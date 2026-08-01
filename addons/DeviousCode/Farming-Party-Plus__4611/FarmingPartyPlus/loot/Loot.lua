local ADDON_NAME = 'FarmingPartyPlus'

local function NormalizeItemName(itemLink)
  local itemName = GetItemLinkName(itemLink)
  if itemName == nil or itemName == '' then
    itemName = zo_strformat('<<t:1>>', itemLink)
  end
  return zo_strlower(zo_strformat('<<z:1>>', itemName))
end

local Addon = FarmingPartyPlus
local Loot = ZO_Object:Subclass()
Addon.Classes.Loot = Loot

local NOT_EQUIPPABLE = 0
local Members
local MemberList
local Logger
local Settings
local Sync
local Price
local knownFishingLinksByCode = {}
local trackedLocalFishSlots = {}
local trackedLocalFishSlotKeysByItemName = {}
local trackedSyncedFishSlots = {}
local recentLocalGuttingOutputs = {}
local recentStolenInventoryItems = {}
local AUTO_ADD_WARNING_DIALOG_NAME = 'FarmingPartyPlusCraftBagWarningDialog'
local STOLEN_CACHE_SECONDS = 5
local SYNC_KIND_DELTA = 0
local SYNC_KIND_FISH_STACK_STATE = 1
local SYNC_KIND_FISH_STACK_DELTA = 2

local function RememberKnownItemLink(itemLink)
  local entry = FarmingPartyPlusFishingSyncLookup:GetByNormalizedName(NormalizeItemName(itemLink))
  if entry ~= nil then
    knownFishingLinksByCode[entry.code] = itemLink
  end
end

local function ResolveKnownItemLink(itemCode, fallbackLink)
  itemCode = tonumber(itemCode) or 0
  if itemCode > 0 and knownFishingLinksByCode[itemCode] ~= nil then
    return knownFishingLinksByCode[itemCode]
  end
  local canonicalLink = FarmingPartyPlusFishingSyncLookup:GetCanonicalLinkByCode(itemCode)
  if canonicalLink ~= nil and canonicalLink ~= '' then
    return canonicalLink
  end
  return fallbackLink or ''
end

local function GetPriceDetails(itemLink)
  local itemValue, priceSourceKey = Price.GetItemPrice(itemLink)
  local priceSourceLabel = Price.GetHistorySourceLabel(priceSourceKey)
  return itemValue, priceSourceKey, priceSourceLabel
end

local function BuildBagSlotKey(bagId, slotIndex)
  return string.format('%d:%d', bagId, slotIndex)
end

local function AddIndexedSlotKey(indexTable, itemName, slotKey)
  if itemName == nil or itemName == '' then
    return
  end
  local slotKeys = indexTable[itemName]
  if slotKeys == nil then
    slotKeys = {}
    indexTable[itemName] = slotKeys
  end
  slotKeys[slotKey] = true
end

local function RemoveIndexedSlotKey(indexTable, itemName, slotKey)
  if itemName == nil or itemName == '' then
    return
  end
  local slotKeys = indexTable[itemName]
  if slotKeys == nil then
    return
  end
  slotKeys[slotKey] = nil
  if next(slotKeys) == nil then
    indexTable[itemName] = nil
  end
end

local function IsBackpackSlot(bagId)
  return bagId == BAG_BACKPACK
end

local function IsGuttableFishItem(itemLink)
  return GetItemLinkItemType(itemLink) == ITEMTYPE_FISH
      and GetItemLinkQuality(itemLink) <= ITEM_QUALITY_NORMAL
      and NormalizeItemName(itemLink) ~= 'fish'
end

local function IsTrackedGuttingOutputName(itemName)
  return itemName == 'fish' or itemName == 'perfect roe'
end

local function IsRecipeItemType(itemType)
  return itemType == ITEMTYPE_RECIPE
end

local function BuildRecentOutputKey(itemLink, quantity)
  return string.format('%s|%s', NormalizeItemName(itemLink), tostring(quantity or 0))
end

local function GetItemIdFromLink(itemLink)
  if GetItemLinkItemId == nil or itemLink == nil or itemLink == '' then
    return nil
  end
  return tonumber(GetItemLinkItemId(itemLink))
end

local function BuildStolenInventoryKey(itemLink, itemId)
  itemId = tonumber(itemId) or GetItemIdFromLink(itemLink) or 0
  if itemId > 0 then
    return 'id:' .. tostring(itemId)
  end
  return 'name:' .. NormalizeItemName(itemLink)
end

local function CleanupRecentOutputs(cache, now)
  for eventKey, timestamp in pairs(cache) do
    if now - timestamp > 2 then
      cache[eventKey] = nil
    end
  end
end

local function CleanupRecentStolenInventoryItems(now)
  for eventKey, entry in pairs(recentStolenInventoryItems) do
    if now - (entry.timestamp or 0) > STOLEN_CACHE_SECONDS then
      recentStolenInventoryItems[eventKey] = nil
    end
  end
end

local function RememberStolenInventoryItem(itemLink, quantity)
  if itemLink == nil or itemLink == '' or quantity <= 0 then
    return
  end

  local now = GetTimeStamp()
  CleanupRecentStolenInventoryItems(now)
  local eventKey = BuildStolenInventoryKey(itemLink)
  local entry = recentStolenInventoryItems[eventKey]
  if entry == nil then
    entry = {
      quantity = 0,
      timestamp = now
    }
    recentStolenInventoryItems[eventKey] = entry
  end

  entry.quantity = (entry.quantity or 0) + quantity
  entry.timestamp = now
end

local function ConsumeRecentStolenInventoryItem(itemLink, itemId, quantity)
  if itemLink == nil or itemLink == '' then
    return false
  end

  local now = GetTimeStamp()
  CleanupRecentStolenInventoryItems(now)
  local eventKey = BuildStolenInventoryKey(itemLink, itemId)
  local entry = recentStolenInventoryItems[eventKey]
  if entry == nil or (entry.quantity or 0) <= 0 then
    return false
  end

  local quantityToConsume = math.max(tonumber(quantity) or 1, 1)
  entry.quantity = (entry.quantity or 0) - quantityToConsume
  entry.timestamp = now
  if entry.quantity <= 0 then
    recentStolenInventoryItems[eventKey] = nil
  end
  return true
end

local function IsLootEventStolen(itemLink, itemId, quantity, isStolen, isPickpocketLoot)
  if isStolen == true or isPickpocketLoot == true then
    return true
  end
  return ConsumeRecentStolenInventoryItem(itemLink, itemId, quantity)
end

local function IsCraftBagAutoAddEnabled()
  if GetSetting_Bool == nil then
    return false
  end
  return GetSetting_Bool(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_ADD_TO_CRAFT_BAG)
end

function Loot:New()
  local obj = ZO_Object.New(self)
  obj:Initialize()
  return obj
end

function Loot:Initialize()
  Members = FarmingPartyPlus.Modules.Members
  MemberList = FarmingPartyPlus.Modules.MemberList
  Logger = FarmingPartyPlus.Modules.Logger
  Settings = FarmingPartyPlus.Settings
  Sync = FarmingPartyPlus.Modules.Sync
  Price = FarmingPartyPlus.Price
  self.hasShownCraftBagAutoAddWarning = false

  self:RegisterDialogs()
  if Settings:Status() == FarmingPartyPlus.Settings.TRACKING_STATUS.ENABLED then
    self:AddEventHandlers()
  end
end

function Loot:Finalize()
end

function Loot:ClearSessionState()
  ZO_ClearTable(knownFishingLinksByCode)
  ZO_ClearTable(trackedLocalFishSlots)
  ZO_ClearTable(trackedLocalFishSlotKeysByItemName)
  ZO_ClearTable(trackedSyncedFishSlots)
  ZO_ClearTable(recentLocalGuttingOutputs)
  ZO_ClearTable(recentStolenInventoryItems)
  self.hasShownCraftBagAutoAddWarning = false
end

function Loot:RegisterDialogs()
  if self.dialogsRegistered then
    return
  end

  ZO_Dialogs_RegisterCustomDialog(AUTO_ADD_WARNING_DIALOG_NAME, {
    title = {
      text = 'Craft Bag Auto-Add Detected'
    },
    mainText = {
      text = 'Auto-Add to Craft Bag is on. Fish and Perfect Roe may skip Farming Party Plus tracking. Turn it off now?'
    },
    buttons = {
      {
        text = SI_DIALOG_ACCEPT,
        callback = function()
          SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_ADD_TO_CRAFT_BAG, 'false')
          d('[Farming Party Plus]: Auto-Add to Craft Bag was turned off.')
        end
      },
      {
        text = SI_DIALOG_CANCEL
      }
    }
  })

  self.dialogsRegistered = true
end

function Loot:WarnAboutCraftBagAutoAddIfNeeded(itemLink)
  if self.hasShownCraftBagAutoAddWarning then
    return
  end
  if itemLink == nil or itemLink == '' then
    return
  end

  local normalizedItemName = NormalizeItemName(itemLink)
  local isFishingRelevant = IsGuttableFishItem(itemLink) or IsTrackedGuttingOutputName(normalizedItemName)
  if not isFishingRelevant or not IsCraftBagAutoAddEnabled() then
    return
  end

  self.hasShownCraftBagAutoAddWarning = true
  ZO_Dialogs_ShowDialog(AUTO_ADD_WARNING_DIALOG_NAME)
end

function Loot:AddEventHandlers()
  EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_LOOT_RECEIVED,
    function(...)
      self:OnItemLooted(...)
    end
  )
  EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    function(...)
      self:OnInventorySlotUpdated(...)
    end
  )
end

function Loot:RemoveEventHandlers()
  EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_LOOT_RECEIVED)
  EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
end

local function FindMemberKey(looterName, lootedByPlayer)
  if lootedByPlayer then
    return zo_strformat(SI_UNIT_NAME, GetUnitName('player'))
  end

  if looterName ~= nil and looterName ~= '' then
    local indexedMemberKey = Members:GetMemberKeyByDisplayName(looterName)
    if indexedMemberKey ~= nil then
      return indexedMemberKey
    end

    local normalizedName = zo_strformat(SI_UNIT_NAME, looterName)
    if Members:HasMember(normalizedName) then
      return normalizedName
    end
  end

  return nil
end

local function GetMember(looterName, lootedByPlayer)
  local memberKey = FindMemberKey(looterName, lootedByPlayer)
  if memberKey ~= nil and Members:HasMember(memberKey) then
    return memberKey, Members:GetMember(memberKey)
  end

  MemberList:SyncGroupMembers(MemberList:GetAllGroupMembers())
  memberKey = FindMemberKey(looterName, lootedByPlayer)
  if memberKey ~= nil then
    return memberKey, Members:GetMember(memberKey)
  end

  return nil, nil
end

local function GetSyncedMember(characterName, displayName)
  if displayName ~= nil then
    local displayNameMemberKey = Members:GetMemberKeyByDisplayName(displayName)
    if displayNameMemberKey ~= nil then
      return displayNameMemberKey, Members:GetMember(displayNameMemberKey)
    end
  end

  local normalizedCharacterName = zo_strformat(SI_UNIT_NAME, characterName or '')
  if normalizedCharacterName ~= '' and Members:HasMember(normalizedCharacterName) then
    return normalizedCharacterName, Members:GetMember(normalizedCharacterName)
  end

  MemberList:SyncGroupMembers(MemberList:GetAllGroupMembers())
  if displayName ~= nil then
    local displayNameMemberKey = Members:GetMemberKeyByDisplayName(displayName)
    if displayNameMemberKey ~= nil then
      return displayNameMemberKey, Members:GetMember(displayNameMemberKey)
    end
  end

  if normalizedCharacterName ~= '' and Members:HasMember(normalizedCharacterName) then
    return normalizedCharacterName, Members:GetMember(normalizedCharacterName)
  end

  return nil, nil
end

local function ShouldSuppressNativeLoot(displayName, itemLink, quantity, lootType)
  if Sync == nil or Sync.ConsumeDuplicate == nil then
    return false
  end
  return Sync:ConsumeDuplicate(displayName, GetItemLinkName(itemLink), quantity, lootType, 'native')
end

local function RecordNativeLoot(displayName, itemLink, quantity, lootType)
  if Sync == nil or Sync.RecordObservedLoot == nil then
    return
  end
  Sync:RecordObservedLoot(displayName, GetItemLinkName(itemLink), quantity, lootType, 'native')
end

local function ResolveSyncedTrackedItem(data)
  local syncEntry = FarmingPartyPlusFishingSyncLookup:GetByCode(data.itemCode)
  local itemLink = syncEntry ~= nil and ResolveKnownItemLink(syncEntry.code, data.itemLink) or data.itemLink
  local itemName = data.itemName
  if (itemName == nil or itemName == '') and syncEntry ~= nil then
    itemName = syncEntry.name
    data.itemName = itemName
  elseif (itemName == nil or itemName == '') and itemLink ~= nil and itemLink ~= '' then
    itemName = NormalizeItemName(itemLink)
    data.itemName = itemName
  end
  local trackedItem = (itemLink ~= nil and itemLink ~= '') and itemLink or itemName
  local resolvedItemValue, priceSourceKey, priceSourceLabel
  if itemLink ~= nil and itemLink ~= '' then
    resolvedItemValue, priceSourceKey, priceSourceLabel = GetPriceDetails(itemLink)
  else
    resolvedItemValue = tonumber(data.itemValue) or 0
    priceSourceKey = 'npc'
    priceSourceLabel = Price.GetHistorySourceLabel(priceSourceKey)
  end
  return trackedItem, resolvedItemValue, priceSourceKey, priceSourceLabel
end

local function LogSyncedLoot(displayName, trackedItem, quantity, itemValue, lootType, priceSourceLabel)
  local absoluteQuantity = math.abs(quantity)
  local totalValue = itemValue * absoluteQuantity
  Logger:LogLootItem(displayName, false, trackedItem, quantity, totalValue, lootType or 0, priceSourceLabel)
end

function Loot:PassesBaseExclusions(itemLink)
  local _, _, _, equipType = GetItemLinkInfo(itemLink)
  local itemType = GetItemLinkItemType(itemLink)

  if equipType ~= NOT_EQUIPPABLE and not Settings:TrackGearLoot() then
    return false
  end
  if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF and not Settings:TrackMotifLoot() then
    return false
  end

  return true
end

local function GetSyncedItemLink(data)
  local itemLink = data.itemLink
  local syncEntry = FarmingPartyPlusFishingSyncLookup:GetByCode(data.itemCode)
  if syncEntry ~= nil then
    itemLink = ResolveKnownItemLink(syncEntry.code, itemLink)
    data.itemLink = itemLink
  end
  return itemLink
end

function Loot:ShouldTrackByLegacyRules(itemLink)
  local itemQuality = GetItemLinkQuality(itemLink)
  local minimumQuality = tonumber(Settings:MinimumLootQuality()) or ITEM_QUALITY_TRASH
  if itemQuality < minimumQuality then
    return false
  end
  return true
end

function Loot:ShouldTrackByWhitelist(itemLink)
  local itemType = GetItemLinkItemType(itemLink)
  if IsRecipeItemType(itemType) and Settings:IsWhitelistRuleEnabled('__recipes_any__') then
  return Price.GetItemPrice(itemLink) >= Settings:MinimumRecipeValue()
  end

  local itemKey = NormalizeItemName(itemLink)
  if Settings:IsWhitelistedItem(itemKey) then
    return true
  end

  if itemType == ITEMTYPE_FISH and Settings:IsWhitelistRuleEnabled('__fish_any__') then
    return true
  end

  return false
end

function Loot:ShouldTrackItem(itemLink, lootType, isStolen, lootedByPlayer)
  if lootType == LOOT_TYPE_QUEST_ITEM then
    return false
  end
  if Settings:UseStolenOnlyMode() then
    if lootedByPlayer == false then
      return true
    end
    return isStolen == true
  end
  if not self:PassesBaseExclusions(itemLink) then
    return false
  end

  if Settings:UseWhitelistMode() then
    return self:ShouldTrackByWhitelist(itemLink)
  end

  return self:ShouldTrackByLegacyRules(itemLink)
end

function Loot:ShouldTrackSyncedData(data)
  if data.lootType == LOOT_TYPE_QUEST_ITEM then
    return false
  end
  if Settings:UseStolenOnlyMode() then
    return false
  end
  local syncEntry = FarmingPartyPlusFishingSyncLookup:GetByCode(data.itemCode)
  if syncEntry == nil then
    return false
  end
  local itemLink = GetSyncedItemLink(data)
  if itemLink ~= nil and itemLink ~= '' then
    return self:ShouldTrackItem(itemLink, data.lootType)
  end

  if Settings:UseWhitelistMode() then
    if syncEntry.kind == 'common_fish' then
      return Settings:IsWhitelistRuleEnabled('__fish_any__')
    end
    return Settings:IsWhitelistedItem(syncEntry.key)
  end

  return (tonumber(syncEntry.quality) or ITEM_QUALITY_TRASH) >= (tonumber(Settings:MinimumLootQuality()) or ITEM_QUALITY_TRASH)
end

function Loot:RememberLocalFishSlot(bagId, slotIndex)
  if not IsBackpackSlot(bagId) then
    return
  end

  local slotKey = BuildBagSlotKey(bagId, slotIndex)
  local existingTrackedSlot = trackedLocalFishSlots[slotKey]
  local itemLink = GetItemLink(bagId, slotIndex)
  if itemLink == nil or itemLink == '' or not IsGuttableFishItem(itemLink) then
    if existingTrackedSlot ~= nil then
      RemoveIndexedSlotKey(trackedLocalFishSlotKeysByItemName, existingTrackedSlot.itemName, slotKey)
      trackedLocalFishSlots[slotKey] = nil
    end
    return
  end

  local normalizedItemName = NormalizeItemName(itemLink)
  local preservedClaimedCount = 0
  if existingTrackedSlot ~= nil and existingTrackedSlot.itemName == normalizedItemName then
    preservedClaimedCount = existingTrackedSlot.claimedCount or 0
  elseif existingTrackedSlot ~= nil then
    RemoveIndexedSlotKey(trackedLocalFishSlotKeysByItemName, existingTrackedSlot.itemName, slotKey)
  end

  local itemValue, priceSourceKey, priceSourceLabel = GetPriceDetails(itemLink)
  trackedLocalFishSlots[slotKey] = {
    bagId = bagId,
    slotIndex = slotIndex,
    itemName = normalizedItemName,
    itemLink = itemLink,
    itemValue = itemValue,
    priceSourceKey = priceSourceKey,
    priceSourceLabel = priceSourceLabel,
    stackCount = GetSlotStackSize(bagId, slotIndex),
    claimedCount = preservedClaimedCount
  }
  AddIndexedSlotKey(trackedLocalFishSlotKeysByItemName, normalizedItemName, slotKey)
end

function Loot:CaptureLocalFishSlotsByName(normalizedItemName)
  local capturedSlotKeys = {}
  local bagSize = GetBagSize(BAG_BACKPACK)
  for slotIndex = 0, bagSize - 1 do
    local slotItemLink = GetItemLink(BAG_BACKPACK, slotIndex)
    if slotItemLink ~= nil and slotItemLink ~= '' and NormalizeItemName(slotItemLink) == normalizedItemName and IsGuttableFishItem(slotItemLink) then
      self:RememberLocalFishSlot(BAG_BACKPACK, slotIndex)
      capturedSlotKeys[#capturedSlotKeys + 1] = BuildBagSlotKey(BAG_BACKPACK, slotIndex)
    end
  end
  return capturedSlotKeys
end

function Loot:ClaimLocalFishSlotForSession(normalizedItemName, caughtQuantity)
  zo_callLater(function()
    local playerName = zo_strformat(SI_UNIT_NAME, GetUnitName('player'))
    local claimedCatchQuantity = tonumber(caughtQuantity) or 0
    local slotKeys = self:CaptureLocalFishSlotsByName(normalizedItemName)
    for _, slotKey in ipairs(slotKeys) do
      local trackedSlot = trackedLocalFishSlots[slotKey]
      if trackedSlot ~= nil then
        local currentStackCount = trackedSlot.stackCount or 0
        local previouslyClaimedCount = trackedSlot.claimedCount or 0
        local claimDelta = currentStackCount - previouslyClaimedCount - claimedCatchQuantity

        if claimDelta > 0 and Members:HasMember(playerName) then
          self:AddNewLootedItem(playerName, trackedSlot.itemLink, trackedSlot.itemValue, claimDelta)
          Logger:LogStackFound(GetDisplayName('player'), true, trackedSlot.itemLink, claimDelta, trackedSlot.itemValue * claimDelta, LOOT_TYPE_ITEM, trackedSlot.priceSourceLabel)
        end
        trackedSlot.claimedCount = currentStackCount
      end
    end
  end, 0)
end

function Loot:OnItemLooted(eventCode, name, itemLink, quantity, itemSound, lootType, lootedByPlayer, isPickpocketLoot, questItemIcon, itemId, isStolen)
  if not lootedByPlayer and not Settings:TrackGroupLoot() then
    return
  end
  if lootedByPlayer and not Settings:TrackSelfLoot() then
    return
  end

  local normalizedItemName = NormalizeItemName(itemLink)
  RememberKnownItemLink(itemLink)
  if lootedByPlayer then
    self:WarnAboutCraftBagAutoAddIfNeeded(itemLink)
  end
  local lootEventIsStolen = IsLootEventStolen(itemLink, itemId, quantity, isStolen, isPickpocketLoot)
  if not self:ShouldTrackItem(itemLink, lootType, lootEventIsStolen, lootedByPlayer) then
    return
  end

  if lootedByPlayer and IsTrackedGuttingOutputName(normalizedItemName) then
    local eventKey = BuildRecentOutputKey(itemLink, quantity)
    CleanupRecentOutputs(recentLocalGuttingOutputs, GetTimeStamp())
    recentLocalGuttingOutputs[eventKey] = GetTimeStamp()
  end

  local itemValue, _, priceSourceLabel = GetPriceDetails(itemLink)
  local totalValue = itemValue * quantity
  local memberKey, looterMember = GetMember(name, lootedByPlayer)

  if memberKey == nil or looterMember == nil then
    return
  end

  local observedDisplayName = looterMember.displayName or memberKey
  if not lootedByPlayer and ShouldSuppressNativeLoot(observedDisplayName, itemLink, quantity, lootType) then
    return
  end

  RecordNativeLoot(observedDisplayName, itemLink, quantity, lootType)
  self:AddNewLootedItem(memberKey, itemLink, itemValue, quantity)
  Logger:LogLootItem(looterMember.displayName, lootedByPlayer, itemLink, quantity, totalValue, lootType, priceSourceLabel)

  if lootedByPlayer and IsGuttableFishItem(itemLink) then
    self:ClaimLocalFishSlotForSession(normalizedItemName, quantity)
  end
end

function Loot:OnSyncedLootReceived(data, unitTag)
  if data == nil or not Settings:TrackGroupLoot() then
    return
  end
  if not self:ShouldTrackSyncedData(data) then
    return
  end

  local memberKey, looterMember = GetSyncedMember(data.senderCharacterName, data.senderDisplayName)
  if memberKey == nil or looterMember == nil then
    return
  end

  local quantity = tonumber(data.quantity) or 1
  local trackedItem, resolvedItemValue, resolvedPriceSourceKey, resolvedPriceSourceLabel = ResolveSyncedTrackedItem(data)
  local syncKind = tonumber(data.syncKind) or SYNC_KIND_DELTA
  if type(trackedItem) == 'string' and zo_plainstrfind(trackedItem, '|H') == 1 then
    RememberKnownItemLink(trackedItem)
  end

  if quantity == 0 then
    return
  end

  if syncKind == SYNC_KIND_FISH_STACK_STATE then
    self:ApplySyncedFishStackState(memberKey, trackedItem, resolvedItemValue, quantity, data)
    return
  elseif syncKind == SYNC_KIND_FISH_STACK_DELTA then
    data.priceSourceKey = resolvedPriceSourceKey
    data.priceSourceLabel = resolvedPriceSourceLabel
    self:AdjustLootedItem(memberKey, trackedItem, resolvedItemValue, quantity)
    self:RememberSyncedFishSlot(memberKey, trackedItem, resolvedItemValue, data)
    LogSyncedLoot(looterMember.displayName, trackedItem, quantity, resolvedItemValue, data.lootType, resolvedPriceSourceLabel)
    return
  end

  if quantity > 0 then
    self:AddNewLootedItem(memberKey, trackedItem, resolvedItemValue, quantity)
    LogSyncedLoot(looterMember.displayName, trackedItem, quantity, resolvedItemValue, data.lootType, resolvedPriceSourceLabel)
  else
    self:AdjustLootedItem(memberKey, trackedItem, resolvedItemValue, quantity)
    LogSyncedLoot(looterMember.displayName, trackedItem, quantity, resolvedItemValue, data.lootType, resolvedPriceSourceLabel)
  end
end

function Loot:GetSyncedFishSlotState(memberKey, bagId, slotIndex)
  local memberSlots = trackedSyncedFishSlots[memberKey]
  if memberSlots == nil then
    return nil
  end
  return memberSlots[BuildBagSlotKey(bagId, slotIndex)]
end

function Loot:RememberSyncedFishSlot(memberKey, itemLink, itemValue, data)
  local bagId = tonumber(data.bagId) or 0
  local slotIndex = tonumber(data.slotIndex) or 0
  if bagId <= 0 and slotIndex <= 0 then
    return
  end

  local claimedCount = tonumber(data.claimedCount) or 0
  local memberSlots = trackedSyncedFishSlots[memberKey]
  if memberSlots == nil then
    memberSlots = {}
    trackedSyncedFishSlots[memberKey] = memberSlots
  end

  local slotKey = BuildBagSlotKey(bagId, slotIndex)
  if claimedCount <= 0 then
    memberSlots[slotKey] = nil
    return
  end

  memberSlots[slotKey] = {
    itemLink = itemLink,
    itemValue = itemValue,
    priceSourceKey = data.priceSourceKey,
    priceSourceLabel = data.priceSourceLabel,
    claimedCount = claimedCount
  }
end

function Loot:ApplySyncedFishStackState(memberKey, itemLink, itemValue, caughtQuantity, data)
  local bagId = tonumber(data.bagId) or 0
  local slotIndex = tonumber(data.slotIndex) or 0
  if bagId <= 0 and slotIndex <= 0 then
    return
  end

  local previousState = self:GetSyncedFishSlotState(memberKey, bagId, slotIndex)
  local previousClaimedCount = previousState ~= nil and (previousState.claimedCount or 0) or 0
  local currentClaimedCount = tonumber(data.claimedCount) or 0
  local correctionDelta = currentClaimedCount - previousClaimedCount - math.max(tonumber(caughtQuantity) or 0, 0)

  self:RememberSyncedFishSlot(memberKey, itemLink, itemValue, data)

  if correctionDelta > 0 then
    self:AddNewLootedItem(memberKey, itemLink, itemValue, correctionDelta)
    local looterMember = Members:GetMember(memberKey)
    if looterMember ~= nil then
      Logger:LogStackFound(looterMember.displayName, false, itemLink, correctionDelta, itemValue * correctionDelta, data.lootType or LOOT_TYPE_ITEM, data.priceSourceLabel)
    end
  elseif correctionDelta < 0 then
    self:AdjustLootedItem(memberKey, itemLink, itemValue, correctionDelta)
  end
end

function Loot:AddNewLootedItem(memberName, itemLink, itemValue, count)
  local itemDetails = Members:GetItemForMember(memberName, itemLink)
  if itemDetails == nil then
    itemDetails = FarmingPartyPlus.MemberItem:New(itemLink)
  end
  itemDetails = FarmingPartyPlus.MemberItem:UpdateItemCount(itemDetails, itemValue, count)
  Members:SetItemForMember(memberName, itemLink, itemDetails)
  Members:UpdateTotalValueAndSetBestItem(memberName, itemDetails, itemValue * count)
end

function Loot:AdjustLootedItem(memberName, itemLink, itemValue, count)
  local itemDetails = Members:GetItemForMember(memberName, itemLink)
  if itemDetails == nil then
    return
  end

  itemDetails = FarmingPartyPlus.MemberItem:UpdateItemCount(itemDetails, itemValue, count)
  if itemDetails.count <= 0 then
    Members:DeleteItemForMember(memberName, itemLink)
  else
    Members:SetItemForMember(memberName, itemLink, itemDetails)
  end
  Members:RebuildMemberTotals(memberName)
end

function Loot:OnInventorySlotUpdated(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
  if not IsBackpackSlot(bagId) or not Settings:TrackSelfLoot() then
    return
  end

  local slotKey = BuildBagSlotKey(bagId, slotIndex)
  local trackedSlot = trackedLocalFishSlots[slotKey]
  local countDelta = tonumber(stackCountChange) or 0
  local playerName = zo_strformat(SI_UNIT_NAME, GetUnitName('player'))

  if countDelta > 0 and IsItemStolen ~= nil and IsItemStolen(bagId, slotIndex) then
    local itemLink = GetItemLink(bagId, slotIndex)
    RememberStolenInventoryItem(itemLink, countDelta)
  end

  if trackedSlot ~= nil and countDelta < 0 and Members:HasMember(playerName) then
    local quantityRemoved = math.min(math.abs(countDelta), trackedSlot.claimedCount or math.abs(countDelta))
    self:AdjustLootedItem(playerName, trackedSlot.itemLink, trackedSlot.itemValue, -quantityRemoved)
    Logger:LogLootItem(GetDisplayName(), true, trackedSlot.itemLink, -quantityRemoved, trackedSlot.itemValue * quantityRemoved, LOOT_TYPE_ITEM, trackedSlot.priceSourceLabel)
    trackedSlot.stackCount = math.max((trackedSlot.stackCount or 0) - quantityRemoved, 0)
    trackedSlot.claimedCount = math.max((trackedSlot.claimedCount or 0) - quantityRemoved, 0)
    if trackedSlot.claimedCount == 0 then
      RemoveIndexedSlotKey(trackedLocalFishSlotKeysByItemName, trackedSlot.itemName, slotKey)
      trackedLocalFishSlots[slotKey] = nil
    end
  end

  if countDelta > 0 and Members:HasMember(playerName) then
    local itemLink = GetItemLink(bagId, slotIndex)
    if itemLink ~= nil and itemLink ~= '' then
      local normalizedItemName = NormalizeItemName(itemLink)
      if IsTrackedGuttingOutputName(normalizedItemName) and self:ShouldTrackItem(itemLink, LOOT_TYPE_ITEM) then
        local eventKey = BuildRecentOutputKey(itemLink, countDelta)
        CleanupRecentOutputs(recentLocalGuttingOutputs, GetTimeStamp())
        if recentLocalGuttingOutputs[eventKey] ~= nil then
          recentLocalGuttingOutputs[eventKey] = nil
          self:RememberLocalFishSlot(bagId, slotIndex)
          return
        end
        local itemValue, _, priceSourceLabel = GetPriceDetails(itemLink)
        self:AddNewLootedItem(playerName, itemLink, itemValue, countDelta)
        Logger:LogLootItem(GetDisplayName('player'), true, itemLink, countDelta, itemValue * countDelta, LOOT_TYPE_ITEM, priceSourceLabel)
      end
    end
  end

  self:RememberLocalFishSlot(bagId, slotIndex)
end
