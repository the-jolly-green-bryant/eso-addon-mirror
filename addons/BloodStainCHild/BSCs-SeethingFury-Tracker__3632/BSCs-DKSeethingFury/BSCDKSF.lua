BSCDKSFury = BSCDKSFury or {}
local BSCDKSF = BSCDKSFury

BSCDKSF.Name = "BSCs-DKSeethingFury"
-- AddonInfo
BSCDKSF.NameMenu = "BSC's-Seething Fury Buff"
BSCDKSF.NameSpaced = "BSCDKSeethingFury"
BSCDKSF.Author = "@BloodStainChild666"
BSCDKSF.SavedVar = "BSCDKSFSaved"
BSCDKSF.VersionDisplay = "1.1.0"

local MoltenWhipID = 20805
local SeethingFuryID = 122729
local BuffStartTime = 0
local bSkillSloted = false
--/script d(IsSlotItemConsumable( 1, HOTBAR_CATEGORY_PRIMARY) )
local HOTBAR_CATEGORY_SET =
{
    [HOTBAR_CATEGORY_PRIMARY] = true,
    [HOTBAR_CATEGORY_BACKUP] = true,
}
local bCombat = false
local function OnCombatState(_, inCombat)	
	bCombat = inCombat
	if bSkillSloted and BSCDKSF.SV_ACC.UI_ONLYCOMBAT then
		if inCombat then
			BSCDKSeethingFuryUI:SetHidden(false)
		else
			BSCDKSeethingFuryUI:SetHidden(true)
		end
	end
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function CheckHotbar()
	local bSkillExist = false
	for hotbarCategory in pairs(HOTBAR_CATEGORY_SET) do
		if HOTBAR_CATEGORY_SET[hotbarCategory] then
			local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarCategory)
			if hotbar ~= nil then 
				 for actionSlotIndex, slotData in hotbar:SlotIterator() do
					if slotData:IsStillValid() then
						local skilldata = slotData:GetPlayerSkillData()
						if skilldata ~= nil then
							if skilldata:IsActive() then
								if slotData:GetActionId() == MoltenWhipID then
									bSkillExist = true
								end
							end
						end
					end
				 end
			end
		end
	end
	if bSkillExist then
		if not BSCDKSF.SV_ACC.UI_ONLYCOMBAT then
			BSCDKSeethingFuryUI:SetHidden(false)
		end
		bSkillSloted = true
	else
		BSCDKSeethingFuryUI:SetHidden(true)
		bSkillSloted = false
	end
end
-------------------------------------------------------------------------------------------------
local function OnCombatEvent( _, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	if result == ACTION_RESULT_EFFECT_GAINED then
		local LS = BSCDKSeethingFuryUI:GetNamedChild("Stack")
		LS:SetText((hitValue*100))
		if hitValue == 3 then
			LS:SetColor(0, 1, 0, 1)	
		elseif hitValue == 2 then
			LS:SetColor(0.8, 1, 0, 1)
		else
			LS:SetColor(1, 0, 0, 1)
		end		
		BuffStartTime = (GetGameTimeMilliseconds()/1000) + (GetAbilityDuration(SeethingFuryID)/1000)	
	end
end
local function UpdateUI()
	local DURATION = BuffStartTime - (GetGameTimeMilliseconds()/1000)
	if DURATION <= 0 then 
		DURATION = 0 
	end			
	local LB = BSCDKSeethingFuryUI:GetNamedChild("Info")
	local BF = BSCDKSeethingFuryUI:GetNamedChild("FrameBack")
	local LS = BSCDKSeethingFuryUI:GetNamedChild("Stack")
	LB:SetText(string.format("%.0f", DURATION))		
	if DURATION == 0 then
		LB:SetColor(1, 0, 0, 1)
		BF:SetCenterColor(1, 0, 0, 1)
		LS:SetText("0")	
		LS:SetColor(1, 0, 0, 1)
	elseif DURATION < 4 then
		LB:SetColor(0.8, 1, 0, 1)
		BF:SetCenterColor(0.8, 1, 0, 1)
	else
		LB:SetColor(0, 1, 0, 1)				
		BF:SetCenterColor(0, 1, 0, 1)
	end
end
local function ToggleUI(oldState, newState)
	if bSkillSloted then 
		if newState == SCENE_SHOWN then			--bCombat
			if BSCDKSF.SV_ACC.UI_ONLYCOMBAT and bCombat then
				BSCDKSeethingFuryUI:SetHidden(false)
			else
				BSCDKSeethingFuryUI:SetHidden(false)
			end
		elseif newState == SCENE_HIDDEN then
			BSCDKSeethingFuryUI:SetHidden(true)
		end
	end
end
local lastUpdateTime = GetGameTimeMilliseconds()
function BSCDKSF:onRootFrameUpdate()
	local ms = GetGameTimeMilliseconds()
	if ms < lastUpdateTime then return end  
	lastUpdateTime = ms + 200
	if bSkillSloted then 
		UpdateUI()
	end
end	
local function OnPlayerActivated()
	BSCDKSF:CheckSkillLines()
end
function BSCDKSF:OnMoveStop()
	BSCDKSF.SV_ACC.UI_LEFT = BSCDKSeethingFuryUI:GetLeft()
	BSCDKSF.SV_ACC.UI_TOP = BSCDKSeethingFuryUI:GetTop()
end
function BSCDKSF:SetPosition()
	if BSCDKSF.SV_ACC.UI_LEFT ~= -250 and BSCDKSF.SV_ACC.UI_TOP ~= 0 then
		BSCDKSeethingFuryUI:ClearAnchors()
		BSCDKSeethingFuryUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCDKSF.SV_ACC.UI_LEFT, BSCDKSF.SV_ACC.UI_TOP)
	end
	BSCDKSeethingFuryUI:SetAlpha(BSCDKSF.SV_ACC.UI_ALPHA)
end
local function SkillLineAdded(_, _skillType_, _skillLineIndex_, _advised_)
	BSCDKSF:CheckSkillLines()
end
-- Prepeare for subclasing
function BSCDKSF:CheckSkillLines() -- /script BSCDKSFury:CheckSkillLines()	
	local function CheckByClassID(_classId_)			
		for _classSkillLineIndex_ = 1, GetNumSkillLinesForClass(_classId_), 1 do 
			local _skillLineId_ = GetSkillLineIdForClass(_classId_, _classSkillLineIndex_)				
			local _skillType_, _skillLineIndex_ = GetSkillLineIndicesFromSkillLineId(_skillLineId_)				
			local _rank_, _isAdvised_, _isActive_, _isDiscovered_, _isAccountSkill_, _isInTraining_ =  GetSkillLineDynamicInfo(_skillType_, _skillLineIndex_)
			-- Active skill lines
			if _isActive_ then
				--d(GetSkillLineNameById(_skillLineId_))
				for _skillIndex_ = 1, GetNumSkillAbilities(_skillType_, _skillLineIndex_), 1 do				
					if not IsSkillAbilityPassive(_skillType_, _skillLineIndex_, _skillIndex_) 
					and IsSkillAbilityPurchased(_skillType_, _skillLineIndex_, _skillIndex_) then						
						local _showUpgrade_ = false
						local _abilityId_ = GetSkillAbilityId(_skillType_, _skillLineIndex_, _skillIndex_, _showUpgrade_)
						--d(zo_strformat("[<<1>>] Name[<<2>>]", _abilityId_, GetAbilityName(_abilityId_)))
						if _abilityId_ == MoltenWhipID then
							CheckHotbar()
						end
					end
				end	
			end			
		end	
	end
	if HasAccessToSubclassing() then
		-- Check
		for index = 1, GetNumClasses(), 1 do
			local _classId_ = GetClassIdByIndex(index)			
			CheckByClassID(GetClassIdByIndex(_classId_))			
		end		
	else
		CheckByClassID(GetUnitClassId('player'))
	end
end
local defaultSV_ACC = {	
	UI_LEFT = -250,
	UI_TOP  = 0,
	UI_ALPHA = 1,	
	UI_ONLYCOMBAT = false,
}
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
function BSCDKSF.init(event, addonName)	
	if addonName ~= BSCDKSF.Name then
		return 
	end
	EVENT_MANAGER:UnregisterForEvent(BSCDKSF.Name, 	EVENT_ADD_ON_LOADED)	
	--
	BSCDKSF.SV_ACC = ZO_SavedVars:NewAccountWide(BSCDKSF.SavedVar, 1, nil, defaultSV_ACC)	
	BSCDKSF:InitMenu()
	--
	EVENT_MANAGER:RegisterForEvent(BSCDKSF.Name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	-- Hide on opening menu
	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)
	-- Combat Events
	EVENT_MANAGER:RegisterForEvent(BSCDKSF.Name, EVENT_COMBAT_EVENT, OnCombatEvent)	
	EVENT_MANAGER:AddFilterForEvent(BSCDKSF.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, SeethingFuryID)
	EVENT_MANAGER:AddFilterForEvent(BSCDKSF.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)	
	-- Combat State
	EVENT_MANAGER:RegisterForEvent(BSCDKSF.Name, EVENT_PLAYER_COMBAT_STATE, 	OnCombatState)	
	-- Hotbar Check		
	EVENT_MANAGER:RegisterForEvent(BSCDKSF.Name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function() CheckHotbar() end)
	--
	BSCDKSF:SetPosition()
end
EVENT_MANAGER:RegisterForEvent(BSCDKSF.Name, EVENT_ADD_ON_LOADED, BSCDKSF.init)
