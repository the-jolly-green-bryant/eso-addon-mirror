local StackMaster = ZO_Object:Subclass()

function StackMaster:New()
	return ZO_Object.New(self)
end

function StackMaster:OnInventoryContextMenu(control, ...)
	if not self.StackHandler and control:GetOwningWindow() ~= ZO_TradingHouse then
		if ZO_InventorySlot_IsSplittableType(control) and ZO_InventorySlot_CanSplitItemStack(control) then
			local bag, slot = ZO_Inventory_GetBagAndIndex(control)
			if GetSlotStackSize(bag, slot) > 1 then
				local link = GetItemLink(bag, slot)
				zo_callLater(function() self:AppendToInventoryContextMenu(bag, slot, link) end, 1)
			end
		end
	end
end

function StackMaster:AppendToInventoryContextMenu(bag, slot, link)
	local count = GetSlotStackSize(bag, slot)
	local link = GetItemLink(bag, slot)
	AddCustomMenuItem("|t18:18:/StackMaster/split.dds|t x1", function() self:Split(1, bag, slot, link) end, MENU_ADD_OPTION_LABEL)
	if count > 10 then
		AddCustomMenuItem("|t18:18:/StackMaster/split.dds|t x10", function() self:Split(10, bag, slot, link) end, MENU_ADD_OPTION_LABEL)
	end
	if count > 50 then
		AddCustomMenuItem("|t18:18:/StackMaster/split.dds|t x50", function() self:Split(50, bag, slot, link) end, MENU_ADD_OPTION_LABEL)
	end
	if count > 10 then
		AddCustomMenuItem("|t18:18:/StackMaster/stacks.dds|t x10 each", function() self:Stack(10, bag, slot, link) end, MENU_ADD_OPTION_LABEL)
	end
	if count > 50 then
		AddCustomMenuItem("|t18:18:/StackMaster/stacks.dds|t x50 each", function() self:Stack(50, bag, slot, link) end, MENU_ADD_OPTION_LABEL)
	end
	if count > 100 then
		AddCustomMenuItem("|t18:18:/StackMaster/stacks.dds|t x100 each", function() self:Stack(100, bag, slot, link) end, MENU_ADD_OPTION_LABEL)
	end
	ShowMenu(self)
end

function StackMaster:Split(amount, bag, slot, link)
	local slotLink = GetItemLink(bag, slot)
	local slotStackSize = GetSlotStackSize(bag, slot)
	if slotLink == link and slotStackSize > amount then
		local targetBag = bag
		local targetSlot = FindFirstEmptySlotInBag(targetBag)
		if not targetSlot then
			if targetBag == BAG_BANK then
				targetBag = BAG_SUBSCRIBER_BANK
				targetSlot = FindFirstEmptySlotInBag(targetBag)
			elseif targetBag == BAG_SUBSCRIBER_BANK then
				targetBag = BAG_BANK
				targetSlot = FindFirstEmptySlotInBag(targetBag)
			end
		end
		if targetSlot then
			CallSecureProtected("RequestMoveItem", bag, slot, targetBag, targetSlot, amount)
			PlaySound("Lockpicking_unlocked")
			return true
		end
		PlaySound("Justice_PickpocketFailed")
	end
	return false
end

function StackMaster:Stack(amount, bag, slot, link)
	local iterations = 0
	local stackHandler = function()
		iterations = (iterations or 0) + 1
		if iterations > 200 or not self:Split(amount, bag, slot, link) then
			self.StackHandler = nil
		end
	end
	self.StackHandler = stackHandler
	self:OnSingleSlotUpdate()
end

function StackMaster:OnSingleSlotUpdate()
	local stackHandler = self.StackHandler
	if stackHandler then
		EVENT_MANAGER:RegisterForUpdate("StackMasterStackHandler", 200, function()
			EVENT_MANAGER:UnregisterForUpdate("StackMasterStackHandler")
			if stackHandler then
				stackHandler()
			end
		end)
	end
end

STACK_MASTER = StackMaster:New()
ZO_PreHook("ZO_InventorySlot_ShowContextMenu", function(...) STACK_MASTER:OnInventoryContextMenu(...) end)
EVENT_MANAGER:RegisterForEvent("StackMaster", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) STACK_MASTER:OnSingleSlotUpdate(...) end)