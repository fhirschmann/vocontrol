-- packed using volupack.
-- main.lua starts.

local vohttp = {}
vohttp.DEBUG = gkini.ReadString("vohttp", "debug", 0) == 1

function vohttp.debug_print(msg)
    if vohttp.DEBUG then
        print(msg)
    end
end

-- lib/tcpsock.lua starts.

-- written by Andy

-- hacked for http use (post data does not send CRLF)
-- "\n\r\n" is now appended when all data has been received
-- that was requested by Content-Length

local TCP = {}


local function SetupLineInputHandlers(conn, conn_handler, line_handler, disconn_handler)
  local buf = ''
  local match
  local connected
  local wait_for = nil
  local in_body = false

  conn.tcp:SetReadHandler(function()
    local msg, errcode = conn.tcp:Recv()
    if not msg then
      if not errcode then return end
      local err = conn.tcp:GetSocketError()
      if err then log.error(err) end
      conn.tcp:Disconnect()
      disconn_handler(conn)
      conn = nil
      return
    end
    buf = buf..msg
    repeat
    if in_body then
        if buf:len() == wait_for then
            buf = buf.."\r\n\r\n"
        end
    end
      buf,match = string.gsub(buf, "^([^\n]*)\n", function(line)
        if line:find("^Content%-Length") then
            wait_for = tonumber(line:match("Content%-Length: (%d+)"))
        elseif line == "\r" then
            in_body = true
        end
        local result, err_msg = pcall(line_handler, conn, line)
        if not result then
            console_print(err_msg)
            console_print(debug.traceback())
        end
        return ''
      end)
    until (match==0)
  end)

  local writeq = {}
  local qhead,qtail=1,1

  -- returns true if some data was written
  -- returns false if we need to schedule a write callback to write more data
  local write_line_of_data = function()
    --print(tostring(conn)..': sending  '..writeq[qtail])
    local bsent = conn.tcp:Send(writeq[qtail])
    -- if we sent a partial line, keep the rest of it in the queue
    if bsent == -1 then
      -- EWOULDBLOCK?  dunno if i can check for that
      return false
      --error(string.format("write(%q) failed!", writeq[qtail]))
    elseif bsent < string.len(writeq[qtail]) then
      -- consume partial line
      writeq[qtail] = string.sub(writeq[qtail], bsent+1, -1)
      return false
    end
    -- consume whole line
    writeq[qtail] = nil
    qtail = qtail + 1
    return true
  end
  
  -- returns true if all available data was written
  -- false if we need a subsequent write handler
  local write_available_data = function()
    while qhead ~= qtail do
      if not write_line_of_data() then
        return false
      end
    end
    qhead,qtail = 1,1
    return true
  end

  local writehandler = function()
    if write_available_data() then 
      conn.tcp:SetWriteHandler(nil)
    end
  end

  function conn:Send(line)
    --print(tostring(conn)..': queueing '..line)
    writeq[qhead] = line
    qhead = qhead + 1
    if not write_available_data() then
      conn.tcp:SetWriteHandler(writehandler)
    end
  end

  local connecthandler = function()
    conn.tcp:SetWriteHandler(writehandler)
    connected = true
    local err = conn.tcp:GetSocketError()
    if err then 
      conn.tcp:Disconnect()
      return conn_handler(nil, err)
    end
    return conn_handler(conn)
  end

  conn.tcp:SetWriteHandler(connecthandler)
end

-- raw version
function TCP.make_client(host, port, conn_handler, line_handler, disconn_handler)
  local conn = {tcp=TCPSocket()}

  SetupLineInputHandlers(conn, conn_handler, line_handler, disconn_handler)

  local success,err = conn.tcp:Connect(host, port)
  if not success then return conn_handler(nil, err) end

  return conn
end

function TCP.make_server(port, conn_handler, line_handler, disconn_handler)
  local conn = TCPSocket()
  local connected = false
  local buf = ''
  local match

  conn:SetConnectHandler(function()
    local newconn = conn:Accept()
    --print('Accepted connection '..newconn:GetPeerName())
    SetupLineInputHandlers({tcp=newconn}, conn_handler, line_handler, disconn_handler)
  end)
  local ok, err = conn:Listen(port)
  if not ok then error(err) end

  return conn
end
-- lib/tcpsock.lua ends.
-- util.lua starts.

---------------
-- ## HTTP utility functions.
--
-- [Github Page](https://github.com/fhirschmann/vohttp)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

vohttp.util = {}

--- Escapes a string for transmittion over the HTTP protocol.
-- @param s the string to escape
-- @return an escaped string
-- @see vohttp.util.unescape
function vohttp.util.escape(s)
    local s = string.gsub(s, "([&=+%c])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    s = string.gsub(s, " ", "+")
    return s
end

--- Unescapes a previously escaped string.
-- @param s the string to unescape
-- @return an unescaped string
-- @see vottp.util.escape
function vohttp.util.unescape(s)
    local s = string.gsub(s, "+", " ")
    s = string.gsub(s, "%%(%x%x)", function(h)
        return string.char(tonumber(h, 16))
    end)
    return s
end

--- Decodes a previously encoded key/value string.
-- @param s the string to decode
-- @return a table of key and values
function vohttp.util.decode(s)
    local cgi = {}
    for name, value in s:gmatch("([^&=]+)=([^&=]+)") do
        name = vohttp.util.unescape(name)
        value = vohttp.util.unescape(value)
        cgi[name] = value
    end
    return cgi
end

--- Encodes a table of key/values for transmittion over the HTTP protocol.
-- @param t the table to encode
-- @return a string-encoded key-value table
-- @see vohttp.util.decode
function vohttp.util.encode(t)
    local s = ""
    for k,v in pairs(t) do
        s = s .. "&" .. vohttp.util.escape(k) .. "=" .. vohttp.util.escape(v)
    end
    return s:sub(2)
end
-- util.lua ends.
-- request.lua starts.

---------------
-- ## HTTP Request Object.
--
-- [Github Page](https://github.com/fhirschmann/vohttp)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

vohttp.request = {}
vohttp.request.Request = {}

--- Creates a new empty HTTP Request Object.
-- @param con the connection context
function vohttp.request.Request:new(con)
    --- the command set by the client
    self.command = nil

    --- the connection context
    self.con = con

    --- the requested path
    self.path = nil

    --- the headers the clients sent
    self.headers = {}

    --- the HTTP version used by the client
    self.version = nil

    --- the GET data sent by the client
    self.get_data = {}

    -- the POST data sent by the client
    self.post_data = {}

    return self
end


--- Contructs an already initialized Request from a query with a client
-- @param query the query with the client (a table of lines)
function vohttp.request.Request:load_query(query)
    self.command, self.path, self.version = query[1]:match("(.*) (.*) HTTP/(.*)")

    if self.path:find("%?") then
       self.path, self.get_data = self.path:match("(.*)%?(.*)")
       self.get_data = vohttp.util.decode(self.get_data)
    end

    for n, h in ipairs(query) do
        if n ~= 1 then
            local name, value = h:match("(.*): (.*)")
            if name then
                self.headers[name] = value
            end
        end
    end

    if self.command == "POST" then
        if self.headers["Content-Type"] == "application/x-www-form-urlencoded" then
            self.post_data = vohttp.util.decode(query[table.getn(query)])
        else
            self.post_data = query[table.getn(query)]
        end
    end

    return self
end
-- request.lua ends.
-- response.lua starts.

---------------
-- ## HTTP Response Object.
--
-- [Github Page](https://github.com/fhirschmann/vohttp)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

vohttp.response = {}
vohttp.response.Response = {}
vohttp.response.GenericResponse = {}
vohttp.response.NotFoundResponse = {}
vohttp.response.InternalServerErrorResponse = {}

--- Creates a new empty HTTP Response Object (with default values).
-- @param request table of lines received via HTTP
function vohttp.response.Response:new()
    --- the status code (defaults to 200)
    self.status_code = 200

    --- the status message (defaults to "OK")
    self.status_message = "OK"

    --- the http version (defaults to "1.0" and should not be changed)
    self.version = "1.0"

    -- disconnect after serving this response
    self.disconnect = true

    --- any additional headers such as content-type
    self.headers = {}
    self.headers["Content-Type"] = "text/html"
    self.headers["Connection"] = "close"

    --- the response body (the content)
    self.body = ""

    return self
end

--- Constructs a Response string ready to be served
function vohttp.response.Response:construct()
    local lines = {}
    table.insert(lines, table.concat({"HTTP/"..self.version, self.status_code,
                                      self.status_message}, " "))

    for k, v in pairs(self.headers) do
        if v == "Content-Type" then
            if not v:match("charset") then
                v = v.."; charset=iso-8859-1"
            end
        end
        table.insert(lines, k..": "..v)
    end

    table.insert(lines, "Content-Length: "..self.body:len())

    table.insert(lines, "\r")
    table.insert(lines, self.body)

    return lines
end

--- A shorthand for generating simple responses (i.e., 404)
-- @param status_code the HTTP status code
-- @param status_msg the status message for the given status code
-- @param body the body of the response (the content)
function vohttp.response.GenericResponse:new(status_code, status_message, body)
    local response = vohttp.response.Response:new()
    response.status_code = status_code
    response.status_message = status_message
    response.body = body

    return response
end

--- Constructs a 404 (Not Found) Response
function vohttp.response.NotFoundResponse:new()
    return vohttp.response.GenericResponse:new(404, "Not Found",
        "<html><body><h1>Not found</h1>The requested page was not found on this server.</body></html>")
end

--- Constructs a new 500 (Internal Server Error) Response
-- @param msg the error message
function vohttp.response.InternalServerErrorResponse:new(msg)
    return vohttp.response.GenericResponse:new(500, "Internal Server Error",
        "<html><body><h1>Internal Server Error</h1><pre>."..msg.."</pre></body></html>")
end
-- response.lua ends.
-- dispatch.lua starts.

---------------
-- ## Generic dispatcher
--
-- [Github Page](https://github.com/fhirschmann/vohttp)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

vohttp.dispatch = {}
vohttp.dispatch.StaticPage = {}
vohttp.dispatch.StaticFile = {}

--- Creates a dispatcher that serves a static page
-- @param path to the file to serve
-- @param the content type
function vohttp.dispatch.StaticPage:new(body, content_type)
    return function(serve)
        local r = vohttp.response.Response:new()
        r.body = body
        if content_type then
            r.headers["Content-Type"] = content_type
        end

        return r
    end
end

--- Creates a dispatcher that serves a static file
-- @param path the path to the file to serve
-- @param the content type
function vohttp.dispatch.StaticFile:new(path, content_type)
    if not content_type then
        if path:match("css.lua$") then
            content_type = "text/css"
        elseif path:match("js.lua$") then
            content_type = "application/javascript"
        end
    end
    return vohttp.dispatch.StaticPage:new(dofile(path), content_type)
end
-- dispatch.lua ends.
-- server.lua starts.

---------------
-- ## A simple HTTP Server for Vendetta Online.
--
-- [Github Page](https://github.com/fhirschmann/vohttp)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

vohttp.Server = {}

--- Creates a new Server instance.
-- @return a new Server instance
function vohttp.Server:new()
    self._socket = nil
    self._routes = {}
    self._buffer = {}
    self.connections = {}
    self.listening = false

    return self
end

--- Adds a new route dispatcher to this VOServe instance.
-- Use this method to add routes under which your application
-- should respond to.
-- @param route the route (string)
-- @param dispatcher a dispatcher function that returns a response
function vohttp.Server:add_route(route, dispatcher)
    self._routes[route] = dispatcher
end

--- Called when a new connection is made (internal function).
-- @param con the connection context
function vohttp.Server:_connection_made(con)
    vohttp.debug_print("Connection from "..con.tcp:GetPeerName())
    self._buffer[con.tcp:GetPeerName()] = {}
    self.connections[con] = true

    -- waiting for POST data
    self._wait_for = {}
end

--- Called when a new line is received (internal function).
-- @param con the connection context
-- @param line the line that was received
function vohttp.Server:_line_received(con, line)
    local ready = false

    if line == "\r" then
        -- Andy's tcpsock strips off the \n in \r\n

        if self._wait_for[con.tcp:GetPeerName()] then
            self._wait_for[con.tcp:GetPeerName()] = false
        else
            ready = true
        end

    else
        table.insert(self._buffer[con.tcp:GetPeerName()],
                     line:sub(0, line:len() - 1))
        if line:find("^Content%-Length") then
            self._wait_for[con.tcp:GetPeerName()] = true
        end
    end

    if ready then
        local request = vohttp.request.Request:new(con)
        request:load_query(self._buffer[con.tcp:GetPeerName()])
        self:_request_received(con, request)
    end
end

--- Called when a new HTTP request was received.
-- @param con the connection context
-- @param request the request received
function vohttp.Server:_request_received(con, request)
    local response

    if self._routes[request.path] then
        local status
        status, response = pcall(self._routes[request.path], request)
        if not status then
            response = response.."\n"..debug.traceback()
            log_print(response)
            response = vohttp.response.InternalServerErrorResponse:new(response)
        end
    else
        response = vohttp.response.NotFoundResponse:new()
    end

    for _, line in ipairs(response:construct()) do
        con:Send(line.."\n")
    end

    if response.disconnect then
        con.tcp:Disconnect()
    end
end

--- Called when a connection is lost (internal function).
-- @param con the connection context
function vohttp.Server:_connection_lost(con)
    vohttp.debug_print("Lost connection")
    self.connections[con] = nil
end

--- Starts listening for requests.
-- @param port the port to listen to
function vohttp.Server:start(port)
    if self.listening then
        print("ERROR: Socket already open.")
    else
        self._socket = TCP.make_server(port,
                        function(con, err)
                            if con then
                                self:_connection_made(con)
                            end
                        end,
                        function(con, line)
                            self:_line_received(con, line)
                        end,
                        function(con)
                            self:_connection_lost(con)
                        end)
        print("OK: Now listening on port "..port)
        self.listening = true
    end
end

-- Stops listening for requests.
function vohttp.Server:stop()
    if self and self.listening then
        for k, v in ipairs(self.connections) do
            k:Disconnect()
            self.connections[k] = nil
        end
        self._socket:Disconnect()
        self.listening = false
    else
        vohttp.print("Error: Server is not listening.")
    end
end
-- server.lua ends.
-- main.lua ends.
return vohttp
