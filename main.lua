local voutil = dofile("util.lua")
vomote = {}
vomote.VERSION = "experimental"
vomote.http = dofile("lib/vohttp_packed.lua")
vomote.util = dofile("util.lua")

if gkini.ReadInt("vomote", "dev", 0) == 1 then
    -- vomote.http needs to be loaded globally in this case
    vomote.http = vohttp
end

-- Server setup
server = vomote.http.Server:new()

for k, v in pairs(dofile("urls.lua")) do
    server:add_route(k, v)
end

-- Stop listening on reload
RegisterEvent(function(event, data)
        if server.listening then
            server:stop()
        end
    end, "UNLOAD_INTERFACE")

local port = gkini.ReadInt("vomote", "port", 9001)


-- CLI
local cmd = {}
cmd.set = {}

function cmd.start()
    vomote.DEBUG = gkini.ReadInt("vomote", "debug", 0) == 1
    server:start(port)
    print("vomote: now listening on port "..port)
end

function cmd.stop()
    server:stop()
    print("vomote: no longer listening on port "..port)
end

function cmd.restart()
    cmd.stop()
    cmd.start()
end

cmd.reload = ReloadInterface

cmd.set.url = voutil.func.partial(gkini.WriteString, "vomote", "url")

for _, opt in pairs({"autostart", "interval", "port", "evqueuesize"}) do
    cmd.set[opt] = voutil.func.partial(gkini.WriteString, "vomote")
end

-- CLI: Help

function cmd.help()
    print([[usage: vomote {start,stop,restart,reload,set,help} ...

where:
    start - start vomote
    stop - stop vomote
    restart - restart vomote
    reload - reload interface
    set {url,autostart,interval,port,evqueuesize} - set various options]])
end

--- Dispatches function calls in a DFS-manner
-- @param root the top element in the function tree
-- @param args arguments given by the user
local function dispatch(root, args)
    if type(root) == "table" and root[args[1]] ~= nil then
        local a = table.remove(args, 1)
        dispatch(root[a], args)
    else
        if type(root) == "table" then
            print(root)
            print("vomote: incomplete command.")
        else
            root(unpack(args))
        end
    end
end

function cli(data, args)
    local f = table.remove(args, 1)

    if args and cmd[f] then
        dispatch(cmd[f], args)
    else
        print("vomote: invalid argument(s).")
    end
end

RegisterUserCommand("vomote", cli)

if gkini.ReadInt("vomote", "autostart", 0) == 1 then
    cmd.start(port)
end
