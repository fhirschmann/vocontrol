local json = dofile("lib/json.lua")
local Queue = dofile("queue.lua")

local queue = Queue:new()
local queue_volatile = Queue:new(3)


-- Target change
local function target(event, data)
    queue:set("target", GetTargetInfo())
end
RegisterEvent(target, "TARGET_CHANGED")

--- Get info for a player.
-- @return a tuple (name, dist, health, faction_id, faction_name, guild_tag, ship)
local function player_info(pid)
    local av = GetPlayerDistance(pid) or false
    return {
        GetPlayerName(pid),
        av and math.ceil(av).."m" or "",
        av and math.ceil(GetPlayerHealth(pid)) or "",
        GetPlayerFaction(pid),
        FactionName[GetPlayerFaction(pid)],
        GetGuildTag(pid),
        av and GetPrimaryShipNameOfPlayer(pid) or "",
    }
end

-- Chat Messages
local function chat(event, data)
    if not chatinfo[event]["formatstring"] then
        return
    end

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

-- Entered game
local function entered(event, data)
    local name = GetPlayerName()
    if name then
        queue:set("player", player_info(GetCharacterIDByName(name)))
    end
end
RegisterEvent(entered, "ENTERED_STATION")

-- Players in the current sector
local function sector()
    local sector = {}
    -- tostring because the json lib is broken
    ForEachPlayer(function(pid)
        if GetPlayerName(pid):sub(0, 20) ~= "(reading transponder" then
            sector[tostring(pid)] = player_info(pid)
        end
    end)
    queue_volatile:set("sector", sector)
end

--[[
-- Print Messages
local print_orig = print
function print(...)
    print_orig(...)
    if not ... then
        return
    end

    for _, line in ipairs(vomote.util.string.split(..., "\n")) do
        queue:append("chat", {formatstring="<msg>", color="#28b4f0", msg=line})
    end
end
safe_print = print
--]]

-- Commands for the client
local function clientcmd(event, data)
    queue:append("cmd", data)
end
RegisterEvent(clientcmd, "VOMOTE_CTRL")

for k, _ in pairs(chatinfo) do
    RegisterEvent(chat, k)
end

local function serve(req)
    local last_query = tonumber(req.get_data["last_query"]) or nil

    local r = vomote.http.response.Response:new()
    r.headers["Content-Type"] = "application/json"
    --r.headers["Connection"] = "Keep-Alive"

    sector()

    if not last_query then
        entered()
    end

    local q1 = queue:construct(last_query)
    local q2 = queue_volatile:construct(last_query)

    r.body = json.encode(vomote.util.table.union(q1, q2))

    queue:reset()
    return r
end

return serve
