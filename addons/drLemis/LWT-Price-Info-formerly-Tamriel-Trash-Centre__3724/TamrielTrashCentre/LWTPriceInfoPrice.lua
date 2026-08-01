function LWTPriceInfo.GetPriceData(itemLink)
	local result = {}

	for name, data in pairs(LWTPriceInfo.Providers) do
		if LWTPriceInfo.ProviderAvailable[name] then
			local ok, priceResult = pcall(data.Price, itemLink)
			if ok and priceResult then
				result[name] = priceResult
			end
		end
	end

	return result
end

function LWTPriceInfo.GetSingleProviderPrice(provider, itemLink)
	if not provider or not LWTPriceInfo.ProviderAvailable[provider] then
		return nil
	end
	local ok, priceResult = pcall(LWTPriceInfo.Providers[provider]["Price"], itemLink)
	if ok and priceResult then
		return priceResult
	end
	return nil
end

function LWTPriceInfo.IsSellableSingle(providerPriceData)
	return providerPriceData ~= nil
		and providerPriceData["Listed Avg"] ~= nil
		and providerPriceData["Listed Avg"] ~= 0
end

function LWTPriceInfo.FormPriceData(listedAvg, suggested, saleAvg, amount, count)
	local normalized = {}
	normalized["Listed Avg"] = listedAvg == nil and 0 or listedAvg
	normalized["Suggested"] = suggested == nil and 0 or suggested
	normalized["Sale Avg"] = saleAvg == nil and 0 or saleAvg
	normalized["Amount"] = amount == nil and 0 or amount
	normalized["Count"] = count == nil and 0 or count
	return normalized
end

function LWTPriceInfo.GetAvailablePriceProvider(provider)
	if provider ~= nil and LWTPriceInfo.ProviderAvailable[provider] then
		return provider
	end

	for _, providerName in ipairs(LWTPriceInfo.ProviderNames) do
		if LWTPriceInfo.ProviderAvailable[providerName] then
			return providerName
		end
	end

	return nil
end

function LWTPriceInfo.GetPriceAndCount(settings, itemLink, multItems)
	local provider = LWTPriceInfo.GetAvailablePriceProvider(settings.priceProvider)
	if (provider == nil) then
		return nil, nil
	end

	local ok, priceData = pcall(LWTPriceInfo.Providers[provider]["Price"], itemLink)

	if (not ok or priceData == nil) then
		return nil, nil
	end

	local price, count = 0, 0

	if (settings.priceType == "Listed Avg") then
		price = priceData["Listed Avg"] * multItems
		count = priceData["Amount"]
	elseif (settings.priceType == "Sale Avg") then
		price = priceData["Sale Avg"] * multItems
		count = priceData["Count"]
	elseif (settings.priceType == "Suggested") then
		price = (priceData["Suggested"] / LWTPriceInfo.SUGGESTED_MARKUP) * multItems
		count = priceData["Count"]
	end

	return price, count
end

function LWTPriceInfo.FormatNumber(number, decimal)
	decimal = decimal or 0
	local mult = 10 ^ decimal
	number = math.floor(number * mult + 0.5) / mult

	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

function LWTPriceInfo.GetGamepadPriceText(itemLink, stackCount, guildPricePerUnit)
	local settings = LWTPriceInfo.vars.gamepad
	local markerSettings = LWTPriceInfo.GetMarkerSettings()

	local providerPrice = LWTPriceInfo.GetSingleProviderPrice(settings.priceProvider, itemLink)
	if not LWTPriceInfo.IsSellableSingle(providerPrice) then return nil end

	if settings.setsOnly then
		local _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
		if not setId or setId == 0 then return nil end
	end

	if settings.ignoreBound and IsItemLinkBound(itemLink) then return nil end

	local multItems = 1
	if settings.stackMultiplier and stackCount then
		multItems = stackCount
	end

	local syntheticSettings = {
		priceProvider = settings.priceProvider,
		priceType = settings.priceType,
		stackMultiplier = false,
	}

	local price, count = LWTPriceInfo.GetPriceAndCount(syntheticSettings, itemLink, multItems)
	if not price or price == 0 then return nil end

	local isDelta = false
	if settings.guildPriceDelta and guildPricePerUnit then
		isDelta = true
		if settings.guildFee then
			price = price * (1 - LWTPriceInfo.GUILD_FEE_RATE)
		end
		price = price - guildPricePerUnit * multItems
	end

	local r = LWTPriceInfo.FormatPriceDisplay(price, count, {
		minPrice = markerSettings.minPrice,
		maxPrice = markerSettings.maxPrice,
		colors = markerSettings.colors,
		priceShorten = markerSettings.priceShorten,
		showAmount = markerSettings.showAmount,
		colorAmount = markerSettings.colorAmount,
		countMin = markerSettings.countMin,
		countMax = markerSettings.countMax,
		isDelta = isDelta,
	})

	local priceText = "|c" .. r.priceHex .. r.priceFormatted .. "|r"
	if r.countDisplay then
		priceText = priceText .. " |c" .. r.countHex .. "[" .. r.countDisplay .. "]|r"
	end

	return priceText
end

function LWTPriceInfo.FormatPriceDisplay(price, count, options)
	local minPrice = options.minPrice or 0
	local maxPrice = options.maxPrice or 2500
	if maxPrice <= minPrice then maxPrice = minPrice + 1 end

	local colors = options.colors
	local priceShorten = options.priceShorten or 1000
	local comparePrice = options.comparePrice or -1

	local cP
	if price ~= 0 then
		if options.profitableColor and price > 0 and (options.priceOffset or 0) == 0
			and (options.itemPrice or 0) * (options.multItems or 1) >= price * (1 - LWTPriceInfo.GUILD_FEE_RATE) then
			cP = colors.colorProfitable
		elseif price < comparePrice and price > 0 then
			cP = colors.colorBad
		elseif options.isDelta then
			if price < 0 then
				cP = LWTPriceInfo.ColorInterpolateHSL(-price, 0, maxPrice, colors.colorGuildBadStart, colors.colorGuildBadEnd)
			else
				cP = LWTPriceInfo.ColorInterpolateHSL(price, 0, maxPrice, colors.colorGuildGoodStart, colors.colorGuildGoodEnd)
			end
		else
			cP = LWTPriceInfo.ColorInterpolateHSL(price, minPrice, maxPrice, colors.colorBad, colors.colorGood)
		end
	else
		if options.isDelta then
			cP = LWTPriceInfo.ColorInterpolateHSL(price, 0, maxPrice, colors.colorGuildGoodStart, colors.colorGuildGoodEnd)
		else
			cP = colors.colorBad
		end
	end

	local decimals = 2
	if price >= priceShorten or price <= -priceShorten then
		decimals = 0
	end

	local priceFormatted = LWTPriceInfo.FormatNumber(price, decimals)
	local priceHex = LWTPriceInfo.RGB2HEX(cP.r, cP.g, cP.b)

	local countDisplay = nil
	local countHex = nil
	local countColor = nil
	local showAmount = options.showAmount ~= false

	if showAmount and count and count > 0 then
		countDisplay = LWTPriceInfo.FormatCount(count)
		if countDisplay then
			local colorAmount = options.colorAmount or "Separate"
			local cA
			if colorAmount == "Same" then
				cA = cP
			elseif colorAmount == "Separate" then
				local countMin = options.countMin or 5
				local countMax = options.countMax or 50
				cA = LWTPriceInfo.ColorInterpolateHSL(count, countMin, countMax, colors.colorBad, colors.colorGood)
			else
				cA = { r = 1, g = 1, b = 1, a = 1 }
			end
			countColor = cA
			countHex = LWTPriceInfo.RGB2HEX(cA.r, cA.g, cA.b)
		end
	end

	return {
		priceFormatted = priceFormatted,
		priceHex = priceHex,
		priceColor = cP,
		countDisplay = countDisplay,
		countHex = countHex,
		countColor = countColor,
	}
end

function LWTPriceInfo.FormatCount(count)
	if not count or count <= 0 then return nil end
	if count >= 1000000 then
		return string.format("%.1fM", count / 1000000)
	elseif count >= 1000 then
		return string.format("%.1fK", count / 1000)
	end
	return tostring(count)
end

function LWTPriceInfo.IsSellable(priceData, provider)
	if priceData == nil then
		return false
	end

	if provider then
		local data = priceData[provider]
		return data ~= nil and data["Listed Avg"] ~= nil and data["Listed Avg"] ~= 0
	end

	for name, _ in pairs(LWTPriceInfo.Providers) do
		if LWTPriceInfo.ProviderAvailable[name] and priceData[name] ~= nil and priceData[name]["Listed Avg"] ~= nil and priceData[name]["Listed Avg"] ~= 0 then
			return true
		end
	end

	return false
end
