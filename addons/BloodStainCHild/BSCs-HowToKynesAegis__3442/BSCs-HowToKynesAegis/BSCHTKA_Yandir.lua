BSCHTKAHelper = BSCHTKAHelper or {}
local BSCHTKA = BSCHTKAHelper

local TOTEM_POISION 	= 133515 -- Chaurus Totem Spawn
local TOTEM_POISION_CP 	= 133559 -- Chaurus Totem cast posion (start Timer for second poision)
local TOTEM_HARPY_SPWN	= 133510 -- Harpy Totem Spawn
local TOTEM_DRAGON_SPWN = 133045 -- Dragon Totem Spawn
local TOTEM_GARGYL_SPWN = 133513 -- Gargoyle Totem
local TOTEM_GARGYL 		= 133546
local YANDIR_HEALING 	= 133242
local YANDIR_JUMP		= 132571
local GRYPHON_SPAWN_ID 	= 136855
local SEA_ADDER_BILE_SPRAY = 136591

local TOTEM_SPAWN_TIME   = 20	-- Possible Totem Every 20 sec
local GRYPHON_SPAWN_TIME = 60	-- 1 Minute Until Gryfon spawn

local YANDIR_IDS = { }
table.insert(YANDIR_IDS, { id = TOTEM_POISION, 		event = EVENT_COMBAT_EVENT, result = ACTION_RESULT_BEGIN, ftarget = -1 })		 -- Posion Totem: Doge after 4,3 sec
table.insert(YANDIR_IDS, { id = TOTEM_POISION_CP, 	event = EVENT_COMBAT_EVENT, result = ACTION_RESULT_EFFECT_GAINED, ftarget = -1 })		 -- Posion Totem: Doge after 4,3 sec
table.insert(YANDIR_IDS, { id = TOTEM_GARGYL, 		event = EVENT_COMBAT_EVENT, result = ACTION_RESULT_BEGIN, ftarget = -1  })  	 -- Gargyl Totem: Block after 5 sec
table.insert(YANDIR_IDS, { id = YANDIR_HEALING, 	event = EVENT_COMBAT_EVENT, result = ACTION_RESULT_BEGIN, ftarget = -1  })	 	 -- After 10 sec? Cast Healing on Add
table.insert(YANDIR_IDS, { id = YANDIR_JUMP, 		event = EVENT_COMBAT_EVENT, result = ACTION_RESULT_BEGIN, ftarget = -1  })
table.insert(YANDIR_IDS, { id = TOTEM_HARPY_SPWN, 	event = EVENT_COMBAT_EVENT, result = ACTION_RESULT_BEGIN, ftarget = -1  })
table.insert(YANDIR_IDS, { id = TOTEM_DRAGON_SPWN, 	event = EVENT_COMBAT_EVENT, result = ACTION_RESULT_BEGIN, ftarget = -1  })
table.insert(YANDIR_IDS, { id = TOTEM_GARGYL_SPWN, 	event = EVENT_COMBAT_EVENT, result = ACTION_RESULT_BEGIN, ftarget = -1  })
table.insert(YANDIR_IDS, { id = SEA_ADDER_BILE_SPRAY, 	event = EVENT_COMBAT_EVENT, result = ACTION_RESULT_BEGIN, ftarget = COMBAT_UNIT_TYPE_PLAYER  })

BSCHTKA.TOTEM_TIME = 0 
BSCHTKA.GRYPHON_TIME = 0
BSCHTKA.bGRYPHON_SKIP = false
BSCHTKA.bGRYPHON_SKIP_TIME = -1 
BSCHTKA.bGRYPHON_SKIP_FAILHP = 0
function BSCHTKA:Yandir_Reset()
	BSCHTKA.TOTEM_TIME = os.time() + TOTEM_SPAWN_TIME
	BSCHTKA.GRYPHON_TIME = os.time() + GRYPHON_SPAWN_TIME
	BSCHTKA.bGRYPHON_SKIP = false
	BSCHTKA.bGRYPHON_SKIP_TIME = -1 
	BSCHTKA.bGRYPHON_SKIP_FAILHP = 0
	BSCHTKA.PosionTotemID = -1
	BSCHTKA.PosionTotemIDSC = -1
	BSCHTKA.BTotemCall = false
end
-- UI Info
function BSCHTKA:Yandir_UpdateUI()
	local CDTime = BSCHTKA.TOTEM_TIME - os.time()	
	if CDTime < 0 then
		BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText(zo_strformat("Totem Spawn: <<1>>", "TOTEM SOON!"))
	else
		BSCHTKAHelperInfoUI:GetNamedChild("Info1"):SetText(zo_strformat("Totem Spawn: <<1>>", ZO_FormatCountdownTimer(CDTime)))
	end
	--
	CDTime = BSCHTKA.GRYPHON_TIME - os.time()	
	if CDTime >= 0 then
		if BSCHTKA.bGRYPHON_SKIP then 
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText(zo_strformat("Gyphon Skip: <<1>> Left", ZO_FormatCountdownTimer(BSCHTKA.GRYPHON_TIME - BSCHTKA.bGRYPHON_SKIP_TIME)))
		else
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText(zo_strformat("Gyphon Spawn: <<1>>", ZO_FormatCountdownTimer(CDTime)))
		end
	else
		if not BSCHTKA.bGRYPHON_SKIP then
			BSCHTKAHelperInfoUI:GetNamedChild("Info2"):SetText(zo_strformat("Gyphon Skip Fail: <<1>>%", BSCHTKA.bGRYPHON_SKIP_FAILHP))
		end
	end
end
BSCHTKA.PosionTotemID = -1
--BSCHTKA.PosionTotemIDSC = -1
BSCHTKA.BTotemCall = false
local function OnCombatEvent( _, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	if abilityId == TOTEM_POISION and BSCHTKA.SV_ACC.POISION_TOTEM then -- Posion Totem
		local cid = -1
		if BSCHTKA.SV_ACC.USE_COLOR then
			cid = CombatAlerts.AlertCast( abilityId, sourceName, 4300, { -3, 0, false, { unpack(BSCHTKA.SV_ACC.C_POISION_TOTEM) }, { BSCHTKA.SV_ACC.C_POISION_TOTEM[1], BSCHTKA.SV_ACC.C_POISION_TOTEM[2], BSCHTKA.SV_ACC.C_POISION_TOTEM[3], 1 } } )
		else 
			cid = CombatAlerts.AlertCast( abilityId, sourceName, 4300, { -3, 0, false, { 0, 0.8, 0, 0.4 }, { 0, 0.8, 0, 0.8 } } )
		end
		BSCHTKA:AddAlertsList(targetUnitId, cid)
		BSCHTKA.PosionTotemID = targetUnitId
		--BSCHTKA.PosionTotemIDSC = sourceUnitId
	elseif abilityId == TOTEM_POISION_CP and BSCHTKA.SV_ACC.POISION_TOTEM then -- Posion Totem CD start for next
		if BSCHTKA.BTotemCall then return end
		BSCHTKA.BTotemCall = true
		zo_callLater(
			function() 
				--if BSCHTKA.PosionTotemID ~= -1 and BSCHTKA.PosionTotemIDSC ~= -1 and IsUnitInCombat('player') then
				if BSCHTKA.PosionTotemID ~= -1 and IsUnitInCombat('player') then
					BSCHTKA.BTotemCall = false
					if BSCHTKA.SV_ACC.USE_COLOR then
						cid = CombatAlerts.AlertCast( abilityId, sourceName, 4300, { -3, 0, false, { unpack(BSCHTKA.SV_ACC.C_POISION_TOTEM) }, { BSCHTKA.SV_ACC.C_POISION_TOTEM[1], BSCHTKA.SV_ACC.C_POISION_TOTEM[2], BSCHTKA.SV_ACC.C_POISION_TOTEM[3], 1 } } )
					else 
						cid = CombatAlerts.AlertCast( abilityId, sourceName, 4300, { -3, 0, false, { 0, 0.8, 0, 0.4 }, { 0, 0.8, 0, 0.8 } } )
					end
				end
			end, 
		26800)	
	elseif abilityId == TOTEM_GARGYL and BSCHTKA.SV_ACC.GARGYL_TOTEM then -- Gargyl Totem
		local cid = -1
		if BSCHTKA.SV_ACC.USE_COLOR then
			cid = CombatAlerts.AlertCast( abilityId, "Block!!", hitValue, { -3, 0, false, { unpack(BSCHTKA.SV_ACC.C_GARGYL_TOTEM) }, { BSCHTKA.SV_ACC.C_GARGYL_TOTEM[1], BSCHTKA.SV_ACC.C_GARGYL_TOTEM[2], BSCHTKA.SV_ACC.C_GARGYL_TOTEM[3], 1 } } )
		else
			cid = CombatAlerts.AlertCast( abilityId, "Block!!", hitValue, { -3, 0, false, { 0.7, 0.7, 0.7, 0.4 }, { 0.7, 0.7, 0.7, 0.8 } } )
		end
		BSCHTKA:AddAlertsList(targetUnitId, cid)
	elseif abilityId == YANDIR_HEALING and result == ACTION_RESULT_BEGIN and BSCHTKA.SV_ACC.HEALING_YANDIR then
		if BSCHTKA.SV_ACC.USE_COLOR then
			CombatAlerts.Alert(nil, "Casts Healing!", BSCHTKA:BuildHexColor(BSCHTKA.SV_ACC.C_HEALING_YANDIR), SOUNDS.NONE, 2000)
		else
			CombatAlerts.Alert(nil, "Casts Healing!", 0x991111FF, SOUNDS.NONE, 2000)
		end
	elseif abilityId == YANDIR_JUMP and result == ACTION_RESULT_BEGIN and BSCHTKA.SV_ACC.JUMP_YANDIR then
		local cid = -1
		if BSCHTKA.SV_ACC.USE_COLOR then
			cid = CombatAlerts.AlertCast( abilityId, "(Jump) Block!!", 3000, { -3, 0, false, { unpack(BSCHTKA.SV_ACC.C_JUMP_YANDIR) }, { BSCHTKA.SV_ACC.C_JUMP_YANDIR[1], BSCHTKA.SV_ACC.C_JUMP_YANDIR[2], BSCHTKA.SV_ACC.C_JUMP_YANDIR[3], 1 } } )
		else
			cid = CombatAlerts.AlertCast( abilityId, "(Jump) Block!!", 3000, { -3, 0, false, { 0.7, 0.7, 0.7, 0.4 }, { 0.7, 0.7, 0.7, 0.8 } } )
		end
		BSCHTKA:AddAlertsList(targetUnitId, cid)
	elseif abilityId == SEA_ADDER_BILE_SPRAY and BSCHTKA.SV_ACC.SEA_ADDER_BILE_SPRAY then
		local cid = -1
		if BSCHTKA.SV_ACC.USE_COLOR then
			cid = CombatAlerts.AlertCast( abilityId, sourceName, 1933, { -3, 0, false, { unpack(BSCHTKA.SV_ACC.C_SEA_ADDER_BILE) }, { BSCHTKA.SV_ACC.C_SEA_ADDER_BILE[1], BSCHTKA.SV_ACC.C_SEA_ADDER_BILE[2], BSCHTKA.SV_ACC.C_SEA_ADDER_BILE[3], 1 } } )
		else
			cid = CombatAlerts.AlertCast( abilityId, sourceName, 1933, { -3, 0, false, { 0.7, 0.7, 0.7, 0.4 }, { 0.7, 0.7, 0.7, 0.8 } } )
		end
		BSCHTKA:AddAlertsList(targetUnitId, cid)
	end	
	-- Reset Spawn Time again
	if  abilityId == TOTEM_POISION and result == ACTION_RESULT_BEGIN or 
		abilityId == TOTEM_HARPY_SPWN and result == ACTION_RESULT_BEGIN or 
		abilityId == TOTEM_DRAGON_SPWN and result == ACTION_RESULT_BEGIN or 
		abilityId == TOTEM_GARGYL_SPWN and result == ACTION_RESULT_BEGIN then
		--
		BSCHTKA.TOTEM_TIME = os.time() + TOTEM_SPAWN_TIME
	end	
	--d(zo_strformat("abilityId[<<1>>] AbilityName[<<2>>] result[<<3>>] targetUnitId[<<4>>] sourceUnitId[<<5>>]", abilityId, GetAbilityName(abilityId), result, targetUnitId, sourceUnitId))
end
local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType) 
	--d(zo_strformat("abilityId[<<1>>] AbilityName[<<2>>] changeType[<<3>>]", abilityId, GetAbilityName(abilityId), changeType))
end	
function BSCHTKA:Init_Yandir()
	for i, v in ipairs(YANDIR_IDS) do
		if v.id ~= -1 then
			if v.event == EVENT_COMBAT_EVENT then	
				EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name..v.id, 	v.event, OnCombatEvent)
			elseif v.event == EVENT_EFFECT_CHANGED then
				EVENT_MANAGER:RegisterForEvent(BSCHTKA.Name..v.id, 	v.event, OnEffectChanged)			
			end						
			EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name..v.id, v.event, REGISTER_FILTER_ABILITY_ID, v.id)	
			if v.result ~= -1 and v.event == EVENT_COMBAT_EVENT then
				EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name..v.id, v.event, REGISTER_FILTER_COMBAT_RESULT, v.result)
			end	
			if v.ftarget ~= -1 and v.event == EVENT_COMBAT_EVENT then
				EVENT_MANAGER:AddFilterForEvent(BSCHTKA.Name..v.id, v.event, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, v.ftarget)
			end
		end
	end
end	