-- TODO: race conditions are possible

local json = dofile("lib/json.lua")
local change = {}

-- Target change
local function target(event, data)
    change["target"] = GetTargetInfo()
end
RegisterEvent(target, "TARGET_CHANGED")

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
