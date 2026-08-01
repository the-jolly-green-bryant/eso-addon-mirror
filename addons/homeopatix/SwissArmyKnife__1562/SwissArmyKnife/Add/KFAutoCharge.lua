-- AutoCharge Addon File
-- @author    : Homeo
-- @lastModif : 23/09/2017


function AutoRepair()
	local repairCost = GetRepairAllCost()
	if (repairCost > 0 and CanStoreRepair()) then
		if(GetCurrentMoney() > repairCost) then
			RepairAll()
			if(SAK.settings.DISPLAY_REPAIR_TXT == true) then
				d(string.format("%s %s %s", SAK.lang.KF_REPAIR_1, repairCost, SAK.GoldIcon))
			end
		else
			if(SAK.settings.DISPLAY_REPAIR_TXT == true) then
				d(string.format("%s", SAK.lang.KF_REPAIR_2))
			end
		end
	end	
end

local function GetSoulGemSlot()
	local slotIndex, tier = false, 0
	for _,data in pairs(SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)) do
		if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, data.slotIndex) then
			local geminfo = GetSoulGemItemInfo(BAG_BACKPACK, data.slotIndex)
			if geminfo > tier then
				tier = geminfo
				slotIndex = data.slotIndex
			end
		end
	end
	return slotIndex
end

function CheckSeuil(slotId)
	local Val = false

	local cur, curMax = GetChargeInfoForItem(BAG_WORN, slotId)
	local prcent = zo_floor(100/curMax*cur)

	if(prcent <= SAK.settings.SEUIL_CHARGE_AUTO) then
		Val = true
	end
	return Val
end

function AutoCharge()
	for slotId = 0, GetBagSize(BAG_WORN) do
		if IsItemChargeable(BAG_WORN, slotId) then
			if CheckSeuil(slotId) then
				local slotSoulGem = GetSoulGemSlot()
				if slotSoulGem then
					local ItemName = GetItemName(bagId, slotId)
					if(SAK.settings.DISPLAY_RECHARGE_TXT == true) then
						d(zo_strformat("<<1>> <<2>> <<3>> |t100%:100%:<<4>>|t", ItemName, SAK.lang.KF_AUTO_REPA_12, "1", SAK.iconSoulGemFilled_2))
					end
					ChargeItemWithSoulGem(BAG_WORN, slotId, BAG_BACKPACK, slotSoulGem)
				end
			end
		end
	end
end

function AutoActions()
	if(SAK.settings.DISPLAY_JUNK == true) then
		AutoJunkSell()
	end

	if(SAK.settings.DISPLAY_REPAIR == true) then
		AutoRepair()
	end
end