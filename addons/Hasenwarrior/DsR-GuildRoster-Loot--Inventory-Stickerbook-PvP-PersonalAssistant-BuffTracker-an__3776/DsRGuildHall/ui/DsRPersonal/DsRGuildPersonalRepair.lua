-- Create namespace
DsRGuildPersonalRepair = {}
local DsRGuildPersonalRepair = DsRGuildPersonalRepair or {}

DsRGuildPersonalRepair.name = "DsRGuildPersonalRepair"

local repairKits = {}
local soulGems   = {}

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.FindRepairKits()
	repairKits = {}
	local bagId = BAG_BACKPACK
	for slotId = 0, GetBagSize(bagId) do
		if IsItemRepairKit(bagId, slotId) then 
			local tier = GetRepairKitTier(bagId, slotId)
			if not repairKits[tier] then repairKits[tier] = {} end
			repairKits[tier][slotId] = (GetSlotStackSize(bagId, slotId))
		end
	end
	return repairKits
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetItemLevelTier(bagId, slotId)
	return math.floor(GetItemRequiredLevel(bagId, slotId) / 10) + 1
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetRepairKitSlot(repairKitTier)
	if repairKits[repairKitTier] then
		for slotId, count in pairs(repairKits[repairKitTier]) do
			return slotId, count, repairKitTier
		end
	elseif DsRGuildPersonal.ACCconfig.RepairAnyKit then
		while repairKitTier < 6 do
			repairKitTier = repairKitTier + 1
			if repairKits[repairKitTier] then
				for slotId, count in pairs(repairKits[repairKitTier]) do
					return slotId, count, repairKitTier
				end
			end
		end
	end
end 

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.RepairItemWithKit(bagId, slotId)
	local repairKitTier = GetItemLevelTier(bagId, slotId)
	local repaired 		= false
	local itemCondition = GetItemCondition(bagId, slotId)
	local oldCondition 	= itemCondition

	while itemCondition < 100 do
		local repairKitSlot, repairKitCount, repairKitTier = GetRepairKitSlot(repairKitTier)
		if repairKitSlot then
			local repairKitAmount = GetAmountRepairKitWouldRepairItem(bagId, slotId, BAG_BACKPACK, repairKitSlot)
			RepairItemWithRepairKit(bagId, slotId, BAG_BACKPACK, repairKitSlot)
			itemCondition = itemCondition + repairKitAmount
			repairKits = DsRGuildPersonalRepair.FindRepairKits()
			repaired = true
		else
			break
		end
	end

	if repaired and DsRGuildPersonal.ACCconfig.RepairChatOnOff then
		local link = GetItemLink(bagId, slotId)
		if itemCondition >= 100 then
			itemCondition = 100
		end
		d(" |c9fb6cd[DsR-Repair]|r " .. "|c35fc38".. GetString(DsRGuildPersonal_RepairRepaired) .. link:gsub("%^%a+",""))
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.RepairItemsWithKits(threshold)
	threshold = tonumber(threshold) or DsRGuildPersonal.ACCconfig.RepairThreshold

	repairKits = DsRGuildPersonalRepair.FindRepairKits()
	bagId = BAG_WORN
	for slotId = 0, GetBagSize(bagId) do
		if DoesItemHaveDurability(bagId, slotId) then
			local itemName, itemCondition = GetItemName(bagId, slotId), GetItemCondition(bagId, slotId)
			if itemName ~= "" and itemCondition <= threshold then
				DsRGuildPersonalRepair.RepairItemWithKit(bagId, slotId)
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.FindSoulGems()
	soulGems = {}
	local bagId = BAG_BACKPACK

	for slotId = 0, GetBagSize(bagId) do
		if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, bagId, slotId) then 
			local tier = GetSoulGemItemInfo(bagId, slotId)
			if not soulGems[tier] then soulGems[tier] = {} end
			soulGems[tier][slotId] = (GetSlotStackSize(bagId, slotId))
		end
	end
	return soulGems
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function GetSoulGemSlot(soulGemTier)
	if soulGems[soulGemTier] then
		for slotId, count in pairs(soulGems[soulGemTier]) do
			return slotId, count, soulGemTier
		end
	end
end 

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.RechargeItemWithGem(bagId, slotId)
	local recharged 	= false
	local soulGemTier 	= 1
	local itemCharge, itemMaxCharge = GetChargeInfoForItem(bagId, slotId)
	local oldCharge 	= itemCharge

	while itemCharge < itemMaxCharge do
		local soulGemSlot, soulGemCount, soulGemTier = GetSoulGemSlot(soulGemTier)
		if soulGemSlot then
			local chargeAmount = GetAmountSoulGemWouldChargeItem(bagId, slotId, BAG_BACKPACK, soulGemSlot)
			ChargeItemWithSoulGem(bagId, slotId, BAG_BACKPACK, soulGemSlot)
			itemCharge 	= itemCharge + chargeAmount
			soulGems 	= DsRGuildPersonalRepair.FindSoulGems()
			recharged 	= true
		else
			break
		end
	end

	if recharged and DsRGuildPersonal.ACCconfig.RepairChatOnOff then
		local link = GetItemLink(bagId, slotId)
		if itemCharge > itemMaxCharge then
			itemCharge = itemMaxCharge
		end
		d(" |c9fb6cd[DsR-Repair]|r " .. "|c35fc38".. GetString(DsRGuildPersonal_RepairRecharged) .. link:gsub("%^%a+",""))
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.RechargeItemsWithGems(threshold)
	threshold = tonumber(threshold) or DsRGuildPersonal.ACCconfig.RepairrechargeThreshold

	soulGems = DsRGuildPersonalRepair.FindSoulGems()
	for slotId = 0, GetBagSize(BAG_WORN) do
		if IsItemChargeable(BAG_WORN, slotId) then
			local itemName, itemCharge, itemMaxCharge = GetItemName(BAG_WORN, slotId), GetChargeInfoForItem(BAG_WORN, slotId)
			if itemName ~= "" and math.floor(itemCharge / itemMaxCharge * 100) <= threshold then
				DsRGuildPersonalRepair.RechargeItemWithGem(BAG_WORN, slotId)
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.RepairRecharge(threshold)
	DsRGuildPersonalRepair.RepairItemsWithKits(threshold)
	DsRGuildPersonalRepair.RechargeItemsWithGems(threshold)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function AllowRepair()
	if IsUnitDead("player") then return false end
	local usage = DsRGuildPersonal.ACCconfig.RepairMode
	return usage == DsRPersonal_REPAIR_ALWAYS or (usage == DsRPersonal_REPAIR_RAIDING and IsRaidInProgress() and not HasRaidEnded() )
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function AllowRecharge()
	if IsUnitDead("player") then return false end
	local usage = DsRGuildPersonal.ACCconfig.RepairrechargeMode
	return usage == DsRPersonal_REPAIR_ALWAYS or (usage == DsRPersonal_REPAIR_RAIDING and IsRaidInProgress() and not HasRaidEnded() )
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.RepairItemInShop(bagId, slotId)
	local cost = GetItemRepairCost(bagId, slotId)
	local link = GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS)
	if cost > GetCurrentMoney() then
		if (DsRGuildPersonal.ACCconfig.RepairChatOnOff) then
			d(" |c9fb6cd[DsR-Repair]|r " .. "|cfaa0a0" .. GetString(DsRGuildPersonal_RepairCannotAfford) .. link:gsub("%^%a+","") .. GetString(DsRGuildPersonal_RepairFor) .. "|r" .. cost .. zo_iconFormat("/esoui/art/currency/currency_gold.dds", 16, 16))
		end
		return 0
	else
		RepairItem(bagId, slotId)
		if (DsRGuildPersonal.ACCconfig.RepairChatOnOff) then
			d(" |c9fb6cd[DsR-Repair]|r " .. "|c35fc38".. GetString(DsRGuildPersonal_RepairRepaired) .. link:gsub("%^%a+","") .. GetString(DsRGuildPersonal_RepairFor) .. "|r" .. cost .. zo_iconFormat("/esoui/art/currency/currency_gold.dds", 16, 16))
		end
		return cost
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.RepairItemsInShop()
	local totalCost = 0
	local bagId 	= BAG_WORN

	for slotId = 0, GetBagSize(bagId) do
		if DoesItemHaveDurability(bagId, slotId) then
			local itemName = GetItemName(bagId, slotId)
			if itemName ~= "" then
				totalCost = totalCost + DsRGuildPersonalRepair.RepairItemInShop(bagId, slotId)
			end
		end
	end
	if DsRGuildPersonal.ACCconfig.RepairChatOnOff then
		if totalCost > 0 then
			d(" |c9fb6cd[DsR-Repair]|r " .. "|c35fc38".. GetString(DsRGuildPersonal_RepairTotalCost) .. "|r" .. totalCost .. zo_iconFormat("/esoui/art/currency/currency_gold.dds", 16, 16))
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.OnOpenStore()
	if DsRGuildPersonal.ACCconfig.RepairstoreRepairMode == DsRPersonal_REPAIR_ALL then
		local repairCost = GetRepairAllCost()

		if not CanStoreRepair() then return end

		if repairCost < GetCurrentMoney() then
			RepairAll()
			if (DsRGuildPersonal.ACCconfig.RepairChatOnOff) and repairCost > 0 then
				d(" |c9fb6cd[DsR-Repair]|r " .. "|c35fc38" .. GetString(DsRGuildPersonal_RepairTotalGearCost) .. "|r" .. repairCost .. zo_iconFormat("/esoui/art/currency/currency_gold.dds", 16, 16))
			end
		else
			if (DsRGuildPersonal.ACCconfig.RepairChatOnOff) then
				d(" |c9fb6cd[DsR-Repair]|r " .. "|cfaa0a0" .. GetString(DsRGuildPersonal_RepairGearCostAfford) .. "|r" .. repairCost .. zo_iconFormat("/esoui/art/currency/currency_gold.dds", 16, 16))
			end
		end
	elseif DsRGuildPersonal.ACCconfig.RepairstoreRepairMode == DsRPersonal_REPAIR_WORN then
		DsRGuildPersonalRepair.RepairItemsInShop()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.OnPlayerAlive()
	if AllowRepair() then
		DsRGuildPersonalRepair.RepairItemsWithKits()
	end
	if AllowRecharge() then
		DsRGuildPersonalRepair.RechargeItemsWithGems()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.OnInventorySingleSlotUpdate(_, bagId, slotId, isNewItem, _, updateReason)
	if updateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE or updateReason == INVENTORY_UPDATE_REASON_DEFAULT then
		if AllowRepair() and DoesItemHaveDurability(bagId, slotId) then
			local itemName, itemCondition = GetItemName(bagId, slotId), GetItemCondition(bagId, slotId)
			if itemName ~= "" and itemCondition <= DsRGuildPersonal.ACCconfig.RepairThreshold then
				repairKits = DsRGuildPersonalRepair.FindRepairKits()
				DsRGuildPersonalRepair.RepairItemWithKit(bagId, slotId)
			end
		end
	end
	if updateReason == INVENTORY_UPDATE_REASON_ITEM_CHARGE or updateReason == INVENTORY_UPDATE_REASON_DEFAULT then
		if AllowRecharge() and IsItemChargeable(bagId, slotId) then
			local itemName, itemCharge, itemMaxCharge = GetItemName(bagId, slotId), GetChargeInfoForItem(bagId, slotId)
			if itemName ~= "" and math.floor(itemCharge / itemMaxCharge * 100) <= DsRGuildPersonal.ACCconfig.RepairrechargeThreshold then
				soulGems = DsRGuildPersonalRepair.FindSoulGems()
				DsRGuildPersonalRepair.RechargeItemWithGem(bagId, slotId)
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- OnAddOnLoaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPersonalRepair.RepairWorkshop(event, name)
    if DsRGuildPersonal.ACCconfig.RepairOnOff then
	    EVENT_MANAGER:RegisterForEvent(DsRGuildPersonalRepair.Name,  EVENT_OPEN_STORE, DsRGuildPersonalRepair.OnOpenStore)
	    EVENT_MANAGER:RegisterForEvent(DsRGuildPersonalRepair.Name,  EVENT_PLAYER_ALIVE, DsRGuildPersonalRepair.OnPlayerAlive)
	    EVENT_MANAGER:RegisterForEvent(DsRGuildPersonalRepair.Name,  EVENT_INVENTORY_SINGLE_SLOT_UPDATE, DsRGuildPersonalRepair.OnInventorySingleSlotUpdate)
	    EVENT_MANAGER:AddFilterForEvent(DsRGuildPersonalRepair.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    end
end