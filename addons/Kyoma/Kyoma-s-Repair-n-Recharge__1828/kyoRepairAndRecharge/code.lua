local Addon = {}
Addon.Name = "kyoRepairAndRecharge"
Addon.DisplayName = "|cFF5FF5Kyoma's|r Repair 'n Recharge"
Addon.Author = "|cFF5FF5Kyoma|r"
Addon.Version = "1.1"

Addon.Settings = {}
Addon.Defaults = 
{
	storeRepairMode = "All",
	verboseStore = true,

	repairMode = "Raiding",
	repairThreshold = 0,
	useAnyKit = true,
	verboseKits = true,
	
	rechargeMode = "Always",
	rechargeThreshold = 0,
	useAnyGem = true,
	verboseGems = true,
}

local p = function() return end -- this will be replaced when initialized
local c = function() return "" end -- for formatting certain words or numbers in printed text

function Addon:CreateSettingsMenu()

	local LAM = LibStub("LibAddonMenu-2.0")
	local panelData = 
	{
		type = "panel",
		name = self.DisplayName,
		author = self.Author,
		version = self.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsTable = 
	{
		{
			type = "description",
			text = "Auto-use repair kits and soul gems to 'Repair 'n Recharge' your gear.",
		},
		-- Stores
		{
			type = "header",
			name = "|cFF5FF5Stores",
		},
		{
			type = "dropdown", 
			name = "Auto-Repair at Stores", 
			choices = {"All","Worn","None"},
			getFunc = function() return self.Settings.storeRepairMode end,
			setFunc = function(value)   self.Settings.storeRepairMode = value end,
			default = "All", 
		},
		{
			type = "checkbox",
			name = "Print to chat", 
			getFunc = function() return self.Settings.verboseShops end,
			setFunc = function(value)   self.Settings.verboseShops = value end,
			default = true, 
		},

		-- Repair Kits
		{
			type = "header",
			name = "|cFF5FF5Repairing",
		},
		{
			type = "dropdown", 
			name = "Auto-Use Repair Kits",
			choices = {"Always", "Raiding", "Never"},
			getFunc = function() return self.Settings.repairMode end,
			setFunc = function(value)   self.Settings.repairMode = value end,
			default = "Raiding", 
		},
		{
			type = "checkbox", 
			name = "Use any Repair Kit",
			getFunc = function() return self.Settings.anyKit end,
			setFunc = function(value)   self.Settings.anyKit = value end,
			default = true, 
		},
		{
			type = "slider",
			name = "Repair kit threshold",
			min = 0, max = 100, step = 1, 
			getFunc = function() return self.Settings.repairThreshold end,
			setFunc = function(value)   self.Settings.repairThreshold = value end,
			default = 0, 
		},
		{
			type = "checkbox", 
			name = "Print to chat",
			getFunc = function() return self.Settings.verboseKits end,
			setFunc = function(value)   self.Settings.verboseKits = value end,
			default = true, 
		},
		
		--Recharging
		{
			type = "header",
			name = "|cFF5FF5Recharging",
		},
		{
			type = "dropdown",
			name = "Auto-Use Soulgems",
			choices = {"Always", "Raiding", "Never"},
			getFunc = function() return self.Settings.rechargeMode end,
			setFunc = function(value)   self.Settings.rechargeMode = value end,
			default = "Always", 
		},
		{
			type = "checkbox",
			name = "Use any soul gem",
			getFunc = function() return self.Settings.anyGem end,
			setFunc = function(value)   self.Settings.anyGem = value end,
			default = true, 
		},
		{
			type = "slider",
			name = "Recharge threshold",
			min = 0, max = 100, step = 1, 
			getFunc = function() return self.Settings.rechargeThreshold end,
			setFunc = function(value)   self.Settings.rechargeThreshold = value end,
			default = 0, 
		},
		{
			type = "checkbox",
			name = "Print to chat",
			getFunc = function() return self.Settings.verboseGems end,
			setFunc = function(value)   self.Settings.verboseGems = value end,
			default = true, 
		},
	}

	LAM:RegisterAddonPanel(Addon.Name.."_LAM", panelData)
	LAM:RegisterOptionControls(Addon.Name.."_LAM", optionsTable)

end

local DEFAULT_CHAT_COLOR = "|cBDBDBD"
function Addon:Initialize()

	self.Settings = ZO_SavedVars:New("kyoRepairAndRechargeGlobal", 1, nil, self.Defaults)
	self:CreateSettingsMenu()

	EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_OPEN_STORE, Addon.OnOpenStore)
	EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_PLAYER_ALIVE, Addon.OnPlayerAlive)
	EVENT_MANAGER:RegisterForEvent (Addon.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Addon.OnInventorySingleSlotUpdate) -- we only care about worn items, do not filter for updateReason
	EVENT_MANAGER:AddFilterForEvent(Addon.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)  -- because we also want it to trigger when items get equipped

	p = function( msg )
		CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage("|cFF5FF5[R&R] "..DEFAULT_CHAT_COLOR..tostring(msg).."|r" )
	end
	c = function( msg, c1, c2 )
		return ""..(c1 or "|cFFFF29")..tostring(msg)..(c2 or DEFAULT_CHAT_COLOR)
	end

	SLASH_COMMANDS["/repair"]   = Addon.RepairItemsWithKits
	SLASH_COMMANDS["/recharge"] = Addon.RechargeItemsWithGems

end


local repairKits = {}
function Addon.FindRepairKits()
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

local function GetItemLevelTier(bagId, slotId)
	return math.floor(GetItemRequiredLevel(bagId, slotId) / 10) + 1
end

local function GetRepairKitSlot(repairKitTier)
	if repairKits[repairKitTier] then
		for slotId, count in pairs(repairKits[repairKitTier]) do
			return slotId, count, repairKitTier
		end
	elseif Addon.Settings.anyKit then
		--Scan higher tiers first?
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

function Addon.RepairItemWithKit(bagId, slotId)
	local repairKitTier = GetItemLevelTier(bagId, slotId)
	local repaired = false
	local itemCondition = GetItemCondition(bagId, slotId)
	local oldCondition = itemCondition
	while itemCondition < 100 do
		local repairKitSlot, repairKitCount, repairKitTier = GetRepairKitSlot(repairKitTier)
		if repairKitSlot then
			local repairKitAmount = GetAmountRepairKitWouldRepairItem(bagId, slotId, BAG_BACKPACK, repairKitSlot)
			RepairItemWithRepairKit(bagId, slotId, BAG_BACKPACK, repairKitSlot)
			itemCondition = itemCondition + repairKitAmount --GetItemCondition isn't always updated right away (??)
			repairKits = Addon.FindRepairKits()
			repaired = true
		else
			break
		end
	end

	if repaired and Addon.Settings.verboseKits then
		local link = GetItemLink(bagId, slotId)
		if itemCondition > 100 then itemCondition = 100 end
		p("Repaired "..link:gsub("%^%a+","").." from: "..c(oldCondition).."% to: "..c(itemCondition).."%")
	end
end

function Addon.RepairItemsWithKits(threshold)
	threshold = tonumber(threshold) or Addon.Settings.repairThreshold

	repairKits = Addon.FindRepairKits()
	bagId = BAG_WORN
	for slotId = 0, GetBagSize(bagId) do
		if DoesItemHaveDurability(bagId, slotId) then
			local itemName, itemCondition = GetItemName(bagId, slotId), GetItemCondition(bagId, slotId)
			if itemName ~= "" and itemCondition <= threshold then
				Addon.RepairItemWithKit(bagId, slotId)
			end
		end
	end
end

local soulGems = {}
function Addon.FindSoulGems()
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
local function GetSoulGemSlot(soulGemTier)
	if soulGems[soulGemTier] then
		for slotId, count in pairs(soulGems[soulGemTier]) do
			return slotId, count, soulGemTier
		end
	end
end 

function Addon.RechargeItemWithGem(bagId, slotId)
	local recharged = false
	local soulGemTier = 1 --GetItemLevelTier(bagId, slotId) -- Now there are only Grand Soulgems with tier of 1
	local itemCharge, itemMaxCharge = GetChargeInfoForItem(bagId, slotId)
	local oldCharge = itemCharge
	while itemCharge < itemMaxCharge do
		local soulGemSlot, soulGemCount, soulGemTier = GetSoulGemSlot(soulGemTier)
		if soulGemSlot then
			local chargeAmount = GetAmountSoulGemWouldChargeItem(bagId, slotId, BAG_BACKPACK, soulGemSlot)
			ChargeItemWithSoulGem(bagId, slotId, BAG_BACKPACK, soulGemSlot)
			itemCharge = itemCharge + chargeAmount
			soulGems = Addon.FindSoulGems()
			recharged = true
		else
			break
		end
	end

	if recharged and Addon.Settings.verboseGems then
		local link = GetItemLink(bagId, slotId)
		if itemCharge > itemMaxCharge then itemCharge = itemMaxCharge end
		p("Recharged "..link:gsub("%^%a+","").." from: "..c(math.floor(oldCharge / itemMaxCharge * 100)).."% to: "..c(math.floor(itemCharge / itemMaxCharge * 100)).."%" )
	end
end

function Addon.RechargeItemsWithGems(threshold)
	threshold = tonumber(threshold) or Addon.Settings.rechargeThreshold

	soulGems = Addon.FindSoulGems()
	for slotId = 0, GetBagSize(BAG_WORN) do
		if IsItemChargeable(BAG_WORN, slotId) then
			local itemName, itemCharge, itemMaxCharge = GetItemName(BAG_WORN, slotId), GetChargeInfoForItem(BAG_WORN, slotId)
			if itemName ~= "" and math.floor(itemCharge / itemMaxCharge * 100) <= threshold then
				Addon.RechargeItemWithGem(BAG_WORN, slotId)
			end
		end
	end
end

local function AllowRepair()
	if IsUnitDead("player") then return false end
	local usage = Addon.Settings.repairMode
	return usage == "Always" or (usage == "Raiding" and IsRaidInProgress() and not HasRaidEnded() )
end

local function AllowRecharge()
	if IsUnitDead("player") then return false end
	local usage = Addon.Settings.rechargeMode
	return usage == "Always" or (usage == "Raiding" and IsRaidInProgress() and not HasRaidEnded() )
end

function Addon.OnInventorySingleSlotUpdate(_, bagId, slotId, isNewItem, _, updateReason)
	if updateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE or updateReason == INVENTORY_UPDATE_REASON_DEFAULT then
		if AllowRepair() and DoesItemHaveDurability(bagId, slotId) then
			local itemName, itemCondition = GetItemName(bagId, slotId), GetItemCondition(bagId, slotId)
			if itemName ~= "" and itemCondition <= Addon.Settings.repairThreshold then
				repairKits = Addon.FindRepairKits()
				Addon.RepairItemWithKit(bagId, slotId)
			end
		end
	end
	if updateReason == INVENTORY_UPDATE_REASON_ITEM_CHARGE or updateReason == INVENTORY_UPDATE_REASON_DEFAULT then
		if AllowRecharge() and IsItemChargeable(bagId, slotId) then
			local itemName, itemCharge, itemMaxCharge = GetItemName(bagId, slotId), GetChargeInfoForItem(bagId, slotId)
			if itemName ~= "" and math.floor(itemCharge / itemMaxCharge * 100) <= Addon.Settings.rechargeThreshold then
				soulGems = Addon.FindSoulGems()
				Addon.RechargeItemWithGem(bagId, slotId)
			end
		end
	end
end

function Addon.OnPlayerAlive()

	if AllowRepair() then
		Addon.RepairItemsWithKits()
	end
	
	if AllowRecharge() then
		Addon.RechargeItemsWithGems()
	end

end

function Addon.RepairItemInShop(bagId, slotId)
	local cost = GetItemRepairCost(bagId, slotId)
	local link = GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS)
	if cost > GetCurrentMoney() then
		if (Addon.Settings.verboseShops) then
			p("Cannot afford to repair "..link:gsub("%^%a+","").." for: "..c(cost).."g")
		end
		return 0
	else
		RepairItem(bagId, slotId)
		if (Addon.Settings.verboseShops) then
			p("Repaired "..link:gsub("%^%a+","").." for: "..c(cost).."g")
		end
		return cost
	end
end


function Addon.RepairItemsInShop()
	local totalCost = 0
	local bagId = BAG_WORN
	for slotId = 0, GetBagSize(bagId) do
		if DoesItemHaveDurability(bagId, slotId) then
			local itemName = GetItemName(bagId, slotId)
			if itemName ~= "" then
				totalCost = totalCost + Addon.RepairItemInShop(bagId, slotId)
			end
		end
	end
	if Addon.Settings.verboseShops then
		if totalCost == 0 then
			--p("Nothing to repair")
		else
			p("Total repair cost: "..c(totalCost).."g")
		end
	end
end

function Addon.OnOpenStore()

	if Addon.Settings.storeRepairMode == "All" then
		local repairCost = GetRepairAllCost()
		if repairCost <= 0 then
			--if (Addon.Settings.verboseShops) then p("Nothing to repair") end
		elseif repairCost < GetCurrentMoney() then
			RepairAll()
			if (Addon.Settings.verboseShops) then p("All gear repaired for: "..c(repairCost).."g") end
		else
			if (Addon.Settings.verboseShops) then p("Cannot afford repair cost of: "..c(repairCost).."g") end
		end
	elseif Addon.Settings.storeRepairMode == "Worn" then
		Addon.RepairItemsInShop()
	end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= Addon.Name then return end
    EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED)
	Addon:Initialize()
end
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, OnAddonLoaded)


KYO_RNR = Addon