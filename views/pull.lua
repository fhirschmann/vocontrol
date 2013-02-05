-- TODO: race conditions are possible

local json = dofile("lib/json.lua")
local change = {}

-- Target change
local function target(event, data)
    change["target"] = GetTargetInfo()
end
RegisterEvent(target, "TARGET_CHANGED")

-- Chat Messages
local function chat(event, data)
    change["chat"] = change["chat"] or {}
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
    table.insert(change["chat"], add)
end

for k, _ in pairs(chatinfo) do
    RegisterEvent(chat, k)
end

local function serve(req)
    local r = vohttp.response.Response:new()
    r.headers["Content-Type"] = "application/json"

    change["sector"] = {}
    ForEachPlayer(function(pid)
        table.insert(change["sector"],
                     {pid, GetPlayerName(pid), math.floor(GetPlayerDistance(pid) or 0),
                      math.floor(GetPlayerHealth(pid) or 100),
                      GetPlayerFaction(pid), GetPlayerFactionStanding(pid)}) end)

    r.body = json.encode(change)
    change = {}
    return r
end

return serve
