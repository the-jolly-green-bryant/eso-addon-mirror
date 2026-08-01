------------------------------------------------------------------
------------------------------------------------------------------
--FCOCraftFilter.lua
--Author: Baertram
--[[
Filter your crafting station items
]]
FCOCF = {}
FCOCraftFilter = FCOCF
local FCOCF = FCOCF

local CM = CALLBACK_MANAGER
local EM = EVENT_MANAGER

--Libraries (See EVENT_ADD_ON_LOADED)
local libFilters
local libFilters_GetCtrl
local libFilters_IsUniversalDeconstructionSupportedFilterType
local libFilters_IsUniversalDeconstructionPanelShown
local libFilters_getUniversalDeconstructionPanelActiveTabFilterType

local isPerfectPixelEnabled = PP and PP.ADDON_NAME ~= nil

local tos = tostring

--local APIVersion = GetAPIVersion()

--Constants
FCOCF_SHOW_ALL              =  1
FCOCF_ONLY_SHOW_INVENTORY   =  2
FCOCF_ONLY_SHOW_BANKED      =  3
FCOCF_ONLY_SHOW_CRAFTBAG    =  4
FCOCF_ONLY_SHOW_WORN        =  5
FCOCF_DO_NOT_SHOW_CRAFTBAG  = -4

FCOCF_CRAFTINGTYPE_UNIVERSAL_DECONSTRUCTION = "UniversalDeconstruction"

--Addon variables
FCOCF.addonVars = {}
FCOCF.addonVars.gAddonName					= "FCOCraftFilter"
FCOCF.addonVars.addonNameMenu				= "FCO CraftFilter"
FCOCF.addonVars.addonNameMenuDisplay		= "|c00FF00FCO |cFFFF00CraftFilter|r"
FCOCF.addonVars.addonAuthor 				= '|cFFFF00Baertram|r'
FCOCF.addonVars.addonVersion		   		= 0.51 -- Changing this will reset SavedVariables!
FCOCF.addonVars.addonVersionOptions 		= '0.6.9' -- version shown in the settings panel
FCOCF.addonVars.addonVersionOptionsNumber 	= tonumber(FCOCF.addonVars.addonVersionOptions)
FCOCF.addonVars.addonSavedVariablesName		= "FCOCraftFilter_Settings"
FCOCF.addonVars.addonWebsite                = "http://www.esoui.com/downloads/info1104-FCOCraftFilter.html"
FCOCF.addonVars.gAddonLoaded				= false
local addonName = FCOCF.addonVars.gAddonName

--Available languages
FCOCF.numVars = {}
FCOCF.numVars.languageCount = 7 --English, German, French, Spanish, Italian, Japanese, Russian
FCOCF.langVars = {}
FCOCF.langVars.languages = {}
--Build the languages array
for i=1, FCOCF.numVars.languageCount do
	FCOCF.langVars.languages[i] = true
end

--Array for all the variables
FCOCF.locVars = {}
--The last opened panel ID
FCOCF.locVars.gLastPanel        = nil
--The last opened crafting station type
FCOCF.locVars.gLastCraftingType = nil

--Uncolored "FCOCF" pre chat text for the chat output
FCOCF.locVars.preChatText = FCOCF.addonVars.addonNameMenu
--Green colored "FCOCF" pre text for the chat output
FCOCF.locVars.preChatTextGreen = "|c22DD22"..FCOCF.locVars.preChatText.."|r "
--Red colored "FCOCF" pre text for the chat output
FCOCF.locVars.preChatTextRed = "|cDD2222"..FCOCF.locVars.preChatText.."|r "
--Blue colored "FCOCF" pre text for the chat output
FCOCF.locVars.preChatTextBlue = "|c2222DD"..FCOCF.locVars.preChatText.."|r "

FCOCF.filterButtons = {}
FCOCF.horizontalScrollListFilterButtons = {}

--Control names of ZO* standard controls etc.
FCOCF.zoVars = {}
local zoVars = FCOCF.zoVars
--Smithing
zoVars.CRAFTSTATION_SMITHING                                    = ZO_Smithing
local zo_smith = zoVars.CRAFTSTATION_SMITHING
zoVars.CRAFTSTATION_SMITHING_VAR                                = SMITHING
local smith     = zoVars.CRAFTSTATION_SMITHING_VAR
--Creation
zoVars.CRAFTSTATION_SMITHING_CREATION_MASTERCRAFTER_SET_LIST    = ZO_SmithingTopLevelSetContainerCategoriesScrollChild --SMITHING.categoryTree
zoVars.CRAFTSTATION_SMITHING_CREATION_MASTERCRAFTER_SET_CONTAINER = ZO_SmithingTopLevelSetContainer
--if ZO_Smithing_IsConsolidatedStationCraftingMode() then
--ZO_Smithing:InitializeSetCategories() -> Type of category: ZO_StatusIconHeader
--
--ZO_Smithing:RefreshSetCategories() ->
-->ZO_Smithing:AddSetCategory(categoryData, filters)
--[[
--This is a special pseudo-category that represents the "No Item Set" option
local DEFAULT_CATEGORY_ID = 0
CONSOLIDATED_SMITHING_DEFAULT_CATEGORY_DATA = ZO_ConsolidatedSmithingDefaultCategoryData:New(DEFAULT_CATEGORY_ID)

--Add the special default category first
self:AddSetCategory(CONSOLIDATED_SMITHING_DEFAULT_CATEGORY_DATA)
]]

--Deconstruction
zoVars.CRAFTSTATION_SMITHING_REFINEMENT_INVENTORY               = ZO_SmithingTopLevelRefinementPanelInventory
zoVars.CRAFTSTATION_SMITHING_REFINEMENT_TABS                    = ZO_SmithingTopLevelRefinementPanelInventoryTabs
zoVars.CRAFTSTATION_SMITHING_DECONSTRUCTION_INVENTORY           = ZO_SmithingTopLevelDeconstructionPanelInventory
zoVars.CRAFTSTATION_SMITHING_DECONSTRUCTION_TABS                = ZO_SmithingTopLevelDeconstructionPanelInventoryTabs

--Improvement
zoVars.CRAFTSTATION_SMITHING_IMPROVEMENT_INVENTORY              = ZO_SmithingTopLevelImprovementPanelInventory
zoVars.CRAFTSTATION_SMITHING_IMPROVEMENT_TABS                   = ZO_SmithingTopLevelImprovementPanelInventoryTabs

--Research
zoVars.CRAFTSTATION_SMITHING_RESEARCH                           = ZO_SmithingTopLevelResearchPanel
zoVars.CRAFTSTATION_SMITHING_RESEARCH_TABS                      = ZO_SmithingTopLevelResearchPanelTabs
zoVars.CRAFTSTATION_SMITHING_RESEARCH_TIMER_ICON                = ZO_SmithingTopLevelResearchPanelTimerIcon
zoVars.CRAFTSTATION_SMITHING_RESEARCH_NUM_RESEARCH_LABEL        = ZO_SmithingTopLevelResearchPanelNumResearching

--Research dialog
zoVars.RESEARCH    				                              = zoVars.CRAFTSTATION_SMITHING_RESEARCH
zoVars.RESEARCH_POPUP_TOP_DIVIDER                               = ZO_ListDialog1Divider
zoVars.LIST_DIALOG 	    		                              = ZO_ListDialog1
zoVars.LIST_DIALOG_LIST 	    		                          = ZO_ListDialog1List

--Enchanting
zoVars.CRAFTSTATION_ENCHANTING	                              = ZO_Enchanting
local zo_ench      = zoVars.CRAFTSTATION_ENCHANTING
zoVars.CRAFTSTATION_ENCHANTING_VAR                              = ENCHANTING
local ench      = zoVars.CRAFTSTATION_ENCHANTING_VAR
zoVars.CRAFTSTATION_ENCHANTING_INVENTORY                        = ZO_EnchantingTopLevelInventory
zoVars.CRAFTSTATION_ENCHANTING_TABS                             = ZO_EnchantingTopLevelInventoryTabs

--Alchemy
--zoVars.CRAFTSTATION_ALCHEMY	                                    = ZO_Alchemy
--local zo_alch      = zoVars.CRAFTSTATION_ALCHEMY
zoVars.CRAFTSTATION_ALCHEMY_VAR                              = ALCHEMY
local alch      = zoVars.CRAFTSTATION_ALCHEMY_VAR

--Provisioning
--zoVars.CRAFTSTATION_PROVISIONING                           = ZO_Provisioner
--local zo_prov     = zoVars.CRAFTSTATION_PROVISIONING
zoVars.CRAFTSTATION_PROVISIONING_VAR                              = PROVISIONER
local prov      = zoVars.CRAFTSTATION_PROVISIONING_VAR

--Transmutation
--Transmutation / Retrait
--Markarth or newer
zoVars.TRANSMUTATIONSTATION                                       = ZO_RETRAIT_KEYBOARD
local retrait   = zoVars.TRANSMUTATIONSTATION
zoVars.TRANSMUTATIONSTATION_RETRAIT_PANEL                         = retrait
zoVars.TRANSMUTATIONSTATION_CONTROL                               = retrait.control
zoVars.TRANSMUTATIONSTATION_INVENTORY                             = ZO_RetraitStation_KeyboardTopLevelRetraitPanelInventory
zoVars.TRANSMUTATIONSTATION_TABS                                  = ZO_RetraitStation_KeyboardTopLevelRetraitPanelInventoryTabs
zoVars.RETRAITSTATION = ZO_RETRAIT_STATION_KEYBOARD
local retraitStation     = zoVars.RETRAITSTATION
local retraitStationTabs = retraitStation.tabs

--Include banked items checkbox
zoVars.INVENTORY_NAME                                             = "Inventory"
zoVars.INCLUDE_BANKED_CHECKBOX_NAME                               = "IncludeBanked"
zoVars.QUEST_ITEMS_ONLY_CHECKBOX_NAME                             = "QuestItemsOnly"

--Universal Deconstruction
zoVars.universalDeconScene                                        = UNIVERSAL_DECONSTRUCTION_KEYBOARD_SCENE
zoVars.universalDecon                                             = UNIVERSAL_DECONSTRUCTION
local universalDecon = zoVars.universalDecon
zoVars.universalDeconPanel                                        = universalDecon.deconstructionPanel
local universalDeconPanel = zoVars.universalDeconPanel
zoVars.universalDeconPanelInv                                     = universalDeconPanel.inventory
local universalDeconPanelInv = zoVars.universalDeconPanelInv
zoVars.universalDeconPanelInvControl                              = universalDeconPanelInv.control
local universalDeconPanelInvControl = zoVars.universalDeconPanelInvControl
zoVars.universalDeconInvTabs                                      = GetControl(zoVars.universalDeconPanelInvControl, "Tabs") --ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryTabs
local universalDeconInvTabs = zoVars.universalDeconInvTabs

--LibFilters filterTypes where the BAG_WORN should also show items in the results list for "SHOW INVENTORY" FCOCraftFilter
local isWornBagFilterTypeAndShouldShowWithInventory = {
    [LF_RETRAIT] =              true,
    [LF_SMITHING_IMPROVEMENT] = true,
    [LF_JEWELRY_IMPROVEMENT] =  true,
}


local controlsForChecks = {
    --Keyboard variables
    smithing                = SMITHING,
    enchanting              = ENCHANTING,
    retrait                 = ZO_RETRAIT_STATION_KEYBOARD,
    universalDeconstruction = zoVars.universalDecon,
}
controlsForChecks.researchPanel         =   controlsForChecks.smithing.researchPanel
controlsForChecks.researchLineList      =   controlsForChecks.researchPanel.researchLineList
FCOCF.controlsForChecks = controlsForChecks

--[[
--Smithing
controlsForChecks.refinementPanel       =   controlsForChecks.smithing.refinementPanel
controlsForChecks.creationPanel         =   controlsForChecks.smithing.creationPanel
controlsForChecks.deconstructionPanel   =   controlsForChecks.smithing.deconstructionPanel
controlsForChecks.improvementPanel      =   controlsForChecks.smithing.improvementPanel
controlsForChecks.researchPanel         =   controlsForChecks.smithing.researchPanel
--Enchanting
controlsForChecks.enchantCreatePanel    =   controlsForChecks.enchanting
controlsForChecks.enchantExtractPanel   =   controlsForChecks.enchanting
--Retrait
controlsForChecks.retraitPanel          =   controlsForChecks.retrait.retraitPanel
]]
local deconPanel =      controlsForChecks.smithing.deconstructionPanel
local researchPanel =   controlsForChecks.smithing.researchPanel
--local universalDeconPanel = controlsForChecks.universalDeconstruction.deconstructionPanel
FCOCF.controlsForChecks = controlsForChecks

--The mapping between LibFilters3 panelid and the panel holding the inventory
local craftingTablePanels = {}

--SavedVariables at deconstruction and research panel: Include banked items checkbox of vabilla UI
local svName =                      "savedVars"
local includeBankedItemsChecked =   "includeBankedItemsChecked"
local craftingTableSVs = {
    [LF_SMITHING_DECONSTRUCT]   = { svVar = deconPanel,     svName = svName,   includeBanked = includeBankedItemsChecked },
    [LF_JEWELRY_DECONSTRUCT]    = { svVar = deconPanel,     svName = svName,   includeBanked = includeBankedItemsChecked },
    [LF_SMITHING_RESEARCH]      = { svVar = researchPanel,  svName = svName,   includeBanked = includeBankedItemsChecked },
    [LF_JEWELRY_RESEARCH]       = { svVar = researchPanel,  svName = svName,   includeBanked = includeBankedItemsChecked },
    [FCOCF_CRAFTINGTYPE_UNIVERSAL_DECONSTRUCTION] =  { svVar = universalDeconPanel,  svName = svName,   includeBanked = includeBankedItemsChecked },
}
FCOCF.craftingTableSVs = craftingTableSVs

local blacksmithRecipeDescriptor = _G["SI_RECIPECRAFTINGSYSTEM" .. GetTradeskillRecipeCraftingSystem(CRAFTING_TYPE_BLACKSMITHING)]
local clothierRecipeDescriptor = _G["SI_RECIPECRAFTINGSYSTEM" .. GetTradeskillRecipeCraftingSystem(CRAFTING_TYPE_CLOTHIER)]
local enchantingRecipeDescriptor = _G["SI_RECIPECRAFTINGSYSTEM" .. GetTradeskillRecipeCraftingSystem(CRAFTING_TYPE_ENCHANTING)]
local alchemyRecipeDescriptor = _G["SI_RECIPECRAFTINGSYSTEM" .. GetTradeskillRecipeCraftingSystem(CRAFTING_TYPE_ALCHEMY)]
local proivisioningRecipeDescriptor = _G["SI_RECIPECRAFTINGSYSTEM" .. GetTradeskillRecipeCraftingSystem(CRAFTING_TYPE_PROVISIONING)]
local woodworkingRecipeDescriptor = _G["SI_RECIPECRAFTINGSYSTEM" .. GetTradeskillRecipeCraftingSystem(CRAFTING_TYPE_WOODWORKING)]
local jewelryRecipeDescriptor = _G["SI_RECIPECRAFTINGSYSTEM" .. GetTradeskillRecipeCraftingSystem(CRAFTING_TYPE_JEWELRYCRAFTING)]

--local smithingCraftingTabEntries = {GetString(SI_SMITHING_TAB_REFINEMENT), GetString(SI_SMITHING_TAB_CREATION), GetString(SI_SMITHING_TAB_DECONSTRUCTION), GetString(SI_SMITHING_TAB_IMPROVEMENT), GetString(SI_SMITHING_TAB_RESEARCH), GetString(SI_ITEMTYPE29)}
local smithingCraftingTabEntriesValues = {-1, SMITHING_MODE_REFINEMENT, SMITHING_MODE_CREATION, SMITHING_MODE_DECONSTRUCTION, SMITHING_MODE_IMPROVEMENT, SMITHING_MODE_RESEARCH, SMITHING_MODE_RECIPES}
local possibleCraftingTypeTabDropdownEntries       = {
    [CRAFTING_TYPE_ALCHEMY] =           {GetString(SI_CHECK_BUTTON_DISABLED), GetString(SI_ALCHEMY_CREATION), GetString(alchemyRecipeDescriptor)},
    [CRAFTING_TYPE_BLACKSMITHING] =     {GetString(SI_CHECK_BUTTON_DISABLED), GetString(SI_SMITHING_TAB_REFINEMENT), GetString(SI_SMITHING_TAB_CREATION), GetString(SI_SMITHING_TAB_DECONSTRUCTION), GetString(SI_SMITHING_TAB_IMPROVEMENT), GetString(SI_SMITHING_TAB_RESEARCH), GetString(blacksmithRecipeDescriptor)},
    [CRAFTING_TYPE_CLOTHIER] =          {GetString(SI_CHECK_BUTTON_DISABLED), GetString(SI_SMITHING_TAB_REFINEMENT), GetString(SI_SMITHING_TAB_CREATION), GetString(SI_SMITHING_TAB_DECONSTRUCTION), GetString(SI_SMITHING_TAB_IMPROVEMENT), GetString(SI_SMITHING_TAB_RESEARCH), GetString(clothierRecipeDescriptor)},
    [CRAFTING_TYPE_ENCHANTING] =        {GetString(SI_CHECK_BUTTON_DISABLED), GetString(SI_ENCHANTING_CREATION), GetString(SI_ENCHANTING_EXTRACTION), GetString(enchantingRecipeDescriptor)},
    [CRAFTING_TYPE_JEWELRYCRAFTING] =   {GetString(SI_CHECK_BUTTON_DISABLED), GetString(SI_SMITHING_TAB_REFINEMENT), GetString(SI_SMITHING_TAB_CREATION), GetString(SI_SMITHING_TAB_DECONSTRUCTION), GetString(SI_SMITHING_TAB_IMPROVEMENT), GetString(SI_SMITHING_TAB_RESEARCH), GetString(jewelryRecipeDescriptor)},
    [CRAFTING_TYPE_PROVISIONING] =      {GetString(SI_CHECK_BUTTON_DISABLED), GetString("SI_PROVISIONERSPECIALINGREDIENTTYPE", PROVISIONER_SPECIAL_INGREDIENT_TYPE_FILLET), GetString("SI_PROVISIONERSPECIALINGREDIENTTYPE", PROVISIONER_SPECIAL_INGREDIENT_TYPE_SPICES), GetString("SI_PROVISIONERSPECIALINGREDIENTTYPE", PROVISIONER_SPECIAL_INGREDIENT_TYPE_FLAVORING), GetString(proivisioningRecipeDescriptor)}, --GetString("SI_PROVISIONERSPECIALINGREDIENTTYPE", PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING)},
    [CRAFTING_TYPE_WOODWORKING] =       {GetString(SI_CHECK_BUTTON_DISABLED), GetString(SI_SMITHING_TAB_REFINEMENT), GetString(SI_SMITHING_TAB_CREATION), GetString(SI_SMITHING_TAB_DECONSTRUCTION), GetString(SI_SMITHING_TAB_IMPROVEMENT), GetString(SI_SMITHING_TAB_RESEARCH), GetString(woodworkingRecipeDescriptor)},
    ["retrait"]                 =       {GetString(SI_CHECK_BUTTON_DISABLED), GetString(SI_RETRAIT_STATION_RETRAIT_MODE), GetString(SI_RETRAIT_STATION_RECONSTRUCT_MODE)},
    ["universalDeconstruction"] =       {GetString(SI_CHECK_BUTTON_DISABLED)}
}
local possibleCraftingTypeTabDropdownEntriesValues = {
    [CRAFTING_TYPE_ALCHEMY] =           {-1, ZO_ALCHEMY_MODE_CREATION, ZO_ALCHEMY_MODE_RECIPES},
    [CRAFTING_TYPE_BLACKSMITHING] =     smithingCraftingTabEntriesValues,
    [CRAFTING_TYPE_CLOTHIER] =          smithingCraftingTabEntriesValues,
    [CRAFTING_TYPE_ENCHANTING] =        {-1, ENCHANTING_MODE_CREATION, ENCHANTING_MODE_EXTRACTION, ENCHANTING_MODE_RECIPES},
    [CRAFTING_TYPE_JEWELRYCRAFTING] =   smithingCraftingTabEntriesValues,
    [CRAFTING_TYPE_PROVISIONING] =      {-1, PROVISIONER_SPECIAL_INGREDIENT_TYPE_FILLET, PROVISIONER_SPECIAL_INGREDIENT_TYPE_SPICES, PROVISIONER_SPECIAL_INGREDIENT_TYPE_FLAVORING, PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING},
    [CRAFTING_TYPE_WOODWORKING] =       smithingCraftingTabEntriesValues,
    ["retrait"]                 =       {-1, "retraitTab", "reconstructTab"},--{ZO_RETRAIT_MODE_RETRAIT, ZO_RETRAIT_MODE_RECONSTRUCT},
    ["universalDeconstruction"] =       {-1}
}
FCOCF.possibleCraftingTypeTabDropdownEntries = possibleCraftingTypeTabDropdownEntries
FCOCF.possibleCraftingTypeTabDropdownEntriesValues = possibleCraftingTypeTabDropdownEntriesValues

local tabButtonBarsByCraftingType = {
    [CRAFTING_TYPE_ALCHEMY] =           alch.modeBar,
    [CRAFTING_TYPE_BLACKSMITHING] =     smith.modeBar,
    [CRAFTING_TYPE_CLOTHIER] =          smith.modeBar,
    [CRAFTING_TYPE_ENCHANTING] =        ench.modeBar,
    [CRAFTING_TYPE_JEWELRYCRAFTING] =   smith.modeBar,
    [CRAFTING_TYPE_PROVISIONING] =      prov.tabs,
    [CRAFTING_TYPE_WOODWORKING] =       smith.modeBar,
    ["retrait"] =                       retraitStationTabs,
    ["universalDeconstruction"] =       universalDeconPanelInv.tabs
}
FCOCF.tabButtonBarsByCraftingType = tabButtonBarsByCraftingType

local universalDeconKeys = {
    "all",
    "weapons",
    "armor",
    "jewelry",
    "enchantments",
}
for _, unversalDeconKey in ipairs(universalDeconKeys) do
    local dataOfKey = ZO_GetUniversalDeconstructionFilterType(unversalDeconKey)
    table.insert(possibleCraftingTypeTabDropdownEntries["universalDeconstruction"], dataOfKey.displayName)
    table.insert(possibleCraftingTypeTabDropdownEntriesValues["universalDeconstruction"], unversalDeconKey) --dataOfKey.filter cannot be used as those are whole tables, used as descriptor!
end



local libFilters_GetFilterTypeReferences
local function getCraftingPanelControlByFilterType(filterType, isUniversalDecon)
    libFilters_GetFilterTypeReferences = libFilters_GetFilterTypeReferences or libFilters.GetFilterTypeReferences
    libFilters_IsUniversalDeconstructionSupportedFilterType = libFilters_IsUniversalDeconstructionSupportedFilterType or libFilters.IsUniversalDeconstructionSupportedFilterType
    isUniversalDecon = isUniversalDecon or false
    local lReferencesToFilterType, universalDeconRef = libFilters_GetFilterTypeReferences(libFilters, filterType, false) --only keaybord mode supported!
----d("[FCOCF]getCraftingPanelControlByFilterType-filterType: " ..tos(filterType).. ", isUniversalDecon: " ..tos(isUniversalDecon))

    --local lReferencesToFilterType, lFilterTypeDetected, universalDeconSelectedTabKey = libFilters:GetCurrentFilterTypeReference(filterType, nil)
	local craftingTablePanelControl
    if isUniversalDecon == true and libFilters_IsUniversalDeconstructionSupportedFilterType(filterType) == true and universalDeconRef ~= nil then
        craftingTablePanelControl = universalDeconRef
----d(">universalDecon: found")
    else
        if lReferencesToFilterType ~= nil and #lReferencesToFilterType > 0 then
----d(">other found")
            --Get the first reference control and use it as control for the filterType
            local refOne = lReferencesToFilterType[1]
            libFilters_GetCtrl = libFilters_GetCtrl or libFilters.GetCtrl
            craftingTablePanelControl = libFilters_GetCtrl(refOne)
        end
    end
    return craftingTablePanelControl
end

local function getCorrectCraftingFilterTypeReference(crafingFilterType, isUniversalDecon)
    return getCraftingPanelControlByFilterType(crafingFilterType, isUniversalDecon)
end
FCOCF.GetCorrectCraftingFilterTypeReference = getCorrectCraftingFilterTypeReference

local function getCurrentCraftingFilterTypeReference(crafingFilterType, isUniversalDecon)
    libFilters_IsUniversalDeconstructionSupportedFilterType = libFilters_IsUniversalDeconstructionSupportedFilterType or libFilters.IsUniversalDeconstructionSupportedFilterType
    if isUniversalDecon == true and libFilters_IsUniversalDeconstructionSupportedFilterType(crafingFilterType) == true then
        return universalDeconPanel
    else
        return craftingTablePanels[crafingFilterType]
    end
end
FCOCF.GetCurrentCraftingFilterTypeReference = getCurrentCraftingFilterTypeReference


--Settings / SavedVars
FCOCF.settingsVars			    = {}
FCOCF.settingsVars.settings       = {}
FCOCF.settingsVars.defaultSettings= {}
FCOCF.settingsVars.defaults = {}

--Preventer variables
FCOCF.preventerVars = {}
FCOCF.preventerVars.gLocalizationDone = false
FCOCF.preventerVars.gLockpickActive	= false
FCOCF.preventerVars.gOnLockpickChatState = false
FCOCF.preventerVars.ZO_ListDialog1ResearchIsOpen = false
FCOCF.preventerVars.wasCraftingTableWithoutCraftingTypeRecentlyOpened = false

--Localization
FCOCF.localizationVars = {}
FCOCF.localizationVars.FCOCF_loc = {}

--Textures
FCOCF.textures = {}
local textures = FCOCF.textures
local emptyIcon             = "/esoui/art/icons/heraldrycrests_misc_blank_01.dds"
local textureAll            = "/EsoUI/Art/Inventory/inventory_tabIcon_items_up.dds"
local textureOnlyInventory  = "/esoui/art/mainmenu/menubar_inventory_up.dds"
local textureOnlyBank       = "/esoui/art/icons/servicemappins/servicepin_bank.dds"
local textureOnlyCraftBag   = "/esoui/art/inventory/inventory_tabicon_craftbag_down.dds"
local textureNoCraftBag     = "/esoui/art/hud/gamepad/gp_loothistory_icon_craftbag.dds"
local textureCurrentlyResearchedDown = "/esoui/art/crafting/smithing_tabicon_research_disabled.dds"
local textureCurrentlyResearched = "/esoui/art/tutorial/smithing_tabicon_research_up.dds"
local textureOnlyWorn       = "EsoUI/Art/WritAdvisor/advisor_tabIcon_equip_up.dds"
local savedInCategoryTexture = "/esoui/art/miscellaneous/check.dds"
--local notSavedInCategoryTexture = "/esoui/art/mainmenu/menubar_inventory_up.dds"
local favoriteIcon          = "EsoUI/Art/Collections/Favorite_StarOnly.dds"
local favIconStr = zo_iconFormat(favoriteIcon, 24, 24)
textures.emptyIcon = emptyIcon
textures.textureAll = textureAll
textures.textureOnlyInventory = textureOnlyInventory
textures.textureOnlyBank = textureOnlyBank
textures.textureOnlyCraftBag = textureOnlyCraftBag
textures.textureNoCraftBag = textureNoCraftBag
textures.textureCurrentlyResearchedDown = textureCurrentlyResearchedDown
textures.textureCurrentlyResearched = textureCurrentlyResearched
textures.textureOnlyWorn = textureOnlyWorn
textures.favoriteIcon = favoriteIcon
textures.favIconStr = favIconStr
textures.savedInCategoryTexture = savedInCategoryTexture
textures.notSavedInCategoryTexture = notSavedInCategoryTexture


--MasterCrafter tables - New data favorite category ID
local FAVORITES_TANK_CATEGORY_ID = 99001
local FAVORITES_STAM_HEAL_CATEGORY_ID = 99002
local FAVORITES_MAG_HEAL_CATEGORY_ID = 99003
local FAVORITES_STAM_DD_CATEGORY_ID = 99004
local FAVORITES_MAG_DD_CATEGORY_ID = 99005
local FAVORITES_HYBRID_DD_CATEGORY_ID = 99006
FCOCF.FAVORITES_TANK_CATEGORY_ID = FAVORITES_TANK_CATEGORY_ID
FCOCF.FAVORITES_STAM_HEAL_CATEGORY_ID = FAVORITES_STAM_HEAL_CATEGORY_ID
FCOCF.FAVORITES_MAG_HEAL_CATEGORY_ID = FAVORITES_MAG_HEAL_CATEGORY_ID
FCOCF.FAVORITES_STAM_DD_CATEGORY_ID = FAVORITES_STAM_DD_CATEGORY_ID
FCOCF.FAVORITES_MAG_DD_CATEGORY_ID = FAVORITES_MAG_DD_CATEGORY_ID
FCOCF.FAVORITES_HYBRID_DD_CATEGORY_ID = FAVORITES_HYBRID_DD_CATEGORY_ID

local customMasterCrafterSetStationFavoriteIds = {
    [FAVORITES_TANK_CATEGORY_ID] = true,
    [FAVORITES_STAM_HEAL_CATEGORY_ID] = true,
    [FAVORITES_MAG_HEAL_CATEGORY_ID] = true,
    [FAVORITES_STAM_DD_CATEGORY_ID] = true,
    [FAVORITES_MAG_DD_CATEGORY_ID] = true,
    [FAVORITES_HYBRID_DD_CATEGORY_ID] = true,
}
FCOCF.customMasterCrafterSetStationFavoriteIds = customMasterCrafterSetStationFavoriteIds

--===================== FUNCTIONS ==============================================

local function getCraftingTabButtonBar(craftingType)
    return tabButtonBarsByCraftingType[craftingType]
end

local function getUniversalDeconDescriptor(unversalDeconKey)
    return ZO_GetUniversalDeconstructionFilterType(unversalDeconKey).filter --the filter table is nil at the "all" tab!
end

local function setRetraitTabButtonTo(newRetraitTab)
    --d("[FCOCF]setRetraitTabButtonTo-newRetraitTab:" .. tos(newRetraitTab))
    if newRetraitTab == -1 then return end

    local tabButtonBar
    tabButtonBar = getCraftingTabButtonBar("retrait")
--d(">tabButtonBar: " .. tos(tabButtonBar))
    if tabButtonBar ~= nil and newRetraitTab ~= nil then
--d(">>Setting retrait tab to: " ..tos(newRetraitTab))
        tabButtonBar:SelectFragment(retraitStation[newRetraitTab].categoryName)
        return true
    end
    return false
end

local function setCraftingTabButtonTo(craftingTypeOrUniversalDeconKey, isUniversalDecon, descriptorOrNewUniversalDeconKey, currentUniversalDeconTab)
    isUniversalDecon = isUniversalDecon or false
    --d("[FCOCF]setCraftingTabButtonTo-craftSkill:" .. tos(craftingTypeOrUniversalDeconKey) .. ", isUniversalDecon: " ..tos(isUniversalDecon) .. ", newDescriptor: " .. tos(descriptorOrNewUniversalDeconKey))
    --Disabled at the crafting type? Do not changem use ESO default behavor
    if descriptorOrNewUniversalDeconKey == -1 then return end

    local newTabDescriptor, tabButtonBar
    if isUniversalDecon == true then
        --Get the current UniversalDecon selected tab
        local lFilterTypeDetected
        if currentUniversalDeconTab == nil then
            lFilterTypeDetected, currentUniversalDeconTab = libFilters.GetUniversalDeconstructionPanelActiveTabFilterType()
        elseif currentUniversalDeconTab.key ~= nil then
            currentUniversalDeconTab = currentUniversalDeconTab.key
        end
        --d(">currentUniversalDeconKey: " .. tos(currentUniversalDeconTab))
        --Change tab it, if needed
        if descriptorOrNewUniversalDeconKey == currentUniversalDeconTab then
            --d("<[ABORT]universalDecon tab already active!")
            return false
        end

        --Get the actual descriptor for the new tab, by the new key
        newTabDescriptor = getUniversalDeconDescriptor(descriptorOrNewUniversalDeconKey)
        tabButtonBar = getCraftingTabButtonBar("universalDeconstruction")
    else
        if craftingTypeOrUniversalDeconKey == nil then return end
        newTabDescriptor = descriptorOrNewUniversalDeconKey
        tabButtonBar = getCraftingTabButtonBar(craftingTypeOrUniversalDeconKey)
    end
    --d(">tabButtonBar: " .. tos(tabButtonBar) .. ", newTabDescriptor: " .. tos(newTabDescriptor))
    if tabButtonBar ~= nil and ((not isUniversalDecon and newTabDescriptor ~= nil) or isUniversalDecon) then
        --Get the currently selected descriptor
        if ZO_MenuBar_GetSelectedDescriptor(tabButtonBar) == newTabDescriptor then
            --d("<[ABORT]descriptor already active!")
            return false
        end
        --And change it, if it differs
        --d(">>Setting descriptor to: " ..tos(newTabDescriptor))
        ZO_MenuBar_SelectDescriptor(tabButtonBar, newTabDescriptor, true, false)
        return true
    end
    return false
end


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function getCurrentButtonStateAndTexture(isUniversalDecon, isResearchShowOnlyCurrentlyResearched)
    isUniversalDecon = isUniversalDecon or false
    isResearchShowOnlyCurrentlyResearched = isResearchShowOnlyCurrentlyResearched or false

    local currentTexture, currentTooltip
    --Are the settings to hide items from your bank enabled?
    local settings = FCOCF.settingsVars.settings
    local localizationVars = FCOCF.localizationVars.FCOCF_loc
    local locVars = FCOCF.locVars
    local lastCraftingType = locVars.gLastCraftingType --contains "UniversalDeconstruction" as crafting type if last was UniversalDecon panel
    local lastPanel= locVars.gLastPanel
    local isRefinementPanel = (lastPanel == LF_SMITHING_REFINE or lastPanel == LF_JEWELRY_REFINE) or false
    local filterApplied

--d("[FCOCF]getCurrentButtonStateAndTexture-isUniversalDecon: " .. tos(isUniversalDecon) ..", isResearchCurrently: " ..tos(isResearchShowOnlyCurrentlyResearched))

    if isResearchShowOnlyCurrentlyResearched then
        filterApplied = settings.horizontalScrollBarFilterApplied[lastCraftingType][lastPanel]
        currentTexture = (filterApplied == true and textureCurrentlyResearchedDown or textureCurrentlyResearched)
        currentTooltip = (filterApplied == true and localizationVars["button_FCO_currently_show_only_researched_tooltip"]) or localizationVars["button_FCO_show_all_researched_tooltip"]
    else
        --Check the current settings at the given crafting panel and return the next buttons state and texture
        filterApplied = settings.filterApplied[lastCraftingType][lastPanel]

--d(">filterApplied: " .. tos(filterApplied) ..", lastCraftingType: " ..tos(lastCraftingType) .. ", lastPanel: " ..tos(lastPanel))

        if filterApplied == FCOCF_SHOW_ALL then
--d(">ALL")
            currentTexture = textureAll
            currentTooltip = localizationVars["button_FCO_currently_show_all_tooltip"] .. "\n" .. localizationVars["button_FCO_hide_bank_tooltip"]

        elseif filterApplied == FCOCF_ONLY_SHOW_INVENTORY then
--d(">SHOW INV")
            currentTexture = textureOnlyInventory
            if isRefinementPanel == true then
                if settings.enableMediumFilters then
                    currentTooltip = localizationVars["button_FCO_currently_hide_bank_tooltip"] .. "\n" .. localizationVars["button_FCO_show_only_bank_tooltip"]
                else
                    currentTooltip = localizationVars["button_FCO_currently_hide_bank_tooltip"] .. "\n" .. localizationVars["button_FCO_show_only_craftbag_tooltip"]
                end
            else
                if isWornBagFilterTypeAndShouldShowWithInventory[lastPanel] and settings.enableOnlyWornFilters then
--d(">>WORN BAG")
                        currentTooltip = localizationVars["button_FCO_currently_hide_bank_tooltip"] .. "\n" .. localizationVars["button_FCO_show_only_worn_tooltip"]
                else
--d(">>NON WORN")
                    if settings.enableMediumFilters then
                        currentTooltip = localizationVars["button_FCO_currently_hide_bank_tooltip"] .. "\n" .. localizationVars["button_FCO_show_only_bank_tooltip"]
                    else
                        currentTooltip = localizationVars["button_FCO_currently_hide_bank_tooltip"] .. "\n" .. localizationVars["button_FCO_show_all_tooltip"]
                    end
                end
            end

        elseif filterApplied == FCOCF_ONLY_SHOW_WORN and isWornBagFilterTypeAndShouldShowWithInventory[lastPanel] then
--d(">SHOW WORN")
            if settings.enableOnlyWornFilters then
                currentTexture = textureOnlyWorn
                if settings.enableMediumFilters then
                    currentTooltip = localizationVars["button_FCO_currently_show_only_worn_tooltip"] .. "\n" .. localizationVars["button_FCO_show_only_bank_tooltip"]
                else
                    currentTooltip = localizationVars["button_FCO_currently_show_only_worn_tooltip"] .. "\n" .. localizationVars["button_FCO_show_all_tooltip"]
                end
            else
                --Fallback to ALL
                currentTexture = textureAll
                currentTooltip = localizationVars["button_FCO_currently_show_all_tooltip"] .. "\n" .. localizationVars["button_FCO_hide_bank_tooltip"]
            end


        elseif filterApplied == FCOCF_ONLY_SHOW_BANKED then
--d(">SHOW BANKED")
            currentTexture = textureOnlyBank
            if isRefinementPanel == true then
                currentTooltip = localizationVars["button_FCO_currently_show_only_bank_tooltip"] .. "\n" .. localizationVars["button_FCO_show_only_craftbag_tooltip"]
            else
                currentTooltip = localizationVars["button_FCO_currently_show_only_bank_tooltip"] .. "\n" .. localizationVars["button_FCO_show_all_tooltip"]
            end

        elseif isRefinementPanel == true then
--d(">SHOW CRAFTBAG")
            if filterApplied == FCOCF_ONLY_SHOW_CRAFTBAG then
                currentTexture = textureOnlyCraftBag
                currentTooltip = localizationVars["button_FCO_currently_show_only_craftbag_tooltip"] .. "\n" .. localizationVars["button_FCO_hide_craftbag_tooltip"]
            elseif filterApplied == FCOCF_DO_NOT_SHOW_CRAFTBAG then
                currentTexture = textureNoCraftBag
                currentTooltip = localizationVars["button_FCO_currently_hide_craftbag_tooltip"] .. "\n" .. localizationVars["button_FCO_show_all_tooltip"]
            end
        end
    end

--d(">currentTexture: " .. tos(currentTexture) ..", currentTooltip: " ..tos(currentTooltip))

    return filterApplied, currentTexture, currentTooltip, isRefinementPanel
end

local function moveQuestOnlyCheckbox(filterPanelId)
    ----d("[FCOCF]moveQuestOnlyCheckbox")
    filterPanelId = filterPanelId or FCOCF.locVars.gLastPanel
    --Only needed if AF is active
    if not AdvancedFilters then return end
    --local craftingPanel = craftingTablePanels[filterPanelId]
    libFilters_IsUniversalDeconstructionPanelShown = libFilters_IsUniversalDeconstructionPanelShown or libFilters.IsUniversalDeconstructionPanelShown
    local isUniversalDecon = libFilters_IsUniversalDeconstructionPanelShown(libFilters, false)
    local craftingPanel = getCurrentCraftingFilterTypeReference(filterPanelId, isUniversalDecon)
    if craftingPanel ~= nil then
        local inventoryName = zoVars.INVENTORY_NAME
        local onlyQuestCBoxName = zoVars.QUEST_ITEMS_ONLY_CHECKBOX_NAME
        local onlyQuestCBox = (craftingPanel.GetNamedChild ~= nil and craftingPanel:GetNamedChild(onlyQuestCBoxName)) or nil
        local craftingInv
        if not onlyQuestCBox then
            if craftingPanel.GetNamedChild == nil then
                if craftingPanel.control ~= nil then
                    craftingPanel = craftingPanel.control
                end
            end
            craftingInv = craftingPanel:GetNamedChild(inventoryName)
            onlyQuestCBox = craftingInv and craftingInv:GetNamedChild(onlyQuestCBoxName)
        end
        if onlyQuestCBox then
            --Reanchor the OnlyQuest checkbox now
            onlyQuestCBox:ClearAnchors()
            local anchorTo
            craftingInv = craftingInv or craftingPanel:GetNamedChild(inventoryName)
            if craftingInv then
                anchorTo = craftingInv
            else
                anchorTo = craftingPanel
            end
            onlyQuestCBox:SetAnchor(TOPLEFT, anchorTo, TOPLEFT, 0, -30)
        end
    end
end

local function hideIncludeBankedItemsCheckbox(filterPanelId, isUniversalDecon)
    filterPanelId = filterPanelId or FCOCF.locVars.gLastPanel
    --local craftingPanel = craftingTablePanels[filterPanelId]
    libFilters_IsUniversalDeconstructionPanelShown = libFilters_IsUniversalDeconstructionPanelShown or libFilters.IsUniversalDeconstructionPanelShown
    if isUniversalDecon == nil then
        isUniversalDecon = libFilters_IsUniversalDeconstructionPanelShown(libFilters, false)
    end
--d("hideIncludeBankedItemsCheckbox - filterPanelId: " ..tos(filterPanelId) .. ", isUniversalDecon: " ..tos(isUniversalDecon))
    local craftingPanel = getCurrentCraftingFilterTypeReference(filterPanelId, isUniversalDecon)
    if craftingPanel ~= nil then
--d(">crafting panel found")
--FCOCF._craftingPanel = craftingPanel
        local includeBankedCBoxName = zoVars.INCLUDE_BANKED_CHECKBOX_NAME
        local includeBankedCbox = (craftingPanel.GetNamedChild ~= nil and craftingPanel:GetNamedChild(includeBankedCBoxName)) or nil
        if not includeBankedCbox then
            if craftingPanel.GetNamedChild == nil then
                if craftingPanel.control ~= nil then
                    craftingPanel = craftingPanel.control
                end
            end
            local inventoryName = zoVars.INVENTORY_NAME
            local craftingInv = craftingPanel:GetNamedChild(inventoryName)
            includeBankedCbox = craftingInv and craftingInv:GetNamedChild(includeBankedCBoxName)
        end
        if includeBankedCbox then
--FCOCF._includeBankedCbox = includeBankedCbox
--d(">>found includeBankedCbox")
            --Enable the checkbox so banked items are not filtered by default and FCOCraftFilter can filter with it's own button
            ZO_CheckButton_SetCheckState(includeBankedCbox, true)
            -->Does not change the SavedVariables as e.g. ZO_SmithingExtraction:OnFilterChanged is not executed!
            -->Update the SV manually here
            local svData = (isUniversalDecon == true and craftingTableSVs[FCOCF_CRAFTINGTYPE_UNIVERSAL_DECONSTRUCTION]) or craftingTableSVs[filterPanelId]
            if svData ~= nil and svData.svVar ~= nil and svData.svName ~= nil then
--d(">>>found SVs")
                local svVar = svData.svVar
                local svEntryName = svData.svName
                local svTab = svVar[svEntryName]
                local includeBankedStr = svData.includeBanked
                if includeBankedStr ~= nil then
                    svTab[includeBankedStr] = true
                end
            end
            if includeBankedCbox.IsHidden and includeBankedCbox:IsHidden() == false then
--d(">>hiding includeBankedCbox")
                includeBankedCbox:SetHidden(true)
            end
        end
--    else
--d("<craftingPanel is nil!")
    end
end

local function isCurrentlyAnyTraitResearchedFilterFunc(craftingType, lineIndex)
    --@return name string, icon textureName, numTraits integer, timeRequiredForNextResearchSecs integer
    local name, icon = GetSmithingResearchLineInfo(craftingType, lineIndex)
    for traitIndex = 1, GetNumSmithingTraitItems() do
        --@return duration integer:nilable, timeRemainingSecs integer:nilable
        local duration, timeRemainingSecs = GetSmithingResearchLineTraitTimes(craftingType, lineIndex, traitIndex)
        --traitType [ItemTraitType|#ItemTraitType], traitDescription string, known bool
        local traitType = GetSmithingResearchLineTraitInfo(craftingType, lineIndex, traitIndex)
        local traitName = GetString("SI_ITEMTRAITTYPE", traitType)
        if duration ~= nil and duration > 0 and timeRemainingSecs ~= nil and timeRemainingSecs > 0 then
--d("[FCOCF]IsResearched-name: " ..tos(name) .. " " .. tos(traitName) .. ", left: " ..tos(timeRemainingSecs) .. "/" .. tos(duration))
            return true
        end
    end
    return false
end

FCOCF.lastResearchLineLoopValues = nil

--Clear the custom variables used to filter the horizontal scrolling list entries at a given craftingType
local function clearResearchPanelCustomFilters(craftingType)
    craftingType = craftingType or GetCraftingInteractionType()
    libFilters:UnregisterResearchHorizontalScrollbarFilter("FCOCraftFilter_ResearchHorizontalScrollBarFilter", craftingType)
end
FCOCF.ClearResearchPanelCustomFilters = clearResearchPanelCustomFilters

--Clear the custom variables used to filter the horizontal scrolling list entries at all craftingTypes which got filters registered
local function clearResearchPanelCustomFiltersAtAllCraftingTypes()
    local defaults = FCOCF.settingsVars.defaults
    if defaults == nil then return end
    local horizontalScrollBarFilterAppliedCraftingTypes = defaults.horizontalScrollBarFilterApplied
    if horizontalScrollBarFilterAppliedCraftingTypes == nil then return end
    for craftingType, _ in pairs(horizontalScrollBarFilterAppliedCraftingTypes) do
        libFilters:UnregisterResearchHorizontalScrollbarFilter("FCOCraftFilter_ResearchHorizontalScrollBarFilter", craftingType)
    end
end

--Filter a horizontal scroll list and run a filterFunction given to determine the entries to show in the
--horizontal list afterwards
local function filterHorizontalScrollList(craftingType)
--d(">>>===============================================")
--d("[FCOCF]filterHorizontalScrollList")
    craftingType = craftingType or GetCraftingInteractionType()
    if craftingType == CRAFTING_TYPE_INVALID then return false end
    local filterPanelId = libFilters:GetCurrentFilterType()

    --Check the researchLinIndices for their filterOrEquiupType, armorType and traitType at the current filterPanelId
    if filterPanelId ~= nil then
        --Unregister the before registered filter first
        clearResearchPanelCustomFilters(craftingType)

        --Check the current crafting table's research line for the indices and build a "skip table" for LibFilters-3.0
        local fromResearchLineIndex = 1
        local toResearchLineIndex = GetNumSmithingResearchLines(craftingType)
        local skipTable = {}

        --Check for each possible researchLine at the given crafting station
        for researchLineIndex = fromResearchLineIndex, toResearchLineIndex do
            --d(">CHECKING researchLineIndex: " ..tos(researchLineIndex) .. ", name: " .. tos(GetSmithingResearchLineInfo(craftingType, researchLineIndex)))
            --Check if the current research line index is actively researching any trait
            local researchLineIndexIsAllowed = isCurrentlyAnyTraitResearchedFilterFunc(craftingType, researchLineIndex)
            --No trait is currently researched at the researchLineIndex? Add it to the skip table
            if not researchLineIndexIsAllowed then
    --d(">>SKIPPED NOW")
                --if AF.settings.debugSpam then d("<<<<skipping researchLineIndex: " .. tos(researchLineIndex) .. ", name: " ..tos(GetSmithingResearchLineInfo(craftingType, researchLineIndex))) end
                skipTable[researchLineIndex] = true
            end
        end

        if NonContiguousCount(skipTable) > 0 then
            --Set the from and to and the skipTable values for the loop "for researchLineIndex = 1, GetNumSmithingResearchLines(craftingType) do"
            --in function SMITHING.researchPanel.Refresh
            -->Was overwritten in LibFilters-3.0 helper functions and the function LibFilters3.SetResearchLineLoopValues(from, to, skipTable) was added
            -->to set the values for your needs
            --libFilters:SetResearchLineLoopValues(fromResearchLineIndex, toResearchLineIndex, skipTable, additionalData)
            --This will update the registered filter (skipTable) but it won't refresh the researchPanel! This needs to be manually done via
            --libFilters:RequestUpdateForResearchFilters(0)
            libFilters:RegisterResearchHorizontalScrollbarFilter("FCOCraftFilter_ResearchHorizontalScrollBarFilter", craftingType, skipTable, fromResearchLineIndex, toResearchLineIndex)
        end
    end
--d("<<<===============================================")
end

--[[
local function isResearchHorizontalScrollbarShown()
    --if the research panel is currently not shown: Do nothing
    local currentFilterType = libFilters:GetCurrentFilterType()
    if currentFilterType == nil or (currentFilterType ~= LF_SMITHING_RESEARCH and currentFilterType ~= LF_JEWELRY_RESEARCH) then return end
    --local filterTag = tos(GetCraftingInteractionType()) .. "_" .. tos(currentFilterType)
    local researchHorizontalScrollList = controlsForChecks.researchLineList

    if researchHorizontalScrollList and researchHorizontalScrollList.control and not researchHorizontalScrollList.control:IsHidden() then
        return true, currentFilterType
    end
    return false, currentFilterType
end
]]

local function callCurrentlyResearchedItemsFilter(doToggle)
    local locVars = FCOCF.locVars
    local lastCraftingType = locVars.gLastCraftingType --contains "UniversalDeconstruction" as crafting type if last was UniversalDecon panel
    local lastPanel= locVars.gLastPanel
    --d("[FCOCF]callCurrentlyResearchedItemsFilter-doToggle: " ..tos(doToggle) .. ", lastCraftingType: " ..tos(lastCraftingType) .. ", lastPanel: " .. tos(lastPanel))
    if not libFilters:IsResearchShown() then return end

    local settings = FCOCF.settingsVars.settings
    --Abort and unregister current filters if button is disabled or settings are missing
    if not settings.showButtonResearchOnlyCurrentlyResearched then
        --Unregister the filter at all craftingTypes of the horizintal scrolllists
        clearResearchPanelCustomFiltersAtAllCraftingTypes()
        return
    end
    if settings.horizontalScrollBarFilterApplied[lastCraftingType] == nil or settings.horizontalScrollBarFilterApplied[lastCraftingType][lastPanel] == nil then
        --Unregister the filter at the current horizintal scrolllist
        clearResearchPanelCustomFilters(lastCraftingType)
        return
    end

    doToggle = doToggle or false
    if doToggle == true then
        FCOCF.settingsVars.settings.horizontalScrollBarFilterApplied[lastCraftingType][lastPanel] = not FCOCF.settingsVars.settings.horizontalScrollBarFilterApplied[lastCraftingType][lastPanel]


        ------- -v- OTHER ADDON: AdvancedFilters -v- -----------------------------------------------------------------------------------
        --If AdvancedFilters is enabled. Let it's filter apply first, after that call FCOCraftFilter functions from AF's function AdvancedFilters.util.FilterHorizontalScrollList
        if AdvancedFilters ~= nil then
            --AdvancedFilters.util.CheckForResearchPanelAndRunFilterFunction(true, nil, nil, nil)
            --Get the currently active AdvancedFilters subFilterBar and run apply it's currents horizontal scroll list filterCallbacks
            AdvancedFilters.util.CheckForResearchPanelAndRunCurrentSubfilterBarsFilterFunctions()
            return
        end
        ------- -^- OTHER ADDON: AdvancedFilters -^- -----------------------------------------------------------------------------------
    end

    if FCOCF.settingsVars.settings.horizontalScrollBarFilterApplied[lastCraftingType][lastPanel] == true then
        --Refresh the research horizontal scrollbar
        filterHorizontalScrollList(lastCraftingType)
    else
        --Unregister the filter at the horizintal scrolllist
        clearResearchPanelCustomFilters(lastCraftingType)
    end
    --Refresh the research horizontal scrollbar
    --libFilters:RequestUpdateByName("SMITHING_RESEARCH", 0, currentFilterType) --researchPanel:Refresh() --> Will rebuild the list entries and call list:Commit()
    --Only update the list if not done by AdvancedFilters
    if doToggle == true or AdvancedFilters == nil then
        libFilters:RequestUpdateForResearchFilters(0)
    end
end
FCOCF.CallCurrentlyResearchedItemsFilter = callCurrentlyResearchedItemsFilter

local function toggleCurrentlyResearchedItemsFilter()
--d("[FCOCF]toggleCurrentlyResearchedItemsFilter")
    callCurrentlyResearchedItemsFilter(true)
end
--FCOCF.ToggleCurrentlyResearchedItemsFilter = toggleCurrentlyResearchedItemsFilter


local function Localization()
----d("[FCOCF] Localization - Start, useClientLang: " .. tos(FCOCF.settingsVars.settings.alwaysUseClientLanguage))
	--Was localization already done during keybindings? Then abort here
 	if FCOCF.preventerVars.gLocalizationDone == true then return end
    local settings = FCOCF.settingsVars.settings
    --Fallback to english variable
    local fallbackToEnglish = false
	--Always use the client's language?
    if not settings.alwaysUseClientLanguage then
		--Was a language chosen already?
	    if not settings.languageChosen then
----d("[FCOCF] Localization: Fallback to english. Language chosen: " .. tos(settings.languageChosen) .. ", defaultLanguage: " .. tos(FCOCF.settingsVars.defaultSettings.language))
			if FCOCF.settingsVars.defaultSettings.language == nil then
----d("[FCOCF] Localization: defaultSettings.language is NIL -> Fallback to english now")
		    	fallbackToEnglish = true
		    else
				--Is the languages array filled and the language is not valid (not in the language array with the value "true")?
				if FCOCF.langVars.languages ~= nil and #FCOCF.langVars.languages > 0 and not FCOCF.langVars.languages[FCOCF.settingsVars.defaultSettings.language] then
		        	fallbackToEnglish = true
----d("[FCOCF] Localization: defaultSettings.language is ~= " .. i .. ", and this language # is not valid -> Fallback to english now")
				end
		    end
		end
	end
----d("[FCOCF] localization, fallBackToEnglish: " .. tos(fallbackToEnglish))
	--Fallback to english language now
    if (fallbackToEnglish) then FCOCF.settingsVars.defaultSettings.language = 1 end
	--Is the standard language english set?
    if settings.alwaysUseClientLanguage or (FCOCF.settingsVars.defaultSettings.language == 1 and not settings.languageChosen) then
----d("[FCOCF] localization: Language chosen is false or always use client language is true!")
		local lang = GetCVar("language.2")
		--Check for supported languages
		if(lang == "de") then
	    	FCOCF.settingsVars.defaultSettings.language = 2
	    elseif (lang == "en") then
	    	FCOCF.settingsVars.defaultSettings.language = 1
	    elseif (lang == "fr") then
	    	FCOCF.settingsVars.defaultSettings.language = 3
	    elseif (lang == "es") then
	    	FCOCF.settingsVars.defaultSettings.language = 4
	    elseif (lang == "it") then
	    	FCOCF.settingsVars.defaultSettings.language = 5
	    elseif (lang == "jp") then
	    	FCOCF.settingsVars.defaultSettings.language = 6
	    elseif (lang == "ru") then
	    	FCOCF.settingsVars.defaultSettings.language = 7
		else
	    	FCOCF.settingsVars.defaultSettings.language = 1
	    end
	end
----d("[FCOCF] localization: default settings, language: " .. tos(FCOCF.settingsVars.defaultSettings.language))
    --Get the localized texts from the localization file
    FCOCF.localizationVars.FCOCF_loc = FCOCF.localizationVars.localizationAll[FCOCF.settingsVars.defaultSettings.language]
end

--Show a help inside the chat
local function help()
	d(FCOCF.localizationVars.FCOCF_loc["chatcommands_info"])
	--d("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	d(FCOCF.localizationVars.FCOCF_loc["chatcommands_help"])
end

--Check the commands ppl type to the chat
local function command_handler(args)
    --Parse the arguments string
	local options = {}
    local searchResult = { string.match(args, "^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end

	if(#options == 0 or options[1] == "" or options[1] == "help" or options[1] == "hilfe" or options[1] == "list") then
       	help()
    end
end

--==============================================================================
--============================== END SETTINGS ==================================
--==============================================================================
--Move the research timer icon and the currently available research slots label to the right
local function reanchorResearchControls()
    local numResearchingLabel = zoVars.CRAFTSTATION_SMITHING_RESEARCH_NUM_RESEARCH_LABEL
    local timerIcon = zoVars.CRAFTSTATION_SMITHING_RESEARCH_TIMER_ICON
    if numResearchingLabel then
        numResearchingLabel:ClearAnchors()
        numResearchingLabel:SetAnchor(TOPLEFT, nil, nil, 75, 18)
    end
    if timerIcon then
        timerIcon:ClearAnchors()
        timerIcon:SetAnchor(RIGHT, numResearchingLabel, LEFT, -2, 0)
    end
end

--Check if the ResearchListDialog is shown
local function isResearchListDialogShown()
----d("[FCOCF]isResearchListDialogShown")
    local listDialog = ZO_InventorySlot_GetItemListDialog()
    if listDialog == nil or listDialog.control == nil or listDialog.control.data == nil then return false end
    local data = listDialog.control.data
    if data.owner == nil or data.owner.control == nil then return false end
    local isResearchDialogShown = (not listDialog.control:IsHidden() and data.owner.control == zoVars.RESEARCH) or false
----d(">shown: " ..tos(isResearchDialogShown))
    return isResearchDialogShown
end


--Callback function for the filter: This function will hide/show the items at the crafting station panel
--return false: hide the slot
--return true: show the slot
local function FCOCraftFilter_FilterCallbackFunction(bagId, slotIndex, filterTag)
    local locVars = FCOCF.locVars
    local lastPanel = locVars.gLastPanel
    local lastCraftingType = locVars.gLastCraftingType
    if bagId == nil or slotIndex == nil or lastPanel == nil or lastCraftingType == nil then return false end
    local settings = FCOCF.settingsVars.settings
    --The result variable, predefined with true to show the item
    local filterAppliedSettings = settings.filterApplied[lastCraftingType][lastPanel]

    if filterAppliedSettings == FCOCF_SHOW_ALL then return true end

    local resultVar = true
    if filterAppliedSettings == FCOCF_ONLY_SHOW_INVENTORY then
        if bagId ~= BAG_BACKPACK then
            --Is retrait shown etc? Worn items should not be filtered then and show at "Only inventory" too
            if bagId ~= BAG_WORN then
                resultVar = false
            else
                --Show worn items at "Only inventory" too=
                if filterTag ~= nil and isWornBagFilterTypeAndShouldShowWithInventory[filterTag] == true and settings.showWornItemsAtOnlyInventory == true then
                    resultVar = true
                else
                    resultVar = false
                end
            end
        end
    elseif filterAppliedSettings == FCOCF_ONLY_SHOW_WORN then
        if bagId ~= BAG_WORN or filterTag == nil or not isWornBagFilterTypeAndShouldShowWithInventory[filterTag] then
            resultVar = false
        end
    elseif filterAppliedSettings == FCOCF_ONLY_SHOW_BANKED then
        if (bagId ~= BAG_BANK and bagId ~= BAG_SUBSCRIBER_BANK) then
            resultVar = false
        end

    elseif filterAppliedSettings == FCOCF_ONLY_SHOW_CRAFTBAG then
        if bagId ~= BAG_VIRTUAL then
            resultVar = false
        end

    elseif filterAppliedSettings == FCOCF_DO_NOT_SHOW_CRAFTBAG then
        if bagId == BAG_VIRTUAL then
            resultVar = false
        end
    end

    --[[
    if bagId == BAG_WORN then
        d("[FCOCF]" .. GetItemLink(bagId, slotIndex) ..": " ..tos(resultVar) .. "; filterApplied: " .. tos(filterAppliedSettings) .."; bag: " .. tos(bagId) .. "; filterTag: " ..tos(filterTag))
    end
    ]]

    --Return the result variable now
    return resultVar
end

--Refresh the list dialog 1 scroll list (ZO_ListDialog1List)
local function RefreshListDialog(rebuildItems, filterPanelId)
    rebuildItems = rebuildItems or false
    filterPanelId = filterPanelId or FCOCF.locVars.gLastPanel
----d("RefreshListDialog - rebuildItems: " .. tos(rebuildItems) .. ", filterPanelId: " .. tos(filterPanelId) .. ", ListDialogHidden: " ..tos(zoVars.LIST_DIALOG_LIST:IsHidden()))
    local refreshListDialogNow = false
    if not zoVars.LIST_DIALOG_LIST:IsHidden() then
        --Rebuild the whole ZO_ListDialog1List ?
        if rebuildItems and filterPanelId ~= nil then
            --Is the function to update a dialog from LibFilters given?
            if libFilters and libFilters.RequestUpdate then
                libFilters:RequestUpdate(filterPanelId)
            else
                refreshListDialogNow = true
            end
        else
            refreshListDialogNow = true
        end
        if refreshListDialogNow then
            --Refresh the visible contents if the list dialog
            ZO_ScrollList_RefreshVisible(zoVars.LIST_DIALOG_LIST)
        end
    end
end

--Update inventory/refresh it
local function FCOCraftFilter_UpdateInventory(invType)
    if libFilters == nil or invType == nil then return end
    libFilters:RequestUpdate(invType)
    --Is a dialog shown? Then refresh teh visible entries now
    if not zoVars.LIST_DIALOG:IsHidden() then
        RefreshListDialog(false, invType)
    end

    --Addon AdvancedFilters is enabled? RefreshTheSubfilterButton bar now to hide/show subfilters where no items are below
    if AdvancedFilters and AdvancedFilters.util and AdvancedFilters.util.RefreshSubfilterBar
        and AdvancedFilters.util.UpdateCraftingInventoryFilteredCount then
        local AF = AdvancedFilters
        local retraitPanel = zoVars.TRANSMUTATIONSTATION_RETRAIT_PANEL
        local libFiltersPanelId2CraftingInvFilterType = {
            [LF_RETRAIT]                = retraitPanel.inventory.filterType,
            [LF_SMITHING_REFINE]        = smith.refinementPanel.inventory.filterType,
            [LF_SMITHING_DECONSTRUCT]   = smith.deconstructionPanel.inventory.filterType,
            [LF_SMITHING_IMPROVEMENT]   = smith.improvementPanel.inventory.filterType,
            [LF_SMITHING_RESEARCH]      = nil, --No subfilterbars within AF until today!
            [LF_JEWELRY_REFINE]         = smith.refinementPanel.inventory.filterType,
            [LF_JEWELRY_DECONSTRUCT]    = smith.deconstructionPanel.inventory.filterType,
            [LF_JEWELRY_IMPROVEMENT]    = smith.improvementPanel.inventory.filterType,
            [LF_JEWELRY_RESEARCH]       = nil, --No subfilterbars within AF until today!
            [LF_ENCHANTING_CREATION]    = ench.inventory.filterType,
            [LF_ENCHANTING_EXTRACTION]  = ench.inventory.filterType,
        }
        local invTypeAF = AF.currentInventoryType
        local craftingType = AF.util.GetCraftingType()
        local craftingInvFilterType = libFiltersPanelId2CraftingInvFilterType[invTypeAF] or nil
        if craftingInvFilterType == nil then return end
        local currentFilter = AF.util.MapCraftingStationFilterType2ItemFilterType(craftingInvFilterType, invTypeAF, craftingType)
----d("[FCOCF->AF]ChangeFilterCrafting, invTypeAF: " .. tos(invTypeAF) .. ", craftingType: " .. tos(craftingType) .. ", currentFilter: " .. tos(currentFilter))
        local subfilterGroup = AF.subfilterGroups[invTypeAF]
        if not subfilterGroup then return end
        local currentSubfilterBar = subfilterGroup.currentSubfilterBar
        if not currentSubfilterBar then return end
        AF.util.ThrottledUpdate("RefreshSubfilterBar" .. invTypeAF .. "_" .. craftingType .. currentSubfilterBar.name, 10,
            AF.util.RefreshSubfilterBar, currentSubfilterBar, "FCOCraftFilter")
        AF.util.ThrottledUpdate("UpdateCraftingInventoryFilteredCount" .. invTypeAF .. "_" .. craftingType .. currentSubfilterBar.name, 25,
            AF.util.UpdateCraftingInventoryFilteredCount, invTypeAF)
    end
end

--Register the filter + callback function for the inventory type
local function FCOCraftFilter_RegisterFilter(filterName, libFiltersInventoryType, callbackFunction)
    if   libFilters == nil or filterName == nil or filterName == "" or libFiltersInventoryType == nil
      or callbackFunction == nil or type(callbackFunction) ~= "function" then return end
--d("[FCOCraftFilter_RegisterFilter] filterName: FCOCraftFilter_" .. filterName .. ", libFiltersInventoryType: " .. libFiltersInventoryType)
    if(not libFilters:IsFilterRegistered("FCOCraftFilter_" .. tos(filterName))) then
        ----d("--> register now")
        libFilters:RegisterFilter("FCOCraftFilter_" .. tos(filterName), libFiltersInventoryType,
                function(bagId, slotIndex)
                    return callbackFunction(bagId, slotIndex, libFiltersInventoryType)
                end)
    end
end

--Unregister the filter for the inventory type
local function FCOCraftFilter_UnregisterFilter(filterName, libFiltersInventoryType)
    if   libFilters == nil or filterName == nil or filterName == "" or libFiltersInventoryType == nil then return end
----d("[FCOCraftFilter_UnregisterFilter] filterName: FCOCraftFilter_" .. filterName .. ", libFiltersInventoryType: " .. libFiltersInventoryType)
    libFilters:UnregisterFilter("FCOCraftFilter_" .. tos(filterName), libFiltersInventoryType)
end


--==============================================================================
--==================== START EVENT CALLBACK FUNCTIONS===========================
--==============================================================================

--Get the "real" active panel.
local function FCOCraftFilter_CheckActivePanel(comingFrom, isUniversalDeconShown)
    isUniversalDeconShown = isUniversalDeconShown or false
    local locVars = FCOCF.locVars
    if comingFrom == nil then
        --Get the current filter panel id
        comingFrom = locVars.gLastPanel
        if comingFrom == nil then comingFrom = 0 end
    end

--d("[FCOCraftFilter_CheckActivePanel] comingFrom: " .. comingFrom)

    if locVars.gLastCraftingType ~= nil and locVars.gLastPanel ~= nil then
        --Unregister the filter for old panel
        FCOCraftFilter_UnregisterFilter(locVars.gLastCraftingType .. "_" .. locVars.gLastPanel, locVars.gLastPanel)
    end
    local craftingType = GetCraftingInteractionType()

    --UniversalDeconstruction
    if (isUniversalDeconShown == true or libFilters_IsUniversalDeconstructionPanelShown(libFilters)) and libFilters_IsUniversalDeconstructionSupportedFilterType(comingFrom) then
--d(">universal decon")
        craftingType = FCOCF_CRAFTINGTYPE_UNIVERSAL_DECONSTRUCTION
        locVars.gLastCraftingType = craftingType
        locVars.gLastPanel = comingFrom

    --Enchanting creation mode
    elseif comingFrom == LF_ENCHANTING_CREATION then
        locVars.gLastPanel = LF_ENCHANTING_CREATION
        --Enchanting extraction mode
    elseif comingFrom == LF_ENCHANTING_EXTRACTION then
        locVars.gLastPanel = LF_ENCHANTING_EXTRACTION
        --Refinement
    elseif comingFrom == LF_SMITHING_REFINE then
        locVars.gLastPanel = LF_SMITHING_REFINE
    elseif comingFrom == LF_JEWELRY_REFINE then
        locVars.gLastPanel = LF_JEWELRY_REFINE
        --Deconstruction
    elseif comingFrom == LF_SMITHING_DECONSTRUCT then
        locVars.gLastPanel = LF_SMITHING_DECONSTRUCT
    elseif comingFrom == LF_JEWELRY_DECONSTRUCT then
        locVars.gLastPanel = LF_JEWELRY_DECONSTRUCT
        --Improvement
    elseif comingFrom == LF_SMITHING_IMPROVEMENT then
        locVars.gLastPanel = LF_SMITHING_IMPROVEMENT
    elseif comingFrom == LF_JEWELRY_IMPROVEMENT then
        locVars.gLastPanel = LF_JEWELRY_IMPROVEMENT
        --Research
    elseif comingFrom == LF_SMITHING_RESEARCH then
        locVars.gLastPanel = LF_SMITHING_RESEARCH
    elseif comingFrom == LF_JEWELRY_RESEARCH then
        locVars.gLastPanel = LF_JEWELRY_RESEARCH
        --Research dialog
    elseif comingFrom == LF_SMITHING_RESEARCH_DIALOG then
        locVars.gLastPanel = LF_SMITHING_RESEARCH_DIALOG
    elseif comingFrom == LF_JEWELRY_RESEARCH_DIALOG then
        locVars.gLastPanel = LF_JEWELRY_RESEARCH_DIALOG
        --Transmutation / Retrait
    elseif comingFrom == LF_RETRAIT then
        locVars.gLastPanel = LF_RETRAIT

        ---------------------------------------------------------------------------------
        --Alternative detection via the controls hidden state
        ---------------------------------------------------------------------------------
        --Refinement
    elseif not zoVars.CRAFTSTATION_SMITHING_REFINEMENT_INVENTORY:IsHidden() then
        if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
            locVars.gLastPanel = LF_JEWELRY_REFINE
        else
            locVars.gLastPanel = LF_SMITHING_REFINE
        end
        --Deconstruction
    elseif not zoVars.CRAFTSTATION_SMITHING_DECONSTRUCTION_INVENTORY:IsHidden() then
        if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
            locVars.gLastPanel = LF_JEWELRY_DECONSTRUCT
        else
            locVars.gLastPanel = LF_SMITHING_DECONSTRUCT
        end
        --Improvement
    elseif not zoVars.CRAFTSTATION_SMITHING_IMPROVEMENT_INVENTORY:IsHidden() then
        if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
            locVars.gLastPanel = LF_JEWELRY_IMPROVEMENT
        else
            locVars.gLastPanel = LF_SMITHING_IMPROVEMENT
        end
        --Research
    elseif not zoVars.CRAFTSTATION_SMITHING_RESEARCH:IsHidden() then
        if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
            locVars.gLastPanel = LF_JEWELRY_RESEARCH
        else
            locVars.gLastPanel = LF_SMITHING_RESEARCH
        end
        --Research dialog
    elseif isResearchListDialogShown() then
        --Check the active crafting type
        if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
            locVars.gLastPanel = LF_JEWELRY_RESEARCH_DIALOG
        elseif craftingType ~= CRAFTING_TYPE_INVALID and craftingType ~= CRAFTING_TYPE_ENCHANTING then
            locVars.gLastPanel = LF_SMITHING_RESEARCH_DIALOG
        else
            locVars.gLastPanel = nil
            return
        end
        --Transmutation / Retrait
    elseif not zoVars.TRANSMUTATIONSTATION_CONTROL:IsHidden() then
        locVars.gLastPanel = LF_RETRAIT
    end
    --d(">lastPanel: "..tos(locVars.gLastPanel))

    if comingFrom == 0 or locVars.gLastPanel == nil then return end
end

--Add a button to an existing parent control
local function AddButton(parent, name, callbackFunction, text, font, tooltipText, tooltipAlign, width, height, left, top, alignMain, alignBackup, alignControl, hideButton, isUniversalDecon, isResearchShowOnlyCurrentlyResearched)
    isUniversalDecon = isUniversalDecon or false
    isResearchShowOnlyCurrentlyResearched = isResearchShowOnlyCurrentlyResearched or false
--d("[AddButton] name: " .. name)
    --Abort needed?
    if (not hideButton and (parent == nil or name == nil or callbackFunction == nil
            or width <= 0 or height <= 0 or alignMain == nil or alignBackup == nil)
            and (textureAll == nil or text == nil)) then
    elseif hideButton and name == nil then
        return nil
    end
    --local settings = FCOCF.settingsVars.settings
    local locVars = FCOCF.locVars
    --local localizationVars = FCOCF.localizationVars.FCOCF_loc
    --local lastCraftingType = locVars.gLastCraftingType
    --local lastPanel= locVars.gLastPanel


    local function colorizeTextureAccordingToFilterApplied(texture, filterApplied, isRefinementPanel, isResearchShowOnlyCurrentlyResearched)
        isResearchShowOnlyCurrentlyResearched = isResearchShowOnlyCurrentlyResearched or false

        if isResearchShowOnlyCurrentlyResearched == true then
            if filterApplied == true then
                texture:SetColor(0, 1, 0, 1)
            else
                texture:SetColor(1, 1, 1, 0.5)
            end
        else
            texture:SetColor(1, 1, 1, 1)
            if isRefinementPanel == true then
                if filterApplied == FCOCF_DO_NOT_SHOW_CRAFTBAG then
                    texture:SetColor(1, 0, 0, 1)
                end
            end
        end
    end

    local function updateButtonTextureAndTooltip(buttonControl)
        ZO_Tooltips_HideTextTooltip()
        local filterApplied, texturePath, tooltipTextForButton, isRefinementPanel = getCurrentButtonStateAndTexture(buttonControl.isUniversalDecon, buttonControl.isResearchShowOnlyCurrentlyResearched)

        local butnTexture = buttonControl:GetChild(1)
        butnTexture:SetTexture(texturePath)
        colorizeTextureAccordingToFilterApplied(butnTexture, filterApplied, isRefinementPanel, buttonControl.isResearchShowOnlyCurrentlyResearched)
        if tooltipText ~= nil and tooltipTextForButton ~= nil then
            tooltipText = locVars.preChatTextGreen .. "\n" .. tooltipTextForButton
            ZO_Tooltips_ShowTextTooltip(buttonControl, tooltipAlign, tooltipText)
        end
    end

    local button
    --Does the button already exist?
    button = WINDOW_MANAGER:GetControlByName(name, "")
    if button == nil then
        --Button does not exist yet and it should be hidden? Abort here!
        if hideButton == true then return nil end
        --Create the button control at the parent
        button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    end
    --Button was created?
    if button ~= nil then
----d(">found button, or created it")
        button.isUniversalDecon = isUniversalDecon
        button.isResearchShowOnlyCurrentlyResearched = isResearchShowOnlyCurrentlyResearched

        --Button should be hidden?
        if hideButton == false then

            --Set the button's size
            button:SetDimensions(width, height)

            --Align the button
            if alignControl == nil then
                alignControl = parent
            end

            --SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
            button:SetAnchor(alignMain, alignControl, alignBackup, left, top)

            --Texture or text?
            if text ~= nil then
                --Text
                --Set the button's font
                if font == nil then
                    button:SetFont("ZoFontGameSmall")
                else
                    button:SetFont(font)
                end

                --Set the button's text
                button:SetText(text)

            else
                --Do we have seperate textures for the button states?
                if button.isResearchShowOnlyCurrentlyResearched == true then
                    button.showAllTexture       = textureCurrentlyResearched
                else
                    button.showAllTexture       = textureAll
                    button.onlyBankedTexture    = textureOnlyBank
                    button.onlyCraftbagTexture  = textureOnlyCraftBag
                    button.noCraftbagTexture    = textureNoCraftBag
                    button.onlyInventory        = textureOnlyInventory
                    button.onlyWornTexture      = textureOnlyWorn
                end

                --Texture
                local texture
                --Check if texture exists
                texture = WINDOW_MANAGER:GetControlByName(name .. "Texture", "")
                if texture == nil then
                    --Create the texture for the button to hold the image
                    texture = WINDOW_MANAGER:CreateControl(name .. "Texture", button, CT_TEXTURE)
                end
                texture:SetAnchorFill()

                local filterApplied, texturePath, _, isRefinementPanel = getCurrentButtonStateAndTexture(button.isUniversalDecon, button.isResearchShowOnlyCurrentlyResearched)
--d(">texturePath: " ..tos(texturePath))
                texture:SetTexture(texturePath)
                colorizeTextureAccordingToFilterApplied(texture, filterApplied, isRefinementPanel, button.isResearchShowOnlyCurrentlyResearched)
            end

            if tooltipAlign == nil then tooltipAlign = TOP end

            --Set a tooltip?
            button:SetHandler("OnMouseEnter", function(self)
                updateButtonTextureAndTooltip(self)
            end)
            button:SetHandler("OnMouseExit", function(self)
                ZO_Tooltips_HideTextTooltip()
            end)
            button:SetHandler("OnMouseDown", function(butn, ctrl, alt, shift, command)
                ZO_Tooltips_HideTextTooltip()
            end)
            --Set the callback function of the button
            button:SetHandler("OnClicked", function(butn, ...)
                callbackFunction(butn, ...)
                --Switch the texture of the button to the next one, according to the settings
                zo_callLater(function()
                    updateButtonTextureAndTooltip(butn)
                end, 10)
            end)
            button:SetHandler("OnMouseUp", function(butn, upInside)
                if upInside then
                    ZO_Tooltips_HideTextTooltip()
                end
            end)

            --Show the button and make it react on mouse input
            button:SetHidden(false)
            button:SetMouseEnabled(true)

            --Return the button control
            return button
        else
----d("hiding button: " .. name)
            --Hide the button and make it not reacting on mouse input
            button:SetHidden(true)
            button:SetMouseEnabled(false)
        end
    else
        return nil
    end
end

--Function to change the bank etc. items filter at crafting stations, according to the enabled settings (medium filter)
local function FCOCraftFilter_ChangeCraftingStationFilterSettingsByButtonClicked(comingFrom, isUniversalDecon)
    isUniversalDecon = isUniversalDecon or false
    if comingFrom == nil then return false end
    local locVars = FCOCF.locVars
    local lastCraftingType = locVars.gLastCraftingType
    if lastCraftingType == nil then return false end

    local settings = FCOCF.settingsVars.settings
    local isRefinementPanel = (comingFrom == LF_SMITHING_REFINE or comingFrom == LF_JEWELRY_REFINE) or false
    if isRefinementPanel == true then isUniversalDecon = false end

    --Is the "show only bank items" filter enabled?
--d("[FCOCF]FCOCraftFilter_ChangeCraftingStationBankSettings-comingFrom: "
        --..tos(comingFrom).. ", enableMediumFilters: " ..tos(settings.enableMediumFilters) .. ", lastCraftingType: " ..tos(locVars.gLastCraftingType)
        --.. ", currentSetting: " .. tos(settings.filterApplied[locVars.gLastCraftingType][comingFrom]))

    if settings.filterApplied[lastCraftingType][comingFrom] == FCOCF_SHOW_ALL then
        settings.filterApplied[lastCraftingType][comingFrom] = FCOCF_ONLY_SHOW_INVENTORY

    elseif settings.filterApplied[lastCraftingType][comingFrom] == FCOCF_ONLY_SHOW_INVENTORY then
        if settings.enableOnlyWornFilters and isWornBagFilterTypeAndShouldShowWithInventory[comingFrom] == true then
            settings.filterApplied[lastCraftingType][comingFrom] = FCOCF_ONLY_SHOW_WORN
        else
            settings.filterApplied[lastCraftingType][comingFrom] = FCOCF_ONLY_SHOW_BANKED
        end

    elseif settings.filterApplied[lastCraftingType][comingFrom] == FCOCF_ONLY_SHOW_WORN then
        if settings.enableMediumFilters then
            settings.filterApplied[lastCraftingType][comingFrom] = FCOCF_ONLY_SHOW_BANKED
        else
            if isRefinementPanel then
                settings.filterApplied[lastCraftingType][comingFrom] = FCOCF_ONLY_SHOW_CRAFTBAG
            else
                settings.filterApplied[lastCraftingType][comingFrom] = FCOCF_SHOW_ALL
            end
        end

    elseif settings.filterApplied[lastCraftingType][comingFrom] == FCOCF_ONLY_SHOW_BANKED then
        if isRefinementPanel then
            settings.filterApplied[lastCraftingType][comingFrom] = FCOCF_ONLY_SHOW_CRAFTBAG
        else
            settings.filterApplied[lastCraftingType][comingFrom] = FCOCF_SHOW_ALL
        end

    elseif isRefinementPanel and settings.filterApplied[lastCraftingType][comingFrom] == FCOCF_ONLY_SHOW_CRAFTBAG then
        settings.filterApplied[lastCraftingType][comingFrom] = FCOCF_DO_NOT_SHOW_CRAFTBAG

    elseif isRefinementPanel and settings.filterApplied[lastCraftingType][comingFrom] == FCOCF_DO_NOT_SHOW_CRAFTBAG then
        settings.filterApplied[lastCraftingType][comingFrom] = FCOCF_SHOW_ALL

    else
        --Fallback to show all
        settings.filterApplied[lastCraftingType][comingFrom] = FCOCF_SHOW_ALL
    end

--d("<New filterApplied: " ..tos(settings.filterApplied[lastCraftingType][comingFrom]))
end

local function resetSVIfNecessary(lastCraftingType)
    local locVars = FCOCF.locVars
    lastCraftingType = lastCraftingType or locVars.gLastCraftingType
    if lastCraftingType == nil then return end
    local lastPanel = locVars.gLastPanel
    if lastPanel == nil then return end

    local settings = FCOCF.settingsVars.settings
    local filterAppliedSettings = settings.filterApplied[lastCraftingType][lastPanel]
    --Reset variables in SV for the active panel so the buttons texture shows properly, if a setting to show the button was disabled
    if not settings.enableOnlyWornFilters and filterAppliedSettings == FCOCF_ONLY_SHOW_WORN then
        FCOCF.settingsVars.settings.filterApplied[lastCraftingType][lastPanel] = FCOCF_SHOW_ALL
    end
end

--Function to update the settings "hide/show bank items at crafting station", update the filter and refresh the visible items
local function FCOCraftFilter_CraftingStationUpdateBankItemOption(comingFrom, changeSettings, isUniversalDecon)
    changeSettings = changeSettings or false
    isUniversalDecon = isUniversalDecon or false
    if comingFrom == nil then return false end
    local locVars = FCOCF.locVars
    local lastCraftingType = locVars.gLastCraftingType
--d("[FCOCraftFilter_CraftingStationUpdateBankItemOption] comingFrom: " .. comingFrom .. ", changeSettings: " .. tos(changeSettings) .. ", lastCraftingType: " ..tos(lastCraftingType))
    if lastCraftingType == nil then return false end
    local settings = FCOCF.settingsVars.settings
    if settings.filterApplied[lastCraftingType][comingFrom] == nil then return false end

--d(">> settings.filterApplied[" .. tos(lastCraftingType) .. "][" .. tos(comingFrom) .. "]: " .. tos(settings.filterApplied[lastCraftingType][comingFrom]))
    --Turn around the settings if wished
    if changeSettings == true then
        FCOCraftFilter_ChangeCraftingStationFilterSettingsByButtonClicked(comingFrom, isUniversalDecon)
    end
--d(">>> NEW setting filterApplied: " .. tos(settings.filterApplied[locVars.gLastCraftingType][comingFrom]))
    --Get the appropriate inventory type
    if comingFrom == nil then return end
    --Check settings then
    local filterTag = lastCraftingType .. "_" .. comingFrom
    if settings.filterApplied[lastCraftingType][comingFrom] == FCOCF_SHOW_ALL then
        --d("Unregister filter")
        --Unregister the filter and show all items again
        FCOCraftFilter_UnregisterFilter(filterTag, comingFrom)
        --Refresh the inventory
        FCOCraftFilter_UpdateInventory(comingFrom)
    else
        --d("Register filter")
        resetSVIfNecessary(lastCraftingType)
        --Register the filter and hide bank items
        FCOCraftFilter_RegisterFilter(filterTag, comingFrom, FCOCraftFilter_FilterCallbackFunction)
        --Refresh the inventory
        FCOCraftFilter_UpdateInventory(comingFrom)
    end
end

local function addFilterButtonUniversalDecon(filterType)
    local addedButtonData
    local parent, name, alignControl

    FCOCF.filterButtons[FCOCF_CRAFTINGTYPE_UNIVERSAL_DECONSTRUCTION] = FCOCF.filterButtons[FCOCF_CRAFTINGTYPE_UNIVERSAL_DECONSTRUCTION] or {}
    local universalDeconFilterButtons = FCOCF.filterButtons[FCOCF_CRAFTINGTYPE_UNIVERSAL_DECONSTRUCTION]

    --Compatibility for addon PerfectPixel
    local xOffset = (isPerfectPixelEnabled == nil and -380) or -355

    --UniversalDeconstruction
    --DECONSTRUCTION & Jewelry deconstructin (re-use the same button, just updates the filterType!)
    if filterType == LF_SMITHING_DECONSTRUCT or filterType == LF_JEWELRY_DECONSTRUCT then
        --Hide the enchantment extraction button at UniversalDeconstruction panel, if shown
        local enchantingButton = universalDeconFilterButtons[LF_ENCHANTING_EXTRACTION]
        if enchantingButton ~= nil and not enchantingButton:IsHidden() and enchantingButton:GetParent() == universalDeconPanelInvControl then
            enchantingButton:SetHidden(true)
        end

        --Show/Update the Deconstruction/Jewelry deconstruction button at UniversalDeconstruction panel
        addedButtonData = AddButton(
                universalDeconPanelInvControl,
                universalDeconInvTabs:GetName() .. "DeconstructFCOCraftFilterHideBankButton",
                function(...) FCOCraftFilter_CraftingStationUpdateBankItemOption(filterType, true, true) end,
                nil,
                nil,
                "",
                BOTTOM,
                32,
                32,
                xOffset,
                35,
                BOTTOMLEFT,
                TOPLEFT,
                universalDeconInvTabs,
                false
        )
        universalDeconFilterButtons[LF_SMITHING_DECONSTRUCT] = addedButtonData

    --ENCHANTING EXTRACTION
    elseif filterType == LF_ENCHANTING_EXTRACTION then
        --Hide the Deconstruction button at UniversalDeconstruction panel
        local deconstructionButton = universalDeconFilterButtons[LF_SMITHING_DECONSTRUCT]
        if deconstructionButton ~= nil and not deconstructionButton:IsHidden() and deconstructionButton:GetParent() == universalDeconPanelInvControl then
            deconstructionButton:SetHidden(true)
        end

        --Show the enchantment extraction button at UniversalDeconstruction panel
        addedButtonData = AddButton(
                universalDeconPanelInvControl,
                universalDeconInvTabs:GetName() .. "EnchantingExtractFCOCraftFilterHideBankButton",
                function(...) FCOCraftFilter_CraftingStationUpdateBankItemOption(filterType, true, true) end,
                nil,
                nil,
                "",
                BOTTOM,
                32,
                32,
                xOffset,
                35,
                BOTTOMLEFT,
                TOPLEFT,
                universalDeconInvTabs,
                false
        )
        universalDeconFilterButtons[LF_ENCHANTING_EXTRACTION] = addedButtonData
    end

    if addedButtonData ~= nil then
        addedButtonData:SetDrawTier(DT_MEDIUM)
        addedButtonData:SetDrawLayer(DL_CONTROLS)
    end
    return addedButtonData
end

local function FCOCraftFilter_CheckIfDefaultCraftingTabShouldBeSelected(craftSkill)
--d("FCOCraftFilter_CheckIfDefaultCraftingTabShouldBeSelected-craftSkill:" .. tos(craftSkill))
    FCOCF.preventerVars.wasCraftingTableWithoutCraftingTypeRecentlyOpened = false

    local settings = FCOCF.settingsVars.settings
    if not settings.defaultCraftTabDescriptorEnabled then return end
    craftSkill = craftSkill or GetCraftingInteractionType()

    if craftSkill == CRAFTING_TYPE_INVALID then
        if libFilters:IsRetraitStationShown() == true or not zoVars.TRANSMUTATIONSTATION_CONTROL:IsHidden() then
            FCOCF.preventerVars.wasCraftingTableWithoutCraftingTypeRecentlyOpened = false
--d(">retrait")
            setRetraitTabButtonTo(settings.defaultCraftTabDescriptor["retrait"])
        else
            FCOCF.preventerVars.wasCraftingTableWithoutCraftingTypeRecentlyOpened = true
            zo_callLater(function()
                --Check if the retrait station is shown
                if libFilters:IsRetraitStationShown() == true or not zoVars.TRANSMUTATIONSTATION_CONTROL:IsHidden() then
--d(">retrait delayed")
                    FCOCF.preventerVars.wasCraftingTableWithoutCraftingTypeRecentlyOpened = false
                    setRetraitTabButtonTo(settings.defaultCraftTabDescriptor["retrait"])
                end
            end, 50) -- delayed in order to let the retrait panel show properly!
        end
    else
--d(">other crafting type: " ..tos(craftSkill))
        --Others
        setCraftingTabButtonTo(craftSkill, false, settings.defaultCraftTabDescriptor[craftSkill])
    end
end

local function updateRetraitButtons(craftSkill)
    --Set the actual panel to transmutation/retrait
    FCOCF.locVars.gLastPanel = LF_RETRAIT
    FCOCF.locVars.gLastCraftingType = craftSkill
    --Add the button to the retrait station now
    local tooltipVar = ""
    isPerfectPixelEnabled = PP and PP.ADDON_NAME ~= nil
    local xOffset = (isPerfectPixelEnabled == nil and -445) or -425
    AddButton(zoVars.TRANSMUTATIONSTATION_INVENTORY, zoVars.TRANSMUTATIONSTATION_TABS:GetName() .. "RetraitFCOCraftFilterHideBankButton", function(...) FCOCraftFilter_CraftingStationUpdateBankItemOption(LF_RETRAIT, true) end, nil, nil, tooltipVar, BOTTOM, 32, 32, xOffset, 35, BOTTOMLEFT, TOPLEFT, zoVars.TRANSMUTATIONSTATION_TABS, false)
    --Update the filters for the Retrait station now (again)
    FCOCraftFilter_CraftingStationUpdateBankItemOption(LF_RETRAIT, false)
end

--Check if the retrait station is shown and add the button now
local function FCOCraftFilter_CheckIfRetraitStationIsShownAndAddButton(craftSkill)
--d("FCOCraftFilter_CheckIfRetraitStationIsShownAndAddButton-craftSkill:" .. tos(craftSkill))
    if craftSkill == CRAFTING_TYPE_INVALID then

--d(">found retrait: " ..tos(libFilters:IsRetraitStationShown()))
        if libFilters:IsRetraitStationShown() == true then
            updateRetraitButtons(craftSkill)
        else
            zo_callLater(function()
                --Check if the retrait station is shown
                if libFilters:IsRetraitStationShown() or not zoVars.TRANSMUTATIONSTATION_CONTROL:IsHidden() then
                    updateRetraitButtons(craftSkill)
                end
            end, 50) -- delayed in order to let the retrait panel show properly!
        end
    end
end

--Event upon opening a crafting station
local function FCOCraftFilter_OnOpenCrafting(eventCode, craftSkill, sameStation)
    local locVars = FCOCF.locVars
    local lastPanel = locVars.gLastPanel
    --Set crafting station type to invalid if not given (e.g. when coming from the retrait station)
    craftSkill = craftSkill or CRAFTING_TYPE_INVALID
--d("FCOCraftFilter_OnOpenCraftingStation-craftSkill:" .. tos(craftSkill))

    --Hide the ZOs checkbox for "Include banked" and reset it to it's default value
    hideIncludeBankedItemsCheckbox()

    libFilters_IsUniversalDeconstructionPanelShown = libFilters_IsUniversalDeconstructionPanelShown or libFilters.IsUniversalDeconstructionPanelShown
    libFilters_IsUniversalDeconstructionSupportedFilterType = libFilters_IsUniversalDeconstructionSupportedFilterType or libFilters.IsUniversalDeconstructionSupportedFilterType

    --Unregister old filters if the crafting type is unknown
    if locVars.gLastCraftingType == CRAFTING_TYPE_INVALID then
        --and the last panel was the retrait station or an UniversalDeconstruction filterType
        if lastPanel == LF_RETRAIT or libFilters_IsUniversalDeconstructionSupportedFilterType(lastPanel) then
            --d(">RETRAIT: resetting filter for panel: " .. tos(lastPanel))
            FCOCraftFilter_UnregisterFilter(locVars.gLastCraftingType .. "_" .. lastPanel, lastPanel)
        end
    end

    --Remember the current crafting station type
    FCOCF.locVars.gLastCraftingType = craftSkill

    --Remove the filters at the horizontal scroll lists at all crafting tables
    clearResearchPanelCustomFiltersAtAllCraftingTypes()

----d(">FCOCF.locVars.gLastCraftingType: " ..tos(FCOCF.locVars.gLastCraftingType))
    --Is the craftSkill not valid then it could be the retrait station.
    --Check if the retrait station is shown and add the button now
    FCOCraftFilter_CheckIfRetraitStationIsShownAndAddButton(craftSkill)

    --Check if "default" tab selection needs to change the tab
    FCOCraftFilter_CheckIfDefaultCraftingTabShouldBeSelected(craftSkill)
end

--Event upon closing a crafting station
local function FCOCraftFilter_OnCloseCrafting(...)
--d("FCOCraftFilter_OnCloseCraftingStation, gLastCraftingType was reset to NIL")
    FCOCF.preventerVars.wasCraftingTableWithoutCraftingTypeRecentlyOpened = false
    local locVars = FCOCF.locVars
    if locVars.gLastPanel == nil then return false end
    FCOCraftFilter_UnregisterFilter(locVars.gLastCraftingType .. "_" .. locVars.gLastPanel, locVars.gLastPanel)

    --Remove the filters at the horizontal scroll lists at all crafting tables
    clearResearchPanelCustomFiltersAtAllCraftingTypes()

    --Reset the last crafting station type
    FCOCF.locVars.gLastCraftingType = nil
end

-- Fires each time after addons were loaded and player is ready to move (after each zone change too)
local function FCOCraftFilter_Player_Activated(...)
	--Prevent this event to be fired again and again upon each zone change
	EM:UnregisterForEvent(addonName, EVENT_PLAYER_ACTIVATED)

    resetSVIfNecessary()

    --Register the extra filters for AdvancedFilters Subfilterbar refresh function (to hide subfilter buttons as the bag types are filtered)
    if AdvancedFilters ~= nil and AdvancedFilters_RegisterSubfilterbarRefreshFilter ~= nil then
        --Deconstruction
        local subfilterRefreshFilterInformationTable = {
            inventoryType       = {INVENTORY_BACKPACK, INVENTORY_BANK},
            craftingType        = {CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_WOODWORKING},
            filterPanelId       = LF_SMITHING_DECONSTRUCT,
            filterName          = "FCOCraftFilter_Deconstruction",
            callbackFunction    = function(slotData)
                return FCOCraftFilter_FilterCallbackFunction(slotData.bagId, slotData.slotIndex, LF_SMITHING_DECONSTRUCT)
            end,
        }
        AdvancedFilters_RegisterSubfilterbarRefreshFilter(subfilterRefreshFilterInformationTable)
        --Improvement
        subfilterRefreshFilterInformationTable.filterPanelId = LF_SMITHING_IMPROVEMENT
        subfilterRefreshFilterInformationTable.filterName    = "FCOCraftFilter_Improvement"
        AdvancedFilters_RegisterSubfilterbarRefreshFilter(subfilterRefreshFilterInformationTable)
        --Enchanting creation
        subfilterRefreshFilterInformationTable = {
            inventoryType       = {INVENTORY_BACKPACK, INVENTORY_BANK},
            craftingType        = {CRAFTING_TYPE_ENCHANTING},
            filterPanelId       = LF_ENCHANTING_CREATION,
            filterName          = "FCOCraftFilter_Enchanting_Creation",
            callbackFunction    = function(slotData)
                return FCOCraftFilter_FilterCallbackFunction(slotData.bagId, slotData.slotIndex, LF_ENCHANTING_CREATION)
            end,
        }
        AdvancedFilters_RegisterSubfilterbarRefreshFilter(subfilterRefreshFilterInformationTable)
        --Enchanting extraction
        subfilterRefreshFilterInformationTable.filterPanelId = LF_ENCHANTING_EXTRACTION
        subfilterRefreshFilterInformationTable.filterName    = "FCOCraftFilter_Enchanting_Extraction"
        AdvancedFilters_RegisterSubfilterbarRefreshFilter(subfilterRefreshFilterInformationTable)
        --Jewelry deconstruction
        subfilterRefreshFilterInformationTable = {
            inventoryType       = {INVENTORY_BACKPACK, INVENTORY_BANK},
            craftingType        = {CRAFTING_TYPE_JEWELRYCRAFTING},
            filterPanelId       = LF_JEWELRY_DECONSTRUCT,
            filterName          = "FCOCraftFilter_Jewelry_Deconstruction",
            callbackFunction    = function(slotData)
                return FCOCraftFilter_FilterCallbackFunction(slotData.bagId, slotData.slotIndex, LF_JEWELRY_DECONSTRUCT)
            end,
        }
        AdvancedFilters_RegisterSubfilterbarRefreshFilter(subfilterRefreshFilterInformationTable)
        --Jewelry improvement
        subfilterRefreshFilterInformationTable.filterPanelId = LF_JEWELRY_IMPROVEMENT
        subfilterRefreshFilterInformationTable.filterName    = "FCOCraftFilter_Jewelry_Improvement"
        AdvancedFilters_RegisterSubfilterbarRefreshFilter(subfilterRefreshFilterInformationTable)
        --Retrait
        subfilterRefreshFilterInformationTable = {
            inventoryType       = {INVENTORY_BACKPACK, INVENTORY_BANK},
            craftingType        = {CRAFTING_TYPE_INVALID},
            filterPanelId       = LF_RETRAIT,
            filterName          = "FCOCraftFilter_Retrait",
            callbackFunction    = function(slotData)
                return FCOCraftFilter_FilterCallbackFunction(slotData.bagId, slotData.slotIndex, LF_RETRAIT)
            end,
        }
        AdvancedFilters_RegisterSubfilterbarRefreshFilter(subfilterRefreshFilterInformationTable)
    end
end
--==============================================================================
--===== HOOKS BEGIN ============================================================
--==============================================================================
--Hook function for the menu buttons
--PreHook function for the buttons at the top tabs of crafting stations
local function FCOCraftFilter_PreHookButtonHandler(comingFrom, calledBy, isUniversalDeconShown)
    isUniversalDeconShown = isUniversalDeconShown or false
--d("FCOCraftFilter_PreHookButtonHandler, comingFrom: " ..tos(comingFrom) .. ", calledBy: " .. tos(calledBy) .. ", isUniversalDecon: " ..tos(isUniversalDeconShown))
    local settings = FCOCF.settingsVars.settings
    local locVars = FCOCF.locVars
    --This function sometimes is called even if you are not at a crafting table. Why?
    --Implement some checks here in order to abort further handling if not at a crafting station.
    --> if not ZO_CraftingUtils_IsCraftingWindowOpen() or if locVars.gLastCraftingType == nil then return end
    --local localizationVars = FCOCF.localizationVars.FCOCF_loc

    --Disable the medium filters if the settings for the medium filter is disabled
    if not settings.enableMediumFilters then
        if settings.filterApplied[LF_SMITHING_REFINE] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_SMITHING_REFINE] = false
        end
        if settings.filterApplied[LF_SMITHING_DECONSTRUCT] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_SMITHING_DECONSTRUCT] = false
        end
        if settings.filterApplied[LF_SMITHING_IMPROVEMENT] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_SMITHING_IMPROVEMENT] = false
        end
        if settings.filterApplied[LF_SMITHING_RESEARCH] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_SMITHING_RESEARCH] = false
        end
        if settings.filterApplied[LF_SMITHING_RESEARCH_DIALOG] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_SMITHING_RESEARCH_DIALOG] = false
        end
        if settings.filterApplied[LF_JEWELRY_REFINE] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_JEWELRY_REFINE] = false
        end
        if settings.filterApplied[LF_JEWELRY_DECONSTRUCT] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_JEWELRY_DECONSTRUCT] = false
        end
        if settings.filterApplied[LF_JEWELRY_IMPROVEMENT] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_JEWELRY_IMPROVEMENT] = false
        end
        if settings.filterApplied[LF_JEWELRY_RESEARCH] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_JEWELRY_RESEARCH] = false
        end
        if settings.filterApplied[LF_JEWELRY_RESEARCH_DIALOG] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_JEWELRY_RESEARCH_DIALOG] = false
        end
        if settings.filterApplied[LF_ENCHANTING_EXTRACTION] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_ENCHANTING_EXTRACTION] = false
        end
        if settings.filterApplied[LF_ENCHANTING_CREATION] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_ENCHANTING_CREATION] = false
        end
        if settings.filterApplied[LF_RETRAIT] == FCOCF_ONLY_SHOW_BANKED then
            settings.filterApplied[LF_RETRAIT] = false
        end
    end

    --Check the filter buttons and create them if they are not there
    FCOCraftFilter_CheckActivePanel(comingFrom, isUniversalDeconShown)

    --Add the button to the panel so enabling/disabling the option will be fast
    FCOCraftFilter_CraftingStationUpdateBankItemOption(locVars.gLastPanel, false, isUniversalDeconShown)

    --Get the tooltip state text for the button
    local tooltipVar = ""
    local tooltipVarCurrentlyResearched = ""

    --The current crafing type and the filterPanel
    local lastCraftingType = locVars.gLastCraftingType
    local lastPanel = locVars.gLastPanel

--d(">gLastCraftingType: " .. tos(locVars.gLastCraftingType) .. ", gLastPanel: " ..tos(locVars.gLastPanel))

    --1. /EsoUI/Art/Inventory/inventory_tabIcon_items_up.dds
    --2. /esoui/art/mainmenu/menubar_inventory_up.dds
    --  or
    --  /esoui/art/tooltips/icon_bank.dds
    --3. /esoui/art/icons/servicemappins/servicepin_bank.dds

    --local buttonNormalTexture = "/EsoUI/Art/Inventory/inventory_tabIcon_items_up.dds"
    --local buttonClickedTexture = "/esoui/art/mainmenu/menubar_inventory_up.dds"
    --local buttonMediumTexture = "/esoui/art/icons/servicemappins/servicepin_bank.dds"


    isPerfectPixelEnabled = PP and PP.ADDON_NAME ~= nil

    --Add the button to the head line of the crafting station menu
    --DECONSTRUCTION
    local addedButton
    local xExtra = 0

    if isUniversalDeconShown == true then
        addFilterButtonUniversalDecon(comingFrom)
    else
        --local craftingType = GetCraftingInteractionType()

        --REFINE
        if comingFrom == LF_SMITHING_REFINE or comingFrom == LF_JEWELRY_REFINE then
            --Compatibility for addon PerfectPixel
            local xOffset = (isPerfectPixelEnabled == false and -495) or -500
            addedButton = AddButton(zoVars.CRAFTSTATION_SMITHING_REFINEMENT_INVENTORY, zoVars.CRAFTSTATION_SMITHING_REFINEMENT_TABS:GetName() .. "RefinementFCOCraftFilterHideBankButton", function(...) FCOCraftFilter_CraftingStationUpdateBankItemOption(comingFrom, true) end, nil, nil, tooltipVar, BOTTOM,  32, 32, (xOffset + xExtra) , 35, BOTTOMLEFT, TOPLEFT, zoVars.CRAFTSTATION_SMITHING_REFINEMENT_TABS, false)
        --DECONSTRUCTION
        elseif comingFrom == LF_SMITHING_DECONSTRUCT or comingFrom == LF_JEWELRY_DECONSTRUCT then
            --Compatibility for addon PerfectPixel
            local xOffset = (isPerfectPixelEnabled == false and -495) or -465
            addedButton = AddButton(zoVars.CRAFTSTATION_SMITHING_DECONSTRUCTION_INVENTORY, zoVars.CRAFTSTATION_SMITHING_DECONSTRUCTION_TABS:GetName() .. "DeconstructFCOCraftFilterHideBankButton", function(...) FCOCraftFilter_CraftingStationUpdateBankItemOption(comingFrom, true) end, nil, nil, tooltipVar, BOTTOM,  32, 32, (xOffset + xExtra) , 35, BOTTOMLEFT, TOPLEFT, zoVars.CRAFTSTATION_SMITHING_DECONSTRUCTION_TABS, false)
            --IMPROVEMENT
        elseif comingFrom == LF_SMITHING_IMPROVEMENT or comingFrom == LF_JEWELRY_IMPROVEMENT then
            --Compatibility for addon PerfectPixel
            local xOffset = (isPerfectPixelEnabled == false and -495) or -465
            addedButton = AddButton(zoVars.CRAFTSTATION_SMITHING_IMPROVEMENT_INVENTORY, zoVars.CRAFTSTATION_SMITHING_IMPROVEMENT_TABS:GetName() .. "ImproveFCOCraftFilterHideBankButton", function(...) FCOCraftFilter_CraftingStationUpdateBankItemOption(comingFrom, true) end, nil, nil, tooltipVar, BOTTOM,  32, 32, (xOffset + xExtra), 35, BOTTOMLEFT, TOPLEFT, zoVars.CRAFTSTATION_SMITHING_IMPROVEMENT_TABS, false)
            --Research
        elseif comingFrom == LF_SMITHING_RESEARCH or comingFrom == LF_JEWELRY_RESEARCH then
            reanchorResearchControls()
            local xOffset = (isPerfectPixelEnabled == false and -4) or -11
            --Filter banked/inventory/both items button
            addedButton = AddButton(zoVars.CRAFTSTATION_SMITHING_RESEARCH, zoVars.CRAFTSTATION_SMITHING_RESEARCH_TABS:GetName() .. "ResearchFCOCraftFilterHideBankButton", function(...) FCOCraftFilter_CraftingStationUpdateBankItemOption(comingFrom, true) end, nil, nil, tooltipVar, BOTTOM,  32, 32, xOffset, 3, RIGHT, LEFT, zoVars.CRAFTSTATION_SMITHING_RESEARCH_TIMER_ICON, false)

            --Filter currently researched items button
            local showButtonResearchOnlyCurrentlyResearched = settings.showButtonResearchOnlyCurrentlyResearched
            if FCOCF.horizontalScrollListFilterButtons[comingFrom] ~= nil and not showButtonResearchOnlyCurrentlyResearched then
                FCOCF.horizontalScrollListFilterButtons[comingFrom]:SetHidden(true)
            end
            if addedButton ~= nil and showButtonResearchOnlyCurrentlyResearched== true then
                FCOCF.horizontalScrollListFilterButtons[comingFrom] = AddButton(zoVars.CRAFTSTATION_SMITHING_RESEARCH, zoVars.CRAFTSTATION_SMITHING_RESEARCH_TABS:GetName() .. "ResearchFCOCraftFilterHideNotResearchedButton", function(...) toggleCurrentlyResearchedItemsFilter() end, nil, nil, tooltipVarCurrentlyResearched, BOTTOM,  32, 32, -8, 0, TOPRIGHT, TOPLEFT, ZO_SmithingTopLevelResearchPanelResearchLineList, false, false, true)
                FCOCF.horizontalScrollListFilterButtons[comingFrom]:SetHidden(false)
            end

            --Research dialog
        elseif comingFrom == LF_SMITHING_RESEARCH_DIALOG or comingFrom == LF_JEWELRY_RESEARCH_DIALOG then
            addedButton = AddButton(zoVars.RESEARCH_POPUP_TOP_DIVIDER, zoVars.RESEARCH_POPUP_TOP_DIVIDER:GetName() .. "ResearchDialogFCOCraftFilterHideBankButton", function(...) FCOCraftFilter_CraftingStationUpdateBankItemOption(comingFrom, true) end, nil, nil, tooltipVar, BOTTOM,  32, 32, 36, -20, LEFT, LEFT, zoVars.RESEARCH_POPUP_TOP_DIVIDER, false)
            --ENCHANTING CREATION
        elseif comingFrom == LF_ENCHANTING_CREATION then
            local xOffset = (isPerfectPixelEnabled == false and -394) or -394
            --Hide the enchantment extraction button
            AddButton(nil, zoVars.CRAFTSTATION_ENCHANTING_TABS:GetName() .. "ExtFCOCraftFilterHideBankButton", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,nil, nil, nil, true)
            --Show the enchantment creation button
            addedButton = AddButton(zoVars.CRAFTSTATION_ENCHANTING_INVENTORY, zoVars.CRAFTSTATION_ENCHANTING_TABS:GetName() .. "CreationFCOCraftFilterHideBankButton", function(...) FCOCraftFilter_CraftingStationUpdateBankItemOption(LF_ENCHANTING_CREATION, true) end, nil, nil, tooltipVar, BOTTOM,  32, 32, xOffset, 35, BOTTOMLEFT, TOPLEFT, zoVars.CRAFTSTATION_ENCHANTING_TABS, false)
            --ENCHANTING EXTRACTION
        elseif comingFrom == LF_ENCHANTING_EXTRACTION then
            local xOffset = (isPerfectPixelEnabled == false and -505) or -505
            --Hide the enchantment creation button
            AddButton(nil, zoVars.CRAFTSTATION_ENCHANTING_TABS:GetName() .. "CreationFCOCraftFilterHideBankButton", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,nil, nil, nil, true)
            --Show the enchantment extraction button
            addedButton = AddButton(zoVars.CRAFTSTATION_ENCHANTING_INVENTORY, zoVars.CRAFTSTATION_ENCHANTING_TABS:GetName() .. "ExtFCOCraftFilterHideBankButton", function(...) FCOCraftFilter_CraftingStationUpdateBankItemOption(LF_ENCHANTING_EXTRACTION, true) end, nil, nil, tooltipVar, BOTTOM,  32, 32, xOffset, 35, BOTTOMLEFT, TOPLEFT, zoVars.CRAFTSTATION_ENCHANTING_TABS, false)
        --TRANSMUTATION / RETRAIT
        elseif comingFrom == LF_RETRAIT then
            local xOffset = (isPerfectPixelEnabled == false and -445) or -425
            addedButton = AddButton(zoVars.TRANSMUTATIONSTATION_INVENTORY, zoVars.TRANSMUTATIONSTATION_TABS:GetName() .. "RetraitFCOCraftFilterHideBankButton", function(...) FCOCraftFilter_CraftingStationUpdateBankItemOption(LF_RETRAIT, true) end, nil, nil, tooltipVar, BOTTOM,  32, 32, xOffset, 35, BOTTOMLEFT, TOPLEFT, zoVars.TRANSMUTATIONSTATION_TABS, false)
        end
    end

    --Add the created/updated button to the table of added buttons so one can reference and hide them if needed
    if addedButton ~= nil then
        addedButton:SetDrawTier(DT_MEDIUM)
        addedButton:SetDrawLayer(DL_CONTROLS)

        FCOCF.filterButtons[comingFrom] = addedButton
    end
    --Return false to call the normal callback handler of the button afterwards
    return false
end

--Check if UniversalDeconstruction is shown
local function FCOCraftFilter_CheckIfUniversalDeconIsShownAndAddButton(craftSkill, stateStr, universalDeconSelectedTabNow)
--d("[FCOCraftFilter_CheckIfUniversalDeconIsShownAndAddButton]craftSkill: " ..tos(craftSkill) .. ", stateStr: " ..tos(stateStr) .. ", tab: " ..tos(universalDeconSelectedTabNow))
    if craftSkill == FCOCF_CRAFTINGTYPE_UNIVERSAL_DECONSTRUCTION then
        libFilters_getUniversalDeconstructionPanelActiveTabFilterType = libFilters_getUniversalDeconstructionPanelActiveTabFilterType or libFilters.GetUniversalDeconstructionPanelActiveTabFilterType
        local currentUniversalDeconFilterType, universalDeconCurrentTab = libFilters_getUniversalDeconstructionPanelActiveTabFilterType(nil)
        local isUniversalDecon = (currentUniversalDeconFilterType ~= nil and universalDeconCurrentTab ~= nil and universalDeconCurrentTab == universalDeconSelectedTabNow and true) or false
--d(">isUniversalDecon: " ..tos(isUniversalDecon) .. ", currentUniversalDeconFilterType: " ..tos(currentUniversalDeconFilterType) .. ", currentTab: " ..tos(universalDeconCurrentTab))
        if isUniversalDecon == true then
--d(">craftskill changed to UniversalDeconstruction")
            --Set the actual panel to UniversalDeconstruction
            FCOCF.locVars.gLastPanel = currentUniversalDeconFilterType
            FCOCF.locVars.gLastCraftingType = craftSkill

            hideIncludeBankedItemsCheckbox(currentUniversalDeconFilterType, true)

            --Add the button to the UniversalDecon station
            --local isShown = (stateStr == SCENE_SHOWN and true) or false
            FCOCraftFilter_PreHookButtonHandler(currentUniversalDeconFilterType, "UNIVERSAL_DECONSTRUCTION-" .. tos(universalDeconCurrentTab), true)
        end
    end
end


------------------------------------------------------------------------------------------------------------------------
--Create the hooks & pre-hooks
local function FCOCraftFilter_CreateHooks()

    --======== SMITHING =============================================================
    --Master Crafter Set Tables - Create -> Favorites
    FCOCF.HookCrafting_MasterSetCrafterTables_Create()


    --Other
    --[[
        --Prehook the smithing function SetMode() which gets executed as the smithing tabs are changed
        ZO_PreHook(ZO_Smithing, "SetMode", function(smithing_obj, mode)
            --Deconstruction
            if     mode == SMITHING_MODE_DECONSTRUCTION then
                --Deconstruction
                zo_callLater(function()
                    FCOCraftFilter_PreHookButtonHandler(LF_SMITHING_DECONSTRUCT, "SMITHING deconstruct")
                end, 10)
                --Improvement
            elseif mode == SMITHING_MODE_IMPROVEMENT then
                zo_callLater(function()
                    FCOCraftFilter_PreHookButtonHandler(LF_SMITHING_IMPROVEMENT, "SMITHING improvement")
                end, 10)
            end
            --Go on with original function
            return false
        end)
    ]]
    local function smithingSetMode(smithing_obj, mode, ...)
        --d("[FCOCraftFilter]SMITHING.SetMode: " ..tos(mode))
        local craftingType = GetCraftingInteractionType()
        local filterPanelId
        --Refine
        if     mode == SMITHING_MODE_REFINEMENT then
            filterPanelId = LF_SMITHING_REFINE
            --[[
            if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
                filterPanelId = LF_JEWELRY_REFINE
            end
            ]]
            --Detect if the filterType should be switched to jewelry*
            filterPanelId = libFilters:GetFilterTypeRespectingCraftType(filterPanelId, craftingType)
            --Refine
            zo_callLater(function()
                FCOCraftFilter_PreHookButtonHandler(filterPanelId, "SMITHING refine SetMode")
            end, 10)
            --Deconstruction
        elseif     mode == SMITHING_MODE_DECONSTRUCTION then
            filterPanelId = LF_SMITHING_DECONSTRUCT
            --[[
            if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
                filterPanelId = LF_JEWELRY_DECONSTRUCT
            end
            ]]
            --Detect if the filterType should be switched to jewelry*
            filterPanelId = libFilters:GetFilterTypeRespectingCraftType(filterPanelId, craftingType)
            --Deconstruction
            zo_callLater(function()
                FCOCraftFilter_PreHookButtonHandler(filterPanelId, "SMITHING deconstruct SetMode")
            end, 10)
            --Improvement
        elseif mode == SMITHING_MODE_IMPROVEMENT then
            filterPanelId = LF_SMITHING_IMPROVEMENT
            --[[
            if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
                filterPanelId = LF_JEWELRY_IMPROVEMENT
            end
            ]]
            --Detect if the filterType should be switched to jewelry*
            filterPanelId = libFilters:GetFilterTypeRespectingCraftType(filterPanelId, craftingType)
            zo_callLater(function()
                FCOCraftFilter_PreHookButtonHandler(filterPanelId, "SMITHING improvement SetMode")
            end, 10)
            --Research
        elseif mode == SMITHING_MODE_RESEARCH then
            filterPanelId = LF_SMITHING_RESEARCH
            --[[
            if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
                filterPanelId = LF_JEWELRY_RESEARCH
            end
            ]]
            --Detect if the filterType should be switched to jewelry*
            filterPanelId = libFilters:GetFilterTypeRespectingCraftType(filterPanelId, craftingType)
            zo_callLater(function()
                --Adds/Updates the button "show all/banked only/inventory only items" & add/update the horizontal scrollbar "show currently researched only"!
                FCOCraftFilter_PreHookButtonHandler(filterPanelId, "SMITHING research SetMode")
                reanchorResearchControls()
                --Update the horizontal scrollbar filters
                callCurrentlyResearchedItemsFilter()
            end, 10)
            --[[
                    --Research
                    elseif mode == SMITHING_MODE_RESEARCH then
                        local craftingType = GetCraftingInteractionType()
                        local filterPanelId = LF_SMITHING_RESEARCH_DIALOG
                        if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
                            filterPanelId = LF_JEWELRY_RESEARCH_DIALOG
                        end
                        zo_callLater(function()
                            FCOCraftFilter_PreHookButtonHandler(filterPanelId, "SMITHING research")
                        end, 10)
            ]]
        end
        hideIncludeBankedItemsCheckbox(filterPanelId)
        --Go on with original function
        return false
    end
    SecurePostHook(zo_smith, "SetMode", smithingSetMode)

    --======== ENCHANTING ===========================================================
    --[[
        --Prehook the enchanting function SetEnchantingMode() which gets executed as the enchanting tabs are changed
        ZO_PreHook(ZO_Enchanting, "SetEnchantingMode", function(enchanting_obj, enchantingMode)
            --Creation
            if     enchantingMode == ENCHANTING_MODE_CREATION then
                zo_callLater(function()
                    FCOCraftFilter_PreHookButtonHandler(LF_ENCHANTING_CREATION, "ENCHANTING create")
                end, 10)
                --Extraction
            elseif enchantingMode == ENCHANTING_MODE_EXTRACTION then
                zo_callLater(function()
                    FCOCraftFilter_PreHookButtonHandler(LF_ENCHANTING_EXTRACTION, "ENCHANTING extract")
                end, 10)
            end
            --Go on with original function
            return false
        end)
    ]]
    local function enchantingModeChangeFunction(enchantingMode)
        ----d("[FCOCraftFilter]enchantingModeChangeFunction - enchantingMode: " ..tos(enchantingMode))
        --Creation
        local filterPanelId
        if     enchantingMode == ENCHANTING_MODE_CREATION then
            zo_callLater(function()
                filterPanelId = LF_ENCHANTING_CREATION
                FCOCraftFilter_PreHookButtonHandler(filterPanelId, "ENCHANTING create SetEnchantingMode/OnModeUpdate")
                zo_callLater(function() moveQuestOnlyCheckbox(filterPanelId) end, 50)
            end, 10)
            --Extraction
        elseif enchantingMode == ENCHANTING_MODE_EXTRACTION then
            zo_callLater(function()
                filterPanelId = LF_ENCHANTING_EXTRACTION
                FCOCraftFilter_PreHookButtonHandler(filterPanelId, "ENCHANTING extract SetEnchantingMode/OnModeUpdate")
            end, 10)
        end
        hideIncludeBankedItemsCheckbox(filterPanelId)
    end
    --[[
    local enchantingSetEnchantingModeOrig = zo_ench.SetEnchantingMode
    if enchantingSetEnchantingModeOrig ~= nil then
        zo_ench.SetEnchantingMode = function(enchanting_obj, enchantingMode, ...)
            local retVar = enchantingSetEnchantingModeOrig(enchanting_obj, enchantingMode, ...)
            enchantingModeChangeFunction(enchantingMode)
            --Go on with original function
            return retVar
        end
    else
        --ZO_Enchanting:SetEnchantingMode does not exist anymore (PTS -> Scalebreaker) and was replaced by ZO_Enchanting:OnModeUpdated()
        enchantingSetEnchantingModeOrig = zo_ench.OnModeUpdated
        zo_ench.OnModeUpdated = function(self, ...)
            enchantingSetEnchantingModeOrig(self, ...)
            enchantingModeChangeFunction(self.enchantingMode)
        end
    end
    ]]
    SecurePostHook(zo_ench, "OnModeUpdated", function(self) enchantingModeChangeFunction(self.enchantingMode) end)

    --======== RETRAIT ===========================================================
    --Called as the retrait filters are changed (Armor, weapons, jewelry). But it's not called as the retrait station
    --was opened before and is re-opened later on at the same tab + same subfilter :-( (e.g. armor -> shields)
    --THis will be handled via the event EVENT_CRAFTING_STATION_INTERACT
    local function ChangeFilterRetraitPanel (self, filterTab)
        ----d("[FCOCraftFilter]ChangeFilterRetraitPanel - filterTab: " ..tos(filterTab))
        --Set the crafting panel type to none
        FCOCF.locVars.gLastCraftingType = CRAFTING_TYPE_INVALID
        --Update the visible buttons
        local filterPanelId = LF_RETRAIT
        FCOCraftFilter_PreHookButtonHandler(filterPanelId, "RETRAIT changeFilter")
        hideIncludeBankedItemsCheckbox(filterPanelId)
    end
    local retraitPanel = zoVars.TRANSMUTATIONSTATION_RETRAIT_PANEL
    ZO_PreHook(retraitPanel.inventory, "ChangeFilter", ChangeFilterRetraitPanel)

    --========= RESEARCH LIST / ListDialog OnShow/OnHide ======================================================
    local researchPopupDialogCustomControl = ESO_Dialogs["SMITHING_RESEARCH_SELECT"].customControl()
    if researchPopupDialogCustomControl ~= nil then
        ZO_PreHookHandler(researchPopupDialogCustomControl, "OnShow", function()
            --As this OnShow function will be also called for other ZO_ListDialog1 dialogs...
            --Check if we are at the research popup dialog
            if not isResearchListDialogShown() then return false end
            ----d("[FCOCraftFilter]ResearchPopupDialog - OnShow")
            ----d("[FCOCraftFilter]researchPopupDialogCustomControl:OnShow")
            FCOCF.preventerVars.ZO_ListDialog1ResearchIsOpen = true
            --Show filter button at LF_SMITHING_RESEARCH_DIALOG or LF_JEWELRY_RESEARCH_DIALOG
            --Update the visible buttons
            --Check the active crafting type
            local filterPanelId
            local craftingType = GetCraftingInteractionType()
            if craftingType then
                if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
                    filterPanelId = LF_JEWELRY_RESEARCH_DIALOG
                elseif craftingType ~= CRAFTING_TYPE_INVALID and craftingType ~= CRAFTING_TYPE_ENCHANTING then
                    filterPanelId = LF_SMITHING_RESEARCH_DIALOG
                end
            end
            ----d("[FCOCF]researchPopupDialog:OnShow - craftingType: " ..tos(craftingType) .. ", filterPanelId: " ..tos(filterPanelId))
            if filterPanelId then
                hideIncludeBankedItemsCheckbox(filterPanelId)
                FCOCraftFilter_PreHookButtonHandler(filterPanelId, "SMITHING research popup OnShow")
            end
        end)

        ZO_PreHookHandler(researchPopupDialogCustomControl, "OnHide", function()
            --Check if we are at the research popup dialog
            if not FCOCF.preventerVars.ZO_ListDialog1ResearchIsOpen then return false end
            FCOCF.preventerVars.ZO_ListDialog1ResearchIsOpen = false
            ----d("[FCOCraftFilter]researchPopupDialogCustomControl:OnHide")
            --Hide the filter button at LF_SMITHING_RESEARCH_DIALOG or LF_JEWELRY_RESEARCH_DIALOG
            local filterPanelId, filterPanelIdAfterClose
            local craftingType = GetCraftingInteractionType()
            if craftingType then
                if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
                    filterPanelId           = LF_JEWELRY_RESEARCH_DIALOG
                    filterPanelIdAfterClose = LF_JEWELRY_RESEARCH
                elseif craftingType ~= CRAFTING_TYPE_INVALID and craftingType ~= CRAFTING_TYPE_ENCHANTING then
                    filterPanelId           = LF_SMITHING_RESEARCH_DIALOG
                    filterPanelIdAfterClose = LF_SMITHING_RESEARCH
                end
                if filterPanelId then
                    --Hide the button now at the research dialog so it does not show at other dialogs like repair, recharge, enchant, etc.
                    if FCOCF.filterButtons then
                        local buttonToHide = FCOCF.filterButtons[filterPanelId]
                        if buttonToHide ~= nil and buttonToHide.SetHidden ~= nil then
                            buttonToHide:SetHidden(true)
                        end
                    end
                end
                --Reset the current filterPanel to the normal SMITHING or JEWELRY research panel again now
                if filterPanelIdAfterClose then
                    FCOCF.locVars.gLastPanel = filterPanelIdAfterClose
                end
            end
        end)
    end

    --Secure post hook the research function to update the research lists properly and re-register the LibFilters filters after a research was started
    SecurePostHook("ResearchSmithingTrait", function()
        local libFiltersPanelId = LF_SMITHING_RESEARCH
        local craftingType = GetCraftingInteractionType()
        if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
            libFiltersPanelId = LF_JEWELRY_RESEARCH
        end
        if not libFiltersPanelId then return end
        hideIncludeBankedItemsCheckbox(libFiltersPanelId)
        FCOCraftFilter_CraftingStationUpdateBankItemOption(libFiltersPanelId, false)
    end)

    --======== UNIVERSAL DECONSTRUCTION ===========================================================
    --[[
        callbackName,
        filterType,
        stateStr,
        isInGamepadMode,
        fragmentOrSceneOrControl,
        lReferencesToFilterType,
        universalDeconSelectedTabNow
    ]]
    local function libFiltersUniversalDeconShownOrHiddenCallback(isShown, callbackName, filterType, stateStr, isInGamepadMode, fragmentOrSceneOrControl, lReferencesToFilterType, universalDeconSelectedTabNow)
        --d("[UNIVERSAL_DECONSTRUCTION - CALLBACK - " ..tos(callbackName) .. ", state: "..tos(stateStr) .. ", filterType: " ..tos(filterType) ..", isInGamepadMode: " ..tos(isInGamepadMode) .. ", universalDeconSelectedTabNow: " ..tos(universalDeconSelectedTabNow))
        FCOCraftFilter_CheckIfUniversalDeconIsShownAndAddButton(FCOCF_CRAFTINGTYPE_UNIVERSAL_DECONSTRUCTION, stateStr, universalDeconSelectedTabNow)

        --Universal Decon panel shown and crafting table was opened recently?
        if isShown == true and FCOCF.preventerVars.wasCraftingTableWithoutCraftingTypeRecentlyOpened then
            --d(">UniversalDecon panel, and crafting table opened recently!")
            FCOCF.preventerVars.wasCraftingTableWithoutCraftingTypeRecentlyOpened = false
            setCraftingTabButtonTo("universalDeconstruction", true, FCOCF.settingsVars.settings.defaultCraftTabDescriptor["universalDeconstruction"], universalDeconSelectedTabNow)
        elseif not isShown then
            FCOCF.preventerVars.wasCraftingTableWithoutCraftingTypeRecentlyOpened = false
        end
    end
    local callbackNameUniversalDeconDeconAllShown = libFilters:RegisterCallbackName(addonName, LF_SMITHING_DECONSTRUCT, true, nil, "all", "TEST-callback-name-raise-before")
    local callbackNameUniversalDeconDeconAllHidden = libFilters:RegisterCallbackName(addonName, LF_SMITHING_DECONSTRUCT, false, nil, "all")
    CM:RegisterCallback(callbackNameUniversalDeconDeconAllShown, function(...) libFiltersUniversalDeconShownOrHiddenCallback(true, ...) end)
    CM:RegisterCallback(callbackNameUniversalDeconDeconAllHidden, function(...) libFiltersUniversalDeconShownOrHiddenCallback(false, ...) end)
    local callbackNameUniversalDeconDeconArmorShown = libFilters:RegisterCallbackName(addonName, LF_SMITHING_DECONSTRUCT, true, nil, "armor")
    local callbackNameUniversalDeconDeconArmorHidden = libFilters:RegisterCallbackName(addonName, LF_SMITHING_DECONSTRUCT, false, nil, "armor")
    CM:RegisterCallback(callbackNameUniversalDeconDeconArmorShown, function(...) libFiltersUniversalDeconShownOrHiddenCallback(true, ...) end)
    CM:RegisterCallback(callbackNameUniversalDeconDeconArmorHidden, function(...) libFiltersUniversalDeconShownOrHiddenCallback(false, ...) end)
    local callbackNameUniversalDeconDeconWeaponsShown = libFilters:RegisterCallbackName(addonName, LF_SMITHING_DECONSTRUCT, true, nil, "weapons")
    local callbackNameUniversalDeconDeconWeaponsHidden = libFilters:RegisterCallbackName(addonName, LF_SMITHING_DECONSTRUCT, false, nil, "weapons")
    CM:RegisterCallback(callbackNameUniversalDeconDeconWeaponsShown, function(...) libFiltersUniversalDeconShownOrHiddenCallback(true, ...) end)
    CM:RegisterCallback(callbackNameUniversalDeconDeconWeaponsHidden, function(...) libFiltersUniversalDeconShownOrHiddenCallback(false, ...) end)
    local callbackNameUniversalDeconJewelryDeconShown = libFilters:RegisterCallbackName(addonName, LF_JEWELRY_DECONSTRUCT, true, nil, "jewelry")
    local callbackNameUniversalDeconJewelryDeconHidden = libFilters:RegisterCallbackName(addonName, LF_JEWELRY_DECONSTRUCT, false, nil, "jewelry")
    CM:RegisterCallback(callbackNameUniversalDeconJewelryDeconShown, function(...) libFiltersUniversalDeconShownOrHiddenCallback(true, ...) end)
    CM:RegisterCallback(callbackNameUniversalDeconJewelryDeconHidden, function(...) libFiltersUniversalDeconShownOrHiddenCallback(false, ...) end)
    local callbackNameUniversalDeconEnchantingShown = libFilters:RegisterCallbackName(addonName, LF_ENCHANTING_EXTRACTION, true, nil, "enchantments")
    local callbackNameUniversalDeconEnchantingHidden = libFilters:RegisterCallbackName(addonName, LF_ENCHANTING_EXTRACTION, false, nil, "enchantments")
    CM:RegisterCallback(callbackNameUniversalDeconEnchantingShown, function(...) libFiltersUniversalDeconShownOrHiddenCallback(true, ...) end)
    CM:RegisterCallback(callbackNameUniversalDeconEnchantingHidden, function(...) libFiltersUniversalDeconShownOrHiddenCallback(false, ...) end)
end

--Register the slash commands
local function RegisterSlashCommands()
    -- Register slash commands
	SLASH_COMMANDS["/fcocraftfilter"] = command_handler
	SLASH_COMMANDS["/fcocf"] 		  = command_handler
end


--Addon loads up
local function FCOCraftFilter_Loaded(eventCode, addOnName)
	local addonVars = FCOCF.addonVars
    --Is this addon found?
	if(addOnName ~= addonName) then
        return
    end
	--Unregister this event again so it isn't fired again after this addon has beend reckognized
    EM:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

    --Create the filter object for addon libFilters 2.0
    libFilters = LibFilters3
    --Initialize the libFilters filters
    libFilters:InitializeLibFilters()
    libFilters_GetCtrl = libFilters_GetCtrl or libFilters.GetCtrl
    libFilters_IsUniversalDeconstructionSupportedFilterType = libFilters.IsUniversalDeconstructionSupportedFilterType
    libFilters_IsUniversalDeconstructionPanelShown = libFilters_IsUniversalDeconstructionPanelShown or libFilters.IsUniversalDeconstructionPanelShown

    --Update the controls and references needed, based on LibFilters3
    --Smithing
    controlsForChecks.refinementPanel       =  getCorrectCraftingFilterTypeReference(LF_SMITHING_REFINE) --controlsForChecks.smithing.refinementPanel
    controlsForChecks.creationPanel         =  getCorrectCraftingFilterTypeReference(LF_SMITHING_CREATION) --controlsForChecks.smithing.creationPanel
    controlsForChecks.deconstructionPanel   =  getCorrectCraftingFilterTypeReference(LF_SMITHING_DECONSTRUCT) --controlsForChecks.smithing.deconstructionPanel
    controlsForChecks.improvementPanel      =  getCorrectCraftingFilterTypeReference(LF_SMITHING_IMPROVEMENT) --controlsForChecks.smithing.improvementPanel
    controlsForChecks.researchPanel         =  getCorrectCraftingFilterTypeReference(LF_SMITHING_RESEARCH) --controlsForChecks.smithing.researchPanel
    --Enchanting
    controlsForChecks.enchantCreatePanel    =  getCorrectCraftingFilterTypeReference(LF_ENCHANTING_CREATION) --controlsForChecks.enchanting
    controlsForChecks.enchantExtractPanel   =  getCorrectCraftingFilterTypeReference(LF_ENCHANTING_EXTRACTION) --controlsForChecks.enchanting
    --Retrait
    controlsForChecks.retraitPanel          =  getCorrectCraftingFilterTypeReference(LF_RETRAIT) --controlsForChecks.retrait.retraitPanel
    --Universal Deconstruction
    controlsForChecks.universalDeconstruction=  getCorrectCraftingFilterTypeReference(LF_SMITHING_DECONSTRUCT, true) --controlsForChecks.universalDeconstruction.deconstructionPanel

    --The mapping between LibFilters3 panelid and the panel holding the inventory
    craftingTablePanels = {
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
    FCOCF.craftingTablePanels = craftingTablePanels

    --AddOns
    isPerfectPixelEnabled = PP and PP.ADDON_NAME ~= nil

	addonVars.gAddonLoaded = false

    --The default values for the language and save mode
    local defaultsSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide settings
    }

    --Pre-set the deafult values
    local defaults = {
		alwaysUseClientLanguage			= true,
        languageChoosen				    = false,
        filterApplied               = {
            [CRAFTING_TYPE_BLACKSMITHING] = {
                [LF_SMITHING_REFINE]        = FCOCF_SHOW_ALL,
                [LF_SMITHING_DECONSTRUCT]   = FCOCF_SHOW_ALL,
                [LF_SMITHING_IMPROVEMENT]   = FCOCF_SHOW_ALL,
                [LF_SMITHING_RESEARCH]      = FCOCF_SHOW_ALL,
                [LF_SMITHING_RESEARCH_DIALOG]   = FCOCF_SHOW_ALL,
            },
            [CRAFTING_TYPE_CLOTHIER] = {
                [LF_SMITHING_REFINE]        = FCOCF_SHOW_ALL,
                [LF_SMITHING_DECONSTRUCT]   = FCOCF_SHOW_ALL,
                [LF_SMITHING_IMPROVEMENT]   = FCOCF_SHOW_ALL,
                [LF_SMITHING_RESEARCH]      = FCOCF_SHOW_ALL,
                [LF_SMITHING_RESEARCH_DIALOG]   = FCOCF_SHOW_ALL,
            },
            [CRAFTING_TYPE_ENCHANTING] = {
                [LF_ENCHANTING_EXTRACTION] 	= FCOCF_SHOW_ALL,
                [LF_ENCHANTING_CREATION]   	= FCOCF_SHOW_ALL,
            },
            [CRAFTING_TYPE_WOODWORKING] = {
                [LF_SMITHING_REFINE]        = FCOCF_SHOW_ALL,
                [LF_SMITHING_DECONSTRUCT]   = FCOCF_SHOW_ALL,
                [LF_SMITHING_IMPROVEMENT]   = FCOCF_SHOW_ALL,
                [LF_SMITHING_RESEARCH]      = FCOCF_SHOW_ALL,
                [LF_SMITHING_RESEARCH_DIALOG]   = FCOCF_SHOW_ALL,
            },
            [CRAFTING_TYPE_JEWELRYCRAFTING] = {
                [LF_JEWELRY_REFINE]        = FCOCF_SHOW_ALL,
                [LF_JEWELRY_DECONSTRUCT]   = FCOCF_SHOW_ALL,
                [LF_JEWELRY_IMPROVEMENT]   = FCOCF_SHOW_ALL,
                [LF_JEWELRY_RESEARCH]      = FCOCF_SHOW_ALL,
                [LF_JEWELRY_RESEARCH_DIALOG]   = FCOCF_SHOW_ALL,
            },
            [CRAFTING_TYPE_INVALID] = {
                [LF_RETRAIT]                = FCOCF_SHOW_ALL,
            },
            [FCOCF_CRAFTINGTYPE_UNIVERSAL_DECONSTRUCTION] = {
                [LF_SMITHING_DECONSTRUCT]   = FCOCF_SHOW_ALL,
                [LF_JEWELRY_DECONSTRUCT]    = FCOCF_SHOW_ALL,
                [LF_ENCHANTING_EXTRACTION] 	= FCOCF_SHOW_ALL,
            },
        },
        horizontalScrollBarFilterApplied = {
            [CRAFTING_TYPE_BLACKSMITHING] = {
                [LF_SMITHING_RESEARCH]      = false,
            },
            [CRAFTING_TYPE_CLOTHIER] = {
                [LF_SMITHING_RESEARCH]      = false,
            },
            [CRAFTING_TYPE_WOODWORKING] = {
                [LF_SMITHING_RESEARCH]      = false,
            },
            [CRAFTING_TYPE_JEWELRYCRAFTING] = {
                [LF_JEWELRY_RESEARCH]       = false,
            },
        },
        enableMediumFilters             = true,
        showButtonResearchOnlyCurrentlyResearched = false,
        defaultCraftTabDescriptorEnabled = false,
        defaultCraftTabDescriptor = {
            [CRAFTING_TYPE_ALCHEMY] =           -1,
            [CRAFTING_TYPE_BLACKSMITHING] =     -1,
            [CRAFTING_TYPE_CLOTHIER] =          -1,
            [CRAFTING_TYPE_ENCHANTING] =        -1,
            [CRAFTING_TYPE_JEWELRYCRAFTING] =   -1,
            [CRAFTING_TYPE_PROVISIONING] =      -1,
            [CRAFTING_TYPE_WOODWORKING] =       -1,
            ["retrait"] =                       -1,
            ["universalDeconstruction"] =       -1,
        },
        enableMasterCrafterSetsFavorites = false,
        masterCrafterSetsFavoritesEnabled = {},
        masterCrafterSetsFavoritesNames = {},
        masterCrafterSetsFavorites = {},
        enableOnlyWornFilters = false,
        showWornItemsAtOnlyInventory = false,

    }
    for customFavoriteId, _ in pairs(customMasterCrafterSetStationFavoriteIds) do
        defaults.masterCrafterSetsFavorites[customFavoriteId] = {}
        defaults.masterCrafterSetsFavoritesEnabled[customFavoriteId] = true
    end

    FCOCF.settingsVars.defaults = defaults

--=============================================================================================================
--	LOAD USER SETTINGS
--=============================================================================================================
    local worldName = GetWorldName()

    --Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
    FCOCF.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVariablesName, 999, "SettingsForAll", defaultsSettings, worldName)

	--Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
	if (FCOCF.settingsVars.defaultSettings.saveMode == 1) then
        FCOCF.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(addonVars.addonSavedVariablesName, addonVars.addonVersion , "Settings", defaults, worldName)
	else--if (FCOCF.settingsVars.defaultSettings.saveMode == 2) then
        FCOCF.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVariablesName, addonVars.addonVersion, "Settings", defaults, worldName)
	end
--=============================================================================================================

	-- Set Localization
    Localization()

	--Create the hooks
    FCOCraftFilter_CreateHooks()

    --Build the LAM menu
    FCOCF.BuildAddonMenu()

    -- Register slash commands
    RegisterSlashCommands()

    addonVars.gAddonLoaded = true
end


-- Register the event "addon loaded" for this addon
local function FCOCraftFilter_Initialized()
	EM:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, FCOCraftFilter_Loaded)
	--Register for the zone change/player ready event
	EM:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, FCOCraftFilter_Player_Activated)
	--Register the events for crafting stations
	EM:RegisterForEvent(addonName, EVENT_CRAFTING_STATION_INTERACT, function(eventCode, craftSkill, sameStation) FCOCraftFilter_OnOpenCrafting(eventCode, craftSkill, sameStation) end)
    EM:RegisterForEvent(addonName, EVENT_RETRAIT_STATION_INTERACT_START, function(eventCode) FCOCraftFilter_OnOpenCrafting(eventCode) end)
    EM:RegisterForEvent(addonName, EVENT_END_CRAFTING_STATION_INTERACT, FCOCraftFilter_OnCloseCrafting)

    --For debugging: Change the settings and filters of LibFilters via chat /script command
    FCOCF.debugChangeFilter = FCOCraftFilter_CraftingStationUpdateBankItemOption
end

--API function

--Get the active button state
function FCOCF.GetActiveCraftPanelFilterSetting(filterPanelId)
    if filterPanelId == nil then return end
    local locVars = FCOCF.locVars
    local lastCraftingType = locVars.gLastCraftingType
    if lastCraftingType == nil then return end

    local settings = FCOCF.settingsVars.settings
    if not settings then return end

    --Is the "show only bank items" filter enabled?
    ----d("[FCOCF]GetActiveCraftPanelFilterSetting-filterPanelId: " ..tos(filterPanelId).. ", enableMediumFilters: " ..tos(settings.enableMediumFilters) .. ", lastCraftingType: " ..tos(locVars.gLastCraftingType) .. ", currentSetting: " .. tos(settings.filterApplied[locVars.gLastCraftingType][filterPanelId]))
    return settings.filterApplied[locVars.gLastCraftingType][filterPanelId]
end

--Get the filter callback function
function FCOCF.GetFilterCallbackFunction()
    return FCOCraftFilter_FilterCallbackFunction
end


--------------------------------------------------------------------------------
--- Call the start function for this addon to register events etc.
--------------------------------------------------------------------------------
FCOCraftFilter_Initialized()
