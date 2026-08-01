DoItAll = DoItAll or {}

local errorMessage = nil

local function UnMarkItemFromJunkNow(slot)
    local bag  = slot.bagId
    local slot = slot.slotIndex
    if IsItemJunk(bag, slot) then
        SetItemIsJunk(bag, slot, false)
        --local itemLink = GetItemLink(bag, slot)
        --d("RemoveItemFromJunk: " .. itemLink)
    end
    return true
end

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
  if type == "MarkAllAsJunk" then
      local slotsBatch = DoItAll.Slots:New(DoItAll.ItemFilter:New(false))
      if not slotsBatch:Take(slotsAll, DoItAll.Settings.GetBatchSize()) then return end
	  if slotsBatch:ForEach(MarkItemAsJunkNow) then
	    zo_callLater(function() TransferBatch(slotsAll, type) end, DoItAll.Settings.GetBatchDelay())
      end
  elseif type == "UnMarkAllFromJunk" then
      local slotsBatch = DoItAll.Slots:New()
      if not slotsBatch:Take(slotsAll, DoItAll.Settings.GetBatchSize()) then return end
      if slotsBatch:ForEach(UnMarkItemFromJunkNow) then
          zo_callLater(function() TransferBatch(slotsAll, type) end, DoItAll.Settings.GetBatchDelay())
      end
  end
end

local function TransferAll(container, type)
    errorMessage = nil
    local slotsAll
    if type == "MarkAllAsJunk" then
        slotsAll = DoItAll.Slots:New(DoItAll.ItemFilter:New(false))
    elseif type == "UnMarkAllFromJunk" then
        slotsAll = DoItAll.Slots:New()
    end
    if slotsAll == nil then return false end
    slotsAll:Fill(container)
    TransferBatch(slotsAll, type)

    if errorMessage then ReportError() end
end

function DoItAll.MarkAllAsJunk()
    --Check if we are at a vendor and the inventory is shown
    local isVendorActive    = not ZO_StoreWindow:IsHidden()
    local isPlayerInvShown  = not INVENTORY_FRAGMENT:IsHidden()
    local isBuyBackShown    = not ZO_BuyBack:IsHidden()
    local isRepairShown     = not ZO_RepairWindow:IsHidden()
    local isJunkTabShown    = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK].currentFilter == ITEMFILTERTYPE_JUNK

    if not isVendorActive and not isBuyBackShown and not isRepairShown and not isJunkTabShown and isPlayerInvShown then
        --Vendor tab: Sell
        --Inventory: Not the junk tab
        --d("DoItAll -> MarkAllAsJunk")
        TransferAll(ZO_PlayerInventoryBackpack, "MarkAllAsJunk")

    elseif not isVendorActive and not isBuyBackShown and not isRepairShown and isJunkTabShown and isPlayerInvShown then
        --Vendor tab: Sell
        --Inventory: The junk tab

        --Only if we got any junk in our backpack
        --HasAnyJunk(*integer* _bagId_, *bool* _excludeStolenItems_)
        if HasAnyJunk(BAG_BACKPACK, false) then
            --d("DoItAll -> Un-MarkAllFromJunk")
            TransferAll(ZO_PlayerInventoryBackpack, "UnMarkAllFromJunk")
        end

        --Nützlich ggf:
        -- ITEMFILTERTYPE_JUNK
        --  ** _Returns:_ *bool* _hasJunk_
    end
end


