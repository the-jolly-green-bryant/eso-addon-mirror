local SFT = SamisFishTrackerAddon
local excludedFishItemIds = SFT.constants.excludedFishItemIds
local perfectRoeItemId = SFT.constants.perfectRoeItemId

function SFT.IsTrackableFish(itemLink)
  if GetItemLinkItemType(itemLink) ~= ITEMTYPE_FISH then
    return false
  end

  return not excludedFishItemIds[GetItemLinkItemId(itemLink)]
end

function SFT.GetBagFishCount()
  local total = 0
  local bagIdPack = BAG_BACKPACK
  local slotBagPack = ZO_GetNextBagSlotIndex(bagIdPack, nil)

  while slotBagPack do
    local itemLink = GetItemLink(bagIdPack, slotBagPack, nil)
    local inventoryCount = GetItemLinkStacks(itemLink)

    if SFT.IsTrackableFish(itemLink) then
      total = total + inventoryCount
    end

    slotBagPack = ZO_GetNextBagSlotIndex(bagIdPack, slotBagPack)
  end

  return total
end

function SFT.GetBankFishCount()
  local total = 0
  local fishies = SHARED_INVENTORY:GenerateFullSlotData(
    function(itemdata)
      return itemdata.itemType == ITEMTYPE_FISH and not excludedFishItemIds[itemdata.itemId]
    end,
    BAG_BANK,
    BAG_SUBSCRIBER_BANK
  )

  for _, item in pairs(fishies) do
    total = total + item.stackCount
  end

  return total
end

function SFT.GetBagPerfectRoeCount()
  local total = 0
  local bagIdPack = BAG_BACKPACK
  local slotBagPack = ZO_GetNextBagSlotIndex(bagIdPack, nil)

  while slotBagPack do
    local itemLink = GetItemLink(bagIdPack, slotBagPack, nil)
    if GetItemLinkItemId(itemLink) == perfectRoeItemId then
      total = total + GetItemLinkStacks(itemLink)
    end

    slotBagPack = ZO_GetNextBagSlotIndex(bagIdPack, slotBagPack)
  end

  return total
end

function SFT.GetBankPerfectRoeCount()
  local total = 0
  local roeItems = SHARED_INVENTORY:GenerateFullSlotData(
    function(itemdata)
      return itemdata.itemId == perfectRoeItemId
    end,
    BAG_BANK,
    BAG_SUBSCRIBER_BANK
  )

  for _, item in pairs(roeItems) do
    total = total + item.stackCount
  end

  return total
end

function SFT.RefreshTotals()
  SFT.total_bag = SFT.GetBagFishCount()
  SFT.total_bank = SFT.GetBankFishCount()
  SFT.total_roe_bag = SFT.GetBagPerfectRoeCount()
  SFT.total_roe_bank = SFT.GetBankPerfectRoeCount()
end

function SFT.UpdateTotal()
  SFT.RefreshTotals()
  SFT.RefreshStorageLabels()
end
