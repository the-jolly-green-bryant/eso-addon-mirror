Mephisto = Mephisto or {}
local MP = Mephisto

MP.repair = {}
local MPR = MP.repair
local MPQ = MP.queue

MPR.REPAIRTHRESHOLD = 15
MPR.REPKITID = GetItemLinkItemId("|H0:item:44879:121:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")

MPR.CHARGETHRESHOLD = 2
MPR.SOULGEMID = GetItemLinkItemId("|H0:item:33271:31:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")
MPR.CHARGEITEMS = {
	EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
	EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

function MPR.Init()
	MPR.name = MP.name .. "Repair"
	MPR.repairName = MPR.name .. "Armor"
	MPR.chargeName = MPR.name .. "Weapons"
	
	MPR.logCooldown = false
	MPR.repairCooldown = {}
	
	MPR.RegisterRepairEvents()
	MPR.RegisterChargeEvents()
end

function MPR.RegisterRepairEvents()
	if MP.settings.repairArmor then
		EVENT_MANAGER:RegisterForEvent(MPR.repairName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, MPR.RepairSingleWithKit) -- during fights
		EVENT_MANAGER:AddFilterForEvent(MPR.repairName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
		EVENT_MANAGER:AddFilterForEvent(MPR.repairName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DURABILITY_CHANGE)
		EVENT_MANAGER:RegisterForEvent(MPR.repairName, EVENT_PLAYER_REINCARNATED, MPR.RepairAllWithKit) -- no longer ghost
		EVENT_MANAGER:RegisterForEvent(MPR.repairName, EVENT_PLAYER_ALIVE, MPR.RepairAllWithKit) -- revive at wayshrine
		EVENT_MANAGER:RegisterForEvent(MPR.repairName, EVENT_OPEN_STORE, MPR.OnOpenStore)
		-- wait until ui is loaded
		zo_callLater(function()
			MPR.RepairAllWithKit()
		end, 100)
	else
		EVENT_MANAGER:UnregisterForEvent(MPR.repairName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(MPR.repairName, EVENT_PLAYER_REINCARNATED)
		EVENT_MANAGER:UnregisterForEvent(MPR.repairName, EVENT_PLAYER_ALIVE)
		EVENT_MANAGER:UnregisterForEvent(MPR.repairName, EVENT_OPEN_STORE)
	end
end

function MPR.RegisterChargeEvents()
	if MP.settings.chargeWeapons then
		EVENT_MANAGER:RegisterForEvent(MPR.chargeName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, MPR.ChargeWeapon)
		EVENT_MANAGER:AddFilterForEvent(MPR.chargeName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
		EVENT_MANAGER:AddFilterForEvent(MPR.chargeName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_ITEM_CHARGE)
		-- wait until ui is loaded
		zo_callLater(function()
			MPR.ChargeAll()
		end, 100)
	else
		EVENT_MANAGER:UnregisterForEvent(MPR.chargeName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	end
end

function MPR.OnOpenStore()
	RepairAll()
end

function MPR.RepairSingleWithKit(_, bagId, slotId, _, _, inventoryUpdateReason, _)
	local task = function()
		local repairKey = string.format("%d%d", bagId, slotId)
		if MPR.repairCooldown[repairKey] then
			return -- event gets triggered 2 times
		end
		if DoesItemHaveDurability(bagId, slotId) then
			local condition = GetItemCondition(bagId, slotId)
			if condition < MPR.REPAIRTHRESHOLD then
				local kitSlots = MPR.GetSlotsByItemId(MPR.REPKITID)
				if #kitSlots == 0 then
					MPR.LogDirty(GetString(MP_MSG_NOREPKITS), MP.LOGTYPES.ERROR)
					return
				end
				local kitStack = kitSlots[#kitSlots]
				RepairItemWithRepairKit(bagId, slotId, kitStack.bag, kitStack.slot)
				MPR.repairCooldown[repairKey] = true
				zo_callLater(function()
					MPR.repairCooldown[repairKey] = nil
				end, 2000)
				--d("Repaired " .. GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT) .. condition)
			end
		end
	end
	MPQ.Push(task)
end

function MPR.RepairAllWithKit()
	if IsUnitDeadOrReincarnating("player") then
		return
	end
	local task = function()
		local kitSlots = MPR.GetSlotsByItemId(MPR.REPKITID)
		for slotIndex = 0, GetBagSize(BAG_WORN) do
			if DoesItemHaveDurability(BAG_WORN, slotIndex) then
				local repairKey = string.format("%d%d", BAG_WORN, slotIndex)
				if MPR.repairCooldown[repairKey] then
					return -- event gets triggered 2 times
				end
				
				local condition = GetItemCondition(BAG_WORN, slotIndex)
				if condition < MPR.REPAIRTHRESHOLD then
					if #kitSlots == 0 then
						MP.Log(GetString(MP_MSG_NOREPKITS), MP.LOGTYPES.ERROR)
						return
					end
					local kitStack = kitSlots[#kitSlots]
					if not kitStack then
						MP.Log(GetString(MP_MSG_NOTENOUGHREPKITS), MP.LOGTYPES.ERROR)
						return
					end
					RepairItemWithRepairKit(BAG_WORN, slotIndex, kitStack.bag, kitStack.slot)
					MPR.repairCooldown[repairKey] = true
					zo_callLater(function()
						MPR.repairCooldown[repairKey] = nil
					end, 2000)
					kitStack.count = kitStack.count - 1
					if kitStack.count <= 0 then
						kitSlots[#kitSlots] = nil
					end
					--d("Repaired " .. GetItemLink(BAG_WORN, slotIndex, LINK_STYLE_DEFAULT) .. condition)
				end
			end
		end
	end
	MPQ.Push(task)
end

function MPR.ChargeWeapon(_, bagId, slotId, _, _, inventoryUpdateReason, _)
	local task = function()
		local itemType = GetItemType(bagId, slotId)
		if IsItemChargeable(bagId, slotId) and itemType == ITEMTYPE_WEAPON then
			local charges, maxCharges = GetChargeInfoForItem(bagId , slotId)
			if charges < MPR.CHARGETHRESHOLD then
				local gemSlots = MPR.GetSlotsByItemId(MPR.SOULGEMID)
				if #gemSlots == 0 then
					MP.Log(GetString(MP_MSG_NOSOULGEMS), MP.LOGTYPES.ERROR)
					return
				end
				local gemStack = gemSlots[#gemSlots]
				ChargeItemWithSoulGem(bagId, slotId, gemStack.bag, gemStack.slot)
				--d("Charged " .. GetItemLink(BAG_WORN, slotId, LINK_STYLE_DEFAULT))
			end
		end
	end
	-- MPQ.Push(task)
	-- since it can be done in combat
	task()
end

function MPR.ChargeAll()
	local task = function()
		local gemSlots = MPR.GetSlotsByItemId(MPR.SOULGEMID)
		for _, gearSlot in ipairs(MPR.CHARGEITEMS) do
			local itemType = GetItemType(BAG_WORN, gearSlot)
			if IsItemChargeable(BAG_WORN, gearSlot) and itemType == ITEMTYPE_WEAPON then
				local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, gearSlot)
				if charges < MPR.CHARGETHRESHOLD then
					if #gemSlots == 0 then
						MP.Log(GetString(MP_MSG_NOSOULGEMS), MP.LOGTYPES.ERROR)
						return
					end
					local gemStack = gemSlots[#gemSlots]
					if gemStack == nil then
						MP.Log(GetString(MP_MSG_NOTENOUGHSOULGEMS), MP.LOGTYPES.ERROR)
						return
					end
					ChargeItemWithSoulGem(BAG_WORN, gearSlot, gemStack.bag, gemStack.slot)
					--d("Charged " .. GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT))
					gemStack.count = gemStack.count - 1
					if gemStack.count <= 0 then
						gemSlots[#gemSlots] = nil
					end
				end
			end
		end
	end
	-- MPQ.Push(task)
	-- since it can be done in combat
	task()
end

function MPR.GetSlotsByItemId(wantedItemId)
	local itemList = {}
	for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
		local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)
		local itemId = GetItemLinkItemId(itemLink)
		if itemId == wantedItemId then
			local _, stack = GetItemInfo(BAG_BACKPACK, slotIndex)
			itemList[#itemList + 1] = {
				bag = BAG_BACKPACK,
				slot = slotIndex,
				count = stack,
			}
		end
	end
	return itemList
end

function MPR.LogDirty(...)
	if not MPR.logCooldown then
		MP.Log(...)
		MPR.logCooldown = true
		zo_callLater(function()
			MPR.logCooldown = false
		end, 1000)
	end
end