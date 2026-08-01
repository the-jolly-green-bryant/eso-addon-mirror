function IIfA:IsCharacterInventoryIgnored()
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  serverData.ignoredCharInventories = serverData.ignoredCharInventories or {}
  return serverData.ignoredCharInventories[IIfA.currentCharacterId] or false
end

function IIfA:IgnoreCharacterInventory(value)
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  serverData.ignoredCharInventories = serverData.ignoredCharInventories or {}
  serverData.ignoredCharInventories[IIfA.currentCharacterId] = value

  IIfA.trackedBags[BAG_BACKPACK] = not value
  IIfA:ScanCurrentCharacter()
  IIfA:RefreshInventoryScroll()
end

function IIfA:IsCharacterEquipIgnored()
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  serverData.ignoredCharEquipment = serverData.ignoredCharEquipment or {}
  return serverData.ignoredCharEquipment[IIfA.currentCharacterId] or false
end

function IIfA:IgnoreCharacterEquip(value)
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  serverData.ignoredCharEquipment = serverData.ignoredCharEquipment or {}
  serverData.ignoredCharEquipment[IIfA.currentCharacterId] = value

  IIfA.trackedBags[BAG_WORN] = not value
  IIfA:ScanCurrentCharacter()
  IIfA:RefreshInventoryScroll()
end

function IIfA:IsCompanionEquipIgnored()
  return not IIFA_DATABASE[IIfA.currentAccount].settings.ignoreCompanionEquipment
end

function IIfA:SetSetNameFilterOnly(value)
  local settings = IIFA_DATABASE[IIfA.currentAccount].settings
  settings.bFilterOnSetName = not settings.bFilterOnSetName
  IIFA_GUI_Search_SetNameOnly:SetState((settings.bFilterOnSetName and BSTATE_PRESSED) or BSTATE_NORMAL)
  IIfA:RefreshInventoryScroll()
end

function IIfA:GetFocusSearchOnToggle()
  return not IIFA_DATABASE[IIfA.currentAccount].settings.dontFocusSearch
end

function IIfA:SetFocusSearchOnToggle(value)
  IIFA_DATABASE[IIfA.currentAccount].settings.dontFocusSearch = not value
end

-- this is for the dropdown menu
function IIfA:GetInventoryListFilter()
  if not IIfA.InventoryListFilter then return GetString(IIFA_LOCATION_NAME_ALL) end
  return IIfA.InventoryListFilter
end

function IIfA:SetInventoryListFilter(value, bagId)
  if not value or value == IIfA.EMPTY_STRING then value = GetString(IIFA_LOCATION_NAME_ALL) end
  IIfA.InventoryListFilter = value
  IIfA.InventoryListFilterBagId = bagId
  --	IIfA.searchFilter = IIfA.GUI_SearchBox:GetText()
  IIfA:RefreshInventoryScroll()
end

-- this is for the dropdown menu
function IIfA:GetInventoryListFilterQuality()
  return IIfA.InventoryListFilterQuality or IIFA_FILTER_MENU_QUALITY_ANY
end

-- this is for the dropdown menu
function IIfA:SetInventoryListFilterQuality(value)
  IIfA.InventoryListFilterQuality = value
  --	IIfA.searchFilter = IIfA.GUI_SearchBox:GetText()
  IIfA:RefreshInventoryScroll()
end

function IIfA:GetCollectingHouseData()
  return IIFA_DATABASE[IIfA.currentAccount].settings.b_collectHouses
end

function IIfA:GetTrackedBags()
  -- Add houses from collectHouseData to IIfA.trackedBags directly
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  local collectHouseData = serverData.collectHouseData

  for houseCollectibleId, trackIt in pairs(collectHouseData) do
    IIfA.trackedBags[houseCollectibleId] = trackIt or nil -- Set to nil if untracked for cleaner table
  end

  return IIfA.trackedBags
end

function IIfA:GetTrackedHousIds()
  local ret = {}
  local collectHouseData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].collectHouseData

  for id, trackIt in pairs(collectHouseData) do
    if trackIt then
      table.insert(ret, id)
    end
  end
  return ret
end

function IIfA:GetIgnoredHouseIds()
  local ret = {}
  local collectHouseData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].collectHouseData

  for id, trackIt in pairs(collectHouseData) do
    if not trackIt then
      table.insert(ret, id)
    end
  end
  return ret
end

function IIfA:GetHouseIdFromName(houseName)
  IIfA:dm("Debug", "[GetHouseIdFromName] houseName: '<<1>>'", houseName)

  if houseName == IIFA_HOUSING_DROPDOWN_EMPTY then
    return nil
  end

  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  return serverData.HouseNameToId[houseName]
end

function IIfA:GetTrackingWithHouseNames()
  local ret = {}
  local collectHouseData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].collectHouseData

  for collectibleId, trackIt in pairs(collectHouseData) do
    local collectibleName = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, GetCollectibleName(collectibleId))
    ret[collectibleName] = true
  end
  return ret
end

function IIfA:RebuildHouseMenuDropdowns()
  local tracked = { IIFA_HOUSING_DROPDOWN_EMPTY }
  local ignored = { IIFA_HOUSING_DROPDOWN_EMPTY }
  local trackedHasDefault = true
  local ignoredHasDefault = true

  -- Access house-related data from the server-specific section of the database
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  local collectHouseData = serverData.collectHouseData

  -- Rebuild house lookups and dropdown data
  for collectibleId, trackIt in pairs(collectHouseData) do
    -- Initialize HouseNameToId and HouseIdToName if not already initialized
    serverData.HouseNameToId = serverData.HouseNameToId or {}
    serverData.HouseIdToName = serverData.HouseIdToName or {}

    local collectibleName = ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, GetCollectibleName(collectibleId))

    -- Update lookup tables
    serverData.HouseNameToId[collectibleName] = collectibleId
    serverData.HouseIdToName[collectibleId] = collectibleName

    -- Determine which dropdown to update
    local targetTable = trackIt and tracked or ignored

    if targetTable == tracked and trackedHasDefault then
      tracked[1] = collectibleName
      trackedHasDefault = false
    elseif targetTable == ignored and ignoredHasDefault then
      ignored[1] = collectibleName
      ignoredHasDefault = false
    else
      table.insert(targetTable, collectibleName)
    end
  end

  -- Update global variables for tracked and ignored house names
  IIfA.houseNamesIgnored = ignored
  IIfA.houseNamesTracked = tracked
end


function IIfA:GetIgnoredHouseNames()
  if IIfA.houseNamesIgnored == nil then
    IIfA:RebuildHouseMenuDropdowns()
  end
  return IIfA.houseNamesIgnored
end

function IIfA:GetTrackedHouseNames()
  if IIfA.houseNamesTracked == nil then
    IIfA:RebuildHouseMenuDropdowns()
  end
  return IIfA.houseNamesTracked
end

function IIfA:GetAllHouseIds()
  local ret = {}
  local collectHouseData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].collectHouseData
  for id, trackIt in pairs(collectHouseData) do
    table.insert(ret, id)
  end
  return ret
end

function IIfA:SetTrackingForHouse(houseCollectibleId, trackIt)
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  local collectHouseData = serverData.collectHouseData

  -- Determine if houseCollectibleId is a name or an ID
  if type(houseCollectibleId) == "string" then
    houseCollectibleId = serverData.HouseNameToId[houseCollectibleId] or 0
  end

  -- If no valid houseCollectibleId is found, exit
  if houseCollectibleId == 0 then
    IIfA:dm("Warn", "[SetTrackingForHouse] Invalid houseCollectibleId!")
    return
  end

  -- Update collectHouseData with the tracking state
  collectHouseData[houseCollectibleId] = trackIt
  IIfA:RebuildHouseMenuDropdowns()

  -- If untracking, clear location data
  if not trackIt then
    IIfA:ClearLocationData(houseCollectibleId)
    IIfA:ClearBagSlotInfoByBagId(houseCollectibleId)
  end
end

function IIfA:GetHouseTracking()
  return IIFA_DATABASE[IIfA.currentAccount].settings.b_collectHouses
end

function IIfA:SetHouseTracking(value)
  IIFA_DATABASE[IIfA.currentAccount].settings.b_collectHouses = value
  if value then
    IIfA:RebuildHouseMenuDropdowns()
  end
end
