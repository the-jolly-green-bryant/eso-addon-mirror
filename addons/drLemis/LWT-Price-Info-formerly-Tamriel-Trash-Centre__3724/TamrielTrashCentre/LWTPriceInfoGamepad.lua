local GAMEPAD_TOOLTIP_PRICE_STYLE = {
	fontSize = 28,
	fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1,
}

local gamepadHooksInstalled = false

function LWTPriceInfo.InitializeGamepad()
	if gamepadHooksInstalled then return end

	LWTPriceInfo.InstallGamepadHooks()

	gamepadHooksInstalled = true
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

function LWTPriceInfo.OnGamepadModeChanged()
	if IsInGamepadPreferredMode() then
		LWTPriceInfo.SafeCall(LWTPriceInfo.InitializeGamepad, "Gamepad mode init")
	else
		LWTPriceInfo.SafeCall(LWTPriceInfo.InitializeKeyboardMode, "Keyboard mode init")
	end
end
