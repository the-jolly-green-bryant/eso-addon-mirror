local _settings

function TamrielTradeCentrePrice:GetPriceTableUpdatedDateString(langEnum)
	if (self.PriceTable == nil) then
		return TamrielTradeCentre:GetString("TTC_ERROR_PRICETABLEMISSING", langEnum)
	end

	local totalSecPerDay = 24 * 60 * 60 
	local timeStamp = self.PriceTable.TimeStamp
	local elapsedTime = GetTimeStamp() - timeStamp
	local elapsedDays = elapsedTime/totalSecPerDay
	if (elapsedTime < totalSecPerDay * 1.5) then
		return TamrielTradeCentre:GetString("TTC_PRICE_UPDATEDTODAY", langEnum)
	elseif (elapsedDays > 3) then
		return TamrielTradeCentre:GetString("TTC_ERROR_PRICETABLEOUTDATED", langEnum)
	else
		return string.format(TamrielTradeCentre:GetString("TTC_PRICE_LASTUPDATEDXDAYSAGO", langEnum), elapsedDays)
	end
end

--Public Function. Used by 3rd parties
function TamrielTradeCentrePrice:GetPriceInfo(itemInfoOrLink)
	local itemInfo = itemInfoOrLink
	local typeName = type(itemInfoOrLink)
	if (typeName == "string") then
		itemInfo = TamrielTradeCentre_ItemInfo:New(itemInfoOrLink)
	end

	if (self.PriceTable == nil or itemInfo == nil or itemInfo.ID == nil) then
		return nil
	end
	
	local itemIDDict = self.PriceTable.Data
	local qualityDict = itemIDDict[itemInfo.ID]
	if (qualityDict == nil) then
		TamrielTradeCentre:DebugWriteLine("itemIDDict not found")
		return nil
	end

	local levelDict = qualityDict[itemInfo.QualityID]
	if (levelDict == nil) then
		TamrielTradeCentre:DebugWriteLine("qualityDict not found")
		return nil
	end

	local traitDict = levelDict[itemInfo.Level]
	if (traitDict == nil) then
		TamrielTradeCentre:DebugWriteLine("levelDict not found")
		return nil
	end

	local priceDict = nil
	if (itemInfo.Category2IDOverWrite ~= nil) then
		local category2Dict = traitDict[itemInfo.TraitID or -1]
		if (category2Dict == nil) then
			TamrielTradeCentre:DebugWriteLine("traitDict not found")
			return nil
		end

		priceDict = category2Dict[itemInfo.Category2IDOverWrite]
	elseif (itemInfo.ItemType == ITEMTYPE_POTION or itemInfo.ItemType == ITEMTYPE_POISON) then
		local potionEffectDict = traitDict[itemInfo.TraitID or -1]
		if (potionEffectDict == nil) then
			TamrielTradeCentre:DebugWriteLine("traitDict not found")
			return nil
		end
		
		local potionEffectString = ""
		if (itemInfo.PotionEffects ~= nil) then
			for i = 1, #itemInfo.PotionEffects do
				if (potionEffectString ~= "") then
					potionEffectString = potionEffectString .. "|"
				end

				potionEffectString = potionEffectString .. itemInfo.PotionEffects[i]
			end
		end

		priceDict = potionEffectDict[potionEffectString]
	elseif (itemInfo.ItemType == ITEMTYPE_MASTER_WRIT) then
		local masterWritInfo = itemInfo.MasterWritInfo
		if (masterWritInfo == nil) then
			TamrielTradeCentre:DebugWriteLine("masterWritInfo is nil")
			return nil
		end

		local masterWritInfoDict = traitDict[itemInfo.TraitID or -1]
		if (masterWritInfoDict == nil) then
			TamrielTradeCentre:DebugWriteLine("masterWritInfoDict not found")
			return nil
		end

		local requiredItemIDDict = masterWritInfoDict[masterWritInfo.RequiredItemID or -1]
		if (requiredItemIDDict == nil) then	
			TamrielTradeCentre:DebugWriteLine("requiredItemIDDict not found")
			return nil
		end

		local requiredQualityIDDict = requiredItemIDDict[masterWritInfo.RequiredQualityID or -1]
		if (requiredQualityIDDict == nil) then	
			TamrielTradeCentre:DebugWriteLine("requiredQualityIDDict not found")
			return nil
		end

		local numVoucherDict = requiredQualityIDDict[masterWritInfo.NumVoucher or -1]
		if (numVoucherDict == nil) then	
			TamrielTradeCentre:DebugWriteLine("numVoucherDict not found")
			return nil
		end

		priceDict = numVoucherDict[masterWritInfo.RequiredTraitID or -1]
	else
		priceDict = traitDict[itemInfo.TraitID or -1]
	end

	if (priceDict == nil or (priceDict.Avg == nil and priceDict.A == nil)) then
		TamrielTradeCentre:DebugWriteLine("priceDict not found")
		return nil
	end

	return TamrielTradeCentre_PriceInfo:New(priceDict.Avg or priceDict.A, priceDict.Max or priceDict.X, priceDict.Min or priceDict.N, priceDict.EntryCount or priceDict.EC, priceDict.AmountCount or priceDict.AC, priceDict.SuggestedPrice or priceDict.S, priceDict.SaleAvg or priceDict.SA, priceDict.SaleEntryCount or priceDict.SE, priceDict.SaleAmountCount or priceDict.SAC)
end

function TamrielTradeCentrePrice:AppendPriceInfo(toolTipControl, itemInfo)
	local priceInfo = self:GetPriceInfo(itemInfo)

	if (priceInfo ~= nil) then
		toolTipControl:AddVerticalPadding(5)
		ZO_Tooltip_AddDivider(toolTipControl)

		if (_settings.EnableToolTipSuggested and priceInfo.SuggestedPrice ~= nil) then
			toolTipControl:AddLine(string.format("TTC " .. GetString(TTC_PRICE_SUGGESTEDXTOY), 
				TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice, 0), TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice * 1.25, 0)))
		end

		if (_settings.EnableToolTipAggregate) then
			toolTipControl:AddLine(string.format(GetString(TTC_PRICE_AGGREGATEPRICESXYZ), TamrielTradeCentre:FormatNumber(priceInfo.Avg), 
				TamrielTradeCentre:FormatNumber(priceInfo.Min), TamrielTradeCentre:FormatNumber(priceInfo.Max)))
		end

		if (_settings.EnableToolTipStat) then
			if (priceInfo.EntryCount ~= priceInfo.AmountCount) then
				toolTipControl:AddLine(string.format(GetString(TTC_PRICE_XLISTINGSYITEMS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount), TamrielTradeCentre:FormatNumber(priceInfo.AmountCount)))
			else
				toolTipControl:AddLine(string.format(GetString(TTC_PRICE_XLISTINGS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount)))
			end
		end

		if (_settings.EnableToolTipSalePrice and priceInfo.SaleAvg ~= nil) then
			toolTipControl:AddLine(string.format(GetString(TTC_PRICE_SALEAVGX), TamrielTradeCentre:FormatNumber(priceInfo.SaleAvg, 2)))

			if (_settings.EnableToolTipStat) then
				if (priceInfo.SaleEntryCount ~= priceInfo.SaleAmountCount) then
					toolTipControl:AddLine(string.format(GetString(TTC_PRICE_XSALESYITEMS), TamrielTradeCentre:FormatNumber(priceInfo.SaleEntryCount), TamrielTradeCentre:FormatNumber(priceInfo.SaleAmountCount)))
				else
					toolTipControl:AddLine(string.format(GetString(TTC_PRICE_XSALES), TamrielTradeCentre:FormatNumber(priceInfo.SaleEntryCount)))
				end
			end
		end

		if (_settings.EnableToolTipLastUpdate) then
			toolTipControl:AddLine(self:GetPriceTableUpdatedDateString())
		end
	end
end

function TamrielTradeCentrePrice:PriceInfoToChat(itemInfo, langEnum)
	local priceInfo = self:GetPriceInfo(itemInfo)
	local priceString = string.format(TamrielTradeCentre:GetString("TTC_PRICE_FORX", langEnum), itemInfo.ItemLink)
	if (priceInfo == nil) then
		priceString = priceString .. TamrielTradeCentre:GetString("TTC_PRICE_NOLISTINGDATA", langEnum)
	else
		if (_settings.EnablePriceToChatSuggested) then
			if (priceInfo.SuggestedPrice ~= nil) then
				priceString = priceString .. string.format(TamrielTradeCentre:GetString("TTC_PRICE_SUGGESTEDXTOY", langEnum), TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice, 0), 
					TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice * 1.25, 0))
			else
				priceString = priceString .. TamrielTradeCentre:GetString("TTC_PRICE_NOTENOUGHDATAFORSUGGESTION", langEnum)
			end
		end

		if (_settings.EnablePriceToChatAggregate) then
			priceString = priceString .. " " .. string.format(TamrielTradeCentre:GetString("TTC_PRICE_AGGREGATEPRICESXYZ", langEnum), TamrielTradeCentre:FormatNumber(priceInfo.Avg), 
				TamrielTradeCentre:FormatNumber(priceInfo.Min), TamrielTradeCentre:FormatNumber(priceInfo.Max))
		end

		if (_settings.EnablePriceToChatStat) then
			if (priceInfo.EntryCount ~= priceInfo.AmountCount) then
				priceString = priceString .. " " .. string.format(TamrielTradeCentre:GetString("TTC_PRICE_XLISTINGSYITEMS", langEnum), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount), TamrielTradeCentre:FormatNumber(priceInfo.AmountCount))
			else
				priceString = priceString .. " " .. string.format(TamrielTradeCentre:GetString("TTC_PRICE_XLISTINGS", langEnum), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount))
			end
		end

		if (_settings.EnablePriceToChatSalePrice and priceInfo.SaleAvg ~= nil) then
			priceString = priceString .. " " .. string.format(TamrielTradeCentre:GetString("TTC_PRICE_SALEAVGX", langEnum), TamrielTradeCentre:FormatNumber(priceInfo.SaleAvg))

			if (_settings.EnablePriceToChatStat) then
				if (priceInfo.SaleEntryCount ~= priceInfo.SaleAmountCount) then
					priceString = priceString .. " " .. string.format(TamrielTradeCentre:GetString("TTC_PRICE_XSALESYITEMS", langEnum), TamrielTradeCentre:FormatNumber(priceInfo.SaleEntryCount), TamrielTradeCentre:FormatNumber(priceInfo.SaleAmountCount))
				else
					priceString = priceString .. " " .. string.format(TamrielTradeCentre:GetString("TTC_PRICE_XSALES", langEnum), TamrielTradeCentre:FormatNumber(priceInfo.SaleEntryCount))
				end
			end
		end
	end

	if (_settings.EnablePriceToChatLastUpdate) then
		priceString = priceString .. " " .. self:GetPriceTableUpdatedDateString(langEnum)
	end

	CHAT_SYSTEM.textEntry.editControl:InsertText(priceString)
end

function TamrielTradeCentrePrice:SearchOnline(itemInfo)
	local serverRegion = TamrielTradeCentre:GetCurrentServerRegion()
	local url = "https://"
	if (serverRegion == "NA") then
		url = url .. "us."
	else
		url = url .. "eu."
	end

	url = url .. "tamrieltradecentre.com/pc/Trade/SearchResult?"

	url = url .. "ItemID=" .. itemInfo.ID
	url = url .. "&ItemNamePattern=" .. itemInfo.Name

	if (itemInfo.TraitID ~= nil) then
		url = url .. "&ItemTraitID=" .. itemInfo.TraitID
	end

	if (itemInfo.QualityID ~= nil) then
		url = url .. "&ItemQualityID=" .. itemInfo.QualityID
	end

	local level = itemInfo.Level
	url = url .. "&LevelMin=" .. level .. "&LevelMax=" .. level

	local langCode = TamrielTradeCentre:GetLangCode()

	if (_settings.SearchOnlineSort ~= nil) then
		url = url .. "&SortBy=" .. _settings.SearchOnlineSort
	end

	if (_settings.SearchOnlineOrder ~= nil) then
		url = url .. "&Order=" .. _settings.SearchOnlineOrder
	end

	if (langCode ~= nil) then
		url = url .. "&lang=" .. langCode
	end

	RequestOpenUnsafeURL(url)
end

function TamrielTradeCentrePrice:PriceDetailOnline(itemInfo)
	local serverRegion = TamrielTradeCentre:GetCurrentServerRegion()
	local url = "https://"
	if (serverRegion == "NA") then
		url = url .. "us."
	else
		url = url .. "eu."
	end

	url = url .. "tamrieltradecentre.com/pc/Trade/PriceDetail/"

	local keyTable = {}
	for i = 1, 12 do
		keyTable[i] = ""
	end

	keyTable[1] = itemInfo.ID
	keyTable[2] = itemInfo.Level
	keyTable[3] = itemInfo.QualityID
	keyTable[4] = itemInfo.TraitID
	keyTable[5] = itemInfo.Category2IDOverWrite
	
	if (itemInfo.PotionEffects ~= nil) then
		keyTable[6] = itemInfo.PotionEffects[1]
		keyTable[7] = itemInfo.PotionEffects[2]
		keyTable[8] = itemInfo.PotionEffects[3]
	end

	if (itemInfo.MasterWritInfo ~= nil) then
		keyTable[9] = itemInfo.RequiredItemID
		keyTable[10] = itemInfo.RequiredQualityID
		keyTable[11] = itemInfo.RequiredTraitID
		keyTable[12] = itemInfo.NumVoucher
	end

	local itemKey = table.concat(keyTable, "-")
	url = url .. itemKey
	
	local langCode = TamrielTradeCentre:GetLangCode()

	if (langCode ~= nil) then
		url = url .. "?lang=" .. langCode
	end

	RequestOpenUnsafeURL(url)
end

local function InsertContextMenuEntry(useSubMenu, subEntries, label, callback)
	if (useSubMenu) then
		local subEntry = {
			label = label,
			callback = callback
		}

		table.insert(subEntries, subEntry)
	else
		AddCustomMenuItem(label, callback)
	end
end

local function MakeContextMenuEntries(itemInfo, control)
	local useSubMenu = _settings.EnableSubMenus
	local subEntries = {}

	if (_settings.EnableItemPriceToChatBtn) then
		local currentLangName = GetCVar("language.2")
		currentLangName = string.upper(currentLangName)

		local priceToChatLangs = {}
		table.insert(priceToChatLangs, TamrielTradeCentreLangEnum.Default)

		for langEnum, isEnabled in pairs(_settings.AdditionalPriceToChatLang) do
			local langEnumName = TamrielTradeCentre:EnumToString(TamrielTradeCentreLangEnum, langEnum)

			if (isEnabled and langEnumName ~= currentLangName) then
				table.insert(priceToChatLangs, langEnum)
			end
		end

		local useLangSubMenu = #priceToChatLangs >= 2 and not useSubMenu
		local langSubEntries = {}

		local subEntriesToInsert = subEntries
		if (useLangSubMenu) then
			subEntriesToInsert = langSubEntries
		end

		for _, langEnum in pairs(priceToChatLangs) do
			InsertContextMenuEntry(useSubMenu or useLangSubMenu, subEntriesToInsert, 
				TamrielTradeCentre:GetString("TTC_PRICE_PRICETOCHAT", langEnum), 
				function ()
					TamrielTradeCentrePrice:PriceInfoToChat(itemInfo, langEnum)
				end)
		end

		if (useLangSubMenu) then
			AddCustomSubMenuItem(GetString(TTC_PRICE_PRICETOCHAT), langSubEntries)
		end
	end

	if (_settings.EnableItemSearchOnlineBtn and itemInfo.ID ~= nil) then
		InsertContextMenuEntry(useSubMenu, subEntries,
			GetString(TTC_SEARCHONLINE),
			function() 
				TamrielTradeCentrePrice:SearchOnline(itemInfo)
			end)
	end

	if (_settings.EnableItemPriceDetailOnlineBtn and itemInfo.ID ~= nil) then
		InsertContextMenuEntry(useSubMenu, subEntries,
			GetString(TTC_PRICEHISTORYONLINE),
			function() 
				TamrielTradeCentrePrice:PriceDetailOnline(itemInfo)
			end)
	end

	if (useSubMenu) then
		AddCustomSubMenuItem("TTC", subEntries)
	end

	ShowMenu(control)
end


local function AddContextMenuEntries(itemLink, control)
	if FCOIS then
		if FCOIS.ShouldInventoryContextMenuBeHiddden then
			if FCOIS.ShouldInventoryContextMenuBeHiddden() then 
				return 
			end
		else
			if FCOIS.preventerVars and FCOIS.preventerVars.dontShowInvContextMenu == true then 
				return 
			end
		end
	end

	local itemInfo = TamrielTradeCentre_ItemInfo:New(itemLink)
	if (itemInfo ~= nil) then
		MakeContextMenuEntries(itemInfo, control)
	end
end

local function OverWriteLinkMouseUpHandler()
	local base = ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp = function(link, button, control)
		base(link, button, control)
		
		if (button ~= MOUSE_BUTTON_INDEX_RIGHT or not TamrielTradeCentre:IsItemLink(link)) then
			return
		end

		if link ~= nil and TamrielTradeCentre:IsItemLink(link) then
			AddContextMenuEntries(link, control)
		end
	end
end

local function OverWriteInventoryShowContextMenuHandler()
	LibCustomMenu:RegisterContextMenu(
		function(inventorySlot, slotActions)
			local slotType = ZO_InventorySlot_GetType(inventorySlot)
			local link = nil
			if slotType == SLOT_TYPE_ITEM or slotType == SLOT_TYPE_EQUIPMENT or slotType == SLOT_TYPE_BANK_ITEM or slotType == SLOT_TYPE_GUILD_BANK_ITEM or 
				slotType == SLOT_TYPE_TRADING_HOUSE_POST_ITEM or slotType == SLOT_TYPE_REPAIR or slotType == SLOT_TYPE_CRAFTING_COMPONENT or 
				slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or slotType == SLOT_TYPE_CRAFT_BAG_ITEM or
				slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT then
				local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
				link = GetItemLink(bag, index)
			end
			if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
				link = GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(inventorySlot))
			end
			if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
				link = GetTradingHouseListingItemLink(ZO_Inventory_GetSlotIndex(inventorySlot))
			end
			if link ~= nil and TamrielTradeCentre:IsItemLink(link) then
				AddContextMenuEntries(link, inventorySlot)
			end
		end
	)
end

local function OverWriteToolTipFunction(toolTipControl, functionName, getItemLinkFunction)
	local base = toolTipControl[functionName]
	toolTipControl[functionName] = function(control, ...)
		base(control, ...)

		if (_settings.EnableItemToolTipPricing) then
			local itemLink = getItemLinkFunction(...)
			local itemInfo = TamrielTradeCentre_ItemInfo:New(itemLink)

			TamrielTradeCentrePrice:AppendPriceInfo(control, itemInfo)
		end
	end
end

local function AddPriceToolTipHook(hookObject, toolTipControl, functionName, getItemLinkFunction)
	SecurePostHook(hookObject, functionName, function(...)
		if (_settings.EnableItemToolTipPricing) then
			local itemLink = getItemLinkFunction(...)
			local itemInfo = TamrielTradeCentre_ItemInfo:New(itemLink)

			TamrielTradeCentrePrice:AppendPriceInfo(toolTipControl, itemInfo)
		end
	end)
end

local function GetWornItemLink(equipSlot)
	return GetItemLink(BAG_WORN, equipSlot)
end

local function GetItemLinkFirstParam(itemLink)
	return itemLink
end

local function ChangeItemQuality(itemLink, newSubType)
    local pattern = "(|H%d:item:%d+):(%d+)(:.*)"
    local newLink = itemLink:gsub(pattern, "%1:" .. newSubType .. "%3")
    return newLink
end

local function GetImprovedItemLink(itemLink)
	if (itemLink == nil) then
		return nil
	end

	local qualities = {[0] = 357, [1] = 366, [2] = 367, [3] = 368, [4] = 369, [5] = 370}
	local currentQuality = GetItemLinkQuality(itemLink)
	local newQuality = currentQuality;

	if (currentQuality < 5) then
		newQuality = qualities[currentQuality + 1]
	end
	
	return ChangeItemQuality(itemLink, newQuality)
end

function TamrielTradeCentrePrice:Init()
	TamrielTradeCentre:DebugWriteLine("TTC Price Init")
	_settings = TamrielTradeCentre.Settings

	local serverRegion = TamrielTradeCentre:GetCurrentServerRegion()
	if (serverRegion == "NA" and self.LoadPriceTableNA ~= nil) then
		self:LoadPriceTableNA()
	elseif (serverRegion == "EU" and self.LoadPriceTableEU ~= nil) then
		self:LoadPriceTableEU()
	end

	OverWriteToolTipFunction(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
	OverWriteToolTipFunction(ItemTooltip, "SetBagItem", GetItemLink)
	OverWriteToolTipFunction(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
	OverWriteToolTipFunction(ItemTooltip, "SetLootItem", GetLootItemLink)
	OverWriteToolTipFunction(ItemTooltip, "SetTradeItem", GetTradeItemLink)
	OverWriteToolTipFunction(ItemTooltip, "SetStoreItem", GetStoreItemLink)
	OverWriteToolTipFunction(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
	OverWriteToolTipFunction(ItemTooltip, "SetWornItem", GetWornItemLink)
	OverWriteToolTipFunction(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)
	OverWriteToolTipFunction(PopupTooltip, "SetLink", GetItemLinkFirstParam)
	
	AddPriceToolTipHook(ZO_SmithingImprovement, ZO_SmithingTopLevelImprovementPanelResultTooltip, "SetupResultTooltip", function(_, itemToImproveBagId, itemToImproveSlotIndex)
			local itemLink = GetItemLink(itemToImproveBagId, itemToImproveSlotIndex)
			if (itemLink == nil) then
				return
			end
			return GetImprovedItemLink(itemLink)
		end)
	
	AddPriceToolTipHook(ZO_SmithingCreation, ZO_SmithingTopLevelCreationPanelResultTooltip, "SetupResultTooltip", function(_, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
			return GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
		end)

	AddPriceToolTipHook(ZO_Provisioner, ZO_ProvisionerTopLevelTooltip, "RefreshRecipeDetails", function(control)
			local recipeData = control:GetRecipeData()
			if (recipeData == nil) then 
				return
			end
			local recipeListIndex = control:GetSelectedRecipeListIndex()
			local recipeIndex = control:GetSelectedRecipeIndex()

			return GetRecipeResultItemLink(recipeListIndex, recipeIndex)
		end)

	AddPriceToolTipHook(ZO_Enchanting, ZO_EnchantingTopLevelTooltip, "UpdateTooltip", function()
			return ENCHANTING:GetResultItemLink()
		end)

	AddPriceToolTipHook(ZO_Alchemy, ZO_AlchemyTopLevelTooltip, "UpdateTooltip", function()
			return ALCHEMY:GetResultItemLink()
		end)

	if (AwesomeGuildStore) then
		AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.AFTER_INITIAL_SETUP, function()
			OverWriteToolTipFunction(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
		end)
	else
		OverWriteToolTipFunction(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
	end
	

	OverWriteLinkMouseUpHandler()
	OverWriteInventoryShowContextMenuHandler()
	TamrielTradeCentrePrice.SavedVars = ZO_SavedVars:NewAccountWide("TTCPriceVars", 1)
end