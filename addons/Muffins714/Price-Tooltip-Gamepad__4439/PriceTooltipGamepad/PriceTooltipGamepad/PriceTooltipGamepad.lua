--[[
	Addon: PriceTooltip
	Author: Mladen90 (@Mladen90 EU), Infixo (CoAuthor), Muffins714 (Gamepad)
	Created by Mladen90 (@Mladen90 EU)
]] --


PriceTooltip = {}
local PTTG = PriceTooltip
PriceTTG_MENU = {}
PriceTTG_IsLoaded = false
local PriceTTG_ATT_Sales = nil
local PriceTTG_LastDivider = nil
local PriceTTG_UESP_Sales_Exists = false

-- Gold icon
local goldIcon = ZO_Currency_GetPlatformFormattedGoldIcon()

-- HELPERS & MATH (Kept original logic)
PriceTTG_Is_MM_Ready = function()
	return MasterMerchant and MasterMerchant.isInitialized and LibGuildStore and LibGuildStore.guildStoreReady
end

PriceTTG_ValidPrice = function(price) return (price or 0) > 0 end

PriceTTG_Round = function(num, numDecimalPlaces)
	if not num then return num end
	local decimalPlaces = numDecimalPlaces or 0
	if PTTG.SavedVariables.RoundPrice then decimalPlaces = 0 end
	local mult = 10 ^ decimalPlaces
	return math.floor(num * mult + 0.5) / mult
end

PriceTTG_NumberFormat = function(amount)
	local formatted = amount
	local separator = PTTG.SavedVariables.Separator
	if separator == Price_TTGS_EMPTY then return formatted end
	if separator == Price_TTGS_SPACE then separator = " " end
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1" .. separator .. "%2")
		if (k == 0) then break end
	end
	return formatted
end

-- PRICE CALCULATION (Kept original logic)
PriceTTG_GetPrices = function(itemLink)
	local prices =
	{
		vendorPrice = nil,
		profitPrice = nil,

		-- TTC
		originalTTCPrice = nil,
		originalTTCPriceIsAvg = false,
		scaledTTCPrice = nil,
		infoTTC1 = nil,
		infoTTC2 = nil,
		infoTTC3 = nil,

		-- MM
		originalMMPrice = nil,
		scaledMMPrice = nil,
		infoMM = nil,

		-- ATT
		originalATTPrice = nil,
		scaledATTPrice = nil,
		infoATT = nil,

		-- UESP
		originalUESPPrice = nil,
		scaledUESPPrice = nil,

		originalAveragePrice = nil,
		scaledAveragePrice = nil,
		bestPrice = nil,
		bestPriceText = nil,

		isBound = false
	}

	if not itemLink then return nil end
	prices.isBound = IsItemLinkBound(itemLink)

	local icon, meetsUsageRequirement
	icon, prices.vendorPrice, meetsUsageRequirement = GetItemLinkInfo(itemLink)
	if not PriceTTG_ValidPrice(prices.vendorPrice) then prices.vendorPrice = 0 end

	if PTTG.SavedVariables.UseProfitPrice then
		prices.profitPrice = prices.vendorPrice * (1 + PTTG.SavedVariables.ScaleProfitPrice / 100)
		if not PriceTTG_ValidPrice(prices.profitPrice) then prices.profitPrice = 1 end
	end

	-- TTC
	if PTTG.SavedVariables.UseTTCPrice then
		if TamrielTradeCentrePrice then
			local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
			if priceInfo then
				prices.originalTTCPrice = priceInfo.SuggestedPrice

				if priceInfo.SuggestedPrice then
					prices.infoTTC1 = string.format("TTC " .. GetString(TTC_PRICE_SUGGESTEDXTOY),
						TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice, 0),
						TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice * 1.25, 0))
				end

				prices.infoTTC2 = string.format(GetString(TTC_PRICE_AGGREGATEPRICESXYZ),
					TamrielTradeCentre:FormatNumber(priceInfo.Avg), TamrielTradeCentre:FormatNumber(priceInfo.Min),
					TamrielTradeCentre:FormatNumber(priceInfo.Max));

				if (PTTG.SavedVariables.IncludeAvgTTCPrice and not PriceTTG_ValidPrice(prices.originalTTCPrice)) then
					prices.originalTTCPrice = priceInfo.Avg
					prices.originalTTCPriceIsAvg = true
				end

				if (PTTG.SavedVariables.DisplayTTCPriceInfo) then
					if priceInfo.EntryCount ~= priceInfo.AmountCount then
						prices.infoTTC3 = string.format(GetString(TTC_PRICE_XLISTINGSYITEMS),
							TamrielTradeCentre:FormatNumber(priceInfo.EntryCount),
							TamrielTradeCentre:FormatNumber(priceInfo.AmountCount))
					else
						prices.infoTTC3 = string.format(GetString(TTC_PRICE_XLISTINGS),
							TamrielTradeCentre:FormatNumber(priceInfo.EntryCount))
					end
				end
			end

			if PriceTTG_ValidPrice(prices.originalTTCPrice) then
				if (prices.originalTTCPriceIsAvg) then
					prices.scaledTTCPrice = prices.originalTTCPrice *
						(1 + PTTG.SavedVariables.ScaleAvgTTCPrice / 100)
				else
					prices.scaledTTCPrice = prices.originalTTCPrice *
						(1 + PTTG.SavedVariables.ScaleTTCPrice / 100)
				end
			end
		end
	end

	-- MM
	if PTTG.SavedVariables.UseMMPrice then
		if MasterMerchant then
			local itemInfo = MasterMerchant:itemStats(itemLink, false)
			prices.originalMMPrice = itemInfo.avgPrice

			if (PTTG.SavedVariables.DisplayMMPriceInfo) then
				local tipLine, avgPrice, graphInfo = MasterMerchant:itemPriceTip(itemLink, false, clickable)
				if tipLine then prices.infoMM = zo_strformat("<<1>> ", tipLine) end
			end

			if PriceTTG_ValidPrice(prices.originalMMPrice) then
				prices.scaledMMPrice = prices.originalMMPrice * (1 + PTTG.SavedVariables.ScaleMMPrice / 100)
			end
		end
	end

	-- ATT
	if PTTG.SavedVariables.UseATTPrice then
		if PriceTTG_ATT_Sales then
			local fromTimeStamp = GetTimeStamp() - PTTG.SavedVariables.ATTDays * 60 * 60 * 24
			prices.originalATTPrice = PriceTTG_ATT_Sales:GetAveragePricePerItem(itemLink, fromTimeStamp)
			if PriceTTG_ValidPrice(prices.originalATTPrice) then
				prices.scaledATTPrice = prices.originalATTPrice * (1 + PTTG.SavedVariables.ScaleATTPrice / 100)
			end
			if (PTTG.SavedVariables.DisplayATTPriceInfo) then
				prices.infoATT = PriceTTG_GetAttInfo(itemLink, fromTimeStamp)
			end
		end
	end

	-- UESP
	if PTTG.SavedVariables.UseUESPPrice then
		-- Re-verify global existence in case it was slow to load
		if not PriceTTG_UESP_Sales_Exists and uespLog and uespLog.SalesPrices then
			PriceTTG_UESP_Sales_Exists = true
		end

		if PriceTTG_UESP_Sales_Exists then
			local data = PriceTTG_uespLog_FindSalesPrice(itemLink)
			if data and data.priceSold then
				prices.originalUESPPrice = data.priceSold
				if PriceTTG_ValidPrice(prices.originalUESPPrice) then
					prices.scaledUESPPrice = prices.originalUESPPrice *
						(1 + PTTG.SavedVariables.ScaleUESPPrice / 100)
				end
			end
		end
	end

	-- Average & Best Price Logic
	if PTTG.SavedVariables.UseAveragePrice then
		prices.scaledAveragePrice = 0
		prices.originalAveragePrice = 0
		local count = 0
		if PTTG.SavedVariables.IncludeTTCInAP and PriceTTG_ValidPrice(prices.scaledTTCPrice) then
			if (prices.originalTTCPriceIsAvg) then
				if (PTTG.SavedVariables.IncludeTTCAvgInAP) then
					prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledTTCPrice
					prices.originalAveragePrice = prices.originalAveragePrice + prices.originalTTCPrice
					count = count + 1
				end
			else
				prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledTTCPrice
				prices.originalAveragePrice = prices.originalAveragePrice + prices.originalTTCPrice
				count = count + 1
			end
		end

		if PTTG.SavedVariables.IncludeMMInAP and PriceTTG_ValidPrice(prices.scaledMMPrice) then
			prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledMMPrice
			prices.originalAveragePrice = prices.originalAveragePrice + prices.originalMMPrice
			count = count + 1
		end

		if PTTG.SavedVariables.IncludeATTInAP and PriceTTG_ValidPrice(prices.scaledATTPrice) then
			prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledATTPrice
			prices.originalAveragePrice = prices.originalAveragePrice + prices.originalATTPrice
			count = count + 1
		end

		if PTTG.SavedVariables.IncludeUESPInAP and PriceTTG_ValidPrice(prices.scaledUESPPrice) then
			prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledUESPPrice
			prices.originalAveragePrice = prices.originalAveragePrice + prices.originalUESPPrice
			count = count + 1
		end

		if count > 0 then
			prices.originalAveragePrice = prices.originalAveragePrice / count
			prices.scaledAveragePrice = prices.scaledAveragePrice / count
		end
	end

	if PTTG.SavedVariables.UseBestPrice then
		prices.bestPrice = 0

		if PTTG.SavedVariables.UseTTCPrice and PriceTTG_ValidPrice(prices.scaledTTCPrice) and prices.scaledTTCPrice > prices.bestPrice then
			if (PTTG.SavedVariables.IncludeTTCAvgInBP or (not prices.originalTTCPriceIsAvg)) then
				prices.bestPrice = prices.scaledTTCPrice
				prices.bestPriceText = Price_TTGS_TTC_PRICE
			end
		end

		if PTTG.SavedVariables.UseMMPrice and PriceTTG_ValidPrice(prices.scaledMMPrice) and prices.scaledMMPrice > prices.bestPrice then
			prices.bestPrice = prices.scaledMMPrice
			prices.bestPriceText = Price_TTGS_MM_PRICE
		end

		if PTTG.SavedVariables.UseATTPrice and PriceTTG_ValidPrice(prices.scaledATTPrice) and prices.scaledATTPrice > prices.bestPrice then
			prices.bestPrice = prices.scaledATTPrice
			prices.bestPriceText = Price_TTGS_ATT_PRICE
		end

		if PTTG.SavedVariables.UseUESPPrice and PriceTTG_ValidPrice(prices.scaledUESPPrice) and prices.scaledUESPPrice > prices.bestPrice then
			prices.bestPrice = prices.scaledUESPPrice
			prices.bestPriceText = Price_TTGS_UESP_PRICE
		end

		if PTTG.SavedVariables.IncludePPInBP and PTTG.SavedVariables.UseProfitPrice and PriceTTG_ValidPrice(prices.profitPrice) and prices.profitPrice > prices.bestPrice then
			prices.bestPrice = prices.profitPrice
			prices.bestPriceText = Price_TTGS_PROFIT_PRICE
		end

		if not PriceTTG_ValidPrice(prices.bestPrice) then
			prices.bestPrice = nil
			prices.bestPriceText = nil
		end

		if not PTTG.SavedVariables.DisplaySourceInBP then
			prices.bestPriceText = nil
		end
	end

	prices.profitPrice = PriceTTG_Round(prices.profitPrice, 2)
	prices.originalTTCPrice = PriceTTG_Round(prices.originalTTCPrice, 2)
	prices.scaledTTCPrice = PriceTTG_Round(prices.scaledTTCPrice, 2)
	prices.originalMMPrice = PriceTTG_Round(prices.originalMMPrice, 2)
	prices.scaledMMPrice = PriceTTG_Round(prices.scaledMMPrice, 2)
	prices.originalATTPrice = PriceTTG_Round(prices.originalATTPrice, 2)
	prices.scaledATTPrice = PriceTTG_Round(prices.scaledATTPrice, 2)
	prices.originalUESPPrice = PriceTTG_Round(prices.originalUESPPrice, 2)
	prices.scaledUESPPrice = PriceTTG_Round(prices.scaledUESPPrice, 2)
	prices.originalAveragePrice = PriceTTG_Round(prices.originalAveragePrice, 2)
	prices.scaledAveragePrice = PriceTTG_Round(prices.scaledAveragePrice, 2)
	prices.bestPrice = PriceTTG_Round(prices.bestPrice, 2)
	return prices
end

PriceTTG_GetAttInfo = function(itemLink, fromTimeStamp)
	if not ArkadiusTradeTools or not PriceTTG_ATT_Sales then
		return nil
	end
	itemLink = PriceTTG_ATT_Sales:NormalizeItemLink(itemLink)
	if itemLink == nil then return nil end
	local itemSales = PriceTTG_ATT_Sales:GetItemSalesInformation(itemLink, fromTimeStamp, true)
	local itemType = GetItemLinkItemType(itemLink)
	local statsString = nil
	for link, sales in pairs(itemSales) do
		-- Only process data for the specific link we requested
		if (link == itemLink) then
			local quantity = 0
			for _, sale in pairs(sales) do
				quantity = quantity + sale.quantity
			end
			if (quantity > 0) then
				local formattedSales = ArkadiusTradeTools:LocalizeDezimalNumber(#sales)
				local formattedQty = ArkadiusTradeTools:LocalizeDezimalNumber(quantity)

				if (itemType == ITEMTYPE_MASTER_WRIT) then
					statsString = string.format("%s sales, %s writ vouchers", formattedSales, formattedQty)
				else
					statsString = string.format("%s sales, %s items", formattedSales, formattedQty)
				end
			end
		end
	end
	return statsString
end

--NOTE If original price is valid, scaled price is also valid.
--NOTE ProfitPrice is scaled price of VendorPrice
PriceTTG_NoDisplayPrices = function(prices)
	return prices == nil or
		(not (PriceTTG_ValidPrice(prices.vendorPrice) and PTTG.SavedVariables.DisplayVendorPrice) and
			not (PriceTTG_ValidPrice(prices.profitPrice) and PTTG.SavedVariables.DisplayProfitPrice) and
			not (PriceTTG_ValidPrice(prices.originalTTCPrice) and PTTG.SavedVariables.DisplayTTCPrice) and
			not ((prices.infoTTC1 or prices.infoTTC2 or prices.infoTTC3) and PTTG.SavedVariables.DisplayTTCPriceInfo) and
			not (PriceTTG_ValidPrice(prices.originalMMPrice) and PTTG.SavedVariables.DisplayMMPrice) and
			not (prices.infoMM and PTTG.SavedVariables.DisplayMMPriceInfo) and
			not (PriceTTG_ValidPrice(prices.originalATTPrice) and PTTG.SavedVariables.DisplayATTPrice) and
			not (prices.infoATT and PTTG.SavedVariables.DisplayATTPriceInfo) and
			not (PriceTTG_ValidPrice(prices.originalUESPPrice) and PTTG.SavedVariables.DisplayUESPPrice) and
			not (PriceTTG_ValidPrice(prices.originalAveragePrice) and PTTG.SavedVariables.DisplayAveragePrice) and
			not (PriceTTG_ValidPrice(prices.bestPrice) and PTTG.SavedVariables.DisplayBestPrice))
end

-- TOOLTIP DISPLAY LOGIC
PriceTTG_AddTooltip = function(control, itemLink)
	if (not control) then return end

	local gamepad = true
	local addedLine = 0
	local prices = PriceTTG_GetPrices(itemLink)

	if not PriceTTG_NoDisplayPrices(prices) then
		if PTTG.SavedVariables.DisplayVendorPrice and PriceTTG_ValidPrice(prices.vendorPrice) then
			control:AddLine(
				PriceTTG_GetStringColorFromColor(PTTG.SavedVariables.TooltipColor) ..
				--	"Vendor price " .. PriceTTG_NumberFormat(prices.vendorPrice) .. " " .. goldIcon,
				Price_TTGS_VENDOR_PRICE .. " " .. PriceTTG_NumberFormat(prices.vendorPrice) .. " " .. goldIcon,
				ZO_TOOLTIP_STYLES[PTTG.SavedVariables.GamepadFont])
		end
	end

	if not PriceTTG_NoDisplayPrices(prices) then
		local stringPTIColor = PriceTTG_GetStringColorFromColor(PTTG.SavedVariables.TooltipPriceInfoColor)

		if PTTG.SavedVariables.DisplayProfitPrice then
			addedLine = addedLine +
				PriceTTG_AddPTLine(control, Price_TTGS_PROFIT_PRICE, prices.profitPrice, prices.vendorPrice,
					prices.profitPrice, nil, gamepad, nil, prices.isBound)
		end

		-- TTC
		if PTTG.SavedVariables.DisplayTTCPrice then
			if (prices.originalTTCPriceIsAvg) then
				addedLine = addedLine +
					PriceTTG_AddPTLine(control, Price_TTGS_TTC_PRICE, prices.scaledTTCPrice, prices.vendorPrice,
						prices.profitPrice, nil, gamepad,
						PTTG.SavedVariables.AvgTTCPriceColor, prices.isBound)
			else
				addedLine = addedLine +
					PriceTTG_AddPTLine(control, Price_TTGS_TTC_PRICE, prices.scaledTTCPrice, prices.vendorPrice,
						prices.profitPrice, nil, gamepad, nil, prices.isBound)
			end
		end

		if PTTG.SavedVariables.DisplayTTCPriceInfo then
			if prices.infoTTC1 then
				addedLine = addedLine +
					PriceTTG_AddTooltipLine(control, stringPTIColor .. prices.infoTTC1, gamepad, true)
			end
			if prices.infoTTC2 then
				addedLine = addedLine +
					PriceTTG_AddTooltipLine(control, stringPTIColor .. prices.infoTTC2, gamepad, true)
			end
			if (prices.infoTTC2 and prices.infoTTC3 ~= prices.infoTTC2) or prices.infoTTC3 then
				addedLine = addedLine +
					PriceTTG_AddTooltipLine(control, stringPTIColor .. prices.infoTTC3, gamepad, true)
			end
		end

		-- MM
		if PTTG.SavedVariables.DisplayMMPrice then
			addedLine = addedLine +
				PriceTTG_AddPTLine(control, Price_TTGS_MM_PRICE, prices.scaledMMPrice, prices.vendorPrice,
					prices.profitPrice, nil, gamepad, nil, prices.isBound)
		end

		if PTTG.SavedVariables.DisplayMMPriceInfo and prices.infoMM then
			addedLine = addedLine + PriceTTG_AddTooltipLine(control, stringPTIColor .. prices.infoMM, gamepad, true)
		end

		-- ATT
		if PTTG.SavedVariables.DisplayATTPrice then
			addedLine = addedLine +
				PriceTTG_AddPTLine(control, Price_TTGS_ATT_PRICE, prices.scaledATTPrice, prices.vendorPrice,
					prices.profitPrice, nil, gamepad, nil, prices.isBound)
		end

		if PTTG.SavedVariables.DisplayATTPriceInfo and prices.infoATT then
			addedLine = addedLine + PriceTTG_AddTooltipLine(control, stringPTIColor .. prices.infoATT, gamepad, true)
		end

		-- UESP
		if PTTG.SavedVariables.DisplayUESPPrice then
			addedLine = addedLine +
				PriceTTG_AddPTLine(control, Price_TTGS_UESP_PRICE, prices.scaledUESPPrice, prices.vendorPrice,
					prices.profitPrice, nil, gamepad, nil, prices.isBound)
		end

		if PTTG.SavedVariables.DisplayAveragePrice then
			if (prices.originalTTCPriceIsAvg) then
				addedLine = addedLine +
					PriceTTG_AddPTLine(control, Price_TTGS_TRADE_PRICE, prices.scaledAveragePrice, prices.vendorPrice,
						prices.profitPrice, nil, gamepad, PTTG.SavedVariables.AvgTTCPriceColor, prices.isBound)
			else
				addedLine = addedLine +
					PriceTTG_AddPTLine(control, Price_TTGS_TRADE_PRICE, prices.scaledAveragePrice, prices.vendorPrice,
						prices.profitPrice, nil, gamepad, nil, prices.isBound)
			end
		end

		if PTTG.SavedVariables.DisplayBestPrice then
			if (prices.originalTTCPriceIsAvg) then
				addedLine = addedLine +
					PriceTTG_AddPTLine(control, Price_TTGS_BEST_PRICE, prices.bestPrice, prices.vendorPrice,
						prices.profitPrice, prices.bestPriceText, gamepad, PTTG.SavedVariables.AvgTTCPriceColor,
						prices.isBound)
			else
				addedLine = addedLine +
					PriceTTG_AddPTLine(control, Price_TTGS_BEST_PRICE, prices.bestPrice, prices.vendorPrice,
						prices.profitPrice, prices.bestPriceText, gamepad, nil, prices.isBound)
			end
		end
	end

	-- PTTG Note Display
	if PTTGNote then
		local note = PTTGNote_GetData(itemLink)
		if note then
			local noteColorText = PTTGNote_GetStringColorFromColor(PTTGNote.SavedVariables.TooltipColor)
			addedLine = addedLine + PriceTTG_AddTooltipLine(control, noteColorText .. "NOTE: " .. note, true)
		end
	end
	if not PriceTTG_NoDisplayPrices(prices) then
		local stringErrorColor = PriceTTG_GetStringColor(1, 0, 0)
		if PTTG.SavedVariables.UseTTCPrice and not TamrielTradeCentrePrice then
			addedLine = addedLine +
				PriceTTG_AddTooltipLine(control, stringErrorColor .. "TTC not available!", gamepad)
		end
		if PTTG.SavedVariables.UseMMPrice and not MasterMerchant then
			addedLine = addedLine +
				PriceTTG_AddTooltipLine(control, stringErrorColor .. "MM not available!", gamepad)
		end
		if PTTG.SavedVariables.UseATTPrice and not PriceTTG_ATT_Sales then
			addedLine = addedLine +
				PriceTTG_AddTooltipLine(control, stringErrorColor .. "ATT not available!", gamepad)
		end
		if PTTG.SavedVariables.UseUESPPrice and not PriceTTG_UESP_Sales_Exists then
			addedLine = addedLine +
				PriceTTG_AddTooltipLine(control, stringErrorColor .. "UESP not available!", gamepad)
		end
	end
	--Empty line instead of divider
	if addedLine > 0 then control:AddLine(" ") end
end

PriceTTG_GetBoundPriceIndicator = function(is_bound)
	if is_bound and PTTG.SavedVariables.MarkBoundItems then
		return PriceTTG_GetStringColorFromColor(PTTG.SavedVariables.BoundItemMarkColor) .. "*"
	else
		return ""
	end
end

PriceTTG_GetLowPriceIndicator = function(price, vendorPrice, profitPrice)
	local lowPriceIndikator = ""
	if PriceTTG_ValidPrice(price) then
		if price <= vendorPrice then
			lowPriceIndikator = PriceTTG_GetStringColorFromColor(PTTG.SavedVariables
				.VendorPriceLowPriceIndicatorColor) .. "*"
		elseif PTTG.SavedVariables.UseProfitPrice and price < profitPrice then
			lowPriceIndikator = PriceTTG_GetStringColorFromColor(PTTG.SavedVariables
				.ProfitPriceLowPriceIndicatorColor) .. "*"
		end
	end
	return lowPriceIndikator
end

PriceTTG_AddPTLine = function(control, text, price, vendorPrice, profitPrice, info, gamepad, priceColor, isBound)
	if PriceTTG_ValidPrice(price) then
		text = text or "Unknown Source"

		if info then info = " (" .. info .. ")" end
		local indicator = ""
		if PTTG.SavedVariables.LowPriceIndicatorTooltip then
			indicator = PriceTTG_GetLowPriceIndicator(price, vendorPrice, profitPrice)
		end
		indicator = indicator .. PriceTTG_GetBoundPriceIndicator(isBound)

		local stringColorText = PriceTTG_GetStringColorFromColor(PTTG.SavedVariables.TooltipColor)
		local stringColorPrice = stringColorText

		if priceColor then stringColorPrice = PriceTTG_GetStringColorFromColor(priceColor) end
		local finalGoldIcon = " " .. goldIcon
		local formattedPrice = PriceTTG_NumberFormat(price) or "0"

		local finalLine = stringColorText ..
			text ..
			" " .. indicator .. stringColorPrice .. formattedPrice .. finalGoldIcon .. stringColorText .. (info or "")

		PriceTTG_AddTooltipLine(control, finalLine, gamepad)
		return 1
	end
	return 0
end


PriceTTG_AddTooltipLine = function(control, text, gamepad, isPTI)
	if isPTI then
		control:AddLine(text, ZO_TOOLTIP_STYLES[PTTG.SavedVariables.GamepadPriceInfoFont])
	else
		control:AddLine(text, ZO_TOOLTIP_STYLES[PTTG.SavedVariables.GamepadFont])
	end
	return 1
end

-- HOOKS
PriceTTG_GamePadToolTipExtension = function(toolTipControl, functionName)
	local base = toolTipControl[functionName]
	toolTipControl[functionName] = function(control, bagId, slotIndex, ...)
		if type(bagId) == "number" then
			local itemLink = GetItemLink(bagId, slotIndex)
			if itemLink and control then
				PriceTTG_AddTooltip(control, itemLink)
			end
		end
		base(control, bagId, slotIndex, ...)
	end
end

PriceTTG_GamePadToolTipExtension2 = function(toolTipControl, functionName)
	local base = toolTipControl[functionName]
	if not base then return end

	toolTipControl[functionName] = function(self, ...)
		base(self, ...)
		if self.selectedEquipSlot and GAMEPAD_TOOLTIPS then
			GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, BAG_WORN, self.selectedEquipSlot)
		end
	end
end

-- Dedicated line hook corrected for gamepad guild store and vender/store items
PriceTTG_GamePadToolTipExtension3 = function(toolTipControl, functionName)
	ZO_PreHook(toolTipControl, functionName, function(control, data, ...)
		local itemLink = nil
		if type(data) == "table" then
			itemLink = data.itemLink
		elseif type(data) == "string" then
			itemLink = data
		end

		if itemLink and string.find(itemLink, ":item:") then
			PriceTTG_AddTooltip(control, itemLink)
		end

		return false
	end)
end

-- Handles links clicked in chat or other static UI elements.
PriceTTG_GamePadToolTipExtension4 = function(toolTipControl, functionName)
	ZO_PreHook(toolTipControl, functionName, function(control, arg1, arg2, arg3, ...)
		local itemLink = nil
		if type(arg1) == "string" and string.find(arg1, "|H.-:item:") then
			itemLink = arg1
		elseif type(arg2) == "string" and string.find(arg2, "|H.-:item:") then
			itemLink = arg2
		elseif type(arg3) == "string" and string.find(arg3, "|H.-:item:") then
			itemLink = arg3
		end

		-- If we found a valid item, we run our tooltip logic.
		if itemLink then
			PriceTTG_AddTooltip(control, itemLink)
		end

		return false
	end)
end

--TODO Add craft cost to items already made like food ect.
-- MATH HELPER USING TTC PRICES (All Stations)
local function GetTTCPrice(link)
	if not link or link == "" or not TamrielTradeCentrePrice then return 0 end
	local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(link)
	if priceInfo then
		return priceInfo.SuggestedPrice or priceInfo.Avg or 0
	end
	return 0
end

local function GetBagSlotCost(...)
	local cost = 0
	local args = { ... }
	for i = 1, #args, 2 do
		local bagId = args[i]
		local slotIndex = args[i + 1]
		if bagId and slotIndex then
			cost = cost + GetTTCPrice(GetItemLink(bagId, slotIndex))
		end
	end
	return cost
end


-- function for crafting costs
local function CraftPriceInfo(tooltip, matCost, itemLink)
	local marketValue = GetTTCPrice(itemLink)
	local marketValueText = marketValue > 0 and ZO_CommaDelimitNumber(math.floor(marketValue + 0.5)) or "No TTC Data"

	-- Check displaycraftcost toggle
	if PTTG.SavedVariables.DisplayCraftCost then
		local matCostText = ZO_CommaDelimitNumber(math.floor(matCost + 0.5))

		-- Total Mat Cost Per Item
		tooltip.tip:AddLine(Price_TTGS_CRAFT_TOTAL, ZO_TOOLTIP_STYLES.PTTGText)
		tooltip.tip:AddLine(matCostText .. " " .. goldIcon, ZO_TOOLTIP_STYLES.PTTGGoldCost)

		-- Market Value Per Item
		tooltip.tip:AddLine(Price_TTGS_MARKET_COST, ZO_TOOLTIP_STYLES.PTTGText)
		tooltip.tip:AddLine(marketValueText .. " " .. goldIcon, ZO_TOOLTIP_STYLES.PTTGGoldCost)
	end
end

-- CRAFTING HOOKS
local function PriceTTG_CraftingHooks()
	-- ALCHEMY
	if GAMEPAD_ALCHEMY then
		--ZO_PostHook
		SecurePostHook(GAMEPAD_ALCHEMY, "UpdateTooltip", function(self)
			if not self or not self.IsCraftable or not self:IsCraftable() then return end
			if not self.tooltip or not self.tooltip.tip then return end

			local itemLink = GetAlchemyResultingItemLink(self:GetAllCraftingBagAndSlots())
			if itemLink and itemLink ~= "" then
				local matCost = GetBagSlotCost(self:GetAllCraftingBagAndSlots())
				CraftPriceInfo(self.tooltip, matCost, itemLink)
			end
		end)
	end

	-- ENCHANTING
	if GAMEPAD_ENCHANTING then
		ZO_PostHook(GAMEPAD_ENCHANTING, "UpdateTooltip", function(self)
			if not self or not self.IsCraftable or not self:IsCraftable() then return end
			if not self.resultTooltip or not self.resultTooltip.tip then return end

			local itemLink = GetEnchantingResultingItemLink(self:GetAllCraftingBagAndSlots())
			if itemLink and itemLink ~= "" then
				local matCost = GetBagSlotCost(self:GetAllCraftingBagAndSlots())
				CraftPriceInfo(self.resultTooltip, matCost, itemLink)
			end
		end)
	end

	-- PROVISIONING
	if GAMEPAD_PROVISIONER then
		--	ZO_PostHook
		SecurePostHook(GAMEPAD_PROVISIONER, "RefreshRecipeDetails", function(self, selectedData)
			if not selectedData then return end
			if not self.resultTooltip or not self.resultTooltip.tip then return end

			local listID = selectedData.recipeListIndex
			local itemID = selectedData.recipeIndex
			if not listID or not itemID then return end

			local itemLink = GetRecipeResultItemLink(listID, itemID)
			if itemLink and itemLink ~= "" then
				local matCost = 0
				local _, _, numIngredients = GetRecipeInfo(listID, itemID)
				for i = 1, numIngredients do
					local _, _, qty = GetRecipeIngredientItemInfo(listID, itemID, i)
					local link = GetRecipeIngredientItemLink(listID, itemID, i)
					matCost = matCost + (GetTTCPrice(link) * qty)
				end

				CraftPriceInfo(self.resultTooltip, matCost, itemLink)
			end
		end)
	end
	-- CREATION
	if SMITHING_GAMEPAD and SMITHING_GAMEPAD.creationPanel then
		--ZO_PostHook
		SecurePostHook(SMITHING_GAMEPAD.creationPanel, "SetupResultTooltip", function(self)
			if not self or not self.resultTooltip or not self.resultTooltip.tip then return end

			local patternIndex, materialIndex, materialQuantity, itemStyleId, traitIndex = self:GetAllCraftingParameters()
			local itemLink = GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, itemStyleId,
				traitIndex)

			if itemLink and itemLink ~= "" then
				local baseLink = GetSmithingPatternMaterialItemLink(patternIndex, materialIndex)
				local styleLink = GetItemStyleMaterialLink(itemStyleId)
				local traitLink = GetSmithingTraitItemLink(traitIndex)
				local matCost = (GetTTCPrice(baseLink) * materialQuantity) + GetTTCPrice(styleLink) +
					GetTTCPrice(traitLink)

				CraftPriceInfo(self.resultTooltip, matCost, itemLink)
			end
		end)
	end

	-- IMPROVEMENT
	if SMITHING_GAMEPAD and SMITHING_GAMEPAD.improvementPanel then
		--ZO_PostHook
		SecurePostHook(SMITHING_GAMEPAD.improvementPanel, "SetupResultTooltip", function(self, bagId, slotIndex)
			if not self or not self.resultTooltip or not self.resultTooltip.tip then return end

			if not bagId or not slotIndex then
				bagId, slotIndex = self.inventory:CurrentSelectionBagAndSlot()
			end

			if bagId and slotIndex then
				local craftingType = GetCraftingInteractionType()
				local itemLink = GetSmithingImprovedItemLink(bagId, slotIndex, craftingType)

				if itemLink and itemLink ~= "" then
					local currentQuality = GetItemLinkQuality(GetItemLink(bagId, slotIndex))

					-- Grab the exact Item Link for the booster material
					local boosterItemLink = GetSmithingImprovementItemLink(craftingType, currentQuality)

					local quantity = 1
					if self.spinner and self.spinner.GetValue then quantity = self.spinner:GetValue() end

					local matCost = GetTTCPrice(boosterItemLink) * quantity

					CraftPriceInfo(self.resultTooltip, matCost, itemLink)
				end
			end
		end)
	end
end

ZO_TOOLTIP_STYLES.PTTGText = {
	width = ZO_GAMEPAD_CONTENT_WIDTH,
	paddingLeft = 0,
	paddingRight = 0,
	-- fontFace = "$(GAMEPAD_MEDIUM_FONT)",
	fontFace = "$(GAMEPAD_LIGHT_FONT)",
	fontSize = "$(GP_34)",
	--	fontColorType = INTERFACE_COLOR_TYPE_ANTIQUITY_QUALITY_COLORS,
	--	fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1, -- White
	--	fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2, -- Grey
	fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3, -- Off White

	fontStyle = "soft-shadow-thick",
}

ZO_TOOLTIP_STYLES.PTTGGoldCost = {
	width = ZO_GAMEPAD_CONTENT_WIDTH,
	paddingLeft = 0,
	paddingRight = 0,
	fontFace = "$(GAMEPAD_MEDIUM_FONT)",
	fontSize = "$(GP_36)",
	fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1,
	fontStyle = "soft-shadow-thick",
}

PriceTTG_GetStringColorFromColor = function(color)
	return PriceTTG_GetStringColor(color.Red, color.Green,
		color.Blue)
end
PriceTTG_GetChatTextColor = function(r, g, b) return PriceTTG_GetStringColor(r, g, b) end
PriceTTG_GetStringColor = function(red, green, blue)
	local color = ZO_ColorDef:New(red, green, blue, 1)
	return "|c" .. color:ToHex()
end

PriceTTG_PriceToChat = function(link, priceText, price)
	if CHAT_SYSTEM and CHAT_SYSTEM.textEntry and CHAT_SYSTEM.textEntry.editControl then
		local chat = CHAT_SYSTEM.textEntry.editControl
		if not chat:HasFocus() then StartChatInput() end

		if (priceText and price) then
			chat:InsertText("PT: " ..
				priceText .. " -> " .. PriceTTG_NumberFormat(price) .. " gold for " .. string.gsub(link, '|H0', '|H1'))
		else
			chat:InsertText("PT: No data for " .. string.gsub(link, '|H0', '|H1'))
		end
	end
end

-- INITIALIZATION
PriceTTG_Load = function(eventCode, addonName)
	if addonName ~= PTTG.AddOnName then return end
	EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

	PTTG.SavedVariables = ZO_SavedVars:NewAccountWide(PTTG.SavedVariablesFileName, PTTG.Version,
		nil, PTTG.Default)

	-- ATT Initialization
	if ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales then
		PriceTTG_ATT_Sales = ArkadiusTradeTools.Modules.Sales
	end

	-- UESP Initialization
	if uespLogSalesPrices or (uespLog and uespLog.InitSalesPrices) then
		if uespLog and uespLog.InitSalesPrices and not uespLog.SalesPrices then
			uespLog.InitSalesPrices()
		end
		if uespLog and uespLog.SalesPrices then
			PriceTTG_UESP_Sales_Exists = true
		end
	end

	if PTTG.SavedVariables.FirstTime == false then
		PTTG.SavedVariables.Init.FirstTime_1 = false
	end

	-- 1
	if PTTG.SavedVariables.Init.FirstTime_1 then
		if TamrielTradeCentrePrice then PTTG.SavedVariables.UseTTCPrice = true end
		if MasterMerchant then PTTG.SavedVariables.UseMMPrice = true end
		if PriceTTG_ATT_Sales then PTTG.SavedVariables.UseATTPrice = true end
		if PriceTTG_UESP_Sales_Exists then PTTG.SavedVariables.UseUESPPrice = true end
		PTTG.SavedVariables.Init.FirstTime_1 = false
	end
	-- 2
	if PTTG.SavedVariables.Init.FirstTime_2 then
		if PTTG.SavedVariables.Color then
			PTTG.SavedVariables.TooltipColor = {}
			PTTG.SavedVariables.TooltipColor.Red = PTTG.SavedVariables.Color.Red
			PTTG.SavedVariables.TooltipColor.Green = PTTG.SavedVariables.Color.Green
			PTTG.SavedVariables.TooltipColor.Blue = PTTG.SavedVariables.Color.Blue
			--
			PTTG.SavedVariables.GridPriceColor = {}
			PTTG.SavedVariables.GridPriceColor.Red = PTTG.SavedVariables.Color.Red
			PTTG.SavedVariables.GridPriceColor.Green = PTTG.SavedVariables.Color.Green
			PTTG.SavedVariables.GridPriceColor.Blue = PTTG.SavedVariables.Color.Blue
		end
		if PTTG.SavedVariables.UseVendorPrice ~= nil then
			PTTG.SavedVariables.DisplayVendorPrice =
				PTTG.SavedVariables.UseVendorPrice
		end
		if PTTG.SavedVariables.ShowBestPriceOnly ~= nil then
			PTTG.SavedVariables.DisplayBestPrice =
				PTTG.SavedVariables.ShowBestPriceOnly
		end
		if PTTG.SavedVariables.UseProfitPrice ~= nil then
			PTTG.SavedVariables.DisplayProfitPrice =
				PTTG.SavedVariables.UseProfitPrice
		end
		if PTTG.SavedVariables.UseTTCPrice ~= nil then
			PTTG.SavedVariables.DisplayTTCPrice = PTTG
				.SavedVariables.UseTTCPrice
		end
		if PTTG.SavedVariables.UseMMPrice ~= nil then
			PTTG.SavedVariables.DisplayMMPrice = PTTG
				.SavedVariables.UseMMPrice
		end
		if PTTG.SavedVariables.UseATTPrice ~= nil then
			PTTG.SavedVariables.DisplayATTPrice = PTTG
				.SavedVariables.UseATTPrice
		end
		if PTTG.SavedVariables.UseAveragePrice ~= nil then
			PTTG.SavedVariables.DisplayAveragePrice =
				PTTG.SavedVariables.UseAveragePrice
		end
		PTTG.SavedVariables.Init.FirstTime_2 = false
	end
	-- 3
	if PTTG.SavedVariables.Init.FirstTime_3 then
		if PTTG.SavedVariables.TooltipColor then
			PTTG.SavedVariables.PriceToChatColor = {}
			PTTG.SavedVariables.PriceToChatColor.Red = PTTG.SavedVariables.TooltipColor.Red
			PTTG.SavedVariables.PriceToChatColor.Green = PTTG.SavedVariables.TooltipColor.Green
			PTTG.SavedVariables.PriceToChatColor.Blue = PTTG.SavedVariables.TooltipColor.Blue
		end
		PTTG.SavedVariables.Init.FirstTime_3 = false
	end
	-- 4
	if PTTG.SavedVariables.Init.FirstTime_4 then
		PTTG.SavedVariables.OverrideBehaviour = PTTG.SavedVariables.OverrideBehaviour or
			Price_TTGS_AVERAGE_PRICE
		PTTG.SavedVariables.UseProfitPrice = true
		PTTG.SavedVariables.Init.FirstTime_4 = false
	end
	-- 5
	if PTTG.SavedVariables.Init.FirstTime_5 then
		if PTTG.SavedVariables.Init.OverrideItemPrice ~= nil then
			PTTG.SavedVariables.Init.UseGridItemPriceOverride =
				PTTG.SavedVariables.Init.OverrideItemPrice
		end
		if PTTG.SavedVariables.Init.OverrideBehaviour ~= nil then
			PTTG.SavedVariables.Init.GridItemPriceOverrideBehaviour =
				PTTG.SavedVariables.Init.OverrideBehaviour
		end
		PTTG.SavedVariables.Init.FirstTime_5 = false
	end
	-- 6
	if PTTG.SavedVariables.Init.FirstTime_6 then
		if PTTG.SavedVariables.IncludeProfitPriceToBestPrice ~= nil then
			PTTG.SavedVariables.IncludePPInBP = PTTG.SavedVariables.IncludeProfitPriceToBestPrice
		end
		PTTG.SavedVariables.Init.FirstTime_6 = false
	end
	-- 7
	if PTTG.SavedVariables.Init.FirstTime_7 then
		PTTG.SavedVariables.RoundPrice = true
		PTTG.SavedVariables.Init.FirstTime_7 = false
	end
	-- 8
	if PTTG.SavedVariables.Init.FirstTime_8 then
		if PTTG.SavedVariables.PriceToChatColor then
			PTTG.SavedVariables.ContextMenuColor = {}
			PTTG.SavedVariables.ContextMenuColor.Red = PTTG.SavedVariables.PriceToChatColor.Red
			PTTG.SavedVariables.ContextMenuColor.Green = PTTG.SavedVariables.PriceToChatColor.Green
			PTTG.SavedVariables.ContextMenuColor.Blue = PTTG.SavedVariables.PriceToChatColor.Blue
		end
		if PTTG.SavedVariables.UsePriceToChat ~= nil then
			PTTG.SavedVariables.UsePriceTooltipMenuGamepad = PTTG.SavedVariables.UsePriceToChat
		end
		PTTG.SavedVariables.Init.FirstTime_8 = false
	end
	-- 9
	if PTTG.SavedVariables.Init.FirstTime_9 then
		if PriceTTG_UESP_Sales_Exists then PTTG.SavedVariables.UseUESPPrice = true end
		PTTG.SavedVariables.Init.FirstTime_9 = false
	end
	PriceTTG_MENU.Init()
	-- MM
	if MasterMerchant then
		if not PriceTTG_Is_MM_Ready() then
			if not PTTG.SavedVariables.DisableStartupLog then
				PriceTTG_SystemPrint("[Price Tooltip] Waiting [MM]", 1, 0.5, 0, true)
			end
		end
	end
	zo_callLater(function() PriceTTG_Extensions() end, 1000)
end

PriceTTG_SystemPrint = function(line, r, g, b, delayed_message)
	local text = PriceTTG_GetChatTextColor(r, g, b) .. line .. "|r"

	if delayed_message then
		zo_callLater(function() d(text) end, 1000)
	else
		d(text)
	end
end

PriceTTG_Extensions = function()
	PriceTTG_InitGamepadTooltips()
	PriceTTG_GamePadActions()
	PriceTTG_CraftingHooks()
	PriceTTG_SystemPrint("[Price Tooltip GamePad] Initialized", 0, 1, 0, true)
	PriceTTG_IsLoaded = true
end

-- Switched from older code to add support for guildstore search results and store items.
PriceTTG_GamePadActions = function()
	local menu = LibCustomMenu
	if menu then
		menu:RegisterKeyStripEnter(function(inventorySlot, slotActions)
			if (IsInGamepadPreferredMode()) then
				local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
				local itemLink = nil

				if bagId and slotIndex then
					itemLink = GetItemLink(bagId, slotIndex)
				elseif inventorySlot.data and inventorySlot.data.itemLink then
					itemLink = inventorySlot.data.itemLink
				end

				if not itemLink then return end

				if PTTG.SavedVariables.UsePriceTooltipMenuGamepad then
					local stringColor = PriceTTG_GetStringColorFromColor(PTTG.SavedVariables.ContextMenuColor)

					local prices = PriceTTG_GetPrices(itemLink)

					local count = 0

					if prices then
						if PriceTTG_ValidPrice(prices.originalTTCPrice) then
							ZO_CreateStringId("SI_BINDING_NAME_Price_TTGS_TTC_PRICE",
								stringColor ..
								Price_TTGS_TTC_PRICE ..
								" -> " ..
								PriceTTG_NumberFormat(prices.originalTTCPrice) ..
								" " .. goldIcon)
							slotActions:AddCustomSlotAction(SI_BINDING_NAME_Price_TTGS_TTC_PRICE,
								function(...)
									PriceTTG_PriceToChat(itemLink, Price_TTGS_TTC_PRICE, prices.originalTTCPrice)
								end)
							count = count + 1
						end

						if PriceTTG_ValidPrice(prices.originalMMPrice) then
							ZO_CreateStringId("SI_BINDING_NAME_Price_TTGS_MM_PRICE",
								stringColor ..
								Price_TTGS_MM_PRICE ..
								" -> " ..
								PriceTTG_NumberFormat(prices.originalMMPrice) .. " " .. goldIcon)
							slotActions:AddCustomSlotAction(SI_BINDING_NAME_Price_TTGS_MM_PRICE,
								function(...)
									PriceTTG_PriceToChat(itemLink, Price_TTGS_MM_PRICE, prices.originalMMPrice)
								end)
							count = count + 1
						end

						if PriceTTG_ValidPrice(prices.originalATTPrice) then
							ZO_CreateStringId("SI_BINDING_NAME_Price_TTGS_ATT_PRICE",
								stringColor ..
								Price_TTGS_ATT_PRICE ..
								" -> " ..
								PriceTTG_NumberFormat(prices.originalATTPrice) ..
								" " .. goldIcon)
							slotActions:AddCustomSlotAction(SI_BINDING_NAME_Price_TTGS_ATT_PRICE,
								function(...)
									PriceTTG_PriceToChat(itemLink, Price_TTGS_ATT_PRICE, prices.originalATTPrice)
								end)
							count = count + 1
						end

						if PriceTTG_ValidPrice(prices.originalUESPPrice) then
							ZO_CreateStringId("SI_BINDING_NAME_Price_TTGS_UESP_PRICE",
								stringColor ..
								Price_TTGS_UESP_PRICE ..
								" -> " ..
								PriceTTG_NumberFormat(prices.originalUESPPrice) ..
								" " .. goldIcon)
							slotActions:AddCustomSlotAction(SI_BINDING_NAME_Price_TTGS_UESP_PRICE,
								function(...)
									PriceTTG_PriceToChat(itemLink, Price_TTGS_UESP_PRICE, prices.originalUESPPrice)
								end)
							count = count + 1
						end

						if PriceTTG_ValidPrice(prices.originalAveragePrice) then
							ZO_CreateStringId("SI_BINDING_NAME_Price_TTGS_AVG_PRICE",
								stringColor ..
								"AVG price to chat -> " ..
								PriceTTG_NumberFormat(prices.originalAveragePrice) ..
								" " .. goldIcon)
							slotActions:AddCustomSlotAction(SI_BINDING_NAME_Price_TTGS_AVG_PRICE,
								function(...) PriceTTG_PriceToChat(itemLink, "AVG price", prices.originalAveragePrice) end)
							count = count + 1
						end
					end

					if (count == 0) then
						ZO_CreateStringId("SI_BINDING_NAME_Price_TTGS_NO_PRICE",
							stringColor .. "Price to chat -> No data")
						slotActions:AddCustomSlotAction(SI_BINDING_NAME_Price_TTGS_NO_PRICE,
							function(...) PriceTTG_PriceToChat(itemLink, nil, nil) end)
					end
				end

				if PTTGNote then
					local noteColor = PTTGNote_GetStringColorFromColor(PTTGNote.SavedVariables.ContextMenuColor)
					ZO_CreateStringId("SI_BINDING_NAME_Price_TTGS_EDIT_NOTE", noteColor .. "Edit NOTE")
					ZO_CreateStringId("SI_BINDING_NAME_Price_TTGS_DELETE_NOTE", noteColor .. "Delete NOTE")

					slotActions:AddCustomSlotAction(SI_BINDING_NAME_Price_TTGS_EDIT_NOTE,
						function(...) PTTGNote_NoteToChat_Edit(itemLink) end)
					slotActions:AddCustomSlotAction(SI_BINDING_NAME_Price_TTGS_DELETE_NOTE,
						function(...) PTTGNote_NoteToChat_Delete(itemLink) end)
				end
			end
		end, menu.CATEGORY_PRIMARY)
	end
end

-- Gamepad tooltips for bags, inventory, store items and guild store search results.
PriceTTG_InitGamepadTooltips = function()
	if not GAMEPAD_TOOLTIPS then return end
	PriceTTG_GamePadToolTipExtension(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutBagItem")
	PriceTTG_GamePadToolTipExtension2(GAMEPAD_INVENTORY, "UpdateCategoryLeftTooltip")
	PriceTTG_GamePadToolTipExtension(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutBagItem")
	PriceTTG_GamePadToolTipExtension(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutBagItem")
	PriceTTG_GamePadToolTipExtension3(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP),
		"LayoutGuildStoreSearchResult")
	PriceTTG_GamePadToolTipExtension3(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP),
		"LayoutGuildStoreSearchResult")
	PriceTTG_GamePadToolTipExtension3(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP),
		"LayoutGuildStoreSearchResult")
	PriceTTG_GamePadToolTipExtension3(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutStoreWindowItem")
	PriceTTG_GamePadToolTipExtension4(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutLink")
	PriceTTG_GamePadToolTipExtension4(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutLink")
	PriceTTG_GamePadToolTipExtension4(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutLink")
end

PriceTTG_PostHook = function(control, method, fn)
	if control then
		local originalMethod = control[method]
		control[method] = function(self, ...)
			originalMethod(self, ...)
			fn(self, ...)
		end
	end
end

-- FROM uespLog -> function uespLog.FindSalesPrice(itemLink)
PriceTTG_uespLog_FindSalesPrice = function(itemLink)
	if (itemLink == nil) then
		return nil
	end

	local linkData = PriceTTG_uespLog_ParseItemLinkEx(itemLink)

	if (not linkData or uespLog.SalesPrices == nil) then
		return nil
	end

	linkData.itemId = tonumber(linkData.itemId)

	local levelData = uespLog.SalesPrices[linkData.itemId]

	if (levelData == nil) then
		--uespLog.DebugMsg("FindSalesPrice: No ItemID Data")
		return nil
	end

	local quality = GetItemLinkDisplayQuality(itemLink)
	local trait = GetItemLinkTraitInfo(itemLink)
	local level = GetItemLinkRequiredLevel(itemLink)
	local reqCP = GetItemLinkRequiredChampionPoints(itemLink)

	if (reqCP > 0) then
		level = 50 + math.floor(reqCP / 10)
	end

	linkData.potionData = tonumber(linkData.potionData)

	if (linkData.potionData == nil) then
		linkData.potionData = 0
	end

	if (linkData.writ1 > 0) then
		linkData.potionData = linkData.writ1 ..
			":" ..
			linkData.writ2 ..
			":" .. linkData.writ3 .. ":" .. linkData.writ4 .. ":" .. linkData.writ5 .. ":" .. linkData.writ6
	end

	local qualityData = levelData[level]

	if (qualityData == nil) then
		--uespLog.DebugMsg("FindSalesPrice: No Level Data")
		return nil
	end

	local traitData = qualityData[quality]

	if (traitData == nil) then
		--uespLog.DebugMsg("FindSalesPrice: No Quality Data")
		return nil
	end

	local potionData = traitData[trait]

	if (potionData == nil) then
		--uespLog.DebugMsg("FindSalesPrice: No Trait Data")
		return nil
	end

	local salesData = potionData[linkData.potionData]

	if (salesData == nil) then
		--uespLog.DebugMsg("FindSalesPrice: No Potion Data")
		return nil
	end

	if (uespLog.SalesPricesVersion == nil or uespLog.SalesPricesVersion > 1) then
		return nil
	end

	local result = {}

	result.price = salesData[1]
	result.priceSold = salesData[2]
	result.priceListed = salesData[3]
	result.countSold = salesData[4]
	result.countListed = salesData[5]
	result.itemsSold = salesData[6]
	result.itemsListed = salesData[7]
	result.count = result.countSold + result.countListed
	result.items = result.itemsSold + result.itemsListed
	result.itemLink = itemLink

	return result
end

-- FROM uespLog -> function uespLog.ParseItemLinkEx(link)
function PriceTTG_uespLog_ParseItemLinkEx(link)
	--|H1:item:Id:SubType:InternalLevel:EnchantId:EnchantSubType:EnchantLevel:Writ1:Writ2:Writ3:Writ4:Writ5:Writ6:0:0:0:Style:Crafted:Bound:Stolen::Charges:PotionEffect/WritReward|hName|h
	local linkData = {}

	if (link == nil) then
		return false
	end

	linkData.linkType, linkData.itemText, linkData.itemId, linkData.internalSubType, linkData.internalLevel, linkData.enchantId, linkData.enchantSubtype, linkData.enchantLevel, linkData.writ1, linkData.writ2, linkData.writ3, linkData.writ4, linkData.writ5, linkData.writ6, linkData.zero1, linkData.zero2, linkData.zero3, linkData.style, linkData.crafted, linkData.bound, linkData.stolen, linkData.charges, linkData.potionData, linkData.itemName =
		link:match(
			"|H(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h(.-)|h")

	if (linkData.linkType == nil) then
		return false
	end

	linkData.itemId = tonumber(linkData.itemId)
	linkData.internalSubType = tonumber(linkData.internalSubType)
	linkData.internalLevel = tonumber(linkData.internalLevel)
	linkData.enchantId = tonumber(linkData.enchantId)
	linkData.enchantSubtype = tonumber(linkData.enchantSubtype)
	linkData.enchantLevel = tonumber(linkData.enchantLevel)
	linkData.writ1 = tonumber(linkData.writ1)
	linkData.writ2 = tonumber(linkData.writ2)
	linkData.writ3 = tonumber(linkData.writ3)
	linkData.writ4 = tonumber(linkData.writ4)
	linkData.writ5 = tonumber(linkData.writ5)
	linkData.writ6 = tonumber(linkData.writ6)
	linkData.zero1 = tonumber(linkData.zero1)
	linkData.zero2 = tonumber(linkData.zero2)
	linkData.zero3 = tonumber(linkData.zero3)
	linkData.style = tonumber(linkData.style)
	linkData.crafted = tonumber(linkData.crafted)
	linkData.bound = tonumber(linkData.bound)
	linkData.stolen = tonumber(linkData.stolen)
	linkData.charges = tonumber(linkData.charges)
	linkData.potionData = tonumber(linkData.potionData)

	return linkData
end

EVENT_MANAGER:RegisterForEvent("PriceTTG_Load", EVENT_ADD_ON_LOADED, PriceTTG_Load)
