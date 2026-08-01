FCOCO = FCOCO or  {}
local FCOCompanion = FCOCO
if not FCOCompanion.isCompanionUnlocked then return end
------------------------------------------------------------------------------------------------------------------------


local addonVars = FCOCompanion.addonVars
local getCompanionJunkSavedVars = FCOCompanion.GetCompanionJunkSavedVars

local LAM2 = FCOCompanion.LAM

------------------------------------------------------------------------------------------------------------------------
-- SETTINGS MENU
------------------------------------------------------------------------------------------------------------------------

function FCOCompanion.buildAddonMenu()
    local settings = FCOCompanion.settingsVars.settings
    if not settings or not LAM2 then return false end
    local defaults = FCOCompanion.settingsVars.defaults
    local settingsPerToon = FCOCompanion.settingsVars.settingsPerToon
    --local defaultsPerToon = FCOCompanion.settingsVars.defaultsPerToon
    local companionJunkSV, companionJunkDefaults = getCompanionJunkSavedVars()
    local addonName = addonVars.addonName


    local panelData = {
        type 				= 'panel',
        name 				= addonVars.addonNameMenu,
        displayName 		= addonVars.addonNameMenuDisplay,
        author 				= addonVars.addonAuthor,
        version 			= tostring(addonVars.addonVersion),
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand        = "/fcocos",
        website             = addonVars.addonWebsite,
        feedback            = addonVars.addonFeedback,
        donation            = addonVars.addonDonation,
    }
    FCOCompanion.FCOSettingsPanel = LAM2:RegisterAddonPanel(addonName .. "_LAM", panelData)

    local savedVariablesOptions = {
        [1] = GetString(FCOCO_LAM_SV_EACH_CHARACTER),   --'Each character',
        [2] = GetString(FCOCO_LAM_SV_ACCOUNT_WIDE),     --'Account wide'
    }
    local savedVariablesOptionsValues = {
        [1] = 1,
        [2] = 2,
    }

    local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

        {
            type = 'dropdown',
            name = GetString(FCOCO_LAM_SV_MODE),
            tooltip = GetString(FCOCO_LAM_SV_MODE_TT),
            choices = savedVariablesOptions,
            choicesValues = savedVariablesOptionsValues,
            getFunc = function() return FCOCompanion.settingsVars.defaultSettings.saveMode end,
            setFunc = function(value)
                FCOCompanion.settingsVars.defaultSettings.saveMode = value
            end,
            requiresReload = true,
        },


        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOCO_LAM_SETTING_HEADER_JUNK),
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_ENABLE_JUNK),
            tooltip = GetString(FCOCO_LAM_SETTING_ENABLE_JUNK_TT),
            getFunc = function() return companionJunkSV.enableCompanionItemJunk end,
            setFunc = function(value) companionJunkSV.enableCompanionItemJunk = value
            end,
            default = companionJunkDefaults.enableCompanionItemJunk,
            width="full",
            disabled = function() return LibCustomMenu == nil end,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_ENABLE_ACCOUNT_WIDE_JUNK),
            tooltip = GetString(FCOCO_LAM_SETTING_ENABLE_ACCOUNT_WIDE_JUNK_TT),
            getFunc = function() return settings.useAccountWideCompanionJunk end,
            setFunc = function(value) settings.useAccountWideCompanionJunk = value
            end,
            default = defaults.useAccountWideCompanionJunk,
            width="full",
            disabled = function() return LibCustomMenu == nil or not companionJunkSV.enableCompanionItemJunk end,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_AUTO_JUNK_SAME_ITEMS),
            tooltip = GetString(FCOCO_LAM_SETTING_AUTO_JUNK_SAME_ITEMS_TT),
            getFunc = function() return companionJunkSV.autoJunkMarkSameCompanionItemsInBags end,
            setFunc = function(value) companionJunkSV.autoJunkMarkSameCompanionItemsInBags = value
            end,
            default = companionJunkDefaults.autoJunkMarkSameCompanionItemsInBags,
            width="full",
            disabled = function() return LibCustomMenu == nil or not companionJunkSV.enableCompanionItemJunk end,
        },

        {
            type = "button",
            name = GetString(FCOCO_LAM_SETTING_JUNK_MIGRATE_TO_ACC),
            tooltip = GetString(FCOCO_LAM_SETTING_JUNK_MIGRATE_TO_ACC_TT),
            func = function()
                local wasExecuted, numMigrated = FCOCompanion.MigrateSVData(GetCurrentCharacterId(), true, true, "companionItemsJunked")
                if wasExecuted == true then
                    d(string.format(GetString(FCOCO_LAM_JUNK_MIGRATE_TO_ACC_TOTAL_STR), numMigrated))
                end
            end,
            width = "full",
            isDangerous = true,
            disabled = function() return LibCustomMenu == nil
                                    or not companionJunkSV.enableCompanionItemJunk
                                    or not settings.useAccountWideCompanionJunk
                                    or ZO_IsTableEmpty(settingsPerToon.companionItemsJunked)
                                    or FCOCompanion.AnyCompanionJunkItemsToMigrate(true) == false
                        end,
            warning = GetString(FCOCO_LAM_SETTING_JUNK_MIGRATE_TO_ACC_TT),
        },

        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOCO_LAM_SETTING_HEADER_CRAFTING),
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_CRAFTING_TABLE),
            tooltip = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_CRAFTING_TABLE_TT),
            getFunc = function() return settings.unSummonAtCraftingTables end,
            setFunc = function(value) settings.unSummonAtCraftingTables = value
            end,
            default = defaults.unSummonAtCraftingTables,
            width="full",
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_CRAFTING_TABLE),
            tooltip = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_CRAFTING_TABLE_TT),
            getFunc = function() return settings.reSummonAfterCraftingTables end,
            setFunc = function(value) settings.reSummonAfterCraftingTables = value
            end,
            default = defaults.reSummonAfterCraftingTables,
            disabled = function() return not settings.unSummonAtCraftingTables end,
            width="full",
        },
        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOCO_LAM_SETTING_HEADER_BANKS),
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_BANK),
            tooltip = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_BANK_TT),
            getFunc = function() return settings.unSummonAtBanks end,
            setFunc = function(value) settings.unSummonAtBanks = value
            end,
            default = defaults.unSummonAtBanks,
            width="full",
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_BANK),
            tooltip = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_BANK_TT),
            getFunc = function() return settings.reSummonAfterBanks end,
            setFunc = function(value) settings.reSummonAfterBanks = value
            end,
            default = defaults.reSummonAfterBanks,
            disabled = function() return not settings.unSummonAtBanks end,
            width="full",
        },
        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOCO_LAM_SETTING_HEADER_VENDORS),
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_VENDOR),
            tooltip = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_VENDOR_TT),
            getFunc = function() return settings.unSummonAtVendors end,
            setFunc = function(value) settings.unSummonAtVendors = value
            end,
            default = defaults.unSummonAtVendors,
            width="full",
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_VENDOR),
            tooltip = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_VENDOR_TT),
            getFunc = function() return settings.reSummonAfterVendors end,
            setFunc = function(value) settings.reSummonAfterVendors = value
            end,
            default = defaults.reSummonAfterVendors,
            disabled = function() return not settings.unSummonAtVendors end,
            width="full",
        },
        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOCO_LAM_SETTING_HEADER_FISHING),
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_FISHING),
            tooltip = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_FISHING_TT),
            getFunc = function() return settings.unSummonAtFishing end,
            setFunc = function(value) settings.unSummonAtFishing = value
            end,
            default = defaults.unSummonAtFishing,
            width="full",
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING),
            tooltip = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING_TT),
            getFunc = function() return settings.reSummonAfterFishing end,
            setFunc = function(value) settings.reSummonAfterFishing = value
            end,
            default = defaults.reSummonAfterFishing,
            disabled = function() return not settings.unSummonAtFishing end,
            width="full",
        },
        {
            type = "slider",
            name = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING_DELAY),
            tooltip = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING_DELAY_TT),
            getFunc = function() return settings.reSummonAfterFishingDelay end,
            setFunc = function(value) settings.reSummonAfterFishingDelay = value
            end,
            min = 0,
            max = 60000,
            step = 1000,
            default = defaults.reSummonAfterFishingDelay,
            disabled = function() return not settings.unSummonAtFishing or not settings.reSummonAfterFishing end,
            width="full",
        },
        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOCO_LAM_SETTING_HEADER_CROUCH),
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING),
            tooltip = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING_TT),
            getFunc = function() return settings.unSummonAtCrouching end,
            setFunc = function(value) settings.unSummonAtCrouching = value
            end,
            default = defaults.unSummonAtCrouching,
            width="full",
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING_NO_COMBAT),
            tooltip = GetString(FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING_NO_COMBAT_TT),
            getFunc = function() return settings.unSummonAtCrouchingNoCombat end,
            setFunc = function(value) settings.unSummonAtCrouchingNoCombat = value
            end,
            default = defaults.unSummonAtCrouchingNoCombat,
            disabled = function() return not settings.unSummonAtCrouching end,
            width="full",
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING),
            tooltip = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING_TT),
            getFunc = function() return settings.reSummonAfterCrouching end,
            setFunc = function(value) settings.reSummonAfterCrouching = value
            end,
            default = defaults.reSummonAfterCrouching,
            disabled = function() return not settings.unSummonAtCrouching end,
            width="full",
        },
        {
            type = "slider",
            name = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING_DELAY),
            tooltip = GetString(FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING_DELAY_TT),
            getFunc = function() return settings.reSummonAfterCrouchingDelay end,
            setFunc = function(value) settings.reSummonAfterCrouchingDelay = value
            end,
            min = 0,
            max = 60000,
            step = 1000,
            default = defaults.reSummonAfterCrouchingDelay,
            disabled = function() return not settings.unSummonAtCrouching or not settings.reSummonAfterCrouching end,
            width="full",
        },
        --==============================================================================
        {
            type = 'header',
            name = GetString(FCOCO_LAM_SETTING_HEADER_COMPASS),
        },
        {
            type = "checkbox",
            name = GetString(FCOCO_LAM_SETTING_DISABLE_PIN_AT_COMPASS),
            tooltip = GetString(FCOCO_LAM_SETTING_DISABLE_PIN_AT_COMPASS_TT),
            getFunc = function() return settings.disableCompanionAtCompass end,
            setFunc = function(value)
                settings.disableCompanionAtCompass = value
                FCOCompanion.UpdateCompass()
            end,
            default = defaults.disableCompanionAtCompass,
            width="full",
        },


    } -- optionsTable
    -- END OF OPTIONS TABLE
    --[[
    local lamPanelCreationInitDone = false
    local function LAMControlsCreatedCallbackFunc(pPanel)
        if pPanel ~= FCOCompanion.FCOSettingsPanel then return end
        if lamPanelCreationInitDone == true then return end
        --Do stiff here
        lamPanelCreationInitDone = true
    end
    ]]
    --CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", LAMControlsCreatedCallbackFunc)

    LAM2:RegisterOptionControls(addonName .. "_LAM", optionsTable)
end