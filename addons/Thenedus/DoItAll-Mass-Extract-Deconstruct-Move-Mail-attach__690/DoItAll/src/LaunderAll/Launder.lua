DoItAll = DoItAll or {}

function DoItAll.IsShowingFence()
  return BACKPACK_FENCE_LAYOUT_FRAGMENT.state == SCENE_SHOWN
end
function DoItAll.IsShowingLaunder()
  return BACKPACK_LAUNDER_LAYOUT_FRAGMENT.state == SCENE_SHOWN
end

local errorMessage = nil
local function FenceItemNow(slot)
  local totalSells, sellsUsed = GetFenceSellTransactionInfo()
  if sellsUsed == totalSells then
    errorMessage = GetString("SI_STOREFAILURE", STORE_FAILURE_AT_FENCE_LIMIT)
	return
  end
  SellInventoryItem(slot.bagId, slot.slotIndex, slot.stackCount)
  return true
end

local function LaunderItemNow(slot)
  local totalLaunders, laundersUsed = GetFenceLaunderTransactionInfo()
  if laundersUsed == totalLaunders then
	  errorMessage = GetString("SI_ITEMLAUNDERRESULT", ITEM_LAUNDER_RESULT_AT_LIMIT)
      return
  end
  LaunderItem(slot.bagId, slot.slotIndex, slot.stackCount)
  return true
end


local function ReportError()
  ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, errorMessage)
end

local function TransferBatch(slotsAll, type)
  local slotsBatch = DoItAll.Slots:New(DoItAll.ItemFilter:New(false))
  if not slotsBatch:Take(slotsAll, DoItAll.Settings.GetBatchSize()) then return end

  if type == "Fence" then
	  if slotsBatch:ForEach(FenceItemNow) then
	    zo_callLater(function() TransferBatch(slotsAll, type) end, DoItAll.Settings.GetBatchDelay())
	  end
  elseif type == "Launder" then
	  if slotsBatch:ForEach(LaunderItemNow) then
	    zo_callLater(function() TransferBatch(slotsAll, type) end, DoItAll.Settings.GetBatchDelay())
	  end
  end
end

local function TransferAll(container, type)
  errorMessage = nil

  --Sort the inventory by the value/price DESCENDING first
  --ZO_PlayerInventorySortByPrice
  --Check if the current sort key is not already the value/price and if it isn't DESCENDING already
  if (ZO_PlayerInventorySortByPrice.sortHeaderGroup:GetCurrentSortKey() == "stackSellPrice" and ZO_PlayerInventorySortByPrice.sortHeaderGroup:GetSortDirection() == ZO_SORT_ORDER_UP)
   or ZO_PlayerInventorySortByPrice.sortHeaderGroup:GetCurrentSortKey() ~= "stackSellPrice" then
	--Switch to the sell price header without any sorting callbacks
  	ZO_PlayerInventorySortByPrice.sortHeaderGroup:SelectHeaderByKey("stackSellPrice", ZO_SortHeaderGroup.SUPPRESS_CALLBACKS)
	--Now execute the sorting callback functions to switch to descending sorting
  	ZO_PlayerInventorySortByPrice.sortHeaderGroup:SelectHeaderByKey("stackSellPrice")
  end

  --REMOVE GLOBAL VARIABLE AGAIN!
  local slotsAll = DoItAll.Slots:New(DoItAll.ItemFilter:New(false))
  slotsAll:Fill(container)
  TransferBatch(slotsAll, type)

  if errorMessage then ReportError() end
end

local function FenceAll()
  TransferAll(ZO_PlayerInventoryBackpack, "Fence")
end

local function LaunderAll()
  TransferAll(ZO_PlayerInventoryBackpack, "Launder")
end

function DoItAll.FenceOrLaunderAll()
  if DoItAll.IsShowingFence() then
	FenceAll()
  elseif DoItAll.IsShowingLaunder() then
    LaunderAll()
  end
end
