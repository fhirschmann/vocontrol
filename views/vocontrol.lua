template_base = dofile("templates/base.html.lua")

local function serve(req)
    local context = {
        URL=vocontrol.config.get("url"),
        DEBUG=vocontrol.config.get("debug"),
        INTERVAL=vocontrol.config.get("interval"),
    }


    local r = vocontrol.http.response.Response:new()
    r.body = template_base(context)
    return r
end

return serve
