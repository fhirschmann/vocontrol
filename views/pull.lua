-- TODO: race conditions are possible
-- TODO: only one client possible right now

local json = dofile("lib/json.lua")
local Queue = dofile("queue.lua")

local queue = Queue:new()


-- Target change
local function target(event, data)
    queue:set("target", GetTargetInfo())
end
RegisterEvent(target, "TARGET_CHANGED")

-- Chat Messages
local function chat(event, data)
    local add = {
        color="#"..chatinfo[event][1]:sub(2),
        formatstring=chatinfo[event]["formatstring"],
    }
    for k, v in pairs(data) do
        add[k] = v
    end
    if data["faction"] then
        add["faction_color"] = "#"..rgbtohex(FactionColor_RGB[data["faction"]]):sub(2)
    end
    if data["location"] then
        add["location"] = ShortLocationStr(data["location"])
    end
    if data["color"] then
        add["color"] = data["color"]:sub(2)
    end
    queue:append("chat", add)
end

for k, _ in pairs(chatinfo) do
    RegisterEvent(chat, k)
end

local function serve(req)
    local last_query = tonumber(req.get_data["last_query"]) or nil

    local r = vohttp.response.Response:new()
    r.headers["Content-Type"] = "application/json"
    --r.headers["Connection"] = "Keep-Alive"

    local sector = {}
    ForEachPlayer(function(pid)
        table.insert(sector,
                     {pid, GetPlayerName(pid), math.floor(GetPlayerDistance(pid) or 0),
                      math.floor(GetPlayerHealth(pid) or 100),
                      GetPlayerFaction(pid), GetPlayerFactionStanding(pid)}) end)
    --queue:set("sector", sector)

    r.body = json.encode(queue:construct(last_query))
    queue:reset()
    print(r.body)
    return r
end

return serve
