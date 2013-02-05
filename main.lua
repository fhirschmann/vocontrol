local voutil = dofile("util.lua")

-- Server setup
server = vohttp.Server:new()

for k, v in pairs(dofile("urls.lua")) do
    server:add_route(k, v)
end

local function start(port)
    vohttp.DEBUG = gkini.ReadInt("vomote", "debug", 0) == 1
    server:start(port)
end

local port = gkini.ReadInt("vomote", "port", 9001)
local autostart = gkini.ReadInt("vomote", "autostart", 0)

-- Command Line Interface
local VALID_OPTIONS = {"autostart", "debug"}

local function option_onoff(name, arg)
    if arg == nil then
        if gkini.ReadInt("vomote", name, 0) == 0 then
            return option_onoff(name, "1")
        else
            return option_onoff(name, "0")
        end
    end
    if arg == "on" or arg == "1" then
        gkini.WriteInt("vomote", name, 1)
        print("vomote: "..name.." is now enabled")
    else
        gkini.WriteInt("vomote", name, 0)
        print("vomote: "..name.." is now disabled")
    end
end

local function cli(data, args)
    if args then
        if args[1] == "start" then
            start(port)
            print("vomote: now listening on port "..port)
        elseif args[1] == "stop" then
            server:stop()
            print("vomote: no longer listening on port "..port)
        elseif args[1] == "status" then
            if server.listening then
                print("vomote: listening on port "..port)
            else
                print("vomote: not listening on port "..port)
            end
        elseif args[1] == "restart" then
            server:stop()
            start(port)
        elseif args[1] == "reload" then
            local listening = server.listening
            if listening then
                server:stop()
            end

            ReloadInterface()
        elseif args[1] == "set" then
            if voutil.table.contains_value(VALID_OPTIONS, args[2]) then
                option_onoff(args[2], args[3])
            else
                print("No such option")
            end
        elseif args[1] == "help" then
            if args[2] == "set" then
                print([[
usage: vomote set {autostart}

where:]])
                for _, item in pairs(VALID_OPTIONS) do
                    print(item.." {0,1}    enable/disable "..item)
                end
            else
                print([[
usage: vomote {start,stop,restart,reload,set,help} ...

where:
    start       start vomote
    stop        stop vomote
    restart     restart vomote
    reloa       reload vomote (from disk)
    set         set vomote options (see /vomote help set)]])
            end
        else
            print("vomote: unknown command; try /vomote help")
        end
    end
end

RegisterUserCommand("vomote", cli)

if autostart == 1 then
    start(port)
end
