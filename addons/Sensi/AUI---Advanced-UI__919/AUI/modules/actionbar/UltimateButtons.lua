AUI.Actionbar.UltimateButtons = {}

local gZO_quickSlot = ZO_ActionBar_GetButton(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
local gZO_companionButton = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, HOTBAR_CATEGORY_COMPANION)
local gZO_ultimateButton = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1)
local gZO_lastActionSlot = ZO_ActionBar_GetButton(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + ACTION_BAR_SLOTS_PER_PAGE - 1)

local gIsLoaded = false
local gOverlayUltimatePercent = nil
local gUltimateLabel = nil

local function CreateUI()	
	gUltimateLabel = WINDOW_MANAGER:CreateControl(nil, gZO_ultimateButton.slot, CT_LABEL)
	--gUltimateLabel:SetResizeToFitDescendents(true)
	gUltimateLabel:SetInheritScale(false)
	gUltimateLabel:SetHorizontalAlignment(_hAlign or TEXT_ALIGN_CENTER)
	gUltimateLabel:SetVerticalAlignment(_vAlign or TEXT_ALIGN_CENTER)		
	
	gOverlayUltimatePercent = WINDOW_MANAGER:CreateControl(nil, gZO_ultimateButton.slot, CT_LABEL)
	--gOverlayUltimatePercent:SetResizeToFitDescendents(true)
	gOverlayUltimatePercent:SetInheritScale(false)
	gOverlayUltimatePercent:SetHorizontalAlignment(_hAlign or TEXT_ALIGN_CENTER)
	gOverlayUltimatePercent:SetVerticalAlignment(_vAlign or TEXT_ALIGN_CENTER)			
end

local function GetUltimateString(_powerValue)
	if _powerValue == 0 then
		return ""
	end

	return _powerValue
end	
	
local function GetUltimatePercentString(_powerValue)
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
	if not _powerValue or not _maxValue then
		_powerValue, _maxValue = GetUnitPower(AUI_PLAYER_UNIT_TAG, POWERTYPE_ULTIMATE)
	end

	local percent = GetUltimatePercentString(_powerValue)
	gOverlayUltimatePercent:SetText(percent)
	gUltimateLabel:SetText(GetUltimateString(_powerValue, _powerMax))		
end	

function AUI.Actionbar.UltimateButtons.OnPowerUpdate(_unitTag, _powerIndex, _powerType, _powerValue, _powerMax, _powerEffectiveMax)
	if not gIsLoaded or _unitTag ~= AUI_PLAYER_UNIT_TAG then
		return
	end

	if _powerType == POWERTYPE_ULTIMATE then	
		UpdateUltimateText(_powerValue, _powerMax)
	end	
end	

function AUI.Actionbar.UltimateButtons.OnSwapActionBar()
	if not gIsLoaded then
		return
	end

	UpdateUltimateText()
end

function AUI.Actionbar.UltimateButtons.Update()
	if not gIsLoaded then
		return
	end

	UpdateUltimateText()
end

function AUI.Actionbar.UltimateButtons.ShowPercent()
	if not gIsLoaded or not AUI.Settings.Actionbar.show_ultimate_percent then
		return
	end

	if gOverlayUltimatePercent:GetAlpha() == 1 or not gOverlayUltimatePercent:IsHidden() then
		return
	end

	gOverlayUltimatePercent:SetHidden(false)
	gOverlayUltimatePercent:SetAlpha(1)	
end

function AUI.Actionbar.UltimateButtons.HidePercent()
	if not gIsLoaded or not AUI.Settings.Actionbar.show_ultimate_percent then
		return
	end

	if gOverlayUltimatePercent:GetAlpha() == 0 or gOverlayUltimatePercent:IsHidden() then
		return
	end
	
	gOverlayUltimatePercent:SetHidden(true)
	gOverlayUltimatePercent:SetAlpha(0)	
end

function AUI.Actionbar.UltimateButtons.UpdateUI()
	if not gIsLoaded then
		return
	end

	if IsInGamepadPreferredMode() then
		gUltimateLabel:ClearAnchors()
		gUltimateLabel:SetAnchor(BOTTOM, nil, TOP, 0, -2)	
		gUltimateLabel:SetFont("$(BOLD_FONT)|" .. 18 .. "|" .. "thick-outline")
		gOverlayUltimatePercent:SetFont("$(BOLD_FONT)|" .. 18 .. "|" .. "thick-outline")			
		gOverlayUltimatePercent:SetAnchor(BOTTOM, gZO_ultimateButton.slot, BOTTOM, 0, -12)
					
		gZO_ultimateButton:ApplyAnchor(gZO_lastActionSlot.slot, 66)
	else
		gUltimateLabel:ClearAnchors()
		gUltimateLabel:SetAnchor(BOTTOM, nil, TOP, 0, 0)				
		gUltimateLabel:SetFont("$(BOLD_FONT)|" .. 16 .. "|" .. "thick-outline")
		gOverlayUltimatePercent:SetFont("$(BOLD_FONT)|" .. 12 .. "|" .. "thick-outline")
		gOverlayUltimatePercent:SetAnchor(BOTTOM, gZO_ultimateButton.slot, BOTTOM, 0, -4)	
	
		gZO_ultimateButton:ApplyAnchor(gZO_lastActionSlot.slot, 40)
	end

	if AUI.Settings.Actionbar.show_ultimate_percent then
		gUltimateLabel:SetHidden(false)
		gOverlayUltimatePercent:SetHidden(false)	
	else
		gUltimateLabel:SetHidden(true)
		gOverlayUltimatePercent:SetHidden(true)	
	end		

	gZO_companionButton.slot:ClearAnchors()
	if AUI.Settings.Actionbar.useCompanionDefaultPos then		
		if IsInGamepadPreferredMode() then
			gZO_companionButton.slot:SetAnchor(LEFT, ZO_ActionBar1WeaponSwap, LEFT, -46)
		else
			gZO_companionButton.slot:SetAnchor(LEFT, ZO_ActionBar1WeaponSwap, LEFT, -60)			
		end	
	else
		if IsInGamepadPreferredMode() then
			gZO_companionButton.slot:SetAnchor(RIGHT, gZO_ultimateButton.slot, RIGHT, 160)
		else
			gZO_companionButton.slot:SetAnchor(RIGHT, gZO_ultimateButton.slot, RIGHT, 70)			
		end	
	end

	if not AUI.Settings.Actionbar.quick_slots_enabled then
		if AUI.Settings.Actionbar.useCompanionDefaultPos then
			if IsInGamepadPreferredMode() then
				gZO_quickSlot.slot:SetAnchor(RIGHT, gZO_companionButton.slot, LEFT, -46)		
			else
				gZO_quickSlot.slot:SetAnchor(RIGHT, gZO_companionButton.slot, LEFT, -30)
			end		
		else	
			gZO_quickSlot.slot:SetAnchor(RIGHT, ZO_ActionBar1WeaponSwap, LEFT, -4)
		end		
	end	

	UpdateUltimateText()
end

function AUI.Actionbar.UltimateButtons.Load()
	if gIsLoaded then
		return
	end
	
	gIsLoaded = true
	
	CreateUI()
end

function AUI.Actionbar.UltimateButtons.GetUltimateButton()
	return gZO_ultimateButton.slot
end

function AUI.Actionbar.UltimateButtons.GetCompanionUltimateButton()
	return gZO_companionButton.slot
end