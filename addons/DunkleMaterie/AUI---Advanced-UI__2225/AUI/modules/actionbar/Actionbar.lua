AUI.Actionbar = {}

local MAX_QUICK_SLOTS = 8

local isLoaded = false
local abilityProcEffects = {}
local quickSlotList = {}
local abilitySlotList ={}
local isGamepadMode = false

local ULTIMATE_SLOT_INDEX = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
local UTILITY_SLOT_INDEX = ACTION_BAR_FIRST_UTILITY_BAR_SLOT + 1

local quickSlotAssignList =
{
	[1] = 12,
	[2] = 11,
	[3] = 10,
	[4] = 9,
	[5] = 16,
	[6] = 15,
	[7] = 14,
	[8] = 13,
}

local acionBarControl = ZO_ActionBar1
local actionBarKeybindBGControl = ZO_ActionBar1KeybindBG
local weaponSwapControl = ZO_ActionBar1WeaponSwap

local quickSlot = ZO_ActionBar_GetButton(UTILITY_SLOT_INDEX)
local actionBarUltimateButton = ZO_ActionBar_GetButton(ULTIMATE_SLOT_INDEX)

local overlayUltimatePercent = nil
local ultimateLabel = nil

local function GetUltimateString(_powerValue)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.GetUltimateString | " .. _powerValue)
	end
	--/DebugMessage--

	if _powerValue == 0 then
		return ""
	end

	return _powerValue
end

local function GetUltimatePercentString(_powerValue)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.GetUltimatePercentString | " .. tostring(_powerValue))
	end
	--/DebugMessage--

	local ultimateSlot = GetSlotAbilityCost(8)

	if ultimateSlot > 0 then 
		local unitPercent = AUI.Math.Round((_powerValue / ultimateSlot) * 100)

		if not AUI.Settings.Actionbar.allow_over_100_percent and unitPercent > 100 then
			unitPercent = 100
		end
		
		return unitPercent .. "%"
	end
	
	return ""
end

local function UpdateUltimateText(_powerValue, _maxValue)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.UpdateUltimateText | " .. tostring(_powerValue) .. "| " .. tostring(_maxValue))
	end
	--/DebugMessage--

	if not _powerValue or not _maxValue then
		_powerValue, _maxValue = GetUnitPower(AUI_PLAYER_UNIT_TAG, POWERTYPE_ULTIMATE)
	end

	local percent = GetUltimatePercentString(_powerValue)
	overlayUltimatePercent:SetText(percent)
	ultimateLabel:SetText(GetUltimateString(_powerValue, _powerMax))		
end

local function GetQuickslot(_slotId)
	return quickSlotList[_slotId]
end

function AUI.Actionbar.SelectQuickSlotButton(_slotId)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.SelectQuickSlotButton | " .. _slotId)
	end
	--/DebugMessage--

	if not isLoaded or QUICKSLOT_FRAGMENT:IsShowing() then
		return
	end

	local item = GetQuickslot(_slotId)
	if item and not QUICKSLOT_FRAGMENT:IsShowing() then
		SetCurrentQuickslot(item.button.slotNum)
	end
	
	AUI.Actionbar.SelectCurrentQuickSlot()
end

local function GetSlotData(_slotId)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.GetSlotData | " .. _slotId)
	end
	--/DebugMessage--

	for slotId, slot in pairs(quickSlotList) do
		local itemSlotId = slot:GetSlot()
		if itemSlotId == _slotId then
			return slotId, slot
		end
	end
end

local function GetSlotIdFromAbilityId(_abilityId)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.GetSlotIdFromAbilityId | " .. _abilityId)
	end
	--/DebugMessage--

	local abilityId = AUI.Ability.GetProcAssignment(_abilityId)

	local abilityName = GetAbilityName(abilityId)

	for slotId, actionButton in pairs(abilitySlotList) do
		local slotName = GetSlotName(slotId)

		if slotName == abilityName then
			return slotId, true	
		end	
	end
	
	return -1, false
end

local function AddProcEffect(_abilityId)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.AddProcEffect | " .. _abilityId)
	end
	--/DebugMessage--

	if SKILLS_FRAGMENT:IsShowing() then
		return
	end

	local slotId = GetSlotIdFromAbilityId(_abilityId)
	if slotId then
		local actionButton = ZO_ActionBar_GetButton(slotId)
		if actionButton then
			actionButton.procBurstTimeline:PlayFromStart()
			actionButton.procLoopTimeline:PlayFromStart()
			actionButton.procBurstTexture:SetHidden(false)
			actionButton.procLoopTexture:SetHidden(false)
		end
		
		abilityProcEffects[slotId] = _abilityId
	end
end

local function RemoveProcEffect(_abilityId)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.RemoveProcEffect | " .. _abilityId)
	end
	--/DebugMessage--

	for slotId, abilityId in pairs(abilityProcEffects) do
		if abilityId == _abilityId then
			local actionButton = ZO_ActionBar_GetButton(slotId)
			if actionButton then
				actionButton.procBurstTimeline:Stop()
				actionButton.procLoopTimeline:Stop()
				actionButton.procBurstTexture:SetHidden(true)
				actionButton.procLoopTexture:SetHidden(true)
			end				
				
			abilityProcEffects[slotId] = nil			
		end
	end	
end

local function UpdateProcAbilitys()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.UpdateProcAbilitys")
	end
	--/DebugMessage--

	for slotId, actionButton in pairs(abilitySlotList) do
		actionButton.procBurstTimeline:Stop()
		actionButton.procLoopTimeline:Stop()
		actionButton.procBurstTexture:SetHidden(true)
		actionButton.procLoopTexture:SetHidden(true)
	end

	if not SKILLS_FRAGMENT:IsShowing() then
		for _, abilityId in pairs(abilityProcEffects) do
			local slotId = GetSlotIdFromAbilityId(abilityId)
			if slotId then
				local actionButton = ZO_ActionBar_GetButton(slotId)
				if actionButton then
					actionButton.procBurstTimeline:PlayFromStart()
					actionButton.procLoopTimeline:PlayFromStart()
					actionButton.procBurstTexture:SetHidden(false)
					actionButton.procLoopTexture:SetHidden(false)
				end
			end
		end	
	end
end

local function IsQuickSlotActive(_slotId)
	if quickSlotList[_slotId] then
		if SKILLS_FRAGMENT:IsShowing() then
			return false
		end	
	
		--DebugMessage--
		if AUI_DEBUG then
			AUI.DebugMessage("AUI.Actionbar.IsQuickSlotActive | " .. _slotId)
		end
		--/DebugMessage--	
	
		local slotCount = AUI.Settings.Actionbar.keyboard_quickslot_count

		if isGamepadMode then
			slotCount = AUI.Settings.Actionbar.gamepad_quickslot_count
		end

		if QUICKSLOT_FRAGMENT:IsShowing() or _slotId and _slotId <= slotCount  then
			return true
		end
	end
	
	return false
end

function AUI.Actionbar.SelectCurrentQuickSlot()
	if not isLoaded or QUICKSLOT_FRAGMENT:IsShowing() then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.SelectCurrentQuickSlot")
	end
	--/DebugMessage--	
	
	for _, button in pairs(quickSlotList) do
		button:Unselect()
	end	
				
	if not QUICKSLOT_FRAGMENT:IsShowing() then
		local currentQuickSlotId = GetCurrentQuickslot()
		local slotId, quickSlotControl = GetSlotData(currentQuickSlotId)
			
		if IsQuickSlotActive(slotId) then	
			quickSlotControl:Select()
		end
	end
end

function AUI.Actionbar.SelectNextQuickSlotButton()
	if not isLoaded or QUICKSLOT_FRAGMENT:IsShowing() then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.SelectNextQuickSlotButton")
	end
	--/DebugMessage--	
	
	local currentQuickSlotId = GetCurrentQuickslot()
	local slotId, quickSlotControl = GetSlotData(currentQuickSlotId)	
	
	slotId = slotId + 1
	
	if not IsQuickSlotActive(slotId) then
		slotId = 1
	end
	
	AUI.Actionbar.SelectQuickSlotButton(slotId)
end

function AUI.Actionbar.SelectPreviosQuickSlotButton()
	if not isLoaded or QUICKSLOT_FRAGMENT:IsShowing() then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.SelectPreviosQuickSlotButton")
	end
	--/DebugMessage--	
	
	local currentQuickSlotId = GetCurrentQuickslot()
	local slotId, quickSlotControl = GetSlotData(currentQuickSlotId)	
	slotId = slotId - 1
	
	if not IsQuickSlotActive(slotId) then
		local slotCount = AUI.Settings.Actionbar.keyboard_quickslot_count
		if isGamepadMode then
			slotCount = AUI.Settings.Actionbar.gamepad_quickslot_count
		end	
	
		slotId = slotCount
	end	
	
	AUI.Actionbar.SelectQuickSlotButton(slotId)
end

function AUI.Actionbar.IsShow()
	return not acionBarControl:IsHidden()
end

function AUI.Actionbar.Lock()
	if not isLoaded then
		return
	end

	ACTION_BAR_FRAGMENT:SetHiddenForReason("ShouldntShow", true)
	acionBarControl:SetHidden(false)
end

function AUI.Actionbar.Unlock()
	if not isLoaded then
		return
	end

	ACTION_BAR_FRAGMENT:SetHiddenForReason("ShouldntShow", false)
	acionBarControl:SetHidden(true)
end

local function CreateQuickSlotButton(physicalSlot, buttonObject)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.CreateQuickSlotButton | " .. physicalSlot)
	end
	--/DebugMessage--

    return buttonObject:New(physicalSlot, ACTION_BUTTON_TYPE_VISIBLE, acionBarControl, "ZO_ActionButton")
end	
	
function AUI.Actionbar.UpdateUI()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.UpdateUI")
	end
	--/DebugMessage--

	if not isLoaded then
		return
	end

	local actionBarWidth = 0
	
	if AUI.Settings.Actionbar.show_ultimate_info then
		ultimateLabel:SetHidden(false)
		overlayUltimatePercent:SetHidden(false)	
	else
		ultimateLabel:SetHidden(true)
		overlayUltimatePercent:SetHidden(true)	
	end		
	
	isGamepadMode = IsInGamepadPreferredMode() 	
	if isGamepadMode then
		quickSlot.slot:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)  		
		weaponSwapControl:SetAnchor(LEFT, quickSlot.slot, RIGHT, 5, 0)	
		
		ultimateLabel:SetFont("$(MEDIUM_FONT)|" .. 20 .. "|" .. "thick-outline")
		overlayUltimatePercent:SetFont("$(MEDIUM_FONT)|" .. 18 .. "|" .. "thick-outline")				
		
		ultimateLabel:ClearAnchors()
		ultimateLabel:SetAnchor(BOTTOM, nil, TOP, 0, -8)
	else
		ultimateLabel:SetFont("$(MEDIUM_FONT)|" .. 14 .. "|" .. "thick-outline")
		overlayUltimatePercent:SetFont("$(MEDIUM_FONT)|" .. 12 .. "|" .. "thick-outline")	

		ultimateLabel:ClearAnchors()
		ultimateLabel:SetAnchor(BOTTOM, nil, TOP, -1, 0)		
	end	
	
	local buttonTemplate = ZO_GetPlatformTemplate("ZO_ActionButton")
	local lastSlot = nil
	local activeQuickSlotCount = 1
	
	for slotId = 1, MAX_QUICK_SLOTS do
		local buttonControl = quickSlotList[slotId]
	
		if not buttonControl then
			local itemSlotId = quickSlotAssignList[slotId]
			
			quickSlotList[slotId] = CreateQuickSlotButton(itemSlotId, AUI_QuickSlotButton)
			buttonControl = quickSlotList[slotId]
		end
		
		local anchorTarget = lastSlot and lastSlot.slot
		local anchorOffsetX = 2
		
		if isGamepadMode then
			anchorOffsetX = 10
		end			
		
		if not lastSlot then
			anchorTarget = quickSlot.slot
			if not isGamepadMode then
				anchorOffsetX = 30
			end
		end			
		
		buttonControl:ApplyStyle(buttonTemplate)
		buttonControl.countText:SetFont("$(MEDIUM_FONT)|" .. 12 .. "|" .. "soft-shadow-thin")
		buttonControl:ApplyAnchor(anchorTarget, anchorOffsetX)
		buttonControl:SetupBounceAnimation()

		if IsQuickSlotActive(slotId) then
			activeQuickSlotCount = activeQuickSlotCount + 1
			buttonControl:HandleSlotChanged()
			buttonControl.slot:SetHidden(false)
			
			actionBarWidth = actionBarWidth + buttonControl.slot:GetWidth() + anchorOffsetX
		else
			buttonControl.slot:SetHidden(true)
		end			
		
		lastSlot = buttonControl
	end

	local isQuckslotFragmentShowing = QUICKSLOT_FRAGMENT:IsShowing()
	
	for slotId, actionButton in pairs(abilitySlotList) do
		actionButton.slot:SetHidden(isQuckslotFragmentShowing)
		
		if not isQuckslotFragmentShowing then
			actionBarWidth = actionBarWidth + actionButton.slot:GetWidth()
		end
	end	

	if not isGamepadMode then
		actionBarUltimateButton.slot:SetHidden(isQuckslotFragmentShowing)
		quickSlot.slot:SetHidden(isQuckslotFragmentShowing)	
		weaponSwapControl:SetHidden(isQuckslotFragmentShowing)		

		if isQuckslotFragmentShowing then	
			acionBarControl:SetDimensions(actionBarWidth, acionBarControl:GetHeight())	
					
			acionBarControl:ClearAnchors()
			acionBarControl:SetAnchor(BOTTOM, ZO_PlayerInventory, BOTTOM, -80, 120)
		else
			local weaponSwapOffsetX = 5
			local ultimateOffsetX = 30
		
			actionBarWidth = actionBarWidth + weaponSwapOffsetX + ultimateOffsetX + actionBarUltimateButton.slot:GetWidth() + weaponSwapControl:GetWidth()
		
			if SKILLS_FRAGMENT:IsShowing() then
				ultimateLabel:SetHidden(true)
				overlayUltimatePercent:SetHidden(true)
			else
				actionBarWidth = actionBarWidth + quickSlot.slot:GetWidth()
			
				acionBarControl:ClearAnchors()
				acionBarControl:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, 0)				
			end		
		
			if activeQuickSlotCount > 1 then	
				weaponSwapControl:ClearAnchors()
				weaponSwapControl:SetAnchor(LEFT, quickSlotList[activeQuickSlotCount - 1].slot, RIGHT, weaponSwapOffsetX)	
				actionBarUltimateButton:ApplyAnchor(abilitySlotList[ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE - 1].slot, ultimateOffsetX)
				actionBarKeybindBGControl:SetWidth(actionBarWidth + 40)
			else
				weaponSwapControl:ClearAnchors()
				weaponSwapControl:SetAnchor(LEFT, quickSlot.slot, RIGHT, weaponSwapOffsetX)		
			end
			
			acionBarControl:SetDimensions(actionBarWidth, acionBarControl:GetHeight())	
		end
	else
		actionBarWidth = actionBarWidth + actionBarUltimateButton.slot:GetWidth() + weaponSwapControl:GetWidth() + 164
	
		if activeQuickSlotCount > 1 then
			weaponSwapControl:ClearAnchors()
			weaponSwapControl:SetAnchor(LEFT, quickSlotList[activeQuickSlotCount - 1].slot, RIGHT, 0)

			actionBarWidth = actionBarWidth + actionBarUltimateButton.slot:GetWidth() + weaponSwapControl:GetWidth()	
		end	

		acionBarControl:SetDimensions(actionBarWidth, acionBarControl:GetHeight())		
	end

	UpdateProcAbilitys()
	UpdateUltimateText()
	AUI.Actionbar.SelectCurrentQuickSlot()	
end

function AUI.Actionbar.OnPowerUpdate(_unitTag, _powerIndex, _powerType, _powerValue, _powerMax, _powerEffectiveMax)
	if not isLoaded or _unitTag ~= AUI_PLAYER_UNIT_TAG then
		return
	end

	if _powerType == POWERTYPE_ULTIMATE then
		UpdateProcAbilitys()
		UpdateUltimateText(_powerValue, _powerMax)
	end
end

function AUI.Actionbar.UpdateCooldowns()
	if not isLoaded or QUICKSLOT_FRAGMENT:IsShowing() then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.UpdateCooldowns")
	end
	--/DebugMessage--		
	
	for slotId, buttonControl in pairs(quickSlotList) do
		if IsQuickSlotActive(slotId) then	
			buttonControl:UpdateCooldown()
		end
	end 	
end

function AUI.Actionbar.UpdateSlots(_slotId)
	if not isLoaded then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.UpdateSlots")
	end
	--/DebugMessage--	
	
	if _slotId then
		if _slotId == ULTIMATE_SLOT_INDEX then
			UpdateUltimateText()
		else
			local button = quickSlotList[_slotId]
			if button and IsQuickSlotActive(slotId) then
				button:HandleSlotChanged()	
			end	
		end
	else
		UpdateUltimateText()
	
		for slotId, buttonControl in pairs(quickSlotList) do
			if IsQuickSlotActive(slotId) then
				buttonControl:HandleSlotChanged()	
			end
		end
	end
end

function AUI.Actionbar.UpdateProcEffects()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.UpdateProcEffects")
	end
	--/DebugMessage--

	if not isLoaded or QUICKSLOT_FRAGMENT:IsShowing() then
		return
	end
	
	UpdateProcAbilitys()
end

function AUI.Actionbar.OnEffectChanged(_changeType, _effectSlot, _effectName, _unitTag, _beginTime, _endTime, _stackCount, _iconName, _buffType, _effectType, _abilityType, _statusEffectType, _unitName, _unitId, _abilityId)
	if not isLoaded or _unitTag ~= AUI_PLAYER_UNIT_TAG then
		return
	end
	
	if AUI.Ability.IsProc(_abilityId) then
		if _changeType == 1 then
			AddProcEffect(_abilityId)
		elseif _changeType == 2 then
			RemoveProcEffect(_abilityId)					
		end
	end
end

function AUI.Actionbar.OnGamepadPreferredModeChanged(_gamepadPreferred)
	AUI.Actionbar.UpdateUI()	
end

local function CreateActionButtons()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Actionbar.CreateActionButtons")
	end
	--/DebugMessage--

	for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE - 1 do
		abilitySlotList[i] = ZO_ActionBar_GetButton(i)
		
		if not abilitySlotList[i].procBurstTexture then
			abilitySlotList[i].procBurstTexture = WINDOW_MANAGER:CreateControl("$(parent)Burst", abilitySlotList[i].slot, CT_TEXTURE)
			abilitySlotList[i].procBurstTexture:SetAnchor(TOPLEFT)
			abilitySlotList[i].procBurstTexture:SetAnchor(BOTTOMRIGHT)			
			abilitySlotList[i].procBurstTexture:SetTexture("EsoUI/Art/ActionBar/coolDown_completeEFX.dds")
			abilitySlotList[i].procBurstTexture:SetDrawTier(DT_HIGH)
		end
		
		if not abilitySlotList[i].procLoopTexture then
			abilitySlotList[i].procLoopTexture = WINDOW_MANAGER:CreateControl("$(parent)Loop", abilitySlotList[i].slot, CT_TEXTURE)
			abilitySlotList[i].procLoopTexture:SetAnchor(TOPLEFT)
			abilitySlotList[i].procLoopTexture:SetAnchor(BOTTOMRIGHT)
			abilitySlotList[i].procLoopTexture:SetTexture("EsoUI/Art/ActionBar/abilityHighlight_mage_med.dds") 
			abilitySlotList[i].procLoopTexture:SetDrawTier(DT_HIGH)		
		end
		
		if not abilitySlotList[i].procBurstTimeline then	
			abilitySlotList[i].procBurstTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("AbilityProcReadyBurst", abilitySlotList[i].procBurstTexture)	
		end
		
		if not abilitySlotList[i].procLoopTimeline then	
			abilitySlotList[i].procLoopTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("AbilityProcReadyLoop", abilitySlotList[i].procLoopTexture)				
		end
		
		abilitySlotList[i].procBurstTexture:SetHidden(true)
		abilitySlotList[i].procLoopTexture:SetHidden(true)		
	end
end

function AUI.Actionbar.OnActionSlotUpdated(_slotId)
	if not isLoaded then
		return
	end
	
	if AUI.Ability.IsAbility(_slotId) then 
		local abilityID	= GetSlotBoundId(_slotId)

		if AUI.Ability.IsProc(abilityID) then	
			AddProcEffect(abilityID)
		elseif abilityProcEffects[_slotId] then
			RemoveProcEffect(abilityProcEffects[_slotId])				
		end	
	end
	
	if QUICKSLOT_FRAGMENT:IsShowing() then
		AUI.Actionbar.UpdateUI()
	else
		AUI.Actionbar.UpdateSlots(_slotId)
	end
end

function AUI.Actionbar.OnActionSlotsFullUpdate(_isHotbarSwap)
	if not isLoaded or QUICKSLOT_FRAGMENT:IsShowing() then
		if QUICKSLOT_FRAGMENT:IsShowing() then
			AUI.Actionbar.UpdateUI()
		end		
	
		return
	end	
	
	if not _isHotbarSwap then
		AUI.Actionbar.UpdateSlots()
	else
		UpdateUltimateText()
		AUI.Actionbar.UpdateProcEffects()
	end
end

function AUI.Actionbar.OnInventorySingleSlotUpdate(_bagId, _slotId, _isNewItem, _itemSoundCategory, _inventoryUpdateReason)
	if not isLoaded then
		return
	end

	AUI.Actionbar.UpdateSlots()
end

function AUI.Actionbar.Load()
	if isLoaded then
		return
	end
	
	isLoaded = true	

	AUI.Actionbar.SetMenuData()

	ultimateLabel = WINDOW_MANAGER:CreateControl(nil, actionBarUltimateButton.slot, CT_LABEL)
	ultimateLabel:SetResizeToFitDescendents(true)
	ultimateLabel:SetInheritScale(false)
	ultimateLabel:SetHorizontalAlignment(_hAlign or TEXT_ALIGN_CENTER)
	ultimateLabel:SetVerticalAlignment(_vAlign or TEXT_ALIGN_CENTER)		
	
	overlayUltimatePercent = WINDOW_MANAGER:CreateControl(nil, actionBarUltimateButton.slot, CT_LABEL)
	overlayUltimatePercent:SetResizeToFitDescendents(true)
	overlayUltimatePercent:SetInheritScale(false)
	overlayUltimatePercent:SetHorizontalAlignment(_hAlign or TEXT_ALIGN_CENTER)
	overlayUltimatePercent:SetVerticalAlignment(_vAlign or TEXT_ALIGN_CENTER)	
	overlayUltimatePercent:SetAnchor(BOTTOM, actionBarUltimateButton.slot, BOTTOM, 0, 0)	
	
	CreateActionButtons()
	
	SKILLS_FRAGMENT:RegisterCallback("StateChange", 
	function(oldState, newState)
		if isLoaded then
			if newState == SCENE_SHOWN then	
			  if AUI.IsAzurahDetected() then ZO_SkillsAssignableActionBar:SetHidden(true) end
				ACTION_BAR_FRAGMENT:Show()	
			elseif newState == SCENE_SHOWING then		
				AUI.Actionbar.UpdateUI()			
			elseif newState == SCENE_HIDDEN then
				AUI.Actionbar.UpdateUI()
				if AUI.IsAzurahDetected() then ZO_SkillsAssignableActionBar:SetHidden(false) end
			end
		end													
	end)	
	
	QUICKSLOT_FRAGMENT:RegisterCallback("StateChange", 
	function(oldState, newState)
		if isLoaded then
			if newState == SCENE_SHOWING then	
				ACTION_BAR_FRAGMENT:Show()			
				AUI.Actionbar.UpdateUI()				
			elseif newState == SCENE_HIDING then
				AUI.Actionbar.UpdateUI()
			end
		end													
	end)			
end