-- ------------- --
-- Price Tracker --
-- ------------- --

PriceTracker = {
	queryDelay = 3000,
	isSearching = false,
	settingsVersion = 0.3,
	icons = {
		gold = "EsoUI/Art/currency/currency_gold.dds"
	},
	colors = {
		default = "|c" .. ZO_TOOLTIP_DEFAULT_COLOR:ToHex(),
		instructional = "|c" .. ZO_TOOLTIP_INSTRUCTIONAL_COLOR:ToHex(),
		title = "|c00B5FF",
	},
	selectedItem = {},
}
local PriceTracker = PriceTracker

-- Addon initialization
function PriceTracker:OnLoad(eventCode, addOnName)
	if(addOnName ~= "PriceTracker") then return end

	EVENT_MANAGER:RegisterForEvent("OnSearchResultsReceived", EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED, function(...) self:OnSearchResultsReceived(...) end)
	EVENT_MANAGER:RegisterForEvent("OnSearchResultsError", EVENT_TRADING_HOUSE_ERROR, function(...) self:OnSearchResultsError(...) end)
	EVENT_MANAGER:RegisterForEvent("OnTradingHouseOpened", EVENT_OPEN_TRADING_HOUSE, function(...) self:OnTradingHouseOpened(...) end)
	EVENT_MANAGER:RegisterForEvent("OnTradingHouseClosed", EVENT_CLOSE_TRADING_HOUSE, function(...) self:OnTradingHouseClosed(...) end)
	EVENT_MANAGER:RegisterForEvent("OnTradingHouseCooldown", EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE, function(...) self:OnTradingHouseCooldown(...) end)

	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, PriceTracker.OnLinkClicked, self)

	ZO_PreHookHandler(ItemTooltip, "OnUpdate", function() self:OnUpdateTooltip(moc(), ItemTooltip) end)
	ZO_PreHookHandler(ItemTooltip, "OnHide", function() self:OnHideTooltip(ItemTooltip) end)

	ZO_PreHookHandler(PopupTooltip, "OnUpdate", function() self:OnUpdateTooltip(self.clickedItem, PopupTooltip) end)
	ZO_PreHookHandler(PopupTooltip, "OnHide", function() self:OnHideTooltip(PopupTooltip) end)


	PriceTracker.enchantingTable:OnLoad(eventCode, addOnName)

	SLASH_COMMANDS["/pt"] = function(...) self:CommandHandler(...) end
	SLASH_COMMANDS["/pricetracker"] = function(...) self:CommandHandler(...) end

	local defaults = {
		itemList = {},
		algorithm = self.menu.algorithmTable[1],
		showMinMax = true,
		showSeen = true,
		ignoreFewItems = false,
		keyPress = self.menu.keyTable[1],
		isPlaySound = false,
		playSound = 1,
	}

	-- Load saved settings
	self.settings = ZO_SavedVars:NewAccountWide("PriceTrackerSettings", self.settingsVersion, nil, defaults)

	-- Do some housekeeping and remove inparsable items 
	self:Housekeeping()

	-- Create a button in the trading house window
	self.button = PriceTrackerControlButton
	self.button:SetParent(ZO_TradingHouseLeftPaneBrowseItemsCommon)
	self.button:SetWidth(ZO_TradingHouseLeftPaneBrowseItemsCommonQuality:GetWidth())

	self.menu:InitAddonMenu(addOnName)
end

-- Handle slash commands
function PriceTracker:CommandHandler(text)
	if not text or text == "" or text == "help" then
		self:ShowHelp()
		return
	end

	if text == "reset" or text == "clear" then
		self.settings.itemList = {}
		return
	end

	if text == "clean" then
		self:CleanItemList()
		return
	end

	-- Hidden option
	if text == "housekeeping" then
		self:Housekeeping()
		return
	end

end

function PriceTracker:ShowHelp()
	d("To scan all item prices in all guild stores, click the 'Scan Prices' button in the guild store window.")
	d(" ")
	d("/pt help - Show this help")
	d("/pt clear - Clear stored price values")
	d("/pt clean - Remove stale items (experimental)")
	d("/ptsetup - Open the addon setup menu")
end

-- This method makes sure the item list is intact and parsable, in order to avoid exceptions later on
function PriceTracker:Housekeeping()
	if not self.settings.itemList then
		self.settings.itemList = {}
	end

	-- Preserve prices from previous UI versions
	if PriceTrackerSettings["Default"][""] ~= nil then
		PriceTrackerSettings["Default"][GetDisplayName()] = PriceTrackerSettings["Default"][""]
		PriceTrackerSettings["Default"][""] = nil
		SLASH_COMMANDS["/reloadui"]()
	end

	for k, v in pairs(self.settings.itemList) do
		-- Remove any empty items
		for level, item in pairs(v) do
			for p, q in pairs(item) do
				if not q.purchasePrice or not q.stackCount then v[p] = nil end
			end
			if not next(item) then self.settings.itemList[k][level] = nil end
		end
		if not next(v) then self.settings.itemList[k] = nil end
	end
end

function PriceTracker:OnUpdateTooltip(item, tooltip)
	if not tooltip then tooltip = ItemTooltip end
	if not item or not item.dataEntry or not item.dataEntry.data or not self.menu:IsKeyPressed() or self.selectedItem[tooltip] == item then return end
	self.selectedItem[tooltip] = item
	local stackCount = item.dataEntry.data.stackCount or item.dataEntry.data.stack
	if not stackCount then return end

	local itemLink = self:GetItemLink(item)
	local _, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
	local level = self:GetItemLevel(itemLink)

	if not itemLink then
		if item.dataEntry and item.dataEntry.data and item.dataEntry.data.itemId then
			itemId = item.dataEntry.data.itemId
			level = tonumber(item.dataEntry.data.level)
		else
			return
		end
	end

	local matches = self:GetMatches(itemId, level)
	if not matches then return end

	local item = self:SuggestPrice(matches)
	if not item then return end

	ZO_Tooltip_AddDivider(tooltip)
	tooltip:AddLine("Price Tracker", "ZoFontHeader2")
	local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
	tooltip:AddLine(self:FormatTooltipLine("Suggested price:", math.floor(item.purchasePrice / item.stackCount)), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, CENTER, true)
	if stackCount > 1 then
		tooltip:AddLine(self:FormatTooltipLine("Stack price:", math.floor(item.purchasePrice / item.stackCount * stackCount)), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, CENTER, true)
	end
	if self.settings.showMinMax then
		local minItem = self.mathUtils:Min(matches)
		local maxItem = self.mathUtils:Max(matches)
		local minPrice = math.floor(minItem.purchasePrice / minItem.stackCount)
		local maxPrice = math.floor(maxItem.purchasePrice / maxItem.stackCount)
		tooltip:AddLine(self:FormatTooltipLine("Min (each / stack):", minPrice, minPrice * stackCount, minItem.guildName), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, CENTER, true)
		tooltip:AddLine(self:FormatTooltipLine("Max (each / stack):", maxPrice, maxPrice * stackCount, maxItem.guildName), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, CENTER, true)
	end
	if self.settings.showSeen then
		tooltip:AddLine("Seen " .. #matches .. " times", "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, CENTER, false)
	end
end

function PriceTracker:OnHideTooltip(tooltip)
	self.selectedItem[tooltip] = nil
	self.clickedItem = nil
end

function PriceTracker:OnScanPrices()
	if self.isSearching then return end

	self.button:SetEnabled(false)
	self.isSearching = true
	self.numOfGuilds = GetNumTradingHouseGuilds()
	self.currentGuild = 0
	self.currentPage = 0
	while not CanSellOnTradingHouse(self.currentGuild) and self.currentGuild < self.numOfGuilds do
		self.currentGuild = self.currentGuild + 1
	end

	SelectTradingHouseGuildId(self.currentGuild)
	zo_callLater(function() ExecuteTradingHouseSearch(0, TRADING_HOUSE_SORT_SALE_PRICE, true) end, GetTradingHouseCooldownRemaining() + 1000)
end

function PriceTracker:OnTradingHouseOpened(eventCode)
	self.isSearching = false
end

function PriceTracker:OnSearchResultsReceived(eventId, guildId, numItemsOnPage, currentPage, hasMorePages)
	if not self.isSearching then return end

	for i = 1, numItemsOnPage do
		self:AddItem(i)
	end

	self.currentPage = currentPage

	if hasMorePages then
		zo_callLater(function() ExecuteTradingHouseSearch(currentPage + 1, TRADING_HOUSE_SORT_SALE_PRICE, true) end, GetTradingHouseCooldownRemaining() + 1000)
	else
		if self.currentGuild < self.numOfGuilds then
			self.currentGuild = self.currentGuild + 1
			while not CanSellOnTradingHouse(self.currentGuild) and self.currentGuild < self.numOfGuilds do
				self.currentGuild = self.currentGuild + 1
			end

			zo_callLater(function() SelectTradingHouseGuildId(self.currentGuild) end, self.queryDelay)
			zo_callLater(function() ExecuteTradingHouseSearch(0, TRADING_HOUSE_SORT_SALE_PRICE, true) end, GetTradingHouseCooldownRemaining() + 1000)
		else
			if self.settings.isPlaySound then
				PlaySound(self.settings.playSound)
			end
			self:OnTradingHouseClosed()
		end
	end
end

function PriceTracker:OnTradingHouseCooldown(eventCode, cooldownMilliseconds)
	self.button:SetEnabled(not self.isSearching)
end

function PriceTracker:OnSearchResultsError(eventCode, errorCode)
	if errorCode == TRADING_HOUSE_RESULT_NOT_OPEN then
		self.button:SetEnabled(not self.isSearching)
		return
	end

	d("Error scanning prices.  Please try again.")
	self:OnTradingHouseClosed()
end

function PriceTracker:OnTradingHouseClosed(eventCode)
	self.isSearching = false
end

function PriceTracker:OnLinkClicked(rawLink, mouseButton, linkText, color, linkType, itemId, ...)
	if linkType ~= "item" then return end

	local _, sellPrice, _, _, _ = GetItemLinkInfo(rawLink)
	local _, _, _, _, _, level = ZO_LinkHandler_ParseLink(rawLink)
	local item = {
		dataEntry = {
			data = {
				name = self:NormalizeName(string.sub(linkText, 2, #linkText - 1)),
				stackCount = 1,
				purchasePrice = sellPrice,
				itemId = itemId,
				level = level
			}
		}
	}
	self.clickedItem = item
end

function PriceTracker:AddItem(index)
	local icon, itemName, quality, stackCount, sellerName, timeRemaining, purchasePrice = GetTradingHouseSearchResultItemInfo(index)
	local itemLink = GetTradingHouseSearchResultItemLink(index)
	local _, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
	local level = self:GetItemLevel(itemLink)

	if not purchasePrice or not stackCount then return end

	local item = {
		expiry = timeRemaining + GetTimeStamp(),
		icon = icon,
		name = itemName,
		normalizedName = self:NormalizeName(itemName),
		quality = quality,
		stackCount = stackCount,
		sellerName = sellerName,
		purchasePrice = purchasePrice,
		eachPrice = purchasePrice / stackCount,
		guildId = self.currentGuild,
		guildName = GetGuildName(self.currentGuild)
	}

	if not self.settings.itemList[itemId] then
		self.settings.itemList[itemId] = {}
	end

	if not self.settings.itemList[itemId][level] then
		self.settings.itemList[itemId][level] = {}
	end

	-- Do not add items that are already in the database
	if not self.settings.itemList[itemId][level][item.expiry] then
		self.settings.itemList[itemId][level][item.expiry] = item
	end
end

function PriceTracker:CleanItemList()
	local timestamp = GetTimeStamp()
	for k, v in pairs(self.settings.itemList) do
		for level, item in pairs(v) do
			for itemK, itemV in pairs(item) do
				if itemV.expiry > timestamp then
					table.remove(item, itemK)
				end
			end
		end
	end
end

function PriceTracker:GetMatches(itemId, itemLevel)
	if not self.settings.itemList or not self.settings.itemList[itemId] then
		return nil
	end

	local limitToGuild = self.settings.limitToGuild or 1

	local matches = {}
	for level, items in pairs(self.settings.itemList[itemId]) do
		level = tonumber(level)
		if not itemLevel or itemLevel == level or (itemLevel < 2 and level < 2) then
			local index = next(items)
			while index do
				if limitToGuild == 1 or items[index].guildId == GetGuildId(limitToGuild - 1) then
					table.insert(matches, items[index])
				end
				index = next(items, index)
			end
		end
	end
	local minSeen = 0
	if self.settings.ignoreFewItems then minSeen = 2 end
	if #matches <= minSeen then return nil end
	return matches
end

function PriceTracker:SuggestPrice(matches)
	if self.settings.algorithm == self.menu.algorithmTable[1] then
		return self.mathUtils:WeightedAverage(matches)
	end

	if self.settings.algorithm == self.menu.algorithmTable[2] then
		return self.mathUtils:Median(matches)
	end

	if self.settings.algorithm == self.menu.algorithmTable[3] then
		return self.mathUtils:Mode(matches)
	end

	d("Error deciding how to calculate suggested price")
	return nil
end

function PriceTracker:FormatTooltipLine(title, price1, price2, guild)
	if price2 then
		price1 = price1 .. " / " .. price2
	end
	local str
	if guild then
		str = "%-20.20s  (%-10.10s)"
	else
		str = "%-40.40s  %1.1s"
	end
	str = str .. " %12.12s%s"
	return string.format(str, title, guild or "", price1, zo_iconFormat(self.icons.gold, 16, 16))
end

function PriceTracker:NormalizeName(name)
	return zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
end

function PriceTracker:GetItemLink(item)
	if not item or not item.GetParent then return nil end

	local parent = item:GetParent()
	if not parent then return nil end

	local parentName = parent:GetName()
	if parentName.find(parentName, "BackpackContents") then
		return GetItemLink(item.dataEntry.data.bagId, item.dataEntry.data.slotIndex, LINK_STYLE_DEFAULT)
	end
	if parentName == "ZO_StoreWindowListContents" then
		return GetStoreItemLink(item.dataEntry.data.slotIndex, LINK_STYLE_DEFAULT)
	end
	if parentName == "ZO_TradingHouseItemPaneSearchResultsContents" then
		if item.dataEntry.data.timeRemaining > 0 then
			return GetTradingHouseSearchResultItemLink(item.dataEntry.data.slotIndex)
		else
			return nil
		end
	end
	if parentName == "ZO_TradingHousePostedItemsListContents" then
		return GetTradingHouseListingItemLink(item.dataEntry.data.slotIndex)
	end
	if parentName == "ZO_BuyBackListContents" then
		return GetBuybackItemLink(item.dataEntry.data.slotIndex)
	end
	d("Could not get item link for " .. parentName)
	return nil
end

function PriceTracker:GetItemLevel(itemLink)
	local level = GetItemLinkRequiredLevel(itemLink)
	if level == 50 then
		level = level + GetItemLinkRequiredVeteranRank(itemLink)
	end
	return level
end

EVENT_MANAGER:RegisterForEvent("PriceTrackerLoaded", EVENT_ADD_ON_LOADED, function(...) PriceTracker:OnLoad(...) end)
