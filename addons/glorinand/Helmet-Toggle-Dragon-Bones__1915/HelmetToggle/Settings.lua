--[[

Helmet Toggle
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Variable for saved variables table
local sv

local panelData = {
    type = "panel",
    name = "Helmet Toggle",
    displayName = "|c70C0DEHelmet Toggle|r",
    author = "|c70C0DECaptainBlagbird|r",
    version = "1.5",
    slashCommand = "/helmettoggle",
    registerForRefresh = true,
    registerForDefaults = true,
    -- resetFunc = function() end, -- Will run after settings are reset to defaults
}

local optionsTable = {
    {
        type = "checkbox",
        name = "Display UI button",
        tooltip = "Enable/disable UI button",
        getFunc = function() return sv.uiEnabled end,
        setFunc = function(value)
                HelmetToggle:ShowUI(value)
            end,
        default = HelmetToggle.SavedVariables_defaults.uiEnabled,
        width = "full",
    },
    {
        type = "checkbox",
        name = "Chat command",
        tooltip = "Enable/disable chat command |cFFFF00/ht|r for toggling helmet",
        warning = "May need UI refresh (|cFFFF00/reloadui|r) after disabling if another add-on uses the same command",
        getFunc = function() return sv.slashEnabled end,
        setFunc = function(value)
                sv.slashEnabled = value
                SLASH_COMMANDS["/ht"] = value and HelmetToggle.ToggleHelmet or nil
            end,
        default = HelmetToggle.SavedVariables_defaults.slashEnabled,
        width = "full",
    },
    {
        type = "checkbox",
        name = "Auto mode",
        tooltip = "Enable/disable auto mode that toggles helmet on while in combat",
        getFunc = function() return sv.autoEnabled end,
        setFunc = function(value)
                HelmetToggle:ToggleAutoMode(value)
            end,
        default = HelmetToggle.SavedVariables_defaults.autoEnabled,
        width = "full",
    },
    {
        type = "slider",
        name = "Helmet show delay",
        tooltip = "Delay in miliseconds before helmet is shown in auto mode",
        min = 0,
        max = 5000,
        step = 25,
        getFunc = function() return sv.delayShow end,
        setFunc = function(value) sv.delayShow = value end,
        default = HelmetToggle.SavedVariables_defaults.delayShow,
        disabled = function() return not sv.autoEnabled end,
        width = "full",
    },
    {
        type = "slider",
        name = "Helmet hide delay",
        tooltip = "Delay in miliseconds before helmet is hidden in auto mode",
        min = 0,
        max = 5000,
        step = 25,
        getFunc = function() return sv.delayHide end,
        setFunc = function(value) sv.delayHide = value end,
        default = HelmetToggle.SavedVariables_defaults.delayHide,
        disabled = function() return not sv.autoEnabled end,
        width = "full",
    },
    {
        type = "header",
        name = "",
        width = "full",
    },
    {
        type = "description",
        title = "\nReset UI position",
        width = "half",
    },
    {
        type = "button",
        name = "Reset",
        warning = "Cannot be undone!",
        func = function()
                sv.position = {}
                HelmetToggle:RestoreUIPosition()
            end,
        width = "half",
    },
    {
        type = "description",
        title = "",
        text = "Note: Clicking on '"..GetString(SI_OPTIONS_DEFAULTS).."' below does NOT reset the UI position.",
        width = "full",
    },
}


-- Wait until all addons are loaded
local function OnPlayerActivated(event)
    if LibStub ~= nil then
        local LAM = LibStub("LibAddonMenu-2.0")
        LAM:RegisterAddonPanel("HelmetToggle_Options", panelData)
        LAM:RegisterOptionControls("HelmetToggle_Options", optionsTable)
    end
    
    -- Direct reference to saved variables table of current user/char
    sv = HelmetToggleSavedVariables.Default[GetDisplayName()][GetUnitName("player")]
    
    EVENT_MANAGER:UnregisterForEvent("HelmetToggle_Options", EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent("HelmetToggle_Options", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)