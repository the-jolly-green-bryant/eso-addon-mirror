local HarvensDurabilityAndCharges = {}

function HarvensDurabilityAndCharges.OnAddGameData(control, gameDataType, ...)
	if control == ItemTooltip then
		HarvensDurabilityAndCharges.ItemTooltipOrgHandler(control, gameDataType, ...)
	elseif control == ComparativeTooltip1 then
		HarvensDurabilityAndCharges.ComparativeTooltip1OrgHandler(control, gameDataType, ...)
	elseif control == ComparativeTooltip2 then
		HarvensDurabilityAndCharges.ComparativeTooltip1OrgHandler(control, gameDataType, ...)
	elseif control == PopupTooltip then
		HarvensDurabilityAndCharges.PopupTooltipOrgHandler(control, gameDataType, ...)
	end

	if gameDataType == TOOLTIP_GAME_DATA_CONDITION then
		local bar = control:GetNamedChild("HarvensCondition")
		if not bar then
			return
		end
		local cur, max = ...
		bar.bars[1]:SetMinMax(0, max / 2)
		bar.bars[2]:SetMinMax(0, max / 2)
		bar.bars[1]:SetValue(cur / 2)
		bar.bars[2]:SetValue(cur / 2)
		local cost
		if bar.bagIndex and bar.slotIndex then
			cost = GetItemRepairCost(bar.bagIndex, bar.slotIndex)
		else
			cost = 0
		end
		local percent = cur / max * 100
		local text = cost > 0 and string.format("%.f%% - %ig", percent, cost) or string.format("%.f%%", percent)
		bar.label:SetText(text)
	elseif gameDataType == TOOLTIP_GAME_DATA_CHARGES then
		local bar = control:GetNamedChild("HarvensCharges")
		if not bar then
			return
		end
		local cur, max = ...
		bar.bars[1]:SetMinMax(0, max / 2)
		bar.bars[2]:SetMinMax(0, max / 2)
		bar.bars[1]:SetValue(cur / 2)
		bar.bars[2]:SetValue(cur / 2)
		bar.label:SetText(string.format("%i/%i", cur, max))
	elseif gameDataType == TOOLTIP_GAME_DATA_EQUIPPED_INFO then
		local bar = control:GetNamedChild("HarvensCondition")
		if not bar then
			return
		end
		local slotIndex, actorCategory = ...
		local bagId = actorCategory ~= GAMEPLAY_ACTOR_CATEGORY_COMPANION and BAG_WORN or BAG_COMPANION_WORN
		bar.bagIndex, bar.slotIndex = bagId, slotIndex
	end
end

function HarvensDurabilityAndCharges:AttachStatusBar(tooltip, type)
	local harvensStatusBar = WINDOW_MANAGER:CreateControlFromVirtual(tooltip:GetName() .. "Harvens" .. type, tooltip, "HarvensTooltipStatusBar")
	harvensStatusBar:SetHidden(true)
	harvensStatusBar:SetWidth(300)
	harvensStatusBar.bars = {harvensStatusBar:GetNamedChild("BarLeft"), harvensStatusBar:GetNamedChild("BarRight")}
	harvensStatusBar.bars[1]:SetGradientColors(0.05, 0.24, 0.36, 1, 0.39, 0.74, 0.82, 1)
	harvensStatusBar.bars[2]:SetGradientColors(0.05, 0.24, 0.36, 1, 0.39, 0.74, 0.82, 1)
	harvensStatusBar.label = harvensStatusBar:GetNamedChild("Value")
	harvensStatusBar:SetAnchor(CENTER, tooltip:GetNamedChild(type), CENTER)
	tooltip:GetNamedChild(type):SetHeight(20)
	tooltip:GetNamedChild(type):SetAlpha(0)
	tooltip:GetNamedChild(type):SetHandler(
		"OnEffectivelyShown",
		function(control)
			harvensStatusBar:SetHidden(false)
		end
	)
	tooltip:GetNamedChild(type):SetHandler(
		"OnEffectivelyHidden",
		function(control)
			harvensStatusBar:SetHidden(true)
			harvensStatusBar.bagIndex = nil
			harvensStatusBar.slotIndex = nil
		end
	)
	local CHILD_DIRECTIONS = {"Left", "Right", "Center"}
	local backgroundTemplates = {
		Left = "ZO_PlayerAttributeBgLeftArrow_Keyboard_Template",
		Right = "ZO_PlayerAttributeBgRightArrow_Keyboard_Template",
		Center = "ZO_PlayerAttributeBgCenter_Keyboard_Template"
	}
	local frameTemplates = {
		Left = "ZO_PlayerAttributeFrameLeftArrow_Keyboard_Template",
		Right = "ZO_PlayerAttributeFrameRightArrow_Keyboard_Template",
		Center = "ZO_PlayerAttributeFrameCenter_Keyboard_Template"
	}
	for _, direction in pairs(CHILD_DIRECTIONS) do
		local bgChild = harvensStatusBar:GetNamedChild("BgContainer"):GetNamedChild("Bg" .. direction)
		ApplyTemplateToControl(bgChild, backgroundTemplates[direction])

		local frameControl = harvensStatusBar:GetNamedChild("Frame" .. direction)
		ApplyTemplateToControl(frameControl, frameTemplates[direction])
	end
end

function HarvensDurabilityAndCharges.UpdateRepairCost(eventType, ...)
	if eventType == EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
		local bagId, _, _, _, updateReason = ...
		if updateReason ~= INVENTORY_UPDATE_REASON_DURABILITY_CHANGE or bagId ~= BAG_WORN then
			return
		end
	end

	local bagId = BAG_WORN
	local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(bagId)

	local cost = 0
	for _, itemData in pairs(bagCache) do
		cost = cost + GetItemRepairCost(itemData.bagId, itemData.slotIndex)
	end

	ZO_CurrencyControl_SetSimpleCurrency(HarvensDurabilityAndCharges.repairCostControl, CURT_MONEY, cost, HarvensDurabilityAndCharges.currencyOptions)
end

function HarvensDurabilityAndCharges:Initialize()
	self.ItemTooltipOrgHandler = ItemTooltip:GetHandler("OnAddGameData")
	ItemTooltip:SetHandler("OnAddGameData", HarvensDurabilityAndCharges.OnAddGameData)
	HarvensDurabilityAndCharges:AttachStatusBar(ItemTooltip, "Charges")
	HarvensDurabilityAndCharges:AttachStatusBar(ItemTooltip, "Condition")

	self.ComparativeTooltip1OrgHandler = ComparativeTooltip1:GetHandler("OnAddGameData")
	ComparativeTooltip1:SetHandler("OnAddGameData", HarvensDurabilityAndCharges.OnAddGameData)
	self.ComparativeTooltip2OrgHandler = ComparativeTooltip2:GetHandler("OnAddGameData")
	ComparativeTooltip2:SetHandler("OnAddGameData", HarvensDurabilityAndCharges.OnAddGameData)
	HarvensDurabilityAndCharges:AttachStatusBar(ComparativeTooltip1, "Charges")
	HarvensDurabilityAndCharges:AttachStatusBar(ComparativeTooltip1, "Condition")
	HarvensDurabilityAndCharges:AttachStatusBar(ComparativeTooltip2, "Charges")
	HarvensDurabilityAndCharges:AttachStatusBar(ComparativeTooltip2, "Condition")

	self.PopupTooltipOrgHandler = PopupTooltip:GetHandler("OnAddGameData")
	PopupTooltip:SetHandler("OnAddGameData", HarvensDurabilityAndCharges.OnAddGameData)
	HarvensDurabilityAndCharges:AttachStatusBar(PopupTooltip, "Charges")
	HarvensDurabilityAndCharges:AttachStatusBar(PopupTooltip, "Condition")

	self.ItemTooltipSetBagItemOrgFunc = ItemTooltip.SetBagItem
	ItemTooltip.SetBagItem = function(control, ...)
		local bagId, slotIndex = ...
		local bar = control:GetNamedChild("HarvensCondition")
		bar.bagIndex, bar.slotIndex = bagId, slotIndex
		return self.ItemTooltipSetBagItemOrgFunc(control, ...)
	end

	self.ItemTooltipSetWornItemOrgFunc = ItemTooltip.SetWornItem
	ItemTooltip.SetWornItem = function(control, ...)
		local slotIndex, bagId = ...
		local bar = control:GetNamedChild("HarvensCondition")
		bar.bagIndex, bar.slotIndex = bagId, slotIndex
		return self.ItemTooltipSetWornItemOrgFunc(control, ...)
	end

	local repairall = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)HarvensRepairAll", ZO_Character, "HarvensCharacterSheetRepairAll")
	repairall:SetAnchor(TOPLEFT, ZO_Character, TOPLEFT, 0, 540)

	self.repairCostControl = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)HarvensRepairAllLabel", ZO_Character, "HarvensCharacterSheetRepairAllLabel")
	self.currencyOptions = {
		showTooltips = false,
		iconSide = LEFT,
		font = "ZoFontGameLargeBold"
	}
	self.repairCostControl:SetAnchor(TOPLEFT, repairall:GetNamedChild("Text"), BOTTOMLEFT)

	self.repairCostControl:RegisterForEvent(EVENT_PLAYER_ACTIVATED, HarvensDurabilityAndCharges.UpdateRepairCost)
	self.repairCostControl:RegisterForEvent(EVENT_INVENTORY_FULL_UPDATE, HarvensDurabilityAndCharges.UpdateRepairCost)
	self.repairCostControl:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, HarvensDurabilityAndCharges.UpdateRepairCost)
end

local function HarvensDurabilityAndCharges_OnLoaded(eventType, addonName)
	if addonName ~= "HarvensDurabilityAndCharges" then
		return
	end

	local asd = ZO_TooltipSection.AddStatusBar
	ZO_TooltipSection.AddStatusBar = function(section, bar, ...)
		if HarvensDurabilityAndCharges.gamepadTooltipItemLink then
			--d("Add Status Bar: "..HarvensDurabilityAndCharges.gamepadTooltipItemLink)

			if GetItemLinkItemType(HarvensDurabilityAndCharges.gamepadTooltipItemLink) == ITEMTYPE_WEAPON then
				local max = GetItemLinkMaxEnchantCharges(HarvensDurabilityAndCharges.gamepadTooltipItemLink)
				local cur = GetItemLinkNumEnchantCharges(HarvensDurabilityAndCharges.gamepadTooltipItemLink)
				bar:GetNamedChild("Value"):SetText(string.format("%i/%i", cur, max))
			else
				local text = GetItemLinkCondition(HarvensDurabilityAndCharges.gamepadTooltipItemLink) .. "%"
				if HarvensDurabilityAndCharges.gamepadTooltipBagId and HarvensDurabilityAndCharges.gamepadTooltipSlotIndex then
					local cost = GetItemRepairCost(HarvensDurabilityAndCharges.gamepadTooltipBagId, HarvensDurabilityAndCharges.gamepadTooltipSlotIndex)
					if cost > 0 then
						text = string.format("%s - %ig", text, cost)
					end
				end
				bar:GetNamedChild("Value"):SetText(text)
			end
		end
		return asd(section, bar, ...)
	end

	local oldCallback = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP).AddConditionOrChargeBar
	GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP).AddConditionOrChargeBar = function(control, itemLink, ...)
		HarvensDurabilityAndCharges.gamepadTooltipItemLink = itemLink

		local ret = oldCallback(control, itemLink, ...)

		HarvensDurabilityAndCharges.gamepadTooltipItemLink = nil
		return ret
	end

	local oldCallback2 = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP).AddConditionOrChargeBar
	GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP).AddConditionOrChargeBar = function(control, itemLink, ...)
		HarvensDurabilityAndCharges.gamepadTooltipItemLink = itemLink

		local ret = oldCallback2(control, itemLink, ...)

		HarvensDurabilityAndCharges.gamepadTooltipItemLink = nil
		return ret
	end

	local oldCallback3 = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP).LayoutBagItem
	GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP).LayoutBagItem = function(self, bagId, slotIndex, ...)
		HarvensDurabilityAndCharges.gamepadTooltipBagId = bagId
		HarvensDurabilityAndCharges.gamepadTooltipSlotIndex = slotIndex

		local ret = oldCallback3(self, bagId, slotIndex, ...)

		HarvensDurabilityAndCharges.gamepadTooltipBagId = nil
		HarvensDurabilityAndCharges.gamepadTooltipSlotIndex = nil
		return ret
	end

	ZO_TOOLTIP_STYLES.conditionOrChargeBar.statusBarTemplate = "HarvensDaCGamepadStatusBar"
	ZO_TOOLTIP_STYLES.conditionOrChargeBar.widthPercent = 50

	HarvensDurabilityAndCharges:Initialize()
end

EVENT_MANAGER:RegisterForEvent("HarvensDurabilityAndChargesOnLoaded", EVENT_ADD_ON_LOADED, HarvensDurabilityAndCharges_OnLoaded)
