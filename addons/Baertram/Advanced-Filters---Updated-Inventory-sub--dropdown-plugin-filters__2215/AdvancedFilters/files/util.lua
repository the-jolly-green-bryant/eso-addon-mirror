AdvancedFilters = AdvancedFilters or {}
local AF = AdvancedFilters

--Utilities
AF.util = AF.util or {}
local util = AF.util
local libFilters = util.LibFilters

local showChatDebug = AF.showChatDebug

local displayName = GetDisplayName()


--Added 202060311: New inventory buy backspace icon needs to be hidden?
local ZO_PlayerInventoryInfoBarBuyBagSpace_Ctrl, ZO_PlayerInventoryInfoBarBuyBagSpace_ParentCtrl
local function hideInventoryCountControls()
    ZO_PlayerInventoryInfoBarBuyBagSpace_Ctrl = ZO_PlayerInventoryInfoBarBuyBagSpace_Ctrl or ZO_PlayerInventoryInfoBarBuyBagSpace
    if ZO_PlayerInventoryInfoBarBuyBagSpace_Ctrl then
        local nextBuyBagSpaceGoldCost = GetNextBackpackUpgradePrice() or 0
        if nextBuyBagSpaceGoldCost <= 0 then
            --Hide - No more bag space can be bought
            ZO_PlayerInventoryInfoBarBuyBagSpace_Ctrl:SetHidden(true)
        else
            --Reanchor and move -> Only if PerfectPixel is not enabled
            if PP then return end
            ZO_PlayerInventoryInfoBarBuyBagSpace_ParentCtrl = ZO_PlayerInventoryInfoBarBuyBagSpace_ParentCtrl or ((ZO_PlayerInventoryInfoBarBuyBagSpace_Ctrl ~= nil and ZO_PlayerInventoryInfoBarBuyBagSpace_Ctrl:GetParent()) or nil)
            if ZO_PlayerInventoryInfoBarBuyBagSpace_ParentCtrl then
                ZO_PlayerInventoryInfoBarBuyBagSpace_Ctrl:ClearAnchors()
                ZO_PlayerInventoryInfoBarBuyBagSpace_Ctrl:SetAnchor(TOPLEFT, ZO_PlayerInventoryInfoBarBuyBagSpace_ParentCtrl, BOTTOMLEFT, 5, -5)
            end
        end
    end
end

--Get the language of the client
function util.GetLanguage()
    local lang = GetCVar("language.2")
    local supported = AF.supportedLanguages
    --check for supported languages
    if(supported[lang] ~= nil) then return lang end

    --return english if not supported
    return "en"
end
local getClientLanguage = util.GetLanguage

local LANG_EN = "en"
local clientLang = getClientLanguage()

local tos = tostring
local strfor = string.format

local controlsForChecks = AF.controlsForChecks
local researchHorizontalScrollList = controlsForChecks.researchLineList

--These variables will get the currentFilter "updated" so need the full path via AF.controlsForChecks!
local companionInv = AF.controlsForChecks.companionInv
local store = AF.controlsForChecks.store
local quickslots = AF.controlsForChecks.quickslot


local checkIfOtherAddonsProvideSubfilterBarRefreshFilters
local isItemFilterTypeInItemFilterData


--local universalDecon = controlsForChecks.universalDecon
--local universalDeconPanel = controlsForChecks.universalDeconPanel
local universalDeconPanelInv = controlsForChecks.universalDeconPanelInv
--local universaldDeconScene = controlsForChecks.universalDeconScene
local subfilterBarInventorytypesOfUniversalDecon = AF.subfilterBarInventorytypesOfUniversalDecon
local universalDeconKeyToAFFilterType = AF.universalDeconKeyToAFFilterType
local universalDeconSelectedTabToActualInventories = AF.universalDeconSelectedTabToActualInventories
local subfilterButtonEntriesNotForDropdownCallback = AF.subfilterButtonEntriesNotForDropdownCallback
local inventorySpecialCurentFilterToCurrentFilter = AF.inventorySpecialCurrentFilterToCurentFilter
local inventoryCurrentFilterToSpecialCurentFilter = AF.inventoryCurrentFilterToSpecialCurentFilter
local inventoryTypeNeedsMappingToCustomAFCurrentFilter = AF.inventoryTypeNeedsMappingToCustomAFCurrentFilter


local detectUniversalDeconstructionPanelActiveTab
local mapAFInvTypeToLibFiltersFilterType
local filterBarParentControlsToHide
local panelIdSupportedAtDeconNPC
local isUniversalDeconPanelShown

--======================================================================================================================
--Other addons
--======================================================================================================================
--FCOCompanion
local junkFunctionsUpdateDone = false
local FCOCompanionJunkEnabled = false

local function checkForOtherAddonFlags()
    --Check if other addons are enabled, like FCO Companion, and if the companion junk is enabled there
    if not junkFunctionsUpdateDone then
        if FCOCO ~= nil and FCOCO.IsCompanionJunkEnabled ~= nil then
            FCOCompanionJunkEnabled = FCOCO.IsCompanionJunkEnabled()
        end
        junkFunctionsUpdateDone = true
    end
    return FCOCompanionJunkEnabled
end
AF.util.CheckForOtherAddonFlags = checkForOtherAddonFlags


--======================================================================================================================
-- -v- Helper functions                                                                                              -v-
--======================================================================================================================
--Variable or function?
function util.getValueOrCallback(arg, ...)
	if type(arg) == "function" then
		return arg(...)
	else
		return arg
	end
end
local getValueOrCallback = util.getValueOrCallback

--Localization helper
function util.Localize(text)
    if type(text) == 'number' then
        -- get the string from this constant
        text = GetString(text)
    end
    -- clean up suffixes such as ^F or ^S
    return zo_strformat(SI_TOOLTIP_ITEM_NAME, text) or " "
end

--Run a function throttled (check if it should run already and overwrite the old call then with a new one to
--prevent running it multiple times in a short time)
function util.ThrottledUpdate(callbackName, timer, callback, ...)
    if not callbackName or callbackName == "" or not callback then return end
    local args
    if ... ~= nil then
        args = {...}
    end
    local function Update()
        if AF.settings.debugSpam then d("--->[AF]ThrottledUpdate, callbackName: " ..tos(callbackName)) end
 --d("--->[AF]ThrottledUpdate, callbackName: " ..tos(callbackName))

        EVENT_MANAGER:UnregisterForUpdate(callbackName)
        if args then
            callback(unpack(args))
        else
            callback()
        end
    end
    EVENT_MANAGER:UnregisterForUpdate(callbackName)
    EVENT_MANAGER:RegisterForUpdate(callbackName, timer, Update)
end
local ThrottledUpdate = util.ThrottledUpdate
--======================================================================================================================
-- -^- Helper functions                                                                                              -^-
--======================================================================================================================


--======================================================================================================================
-- -v- String functions                                                                                           -v-
--======================================================================================================================
--get string information from the calling addon/plugin and insert it into our string table
--and support setmetatable! Use english texts as fallback -> See function AF.util.GetLanguage()
--> Overwrite exisiting strings with data from the same AF plugin strings, if re-apllied, which happens due to different languages and metatables!
-->1st enStrings will be added, after that deStrings etc. Each use the same key
-->A shadow table AF.stringsOfPlugins will be updated here with the keys of each plugin, and if any plugin re-used an existing key an error message will be shown!
AF.pluginStrings = {}
AF.pluginStringKeyToPlugin = {}

local function addStrings(strings, p_filterInformation, p_pluginName)
    if strings == nil then return end
    local pluginName = (p_pluginName or (p_filterInformation ~= nil and (p_filterInformation.pluginName or p_filterInformation.submenuName or (p_filterInformation.callbackTable and p_filterInformation.callbackTable[1] and p_filterInformation.callbackTable[1].name)))) or AF.pluginNameUnknown
    local lang, langStrings

    if p_filterInformation ~= nil then
        lang = clientLang or getClientLanguage()
        langStrings = p_filterInformation[lang .. "Strings"]
    end

--d("[AF]addStrings-name: " ..tostring(pluginName) .. ", lang: " ..tostring(lang))


    --English strings (or generated strings in client language) first
    for key, stringEn in pairs(strings) do

        AF.pluginStrings[pluginName] = AF.pluginStrings[pluginName] or {}
        AF.pluginStrings[pluginName][LANG_EN] = AF.pluginStrings[pluginName][LANG_EN] or {}
        AF.pluginStrings[pluginName][LANG_EN][key] = stringEn

        if AF.strings[key] == nil then
            AF.strings[key] = stringEn

            --Duplicate entry prevention
            AF.pluginStringKeyToPlugin[key] = pluginName
        --[[
        else
            --Check if the same key was defined within another plugin already, and if this is the case: Error!
            local alreadyAddedPluginForKey = AF.pluginStringKeyToPlugin[key]
            if alreadyAddedPluginForKey ~= nil and alreadyAddedPluginForKey ~= pluginName then
                d("[AdvancedFilters]String key \'"..tostring(key) .."\' = \'"..tostring(stringEn).."\' already exist in plugin \'" .. tostring(alreadyAddedPluginForKey).."\'! Please define a unique string key within current plugin: \'" ..tostring(pluginName) .. "\'")
            end
            ]]
        end
    end

    --Client language strings afterwards - If not client lang = English!
    if langStrings ~= nil and lang ~= nil and lang ~= LANG_EN then
        for key, stringOfClientLang in pairs(langStrings) do
            --if AF.strings[key] == nil then --Overwrite with client language!
                AF.strings[key] = stringOfClientLang

                AF.pluginStrings[pluginName] = AF.pluginStrings[pluginName] or {}
                AF.pluginStrings[pluginName][lang] = AF.pluginStrings[pluginName][lang] or {}
                AF.pluginStrings[pluginName][lang][key] = stringOfClientLang

            --[[
            else
                --Check if the same key was defined within another plugin already, and if this is the case: Error!
                local alreadyAddedPluginForKey = AF.pluginStringKeyToPlugin[key]
                if alreadyAddedPluginForKey ~= nil and alreadyAddedPluginForKey ~= pluginName then
                    d("[AdvancedFilters]Client lang \'"..tostring(lang).."\' string key \'"..tostring(key) .."\' = \'"..tostring(stringOfClientLang).."\' already exist in plugin \'" .. tostring(alreadyAddedPluginForKey).."\'! Please define a unique string key within current plugin: \'" ..tostring(pluginName) .. "\'")
                end
                ]]
            --end
        end
    end
end
AF.util.AddStrings = addStrings


--======================================================================================================================
-- -v- Filter plugin functions                                                                                    -v-
--======================================================================================================================
--Slot is the bagId, coming from libFilters, helper function (e.g. deconstruction).
--Prepare the slot variable with bagId and slotIndex
function util.prepareSlot(bagId, slotIndex)
    local slot = {}
    slot.bagId = bagId
    slot.slotIndex = slotIndex
    return slot
end
--======================================================================================================================
-- -^- Filter plugin functions                                                                                    -^-
--======================================================================================================================

--======================================================================================================================
-- -v Itemlink functions                                                                                           -v-
--======================================================================================================================
function util.GetItemLink(slot)
    --Supporrt for AutoCategory AddOn ->
    -- Collapsable headers in the inventories & crafting stations
    if slot == nil or type(slot) ~= "table" or (slot.isHeader ~= nil and slot.isHeader) then return end
    if slot.bagId and slot.slotIndex then
        return GetItemLink(slot.bagId, slot.slotIndex)
    elseif slot.slotIndex and slot.questIndex and slot.toolIndex then
        return GetQuestToolLink(slot.questIndex, slot.toolIndex)
    elseif slot.slotIndex then
        return GetStoreItemLink(slot.slotIndex)
    end
    return
end

--Build an itemlink from an itemId
function util.BuildItemLink(itemId)
    if itemId == nil then return nil end
    return strfor("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", itemId, 364, ITEMSTYLE_NONE, 0, 10000)
end
--======================================================================================================================
-- -^- Itemlink functions                                                                                           -^-
--======================================================================================================================

--======================================================================================================================
-- -v- Crafting helper functions                                                                                    -v-
--======================================================================================================================
--Is the retrait panel shown?
function util.IsRetraitPanelShown()
    return ZO_RETRAIT_STATION_MANAGER:IsRetraitSceneShowing() or false
end
local isRetraitPanelShown = util.IsRetraitPanelShown

--Is any crafting table shown?
function util.IsCraftingPanelShown()
    return (ZO_CraftingUtils_IsCraftingWindowOpen() or isRetraitPanelShown()) or false
end
local isCraftingPanelShown = util.IsCraftingPanelShown

--Get the crafting table of the filterType
function util.GetCraftingTable(filterType)
    if filterType == nil or not isCraftingPanelShown() then return end
    local craftingTables = AF.craftingTables
    local craftingTable = craftingTables[filterType]
    return craftingTable
end
local getCraftingTable = util.GetCraftingTable

--Get the crafting panel of the filterType
function util.GetCraftingTablePanel(filterType, isUniversalDecon)
    if filterType == nil then return end
    libFilters = libFilters or util.LibFilters
    isUniversalDeconPanelShown = isUniversalDeconPanelShown or libFilters.IsUniversalDeconstructionPanelShown
    util.IsUniversalDeconPanelShown = isUniversalDeconPanelShown
    isUniversalDecon = isUniversalDecon or isUniversalDeconPanelShown()

    if not isCraftingPanelShown() and not isUniversalDecon then return end
    local craftingTablePanels = AF.craftingTablePanels
    local craftingPanel = (isUniversalDecon and craftingTablePanels["universalDeconstruction"]) or craftingTablePanels[filterType]
    return craftingPanel
end
local getCraftingTablePanel = util.GetCraftingTablePanel

--Get the crafting panel of the filterType and it's inventory
function util.GetCraftingTablePanelInventory(filterType)
    if filterType == nil or not isCraftingPanelShown() then return end
    local craftingPanel = getCraftingTablePanel(filterType, nil)
    if not craftingPanel then return end
    local craftingInv
    if craftingPanel.inventory then
        craftingInv = craftingPanel.inventory
    else
        --For research panels
        craftingInv = craftingPanel
    end
    return craftingInv
end
local getCraftingTablePanelInventory = util.GetCraftingTablePanelInventory

--Get the crafting panel of the filterType and it's currently selected filterType (e.g. weapons, or armor, or light armor or medium armor, or neck or ring, ...)
function util.GetCraftingTablePanelFilter(filterType)
    if filterType == nil or not isCraftingPanelShown() then return end
    local craftingPanelInv = getCraftingTablePanelInventory(filterType)
    if not craftingPanelInv then return end
    local filterTypeOfCraftingTable
    if craftingPanelInv.filterType then
        filterTypeOfCraftingTable = craftingPanelInv.filterType
    --For research panels
    elseif craftingPanelInv.typeFilter then
        filterTypeOfCraftingTable = craftingPanelInv.typeFilter
    end
    return filterTypeOfCraftingTable
end
local getCraftingTablePanelFilter = util.GetCraftingTablePanelFilter

function util.GetCraftingTablePanelIncludeBankedCheckbox(filterPanelId, isUniversalDecon)
    local ZOsControlNames = AF.ZOsControlNames
    local includeBankedCBoxName = ZOsControlNames.includeBankedCheckbox

    local craftingTablePanel = getCraftingTablePanel(filterPanelId, isUniversalDecon)
    local craftingTablePanelControl = craftingTablePanel and craftingTablePanel.control
    local includeBankedCbox = craftingTablePanelControl and craftingTablePanelControl:GetNamedChild(includeBankedCBoxName)
    local parentCtrl = craftingTablePanelControl
    if not includeBankedCbox then
        local craftingTablePanelInv = getCraftingTablePanelInventory(filterPanelId)
        craftingTablePanelControl =  craftingTablePanelInv and craftingTablePanelInv.control
        includeBankedCbox =  craftingTablePanelControl and craftingTablePanelControl:GetNamedChild(includeBankedCBoxName)
        parentCtrl = craftingTablePanelControl
    end
    local craftTypeDropdownFilterBox
    if isUniversalDecon then
        local craftTypeFilterDDBoxName = ZOsControlNames.craftingTypes
        craftTypeDropdownFilterBox = craftingTablePanelControl and craftingTablePanelControl:GetNamedChild(craftTypeFilterDDBoxName)
    end
    return includeBankedCbox, parentCtrl, craftTypeDropdownFilterBox
end
local getCraftingTablePanelIncludeBankedCheckbox = util.GetCraftingTablePanelIncludeBankedCheckbox

--Get the crafting interaction type
function util.GetCraftingType()
    --[[
        TradeskillType
        CRAFTING_TYPE_ALCHEMY
        CRAFTING_TYPE_BLACKSMITHING
        CRAFTING_TYPE_CLOTHIER
        CRAFTING_TYPE_ENCHANTING
        CRAFTING_TYPE_INVALID
        CRAFTING_TYPE_PROVISIONING
        CRAFTING_TYPE_WOODWORKING
        CRAFTING_TYPE_JEWELRYCRAFTING
    ]]
    return GetCraftingInteractionType() or CRAFTING_TYPE_INVALID
end
local getCraftingType = util.GetCraftingType

--Get the inventory of the craftingPanel in "libFiltersFilterPanelId"
function util.GetInventoryFromCraftingPanel(libFiltersFilterPanelId)
    if libFiltersFilterPanelId == nil then return end
    local craftingPanelInv = getCraftingTablePanelInventory(libFiltersFilterPanelId)
    return craftingPanelInv
end
local getInventoryFromCraftingPanel = util.GetInventoryFromCraftingPanel

--Check if the inventorytype is a crafting station
function util.IsCraftingStationInventoryType(inventoryType)
    local craftingTables = AF.craftingTables
    local retVar = (craftingTables[inventoryType] ~= nil) or false
    return retVar
end
local isCraftingStationInventoryType = util.IsCraftingStationInventoryType

--Is the inventory type a normal LibFilters filterPanelId?
function util.DoesInventoryTypeEqualLibFiltersType(inventoryType)
    local invEqualsLibFilters = AF.invEqualsLibFilters
    local retVar = invEqualsLibFilters[inventoryType] or false
    return retVar
end
local doesInventoryTypeEqualLibFiltersType = util.DoesInventoryTypeEqualLibFiltersType

--Function to return a boolean value if the craftingPanel is using the worn bag ID as well.
--Use the LibFilters filterPanelId as parameter
function util.GetCraftingPanelUsesBagWorn(libFiltersFilterPanelId)
    local craftingFilterPanelId2UsesBagWorn = AF.craftingFilterPanelId2UsesBagWorn
    local usesBagWorn = craftingFilterPanelId2UsesBagWorn[libFiltersFilterPanelId] or false
    return usesBagWorn
end
local getCraftingPanelUsesBagWorn = util.GetCraftingPanelUsesBagWorn

--Clear the custom variables used to filter the horizontal scrolling list entries
function util.ClearResearchPanelCustomFilters(craftingType)
    --d("!!!!! [AF]util.ClearResearchPanelCustomFilters-craftingType: " ..tos(craftingType))
    --Reset the custom data for the loop now
    --[[
    if controlsForChecks.researchPanel and controlsForChecks.researchPanel.LibFilters_3ResearchLineLoopValues then
        controlsForChecks.researchPanel.LibFilters_3ResearchLineLoopValues = nil
    end
    ]]
    libFilters = libFilters or util.LibFilters
    libFilters:UnregisterResearchHorizontalScrollbarFilter("AF_ResearchHorizontalScrollBarFilter", craftingType)
end
local clearResearchPanelCustomFilters = util.ClearResearchPanelCustomFilters

--======================================================================================================================
-- -^- Crafting helper functions                                                                                    -^-
--======================================================================================================================

--======================================================================================================================
-- -v- Companion functions                                                                                           -v-
--======================================================================================================================
function util.IsCompanionInventoryShown()
    local isCompanionInvHidden = controlsForChecks.companionInv.control:IsHidden()
    return not isCompanionInvHidden
end
local isCompanionInventoryShown = util.IsCompanionInventoryShown
--======================================================================================================================
-- -^- Companion functions                                                                                           -^-
--======================================================================================================================


--======================================================================================================================
-- -v- Quickslot filter functions                                                                                  -v-
--======================================================================================================================
--Create the key from the collectibleData table, used as table key in the subfilterBars at LF_QUICKSLOT and used as
--currentFilter key
function util.getAFQuickSlotCollectibleKey(categoryData)
    return AF_QS_PREFIX..categoryData.categoryId .. "_" .. categoryData.categoryIndex .. "_" .. categoryData.categorySpecialization
end
local getAFQuickSlotCollectibleKey = util.getAFQuickSlotCollectibleKey
--======================================================================================================================
-- -^- Inventory filter functions                                                                                  -^-
--======================================================================================================================


--======================================================================================================================
-- -v- Inventory filter functions                                                                                  -v-
--======================================================================================================================
local function getActiveUniversalDeconstructionPanelFilterType(invType)
    libFilters = libFilters or util.LibFilters
    detectUniversalDeconstructionPanelActiveTab = detectUniversalDeconstructionPanelActiveTab or libFilters.DetectUniversalDeconstructionPanelActiveTab
    isUniversalDeconPanelShown                  = isUniversalDeconPanelShown or libFilters.IsUniversalDeconstructionPanelShown
    util.IsUniversalDeconPanelShown = isUniversalDeconPanelShown
    mapAFInvTypeToLibFiltersFilterType     = mapAFInvTypeToLibFiltersFilterType or AF.mapInvTypeToLibFiltersFilterType
    local libFiltersFilterType             = mapAFInvTypeToLibFiltersFilterType[invType]
    local isUniversalDecon = isUniversalDeconPanelShown()
    if isUniversalDecon == true then
        return libFiltersFilterType
    end
    return nil
end
util.IsUniversalDeconPanelShown = isUniversalDeconPanelShown

function util.GetCurrentFilterTypeForInventory(invType, forLibFiltersRegister)
    if invType == nil then return end
    forLibFiltersRegister = forLibFiltersRegister or false
    local filterType
    local curInvType = AF.currentInventoryType
    --Check if a custom inventory filterBar button was added and we are trying to show the subfilterBar etc. for it
    --[[
    if curInvType and util.CheckIfIsCustomAddonInventoryFilterButtonItemFilterType(curInvType) then
        --Used to add/update the subfilterBars of AdvancedFilters at first
        filterType = util.GetCurrentFilter(curInvType)

        --Then check: Used for adding the filters to LibFilters properly?
        --We cannot use the custom itemFilterTypes here as LibFilters does not work with them, and only uses
        --the filter constants LF_*
        --So map the custom itemFilterType to the LibFiltersPanelId here
        if forLibFiltersRegister then
            local libFiltersPanelIdForCustomAddonItemFilterType = util.MapCustomAddonItemFilterType2LibFiltersPanelId(filterType)
            if libFiltersPanelIdForCustomAddonItemFilterType then
                filterType = libFiltersPanelIdForCustomAddonItemFilterType
            end
        end
    else
    ]]
        --Check all other normal inventory types
    if invType == INVENTORY_TYPE_VENDOR_BUY then
        filterType = LF_VENDOR_BUY
    elseif subfilterBarInventorytypesOfUniversalDecon[invType] then
        filterType = getActiveUniversalDeconstructionPanelFilterType(invType)
    elseif isCraftingStationInventoryType(invType) then
        filterType = curInvType
    elseif doesInventoryTypeEqualLibFiltersType(invType) then
        filterType = curInvType
    else
        libFilters = libFilters or util.LibFilters
        filterType = libFilters:GetCurrentFilterTypeForInventory(invType)
    end
    --end
    if AF.settings.debugSpam then  d("[AF]util.GetCurrentFilterTypeForInventory - invType: " ..tos(invType) .. ", filterType: " ..tos(filterType)) end
    return filterType
end
local getCurrentFilterTypeForInventory = util.GetCurrentFilterTypeForInventory

--Some inventoryTypes are special, like the INVENTORY_QUEST_ITEM. If they are met and the currentInventoryType of AF
--differs -> assign the corretc one to the currentInventoryType
function util.CheckSpecialInventoryTypesAndUpdateCurrentInventoryType(inventoryType)
    local debugSpam = AF.settings.debugSpam
    if debugSpam then d("[AF]util.CheckSpecialInventoryTypesAndUpdateCurrentInventoryType - invType: " ..tos(inventoryType)) end
    local specialInventoryTypes = AF.specialInventoryTypes
    if specialInventoryTypes and specialInventoryTypes[inventoryType] == true then
        if debugSpam then d("<<<<<<<<<<<<AF.currentInventoryType changed to " ..tos(inventoryType)) end
        AF.currentInventoryType = inventoryType
    end
end

function util.DoesInventoryTypeNeedsMappingToCustomAFCurrentFilter(invType)
    if invType == nil then return false end
    local needsMapping = (inventoryTypeNeedsMappingToCustomAFCurrentFilter[invType] == true and true) or false
    return needsMapping
end
local doesInventoryTypeNeedsMappingToCustomAFCurrentFilter = util.DoesInventoryTypeNeedsMappingToCustomAFCurrentFilter

function util.GetCurrentFilterOfInventory(invType, invVar, noSpecialInventoryMapping)
    noSpecialInventoryMapping = noSpecialInventoryMapping or false
    local currentFilter = invVar.currentFilter

    if not noSpecialInventoryMapping then
        if doesInventoryTypeNeedsMappingToCustomAFCurrentFilter(invType) then
            if currentFilter ~= nil and inventoryCurrentFilterToSpecialCurentFilter[invType] ~= nil then
                local mappedCurrentFilter = inventoryCurrentFilterToSpecialCurentFilter[invType][currentFilter]
                if mappedCurrentFilter ~= nil then
                    currentFilter = getValueOrCallback(mappedCurrentFilter)
                end
            end
        end
    end
    return currentFilter
end
local getCurrentFilterOfInventory = util.GetCurrentFilterOfInventory

function util.SetCurrentFilterOfInventory(invVar, invType, currentFilter)
    if not invVar or not invType or not invVar.inventories[invType] then
        if AF.settings.debugSpam then df("<<ABORT[AF]util.UpdateCurrentFilter - invType %q missing in PLAYER_INVENTORY.inventories! CurrentFilter: %s", tostring(invType), tostring(currentFilter)) end
        return false
    end
    if doesInventoryTypeNeedsMappingToCustomAFCurrentFilter(invType) then
        --Check if the currentFilter needs to be mappd back from AF* special iventory filtertype to ZOs vanilla inventory filter/display type:
        if currentFilter ~= nil and inventorySpecialCurentFilterToCurrentFilter[invType] ~= nil then
            local mappedCurrentFilter = inventorySpecialCurentFilterToCurrentFilter[invType][currentFilter]
            if mappedCurrentFilter ~= nil then
                currentFilter = getValueOrCallback(mappedCurrentFilter)
            end
        end
    end
    invVar.inventories[invType].currentFilter = currentFilter
end
local setCurrentFilterOfInventory = util.SetCurrentFilterOfInventory

--Get the currentFilter of an inventory type
function util.GetCurrentFilter(invType, noSpecialInventoryMapping, currentFilterBefore)
--d("[AF]util.GetCurrentFilter-invType: " ..tos(invType))
    if not invType then return end
    local currentFilter

    --Crafting
    local isCraftingInventoryType = false
    --local craftingType = getCraftingType()
    --local subfilterBarBase = util.GetSubfilterBar(invType, craftingType)
    if AF.settings.debugSpam then d("[AF]util.GetCurrentFilter-invType: " ..tos(invType) ..", currentFilterBefore: " ..tos(currentFilterBefore) ..", noSpecialInventoryMapping: " ..tos(noSpecialInventoryMapping)) end
    local subfilterBar = util.GetActiveSubfilterBar(invType)
    local subfilterBarInvType
    if isCraftingPanelShown() and subfilterBar then
        subfilterBarInvType = subfilterBar.inventoryType
        isCraftingInventoryType = isCraftingStationInventoryType(subfilterBarInvType)
    end

    if invType == INVENTORY_TYPE_VENDOR_BUY then
        currentFilter = controlsForChecks.store.currentFilter
    elseif subfilterBarInventorytypesOfUniversalDecon[invType] then
        --[[
        local key = universalDeconPanelInv:GetCurrentFilter().key
        currentFilter = universalDeconKeyToAFFilterType[key]
        ]]
        currentFilter = universalDeconPanelInv.AF_currentFilter
--d(">util.GetCurrentFilter: " ..tos(currentFilter))

    elseif isCraftingInventoryType then
        local craftingInv = subfilterBar and getInventoryFromCraftingPanel(subfilterBarInvType)
--d(">IsCraftingInv of subfilterBar: " ..tos(craftingInv) .. ", invType: " ..tos(invType))
        if not craftingInv then return currentFilterBefore end
        currentFilter = craftingInv.currentFilter
    elseif invType == LF_INVENTORY_COMPANION then
        --CurrentFilter is a table
        currentFilter = companionInv.currentFilter.descriptor
    else
        --Get the player inventory for the inventory type
        local playerInvVar = controlsForChecks.playerInv
        local playerInv = playerInvVar.inventories[invType]
        if not playerInv then return currentFilterBefore end

        --Get the currentFilter of the inventory but see if needs a mapping (e.g. Craftbag's "Misc" tab -> to another
        currentFilter = getCurrentFilterOfInventory(invType, playerInv, noSpecialInventoryMapping)
        if not currentFilter then return currentFilterBefore end
    end
--d(">currentFilter now: " ..tos(currentFilter))
    return currentFilter or currentFilterBefore
end
local getCurrentFilter = util.GetCurrentFilter

function util.GetInvTypeCurrentQuickslotFilter(invType, currentFilter)
    local currentFilterToUse
    --Quickslot
    if invType == LF_QUICKSLOT then
        --The currentFilter is a table containing a descriptor which is an itemtype, or there exists another
        --subtable extraInfo with a collectible category id etc.
        if type(currentFilter) == "table" then
            if currentFilter.extraInfo ~= nil then
                currentFilterToUse = getAFQuickSlotCollectibleKey(currentFilter.extraInfo)
            --MerQuickslotFilters support
            elseif currentFilter.merQuickslotFiltersItemTypes ~= nil then
                currentFilterToUse = ITEM_TYPE_DISPLAY_CATEGORY_ALL
            else
                --Use the descriptor as currentFilter
                if currentFilter.descriptor ~= ITEM_TYPE_DISPLAY_CATEGORY_ALL then
                    currentFilterToUse = AF_QS_PREFIX .. currentFilter.descriptor
                else
                    currentFilterToUse = currentFilter.descriptor
                end
            end
        else
            --Not supported
            return
        end
    end
    return currentFilterToUse
end

--Update the currentFilter to the current inventory or crafting inventory
function util.UpdateCurrentFilter(invType, currentFilter, isCraftingInventoryType, craftingInv, currentFilterToUse)
    if AF.settings.debugSpam then d("[AF]util.UpdateCurrentFilter - invType: " .. tos(invType) .. ", currentFilter: " ..tos(currentFilter).. ", isCraftingInventoryType: " ..tos(isCraftingInventoryType) .. ", currentFilterToUse: " ..tos(currentFilterToUse)) end
    if invType == nil or currentFilter == nil then return nil end
    isCraftingInventoryType = isCraftingInventoryType or false
    if isCraftingInventoryType and craftingInv == nil then
        if AF.settings.debugSpam then d("<<ABORT[AF]util.UpdateCurrentFilter - is crafting but craftingInv var missing!") end
        return false
    end
    --set currentFilter since we need it before the original ChangeFilter updates it
    if invType == INVENTORY_TYPE_VENDOR_BUY then
        --Map the currentfilter, containing the
        --local currentFilterForVendorBuy =
        store.currentFilter = currentFilter
    elseif subfilterBarInventorytypesOfUniversalDecon[invType] then
        universalDeconPanelInv.AF_currentFilter = currentFilter
--d(">updated universalInv.AF_currentFilter: " .. tos(currentFilter))
    elseif isCraftingInventoryType then
        craftingInv.currentFilter = currentFilter
    elseif invType == LF_QUICKSLOT then
        --CurrentFilter is a table
        --currentFilterToUse = currentFilterToUse or util.GetInvTypeCurrentQuickslotFilter(invType, currentFilter)
        quickslots.currentFilter = currentFilter
    elseif invType == LF_INVENTORY_COMPANION then
        --CurrentFilter is a table
        companionInv.currentFilter.descriptor = currentFilter
    else
        local playerInvVar = controlsForChecks.playerInv
        --playerInvVar.inventories[invType].currentFilter = currentFilter
        --Check if the currentFilter needs a mapping back from AF* special to normal ZOs item filter/display type
        setCurrentFilterOfInventory(playerInvVar, invType, currentFilter)
    end
end

--Get the current inventory filterBar button's data
function AF.util.GetActiveInventoryFilterBarButtonData(invType)
    if AF.settings.debugSpam then d("[AF]GetActiveInventoryFilterBarButtonData-invType: "..tos(invType)) end
    if not invType then return end
    local playerInvVar = controlsForChecks.playerInv
    local playerInv = playerInvVar.inventories[invType]
    if not playerInv then return end
    local filterBar = playerInv.filterBar
    if not filterBar then return end
    local currentlySelectedInventoryFilterBarButton = filterBar.m_object.m_clickedButton
    return currentlySelectedInventoryFilterBarButton
end
--======================================================================================================================
-- -^- Inventory filter functions                                                                                  -^-
--======================================================================================================================


--======================================================================================================================
-- -v- Inventory layout functions                                                                                  -v-
--======================================================================================================================
function util.GetAlternativeInventoryLayoutData(filterType)
--d("[AF]util.GetAlternativeInventoryLayoutData - filterType: " ..tos(filterType))
    local filterBarInventoryLayoutData = AF.filterBarAlternativeInventoryLayoutData
    return filterBarInventoryLayoutData[filterType]
end

function util.HideInventoryControls(filterType, delay)
    delay = delay or 0
    filterBarParentControlsToHide = filterBarParentControlsToHide or AF.filterBarParentControlsToHide
    libFilters = libFilters or util.LibFilters
    panelIdSupportedAtDeconNPC = panelIdSupportedAtDeconNPC or libFilters.mapping.universalDeconLibFiltersFilterTypeSupported
    AF.panelIdSupportedAtDeconNPC = panelIdSupportedAtDeconNPC

    zo_callLater(function()
        filterType = filterType or getCurrentFilterTypeForInventory(AF.currentInventoryType)
        isUniversalDeconPanelShown = isUniversalDeconPanelShown or libFilters.IsUniversalDeconstructionPanelShown
        util.IsUniversalDeconPanelShown = isUniversalDeconPanelShown
        local isUniversalDecon = isUniversalDeconPanelShown()

--d("[AF]util.HideInventoryControls - filterType: " ..tos(filterType).. ", delay: " ..tos(delay) .. ", isUniversalDecon: " ..tos(isUniversalDecon))
        local controlsToHide = filterBarParentControlsToHide[filterType]

        local function doHideNow(controlToHide)
--d(">Trying to hide: " .. tos(controlToHide:GetName()))
            if controlToHide.IsHidden and not controlToHide:IsHidden() and controlToHide.SetHidden then
                controlToHide:SetHidden(true)
--d(">>hidden")
                --d(">>hidden!")
                --else
                --d("<<was already hidden!")
            end
        end

        local function hideControlsNow(p_controlsToHide)
            for idxOrName, controlToHide in pairs(p_controlsToHide) do
--d(">>idxOrName: " ..tos(idxOrName))
                if controlToHide ~= nil then
                    if AF.settings.debugSpam then if controlToHide.GetName then d(">Trying to hide idx: " ..tos(idxOrName) .." = " .. tos(controlToHide:GetName())) end end
                    if not isUniversalDecon then
                        doHideNow(controlToHide)
                    else
                        if idxOrName == "universalDeconstruction" then
                            doHideNow(controlToHide)
                        end
                    end
                    --else
                    --d("<control as not found")
                end
            end
        end

        --Hide the controls now
        if controlsToHide then
            hideControlsNow(controlsToHide)
        end
    end, delay)
end
--======================================================================================================================
-- -^- Inventory layout functions                                                                                  -^-
--======================================================================================================================


--======================================================================================================================
-- -v- Mapping functions                                                                                            -v-
--======================================================================================================================
--Map the groupName to it's filterType
function util.MapGroupNameToFilterType(groupName)
    if not groupName then return end
    local filterTypeNames = AF.filterTypeNames
    if not filterTypeNames then return end
    for filterType, groupNameToCompare in pairs(filterTypeNames) do
        if groupNameToCompare == groupName then
            return filterType
        end
    end
    return
end

function util.MapLibFiltersInventoryTypeToRealInventoryType(inventoryType)
    --One Libfilters inventoryType can have up to 4 different real inventory types:
    --e.g. Crafting deconstruction can happen for bagpack, bank and house_bank items
    -- whereas crafting creation can use bagpack, bank, house_bank and craftabg items, etc.
    if inventoryType == nil then return nil end
    local mapLibFiltersInvToRealInvType1 = {
        [LF_RETRAIT]                = INVENTORY_BACKPACK,
        [LF_SMITHING_REFINE]        = INVENTORY_BACKPACK,
        [LF_SMITHING_CREATION]      = INVENTORY_BACKPACK,
        [LF_SMITHING_DECONSTRUCT]   = INVENTORY_BACKPACK,
        [LF_SMITHING_IMPROVEMENT]   = INVENTORY_BACKPACK,
        [LF_SMITHING_RESEARCH]      = INVENTORY_BACKPACK,
        [LF_ENCHANTING_CREATION]    = INVENTORY_BACKPACK,
        [LF_ENCHANTING_EXTRACTION]  = INVENTORY_BACKPACK,
        [LF_JEWELRY_REFINE]         = INVENTORY_BACKPACK,
        [LF_JEWELRY_CREATION]       = INVENTORY_BACKPACK,
        [LF_JEWELRY_DECONSTRUCT]    = INVENTORY_BACKPACK,
        [LF_JEWELRY_IMPROVEMENT]    = INVENTORY_BACKPACK,
        [LF_JEWELRY_IMPROVEMENT]    = INVENTORY_BACKPACK,
        [LF_JEWELRY_RESEARCH]       = INVENTORY_BACKPACK,
        [LF_INVENTORY_COMPANION]    = INVENTORY_BACKPACK,
        [LF_INVENTORY_VENGEANCE]    = INVENTORY_VENGEANCE,
    }
    local mapLibFiltersInvToRealInvType2 = {
        [LF_RETRAIT]                = INVENTORY_BANK,
        [LF_SMITHING_REFINE]        = INVENTORY_BANK,
        [LF_SMITHING_CREATION]      = INVENTORY_BACKPACK,
        [LF_SMITHING_DECONSTRUCT]   = INVENTORY_BANK,
        [LF_SMITHING_IMPROVEMENT]   = INVENTORY_BANK,
        [LF_SMITHING_RESEARCH]      = INVENTORY_BANK,
        [LF_ENCHANTING_CREATION]    = INVENTORY_BANK,
        [LF_ENCHANTING_EXTRACTION]  = INVENTORY_BANK,
        [LF_JEWELRY_REFINE]         = INVENTORY_BANK,
        [LF_JEWELRY_CREATION]       = INVENTORY_BANK,
        [LF_JEWELRY_DECONSTRUCT]    = INVENTORY_BANK,
        [LF_JEWELRY_IMPROVEMENT]    = INVENTORY_BANK,
        [LF_JEWELRY_RESEARCH]       = INVENTORY_BANK,
        --[LF_INVENTORY_VENGEANCE]    = INVENTORY_BACKPACK,
    }
    local mapLibFiltersInvToRealInvType3 = {
        [LF_RETRAIT]                = INVENTORY_HOUSE_BANK,
        [LF_SMITHING_REFINE]        = INVENTORY_HOUSE_BANK,
        [LF_SMITHING_CREATION]      = INVENTORY_BACKPACK,
        [LF_SMITHING_DECONSTRUCT]   = INVENTORY_HOUSE_BANK,
        [LF_SMITHING_IMPROVEMENT]   = INVENTORY_HOUSE_BANK,
        [LF_ENCHANTING_CREATION]    = INVENTORY_HOUSE_BANK,
        [LF_ENCHANTING_EXTRACTION]  = INVENTORY_HOUSE_BANK,
        [LF_JEWELRY_REFINE]         = INVENTORY_HOUSE_BANK,
        [LF_JEWELRY_CREATION]       = INVENTORY_HOUSE_BANK,
        [LF_JEWELRY_DECONSTRUCT]    = INVENTORY_HOUSE_BANK,
        [LF_JEWELRY_IMPROVEMENT]    = INVENTORY_HOUSE_BANK,
    }
    local mapLibFiltersInvToRealInvType4 = {
        [LF_SMITHING_REFINE]        = INVENTORY_CRAFT_BAG,
        [LF_SMITHING_CREATION]      = INVENTORY_CRAFT_BAG,
        [LF_ENCHANTING_CREATION]    = INVENTORY_CRAFT_BAG,
        [LF_JEWELRY_REFINE]         = INVENTORY_CRAFT_BAG,
        [LF_JEWELRY_CREATION]       = INVENTORY_CRAFT_BAG,
    }
    local realInvType1 = mapLibFiltersInvToRealInvType1[inventoryType] or nil
    local realInvType2 = mapLibFiltersInvToRealInvType2[inventoryType] or nil
    local realInvType3 = mapLibFiltersInvToRealInvType3[inventoryType] or nil
    local realInvType4 = mapLibFiltersInvToRealInvType4[inventoryType] or nil
    local realInvTypes
    if realInvType1 ~= nil then realInvTypes = realInvTypes or {} table.insert(realInvTypes, realInvType1) end
    if realInvType2 ~= nil then realInvTypes = realInvTypes or {} table.insert(realInvTypes, realInvType2) end
    if realInvType3 ~= nil then realInvTypes = realInvTypes or {} table.insert(realInvTypes, realInvType3) end
    if realInvType4 ~= nil then realInvTypes = realInvTypes or {} table.insert(realInvTypes, realInvType4) end
    return realInvTypes
end
local mapLibFiltersInventoryTypeToRealInventoryType = util.MapLibFiltersInventoryTypeToRealInventoryType


function util.MapUniversalDeconTabKeyToRealInventoryTypes(tabKey)
    if tabKey == nil then return nil end
    return universalDeconSelectedTabToActualInventories[tabKey]
end
--[[
function util.MapUniversalDeconTabKeyToRealInventoryTypes(tabKey)
    if tabKey == nil then return nil end
    local mapLibFiltersInvToRealInvType1 = {
        ["all"]          = INVENTORY_BACKPACK,
        ["weapons"]      = INVENTORY_BACKPACK,
        ["armor"]        = INVENTORY_BACKPACK,
        ["jewelry"]      = INVENTORY_BACKPACK,
        ["enchantments"] = INVENTORY_BACKPACK,
    }
    local mapLibFiltersInvToRealInvType2 = {
        ["all"]          = INVENTORY_BANK,
        ["weapons"]      = INVENTORY_BANK,
        ["armor"]        = INVENTORY_BANK,
        ["jewelry"]      = INVENTORY_BANK,
        ["enchantments"] = INVENTORY_BANK,
    }
    local mapLibFiltersInvToRealInvType3 = {
        ["all"]          = INVENTORY_HOUSE_BANK,
        ["weapons"]      = INVENTORY_HOUSE_BANK,
        ["armor"]        = INVENTORY_HOUSE_BANK,
        ["jewelry"]      = INVENTORY_HOUSE_BANK,
        ["enchantments"] = INVENTORY_HOUSE_BANK,
    }
    local realInvType1 = mapLibFiltersInvToRealInvType1[tabKey] or nil
    local realInvType2 = mapLibFiltersInvToRealInvType2[tabKey] or nil
    local realInvType3 = mapLibFiltersInvToRealInvType3[tabKey] or nil
    local realInvTypes
    if realInvType1 ~= nil then realInvTypes = realInvTypes or {} table.insert(realInvTypes, realInvType1) end
    if realInvType2 ~= nil then realInvTypes = realInvTypes or {} table.insert(realInvTypes, realInvType2) end
    if realInvType3 ~= nil then realInvTypes = realInvTypes or {} table.insert(realInvTypes, realInvType3) end
    return realInvTypes
end
]]
local mapUniversalDeconTabKeyToRealInventoryTypes = util.MapUniversalDeconTabKeyToRealInventoryTypes
--======================================================================================================================
-- -^- Mapping functions                                                                                            -^-
--======================================================================================================================

--======================================================================================================================
-- -v- Dropdown box functions                                                                                       -v-
--======================================================================================================================
--Check if the current panel should show the dropdown "addon filters" for "all" too
function util.checkIfPanelShouldShowAddonAllDropdownFilters(invType)
    if AF.settings.debugSpam then
        --d("[AF]checkIfPanelShouldShowAddonAllDropdownFilters - invType: " .. tos(invType))
    end
    if invType == nil then return true end
    local inv2ShowAddonAllDropdownFilters = {
        [LF_ENCHANTING_CREATION]    = false,
        [LF_ENCHANTING_EXTRACTION]  = false,
        --[LF_SMITHING_REFINE]        = false,
        [LF_SMITHING_CREATION]      = false,
        [LF_JEWELRY_CREATION]       = false,
    }
    local showAtInv = true
    if inv2ShowAddonAllDropdownFilters[invType] ~= nil then
        showAtInv = inv2ShowAddonAllDropdownFilters[invType]
    end
    return showAtInv
end
local checkIfPanelShouldShowAddonAllDropdownFilters = util.checkIfPanelShouldShowAddonAllDropdownFilters


--Map different subfilterNames to one combined, e.g. te group Armor->subfilters LightArmor, Medium, Heavy, Clothing -> Body
function util.MapMultipleGroupSubfiltersToCombinedSubfilter(filterType, subFilterName)
    if not subfilterButtonEntriesNotForDropdownCallback then return end
    local dataForFilterType = subfilterButtonEntriesNotForDropdownCallback[filterType]
    if not dataForFilterType then return end
    local doNotAdd = dataForFilterType["doNotAdd"]
    local replaceWith = dataForFilterType["replaceWith"]
    if not doNotAdd or not replaceWith then return end
    for _, subfilterNameToReplace in ipairs(doNotAdd) do
        if subfilterNameToReplace == subFilterName then
            return replaceWith
        end
    end
    return
end
local mapMultipleGroupSubfiltersToCombinedSubfilter = util.MapMultipleGroupSubfiltersToCombinedSubfilter

function util.MapArmorGroupSubfiltersToBodySubfilter(groupName , subFilterName)
    local returnSubfilterName = subFilterName
    if groupName == "Armor" then
        local replaceSubFilterName = mapMultipleGroupSubfiltersToCombinedSubfilter(ITEM_TYPE_DISPLAY_CATEGORY_ARMOR, subFilterName)
        if replaceSubFilterName ~= nil and replaceSubFilterName ~= subFilterName then
            returnSubfilterName = replaceSubFilterName
        end
    end
    return returnSubfilterName
end
local mapArmorGroupSubfiltersToBodySubfilter = util.MapArmorGroupSubfiltersToBodySubfilter


--Build the subfilterBar's dropdown box filter callback tables and functions
function util.BuildDropdownCallbacks(groupName, subfilterName)
    local settings = AF.settings
    local debugSpam = settings.debugSpam
    local debugSpamExcludeDropdownBoxFilters = settings.debugSpamExcludeDropdownBoxFilters

    --todo: For debugging
    --debugSpam = true
    --debugSpamExcludeDropdownBoxFilters = false

    local subfilterNameOrig = subfilterName

    --Map the armor subfilterNames like "Light", "Heavy" etc, to the "Body" subfilterName. See Constants.lua -> table subfilterButtonEntriesNotForDropdownCallback[ITEM_TYPE_DISPLAY_CATEGORY_ARMOR]
    subfilterName = mapArmorGroupSubfiltersToBodySubfilter(groupName , subfilterName)

    if debugSpam then d("=========================\n[AF]]BuildDropdownCallbacks - groupName: " .. tos(groupName) .. ", subfilterName: " .. tos(subfilterName) .. ", subFilterNameOrig: " ..tos(subfilterNameOrig) .. ", AF.currentInventoryType: " ..tos(AF.currentInventoryType)) end
    local callbackTable = {}
    local keys = AF.dropdownCallbackKeys
    local craftBagFilterGroups = AF.craftBagFilterGroups
    local subfilterCallbacks = AF.subfilterCallbacks
    local invOrFilterType = getCurrentFilterTypeForInventory(AF.currentInventoryType)

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
   local function makeAddonDropdownFiltersCompatible(callbackEntry, currentAddonName)
        --Backwards compatibility: Addons using LibCustomMenu's "header" constant (itemType=MENU_ADD_OPTION_HEADER) to add a header to the dropdown callbacks
        --will get that changed here to the new LibScrollingMenu isHeader=true tag
        if callbackEntry.itemType ~= nil then
            if callbackEntry.itemType == MENU_ADD_OPTION_HEADER then
                callbackEntry.isHeader = true
--d(">Switched LCM header->LSM isHeader - addon: " ..tos(currentAddonName) .. ", name: " .. callbackEntry.name)
            end
        end
        return callbackEntry
    end
    ------------------------------------------------------------------------------------------------------------------------------------


    --Recursively check the addonTable's callbackTable for nestedSubmenus and add the names in that callback entries
    --plus the normal submenuName, plus normal callback entry names to the compare table
    --> The compare table will then be checked against entries in the dropdown filter box so no duplicates will be added again
    local maxRecursivelyCallsInLoop = 100
    local preventEndlessLoopDuplicateCallbackEntryNames = false
    local preventEndlessLoopDuplicateCallbackEntryNamesCounter = 0
    local function recursivelyCheckDuplicateAddonFilterCallbackEntryNames(p_addonTable, p_compareNames)
--d("[AF]recursivelyCheckDuplicateAddonFilterCallbackEntryNames - EntryCount: " .. tos(p_compareNames ~= nil and #p_compareNames or 0) .. ", endlessLoopCounter: " ..tos(preventEndlessLoopDuplicateCallbackEntryNamesCounter))
        --Prevent the recursively submenu checks to do more than 100 loops
        preventEndlessLoopDuplicateCallbackEntryNamesCounter = preventEndlessLoopDuplicateCallbackEntryNamesCounter + 1
        if preventEndlessLoopDuplicateCallbackEntryNames == true and preventEndlessLoopDuplicateCallbackEntryNamesCounter >= maxRecursivelyCallsInLoop then
            return
        end
        if p_addonTable == nil or p_compareNames == nil then return end

        --Any submenu name provided? Add it to the compareNames table
        if p_addonTable.submenuName then
            table.insert(p_compareNames, p_addonTable.submenuName)
        end
        --Any callbackTable provided (if not it should error before already)
        if p_addonTable.callbackTable then
            for _, callbackTableNameEntry in ipairs(p_addonTable.callbackTable) do
                --Do we have any nestedSubmenuEntries?
                --Recursively check the nestedSubmenuEntries callbackTable for next names and maybe oher nested submenuEntries
                if callbackTableNameEntry.nestedSubmenuEntries ~= nil then
--d(">Found nestedSubmenuEntries in callback entries table")
                    preventEndlessLoopDuplicateCallbackEntryNames = true
                    recursivelyCheckDuplicateAddonFilterCallbackEntryNames(callbackTableNameEntry.nestedSubmenuEntries, p_compareNames)
                else
                    --No nested submenu entries, just add the normal callback entry names
                    table.insert(p_compareNames, callbackTableNameEntry.name)
                end
            end
        end
    end
    ------------------------------------------------------------------------------------------------------------------------------------


    local function insertAddonOrBaseAdvancedFiltersSubmenu(addonTable, groupNameLocal, subfilterNameLocal, isBaseAdvancedFiltersSubmenu)
        groupNameLocal = groupNameLocal or ""
        subfilterNameLocal = subfilterNameLocal or subfilterNameLocal
        isBaseAdvancedFiltersSubmenu = isBaseAdvancedFiltersSubmenu or false

        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">[AF]insertAddonOrBaseAdvancedFiltersSubmenu-groupName: " ..tos(groupNameLocal) .. ", subfilterNameLocal: " ..tos(subfilterNameLocal) .. ", isBaseAdvancedFiltersSubmenu: " .. tos(isBaseAdvancedFiltersSubmenu))
            AF._addonTableBuildDropdownCallbacks = AF._addonTableBuildDropdownCallbacks or {}
            table.insert(AF._addonTableBuildDropdownCallbacks, addonTable)
        end
        local addonName = ""
        if addonTable.name ~= nil and addonTable.name ~= "" then
            addonName = addonTable.name
        elseif addonTable.pluginName ~= nil and addonTable.pluginName ~= "" then
            addonName = addonTable.pluginName
        elseif addonTable.submenuName ~= nil and addonTable.submenuName ~= "" then
            addonName = addonTable.submenuName
        else
            addonName = (addonTable.callbackTable and addonTable.callbackTable[1] and addonTable.callbackTable[1].name) or "n/a"
        end

        if displayName == "@Baertram" and (not addonName or addonName ~= nil and addonName == "") then
d(strfor("[AF]insertAddonOrBaseAdvancedFiltersSubmenu -> addonName not found! groupNameLocal: %s, subfilterNameLocal: %s, isBaseAdvancedFiltersSubmenu: %s\n->Inspect table A_F._addonTable", tos(groupNameLocal), tos(subfilterNameLocal), tos(isBaseAdvancedFiltersSubmenu)) )
        end
        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d("->insertAddon addonName: '" .. tos(addonName) .."', groupNameLocal: '" .. tos(groupNameLocal) .. "', subfilterNameLocal: '" .. tos(subfilterNameLocal).. "'") end


--Todo: For debugging - Remove afterwards
--[[
if not isBaseAdvancedFiltersSubmenu then
    AF._debugPluginFilterAddonTables = AF._debugPluginFilterAddonTables or {}
    AF._debugPluginFilterAddonTables[addonName .. "_" .. groupNameLocal .. "_" .. subfilterNameLocal] = {
        _addonName = addonName,
        addonTableOrig = ZO_ShallowTableCopy(addonTable),
        addonTable = addonTable,
        groupNameLocal = groupNameLocal,
        subfilterNameLocal = subfilterNameLocal,
    }
end
]]

        ------------------------------------------------------------------------------------------------------------------------
        -- Generator function for callbackTable and strings
        ---------------------------------------------------------------------------------------------------------------------------
        --generate information, if necessary via a generator function
        -->Coming from plugin filterInformation
        if addonTable.generator then
            local strings = {}
            addonTable.callbackTable, strings = addonTable.generator()

            --Mandatory fields are provided?
            if ZO_IsTableEmpty(addonTable.callbackTable) or ZO_IsTableEmpty(strings) or ZO_IsTableEmpty(strings["enStrings"]) then return end

            --Add generated strings to the AF.strings table
            -->First always add the mandatory enStrings
            -->Afterwards add the client language in addition, if provided and not "en" too
            local filterInformationGeneratedForClientLanguage
            if clientLang ~= LANG_EN then
                local clientLangStringKey = clientLang .. "Strings"
                if strings[clientLangStringKey] ~= nil then
                    filterInformationGeneratedForClientLanguage = {
                        [clientLangStringKey] = strings[clientLangStringKey]
                    }
                end
            end
            addStrings(strings["enStrings"], filterInformationGeneratedForClientLanguage, addonName)
        end

        ------------------------------------------------------------------------------------------------------------------------
        -- Exclude Filter Panels
        ---------------------------------------------------------------------------------------------------------------------------
        --Is the addon filter not to be shown at some libFilter panels?
        if addonTable.excludeFilterPanels ~= nil then
            if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">>excludeFilterPanels: Yes") end
            if type(addonTable.excludeFilterPanels) == "table" then
                for _, filterPanelToExclude in pairs(addonTable.excludeFilterPanels) do
                    if invOrFilterType == filterPanelToExclude then
                        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">>>insertAddon - filterPanelToExclude: " ..tos(filterPanelToExclude)) end
                        return
                    else
                        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">>>insertAddon - filterPanelToExclude: " ..tos(filterPanelToExclude) .. " <> filterType: "..tos(invOrFilterType)) end
                    end
                end
            else
                if invOrFilterType == addonTable.excludeFilterPanels then
                    if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">>>insertAddon - filterPanelToExclude: " ..tos(addonTable.excludeFilterPanels)) end
                    return
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        -- Exclude Groups
        ---------------------------------------------------------------------------------------------------------------------------
        --Do not add the entries if the group name specified "to be excluded" are the given ones
        if groupNameLocal ~= AF_CONST_ALL and addonTable.excludeGroups ~= nil then
            if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">>excludeGroups: Yes") end
            if type(addonTable.excludeGroups) == "table" then
                local notAllowedGroupNameLocals = {}
                for _, groupNameLocalToCheck in pairs(addonTable.excludeGroups) do
                    --groupNameLocal "Craftbag" stands for several group names, so add them all
                    if groupNameLocalToCheck == "Craftbag" then
                        for _, craftBagGroup in pairs(craftBagFilterGroups) do
                            notAllowedGroupNameLocals[craftBagGroup] = true
                        end
                    end
                    notAllowedGroupNameLocals[groupNameLocalToCheck] = true
                end
                if notAllowedGroupNameLocals[groupNameLocal] then
                    if debugSpam and not debugSpamExcludeDropdownBoxFilters then d("<--[EXCLUDE]insertAddon - excludeGroups, excluded group: " ..tos(groupNameLocal)) end
                    return
                end
            else
                if addonTable.excludeGroups == "Craftbag" then
                    local notAllowedGroupNameLocals = {}
                    --groupNameLocal "Craftbag" stands for several group names, so add them all
                    for _, craftBagGroup in pairs(craftBagFilterGroups) do
                        notAllowedGroupNameLocals[craftBagGroup] = true
                    end
                    if notAllowedGroupNameLocals[groupNameLocal] then
                        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d("<--[EXCLUDE]insertAddon - excludeGroups, excluded group: " ..tos(groupNameLocal)) end
                        return
                    end

                else
                    if groupNameLocal == addonTable.excludeGroups then
                        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d("<--[EXCLUDE]insertAddon - excludeGroups, excluded group: " ..tos(addonTable.excludeGroups)) end
                        return
                    end
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        -- Check onlyGroups
        ---------------------------------------------------------------------------------------------------------------------------
        --Only add the entries if the group name specified "to be used" are the given ones
        if groupNameLocal ~= AF_CONST_ALL and addonTable.onlyGroups ~= nil then
            if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">>onlyGroups: Yes") end
            if type(addonTable.onlyGroups) == "table" then
                local allowedgroupNameLocals = {}
                for _, groupNameLocalToCheck in pairs(addonTable.onlyGroups) do
                    --groupNameLocal "Craftbag" stands for several group names, so add them all
                    if groupNameLocalToCheck == "Craftbag" then
                        for _, craftBagGroup in pairs(craftBagFilterGroups) do
                            allowedgroupNameLocals[craftBagGroup] = true
                        end
                    end
                    allowedgroupNameLocals[groupNameLocalToCheck] = true
                end
                if not allowedgroupNameLocals[groupNameLocal] then
                    if debugSpam and not debugSpamExcludeDropdownBoxFilters then d("-->insertAddon - onlyGroups, not allowed group: " ..tos(groupNameLocal)) end
                    return
                end
            else
                if addonTable.onlyGroups == "Craftbag" then
                    local allowedgroupNameLocals = {}
                    --groupNameLocal "Craftbag" stands for several group names, so add them all
                    for _, craftBagGroup in pairs(craftBagFilterGroups) do
                        allowedgroupNameLocals[craftBagGroup] = true
                    end
                    if not allowedgroupNameLocals[groupNameLocal] then
                        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d("-->insertAddon - onlyGroups, not allowed group: " ..tos(groupNameLocal)) end
                        return
                    end

                else
                    if groupNameLocal ~= addonTable.onlyGroups then
                        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d("-->insertAddon - onlyGroups, not allowed group: " ..tos(addonTable.onlyGroups)) end
                        return
                    end
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        -- Exclude subfilters
        ---------------------------------------------------------------------------------------------------------------------------
        --Should any subfilter be excluded?
        if addonTable.excludeSubfilters ~= nil then
            if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">>excludeSubfilters: Yes") end
            if type(addonTable.excludeSubfilters) == "table" then
                for _, subfilterNameLocalToExclude in pairs(addonTable.excludeSubfilters) do
                    if subfilterNameOrig == subfilterNameLocalToExclude or subfilterNameLocal == subfilterNameLocalToExclude then
                        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d("<---[EXCLUDE]insertAddon - excludeSubfilters: " ..tos(subfilterNameLocalToExclude)) end
                        return
                    else
                        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d("--->[INCLUDE]insertAddon - excludeSubfilters '" ..tos(subfilterNameLocalToExclude) .. "' <> ' " ..tos(subfilterNameOrig) .. "/" .. tos(subfilterNameLocal)) end
                    end
                end
            else
                if subfilterNameOrig == addonTable.excludeSubfilters or subfilterNameLocal == addonTable.excludeSubfilters then
                    if debugSpam and not debugSpamExcludeDropdownBoxFilters then d("<---[EXCLUDE]insertAddon - excludeSubfilters: " ..tos(subfilterNameLocal)) end
                    return
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        -- Compare for already added entries
        ---------------------------------------------------------------------------------------------------------------------------
        --was the same addon filter already added before via the "ALL" type
        --only check if the groupNameLocal not equals "ALL", and if the duplicate checks should be done
        --e.g. they are not needed as the global addon filters get added
        if groupNameLocal ~= AF_CONST_ALL then --and subfilterNameLocal == AF_CONST_ALL then
            --Build names to compare
            local compareNames = {}
            --[[
            if addonTable.submenuName then
                table.insert(compareNames, addonTable.submenuName)
            else
                if addonTable.callbackTable then
                    for _, callbackTableNameEntry in ipairs(addonTable.callbackTable) do
                        if callbackTableNameEntry.nestedSubmenuEntries == nil then
                            table.insert(compareNames, callbackTableNameEntry.name)
                        else
                            for _, callbackTableNameNestedSubmenuEntry in ipairs(callbackTableNameEntry) do
                                table.insert(compareNames, callbackTableNameNestedSubmenuEntry.name)
                            end
                        end
                    end
                end
            end
            ]]
            recursivelyCheckDuplicateAddonFilterCallbackEntryNames(addonTable, compareNames)
            preventEndlessLoopDuplicateCallbackEntryNamesCounter = 0
            preventEndlessLoopDuplicateCallbackEntryNames = false
--AF._debugCompareNames = compareNames

            --Compare names with the entries in dropdownbox now
            for _, compareName in ipairs(compareNames) do
                --Check the whole callback table for entries with the same name or submenuName
                for _, callbackTableEntry in ipairs(callbackTable) do
                    if callbackTableEntry.submenuName then
                        if callbackTableEntry.submenuName == compareName then
                            if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">Duplicate submenu entry: " .. tos(callbackTableEntry.submenuName)) end
                            return
                        end
                    else
                        if callbackTableEntry.name and callbackTableEntry.name == compareName then
                            if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">Duplicate entry: " .. tos(callbackTableEntry.name)) end
                            return
                        end
                    end
                end
            end
        end

        ------------------------------------------------------------------------------------------------------------------------
        -- Add entries to callbackBable now
        ---------------------------------------------------------------------------------------------------------------------------
        --check to see if addon is set up for a submenu
        if addonTable.submenuName then
            if isBaseAdvancedFiltersSubmenu == true then
                addonTable.isStandardAFDropdownFilter = true
            end

            local currentAddonTable = addonTable.callbackTable
            for _, callbackEntry in ipairs(currentAddonTable) do
                callbackEntry = makeAddonDropdownFiltersCompatible(callbackEntry, addonName)
            end

            --insert whole package
            table.insert(callbackTable, addonTable)
        else
            --insert all callbackTable entries
            local currentAddonTable = addonTable.callbackTable
            for _, callbackEntry in ipairs(currentAddonTable) do
                if isBaseAdvancedFiltersSubmenu == true then
                    callbackEntry.isStandardAFDropdownFilter = true
                end

                callbackEntry = makeAddonDropdownFiltersCompatible(callbackEntry, addonName)

                table.insert(callbackTable, callbackEntry)
            end
        end
    end -- function "insertAddonOrBaseAdvancedFiltersSubmenu"
    ------------------------------------------------------------------------------------------------------------------------------------


    --Check if the new callbackEntry's name was not already added to the callbackTable, so that we do not have
    --duplicate entries in the "All" subfilter button e.g.
    local function insertNonDuplicateToCallbackTable(p_callbackTable, callbackEntry)
        if p_callbackTable == nil or callbackEntry == nil or callbackEntry.name == nil or callbackEntry.name == "" then return end

        for _, value in ipairs(p_callbackTable) do
            if value == callbackEntry or (value.name and value.name == callbackEntry.name) then
                local doError = true
                if callbackEntry.addString ~= nil then
                    if value.name ~= nil and value.name ~= callbackEntry.name .. "_" .. callbackEntry.addString then
                        doError = false
                    end
                end
                if doError == true then
                    if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">Duplicate AF base filter entry: " .. tos(callbackEntry.name)) end
                    return
                end
            end
        end
        table.insert(p_callbackTable, callbackEntry)
    end
    ------------------------------------------------------------------------------------------------------------------------------------

    --Check if the dropdownCallbacks should show a header row in the dropdown (e.g. for the Junk entries)
    local function checkAndAddPossibleDropdownCallbackHeaderLine(p_groupName, subFilterName, isSubmenuCallback)
        if not AF.settings.showSubMenuHeaderlinesInFilterDropdowns then return end

        isSubmenuCallback = isSubmenuCallback or false
        local subFilterGroupDropdownCallbacks
        if p_groupName == nil then
            subFilterGroupDropdownCallbacks = subfilterCallbacks[subFilterName]
        else
            subFilterGroupDropdownCallbacks = subfilterCallbacks[p_groupName][subFilterName]
        end
        if subFilterGroupDropdownCallbacks ~= nil then
            if not isSubmenuCallback then
                if subFilterGroupDropdownCallbacks.dropdownCallbacksHeaders == true then
                    if not ZO_IsTableEmpty(subFilterGroupDropdownCallbacks.dropdownCallbacks) then
                        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">Dropdown callback header entry: " .. tos(subFilterName) .. ", group: " ..tos(p_groupName)) end
                        local headerCallbackEntry = {
                            isHeader    = true, --Define this entry as headerline for the dropdown ZO_ComboBox -> LibScrollableMenu
                            name        = tos(p_groupName) .. "<|>" .. tos(subFilterName),
                        }
                        insertNonDuplicateToCallbackTable(callbackTable, headerCallbackEntry)
                    end
                end

            else
                --[[
                if subFilterGroupDropdownCallbacks.dropdownSubmenuCallbacks.dropdownCallbacksHeaders == true then

                end
                ]]
            end
        end
    end

    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------

    --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    -- Insert global AdvancedFilters "All" filters (no group)
    --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    checkAndAddPossibleDropdownCallbackHeaderLine(nil, AF_CONST_ALL)
    for _, callbackEntry in ipairs(subfilterCallbacks[AF_CONST_ALL].dropdownCallbacks) do
        callbackEntry.isStandardAFDropdownFilter = true
        insertNonDuplicateToCallbackTable(callbackTable, callbackEntry)
        --table.insert(callbackTable, callbackEntry)
    end

    --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    -- Insert filters that apply to a group, but not the ALL entry!
    --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if groupName ~= AF_CONST_ALL then
        checkAndAddPossibleDropdownCallbackHeaderLine(groupName, AF_CONST_ALL)
        --insert global "All" filters for a "group". e.g. Group "Jewelry", entry "All" -> subfilterCallbacks[Jewelry].All
        for _, callbackEntry in ipairs(subfilterCallbacks[groupName][AF_CONST_ALL].dropdownCallbacks) do
            callbackEntry.isStandardAFDropdownFilter = true
            insertNonDuplicateToCallbackTable(callbackTable, callbackEntry)
            --table.insert(callbackTable, callbackEntry)
        end

        --Subfilter is the ALL entry?
        if subfilterName == AF_CONST_ALL then
            --Gte the keys of all groupnames' subFilters, e.g. "1 HD", "2 HD", "Heal staff"
            local groupNameOfKeys = keys[groupName]
            if groupNameOfKeys == nil then
                d("[AdvancedFilters] ERROR - util.BuildDropdownCallbacks-GroupName is missing in keys: " ..tos(groupName) .. ". Please contact the author of ".. tos(AF.name) .. " at the website in the settings menu (link can be found at the top of the settings page)!")
                return
            elseif AF.settings.debugSpam and not debugSpamExcludeDropdownBoxFilters
                then d("[AF]util.BuildDropdownCallbacks-GroupName: " ..tos(groupName))
            end
            --insert all default AdvancedFilters filters for each subfilter (see file files/filterCallbacks.lua -> table subfilterCallbacks)
            for _, subfilterNameLoop in ipairs(groupNameOfKeys) do
                checkAndAddPossibleDropdownCallbackHeaderLine(groupName, subfilterNameLoop)
                local currentSubfilterTable = subfilterCallbacks[groupName][subfilterNameLoop]
                for _, callbackEntry in ipairs(currentSubfilterTable.dropdownCallbacks) do
                    callbackEntry.isStandardAFDropdownFilter = true
                    insertNonDuplicateToCallbackTable(callbackTable, callbackEntry)
                    --table.insert(callbackTable, callbackEntry)
                end

                --Insert special AdvancedFilters dropdown entries with SubMenus for all the subfilters of the group
                if subfilterCallbacks[groupName][subfilterNameLoop].dropdownSubmenuCallbacks then
                    for _, afSpecialTableAllSubfilterLoop in ipairs(subfilterCallbacks[groupName][subfilterNameLoop].dropdownSubmenuCallbacks) do
                        --add AF special filters to the dropdown boxes at subfilterName
                        insertAddonOrBaseAdvancedFiltersSubmenu(afSpecialTableAllSubfilterLoop, groupName, subfilterNameLoop, true)
                    end
                end
            end
            --Insert special AdvancedFilters dropdown entries with SubMenus for the ALL subfilter
            if subfilterCallbacks[groupName][subfilterName].dropdownSubmenuCallbacks then
                for _, afSpecialTableAllSubfilter in ipairs(subfilterCallbacks[groupName][subfilterName].dropdownSubmenuCallbacks) do
                    --add AF special filters to the dropdown boxes at subfilterName
                    insertAddonOrBaseAdvancedFiltersSubmenu(afSpecialTableAllSubfilter, groupName, subfilterName, true)
                end
            end

            --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- Insert all filters provided by plugins / other addons -> addonDropdownCallbacks added via API function AdvancedFilters_RegisterFilter(filterInformationTable)
            --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            --but check if the current panel should show the addon filters for "all" too
            if checkIfPanelShouldShowAddonAllDropdownFilters(invOrFilterType) then
                if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">add addon dropdown filters to group's '" .. tos(groupName) .."' 'ALL' filters") end
                for _, addonTable in ipairs(subfilterCallbacks[groupName].addonDropdownCallbacks) do
                    insertAddonOrBaseAdvancedFiltersSubmenu(addonTable, groupName, subfilterName, false)
                end
            end


        --Subfilter is NOT the ALL entry
        else
            --insert standard AdvancedFilters filters for provided subfilter
            checkAndAddPossibleDropdownCallbackHeaderLine(groupName, subfilterName)
            local currentSubfilterTable = subfilterCallbacks[groupName][subfilterName]
            for _, callbackEntry in ipairs(currentSubfilterTable.dropdownCallbacks) do
                callbackEntry.isStandardAFDropdownFilter = true
                insertNonDuplicateToCallbackTable(callbackTable, callbackEntry)
                --table.insert(callbackTable, callbackEntry)
            end

            --Insert special AdvancedFilters dropdown entries with SubMenus
            if subfilterCallbacks[groupName][subfilterName].dropdownSubmenuCallbacks then
                for _, afSpecialTable in ipairs(subfilterCallbacks[groupName][subfilterName].dropdownSubmenuCallbacks) do
                    --add AF special filters to the dropdown boxes at subfilterName
                    insertAddonOrBaseAdvancedFiltersSubmenu(afSpecialTable, groupName, subfilterName, true)
                end
            end

            --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            -- insert filters provided by addons for this subfilter
            --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            for _, addonTable in ipairs(subfilterCallbacks[groupName].addonDropdownCallbacks) do
                --scan addon to see if it applies to given subfilter
                for _, subfilter in ipairs(addonTable.subfilters) do
                    if subfilter == subfilterName or subfilter == AF_CONST_ALL then
                        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">add addon dropdown filters to group's '" .. tos(groupName) .."' subFilter \'" ..tos(subfilter) .."\'") end
                        --add addon filters to the dropdown boxes at the subfilterName
                        insertAddonOrBaseAdvancedFiltersSubmenu(addonTable, groupName, subfilterName, false)
                    end
                end
            end
        end
    end


    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- insert global (subFilterGroup = "All") addon filters ->  addonDropdownCallbacks added via API function AdvancedFilters_RegisterFilter(filterInformationTable)
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    --but check if the current panel should show the addon filters for "all" too
    if checkIfPanelShouldShowAddonAllDropdownFilters(invOrFilterType) then
        if debugSpam and not debugSpamExcludeDropdownBoxFilters then d(">show addon dropdown 'ALL' filters") end
        for _, addonTable in ipairs(subfilterCallbacks.All.addonDropdownCallbacks) do
            insertAddonOrBaseAdvancedFiltersSubmenu(addonTable, groupName, subfilterName, false)
        end
    end

    --todo: For debugging
    --debugSpam = false
    --debugSpamExcludeDropdownBoxFilters = true


    return callbackTable
end
--======================================================================================================================
-- -^- Dropdown box functions                                                                                       -^-
--======================================================================================================================

--======================================================================================================================
-- -v- Inventory count functions                                                                                    -v-
--======================================================================================================================
--Do not update the inventories itemCount as it got no count label or no value to update
--(e.g. smithing research panel)
function util.DoNotUpdateInventoryItemCount(filterTypeToUse)
    hideInventoryCountControls()

    filterTypeToUse = filterTypeToUse or getCurrentFilterTypeForInventory(AF.currentInventoryType)
    local doNotUpdateInventoryItemCountFilterPanels = {
        [LF_SMITHING_CREATION]          = true,
        [LF_SMITHING_RESEARCH]          = true,
        [LF_JEWELRY_CREATION]           = true,
        [LF_JEWELRY_RESEARCH]           = true,
        [LF_SMITHING_RESEARCH_DIALOG]   = true,
        [LF_JEWELRY_RESEARCH_DIALOG]    = true,
    }
    local doNotUpdateInventoryItemCountAtFilterPanel = doNotUpdateInventoryItemCountFilterPanels[filterTypeToUse] or false
    if AF.settings.debugSpam then d("[AF]util.DoNotUpdateInventoryItemCount, filterTypeToUse: " ..tos(filterTypeToUse) .. ", doNotUpdate: " ..tos(doNotUpdateInventoryItemCountAtFilterPanel)) end
    return doNotUpdateInventoryItemCountAtFilterPanel
end

--Add count of shown (filtered) items to the inventory: space/total (count)
function util.getInvItemCount(freeSlotType, isCraftingInvType)
    if AF.settings.debugSpam then d("[AF]util.getInvItemCount-freeSlotType: " .. tos(freeSlotType) .. ", isCraftingInvType: " .. tos(isCraftingInvType)) end
    local itemCount
    local invType
    if freeSlotType ~= nil then
        invType = freeSlotType
    else
        invType = AF.currentInventoryType
    end
    if invType == nil then return nil end
    isCraftingInvType = isCraftingInvType or isCraftingStationInventoryType(invType)
    if not isCraftingInvType then
        local invListViewData
        if invType == LF_QUICKSLOT then
            local quickslotVar = controlsForChecks.quickslot
            if quickslotVar == nil then return nil end
            invListViewData = quickslotVar.list.data
        else
            local playerInvVar = controlsForChecks.playerInv
            if playerInvVar.inventories[invType] == nil then return nil end
            invListViewData = playerInvVar.inventories[invType].listView.data
        end
        if invListViewData then
            itemCount = #invListViewData
        end
    else
        local craftingInvCtrl = getInventoryFromCraftingPanel(freeSlotType) or nil
        if craftingInvCtrl == nil or craftingInvCtrl.list == nil then return nil end
        local craftingInvSlotCountCtrl = craftingInvCtrl.list.data or nil
        if craftingInvSlotCountCtrl == nil then return nil end
        itemCount = #craftingInvSlotCountCtrl
    end
    return itemCount
end

--Update the inventory infobar lFreeSlot label with the item filtered count
function util.updateInventoryInfoBarCountLabel(invType, isCraftingInvType, isCalledFromExternalAddon)
    invType = invType or AF.currentInventoryType
    if util.DoNotUpdateInventoryItemCount(invType) then return end
    isCraftingInvType = isCraftingInvType or isCraftingStationInventoryType(invType)
    isCalledFromExternalAddon = isCalledFromExternalAddon or false
    if AF.settings.debugSpam then d("[AF]util.updateInventoryInfoBarCountLabel-invType: " ..tos(invType) .. ", isCraftingInvType: " .. tos(isCraftingInvType) .. ", isCalledFromExternalAddon: " .. tos(isCalledFromExternalAddon)) end
    --Update the count of shown/filtered items in the inventory FreeSlots label
    if invType ~= nil then
        if not isCraftingInvType then
            if invType == LF_QUICKSLOT then
                local quickslotVar = controlsForChecks.quickslot
                ThrottledUpdate("RefreshItemCount_Quickslots", 50, quickslotVar.UpdateFreeSlots, quickslotVar)
            else
                local playerInvVar = controlsForChecks.playerInv
                --Call the update function for the player inventories
                if playerInvVar.inventories ~= nil and playerInvVar.inventories[invType] ~= nil then
                    playerInvVar:UpdateFreeSlots(invType)
                end
            end
        else
            --Call the update function for the crafting tables inventories now, see file "main.lua"
            -->Overwritten function UpdateInventorySlots(infoBar)
            --Ge the infoBar first
            local craftingInvCtrl = getInventoryFromCraftingPanel(invType) or nil
            if craftingInvCtrl == nil then return nil end
            local craftingInvCtrlControl = craftingInvCtrl.control or nil
            if craftingInvCtrlControl == nil then return nil end
            local infoBar = craftingInvCtrlControl:GetNamedChild("InfoBar")
            --Now call update function
            if infoBar ~= nil then
                if UpdateInventorySlots then UpdateInventorySlots(infoBar) end
            end
        end
    end
end
local updateInventoryInfoBarCountLabel = util.updateInventoryInfoBarCountLabel

--Update the crafting table's inventory item count etc. from external addons
function util.UpdateCraftingInventoryFilteredCount(invType)
    if AF.settings.debugSpam then d("[AF]util.UpdateCraftingInventoryFilteredCount - invType: " ..tos(invType)) end
    updateInventoryInfoBarCountLabel(invType, nil, true)
end
local updateCraftingInventoryFilteredCount = util.UpdateCraftingInventoryFilteredCount
--======================================================================================================================
-- -^- Inventory count functions                                                                                    -^-
--======================================================================================================================

--======================================================================================================================
-- -v- IsShown functions                                                                                            -v-
--======================================================================================================================
--Check if a game scene is shown
function util.IsSceneShown(sceneName)
    --if AF.settings.debugSpam then d("[AF]util.IsSceneShown, sceneName: " ..tos(sceneName)) end
    if sceneName == nil then return false end
    local currentSceneName = SCENE_MANAGER.currentScene.name
    --d(">currentSceneName: " .. tos(currentSceneName))
    if currentSceneName ~= nil and currentSceneName == sceneName then
        return true
    end
    return false
end
local isSceneShown = util.IsSceneShown

--Check if a LibFilters-3.0 filterPanelId (or a related control) is shown
function util.IsFilterPanelShown(libFiltersFilterPanelId)
    --if AF.settings.debugSpam then d("[AF]IsFilterPanelShown: " ..tos(libFiltersFilterPanelId)) end
    if libFiltersFilterPanelId == nil then return false end
    local controlInventory = controlsForChecks.invList
    local controlMailSend = controlsForChecks.mailSend
    local controlVendorBuy = controlsForChecks.storeWindow
    local controlVendorBuyback = controlsForChecks.buyBackList
    local controlVendorRepair = controlsForChecks.repairWindow
    local controlBankDeposit = controlsForChecks.bankBackpack
    local controlFurnitureVaultDeposit = controlsForChecks.furnitureVaultList
    local controlGuildBankDeposit = controlsForChecks.guildBankBackpack
    local controlGuildStoreSell = controlsForChecks.guildStoreSellBackpack
    local controlsFence = controlsForChecks.fence
    local controlsTrade = controlsForChecks.trade
    local scenesForChecks = AF.scenesForChecks
    local sceneNameStoreVendor = scenesForChecks.storeVendor
    local sceneNameBankDeposit = scenesForChecks.bank
    local sceneNameFurnitureVaultDeposit = scenesForChecks.furnitureVault
    local sceneNameGuildBankDeposit = scenesForChecks.guildBank
    local sceneNameGuildStoreSell = scenesForChecks.guildStoreSell
    local sceneNameFence = scenesForChecks.fence
    --local sceneNameUniversalDecon = scenesForChecks.universalDecon todo ???
    local filterPanelId2TrueControl = {
        [LF_MAIL_SEND]          = function() return not controlMailSend.control:IsHidden() or false end,
        [LF_VENDOR_BUY]         = function() return not controlVendorBuy:IsHidden() and controlInventory:IsHidden() and controlVendorBuyback:IsHidden() and controlVendorRepair:IsHidden() or false end,
        [LF_VENDOR_SELL]        = function() return controlVendorBuy:IsHidden() and not controlInventory:IsHidden() and controlVendorBuyback:IsHidden() and controlVendorRepair:IsHidden() or false end,
        [LF_VENDOR_BUYBACK]     = function() return controlVendorBuy:IsHidden() and controlInventory:IsHidden() and not controlVendorBuyback:IsHidden() and controlVendorRepair:IsHidden() or false end,
        [LF_VENDOR_REPAIR]      = function() return controlVendorBuy:IsHidden() and controlInventory:IsHidden() and controlVendorBuyback:IsHidden() and not controlVendorRepair:IsHidden() or false end,
        [LF_BANK_DEPOSIT]       = controlInventory,
        [LF_GUILDBANK_DEPOSIT]  = controlInventory,
        [LF_HOUSE_BANK_DEPOSIT] = controlInventory,
        [LF_FURNITURE_VAULT_DEPOSIT] = controlInventory,
        [LF_GUILDSTORE_SELL]    = controlGuildStoreSell,
        [LF_FENCE_SELL]         = function() return (not controlsFence.control:IsHidden() and controlsFence.mode == ZO_MODE_STORE_SELL_STOLEN) or false end,
        [LF_FENCE_LAUNDER]      = function() return (not controlsFence.control:IsHidden() and controlsFence.mode == ZO_MODE_STORE_LAUNDER) or false end,
        [LF_TRADE]              = function() return (not controlsTrade.control:IsHidden()) or false end,
    }
    local filterPanelId2FalseControl = {
        [LF_BANK_DEPOSIT]       = controlBankDeposit,
        [LF_GUILDBANK_DEPOSIT]  = controlGuildBankDeposit,
        [LF_HOUSE_BANK_DEPOSIT] = controlBankDeposit,
        [LF_FURNITURE_VAULT_DEPOSIT] = controlFurnitureVaultDeposit,
    }
    local filterPanelId2SceneName = {
        [LF_VENDOR_BUY]         = sceneNameStoreVendor,
        [LF_VENDOR_SELL]        = sceneNameStoreVendor,
        [LF_VENDOR_BUYBACK]     = sceneNameStoreVendor,
        [LF_VENDOR_REPAIR]      = sceneNameStoreVendor,
        [LF_BANK_DEPOSIT]       = sceneNameBankDeposit,
        [LF_GUILDBANK_DEPOSIT]  = sceneNameGuildBankDeposit,
        [LF_HOUSE_BANK_DEPOSIT] = sceneNameBankDeposit,
        [LF_GUILDSTORE_SELL]    = sceneNameGuildStoreSell,
        [LF_FURNITURE_VAULT_DEPOSIT] = sceneNameFurnitureVaultDeposit,
        [LF_FENCE_SELL]         = sceneNameFence,
        [LF_FENCE_LAUNDER]      = sceneNameFence,
    }
    local goOn = true
    local trueSceneName = filterPanelId2SceneName[libFiltersFilterPanelId] or nil
    --Check if a scene needs to be checked
    if trueSceneName ~= nil then
        goOn = false
        --Check the active scene
        if isSceneShown(trueSceneName) then
            goOn = true
        else
            --No scene found but needs one. Abort!
            return false
        end
    end
    --Scene was checked, shall we go on?
    if not goOn then return false end
    --Check if a control needs to be shown
    goOn = false
    local trueControl
    local trueControlCheck = filterPanelId2TrueControl[libFiltersFilterPanelId] or nil
    if trueControlCheck ~= nil then
        if type(trueControlCheck) == "function" then
            trueControl = trueControlCheck() or false
        elseif type(trueControlCheck) == "boolean" then
            trueControl = trueControlCheck or false
        else
            trueControl = trueControlCheck.IsHidden ~= nil and not trueControlCheck:IsHidden() or false
        end
    end
    if trueControl ~= nil and trueControl == true then
        goOn = true
    else
        --Control(s) must be shown but isn't? Abort!
        return false
    end
    --True control was checked, shall we go on?
    if not goOn then return false end
    --Check if a control needs to be hidden
    goOn = false
    local falseControl
    local falseControlCheck = filterPanelId2FalseControl[libFiltersFilterPanelId] or nil
    if falseControlCheck ~= nil then
        if type(falseControlCheck) == "function" then
            falseControl = falseControlCheck() or nil
        elseif type(trueControlCheck) == "boolean" then
            trueControl = falseControlCheck or nil
        else
            if falseControlCheck.IsHidden ~= nil then
                falseControl = falseControlCheck:IsHidden() or nil
            end
        end
    end
    if falseControlCheck ~= nil and (falseControl == nil or falseControl == false) then
        --Control must be hidden but isn't? Abort!
        return false
        --else
        --    goOn = true
    end
    --False control was checked, shall we go on?
    --if not goOn then return false end
    --Panel was determined via scene name, true and/or false control!
    return true
end
local isFilterPanelShown = util.IsFilterPanelShown

function util.GetSubFilterBarsFilterTypeInfo(subFilterBar, inventoryType)
    if not subFilterBar or not inventoryType then return end
    local AFsubFilterNamePlayerInv = AF.inventoryNames[INVENTORY_BACKPACK]
    local AFsubFilterNameActiveInv = AF.inventoryNames[inventoryType]
    local filterTypeNames = AF.filterTypeNames
    local isMailSendPanel               = isFilterPanelShown(LF_MAIL_SEND) or false
    local isVendorBuy                   = isFilterPanelShown(LF_VENDOR_BUY) or false
    local isVendorPanel                 = isFilterPanelShown(LF_VENDOR_SELL) or false
    local isFencePanel                  = isFilterPanelShown(LF_FENCE_SELL) or false
    local isLaunderPanel                = isFilterPanelShown(LF_FENCE_LAUNDER) or false
    local isBankDepositPanel            = AF.bankOpened and isFilterPanelShown(LF_BANK_DEPOSIT) or false
    local isGuildBankDepositPanel       = AF.guildBankOpened  and isFilterPanelShown(LF_GUILDBANK_DEPOSIT) or false
    local isHouseBankDepositPanel       = AF.houseBankOpened  and isFilterPanelShown(LF_HOUSE_BANK_DEPOSIT) or false
    local isGuildStoreSellPanel         = isFilterPanelShown(LF_GUILDSTORE_SELL) or false
    local isRetraitStation              = isRetraitPanelShown()
    local isFurnitureVaultDepositPanel  = AF.furnitureVaultOpened and isFilterPanelShown(LF_FURNITURE_VAULT_DEPOSIT) or false
    local isVengeanceInvPanel           = isFilterPanelShown(LF_INVENTORY_VENGEANCE) or false

    local isJunkInvButtonActive         = subFilterBar.name == (AFsubFilterNamePlayerInv .. "_" .. filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_JUNK]) or false
    local isJunkButtonActive            = subFilterBar.name == (AFsubFilterNameActiveInv .. "_" .. filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_JUNK]) or false

    checkForOtherAddonFlags()
    --FCO Companion support
    if isJunkButtonActive == false and FCOCompanionJunkEnabled == true then
        local isJunkCompanionInvButtonActive = subFilterBar.name == ("AF_FilterBarCompanionInventory_" .. filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_JUNK]) or false
        if isJunkCompanionInvButtonActive == true then
            isJunkButtonActive = isJunkCompanionInvButtonActive
        end
    end
    local isTrade                       = isFilterPanelShown(LF_TRADE) or false
    local libFiltersPanelId             = getCurrentFilterTypeForInventory(inventoryType, true)
    local isCompanionInv                = isCompanionInventoryShown()
    local isCompanionInvButtonActive    = subFilterBar.name == (AFsubFilterNameActiveInv ~= nil and AFsubFilterNameActiveInv .. "_" .. filterTypeNames[ITEM_TYPE_DISPLAY_CATEGORY_COMPANION]) or false
    libFilters = libFilters or util.LibFilters
    isUniversalDeconPanelShown = isUniversalDeconPanelShown or libFilters.IsUniversalDeconstructionPanelShown
    util.IsUniversalDeconPanelShown = isUniversalDeconPanelShown
    local isUniversalDecon              = isUniversalDeconPanelShown()

    return {
        libFiltersPanelId = libFiltersPanelId,
        isMailSendPanel = isMailSendPanel,
        isVendorBuy = isVendorBuy,
        isVendorPanel = isVendorPanel,
        isFencePanel = isFencePanel,
        isLaunderPanel = isLaunderPanel,
        isBankDepositPanel = isBankDepositPanel,
        isGuildBankDepositPanel = isGuildBankDepositPanel,
        isHouseBankDepositPanel = isHouseBankDepositPanel,
        isGuildStoreSellPanel = isGuildStoreSellPanel,
        isRetraitStation = isRetraitStation,
        isJunkInvButtonActive = isJunkInvButtonActive,
        isJunkButtonActive = isJunkButtonActive,
        isTrade = isTrade,
        isCompanionInv = isCompanionInv,
        isCompanionInvButtonActive = isCompanionInvButtonActive,
        isUniversalDeconstruction = isUniversalDecon,
        isFurnitureVaultDepositPanel = isFurnitureVaultDepositPanel,
        isVengeanceInvPanel = isVengeanceInvPanel,
    }
end
local getSubFilterBarsFilterTypeInfo = util.GetSubFilterBarsFilterTypeInfo

--Check if the craftbag is shown as the groupName at the craftbag is different than non-craftbag
--e.g. the groupName "Alchemy" is the normal groupName "Crafting" with subfilterName "Alchemy"
function util.IsCraftBagShown()
    return not ZO_CraftBag:IsHidden()
end

--======================================================================================================================
-- -^- IsShown functions                                                                                            -^-
--======================================================================================================================

--======================================================================================================================
-- -v- Subfilter bar functions                                                                                      -v-
--======================================================================================================================
--Should the subfilter bar not be shown?
--e.g. ALWAYS do not show if special itemfilterType OR if the current inventory was closed again (automatic bank closing)
function util.CheckIfNoSubfilterBarShouldBeShown(currentFilter, invType, craftingType, filter)
    local debugSpam = AF.settings.debugSpam
    if AF.debug or debugSpam then
        d("[AF]util.CheckIfNoSubfilterBarShouldBeShown - currentFilter: " .. tos(currentFilter) .. ", invType: " ..tos(invType) .. ", craftingType: " ..tos(craftingType) .. ", filter: " .. tos(filter))
    end
    local doAbort = false
    local filterTypeToUse
    --Is the stable vendor shown? Abort, as there are no subfilter bars
    if currentFilter and currentFilter == ITEMFILTERTYPE_COLLECTIBLE and SCENE_MANAGER:GetCurrentScene() == STABLES_SCENE then doAbort = true end
    if not doAbort and invType ~= nil then
        --Check if the subfilterBar is still needed. Maybe the current inventory/panel was closed already again (automatic bank close check)
        if AF.fragmentStateHiding and AF.fragmentStateHiding[invType] then
            doAbort = true
        end
        --Is the subfilter bar some bad combination which the game creates but shouldn't be there as it will be updated right afterwards
        --properly with correct values? e.g. at the jewelry refinemant panel the filter will be first 6 (why?) + currentFilter =nil and
        --then corrected to 1 and correct currentFilter properly
        if not doAbort then
            if currentFilter == nil then
                if filter == nil then return false end
                craftingType = craftingType or getCraftingType()
                if not craftingType then return false end
                local subfilterBarsShouldOnlyBeShownSpecial = AF.subfilterBarsShouldOnlyBeShownSpecial
                if subfilterBarsShouldOnlyBeShownSpecial[invType] and subfilterBarsShouldOnlyBeShownSpecial[invType][craftingType] then
                    local subfilterBarShouldOnlyBeShownSpecial = subfilterBarsShouldOnlyBeShownSpecial[invType][craftingType][filter] or false
                    doAbort = not subfilterBarShouldOnlyBeShownSpecial
                end
            end
        end
    end
    if debugSpam then d("[AF]util.CheckIfNoSubfilterBarShouldBeShown - doAbort: " .. tos(doAbort) .." /currentFilter: " ..tos(currentFilter) .. ", invType: " ..tos(invType) .. ", filterTypeToUse: " ..tos(filterTypeToUse) .. ", fragmentStateHiding: " ..tos(AF.fragmentStateHiding[invType]) .. ", isBanking: " ..tos(PLAYER_INVENTORY:IsBanking())) end
    --if AF.settings.debugSpam then d("[AF]util.CheckIfNoSubfilterBarShouldBeShown - currentFilter: " ..tos(currentFilter) .. ", invType: " ..tos(invType) .. ", abort: " ..tos(doAbort)) end
    return doAbort
end


--Abort the subfilterbar refresh?
--e.g. if via the metatables the "old" (currently hiding) subfilterbar will be hidden and a refresh is not needed
--until it's shown again
function util.AbortSubfilterRefresh(inventoryType)
    if inventoryType == nil then return true end
    local doAbort = false
    local subFilterRefreshAbortInvTypes = AF.abortSubFilterRefreshInventoryTypes
    --Abort the subfilter bar refresh at some panels (and always at crafting panels->they will be updated with their own update functions)
    if subFilterRefreshAbortInvTypes[inventoryType] or isCraftingStationInventoryType(inventoryType) then
        doAbort = true
    end
    if AF.settings.debugSpam then d("[AF]util.AbortSubfilterRefresh - invType: " ..tos(inventoryType) .. ", abort: " ..tos(doAbort)) end
    return doAbort
end
local abortSubfilterRefresh = util.AbortSubfilterRefresh

--Refresh the subfilter button bar and disable non-given/non-matching subfilter buttons ("grey-out" the buttons)
function util.RefreshSubfilterBar(subfilterBar, calledFromExternalAddonName, isUniversalDecon, activeUniversalTab)
    checkIfOtherAddonsProvideSubfilterBarRefreshFilters = checkIfOtherAddonsProvideSubfilterBarRefreshFilters or util.CheckIfOtherAddonsProvideSubfilterBarRefreshFilters
    isItemFilterTypeInItemFilterData = isItemFilterTypeInItemFilterData or util.IsItemFilterTypeInItemFilterData

    --Check if any other addon flag or table or function update is needed
    checkForOtherAddonFlags()

    calledFromExternalAddonName = calledFromExternalAddonName or ""
    local settings = AF.settings
    local debugSpam = settings.debugSpam
    local debugSpamExcludeRefreshSubfilterBar = settings.debugSpamExcludeRefreshSubfilterBar
    local inventoryType = subfilterBar.inventoryType
    local craftingType = getCraftingType()
    local isNoCrafting = not isCraftingPanelShown()
    local realInvTypes
    local inventory, inventorySlots
    local currentFilter
    local bagWornItemCache
    local bagVendorBuy
    local bagVendorBuyFilterTypes

    --Setting to gray out the buttons is enbaled?
    local grayOutSubFiltersWithNoItems  = settings.grayOutSubFiltersWithNoItems
    --Reactivate all subfilterbar buttons if they were disabled
    local abortSubfilterBarRefresh = abortSubfilterRefresh(inventoryType)
--d(">abortSubfilterBarRefresh: " ..tos(abortSubfilterBarRefresh))
    local onlyEnableAllSubfilterBarButtons = false
    local isVendorBuyInv = (inventoryType == INVENTORY_TYPE_VENDOR_BUY) or false
    local isCompanionInv = (inventoryType == LF_INVENTORY_COMPANION) or false
    if isUniversalDecon == nil then
        isUniversalDecon = subfilterBarInventorytypesOfUniversalDecon[inventoryType] or false
    end
    if isUniversalDecon == true then isNoCrafting = true end

    if debugSpam then
        d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        d("[AF]SubFilter refresh, abortSubfilterBarRefresh: " .. tos(abortSubfilterBarRefresh) .. ", calledFromExternalAddonName: " .. tos(calledFromExternalAddonName) .. ", invType: " .. tos(inventoryType) .. ", subfilterBar: " ..tos(subfilterBar.name) .. ", craftingType: " .. tos(craftingType) .. ", isNoCrafting: " .. tos(isNoCrafting) .. ", isCompanionInv: " .. tos(isCompanionInv) ..", isUniversalDecon: " ..tos(isUniversalDecon))
        AF._currentSubfilterBarAtRefreshCheck = subfilterBar
    end

    local hideCharBound = settings.hideCharBoundAtBankDeposit

    --Abort the subfilterBar refresh method? Or check for crafting inventory types and return the correct inventory types then
    if abortSubfilterBarRefresh == true or isCompanionInv == true then
        --Try to map the fake inventory type from LibFilters to the real ingame inventory type
        realInvTypes = mapLibFiltersInventoryTypeToRealInventoryType(inventoryType)
        if realInvTypes == nil and not isVendorBuyInv then
            --Reactivate all subfilterbar buttons if they were disabled
            onlyEnableAllSubfilterBarButtons = true
        end
        --Improvement panel: BAG_WORN needs to be checked as well later on!
        local bagWornCheckNeeded = getCraftingPanelUsesBagWorn(inventoryType)
        if bagWornCheckNeeded == true then
            bagWornItemCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_WORN)
        end
    elseif isUniversalDecon == true then
        local tabKey = (activeUniversalTab ~= nil and activeUniversalTab.key) or universalDeconPanelInv:GetCurrentFilter().key
        if tabKey == nil then return end
        realInvTypes = mapUniversalDeconTabKeyToRealInventoryTypes(tabKey)
    elseif isVendorBuyInv == true then
        bagVendorBuy, bagVendorBuyFilterTypes = ZO_StoreManager_GetStoreItems()
        if debugSpam then
            AF._bagVendorBuy = bagVendorBuy
            AF._bagVendorBuyFilterTypes = bagVendorBuyFilterTypes
        end
    else
        realInvTypes = {}
        table.insert(realInvTypes, inventoryType)
    end

--AF._realInvTypes = realInvTypes

    if debugSpam then d("<SubFilter refresh - go on: onlyEnableAllSubfilterBarButtons: " ..tos(onlyEnableAllSubfilterBarButtons) ..", bagVendorBuyGiven: " ..tos((bagVendorBuy~=nil and #bagVendorBuy) or "no") ..", #realInvTypes: " .. tos((realInvTypes~=nil and #realInvTypes) or "none") .. ", subfilterBar: " ..tos(subfilterBar) .. ", bagWornToo?: " ..tos(bagWornItemCache ~= nil)) end
    --Check if a bank/guild bank/house storage is opened, junk button is selected, etc.
    local subFilterBarFilterInfo = getSubFilterBarsFilterTypeInfo(subfilterBar, inventoryType)
    if subFilterBarFilterInfo == nil then
        showChatDebug("RefreshSubfilterBar - subFilterBarFilterInfo missing", "InventoryType: " ..tos(inventoryType) .. ", craftingType: " ..tos(craftingType) .. "/" .. util.GetCraftingType() .. ", isUniversalDecon: " .. tos(isUniversalDecon) .. ", calledFromExternalAddonName: " ..tos(calledFromExternalAddonName) .. ", subfilterBarName: " ..tos(subfilterBar ~= nil and subfilterBar.name))
        return
    end

    local libFiltersPanelId             = subFilterBarFilterInfo.libFiltersPanelId
    local isMailSendPanel               = subFilterBarFilterInfo.isMailSendPanel
    local isVendorBuy                   = subFilterBarFilterInfo.isVendorBuy
    local isVendorPanel                 = subFilterBarFilterInfo.isVendorPanel
    local isFencePanel                  = subFilterBarFilterInfo.isFencePanel
    local isLaunderPanel                = subFilterBarFilterInfo.isLaunderPanel
    local isBankDepositPanel            = subFilterBarFilterInfo.isBankDepositPanel
    local isGuildBankDepositPanel       = subFilterBarFilterInfo.isGuildBankDepositPanel
    local isHouseBankDepositPanel       = subFilterBarFilterInfo.isHouseBankDepositPanel
    local isABankDepositPanel           = (subFilterBarFilterInfo.isBankDepositPanel or subFilterBarFilterInfo.isGuildBankDepositPanel or subFilterBarFilterInfo.isHouseBankDepositPanel) or false
    local isGuildStoreSellPanel         = subFilterBarFilterInfo.isGuildStoreSellPanel
    local isRetraitStation              = subFilterBarFilterInfo.isRetraitStation
    local isJunkInvButtonActive         = subFilterBarFilterInfo.isJunkInvButtonActive
    local isJunkButtonActive            = subFilterBarFilterInfo.isJunkButtonActive
    local isCompanionInvPanel           = subFilterBarFilterInfo.isCompanionInv
    local isCompanionInvButtonActive    = subFilterBarFilterInfo.isCompanionInvButtonActive
    local isUniversalDeconstructionActive = subFilterBarFilterInfo.isUniversalDeconstruction
    local isVengeanceInvPanel           = subFilterBarFilterInfo.isVengeanceInvPanel

    --For FCOCompanion "Junk" tab
    local isFCOCompanionJunkTabAtCompanionInv = (FCOCompanionJunkEnabled == true and isCompanionInv and isJunkButtonActive and true) or false

    if debugSpam then d(">isMailSend: " ..tos(isMailSendPanel) .. ", isVendorBuy: " ..tos(isVendorBuy) ..", isFencePanel: " .. tos(isFencePanel) .. ", isLaunderPanel: " .. tos(isLaunderPanel) .. ", isVendorPanel: " .. tos(isVendorPanel) .. ", isBankDepositPanel: " .. tos(isBankDepositPanel) .. ", isGuildBankDepositPanel: " .. tos(isGuildBankDepositPanel) .. ", isHouseBankDepositPanel: " .. tos(isHouseBankDepositPanel) .. ", isRetraitStation: " .. tos(isRetraitStation) .. ", isJunkInvButtonActive: " .. tos(isJunkInvButtonActive) .. ", isJunkButtonActive: " .. tos(isJunkButtonActive) .. ", isCompanionInv: " ..tos(isCompanionInvPanel) .. ", isUniversalDecon: " ..tos(isUniversalDeconstructionActive) ..", libFiltersPanelId: " .. tos(libFiltersPanelId) .. ", grayOutSubfiltersWithNoItems: " ..tos(grayOutSubFiltersWithNoItems)) end
    local doEnableSubFilterButtonAgain = false
    local breakInventorySlotsLoopNow = false

    --Get the crafting panel
    --Check if a "include banked" checkbox is given at the crafting panel
    local includeBankedCbox, includeBankedCboxParentCtrl
    local includeBankedItemsChecked
    if not isNoCrafting then
        includeBankedCbox, includeBankedCboxParentCtrl = getCraftingTablePanelIncludeBankedCheckbox(libFiltersPanelId, isUniversalDecon)
        --AF._includeBankedCbox = includeBankedCbox
        --AF._parentCtrl = parentCtrl
        if includeBankedCbox and includeBankedCboxParentCtrl then
            --Check if the "include banked items" checkbox is enabled
            -->If not: Check if bagId is bank or subscriber bank and hide the items then
            includeBankedItemsChecked = ZO_CheckButton_IsChecked(includeBankedCbox)
            --d("[AF]RefreshSubfilterBar - Found include banked items checkbox, state: " ..tos(includeBankedItemsChecked))
        end
    end
    local doIncludeBankCBChecks = includeBankedCbox ~= nil

    --FCOCraftFilter is enabled? Get it's filter function
    local FCOCF_filtercallbackFunction
    if (FCOCF and FCOCF.GetFilterCallbackFunction) then
        FCOCF_filtercallbackFunction = FCOCF.GetFilterCallbackFunction()
    end


    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------

    --Check subfilterbutton for items, using the filter function and junk checks (only for non-crafting stations)
    local function checkBagContentsNow(bag, bagData, realInvType, button)
--d(">checkBagContentsNow - isNoCrafting: " ..tos(isNoCrafting) .. ", isUniversalDecon: " ..tos(isUniversalDecon) ..", libFiltersPanelId: " ..tos(libFiltersPanelId))
        if debugSpam and not debugSpamExcludeRefreshSubfilterBar then d(">checkBagContentsNow: " ..tos(button.name)) end
        doEnableSubFilterButtonAgain = false
        breakInventorySlotsLoopNow = false


        local hasAnyJunkInBag = false
        local useBagWorn = (bag and bag == BAG_WORN) or false
        if isNoCrafting and (bag and not useBagWorn) then
            hasAnyJunkInBag = HasAnyJunk(bag, false)
        end
        local bagDataToCheck = {}
        --Worn items? The given data is quite different then the PLAYER_INVENTORY data so one needs to map it
        -->Use the first entry in the list of bagData = itemlist to check
        if useBagWorn == true then
            bagDataToCheck[1] = bagData
        else
            bagDataToCheck = bagData
        end

        --AF._bagDataToCheck = bagDataToCheck
        local itemsFound = 0
        if debugSpam and not debugSpamExcludeRefreshSubfilterBar then d(">currentFilter: " ..tos(currentFilter)) end
        for _, itemData in pairs(bagDataToCheck) do
            breakInventorySlotsLoopNow = false
            local isItemSellable = false
            local isItemStolen = false
            local isItemJunk = false
            local isItemBankAble = true
            local isBOPTradeable = false
            local isBound = false
            local itemIsOwnedByCompanion = false
            local itemIsCharBound = false
            local passesCallback
            local passesFilter

            local bagId     = itemData.bagId
            local slotIndex = itemData.slotIndex

            --todo Change here to disable debugging output for 1 item                           --#83
            local doSingleItemDebug = false --(bagId == 1 and slotIndex == 69) and true or false        --#83
            local itemlink
            if doSingleItemDebug or (debugSpam and not debugSpamExcludeRefreshSubfilterBar) then
                if isVendorBuy then
                    itemlink = GetStoreItemLink(slotIndex)
                else
                    itemlink = GetItemLink(bagId, slotIndex)
                end
            end


            --Another addon uses filters on this LibFilters panelId?
            local otherAddonUsesFilters = checkIfOtherAddonsProvideSubfilterBarRefreshFilters(itemData, realInvType, craftingType, libFiltersPanelId)
            if isNoCrafting then
                passesCallback = button.filterCallback(itemData)
                if doSingleItemDebug then d(">>passesCallback NO CRAFTING - START: " .. tos(passesCallback)) end

                --Other addons are active which need special handling?
                --FCOCompanion - "Junk" tab at companion inventory
                if isFCOCompanionJunkTabAtCompanionInv and currentFilter == ITEM_TYPE_DISPLAY_CATEGORY_JUNK then
                    passesFilter = (passesCallback and isItemFilterTypeInItemFilterData(itemData, currentFilter, nil)
                    ) and otherAddonUsesFilters
                else
                    --Like crafting tables the junk inventory got different itemTypes in one section (ITEM_TYPE_DISPLAY_CATEGORY_JUNK = 9). So the filter comparison does not work and the callback should be enough to check.
                    passesFilter = passesCallback and (
                            (not isVendorBuy and (isJunkInvButtonActive and currentFilter == ITEM_TYPE_DISPLAY_CATEGORY_JUNK))
                                    --Seems "itemData.filterData" contains the new ITEM_TYPE_DISPLAY_CATEGORY_* values now as well!
                                    --use this function to map it: ITEM_FILTER_UTILS.IsSlotFilterDataInItemTypeDisplayCategory(slot, currentFilter)
                                    or (isItemFilterTypeInItemFilterData(itemData, currentFilter, ((isUniversalDecon and activeUniversalTab) or nil)))
                    ) and otherAddonUsesFilters
                end


                if doSingleItemDebug or (debugSpam and not debugSpamExcludeRefreshSubfilterBar and isFCOCompanionJunkTabAtCompanionInv and currentFilter == ITEM_TYPE_DISPLAY_CATEGORY_JUNK) then
                    d("[AF]SubFilterBarButtonEnabled - NO CRAFTING >> " .. itemlink .. " - passesCallback: " ..tos(passesCallback) .. ", passesFilter: " ..tos(passesFilter))
                end
            else
                passesCallback = button.filterCallback(itemData)
                if doSingleItemDebug then d(">>passesCallback - START: " .. tos(passesCallback)) end

                --Todo: ItemData.filterData is not reliable at crafting stations as the items are collected from several different bags!
                --Todo: Thus the filter is always marked as "passed". Is this correct and does it work properly? To test!
                --> Set the currentFilter = itemData.filterData[1], which should be the itemType of the current item
                --currentFilter = itemData.filterData[1]
                passesFilter = passesCallback and otherAddonUsesFilters
                if doSingleItemDebug then d(">>passesFilter - START: " .. tos(passesFilter) .. ", otherAddonUsesFilters: " .. tos(otherAddonUsesFilters)) end

                --Do more filter checks for the crafting types, if the filter passes until now
                --Enchanting extraction
                if passesFilter == true then
                    --Enchanting crafting
                    if craftingType == CRAFTING_TYPE_ENCHANTING then
                        if doSingleItemDebug then d(">enchanting - passesFilter") end
                        --Enchanting extraction
                        if libFiltersPanelId == LF_ENCHANTING_EXTRACTION then
                            if not ZO_SharedSmithingExtraction_IsExtractableItem(itemData) then
                                if doSingleItemDebug then d(">not extractable!!!") end
                                passesFilter = false
                            end
                        end
                    end
                end
                if passesFilter == true then
                    if doSingleItemDebug then d(">>passesFilter 2") end
                    --Jewelry crafting
                    if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
                        --Jewelry deconstruction
                        if libFiltersPanelId == LF_JEWELRY_DECONSTRUCT then
                            passesFilter = passesFilter and not IsItemLinkForcedNotDeconstructable(GetItemLink(bagId, slotIndex))
                        end
                        --Retrait
                    elseif craftingType == CRAFTING_TYPE_INVALID then
                        if libFiltersPanelId == LF_RETRAIT and isRetraitStation then
                            passesFilter = passesFilter and CanItemBeRetraited(bagId, slotIndex)
                        end
                    end
                end
                --Decon/Improvement panel? Golden items are still included in the submenu filters somehow even thought they
                --cannot be improved any further
                if passesFilter == true then
                    if doSingleItemDebug then d(">>passesFilter 3") end
                    if (libFiltersPanelId == LF_SMITHING_DECONSTRUCT or libFiltersPanelId == LF_JEWELRY_DECONSTRUCT) then
                        if not ZO_SharedSmithingExtraction_IsExtractableItem(itemData) then
                            passesFilter = false
                        end
                    elseif (libFiltersPanelId == LF_SMITHING_IMPROVEMENT or libFiltersPanelId == LF_JEWELRY_IMPROVEMENT) then
                        if GetItemDisplayQuality(bagId, slotIndex) == ITEM_DISPLAY_QUALITY_LEGENDARY then
                            passesFilter = false
                        end
                    end
                end

                --Does a "include bank items" checkbox exist and is valid at the crafting table?
                -->vanilla UI checkbox!
                if passesFilter == true and doIncludeBankCBChecks ~= nil and includeBankedItemsChecked ~= nil
                        and (bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK) then
                    if doSingleItemDebug then d(">>passesFilter bank") end
                    --Do not include banked items?
                    if includeBankedItemsChecked == false then
                        if doSingleItemDebug then d(">>>>banked: passes false") end
                        passesFilter = false
                    end
                end

                --Detect that FCOCraftFilter is activated and use it's own filter function on the subFilter button activated check
                if passesFilter == true and FCOCF_filtercallbackFunction ~= nil  then
                    passesFilter = FCOCF_filtercallbackFunction(bagId, slotIndex, true)
                    if doSingleItemDebug then d(">>>>FCOCF: passesFilter:  " .. tos(passesFilter)) end
                end
                --if craftingType == CRAFTING_TYPE_ENCHANTING and passesCallback == true then
                --local itemLink = GetItemLink(bagId, slotIndex)
                --d(">" .. itemLink .. " passesFilter: " ..tos(passesFilter) ..", passesCallback: " ..tos(passesCallback) .. ", otherAddonUsesFilters: " ..tos(otherAddonUsesFilters) .. ", craftingType: " ..tos(craftingType) .. ",libFiltersPanelId: " ..tos(libFiltersPanelId))
                --end
                -- TODO: Check retrait station subfilter buttons greying out properly
                -- TODO: Check jewelry refine subfilter buttons greying out properly
                --if passesCallback and passesFilter then
                --if libFiltersPanelId == LF_JEWELRY_REFINE then
                --    local itemLink = GetItemLink(bagId, slotIndex)
                --    local itemType = GetItemLinkItemType(itemLink)
                --    if itemType == ITEMTYPE_JEWELRY_TRAIT or itemType == ITEMTYPE_JEWELRY_RAW_TRAIT or itemType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER or
                --    itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL or itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER or itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL then
                --d("[AF]SubfilterRefresh: " .. itemLink .. ", passesCallback: " .. tos(passesCallback) .. ", passesFilter: " ..tos(passesFilter))
                --end
                --end
            end

            ------------------------------------------------------------------------------------------------------------
            --Callback and filter pass checks - depending on the shown panel
            ------------------------------------------------------------------------------------------------------------
            if passesCallback and passesFilter then

                if doSingleItemDebug then
                    d("[AF]SubFilterBarButtonEnabled PANEL CHECKS - START >> passesCallback: " ..tos(passesCallback) .. ", passesFilter: " ..tos(passesFilter))
                end
                --Only if not at the vendor buy panel
                if not isVendorBuy then
                    --Check if item is junk and do not pass the callback then!
                    if hasAnyJunkInBag then
                        isItemJunk = IsItemJunk(bagId, slotIndex)
                    end
                    --Check if the item can be sold
                    if isVendorPanel or isFencePanel then
                        isItemSellable = true
                        --[[
                            local itemSellInformation = GetItemLinkSellInformation(GetItemLink(bagId, slotIndex))
                            --ItemSellInformation
                            --        * ITEM_SELL_INFORMATION_CANNOT_SELL = 4
                            --        * ITEM_SELL_INFORMATION_CAN_BE_RESEARCHED = 3
                            --        * ITEM_SELL_INFORMATION_INTRICATE = 2
                            --        * ITEM_SELL_INFORMATION_PRIORITY_SELL = 1
                            --        * ITEM_SELL_INFORMATION_NONE = 0
                            if itemSellInformation == ITEM_SELL_INFORMATION_CANNOT_SELL then
                                isItemSellable = false
                            else
                                isItemSellable = true
                            end
                        ]]
                    end
                    --Check if item is stolen (crafting or banks)
                    if isABankDepositPanel or isVendorPanel or not isNoCrafting or isGuildStoreSellPanel or isFencePanel or isLaunderPanel or isMailSendPanel then
                        isItemStolen = IsItemStolen(bagId, slotIndex)
                    end
                    --Checks for bound and BOP tradeable
                    if isGuildBankDepositPanel or isGuildStoreSellPanel or isMailSendPanel then
                        isBound         = IsItemBound(bagId, slotIndex)
                        isBOPTradeable  = IsItemBoPAndTradeable(bagId, slotIndex)

                        --Is an item below a subfilter but cannot be deposit/sold (bank, guild bank, vendor):
                        --The subfilter button will be still enabled as there are no items to check (will be filtered by ESO vanilla UI BEFORE AF can check them)
                        --if isBankDepositPanel or isHouseBankDepositPanel then
                        --Check if items are not bankable:
                        --isItemBankAble =
                        --end
                        if isGuildBankDepositPanel then
                            --Check if items are not guild bankable:
                            --Stolen items
                            --Bound items
                            --Bound but tradeable items
                            isItemBankAble = not isBound and not isBOPTradeable
                        end
                    end
                    --Companion owned item? Do not show in normal inv but show at companion inv
                    itemIsOwnedByCompanion = (GetItemActorCategory(bagId, slotIndex) == GAMEPLAY_ACTOR_CATEGORY_COMPANION) or false
                end --if not isVendorBuy then
                ----------------------------------------------------------------------------------------

                if doSingleItemDebug then
                    d(">>>NoCrafting: " .. tos(isNoCrafting) .. ", Junk: " .. tos(isItemJunk) .. ", JunkInvButton: " ..tos(isJunkInvButtonActive) ..", Stolen: " .. tos(isItemStolen) .. ", Bound: ".. tos(isBound) ..", BOPTrade: " .. tos(isBOPTradeable) .. ", Sellable: " ..tos(isItemSellable) .. ", Bankable: " ..tos(isItemBankAble))
                end

                --[No crafting panel] (e.g. inventory, bank, guild bank, mail, trade, craftbag):
                --Item is:
                -->no junk
                -->or at junk panel and item is junk

                if isNoCrafting then
                    --[Bank/Guild Bank deposit]
                    --Item is:
                    -->Not stolen
                    -->Bankable (unbound)
                    -->not junk
                    -->Or junk, and junk inventory filter button is active
                    -->Or junk, and itemIsOwnedByCompanion and FCOCompanion's junk is enabled, and junk filter button is active
                    -->not itemIsOwnedByCompanion if not companionFilterButton active
                    if isABankDepositPanel then
                        if hideCharBound == true then
                            itemIsCharBound = (IsItemBound(bagId, slotIndex) and (GetItemBindType(bagId, slotIndex) == BIND_TYPE_ON_PICKUP_BACKPACK)) or false
                        end

                        if FCOCompanionJunkEnabled == true then --#83
                            local isCompanionJunkItem = itemIsOwnedByCompanion and (isJunkInvButtonActive or isJunkButtonActive) --#83
                            doEnableSubFilterButtonAgain = not isItemStolen and isItemBankAble
                                    and (not isItemJunk or (isItemJunk and (isJunkInvButtonActive or isCompanionJunkItem))) --#83
                                    and (isCompanionJunkItem or (not isCompanionJunkItem and ((not isCompanionInvButtonActive and not itemIsOwnedByCompanion) or (isCompanionInvButtonActive and itemIsOwnedByCompanion)))) --#83
                                    and (not hideCharBound or (hideCharBound == true and not itemIsCharBound))
                        else
                            doEnableSubFilterButtonAgain = not isItemStolen and isItemBankAble
                                    and (not isItemJunk or (isItemJunk and isJunkInvButtonActive ))
                                    and ((not isCompanionInvButtonActive and not itemIsOwnedByCompanion) or (isCompanionInvButtonActive and itemIsOwnedByCompanion))
                                    and (not hideCharBound or (hideCharBound == true and not itemIsCharBound))
                        end

                        if doSingleItemDebug then
                            --d(">>>itemIsOwnedByCompanion: " .. tos(itemIsOwnedByCompanion) .. ", isCompanionInvButtonActive: " .. tos(isCompanionInvButtonActive) ..",  Junk: " .. tos(isItemJunk) .. ", JunkInvButton: " ..tos(isJunkInvButtonActive) .. ", JunkButton: " ..tos(isJunkButtonActive) .. ", FCOCompanionJunkEnabled: " ..tos(FCOCompanionJunkEnabled) ..", Stolen: " .. tos(isItemStolen) .. ", Bound: ".. tos(isBound) ..", BOPTrade: " .. tos(isBOPTradeable) .. ", Sellable: " ..tos(isItemSellable) .. ", Bankable: " ..tos(isItemBankAble))
                            d("!>isABankDepositPanel-enable: " ..tos(doEnableSubFilterButtonAgain) .. ", itemIsCharBound: " ..tos(itemIsCharBound) .. ", hideCharBound: " .. tos(hideCharBound))
                        end

                        --[Vendor]
                        --Item is:
                        -->Not stolen
                        -->not junk
                        -->Or junk, and junk inventory filter button is active
                        -->is sellable
                    elseif isVendorPanel then
                        doEnableSubFilterButtonAgain = not isItemStolen and (not isItemJunk or (isJunkInvButtonActive and isItemJunk)) and isItemSellable
                        if doSingleItemDebug then d("!>isVendorPanel-enable: " ..tos(doEnableSubFilterButtonAgain)) end

                        --[Fence sell]
                        --Item is:
                        -->Stolen
                        -->not junk
                        -->Or junk, and junk inventory filter button is active
                        -->sellable at vendor
                    elseif isFencePanel then
                        doEnableSubFilterButtonAgain = isItemStolen and (not isItemJunk or (isJunkInvButtonActive and isItemJunk)) and isItemSellable
                        if doSingleItemDebug then d("!>isFencePanel-enable: " ..tos(doEnableSubFilterButtonAgain)) end

                        --[Fence launder]
                        --Item is:
                        -->Stolen
                        -->not junk
                        -->Or junk, and junk inventory filter button is active
                    elseif isLaunderPanel then
                        doEnableSubFilterButtonAgain = isItemStolen and (not isItemJunk or (isJunkInvButtonActive and isItemJunk))
                        if doSingleItemDebug then d("!>isLaunderPanel-enable: " ..tos(doEnableSubFilterButtonAgain)) end

                        --[Guild store list/sell]
                        --Item is:
                        -->Not stolen
                        -->not junk
                        -->not bound
                    elseif isGuildStoreSellPanel then
                        doEnableSubFilterButtonAgain = not isItemStolen and not isBound and not isBOPTradeable and (not isItemJunk or (isJunkInvButtonActive and isItemJunk)) --#82
                        if doSingleItemDebug then d("!>isGuildStoreSellPanel-enable: " ..tos(doEnableSubFilterButtonAgain)) end

                        --[Vendor buy]
                        --Item is:
                        -->not junk
                        -->Or junk, and junk inventory filter button is active
                    elseif isVendorBuy then
                        doEnableSubFilterButtonAgain = (not isItemJunk or (isJunkInvButtonActive and isItemJunk))
                        if doSingleItemDebug then d("!>isVendorBuy-enable: " ..tos(doEnableSubFilterButtonAgain)) end

                        --[Mail send]
                        --Item is:
                        -->not stolen
                        -->not bound
                    elseif isMailSendPanel then
                        doEnableSubFilterButtonAgain = not isItemStolen and not isBound
                        if doSingleItemDebug then d("!>isMailSendPanel-enable: " ..tos(doEnableSubFilterButtonAgain)) end

                        --[Companion inventory]
                    elseif isCompanionInvPanel then
                        --d(">isCompanionInvPanel - FCOCompanionJunkEnabled: " ..tos(FCOCompanionJunkEnabled))
                        --FCOCompanion Junk is enabled?
                        if FCOCompanionJunkEnabled == true then
                            --Item is:
                            --Item is:
                            --owned by companion
                            -->not junk
                            -->or junk and companionInvJunkTab is active
                            doEnableSubFilterButtonAgain = (itemIsOwnedByCompanion and (not isItemJunk or (isItemJunk and isJunkButtonActive))) --isJunkButtonActive will be set to true if the companionInvJunk subfilterBar is currently active
                            if doSingleItemDebug then d("!>isCompanionInvPanel FCOCompanionJunkEnabled-enable: " ..tos(doEnableSubFilterButtonAgain)) end

                        else
                            --Normal Companion inventory
                            --Item is:
                            --owned by companion
                            -->not junk
                            doEnableSubFilterButtonAgain = (itemIsOwnedByCompanion and not isItemJunk)
                            if doSingleItemDebug then d("!>isCompanionInvPanel-enable: " ..tos(doEnableSubFilterButtonAgain)) end
                        end


                        --Cyrodiil Vengeance inventory
                    --elseif isVengeanceInvPanel then
                        --todo 2025-09-18 Anything to do extra here?


                    --Others & other addons
                    else
                        --FCOCompanion Junk is enabled?
                        if FCOCompanionJunkEnabled == true then
                            --Item is:
                            -->ownedByCompanion as companionFilterButton is active
                            -->not junk
                            -->Or junk, and junk inventory filter or bank withdraw junk filter button is active
                            -->Or junk, and junk inventory filter or bank withdraw junk filter button is active, and ownedByCompanion
                            doEnableSubFilterButtonAgain = (not isItemJunk or ((isJunkInvButtonActive or isJunkButtonActive) and isItemJunk))
                                    and (
                                    ((isJunkInvButtonActive or isJunkButtonActive) and itemIsOwnedByCompanion) or --#83 or isJunkInvButtonActive -> changed to or isJunkButtonActive
                                            (not isCompanionInvButtonActive and not itemIsOwnedByCompanion) or
                                            (isCompanionInvButtonActive and itemIsOwnedByCompanion)
                            )
                            if doSingleItemDebug then d("!>OTHERS FCOCompanionJunkEnabled-enable: " ..tos(doEnableSubFilterButtonAgain)) end

                            --[Normal inventory, mail, trade, craftbag]
                        else
                            --Item is:
                            -->ownedByCompanion as companionFilterButton is active
                            -->not junk
                            -->Or junk, and junk inventory filter or bank withdraw junk filter button is active
                            doEnableSubFilterButtonAgain = (not isItemJunk or ((isJunkInvButtonActive or isJunkButtonActive) and isItemJunk))
                                    and ((not isCompanionInvButtonActive and not itemIsOwnedByCompanion) or (isCompanionInvButtonActive and itemIsOwnedByCompanion))
                            if doSingleItemDebug then d("!>OTHERS-enable: " ..tos(doEnableSubFilterButtonAgain)) end
                        end
                    end

                        ----------------------------------------------------------------------------------------
                        --[Crafting panel] (e.g. refine, creation, deconstruction, improvement, research, recipes, extraction, retrait):
                        --Item is:
                        -->Not stolen (currently deactivated!)
                else -- if isNoCrafting then
                    --if isRetraitStation and button.name == "Shield" then
                    --d(">" .. GetItemLink(bagId, slotIndex) .. " passesCallback: " ..tos(passesCallback) .. ", otherAddonUsesFilters: " .. tos(otherAddonUsesFilters) .. ", passesFilter: " ..tos(passesFilter) .. ", canBeRetraited: " .. tos(CanItemBeRetraited(bagId, slotIndex)) .. " - doEnableSubFilterButtonAgain: " ..tos(doEnableSubFilterButtonAgain))
                    --end

                    itemsFound = itemsFound + 1
--d("<<IsNoCrafting: false, itemsFound: " ..tos(itemsFound))
                    --d("<<< Crafting station: " ..tos(itemsFound))
                    --doEnableSubFilterButtonAgain = not isItemStolen
                    doEnableSubFilterButtonAgain = (itemsFound > 0) or false
                    if doSingleItemDebug then d("!>NO CRAFTING-enable: " ..tos(doEnableSubFilterButtonAgain)) end


                end -- if isNoCrafting then
                if doEnableSubFilterButtonAgain then
                    breakInventorySlotsLoopNow = true
                    break
                end
            else --if passesCallback and passesFilter then
                --d("<<< did not pass filter or callback!")
            end --if passesCallback and passesFilter then
        end -- for ... itemData in bagData
        --d(">breakInventorySlotsLoopNow: " ..tos(breakInventorySlotsLoopNow) .. ", doEnableSubFilterButtonAgain: " .. tos(doEnableSubFilterButtonAgain))
    end -- function checkBagContentsNow(bag, bagData, realInvType, button)
    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------
    local playerInvVar = controlsForChecks.playerInv

    --Check if filters apply to the subfilter and change the color of the subfilter button
    for _, button in ipairs(subfilterBar.subfilterButtons) do
        if debugSpam then
            d(">>onlyEnableAllSubfilterBarButtons: " ..tos(onlyEnableAllSubfilterBarButtons))
            if not debugSpamExcludeRefreshSubfilterBar then d(">==========>Checking button: " .. tos(button.name)) end
        end
        if onlyEnableAllSubfilterBarButtons == true or not grayOutSubFiltersWithNoItems then
            doEnableSubFilterButtonAgain = true
        else -- if onlyEnableAllSubfilterBarButtons == true or not grayOutSubFiltersWithNoItems then
            if button.name ~= AF_CONST_ALL then
                --Setting to disable subfilter buttons with no items is enabled?
                doEnableSubFilterButtonAgain = false
                breakInventorySlotsLoopNow = false
                --Disable button first (May be enabled further down again if checks allow it)
                if button.clickable then
                    if debugSpam and not debugSpamExcludeRefreshSubfilterBar then d(">disabling button: " ..tos(button.name)) end
                    button.texture:SetColor(.3, .3, .3, .9)
                    button:SetEnabled(false)
                    button.clickable = false
                end
                --Check each inventory now
                if not isVendorBuyInv then
                    for _, realInvType in pairs(realInvTypes) do
                        if breakInventorySlotsLoopNow then break end
                        breakInventorySlotsLoopNow = false
                        inventory = playerInvVar.inventories[realInvType]
                        if inventory ~= nil and inventory.slots ~= nil then
                            --Get the current filter. Normally this comes from the inventory. Crafting currentFilter determination is more complex!
                            if isNoCrafting and not isUniversalDecon and not isFCOCompanionJunkTabAtCompanionInv then
                                currentFilter = inventory.currentFilter
                            --UniversalDeconstruction panel and FCOCompanion currentFilter should be the one of the active inventoryType
                            -->detected automatically
                            elseif isUniversalDecon or isFCOCompanionJunkTabAtCompanionInv then
                                currentFilter = getCurrentFilter(inventoryType)
                                --d(">universalDecon - invType: " ..tos(realInvType) .. ", currentFilter: " .. tos(currentFilter))
                                --else
                                --Todo: ItemData.filterData is not reliable at crafting stations as the items are collected from several different bags!
                                --Todo: Thus the filter is always marked as "passed". Is this correct and does it work properly? To test!
                                --Todo: Enable this section again if currentFilter is needed further down in this function!
                                --[[
                                local invType = getCurrentFilterTypeForInventory(AF.currentInventoryType)
                                local craftingFilter = util.GetCraftingTablePanelFilter(invType)
                                currentFilter = util.MapCraftingStationFilterType2ItemFilterType(craftingFilter, invType, craftingType)
                                ]]
                            end -- if isNoCrafting then
                            inventorySlots = inventory.slots

                            --Check subfilterbutton for items, using the filter function and junk checks (only for non-crafting stations)
                            for bag, bagData in pairs(inventorySlots) do
                                if breakInventorySlotsLoopNow then break end
                                checkBagContentsNow(bag, bagData, realInvType, button)
                                if doEnableSubFilterButtonAgain then
                                    --d(">>> !!! subfilterButton got enabled again !!!")
                                    breakInventorySlotsLoopNow = true
                                end
                            end --for bag, bagData in pairs(inventorySlots) do
                        end -- if inventory ~= nil and inventory.slots ~= nil then

                        if doEnableSubFilterButtonAgain then
                            --d(">>>> !!!! subfilterButton got enabled again !!!!")
                            breakInventorySlotsLoopNow = true
                        end
                    end --for _, realInvType in pairs(realInvTypes) do

                    --Check the worn items as well? (for LF_SMITHING_IMPROVEMENT e.g.)
                    if not doEnableSubFilterButtonAgain and bagWornItemCache ~= nil then
                        for _, data in pairs(bagWornItemCache) do
                            checkBagContentsNow(BAG_WORN, data, INVENTORY_BACKPACK, button)
                            if doEnableSubFilterButtonAgain then
                                --d(">>>>> !!!!! BAG_WORN: subfilterButton got enabled again !!!!")
                                breakInventorySlotsLoopNow = true
                                break
                            end
                        end --for _, data in pairs(bagWornItemCache) do
                    end --if not doEnableSubFilterButtonAgain and bagWornItemCache ~= nil then

                    --Vendor buy panel
                elseif bagVendorBuy ~= nil and isVendorBuy == true then
                    currentFilter = getCurrentFilter(inventoryType)
                    checkBagContentsNow(nil, bagVendorBuy, INVENTORY_TYPE_VENDOR_BUY, button)
                end -- if not isVendorBuyInv then
            end -- if button.name ~= AF_CONST_ALL then
        end --if onlyEnableAllSubfilterBarButtons == true or not grayOutSubFiltersWithNoItems then

        --Enable the subfilter button again now?
        if doEnableSubFilterButtonAgain == true then
            if debugSpam and not debugSpamExcludeRefreshSubfilterBar then d(">Enabling button again: " .. tos(button.name)) end
            button.texture:SetColor(1, 1, 1, 1)
            button:SetEnabled(true)
            button.clickable = true
        else
            --Is the button currently selected but shouldn't be enabled (as no items are filtered below anymore)?
            --e.g. by equipping the last filtered item: Select the ALL subfilter button then instead
            --todo
            if debugSpam and not debugSpamExcludeRefreshSubfilterBar then d(">No items left to filter, Enabling the \'All\' button now") end
        end -- if doEnableSubFilterButtonAgain == true then
    end --for _, button in ipairs(subfilterBar.subfilterButtons) do
end

--Get the list's control name for the subfilterBar reanchor
function util.GetListControlForSubfilterBarReanchor(inventoryType)
    local filterPanelId = getCurrentFilterTypeForInventory(inventoryType)
--d("[AF]util.GetListControlForSubfilterBarReanchor-inventoryType: " ..tos(inventoryType) .. ", filterPanelId: " ..tos(filterPanelId))
    local listControlsForSubfilterBarReanchor = AF.listControlForSubfilterBarReanchor
    local listControlForSubfilterBarReanchorData = listControlsForSubfilterBarReanchor[filterPanelId]
    local listData
    local moveInvBottomBarDown = false
    local reanchorData
    if listControlForSubfilterBarReanchorData then
        listData = listControlForSubfilterBarReanchorData.listData
        moveInvBottomBarDown = listControlForSubfilterBarReanchorData.moveInvBottomBarDown
        reanchorData = listControlForSubfilterBarReanchorData.reanchorData
    end
    return listData, moveInvBottomBarDown, reanchorData
end

--======================================================================================================================
-- -^- Subfilter bar functions                                                                                      -^-
--======================================================================================================================

--======================================================================================================================
-- -v- Filter functions                                                                                             -v-
--======================================================================================================================

--Apply the LiFilters filter to the inventory now
function util.ApplyFilter(button, filterTag, requestUpdate, filterType, inventoryTypeOfFilterBar)
    local debugSpam = AF.settings.debugSpam
    if debugSpam then
        d("[AF]ApplyFilter_VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV")
        AF._lastClickedSubFilterBarButton = button
    end
    local currentInvType    = inventoryTypeOfFilterBar or AF.currentInventoryType
    if debugSpam then d(">FilterTag: " .. tos(filterTag) .. " for filterType " .. tos(filterType) .. " and inventoryType " .. tos(currentInvType) .. ", requestUpdate: " ..tos(requestUpdate)) end
    --local LibFilters        = util.LibFilters
    libFilters = libFilters or util.LibFilters

    local callback          = button.filterCallback
    local filterTypeToUse   = filterType or getCurrentFilterTypeForInventory(currentInvType, true)
    local delay             = 0
    local buttonName        = button.name


    if debugSpam then d(">" .. tos(buttonName) .. " |  filterTypeUpdated: " .. tos(filterTypeToUse)) end
    --if something isn't right, abort
    local errorSuffix = "Tag \'" .. filterTag .. "\', button \'" .. tos(buttonName) .. "\', filterType: \'" ..tos(filterTypeToUse) .. "\', groupName: \'" .. tos(button.groupName) .. "\'"
    if callback == nil then
        d("[AdvancedFilters] ERROR - ApplyFilter: Callback at inventory \'".. tos(currentInvType) .. "\' was nil!\n" .. errorSuffix)
        return
    end
    if filterTypeToUse == nil then
        d("[AdvancedFilters] ERROR - ApplyFilter: FilterType at inventory \'".. tos(currentInvType) .. "\'  was nil!\n" .. errorSuffix)
        return
    end

    --Save the currently selected filter dropdown box entry
    if filterTag == AF_CONST_DROPDOWN_FILTER then
        if debugSpam then d(">util.ApplyFilter-Dropdownbox selected filter entry updated: " ..tos(button.name)) end
        AF.currentlySelectedDropDownEntry = button
    end

    --Check if the parameter to reset the current dropdown filter to "All" was registered
    -->This is needed if the dropdown filters rely on the currently "shown" (and thus already filtered) inventory items
    -->to only use these for their filter functions/comparisons, and not ALL items of the inventories involved
    if filterTag == AF_CONST_DROPDOWN_FILTER and button.filterResetAtStart then
        if debugSpam then d(">util.ApplyFilter-Dropdownbox filter reset at start") end
        delay = button.filterResetAtStartDelay or 50 --Set delay so the next dropdown filter will be called AFTER evertyhing got updated
        --Clear the filters and refresh the visible inventory items now.
        --Do not change the dropdownbox entry to "ALL" or the "lastSelectedDropdownEntry" will be changed as well!
        --Clear current filters without an update
        libFilters:UnregisterFilter(filterTag)
        --Update the inventory to show all items unfiltered again
        libFilters:RequestUpdate(filterTypeToUse)
    end

    --Call delayed if the dropdown filter was reset to all
    zo_callLater(function()
        if debugSpam then d(">>util.ApplyFilter-delayed call 1 -> LibFilters register: " ..tos(filterTag) .. " - " ..tos(filterTypeToUse)) end
        --Check if a function should be executed before the filters get applied
        local filterStartCallback = button.filterStartCallback
        if filterStartCallback and type(filterStartCallback) == "function" then
            if debugSpam then d(">>>util.ApplyFilter-filterStartCallback: " ..tos(filterTag) .. " - " ..tos(filterTypeToUse)) end
            filterStartCallback()
        end
        --Only for the dropdown box filters and ONLY for non-standard AdvancedFilters dropdown entries
        -->(isStandardAFDropdownFilter is added in function AF.util.BuildDropdownCallbacks as AF_FilterBar:ActivateButton() is called)
        if filterTag == AF_CONST_DROPDOWN_FILTER and not button.isStandardAFDropdownFilter then
            if debugSpam then d(">>>util.ApplyFilter-dropdown box, standard AF dropdown filter: " ..tos(filterTag) .. " - " ..tos(filterTypeToUse)) end
            --Check if the research panel is opened and build the prefilter data for the horizontal scroll list
            --depending on the currently selected subfilterBar button's name and group
            -->First parameter "true" will start the prefiltering
            --->Will check table AF.subfilterCallbacks with the group and name to get the entry of the selected button.
            --->Then it will use the data in the subTable "filterForAll" to prefiltzer some values like itemType, equipType, armorType or traitType
            util.CheckForResearchPanelAndRunFilterFunction(true, nil, nil, nil)
        end

        --first, clear current filters without an update
        -->if not cleared before!
        if not button.filterResetAtStart then
            if debugSpam then d(">>>util.ApplyFilter-UnregisterFilter: " ..tos(filterTag) .. " - " ..tos(filterTypeToUse)) end
            libFilters:UnregisterFilter(filterTag)
        end
        --then register new one and hand off update parameter
        if debugSpam then d(">>>util.ApplyFilter-RegisterFilter: " ..tos(filterTag) .. ", filterTypeToUse: " ..tos(filterTypeToUse)) end
        libFilters:RegisterFilter(filterTag, filterTypeToUse, callback)
        if requestUpdate == true then
            if debugSpam then d(">>>util.ApplyFilter-Request update") end
            --Delay the update as there might be several incoming refresh calls from e.g. AF_CONST_BUTTON_FILTER and AF_CONST_DROPDOWN_FILTER
            -->Is already handled by LibFilters3 on it's own!
            --ThrottledUpdate("LibFilters_RequestUpdate_" .. tos(filterTypeToUse), 10, function() LibFilters:RequestUpdate(filterTypeToUse) end)
            libFilters:RequestUpdate(filterTypeToUse)
        end

        --Update the count of filtered/shown items in the inventory FreeSlot label
        --Delay this function call as the data needs to be filtered first!
        zo_callLater(function()
            if debugSpam then d(">>util.ApplyFilter-delayed call 2 -> UpdateCraftingInventoryFilteredCount: " ..tos(filterTag) .. " - " ..tos(filterTypeToUse)) end
            --Update the shown filtered item count at the inventory bottom line, if the inventory got a label for it
            --util.UpdateCraftingInventoryFilteredCount(currentInvType)
            --Delay the update as there might be several incoming refresh calls from e.g. AF_CONST_BUTTON_FILTER and AF_CONST_DROPDOWN_FILTER
            ThrottledUpdate("UpdateCraftingInventoryFilteredCount_" .. tos(currentInvType), 10, updateCraftingInventoryFilteredCount, currentInvType)

            --Run an end callback function now?
            local endCallback = button.filterEndCallback
            if endCallback and type(endCallback) == "function" then
                if debugSpam then d(">>>util.ApplyFilter-End callback: " ..tos(filterTag) .. " - " ..tos(filterTypeToUse)) end
                endCallback()
            end
        end, 50)
    end, delay)
    if debugSpam then
        d("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
        AF._lastClickedSubFilterBarButton = button
    end
end

--Remove all registered filters of buttons and dropdown boxes and update the inventory
function util.RemoveAllFilters()
    if AF.settings.debugSpam then d("[AF]util.RemoveAllFilters") end
    local libFilters = util.LibFilters
    local filterType = getCurrentFilterTypeForInventory(AF.currentInventoryType, true)

    libFilters:UnregisterFilter(AF_CONST_BUTTON_FILTER)
    libFilters:UnregisterFilter(AF_CONST_DROPDOWN_FILTER)

    if filterType ~= nil then libFilters:RequestUpdate(filterType) end
end

--Check if an item's filterData contains an itemFilterType
function util.IsItemFilterTypeInItemFilterData(slot, currentFilter, universalDeconCurrentlySelectedTab)
    if slot == nil or currentFilter == nil then return false end
    local retVar
    if universalDeconCurrentlySelectedTab ~= nil then
        retVar = false
        local isDeconstructable = ZO_UniversalDeconstructionPanel_Shared.IsDeconstructableItem(slot, nil) --2nd param are the craftingTypes of vanilla UI's multiDropDownBox
        if isDeconstructable == true then
            --Check the itemFilterTypes
            local filter = universalDeconCurrentlySelectedTab.filter
            if filter == nil then filter = universalDeconPanelInv:GetCurrentFilter() end
            retVar = ZO_UniversalDeconstructionPanel_Shared.DoesItemPassFilter(slot.bagId, slot.slotIndex, filter)
        end
--d(">universalDecon isDeconstructable: " ..tos(isDeconstructable) .. ", retVar: " ..tos(retVar))
    else
        --if itemFilterData == nil or itemFilterType == nil then return false end
        --[[
        for _, itemFilterTypeInFilterData in ipairs(itemFilterData) do
            if itemFilterTypeInFilterData == itemFilterType then return true end
        end
        ]]
        --Seems "itemData.filterData" contains the new ITEM_TYPE_DISPLAY_CATEGORY_* values now as well!
        --use this function to map it: ITEM_FILTER_UTILS.IsSlotFilterDataInItemTypeDisplayCategory(slot, currentFilter)
        retVar = ITEM_FILTER_UTILS.IsSlotFilterDataInItemTypeDisplayCategory(slot, currentFilter)
    end
--[[
    if retVar == true and AF.settings.debugSpam then
d("[AF]util.IsItemFilterTypeInItemFilterData - passesFilter: true")
    end
]]
    return retVar
end

--Filter a horizontal scroll list and run a filterFunction given to determine the entries to show in the
--horizontal list afterwards
function util.FilterHorizontalScrollList(runPrefilterForAllSelection, horizontalScrollList, filterOrEquipTypes, armorTypes, traitTypes)
    if not horizontalScrollList then return false end
    runPrefilterForAllSelection = runPrefilterForAllSelection or false
    --if AF.settings.debugSpam then d("[AF]util.FilterHorizontalScrollList") end

    --==================================================================================================================
    -- -v- SMITHING Research horizontal scrolllist?                                                                 -v-
    --==================================================================================================================
    if horizontalScrollList == controlsForChecks.researchLineList then
        libFilters = libFilters or util.LibFilters
        if not libFilters:IsResearchShown() then return end

--d("[AF]util.FilterHorizontalScrollList - runPrefilterForAllSelection: " ..tos(runPrefilterForAllSelection))
        local craftingType = getCraftingType()
        if craftingType == CRAFTING_TYPE_INVALID then return false end

        --Unregister the old filters for the horizontal scroll list, of this addon
        -->If we do this here the 2nd call to util.FilterHorizontalScrollList (why is it called twice? Once for filterButton from submenuFilterBar, and anoher one for the dropdown box?)
        -->will delete the filtered skipTable :-(
        --clearResearchPanelCustomFilters(craftingType)

        --Now check for teh current filters and register them
        local researchLineListArmorTypes = AF.researchLinesToArmorType[craftingType]
        local filterPanelId = getCurrentFilterTypeForInventory(AF.currentInventoryType)
        local craftingStationFilter = getCraftingTablePanelFilter(filterPanelId)
        local researchLineListIndicesOfWeaponOrArmorOrJewelryTypesBase = AF.researchLineListIndicesOfWeaponOrArmorOrJewelryTypes[craftingType]
        --local craftingPanel =  util.GetCraftingTablePanel(filterPanelId)
        --if AF.settings.debugSpam then d("[AF]util.FilterHorizontalScrollListcraftingType: " ..tos(craftingType) .. ", craftingPanel: " .. tos(craftingPanel.control:GetName()) .. ", craftingFilter: " ..tos(craftingStationFilter)) end
        if not researchLineListIndicesOfWeaponOrArmorOrJewelryTypesBase then
            d("[AdvancedFilters] ERROR util.FilterHorizontalScrollList: Abort->Crafting table crafting type (".. tos(craftingType) .. ") is not known in \'AF.researchLineListIndicesOfWeaponOrArmorOrJewelryTypes\'")
            return
        end
        local researchLineListIndicesOfWeaponOrArmorOrJewelryTypes = researchLineListIndicesOfWeaponOrArmorOrJewelryTypesBase[craftingStationFilter]
        if not researchLineListIndicesOfWeaponOrArmorOrJewelryTypes then
            d("[AdvancedFilters] ERROR util.FilterHorizontalScrollList: Abort->Crafting table filter type (".. tos(craftingStationFilter) .. ") is not known in \'AF.researchLineListIndicesOfWeaponOrArmorOrJewelryTypes\'")
            return
        end
        local researchLineListIndexOfWeaponOrArmorOrJewelryType = 0
        --Rebuild the list but filter the items by applying new filter to the current libFilter filterPanelId
        --which then will be used inside the :Refresh() function of the panel

        --Prefilter some entries if the ALL button was chosen?
        local filterOrEquipTypesPreFiltered, armorTypesPreFiltered
        if runPrefilterForAllSelection then
            --Check which button is currently active. If it's not ALL then the ALL dropdown entry was selected.
            --Check which button is active and prefilter the list with the determined filterTypes, equipTypes and/or armorTypes
            filterOrEquipTypesPreFiltered, armorTypesPreFiltered = util.PreFilterWithSubfilterBarButtonFilterForAll()
        end
        --Add the prefilters to the current filters
        if filterOrEquipTypesPreFiltered then
            if not filterOrEquipTypes then
                filterOrEquipTypes = filterOrEquipTypesPreFiltered
            else
                if type(filterOrEquipTypes) == "table" then
                    for _, filterOrEquipType in ipairs(filterOrEquipTypesPreFiltered) do
                        table.insert(filterOrEquipTypes, filterOrEquipType)
                    end
                else
                    local filterOrEquipType = filterOrEquipTypes
                    filterOrEquipTypes = {}
                    filterOrEquipTypes = filterOrEquipTypesPreFiltered
                    table.insert(filterOrEquipTypes, filterOrEquipType)
                end
            end
        end
        if armorTypesPreFiltered then
            if not armorTypes then
                armorTypes = armorTypesPreFiltered
            else
                if type(armorTypes) == "table" then
                    for _, armorType in ipairs(armorTypesPreFiltered) do
                        table.insert(armorTypes, armorType)
                    end
                else
                    local armorType = armorTypes
                    armorTypes = {}
                    armorTypes = armorTypesPreFiltered
                    table.insert(armorTypes, armorType)
                end
            end
        end

        --Count the filterTypes
        local filterTypeCount = 0
        if filterOrEquipTypes ~= nil then
            if type(filterOrEquipTypes) == "table" then
                filterTypeCount = #filterOrEquipTypes
                if filterTypeCount == 1 then
                    researchLineListIndexOfWeaponOrArmorOrJewelryType = researchLineListIndicesOfWeaponOrArmorOrJewelryTypes[filterOrEquipTypes[1]]
                end
            else
                filterTypeCount = 1
                researchLineListIndexOfWeaponOrArmorOrJewelryType = researchLineListIndicesOfWeaponOrArmorOrJewelryTypes[filterOrEquipTypes]
            end
        end
        --Count the armorTypes
        local armorTypeCount = 0
        if armorTypes ~= nil then
            if type(armorTypes) == "table" then
                armorTypeCount = #armorTypes
            else
                armorTypeCount = 1
            end
        end
        --Count the traitTypes
        local traitTypeCount = 0
        if traitTypes ~= nil then
            if type(traitTypes) == "table" then
                traitTypeCount = #traitTypes
            else
                traitTypeCount = 1
            end
        end
        --if AF.settings.debugSpam then d("[AF]filterTypeCount: " ..tos(filterTypeCount) .. ", armorTypeCount: " ..tos(armorTypeCount) .. ", traitTypeCount: " ..tos(traitTypeCount)) end

--d("[AF]filterPanelId: " ..tos(filterPanelId) ..", filterTypeCount: " ..tos(filterTypeCount) .. ", armorTypeCount: " ..tos(armorTypeCount) .. ", traitTypeCount: " ..tos(traitTypeCount))

        --Nothing should be filtered? Abort here and allow all entries
        if filterPanelId ~= nil then
            local wasFilteredByAdvancedFilters = false
            if filterTypeCount ~= 0 or armorTypeCount ~= 0 or traitTypeCount ~= 0 then
            --Check the researchLinIndices for their filterOrEquiupType, armorType and traitType at the current filterPanelId
                --Check the current crafting table's research line for the indices and build a "skip table" for LibFilters-3.0
                local fromResearchLineIndex = 1
                local toResearchLineIndex = GetNumSmithingResearchLines(craftingType)
                local skipTable = {}
                --Check for each possible researchLine at the given crafting station
                local researchLineAtCraftingStationToFilterType = AF.researchLinesToFilterTypes[craftingType]
                if researchLineAtCraftingStationToFilterType then
                    for researchLineIndex = 1, toResearchLineIndex do
                        --d(">researchLineIndex: " ..tos(researchLineIndex) .. ", name: " .. tos(GetSmithingResearchLineInfo(craftingType, researchLineIndex)))
                        --Get the current filterType at the researchLineIndex
                        local researchLineIndexIsAllowed = false
                        --Check filterOrEquippmentTypes + armor types
                        if filterTypeCount > 0 then
                            --d(">check filterOrEquipType")
                            local filterTypeOfResearchLineIndex = researchLineAtCraftingStationToFilterType[researchLineIndex]
                            if filterTypeOfResearchLineIndex then
                                --d(">filterTypeOfResearchLineIndex: " ..tos(filterTypeOfResearchLineIndex))
                                --Check each filterType
                                if type(filterOrEquipTypes) == "table" then
                                    for _, filterType in ipairs(filterOrEquipTypes) do
                                        if filterType == filterTypeOfResearchLineIndex then
                                            --d(">found matching equipType: " ..tos(filterType))
                                            researchLineIndexIsAllowed = true
                                            break --exit the inner filterOrEquipTyps for .. loop of filterTypes
                                        end
                                    end
                                else
                                    if filterOrEquipTypes == filterTypeOfResearchLineIndex then
                                        researchLineIndexIsAllowed = true
                                        --d(">found matching equipType: " ..tos(filterOrEquipTypes))
                                    end
                                end
                            end
                        end
                        --Check armor types (if not checked within filterOrEquipType before)
                        if armorTypeCount > 0 and ((researchLineIndexIsAllowed and filterTypeCount > 0) or (not researchLineIndexIsAllowed and filterTypeCount == 0)) then
                            researchLineIndexIsAllowed = false
                            --d(">researchLineIndexIsAllowed: " .. tos(researchLineIndexIsAllowed) .." -> check armorType")
                            if armorTypes and researchLineListArmorTypes then
                                local researchLineListArmorType = researchLineListArmorTypes[researchLineIndex]
                                if researchLineListArmorType then
                                    --d(">researchLineListArmorType: " ..tos(researchLineListArmorType))
                                    if type(armorTypes) == "table" then
                                        for _, armorType in ipairs(armorTypes) do
                                            if armorType == researchLineListArmorType then
                                                --d(">found matching armorType: " ..tos(armorType))
                                                researchLineIndexIsAllowed = true
                                                break --exit the inner inner armorTypes for .. loop
                                            end
                                        end
                                    else
                                        if armorTypes == researchLineListArmorType then
                                            researchLineIndexIsAllowed = true
                                            --d(">found matching armorType: " ..tos(armorTypes))
                                        end
                                    end
                                end
                            else
                                researchLineIndexIsAllowed = true
                            end
                        end
                        --Check traits
                        --Is the researchLineIndex allowed so far because of the matching filterOrEquipType and/or armor type?
                        --Or not allowed as filterOrEquipType and armorType were not checked
                        if traitTypeCount > 0 and ((researchLineIndexIsAllowed and (filterTypeCount > 0 or armorTypeCount > 0)) or (not researchLineIndexIsAllowed and (filterTypeCount == 0 and armorTypeCount == 0)) )then
                            researchLineIndexIsAllowed = false
                            --d(">researchLineIndexIsAllowed: " .. tos(researchLineIndexIsAllowed) .." -> check traitType")
                            local researchLineListTraitType = GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, 1)
                            --d(">researchLine trait: " ..tos(researchLineListTraitType))
                            --Check if the traitTypes are given and mathcing as well
                            if type(traitTypes) == "table" then
                                for _, traitType in ipairs(traitTypes) do
                                    if traitType == researchLineListTraitType then
                                        --d(">found matching trait: " ..tos(traitType))
                                        researchLineIndexIsAllowed = true
                                        break --exit the inner inner traitTypes for .. loop
                                    end
                                end
                            else
                                if traitTypes == researchLineListTraitType then
                                    --d(">!!!found matching trait: " ..tos(traitTypes))
                                    researchLineIndexIsAllowed = true
                                end
                            end
                        end
                        --FilterType is not allowed? Add it to the skip table
                        if not researchLineIndexIsAllowed then
                            --if AF.settings.debugSpam then d("<<<<skipping researchLineIndex: " .. tos(researchLineIndex) .. ", name: " ..tos(GetSmithingResearchLineInfo(craftingType, researchLineIndex))) end
                            --d("<<<<skipping researchLineIndex: " .. tos(researchLineIndex) .. ", name: " ..tos(GetSmithingResearchLineInfo(craftingType, researchLineIndex)))
                            skipTable[researchLineIndex] = true
                        else
                            --if AF.settings.debugSpam then d(">>>>>adding researchLineIndex: " .. tos(researchLineIndex) .. ", name: " ..tos(GetSmithingResearchLineInfo(craftingType, researchLineIndex))) end
                        end
                    end
                    --local expectedTypeFilter = ZO_CraftingUtils_GetSmithingFilterFromTrait(GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, 1)) --returns 2 for weapons and 4 for armor, ? for jewelry

                    --Set the from and to and the skipTable values for the loop "for researchLineIndex = 1, GetNumSmithingResearchLines(craftingType) do"
                    --in function SMITHING.researchPanel.Refresh
                    -->Was overwritten in LibFilters-3.0 helper functions and the function LibFilters3.SetResearchLineLoopValues(from, to, skipTable) was added
                    -->to set the values for your needs
                    --d(">util.LibFilters:SetResearchLineLoopValues")
                    --util.LibFilters:SetResearchLineLoopValues(fromResearchLineIndex, toResearchLineIndex, skipTable)
                    if NonContiguousCount(skipTable) > 0 then
                        libFilters:RegisterResearchHorizontalScrollbarFilter("AF_ResearchHorizontalScrollBarFilter", craftingType, skipTable, fromResearchLineIndex, toResearchLineIndex, true)
                        wasFilteredByAdvancedFilters = true
                    end
                end

--            else
--d("<Nothing to filter!")
            end -- if filterTypeCount ~= 0 or armorTypeCount ~= 0 or traitTypeCount ~= 0 then


            --Is FCOCraftFilter enabled? Then update it's skipTable too and register / unregister it's filters
            --Update of the researchPanel filters and horizontal scrollbar filters will be done by AdvancedFilters below then!
            local FCOCraftFilterisActive = (FCOCF ~= nil and FCOCF.CallCurrentlyResearchedItemsFilter ~= nil and true) or false
            if FCOCraftFilterisActive == true then
                FCOCF.CallCurrentlyResearchedItemsFilter(false)
            end

            --Refresh -> rebuild and Commit the new list
            --d(">controlsForChecks.researchPanel:Refresh()")
            --controlsForChecks.researchPanel:Refresh() --> Will rebuild the list entries and call list:Commit()
            if wasFilteredByAdvancedFilters == true or FCOCraftFilterisActive == true then
                libFilters:RequestUpdateForResearchFilters(0)

                --TODO: Somehow the researchPanel:Refresh() function is called twice, except for the "ALL" filter button?? WHY???
                --      Due to this we need to clear the variables delayed here and cannot do this within LibFilters3 as the 2nd call to Refresh would show
                --      all entries in the horizontal list again then :-(
                util.ThrottledUpdate("AF_ClearResearchPanelCustomFilters", 50, clearResearchPanelCustomFilters, craftingType)
            end


            --AdvancedFilters itsself filtered some entries at teh horizontal list?
            if wasFilteredByAdvancedFilters == true then
                --Scroll the list to the selected weapon or armorType
                if not researchLineListIndexOfWeaponOrArmorOrJewelryType then researchLineListIndexOfWeaponOrArmorOrJewelryType = 0 end
                zo_callLater(function()
                    --d(">researchLineListIndexOfWeaponOrArmorType: " ..tos(researchLineListIndexOfWeaponOrArmorType))
                    horizontalScrollList:SetSelectedIndex(researchLineListIndexOfWeaponOrArmorOrJewelryType)
                end, 25)
            end
        end --if filterPanelId then
    end
    --==================================================================================================================
    -- -^- SMITHING Research horizontal scrolllist?                                                                 -^-
    --==================================================================================================================
end
local filterHorizontalScrollList = util.FilterHorizontalScrollList

--Get the current active subfilterBar's button name and then read the filterForAll entry of this button
--from the subfilterGroups to prefilter the list with some data (e.g. the horizontal research scroll list with EQUIPTYPE_NECK)
function util.PreFilterWithSubfilterBarButtonFilterForAll()
    --if AF.settings.debugSpam then d("[AF]util.PreFilterWithSubfilterBarButtonFilterForAll") end
    local subfilterGroups = AF.subfilterGroups[getCurrentFilterTypeForInventory(AF.currentInventoryType)]
    if not subfilterGroups then return nil, nil end
    local currentActiveSubFilterBar = subfilterGroups.currentSubfilterBar
    if not currentActiveSubFilterBar then return nil, nil end
    local currentActiveButtonAtSubFilterBar = currentActiveSubFilterBar.activeButton
    if not currentActiveButtonAtSubFilterBar then return nil, nil end
    local activeButtonName = currentActiveButtonAtSubFilterBar.name
    --Stop if name of button is missing or if it's the ALL button
    if not activeButtonName or activeButtonName == AF_CONST_ALL then return nil, nil end
    --Get the subfilterCallbacks
    local subfilterCallbacks = AF.subfilterCallbacks
    if not subfilterCallbacks then return nil, nil end
    local activeButtonGroupName = currentActiveButtonAtSubFilterBar.groupName
    local subfilterCallbackForButtonGroup = subfilterCallbacks[activeButtonGroupName]
    if not subfilterCallbackForButtonGroup then return nil, nil end
    local subfilterCallbackForButton = subfilterCallbackForButtonGroup[activeButtonName]
    if not subfilterCallbackForButton then return nil, nil end
    local filterForAll = subfilterCallbackForButton.filterForAll
    if not filterForAll then return nil, nil end
    --[[
            filterForAll = {
                filterTypes = {}
                equipTypes  = {EQUIPTYPE_RING},
                armorTypes  = {},
            },
    ]]
    --Combine filterTypes and equipTypes in return table filterAndEquipTypes
    local filterAndEquipTypes
    local armorTypes
    if filterForAll.itemTypes then
        filterAndEquipTypes = filterAndEquipTypes or {}
        for _, filterType in pairs(filterForAll.itemTypes) do
            table.insert(filterAndEquipTypes, filterType)
        end
    end
    if filterForAll.equipTypes then
        filterAndEquipTypes = filterAndEquipTypes or {}
        for _, equipType in pairs(filterForAll.equipTypes) do
            table.insert(filterAndEquipTypes, equipType)
        end
    end
    if filterForAll.armorTypes then
        armorTypes = {}
        armorTypes = filterForAll.armorTypes
    end
    return filterAndEquipTypes, armorTypes
end


--======================================================================================================================
-- -^- Filter functions                                                                                             -^-
--======================================================================================================================


--======================================================================================================================
-- -v- Crafting functions                                                                                           -v-
--======================================================================================================================
--Get the crafting tables mode
function util.GetCraftingMode(inventoryType)
    inventoryType = inventoryType or getCurrentFilterTypeForInventory(AF.currentInventoryType)
    local craftingMode
    local craftingTable = getCraftingTable(inventoryType)
    if not craftingTable then return end
    craftingMode = craftingTable.mode or craftingTable.enchantingMode
    return craftingMode
end


--Get the LibFilters filterType constant of a subfilterBar
function util.GetSubFilterBarsLibFiltersFilterType(subfilterBar, inventoryType)
    local subFilterBarFilterInfo = getSubFilterBarsFilterTypeInfo(subfilterBar, inventoryType)
    local libFiltersFilterType
    if subFilterBarFilterInfo.isMailSendPanel == true then
        libFiltersFilterType = LF_MAIL_SEND
    elseif subFilterBarFilterInfo.isVendorPanel == true then
        libFiltersFilterType = LF_VENDOR_SELL
    elseif subFilterBarFilterInfo.isFencePanel == true then
        libFiltersFilterType = LF_FENCE_SELL
    elseif subFilterBarFilterInfo.isLaunderPanel == true then
        libFiltersFilterType = LF_FENCE_LAUNDER
    elseif subFilterBarFilterInfo.isBankDepositPanel == true then
        libFiltersFilterType = LF_BANK_DEPOSIT
    elseif subFilterBarFilterInfo.isGuildBankDepositPanel == true then
        libFiltersFilterType = LF_GUILDBANK_DEPOSIT
    elseif subFilterBarFilterInfo.isHouseBankDepositPanel == true then
        libFiltersFilterType = LF_HOUSE_BANK_DEPOSIT
    elseif subFilterBarFilterInfo.isFurnitureVaultDepositPanel == true then
        libFiltersFilterType = LF_FURNITURE_VAULT_DEPOSIT
    elseif subFilterBarFilterInfo.isVengeanceInvPanel == true then
        libFiltersFilterType = LF_INVENTORY_VENGEANCE
    elseif subFilterBarFilterInfo.isGuildStoreSellPanel == true then
        libFiltersFilterType = LF_GUILDSTORE_SELL
    elseif subFilterBarFilterInfo.isTradePanel == true then
        libFiltersFilterType = LF_TRADE
    elseif subFilterBarFilterInfo.isUniversalDeconstruction == true then
        libFiltersFilterType = getActiveUniversalDeconstructionPanelFilterType(inventoryType)
    end
    return libFiltersFilterType
end
local getSubFilterBarsLibFiltersFilterType = util.GetSubFilterBarsLibFiltersFilterType

--Get the LibFilters filterType constant of a subfilterGroup
function util.GetSubFilterGroupsLibFiltersFilterType(inventoryTypeOfSubfilterGroup, tradeSkillTypeOfSubFilterGroup, itemFilterTypesOfSubfilterGroup)
--d("[AF]util.GetSubFilterGroupsLibFiltersFilterType - inventoryTypeOfSubfilterGroup: " ..tos(inventoryTypeOfSubfilterGroup))
    if not inventoryTypeOfSubfilterGroup then return nil, nil end
    local isSubFilterGroupTheSameAsLibFiltersFilterType = doesInventoryTypeEqualLibFiltersType(inventoryTypeOfSubfilterGroup)
    local libFiltersFilterType, callbackFunctionForUpdate
    if not isSubFilterGroupTheSameAsLibFiltersFilterType then
        mapAFInvTypeToLibFiltersFilterType = mapAFInvTypeToLibFiltersFilterType or AF.mapInvTypeToLibFiltersFilterType
        libFiltersFilterType               = mapAFInvTypeToLibFiltersFilterType[inventoryTypeOfSubfilterGroup] or nil
--d(">libFiltersFilterType: " ..tos(libFiltersFilterType))
        if libFiltersFilterType ~= nil then
            if type(libFiltersFilterType) == "function" then
                local libFiltersFilterTypeResult = libFiltersFilterType(inventoryTypeOfSubfilterGroup, tradeSkillTypeOfSubFilterGroup, itemFilterTypesOfSubfilterGroup)
                --d(">>isFunction: true, result: " ..tos(libFiltersFilterTypeResult))
                libFiltersFilterType = libFiltersFilterTypeResult
            else
                --INVENTORY_BACKPACK and LF_INVENTORY can be several different ones:
                --LF_BANK_DEPOSIT, LF_GUILDBANK_DEPOSIT, LF_HOUSE_BANK_DEPOSIT, LF_MAIL, LF_TRADE, LF_VENDOR_SELL, LF_GUILDSTORE_SELL
                --So we need to register a callback function to the subFilterGroup which is called as the subfilterGroup is shown, to
                --update the AdvancedFilters.currentSubfilterGroup.libFilters_filterType variable properly
                if inventoryTypeOfSubfilterGroup == INVENTORY_BACKPACK and libFiltersFilterType == LF_INVENTORY then
                    callbackFunctionForUpdate = getSubFilterBarsLibFiltersFilterType
                end
            end
        end
    else
        libFiltersFilterType = inventoryTypeOfSubfilterGroup
    end
    return libFiltersFilterType, callbackFunctionForUpdate
end

--return the LibFilters filterType constant for the inventory's subfilterGroup data.
--Will be called for INVENTORY_BACKPACK to determine the correct value of the libFilters filterType e.g. LF_INVENTORY or LF_BANK_DEPOSIT or LF_MAIL etc.
-->Called dynamically from function util.GetSubFilterGroupsLibFiltersFilterType(inventoryTypeOfSubfilterGroup, tradeSkillTypeOfSubFilterGroup, itemFilterTypesOfSubfilterGroup)
-->via table AF.mapInvTypeToLibFiltersFilterType
function util.GetLibFiltersFilterTypeForInventorySubfilterGroup(inventoryTypeOfSubfilterGroup, tradeSkillTypeOfSubFilterGroup, itemFilterTypesOfSubfilterGroup)
--d("[AF]util.GetLibFiltersFilterTypeForInventorySubfilterGroup - inventoryTypeOfSubfilterGroup: " ..tos(inventoryTypeOfSubfilterGroup))
    local libFiltersFilterType = LF_INVENTORY
    return libFiltersFilterType
end


--Function to return the "predicate" and "filter" functions used at the different crafting types, as new inventory lists are build.
-->They will pre-filter and filter the inventory items.
--Use the LibFilters filterPanelId as parameter
function util.GetPredicateAndFilterFunctionFromCraftingPanel(libFiltersFilterPanelId)
    local craftingFilterPanelId2PredicateFunc = AF.craftingFilterPanelId2PredicateFunc
    local predicateFunc, filterFunc
    local funcs = craftingFilterPanelId2PredicateFunc[libFiltersFilterPanelId] or nil
    if funcs and funcs[1] and funcs[2] then
        predicateFunc, filterFunc = funcs[1], funcs[2]
    end
    return predicateFunc, filterFunc
end

function util.MapItemFilterType2CraftingStationFilterType(itemFilterType, filterPanelId, craftingType)
    if filterPanelId == nil then return end
    local mapIFT2CSFT = AF.mapIFT2CSFT
    if craftingType == nil then craftingType = getCraftingType() end
    if itemFilterType == nil or craftingType == nil or mapIFT2CSFT[filterPanelId] == nil or mapIFT2CSFT[filterPanelId][craftingType] == nil or mapIFT2CSFT[filterPanelId][craftingType][itemFilterType] == nil then return end
    return mapIFT2CSFT[filterPanelId][craftingType][itemFilterType]
end

function util.MapCraftingStationFilterType2ItemFilterType(craftingStationFilterType, filterPanelId, craftingType)
    if filterPanelId == nil then return end
    local mapCSFT2IFT = AF.mapCSFT2IFT
    if craftingType == nil then craftingType = getCraftingType() end
    if craftingStationFilterType == nil or craftingType == nil or mapCSFT2IFT[filterPanelId] == nil or mapCSFT2IFT[filterPanelId][craftingType] == nil or mapCSFT2IFT[filterPanelId][craftingType][craftingStationFilterType] == nil then return end
    local retVar = mapCSFT2IFT[filterPanelId][craftingType][craftingStationFilterType]
    return retVar
end

--Check if the research panel is shown and do some special stuff with the horizontal scroll list then.
--If not: Run the filter function only
function util.CheckForResearchPanelAndRunFilterFunction(runPrefilterForAllSelection, filterOrEquipTypes, armorTypes, traitTypes)
    runPrefilterForAllSelection = runPrefilterForAllSelection or false
    --if AF.settings.debugSpam then d("[AF]util.CheckForResearchPanelAndRunFilterFunction") end
    --If the research panel is shown:
    --Clear the horizontal list and only show the entries which apply to the selected item type
    if researchHorizontalScrollList and researchHorizontalScrollList.control then --and not researchHorizontalScrollList.control:IsHidden() then
        --Hide entries on the horizontal scroll list of the research panel
        filterHorizontalScrollList(runPrefilterForAllSelection, researchHorizontalScrollList, filterOrEquipTypes, armorTypes, traitTypes)
    end
end

--Get the currently active AdvancedFilters subFilterBar and run apply it's currents horizontal scroll list filterCallbacks
function util.CheckForResearchPanelAndRunCurrentSubfilterBarsFilterFunctions()
--d("!!! [AF]util.CheckForResearchPanelAndRunCurrentSubfilterBarsFilterFunctions")
    libFilters = libFilters or util.LibFilters
    if not libFilters:IsResearchShown() then return end
    --util.ReApplyDropdownFilter() --not working!

    local activeSubfilterBar = util.GetActiveSubfilterBar()
    if not activeSubfilterBar then return end
    local activeButton = activeSubfilterBar.activeButton
    if activeButton and activeButton.filterStartCallback then
--d(">running: activeSubfilterBar:filterStartCallback()")
        activeButton:filterStartCallback()
    end
end
--======================================================================================================================
-- -^- Crafting functions                                                                                           -^-
--======================================================================================================================


--======================================================================================================================
-- -v- Universal Deconstruction functions                                                                           -v-
--======================================================================================================================
function util.MapItemFilterType2UniversalDeconstructionFilterType(itemFilterType, filterPanelId, craftingType)
    if filterPanelId == nil then return end
    local mapIFT2UDFT = AF.mapIFT2UDFT
    if craftingType == nil then craftingType = getCraftingType() end
    if itemFilterType == nil or craftingType == nil or mapIFT2UDFT[filterPanelId] == nil
            or mapIFT2UDFT[filterPanelId][craftingType] == nil
            or mapIFT2UDFT[filterPanelId][craftingType][itemFilterType] == nil then return end
    return mapIFT2UDFT[filterPanelId][craftingType][itemFilterType]
end

function util.MapUniversalDeconstructionFilterType2ItemFilterType(tab)
    if tab == nil then return end
    local tabKey = tab.key
    if tabKey == nil then return end
    local AFuniversalDeconItemFilterTypeByTabKey = universalDeconKeyToAFFilterType[tabKey]
--d(">tab found, key: " .. tos(tabKey) .. ", itemFilterType: " ..tos(AFuniversalDeconItemFilterTypeByTabKey))
    --todo
    --universalDeconPanelInv.AF_currentFilter should contain the currently selected itemFilterType e.g. ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS
    --and the currently selected subFilterBar's itemFilterType needs to be determined somehow here!

    --[[
    local filterData = universalDeconPanelInv.filter and universalDeconPanelInv.filter.filter
    if filterData then
        d(">filterData found")
        --Enchantments -> itemTypes of the 3 glyph types
        if filterData.itemTypes ~= nil then
            d(">filterData itemTypes found")
            --todo How to select the correct one? Store the selected glyp subfilter at UNIVERSAL_DECONSTRUCTION.currentFilter at best!
            --filterData.itemTypes[1]
            return ITEMFILTERTYPE_AF_GLYPHS_ENCHANTING
        end
        if filterData.itemFilterTypes ~= nil then
            d(">filterData itemFilterTypes found")
            return filterData.itemFilterTypes[1]
        end
    end
    --All selected
    return ITEM_TYPE_DISPLAY_CATEGORY_ALL
    ]]
    return AFuniversalDeconItemFilterTypeByTabKey
end
--======================================================================================================================
-- -^- Universal Deconstruction functions                                                                           -^-
--======================================================================================================================


--======================================================================================================================
-- -v- Filter plugin for the filterBar dropdown box functions                                                       -v-
--======================================================================================================================
--[[
function util.ResetExternalDropdownFilterPluginsIsFiltering()
    local externalDropdownFilterPlugins = AF.externalDropdownFilterPlugins
    if externalDropdownFilterPlugins then
        for externalFilterPluginName, externalFilterPluginData in pairs(externalDropdownFilterPlugins) do
            if externalFilterPluginData and externalFilterPluginData.isFiltering == true then
                externalFilterPluginData.isFiltering = false
            end
        end
    end
end
]]
--======================================================================================================================
-- -^- Filter plugin for the filterBar dropdown box functions                                                       -^-
--======================================================================================================================

--======================================================================================================================
-- -v- Other addons functions                                                                                       -v-
--======================================================================================================================
--Map the custom addon's itemFilterType defined in AdvancedFilters constants.lua to a LibFilters panelId LF_*
function util.MapCustomAddonItemFilterType2LibFiltersPanelId(customAddonItemFilterType)
    if not customAddonItemFilterType then return end
    local customAddonItemFilterTypes2LibFiltersPanelIds = AF.customAddonItemFilterType2LibFiltersPanelId
    if not customAddonItemFilterTypes2LibFiltersPanelIds then return end
    local filterPanelId = customAddonItemFilterTypes2LibFiltersPanelIds[customAddonItemFilterType]
    return filterPanelId
end

--Check if the itemFilterType of the current inventoryType is one added by a custom addon (e.g. "HarvensStolenFilter" filterTab button)
function util.CheckIfIsCustomAddonInventoryFilterButtonItemFilterType(invType)
    --if AF.settings.debugSpam then d("[AF]util.CheckIfIsCustomAddonInventoryFilterButtonItemFilterType - invType: " ..tos(invType)) end
    local customInventoryFilterButton2ItemType = AF.customInventoryFilterButton2ItemType
    if not customInventoryFilterButton2ItemType then return false end
    --Get the currentFilter of the inventory
    local currentFilter = getCurrentFilter(invType)
    if not currentFilter or type(currentFilter) == "table" then return false end
    for otherAddonName, customItemFilterType in pairs(customInventoryFilterButton2ItemType) do
        if customItemFilterType == currentFilter then return true end
    end
    return false
end

--Check if the current filter is a function and then get the owning inventory filter bar's button to check for it's
--"descriptor" tag. If a descriptor is found use the mapping table AF.customInventoryFilterButton2ItemType to
--return a custom itemFilterType for this descriptor and use this itemFilterType addon wide (so the subfilterGroups and
--callback tables have a "key" to use!)
function util.CheckForCustomInventoryFilterBarButton(invType, currentFilter)
    if invType == nil or currentFilter == nil then return end
    --[[
    --Only if the currentFilter (which relates to PLAYER_INVENTORY.inventories[...].tabFilters[...].filterType) is a function
    -->All others would be numbers and can be used as is!
    if not type(currentFilter) == "function" then return end
    ]]
    local currentlySelectedInventoryFilterBarButton = util.GetActiveInventoryFilterBarButtonData(invType)
    --identification tag exists?
    if not currentlySelectedInventoryFilterBarButton or not currentlySelectedInventoryFilterBarButton.GetDescriptor then return end
    local customInventoryFilterButtons2ItemType = AF.customInventoryFilterButton2ItemType
    local descriptor = currentlySelectedInventoryFilterBarButton:GetDescriptor()
    if not descriptor or descriptor == "" or descriptor == 0 then return end
    local customInventoryFilterButton2ItemType = customInventoryFilterButtons2ItemType[descriptor]
    return customInventoryFilterButton2ItemType
end

--======================================================================================================================
-- -^- Other addons functions                                                                                       -^-
--======================================================================================================================

--======================================================================================================================
-- -v- API functions                                                                                               -v-
--======================================================================================================================
--Checks if other addons have registered filter functions which should be run on util.RefreshSubfilterBar as well
--to check if the subfilter bar button should be greyed out.
-->Will return true if no other addons have registered any filters for the inventoryType, craftingType and filterType
function util.CheckIfOtherAddonsProvideSubfilterBarRefreshFilters(slotData, inventoryType, craftingType, libFiltersPanelId)
    if slotData == nil or slotData.bagId == nil or slotData.slotIndex == nil
            or inventoryType == nil or craftingType == nil or libFiltersPanelId == nil then return true end
    --if AF.settings.debugSpam then
    --d("[AF]util.CheckIfOtherAddonsProvideSubfilterBarRefreshFilters, inventoryType: " ..tos(inventoryType) .. ", craftingType: " .. tos(craftingType) .. ", libFiltersPanelId: " .. tos(libFiltersPanelId))
    --end
    --AF.SubfiltThrottledUpdateerRefreshCallbacks contain the externally registered filters, from other addons, for the refresh of subfilterBars
    local subfilterRefreshCallbacks
    if AF.SubfilterRefreshCallbacks == nil or AF.SubfilterRefreshCallbacks[inventoryType] == nil
            or AF.SubfilterRefreshCallbacks[inventoryType][craftingType] == nil or AF.SubfilterRefreshCallbacks[inventoryType][craftingType][libFiltersPanelId] == nil then
        return true
    end
    subfilterRefreshCallbacks = AF.SubfilterRefreshCallbacks[inventoryType][craftingType][libFiltersPanelId]
    if subfilterRefreshCallbacks == nil then return true end
    local retVar = true
    for externalAddonName, callbackFunc in pairs(subfilterRefreshCallbacks) do
        if callbackFunc ~= nil and type(callbackFunc) == "function" then
            local callbackFuncResult = callbackFunc(slotData)
            retVar = callbackFuncResult
            if retVar == false then
--d(">[AF]RefreshSubFilterbar, externalAddonName: " .. tos(externalAddonName) .. ", result: " ..tos(callbackFuncResult))
                return false
            end
        end
    end
--d(">[AF]RefreshSubFilterbar, result: " ..tos(retVar))
    return retVar
end

--Get a subfilterBar
--invType: nilable  Inventory type
--craftType: nilable Crafting type
function util.GetSubfilterBar(invType, craftType)
    invType = invType or AF.currentInventoryType
    if not invType then return end
    local subfilterGroup = AF.subfilterGroups[invType]
    if not subfilterGroup then return end
    if craftType == nil then
        return subfilterGroup
    end
    local subfilterBar = subfilterGroup[craftType]
    return subfilterBar
end

--Get the currently active subfilterBar
--invType: nilable  Inventory type
function util.GetActiveSubfilterBar(invType)
    local subfilterGroup = util.GetSubfilterBar(invType, nil)
    if not subfilterGroup then return end
    local activeSubfilterBar = subfilterGroup.currentSubfilterBar
    return activeSubfilterBar
end

--Get the currently active subfilterBar's button
--invType: nilable  Inventory type
function util.GetActiveSubfilterBarButton(invType)
    local activeSubfilterBar = util.GetActiveSubfilterBar(invType)
    if not activeSubfilterBar then return end
    return activeSubfilterBar.activeButton
end

--Get the currently active subfilterBar's dropdown box
--invType: nilable  Inventory type
function util.GetActiveSubfilterBarDropdown(invType)
    local activeSubfilterBar = util.GetActiveSubfilterBar(invType)
    if not activeSubfilterBar then return end
    return activeSubfilterBar.dropdown
end

--Get the currently active subfilterBar's dropdown box's selected filter plugin data
--invType: nilable  Inventory type
function util.GetActiveSubfilterBarSelectedDropdownFilterData(invType)
    local dropdown = util.GetActiveSubfilterBarDropdown(invType)
    if not dropdown then return end
    local comboBox = dropdown.m_comboBox
    if not comboBox then return end
    local selectedItemData = comboBox.m_selectedItemData
    return selectedItemData
end

--Re-Apply the last selected filterBar's dropdown filter, or apply the first entry of the dropdown box
function util.ReApplyDropdownFilter()
    local activeSubfilterBar = util.GetActiveSubfilterBar()
    if not activeSubfilterBar then return end
    if activeSubfilterBar.ApplyDropdownSelection then
        activeSubfilterBar:ApplyDropdownSelection()
    end
end


--======================================================================================================================
--======================================================================================================================
--======================================================================================================================
--Since API100033: ZOs added their own inventory filters. The main buttons are not using the itemfilter_types any longer
--but so called ItemTypeDisplayCategory. So the filter menu button's buttonData.filterType ("currentFilter" used within
--AF) is the new ItemTypeDisplayCategory and needs to be mapped to the AF itemfilter_type again, in order to let all AF
--functions AND plugins work properly (as they need the older ITEMFILTER_TYPE_* variables)!
--[[
function util.mapItemFilterCategoryToItemFilterType(itemFilterCategory)
    if not itemFilterCategory then return end
    --Map the itemFilterType from currentFIlter to the new itemTypeDisplayCategory, or return the value passed in
    --e.g. for AF created itemFilterTypes like ITEMFILTERTYPE_AF_REFINE_SMITHING etc.
    local itemDisplayCategoryToItemFilterType = AF.itemDisplayCategoryToItemFilterType
    return itemDisplayCategoryToItemFilterType[itemFilterCategory] or itemFilterCategory
end
]]

--Map the itemFilterType to the new ZOs API100033 ItemTypeDisplayCategory
function util.mapItemFilterTypeToItemFilterCategory(itemFilterType)
    if not itemFilterType then return end
    --ZO_ItemFilterUtils
    local itemTypeDisplayCategory = ITEM_FILTER_UTILS.GetItemTypeDisplayCategoryByItemFilterType(itemFilterType)
            or itemFilterType
    return itemTypeDisplayCategory
end
--======================================================================================================================
-- -^- API functions                                                                                               -^-
--======================================================================================================================


