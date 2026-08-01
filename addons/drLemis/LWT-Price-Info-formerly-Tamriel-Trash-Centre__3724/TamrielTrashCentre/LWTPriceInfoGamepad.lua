local GAMEPAD_TOOLTIP_PRICE_STYLE = {
	fontSize = 28,
	fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1,
}

local gamepadHooksInstalled = false
local gamepadGuildStoreTooltipHooked = false
local gamepadBrowseHooked = false
local skipGenericTooltipHook = false

function LWTPriceInfo.InitializeGamepad()
	if gamepadHooksInstalled then return end

	LWTPriceInfo.InitializeGamepadSubLabels()
	LWTPriceInfo.InitializeGamepadTooltips()
	LWTPriceInfo.InitializeGamepadCraftingTooltips()

	gamepadHooksInstalled = true
end

function LWTPriceInfo.InitializeGamepadSubLabels()
	if not ZO_SharedGamepadEntry_OnSetup then return end

	ZO_PostHook("ZO_SharedGamepadEntry_OnSetup", function(control, data, selected, reselectingDuringRebuild, enabled, active)
		pcall(function()
			local priceLabel = control:GetNamedChild("LWTPrice")
			if priceLabel then
				priceLabel:SetHidden(true)
			end

			if not data then return end

			local displayMode = LWTPriceInfo.vars.gamepad.displayMode
			if displayMode == "tooltip" then return end

			local itemLink
			local stackCount = data.stackCount

			if data.lootId then
				itemLink = GetLootItemLink(data.lootId)
				stackCount = stackCount or data.count
			elseif data.bagId and data.slotIndex then
				itemLink = GetItemLink(data.bagId, data.slotIndex)
			elseif data.itemLink then
				itemLink = data.itemLink
			elseif data.recipeListIndex and data.recipeIndex then
				itemLink = GetRecipeResultItemLink(data.recipeListIndex, data.recipeIndex)
			elseif data.slotIndex then
				itemLink = GetStoreItemLink(data.slotIndex)
				if not itemLink or itemLink == "" then
					itemLink = GetBuybackItemLink(data.slotIndex)
				end
			end

			if not itemLink or itemLink == "" then return end

			local priceText = LWTPriceInfo.GetGamepadPriceText(itemLink, stackCount)
			if not priceText then return end

			local label = control:GetNamedChild("Label")
			if not label then return end

			if not priceLabel then
				priceLabel = CreateControl(control:GetName() .. "LWTPrice", control, CT_LABEL)
			end

			local markerSettings = LWTPriceInfo.GetMarkerSettings()
			local fontStyle = markerSettings.textBold and "BOLD_FONT" or "MEDIUM_FONT"
			local customFont = string.format("$(%s)|$(KB_%s)|soft-shadow-thick", fontStyle, markerSettings.textScale)
			priceLabel:SetFont(customFont)
			priceLabel:ClearAnchors()
			priceLabel:SetAnchor(BOTTOMLEFT, label, TOPLEFT, markerSettings.xOffsetInv, markerSettings.yOffsetInv + 10)
			priceLabel:SetText(priceText)
			priceLabel:SetHidden(false)
		end)
	end)
end

function LWTPriceInfo.InitializeGamepadTooltips()
	local function TooltipHook(tooltipControl, method, dataFunc)
		if not tooltipControl or not tooltipControl[method] then return end

		local origMethod = tooltipControl[method]
		tooltipControl[method] = function(self, ...)
			self._lwtPriceAdded = nil
			origMethod(self, ...)

			if skipGenericTooltipHook then return end
			if self._lwtPriceAdded then return end

			local ok, itemLink, stackCount = pcall(dataFunc, ...)
			if ok and itemLink and itemLink ~= "" then
				pcall(LWTPriceInfo.AddGamepadTooltipPrice, self, itemLink, stackCount)
				self._lwtPriceAdded = true
			end
		end
	end

	local tooltipTargets = { GAMEPAD_LEFT_TOOLTIP, GAMEPAD_RIGHT_TOOLTIP, GAMEPAD_MOVABLE_TOOLTIP }
	local hookedTooltips = {}

	for _, tooltipId in ipairs(tooltipTargets) do
		local ok, tooltip = pcall(function() return GAMEPAD_TOOLTIPS:GetTooltip(tooltipId) end)
		if ok and tooltip and not hookedTooltips[tooltip] then
			hookedTooltips[tooltip] = true
			TooltipHook(tooltip, "LayoutBagItem", function(bagId, slotIndex)
				local stackCount = GetSlotStackSize(bagId, slotIndex)
				return GetItemLink(bagId, slotIndex), stackCount
			end)

			TooltipHook(tooltip, "LayoutCraftBagItem", function(bagId, slotIndex)
				local stackCount = GetSlotStackSize(bagId, slotIndex)
				return GetItemLink(bagId, slotIndex), stackCount
			end)

			TooltipHook(tooltip, "LayoutItemWithStackCount", function(itemLink, stackCount)
				return itemLink, stackCount
			end)
		end
	end
end

function LWTPriceInfo.AddGamepadTooltipPrice(tooltip, itemLink, stackCount)
	local settings = LWTPriceInfo.vars.gamepad
	if settings.displayMode == "ui" then return end
	local providerPrice = LWTPriceInfo.GetSingleProviderPrice(settings.priceProvider, itemLink)
	if not LWTPriceInfo.IsSellableSingle(providerPrice) then return end
	local markerSettings = LWTPriceInfo.GetMarkerSettings()

	local multItems = 1
	if settings.stackMultiplier and stackCount and stackCount > 1 then
		multItems = stackCount
	end

	local syntheticSettings = {
		priceProvider = settings.priceProvider,
		priceType = settings.priceType,
		stackMultiplier = false,
	}

	local price, count = LWTPriceInfo.GetPriceAndCount(syntheticSettings, itemLink, multItems)
	if not price or price == 0 then return end

	local r = LWTPriceInfo.FormatPriceDisplay(price, count, {
		minPrice = markerSettings.minPrice,
		maxPrice = markerSettings.maxPrice,
		colors = markerSettings.colors,
		priceShorten = markerSettings.priceShorten,
		showAmount = markerSettings.showAmount,
		colorAmount = markerSettings.colorAmount,
		countMin = markerSettings.countMin,
		countMax = markerSettings.countMax,
	})

	local displayText = "|c" .. r.priceHex .. r.priceFormatted .. "|r"
	if r.countDisplay then
		displayText = displayText .. " |c" .. r.countHex .. "[" .. r.countDisplay .. "]|r"
	end

	local providerName = settings.priceProvider or ""
	local headerText = LWTPriceInfo.nameLoc .. " (" .. providerName .. " " .. settings.priceType .. ")"

	tooltip:AddLine(headerText, GAMEPAD_TOOLTIP_PRICE_STYLE, tooltip:GetStyle("bodySection"))
	tooltip:AddLine(displayText, GAMEPAD_TOOLTIP_PRICE_STYLE, tooltip:GetStyle("bodySection"))
end

function LWTPriceInfo.InitializeGamepadGuildStore()
	LWTPriceInfo.InitializeGamepadGuildStoreTooltips()
	LWTPriceInfo.HookGamepadBrowseResultsList()
end

function LWTPriceInfo.InitializeGamepadGuildStoreTooltips()
	if gamepadGuildStoreTooltipHooked then return end

	local function HookTooltipClass(method, getDataFunc)
		pcall(function()
			if not ZO_Tooltip or not ZO_Tooltip[method] then return end

			ZO_PreHook(ZO_Tooltip, method, function(self, ...)
				if not IsInGamepadPreferredMode() then return end
				skipGenericTooltipHook = true
			end)

			ZO_PostHook(ZO_Tooltip, method, function(self, index, ...)
				if not IsInGamepadPreferredMode() then return end
				skipGenericTooltipHook = false
				pcall(function()
					local itemLink, stackCount = getDataFunc(index)
					if itemLink and itemLink ~= "" then
						LWTPriceInfo.AddGamepadTooltipPrice(self, itemLink, stackCount)
					end
				end)
			end)
		end)
	end

	HookTooltipClass("LayoutTradingHouseSearchResult", function(resultIndex)
		local _, _, _, stackCount = GetTradingHouseSearchResultItemInfo(resultIndex)
		return GetTradingHouseSearchResultItemLink(resultIndex), stackCount
	end)

	HookTooltipClass("LayoutTradingHouseListing", function(listingIndex)
		local _, _, _, stackCount = GetTradingHouseListingItemInfo(listingIndex)
		return GetTradingHouseListingItemLink(listingIndex), stackCount
	end)

	gamepadGuildStoreTooltipHooked = true
end

function LWTPriceInfo.HookGamepadBrowseResultsList()
	if gamepadBrowseHooked then return end

	local ok, err = pcall(function()
		if not GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS then return end

		local browseResults = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
		local dataTypeId = ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_PRIMARY_DATA_TYPE or 1
		local dataType = ZO_ScrollList_GetDataTypeTable(browseResults.list, dataTypeId)
		if not dataType or not dataType.setupCallback then return end

		local GP_PRICE_CHILD = LWTPriceInfo.name .. "_GPPrice"
		local GP_FONT = "$(BOLD_FONT)|$(KB_20)|soft-shadow-thick"

		ZO_PostHook(dataType, "setupCallback", function(rowControl, rowData)
			pcall(function()
				local priceLabel = rowControl:GetNamedChild(GP_PRICE_CHILD)
				local itemLink = rowData and rowData.itemLink

				if not itemLink or itemLink == "" then
					if priceLabel then priceLabel:SetHidden(true) end
					return
				end

				local guildPricePerUnit = nil
				if rowData.purchasePricePerUnit then
					guildPricePerUnit = rowData.purchasePricePerUnit
				end

				local priceText = LWTPriceInfo.GetGamepadPriceText(itemLink, rowData.stackCount, guildPricePerUnit)
				if not priceText or priceText == "" then
					if priceLabel then priceLabel:SetHidden(true) end
					return
				end

				if not priceLabel then
					priceLabel = WINDOW_MANAGER:CreateControl(
						rowControl:GetName() .. GP_PRICE_CHILD, rowControl, CT_LABEL)
					priceLabel:SetFont(GP_FONT)
				end

				priceLabel:ClearAnchors()
				priceLabel:SetAnchor(BOTTOMRIGHT, rowControl.priceLabel, TOPRIGHT, 0, 0)
				priceLabel:SetText(priceText)
				priceLabel:SetHidden(false)
			end)
		end)

		gamepadBrowseHooked = true
		LWTPriceInfo._gamepadBrowseHooked = true

		pcall(function()
			ZO_ScrollList_RefreshVisible(browseResults.list)
		end)
	end)
end

function LWTPriceInfo.OnGamepadModeChanged()
	if IsInGamepadPreferredMode() then
		pcall(LWTPriceInfo.InitializeGamepad)
	else
		pcall(LWTPriceInfo.InitializeKeyboardMode)
	end
end

function LWTPriceInfo.InitializeGamepadCraftingTooltips()
	pcall(function()
		if SMITHING_GAMEPAD then
			if SMITHING_GAMEPAD.creationPanel then
				ZO_PostHook(SMITHING_GAMEPAD.creationPanel, "SetupResultTooltip",
					function(self, selectedPatternIndex, selectedMaterialIndex, selectedMaterialQuantity, selectedStyleId, selectedTraitIndex)
						pcall(function()
							local itemLink = GetSmithingPatternResultLink(selectedPatternIndex, selectedMaterialIndex, selectedMaterialQuantity, selectedStyleId, selectedTraitIndex)
							if itemLink and itemLink ~= "" then
								LWTPriceInfo.AddGamepadTooltipPrice(self.resultTooltip.tip, itemLink, 1)
							end
						end)
					end)
			end

			if SMITHING_GAMEPAD.improvementPanel then
				ZO_PostHook(SMITHING_GAMEPAD.improvementPanel, "SetupResultTooltip",
					function(self, ...)
						local args = { ... }
						pcall(function()
							local itemLink = GetSmithingImprovedItemLink(unpack(args))
							if itemLink and itemLink ~= "" then
								LWTPriceInfo.AddGamepadTooltipPrice(self.resultTooltip.tip, itemLink, 1)
							end
						end)
					end)
			end
		end

		if GAMEPAD_ENCHANTING then
			ZO_PostHook(GAMEPAD_ENCHANTING, "UpdateTooltip",
				function(self)
					pcall(function()
						if not self:IsCraftable() then return end
						local itemLink = GetEnchantingResultingItemLink(self:GetAllCraftingBagAndSlots())
						if itemLink and itemLink ~= "" then
							LWTPriceInfo.AddGamepadTooltipPrice(self.resultTooltip.tip, itemLink, 1)
						end
					end)
				end)
		end

		if GAMEPAD_ALCHEMY then
			ZO_PostHook(GAMEPAD_ALCHEMY, "UpdateTooltip",
				function(self)
					pcall(function()
						if not self:IsCraftable() then return end
						local itemLink = GetAlchemyResultingItemLink(self:GetAllCraftingBagAndSlots())
						if itemLink and itemLink ~= "" then
							LWTPriceInfo.AddGamepadTooltipPrice(self.tooltip.tip, itemLink, 1)
						end
					end)
				end)
		end

		if GAMEPAD_PROVISIONER then
			ZO_PostHook(GAMEPAD_PROVISIONER, "RefreshRecipeDetails",
				function(self, selectedData)
					pcall(function()
						if not selectedData then return end
						local recipeListIndex = selectedData.recipeListIndex
						local recipeIndex = selectedData.recipeIndex
						if not recipeListIndex or not recipeIndex then return end
						local itemLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
						if itemLink and itemLink ~= "" then
							LWTPriceInfo.AddGamepadTooltipPrice(self.resultTooltip.tip, itemLink, 1)
						end
					end)
				end)
		end
	end)
end
