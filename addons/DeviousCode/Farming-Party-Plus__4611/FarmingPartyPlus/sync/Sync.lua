local SYNC_PROTOCOL_ID = 391
local SYNC_PROTOCOL_NAME = 'FarmingPartyPlusSyncLoot'
local DUPLICATE_WINDOW_SECONDS = 5
local SENDER_EVENT_NAMESPACE = 'FarmingPartyPlusSyncSender'
local DELTA_BATCH_WINDOW_MS = 3000
local MAX_SYNC_QUANTITY_PER_MESSAGE = 1000
local SYNC_KIND_DELTA = 0
local SYNC_KIND_FISH_STACK_STATE = 1
local SYNC_KIND_FISH_STACK_DELTA = 2
local OBSERVED_SOURCE_NATIVE = 'native'
local OBSERVED_SOURCE_SYNC = 'sync'
local Addon = FarmingPartyPlus

local SyncHost = ZO_Object:Subclass()
local SyncSender = ZO_Object:Subclass()
Addon.Classes.SyncHost = SyncHost
Addon.Classes.SyncSender = SyncSender

local observedEvents = {}
local senderTrackedFishSlots = {}
local senderTrackedFishSlotKeysByItemName = {}
local senderRecentGuttingOutputs = {}

local function NormalizeText(text)
  if text == nil then
    return ''
  end
  return zo_strlower(zo_strformat('<<z:1>>', text))
end

local function GetNormalizedItemNameFromLink(itemLink)
  if itemLink == nil or itemLink == '' then
    return ''
  end
  local itemName = GetItemLinkName(itemLink)
  if itemName == nil or itemName == '' then
    itemName = zo_strformat('<<t:1>>', itemLink)
  end
  return zo_strlower(zo_strformat('<<z:1>>', itemName))
end

local function GetFishingSyncEntryForLink(itemLink)
  return FarmingPartyPlusFishingSyncLookup:GetByNormalizedName(GetNormalizedItemNameFromLink(itemLink))
end

local function BuildEventKey(displayName, itemName, quantity, lootType)
  return table.concat({
    NormalizeText(displayName),
    NormalizeText(itemName),
    tostring(quantity or 0),
    tostring(lootType or 0)
  }, '|')
end

local function CleanupObservedEvents(now)
  for key, eventState in pairs(observedEvents) do
    if now - (eventState.timestamp or 0) > DUPLICATE_WINDOW_SECONDS then
      observedEvents[key] = nil
    end
  end
end

local function GetObservedCountKeys(source)
  if source == OBSERVED_SOURCE_SYNC then
    return 'syncCount', 'nativeCount'
  end
  return 'nativeCount', 'syncCount'
end

local function GetOrCreateObservedEvent(displayName, itemName, quantity, lootType, now)
  local eventKey = BuildEventKey(displayName, itemName, quantity, lootType)
  local eventState = observedEvents[eventKey]
  if eventState == nil then
    eventState = {
      nativeCount = 0,
      syncCount = 0,
      timestamp = now
    }
    observedEvents[eventKey] = eventState
  end

  eventState.timestamp = now
  return eventKey, eventState
end

local function GetObservedEvent(displayName, itemName, quantity, lootType)
  local eventKey = BuildEventKey(displayName, itemName, quantity, lootType)
  return eventKey, observedEvents[eventKey]
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
      and GetNormalizedItemNameFromLink(itemLink) ~= 'fish'
end

local function IsTrackedGuttingOutputName(itemName)
  return itemName == 'fish' or itemName == 'perfect roe'
end

local function BuildRecentOutputKey(itemLink, quantity)
  return string.format('%s|%s', GetNormalizedItemNameFromLink(itemLink), tostring(quantity or 0))
end

local function BuildQueuedDeltaKey(itemCode, quantity, itemValue, syncKind, bagId, slotIndex)
  return table.concat({
    tostring(itemCode or 0),
    quantity >= 0 and 'positive' or 'negative',
    tostring(itemValue or 0),
    tostring(syncKind or SYNC_KIND_DELTA),
    tostring(bagId or 0),
    tostring(slotIndex or 0)
  }, '|')
end

local function CleanupRecentOutputs(now)
  for eventKey, timestamp in pairs(senderRecentGuttingOutputs) do
    if now - timestamp > 2 then
      senderRecentGuttingOutputs[eventKey] = nil
    end
  end
end

function SyncHost:New()
  local obj = ZO_Object.New(self)
  obj:Initialize()
  return obj
end

function SyncSender:New(syncHost)
  local obj = ZO_Object.New(self)
  obj:Initialize(syncHost)
  return obj
end

function SyncSender:Initialize(syncHost)
  self.syncHost = syncHost
  self.enabled = false
  self.pendingSyncDeltas = {}
  self.pendingFlushGeneration = 0

  if syncHost == nil or syncHost.protocol == nil then
    return
  end

  self.enabled = true
  EVENT_MANAGER:RegisterForEvent(SENDER_EVENT_NAMESPACE, EVENT_LOOT_RECEIVED, function(...)
    self:OnLootReceived(...)
  end)
  EVENT_MANAGER:RegisterForEvent(SENDER_EVENT_NAMESPACE, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...)
    self:OnInventorySlotUpdated(...)
  end)
end

function SyncSender:Finalize()
  EVENT_MANAGER:UnregisterForEvent(SENDER_EVENT_NAMESPACE, EVENT_LOOT_RECEIVED)
  EVENT_MANAGER:UnregisterForEvent(SENDER_EVENT_NAMESPACE, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
end

function SyncSender:IsEnabled()
  return self.enabled == true and self.syncHost ~= nil and self.syncHost.protocol ~= nil
end

function SyncSender:ClearSessionState()
  ZO_ClearTable(senderTrackedFishSlots)
  ZO_ClearTable(senderTrackedFishSlotKeysByItemName)
  ZO_ClearTable(senderRecentGuttingOutputs)
  ZO_ClearTable(self.pendingSyncDeltas)
  self.pendingFlushGeneration = 0
end

function SyncSender:RememberFishSlot(bagId, slotIndex)
  if not IsBackpackSlot(bagId) then
    return
  end

  local slotKey = BuildBagSlotKey(bagId, slotIndex)
  local existingTrackedSlot = senderTrackedFishSlots[slotKey]
  local itemLink = GetItemLink(bagId, slotIndex)
  if itemLink == nil or itemLink == '' or not IsGuttableFishItem(itemLink) then
    if existingTrackedSlot ~= nil then
      RemoveIndexedSlotKey(senderTrackedFishSlotKeysByItemName, existingTrackedSlot.itemName, slotKey)
      senderTrackedFishSlots[slotKey] = nil
    end
    return
  end

  local normalizedItemName = GetNormalizedItemNameFromLink(itemLink)
  local syncEntry = FarmingPartyPlusFishingSyncLookup:GetByNormalizedName(normalizedItemName)
  if syncEntry == nil then
    if existingTrackedSlot ~= nil then
      RemoveIndexedSlotKey(senderTrackedFishSlotKeysByItemName, existingTrackedSlot.itemName, slotKey)
      senderTrackedFishSlots[slotKey] = nil
    end
    return
  end
  local preservedClaimedCount = 0
  if existingTrackedSlot ~= nil and existingTrackedSlot.itemName == normalizedItemName then
    preservedClaimedCount = existingTrackedSlot.claimedCount or 0
  elseif existingTrackedSlot ~= nil then
    RemoveIndexedSlotKey(senderTrackedFishSlotKeysByItemName, existingTrackedSlot.itemName, slotKey)
  end

  senderTrackedFishSlots[slotKey] = {
    bagId = bagId,
    slotIndex = slotIndex,
    itemName = normalizedItemName,
    itemCode = syncEntry.code,
    itemLink = itemLink,
    itemValue = FarmingPartyPlus.Price.GetItemPrice(itemLink),
    stackCount = GetSlotStackSize(bagId, slotIndex),
    claimedCount = preservedClaimedCount
  }
  AddIndexedSlotKey(senderTrackedFishSlotKeysByItemName, normalizedItemName, slotKey)
end

function SyncSender:CaptureFishSlotsByName(normalizedItemName)
  local capturedSlotKeys = {}
  local bagSize = GetBagSize(BAG_BACKPACK)
  for slotIndex = 0, bagSize - 1 do
    local slotItemLink = GetItemLink(BAG_BACKPACK, slotIndex)
    if slotItemLink ~= nil and slotItemLink ~= '' and GetNormalizedItemNameFromLink(slotItemLink) == normalizedItemName and IsGuttableFishItem(slotItemLink) then
      self:RememberFishSlot(BAG_BACKPACK, slotIndex)
      capturedSlotKeys[#capturedSlotKeys + 1] = BuildBagSlotKey(BAG_BACKPACK, slotIndex)
    end
  end
  return capturedSlotKeys
end

function SyncSender:ClaimFishSlotForSession(bagId, slotIndex, caughtQuantity)
  if not IsBackpackSlot(bagId) then
    return
  end

  local itemLink = GetItemLink(bagId, slotIndex)
  if itemLink == nil or itemLink == '' or not IsGuttableFishItem(itemLink) then
    return
  end

  local slotKey = BuildBagSlotKey(bagId, slotIndex)
  local trackedSlot = senderTrackedFishSlots[slotKey]
  local claimedCatchQuantity = tonumber(caughtQuantity) or 0
  local normalizedItemName = GetNormalizedItemNameFromLink(itemLink)
  local syncEntry = FarmingPartyPlusFishingSyncLookup:GetByNormalizedName(normalizedItemName)
  if syncEntry == nil then
    return
  end
  local preservedClaimedCount = 0
  if trackedSlot ~= nil and trackedSlot.itemName == normalizedItemName then
    preservedClaimedCount = trackedSlot.claimedCount or 0
  end

  senderTrackedFishSlots[slotKey] = {
    bagId = bagId,
    slotIndex = slotIndex,
    itemName = normalizedItemName,
    itemCode = syncEntry.code,
    itemLink = itemLink,
    itemValue = FarmingPartyPlus.Price.GetItemPrice(itemLink),
    stackCount = GetSlotStackSize(bagId, slotIndex),
    claimedCount = preservedClaimedCount
  }

  self:SendDelta(
    syncEntry.code,
    claimedCatchQuantity,
    FarmingPartyPlus.Price.GetItemPrice(itemLink),
    SYNC_KIND_FISH_STACK_STATE,
    bagId,
    slotIndex,
    senderTrackedFishSlots[slotKey].stackCount
  )
  senderTrackedFishSlots[slotKey].claimedCount = senderTrackedFishSlots[slotKey].stackCount
end

function SyncSender:SendDelta(itemCode, quantity, itemValue, syncKind, bagId, slotIndex, claimedCount)
  if not self:IsEnabled() or quantity == 0 then
    return
  end

  local queuedDeltaKey = BuildQueuedDeltaKey(itemCode, quantity, itemValue, syncKind, bagId, slotIndex)
  local pendingDelta = self.pendingSyncDeltas[queuedDeltaKey]
  if pendingDelta == nil then
    pendingDelta = {
      itemCode = itemCode,
      quantity = 0,
      itemValue = itemValue,
      syncKind = syncKind or SYNC_KIND_DELTA,
      bagId = bagId or 0,
      slotIndex = slotIndex or 0,
      claimedCount = claimedCount or 0
    }
    self.pendingSyncDeltas[queuedDeltaKey] = pendingDelta
  end

  pendingDelta.quantity = (pendingDelta.quantity or 0) + quantity
  pendingDelta.claimedCount = claimedCount or pendingDelta.claimedCount or 0
  if pendingDelta.quantity == 0 then
    self.pendingSyncDeltas[queuedDeltaKey] = nil
  end

  self.pendingFlushGeneration = self.pendingFlushGeneration + 1
  local flushGeneration = self.pendingFlushGeneration
  zo_callLater(function()
    if flushGeneration ~= self.pendingFlushGeneration then
      return
    end
    self:FlushQueuedDeltas()
  end, DELTA_BATCH_WINDOW_MS)
end

function SyncSender:FlushQueuedDeltas()
  if not self:IsEnabled() then
    ZO_ClearTable(self.pendingSyncDeltas)
    return
  end

  for queuedDeltaKey, pendingDelta in pairs(self.pendingSyncDeltas) do
    local remainingQuantity = pendingDelta.quantity or 0
    while remainingQuantity ~= 0 do
      local quantityDirection = remainingQuantity > 0 and 1 or -1
      local chunkQuantity = math.min(math.abs(remainingQuantity), MAX_SYNC_QUANTITY_PER_MESSAGE) * quantityDirection
      self:SendDeltaNow(
        pendingDelta.itemCode,
        chunkQuantity,
        pendingDelta.itemValue,
        pendingDelta.syncKind,
        pendingDelta.bagId,
        pendingDelta.slotIndex,
        pendingDelta.claimedCount
      )
      remainingQuantity = remainingQuantity - chunkQuantity
    end
    self.pendingSyncDeltas[queuedDeltaKey] = nil
  end
end

function SyncSender:SendDeltaNow(itemCode, quantity, itemValue, syncKind, bagId, slotIndex, claimedCount)
  if not self:IsEnabled() or quantity == 0 then
    return
  end

  self.syncHost:SendMeshDelta({
    senderDisplayName = UndecorateDisplayName(GetDisplayName('player')),
    itemCode = itemCode,
    quantity = quantity,
    itemValue = itemValue,
    syncKind = syncKind or SYNC_KIND_DELTA,
    bagId = bagId or 0,
    slotIndex = slotIndex or 0,
    claimedCount = claimedCount or 0
  })
end

function SyncSender:QueueLinkDelta(itemLink, quantity, lootType, syncKind, bagId, slotIndex, claimedCount)
  local syncEntry = GetFishingSyncEntryForLink(itemLink)
  if syncEntry == nil then
    return
  end
  self:SendDelta(
    syncEntry.code,
    quantity,
    FarmingPartyPlus.Price.GetItemPrice(itemLink),
    syncKind,
    bagId,
    slotIndex,
    claimedCount
  )
end

function SyncSender:OnLootReceived(eventCode, name, itemLink, quantity, itemSound, lootType, lootedByPlayer)
  if not self:IsEnabled() or not lootedByPlayer or lootType == LOOT_TYPE_QUEST_ITEM then
    return
  end

  local normalizedItemName = GetNormalizedItemNameFromLink(itemLink)
  if IsTrackedGuttingOutputName(normalizedItemName) then
    local eventKey = BuildRecentOutputKey(itemLink, quantity)
    CleanupRecentOutputs(GetTimeStamp())
    senderRecentGuttingOutputs[eventKey] = GetTimeStamp()
    self:QueueLinkDelta(itemLink, quantity, LOOT_TYPE_ITEM)
    return
  end

  if not IsGuttableFishItem(itemLink) then
    return
  end

  zo_callLater(function()
    local slotKeys = self:CaptureFishSlotsByName(normalizedItemName)
    for _, slotKey in ipairs(slotKeys) do
      local trackedSlot = senderTrackedFishSlots[slotKey]
      if trackedSlot ~= nil then
        self:ClaimFishSlotForSession(trackedSlot.bagId, trackedSlot.slotIndex, quantity)
      end
    end
  end, 0)
end

function SyncSender:OnInventorySlotUpdated(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
  if not self:IsEnabled() or not IsBackpackSlot(bagId) then
    return
  end

  local slotKey = BuildBagSlotKey(bagId, slotIndex)
  local trackedSlot = senderTrackedFishSlots[slotKey]
  local countDelta = tonumber(stackCountChange) or 0

  if trackedSlot ~= nil and countDelta < 0 then
    local quantityRemoved = math.min(math.abs(countDelta), trackedSlot.claimedCount or math.abs(countDelta))
    local remainingClaimedCount = math.max((trackedSlot.claimedCount or 0) - quantityRemoved, 0)
    self:QueueLinkDelta(trackedSlot.itemLink, -quantityRemoved, LOOT_TYPE_ITEM, SYNC_KIND_FISH_STACK_DELTA, bagId, slotIndex, remainingClaimedCount)
    trackedSlot.stackCount = math.max((trackedSlot.stackCount or 0) - quantityRemoved, 0)
    trackedSlot.claimedCount = remainingClaimedCount
    if trackedSlot.claimedCount == 0 then
      RemoveIndexedSlotKey(senderTrackedFishSlotKeysByItemName, trackedSlot.itemName, slotKey)
      senderTrackedFishSlots[slotKey] = nil
    end
  end

  if countDelta > 0 then
    local itemLink = GetItemLink(bagId, slotIndex)
    if itemLink ~= nil and itemLink ~= '' then
      local normalizedItemName = GetNormalizedItemNameFromLink(itemLink)
      if IsTrackedGuttingOutputName(normalizedItemName) then
        local eventKey = BuildRecentOutputKey(itemLink, countDelta)
        CleanupRecentOutputs(GetTimeStamp())
        if senderRecentGuttingOutputs[eventKey] ~= nil then
          senderRecentGuttingOutputs[eventKey] = nil
          self:RememberFishSlot(bagId, slotIndex)
          return
        end
        self:QueueLinkDelta(itemLink, countDelta, LOOT_TYPE_ITEM)
      end
    end
  end

  self:RememberFishSlot(bagId, slotIndex)
end

function SyncHost:Initialize()
  self.enabled = false
  self.protocol = nil
  self.sender = nil

  local lib = LibGroupBroadcast
  if type(lib) ~= 'table' then
    return
  end

  local handler = lib:RegisterHandler('FarmingPartyPlus', 'SyncHost')
  if handler == nil then
    return
  end

  self.protocol = self:DeclareProtocol(handler, lib, SYNC_PROTOCOL_ID, SYNC_PROTOCOL_NAME)
  self.enabled = true
  self.sender = SyncSender:New(self)
end

function SyncHost:DeclareProtocol(handler, lib, protocolId, protocolName)
  local protocol = handler:DeclareProtocol(protocolId, protocolName)
  protocol:AddField(lib.CreateStringField('senderDisplayName', { maxLength = 64 }))
  protocol:AddField(lib.CreateNumericField('itemCode', { numBits = 8 }))
  protocol:AddField(lib.CreateNumericField('quantity', { minValue = -1000, maxValue = 1000 }))
  protocol:AddField(lib.CreateNumericField('itemValue', { numBits = 32 }))
  protocol:AddField(lib.CreateNumericField('syncKind', { numBits = 8 }))
  protocol:AddField(lib.CreateNumericField('bagId', { numBits = 8 }))
  protocol:AddField(lib.CreateNumericField('slotIndex', { numBits = 16 }))
  protocol:AddField(lib.CreateNumericField('claimedCount', { numBits = 16 }))
  protocol:OnData(function(unitTag, data)
    self:OnData(unitTag, data)
  end)
  protocol:Finalize({
    isRelevantInCombat = false,
    replaceQueuedMessages = false
  })
  return protocol
end

function SyncHost:Finalize()
  if self.sender ~= nil and self.sender.Finalize ~= nil then
    self.sender:Finalize()
  end
end

function SyncHost:ClearSessionState()
  ZO_ClearTable(observedEvents)
  if self.sender ~= nil and self.sender.ClearSessionState ~= nil then
    self.sender:ClearSessionState()
  end
end

function SyncHost:IsEnabled()
  return self.enabled == true
end

function SyncHost:SendMeshDelta(data)
  if not self:IsEnabled() or self.protocol == nil or data == nil then
    return false
  end

  self.protocol:Send({
    senderDisplayName = data.senderDisplayName,
    itemCode = data.itemCode or FarmingPartyPlusFishingSyncLookup:GetCodeByNormalizedName(GetNormalizedItemNameFromLink(data.itemLink)),
    quantity = data.quantity,
    itemValue = data.itemValue or 0,
    syncKind = data.syncKind or SYNC_KIND_DELTA,
    bagId = data.bagId or 0,
    slotIndex = data.slotIndex or 0,
    claimedCount = data.claimedCount or 0
  })
  return true
end

function SyncHost:RecordObservedLoot(displayName, itemName, quantity, lootType, source)
  if not self:IsEnabled() then
    return
  end

  local now = GetTimeStamp()
  CleanupObservedEvents(now)
  local _, eventState = GetOrCreateObservedEvent(displayName, itemName, quantity, lootType, now)
  local observedCountKey = GetObservedCountKeys(source)
  eventState[observedCountKey] = (eventState[observedCountKey] or 0) + 1
end

function SyncHost:ConsumeDuplicate(displayName, itemName, quantity, lootType, source)
  if not self:IsEnabled() then
    return false
  end

  local now = GetTimeStamp()
  CleanupObservedEvents(now)
  local eventKey, eventState = GetObservedEvent(displayName, itemName, quantity, lootType)
  if eventState == nil then
    return false
  end

  local _, opposingKey = GetObservedCountKeys(source)
  local remainingCount = eventState[opposingKey] or 0
  if remainingCount <= 0 then
    return false
  end

  eventState[opposingKey] = remainingCount - 1
  eventState.timestamp = now
  if (eventState.nativeCount or 0) <= 0 and (eventState.syncCount or 0) <= 0 then
    observedEvents[eventKey] = nil
  else
    observedEvents[eventKey] = eventState
  end
  return true
end

function SyncHost:OnData(unitTag, data)
  if not self:IsEnabled() then
    return
  end
  if data == nil then
    return
  end

  local senderDisplayName = data.senderDisplayName
  if senderDisplayName == nil or senderDisplayName == '' then
    senderDisplayName = UndecorateDisplayName(GetUnitDisplayName(unitTag or ''))
  end
  if senderDisplayName == nil or senderDisplayName == '' then
    return
  end
  local senderCharacterName = zo_strformat(SI_UNIT_NAME, GetUnitName(unitTag or ''))
  local syncEntry = FarmingPartyPlusFishingSyncLookup:GetByCode(data.itemCode)
  if syncEntry == nil then
    return
  end
  local itemName = syncEntry.name
  local lootType = LOOT_TYPE_ITEM
  local syncKind = tonumber(data.syncKind) or SYNC_KIND_DELTA
  local localDisplayName = UndecorateDisplayName(GetDisplayName('player'))
  if senderDisplayName == localDisplayName then
    return
  end
  if syncKind == SYNC_KIND_DELTA then
    if self:ConsumeDuplicate(senderDisplayName, itemName, data.quantity, lootType, 'sync') then
      return
    end

    self:RecordObservedLoot(senderDisplayName, itemName, data.quantity, lootType, 'sync')
  end

  local memberList = FarmingPartyPlus.Modules.MemberList
  if memberList ~= nil and memberList.MarkHelperActive ~= nil then
    memberList:MarkHelperActive(senderCharacterName, senderDisplayName)
  end

  data.senderCharacterName = senderCharacterName
  data.senderDisplayName = senderDisplayName
  data.itemName = itemName
  data.lootType = lootType
  data.syncKind = syncKind
  local lootModule = FarmingPartyPlus.Modules.Loot
  if lootModule ~= nil then
    lootModule:OnSyncedLootReceived(data, unitTag)
  end
end
