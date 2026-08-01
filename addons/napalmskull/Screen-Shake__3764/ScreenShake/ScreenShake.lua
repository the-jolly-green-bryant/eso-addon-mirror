local function setScreenShake(value)
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SCREEN_SHAKE, value)
end

local ScreenShake = {
    name = 'ScreenShake',
    variableVersion = 1,
    default = {
        pve = 1,
        pvp = 0,
    }
}

local function updateScreenShake()
    if IsPlayerInAvAWorld() or IsActiveWorldBattleground() then
        setScreenShake(ScreenShake.current.pvp)
    else
        setScreenShake(ScreenShake.current.pve)
    end
end

local function OnAddonLoaded(event, name)
    if name ~= ScreenShake.name then return end

    EVENT_MANAGER:UnregisterForEvent(ScreenShake.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

    ScreenShake.current = ZO_SavedVars:NewAccountWide('saved'..ScreenShake.name, ScreenShake.variableVersion, nil, ScreenShake.default)

    EVENT_MANAGER:RegisterForEvent(ScreenShake.name, EVENT_PLAYER_ACTIVATED, function ()
        updateScreenShake()
    end)

    SLASH_COMMANDS["/ss"] = function (value)
        setScreenShake(value)
    end;

    LibAddonMenu2:RegisterAddonPanel(ScreenShake.name, {
        type = 'panel',
        name = 'Screen Shake',
        slashCommand = '/ssoptions',
    })
    LibAddonMenu2:RegisterOptionControls(ScreenShake.name, {
        {
            type = 'slider',
            name = 'PvE',
            getFunc = function()
                return ScreenShake.current.pve * 100
            end,
            setFunc = function(value)
                ScreenShake.current.pve = value / 100
                updateScreenShake()
            end,
            min = 0,
            max = 100,
        },
        {
            type = 'slider',
            name = 'PvP',
            getFunc = function()
                return ScreenShake.current.pvp * 100
            end,
            setFunc = function(value)
                ScreenShake.current.pvp = value / 100
                updateScreenShake()
            end,
            min = 0,
            max = 100,
        }
    })
end

EVENT_MANAGER:RegisterForEvent(ScreenShake.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
