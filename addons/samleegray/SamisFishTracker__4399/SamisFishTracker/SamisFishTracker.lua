local SFT = SamisFishTrackerAddon
local visibility = SFT.constants.visibility
local averageRateUpdateName = SFT.name .. "AverageRate"


local function iterateThroughEntireBag()
  local bagId = BAG_BACKPACK
  local slotIndex = ZO_GetNextBagSlotIndex(bagId, 0)
  local newLinks = {}

  while slotIndex do
    slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)

    local itemLink = GetItemLink(bagId, slotIndex, 1)
    if itemLink and GetItemLinkItemType(itemLink) == ITEMTYPE_FISH then
      newLinks[slotIndex] = itemLink
    end
  end

  SFT.utils.cacheFish(newLinks)
end

function SFT.ConfigureAverageRateAutoUpdate()
  local intervalSeconds = tonumber(SFT.savedVariables.averageRateUpdateIntervalSeconds) or 1
  intervalSeconds = math.max(1, math.min(60, intervalSeconds))
  SFT.savedVariables.averageRateUpdateIntervalSeconds = intervalSeconds

  EVENT_MANAGER:UnregisterForUpdate(averageRateUpdateName)

  if SFT.savedVariables.averageRateAutoUpdateEnabled == false then
    return
  end

  EVENT_MANAGER:RegisterForUpdate(averageRateUpdateName, intervalSeconds * 1000, function()
    SFT.UpdateAverageRateLabel()
  end)
end

function SFT.RestorePosition()
  local left = SFT.savedVariables.left
  local top = SFT.savedVariables.top

  if left == nil or top == nil then
    return
  end

  SamisFishTrackerControl:ClearAnchors()

  SamisFishTrackerControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function SFT.RestoreFilletPosition()
  local left = SFT.savedVariables.filletLeft
  local top = SFT.savedVariables.filletTop

  if left == nil or top == nil then
    return
  end

  SamisFilletTrackerControl:ClearAnchors()
  SamisFilletTrackerControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function SFT.ApplyVisibilitySetting()
  if SFT.savedVariables.visibility == visibility.SHOW then
    SamisFishTrackerControl:SetHidden(false)
  else
    SamisFishTrackerControl:SetHidden(true)
  end
end

function SFT.OnInventoryUpdate(eventCode, itemSoundCategory)
  SFT.RefreshTotals()
  SFT.RefreshStorageLabels()
  -- Sync session count to actual bag count so it reflects current inventory
  SFT.UpdateFishCount(SFT.total_bag)
  SFT.savedVariables.amount = SFT.total_bag

  -- Refresh again after 2 seconds to account for any inventory state settling delay
  zo_callLater(function()
    SFT.RefreshTotals()
    SFT.RefreshStorageLabels()
    SFT.UpdateFishCount(SFT.total_bag)
    SFT.savedVariables.amount = SFT.total_bag
  end, 2000)
end

function SFT.Initialize()
  SFT.fishamount = 0
  SFT.filletCountTotal = 0
  SFT.filletsSinceRoe = 0
  SFT.lastRoeFillets = 0
  SFT.lastRoeRatePercent = 0
  SFT.total_roe_found = 0
  SFT.sessionStartTime = os.time()
  SFT.averageRateCatchHistory = {}

  EVENT_MANAGER:RegisterForEvent(SFT.name, EVENT_LOOT_RECEIVED, SFT.LootReceivedEvent)
  EVENT_MANAGER:RegisterForEvent(SFT.name, EVENT_CLOSE_BANK, SFT.UpdateTotal)
  EVENT_MANAGER:RegisterForEvent(SFT.name, EVENT_INVENTORY_ITEM_USED, SFT.OnInventoryUpdate)
  EVENT_MANAGER:RegisterForEvent(SFT.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SFT.OnInventorySlotUpdate)

  SFT.savedVariables = ZO_SavedVars:NewAccountWide("SamisFishTrackerSavedVariables", 1, nil, {
    amount = 0,
    visibility = visibility.HIDE,
    roeRate = SFT.constants.roeRate,
    enableRoeTracking = true,
    filletCountTotal = 0,
    filletsSinceRoe = 0,
    lastRoeFillets = 0,
    lastRoeRatePercent = 0,
    autoSyncRoeRate = false,
    totalRoeFound = 0,
    showAverageRate = true,
    averageRateAutoUpdateEnabled = true,
    averageRateUpdateIntervalSeconds = 1,
    averageRateUseRollingWindow = true,
    averageRateRollingWindowSeconds = 300,
  })

  SFT.filletCountTotal = tonumber(SFT.savedVariables.filletCountTotal) or 0
  SFT.filletsSinceRoe = tonumber(SFT.savedVariables.filletsSinceRoe) or 0
  SFT.lastRoeFillets = tonumber(SFT.savedVariables.lastRoeFillets) or 0
  SFT.lastRoeRatePercent = tonumber(SFT.savedVariables.lastRoeRatePercent) or 0
  SFT.total_roe_found = tonumber(SFT.savedVariables.totalRoeFound) or 0

  SamisFishTrackerControl:SetHandler("OnMoveStop", function()
    SFT.savedVariables.left = SamisFishTrackerControl:GetLeft()
    SFT.savedVariables.top = SamisFishTrackerControl:GetTop()
  end)

  SFT.RestoreFilletPosition()
  SamisFilletTrackerControl:SetHandler("OnMoveStop", function()
    SFT.savedVariables.filletLeft = SamisFilletTrackerControl:GetLeft()
    SFT.savedVariables.filletTop = SamisFilletTrackerControl:GetTop()
  end)

  SFT.InitializeBackground()
  SFT.settingsInit()
  SFT.RefreshTotals()
  SFT.UpdateFishCount(SFT.savedVariables.amount or 0)
  SFT.RefreshStorageLabels()
  SFT.ApplyVisibilitySetting()
  SFT.RestorePosition()
  SFT.RegisterSlashCommands()
  SFT.ConfigureAverageRateAutoUpdate()
  iterateThroughEntireBag()
end

function SFT.LootReceivedEvent(_, _, itemLink, quantity, _, _, self)
  if not self then
    return
  end

  if not SFT.IsTrackableFish(itemLink) then
    return
  end

  local amount = quantity or 1
  SFT.RecordFishCatch(amount)
  SFT.UpdateFishAmount(amount)
  SFT.savedVariables.amount = SFT.fishamount
  SFT.UpdateAverageRateLabel(true)
end

function SFT.RegisterFilletCount(amount)
  if SFT.IsRoeTrackingEnabled and not SFT.IsRoeTrackingEnabled() then
    return
  end

  local increment = amount or 0
  if increment <= 0 then
    return
  end

  SFT.filletCountTotal = (SFT.filletCountTotal or 0) + increment
  SFT.filletsSinceRoe = (SFT.filletsSinceRoe or 0) + increment
  local totalFillets = SFT.filletCountTotal or 0
  local totalRoeFound = SFT.total_roe_found or 0
  if totalFillets > 0 then
    SFT.lastRoeRatePercent = (totalRoeFound / totalFillets) * 100
  else
    SFT.lastRoeRatePercent = 0
  end
  if SFT.savedVariables.autoSyncRoeRate then
    SFT.savedVariables.roeRate = SFT.lastRoeRatePercent / 100
  end
  SFT.savedVariables.filletCountTotal = SFT.filletCountTotal
  SFT.savedVariables.filletsSinceRoe = SFT.filletsSinceRoe
  SFT.savedVariables.lastRoeRatePercent = SFT.lastRoeRatePercent
  if SFT.UpdateFilletStatsLabel then
    SFT.UpdateFilletStatsLabel()
  end
end

function SFT.OnPerfectRoeFound(amount)
  if SFT.IsRoeTrackingEnabled and not SFT.IsRoeTrackingEnabled() then
    return
  end

  local increment = amount or 0
  if increment <= 0 then
    return
  end

  SFT.total_roe_found = (SFT.total_roe_found or 0) + increment
  local filletsSinceRoe = SFT.filletsSinceRoe or 0
  if filletsSinceRoe > 0 then
    SFT.lastRoeFillets = filletsSinceRoe
    SFT.lastRoeRatePercent = (1 / filletsSinceRoe) * 100
  else
    SFT.lastRoeFillets = 0
  end

  SFT.filletsSinceRoe = 0
  local totalFillets = SFT.filletCountTotal or 0
  if totalFillets > 0 then
    SFT.lastRoeRatePercent = (SFT.total_roe_found / totalFillets) * 100
  else
    SFT.lastRoeRatePercent = 0
  end
  if SFT.savedVariables.autoSyncRoeRate then
    SFT.savedVariables.roeRate = SFT.lastRoeRatePercent / 100
  end
  SFT.savedVariables.totalRoeFound = SFT.total_roe_found
  SFT.savedVariables.filletsSinceRoe = SFT.filletsSinceRoe
  SFT.savedVariables.lastRoeFillets = SFT.lastRoeFillets
  SFT.savedVariables.lastRoeRatePercent = SFT.lastRoeRatePercent
  SFT.RefreshTotals()
  SFT.RefreshStorageLabels()
  if SFT.UpdateFilletStatsLabel then
    SFT.UpdateFilletStatsLabel()
  end
end

function SFT.ResetRoeFilletTracking()
  if SFT.IsRoeTrackingEnabled and not SFT.IsRoeTrackingEnabled() then
    return
  end

  SFT.filletCountTotal = 0
  SFT.filletsSinceRoe = 0
  SFT.lastRoeFillets = 0
  SFT.lastRoeRatePercent = 0
  SFT.total_roe_found = 0

  SFT.savedVariables.filletCountTotal = 0
  SFT.savedVariables.filletsSinceRoe = 0
  SFT.savedVariables.lastRoeFillets = 0
  SFT.savedVariables.lastRoeRatePercent = 0
  SFT.savedVariables.totalRoeFound = 0

  SFT.RefreshTotals()
  SFT.RefreshStorageLabels()
end

function SFT.ApplyLastRoeRateToRoeRateSetting()
  if SFT.IsRoeTrackingEnabled and not SFT.IsRoeTrackingEnabled() then
    return
  end

  local percentValue = tonumber(SFT.lastRoeRatePercent) or 0
  local rateValue = percentValue / 100
  local clampedRate = math.max(0.0001, rateValue)

  SFT.savedVariables.roeRate = clampedRate
  SFT.UpdateFishCount(SFT.fishamount)
  SFT.RefreshStorageLabels()
end

local function handleInventoryAddition(bagId, slotIndex, stackCountChange)
  if bagId == BAG_BACKPACK and stackCountChange > 0 then
    iterateThroughEntireBag()
  end

  local itemLink = GetItemLink(bagId, slotIndex)
  if (not itemLink or itemLink == "") and SFT.utils.getCachedFishItemLink(slotIndex) ~= nil then
    itemLink = SFT.utils.getCachedFishItemLink(slotIndex)
  end

  if not itemLink or itemLink == "" then
    return
  end

  local itemId = GetItemLinkItemId(itemLink)
  if bagId == BAG_VIRTUAL and itemId == SFT.constants.perfectRoeItemId and stackCountChange > 0 then
    SFT.OnPerfectRoeFound(stackCountChange)
    return
  end
end

function SFT.OnInventorySlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason,
                                   stackCountChange)
  if bagId ~= BAG_BACKPACK and bagId ~= BAG_SUBSCRIBER_BANK and bagId ~= BAG_VIRTUAL then
    return
  end

  if stackCountChange > 0 then
    handleInventoryAddition(bagId, slotIndex, stackCountChange)
    return
  end

  if not stackCountChange or stackCountChange == 0 then
    return
  end

  local itemLink = GetItemLink(bagId, slotIndex)
  if (not itemLink or itemLink == "") and SFT.utils.getCachedFishItemLink(slotIndex) ~= nil then
    itemLink = SFT.utils.getCachedFishItemLink(slotIndex)
  end

  if not itemLink or itemLink == "" then
    return
  end

  local isFish = GetItemLinkItemType(itemLink) == ITEMTYPE_FISH

  if isFish and stackCountChange < 0 then
    SFT.RegisterFilletCount(-stackCountChange)
  end

  SFT.utils.cacheItemLink(bagId, slotIndex, itemLink)
end

function SFT.OnAddOnLoaded(_, addonName)
  if addonName ~= SFT.name then
    return
  end

  SFT.Initialize()
  EVENT_MANAGER:UnregisterForEvent(SFT.name, EVENT_ADD_ON_LOADED)

  ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", SFT.ManageInteraction)
  ZO_PreHookHandler(RETICLE.interact, "OnHide", SFT.ManageInteraction)
end

function SFT.ManageInteraction()
  if SFT.savedVariables.visibility ~= visibility.AUTO then
    return
  end

  local action, _, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
  local shouldShow = action and additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE

  SamisFishTrackerControl:SetHidden(not shouldShow)
end

EVENT_MANAGER:RegisterForEvent(SFT.name, EVENT_ADD_ON_LOADED, SFT.OnAddOnLoaded)
