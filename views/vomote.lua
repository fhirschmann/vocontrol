template_base = dofile("templates/base.html.lua")

local function serve(req)
    local context = {
        URL=vomote.config.get("url"),
        DEBUG=vomote.config.get("debug"),
        INTERVAL=vomote.config.get("interval"),
    }


    local r = vomote.http.response.Response:new()
    r.body = template_base(context)
    return r
end

return serve
