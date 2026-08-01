-- Local instances of Global tables
local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKDE = SK.Data.equipmentData
local SKDC = SK.Data.common
local WM, EM = WINDOW_MANAGER, EVENT_MANAGER

local tooltipsHooks = {
	{ItemTooltip, "SetBagItem", GetItemLink},
	{ItemTooltip, "SetWornItem", SKH.getWornItemLink},
	{ItemTooltip, "SetTradeItem", GetTradeItemLink},
	{ItemTooltip, "SetBuybackItem", GetBuybackItemLink},
	{ItemTooltip, "SetStoreItem", GetStoreItemLink},
	{ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink},
	{ItemTooltip, "SetLootItem", GetLootItemLink},
	{ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink},
	{ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink},
	{ItemTooltip, "SetLink", SKH.returnItemLink},
	{PopupTooltip, "SetLink", SKH.returnItemLink},
}

local orgEnchantString = GetString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED)
local orgEnchantStringMulti = GetString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_MULTI_EFFECT)
local includeQuality = {}
local includeQualityMulti = {}
local subIdToQuality = {}

-- ----------------------------------------------------
-- SK_Apparel
-- ----------------------------------------------------
SK_Apparel = ZO_Object:Subclass()
function SK_Apparel:New(...)
    local object = ZO_Object.New(self)
	self:Initialize(...)
    return object
end

function SK_Apparel:Initialize(controlName, name, bagId, flag)
	self.apparelSlots = {}
	self.bagId = bagId
	self.isShow = false
	self.isDurability = false
	for _, apparelData in pairs(SKDE.EQUIPMENT_SLOTS) do
		if flag == nil or apparelData[3] == flag then
			local equipmentSlot = WM:GetControlByName(controlName..apparelData[2])
		    local apparelSlot = WM:CreateControlFromVirtual("SK_Apparel_"..name.."_Slot"..apparelData[1],
				    equipmentSlot, "SK_Apparel_Slot")
			local controlBG = apparelSlot:GetNamedChild("BG")
			controlBG:SetHidden(true)
			controlBG:SetTexture(SK.savedVars.apparelQualitySlotIcon)
			local controlCondition = apparelSlot:GetNamedChild("Condition")
			controlCondition:SetHidden(true)
			self.apparelSlots[apparelData[1]] = apparelSlot
		end
	end
end

function SK_Apparel:UpdateSlot(_, bag, slot)
	if self.bagId ~= bag then return end
	if self.bagId == BAG_WORN and SKH.isValueInList(SKDE.IGNORE_EQUIPMENT_SLOTS, slot) then return end
	local apparelSlot = self.apparelSlots[slot]
	local apparelSlotTexture = apparelSlot:GetNamedChild("BG")
	local apparelSlotLabel = apparelSlot:GetNamedChild("Condition")
	if GetItemInstanceId(bag, slot) then
		if self.isShow or self.isDurability then
			apparelSlot:SetHidden(false)
			if self.isShow then
				local apparelSlotParent = apparelSlot:GetParent()
				local equipmentSlotHighlight = apparelSlotParent:GetNamedChild("Highlight")
				if equipmentSlotHighlight then
					equipmentSlotHighlight:ClearAnchors()
					equipmentSlotHighlight:SetAnchor(1, apparelSlotParent, 1, 0, 2)
					equipmentSlotHighlight:SetDimensions(52, 52)
					equipmentSlotHighlight:SetTexture(SK.savedVars.apparelQualitySlotHighlightIcon)
					equipmentSlotHighlight:SetDrawLayer(0)
					equipmentSlotHighlight:SetDrawLevel(1)
				end
				apparelSlotTexture:SetColor(SKH.getQuality(GetItemLink(bag, slot), 1))
				apparelSlotTexture:SetHidden(false)
			else
				apparelSlotTexture:SetHidden(true)
			end
			if DoesItemHaveDurability(bag, slot) and self.isDurability then
				local condition = GetItemCondition(bag, slot)
				apparelSlotLabel:SetColor(SKH.getColor(condition, 0.9))
				apparelSlotLabel:SetText(condition.."%")
				apparelSlotLabel:SetHidden(false)
			else
				apparelSlotLabel:SetHidden(true)
			end
		else
			apparelSlot:SetHidden(true)
		end
	else
		apparelSlot:SetHidden(true)
	end
end

function SK_Apparel:UpdateAllSlots()
	for _, apparelData in pairs(SKDE.EQUIPMENT_SLOTS) do
		if self.bagId == BAG_WORN or apparelData[3] then
			self:UpdateSlot(_, self.bagId, apparelData[1])
		end
	end
end

-- ----------------------------------------------------
-- SK_ApparelPlayer SK_ApparelCompanion
-- ----------------------------------------------------
SK_ApparelPlayer = SK_Apparel:Subclass()
SK_ApparelCompanion = SK_Apparel:Subclass()

-- ----------------------------------------------------
--
-- ----------------------------------------------------
local function InitApparelSlots()
	if SKAP == nil then
		SKAP = SK_ApparelPlayer:New("ZO_CharacterEquipmentSlots", "Player", BAG_WORN)
		SKAP.isShow = SK.savedVars.apparelShowQuality
		SKAP.isDurability = SK.savedVars.apparelShowDurability
		zo_callLater(function() SKAP:UpdateAllSlots() end, 200)
	end
	if SK.savedVars.apparelShowQuality or SK.savedVars.apparelShowDurability then
		EM:RegisterForEvent("SK_Event_Condition", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
			function(...) SKAP:UpdateSlot(...) end
		)
	else
		EM:UnregisterForEvent("SK_Event_Condition", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	end
	if SKAC == nil then
		SKAC = SK_ApparelCompanion:New("ZO_CompanionCharacterWindow_Keyboard_TopLevelEquipmentSlots",
				"Companion", BAG_COMPANION_WORN, true)
		SKAC.isShow = SK.savedVars.companionApparelShowQuality
	end
	if SK.savedVars.companionApparelShowQuality then
		EM:RegisterForEvent("SK_Event_Cp_All_Condition", EVENT_COMPANION_ACTIVATED,
			function(...) SKAC:UpdateSlot(...) end
		)
		EM:RegisterForEvent("SK_Event_Cp_Condition", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
			function(...) SKAC:UpdateSlot(...) end
		)
	else
		EM:UnregisterForEvent("SK_Event_Cp_A_Condition", EVENT_COMPANION_ACTIVATED)
		EM:UnregisterForEvent("SK_Event_Cp_Condition", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	end
end

local function UpdateRepair(_, bag)
	if bag ~= BAG_WORN then return end
	local conditionAll, count, allCost, condition, minimalCondition = 0, 0, 0, 0, 100
	for _, c in pairs(SKDE.EQUIPMENT_SLOTS) do
		if DoesItemHaveDurability(BAG_WORN, c[1]) then
			condition = GetItemCondition(BAG_WORN, c[1])
			if condition <= minimalCondition then minimalCondition = condition end
			conditionAll = conditionAll + condition
			allCost = allCost + GetItemRepairCost(BAG_WORN, c[1])
			count = count + 1
		end
	end
	conditionAll = math.floor(conditionAll/count) or 0
	if minimalCondition < 100 then
		minimalCondition = "("..minimalCondition..")"
	else
		minimalCondition = ""
	end
	--SK_RepairIcon:SetColor(SKH.getColor(conditionAll, 1))
	SK_RepairIcon:SetTexture(GetItemInfo(BAG_WORN, EQUIP_SLOT_CHEST))
	local text = ""
	if count ~= 0 then
		text = conditionAll..minimalCondition.."%"
	end
	SK_RepairValue:SetText(text)
	SK_RepairValue:SetColor(SKH.getColor(conditionAll, 1))
	SK_RepairCost:SetText(allCost.." |t12:12:esoui/art/currency/currency_gold.dds|t")
end

local function UpdateCharge(_, bag)
	if bag ~= BAG_WORN then return end
	local slotWeaponCount = GetActiveWeaponPairInfo()
	local weapon1, weapon2, chargeInfo1, chargeInfo2, chargeAll
	if slotWeaponCount == 1 then
		if IsItemChargeable(BAG_WORN, EQUIP_SLOT_MAIN_HAND) then
			chargeInfo1 = {GetChargeInfoForItem(BAG_WORN, EQUIP_SLOT_MAIN_HAND)}
			weapon1 = GetItemInfo(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
		end
		if IsItemChargeable(BAG_WORN, EQUIP_SLOT_OFF_HAND) then
			chargeInfo2 = {GetChargeInfoForItem(BAG_WORN, EQUIP_SLOT_OFF_HAND)}
			weapon2 = GetItemInfo(BAG_WORN, EQUIP_SLOT_OFF_HAND)
		end
	else
		if IsItemChargeable(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN) then
			chargeInfo1 = {GetChargeInfoForItem(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)}
			weapon1 = GetItemInfo(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
		end
		if IsItemChargeable(BAG_WORN, EQUIP_SLOT_BACKUP_OFF) then
			chargeInfo2 = {GetChargeInfoForItem(BAG_WORN, EQUIP_SLOT_BACKUP_OFF)}
			weapon2 = GetItemInfo(BAG_WORN, EQUIP_SLOT_BACKUP_OFF)
		end
	end
	if weapon1 then
		SKH.Show(SK_ChargeLeftHand)
		chargeAll = math.floor(chargeInfo1[1]/chargeInfo1[2]*100)
		SK_ChargeLeftHandIcon:SetTexture(weapon1)
		SK_ChargeLeftHandValue:SetText(chargeAll.."%")
		SK_ChargeLeftHandValue:SetColor(SKH.getColor(chargeAll, 1))
		SK_ChargeLeftHand:SetHidden(false)
	else
		SKH.Hide(SK_ChargeLeftHand)
	end
	if weapon2 then
		SKH.Show(SK_ChargeRightHand)
		chargeAll = math.floor(chargeInfo2[1]/chargeInfo2[2]*100)
		SK_ChargeRightHandIcon:SetTexture(weapon2)
		SK_ChargeRightHandValue:SetText(chargeAll.."%")
		SK_ChargeRightHandValue:SetColor(SKH.getColor(chargeAll, 1))
		SK_ChargeRightHand:SetHidden(false)
	else
		SKH.Hide(SK_ChargeRightHand)
	end
end

local function Swap(_, isSwap)
    if isSwap and not IsBlockActive() then
		UpdateCharge(nil, BAG_WORN)
    end
end

local function InitEquipmentToolbar()
	if SK.savedVars.hideSwapWeapon then
	    SKH.hideSwapWeapon(true)
	end
	if SK.savedVars.hideActionButtonsKeybind then
		local function hideKeybind(...)
			local button = ZO_ActionBar_GetButton(...)
			if button then
				local buttonText = button.slot:GetNamedChild("ButtonText")
				if buttonText then
					buttonText:SetHidden(true)
				end
			end
		end
		for slotIndex = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 do
			hideKeybind(slotIndex)
		end
		if ACTION_BAR_FIRST_UTILITY_BAR_SLOT ~= nil then
			hideKeybind(ACTION_BAR_FIRST_UTILITY_BAR_SLOT + 1)
		else
			local button = QuickslotButton
			if button then
				local buttonText = button:GetNamedChild("ButtonText")
				if buttonText then
					buttonText:SetHidden(true)
				end
			end
		end
		hideKeybind(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, HOTBAR_CATEGORY_COMPANION)
	end
	SK_RepairValue:SetHidden(not SK.savedVars.panelBottomShowRepair)
	SK_RepairCost:SetHidden(not SK.savedVars.panelBottomShowRepair)
	if SK.savedVars.panelBottomShowRepair then
		EM:RegisterForEvent("SK_Event_Repair", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, UpdateRepair)
		UpdateRepair(nil, BAG_WORN)
		SK_RepairValue:SetAnchor(TOP, SK_Repair, BOTTOM, 3, -17)
		SK_RepairValue:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		SKH.Show(SK_Repair)
	else
		EM:UnregisterForEvent("SK_Event_Repair", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		SKH.Hide(SK_Repair)
	end

	SK_ChargeLeftHand:SetHidden(not SK.savedVars.panelBottomShowCharge)
	SK_ChargeRightHand:SetHidden(not SK.savedVars.panelBottomShowCharge)
	if SK.savedVars.panelBottomShowCharge then
		EM:RegisterForEvent("SK_Event_Charge", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, UpdateCharge)
		EM:RegisterForEvent("SK_Event_Swap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, Swap)
		UpdateCharge(nil, BAG_WORN)
		SK_ChargeLeftHandValue:SetAnchor(TOP, SK_ChargeLeftHand, BOTTOM, 3, -17)
		SK_ChargeLeftHandValue:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		SK_ChargeRightHandValue:SetAnchor(TOP, SK_ChargeRightHand, BOTTOM, 3, -17)
		SK_ChargeRightHandValue:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	else
		EM:UnregisterForEvent("SK_Event_Charge", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		EM:UnregisterForEvent("SK_Event_Swap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
		SKH.Hide(SK_ChargeLeftHand)
		SKH.Hide(SK_ChargeRightHand)
	end
end

local function GetEnchantQuality(itemLink)
	local itemId, itemIdSub, enchantSub = itemLink:match("|H[^:]+:item:([^:]+):([^:]+):[^:]+:[^:]+:([^:]+):")
	if not itemId then return 0 end
	enchantSub = tonumber(enchantSub)
	if enchantSub == 0 and not IsItemLinkCrafted(itemLink) then
		local hasSet = GetItemLinkSetInfo(itemLink, false)
		if hasSet then enchantSub = tonumber(itemIdSub) end
	end
	if enchantSub > 0 then
		local quality = subIdToQuality[enchantSub]
		if not quality then
			itemLink = string.format("|H1:item:%i:%i:50:0:0:0:0:0:0:0:0:0:0:0:0:1:1:0:0:10000:0|h|h", itemId, enchantSub)
			quality = GetItemLinkFunctionalQuality(itemLink)
			subIdToQuality[enchantSub] = quality
		end
		return quality
	end
	return 0
end

local function InitEnchantQualityCache()
	local single, multiple = orgEnchantString, orgEnchantStringMulti
	for quality = ITEM_FUNCTIONAL_QUALITY_NORMAL, ITEM_FUNCTIONAL_QUALITY_MAX_VALUE do
		includeQuality[quality] = GetItemQualityColor(quality):Colorize(single)
		includeQualityMulti[quality] = GetItemQualityColor(quality):Colorize(multiple)
	end
end

local function AddUnwantedTooltipData(tooltipControl, itemLink)
	local hasSet, originSetName, _, _, _, setId = GetItemLinkSetInfo(itemLink)
	local junkSetLeftRow, junkSetRightRow, setNameRow, traitNameRow, junkOtherRow = 2, 2, 2, 2, 1
	local r, g, b
	local traitShowing = false
	local isItemUnique = IsItemLinkUnique(itemLink)
	local isItemCrafted = IsItemLinkCrafted(itemLink)
	local isItemSetCollectionPiece = IsItemLinkSetCollectionPiece(itemLink)
	local bindType = GetItemLinkBindType(itemLink)
	local isBound = IsItemLinkBound(itemLink)
	if SK.savedVars.showEnSetNameToo then
		junkSetLeftRow = junkSetLeftRow + 1
		junkSetRightRow = junkSetRightRow + 1
	end
	if isItemUnique then
		junkSetLeftRow = junkSetLeftRow + 1
		junkSetRightRow = junkSetRightRow + 1
		traitNameRow = traitNameRow + 1
		setNameRow = setNameRow + 1
	end
	if SK.savedVars.showEnTraitNameToo and (isItemCrafted or isItemUnique) then
		local traitName = SKH.getTraitName(itemLink)
		local setName = SKH.getSetName(itemLink, true)
		if setName ~= originSetName and traitName ~= nil then
			traitShowing = true
			r, g, b = SK.COLOR.CYAN:UnpackRGB()
			local hasBoundLine = false
			if not hasSet then
				if (isBound and bindType == BIND_TYPE_ON_PICKUP_BACKPACK) or isBound or
						(bindType ~= BIND_TYPE_NONE and bindType ~= BIND_TYPE_UNSET)
				then
					hasBoundLine = true
				end
				if not hasBoundLine then
					traitNameRow = traitNameRow - 1
				end
			end
			tooltipControl:AddHeaderLine(traitName, "ZoFontWinH5", traitNameRow, TOOLTIP_HEADER_SIDE_RIGHT, r, g, b)
		end
	end
	if hasSet then
		local traitName = SKH.getTraitName(itemLink)
		if SK.savedVars.showEnSetNameToo then
			local setName = SKH.getSetName(itemLink, true)
			if setName ~= originSetName then
				if SK.savedVars.showEnTraitNameToo and traitName ~= nil and not (isItemCrafted or isItemUnique) then
					setName = setName.."\n"..SK.COLOR.CYAN:Colorize(traitName)
				end
				local quality = GetItemLinkFunctionalQuality(itemLink)
				r, g, b = SK.QUALITY_MAP[quality]:UnpackRGB()
				tooltipControl:AddHeaderLine(setName, "ZoFontWinT2", setNameRow, TOOLTIP_HEADER_SIDE_LEFT, r, g, b)
			elseif not isItemSetCollectionPiece then
				junkSetLeftRow = junkSetLeftRow - 1
				junkSetRightRow = junkSetRightRow - 1
			end
		end
		if SK.savedVars.junkUnwantedSetsAfterLoot then
			local isSetRuleExisting = SKH.isKeyInTable(SK.globalSV.permanentUnwantedSetIds, setId)
			if isSetRuleExisting then
				r, g, b = ZO_DISABLED_TEXT:UnpackRGB()
				local isJunk = SKH.checkSetJunkConditions(SK.globalSV.permanentUnwantedSetIds[setId], itemLink)
				local isDeconstruct = SKH.checkSetDeconstructConditions(SK.globalSV.permanentUnwantedSetIds[setId], itemLink)
				if isJunk or isDeconstruct then
					r, g, b = SK.COLOR.ORANGE:UnpackRGB()
				end
				tooltipControl:AddHeaderLine(GetString(SI_SK_AUT_LOOT_UNWANTED_SET_EXISTS_TOOLTIP_TEXT),
						"ZoFontWinH5", junkSetLeftRow, TOOLTIP_HEADER_SIDE_LEFT, r, g, b)
				if isDeconstruct then
					tooltipControl:AddHeaderLine(GetString(SI_SK_AUT_UNWANTED_EDIT_SET_DECONSTRUCT_QUALITY_LABEL),
							"ZoFontWinH5", junkSetRightRow, TOOLTIP_HEADER_SIDE_RIGHT, r, g, b)
				elseif not isJunk then
					local mismatchConditionName, mismatchConditionColor  = SKH.getJunkMismatchConditionName(SK.globalSV.permanentUnwantedSetIds[setId], itemLink)
					r, g, b = mismatchConditionColor:UnpackRGB()
					tooltipControl:AddHeaderLine(mismatchConditionName, "ZoFontWinH5", junkSetRightRow, TOOLTIP_HEADER_SIDE_RIGHT, r, g, b)
				elseif isJunk then
					tooltipControl:AddHeaderLine(GetString(SI_SK_AUT_JUNK_LABEL), "ZoFontWinH5", junkSetRightRow, TOOLTIP_HEADER_SIDE_RIGHT, r, g, b)
				end
			end
		end
	elseif not IsItemLinkStolen(itemLink) and (SK.savedVars.junkNonSetEquipments or SK.savedVars.filterUnwantedItemAfterLoot) then
		local isJunkConditions, isDeconstructConditions, isTreasure, isDestroyConditions = SKH.checkUnwantedConditions(itemLink)
		if isJunkConditions or isDeconstructConditions or isTreasure or isDestroyConditions then
			local text = GetString(SI_SK_AUT_JUNK_LABEL)
			r, g, b = SK.COLOR.ORANGE:UnpackRGB()
			if (isBound and bindType == BIND_TYPE_ON_PICKUP_BACKPACK) or isBound or
				(bindType ~= BIND_TYPE_NONE and bindType ~= BIND_TYPE_UNSET)
			then
				junkOtherRow = junkOtherRow + 1
			end
			if traitShowing then
				junkOtherRow = junkOtherRow + 1
			end
			if SK.savedVars.filterUnwantedItemAfterLoot and (isJunkConditions or isDestroyConditions) then
				if isDestroyConditions then
					r, g, b = SK.COLOR.RED:UnpackRGB()
					text = GetString(SI_SK_AUT_UNWANTED_DESTROY_ACTION_NAME)
				else
					text = GetString(SI_SK_AUT_UNWANTED_JUNK_ACTION_NAME)
				end
				tooltipControl:AddHeaderLine(text, "ZoFontWinH5", junkOtherRow, TOOLTIP_HEADER_SIDE_RIGHT, r, g, b)
			elseif SK.savedVars.junkNonSetEquipments and (isJunkConditions or isDeconstructConditions or isTreasure) then
				if isDeconstructConditions then
					text = GetString(SI_SK_AUT_JUNK_NON_SET_DECONSTRUCT_LABEL)
				end
				tooltipControl:AddHeaderLine(text, "ZoFontWinH5", junkOtherRow, TOOLTIP_HEADER_SIDE_RIGHT, r, g, b)
			end
		end
	end
end

local function AddSendMailItemTooltipData(tooltipControl, itemLink)
	local hasSet = GetItemLinkSetInfo(itemLink)
	if SK.savedVars.sendMailToAnotherAccount and not hasSet then
		if SKH.isItemMustBeSendByEmail(itemLink) then
			local textRow = 1
			local r, g, b = SK.COLOR.GREEN:UnpackRGB()
			tooltipControl:AddHeaderLine(GetString(SI_SK_AUT_SENDING_ITEM_TOOLTIP_HEADER),
				"ZoFontWinH5", textRow, TOOLTIP_HEADER_SIDE_RIGHT, r, g, b)
		end
	end
end

local function AddStolenItemTooltipData(tooltipControl, itemLink, bagId, slotIndex, sellCost)
	local r, g, b
	local textRow = 1
	local side = TOOLTIP_HEADER_SIDE_RIGHT
	if IsItemLinkBound(itemLink) or GetItemLinkBindType(itemLink) then textRow = 2 end
	if SKH.isItemForLaunder(nil, nil, itemLink) then
		r, g, b = SK.COLOR.GREEN:UnpackRGB()
		tooltipControl:AddHeaderLine(GetString(SI_SK_AUT_STOLEN_LAUNDER_HEADER),
			"ZoFontWinH5", textRow, side, r, g, b)
	elseif SKH.isStolenItemForDestroy(bagId, slotIndex, itemLink, sellCost) then
		r, g, b = SK.COLOR.RED:UnpackRGB()
		tooltipControl:AddHeaderLine(GetString(SI_SK_AUT_STOLEN_DESTROY_HEADER),
			"ZoFontWinH5", textRow, side, r, g, b)
	elseif SKH.isStolenItemForSell(bagId, slotIndex, itemLink) then
		r, g, b = SK.COLOR.YELLOW:UnpackRGB()
		tooltipControl:AddHeaderLine(GetString(SI_SK_AUT_STOLEN_SELL_HEADER),
			"ZoFontWinH5", textRow, side, r, g, b)
	end
end

local function TooltipHook(tooltipControl, method, linkFunc)
	local origMethod = tooltipControl[method]

	tooltipControl[method] = function(self, ...)
		local modified = false
		local itemLink = linkFunc(...)
		if SK.savedVars.showEnchantQualityColor then
			local itemType = GetItemLinkItemType(itemLink)
			if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
				local quality = GetEnchantQuality(itemLink)
				if quality > 0 then
					SKH.modifyItemEnchantFormatString(includeQuality[quality], includeQualityMulti[quality])
					modified = true
				end
			end
		end

		AddUnwantedTooltipData(tooltipControl, itemLink)
		AddSendMailItemTooltipData(tooltipControl, itemLink)

		if IsItemLinkStolen(itemLink) then
			local bagId, slotIndex, sellCost
			if method ~= "SetLootItem" then
				bagId, slotIndex = ...
				if not SKH.isValueInList(SKDC.BAG_LINKS_BAGS, bagId) then
					bagId = nil
					slotIndex = nil
				end
			else
				local linkLootId = ...
				local numLootItems = GetNumLootItems()
				for i = 1, numLootItems do
					local lootId, _, _, count, _, value, _, _, _ = GetLootItemInfo(i)
					if linkLootId == lootId then sellCost = count * value end
				end
			end
			AddStolenItemTooltipData(tooltipControl, itemLink, bagId, slotIndex, sellCost)
		end

		if modified then
			local result = origMethod(self, ...)
			if SK.savedVars.showEnchantQualityColor then
				SKH.modifyItemEnchantFormatString(orgEnchantString, orgEnchantStringMulti)
			end
			return result
		else
			return origMethod(self, ...)
		end
	end
end

local function TooltipOnAddGameData(tooltipControl, gameDataType, ...)
	if gameDataType == TOOLTIP_GAME_DATA_EQUIPPED_INFO then
		local itemLink = SKH.getWornItemLink(...)
		if SK.savedVars.showEnchantQualityColor then
			local quality = GetEnchantQuality(itemLink)
			if quality > 0 then
				SKH.modifyItemEnchantFormatString(includeQuality[quality], includeQualityMulti[quality])
			end
		end
		AddUnwantedTooltipData(tooltipControl, itemLink)
	elseif gameDataType == TOOLTIP_GAME_DATA_MYTHIC_OR_STOLEN then
		if SK.savedVars.showEnchantQualityColor then
			SKH.modifyItemEnchantFormatString(orgEnchantString, orgEnchantStringMulti)
		end
	end
end

local function EquipmentTooltipsHook()
	for _, tooltipsHook in ipairs(tooltipsHooks) do
    	TooltipHook(tooltipsHook[1], tooltipsHook[2], tooltipsHook[3])
    end
	ZO_PreHookHandler(ComparativeTooltip1, "OnAddGameData", TooltipOnAddGameData)
	ZO_PreHookHandler(ComparativeTooltip2, "OnAddGameData", TooltipOnAddGameData)
end

-- Export
SK.Equipment = {
	InitApparelSlots = InitApparelSlots,
 	InitEquipmentToolbar = InitEquipmentToolbar,
	InitEnchantQualityCache = InitEnchantQualityCache,
	EquipmentTooltipsHook = EquipmentTooltipsHook
}