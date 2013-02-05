context = {}
context["URL"] = gkini.ReadString("vomote", "url", "https://vomote.0x0b.de/media")


template_base = dofile("templates/base.html.lua")(context)

local function serve(req)
    local r = vohttp.response.Response:new()
    r.body = template_base
    return r
end

return serve
