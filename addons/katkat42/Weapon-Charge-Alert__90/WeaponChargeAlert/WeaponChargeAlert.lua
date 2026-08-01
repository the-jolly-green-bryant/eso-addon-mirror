------------------------------------------------------------------
--WeaponChargeAlert.lua
--Author: ingeniousclown
--v1.1.18
--[[
A mod that pops up a little alert window when you're low on weapon
charge for your main and off-hand weapons.
]]
------------------------------------------------------------------


WCASettings = nil
local MAIN_WINDOW = nil

local MAIN_WEAPON = nil
local OFF_WEAPON = nil

local OUTLINE_TEXTURE = "WeaponChargeAlert/assets/gridItem_outline.dds"

local Threshold = {
	NONE = 0,
	HALF = 1,
	LOW = 2,
	EMPTY = 3
}

local lang = GetCVar("Language.2")
if lang ~= "en" then lang = "en" end

---------------------------------------------------------------
--CHAIN
---------------------------------------------------------------

local function CHAIN( object )
	-- Setup the metatable
	local T = {}
	setmetatable( T, { __index = function( self, func )
		
		-- Know when to stop chaining
		if func == "__END" then	return object end
		
		-- Otherwise, add the method to the parent object
		return function( self, ... )
			assert( object[func], func .. " missing in object" )
			object[func]( object, ... )
			return self
		end
	end })
	
	-- Return the metatable
	return T
end

---------------------------------------------------------------
--STUFF
---------------------------------------------------------------

local function SetHiddenAll(control, shouldHide)
	control:SetHidden(shouldHide)
	control:GetNamedChild("_Icon"):SetHidden(shouldHide)
	control:GetNamedChild("_Outline"):SetHidden(shouldHide)
end

local function GetChargeThreshold(control)
	local chargeRatio = control.charges / control.maxCharges

	if(chargeRatio == 0) then
		return Threshold.EMPTY
	elseif(WCASettings:IsLowAlert() and WCASettings:GetLowThreshold() >= chargeRatio) then
		return Threshold.LOW
	elseif(WCASettings:IsFirstAlert() and WCASettings:GetFirstThreshold() >= chargeRatio) then
		return Threshold.HALF
	else
		return Threshold.NONE
	end
end

local function SetAlert(control, threshold)
	local outline = control:GetNamedChild("_Outline")
	SetHiddenAll(control, true)
	control.shouldShow = false
	if(threshold >= Threshold.EMPTY and WCASettings:IsEmptyAlert()) then
		outline:SetColor(WCASettings:GetEmptyColor())
		SetHiddenAll(control, false)
		control.shouldShow = true
		return
	elseif(threshold >= Threshold.LOW and WCASettings:IsLowAlert()) then
		outline:SetColor(WCASettings:GetLowColor())
		SetHiddenAll(control, false)
		control.shouldShow = true
		return
	elseif(threshold >= Threshold.HALF and WCASettings:IsFirstAlert()) then
		outline:SetColor(WCASettings:GetFirstColor())
		SetHiddenAll(control, false)
		control.shouldShow = true
		return
	else
		outline:SetColor(0, 0, 0, 0)
		return 
	end
end

local function UpdateAlert(control)
	if(control and control.chargeable) then
		SetAlert(control, GetChargeThreshold(control))
	else
		control.shouldShow = false
	end
end

local function UpdateAllAlerts()
	if MAIN_WINDOW.FRAGMENT.state == "hidden" then
		MAIN_WEAPON.shouldShow = false
		OFF_WEAPON.shouldShow = false
		return
	end

	UpdateAlert(MAIN_WEAPON)
	UpdateAlert(OFF_WEAPON)

	MAIN_WINDOW:SetHidden((not (MAIN_WEAPON.shouldShow or OFF_WEAPON.shouldShow)) and WCASettings:IsLocked())
	MAIN_WINDOW.BD:SetHidden((not (MAIN_WEAPON.shouldShow or OFF_WEAPON.shouldShow)) and WCASettings:IsLocked())
end

function WeaponChargeAlert_UpdateAllAlerts()
	UpdateAllAlerts()
end

local function SetWeaponSlot(control, slotId)
	control.chargeable = IsItemChargeable(BAG_WORN, slotId)
	if (not control.chargeable or not slotId) then
		control:SetHidden(true)
		return
	end

	local itemLink = GetItemLink(BAG_WORN, slotId)
	local icon, _, _, equipType = GetItemLinkInfo(itemLink)
	local charges = GetItemLinkNumEnchantCharges(itemLink)
	local maxCharges = GetItemLinkMaxEnchantCharges(itemLink)

	control:GetNamedChild("_Icon"):SetTexture(icon)
	control.charges = charges
	control.maxCharges = maxCharges
	control.slotId = slotId

	UpdateAllAlerts()
end

local function ApplyWeaponSet(activeWeaponPair)
	if(activeWeaponPair == 1) then
		SetWeaponSlot(MAIN_WEAPON, EQUIP_SLOT_MAIN_HAND)
		SetWeaponSlot(OFF_WEAPON, EQUIP_SLOT_OFF_HAND)
	else
		SetWeaponSlot(MAIN_WEAPON, EQUIP_SLOT_BACKUP_MAIN)
		SetWeaponSlot(OFF_WEAPON, EQUIP_SLOT_BACKUP_OFF)
	end
end

---------------------------------------------------------------
--BUTTON HANDLER
---------------------------------------------------------------

local function ChargeWeapon(button)
	ZO_Dialogs_ShowDialog("CHARGE_ITEM", {bag = 0, index = button.slotId})
end

function WeaponChargeAlert_ChargeWeapon()
	if not MAIN_WEAPON:IsHidden() then
		-- charge main weapon
		if(GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN) then
			ZO_Dialogs_ShowDialog("CHARGE_ITEM", {bag = BAG_WORN, index = EQUIP_SLOT_MAIN_HAND})
		else
			ZO_Dialogs_ShowDialog("CHARGE_ITEM", {bag= BAG_WORN, index = EQUIP_SLOT_BACKUP_MAIN})
		end
	elseif not OFF_WEAPON:IsHidden() then
		-- charge off weapon
		if(GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN) then
			ZO_Dialogs_ShowDialog("CHARGE_ITEM", {bag = BAG_WORN, index = EQUIP_SLOT_OFF_HAND})
		else
			ZO_Dialogs_ShowDialog("CHARGE_ITEM", {bag = BAG_WORN, index = EQUIP_SLOT_BACKUP_OFF})
		end
	end
end

---------------------------------------------------------------
--EVENT HANDLERS
---------------------------------------------------------------

local function CombatStateChanged(eventCode, inCombat)
	if(not inCombat) then
		UpdateAllAlerts()
	end
end

local function WeaponSetChanged(eventCode, activeWeaponPair, locked)
	ApplyWeaponSet(activeWeaponPair)
end

local function WeaponChanged(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
	if(bagId ~= BAG_WORN) then return end

	if(GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN) then
		if(slotId == EQUIP_SLOT_MAIN_HAND) then
			SetWeaponSlot(MAIN_WEAPON, slotId)
		elseif(slotId == EQUIP_SLOT_OFF_HAND) then
			SetWeaponSlot(OFF_WEAPON, slotId)
		end
	else
		if(slotId == EQUIP_SLOT_BACKUP_MAIN) then
			SetWeaponSlot(MAIN_WEAPON, slotId)
		elseif(slotId == EQUIP_SLOT_BACKUP_OFF) then
			SetWeaponSlot(OFF_WEAPON, slotId)
		end
	end
end

local function ToggleLock(locked)
	WCASettings:SetLocked(locked)
end

local function MakeMainWindow()
	local iconSize = 64
	local betweenSpace = 10
	local indents = {
		vertical = {
			paddingXSingle = 66,
			paddingXDouble = 66,
			paddingYSingle = 76,
			paddingYDouble = 126,
			anchorXSingle = -14,
			anchorXDouble = -14,
			anchorYSingle = -8,
			anchorYDouble = -17,
		},
		horizontal = {
			paddingXSingle = 70,
			paddingXDouble = 100,
			paddingYSingle = 80,
			paddingYDouble = 80,
			anchorXSingle = -14,
			anchorXDouble = -23,
			anchorYSingle = -8,
			anchorYDouble = -8,
		},
	}
	
    MAIN_WINDOW = CHAIN(WINDOW_MANAGER:CreateTopLevelWindow("WeaponChargeAlert_Window"))
		:SetResizeToFitDescendents(true)
		:SetAnchor(CENTER, GuiRoot, TOPLEFT, WCASettings.GetOffsetX(), WCASettings:GetOffsetY())
		:SetClampedToScreen(true)
		:SetMouseEnabled(true)
		:SetMovable(WCASettings:IsLocked())
		:SetHidden(false)
		:SetAlpha(WCASettings:GetAlpha())
		:SetScale(WCASettings:GetScale())
		:SetHandler("OnMoveStop", function(self)
			local x, y = self:GetCenter()
			WCASettings:SetOffsetX(x)
			WCASettings:SetOffsetY(y)
		end )
		:SetResizeToFitPadding(paddingXSingle, paddingYSingle)
	.__END

	WCASettings:SetMainWindow(MAIN_WINDOW)

	MAIN_WINDOW.BD = CHAIN(WINDOW_MANAGER:CreateControl("WeaponChargeAlert_Backdrop", MAIN_WINDOW, CT_TEXTURE))
		:SetAnchorFill(MAIN_WINDOW)
		:SetExcludeFromResizeToFitExtents(true)
		:SetTexture([[/esoui/art/ava/ava_seigecontrols_bg.dds]])
		--:SetTexture([[/esoui/art/buttons/swatchframe_up.dds]])
	.__END

	MAIN_WINDOW.MOVE_SPACER = CHAIN(WINDOW_MANAGER:CreateControl("WeaponChargeAlert_ForceShow", MAIN_WINDOW, CT_CONTROL))
		:SetAnchor(CENTER, MAIN_WINDOW, CENTER, 0, 0)
		:SetDimensions(140, 140)
		:SetHidden(WCASettings:IsLocked())
	.__END

	MAIN_WINDOW.CONTAINER = CHAIN(WINDOW_MANAGER:CreateControl("WeaponChargeAlert_Frame", MAIN_WINDOW, CT_CONTROL))
		:SetAnchor(CENTER, MAIN_WINDOW, CENTER, anchorXSingle, anchorYSingle)
		:SetResizeToFitDescendents(true)
	.__END
	

	MAIN_WEAPON = CHAIN(WINDOW_MANAGER:CreateControl("WeaponChargeAlert_Main_Weapon", MAIN_WINDOW.CONTAINER, CT_BUTTON))
		:SetDimensions(iconSize, iconSize)
		:SetHandler("OnClicked", ChargeWeapon)
		:SetHidden(true)
		:SetHandler("OnEffectivelyShown", function(self)
			local orient = WCASettings:GetOrientation()
			MAIN_WEAPON:ClearAnchors()
			OFF_WEAPON:ClearAnchors()
			if orient == "vertical" then
				MAIN_WEAPON:SetAnchor(TOP, MAIN_WINDOW.CONTAINER, TOP)
				OFF_WEAPON:SetAnchor(TOP, MAIN_WEAPON, BOTTOM, 0, betweenSpace)
			else
				MAIN_WEAPON:SetAnchor(LEFT, MAIN_WINDOW.CONTAINER, LEFT)
				OFF_WEAPON:SetAnchor(LEFT, MAIN_WEAPON, RIGHT, betweenSpace, 0)
			end
			if not OFF_WEAPON:IsHidden() then
				MAIN_WINDOW:SetResizeToFitPadding(indents[orient].paddingXDouble, indents[orient].paddingYDouble)
				MAIN_WINDOW.CONTAINER:ClearAnchors()
				MAIN_WINDOW.CONTAINER:SetAnchor(CENTER, MAIN_WINDOW, CENTER, indents[orient].anchorXDouble, indents[orient].anchorYDouble)
			end
		end)
		:SetHandler("OnEffectivelyHidden", function(self)
			local orient = WCASettings:GetOrientation()
			MAIN_WEAPON:ClearAnchors()
			OFF_WEAPON:ClearAnchors()
			if orient == "vertical" then
				MAIN_WEAPON:SetAnchor(TOP, MAIN_WINDOW.CONTAINER, TOP)
			else
				MAIN_WEAPON:SetAnchor(LEFT, MAIN_WINDOW.CONTAINER, LEFT)
			end
			OFF_WEAPON:SetAnchor(CENTER, MAIN_WINDOW.CONTAINER, CENTER, 0, 0)
			MAIN_WINDOW:SetResizeToFitPadding(indents[orient].paddingXSingle, indents[orient].paddingYSingle)
			MAIN_WINDOW.CONTAINER:ClearAnchors()
			MAIN_WINDOW.CONTAINER:SetAnchor(CENTER, MAIN_WINDOW, CENTER, indents[orient].anchorXSingle, indents[orient].anchorYSingle)
		end)
	.__END
	MAIN_WINDOW.CONTAINER.MAIN_WEAPON = MAIN_WEAPON
	if WCASettings:GetOrientation() == "vertical" then
		MAIN_WEAPON:SetAnchor(TOP, MAIN_WINDOW.CONTAINER, TOP)
	else
		MAIN_WEAPON:SetAnchor(LEFT, MAIN_WINDOW.CONTAINER, LEFT)
	end

	local MAIN_OUTLINE = CHAIN(WINDOW_MANAGER:CreateControl("WeaponChargeAlert_Main_Weapon_Outline", MAIN_WEAPON, CT_TEXTURE))
		:SetAnchor(CENTER, MAIN_WEAPON, CENTER)
		:SetDimensions(iconSize, iconSize)
		:SetTexture(OUTLINE_TEXTURE)
		:SetHidden(true)
	.__END

	local MAIN_ICON = CHAIN(WINDOW_MANAGER:CreateControl("WeaponChargeAlert_Main_Weapon_Icon", MAIN_WEAPON, CT_TEXTURE))
		:SetAnchor(CENTER, MAIN_WEAPON, CENTER)
		:SetDimensions(iconSize, iconSize)
		:SetTexture([[/esoui/art/lorelibrary/lorelibrary_unreadbook_highlight.dds]])
		:SetColor(1, 1, 1, 1)
		:SetHidden(true)
	.__END

	OFF_WEAPON = CHAIN(WINDOW_MANAGER:CreateControl("WeaponChargeAlert_Off_Weapon", MAIN_WINDOW.CONTAINER, CT_BUTTON))
		:SetDimensions(iconSize, iconSize)
		:SetAnchor(CENTER, MAIN_WINDOW.CONTAINER, CENTER, 0, 0)
		:SetHandler("OnClicked", ChargeWeapon)
		:SetHidden(true)
		:SetHandler("OnEffectivelyShown",  function(self)
			local orient = WCASettings:GetOrientation()
			if not MAIN_WEAPON:IsHidden() then
				MAIN_WINDOW:SetResizeToFitPadding(indents[orient].paddingXDouble, indents[orient].paddingYDouble)
				MAIN_WINDOW.CONTAINER:ClearAnchors()
				MAIN_WINDOW.CONTAINER:SetAnchor(CENTER, MAIN_WINDOW, CENTER, indents[orient].anchorXDouble, indents[orient].anchorYDouble)
			end
		end)
		:SetHandler("OnEffectivelyHidden", function(self)
			local orient = WCASettings:GetOrientation()
			MAIN_WINDOW:SetResizeToFitPadding(indents[orient].paddingXSingle, indents[orient].paddingYSingle)
			MAIN_WINDOW.CONTAINER:ClearAnchors()
			MAIN_WINDOW.CONTAINER:SetAnchor(CENTER, MAIN_WINDOW, CENTER, indents[orient].anchorXSingle, indents[orient].anchorYSingle)
		end)
	.__END
	MAIN_WINDOW.CONTAINER.OFF_WEAPON = OFF_WEAPON

	local OFF_OUTLINE = CHAIN(WINDOW_MANAGER:CreateControl("WeaponChargeAlert_Off_Weapon_Outline", OFF_WEAPON, CT_TEXTURE))
		:SetAnchor(CENTER, OFF_WEAPON, CENTER)
		:SetDimensions(iconSize, iconSize)
		:SetTexture(OUTLINE_TEXTURE)
		:SetHidden(true)
	.__END

	local OFF_ICON = CHAIN(WINDOW_MANAGER:CreateControl("WeaponChargeAlert_Off_Weapon_Icon", OFF_WEAPON, CT_TEXTURE))
		:SetAnchor(CENTER, OFF_WEAPON, CENTER)
		:SetDimensions(iconSize, iconSize)
		:SetTexture([[/esoui/art/lorelibrary/lorelibrary_unreadbook_highlight.dds]])
		:SetColor(1, 1, 1, 1)
		:SetHidden(true)
	.__END
	
	MAIN_WINDOW.FRAGMENT = ZO_SimpleSceneFragment:New(MAIN_WINDOW)
	MAIN_WINDOW.FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWING then
			UpdateAllAlerts()
		end
	end)
	local scene = SCENE_MANAGER:GetScene("hudui")
	scene:AddFragment(MAIN_WINDOW.FRAGMENT)
	scene = SCENE_MANAGER:GetScene("hud")
	scene:AddFragment(MAIN_WINDOW.FRAGMENT)
end

local function OnLoad(eventCode, addOnName)
	if(addOnName ~= "WeaponChargeAlert") then
        return
    end

	WCASettings = WeaponChargeAlertSettings:New()
	
	ZO_CreateStringId("SI_BINDING_NAME_CHARGE_WEAPON", WeaponChargeAlert_Strings[lang].KEYBIND_LABEL)

	MakeMainWindow()

	MAIN_WEAPON.shouldShow = false
	OFF_WEAPON.shouldShow = false

	ApplyWeaponSet(GetActiveWeaponPairInfo())

	UpdateAllAlerts()
	ToggleLock(WCASettings:IsLocked())

	SLASH_COMMANDS["/weaponchargealert"] = function(input)
		local args = { string.match(input, "^(%S*)%s*(.-)$") }
		if(args[1] == "lock") then
			ToggleLock(true)
			d("locked")
		elseif(args[1] == "unlock") then
			ToggleLock(false)
			d("unlocked")
		else
			d('"/weaponchargealert" or "/wca"')
			d("lock - locks position and hides the window")
			d("unlock - unlocks position and shows the window")
		end
	end
	if(not SLASH_COMMANDS["/wca"]) then
		SLASH_COMMANDS["/wca"] = SLASH_COMMANDS["/weaponchargealert"]
	end
	EVENT_MANAGER:RegisterForEvent("WeaponChargeAlert_WpnSlotChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, WeaponChanged)
	EVENT_MANAGER:RegisterForEvent("WeaponChargeAlert_CombatStateChanged", EVENT_PLAYER_COMBAT_STATE, CombatStateChanged)
	EVENT_MANAGER:RegisterForEvent("WeaponChargeAlert_WeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, WeaponSetChanged)
end

local function WeaponChargeAlert_Initialized(self)
	EVENT_MANAGER:RegisterForEvent("WeaponChargeAlert_OnLoad", EVENT_ADD_ON_LOADED, OnLoad)
end

function UnhideAllDur()
	SetHiddenAll(MAIN_WEAPON, false)
	SetHiddenAll(OFF_WEAPON, false)
end

WeaponChargeAlert_Initialized()