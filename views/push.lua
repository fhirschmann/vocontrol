-- TODO: race conditions are possible

local json = dofile("lib/json.lua")

local METHODS = {
    reload=function() gkinterface.GKProcessCommand("vomote reload") end,
    target=function(pid) radar.SetRadarSelection(GetPlayerNodeID(pid), GetPrimaryShipIDOfPlayer(pid)) end,
}

local function pack(...)
    return {...}
end

local function serve(req)
    local data = json.decode(req.post_data)
    print(req.post_data)
    local response = vohttp.response.Response:new()

    local f = METHODS[data["method"]:sub(4)]
    local serve = {jsonrpc="2.0", id=req.post_data["id"]}

    if f then
        local result = pack(pcall(f, unpack(data["params"])))
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
    print(response.body)

    return response
end

return serve
