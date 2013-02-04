dofile("lib/json.lua")

server = vohttp.Server:new()

for k, v in pairs(dofile("urls.lua")) do
    server:add_route(k, v)
end

local port = gkini.ReadInt("vomote", "port", 9001)
local autostart = gkini.ReadInt("vomote", "autostart", 0)

local function cli(data, args)
    if args then
        if args[1] == "start" then
            server:start(port)
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
            server:start(port)
        elseif args[1] == "reload" then
            local listening = server.listening
            if listening then
                server:stop()
            end

            ReloadInterface()
        elseif args[1] == "set" then
            if args[2] == "autostart" then
                if args[3] == "1" or args[3] == "on" then
                    print("vomote: autostart enabled")
                    gkini.WriteInt("vomote", "autostart", 1)
                else
                    gkini.WriteInt("vomote", "autostart", 0)
                    print("vomote: autostart disabled")
                end
            end
        elseif args[1] == "help" then
            if args[2] == "set" then
                print([[
usage: vomote set {autostart}

where:
    autostart {0,1}     enable/disable autostart]])
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
    server:start(port)
end
