-- Local instances of Global tables
local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKI = SK.Interface
local SKV = SK.Variables

SK.OptionsPanel = nil
SK.LAM = LibAddonMenu2

-- Settings menu.
local function InitSettings()
    local TrainNames = SK.Automation.TrainNames
    local QualityChooses = SK.QUALITY_CHOOSES
    local AfterThresholdTrainRule = SK.Automation.AfterThresholdTrainRule
    local CompanionUnsafeEntryModes = SK.Automation.CompanionUnsafeEntryModes
    local choicesWhoMust, mappingWhoMust, reverseMappingWhoMust = SKH.getChoicesWhoMust()

    local panelData = {
        type = "panel",
        name = SK.displayName,
        displayName = SK.displayName,
        author = SK.COLOR.DARK_OLIVE_GREEN:Colorize(SK.author),
        version = SK.COLOR.DARK_SLATE_BLUE:Colorize(SK.version),
        registerForRefresh = true,
        registerForDefaults = true,
    }
    SK.OptionsPanel = SK.LAM:RegisterAddonPanel(SK.name.."OptionsPanel", panelData)

    local optionsTable = {}
    table.insert(optionsTable, {
        type = "description",
        text = GetString(SI_SK_OPTIONS_GENERAL_DESCRIPTION),
    })

    table.insert(optionsTable,{
        type = "checkbox",
        name = GetString(SI_SK_ASW_OPTIONS_NAME),
        tooltip = GetString(SI_SK_ASW_OPTIONS_TOOLTIP),
        getFunc = function() return SK.accountsWideSV.accountsWide end,
        setFunc = function(v)
            if v and SK.accountsWideSV.firstLoad then
                SKV.DeepCopy(
                    SK.savedVars,
                    SK.accountsWideSV
                )
                SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKO, GetString(SI_SK_ASW_OPTIONS_TOGGLE_MESSAGE))
            end
            SK.accountsWideSV.accountsWide = v
        end,
        default = SK.defaultSavedVars.accountsWide,
        requiresReload = true,
        width = "full"
    })

    table.insert(optionsTable,{
        type = "checkbox",
        name = GetString(SI_SK_AW_OPTIONS_NAME),
        tooltip = GetString(SI_SK_AW_OPTIONS_TOOLTIP),
        getFunc = function() return SK.accountWideSV.accountWide end,
        setFunc = function(v)
            if v and SK.accountWideSV.firstLoad then
                SKV.DeepCopy(
                    SK.savedVars,
                    SK.accountWideSV
                )
                SKH.sendMessageToChat(
                    SK.COLORED_PREFIXES.SKO,
                    SK.COLOR.WHITE:Colorize(GetString(SI_SK_AW_OPTIONS_TOGGLE_MESSAGE))
                )
            end
            SK.accountWideSV.accountWide = v
        end,
        disabled = function() return SK.accountsWideSV.accountsWide end,
        default = SK.defaultSavedVars.accountWide,
        requiresReload = true,
        width = "full"
    })

    table.insert(optionsTable,{
        type = "checkbox",
        name = GetString(SI_SK_DEBUG_NAME),
        getFunc = function() return SK.savedVars.debugMode end,
        setFunc = function(v)
            SK.savedVars.debugMode = v
            SK.SlashCommands.fillCommandsData()
        end,
        default = SK.defaultSavedVars.debugMode,
        width = "full"
    })

    table.insert(optionsTable, {
        type = "header",
        name = SK.COLOR.ORANGE:Colorize(GetString(SI_SK_EQUIPMENT_OPTIONS_HEADER)),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_SETS_SUBMENU_HEADER)),
        tooltip = GetString(SI_SK_SETS_SUBMENU_TOOLTIP),
        icon = "/SwissKnife/textures/gui/cultist.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_EQUIPMENT_TRACK_SETS_ITEMS_NAME),
                tooltip = GetString(SI_SK_EQUIPMENT_TRACK_SETS_ITEMS_TOOLTIP),
                getFunc = function() return SK.savedVars.trackSetsItems end,
                setFunc = function(v)
                    SK.savedVars.trackSetsItems = v
                    if v then
                        if SK.globalSV.trackedSetsItems == nil then
                            SK.globalSV.trackedSetsItems = {}
                        end
                        SK.isTrackedSetsItemsDataLoad = false
                        SKH.updateTrackedSetItems()
                        SKH.conditionalRefreshSetsItemsList()
                    end
                end,
                default = SK.defaultSavedVars.trackSetsItems,
                requiresReload = true,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(SI_SK_EQUIPMENT_TRACK_LOW_LEVEL_SETS_TOO_NAME),
                tooltip = GetString(SI_SK_EQUIPMENT_TRACK_LOW_LEVEL_SETS_TOO_TOOLTIP),
                getFunc = function() return SK.savedVars.trackLowLevelSetsItems end,
                setFunc = function(v)
                    SK.savedVars.trackLowLevelSetsItems = v
                    SK.isTrackedSetsItemsDataLoad = false
                    SKH.updateTrackedSetItems()
                    SKH.conditionalRefreshSetsItemsList()
                end,
                disabled = function() return not SK.savedVars.trackSetsItems end,
                default = SK.defaultSavedVars.trackLowLevelSetsItems,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(SI_SK_EQUIPMENT_TRACK_CRAFTED_SETS_TOO_NAME),
                tooltip = GetString(SI_SK_EQUIPMENT_TRACK_CRAFTED_SETS_TOO_TOOLTIP),
                getFunc = function() return SK.savedVars.trackCraftedSetsItems end,
                setFunc = function(v)
                    SK.savedVars.trackCraftedSetsItems = v
                    SK.isTrackedSetsItemsDataLoad = false
                    SKH.updateTrackedSetItems()
                    SKH.conditionalRefreshSetsItemsList()
                end,
                disabled = function() return not SK.savedVars.trackSetsItems end,
                default = SK.defaultSavedVars.trackCraftedSetsItems,
                width = "full"
            },
            [4] = {
                type = "checkbox",
                name = GetString(SI_SK_EQUIPMENT_TRACK_COMPANION_ITEMS_TOO_NAME),
                getFunc = function() return SK.savedVars.trackCompanionItems end,
                setFunc = function(v)
                    SK.savedVars.trackCompanionItems = v
                    SK.isTrackedSetsItemsDataLoad = false
                    SKH.updateTrackedSetItems()
                    SKH.conditionalRefreshSetsItemsList()
                end,
                disabled = function() return not SK.savedVars.trackSetsItems end,
                default = SK.defaultSavedVars.trackCompanionItems,
                width = "full"
            },
            [5] = {
                type = "checkbox",
                name = GetString(SI_SK_EQUIPMENT_TRACK_SHOW_WHERE_CURRENT_ACCOUNT_NAME),
                tooltip = GetString(SI_SK_EQUIPMENT_TRACK_SHOW_WHERE_CURRENT_ACCOUNT_TOOLTIP),
                getFunc = function() return SK.savedVars.filterCurrentAccountTrackSetsItems end,
                setFunc = function(v) SK.savedVars.filterCurrentAccountTrackSetsItems = v end,
                disabled = function() return not SK.savedVars.trackSetsItems end,
                default = SK.defaultSavedVars.filterCurrentAccountTrackSetsItems,
                width = "full"
            },
            [6] = {
                type = "checkbox",
                name = GetString(SI_SK_EQUIPMENT_TRACK_SHOW_WHERE_CURRENT_SERVER_NAME),
                tooltip = GetString(SI_SK_EQUIPMENT_TRACK_SHOW_WHERE_CURRENT_SERVER_TOOLTIP),
                getFunc = function() return SK.savedVars.filterCurrentServerTrackSetsItems end,
                setFunc = function(v) SK.savedVars.filterCurrentServerTrackSetsItems = v end,
                disabled = function() return SK.HasOneServer or not SK.savedVars.trackSetsItems end,
                default = SK.defaultSavedVars.filterCurrentServerTrackSetsItems,
                width = "full"
            },
            --[4] = {
            --    type = "checkbox",
            --    name = GetString(SI_SK_EQUIPMENT_TRACK_JUNK_ITEMS_TOO_NAME),
            --    tooltip = GetString(SI_SK_EQUIPMENT_TRACK_JUNK_ITEMS_TOO_TOOLTIP),
            --    getFunc = function() return SK.savedVars.trackJunkSetsItems end,
            --    setFunc = function(v)
            --        SK.savedVars.trackJunkSetsItems = v
            --        SKH.updateTrackedSetItems()
            --        SKMD.setsItemsList:Refresh()
            --    end,
            --    disabled = function() return not SK.savedVars.trackSetsItems end,
            --    width = "full"
            --},
            [7] = {
                type = "dropdown",
                name = GetString(SI_SK_EQUIPMENT_TRACK_SETS_ITEMS_LIST_FONT_NAME),
                tooltip = GetString(SI_SK_EQUIPMENT_TRACK_SETS_ITEMS_LIST_FONT_TOOLTIP),
                choices = {"ZoFontWinT1", "ZoFontWinT2"},
                getFunc = function() return SK.savedVars.trackSetsItemsFont end,
                setFunc = function(v)
                    SK.savedVars.trackSetsItemsFont = v
                    SKH.conditionalRefreshSetsItemsList()
                end,
                disabled = function() return not SK.savedVars.trackSetsItems end,
                default = SK.defaultSavedVars.trackSetsItemsFont,
                width = "full",
            },
            [8] = {
                type = "divider",
                width = "full"
            },
            [9] = {
                type = "checkbox",
                name = GetString(SI_SK_EQUIPMENT_SHOW_EN_SET_NAME_TOO_NAME),
                tooltip = GetString(SI_SK_EQUIPMENT_SHOW_EN_SET_NAME_TOO_TOOLTIP),
                getFunc = function() return SK.savedVars.showEnSetNameToo end,
                setFunc = function(v)
                    SK.savedVars.showEnSetNameToo = v
                    if not v then SK.savedVars.showEnTraitNameToo = false end
                    SKMD.setsList:Refresh()
                    SKH.conditionalRefreshSetsItemsList()
                end,
                default = SK.defaultSavedVars.showEnSetNameToo,
                width = "full"
            },
            [10] = {
                type = "checkbox",
                name = GetString(SI_SK_EQUIPMENT_SHOW_EN_TRAIT_NAME_TOO_NAME),
                tooltip = GetString(SI_SK_EQUIPMENT_SHOW_EN_TRAIT_NAME_TOO_TOOLTIP),
                getFunc = function() return SK.savedVars.showEnTraitNameToo end,
                setFunc = function(v) SK.savedVars.showEnTraitNameToo = v end,
                disabled = function() return not SK.savedVars.showEnSetNameToo end,
                default = SK.defaultSavedVars.showEnTraitNameToo,
                width = "full"
            },
        }})

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_APPAREL_SUBMENU_HEADER)),
        tooltip = GetString(SI_SK_APPAREL_SUBMENU_TOOLTIP),
        icon = "/SwissKnife/textures/gui/swordman.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_APPAREL_SHOW_QUALITY_NAME),
                tooltip = GetString(SI_SK_APPAREL_SHOW_QUALITY_TOOLTIP),
                getFunc = function() return SK.savedVars.apparelShowQuality end,
                setFunc = function(v)
                    SKAP.isShow = v
                    SKAP:UpdateAllSlots()
                    SK.savedVars.apparelShowQuality = v
                end,
                default = SK.defaultSavedVars.apparelShowQuality,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(SI_SK_APPAREL_SHOW_DURABILITY_NAME),
                tooltip = GetString(SI_SK_APPAREL_SHOW_DURABILITY_TOOLTIP),
                getFunc = function() return SK.savedVars.apparelShowDurability end,
                setFunc = function(v)
                    SKAP.isDurability = v
                    SKAP:UpdateAllSlots()
                    SK.savedVars.apparelShowDurability = v
                end,
                default = SK.defaultSavedVars.apparelShowDurability,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(SI_SK_COMPANION_APPAREL_SHOW_QUALITY_NAME),
                tooltip = GetString(SI_SK_COMPANION_APPAREL_SHOW_QUALITY_TOOLTIP),
                getFunc = function() return SK.savedVars.companionApparelShowQuality end,
                setFunc = function(v)
                    SKAC.isShow = v
                    SKAC:UpdateAllSlots()
                    SK.savedVars.companionApparelShowQuality = v
                end,
                default = SK.defaultSavedVars.companionApparelShowQuality,
                width = "full"
            },
        },
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_CR_PANEL_SUBMENU_HEADER)),
        tooltip = GetString(SI_SK_CR_PANEL_SUBMENU_TOOLTIP),
        icon = "/SwissKnife/textures/gui/wooden-sign.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_CR_PANEL_SHOW_REPAIR_NAME),
                tooltip = GetString(SI_SK_CR_PANEL_SHOW_REPAIR_TOOLTIP),
                getFunc = function() return SK.savedVars.panelBottomShowRepair end,
                setFunc = function(v) SK.savedVars.panelBottomShowRepair = v end,
                default = SK.defaultSavedVars.panelBottomShowRepair,
                requiresReload = true,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(SI_SK_CR_PANEL_SHOW_CHARGE_NAME),
                tooltip = GetString(SI_SK_CR_PANEL_SHOW_CHARGE_TOOLTIP),
                getFunc = function() return SK.savedVars.panelBottomShowCharge end,
                setFunc = function(v) SK.savedVars.panelBottomShowCharge = v end,
                default = SK.defaultSavedVars.panelBottomShowCharge,
                requiresReload = true,
                width = "full"
            },
        },
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_EQ_PANEL_SUBMENU_HEADER)),
        tooltip = GetString(SI_SK_EQ_PANEL_SUBMENU_TOOLTIP),
        icon = "/SwissKnife/textures/gui/emerald.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_EQ_PANEL_SHOW_QUALITY_COLOR_NAME),
                tooltip = GetString(SI_SK_EQ_PANEL_SHOW_QUALITY_COLOR_TOOLTIP),
                getFunc = function() return SK.savedVars.showEnchantQualityColor end,
                setFunc = function(v) SK.savedVars.showEnchantQualityColor = v end,
                default = SK.defaultSavedVars.showEnchantQualityColor,
                width = "full"
            },
        },
    })

    table.insert(optionsTable, {
        type = "header",
        name = SK.COLOR.ORANGE:Colorize(GetString(SI_SK_AUT_OPTIONS_HEADER)),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_AUT_BANK_TRADING_HOUSE_HEADER)),
        tooltip = GetString(SI_SK_AUT_BANK_TRADING_HOUSE_TOOLTIP),
        icon = "/SwissKnife/textures/gui/closed-doors.dds",
        controls = {
            [1] = {
                type = "dropdown",
                name = GetString(SI_SK_AUT_DEFAULT_GUILD_BANK_OPTIONS_HEADER),
                tooltip = GetString(SI_SK_AUT_DEFAULT_GUILD_BANK_OPTIONS_TOOLTIP),
    			choices = SKH.getGuilds().Choices,
                getFunc = function()
                    if SKH.hasTableChild(SK.savedVars.defaultGuildData, {SK.AccName, "BankId"}) then
                        return GetGuildName(SK.savedVars.defaultGuildData[SK.AccName].BankId)
                    end
                end,
                setFunc = function(v)
                    local id = SKH.getGuilds().Maps[v]
                    SKH.setTableChild(SK.savedVars.defaultGuildData, {SK.AccName, "BankId"}, id)
                end,
                width = "full"
            },
            [2] = {
                type = "dropdown",
                name = GetString(SI_SK_AUT_DEFAULT_GUILD_SHOP_OPTIONS_HEADER),
                tooltip = GetString(SI_SK_AUT_DEFAULT_GUILD_SHOP_OPTIONS_TOOLTIP),
    			choices = SKH.getGuilds().Choices,
                getFunc = function()
                    if SKH.hasTableChild(SK.savedVars.defaultGuildData, {SK.AccName, "ShopId"}) then
                        return GetGuildName(SK.savedVars.defaultGuildData[SK.AccName].ShopId)
                    end
                end,
                setFunc = function(v)
                    local id = SKH.getGuilds().Maps[v]
                    SKH.setTableChild(SK.savedVars.defaultGuildData, {SK.AccName, "ShopId"}, id)
                end,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_OPEN_GUILD_SHOP_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_OPEN_GUILD_SHOP_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.openGuildShopEnabled end,
                setFunc = function(v) SK.savedVars.openGuildShopEnabled = v end,
                default = SK.defaultSavedVars.openGuildShopEnabled,
                width = "full"
            },
            [4] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_SHOW_GUILD_BANK_CHOOSER_NAME),
                tooltip = GetString(SI_SK_AUT_SHOW_GUILD_BANK_CHOOSER_TOOLTIP),
                getFunc = function() return SK.savedVars.showGuildBankChooser end,
                setFunc = function(v) SK.savedVars.showGuildBankChooser = v end,
                default = SK.defaultSavedVars.showGuildBankChooser,
                width = "full"
            },
        },
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_AUT_LOOT_HEADER)),
        tooltip = GetString(SI_SK_AUT_LOOT_TOOLTIP),
        icon = "/SwissKnife/textures/gui/swap-bag.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_UNWANTED_FILTER_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_UNWANTED_FILTER_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.filterUnwantedItemAfterLoot end,
                setFunc = function(v) SK.savedVars.filterUnwantedItemAfterLoot = v end,
                default = SK.defaultSavedVars.filterUnwantedItemAfterLoot,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_UNWANTED_FILTER_NEW_ONLY_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_UNWANTED_FILTER_NEW_ONLY_TOOLTIP),
                getFunc = function() return SK.savedVars.filterNewOnlyUnwantedItem end,
                setFunc = function(v) SK.savedVars.filterNewOnlyUnwantedItem = v end,
                disabled = function() return not SK.savedVars.filterUnwantedItemAfterLoot end,
                default = SK.defaultSavedVars.filterNewOnlyUnwantedItem,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_UNWANTED_DESTROY_PROTECTED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_UNWANTED_DESTROY_PROTECTED_TOOLTIP),
                getFunc = function() return SK.savedVars.destroyProtectedUnwantedItem end,
                setFunc = function(v) SK.savedVars.destroyProtectedUnwantedItem = v end,
                disabled = function() return not SK.savedVars.filterUnwantedItemAfterLoot end,
                default = SK.defaultSavedVars.destroyProtectedUnwantedItem,
                width = "full"
            },
            [4] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_UNWANTED_DESTROY_CRAFTED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_UNWANTED_DESTROY_CRAFTED_TOOLTIP),
                getFunc = function() return SK.savedVars.destroyCraftedUnwantedItem end,
                setFunc = function(v) SK.savedVars.destroyCraftedUnwantedItem = v end,
                disabled = function() return not SK.savedVars.filterUnwantedItemAfterLoot end,
                default = SK.defaultSavedVars.destroyCraftedUnwantedItem,
                width = "full"
            },
            [5] = {
                type = "divider",
                width = "full"
            },
            [6] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_UNWANTED_JUNK_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_UNWANTED_JUNK_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.junkUnwantedSetsAfterLoot end,
                setFunc = function(v) SK.savedVars.junkUnwantedSetsAfterLoot = v end,
                default = SK.defaultSavedVars.junkUnwantedSetsAfterLoot,
                width = "full"
            },
            [7] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_UNWANTED_DECONSTRUCT_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_UNWANTED_DECONSTRUCT_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.deconstructUnwantedSetsByQuality end,
                setFunc = function(v) SK.savedVars.deconstructUnwantedSetsByQuality = v end,
                disabled = function() return not SK.savedVars.junkUnwantedSetsAfterLoot end,
                default = SK.defaultSavedVars.deconstructUnwantedSetsByQuality,
                width = "full"
            },
            [8] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_UNWANTED_DECONSTRUCT_FCOIS_MARK_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_UNWANTED_DECONSTRUCT_FCOIS_MARK_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.markDeconstructUnwantedWithFCOIS end,
                setFunc = function(v) SK.savedVars.markDeconstructUnwantedWithFCOIS = v end,
                disabled = function() return not (SK.savedVars.junkUnwantedSetsAfterLoot and FCOIS) end,
                default = SK.defaultSavedVars.markDeconstructUnwantedWithFCOIS,
                width = "full"
            },
            [9] = {
                type = "divider",
                width = "full"
            },
            [10] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_JUNK_NON_SETS_EQUIPMENT_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_JUNK_NON_SETS_EQUIPMENT_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.junkNonSetEquipments end,
                setFunc = function(v) SK.savedVars.junkNonSetEquipments = v end,
                default = SK.defaultSavedVars.junkNonSetEquipments,
                width = "full"
            },
            [11] = {
                type = "dropdown",
                name = GetString(SI_SK_AUT_LOOT_JUNK_NON_SETS_EQUIPMENT_QUALITY_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_JUNK_NON_SETS_EQUIPMENT_QUALITY_TOOLTIP),
                choices = QualityChooses,
                getFunc = function() return QualityChooses[SK.savedVars.junkNonSetEquipmentQuality] end,
                setFunc = function(value)
                    local quality
                    for k, v in pairs(QualityChooses) do
                        if v == value then quality = k end
                    end
                    SK.savedVars.junkNonSetEquipmentQuality = quality
                end,
                disabled = function() return not SK.savedVars.junkNonSetEquipments end,
                default = SK.defaultSavedVars.junkNonSetEquipmentQuality,
                width = "full",
            },
            [12] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_DECONSTRUCT_NON_SETS_ARMOR_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_DECONSTRUCT_NON_SETS_ARMOR_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.deconstructNonSetArmorWeapon end,
                setFunc = function(v) SK.savedVars.deconstructNonSetArmorWeapon = v end,
                disabled = function() return not SK.savedVars.junkNonSetEquipments or not FCOIS end,
                default = SK.defaultSavedVars.deconstructNonSetArmorWeapon,
                width = "full"
            },
            [13] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_DECONSTRUCT_NON_SETS_JEWELRY_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_DECONSTRUCT_NON_SETS_JEWELRY_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.deconstructNonSetJewelry end,
                setFunc = function(v) SK.savedVars.deconstructNonSetJewelry = v end,
                disabled = function() return not SK.savedVars.junkNonSetEquipments or not FCOIS end,
                default = SK.defaultSavedVars.deconstructNonSetJewelry,
                width = "full"
            },
            [14] = {
                type = "divider",
                width = "full"
            },
            [15] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_UNWANTED_JUNK_KNOWN_ONLY_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_UNWANTED_JUNK_KNOWN_ONLY_TOOLTIP),
                getFunc = function() return SK.savedVars.junkKnownTraitOnly end,
                setFunc = function(v) SK.savedVars.junkKnownTraitOnly = v end,
                disabled = function() return not SK.savedVars.junkUnwantedSetsAfterLoot end,
                default = SK.defaultSavedVars.junkKnownTraitOnly,
                width = "full"
            },
            [16] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_JUNK_TREASURES_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_JUNK_TREASURES_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.junkTreasures end,
                setFunc = function(v) SK.savedVars.junkTreasures = v end,
                default = SK.defaultSavedVars.junkTreasures,
                width = "full"
            },
            [17] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_UNWANTED_JUNK_DECONSTRUCTED_TOO_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_UNWANTED_JUNK_DECONSTRUCTED_TOO_TOOLTIP),
                getFunc = function() return SK.savedVars.junkDeconstructedToo end,
                setFunc = function(v) SK.savedVars.junkDeconstructedToo = v end,
                disabled = function() return not SK.savedVars.junkUnwantedSetsAfterLoot end,
                default = SK.defaultSavedVars.junkDeconstructedToo,
                width = "full"
            },
            [18] = {
                type = "divider",
                width = "full"
            },
            [19] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_MARK_AS_JUNK_NOTIFICATION_NAME),
                tooltip = GetString(SI_SK_AUT_MARK_AS_JUNK_NOTIFICATION_TOOLTIP),
                getFunc = function() return SK.savedVars.enableMarkAsJunkNotification end,
                setFunc = function(v) SK.savedVars.enableMarkAsJunkNotification = v end,
                default = SK.defaultSavedVars.enableMarkAsJunkNotification,
                width = "full"
            },
            [20] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_MARK_FOR_DECONSTRUCT_NOTIFICATION_NAME),
                tooltip = GetString(SI_SK_AUT_MARK_FOR_DECONSTRUCT_NOTIFICATION_TOOLTIP),
                getFunc = function() return SK.savedVars.enableMarkForDeconstructNotification end,
                setFunc = function(v) SK.savedVars.enableMarkForDeconstructNotification = v end,
                default = SK.defaultSavedVars.enableMarkForDeconstructNotification,
                width = "full"
            },
            [21] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_DESTROYED_NOTIFICATION_NAME),
                tooltip = GetString(SI_SK_AUT_DESTROYED_NOTIFICATION_TOOLTIP),
                getFunc = function() return SK.savedVars.enableDestroyedNotification end,
                setFunc = function(v) SK.savedVars.enableDestroyedNotification = v end,
                default = SK.defaultSavedVars.enableDestroyedNotification,
                width = "full"
            },
        },
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_AUT_CRAFT_HEADER)),
        tooltip = GetString(SI_SK_AUT_CRAFT_TOOLTIP),
        icon = "/SwissKnife/textures/gui/forge.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_DECONSTRUCT_FCOIS_MARK_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_DECONSTRUCT_FCOIS_MARK_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.autoDeconstructFCOISMarked end,
                setFunc = function(v) SK.savedVars.autoDeconstructFCOISMarked = v end,
                disabled = function() return not FCOIS end,
                default = SK.defaultSavedVars.autoDeconstructFCOISMarked,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_CLOSE_AFTER_CRAFTED_DECONSTRUCT_TOO_NAME),
                tooltip = GetString(SI_SK_AUT_CLOSE_AFTER_CRAFTED_DECONSTRUCT_TOO_TOOLTIP),
                getFunc = function() return SK.savedVars.isDeconstructCraftedItems end,
                setFunc = function(v) SK.savedVars.isDeconstructCraftedItems = v end,
                disabled = function() return not FCOIS or not SK.savedVars.autoDeconstructFCOISMarked end,
                default = SK.defaultSavedVars.isDeconstructCraftedItems,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_REFINE_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_REFINE_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.autoRefineRawMaterial end,
                setFunc = function(v) SK.savedVars.autoRefineRawMaterial = v end,
                default = SK.defaultSavedVars.autoRefineRawMaterial,
                width = "full"
            },
            [4] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_REFINE_IF_SKILL_MAXED_NAME),
                tooltip = GetString(SI_SK_AUT_REFINE_IF_SKILL_MAXED_TOOLTIP),
                getFunc = function() return SK.savedVars.autoRefineIfSkillMaxed end,
                setFunc = function(v) SK.savedVars.autoRefineIfSkillMaxed = v end,
                default = SK.defaultSavedVars.autoRefineIfSkillMaxed,
                disabled = function() return not SK.savedVars.autoRefineRawMaterial end,
                width = "full"
            },
            [5] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_REFINE_IF_ESO_PLUS_NAME),
                tooltip = GetString(SI_SK_AUT_REFINE_IF_ESO_PLUS_TOOLTIP),
                getFunc = function() return SK.savedVars.autoRefineIfESOPlus end,
                setFunc = function(v) SK.savedVars.autoRefineIfESOPlus = v end,
                default = SK.defaultSavedVars.autoRefineIfESOPlus,
                disabled = function() return not SK.savedVars.autoRefineRawMaterial end,
                width = "full"
            },
            [6] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_FILLET_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_FILLET_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.autoFilletFish end,
                setFunc = function(v) SK.savedVars.autoFilletFish = v end,
                default = SK.defaultSavedVars.autoFilletFish,
                width = "full"
            },
            [7] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_CLOSE_AFTER_AUTO_DECONSTRUCT_NAME),
                tooltip = GetString(SI_SK_AUT_CLOSE_AFTER_AUTO_DECONSTRUCT_TOOLTIP),
                getFunc = function() return SK.savedVars.isCloseCraftStationAfterDeconstruction end,
                setFunc = function(v) SK.savedVars.isCloseCraftStationAfterDeconstruction = v end,
                disabled = function() return not SK.savedVars.deconstructUnwantedSetsByQuality and not SK.savedVars.autoDeconstructFCOISMarked end,
                default = SK.defaultSavedVars.isCloseCraftStationAfterDeconstruction,
                width = "full"
            },
            [8] = {
                type = "divider",
                width = "full"
            },
            [9] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_USE_INTRICATE_FOR_CRAFT_TRAINING_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_USE_INTRICATE_FOR_CRAFT_TRAINING_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.useIntricateForCraftTraining end,
                setFunc = function(v) SK.savedVars.useIntricateForCraftTraining = v end,
                default = SK.defaultSavedVars.useIntricateForCraftTraining,
                width = "full"
            },
            [10] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_MARK_INTRICATE_FOR_CRAFT_TRAINING_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_MARK_INTRICATE_FOR_CRAFT_TRAINING_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.markIntricateForCraftTraining end,
                setFunc = function(v) SK.savedVars.markIntricateForCraftTraining = v end,
                disabled = function() return not FCOIS or not SK.savedVars.useIntricateForCraftTraining end,
                default = SK.defaultSavedVars.markIntricateForCraftTraining,
                width = "full"
            },
            [11] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_JUNK_IF_CRAFT_LEVEL_MAXIMAL_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_JUNK_IF_CRAFT_LEVEL_MAXIMAL_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.junkIntricateIfCraftMaximize end,
                setFunc = function(v) SK.savedVars.junkIntricateIfCraftMaximize = v end,
                disabled = function() return not FCOIS or not SK.savedVars.useIntricateForCraftTraining end,
                default = SK.defaultSavedVars.junkIntricateIfCraftMaximize,
                width = "full"
            },
            [12] = {
                type = "divider",
                width = "full"
            },
            [13] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_USE_GLYPHS_FOR_CRAFT_TRAINING_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_USE_GLYPHS_FOR_CRAFT_TRAINING_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.useGlyphsForCraftTraining end,
                setFunc = function(v) SK.savedVars.useGlyphsForCraftTraining = v end,
                default = SK.defaultSavedVars.useGlyphsForCraftTraining,
                width = "full"
            },
            [14] = {
                type = "dropdown",
                name = GetString(SI_SK_AUT_LOOT_USE_GLYPHS_FOR_CRAFT_TRAINING_QUALITY_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_USE_GLYPHS_FOR_CRAFT_TRAINING_QUALITY_TOOLTIP),
                choices = QualityChooses,
                getFunc = function() return QualityChooses[SK.savedVars.useGlyphsForCraftTrainingQuality] end,
                setFunc = function(value)
                    local quality
                    for k, v in pairs(QualityChooses) do
                        if v == value then quality = k end
                    end
                    SK.savedVars.useGlyphsForCraftTrainingQuality = quality
                end,
                disabled = function() return not SK.savedVars.useGlyphsForCraftTraining end,
                default = SK.defaultSavedVars.useGlyphsForCraftTrainingQuality,
                width = "full",
            },
            [15] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_MARK_GLYPHS_FOR_CRAFT_TRAINING_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_MARK_GLYPHS_FOR_CRAFT_TRAINING_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.markGlyphsForCraftTraining end,
                setFunc = function(v) SK.savedVars.markGlyphsForCraftTraining = v end,
                disabled = function() return not FCOIS or not SK.savedVars.useGlyphsForCraftTraining end,
                default = SK.defaultSavedVars.markGlyphsForCraftTraining,
                width = "full"
            },
            [16] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LOOT_JUNK_IF_CRAFT_LEVEL_MAXIMAL_ENABLED_NAME),
                tooltip = GetString(SI_SK_AUT_LOOT_JUNK_IF_CRAFT_LEVEL_MAXIMAL_ENABLED_TOOLTIP),
                getFunc = function() return SK.savedVars.junkGlyphsIfCraftMaximize end,
                setFunc = function(v) SK.savedVars.junkGlyphsIfCraftMaximize = v end,
                disabled = function() return not SK.savedVars.useGlyphsForCraftTraining end,
                default = SK.defaultSavedVars.junkGlyphsIfCraftMaximize,
                width = "full"
            },
            [17] = {
                type = "divider",
                width = "full"
            },
            [18] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_DECONSTRUCTED_NOTIFICATION_NAME),
                tooltip = GetString(SI_SK_AUT_DECONSTRUCTED_NOTIFICATION_TOOLTIP),
                getFunc = function() return SK.savedVars.enableHasBeenDeconstructedNotification end,
                setFunc = function(v) SK.savedVars.enableHasBeenDeconstructedNotification = v end,
                disabled = function() return not SK.savedVars.deconstructUnwantedSetsByQuality and not SK.savedVars.autoDeconstructFCOISMarked end,
                default = SK.defaultSavedVars.enableHasBeenDeconstructedNotification,
                width = "full"
            },
            [19] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_REFINED_NOTIFICATION_NAME),
                tooltip = GetString(SI_SK_AUT_REFINED_NOTIFICATION_TOOLTIP),
                getFunc = function() return SK.savedVars.enableHasBeenRefinedNotification end,
                setFunc = function(v) SK.savedVars.enableHasBeenRefinedNotification = v end,
                disabled = function() return not SK.savedVars.autoRefineRawMaterial end,
                default = SK.defaultSavedVars.enableHasBeenRefinedNotification,
                width = "full"
            },
            [20] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_FILLET_NOTIFICATION_NAME),
                tooltip = GetString(SI_SK_AUT_FILLET_NOTIFICATION_TOOLTIP),
                getFunc = function() return SK.savedVars.enableHasBeenFilletNotification end,
                setFunc = function(v) SK.savedVars.enableHasBeenFilletNotification = v end,
                disabled = function() return not SK.savedVars.autoFilletFish end,
                default = SK.defaultSavedVars.enableHasBeenFilletNotification,
                width = "full"
            },
        },
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_AUT_STOLEN_HEADER)),
        tooltip = GetString(SI_SK_AUT_STOLEN_TOOLTIP),
        icon = "/SwissKnife/textures/gui/robber.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_STOLEN_PICKY_THIEF_NAME),
                tooltip = GetString(SI_SK_AUT_STOLEN_PICKY_THIEF_TOOLTIP),
                getFunc = function() return SK.savedVars.isPickyThiefEnabled end,
                setFunc = function(v) SK.savedVars.isPickyThiefEnabled = v end,
                default = SK.defaultSavedVars.isPickyThiefEnabled,
                width = "full"
            },
            [2] = {
                type = "dropdown",
                name = GetString(SI_SK_AUT_LOW_QUALITY_STEALING_NAME),
                choices = QualityChooses,
                getFunc = function() return QualityChooses[SK.savedVars.lowQualityStealing] end,
                setFunc = function(value)
                    local quality
                    for k, v in pairs(QualityChooses) do
                        if v == value then quality = k end
                    end
                    SK.savedVars.lowQualityStealing = quality
                end,
                disabled = function() return not SK.savedVars.isPickyThiefEnabled end,
                default = SK.savedVars.lowQualityStealing,
                width = "full",
            },
            [3] = {
                type = "editbox",
                name = GetString(SI_SK_AUT_LOW_COST_STEALING_NAME),
                getFunc = function() return SK.savedVars.lowCostStealing end,
                setFunc = function(v) SK.savedVars.lowCostStealing = tonumber(v) end,
                default = SK.defaultSavedVars.lowCostStealing,
                disabled = function() return not SK.savedVars.isPickyThiefEnabled end,
                width = "full"
            },
            [4] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_STOLEN_PREVENT_UNSAFE_STEALING_NAME),
                tooltip = GetString(SI_SK_AUT_STOLEN_PREVENT_UNSAFE_STEALING_TOOLTIP),
                getFunc = function() return SK.savedVars.preventUnsafeStealing end,
                setFunc = function(v) SK.savedVars.preventUnsafeStealing = v end,
                default = SK.defaultSavedVars.preventUnsafeStealing,
                width = "full"
            },
            [5] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_STOLEN_PREVENT_PICKPOCKET_WITHOUT_BONUS_NAME),
                tooltip = GetString(SI_SK_AUT_STOLEN_PREVENT_PICKPOCKET_WITHOUT_BONUS_TOOLTIP),
                getFunc = function() return SK.savedVars.preventPickpocketWithoutBonus end,
                setFunc = function(v) SK.savedVars.preventPickpocketWithoutBonus = v end,
                default = SK.defaultSavedVars.preventPickpocketWithoutBonus,
                disabled = function() return not SK.savedVars.preventUnsafeStealing end,
                width = "full"
            },
            [6] = {
                type = "divider",
                width = "full"
            },
            [7] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_STOLEN_SMART_SALE_NAME),
                tooltip = GetString(SI_SK_AUT_STOLEN_SMART_SALE_TOOLTIP),
                getFunc = function() return SK.savedVars.isSmartSaleEnabled end,
                setFunc = function(v) SK.savedVars.isSmartSaleEnabled = v end,
                default = SK.defaultSavedVars.isSmartSaleEnabled,
                width = "full"
            },
            [8] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_AUTO_LAUNDER_NAME),
                tooltip = GetString(SI_SK_AUT_AUTO_LAUNDER_TOOLTIP),
                getFunc = function() return SK.savedVars.isAutoLaunderEnabled end,
                setFunc = function(v) SK.savedVars.isAutoLaunderEnabled = v end,
                default = SK.defaultSavedVars.isAutoLaunderEnabled,
                width = "full"
            },
            [9] = {
                type = "divider",
                width = "full"
            },
            [10] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_SELL_NOTIFICATION_NAME),
                tooltip = GetString(SI_SK_AUT_SELL_NOTIFICATION_TOOLTIP),
                getFunc = function() return SK.savedVars.enableHasBeenSellNotification end,
                setFunc = function(v) SK.savedVars.enableHasBeenSellNotification = v end,
                disabled = function() return not SK.savedVars.isSmartSaleEnabled end,
                default = SK.defaultSavedVars.enableHasBeenSellNotification,
                width = "full"
            },
            [11] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_LAUNDER_NOTIFICATION_NAME),
                tooltip = GetString(SI_SK_AUT_LAUNDER_NOTIFICATION_TOOLTIP),
                getFunc = function() return SK.savedVars.enableHasBeenLaunderNotification end,
                setFunc = function(v) SK.savedVars.enableHasBeenLaunderNotification = v end,
                disabled = function() return not SK.savedVars.isAutoLaunderEnabled end,
                default = SK.defaultSavedVars.enableHasBeenLaunderNotification,
                width = "full"
            },
        },
    })

    local controlsCollections = {
        [1] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_LOOT_BIND_UNKNOWN_COLLECTABLES_PARTS_NAME),
            tooltip = GetString(SI_SK_AUT_LOOT_BIND_UNKNOWN_COLLECTABLES_PARTS_TOOLTIP),
            getFunc = function() return SK.savedVars.bindUnknownCollectablesSetItems end,
            setFunc = function(v) SK.savedVars.bindUnknownCollectablesSetItems = v end,
            default = SK.defaultSavedVars.bindUnknownCollectablesSetItems,
            width = "full"
        },
        [2] = {
            type = "checkbox",
            name = GetString(SI_SK_INTERFACE_I_SHOW_COLLECTABLES_INFO_NAME),
            tooltip = GetString(SI_SK_INTERFACE_I_SHOW_COLLECTABLES_INFO_TOOLTIP),
            getFunc = function() return SK.savedVars.showCollectablesSetItemExtraTooltip end,
            setFunc = function(v) SK.savedVars.showCollectablesSetItemExtraTooltip = v end,
            default = SK.defaultSavedVars.showCollectablesSetItemExtraTooltip,
            requiresReload = true,
            width = "full"
        },
        [3] = {
			type = "slider",
			name = GetString(SI_SK_INTERFACE_I_COLLECTABLES_ICON_X_NAME),
            tooltip = GetString(SI_SK_INTERFACE_I_COLLECTABLES_ICON_X_TOOLTIP),
			min = -100,
			max = 100,
			step = 1,
			inputLocation = "bottom",
			clampInput = true,
            decimals = 0,
            getFunc = function() return SK.savedVars.collectablesSetItemIconX end,
            setFunc = function(v) SK.savedVars.collectablesSetItemIconX = v end,
            disabled = function() return not SK.savedVars.showCollectablesSetItemExtraTooltip end,
            default = SK.defaultSavedVars.collectablesSetItemIconX,
            requiresReload = true,
        },
        [4] = {
			type = "slider",
			name = GetString(SI_SK_INTERFACE_I_COLLECTABLES_ICON_Y_NAME),
            tooltip = GetString(SI_SK_INTERFACE_I_COLLECTABLES_ICON_Y_TOOLTIP),
			min = -16,
			max = 16,
			step = 1,
			inputLocation = "bottom",
			clampInput = true,
			decimals = 0,
            getFunc = function() return SK.savedVars.collectablesSetItemIconY end,
            setFunc = function(v) SK.savedVars.collectablesSetItemIconY = v end,
            disabled = function() return not SK.savedVars.showCollectablesSetItemExtraTooltip end,
            default = SK.defaultSavedVars.collectablesSetItemIconY,
            requiresReload = true,
        },
        [5] = {
            type = "checkbox",
            name = GetString(SI_SK_INTERFACE_I_HIDE_COLLECTABLES_UNLOCKED_NAME),
            tooltip = GetString(SI_SK_INTERFACE_I_HIDE_COLLECTABLES_UNLOCKED_TOOLTIP),
            getFunc = function() return SK.savedVars.hideUnlockedCollectablesSetItemOnTooltip end,
            setFunc = function(v) SK.savedVars.hideUnlockedCollectablesSetItemOnTooltip = v end,
            disabled = function() return not SK.savedVars.showCollectablesSetItemExtraTooltip end,
            default = SK.defaultSavedVars.hideUnlockedCollectablesSetItemOnTooltip,
            width = "full"
        },
        [6] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_TRACK_COLLECTABLES_ITEMS_NAME),
            tooltip = GetString(SI_SK_AUT_TRACK_COLLECTABLES_ITEMS_TOOLTIP),
            getFunc = function() return SK.savedVars.trackAccountsCollectionsItems end,
            setFunc = function(v) SK.savedVars.trackAccountsCollectionsItems = v end,
            default = SK.defaultSavedVars.trackAccountsCollectionsItems,
            requiresReload = true,
            width = "full"
        },
    }

    local index = 6
    for accName, _ in pairs(SK.savedVars.trackItemsAccountsNames) do
        if accName ~= SK.AccName then
            index = index + 1
            controlsCollections[index] = {
                type = "checkbox",
                name = accName,
                getFunc = function() return SK.savedVars.trackItemsAccountsNames[accName] == SK.TRUE end,
                setFunc = function(v)
                    if v then
                        SK.savedVars.trackItemsAccountsNames[accName] = SK.TRUE
                    else
                        SK.savedVars.trackItemsAccountsNames[accName] = SK.FALSE
                    end
                end,
                disabled = function() return not SK.savedVars.trackAccountsCollectionsItems end,
                default = SK.TRUE,
                width = "full",
            }
        end
    end

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_AUT_COLLECTIONS_SETS_TEXT)),
        icon = "/SwissKnife/textures/gui/sets.dds",
        controls = controlsCollections
    })

    local controlsSKMail = {
        [1] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_MAILER_RECEIPT_MAIL_LOOT_MODE_NAME),
            tooltip = GetString(SI_SK_AUT_MAILER_RECEIPT_MAIL_LOOT_MODE_TOOLTIP),
            getFunc = function() return SK.savedVars.isAutomaticModeReceiptMail end,
            setFunc = function(v) SK.savedVars.isAutomaticModeReceiptMail = v end,
            default = SK.defaultSavedVars.isAutomaticModeReceiptMail,
            width = "full",
        },
        [2] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_MAILER_SYSTEM_MAIL_AUTO_LOOT_NAME),
            tooltip = GetString(SI_SK_AUT_MAILER_SYSTEM_MAIL_AUTO_LOOT_TOOLTIP),
            getFunc = function() return SK.savedVars.isAutomaticResourcesMailReceiptEnabled end,
            setFunc = function(v) SK.savedVars.isAutomaticResourcesMailReceiptEnabled = v end,
            default = SK.defaultSavedVars.isAutomaticResourcesMailReceiptEnabled,
            width = "full",
        },
        [3] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_MAILER_AUTO_LOOT_ESO_PLUS_ONLY_NAME),
            tooltip = GetString(SI_SK_AUT_MAILER_AUTO_LOOT_ESO_PLUS_TOOLTIP),
            getFunc = function() return SK.savedVars.useAutomaticReceiptWhenESOPlusOnly end,
            setFunc = function(v) SK.savedVars.useAutomaticReceiptWhenESOPlusOnly = v end,
            default = SK.defaultSavedVars.useAutomaticReceiptWhenESOPlusOnly,
            width = "full",
        },
        [4] = {
            type = "dropdown",
            name = GetString(SI_SK_AUT_MAILER_AUTO_LOOT_WHO_CAN_NAME),
            tooltip = GetString(SI_SK_AUT_MAILER_AUTO_LOOT_WHO_CAN_TOOLTIP),
            choices = choicesWhoMust,
            getFunc = function()
                if IsESOPlusSubscriber() then
                    return reverseMappingWhoMust[SK.WHO_MUST_RECEIPT_DATA.ANYONE]
                else
                    local character = SK.savedVars.whoMustReceiptMailWithoutESOPlus[SK.AccName]
                    if not character then return reverseMappingWhoMust[SK.WHO_MUST_RECEIPT_DATA.NO_ONE] end
                    return reverseMappingWhoMust[character]
                end
            end,
            setFunc = function(value) SK.savedVars.whoMustReceiptMailWithoutESOPlus[SK.AccName] = mappingWhoMust[value] end,
            disabled = function() return SK.savedVars.useAutomaticReceiptWhenESOPlusOnly or
                    not SK.savedVars.isAutomaticResourcesMailReceiptEnabled end,
            default = function()
                if IsESOPlusSubscriber() then
                    return reverseMappingWhoMust[SK.WHO_MUST_RECEIPT_DATA.ANYONE]
                else
                    return reverseMappingWhoMust[SK.WHO_MUST_RECEIPT_DATA.NO_ONE]
                end
            end,
            width = "full",
        },
        [5] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_MAILER_REPEAT_RECEIPT_AFTER_FAILURE_HEADER),
            tooltip = GetString(SI_SK_AUT_MAILER_REPEAT_RECEIPT_AFTER_FAILURE_TOOLTIP),
            getFunc = function() return SK.savedVars.repeatReceiptMailAfterFailure end,
            setFunc = function(v) SK.savedVars.repeatReceiptMailAfterFailure = v end,
            default = SK.defaultSavedVars.repeatReceiptMailAfterFailure,
            width = "full",
        },
        [6] = {
            type = "editbox",
            name = GetString(SI_SK_AUT_MAILER_MAXIMUM_RECEIPT_REPEATS_HEADER),
            tooltip = GetString(SI_SK_AUT_MAILER_MAXIMUM_RECEIPT_REPEATS_TOOLTIP),
            getFunc = function() return SK.savedVars.maximumMailReceiptFailureCount end,
            setFunc = function(v) SK.savedVars.maximumMailReceiptFailureCount = tonumber(v) end,
            disabled = function() return not SK.savedVars.repeatReceiptMailAfterFailure end,
            default = SK.defaultSavedVars.maximumMailReceiptFailureCount,
            width = "full",
        },
        [7] = {
            type = "editbox",
            name = GetString(SI_SK_AUT_MAILER_FAILURE_RECEIPT_TIMEOUT_HEADER),
            tooltip = GetString(SI_SK_AUT_MAILER_FAILURE_RECEIPT_TIMEOUT_TOOLTIP),
            getFunc = function() return SK.savedVars.failureReceiptMailTimeout end,
            setFunc = function(v) SK.savedVars.failureReceiptMailTimeout = tonumber(v) end,
            disabled = function() return not SK.savedVars.repeatReceiptMailAfterFailure end,
            default = SK.defaultSavedVars.failureReceiptMailTimeout,
            width = "full",
        },
        [8] = {
            type = "divider",
            width = "full"
        },
        [9] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_MAILER_AUTO_MODE_HEADER),
            tooltip = GetString(SI_SK_AUT_MAILER_AUTO_MODE_TOOLTIP),
            getFunc = function() return SK.savedVars.isAutomaticModeSendMail end,
            setFunc = function(v) SK.savedVars.isAutomaticModeSendMail = v end,
            default = SK.defaultSavedVars.isAutomaticModeSendMail,
            width = "full",
        },
        [10] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_MAILER_ENABLE_HEADER),
            tooltip = GetString(SI_SK_AUT_MAILER_ENABLE_TOOLTIP),
            getFunc = function() return SK.savedVars.sendMailToAnotherAccount end,
            setFunc = function(v) SK.savedVars.sendMailToAnotherAccount = v end,
            default = SK.defaultSavedVars.sendMailToAnotherAccount,
            width = "full"
        },
        [11] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_MAILER_FULL_MAIL_ONLY_HEADER),
            tooltip = GetString(SI_SK_AUT_MAILER_FULL_MAIL_ONLY_TOOLTIP),
            getFunc = function() return SK.savedVars.sendFullMailOnly end,
            setFunc = function(v) SK.savedVars.sendFullMailOnly = v end,
            disabled = function() return not SK.savedVars.sendMailToAnotherAccount end,
            default = SK.defaultSavedVars.sendFullMailOnly,
            width = "full",
        },
        [12] = {
            type = "editbox",
            name = GetString(SI_SK_AUT_MAILER_DELAY_HEADER),
            tooltip = GetString(SI_SK_AUT_MAILER_DELAY_TOOLTIP),
            getFunc = function() return SK.savedVars.sendMailToAnotherAccountDelay end,
            setFunc = function(v) SK.savedVars.sendMailToAnotherAccountDelay = tonumber(v) end,
            disabled = function() return not SK.savedVars.sendMailToAnotherAccount end,
            default = SK.defaultSavedVars.sendMailToAnotherAccountDelay,
            width = "full",
        },
        [13] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_MAILER_REPEAT_AFTER_FAILURE_HEADER),
            tooltip = GetString(SI_SK_AUT_MAILER_REPEAT_AFTER_FAILURE_TOOLTIP),
            getFunc = function() return SK.savedVars.repeatSendMailAfterFailure end,
            setFunc = function(v) SK.savedVars.repeatSendMailAfterFailure = v end,
            disabled = function() return not SK.savedVars.sendMailToAnotherAccount end,
            default = SK.defaultSavedVars.repeatSendMailAfterFailure,
            width = "full",
        },
        [14] = {
            type = "editbox",
            name = GetString(SI_SK_AUT_MAILER_MAXIMUM_REPEATS_HEADER),
            tooltip = GetString(SI_SK_AUT_MAILER_MAXIMUM_REPEATS_TOOLTIP),
            getFunc = function() return SK.savedVars.maximumMailSendFailureCount end,
            setFunc = function(v) SK.savedVars.maximumMailSendFailureCount = tonumber(v) end,
			disabled = function() return not SK.savedVars.sendMailToAnotherAccount or
                not SK.savedVars.repeatSendMailAfterFailure end,
            default = SK.defaultSavedVars.maximumMailSendFailureCount,
            width = "full",
        },
        [15] = {
            type = "editbox",
            name = GetString(SI_SK_AUT_MAILER_FAILURE_TIMEOUT_HEADER),
            tooltip = GetString(SI_SK_AUT_MAILER_FAILURE_TIMEOUT_TOOLTIP),
            getFunc = function() return SK.savedVars.failureSendMailTimeout end,
            setFunc = function(v) SK.savedVars.failureSendMailTimeout = tonumber(v) end,
			disabled = function() return not SK.savedVars.sendMailToAnotherAccount or
                not SK.savedVars.repeatSendMailAfterFailure end,
            default = SK.defaultSavedVars.failureSendMailTimeout,
            width = "full",
        },
    }

    index = 15
    for key, _ in pairs(SK.savedVars.sendMailByTypeOptions) do
        controlsSKMail[index] = {
            type = "divider",
            width = "full"
        }
        index = index + 1
		controlsSKMail[index] = {
            type = "editbox",
            name = GetString("SI_SK_AUT_MAILER_PRESET_NAME", key),
            tooltip = GetString("SI_SK_AUT_MAILER_PRESET_TOOLTIP", key),
            getFunc = function() return SK.savedVars.sendMailByTypeOptions[key].recipient end,
            setFunc = function(v) SK.savedVars.sendMailByTypeOptions[key].recipient = v end,
			disabled = function() return not SK.savedVars.sendMailToAnotherAccount end,
            default = SK.defaultSavedVars.sendMailByTypeOptions[key].recipient,
            width = "full",
        }
        index = index + 1
        if SK.savedVars.sendMailByTypeOptions[key].quality then
            controlsSKMail[index] = {
                type = "dropdown",
                name = GetString("SI_SK_AUT_MAILER_PRESET_QUALITY_NAME", key),
                tooltip = GetString("SI_SK_AUT_MAILER_PRESET_QUALITY_TOOLTIP", key),
                choices = QualityChooses,
                getFunc = function() return QualityChooses[SK.savedVars.sendMailByTypeOptions[key].quality] end,
                setFunc = function(value)
                    local quality
                    for k, v in pairs(QualityChooses) do
                        if v == value then quality = k end
                    end
                    SK.savedVars.sendMailByTypeOptions[key].quality = quality
                end,
                disabled = function() return
                    not SK.savedVars.sendMailToAnotherAccount or
                    not SK.savedVars.sendMailByTypeOptions[key].recipient or
                    SK.savedVars.sendMailByTypeOptions[key].recipient == ""
                    end,
                default = SK.defaultSavedVars.sendMailByTypeOptions[key].quality,
                width = "full",
            }
            index = index + 1
        end
        if key == SK.ATTACHMENT_TYPES.INTRICATE then
            controlsSKMail[index] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_MAILER_PRESET_JEWELRY_EXCLUDE_NAME),
                tooltip = GetString(SI_SK_AUT_MAILER_PRESET_JEWELRY_EXCLUDE_TOOLTIP),
                getFunc = function() return SK.savedVars.sendMailByTypeOptions[key].isJewelryExclude end,
                setFunc = function(v) SK.savedVars.sendMailByTypeOptions[key].isJewelryExclude = v end,
                disabled = function() return
                    not SK.savedVars.sendMailToAnotherAccount or
                    not SK.savedVars.sendMailByTypeOptions[key].recipient or
                    SK.savedVars.sendMailByTypeOptions[key].recipient == ""
                end,
                default = SK.defaultSavedVars.sendMailByTypeOptions[key].isJewelryExclude,
                width = "full",
            }
            index = index + 1
        elseif key == SK.ATTACHMENT_TYPES.RESOURCES then
            controlsSKMail[index] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_MAILER_PRESET_SMART_SEND_NAME),
                tooltip = GetString(SI_SK_AUT_MAILER_PRESET_SMART_SEND_TOOLTIP),
                getFunc = function() return SK.savedVars.sendMailByTypeOptions[key].isSmartSendEnabled end,
                setFunc = function(v) SK.savedVars.sendMailByTypeOptions[key].isSmartSendEnabled = v end,
                disabled = function() return not SK.savedVars.sendMailToAnotherAccount end,
                default = SK.defaultSavedVars.sendMailByTypeOptions[key].isSmartSendEnabled,
                width = "full",
            }
            index = index + 1
            controlsSKMail[index] = {
                type = "checkbox",
                name = GetString(SI_SK_AUT_MAILER_PRESET_AUTO_LOOT_NAME),
                tooltip = GetString(SI_SK_AUT_MAILER_PRESET_AUTO_LOOT_TOOLTIP),
                getFunc = function() return SK.savedVars.sendMailByTypeOptions[key].isAutomaticReceiptEnabled end,
                setFunc = function(v) SK.savedVars.sendMailByTypeOptions[key].isAutomaticReceiptEnabled = v end,
                disabled = function() return not SK.savedVars.sendMailToAnotherAccount end,
                default = SK.defaultSavedVars.sendMailByTypeOptions[key].isAutomaticReceiptEnabled,
                width = "full",
            }
            index = index + 1
        end
	end

    table.insert(optionsTable, {
        type = "submenu",
        name = GetString(SI_SK_AUT_MAILER_HEADER),
        tooltip = GetString(SI_SK_AUT_MAILER_TOOLTIP),
        icon = "/SwissKnife/textures/gui/envelope.dds",
        controls = controlsSKMail
    })

    local controlsRiddingTraining = {
        [1] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_RIDING_TRAIN_ENABLE_NAME),
            tooltip = GetString(SI_SK_AUT_RIDING_TRAIN_ENABLE_TOOLTIP),
            getFunc = function() return SK.savedVars.stableTrainEnabled end,
            setFunc = function(v) SK.savedVars.stableTrainEnabled = v end,
            default = SK.defaultSavedVars.stableTrainEnabled,
            width = "full"
        },
    }

    for i = 1, #SK.savedVars.stableTrainOrder do
		controlsRiddingTraining[2*i] = {
            type = "dropdown",
            name = SKH.getFormattedText(GetString(SI_SK_AUT_RIDING_TRAIN_ORDER_NAME), i),
            tooltip = SKH.getFormattedText(GetString(SI_SK_AUT_RIDING_TRAIN_ORDER_TOOLTIP), i),
            choices = TrainNames,
            getFunc = function() return TrainNames[SK.savedVars.stableTrainOrder[i]] end,
            setFunc = function(value)
                local stableTrainOrder = SK.savedVars.stableTrainOrder
                local newNum
                for k, v in pairs(TrainNames) do if v == value then newNum = k end end
                local oldSpot
                for j = 1, #SK.savedVars.stableTrainOrder do if stableTrainOrder[j] == newNum then oldSpot = j end end
                local currentPriority = stableTrainOrder[i]
                stableTrainOrder[i] = newNum
                stableTrainOrder[oldSpot] = currentPriority
            end,
            disabled = function() return not SK.savedVars.stableTrainEnabled end,
            width = "full",
        }
        controlsRiddingTraining[2*i+1] = {
			type = "slider",
			name = SKH.getFormattedText(GetString(SI_SK_AUT_RIDING_TRAIN_THRESHOLD_NAME), i),
            tooltip = GetString(SI_SK_AUT_RIDING_TRAIN_THRESHOLD_TOOLTIP),
			min = 0,
			max = 60,
			step = 1,
			inputLocation = "bottom",
			clampInput = true,
			decimals = 0,
            getFunc = function() return SK.savedVars.stableTrainThreshold[SK.savedVars.stableTrainOrder[i]] end,
            setFunc = function(v) SK.savedVars.stableTrainThreshold[SK.savedVars.stableTrainOrder[i]] = v end,
            disabled = function() return not SK.savedVars.stableTrainEnabled end,
            default = SK.defaultSavedVars.stableTrainThreshold[SK.savedVars.stableTrainOrder[i]],
		}
	end
    controlsRiddingTraining[8] = {
        type = "dropdown",
        name = GetString(SI_SK_AUT_RIDING_TRAIN_AFTER_THRESHOLD_RULE_NAME),
        tooltip = GetString(SI_SK_AUT_RIDING_TRAIN_AFTER_THRESHOLD_TOOLTIP),
        choices = AfterThresholdTrainRule,
        getFunc = function() return AfterThresholdTrainRule[SK.savedVars.stableAfterThresholdTrainRule] end,
        setFunc = function(v)
            local rule
            for key, value in pairs(AfterThresholdTrainRule) do if v == value then rule = key end end
            SK.savedVars.stableAfterThresholdTrainRule = rule
        end,
        disabled = function() return not SK.savedVars.stableTrainEnabled end,
        default = SK.defaultSavedVars.stableAfterThresholdTrainRule,
        width = "full",
    }

    table.insert(optionsTable, {
        type = "submenu",
        name = GetString(SI_SK_AUT_RIDING_TRAIN_HEADER),
        tooltip = GetString(SI_SK_AUT_RIDING_TRAIN_TOOLTIP),
        icon = "/esoui/art/icons/mapkey/mapkey_stables.dds",
        controls = controlsRiddingTraining
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_MISC_DAILY_HEADER)),
        icon = "/SwissKnife/textures/gui/calendar.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_MISC_DAILY_MAGE_NAME),
                tooltip = GetString(SI_SK_MISC_DAILY_MAGE_TOOLTIP),
                getFunc = function() return SK.savedVars.dailyQuestAcceptOptions.mage end,
                setFunc = function(value) SK.savedVars.dailyQuestAcceptOptions.mage = value end,
                default = function() return SK.defaultSavedVars.dailyQuestAcceptOptions.mage end,
                width = "full",
            },
            [2] = {
                type = "checkbox",
                name = GetString(SI_SK_MISC_DAILY_FIGHTERS_NAME),
                tooltip = GetString(SI_SK_MISC_DAILY_FIGHTERS_TOOLTIP),
                getFunc = function() return SK.savedVars.dailyQuestAcceptOptions.fighters end,
                setFunc = function(value) SK.savedVars.dailyQuestAcceptOptions.fighters = value end,
                default = function() return SK.defaultSavedVars.dailyQuestAcceptOptions.fighters end,
                width = "full",
            },
            [3] = {
                type = "checkbox",
                name = GetString(SI_SK_MISC_DAILY_UNDAUNTED_NAME),
                tooltip = GetString(SI_SK_MISC_DAILY_UNDAUNTED_TOOLTIP),
                getFunc = function() return SK.savedVars.dailyQuestAcceptOptions.undaunted end,
                setFunc = function(value) SK.savedVars.dailyQuestAcceptOptions.undaunted = value end,
                default = function() return SK.defaultSavedVars.dailyQuestAcceptOptions.undaunted end,
                width = "full",
            },
            [4] = {
                type = "checkbox",
                name = GetString(SI_SK_MISC_DAILY_QUEST_HELPER_ENABLE_NAME),
                tooltip = GetString(SI_SK_MISC_DAILY_QUEST_HELPER_ENABLE_TOOLTIP),
                getFunc = function() return SK.savedVars.enableDailyQuestHelper end,
                setFunc = function(value) SK.savedVars.enableDailyQuestHelper = value end,
                default = function() return SK.defaultSavedVars.enableDailyQuestHelper end,
                width = "full",
            },
        }
    })

    local controlsMisc = {
        [1] = {
            type = "checkbox",
            name = GetString(SI_SK_AUT_MISC_AUTO_FILL_DESTROY_ITEM_CONFIRMATION_NAME),
            tooltip = GetString(SI_SK_AUT_MISC_AUTO_FILL_DESTROY_ITEM_CONFIRMATION_TOOLTIP),
            getFunc = function() return SK.savedVars.autoFillDestroyItemConfirmation end,
            setFunc = function(value) SK.savedVars.autoFillDestroyItemConfirmation = value end,
            default = function() return SK.defaultSavedVars.autoFillDestroyItemConfirmation end,
            width = "full",
        },
        --[2] = {
        --    type = "checkbox",
        --    name = GetString(SI_SK_AUT_MISC_LOGOUT_QUIT_CONFIRM_NAME),
        --    tooltip = GetString(SI_SK_AUT_MISC_LOGOUT_QUIT_CONFIRM_TOOLTIP),
        --    getFunc = function() return SK.savedVars.enableLogoutOrQuitConfirmation end,
        --    setFunc = function(value) SK.savedVars.enableLogoutOrQuitConfirmation = value end,
        --    default = function() return SK.defaultSavedVars.enableLogoutOrQuitConfirmation end,
        --    width = "full",
        --},
    }

    --controlsMisc = SKH.makeMenuControls(controlsMisc, "AutMisc", 2)

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_INTERFACE_MISC_HEADER)),
        icon = "/SwissKnife/textures/gui/misc.dds",
        controls = controlsMisc
    })

    table.insert(optionsTable, {
        type = "header",
        name = SK.COLOR.ORANGE:Colorize(GetString(SI_SK_BATTLE_OPTIONS_HEADER)),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_BATTLE_ABILITY_CONTROL_HEADER)),
        tooltip = GetString(SI_SK_BATTLE_ABILITY_CONTROL_TOOLTIP),
        icon = "/SwissKnife/textures/gui/swirl.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_BATTLE_AC_BLOCK_REUSE_NAME),
                tooltip = GetString(SI_SK_BATTLE_AC_BLOCK_REUSE_TOOLTIP),
                getFunc = function() return SK.savedVars.isAutomationBlockAbilities end,
                setFunc = function(v) SK.savedVars.isAutomationBlockAbilities = v end,
                default = SK.defaultSavedVars.isAutomationBlockAbilities,
                width = "full"
            },
            [2] = {
                type = "editbox",
                name = GetString(SI_SK_BATTLE_AC_BLOCK_CORRECTION_INTERVAL_NAME),
                tooltip = GetString(SI_SK_BATTLE_AC_BLOCK_CORRECTION_INTERVAL_TOOLTIP),
                getFunc = function() return SK.savedVars.abilityEndCorrectionInterval end,
                setFunc = function(v)
                    for id, data in pairs(SK.globalSV.automationBlockAbilities) do
                        if data.correctionInterval == SK.savedVars.abilityEndCorrectionInterval then
                            SK.globalSV.automationBlockAbilities[id].correctionInterval = v
                        end
                    end
                    SKMD.watchedAbilitiesList:Refresh()
                    SK.savedVars.abilityEndCorrectionInterval = v
                end,
                default = SK.defaultSavedVars.abilityEndCorrectionInterval,
                disabled = function() return not SK.savedVars.isAutomationBlockAbilities end,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(SI_SK_BATTLE_AC_SHOW_EXECUTION_INDICATOR_NAME),
                tooltip = GetString(SI_SK_BATTLE_AC_SHOW_EXECUTION_INDICATOR_TOOLTIP),
                getFunc = function() return SK.savedVars.showExecutionIndicator end,
                setFunc = function(v) SK.savedVars.showExecutionIndicator = v end,
                default = SK.defaultSavedVars.showExecutionIndicator,
                width = "full"
            },
            [4] = {
                type = "slider",
                name = GetString(SI_SK_BATTLE_AC_INDICATOR_OFFSET_X_NAME),
                tooltip = GetString(SI_SK_BATTLE_AC_INDICATOR_OFFSET_X_TOOLTIP),
                min = -150,
                max = 150,
                step = 1,
                inputLocation = "bottom",
                clampInput = true,
                decimals = 0,
                getFunc = function() return SK.savedVars.executionIndicatorOffsetX end,
                setFunc = function(v)
                    SK.savedVars.executionIndicatorOffsetX = tonumber(v)
                    SKCI.executionControl:SetAnchor(TOPLEFT, SKCI.reticleControl, BOTTOMLEFT,
                        SK.savedVars.executionIndicatorOffsetX, SK.savedVars.executionIndicatorOffsetY
                    )
                end,
                default = SK.defaultSavedVars.executionIndicatorOffsetX,
                disabled = function() return not SK.savedVars.showExecutionIndicator end,
                width = "full",
            },
            [5] = {
                type = "slider",
                name = GetString(SI_SK_BATTLE_AC_INDICATOR_OFFSET_Y_NAME),
                tooltip = GetString(SI_SK_BATTLE_AC_INDICATOR_OFFSET_Y_TOOLTIP),
                min = -150,
                max = 150,
                step = 1,
                inputLocation = "bottom",
                clampInput = true,
                decimals = 0,
                getFunc = function() return SK.savedVars.executionIndicatorOffsetY end,
                setFunc = function(v)
                    SK.savedVars.executionIndicatorOffsetY = tonumber(v)
                    SKCI.executionControl:SetAnchor(TOPLEFT, SKCI.reticleControl, BOTTOMLEFT,
                        SK.savedVars.executionIndicatorOffsetX, SK.savedVars.executionIndicatorOffsetY
                    )
                end,
                default = SK.defaultSavedVars.executionIndicatorOffsetY,
                disabled = function() return not SK.savedVars.showExecutionIndicator end,
                width = "full",
            },
            [6] = {
                type = "colorpicker",
                name = GetString(SI_SK_BATTLE_AC_INDICATOR_COLOR_NAME),
                getFunc = function() return unpack(SK.savedVars.executionIndicatorColor) end,
                setFunc = function(r, g, b, a)
                    SK.savedVars.executionIndicatorColor = {r, g, b, a}
                    SKCI.executionControlText:SetColor(r, g, b, a)
                end,
                default = SK.defaultSavedVars.executionIndicatorColor,
                disabled = function() return not SK.savedVars.showExecutionIndicator end,
                width = "full",
            },
            [7] = {
                type = "checkbox",
                name = GetString(SI_SK_BATTLE_AC_EXECUTION_SOUND_DISABLE_NAME),
                tooltip = GetString(SI_SK_BATTLE_AC_EXECUTION_SOUND_DISABLE_TOOLTIP),
                getFunc = function() return SK.savedVars.disableExecutionIndicatorSound end,
                setFunc = function(v) SK.savedVars.disableExecutionIndicatorSound = v end,
                default = SK.defaultSavedVars.disableExecutionIndicatorSound,
                disabled = function() return not SK.savedVars.showExecutionIndicator end,
                width = "full"
            },
            [8] = {
                type = "slider",
                name = GetString(SI_SK_BATTLE_AC_HEALTH_FOR_EXECUTION_WATCH_NAME),
                tooltip = GetString(SI_SK_BATTLE_AC_HEALTH_FOR_EXECUTION_WATCH_TOOLTIP),
                min = 0,
                max = 1000000,
                step = 100,
                inputLocation = "bottom",
                clampInput = true,
                decimals = 0,
                getFunc = function() return SK.savedVars.minTargetHealthForExecutionWatch end,
                setFunc = function(v) SK.savedVars.minTargetHealthForExecutionWatch = tonumber(v) end,
                default = SK.defaultSavedVars.minTargetHealthForExecutionWatch,
                disabled = function() return not SK.savedVars.showExecutionIndicator end,
                width = "full",
            },
        },
    })

    table.insert(optionsTable, {
        type = "header",
        name = SK.COLOR.ORANGE:Colorize(GetString(SI_SK_INTERFACE_OPTIONS_HEADER)),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_INTERFACE_CAMERA_INTERACTIONS_HEADER)),
        icon = "/SwissKnife/textures/gui/back-forth.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_CI_CAMERA_ROTATE_NAME),
                tooltip = GetString(SI_SK_INTERFACE_CI_CAMERA_ROTATE_TOOLTIP),
                getFunc = function() return SK.savedVars.stopCameraRotate end,
                setFunc = function(v) SK.savedVars.stopCameraRotate = v end,
                default = SK.defaultSavedVars.stopCameraRotate,
                requiresReload = true,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_CI_INTERACTIONS_INTERRUPT_NAME),
                tooltip = GetString(SI_SK_INTERFACE_CI_INTERACTIONS_INTERRUPT_TOOLTIP),
                getFunc = function() return SK.savedVars.isDoNotInterruption end,
                setFunc = function(v) SK.savedVars.isDoNotInterruption = v end,
                default = SK.defaultSavedVars.isDoNotInterruption,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_CI_HIDE_EMPTY_INTERACTION_NAME),
                tooltip = GetString(SI_SK_INTERFACE_CI_HIDE_EMPTY_INTERACTION_TOOLTIP),
                getFunc = function() return SK.savedVars.hideEmptyInteraction end,
                setFunc = function(v) SK.savedVars.hideEmptyInteraction = v end,
                default = SK.defaultSavedVars.hideEmptyInteraction,
                width = "full"
            },
            [4] = {
                type = "divider",
                width = "full"
            },
            [5] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_CI_DANGER_INTERACTION_INDICATOR),
                tooltip = GetString(SI_SK_INTERFACE_CI_DANGER_INTERACTION_INDICATOR_TOOLTIP),
                getFunc = function() return SK.savedVars.enableDangerInteractionIndicator end,
                setFunc = function(v)
                    SK.savedVars.enableDangerInteractionIndicator = v
                    SKPI:SetHidden()
                end,
                default = SK.defaultSavedVars.enableDangerInteractionIndicator,
                width = "full"
            },
            [6] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_CI_DANGER_INTERACTION_NAME),
                tooltip = GetString(SI_SK_INTERFACE_CI_DANGER_INTERACTION_TOOLTIP),
                getFunc = function() return SK.savedVars.enableDangerInteractionNotification end,
                setFunc = function(v) SK.savedVars.enableDangerInteractionNotification = v end,
                default = SK.defaultSavedVars.enableDangerInteractionNotification,
                width = "full"
            },
        },
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_HOTBARCATEGORY13)),
        icon = "/SwissKnife/textures/gui/allies.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_CI_PREVENT_UNSAFE_INSECTS_TAKE_NAME),
                tooltip = GetString(SI_SK_INTERFACE_CI_PREVENT_UNSAFE_INSECTS_TAKE_TOOLTIP),
                getFunc = function() return SK.savedVars.preventUnsafeInsectTake end,
                setFunc = function(v) SK.savedVars.preventUnsafeInsectTake = v end,
                default = SK.defaultSavedVars.preventUnsafeInsectTake,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_CI_PREVENT_UNSAFE_FISHING_NAME),
                tooltip = GetString(SI_SK_INTERFACE_CI_PREVENT_UNSAFE_FISHING_TOOLTIP),
                getFunc = function() return SK.savedVars.preventUnsafeFishing end,
                setFunc = function(v) SK.savedVars.preventUnsafeFishing = v end,
                default = SK.defaultSavedVars.preventUnsafeFishing,
                width = "full"
            },
            [3] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_CI_PREVENT_UNSAFE_STEALING_NAME),
                tooltip = GetString(SI_SK_INTERFACE_CI_PREVENT_UNSAFE_STEALING_TOOLTIP),
                getFunc = function() return SK.savedVars.preventCompanionUnsafeStealing end,
                setFunc = function(v) SK.savedVars.preventCompanionUnsafeStealing = v end,
                default = SK.defaultSavedVars.preventCompanionUnsafeStealing,
                width = "full"
            },
            [4] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_CI_PREVENT_UNSAFE_BOW_NAME),
                tooltip = GetString(SI_SK_INTERFACE_CI_PREVENT_UNSAFE_BOW_TOOLTIP),
                getFunc = function() return SK.savedVars.preventCompanionUnsafeBladeOfWoe end,
                setFunc = function(v) SK.savedVars.preventCompanionUnsafeBladeOfWoe = v end,
                default = SK.defaultSavedVars.preventCompanionUnsafeBladeOfWoe,
                width = "full"
            },
            [5] = {
                type = "dropdown",
                name = GetString(SI_SK_SKW_COMPANION_UNSAFE_ENTRY_NAME),
                tooltip = GetString(SI_SK_SKW_COMPANION_UNSAFE_ENTRY_TOOLTIP),
                choices = CompanionUnsafeEntryModes,
                getFunc = function() return CompanionUnsafeEntryModes[SK.savedVars.companionUnsafeEntryMode] end,
                setFunc = function(v)
                    local rule
                    for key, value in pairs(CompanionUnsafeEntryModes) do if v == value then rule = key end end
                    SK.savedVars.companionUnsafeEntryMode = rule
                end,
                default = SK.defaultSavedVars.companionUnsafeEntryMode,
                width = "full",
            },
            [6] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_CI_PREVENT_ACCIDENTAL_IA_NAME),
                tooltip = GetString(SI_SK_INTERFACE_CI_PREVENT_ACCIDENTAL_IA_TOOLTIP),
                getFunc = function() return SK.savedVars.preventAccidentalInteraction end,
                setFunc = function(v) SK.savedVars.preventAccidentalInteraction = v end,
                default = SK.defaultSavedVars.preventAccidentalInteraction,
                width = "full"
            },
            [7] = {
                type = "editbox",
                name = GetString(SI_SK_INTERFACE_CI_PREVENT_ACCIDENTAL_IA_INTERVAL_NAME),
                tooltip = GetString(SI_SK_INTERFACE_CI_PREVENT_ACCIDENTAL_IA_INTERVAL_TOOLTIP),
                getFunc = function() return SK.savedVars.preventAccidentalInteractionInterval end,
                setFunc = function(v) SK.savedVars.preventAccidentalInteractionInterval = tonumber(v) end,
                disabled = function() return not SK.savedVars.preventAccidentalInteraction end,
                default = SK.defaultSavedVars.preventAccidentalInteractionInterval,
                width = "full",
            },
            [8] = {
                type = "divider",
                width = "full"
            },
            [9] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_CI_COMPANIONS_INTERACTION_NAME),
                tooltip = GetString(SI_SK_INTERFACE_CI_COMPANIONS_INTERACTION_TOOLTIP),
                getFunc = function() return SK.savedVars.enableCompanionsInteractionNotification end,
                setFunc = function(v) SK.savedVars.enableCompanionsInteractionNotification = v end,
                default = SK.defaultSavedVars.enableCompanionsInteractionNotification,
                width = "full"
            },
        },
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_INTERFACE_INVENTORY_HEADER)),
        icon = "/SwissKnife/textures/gui/knapsack.dds",
        controls = {
            [1] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_INVENTORY_BAG_SLOTS_NAME),
                tooltip = GetString(SI_SK_INTERFACE_INVENTORY_BAG_SLOTS_TOOLTIP),
                getFunc = function() return SK.savedVars.replaceBackpackSlotsInfo end,
                setFunc = function(v)
                    SK.savedVars.replaceBackpackSlotsInfo = v
                    if v then
                        SK.Interface.updateBagInfo(BAG_BACKPACK)
                    else
                        SK.Interface.setDefaultBagSlotInfoControls()
                    end
                end,
                default = SK.defaultSavedVars.replaceBackpackSlotsInfo,
                width = "full"
            },
            [2] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_I_BAG_SHOW_FREE_SLOTS_NAME),
                tooltip = GetString(SI_SK_INTERFACE_I_BAG_SHOW_FREE_SLOTS_TOOLTIP),
                getFunc = function() return SK.savedVars.showFreeBagSlots end,
                setFunc = function(v)
                    SK.savedVars.showFreeBagSlots = v
                    SKI:updateSlotInfoOffset()
                    SKI.updateBagInfo(BAG_BACKPACK)
                end,
                disabled = function() return not SK.savedVars.replaceBackpackSlotsInfo end,
                default = SK.defaultSavedVars.showFreeBagSlots,
                width = "full",
            },
            [3] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_I_BAG_USE_PERCENTAGE_FREE_SLOTS_NAME),
                tooltip = GetString(SI_SK_INTERFACE_I_BAG_USE_PERCENTAGE_FREE_SLOTS_TOOLTIP),
                getFunc = function() return SK.savedVars.usePercentageFreeBagSlots end,
                setFunc = function(v)
                    SK.savedVars.usePercentageFreeBagSlots = v
                    SKI:updateSlotInfoOffset()
                    SK.Interface.updateBagInfo(BAG_BACKPACK)
                end,
                disabled = function() return not SK.savedVars.replaceBackpackSlotsInfo or
                    not SK.savedVars.showFreeBagSlots
                end,
                default = SK.defaultSavedVars.usePercentageFreeBagSlots,
                width = "full",
            },
            [4] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_I_BAG_USE_COLORIZED_FREE_SLOTS_NAME),
                tooltip = GetString(SI_SK_INTERFACE_I_BAG_USE_COLORIZED_FREE_SLOTS_TOOLTIP),
                getFunc = function() return SK.savedVars.showColorizedFreeBagSlots end,
                setFunc = function(v)
                    SK.savedVars.showColorizedFreeBagSlots = v
                    SK.Interface.updateBagInfo(BAG_BACKPACK)
                end,
                disabled = function() return not SK.savedVars.replaceBackpackSlotsInfo or
                    not SK.savedVars.showFreeBagSlots
                end,
                default = SK.defaultSavedVars.showColorizedFreeBagSlots,
                width = "full",
            },
            [5] = {
                type = "divider",
                width = "full"
            },
            [6] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_INVENTORY_FENCE_SLOTS_NAME),
                tooltip = GetString(SI_SK_INTERFACE_INVENTORY_FENCE_SLOTS_TOOLTIP),
                getFunc = function() return SK.savedVars.replaceFenceSlotsInfo end,
                setFunc = function(v)
                    SK.savedVars.replaceFenceSlotsInfo = v
                    if not v then SK.Interface.setDefaultFenceSlotInfoControls() end
                end,
                default = SK.defaultSavedVars.replaceFenceSlotsInfo,
                width = "full"
            },
            [7] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_I_FENCE_SHOW_FREE_SLOTS_NAME),
                tooltip = GetString(SI_SK_INTERFACE_I_FENCE_SHOW_FREE_SLOTS_TOOLTIP),
                getFunc = function() return SK.savedVars.showFreeFenceSlots end,
                setFunc = function(v) SK.savedVars.showFreeFenceSlots = v end,
                disabled = function() return not SK.savedVars.replaceFenceSlotsInfo end,
                default = SK.defaultSavedVars.showFreeFenceSlots,
                width = "full",
            },
            [8] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_I_FENCE_USE_PERCENTAGE_FREE_SLOTS_NAME),
                tooltip = GetString(SI_SK_INTERFACE_I_FENCE_USE_PERCENTAGE_FREE_SLOTS_TOOLTIP),
                getFunc = function() return SK.savedVars.usePercentageFreeFenceSlots end,
                setFunc = function(v) SK.savedVars.usePercentageFreeFenceSlots = v end,
                disabled = function() return not SK.savedVars.replaceFenceSlotsInfo or
                    not SK.savedVars.showFreeFenceSlots
                end,
                default = SK.defaultSavedVars.usePercentageFreeFenceSlots,
                width = "full",
            },
            [9] = {
                type = "checkbox",
                name = GetString(SI_SK_INTERFACE_I_FENCE_USE_COLORIZED_FREE_SLOTS_NAME),
                tooltip = GetString(SI_SK_INTERFACE_I_FENCE_USE_COLORIZED_FREE_SLOTS_TOOLTIP),
                getFunc = function() return SK.savedVars.showColorizedFreeFenceSlots end,
                setFunc = function(v) SK.savedVars.showColorizedFreeFenceSlots = v end,
                disabled = function() return not SK.savedVars.replaceFenceSlotsInfo or
                    not SK.savedVars.showFreeFenceSlots
                end,
                default = SK.defaultSavedVars.showColorizedFreeFenceSlots,
                width = "full",
            },
        },
    })

    local controlsInterfaceMisc = {
        [1] = {
            type = "checkbox",
            name = GetString(SI_SK_I_DISABLE_SWAP_WEAPON_ICON),
            getFunc = function() return SK.savedVars.hideSwapWeapon end,
            setFunc = function(v)
                SKH.hideSwapWeapon(v)
                SK.savedVars.hideSwapWeapon = v
            end,
            default = SK.defaultSavedVars.hideSwapWeapon,
            width = "full"
        },
        [2] = {
            type = "checkbox",
            name = GetString(SI_SK_I_DISABLE_ACTIONBAR_KEYBIND_TEXT),
            getFunc = function() return SK.savedVars.hideActionButtonsKeybind end,
            setFunc = function(v) SK.savedVars.hideActionButtonsKeybind = v end,
            default = SK.defaultSavedVars.hideActionButtonsKeybind,
            requiresReload = true,
            width = "full"
        },
        [3] = {
            type = "checkbox",
            name = GetString(SI_SK_I_DISABLE_STEALTH_TEXT),
            tooltip =  GetString(SI_SK_I_DISABLE_STEALTH_TEXT_TOOLTIP),
            getFunc = function() return SK.savedVars.hideStealthText end,
            setFunc = function(v)
                RETICLE.stealthIcon.stealthText:SetHidden(v)
                SK.savedVars.hideStealthText = v
            end,
            default = SK.defaultSavedVars.hideStealthText,
            width = "full"
        },
    }

    controlsInterfaceMisc = SKH.makeMenuControls(controlsInterfaceMisc, "InterfaceMisc", 4)

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_INTERFACE_MISC_HEADER)),
        icon = "/SwissKnife/textures/gui/theater-curtains.dds",
        controls = controlsInterfaceMisc
    })

    table.insert(optionsTable, {
        type = "header",
        name = SK.COLOR.ORANGE:Colorize(GetString(SI_SK_OPTIONS_CLIENT_OPTIMIZATION_HEADER)),
        width = "full",
    })

   local controlsGuildHistory = SKH.makeMenuControls({
       [1] = {
        type = "header",
        name = SK.COLOR.ORANGE:Colorize(GetString(SI_SK_PREGAME_GUILD_HISTORY_TITLE)),
        width = "full",
       }
   }, "GuildHistory", 2)

    table.insert(optionsTable, {
        type = "submenu",
        name = SK.COLOR.WHITE:Colorize(GetString(SI_SK_OPTIONS_CO_MEMORY_HEADER)),
        --icon = "/SwissKnife/textures/gui/theater-curtains.dds",
        controls = controlsGuildHistory
    })

    SK.LAM:RegisterOptionControls(SK.name.."OptionsPanel", optionsTable)
end

-- Export
SK.OptionsMenu = {
    InitSettings = InitSettings
}