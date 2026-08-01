LWTPriceInfo = {}
LWTPriceInfo.name = "TamrielTrashCentre"
LWTPriceInfo.nameLoc = "|c006400LWT|r Price Info"
LWTPriceInfo.author = "drLemis"
LWTPriceInfo.version = "2.0.2"
LWTPriceInfo.website = "https://www.esoui.com/downloads/info3724.html"

LWTPriceInfo.GUILD_FEE_RATE = 0.07
LWTPriceInfo.SUGGESTED_MARKUP = 1.125

LWTPriceInfo.errorLog = ""

function LWTPriceInfo.OnAddOnLoaded(_, addonName)
	if addonName == LWTPriceInfo.name then
		EVENT_MANAGER:UnregisterForEvent(LWTPriceInfo.name, EVENT_ADD_ON_LOADED)

		LWTPriceInfo.vars = ZO_SavedVars:NewAccountWide("TamrielTrashCentreVars", 2, nil, LWTPriceInfo.defaults)

		LWTPriceInfo.SetupProviders()

		local isDependsOk = LWTPriceInfo.CheckForDepends()
		LWTPriceInfo.CreateSettingsUI()
		EVENT_MANAGER:UnregisterForEvent(LWTPriceInfo.name, EVENT_PLAYER_ACTIVATED)
		if (isDependsOk == false) then
			EVENT_MANAGER:RegisterForEvent(LWTPriceInfo.name, EVENT_PLAYER_ACTIVATED, LWTPriceInfo.ShowErrors)
			return
		end

		local okKb, errKb = pcall(LWTPriceInfo.InitializeKeyboardMode)
		if not okKb then
			LWTPriceInfo.errorLog = LWTPriceInfo.errorLog .. "Keyboard init: " .. tostring(errKb) .. "\n"
		end
		local okGp, errGp = pcall(LWTPriceInfo.InitializeGamepad)
		if not okGp then
			LWTPriceInfo.errorLog = LWTPriceInfo.errorLog .. "Gamepad init: " .. tostring(errGp) .. "\n"
		end

		if string.len(LWTPriceInfo.errorLog) > 0 then
			EVENT_MANAGER:RegisterForEvent(LWTPriceInfo.name, EVENT_PLAYER_ACTIVATED, LWTPriceInfo.ShowErrors)
		end

		EVENT_MANAGER:RegisterForEvent(LWTPriceInfo.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, LWTPriceInfo.InitializeGuildTrader)

		EVENT_MANAGER:RegisterForEvent(LWTPriceInfo.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
			zo_callLater(LWTPriceInfo.OnGamepadModeChanged, 200)
		end)
	end
end

local keyboardHooksInstalled = false

function LWTPriceInfo.InitializeKeyboardMode()
	if keyboardHooksInstalled then return end

	LWTPriceInfo.InitializePlayerInventory()
	LWTPriceInfo.InitializeCraftingUI()

	ZO_PostHook(ZO_ScrollList_GetDataTypeTable(ZO_LootAlphaContainerList, 1), "setupCallback", LWTPriceInfo.InitializeLootContainersUI)

	LWTPriceInfo.AddPriceToCraftingTooltip(SMITHING.improvementPanel, 'SetupResultTooltip', GetSmithingImprovedItemLink)
	LWTPriceInfo.AddPriceToCraftingTooltip(SMITHING.creationPanel, 'SetupResultTooltip', GetSmithingPatternResultLink)
	LWTPriceInfo.AddPriceToCraftingTooltip(ZO_Enchanting, 'UpdateTooltip', LWTPriceInfo.GetEnchantResultItemLink)
	LWTPriceInfo.HookKeyboardAlchemy()
	LWTPriceInfo.HookKeyboardProvisioner()
	LWTPriceInfo.HookStoreWindow()

	keyboardHooksInstalled = true
end

function LWTPriceInfo.GetEnchantResultItemLink(...)
	local itemLink = GetEnchantingResultingItemLink(ENCHANTING:GetAllCraftingBagAndSlots())
	return itemLink
end

function LWTPriceInfo.GetAlchemyResultItemLink(...)
	local itemLink = GetAlchemyResultingItemLink(ALCHEMY:GetAllCraftingBagAndSlots())
	return itemLink
end

function LWTPriceInfo.GetProvisionerResultItemLink(selectedData)
	if not selectedData then return nil end
	local recipeListIndex = selectedData.recipeListIndex
	local recipeIndex = selectedData.recipeIndex
	if not recipeListIndex or not recipeIndex then return nil end
	return GetRecipeResultItemLink(recipeListIndex, recipeIndex)
end

function LWTPriceInfo.AddPriceToCraftingTooltip(toolTipControl, functionName, getItemLinkFunction)
	local base = toolTipControl[functionName]

	if (base == nil) then
		return
	end

	toolTipControl[functionName] = function(control, ...)
		base(control, ...)
		local itemLink = getItemLinkFunction(...)
		
		local tooltip = control
		if (control.resultTooltip ~= nil) then
			tooltip = control.resultTooltip
		elseif (control.tooltip ~= nil) then
			tooltip = control.tooltip
		end

		local info = {}
		info["itemLink"] = itemLink
		info["imitationItem"] = true
		LWTPriceInfo.InitializeLootContainersUI(tooltip, info)
	end
end

function LWTPriceInfo.HookKeyboardAlchemy()
	if not ZO_Alchemy then return end
	local base = ZO_Alchemy.UpdateTooltip
	if not base then return end

	ZO_PostHook(ZO_Alchemy, "UpdateTooltip", function(self)
		pcall(function()
			local itemLink = LWTPriceInfo.GetAlchemyResultItemLink()
			if not itemLink or itemLink == "" then
				LWTPriceInfo.HideCraftingPriceLabel(self)
				return
			end
			LWTPriceInfo.ShowCraftingPriceLabel(self, self.tooltip, itemLink)
		end)
	end)
end

function LWTPriceInfo.HookKeyboardProvisioner()
	if not PROVISIONER then return end
	if not PROVISIONER.RefreshRecipeDetails then return end

	ZO_PostHook(PROVISIONER, "RefreshRecipeDetails", function(self, selectedData)
		pcall(function()
			if not selectedData and self.recipeTree then
				selectedData = self.recipeTree:GetSelectedData()
			end
			local itemLink = LWTPriceInfo.GetProvisionerResultItemLink(selectedData)
			if not itemLink or itemLink == "" then
				LWTPriceInfo.HideCraftingPriceLabel(self)
				return
			end
			LWTPriceInfo.ShowCraftingPriceLabel(self, self.resultTooltip, itemLink)
		end)
	end)
end

function LWTPriceInfo.ShowCraftingPriceLabel(craftingObject, anchorControl, itemLink)
	local settings = LWTPriceInfo.GetMarkerSettings()
	if not settings.enabled then
		LWTPriceInfo.HideCraftingPriceLabel(craftingObject)
		return
	end

	local providerPrice = LWTPriceInfo.GetSingleProviderPrice(settings.priceProvider, itemLink)
	if not LWTPriceInfo.IsSellableSingle(providerPrice) then
		LWTPriceInfo.HideCraftingPriceLabel(craftingObject)
		return
	end

	local price, count = LWTPriceInfo.GetPriceAndCount(settings, itemLink, 1)
	if not price or price == 0 then
		LWTPriceInfo.HideCraftingPriceLabel(craftingObject)
		return
	end

	local r = LWTPriceInfo.FormatPriceDisplay(price, count, {
		minPrice = settings.minPrice,
		maxPrice = settings.maxPrice,
		colors = settings.colors,
		priceShorten = settings.priceShorten,
		showAmount = settings.showAmount,
		colorAmount = settings.colorAmount,
		countMin = settings.countMin,
		countMax = settings.countMax,
	})

	local priceText = "|c" .. r.priceHex .. r.priceFormatted
	if r.countDisplay then
		priceText = priceText .. "|c" .. r.countHex .. " [" .. r.countDisplay .. "]"
	end

	if not anchorControl then return end

	local label = craftingObject._lwtPriceLabel
	if not label then
		local tooltipName = anchorControl:GetName() or ""
		label = WINDOW_MANAGER:CreateControl(tooltipName .. LWTPriceInfo.name .. "_craftResult", anchorControl, CT_LABEL)
		label:SetDrawLevel(10)
		craftingObject._lwtPriceLabel = label
	end

	local fontStyle = settings.textBold and "BOLD_FONT" or "MEDIUM_FONT"
	local customFont = string.format("$(%s)|$(KB_%s)|soft-shadow-thick", fontStyle, settings.textScaleCraft)
	label:SetFont(customFont)
	label:SetText(priceText)
	label:ClearAnchors()

	local anchor = settings.anchorCraft
	label:SetAnchor(anchor, nil, anchor, -6 + settings.xOffsetCraft, settings.yOffsetCraft)
	label:SetHidden(false)
end

function LWTPriceInfo.HideCraftingPriceLabel(craftingObject)
	if craftingObject._lwtPriceLabel then
		craftingObject._lwtPriceLabel:SetHidden(true)
	end
end

function LWTPriceInfo.HookScrollList(listOwner, getItemLinkFunc)
	if not listOwner then return end

	local list = listOwner.list
	if not list then return end

	local scrollList = list.list or list
	if not scrollList or not scrollList.dataTypes then return end

	for _, dataType in pairs(scrollList.dataTypes) do
		if dataType.setupCallback then
			ZO_PostHook(dataType, "setupCallback", function(control, data)
				pcall(function()
					LWTPriceInfo.ClearAllMarkers(control)
					if not data then return end

					local itemLink = getItemLinkFunc(data)
					if not itemLink or itemLink == "" then return end

					local _, itemPrice = GetItemLinkInfo(itemLink)
					LWTPriceInfo.DisplayPrice(control, itemLink, itemPrice or 0, 0, 0, data.stackCount, false, false)
				end)
			end)
		end
	end
end

function LWTPriceInfo.HookStoreWindow()
	pcall(function()
		LWTPriceInfo.HookScrollList(STORE_WINDOW, function(data)
			return GetStoreItemLink(data.slotIndex)
		end)
	end)

	pcall(function()
		LWTPriceInfo.HookScrollList(BUY_BACK_WINDOW, function(data)
			return GetBuybackItemLink(data.slotIndex)
		end)
	end)
end

function LWTPriceInfo.CheckForDepends()
	LWTPriceInfo.errorLog = ""

	local settings = LWTPriceInfo.GetMarkerSettings()

	if (#LWTPriceInfo.ProviderNames == 0) then
		LWTPriceInfo.errorLog = LWTPriceInfo.errorLog .. GetString(LWT_PI_ERROR_PROVIDERS_NONE)
		for _, data in pairs(LWTPriceInfo.Providers) do
			LWTPriceInfo.errorLog = LWTPriceInfo.errorLog .. " : " .. data["Name"]
		end
		LWTPriceInfo.errorLog = LWTPriceInfo.errorLog .. "\n"
		return false
	end

	if (LWTPriceInfo.Providers[settings.priceProvider] == nil) then
		settings.priceProvider = LWTPriceInfo.GetAvailablePriceProvider(settings.priceProvider)
		LWTPriceInfo.errorLog = LWTPriceInfo.errorLog .. GetString(LWT_PI_ERROR_PROVIDER_EMPTY) .. "\n"
	elseif (not LWTPriceInfo.ProviderAvailable[settings.priceProvider]) then
		LWTPriceInfo.errorLog = LWTPriceInfo.errorLog ..
			LWTPriceInfo.Providers[settings.priceProvider]["Name"] .. GetString(LWT_PI_ERROR_PROVIDER_UNAVAILABLE) .. "\n"
		settings.priceProvider = LWTPriceInfo.GetAvailablePriceProvider(settings.priceProvider)
	end

	return true
end

function LWTPriceInfo.SetupProviders()
	LWTPriceInfo.ProviderNames = {}
	LWTPriceInfo.ProviderAvailable = {}
	for name, data in pairs(LWTPriceInfo.Providers) do
		local available = data["Available"]()
		LWTPriceInfo.ProviderAvailable[name] = available
		if available then
			table.insert(LWTPriceInfo.ProviderNames, tostring(name))
			if (data["Priority"] == nil) then
				data["Priority"] = math.huge
			end
		end
	end
	table.sort(LWTPriceInfo.ProviderNames,
		function(a, b) return LWTPriceInfo.Providers[a]["Priority"] < LWTPriceInfo.Providers[b]["Priority"] end)
end

function LWTPriceInfo.InitializeCraftingUI()
	LWTPriceInfo.HookCraftingPanel(SMITHING, "deconstructionPanel")
	LWTPriceInfo.HookCraftingPanel(SMITHING, "improvementPanel")
	LWTPriceInfo.HookCraftingPanel(SMITHING, "refinementPanel")
	LWTPriceInfo.HookCraftingPanel(ENCHANTING, "inventory")

	LWTPriceInfo.HookCraftingPanel(UNIVERSAL_DECONSTRUCTION, "deconstructionPanel")
end

function LWTPriceInfo.HookCraftingPanel(system, panelName)
    local panel = system[panelName]
    local scrollList = panel and panel.inventory and panel.inventory.list
    local datatype = scrollList and scrollList.dataTypes and scrollList.dataTypes[1]
    if datatype then
		if datatype.setupCallback then
			ZO_PostHook(datatype, "setupCallback", function (control, data)
				LWTPriceInfo.ClearAllMarkers(control)
				LWTPriceInfo.InitializeContainersUI(control, data, false)
			end)
		end
	end
end

function LWTPriceInfo.InitializeGuildTrader()
	if IsInGamepadPreferredMode() then
		pcall(LWTPriceInfo.InitializeGamepadGuildStore)
		if LWTPriceInfo._gamepadBrowseHooked then
			EVENT_MANAGER:UnregisterForEvent(LWTPriceInfo.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
		end
	else
		EVENT_MANAGER:UnregisterForEvent(LWTPriceInfo.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
		local hookedFunction = TRADING_HOUSE.searchResultsList.dataTypes[1].setupCallback
		if hookedFunction then
			ZO_PostHook(TRADING_HOUSE.searchResultsList.dataTypes[1], "setupCallback",
			function (control, data)
				LWTPriceInfo.ClearAllMarkers(control)
				LWTPriceInfo.InitializeContainersUIGuild(control, data)
			end)
		end
	end
end

function LWTPriceInfo.ClearAllMarkers(control)
	LWTPriceInfo.ClearMarker(control, LWTPriceInfo.GetMarkerSettings())
end

function LWTPriceInfo.InitializeContainersUIGuild(control, data)
	local settings = LWTPriceInfo.GetMarkerSettings()
	if settings.enabled then
		LWTPriceInfo.InitializeContainersUI(control, data, true)
	end
end

function LWTPriceInfo.InitializeLootContainersUI(control, data)
	LWTPriceInfo.ClearAllMarkers(control)
	LWTPriceInfo.InitializeContainersUI(control, data, false)
end

function LWTPriceInfo.InitializeContainersUI(control, data, useGuildOffset)
	local lootLink = GetLootItemLink(data.lootId)
	local tradingLink = lootLink

	local link = data.itemLink
	if (link == nil) then
		link = GetItemLink(data.bagId, data.slotIndex)
	end 
	if (lootLink ~= nil and lootLink ~= "") then
		link = lootLink
	end

	local guildOffset = false
	local priceOffset = 0
	local priceMod = 0
	
	if (LWTPriceInfo.CheckIfCurrency(data)) then
		return
	end

	if (data.imitationItem == nil or data.imitationItem == false) then
		if (link ~= lootLink) then
			if (data ~= nil) then
				tradingLink = GetTradingHouseListingItemLink(data.slotIndex, LINK_STYLE_DEFAULT)
				guildOffset = true
				if (data.stackCount ~= nil and data.purchasePricePerUnit ~= nil and data.stackCount > 1) then
					priceOffset = data.purchasePricePerUnit
				elseif (data.purchasePrice ~= nil) then
					priceOffset = data.purchasePrice
				end
			end
			priceMod = LWTPriceInfo.GUILD_FEE_RATE
		end
		if (tradingLink ~= link) then
			if (data ~= nil) then
				tradingLink = GetTradingHouseSearchResultItemLink(data.slotIndex, LINK_STYLE_DEFAULT)
				guildOffset = true
				if (data.stackCount ~= nil and data.purchasePricePerUnit ~= nil and data.stackCount > 1) then
					priceOffset = data.purchasePricePerUnit
				elseif (data.purchasePrice ~= nil) then
					priceOffset = data.purchasePrice
				end
			end
			priceMod = LWTPriceInfo.GUILD_FEE_RATE
		end
	end

	local itemPrice = 0
	if (tradingLink ~= nil and tradingLink ~= "") then
		_, itemPrice, _, _, _ = GetItemLinkInfo(tradingLink)
	end
	if ((itemPrice == 0 or itemPrice == nil) and lootLink ~= nil and lootLink ~= "") then
		_, itemPrice, _, _, _ = GetItemLinkInfo(lootLink)
	end
	if ((itemPrice == 0 or itemPrice == nil) and link ~= nil and link ~= "") then
		_, itemPrice, _, _, _ = GetItemLinkInfo(link)
	end
	if (itemPrice == 0 or itemPrice == nil)  then
		itemPrice = data.purchasePricePerUnitRaw
	end
	if (itemPrice == nil) then
		itemPrice = 0
	end

	local itemLink = link
	if (link == nil) then
		itemLink = lootLink
	end
	if (link == nil) then
		itemLink = tradingLink
	end
	
	if (itemLink == nil or itemLink == "") then
		return
	end

	if (useGuildOffset == false) then
		guildOffset = false
	end

	LWTPriceInfo.DisplayPrice(control, itemLink, itemPrice, -priceOffset, priceMod, data.stackCount, guildOffset, data.imitationItem or false)
end

function LWTPriceInfo.InitializePlayerInventory()
	for _, v in pairs(PLAYER_INVENTORY.inventories) do
		local listView = v.listView
		
		if (listView and listView.dataTypes and listView.dataTypes[1]) then
			ZO_PostHook(listView.dataTypes[1], "setupCallback",
			function(control, data)
				if (LWTPriceInfo.CheckIfCurrency(data)) then
					return
				end

				local itemLink = GetItemLink(data.bagId, data.slotIndex)
				local _, itemPrice = GetItemLinkInfo(itemLink)
				LWTPriceInfo.DisplayPrice(control, itemLink, itemPrice, 0, 0, data.stackCount, false, false)
			end
			)
		end
	end
end

function LWTPriceInfo.CheckIfCurrency(data)
	if (data ~= nil and data.currencyAmount ~= nil and data.currencyAmount > 0) then
		return true
	end

	return false
end

function LWTPriceInfo.DisplayPrice(control, itemLink, itemPrice, priceOffset, priceMod, numbItem, useGuildOffset, isImitationObject)
	if (not itemLink or not control) then
		return
	end

	local settings = LWTPriceInfo.GetMarkerSettings()
	LWTPriceInfo.ClearMarker(control, settings)

	if (not settings.enabled) then return end

	local providerPrice = LWTPriceInfo.GetSingleProviderPrice(settings.priceProvider, itemLink)
	if (not LWTPriceInfo.IsSellableSingle(providerPrice)) then return end

	if (settings.setsOnly) then
		local _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
		if (setId == nil or setId == 0) then return end
	end

	if (settings.ignoreBound and IsItemLinkBound(itemLink)) then return end

	LWTPriceInfo.ShowMarker(control, itemPrice, priceOffset, priceMod, itemLink, numbItem, settings, useGuildOffset, isImitationObject)
end

function LWTPriceInfo.ClearMarker(control, settings)
	local marker = control:GetNamedChild(LWTPriceInfo.name .. settings.childName)
	if (marker) then
		marker:SetText("")
	end
end

function LWTPriceInfo.ShowMarker(control, itemPrice, priceOffset, priceMod, itemLink, amount, settings, useGuildOffset, isImitationObject)
	local multItems = 1
	if (settings.stackMultiplier and amount ~= nil) then
		multItems = amount
	end

	local price, count = LWTPriceInfo.GetPriceAndCount(settings, itemLink, multItems)

	if (price == nil or count == nil or price == 0 or count == 0) then
		return
	end

	local offsetX = settings.xOffsetInv
	local offsetY = settings.yOffsetInv
	if (useGuildOffset) then
		offsetX = settings.xOffsetGuild
		offsetY = settings.yOffsetGuild
		if (settings.guildPriceDelta and settings.guildFee) then
			price = price * (1 - priceMod)
		end
		if (settings.guildPriceDelta) then
			price = price + priceOffset * multItems
		end
	end
	if (isImitationObject) then
		offsetX = settings.xOffsetCraft
		offsetY = settings.yOffsetCraft
	end

	local maxPrice = settings.maxPrice
	local minPrice = settings.minPrice
	if (maxPrice <= minPrice) then
		maxPrice = minPrice + 1
		settings.maxPrice = maxPrice
	end
	local midPrice = (maxPrice - minPrice) / 2 + minPrice

	local comparePrice = -1
	if (settings.visibilityType == "Over min price") then
		comparePrice = minPrice
	elseif (settings.visibilityType == "Over mid price") then
		comparePrice = midPrice
	elseif (settings.visibilityType == "Over max price") then
		comparePrice = maxPrice
	end

	local isDelta = priceOffset ~= 0 and settings.guildPriceDelta

	local r = LWTPriceInfo.FormatPriceDisplay(price, count, {
		minPrice = minPrice,
		maxPrice = maxPrice,
		colors = settings.colors,
		priceShorten = settings.priceShorten,
		showAmount = settings.showAmount,
		colorAmount = settings.colorAmount,
		countMin = settings.countMin,
		countMax = settings.countMax,
		isDelta = isDelta,
		profitableColor = settings.profitableColor,
		itemPrice = itemPrice,
		multItems = multItems,
		priceOffset = priceOffset,
		comparePrice = comparePrice,
	})

	local priceText = "|c" .. r.priceHex .. r.priceFormatted
	if r.countDisplay then
		priceText = priceText .. "|c" .. r.countHex .. " [" .. r.countDisplay .. "]"
	end

	local marker = control:GetNamedChild(LWTPriceInfo.name .. settings.childName)
	if (not marker) then
		marker = WINDOW_MANAGER:CreateControl(control:GetName() .. LWTPriceInfo.name .. settings.childName, control, CT_LABEL)
	end
	marker:ClearAnchors()

	local anchor = settings.anchor
	local scale = settings.textScale
	if (isImitationObject) then
		anchor = settings.anchorCraft
		scale = settings.textScaleCraft
	end

	local fontStyle = settings.textBold and "BOLD_FONT" or "MEDIUM_FONT"
	local customFont = string.format("$(%s)|$(KB_%s)|soft-shadow-thick", fontStyle, scale)
	marker:SetFont(customFont)
	marker:SetText(priceText)

	if (useGuildOffset) then
		local sellPriceControl = control:GetNamedChild("SellPrice")
		if (sellPriceControl) then
			marker:SetAnchor(BOTTOMRIGHT, sellPriceControl, TOPRIGHT, offsetX, offsetY)
			return
		end
	end
	marker:SetAnchor(anchor, nil, anchor, -6 + offsetX, offsetY)
end

function LWTPriceInfo.ShowErrors()
	if (string.len(LWTPriceInfo.errorLog) > 0) then
		d(LWTPriceInfo.nameLoc .. " : " .. GetString(LWT_PI_ERRORS_DETECTED))
	end
end

EVENT_MANAGER:RegisterForEvent(LWTPriceInfo.name, EVENT_ADD_ON_LOADED, LWTPriceInfo.OnAddOnLoaded)

TamrielTrashCentre = LWTPriceInfo
