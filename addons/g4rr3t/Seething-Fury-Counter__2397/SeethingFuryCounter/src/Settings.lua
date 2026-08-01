-- -----------------------------------------------------------------------------
-- Seething Fury Counter
-- Author:  g4rr3t
-- Created: May 22, 2019
--
-- Settings.lua
-- -----------------------------------------------------------------------------

SFC.Settings = {}

local LAM = LibStub("LibAddonMenu-2.0")

local panelData = {
    type        = "panel",
    name        = "Seething Fury Counter",
    displayName = "Seething Fury Counter",
    author      = "g4rr3t",
    version     = SFC.version,
    registerForRefresh  = true,
}

-- -----------------------------------------------------------------------------
-- Helper functions
-- -----------------------------------------------------------------------------

-- Locked State
local function ToggleLocked(control)
    SFC.preferences.unlocked = not SFC.preferences.unlocked
    SFC.UI.Contexts['animation']:SetMovable(SFC.preferences.unlocked)
    if SFC.preferences.unlocked then
        control:SetText("Lock")
    else
        control:SetText("Unlock")
    end
end

-- Get/Set
local function GetSaved(element)
    local saved = SFC.preferences[element]
    if type(saved) == "table" then
        return saved.r,
            saved.g,
            saved.b,
            saved.a
    else
        return saved
    end
end

local function SetSaved(element, value)
    SFC.preferences[element] = value
end

-- Color Options
local function SetColor(element, r, g, b, a)
    local color = {
        r = r,
        g = g,
        b = b,
        a = a,
    }
    SFC.UI.UpdateColor(element, color)
    SetSaved(element, color)
end

-- Frame Options
local function SetShowFrame(value)
    local isHidden = not value
    SFC.UI.Contexts['frame']:SetHidden(isHidden)
end

-- -----------------------------------------------------------------------------
-- Create Settings
-- -----------------------------------------------------------------------------

local optionsTable = {
    {
        type = "button",
        name = function() if SFC.preferences.unlocked then return "Lock" else return "Unlock" end end,
        tooltip = "Toggle lock/unlock state of counter display for repositioning.",
        func = function(control) ToggleLocked(control) end,
        width = "half",
    },
    {
        type = "header",
        name = "Display Options",
        width = "full",
    },
    {
        type = "colorpicker",
        name = "Number Color",
        tooltip = "",
        getFunc = function() return GetSaved('count') end,
        setFunc = function(r, g, b, a) SetColor('count', r, g, b, a) end,
    },
    {
        type = "colorpicker",
        name = "Animation Color",
        tooltip = "",
        getFunc = function() return GetSaved('animation') end,
        setFunc = function(r, g, b, a) SetColor('animation', r, g, b, a) end,
    },
    {
        type = "checkbox",
        name = "Show Frame",
        tooltip = "",
        getFunc = function() return GetSaved('showFrame') end,
        setFunc = function(value) SetSaved('showFrame', value) SetShowFrame(value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        name = "Frame Color",
        disabled = function() return not GetSaved('showFrame') end,
        tooltip = "",
        getFunc = function() return GetSaved('frame') end,
        setFunc = function(r, g, b, a) SetColor('frame', r, g, b, a) end,
    },
}

-- -----------------------------------------------------------------------------
-- Initialize Settings
-- -----------------------------------------------------------------------------

function SFC.Settings.Init()
    LAM:RegisterAddonPanel(SFC.name, panelData)
    LAM:RegisterOptionControls(SFC.name, optionsTable)

    SFC:Trace(2, "Finished Settings Init()")
end

-- -----------------------------------------------------------------------------
-- Settings Upgrade Function
-- -----------------------------------------------------------------------------

function SFC.Settings.Upgrade()
    -- FPO
end

