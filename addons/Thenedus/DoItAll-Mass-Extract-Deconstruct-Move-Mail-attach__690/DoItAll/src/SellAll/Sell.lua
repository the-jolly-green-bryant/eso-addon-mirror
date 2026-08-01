DoItAll = DoItAll or {}

local errorMessage = nil

local function MarkItemAsJunkNow(slot)
  local bag  = slot.bagId
  local slot = slot.slotIndex
  if CanItemBeMarkedAsJunk(bag, slot) then
  	SetItemIsJunk(bag, slot, true)
--local itemLink = GetItemLink(bag, slot)
--d("SetItemAsJunk: " .. itemLink)
  end
  return true
end

local function ReportError()
  ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, errorMessage)
end

local function TransferBatch(slotsAll, type)
  local slotsBatch = DoItAll.Slots:New(DoItAll.ItemFilter:New(false))
  if not slotsBatch:Take(slotsAll, DoItAll.Settings.GetBatchSize()) then return end

  if type == "MarkAllAsJunk" then
	  if slotsBatch:ForEach(MarkItemAsJunkNow) then
	    zo_callLater(function() TransferBatch(slotsAll, type) end, DoItAll.Settings.GetBatchDelay())
	  end
  end
end

local function TransferAll(container, type)
  errorMessage = nil

  local slotsAll = DoItAll.Slots:New(DoItAll.ItemFilter:New(false))
  slotsAll:Fill(container)
  TransferBatch(slotsAll, type)

  if errorMessage then ReportError() end
end

function DoItAll.MarkAllAsJunk()
  TransferAll(ZO_PlayerInventoryBackpack, "MarkAllAsJunk")
  --d("DoItAll -> MarkAllAsJunk")
end


