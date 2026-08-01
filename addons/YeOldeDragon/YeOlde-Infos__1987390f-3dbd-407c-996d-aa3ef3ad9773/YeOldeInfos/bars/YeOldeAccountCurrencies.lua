---
--- Created by YeOldeDragon.
---

local DEFAULT_TEXT = "n/a"
local TEXT_COLOR = ZO_CURRENCY_HIGHLIGHT_TEXT:ToHex()
local TEXT_PATTERN = "|c" .. TEXT_COLOR .. "<<1>>|r  "
local SV_VERSION = 1

local ICON_SIZE = 16

local ORDER = {
	[1] = CURT_CHAOTIC_CREATIA,    -- transmute crystals
	[2] = CURT_CROWN_GEMS,         -- crown gems
	[3] = CURT_CROWNS,             -- crowns
	[4] = CURT_TRADE_BARS,         -- trade bars
	[5] = CURT_ENDEAVOR_SEALS,     -- seals
	[6] = CURT_ARCHIVAL_FORTUNES,  -- archival fortunes
	[7] = CURT_IMPERIAL_FRAGMENTS, -- imperial fragments
	[8] = CURT_TOME_POINTS,        -- tome points
}

local ICONS = {
	[CURT_CHAOTIC_CREATIA] = GetCurrencyKeyboardIcon(CURT_CHAOTIC_CREATIA),
	[CURT_CROWN_GEMS] = GetCurrencyKeyboardIcon(CURT_CROWN_GEMS),
	[CURT_CROWNS] = GetCurrencyKeyboardIcon(CURT_CROWNS),
	[CURT_TRADE_BARS] = GetCurrencyKeyboardIcon(CURT_TRADE_BARS),
	[CURT_ENDEAVOR_SEALS] = GetCurrencyKeyboardIcon(CURT_ENDEAVOR_SEALS),
	[CURT_ARCHIVAL_FORTUNES] = GetCurrencyKeyboardIcon(CURT_ARCHIVAL_FORTUNES),
	[CURT_IMPERIAL_FRAGMENTS] = GetCurrencyKeyboardIcon(CURT_IMPERIAL_FRAGMENTS),
	[CURT_TOME_POINTS] = GetCurrencyKeyboardIcon(CURT_TOME_POINTS),
}

local TEXT_ICONS = {
	[CURT_CHAOTIC_CREATIA] = zo_iconFormat(ICONS[CURT_CHAOTIC_CREATIA], ICON_SIZE, ICON_SIZE),
	[CURT_CROWN_GEMS] = zo_iconFormat(ICONS[CURT_CROWN_GEMS], ICON_SIZE, ICON_SIZE),
	[CURT_CROWNS] = zo_iconFormat(ICONS[CURT_CROWNS], ICON_SIZE, ICON_SIZE),
	[CURT_TRADE_BARS] = zo_iconFormat(ICONS[CURT_TRADE_BARS], ICON_SIZE, ICON_SIZE),
	[CURT_ENDEAVOR_SEALS] = zo_iconFormat(ICONS[CURT_ENDEAVOR_SEALS], ICON_SIZE, ICON_SIZE),
	[CURT_ARCHIVAL_FORTUNES] = zo_iconFormat(ICONS[CURT_ARCHIVAL_FORTUNES], ICON_SIZE, ICON_SIZE),
	[CURT_IMPERIAL_FRAGMENTS] = zo_iconFormat(ICONS[CURT_IMPERIAL_FRAGMENTS], ICON_SIZE, ICON_SIZE),
	[CURT_TOME_POINTS] = zo_iconFormat(ICONS[CURT_TOME_POINTS], ICON_SIZE, ICON_SIZE),
}

local NAMES = {
	[CURT_CHAOTIC_CREATIA] = GetString(SI_YEOLDEINFOS_CURRENCY_CHAOTIC_CREATIA),
	[CURT_CROWN_GEMS] = GetString(SI_YEOLDEINFOS_CURRENCY_CROWN_GEMS),
	[CURT_CROWNS] = GetString(SI_YEOLDEINFOS_CURRENCY_CROWNS),
	[CURT_TRADE_BARS] = GetString(SI_YEOLDEINFOS_CURRENCY_TRADE_BARS),
	[CURT_ENDEAVOR_SEALS] = GetString(SI_YEOLDEINFOS_CURRENCY_ENDEAVOR_SEALS),
	[CURT_ARCHIVAL_FORTUNES] = GetString(SI_YEOLDEINFOS_CURRENCY_ARCHIVAL_FORTUNES),
	[CURT_IMPERIAL_FRAGMENTS] = GetString(SI_YEOLDEINFOS_CURRENCY_IMPERIAL_FRAGMENTS),
	[CURT_TOME_POINTS] = GetString(SI_YEOLDEINFOS_CURRENCY_TOME_POINTS),
}

local TOOLTIPS = {
	[CURT_CHAOTIC_CREATIA] = GetString(SI_YEOLDEINFOS_TT_CURRENCY_CHAOTIC_CREATIA),
	[CURT_CROWN_GEMS] = GetString(SI_YEOLDEINFOS_TT_CURRENCY_CROWN_GEMS),
	[CURT_CROWNS] = GetString(SI_YEOLDEINFOS_TT_CURRENCY_CROWNS),
	[CURT_TRADE_BARS] = GetString(SI_YEOLDEINFOS_TT_CURRENCY_TRADE_BARS),
	[CURT_ENDEAVOR_SEALS] = GetString(SI_YEOLDEINFOS_TT_CURRENCY_ENDEAVOR_SEALS),
	[CURT_ARCHIVAL_FORTUNES] = GetString(SI_YEOLDEINFOS_TT_CURRENCY_ARCHIVAL_FORTUNES),
	[CURT_IMPERIAL_FRAGMENTS] = GetString(SI_YEOLDEINFOS_TT_CURRENCY_IMPERIAL_FRAGMENTS),
	[CURT_TOME_POINTS] = GetString(SI_YEOLDEINFOS_TT_CURRENCY_TOME_POINTS),
}

------------------------------
-- Class definition
YeOldeAccountCurrencies = YeOldeInfoBar_Base:Subclass()

function YeOldeAccountCurrencies:InitializeControls()
	self.blocs = {}
	for _, currencyType in ipairs(ORDER) do
		self.blocs[currencyType] = self.uiBar:AddContentBloc(currencyType, ICONS[currencyType], DEFAULT_TEXT)
		if not self.SV.Show[currencyType] then
			self.uiBar:SetBlocHidden(self.blocs[currencyType], true)
		end
	end
end

function YeOldeAccountCurrencies:GetTotalCurrency(currencyType)
	local amount = GetCurrencyAmount(currencyType, CURRENCY_LOCATION_ACCOUNT)
	return ZO_CommaDelimitDecimalNumber(amount)
end

function YeOldeAccountCurrencies:UpdateCurrencies()
	for _, currencyType in ipairs(ORDER) do
		if self.SV.Show[currencyType] then
			local amountText = self:GetTotalCurrency(currencyType)
			self.blocs[currencyType]:SetText(zo_strformat(TEXT_PATTERN, amountText))
		end
	end
end

function YeOldeAccountCurrencies:OnActivate(value)
	if value then
		self:UpdateCurrencies()

		local function OnCurrencyUpdate(eventId, currencyType, currencyLocation, newAmount, oldAmount, reason)
			for _, managedCurrency in ipairs(ORDER) do
				if currencyType == managedCurrency then
					self:UpdateCurrencies()
					break
				end
			end
		end

		EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_CURRENCY_UPDATE, OnCurrencyUpdate)
	else
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_CURRENCY_UPDATE)
	end
end

function YeOldeAccountCurrencies:InitializeSavedVars()
	-- If Version = 0, we need to initialize vars
	if self.SV.Version == 0 then
		self.SV.Show = {}
		for _, currencyType in ipairs(ORDER) do
			self.SV.Show[currencyType] = true
		end
	else
		if self.SV.Show == nil then
			self.SV.Show = {}
		end
		for _, currencyType in ipairs(ORDER) do
			if self.SV.Show[currencyType] == nil then
				self.SV.Show[currencyType] = true
			end
		end
	end
	self.SV.Version = SV_VERSION
end

function YeOldeAccountCurrencies:InitializeSettingsMenu(controls)
	controls[#controls + 1] = {
		type = "divider",
		reference = zo_strformat(YeOldeInfos.SETTING_PATTERN, self.name, #controls),
	}
	controls[#controls + 1] = {
		type = "description",
        uppercase = true,
		title = GetString(SI_YEOLDEINFOS_BAR_CONTENT),
		reference = zo_strformat(YeOldeInfos.SETTING_PATTERN, self.name, #controls),
	}

	for _, currencyType in ipairs(ORDER) do
		controls[#controls + 1] = {
			type = "checkbox",
			name = NAMES[currencyType],
			tooltip = TOOLTIPS[currencyType],
			getFunc = function()
				return self.SV.Show[currencyType]
			end,
			setFunc = function(value)
				self.SV.Show[currencyType] = value
				self.uiBar:SetBlocHidden(self.blocs[currencyType], not value)
				if value then
					self:UpdateCurrencies()
				end
			end,
		}
	end

	local options = {
		type = "submenu",
		name = GetString(SI_YEOLDEINFOS_ACCOUNT_CURRENCY_HEADER),
		controls = controls,
	}
	return options
end
