--[[
	Addon: PriceTooltip
	Author: Mladen90 (@Mladen90 EU), Infixo (CoAuthor)
	Created by Mladen90 (@Mladen90 EU)
]]--


PriceTooltip = {}
PriceTooltip_MENU = {}


PriceTooltip_IsLoaded = false


local PriceTooltip_ATT_Sales = nil
local PriceTooltip_LastDivider = nil


local PriceTooltip_UESP_Sales_Exists = false


PriceTooltip_Is_MM_Ready = function()
	return MasterMerchant and MasterMerchant.isInitialized and LibGuildStore and LibGuildStore.guildStoreReady
end


PriceTooltip_ValidPrice = function(price) return (price or 0) > 0 end


PriceTooltip_Round = function (num, numDecimalPlaces)
	if not num then return num end

	local decimalPlaces = numDecimalPlaces or 0

	if PriceTooltip.SavedVariables.RoundPrice then decimalPlaces = 0 end

	local mult = 10 ^ decimalPlaces
	return math.floor(num * mult + 0.5) / mult
end


PriceTooltip_NumberFormat = function(amount)
	local formatted = amount

	local separator = PriceTooltip.SavedVariables.Separator
	if separator == PRICE_TOOLTIP_EMPTY then return formatted end
	if separator == PRICE_TOOLTIP_SPACE then separator = " " end

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1" .. separator .. "%2")
		if (k==0) then break end
	end

	return formatted
end


PriceTooltip_GetPrices = function(itemLink)
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

	if not PriceTooltip_ValidPrice(prices.vendorPrice) then prices.vendorPrice = 0 end
	
	if PriceTooltip.SavedVariables.UseProfitPrice then
		prices.profitPrice = prices.vendorPrice * (1 + PriceTooltip.SavedVariables.ScaleProfitPrice / 100)
		if not PriceTooltip_ValidPrice(prices.profitPrice) then prices.profitPrice = 1 end
	end

	-- TTC
	if PriceTooltip.SavedVariables.UseTTCPrice then
		if TamrielTradeCentrePrice then
			local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
			if priceInfo then
				prices.originalTTCPrice = priceInfo.SuggestedPrice

				if priceInfo.SuggestedPrice then
					prices.infoTTC1 = string.format("TTC " .. GetString(TTC_PRICE_SUGGESTEDXTOY), TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice, 0), TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice * 1.25, 0))
				end

				prices.infoTTC2 = string.format(GetString(TTC_PRICE_AGGREGATEPRICESXYZ), TamrielTradeCentre:FormatNumber(priceInfo.Avg), TamrielTradeCentre:FormatNumber(priceInfo.Min), TamrielTradeCentre:FormatNumber(priceInfo.Max));

				if (PriceTooltip.SavedVariables.IncludeAvgTTCPrice and not PriceTooltip_ValidPrice(prices.originalTTCPrice)) then
					prices.originalTTCPrice = priceInfo.Avg
					prices.originalTTCPriceIsAvg = true
				end

				if (PriceTooltip.SavedVariables.DisplayTTCPriceInfo) then
					if priceInfo.EntryCount ~= priceInfo.AmountCount then
						prices.infoTTC3 = string.format(GetString(TTC_PRICE_XLISTINGSYITEMS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount), TamrielTradeCentre:FormatNumber(priceInfo.AmountCount))
					else
						prices.infoTTC3 = string.format(GetString(TTC_PRICE_XLISTINGS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount))
					end
				end
			end
			
			if PriceTooltip_ValidPrice(prices.originalTTCPrice) then
				if (prices.originalTTCPriceIsAvg) then prices.scaledTTCPrice = prices.originalTTCPrice * (1 + PriceTooltip.SavedVariables.ScaleAvgTTCPrice / 100)
				else prices.scaledTTCPrice = prices.originalTTCPrice * (1 + PriceTooltip.SavedVariables.ScaleTTCPrice / 100) end
			end
		end
	end

	-- MM
	if PriceTooltip.SavedVariables.UseMMPrice then
		if MasterMerchant then
			local itemInfo = MasterMerchant:itemStats(itemLink, false)
			prices.originalMMPrice = itemInfo.avgPrice

			if (PriceTooltip.SavedVariables.DisplayMMPriceInfo) then
				local tipLine, avgPrice, graphInfo = MasterMerchant:itemPriceTip(itemLink, false, clickable)
				if tipLine then prices.infoMM = zo_strformat("<<1>> ", tipLine) end
			end
			
			if PriceTooltip_ValidPrice(prices.originalMMPrice) then
				prices.scaledMMPrice = prices.originalMMPrice * (1 + PriceTooltip.SavedVariables.ScaleMMPrice / 100)
			end
		end
	end

	-- ATT
	if PriceTooltip.SavedVariables.UseATTPrice then
		if PriceTooltip_ATT_Sales then
			local fromTimeStamp = GetTimeStamp() - PriceTooltip.SavedVariables.ATTDays * 60 * 60 * 24

			prices.originalATTPrice = PriceTooltip_ATT_Sales:GetAveragePricePerItem(itemLink, fromTimeStamp)
			if PriceTooltip_ValidPrice(prices.originalATTPrice) then
				prices.scaledATTPrice = prices.originalATTPrice * (1 + PriceTooltip.SavedVariables.ScaleATTPrice / 100)
			end

			if (PriceTooltip.SavedVariables.DisplayATTPriceInfo) then
				prices.infoATT = PriceTooltip_GetAttInfo(itemLink, fromTimeStamp)
			end
		end
	end

	-- UESP
	if PriceTooltip.SavedVariables.UseUESPPrice then
		if PriceTooltip_UESP_Sales_Exists then
			local data = PriceTooltip_uespLog_FindSalesPrice(itemLink)
			if data then
				prices.originalUESPPrice = data.priceSold
				if PriceTooltip_ValidPrice(prices.originalUESPPrice) then
					prices.scaledUESPPrice = prices.originalUESPPrice * (1 + PriceTooltip.SavedVariables.ScaleUESPPrice / 100)
				end
			end
		end
	end

	if PriceTooltip.SavedVariables.UseAveragePrice then
		prices.scaledAveragePrice = 0
		prices.originalAveragePrice = 0
		local count = 0

		if PriceTooltip.SavedVariables.IncludeTTCInAP and PriceTooltip_ValidPrice(prices.scaledTTCPrice) then
			if (prices.originalTTCPriceIsAvg) then
				if (PriceTooltip.SavedVariables.IncludeTTCAvgInAP) then
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

		if PriceTooltip.SavedVariables.IncludeMMInAP and PriceTooltip_ValidPrice(prices.scaledMMPrice) then
			prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledMMPrice
			prices.originalAveragePrice = prices.originalAveragePrice + prices.originalMMPrice
			count = count + 1
		end

		if PriceTooltip.SavedVariables.IncludeATTInAP and PriceTooltip_ValidPrice(prices.scaledATTPrice) then
			prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledATTPrice
			prices.originalAveragePrice = prices.originalAveragePrice + prices.originalATTPrice
			count = count + 1
		end

		if PriceTooltip.SavedVariables.IncludeUESPInAP and PriceTooltip_ValidPrice(prices.scaledUESPPrice) then
			prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledUESPPrice
			prices.originalAveragePrice = prices.originalAveragePrice + prices.originalUESPPrice
			count = count + 1
		end

		if count > 0 then
			prices.originalAveragePrice = prices.originalAveragePrice / count
			prices.scaledAveragePrice = prices.scaledAveragePrice / count
		end
	end
	
	if PriceTooltip.SavedVariables.UseBestPrice then
		prices.bestPrice = 0

		if PriceTooltip.SavedVariables.UseTTCPrice and PriceTooltip_ValidPrice(prices.scaledTTCPrice) and prices.scaledTTCPrice > prices.bestPrice then
			if (PriceTooltip.SavedVariables.IncludeTTCAvgInBP or (not prices.originalTTCPriceIsAvg)) then
				prices.bestPrice = prices.scaledTTCPrice
				prices.bestPriceText = PRICE_TOOLTIP_TTC_PRICE
			end
		end

		if PriceTooltip.SavedVariables.UseMMPrice and PriceTooltip_ValidPrice(prices.scaledMMPrice) and prices.scaledMMPrice > prices.bestPrice then
			prices.bestPrice = prices.scaledMMPrice
			prices.bestPriceText = PRICE_TOOLTIP_MM_PRICE
		end

		if PriceTooltip.SavedVariables.UseATTPrice and PriceTooltip_ValidPrice(prices.scaledATTPrice) and prices.scaledATTPrice > prices.bestPrice then
			prices.bestPrice = prices.scaledATTPrice
			prices.bestPriceText = PRICE_TOOLTIP_ATT_PRICE
		end

		if PriceTooltip.SavedVariables.UseUESPPrice and PriceTooltip_ValidPrice(prices.scaledUESPPrice) and prices.scaledUESPPrice > prices.bestPrice then
			prices.bestPrice = prices.scaledUESPPrice
			prices.bestPriceText = PRICE_TOOLTIP_UESP_PRICE
		end

		if PriceTooltip.SavedVariables.IncludePPInBP and PriceTooltip.SavedVariables.UseProfitPrice and PriceTooltip_ValidPrice(prices.profitPrice) and prices.profitPrice > prices.bestPrice then
			prices.bestPrice = prices.profitPrice
			prices.bestPriceText = PRICE_TOOLTIP_PROFIT_PRICE
		end

		if not PriceTooltip_ValidPrice(prices.bestPrice) then
			prices.bestPrice = nil
			prices.bestPriceText = nil
		end

		if not PriceTooltip.SavedVariables.DisplaySourceInBP then
			prices.bestPriceText = nil
		end
	end

	prices.profitPrice = PriceTooltip_Round(prices.profitPrice, 2)
	prices.originalTTCPrice = PriceTooltip_Round(prices.originalTTCPrice, 2)
	prices.scaledTTCPrice = PriceTooltip_Round(prices.scaledTTCPrice, 2)
	prices.originalMMPrice = PriceTooltip_Round(prices.originalMMPrice, 2)
	prices.scaledMMPrice = PriceTooltip_Round(prices.scaledMMPrice, 2)
	prices.originalATTPrice = PriceTooltip_Round(prices.originalATTPrice, 2)
	prices.scaledATTPrice = PriceTooltip_Round(prices.scaledATTPrice, 2)
	prices.originalUESPPrice = PriceTooltip_Round(prices.originalUESPPrice, 2)
	prices.scaledUESPPrice = PriceTooltip_Round(prices.scaledUESPPrice, 2)
	prices.originalAveragePrice = PriceTooltip_Round(prices.originalAveragePrice, 2)
	prices.scaledAveragePrice = PriceTooltip_Round(prices.scaledAveragePrice, 2)
	prices.bestPrice = PriceTooltip_Round(prices.bestPrice, 2)

	return prices
end

PriceTooltip_GetAttInfo = function(itemLink, fromTimeStamp)
	itemLink = PriceTooltip_ATT_Sales:NormalizeItemLink(itemLink)
    if itemLink == nil then return nil end

    local itemSales = PriceTooltip_ATT_Sales:GetItemSalesInformation(itemLink, fromTimeStamp, true)
    local itemType = GetItemLinkItemType(itemLink)
	local statsString = nil
	
    for link, sales in pairs(itemSales) do
        local quantity = 0

        for _, sale in pairs(sales) do
            quantity = quantity + sale.quantity
        end

        if (link == itemLink) then
            if (quantity > 0) then
                if (itemType == ITEMTYPE_MASTER_WRIT) then
                    statsString = string.format("%s sales, %s writ vouchers", ArkadiusTradeTools:LocalizeDezimalNumber(#sales), ArkadiusTradeTools:LocalizeDezimalNumber(quantity))
                else
                    statsString = string.format("%s sales, %s items", ArkadiusTradeTools:LocalizeDezimalNumber(#sales), ArkadiusTradeTools:LocalizeDezimalNumber(quantity))
                end
            end
        end
    end

	return statsString
end


PriceTooltip_AddDivider = function(tooltipControl)
    if not tooltipControl.dividerPool then 
        tooltipControl.dividerPool = ZO_ControlPool:New("ZO_BaseTooltipDivider", tooltipControl, "Divider")
    end
	
	return tooltipControl.dividerPool:AcquireObject() 
end


--NOTE If original price is valid, scaled price is also valid.
--NOTE ProfitPrice is scaled price of VendorPrice
PriceTooltip_NoDisplayPrices = function(prices)
	return prices == nil or (not (PriceTooltip_ValidPrice(prices.vendorPrice) and PriceTooltip.SavedVariables.DisplayVendorPrice) and
							 not (PriceTooltip_ValidPrice(prices.profitPrice) and PriceTooltip.SavedVariables.DisplayProfitPrice) and
							 not (PriceTooltip_ValidPrice(prices.originalTTCPrice) and PriceTooltip.SavedVariables.DisplayTTCPrice) and
							 not ((prices.infoTTC1 or prices.infoTTC2 or prices.infoTTC3) and PriceTooltip.SavedVariables.DisplayTTCPriceInfo) and
							 not (PriceTooltip_ValidPrice(prices.originalMMPrice) and PriceTooltip.SavedVariables.DisplayMMPrice) and
							 not (prices.infoMM and PriceTooltip.SavedVariables.DisplayMMPriceInfo) and
							 not (PriceTooltip_ValidPrice(prices.originalATTPrice) and PriceTooltip.SavedVariables.DisplayATTPrice) and
							 not (prices.infoATT and PriceTooltip.SavedVariables.DisplayATTPriceInfo) and
							 not (PriceTooltip_ValidPrice(prices.originalUESPPrice) and PriceTooltip.SavedVariables.DisplayUESPPrice) and
							 not (PriceTooltip_ValidPrice(prices.originalAveragePrice) and PriceTooltip.SavedVariables.DisplayAveragePrice) and
							 not (PriceTooltip_ValidPrice(prices.bestPrice) and PriceTooltip.SavedVariables.DisplayBestPrice))
end


PriceTooltip_Print = function(prices)
	d("Start print prices:")
	PriceTooltip_PrintPriceInternal("vendorPrice", prices.vendorPrice)
	PriceTooltip_PrintPriceInternal("profitPrice", prices.profitPrice)
	PriceTooltip_PrintPriceInternal("originalTTCPrice", prices.originalTTCPrice)
	PriceTooltip_PrintPriceInternal("scaledTTCPrice", prices.scaledTTCPrice)
	PriceTooltip_PrintPriceInternal("originalMMPrice", prices.originalMMPrice)
	PriceTooltip_PrintPriceInternal("scaledMMPrice", prices.scaledMMPrice)
	PriceTooltip_PrintPriceInternal("originalATTPrice", prices.originalATTPrice)
	PriceTooltip_PrintPriceInternal("scaledATTPrice", prices.scaledATTPrice)
	PriceTooltip_PrintPriceInternal("originalUESPPrice", prices.originalUESPPrice)
	PriceTooltip_PrintPriceInternal("scaledUESPPrice", prices.scaledUESPPrice)
	PriceTooltip_PrintPriceInternal("originalAveragePrice", prices.originalAveragePrice)
	PriceTooltip_PrintPriceInternal("scaledAveragePrice", prices.scaledAveragePrice)
	PriceTooltip_PrintPriceInternal("bestPrice", prices.bestPrice)
	PriceTooltip_PrintPriceInternal("bestPriceText", prices.bestPriceText)
end


PriceTooltip_PrintPriceInternal = function(text, price)
	if text and PriceTooltip_ValidPrice(price) then
		d(priceText .. " -> " .. price)
	end
end


PriceTooltip_PrintTextInternal = function(text1, text2)
	if text1 and text2 then
		d(text1 .. " -> " .. text2)
	end
end


PriceTooltip_AddTooltip = function(control, itemLink, gamepad)
	if (not control) then return end
	
	local addedLine = 0

	local prices = PriceTooltip_GetPrices(itemLink)
	
	if not PriceTooltip_NoDisplayPrices(prices) then
		local stringPTIColor = PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.TooltipPriceInfoColor)
	
		if PriceTooltip.SavedVariables.DisplayVendorPrice and PriceTooltip_ValidPrice(prices.vendorPrice) then
			if gamepad then
				control:AddLine(PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.TooltipColor) .. "Vendor price " .. PriceTooltip_NumberFormat(prices.vendorPrice) .. PriceTooltip_GetGoldIcon(gamepad), ZO_TOOLTIP_STYLES[PriceTooltip.SavedVariables.GamepadFont])
			else
				local itemType = GetItemLinkItemType(itemLink)
		
				if (PriceTooltip_ItemTypes[itemType]) then
					-- Add spacing to match original spacing
					if (not (itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE )) then control:AddLine() end
				
					control:AddLine()

					control:AddLine(PriceTooltip_NumberFormat(prices.vendorPrice) .. PriceTooltip_GetGoldIcon(gamepad), "ZoFontWinH4")
				end
			end
		end
	end

	local divider = nil

	if not gamepad then
		divider = PriceTooltip_AddDivider(control)

		if (divider) then
			if (PriceTooltip.SavedVariables.FixDoubleTooltip) then
				if (PriceTooltip_LastDivider and PriceTooltip_LastDivider.PriceTooltipLink == itemLink and PriceTooltip_LastDivider:GetName() ~= divider:GetName()) then
					divider:SetHidden(true)
					return
				else
					if (PriceTooltip_LastDivider) then PriceTooltip_LastDivider.PriceTooltipLink = nil end

					divider.PriceTooltipLink = itemLink
					PriceTooltip_LastDivider = divider
				end
			else
				if (PriceTooltip_LastDivider) then PriceTooltip_LastDivider.PriceTooltipLink = nil end

				divider.PriceTooltipLink = nil
				PriceTooltip_LastDivider = nil
			end

			control:AddControl(divider)
			divider:SetAnchor(CENTER)
			divider:SetHidden(false)
		end
	end

	if not PriceTooltip_NoDisplayPrices(prices) then
		local stringPTIColor = PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.TooltipPriceInfoColor)

		if PriceTooltip.SavedVariables.DisplayProfitPrice then
			addedLine = addedLine + PriceTooltip_AddPTLine(control, PRICE_TOOLTIP_PROFIT_PRICE, prices.profitPrice, prices.vendorPrice, prices.profitPrice, nil, gamepad, nil, prices.isBound)
		end

		-- TTC
		if PriceTooltip.SavedVariables.DisplayTTCPrice then
			if (prices.originalTTCPriceIsAvg) then
				addedLine = addedLine + PriceTooltip_AddPTLine(control, PRICE_TOOLTIP_TTC_PRICE, prices.scaledTTCPrice, prices.vendorPrice, prices.profitPrice, nil, gamepad,
					PriceTooltip.SavedVariables.AvgTTCPriceColor, prices.isBound)
			else
				addedLine = addedLine + PriceTooltip_AddPTLine(control, PRICE_TOOLTIP_TTC_PRICE, prices.scaledTTCPrice, prices.vendorPrice, prices.profitPrice, nil, gamepad, nil, prices.isBound)
			end
		end
	
		if PriceTooltip.SavedVariables.DisplayTTCPriceInfo then
			if prices.infoTTC1 then addedLine = addedLine + PriceTooltip_AddTooltipLine(control, stringPTIColor .. prices.infoTTC1, gamepad, true) end
			if prices.infoTTC2 then addedLine = addedLine + PriceTooltip_AddTooltipLine(control, stringPTIColor .. prices.infoTTC2, gamepad, true) end
			if (prices.infoTTC2 and prices.infoTTC3 ~= prices.infoTTC2) or prices.infoTTC3 then
				addedLine = addedLine + PriceTooltip_AddTooltipLine(control, stringPTIColor .. prices.infoTTC3, gamepad, true)
			end
		end

		-- MM
		if PriceTooltip.SavedVariables.DisplayMMPrice then
			addedLine = addedLine + PriceTooltip_AddPTLine(control, PRICE_TOOLTIP_MM_PRICE, prices.scaledMMPrice, prices.vendorPrice, prices.profitPrice, nil, gamepad, nil, prices.isBound)
		end

		if PriceTooltip.SavedVariables.DisplayMMPriceInfo and prices.infoMM then
			addedLine = addedLine + PriceTooltip_AddTooltipLine(control, stringPTIColor .. prices.infoMM, gamepad, true)
		end

		-- ATT
		if PriceTooltip.SavedVariables.DisplayATTPrice then
			addedLine = addedLine + PriceTooltip_AddPTLine(control, PRICE_TOOLTIP_ATT_PRICE, prices.scaledATTPrice, prices.vendorPrice, prices.profitPrice, nil, gamepad, nil, prices.isBound)
		end

		if PriceTooltip.SavedVariables.DisplayATTPriceInfo and prices.infoATT then
			addedLine = addedLine + PriceTooltip_AddTooltipLine(control, stringPTIColor .. prices.infoATT, gamepad, true)
		end

		-- UESP
		if PriceTooltip.SavedVariables.DisplayUESPPrice then
			addedLine = addedLine + PriceTooltip_AddPTLine(control, PRICE_TOOLTIP_UESP_PRICE, prices.scaledUESPPrice, prices.vendorPrice, prices.profitPrice, nil, gamepad, nil, prices.isBound)
		end

		if PriceTooltip.SavedVariables.DisplayAveragePrice then
			if (prices.originalTTCPriceIsAvg) then
				addedLine = addedLine + PriceTooltip_AddPTLine(control, PRICE_TOOLTIP_TRADE_PRICE, prices.scaledAveragePrice, prices.vendorPrice, prices.profitPrice, nil, gamepad,
					PriceTooltip.SavedVariables.AvgTTCPriceColor, prices.isBound)
			else
				addedLine = addedLine + PriceTooltip_AddPTLine(control, PRICE_TOOLTIP_TRADE_PRICE, prices.scaledAveragePrice, prices.vendorPrice, prices.profitPrice, nil, gamepad, nil, prices.isBound)
			end
		end

		if PriceTooltip.SavedVariables.DisplayBestPrice then
			if (prices.originalTTCPriceIsAvg) then
				addedLine = addedLine + PriceTooltip_AddPTLine(control, PRICE_TOOLTIP_BEST_PRICE, prices.bestPrice, prices.vendorPrice, prices.profitPrice, prices.bestPriceText, gamepad,
					PriceTooltip.SavedVariables.AvgTTCPriceColor,prices.isBound)
			else
				addedLine =
					addedLine + PriceTooltip_AddPTLine(control, PRICE_TOOLTIP_BEST_PRICE, prices.bestPrice, prices.vendorPrice, prices.profitPrice, prices.bestPriceText, gamepad, nil, prices.isBound)
			end
		end
	end
	
	if PriceTooltipNote then
		local note = PriceTooltipNote_GetData(itemLink)
		if note then
			local noteColorText = PriceTooltipNote_GetStringColorFromColor(PriceTooltipNote.SavedVariables.TooltipColor)
			addedLine = addedLine + PriceTooltipNote_AddTooltipLine(control, noteColorText .. "NOTE: " .. note, gamepad)
		end
	end
	
	if not PriceTooltip_NoDisplayPrices(prices) then
		local stringErrorColor = PriceTooltip_GetStringColor(1, 0, 0)

		if PriceTooltip.SavedVariables.UseTTCPrice and not TamrielTradeCentrePrice then addedLine = addedLine + PriceTooltip_AddTooltipLine(control, stringErrorColor .. "TTC not available!", gamepad) end
		if PriceTooltip.SavedVariables.UseMMPrice and not MasterMerchant then addedLine = addedLine + PriceTooltip_AddTooltipLine(control, stringErrorColor .. "MM not available!", gamepad) end
		if PriceTooltip.SavedVariables.UseATTPrice and not PriceTooltip_ATT_Sales then addedLine = addedLine + PriceTooltip_AddTooltipLine(control, stringErrorColor .. "ATT not available!", gamepad) end
		if PriceTooltip.SavedVariables.UseUESPPrice and not PriceTooltip_UESP_Sales_Exists then addedLine = addedLine + PriceTooltip_AddTooltipLine(control, stringErrorColor .. "UESP not available!", gamepad) end
	end

	if divider then divider:SetHidden(addedLine < 1) end

	--Empty line instead of divider for gamepad
	if addedLine > 0 and gamepad then control:AddLine(" ") end
end


PriceTooltip_GetBoundPriceIndicator = function(is_bound)
	if is_bound and PriceTooltip.SavedVariables.MarkBoundItems then
		return PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.BoundItemMarkColor) .. "*"
	else
		return ""
	end
end


PriceTooltip_GetLowPriceIndicator = function(price, vendorPrice, profitPrice)
	local lowPriceIndikator = ""

	if PriceTooltip_ValidPrice(price) then
		if price <= vendorPrice then lowPriceIndikator = PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.VendorPriceLowPriceIndicatorColor) .. "*"
		elseif PriceTooltip.SavedVariables.UseProfitPrice and price < profitPrice then lowPriceIndikator = PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.ProfitPriceLowPriceIndicatorColor) .. "*" end
	end

	return lowPriceIndikator
end


PriceTooltip_AddPTLine = function(control, text, price, vendorPrice, profitPrice, info, gamepad, priceColor, isBound)
	if PriceTooltip_ValidPrice(price) then
		if info then info = " (" .. info .. ")" end

		local indicator = ""
		if PriceTooltip.SavedVariables.LowPriceIndicatorTooltip then
			indicator = PriceTooltip_GetLowPriceIndicator(price, vendorPrice, profitPrice)
		end
		indicator = indicator .. PriceTooltip_GetBoundPriceIndicator(isBound)

		local stringColorText = PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.TooltipColor)
		local stringColorPrice = stringColorText

		if priceColor then stringColorPrice = PriceTooltip_GetStringColorFromColor(priceColor) end
		
		PriceTooltip_AddTooltipLine(control, stringColorText .. text .. " " .. indicator .. stringColorPrice .. PriceTooltip_NumberFormat(price) .. PriceTooltip_GetGoldIcon(gamepad)
			.. stringColorText .. (info or ""), gamepad)

		return 1
	end

	return 0
end


PriceTooltip_GetGoldIcon = function(gamepad)
	if gamepad then return PRICE_TOOLTIP_GAMEPAD_GOLD_TEXT_ICON
	else return PRICE_TOOLTIP_GOLD_TEXT_ICON end
end


PriceTooltip_AddTooltipLine = function(control, text, gamepad, isPTI)
	if gamepad then
		if isPTI then
			control:AddLine(text, ZO_TOOLTIP_STYLES[PriceTooltip.SavedVariables.GamepadPriceInfoFont])
		else
			control:AddLine(text, ZO_TOOLTIP_STYLES[PriceTooltip.SavedVariables.GamepadFont])
		end
	else
		control:AddVerticalPadding(PriceTooltip.SavedVariables.TooltipLineSpacing)

		if isPTI then
			control:AddLine(text, PriceTooltip.SavedVariables.PriceInfoFont, 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, LEFT, false)
		else
			control:AddLine(text, PriceTooltip.SavedVariables.Font, 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_UPPERCASE, LEFT, false)
		end
	end

	return 1
end


PriceTooltip_GamePadToolTipExtension = function(toolTipControl, functionName)
  local base = toolTipControl[functionName]
  toolTipControl[functionName] = function(control, bagId, slotIndex, ...) 
	local itemLink = GetItemLink(bagId, slotIndex)

	if itemLink and control then
		PriceTooltip_AddTooltip(control, itemLink, true)
	end

    base(control, bagId, slotIndex, ...)
  end
end


PriceTooltip_GamePadToolTipExtension2 = function(toolTipControl, functionName)
  local base = toolTipControl[functionName]
  toolTipControl[functionName] = function(selectedData, ...)
    base(selectedData, ...)
	if toolTipControl.selectedEquipSlot then
		GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, BAG_WORN, toolTipControl.selectedEquipSlot)
	end
  end
end


PriceTooltip_ToolTipExtension = function(toolTipControl, functionName, getItemLinkFunction)
	local base = toolTipControl[functionName]
	
	toolTipControl[functionName] = function(control, ...)
		base(control, ...)
		
		if not getItemLinkFunction then return end
		
		local itemLink = getItemLinkFunction(...)
		
		if itemLink and control then
			PriceTooltip_AddTooltip(control, itemLink, false)
		end
	end
end


PriceTooltip_GetWornItemLink = function(equipSlot) return GetItemLink(BAG_WORN, equipSlot) end
PriceTooltip_GetItemLinkFirstParam = function(itemLink) return itemLink end


PriceTooltip_GetStringColorFromColor = function(color) return PriceTooltip_GetStringColor(color.Red, color.Green, color.Blue) end
PriceTooltip_GetChatTextColor = function(r, g ,b) return PriceTooltip_GetStringColor(r, g, b) end


PriceTooltip_GetStringColor = function(red, green, blue)
	local color = ZO_ColorDef:New(red, green, blue, 1)
	return "|c" .. color:ToHex()
end


PriceTooltip_ChangeGridPrice = function(control, slot)
	if not PriceTooltip.SavedVariables.UseGridItemPriceOverride then return end

	local mainControl = nil
	if control and control.dataEntry and control.dataEntry.data and control.dataEntry.data.bagId and control.dataEntry.data.slotIndex and control.dataEntry.data.stackCount then
		mainControl = control
	elseif slot and slot.dataEntry and slot.dataEntry.data and slot.dataEntry.data.bagId and slot.dataEntry.data.slotIndex and slot.dataEntry.data.stackCount then
		mainControl = slot
	end
	
	if mainControl then
		local bagId = mainControl.dataEntry.data.bagId
		local slotIndex = mainControl.dataEntry.data.slotIndex
		local stackCount = mainControl.dataEntry.data.stackCount
		local itemLink = bagId and GetItemLink(bagId, slotIndex) or GetItemLink(slotIndex)

		if not itemLink then return end
		
		local prices = PriceTooltip_GetPrices(itemLink)

		if not prices then return end
				
		local sellPriceControl = mainControl:GetNamedChild("SellPriceText")

		if not sellPriceControl then return end

		local ptControl = sellPriceControl.PTControl

		if (not ptControl) then
			ptControl = WINDOW_MANAGER:CreateControl(nil, sellPriceControl, CT_LABEL)
			ptControl:SetColor(1, 1, 1)
			ptControl:SetFont("ZoFontGameShadow")
			ptControl:SetDrawLayer(0)
			ptControl:SetAnchor(TOPRIGHT, nil, BOTTOMRIGHT, 0, 0)
			ptControl:SetAlpha(1)
			ptControl:SetScale(0.7)
			sellPriceControl.PTControl = ptControl
		end

		local priceType = PriceTooltip.SavedVariables.GridItemPriceOverrideBehaviour
		local price = PriceTooltip_GetPriceByType(prices, priceType)
		local gridPriceColor = PriceTooltip.SavedVariables.GridPriceColor

		if (prices.originalTTCPriceIsAvg) then
			if (priceType == PRICE_TOOLTIP_TTC_PRICE and PriceTooltip.SavedVariables.IncludeAvgTTCPrice) then
				gridPriceColor = PriceTooltip.SavedVariables.AvgTTCPriceColor
			elseif (priceType == PRICE_TOOLTIP_AVERAGE_PRICE and PriceTooltip.SavedVariables.IncludeTTCAvgInAP) then
				gridPriceColor = PriceTooltip.SavedVariables.AvgTTCPriceColor
			elseif (priceType == PRICE_TOOLTIP_BEST_PRICE) then
				gridPriceColor = PriceTooltip.SavedVariables.AvgTTCPriceColor
			end
		end

		local indikator = ""
		if priceType ~= PRICE_TOOLTIP_DEFAULT_PRICE and
		   priceType ~= PRICE_TOOLTIP_PROFIT_PRICE and
		   PriceTooltip.SavedVariables.LowPriceIndicatorGrid then
			indikator = PriceTooltip_GetLowPriceIndicator(price, prices.vendorPrice, prices.profitPrice)
		end
		indikator = indikator .. PriceTooltip_GetBoundPriceIndicator(prices.isBound)

		--TODO check why it is set here and not earlier
		if not PriceTooltip_ValidPrice(price) then
			price = prices.vendorPrice
		elseif prices.isBound and PriceTooltip.SavedVariables.BoundItemsAsVendorPrice then
			price = prices.vendorPrice
		end

		local displayPrice = PriceTooltip_Round(price)
		local otherPrice = PriceTooltip_Round(price)

		if PriceTooltip.SavedVariables.ShowSingleItemPriceInGrid then otherPrice = PriceTooltip_Round(price * stackCount)
		else displayPrice = PriceTooltip_Round(price * stackCount) end

		if PriceTooltip.SavedVariables.UseMinItemGridPrice then
			if price < PriceTooltip.SavedVariables.MinItemGridPrice then PriceTooltip_SetGridPrice(sellPriceControl, indikator, 1, 1, 1, displayPrice, otherPrice)
			else PriceTooltip_SetGridPrice(sellPriceControl, indikator, gridPriceColor.Red, gridPriceColor.Green, gridPriceColor.Blue, displayPrice, otherPrice) end
		else
			if price == prices.vendorPrice then PriceTooltip_SetGridPrice(sellPriceControl, indikator, 1, 1, 1, displayPrice, otherPrice)
			else PriceTooltip_SetGridPrice(sellPriceControl, indikator, gridPriceColor.Red, gridPriceColor.Green, gridPriceColor.Blue, displayPrice, otherPrice) end
		end
	end
end


PriceTooltip_GetPriceByType = function(prices, priceType)
	local price = nil

	if prices then
		if priceType == PRICE_TOOLTIP_DEFAULT_PRICE then price = prices.vendorPrice
		elseif priceType == PRICE_TOOLTIP_AVERAGE_PRICE then price = prices.scaledAveragePrice
		elseif priceType == PRICE_TOOLTIP_MM_PRICE then price = prices.scaledMMPrice
		elseif priceType == PRICE_TOOLTIP_TTC_PRICE then price = prices.scaledTTCPrice
		elseif priceType == PRICE_TOOLTIP_ATT_PRICE then price = prices.scaledATTPrice
		elseif priceType == PRICE_TOOLTIP_UESP_PRICE then price = prices.scaledUESPPrice
		elseif priceType == PRICE_TOOLTIP_BEST_PRICE then price = prices.bestPrice
		elseif priceType == PRICE_TOOLTIP_PROFIT_PRICE then price = prices.profitPrice
		end
	end

	return price
end


PriceTooltip_SetGridPrice = function(sellPriceControl, lowPriceIndikator, r, g, b, displayPrice, otherPrice)
	local stringColor = PriceTooltip_GetStringColor(r, g, b)

	if PriceTooltip.SavedVariables.EnableFirstPriceInGrid then
		sellPriceControl:SetText(lowPriceIndikator .. stringColor .. PriceTooltip_NumberFormat(displayPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON)
	end

	if (PriceTooltip.SavedVariables.EnableSecondPriceInGrid) then
		if (otherPrice <= displayPrice) then
			sellPriceControl.PTControl:SetText(stringColor .. "@" .. PriceTooltip_NumberFormat(otherPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON)
		else
			sellPriceControl.PTControl:SetText(stringColor .. "=" .. PriceTooltip_NumberFormat(otherPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON)
		end
	else
		sellPriceControl.PTControl:SetText("")
	end
end


PriceTooltip_GridPriceExtension = function()
	if MasterMerchant and PriceTooltip.SavedVariables.OverrideMM then
		local base = MasterMerchant["SwitchPrice"]
		
		MasterMerchant["SwitchPrice"] = function(control, slot)
			base(control, slot)
			PriceTooltip_ChangeGridPrice(control, slot)
		end

		local base2 = MasterMerchant["SwitchUnitPrice"]

		MasterMerchant["SwitchUnitPrice"] = function(control, slot)
			base2(control, slot)
			PriceTooltip_ChangeGridPrice(control, slot)
		end
	else
		for _,i in pairs(PLAYER_INVENTORY.inventories) do
			local listView = i.listView
			if listView and listView.dataTypes and listView.dataTypes[1] then
				local originalCall = listView.dataTypes[1].setupCallback				
				listView.dataTypes[1].setupCallback = function(control, slot)						
					originalCall(control, slot)
					PriceTooltip_ChangeGridPrice(control, slot)
				end
			end
		end

		local originalCall = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1].setupCallback
		ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1].setupCallback = function(control, slot)
			originalCall(control, slot)
			PriceTooltip_ChangeGridPrice(control, slot)
		end
	end
end


PriceTooltip_PriceToChat = function(link, priceText, price)
	if CHAT_SYSTEM and CHAT_SYSTEM.textEntry and CHAT_SYSTEM.textEntry.editControl then
		local chat = CHAT_SYSTEM.textEntry.editControl
		if not chat:HasFocus() then StartChatInput() end

		if (priceText and price) then
			chat:InsertText("PT: " .. priceText .. " -> ".. PriceTooltip_NumberFormat(price)  .. " gold for " .. string.gsub(link, '|H0', '|H1'))
		else
			chat:InsertText("PT: No data for " .. string.gsub(link, '|H0', '|H1'))
		end
	end
end


PriceTooltip_AddCustomMenuItems = function(link, button)
	if not (link and button == MOUSE_BUTTON_INDEX_RIGHT) then return end

	local linkType = GetLinkType(link)
	if linkType == LINK_TYPE_ACHIEVEMENT then return end

	if PriceTooltip.SavedVariables.UsePriceTooltipMenu then
		local count = 1
		local entries = {}

		local prices = PriceTooltip_GetPrices(link)
		if prices then
			if PriceTooltip_ValidPrice(prices.originalTTCPrice) then
				entries[count] = 
				{
					label = PRICE_TOOLTIP_TTC_PRICE .. " to chat -> " .. PriceTooltip_NumberFormat(prices.originalTTCPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
					callback = function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_TTC_PRICE, prices.originalTTCPrice) end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1
			end

			if PriceTooltip_ValidPrice(prices.originalMMPrice) then
				entries[count] = 
				{
					label = PRICE_TOOLTIP_MM_PRICE .. " to chat -> " .. PriceTooltip_NumberFormat(prices.originalMMPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
					callback = function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_MM_PRICE, prices.originalMMPrice) end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1
			end

			if PriceTooltip_ValidPrice(prices.originalATTPrice) then
				entries[count] = 
				{
					label = PRICE_TOOLTIP_ATT_PRICE .. " to chat -> " .. PriceTooltip_NumberFormat(prices.originalATTPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
					callback = function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_ATT_PRICE, prices.originalATTPrice) end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1
			end

			if PriceTooltip_ValidPrice(prices.originalUESPPrice) then
				entries[count] = 
				{
					label = PRICE_TOOLTIP_UESP_PRICE .. " to chat -> " .. PriceTooltip_NumberFormat(prices.originalUESPPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
					callback = function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_UESP_PRICE, prices.originalUESPPrice) end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1
			end

			if PriceTooltip_ValidPrice(prices.originalAveragePrice) then
				entries[count] = 
				{
					label = "AVG price to chat -> " .. PriceTooltip_NumberFormat(prices.originalAveragePrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
					callback = function(...) PriceTooltip_PriceToChat(link, "AVG price", prices.originalAveragePrice) end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1
			end
		end

		if (count == 1) then
			entries[count] = 
			{
				label = "Price to chat -> No data",
				callback = function(...) PriceTooltip_PriceToChat(link, nil, nil) end,
				itemType = MENU_ADD_OPTION_LABEL,
			}
			count = count + 1
		end

		if count > 1 then
			local stringColor = PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.ContextMenuColor)
			AddCustomSubMenuItem(stringColor .. "PT MENU", entries)
		end
	end

	-- if PriceTooltipNote then
	-- 	local count = 1
	-- 	local entries = {}
 
	-- 	entries[count] = 
	-- 	{
	-- 		label = "Edit NOTE",
	-- 		callback = function(...) PriceTooltipNote_NoteToChat_Edit(link) end,
	-- 		itemType = MENU_ADD_OPTION_LABEL,
	-- 	}
	-- 	count = count + 1
 
	-- 	entries[count] = 
	-- 	{
	-- 		label = "Delete NOTE",
	-- 		callback = function(...) PriceTooltipNote_NoteToChat_Delete(link) end,
	-- 		itemType = MENU_ADD_OPTION_LABEL,
	-- 	}
	-- 	count = count + 1
 
	-- 	local stringColor = PriceTooltipNote_GetStringColorFromColor(PriceTooltipNote.SavedVariables.ContextMenuColor)
	-- 	AddCustomSubMenuItem(stringColor .. "PTN MENU", entries)
	-- end

	ShowMenu()
end


PriceTooltip_LinkHandlerExtension = function()
	local base = ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp = function(link, button, control)
		base(link, button, control)
		PriceTooltip_AddCustomMenuItems(link, button)
	end
end


PriceTooltip_ShowContextMenuExtension = function(inventorySlot)
	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
	if not (bagId and slotIndex) then return end

	local itemLink = GetItemLink(bagId, slotIndex)
	if not itemLink then return end

	PriceTooltip_AddCustomMenuItems(itemLink, MOUSE_BUTTON_INDEX_RIGHT)
end


PriceTooltip_Load = function(eventCode, addonName)
    if addonName ~= PriceTooltip.AddOnName then return end

    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

	PriceTooltip.SavedVariables = ZO_SavedVars:NewAccountWide(PriceTooltip.SavedVariablesFileName, PriceTooltip.Version, nil, PriceTooltip.Default)

	if ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales then
		PriceTooltip_ATT_Sales = ArkadiusTradeTools.Modules.Sales
	end

	if uespLog and uespLog.InitSalesPrices then
		if uespLog.version then
			if not PriceTooltip.SavedVariables.DisableStartupLog then
				PriceTooltip_SystemPrint("[PriceTooltip] You only need [uespLogSalesPrices], you can disable [uespLog]", 1, 0.5, 0, true)
			end
		else
			if not uespLog.SalesPrices then
				uespLog.InitSalesPrices()
			end
		end

		PriceTooltip_UESP_Sales_Exists = true
	end

	if PriceTooltip.SavedVariables.FirstTime == false then
		PriceTooltip.SavedVariables.Init.FirstTime_1 = false
	end

	if PriceTooltip.SavedVariables.Init.FirstTime_1 then
		if TamrielTradeCentrePrice then PriceTooltip.SavedVariables.UseTTCPrice = true end
		if MasterMerchant then PriceTooltip.SavedVariables.UseMMPrice = true end
		if PriceTooltip_ATT_Sales then PriceTooltip.SavedVariables.UseATTPrice = true end
		if PriceTooltip_UESP_Sales_Exists then PriceTooltip.SavedVariables.UseUESPPrice = true end
		PriceTooltip.SavedVariables.Init.FirstTime_1 = false
	end

	if PriceTooltip.SavedVariables.Init.FirstTime_2 then
		if PriceTooltip.SavedVariables.Color then
			PriceTooltip.SavedVariables.TooltipColor = {}
			PriceTooltip.SavedVariables.TooltipColor.Red = PriceTooltip.SavedVariables.Color.Red
			PriceTooltip.SavedVariables.TooltipColor.Green = PriceTooltip.SavedVariables.Color.Green
			PriceTooltip.SavedVariables.TooltipColor.Blue = PriceTooltip.SavedVariables.Color.Blue

			PriceTooltip.SavedVariables.GridPriceColor = {}
			PriceTooltip.SavedVariables.GridPriceColor.Red = PriceTooltip.SavedVariables.Color.Red
			PriceTooltip.SavedVariables.GridPriceColor.Green = PriceTooltip.SavedVariables.Color.Green
			PriceTooltip.SavedVariables.GridPriceColor.Blue = PriceTooltip.SavedVariables.Color.Blue
		end

		if PriceTooltip.SavedVariables.UseVendorPrice ~= nil then PriceTooltip.SavedVariables.DisplayVendorPrice = PriceTooltip.SavedVariables.UseVendorPrice end
		if PriceTooltip.SavedVariables.ShowBestPriceOnly ~= nil then PriceTooltip.SavedVariables.DisplayBestPrice = PriceTooltip.SavedVariables.ShowBestPriceOnly end
		if PriceTooltip.SavedVariables.UseProfitPrice ~= nil then PriceTooltip.SavedVariables.DisplayProfitPrice = PriceTooltip.SavedVariables.UseProfitPrice end
		if PriceTooltip.SavedVariables.UseTTCPrice ~= nil then PriceTooltip.SavedVariables.DisplayTTCPrice = PriceTooltip.SavedVariables.UseTTCPrice end
		if PriceTooltip.SavedVariables.UseMMPrice ~= nil then PriceTooltip.SavedVariables.DisplayMMPrice = PriceTooltip.SavedVariables.UseMMPrice end
		if PriceTooltip.SavedVariables.UseATTPrice ~= nil then PriceTooltip.SavedVariables.DisplayATTPrice = PriceTooltip.SavedVariables.UseATTPrice end
		if PriceTooltip.SavedVariables.UseAveragePrice ~= nil then PriceTooltip.SavedVariables.DisplayAveragePrice = PriceTooltip.SavedVariables.UseAveragePrice end

		PriceTooltip.SavedVariables.Init.FirstTime_2 = false
	end
	
	if PriceTooltip.SavedVariables.Init.FirstTime_3 then
		if PriceTooltip.SavedVariables.TooltipColor then
			PriceTooltip.SavedVariables.PriceToChatColor = {}
			PriceTooltip.SavedVariables.PriceToChatColor.Red = PriceTooltip.SavedVariables.TooltipColor.Red
			PriceTooltip.SavedVariables.PriceToChatColor.Green = PriceTooltip.SavedVariables.TooltipColor.Green
			PriceTooltip.SavedVariables.PriceToChatColor.Blue = PriceTooltip.SavedVariables.TooltipColor.Blue
		end

		PriceTooltip.SavedVariables.Init.FirstTime_3 = false
	end
	
	if PriceTooltip.SavedVariables.Init.FirstTime_4 then
		PriceTooltip.SavedVariables.OverrideBehaviour = PriceTooltip.SavedVariables.OverrideBehaviour or PRICE_TOOLTIP_AVERAGE_PRICE
		PriceTooltip.SavedVariables.UseProfitPrice = true
		PriceTooltip.SavedVariables.Init.FirstTime_4 = false
	end

	if PriceTooltip.SavedVariables.Init.FirstTime_5 then
		if PriceTooltip.SavedVariables.Init.OverrideItemPrice ~= nil then PriceTooltip.SavedVariables.Init.UseGridItemPriceOverride = PriceTooltip.SavedVariables.Init.OverrideItemPrice end
		if PriceTooltip.SavedVariables.Init.OverrideBehaviour ~= nil then PriceTooltip.SavedVariables.Init.GridItemPriceOverrideBehaviour = PriceTooltip.SavedVariables.Init.OverrideBehaviour end
		PriceTooltip.SavedVariables.Init.FirstTime_5 = false
	end

	if PriceTooltip.SavedVariables.Init.FirstTime_6 then
		if PriceTooltip.SavedVariables.IncludeProfitPriceToBestPrice ~= nil then 
			PriceTooltip.SavedVariables.IncludePPInBP = PriceTooltip.SavedVariables.IncludeProfitPriceToBestPrice
		end

		PriceTooltip.SavedVariables.Init.FirstTime_6 = false
	end

	if PriceTooltip.SavedVariables.Init.FirstTime_7 then
		PriceTooltip.SavedVariables.RoundPrice = true
		PriceTooltip.SavedVariables.Init.FirstTime_7 = false
	end

	if PriceTooltip.SavedVariables.Init.FirstTime_8 then
		if PriceTooltip.SavedVariables.PriceToChatColor then
			PriceTooltip.SavedVariables.ContextMenuColor = {}
			PriceTooltip.SavedVariables.ContextMenuColor.Red = PriceTooltip.SavedVariables.PriceToChatColor.Red
			PriceTooltip.SavedVariables.ContextMenuColor.Green = PriceTooltip.SavedVariables.PriceToChatColor.Green
			PriceTooltip.SavedVariables.ContextMenuColor.Blue = PriceTooltip.SavedVariables.PriceToChatColor.Blue
		end

		if PriceTooltip.SavedVariables.UsePriceToChat ~= nil then
			PriceTooltip.SavedVariables.UsePriceTooltipMenu = PriceTooltip.SavedVariables.UsePriceToChat
		end

		PriceTooltip.SavedVariables.Init.FirstTime_8 = false
	end

	if PriceTooltip.SavedVariables.Init.FirstTime_9 then
		if PriceTooltip_UESP_Sales_Exists then PriceTooltip.SavedVariables.UseUESPPrice = true end

		PriceTooltip.SavedVariables.Init.FirstTime_9 = false
	end
	
	PriceTooltip_MENU.Init()

	if MasterMerchant then
		if not PriceTooltip_Is_MM_Ready() then
			if not PriceTooltip.SavedVariables.DisableStartupLog then
				PriceTooltip_SystemPrint("[PriceTooltip] Waiting [MM]", 1, 0.5, 0, true)
			end
		end
	end

	zo_callLater(function() PriceTooltip_LoadLater() end, 1000)
end


PriceTooltip_SystemPrint = function(line, r, g, b, delayed_message)
	local text = PriceTooltip_GetChatTextColor(r, g, b) .. line .. "|r"

	if delayed_message then zo_callLater(function() d(text) end, 1000)
	else d(text) end
end


PriceTooltip_LoadLater = function()
	if MasterMerchant then
		if not PriceTooltip_Is_MM_Ready() then
			zo_callLater(function() PriceTooltip_LoadLater() end, 1000)
			return
		end
	end

	PriceTooltip_Extensions()

	if PriceTooltip.SavedVariables.UseGridSort then
		local sortKeys = ZO_Inventory_GetDefaultHeaderSortKeys()
		sortKeys["ptValue"] = { isNumeric = true, tiebreaker = "name" }
		
		PriceTooltip_AllSortByValueHeader()
		PriceTooltip_UpdateAllSortByValueHeader()

		ZO_PreHook(PLAYER_INVENTORY, "ApplySort", PriceTooltip_LoadSortData)
	end

	PriceTooltip_SystemPrint("[PriceTooltip] Initialized", 0, 1, 0, true)

	PriceTooltip_IsLoaded = true
end


PriceTooltip_LoadSortData = function(inventoryManager, inventoryType)
	if
	(
		inventoryType and
		inventoryManager and
		inventoryManager.inventories and
		inventoryManager.inventories[inventoryType] and
		inventoryManager.inventories[inventoryType].slots
	) then
		local priceType = PriceTooltip.SavedVariables.GridSortBehaviour

		for slotsId, slots in pairs(inventoryManager.inventories[inventoryType].slots) do
			for slotId, slot in pairs(slots) do
				if (not slot.lnk) then
					if (slot.searchData) then
						local bagId = slot.searchData.bagId
						local slotIndex = slot.searchData.slotIndex
						--local type = slot.searchData["type"]

						if bagId and slotIndex then
							local item_link = GetItemLink(bagId, slotIndex)

							if item_link then
								slot.lnk = item_link
							end
						end
					end
				end

				if slot.lnk then
					if (not PriceTooltip.SavedVariables.UseGridCacheModus) or slot.ptType ~= priceType or slot.ptLink ~= slot.lnk then
						local price = 0
						
						local prices = PriceTooltip_GetPrices(slot.lnk)
						if prices then
							if prices.isBound and PriceTooltip.SavedVariables.BoundItemsAsVendorPrice then
								price = prices.vendorPrice
							else 
								price = PriceTooltip_GetPriceByType(prices, priceType)
							end
							price = PriceTooltip_Round(price)

							if not PriceTooltip_ValidPrice(price) then price = prices.vendorPrice end
						end
						
						slot.ptItemValue = price
						slot.ptType = priceType
						slot.ptLink = slot.lnk
					end

					if PriceTooltip.SavedVariables.SortGridByStackValue then slot.ptValue = slot.ptItemValue * slot.stackCount
					else slot.ptValue = slot.ptItemValue end
				end
			end
		end
	end
end


PriceTooltip_AllSortByValueHeader = function()
	if (PriceTooltip.SavedVariables.UseNewSortButton) then
		PriceTooltip_SortByValueHeaderNew(INVENTORY_BACKPACK, ZO_PlayerInventorySortBy)
		PriceTooltip_SortByValueHeaderNew(INVENTORY_CRAFT_BAG, ZO_CraftBagSortBy)
		PriceTooltip_SortByValueHeaderNew(INVENTORY_BANK, ZO_PlayerBankSortBy)
		PriceTooltip_SortByValueHeaderNew(INVENTORY_GUILD_BANK, ZO_GuildBankSortBy)
		PriceTooltip_SortByValueHeaderNew(INVENTORY_HOUSE_BANK, ZO_HouseBankSortBy)
	else
		PriceTooltip_SortByValueHeaderOld(INVENTORY_BACKPACK, ZO_PlayerInventorySortBy, ZO_PlayerInventorySortByPriceName)
		PriceTooltip_SortByValueHeaderOld(INVENTORY_CRAFT_BAG, ZO_CraftBagSortBy, ZO_CraftBagSortByPriceName)
		PriceTooltip_SortByValueHeaderOld(INVENTORY_BANK, ZO_PlayerBankSortBy, ZO_PlayerBankSortByPriceName)
		PriceTooltip_SortByValueHeaderOld(INVENTORY_GUILD_BANK, ZO_GuildBankSortBy, ZO_GuildBankSortByPriceName)
		PriceTooltip_SortByValueHeaderOld(INVENTORY_HOUSE_BANK, ZO_HouseBankSortBy, ZO_HouseBankSortByPriceName)
	end
end


PriceTooltip_SortByValueHeaderOld = function(inventoryType, sortControl, priceNameControl)
	-- Moving Original Price sort to left for more space
	local parent = priceNameControl:GetParent()
	priceNameControl:ClearAnchors();
	priceNameControl:SetAnchor(LEFT, parent, LEFT, 0, 0)

	local sortHeader = CreateControlFromVirtual("$(parent)PTV", sortControl, "ZO_SortHeaderIcon")
	sortHeader:SetAnchor(LEFT, priceNameControl, RIGHT, 20, 0)
	sortHeader:SetDimensions(15, 30)

    ZO_SortHeader_InitializeArrowHeader(sortHeader, "ptValue", ZO_SORT_ORDER_DOWN)
    ZO_SortHeader_SetTooltip(sortHeader, "PT Value", BOTTOMLEFT, 0, 00)

    local inventory = PLAYER_INVENTORY.inventories[inventoryType]
	inventory.sortHeaders:AddHeader(sortHeader)
end


PriceTooltip_SortByValueHeaderNew = function(inventoryType, sortByControl)
	local name = PriceTooltip.SavedVariables.SortNamePTV or ""
	local width = 15 + string.len(name) * 10

    local sortHeader = CreateControlFromVirtual("$(parent)PTV", sortByControl, "ZO_SortHeader")
	sortHeader:SetAnchor(LEFT, nil, RIGHT, -width, 0)
    sortHeader:SetDimensions(width, 20)

    ZO_SortHeader_Initialize(sortHeader, name, "ptValue", ZO_SORT_ORDER_DOWN, TEXT_ALIGN_RIGHT, "ZoFontHeader")
	ZO_SortHeader_SetTooltip(sortHeader, "Sort by PT Value", BOTTOMLEFT, 0, 0)

    local inventory = PLAYER_INVENTORY.inventories[inventoryType]
	inventory.sortHeaders:AddHeader(sortHeader)
end


PriceTooltip_UpdateAllSortByValueHeader = function()
	if (PriceTooltip.SavedVariables.UseGridSort and PriceTooltip.SavedVariables.UseNewSortButton) then
		PriceTooltip_UpdateSortByValueHeader(ZO_PlayerInventorySortByPrice, ZO_PlayerInventorySortByPTV)
		PriceTooltip_UpdateSortByValueHeader(ZO_CraftBagSortByPrice, ZO_CraftBagSortByPTV)
		PriceTooltip_UpdateSortByValueHeader(ZO_PlayerBankSortByPrice, ZO_PlayerBankSortByPTV)
		PriceTooltip_UpdateSortByValueHeader(ZO_GuildBankSortByPrice, ZO_GuildBankSortByPTV)
		PriceTooltip_UpdateSortByValueHeader(ZO_HouseBankSortByPrice, ZO_HouseBankSortByPTV)
	end
end


PriceTooltip_UpdateSortByValueHeader = function(standard_value_sort, pt_value_sort)
	if PriceTooltip.SavedVariables.ReplaceStandardValueSort then
		standard_value_sort:SetAnchor(LEFT, nil, RIGHT, 1000, 0) -- hide (set hide dont work well)
	else
		if PriceTooltip.SavedVariables.EnableMoveStandardValueSort then
			standard_value_sort:SetAnchor(LEFT, nil, RIGHT, PriceTooltip.SavedVariables.StandardValueSortPositionX, 0)
		else
			standard_value_sort:SetAnchor(LEFT, nil, RIGHT, -100, 0) -- show (set hide dont work well)
		end
	end

	pt_value_sort:SetAnchor(LEFT, nil, RIGHT, PriceTooltip.SavedVariables.PTValueSortPositionX, 0)
end


PriceTooltip_Extensions = function()
	PriceTooltip_InitTooltips()
	PriceTooltip_GridPriceExtension()
	PriceTooltip_LinkHandlerExtension()
	ZO_PreHook("ZO_InventorySlot_ShowContextMenu", function(inventorySlot) zo_callLater(function() PriceTooltip_ShowContextMenuExtension(inventorySlot) end, 50) end)
	PriceTooltip_GamePadActions()
end


PriceTooltip_GamePadActions = function()
	local menu = LibCustomMenu
	if menu then
		menu:RegisterKeyStripEnter(function(inventorySlot, slotActions)
			if (IsInGamepadPreferredMode()) then
				local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
				if not (bagId and slotIndex) then return end
				
				local itemLink = GetItemLink(bagId, slotIndex)
				if not itemLink then return end
				
				local linkType = GetLinkType(link)
				if linkType == LINK_TYPE_ACHIEVEMENT then return end

				if PriceTooltip.SavedVariables.UsePriceTooltipMenuGamepad then
					local link = itemLink
					local count = 1

					local stringColor = PriceTooltip_GetStringColorFromColor(PriceTooltip.SavedVariables.ContextMenuColor)

					local prices = PriceTooltip_GetPrices(link)
					if prices then
						if PriceTooltip_ValidPrice(prices.originalTTCPrice) then
							ZO_CreateStringId("SI_BINDING_NAME_PRICE_TOOLTIP_TTC_PRICE", stringColor .. PRICE_TOOLTIP_TTC_PRICE .. " to chat -> " .. PriceTooltip_NumberFormat(prices.originalTTCPrice) .. PRICE_TOOLTIP_GAMEPAD_GOLD_TEXT_ICON)
							slotActions:AddCustomSlotAction(SI_BINDING_NAME_PRICE_TOOLTIP_TTC_PRICE, function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_TTC_PRICE, prices.originalTTCPrice) end)
							count = count + 1
						end

						if PriceTooltip_ValidPrice(prices.originalMMPrice) then
							ZO_CreateStringId("SI_BINDING_NAME_PRICE_TOOLTIP_MM_PRICE", stringColor .. PRICE_TOOLTIP_MM_PRICE .. " to chat -> " .. PriceTooltip_NumberFormat(prices.originalMMPrice) .. PRICE_TOOLTIP_GAMEPAD_GOLD_TEXT_ICON)
							slotActions:AddCustomSlotAction(SI_BINDING_NAME_PRICE_TOOLTIP_MM_PRICE, function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_MM_PRICE, prices.originalMMPrice) end)
							count = count + 1
						end

						if PriceTooltip_ValidPrice(prices.originalATTPrice) then
							ZO_CreateStringId("SI_BINDING_NAME_PRICE_TOOLTIP_ATT_PRICE", stringColor .. PRICE_TOOLTIP_ATT_PRICE .. " to chat -> " .. PriceTooltip_NumberFormat(prices.originalATTPrice) .. PRICE_TOOLTIP_GAMEPAD_GOLD_TEXT_ICON)
							slotActions:AddCustomSlotAction(SI_BINDING_NAME_PRICE_TOOLTIP_ATT_PRICE, function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_ATT_PRICE, prices.originalATTPrice) end)
							count = count + 1
						end

						if PriceTooltip_ValidPrice(prices.originalUESPPrice) then
							ZO_CreateStringId("SI_BINDING_NAME_PRICE_TOOLTIP_UESP_PRICE", stringColor .. PRICE_TOOLTIP_UESP_PRICE .. " to chat -> " .. PriceTooltip_NumberFormat(prices.originalUESPPrice) .. PRICE_TOOLTIP_GAMEPAD_GOLD_TEXT_ICON)
							slotActions:AddCustomSlotAction(SI_BINDING_NAME_PRICE_TOOLTIP_UESP_PRICE, function(...) PriceTooltip_PriceToChat(link, PRICE_TOOLTIP_UESP_PRICE, prices.originalUESPPrice) end)
							count = count + 1
						end

						if PriceTooltip_ValidPrice(prices.originalAveragePrice) then
							ZO_CreateStringId("SI_BINDING_NAME_PRICE_TOOLTIP_AVG_PRICE", stringColor .. "AVG price to chat -> " .. PriceTooltip_NumberFormat(prices.originalAveragePrice) .. PRICE_TOOLTIP_GAMEPAD_GOLD_TEXT_ICON)
							slotActions:AddCustomSlotAction(SI_BINDING_NAME_PRICE_TOOLTIP_AVG_PRICE, function(...) PriceTooltip_PriceToChat(link, "AVG price", prices.originalAveragePrice) end)
							count = count + 1
						end
					end

					if (count == 1) then
						ZO_CreateStringId("SI_BINDING_NAME_PRICE_TOOLTIP_NO_PRICE", stringColor .. "Price to chat -> No data")
						slotActions:AddCustomSlotAction(SI_BINDING_NAME_PRICE_TOOLTIP_NO_PRICE, function(...) PriceTooltip_PriceToChat(link, nil, nil) end)
					end
				end

				if PriceTooltipNote then
					local stringColor = PriceTooltipNote_GetStringColorFromColor(PriceTooltipNote.SavedVariables.ContextMenuColor)

					ZO_CreateStringId("SI_BINDING_NAME_PRICE_TOOLTIP_EDIT_NOTE", stringColor .. "Edit NOTE")
					ZO_CreateStringId("SI_BINDING_NAME_PRICE_TOOLTIP_DELETE_NOTE", stringColor .. "Delete NOTE")

					slotActions:AddCustomSlotAction(SI_BINDING_NAME_PRICE_TOOLTIP_EDIT_NOTE, function(...) PriceTooltipNote_NoteToChat_Edit(itemLink) end)
					slotActions:AddCustomSlotAction(SI_BINDING_NAME_PRICE_TOOLTIP_DELETE_NOTE, function(...) PriceTooltipNote_NoteToChat_Delete(itemLink) end)
				end
			end
		end, menu.CATEGORY_PRIMARY)
	end
end


PriceTooltip_InitTooltips = function ()
	PriceTooltip_InitGamepadTooltips()

	PriceTooltip_ToolTipExtension(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetBagItem", GetItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetLootItem", GetLootItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetTradeItem", GetTradeItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetStoreItem", GetStoreItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetWornItem", PriceTooltip_GetWornItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)
	PriceTooltip_ToolTipExtension(ItemTooltip, "SetLink", PriceTooltip_GetItemLinkFirstParam)
	PriceTooltip_ToolTipExtension(PopupTooltip, "SetLink", PriceTooltip_GetItemLinkFirstParam)
	
	--[[SetPendingSmithingItem(*luaindex* _patternIndex_, *luaindex* _materialIndex_, *integer* _materialQuantity_, *integer* _itemStyleId_, *luaindex* _traitIndex_)
		GetSmithingPatternResultLink(*luaindex* _patternIndex_, *luaindex* _materialIndex_, *integer* _materialQuantity_, *integer* _itemStyleId_, *luaindex* _traitIndex_,
			*[LinkStyle|#LinkStyle]* _linkStyle_)
		_Returns:_ *string* _link_]]--
	PriceTooltip_ToolTipExtension(ZO_SmithingTopLevelCreationPanelResultTooltip, "SetPendingSmithingItem", GetSmithingPatternResultLink)

	--[[SetProvisionerResultItem(*luaindex* _recipeListIndex_, *luaindex* _recipeIndex_)
		GetRecipeResultItemLink(*luaindex* _recipeListIndex_, *luaindex* _recipeIndex_, *[LinkStyle|#LinkStyle]* _linkStyle_)
		_Returns:_ *string* _link_ ]]--
	PriceTooltip_ToolTipExtension(ZO_ProvisionerTopLevelTooltip, "SetProvisionerResultItem", GetRecipeResultItemLink)
end


PriceTooltip_InitGamepadTooltips = function()
	PriceTooltip_GamePadToolTipExtension(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutBagItem")
	PriceTooltip_GamePadToolTipExtension2(GAMEPAD_INVENTORY, "UpdateCategoryLeftTooltip")
    PriceTooltip_GamePadToolTipExtension(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutBagItem")
    PriceTooltip_GamePadToolTipExtension(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutBagItem")
	
	PriceTooltip_PostHook(ZO_MailInbox_Gamepad, 'InitializeKeybindDescriptors',
	function(self)
		self.mainKeybindDescriptor[3]["callback"] = function() self:Delete() end
	end)
end


PriceTooltip_PostHook = function(control, method, fn)
	if control then
		local originalMethod = control[method]
		control[method] = function(self, ...)
			originalMethod(self, ...)
			fn(self, ...)
		end
	end
end


-- FROM uespLog -> function uespLog.FindSalesPrice(itemLink)
PriceTooltip_uespLog_FindSalesPrice = function(itemLink)
	if (itemLink == nil) then
		return nil
	end
	
	local linkData = PriceTooltip_uespLog_ParseItemLinkEx(itemLink)
	
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
		level = 50 + math.floor(reqCP/10)
	end
	
	linkData.potionData = tonumber(linkData.potionData)
	
	if (linkData.potionData == nil) then
		linkData.potionData = 0
	end
	
	if (linkData.writ1 > 0) then
		linkData.potionData = linkData.writ1 .. ":" .. linkData.writ2 .. ":" .. linkData.writ3 .. ":" .. linkData.writ4 .. ":" .. linkData.writ5 .. ":" .. linkData.writ6
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
function PriceTooltip_uespLog_ParseItemLinkEx(link)
	--|H1:item:Id:SubType:InternalLevel:EnchantId:EnchantSubType:EnchantLevel:Writ1:Writ2:Writ3:Writ4:Writ5:Writ6:0:0:0:Style:Crafted:Bound:Stolen::Charges:PotionEffect/WritReward|hName|h
	local linkData = {}
	
	if (link == nil) then
		return false
	end
	
	linkData.linkType, linkData.itemText, linkData.itemId, linkData.internalSubType, linkData.internalLevel, linkData.enchantId, linkData.enchantSubtype, linkData.enchantLevel, linkData.writ1, linkData.writ2, linkData.writ3, linkData.writ4, linkData.writ5, linkData.writ6, linkData.zero1, linkData.zero2, linkData.zero3, linkData.style, linkData.crafted, linkData.bound, linkData.stolen, linkData.charges, linkData.potionData, linkData.itemName = link:match("|H(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h(.-)|h")	
	
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


EVENT_MANAGER:RegisterForEvent("PriceTooltip_Load", EVENT_ADD_ON_LOADED, PriceTooltip_Load)