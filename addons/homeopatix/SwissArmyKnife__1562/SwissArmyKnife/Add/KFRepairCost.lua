-- Repair Cost Addon File
-- @author    : Homeo
-- @lastModif : 06/01/2017

--------------------
--- REPAIR COST ----
--------------------
local slots = {
	[EQUIP_SLOT_HEAD]			= ZO_CharacterEquipmentSlotsHead,
	[EQUIP_SLOT_CHEST]			= ZO_CharacterEquipmentSlotsChest,
	[EQUIP_SLOT_SHOULDERS]			= ZO_CharacterEquipmentSlotsShoulder,
	[EQUIP_SLOT_WAIST]			= ZO_CharacterEquipmentSlotsBelt,
	[EQUIP_SLOT_LEGS]			= ZO_CharacterEquipmentSlotsLeg,
	[EQUIP_SLOT_FEET]			= ZO_CharacterEquipmentSlotsFoot,
	[EQUIP_SLOT_HAND]			= ZO_CharacterEquipmentSlotsGlove,
	[EQUIP_SLOT_MAIN_HAND]		= ZO_CharacterEquipmentSlotsMainHand, --Charges
	[EQUIP_SLOT_BACKUP_MAIN]	= ZO_CharacterEquipmentSlotsBackupMain, --Charges
	[EQUIP_SLOT_BACKUP_OFF]		= ZO_CharacterEquipmentSlotsBackupOff, --Armour or charges
	[EQUIP_SLOT_OFF_HAND]		= ZO_CharacterEquipmentSlotsOffHand, --Armour or charges
}

function RepairCost()
	local bagId = BAG_WORN
	local CoutTotal = 0

	local obj_1 = {[1]=-1, [2]=0, [3]="", [4]=0}
	local obj_2 = {[1]=-1, [2]=0, [3]="", [4]=0}
	local obj_3 = {[1]=-1, [2]=0, [3]="", [4]=0}
	local obj_4 = {[1]=-1, [2]=0, [3]="", [4]=0}
	local obj_5 = {[1]=-1, [2]=0, [3]="", [4]=0}
	local obj_6 = {[1]=-1, [2]=0, [3]="", [4]=0}
	local obj_7 = {[1]=-1, [2]=0, [3]="", [4]=0}

	local arm_1 = {[1]=-1, [2]=0, [3]="", [4]=0}
	local arm_2 = {[1]=-1, [2]=0, [3]="", [4]=0}
	local arm_3 = {[1]=-1, [2]=0, [3]="", [4]=0}
	local arm_4 = {[1]=-1, [2]=0, [3]="", [4]=0}

	for slotId in pairs(slots) do
	local charges, maxCharges = GetChargeInfoForItem(bagId, slotId)
		if (DoesItemHaveDurability(bagId, slotId)) then
			--Equipped armour or shield
			local cond = GetItemCondition(bagId, slotId)
			local cost = GetItemRepairCost(bagId, slotId)
			local link = GetItemLink(bagId, slotId)
			local Quality = GetItemLinkQuality(link)
			local ItemIn = GetItemInfo(bagId, slotId)

			if(slotId == 0) then obj_1[1]=cond obj_1[2]=cost obj_1[3]=ItemIn obj_1[4]=Quality end
			if(slotId == 2) then obj_2[1]=cond obj_2[2]=cost obj_2[3]=ItemIn obj_2[4]=Quality end
			if(slotId == 3) then obj_3[1]=cond obj_3[2]=cost obj_3[3]=ItemIn obj_3[4]=Quality end
			if(slotId == 6) then obj_4[1]=cond obj_4[2]=cost obj_4[3]=ItemIn obj_4[4]=Quality end
			if(slotId == 8) then obj_5[1]=cond obj_5[2]=cost obj_5[3]=ItemIn obj_5[4]=Quality end
			if(slotId == 9) then obj_6[1]=cond obj_6[2]=cost obj_6[3]=ItemIn obj_6[4]=Quality end
			if(slotId == 16) then obj_7[1]=cond obj_7[2]=cost obj_7[3]=ItemIn obj_7[4]=Quality end
			CoutTotal = CoutTotal + cost
		elseif (maxCharges > 0) then
			--Weapon with an enchantment, main hand + backup, off hand + backup
			local cond = zo_floor(100/maxCharges*charges)
			local cost = GetItemRepairCost(bagId, slotId)
			local link = GetItemLink(bagId, slotId)
			local Quality = GetItemLinkQuality(link)
			local ItemIn = GetItemInfo(bagId, slotId)

			if(slotId == 4) then arm_1[1]=cond arm_1[2]=cost arm_1[3]=ItemIn arm_1[4]=Quality end
			if(slotId == 5) then arm_2[1]=cond arm_2[2]=cost arm_2[3]=ItemIn arm_2[4]=Quality end
			if(slotId == 20) then arm_3[1]=cond arm_3[2]=cost arm_3[3]=ItemIn arm_3[4]=Quality end
			if(slotId == 21) then arm_4[1]=cond arm_4[2]=cost arm_4[3]=ItemIn arm_4[4]=Quality end
		end
	end
	
	return CoutTotal, obj_1, obj_2, obj_3, obj_4, obj_5, obj_6, obj_7, arm_1, arm_2, arm_3, arm_4
end




