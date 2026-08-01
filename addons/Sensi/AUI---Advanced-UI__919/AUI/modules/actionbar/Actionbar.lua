AUI.Actionbar = {}

local gIsLoaded = false

local gIsPreviewShowed = false
local gKeybindBGControl = nil
local gZO_acionBarControl = ZO_ActionBar1
local gZO_actionBargKeybindBGControl = ZO_ActionBar1:GetNamedChild("KeybindBG")
local gZO_weaponSwapControl = ZO_ActionBar1:GetNamedChild("WeaponSwap")

function AUI.Actionbar.DoesShow()
	return not gZO_acionBarControl:IsHidden()
end

function AUI.Actionbar.ShowPreview()
	if not gIsLoaded then
		return
	end

	gIsPreviewShowed= true

	ACTION_BAR_FRAGMENT:SetHiddenForReason("ShouldntShow", true)
	gZO_acionBarControl:SetHidden(false)
	
	AUI.Actionbar.AbilityButtons.ShowPreview()
end

function AUI.Actionbar.HidePreview()
	if not gIsLoaded then
		return
	end

	gIsPreviewShowed= false

	ACTION_BAR_FRAGMENT:SetHiddenForReason("ShouldntShow", false)
	gZO_acionBarControl:SetHidden(true)
	
	AUI.Actionbar.AbilityButtons.HidePreview()
end

function AUI.Actionbar.OnSwapActionBar(activeHotbarCategory)
	if not gIsLoaded then
		return
	end

	AUI.Actionbar.AbilityButtons.OnSwapActionBar(activeHotbarCategory)	
	AUI.Actionbar.UltimateButtons.OnSwapActionBar()
end
	
function AUI.Actionbar.Update()	
	if not gIsLoaded then
		return
	end

	AUI.Actionbar.AbilityButtons.Update()
	AUI.Actionbar.UltimateButtons.Update()
end
	
function AUI.Actionbar.UpdateUI()
	if not gIsLoaded then
		return
	end

	AUI.Actionbar.QuickButtons.UpdateUI()	
	AUI.Actionbar.AbilityButtons.UpdateUI()	
	AUI.Actionbar.UltimateButtons.UpdateUI()	

	if not IsInGamepadPreferredMode() then	
		gKeybindBGControl:ClearAnchors()
		gKeybindBGControl:SetAnchor(BOTTOMLEFT, AUI.Actionbar.QuickButtons.GetMainQuickSlot(), BOTTOMRIGHT, -50, 0)	
		
		if AUI.Actionbar.ShouldShowCompanionUltimateButton() then
			if AUI.Settings.Actionbar.ultimate_slots_enabled then
				if AUI.Settings.Actionbar.useCompanionDefaultPos then
					gKeybindBGControl:SetAnchor(BOTTOMRIGHT, AUI.Actionbar.UltimateButtons.GetUltimateButton(), BOTTOM, 24, 34)
				else
					gKeybindBGControl:SetAnchor(BOTTOMRIGHT, AUI.Actionbar.UltimateButtons.GetCompanionUltimateButton(), BOTTOM, 24, 34)		
				end				
			else
				gKeybindBGControl:SetAnchor(BOTTOMRIGHT, AUI.Actionbar.UltimateButtons.GetUltimateButton(), BOTTOM, 24, 34)	
			end
		else
			gKeybindBGControl:SetAnchor(BOTTOMRIGHT, AUI.Actionbar.UltimateButtons.GetUltimateButton(), BOTTOM, 24, 34)		
		end			
		
		if AUI.Settings.Actionbar.show_background then
			gKeybindBGControl:SetHidden(false)
		else
			gKeybindBGControl:SetHidden(true)
		end
	else	
		gKeybindBGControl:SetHidden(true)		
	end
		
	AUI.Actionbar.Update()
end

function AUI.Actionbar.OnPowerUpdate(_unitTag, _powerIndex, _powerType, _powerValue, _powerMax, _powerEffectiveMax)
	if not gIsLoaded then
		return
	end

	AUI.Actionbar.UltimateButtons.OnPowerUpdate(_unitTag, _powerIndex, _powerType, _powerValue, _powerMax, _powerEffectiveMax)	
end

function AUI.Actionbar.OnEffectChanged(_changeType, _effectSlot, _effectName, _unitTag, _beginTime, _endTime, _stackCount, _iconName, _buffType, _effectType, _abilityType, _statusEffectType, _unitName, _unitId, _abilityId, _combatUnitType, _castByPlayer, _procInfoData)
	if not gIsLoaded then
		return
	end
	
	AUI.Actionbar.AbilityButtons.OnEffectChanged(_changeType, _effectSlot, _effectName, _unitTag, _beginTime, _endTime, _stackCount, _iconName, _buffType, _effectType, _abilityType, _statusEffectType, _unitName, _unitId, _abilityId, _combatUnitType, _castByPlayer, _procInfoData)
end

function AUI.Actionbar.OnGamepadPreferredModeChanged(_gamepadPreferred)
	zo_callLater(function() AUI.Actionbar.UpdateUI() end, 200)
end

function AUI.Actionbar.OnAllHotbarsUpdated()
	if not gIsLoaded then
		return
	end	

	AUI.Actionbar.Update()
end

function AUI.Actionbar.OnActionUpdateCooldowns()
	AUI.Actionbar.QuickButtons.UpdateCooldowns()
end

function AUI.Actionbar.OnActionSlotUpdate(_slotId)
	if not gIsLoaded then
		return
	end

	AUI.Actionbar.QuickButtons.OnSlotUpdate(_slotId)
end

function AUI.Actionbar.OnActionSlotsFullUpdate(_isHotbarSwap)
	if not gIsLoaded then
		return
	end

	AUI.Actionbar.AbilityButtons.OnActionSlotsFullUpdate(_isHotbarSwap)
	AUI.Actionbar.QuickButtons.OnFullUpdate(_isHotbarSwap)	
end

function AUI.Actionbar.OnActionSlotEffectUpdated(hotbarCategory, actionSlotIndex)
	if not gIsLoaded then
		return
	end

	AUI.Actionbar.AbilityButtons.OnActionSlotEffectUpdated(hotbarCategory, actionSlotIndex)
end

function AUI.Actionbar.OnActionSlotEffectsCleared()
	if not gIsLoaded then
		return
	end

	AUI.Actionbar.AbilityButtons.OnActionSlotEffectsCleared()
end

function AUI.Actionbar.OnInterfaceSettingChanged(settingSystemType, settingId)
	if not gIsLoaded then
		return
	end

	AUI.Actionbar.AbilityButtons.OnInterfaceSettingChanged(settingSystemType, settingId)
end

function AUI.Actionbar.OnPlayerActivated()
	if not gIsLoaded then
		return
	end

	AUI.Actionbar.AbilityButtons.OnPlayerActivated()
end

function AUI.Actionbar.DisableDefaultUltiTextSetting()
	SetSetting(SETTING_TYPE_UI, UI_SETTING_ULTIMATE_NUMBER, "false")
end

function AUI.Actionbar.ShouldShowCompanionUltimateButton()
    return DoesUnitExist("companion") and HasActiveCompanion()
end

function AUI.Actionbar.Load()
	if gIsLoaded then
		return
	end
	
	gIsLoaded = true	

	AUI.Actionbar.LoadSettings()
	
	gKeybindBGControl = CreateControlFromVirtual(gZO_acionBarControl:GetName() .. "_AUI_Keybind_bg", gZO_acionBarControl, "AUI_Actionbar_KeybindBG")
	gKeybindBGControl:SetHeight(44)
	gKeybindBGControl:SetEdgeTexture("/EsoUi/art/chatwindow/chat_bg_edge.dds", 256, 128, 22)
	gKeybindBGControl:SetCenterColor(1, 1, 1, 0)
	
	gZO_actionBargKeybindBGControl:SetHidden(true)
	
	if not AUI.FrameMover.IsEnabled() then	
		ZO_HUDEquipmentStatus:ClearAnchors()
		ZO_HUDEquipmentStatus:SetAnchor(LEFT, ZO_ActionBar1, RIGHT, 60)
	end			
		
	if AUI.Settings.Actionbar.quick_slots_enabled then
		AUI.Actionbar.QuickButtons.Load()
	end	
	
	if AUI.Settings.Actionbar.ability_cooldowns_enabled then
		AUI.Actionbar.AbilityButtons.Load()	
	end	
	
	if AUI.Settings.Actionbar.ultimate_slots_enabled then
		AUI.Actionbar.UltimateButtons.Load()	
	end
	
	AUI.Actionbar.UpdateUI()	

	if AUI.Settings.Actionbar.ability_cooldowns_enabled then
		if AUI.Settings.Actionbar.show_text then
			SetSetting(SETTING_TYPE_UI, UI_SETTING_ULTIMATE_NUMBER, "false")

			EVENT_MANAGER:RegisterForEvent("AUI_DEFAULT_ULTI_SETTING_CHANGED", EVENT_INTERFACE_SETTING_CHANGED, function(_, settingType, settingId)
				if settingType == SETTING_TYPE_UI and settingId == UI_SETTING_ULTIMATE_NUMBER and AUI.Settings.Actionbar.show_text then
					if GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_ULTIMATE_NUMBER) then
						AUI.Actionbar.DisableDefaultUltiTextSetting()
					end
				end
			end)
		end
	end	
end