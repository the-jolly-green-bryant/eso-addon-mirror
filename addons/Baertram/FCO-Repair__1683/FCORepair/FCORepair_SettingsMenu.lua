if FCORep == nil then FCORep = {} end
local FCORep = FCORep

--===================== LAM Settings menu ==============================================

-- Build the options menu
function FCORep.BuildAddonMenu()
    local addonVars = FCORep.addonVars
    local panelData = {
        type 				= 'panel',
        name 				= addonVars.addonNameMenu,
        displayName 		= addonVars.addonNameMenuDisplay,
        author 				= addonVars.addonAuthor,
        version 			= addonVars.addonVersionOptions,
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand = "/FCOReps",
    }

    local FCORepSettings        = FCORep.settingsVars.settings
    local FCORepDefaultSettings = FCORep.settingsVars.defaults
    local FCORepLoc             = FCORep.localizationVars.FCORep_loc

    -- !!! RU Patch Section START
    --  Add english language description behind language descriptions in other languages
    local function nvl(val) if val == nil then return "..." end return val end
    local LV_Cur = FCORepLoc
    local LV_Eng = FCORep.localizationVars.localizationAll[1]
    local languageOptions = {}
    for i=1, FCORep.numVars.languageCount do
        local s="options_language_dropdown_selection"..i
        if LV_Cur==LV_Eng then
            languageOptions[i] = nvl(LV_Cur[s])
        else
            languageOptions[i] = nvl(LV_Cur[s]) .. " (" .. nvl(LV_Eng[s]) .. ")"
        end
    end
    -- !!! RU Patch Section END

    local savedVariablesOptions = {
        [1] = FCORepLoc["options_savedVariables_dropdown_selection1"],
        [2] = FCORepLoc["options_savedVariables_dropdown_selection2"],
    }

    local dropdownSortHeaderEquipped = {
        [1] = FCORepLoc["options_sort_sortheader_default_off"],
        [2] = FCORepLoc["options_sort_sortheader_default_equipped"],
        [3] = FCORepLoc["options_sort_sortheader_default_nonequipped"],
    }
    local dropdownSortHeaderEquippedValues = {
        [1] = 0,
        [2] = 1,
        [3] = 2,
    }

    FCORep.FCOSettingsPanel = FCORep.LAM:RegisterAddonPanel(addonVars.gAddonName .. "_LAM", panelData)

    local optionsTable =
    {   -- BEGIN OF OPTIONS TABLE
        {
            type = 'description',
            text = FCORepLoc["options_description"],
        },

        --==============================================================================
        {
            type = 'header',
            name = FCORepLoc["options_header1"],
        },
        {
            type = 'dropdown',
            name = FCORepLoc["options_language"],
            tooltip = FCORepLoc["options_language_tooltip"],
            choices = languageOptions,
            getFunc = function() return languageOptions[FCORep.settingsVars.defaultSettings.language] end,
            setFunc = function(value)
                for i,v in pairs(languageOptions) do
                    if v == value then
                        FCORep.settingsVars.defaultSettings.language = i
                        --Tell the FCORepSettings that you have manually chosen the language and want to keep it
                        --Read in function Localization() after ReloadUI()
                        FCORepSettings.languageChoosen = true
                        --FCORepLoc			  	 = FCORepLoc[i]
                        --ReloadUI()
                    end
                end
            end,
            disabled = function() return FCORepSettings.alwaysUseClientLanguage end,
            warning = FCORepLoc["options_language_description1"],
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = FCORepLoc["options_language_use_client"],
            tooltip = FCORepLoc["options_language_use_client_tooltip"],
            getFunc = function() return FCORepSettings.alwaysUseClientLanguage end,
            setFunc = function(value)
                FCORepSettings.alwaysUseClientLanguage = value
                --ReloadUI()
            end,
            default = FCORepDefaultSettings.alwaysUseClientLanguage,
            warning = FCORepLoc["options_language_description1"],
            requiresReload = true,
        },
        {
            type = 'dropdown',
            name = FCORepLoc["options_savedvariables"],
            tooltip = FCORepLoc["options_savedvariables_tooltip"],
            choices = savedVariablesOptions,
            getFunc = function() return savedVariablesOptions[FCORep.settingsVars.defaultSettings.saveMode] end,
            setFunc = function(value)
                for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        FCORep.settingsVars.defaultSettings.saveMode = i
                    end
                end
            end,
            warning = FCORepLoc["options_language_description1"],
            requiresReload = true,
        },
        --==============================================================================
        {
            type = 'header',
            name = FCORepLoc["options_header_repair"],
        },
        {
            type = 'submenu',
            name = FCORepLoc["options_header_repair_condition"],
            controls = {
                {
                    type = "checkbox",
                    name = FCORepLoc["options_repair_condition_colorize"],
                    tooltip = FCORepLoc["options_repair_condition_colorize_tooltip"],
                    getFunc = function() return FCORepSettings.colorizeCondition end,
                    setFunc = function(value) FCORepSettings.colorizeCondition = value
                    end,
                    default = FCORepDefaultSettings.colorizeCondition,
                    width="full",
                },
                {
                    type = 'submenu',
                    name = FCORepLoc["options_repair_condition_value_high"],
                    controls = {
                        {
                            type = "slider",
                            min = 2,
                            max = 100,
                            name = FCORepLoc["options_repair_condition_threshold"],
                            tooltip = FCORepLoc["options_repair_condition_threshold"],
                            getFunc = function() return FCORepSettings.condition.high.value end,
                            setFunc = function(value) FCORepSettings.condition.high.value = value
                            end,
                            width="half",
                            default = FCORepDefaultSettings.condition.high.value,
                            disabled = function() return not FCORepSettings.colorizeCondition end,
                            --reference = "FCORepair_LAM_Slider_Condition_High",
                        },
                        {
                            type = "colorpicker",
                            name = FCORepLoc["options_repair_condition_color"],
                            tooltip = FCORepLoc["options_repair_condition_color"],
                            getFunc = function() return FCORepSettings.condition.high.color.r, FCORepSettings.condition.high.color.g, FCORepSettings.condition.high.color.b, FCORepSettings.condition.high.color.a end,
                            setFunc = function(r,g,b,a)
                                FCORepSettings.condition.high.color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
                            end,
                            width="half",
                            default = FCORepDefaultSettings.condition.high.color,
                            disabled = function() return not FCORepSettings.colorizeCondition end,
                        },

                    }, -- controls high
                    disabled = function() return not FCORepSettings.colorizeCondition end,
                }, -- submenu high
                {
                    type = 'submenu',
                    name = FCORepLoc["options_repair_condition_value_medium"],
                    controls = {
                        {
                            type = "slider",
                            min = 1,
                            max = 99,
                            name = FCORepLoc["options_repair_condition_threshold"],
                            tooltip = FCORepLoc["options_repair_condition_threshold"],
                            getFunc = function() return FCORepSettings.condition.medium.value end,
                            setFunc = function(value) FCORepSettings.condition.medium.value = value
                            end,
                            width="half",
                            default = FCORepDefaultSettings.condition.medium.value,
                            disabled = function() return not FCORepSettings.colorizeCondition end,
                            --reference = "FCORepair_LAM_Slider_Condition_Medium",
                        },
                        {
                            type = "colorpicker",
                            name = FCORepLoc["options_repair_condition_color"],
                            tooltip = FCORepLoc["options_repair_condition_color"],
                            getFunc = function() return FCORepSettings.condition.medium.color.r, FCORepSettings.condition.medium.color.g, FCORepSettings.condition.medium.color.b, FCORepSettings.condition.medium.color.a end,
                            setFunc = function(r,g,b,a)
                                FCORepSettings.condition.medium.color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
                            end,
                            width="half",
                            default = FCORepDefaultSettings.condition.medium.color,
                            disabled = function() return not FCORepSettings.colorizeCondition end,
                        },

                    }, -- controls medium
                    disabled = function() return not FCORepSettings.colorizeCondition end,
                }, --submenu medium
                {
                    type = 'submenu',
                    name = FCORepLoc["options_repair_condition_value_low"],
                    controls = {
    --[[
                        {
                            type = "slider",
                            min = 0,
                            max = 100,
                            name = FCORepLoc["options_repair_condition_threshold"],
                            tooltip = FCORepLoc["options_repair_condition_threshold"],
                            getFunc = function() return FCORepSettings.condition.low.value end,
                            setFunc = function(value) FCORepSettings.condition.low.value = value
                            end,
                            width="half",
                            default = FCORepDefaultSettings.condition.low.value,
                            disabled = function() return not FCORepSettings.colorizeCondition end,
                        },
]]
                        {
                            type = "colorpicker",
                            name = FCORepLoc["options_repair_condition_color"],
                            tooltip = FCORepLoc["options_repair_condition_color"],
                            getFunc = function() return FCORepSettings.condition.low.color.r, FCORepSettings.condition.low.color.g, FCORepSettings.condition.low.color.b, FCORepSettings.condition.low.color.a end,
                            setFunc = function(r,g,b,a)
                                FCORepSettings.condition.low.color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
                            end,
                            width="half",
                            default = FCORepDefaultSettings.condition.low.color,
                            disabled = function() return not FCORepSettings.colorizeCondition end,
                        },

                    }, -- controls low
                    disabled = function() return not FCORepSettings.colorizeCondition end,
                }, -- submenu low

            }, -- controls condition
        }, -- submenu condition
        --==============================================================================
        {
            type = 'submenu',
            name = FCORepLoc["options_header_repair_name"],
            controls = {
                {
                    type = "checkbox",
                    name = FCORepLoc["options_repair_name_brackets"],
                    tooltip = FCORepLoc["options_repair_name_brackets_tooltip"],
                    getFunc = function() return FCORepSettings.addBracketsAroundName end,
                    setFunc = function(value) FCORepSettings.addBracketsAroundName = value
                    end,
                    default = FCORepDefaultSettings.addBracketsAroundName,
                    width="full",
                },
            }, -- controls name
        }, -- submenu name
        --==============================================================================
        {
            type = 'header',
            name = FCORepLoc["options_header_sort"],
        },
        {
            type = 'submenu',
            name = FCORepLoc["options_sort_add_sortheader_text"],
            controls = {
                {
                    type = "checkbox",
                    name = FCORepLoc["options_sort_add_sortheader"],
                    tooltip = FCORepLoc["options_sort_add_sortheader_tooltip"],
                    getFunc = function() return FCORepSettings.addEquippedSort end,
                    setFunc = function(value) FCORepSettings.addEquippedSort = value
                    end,
                    default = FCORepDefaultSettings.addEquippedSort,
                    width="full",
                    requiresReload = true,
                },
                {
                    type = "dropdown",
                    choices         = dropdownSortHeaderEquipped,
                    choicesValues   = dropdownSortHeaderEquippedValues,
                    name = FCORepLoc["options_sort_sortheader_default"],
                    tooltip = FCORepLoc["options_sort_sortheader_default_tooltip"],
                    getFunc = function() return FCORepSettings.defaultEquippedSort end,
                    setFunc = function(value) FCORepSettings.defaultEquippedSort = value end,
                    default = FCORepDefaultSettings.defaultEquippedSort,
                    width="full",
                    disabled = function() return not FCORepSettings.addEquippedSort end,
                },
            }, -- controls sort header
        }, -- submenu sort header

    } -- END OF OPTIONS TABLE

    FCORep.LAM:RegisterOptionControls(addonVars.gAddonName .. "_LAM", optionsTable)
end