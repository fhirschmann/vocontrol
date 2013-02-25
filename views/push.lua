---------------
-- ## This view exposes /push/ which handles commands sent by the browser.
--
-- [Github Page](https://github.com/fhirschmann/vocontrol)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

local json = dofile("lib/json.lua")

local METHODS = {
    reload=function() gkinterface.GKProcessCommand("vocontrol reload") end,
    target=function(pid) radar.SetRadarSelection(GetPlayerNodeID(pid), GetPrimaryShipIDOfPlayer(pid)) end,
    chat=SendChat,
    tabcomplete=TabCompleteName,
    processcmd=gkinterface.GKProcessCommand,
}

local function pack(...)
    return {...}
end

local function serve(req)
    local data = json.decode(req.post_data)
    local response = vocontrol.http.response.Response:new()

    local f = METHODS[data["method"]:sub(4)]
    local serve = {jsonrpc="2.0", id=req.post_data["id"]}

    if f then
        local result = pack(pcall(f, unpack(data["params"] or {})))
        local status = result[1]
        table.remove(result, 1)

        if status then
            serve["result"] = result
        else
            serve["error"] = {code="-1", message=result[1], traceback=debug.traceback()}
        end
    else
        serve["error"] = {code="-1", message="no such function is exposed: "..data["method"]}
    end

    response.body = json.encode(serve)

    return response
end

return serve
