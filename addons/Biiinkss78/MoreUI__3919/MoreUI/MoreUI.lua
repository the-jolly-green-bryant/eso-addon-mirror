MoreUI = {}
MoreUI.name = "MoreUI"
MoreUI.dailyStartTime = os.time()
MoreUI.sessionTimePlayed =
{
    startTime = MoreUI.dailyStartTime,
    hours = 0,
    minutes = 0,
    seconds = 0
}

local function options_GetLang()
    return sv.lang
end

local function options_SetLang(s)
    sv.lang = s
end

local function updateClock()
    local time

    if options_GetLang() == "FR" then
        time = os.date("%A %d %B  %H:%M:%S")
    else
        time = os.date("%A %B %d  %H:%M:%S")
    end

    ClockLabel:SetText(time)
end

local function updateFramerate()
    local fps = math.floor(GetFramerate())
    if fps <= 30 then
        FramerateLabel:SetText("|cff0000" .. fps .. " FPS|")
    else
        FramerateLabel:SetText(fps .. " FPS")
    end
end

local function updateDailyTimePlayed()
    if sv.day ~= tonumber(os.date("%d")) then
        sv.day = tonumber(os.date("%d"))
        sv.dailyTimePlayedHours = 0
        sv.dailyTimePlayedMinutes = 0
        sv.dailyTimePlayedSeconds = 0
    end

    local diff = os.difftime(os.time(), MoreUI.dailyStartTime)
    if diff >= 1 then
        sv.dailyTimePlayedSeconds = sv.dailyTimePlayedSeconds + diff

        if sv.dailyTimePlayedSeconds >= 60 then
            sv.dailyTimePlayedSeconds = 0
            sv.dailyTimePlayedMinutes = sv.dailyTimePlayedMinutes + 1
        end

        if sv.dailyTimePlayedMinutes >= 60 then
            sv.dailyTimePlayedMinutes = 0
            sv.dailyTimePlayedHours = sv.dailyTimePlayedHours + 1
        end
        
        MoreUI.dailyStartTime = os.time()
    end

    if options_GetLang() == "FR" then
        DailyTimePlayedLabel:SetText("Journée " .. sv.dailyTimePlayedHours .. " heure(s) " .. sv.dailyTimePlayedMinutes .. " minute(s) " .. sv.dailyTimePlayedSeconds .. " seconde(s)")
    else
        DailyTimePlayedLabel:SetText("Daily " .. sv.dailyTimePlayedHours .. " hour(s) " .. sv.dailyTimePlayedMinutes .. " minute(s) " .. sv.dailyTimePlayedSeconds .. " second(s)")
    end    
end

local function updateSessionTimePlayed()
    local diff = os.difftime(os.time(), MoreUI.sessionTimePlayed.startTime)
    if diff >= 1 then
        MoreUI.sessionTimePlayed.seconds = MoreUI.sessionTimePlayed.seconds + diff

        if MoreUI.sessionTimePlayed.seconds >= 60 then
            MoreUI.sessionTimePlayed.seconds = 0
            MoreUI.sessionTimePlayed.minutes = MoreUI.sessionTimePlayed.minutes + 1
        end

        if MoreUI.sessionTimePlayed.minutes >= 60 then
            MoreUI.sessionTimePlayed.minutes = 0
            MoreUI.sessionTimePlayed.hours = MoreUI.sessionTimePlayed.hours + 1
        end
        
        MoreUI.sessionTimePlayed.startTime = os.time()
    end

    if options_GetLang() == "FR" then
        SessionTimePlayedLabel:SetText("Session " .. MoreUI.sessionTimePlayed.hours .. " heure(s) " .. MoreUI.sessionTimePlayed.minutes .. " minute(s) " .. MoreUI.sessionTimePlayed.seconds .. " seconde(s)")
    else
        SessionTimePlayedLabel:SetText("Session " .. MoreUI.sessionTimePlayed.hours .. " hours(s) " .. MoreUI.sessionTimePlayed.minutes .. " minute(s) " .. MoreUI.sessionTimePlayed.seconds .. " second(s)")
    end
end

local function update()
    updateClock()
    updateFramerate()
    updateDailyTimePlayed()
    updateSessionTimePlayed()

    zo_callLater(function() update() end, 1000)
end

local function roundFloat(number, digit_position)
    local precision = 10 ^ digit_position
    number = number + (precision / 2)
    return math.floor(number / precision) * precision
end

local function options_IsExpToggled()
    return sv.expToggled
end

local function options_ToggleExp(b)
    XPPercentLabel:SetHidden(not b)
    XPLevelLabel:SetHidden(not b)
    XPBarFrontTexture:SetHidden(not b)
    XPBarBackTexture:SetHidden(not b)
    sv.expToggled = b
end

local function options_SetExpPosition(a, o)
    if a == 'x' then
        sv.expX = o
        XP:SetTransformOffsetX(o)
    else
        sv.expY = o
        XP:SetTransformOffsetY(o)
    end
end

local function options_GetExpPosition(a)
    if a == 'x' then
        return sv.expX
    else
        return sv.expY
    end
end

local function options_IsFPSToggled()
    return sv.fpsToggled
end

local function options_ToggleFPS(b)
    FramerateLabel:SetHidden(not b)
    sv.fpsToggled = b
end

local function options_SetFPSPosition(a, o)
    if a == 'x' then
        sv.fpsX = o
        FramerateLabel:SetTransformOffsetX(o)
    else
        sv.fpsY = o
        FramerateLabel:SetTransformOffsetY(o)
    end
end

local function options_GetFPSPosition(a)
    if a == 'x' then
        return sv.fpsX
    else
        return sv.fpsY
    end
end

local function options_IsDailyTimeToggled()
    return sv.dailyTimeToggled
end

local function options_ToggleDailyTime(b)
    DailyTimePlayedLabel:SetHidden(not b)
    sv.dailyTimeToggled = b
end

local function options_SetDailyTimePosition(a, o)
    if a == 'x' then
        sv.dailyTimePlayedX = o
        DailyTimePlayedLabel:SetTransformOffsetX(o)
    else
        sv.dailyTimePlayedY = o
        DailyTimePlayedLabel:SetTransformOffsetY(o)
    end
end

local function options_GetDailyTimePosition(a)
    if a == 'x' then
        return sv.dailyTimePlayedX
    else
        return sv.dailyTimePlayedY
    end
end

local function options_IsSessionTimeToggled()
    return sv.sessionTimeToggled
end

local function options_ToggleSessionTime(b)
    SessionTimePlayedLabel:SetHidden(not b)
    sv.sessionTimeToggled = b
end

local function options_SetSessionTimePosition(a, o)
    if a == 'x' then
        sv.sessionTimePlayedX = o
        SessionTimePlayedLabel:SetTransformOffsetX(o)
    else
        sv.sessionTimePlayedY = o
        SessionTimePlayedLabel:SetTransformOffsetY(o)
    end
end

local function options_GetSessionTimePosition(a)
    if a == 'x' then
        return sv.sessionTimePlayedX
    else
        return sv.sessionTimePlayedY
    end
end

local function options_IsClockToggled()
    return sv.clockToggled
end

local function options_ToggleClock(b)
    ClockLabel:SetHidden(not b)
    sv.clockToggled = b
end

local function options_SetClockPosition(a, o)
    if a == 'x' then
        sv.clockX = o
        ClockLabel:SetTransformOffsetX(o)
    else
        sv.clockY = o
        ClockLabel:SetTransformOffsetY(o)
    end
end

local function options_GetClockPosition(a)
    if a == 'x' then
        return sv.clockX
    else
        return sv.clockY
    end
end

local function options_SetExpFillColor(p, r, g, b)
    if p == 25 then
        sv.exp25_r = r
        sv.exp25_g = g
        sv.exp25_b = b
        XPBarFrontTexture:SetColor(sv.exp25_r, sv.exp25_g, sv.exp25_b, 255)
    elseif p == 50 then
        sv.exp50_r = r
        sv.exp50_g = g
        sv.exp50_b = b
        XPBarFrontTexture:SetColor(sv.exp50_r, sv.exp50_g, sv.exp50_b, 255)
    elseif p == 75 then
        sv.exp75_r = r
        sv.exp75_g = g
        sv.exp75_b = b
        XPBarFrontTexture:SetColor(sv.exp75_r, sv.exp75_g, sv.exp75_b, 255)
    else
        sv.expS75_r = r
        sv.expS75_g = g
        sv.expS75_b = b
        XPBarFrontTexture:SetColor(sv.expS75_r, sv.expS75_g, sv.expS75_b, 255)
    end
end

local function options_SetExpBorderColor(r, g, b)
    sv.expBorder_r = r
    sv.expBorder_g = g
    sv.expBorder_b = b
    XPBarBorderTexture:SetColor(sv.expBorder_r, sv.expBorder_g, sv.expBorder_b, 255)
end

local function options_SetExpBackColor(r, g, b)
    sv.expBack_r = r
    sv.expBack_g = g
    sv.expBack_b = b
    XPBarBackTexture:SetColor(sv.expBack_r, sv.expBack_g, sv.expBack_b, 255)
end

function MoreUI.OnLoaded(event, name)
    if name ~= MoreUI.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)

    local svTable =
    {
        day = tonumber(os.date("%d")),
        dailyTimePlayedSeconds = 0,
        dailyTimePlayedMinutes = 0,
        dailyTimePlayedHours = 0,
        expToggled = true,
        fpsToggled = true,
        dailyTimeToggled = true,
        sessionTimeToggled = true,
        clockToggled = true,
        expX = 35,
        expY = 0,
        fpsX = 0,
        fpsY = 0,
        dailyTimePlayedX = 0,
        dailyTimePlayedY = 0,
        sessionTimePlayedX = 0,
        sessionTimePlayedY = 0,
        clockX = 0,
        clockY = 0,
        lang = "EN",
        exp25_r = 0,
        exp25_g = 0.1,
        exp25_b = 1,
        exp50_r = 0,
        exp50_g = 0.25,
        exp50_b = 1,
        exp75_r = 0,
        exp75_g = 0.5,
        exp75_b = 1,
        expS75_r = 0,
        expS75_g = 1,
        expS75_b = 1,
        expBorder_r = 1,
        expBorder_g = 1,
        expBorder_b = 1,
        expBack_r = 0,
        expBack_g = 0,
        expBack_b = 0
    }

    sv = ZO_SavedVars:NewAccountWide('MoreUIsv', 1, nil, svTable)

    options_ToggleExp(options_IsExpToggled())
    options_ToggleFPS(options_IsFPSToggled())
    options_ToggleDailyTime(options_IsDailyTimeToggled())
    options_ToggleSessionTime(options_IsSessionTimeToggled())
    options_ToggleClock(options_IsClockToggled())

    options_SetExpPosition('x', options_GetExpPosition('x'))
    options_SetExpPosition('y', options_GetExpPosition('y'))
    options_SetFPSPosition('x', options_GetFPSPosition('x'))
    options_SetFPSPosition('y', options_GetFPSPosition('y'))
    options_SetDailyTimePosition('x', options_GetDailyTimePosition('x'))
    options_SetDailyTimePosition('y', options_GetDailyTimePosition('y'))
    options_SetSessionTimePosition('x', options_GetSessionTimePosition('x'))
    options_SetSessionTimePosition('y', options_GetSessionTimePosition('y'))
    options_SetClockPosition('x', options_GetClockPosition('x'))
    options_SetClockPosition('y', options_GetClockPosition('y'))

    options_SetLang(options_GetLang())

    local strLangName
    local strExpName
    local strFPSName
    local strDailyName
    local strSessionName
    local strClockName
    local strExpFill
    local strExpBorder
    local strExpBack

    if options_GetLang() == "FR" then
        strLangName = "Langue (rechargement de l'UI nécessaire)"
        strExpName = "Afficher la barre d'exp"
        strFPSName = "Afficher les FPS"
        strDailyName = "Afficher le temps de jeux total de la journée"
        strSessionName = "Afficher le temps de jeux de la session en cours"
        strClockName = "Afficher la date et l'heure"
        strExpFill = "Couleur du remplissage"
        strExpBorder = "Couleur des bordures"
        strExpBack = "Couleur de fond"
    else
        strLangName = "Language (reload UI needed)"
        strExpName = "Show exp bar"
        strFPSName = "Show FPS"
        strDailyName = "Show daily played time"
        strSessionName = "Show current session played time"
        strClockName = "Show date & time"
        strExpFill = "Fill color"
        strExpBorder = "Border color"
        strExpBack = "Back color"
    end

    local LAM = LibAddonMenu2
    local panel =
    {
        name = "MoreUIOptions",
        data =
        {
            type = "panel",
            name = "|ccc66ffMoreUI",
            author = "|c660099@|ccc66ffBiiinkss78"
        },

        optionsData =
        {
            [1] =
            {
                type = "dropdown",
                name = strLangName,
                choices = { "FR", "EN" },
                getFunc = function() return options_GetLang() end,
                setFunc = function(value) options_SetLang(value) end
            },

            [2] =
            {
                type = "checkbox",
                name = "|ccae00d" .. strExpName,
                getFunc = function() return options_IsExpToggled() end,
                setFunc = function(value) options_ToggleExp(value) end
            },

            [3] =
            {
                type = "editbox",
                name = "|ccae00dPosition X",
                isMultiline = false,
                width = "half",
                getFunc = function() return options_GetExpPosition('x') end,
                setFunc = function(value) options_SetExpPosition('x', tonumber(value)) end
            },

            [4] =
            {
                type = "editbox",
                name = "|ccae00dPosition Y",
                isMultiline = false,
                width = "half",
                getFunc = function() return options_GetExpPosition('y') end,
                setFunc = function(value) options_SetExpPosition('y', tonumber(value)) end
            },

            [5] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " < 25% " .. "|cff1100R",
                isMultiline = false,
                getFunc = function() return sv.exp25_r end,
                setFunc = function(value) options_SetExpFillColor(25, value, sv.exp25_g, sv.exp25_b) end
            },

            [6] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " < 25% " .. "|c4dff00G",
                isMultiline = false,
                getFunc = function() return sv.exp25_g end,
                setFunc = function(value) options_SetExpFillColor(25, sv.exp25_r, value, sv.exp25_b) end
            },

            [7] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " < 25% " .. "|c16537eB",
                isMultiline = false,
                getFunc = function() return sv.exp25_b end,
                setFunc = function(value) options_SetExpFillColor(25, sv.exp25_r, sv.exp25_g, value) end
            },

            [8] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " < 50% " .. "|cff1100R",
                isMultiline = false,
                getFunc = function() return sv.exp50_r end,
                setFunc = function(value) options_SetExpFillColor(50, value, sv.exp50_g, sv.exp50_b) end
            },

            [9] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " < 50% " .. "|c4dff00G",
                isMultiline = false,
                getFunc = function() return sv.exp50_g end,
                setFunc = function(value) options_SetExpFillColor(50, sv.exp50_r, value, sv.exp50_b) end
            },

            [10] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " < 50% " .. "|c16537eB",
                isMultiline = false,
                getFunc = function() return sv.exp50_b end,
                setFunc = function(value) options_SetExpFillColor(50, sv.exp50_r, sv.exp50_g, value) end
            },

            [11] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " < 75% " .. "|cff1100R",
                isMultiline = false,
                getFunc = function() return sv.exp75_r end,
                setFunc = function(value) options_SetExpFillColor(75, value, sv.exp75_g, sv.exp75_b) end
            },

            [12] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " < 75% " .. "|c4dff00G",
                isMultiline = false,
                getFunc = function() return sv.exp75_g end,
                setFunc = function(value) options_SetExpFillColor(75, sv.exp75_r, value, sv.exp75_b) end
            },

            [13] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " < 75% " .. "|c16537eB",
                isMultiline = false,
                getFunc = function() return sv.exp75_b end,
                setFunc = function(value) options_SetExpFillColor(75, sv.exp75_r, sv.exp75_g, value) end
            },

            [14] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " > 75% " .. "|cff1100R",
                isMultiline = false,
                getFunc = function() return sv.expS75_r end,
                setFunc = function(value) options_SetExpFillColor(76, value, sv.expS75_g, sv.expS75_b) end
            },

            [15] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " > 75% " .. "|c4dff00G",
                isMultiline = false,
                getFunc = function() return sv.expS75_g end,
                setFunc = function(value) options_SetExpFillColor(76, sv.expS75_r, value, sv.expS75_b) end
            },

            [16] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpFill .. " > 75% " .. "|c16537eB",
                isMultiline = false,
                getFunc = function() return sv.expS75_b end,
                setFunc = function(value) options_SetExpFillColor(76, sv.expS75_r, sv.expS75_g, value) end
            },

            [17] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpBorder .. " |cff1100R",
                isMultiline = false,
                getFunc = function() return sv.expBorder_r end,
                setFunc = function(value) options_SetExpBorderColor(value, sv.expBorder_g, sv.expBorder_b) end
            },

            [18] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpBorder .. " |c4dff00G",
                isMultiline = false,
                getFunc = function() return sv.expBorder_g end,
                setFunc = function(value) options_SetExpBorderColor(sv.expBorder_r, value, sv.expBorder_b) end
            },

            [19] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpBorder .. " |c16537eB",
                isMultiline = false,
                getFunc = function() return sv.expBorder_b end,
                setFunc = function(value) options_SetExpBorderColor(sv.expBorder_r, sv.expBorder_g, value) end
            },

            [20] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpBack .. " |cff1100R",
                isMultiline = false,
                getFunc = function() return sv.expBack_r end,
                setFunc = function(value) options_SetExpBackColor(value, sv.expBack_g, sv.expBack_b) end
            },

            [21] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpBack .. " |c4dff00G",
                isMultiline = false,
                getFunc = function() return sv.expBack_g end,
                setFunc = function(value) options_SetExpBackColor(sv.expBack_r, value, sv.expBack_b) end
            },

            [22] =
            {
                type = "editbox",
                name = "|ccae00d" .. strExpBack .. " |c16537eB",
                isMultiline = false,
                getFunc = function() return sv.expBack_b end,
                setFunc = function(value) options_SetExpBackColor(sv.expBack_r, sv.expBack_g, value) end
            },

            [23] =
            {
                type = "checkbox",
                name = "|cf59342" .. strFPSName,
                getFunc = function() return options_IsFPSToggled() end,
                setFunc = function(value) options_ToggleFPS(value) end
            },

            [24] =
            {
                type = "editbox",
                name = "|cf59342Position X",
                isMultiline = false,
                width = "half",
                getFunc = function() return options_GetFPSPosition('x') end,
                setFunc = function(value) options_SetFPSPosition('x', tonumber(value)) end
            },

            [25] =
            {
                type = "editbox",
                name = "|cf59342Position Y",
                isMultiline = false,
                width = "half",
                getFunc = function() return options_GetFPSPosition('y') end,
                setFunc = function(value) options_SetFPSPosition('y', tonumber(value)) end
            },

            [26] =
            {
                type = "checkbox",
                name = "|c7fff00" .. strDailyName,
                getFunc = function() return options_IsDailyTimeToggled() end,
                setFunc = function(value) options_ToggleDailyTime(value) end
            },

            [27] =
            {
                type = "editbox",
                name = "|c7fff00Position X",
                isMultiline = false,
                width = "half",
                getFunc = function() return options_GetDailyTimePosition('x') end,
                setFunc = function(value) options_SetDailyTimePosition('x', tonumber(value)) end
            },

            [28] =
            {
                type = "editbox",
                name = "|c7fff00Position Y",
                isMultiline = false,
                width = "half",
                getFunc = function() return options_GetDailyTimePosition('y') end,
                setFunc = function(value) options_SetDailyTimePosition('y', tonumber(value)) end
            },

            [29] =
            {
                type = "checkbox",
                name = "|cbd33a4" .. strSessionName,
                getFunc = function() return options_IsSessionTimeToggled() end,
                setFunc = function(value) options_ToggleSessionTime(value) end
            },

            [30] =
            {
                type = "editbox",
                name = "|cbd33a4Position X",
                isMultiline = false,
                width = "half",
                getFunc = function() return options_GetSessionTimePosition('x') end,
                setFunc = function(value) options_SetSessionTimePosition('x', tonumber(value)) end
            },

            [31] =
            {
                type = "editbox",
                name = "|cbd33a4Position Y",
                isMultiline = false,
                width = "half",
                getFunc = function() return options_GetSessionTimePosition('y') end,
                setFunc = function(value) options_SetSessionTimePosition('y', tonumber(value)) end
            },

            [32] =
            {
                type = "checkbox",
                name = "|c0054a1" .. strClockName,
                getFunc = function() return options_IsClockToggled() end,
                setFunc = function(value) options_ToggleClock(value) end
            },

            [33] =
            {
                type = "editbox",
                name = "|c0054a1Position X",
                isMultiline = false,
                width = "half",
                getFunc = function() return options_GetClockPosition('x') end,
                setFunc = function(value) options_SetClockPosition('x', tonumber(value)) end
            },

            [34] =
            {
                type = "editbox",
                name = "|c0054a1Position Y",
                isMultiline = false,
                width = "half",
                getFunc = function() return options_GetClockPosition('y') end,
                setFunc = function(value) options_SetClockPosition('y', tonumber(value)) end
            }
        }
    }

    local LAMPanel = LAM:RegisterAddonPanel(panel.name, panel.data)
    LAM:RegisterOptionControls(panel.name, panel.optionsData)

    local path = "EsoUI/Common/Fonts/univers67.otf"
    local size = 20
    local outline = "soft-shadow-thin"

    ClockLabel:SetFont(path .. "|" .. size .. "|" ..  outline)
    FramerateLabel:SetFont(path .. "|" .. size .. "|" ..  outline)
    XPPercentLabel:SetFont(path .. "|" .. size * 1.1 .. "|" ..  outline)
    XPLevelLabel:SetFont(path .. "|" .. size * 1.25 .. "|" ..  outline)
    DailyTimePlayedLabel:SetFont(path .. "|" .. size .. "|" ..  outline)
    SessionTimePlayedLabel:SetFont(path .. "|" .. size .. "|" ..  outline)

    local championXP = GetPlayerChampionXP()
    local currentExp = 0
    local maxExp = 0
    if GetUnitLevel('player') == 50 then
        XPLevelLabel:SetText("Champion " .. GetPlayerChampionPointsEarned())

        currentExp = championXP
        maxExp = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
    else
        XPLevelLabel:SetText("Level " .. GetUnitLevel('player'))
        currentExp = GetUnitXP("player")
        maxExp = GetUnitXPMax("player")
    end

    XPBarFrontTexture:SetDimensions(((currentExp / maxExp) * 400), 6)
    XPBarBorderTexture:SetColor(sv.expBorder_r, sv.expBorder_g, sv.expBorder_b, 255)
    XPBarBackTexture:SetColor(sv.expBack_r, sv.expBack_g, sv.expBack_b, 255)

    local xpPercent = ((currentExp / maxExp) * 100)

    if xpPercent < 25 then
        XPPercentLabel:SetText(roundFloat(xpPercent, -2) .. "%")
        XPBarFrontTexture:SetColor(sv.exp25_r, sv.exp25_g, sv.exp25_b, 255)
    elseif xpPercent < 50 then
        XPPercentLabel:SetText(roundFloat(xpPercent, -2) .. "%")
        XPBarFrontTexture:SetColor(sv.exp50_r, sv.exp50_g, sv.exp50_b, 255)
    elseif xpPercent < 75 then
        XPPercentLabel:SetText(roundFloat(xpPercent, -2) .. "%")
        XPBarFrontTexture:SetColor(sv.exp75_r, sv.exp75_g, sv.exp75_b, 255)
    else
        XPPercentLabel:SetText(roundFloat(xpPercent, -2) .. "%")
        XPBarFrontTexture:SetColor(sv.expS75_r, sv.expS75_g, sv.expS75_b, 255)
    end

    EVENT_MANAGER:RegisterForEvent(MoreUI.name, EVENT_EXPERIENCE_UPDATE, MoreUI.OnXPUpdated)
    update()
end

function MoreUI.OnXPUpdated(eventCode, unitTag, currentExp, maxExp, reason)
    local championXP = GetPlayerChampionXP()
    if GetUnitLevel('player') == 50 then
        XPLevelLabel:SetText("Champion " .. GetPlayerChampionPointsEarned())

        currentExp = championXP
        maxExp = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
    else
        XPLevelLabel:SetText("Level " .. GetUnitLevel('player'))
    end

    XPBarFrontTexture:SetDimensions(((currentExp / maxExp) * 400), 6)

    local xpPercent = ((currentExp / maxExp) * 100)

    if xpPercent < 25 then
        XPPercentLabel:SetText(roundFloat(xpPercent, -2) .. "%")
        XPBarFrontTexture:SetColor(sv.exp25_r, sv.exp25_g, sv.exp25_b, 255)
    elseif xpPercent < 50 then
        XPPercentLabel:SetText(roundFloat(xpPercent, -2) .. "%")
        XPBarFrontTexture:SetColor(sv.exp50_r, sv.exp50_g, sv.exp50_b, 255)
    elseif xpPercent < 75 then
        XPPercentLabel:SetText(roundFloat(xpPercent, -2) .. "%")
        XPBarFrontTexture:SetColor(sv.exp75_r, sv.exp75_g, sv.exp75_b, 255)
    else
        XPPercentLabel:SetText(roundFloat(xpPercent, -2) .. "%")
        XPBarFrontTexture:SetColor(sv.expS75_r, sv.expS75_g, sv.expS75_b, 255)
    end
end

EVENT_MANAGER:RegisterForEvent(MoreUI.name, EVENT_ADD_ON_LOADED, MoreUI.OnLoaded)