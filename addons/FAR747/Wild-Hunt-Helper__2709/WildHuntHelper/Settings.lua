-- Settings menu.
function WildHuntHelper.LoadSettings()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = WildHuntHelper.menuName,
        displayName = WildHuntHelper.menuName,
        author = WildHuntHelper.author,
        version = WildHuntHelper.version,
        --slashCommand = "/WildHuntHelper",
        registerForRefresh = true,
        registerForDefaults = true,
        website = GetString(SI_WHH_INFO_WEBSITE),
        --feedback = "https://www.esoui.com/downloads/info2668-SteelswordGoldLogger.html#comments",
        --translation = "https://github.com/FAR747/SteelswordGoldLogger-ESOAddon/tree/master/SteelswordGoldLogger/Languages",
        donation = "https://www.esoui.com/downloads/info2668-SteelswordGoldLogger.html#donate",
    }
    LAM:RegisterAddonPanel(WildHuntHelper.menuName, panelData)

    local optionsTable = {}
    
    optionsTable[#optionsTable + 1] = {
                type = "header",
                name = GetString(SI_WHH_SETTINGS_ICONLABEL),
                width = "full",
            }
    optionsTable[#optionsTable + 1] = {
                type = "description",
                text = GetString(SI_WHH_SETTINGS_ICONLABEL_DESCRIPTION),
                width = "full",
            }
    optionsTable[#optionsTable + 1] = {
                type = "checkbox",
                name = GetString(SI_WHH_SETTINGS_ICONLOCK),
                tooltip = GetString(SI_WHH_SETTINGS_ICONLOCK_TP),
                getFunc = function() return WildHuntHelper.savedVars.Lockicon end,
                setFunc = function(value) WildHuntHelper.GUILOCKICON(value) end,
                width = "half",
            }
    optionsTable[#optionsTable + 1] = {
                type = "button",
                name = GetString(SI_WHH_SETTINGS_ICONDEFAULT),
                tooltip = GetString(SI_WHH_SETTINGS_ICONDEFAULT_TP),
                func = function() WildHuntHelper.GUIRESETPOS() end,
                width = "half",
            }
    --Sliders
    optionsTable[#optionsTable + 1] = {
        type = "slider",
        name = GetString(SI_WHH_SETTINGS_ICONTRANSPARENCY),
        tooltip = GetString(SI_WHH_SETTINGS_ICONTRANSPARENCY_TP),
        getFunc = function() return WildHuntHelper.savedVars.IconCustomize.IconTransparency end,
        setFunc = function(value) WildHuntHelper.SetGUIIconTransparency(value) end,
        min = 0,
        max = 1,
        step = 0.01,
        decimals = 2,
        default = WildHuntHelper.defaultvars.IconCustomize.IconTransparency,
        width = "full",
    }
    optionsTable[#optionsTable + 1] = {
        type = "slider",
        name = GetString(SI_WHH_SETTINGS_BGICONTRANSPARENCY),
        tooltip = GetString(SI_WHH_SETTINGS_BGICONTRANSPARENCY_TP),
        getFunc = function() return WildHuntHelper.savedVars.IconCustomize.BGTransparency end,
        setFunc = function(value) WildHuntHelper.SetGUIBGIconTransparency(value) end,
        min = 0,
        max = 1,
        step = 0.01,
        decimals = 2,
        default = WildHuntHelper.defaultvars.IconCustomize.BGTransparency,
        width = "full",
    }
    --END Main Settings
    optionsTable[#optionsTable + 1] = {
                type = "divider",
                height = 15,
                width = "full",
            }
    optionsTable[#optionsTable + 1] = {
            type = "submenu",
            name = GetString(SI_WHH_SETTINGS_CRINGNAME_TITLE),
            controls = {
                [1] = {
                    type = "description",
                    text = GetString(SI_WHH_SETTINGS_CRINGNAME_DESCRIPTION),
                    width = "full",
                },
                [2] = {
                    type = "checkbox",
                    name = GetString(SI_WHH_SETTINGS_CRINGNAME_ENABLE),
                    tooltip = GetString(SI_WHH_SETTINGS_CRINGNAME_ENABLE_TP),
                    getFunc = function() return WildHuntHelper.savedVars.enableCuntomRingName end,
                    setFunc = function(value) WildHuntHelper.savedVars.enableCuntomRingName = value end,
                    default = WildHuntHelper.defaultvars.enableCuntomRingName,
                    width = "half",
                },
                [3] = {
                    type = "button",
                    name = GetString(SI_WHH_SETTINGS_CRINGNAME_BUTTONNAME),
                    tooltip = GetString(SI_WHH_SETTINGS_CRINGNAME_BUTTONNAME_TP),
                    func = function() WildHuntHelper.CustomButtonNameCheckRing() end,
                    width = "half",
                    disabled = function() return not WildHuntHelper.savedVars.enableCuntomRingName end, 
                },
                [4] = {
                    type = "editbox",
                    name = GetString(SI_WHH_SETTINGS_CRINGNAME_EDITBOXNAME),
                    tooltip = GetString(SI_WHH_SETTINGS_CRINGNAME_EDITBOXNAME_TP),
                    getFunc = function() return WildHuntHelper.savedVars.RingName end,
                    setFunc = function(text) WildHuntHelper.savedVars.RingName = text end,
                    default = WildHuntHelper.defaultvars.RingName,
                    width = "full",
                    disabled = function() return not WildHuntHelper.savedVars.enableCuntomRingName end, 
                },
            }
    }
    optionsTable[#optionsTable + 1] = {
            type = "submenu",
            name = "DEBUG",
            controls = {
                [1] = {
                    type = "button",
                    name = "Check Inventory",
                    --tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_UNDEFINED_MSG_TP),
                    func = function() WildHuntHelper.initinventory() end,
                    width = "half",
                },
                [2] = {
                    type = "button",
                    name = "Check Gear",
                    --tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_UNDEFINED_MSG_TP),
                    func = function() WildHuntHelper.gearcheck() end,
                    width = "half",
                },
            }
        }

    LAM:RegisterOptionControls(WildHuntHelper.menuName, optionsTable)
end