context = {}
context["URL"] = gkini.ReadString("vomote", "url",
    "https://raw.github.com/fhirschmann/vomote/master/media")


template_base = dofile("templates/base.html.lua")(context)

local function serve(req)
    local r = vohttp.response.Response:new()
    r.body = template_base
    return r
end

return serve
