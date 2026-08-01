local identifier = "LibAsylum"
local version = 1.0
local LibAsylum = LibStub:NewLibrary(identifier, 1)
if not LibAsylum then return end

local TRIAL_ASYLUM_SANCTORIUM = (TRIAL_ASYLUM_SANCTORIUM or 8)

AS_ABILITY_IDS = {
	general = {
		miniboss = {
			sleep = 99990,
			enrage = 101354
		},
		sphere = {
			spawn = 10298
		}
	},
	felms = {
		maim = 95657,
		wrath = 99037,
		teleport = {
			check = 99139,
			strike = 99138
		},
	},
	llothis = {
		bolts_channel = 95585,
		blast = 95545,
		jump = 99819
	},
	olms = {
		storm = 98535,
		field = 100437,
		breath = 98683
	}
}

local LBF = nil
local CONF = {
	debug_level = 0
}

local msg = {
	none = 0,
	spam = 5,
	info = 4,
	warning = 3,
	error = 2,
	critical = 1,
}

local type_to_str = {
	[msg.none] = 'NONE',
	[msg.info] = 'INFO',
	[msg.warning] = 'WARNING',
	[msg.error] = 'ERROR',
	[msg.critical] = 'CRITICAL',
	[msg.spam] = 'SPAM',
}

local bosses = {
	llothis = false,
	felms = false
}

local OLMS_ENGAGEMENT = false

local function DebugMessage(message, level)
	local dblvl = (level or 0)
	if CONF.debug_level == 0 or dblvl > CONF.debug_level then return end
	message = string.format('[%s] LAS - %s', type_to_str[dblvl], message)
	CHAT_SYSTEM:AddMessage('|cffffff'..message..'|c')
end

local function FixName(name)
	name = string.gsub(name, '%^.+', '')
	return name
end

local function UnitTrackingStart(unit)
	if not LibAsylum:Valid() then return end
	if unit.name:lower():match('felms') then
		bosses.felms = unit
		CALLBACK_MANAGER:FireCallbacks('OnFelmsPresenceDetected', unit)
	elseif unit.name:lower():match('llothis') then
		bosses.llothis = llothis
		CALLBACK_MANAGER:FireCallbacks('OnLlothisPresenceDetected', unit)
	else
		CALLBACK_MANAGER:FireCallbacks('OnASNonMinibossPresenceDetected', unit)
	end
end

local function OnEffectChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if not LibAsylum:Valid() then return end
	local unit = LBF:DetectTrashUnit(unitId, FixName(unitName))
	if unit.name:lower():match('felms') then
		CALLBACK_MANAGER:FireCallbacks('FelmsEffect', changeType, effectName, abilityId, unitTag, unitName, beginTime, endTime, stackCount, buffType, effectType)
	elseif unit.name:lower():match('llothis') then
		CALLBACK_MANAGER:FireCallbacks('LlothisEffect', changeType, effectName, abilityId, unitTag, unitName, beginTime, endTime, stackCount, buffType, effectType)
	end
end

local function OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if not LibAsylum:Valid() then return end
	local unit = LBF:DetectTrashUnit(targetUnitId, FixName(targetName))
	if unit.name:lower():match('felms') then
		CALLBACK_MANAGER:FireCallbacks('FelmsEvent', true, result, abilityName, abilityId, sourceType, sourceName, hitValue, powerType)
	elseif unit.name:lower():match('llothis') then
		CALLBACK_MANAGER:FireCallbacks('LlothisEvent', true, result, abilityName, abilityId, sourceType, sourceName, hitValue, powerType)
	end
	local unit = LBF:DetectTrashUnit(sourceUnitId, FixName(sourceName))
	if unit.name:lower():match('felms') then
		CALLBACK_MANAGER:FireCallbacks('FelmsEvent', false, result, abilityName, abilityId, targetType, targetName, hitValue, powerType)
	elseif unit.name:lower():match('llothis') then
		CALLBACK_MANAGER:FireCallbacks('LlothisEvent', false, result, abilityName, abilityId, targetType, targetName, hitValue, powerType)
	end
	local boss = LBF:DetectUnit(false, FixName(sourceName))
	if boss then
		CALLBACK_MANAGER:FireCallbacks('OlmsEvent', false, result, abilityName, abilityId, targetType, targetName, hitValue, powerType)
	end
end

function LibAsylum:Init(libbossfight, debug_level)
	if not libbossfight then DebugMessage('LibBossFight required!', msg.critical) return end
	LBF = libbossfight
	if debug_level then
		CONF.debug_level = debug_level
	end
	CALLBACK_MANAGER:RegisterCallback("OnBossFightStart", function(boss, hardmode)
	    if LBF:IsInRaidBossFight(TRIAL_ASYLUM_SANCTORIUM, true) then
	        OLMS_ENGAGEMENT = true
	        CALLBACK_MANAGER:FireCallbacks('OlmsFightStarted')
	    end
	end)
	 
	CALLBACK_MANAGER:RegisterCallback("OnBossFightOver", function(boss)
	    if OLMS_ENGAGEMENT then
	    	OLMS_ENGAGEMENT = false
	    	CALLBACK_MANAGER:FireCallbacks('OlmsFightOver')
	    end
	end)
	CALLBACK_MANAGER:RegisterCallback("OnUnitTrackingStart", UnitTrackingStart)
	EVENT_MANAGER:RegisterForEvent('LibAsylum', EVENT_COMBAT_EVENT, OnCombatEvent)
	EVENT_MANAGER:RegisterForEvent('LibAsylum', EVENT_EFFECT_CHANGED, OnEffectChanged)
end

function LibAsylum:Valid()
	if not GetCurrentParticipatingRaidId() ~= TRIAL_ASYLUM_SANCTORIUM then return false end
	return (OLMS_ENGAGEMENT)
end

function LibAsylum:GetLlothis()
	return LBF:GetUnitByName('Llothis')
end

function LibAsylum:GetFelms()
	return LBF:GetUnitByName('Felms')
end
