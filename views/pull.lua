---------------
-- ## This view exposes /pull/ which handles pull requests by the browser.
--
-- [Github Page](https://github.com/fhirschmann/vocontrol)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

local json = dofile("lib/json.lua")
local MultiBuffer = dofile("mb.lua")

local mb = MultiBuffer:new()

--- Get info for a player.
-- @param pid the player (character) id
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
local function event_chat(event, data)
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
    mb:append("chat", add)
end

for k, _ in pairs(chatinfo) do
    RegisterEvent(event_chat, k)
end

-- Entered game
local function event_charchange(event, data)
    local name = GetPlayerName()
    if name then
        mb:set("player", player_info(GetCharacterIDByName(name)))
    end
end
RegisterEvent(event_charchange, "ENTERED_STATION")

-- Players in the current sector
local function sectorinfo()
    local sector = {}
    -- tostring because the json lib is broken
    ForEachPlayer(function(pid)
        if GetPlayerName(pid):sub(0, 20) ~= "(reading transponder" then
            sector[tostring(pid)] = player_info(pid)
        end
    end)
    return sector
end

-- Target change
local function event_target(event, data)
    mb:set("target", GetTargetInfo())
end
RegisterEvent(event_target, "TARGET_CHANGED")

-- Commands for the client
local function event_clientcmd(event, data)
    mb:append("cmd", data)
end
RegisterEvent(event_clientcmd, "VOMOTE_CTRL")


local function serve(req)
    local known = mb:get_buffer(tonumber(req.get_data["id"]))
    local id = known and tonumber(req.get_data["id"]) or mb:add_buffer()
    local buffer = mb:get_buffer(id)

    local r = vocontrol.http.response.Response:new()
    r.headers["Content-Type"] = "application/json"
    --r.headers["Connection"] = "Keep-Alive"

    local send = {id=id, sector=sectorinfo()}

    if not known then
        event_charchange()
    end

    r.body = json.encode(vocontrol.util.table.merge(send, buffer:get() or {}))

    buffer:reset()
    return r
end

return serve
