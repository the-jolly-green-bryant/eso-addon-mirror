-- Transmute Set Crafter — LibAddonMenu settings panel

local TSC = TransmuteSetCrafter

function TSC.InitializeSettings()
    local LAM = LibAddonMenu2 or LibStub and LibStub("LibAddonMenu-2.0", true)
    if not LAM then return end

    local panelData = {
        type        = "panel",
        name        = GetString(SI_TSC_SETTINGS_PANEL_NAME),
        displayName = GetString(SI_TSC_TITLE),
        author      = "You",
        version     = "1.0.0",
    }
    LAM:RegisterAddonPanel("TransmuteSetCrafterPanel", panelData)

    local options = {
        {
            type    = "checkbox",
            name    = GetString(SI_TSC_SETTINGS_AUTO_OPEN),
            tooltip = GetString(SI_TSC_SETTINGS_AUTO_OPEN_TOOLTIP),
            getFunc = function() return TSC.savedVars.openAtStation end,
            setFunc = function(v) TSC.savedVars.openAtStation = v end,
        },
        {
            type    = "checkbox",
            name    = GetString(SI_TSC_SETTINGS_CLOSE_ON_EXIT),
            tooltip = GetString(SI_TSC_SETTINGS_CLOSE_ON_EXIT_TOOLTIP),
            getFunc = function() return TSC.savedVars.closeOnExit end,
            setFunc = function(v) TSC.savedVars.closeOnExit = v end,
        },
        {
            type    = "checkbox",
            name    = GetString(SI_TSC_SETTINGS_AUTO_RECONSTRUCT),
            tooltip = GetString(SI_TSC_SETTINGS_AUTO_RECONSTRUCT_TOOLTIP),
            getFunc = function() return TSC.savedVars.autoOpenReconstruct end,
            setFunc = function(v) TSC.savedVars.autoOpenReconstruct = v end,
        },
        {
            type    = "checkbox",
            name    = GetString(SI_TSC_SETTINGS_AUTO_OPEN_ENCHANT),
            tooltip = GetString(SI_TSC_SETTINGS_AUTO_OPEN_ENCHANT_TOOLTIP),
            getFunc = function() return TSC.savedVars.openAtEnchantStation end,
            setFunc = function(v) TSC.savedVars.openAtEnchantStation = v end,
        },
        {
            type    = "checkbox",
            name    = GetString(SI_TSC_SETTINGS_CLOSE_ON_ENCHANT_EXIT),
            tooltip = GetString(SI_TSC_SETTINGS_CLOSE_ON_ENCHANT_EXIT_TOOLTIP),
            getFunc = function() return TSC.savedVars.closeOnEnchantExit end,
            setFunc = function(v) TSC.savedVars.closeOnEnchantExit = v end,
        },
    }
    LAM:RegisterOptionControls("TransmuteSetCrafterPanel", options)
end
