AUI.Actionbar.QuickButtons = {}

local MAX_QUICK_SLOTS = 8

local gZO_companionButton = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, HOTBAR_CATEGORY_COMPANION)
local gZO_ultimateButton = ZO_UltimateActionButton
local gQuickButtonArray = {}
local gNumSlots = 0

local function GetSlotData(_slotId)
	for slotId, slot in pairs(gQuickButtonArray) do
		if slot:GetSlot() == _slotId then
			return slotId, slot
		end
	end
end

local function IsQuickSlotActive(_slotId)
	if gQuickButtonArray[_slotId] then
		local slotCount = 0

		if IsInGamepadPreferredMode() then
			slotCount = AUI.Settings.Actionbar.gamepad_quickslot_count
		else
			slotCount = AUI.Settings.Actionbar.keyboard_quickslot_count
		end

		if _slotId and _slotId <= slotCount then
			return true
		end
	end
	
	return false
end

local function CreateButtons()
	for slotId = 1, MAX_QUICK_SLOTS do	
		local buttonControl = AUI_QuickSlotButton:New(slotId, ACTION_BUTTON_TYPE_VISIBLE, ZO_ActionBar1, "ZO_ActionButton")		
		buttonControl:SetupBounceAnimation()
		
		gQuickButtonArray[slotId] = buttonControl
	end
end

local function SelectCurrentQuickSlot()
	for _, button in pairs(gQuickButtonArray) do
		button:Unselect()
	end	
				
	local currentQuickSlotId = GetCurrentQuickslot()
	if IsQuickSlotActive(currentQuickSlotId) then	
		local buttonControl = gQuickButtonArray[currentQuickSlotId]
		buttonControl:Select()
	end
end

function AUI.Actionbar.QuickButtons.SelectNextQuickSlotButton()
	if not gIsLoaded then
		return
	end

	local currentQuickSlotId = GetCurrentQuickslot()
	local slotId, quickSlotControl = GetSlotData(currentQuickSlotId)	
	
	slotId = slotId + 1
	
	if not IsQuickSlotActive(slotId) then
		slotId = 1
	end
	
	AUI.Actionbar.QuickButtons.SelectQuickSlotButton(slotId)
end

function AUI.Actionbar.QuickButtons.SelectPreviosQuickSlotButton()
	if not gIsLoaded then
		return
	end

	local currentQuickSlotId = GetCurrentQuickslot()
	local slotId, quickSlotControl = GetSlotData(currentQuickSlotId)	
	slotId = slotId - 1
	
	if not IsQuickSlotActive(slotId) then
		local slotCount = AUI.Settings.Actionbar.keyboard_quickslot_count
		if IsInGamepadPreferredMode() then
			slotCount = AUI.Settings.Actionbar.gamepad_quickslot_count
		end	
	
		slotId = slotCount
	end	
	
	AUI.Actionbar.QuickButtons.SelectQuickSlotButton(slotId)
end

function AUI.Actionbar.QuickButtons.SelectQuickSlotButton(_slotId)
	if not gIsLoaded then
		return
	end

	if gQuickButtonArray[_slotId] then
		SetCurrentQuickslot(gQuickButtonArray[_slotId].button.slotNum)
	end
	
	SelectCurrentQuickSlot()
end

function AUI.Actionbar.QuickButtons.SelectCurrentQuickSlot()
	if not gIsLoaded then
		return
	end

	SelectCurrentQuickSlot()
end

function AUI.Actionbar.QuickButtons.GetNumSlots()
	return gNumSlots - 1
end

function AUI.Actionbar.QuickButtons.UpdateUI()
	if not gIsLoaded then
		return
	end

	gNumSlots = 1
	
	for slotId, quickButton in pairs(gQuickButtonArray) do
		if IsQuickSlotActive(slotId) then
			gNumSlots = gNumSlots + 1
			quickButton:HandleSlotChanged(HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
			quickButton.slot:SetHidden(false)	
		else
			quickButton.slot:SetHidden(true)
		end
	end	
	
	local lastSlot = nil
	for slotId = 1, gNumSlots do	
		local quickButton = gQuickButtonArray[gNumSlots - slotId]
		
		if quickButton then
			quickButton:ApplyStyle(ZO_GetPlatformTemplate("ZO_ActionButton"))
			
			if not IsInGamepadPreferredMode() then
				quickButton.countText:SetFont("$(BOLD_FONT)|" .. 14 .. "|" .. "soft-shadow-thin")
			else
				quickButton.countText:SetFont("$(BOLD_FONT)|" .. 20 .. "|" .. "soft-shadow-thin")
			end
			
			quickButton.slot:ClearAnchors()
		
			if not lastSlot then		
				if AUI.Actionbar.ShouldShowCompanionUltimateButton() then
					if AUI.Settings.Actionbar.useCompanionDefaultPos or not AUI.Settings.Actionbar.ultimate_slots_enabled then					
						if IsInGamepadPreferredMode() then
							quickButton.slot:SetAnchor(RIGHT, gZO_companionButton.slot, LEFT, -46)		
						else
							quickButton.slot:SetAnchor(RIGHT, gZO_companionButton.slot, LEFT, -30)
						end								
					else
						quickButton.slot:SetAnchor(RIGHT, ZO_ActionBar1WeaponSwap, LEFT, -4)	
					end
				else
					if AUI.Settings.Actionbar.useCompanionDefaultPos or not AUI.Settings.Actionbar.ultimate_slots_enabled then
						quickButton.slot:SetAnchor(RIGHT, gZO_companionButton.slot, LEFT, -4)							
					else
						quickButton.slot:SetAnchor(RIGHT, ZO_ActionBar1WeaponSwap, LEFT, -4)						
					end
				end			
			else
				if not IsInGamepadPreferredMode() then
					quickButton.slot:SetAnchor(RIGHT, lastSlot.slot, LEFT, -2)			
				else
					quickButton.slot:SetAnchor(RIGHT, lastSlot.slot, LEFT, -10)
				end
			end	
			
			lastSlot = quickButton		
		end
	end		
	
	local gZO_quickSlot = ZO_ActionBar_GetButton(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
	
	gZO_quickSlot.slot:ClearAnchors()	
	
	local numQuickSlots = AUI.Actionbar.QuickButtons.GetNumSlots()		
	if numQuickSlots > 0 then
		if IsInGamepadPreferredMode() then
			gZO_quickSlot.slot:SetAnchor(RIGHT, AUI.Actionbar.QuickButtons.GetFirstQuickSlot(), LEFT, -46)		
		else
			gZO_quickSlot.slot:SetAnchor(RIGHT, AUI.Actionbar.QuickButtons.GetFirstQuickSlot(), LEFT, -30)
		end				
	else
		if AUI.Actionbar.ShouldShowCompanionUltimateButton() then
			if AUI.Settings.Actionbar.useCompanionDefaultPos or not AUI.Settings.Actionbar.ultimate_slots_enabled then
				if IsInGamepadPreferredMode() then
					gZO_quickSlot.slot:SetAnchor(RIGHT, gZO_companionButton.slot, LEFT, -46)		
				else
					gZO_quickSlot.slot:SetAnchor(RIGHT, gZO_companionButton.slot, LEFT, -30)
				end		
			else
				gZO_quickSlot.slot:SetAnchor(RIGHT, ZO_ActionBar1WeaponSwap, LEFT, -4)	
			end	
		else
			gZO_quickSlot.slot:SetAnchor(RIGHT, ZO_ActionBar1WeaponSwap, LEFT, -4)						
		end
	end	
	
	SelectCurrentQuickSlot()
end

function AUI.Actionbar.QuickButtons.UpdateCooldowns()
	if not gIsLoaded then
		return
	end

	for slotId, quickButton in pairs(gQuickButtonArray) do
		if IsQuickSlotActive(slotId) then
			quickButton:HandleSlotChanged(HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
		end
	end
end

function AUI.Actionbar.QuickButtons.OnFullUpdate(_isHotbarSwap)
	if not gIsLoaded or _isHotbarSwap then
		return
	end


	for slotId, quickButton in pairs(gQuickButtonArray) do	
		if IsQuickSlotActive(slotId) then
			quickButton:HandleSlotChanged(HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
		end
	end	
end

function AUI.Actionbar.QuickButtons.OnSlotUpdate(_slotId)
	if not gIsLoaded and not IsQuickSlotActive(_slotId) then
		return
	end

	local quickButton = gQuickButtonArray[_slotId]	
	if quickButton then
		quickButton:HandleSlotChanged(HOTBAR_CATEGORY_QUICKSLOT_WHEEL)		
		AUI.Actionbar.QuickButtons.UpdateUI()			
	end	
end

function AUI.Actionbar.QuickButtons.Load()
	if gIsLoaded then
		return
	end
	
	CreateButtons()
	
	gIsLoaded = true
end

function AUI.Actionbar.QuickButtons.GetNumlots()
	return gNumSlots
end

function AUI.Actionbar.QuickButtons.GetMainQuickSlot()
	return ZO_ActionBar_GetButton(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL).slot
end

function AUI.Actionbar.QuickButtons.GetFirstQuickSlot()
	if not gIsLoaded then
		return nil
	end

	return gQuickButtonArray[1].slot
end

function AUI.Actionbar.QuickButtons.GetLastQuickSlot()
	if not gIsLoaded then
		return nil
	end

	return gQuickButtonArray[gNumSlots - 1].slot
end

