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

-- Master-writ voucher count from the item link. There is no ZOS API for this;
-- the count is item-link field 24 (ZO_LinkHandler_ParseLink), scaled by 10000
-- (verified against AGS ItemLinkUtils.lua:59-63, TTC, WritWorthy). Only valid
-- for ITEMTYPE_MASTER_WRIT (field 24 is the crafted flag on potions/poisons).
-- Returns nil for non-writs, nil/0-voucher writs (they exist - AGS guard
-- 2ca5e186), and malformed links, so callers treat those as regular items.
function LWTPriceInfo.GetWritVoucherCount(itemLink)
	if not itemLink or itemLink == "" then return nil end
	if GetItemLinkItemType(itemLink) ~= ITEMTYPE_MASTER_WRIT then return nil end
	local data = select(24, ZO_LinkHandler_ParseLink(itemLink))
	if not data then return nil end
	local vouchers = tonumber(string.format("%.0f", tonumber(data) / 10000))
	if not vouchers or vouchers < 1 then return nil end
	return vouchers
end

-- Effective stack count for delta math: master writs are priced per writ item
-- but their value unit is the voucher, so the effective stack is
-- stackCount * vouchers (AGS ItemData.lua:78-88 pattern). Non-writs and
-- 0-voucher writs return stackCount unchanged.
function LWTPriceInfo.GetEffectiveStackCount(itemLink, stackCount)
	local vouchers = LWTPriceInfo.GetWritVoucherCount(itemLink)
	if vouchers then
		return (stackCount or 1) * vouchers
	end
	return stackCount or 1
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
			price = price * (1 - LWTPriceInfo.GUILD_FEE_RATE - LWTPriceInfo.LISTING_FEE_RATE)
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

-- Guild search delta engine (plan: guild-store-delta-column T1).
-- Pure functions; no UI, no hooks. Shared by the vanilla delta column,
-- the vanilla sort and the AwesomeGuildStore sort order (single source of truth).
-- Per-unit deltas are per VOUCHER for master writs (writ prices are quoted per
-- voucher - ESO community convention, cf. AGS ItemData:GetStackCount); total =
-- per-voucher x effective stack (stackCount x vouchers).

function LWTPriceInfo.GetGuildSearchDeltaPerUnit(itemLink, listingPricePerUnit, settings)
	local provider = LWTPriceInfo.GetAvailablePriceProvider(settings.priceProvider)
	if (provider == nil) then
		return nil
	end

	local _, priceData = pcall(LWTPriceInfo.Providers[provider].Price, itemLink)

	if (not LWTPriceInfo.IsSellableSingle(priceData)) then
		return nil
	end

	local providerTerm
	if (settings.priceType == "Listed Avg") then
		providerTerm = priceData["Listed Avg"]
	elseif (settings.priceType == "Sale Avg") then
		providerTerm = priceData["Sale Avg"]
	elseif (settings.priceType == "Suggested") then
		providerTerm = priceData["Suggested"] / LWTPriceInfo.SUGGESTED_MARKUP
	else
		return nil
	end

	-- Instant-resell simulation: subtract the 7% guild trader fee AND the 1%
	-- listing fee (paid upfront by the seller). Only inside the guildFee branch;
	-- the plain buying views never apply these fees.
	if (settings.guildFee) then
		providerTerm = providerTerm * (1 - LWTPriceInfo.GUILD_FEE_RATE - LWTPriceInfo.LISTING_FEE_RATE)
	end

	if (not settings.guildPriceDelta) then
		return nil
	end

	-- Master writs: the provider's price is per writ ITEM; the delta must be
	-- per VOUCHER so writs of different sizes sort on the same scale
	-- (community convention: gold per voucher). providerTerm and
	-- listingPricePerUnit are both divided by the same V.
	local vouchers = LWTPriceInfo.GetWritVoucherCount(itemLink)
	if vouchers then
		providerTerm = providerTerm / vouchers
		listingPricePerUnit = listingPricePerUnit / vouchers
	end

	-- Second return: the raw priceData table (nil when unavailable). The delta
	-- engine stays the single source for the volume count too - one provider call.
	return providerTerm - listingPricePerUnit, priceData
end

-- Guild delta data row. Per-unit deltas are per VOUCHER for master writs (writ
-- prices are quoted per voucher - ESO community convention, cf. AGS
-- ItemData:GetStackCount); total = per-voucher x effective stack (stackCount x
-- vouchers), so the whole-listing total stays in gold.
function LWTPriceInfo.GetGuildSearchDeltaData(itemLink, listingPricePerUnit, stackCount, settings)
	if (listingPricePerUnit == nil) then
		return nil
	end

	local perUnit, priceData = LWTPriceInfo.GetGuildSearchDeltaPerUnit(itemLink, listingPricePerUnit, settings)

	-- count: raw volume from the same priceData the delta came from ("Listed Avg"
	-- reports Amount, everything else Count - mirror of GetPriceAndCount). -1 / nil
	-- volume stays as-is; FormatCount nils it at display time.
	local count = nil
	if (perUnit ~= nil and priceData ~= nil) then
		if (settings.priceType == "Listed Avg") then
			count = priceData["Amount"]
		else
			count = priceData["Count"]
		end
	end

	return {
		perUnit = perUnit,
		total = perUnit ~= nil and perUnit * LWTPriceInfo.GetEffectiveStackCount(itemLink, stackCount or 1) or nil,
		available = perUnit ~= nil,
		count = count,
	}
end

function LWTPriceInfo.GetGuildSearchDeltaFromResult(data, settings)
	local itemLink = data.itemLink or GetTradingHouseSearchResultItemLink(data.slotIndex)

	local listingPricePerUnit
	local stackCount = data.stackCount

	if (stackCount ~= nil and stackCount > 1 and data.purchasePricePerUnit) then
		listingPricePerUnit = data.purchasePricePerUnit
	elseif (data.purchasePrice and stackCount ~= nil and stackCount > 0) then
		listingPricePerUnit = data.purchasePrice / stackCount
	else
		listingPricePerUnit = nil
	end

	return LWTPriceInfo.GetGuildSearchDeltaData(itemLink, listingPricePerUnit, stackCount, settings)
end

function LWTPriceInfo.GetGuildDeltaFingerprint(settings)
	return tostring(settings.priceProvider) .. settings.priceType .. tostring(settings.guildFee) .. tostring(settings.guildPriceDelta)
end

-- Shared color+format for a guild delta VALUE (isDelta=true, showAmount=false).
-- The color basis is the VALUE passed in: the total label and the combined
-- label color by d.total; the vanilla per-unit split label colors by d.perUnit.
function LWTPriceInfo.FormatGuildDeltaValue(value, settings)
	return LWTPriceInfo.FormatPriceDisplay(value, nil, {
		minPrice = settings.minPrice,
		maxPrice = settings.maxPrice,
		colors = settings.colors,
		priceShorten = settings.priceShorten,
		showAmount = false,
		isDelta = true,
	})
end

-- Guild delta column cell text (plan: guild-store-delta-column T5).
-- Pure: formats the per-row delta for the vanilla guild store table. Returns nil
-- when the row has no price (cell stays hidden - no "em dash" placeholder is
-- ever used, so a row without a price shows an empty cell, consistent with the
-- hidden-label behavior of the overlay).
-- The combined text is assembled from the two split helpers below, so the
-- vanilla two-label UI (F3-r4) and the AGS combined tag share one source of truth.
-- A volume count suffix (overlay badge " |c<hex>[N]", restored) is appended via
-- BuildGuildColumnCountText; the per-unit/total helpers stay pure number-only.
-- Color basis: the combined "unit / total" label is colored by the STACK TOTAL
-- (the whole-stack delta decides the color); the vanilla split keeps the per-unit
-- label colored by perUnit and the total label colored by total.
function LWTPriceInfo.BuildGuildColumnText(d, settings, showTotal)
	local perUnitText = LWTPriceInfo.BuildGuildColumnPerUnitText(d, settings)
	if (perUnitText == nil) then
		return nil
	end

	local text = perUnitText

	if (showTotal) then
		local totalText = LWTPriceInfo.BuildGuildColumnTotalText(d, settings)
		if (totalText) then
			-- Combined "unit / total" label: the whole label is colored by the
			-- STACK TOTAL (the per-unit part is re-rendered with the total's
			-- color); the vanilla split labels keep separate colors.
			local rTotal = LWTPriceInfo.FormatGuildDeltaValue(d.total, settings)
			local rUnit = LWTPriceInfo.FormatGuildDeltaValue(d.perUnit, settings)
			text = "|c" .. rTotal.priceHex .. rUnit.priceFormatted .. "|r / " .. totalText
		end
	end

	-- count suffix after the total suffix: "3.0 / 600 [50]"
	text = text .. (LWTPriceInfo.BuildGuildColumnCountText(d, settings) or "")

	return text
end

-- Guild delta per-unit cell text (plan: guild-store-delta-column F3-r4).
-- Pure: formats ONLY the per-unit delta, "|c<hex><price>|r", via the same
-- FormatPriceDisplay call the combined text's primary used (isDelta=true,
-- showAmount=false). Returns nil when the row has no price (label stays hidden).
function LWTPriceInfo.BuildGuildColumnPerUnitText(d, settings)
	if (not d or not d.available or d.perUnit == nil) then
		return nil
	end

	local r = LWTPriceInfo.FormatGuildDeltaValue(d.perUnit, settings)

	return "|c" .. r.priceHex .. r.priceFormatted .. "|r"
end

-- Guild delta stack-total cell text (plan: guild-store-delta-column F3-r4).
-- Pure: formats ONLY the stack total, "|c<hex><total>|r", colored by the TOTAL
-- value (the whole-stack delta decides the color); the vanilla split keeps the
-- per-unit label colored by perUnit.
-- Returns nil when the row has no total or the stack is 1 (total == perUnit);
-- the showTotal gate stays in the calling wrapper.
function LWTPriceInfo.BuildGuildColumnTotalText(d, settings)
	if (not d or not d.available or d.total == nil or d.total == d.perUnit) then
		return nil
	end

	local r = LWTPriceInfo.FormatGuildDeltaValue(d.total, settings)

	return "|c" .. r.priceHex .. LWTPriceInfo.FormatNumber(d.total, 0) .. "|r"
end

-- Guild delta cell count suffix (plan: guild-store-delta-column T5, restore-count).
-- Pure: formats the volume/count suffix " |c<hex>[<count>]" exactly like the
-- overlay badge (LWTPriceInfo.lua:415-416). Returns nil when the row has no price
-- or count, when the count is <= 0 (FormatCount nils the -1 "no volume" sentinel),
-- or when settings.showAmount is off. Color handling (Base/Same/Separate +
-- countMin/countMax gradient) comes from FormatPriceDisplay's count fields, so it
-- matches the overlay exactly. Only the count fields are used - never the price.
function LWTPriceInfo.BuildGuildColumnCountText(d, settings)
	if (not d or not d.available or d.perUnit == nil or d.count == nil) then
		return nil
	end
	if (settings.showAmount == false) then
		return nil
	end

	local r = LWTPriceInfo.FormatPriceDisplay(d.perUnit, d.count, {
		minPrice = settings.minPrice,
		maxPrice = settings.maxPrice,
		colors = settings.colors,
		priceShorten = settings.priceShorten,
		showAmount = true,
		colorAmount = settings.colorAmount,
		countMin = settings.countMin,
		countMax = settings.countMax,
		isDelta = true,
	})

	if (not r.countDisplay) then
		return nil
	end

	return " |c" .. r.countHex .. "[" .. r.countDisplay .. "]"
end
