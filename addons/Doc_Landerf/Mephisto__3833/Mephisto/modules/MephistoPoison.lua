Mephisto = Mephisto or {}
local MP = Mephisto

MP.poison = {}
local MPP = MP.poison
local MPQ = MP.queue

MPP.poisons = {
	CRAFTED = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:138240|h|h",
	CROWN = "|H0:item:79690:6:1:0:0:0:0:0:0:0:0:0:0:0:1:36:0:1:0:0:0|h|h",
}

function MPP.Init()
	MPP.name = MP.name .. "Poison"
	MPP.lastPoison = nil
	MPP.RegisterEvents()
end

function MPP.RegisterEvents()
	if MP.settings.fillPoisons then
		EVENT_MANAGER:RegisterForEvent(MPP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, MPP.OnInventoryChange)
		EVENT_MANAGER:AddFilterForEvent(MPP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
		EVENT_MANAGER:AddFilterForEvent(MPP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
		
		-- wait until ui is loaded
		zo_callLater(function()
			MPP.OnInventoryChange(_, _, EQUIP_SLOT_POISON, _, _, _, _)
			MPP.OnInventoryChange(_, _, EQUIP_SLOT_BACKUP_POISON, _, _, _, _)
		end, 100)
	else
		EVENT_MANAGER:UnregisterForEvent(MPP.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	end
end

function MPP.OnInventoryChange(_, _, slotId, _, _, _, _)
	if slotId == EQUIP_SLOT_POISON or slotId == EQUIP_SLOT_BACKUP_POISON then
		local _, stack, _, _, _, _, _, _ = GetItemInfo(BAG_WORN, slotId) 
		if stack == 1 then
			local lookupLink = GetItemLink(BAG_WORN, slotId, LINK_STYLE_DEFAULT)
			MPP.lastPoison = lookupLink
			return
		end
		if stack == 0 and MPP.lastPoison then
			local task = function()
				if not MPP.lastPoison then
					return
				end
				MPP.EquipPoisons(MPP.lastPoison, slotId)
				MPP.lastPoison = nil
			end
			MPQ.Push(task)
		end
	end
end

function MPP.EquipPoisons(itemLink, slotId)
	local poisonSlots = MPP.GetSlotsByItemLink(itemLink)
	if #poisonSlots == 0 then
		local backupLink = MPP.GetBackupPoison(itemLink)
		if not backupLink then
			MP.Log(GetString(MP_MSG_NOPOISONS), MP.LOGTYPES.ERROR)
			return
		end
		poisonSlots = MPP.GetSlotsByItemLink(backupLink)
		if #poisonSlots == 0 then
			MP.Log(GetString(MP_MSG_NOPOISONS), MP.LOGTYPES.ERROR)
			return
		end
	end
	local poisonStack = poisonSlots[#poisonSlots]
	EquipItem(poisonStack.bag, poisonStack.slot, slotId)
	PlaySound(SOUNDS.DYEING_TOOL_SET_FILL_USED)
end

function MPP.GetSlotsByItemLink(wantedItemLink)
	local itemList = {}
	for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
		local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)
		if itemLink == wantedItemLink then
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

function MPP.GetBackupPoison(itemLink)
	if itemLink == MPP.poisons.CRAFTED then
		return MPP.poisons.CROWN
	elseif itemLink == MPP.poisons.CROWN then
		return MPP.poisons.CRAFTED
	else
		return nil
	end
end