---------------
-- ## vomote - a remote control plugin for Vendetta Online.
--
-- [Github Page](https://github.com/fhirschmann/vomote)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

vomote = {
    VERSION="experimental",
    http=dofile("lib/vohttp_packed.lua"),
    util=dofile("util.lua")
}

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
local cmd = {set={}, reset={}, reload=ReloadInterface, help=dofile("help.lua")}

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

function cmd.ctrl(...)
    if ... ~= nil then
        ProcessEvent("VOMOTE_CTRL", {...})
    end
end

for _, opt in pairs({"autostart", "interval", "port", "evqueuesize"}) do
    cmd.set[opt] = vomote.util.func.partial(gkini.WriteInt, "vomote")
end

for _, opt in pairs({"url"}) do
    cmd.set[opt] = vomote.util.func.partial(gkini.WriteString, "vomote")
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
            print("vomote: incomplete command.")
        else
            root(unpack(args))
        end
    end
end

--- Main entry point for the Command Line Interface (CLI).
function cli(data, args)
    if not args then
        print("vomote: no arguments given - try /vomote help.")
    else
        local f = table.remove(args, 1)

        if args and cmd[f] then
            dispatch(cmd[f], args)
        else
            print("vomote: invalid argument(s).")
        end
    end
end

RegisterUserCommand("vomote", cli)

if gkini.ReadInt("vomote", "autostart", 0) == 1 then
    cmd.start(port)
end
