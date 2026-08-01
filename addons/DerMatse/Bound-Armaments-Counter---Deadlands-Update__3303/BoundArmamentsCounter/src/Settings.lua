-- -----------------------------------------------------------------------------
-- Bound Armaments Counter
-- Author:  g4rr3t/Masel
-- Created: Sep 27, 2019
--
-- Settings.lua
-- -----------------------------------------------------------------------------

local LAM = LibAddonMenu2

local panelData = {
    type        = "panel",
    name        = "Bound Armaments Counter",
    displayName = "Bound Armaments Counter",
    author      = "g4rr3t/Masel",
    version     = BAC.version,
    registerForRefresh  = true,
}

local optionsTable = {
    {
        type = "header",
        name = "Positioning",
        width = "full",
    },
    {
        type = "button",
        name = function() if BAC.preferences.unlocked then return "Lock" else return "Unlock" end end,
        tooltip = "Toggle lock/unlock state of counter display for repositioning.",
        func = function(control) ToggleLockedb(control) end,
        width = "half",
    },
    {
        type = "button",
        name = function() if BAC.ForceShowb then return "Hide" else return "Show" end end,
        tooltip = "Force show for position or previewing display settings.",
        func = function(control) ForceShowb(control) end,
        width = "half",
    },
    {
        type = "checkbox",
        name = "Lock to Reticle",
        tooltip = "Snap display of counter to center of reticle. Some display options may appear better than others positioned this way.",
        getFunc = function() return GetLockReticleb() end,
        setFunc = function(value) SetLockReticleb(value) end,
        width = "full",
    },
    {
        type = "header",
        name = "Style",
        width = "full",
    },
    {
        type = "iconpicker",
        name = "Counter Style",
        choices = {
            "BoundArmamentsCounter/art/textures/Picker-ColorSquares.dds",
            "BoundArmamentsCounter/art/textures/Picker-Doom.dds",
            "BoundArmamentsCounter/art/textures/Picker-HorizontalDots.dds",
            "BoundArmamentsCounter/art/textures/Picker-FilledDots.dds",
            "BoundArmamentsCounter/art/textures/Picker-Numbers.dds",
            "BoundArmamentsCounter/art/textures/Picker-NumbersThickStroke.dds",
            "BoundArmamentsCounter/art/textures/Picker-Dice.dds",
            "BoundArmamentsCounter/art/textures/Picker-PlayMagsorc.dds",
            "BoundArmamentsCounter/art/textures/Picker-CH01_red.dds",
            "BoundArmamentsCounter/art/textures/Picker-CH01_BW.dds",
			"BoundArmamentsCounter/art/textures/Picker-Sorcaim.dds",
        },
        getFunc = function() return GetTextureb() end,
        setFunc = function(texture) SetTextureb(texture) end,
        tooltip = "Style of counter display.",
        choicesTooltips = {
            "Color Squares",
            "DOOM",
            "Horizontal Dots",
            "Filled Dots",
            "Numbers",
            "Numbers (Thick Stroke)",
            "Dice",
            "Play Magsorc",
            "Red Compass (by Porkjet)",
            "Mono Compass (by Porkjet)",
			"Sorc Aim (by Porkjet)",
        },
        maxColumns = 3,
        visibleRows = 2.5,
        iconSize = 64,
        width = "full",
    },
    {
        type = "slider",
        name = "Display Size",
        tooltip = "Display size of counter.",
        min = 0,
        max = 500,
        step = 5,
        getFunc = function() return GetSizeb() end,
        setFunc = function(value) SetSizeb(value) end,
        width = "full",
        default = 40,
    },
    {
        type = "checkbox",
        name = "Show Zero Stacks",
        tooltip = "Show when skill is active but no stacks tracked.",
        getFunc = function() return GetZeroStacksb() end,
        setFunc = function(value) SetZeroStacksb(value) end,
        width = "full",
    },
    {
        type = "description",
        text = "Not all display styles include indicators for zero stacks.",
        width = "full",
    },
    {
        type = "header",
        name = "Advanced Options",
        width = "full",
    },
    {
        type = "checkbox",
        name = "Fade on Skill Inactive",
        tooltip = "Lower opacity when stacks exist and in combat, but buff has expired.",
        getFunc = function() return GetFadeb() end,
        setFunc = function(value) SetFadeb(value) end,
        width = "full",
    },
    {
        type = "slider",
        name = "Fade Amount",
        tooltip = "Opacity of inactive skill with counted stacks",
        min = 0,
        max = 100,
        disabled = function() return not GetFadeb() end,
        getFunc = function() return GetFadebAmount() end,
        setFunc = function(value) SetFadebAmount(value) end,
        width = "full",
        default = 90,
    },
    {
        type = "checkbox",
        name = "Color Overlay: Default",
        tooltip = "Overlay the indicator with a color. Works better on some textures than others.",
        getFunc = function() return GetColorOverlayb('default') end,
        setFunc = function(value) SetColorOverlayb('default', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlayb('default') end,
        tooltip = "Color used for Color Overlay: Default",
        getFunc = function() return GetColorb('default') end,
        setFunc = function(r, g, b, a) SetColorb('default', r, g, b, a) end,
    },
    {
        type = "checkbox",
        name = "Color Overlay: Inactive",
        tooltip = "When skill is inactive, overlay the indicator with a color.",
        getFunc = function() return GetColorOverlayb('inactive') end,
        setFunc = function(value) SetColorOverlayb('inactive', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlayb('inactive') end,
        tooltip = "Color used for Color Overlay: Inactive",
        getFunc = function() return GetColorb('inactive') end,
        setFunc = function(r, g, b, a) SetColorb('inactive', r, g, b, a) end,
    },
    {
        type = "checkbox",
        name = "Color Overlay: 4 Stacks",
        tooltip = "Differentiate the significance of 4 stacks to prepare to fire bow proc.",
        getFunc = function() return GetColorOverlayb('four') end,
        setFunc = function(value) SetColorOverlayb('four', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlayb('four') end,
        tooltip = "Color used for Color Overlay: Proc",
        getFunc = function() return GetColorb('four') end,
        setFunc = function(r, g, b, a) SetColorb('four', r, g, b, a) end,
    },
    {
        type = "checkbox",
        name = "Color Overlay: Proc",
        tooltip = "When a proc is active and spectral bow is ready to be fired, overlay the indicator with a color.",
        getFunc = function() return GetColorOverlayb('proc') end,
        setFunc = function(value) SetColorOverlayb('proc', value) end,
        width = "full",
    },
    {
        type = "colorpicker",
        disabled = function() return not GetColorOverlayb('proc') end,
        tooltip = "Color used for Color Overlay: Proc",
        getFunc = function() return GetColorb('proc') end,
        setFunc = function(r, g, b, a) SetColorb('proc', r, g, b, a) end,
    },
    {
        type = "submenu",
        name = "Acknowledgements",
        controls = {
		    [1] = {
                type = "description",
                text = "|cBCBCBC|u0:40::g4rr3t|u|rCreator of Grim Focus Counter",
                width = "full",
            [2] = {
                type = "description",
                text = "|cBCBCBC|u0:40::Porkjet|u|rCreator of awesome textures",
                width = "full",
            },
            [3] = {
                type = "description",
                text = "|cBCBCBC|u0:40::aquamantom|u|rHomeowner of primary facility for testing, parsing and AFKing",
                width = "full",
            },
            [4] = {
                type = "description",
                text = "|cBCBCBC|u0:40::Vierron|u|rAdditional blind-people perspective, testing and input",
                width = "full",
            },
			},
        },               
    },
}

-- -----------------------------------------------------------------------------
-- Helper functions to set/get settings
-- -----------------------------------------------------------------------------

-- Locked State
function ToggleLockedb(control)
    BAC.preferences.unlocked = not BAC.preferences.unlocked
    BAC.BACContainer:SetMovable(BAC.preferences.unlocked)
    if BAC.preferences.unlocked then
        control:SetText("Lock")
    else
        control:SetText("Unlock")
    end
end

-- Force Showing
function ForceShowb(control)
    BAC.ForceShowb = not BAC.ForceShowb
    if BAC.ForceShowb then
        control:SetText("Hide")
        BAC.HUDHidden = false
        BAC.BACContainer:SetHidden(false)
        BAC.UpdateStacks(5)
    else
        control:SetText("Show")
        BAC.HUDHidden = true
        BAC.BACContainer:SetHidden(true)
        BAC.UpdateStacks(0)
    end
end

-- Lock to Reticle
function SetLockReticleb(value)
    BAC.LockToReticle(value)
end

function GetLockReticleb(value)
    return BAC.preferences.lockedToReticle
end

-- Textures
function SetTextureb(value)

    -- Search texture array
    -- We are passed the picker's texture,
    -- convert to the index of the texture table.
    for index, texture in pairs(BAC.TEXTURE_VARIANTS) do
        if texture.picker == value then
            selectedTexture = index
            break
        end
    end

    if selectedTexture ~= nil then
        BAC.BACTexture:SetTexture(BAC.TEXTURE_VARIANTS[selectedTexture].asset)
        BAC.preferences.selectedTexture = selectedTexture
    else
        d('[BAC] Could not load specified texture!')
    end

end

function GetTextureb()
    selectedTexture = BAC.preferences.selectedTexture
    return BAC.TEXTURE_VARIANTS[selectedTexture].picker
end

-- Sizing
function SetSizeb(value)
    BAC.preferences.size = value
    BAC.BACContainer:SetDimensions(value, value)
    BAC.BACTexture:SetDimensions(value, value)
end

function GetSizeb()
    return BAC.preferences.size
end

-- Zero Stacks
function SetZeroStacksb(value)
    BAC.preferences.showEmptyStacks = value
end

function GetZeroStacksb()
    return BAC.preferences.showEmptyStacks
end

-- Color Overlay
function SetColorOverlayb(overlayType, value)
    BAC.preferences.overlay[overlayType] = value
    BAC.SetSkillColorOverlay('default')
end

function GetColorOverlayb(overlayType, key)
    return BAC.preferences.overlay[overlayType]
end

function SetColorb(overlayType, r, g, b, a)
    BAC.preferences.colors[overlayType] = {
        r = r,
        g = g,
        b = b,
        a = a,
    }
    BAC.SetSkillColorOverlay('default')
end

function GetColorb(overlayType)
    return BAC.preferences.colors[overlayType].r,
        BAC.preferences.colors[overlayType].g,
        BAC.preferences.colors[overlayType].b,
        BAC.preferences.colors[overlayType].a
end

-- Fade
function SetFadeb(value)
    -- Note: To avoid having to change alpha every time,
    -- even if we never wanted to fade in the first place,
    -- turning OFF the option must first SetSkillFade(false)
    -- before setting preferences.fadeInactive to false.
    -- Otherwise we may get stuck in a faded state.
    BAC.SetSkillFade(value)
    BAC.preferences.fadeInactive = value
end

function GetFadeb()
    return BAC.preferences.fadeInactive
end

function SetFadebAmount(value)
    BAC.preferences.fadeAmount = value
    BAC.SetSkillFade()
end

function GetFadebAmount()
    return BAC.preferences.fadeAmount
end

-- -----------------------------------------------------------------------------
-- Initialize Settings
-- -----------------------------------------------------------------------------

function BAC:InitSettings()
    LAM:RegisterAddonPanel(BAC.name, panelData)
    LAM:RegisterOptionControls(BAC.name, optionsTable)

    BAC:Trace(2, "Finished InitSettings()")
end

-- -----------------------------------------------------------------------------
-- Settings Upgrade Function
-- -----------------------------------------------------------------------------

function BAC:UpgradeSettings()
    -- Check if we've already upgraded
    if BAC.preferences.colorOverlay == nil and BAC.preferences.color == nil then return end

    -- Copy default color overlay to new savedvar
    BAC.preferences.overlay.default = BAC.preferences.colorOverlay
    BAC.preferences.colors.default = BAC.preferences.color

    -- Clear old, indicate upgraded
    BAC.preferences.colorOverlay = nil
    BAC.preferences.color= nil
end

