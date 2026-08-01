local ADDON_NAME = "DarkModeESO"
local ADDON_VERSION = "1.0.1"

local DarkMode = {
    defaults = {
        enabled = true,
        darkPanels = true,
        darkCompass = true,
        darkHealthBars = true,
    },
    savedVars = nil,
}

local DARK_COLOR = { 0.02, 0.02, 0.02, 1.0 }
local PANEL_COLOR = { 0.05, 0.05, 0.05, 0.95 }

local ATTRIBUTE_FRAME_TEXTURES = {
    "ZO_PlayerAttributeHealthFrameLeft",
    "ZO_PlayerAttributeHealthFrameRight",
    "ZO_PlayerAttributeHealthFrameCenter",
    "ZO_PlayerAttributeMagickaFrameLeft",
    "ZO_PlayerAttributeMagickaFrameRight",
    "ZO_PlayerAttributeMagickaFrameCenter",
    "ZO_PlayerAttributeStaminaFrameLeft",
    "ZO_PlayerAttributeStaminaFrameRight",
    "ZO_PlayerAttributeStaminaFrameCenter",
}

local COMPASS_TEXTURES = {
    "ZO_CompassFrameLeft",
    "ZO_CompassFrameRight",
    "ZO_CompassFrameCenter",
}

local PANEL_BACKGROUND_TEXTURES = {
    "ZO_SharedRightPanelBackgroundLeft",
    "ZO_SharedLeftPanelBackgroundLeft",
    "ZO_SharedLeftPanelBackgroundRight",
    "ZO_SharedRightBackgroundLeft",
    "ZO_SharedStatsBackgroundLeft",
    "ZO_SharedThinRightPanelBackgroundLeft",
    "ZO_SharedThinLeftPanelBackgroundLeft",
    "ZO_SharedThinLeftPanelBackgroundRight",
    "ZO_SharedMediumRightPanelBackgroundLeft",
    "ZO_SharedMediumLeftPanelBackgroundLeft",
    "ZO_SharedMediumLeftPanelBackgroundRight",
    "ZO_SharedWideRightPanelBackgroundLeft",
    "ZO_SharedWideLeftPanelBackgroundLeft",
    "ZO_SharedWideLeftPanelBackgroundRight",
    "ZO_SharedTreeUnderlayLeft",
    "ZO_SharedTreeUnderlayRight",
    "ZO_KeybindStripMungeBackgroundTexture",
}

local function SafeDarkenTexture(controlName, color)
    local control = GetControl(controlName)
    if control and control.SetColor then
        control:SetColor(unpack(color))
    end
end

local function SafeDarkenBackdrop(controlName, color)
    local control = GetControl(controlName)
    if control then
        if control.SetCenterColor then
            control:SetCenterColor(unpack(color))
        end
        if control.SetEdgeColor then
            control:SetEdgeColor(unpack(color))
        end
    end
end

local function DarkenAttributeBars()
    if not DarkMode.savedVars or not DarkMode.savedVars.darkHealthBars then return end
    for _, name in ipairs(ATTRIBUTE_FRAME_TEXTURES) do
        SafeDarkenTexture(name, DARK_COLOR)
    end
end

local function DarkenCompass()
    if not DarkMode.savedVars or not DarkMode.savedVars.darkCompass then return end
    for _, name in ipairs(COMPASS_TEXTURES) do
        SafeDarkenTexture(name, DARK_COLOR)
    end
    local frame = GetControl("ZO_CompassFrame")
    if frame then
        for i = 1, frame:GetNumChildren() do
            local child = frame:GetChild(i)
            if child and child.SetColor and not child.SetText then
                child:SetColor(unpack(DARK_COLOR))
            end
        end
    end
end

local function DarkenPanels()
    if not DarkMode.savedVars or not DarkMode.savedVars.darkPanels then return end
    for _, name in ipairs(PANEL_BACKGROUND_TEXTURES) do
        SafeDarkenTexture(name, PANEL_COLOR)
    end
end

local function ApplyDarkMode()
    if not DarkMode.savedVars or not DarkMode.savedVars.enabled then return end
    DarkenAttributeBars()
    DarkenCompass()
    DarkenPanels()
end

local function CreateSettingsPanel()
    if not LibHarvensAddonSettings then return end
    local settings = LibHarvensAddonSettings:AddAddon(ADDON_NAME)
    if not settings then return end
    
    settings:AddSetting {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Enable Dark Mode",
        tooltip = "Toggle the dark mode theme on or off",
        default = DarkMode.defaults.enabled,
        getFunction = function() return DarkMode.savedVars.enabled end,
        setFunction = function(value)
            DarkMode.savedVars.enabled = value
            if value then ApplyDarkMode() end
        end,
    }
    
    settings:AddSetting {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Dark Compass",
        tooltip = "Apply dark theme to the compass frame",
        default = DarkMode.defaults.darkCompass,
        getFunction = function() return DarkMode.savedVars.darkCompass end,
        setFunction = function(value)
            DarkMode.savedVars.darkCompass = value
            ApplyDarkMode()
        end,
    }
    
    settings:AddSetting {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Dark Health Bar Outlines",
        tooltip = "Apply dark theme to attribute bar frames",
        default = DarkMode.defaults.darkHealthBars,
        getFunction = function() return DarkMode.savedVars.darkHealthBars end,
        setFunction = function(value)
            DarkMode.savedVars.darkHealthBars = value
            ApplyDarkMode()
        end,
    }
    
    settings:AddSetting {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Dark UI Panels",
        tooltip = "Apply dark theme to UI panel backgrounds",
        default = DarkMode.defaults.darkPanels,
        getFunction = function() return DarkMode.savedVars.darkPanels end,
        setFunction = function(value)
            DarkMode.savedVars.darkPanels = value
            ApplyDarkMode()
        end,
    }
end

local function SlashCommandHandler(args)
    args = string.lower(args or "")
    if args == "toggle" or args == "" then
        DarkMode.savedVars.enabled = not DarkMode.savedVars.enabled
        if DarkMode.savedVars.enabled then
            d("|cFFFFFF[Dark Mode ESO]|r Enabled")
            ApplyDarkMode()
        else
            d("|cFFFFFF[Dark Mode ESO]|r Disabled - Reload UI to remove effects")
        end
    elseif args == "reload" then
        ApplyDarkMode()
        d("|cFFFFFF[Dark Mode ESO]|r Refreshed")
    elseif args == "help" then
        d("|cFFFFFF[Dark Mode ESO]|r Commands:")
        d("  /darkmode - Toggle on/off")
        d("  /darkmode reload - Refresh")
    end
end

local function Initialize()
    DarkMode.savedVars = ZO_SavedVars:NewAccountWide("DarkModeESO_SavedVariables", 1, nil, DarkMode.defaults)
    SLASH_COMMANDS["/darkmode"] = SlashCommandHandler
    SLASH_COMMANDS["/dm"] = SlashCommandHandler
    
    CreateSettingsPanel()
    
    zo_callLater(function()
        ApplyDarkMode()
        d("|cFFFFFF[Dark Mode ESO]|r v" .. ADDON_VERSION .. " loaded")
    end, 1000)
    
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(ApplyDarkMode, 500)
    end)
    
    if SCENE_MANAGER then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
            if newState == SCENE_SHOWN then
                zo_callLater(ApplyDarkMode, 200)
            end
        end)
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    Initialize()
end)
