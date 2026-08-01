if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

local CM = CALLBACK_MANAGER

------------------------------------------------------------------------------------------------------------
-- LibAddonMenu (LAM) Settings panel
------------------------------------------------------------------------------------------------------------
function FCOSS.buildAddonMenu()
    if FCOSS.addonMenu == nil then return nil end
    --Local "speed up arrays/tables" variables
    local addonVars =       FCOSS.addonVars
    local settings =        FCOSS.settingsVars.settings
    local defaults =        FCOSS.settingsVars.defaults

    FCOSS.panelData    = {
        type                = "panel",
        name                = addonVars.settingsName,
        displayName         = addonVars.settingsDisplayName,
        author              = addonVars.addonAuthor,
        version             = tostring(addonVars.addonRealVersion),
        registerForRefresh  = true,
        registerForDefaults = true,
        slashCommand 		= "/fcosss",
        website             = addonVars.addonWebsite
    }

    --Are other addons loaded?
    FCOSS.checkIfOtherAddonsAreActive()
    local isAutoSlotSwitchLoaded = FCOSS.otherAddons.autoSlotSwitch["isLoaded"]

    -- !!! RU Patch Section START
    --  Add english language description behind language descriptions in other languages
    local function nvl(val) if val == nil then return "..." end return val end
    local LV_Cur = FCOSS.localizationVars.fco_ss_loc
    local LV_Eng = FCOSS.localizationVars.localizationAll[1]
    local languageOptions = {}
    local languageOptionsValues = {}
    for i=1, FCOSS.numVars.languageCount do
        local s="options_language_dropdown_selection"..i
        if LV_Cur==LV_Eng then
            languageOptions[i] = nvl(LV_Cur[s])
        else
            languageOptions[i] = nvl(LV_Cur[s]) .. " (" .. nvl(LV_Eng[s]) .. ")"
        end
        languageOptionsValues[i] = i
    end
    -- !!! RU Patch Section END

    local fcoSSLocVars = FCOSS.localizationVars.fco_ss_loc

    local savedVariablesOptions = {
        [1] = fcoSSLocVars["options_savedVariables_dropdown_selection1"],
        [2] = fcoSSLocVars["options_savedVariables_dropdown_selection2"],
    }
    local savedVariablesOptionsValues = {
        [1] = 1,
        [2] = 2,
    }

    local texturesList = {}
    for i=1, #FCOSS.iconTextures, 1 do
        table.insert(texturesList, tostring(i))
    end

    --Build the dropdown lists for the quickslots etc.
    FCOSS.BuildQuickSlotsSettings()

    local alertCheckEvents = {
        [1] = fcoSSLocVars["options_alert_check_event_pvp"],
        [2] = fcoSSLocVars["options_alert_check_event_pvp_group"],
        [3] = fcoSSLocVars["options_alert_check_event_pvp_raid"],
        [4] = fcoSSLocVars["options_alert_check_event_pve"],
        [5] = fcoSSLocVars["options_alert_check_event_pve_group"],
        [6] = fcoSSLocVars["options_alert_check_event_pve_raid"],
        [7] = fcoSSLocVars["options_alert_check_event_group"],
        [8] = fcoSSLocVars["options_alert_check_event_raid"],
        [9] = fcoSSLocVars["options_alert_check_event_everywhere"],
    }
    local alertCheckDungeons = {
        [1] = fcoSSLocVars["options_alert_check_event_dungeon_delve"],
        [2] = fcoSSLocVars["options_alert_check_event_dungeon_public"],
        [3] = fcoSSLocVars["options_alert_check_event_dungeon_group"],
        [4] = fcoSSLocVars["options_alert_check_event_dungeon_raid"],
        [5] = fcoSSLocVars["options_alert_check_event_dungeon_all"],
        [6] = fcoSSLocVars["options_alert_check_event_dungeon_everywhere"],
    }

    --Addon panels were refreshed
    local function addonMenuOnRefreshCallback(panel)
        if panel == FCOSS.addonMenuPanel then
            FCOSS.updateQuickslotsSettingsDropdown()
        end
    end

    --Addon panels were loaded
    FCOSS.activeDropdown = nil
    local function addonMenuOnLoadCallback(panel)
        if panel == FCOSS.addonMenuPanel then
            --UnRegister the callback for the LAM2 panel created function
            CM:UnregisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)
            --Set the text for the selected food buff AlertSound label
            FCOStarveStop_Settings_AlertSound.label:SetText(fcoSSLocVars["options_alert_sound"] .. ": " .. FCOSS.sounds[settings.alertSound])
            --Set the text for the selected potion AlertSound label
            FCOStarveStop_Settings_AlertSoundPotion.label:SetText(fcoSSLocVars["options_alert_sound"] .. ": " .. FCOSS.sounds[settings.alertSoundPotion])

            --Fill FCOSS.quickSlots and FCOSS.quickSlotsMapping tables with data
            FCOSS.updateQuickslotsSettingsDropdown()

            --Alowed dropdowns in the LAM2 settings menu
            local dropdownWithTooltip = {
                FCOStarveStop_Settings_PvE_Select,
                FCOStarveStop_Settings_PvE_Combat_Select,
                FCOStarveStop_Settings_PvP_Select,
                FCOStarveStop_Settings_PvP_Combat_Select,
                FCOStarveStop_Settings_Delve_PvE_Select,
                FCOStarveStop_Settings_Delve_PvP_Combat_Select,
                FCOStarveStop_Settings_Delve_PvP_Select,
                FCOStarveStop_Settings_Delve_PvP_Combat_Select,
                FCOStarveStop_Settings_PublicDungeon_PvE_Select,
                FCOStarveStop_Settings_PublicDungeon_PvE_Combat_Select,
                FCOStarveStop_Settings_PublicDungeon_PvP_Select,
                FCOStarveStop_Settings_PublicDungeon_PvP_Combat_Select,
                FCOStarveStop_Settings_GroupDungeon_PvE_Select,
                FCOStarveStop_Settings_GroupDungeon_PvE_Combat_Select,
                FCOStarveStop_Settings_GroupDungeon_PvP_Select,
                FCOStarveStop_Settings_GroupDungeon_PvP_Combat_Select,
                FCOStarveStop_Settings_RaidDungeon_PvE_Select,
                FCOStarveStop_Settings_RaidDungeon_PvE_Combat_Select,
                FCOStarveStop_Settings_RaidDungeon_PvP_Select,
                FCOStarveStop_Settings_RaidDungeon_PvP_Combat_Select,
                FCOStarveStop_Settings_FoodBuff_PvE_Select,
                FCOStarveStop_Settings_FoodBuff_PvP_Select,
            }
            --For each allowed combobox/dropdown in the LAM2 settings do
            for i = 1, #dropdownWithTooltip do
                local dropdown = dropdownWithTooltip[i].dropdown
                ZO_PreHook(dropdown, "SetVisible", function(self, visible)
                    if(visible) then
                        FCOSS.activeDropdown = self
                    else
                        FCOSS.activeDropdown = nil
                    end
                end)
            end -- for ...

            --Show tooltips in LAM2's dropdown menus, if the dropdown box is allowed
            ZO_PreHook("ZO_Menu_SetSelectedIndex", function(index)
--d("ZO_Menu_SetSelectedIndex - FCOSS.activeDropdown: " ..tostring(FCOSS.activeDropdown:GetName()))
                if(not FCOSS.activeDropdown) then return end
                ClearTooltip(ItemTooltip)
                if(not index or not ZO_Menu.items) then return end
--d(">1")
                index = zo_max(zo_min(index, #ZO_Menu.items), 1)
--d(">index: " ..tostring(index))

                local qsItemLink = GetSlotItemLink(FCOSS.quickSlotsMapping[index], HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
                if qsItemLink ~= "" then
                    local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
                    if not mouseOverControl then return false end
                    InitializeTooltip(ItemTooltip, mouseOverControl, TOPLEFT, 0, 0, BOTTOMRIGHT)
                    ItemTooltip:SetLink(qsItemLink)
                    ItemTooltipTopLevel:BringWindowToTop()
                end
            end)

            --Register the callback for the LAM panel refresh function
            CM:RegisterCallback("LAM-RefreshPanel", addonMenuOnRefreshCallback)
        end -- if panel == FCOSS.addonMenuPanel then
    end -- local function addonMenuOnLoadCallback(panel)
    --Register the callback for the LAM panel created function
    CM:RegisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)

    local function addonMenuOnPanelOpenedCallback(...)
        FCOSS.addonMenu.isShown = true
    end
    --Register the callback for the LAM panel opened function
    CM:RegisterCallback("LAM-PanelOpened", addonMenuOnPanelOpenedCallback)
    local function addonMenuOnPanelClosedCallback(...)
        FCOSS.addonMenu.isShown = false
        --Check 1 second later if any other panel is shown -> If not: LAM is closed!
        zo_callLater(function()
            if FCOSS.addonMenu.isShown then return false end
            --Check if the potion alert should be shown
            --But only if the LAM menu is closed!
            FCOSS.checkIfPotionAlertNeedsToBeShown()
        end, 1000)
    end
    --Register the callback for the LAM panel closed function
    CM:RegisterCallback("LAM-PanelClosed", addonMenuOnPanelClosedCallback)

    --The options panel data for the LAM settings of this addon
    FCOSS.optionsData  = {
        {
            type              = "description",
            text              = fcoSSLocVars["options_description"],
        },

        --==============================================================================
        {
            type = 'header',
            name = fcoSSLocVars["options_header1"],
        },
        {
            type = 'dropdown',
            name = fcoSSLocVars["options_language"],
            tooltip = fcoSSLocVars["options_language_tooltip"],
            choices = languageOptions,
            choicesValues = languageOptionsValues,
            getFunc = function() return FCOSS.settingsVars.defaultSettings.language end,
            setFunc = function(value)
                --[[
                for i,v in pairs(languageOptions) do
                    if v == value then
                        FCOSS.settingsVars.defaultSettings.language = i
                        --Tell the settings that you have manually chosen the language and want to keep it
                        --Read in function Localization() after ReloadUI()
                        settings.languageChoosen = true
                        ReloadUI()
                    end
                end
                ]]
                FCOSS.settingsVars.defaultSettings.language = value
                settings.languageChoosen = true
                ReloadUI()
            end,
            disabled = function() return settings.alwaysUseClientLanguage end,
            warning = fcoSSLocVars["options_language_description1"],
        },
        {
            type = "checkbox",
            name = fcoSSLocVars["options_language_use_client"],
            tooltip = fcoSSLocVars["options_language_use_client_tooltip"],
            getFunc = function() return settings.alwaysUseClientLanguage end,
            setFunc = function(value)
                settings.alwaysUseClientLanguage = value
                ReloadUI()
            end,
            default = defaults.alwaysUseClientLanguage,
            warning = fcoSSLocVars["options_language_description1"],
        },
        {
            type = 'dropdown',
            name = fcoSSLocVars["options_savedvariables"],
            tooltip = fcoSSLocVars["options_savedvariables_tooltip"],
            choices = savedVariablesOptions,
            choicesValues = savedVariablesOptionsValues,
            getFunc = function() return FCOSS.settingsVars.defaultSettings.saveMode end,
            setFunc = function(value)
                --[[
                for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        FCOSS.settingsVars.defaultSettings.saveMode = i
                        ReloadUI()
                    end
                end
                ]]
                FCOSS.settingsVars.defaultSettings.saveMode = value
                ReloadUI()
            end,
            warning = fcoSSLocVars["options_language_description1"],
        },
        {
            type = 'description',
            text = fcoSSLocVars["options_language_description1"],
        },
        --==============================================================================
        -- FOOD BUFF
        {
            type = 'header',
            name = fcoSSLocVars["options_header_food_buff"],
        },
        {
            type              = "checkbox",
            name              = fcoSSLocVars["options_alert_on_login_enabled"],
            tooltip           = fcoSSLocVars["options_alert_on_login_enabled_tooltip"],
            getFunc           = function() return settings.alertOnLogin end,
            setFunc           = function(value) settings.alertOnLogin = value end,
            default = defaults.alertOnLogin
        },

        {
            type = "slider",
            name = fcoSSLocVars["options_alert_check_repeat"],
            tooltip = fcoSSLocVars["options_alert_check_repeat_tooltip"],
            min = 0,
            max = 3600,
            getFunc = function() return settings.alertRepeatSeconds end,
            setFunc = function(seconds)
                settings.alertRepeatSeconds = seconds
                FCOSS.setupAlertRepeat(seconds, settings.alertRepeatChatOutput, false)
            end,
            width="full",
            default = defaults.alertRepeatSeconds,
        },

        {
            type = 'dropdown',
            name = fcoSSLocVars["options_alert_check_event"],
            tooltip = fcoSSLocVars["options_alert_check_event_tooltip"],
            choices = alertCheckEvents,
            getFunc = function() return alertCheckEvents[settings.alertCheckEvent] end,
            setFunc = function(value)
                for i,v in pairs(alertCheckEvents) do
                    if v == value then
                        settings.alertCheckEvent = i
                    end
                end
            end,
            default = alertCheckEvents[settings.alertCheckEvent],
        },

        {
            type = 'dropdown',
            name = fcoSSLocVars["options_alert_check_event_dungeon"],
            tooltip = fcoSSLocVars["options_alert_check_event_dungeon_tooltip"],
            choices = alertCheckDungeons,
            getFunc = function() return alertCheckDungeons[settings.alertCheckDungeons] end,
            setFunc = function(value)
                for i,v in pairs(alertCheckDungeons) do
                    if v == value then
                        settings.alertCheckDungeons = i
                    end
                end
            end,
            default = alertCheckDungeons[settings.alertCheckDungeons],
        },

        {
            type = "slider",
            name = fcoSSLocVars["options_alert_check_warning_before_expire"],
            tooltip = fcoSSLocVars["options_alert_check_warning_before_expire_tooltip"],
            min = 0,
            max = 125,
            getFunc = function() return settings.showWarningBeforeExpiration end,
            setFunc = function(minutes)
                settings.showWarningBeforeExpiration = minutes
                if minutes > 0 then
                    --Prevent the chat output for active food buff as it will be shown with the repeat timer
                    FCOSS.preventerVars.setupWarningBeforeExpirationRepeat = true
                    --Override the buff food check to restart the warning timer, and suppress chat and alert text + icon
                    FCOSS.checkForExistingBuffFood(nil, settings.alertRepeatChatOutput)
                    --Allow the chat output for active food buff again
                    FCOSS.preventerVars.setupWarningBeforeExpirationRepeat = false
                else
                    FCOSS.setupWarningBeforeExpirationRepeat(true, nil, nil, nil, nil, nil, nil)
                end
            end,
            width="full",
            default = defaults.showWarningBeforeExpiration,
        },

        {
            type = "slider",
            name = fcoSSLocVars["options_alert_check_warning_before_expire_repeat"],
            tooltip = fcoSSLocVars["options_alert_check_warning_before_expire_repeat_tooltip"],
            min = 5,
            max = 600,
            getFunc = function() return settings.showWarningBeforeExpirationRepeat end,
            setFunc = function(seconds)
                settings.showWarningBeforeExpirationRepeat = seconds
                --Prevent the chat output for active food buff as it will be shown with the repeat timer
                FCOSS.preventerVars.setupWarningBeforeExpirationRepeat = true
                --Override the buff food check to restart the warning timer, and suppress chat and alert text + icon
                FCOSS.checkForExistingBuffFood(nil, settings.alertRepeatChatOutput)
                --Allow the chat output for active food buff again
                FCOSS.preventerVars.setupWarningBeforeExpirationRepeat = false
            end,
            width="full",
            default = defaults.showWarningBeforeExpirationRepeat,
            disabled = function() return settings.showWarningBeforeExpiration <= 0 end,
        },

        {
            type              = "checkbox",
            name              = fcoSSLocVars["options_alert_only_not_in_house"],
            tooltip           = fcoSSLocVars["options_alert_only_not_in_house_tooltip"],
            getFunc           = function() return settings.alertNotInHouse end,
            setFunc           = function(value)
                settings.alertNotInHouse = value
                if value == true then
                    --Check if the food buff alert icon is shown and hide it, if in a house
                    FCOSS.checkAndHideAlertIconInHouse()
                    --Check if the potion alert icon is shown and hide it, if in a house
                    FCOSS.checkAndHidePotionAlertIconInHouse()
                end
            end,
            default = defaults.alertNotInHouse
        },

        {
            type              = "checkbox",
            name              = fcoSSLocVars["options_alert_check_repeat_chat_output_consumed"],
            tooltip           = fcoSSLocVars["options_alert_check_repeat_chat_output_consumed_tooltip"],
            getFunc           = function() return settings.chatOutputConsumedNamed end,
            setFunc           = function(value)
                settings.chatOutputConsumedNamed = value
            end,
            default = defaults.chatOutputConsumedNamed
        },
        {
            type              = "checkbox",
            name              = fcoSSLocVars["options_alert_check_repeat_chat_output"],
            tooltip           = fcoSSLocVars["options_alert_check_repeat_chat_output_tooltip"],
            getFunc           = function() return settings.alertRepeatChatOutput end,
            setFunc           = function(value)
                settings.alertRepeatChatOutput = value
                FCOSS.setupAlertRepeat(settings.alertRepeatSeconds, value, false)
            end,
            default = defaults.alertRepeatChatOutput
        },
        {
            type              = "checkbox",
            name              = fcoSSLocVars["options_alert_check_repeat_chat_output_only_negative"],
            tooltip           = fcoSSLocVars["options_alert_check_repeat_chat_output_only_negative_tooltip"],
            getFunc           = function() return settings.alertRepeatChatOutputOnlyWithoutFoodBuff end,
            setFunc           = function(value)
                settings.alertRepeatChatOutputOnlyWithoutFoodBuff = value
            end,
            disabled = function() return not settings.alertRepeatChatOutput end,
            default = defaults.alertRepeatChatOutputOnlyWithoutFoodBuff
        },

        {
            type = "button",
            name = fcoSSLocVars["options_alert_test"],
            tooltip = fcoSSLocVars["options_alert_test_tooltip"],
            func = function()
                local testAlertButton = WINDOW_MANAGER:GetControlByName("FCOStarveStop_Button_Test_Alerts", "")
                if testAlertButton then
                    FCOSS.preventerVars.disableTestAlertButton = true
                end
                local delay = 0
                local noTextSoFar = true
                local chatOutput = settings.alertRepeatChatOutput
                if settings.textAlert and settings.textAlertDrink and settings.textAlertDrink ~= "" then
                    FCOSS.alertNow("Drink", chatOutput, true)
                    noTextSoFar = false
                end
                if settings.textAlert and settings.textAlertFood and settings.textAlertFood ~= "" then
                    delay = delay + 3500
                    if noTextSoFar then
                        delay = 0
                    end
                    zo_callLater(function() FCOSS.alertNow("Food", chatOutput, true) end, delay)
                    noTextSoFar = false
                end
                if settings.iconAlert and noTextSoFar then
                    delay = delay + 3500
                    if noTextSoFar then
                        delay = 0
                    end
                    zo_callLater(function() FCOSS.alertNow("n/a", chatOutput, true) end, delay)
                    noTextSoFar = false
                end
                --Show the potion alert test
                if settings.potionAlert then
                    delay = delay + 3500
                    if noTextSoFar then
                        delay = 0
                    end
                    zo_callLater(function() FCOSS.showPotionAlert(true, true) end, delay)
                end
                if testAlertButton then
                    zo_callLater(function()
                        FCOSS.preventerVars.disableTestAlertButton = false
                        --Update the LAM panel controls to enable the test alert button again
                        CM:FireCallbacks("LAM-RefreshPanel", FCOSS.addonMenuPanel)
                    end, delay + 2000)
                end
            end,
            width = "full",
            disabled = function()
                if FCOSS.preventerVars.disableTestAlertButton==true or
                        ((not settings.textAlert and not settings.iconAlert) or settings.alertSound == 1) or                -- Food/Drink alerts
                        ((not settings.textAlertPotion and not settings.iconAlertPotion) or settings.alertSoundPotion == 1) -- Potion alerts
                then
                    return true
                end
                return false
            end,
            reference = "FCOStarveStop_Button_Test_Alerts",
        },

        -- POTIONS
        {
            type = 'header',
            name = fcoSSLocVars["options_header_potion"],
        },

        {
            type              = "checkbox",
            name              = fcoSSLocVars["options_potion_alert"],
            tooltip           = fcoSSLocVars["options_potion_alert_tooltip"],
            getFunc           = function() return settings.potionAlert end,
            setFunc           = function(value) settings.potionAlert = value end,
            default = defaults.potionAlert
        },
        {
            type              = "checkbox",
            name              = fcoSSLocVars["options_potion_alert_only_in_combat"],
            tooltip           = fcoSSLocVars["options_potion_alert_only_in_combat_tooltip"],
            getFunc           = function() return settings.potionAlertOnlyInCombat end,
            setFunc           = function(value) settings.potionAlertOnlyInCombat = value end,
            default = defaults.potionAlertOnlyInCombat,
            disabled          = function() return not settings.potionAlert end,
        },

        --==============================================================================
        {
            type = "submenu",
            name = fcoSSLocVars["options_header_text_alert"],
            controls = {
                --Alert text for food buff
                {
                    type = 'header',
                    name = fcoSSLocVars["options_header_food_buff"],
                },
                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_text_alert_enabled"],
                    tooltip           = fcoSSLocVars["options_text_alert_enabled_tooltip"],
                    getFunc           = function() return settings.textAlert end,
                    setFunc           = function(value) settings.textAlert = value end,
                    default = defaults.textAlert
                },

                {
                    type              = "editbox",
                    name              = fcoSSLocVars["options_text_alert_food_text"],
                    tooltip           = fcoSSLocVars["options_text_alert_food_text_tooltip"],
                    getFunc           = function() return settings.textAlertFood end,
                    setFunc           = function(textVar)
                        settings.textAlertFood = textVar
                        FCOSS.alertTextFood = ""
                    end,
                    disabled          = function() return not settings.textAlert end,
                    default = defaults.textAlertFood
                },

                {
                    type              = "editbox",
                    name              = fcoSSLocVars["options_text_alert_drink_text"],
                    tooltip           = fcoSSLocVars["options_text_alert_drink_text_tooltip"],
                    getFunc           = function() return settings.textAlertDrink end,
                    setFunc           = function(textVar)
                        settings.textAlertDrink = textVar
                        FCOSS.alertTextDrink = ""
                    end,
                    disabled          = function() return not settings.textAlert end,
                    default = defaults.textAlertDrink
                },


                {
                    type              = "editbox",
                    name              = fcoSSLocVars["options_text_alert_general_text"],
                    tooltip           = fcoSSLocVars["options_text_alert_general_text_tooltip"],
                    getFunc           = function() return settings.textAlertGeneral end,
                    setFunc           = function(textVar)
                        settings.textAlertGeneral = textVar
                        FCOSS.alertTextGeneral = ""
                        settings.textAlertGeneralChanged = true
                    end,
                    disabled          = function() return not settings.textAlert end,
                    default           = fcoSSLocVars["icon_tooltip_text"],
                },

                --Alert text for potions
                {
                    type = 'header',
                    name = fcoSSLocVars["options_header_potion"],
                },
                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_potion_text_alert_enabled"],
                    tooltip           = fcoSSLocVars["options_potion_text_alert_enabled_tooltip"],
                    getFunc           = function() return settings.textAlertPotion end,
                    setFunc           = function(value) settings.textAlertPotion = value end,
                    default = defaults.textAlertPotion,
                    disabled          = function() return not settings.potionAlert end,
                },

                {
                    type              = "editbox",
                    name              = fcoSSLocVars["options_potion_text_alert_text"],
                    tooltip           = fcoSSLocVars["options_potion_text_alert_text_tooltip"],
                    getFunc           = function() return settings.textAlertGeneralPotion end,
                    setFunc           = function(textVar)
                        settings.textAlertGeneralPotion = textVar
                        FCOSS.alertTextGeneralPotion = ""
                        settings.textAlertGeneralChangedPotion = true
                    end,
                    default           = fcoSSLocVars["icon_tooltip_potion_text"],
                    disabled          = function() return not settings.potionAlert or not settings.textAlertPotion end,
                },

            }, -- controls submenu alert text
        },  -- submenu alert text
        {
            type = "submenu",
            name = fcoSSLocVars["options_header_icon_alert"],
            controls = {
                --Alert icon for food buff
                {
                    type = 'header',
                    name = fcoSSLocVars["options_header_food_buff"],
                },
                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_icon_alert_enabled"],
                    tooltip           = fcoSSLocVars["options_icon_alert_enabled_tooltip"],
                    getFunc           = function() return settings.iconAlert end,
                    setFunc           = function(value)
                        settings.iconAlert = value
                        FCOSS.preventerVars.changedBySettingsMenu = true
                        FCOSS.ToggleAlertIcon(nil, false, false)
                        FCOSS.preventerVars.changedBySettingsMenu = false
                    end,
                    default = defaults.iconAlert
                },

                {
                    type = "iconpicker",
                    name = fcoSSLocVars["options_icon_alert_symbol"],
                    tooltip = fcoSSLocVars["options_icon_alert_symbol_tooltip"],
                    choices = FCOSS.iconTextures,
                    choicesTooltips = texturesList,
                    getFunc = function() return FCOSS.iconTextures[settings.iconAlertTexture] end,
                    setFunc = function(texturePath)
                        local textureId = FCOSS.GetTextureId(texturePath)
                        if textureId ~= 0 then
                            settings.iconAlertTexture = textureId
                            FCOSS.UpdateAlertIconValues()
                        end
                    end,
                    maxColumns = 5,
                    visibleRows = 4,
                    iconSize = 48,
                    width = "full",
                    default = FCOSS.iconTextures[settings.iconAlertTexture],
                    reference = "FCOStarveStop_Settings_IconAlertTexture_Select",
                    disabled = function() return not settings.iconAlert end,
                },

                {
                    type = "slider",
                    name = fcoSSLocVars["options_icon_alert_width"],
                    tooltip = fcoSSLocVars["options_icon_alert_width_tooltip"],
                    min = 8,
                    max = 500,
                    getFunc = function() return settings.iconAlertWidth end,
                    setFunc = function(width)
                        settings.iconAlertWidth = width
                        FCOSS.UpdateAlertIconValues()
                    end,
                    width="half",
                    default = defaults.iconAlertWidth,
                    disabled = function() return not settings.iconAlert end,
                },

                {
                    type = "slider",
                    name = fcoSSLocVars["options_icon_alert_height"],
                    tooltip = fcoSSLocVars["options_icon_alert_height_tooltip"],
                    min = 8,
                    max = 500,
                    getFunc = function() return settings.iconAlertHeight end,
                    setFunc = function(height)
                        settings.iconAlertHeight = height
                        FCOSS.UpdateAlertIconValues()
                    end,
                    width="half",
                    default = defaults.iconAlertHeight,
                    disabled = function() return not settings.iconAlert end,
                },

                {
                    type = "slider",
                    name = fcoSSLocVars["options_icon_alert_position_x"],
                    tooltip = fcoSSLocVars["options_icon_alert_position_x_tooltip"],
                    min = 0,
                    max = 3600,
                    getFunc = function() return settings.iconAlertX end,
                    setFunc = function(x)
                        settings.iconAlertX = x
                        FCOSS.UpdateAlertIconValues()
                    end,
                    width="half",
                    default = defaults.iconAlertX,
                    disabled = function() return not settings.iconAlert end,
                },

                {
                    type = "slider",
                    name = fcoSSLocVars["options_icon_alert_position_y"],
                    tooltip = fcoSSLocVars["options_icon_alert_position_y_tooltip"],
                    min = 0,
                    max = 2400,
                    getFunc = function() return settings.iconAlertY end,
                    setFunc = function(y)
                        settings.iconAlertY = y
                        FCOSS.UpdateAlertIconValues()
                    end,
                    width="half",
                    default = defaults.iconAlertY,
                    disabled = function() return not settings.iconAlert end,
                },


                --Alert icon for potions
                {
                    type = 'header',
                    name = fcoSSLocVars["options_header_potion"],
                },

                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_potion_icon_alert_enabled"],
                    tooltip           = fcoSSLocVars["options_potion_icon_alert_enabled_tooltip"],
                    getFunc           = function() return settings.iconAlertPotion end,
                    setFunc           = function(value)
                        settings.iconAlertPotion = value
                        FCOSS.preventerVars.changedBySettingsMenuPotion = true
                        FCOSS.toggleAlertIconPotion(nil, false)
                        FCOSS.preventerVars.changedBySettingsMenuPotion = false
                    end,
                    default = defaults.iconAlertPotion,
                    disabled          = function() return not settings.potionAlert end,
                },

                {
                    type = "iconpicker",
                    name = fcoSSLocVars["options_icon_alert_symbol"],
                    tooltip = fcoSSLocVars["options_icon_alert_symbol_tooltip"],
                    choices = FCOSS.iconTextures,
                    choicesTooltips = texturesList,
                    getFunc = function() return FCOSS.iconTextures[settings.iconAlertTexturePotion] end,
                    setFunc = function(texturePath)
                        local textureId = FCOSS.GetTextureId(texturePath)
                        if textureId ~= 0 then
                            settings.iconAlertTexturePotion = textureId
                            FCOSS.UpdateAlertIconValuesPotion()
                        end
                    end,
                    maxColumns = 5,
                    visibleRows = 4,
                    iconSize = 48,
                    width = "full",
                    default = FCOSS.iconTextures[settings.iconAlertTexture],
                    reference = "FCOStarveStop_Settings_IconAlertTexturePotion_Select",
                    disabled = function() return not settings.potionAlert or not settings.iconAlertPotion end,
                },

                {
                    type = "slider",
                    name = fcoSSLocVars["options_icon_alert_width"],
                    tooltip = fcoSSLocVars["options_icon_alert_width_tooltip"],
                    min = 8,
                    max = 500,
                    getFunc = function() return settings.iconAlertWidthPotion end,
                    setFunc = function(width)
                        settings.iconAlertWidthPotion = width
                        FCOSS.UpdateAlertIconValuesPotion()
                    end,
                    width="half",
                    default = defaults.iconAlertWidthPotion,
                    disabled = function() return not settings.potionAlert or not settings.iconAlertPotion end,
                },

                {
                    type = "slider",
                    name = fcoSSLocVars["options_icon_alert_height"],
                    tooltip = fcoSSLocVars["options_icon_alert_height_tooltip"],
                    min = 8,
                    max = 500,
                    getFunc = function() return settings.iconAlertHeightPotion end,
                    setFunc = function(height)
                        settings.iconAlertHeightPotion = height
                        FCOSS.UpdateAlertIconValuesPotion()
                    end,
                    width="half",
                    default = defaults.iconAlertHeightPotion,
                    disabled = function() return not settings.potionAlert or not settings.iconAlertPotion end,
                },

                {
                    type = "slider",
                    name = fcoSSLocVars["options_icon_alert_position_x"],
                    tooltip = fcoSSLocVars["options_icon_alert_position_x_tooltip"],
                    min = 0,
                    max = 3600,
                    getFunc = function() return settings.iconAlertXPotion end,
                    setFunc = function(x)
                        settings.iconAlertXPotion = x
                        FCOSS.UpdateAlertIconValuesPotion()
                    end,
                    width="half",
                    default = defaults.iconAlertXPotion,
                    disabled = function() return not settings.potionAlert or not settings.iconAlertPotion end,
                },

                {
                    type = "slider",
                    name = fcoSSLocVars["options_icon_alert_position_y"],
                    tooltip = fcoSSLocVars["options_icon_alert_position_y_tooltip"],
                    min = 0,
                    max = 2400,
                    getFunc = function() return settings.iconAlertYPotion end,
                    setFunc = function(y)
                        settings.iconAlertYPotion = y
                        FCOSS.UpdateAlertIconValuesPotion()
                    end,
                    width="half",
                    default = defaults.iconAlertYPotion,
                    disabled = function() return not settings.potionAlert or not settings.iconAlertPotion end,
                },


            }, -- controls submenu alert icon
        },  -- submenu alert icon

        {
            type = "submenu",
            name = fcoSSLocVars["options_header_sound_alert"],
            controls = {
                -- FOOD BUFF
                {
                    type = 'header',
                    name = fcoSSLocVars["options_header_food_buff"],
                },

                {
                    type = 'slider',
                    name = fcoSSLocVars["options_alert_sound"],
                    tooltip = fcoSSLocVars["options_alert_sound_tooltip"],
                    min = 1,
                    max = #FCOSS.sounds,
                    getFunc = function()
                        return settings.alertSound
                    end,
                    setFunc = function(idx)
                        settings.alertSound = idx
                        FCOStarveStop_Settings_AlertSound.label:SetText(fcoSSLocVars["options_alert_sound"] .. ": " .. FCOSS.sounds[idx])
                        if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOSS.sounds[idx]] ~= nil then
                            PlaySound(SOUNDS[FCOSS.sounds[idx]])
                        end
                    end,
                    default = defaults.alertSound,
                    reference = "FCOStarveStop_Settings_AlertSound",
                },

                {
                    type = 'slider',
                    name = fcoSSLocVars["options_alert_sound_repeat"],
                    tooltip = fcoSSLocVars["options_alert_sound_repeat_tooltip"],
                    min = 1,
                    max = 10,
                    getFunc = function()
                        return settings.alertSoundRepeat
                    end,
                    setFunc = function(repeatMe)
                        settings.alertSoundRepeat = repeatMe
                    end,
                    disabled = function() return settings.alertSound == 1 end,
                    default = defaults.alertSoundRepeat,
                },

                {
                    type = 'slider',
                    name = fcoSSLocVars["options_alert_sound_delay"],
                    tooltip = fcoSSLocVars["options_alert_sound_delay_tooltip"],
                    min = 250,
                    max = 10000,
                    getFunc = function()
                        return settings.alertSoundDelay
                    end,
                    setFunc = function(delayMe)
                        settings.alertSoundDelay = delayMe
                    end,
                    disabled = function() return settings.alertSound == 1 end,
                    default = defaults.alertSoundDelay,
                },

                -- POTIONS
                {
                    type = 'header',
                    name = fcoSSLocVars["options_header_potion"],
                },

                {
                    type = 'slider',
                    name = fcoSSLocVars["options_alert_sound"],
                    tooltip = fcoSSLocVars["options_alert_sound_tooltip"],
                    min = 1,
                    max = #FCOSS.sounds,
                    getFunc = function()
                        return settings.alertSoundPotion
                    end,
                    setFunc = function(idx)
                        settings.alertSoundPotion = idx
                        FCOStarveStop_Settings_AlertSoundPotion.label:SetText(fcoSSLocVars["options_alert_sound"] .. ": " .. FCOSS.sounds[idx])
                        if idx ~= 1 and SOUNDS ~= nil and SOUNDS[FCOSS.sounds[idx]] ~= nil then
                            PlaySound(SOUNDS[FCOSS.sounds[idx]])
                        end
                    end,
                    default = defaults.alertSoundPotion,
                    reference = "FCOStarveStop_Settings_AlertSoundPotion",
                },

                {
                    type = 'slider',
                    name = fcoSSLocVars["options_alert_sound_repeat"],
                    tooltip = fcoSSLocVars["options_alert_sound_repeat_tooltip"],
                    min = 1,
                    max = 10,
                    getFunc = function()
                        return settings.alertSoundRepeatPotion
                    end,
                    setFunc = function(repeatMe)
                        settings.alertSoundRepeatPotion = repeatMe
                    end,
                    disabled = function() return settings.alertSoundPotion == 1 end,
                    default = defaults.alertSoundRepeatPotion,
                },

                {
                    type = 'slider',
                    name = fcoSSLocVars["options_alert_sound_delay"],
                    tooltip = fcoSSLocVars["options_alert_sound_delay_tooltip"],
                    min = 250,
                    max = 10000,
                    getFunc = function()
                        return settings.alertSoundDelayPotion
                    end,
                    setFunc = function(delayMe)
                        settings.alertSoundDelayPotion = delayMe
                    end,
                    disabled = function() return settings.alertSoundPotion == 1 end,
                    default = defaults.alertSoundDelayPotion,
                },

            }, --controls sound
        }, --submenu sound

        {
            type = "submenu",
            name = fcoSSLocVars["options_header_quickslots"],
            controls = {

                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_other_addons_autoslotswitch"],
                    tooltip           = fcoSSLocVars["options_other_addons_autoslotswitch_tooltip"],
                    getFunc           = function() return settings.preferAutoSlotSwitch end,
                    setFunc           = function(value)
                        settings.preferAutoSlotSwitch = value
                    end,
                    default = defaults.preferAutoSlotSwitch,
                    disabled			= function() return not isAutoSlotSwitchLoaded end,
                },

                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_change_to_last_slot_after_companion_usage_from_qs"],
                    tooltip           = fcoSSLocVars["options_change_to_last_slot_after_companion_usage_from_qs_tooltip"],
                    getFunc           = function() return settings.changeToLastSlotAfterCompanionUsageFromQuickSlots end,
                    setFunc           = function(value)
                        settings.changeToLastSlotAfterCompanionUsageFromQuickSlots = value
                    end,
                    default = defaults.changeToLastSlotAfterCompanionUsageFromQuickSlots
                },
                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_quickslots_change_with_active_bufffood"],
                    tooltip           = fcoSSLocVars["options_quickslots_change_with_active_bufffood_tooltip"],
                    getFunc           = function() return settings.changeQuickslotsWithBuffFood end,
                    setFunc           = function(value)
                        settings.changeQuickslotsWithBuffFood = value
                    end,
                    default = defaults.changeQuickslotsWithBuffFood
                },
                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_quickslots_change_food_buff_in_combat"],
                    tooltip           = fcoSSLocVars["options_quickslots_change_food_buff_in_combat_tooltip"],
                    getFunc           = function() return settings.quickSlotChangeToFoodBuffInCombat end,
                    setFunc           = function(value)
                        settings.quickSlotChangeToFoodBuffInCombat = value
                    end,
                    default = defaults.quickSlotChangeToFoodBuffInCombat
                },
                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_quickslots_change_pve"],
                    tooltip           = fcoSSLocVars["options_quickslots_change_pve_tooltip"],
                    getFunc           = function() return settings.quickSlotChangePVE end,
                    setFunc           = function(value)
                        settings.quickSlotChangePVE = value
                    end,
                    default = defaults.quickSlotChangePVE
                },
                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_quickslots_change_pvp"],
                    tooltip           = fcoSSLocVars["options_quickslots_change_pvp_tooltip"],
                    getFunc           = function() return settings.quickSlotChangePVP end,
                    setFunc           = function(value)
                        settings.quickSlotChangePVP = value
                    end,
                    default = defaults.quickSlotChangePVP
                },

                --[[
                                {
                                    type = "submenu",
                                    name = fcoSSLocVars["options_header_quickslots_pve"],
                                    controls = {
                ]]
                {
                    type = "header",
                    name = fcoSSLocVars["options_header_quickslots_pve_food_buff"],
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pve_food_buff_slot"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pve_food_buff_slot_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToFoodBuffPVE]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToFoodBuffPVE = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToFoodBuffPVE]],
                    disabled = function() return not settings.quickSlotChangePVE end,
                    reference = "FCOStarveStop_Settings_FoodBuff_PvE_Select",
                },

                {
                    type = "header",
                    name = fcoSSLocVars["options_header_quickslots_pve"],
                },

                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_quickslots_change_pve_last_slot"],
                    tooltip           = fcoSSLocVars["options_quickslots_change_pve_last_slot_tooltip"],
                    getFunc           = function() return settings.quickSlotChangeToPVELast end,
                    setFunc           = function(value)
                        settings.quickSlotChangeToPVELast = value
                    end,
                    disabled 			= function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) end,
                    default = defaults.quickSlotChangeToPVELast
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pve_slot"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pve_slot_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPVE]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToPVE = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPVE]],
                    disabled = function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVELast end,
                    reference = "FCOStarveStop_Settings_PvE_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pve_slot_delve"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pve_slot_delve_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToDelvePVE]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToDelvePVE = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToDelvePVE]],
                    disabled = function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVELast end,
                    reference = "FCOStarveStop_Settings_Delve_PvE_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pve_slot_public_dungeon"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pve_slot_public_dungeon_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPublicDungeonPVE]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToPublicDungeonPVE = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPublicDungeonPVE]],
                    disabled = function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVELast end,
                    reference = "FCOStarveStop_Settings_PublicDungeon_PvE_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pve_slot_group_dungeon"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pve_slot_group_dungeon_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToGroupDungeonPVE]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToGroupDungeonPVE = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToGroupDungeonPVE]],
                    disabled = function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVELast end,
                    reference = "FCOStarveStop_Settings_GroupDungeon_PvE_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pve_slot_raid_dungeon"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pve_slot_raid_dungeon_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToRaidDungeonPVE]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToRaidDungeonPVE = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToRaidDungeonPVE]],
                    disabled = function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVELast end,
                    reference = "FCOStarveStop_Settings_RaidDungeon_PvE_Select",
                },

                {
                    type = "header",
                    name = fcoSSLocVars["options_header_quickslots_pve_combat"],
                },

                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_quickslots_change_pve_in_combat_last_slot"],
                    tooltip           = fcoSSLocVars["options_quickslots_change_pve_in_combat_last_slot_tooltip"],
                    getFunc           = function() return settings.quickSlotChangeToPVEInCombatLast end,
                    setFunc           = function(value)
                        settings.quickSlotChangeToPVEInCombatLast = value
                    end,
                    disabled 			= function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) end,
                    default = defaults.quickSlotChangeToPVEInCombatLast
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pve_in_combat_slot"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pve_in_combat_slot_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPVEInCombat]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToPVEInCombat = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPVEInCombat]],
                    disabled = function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVEInCombatLast end,
                    reference = "FCOStarveStop_Settings_PvE_Combat_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pve_slot_delve_combat"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pve_slot_delve_combat_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToDelvePVEInCombat]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToDelvePVEInCombat = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToDelvePVEInCombat]],
                    disabled = function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVEInCombatLast end,
                    reference = "FCOStarveStop_Settings_Delve_PvE_Combat_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pve_slot_public_dungeon_combat"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pve_slot_public_dungeon_combat_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPublicDungeonPVEInCombat]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToPublicDungeonPVEInCombat = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPublicDungeonPVEInCombat]],
                    disabled = function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVEInCombatLast end,
                    reference = "FCOStarveStop_Settings_PublicDungeon_PvE_Combat_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pve_slot_group_dungeon_combat"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pve_slot_group_dungeon_combat_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToGroupDungeonPVEInCombat]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToGroupDungeonPVEInCombat = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToGroupDungeonPVEInCombat]],
                    disabled = function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVEInCombatLast end,
                    reference = "FCOStarveStop_Settings_GroupDungeon_PvE_Combat_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pve_slot_raid_dungeon_combat"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pve_slot_raid_dungeon_combat_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToRaidDungeonPVEInCombat]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToRaidDungeonPVEInCombat = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToRaidDungeonPVEInCombat]],
                    disabled = function() return not settings.quickSlotChangePVE or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVEInCombatLast end,
                    reference = "FCOStarveStop_Settings_RaidDungeon_PvE_Combat_Select",
                },

                --}, -- controls pve
                --}, -- submenu pve

                --[[
                                {
                                    type = "submenu",
                                    name = fcoSSLocVars["options_header_quickslots_pvp"],
                                    controls = {
                ]]
                {
                    type = "header",
                    name = fcoSSLocVars["options_header_quickslots_pvp_food_buff"],
                },
                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pvp_food_buff_slot"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pvp_food_buff_slot_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToFoodBuffPVP]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToFoodBuffPVP = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToFoodBuffPVP]],
                    disabled = function() return not settings.quickSlotChangePVP end,
                    reference = "FCOStarveStop_Settings_FoodBuff_PvP_Select",
                },

                {
                    type = "header",
                    name = fcoSSLocVars["options_header_quickslots_pvp"],
                },

                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_quickslots_change_pvp_last_slot"],
                    tooltip           = fcoSSLocVars["options_quickslots_change_pvp_last_slot_tooltip"],
                    getFunc           = function() return settings.quickSlotChangeToPVPLast end,
                    setFunc           = function(value)
                        settings.quickSlotChangeToPVPLast = value
                    end,
                    disabled 			= function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) end,
                    default = defaults.quickSlotChangeToPVPLast
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pvp_slot"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pvp_slot_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPVP]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToPVP = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPVP]],
                    disabled = function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVPLast end,
                    reference = "FCOStarveStop_Settings_PvP_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pvp_slot_delve"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pvp_slot_delve_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToDelvePVP]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToDelvePVP = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToDelvePVP]],
                    disabled = function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVPLast end,
                    reference = "FCOStarveStop_Settings_Delve_PvP_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pvp_slot_public_dungeon"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pvp_slot_public_dungeon_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPublicDungeonPVP]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToPublicDungeonPVP = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPublicDungeonPVP]],
                    disabled = function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVPLast end,
                    reference = "FCOStarveStop_Settings_PublicDungeon_PvP_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pvp_slot_group_dungeon"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pvp_slot_group_dungeon_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToGroupDungeonPVP]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToGroupDungeonPVP = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToGroupDungeonPVP]],
                    disabled = function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVPLast end,
                    reference = "FCOStarveStop_Settings_GroupDungeon_PvP_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pvp_slot_raid_dungeon"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pvp_slot_raid_dungeon_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToRaidDungeonPVP]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToRaidDungeonPVP = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToRaidDungeonPVP]],
                    disabled = function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVPLast end,
                    reference = "FCOStarveStop_Settings_RaidDungeon_PvP_Select",
                },

                {
                    type = "header",
                    name = fcoSSLocVars["options_header_quickslots_pvp_combat"],
                },

                {
                    type              = "checkbox",
                    name              = fcoSSLocVars["options_quickslots_change_pvp_in_combat_last_slot"],
                    tooltip           = fcoSSLocVars["options_quickslots_change_pvp_in_combat_last_slot_tooltip"],
                    getFunc           = function() return settings.quickSlotChangeToPVPInCombatLast end,
                    setFunc           = function(value)
                        settings.quickSlotChangeToPVPInCombatLast = value
                    end,
                    disabled 			= function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) end,
                    default = defaults.quickSlotChangeToPVPInCombatLast
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pvp_in_combat_slot"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pvp_in_combat_slot_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPVPInCombat]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToPVPInCombat = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPVPInCombat]],
                    disabled = function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVPInCombatLast end,
                    reference = "FCOStarveStop_Settings_PvP_Combat_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pvp_slot_delve_combat"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pvp_slot_delve_combat_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToDelvePVPInCombat]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToDelvePVPInCombat = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToDelvePVPInCombat]],
                    disabled = function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVPInCombatLast end,
                    reference = "FCOStarveStop_Settings_Delve_PvP_Combat_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pvp_slot_public_dungeon_combat"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pvp_slot_public_dungeon_combat_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPublicDungeonPVPInCombat]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToPublicDungeonPVPInCombat = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToPublicDungeonPVPInCombat]],
                    disabled = function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVPInCombatLast end,
                    reference = "FCOStarveStop_Settings_PublicDungeon_PvP_Combat_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pvp_slot_group_dungeon_combat"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pvp_slot_group_dungeon_combat_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToGroupDungeonPVPInCombat]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToGroupDungeonPVPInCombat = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToGroupDungeonPVPInCombat]],
                    disabled = function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVPInCombatLast end,
                    reference = "FCOStarveStop_Settings_GroupDungeon_PvP_Combat_Select",
                },

                {
                    type = 'dropdown',
                    name = fcoSSLocVars["options_quickslots_change_pvp_slot_raid_dungeon_combat"],
                    tooltip = fcoSSLocVars["options_quickslots_change_pvp_slot_raid_dungeon_combat_tooltip"],
                    choices = FCOSS.quickSlots,
                    getFunc = function() return FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToRaidDungeonPVPInCombat]] end,
                    setFunc = function(value)
                        for i, v in pairs(FCOSS.quickSlots) do
                            if v == value then
                                settings.quickSlotChangeToRaidDungeonPVPInCombat = FCOSS.quickSlotsMapping[i]
                                break
                            end
                        end
                    end,
                    default = FCOSS.quickSlots[FCOSS.quickSlotsBackwardsMapping[settings.quickSlotChangeToRaidDungeonPVPInCombat]],
                    disabled = function() return not settings.quickSlotChangePVP or (settings.preferAutoSlotSwitch and isAutoSlotSwitchLoaded) or settings.quickSlotChangeToPVPInCombatLast end,
                    reference = "FCOStarveStop_Settings_RaidDungeon_PvP_Combat_Select",
                },

                --} -- controls pvp
                --}, -- submenu pvp

            } -- controls quickslots
        }, -- submenu quickslots

    }
    FCOSS.addonMenuPanel = FCOSS.addonMenu:RegisterAddonPanel("FCOStarveStop_SettingsMenu", FCOSS.panelData)
    FCOSS.addonMenu:RegisterOptionControls("FCOStarveStop_SettingsMenu", FCOSS.optionsData)
    --Show the alert icon and potion alert icon
    local firstOpenLAMSettingsPanel = true
    local function FCOSS_LAM_Opened(panel)
        if panel == FCOSS.addonMenuPanel then
            if not firstOpenLAMSettingsPanel then
                FCOSS.updateQuickslotsSettingsDropdown()
            end
            FCOSS.ToggleAlertIcon(true, false, false)
            FCOSS.toggleAlertIconPotion(true, false)

            firstOpenLAMSettingsPanel = false
        end
    end
    --Hide the alert icon and potion alert icon
    local function FCOSS_LAM_Closed(panel)
        if panel == FCOSS.addonMenuPanel then
            FCOSS.ToggleAlertIcon(false, false, false)
            --Check delayed after the FCOStarveStop settings panel was closed and the new panel was updated
            zo_callLater(function()
                FCOSS.toggleAlertIconPotion(false, false)
            end, 50)
        end
    end
    --Register the callback for the LAM panel created function
    CM:RegisterCallback("LAM-PanelOpened",    FCOSS_LAM_Opened)
    CM:RegisterCallback("LAM-PanelClosed",    FCOSS_LAM_Closed)

    FCOSS.preventerVars.addonMenuBuild = true
end

