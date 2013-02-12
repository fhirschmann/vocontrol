local config = {}

local settings = {
    autostart=gkini.ReadInt("vomote", "autostart", 0),
    interval=gkini.ReadInt("vomote", "interval", 2000),
    port=gkini.ReadInt("vomote", "port", 9001),
    debug=gkini.ReadInt("vomote", "debug", 0),
    url=gkini.ReadString("vomote", "url", ""),
}

function config.get(option)
    return settings[option]
end

function config.set(option, value)
    settings[option] = value

    if type(settings[option]) == "number" then
        gkini.WriteInt("vomote", option, value)
    else
        gkini.WriteString("vomote", option, value)
    end
end

function config.get(option)
    return settings[option]
end

function config.all()
    return settings
end

return config
