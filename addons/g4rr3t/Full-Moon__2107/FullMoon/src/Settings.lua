-- -----------------------------------------------------------------------------
-- Full Moon
-- Author:  g4rr3t
-- Created: Aug 23, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------

local LAM = LibStub("LibAddonMenu-2.0")

local panelData = {
    type        = "panel",
    name        = "Full Moon",
    displayName = "Full Moon",
    author      = "g4rr3t",
    version     = MOON.version,
    registerForRefresh  = true,
}

-- -----------------------------------------------------------------------------
-- Helper functions to set/get settings
-- -----------------------------------------------------------------------------

-- Locked State
local function ToggleLocked(control)
    MOON.preferences.unlocked = not MOON.preferences.unlocked
    if (MOON.enabled) then
        MOON.Container:SetMovable(MOON.preferences.unlocked)
        if MOON.preferences.unlocked then
            control:SetText("Lock")
        else
            control:SetText("Unlock")
        end
    else
        control:SetText("Not Equipped!")
    end
end

-- Force Showing
local function ForceShow(control)
    MOON.ForceShow = not MOON.ForceShow
    if (MOON.enabled) then
        if MOON.ForceShow then
            control:SetText("Hide")
            MOON.UpdateStacks(5)
            MOON:ShowIcon(true)
        else
            control:SetText("Show")
            MOON.UpdateStacks(0)
            MOON:ShowIcon(true)
        end
    else
        control:SetText("Not Equipped!")
    end
end

-- Sizing
local function SetSize(value)
    MOON.preferences.size = value
    if MOON.enabled then
        MOON.Container:SetDimensions(value, value)
        MOON.Texture:SetDimensions(value, value)
        MOON.SetFontSize(value)
    end
end

local function GetSize()
    return MOON.preferences.size
end

-- Show In Combat
local function SetHideOutOfCombat(value)
    MOON.preferences.hideOOC = value

    if value then
        MOON.RegisterCombatEvent()
        MOON.isInCombat = IsUnitInCombat("player")
    else
        MOON.UnregisterCombatEvent()
    end

    MOON:SetCombatStateDisplay()

end

local function GetHideOutOfCombat()
    return MOON.preferences.hideOOC
end


-- Sounds

local function GetOnFrenziedEnabled()
    return MOON.preferences.soundEnabled
end

local function SetOnFrenziedEnabled(enabled)
    MOON.preferences.soundEnabled = enabled
end

local function PlayTestSound(setKey, condition)
    local sound = MOON.preferences.sound
    MOON:Trace(2, "Testing sound <<1>>", sound)
    MOON.PlaySound(sound)
end

local optionsTable = {
    {
        type = "header",
        name = "Positioning",
        width = "full",
    },
    {
        type = "button",
        name = function() if MOON.preferences.unlocked then return "Lock" else return "Unlock" end end,
        tooltip = "Toggle lock/unlock state of counter display for repositioning.",
        func = function(control) ToggleLocked(control) end,
        width = "half",
    },
    {
        type = "button",
        name = function() if MOON.ForceShow then return "Hide" else return "Show" end end,
        tooltip = "Force show for position or previewing display settings.",
        func = function(control) ForceShow(control) end,
        width = "half",
    },
    {
        type = "header",
        name = "Display",
        width = "full",
    },
    {
        type = "slider",
        name = "Size",
        tooltip = "Display size of counter.",
        min = 32,
        max = 512,
        step = 5,
        getFunc = function() return GetSize() end,
        setFunc = function(value) SetSize(value) end,
        width = "full",
        default = 40,
    },
    {
        type = "checkbox",
        name = "Hide Out of Combat",
        tooltip = "Only show display while in combat, otherwise hide display",
        getFunc = function() return GetHideOutOfCombat() end,
        setFunc = function(value) SetHideOutOfCombat(value) end,
        width = "full",
    },
    {
        type = "header",
        name = "Sound",
        width = "full",
    },
    {
        type = "checkbox",
        name = "Play Sound When Frenzied",
        tooltip = "Set to ON to play a sound when reaching five Blood Scent stacks and become Frenzied.",
        getFunc = function() return GetOnFrenziedEnabled() end,
        setFunc = function(value) SetOnFrenziedEnabled(value) end,
        width = "full",
    },
    {
        type = "dropdown",
        name = "Sound When Frenzied",
        choices = MOON.Sounds.names,
        choicesValues = MOON.Sounds.options,
        getFunc = function() return MOON.preferences.sound end,
        setFunc = function(value) MOON.preferences.sound = value end,
        tooltip = "Sound volume based on game interface volume setting.",
        sort = "name-up",
        width = "full",
        scrollable = true,
        disabled = function() return not GetOnFrenziedEnabled() end,
    },
    {
        type = "button",
        name = "Test Sound",
        func = function() PlayTestSound() end,
        width = "full",
        disabled = function() return not GetOnFrenziedEnabled() end,
    },
}

-- -----------------------------------------------------------------------------
-- Initialize Settings
-- -----------------------------------------------------------------------------

function MOON:InitSettings()
    LAM:RegisterAddonPanel(MOON.name, panelData)
    LAM:RegisterOptionControls(MOON.name, optionsTable)

    MOON:Trace(2, "Finished InitSettings()")
end

