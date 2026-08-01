BSCTauntCounter = BSCTauntCounter or {}
local BSCTC = BSCTauntCounter

-- AddonInfo
BSCTC.Author = "@BloodStainChild666"
BSCTC.Name = "BSCs-TauntCounter"
BSCTC.Version = 1
BSCTC.SavedVar = "BSCTCSaved"
BSCTC.VersionDisplay = "1.0.0"

local TauntCounterID = 52790
local TauntIMMUNE = 52788
local BuffStartTime = 0
local bAddonActive = false

function BSCTC:PlaySound(loop, sound)
	if loop < 1 or loop > 20 then loop = 1 end
	for j = 1, loop do
		PlaySound(sound)
	end
end
--EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow) 
local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, dmgType, blog, sourceUnitId, targetUnitId, abilityId, overflow)
	if result == ACTION_RESULT_EFFECT_GAINED then --2240		
		if BSCTC.SV_ACC.bOnlyShowWhenNeed and hitValue >= 2 then			
			BSCTauntCounterUI:SetHidden(false)
		end	
		local LS = BSCTauntCounterUI:GetNamedChild("Count")		
		if hitValue == 5 then
			LS:SetColor(1, 0, 0, 1)	
			BSCTC:PlaySound(5, BSCTC.SV_ACC.S_SOUND_5)
		elseif hitValue == 4 then
			LS:SetColor(0.8, 1, 0, 1)
			BSCTC:PlaySound(4, BSCTC.SV_ACC.S_SOUND_4)
		elseif hitValue == 3 then
			LS:SetColor(0.6, 1, 0, 1)
			BSCTC:PlaySound(3, BSCTC.SV_ACC.S_SOUND_3)
		elseif hitValue == 2 then
			BSCTC:PlaySound(2, BSCTC.SV_ACC.S_SOUND_2)
			LS:SetColor(0.4, 1, 0, 1)		
		else
			LS:SetColor(0, 1, 0, 1)
		end		
		LS:SetText(hitValue)
		BSCTauntCounterUI:GetNamedChild("Taunting"):SetText(zo_strformat("<<1>>", targetName))	
		BuffStartTime = (GetGameTimeMilliseconds()/1000) + (GetAbilityDuration(TauntCounterID)/1000)
	elseif result == ACTION_RESULT_EFFECT_GAINED_DURATION then --2245
		BuffStartTime = (GetGameTimeMilliseconds()/1000) + (hitValue/1000)
	elseif result == ACTION_RESULT_EFFECT_FADED then --2250
		BSCTauntCounterUI:GetNamedChild("Taunting"):SetText("")
		BuffStartTime = 0
		if BSCTC.SV_ACC.bOnlyShowWhenNeed then			
			BSCTauntCounterUI:SetHidden(true)
		end	
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function UpdateUI()
	local DURATION = BuffStartTime - (GetGameTimeMilliseconds()/1000)
	if DURATION <= 0 then 
		DURATION = 0 
	end			
	local LB = BSCTauntCounterUI:GetNamedChild("Info")
	local BF = BSCTauntCounterUI:GetNamedChild("FrameBack")
	local LS = BSCTauntCounterUI:GetNamedChild("Count")
	local LT = BSCTauntCounterUI:GetNamedChild("Taunting")
	LB:SetText(string.format("%.0f", DURATION))		
	if DURATION == 0 then
		LB:SetColor(0, 1, 0, 1)
		BF:SetCenterColor(0, 1, 0, 1)
		LS:SetText("0")	
		LS:SetColor(0, 1, 0, 1)
		LT:SetText("")
		if BSCTC.SV_ACC.bOnlyShowWhenNeed then
			BSCTauntCounterUI:SetHidden(true)
		end
	elseif DURATION < 4 then
		LB:SetColor(0.8, 1, 0, 1)
		BF:SetCenterColor(0.8, 1, 0, 1)
	else
		LB:SetColor(1, 0, 0, 1)				
		BF:SetCenterColor(1, 0, 0, 1)
	end
end
local function ToggleUI(oldState, newState)
	if bAddonActive then 
		if newState == SCENE_SHOWN then
			BSCTauntCounterUI:SetHidden(false)
		elseif newState == SCENE_HIDDEN then
			BSCTauntCounterUI:SetHidden(true)
		end
	end
end
local lastUpdateTime = GetGameTimeMilliseconds()
function BSCTC:onRootFrameUpdate()
	local ms = GetGameTimeMilliseconds()
	if ms < lastUpdateTime then return end  
	lastUpdateTime = ms + 200
	if bAddonActive then 
		UpdateUI()
	end
end	
function BSCTC:OnMoveStop()
	BSCTC.SV_ACC.UI_LEFT = BSCTauntCounterUI:GetLeft()
	BSCTC.SV_ACC.UI_TOP = BSCTauntCounterUI:GetTop()
end
function BSCTC:SetPosition()
	if BSCTC.SV_ACC.UI_LEFT ~= -250 and BSCTC.SV_ACC.UI_TOP ~= 0 then
		BSCTauntCounterUI:ClearAnchors()
		BSCTauntCounterUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCTC.SV_ACC.UI_LEFT, BSCTC.SV_ACC.UI_TOP)
	end
	BSCTauntCounterUI:SetAlpha(BSCTC.SV_ACC.UI_ALPHA)
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function RegisterEvents()
	if bAddonActive then return end
	bAddonActive = true
	local eventName = 'TC_ID_'..TauntCounterID	
	EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, OnCombatEvent)
	EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, TauntCounterID)
	EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)	
	BSCTauntCounterUI:SetHidden(false)
end
local function UnregisterEvent()
	if not bAddonActive then return end
	bAddonActive = false
	local eventName = 'TC_ID_'..TauntCounterID	
	EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
	BSCTauntCounterUI:SetHidden(true)
end
------------------------------------------------------------------------------
--  Role Change LFG_ROLE_DPS, LFG_ROLE_HEAL, LFG_ROLE_INVALID,LFG_ROLE_TANK
------------------------------------------------------------------------------
local function HookRoleChange()
	ZO_PreHook("UpdateSelectedLFGRole", 	
	function(role) 
		if not BSCTC.SV_ACC.bEnableAddon then return end
		if BSCTC.SV_ACC.bOnlyBoss and not DoesUnitExist('boss1') then return end
		if role == LFG_ROLE_TANK then
			RegisterEvents()
		else
			UnregisterEvent()
		end
	end)
end
local function OnBossesChanged(_, forceReset)	
	if not BSCTC.SV_ACC.bEnableAddon then return end
	if not BSCTC.SV_ACC.bOnlyBoss then return end
	if DoesUnitExist('boss1') then
		if GetSelectedLFGRole() == LFG_ROLE_TANK then
			RegisterEvents()
		end	
	else
		UnregisterEvent()
	end	
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function OnPlayerActivated()
	if not BSCTC.SV_ACC.bEnableAddon then return end	
	EVENT_MANAGER:UnregisterForEvent(BSCTC.Name, EVENT_PLAYER_ACTIVATED)
	if GetSelectedLFGRole() == LFG_ROLE_TANK then
		if BSCTC.SV_ACC.bOnlyBoss and not DoesUnitExist('boss1') then return end
		RegisterEvents()
	end	
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCTC:EnableAddon()	
	if BSCTC.SV_ACC.bEnableAddon then
		if BSCTC.SV_ACC.bOnlyBoss and not DoesUnitExist('boss1') then return end
		if GetSelectedLFGRole() == LFG_ROLE_TANK then
			RegisterEvents()
		end	
	else
		UnregisterEvent()
	end	
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Init -- //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local defaultSV_ACC = {	
	UI_LEFT = -250,
	UI_TOP  = 0,
	UI_ALPHA = 1,	
	bOnlyBoss = true,
	bEnableAddon = true,
	bOnlyShowWhenNeed = false,
	S_SOUND_2 = "No_Sound",
	S_SOUND_3 = "No_Sound",
	S_SOUND_4 = "No_Sound",
	S_SOUND_5 = "No_Sound",
}
function BSCTC.init(event, addonName)	
	if addonName ~= BSCTC.Name then
		return 
	end			
	EVENT_MANAGER:UnregisterForEvent(BSCTC.Name, EVENT_ADD_ON_LOADED)	
	--
	BSCTC.SV_ACC = ZO_SavedVars:NewAccountWide(BSCTC.SavedVar, 1, nil, defaultSV_ACC)
	
	EVENT_MANAGER:RegisterForEvent(BSCTC.Name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)	
	-- Hide on opening menu
	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)
	
	HookRoleChange()
	
	EVENT_MANAGER:RegisterForEvent(BSCTC.Name, EVENT_BOSSES_CHANGED, OnBossesChanged)	
	
	BSCTC:SetPosition()		
	BSCTC:InitMenu()
end

EVENT_MANAGER:RegisterForEvent(BSCTC.Name, EVENT_ADD_ON_LOADED, BSCTC.init)