-- ---------------------------------------------------------------------------------------------------
-- Code based on Addon "PriceTooltip" by @Mladen90
-- ---------------------------------------------------------------------------------------------------

-- Create namespace
DsRGuildPrice = {}
local DsRGuildPrice = DsRGuildPrice or {}

DsRGuildPrice.name    = "DsR GuildRoster - Price"
DsRGuildPrice.version = DsRVersion.version

DsRGuildPrice_IsLoaded  = false
DsRGuildPrice_Kontext   = false

local DsRGuildPrice_ATT_Sales   = nil
local DsRGuildPrice_LastDivider = nil

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice.GetPrices(itemLink)

	local prices =
	{
		vendorPrice = nil,
		profitPrice = nil,

		-- TTC
		originalTTCPrice 	  = nil,
		originalTTCPriceIsAvg = false,
		scaledTTCPrice 		  = nil,
		infoTTC1 			  = nil,
		infoTTC2 			  = nil,
		infoTTC3 			  = nil,

		-- MM
		originalMMPrice = nil,
		scaledMMPrice   = nil,
		infoMM 			= nil,

		-- ATT
		originalATTPrice = nil,
		scaledATTPrice 	 = nil,
		infoATT 		 = nil,

		originalAveragePrice = nil,
		scaledAveragePrice 	 = nil,
		bestPrice 			 = nil,
		bestPriceText 		 = nil,

		isBound = false
	}

	if not itemLink then return nil end

	prices.isBound = IsItemLinkBound(itemLink)
	
	local icon, meetsUsageRequirement
	icon, prices.vendorPrice, meetsUsageRequirement = GetItemLinkInfo(itemLink)

	if not DsRGuildPrice_ValidPrice(prices.vendorPrice) then prices.vendorPrice = 0 end
	
	if DsRGuildPrice.SavedVariables.UseProfitPrice then
		prices.profitPrice = prices.vendorPrice * (1 + DsRGuildPrice.SavedVariables.ScaleProfitPrice / 100)
		if not DsRGuildPrice_ValidPrice(prices.profitPrice) then prices.profitPrice = 1 end
	end

	-- TTC
	if DsRGuildPrice.SavedVariables.UseTTCPrice then
		if TamrielTradeCentrePrice then
			local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
			if priceInfo then
				prices.originalTTCPrice = priceInfo.SuggestedPrice

				if priceInfo.SuggestedPrice then
					prices.infoTTC1 = string.format("TTC " .. GetString(TTC_PRICE_SUGGESTEDXTOY), TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice, 0), TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice * 1.25, 0))
				end

				prices.infoTTC2 = string.format(GetString(TTC_PRICE_AGGREGATEPRICESXYZ), TamrielTradeCentre:FormatNumber(priceInfo.Avg), TamrielTradeCentre:FormatNumber(priceInfo.Min), TamrielTradeCentre:FormatNumber(priceInfo.Max));

				if (DsRGuildPrice.SavedVariables.IncludeAvgTTCPrice and not DsRGuildPrice_ValidPrice(prices.originalTTCPrice)) then
					prices.originalTTCPrice = priceInfo.Avg
					prices.originalTTCPriceIsAvg = true
				end

				if (DsRGuildPrice.SavedVariables.DisplayTTCPriceInfo) then
					if priceInfo.EntryCount ~= priceInfo.AmountCount then
						prices.infoTTC3 = string.format(GetString(TTC_PRICE_XLISTINGSYITEMS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount), TamrielTradeCentre:FormatNumber(priceInfo.AmountCount))
					else
						prices.infoTTC3 = string.format(GetString(TTC_PRICE_XLISTINGS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount))
					end
				end
			end
			
			if DsRGuildPrice_ValidPrice(prices.originalTTCPrice) then
				if (prices.originalTTCPriceIsAvg) then prices.scaledTTCPrice = prices.originalTTCPrice * (1 + DsRGuildPrice.SavedVariables.ScaleAvgTTCPrice / 100)
				else prices.scaledTTCPrice = prices.originalTTCPrice * (1 + DsRGuildPrice.SavedVariables.ScaleTTCPrice / 100) end
			end
		end
	end

	-- MM
	if DsRGuildPrice.SavedVariables.UseMMPrice then
		if MasterMerchant then
			local itemInfo = MasterMerchant:itemStats(itemLink, false)
			prices.originalMMPrice = itemInfo.avgPrice

			if (DsRGuildPrice.SavedVariables.DisplayMMPriceInfo) then
				local tipLine, avgPrice, graphInfo = MasterMerchant:itemPriceTip(itemLink, false, clickable)
				if tipLine then prices.infoMM = zo_strformat("<<1>> ", tipLine) end
			end
			
			if DsRGuildPrice_ValidPrice(prices.originalMMPrice) then
				prices.scaledMMPrice = prices.originalMMPrice * (1 + DsRGuildPrice.SavedVariables.ScaleMMPrice / 100)
			end
		end
	end

	-- ATT
	if DsRGuildPrice.SavedVariables.UseATTPrice then
		if DsRGuildPrice_ATT_Sales then
			local fromTimeStamp = GetTimeStamp() - DsRGuildPrice.SavedVariables.ATTDays * 60 * 60 * 24

			prices.originalATTPrice = DsRGuildPrice_ATT_Sales:GetAveragePricePerItem(itemLink, fromTimeStamp)
			if DsRGuildPrice_ValidPrice(prices.originalATTPrice) then
				prices.scaledATTPrice = prices.originalATTPrice * (1 + DsRGuildPrice.SavedVariables.ScaleATTPrice / 100)
			end

			if (DsRGuildPrice.SavedVariables.DisplayATTPriceInfo) then
				prices.infoATT = DsRGuildPrice_GetAttInfo(itemLink, fromTimeStamp)
			end
		end
	end

	if DsRGuildPrice.SavedVariables.UseAveragePrice then
		prices.scaledAveragePrice = 0
		prices.originalAveragePrice = 0
		local count = 0

		if DsRGuildPrice.SavedVariables.IncludeTTCInAP and DsRGuildPrice_ValidPrice(prices.scaledTTCPrice) then
			if (prices.originalTTCPriceIsAvg) then
				if (DsRGuildPrice.SavedVariables.IncludeTTCAvgInAP) then
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

		if DsRGuildPrice.SavedVariables.IncludeMMInAP and DsRGuildPrice_ValidPrice(prices.scaledMMPrice) then
			prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledMMPrice
			prices.originalAveragePrice = prices.originalAveragePrice + prices.originalMMPrice
			count = count + 1
		end

		if DsRGuildPrice.SavedVariables.IncludeATTInAP and DsRGuildPrice_ValidPrice(prices.scaledATTPrice) then
			prices.scaledAveragePrice = prices.scaledAveragePrice + prices.scaledATTPrice
			prices.originalAveragePrice = prices.originalAveragePrice + prices.originalATTPrice
			count = count + 1
		end

		if count > 0 then
			prices.originalAveragePrice = prices.originalAveragePrice / count
			prices.scaledAveragePrice   = prices.scaledAveragePrice / count
		end
	end
	
	if DsRGuildPrice.SavedVariables.UseBestPrice then
		prices.bestPrice = 0

		if DsRGuildPrice.SavedVariables.UseTTCPrice and DsRGuildPrice_ValidPrice(prices.scaledTTCPrice) and prices.scaledTTCPrice > prices.bestPrice then
			if (DsRGuildPrice.SavedVariables.IncludeTTCAvgInBP or (not prices.originalTTCPriceIsAvg)) then
				prices.bestPrice = prices.scaledTTCPrice
				prices.bestPriceText = PRICE_TOOLTIP_TTC_PRICE
			end
		end

		if DsRGuildPrice.SavedVariables.UseMMPrice and DsRGuildPrice_ValidPrice(prices.scaledMMPrice) and prices.scaledMMPrice > prices.bestPrice then
			prices.bestPrice = prices.scaledMMPrice
			prices.bestPriceText = PRICE_TOOLTIP_MM_PRICE
		end

		if DsRGuildPrice.SavedVariables.UseATTPrice and DsRGuildPrice_ValidPrice(prices.scaledATTPrice) and prices.scaledATTPrice > prices.bestPrice then
			prices.bestPrice = prices.scaledATTPrice
			prices.bestPriceText = PRICE_TOOLTIP_ATT_PRICE
		end

		if DsRGuildPrice.SavedVariables.IncludePPInBP and DsRGuildPrice.SavedVariables.UseProfitPrice and DsRGuildPrice_ValidPrice(prices.profitPrice) and prices.profitPrice > prices.bestPrice then
			prices.bestPrice = prices.profitPrice
			prices.bestPriceText = PRICE_TOOLTIP_PROFIT_PRICE
		end

		if not DsRGuildPrice_ValidPrice(prices.bestPrice) then
			prices.bestPrice = nil
			prices.bestPriceText = nil
		end

		if not DsRGuildPrice.SavedVariables.DisplaySourceInBP then
			prices.bestPriceText = nil
		end
	end

	prices.profitPrice 			= DsRGuildPrice_Round(prices.profitPrice, 2)
	prices.originalTTCPrice 	= DsRGuildPrice_Round(prices.originalTTCPrice, 2)
	prices.scaledTTCPrice 		= DsRGuildPrice_Round(prices.scaledTTCPrice, 2)
	prices.originalMMPrice 		= DsRGuildPrice_Round(prices.originalMMPrice, 2)
	prices.scaledMMPrice 		= DsRGuildPrice_Round(prices.scaledMMPrice, 2)
	prices.originalATTPrice 	= DsRGuildPrice_Round(prices.originalATTPrice, 2)
	prices.scaledATTPrice 		= DsRGuildPrice_Round(prices.scaledATTPrice, 2)
	prices.originalAveragePrice = DsRGuildPrice_Round(prices.originalAveragePrice, 2)
	prices.scaledAveragePrice 	= DsRGuildPrice_Round(prices.scaledAveragePrice, 2)
	prices.bestPrice 			= DsRGuildPrice_Round(prices.bestPrice, 2)

	return prices
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_ValidPrice(price)
	return (price or 0) > 0
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_Round(num, numDecimalPlaces)
	if not num then return num end

	local decimalPlaces = numDecimalPlaces or 0

	if DsRGuildPrice.SavedVariables.RoundPrice then decimalPlaces = 0 end

	local mult = 10 ^ decimalPlaces
	return math.floor(num * mult + 0.5) / mult
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_NumberFormat(amount)
	local formatted = amount

	local separator = DsRGuildPrice.SavedVariables.Separator
	if separator == PRICE_TOOLTIP_EMPTY then return formatted end
	if separator == PRICE_TOOLTIP_SPACE then separator = " " end

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1" .. separator .. "%2")
		if (k==0) then break end
	end

	return formatted
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_GetAttInfo(itemLink, fromTimeStamp)
	itemLink = DsRGuildPrice_ATT_Sales:NormalizeItemLink(itemLink)
    if itemLink == nil then return nil end

    local itemSales   = DsRGuildPrice_ATT_Sales:GetItemSalesInformation(itemLink, fromTimeStamp, true)
    local itemType    = GetItemLinkItemType(itemLink)
	local statsString = nil
	
    for link, sales in pairs(itemSales) do
        local quantity = 0

        for _, sale in pairs(sales) do
            quantity = quantity + sale.quantity
        end

        if (link == itemLink) then
            if (quantity > 0) then
                if (itemType == ITEMTYPE_MASTER_WRIT) then
                    statsString = string.format("%s %s, %s %s", ArkadiusTradeTools:LocalizeDezimalNumber(#sales), GetString(DsRGuildPrice_Sale), ArkadiusTradeTools:LocalizeDezimalNumber(quantity), GetString(DsRGuildPrice_WritVouchers))
                else
                    statsString = string.format("%s %s, %s %s", ArkadiusTradeTools:LocalizeDezimalNumber(#sales), GetString(DsRGuildPrice_Sale), ArkadiusTradeTools:LocalizeDezimalNumber(quantity), GetString(DsRGuildPrice_items))
                end
            end
        end
    end

	return statsString
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_AddDivider(tooltipControl)
    if not tooltipControl.dividerPool then 
        tooltipControl.dividerPool = ZO_ControlPool:New("ZO_BaseTooltipDivider", tooltipControl, "Divider")
    end
	
	return tooltipControl.dividerPool:AcquireObject() 
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_NoDisplayPrices(prices)
	return prices == nil or (not (DsRGuildPrice_ValidPrice(prices.vendorPrice) and DsRGuildPrice.SavedVariables.DisplayVendorPrice) and
							 not (DsRGuildPrice_ValidPrice(prices.profitPrice) and DsRGuildPrice.SavedVariables.DisplayProfitPrice) and
							 not (DsRGuildPrice_ValidPrice(prices.originalTTCPrice) and DsRGuildPrice.SavedVariables.DisplayTTCPrice) and
							 not ((prices.infoTTC1 or prices.infoTTC2 or prices.infoTTC3) and DsRGuildPrice.SavedVariables.DisplayTTCPriceInfo) and
							 not (DsRGuildPrice_ValidPrice(prices.originalMMPrice) and DsRGuildPrice.SavedVariables.DisplayMMPrice) and
							 not (prices.infoMM and DsRGuildPrice.SavedVariables.DisplayMMPriceInfo) and
							 not (DsRGuildPrice_ValidPrice(prices.originalATTPrice) and DsRGuildPrice.SavedVariables.DisplayATTPrice) and
							 not (prices.infoATT and DsRGuildPrice.SavedVariables.DisplayATTPriceInfo) and
							 not (DsRGuildPrice_ValidPrice(prices.originalAveragePrice) and DsRGuildPrice.SavedVariables.DisplayAveragePrice) and
							 not (DsRGuildPrice_ValidPrice(prices.bestPrice) and DsRGuildPrice.SavedVariables.DisplayBestPrice))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_AddTooltip(control, itemLink)
	if (not control) then return end
	
	local addedLine = 0

	local prices = DsRGuildPrice.GetPrices(itemLink)
	
	if not DsRGuildPrice_NoDisplayPrices(prices) then
		local stringPTIColor = DsRGuildPrice_GetStringColorFromColor(DsRGuildPrice.SavedVariables.TooltipPriceInfoColor)
	
		if DsRGuildPrice.SavedVariables.DisplayVendorPrice and DsRGuildPrice_ValidPrice(prices.vendorPrice) then
			local itemType = GetItemLinkItemType(itemLink)
	
			if (DsRGuildPrice_ItemTypes[itemType]) then
				if (not (itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE )) then control:AddLine() end
			
				control:AddLine()
				control:AddLine(DsRGuildPrice_NumberFormat(prices.vendorPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON, "ZoFontWinH4")
			end
		end
	end

	local divider = nil

	divider = DsRGuildPrice_AddDivider(control)

	if (divider) then
		if (DsRGuildPrice.SavedVariables.FixDoubleTooltip) then
			if (DsRGuildPrice_LastDivider and DsRGuildPrice_LastDivider.DsRGuildPriceLink == itemLink and DsRGuildPrice_LastDivider:GetName() ~= divider:GetName()) then
				divider:SetHidden(true)
				return
			else
				if (DsRGuildPrice_LastDivider) then DsRGuildPrice_LastDivider.DsRGuildPriceLink = nil end
				divider.DsRGuildPriceLink = itemLink
				DsRGuildPrice_LastDivider = divider
			end
		else
			if (DsRGuildPrice_LastDivider) then DsRGuildPrice_LastDivider.DsRGuildPriceLink = nil end
			divider.DsRGuildPriceLink = nil
			DsRGuildPrice_LastDivider = nil
		end
		control:AddControl(divider)
		divider:SetAnchor(CENTER)
		divider:SetHidden(false)
	end

	if not DsRGuildPrice_NoDisplayPrices(prices) then
		local stringPTIColor = DsRGuildPrice_GetStringColorFromColor(DsRGuildPrice.SavedVariables.TooltipPriceInfoColor)

		if DsRGuildPrice.SavedVariables.DisplayProfitPrice then
			addedLine = addedLine + DsRGuildPrice_AddPTLine(control, PRICE_TOOLTIP_PROFIT_PRICE, prices.profitPrice, prices.vendorPrice, prices.profitPrice, nil, nil, prices.isBound)
		end

		-- TTC
		if DsRGuildPrice.SavedVariables.DisplayTTCPrice then
			if (prices.originalTTCPriceIsAvg) then
				addedLine = addedLine + DsRGuildPrice_AddPTLine(control, PRICE_TOOLTIP_TTC_PRICE, prices.scaledTTCPrice, prices.vendorPrice, prices.profitPrice, nil, DsRGuildPrice.SavedVariables.AvgTTCPriceColor, prices.isBound)
			else
				addedLine = addedLine + DsRGuildPrice_AddPTLine(control, PRICE_TOOLTIP_TTC_PRICE, prices.scaledTTCPrice, prices.vendorPrice, prices.profitPrice, nil, nil, prices.isBound)
			end
		end
	
		if DsRGuildPrice.SavedVariables.DisplayTTCPriceInfo then
			if prices.infoTTC1 then addedLine = addedLine + DsRGuildPrice_AddTooltipLine(control, stringPTIColor .. prices.infoTTC1, true) end
			if prices.infoTTC2 then addedLine = addedLine + DsRGuildPrice_AddTooltipLine(control, stringPTIColor .. prices.infoTTC2, true) end
			if (prices.infoTTC2 and prices.infoTTC3 ~= prices.infoTTC2) or prices.infoTTC3 then
				addedLine = addedLine + DsRGuildPrice_AddTooltipLine(control, stringPTIColor .. prices.infoTTC3, true)
			end
		end

		-- MM
		if DsRGuildPrice.SavedVariables.DisplayMMPrice then
			addedLine = addedLine + DsRGuildPrice_AddPTLine(control, PRICE_TOOLTIP_MM_PRICE, prices.scaledMMPrice, prices.vendorPrice, prices.profitPrice, nil, nil, prices.isBound)
		end

		if DsRGuildPrice.SavedVariables.DisplayMMPriceInfo and prices.infoMM then
			addedLine = addedLine + DsRGuildPrice_AddTooltipLine(control, stringPTIColor .. prices.infoMM, true)
		end

		-- ATT
		if DsRGuildPrice.SavedVariables.DisplayATTPrice then
			addedLine = addedLine + DsRGuildPrice_AddPTLine(control, PRICE_TOOLTIP_ATT_PRICE, prices.scaledATTPrice, prices.vendorPrice, prices.profitPrice, nil, nil, prices.isBound)
		end

		if DsRGuildPrice.SavedVariables.DisplayATTPriceInfo and prices.infoATT then
			addedLine = addedLine + DsRGuildPrice_AddTooltipLine(control, stringPTIColor .. prices.infoATT, true)
		end

		if DsRGuildPrice.SavedVariables.DisplayAveragePrice then
			if (prices.originalTTCPriceIsAvg) then
				addedLine = addedLine + DsRGuildPrice_AddPTLine(control, PRICE_TOOLTIP_TRADE_PRICE, prices.scaledAveragePrice, prices.vendorPrice, prices.profitPrice, nil, 
					DsRGuildPrice.SavedVariables.AvgTTCPriceColor, prices.isBound)
			else
				addedLine = addedLine + DsRGuildPrice_AddPTLine(control, PRICE_TOOLTIP_TRADE_PRICE, prices.scaledAveragePrice, prices.vendorPrice, prices.profitPrice, nil, nil, prices.isBound)
			end
		end

		if DsRGuildPrice.SavedVariables.DisplayBestPrice then
			if (prices.originalTTCPriceIsAvg) then
				addedLine = addedLine + DsRGuildPrice_AddPTLine(control, PRICE_TOOLTIP_BEST_PRICE, prices.bestPrice, prices.vendorPrice, prices.profitPrice, prices.bestPriceText,
					DsRGuildPrice.SavedVariables.AvgTTCPriceColor,prices.isBound)
			else
				addedLine =
					addedLine + DsRGuildPrice_AddPTLine(control, PRICE_TOOLTIP_BEST_PRICE, prices.bestPrice, prices.vendorPrice, prices.profitPrice, prices.bestPriceText, nil, prices.isBound)
			end
		end
	end
	
	if not DsRGuildPrice_NoDisplayPrices(prices) then
		local stringErrorColor = DsRGuildPrice_GetStringColor(1, 0, 0)

		if DsRGuildPrice.SavedVariables.UseTTCPrice and not TamrielTradeCentrePrice then addedLine = addedLine + DsRGuildPrice_AddTooltipLine(control, stringErrorColor .. GetString(DsRGuildPrice_TTCnotavailable)) end
		if DsRGuildPrice.SavedVariables.UseMMPrice and not MasterMerchant then addedLine = addedLine + DsRGuildPrice_AddTooltipLine(control, stringErrorColor .. GetString(DsRGuildPrice_MMnotavailable)) end
		if DsRGuildPrice.SavedVariables.UseATTPrice and not DsRGuildPrice_ATT_Sales then addedLine = addedLine + DsRGuildPrice_AddTooltipLine(control, stringErrorColor .. GetString(DsRGuildPrice_ATTnotavailable)) end
	end

	if divider then divider:SetHidden(addedLine < 1) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_GetBoundPriceIndicator(is_bound)
	if is_bound and DsRGuildPrice.SavedVariables.MarkBoundItems then
		return DsRGuildPrice_GetStringColorFromColor(DsRGuildPrice.SavedVariables.BoundItemMarkColor) .. "*"
	else
		return ""
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_GetLowPriceIndicator(price, vendorPrice, profitPrice)
	local lowPriceIndikator = ""

	if DsRGuildPrice_ValidPrice(price) then
		if price <= vendorPrice then lowPriceIndikator = DsRGuildPrice_GetStringColorFromColor(DsRGuildPrice.SavedVariables.VendorPriceLowPriceIndicatorColor) .. "*"
		elseif DsRGuildPrice.SavedVariables.UseProfitPrice and price < profitPrice then lowPriceIndikator = DsRGuildPrice_GetStringColorFromColor(DsRGuildPrice.SavedVariables.ProfitPriceLowPriceIndicatorColor) .. "*" end
	end

	return lowPriceIndikator
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_AddPTLine(control, text, price, vendorPrice, profitPrice, info, priceColor, isBound)
	if DsRGuildPrice_ValidPrice(price) then
		if info then info = " (" .. info .. ")" end

		local indicator = ""
		if DsRGuildPrice.SavedVariables.LowPriceIndicatorTooltip then
			indicator = DsRGuildPrice_GetLowPriceIndicator(price, vendorPrice, profitPrice)
		end
		indicator = indicator .. DsRGuildPrice_GetBoundPriceIndicator(isBound)

		local stringColorText = DsRGuildPrice_GetStringColorFromColor(DsRGuildPrice.SavedVariables.TooltipColor)
		local stringColorPrice = stringColorText

		if priceColor then stringColorPrice = DsRGuildPrice_GetStringColorFromColor(priceColor) end
		
		DsRGuildPrice_AddTooltipLine(control, stringColorText .. text .. " " .. indicator .. stringColorPrice .. DsRGuildPrice_NumberFormat(price) .. PRICE_TOOLTIP_GOLD_TEXT_ICON
			.. stringColorText .. (info or ""))

		return 1
	end

	return 0
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_AddTooltipLine(control, text, isPTI)
	control:AddVerticalPadding(DsRGuildPrice.SavedVariables.TooltipLineSpacing)

	if isPTI then
		control:AddLine(text, DsRGuildPrice.SavedVariables.PriceInfoFont, 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, LEFT, false)
	else
		control:AddLine(text, DsRGuildPrice.SavedVariables.Font, 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, LEFT, false)
	end

	return 1
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_ToolTipExtension(toolTipControl, functionName, getItemLinkFunction)
	local base = toolTipControl[functionName]
	
	toolTipControl[functionName] = function(control, ...)
		base(control, ...)
		
		if not getItemLinkFunction then return end
		
		local itemLink = getItemLinkFunction(...)
		
		if itemLink and control then
			DsRGuildPrice_AddTooltip(control, itemLink, false)
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_GetWornItemLink(equipSlot)
	return GetItemLink(BAG_WORN, equipSlot)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_GetItemLinkFirstParam(itemLink)
	return itemLink
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_GetStringColorFromColor(color)
	return DsRGuildPrice_GetStringColor(color.Red, color.Green, color.Blue)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_GetChatTextColor(r, g ,b)
	return DsRGuildPrice_GetStringColor(r, g, b)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_GetStringColor(red, green, blue)
	local color = ZO_ColorDef:New(red, green, blue, 1):ToHex()
	return zo_strformat("|c<<1>>", color)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_ChangeGridPrice(control, slot)
	if not DsRGuildPrice.SavedVariables.UseGridItemPriceOverride then return end

	local mainControl = nil
	if control and control.dataEntry and control.dataEntry.data and control.dataEntry.data.bagId and control.dataEntry.data.slotIndex and control.dataEntry.data.stackCount then
		mainControl = control
	elseif slot and slot.dataEntry and slot.dataEntry.data and slot.dataEntry.data.bagId and slot.dataEntry.data.slotIndex and slot.dataEntry.data.stackCount then
		mainControl = slot
	end
	
	if mainControl then
		local bagId 		= mainControl.dataEntry.data.bagId
		local slotIndex 	= mainControl.dataEntry.data.slotIndex
		local stackCount 	= mainControl.dataEntry.data.stackCount
		local itemLink 		= bagId and GetItemLink(bagId, slotIndex) or GetItemLink(slotIndex)

		if not itemLink then return end
		
		local prices = DsRGuildPrice.GetPrices(itemLink)

		if not prices then return end
				
		local sellPriceControl = mainControl:GetNamedChild("SellPrice")
		local sellPriceLabel   = sellPriceControl:GetNamedChild("Text")

		if not sellPriceControl then return end

		local ptControl = sellPriceControl.PTControl

		if (not ptControl) then
			ptControl = WINDOW_MANAGER:CreateControl(nil, sellPriceControl, CT_LABEL)
			ptControl:SetColor(1, 1, 1)
			ptControl:SetFont("ZoFontGameShadow")
			ptControl:SetDrawLayer(0)
			ptControl:SetAnchor(TOPRIGHT, nil, BOTTOMRIGHT, 0, -20)
			ptControl:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )
			ptControl:SetAlpha(1)
			ptControl:SetScale(0.8)
			sellPriceControl.PTControl = ptControl
		end
		sellPriceLabel:SetText("")

		local priceType  = DsRGuildPrice.SavedVariables.GridItemPriceOverrideBehaviour
		local price 	 = DsRGuildPrice_GetPriceByType(prices, priceType)

		local indikator = ""
		if priceType ~= PRICE_TOOLTIP_DEFAULT_PRICE and
		   priceType ~= PRICE_TOOLTIP_PROFIT_PRICE and
		   DsRGuildPrice.SavedVariables.LowPriceIndicatorGrid then
			indikator = DsRGuildPrice_GetLowPriceIndicator(price, prices.vendorPrice, prices.profitPrice)
		end
		indikator = indikator .. DsRGuildPrice_GetBoundPriceIndicator(prices.isBound)

		if not DsRGuildPrice_ValidPrice(price) then
			price = prices.vendorPrice
		elseif prices.isBound and DsRGuildPrice.SavedVariables.BoundItemsAsVendorPrice then
			price = prices.vendorPrice
		end

		local displayPrice = DsRGuildPrice_Round(price)
		local otherPrice   = DsRGuildPrice_Round(price)

		if DsRGuildPrice.SavedVariables.ShowSingleItemPriceInGrid then otherPrice = DsRGuildPrice_Round(price * stackCount)
		else displayPrice = DsRGuildPrice_Round(price * stackCount) end

		if price == prices.vendorPrice then DsRGuildPrice_SetGridPrice(sellPriceControl, indikator, displayPrice, otherPrice)
		else DsRGuildPrice_SetGridPrice(sellPriceControl, indikator, displayPrice, otherPrice) end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_GetPriceByType(prices, priceType)
	local price = nil

	if prices then
		if priceType     == PRICE_TOOLTIP_DEFAULT_PRICE then price = prices.vendorPrice
		elseif priceType == PRICE_TOOLTIP_AVERAGE_PRICE then price = prices.scaledAveragePrice
		elseif priceType == PRICE_TOOLTIP_MM_PRICE 	    then price = prices.scaledMMPrice
		elseif priceType == PRICE_TOOLTIP_TTC_PRICE 	then price = prices.scaledTTCPrice
		elseif priceType == PRICE_TOOLTIP_ATT_PRICE 	then price = prices.scaledATTPrice
		elseif priceType == PRICE_TOOLTIP_BEST_PRICE 	then price = prices.bestPrice
		elseif priceType == PRICE_TOOLTIP_PROFIT_PRICE  then price = prices.profitPrice
		end
	end

	return price
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_SetGridPrice(sellPriceControl, lowPriceIndikator, displayPrice, otherPrice)

	local stringColorOne = "|cffff33"
	local stringColorSum = "|c9fb6cd"

	if DsRGuildPrice.SavedVariables.EnableFirstPriceInGrid and not DsRGuildPrice.SavedVariables.EnableSecondPriceInGrid  then
		sellPriceControl.PTControl:SetText(lowPriceIndikator .. stringColorOne .. DsRGuildPrice_NumberFormat(otherPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON)
		sellPriceControl.PTControl:SetAnchor(TOPRIGHT, nil, BOTTOMRIGHT, 0, -10)
	elseif DsRGuildPrice.SavedVariables.EnableFirstPriceInGrid and DsRGuildPrice.SavedVariables.EnableSecondPriceInGrid then
		if DsRGuildPrice_NumberFormat(otherPrice) == DsRGuildPrice_NumberFormat(displayPrice) then
			sellPriceControl.PTControl:SetText(lowPriceIndikator .. stringColorOne .. DsRGuildPrice_NumberFormat(otherPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON)
			sellPriceControl.PTControl:SetAnchor(TOPRIGHT, nil, BOTTOMRIGHT, 0, -10)
		else
			sellPriceControl.PTControl:SetText(lowPriceIndikator .. stringColorOne .. DsRGuildPrice_NumberFormat(otherPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON .. "|r\n" .. lowPriceIndikator .. stringColorSum .. DsRGuildPrice_NumberFormat(displayPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON)
			sellPriceControl.PTControl:SetAnchor(TOPRIGHT, nil, BOTTOMRIGHT, 0, -20)
		end
	elseif not DsRGuildPrice.SavedVariables.EnableFirstPriceInGrid and DsRGuildPrice.SavedVariables.EnableSecondPriceInGrid then
		sellPriceControl.PTControl:SetText(lowPriceIndikator .. stringColorSum .. DsRGuildPrice_NumberFormat(displayPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON)
		sellPriceControl.PTControl:SetAnchor(TOPRIGHT, nil, BOTTOMRIGHT, 0, -10)
	else
		sellPriceControl.PTControl:SetText("")
		sellPriceControl.PTControl:SetAnchor(TOPRIGHT, nil, BOTTOMRIGHT, 0, -10)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_GridPriceExtension()
	for _,i in pairs(PLAYER_INVENTORY.inventories) do
		local listView = i.listView
		if listView and listView.dataTypes and listView.dataTypes[1] then
			local originalCall = listView.dataTypes[1].setupCallback				
			listView.dataTypes[1].setupCallback = function(control, slot)						
				originalCall(control, slot)
				DsRGuildPrice_ChangeGridPrice(control, slot)
			end
		end
	end

	local originalCall = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1].setupCallback
	ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1].setupCallback = function(control, slot)
		originalCall(control, slot)
		DsRGuildPrice_ChangeGridPrice(control, slot)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_PriceToChat(link, priceText, price, Long, Tool)
	if CHAT_SYSTEM and CHAT_SYSTEM.textEntry and CHAT_SYSTEM.textEntry.editControl then
		local chat = CHAT_SYSTEM.textEntry.editControl
		if not chat:HasFocus() then StartChatInput() end

		if (priceText and price) then
			if Long == false then
				chat:InsertText("[DsR-Price]: " .. priceText .. " -> ".. DsRGuildPrice_NumberFormat(price)  .. GetString(DsRGuildPrice_GoldFor) .. string.gsub(link, '|H0', '|H1'))
			else
				if Tool == "TTC" then
					chat:InsertText("[DsR-Price]: " .. priceText .. " -> ".. DsRGuildPrice_NumberFormat(price.scaledTTCPrice) .. " Gold (".. price.TTC1 .. " ".. price.TTC2 .. " ".. price.TTC3 .. ") ".. GetString(DsRGuildPrice_For) .. string.gsub(link, '|H0', '|H1'))
				elseif Tool == "MM" then
					chat:InsertText("[DsR-Price]: " .. price.infoMM .. " ".. GetString(DsRGuildPrice_For) .. string.gsub(link, '|H0', '|H1'))
				elseif Tool == "ATT" then
					chat:InsertText("[DsR-Price]: " .. priceText .. " -> ".. DsRGuildPrice_NumberFormat(price.originalATTPrice) .. " Gold ".. price.infoATT .. " ".. GetString(DsRGuildPrice_For) .. string.gsub(link, '|H0', '|H1'))
				end
			end
		else
			chat:InsertText("[DsR-Price]: " .. GetString(DsRGuildPrice_NoPriceDataChat) .. string.gsub(link, '|H0', '|H1'))
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_AddCustomMenuItems(link, button)
	if not (link and button == MOUSE_BUTTON_INDEX_RIGHT) then return end

	local linkType = GetLinkType(link)
	if linkType == LINK_TYPE_ACHIEVEMENT then return end

	if DsRGuildPrice.SavedVariables.UsePriceTooltipMenu then
		local count = 1
		local entries = {}

		local prices = DsRGuildPrice.GetPrices(link)
		if prices then
			if DsRGuildPrice_ValidPrice(prices.originalTTCPrice) then
				entries[count] = 
				{
					label = PRICE_TOOLTIP_TTC_PRICE .. DsRGuildPrice_NumberFormat(prices.originalTTCPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
					callback = function(...) DsRGuildPrice_PriceToChat(link, PRICE_TOOLTIP_TTC_PRICE, prices.originalTTCPrice, false, "TTC") end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1				
				entries[count] = 
				{
					label = PRICE_TOOLTIP_TTC_PRICE .. DsRGuildPrice_NumberFormat(prices.originalTTCPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON .. GetString(DsRGuildPrice_detailed),
					callback = function(...) DsRGuildPrice_PriceToChat(link, PRICE_TOOLTIP_TTC_PRICE, { scaledTTCPrice= prices.scaledTTCPrice, TTC1 = prices.infoTTC1, TTC2 = prices.infoTTC2, TTC3 = prices.infoTTC3}, true, "TTC") end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1
			end

			if DsRGuildPrice_ValidPrice(prices.originalMMPrice) then
				entries[count] = 
				{
					label = PRICE_TOOLTIP_MM_PRICE .. DsRGuildPrice_NumberFormat(prices.originalMMPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
					callback = function(...) DsRGuildPrice_PriceToChat(link, PRICE_TOOLTIP_MM_PRICE, prices.originalMMPrice, false, "MM") end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1
				entries[count] = 
				{
					label = PRICE_TOOLTIP_MM_PRICE .. DsRGuildPrice_NumberFormat(prices.originalMMPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON .. GetString(DsRGuildPrice_detailed),
					callback = function(...) DsRGuildPrice_PriceToChat(link, PRICE_TOOLTIP_MM_PRICE, {originalMMPrice = prices.originalMMPrice, infoMM = prices.infoMM}, true, "MM") end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1
			end

			if DsRGuildPrice_ValidPrice(prices.originalATTPrice) then
				entries[count] = 
				{
					label = PRICE_TOOLTIP_ATT_PRICE .. DsRGuildPrice_NumberFormat(prices.originalATTPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
					callback = function(...) DsRGuildPrice_PriceToChat(link, PRICE_TOOLTIP_ATT_PRICE, prices.originalATTPrice, false, "ATT") end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1
				entries[count] = 
				{
					label = PRICE_TOOLTIP_ATT_PRICE .. DsRGuildPrice_NumberFormat(prices.originalATTPrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON .. GetString(DsRGuildPrice_detailed),
					callback = function(...) DsRGuildPrice_PriceToChat(link, PRICE_TOOLTIP_ATT_PRICE, {originalATTPrice = prices.originalATTPrice, infoATT = prices.infoATT}, false, "ATT") end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1
			end

			if DsRGuildPrice_ValidPrice(prices.originalAveragePrice) then
				entries[count] = 
				{
					label = GetString(DsRGuildPrice_AVGPriceToChat) .. DsRGuildPrice_NumberFormat(prices.originalAveragePrice) .. PRICE_TOOLTIP_GOLD_TEXT_ICON,
					callback = function(...) DsRGuildPrice_PriceToChat(link, GetString(DsRGuildPrice_AVGPrice), prices.originalAveragePrice, false) end,
					itemType = MENU_ADD_OPTION_LABEL,
				}
				count = count + 1
			end
		end

		if (count == 1) then
			entries[count] = 
			{
				label    = GetString(DsRGuildPrice_NoPriceData),
				callback = function(...) DsRGuildPrice_PriceToChat(link, nil, nil, false) end,
				itemType = MENU_ADD_OPTION_LABEL,
			}
			count = count + 1
		end

		if count > 1 then
			local stringColor = DsRGuildPrice_GetStringColorFromColor(DsRGuildPrice.SavedVariables.ContextMenuColor)
			AddCustomSubMenuItem(stringColor .. "[DsR-Price]", entries)
		end
	end

	ShowMenu()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_LinkHandlerExtension()
	local base = ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp = function(link, button, control)
		base(link, button, control)
		DsRGuildPrice_AddCustomMenuItems(link, button)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_ShowContextMenuExtension(inventorySlot)
	local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
	if not (bagId and slotIndex) then return end

	local itemLink = GetItemLink(bagId, slotIndex)
	if not itemLink then return end

	DsRGuildPrice_AddCustomMenuItems(itemLink, MOUSE_BUTTON_INDEX_RIGHT)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_InitTooltips()
	DsRGuildPrice_ToolTipExtension(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
	DsRGuildPrice_ToolTipExtension(ItemTooltip, "SetBagItem", GetItemLink)
	DsRGuildPrice_ToolTipExtension(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
	DsRGuildPrice_ToolTipExtension(ItemTooltip, "SetLootItem", GetLootItemLink)
	DsRGuildPrice_ToolTipExtension(ItemTooltip, "SetTradeItem", GetTradeItemLink)
	DsRGuildPrice_ToolTipExtension(ItemTooltip, "SetStoreItem", GetStoreItemLink)
	DsRGuildPrice_ToolTipExtension(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
	DsRGuildPrice_ToolTipExtension(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
	DsRGuildPrice_ToolTipExtension(ItemTooltip, "SetWornItem", DsRGuildPrice_GetWornItemLink)
	DsRGuildPrice_ToolTipExtension(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)
	DsRGuildPrice_ToolTipExtension(ItemTooltip, "SetLink", DsRGuildPrice_GetItemLinkFirstParam)
	DsRGuildPrice_ToolTipExtension(PopupTooltip, "SetLink", DsRGuildPrice_GetItemLinkFirstParam)
	
	DsRGuildPrice_ToolTipExtension(ZO_SmithingTopLevelCreationPanelResultTooltip, "SetPendingSmithingItem", GetSmithingPatternResultLink)
	DsRGuildPrice_ToolTipExtension(ZO_ProvisionerTopLevelTooltip, "SetProvisionerResultItem", GetRecipeResultItemLink)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_LoadLater()
	if DsRGuildPrice_IsLoaded == true then return end

	CHAT_SYSTEM:Maximize()
	
	if MasterMerchant then
		if not DsRGuildPrice_Is_MM_Ready() then
			zo_callLater(function() DsRGuildPrice_LoadLater() end, 1000)
			return
		else
			DsRGuildPrice_Extensions()
			d("|c9fb6cd[DsR-Price]|r |c00ff00" .. GetString(DsRGuildPrice_Loaded) .. "|r")
			DsRGuildPrice_IsLoaded = true
		end
	else
		DsRGuildPrice_Extensions()
		DsRGuildPrice_IsLoaded = true
		zo_callLater(function() d("|c9fb6cd[DsR-Price]|r |c00ff00" .. GetString(DsRGuildPrice_Loaded) .. "|r") end, 3000)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_Extensions()
	DsRGuildPrice_InitTooltips()
	DsRGuildPrice_GridPriceExtension()
	DsRGuildPrice_LinkHandlerExtension()
	ZO_PreHook("ZO_InventorySlot_ShowContextMenu", function(inventorySlot) zo_callLater(function() DsRGuildPrice_ShowContextMenuExtension(inventorySlot) end, 50) end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice_Is_MM_Ready()
	return MasterMerchant and MasterMerchant.isInitialized and LibGuildStore and LibGuildStore.guildStoreReady
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrice.OnAddOnLoaded(event, name)
	EVENT_MANAGER:UnregisterForEvent(DsRGuildPrice.name, EVENT_ADD_ON_LOADED)
	
	if DsRGuildPrice.SavedVariables.PriceOnOff then return end
	
	if ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales then
		DsRGuildPrice_ATT_Sales = ArkadiusTradeTools.Modules.Sales
	end
	
	DsRGuildPrice.SavedVariables.UseProfitPrice = false
	
	DsRGuildPrice_LoadLater()
end
