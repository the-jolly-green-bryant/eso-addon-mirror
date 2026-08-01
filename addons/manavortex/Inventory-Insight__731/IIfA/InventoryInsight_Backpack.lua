local function p(...)
  -- Ensure IIfA and its debug function are properly initialized
  if not IIfA or not IIfA.DebugOut then return end

  -- Ensure the conditions for debugging are met
  if not IIFA_DATABASE[IIfA.currentAccount] or not IIFA_DATABASE[IIfA.currentAccount].settings.bDebug then return end

  IIfA:DebugOut(...)
end


-- this is for the buttons
local function enableFilterButton(num)
  local buttonName = "Button" .. num
  local button = IIFA_GUI_Header_Filter:GetNamedChild(buttonName)
  if button then
    button:SetState(BSTATE_PRESSED)
  end
end

local function disableFilterButton(num)
  local button = IIFA_GUI_Header_Filter:GetNamedChild("Button" .. num)
  if button then
    button:SetState(BSTATE_NORMAL)
  end
end

function IIfA:GetActiveFilter()
  if not IIfA.ActiveFilter then return 0 end
  return tonumber(IIfA.ActiveFilter)
end

function IIfA:SetActiveFilter(value)
  if value == nil then
    value = 0
  else
    value = tonumber(value)
  end
  local currentFilter = IIfA:GetActiveFilter()

  if tonumber(currentFilter) == value then
    value = 0
  end

  IIfA.ActiveFilter = value
  if currentFilter ~= value then
    disableFilterButton(currentFilter)
  end

  enableFilterButton(value)

  IIfA:RefreshInventoryScroll()
end

function IIfA:GetActiveSubFilter()
  if not IIfA.activeSubFilter then return 0 end
  return tonumber(IIfA.activeSubFilter)
end

function IIfA:SetActiveSubFilter(value)
  value = tonumber(value)
  if IIfA:GetActiveSubFilter() == value then
    IIfA.activeSubFilter = 0
  else
    IIfA.activeSubFilter = value
  end
  IIfA:RefreshInventoryScroll()
end

--[[----------------------------------------------------------------------]]
--[[----------------------------------------------------------------------]]
--[[------ GUI functions  ------------------------------------------------]]

function IIfA:GUIDoubleClick(control, button)
  if button == MOUSE_BUTTON_INDEX_LEFT and control.itemLink then
    if control.itemLink ~= IIfA.EMPTY_STRING then
      ZO_ChatWindowTextEntryEditBox:SetText(ZO_ChatWindowTextEntryEditBox:GetText() .. ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, control.itemLink))
    end
  end
end

local function getHouseIds()
  local ret = {}
  for houseName, houseId in pairs(IIfA:GetTrackedHouses()) do
    table.insert(ret, houseId)
  end
  return ret
end

local function isHouse()
  return IIfA:GetTrackingWithHouseNames()[locationName]
end

function IIfA:GetCurrentCompanionName()
  if HasActiveCompanion() then
    return ZO_CachedStrFormat(SI_UNIT_NAME, GetCompanionName(GetActiveCompanionDefId()))
    -- returns nil if no current active companion
  else return end
end

function IIfA:GetCurrentCompanionHashId()
  local currentCompanionName
  local companionNameHash
  if HasActiveCompanion() then
    currentCompanionName = IIfA:GetCurrentCompanionName()
    companionNameHash = HashString(currentCompanionName)
    return tostring(companionNameHash)
  end
  -- returns nil if no current active companion
  return
end

local function is_empty_or_nil(t)
  if t == nil or t == "" then return true end
  return type(t) == "table" and ZO_IsTableEmpty(t) or false
end

local function is_in(search_value, search_table)
  if is_empty_or_nil(search_value) then return false end
  for k, v in pairs(search_table) do
    if search_value == v then return true end
    if type(search_value) == "string" then
      if zo_strfind(zo_strlower(v), zo_strlower(search_value)) then return true end
    end
  end
  return false
end

local function DoesInventoryMatchList(locationName, location)
  local bagId = location.bagID
  local filter = IIfA.InventoryListFilter
  local filterBag = IIfA.InventoryListFilterBagId
  local allBanks = { BAG_BANK, BAG_SUBSCRIBER_BANK, BAG_GUILDBANK }
  local guildBank = { BAG_GUILDBANK }
  local allCharacterInventory = { BAG_BACKPACK, BAG_WORN, BAG_COMPANION_WORN }
  local allCompanions = { BAG_COMPANION_WORN }
  local allEquipped = { BAG_WORN, BAG_COMPANION_WORN }
  local allStorage = { BAG_BACKPACK, BAG_WORN, BAG_BANK, BAG_SUBSCRIBER_BANK, BAG_VIRTUAL, BAG_COMPANION_WORN, BAG_FURNITURE_VAULT }
  local bankAndCharacters = { BAG_BACKPACK, BAG_WORN, BAG_BANK, BAG_SUBSCRIBER_BANK, BAG_COMPANION_WORN }
  local currentCharacter = { BAG_BACKPACK, BAG_WORN }
  local banksOnly = { BAG_BANK, BAG_SUBSCRIBER_BANK }
  local craftBag = { BAG_VIRTUAL }
  local furnitureVault = { BAG_FURNITURE_VAULT }

  -- Local variable for collectHouseData
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  local collectHouseData = serverData.collectHouseData[bagId]

  --	if locationName == "attributes" then return false end
  if (filter == GetString(IIFA_LOCATION_NAME_ALL)) then
    return true

  elseif (filter == GetString(IIFA_LOCATION_NAME_ALL_BANKS)) then
    return is_in(bagId, allBanks) and IIfA.trackedBags[bagId]

  elseif (filter == GetString(IIFA_LOCATION_NAME_ALL_GUILDBANKS)) then
    return is_in(bagId, guildBank)

  elseif (filter == GetString(IIFA_LOCATION_NAME_ALL_CHARACTERS)) then
    return is_in(bagId, allCharacterInventory)

  elseif (filter == GetString(IIFA_LOCATION_NAME_ALL_COMPANIONS)) then
    return is_in(bagId, allCompanions)

  elseif (filter == GetString(IIFA_LOCATION_NAME_ALL_EQUIPPED)) then
    return is_in(bagId, allEquipped)

  elseif (filter == GetString(IIFA_LOCATION_NAME_ALL_STORAGE)) then
    return is_in(bagId, allStorage) or GetCollectibleForBag(bagId) > 0

  elseif (filter == GetString(IIFA_LOCATION_NAME_EVERYTHING)) then
    return is_in(bagId, allStorage) or GetCollectibleForBag(bagId) > 0 or collectHouseData

  elseif (filter == GetString(IIFA_LOCATION_NAME_BANK_ONLY)) then
    return is_in(bagId, banksOnly)

  elseif (filter == GetString(IIFA_LOCATION_NAME_BANK_AND_CHARACTERS)) then
    return is_in(bagId, bankAndCharacters)

  elseif (filter == GetString(IIFA_LOCATION_NAME_BANK_CURRENT_CHARACTER)) then
    return is_in(bagId, banksOnly) or (is_in(bagId, currentCharacter) and locationName == IIfA.currentCharacterId)

  elseif (filter == GetString(IIFA_LOCATION_NAME_BANK_OTHER_CHARACTERS)) then
    return is_in(bagId, banksOnly) or (is_in(bagId, currentCharacter) and locationName ~= IIfA.currentCharacterId)

  elseif (filter == GetString(IIFA_LOCATION_NAME_CRAFT_BAG)) then
    return is_in(bagId, craftBag)

  elseif (filter == GetString(IIFA_LOCATION_NAME_FURNITURE_VAULT)) then
    return is_in(bagId, furnitureVault)

  elseif (filter == GetString(IIFA_LOCATION_NAME_HOUSING_STORAGE) and filterBag == nil) then
    -- all housing storage chests/coffers
    return GetCollectibleForBag(bagId) > 0

  elseif (filter == GetString(IIFA_LOCATION_NAME_HOUSING_STORAGE) and filterBag ~= nil) then
    -- specific housing storage chest/coffer
    return bagId == filterBag and GetCollectibleForBag(bagId) > 0

  elseif (filter == GetString(IIFA_LOCATION_NAME_ALL_HOUSES)) then
    return collectHouseData

  elseif (IIfA:GetHouseIdFromName(filter) ~= nil) then
    return (bagId == IIfA:GetHouseIdFromName(filter))

  else
    -- is it a specific character
    if is_in(bagId, currentCharacter) then
      -- it's a character name, convert to Id, check that against location Name in the dbv3 table
      if locationName == serverData.CharNameToId[filter] then return true end
      -- Check companion equipment, convert to Id
    elseif is_in(bagId, allCompanions) then
      if locationName == serverData.CompanionNameToId[filter] then return true end
    else
      -- it's a bank to compare, do it direct
      return locationName == filter
    end
  end
end

--@Baertram:
--Made the function global to be used in other addons like FCOItemSaver
function IIfA:DoesInventoryMatchList(locationName, location)
  return DoesInventoryMatchList(locationName, location)
end

local function matchCurrentInventory(locationName)
  --	if locationName == "attributes" then return false end
  local accountInventoryList = IIfA:GetAccountInventoryList()

  for i, inventoryName in pairs(accountInventoryList) do
    if inventoryName == locationName then return true end
  end

  return (IIfA:GetInventoryListFilter() == GetString(IIFA_LOCATION_NAME_ALL))
end

local qualityDictionary
local function getColoredString(color, s)
  local c = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, color))
  return c:Colorize(s)
end

local function getQualityDict()
  if qualityDictionary == nil then
    qualityDictionary = {
      [GetString(IIFA_DROPDOWN_QUALITY_MENU_ANY)] = IIFA_FILTER_MENU_QUALITY_ANY,
      [getColoredString(ITEM_DISPLAY_QUALITY_TRASH, GetString(SI_ITEMDISPLAYQUALITY0))] = ITEM_DISPLAY_QUALITY_TRASH,
      [getColoredString(ITEM_DISPLAY_QUALITY_NORMAL, GetString(SI_ITEMDISPLAYQUALITY1))] = ITEM_DISPLAY_QUALITY_NORMAL,
      [getColoredString(ITEM_DISPLAY_QUALITY_MAGIC, GetString(SI_ITEMDISPLAYQUALITY2))] = ITEM_DISPLAY_QUALITY_MAGIC,
      [getColoredString(ITEM_DISPLAY_QUALITY_ARCANE, GetString(SI_ITEMDISPLAYQUALITY3))] = ITEM_DISPLAY_QUALITY_ARCANE,
      [getColoredString(ITEM_DISPLAY_QUALITY_ARTIFACT, GetString(SI_ITEMDISPLAYQUALITY4))] = ITEM_DISPLAY_QUALITY_ARTIFACT,
      [getColoredString(ITEM_DISPLAY_QUALITY_LEGENDARY, GetString(SI_ITEMDISPLAYQUALITY5))] = ITEM_DISPLAY_QUALITY_LEGENDARY,
      [getColoredString(ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE, GetString(SI_ITEMDISPLAYQUALITY6))] = ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE,
    }
  end
  return qualityDictionary
end

function IIfA:getQualityDict()
  return qualityDictionary or getQualityDict()
end

--[[ Only used in IIfA:UpdateScrollDataLinesData()
This is not used from the XML file when a user clicks a filter button.

When a user clicks a filter button that is IIfA:GuiOnFilterButton()
]]--
local function matchFilter(itemName, itemLink)
  if not itemLink then return end

  local ret = false
  local itemMatch = false

  local isCompanionItem = GetItemLinkActorCategory(itemLink) == GAMEPLAY_ACTOR_CATEGORY_COMPANION
  local weaponType = GetItemLinkWeaponType(itemLink)
  local armorType = GetItemLinkArmorType(itemLink)
  local itemType, specializedItemType = GetItemLinkItemType(itemLink)
  local equipType = GetItemLinkEquipType(itemLink)
  -- for furniture
  local furnitureDataId
  if IIfA:isItemLink(itemLink) then
    furnitureDataId = GetItemLinkFurnitureDataId(itemLink)
  elseif IIfA:isCollectibleLink(itemLink) then
    local collectibleId = IIfA:GetCollectibleLinkItemId(itemLink)
    furnitureDataId = GetCollectibleFurnitureDataId(collectibleId)
    itemType = ITEMTYPE_FURNISHING
  end
  local categoryId, subcategoryId = GetFurnitureDataCategoryInfo(furnitureDataId)
  local isFurnishingItem = itemType == ITEMTYPE_FURNISHING

  local function itemWearable()
    return equipType == EQUIP_TYPE_CHEST
      or equipType == EQUIP_TYPE_FEET
      or equipType == EQUIP_TYPE_HAND
      or equipType == EQUIP_TYPE_HEAD
      or equipType == EQUIP_TYPE_LEGS
      or equipType == EQUIP_TYPE_SHOULDERS
      or equipType == EQUIP_TYPE_WAIST
  end
  local isWearable = itemWearable()

  local function itemWeapon()
    return weaponType == WEAPONTYPE_AXE
      or weaponType == WEAPONTYPE_HAMMER
      or weaponType == WEAPONTYPE_SWORD
      or weaponType == WEAPONTYPE_DAGGER
      or weaponType == WEAPONTYPE_TWO_HANDED_AXE
      or weaponType == WEAPONTYPE_TWO_HANDED_HAMMER
      or weaponType == WEAPONTYPE_TWO_HANDED_SWORD
      or weaponType == WEAPONTYPE_BOW
      or weaponType == WEAPONTYPE_FIRE_STAFF
      or weaponType == WEAPONTYPE_FROST_STAFF
      or weaponType == WEAPONTYPE_LIGHTNING_STAFF
      or weaponType == WEAPONTYPE_HEALING_STAFF
  end
  local isWeapon = itemWeapon()

  -- 17-7-30 AM - moved lowercasing to when it's created, one less call to lowercase for every item
  -- 2024-11-10 Sharlikran - ony use when IIfA:IsItemSet() when there is a search string
  --Empty search string? Then skip all searches with names

  local searchFilter = IIfA.searchFilter
  local hasSearchFilter = searchFilter and searchFilter > IIfA.EMPTY_STRING
  local function HasItemNameSearchFilter()
    local hasValidItemName = itemName and itemName > IIfA.EMPTY_STRING
    local validMatch = false

    -- Only proceed if the item name and search filter are not empty
    if hasSearchFilter then
      if hasValidItemName then
        -- Set name of item and convert to lowercase
        local name = zo_strlower(ZO_CachedStrFormat("<<C:1>>", itemName))

        -- Match the item name against the search filter
        validMatch = zo_plainstrfind(name, searchFilter)
      end
    end
    return validMatch
  end
  local hasValidItemNameFilter = HasItemNameSearchFilter()

  local function HasSetSearchFilter()
    -- Local variable to indicate a match
    local retSet = false
    local hasSetInfo, setName

    -- Check if there’s a search filter and if set-based filtering is enabled
    if hasSearchFilter and (IIFA_DATABASE[IIfA.currentAccount].settings.bFilterOnSetNameToo or IIFA_DATABASE[IIfA.currentAccount].settings.bFilterOnSetName) then
      hasSetInfo, setName = IIfA:IsItemSet(itemLink)
      if hasSetInfo then
        -- Check if the set name matches the search filter
        retSet = zo_plainstrfind(zo_strlower(setName), searchFilter)
      end
    end

    return retSet
  end
  local hasValidSetFilter = HasSetSearchFilter()

  local hasSingleFilterMatch = IIfA.filterTypes and type(IIfA.filterTypes) == "table" and #IIfA.filterTypes >= 1
  local hasDualFilterMatch = IIfA.filterTypes and type(IIfA.filterTypes) == "table" and #IIfA.filterTypes >= 2
  local hasValidFurnishingFilterType = IIfA.filterTypes and type(IIfA.filterTypes) == "table" and #IIfA.filterTypes >= 3
  -- the following groups use nil initially rather than a type from GetItemLinkItemType()
  local isFilterGroupAllItems = IIfA.filterGroup == "All"
  local isFilterGroupWeapons = IIfA.filterGroup == "Weapons"
  local isFilterGroupArmor = IIfA.filterGroup == "Armor"
  local isFilterGroupJewelry = IIfA.filterGroup == "Jewelry"
  local isFilterGroupCompanion = IIfA.filterGroup == "Companion"
  local isFilterGroupFurnishing = IIfA.filterGroup == "Furnishing"

  --[[ Check if the filter group is set to something specific (not "All") and
  IIfA.filterTypes is populated ]]--
  local isFilterGroupSpecific = IIfA.filterGroup ~= "All"

  --[[ the following groups use corresponding itemType constants
  within a table and compared to GetItemLinkItemType() ]]--
  local isFilterGroupConsumable = IIfA.filterGroup == "Consumable"
  local isFilterGroupMaterials = IIfA.filterGroup == "Materials"
  local isFilterGroupSpecialized = IIfA.filterGroup == "Specialized"
  local isFilterGroupMisc = IIfA.filterGroup == "Misc"
  local isFilterGroupMiscSubfilter = IIfA.filterGroup == "MiscSubfilter"

  local isFilterGroupStolen = IIfA.filterGroup == "Stolen"
  local isFilterGroupAppearance = IIfA.filterGroup == "Appearance"
  local isFilterGroupJunk = IIfA.filterGroup == "Junk"

  --[[TODO: Would anyone ever choose Stolen and a set name? ]]--
  if isFilterGroupStolen then
    -- If the filter is set to "Stolen"
    ret = IsItemLinkStolen(itemLink)
  end

  if isFilterGroupAllItems then
    -- If the filter is set to "All"
    ret = true
  end

  if isFilterGroupSpecific and not isFilterGroupStolen then
    local function shouldMatchAllWeaponTypes()
      local invalidFilterType = not IIfA.filterTypes or #IIfA.filterTypes == 0
      return invalidFilterType and not isCompanionItem and isWeapon
    end

    local function shouldMatchAllArmorTypes()
      local invalidFilterType = not IIfA.filterTypes or #IIfA.filterTypes == 0
      local hasShield = weaponType == WEAPONTYPE_SHIELD
      local hasDisguise = specializedItemType == SPECIALIZED_ITEMTYPE_DISGUISE
      local hasCostume = specializedItemType == SPECIALIZED_ITEMTYPE_COSTUME
      return invalidFilterType and not isCompanionItem and (hasShield or hasDisguise or isWearable or hasCostume)
    end

    local function shouldMatchAllJewelryTypes()
      local invalidFilterType = not IIfA.filterTypes or #IIfA.filterTypes == 0
      local isJewelry = armorType == ARMORTYPE_NONE and (equipType == EQUIP_TYPE_NECK or equipType == EQUIP_TYPE_RING)
      return invalidFilterType and not isCompanionItem and isJewelry
    end

    local function shouldMatchAllCompanionItems()
      local invalidFilterType = not IIfA.filterTypes or #IIfA.filterTypes == 0
      return invalidFilterType and isCompanionItem
    end

    local function shouldMatchAllFurnishingItems()
      local invalidFilterType = not IIfA.filterTypes or #IIfA.filterTypes == 0
      return invalidFilterType and isFurnishingItem
    end
    --[[
    Consumable, Materials, Furnishings (Specialized), Misc, Junk : use Item Types for All

    All, Weapons, Armor, Jewelry, Companion : use nil for All
    ]]--

    --[[ All and Stolen Considered first and set ret to true ]]--

    --[[
    All : All (Unique)
    Weapons :
    Armor :
      Shield : Armor
      Appearance : Armor
    Jewelry :
    Consumable :
    Materials :
    Furnishings : Specialized
    Companion :
    Misc :
      Scripting : Misc (incorporated)
      Stolen : Misc
      Junk : Misc
    ]]--
    -- Weapons (Uses nil for top filter)
    --[[The values for Weapons use WEAPONTYPE without an leading
    itemType]]--
    if isFilterGroupWeapons then
      if shouldMatchAllWeaponTypes() then
        itemMatch = true
      elseif hasSingleFilterMatch then
        for i = 1, #IIfA.filterTypes do
          if weaponType == IIfA.filterTypes[i] and not isCompanionItem then
            itemMatch = true
            break
          end
        end
      end
    end

    -- Armor (Uses nil for top filter)
    --[[The values for Armor use armorType as the first parameter then
    subsequent comparisons use EQUIP_TYPE ]]--
    if isFilterGroupArmor then
      if shouldMatchAllArmorTypes() then
        itemMatch = true
      elseif hasDualFilterMatch then
        if armorType == IIfA.filterTypes[1] then
          for i = 2, #IIfA.filterTypes do
            if equipType == IIfA.filterTypes[i] and not isCompanionItem then
              itemMatch = true
              break
            end
          end
        end
      end
    end

    -- Appearance
    if isFilterGroupAppearance then
      --[[The values for Appearance use SPECIALIZED_ITEMTYPE because
      there are two Itemtypes and IIfA.filterTypes[1] would not work ]]--
      if hasSingleFilterMatch then
        for i = 1, #IIfA.filterTypes do
          if (specializedItemType == IIfA.filterTypes[i]) then
            itemMatch = true
            break
          end
        end
      end
    end

    -- Jewelry (Uses nil for top filter)
    --[[The values for Jewelry use only EQUIP_TYPE because
    armorType will be equal to ARMORTYPE_NONE ]]--
    if isFilterGroupJewelry then
      if shouldMatchAllJewelryTypes() then
        itemMatch = true
      elseif hasSingleFilterMatch then
        for i = 1, #IIfA.filterTypes do
          if equipType == IIfA.filterTypes[i] and not isCompanionItem then
            itemMatch = true
            break
          end
        end
      end
    end


    -- Consumable
    if isFilterGroupConsumable then
      --[[The values for Consumable use the Itemtypes and while recipe
      uses Specialized it will function independently of this filter ]]--
      if hasSingleFilterMatch then
        for i = 1, #IIfA.filterTypes do
          if (itemType == IIfA.filterTypes[i]) then
            itemMatch = true
            break
          end
        end
      end
    end

    -- Materials
    if isFilterGroupMaterials then
      --[[The values for Materials use the Itemtypes ]]--
      if hasSingleFilterMatch then
        for i = 1, #IIfA.filterTypes do
          if (itemType == IIfA.filterTypes[i]) then
            itemMatch = true
            break
          end
        end
      end
    end

    -- Furnishings (Uses nil for top filter)
    if isFilterGroupFurnishing then
      --[[The values for Furnishings are using custom constants to use with
      GetFurnitureDataCategoryInfo() where categoryId is similar to itemType
      and subcategoryId is similar to specializedItemType

      The main difference is that the first type is the itemType for Furnishings
      then the special categoryId, and then the subtype if selected. ]]--
      if shouldMatchAllFurnishingItems() then
        itemMatch = true
      elseif hasValidFurnishingFilterType then
        if itemType == IIfA.filterTypes[1] and categoryId == IIfA.filterTypes[2] then
          for i = 3, #IIfA.filterTypes do
            if (subcategoryId == IIfA.filterTypes[i]) then
              itemMatch = true
              break
            end
          end
        end
      end
    end

    -- Specialized
    if isFilterGroupSpecialized then
      --[[The values for Specialized use the Itemtypes as the first parameter
      then iterate over SPECIALIZED_ITEMTYPE ]]--
      if hasDualFilterMatch then
        if itemType == IIfA.filterTypes[1] then
          for i = 2, #IIfA.filterTypes do
            if (specializedItemType == IIfA.filterTypes[i]) then
              itemMatch = true
              break
            end
          end
        end
      end
    end

    -- MiscSubfilter
    if isFilterGroupMiscSubfilter then
      --[[The values for MiscSubfilter iterate over specialized item types ]]--
      if hasSingleFilterMatch then
        for i = 1, #IIfA.filterTypes do
          if (specializedItemType == IIfA.filterTypes[i]) then
            itemMatch = true
            break
          end
        end
      end
    end

    -- Companion (Uses nil for top filter)
    if isFilterGroupCompanion and isCompanionItem then
      if shouldMatchAllCompanionItems() then
        itemMatch = true
      elseif hasDualFilterMatch then
        if IIfA.filterTypes[1] == ITEMTYPE_ARMOR then
          for i = 2, #IIfA.filterTypes do
            if equipType == IIfA.filterTypes[i] then
              itemMatch = true
              break
            end
          end
        elseif IIfA.filterTypes[1] == ITEMTYPE_WEAPON then
          for i = 2, #IIfA.filterTypes do
            if weaponType == IIfA.filterTypes[i] then
              itemMatch = true
              break
            end
          end
        end
      end
    end

    -- Misc
    if isFilterGroupMisc then
      --[[The values for Misc use the Itemtypes and while Stolen
      uses its own category it functions independently of this filter ]]--
      if hasSingleFilterMatch then
        for i = 1, #IIfA.filterTypes do
          if (itemType == IIfA.filterTypes[i]) then
            itemMatch = true
            break
          end
        end
      end
    end

    -- Junk
    if isFilterGroupJunk then
      --[[The values for Junk use the Itemtypes but are part of Misc ]]--
      if hasSingleFilterMatch then
        if itemType == IIfA.filterTypes[1] then
          itemMatch = true
        end
      end
    end

    ret = itemMatch
  end

  if hasSearchFilter then
    if IIFA_DATABASE[IIfA.currentAccount].settings.bFilterOnSetName then
      -- Only set name matches are allowed
      ret = ret and hasValidSetFilter
    elseif IIFA_DATABASE[IIfA.currentAccount].settings.bFilterOnSetNameToo then
      -- Either set name or item name matches
      ret = ret and (hasValidSetFilter or hasValidItemNameFilter)
    else
      -- When both options are false, only item names should match
      ret = ret and hasValidItemNameFilter
    end
  end

  return ret
end

local function matchQuality(itemQuality)
  local quality = IIfA.InventoryListFilterQuality
  return IIFA_FILTER_MENU_QUALITY_ANY == quality or itemQuality == quality
end

--sort datalines
local function IIfA_FilterCompareUp(a, b)

  local sort1 = (IIfA.bSortQuality and a.quality) or a.name
  local sort2 = (IIfA.bSortQuality and b.quality) or b.name
  return (sort1 or IIfA.EMPTY_STRING) < (sort2 or IIfA.EMPTY_STRING)
end

local function IIfA_FilterCompareDown(a, b)
  return IIfA_FilterCompareUp(b, a)
end

local function sort(dataLines)
  if dataLines == nil then dataLines = IIFA_GUI_ListHolder.dataLines end

  if (IIfA.ScrollSortUp) then
    dataLines = table.sort(dataLines, IIfA_FilterCompareUp)
  elseif (not IIfA.ScrollSortUp) then
    dataLines = table.sort(dataLines, IIfA_FilterCompareDown)
  end
end

local function itemSum(location)
  if type(location.bagSlot) ~= "table" then return 0 end
  local totQty = 0
  for bagSlot, itemCount in pairs(location.bagSlot) do
    totQty = totQty + itemCount
  end
  return totQty
end

local function checkSearchFilter(searchFilterNew)
  local searchFilterCurrent = IIfA.searchFilter
  if ((searchFilterNew and searchFilterCurrent and searchFilterNew ~= searchFilterCurrent) or
    (not searchFilterNew and not searchFilterCurrent) or
    (searchFilterCurrent and searchFilterCurrent == "Click to search..."))
  then
    searchFilterNew = searchFilterNew or IIfA.GUI_SearchBox:GetText()
    searchFilterNew = ZO_CachedStrFormat("<<C:1>>", searchFilterNew)
    return zo_strlower(searchFilterNew)
  else
    return searchFilterCurrent
  end
end

function IIfA:UpdateScrollDataLinesData()
  IIfA.searchFilter = checkSearchFilter()
  local dataLines = {}
  local DBv3 = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3
  local totalItems = 0 -- Tracks total item counts across all entries

  if DBv3 then
    -- Create coroutine to process database items in chunks
    local co = coroutine.create(function()
      for itemKey, dbItem in pairs(DBv3) do
        -- Determine the item link
        local identifiedLink = nil
        if IIfA:isCollectibleLink(itemKey) or IIfA:isItemLink(itemKey) then
          identifiedLink = itemKey
        elseif IIfA:isItemKey(itemKey) then
          identifiedLink = dbItem.itemLink
        end

        if identifiedLink and identifiedLink ~= IIfA.EMPTY_STRING then
          -- Retrieve item details based on its type
          local identifiedIcon, identifiedItemName, identifiedItemQuality
          if IIfA:isCollectibleLink(identifiedLink) then
            local collectibleId = IIfA:GetCollectibleLinkItemId(identifiedLink)
            identifiedIcon = GetCollectibleIcon(collectibleId)
            identifiedItemName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetCollectibleName(collectibleId))
            identifiedItemQuality = 1
          elseif IIfA:isItemLink(identifiedLink) then
            identifiedIcon = GetItemLinkIcon(identifiedLink)
            identifiedItemName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(identifiedLink))
            identifiedItemQuality = GetItemLinkDisplayQuality(identifiedLink)
          end

          -- Update cached item data
          dbItem.itemName = dbItem.itemName or identifiedItemName
          dbItem.itemQuality = dbItem.itemQuality or identifiedItemQuality
          dbItem.filterType = dbItem.filterType or 0

          -- Initialize tracking variables for this item
          local itemCount = 0
          local bWorn, bWornCompanion = false, false
          local isItemMatched = false

          -- Process each location and update counts and states
          for locationName, locData in pairs(dbItem.locations) do
            itemCount = itemCount + itemSum(locData)

            if DoesInventoryMatchList(locationName, locData) then
              isItemMatched = true
            end

            if locData.bagID == BAG_WORN then
              bWorn = true
            elseif locData.bagID == BAG_COMPANION_WORN then
              bWornCompanion = true
            end
          end

          local dataLine = {
            link = identifiedLink,
            qty = itemCount,
            icon = identifiedIcon,
            name = dbItem.itemName,
            quality = dbItem.itemQuality,
            filter = dbItem.filterType,
            worn = bWorn,
            wornCompanion = bWornCompanion
          }

          -- Add data to dataLines if the item meets all criteria
          if itemCount > 0 and isItemMatched and matchFilter(identifiedItemName, identifiedLink) and matchQuality(dbItem.itemQuality) then
            table.insert(dataLines, dataLine)
            totalItems = totalItems + itemCount
          end
        end

        -- Yield after processing each item to prevent blocking
        coroutine.yield()
      end
    end)

    -- Resume coroutine until complete
    while coroutine.status(co) ~= "dead" do
      local success, err = coroutine.resume(co)
      if not success then
        d("Error in UpdateScrollDataLinesData coroutine: " .. tostring(err))
        break
      end
    end
  end

  -- Update GUI elements with processed data
  IIFA_GUI_ListHolder.dataLines = dataLines
  sort(IIFA_GUI_ListHolder.dataLines)
  IIFA_GUI_ListHolder.dataOffset = 0
  IIFA_GUI_ListHolder_Slider:SetValue(0)

  -- Set handlers for scroll interaction
  IIFA_GUI_ListHolder_SliderUp:SetHandler("OnClicked", function(self, button, ctrl, alt, shiftPressed)
    local increment = shiftPressed and 10 or 1
    IIfA:GuiOnScroll(self:GetParent(), increment)
  end)

  IIFA_GUI_ListHolder_SliderDown:SetHandler("OnClicked", function(self, button, ctrl, alt, shiftPressed)
    local increment = shiftPressed and -10 or -1
    IIfA:GuiOnScroll(self:GetParent(), increment)
  end)

  IIFA_GUI_ListHolder:SetHandler("OnMouseWheel", function(self, delta, ctrl, alt, shiftPressed)
    local increment = delta * (shiftPressed and 10 or 1)
    IIfA:GuiOnScroll(self:GetParent(), increment)
  end)

  -- even if the counts aren’t visible, update them so they show properly if user turns them on
  IIFA_GUI_ListHolder_Counts_Items:SetText("Item count: " .. totalItems)
  IIFA_GUI_ListHolder_Counts_Slots:SetText("Appx. slots used: " .. #dataLines)
end

--Update the FCOItemSaver marker icons at the IIfA inventory frames
local function updateFCOISMarkerIcons(curLine, showFCOISMarkerIcons, createFCOISMarkerIcons, iconId)
  if not FCOIS or not IIfA.UpdateFCOISMarkerIcons then return end
  IIfA:UpdateFCOISMarkerIcons(curLine, showFCOISMarkerIcons, createFCOISMarkerIcons, iconId)
end

local function fillLine(curLine, curItem)
  local color
  if curItem == nil then
    curLine.itemLink = IIfA.EMPTY_STRING
    curLine.icon:SetTexture(nil)
    curLine.icon:SetAlpha(0)
    curLine.text:SetText(IIfA.EMPTY_STRING)
    curLine.qty:SetText(IIfA.EMPTY_STRING)
    curLine.worn:SetHidden(true)
    curLine.wornCompanion:SetHidden(true)
    curLine.stolen:SetHidden(true)
    -- Hide the FCOIS marker icons at the line (do not create them if not needed) -> File plugins/FCOIS/IIfA_FCOIS.lua
    updateFCOISMarkerIcons(curLine, false, false, -1)
  else
    local r, g, b, a = 255, 255, 255, 1
    if (curItem.quality) then
      color = GetItemQualityColor(curItem.quality)
      r, g, b, a = color:UnpackRGBA()
    end
    curLine.itemLink = curItem.link
    curLine.icon:SetTexture(curItem.icon)
    curLine.icon:SetAlpha(1)
    local text = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, curItem.name)
    curLine.text:SetText(text)
    curLine.text:SetColor(r, g, b, a)
    curLine.qty:SetText(curItem.qty)
    curLine.worn:SetHidden(not curItem.worn)
    curLine.wornCompanion:SetHidden(not curItem.wornCompanion)
    curLine.stolen:SetHidden(not IsItemLinkStolen(curItem.link))
    -- Show the FCOIS marker icons at the line, if enabled in the settings (create them if needed) -> File plugins/FCOIS/IIfA_FCOIS.lua
    updateFCOISMarkerIcons(curLine, IIFA_DATABASE[IIfA.currentAccount].settings.FCOISshowMarkerIcons, false, -1)
  end
end

function IIfA:SetDataLinesData()
  --	p("SetDataLinesData")

  local curLine, curData
  for i = 1, IIFA_GUI_ListHolder.maxLines do

    curLine = IIFA_GUI_ListHolder.lines[i]
    curData = IIFA_GUI_ListHolder.dataLines[IIFA_GUI_ListHolder.dataOffset + i]
    IIFA_GUI_ListHolder.lines[i] = curLine

    if (curData ~= nil) then
      fillLine(curLine, curData)
    else
      fillLine(curLine, nil)
    end
  end
end

function IIfA:UpdateInventoryScroll()
  if IIFA_GUI_ListHolder.dataOffset < 0 then IIFA_GUI_ListHolder.dataOffset = 0 end
  if IIFA_GUI_ListHolder.maxLines == nil then IIFA_GUI_ListHolder.maxLines = 35 end
  IIfA:SetDataLinesData()

  local total = #IIFA_GUI_ListHolder.dataLines - IIFA_GUI_ListHolder.maxLines
  IIFA_GUI_ListHolder_Slider:SetMinMax(0, total)
end

function IIfA:RefreshInventoryScroll()

  -- p("RefreshInventoryScroll")

  IIfA:UpdateScrollDataLinesData()
  IIfA:UpdateInventoryScroll()
end

function IIfA:SetItemCountPosition()
  for i = 1, IIFA_GUI_ListHolder.maxLines do
    local line = IIFA_GUI_ListHolder.lines[i]
    line.text:ClearAnchors()
    line.qty:ClearAnchors()
    if IIFA_DATABASE[IIfA.currentAccount].settings.showItemCountOnRight then
      line.qty:SetAnchor(TOPRIGHT, line, TOPRIGHT, 0, 0)
      line.text:SetAnchor(TOPLEFT, line:GetNamedChild("Button"), TOPRIGHT, 18, 0)
      line.text:SetAnchor(TOPRIGHT, line.qty, TOPLEFT, -10, 0)
    else
      line.qty:SetAnchor(TOPLEFT, line:GetNamedChild("Button"), TOPRIGHT, 8, -3)
      line.text:SetAnchor(TOPLEFT, line.qty, TOPRIGHT, 18, 0)
      line.text:SetAnchor(TOPRIGHT, line, TOPLEFT, 0, 0)
    end
  end
end

-- Define constants for anchor groups
local IIFA_DEFAULT_ANCHOR = 1

-- Define constants for anchor types
local IIFA_ANCHOR_EQUIPPED = 1
local IIFA_ANCHOR_COMPANION_EQUIPPED = 2
local IIFA_ANCHOR_STOLEN = 3

-- Function to retrieve anchor values
local function GetAnchor(group, anchor, control)

  -- Anchor definitions
  local anchorGroups = {
    [IIFA_DEFAULT_ANCHOR] = {
      [IIFA_ANCHOR_EQUIPPED] = { TOPRIGHT, control, TOPLEFT, 12, 5 },
      [IIFA_ANCHOR_COMPANION_EQUIPPED] = { TOPRIGHT, control, TOPLEFT, 12, 5 },
      [IIFA_ANCHOR_STOLEN] = { BOTTOMRIGHT, control, BOTTOMLEFT, 15, -8 },
    },
  }

  local groupAnchors = anchorGroups[group]
  if groupAnchors then
    local anchorValues = groupAnchors[anchor]
    if anchorValues then
      return unpack(anchorValues) -- Return point, relativeTo, relativePoint, offsetX, offsetY
    end
  end
  -- Fallback to default equipped anchor
  return unpack(anchorGroups[IIFA_DEFAULT_ANCHOR][IIFA_ANCHOR_EQUIPPED])
end

function IIfA:CreateLine(i, predecessor, parent)
  local line = WINDOW_MANAGER:CreateControlFromVirtual("IIFA_ListItem_" .. i, parent, "IIFA_SlotTemplate")

  line.icon = line:GetNamedChild("Button"):GetNamedChild("Icon")
  line.text = line:GetNamedChild("Name")
  line.qty = line:GetNamedChild("Qty")
  line.worn = line:GetNamedChild("IconWorn")
  line.wornCompanion = line:GetNamedChild("IconCompanionWorn")
  line.stolen = line:GetNamedChild("IconStolen")

  line:SetHidden(false)
  line:SetMouseEnabled(true)
  line:SetHeight(IIFA_GUI_ListHolder.rowHeight)

  line.worn:ClearAnchors()
  local wornPoint, wornRelativeTo, wornRelativePoint, wornOffsetX, wornOffsetY = GetAnchor(IIFA_DEFAULT_ANCHOR, IIFA_ANCHOR_EQUIPPED, line)
  line.worn:SetAnchor(wornPoint, wornRelativeTo, wornRelativePoint, wornOffsetX, wornOffsetY)

  line.wornCompanion:ClearAnchors()
  local wornCompanionPoint, wornCompanionRelativeTo, wornCompanionRelativePoint, wornCompanionOffsetX, wornCompanionOffsetY = GetAnchor(IIFA_DEFAULT_ANCHOR, IIFA_ANCHOR_COMPANION_EQUIPPED, line)
  line.wornCompanion:SetAnchor(wornCompanionPoint, wornCompanionRelativeTo, wornCompanionRelativePoint, wornCompanionOffsetX, wornCompanionOffsetY)

  line.stolen:ClearAnchors()
  local stolenPoint, stolenRelativeTo, stolenRelativePoint, stolenOffsetX, stolenOffsetY = GetAnchor(IIFA_DEFAULT_ANCHOR, IIFA_ANCHOR_STOLEN, line)
  line.stolen:SetAnchor(stolenPoint, stolenRelativeTo, stolenRelativePoint, stolenOffsetX, stolenOffsetY)

  if i == 1 then
    line:SetAnchor(TOPLEFT, IIFA_GUI_ListHolder, TOPLEFT, 0, 0)
    line:SetAnchor(TOPRIGHT, IIFA_GUI_ListHolder, TOPRIGHT, 0, 0)
  else
    line:SetAnchor(TOPLEFT, predecessor, BOTTOMLEFT, 0, 0)
    line:SetAnchor(TOPRIGHT, predecessor, BOTTOMRIGHT, 0, 0)
  end

  line:SetHandler("OnMouseEnter", function(self) IIfA:GuiLineOnMouseEnter(self) end)
  line:SetHandler("OnMouseExit", function(self) IIfA:GuiLineOnMouseExit(self) end)
  line:SetHandler("OnMouseDoubleClick", function(...) IIfA:GUIDoubleClick(...) end)

  return line
end

function IIfA:CreateInventoryScroll()
  p("CreateInventoryScroll")

  IIFA_GUI_ListHolder.dataOffset = 0
  IIFA_GUI_ListHolder.dataLines = {}
  IIFA_GUI_ListHolder.lines = {}
  IIFA_GUI_Header_SortBar.Icon = IIFA_GUI_Header_SortBar:GetNamedChild("_Sort"):GetNamedChild("_Icon")

  -- Set max lines to the amount that can be shown based on constraints
  IIFA_GUI_ListHolder.maxLines = 35
  local predecessor = nil
  for i = 1, IIFA_GUI_ListHolder.maxLines do
    IIFA_GUI_ListHolder.lines[i] = IIfA:CreateLine(i, predecessor, IIFA_GUI_ListHolder)
    predecessor = IIFA_GUI_ListHolder.lines[i]
  end

  -- Access `showItemCountOnRight` from `IIFA_DATABASE`
  if IIFA_DATABASE[IIfA.currentAccount].settings.showItemCountOnRight then
    IIfA:SetItemCountPosition()
  end

  -- Setup slider range
  -- local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
  -- IIFA_GUI_ListHolder_Slider:SetThumbTexture(tex, tex, tex, 16, 50, 0, 0, 1, 1)
  IIFA_GUI_ListHolder_Slider:SetMinMax(0, #IIFA_GUI_ListHolder.dataLines - IIFA_GUI_ListHolder.maxLines)

  return IIFA_GUI_ListHolder.lines
end

function IIfA:GetCharacterList()
  local charList = {}
  for charName, _ in pairs(IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].CharNameToId) do
    table.insert(charList, charName)
  end
  return charList
end

--[[ GetAccountInventoryList creates the filter dropdown list
for the main UI ]]--
function IIfA:GetAccountInventoryList()
  local accountInventories = IIfA.dropdownLocNames

  -- Get character names directly from CharNameToId
  local charNameToId = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].CharNameToId
  for charName, _ in pairs(charNameToId) do
    if (accountInventories[charName] == nil) then
      table.insert(accountInventories, charName)
    end
  end

  -- Get companion names from CompanionNameToId
  local companionNameToId = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].CompanionNameToId
  for companionName, _ in pairs(companionNameToId) do
    if (accountInventories[companionName] == nil) then
      table.insert(accountInventories, companionName)
    end
  end

  -- Banks are the same as toons, same order as the player normally sees them
  if IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].bCollectGuildBankData then
    local guildBankInfo = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].guildBankInfo
    for guildName, guildData in pairs(guildBankInfo) do
      if guildData.bCollectData then
        table.insert(accountInventories, guildName)
      end
    end
  end

  -- House item inventories
  if IIFA_DATABASE[IIfA.currentAccount].settings.b_collectHouses then
    for idx, houseName in pairs(IIfA:GetTrackedHouseNames()) do
      table.insert(accountInventories, houseName)
    end
  end

  return accountInventories
end

function IIfA:QueryAccountInventory(itemLink)
  -- IIfA:dm("Debug", "[QueryAccountInventory] " .. itemLink)
  -- Ensure the itemLink is valid
  local hasValidLinkType = IIfA:isItemLink(itemLink) or IIfA:isCollectibleLink(itemLink)
  if not hasValidLinkType then return end
  -- IIfA:dm("Debug", "hasValidLinkType")
  -- Determine the item key
  local identifiedItemKey
  if IIfA:isItemLink(itemLink) then
    identifiedItemKey = IIfA:GetItemKey(itemLink)
  elseif IIfA:isCollectibleLink(itemLink) then
    identifiedItemKey = itemLink
  end

  -- Access DBv3
  local DBv3 = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3

  -- Return if the item key, DBv3, or item data is invalid
  if not identifiedItemKey or not DBv3 or next(DBv3) == nil then return end
  -- IIfA:dm("Debug", " item key, DBv3, or item is valid")
  if identifiedItemKey ~= nil then
    -- IIfA:dm("Debug", "Item key: " .. identifiedItemKey)
    -- IIfA:dm("Debug", "Item key (text): " .. tostring(identifiedItemKey))
  else
    IIfA:dm("Debug", "Nil key")
  end
  local item = DBv3[identifiedItemKey]
  if not item then
    IIfA:dm("Warn", "Item not found.")
    return
  end
  -- IIfA:dm("Debug", "item is valid")

  -- Update the item link in queryItem if it's an item key
  local queryItem = { link = itemLink, locations = {} }
  if IIfA:isItemKey(identifiedItemKey) then
    queryItem.link = item.itemLink
  end

  -- Local variables for name lookups
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  local charIdToName = serverData.CharIdToName
  local companionIdToName = serverData.CompanionIdToName

  -- Process item locations
  for location, locationData in pairs(item.locations) do
    local itemCount = itemSum(locationData)
    local AlreadySavedLoc = false

    -- Resolve character or companion names for certain bag types
    if locationData.bagID == BAG_WORN or locationData.bagID == BAG_BACKPACK then
      location = charIdToName[location]
    elseif locationData.bagID == BAG_COMPANION_WORN then
      location = companionIdToName[location]
    end

    if location ~= nil then
      -- Check if location already exists in queryItem
      for queryLocation, queryLocationData in pairs(queryItem.locations) do
        if queryLocationData.name == location then
          queryLocationData.itemsFound = queryLocationData.itemsFound + itemCount
          AlreadySavedLoc = true
        end
      end

      -- Add a new location if not already saved
      if itemCount > 0 and not AlreadySavedLoc then
        local newLocation = { name = location }
        local bagID = locationData.bagID

        if bagID == BAG_WORN or bagID == BAG_BACKPACK then
          newLocation.bagLoc = BAG_BACKPACK
        elseif bagID == BAG_BANK or bagID == BAG_SUBSCRIBER_BANK then
          newLocation.bagLoc = BAG_BANK
        elseif bagID == BAG_VIRTUAL then
          newLocation.bagLoc = BAG_VIRTUAL
        elseif bagID == BAG_FURNITURE_VAULT then
          newLocation.bagLoc = BAG_FURNITURE_VAULT
        elseif bagID == BAG_COMPANION_WORN then
          newLocation.bagLoc = BAG_COMPANION_WORN
        elseif bagID == BAG_GUILDBANK then
          newLocation.bagLoc = BAG_GUILDBANK
        elseif bagID >= BAG_HOUSE_BANK_ONE and bagID <= BAG_HOUSE_BANK_TEN and tonumber(location) then
          -- Housing chest
          newLocation.name = GetCollectibleNickname(location)
          if newLocation.name == IIfA.EMPTY_STRING then
            newLocation.name = GetCollectibleName(location)
          end
          newLocation.bagLoc = BAG_HOUSE_BANK_ONE
        elseif bagID == location and tonumber(location) then
          -- House
          newLocation.name = GetCollectibleName(location)
          newLocation.bagLoc = IIFA_HOUSING_BAG_LOCATION
        end

        newLocation.itemsFound = itemCount
        newLocation.worn = bagID == BAG_WORN
        newLocation.wornCompanion = bagID == BAG_COMPANION_WORN
        table.insert(queryItem.locations, newLocation)
      end
    end
  end

  return queryItem
end

-- test query
-- /script d(IIfA:QueryAccountInventory("|H0:item:134629:6:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"))

function IIfA:GetSceneVisible(name)
  local frameSettings = IIFA_DATABASE[IIfA.currentAccount].characters[IIfA.currentCharacterId].frameSettings
  if frameSettings and frameSettings[name] then
    IIfA:dm("Debug", "Settings Exist, returning hidden for <<1>>.", name)
    return not frameSettings[name].hidden
  else
    -- Default visibility is true if no specific settings exist
    IIfA:dm("Debug", "Settings not present, returning true for <<1>>.", name)
    return true
  end
end

function IIfA:SetSceneVisible(name, value)
  local frameSettings = IIFA_DATABASE[IIfA.currentAccount].characters[IIfA.currentCharacterId].frameSettings
  if frameSettings and frameSettings[name] then
    IIfA:dm("Debug", "Settings Exist, updating <<1>>.", name)
    frameSettings[name].hidden = not value
  end
  IIfA:dm("Debug", "Settings not present, nothing set for <<1>>.", name)
end

-- general note for popup menus
-- example here http://www.esoui.com/downloads/info1146-LibCustomMenu.html
-- AddCustomSubMenuItem(mytext, entries, myfont, normalColor, highlightColor, itemYPad)

function IIfA:SetupBackpack()

  local function createInventoryDropdown()
    local comboBox, entry

    if IIFA_GUI_Header_Dropdown_Main.comboBox ~= nil then
      comboBox = IIFA_GUI_Header_Dropdown_Main.comboBox
    else
      comboBox = ZO_ComboBox_ObjectFromContainer(IIFA_GUI_Header_Dropdown_Main)
      IIFA_GUI_Header_Dropdown_Main.comboBox = comboBox
    end

    local function OnItemSelect(_, choiceText, choice)
      --		d("OnItemSelect", choiceText, choice)
      IIfA:SetInventoryListFilter(choiceText)
      IIfA:RefreshInventoryScroll()
      PlaySound(SOUNDS.POSITIVE_CLICK)
    end

    local function OnChestSelect(_, choiceText, choice)
      -- p("OnChestSelect '<<1>>' - <<2>>", choiceText, choice)
      local cName, cId
      for ctr = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
        cId = GetCollectibleForBag(ctr)
        cName = GetCollectibleNickname(cId)
        if cName == IIfA.EMPTY_STRING then
          cName = GetCollectibleName(cId)
        end
        cName = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, cName)
        if cName == choiceText then
          IIfA:SetInventoryListFilter("Housing Storage", ctr)
          break
        end
      end
      IIfA:RefreshInventoryScroll()
      PlaySound(SOUNDS.POSITIVE_CLICK)
    end

    comboBox:SetSortsItems(false)

    IIFA_GUI_Header_Dropdown_Main.m_comboBox.m_height = 500    -- normal height is 250, so just double it (will be plenty tall for most users - even Mana)

    local validChoices = IIfA:GetAccountInventoryList()

    for i = 1, #validChoices do
      entry = comboBox:CreateItemEntry(validChoices[i], OnItemSelect)
      --[[ TODO: Why do we print this information ]]--
      d(comboBox:AddItem(entry))
      if validChoices[i] == IIfA:GetInventoryListFilter() then
        comboBox:SetSelectedItem(validChoices[i])
      end
    end

    local cName, cId
    for ctr = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
      cId = GetCollectibleForBag(ctr)
      if IsCollectibleUnlocked(cId) then
        cName = GetCollectibleNickname(cId)
        if cName == IIfA.EMPTY_STRING then
          cName = GetCollectibleName(cId)
        end
        cName = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, cName)
        entry = comboBox:CreateItemEntry(cName, OnChestSelect)
        comboBox:AddItem(entry)
      end
    end

    local function ScrollableMenuItemPrehookMouseEnter(control)
      if control:GetName():find("IIFA_GUI_Header_Dropdown_Main") ~= nil then
        local itemLabel = control:GetNamedChild("Label"):GetText()
        if IIfA.dropdownLocNamesTT[itemLabel] then
          IIfA:GuiShowTooltip(control, IIfA.dropdownLocNamesTT[itemLabel])
        end
      end
    end
    local function ScrollableMenuItemPrehookMouseExit(control)
      IIfA:GuiHideTooltip(control)
    end

    ZO_PreHook("ZO_ScrollableComboBox_Entry_OnMouseEnter", ScrollableMenuItemPrehookMouseEnter)
    ZO_PreHook("ZO_ScrollableComboBox_Entry_OnMouseExit", ScrollableMenuItemPrehookMouseExit)
  end

  local function createInventoryDropdownQuality()
    local qualityDict = getQualityDict()

    IIFA_GUI_Header_Dropdown_Quality.comboBox = IIFA_GUI_Header_Dropdown_Quality.comboBox or ZO_ComboBox_ObjectFromContainer(IIFA_GUI_Header_Dropdown_Quality)

    local validChoices = {
      GetString(IIFA_DROPDOWN_QUALITY_MENU_ANY),
      getColoredString(ITEM_DISPLAY_QUALITY_TRASH, GetString(SI_ITEMDISPLAYQUALITY0)),
      getColoredString(ITEM_DISPLAY_QUALITY_NORMAL, GetString(SI_ITEMDISPLAYQUALITY1)),
      getColoredString(ITEM_DISPLAY_QUALITY_MAGIC, GetString(SI_ITEMDISPLAYQUALITY2)),
      getColoredString(ITEM_DISPLAY_QUALITY_ARCANE, GetString(SI_ITEMDISPLAYQUALITY3)),
      getColoredString(ITEM_DISPLAY_QUALITY_ARTIFACT, GetString(SI_ITEMDISPLAYQUALITY4)),
      getColoredString(ITEM_DISPLAY_QUALITY_LEGENDARY, GetString(SI_ITEMDISPLAYQUALITY5)),
      getColoredString(ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE, GetString(SI_ITEMDISPLAYQUALITY6)),
    }

    local comboBox = IIFA_GUI_Header_Dropdown_Quality.comboBox

    local function OnItemSelect(_, choiceText, choice)
      IIfA:SetInventoryListFilterQuality(getQualityDict()[choiceText])
      PlaySound(SOUNDS.POSITIVE_CLICK)
    end

    comboBox:SetSortsItems(false)

    for i = 1, #validChoices do
      local entry = comboBox:CreateItemEntry(validChoices[i], OnItemSelect)
      comboBox:AddItem(entry)
      if qualityDict[validChoices[i]] == IIfA:GetInventoryListFilterQuality() then
        comboBox:SetSelectedItem(validChoices[i])
      end
    end
    -- return IIFA_GUI_Header_Dropdown
  end

  IIfA.InventoryListFilter = IIFA_DATABASE[IIfA.currentAccount].characters[IIfA.currentCharacterId].defaultInventoryFrameView
  IIfA:CreateInventoryScroll()
  createInventoryDropdown()
  createInventoryDropdownQuality()

  -- IIfA:GuiOnSort()
end

function IIfA:ProcessRightClick(control)
  if control == nil then return end

  control = control:GetParent()
  if control:GetName():match("IIFA_ListItem") == nil or control.itemLink == nil then return end

  -- it's an IIFA list item, lets see if it has data, and allow menu if it does
  local itemLink = control and control.itemLink or nil
  local dataEntryItemLink = control and control.dataEntry and control.dataEntry.data and control.dataEntry.data.itemLink or nil
  local identifiedLink = itemLink or dataEntryItemLink
  IIfA:dm("Debug", "[ProcessRightClick] itemLink <<1>>", itemLink)
  IIfA:dm("Debug", "[ProcessRightClick] dataEntryItemLink <<1>>", dataEntryItemLink)

  IIfA:dm("Debug", "[ProcessRightClick] itemLink: <<1>>", identifiedLink)
  if identifiedLink and identifiedLink ~= IIfA.EMPTY_STRING then
    zo_callLater(function()
      AddCustomMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() IIfA:GUIDoubleClick(control, MOUSE_BUTTON_INDEX_LEFT) end, MENU_ADD_OPTION_LABEL)
      --Check if the item is a motif
      if IIfA.bAddContextMenuEntryMissingMotifsInIIfA and GetItemLinkItemType(identifiedLink) == ITEMTYPE_RACIAL_STYLE_MOTIF then
        local isMotif, motifNum = IIfA:IsItemMotif(identifiedLink)
        if isMotif and motifNum then
          AddCustomMenuItem("Missing motifs (#" .. tostring(motifNum) .. ") to text", function() IIfA:FMC(control, identifiedLink, "Private") end, MENU_ADD_OPTION_LABEL)
          AddCustomMenuItem("Missing motifs (#" .. tostring(motifNum) .. ") to chat", function() IIfA:FMC(control, identifiedLink, "Public") end, MENU_ADD_OPTION_LABEL)
        end
      end
      AddCustomMenuItem("Filter by Item Name", function() IIfA:FilterByItemName(control) end, MENU_ADD_OPTION_LABEL)
      --Check if the item is as set
      local isSet, setName = IIfA:IsItemSet(identifiedLink)
      if isSet then
        AddCustomMenuItem("Filter by Item Set Name", function() IIfA:FilterByItemSet(control, setName) end, MENU_ADD_OPTION_LABEL)
      end
      if MasterMerchant then
        AddMenuItem(GetString(MM_STATS_TO_CHAT), function() MasterMerchant:OnItemLinkAction(identifiedLink) end)
      end
      ShowMenu(control)
    end, 0)
  end
end

function IIfA:IsItemSet(itemLink)
  if itemLink == nil then return false, nil end
  local hasSetInfo, setName = GetItemLinkSetInfo(itemLink, false)
  hasSetInfo = hasSetInfo or false
  if setName and setName > IIfA.EMPTY_STRING then
    setName = ZO_CachedStrFormat("<<C:1>>", setName)
  end
  return hasSetInfo, setName
end

function IIfA:IsItemMotif(itemLink)
  local motifNum = GetItemLinkName(itemLink):match("%d+")
  motifNum = tonumber(motifNum)
  IIfA:dm("Debug", "[IsItemMotif] itemLink: <<1>>, motifNum: <<2>>", itemLink, motifNum)
  local motifAchieves = IIfA:GetMotifAchieves()
  if motifAchieves[motifNum] ~= nil then return true, motifNum end
  return false, nil
end

function IIfA:GetMotifAchieves()
  -- following lookup turns a motif number "Crafting Motif 33: Thieves Guild Axes" into an achieve lookup
  -- |H1:achievement:1318:16383:1431113493|h|h
  -- the index is the # from the motif text, NOT any internal value
  local motifAchieves = {
    [15] = 1144, -- Dwemer
    [16] = 1319, -- Glass
    [17] = 1181, -- Xivkyn
    [18] = 1318, -- Akaviri
    [19] = 1348, -- Mercenary
    [20] = 1713, -- Yokudan
    [21] = 1341, -- Ancient Orc
    [22] = 1411, -- Trinimac
    [23] = 1412, -- Malacath
    [24] = 1417, -- Outlaw
    [25] = 1415, -- Aldmeri Dominion
    [26] = 1416, -- Daggerfall Covenant
    [27] = 1414, -- Ebonheart Pact
    [28] = 1797, -- Ra Gada
    [29] = 1418, -- Soul Shriven
    [30] = 1933, -- Morag Tong
    [31] = 1676, -- Skinchanger
    [32] = 1422, -- Abah's Watch
    [33] = 1423, -- Thieves Guild
    [34] = 1424, -- Assasins League
    [35] = 1659, -- Dro-m'Athra
    [36] = 1661, -- Dark Brotherhood
    [37] = 1798, -- Ebony
    [38] = 1715, -- Draugr
    [39] = 1662, -- Minotaur
    [40] = 1660, -- Order Hour
    [41] = 1714, -- Celestial
    [42] = 1545, -- Hollowjack
    -- [43] = 0000, -- Grim Harlequin, not listed in Lore Library
    [44] = 1796, -- Silken Ring
    [45] = 1795, -- Mazzatun
    -- [46] = 0000, -- Frostcaster, not listed in Lore Library
    [47] = 1934, -- Buoyant Armiger
    [48] = 1932, -- Ashlander
    [49] = 1935, -- Militant Ordinator
    [50] = 2023, -- Telvanni
    [51] = 2021, -- Hlaalu
    [52] = 2022, -- Redoran
    -- [53] = 0000, -- Tsaesci, not listed in Lore Library
    [54] = 2098, -- Bloodforge
    [55] = 2097, -- Dreadhorn
    [56] = 2044, -- Apostle
    [57] = 2045, -- Ebonshadow
    [58] = 2190, -- Fang Lair
    [59] = 2189, -- Scalecaller
    [60] = 2120, -- Worm Cult
    [61] = 2186, -- Psijic
    [62] = 2187, -- Sapiarch
    [63] = 2188, -- Dremora
    [64] = 2285, -- Pyandonean
    [65] = 2317, -- Huntsman
    [66] = 2318, -- Silver Dawn
    [67] = 2319, -- Welkynar
    [68] = 2359, -- Honor Guard
    [69] = 2360, -- Dead Water
    [70] = 2361, -- Elder Argonian
    [71] = 2503, -- Coldsnap
    [72] = 2504, -- Meridian
    [73] = 2505, -- Annequina
    [74] = 2506, -- Pellitine
    [75] = 2507, -- Sunspire
    [76] = 2630, -- Dragonguard
    [77] = 2629, -- Stags of Z'en
    [78] = 2628, -- Moongrave Fane
    [79] = 2024, -- Refabricated
    [80] = 2750, -- Shield of Senchal
    [81] = 2750, -- New Moon Priest
    [82] = 2747, -- Icereach Coven
    [83] = 2749, -- Pyre Watch
    [84] = 2757, -- Blackreach Vanguard
    [85] = 2761, -- Greymoor
    [86] = 2762, -- Sea Giant
    [87] = 2763, -- Ancestral Nord
    [88] = 2776, -- Ancestral Orc
    [89] = 2773, -- Ancestral High Elf
    [90] = 2849, -- Thorn Legion
    [91] = 2850, -- Hazardous Alchemy
    [92] = 2903, -- Ancestral Akaviri
    [93] = 2904, -- Ancestral Breton
    [94] = 2905, -- Ancestral Reach
    [95] = 2926, -- Nighthollow
    [96] = 2938, -- Arkthzand Armory
    [97] = 2998, -- Wayward Guardian
    [98] = 2959, -- House Hexos
    [99] = 2991, -- Waking Flame
    [100] = 2984, -- True-Sworn
    [101] = 3001, -- Ivory Brigade
    [102] = 3002, -- Sul-Xan
    [103] = 3000, -- Black Fin Legion
    [104] = 2999, -- Ancient Daedric
    [105] = 3094, -- Crimson Oath
    [106] = 3097, -- Silver Rose
    [107] = 3098, -- Annihilarch’s Chosen
    [108] = 3220, -- Fargrave Guardian
    [110] = 3228, -- Dreadsails
    [111] = 3229, -- Ascendant Order
    [112] = 3258, -- Syrabanic Marine
    [113] = 3259, -- Steadfast Society
    [114] = 3260, -- Systres Guardian
    [115] = 3422, -- Y’ffre’s Will
    [116] = 3423, -- Drowned Mariner
    [117] = 3464, -- Firesong
    [118] = 3465, -- House Mornard
    [119] = 3547, -- Blessed Inheritor
    [120] = 3546, -- Scribes of Mora
    [121] = 3667, -- Clan Dreamcarver
    [122] = 3668, -- Dead Keeper
    [123] = 3669, -- Kindred’s Concord
    [124] = 3921, -- The Recollection
    [125] = 3922, -- Blind Path Cultist
    [126] = 3923, -- Shardborn
    [127] = 3924, -- West Weald Legion
    [128] = 3925, -- Lucent Sentinel
    -- [129] = 0000, -- Hircine Bloodhunter, not listed in Lore Library
  }
  return motifAchieves
end


-- paste missing motif chapters to chat based on currently displayed list of items
function IIfA:FMC(control, controlItemLink, WhoSeesIt)
  --		local i, a
  --		for i,a in pairs(motifAchieves) do
  --			d(i .. " = |H1:achievement:" .. a .. ":16383:1431113493|h|h")
  --		end
  local itemLink = control and control.itemLink or nil
  local identifiedLink = controlItemLink or itemLink

  local motifAchieves = IIfA:GetMotifAchieves()
  if not motifAchieves then return end

  local langChapNames = {}
  langChapNames["EN"] = { "Axes", "Belts", "Boots", "Bows", "Chests", "Daggers", "Gloves", "Helmets", "Legs", "Maces", "Shields", "Shoulders", "Staves", "Swords" }
  langChapNames["DE"] = { "Äxte", "Gürtel", "Stiefel", "Bogen", "Torsi", "Dolche", "Handschuhe", "Helme", "Beine", "Keulen", "Schilde", "Schultern", "Stäbe", "Schwerter" }
  local chapnames = langChapNames[IIfA.clientLanguage] or langChapNames["EN"]

  if not IIfA:isItemLink(identifiedLink) then
    IIfA:dm("Debug", "[IIfA:FMC] Invalid item. Right-Click ignored.")
    return
  end

  local isMotif, motifNum = IIfA:IsItemMotif(identifiedLink)
  if not isMotif then
    IIfA:dm("Debug", "[IIfA:FMC] <<1>>, is not a valid motif chapter", identifiedLink)
    return
  end

  --	local chapnames = {}, idx, chapType
  --	for idx, chapType in pairs(styleChaptersLookup) do
  --		chapnames[idx - 1] = GetString("SI_ITEMSTYLECHAPTER", chapType)
  --	end

  local chapVal
  chapVal = 0
  for idx, data in pairs(IIFA_GUI_ListHolder.dataLines) do
    for i, val in pairs(chapnames) do
      if chapnames[i] ~= nil then
        if zo_plainstrfind(data.name, val) and zo_plainstrfind(data.name, tostring(motifNum)) then
          chapnames[i] = nil
          chapVal = chapVal + (2 ^ (i - 1))
        end
      end
    end
  end

  local s = IIfA.EMPTY_STRING
  for i, val in pairs(chapnames) do
    if val ~= nil then
      if s == IIfA.EMPTY_STRING then
        s = val
      else
        s = string.format("%s, %s", s, val)
      end
    end
  end

  if s == IIfA.EMPTY_STRING then
    d("No motif chapters missing")
  else
    -- incomplete motif achieve
    -- |H1:achievement:1416:0:0|h|h
    local motifStr = string.format("|H1:achievement:%s:%s:0|h|h", motifAchieves[motifNum], chapVal)

    if WhoSeesIt == "Private" then
      d("Missing " .. motifStr .. " chapters: " .. s)
    end

    if WhoSeesIt == "Public" then
      d("Missing motif chapters are in the chat text edit area")
      ZO_ChatWindowTextEntryEditBox:SetText("Looking for " .. motifStr .. " missing chapters: " .. s)
    end

  end
  --d(chapnames)

end

function IIfA:FilterByItemName(control)
  local itemName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(control.itemLink))
  IIfA.searchFilter = checkSearchFilter(itemName)
  IIfA.GUI_SearchBox:SetText(IIfA.searchFilter)
  IIfA.bFilterOnSetName = false
  IIfA:RefreshInventoryScroll()
end

function IIfA:FilterByItemSet(control, setName)
  if not setName and not control then return end
  if not setName and control then
    local isSet, setNameLoc = IIfA:IsItemSet(control.itemLink)
    if isSet then
      setName = setNameLoc
    end
  end
  if setName and setName > IIfA.EMPTY_STRING then
    IIfA.searchFilter = checkSearchFilter(setName)
    -- fill in the GUI portion here
    IIfA.GUI_SearchBox:SetText(IIfA.searchFilter)
    IIfA.bFilterOnSetName = true
    IIfA:RefreshInventoryScroll()
  end
end



--[[
misc musings

--|H1:item:45350:365:50:0:0:0:0:0:0:0:0:0:0:0:0:7:0:0:0:10000:0|h|h

ww writ
ruby ash healing staff, epic, nirnhoned, magnus gift set, glass, 48 writ voucher reward
/script local i for i=1,100 do d(i .. " = " .. GenerateMasterWritBaseText("|H1:item:119681:6:1:0:0:0:" .. i .. ":192:4:48:26:28:0:0:0:0:0:0:0:0:480000|h|h")) end

maple resto staff
|H1:item:43560:30:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h

nobles conquest robe
|H1:item:59965:30:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
|H1:item:60000:30:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h
]]
