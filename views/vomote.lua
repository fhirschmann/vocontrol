context = {}
context["URL"] = vomote.config.get("url")
context["DEBUG"] = vomote.config.get("debug")


template_base = dofile("templates/base.html.lua")(context)

local function serve(req)
    local r = vomote.http.response.Response:new()
    r.body = template_base
    return r
end

return serve
