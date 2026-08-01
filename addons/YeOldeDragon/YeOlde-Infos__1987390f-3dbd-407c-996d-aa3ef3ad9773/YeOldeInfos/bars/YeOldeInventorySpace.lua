---
--- Created by elwoo.
--- DateTime: 2021-06-22 22:20
---

local WARNING_PCT = 70
local DEFAULT_TEXT = "n/a"
local TEXT_PATTERN = "|c<<1>><<2>>|r / <<3>>"
local SV_VERSION = 1

local SLOT_HEALTY_COLOR = YeOldeInfos.Colors.GREEN
local SLOT_WARNING_COLOR = YeOldeInfos.Colors.GOLD
local SLOT_FULL_COLOR = YeOldeInfos.Colors.RED

local ORDER = {
	[1] = BAG_BACKPACK,
	[2] = BAG_BANK,
}

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
YeOldeInventorySpace = YeOldeInfoBar_Base:Subclass()

function YeOldeInventorySpace:InitializeControls()
	self.blocs = {}
	for _, type in ipairs(ORDER) do
		self.blocs[type] = self.uiBar:AddContentBloc(type, ICONS[type], DEFAULT_TEXT)
		if not self.SV.Show[type] then
			self.uiBar:SetBlocHidden(self.blocs[type], true)
		end
	end
end

function YeOldeInventorySpace:UpdateBags()
	for _, bagType in pairs(ORDER) do
		if self.SV.Show[bagType] then
			local bagInfo = self:GetSpaceInfo(bagType)
			self.blocs[bagType]:SetText(bagInfo)
		end
	end
end

function YeOldeInventorySpace:GetSpaceInfo(bagType)
	local totalSlots = GetBagUseableSize(bagType)
	local freeSlots = GetNumBagFreeSlots(bagType)

	if bagType == BAG_BANK then
		totalSlots = totalSlots + GetBagUseableSize(BAG_SUBSCRIBER_BANK)
		freeSlots = freeSlots + GetNumBagFreeSlots(BAG_SUBSCRIBER_BANK)
	end

	if totalSlots == 0 then
		return DEFAULT_TEXT
	end
	local usedSlots = totalSlots - freeSlots
	local healthColor = SLOT_HEALTY_COLOR
	local percentUsed = (usedSlots / totalSlots) * 100

	if percentUsed >= 100 then
		healthColor = SLOT_FULL_COLOR
	elseif percentUsed > self.SV.WarningPct[bagType] then
		healthColor = SLOT_WARNING_COLOR
	end

	return zo_strformat(TEXT_PATTERN, healthColor:ToHex(), usedSlots, totalSlots)
end

function YeOldeInventorySpace:OnActivate(value)
	local function OnInventoryUpdate()
		self:UpdateBags()
	end

	if value then
		EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_INVENTORY_BOUGHT_BAG_SPACE, OnInventoryUpdate)
		EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_INVENTORY_BOUGHT_BANK_SPACE, OnInventoryUpdate)
		EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdate)
		EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_INVENTORY_FULL_UPDATE, OnInventoryUpdate)
		EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_INVENTORY_ITEM_USED, OnInventoryUpdate)
		EVENT_MANAGER:RegisterForEvent(
			self.eventNamespace,
			EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG,
			OnInventoryUpdate
		)
		EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_INVENTORY_ITEM_DESTROYED, OnInventoryUpdate)
		self:UpdateBags()
	else
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_INVENTORY_BOUGHT_BAG_SPACE)
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_INVENTORY_BOUGHT_BANK_SPACE)
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_INVENTORY_FULL_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_INVENTORY_ITEM_USED)
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG)
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_INVENTORY_ITEM_DESTROYED)
	end
end

function YeOldeInventorySpace:InitializeSavedVars()
	-- If Version = 0, we need to initialize vars
	if self.SV.Version == 0 then
		self.SV.Show = {
			[BAG_BACKPACK] = true,
			[BAG_BANK] = true,
		}
		self.SV.WarningPct = {
			[BAG_BACKPACK] = WARNING_PCT,
			[BAG_BANK] = WARNING_PCT,
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

		if self.SV.WarningPct == nil then
			self.SV.WarningPct = {}
		end
		if self.SV.WarningPct[BAG_BACKPACK] == nil then
			self.SV.WarningPct[BAG_BACKPACK] = WARNING_PCT
		end
		if self.SV.WarningPct[BAG_BANK] == nil then
			self.SV.WarningPct[BAG_BANK] = WARNING_PCT
		end
	end
	self.SV.Version = SV_VERSION
end

function YeOldeInventorySpace:InitializeSettingsMenu(controls)
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
				self:UpdateBags()
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
				self:UpdateBags()
			end
		end,
	}

	local options = {
		type = "submenu",
		name = GetString(SI_GAMEPAD_MAIL_INBOX_INVENTORY),
		controls = controls,
	}
	return options
end
