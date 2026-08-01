DoItAll = DoItAll or {}
local slots = DoItAll.Slots:New(DoItAll.ItemFilter:New(false))
local addedItems = 0
local cnt = 0

local function IsShowingTrade()
  local tradeScene = SCENE_MANAGER:GetScene("trade")
  return tradeScene.state == SCENE_SHOWN
end

local function FindAddSlot()
	local nextFreeSlotForTrade = ZO_SharedTradeWindow:FindMyNextAvailableSlot()
    --d("FindAddSlot: " .. nextFreeSlotForTrade)
	return nextFreeSlotForTrade
end

local function GetItemsAdded()
    --d("getItemsAdded")
	if not FindAddSlot() then return TRADE_NUM_SLOTS end

	local itemsAddedToTrade = 0
	for i = 1, TRADE_NUM_SLOTS do
		local _, _, stackCount, _ = GetTradeItemInfo(TRADE_ME, i)
		if(stackCount > 0) then
        	itemsAddedToTrade = itemsAddedToTrade + 1
		end
    end

	--d("itemsAddedToTrade: " .. itemsAddedToTrade)
    return itemsAddedToTrade
end

local function RemoveTradeItems(id)
	if id == nil then
		for i = 1, TRADE_NUM_SLOTS do
			TradeRemoveItem(i)
			addedItems = addedItems - 1
		end
    else
		if id < 1 or id > TRADE_NUM_SLOTS then return end
		TradeRemoveItem(id)
		addedItems = addedItems - 1
    end
end

local function checkIsItemAlreadyBeingTraded(inventorySlot)
    if ZO_InventorySlot_GetType(inventorySlot) == SLOT_TYPE_MY_TRADE then
        local _, _, stackCount = GetTradeItemInfo(TRADE_ME, ZO_Inventory_GetSlotIndex(inventorySlot))
        if stackCount > 0 then
--d("checkIsItemAlreadyBeingTraded: True 1")
            return true
        end
    else
        local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
        for i = 1, TRADE_NUM_SLOTS do
            local bagId, slotIndex = GetTradeItemBagAndSlot(TRADE_ME, i)
            if bagId and slotIndex and bagId == bag and slotIndex == index then
--d("checkIsItemAlreadyBeingTraded: True 2")
                return true
            end
        end
    end
--d("checkIsItemAlreadyBeingTraded: False")
    return false
end

local function AddItem(inventorySlot)
--	cnt = cnt + 1
--	d("AddItem: " .. cnt)
	--On first run GetItemsAdded() will be always 0. It does not seem to update properly
	--Only 5 items allowed, one more slot must be empty and current item shouldn't already be added
  	if addedItems >= TRADE_NUM_SLOTS or GetItemsAdded() >= TRADE_NUM_SLOTS then
       return false
    end
	if not checkIsItemAlreadyBeingTraded(inventorySlot) then
	    TradeAddItem(inventorySlot.bagId, inventorySlot.slotIndex)
		addedItems = addedItems + 1
    end
  	return true
end

function DoItAll.RunAddAll()
--	cnt = 0
	--RemoveTradeItems()
    addedItems = GetItemsAdded()
--    d("RunAddAll: addedItems = " .. addedItems)
	if addedItems < TRADE_NUM_SLOTS then
		slots:Fill(ZO_PlayerInventoryBackpack)
		slots:ForEach(AddItem)
	end
end

function DoItAll.AddAll()
  if not IsShowingTrade() then return end
  DoItAll.RunAddAll()
end
