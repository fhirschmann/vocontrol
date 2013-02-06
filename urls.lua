urls = {}

urls["/"] = dofile("views/vomote.lua")
urls["/pull/"] = dofile("views/pull.lua")
urls["/push/"] = dofile("views/push.lua")
--urls["/media/css/style.css"] = vomote.http.dispatch.StaticFile:new("media/css/style.css.lua")
--urls["/media/js/vomote.js"] = vomote.http.dispatch.StaticFile:new("media/js/vomote.js.lua")

return urls
