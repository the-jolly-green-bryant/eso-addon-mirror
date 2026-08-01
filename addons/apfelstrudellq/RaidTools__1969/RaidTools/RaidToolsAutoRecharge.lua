RaidToolsModules_AutoRecharge = {}
local needs_repair = false
function RaidToolsModules_AutoRecharge.Init()
	zo_callLater(function ()
		if RaidTools.storage.modules.auto_repair_armour then RaidTools.RepairArmour(false, true) end
		if RaidTools.storage.modules.auto_recharge_weapons then RaidTools.ChargeWeapons(0) end
	end, 1000)
	CALLBACK_MANAGER:RegisterCallback("OnBossFightStart", function(boss, hardmode)
		if RaidTools.storage.modules.auto_repair_armour then RaidTools.RepairArmour() end
		if RaidTools.storage.modules.auto_recharge_weapons then RaidTools.ChargeWeapons() end
	end)
end

local to_charge = {
	EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_OFF,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_BACKUP_MAIN
}

function RaidToolsModules_AutoRecharge.OnInventorySlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if bagId ~= BAG_WORN then return end
	if RaidTools.storage.modules.auto_recharge_weapons then 
		if inventoryUpdateReason == 3 and has_value(to_charge, slotId) then 
			RaidTools.ChargeWeapons()
		end
	end
	if RaidTools.storage.modules.auto_repair_armour then 
		if inventoryUpdateReason == 1 and DoesItemHaveDurability(BAG_WORN, slotId) then
			if not IsUnitDead('player') then RaidTools.RepairArmour(slotId) end
		end
	end
end

function RaidToolsModules_AutoRecharge.OnPlayerReincarnated(...)
	if RaidTools.storage.modules.auto_repair_armour then
		zo_callLater(function ()
			RaidTools.RepairArmour()
			RaidTools.ChargeWeapons()
		end, 1500)
	end
end

function RaidToolsModules_AutoRecharge.OnStoreOpened( ... )
	local repair_cost_total = 0
	if RaidTools.storage.modules.auto_repair_at_merchant then
        for slot = 0, GetBagSize(BAG_WORN) do
            local name, condition = GetItemName(BAG_WORN, slot), GetItemCondition(BAG_WORN, slot)
            if name ~= '' and condition < 99 then
                local repair_cost = GetItemRepairCost(BAG_WORN, slot)
                repair_cost_total = repair_cost_total + repair_cost
				RepairItem(BAG_WORN, slot)
			end
		end
		for slot = 0, GetBagSize(BAG_BACKPACK) do
            local name, condition = GetItemName(BAG_BACKPACK, slot), GetItemCondition(BAG_BACKPACK, slot)
            if name ~= '' and condition < 99 then
                local repair_cost = GetItemRepairCost(BAG_BACKPACK, slot)
                repair_cost_total = repair_cost_total + repair_cost
				RepairItem(BAG_BACKPACK, slot)
			end
		end
		if repair_cost_total ~= 0 then RaidTools.BrandedMessage('Repaired items for a total of |c'.. CLR.cancer.hex .. repair_cost_total ..'|r gold') end
	end
end
