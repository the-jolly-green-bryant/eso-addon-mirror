local task = IIfA.task or LibAsync:Create("IIfA_DataCollection")
IIfA.task = task

local function p(...)
  -- Ensure IIfA and its debug function are properly initialized
  if not IIfA or not IIfA.DebugOut then return end

  -- Ensure the conditions for debugging are met
  if not IIFA_DATABASE[IIfA.currentAccount].settings.bDebug then return end

  IIfA:DebugOut(...)
end

local function NonContiguousNonNilCount(tableObject)
  local count = 0

  for i, v in pairs(tableObject) do
    if v ~= nil then count = count + 1 end
  end

  return count
end

local function GetBagName(bagId)
  local bagNames = {
    [BAG_BACKPACK] = "Backpack",
    [BAG_BANK] = "Bank",
    [BAG_BUYBACK] = "Buyback",
    [BAG_COMPANION_WORN] = "Companion Worn",
    [BAG_FURNITURE_VAULT] = "Furniture Vault",
    [BAG_GUILDBANK] = "Guild Bank",
    [BAG_HOUSE_BANK_ONE] = "House Bank One",
    [BAG_HOUSE_BANK_TWO] = "House Bank Two",
    [BAG_HOUSE_BANK_THREE] = "House Bank Three",
    [BAG_HOUSE_BANK_FOUR] = "House Bank Four",
    [BAG_HOUSE_BANK_FIVE] = "House Bank Five",
    [BAG_HOUSE_BANK_SIX] = "House Bank Six",
    [BAG_HOUSE_BANK_SEVEN] = "House Bank Seven",
    [BAG_HOUSE_BANK_EIGHT] = "House Bank Eight",
    [BAG_HOUSE_BANK_NINE] = "House Bank Nine",
    [BAG_HOUSE_BANK_TEN] = "House Bank Ten",
    [BAG_SUBSCRIBER_BANK] = "Subscriber Bank",
    [BAG_VIRTUAL] = "Virtual",
    [BAG_WORN] = "Worn",
  }

  local bagName = bagNames[bagId]
  if bagName then
    return bagName
  elseif bagId > BAG_MAX_VALUE then
    return GetCollectibleName(bagId)
  else
    IIfA:dm("Warn", "[GetBagName] Unknown Bag ID: " .. tostring(bagId))
  end
end

local function ItemHasLocations(databaseItem)
  if not databaseItem or databaseItem.locations == nil then return end
  return NonContiguousNonNilCount(databaseItem.locations) >= 1
end

local function GetItemIdString(itemLink)
  if itemLink then return tostring(GetItemLinkItemId(itemLink)) end
  return
end

local function getDatabaseItemLocation(bagId)
  --[[ Note: when the bagId is actually a houseCollectibleId do not use
  IsOwnerOfCurrentHouse() because this could be for the LAM menu
  where the player is setting the house to be ignored or tracked.

  Handle checking valid ownership in the function collecting the
  contents of the player home, or in the function used to call
  the collector function like CollectBag.]]--
  local houseCollectibleId = GetCollectibleIdForHouse(GetCurrentZoneHouseId())
  if (bagId == BAG_BACKPACK or bagId == BAG_WORN) then
    return IIfA.currentCharacterId
  elseif (bagId == BAG_COMPANION_WORN) and HasActiveCompanion() then
    return IIfA.currentCompanionId
  elseif (bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK) then
    return IIFA_LOCATION_KEY_BANK
  elseif (bagId == BAG_VIRTUAL) then
    return IIFA_LOCATION_KEY_CRAFTBAG
  elseif (bagId == BAG_FURNITURE_VAULT) then
    return IIFA_LOCATION_KEY_FURNITURE_VAULT
  elseif (bagId == BAG_GUILDBANK) then
    return GetGuildName(GetSelectedGuildBankId())
  elseif (bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN) then
    return GetCollectibleForBag(bagId)
  elseif (bagId > BAG_MAX_VALUE) and houseCollectibleId then
    --[[ yes we hope houseCollectibleId is valid and a player home
    but, it should be since housing banks have a bagId less than
    BAG_MAX_VALUE. ]]--
    return houseCollectibleId
  end
end

local function getBagSlotInfoLocation(bagId, location)
  --[[ Using if then statements for troubleshooting discrepancies.

  Note: when the bagId is actually a houseCollectibleId do not use
  IsOwnerOfCurrentHouse() because this could be for the LAM menu
  where the player is setting the house to be ignored or tracked.

  Same goes for HasActiveCompanion() in case you are clering
  the bag from the LAM menu.

  Handle checking valid ownership in the function collecting the
  contents of the player home, or in the function used to call
  the collector function like CollectBag.]]--
  local selectedGuildBankId = GetSelectedGuildBankId()
  local selectedGuildBankName = GetGuildName(selectedGuildBankId)
  local houseCollectibleId = GetCollectibleIdForHouse(GetCurrentZoneHouseId())

  if (bagId == BAG_BACKPACK or bagId == BAG_WORN) then
    return bagId
  elseif (bagId == BAG_COMPANION_WORN) then
    return bagId
  elseif (bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK) then
    return bagId
  elseif (bagId == BAG_VIRTUAL) then
    return bagId
  elseif (bagId == BAG_FURNITURE_VAULT) then
    return bagId
  elseif (bagId == BAG_GUILDBANK) then
    return location or selectedGuildBankName
  elseif (bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN) then
    return bagId
  elseif (bagId > BAG_MAX_VALUE) then
    --[[ yes we hope houseCollectibleId is valid and a player home
    but, it should be since housing banks have a bagId less than
    BAG_MAX_VALUE. ]]--
    return bagId or houseCollectibleId
  end
end

-- try to read item name from bag/slot - if that's empty, we read it from item link
local function getItemName(bagId, slotId, itemLink)
  -- Attempt to get the item name using bagId and slotId if provided
  if bagId and slotId then
    local itemName = GetItemName(bagId, slotId)
    if itemName and itemName ~= "" then
      return ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, itemName)
    end
  end

  -- If bagId and slotId are not valid, try to use the itemLink
  if IIfA:isItemLink(itemLink) then
    local itemName = GetItemLinkName(itemLink)
    if itemName and itemName ~= "" then
      return ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, itemName)
    end
  end

  -- If the itemLink is a collectible link, handle that case
  if IIfA:isCollectibleLink(itemLink) then
    local collectibleId = IIfA:GetCollectibleLinkItemId(itemLink)
    local collectibleName = GetCollectibleName(collectibleId)
    if collectibleName and collectibleName ~= "" then
      return ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, collectibleName)
    end
  end

  -- Return nil if no valid name could be determined
  return nil
end

local function getItemCount(bagId, slotId)
  local itemInfo = { GetItemInfo(bagId, slotId) }
  local itemCount = itemInfo[2] or 0 -- meaning itemCount
  return itemCount
end

function IIfA:GetBagSlotInfo(bagId, slotIndex)
  local hasNoBagInfo = not bagId or not slotIndex
  if hasNoBagInfo then return end

  local locationID = getBagSlotInfoLocation(bagId)
  local hasBagSlotInfo = locationID and slotIndex and IIfA.BagSlotInfo[locationID] ~= nil and IIfA.BagSlotInfo[locationID][slotIndex]

  if hasBagSlotInfo then
    -- IIfA:dm("Debug", "[GetBagSlotInfo] - bagId: <<1>>, slotIndex: <<2>>, locationID: '<<3>>', hasBagSlotInfo: '<<4>>'", bagId, slotIndex, locationID, hasBagSlotInfo)
    return IIfA.BagSlotInfo[locationID][slotIndex]
  end

  return
end

function IIfA:SetBagSlotInfo(bagId, slotIndex, itemKey)
  local hasNoBagInfo = not bagId or not slotIndex
  if hasNoBagInfo then return end

  --[[ locationID is used instead of bagId so that when the locationID
  is 6400, then we are looking at IIfA.BagSlotInfo[6400] for the Hall of Champions. ]]--
  local locationID = getBagSlotInfoLocation(bagId)
  local untrackedBag = locationID and slotIndex and IIfA.BagSlotInfo[locationID] == nil
  local untrackedSlot = locationID and slotIndex and IIfA.BagSlotInfo[locationID] and (IIfA.BagSlotInfo[locationID][slotIndex] == nil)
  local hasBagSlotInfo = IIfA:GetBagSlotInfo(bagId, slotIndex)

  if untrackedBag then
    IIfA.BagSlotInfo[locationID] = {}
    IIfA.BagSlotInfo[locationID][slotIndex] = itemKey
    -- IIfA:dm("Debug", "[SetBagSlotInfo] Untracked Bag - locationID: <<1>>, slotIndex: <<2>>, itemKey: '<<3>>'", locationID, slotIndex, itemKey)
  elseif untrackedSlot then
    IIfA.BagSlotInfo[locationID][slotIndex] = itemKey
    -- IIfA:dm("Debug", "[SetBagSlotInfo] Untracked Slot - locationID: <<1>>, slotIndex: <<2>>, itemKey: '<<3>>'", locationID, slotIndex, itemKey)
  elseif hasBagSlotInfo then
    local storedKey = IIfA.BagSlotInfo[locationID][slotIndex]
    -- Only warn if itemKey differs from what’s already stored, or bagId is NOT a known special-case (like housing)
    if storedKey ~= itemKey then
      IIfA:dm("Warn", "[SetBagSlotInfo] Existing BagSlotInfo! locationID: <<1>>, slotIndex: <<2>>, itemKey: '<<3>>', storedKey: '<<4>>'", locationID, slotIndex, itemKey, storedKey)
    end
  else
    IIfA:dm("Warn", "[SetBagSlotInfo] Condition not covered - locationID: <<1>>, slotIndex: <<2>>, itemKey: '<<3>>'", locationID, slotIndex, itemKey)
  end
end

function IIfA:ClearBagSlotInfo(bagId, slotIndex)
  local hasNoBagInfo = not bagId or not slotIndex
  if hasNoBagInfo then return end
  if bagId == BAG_COMPANION_WORN and not HasActiveCompanion() then return end

  --[[ locationID is used instead of bagId so that when the locationID
  is 6400, then we are looking at IIfA.BagSlotInfo[6400] for the Hall of Champions. ]]--
  local locationID = getBagSlotInfoLocation(bagId)

  IIfA.BagSlotInfo[locationID] = IIfA.BagSlotInfo[locationID] or {}
  IIfA.BagSlotInfo[locationID][slotIndex] = nil
  IIfA:dm("Debug", "[ClearBagSlotInfo] Cleared BagSlotInfo - locationID: <<1>>, bagId: <<2>>, slotIndex: <<3>>", locationID, bagId, slotIndex)
end

--[[ Only specify location for a specific guild bank from the LAM menu. ]]--
function IIfA:ClearBagSlotInfoByBagId(bagId, location)
  local hasNoBagId = not bagId
  if hasNoBagId then return end

  --[[ locationID is used instead of bagId so that when the locationID
  is 6400, then we are looking at IIfA.BagSlotInfo[6400] for the Hall of Champions. ]]--
  local locationID = (location ~= nil) and location or getBagSlotInfoLocation(bagId)
  if not locationID then
    IIfA:dm("Debug", "[ClearBagSlotInfoByBagId] Skipping - locationID could not be determined for bagId: <<1>>, name: <<2>>", bagId, GetBagName(bagId))
    return
  end

  -- Ensure the BagSlotInfo for the locationID is initialized to prevent nil index errors.
  IIfA.BagSlotInfo = IIfA.BagSlotInfo or {}

  -- Clear the specific slotIndex.
  if IIfA.BagSlotInfo and IIfA.BagSlotInfo[locationID] then
    IIfA.BagSlotInfo[locationID] = nil
    IIfA:dm("Debug", "[ClearBagSlotInfoByBagId] Cleared BagSlotInfo - locationID: <<1>>, bagId: <<2>>, name: <<3>>", location, bagId, GetBagName(bagId))
  else
    IIfA:dm("Debug", "[ClearBagSlotInfoByBagId] Unable to clear BagSlotInfo because locationID was nil or invalid. locationID: <<1>>, bagId: <<2>>, name: <<3>>", location, bagId, GetBagName(bagId))
  end
end

function IIfA:SetFurnitureSlotInfo(houseCollectibleId, itemId, furnitureItemLink)
  --[[ The bagId is actually the houseCollectibleId, and the slotIndex
  is actually the itemId. The furnitureItemLink is from the
  getAllPlacedFurniture table created within RescanHouse ]]--

  --=== [1] Input Validation ===--
  local hasNoBagInfo = not houseCollectibleId or not itemId
  if hasNoBagInfo then return end

  local isValidLinkType = IIfA:isItemLink(furnitureItemLink) or IIfA:isCollectibleLink(furnitureItemLink)
  if not isValidLinkType then
    IIfA:dm("Warn", "[SetFurnitureSlotInfo] Invalid furnitureItemLink: '<<1>>', houseCollectibleId: '<<2>>', itemId: '<<3>>'", furnitureItemLink, houseCollectibleId, itemId)
    return
  end

  --=== [2] Resolve Item Key ===--
  local itemKey
  if IIfA:isItemLink(furnitureItemLink) then
    itemKey = IIfA:GetItemKey(furnitureItemLink)
  elseif IIfA:isCollectibleLink(furnitureItemLink) then
    itemKey = furnitureItemLink
  end

  if not itemKey then
    IIfA:dm("Warn", "[SetFurnitureSlotInfo] Could not resolve itemKey for furnitureItemLink: '<<1>>'", furnitureItemLink)
    return
  end

  --=== [3] Determine Location and BagSlotInfo State ===--
  local locationID = getBagSlotInfoLocation(houseCollectibleId)
  local untrackedBag = locationID and itemId and IIfA.BagSlotInfo[locationID] == nil
  local untrackedSlot = locationID and itemId and IIfA.BagSlotInfo[locationID] and (IIfA.BagSlotInfo[locationID][itemId] == nil)
  local hasBagSlotInfo = locationID and itemId and IIfA.BagSlotInfo[locationID] ~= nil and IIfA.BagSlotInfo[locationID][itemId]

  --=== [4] Assign ItemKey in BagSlotInfo ===--
  if untrackedBag then
    IIfA.BagSlotInfo[locationID] = {}
    IIfA.BagSlotInfo[locationID][itemId] = itemKey
    IIfA:dm("Debug", "[SetFurnitureSlotInfo] Untracked Bag - locationID: <<1>>, itemId: <<2>>, furnitureItemLink: '<<3>>', itemKey: '<<4>>'", locationID, itemId, furnitureItemLink, itemKey)
  elseif untrackedSlot then
    IIfA.BagSlotInfo[locationID][itemId] = itemKey
    IIfA:dm("Debug", "[SetFurnitureSlotInfo] Untracked Slot - locationID: <<1>>, itemId: <<2>>, furnitureItemLink: '<<3>>', itemKey: '<<4>>'", locationID, itemId, furnitureItemLink, itemKey)
  elseif hasBagSlotInfo then
    IIfA:dm("Warn", "[SetFurnitureSlotInfo] Existing Slot - locationID: <<1>>, itemId: <<2>>, furnitureItemLink: '<<3>>', itemKey: '<<4>>', storedKey: '<<5>>'", locationID, itemId, furnitureItemLink, itemKey, IIfA.BagSlotInfo[locationID][itemId])
  else
    IIfA:dm("Warn", "[SetFurnitureSlotInfo] Condition not covered - locationID: <<1>>, itemId: <<2>>, furnitureItemLink: '<<3>>', itemKey: '<<4>>'", locationID, itemId, furnitureItemLink, itemKey)
  end
end

local function IsCollectibleIdPlayerHouse(houseCollectibleId)
  if not houseCollectibleId then IIfA:dm("Warn", "[IsCollectibleIdPlayerHouse] houseCollectibleId was nil, will obtain from API") end
  houseCollectibleId = houseCollectibleId or GetCollectibleIdForHouse(GetCurrentZoneHouseId())
  return houseCollectibleId > BAG_MAX_VALUE and GetCollectibleIdForHouse(GetCurrentZoneHouseId()) > 0
end

-- House Bank chests are only available in owned player homes
local function IsHouseBankUnavailable(bagId)
  return bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN
    and (GetCollectibleForBag(bagId) <= 0 or not IsOwnerOfCurrentHouse())
end

-- Furniture Vault requires being in your own home and having unlocked it
local function IsFurnitureVaultUnavailable(bagId)
  return bagId == BAG_FURNITURE_VAULT
    and (not IsOwnerOfCurrentHouse() or not HOUSING_EDITOR_STATE:HasUnlockedFurnitureVault())
end

-- Companion gear is not available unless companion is summoned
local function IsCompanionBagUnavailable(bagId)
  return bagId == BAG_COMPANION_WORN and (not HasActiveCompanion() or IIfA.currentCompanionId == nil)
end

-- Bank and subscriber bank must be open to be scanned
local function IsBankUnavailable(bagId)
  return (bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK) and not IsBankOpen()
end

-- Same as above, but includes virtual bag for GetBagContents (since it uses special handling)
local function IsBagUnsupportedForGetBagContents(bagId)
  return bagId == BAG_GUILDBANK or bagId == BAG_VIRTUAL or bagId > BAG_MAX_VALUE
end

--[[Regardless of previous versions coding, this method is simply not
supported for the Guild Bank, Craft Bag, or any player home. ]]--
local function GetBagContents(bagId, b_useAsync)
  local shouldSkipBagScan = IsFurnitureVaultUnavailable(bagId) or IsHouseBankUnavailable(bagId) or IsCompanionBagUnavailable(bagId) or IsBagUnsupportedForGetBagContents(bagId) or IsBankUnavailable(bagId)
  if shouldSkipBagScan then
    IIfA:dm("Debug", "[GetBagContents] IsFurnitureVaultUnavailable: <<1>>", tostring(IsFurnitureVaultUnavailable(bagId)))
    IIfA:dm("Debug", "[GetBagContents] IsHouseBankUnavailable: <<1>>", tostring(IsHouseBankUnavailable(bagId)))
    IIfA:dm("Debug", "[GetBagContents] IsCompanionBagUnavailable: <<1>>", tostring(IsCompanionBagUnavailable(bagId)))
    IIfA:dm("Debug", "[GetBagContents] IsBagUnsupportedForGetBagContents: <<1>>", tostring(IsBagUnsupportedForGetBagContents(bagId)))
    IIfA:dm("Debug", "[GetBagContents] IsBankUnavailable: <<1>>", tostring(IsBankUnavailable(bagId)))
    IIfA:dm("Debug", "[GetBagContents] Skipped bagId: <<1>>, name: <<2>>, useAsync: <<3>>", bagId, GetBagName(bagId), tostring(b_useAsync))
    return
  end

  IIfA:dm("Debug", "[GetBagContents] Collecting bag contents for bagId: <<1>>, name: <<2>>, useAsync: <<3>>", bagId, GetBagName(bagId), tostring(b_useAsync))

  local bagItems = GetBagSize(bagId)

  -- Note: most bags are 0-based, but BAG_FURNITURE_VAULT uses 1-based indexing
  -- so the loop must be adjusted accordingly to scan correct slot indices.
  local startIndex = (bagId == BAG_FURNITURE_VAULT) and 1 or 0
  local endIndex = bagItems - 1 + startIndex

  if b_useAsync then
    task:For(startIndex, endIndex):Do(function(slotIndex)
      IIfA:EvalBagItem(bagId, slotIndex)
    end)
  else
    for slotIndex = startIndex, endIndex do
      IIfA:EvalBagItem(bagId, slotIndex)
    end
  end
end

local function GetVirtualBagContents(b_useAsync)
  IIfA:dm("Debug", "[GetVirtualBagContents] Collecting Virtual Bag contents, useAsync: <<1>>", tostring(b_useAsync))
  local slotId = GetNextVirtualBagSlotId(nil)
  if b_useAsync then
    task:While(function()
      return slotId ~= nil
    end):Do(function()
      IIfA:EvalBagItem(BAG_VIRTUAL, slotId)
      slotId = GetNextVirtualBagSlotId(slotId)
    end)
  else
    while slotId ~= nil do
      IIfA:EvalBagItem(BAG_VIRTUAL, slotId)
      slotId = GetNextVirtualBagSlotId(slotId)
    end
  end
end

function IIfA:DeleteCharacterData(characterToDelete)
  if characterToDelete then
    -- Access the current account and server data
    local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
    local charNameToId = serverData.CharNameToId
    local charIdToName = serverData.CharIdToName

    -- Delete the selected character's data
    for characterName, charId in pairs(charNameToId) do
      if characterName == characterToDelete then
        -- Remove the character from the lookup tables
        charNameToId[characterToDelete] = nil
        charIdToName[charId] = nil
        IIfA:ClearUnowned()
      end
    end
  end
end

function IIfA:DeleteGuildData(selectedGuildBankToDelete)
  if selectedGuildBankToDelete then
    -- Access server-specific guild bank info
    local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
    serverData.guildBankInfo = serverData.guildBankInfo or {}

    -- Check if the guild exists in guildBankInfo
    if serverData.guildBankInfo[selectedGuildBankToDelete] then
      p("Deleting Guild Bank data for <<1>>", selectedGuildBankToDelete)

      -- Set bCollectData to false
      serverData.guildBankInfo[selectedGuildBankToDelete].bCollectData = false

      -- Clear location and bag slot info
      IIfA:ClearLocationData(BAG_GUILDBANK, selectedGuildBankToDelete)
      IIfA:ClearBagSlotInfoByBagId(BAG_GUILDBANK, selectedGuildBankToDelete)
    end
  end
end

function IIfA:CollectGuildBank()
  IIfA:UpdateGuildBankLookup()

  local selectedGuildBankId = GetSelectedGuildBankId()
  local selectedGuildBankName = GetGuildName(selectedGuildBankId)
  if #selectedGuildBankName == 0 or selectedGuildBankName == IIfA.EMPTY_STRING then return end

  -- Access server-specific guild bank info
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]

  -- Check if the user wants to track this guild's data first
  local guildData = serverData.guildBankInfo[selectedGuildBankName]
  if not serverData.bCollectGuildBankData or not guildData.bCollectData then
    return
  end

  -- Add Roomba support
  if Roomba and Roomba.WorkInProgress and Roomba.WorkInProgress() then
    CALLBACK_MANAGER:FireCallbacks("Roomba-EndStacking", function() IIfA:CollectGuildBank() end)
    return
  end

  local guildBankOpen = IsGuildBankOpen()
  if not guildBankOpen then
    IIfA:dm("Debug", "[CollectGuildBank] Guild Bank '<<1>>' is not available, exiting early", selectedGuildBankName)
    return
  end

  IIfA:dm("Debug", "[CollectGuildBank] Collecting Guild Bank Data for " .. selectedGuildBankName)

  task:Call(function()
    IIfA:ClearLocationData(BAG_GUILDBANK, selectedGuildBankName)
    IIfA:ClearBagSlotInfoByBagId(BAG_GUILDBANK, selectedGuildBankName)
  end):Then(function()
    local itemsInGuildBank = 0
    local slotIndex = ZO_GetNextBagSlotIndex(BAG_GUILDBANK, nil)
    task:While(function()
      return slotIndex ~= nil
    end):Do(function()
      itemsInGuildBank = itemsInGuildBank + 1
      local itemLink = GetItemLink(BAG_GUILDBANK, slotIndex, LINK_STYLE_BRACKETS)
      IIfA:EvalBagItem(BAG_GUILDBANK, slotIndex)
      slotIndex = ZO_GetNextBagSlotIndex(BAG_GUILDBANK, slotIndex)
    end):Then(function()
      guildData.items = itemsInGuildBank
      IIfA:dm("Debug", "[CollectGuildBank] Guild Bank Collected - <<1>>, itemCount: <<2>>", selectedGuildBankName, itemsInGuildBank)
    end)
  end)
end

function IIfA:ScanCurrentCharacter()
  IIfA:dm("Debug", "[ScanCurrentCharacter] Starting...")

  task:Call(function()
    --[[ It is safe to use ClearBagSlotInfoByBagId() with the
     BAG_BACKPACK because BagSlotInfo uses two separate locations
     for BAG_WORN and BAG_BACKPACK.

     Do not use ClearLocationData() with BAG_BACKPACK ]]--
    --[[ After we clear BAG_WORN or BAG_BACKPACK both bags have
    been cleared, so we have to scan both again. ]]--
    IIfA:ClearLocationData(BAG_WORN)
  end)

  if not IIfA:IsCharacterEquipIgnored() then
    -- First task: GetBagContents(BAG_WORN)
    task:Call(function()
      IIfA:ClearBagSlotInfoByBagId(BAG_WORN)
      GetBagContents(BAG_WORN, true)
    end)
  end

  if not IIfA:IsCharacterInventoryIgnored() then
    -- Second task: GetBagContents(BAG_BACKPACK)
    task:Call(function()
      --[[ It is safe to use ClearBagSlotInfoByBagId() with the
       BAG_BACKPACK because BagSlotInfo uses two separate locations
       for BAG_WORN and BAG_BACKPACK.

       Do not use ClearLocationData() with BAG_BACKPACK ]]--
      IIfA:ClearBagSlotInfoByBagId(BAG_BACKPACK)
      GetBagContents(BAG_BACKPACK, true)
    end)
  end

  task:Call(function()
    IIfA:MakeBSI()
  end)
end

function IIfA:ScanBackpackAndCraftBag()
  IIfA:dm("Debug", "[ScanBackpackAndCraftBag] Starting...")

  task:Call(function()
    --[[ It is safe to use ClearBagSlotInfoByBagId() with the
     BAG_BACKPACK because BagSlotInfo uses two separate locations
     for BAG_WORN and BAG_BACKPACK.

     Do not use ClearLocationData() with BAG_BACKPACK ]]--
    --[[ After we clear BAG_WORN or BAG_BACKPACK both bags have
    been cleared, so we have to scan both again. ]]--
    IIfA:ClearLocationData(BAG_WORN)
  end)

  if not IIfA:IsCharacterEquipIgnored() then
    -- First task: GetBagContents(BAG_WORN)
    task:Call(function()
      IIfA:ClearBagSlotInfoByBagId(BAG_WORN)
      GetBagContents(BAG_WORN, true)
    end)
  end

  if not IIfA:IsCharacterInventoryIgnored() then
    -- Second task: GetBagContents(BAG_BACKPACK)
    task:Call(function()
      --[[ It is safe to use ClearBagSlotInfoByBagId() with the
       BAG_BACKPACK because BagSlotInfo uses two separate locations
       for BAG_WORN and BAG_BACKPACK.

       Do not use ClearLocationData() with BAG_BACKPACK ]]--
      IIfA:ClearBagSlotInfoByBagId(BAG_BACKPACK)
      GetBagContents(BAG_BACKPACK, true)
    end)
  end

  task:Then(function()
    IIfA:ClearLocationData(BAG_VIRTUAL)
    IIfA:ClearBagSlotInfoByBagId(BAG_VIRTUAL)
    GetVirtualBagContents(false)
  end)

  task:Then(function()
    IIfA:MakeBSI()
  end)
end

--[[
Developer note: In ScanHouseBanks, the call to IIfA:ClearLocationData will fail because collectibleId is zero
bagId on the other hand DOES work, possibly because it's in use by the for loop
]]--

local function ScanHouseBanks()
  if not IsOwnerOfCurrentHouse() then
    IIfA:dm("Debug", "[ScanHouseBanks] Skipped, not in a house...")
    return
  else
    IIfA:dm("Debug", "[ScanHouseBanks] Starting...")
  end

  task:For(BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN):Do(function(bagId)
    local collectibleId = GetCollectibleForBag(bagId)
    if IsCollectibleUnlocked(collectibleId) then
      IIfA:dm("Debug", "Scanning House Bank (<<1>>)", collectibleId)
      IIfA:ClearLocationData(bagId)
      IIfA:ClearBagSlotInfoByBagId(bagId)
      GetBagContents(bagId)
    end
  end):Then(function()
    local collectibleId = GetFurnitureVaultCollectibleId()
    if HOUSING_EDITOR_STATE:HasUnlockedFurnitureVault() then
      IIfA:dm("Debug", "Scanning Furniture Vault (<<1>>)", collectibleId)
      IIfA:ClearLocationData(BAG_FURNITURE_VAULT)
      IIfA:ClearBagSlotInfoByBagId(BAG_FURNITURE_VAULT)
      GetBagContents(BAG_FURNITURE_VAULT)
    end
  end):Then(function()
    IIfA:dm("Debug", "Completed scanning all house banks")
  end)
end

function IIfA:ScanBank()
  IIfA:dm("Debug", "[ScanBank] Scanning BAG_BANK, BAG_SUBSCRIBER_BANK, BAG_VIRTUAL, ScanHouseBanks")
  -- Start the task for scanning the player's bank and other related data
  task:Call(function()
    -- Retrieve the bank contents
    IIfA:ClearLocationData(BAG_BANK)
    IIfA:ClearBagSlotInfoByBagId(BAG_BANK)
    GetBagContents(BAG_BANK, true)
  end):Then(function()
    --[[ It is safe to use ClearBagSlotInfoByBagId() with the
     BAG_SUBSCRIBER_BANK because BagSlotInfo uses two separate locations
     for BAG_BANK and BAG_SUBSCRIBER_BANK.

     Do not use ClearLocationData() with BAG_SUBSCRIBER_BANK ]]--
    -- Next, handle the subscriber bank after the main bank is done
    IIfA:ClearBagSlotInfoByBagId(BAG_SUBSCRIBER_BANK)
    GetBagContents(BAG_SUBSCRIBER_BANK, true)
  end):Then(function()
    -- After processing the bank, handle the craft bag (virtual bag)
    IIfA:ClearLocationData(BAG_VIRTUAL)
    IIfA:ClearBagSlotInfoByBagId(BAG_VIRTUAL)
    GetVirtualBagContents(true)
  end):Then(function()
    -- Finally, attempt to scan the house bank after everything else is done
    ScanHouseBanks()
  end)
end

-- only grabs the content of bagpack and worn on the first login - hence we set the function to insta-return below.
function IIfA:OnFirstInventoryOpen()
  IIfA:dm("Debug", "[OnFirstInventoryOpen] Starting...")
  if IIfA.BagsScanned then return end
  IIfA.BagsScanned = true

  -- do not async this, each scan function does that itself
  IIfA:ScanBank()
  IIfA:ScanCurrentCharacter()
end

function IIfA:UpdateGuildBankLookup()
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  serverData.guildBankInfo = serverData.guildBankInfo or {}
  -- IIfA:dm("Debug", serverData.guildBankInfo)

  for index = 1, GetNumGuilds() do
    local guildId = GetGuildId(index)
    local guildName = GetGuildName(guildId)
    if not serverData.guildBankInfo[guildName] then
      serverData.guildBankInfo[guildName] = {
        bCollectData = false,
        items = 0,
      }
    end
  end
  -- IIfA:dm("Debug", serverData.guildBankInfo)
end

function IIfA:GuildBankReady()
  -- call with libAsync to avoid lag
  task:Call(function()
    p("GuildBankReady...")
    IIfA.isGuildBankReady = false
    IIfA:CollectGuildBank()
  end)
end

function IIfA:GuildBankDelayReady()
  p("GuildBankDelayReady...")
  if not IIfA.isGuildBankReady then
    IIfA.isGuildBankReady = true
    IIfA:GuildBankReady()
  end
end

function IIfA:GuildBankAddRemove(eventCode, slotId, addedByLocalPlayer, itemSoundCategory, isLastUpdateForMessage)
  IIfA:dm("Debug", "Guild Bank Add or Remove...")

  -- Access bCollectGuildBankData from IIFA_DATABASE
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  if not serverData.bCollectGuildBankData then return end

  -- Call with libAsync to avoid lag
  task:Call(function()
    IIfA:UpdateGuildBankLookup()
    local guildName = GetGuildName(GetSelectedGuildBankId())
    local itemLink, itemKey, itemLinkFromBag, itemCount = IIfA:GetBagItemDetails(BAG_GUILDBANK, slotId)
    if guildName and eventCode == EVENT_GUILD_BANK_ITEM_ADDED then
      IIfA:dm("Debug", "[GuildBankAddRemove] Added: '<<1>>', '<<2>>', slot: <<3>>", itemLink, guildName, slotId)
      IIfA:EvalBagItem(BAG_GUILDBANK, slotId)
    elseif guildName and eventCode == EVENT_GUILD_BANK_ITEM_REMOVED then
      IIfA:dm("Debug", "[GuildBankAddRemove] Removed: '<<1>>', '<<2>>', slot: <<3>>", itemLink, guildName, slotId)
      IIfA:EvalBagItem(BAG_GUILDBANK, slotId)
    end
  end)
end

function IIfA:RescanHouse(houseCollectibleId)
  IIfA:dm("Debug", "[RescanHouse] Starting...")
  if not houseCollectibleId then IIfA:dm("Warn", "[RescanHouse] houseCollectibleId was nil, will obtain from API") end

  houseCollectibleId = houseCollectibleId or GetCollectibleIdForHouse(GetCurrentZoneHouseId())
  if not houseCollectibleId or not IIfA.trackedBags[houseCollectibleId] then
    IIfA:dm("Warn", "[RescanHouse] houseCollectibleId not obtained!")
    return
  end
  local collectibleName = GetCollectibleName(houseCollectibleId)
  if not IsCollectibleIdPlayerHouse(houseCollectibleId) then
    IIfA:dm("Warn", "[RescanHouse] Rescan Aborted, not in a player home.")
    return
  end
  IIfA:dm("Debug", "[RescanHouse] houseCollectibleId: <<1>>, for <<2>>", houseCollectibleId, collectibleName)

  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]

  -- Update HouseNameToId and HouseIdToName
  serverData.HouseNameToId[collectibleName] = houseCollectibleId
  serverData.HouseIdToName[houseCollectibleId] = collectibleName

  -- Only set collectHouseData[houseCollectibleId] if it's not already set
  if serverData.collectHouseData[houseCollectibleId] == nil then
    serverData.collectHouseData[houseCollectibleId] = IIfA:GetHouseTracking()
  end

  local isTrackedBagValid = IIfA.trackedBags and IIfA.trackedBags[houseCollectibleId]
  if isTrackedBagValid then
    IIfA:dm("Debug", "[RescanHouse] trackedBags for the current house: <<1>>", tostring(IIfA.trackedBags[houseCollectibleId]))
  else
    IIfA:dm("Warn", "[RescanHouse] trackedBags invalid!")
  end

  if not serverData.collectHouseData[houseCollectibleId] then
    if IIfA:GetHouseTracking() and IIfA:GetIgnoredHouseIds()[houseCollectibleId] then
      IIfA.trackedBags[houseCollectibleId] = false
      return
    end
    IIfA.trackedBags[houseCollectibleId] = true
  end
  IIfA:dm("Debug", "[RescanHouse] Rescanning player home: id: <<1>>, name '<<2>>'", houseCollectibleId, GetCollectibleName(houseCollectibleId))

  -- call with libAsync to avoid lag
  task:Call(function()
    -- clear and re-create, faster than conditionally updating
    IIfA:ClearLocationData(houseCollectibleId)
    IIfA:ClearBagSlotInfoByBagId(houseCollectibleId)

  end):Then(function()
    local furnitureData = {}
    local furnitureId = GetNextPlacedHousingFurnitureId(nil)

    local counter = 0
    local identifiedItemId = nil
    local identifiedLink = nil
    local identifiedName = nil
    task:While(function()
      return furnitureId ~= nil and counter < 10000
    end):Do(function()
      if furnitureId then
        -- These placeholders will indicate the Identified placed furniture or collectible
        identifiedLink = nil
        identifiedItemId = nil

        local itemLink = GetPlacedFurnitureLink(furnitureId, LINK_STYLE_BRACKETS)
        local itemId = GetItemLinkItemId(itemLink)
        local collectibleId = GetCollectibleIdFromFurnitureId(furnitureId)
        local collectibleLink = GetCollectibleLink(collectibleId, LINK_STYLE_BRACKETS)

        if IIfA:isItemLink(itemLink) then
          identifiedLink = itemLink
          identifiedItemId = itemId
        elseif IIfA:isCollectibleLink(collectibleLink) then
          identifiedLink = collectibleLink
          identifiedItemId = collectibleId
        end

        if identifiedLink then
          furnitureData[identifiedLink] = furnitureData[identifiedLink] or { count = 0, itemId = identifiedItemId }
          furnitureData[identifiedLink].count = furnitureData[identifiedLink].count + 1
        end

        counter = counter + 1
        furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
      end
    end):Then(function()
      IIfA:dm("Debug", "[RescanHouse] Starting For Loop...")
      task:For(pairs(furnitureData)):Do(function(itemLink, itemData)
        local itemId = itemData.itemId
        local itemCount = itemData.count

        if IIfA:isItemLink(itemLink) then
          identifiedName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
        elseif IIfA:isCollectibleLink(itemLink) then
          identifiedName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetCollectibleName(itemId))
        end

        IIfA:EvalFurnitureItem(houseCollectibleId, itemId, itemLink, itemCount, identifiedName)
      end)
    end):Then(function()
      IIfA:dm("Debug", "[RescanHouse] Furniture loop completed...")
    end)
  end)
end

--[[
Data collection notes:
	Currently crafting items are coming back from getitemlink with level info in them.
	If it's a crafting item, strip the level info and store only the item number as the itemKey
	Use function GetItemCraftingInfo, if usedInCraftingType indicates it's NOT a material, check for other item types

	When showing items in tooltips, check for both stolen & owned, show both
--]]

--[[ GetItemKey() returns the item's db key, we only save under the item link
if we need to save level information etc, else we use the itemId.

isCollectibleLink it not used here because we use the entire collectible link to
ensure the we check for the correct link type.
]]--
function IIfA:GetItemKey(itemLink)
  -- Return an empty string immediately if itemLink is nil or an empty string
  local isValidLinkType = IIfA:isItemLink(itemLink)
  if not isValidLinkType then
    return IIfA.EMPTY_STRING
  end

  if CanItemLinkBeVirtual(itemLink) then
    -- Anything that goes in the craft bag - must be a crafting material
    return GetItemIdString(itemLink)
  else
    -- Other oddball items that might have level info in them
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    if (itemType == ITEMTYPE_TOOL and specializedItemType == SPECIALIZED_ITEMTYPE_TOOL) or
      (itemType == ITEMTYPE_CONTAINER and specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER) or -- 4-6-19 AM - runeboxes appear to have level info in them
      itemType == ITEMTYPE_LOCKPICK and specializedItemType == SPECIALIZED_ITEMTYPE_LOCKPICK or -- 11-19-24 Sharlikran - added because Lockpicks are no longer Tools
      itemType == ITEMTYPE_SOUL_GEM and specializedItemType == SPECIALIZED_ITEMTYPE_SOUL_GEM or -- 11-19-24 Sharlikran - added because soul gems have level info
      itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or -- 9-12-16 AM - added because motifs now appear to have level info in them
      itemType == ITEMTYPE_TROPHY or -- 11-19-24 Sharlikran - added because trophies can have level info
      --[[ 12-15-24 Sharlikran - added because tabards have the guild ID as part of the itemLink
      which causes there to be multiple copies. You cannot use the guild ID from the itemLink
      to look up the guild name if you are not a member of the guild.
      ]]--
      itemType == ITEMTYPE_TABARD or
      itemType == ITEMTYPE_RECIPE then
      return GetItemIdString(itemLink)
    end
  end

  return itemLink
end

--@Baertram:
-- Added for other addons like FCOItemSaver to get the item instance or the unique ID
-->Returns itemInstance or uniqueId as 1st return value
-->Returns a boolean value as 2nd retun value: true if the bagId should build an itemInstance or unique ID / false if not
local function getItemInstanceOrUniqueId(bagId, slotIndex, itemLink)
  local itemInstanceOrUniqueId = 0
  local isBagToBuildItemInstanceOrUniqueId = false
  if FCOIS == nil or FCOIS.getItemInstanceOrUniqueId == nil then return 0, false end
  --Call function within addon FCOItemSaver, file FCOIS_OtherAddons.lua -> IIfA section
  itemInstanceOrUniqueId, isBagToBuildItemInstanceOrUniqueId = FCOIS.getItemInstanceOrUniqueId(bagId, slotIndex, itemLink)
  return itemInstanceOrUniqueId, isBagToBuildItemInstanceOrUniqueId
end

function IIfA:GetBagItemDetails(bagId, slotIndex)
  IIfA:dm("Debug", "GetBagItemDetails")
  local hasNoBagInfo = not bagId or not slotIndex
  local hasNoActiveCompanion = bagId == BAG_COMPANION_WORN and not HasActiveCompanion()
  if hasNoBagInfo or hasNoActiveCompanion then return end

  -- Attempt to get the itemLink from the bag and slot
  local itemLinkFromBag = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
  local itemLink, itemKey = itemLinkFromBag, nil

  -- Fetch item count from the bag and slot
  local itemInfo = { GetItemInfo(bagId, slotIndex) }
  local itemCount = itemInfo[2] or 0 -- meaning itemCount
  IIfA:dm("Debug", "[GetBagItemDetails] - itemCount: '<<1>>'", itemCount)
  IIfA:dm("Debug", "[GetBagItemDetails] - itemCount From Function: '<<1>>'", GetItemTotalCount(bagId, slotIndex))

  -- Determine the itemKey based on the itemLink
  itemKey = IIfA:GetItemKey(itemLinkFromBag)
  -- "[GetBagItemDetails] - [First] itemLinkFromBag: '<<1>>', itemKey: '<<2>>', itemCount: <<3>>", itemLinkFromBag, itemKey, itemCount)

  -- Check if bag slot info exists and update itemKey if necessary
  local hasBagSlotInfo = bagId and slotIndex and IIfA.BagSlotInfo[bagId] ~= nil and IIfA.BagSlotInfo[bagId][slotIndex]
  if #itemKey == 0 and hasBagSlotInfo then
    itemKey = IIfA.BagSlotInfo[bagId][slotIndex]
  end
  -- IIfA:dm("Debug", "[GetBagItemDetails] - [Second] itemLinkFromBag: '<<1>>', itemKey: '<<2>>'", itemLinkFromBag, itemKey)

  -- Check if the database has an itemLink for the itemKey and update itemLink
  local DBv3 = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3 -- Adjusted to reference DBv3
  local hasDatabaseItemLink = IIfA:isItemKey(itemKey) and DBv3[itemKey] and DBv3[itemKey].itemLink
  if #itemLinkFromBag == 0 and hasDatabaseItemLink then
    itemLink = DBv3[itemKey].itemLink
  end
  -- IIfA:dm("Debug", "[GetBagItemDetails] - [Third] itemLink: '<<1>>', itemKey: '<<2>>', itemLinkFromBag: '<<3>>'", itemLink, itemKey, itemLinkFromBag)

  -- Fall back to using itemKey as itemLink if it qualifies
  if itemLink ~= nil and #itemLink == 0 and IIfA:isItemLink(itemKey) then
    itemLink = itemKey
  end

  -- Final debug output before returning results
  -- IIfA:dm("Debug", "[GetBagItemDetails] - [Final] itemLink: '<<1>>', itemKey: '<<2>>', itemLinkFromBag: '<<3>>', itemCount: <<4>>", itemLink, itemKey, itemLinkFromBag, itemCount)

  -- Return all computed values
  return itemLink, itemKey, itemLinkFromBag, itemCount
end

local function cleanupItemLocation(DBitem, location, bagId, slotId)
  if not DBitem or not DBitem.locations then
    return DBitem
  end

  local locationData = DBitem.locations[location]
  if locationData and locationData.bagSlot then
    -- Remove the slot from this location
    locationData.bagSlot[slotId] = nil

    -- If the bagSlot table is now empty, remove the location entirely
    if next(locationData.bagSlot) == nil then
      DBitem.locations[location] = nil
    end
  end

  -- Clear associated reverse lookup
  IIfA:ClearBagSlotInfo(bagId, slotId)

  return DBitem
end

local function handleStaleDataCleanup(DBv3, storedKey, location, bagId, slotId, itemLinkSlotInfo)
  --=== [1] Cleanup Phase ===--
  local oldItemData = DBv3[storedKey] or {}
  local updatedData = cleanupItemLocation(oldItemData, location, bagId, slotId)
  DBv3[storedKey] = updatedData

  --=== [2] Data Collection Phase ===--
  local itemKey = IIfA:GetItemKey(itemLinkSlotInfo)
  local filterType = GetItemFilterTypeInfo(bagId, slotId) or 0
  local itemQuality = GetItemLinkDisplayQuality(itemLinkSlotInfo)
  local itemName = getItemName(bagId, slotId, itemLinkSlotInfo)
  local itemSlotCount = getItemCount(bagId, slotId)

  --=== [3] Storage Phase ===--
  local newItemData = DBv3[itemKey] or {}

  newItemData.filterType = filterType
  newItemData.itemQuality = itemQuality
  newItemData.itemName = itemName

  newItemData.locations = newItemData.locations or {}
  local locationData = newItemData.locations[location] or { bagID = bagId, bagSlot = {} }
  locationData.bagSlot[slotId] = itemSlotCount or 0
  newItemData.locations[location] = locationData

  DBv3[itemKey] = newItemData
  IIfA.BagSlotInfo[bagId][slotId] = itemKey

  return newItemData, itemKey
end

local function ItemAttributesChanged(storedItemKey, currentItemLink)
  -- Ensure storedKey is valid and is an item link
  if not storedItemKey or not IIfA:isItemLink(storedItemKey) then
    return false -- No stale data if storedKey is not an item link
  end

  -- If the stored key matches the current item link, no update needed
  if storedItemKey == currentItemLink then
    return false
  end

  -- Compare attributes of the stored and current item links
  if GetItemLinkItemId(storedItemKey) ~= GetItemLinkItemId(currentItemLink) then return true end
  if GetItemLinkDisplayQuality(storedItemKey) ~= GetItemLinkDisplayQuality(currentItemLink) then return true end
  if GetItemLinkTraitType(storedItemKey) ~= GetItemLinkTraitType(currentItemLink) then return true end
  if GetItemLinkRequiredLevel(storedItemKey) ~= GetItemLinkRequiredLevel(currentItemLink) then return true end
  if GetItemLinkRequiredChampionPoints(storedItemKey) ~= GetItemLinkRequiredChampionPoints(currentItemLink) then return true end
  if GetItemLinkTraitType(storedItemKey) ~= GetItemLinkTraitType(currentItemLink) then return true end
  if GetItemLinkAppliedEnchantId(storedItemKey) ~= GetItemLinkAppliedEnchantId(currentItemLink) then return true end

  return false -- No stale data detected
end

function IIfA:EvalBagItem(bagId, slotId)
  --=== [1] Early Exit: Skip untracked bags ===--
  if not IIfA.trackedBags[bagId] then return end

  --=== [2] Basic Setup ===--
  local DBv3 = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3

  local itemSlotCount = getItemCount(bagId, slotId)
  local itemLink = GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS)

  if (bagId == BAG_FURNITURE_VAULT and IIfA:isItemLink(itemLink)) then
    itemLink = IIfA:CheckLevelAndSubType(itemLink)
  end

  local storedKey = IIfA:GetBagSlotInfo(bagId, slotId)
  local location = getDatabaseItemLocation(bagId)

  --=== [3] Sanity Check: Location must be valid ===--
  if location == IIfA.EMPTY_STRING or location == nil then
    storedKey = storedKey or "[Empty String or Nil for storedKey]"
    location = location or "[Empty String or Nil for location]"
    IIfA:dm("Warn", "[EvalBagItem] Error: location: '<<1>>' is not valid! bagId: <<2>>, slotId: <<3>>, storedKey: '<<4>>'", location, bagId, slotId, storedKey)
    return
  end

  --=== [4] Handle empty slot cleanup ===--
  local hasNoBagSlotData = (not itemLink or itemLink == "") and itemSlotCount <= 0
  local shouldClearDatabaseLocations = storedKey and hasNoBagSlotData and (IIfA:isItemKey(storedKey) or IIfA:isItemLink(storedKey))

  if DBv3 and DBv3[storedKey] and shouldClearDatabaseLocations then
    DBv3[storedKey] = cleanupItemLocation(DBv3[storedKey], location, bagId, slotId)
    IIfA:dm("Warn", "[EvalBagItem] Invalid data for bagId <<1>>, slotId <<2>>, clearing stored info for: '<<3>>', itemLink '<<4>>', itemSlotCount <<5>>, location '<<6>>'.", bagId, slotId, storedKey, itemLink, itemSlotCount, location)
    return
  end

  --=== [5] Check for valid item link ===--
  if not itemLink or #itemLink == 0 then
    IIfA:dm("Warn", "[EvalBagItem] itemLink not defined! storedKey '<<1>>', itemLink '<<2>>', itemSlotCount <<3>>, location '<<4>>', bag <<5>>, slot <<6>>", storedKey or "[Empty String or Nil for storedKey]", itemLink, itemSlotCount, location or "[Empty String or Nil for location]", bagId, slotId)
    return
  end

  --=== [6] Prepare item key and name ===--
  local itemKey = IIfA:GetItemKey(itemLink)
  if not itemKey or #itemKey == 0 then
    if storedKey then itemKey = IIfA.BagSlotInfo[bagId][slotId] end
    if not itemKey or #itemKey == 0 then
      IIfA:dm("Warn", "[EvalBagItem] itemKey not defined! storedKey '<<1>>', itemLink '<<2>>', itemSlotCount <<3>>, location '<<4>>', bag <<5>>, slot <<6>>", storedKey or "[Empty String or Nil for storedKey]", itemLink, itemSlotCount, location or "[Empty String or Nil for location]", bagId, slotId)
      return
    end
  end

  IIfA:SetBagSlotInfo(bagId, slotId, itemKey)

  --=== [7] Load or Create DBitem and Store Data ===--
  local itemName = getItemName(bagId, slotId, itemLink)
  local DBitem = DBv3[itemKey] or {}
  DBitem.filterType = DBitem.filterType or GetItemFilterTypeInfo(bagId, slotId) or 0
  DBitem.itemQuality = DBitem.itemQuality or GetItemLinkDisplayQuality(itemLink)
  DBitem.itemName = DBitem.itemName or itemName
  DBitem.locations = DBitem.locations or {}

  -- Ensure the location exists in DBitem.locations
  DBitem.locations[location] = DBitem.locations[location] or { bagID = bagId, bagSlot = {} }
  DBitem.locations[location].bagSlot[slotId] = itemSlotCount or 0

  --=== [8] Handle Stale Item Key ===--
  -- Cleanup if BagSlotInfo doesn't match current itemLink
  if ItemAttributesChanged(storedKey, itemLink) then
    IIfA:dm("Warn", "[EvalBagItem] Stale Data: itemLink '<<1>>', itemKey '<<2>>', location '<<3>>', bag <<4>>, slot <<5>>", itemLink, itemKey, location, bagId, slotId)
    local newItemKey
    DBitem, newItemKey = handleStaleDataCleanup(DBv3, storedKey, location, bagId, slotId, itemLink)
    IIfA:SetBagSlotInfo(bagId, slotId, newItemKey)
    itemKey = newItemKey -- assign newItemKey to itemKey
    -- Check if the old DBitem has no remaining locations and clear it from DBv3 if so
    local oldDBitem = DBv3[storedKey]
    if oldDBitem and (not oldDBitem.locations or next(oldDBitem.locations) == nil) then
      DBv3[storedKey] = nil
      IIfA:dm("Warn", "[EvalBagItem] Cleared stale DBv3 entry for storedKey '<<1>>'", storedKey)
    end
  end

  if IIfA:isItemKey(itemKey) then
    DBitem.itemLink = itemLink
  end

  --=== [9] Assign Unique ID if Required, @Baertram ===--
  local itemInstanceOrUniqueId, isBagToBuildItemInstanceOrUniqueId = getItemInstanceOrUniqueId(bagId, slotId, itemLink)
  if isBagToBuildItemInstanceOrUniqueId then
    DBitem.itemInstanceOrUniqueId = itemInstanceOrUniqueId
  end

  --=== [10] Fallback Cleanup if count is zero ===--
  --[[ This is a fallback condition. If the quantity is 0 here for the database
  location then something is wrong. It should have been cleared above. ]]--
  if DBitem.locations[location].bagSlot[slotId] == 0 then
    IIfA:dm("Warn", "[EvalBagItem] Zapping itemLink = '<<1>>', location = '<<2>>', bag = <<3>>, slot = <<4>>", itemLink, location, bagId, slotId)
    DBitem = cleanupItemLocation(DBitem, location, bagId, slotId)
  end

  --=== [11] Final Save to Database ===--
  -- Save the updated entry back to the database
  DBv3[itemKey] = DBitem
end

function IIfA:EvalFurnitureItem(houseCollectibleId, itemId, itemLink, stackCount, itemName)
  --[[ The bagId is actually the houseCollectibleId, and the slotIndex
  is actually the itemId. The furnitureItemLink is from the
  getAllPlacedFurniture table created within RescanHouse ]]--
  --=== [1] Early Filtering ===--
  local isPlayerInventory = houseCollectibleId < BAG_MAX_VALUE
  local isNotCollectibleFurniture = IIfA:isCollectibleLink(itemLink) and GetCollectibleCategoryType(itemId) ~= COLLECTIBLE_CATEGORY_TYPE_FURNITURE

  if isPlayerInventory or isNotCollectibleFurniture then return end

  if not IIfA.trackedBags[houseCollectibleId] then return end

  --=== [2] Validate Link Type ===--
  local isValidLinkType = IIfA:isItemLink(itemLink) or IIfA:isCollectibleLink(itemLink)
  if not isValidLinkType then return end

  --=== [3] Prep and Debug ===--
  local DBv3 = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3

  IIfA:dm("Debug", "[EvalFurnitureItem] itemLink: '<<1>>', itemId: '<<2>>', bag: <<3>>, slot: <<4>>", itemLink, itemId, houseCollectibleId, itemId)

  IIfA:SetFurnitureSlotInfo(houseCollectibleId, itemId, itemLink)

  --=== [4] Load or Initialize DB Entry ===--
  local DBitem = DBv3[itemLink] or {}

  if IIfA:isItemLink(itemLink) then
    DBitem.filterType = DBitem.filterType or GetItemLinkFilterTypeInfo(itemLink) or 0
    DBitem.itemQuality = DBitem.itemQuality or GetItemLinkDisplayQuality(itemLink)
    DBitem.itemName = DBitem.itemName or itemName
  elseif IIfA:isCollectibleLink(itemLink) then
    DBitem.filterType = DBitem.filterType or 0
    DBitem.itemQuality = DBitem.itemQuality or 1
    DBitem.itemName = DBitem.itemName or itemName
  end

  --=== [5] Assign Location & Stack Count ===--
  DBitem.locations = DBitem.locations or {}
  DBitem.locations[houseCollectibleId] = DBitem.locations[houseCollectibleId] or { bagID = houseCollectibleId, bagSlot = {} }
  DBitem.locations[houseCollectibleId].bagSlot[itemId] = stackCount or 0

  --=== [6] Save to Database ===--
  DBv3[itemLink] = DBitem
end

--[[Regardless of previous versions coding, this method is simply not
supported for the Guild Bank, or any player home.

Unlike GetBagContents which processes the bag indicated, this function
calls GetVirtualBagContents to scan the Craft Bag instead of GetBagContents.

If the bagId is BAG_SUBSCRIBER_BANK then CollectBag will not process that bag.
Instead when the bagId is BAG_BANK, BAG_SUBSCRIBER_BANK is processed as well. ]]--
local function CollectBag(bagId, tracked, b_useAsync)
  IIfA:dm("Debug", "[CollectBag] bagId: <<1>>, name: <<2>>, useAsync: <<3>>", bagId, GetBagName(bagId), tostring(b_useAsync))

  local collectibleHouseBankId = GetCollectibleForBag(bagId)
  local houseCollectibleId = GetCollectibleIdForHouse(GetCurrentZoneHouseId())

  local shouldSkipBagScan = IsFurnitureVaultUnavailable(bagId) or IsHouseBankUnavailable(bagId) or IsCompanionBagUnavailable(bagId) or IsBagUnsupportedForGetBagContents(bagId) or IsBankUnavailable(bagId)
  if shouldSkipBagScan then
    IIfA:dm("Debug", "[CollectBag] IsFurnitureVaultUnavailable: <<1>>", tostring(IsFurnitureVaultUnavailable(bagId)))
    IIfA:dm("Debug", "[CollectBag] IsHouseBankUnavailable: <<1>>", tostring(IsHouseBankUnavailable(bagId)))
    IIfA:dm("Debug", "[CollectBag] IsCompanionBagUnavailable: <<1>>", tostring(IsCompanionBagUnavailable(bagId)))
    IIfA:dm("Debug", "[CollectBag] IsBagUnsupportedForGetBagContents: <<1>>", tostring(IsBagUnsupportedForGetBagContents(bagId)))
    IIfA:dm("Debug", "[CollectBag] IsBankUnavailable: <<1>>", tostring(IsBankUnavailable(bagId)))
    IIfA:dm("Debug", "[CollectBag] Skipping bagId: <<1>>, not processed.", bagId)
    return
  end

  if bagId == BAG_WORN then
    --[[ We don't add 'elseif bagId == BAG_BACKPACK' here
    because getDatabaseItemLocation() returns a string of
    IIfA.currentCharacterId for the current character and it would
    clear everything in the IIfA database for the itemKey and the
    current character's information because the Backpack is shared
    with the worn items so the items are grouped together. ]]--
    IIfA:ClearLocationData(BAG_WORN)
    IIfA:ClearBagSlotInfoByBagId(BAG_WORN)
    IIfA:ClearBagSlotInfoByBagId(BAG_BACKPACK)
  elseif bagId == BAG_BANK then
    --[[ We don't add 'elseif bagId == BAG_SUBSCRIBER_BANK' here
    because getDatabaseItemLocation() returns a string of
    IIFA_LOCATION_KEY_BANK or "Bank" and it would clear
    everything in the IIfA database for the itemKey and the
    location "Bank" because the Subscriber Bank is shared
    with the Bank so items are grouped together. ]]--
    IIfA:ClearLocationData(BAG_BANK) -- IIFA_LOCATION_KEY_BANK
    IIfA:ClearBagSlotInfoByBagId(BAG_BANK)
    IIfA:ClearBagSlotInfoByBagId(BAG_SUBSCRIBER_BANK)
  elseif bagId == BAG_COMPANION_WORN then
    IIfA:ClearLocationData(BAG_COMPANION_WORN)
    IIfA:ClearBagSlotInfoByBagId(BAG_COMPANION_WORN)
  elseif bagId == BAG_VIRTUAL then
    IIfA:ClearLocationData(BAG_VIRTUAL)
    IIfA:ClearBagSlotInfoByBagId(BAG_VIRTUAL)
  elseif bagId == BAG_FURNITURE_VAULT then
    IIfA:ClearLocationData(BAG_FURNITURE_VAULT)
    IIfA:ClearBagSlotInfoByBagId(BAG_FURNITURE_VAULT)
  elseif bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN then
    if IsHouseBankUnavailable(bagId) then
      local chestName = GetCollectibleNickname(collectibleHouseBankId) or GetCollectibleName(collectibleHouseBankId)
      IIfA:dm("Debug", "[CollectBag] Skipping House chest bagId: <<1>>, named: <<2>>. Player is not inside a house or is not the owner.", collectibleHouseBankId, chestName)
      return -- prevent reading the house bag if we're not in our own home
    else
      IIfA:ClearLocationData(bagId)
      IIfA:ClearBagSlotInfoByBagId(bagId)
    end
  elseif bagId >= BAG_MAX_VALUE then
    IIfA:dm("Debug", "Skipping Housing Information (bagId: <<1>>, name: <<2>>, House ID: <<3>>): RescanHouse will scan the house upon entering.", bagId, GetCollectibleName(houseCollectibleId), houseCollectibleId)
    --[[ We prevent scanning placed housing items if we're not in a player home
    because scanning a player home requires GetNextPlacedHousingFurnitureId()
    which does not use bagId or slotId.
    ]]--
    return
  end

  -- Process contents
  if tracked then
    if bagId == BAG_VIRTUAL then
      GetVirtualBagContents(b_useAsync)
    else
      GetBagContents(bagId, b_useAsync)
      if bagId == BAG_BANK then
          --[[ It is safe to use ClearBagSlotInfoByBagId() with the
           BAG_SUBSCRIBER_BANK because BagSlotInfo uses two separate locations
           for BAG_BANK and BAG_SUBSCRIBER_BANK.

           Do not use ClearLocationData() with BAG_SUBSCRIBER_BANK ]]--
        GetBagContents(BAG_SUBSCRIBER_BANK, b_useAsync)
      elseif bagId == BAG_WORN then
          --[[ It is safe to use ClearBagSlotInfoByBagId() with the
           BAG_BACKPACK because BagSlotInfo uses two separate locations
           for BAG_WORN and BAG_BACKPACK.

           Do not use ClearLocationData() with BAG_SUBSCRIBER_BANK ]]--
        GetBagContents(BAG_BACKPACK, b_useAsync)
      end
    end
  else
    IIfA:dm("Warn", "[CollectBag] Bag was not marked as tracked: <<1>>", bagId)
  end
end

function IIfA:RescanBag(bagId)
  local tracked = IIfA.trackedBags[bagId]
  IIfA:dm("Debug", "RescanBag: <<1>>", bagId)
  --[[ ClearLocationData() and ClearBagSlotInfoByBagId() not needed
  here because they are in CollectBag() ]]--
  local bagToScan = bagId
  if bagId == BAG_BACKPACK then bagToScan = BAG_WORN end
  if bagId == BAG_SUBSCRIBER_BANK then bagToScan = BAG_BANK end
  CollectBag(bagToScan, tracked)
end

--[[Regardless of previous versions coding, this method is simply not
supported for the Guild Bank, or any player home.

Unlike GetBagContents which processes the bag indicated, this function
calls CollectBag which then calls GetBagContents unless it is the Craft Bag,
which is processed using GetVirtualBagContents.

This function loops over BagList which can contain values for player homes.

Because it loops over anything in the BagList check for Guild Bank and
Player Homes because those cannot be processed using GetBagContents.
However, CollectBag will process the Craft Bag.

This function uses LibAsync]]--
function IIfA:CollectAllUseAsync()
  local BagList = IIfA:GetTrackedBags() -- Get the list of tracked bags
  IIfA:dm("Debug", "[CollectAllUseAsync] Starting...")

  -- Using LibAsync's task:For loop to iterate over the BagList asynchronously
  task:For(pairs(BagList)):Do(function(bagId, tracked)
    -- 6-22-25 - Furniture Vault should be skipped if the collectible is locked
    local shouldSkipBagScan = IsFurnitureVaultUnavailable(bagId) or IsHouseBankUnavailable(bagId) or IsCompanionBagUnavailable(bagId) or IsBagUnsupportedForGetBagContents(bagId) or IsBankUnavailable(bagId)
    if shouldSkipBagScan then
      IIfA:dm("Debug", "[CollectAllUseAsync] IsFurnitureVaultUnavailable: <<1>>", tostring(IsFurnitureVaultUnavailable(bagId)))
      IIfA:dm("Debug", "[CollectAllUseAsync] IsHouseBankUnavailable: <<1>>", tostring(IsHouseBankUnavailable(bagId)))
      IIfA:dm("Debug", "[CollectAllUseAsync] IsCompanionBagUnavailable: <<1>>", tostring(IsCompanionBagUnavailable(bagId)))
      IIfA:dm("Debug", "[CollectAllUseAsync] IsBagUnsupportedForGetBagContents: <<1>>", tostring(IsBagUnsupportedForGetBagContents(bagId)))
      IIfA:dm("Debug", "[CollectAllUseAsync] IsBankUnavailable: <<1>>", tostring(IsBankUnavailable(bagId)))
      IIfA:dm("Debug", "[CollectAllUseAsync] Skipping invalid bagId: <<1>>, name: <<2>>", bagId, GetBagName(bagId))
      return
    else
      IIfA:dm("Debug", "[CollectAllUseAsync] Processing bagId: <<1>>, name: <<2>>", bagId, GetBagName(bagId))
      CollectBag(bagId, tracked, true)
    end
  end):Then(function()
    -- Final tasks: Clear unowned items and update bag slot info
    IIfA:dm("Debug", "[CollectAllUseAsync] Final tasks: clearing unowned items and updating bag slot info.")

    -- Delay the cleanup tasks to ensure all bags are processed first
    task:Call(function()
      IIfA:ClearUnowned()
      IIfA:MakeBSI()
    end, 1000) -- Delay by 1 second to allow all tasks to finish
  end) -- Closing the Then function here
end

--[[Regardless of previous versions coding, this method is simply not
supported for the Guild Bank, or any player home.

Unlike GetBagContents which processes the bag indicated, this function
calls CollectBag which then calls GetBagContents unless it is the Craft Bag,
which is processed using GetVirtualBagContents.

This function loops over BagList which can contain values for player homes.

This function does not use LibAsync]]--
function IIfA:CollectAll()
  local bagList = IIfA:GetTrackedBags() -- Get the list of tracked bags
  IIfA:dm("Debug", "[CollectAll] Starting...")

  -- Using LibAsync's task:For loop to iterate over the BagList asynchronously
  for bagId, tracked in pairs(bagList) do
    -- 6-22-25 - Furniture Vault should be skipped if the collectible is locked
    local shouldSkipBagScan = IsFurnitureVaultUnavailable(bagId) or IsHouseBankUnavailable(bagId) or IsCompanionBagUnavailable(bagId) or IsBagUnsupportedForGetBagContents(bagId) or IsBankUnavailable(bagId)
    if shouldSkipBagScan then
      IIfA:dm("Debug", "[CollectAll] IsFurnitureVaultUnavailable: <<1>>", tostring(IsFurnitureVaultUnavailable(bagId)))
      IIfA:dm("Debug", "[CollectAll] IsHouseBankUnavailable: <<1>>", tostring(IsHouseBankUnavailable(bagId)))
      IIfA:dm("Debug", "[CollectAll] IsCompanionBagUnavailable: <<1>>", tostring(IsCompanionBagUnavailable(bagId)))
      IIfA:dm("Debug", "[CollectAll] IsBagUnsupportedForGetBagContents: <<1>>", tostring(IsBagUnsupportedForGetBagContents(bagId)))
      IIfA:dm("Debug", "[CollectAll] IsBankUnavailable: <<1>>", tostring(IsBankUnavailable(bagId)))
      IIfA:dm("Debug", "[CollectAll] Skipping invalid bagId: <<1>>, name: <<2>>", bagId, GetBagName(bagId))
      return
    else
      IIfA:dm("Debug", "[CollectAll] Processing bagId: <<1>>, name: <<2>>", bagId, GetBagName(bagId))
      CollectBag(bagId, tracked, false)
    end
  end

  -- Final tasks: Clear unowned items and update bag slot info
  IIfA:dm("Debug", "[CollectAll] Final tasks: clearing unowned items and updating bag slot info.")

  -- 6-3-17 AM - need to clear unowned items when deleting char/guildbank too
  -- 4-4-18 AM - call immediately after collectbag calls above
  IIfA:ClearUnowned()
  IIfA:MakeBSI()  -- 5-11-19 AM - added missing call (if this is on player unload, it's not necessary, but might be used some other time)
end

function IIfA:ClearUnowned()
  --[[ Iterate through the inventory database and remove items with no
  valid `location`, `locationData`, or missing mappings in `IIFA_DATABASE` ]]
  local DBv3 = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3

  for itemKey, itemData in pairs(DBv3) do
    for location, locationData in pairs(itemData.locations) do
      if location == IIfA.EMPTY_STRING then
        itemData.locations[IIfA.EMPTY_STRING] = nil
      else
        if location ~= IIFA_LOCATION_KEY_BANK and location ~= IIFA_LOCATION_KEY_CRAFTBAG then
          if locationData.bagID == BAG_BACKPACK or locationData.bagID == BAG_WORN then
            local charIdToName = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].CharIdToName
            if charIdToName[location] == nil then
              itemData.locations[location] = nil
            end
          elseif locationData.bagID == BAG_GUILDBANK then
            local guildBankInfo = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].guildBankInfo
            if guildBankInfo[location] == nil or guildBankInfo[location].bCollectData == false then
              itemData.locations[location] = nil
            end
          end
        end
      end
    end

    if not ItemHasLocations(itemData) then
      DBv3[itemKey] = nil
    end
  end
end

--[[ location should be nil unless you need to specify
a specific character, companion, or guild bank name. When
scanning the contents of a player home the houseCollectibleId
should be bagId but getDatabaseItemLocation will return
houseCollectibleId as the location.

The bagId is only to compare against the current character ID
when it's BAG_BACKPACK or BAG_WORN so you don't clear other
characters information.
]]--
function IIfA:ClearLocationData(bagId, location)
  local hasNoBagId = not bagId
  if hasNoBagId then return end
  location = location or getDatabaseItemLocation(bagId)
  if location == IIFA_LOCATION_KEY_BANK and bagId == BAG_SUBSCRIBER_BANK then
    IIfA:dm("Warn", "[ClearLocationData] Do not clear locationID: <<1>>, bagId: '<<2>>' - '<<3>>', it clears information for bagId: '<<4>>' - '<<5>>' at the same time", location, bagId, GetBagName(BAG_SUBSCRIBER_BANK), BAG_BANK, GetBagName(BAG_BANK))
    return
  end
  if location == IIfA.currentCharacterId and bagId == BAG_BACKPACK then
    IIfA:dm("Warn", "[ClearLocationData] Do not clear locationID: <<1>>, bagId: '<<2>>' - '<<3>>', it clears information for bagId: '<<4>>' - '<<5>>' at the same time", location, bagId, GetBagName(BAG_BACKPACK), BAG_WORN, GetBagName(BAG_WORN))
    return
  end

  -- Access the DBv3 table from the updated database structure
  local DBv3 = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3
  if DBv3 then
    IIfA:dm("Debug", "[ClearLocationData] Clearing data for location: <<1>>, bagId: <<2>>, name: <<3>>", location, bagId, GetBagName(bagId))
    for itemKey, itemData in pairs(DBv3) do
      -- Iterate over all items in the database
      local itemLocation = itemData.locations[location]
      if itemLocation then
        local isBackpackOrWornForPlayer = bagId and ((itemLocation.bagId == BAG_BACKPACK or itemLocation.bagId == BAG_WORN) and location == IIfA.currentCharacterId)
        local isCompanionEquippedBag = bagId and ((itemLocation.bagId == BAG_COMPANION_WORN) and location == IIfA.currentCompanionId)
        local isCurrentPlayer = location == IIfA.currentCharacterId -- used in ScanCurrentCharacter()
        local isNonBackpackOrWornBag = (itemLocation.bagId ~= BAG_BACKPACK and itemLocation.bagId ~= BAG_WORN and itemLocation.bagId ~= BAG_COMPANION_WORN)
        if isBackpackOrWornForPlayer or isCompanionEquippedBag then
          -- If bagId is provided and matches the bagId of the location, clear it
          if bagId and itemLocation.bagId == bagId then
            itemData.locations[location] = nil
          end
        elseif isNonBackpackOrWornBag or isCurrentPlayer then
          -- If location doesn't match the current character, clear it regardless of bagId
          itemData.locations[location] = nil
        end
      end

      -- Check if there are any remaining locations and remove the item if none exist
      if not ItemHasLocations(itemData) then
        DBv3[itemKey] = nil
      end
    end
  end
end

function IIfA:RenameItems()
  -- Access the DBv3 database from the current server and account
  local DBv3 = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].DBv3
  local itemName, identifiedLink

  if DBv3 then
    -- Iterate through all items in the database
    for itemKey, itemData in pairs(DBv3) do
      identifiedLink = nil
      -- Determine the identifiedLink based on the itemKey type
      if IIfA:isItemLink(itemKey) or IIfA:isCollectibleLink(itemKey) then
        identifiedLink = itemKey
      elseif IIfA:isItemKey(itemKey) then
        identifiedLink = itemData.itemLink
      end

      itemName = nil
      -- Determine the itemName based on the identifiedLink type
      if IIfA:isItemLink(identifiedLink) then
        itemName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(identifiedLink))
      elseif IIfA:isCollectibleLink(identifiedLink) then
        local collectibleId = IIfA:GetCollectibleLinkItemId(identifiedLink)
        itemName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetCollectibleName(collectibleId))
      end

      -- Update the itemName in the database if determined
      if itemName ~= nil then
        itemData.itemName = itemName
      end
    end
  end
end
