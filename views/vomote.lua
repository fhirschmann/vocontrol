context = {}
context["URL"] = gkini.ReadString("vomote", "url",
                                  "http://vomote.0x0b.de/"..vomote.VERSION.."/media")
context["DEBUG"] = gkini.ReadInt("vomote", "debug", 0) == 1


template_base = dofile("templates/base.html.lua")(context)

local function serve(req)
    local r = vomote.http.response.Response:new()
    r.body = template_base
    return r
end

return serve
