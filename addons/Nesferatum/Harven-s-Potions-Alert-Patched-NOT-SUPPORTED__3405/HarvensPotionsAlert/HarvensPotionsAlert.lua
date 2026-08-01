local HarvensPotionsAlert = {
  PotionDialogName = "HARVENSPOTIONSALERT_DIALOG",
  PotionDialog = nil
}

-- not used
--local EMPTY_SLOT = "esoui/art/icons/icon_potion_empty.dds"

local function getFormattedText(text, ...)
    local args = { ... }
    local unpackedString = string.format(text, unpack(args))
    if unpackedString == "" then
        unpackedString = text
    end
    return unpackedString
end


function HarvensPotionsAlert.SetupSlot(slot, slotId)
  local buttonText
  if GetSlotType(slotId, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) ~= ACTION_TYPE_NOTHING and slotId ~= 0 then
    local slotName = GetSlotName(slotId, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    local text = zo_strformat(SI_TOOLTIP_ITEM_NAME, slotName)
    buttonText = text
  else
    buttonText = GetString(SI_GAMEPAD_SELECT_OPTION)
  end
  return buttonText or ""
end

function HarvensPotionsAlert.SaveSlot(control, slotId, slot)
  local slotName = GetSlotName(slotId, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
  local text
  if #slotName > 0 then
    text = zo_strformat(SI_TOOLTIP_ITEM_NAME, slotName)
  else
    text = GetString(SI_GAMEPAD_SELECT_OPTION)
  end
  control:SetText(text)
end

-- Create on demand. Once configured, the dialog is not used frequently.
function HarvensPotionsAlert:CreatePotionDialog()
  if self.PotionDialog == nil then
    self.PotionDialog = WINDOW_MANAGER:CreateControlFromVirtual("HarvensPotionsAlertRadial", nil, "ZO_CustomDialogBase")
    self.PotionDialog.Slots = WINDOW_MANAGER:CreateControlFromVirtual("HarvensPotionsAlertRadialMenu", self.PotionDialog, "ZO_RadialMenuTemplate")
    self.PotionDialog.Accept = WINDOW_MANAGER:CreateControlFromVirtual("HarvensPotionsAlertRadialButton1", self.PotionDialog, "ZO_DialogButton")
    self.PotionDialog.Reset = WINDOW_MANAGER:CreateControlFromVirtual("HarvensPotionsAlertRadialButton2", self.PotionDialog, "ZO_DialogButton")
    self.PotionDialog.Cancel = WINDOW_MANAGER:CreateControlFromVirtual("HarvensPotionsAlertRadialButton3", self.PotionDialog, "ZO_DialogButton")
    self.PotionDialog.Radial = ZO_InteractiveRadialMenuController:New(self.PotionDialog, "ZO_AssignableUtilityWheelSlot_Gamepad_Template", nil, "SelectableItemRadialMenuEntryAnimation", "RadialMenu")
  end
  self.PotionDialog:SetResizeToFitDescendents(false)
  self.PotionDialog.Accept:SetAnchor(CENTER, self.PotionDialog, CENTER, 0, 40)
  self.PotionDialog.Reset:SetAnchor(BOTTOMLEFT, self.PotionDialog, BOTTONLEFT, 24, -24)
  self.PotionDialog.Cancel:SetAnchor(BOTTOMRIGHT, self.PotionDialog, BOTTOMRIGHT, -24, -24)
  self.PotionDialog:SetDimensions(432, 504)
  self.PotionDialog:SetAnchor(CENTER)
  self.PotionDialog:SetHidden(true)
  local bg = self.PotionDialog:GetNamedChild("BG")
  bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 96, 0)
  bg:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
  bg:SetInsets(96, 96, -96, -96)
  bg:SetAlpha(0.5)

  self.PotionDialog:SetHandler("OnHide", function(dialog)
    dialog.Close()
  end)

  local emptyQuickslot = GetString(SI_QUICKSLOTS_EMPTY)
  self.PotionDialog:SetHandler("OnEffectivelyShown", function(control)
    LockCameraRotation(true)
    RETICLE:RequestHidden(true)
    HideMouse(false)

    for i = 1, ACTION_BAR_UTILITY_BAR_SIZE do
      local slotType = GetSlotType(i, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
      if slotType ~= ACTION_TYPE_NOTHING then
        local slotName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetSlotName(i, HOTBAR_CATEGORY_QUICKSLOT_WHEEL))
        local slotTexture = GetSlotTexture(i, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) or ""
        local slotItemDisplayQuality = GetSlotItemDisplayQuality(i, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
		local slotNameData
        if slotItemDisplayQuality then
            local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, slotItemDisplayQuality)
            local colorTable = {r = r, g = g, b = b}
            slotNameData = {slotName, colorTable}
        else
            slotNameData = slotName
        end
        self.PotionDialog.Radial.menu:AddEntry(slotNameData, slotTexture, slotTexture, function() self.PotionDialog.selectedSlot = i end, i)
      else
        self.PotionDialog.Radial.menu:AddEntry("", emptyQuickslot, emptyQuickslot, function() self.PotionDialog.selectedSlot = 0 end, i)
      end
    end

    self.PotionDialog.Radial.menu:Show()
    self.PotionDialog.Radial.isInteracting = true
  end)

  self.PotionDialog.Radial.menu:SetOnClearCallback(function()
    RemoveActionLayerByName(GetString(SI_KEYBINDINGS_LAYER_DIALOG))
    LockCameraRotation(false)
    RETICLE:RequestHidden(false)
	ShowMouse()
  end)

  self.PotionDialog.ShowDialog = function(dialogTitle, setSlot)
    local info =
    {
	  noChoiceCallback = function(dialog)
	    dialog.Radial.menu:FinalizeClear()
		dialog.Close()
	  end,
      customControl = self.PotionDialog,
      title = { text = dialogTitle, },
      buttons =
      {
        {
          control = self.PotionDialog.Accept,
          keybind = "DIALOG_PRIMARY",
          text = SI_DIALOG_ACCEPT,
          callback = function(dialog)
            dialog.Close()
            setSlot(self.PotionDialog.selectedSlot)
          end,
        },
        {
          control = self.PotionDialog.Reset,
          keybind = "DIALOG_SECONDARY",
          text = SI_QUICKSLOTS_EMPTY,
          callback = function(dialog)
            dialog.Close()
            setSlot(0)
          end,
        },
        {
          control = self.PotionDialog.Cancel,
          keybind = "DIALOG_NEGATIVE",
          text = SI_DIALOG_CANCEL,
          callback = function(dialog)
            dialog.Close()
          end,
        }
      }
    }
    ZO_Dialogs_RegisterCustomDialog(HarvensPotionsAlert.PotionDialogName, info)
    PushActionLayerByName(GetString(SI_KEYBINDINGS_LAYER_DIALOG))
    ZO_Dialogs_ShowDialog(HarvensPotionsAlert.PotionDialogName)
  end
  self.PotionDialog.Close = function()
    self.PotionDialog.Radial:StopInteraction()
	
  end
end

function HarvensPotionsAlert:AddSlotOption(settings, powerType, lastControl, attrNames)
	local slotControls
	local slotSelect = {
		type = LibHarvensAddonSettings.ST_BUTTON,
		label = getFormattedText(GetString(HPA_LOW_ATTR_SLOT_LABEL), GetString("SI_ATTRIBUTES", attrNames[powerType]))
	}
	
	local slotName = ""
	if self.sv.slots[powerType].id ~= 0 then
		slotName = GetSlotName(self.sv.slots[powerType].id, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
	end
	
    slotSelect.buttonText = function()
		return self.SetupSlot(slotSelect, self.sv.slots[powerType].id)
	end

	slotSelect.clickHandler = function(control)
		self:CreatePotionDialog()
		
		local function SetSlot1(slot)
			HarvensPotionsAlert.SaveSlot(control, slot, slotSelect)
			self.sv.slots[powerType].id = slot
			slotControls[1]:SetupControl(slotSelect)
		end
		
		self.PotionDialog.ShowDialog(slotSelect.label, SetSlot1)
	end

	local slotTreshold = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = getFormattedText(GetString(HPA_LOW_ATTR_THRESHOLD_LABEL), GetString("SI_ATTRIBUTES", attrNames[powerType])),
		min = 0,
		max = 100,
		step = 1,
		format = "%d",
		unit = "%",
		getFunction = function() return self.sv.slots[powerType].treshold end,
		setFunction = function(value) self.sv.slots[powerType].treshold = value end,
	}
	
	slotControls = settings:AddSettings({slotSelect, slotTreshold})
end

function HarvensPotionsAlert:SetupOptions()
	local settings = LibHarvensAddonSettings:AddAddon("Harven's Potions Alert")
	if not settings then return end
	
	local attrNames = {[POWERTYPE_HEALTH] = 1, [POWERTYPE_MAGICKA] = 2, [POWERTYPE_STAMINA] = 3}
	local lastControl = title
	for k in pairs(self.sv.slots) do
		lastControl = self:AddSlotOption(settings, k, lastControl, attrNames)
	end
	
	local scale = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(HPA_POPUP_SCALE_LABEL),
		min = 0.5,
		max = 8,
		step = 0.1,
		format = "%.1f",
		unit = "",
		getFunction = function() return self.sv.scale end,
		setFunction = function(value) self.sv.scale = value
			HarvensPotionsAlertTopLevel:SetScale(self.sv.scale)
		end,
	}
	
	local testButton = {
		type = LibHarvensAddonSettings.ST_BUTTON,
		buttonText = GetString(HPA_SET_ALERT_POSITION_NAME),
		clickHandler = function(control)
			if self.sv.cooldownAlert then
				HarvensPotionsAlertCooldownAlert:SetHidden(false)
				HarvensPotionsAlertCooldownAlert:SetAlpha(1.0)
				HarvensPotionsAlertCooldownAlert:SetMouseEnabled(true)
				HarvensPotionsAlertCooldownAlertClose:SetMouseEnabled(true)
				HarvensPotionsAlertCooldownAlertClose:SetHidden(false)
			end
			HarvensPotionsAlertTopLevel:SetHidden(false)
			HarvensPotionsAlertTopLevelClose:SetHidden(false)
		end
	}
	
	local cooldownAlertSection = {
		type = LibHarvensAddonSettings.ST_SECTION,
		label = GetString(HPA_COOLDOWN_ALERT_NAME)
	}
	
	local cooldownEnabled = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = GetString(HPA_COOLDOWN_ALERT_ENABLED_LABEL),
		tooltip = GetString(HPA_COOLDOWN_ALERT_ENABLED_TOOLTIP),
		getFunction = function() return self.sv.cooldownAlert end,
		setFunction = function(state) self.sv.cooldownAlert = state end
	}
	
	local cooldownFont = {
		type = LibHarvensAddonSettings.ST_EDIT,
		label = GetString(HPA_COOLDOWN_ALERT_FONT_LABEL),
		getFunction = function() return self.sv.cooldownAlertFont end,
		setFunction = function(value)
			self.sv.cooldownAlertFont = value
			HarvensPotionsAlertCooldownAlertLabel:SetFont(value)
		end
	}
	
	local cooldownIconSize = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(HPA_COOLDOWN_ALERT_ICON_SIZE_LABEL),
		getFunction = function() return self.sv.cooldownAlertIconSize end,
		setFunction = function(value)
			self.sv.cooldownAlertIconSize = value
			HarvensPotionsAlertCooldownAlertLabel:SetText("|t"..value..":"..value..":EsoUI/Art/Icons/icon_missing.dds|t "..GetString(HPA_COOLDOWN_ALERT_READY_TEXT))
		end,
		format = "%d",
		min = 8,
		max = 256,
		step = 2
	}
	
--[[
	local backgroundType = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Background Style",
		items = {{name="Cze cze", data={value=1}}, {name="Ble ble", data={value=2}}},
		getFunction = function() return "Ble ble" end,
		setFunction = function(combobox, name, item) d(name.." "..item.data.value) end,
	}
	
	local backgroundType2 = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = "Background Style 2",
		items = {{name="Nic to nie ma", data={value=3}}, {name="I tu tez nic", data={value=4}}},
		getFunction = function() return "I tu tez nic" end,
		setFunction = function(combobox, name, item) d("-"..name.." "..item.data.value) end,
	}
	settings:AddSettings({backgroundType, backgroundType2})
--]]

	settings:AddSettings({scale, cooldownAlertSection, cooldownEnabled, cooldownFont, cooldownIconSize, testButton})
end

function HarvensPotionsAlert:InitialState()
	HarvensPotionsAlertTopLevel:SetHidden(true)
	HarvensPotionsAlertTopLevel:SetAlpha(1)
end

function HarvensPotionsAlert.PowerUpdate(eventType, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if unitTag ~= "player" 
		or not HarvensPotionsAlert.sv.slots[powerType] 
		or not HarvensPotionsAlert.isInCombat 
		or HarvensPotionsAlert.sv.slots[powerType].treshold == 0
		or HarvensPotionsAlert.sv.slots[powerType].id == 0
		then
			return
	end
	
	local val = 100*powerValue/powerMax
	if val > HarvensPotionsAlert.sv.slots[powerType].treshold then
		return
	end
	
	--check this PowerUpdate priority and if it's lower than previous alert
	--then check if previous alert is still valid
	if HarvensPotionsAlert.alertPowerType ~= POWERTYPE_INVALID and HarvensPotionsAlert.alertPowerType ~= powerType
		and HarvensPotionsAlert.powerTypes[powerType] > HarvensPotionsAlert.powerTypes[HarvensPotionsAlert.alertPowerType] then
		
		local curAlertPower, curAlertMax = GetUnitPower("player", HarvensPotionsAlert.alertPowerType)
		local curAlertVal = 100*curAlertPower/curAlertMax
		if curAlertVal <= HarvensPotionsAlert.sv.slots[HarvensPotionsAlert.alertPowerType].treshold then
			--it's still valid
			return
		end
	end
	
	local slotId = HarvensPotionsAlert.sv.slots[powerType].id
	
	if GetSlotItemCount(slotId, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) == 0 then
		return
	end
	
	local remain, _, global = GetSlotCooldownInfo(slotId, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
	if remain > 0 and not global then
		return
	end
	
	if GetCurrentQuickslot() ~= slotId then
		SetCurrentQuickslot(slotId)
	end
	
	HarvensPotionsAlertTopLevelMsg:SetText(getFormattedText(GetString(HPA_LOW_ATTR_TEXT), GetString("SI_ATTRIBUTES", HarvensPotionsAlert.powerTypes[powerType])))
	HarvensPotionsAlertTopLevelBackdrop:SetEdgeColor(ZO_POWER_BAR_GRADIENT_COLORS[powerType][2]:UnpackRGBA())
	HarvensPotionsAlertTopLevelIcon:SetTexture(GetSlotTexture(slotId, HOTBAR_CATEGORY_QUICKSLOT_WHEEL))
	HarvensPotionsAlertTopLevel:SetHidden(false)
	
	HarvensPotionsAlert.alertPowerType = powerType
	
	HarvensPotionsAlert.alertFadeTimeline:PlayFromStart()
end

function HarvensPotionsAlert.CheckCooldown()
	local slotId = GetCurrentQuickslot()
	local remain, _, global = GetSlotCooldownInfo(slotId, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
	if HarvensPotionsAlert.prevRemain > 0 and not HarvensPotionsAlert.prevGlobal and remain == 0 then
		HarvensPotionsAlertCooldownAlertLabel:SetText("|t"..HarvensPotionsAlert.sv.cooldownAlertIconSize..":"..HarvensPotionsAlert.sv.cooldownAlertIconSize..":"..GetSlotTexture(slotId, HOTBAR_CATEGORY_QUICKSLOT_WHEEL).."|t "..GetString(HPA_COOLDOWN_ALERT_READY_TEXT))
		HarvensPotionsAlertCooldownAlert:SetHidden(false)
		HarvensPotionsAlertCooldownAlert:SetAlpha(1.0)
		HarvensPotionsAlertCooldownAlertClose:SetMouseEnabled(false)
		HarvensPotionsAlertCooldownAlertClose:SetHidden(true)
		HarvensPotionsAlert.cooldownFadeTimeline:PlayFromStart()
	end
	HarvensPotionsAlert.prevRemain = remain
	HarvensPotionsAlert.prevGlobal = global
end

function HarvensPotionsAlert.CombatState(eventType, inCombat)
	HarvensPotionsAlert.isInCombat = inCombat
	
	if inCombat and HarvensPotionsAlert.sv.cooldownAlert then
		HarvensPotionsAlert.prevRemain, _, HarvensPotionsAlert.prevGlobal = GetSlotCooldownInfo(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
		EVENT_MANAGER:RegisterForUpdate( "HarvensPotionsAlertCooldown", 100, HarvensPotionsAlert.CheckCooldown)
	else
		EVENT_MANAGER:UnregisterForUpdate( "HarvensPotionsAlertCooldown")
	end
end

function HarvensPotionsAlert.TestCooldown()
	HarvensPotionsAlert.prevRemain = GetSlotCooldownInfo(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
	EVENT_MANAGER:RegisterForUpdate( "HarvensPotionsAlertCooldown", 100, HarvensPotionsAlert.CheckCooldown)
end

function HarvensPotionsAlert.Initialize(eventType, addonName)
	if addonName ~= "HarvensPotionsAlert" then
		return
	end
	
	HarvensPotionsAlert.powerTypes = {[POWERTYPE_HEALTH] = 1, [POWERTYPE_STAMINA] = 3, [POWERTYPE_MAGICKA] = 2}
	
	defaults = { 
		pos = { point = CENTER, relPoint = CENTER, x=0, y=0 },
		scale = 1.0,
		slots = {},
		pos2 = { point = CENTER, relPoint = CENTER, x=0, y=0 },
		cooldownAlert = true,
		cooldownAlertFont = "$(BOLD_FONT)|36|thick-outline",
		cooldownAlertIconSize = 48
	}
	
	for k,v in pairs(HarvensPotionsAlert.powerTypes) do
		defaults.slots[k] = { id=0, treshold=0 }
	end
	
	HarvensPotionsAlert.sv = ZO_SavedVars:New("HarvensPotionsAlert_SavedVariables", 1, nil, defaults)
	HarvensPotionsAlert.alertPowerType = POWERTYPE_INVALID
	HarvensPotionsAlert.isInCombat = false
	
	HarvensPotionsAlert.cooldownFadeTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensPotionsAlertFade", HarvensPotionsAlertCooldownAlert)
	HarvensPotionsAlertCooldownAlertLabel:SetFont(HarvensPotionsAlert.sv.cooldownAlertFont)
	HarvensPotionsAlertCooldownAlert:SetAnchor(HarvensPotionsAlert.sv.pos2.point, GuiRoot, HarvensPotionsAlert.sv.pos2.relPoint, HarvensPotionsAlert.sv.pos2.x, HarvensPotionsAlert.sv.pos2.y)
	HarvensPotionsAlertCooldownAlert:SetHandler("OnMoveStop", function()
		local _, point, _, relPoint, x, y = HarvensPotionsAlertCooldownAlert:GetAnchor(0)
		HarvensPotionsAlert.sv.pos2 = nil
		HarvensPotionsAlert.sv.pos2 = { point=point, relPoint=relPoint, x=x, y=y }
	end)
	
	HarvensPotionsAlertCooldownAlertClose:SetHandler("OnClicked", function()
		HarvensPotionsAlertCooldownAlertClose:SetMouseEnabled(false)
		HarvensPotionsAlertCooldownAlert:SetAlpha(0)
		HarvensPotionsAlertCooldownAlert:SetMouseEnabled(false)
	end)
	
	HarvensPotionsAlert.alertFadeTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("HarvensPotionsAlertFade", HarvensPotionsAlertTopLevel)
	HarvensPotionsAlert.alertFadeTimeline:SetHandler("OnStop", function(...) HarvensPotionsAlert:InitialState() end)
	
	HarvensPotionsAlertTopLevel:SetAnchor(HarvensPotionsAlert.sv.pos.point, GuiRoot, HarvensPotionsAlert.sv.pos.relPoint, HarvensPotionsAlert.sv.pos.x, HarvensPotionsAlert.sv.pos.y)
	HarvensPotionsAlertTopLevel:SetScale(HarvensPotionsAlert.sv.scale or 1.0)
	HarvensPotionsAlertTopLevel:SetHandler("OnMoveStop", function()
		local _, point, _, relPoint, x, y = HarvensPotionsAlertTopLevel:GetAnchor(0)
		HarvensPotionsAlert.sv.pos = nil
		HarvensPotionsAlert.sv.pos = { point=point, relPoint=relPoint, x=x, y=y }
	end)
	
	HarvensPotionsAlertTopLevel:SetHandler("OnMouseWheel", function(control, delta, ...)
	local scale = HarvensPotionsAlert.sv.scale or 1.0
		if delta > 0 then
			scale = math.min(8.0, scale + 0.05)
		else
			scale = math.max(0.5, scale - 0.05)
		end
		HarvensPotionsAlert.sv.scale = scale
		control:SetScale(scale)
	end)
	
	HarvensPotionsAlertTopLevelClose:SetHandler("OnClicked", function()
		HarvensPotionsAlertTopLevelClose:SetHidden(true)
		HarvensPotionsAlert:InitialState()
	end)

	local keyBind = HarvensPotionsAlertTopLevelKeyBind:GetNamedChild("Bind")
	ZO_Keybindings_RegisterLabelForBindingUpdate(keyBind, "ACTION_BUTTON_9", HIDE_UNBOUND)
	ZO_KeyMarkupLabel_OnNewUserAreaCreated(keyBind, "key", nil, 0, 0, 0, 0, true)
	local bg = keyBind.keyBackdrops[1]
	bg:ClearAnchors()
	bg:SetAnchor(TOPLEFT, keyBind, TOPLEFT, -1, -1)
	bg:SetAnchor(BOTTOMRIGHT, keyBind, BOTTOMRIGHT, 2, 2)

	HarvensPotionsAlert:SetupOptions()
	EVENT_MANAGER:RegisterForEvent("HarvensPotionsAlertCombatState", EVENT_PLAYER_COMBAT_STATE, HarvensPotionsAlert.CombatState)
	EVENT_MANAGER:RegisterForEvent("HarvensPotionsAlertPowerUpdate", EVENT_POWER_UPDATE, HarvensPotionsAlert.PowerUpdate)
	--EVENT_MANAGER:RegisterForEvent("HarvensPotionsAlertPlayerActivated", EVENT_PLAYER_ACTIVATED, HarvensPotionsAlert.TestCooldown)
end

EVENT_MANAGER:RegisterForEvent("HarvensPotionsAlertAddOnLoaded", EVENT_ADD_ON_LOADED, HarvensPotionsAlert.Initialize)