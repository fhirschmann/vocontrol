local config = {}

local settings = {
    autostart=gkini.ReadInt("vocontrol", "autostart", 0),
    interval=gkini.ReadInt("vocontrol", "interval", 2000),
    port=gkini.ReadInt("vocontrol", "port", 9001),
    debug=gkini.ReadInt("vocontrol", "debug", 0),
    url=gkini.ReadString("vocontrol", "url", "/media"),
}

function config.get(option)
    return settings[option]
end

function config.set(option, value)
    settings[option] = value

    if type(settings[option]) == "number" then
        gkini.WriteInt("vocontrol", option, value)
    else
        gkini.WriteString("vocontrol", option, value)
    end
end

function config.get(option)
    return settings[option]
end

function config.all()
    return settings
end

return config
