local WEAPON_CHARGE_WARNER_SCENE_FRAGMENT = nil
local WEAPON_ENCHANT_WARNER_PERCENT_TEXT_NORMAL_COLOR = "#2cce00"
local WEAPON_ENCHANT_WARNER_PERCENT_TEXT_LOW_COLOR = "#dec72c"
local WEAPON_ENCHANT_WARNER_PERCENT_TEXT_EMPTY_COLOR = "#e41515"

local g_isInit = false
local weaponWarnerControls = {}
local weaponWarnerControlCount = 0
local isPreviewShowing = false

local function AUI_UpdateWeaponChargeWarner_OnMouseDown(_eventCode, _button, _ctrl, _alt, _shift)
	if _button == 1 and not AUI.Settings.Combat.lock_windows then
		AUI_WeaponChargeWarner:SetMovable(true)
		AUI_WeaponChargeWarner:StartMoving()
	end
end

local function AUI_UpdateWeaponChargeWarner_OnMouseUp(_eventCode, _button, _ctrl, _alt, _shift)
	AUI_WeaponChargeWarner:SetMovable(false)	
	
	if _button == 1 and not AUI.Settings.Combat.lock_windows then
		_, AUI.Settings.Combat.weapon_charge_warner_anchor.point, _, AUI.Settings.Combat.weapon_charge_warner_anchor.relativePoint, AUI.Settings.Combat.weapon_charge_warner_anchor.offsetX, AUI.Settings.Combat.weapon_charge_warner_anchor.offsetY = AUI_WeaponChargeWarner:GetAnchor()
	end
end

local function GetWeaponEnchantColor(_percent)
	local color = WEAPON_ENCHANT_WARNER_PERCENT_TEXT_NORMAL_COLOR
	if _percent <= 5 then
		color = WEAPON_ENCHANT_WARNER_PERCENT_TEXT_EMPTY_COLOR
	elseif _percent <= 25 then
		color = WEAPON_ENCHANT_WARNER_PERCENT_TEXT_LOW_COLOR
	end

	return AUI.Color.ConvertHexToRGBA(color)
end

local function CreateNewWeaponWarnerControl(_slotId)
	local weaponWarnerControl = CreateControlFromVirtual("AUI_WeaponChargeWarnerControl" .. _slotId, AUI_WeaponChargeWarner, "AUI_WeaponChargeWarnerControl", _slotId)
	
	local iconContainerControl = GetControl(weaponWarnerControl, "_IconContainer")
	local textControl = GetControl(weaponWarnerControl, "_Text")
	local iconTextureControl = GetControl(iconContainerControl, "_Icon")
	local iconTextControl = GetControl(iconTextureControl, "_Text")			
	
	textControl:SetFont("$(BOLD_FONT)|" ..  18 .. "|" .. "thick-outline")
	iconTextControl:SetFont("$(MEDIUM_FONT)|" ..  14 .. "|" .. "outline")

	weaponWarnerControls[_slotId] = weaponWarnerControl
	
	return weaponWarnerControl
end

function AUI.Combat.WeaponChargeWarner.SetToDefaultPosition(defaultSettings)
	if not g_isInit then
		return
	end

	AUI.Settings.Combat.weapon_charge_warner_anchor = defaultSettings.weapon_charge_warner_anchor

	AUI.Combat.WeaponChargeWarner.UpdateUI()
end

function AUI.Combat.WeaponChargeWarner.Update(_slotId, _repos)
	if not g_isInit then
		return
	end

	if  _slotId ~= EQUIP_SLOT_MAIN_HAND and _slotId ~= EQUIP_SLOT_OFF_HAND and _slotId ~= EQUIP_SLOT_BACKUP_MAIN and _slotId ~= EQUIP_SLOT_BACKUP_OFF then
		return
	end

	local isItemChargeable = IsItemChargeable(BAG_WORN, _slotId)
	if isItemChargeable or isPreviewShowing then
		local itemLink = GetItemLink(BAG_WORN, _slotId)				
		local charges = GetItemLinkNumEnchantCharges(itemLink)
		local maxCharges = GetItemLinkMaxEnchantCharges(itemLink)			
		local weaponChargePercent = AUI.Math.Round((charges / maxCharges) * 100)
		local visible_threshold = AUI.Settings.Combat.weapon_charge_warner_visible_threshold
		
		if weaponChargePercent <= visible_threshold or isPreviewShowing then
			local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyle, quality = GetItemInfo(BAG_WORN, _slotId)			
			local itemName = GetItemName(BAG_WORN, _slotId) 

			local weaponWarnerControl = weaponWarnerControls[_slotId]
			if not weaponWarnerControls[_slotId] then
				weaponWarnerControl = CreateNewWeaponWarnerControl(_slotId)
			end	
			
			local iconContainerControl = GetControl(weaponWarnerControl, "_IconContainer")
			local textControl = GetControl(weaponWarnerControl, "_Text")
			local iconTextureControl = GetControl(iconContainerControl, "_Icon")
			local iconTextControl = GetControl(iconTextureControl, "_Text")
			
			if isPreviewShowing then
				itemName = "Weapon " .. weaponWarnerControlCount + 1
				
				if _slotId == EQUIP_SLOT_MAIN_HAND then			
					weaponChargePercent = 90
					icon = "esoui/art/icons/gear_orc_1hsword_d.dds"
					quality = 1
				elseif _slotId == EQUIP_SLOT_OFF_HAND then
					weaponChargePercent = 20
					icon = "esoui/art/icons/gear_imperialdaedric_1haxe_c.dds"
					quality = 1
				elseif _slotId == EQUIP_SLOT_BACKUP_MAIN then
					weaponChargePercent = 4
					icon = "esoui/art/icons/gear_imperialdaedric_dagger__c.dds"
					quality = 1
				else
					weaponChargePercent = 0	
					icon = "esoui/art/icons/gear_imperialerialdaedric_1hsword_c.dds"	
					quality = 1					
				end
			end
					
			iconTextureControl:SetTexture(icon)
			
			local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)
			textControl:SetColor(r, g, b, 1)
			
			textControl:SetText(zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName))
			iconTextControl:SetText(weaponChargePercent .. "%")	
			
			if _repos then
				weaponWarnerControl:ClearAnchors()
				
				local offsetY = 60 * weaponWarnerControlCount
				
				if weaponWarnerControlCount > 0 then
					weaponWarnerControl:SetAnchor(TOPLEFT, AUI_WeaponChargeWarner, TOPLEFT, 0, offsetY)
				else
					weaponWarnerControl:SetAnchor(TOPLEFT, AUI_WeaponChargeWarner, TOPLEFT, 0, 0)	
				end
				
				iconContainerControl:SetDimensions(50, 50)
				
				weaponWarnerControlCount = weaponWarnerControlCount + 1
			end
			
			local weaponEnchantColor = GetWeaponEnchantColor(weaponChargePercent)
			iconTextControl:SetColor(weaponEnchantColor:UnpackRGBA())
			
			weaponWarnerControl:SetHidden(false)		
		else
			if weaponWarnerControls[_slotId] then
				weaponWarnerControls[_slotId]:SetHidden(true)
			end			
		end
	else
		if weaponWarnerControls[_slotId] then
			weaponWarnerControls[_slotId]:SetHidden(true)
		end	
	end
end

function AUI.Combat.WeaponChargeWarner.UpdateAll()
	if not g_isInit then
		return
	end

	weaponWarnerControlCount = 0

	AUI.Combat.WeaponChargeWarner.Update(EQUIP_SLOT_MAIN_HAND, true)
	AUI.Combat.WeaponChargeWarner.Update(EQUIP_SLOT_OFF_HAND, true)
	AUI.Combat.WeaponChargeWarner.Update(EQUIP_SLOT_BACKUP_MAIN, true)
	AUI.Combat.WeaponChargeWarner.Update(EQUIP_SLOT_BACKUP_OFF, true)
end

function AUI.Combat.WeaponChargeWarner.UpdateUI()
	if not g_isInit then
		return
	end

	AUI_WeaponChargeWarner:ClearAnchors()
	AUI_WeaponChargeWarner:SetAnchor(AUI.Settings.Combat.weapon_charge_warner_anchor.point, GuiRoot, AUI.Settings.Combat.weapon_charge_warner_anchor.relativePoint, AUI.Settings.Combat.weapon_charge_warner_anchor.offsetX, AUI.Settings.Combat.weapon_charge_warner_anchor.offsetY)			
	AUI_WeaponChargeWarner:SetDimensions(200, 200)
end

function AUI.Combat.WeaponChargeWarner.ShowPreview()
	if not g_isInit then
		return
	end

	isPreviewShowing = true

	AUI_WeaponChargeWarner:SetHidden(false)
	
	AUI.Combat.WeaponChargeWarner.UpdateAll()
end

function AUI.Combat.WeaponChargeWarner.HidePreview()
	if not g_isInit then
		return
	end

	isPreviewShowing = false

	AUI_WeaponChargeWarner:SetHidden(true)
	
	AUI.Combat.WeaponChargeWarner.UpdateAll()
end

function AUI.Combat.WeaponChargeWarner.Load()
	if g_isInit then
		return
	end

	g_isInit = true	

	WEAPON_CHARGE_WARNER_SCENE_FRAGMENT = ZO_SimpleSceneFragment:New(AUI_WeaponChargeWarner)	
	WEAPON_CHARGE_WARNER_SCENE_FRAGMENT.hiddenReasons = ZO_HiddenReasons:New()		
    WEAPON_CHARGE_WARNER_SCENE_FRAGMENT:SetConditional(function()
        return not WEAPON_CHARGE_WARNER_SCENE_FRAGMENT.hiddenReasons:IsHidden()
    end)		

	HUD_SCENE:AddFragment(WEAPON_CHARGE_WARNER_SCENE_FRAGMENT)
	HUD_UI_SCENE:AddFragment(WEAPON_CHARGE_WARNER_SCENE_FRAGMENT)
	SIEGE_BAR_SCENE:AddFragment(WEAPON_CHARGE_WARNER_SCENE_FRAGMENT)
	if SIEGE_BAR_UI_SCENE then
		SIEGE_BAR_UI_SCENE:AddFragment(WEAPON_CHARGE_WARNER_SCENE_FRAGMENT)
	end	

	AUI.Combat.WeaponChargeWarner.UpdateUI()
	
	AUI_WeaponChargeWarner:SetHandler("OnMouseDown", AUI_UpdateWeaponChargeWarner_OnMouseDown)
	AUI_WeaponChargeWarner:SetHandler("OnMouseUp", AUI_UpdateWeaponChargeWarner_OnMouseUp)	
	
	AUI.Combat.WeaponChargeWarner.UpdateAll()
end