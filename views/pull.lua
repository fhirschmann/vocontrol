local change = {}

-- Target change
local function target(event, data)
    change["target"] = GetTargetInfo()
end
RegisterEvent(target, "TARGET_CHANGED")

-- Players entering the current sector
local function sector_in(event, data)
    change["sector_in"] = change["sector_in"] or {}
    table.insert(change["sector_in"], data)
end
RegisterEvent(sector_in, "PLAYER_ENTERED_SECTOR")

-- Players leaving the current sector
local function sector_out(event, data)
    change["sector_out"] = change["sector_out"] or {}
    table.insert(change["sector_out"], data)
end
RegisterEvent(sector_out, "PLAYER_LEFT_SECTOR")


local function serve(req)
    local r = vohttp.response.Response:new()
    r.headers["Content-Type"] = "application/json"
    r.body = json.encode(change)
    change = {}
    return r
end

return serve
