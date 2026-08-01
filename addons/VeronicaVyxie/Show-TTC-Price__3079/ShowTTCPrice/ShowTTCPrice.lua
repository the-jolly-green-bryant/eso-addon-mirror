local Addon = {name = "ShowTTCPrice", version = "17.4.0", SV_version = 3}

local DropdownPrices = {None = "None", Average = "Avg", Suggested = "SuggestedPrice", Sales_Average = "SaleAvg", Min = "Min", Max = "Max"}
local CoinIcon = "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"
local Settings = {}
local Colors = {Orange = "|cFCBA03", Dark_Orange = "|cFC8403", White = "|cFFFFFF", Green = "|c24FC03", Dark_Green = "|c20B00B", Pink = "|cff9d9d"}
local TogglePriceButtons = {}
local GuildStoreHook1 = false
local GuildStoreHook2 = false
local SV_default = {
	--general
    Enabled = true,
    EnableToggleButton = false,
    PreferredPrice = "Sales Average",
    PriceToShow = "Stack and Unit",
	FallbackPrice = "Average",
    RoundNumbers = true,
	--filters
    IgnoreBoundItems = true,
    IgnoreTrash = true,
    IgnoreBelowVendor = true,
	--
    HighlightReq = false,
    DesiredValue = 5000,
	--
    MinimumReq = false,
    RequiredValue = 25,
	--guild store
    EnableInGuildStore = true,
    GuildStoreInfoToShow = "Profit",
	ListingPreferredPrice = "Sales Average",
	FallbackPriceGS = "None",
	--
    HighlightRiskyDeals = true,
    RiskyDealsListingsCount = 10,
	--AwesomeGuildStore
    EnableAwesomeGuildStoreIntegration = true,
    EnableDealFilter = true,
    EnableProfitFilter = true,
	ProfitFilterSliderMin = "0",
}

local function SetupSettings()
	local LAM = LibAddonMenu2
	if not LAM then return end
	Settings = Addon.SavedVariables
	if Settings.PriceToShow == "Both" then Settings.PriceToShow = "Stack and Unit" end

	local PanelName = "ShowTTCPrice_Settings"
	local PanelData = {type = "panel", name = "Show TTC Price", displayName = "Show TTC Price", author = "VeronicaVyxie", version = Addon.version, registerForDefaults = true}
	LAM:RegisterAddonPanel(PanelName, PanelData)

	local OptionsData = {
		{
		type = "header", name = "Settings", width = "full"
		},
		{
		type = "checkbox",
		name = "Show toggle button",
		tooltip = "Add a toggle above your inventory that lets you swap between TTC and ESO prices" .. " (same function as " .. Colors.Orange .. "Keybindings > Show TTC Price > Toggle TTC Price|r)" .. "\n\nDefault: " .. tostring(SV_default.EnableToggleButton),
		requiresReload = true,
		getFunc = function() return Settings.EnableToggleButton end,
		setFunc = function(value) Settings.EnableToggleButton = value end,
		default = SV_default.EnableToggleButton
		},
		{
		type = "dropdown",
		name = "Preferred price",
		tooltip = "(None = ESO price)" .. "\n\nDefault: " .. tostring(SV_default.PreferredPrice),
		choices = {"None", "Suggested", "Average", "Sales Average", "Min", "Max"},
		getFunc = function() return Settings.PreferredPrice end,
		setFunc = function(choice) Settings.PreferredPrice = choice end,
		default = SV_default.PreferredPrice
		},
		{
		type = "dropdown",
		name = "Price to show",
		choices = {"Stack", "Unit", "Stack and Unit", "Stack (ESO and TTC)", "Unit (ESO and TTC)"},
		tooltip = "Default: " .. tostring(SV_default.PriceToShow),
		getFunc = function() return Settings.PriceToShow end,
		setFunc = function(choice) Settings.PriceToShow = choice end,
		default = SV_default.PriceToShow
		},
		{
		type = "dropdown",
		name = "Fallback price",
		tooltip = "(None = 0)" .. "\n\nDefault: " .. tostring(SV_default.FallbackPrice),
		choices = {"None", "Average"},
		getFunc = function() return Settings.FallbackPrice end,
		setFunc = function(choice) Settings.FallbackPrice = choice end,
		default = SV_default.FallbackPrice
		},
		{
		type = "checkbox",
		name = "Round numbers",
		tooltip = "Default: " .. tostring(SV_default.RoundNumbers),
		getFunc = function() return Settings.RoundNumbers end,
		setFunc = function(value) Settings.RoundNumbers = value end,
		default = SV_default.RoundNumbers
		},
		{
		type = "header", name = "Filters", width = "full"
		},
		{
		type = "checkbox",
		name = "Ignore bound items",
		tooltip = "Default: " .. tostring(SV_default.IgnoreBoundItems),
		getFunc = function() return Settings.IgnoreBoundItems end,
		setFunc = function(value) Settings.IgnoreBoundItems = value end,
		default = SV_default.IgnoreBoundItems
		},
		{
		type = "checkbox",
		name = "Ignore items of type 'Trash'",
		tooltip = "Ignore items like Carapace, Daedra Husk, Foul Hide, etc." .. "\n\nDefault: " .. tostring(SV_default.IgnoreTrash),
		getFunc = function() return Settings.IgnoreTrash end,
		setFunc = function(value) Settings.IgnoreTrash = value end,
		default = SV_default.IgnoreTrash
		},
		{
		type = "checkbox",
		name = "Ignore below default sell price",
		tooltip = "Ignore items if their TTC price is less than their ESO price" .. "\n\nDefault: " .. tostring(SV_default.IgnoreBelowVendor),
		getFunc = function() return Settings.IgnoreBelowVendor end,
		setFunc = function(value) Settings.IgnoreBelowVendor = value end,
		default = SV_default.IgnoreBelowVendor
		},
		{
		type = "divider", alpha = 0.5, width = "half"
		},
		{
		type = "checkbox",
		name = "Highlight above value",
		tooltip = Colors.Dark_Green .. "Highlight|r" .. " items if their TTC price is greater than or equal to Desired value" .. "\n\nDefault: " .. tostring(SV_default.HighlightReq),
		getFunc = function() return Settings.HighlightReq end,
		setFunc = function(value) Settings.HighlightReq = value end,
		default = SV_default.HighlightReq
		},
		{
		type = "slider",
		name = "Desired value",
		min = 0, max = 1000000, width = "full",
		tooltip = "Default: " .. tostring(SV_default.DesiredValue),
		getFunc = function() return Settings.DesiredValue end,
		setFunc = function(value) Settings.DesiredValue = value end,
		default = SV_default.DesiredValue
		},
		{
		type = "divider", alpha = 0.5, width = "half"
		},
		{
		type = "checkbox",
		name = "Ignore below value",
		tooltip = "Ignore items if their TTC price is less than Required value" .. "\n\nDefault: " .. tostring(SV_default.MinimumReq),
		getFunc = function() return Settings.MinimumReq end,
		setFunc = function(value) Settings.MinimumReq = value end,
		default = SV_default.MinimumReq
		},
		{
		type = "slider",
		name = "Required value",
		min = 0, max = 1000000, width = "full",
		tooltip = "Default: " .. tostring(SV_default.RequiredValue),
		getFunc = function() return Settings.RequiredValue end,
		setFunc = function(value) Settings.RequiredValue = value end,
		default = SV_default.RequiredValue
		},
		{
		type = "header", name = "Guild Store", width = "full"
		},
		{
		type = "checkbox",
		name = "Enable Guild Store features",
		requiresReload = true,
		tooltip = "Default: " .. tostring(SV_default.EnableInGuildStore),
		getFunc = function() return Settings.EnableInGuildStore end,
		setFunc = function(value) Settings.EnableInGuildStore = value end,
		default = SV_default.EnableInGuildStore
		},
		{
		type = "dropdown",
		name = "Guild Store info to show",
		choices = {"None", "Discount", "Profit"},
		tooltip = "Default: " .. tostring(SV_default.GuildStoreInfoToShow),
		getFunc = function() return Settings.GuildStoreInfoToShow end,
		setFunc = function(choice) Settings.GuildStoreInfoToShow = choice end,
		default = SV_default.GuildStoreInfoToShow
		},
		{
		type = "dropdown",
		name = "Guild Store listing compared price",
		tooltip = "Choose what price is being compared for Discount and Profit" .. "\n\nDefault: " .. tostring(SV_default.ListingPreferredPrice),
		choices = {"Suggested", "Average", "Sales Average"},
		getFunc = function() return Settings.ListingPreferredPrice end,
		setFunc = function(choice) Settings.ListingPreferredPrice = choice end,
		default = SV_default.ListingPreferredPrice
		},
		{
		type = "dropdown",
		name = "Fallback price",
		tooltip = "(None = 0)" .. "\n\nDefault: " .. tostring(SV_default.FallbackPriceGS),
		choices = {"None", "Average"},
		getFunc = function() return Settings.FallbackPriceGS end,
		setFunc = function(choice) Settings.FallbackPriceGS = choice end,
		default = SV_default.FallbackPriceGS
		},
		{
		type = "divider", alpha = 0.5, width = "half"
		},
		{
		type = "checkbox",
		name = "Highlight risky deals",
		tooltip = Colors.Pink .. "Highlight|r" .. " Discount and Profit of items with few listings" .. "\n\nDefault: " .. tostring(SV_default.HighlightRiskyDeals),
		getFunc = function() return Settings.HighlightRiskyDeals end,
		setFunc = function(value) Settings.HighlightRiskyDeals = value end,
		default = SV_default.HighlightRiskyDeals
		},
		{
		type = "slider",
		name = "Required listings",
		min = 0, max = 1000000, width = "full",
		tooltip = "Number of listings required to consider the item's pricing data reliable" .. "\n\nDefault: " .. tostring(SV_default.RiskyDealsListingsCount),
		getFunc = function() return Settings.RiskyDealsListingsCount end,
		setFunc = function(value) Settings.RiskyDealsListingsCount = value end,
		default = SV_default.RiskyDealsListingsCount
		},
		{
		type = "divider", alpha = 0.5, width = "half"
		},
		{
		type = "checkbox",
		name = "Enable AwesomeGuildStore integration",
		tooltip = "Add Discount and Profit filters to AwesomeGuildStore" .. "\n\nDefault: " .. tostring(SV_default.EnableAwesomeGuildStoreIntegration),
		requiresReload = true,
		getFunc = function() return Settings.EnableAwesomeGuildStoreIntegration end,
		setFunc = function(value) Settings.EnableAwesomeGuildStoreIntegration = value end,
		default = SV_default.EnableAwesomeGuildStoreIntegration
		},
		{
		type = "checkbox",
		name = "Enable Deal Filter",
		requiresReload = true,
		tooltip = "Default: " .. tostring(SV_default.EnableDealFilter),
		getFunc = function() return Settings.EnableDealFilter end,
		setFunc = function(value) Settings.EnableDealFilter = value end,
		default = SV_default.EnableDealFilter
		},
		{
		type = "checkbox",
		name = "Enable Profit Filter",
		requiresReload = true,
		tooltip = "Default: " .. tostring(SV_default.EnableProfitFilter),
		getFunc = function() return Settings.EnableProfitFilter end,
		setFunc = function(value) Settings.EnableProfitFilter = value end,
		default = SV_default.EnableProfitFilter
		},
		{
		type = "dropdown",
		name = "Profit Filter slider minimum value",
		choices = {"0", "-1000000"},
		tooltip = "Default: " .. tostring(SV_default.ProfitFilterSliderMin),
		requiresReload = true,
		getFunc = function() return Settings.ProfitFilterSliderMin end,
		setFunc = function(choice) Settings.ProfitFilterSliderMin = choice end,
		default = SV_default.ProfitFilterSliderMin
		},
	}
	LAM:RegisterOptionControls(PanelName, OptionsData)
end

function ShowTTCPrice_TogglePrices()
	Settings.Enabled = not Settings.Enabled
	if Settings.EnableToggleButton == true then
		--change button text
		for i = 1, #TogglePriceButtons do
			if Settings.Enabled then
				TogglePriceButtons[i]:SetText("TTC " .. CoinIcon)
			else
				TogglePriceButtons[i]:SetText("ESO " .. CoinIcon)
			end
		end
	end
	--refresh inventories
	PLAYER_INVENTORY:UpdateList(INVENTORY_BACKPACK)
	PLAYER_INVENTORY:UpdateList(INVENTORY_CRAFT_BAG)
	PLAYER_INVENTORY:UpdateList(INVENTORY_BANK)
	PLAYER_INVENTORY:UpdateList(INVENTORY_HOUSE_BANK)
	PLAYER_INVENTORY:UpdateList(INVENTORY_GUILD_BANK)
	--refresh crafting station
	local interactionType = GetCraftingInteractionType()
	if interactionType ~= CRAFTING_TYPE_INVALID then
		if interactionType == CRAFTING_TYPE_ENCHANTING then
			ENCHANTING.inventory:PerformFullRefresh()
		elseif interactionType == CRAFTING_TYPE_BLACKSMITHING or interactionType == CRAFTING_TYPE_CLOTHIER or interactionType == CRAFTING_TYPE_WOODWORKING or interactionType == CRAFTING_TYPE_JEWELRYCRAFTING then
			if SMITHING.mode == SMITHING_MODE_REFINMENT then
				SMITHING.refinementPanel.inventory:PerformFullRefresh()
			elseif SMITHING.mode == SMITHING_MODE_DECONSTRUCTION or SMITHING.mode == SMITHING_MODE_IMPROVEMENT then 
				SMITHING.deconstructionPanel.inventory:PerformFullRefresh()
				SMITHING.improvementPanel.inventory:PerformFullRefresh()
			end
		end
	end
end

local function RoundNumber(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

local function FormatNumber(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

local function RoundAndFormat(number)
	if Settings.RoundNumbers then number = RoundNumber(number) end
	return FormatNumber(number)
end

local function ShowTTCPrice(control, slot)
	--data and filters
	if Settings.PreferredPrice == "None" or not Settings.Enabled then return end --if enabled
	local ItemData = control.dataEntry.data
    local BagId = ItemData.bagId
    local SlotIndex = ItemData.slotIndex
    local ItemLink =  GetItemLink(BagId, SlotIndex)
	if not ItemLink then return end
	if IsItemLinkBound(ItemLink) and Settings.IgnoreBoundItems then return end --if bound
	local ItemType, SpecializedItemType = GetItemLinkItemType(ItemLink)
	if SpecializedItemType == SPECIALIZED_ITEMTYPE_TRASH and Settings.IgnoreTrash then return end --if trash
	local SellPriceControl = control:GetNamedChild("SellPriceText")
	if not SellPriceControl then return end
	local ItemPriceData = TamrielTradeCentrePrice:GetPriceInfo(ItemLink)
	if not ItemPriceData then return end
	local PreferredPrice = DropdownPrices[Settings.PreferredPrice:gsub(" ", "_")]
	local FallbackPrice = Settings.FallbackPrice == "None" and 0 or ItemPriceData.Avg
	local TTCPrice = ItemPriceData[PreferredPrice] or FallbackPrice --fallback to 0 or Average if there's no data for PreferredPrice
	if TTCPrice < ItemData.sellPrice and Settings.IgnoreBelowVendor then return end --if less than ESO price
	if TTCPrice < Settings.RequiredValue and Settings.MinimumReq then return end --if less than RequiredValue
	ItemData.sellPriceTTC = TTCPrice
	ItemData.stackSellPriceTTC = TTCPrice * ItemData.stackCount
	--round and format
	local Price_unit_TTC = RoundAndFormat(TTCPrice)
	local Price_stack_TTC =  RoundAndFormat(ItemData.stackSellPriceTTC)
	local Price_unit_ESO =  RoundAndFormat(ItemData.sellPrice)
	local Price_stack_ESO =  RoundAndFormat(ItemData.stackSellPrice)
	local NewPriceText = ""
	local PriceFormats = {
		["Stack and Unit"] = Colors.Orange .. Price_stack_TTC .. "|r " .. CoinIcon .. "\n" .. Colors.White .. "@|r" .. Colors.Dark_Orange .. Price_unit_TTC .. "|r " .. CoinIcon,
		["Stack"] = Colors.Orange .. Price_stack_TTC.. "|r " .. CoinIcon,
		["Unit"] = Colors.Dark_Orange .. Price_unit_TTC .. "|r " .. CoinIcon,
		["Stack (ESO and TTC)"] = Colors.White .. Price_stack_ESO .. "|r " .. CoinIcon .. "\n" .. Colors.Orange .. Price_stack_TTC .. "|r " .. CoinIcon,
		["Unit (ESO and TTC)"] = Colors.White .. Price_unit_ESO .. "|r " .. CoinIcon .. "\n" .. Colors.Dark_Orange .. Price_unit_TTC .. "|r " .. CoinIcon,
	}
	local HighlightedPriceFormats = {
		["Stack and Unit"] = Colors.Green .. Price_stack_TTC .. "|r " .. CoinIcon .. "\n" .. Colors.White .. "@|r" .. Colors.Dark_Green .. Price_unit_TTC .. "|r " .. CoinIcon,
		["Stack"] = Colors.Green .. Price_stack_TTC .. "|r " .. CoinIcon,
		["Unit"] = Colors.Dark_Green .. Price_unit_TTC .. "|r " .. CoinIcon,
		["Stack (ESO and TTC)"] = Colors.White .. Price_stack_ESO .. "|r " .. CoinIcon .. "\n" .. Colors.Green .. Price_stack_TTC .. "|r " .. CoinIcon,
		["Unit (ESO and TTC)"] = Colors.White .. Price_unit_ESO .. "|r " .. CoinIcon .. "\n" .. Colors.Dark_Green .. Price_unit_TTC .. "|r " .. CoinIcon,
	}
	local PriceToShow = Settings.PriceToShow
	if ItemData.stackCount == 1 and PriceToShow == "Stack and Unit" then PriceToShow = "Stack" end
	if Settings.HighlightReq and TTCPrice >= Settings.DesiredValue then --if greater than DesiredValue
		NewPriceText = HighlightedPriceFormats[PriceToShow]
	else
		NewPriceText = PriceFormats[PriceToShow]
	end
	SellPriceControl:SetText(NewPriceText)
end

local function CheckDeal(itemLink, purchasePrice, stackCount, usingFallback)
    local deal = -1
	local discount = 0
	local profit = -1
    local ItemPriceData = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
    if not ItemPriceData then return 2, discount, profit, 0 end
	local PreferredPrice = DropdownPrices[Settings.ListingPreferredPrice:gsub(" ", "_")]
	local FallbackPrice = Settings.FallbackPriceGS == "None" and 0 or ItemPriceData.Avg
	local ComparedPrice = ItemPriceData[PreferredPrice] or FallbackPrice --fallback to 0 or Average if there's no data for PreferredPrice
	local usingFallback = not ItemPriceData[PreferredPrice]
    local EntryCount = ItemPriceData.EntryCount or 1
	local UnitPrice = purchasePrice / stackCount
	profit = (ComparedPrice - UnitPrice) * stackCount
	discount = tonumber(string.format('%.2f', ((ComparedPrice - UnitPrice) / ComparedPrice) * 100))
	if ((discount >= 85 and EntryCount > 35) or (discount >= 70 and EntryCount > 80)) then
        deal = 5 --Excellent
	elseif ((discount >= 65 and EntryCount > 35) or (discount >= 50 and EntryCount > 80)) then
        deal = 4 --Amazing
	elseif ((discount >= 45 and EntryCount > 35) or (discount >= 30 and EntryCount > 80)) then
        deal = 3 --Great
	elseif ((discount >= 25 and EntryCount > 35) or (discount >= 10 and EntryCount > 80)) then
        deal = 2 --Good
    elseif (discount >= 0) then
        deal = 1 --OK
    else
        deal = 0 --Overpriced
    end
	return deal, discount, profit, EntryCount, usingFallback
end

local function ShowTTCDeal(rowControl, result)
	if not result.itemLink then return end

	local DealControl = rowControl:GetNamedChild('DealControl')
	if Settings.GuildStoreInfoToShow == "None" then 
		if DealControl then
			DealControl:SetHidden(true)
		end
		return
	end
	
	if not DealControl then
		DealControl = rowControl:CreateControl(rowControl:GetName() .. 'DealControl', CT_LABEL)
		local TimeControl = rowControl:GetNamedChild('TimeRemaining')
		local NameControl = rowControl:GetNamedChild('Name')
		TimeControl:ClearAnchors()
		TimeControl:SetAnchor(LEFT, NameControl, RIGHT, 20)
		DealControl:SetAnchor(TOPLEFT, TimeControl, BOTTOMLEFT, 0, 0)
		DealControl:SetFont('/esoui/common/fonts/univers67.otf|18|soft-shadow-thin')
	end
	local DealValue, Discount, Profit, EntryCount, usingFallback= CheckDeal(result.itemLink, result.purchasePrice, result.stackCount, result.usingFallback)
	if not DealValue then return end
	if DealValue > -1 then
		if Settings.GuildStoreInfoToShow == "Profit" then
			DealControl:SetText(RoundAndFormat(Profit) .. " " .. CoinIcon)
		elseif Settings.GuildStoreInfoToShow == "Discount" then
			DealControl:SetText(Discount .. '%')
		else
			DealControl:SetHidden(true)
			return
		end
		if Settings.HighlightRiskyDeals and EntryCount < Settings.RiskyDealsListingsCount then --unsure
			DealControl:SetColor(1, 0.62, 0.62, 1)
		elseif Settings.HighlightRiskyDeals and usingFallback then --unsure
			DealControl:SetColor(1, 0.62, 0.62, 1)
		elseif DealValue == 0 then --overpriced
			DealControl:SetColor(1, 0, 0, 1)
		else
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, DealValue)
			DealControl:SetColor(r, g, b, 1)
		end
		DealControl:SetHidden(false)
	else
		DealControl:SetHidden(true)
	end
end  

local function InitializeGuildStoreHook(eventCode, responseType, result)
	if responseType == TRADING_HOUSE_RESULT_SEARCH_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS and not GuildStoreHook1 then
		if TRADING_HOUSE.searchResultsList then
			GuildStoreHook1 = true
			if GuildStoreHook2 then
				EVENT_MANAGER:UnregisterForEvent(Addon.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
			end
			local DataType = TRADING_HOUSE.searchResultsList.dataTypes[1]
			SecurePostHook(DataType, 'setupCallback', ShowTTCDeal)
		end
	elseif responseType == TRADING_HOUSE_RESULT_LISTINGS_PENDING and not GuildStoreHook2 then
		if TRADING_HOUSE.postedItemsList then
			GuildStoreHook2 = true
			if GuildStoreHook1 then
				EVENT_MANAGER:UnregisterForEvent(Addon.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
			end
			local DataType2 = TRADING_HOUSE.postedItemsList.dataTypes[2]
			SecurePostHook(DataType2, 'setupCallback', ShowTTCDeal)
		end
	end
end

local function InitializeDealFilter()
    local FilterBase = AwesomeGuildStore.class.FilterBase
    local ValueRangeFilterBase = AwesomeGuildStore.class.ValueRangeFilterBase
    local FILTER_ID = AwesomeGuildStore:GetFilterIds()
    local DealFilter = ValueRangeFilterBase:Subclass()
    function DealFilter:New(...) return ValueRangeFilterBase.New(self, ...) end

    function DealFilter:Initialize()
		ValueRangeFilterBase.Initialize(self, FILTER_ID.SHOW_TTC_PRICE_DEAL_FILTER or 837, FilterBase.GROUP_SERVER, {
			label = "Deal Filter", min = 1, max = 6,
			steps = {{id = 1, label = "Overpriced"}, {id = 2, label = "OK"}, {id = 3, label = "Good"}, {id = 4, label = "Great"}, {id = 5, label = "Amazing"}, {id = 6, label = "Excellent"}}
		})
		
		function DealFilter:CanFilter(subcategory) return true end
		local dealById = {}
        for i = 1, #self.config.steps do
            local step = self.config.steps[i]
			local color = i == 1 and ZO_ColorDef:New(1, 0, 0) or GetItemQualityColor(step.id - 1)
			step.color = color
			step.colorizedLabel = color:Colorize(step.label)
            dealById[step.id] = step
        end
        self.dealById = dealById
    end

    function DealFilter:FilterLocalResult(result)
        local dealValue, _, _, _ = CheckDeal(result.itemLink, result.purchasePrice, result.stackCount)
        return not ((dealValue or -5) + 1 < self.localMin or (dealValue or 5) + 1 > self.localMax)
    end

    function DealFilter:GetTooltipText(min, max)
        if (min ~= self.config.min or max ~= self.config.max) then
            local out = {}
            for id = min, max do
                local step = self.dealById[id]
                out[#out + 1] = step.colorizedLabel
            end
            return table.concat(out, ", ")
        end
        return ""
    end

	AwesomeGuildStore:RegisterFilter(DealFilter:New())
	AwesomeGuildStore:RegisterFilterFragment(AwesomeGuildStore.class.QualityFilterFragment:New(FILTER_ID.SHOW_TTC_PRICE_DEAL_FILTER or 837)) --placeholder
end

local function InitializeProfitFilter()
    local FilterBase = AwesomeGuildStore.class.FilterBase
    local ValueRangeFilterBase = AwesomeGuildStore.class.ValueRangeFilterBase
    local FILTER_ID = AwesomeGuildStore:GetFilterIds()
    local ProfitFilter = ValueRangeFilterBase:Subclass()
	local minProfit = tonumber(Settings.ProfitFilterSliderMin)
    function ProfitFilter:New(...) return ValueRangeFilterBase.New(self, ...) end
	
    function ProfitFilter:Initialize()
        ValueRangeFilterBase.Initialize(self, FILTER_ID.SHOW_TTC_PRICE_PROFIT_FILTER or 838, FilterBase.GROUP_SERVER, {
            label = "Profit Filter", currency = CURT_MONEY, min = minProfit, max = 100000000, precision = 0,
			steps = minProfit == 0 and {0, 250, 500, 750, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 25000, 50000, 75000, 100000, 1000000, 100000000} or {-1000000, -100000, -75000, -50000, -25000, -10000, -9000, -8000, -7000, -6000, -5000, -4000, -3000, -2000, -1000, -750, -500, -250, 0, 250, 500, 750, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 25000, 50000, 75000, 100000, 1000000, 100000000}
        })
        function ProfitFilter:CanFilter(subcategory) return true end
    end

    function ProfitFilter:FilterLocalResult(result)
        local _, _, profit, _ = CheckDeal(result.itemLink, result.purchasePrice, result.stackCount)
        if not profit or profit < self.localMin or profit > self.localMax then return false end
        return true
    end

	AwesomeGuildStore:RegisterFilter(ProfitFilter:New())
	AwesomeGuildStore:RegisterFilterFragment(AwesomeGuildStore.class.PriceRangeFilterFragment:New(FILTER_ID.SHOW_TTC_PRICE_PROFIT_FILTER or 838)) --placeholder
end

local function InitializeAwesomeGuildStoreIntegration()
	if Settings.EnableDealFilter then InitializeDealFilter() end
	if Settings.EnableProfitFilter then InitializeProfitFilter() end
end

local function InitializeToggleButton()
	local inventories = {ZO_PlayerInventory, ZO_CraftBag, ZO_PlayerBank, ZO_HouseBank, ZO_GuildBank, ZO_SmithingTopLevelDeconstructionPanelInventory, ZO_SmithingTopLevelRefinementPanelInventory, ZO_SmithingTopLevelImprovementPanelInventory, ZO_EnchantingTopLevelInventory}
	local enabled = Settings.Enabled
	for i = 1, #inventories do
		local button = WINDOW_MANAGER:CreateControlFromVirtual("ShowTTCPrice_TogglePriceButton_" .. tostring(i), inventories[i], "ZO_DefaultButton")
		button:SetWidth(80, 28)
		if enabled then button:SetText("TTC " .. CoinIcon) else button:SetText("ESO " .. CoinIcon) end
		button:ClearAnchors()
		button:SetAnchor(BOTTOMLEFT, inventories[i], TOPLEFT,-24,0)
		button:SetClickSound("Click")
		button:SetHandler("OnClicked", function() ShowTTCPrice_TogglePrices() end)
		button:SetState(BSTATE_NORMAL)
		button:SetDrawTier(2)
		table.insert(TogglePriceButtons, button)
	end
end

local function Initialize()
	if Settings.EnableToggleButton then InitializeToggleButton() end --optional toggle
	--inventories
	for _, i in pairs(PLAYER_INVENTORY.inventories) do
		local ListView = i.listView
		if ListView and ListView.dataTypes and ListView.dataTypes[1] and ListView:GetName() ~= "ZO_PlayerInventoryQuest" then --ignore quest tab
			local DataType = ListView.dataTypes[1]
			SecurePostHook(DataType, 'setupCallback', function(control, slot)
				if SCENE_MANAGER:GetCurrentScene() ~= STABLES_SCENE then  --ignore stables scene
					ShowTTCPrice(control, slot)
				end
			end)
		end
	end
	--deconstruction (assistant)
	SecurePostHook(ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack.dataTypes[1], "setupCallback", function(control, slot)
		ShowTTCPrice(control, slot)
	end)
	--deconstruction (crafting stations)
	SecurePostHook(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1], "setupCallback", function(control, slot)
        ShowTTCPrice(control, slot)
	end)
	--refinement (crafting stations)
	SecurePostHook(ZO_SmithingTopLevelRefinementPanelInventoryBackpack.dataTypes[1], "setupCallback", function(control, slot)
        ShowTTCPrice(control, slot)
	end)
	--improvement (crafting stations)
	SecurePostHook(ZO_SmithingTopLevelImprovementPanelInventoryBackpack.dataTypes[1], "setupCallback", function(control, slot)
        ShowTTCPrice(control, slot)
	end)
	--enchanting (crafting stations)
	SecurePostHook(ZO_EnchantingTopLevelInventoryBackpack.dataTypes[1], "setupCallback", function(control, slot)
        ShowTTCPrice(control, slot)
	end)
end

local function OnAddOnLoaded(event, addonName)
	if addonName ~= Addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(Addon.name, EVENT_ADD_ON_LOADED)
	Addon.SavedVariables = ZO_SavedVars:NewAccountWide("ShowTTCPriceVars", Addon.SV_version, GetWorldName(), SV_default)
	ZO_CreateStringId("SI_BINDING_NAME_ShowTTCPrice_PriceToggleKeybind", "Toggle TTC Price")
	SetupSettings()
	Initialize()
	if Settings.EnableInGuildStore then --guild store
		EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, InitializeGuildStoreHook)
		if Settings.EnableAwesomeGuildStoreIntegration and AwesomeGuildStore then --AwesomeGuildStore
			AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.AFTER_FILTER_SETUP, InitializeAwesomeGuildStoreIntegration)
		end
	end
end

EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
