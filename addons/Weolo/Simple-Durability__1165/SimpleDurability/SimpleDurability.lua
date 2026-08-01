local SimpleDurability = {}
local ADDON_NAME = "SimpleDurability"
local ADDON_VERSION = "4.4"
local DISPLAY_NAME = "Simple Durability"

local slots = {
	[EQUIP_SLOT_HEAD] = ZO_CharacterEquipmentSlotsHead,
	[EQUIP_SLOT_CHEST] = ZO_CharacterEquipmentSlotsChest,
	[EQUIP_SLOT_SHOULDERS] = ZO_CharacterEquipmentSlotsShoulder,
	[EQUIP_SLOT_OFF_HAND] = ZO_CharacterEquipmentSlotsOffHand, --Armour or charges
	[EQUIP_SLOT_WAIST] = ZO_CharacterEquipmentSlotsBelt,
	[EQUIP_SLOT_LEGS] = ZO_CharacterEquipmentSlotsLeg,
	[EQUIP_SLOT_FEET] = ZO_CharacterEquipmentSlotsFoot,
	[EQUIP_SLOT_HAND] = ZO_CharacterEquipmentSlotsGlove,
	[EQUIP_SLOT_BACKUP_OFF] = ZO_CharacterEquipmentSlotsBackupOff, --Armour or charges
	[EQUIP_SLOT_MAIN_HAND] = ZO_CharacterEquipmentSlotsMainHand, --Charges
	[EQUIP_SLOT_BACKUP_MAIN] = ZO_CharacterEquipmentSlotsBackupMain --Charges
}

local function UpdateHighlights()
	for slotId, slotControl in pairs(slots) do
		local highlight = slotControl:GetNamedChild("DUR_Highlight")
		local durability = slotControl:GetNamedChild("DUR_Percentage")
		local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, slotId)
		if charges>maxCharges then
			charges=maxCharges
		end
		if DoesItemHaveDurability(BAG_WORN, slotId) then
			--Equipped armour or shield
			local cond = GetItemCondition(BAG_WORN, slotId)
			highlight:SetColor(SimpleDurability.settings.colour.r, SimpleDurability.settings.colour.g, SimpleDurability.settings.colour.b, SimpleDurability.settings.colour.a)
			durability:SetText(cond.."%")
			
			if SimpleDurability.settings.show_durability then
				if SimpleDurability.settings.show_always then
					durability:SetHidden(false)
				else
					durability:SetHidden(cond > SimpleDurability.settings.threshold)
				end
			else
				durability:SetHidden(true)
			end

			if SimpleDurability.settings.show_highlight then
				highlight:SetHidden(cond > SimpleDurability.settings.threshold)
			else
				highlight:SetHidden(true)
			end
		elseif maxCharges>0 then
			--Weapon with an enchantment, main hand + backup, off hand + backup
			local cond = zo_floor(100/maxCharges*charges)
			highlight:SetColor(SimpleDurability.settings.colour_charges.r, SimpleDurability.settings.colour_charges.g, SimpleDurability.settings.colour_charges.b, SimpleDurability.settings.colour_charges.a)
			durability:SetText(cond.."%")

			if SimpleDurability.settings.show_charges_percent then
				if SimpleDurability.settings.show_charges_always then
					durability:SetHidden(false)
				else
					durability:SetHidden(cond > SimpleDurability.settings.threshold_charges)
				end
			else
				durability:SetHidden(true)
			end

			if SimpleDurability.settings.show_charges_highlight then
				highlight:SetHidden(cond > SimpleDurability.settings.threshold_charges)
			else
				highlight:SetHidden(true)
			end
		else
			--No item equipped
			highlight:SetHidden(true)
			durability:SetHidden(true)
		end
	end
end

local function CreateHighlights()
	for slotId, slotControl in pairs(slots) do
		local control = CreateControl(slotControl:GetName().."DUR_Highlight", slotControl, CT_TEXTURE)
		control:SetHidden(true)
		control:SetTexture(SimpleDurability.highlight)
		control:SetAnchor(TOPLEFT, slotControl, TOPLEFT, -5, -5)
		control:SetAnchor(BOTTOMRIGHT, slotControl, BOTTOMRIGHT, 5, 5)
		control:SetColor(SimpleDurability.settings.colour.r, SimpleDurability.settings.colour.g, SimpleDurability.settings.colour.b, SimpleDurability.settings.colour.a)
		control:SetDrawLevel(1)
		
		control = CreateControl(slotControl:GetName().."DUR_Percentage", slotControl, CT_LABEL)
		control:SetHidden(true)
		control:SetAnchor(TOPLEFT, slotControl, BOTTOMLEFT, 0, -15)
		control:SetAnchor(BOTTOMRIGHT, slotControl, BOTTOMRIGHT, 0, 0)
		control:SetFont("ZoFontGameSmall")
		control:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	end
end

local function WorstCondition()
	local worst = 100
	for slotId, slotControl in pairs(slots) do
		if DoesItemHaveDurability(BAG_WORN, slotId) then
			local cond = GetItemCondition(BAG_WORN, slotId)
			if cond < worst then
				worst = cond
			end
		end
	end
	return worst
end

local function Repair()
	local worst = WorstCondition()
	local dialogName = "REPAIR_ALL"
	if SimpleDurability.settings.repair and worst <= SimpleDurability.settings.repair_percent then
		local cost = GetRepairAllCost()
		if CanStoreRepair() and cost > 0 then
			if IsInGamepadPreferredMode() then
				ZO_Dialogs_ShowGamepadDialog(dialogName, {cost = cost})
			else
				ZO_Dialogs_ShowDialog(dialogName, {cost = cost})
			end
		end
	end
end

local function DefaultSettings()
	local defaults = {
		show_durability = true,
		show_always = false,
		colour = {
			r = 1,
			g = 0,
			b = 0,
			a = 1
		},
		threshold = 20,
		show_highlight = true,
		show_charges_highlight = true,
		show_charges_percent = true,
		show_charges_always = false,
		colour_charges = {
			r = 1,
			g = 0,
			b = 0,
			a = 1
		},
		threshold_charges = 10,
		repair = false,
		repair_percent = 20
	}
	return defaults
end

local function CreateSettingsMenu()
	if not LibAddonMenu2 then return end

	local defaults = DefaultSettings()
	local OptionsName = ADDON_NAME.."Options"
	local panelData = {
		type = "panel",
		name = DISPLAY_NAME,
		displayName = zo_strformat("|cff8800<<1>>|r", DISPLAY_NAME),
		author = "Weolo",
		version = ADDON_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
		slashCommand = "/simpledurability",
		website = "https://www.esoui.com/downloads/info1165-SimpleDurability.html",
		feedback = "https://www.esoui.com/downloads/info1165-SimpleDurability.html#comments"
	}
	local panel = LibAddonMenu2:RegisterAddonPanel(OptionsName, panelData)
	
	local optionsData = {
		{
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", GetString(DUR_HEADING1))
		},{
			type = "slider",
			name = DUR_THRESHOLD,
			tooltip = DUR_THRESHOLD_TT,
			min = 0,
			max = 100,
			step = 10,
			getFunc = function() return SimpleDurability.settings.threshold end,
			setFunc = function(value)
				SimpleDurability.settings.threshold = value
				UpdateHighlights()
			end,
			default = defaults.threshold
		},{
			type = "checkbox",
			name = DUR_SHOW_HIGHLIGHT,
			tooltip = DUR_SHOW_HIGHLIGHT_TT,
			getFunc = function() return SimpleDurability.settings.show_highlight end,
			setFunc = function(value)
				SimpleDurability.settings.show_highlight = value
				UpdateHighlights()
			end,
			default = defaults.show_highlight
		},{
			type = "colorpicker",
			name = DUR_COLOUR,
			tooltip = DUR_COLOUR_TT,
			getFunc = function()
				return SimpleDurability.settings.colour.r, SimpleDurability.settings.colour.g, SimpleDurability.settings.colour.b, SimpleDurability.settings.colour.a
			end,
			setFunc = function(r,g,b,a)
				SimpleDurability.settings.colour = {r=r,g=g,b=b,a=a}
				UpdateHighlights()
			end,
			disabled = function() return not SimpleDurability.settings.show_highlight end,
			default = defaults.colour
		},{
			type = "checkbox",
			name = DUR_SHOW_DURABILITY,
			tooltip = DUR_SHOW_DURABILITY_TT,
			getFunc = function() return SimpleDurability.settings.show_durability end,
			setFunc = function(value)
				SimpleDurability.settings.show_durability = value
				UpdateHighlights()
			end,
			default = defaults.show_durability
		},{
			type = "checkbox",
			name = DUR_SHOW_ALWAYS,
			tooltip = DUR_SHOW_ALWAYS_TT,
			getFunc = function() return SimpleDurability.settings.show_always end,
			setFunc = function(value)
				SimpleDurability.settings.show_always = value
				UpdateHighlights()
			end,
			disabled = function() return not SimpleDurability.settings.show_durability end,
			default = defaults.show_always
		},{
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", GetString(DUR_HEADING2))
		},{
			type = "slider",
			name = DUR_THRESHOLD,
			tooltip = DUR_THRESHOLD_TT,
			min = 0,
			max = 100,
			step = 10,
			getFunc = function() return SimpleDurability.settings.threshold_charges end,
			setFunc = function(value)
				SimpleDurability.settings.threshold_charges = value
				UpdateHighlights()
			end,
			default = defaults.threshold_charges
		},{
			type = "checkbox",
			name = DUR_SHOW_HIGHLIGHT,
			tooltip = DUR_SHOW_HIGHLIGHT_TT,
			getFunc = function() return SimpleDurability.settings.show_charges_highlight end,
			setFunc = function(value)
				SimpleDurability.settings.show_charges_highlight = value
				UpdateHighlights()
			end,
			default = defaults.show_charges_highlight
		},{
			type = "colorpicker",
			name = DUR_COLOUR,
			tooltip = DUR_COLOUR_TT,
			getFunc = function()
				return SimpleDurability.settings.colour_charges.r, SimpleDurability.settings.colour_charges.g, SimpleDurability.settings.colour_charges.b, SimpleDurability.settings.colour_charges.a
			end,
			setFunc = function(r,g,b,a)
				SimpleDurability.settings.colour_charges = {r=r,g=g,b=b,a=a}
				UpdateHighlights()
			end,
			disabled = function() return not SimpleDurability.settings.show_charges_highlight end,
			default = defaults.colour_charges
		},{
			type = "checkbox",
			name = DUR_SHOW_DURABILITY,
			tooltip = DUR_SHOW_DURABILITY_TT,
			getFunc = function() return SimpleDurability.settings.show_charges_percent end,
			setFunc = function(value)
				SimpleDurability.settings.show_charges_percent = value
				UpdateHighlights()
			end,
			default = defaults.show_charges_percent
		},{
			type = "checkbox",
			name = DUR_SHOW_ALWAYS,
			tooltip = DUR_SHOW_CHARGE_ALWAYS_TT,
			getFunc = function() return SimpleDurability.settings.show_charges_always end,
			setFunc = function(value)
				SimpleDurability.settings.show_charges_always = value
				UpdateHighlights()
			end,
			disabled = function() return not SimpleDurability.settings.show_charges_percent end,
			default = defaults.show_charges_always
		},{
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", GetString(DUR_HEADING3))
		},{
			type = "checkbox",
			name = DUR_REPAIR,
			getFunc = function() return SimpleDurability.settings.repair end,
			setFunc = function(value) SimpleDurability.settings.repair = value end,
			default = defaults.repair
		},{
			type = "slider",
			name = DUR_REPAIR_PER,
			tooltip = DUR_REPAIR_PER_TT,
			min = 0,
			max = 100,
			step = 10,
			getFunc = function() return SimpleDurability.settings.repair_percent end,
			setFunc = function(value) SimpleDurability.settings.repair_percent = value end,
			disabled = function() return not SimpleDurability.settings.repair end,
			default = defaults.repair_percent
		}
	}
	
	LibAddonMenu2:RegisterOptionControls(OptionsName, optionsData)
end

local function OnActiveWeaponPairChanged(eventCode, activeWeaponPair, locked)
	UpdateHighlights()
end
local function OnInventoryUpdated(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
	if bagId == BAG_WORN then
		UpdateHighlights()
	end
end

local function OnPlayerActivated()
	if SimpleDurability.activated then return end
	SimpleDurability.activated = true
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
	CreateSettingsMenu()
	CreateHighlights()
	UpdateHighlights()
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdated)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, OnActiveWeaponPairChanged)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_STORE, Repair)
end

local function OnLoaded(eventType, addonName)
	if addonName ~= ADDON_NAME then return end
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	
	SimpleDurability.settings = {}
	SimpleDurability.settings = ZO_SavedVars:NewAccountWide("SimpleDurabilitySettings", 1, nil, DefaultSettings())
	SimpleDurability.activated = false
	SimpleDurability.highlight = ADDON_NAME.."/highlight.dds"
	
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)