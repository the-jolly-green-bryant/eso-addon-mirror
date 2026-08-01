BSCHTKAHelper = BSCHTKAHelper or {}
local BSCHTKA = BSCHTKAHelper

BSCHTKA.bYandir = false
BSCHTKA.bYandirHM = false
BSCHTKA.bVrol = false
BSCHTKA.bVrolHM = false
BSCHTKA.bFalgraven = false
BSCHTKA.bFalgravenHM = false
BSCHTKA.bStartListening = false

local ALERT_LIST = { }

local debug_mode = false
function BSCHTKA:PrintDebug(FormatedText)
	if debug_mode then	
		if BSCTestingAddon then
			BSCTestingAddon:PrintToTab(FormatedText)
		else
			CHAT_ROUTER:AddSystemMessage(os.date("[%H:%M:%S] ", GetTimeStamp()) .. FormatedText)
		end
	end
end
local function DecimalToHex(input)
	return string.format("%02X", input * 255)
end
function BSCHTKA:BuildHexColor(input)
	return "0x"..DecimalToHex(input[1])..DecimalToHex(input[2])..DecimalToHex(input[3])..DecimalToHex(input[4])
end
local function SlashCommand(text)
	local ftext = zo_strlower(text)
	if ftext == 'debug' then
		if debug_mode then
			BSCHTKA:PrintDebug("Debug Mode "..BSCHTKA.Name.." Disabled!")
			debug_mode = false
		else
			debug_mode = true
			BSCHTKA:PrintDebug("Debug Mode "..BSCHTKA.Name.." Enabled!")
		end
	elseif ftext == 't' then		
		
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- UI Stuff
local function ToggleUI(oldState, newState)
	if not BSCHTKA.bYandir and not BSCHTKA.bVrol and not BSCHTKA.bFalgraven then return end	
	if newState == SCENE_SHOWN then
		BSCHTKAHelperInfoUI:SetHidden(false)
	elseif newState == SCENE_HIDDEN then
		BSCHTKAHelperInfoUI:SetHidden(true)
	end
end
local function ResetUI(hidden)
	BSCHTKAHelperInfoUI:SetHidden(hidden)
	BSCHTKAHelperInfoUI:GetNamedChild("InfoTOP"):SetText("")
	BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText("")
	BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText("")
	BSCHTKAHelperInfoUI:GetNamedChild("Info3"):SetText("")
	BSCHTKAHelperInfoUI:GetNamedChild("Info4"):SetText("")	
end
local function UpdateUI()
	if BSCHTKA.bStartListening then
		if BSCHTKA.bYandir then
			BSCHTKA:Yandir_UpdateUI()
		end	
		if BSCHTKA.bVrol then
			BSCHTKA:Vrol_UpdateUI()
		end
		if BSCHTKA.bFalgraven then	
			BSCHTKA:Falg_UpdateUI()
		end
	end
end
local function CheckHM()	
	local zone, x, y, z = GetUnitWorldPosition("player")	
	if zone ~= 1196 then return end	
	if x > 63200 and x < 68900
		and y > 24300 and y < 26300
		and z > 90500 and z < 99600 then		
		if select(3, GetUnitPower('boss1', POWERTYPE_HEALTH)) >= 72769370 then
			BSCHTKA.bYandirHM = true
		else
			BSCHTKA.bYandirHM = false
		end		
		BSCHTKA.bYandir = true
		-- YANDIR Show UI
		if BSCHTKA.SV_ACC.SHOW_UI_BOSS then
			ResetUI(false)
			BSCHTKAHelperInfoUI:GetNamedChild("InfoTOP"):SetText(zo_strformat("<<1>> HM[<<2>>]", GetUnitName('boss1'), (BSCHTKA.bYandirHM and 'ON' or 'OFF')))
		end
	elseif x > 110200 and x < 118500
		and y > 24500 and y < 29000
		and z > 65000 and z < 78800 then	
		if select(3, GetUnitPower('boss1', POWERTYPE_HEALTH)) >= 72769370 then
			BSCHTKA.bVrolHM = true
		else
			BSCHTKA.bVrolHM = false
		end		
		BSCHTKA.bVrol = true			
		--  Vrol Show UI	
		if BSCHTKA.SV_ACC.SHOW_UI_BOSS then
			ResetUI(false)
			BSCHTKAHelperInfoUI:GetNamedChild("InfoTOP"):SetText(zo_strformat("<<1>> HM[<<2>>]", GetUnitName('boss1'), (BSCHTKA.bVrolHM and 'ON' or 'OFF')))
		end
	elseif x > 73700 and x < 84500
		and y > 6000 and y < 22500
		and z > 50200 and z < 61900 then	
		if select(3, GetUnitPower('boss1', POWERTYPE_HEALTH)) >= 248386060 then
			BSCHTKA.bFalgravenHM = true
		else
			BSCHTKA.bFalgravenHM = false
		end		
		BSCHTKA.bFalgraven = true		
		-- Falgraven Show UI
		if BSCHTKA.SV_ACC.SHOW_UI_BOSS then
			ResetUI(false)
			BSCHTKAHelperInfoUI:GetNamedChild("InfoTOP"):SetText(zo_strformat("<<1>> HM[<<2>>]", GetUnitName('boss1'), (BSCHTKA.bFalgravenHM and 'ON' or 'OFF')))
		end
	else --
		BSCHTKA.bYandir = false
		BSCHTKA.bVrol = false
		BSCHTKA.bFalgraven = false		
		ResetUI(true)
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Power Update Change
local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	local bpt = powerValue / powerMax * 100		
	if BSCHTKA.bYandir then
		if bpt < 60.0 and BSCHTKA.GRYPHON_TIME - os.time() >= 0 then
			if not BSCHTKA.bGRYPHON_SKIP then
				BSCHTKA.bGRYPHON_SKIP_TIME = os.time()
			end
			BSCHTKA.bGRYPHON_SKIP = true
		end
		if bpt > 60.0 and BSCHTKA.GRYPHON_TIME - os.time() < 0 then
			if BSCHTKA.bGRYPHON_SKIP_FAILHP == 0 then
				BSCHTKA.bGRYPHON_SKIP_FAILHP = bpt
			end
		end
	end	
	if BSCHTKA.bVrol then
		if bpt < 50.0 then		
			BSCHTKA.bPORTAL_END = true
		end
	end
	if BSCHTKA.bFalgraven and BSCHTKA.SV_ACC.SHOW_UI_PERCENT then	
		-- 95 - 90
		if bpt <= 93.0 and bpt >= 90.0 then
			if BSCHTKAUIBossP:IsHidden() then BSCHTKAUIBossP:SetHidden(false) end
			BSCHTKAUIBossP:GetNamedChild("BossPercent"):SetText("Connect Soon! (90% / "..string.format("%.1f", bpt).."%)")
		-- 85 - 80
		elseif bpt <= 83.0 and bpt >= 80.0 then
			if BSCHTKAUIBossP:IsHidden() then BSCHTKAUIBossP:SetHidden(false) end
			BSCHTKAUIBossP:GetNamedChild("BossPercent"):SetText("Connect Soon! (80% / "..string.format("%.1f", bpt).."%)")
		-- 75 - 70
		elseif bpt <= 73.0 and bpt >= 70.0 then
			if BSCHTKAUIBossP:IsHidden() then BSCHTKAUIBossP:SetHidden(false) end
			BSCHTKAUIBossP:GetNamedChild("BossPercent"):SetText("Dont Ult (Floor Shatter)! (70% / "..string.format("%.1f", bpt).."%)")
		-- 40 - 35
		elseif bpt <= 38.0 and bpt >= 35.0 then
			if BSCHTKA.CURRENT_STAGE < 3 then 
				if BSCHTKAUIBossP:IsHidden() then BSCHTKAUIBossP:SetHidden(false) end
				BSCHTKAUIBossP:GetNamedChild("BossPercent"):SetText("Dont Ult! (35% / "..string.format("%.1f", bpt).."%)")
			end
		else --bpt < 35.0 then -- hide		
			if not BSCHTKAUIBossP:IsHidden() then BSCHTKAUIBossP:SetHidden(true) end
		end
	end	
	if not IsUnitInCombat('player') then CheckHM() end	
end
-- Location Check
local function OnBossesChanged(_, forceReset)	
	local zone, x, y, z = GetUnitWorldPosition("player")	
	if zone ~= 1196 then 
		
		return 
	end	
	--d("OnBossesChanged")
	if forceReset then	-- force reset
		--d("Force Reset")
		BSCHTKA.bStartListening = false
		BSCHTKA:Yandir_Reset()
		BSCHTKA:Vrol_Reset()
		BSCHTKA:Falg_Reset()
		BSCHTKA.DisableAllTorturerIcons()		
		ALERT_LIST = { }
	end 
	
	if x > 63200 and x < 68900
		and y > 24300 and y < 26300
		and z > 90500 and z < 99600 then		
		if select(3, GetUnitPower('boss1', POWERTYPE_HEALTH)) >= 72769370 then
			BSCHTKA.bYandirHM = true
		else
			BSCHTKA.bYandirHM = false
		end		
		BSCHTKA.bYandir = true
		-- YANDIR Show UI
		if BSCHTKA.SV_ACC.SHOW_UI_BOSS then
			ResetUI(false)
			BSCHTKAHelperInfoUI:GetNamedChild("InfoTOP"):SetText(zo_strformat("<<1>> HM[<<2>>]", GetUnitName('boss1'), (BSCHTKA.bYandirHM and 'ON' or 'OFF')))	
		end
	elseif x > 110200 and x < 118500
		and y > 24500 and y < 29000
		and z > 65000 and z < 78800 then	
		if select(3, GetUnitPower('boss1', POWERTYPE_HEALTH)) >= 72769370 then
			BSCHTKA.bVrolHM = true
		else
			BSCHTKA.bVrolHM = false
		end		
		BSCHTKA.bVrol = true			
		--  Vrol Show UI	
		ResetUI(false)
		BSCHTKAHelperInfoUI:GetNamedChild("InfoTOP"):SetText(zo_strformat("<<1>> HM[<<2>>]", GetUnitName('boss1'), (BSCHTKA.bVrolHM and 'ON' or 'OFF')))	
	elseif x > 73700 and x < 84500
		and y > 6000 and y < 22500
		and z > 50200 and z < 61900 then	
		if select(3, GetUnitPower('boss1', POWERTYPE_HEALTH)) >= 248386060 then
			BSCHTKA.bFalgravenHM = true
		else
			BSCHTKA.bFalgravenHM = false
		end		
		BSCHTKA.bFalgraven = true		
		-- Falgraven Show UI	
		if BSCHTKA.SV_ACC.SHOW_UI_BOSS then
			ResetUI(false)
			BSCHTKAHelperInfoUI:GetNamedChild("InfoTOP"):SetText(zo_strformat("<<1>> HM[<<2>>]", GetUnitName('boss1'), (BSCHTKA.bFalgravenHM and 'ON' or 'OFF')))
		end
	else --
		BSCHTKA.bYandir = false
		BSCHTKA.bVrol = false
		BSCHTKA.bFalgraven = false
		ResetUI(true)
		BSCHTKA.RemovePortalIcon()
	end
end
local function OnCombatState(_, inCombat)	
	if inCombat then
		if not BSCHTKA.bStartListening then
			BSCHTKA:Yandir_Reset()
			BSCHTKA:Vrol_Reset()
			BSCHTKA:Falg_Reset()
		end
		BSCHTKA.bStartListening = true
	else
		zo_callLater(
			function() 
				if (not IsUnitInCombat("player")) then  
					BSCHTKA.DisableAllTorturerIcons()
					BSCHTKA.bStartListening = false
				end 
			end, 
		2500)		
	end
end
local register_vka = false
local function OnPlayerActivated()
	local zoneId = GetUnitWorldPosition("player") 		
	if zoneId == 1196 then			
		-- Init Icons
		zo_callLater(function() BSCHTKA.CreateAllIcons() end, 10000)
		register_vka = true
		OnBossesChanged(nil, true)
		EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name, EVENT_PLAYER_COMBAT_STATE, OnCombatState)	
		EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name, EVENT_BOSSES_CHANGED, 	OnBossesChanged)	
		EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name, EVENT_POWER_UPDATE,	OnPowerUpdate)	
		EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
		EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")		
		EVENT_MANAGER:RegisterForUpdate(BSCHTKA.Name, 200, UpdateUI)
	elseif register_vka then
		register_vka = false		
		EVENT_MANAGER:UnregisterForEvent(BSCHTKA.Name, EVENT_BOSSES_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(BSCHTKA.Name, EVENT_POWER_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(BSCHTKA.Name, EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:UnregisterForUpdate(BSCHTKA.Name)
		BSCHTKA.bYandir = false
		BSCHTKA.bVrol = false
		BSCHTKA.bFalgraven = false
		ResetUI(true)
		BSCHTKAUIBossP:SetHidden(true)
		BSCHTKA.bStartListening = false
		BSCHTKA.DisableAllTorturerIcons()			
		zo_callLater(function() BSCHTKA.DeleteAllIcons() end, 1000)
	end
end
function BSCHTKA:OnMoveStop()
	BSCHTKA.SV_ACC.UI_LEFT_I = BSCHTKAHelperInfoUI:GetLeft()
	BSCHTKA.SV_ACC.UI_TOP_I = BSCHTKAHelperInfoUI:GetTop()
end
function BSCHTKA:BossOnMoveStop()
	BSCHTKA.SV_ACC.UI_LEFT_B = BSCHTKAUIBossP:GetLeft()
	BSCHTKA.SV_ACC.UI_TOP_B = BSCHTKAUIBossP:GetTop()
end
local function RestorePosition()
	if BSCHTKA.SV_ACC.UI_LEFT_I ~= -15 and BSCHTKA.SV_ACC.UI_TOP_I ~= 500 then
		BSCHTKAHelperInfoUI:ClearAnchors()
		BSCHTKAHelperInfoUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCHTKA.SV_ACC.UI_LEFT_I, BSCHTKA.SV_ACC.UI_TOP_I)
		BSCHTKAHelperInfoUI:SetMovable(not BSCHTKA.SV_ACC.LOCK_UI_I)
	end	
	if BSCHTKA.SV_ACC.UI_LEFT_B ~= 0 and BSCHTKA.SV_ACC.UI_TOP_B ~= -165 then
		BSCHTKAUIBossP:ClearAnchors()
		BSCHTKAUIBossP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCHTKA.SV_ACC.UI_LEFT_B, BSCHTKA.SV_ACC.UI_TOP_B)
		BSCHTKAUIBossP:SetMovable(not BSCHTKA.SV_ACC.LOCK_UI_B)
	end
end
local defaultSV_ACC = {
	POISION_TOTEM = true,
	C_POISION_TOTEM = { 0, 0.8, 0, 0.4 },
	GARGYL_TOTEM = true,
	C_GARGYL_TOTEM = { 0.7, 0.7, 0.7, 0.4 },
	HEALING_YANDIR = true,
	C_HEALING_YANDIR = { 0.7, 0.2, 0.2, 1 },
	JUMP_YANDIR = true,
	C_JUMP_YANDIR = { 0.7, 0.7, 0.7, 0.4 },
	SEA_ADDER_BILE_SPRAY = false,
	C_SEA_ADDER_BILE = { 0.1, 0.8, 0.1, 0.4 },
	
	PORTAL_CAST_VROL = true,
	C_PORTAL_CAST_VROL = { 0.7, 0.2, 0.9, 0.4 },
	FOG_CAST_VROL = true,
	C_FOG_CAST_VROL = { 0.0, 0.0, 1, 0.4 },
	PORTAL_KTIME_VROL = true,
	C_PORTAL_KTIME_VROL = { 1, 0.7, 0, 0.5 },
	HARPOON_VROL = true,
	C_HARPOON_VROL = { 1, 0.7, 0, 0.5 },
	APOTHECARY_VROL = true,
	C_APOTHECARY_VROL = { 0, 0.6, 1, 1 }, 
	PORTAL_ICON_VROL = false,

	M_MOVE_FALGRAVN = true,
	C_M_MOVE_FALGRAVN = { 1, 0.7, 0, 0.5 },
	M_BLOCK_FALGRAVN = true,
	C_M_BLOCK_FALGRAVN = { 1, 0.7, 0, 0.5 },
	M_DODGE_FALGRAVN = false,
	C_M_DODGE_FALGRAVN = { 1, 0, 0.6, 0.8 },

	CONNECT_TIME_FALGRAVN = true,
	INSTABILITY_ICON = false,
	PRISON_ICON = false,
	EXECRATION_ICON = false, 

	PRISON_FALGRAVN = true,
	
	BLOOD_FOUNTAIN = true,
	C_BLOOD_FOUNTAIN = { 1, 0.2, 0.9, 0.8 },

	OPEN_DOOR_FALGRAVN = false,
	C_OPEN_DOOR_FALGRAVN =  { 0.7, 0.1, 0.1, 1 },--0x991111FF
	TUT_FEED_FALGRAVN = false,
	C_TUT_FEED_FALGRAVN = { 1, 0.7, 0, 0.5 },
	
	FALGRAVN_TORTURER_ESC = true,
	C_FALGRAVN_TORTURER_ESC = { 1, 0.7, 0, 1 }, --0xFF8800FF
	
	FALGRAVN_TORTURER_LA = true,
	C_FALGRAVN_TORTURER_LA = { 1, 0, 0, 1 }, --0xFF0000FF
	
	INFUSER_INFUSE = true,
	C_INFUSER_INFUSE = { 0.0, 0.0, 1, 0.8 },
	
	TUT_ODYICON_FALGRAVN = true,
	TUT_ODYICON_FALGRAVN_SIZE = 200,
	
	TUT_ODYICON_POS_FALGRAVN_ENABLE = true,
	TUT_ODYICON_POS_FALGRAVN_SIZE = 100,	
	TUT_ODYICON_POS_FALGRAVN_ENABLE_ALL = true,
	TUT_ODYICON_POS_FALGRAVN_POS = -1,
	
	BB_ODYICON_POS_FALGRAVN_ENABLE = true,
	BB_ODYICON_FALGRAVN_SIZE = 100,
	
	SHOW_UI_PERCENT = true,
	SHOW_UI_BOSS = true,
	LOCK_UI_I = false,
	LOCK_UI_B = false,
	
	UI_LEFT_I = -150,
	UI_TOP_I = 500,
	
	UI_LEFT_B = 0,
	UI_TOP_B = -165,
	
	USE_COLOR = false,
}
function BSCHTKA:AddAlertsList(uid, cid)
	ALERT_LIST[uid] = cid
end
local function OnCombatEvent_DIED( _, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, Blog, sourceUnitId, targetUnitId, abilityId, overflow )	
	local ability = zo_strformat("Ability Info[<<1>>][<<2>>] ", abilityId, GetAbilityName(abilityId))
	local action = zo_strformat("ActionResult[<<1>>]", result)
	local source_unit = zo_strformat("sourceType[<<1>>] sourceName[<<2>>] sourceUnitId[<<3>>]", sourceType, sourceName, sourceUnitId)
	local target_unit = zo_strformat("targetType[<<1>>] targetName[<<2>>] targetUnitId[<<3>>]", targetType, targetName, targetUnitId)
	local output = zo_strformat("<<1>> <<2>> <<3>> <<4>>", ability, action, source_unit, target_unit)
	
	if ALERT_LIST ~= nil and ALERT_LIST[sourceUnitId] ~= nil then 
		CombatAlerts.CastAlertsStop( ALERT_LIST[sourceUnitId] )
		BSCHTKA:PrintDebug(output)
		ALERT_LIST[sourceUnitId] = nil
	end	
	if ALERT_LIST ~= nil and ALERT_LIST[targetUnitId] ~= nil then 
		CombatAlerts.CastAlertsStop( ALERT_LIST[targetUnitId] )
		BSCHTKA:PrintDebug(output)
		ALERT_LIST[targetUnitId] = nil
	end	
	if BSCHTKA.PosionTotemID == sourceUnitId or BSCHTKA.PosionTotemID == targetUnitId then
		BSCHTKA.PosionTotemID = -1
		--BSCHTKA.PosionTotemIDSC = -1		
		BSCHTKA.BTotemCall = false
	end
end
function BSCHTKA.init(event, addonName)	
	if addonName ~= BSCHTKA.Name then
		return 
	end	
	EVENT_MANAGER:UnregisterForEvent(BSCHTKA.Name, 	EVENT_ADD_ON_LOADED)	
	EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	
	-- Get Saved Data	
	BSCHTKA.SV_ACC = ZO_SavedVars:NewAccountWide(BSCHTKA.SavedVar, BSCHTKA.Version, nil, defaultSV_ACC)	
	
	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)
		
	-- Command
	SLASH_COMMANDS['/bsckaha'] = SlashCommand
	
	-- Init Icons
	--zo_callLater(function() BSCHTKA.CreateAllIcons() end, 10000)
	
	-- UI Position
	RestorePosition()
	
	-- Init Bosses
	BSCHTKA:Init_Yandir()
	BSCHTKA:Init_Vrol()
	BSCHTKA:Init_Falgraven()
	
	BSCHTKA:InitMenu()
	
	-- Trigger on mob died
	EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name.."DIED", 	EVENT_COMBAT_EVENT, OnCombatEvent_DIED)
	EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name.."DIED", 	EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)
end

EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name, EVENT_ADD_ON_LOADED, BSCHTKA.init)