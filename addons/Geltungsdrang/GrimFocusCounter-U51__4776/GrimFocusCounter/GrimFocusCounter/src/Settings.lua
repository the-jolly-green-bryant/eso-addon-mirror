-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t Updated by Geltungsdrang
-- Created: Jan 1, 2018
-- Edited: Geltungsdrang 2026
-- Settings.lua
-- -----------------------------------------------------------------------------

local LAM = LibAddonMenu2
local GFC = GFC

--- @type table<string, any> LibAddonMenu2 panel data
local panelData = {
    type                = "panel",
    name                = "Grim Focus Counter",
    displayName         = "Grim Focus Counter",
    author              = "g4rr3t (Geltungsdrang Update)",
    version             = GFC.version,
    registerForRefresh  = true,
    registerForDefaults = true,
    slashCommand        = "/gfcs",
}

-- -----------------------------------------------------------------------------
-- Helper functions to set/get settings
-- -----------------------------------------------------------------------------

--- Update the hideOutOfCombat setting
--- @param hide boolean True to hide when out of combat
--- @return nil
local function setHideOutOfCombat(hide)
    GFC.preferences.hideOutOfCombat = hide
    GFC:OnPlayerChanged()
end

--- Get the hideOutOfCombat setting
--- @return boolean hide True when hideOutOfCombat is enabled
local function getHideOutOfCombat()
    return GFC.preferences.hideOutOfCombat
end

--- Toggle the movable state of the display
--- @return nil
local function toggleLocked()
    GFC.preferences.unlocked = not GFC.preferences.unlocked
    GFC.GFCContainer:SetMovable(GFC.preferences.unlocked)
end

--- Toggle a forced preview of the display
--- @return nil
local function forceShow()
    GFC.ForceShow = not GFC.ForceShow

    if GFC.ForceShow then
        GFC.HUDHidden = false
        GFC.GFCContainer:SetHidden(false)
        -- Preview at the ceiling so the widest digit is visible while
        -- positioning and sizing the display
        GFC:UpdateStacks(GFC.MAX_STACKS)
    else
        GFC.HUDHidden = true
        GFC.GFCContainer:SetHidden(true)
        GFC:OnPlayerChanged()
    end
end

--- Set the display size
--- @param value integer Display size
--- @return nil
local function setSize(value)
    GFC.preferences.size = value
    GFC.GFCContainer:SetDimensions(value, value)
    GFC.GFCTexture:SetDimensions(value, value)
end

--- Get the display size
--- @return integer value Display size
local function getSize()
    return GFC.preferences.size
end

--- Set the showEmptyStacks value
--- @param value boolean True to show the digit 0 when not stacked
--- @return nil
local function setZeroStacks(value)
    GFC.preferences.showEmptyStacks = value
    GFC:UpdateUI()
end

--- Get the showEmptyStacks value
--- @return boolean value True to show the digit 0 when not stacked
local function getZeroStacks()
    return GFC.preferences.showEmptyStacks
end

--- Set the colour for a display state
--- @param state string One of normal, notSlotted, almost, ready
--- @param r number Red value
--- @param g number Green value
--- @param b number Blue value
--- @param a number Alpha value
--- @return nil
local function setColor(state, r, g, b, a)
    GFC.preferences.colors[state] = { r = r, g = g, b = b, a = a or 1 }
    GFC:UpdateUI()
end

--- Get the colour for a display state
--- @param state string One of normal, notSlotted, almost, ready
--- @return number r, number g, number b, number a
local function getColor(state)
    local c = GFC.preferences.colors[state]
    return c.r, c.g, c.b, c.a
end

--- Set if the display should fade when the skill is not slotted
--- @param value boolean True to enable fade
--- @return nil
local function setFade(value)
    GFC.preferences.fadeInactive = value
    GFC:UpdateUI()
end

--- Get the fadeInactive value
--- @return boolean value True to fade when not slotted
local function getFade()
    return GFC.preferences.fadeInactive
end

--- Set the amount to fade
--- @param value integer Amount to fade
--- @return nil
local function setFadeAmount(value)
    GFC.preferences.fadeAmount = value
    GFC:UpdateUI()
end

--- Get the amount to fade
--- @return integer value Amount to fade
local function getFadeAmount()
    return GFC.preferences.fadeAmount
end

--- Set if the display should be locked to the reticle
--- @param value boolean True to lock to reticle
--- @return nil
local function setLockReticle(value)
    GFC:LockToReticle(value)
end

--- Get the lock to reticle setting
--- @return boolean value True when locked to reticle
local function getLockReticle()
    return GFC.preferences.lockedToReticle
end

--- Set if the display should show while the skill is not slotted
--- @param value boolean True to always show
--- @return nil
local function setAlwaysShow(value)
    GFC.preferences.alwaysShow = value
    GFC:OnPlayerChanged()
end

--- Get the always show setting
--- @return boolean value True to always show
local function getAlwaysShow()
    return GFC.preferences.alwaysShow
end

local WHITE = { r = 1, g = 1, b = 1, a = 1 }

--- @type table<string, any>[] LibAddonMenu options
local optionsTable = {
    {
        type = "header",
        name = "Position",
        width = "full",
    },
    {
        type = "button",
        name = "Lock / Unlock",
        tooltip = "Toggle whether the counter can be dragged around the screen.",
        func = toggleLocked,
        width = "half",
    },
    {
        type = "button",
        name = "Preview On / Off",
        tooltip = "Force the counter to show at 10 stacks so you can place and size it.",
        func = forceShow,
        width = "half",
    },
    {
        type = "checkbox",
        name = "Lock to Reticle",
        tooltip = "Snap the counter to the centre of the reticle.",
        getFunc = getLockReticle,
        setFunc = setLockReticle,
        width = "full",
        default = false,
    },
    {
        type = "slider",
        name = "Display Size",
        tooltip = "Size of the counter in pixels.",
        min = 20,
        max = 500,
        step = 5,
        getFunc = getSize,
        setFunc = setSize,
        width = "full",
        default = 100,
    },
    {
        type = "header",
        name = "When to Show",
        width = "full",
    },
    {
        type = "checkbox",
        name = "Show Zero",
        tooltip = "Show the digit 0 while the skill is slotted but not yet stacked. Turn off to show nothing until the first stack.",
        getFunc = getZeroStacks,
        setFunc = setZeroStacks,
        width = "full",
        default = true,
    },
    {
        type = "checkbox",
        name = "Hide Out of Combat",
        tooltip = "Hide the counter whenever you are out of combat.",
        getFunc = getHideOutOfCombat,
        setFunc = setHideOutOfCombat,
        width = "full",
        default = false,
    },
    {
        type = "checkbox",
        name = "Show When Not Slotted",
        tooltip = "Keep the counter on screen even when Grim Focus is not on either bar.",
        getFunc = getAlwaysShow,
        setFunc = setAlwaysShow,
        width = "full",
        default = false,
    },
    {
        type = "checkbox",
        name = "Fade When Not Slotted",
        tooltip = "Dim the counter while the skill is not slotted. Only has an effect with Show When Not Slotted turned on.",
        getFunc = getFade,
        setFunc = setFade,
        width = "full",
        default = false,
    },
    {
        type = "slider",
        name = "Fade Amount",
        tooltip = "How opaque the counter is while faded. 100 is fully visible.",
        min = 0,
        max = 100,
        step = 5,
        getFunc = getFadeAmount,
        setFunc = setFadeAmount,
        width = "full",
        default = 90,
    },
    {
        type = "header",
        name = "Colors",
        width = "full",
    },
    {
        type = "description",
        text = "Leave a colour white for no tint.",
        width = "full",
    },
    {
        type = "colorpicker",
        name = "Building Stacks",
        tooltip = "Digit colour while stacking up, below the count needed to fire.",
        getFunc = function() return getColor('normal') end,
        setFunc = function(r, g, b, a) setColor('normal', r, g, b, a) end,
        width = "full",
        default = WHITE,
    },
    {
        type = "colorpicker",
        name = "One Before Ready",
        tooltip = "Digit colour on the last stack before the bow can fire. That is 3 for Relentless Focus and 4 for Grim Focus and Merciless Resolve.",
        getFunc = function() return getColor('almost') end,
        setFunc = function(r, g, b, a) setColor('almost', r, g, b, a) end,
        width = "full",
        default = WHITE,
    },
    {
        type = "colorpicker",
        name = "Bow Ready",
        tooltip = "Digit colour once the spectral bow can fire. Stays on while stacks bank above that point.",
        getFunc = function() return getColor('ready') end,
        setFunc = function(r, g, b, a) setColor('ready', r, g, b, a) end,
        width = "full",
        default = WHITE,
    },
    {
        type = "colorpicker",
        name = "Not Slotted",
        tooltip = "Digit colour while Grim Focus is not on either bar.",
        getFunc = function() return getColor('notSlotted') end,
        setFunc = function(r, g, b, a) setColor('notSlotted', r, g, b, a) end,
        width = "full",
        default = WHITE,
    },
    {
        type = "description",
        text = "send all your |cFFD700Gold|r to @Geltungsdrang |cFF3333xoxo|r",
        width = "full",
    },
}

--- Initialize settings
--- @return nil
function GFC:InitSettings()
    LAM:RegisterAddonPanel(self.name, panelData)
    LAM:RegisterOptionControls(self.name, optionsTable)

    self:Trace(2, "Finished InitSettings()")
end

--- Upgrade settings
--- @return nil
function GFC:UpgradeSettings()
    local prefs = self.preferences

    -- Very old builds stored a single colour under top level keys
    if prefs.colorOverlay ~= nil or prefs.color ~= nil then
        prefs.colorOverlay = nil
        prefs.color = nil
    end

    local renamed = {
        default  = "normal",
        inactive = "notSlotted",
        four     = "almost",
        proc     = "ready",
    }

    local function isUntinted(c)
        return c == nil or (c.r == 1 and c.g == 1 and c.b == 1 and (c.a or 1) == 1)
    end

    for old, new in pairs(renamed) do
        local colour = prefs.colors and prefs.colors[old]
        local wasEnabled = prefs.overlay and prefs.overlay[old]

        if colour ~= nil then
            if wasEnabled and isUntinted(prefs.colors[new]) then
                prefs.colors[new] = colour
            end
            prefs.colors[old] = nil
        end
    end

    prefs.overlay = nil

    prefs.colors = prefs.colors or {}
    for _, state in ipairs({ "normal", "notSlotted", "almost", "ready" }) do
        local c = prefs.colors[state]
        if type(c) ~= "table" or c.r == nil or c.g == nil or c.b == nil then
            prefs.colors[state] = { r = 1, g = 1, b = 1, a = 1 }
        elseif c.a == nil then
            c.a = 1
        end
    end

    prefs.selectedTexture = nil
    prefs.stackTextMode = nil
end
