BSCHTKAHelper = BSCHTKAHelper or {}
local BSCHTKA = BSCHTKAHelper
 
local INFUSER_CASTS			= 137289 -- Trash Mob
local INFUSER_BUFF			= 139961 -- Buff mob...

local FALGRAVN_LIGHTNING	= 133428 -- 90% and 80% call (start countdown there)
local FALGRAVN_OPEN_DOOR 	= 136693
local FALGRAVN_TUT_FEED 	= 137314
local FALGRAVN_PRISON		= 132473
local FALGRAVN_M_MOVE		= 136965
local FALGRAVN_M_BLOCK		= 136953
local FALGRAVN_M_CLEAVE		= 136976
local FALGRAVN_BLOOD_FOUNT 	= 140294
local FALGRAVN_TORTURER_ESC = 139633 -- buff Torturer comes down!
local FALGRAVN_START_STAGE2 = 135271 -- Channel on the Conduits - (Second Stage)
local FALGRAVN_SHATTER_MID  = 136727 -- Floor Shatter MID - (Last Stage)
local FALGRAVN_INSTABILITY 	= 140944 --
local FALGRAVN_INSTABILITY2 = 140941 -- Non HM
local FALGRAVN_UNW_POWER	= 139378 -- Unwavering Power (20 sec untill hemorr)
local FALGRAVN_BLOOTBALL 	= 136548 --132934 -- dont move Shit
local FALGRAVN_PULSE		= 134854 -- If This Fades Visible of Stacsk can be off
local FALGRAVN_HM			= 137215 -- Lord Falgraven HM
local FALGRAVN_PRISONER_F	= 137315 -- Debuff count on prissoners if fail..
local FALGRAVN_BLOPSYNERGIE = 129936 -- Execration synergie
local FALGRAVN_PULSE_STACK  = 134856 -- Stacks Count on player self

local FALGRAVN_SACRIFICE	= 139620 -- Saved the guy
--local FALGRAVN_DEATHTRIGGER = -1 -- lose this failed to save

local FALGRAVN_TORTURER_LA  = 136958

local FALGRAVN_IDS = { }
table.insert(FALGRAVN_IDS, { en = "FPR", id = FALGRAVN_PRISON, 		event = EVENT_EFFECT_CHANGED, 	result = 0 }) -- Prison Effect gain Duration (8sec)
table.insert(FALGRAVN_IDS, { en = "FOD", id = FALGRAVN_OPEN_DOOR, 		event = EVENT_COMBAT_EVENT, 	result = ACTION_RESULT_BEGIN }) -- Falgraven cast open door (RUNN) -- Open Door Every 40~ sec
table.insert(FALGRAVN_IDS, { en = "FTF", id = FALGRAVN_TUT_FEED, 		event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Time to Kill Add (Feed skill)
table.insert(FALGRAVN_IDS, { en = "FMM", id = FALGRAVN_M_MOVE, 			event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Ground Shit
table.insert(FALGRAVN_IDS, { en = "FMB", id = FALGRAVN_M_BLOCK, 		event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Block Shit
table.insert(FALGRAVN_IDS, { en = "FLI", id = FALGRAVN_LIGHTNING, 		event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Conntect stuff
table.insert(FALGRAVN_IDS, { en = "FPU", id = FALGRAVN_PULSE, 			event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Dissable all position icons
table.insert(FALGRAVN_IDS, { en = "FBF", id = FALGRAVN_BLOOD_FOUNT, 	event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Block Bloof fountain
table.insert(FALGRAVN_IDS, { en = "FSM", id = FALGRAVN_SHATTER_MID, 	event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Start Stage 3
table.insert(FALGRAVN_IDS, { en = "FSS", id = FALGRAVN_START_STAGE2, 	event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Start Stage 2
table.insert(FALGRAVN_IDS, { en = "ICA", id = INFUSER_CASTS,			event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Infuser Cast
table.insert(FALGRAVN_IDS, { en = "IBU", id = INFUSER_BUFF, 			event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Infuser Buff
table.insert(FALGRAVN_IDS, { en = "FUP", id = FALGRAVN_UNW_POWER, 		event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Falgravn landing
table.insert(FALGRAVN_IDS, { en = "FINC", id = FALGRAVN_INSTABILITY, 	event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Instability countdown --ACTION_RESULT_EFFECT_GAINED_DURATION
table.insert(FALGRAVN_IDS, { en = "FBO", id = FALGRAVN_BLOOTBALL, 		event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Blood Ball Testing
table.insert(FALGRAVN_IDS, { en = "FHM", id = FALGRAVN_HM,				event = EVENT_COMBAT_EVENT, 	result = -1 }) -- 	
table.insert(FALGRAVN_IDS, { en = "FSF", id = FALGRAVN_SACRIFICE,		event = EVENT_COMBAT_EVENT, 	result = -1 }) -- 
table.insert(FALGRAVN_IDS, { en = "FINE1", id = FALGRAVN_INSTABILITY,	event = EVENT_EFFECT_CHANGED, 	result = 0 }) -- 	
table.insert(FALGRAVN_IDS, { en = "FINE2", id = FALGRAVN_INSTABILITY2,	event = EVENT_EFFECT_CHANGED, 	result = 0 }) -- 	
table.insert(FALGRAVN_IDS, { en = "FPSE", id = FALGRAVN_PRISONER_F,		event = EVENT_EFFECT_CHANGED, 	result = 0 })
--table.insert(FALGRAVN_IDS, { en = "FPSC", id = FALGRAVN_PULSE_STACK,	event = EVENT_COMBAT_EVENT, 	result = -1 })
table.insert(FALGRAVN_IDS, { en = "FMC", id = FALGRAVN_M_CLEAVE, 		event = EVENT_COMBAT_EVENT, 	result = ACTION_RESULT_BEGIN }) -- Mini Blood Cleave
table.insert(FALGRAVN_IDS, { en = "TLA", id = FALGRAVN_TORTURER_LA, 	event = EVENT_COMBAT_EVENT, 	result = ACTION_RESULT_BEGIN }) -- Torturer LA
table.insert(FALGRAVN_IDS, { en = "FTE", id = FALGRAVN_TORTURER_ESC, 	event = EVENT_COMBAT_EVENT, 	result = -1 }) -- Torturer comes down
table.insert(FALGRAVN_IDS, { en = "FTE", id = FALGRAVN_BLOPSYNERGIE,	event = EVENT_EFFECT_CHANGED, 	result = 0 })

-- Icon Lightning
local ICON_LBOLT = "/esoui/art/icons/ability_skeevatonschock.dds"
local ICON_PRISON = "/esoui/art/icons/ability_rogue_035.dds"
local ICON_EXECRATION = "/esoui/art/icons/ability_necromancer_016.dds"

local PRISONERS_LIST = { }
local function ResetPrisonersList()
	PRISONERS_LIST = { }
	PRISONERS_LIST["Brekalda"] = 0
	PRISONERS_LIST["Thjorlak"] = 0
	PRISONERS_LIST["Aevar"] = 0
	PRISONERS_LIST["Triveta"] = 0	
	PRISONERS_LIST["Skormgondar"] = 0
	PRISONERS_LIST["Irthrig"] = 0
	PRISONERS_LIST["Ama"] = 0
	PRISONERS_LIST["Sislea"] = 0
end

-- 275984480 Max HP
--
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BSCHTKA.CURRENT_STAGE = 1
local NEXT_INSTABILITY = 22
local NEXT_BLOODBALL = 45  
local NEXT_OPENGATE_TIME = 45
local NEXT_TORTURER_TP_COUNTER = 25
local b_EnablePosIcons = false
local TorturerCount = 8

BSCHTKA.OPEN_GATES_TIME = 0
BSCHTKA.TORTURER_TP = 0
BSCHTKA.INSTABILITY_TIME = 10
BSCHTKA.BLOODBALL_TIME = 0
function BSCHTKA:Falg_Reset()	
	b_startTorturerCD = true		
	bMove = true
	bBlock = true
	bConnect = true
	BSCHTKA.CURRENT_STAGE = 1
	TorturerCount = 8
	BSCHTKA.INSTABILITY_TIME = os.time() + 10
	b_EnablePosIcons = false
	BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText("")
	BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText("")
	BSCHTKAHelperInfoUI:GetNamedChild("Info3"):SetText("")
	BSCHTKAHelperInfoUI:GetNamedChild("Info4"):SetText("")
	
	BSCHTKA.DisableAllPosIconBlood()	
	BSCHTKA.DisableAllPosIconConn()
	ResetPrisonersList()
end

function BSCHTKA:Falg_UpdateUI()	
	local CDTime = 0	
	if BSCHTKA.CURRENT_STAGE == 1 then
		-- Lightning
		CDTime = BSCHTKA.INSTABILITY_TIME - os.time()
		if CDTime < 0 then
			BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText("Instability: SOON!!")
		else
			BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText(zo_strformat("Instability: <<1>>", ZO_FormatCountdownTimer(CDTime)))
		end
	elseif BSCHTKA.CURRENT_STAGE == 2 then
		-- Lightning
		CDTime = BSCHTKA.INSTABILITY_TIME - os.time()
		if CDTime < 0 then
			BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText("Instability: SOON!!")
		else
			BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText(zo_strformat("Instability: <<1>>", ZO_FormatCountdownTimer(CDTime)))
		end
		-- Hemorrhage
		CDTime = BSCHTKA.BLOODBALL_TIME - os.time()
		if CDTime < 0 then
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText("Blood Ball: SOON!!")
		else
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText(zo_strformat("Blood Ball: <<1>>", ZO_FormatCountdownTimer(CDTime)))
		end	
	elseif BSCHTKA.CURRENT_STAGE == 3 then
		-- Open the Gates
		CDTime = BSCHTKA.OPEN_GATES_TIME - os.time()
		if CDTime < 0 then
			BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText("Open Gates: SOON!!")
		else
			BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText(zo_strformat("Open Gates: <<1>>", ZO_FormatCountdownTimer(CDTime)))
		end
		-- Cooldown for Torturer comes down	
		CDTime = BSCHTKA.TORTURER_TP - os.time()
		if CDTime < 0 then
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText("")
		else
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText(zo_strformat("Torturer Comes Down: <<1>>", ZO_FormatCountdownTimer(CDTime)))
		end	
	end
end

local b_startTorturerCD = true
local bMove = true
local bBlock = true
local bConnect = true
local nConnectCAID = -1
local function OnCombatEvent( _, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	local TargetUnitNameByID = LibUnitTracker:GetUnitNameByUnitId(targetUnitId)
	local SourceUnitNameByID = LibUnitTracker:GetUnitNameByUnitId(sourceUnitId)
	
	--/script CombatAlerts.AlertCast( 136817, "Block!!", 1200, { -3, 0, false, { 0.7, 0.7, 0.7, 0.4 }, { 0.7, 0.7, 0.7, 0.8 } } )	
	-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	-- Infuser (Trash)
	if abilityId == INFUSER_CASTS and BSCHTKA.SV_ACC.INFUSER_INFUSE then 
		if result == ACTION_RESULT_BEGIN then		
			local cid = -1
			if BSCHTKA.SV_ACC.USE_COLOR then
				cid = CombatAlerts.AlertCast( abilityId, sourceName, 1000, { -3, 0, false, { unpack(BSCHTKA.SV_ACC.C_INFUSER_INFUSE) }, { BSCHTKA.SV_ACC.C_INFUSER_INFUSE[1], BSCHTKA.SV_ACC.C_INFUSER_INFUSE[2], BSCHTKA.SV_ACC.C_INFUSER_INFUSE[3], 1 } } )		
			else
				cid = CombatAlerts.AlertCast( abilityId, sourceName, 1000, { -3, 0, false, { 0.0, 0.0, 1, 0.4 }, { 0.1, 0.1, 1, 0.8 } } )
			end
			BSCHTKA:AddAlertsList(sourceUnitId, cid)			
		end
	end
	if abilityId == INFUSER_BUFF and BSCHTKA.SV_ACC.INFUSER_INFUSE then 
		if result == ACTION_RESULT_EFFECT_GAINED then
			CombatAlerts.Alert(nil, "Infuser Buff passed!", 0xFF8800FF, SOUNDS.DUEL_START, 3000)
		end
	end
	-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	-- HM Check
	if abilityId == FALGRAVN_HM and result == ACTION_RESULT_EFFECT_GAINED then
		BSCHTKA.bFalgravenHM = true
		BSCHTKAHelperInfoUI:GetNamedChild("InfoTOP"):SetText(zo_strformat("<<1>> HM[<<2>>]", GetUnitName('boss1'), (BSCHTKA.bFalgravenHM and 'ON' or 'OFF')))
	elseif abilityId == FALGRAVN_HM and result == ACTION_RESULT_EFFECT_FADED then		
		zo_callLater(
			function() 
				if (not IsUnitInCombat("player")) then  
					BSCHTKA.bFalgravenHM = false
					BSCHTKAHelperInfoUI:GetNamedChild("InfoTOP"):SetText(zo_strformat("<<1>> HM[<<2>>]", GetUnitName('boss1'), (BSCHTKA.bFalgravenHM and 'ON' or 'OFF')))
				end 
			end, 
		2000)
	end	
	-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	-- Lieutenant Njordal
	if abilityId == FALGRAVN_M_MOVE and BSCHTKA.SV_ACC.M_MOVE_FALGRAVN then --and result == ACTION_RESULT_BEGIN then	
		if result == ACTION_RESULT_BEGIN and bMove then
			local cid = -1
			if BSCHTKA.SV_ACC.USE_COLOR then
				cid = CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), 12000, 12000, { unpack(BSCHTKA.SV_ACC.C_M_MOVE_FALGRAVN) }, { 12000, "Move!", BSCHTKA.SV_ACC.C_M_MOVE_FALGRAVN[0], BSCHTKA.SV_ACC.C_M_MOVE_FALGRAVN[1], BSCHTKA.SV_ACC.C_M_MOVE_FALGRAVN[2], 1, SOUNDS.NONE} )
			else
				cid = CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), 12000, 12000, { 1, 0.7, 0, 0.5 }, { 12000, "Move!", 0.8, 0, 0, 0.9, SOUNDS.NONE} )
			end
			BSCHTKA:AddAlertsList(sourceUnitId, cid)
			bMove = false
		end
		if result == ACTION_RESULT_EFFECT_FADED and not bMove then
			bMove = true
		end
		BSCHTKA:PrintDebug(zo_strformat("abilityId[<<1>>] AbilityName[<<2>>] result[<<3>>] targetUnitId[<<4>>] namebyUnitId[<<5>>] sourceUnitId[<<6>>] sName[<<7>>]", abilityId, GetAbilityName(abilityId), result, targetUnitId, TargetUnitNameByID, sourceUnitId, SourceUnitNameByID))
		BSCHTKA:PrintDebug(zo_strformat("abilityId[<<1>>] AbilityName[<<2>>] sourceName[<<3>>] TargetName[<<4>>] result[<<5>>]", abilityId, GetAbilityName(abilityId), sourceName, targetName, result))
	end
	if abilityId == FALGRAVN_M_BLOCK and BSCHTKA.SV_ACC.M_BLOCK_FALGRAVN then --and result == ACTION_RESULT_BEGIN then
		if result == ACTION_RESULT_BEGIN and bBlock then
			local cid = -1
			if BSCHTKA.SV_ACC.USE_COLOR then
				cid = CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), 6000, 6000, { unpack(BSCHTKA.SV_ACC.C_M_BLOCK_FALGRAVN) }, { 6000, "Block Cast!", BSCHTKA.SV_ACC.C_M_BLOCK_FALGRAVN[1], BSCHTKA.SV_ACC.C_M_BLOCK_FALGRAVN[2], BSCHTKA.SV_ACC.C_M_BLOCK_FALGRAVN[3], 1, SOUNDS.NONE} )
			else
				cid = CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), 6000, 6000, { 1, 0.7, 0, 0.5 }, { 6000, "Block Cast!", 0.8, 0, 0, 0.9, SOUNDS.NONE} )
			end
			BSCHTKA:AddAlertsList(sourceUnitId, cid)
			bBlock = false
		end
		if result == ACTION_RESULT_EFFECT_FADED and not bBlock then
			bBlock = true
		end
		BSCHTKA:PrintDebug(zo_strformat("abilityId[<<1>>] AbilityName[<<2>>] result[<<3>>] targetUnitId[<<4>>] namebyUnitId[<<5>>] sourceUnitId[<<6>>] sName[<<7>>]", abilityId, GetAbilityName(abilityId), result, targetUnitId, TargetUnitNameByID, sourceUnitId, SourceUnitNameByID))
		BSCHTKA:PrintDebug(zo_strformat("abilityId[<<1>>] AbilityName[<<2>>] sourceName[<<3>>] TargetName[<<4>>] result[<<5>>]", abilityId, GetAbilityName(abilityId), sourceName, targetName, result))
	end	
	if abilityId == FALGRAVN_M_CLEAVE and BSCHTKA.SV_ACC.M_DODGE_FALGRAVN then
		if BSCHTKA.SV_ACC.USE_COLOR then
			CombatAlerts.CastAlertsStart(abilityId, sourceName, hitValue, hitValue, {  unpack(BSCHTKA.SV_ACC.C_M_DODGE_FALGRAVN) }, { 700, "DODGE!", BSCHTKA.SV_ACC.C_M_DODGE_FALGRAVN[1], BSCHTKA.SV_ACC.C_M_DODGE_FALGRAVN[2], BSCHTKA.SV_ACC.C_M_DODGE_FALGRAVN[3], 1, SOUNDS.CHAMPION_POINTS_COMMITTED} )
		else
			CombatAlerts.CastAlertsStart(abilityId, sourceName, hitValue, hitValue, { 1, 0, 0.6, 0.4 }, { 700, "DODGE!", 1, 0, 0.6, 0.8, SOUNDS.CHAMPION_POINTS_COMMITTED} )
		end				
	end
	
	-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	-- Falgraven stuff	
	if abilityId == FALGRAVN_INSTABILITY then		
		local tName = zo_strformat("<<1>>", targetName)
		local sName = zo_strformat("<<1>>", sourceName)
		--d(zo_strformat("sourceName[<<1>>] TargetName[<<2>>]", sourceName, targetName))
		if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
			BSCHTKA.INSTABILITY_TIME = os.time() + NEXT_INSTABILITY
		end
	end
	-- 90 - 80
	if abilityId == FALGRAVN_LIGHTNING then 
		if result == ACTION_RESULT_BEGIN and bConnect and BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE then
			--nConnectCAID = CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), 36000, 36000, { 1, 0.7, 0, 0.5 }, { 36000, "Connect!", 0.8, 0, 0, 0.9, SOUNDS.NONE} )
			bConnect = false
			BSCHTKA.EnableAllPosIconConn()
		end
		if result == ACTION_RESULT_EFFECT_FADED and bConnect == false and BSCHTKA.SV_ACC.TUT_ODYICON_POS_FALGRAVN_ENABLE  then
			bConnect = true
			--CombatAlerts.CastAlertsStop( nConnectCAID )
		end				
		BSCHTKA:PrintDebug(zo_strformat("abilityId[<<1>>] AbilityName[<<2>>] result[<<3>>] targetUnitId[<<4>>] namebyUnitId[<<5>>] sourceUnitId[<<6>>] sName[<<7>>]", abilityId, GetAbilityName(abilityId), result, targetUnitId, TargetUnitNameByID, sourceUnitId, SourceUnitNameByID))
		BSCHTKA:PrintDebug(zo_strformat("abilityId[<<1>>] AbilityName[<<2>>] sourceName[<<3>>] TargetName[<<4>>] result[<<5>>]", abilityId, GetAbilityName(abilityId), sourceName, targetName, result))
	end	
	--if abilityId == FALGRAVN_PULSE_STACK then 
		--d(zo_strformat("FALGRAVN_PULSE_STACK result[<<1>>] SourceUnitNameByID[<<2>>] TargetUnitNameByID[<<3>>] hitValue[<<4>>]", result, SourceUnitNameByID, TargetUnitNameByID, hitValue))		
	--end	
	-- Position Icons
	if abilityId == FALGRAVN_PULSE then
		if result == ACTION_RESULT_EFFECT_FADED then
			BSCHTKA.DisableAllPosIconConn()
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText("")
			BSCHTKAHelperInfoUI:GetNamedChild("Info3"):SetText("")
			BSCHTKAHelperInfoUI:GetNamedChild("Info4"):SetText("")
		end
	end	
	if abilityId == FALGRAVN_BLOOD_FOUNT and result == ACTION_RESULT_BEGIN and BSCHTKA.SV_ACC.BLOOD_FOUNTAIN then
		local sName = zo_strformat("<<1>>", sourceName)
		if BSCHTKA.SV_ACC.USE_COLOR then
			CombatAlerts.AlertCast( FALGRAVN_BLOOD_FOUNT, sName, 3033, { -3, 0, false, { unpack(BSCHTKA.SV_ACC.C_BLOOD_FOUNTAIN) }, { BSCHTKA.SV_ACC.C_BLOOD_FOUNTAIN[1], BSCHTKA.SV_ACC.C_BLOOD_FOUNTAIN[2], BSCHTKA.SV_ACC.C_BLOOD_FOUNTAIN[3], 1 } } )
		else
			CombatAlerts.AlertCast( FALGRAVN_BLOOD_FOUNT, sName, 3033, { -3, 0, false, { 1, 0.2, 0.9, 0.4 }, { 1, 0.2, 0.9, 0.8 } } )
		end
	end	
	-- Stage 2!! 
	if abilityId == FALGRAVN_UNW_POWER and result == ACTION_RESULT_EFFECT_FADED then
		BSCHTKA:PrintDebug("Falgraven Landing")
		BSCHTKA.BLOODBALL_TIME = os.time() + 20
		BSCHTKA.INSTABILITY_TIME = os.time() + 10		 
		if BSCHTKA.SV_ACC.BB_ODYICON_POS_FALGRAVN_ENABLE then 
			BSCHTKA.EnableAllPosIconBlood()
			b_EnablePosIcons = true
		end
	end
	-- Start dont Move Shit
	if abilityId == FALGRAVN_BLOOTBALL then
		if BSCHTKA.CURRENT_STAGE ~= 2 then BSCHTKA.CURRENT_STAGE = 2 end
		if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
			BSCHTKA.BLOODBALL_TIME = os.time() + 30
			if not b_EnablePosIcons and BSCHTKA.SV_ACC.BB_ODYICON_POS_FALGRAVN_ENABLE then 
				b_EnablePosIcons = true
				BSCHTKA.EnableAllPosIconBlood() 
			end
		end
		if result == ACTION_RESULT_EFFECT_FADED then
			BSCHTKA.BLOODBALL_TIME = os.time() + NEXT_BLOODBALL
		end
	end
	--
	if abilityId == FALGRAVN_START_STAGE2 and result == ACTION_RESULT_BEGIN then
		if BSCHTKA.CURRENT_STAGE ~= 2 then
			BSCHTKA.CURRENT_STAGE = 2
			BSCHTKA:PrintDebug("Stage 2")
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText("")
			BSCHTKAHelperInfoUI:GetNamedChild("Info3"):SetText("")
			BSCHTKAHelperInfoUI:GetNamedChild("Info4"):SetText("")
		end
	end	
	-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	-- STAGE 3!!! (Everything works fine)
	if abilityId == FALGRAVN_SHATTER_MID and result == ACTION_RESULT_BEGIN then
		if BSCHTKA.CURRENT_STAGE ~= 3 then
			BSCHTKA.DisableAllPosIconBlood()		
			b_EnablePosIcons = false
			BSCHTKA.CURRENT_STAGE = 3
			BSCHTKA:PrintDebug("Stage 3")
			BSCHTKA.OPEN_GATES_TIME = os.time() + 40
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText("")
			BSCHTKAHelperInfoUI:GetNamedChild("Info3"):SetText("")
			BSCHTKAHelperInfoUI:GetNamedChild("Info4"):SetText("")
			if BSCHTKA.SV_ACC.TUT_ODYICON_FALGRAVN then BSCHTKA.EnableAllTorturerIcons() end
		end
	end
	-- Opening gates time to kill Torturer
	if abilityId == FALGRAVN_OPEN_DOOR and result == ACTION_RESULT_BEGIN then
		BSCHTKA.OPEN_GATES_TIME = os.time() + NEXT_OPENGATE_TIME
		BSCHTKA.TORTURER_TP = os.time() + NEXT_TORTURER_TP_COUNTER
		if BSCHTKA.SV_ACC.OPEN_DOOR_FALGRAVN then
			if BSCHTKA.SV_ACC.USE_COLOR then
				CombatAlerts.Alert(nil, "Open the Gates!", BSCHTKA:BuildHexColor(BSCHTKA.SV_ACC.C_OPEN_DOOR_FALGRAVN), SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
			else
				CombatAlerts.Alert(nil, "Open the Gates!", 0x991111FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
			end
		end
	end
	if abilityId == FALGRAVN_TUT_FEED then
		BSCHTKA:PrintDebug(zo_strformat("abilityId[<<1>>] AbilityName[<<2>>] sourceName[<<3>>] TargetName[<<4>>] result[<<5>>]", abilityId, GetAbilityName(abilityId), sourceName, targetName, result))
		BSCHTKA:PrintDebug(zo_strformat("sourceType[<<1>>] targetType[<<2>>] sourceUnitId[<<3>>] targetUnitId[<<4>>]", sourceType, targetType, sourceUnitId, targetUnitId))
		local name = TargetUnitNameByID		
		if result == ACTION_RESULT_EFFECT_GAINED then
			if BSCHTKA.SV_ACC.TUT_FEED_FALGRAVN then
				if b_startTorturerCD then
					b_startTorturerCD = false
					if BSCHTKA.SV_ACC.USE_COLOR then
						CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), 10000, 10000, { unpack(BSCHTKA.SV_ACC.C_TUT_FEED_FALGRAVN) }, { 10000, "KILL Torturer!", BSCHTKA.SV_ACC.C_TUT_FEED_FALGRAVN[1], BSCHTKA.SV_ACC.C_TUT_FEED_FALGRAVN[2], BSCHTKA.SV_ACC.C_TUT_FEED_FALGRAVN[3], 1, SOUNDS.NONE} )
					else
						CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), 10000, 10000, { 1, 0.7, 0, 0.5 }, { 10000, "KILL Torturer!", 0.8, 0, 0, 0.9, SOUNDS.NONE} )
					end
				end
			end
			BSCHTKA.UpdateTorturerIcon(name, 0)			
		end
		if result == ACTION_RESULT_EFFECT_FADED then
			b_startTorturerCD = true
		end			
	end
	-- Saved NPC
	if abilityId == FALGRAVN_SACRIFICE then		
		TorturerCount = TorturerCount - 1
		BSCHTKA.UpdateTorturerIcon(TargetUnitNameByID, 1) 
	end	
	-- Failed to kill Torturer
	if abilityId == FALGRAVN_TORTURER_ESC and result == ACTION_RESULT_BEGIN and BSCHTKA.SV_ACC.FALGRAVN_TORTURER_ESC then
		if BSCHTKA.SV_ACC.USE_COLOR then
			CombatAlerts.Alert(nil, "Torturer Comes Down!", BSCHTKA:BuildHexColor(BSCHTKA.SV_ACC.C_FALGRAVN_TORTURER_ESC), SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
		else
			CombatAlerts.Alert(nil, "Torturer Comes Down!", 0xFF8800FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
		end		
	end	
	-- LA From Torturer
	if abilityId == FALGRAVN_TORTURER_LA and GetSelectedLFGRole() ~= LFG_ROLE_TANK and targetType == COMBAT_UNIT_TYPE_PLAYER then	
		if BSCHTKA.SV_ACC.USE_COLOR then
			CombatAlerts.Alert("Torturer LA's", "DODGE !", BSCHTKA:BuildHexColor(BSCHTKA.SV_ACC.C_FALGRAVN_TORTURER_LA), 1000)	
		else
			CombatAlerts.Alert("Torturer LA's", "DODGE !", 0xFF0000FF, 1000)	
		end
		PlaySound(SOUNDS.DUEL_START)
		PlaySound(SOUNDS.DUEL_START)
		PlaySound(SOUNDS.DUEL_START)
		PlaySound(SOUNDS.DUEL_START)
		PlaySound(SOUNDS.DUEL_START)
	end
end
local PrisonID = -1
local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType) 
	-- Prison
	if abilityId == FALGRAVN_PRISON then
		local displayName = zo_strformat("<<1>>", GetUnitDisplayName(unitTag))	 
		if changeType == EFFECT_RESULT_GAINED then
			if BSCHTKA.SV_ACC.PRISON_FALGRAVN then
				local duration = 8000
				PrisonID = CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), duration, duration, { 1, 0.7, 0, 0.5 }, { duration, "KILL PRISON!", 0.8, 0, 0, 0.9, SOUNDS.NONE} )
			end
			if OSI and OSI.CreatePositionIcon and BSCHTKA.SV_ACC.PRISON_ICON then
				OSI.SetMechanicIconForUnit(displayName, ICON_PRISON, 2 * OSI.GetIconSize())
			end			
		end
		if changeType == EFFECT_RESULT_FADED then		
			if BSCHTKA.SV_ACC.PRISON_FALGRAVN then
				CombatAlerts.CastAlertsStop( PrisonID )
			end
			if OSI and OSI.CreatePositionIcon and BSCHTKA.SV_ACC.PRISON_ICON then
				OSI.RemoveMechanicIconForUnit( displayName )
			end
		end
	end
	-- Instability icon on players 	
	if abilityId == FALGRAVN_INSTABILITY2 or abilityId == FALGRAVN_INSTABILITY then
		if BSCHTKA.SV_ACC.INSTABILITY_ICON then
			local displayName = zo_strformat("<<1>>", GetUnitDisplayName(unitTag))	 
			if changeType == EFFECT_RESULT_GAINED then
				if OSI and OSI.CreatePositionIcon then
					OSI.SetMechanicIconForUnit(displayName, ICON_LBOLT, 2 * OSI.GetIconSize())
				end
			end
			if changeType == EFFECT_RESULT_FADED then
				if OSI and OSI.CreatePositionIcon then
					OSI.RemoveMechanicIconForUnit( displayName )
				end
			end
		end 
	end 
	-- Prissoners Dead?
	if abilityId == FALGRAVN_PRISONER_F then
		if changeType == EFFECT_RESULT_GAINED then
			local Name = zo_strformat("<<1>>", unitName)			
			if PRISONERS_LIST ~= nil and PRISONERS_LIST[Name] ~= nil then	
				PRISONERS_LIST[Name] = PRISONERS_LIST[Name] + 1
				if PRISONERS_LIST[Name] == 11 then
					TorturerCount = TorturerCount - 1
					BSCHTKA.UpdateTorturerIcon(Name, 3) 
				end	
			end
		end
	end
	-- Execration debuff on Player
	if abilityId == FALGRAVN_BLOPSYNERGIE then
		local displayName = zo_strformat("<<1>>", GetUnitDisplayName(unitTag))	 
		if changeType == EFFECT_RESULT_GAINED then
			if OSI and OSI.CreatePositionIcon and BSCHTKA.SV_ACC.EXECRATION_ICON then
				OSI.SetMechanicIconForUnit(displayName, ICON_PRISON, 2 * OSI.GetIconSize())
			end
		elseif changeType == EFFECT_RESULT_FADED then
			if OSI and OSI.CreatePositionIcon and BSCHTKA.SV_ACC.EXECRATION_ICON then
				OSI.RemoveMechanicIconForUnit( displayName )
			end
		end
	end
end
function BSCHTKA:Init_Falgraven()
	for i, v in ipairs(FALGRAVN_IDS) do
		if v.id ~= -1 then
			if v.event == EVENT_COMBAT_EVENT then
				EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name..v.en, 	v.event, OnCombatEvent)
				if v.result ~= -1 then
					EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name..v.en, v.event, REGISTER_FILTER_COMBAT_RESULT, v.result)
				end	
			elseif v.event == EVENT_EFFECT_CHANGED then
				EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name..v.en, 	v.event, OnEffectChanged)	
				if v.result ~= -1 then		
					EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name..v.en, v.event, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")	
				end
				if v.result == 1 then		
					EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name..v.en, v.event, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")	
				end
			end						
			EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name..v.en, v.event, REGISTER_FILTER_ABILITY_ID, v.id)		
		end
	end	
end