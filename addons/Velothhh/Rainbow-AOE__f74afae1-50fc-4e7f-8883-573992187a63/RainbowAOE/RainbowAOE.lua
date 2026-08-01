local ADDON_NAME = "RainbowAOE"
local PULSE_UPDATE_NAME = ADDON_NAME .. "_SmoothPulseUpdate"

RainbowAOE = {}
local AOE = RainbowAOE

AOE.pulseModes = {
    slow = {
        label = "Slow",
        interval = 50,
        hueStep = 2,
    },

    medium = {
        label = "Medium",
        interval = 50,
        hueStep = 4,
    },

    fast = {
        label = "Fast",
        interval = 50,
        hueStep = 9,
    },
}

AOE.defaults = {
    enabled = true,

    -- Can be: "slow", "medium", "fast", or "off"
    pulseMode = "slow",

    -- Can be: "enemy", "friendly", or "both"
    pulseTarget = "enemy",

    -- Current position on the rainbow color wheel.
    -- 0 = red, 60 = yellow, 120 = green, 180 = cyan, 240 = blue, 300 = magenta.
    hue = 0,

    -- 100 = most saturated.
    -- Lower values make the rainbow more washed out.
    vibrancy = 100,

    -- Visual brightness is handled by changing the generated RGB color.
    -- This avoids the protected/private ESO base-game brightness sliders on Xbox.
    enemyVisualBrightness = 100,
    friendlyVisualBrightness = 100,

    -- Static fallback colors for whichever side is not being pulsed.
    enemyStaticHue = 0,       -- red
    friendlyStaticHue = 120,  -- green
}

local warnedMissingCVarApi = false

local function Print(message)
    d("|cFF00FFRainbow AOE:|r " .. tostring(message))
end

local function Trim(text)
    return string.match(text or "", "^%s*(.-)%s*$")
end

local function Clamp(value, minValue, maxValue)
    value = tonumber(value) or minValue

    if value < minValue then
        return minValue
    elseif value > maxValue then
        return maxValue
    end

    return value
end

local function ClampByte(value)
    value = math.floor(value + 0.5)

    if value < 0 then
        value = 0
    elseif value > 255 then
        value = 255
    end

    return value
end

local function ByteToHex(value)
    return string.format("%02x", ClampByte(value))
end

local function GetVibrancyValue()
    local percent = Clamp(AOE.saved.vibrancy or 100, 1, 100)
    return percent / 100
end

local function GetEnemyVisualBrightnessValue()
    local percent = Clamp(AOE.saved.enemyVisualBrightness or 100, 1, 100)
    return percent / 100
end

local function GetFriendlyVisualBrightnessValue()
    local percent = Clamp(AOE.saved.friendlyVisualBrightness or 100, 1, 100)
    return percent / 100
end

local function WarnMissingCVarApi()
    if warnedMissingCVarApi then return end

    warnedMissingCVarApi = true
    Print("SetCVar is not available. Combat cue colors cannot be changed on this platform.")
end

local function SafeSetCVar(cvarName, value)
    if type(SetCVar) ~= "function" then
        WarnMissingCVarApi()
        return false
    end

    SetCVar(cvarName, tostring(value))
    return true
end

local function HSVToRGB(h, s, v)
    h = h % 360

    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c

    local r, g, b

    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end

    return
        (r + m) * 255,
        (g + m) * 255,
        (b + m) * 255
end

local function HueToESOColor(hue, visualBrightness)
    local vibrancy = GetVibrancyValue()
    visualBrightness = Clamp(visualBrightness or 1, 0.01, 1)

    local r, g, b = HSVToRGB(hue, vibrancy, visualBrightness)

    -- ESO combat cue color format: AARRGGBB
    return "ff" .. ByteToHex(r) .. ByteToHex(g) .. ByteToHex(b)
end

local function GetEnemyPulseColor()
    return HueToESOColor(
        AOE.saved.hue or 0,
        GetEnemyVisualBrightnessValue()
    )
end

local function GetFriendlyPulseColor()
    return HueToESOColor(
        AOE.saved.hue or 0,
        GetFriendlyVisualBrightnessValue()
    )
end

local function GetEnemyStaticColor()
    return HueToESOColor(
        AOE.saved.enemyStaticHue or AOE.defaults.enemyStaticHue,
        GetEnemyVisualBrightnessValue()
    )
end

local function GetFriendlyStaticColor()
    return HueToESOColor(
        AOE.saved.friendlyStaticHue or AOE.defaults.friendlyStaticHue,
        GetFriendlyVisualBrightnessValue()
    )
end

local function ApplyBaseCombatCueSettings()
    -- Xbox-safe: only use CVars.
    -- Do NOT call SetSetting here. It is private/protected on Xbox and throws UI errors.
    SafeSetCVar("MonsterTellsEnabled", "1")
    SafeSetCVar("MonsterTellsColorSwapEnabled", "1")
end

local function ApplyPulseColorFromHue()
    local target = AOE.saved.pulseTarget or AOE.defaults.pulseTarget

    if target == "friendly" then
        SafeSetCVar(
            "MonsterTellsEnemyColor",
            GetEnemyStaticColor()
        )

        SafeSetCVar(
            "MonsterTellsFriendlyColor",
            GetFriendlyPulseColor()
        )

    elseif target == "both" then
        SafeSetCVar(
            "MonsterTellsEnemyColor",
            GetEnemyPulseColor()
        )

        SafeSetCVar(
            "MonsterTellsFriendlyColor",
            GetFriendlyPulseColor()
        )

    else
        SafeSetCVar(
            "MonsterTellsEnemyColor",
            GetEnemyPulseColor()
        )

        SafeSetCVar(
            "MonsterTellsFriendlyColor",
            GetFriendlyStaticColor()
        )
    end
end

local function StopPulse()
    EVENT_MANAGER:UnregisterForUpdate(PULSE_UPDATE_NAME)
end

local function SmoothPulseUpdate()
    if not AOE.saved.enabled then return end

    local mode = AOE.saved.pulseMode

    if mode == "off" then return end

    local pulseData = AOE.pulseModes[mode]

    if not pulseData then return end

    AOE.saved.hue = (AOE.saved.hue or 0) + pulseData.hueStep

    if AOE.saved.hue >= 360 then
        AOE.saved.hue = AOE.saved.hue - 360
    end

    ApplyPulseColorFromHue()
end

local function StartPulse(mode)
    StopPulse()

    -- Migration from the old name.
    if mode == "slowish" then
        mode = "medium"
    end

    local pulseData = AOE.pulseModes[mode]

    if not pulseData then
        Print("invalid pulse mode")
        return
    end

    AOE.saved.enabled = true
    AOE.saved.pulseMode = mode

    ApplyBaseCombatCueSettings()
    ApplyPulseColorFromHue()

    EVENT_MANAGER:RegisterForUpdate(
        PULSE_UPDATE_NAME,
        pulseData.interval,
        SmoothPulseUpdate
    )

    Print(pulseData.label .. " rainbow pulse enabled")
end

local function SetPulseMode(mode)
    -- Migration from the old name.
    if mode == "slowish" then
        mode = "medium"
    end

    if mode == "off" then
        StopPulse()
        AOE.saved.pulseMode = "off"
        ApplyBaseCombatCueSettings()
        ApplyPulseColorFromHue()
        Print("pulse disabled")
        return
    end

    StartPulse(mode)
end

local function SetPulseTarget(target)
    if target ~= "enemy" and target ~= "friendly" and target ~= "both" then
        Print("invalid pulse target")
        return
    end

    AOE.saved.pulseTarget = target
    ApplyBaseCombatCueSettings()
    ApplyPulseColorFromHue()

    if AOE.saved.enabled and AOE.saved.pulseMode ~= "off" then
        StartPulse(AOE.saved.pulseMode)
    end

    if target == "enemy" then
        Print("pulse target set to enemy")
    elseif target == "friendly" then
        Print("pulse target set to friendly")
    else
        Print("pulse target set to both")
    end
end

local function ToggleAddon()
    AOE.saved.enabled = not AOE.saved.enabled

    if AOE.saved.enabled then
        ApplyBaseCombatCueSettings()
        ApplyPulseColorFromHue()

        if AOE.saved.pulseMode ~= "off" then
            StartPulse(AOE.saved.pulseMode)
        end

        Print("enabled")
    else
        StopPulse()
        Print("disabled. Your ESO combat cue settings were not reset.")
    end
end

local function NextColor()
    StopPulse()
    AOE.saved.pulseMode = "off"

    AOE.saved.hue = (AOE.saved.hue or 0) + 30

    if AOE.saved.hue >= 360 then
        AOE.saved.hue = AOE.saved.hue - 360
    end

    ApplyPulseColorFromHue()
    Print("manual color step")
end

local function PreviousColor()
    StopPulse()
    AOE.saved.pulseMode = "off"

    AOE.saved.hue = (AOE.saved.hue or 0) - 30

    if AOE.saved.hue < 0 then
        AOE.saved.hue = AOE.saved.hue + 360
    end

    ApplyPulseColorFromHue()
    Print("manual color step")
end

local function ApplyAllSettings()
    -- Migration from the old saved name.
    if AOE.saved.pulseMode == "slowish" then
        AOE.saved.pulseMode = "medium"
    end

    if AOE.saved.pulseTarget ~= "enemy" and AOE.saved.pulseTarget ~= "friendly" and AOE.saved.pulseTarget ~= "both" then
        AOE.saved.pulseTarget = "enemy"
    end

    ApplyBaseCombatCueSettings()
    ApplyPulseColorFromHue()

    if AOE.saved.enabled and AOE.saved.pulseMode ~= "off" then
        StartPulse(AOE.saved.pulseMode)
    end
end

local function ShowStatus()
    Print("status")
    d("Enabled: " .. tostring(AOE.saved.enabled))
    d("Pulse mode: " .. tostring(AOE.saved.pulseMode))
    d("Pulse target: " .. tostring(AOE.saved.pulseTarget))
    d("Hue: " .. tostring(AOE.saved.hue))
    d("Vibrancy: " .. tostring(AOE.saved.vibrancy or 100) .. "%")
    d("Enemy visual brightness: " .. tostring(AOE.saved.enemyVisualBrightness or 100) .. "%")
    d("Friendly visual brightness: " .. tostring(AOE.saved.friendlyVisualBrightness or 100) .. "%")
end

local function ShowHelp()
    Print("commands:")
    d("/rainbowaoe slow")
    d("/rainbowaoe medium")
    d("/rainbowaoe fast")
    d("/rainbowaoe off")
    d("/rainbowaoe target enemy")
    d("/rainbowaoe target friendly")
    d("/rainbowaoe target both")
    d("/rainbowaoe next")
    d("/rainbowaoe prev")
    d("/rainbowaoe apply")
    d("/rainbowaoe status")
    d("/rainbowaoe toggle")
    d("/rainbowaoe vibrant")
    d("/rainbowaoe soft")
end

local function SlashCommand(text)
    text = string.lower(Trim(text))

    if text == "slow" or text == "pulse slow" then
        SetPulseMode("slow")

    elseif text == "medium" or text == "pulse medium" or text == "slowish" or text == "pulse slowish" then
        SetPulseMode("medium")

    elseif text == "fast" or text == "pulse fast" then
        SetPulseMode("fast")

    elseif text == "off" or text == "pulse off" then
        SetPulseMode("off")

    elseif text == "target enemy" or text == "enemy" then
        SetPulseTarget("enemy")

    elseif text == "target friendly" or text == "friendly" then
        SetPulseTarget("friendly")

    elseif text == "target both" or text == "both" then
        SetPulseTarget("both")

    elseif text == "next" then
        NextColor()

    elseif text == "prev" or text == "previous" then
        PreviousColor()

    elseif text == "apply" then
        ApplyAllSettings()
        Print("settings applied")

    elseif text == "status" then
        ShowStatus()

    elseif text == "toggle" then
        ToggleAddon()

    elseif text == "vibrant" then
        AOE.saved.vibrancy = 100
        AOE.saved.enemyVisualBrightness = 100
        AOE.saved.friendlyVisualBrightness = 100
        ApplyAllSettings()
        Print("vibrancy and visual brightness set to 100%")

    elseif text == "soft" then
        AOE.saved.vibrancy = 60
        AOE.saved.enemyVisualBrightness = 80
        AOE.saved.friendlyVisualBrightness = 80
        ApplyAllSettings()
        Print("vibrancy and visual brightness set to softer colors")

    else
        ShowHelp()
    end
end

local function RegisterSettingsMenu()
    local LAM = LibAddonMenu2

    if not LAM then
        Print("LibAddonMenu-2.0 not found. Settings UI will not load, but slash commands still work.")
        return
    end

    local panelData = {
        type = "panel",
        name = "Rainbow AOE",
        displayName = "Rainbow AOE",
        author = "Alpha AC",
        version = "0.1.4",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(ADDON_NAME .. "_Options", panelData)

    local optionsData = {
        {
            type = "description",
            text = "Cycles combat cue colors through a smooth rainbow pulse. Set ESO's base Gameplay combat cue brightness sliders to max, then use these visual brightness sliders to control Rainbow AOE intensity.",
        },

        {
            type = "header",
            name = "Main Settings",
        },

        {
            type = "checkbox",
            name = "Enable Rainbow AOE",
            tooltip = "Turns Rainbow AOE on or off.",
            getFunc = function()
                return AOE.saved.enabled
            end,
            setFunc = function(value)
                AOE.saved.enabled = value

                if value then
                    ApplyAllSettings()
                else
                    StopPulse()
                end
            end,
            default = AOE.defaults.enabled,
        },

        {
            type = "dropdown",
            name = "Pulse Target",
            tooltip = "Choose which combat cues should use the rainbow pulse.",
            choices = {
                "Friendly",
                "Enemy",
                "Both",
            },
            choicesValues = {
                "friendly",
                "enemy",
                "both",
            },
            getFunc = function()
                return AOE.saved.pulseTarget or AOE.defaults.pulseTarget
            end,
            setFunc = function(value)
                SetPulseTarget(value)
            end,
            default = AOE.defaults.pulseTarget,
        },

        {
            type = "dropdown",
            name = "Pulse Speed",
            tooltip = "Choose how fast the selected AOE colors cycle through the rainbow.",
            choices = {
                "Off",
                "Slow",
                "Medium",
                "Fast",
            },
            choicesValues = {
                "off",
                "slow",
                "medium",
                "fast",
            },
            getFunc = function()
                if AOE.saved.pulseMode == "slowish" then
                    AOE.saved.pulseMode = "medium"
                end

                return AOE.saved.pulseMode or AOE.defaults.pulseMode
            end,
            setFunc = function(value)
                SetPulseMode(value)
            end,
            default = AOE.defaults.pulseMode,
        },

        {
            type = "slider",
            name = "Color Vibrancy",
            tooltip = "Controls how saturated the rainbow colors are. 100% is the most vivid.",
            min = 1,
            max = 100,
            step = 1,
            getFunc = function()
                return AOE.saved.vibrancy or AOE.defaults.vibrancy
            end,
            setFunc = function(value)
                AOE.saved.vibrancy = value
                ApplyPulseColorFromHue()
            end,
            default = AOE.defaults.vibrancy,
        },

        {
            type = "slider",
            name = "Enemy Visual Brightness",
            tooltip = "Controls the visual brightness of Rainbow AOE enemy colors. This does not move ESO's protected Gameplay brightness slider.",
            min = 1,
            max = 100,
            step = 1,
            getFunc = function()
                return AOE.saved.enemyVisualBrightness or AOE.defaults.enemyVisualBrightness
            end,
            setFunc = function(value)
                AOE.saved.enemyVisualBrightness = value
                ApplyPulseColorFromHue()
            end,
            default = AOE.defaults.enemyVisualBrightness,
        },

        {
            type = "slider",
            name = "Friendly Visual Brightness",
            tooltip = "Controls the visual brightness of Rainbow AOE friendly colors. This does not move ESO's protected Gameplay brightness slider.",
            min = 1,
            max = 100,
            step = 1,
            getFunc = function()
                return AOE.saved.friendlyVisualBrightness or AOE.defaults.friendlyVisualBrightness
            end,
            setFunc = function(value)
                AOE.saved.friendlyVisualBrightness = value
                ApplyPulseColorFromHue()
            end,
            default = AOE.defaults.friendlyVisualBrightness,
        },

        {
            type = "button",
            name = "Apply Settings",
            tooltip = "Re-applies the current Rainbow AOE settings.",
            func = function()
                ApplyAllSettings()
                Print("settings applied")
            end,
        },

        {
            type = "button",
            name = "Max Vibrancy",
            tooltip = "Sets vibrancy and visual brightness to maximum.",
            func = function()
                AOE.saved.vibrancy = 100
                AOE.saved.enemyVisualBrightness = 100
                AOE.saved.friendlyVisualBrightness = 100
                ApplyAllSettings()
                Print("max vibrancy applied")
            end,
        },

        {
            type = "button",
            name = "Stop Pulse",
            tooltip = "Stops the rainbow pulse and keeps the current color.",
            func = function()
                SetPulseMode("off")
            end,
        },
    }

    LAM:RegisterOptionControls(ADDON_NAME .. "_Options", optionsData)
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    AOE.saved = ZO_SavedVars:NewAccountWide(
        "RainbowAOESaved",
        1,
        nil,
        AOE.defaults
    )

    -- Migration from old saved value.
    if AOE.saved.pulseMode == "slowish" then
        AOE.saved.pulseMode = "medium"
    end

    if AOE.saved.pulseTarget ~= "enemy" and AOE.saved.pulseTarget ~= "friendly" and AOE.saved.pulseTarget ~= "both" then
        AOE.saved.pulseTarget = "enemy"
    end

    -- Migration from old brightness slider names.
    if AOE.saved.enemyVisualBrightness == nil then
        AOE.saved.enemyVisualBrightness = AOE.saved.enemyBrightnessPercent or 100
    end

    if AOE.saved.friendlyVisualBrightness == nil then
        AOE.saved.friendlyVisualBrightness = AOE.saved.friendlyBrightnessPercent or 100
    end

    SLASH_COMMANDS["/rainbowaoe"] = SlashCommand
    SLASH_COMMANDS["/raoe"] = SlashCommand

    RegisterSettingsMenu()

    ApplyBaseCombatCueSettings()
    ApplyPulseColorFromHue()

    if AOE.saved.enabled and AOE.saved.pulseMode ~= "off" then
        StartPulse(AOE.saved.pulseMode)
    else
        Print("loaded")
    end
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)