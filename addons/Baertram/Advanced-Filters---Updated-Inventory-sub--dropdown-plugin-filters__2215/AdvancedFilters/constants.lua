AdvancedFilters = AdvancedFilters or {}
local AF = AdvancedFilters

--Addon base variables
AF.name = "AdvancedFilters"
AF.author = "ingeniousclown, Randactyl, Baertram"
AF.version = "1.6.5.5"
AF.savedVarsVersion = 1.511
AF.website = "https://www.esoui.com/downloads/fileinfo.php?id=2215"
AF.feedback = "https://www.esoui.com/portal.php?id=136&a=faq"
AF.donation = "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"
AF.currentInventoryType = INVENTORY_BACKPACK
AF.currentlySelectedDropDownEntry = nil

AF.clientLang = GetCVar("language.2")
AF.supportedLanguages = {
    de = 1,
    en = 2,
    es = 3,
    fr = 4,
    ru = 5,
    jp = 6,
    zh = 7,
}



AF.otherAddonsDisallowed = {
    ["MultiCraft"] = true
}

--SavedVariables default settings
AF.defaultSettings = {
    debugSpam                               = false,
    debugSpamExcludeRefreshSubfilterBar     = true,
    debugSpamExcludeDropdownBoxFilters      = true,
    doDebugOutput                           = false,
    hideItemCount                           = false,
    itemCountLabelColor = {
        ["r"] = 1,
        ["g"] = 1,
        ["b"] = 1,
        ["a"] = 1,
    },
    hideSubFilterLabel                      = false,
    grayOutSubFiltersWithNoItems            = true,
    showIconsInFilterDropdowns              = true,
    showSubMenuHeaderlinesInFilterDropdowns = false,
    rememberFilterDropdownsLastSelection    = true,
    showDropdownSelectedReminderAnimation   = true,
    showDropdownLastSelectedEntries         = true,
    subfilterBarDropdownLastSelectedEntries = {},
    hideCharBoundAtBankDeposit              = false,
    showFilterDropdownMenuOnRightMouseAtSubFilterButton = false,
    dropdownVisibleRows = 15,
    dropdownVisibleSubmenuRows = 15,
}

--Libraries
AF.util = AF.util or {}
--local util = AF.util

--Libraries: See file libraries.lua

--Constant for the "All" subfilters
AF_CONST_ALL                = 'All'
--Prefixes for filterGroups
--Quickslot
AF_QS_PREFIX                = 'QS'
--Constant for the dropdown filter box LibFilters filter
AF_CONST_BUTTON_FILTER      = "AF_ButtonFilter"
AF_CONST_DROPDOWN_FILTER    = "AF_DropdownFilter"

--Last known currentFilter
AF.lastCurrentFilter = {}

--Other addons
AF.otherAddons = {}

--Preventer veriables
AF.preventerVars = {}

--SCENE CHECKS
--Scene names for the SCENE_MANAGER.currentScene.name check
local scenesForChecks = {
    storeVendor     = "store",
    bank            = "bank",
    guildBank       = "guildBank",
    guildStoreSell  = "tradinghouse",
    fence           = "fence_keyboard",
    universalDecon  = "universalDeconstructionSceneKeyboard",
    furnitureVault  = "furnitureVault",
}
AF.scenesForChecks = scenesForChecks
--local sceneNameStoreVendor      = ""
--local sceneNameBankDeposit      = ""
--local sceneNameGuildBankDeposit = ""

--FRAGMENT changes
--The fragment's state is "hiding"= -> For the subfilter bars
AF.fragmentStateHiding = {}

--CONTROLS
--Bank inventory types
local bankInvTypes = {
    [INVENTORY_BANK]        = true,
    [INVENTORY_GUILD_BANK]  = true,
    [INVENTORY_HOUSE_BANK]  = true,
    [INVENTORY_FURNITURE_VAULT] = true,
}
AF.bankInvTypes = bankInvTypes

local defaultUniversalInvTypes = {
	INVENTORY_BACKPACK,
	INVENTORY_BANK,
	INVENTORY_HOUSE_BANK
}
AF.defaultUniversalInvTypes = defaultUniversalInvTypes

local universalDeconSelectedTabToActualInventories = {
    ["all"] =           defaultUniversalInvTypes,
    ["weapons"] =       defaultUniversalInvTypes,
    ["armor"] =         defaultUniversalInvTypes,
    ["jewelry"] =       defaultUniversalInvTypes,
    ["enchantments"] =  defaultUniversalInvTypes,
}
AF.universalDeconSelectedTabToActualInventories = universalDeconSelectedTabToActualInventories

local universalDeconStr = "UniversalDecon"

--Include bank checkbox name
AF.ZOsControlNames = {
    includeBankedCheckbox   =   "IncludeBanked",
    filterDivider           =   "FilterDivider",
    buttonDivider           =   "ButtonDivider",
    searchDivider           =   "SearchDivider",
    searchFilters           =   "SearchFilters",
    textSearch              =   "TextSearch",
    title                   =   "Title",
    tabs                    =   "Tabs",
    subTabs                 =   "SubTabs",
    active                  =   "Active",
    questItemsOnly          =   "QuestItemsOnly",
    craftingTypes           =   "CraftingTypes",
}
local ZOsControlNames = AF.ZOsControlNames
local filterDividerSuffix = ZOsControlNames.filterDivider
local buttonDividerSuffix = ZOsControlNames.buttonDivider
local searchDividerSuffix = ZOsControlNames.searchDivider
local questItemsOnly      = ZOsControlNames.questItemsOnly


local quickslotKeyboard                     = QUICKSLOT_KEYBOARD
local quickslotControl                      = quickslotKeyboard.control
local quickslotFragment                     = KEYBOARD_QUICKSLOT_FRAGMENT

--Control names for the "which panel is shown" checks
local controlsForChecks = {
    playerInv               = PLAYER_INVENTORY,
    inv                     = ZO_PlayerInventory,
    invList                 = ZO_PlayerInventoryList,
    bank                    = ZO_PlayerBank,
    bankBackpack            = ZO_PlayerBankBackpack,
    guildBank               = ZO_GuildBank,
    guildBankBackpack       = ZO_GuildBankBackpack,
    storeWindow             = ZO_StoreWindow,
    buyBackList             = ZO_BuyBackListContents,
    repairWindow            = ZO_RepairWindowList,
    craftBag                = ZO_CraftBag,
    houseBank               = ZO_HouseBank,
    guildStoreSellBackpack  = ZO_PlayerInventory,
    quickslot               = quickslotKeyboard,
    quickslotControl        = quickslotControl,
    quickslotFragment       = quickslotFragment,
    quickslotWheelUnderlay  = GetControl(quickslotKeyboard.wheelControl, "Underlay"), --ZO_QuickSlot_Keyboard_TopLevelQuickSlotCircleUnderlay
    mailSend                = MAIL_SEND,
    trade                   = TRADE,
    --Keyboard variables
    store                   = STORE_WINDOW,
    smithingBaseVar         = ZO_Smithing,
    alchemy                 = ALCHEMY,
    smithing                = SMITHING,
    enchantingBaseVar       = ZO_Enchanting,
    enchanting              = ENCHANTING,
    provisioner             = PROVISIONER,
    retrait                 = ZO_RETRAIT_KEYBOARD, --ZO_RETRAIT_STATION_KEYBOARD -- needed for the other retrait related filter stuff (hooks, util functions)
    fence                   = FENCE_KEYBOARD,
    companionInv            = COMPANION_EQUIPMENT_KEYBOARD,
    furnitureVault          = ZO_FurnitureVault,
    furnitureVaultList      = ZO_FurnitureVaultList,
    vengeanceInv            = ZO_VengeanceInventory,
    vengeanceInvList        = ZO_VengeanceInventoryList,
}

controlsForChecks.universalDecon          = UNIVERSAL_DECONSTRUCTION
controlsForChecks.universalDeconPanel     = UNIVERSAL_DECONSTRUCTION.deconstructionPanel
controlsForChecks.universalDeconPanelInv     = UNIVERSAL_DECONSTRUCTION.deconstructionPanel.inventory
controlsForChecks.universalDeconPanelInvControl = UNIVERSAL_DECONSTRUCTION.deconstructionPanel.inventory.control
controlsForChecks.universalDeconScene     = UNIVERSAL_DECONSTRUCTION_KEYBOARD_SCENE

--Smithing
controlsForChecks.refinementPanel       =   controlsForChecks.smithing.refinementPanel
controlsForChecks.creationPanel         =   controlsForChecks.smithing.creationPanel
controlsForChecks.deconstructionPanel   =   controlsForChecks.smithing.deconstructionPanel
controlsForChecks.improvementPanel      =   controlsForChecks.smithing.improvementPanel
controlsForChecks.researchPanel         =   controlsForChecks.smithing.researchPanel
controlsForChecks.researchLineList      =   controlsForChecks.researchPanel.researchLineList
--Enchanting
controlsForChecks.enchantCreatePanel    =   controlsForChecks.enchanting
controlsForChecks.enchantExtractPanel   =   controlsForChecks.enchanting
--Retrait
controlsForChecks.retraitPanel          =   controlsForChecks.retrait --old: controlsForChecks.retrait.retraitPanel
controlsForChecks.retraitControl        =   controlsForChecks.retraitPanel.control

AF.controlsForChecks = controlsForChecks

--INVENTORIES
--Inventories and their searchBox controls
local inventories = {
    [INVENTORY_BACKPACK]   = {
        searchBox = ZO_PlayerInventorySearchFiltersTextSearchBox,
    },
    [INVENTORY_QUEST_ITEM] = {
        searchBox = ZO_PlayerInventorySearchFiltersTextSearchBox,
    },
    [INVENTORY_BANK]       = {
        searchBox = ZO_PlayerBankSearchFiltersTextSearchBox,
    },
    [INVENTORY_HOUSE_BANK] = {
        searchBox = ZO_HouseBankSearchFiltersTextSearchBox,
    },
    [INVENTORY_GUILD_BANK] = {
        searchBox = ZO_GuildBankSearchFiltersTextSearchBox,
    },
    [INVENTORY_CRAFT_BAG]  = {
        searchBox = ZO_CraftBagSearchFiltersTextSearchBox,
    },
    [LF_QUICKSLOT] = {
        searchBox = (quickslotKeyboard ~= nil and quickslotKeyboard.searchBox) or ZO_QuickSlot_Keyboard_TopLevelSearchFiltersTextSearch, --old: ZO_QuickSlotSearchFiltersTextSearchBox,
    },
    [LF_INVENTORY_COMPANION] = {
        searchBox = ZO_CompanionEquipment_Panel_KeyboardSearchFiltersTextSearchBox, --controlsForChecks.companionInv.searchBox
    },
    [INVENTORY_FURNITURE_VAULT] = {
        searchBox = ZO_FurnitureVaultSearchFiltersTextSearchBox,
    }
}
AF.inventories = inventories
--New defined vendor buy inventory type (only known by AdvancedFilters)
INVENTORY_TYPE_VENDOR_BUY =                         900
--New defined universal deconstruction inventory type (only known by AdvancedFilters)
INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ALL =       901
INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ARMOR =     902
INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_WEAPONS =   903
INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_JEWELRY =   904
INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_GLYPHS =    905


--ITEMFILTERTYPES
--Get the current maximum itemFilterType
AF.maxItemFilterType = ITEM_TYPE_DISPLAY_CATEGORY_MAX_VALUE -- 41 (ITEM_TYPE_DISPLAY_CATEGORY_COMPANION) is the maximum since API 100034 "Blackwood"
--Build new "virtual" itemfiltertypes for crafting stations so one can distinguish the different subfilter bars
local itemFilterTypesDefinedForAdvancedFilters = {
    --Refine
    ITEMFILTERTYPE_AF_REFINE_CLOTHIER               = 0,
    ITEMFILTERTYPE_AF_REFINE_SMITHING               = 0,
    ITEMFILTERTYPE_AF_REFINE_WOODWORKING            = 0,
    ITEMFILTERTYPE_AF_REFINE_JEWELRY                = 0,
    --Create
    --ITEMFILTERTYPE_AF_CREATE_ARMOR_CLOTHIER         = 0,
    --ITEMFILTERTYPE_AF_CREATE_ARMOR_SMITHING         = 0,
    --ITEMFILTERTYPE_AF_CREATE_ARMOR_WOODWORKING      = 0,
    --ITEMFILTERTYPE_AF_CREATE_WEAPONS_SMITHING       = 0,
    --ITEMFILTERTYPE_AF_CREATE_WEAPONS_WOODWORKING    = 0,
    --ITEMFILTERTYPE_AF_CREATE_JEWELRY                = 0,
    ITEMFILTERTYPE_AF_RUNES_ENCHANTING              = 0,
    --Deconstruct / Improve / Research
    ITEMFILTERTYPE_AF_ARMOR_CLOTHIER                = 0,
    ITEMFILTERTYPE_AF_ARMOR_SMITHING                = 0,
    ITEMFILTERTYPE_AF_ARMOR_WOODWORKING             = 0,
    ITEMFILTERTYPE_AF_WEAPONS_SMITHING              = 0,
    ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING           = 0,
    ITEMFILTERTYPE_AF_JEWELRY_CRAFTING              = 0,
    ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING             = 0,
    --Retrait
    ITEMFILTERTYPE_AF_RETRAIT_ARMOR                 = 0,
    ITEMFILTERTYPE_AF_RETRAIT_WEAPONS               = 0,
    ITEMFILTERTYPE_AF_RETRAIT_JEWELRY               = 0,
    --Universal Deconstruction
    ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL           = 0,
    ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS       = 0,
    ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR         = 0,
    ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY       = 0,
    ITEMFILTERTYPE_AF_UNIVERSAL_DECON_GLYPHS        = 0,
    --Craftbag Miscellaneous (for Scribing materials)
    ITEMFILTERTYPE_AF_CRAFTBAG_MISCELLANEOUS        = 0
}
local counter = AF.maxItemFilterType
for itemFilterTypeName, _ in pairs(itemFilterTypesDefinedForAdvancedFilters) do
    counter = counter + 1
    _G[itemFilterTypeName] = counter
end
--Update the maximum filterType number
AF.maxItemFilterType = counter

--Other addons itemFilterTypes
counter = AF.maxItemFilterType
counter = counter + 1
--Harven's Stolen Filter
ITEMFILTERTYPE_AF_STOLENFILTER = counter
AF.maxItemFilterType = counter

--NAME STRINGS (for the LibFilters filterTags)
--The names of the inventories. Needed to build the unique subfilter panel names.
local inventoryNames = {
    --ZOs inventory types
    [INVENTORY_BACKPACK]        = "PlayerInventory",
    [INVENTORY_CRAFT_BAG]       = "CraftBag",
    [INVENTORY_QUEST_ITEM]      = "PlayerInventoryQuest",
    [INVENTORY_BANK]            = "PlayerBank",
    [INVENTORY_GUILD_BANK]      = "GuildBank",
    [INVENTORY_HOUSE_BANK]      = "HouseBankWithdraw",
    [INVENTORY_FURNITURE_VAULT] = "FurnitureVault",
    [INVENTORY_VENGEANCE]       = "VengeanceInventory",

    --LibFilters crafting filterTypes
    [LF_SMITHING_CREATION]      = "SmithingCreate",
    [LF_SMITHING_REFINE]        = "SmithingRefine",
    [LF_SMITHING_DECONSTRUCT]   = "SmithingDeconstruction",
    [LF_SMITHING_IMPROVEMENT]   = "SmithingImprovement",
    [LF_SMITHING_RESEARCH]      = "SmithingResearch",
    [LF_JEWELRY_CREATION]       = "JewelryCraftingCreate",
    [LF_JEWELRY_REFINE]         = "JewelryCraftingRefine",
    [LF_JEWELRY_DECONSTRUCT]    = "JewelryCraftingDeconstruction",
    [LF_JEWELRY_IMPROVEMENT]    = "JewelryCraftingImprovement",
    [LF_JEWELRY_RESEARCH]       = "JewelryCraftingResearch",
    [LF_ENCHANTING_CREATION]    = "EnchantingCreation",
    [LF_ENCHANTING_EXTRACTION]  = "EnchantingExtraction",
    [LF_RETRAIT]                = "Retrait",

    --LibFilters other filterTypes
    [LF_QUICKSLOT]              = "QuickSlot",
    [LF_INVENTORY_COMPANION]    = "CompanionInventory",

    --AdvancedFilters custom created inventory types
    [INVENTORY_TYPE_VENDOR_BUY] =                       "VendorBuy",
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ALL] =     universalDeconStr .. "All",
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ARMOR] =   universalDeconStr .. "Armor",
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_WEAPONS] = universalDeconStr .. "Weapons",
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_JEWELRY] = universalDeconStr .. "Jewelry",
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_GLYPHS] =  universalDeconStr .. "Glyphs",
}
AF.inventoryNames = inventoryNames

--The names of the trade skills. Needed to build the unique subfilter panel names.
local tradeSkillNames = {
    [CRAFTING_TYPE_INVALID]         = "_",
    [CRAFTING_TYPE_ALCHEMY]         = "_ALCHEMY_",
    [CRAFTING_TYPE_BLACKSMITHING]   = "_BLACKSMITH_",
    [CRAFTING_TYPE_CLOTHIER]        = "_CLOTHIER_",
    [CRAFTING_TYPE_ENCHANTING]      = "_ENCHANTING_",
    [CRAFTING_TYPE_PROVISIONING]    = "_PROVISIONING_",
    [CRAFTING_TYPE_WOODWORKING]     = "_WOODWORKING_",
    [CRAFTING_TYPE_JEWELRYCRAFTING] = "_JEWELRY_",
}
AF.tradeSkillNames = tradeSkillNames

--FILTERTYPE NAMES
--The names of the filter types. Needed to build the unique subfilter panel names.
local filterTypeNames = {
    [ITEM_TYPE_DISPLAY_CATEGORY_ALL]                = AF_CONST_ALL,
    [ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS]            = "Weapons",
    [ITEM_TYPE_DISPLAY_CATEGORY_ARMOR]              = "Armor",
    [ITEMFILTERTYPE_COLLECTIBLE]                    = "Collectibles",
    [ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE]         = "Consumables",
    [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING]           = "Crafting",
    [ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS]      = "Miscellaneous",
    [ITEM_TYPE_DISPLAY_CATEGORY_QUEST]              = "Quest",
    [ITEM_TYPE_DISPLAY_CATEGORY_JUNK]               = "Junk",
    [ITEM_TYPE_DISPLAY_CATEGORY_BLACKSMITHING]      = "Blacksmithing",
    [ITEM_TYPE_DISPLAY_CATEGORY_CLOTHING]           = "Clothing",
    [ITEM_TYPE_DISPLAY_CATEGORY_WOODWORKING]        = "Woodworking",
    [ITEM_TYPE_DISPLAY_CATEGORY_ALCHEMY]            = "Alchemy",
    [ITEM_TYPE_DISPLAY_CATEGORY_ENCHANTING]         = "Enchanting",
    [ITEM_TYPE_DISPLAY_CATEGORY_PROVISIONING]       = "Provisioning",
    [ITEM_TYPE_DISPLAY_CATEGORY_STYLE_MATERIAL]     = "Style",
    [ITEM_TYPE_DISPLAY_CATEGORY_TRAIT_ITEM]         = "Traits",
    [ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING]         = "Furnishings",
    [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRYCRAFTING]    = "JewelryCrafting",
    [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY]            = "Jewelry",
    [ITEM_TYPE_DISPLAY_CATEGORY_COMPANION]          = "Companion",
    [ITEMFILTERTYPE_AF_WEAPONS_SMITHING]            = "WeaponsSmithing",
    --[ITEMFILTERTYPE_AF_CREATE_ARMOR_SMITHING]       = "CreateArmorSmithing",
    [ITEMFILTERTYPE_AF_REFINE_SMITHING]             = "RefineSmithing",
    [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING]           = "ArmorWoodworking",
    --[ITEMFILTERTYPE_AF_CREATE_WEAPONS_SMITHING]     = "CreateWeaponsSmithing",
    [ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING]           = "Glyphs",
    [ITEMFILTERTYPE_AF_REFINE_WOODWORKING]          = "RefineWoodworking",
    --[ITEMFILTERTYPE_AF_CREATE_ARMOR_CLOTHIER]       = "CreateArmorClothier",
    [ITEMFILTERTYPE_AF_REFINE_CLOTHIER]             = "RefineClothier",
    [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING]            = "JewelryCraftingStation",
    [ITEMFILTERTYPE_AF_RUNES_ENCHANTING]            = "Runes",
    [ITEMFILTERTYPE_AF_ARMOR_SMITHING]              = "ArmorSmithing",
    [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING]         = "WeaponsWoodworking",
    --[ITEMFILTERTYPE_AF_CREATE_WEAPONS_WOODWORKING]  = "CreateWeaponsWoodworking",
    --[ITEMFILTERTYPE_AF_CREATE_ARMOR_WOODWORKING]    = "CreateArmorWoodworking",
    [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER]              = "ArmorClothier",

    --[ITEMFILTERTYPE_AF_CREATE_JEWELRY]              = "CreateJewelryCraftingStation",
    [ITEMFILTERTYPE_AF_REFINE_JEWELRY]              = "RefineJewelryCraftingStation",
    [ITEMFILTERTYPE_AF_RETRAIT_ARMOR]               = "ArmorRetrait",
    [ITEMFILTERTYPE_AF_RETRAIT_WEAPONS]             = "WeaponsRetrait",
    [ITEMFILTERTYPE_AF_RETRAIT_JEWELRY]             = "JewelryRetrait",
    [AF_QS_PREFIX..ITEMFILTERTYPE_QUICKSLOT]        = "QuickSlot",
    [AF_QS_PREFIX..ITEMFILTERTYPE_QUEST_QUICKSLOT]  = "QuickSlotQuest",

    [ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL]         = "All" ..universalDeconStr,
    [ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS]     = "Weapons" ..universalDeconStr,
    [ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR]       = "Armor" ..universalDeconStr,
    [ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY]     = "Jewelry" ..universalDeconStr,
    [ITEMFILTERTYPE_AF_UNIVERSAL_DECON_GLYPHS]      = "Glyphs" ..universalDeconStr,

    [ITEMFILTERTYPE_AF_CRAFTBAG_MISCELLANEOUS]      = "CraftBagMiscellaneous"
    --CUSTOM ADDON TABs
    --[[
    [ITEMFILTERTYPE_AF_STOLENFILTER]         = "HarvensStolenFilter",
    ]]
}
AF.filterTypeNames = filterTypeNames
--Mapping for filter types to crafting AdvancedFilter types
local normalFilterNames = {
    [filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_ARMOR]]   = true, -- Armor
    [filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS]] = true, -- Weapons
    [filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY]] = true, -- Jewelry
}
AF.normalFilterNames = normalFilterNames

--Mapping between normal inventory currentFilter values (e.g. ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS) and AF custom filterTypes
local inventoryCurrentFilterToSpecialCurentFilter = {
    [INVENTORY_CRAFT_BAG] = {
        [ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS] = ITEMFILTERTYPE_AF_CRAFTBAG_MISCELLANEOUS,
    }
}
AF.inventoryCurrentFilterToSpecialCurentFilter = inventoryCurrentFilterToSpecialCurentFilter
--And the mapping backwards for the same
local inventorySpecialCurrentFilterToCurentFilter = {
    [INVENTORY_CRAFT_BAG] = {
        [ITEMFILTERTYPE_AF_CRAFTBAG_MISCELLANEOUS] = ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS,
    }
}
AF.inventorySpecialCurrentFilterToCurentFilter = inventorySpecialCurrentFilterToCurentFilter
--Enable the mapping between normal inventory currentFilter values (e.g. ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS) and AF custom filterTypes
-->Only at some inventory types (e.g. do not enable at crafting tables or it will throw errors as those use other custom AF variables already!)
local inventoryTypeNeedsMappingToCustomAFCurrentFilter = {
    [INVENTORY_BACKPACK] = true,
    [INVENTORY_CRAFT_BAG] = true,
    [INVENTORY_BANK] = true,
    [INVENTORY_GUILD_BANK] = true,
    [INVENTORY_HOUSE_BANK] = true,
    [INVENTORY_FURNITURE_VAULT] = true,
    [INVENTORY_VENGEANCE] = true,
}
AF.inventoryTypeNeedsMappingToCustomAFCurrentFilter = inventoryTypeNeedsMappingToCustomAFCurrentFilter

local normalFilter2CraftingFilter = {
    [filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_ARMOR]] = {
        [filterTypeNames[ITEMFILTERTYPE_AF_ARMOR_WOODWORKING]]    = true, --ArmorWoodworking
        [filterTypeNames[ITEMFILTERTYPE_AF_ARMOR_SMITHING]]       = true, --ArmorSmithing
        [filterTypeNames[ITEMFILTERTYPE_AF_ARMOR_CLOTHIER]]       = true, --ArmorClothier
        [filterTypeNames[ITEMFILTERTYPE_AF_RETRAIT_ARMOR]]        = true, --ArmorRetrait
    },
    [filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS]] = {
        [filterTypeNames[ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING]]  = true, --WeaponsWoodworking
        [filterTypeNames[ITEMFILTERTYPE_AF_WEAPONS_SMITHING]]     = true, --WeaponsSmithing
        [filterTypeNames[ITEMFILTERTYPE_AF_RETRAIT_WEAPONS]]      = true, --WeaponsRetrait
    },
    [filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY]] = {
        [filterTypeNames[ITEMFILTERTYPE_AF_JEWELRY_CRAFTING]]     = true, --JewelryCraftingStation
        [filterTypeNames[ITEMFILTERTYPE_AF_RETRAIT_JEWELRY]]      = true, --JewelryRetrait
    },
}
AF.normalFilter2CraftingFilter = normalFilter2CraftingFilter

--SUBFILTER BARS
--The list controls for the reanchoring of subfilter bars
local reanchorDataSmithingResearch = {
    {
        --The research line list in total was anchored to the include banked checkbox
        control         = ZO_SmithingTopLevelResearchPanelResearchLineList,
        anchorPoint     = TOP,
        relativeTo      = ZO_SmithingTopLevelResearchPanelButtonDivider,
        relativePoint   = BOTTOM,
        offsetX         = 0,
        offsetY         = 45,--subFilter bar height + 5 space
    },
    {
        --The research line list in total was anchored to the include banked checkbox
        control         = ZO_SmithingTopLevelResearchPanelResearchLineListList,
        anchorPoint     = TOP,
        relativeTo      = ZO_SmithingTopLevelResearchPanelResearchLineList,
        relativePoint   = TOP,
        offsetX         = 0,
        offsetY         = 30,
    },
    {
        --The researching text at the top left edge at the SMITHING reasearch panel
        control         = ZO_SmithingTopLevelResearchPanelNumResearching,
        anchorPoint     = TOPLEFT,
        relativeTo      = ZO_SmithingTopLevelResearchPanel,
        relativePoint   = TOPLEFT,
        offsetX         = 68,
        offsetY         = 8, --18 original
    },
}
local researchListControlForSubfilterBarReanchor = {
        listData = {
            control         = controlsForChecks.researchPanel.researchLineList.control,
            --parent          =,
            anchorPoint     = TOP,
            --relativeTo      =,
            relativePoint   = BOTTOM,
            offsetX         = 0,
            offsetY         = 5,
        },
        moveInvBottomBarDown    = ZO_SmithingTopLevelResearchPanelInfoBar, --For addon "PerfectPixel"
        reanchorData            = reanchorDataSmithingResearch,
    }
local listControlForSubfilterBarReanchor = {
    --[[
    [LF_INVENTORY]          = {
        listData = {
            control                 = controlsForChecks.inv,
            parent                  = ?
            anchorPoint             = TOPLEFT
            relativeTo              = ?
            relativePoint           = TOPLEFT
            offsetX                 = 0,
            offsetY                 = 5,
        },
        moveInvBottomBarDown    = ZO_PlayerInventory..., --For addon "PerfectPixel"
        reanchorData            = {
            {
                control         = ZO_SmithingTopLevelResearchPanelNumResearching,
                anchorPoint     = TOPLEFT,
                relativeTo      = ZO_SmithingTopLevelResearchPanel,
                relativePoint   = TOPLEFT,
                offsetX         = 68,
                offsetY         = 8, --18 original
            },
            ...
        },
    },
    ]]
    [LF_SMITHING_RESEARCH]  =   researchListControlForSubfilterBarReanchor,
    [LF_JEWELRY_RESEARCH]   =   researchListControlForSubfilterBarReanchor,
    [LF_ENCHANTING_CREATION] = {
        reanchorData            = {
            {
                --The "quest only" checkbox and anchored label
                control         = GetControl(controlsForChecks.enchanting.inventory.control, questItemsOnly),
                anchorPoint     = TOPLEFT,
                relativeTo      = controlsForChecks.enchanting.inventory.control,
                relativePoint   = TOPLEFT,
                offsetX         = 0,
                offsetY         = 20,
            }
        },
    },
}
AF.listControlForSubfilterBarReanchor = listControlForSubfilterBarReanchor

--There are no subfilter bars active at the following inventory panels. Used for debug messages!
local subFiltersBarInactive = {
    --[ITEM_TYPE_DISPLAY_CATEGORY_QUEST]  = INVENTORY_QUEST_ITEM,  -- Inventory: Quest items
    --Custom addons
    [ITEMFILTERTYPE_AF_STOLENFILTER]    = INVENTORY_BACKPACK,
}
AF.subFiltersBarInactive = subFiltersBarInactive

--These panels are currently not supported
-->TODO: Remove those entries in the future where subFilter groups and bars SHOULD or COULD be possible!
-->Remember to check if errors occur as these tabs are opened as default tab (via addons like FCOCraftFilter)!
local notSupportedPanels = {
    [CRAFTING_TYPE_ALCHEMY] = {
        [ZO_ALCHEMY_MODE_NONE] = true,
        [ZO_ALCHEMY_MODE_CREATION] = true,
        [ZO_ALCHEMY_MODE_RECIPES] = true
    },
    [CRAFTING_TYPE_BLACKSMITHING] = {
        [SMITHING_MODE_ROOT] = true,
        [SMITHING_MODE_CREATION] = true,
        [SMITHING_MODE_RECIPES] = true
    },
    [CRAFTING_TYPE_CLOTHIER] = {
        [SMITHING_MODE_ROOT] = true,
        [SMITHING_MODE_CREATION] = true,
        [SMITHING_MODE_RECIPES] = true
    },
    [CRAFTING_TYPE_ENCHANTING] = {
        [ENCHANTING_MODE_NONE] = true,
        [ENCHANTING_MODE_RECIPES] = true,
    },
    [CRAFTING_TYPE_JEWELRYCRAFTING] = {
        [SMITHING_MODE_ROOT] = true,
        [SMITHING_MODE_CREATION] = true,
        [SMITHING_MODE_RECIPES] = true
    },
    [CRAFTING_TYPE_PROVISIONING] = {
        [PROVISIONER_SPECIAL_INGREDIENT_TYPE_NONE] = true,
        [PROVISIONER_SPECIAL_INGREDIENT_TYPE_FILLET] = true,
        [PROVISIONER_SPECIAL_INGREDIENT_TYPE_SPICES] = true,
        [PROVISIONER_SPECIAL_INGREDIENT_TYPE_FLAVORING] = true,
        [PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING] = true,
    },
    [CRAFTING_TYPE_WOODWORKING] = {
        [SMITHING_MODE_ROOT] = true,
        [SMITHING_MODE_CREATION] = true,
        [SMITHING_MODE_RECIPES] = true
    },
}
AF.notSupportedPanels = notSupportedPanels

--Some special constellations where the subfilterbar should not be shown
local subfilterBarsShouldOnlyBeShownSpecial = {
    --Smithing refine
    [LF_SMITHING_REFINE] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [SMITHING_FILTER_TYPE_RAW_MATERIALS] = true,
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [SMITHING_FILTER_TYPE_RAW_MATERIALS] = true,
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [SMITHING_FILTER_TYPE_RAW_MATERIALS] = true,
        },
    },
    --Jewelry refine
    [LF_JEWELRY_REFINE] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [SMITHING_FILTER_TYPE_RAW_MATERIALS] = true,
        }
    }
}
AF.subfilterBarsShouldOnlyBeShownSpecial = subfilterBarsShouldOnlyBeShownSpecial

--Universal deconstruction mapping
local subfilterBarInventorytypesOfUniversalDecon = {
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ALL] =     true,
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ARMOR] =   true,
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_WEAPONS] = true,
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_JEWELRY] = true,
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_GLYPHS] =  true,
}
AF.subfilterBarInventorytypesOfUniversalDecon = subfilterBarInventorytypesOfUniversalDecon

local universalDeconSelectedTabToAFInventoryType = {
    ["all"] =           INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ALL,
    ["weapons"] =       INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_WEAPONS,
    ["armor"] =         INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ARMOR,
    ["jewelry"] =       INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_JEWELRY,
    ["enchantments"] =  INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_GLYPHS,
}
AF.universalDeconSelectedTabToAFInventoryType = universalDeconSelectedTabToAFInventoryType

local universalDeconKeyToAFFilterType = {
    ["all"] =           ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL,
    ["weapons"] =       ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS,
    ["armor"] =         ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR,
    ["jewelry"] =       ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY,
    ["enchantments"] =  ITEMFILTERTYPE_AF_UNIVERSAL_DECON_GLYPHS,
}
AF.universalDeconKeyToAFFilterType = universalDeconKeyToAFFilterType

AF.panelIdSupportedAtDeconNPC = nil --util.LibFilters.mapping.universalDeconLibFiltersFilterTypeSupported will be updated in function util.HideInventoryControls


--Inventory types which should not be updated via function ChangeFilter in PLAYER_INVENTORY
--[[
--> This caused the problem with bug #28:
#28 2020-06-30, FooWasHere: Talk to vendor for woodworking, sell tab, change filter from ALL to "Weapons". Leave the woodworking vendor. Open any other vendor where there is NO
--                          Weapons subfilter given: Only weapons subfilterbar is shown and everything else is hiddem, including items

local doNotUpdateInventoriesWithInventoryChangeFilterFunction = {
    [INVENTORY_TYPE_VENDOR_BUY] = true,
}
AF.doNotUpdateInventoriesWithInventoryChangeFilterFunction = doNotUpdateInventoriesWithInventoryChangeFilterFunction
]]

--Some special inventory types which will update the variable AF.currentInventoryType if a check is done (e.g. at
--activation of a subfilter bar button)
local specialInventoryTypes = {
    [INVENTORY_QUEST_ITEM] = true
}
AF.specialInventoryTypes = specialInventoryTypes

--Abort the subfilter bar refresh for the following inventory types
local abortSubFilterRefreshInventoryTypes = {
    --[INVENTORY_TYPE_VENDOR_BUY]             = true, --Vendor buy
    --[INVENTORY_QUEST_ITEM]                  = true, --Quest items
    --Custom addons
    [ITEMFILTERTYPE_AF_STOLENFILTER] = true,
}
AF.abortSubFilterRefreshInventoryTypes = abortSubFilterRefreshInventoryTypes

--The possible subfilter groups for each inventory type, trade skill type and filtertype.
local subfilterGroups = {
    --Player inventory
    --> Will be re-used for inventory, bank deposit, guild bank deposit, house bank deposit, mail, trade with player, vendor sell, guild store sell
    [INVENTORY_BACKPACK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_ARMOR] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRYCRAFTING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_COMPANION] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JUNK] = {},

            --CUSTOM ADDON TABs
            --[[
            [ITEMFILTERTYPE_AF_STOLENFILTER] = {},
            ]]
        },
    },
    --Bank
    [INVENTORY_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_ARMOR] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRYCRAFTING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_COMPANION] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JUNK] = {},
        },
    },
    --Guild bank
    [INVENTORY_GUILD_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_ARMOR] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRYCRAFTING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_COMPANION] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS] = {},
        },
    },
    --Houes bank withdraw
    [INVENTORY_HOUSE_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_ARMOR] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_COMPANION] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JUNK] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRYCRAFTING] = {},
        },
    },
    --Furniture Vault
    [INVENTORY_FURNITURE_VAULT] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {}, --todo 20250605 Define subcategory mapping and add those to callback for filters, textures etc.
            [ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING] = {},
        },
    },
    --Craft bag
    [INVENTORY_CRAFT_BAG] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_BLACKSMITHING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CLOTHING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_WOODWORKING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_ALCHEMY] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_ENCHANTING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_PROVISIONING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRYCRAFTING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_STYLE_MATERIAL] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_TRAIT_ITEM] = {},
            [ITEMFILTERTYPE_AF_CRAFTBAG_MISCELLANEOUS] = {},
        },
    },
    --Quest items
    [INVENTORY_QUEST_ITEM] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_QUEST] = {},
        },
    },
    --Vendor buy -- no standard ZOs inventory type! Self defined in AdvancedFilters with value 900
    -->ZOs did not change the vendor buy as well :-( Only the normal inventories were changed
--[[
    [INVENTORY_TYPE_VENDOR_BUY] = {
        [CRAFTING_TYPE_INVALID] = {
            --New
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_ARMOR] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS] = {},
            [ITEMFILTERTYPE_COLLECTIBLE] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING] ={},
            --Old
            [ITEMFILTERTYPE_ALL] = {},
            [ITEMFILTERTYPE_WEAPONS] = {},
            [ITEMFILTERTYPE_ARMOR] = {},
            [ITEMFILTERTYPE_CONSUMABLE] = {},
            [ITEMFILTERTYPE_CRAFTING] = {},
            [ITEMFILTERTYPE_MISCELLANEOUS] = {},
            [ITEMFILTERTYPE_COLLECTIBLE] = {},
            [ITEMFILTERTYPE_JEWELRY] = {},
            [ITEMFILTERTYPE_FURNISHING] ={},
        },
    },
]]

    --API101048 Cyrodiil Vengeance campaign inventory stuff
    [INVENTORY_VENGEANCE] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_ARMOR] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JUNK] = {},
        },
    },

    --Crafting SMITHING: Create
    --[[
    [LF_SMITHING_CREATION] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_CREATE_ARMOR_SMITHING] = {},
            [ITEMFILTERTYPE_AF_CREATE_WEAPONS_SMITHING] = {},
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_CREATE_ARMOR_WOODWORKING] = {},
            [ITEMFILTERTYPE_AF_CREATE_WEAPONS_WOODWORKING] = {},
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_CREATE_ARMOR_CLOTHIER] = {},
        },
    },
    ]]

    --Crafting SMITHING: Refine
    [LF_SMITHING_REFINE] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_REFINE_SMITHING] = {},
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_REFINE_WOODWORKING] = {},
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_REFINE_CLOTHIER] = {},
        },
    },

    --Crafting SMITHING: Deconstruction
    [LF_SMITHING_DECONSTRUCT] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_SMITHING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_SMITHING] = {},
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING] = {},
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER] = {},
        },
    },

    --Crafting SMITHING: Improvement
    [LF_SMITHING_IMPROVEMENT] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_SMITHING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_SMITHING] = {},
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING] = {},
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER] = {},
        },
    },

    --Crafting SMITHING: Research
    [LF_SMITHING_RESEARCH] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_SMITHING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_SMITHING] = {},
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING] = {},
            [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING] = {},
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER] = {},
        },
    },

    --Crafting JEWELRY: Create
    --[[
    [LF_JEWELRY_CREATION] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_CREATE_JEWELRY] = {},
        },
    },
    ]]

    --Crafting JEWELRY: Refine
    [LF_JEWELRY_REFINE] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_REFINE_JEWELRY] = {},
        },
    },

    --Crafting JEWELRY: Deconstruction
    [LF_JEWELRY_DECONSTRUCT] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING] = {},
        },
    },
    --Crafting JEWELRY: Improvement
    [LF_JEWELRY_IMPROVEMENT] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING] = {},
        },
    },

    --Crafting JEWELRY: Research
    [LF_JEWELRY_RESEARCH] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING] = {},
        },
    },

    --Crafting ENCHANTING: Creation
    [LF_ENCHANTING_CREATION] = {
        [CRAFTING_TYPE_ENCHANTING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            --[ITEMFILTERTYPE_AF_RUNES_ENCHANTING] = {}, TODO: Currently disabled as no extra filters are needed/possible
        },
    },
    --Crafting ENCHANTING: Extraction
    [LF_ENCHANTING_EXTRACTION] = {
        [CRAFTING_TYPE_ENCHANTING] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING] = {},
        },
    },
    --Retrait
    [LF_RETRAIT] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL]    = {},
            [ITEMFILTERTYPE_AF_RETRAIT_ARMOR]   = {},
            [ITEMFILTERTYPE_AF_RETRAIT_WEAPONS] = {},
            [ITEMFILTERTYPE_AF_RETRAIT_JEWELRY] = {},
        },
    },
    --QuickSlots
    [LF_QUICKSLOT] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL]                  = {}, --ITEMFILTERTYPE_ALL
            [AF_QS_PREFIX..ITEMFILTERTYPE_QUICKSLOT]          = {},
            [AF_QS_PREFIX..ITEMFILTERTYPE_QUEST_QUICKSLOT]    = {},
        }
    },
    --Companion inventory
    [LF_INVENTORY_COMPANION] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_ARMOR] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS] = {},
            [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY] = {},
        },
    },
}
--Universal Deconstruction
subfilterGroups[INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ALL] = {
    [CRAFTING_TYPE_INVALID] = {
        [ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL] = {},
    },
}
subfilterGroups[INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_WEAPONS] = {
    [CRAFTING_TYPE_INVALID] = {
        [ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS]      = {},
    },
}
subfilterGroups[INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ARMOR] = {
    [CRAFTING_TYPE_INVALID] = {
        [ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR]        = {},
    },
}
subfilterGroups[INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_JEWELRY] = {
    [CRAFTING_TYPE_INVALID] = {
        [ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY]      = {},
    },
}
subfilterGroups[INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_GLYPHS] = {
    [CRAFTING_TYPE_INVALID] = {
        [ITEMFILTERTYPE_AF_UNIVERSAL_DECON_GLYPHS]      = {},
    },
}
AF.subfilterGroups = subfilterGroups

--INVENTORY TYPES
--The following inventoryTypes (within AF.subfilterGroups) are LibFilters filterPanelIds!
local invEqualsLibFilters = {
    [LF_QUICKSLOT]              = true,
    [LF_SMITHING_REFINE]        = true,
    [LF_JEWELRY_REFINE]         = true,
    [LF_SMITHING_CREATION]      = true,
    [LF_JEWELRY_CREATION]       = true,
    [LF_SMITHING_DECONSTRUCT]   = true,
    [LF_JEWELRY_DECONSTRUCT]    = true,
    [LF_SMITHING_IMPROVEMENT]   = true,
    [LF_JEWELRY_IMPROVEMENT]    = true,
    [LF_SMITHING_RESEARCH]      = true,
    [LF_JEWELRY_RESEARCH]       = true,
    [LF_ENCHANTING_CREATION]    = true,
    [LF_ENCHANTING_EXTRACTION]  = true,
    [LF_RETRAIT]                = true,
    [LF_INVENTORY_COMPANION]    = true,
}
AF.invEqualsLibFilters = invEqualsLibFilters

--Map the inventory types to their LibFilters filterType constant, where there is no entry in invEqualsLibFilters
local mapInvTypeToLibFiltersFilterType = {
    --Inventory
    --Does not work as we need to check which filterType it is as the panel opens, and not as the subfilterBar gets created.
    --So we will set the value to LF_INVENTORY and add a function to the control/fragment of the inventory to get the proper filterType
    --[INVENTORY_BACKPACK]        = function(...) local lUtil = AF.util return lUtil.GetLibFiltersFilterTypeForInventorySubfilterGroup(...) end, --function to return LF_INVENTORY, LF_BANK_DEPOSIT etc. properly
    [INVENTORY_BACKPACK]        = LF_INVENTORY,
    --Others
    [INVENTORY_QUEST_ITEM]      = LF_INVENTORY_QUEST,
    [INVENTORY_CRAFT_BAG]       = LF_CRAFTBAG,
    [INVENTORY_BANK]            = LF_BANK_WITHDRAW,
    [INVENTORY_HOUSE_BANK]      = LF_HOUSE_BANK_WITHDRAW,
    [INVENTORY_GUILD_BANK]      = LF_GUILDBANK_WITHDRAW,
    [INVENTORY_FURNITURE_VAULT] = LF_FURNITURE_VAULT_WITHDRAW,
    --Universal deconstruction
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ALL] =     LF_SMITHING_DECONSTRUCT,
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_WEAPONS] = LF_SMITHING_DECONSTRUCT,
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ARMOR] =   LF_SMITHING_DECONSTRUCT,
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_JEWELRY] = LF_JEWELRY_DECONSTRUCT,
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_GLYPHS] =  LF_ENCHANTING_EXTRACTION,
    --API101048 Cyrodiil Vengeance
    [INVENTORY_VENGEANCE]       = LF_INVENTORY_VENGEANCE
}
AF.mapInvTypeToLibFiltersFilterType = mapInvTypeToLibFiltersFilterType

local mapInvTypeToInvTypeBefore = {
    --Inventory
    [INVENTORY_BACKPACK]        = INVENTORY_QUEST_ITEM,
    [INVENTORY_QUEST_ITEM]      = INVENTORY_BACKPACK,
    --Enchanting
    [LF_ENCHANTING_CREATION]    = LF_ENCHANTING_EXTRACTION,
    [LF_ENCHANTING_EXTRACTION]  = LF_ENCHANTING_CREATION,
    --Refinement
    [LF_SMITHING_REFINE]        = LF_JEWELRY_REFINE,
    [LF_JEWELRY_REFINE]         = LF_SMITHING_REFINE,
    --Deconstruction
    [LF_SMITHING_DECONSTRUCT]   = LF_JEWELRY_DECONSTRUCT,
    [LF_JEWELRY_DECONSTRUCT]    = LF_SMITHING_DECONSTRUCT,
    --Improvement
    [LF_SMITHING_IMPROVEMENT]   = LF_JEWELRY_IMPROVEMENT,
    [LF_JEWELRY_IMPROVEMENT]    = LF_SMITHING_IMPROVEMENT,
    --Research
    [LF_SMITHING_RESEARCH]      = LF_JEWELRY_RESEARCH,
    [LF_JEWELRY_RESEARCH]       = LF_SMITHING_RESEARCH,
}
AF.mapInvTypeToInvTypeBefore = mapInvTypeToInvTypeBefore

--The filter bar parent controls
local filterBarParents = {
    --ZOs vanilla inventories
    [inventoryNames[INVENTORY_BACKPACK]]        = GetControl(controlsForChecks.inv, filterDividerSuffix),
    [inventoryNames[INVENTORY_CRAFT_BAG]]       = GetControl(controlsForChecks.craftBag, filterDividerSuffix),
    [inventoryNames[INVENTORY_QUEST_ITEM]]      = GetControl(controlsForChecks.inv, filterDividerSuffix),
    [inventoryNames[INVENTORY_BANK]]            = GetControl(controlsForChecks.bank, filterDividerSuffix),
    [inventoryNames[INVENTORY_GUILD_BANK]]      = GetControl(controlsForChecks.guildBank, filterDividerSuffix),
    [inventoryNames[INVENTORY_HOUSE_BANK]]      = GetControl(controlsForChecks.houseBank, filterDividerSuffix),
    [inventoryNames[INVENTORY_FURNITURE_VAULT]] = GetControl(controlsForChecks.furnitureVault, filterDividerSuffix),
    [inventoryNames[INVENTORY_VENGEANCE]]       = GetControl(controlsForChecks.vengeanceInv, filterDividerSuffix),

    --LibFilters crafting filterTypes
    --[inventoryNames[LF_SMITHING_CREATION]]      = controlsForChecks.smithing.creationPanel.control,
    [inventoryNames[LF_SMITHING_REFINE]]        = GetControl(controlsForChecks.smithing.refinementPanel.inventory.control, filterDividerSuffix),
    [inventoryNames[LF_SMITHING_DECONSTRUCT]]   = GetControl(controlsForChecks.smithing.deconstructionPanel.inventory.control, filterDividerSuffix),
    [inventoryNames[LF_SMITHING_IMPROVEMENT]]   = GetControl(controlsForChecks.smithing.improvementPanel.inventory.control, filterDividerSuffix),
    [inventoryNames[LF_SMITHING_RESEARCH]]      = GetControl(controlsForChecks.smithing.researchPanel.control, buttonDividerSuffix),
    --[inventoryNames[LF_JEWELRY_CREATION]]       = controlsForChecks.smithing.creationPanel.control,
    [inventoryNames[LF_JEWELRY_REFINE]]         = GetControl(controlsForChecks.smithing.refinementPanel.inventory.control, filterDividerSuffix),
    [inventoryNames[LF_JEWELRY_DECONSTRUCT]]    = GetControl(controlsForChecks.smithing.deconstructionPanel.inventory.control, filterDividerSuffix),
    [inventoryNames[LF_JEWELRY_IMPROVEMENT]]    = GetControl(controlsForChecks.smithing.improvementPanel.inventory.control, filterDividerSuffix),
    [inventoryNames[LF_JEWELRY_RESEARCH]]       = GetControl(controlsForChecks.smithing.researchPanel.control, buttonDividerSuffix),
    [inventoryNames[LF_ENCHANTING_CREATION]]    = GetControl(controlsForChecks.enchanting.inventoryControl, filterDividerSuffix),
    [inventoryNames[LF_ENCHANTING_EXTRACTION]]  = GetControl(controlsForChecks.enchanting.inventoryControl, filterDividerSuffix),
    [inventoryNames[LF_RETRAIT]]                = GetControl(controlsForChecks.retrait.inventory.control, filterDividerSuffix),
    --LibFilters other filterTypes
    [inventoryNames[LF_QUICKSLOT]]              = (quickslotKeyboard ~= nil and GetControl(quickslotKeyboard.control, filterDividerSuffix)) or GetControl(controlsForChecks.quickslot.container, filterDividerSuffix),
    [inventoryNames[LF_INVENTORY_COMPANION]]    = GetControl(controlsForChecks.companionInv.control, filterDividerSuffix),

    --AdvancedFilters custom inventoryTypes
    [inventoryNames[INVENTORY_TYPE_VENDOR_BUY]] = GetControl(controlsForChecks.storeWindow, filterDividerSuffix),
}
filterBarParents[inventoryNames[INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ALL]] =     GetControl(controlsForChecks.universalDeconPanelInvControl, filterDividerSuffix)
filterBarParents[inventoryNames[INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_WEAPONS]] = GetControl(controlsForChecks.universalDeconPanelInvControl, filterDividerSuffix)
filterBarParents[inventoryNames[INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ARMOR]] =   GetControl(controlsForChecks.universalDeconPanelInvControl, filterDividerSuffix)
filterBarParents[inventoryNames[INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_JEWELRY]] = GetControl(controlsForChecks.universalDeconPanelInvControl, filterDividerSuffix)
filterBarParents[inventoryNames[INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_GLYPHS]] =  GetControl(controlsForChecks.universalDeconPanelInvControl, filterDividerSuffix)

AF.filterBarParents = filterBarParents

--Controls which should be hidden as the filter bar is shown at this panel
local researchFilterBarParentControlsToHide = {
    ZO_SmithingTopLevelResearchPanelResearchLineListDivider,
    ZO_SmithingTopLevelResearchPanelResearchLineListTitle,
}
local filterBarParentControlsToHide = {
    [LF_INVENTORY]   = {
        --ZO_PlayerInventorySearchDivider
        GetControl(controlsForChecks.inv, searchDividerSuffix),
    },
    [LF_INVENTORY_VENGEANCE]   = {
        --ZO_VengeanceInventorySearchDivider
        GetControl(controlsForChecks.vengeanceInv, searchDividerSuffix),
    },
    [LF_MAIL_SEND]   = {
        --ZO_PlayerInventorySearchDivider
        GetControl(controlsForChecks.inv, searchDividerSuffix),
    },
    [LF_TRADE]   = {
        --ZO_PlayerInventorySearchDivider
        GetControl(controlsForChecks.inv, searchDividerSuffix),
    },
    [LF_CRAFTBAG]   = {
        GetControl(controlsForChecks.craftBag, searchDividerSuffix),
    },
    [LF_BANK_DEPOSIT]   = {
        GetControl(controlsForChecks.inv, searchDividerSuffix),
    },
    [LF_BANK_WITHDRAW]   = {
        GetControl(controlsForChecks.bank, searchDividerSuffix),
    },
    [LF_GUILDBANK_DEPOSIT]   = {
        GetControl(controlsForChecks.inv, searchDividerSuffix),
    },
    [LF_GUILDBANK_WITHDRAW]   = {
        GetControl(controlsForChecks.guildBank, searchDividerSuffix),
    },
    [LF_GUILDSTORE_SELL]   = {
        GetControl(controlsForChecks.guildStoreSellBackpack, searchDividerSuffix),
    },
    --[[
    [LF_VENDOR_SELL]   = {
        GetControl(controlsForChecks.storeWindow, searchDividerSuffix),
    },
    ]]
    [LF_HOUSE_BANK_WITHDRAW]   = {
        GetControl(controlsForChecks.houseBank, searchDividerSuffix),
    },
    [LF_SMITHING_DECONSTRUCT]   = {
        --ZO_SmithingTopLevelDeconstructionPanelInventoryButtonDivider
        GetControl(controlsForChecks.smithing.deconstructionPanel.inventory.control, buttonDividerSuffix),
    },
    [LF_JEWELRY_DECONSTRUCT]    = {
        GetControl(controlsForChecks.smithing.deconstructionPanel.inventory.control, buttonDividerSuffix),
    },
    [LF_SMITHING_RESEARCH]  = researchFilterBarParentControlsToHide,
    [LF_JEWELRY_RESEARCH]   = researchFilterBarParentControlsToHide,
    [LF_ENCHANTING_CREATION]    = {
        GetControl(controlsForChecks.enchanting.inventory.control, buttonDividerSuffix),
    },
    [LF_ENCHANTING_EXTRACTION]  = {
        GetControl(controlsForChecks.enchanting.inventory.control, buttonDividerSuffix),

    },
    [LF_RETRAIT]  = {
        GetControl(controlsForChecks.retrait.inventory.control, buttonDividerSuffix),
    },
    [LF_QUICKSLOT] = {
        (quickslotKeyboard ~= nil and GetControl(quickslotKeyboard.control, searchDividerSuffix)) or GetControl(controlsForChecks.quickslot.container, searchDividerSuffix),
    },
    [LF_INVENTORY_COMPANION] = {
        GetControl(controlsForChecks.companionInv.control, searchDividerSuffix),
    },
    [LF_FURNITURE_VAULT_DEPOSIT]   = {
        GetControl(controlsForChecks.inv, searchDividerSuffix),
    },
    [LF_FURNITURE_VAULT_WITHDRAW]   = {
        GetControl(controlsForChecks.furnitureVault, searchDividerSuffix),
    },
}
filterBarParentControlsToHide[LF_SMITHING_DECONSTRUCT]["universalDeconstruction"] = GetControl(controlsForChecks.universalDeconPanelInvControl, buttonDividerSuffix)
filterBarParentControlsToHide[LF_JEWELRY_DECONSTRUCT]["universalDeconstruction"] = GetControl(controlsForChecks.universalDeconPanelInvControl, buttonDividerSuffix)
filterBarParentControlsToHide[LF_ENCHANTING_EXTRACTION]["universalDeconstruction"] = GetControl(controlsForChecks.universalDeconPanelInvControl, buttonDividerSuffix)

AF.filterBarParentControlsToHide = filterBarParentControlsToHide


--The fragment controls which contain the inventory layoutData tables
-->Used for e.g. the vanilla UI searchFilter bars, to disable them (hide them)
local layoutDataFragments = {
    BACKPACK_DEFAULT_LAYOUT_FRAGMENT,
    BACKPACK_MENU_BAR_LAYOUT_FRAGMENT,
    BACKPACK_TRADING_HOUSE_LAYOUT_FRAGMENT,
    --BACKPACK_FURNITURE_VAULT_LAYOUT_FRAGMENT, --todo 20250605 needed?
}
table.insert(layoutDataFragments, quickslotFragment)

AF.layoutDataFragments = layoutDataFragments

--The crafting inventory layoutdata for the filterBar, inventoryList, sortHeader offsets
--for some of the panels, e.g. ENCHANTING
--2020-11-23:
local AF_modifiedInventoryBackpackLayoutDataForQuickslot = {
    --inventoryFilterDividerTopOffsetY = DEFAULT_INVENTORY_FILTER_DIVIDER_TOP_OFFSET_Y,
    --width = 565,
    backpackOffsetY = 136, --original is 136 in BACKPACK_DEFAULT_LAYOUT_FRAGMENT.layoutData
    --inventoryTopOffsetY = -20,
    --inventoryBottomOffsetY = -30,
    sortByOffsetY = 96,
    --emptyLabelOffsetY = 100,
    --sortByHeaderWidth = 576,
    --sortByNameWidth = 241,
    --hideBankInfo = true,
    --hideCurrencyInfo = false,
}
local filterBarAlternativeInventoryLayoutData = {
    [LF_QUICKSLOT]         = AF_modifiedInventoryBackpackLayoutDataForQuickslot,
}
AF.filterBarAlternativeInventoryLayoutData = filterBarAlternativeInventoryLayoutData

--SUBFILTER BAR BUTTONS
--The subfilter bars button names
--> Attention: Make sure to maintain file filterCallbacks.lua, table "subfilterCallbacks" too if you change the table below!
local subfilterButtonNames = {
    [ITEM_TYPE_DISPLAY_CATEGORY_ALL] = {
        AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS] = {
        "HealStaff", "DestructionStaff", "Bow", "TwoHand", "OneHand", AF_CONST_ALL,
    },
    --[[
    [ITEMFILTERTYPE_AF_CREATE_ARMOR_CLOTHIER] = {
        "Heavy", AF_CONST_ALL
    },
    [ITEMFILTERTYPE_AF_CREATE_ARMOR_SMITHING] = {
        "Medium", "LightArmor", AF_CONST_ALL
    },
    [ITEMFILTERTYPE_AF_CREATE_ARMOR_WOODWORKING] = {
        "Shield", AF_CONST_ALL
    },
    [ITEMFILTERTYPE_AF_CREATE_WEAPONS_SMITHING] = {
        "OneHand", "TwoHand", AF_CONST_ALL
    },
    [ITEMFILTERTYPE_AF_CREATE_WEAPONS_WOODWORKING] = {
        "Bow", "DestructionStaff", "HealStaff", AF_CONST_ALL
    },
    [ITEMFILTERTYPE_AF_CREATE_JEWELRY] = {
        "Ring", "Neck", AF_CONST_ALL,
    },
    ]]
    [ITEMFILTERTYPE_AF_REFINE_CLOTHIER] = {
        "RawMaterialClothier", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_REFINE_SMITHING] = {
        "RawMaterialSmithing", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_REFINE_WOODWORKING] = {
        "RawMaterialWoodworking", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_WEAPONS_SMITHING] = {
        "TwoHand", "OneHand", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING] = {
        "HealStaff", "DestructionStaff", "Bow", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_ARMOR] = {
        --"Vanity", --> Moved to Miscelaneous
        "Shield", "Clothing", "Heavy", "Medium", "LightArmor", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY] = {
        "Neck", "Ring", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_ARMOR_SMITHING] = {
        "Heavy", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER] = {
        "Medium", "LightArmor", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING] = {
        "Shield", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_RUNES_ENCHANTING] = {
        AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING] = {
        "JewelryGlyph", "ArmorGlyph", "WeaponGlyph", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_COLLECTIBLE] = {
        AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE] = {
        "Trophy", "Repair", "Container", "Writ", "Motif", "Poison",
        "Potion", "Recipe", "Drink", "Food", "Crown", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] = {
        "Scribing", "FurnishingMat", "AllTraits", --"JewelryTrait", "WeaponTrait", "ArmorTrait", -> Removed due to not enough place! Combined within "AllTraits"
        "Style",
        "JewelryCrafting", "Provisioning", "Enchanting", "Alchemy", "Woodworking",
        "Clothier", "Blacksmithing", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING] = {
        "TargetDummy", "Seating", "Ornamental", "Light", "CraftingStation",
        AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS] = {
        "Vanity", "Trash", "Fence", "Trophy", "Tool", "Bait", "Siege", "SoulGem",
        "Glyphs", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_QUEST] = {
        AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_JUNK] = {
        "Miscellaneous", "Furnishings", "Materials", "Consumable", "Jewelry", "Armor", "Weapon",
        AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_BLACKSMITHING] = {
        "FurnishingMat", "Temper", "RefinedMaterialSmithing", "RawMaterialSmithing", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_CLOTHING] = {
        "FurnishingMat", "Tannin", "RefinedMaterialClothier", "RawMaterialClothier", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_WOODWORKING] = {
        "FurnishingMat", "Resin", "RefinedMaterialWoodworking", "RawMaterialWoodworking", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_ALCHEMY] = {
        "FurnishingMat", "Oil", "Water", "Reagent", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_ENCHANTING] = {
        "FurnishingMat", "Potency", "Essence", "Aspect", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_PROVISIONING] = {
        "FurnishingMat", "Bait", "RareIngredient", --"OldIngredient",
        "DrinkIngredient", "FoodIngredient", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRYCRAFTING] = {
        "FurnishingMat", "Plating", "RefinedMaterialJewelry", "RawPlating", "RawMaterialJewelry", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING] = {
        "Neck", "Ring", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_REFINE_JEWELRY] = {
        "RawMaterialJewelry", "RawPlating", "JewelryRawTrait", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_STYLE_MATERIAL] = {
        "CrownStyle", "ExoticStyle", "AllianceStyle", "RareStyle",
        "NormalStyle", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_TRAIT_ITEM] = {
        "JewelryAllTrait", "WeaponTrait", "ArmorTrait", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_RETRAIT_ARMOR] = {
        "Shield", "Heavy", "Medium", "LightArmor", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_RETRAIT_WEAPONS] = {
        "HealStaff", "DestructionStaff", "Bow", "TwoHand", "OneHand", AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_RETRAIT_JEWELRY] = {
        "Neck", "Ring", AF_CONST_ALL,
    },
    [ITEM_TYPE_DISPLAY_CATEGORY_COMPANION] = {
        "Jewelry", "Weapon", "Armor", AF_CONST_ALL,
    },
    [AF_QS_PREFIX..ITEMFILTERTYPE_QUICKSLOT] = {
        "Trophy", "Repair", "Siege", "Scroll", "Potion", "Food", "Drink", "Crown",
        AF_CONST_ALL,
    },
    [AF_QS_PREFIX..ITEMFILTERTYPE_QUEST_QUICKSLOT] = {
        AF_CONST_ALL,
    },
    [ITEMFILTERTYPE_AF_CRAFTBAG_MISCELLANEOUS] = {
        "Scribing", AF_CONST_ALL,
    }

    --CUSTOM ADDON TABs
    --[[
    [ITEMFILTERTYPE_AF_STOLENFILTER] = {
        AF_CONST_ALL,
    }
    ]]
}

--Universal Deconstruction
subfilterButtonNames[ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL]         = {
    "Glyphs",
    "Neck", "Ring",
    "Shield", "Heavy", "Medium", "LightArmor",
    "HealStaff", "DestructionStaff", "Bow", "TwoHand", "OneHand",
    AF_CONST_ALL
}
subfilterButtonNames[ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS]     = {
    "HealStaff", "DestructionStaff", "Bow", "TwoHand", "OneHand", AF_CONST_ALL,
}
subfilterButtonNames[ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR]       = {
    "Shield", "Heavy", "Medium", "LightArmor", AF_CONST_ALL,
}
subfilterButtonNames[ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY]     = {
    "Neck", "Ring", AF_CONST_ALL
}
subfilterButtonNames[ITEMFILTERTYPE_AF_UNIVERSAL_DECON_GLYPHS]      = {
    "JewelryGlyph", "ArmorGlyph", "WeaponGlyph", AF_CONST_ALL
}



--Dynamic subfilterBar entries, e.g. quickslot -> the collectible subfilterBars. Used in function createAdditionalSubFilterGroups
--in file main.lua
AF.collectibleDataKeyToSubFilterBars = {
    --[Quickslot, dynamically created collectibles subfilterBars]
    --The ones not listed here with the key (see function util.getAFQuickSlotCollectibleKey(categoryData)) will just get
    --1 subfilterBar with AF_CONST_ALL!
    --
    --All others will get the listed bars here. Be sure to also define the categoryTypes below in AF.collectibleDataKeyToCategoryTypes
    --for the same key so they will filter the correct collectible cetegoyTypes!

    --Outfits
    [AF_QS_PREFIX.."13_3_0"] = {
      "BodyMarking", "JewelryPiercing", "HeadMarking", "Facial", "Hair", "Hat", "Skin",
      "Polymorph", "Personality", "Costume", AF_CONST_ALL
    }
}
--[[
COLLECTIBLE_CATEGORY_TYPE_COSTUME = 4
COLLECTIBLE_CATEGORY_TYPE_PERSONALITY = 9
COLLECTIBLE_CATEGORY_TYPE_SKIN = 11
COLLECTIBLE_CATEGORY_TYPE_HAT = 10
COLLECTIBLE_CATEGORY_TYPE_POLYMORPH = 12
COLLECTIBLE_CATEGORY_TYPE_HAIR = 13
COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS = 14
COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY = 15
COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY = 16
COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING = 17
COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING = 18
COLLECTIBLE_CATEGORY_TYPE_ABILITY_SKIN = 23
COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE = 24
]]

--The categoryTypes of the collectibles in the subfilter bars. Used in function createAdditionalSubFilterGroups in file
--main.lua to specify what the GetFilterCallbackForCollectibles function in files/filterCallbacks.lua should filter as categories at this
--subfilterbar
AF.collectibleDataKeyToCategoryTypes = {
    --Outfits
    [AF_QS_PREFIX.."13_3_0"] = {
        ["BodyMarking"]         = {COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING},
        ["JewelryPiercing"]     = {COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY},
        ["HeadMarking"]         = {COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING},
        ["Facial"]              = {COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS, COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY},
        ["Hair"]                = {COLLECTIBLE_CATEGORY_TYPE_HAIR},
        ["Hat"]                 = {COLLECTIBLE_CATEGORY_TYPE_HAT},
        ["Skin"]                = {COLLECTIBLE_CATEGORY_TYPE_SKIN},
        ["Polymorph"]           = {COLLECTIBLE_CATEGORY_TYPE_POLYMORPH},
        ["Personality"]         = {COLLECTIBLE_CATEGORY_TYPE_PERSONALITY},
        ["Costume"]             = {COLLECTIBLE_CATEGORY_TYPE_COSTUME},
    }
}


--Exclude some of the buttons at an inventory type, craft type, and filter type?
--If you add entries be sure to add the other ones, sharing the same AF.subfilterCallbacks[groupName][subfilterName]
--as well!
--[[
local excludeButtonNamesfromSubFilterBar = {
    --InventoryName
    [INVENTORY_CRAFT_BAG] = {
        --TradeSkillNames
        [CRAFTING_TYPE_INVALID] = {
            --FilterTypeNames
            [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] =
                --Exclude this single buttons here:
                "AllTraits"
        }
    },
    [INVENTORY_BACKPACK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] = {
                --Exclude these buttons here:
                {"JewelryTrait", "WeaponTrait", "ArmorTrait"}
            }
        }
    },
    [INVENTORY_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] = {
                --Exclude these buttons here:
                {"JewelryTrait", "WeaponTrait", "ArmorTrait"}
            }
        }
    },
    [INVENTORY_GUILD_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] = {
                --Exclude these buttons here:
                {"JewelryTrait", "WeaponTrait", "ArmorTrait"}
            }
        }
    },
    [INVENTORY_HOUSE_BANK] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] = {
                --Exclude these buttons here:
                {"JewelryTrait", "WeaponTrait", "ArmorTrait"}
            }
        }
    },
    [INVENTORY_TYPE_VENDOR_BUY] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING] = {
                --Exclude these buttons here:
                {"JewelryTrait", "WeaponTrait", "ArmorTrait"}
            }
        }
    },
}
]]
AF.subfilterButtonNames = subfilterButtonNames


--DROPDOWN BOXES
--SubfilterButton entries which should not be added to dropdownCallback entries
local subfilterButtonEntriesNotForDropdownCallback = {
    [ITEM_TYPE_DISPLAY_CATEGORY_ARMOR] = {
        ["doNotAdd"] = {"Clothing", "LightArmor", "Medium", "Heavy"}, --These are combined into the entry "Body"
        ["replaceWith"] = "Body",
    },
}
local subfilterButtonEntriesNotForDropdownCallbackArmorBodyReplacement = subfilterButtonEntriesNotForDropdownCallback[ITEM_TYPE_DISPLAY_CATEGORY_ARMOR]
--Enable the same combined "body" subfilter for the Unievrsal Deconstruction Armor subfilter dropdown entries
subfilterButtonEntriesNotForDropdownCallback[ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL] =   subfilterButtonEntriesNotForDropdownCallbackArmorBodyReplacement
subfilterButtonEntriesNotForDropdownCallback[ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR] = subfilterButtonEntriesNotForDropdownCallbackArmorBodyReplacement
AF.subfilterButtonEntriesNotForDropdownCallback = subfilterButtonEntriesNotForDropdownCallback

--CRAFTBAG
--The different filter groups for the CraftBag
local craftBagFilterGroups = {
    filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_BLACKSMITHING],
    filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_CLOTHING],
    filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_WOODWORKING],
    filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_ALCHEMY],
    filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_ENCHANTING],
    filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_PROVISIONING],
    filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_STYLE_MATERIAL],
    filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_TRAIT_ITEM],
    filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_JEWELRYCRAFTING],
    filterTypeNames[ITEMFILTERTYPE_AF_CRAFTBAG_MISCELLANEOUS],
}
AF.craftBagFilterGroups = craftBagFilterGroups

--CRAFTING
--The variables for the crafting tables (to get the active filter)
local craftingTables = {
    --Smithing
    [LF_SMITHING_REFINE]        = controlsForChecks.smithing,
    [LF_JEWELRY_REFINE]         = controlsForChecks.smithing,
    [LF_SMITHING_CREATION]      = controlsForChecks.smithing,
    [LF_JEWELRY_CREATION]       = controlsForChecks.smithing,
    [LF_SMITHING_DECONSTRUCT]   = controlsForChecks.smithing,
    [LF_JEWELRY_DECONSTRUCT]    = controlsForChecks.smithing,
    [LF_SMITHING_IMPROVEMENT]   = controlsForChecks.smithing,
    [LF_JEWELRY_IMPROVEMENT]    = controlsForChecks.smithing,
    [LF_SMITHING_RESEARCH]      = controlsForChecks.smithing,
    [LF_JEWELRY_RESEARCH]       = controlsForChecks.smithing,
    --Enchanting
    [LF_ENCHANTING_CREATION]    = controlsForChecks.enchanting,
    [LF_ENCHANTING_EXTRACTION]  = controlsForChecks.enchanting,
    --Retrait
    [LF_RETRAIT]                = controlsForChecks.retrait,
}
AF.craftingTables = craftingTables

--The variables for the crafting table panels (to get the active filter of their inventory)
local craftingTablePanels = {
    --Smithing
    [LF_SMITHING_REFINE]        = controlsForChecks.refinementPanel,
    [LF_JEWELRY_REFINE]         = controlsForChecks.refinementPanel,
    [LF_SMITHING_CREATION]      = controlsForChecks.creationPanel,
    [LF_JEWELRY_CREATION]       = controlsForChecks.creationPanel,
    [LF_SMITHING_DECONSTRUCT]   = controlsForChecks.deconstructionPanel,
    [LF_JEWELRY_DECONSTRUCT]    = controlsForChecks.deconstructionPanel,
    [LF_SMITHING_IMPROVEMENT]   = controlsForChecks.improvementPanel,
    [LF_JEWELRY_IMPROVEMENT]    = controlsForChecks.improvementPanel,
    [LF_SMITHING_RESEARCH]      = controlsForChecks.researchPanel,
    [LF_JEWELRY_RESEARCH]       = controlsForChecks.researchPanel,
    --Enchanting
    [LF_ENCHANTING_CREATION]    = controlsForChecks.enchantCreatePanel,
    [LF_ENCHANTING_EXTRACTION]  = controlsForChecks.enchantExtractPanel,
    --Retrait
    [LF_RETRAIT]                = controlsForChecks.retraitPanel,

}
--Universal Deconstruction
craftingTablePanels["universalDeconstruction"] = controlsForChecks.universalDeconPanel
AF.craftingTablePanels = craftingTablePanels

--Does the crafting table use the BAG_WORN in it's inventory checks?
local craftingFilterPanelId2UsesBagWorn = {
    --Smithing
    [LF_SMITHING_IMPROVEMENT]   = true,
    [LF_JEWELRY_IMPROVEMENT]    = true,
    --Retrait
    [LF_RETRAIT]                = true,
}
AF.craftingFilterPanelId2UsesBagWorn = craftingFilterPanelId2UsesBagWorn

--The predicate and filter functions used at the crafting panels to prefiletr and "only" show some items
--e.g. no bound ones or no stolen ones, or only the ones which can be refined etc. (including the stolen and bound checks)
local craftingFilterPanelId2PredicateFunc = {
    [LF_SMITHING_REFINE]        = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingExtraction_DoesItemPassFilter},
    [LF_SMITHING_CREATION]      = {nil, nil},
    [LF_SMITHING_DECONSTRUCT]   = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingExtraction_DoesItemPassFilter},
    [LF_SMITHING_IMPROVEMENT]   = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingImprovement_DoesItemPassFilter},
    [LF_SMITHING_RESEARCH]      = {nil, nil},
    [LF_JEWELRY_REFINE]         = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingExtraction_DoesItemPassFilter},
    [LF_JEWELRY_CREATION]       = true,
    [LF_JEWELRY_DECONSTRUCT]    = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingExtraction_DoesItemPassFilter},
    [LF_JEWELRY_IMPROVEMENT]    = {ZO_SharedSmithingExtraction_IsExtractableItem, ZO_SharedSmithingImprovement_DoesItemPassFilter},
    [LF_JEWELRY_RESEARCH]       = {nil, nil},
    [LF_ENCHANTING_CREATION]    = {nil, nil},
    [LF_ENCHANTING_EXTRACTION]  = {nil, nil},
    [LF_RETRAIT]                = {ZO_RetraitStation_CanItemBeRetraited, ZO_RetraitStation_DoesItemPassFilter},
}
AF.craftingFilterPanelId2PredicateFunc = craftingFilterPanelId2PredicateFunc

--[[
    SMITHING_FILTER_TYPE_RAW_MATERIALS = 1
    SMITHING_FILTER_TYPE_ARMOR = 1
    SMITHING_FILTER_TYPE_WEAPONS = 2
    SMITHING_FILTER_TYPE_ARMOR = 1
    SMITHING_FILTER_TYPE_WEAPONS = 2
    --
    SMITHING_FILTER_TYPE_JEWELRY = 6
    --
    ENCHANTING_MODE_CREATION    = 1
    ENCHANTING_MODE_EXTRACTION  = 2
]]
--Map the AdvancedFilters filter type (selected filter button at the crafting table, or selected subfilter button, e.g. weapons) to the
--itemfilter type that is used for the ESO filters (shown items)
local craftingTableAFFilterType2ESOFilterType = {
    [LF_SMITHING_REFINE] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEMFILTERTYPE_AF_REFINE_SMITHING]             = SMITHING_FILTER_TYPE_RAW_MATERIALS,
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEMFILTERTYPE_AF_REFINE_CLOTHIER]             = SMITHING_FILTER_TYPE_RAW_MATERIALS,
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEMFILTERTYPE_AF_REFINE_WOODWORKING]          = SMITHING_FILTER_TYPE_RAW_MATERIALS,
        },
    },
    [LF_SMITHING_DECONSTRUCT] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEMFILTERTYPE_AF_WEAPONS_SMITHING]            = SMITHING_FILTER_TYPE_WEAPONS,
            [ITEMFILTERTYPE_AF_ARMOR_SMITHING]              = SMITHING_FILTER_TYPE_ARMOR,
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER]              = SMITHING_FILTER_TYPE_ARMOR,
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING]         = SMITHING_FILTER_TYPE_WEAPONS,
            [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING]           = SMITHING_FILTER_TYPE_ARMOR,
        },
    },
    [LF_SMITHING_IMPROVEMENT] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEMFILTERTYPE_AF_WEAPONS_SMITHING]            = SMITHING_FILTER_TYPE_WEAPONS,
            [ITEMFILTERTYPE_AF_ARMOR_SMITHING]              = SMITHING_FILTER_TYPE_ARMOR,
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER]              = SMITHING_FILTER_TYPE_ARMOR,
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING]         = SMITHING_FILTER_TYPE_WEAPONS,
            [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING]           = SMITHING_FILTER_TYPE_ARMOR,
        },

    },
    [LF_SMITHING_RESEARCH] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [ITEMFILTERTYPE_AF_WEAPONS_SMITHING]            = SMITHING_FILTER_TYPE_WEAPONS,
            [ITEMFILTERTYPE_AF_ARMOR_SMITHING]              = SMITHING_FILTER_TYPE_ARMOR,
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [ITEMFILTERTYPE_AF_ARMOR_CLOTHIER]              = SMITHING_FILTER_TYPE_ARMOR,
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING]         = SMITHING_FILTER_TYPE_WEAPONS,
            [ITEMFILTERTYPE_AF_ARMOR_WOODWORKING]           = SMITHING_FILTER_TYPE_ARMOR,
        }
    },
    --[[
    [LF_JEWELRY_CREATION] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEMFILTERTYPE_AF_CREATE_JEWELRY]             = ITEMFILTERTYPE_AF_CREATE_JEWELRY,
        },

    },
    ]]
    [LF_JEWELRY_REFINE] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEMFILTERTYPE_AF_REFINE_JEWELRY]             = SMITHING_FILTER_TYPE_RAW_MATERIALS,
        },

    },
    [LF_JEWELRY_DECONSTRUCT] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING]           = SMITHING_FILTER_TYPE_JEWELRY,
        },
    },
    [LF_JEWELRY_IMPROVEMENT] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING]           = SMITHING_FILTER_TYPE_JEWELRY,
        },

    },
    [LF_JEWELRY_RESEARCH] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEMFILTERTYPE_AF_JEWELRY_CRAFTING]           = SMITHING_FILTER_TYPE_JEWELRY,
        },

    },
    [LF_ENCHANTING_CREATION] = {
        [CRAFTING_TYPE_ENCHANTING] = {
            --TODO: Enable if itemfiltertype subfilters for the runes work: ITEMFILTERTYPE_AF_RUNES_ENCHANTING,
            --[[
            [ITEMFILTERTYPE_AF_RUNES_ENCHANTING]       = ENCHANTING_MODE_CREATION,
            ]]
            [ITEM_TYPE_DISPLAY_CATEGORY_ALL]                            = ENCHANTING_MODE_CREATION,
        },
    },
    [LF_ENCHANTING_EXTRACTION] = {
        [CRAFTING_TYPE_ENCHANTING] = {
            [ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING]           = ENCHANTING_MODE_EXTRACTION,
        },
    },
    [LF_RETRAIT] = {
        [CRAFTING_TYPE_INVALID] = {
            [ITEMFILTERTYPE_AF_RETRAIT_WEAPONS] = SMITHING_FILTER_TYPE_WEAPONS,
            [ITEMFILTERTYPE_AF_RETRAIT_ARMOR]   = SMITHING_FILTER_TYPE_ARMOR,
            [ITEMFILTERTYPE_AF_RETRAIT_JEWELRY] = SMITHING_FILTER_TYPE_JEWELRY,
        },
    },
}
AF.mapIFT2CSFT = craftingTableAFFilterType2ESOFilterType


--Map the ESO filter type (selected filter button at the crafting table, or selected subfilter button, e.g. weapons) to the
--itemfilter type that is used for the AdvancedFilters filters (shown items)
local craftingTableESOFilterType2AFFilterType = {
    --[[
    [LF_SMITHING_CREATION] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [SMITHING_FILTER_TYPE_ARMOR]        = ITEMFILTERTYPE_AF_CREATE_ARMOR_SMITHING,
            [SMITHING_FILTER_TYPE_WEAPONS]      = ITEMFILTERTYPE_AF_CREATE_WEAPONS_SMITHING,
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [SMITHING_FILTER_TYPE_ARMOR]        = ITEMFILTERTYPE_AF_CREATE_ARMOR_CLOTHIER,
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [SMITHING_FILTER_TYPE_ARMOR]        = ITEMFILTERTYPE_AF_CREATE_ARMOR_WOODWORKING,
            [SMITHING_FILTER_TYPE_WEAPONS]      = ITEMFILTERTYPE_AF_CREATE_WEAPONS_WOODWORKING,
        },
    },
    ]]
    [LF_SMITHING_REFINE] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [SMITHING_FILTER_TYPE_RAW_MATERIALS] = ITEMFILTERTYPE_AF_REFINE_SMITHING,
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [SMITHING_FILTER_TYPE_RAW_MATERIALS] = ITEMFILTERTYPE_AF_REFINE_CLOTHIER,
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [SMITHING_FILTER_TYPE_RAW_MATERIALS] = ITEMFILTERTYPE_AF_REFINE_WOODWORKING,
        },
    },
    [LF_SMITHING_DECONSTRUCT] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [SMITHING_FILTER_TYPE_WEAPONS] = ITEMFILTERTYPE_AF_WEAPONS_SMITHING,
            [SMITHING_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_SMITHING,
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [SMITHING_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_CLOTHIER,
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [SMITHING_FILTER_TYPE_WEAPONS] = ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING,
            [SMITHING_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_WOODWORKING,
        },

    },
    [LF_SMITHING_IMPROVEMENT] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [SMITHING_FILTER_TYPE_WEAPONS] = ITEMFILTERTYPE_AF_WEAPONS_SMITHING,
            [SMITHING_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_SMITHING,
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [SMITHING_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_CLOTHIER,
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [SMITHING_FILTER_TYPE_WEAPONS] = ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING,
            [SMITHING_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_WOODWORKING,
        },
    },
    [LF_SMITHING_RESEARCH] = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            [SMITHING_FILTER_TYPE_WEAPONS] = ITEMFILTERTYPE_AF_WEAPONS_SMITHING,
            [SMITHING_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_SMITHING,
        },
        [CRAFTING_TYPE_CLOTHIER] = {
            [SMITHING_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_CLOTHIER,
        },
        [CRAFTING_TYPE_WOODWORKING] = {
            [SMITHING_FILTER_TYPE_WEAPONS] = ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING,
            [SMITHING_FILTER_TYPE_ARMOR] = ITEMFILTERTYPE_AF_ARMOR_WOODWORKING,
        },
    },
    --[[
    [LF_JEWELRY_CREATION] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [ITEMFILTERTYPE_AF_CREATE_JEWELRY]                  = ITEMFILTERTYPE_AF_CREATE_JEWELRY,
        },

    },
    ]]
    [LF_JEWELRY_REFINE] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [SMITHING_FILTER_TYPE_RAW_MATERIALS] = ITEMFILTERTYPE_AF_REFINE_JEWELRY,
        },
    },
    [LF_JEWELRY_DECONSTRUCT] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [SMITHING_FILTER_TYPE_JEWELRY] = ITEMFILTERTYPE_AF_JEWELRY_CRAFTING,
        },

    },
    [LF_JEWELRY_IMPROVEMENT] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [SMITHING_FILTER_TYPE_JEWELRY] = ITEMFILTERTYPE_AF_JEWELRY_CRAFTING,
        },
    },
    [LF_JEWELRY_RESEARCH] = {
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            [SMITHING_FILTER_TYPE_JEWELRY] = ITEMFILTERTYPE_AF_JEWELRY_CRAFTING,
        },
    },
    [LF_ENCHANTING_CREATION] = {
        [CRAFTING_TYPE_ENCHANTING] = {
            [ENCHANTING_MODE_CREATION]  = ITEM_TYPE_DISPLAY_CATEGORY_ALL, --TODO: Enable if itemfiltertype subfilters for the runes work: ITEMFILTERTYPE_AF_RUNES_ENCHANTING,
        },
    },
    [LF_ENCHANTING_EXTRACTION] = {
        [CRAFTING_TYPE_ENCHANTING] = {
            [ENCHANTING_MODE_EXTRACTION] = ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING,
        },
    },
    [LF_RETRAIT] = {
        [CRAFTING_TYPE_INVALID] = {
            [SMITHING_FILTER_TYPE_WEAPONS]  = ITEMFILTERTYPE_AF_RETRAIT_WEAPONS,
            [SMITHING_FILTER_TYPE_ARMOR]    = ITEMFILTERTYPE_AF_RETRAIT_ARMOR,
            [SMITHING_FILTER_TYPE_JEWELRY]  = ITEMFILTERTYPE_AF_RETRAIT_JEWELRY,
        },
    },
}
AF.mapCSFT2IFT = craftingTableESOFilterType2AFFilterType

--OTHER ADDONS
--Mapping for other addons like Harven's Stolen Filters
local customInventoryFilterButton2ItemType = {
    ["HarvensStolenFilter"] = ITEMFILTERTYPE_AF_STOLENFILTER,
    ["NTakLootSteal"]       = ITEMFILTERTYPE_AF_STOLENFILTER,
}
AF.customInventoryFilterButton2ItemType = customInventoryFilterButton2ItemType

--Map the custom addon itemFilterTypes to a LibFilters filterPanelId.
local customAddonItemFilterType2LibFiltersPanelId = {
    [ITEMFILTERTYPE_AF_STOLENFILTER] = LF_INVENTORY,
}
AF.customAddonItemFilterType2LibFiltersPanelId = customAddonItemFilterType2LibFiltersPanelId


--RESEARCH panel
--The indices of the research horizontal scrollList for the different weapontypes
local researchLineListIndicesOfWeaponOrArmorOrJewelryTypes = {
    [CRAFTING_TYPE_BLACKSMITHING] = {
        --Weapons
        [SMITHING_FILTER_TYPE_WEAPONS] = {
            --1hd
            [WEAPONTYPE_AXE]                = 0,
            [WEAPONTYPE_HAMMER]             = -1,
            [WEAPONTYPE_SWORD]              = -2,
            [WEAPONTYPE_DAGGER]             = -6,
            --2hd
            [WEAPONTYPE_TWO_HANDED_AXE]     = -3,
            [WEAPONTYPE_TWO_HANDED_HAMMER]  = -4,
            [WEAPONTYPE_TWO_HANDED_SWORD]   = -5,
        },
        --Armor
        [SMITHING_FILTER_TYPE_ARMOR] = {
            [EQUIP_TYPE_CHEST]      = 0, --
            [EQUIP_TYPE_FEET]       = -1, --
            [EQUIP_TYPE_HAND]       = -2, --
            [EQUIP_TYPE_HEAD]       = -3, --
            [EQUIP_TYPE_LEGS]       = -4, --
            [EQUIP_TYPE_SHOULDERS]  = -5, --
            [EQUIP_TYPE_WAIST]      = -6, --
        },
    },
    [CRAFTING_TYPE_WOODWORKING] = {
        --Weapons
        [SMITHING_FILTER_TYPE_WEAPONS] = {
            --2hd bow
            [WEAPONTYPE_BOW]                = 0,
            --2hd staffs
            [WEAPONTYPE_FIRE_STAFF]         = -1,
            [WEAPONTYPE_FROST_STAFF]        = -2,
            [WEAPONTYPE_LIGHTNING_STAFF]    = -3,
            [WEAPONTYPE_HEALING_STAFF]      = -4,
        },
        --Armor
        [SMITHING_FILTER_TYPE_ARMOR] = {
            --Shield
            [EQUIP_TYPE_OFF_HAND] =         0,
        }
    },
    [CRAFTING_TYPE_CLOTHIER] = {
        [SMITHING_FILTER_TYPE_ARMOR] = {
            [EQUIP_TYPE_CHEST]      = 0, --
            [EQUIP_TYPE_FEET]       = -1, --
            [EQUIP_TYPE_HAND]       = -2, --
            [EQUIP_TYPE_HEAD]       = -3, --
            [EQUIP_TYPE_LEGS]       = -4, --
            [EQUIP_TYPE_SHOULDERS]  = -5, --
            [EQUIP_TYPE_WAIST]      = -6, --
            [EQUIP_TYPE_CHEST]      = -7, --
            [EQUIP_TYPE_FEET]       = -8, --
            [EQUIP_TYPE_HAND]       = -9, --
            [EQUIP_TYPE_HEAD]       = -10, --
            [EQUIP_TYPE_LEGS]       = -11, --
            [EQUIP_TYPE_SHOULDERS]  = -12, --
            [EQUIP_TYPE_WAIST]      = -13, --
        }
    },
    [CRAFTING_TYPE_JEWELRYCRAFTING] = {
        [SMITHING_FILTER_TYPE_JEWELRY] = {
            [EQUIP_TYPE_NECK]       = 0,
            [EQUIP_TYPE_RING]       = -1,
        }
    },
}
AF.researchLineListIndicesOfWeaponOrArmorOrJewelryTypes = researchLineListIndicesOfWeaponOrArmorOrJewelryTypes

--The possible research lines and their item filter types
local blacksmithResearchLines = {
    --Weapons
    [1]=WEAPONTYPE_AXE, --
    [2]=WEAPONTYPE_HAMMER, --
    [3]=WEAPONTYPE_SWORD, --
    [4]=WEAPONTYPE_TWO_HANDED_AXE, --
    [5]=WEAPONTYPE_TWO_HANDED_HAMMER, --
    [6]=WEAPONTYPE_TWO_HANDED_SWORD, --
    [7]=WEAPONTYPE_DAGGER, --
    --Armor
    [8]=EQUIP_TYPE_CHEST, --
    [9]=EQUIP_TYPE_FEET, --
    [10]=EQUIP_TYPE_HAND, --
    [11]=EQUIP_TYPE_HEAD, --
    [12]=EQUIP_TYPE_LEGS, --
    [13]=EQUIP_TYPE_SHOULDERS, --
    [14]=EQUIP_TYPE_WAIST, --
}
local blacksmithResearchLinesArmorType = {
    --Armor
    [8]=ARMORTYPE_HEAVY, --
    [9]=ARMORTYPE_HEAVY, --
    [10]=ARMORTYPE_HEAVY, --
    [11]=ARMORTYPE_HEAVY, --
    [12]=ARMORTYPE_HEAVY, --
    [13]=ARMORTYPE_HEAVY, --
    [14]=ARMORTYPE_HEAVY, --
}
local clothierResearchLines = {
    --Light armor
    [1]=EQUIP_TYPE_CHEST, --
    [2]=EQUIP_TYPE_FEET, --
    [3]=EQUIP_TYPE_HAND, --
    [4]=EQUIP_TYPE_HEAD, --
    [5]=EQUIP_TYPE_LEGS, --
    [6]=EQUIP_TYPE_SHOULDERS, --
    [7]=EQUIP_TYPE_WAIST, --
    --Medium armor
    [8]=EQUIP_TYPE_CHEST, --
    [9]=EQUIP_TYPE_FEET, --
    [10]=EQUIP_TYPE_HAND, --
    [11]=EQUIP_TYPE_HEAD, --
    [12]=EQUIP_TYPE_LEGS, --
    [13]=EQUIP_TYPE_SHOULDERS, --
    [14]=EQUIP_TYPE_WAIST, --
}
local clothierResearchLinesArmorTypes = {
    --Light Armor
    [1]=ARMORTYPE_LIGHT, --
    [2]=ARMORTYPE_LIGHT, --
    [3]=ARMORTYPE_LIGHT, --
    [4]=ARMORTYPE_LIGHT, --
    [5]=ARMORTYPE_LIGHT, --
    [6]=ARMORTYPE_LIGHT, --
    [7]=ARMORTYPE_LIGHT, --
    --Medium armor
    [8]=ARMORTYPE_MEDIUM, --
    [9]=ARMORTYPE_MEDIUM, --
    [10]=ARMORTYPE_MEDIUM, --
    [11]=ARMORTYPE_MEDIUM, --
    [12]=ARMORTYPE_MEDIUM, --
    [13]=ARMORTYPE_MEDIUM, --
    [14]=ARMORTYPE_MEDIUM, --
}
local woodworkingResearchLines = {
    --Weapons
    [1]=WEAPONTYPE_BOW,             -- Bow
    [2]=WEAPONTYPE_FIRE_STAFF,      -- Fire staff
    [3]=WEAPONTYPE_FROST_STAFF,     -- Ice staff
    [4]=WEAPONTYPE_LIGHTNING_STAFF, -- Lightning staff
    [5]=WEAPONTYPE_HEALING_STAFF,   -- Heal staff
    --Armor
    [6]=EQUIP_TYPE_OFF_HAND,        -- Shield
}
local woodworkingResearchLinesArmorType = {
    --Armor
    [6]=ARMORTYPE_NONE,             -- Shield
}
local jewelryCraftingResearchLines = {
    --Neck
    [1] = EQUIP_TYPE_NECK,
    --Ring
    [2] = EQUIP_TYPE_RING,
}
AF.researchLinesToFilterTypes = {}
AF.researchLinesToFilterTypes[CRAFTING_TYPE_BLACKSMITHING]  = blacksmithResearchLines
AF.researchLinesToFilterTypes[CRAFTING_TYPE_CLOTHIER]       = clothierResearchLines
AF.researchLinesToFilterTypes[CRAFTING_TYPE_WOODWORKING]    = woodworkingResearchLines
AF.researchLinesToFilterTypes[CRAFTING_TYPE_JEWELRYCRAFTING]= jewelryCraftingResearchLines
AF.researchLinesToArmorType = {}
AF.researchLinesToArmorType[CRAFTING_TYPE_BLACKSMITHING]    = blacksmithResearchLinesArmorType
AF.researchLinesToArmorType[CRAFTING_TYPE_CLOTHIER]         = clothierResearchLinesArmorTypes
AF.researchLinesToArmorType[CRAFTING_TYPE_WOODWORKING]      = woodworkingResearchLinesArmorType

--ITEM IDs
local itemIds = {
    lockpick    = {
        30357--normal lockpick
    },
    repairtools = {
        44874, --Smallest repair kit
        44875, --Smaller repair kit
        44876, --Lower repair kit
        44877, --Common repair kit
        44878, --Greater repair kit
        44879, --Big repair kit
        157516 --GroupRepair of the Impressaria event
    }
}
AF.itemIds = itemIds

--Table where external dropdown filter plugins can register themselves for checks done by other addos
AF.externalDropdownFilterPlugins = {}

--Mapping for the older ITEMFILTERTYPE_* variables to the new ZOs API100033 ITEM_TYPE_DISPLAY_CATEGORY
--https://github.com/esoui/esoui/blob/pts6.2/esoui/ingame/inventory/itemfilterutils.lua#L692
--ZO_ItemFilterUtils.GetItemTypeDisplayCategoryByItemFilterType(itemFilterType)
-->ITEM_FILTER_UTILS:GetItemTypeDisplayCategoryByItemFilterType(itemFilterType)
--[[
AF.itemDisplayCategoryToItemFilterType = {
    --Normal Inventory
    [ITEM_TYPE_DISPLAY_CATEGORY_ALL]            = ITEMFILTERTYPE_ALL,
    [ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS]        = ITEMFILTERTYPE_WEAPONS,
    [ITEM_TYPE_DISPLAY_CATEGORY_ARMOR]          = ITEMFILTERTYPE_ARMOR,
    [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY]        = ITEMFILTERTYPE_JEWELRY,
    [ITEM_TYPE_DISPLAY_CATEGORY_CONSUMABLE]     = ITEMFILTERTYPE_CONSUMABLE,
    [ITEM_TYPE_DISPLAY_CATEGORY_CRAFTING]       = ITEMFILTERTYPE_CRAFTING,
    [ITEM_TYPE_DISPLAY_CATEGORY_FURNISHING]     = ITEMFILTERTYPE_FURNISHING,
    [ITEM_TYPE_DISPLAY_CATEGORY_MISCELLANEOUS]  = ITEMFILTERTYPE_MISCELLANEOUS,
    [ITEM_TYPE_DISPLAY_CATEGORY_QUEST]          = ITEMFILTERTYPE_QUEST,
    [ITEM_TYPE_DISPLAY_CATEGORY_JUNK]           = ITEMFILTERTYPE_JUNK,
    --CraftBag
    [ITEM_TYPE_DISPLAY_CATEGORY_BLACKSMITHING]  = ITEMFILTERTYPE_BLACKSMITHING,
    [ITEM_TYPE_DISPLAY_CATEGORY_CLOTHING]       = ITEMFILTERTYPE_CLOTHING,
    [ITEM_TYPE_DISPLAY_CATEGORY_WOODWORKING]    = ITEMFILTERTYPE_WOODWORKING,
    [ITEM_TYPE_DISPLAY_CATEGORY_ALCHEMY]        = ITEMFILTERTYPE_ALCHEMY,
    [ITEM_TYPE_DISPLAY_CATEGORY_ENCHANTING]     = ITEMFILTERTYPE_ENCHANTING,
    [ITEM_TYPE_DISPLAY_CATEGORY_PROVISIONING]   = ITEMFILTERTYPE_PROVISIONING,
    [ITEM_TYPE_DISPLAY_CATEGORY_JEWELRYCRAFTING]= ITEMFILTERTYPE_JEWELRYCRAFTING,
    [ITEM_TYPE_DISPLAY_CATEGORY_STYLE_MATERIAL] = ITEMFILTERTYPE_STYLE_MATERIALS,
    [ITEM_TYPE_DISPLAY_CATEGORY_TRAIT_ITEM]     = ITEMFILTERTYPE_TRAIT_ITEMS,
}
]]
