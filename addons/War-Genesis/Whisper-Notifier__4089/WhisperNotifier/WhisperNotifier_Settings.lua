--[[--------------------------------------------------------------------
    Whisper Notifier Addon - Settings Menu (v1.0.1)
    - Initial public release + minor fixes
----------------------------------------------------------------------]]

local ADDON_NAME = "WhisperNotifier"
local addon = _G[ADDON_NAME]
local LAM = LibAddonMenu2

local PANEL_NAME = ADDON_NAME .. "Panel"
local PANEL_TITLE = "Whisper Notifier Settings"

local fontChoices = { "Miniscule", "Tiny", "Small", "Normal", "Big", "Huge", "Gigantic" }
local fontValues = { 1, 2, 3, 4, 5, 6, 7 }

-- Create the settings panel
local function InitializeSettingsPanel()
    local defaults = (addon and addon.defaultSavedVars) or {}
    local savedVars = (addon and addon.savedVars) or {}

    local panelData = {
        type = "panel",
        name = PANEL_NAME,
        displayName = PANEL_TITLE,
        author = "JustInconceivable",
        version = (addon and addon.version) or "1.0.1",
        slashCommand = "/whispernotifier",
        registerForRefresh = true,
        registerForDefaults = true,
        defaults = defaults,
    }

    LAM:RegisterAddonPanel(PANEL_NAME, panelData)

    local optionsTable = {
        -- General Options Header
        { type = "header", name = "General Options" },
        {
            type = "checkbox", name = "Lock Position", tooltip = "Off to modify location",
            getFunc = function() return (addon and addon.isLocked ~= nil) and addon.isLocked or true end,
            setFunc = function(value) if addon and addon.UpdateLockState then addon:UpdateLockState(value) end end,
            disabled = function() return not addon end,
        },
        { type = "description", text = "To move: Uncheck 'Lock Position' -- Lock again to hide frame" },
         -- Appearance Header
        { type = "header", name = "Appearance" },
        {
            type = "dropdown", name = "Font Size", tooltip = "Select the font size...",
            choices = fontChoices, choicesValues = fontValues,
             -- Ensure savedVars exists before trying to access its keys
            getFunc = function() return (savedVars and savedVars.fontSizeIndex) or defaults.fontSizeIndex end,
            setFunc = function(value) if savedVars then savedVars.fontSizeIndex = value end; if addon and addon.ApplyFontSettings then addon:ApplyFontSettings() end end,
            default = defaults.fontSizeIndex, width = "full", disabled = function() return not savedVars end,
        },
        {
            type = "colorpicker", name = "Font Color (when Locked)", tooltip = "Sets the color...",
            getFunc = function() return (savedVars and savedVars.fontColorR) or defaults.fontColorR, (savedVars and savedVars.fontColorG) or defaults.fontColorG, (savedVars and savedVars.fontColorB) or defaults.fontColorB, 1 end,
            setFunc = function(r, g, b, a) if savedVars then savedVars.fontColorR = r; savedVars.fontColorG = g; savedVars.fontColorB = b end; if addon and addon.ApplyColorSettings then addon:ApplyColorSettings() end end,
            default = { r = defaults.fontColorR, g = defaults.fontColorG, b = defaults.fontColorB, a = 1 }, disabled = function() return not savedVars end,
        },
        {
            type = "slider", name = "Vertical Padding", tooltip = "Sets the vertical space...",
            min = 0, max = 30, step = 1,
            getFunc = function() return (savedVars and savedVars.verticalPadding) or defaults.verticalPadding end,
            setFunc = function(value) if savedVars then savedVars.verticalPadding = value end; if addon and addon.UpdatePositions then addon.UpdatePositions() end end,
            default = defaults.verticalPadding, width = "full", disabled = function() return not savedVars end,
        },
        -- Timing Header
        { type = "header", name = "Timing & Display" },
        {
            type = "slider", name = "Display Duration (seconds)", tooltip = "How long a message stays...",
            min = 0.5, max = 10, step = 0.1, decimals = 1, -- *** ADDED DECIMALS ***
            getFunc = function() return (savedVars and savedVars.displayDuration) or defaults.displayDuration end,
            setFunc = function(value) if savedVars then savedVars.displayDuration = value end end,
            default = defaults.displayDuration, width = "full", disabled = function() return not savedVars end,
        },
        {
            type = "slider", name = "Fade Out Duration (seconds)", tooltip = "How long the fade-out effect takes.",
            min = 0.1, max = 5, step = 0.1, decimals = 1, -- *** ADDED DECIMALS ***
            getFunc = function() return (savedVars and savedVars.fadeDuration) or defaults.fadeDuration end,
            setFunc = function(value) if savedVars then savedVars.fadeDuration = value end end,
            default = defaults.fadeDuration, width = "full", disabled = function() return not savedVars end,
        },
        {
            type = "slider", name = "Max Visible Messages", tooltip = "Maximum messages shown...",
            min = 1, max = 20, step = 1,
            getFunc = function() return (savedVars and savedVars.maxNotifications) or defaults.maxNotifications end,
            setFunc = function(value) if savedVars then savedVars.maxNotifications = value end end,
            default = defaults.maxNotifications, width = "full", warning = "Requires /reloadui to change the number of message slots available.", disabled = function() return not savedVars end,
        },
    }

    LAM:RegisterOptionControls(PANEL_NAME, optionsTable)
end

-- Delayed registration
local function OnPlayerActivated()
    if _G[ADDON_NAME] then
        addon = _G[ADDON_NAME]
        if addon.savedVars and addon.isLocked ~= nil then
             InitializeSettingsPanel()
             if LAM and LAM.RefreshPanel then LAM.RefreshPanel(PANEL_NAME) end
             EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Settings", EVENT_PLAYER_ACTIVATED)
        else
            zo_callLater(OnPlayerActivated, 500)
        end
    else
        zo_callLater(OnPlayerActivated, 500)
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Settings", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)