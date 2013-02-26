---------------
-- ## vocontrol - a remote control plugin for Vendetta Online.
--
-- [Github Page](https://github.com/fhirschmann/vocontrol)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

vocontrol = {
    VERSION="experimental",
    http=dofile("lib/vohttp_packed.lua"),
    util=dofile("util.lua"),
    config=dofile("config.lua"),
}

-- Server setup
local server = vocontrol.http.Server:new()
local port = vocontrol.config.get("port")

for k, v in pairs(dofile("urls.lua")) do
    server:add_route(k, v)
end

-- Stop listening on reload
RegisterEvent(function(event, data)
        if server.listening then
            server:stop()
        end
    end, "UNLOAD_INTERFACE")

-- CLI
local cmd = {
    config={
        set=vocontrol.config.set,
        get=function(s) print(vocontrol.config.get(s)) end,
    },
    reload=ReloadInterface,
    help=dofile("help.lua")}

function cmd.start()
    server:start(port)
    print("vocontrol: now listening on port "..port)
end

function cmd.stop()
    server:stop()
    print("vocontrol: no longer listening on port "..port)
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

--- Dispatches function calls in a DFS-manner
-- @param root the top element in the function tree
-- @param args arguments given by the user
local function dispatch(root, args)
    if type(root) == "table" and root[args[1]] ~= nil then
        local a = table.remove(args, 1)
        dispatch(root[a], args)
    else
        if type(root) == "table" then
            print("vocontrol: incomplete command.")
        else
            root(unpack(args))
        end
    end
end

--- Main entry point for the Command Line Interface (CLI).
function cli(data, args)
    if not args then
        print("vocontrol: no arguments given - try /vocontrol help.")
    else
        local f = table.remove(args, 1)

        if args and cmd[f] then
            dispatch(cmd[f], args)
        else
            print("vocontrol: invalid argument(s).")
        end
    end
end

RegisterUserCommand("vocontrol", cli)

if vocontrol.config.get("autostart") == 1 then
    cmd.start(port)
end
