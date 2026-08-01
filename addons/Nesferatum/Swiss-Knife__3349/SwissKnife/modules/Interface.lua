-- Local instances of Global tables
local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKDC = SK.Data.common
local SKDS = SK.Data.scenesData
local WM, EM, FM, FK = WINDOW_MANAGER, EVENT_MANAGER, FENCE_MANAGER, FENCE_KEYBOARD

local bagInfo, bankInfo = "", ""
local newFenceTextControl, newFenceBonusControl

local function composeBagInfo(icon, usedSlots, maxSlots, showFree, usePercentageFree, showColorizedFree)
	local slotsFree = maxSlots - usedSlots
	if slotsFree < 0 then slotsFree = 0 end
	local slotsInfo = usedSlots.." / "..maxSlots
	local freeInfo = ""
	if showFree then
		if usePercentageFree then
			local percentFree = math.ceil(slotsFree * 100 / maxSlots)
			freeInfo = ""..percentFree.."%"
		else
			freeInfo = ""..slotsFree
		end
		if showColorizedFree then
			local normalizedFree = math.ceil(slotsFree * math.log(slotsFree + 1) / math.log(7))
			if normalizedFree > 100 then normalizedFree = 100 end
			local freeInfoColor = ZO_ColorDef:New(SKH.getColor(normalizedFree, 1))
			freeInfo = freeInfoColor:Colorize(freeInfo)
		end
		freeInfo = " / "..freeInfo
	end
	local infoText = icon.." "..slotsInfo..freeInfo
	if slotsFree == 0 then
		infoText = SK.COLOR.RED:Colorize(infoText)
	else
		infoText = SK.COLOR.WHITE:Colorize(infoText)
	end
	return infoText
end

local function calculateSlotInfo(bagId)
	if bagId == BAG_BACKPACK then
		local bagMaxSlots = GetBagSize(BAG_BACKPACK)
		local bagUsedSlots = GetNumBagUsedSlots(BAG_BACKPACK)
		bagInfo = composeBagInfo("|t20:20:/EsoUI/Art/Tooltips/icon_bag.dds|t", bagUsedSlots, bagMaxSlots,
			SK.savedVars.showFreeBagSlots, SK.savedVars.usePercentageFreeBagSlots, SK.savedVars.showColorizedFreeBagSlots)
	end
	local isHouseStore = SKH.isValueInList(SKDC.BAG_HOUSE_BANKS, bagId)
	local isBanks = SKH.isValueInList(SKDC.BAG_BANKS, bagId)
	if isBanks or isHouseStore then
		local bankMaxSlots
		local bankUsedSlots
		if bagId == BAG_GUILDBANK or isHouseStore then
			bankMaxSlots = GetBagSize(bagId)
			bankUsedSlots = GetNumBagUsedSlots(bagId)
		else
			bankMaxSlots = GetBagSize(BAG_BANK)
			bankUsedSlots = GetNumBagUsedSlots(BAG_BANK) + GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK)
			if IsESOPlusSubscriber() then
				bankMaxSlots = bankMaxSlots + GetBagSize(BAG_SUBSCRIBER_BANK)
			end
		end
		bankInfo = composeBagInfo("|t20:20:/esoui/art/tooltips/icon_bank.dds|t", bankUsedSlots, bankMaxSlots,
			SK.savedVars.showFreeBagSlots, SK.savedVars.usePercentageFreeBagSlots, SK.savedVars.showColorizedFreeBagSlots)
	end
end

local function setDefaultBagSlotInfoControls()
	for _, t in pairs(SKDS.FREE_SLOTS_DIALOGUES) do
		for _, v in pairs(t) do
			if v.newTextControl ~= nil then v.newTextControl:SetText("") end
			if v.originTextControl ~= nil then v.originTextControl:SetAlpha(1) end
		end
	end
end

local function setDefaultFenceSlotInfoControls()
	if newFenceTextControl ~= nil then newFenceTextControl:SetText("") end	
	if newFenceBonusControl ~= nil then newFenceBonusControl:SetText("") end
	if ZO_PlayerInventoryInfoBarAltFreeSlots ~= nil then ZO_PlayerInventoryInfoBarAltFreeSlots:SetAlpha(1) end
	if ZO_PlayerInventoryInfoBarAltMoney ~= nil then ZO_PlayerInventoryInfoBarAltMoney:SetAlpha(1) end
end

local function updateSingleBagInfo(data, text)
	for k, v in pairs(data) do
		if v.newTextControl ~= nil then v.newTextControl:SetText(text) end
		if v.originTextControl ~= nil then v.originTextControl:SetAlpha(0) end
	end
end

local function updateBagInfo(bagId)
	calculateSlotInfo(bagId)
	if bagId == BAG_BACKPACK then
		updateSingleBagInfo(SKDS.FREE_SLOTS_DIALOGUES.inventory, bagInfo)
	elseif SKH.isValueInList(SKDC.BAG_BANKS, bagId) or SKH.isValueInList(SKDC.BAG_HOUSE_BANKS, bagId) then
		updateSingleBagInfo(SKDS.FREE_SLOTS_DIALOGUES.bank, bankInfo)
	end
end

local function updateSlotInfoOffset()
	local offsetXBagSecondLine = -8
	local offsetXFenceSecondLine = -8
	if PP ~= nil then
		if SK.savedVars.showFreeBagSlots then
			if SK.savedVars.usePercentageFreeBagSlots then
				offsetXFenceSecondLine = 40
				offsetXBagSecondLine = 40
			else
				offsetXFenceSecondLine = 34
				offsetXBagSecondLine = 34
			end
		end
	end
	for tk, t in pairs(SKDS.FREE_SLOTS_DIALOGUES) do
		for _, v in pairs(t) do
			if v.newTextControl ~= nil then
				v.newTextControl:ClearAnchors()
				if tk == "bank" then
					v.newTextControl:SetAnchor(LEFT, v.originTextControl, LEFT, offsetXBagSecondLine, 0)
				else
					v.newTextControl:SetAnchor(LEFT, v.originTextControl, LEFT, -8, 0)
				end
			end
		end
	end
	newFenceTextControl:ClearAnchors()
	newFenceTextControl:SetAnchor(LEFT, ZO_PlayerInventoryInfoBarAltFreeSlots, LEFT, offsetXFenceSecondLine, 0)
end

local function UpdateBagHook(code, bagId)
	if not SK.savedVars.replaceBackpackSlotsInfo then return end
	local isHouseStore = SKH.isValueInList(SKDC.BAG_HOUSE_BANKS, bagId)
	local isBanks = SKH.isValueInList(SKDC.BAG_BANKS, bagId)
	if bagId ~= BAG_BACKPACK and not isHouseStore and not isBanks then return end
	updateBagInfo(bagId)
end

local function UpdateInventoryHook(code, bagId)
	UpdateBagHook(code, BAG_BACKPACK)
end

local function UpdateBankHook(code, bagId)
	if not SK.savedVars.replaceBackpackSlotsInfo then return end
	if not SKH.isValueInList(SKDC.BAG_BANKS, bagId) and
			not SKH.isValueInList(SKDC.BAG_HOUSE_BANKS, bagId) then return end
	calculateSlotInfo(bagId)
	updateSingleBagInfo(SKDS.FREE_SLOTS_DIALOGUES.bank, bankInfo)
end

local function UpdateGuildBankHook()
	UpdateBankHook(nil, BAG_GUILDBANK)
end

local function CloseBankHook(code, bagId)
	if not SK.savedVars.replaceBackpackSlotsInfo then return end
	for _, v in pairs(SKDS.FREE_SLOTS_DIALOGUES.bank) do
		v.newTextControl:SetText("")
		v.originTextControl:SetAlpha(1)
	end
end

local function OnEnterSell(totalSells, sellsUsed)
	if not SK.savedVars.replaceFenceSlotsInfo then return end
	ZO_PlayerInventoryInfoBarAltFreeSlots:SetAlpha(0)
	ZO_PlayerInventoryInfoBarAltMoney:SetAlpha(0)
	local fenceInfo = composeBagInfo("|t20:20:/esoui/art/inventory/inventory_stolenitem_icon.dds|t", sellsUsed,
		totalSells, SK.savedVars.showFreeFenceSlots, SK.savedVars.usePercentageFreeFenceSlots,
		SK.savedVars.showColorizedFreeFenceSlots)
	newFenceTextControl:SetText(fenceInfo)
	local hagglingSkillLevel = FM:GetHagglingBonus()
	newFenceBonusControl:SetText(SK.COLOR.LIGHT_YELLOW:Colorize("|t32:32:EsoUI/Art/Vendor/vendor_tabIcon_sell_up.dds|t"..hagglingSkillLevel.."%"))
	newFenceBonusControl:SetAlpha(1)
end

local function OnEnterLaunder(totalLaunders, laundersUsed)
	if not SK.savedVars.replaceFenceSlotsInfo then return end
	ZO_PlayerInventoryInfoBarAltFreeSlots:SetAlpha(0)
	ZO_PlayerInventoryInfoBarAltMoney:SetAlpha(0)
	local fenceInfo = composeBagInfo("|t20:20:/esoui/art/inventory/inventory_stolenitem_icon.dds|t", laundersUsed,
		totalLaunders, SK.savedVars.showFreeFenceSlots, SK.savedVars.usePercentageFreeFenceSlots,
		SK.savedVars.showColorizedFreeFenceSlots)
	newFenceTextControl:SetText(fenceInfo)
	newFenceBonusControl:SetAlpha(0)
end

local function OnFenceStateUpdated(totalSells, sellsUsed, totalLaunders, laundersUsed)
	if not SK.savedVars.replaceFenceSlotsInfo then return end
    if FK:IsLaundering() then
	    OnEnterLaunder(totalLaunders, laundersUsed)
	else
	    OnEnterSell(totalSells, sellsUsed)
    end
end

local function InitBagTweaks()
	for tk, t in pairs(SKDS.FREE_SLOTS_DIALOGUES) do
		for k, v in pairs(t) do
			v.newTextControl = WM:CreateControl("SKSlotInfo_"..tk.."_"..k, v.parentBar, CT_LABEL)
			if v.newTextControl ~= nil then
				v.newTextControl:SetFont("ZoFontGameLargeBold")
			end
		end
	end
	newFenceTextControl = WM:CreateControl("SKFenceInfo", ZO_PlayerInventoryInfoBar, CT_LABEL)
	newFenceTextControl:SetFont("ZoFontGameLargeBold")
	updateSlotInfoOffset()

	newFenceBonusControl = WM:CreateControl("SKFenceBonus", ZO_PlayerInventoryInfoBar, CT_LABEL)
	newFenceBonusControl:SetFont("ZoFontGameLargeBold")
	local offset = 10
	if PP ~= nil then offset = 0 end
	newFenceBonusControl:SetAnchor(RIGHT, ZO_PlayerInventoryInfoBarAltMoney, RIGHT, 0, offset)

	if SK.savedVars.replaceBackpackSlotsInfo then
		updateBagInfo(BAG_BACKPACK)
	else
		setDefaultBagSlotInfoControls()
	end

	if not SK.savedVars.replaceFenceSlotsInfo then
		setDefaultFenceSlotInfoControls()
	end

	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, UpdateBagHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_INVENTORY_FULL_UPDATE, UpdateInventoryHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_MOUNT_INFO_UPDATED, UpdateInventoryHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_INVENTORY_BUY_BAG_SPACE, UpdateInventoryHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_INVENTORY_BOUGHT_BAG_SPACE, UpdateInventoryHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_INVENTORY_BAG_CAPACITY_CHANGED, UpdateInventoryHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_INVENTORY_BUY_BANK_SPACE, UpdateBankHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_INVENTORY_BOUGHT_BANK_SPACE, UpdateBankHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_INVENTORY_BANK_CAPACITY_CHANGED, UpdateBankHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_OPEN_BANK, UpdateBankHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_OPEN_GUILD_BANK, UpdateGuildBankHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_GUILD_BANK_ITEM_ADDED, UpdateGuildBankHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_GUILD_BANK_ITEMS_READY, UpdateGuildBankHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_GUILD_BANK_ITEM_REMOVED, UpdateGuildBankHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_CLOSE_BANK, CloseBankHook)
	EM:RegisterForEvent("SK_EQUIPMENT", EVENT_CLOSE_GUILD_BANK, CloseBankHook)
    FM:RegisterCallback("FenceUpdated", function(totalSells, sellsUsed, totalLaunders, laundersUsed) OnFenceStateUpdated(totalSells, sellsUsed, totalLaunders, laundersUsed) end)
    FM:RegisterCallback("FenceEnterSell", function(totalSells, sellsUsed) OnEnterSell(totalSells, sellsUsed) end)
    FM:RegisterCallback("FenceEnterLaunder", function(totalLaunders, laundersUsed) OnEnterLaunder(totalLaunders, laundersUsed) end)
    FM:RegisterCallback("FenceClosed", function() newFenceTextControl:SetText("") newFenceBonusControl:SetText("") end)
end

local function InitCombatIndicators()
    if SKCI == nil then
        SKCI = SK_CombatIndicators:New()
        SKCI:Initialize()
	end
end

local function InitProtectIndicator()
	if SKPI == nil then
		SKPI = SK_ProtectedIndicator:New()
		SKPI:Initialize()
	    SKPI:SetColor()
		SKPI:SetHidden()
    end
end


-- Export
SK.Interface = {
	InitBagTweaks = InitBagTweaks,
	InitCombatIndicators = InitCombatIndicators,
	InitProtectIndicator = InitProtectIndicator,
	setDefaultBagSlotInfoControls = setDefaultBagSlotInfoControls,
	setDefaultFenceSlotInfoControls = setDefaultFenceSlotInfoControls,
	updateBagInfo = updateBagInfo,
	updateSlotInfoOffset = updateSlotInfoOffset
}
