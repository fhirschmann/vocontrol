urls = {}

urls["/"] = dofile("views/vomote.lua")
urls["/pull/"] = dofile("views/pull.lua")
urls["/media/css/style.css"] = vohttp.dispatch.StaticFile:new("media/css/style.css.lua")
urls["/media/js/vomote.js"] = vohttp.dispatch.StaticFile:new("media/js/vomote.js.lua")

return urls
