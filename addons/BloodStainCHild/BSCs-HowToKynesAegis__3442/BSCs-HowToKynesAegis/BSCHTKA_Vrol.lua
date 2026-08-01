BSCHTKAHelper = BSCHTKAHelper or {}
local BSCHTKA = BSCHTKAHelper

local VROL_PORTAL_CAST 	= 133994
local VROL_FOG_CAST 	= 133808
local VROL_PORTAL_KTIME = 134016
local VROL_HARPOON		= 133913
local VROL_APOTHECARY	= 140255

-- 136941 -- Portal From Fireshit
local NEXT_PORTAL_TIME 	= 45
local NEXT_CONDUIT_TIME = 40
local NEXT_FOG_TIME 	= 30

-- Captain Vrol Boss
local VROL_IDS = { }
table.insert(VROL_IDS, { id = VROL_PORTAL_CAST, 	event = EVENT_COMBAT_EVENT, 	result = ACTION_RESULT_BEGIN }) -- Ready For Portal! (First Portal 15 sec)
table.insert(VROL_IDS, { id = VROL_FOG_CAST, 		event = EVENT_COMBAT_EVENT, 	result = ACTION_RESULT_BEGIN }) -- Cast Fog
table.insert(VROL_IDS, { id = VROL_PORTAL_KTIME,	event = EVENT_EFFECT_CHANGED, 	result = -1 }) 					-- Portal Time to Kill
table.insert(VROL_IDS, { id = VROL_HARPOON,			event = EVENT_COMBAT_EVENT, 	result = -1 }) 					-- Cast ID of Harpoon
table.insert(VROL_IDS, { id = VROL_APOTHECARY,		event = EVENT_COMBAT_EVENT, 	result = ACTION_RESULT_BEGIN }) -- 

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BSCHTKA.PORTAL_TIME = 0
BSCHTKA.CONDUIT_TIME = 0
BSCHTKA.FOG_TIME = 0
BSCHTKA.bPORTAL_END = false
function BSCHTKA:Vrol_Reset()
	BSCHTKA.PORTAL_TIME = os.time() + 15
	BSCHTKA.CONDUIT_TIME = os.time() + NEXT_CONDUIT_TIME
	BSCHTKA.FOG_TIME = os.time() + NEXT_FOG_TIME
	BSCHTKA.bPORTAL_END = false	
	if BSCHTKA.SV_ACC.PORTAL_ICON_VROL then zo_callLater(function() BSCHTKA.AddPortalIcon() end, 3100) end
end

-- Fight start Portal Spawn 15 sec
-- Next Portal Spawn every 45 sec
-- Harpoon every 40 sec
-- UI Info
function BSCHTKA:Vrol_UpdateUI()
	local CDTime = BSCHTKA.FOG_TIME - os.time()
	if CDTime < 0 then
		BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText("Fog Spawn: SOON!!")
	else
		BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText(zo_strformat("Fog Spawn: <<1>>", ZO_FormatCountdownTimer(CDTime)))
	end
	CDTime = BSCHTKA.CONDUIT_TIME - os.time()
	if CDTime < 0 then
		BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText("Conduit Spawn: SOON!!")
	else
		BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText(zo_strformat("Conduit Spawn: <<1>>", ZO_FormatCountdownTimer(CDTime)))
	end
	-- Portal
	CDTime = BSCHTKA.PORTAL_TIME - os.time()
	if CDTime < 0 then
		if BSCHTKA.bPORTAL_END then
			BSCHTKAHelperInfoUI:GetNamedChild("Info3"):SetText("")
		else
			BSCHTKAHelperInfoUI:GetNamedChild("Info3"):SetText(zo_strformat("Portal Spawn: <<1>>", "Portal SOON!"))
		end
	else
		BSCHTKAHelperInfoUI:GetNamedChild("Info3"):SetText(zo_strformat("Portal Spawn: <<1>>", ZO_FormatCountdownTimer(CDTime)))
	end
end

local function OnCombatEvent( _, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	-- Vrol stuff
	if abilityId == VROL_PORTAL_CAST and result == ACTION_RESULT_BEGIN then
		BSCHTKA.PORTAL_TIME = os.time() + NEXT_PORTAL_TIME
		if BSCHTKA.SV_ACC.PORTAL_CAST_VROL then -- Portal spawn
			if BSCHTKA.SV_ACC.USE_COLOR then
				CombatAlerts.AlertCast( VROL_PORTAL_KTIME, sourceName, 3000, { -3, 0, false, { unpack(BSCHTKA.SV_ACC.C_PORTAL_CAST_VROL) }, { BSCHTKA.SV_ACC.C_PORTAL_CAST_VROL[1], BSCHTKA.SV_ACC.C_PORTAL_CAST_VROL[2], BSCHTKA.SV_ACC.C_PORTAL_CAST_VROL[3], 1 } } )
			else
				CombatAlerts.AlertCast( VROL_PORTAL_KTIME, sourceName, 3000, { -3, 0, false, { 0.7, 0.2, 0.9, 0.4 }, { 0.7, 0.2, 0.9, 0.8 } } )
			end
		end
	end	
	if abilityId == VROL_FOG_CAST and result == ACTION_RESULT_BEGIN then
		BSCHTKA.FOG_TIME = os.time() + NEXT_FOG_TIME
		if BSCHTKA.SV_ACC.FOG_CAST_VROL then -- Cast Fog
			local cid = -1
			if BSCHTKA.SV_ACC.USE_COLOR then
				cid = CombatAlerts.AlertCast( abilityId, sourceName, 1000, { -3, 0, false, { unpack(BSCHTKA.SV_ACC.C_FOG_CAST_VROL) }, { BSCHTKA.SV_ACC.C_FOG_CAST_VROL[1], BSCHTKA.SV_ACC.C_FOG_CAST_VROL[2], BSCHTKA.SV_ACC.C_FOG_CAST_VROL[3], 1 } } )
			else
				cid = CombatAlerts.AlertCast( abilityId, sourceName, 1000, { -3, 0, false, { 0.0, 0.0, 1, 0.4 }, { 0.1, 0.1, 1, 0.8 } } )	
			end
			BSCHTKA:AddAlertsList(targetUnitId, cid)
		end
	end
	-- Kill Time Of Harpoon
	if abilityId == VROL_HARPOON then
		if result == ACTION_RESULT_BEGIN then -- Shocking Harpoon Timer to Kill it	
			BSCHTKA.CONDUIT_TIME = os.time() + NEXT_CONDUIT_TIME
			if BSCHTKA.SV_ACC.HARPOON_VROL then
				local cid = -1
				if BSCHTKA.SV_ACC.USE_COLOR then
					cid = CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), 16000, 16000, { unpack(BSCHTKA.SV_ACC.C_HARPOON_VROL) }, { 16000, "Harpoon!", BSCHTKA.SV_ACC.C_HARPOON_VROL[1], BSCHTKA.SV_ACC.C_HARPOON_VROL[2], BSCHTKA.SV_ACC.C_HARPOON_VROL[3], 1, SOUNDS.NONE} )
				else
					cid = CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), 16000, 16000, { 1, 0.7, 0, 0.5 }, { 16000, "Harpoon!", 0.8, 0, 0, 0.9, SOUNDS.NONE} )
				end			
				BSCHTKA:AddAlertsList(targetUnitId, cid)
			end
		end	
	end		
	if abilityId == VROL_APOTHECARY then
		if result == ACTION_RESULT_BEGIN then 			
			if BSCHTKA.SV_ACC.APOTHECARY_VROL then
				local cid = -1
				if BSCHTKA.SV_ACC.USE_COLOR then
					CombatAlerts.Alert(nil, "Interrupt Apothecary!", BSCHTKA:BuildHexColor(BSCHTKA.SV_ACC.C_APOTHECARY_VROL), SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
				else
					CombatAlerts.Alert(nil, "Interrupt Apothecary!", 0x0099FFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
				end
			end
		end
	end	
end
local portal_time = 0
local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType) 
	-- Vrol stuff
	if abilityId == VROL_PORTAL_KTIME and BSCHTKA.SV_ACC.PORTAL_KTIME_VROL then -- Time To Kill Portal
		if GetLocalPlayerGroupUnitTag() == unitTag then			
			if changeType == EFFECT_RESULT_GAINED then -- Start Countdown
				portal_time = GetGameTimeMilliseconds() + 20000
				if BSCHTKA.SV_ACC.USE_COLOR then
					CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), 20000, 20000, { unpack(BSCHTKA.SV_ACC.C_PORTAL_KTIME_VROL) }, { 20000, "KILL Conjurer!", BSCHTKA.SV_ACC.C_PORTAL_KTIME_VROL[1], BSCHTKA.SV_ACC.C_PORTAL_KTIME_VROL[2], BSCHTKA.SV_ACC.C_PORTAL_KTIME_VROL[3], 1, SOUNDS.NONE} ) 
				else
					CombatAlerts.CastAlertsStart(abilityId, GetFormattedAbilityName(abilityId), 20000, 20000, { 1, 0.7, 0, 0.5 }, { 20000, "KILL Conjurer!", 0.8, 0, 0, 0.9, SOUNDS.NONE} )
				end
			end			
			if changeType == EFFECT_RESULT_FADED then -- Portal Check			
				if portal_time > GetGameTimeMilliseconds() then
					if BSCHTKA.SV_ACC.USE_COLOR then
						CombatAlerts.Alert(nil, "Portal OK!", BSCHTKA:BuildHexColor(BSCHTKA.SV_ACC.C_APOTHECARY_VROL), SOUNDS.DUEL_WON, 2000)
					else
						CombatAlerts.Alert(nil, "Portal OK!", 0x119911FF, SOUNDS.DUEL_WON, 2000)	
					end
				else
					if BSCHTKA.SV_ACC.USE_COLOR then
						CombatAlerts.Alert(nil, "Portal Failed!", BSCHTKA:BuildHexColor(BSCHTKA.SV_ACC.C_APOTHECARY_VROL), SOUNDS.DUEL_FORFEIT, 2000)
					else
						CombatAlerts.Alert(nil, "Portal Failed!", 0x991111FF, SOUNDS.DUEL_FORFEIT, 2000)	
					end
				end
			end
		end
	end
end
function BSCHTKA:Init_Vrol()
	for i, v in ipairs(VROL_IDS) do
		if v.id ~= -1 then
			if v.event == EVENT_COMBAT_EVENT then	
				EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name..v.id, 	v.event, OnCombatEvent)
			elseif v.event == EVENT_EFFECT_CHANGED then
				EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name..v.id, 	v.event, OnEffectChanged)			
				EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name..v.id, v.event, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")	
			end
						
			EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name..v.id, v.event, REGISTER_FILTER_ABILITY_ID, v.id)	
			if v.result ~= -1 and v.event == EVENT_COMBAT_EVENT then
				EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name..v.id, v.event, REGISTER_FILTER_COMBAT_RESULT, v.result)
			end				
		end
	end
end