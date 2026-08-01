---
--- Created by YeOldeDragon.
---

local DEFAULT_TEXT = "n/a"
local TEXT_COLOR = ZO_CURRENCY_HIGHLIGHT_TEXT:ToHex()
-- local TEXT_PATTERN = "|c" .. TEXT_COLOR .. "<<1>>|r <<2>>  "
local TEXT_PATTERN = "|c" .. TEXT_COLOR .. "<<1>>|r  "
local SV_VERSION = 1

local ICON_SIZE = 16

local ORDER = {
	[1] = CURT_ALLIANCE_POINTS,
	[2] = CURT_TELVAR_STONES,
	[3] = CURT_WRIT_VOUCHERS,
}

local ICONS = {
	[CURT_ALLIANCE_POINTS] = GetCurrencyKeyboardIcon(CURT_ALLIANCE_POINTS),
	[CURT_TELVAR_STONES] = GetCurrencyKeyboardIcon(CURT_TELVAR_STONES),
	[CURT_WRIT_VOUCHERS] = GetCurrencyKeyboardIcon(CURT_WRIT_VOUCHERS),
}

local TEXT_ICONS = {
	[CURT_ALLIANCE_POINTS] = zo_iconFormat(ICONS[CURT_ALLIANCE_POINTS], ICON_SIZE, ICON_SIZE),
	[CURT_TELVAR_STONES] = zo_iconFormat(ICONS[CURT_TELVAR_STONES], ICON_SIZE, ICON_SIZE),
	[CURT_WRIT_VOUCHERS] = zo_iconFormat(ICONS[CURT_WRIT_VOUCHERS], ICON_SIZE, ICON_SIZE),
}

local NAMES = {
	[CURT_ALLIANCE_POINTS] = YeOldeInfos.lang[SI_YEOLDEINFOS_CURRENCY_ALLIANCE_POINTS],
	[CURT_TELVAR_STONES] = YeOldeInfos.lang[SI_YEOLDEINFOS_CURRENCY_TELVAR_STONES],
	[CURT_WRIT_VOUCHERS] = YeOldeInfos.lang[SI_YEOLDEINFOS_CURRENCY_WRIT_VOUCHERS],
}

------------------------------
-- Class definition
YeOldePlayerCurrencies = YeOldeInfoBar_Base:Subclass()

function YeOldePlayerCurrencies:InitializeControls()
	self.blocs = {}
	for _, currencyType in ipairs(ORDER) do
		self.blocs[currencyType] = self.uiBar:AddContentBloc(currencyType, ICONS[currencyType], DEFAULT_TEXT)
		if not self.SV.Show[currencyType] then
			self.uiBar:SetBlocHidden(self.blocs[currencyType], true)
		end
	end
end

function YeOldePlayerCurrencies:GetTotalCurrency(currencyType)
	local amount = GetCurrencyAmount(currencyType, CURRENCY_LOCATION_CHARACTER)
	amount = amount + GetCurrencyAmount(currencyType, CURRENCY_LOCATION_BANK)
	if
		currencyType == CURT_ALLIANCE_POINTS
		or currencyType == CURT_TELVAR_STONES
		or currencyType == CURT_WRIT_VOUCHERS
	then
		amount = amount + GetCurrencyAmount(currencyType, CURRENCY_LOCATION_ACCOUNT)
	end
	return ZO_CommaDelimitDecimalNumber(amount)
end

function YeOldePlayerCurrencies:UpdateCurrencies()
	for _, currencyType in ipairs(ORDER) do
		if self.SV.Show[currencyType] then
			local amountText = self:GetTotalCurrency(currencyType)
			self.blocs[currencyType]:SetText(zo_strformat(TEXT_PATTERN, amountText))
		end
	end
end

function YeOldePlayerCurrencies:OnActivate(value)
	if value then
		self:UpdateCurrencies()

		local function OnCurrencyUpdate(eventId, currencyType, currencyLocation, newAmount, oldAmount, reason)
			if
				currencyType == CURT_ALLIANCE_POINTS
				or currencyType == CURT_TELVAR_STONES
				or currencyType == CURT_WRIT_VOUCHERS
			then
				self:UpdateCurrencies()
			end
		end

		EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_CURRENCY_UPDATE, OnCurrencyUpdate)
	else
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_CURRENCY_UPDATE)
	end
end

function YeOldePlayerCurrencies:InitializeSavedVars()
	-- If Version = 0, we need to initialize vars
	if self.SV.Version == 0 then
		self.SV.Show = {
			[CURT_ALLIANCE_POINTS] = true,
			[CURT_TELVAR_STONES] = true,
			[CURT_WRIT_VOUCHERS] = true,
		}
	else
		if self.SV.Show == nil then
			self.SV.Show = {}
		end
		if self.SV.Show[CURT_ALLIANCE_POINTS] == nil then
			self.SV.Show[CURT_ALLIANCE_POINTS] = true
		end
		if self.SV.Show[CURT_TELVAR_STONES] == nil then
			self.SV.Show[CURT_TELVAR_STONES] = true
		end
		if self.SV.Show[CURT_WRIT_VOUCHERS] == nil then
			self.SV.Show[CURT_WRIT_VOUCHERS] = true
		end
	end
	self.SV.Version = SV_VERSION
end

local TOOLTIPS = {
	[CURT_ALLIANCE_POINTS] = YeOldeInfos.lang[SI_YEOLDEINFOS_TT_CURRENCY_ALLIANCE_POINTS],
	[CURT_TELVAR_STONES] = YeOldeInfos.lang[SI_YEOLDEINFOS_TT_CURRENCY_TELVAR_STONES],
	[CURT_WRIT_VOUCHERS] = YeOldeInfos.lang[SI_YEOLDEINFOS_TT_CURRENCY_WRIT_VOUCHERS],
}

function YeOldePlayerCurrencies:InitializeSettingsMenu(controls)
	controls[#controls + 1] = {
		type = "divider",
		reference = zo_strformat(YeOldeInfos.SETTING_PATTERN, self.name, #controls),
	}
	controls[#controls + 1] = {
		type = "description",
		title = zo_strformat(YeOldeInfos.SETTING_DESC_TITLE_PATTERN, YeOldeInfos.lang[SI_YEOLDEINFOS_BAR_CONTENT]),
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
		name = YeOldeInfos.lang[SI_YEOLDEINFOS_CURRENCY_HEADER],
		controls = controls,
	}
	return options
end
