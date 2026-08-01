-- Settings menu.
function SteelswordGoldLogger.LoadSettings()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = SteelswordGoldLogger.menuName,
        displayName = SteelswordGoldLogger.menuName,
        author = SteelswordGoldLogger.author,
        version = SteelswordGoldLogger.version,
        website = GetString(SI_SGL_INFO_WEBSITE),
        feedback = "https://www.esoui.com/downloads/info2668-SteelswordGoldLogger.html#comments",
        translation = "https://github.com/FAR747/SteelswordGoldLogger-ESOAddon/tree/master/SteelswordGoldLogger/Languages",
        donation = "https://www.esoui.com/downloads/info2668-SteelswordGoldLogger.html#donate",
        --slashCommand = "/myaddon",	--(optional) will register a keybind to open to this panel
        registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
        registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
    }
    
    local optionsTable = {
        [1] = {
            type = "submenu",
            name = GetString(SI_SGL_SETTINGS_CATEGORY_GENERAL),
            controls = {
                [1] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_UNDEFINED_MSG),
                    tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_UNDEFINED_MSG_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.msgundefinedreason end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.msgundefinedreason = value end,
                    default = SteelswordGoldLogger.defaultVars.msgundefinedreason,
                    width = "full",	--or "half" (optional)
                    --warning = "Will need to reload the UI.",	--(optional)
                },
                [2] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_HIDECURGOLD),
                    tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_HIDECURGOLD_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.hidecurrectgold end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.hidecurrectgold = value
                    SteelswordGoldLogger.updgold()
                    end,
                    default = SteelswordGoldLogger.defaultVars.hidecurrectgold,
                    width = "full",	--or "half" (optional)
                    --warning = "Will need to reload the UI.",	--(optional)
                },--[[
                [3] = { -- Hide Bank Button
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_HIDEBANKBUTTON),
                    tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_HIDEBANKBUTTON_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.hidebankbutton end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.hidebankbutton = value
                    SteelswordGoldLogger.UPDWindowEv()
                    end,
                    default = SteelswordGoldLogger.defaultVars.hidebankbutton,
                    width = "full",	--or "half" (optional)
                    --warning = "Will need to reload the UI.",	--(optional)
                },--]]
                [3] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_AUTOOPENINBANK),
                    tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_AUTOOPENINBANK_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.autoopeninbank end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.autoopeninbank = value
                    end,
                    default = SteelswordGoldLogger.defaultVars.autoopeninbank,
                    width = "full",	--or "half" (optional)
                    --warning = GetString(SI_SGL_SETTINGS_WARNING_UNSTABLE),	--(optional)
                    --disabled = function() return true end
                },
                [4] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS),
                    tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.savetransactions end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.savetransactions = value
                    SteelswordGoldLogger.savedLogsSettingsEVN(value) 
                    end,
                    default = SteelswordGoldLogger.defaultVars.savetransactions,
                    width = "full",	--or "half" (optional)
                    warning = GetString(SI_SGL_SETTINGS_WARNING_UNSTABLE),	--(optional)
                    --disabled = function() return true end
                },
                [5] = {
                    type = "slider",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_SLIDERNAME),
                    tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_SAVETRANSACTIONS_SLIDERNAME_TP),
		            getFunc = function() return SteelswordGoldLogger.savedVars.savetransactions_max end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.savetransactions_max = value end,
                    default = SteelswordGoldLogger.savedVars.savetransactions_max,
                    disabled = function() return not SteelswordGoldLogger.savedVars.savetransactions end,
		            min = 3,
                    max = 40,
                    width = "full",
		            --reference = "MyAddonSlider"
                },
                
            },
        },
        [2] = {
            type = "submenu",
            name = GetString(SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION),
            tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TP),
            controls = {
                [1] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION),
                    tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.stacktransactions end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.stacktransactions = value end,
                    default = SteelswordGoldLogger.defaultVars.stacktransactions,
                    width = "full",	--or "half" (optional)
                    --warning = "Will need to reload the UI.",	--(optional)
                },
                [2] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK),
                    tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.stacktransactions_timecheck end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.stacktransactions_timecheck = value end,
                    default = SteelswordGoldLogger.defaultVars.stacktransactions_timecheck,
                    width = "full",	--or "half" (optional)
                    disabled = function() return not SteelswordGoldLogger.savedVars.stacktransactions end,
                    --warning = "Will need to reload the UI.",	--(optional)
                },
                [3] = {
                    type = "slider",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_SLIDERNAME),
                    tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_SLIDERNAME_TP),
		            getFunc = function() return SteelswordGoldLogger.savedVars.stacktransactions_time end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.stacktransactions_time = value end,
                    default = SteelswordGoldLogger.savedVars.stacktransactions_time,
                    disabled = function()
                            if SteelswordGoldLogger.savedVars.stacktransactions_timecheck and SteelswordGoldLogger.savedVars.stacktransactions then
                            return false
                            else
                            return true
                            end
                        end,
		            min = 1,
                    max = 600,
                    width = "full",
		            --reference = "MyAddonSlider"
                },
                [4] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_COUNTTIME),
                    tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_STACKTRANSACTION_TIMECHECK_COUNTTIME_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.stacktransactions_isnewonly end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.stacktransactions_isnewonly = value end,
                    default = SteelswordGoldLogger.defaultVars.stacktransactions_isnewonly,
                    width = "full",	--or "half" (optional)
                    disabled = function()
                        if SteelswordGoldLogger.savedVars.stacktransactions_timecheck and SteelswordGoldLogger.savedVars.stacktransactions then
                        return false
                        else
                        return true
                        end
                    end,
		            
                    --warning = "Will need to reload the UI.",	--(optional)
                },
                
            },
        },
        [3] = {
            type = "submenu",
            name = GetString(SI_SGL_SETTINGS_CATEGORY_LIMITS),
            tooltip = GetString(SI_SGL_SETTINGS_CATEGORY_LIMITS_TP),
            controls = {
                [1] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_TLIMITS_ENABLE),
                    --tooltip = GetString(SI_SGL_SETTINGS_CATEGORY_LIMITS_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.transactionslimitsenable end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.transactionslimitsenable = value end,
                    default = SteelswordGoldLogger.defaultVars.transactionslimitsenable,
                    width = "full",	--or "half" (optional)
                    --warning = "Will need to reload the UI.",	--(optional)
                },
                [2] = {
                    type = "slider",
                    name = GetString(SI_SGL_SETTINGS_OPTIONS_TLIMITS_SLIDERNAME),
                    tooltip = GetString(SI_SGL_SETTINGS_OPTIONS_TLIMITS_SLIDERNAME_TP),
		            getFunc = function() return SteelswordGoldLogger.savedVars.transactionsminlimit end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.transactionsminlimit = value end,
                    default = SteelswordGoldLogger.savedVars.transactionsminlimit,
                    disabled = function() return not SteelswordGoldLogger.savedVars.transactionslimitsenable end,
		            min = 0,
                    max = 5000,
                    width = "full",
		            --reference = "MyAddonSlider"
                },
                
            },
        },
        [4] = {
            type = "submenu",
            name = GetString(SI_SGL_SETTINGS_CATEGORY_DEBUG),
            tooltip = GetString(SI_SGL_SETTINGS_CATEGORY_DEBUG_TP),	--(optional)
            controls = {
                [1] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_CATEGORY_DEBUG_GREETING),
                    tooltip = GetString(SI_SGL_SETTINGS_CATEGORY_DEBUG_GREETING_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.greetingmes end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.greetingmes = value end,
                    default = SteelswordGoldLogger.defaultVars.greetingmes,
                    width = "full",	--or "half" (optional)
                    --warning = "Will need to reload the UI.",	--(optional)
                },
                [2] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_CATEGORY_DEBUG_MESSAGES),
                    tooltip = GetString(SI_SGL_SETTINGS_CATEGORY_DEBUG_MESSAGES_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.debugmes end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.debugmes = value end,
                    default = SteelswordGoldLogger.defaultVars.debugmes,
                    width = "full",	--or "half" (optional)
                    --warning = "Will need to reload the UI.",	--(optional)
                },
                [3] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_CATEGORY_DEBUG_AOGUI),
                    tooltip = GetString(SI_SGL_SETTINGS_CATEGORY_DEBUG_AOGUI_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.debugautoopengui end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.debugautoopengui = value end,
                    default = SteelswordGoldLogger.defaultVars.debugautoopengui,
                    --disabled = function() return not SteelswordGoldLogger.savedVars.debugmes end,
                    width = "full",	--or "half" (optional)
                    --warning = "Will need to reload the UI.",	--(optional)
                },
                --[[
                [4] = {
                    type = "checkbox",
                    name = GetString(SI_SGL_SETTINGS_CATEGORY_DEBUG_LEGACY_OLDBUTTONS),
                    tooltip = GetString(SI_SGL_SETTINGS_CATEGORY_DEBUG_LEGACY_OLDBUTTONS_TP),
                    getFunc = function() return SteelswordGoldLogger.savedVars.legacybuttons end,
                    setFunc = function(value) SteelswordGoldLogger.savedVars.legacybuttons = value end,
                    default = SteelswordGoldLogger.defaultVars.legacybuttons,
                    --disabled = function() return not SteelswordGoldLogger.savedVars.debugmes end,
                    width = "full",	--or "half" (optional)
                    warning = GetString(SI_SGL_SETTINGS_WARNING_UNSTABLE),	--(optional)
                },--]]
                
            },
        },
        --[[
        [2] = {
            type = "description",
            --title = "My Title",	--(optional)
            title = nil,	--(optional)
            text = "My description text to display. blah blah blah blah blah blah blah - even more sample text!!",
            width = "full",	--or "half" (optional)
        },
        [3] = {
            type = "dropdown",
            name = "My Dropdown",
            tooltip = "Dropdown's tooltip text.",
            choices = {"table", "of", "choices"},
            getFunc = function() return "of" end,
            setFunc = function(var) print(var) end,
            width = "half",	--or "half" (optional)
            warning = "Will need to reload the UI.",	--(optional)
        },
        [4] = {
            type = "dropdown",
            name = "My Dropdown",
            tooltip = "Dropdown's tooltip text.",
            choices = {"table", "of", "choices"},
            getFunc = function() return "of" end,
            setFunc = function(var) print(var) end,
            width = "half",	--or "half" (optional)
            warning = "Will need to reload the UI.",	--(optional)
        },
        [5] = {
            type = "slider",
            name = "My Slider",
            tooltip = "Slider's tooltip text.",
            min = 0,
            max = 20,
            step = 1,	--(optional)
            getFunc = function() return 3 end,
            setFunc = function(value) d(value) end,
            width = "half",	--or "half" (optional)
            default = 5,	--(optional)
        },
        [6] = {
            type = "button",
            name = "My Button",
            tooltip = "Button's tooltip text.",
            func = function() d("button pressed!") end,
            width = "half",	--or "half" (optional)
            warning = "Will need to reload the UI.",	--(optional)
        },
        [7] = {
            type = "submenu",
            name = "Submenu Title",
            tooltip = "My submenu tooltip",	--(optional)
            controls = {
                [1] = {
                    type = "checkbox",
                    name = "My Checkbox",
                    tooltip = "Checkbox's tooltip text.",
                    getFunc = function() return true end,
                    setFunc = function(value) d(value) end,
                    width = "half",	--or "half" (optional)
                    warning = "Will need to reload the UI.",	--(optional)
                },
                [2] = {
                    type = "colorpicker",
                    name = "My Color Picker",
                    tooltip = "Color Picker's tooltip text.",
                    getFunc = function() return 1, 0, 0, 1 end,	--(alpha is optional)
                    setFunc = function(r,g,b,a) print(r, g, b, a) end,	--(alpha is optional)
                    width = "half",	--or "half" (optional)
                    warning = "warning text",
                },
                [3] = {
                    type = "editbox",
                    name = "My Editbox",
                    tooltip = "Editbox's tooltip text.",
                    getFunc = function() return "this is some text" end,
                    setFunc = function(text) print(text) end,
                    isMultiline = false,	--boolean
                    width = "half",	--or "half" (optional)
                    warning = "Will need to reload the UI.",	--(optional)
                    default = "",	--(optional)
                },
            },
        },
        [8] = {
            type = "custom",
            reference = "MyAddonCustomControl",	--unique name for your control to use as reference
            refreshFunc = function(customControl) end,	--(optional) function to call when panel/controls refresh
            width = "half",	--or "half" (optional)
        },
        [9] = {
            type = "texture",
            image = "EsoUI\\Art\\ActionBar\\abilityframe64_up.dds",
            imageWidth = 64,	--max of 250 for half width, 510 for full
            imageHeight = 64,	--max of 100
            tooltip = "Image's tooltip text.",	--(optional)
            width = "half",	--or "half" (optional)
        },
        --]]
    }
    

    LAM:RegisterAddonPanel("SteelswordGoldLogger_settings", panelData)
    LAM:RegisterOptionControls("SteelswordGoldLogger_settings", optionsTable)
end