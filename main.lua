local voutil = dofile("util.lua")
vomote = {}
vomote.http = dofile("lib/vohttp_packed.lua")

if gkini.ReadInt("vomote", "dev", 0) == 1 then
    -- vomote.http needs to be loaded globally in this case
    vomote.http = vohttp
end

-- Server setup
server = vomote.http.Server:new()

for k, v in pairs(dofile("urls.lua")) do
    server:add_route(k, v)
end

RegisterEvent(function(event, data)
        if server.listening then
            server:stop()
        end
    end, "UNLOAD_INTERFACE")

local function start(port)
    vomote.DEBUG = gkini.ReadInt("vomote", "debug", 0) == 1
    server:start(port)
end

local port = gkini.ReadInt("vomote", "port", 9001)

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
            ReloadInterface()
        elseif args[1] == "set" then
            if voutil.table.contains_value(VALID_OPTIONS, args[2]) then
                option_onoff(args[2], args[3])
            elseif args[2] == "url" then
                if args[3] == "reset" then
                    gkini.WriteString("vomote", "url", "")
                else
                    gkini.WriteString("vomote", "url", args[3])
                end
            else
                print("No such option")
            end
        elseif args[1] == "help" then
            if args[2] == "set" then
                print([[
usage: vomote set OPTION

where OPTION is:]])
                for _, item in pairs(VALID_OPTIONS) do
                    print(item.." {0,1}    enable/disable "..item)
                end
                print([[
url {URL,reset}   (re)sets the media URL
                ]])
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

if gkini.ReadInt("vomote", "autostart", 0) == 1 then
    start(port)
end
