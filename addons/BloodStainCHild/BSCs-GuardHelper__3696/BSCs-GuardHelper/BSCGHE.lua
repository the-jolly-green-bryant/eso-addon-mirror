BSCGUardHelper = BSCGUardHelper or {}
local BSCGHE = BSCGUardHelper

BSCGHE.Name = "BSCs-GuardHelper"
BSCGHE.Version = 1
BSCGHE.SavedVar = "BSCGHESaved"
BSCGHE.VersionDisplay = "1.1.0"
BSCGHE.NameMenu = "BSCs-GuardHelper"
BSCGHE.Author = "@BloodStainChild666"

local GUARD_NORMAL_ICON = "esoui/art/icons/ability_ava_guard.dds"
local GUARD_USED_ICON = "esoui/art/icons/ability_warrior_001.dds"

local bIgnoreCheckHotbar = false
local bSkillSloted = false
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local SlotedSkillID = 61536
local HOTBAR_CATEGORY_SET =
{
    [HOTBAR_CATEGORY_PRIMARY] = true,
    [HOTBAR_CATEGORY_BACKUP] = true,
    [HOTBAR_CATEGORY_OVERLOAD] = false,
    [HOTBAR_CATEGORY_WEREWOLF] = false,
    [HOTBAR_CATEGORY_TEMPORARY] = false,
    [HOTBAR_CATEGORY_DAEDRIC_ARTIFACT] = false,
    [HOTBAR_CATEGORY_COMPANION] = false,
}
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
								local skillType, skillLineIndex, skillIndex = skilldata:GetIndices()								
								local abilityId, lineRankNeededToUnlock = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, skillIndex, MORPH_SLOT_MORPH_1, 1)						
								if abilityId == SlotedSkillID then
									bSkillExist = true
								end
							end
						end
					end
				 end
			end
		end
	end
	if bIgnoreCheckHotbar then return end
	
	if bSkillExist then
		BSCGUardHelperUI:SetHidden(false)
		bSkillSloted = true
	else
		BSCGUardHelperUI:SetHidden(true)
		bSkillSloted = false
	end
end
--
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function BSCPlaySound(soundname)
	if not BSCGHE.SV_ACC.bPlaySound then return end
	PlaySound(soundname)
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BSCGHE.GUARD_IDS_S = {
	[61511] = true, -- Base Morph
	[61529] = true, -- 
	[61536] = true,	-- 
}
BSCGHE.GUARD_IDS_T = {
	[80923] = true,	-- Base Morph
	[80947] = true,	-- 
	[80983] = true,	-- 
}
--	
local function SetUI(Guarding, Range, GUARD_ICON, r, g, b)
	BSCGUardHelperUI:GetNamedChild("Guarding"):SetText(zo_strformat("<<1>>", Guarding))
	BSCGUardHelperUI:GetNamedChild("Range"):SetText(Range)
	BSCGUardHelperUI:GetNamedChild("Icon"):SetTexture(GUARD_ICON)
	BSCGUardHelperUI:GetNamedChild("FrameBack"):SetCenterColor(r, g, b, 1)
end
local GroupUnitTag = ""
-- EVENT_EFFECT_CHANGED (eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
local function OnEffectChanged_S( _, changeType, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, unitName, unitId, abilityId, sourceType)
	--d(zo_strformat("1 abilityId[<<1>>] changeType[<<2>>] unitTag[<<3>>] sourceType[<<4>>]", abilityId, changeType, unitTag, sourceType))
	if changeType == EFFECT_RESULT_FADED then	
		GroupUnitTag = ""
		SetUI("", "", GUARD_NORMAL_ICON, 1, 0, 0)
		BSCPlaySound(SOUNDS.DUEL_FORFEIT)
	elseif changeType == EFFECT_RESULT_UPDATED or changeType == EFFECT_RESULT_GAINED then	
		GroupUnitTag = unitTag
		SetUI(GetUnitName(unitTag), "0", GUARD_USED_ICON, 0, 1, 0)	
		BSCPlaySound(SOUNDS.RETRAITING_RETRAIT_TOOLTIP_GLOW_SUCCESS)
	end	
end
local function OnEffectChanged_T( _, changeType, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, unitName, unitId, abilityId, sourceType)
	--d(zo_strformat("2 abilityId[<<1>>] changeType[<<2>>] unitTag[<<3>>] sourceType[<<4>>]", abilityId, changeType, unitTag, sourceType))
	if BSCGHE.SV_ACC.breceive then		
		if changeType == EFFECT_RESULT_FADED then
			bIgnoreCheckHotbar = false
			GroupUnitTag = ""
			BSCGUardHelperUI:SetHidden(true)
			SetUI("", "", GUARD_NORMAL_ICON, 1, 0, 0)	
			BSCPlaySound(SOUNDS.DUEL_FORFEIT)		
		elseif changeType == EFFECT_RESULT_UPDATED or changeType == EFFECT_RESULT_GAINED then
			bIgnoreCheckHotbar = true
			GroupUnitTag = unitTag
			BSCGUardHelperUI:SetHidden(false)
			SetUI(GetUnitName(unitTag), "0", GUARD_USED_ICON, 0, 1, 0)	
			BSCPlaySound(SOUNDS.RETRAITING_RETRAIT_TOOLTIP_GLOW_SUCCESS)			
		end
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function GetDistance( unitTag1, unitTag2, useHeight )
	local zone1, x1, y1, z1 = GetUnitWorldPosition(unitTag1)
	local zone2, x2, y2, z2 = GetUnitWorldPosition(unitTag2)

	if (zone1 == 0 or zone1 ~= zone2) then
		return(-1)
	elseif (useHeight) then
		return(zo_sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2) / 100)
	else
		return(zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) / 100)
	end
end

local function UpdateUI()
	if GroupUnitTag ~= "" then
		local distance = GetDistance('player', GroupUnitTag, false)
		if distance > 12 then 			
			BSCGUardHelperUI:GetNamedChild("FrameBack"):SetCenterColor(0.8, 1, 0, 1)
			BSCPlaySound(SOUNDS.KEYBIND_BUTTON_DISABLED)
		else
			BSCGUardHelperUI:GetNamedChild("FrameBack"):SetCenterColor(0, 1, 0, 1)
		end
		BSCGUardHelperUI:GetNamedChild("Range"):SetText(string.format("%.1fm", distance))
	end
end
local lastUpdateTime = GetGameTimeMilliseconds()
function BSCGHE:onRootFrameUpdate()
	local ms = GetGameTimeMilliseconds()
	if ms < lastUpdateTime then return end  
	lastUpdateTime = ms + 300
	if bSkillSloted or bIgnoreCheckHotbar then 
		UpdateUI()
	end
end	
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function OnPlayerActivated()		
	BSCGUardHelperUI:GetNamedChild("Guarding"):SetText("")
	BSCGUardHelperUI:GetNamedChild("Range"):SetText("")
	BSCGUardHelperUI:GetNamedChild("Icon"):SetTexture(GUARD_NORMAL_ICON)
	BSCGUardHelperUI:GetNamedChild("FrameBack"):SetCenterColor(1, 0, 0, 1)
	BSCGUardHelperUI:SetHidden(true)
	CheckHotbar()
end
function BSCGHE:OnMoveStop()
	BSCGHE.SV_ACC.UI_LEFT = BSCGUardHelperUI:GetLeft()
	BSCGHE.SV_ACC.UI_TOP = BSCGUardHelperUI:GetTop()
end
function BSCGHE:SetPosition()
	if BSCGHE.SV_ACC.UI_LEFT ~= -250 and BSCGHE.SV_ACC.UI_TOP ~= 0 then
		BSCGUardHelperUI:ClearAnchors()
		BSCGUardHelperUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCGHE.SV_ACC.UI_LEFT, BSCGHE.SV_ACC.UI_TOP)
	end
	BSCGUardHelperUI:SetAlpha(BSCGHE.SV_ACC.UI_ALPHA)
end
local function ToggleUI(oldState, newState)
	if bSkillSloted then 
		if newState == SCENE_SHOWN then
			BSCGUardHelperUI:SetHidden(false)
		elseif newState == SCENE_HIDDEN then
			BSCGUardHelperUI:SetHidden(true)
		end
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local defaultSV_ACC = {	
	UI_LEFT = -250,
	UI_TOP  = 0,
	UI_ALPHA = 1,
	bPlaySound = true,
	breceive = false,
}

function BSCGHE.init(event, addonName)
	if addonName ~= BSCGHE.Name then
		return 
	end		
	EVENT_MANAGER:UnregisterForEvent(BSCGHE.Name, 	EVENT_ADD_ON_LOADED)	
	-- Get Saved Data	
	BSCGHE.SV_ACC = ZO_SavedVars:NewAccountWide(BSCGHE.SavedVar, 1, nil, defaultSV_ACC)		
	BSCGHE.InitMenu()
	--
	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)
	--
	EVENT_MANAGER:RegisterForEvent(BSCGHE.Name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)	
	EVENT_MANAGER:RegisterForEvent(BSCGHE.Name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function() CheckHotbar() end)
	
	for abilityId in pairs(BSCGHE.GUARD_IDS_S) do
		local eventName = 'BSCGHE_GUARDID_'..abilityId
		EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, OnEffectChanged_S)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)	
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	end
	for abilityId in pairs(BSCGHE.GUARD_IDS_T) do
		local eventName = 'BSCGHE_GUARDID_'..abilityId
		EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, OnEffectChanged_T)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)	
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	end
	BSCGHE:SetPosition()
end
EVENT_MANAGER:RegisterForEvent(BSCGHE.Name, EVENT_ADD_ON_LOADED, BSCGHE.init)