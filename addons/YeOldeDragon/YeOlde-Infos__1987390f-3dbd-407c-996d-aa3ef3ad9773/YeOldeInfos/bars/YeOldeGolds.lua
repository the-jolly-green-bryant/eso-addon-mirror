---
--- Created by elwoo.
--- DateTime: 2021-06-22 22:20
---

local DEFAULT_TEXT = "n/a"
local TEXT_COLOR = ZO_CURRENCY_HIGHLIGHT_TEXT:ToHex()
local TEXT_PATTERN = "|c" .. TEXT_COLOR .. "<<1>>|r <<2>>  "
local SV_VERSION = 1

local ORDER = {
	[1] = BAG_BACKPACK,
	[2] = BAG_BANK,
}

local STAMP_SIZE = 16
local ICON_GOLD = "esoui/art/currency/currency_gold.dds"
local TEXT_ICON_GOLD = zo_iconFormat(ICON_GOLD, STAMP_SIZE, STAMP_SIZE)
local ICONS = {
	[BAG_BACKPACK] = "/esoui/art/tutorial/gamepad/gp_inventory_icon_all.dds",
	[BAG_BANK] = "/esoui/art/icons/mapkey/mapkey_bank.dds",
}

local NAMES = {
	[BAG_BACKPACK] = GetString(SI_YEOLDEINFOS_BAG),
	[BAG_BANK] = GetString(SI_INTERACT_OPTION_BANK),
}

------------------------------
-- Class definition
YeOldeGolds = YeOldeInfoBar_Base:Subclass()

function YeOldeGolds:InitializeControls()
	self.blocs = {}
	for _, type in ipairs(ORDER) do
		self.blocs[type] = self.uiBar:AddContentBloc(type, ICONS[type], DEFAULT_TEXT)
		if not self.SV.Show[type] then
			self.uiBar:SetBlocHidden(self.blocs[type], true)
		end
		-- self.blocs[type]:SetStampIcon(ICON_GOLD, STAMP_SIZE, STAMP_SIZE, BOTTOMRIGHT, 0, 0, true)
	end
end

function YeOldeGolds:UpdateGoldInfos()
	local bankedGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
	bankedGold = ZO_CommaDelimitDecimalNumber(bankedGold)

	local inventoryGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
	inventoryGold = ZO_CommaDelimitDecimalNumber(inventoryGold)

	if self.SV.Show[BAG_BACKPACK] then
		self.blocs[BAG_BACKPACK]:SetText(zo_strformat(TEXT_PATTERN, inventoryGold, TEXT_ICON_GOLD))
	end
	if self.SV.Show[BAG_BANK] then
		self.blocs[BAG_BANK]:SetText(zo_strformat(TEXT_PATTERN, bankedGold, TEXT_ICON_GOLD))
	end
end

function YeOldeGolds:OnActivate(value)
	if value then
		self:UpdateGoldInfos()

		local function OnMoneyUpdate()
			self:UpdateGoldInfos()
		end

		EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_MONEY_UPDATE, OnMoneyUpdate)
		EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_BANKED_MONEY_UPDATE, OnMoneyUpdate)
	else
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_MONEY_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_BANKED_MONEY_UPDATE)
	end
end

function YeOldeGolds:InitializeSavedVars()
	-- If Version = 0, we need to initialize vars
	if self.SV.Version == 0 then
		self.SV.Show = {
			[BAG_BACKPACK] = true,
			[BAG_BANK] = true,
		}
	else
		if self.SV.Show == nil then
			self.SV.Show = {}
		end
		if self.SV.Show[BAG_BACKPACK] == nil then
			self.SV.Show[BAG_BACKPACK] = true
		end
		if self.SV.Show[BAG_BANK] == nil then
			self.SV.Show[BAG_BANK] = true
		end
	end
	self.SV.Version = SV_VERSION
end

function YeOldeGolds:InitializeSettingsMenu(controls)
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
	controls[#controls + 1] = {
		type = "checkbox",
		name = NAMES[BAG_BACKPACK],
		getFunc = function()
			return self.SV.Show[BAG_BACKPACK]
		end,
		setFunc = function(value)
			self.SV.Show[BAG_BACKPACK] = value
			self.uiBar:SetBlocHidden(self.blocs[BAG_BACKPACK], not value)
			if value then
				self:UpdateGoldInfos()
			end
		end,
	}
	controls[#controls + 1] = {
		type = "checkbox",
		name = NAMES[BAG_BANK],
		getFunc = function()
			return self.SV.Show[BAG_BANK]
		end,
		setFunc = function(value)
			self.SV.Show[BAG_BANK] = value
			self.uiBar:SetBlocHidden(self.blocs[BAG_BANK], not value)
			if value then
				self:UpdateGoldInfos()
			end
		end,
	}

	local options = {
		type = "submenu",
		name = GetString(SI_GAMEPAD_MAIL_SEND_GOLD_HEADER),
		controls = controls,
	}
	return options
end
