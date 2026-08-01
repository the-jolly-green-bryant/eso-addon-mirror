IAHelper = {
	version = "0.4.2",
	uiLocked = true,
}

local A = IAHelper
local EM = EVENT_MANAGER
local DEBUG = false

A.NAME = "IAHelper"

local SW = nil -- account wide saved variables
local SW_DEFAULTS = {
	enableDataSharing = true,
	enableSounds = true,
	enableTimers = true,
	enableWave = true,
	enableMarkers = true,
	enableWeakening = true,
	enableMajorCowardice = true,
	enableScorchingSupport = true,
	enableCastbar = true,
	hideStageAnnouncement = true,
	scorchingSupportTime = 0, -- last time lava pool spawned
}

-- Addon events
-- Use IAHelper.RegisterCallback(event, callback) to register a callback
IA_EVENT_PLAYER_ACTIVATED		= "PlayerActivated"
IA_EVENT_COMBAT_START			= "CombatStart"
IA_EVENT_COMBAT_END				= "CombatEnd"
IA_EVENT_GROUP_CHANGED			= "GroupChanged"

local ZONE_ID = 1436 -- IA zone id

local SPAWN_ID = 211130 -- trash mob spawn event
local WEAKENING_ID = 17945
local MAJOR_COWARDICE_ID = 147643

local SCORCHING_SUPPORT_VISION_ID = 202804
local SCORCHING_SUPPORT_ABILITY_ID = 202817 -- [2240] (1); 15s cooldown, lasts 10s and can proc again in 5s
local SCORCHING_SUPPORT_DURATION = 10000 -- lava pool duration in ms
local SCORCHING_SUPPORT_COOLDOWN = 15 -- proc cooldown in seconds

local EVENT_GROUP_CHANGE_DELAYED = A.NAME .. 'GroupChangeDelayed'
local EVENT_COMBAT = A.NAME .. 'CombatEvent'
local EVENT_SPAWN = A.NAME .. 'Spawn'
local EVENT_DEATH = A.NAME .. 'Death'
local EVENT_DEATH_XP = EVENT_DEATH .. 'XP'
local EVENT_INTERRUPT = A.NAME .. 'Interrupt'
local EVENT_WEAKENING = A.NAME .. 'Weakening'
local EVENT_MAJOR_COWARDICE = A.NAME .. 'MajorCowardice'
local EVENT_MAJOR_COWARDICE_TICK = EVENT_MAJOR_COWARDICE .. 'Tick'
local EVENT_SCORCHING_SUPPORT = A.NAME .. 'ScorchingSupport'
local EVENT_SCORCHING_SUPPORT_TICK = EVENT_SCORCHING_SUPPORT .. 'Tick'

local eventsRegistered = false -- events are registered only on IA visit
local abilityConfig = {} -- parsed A.ids
local units = {} -- current enemy units in combat: unitId => {"full name", "short name"}
local inCombat = false -- combat state
local combatStartTime = 0 -- time() when combat started
local isBossFight = false -- in combat with a boss
local scampSpawned = false -- Gw the Pilferer

local weakeningEnd = 0 -- weakening glyph on boss

local majorCowardiceUnits = {} -- units affected by Major Cowardice: unitId => endTime

local hasScorchingSupport = false -- player has Scorching Support vision active
local scorchingSupportCount = 0 -- countdown
local scorchingSupportActive = false -- lava pool is currently active

local fragments = {} -- scene fragments

local DataShare -- LibDataShare object
local time = GetGameTimeMilliseconds
local strformat = string.format

function A.GetName()
	return A.NAME
end

function A.PlaySound(sound)
	if SW.enableSounds then
		PlaySound(SOUNDS[sound] or sound)
	end
end

-- Format and split unit name by whitespace, then return the formatted name and second part if it exists
local function SplitName(unitName, unitTag)
	local name = zo_strformat('<<1>>', unitName)
	if unitTag:find('boss') then
		return {name, unitTag == 'boss1' and 'BOSS' or zo_strupper(unitTag)}
	else
		local a, b, c = zo_strsplit(" ", name)
		return {name, c or b or a}
	end
end

local function CombatStart()
	combatStartTime = time()
	--A.ResetCombat()
end

local function CombatEnd()
	A.ResetCombat()
end

-- Returns 1 for player, 2 for another group member, 0 otherwise
local function GetUnitIdType(unitId)
	if A.units.IsPlayerUnitId(unitId) then
		return 1
	elseif A.units.IsGroupUnitId(unitId) then
		return 2
	else
		return 0
	end
end

local function CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if A.ids[abilityId] then return end -- ignore known abilities
	if result == 2200 or result == 2240 or result == 2245 then
		--if isBossFight and time() - combatStartTime < 2000 then-- and (sourceName:find('Gw the') or targetName:find('Gw the')) then
		local name = GetAbilityName(abilityId)
		if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and (sourceUnitId > 0 or hitValue > 1) and GetUnitIdType(targetUnitId) < 2 and name ~= 'Prioritize Hit' and name ~= 'Run Away' and name ~= 'Runaway' then
			d(strformat('[%s] |c%s%s|r#%s : %s->%s (%s)', result, targetType == COMBAT_UNIT_TYPE_PLAYER and 'FF6600' or 'FFFFFF', name, abilityId, sourceName == '' and sourceUnitId or sourceName, targetType == COMBAT_UNIT_TYPE_PLAYER and targetUnitId or targetUnitId, hitValue))
		end
	end
end

--[[
function A.TestCombatEvent()
	CombatEvent(0, ACTION_RESULT_BEGIN, 0, '', '', 0, '', 0, '', 0, 1500, 0, 0, 0, 0, 0, 195079)
end
]]

-- EVENT_PLAYER_COMBAT_STATE handler
local function PlayerCombatState(e, c)
	if inCombat ~= c then
		if c then
			inCombat = true
			CombatStart()
		else
			-- Ignore quick combat state changes
			zo_callLater(function()
				if not IsUnitInCombat("player") then
					inCombat = false
					CombatEnd()
				end
			end, 3000)
		end
	end
end

local function BossesChanged()
	isBossFight = DoesUnitExist('boss1') and not IsUnitDead('boss1') or DoesUnitExist('boss2') and not IsUnitDead('boss1') or DoesUnitExist('boss3') and not IsUnitDead('boss3') or DoesUnitExist('boss4') and not IsUnitDead('boss4')
	fragments.weakening:Refresh()
end

-- EVENT_GROUP_MEMBER_JOINED, EVENT_GROUP_MEMBER_LEFT, EVENT_GROUP_UPDATE, EVENT_GROUP_MEMBER_CONNECTED_STATUS handler
local function GroupChanged()
	EM:UnregisterForUpdate(EVENT_GROUP_CHANGE_DELAYED)
	A.cm:FireCallbacks(IA_EVENT_GROUP_CHANGED)
end

-- Prevent group events spam by calling GroupChanged 1s later
local function OnGroupChangeDelayed()
	EM:UnregisterForUpdate(EVENT_GROUP_CHANGE_DELAYED)
	EM:RegisterForUpdate(EVENT_GROUP_CHANGE_DELAYED, 1000, GroupChanged)
end

local function IsActiveInstance()
	-- For some reason IsInstanceEndlessDungeon() sometimes might return false when porting to Infinite Archive
	return (IsInstanceEndlessDungeon() or GetZoneId(GetUnitZoneIndex('player')) == ZONE_ID) and not IsEndlessDungeonCompleted()
end

local function PlayerActivated()
	isBossFight = false
	hasScorchingSupport = false

	A.RefreshUI()

	-- Unregister everything that could be registered
	if eventsRegistered then
		eventsRegistered = false

		EM:UnregisterForEvent(A.NAME .. "Combat", EVENT_PLAYER_COMBAT_STATE)
		EM:RegisterForEvent(A.NAME .. "ReticleChanged", EVENT_RETICLE_TARGET_CHANGED)
		EM:UnregisterForEvent(EVENT_SPAWN, EVENT_EFFECT_CHANGED)
		EM:UnregisterForEvent(EVENT_DEATH, EVENT_COMBAT_EVENT)
		EM:UnregisterForEvent(EVENT_DEATH_XP, EVENT_COMBAT_EVENT)
		EM:UnregisterForEvent(EVENT_INTERRUPT, EVENT_COMBAT_EVENT)
		EM:UnregisterForEvent(A.NAME, EVENT_BOSSES_CHANGED)
		EM:UnregisterForEvent(EVENT_SCORCHING_SUPPORT, EVENT_COMBAT_EVENT)
		EM:UnregisterForEvent(EVENT_WEAKENING, EVENT_EFFECT_CHANGED)
		EM:UnregisterForEvent(EVENT_MAJOR_COWARDICE, EVENT_EFFECT_CHANGED)

		ENDLESS_DUNGEON_MANAGER:UnregisterCallback("BuffStackCountChanged", A.OnBuffStackCountChanged)

		EM:UnregisterForUpdate(EVENT_SCORCHING_SUPPORT_TICK)	

		for k, v in pairs(A.ids) do
			EM:UnregisterForEvent(strformat("%sAbility%d", A.NAME, k), EVENT_COMBAT_EVENT)
		end

		-- Group events
		EM:UnregisterForEvent(A.NAME, EVENT_GROUP_MEMBER_JOINED)
		EM:UnregisterForEvent(A.NAME, EVENT_GROUP_MEMBER_LEFT)
		EM:UnregisterForEvent(A.NAME, EVENT_GROUP_UPDATE)
		EM:UnregisterForEvent(A.NAME, EVENT_GROUP_MEMBER_CONNECTED_STATUS, OnGroupChangeDelayed)
	end

	if IsActiveInstance() then
		eventsRegistered = true

		-- Player can be in combat after reloadui
		EM:RegisterForEvent(A.NAME .. "Combat", EVENT_PLAYER_COMBAT_STATE, PlayerCombatState)
		PlayerCombatState(nil, IsUnitInCombat("player"))

		EM:RegisterForEvent(A.NAME .. "ReticleChanged", EVENT_RETICLE_TARGET_CHANGED, A.ReticleChanged)

		-- Spawn Immune
		EM:RegisterForEvent(EVENT_SPAWN,  EVENT_EFFECT_CHANGED, A.Spawn)
		EM:AddFilterForEvent(EVENT_SPAWN, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, SPAWN_ID)

		-- Death
		EM:RegisterForEvent(EVENT_DEATH, EVENT_COMBAT_EVENT, A.Death)
		EM:AddFilterForEvent(EVENT_DEATH, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)
		EM:RegisterForEvent(EVENT_DEATH_XP, EVENT_COMBAT_EVENT, A.Death)
		EM:AddFilterForEvent(EVENT_DEATH_XP, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)

		-- Interrupt & Stun
		EM:RegisterForEvent(EVENT_INTERRUPT, EVENT_COMBAT_EVENT, A.Interrupt)
		EM:AddFilterForEvent(EVENT_INTERRUPT, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_INTERRUPT)
		--EVENT_MANAGER:RegisterForEvent(BR.name .. "Stun", EVENT_COMBAT_EVENT, BR.Interrupt)
		--EVENT_MANAGER:AddFilterForEvent(BR.name .. "Stun", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_STUNNED)

		EM:RegisterForEvent(A.NAME, EVENT_BOSSES_CHANGED, BossesChanged)
		BossesChanged()

		EM:RegisterForEvent(EVENT_WEAKENING,  EVENT_EFFECT_CHANGED, A.Weakening)
		EM:AddFilterForEvent(EVENT_WEAKENING, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, 'boss', REGISTER_FILTER_ABILITY_ID, WEAKENING_ID)

		ENDLESS_DUNGEON_MANAGER:RegisterCallback("BuffStackCountChanged", A.OnBuffStackCountChanged)

		EM:RegisterForEvent(EVENT_SCORCHING_SUPPORT, EVENT_COMBAT_EVENT, A.ScorchingSupport)
		EM:AddFilterForEvent(EVENT_SCORCHING_SUPPORT, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
		EM:AddFilterForEvent(EVENT_SCORCHING_SUPPORT, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, SCORCHING_SUPPORT_ABILITY_ID)

		EM:RegisterForEvent(EVENT_MAJOR_COWARDICE, EVENT_EFFECT_CHANGED, A.MajorCowardice)
		EM:AddFilterForEvent(EVENT_MAJOR_COWARDICE, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, MAJOR_COWARDICE_ID)

		--[[
		local function EffectTest(_, change, _, _, unitTag, beginTime, endTime, stackCount, _, _, _, _, _, unitName, unitId, abilityId)
			if abilityId > 180000 then
				d(strformat('%s: %s->%s (%s)', change, GetAbilityName(abilityId), unitTag, endTime - beginTime))
			end
		end
		EM:RegisterForEvent(A.NAME..'Test', EVENT_EFFECT_CHANGED, EffectTest)
		]]

		for k, v in pairs(A.ids) do
			local s = strformat("%sAbility%d", A.NAME, k)
			EM:RegisterForEvent(s, EVENT_COMBAT_EVENT, A.HandleAbility)
			EM:AddFilterForEvent(s, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
		end

		-- Check for Scorching Support vision
		-- Also check ability description if the vision is active (shouldn't contain colored "0/3" substring)
		-- Description check alone should be enough, but buff table might be useful for something else later
		local buffTable = ENDLESS_DUNGEON_MANAGER:GetAbilityStackCountTable(ENDLESS_DUNGEON_BUFF_TYPE_VISION)
		if buffTable[SCORCHING_SUPPORT_VISION_ID] ~= nil and not string.find(GetAbilityDescription(SCORCHING_SUPPORT_VISION_ID), "0|r|cFFFFFF/3") then
			A.RegisterScorchingSupport()
		end

		-- Group events
		EM:RegisterForEvent(A.NAME, EVENT_GROUP_MEMBER_JOINED, OnGroupChangeDelayed)
		EM:RegisterForEvent(A.NAME, EVENT_GROUP_MEMBER_LEFT, OnGroupChangeDelayed)
		EM:RegisterForEvent(A.NAME, EVENT_GROUP_UPDATE, OnGroupChangeDelayed)
		EM:RegisterForEvent(A.NAME, EVENT_GROUP_MEMBER_CONNECTED_STATUS, OnGroupChangeDelayed)
		OnGroupChangeDelayed()

		A.ResetCombat()
	else
		SW.scorchingSupportTime = 0
	end
end

function A.RegisterCallback(eventName, callback)
    A.cm:RegisterCallback(eventName, callback)
end

function A.UnregisterCallback(eventName, callback)
    A.cm:UnregisterCallback(eventName, callback)
end

function A.ResetCombat()
	units = {}
	majorCowardiceUnits = {}
	weakeningEnd = 0
	scampSpawned = false

	BossesChanged()

	EM:UnregisterForUpdate(EVENT_MAJOR_COWARDICE_DELAYED)
	EM:UnregisterForUpdate(EVENT_MAJOR_COWARDICE_TICK)

	IAHelper_MajorCowardice:SetHidden(true)

	A.AramrilStop()
end

-------------------------------------------------
---- Mechanics
-------------------------------------------------

-- Handle known abilities from A.ids
function A.HandleAbility(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if not SW.enableTimers or not A.ids[abilityId] then return end -- ignore unknown abilities
	if not abilityConfig[abilityId] then -- need to parse the ability config first
		local ability = A.ids[abilityId]
		local f, r, h, nh, clr, txt, fltr -- function, result, hit value, new hit value, color
		if ability == true then
			f = A.HeavyAttack
			r = ACTION_RESULT_BEGIN
		elseif type(ability) == 'number' then
			f = A.HeavyAttack
			r = ACTION_RESULT_BEGIN
			hitValue = ability
		elseif type(ability) == 'table' then
			if type(ability[1]) == 'function' then
				f = ability[1]
				r = ability[2] or ACTION_RESULT_BEGIN
				h = ability[3]
				nh = ability[4]
			else
				f = A.HeavyAttack
				r = ability[1] or ACTION_RESULT_BEGIN
				h = ability[2]
				nh = ability[3]
			end
			clr = ability.color
			txt = ability.text
			fltr = ability.filter
		end
		abilityConfig[abilityId] = {id = abilityId, f = f, result = r, hitValue = h, newHitValue = nh, color = clr, text = txt, filter = fltr}
	end
	local cfg = abilityConfig[abilityId]
	if (cfg.result == 0 or cfg.result == result) and (not cfg.hitValue or cfg.hitValue == hitValue) then
		cfg.f(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, cfg.newHitValue or hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	end
	if DEBUG and abilityId ~= 200060 then
		d(strformat('[%s] |c%s%s|r#%s : %s->%s (%s)', result, c or targetType == COMBAT_UNIT_TYPE_PLAYER and 'FF00FF' or '00FF00', GetAbilityName(abilityId), abilityId, sourceName == '' and sourceUnitId or sourceName, targetType == COMBAT_UNIT_TYPE_PLAYER and targetUnitId or targetUnitId, hitValue))
	end
end

-- Mark dangerous foes (group leader only)
do
	-- EVENT_TARGET_MARKER_UPDATE
	local markers = {
		["Fabled Infuser"]			= TARGET_MARKER_TYPE_FIVE,
		["Fabled Spellthief"]		= TARGET_MARKER_TYPE_SIX,
		["Fabled Flameshaper"]		= TARGET_MARKER_TYPE_FOUR,
		["Fabled Sun-Eater"]		= TARGET_MARKER_TYPE_TWO,
		["Fabled Totem Master"]		= TARGET_MARKER_TYPE_TWO,
		["Fabled Brewmaster"]		= TARGET_MARKER_TYPE_FIVE,
		["Fabled Stormcaller"]		= TARGET_MARKER_TYPE_FIVE,
		["Fabled Lightbringer"]		= TARGET_MARKER_TYPE_TWO,

		["Dwarven Arquebus"]		= TARGET_MARKER_TYPE_ONE,
		["Ascendant Archer"]		= TARGET_MARKER_TYPE_ONE,
		["Grovebound Blightbow"]	= TARGET_MARKER_TYPE_ONE,
		["Dreadhorn Scrapper"]		= TARGET_MARKER_TYPE_EIGHT,
		["Dremora Conduit"]			= TARGET_MARKER_TYPE_ONE,
		["Dro-m'Athra Conduit"]		= TARGET_MARKER_TYPE_ONE,
		["Silver Rose Stormcaster"]	= TARGET_MARKER_TYPE_ONE,
		["Firesong Druid"]			= TARGET_MARKER_TYPE_EIGHT,
		["Gw the Pilferer"]			= TARGET_MARKER_TYPE_EIGHT,
	}

	function A.ReticleChanged()
		if not SW.enableMarkers then return end
		if IsUnitAttackable('reticleover') then
			-- Mark attackable units in the list, but only as a group leader
			if IsUnitSoloOrGroupLeader('player') then
				local name = zo_strformat('<<1>>', GetUnitName('reticleover'))
				if markers[name] and GetUnitTargetMarkerType('reticleover') ~= markers[name] then
					AssignTargetMarkerToReticleTarget(markers[name])
					return
				end
			end
		elseif GetUnitTargetMarkerType('reticleover') ~= TARGET_MARKER_TYPE_NONE then
			-- Remove marker if it's on a wrong target (can happen to companions or group members)
			AssignTargetMarkerToReticleTarget(GetUnitTargetMarkerType('reticleover'))
		end
	end
end

-- Heavy and other dangerous attacks
do
	local EVENT_HA_TICK = A.NAME .. 'HeavyAttackTick'
	local heavyAttackList = {}

	local function FormatHeavyAttackList()
		local countdownList = {}
		local countdownListFormatted = {}
		local t = time()

		for _, value in ipairs(heavyAttackList) do
			if value[1] > t then
				table.insert(countdownList, {value[1] - t, value[2], value[3]})
			end
		end

		if #countdownList > 0 then
			table.sort(countdownList, function(a, b) return a[1] < b[1] end)
			for i = 1, zo_min(#countdownList, 3) do -- don't show more than 3 alerts
				local value = countdownList[i]
				table.insert(countdownListFormatted, value[3] == '' and strformat("|c%s%0.1f|r", value[2], value[1] / 1000) or strformat("|c%s%s|r", value[2], value[3]))
			end
			return table.concat(countdownListFormatted, " / ")
		else
			return nil
		end
	end

	local function HeavyAttackTick()
		local text = FormatHeavyAttackList()

		if not text or text == "" then
			heavyAttackList = {}
			EM:UnregisterForUpdate(EVENT_HA_TICK)
			A.HideReticle()
		else
			A.ShowReticle(strformat('> %s <', text))
		end
	end

	-- Use this function to track any dangerous attack on the player
	function A.RegisterHeavyAttack(duration, color, text, sound)
		table.insert(heavyAttackList, {time() + duration, color or IA_COLOR_YELLOW, text or ''})

		if duration < 1100 then
			A.PlaySound(sound or 'DUEL_START')
		else
			zo_callLater(function() A.PlaySound(sound or 'DUEL_START') end, duration - 900)
		end

		EM:UnregisterForUpdate(EVENT_HA_TICK)
		EM:RegisterForUpdate(EVENT_HA_TICK, 100, HeavyAttackTick)
		HeavyAttackTick()
	end

	-- Heavy attack event handler
	function A.HeavyAttack(_, result, _, abilityName, _, _, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
		local cfg = abilityConfig[abilityId] or {}
		if cfg.filter ~= false and ( -- if filter is false, then just always shows the attack
			sourceName ~= '' and targetType ~= COMBAT_UNIT_TYPE_PLAYER or -- when sourceName is not empty, then it's a cast on the player or pet/companion
			GetUnitIdType(targetUnitId) == 2) then -- ignore casts on another player (sourceName and targetType seem to always be empty in this case)
			return
		end
		A.RegisterHeavyAttack(hitValue, cfg.color, cfg.text)--abilityId == 192517 and 'BLOB' or abilityId == 198819 and 'BREATH' or '')
	end
end

-- Wave Spawn
do
	local EVENT_SPAWN_COUNT = EVENT_SPAWN .. 'Count'
	local spawnCount = 0 -- number of mobs spawned (not really needed)
	local bosses = {
		["Ascendant Bulwark"] = "|cFF0000Kitty|r",
		["Silver Rose Realmshaper"] = "|cFF0000Shaper|r",
		["Dreadhorn Firehide"] = "|cFF0000Mino|r",
		["Minotaur Shaman"] = "|cFF0000Mino|r",
		["Lich"] = "|cFF0000Lich|r",
		["Wraith of Crows"] = "|cFF0000Crow|r",
		--["Iron Atronach"] = "|cFFFF00Atro|r",
		--["Bristleback"] = "|cFFFF00Piggy|r",
		--["Dreadhorn Earthgorer"] = "|cFFFFFFMino|r",
		--["Bone Colossus"] = "|cFFFFFFColos|r",
		--["Lurcher"] = "|cFFFFFFLurcher|r",
		--["Dwarven Centurion"] = "|cFFFFFFCenturion|r",
	}

	local function ShowWave()
		local infusers = 0
		local spellthief = 0
		local flameshapers = 0
		local brewmasters = 0
		local stormcallers = 0
		local lightbringers = 0
		local mystics = 0
		local archers = 0
		local imps = 0
		local scrappers = 0
		local conduit = 0
		local arquebus = 0 -- bad sphere
		local suneaters = 0
		local boss

		-- TODO: optimize
		for id, unit in pairs(units) do
			if not boss and bosses[unit[1]] then boss = bosses[unit[1]] end
			if unit[2] == 'Infuser' then
				infusers = infusers + 1
			elseif unit[2] == 'Spellthief' then
				spellthief = spellthief + 1
			elseif unit[2] == 'Flameshaper' then
				flameshapers = flameshapers + 1
			elseif unit[2] == 'Brewmaster' then
				brewmasters = brewmasters + 1
			elseif unit[2] == 'Stormcaller' then
				stormcallers = stormcallers + 1
			elseif unit[2] == 'Lightbringer' then
				lightbringers = lightbringers + 1
			elseif unit[2] == 'Mystic' then
				mystics = mystics + 1
			elseif unit[2] == 'Blightbow' or unit[1] == 'Ascendant Archer' then
				archers = archers + 1
			elseif unit[2] == 'Imp' then
				imps = imps + 1
			elseif unit[2] == 'Scrapper' then
				scrappers = scrappers + 1
			elseif unit[2] == 'Conduit' or unit[2] == 'Stormcaster' then
				conduit = conduit + 1
			elseif unit[2] == 'Arquebus' then
				arquebus = arquebus + 1
			elseif unit[2] == 'Sun-Eater' then
				suneaters = suneaters + 1
			end
		end

		local s = {}
		if boss then table.insert(s, boss) end
		if infusers > 0 then table.insert(s, infusers == 1 and "|cFF0000Infuser|r" or strformat("|cFF0000%d Infusers|r", infusers)) end
		if spellthief > 0 then table.insert(s, spellthief == 1 and "|cFF00FFSpellthief|r" or strformat("|cFF00FF%d Spellthieves|r", spellthief)) end
		if flameshapers > 0 then table.insert(s, flameshapers == 1 and "|cFF6600Flameshaper|r" or strformat("|cFF6600%d Flameshapers|r", flameshapers)) end
		if brewmasters > 0 then table.insert(s, brewmasters == 1 and "|cFF00FFBrewmaster|r" or strformat("|cFF00FF%d Brewmasters|r", brewmasters)) end
		if stormcallers > 0 then table.insert(s, stormcallers == 1 and "|c00FFFFStormcaller|r" or strformat("|c00FFFF%d Stormcallers|r", stormcallers)) end
		if lightbringers > 0 then table.insert(s, lightbringers == 1 and "|cE2E8A9Lightbringer|r" or strformat("|cE2E8A9%d Lightbringers|r", lightbringers)) end
		if mystics > 0 then table.insert(s, mystics == 1 and "|cFF0000Mystic|r" or strformat("|cFF0000%d Mystics|r", mystics)) end
		if archers > 0 then table.insert(s, archers == 1 and "|c00FF00Archer|r" or strformat("|c00FF00%d Archers|r", archers)) end
		if imps > 0 then table.insert(s, imps == 1 and "|cFFFF00Imp|r" or strformat("|cFFFF00%d Imps|r", imps)) end
		if scrappers > 0 then table.insert(s, scrappers == 1 and "|cFFFF00Scrapper|r" or strformat("|cFFFF00%d Scrappers|r", scrappers)) end
		if conduit > 0 then table.insert(s, conduit == 1 and "|c00FFFFConduit|r" or strformat("|c00FFFF%d Conduits|r", conduit)) end
		if arquebus > 0 then table.insert(s, arquebus == 1 and "|cFF6600Sphere|r" or strformat("|cFF6600%d Spheres|r", arquebus)) end
		if suneaters > 0 then table.insert(s, suneaters == 1 and "|c4169E1Sun-Eater|r" or strformat("|c4169E1%d Sun-Eaters|r", suneaters)) end

		if #s > 0 then
			A.PlaySound(boss and 'TELVAR_MULTIPLIERUP' or 'TELVAR_GAINED')
			A.ShowWave(table.concat(s, " + "))
			zo_callLater(function() A.HideWave() end, 7000) -- configurable via mcm
		end
	end

	function A.Spawn(_, change, _, _, unitTag, _, _, _, _, _, _, _, _, unitName, unitId)
		if change == EFFECT_RESULT_GAINED then
			units[unitId] = SplitName(unitName, unitTag)
			spawnCount = spawnCount + 1
			EM:UnregisterForUpdate(EVENT_SPAWN_COUNT)
			EM:RegisterForUpdate(EVENT_SPAWN_COUNT, 200, function()
				EM:UnregisterForUpdate(EVENT_SPAWN_COUNT)
				--d(strformat("Spawn: %d", spawnCount))
				if SW.enableWave then ShowWave() end
				spawnCount = 0
			end)

			-- Imp Spawn
			if units[unitId][2] == 'Imp' then
				A.StormImpSpawn()
			elseif units[unitId][2] == 'Infuser' or units[unitId][2] == 'Flameshaper' then
				A.InfuserSpawn(unitId)
			end
		elseif change == EFFECT_RESULT_FADED then
			-- Spawn Immune faded (can now damage mobs)
		end
	end

	--[[
	function A.TestSpawn()
		A.Spawn(0, EFFECT_RESULT_GAINED, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, "Blightbow", 1)
		A.Spawn(0, EFFECT_RESULT_GAINED, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, "Ascendant Archer", 2)
		A.Spawn(0, EFFECT_RESULT_GAINED, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, "Fabled Spellthief", 3)
		A.Spawn(0, EFFECT_RESULT_GAINED, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, "Imp", 4)
		A.Spawn(0, EFFECT_RESULT_GAINED, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, "Imp", 5)
		A.Spawn(0, EFFECT_RESULT_GAINED, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, "Imp", 6)
	end
	]]
end

function A.Death(_, _, _, _, _, _, _, _, targetName, targetType, _, _, _, _, _, targetUnitId)
	if units[targetUnitId] then
		if units[targetUnitId][2] == 'Infuser' or units[targetUnitId][2] == 'Flameshaper' then
			A.InfuserDeath(targetUnitId)
		elseif units[targetUnitId][2] == 'BOSS' and not DoesUnitExist('boss2') then -- Marauder
			isBossFight = false
			fragments.weakening:Refresh()
		end
		units[targetUnitId] = nil
	end
end

function A.Interrupt(_, result, _, _, _, _, _, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId)
	if units[targetUnitId] and (units[targetUnitId][2] == 'Infuser' or units[targetUnitId][2] == 'Flameshaper') then
		A.InfuserInterrupt(targetUnitId)
	end
end

-- Weakening
do
	local EVENT_WEAKENING_TICK = EVENT_WEAKENING .. 'Tick'

	local function WeakeningTick()
		local t = weakeningEnd - GetFrameTimeSeconds()
		local color = ZO_ColorDef:New(1, 0, 0)
		if t > 2 then
			color:SetRGB(0, 1, 0)
		elseif t > 0 then
			color:SetRGB(1, 1, 0)
		end
		IAHelper_Weakening_Duration:SetText(color:Colorize(strformat('%0.1f', t > 0 and t or 0)))
		IAHelper_Weakening_BG:SetColor(color:UnpackRGB())
	end

	function A.Weakening(_, change, _, _, unitTag, beginTime, endTime, stackCount, _, _, _, _, _, unitName, unitId, abilityId)
		if not SW.enableWeakening then return end
		if change == EFFECT_RESULT_UPDATED and endTime - GetFrameTimeSeconds() > 0 then
			if not units[unitId] and unitTag:find('boss') then
				units[unitId] = SplitName(unitName, unitTag)
			end
			weakeningEnd = endTime
			fragments.weakening:Refresh()
			EM:UnregisterForUpdate(EVENT_WEAKENING_TICK)
			EM:RegisterForUpdate(EVENT_WEAKENING_TICK, 100, WeakeningTick)
			WeakeningTick()
		elseif change == EFFECT_RESULT_FADED then
			weakeningEnd = 0
			--A.PlaySound('JUSTICE_NO_LONGER_KOS')
			EM:UnregisterForUpdate(EVENT_WEAKENING_TICK)
			WeakeningTick()
		end
	end
end

-- Major Cowardice
do
	local EVENT_MAJOR_COWARDICE_DELAYED = EVENT_MAJOR_COWARDICE .. 'Delayed'

	local function MajorCowardiceTick()
		local numTotal = 0
		local numDebuffed = 0
		local names = {}
		local namesColored = {}
		local t = GetFrameTimeSeconds()
		local color = '00FF00'
		for unitId, unitName in pairs(units) do
			numTotal = numTotal + 1
			if majorCowardiceUnits[unitId] then numDebuffed = numDebuffed + 1 end
			table.insert(names, {unitName[2], majorCowardiceUnits[unitId] or 0})
		end
		if numTotal > 0 then
			table.sort(names, function(a, b) return a[2] < b[2] end)
			for _, name in ipairs(names) do
				if name[2] - t < 1 then
					color = 'FF3300'
				elseif name[2] - t < 5.5 then
					color = 'FFFF00'
				else
					color = '00FF00'
				end
				table.insert(namesColored, strformat("|c%s%s|r", color, name[1]))
			end
			local ratio = numDebuffed / numTotal
			if ratio > 0.9 then
				color = '00FF00'
			elseif ratio > 0.5 then
				color = 'FFFF00'
			else
				color = 'FF3300'
			end
			-- Resize magic
			IAHelper_MajorCowardice:SetHidden(false)
			IAHelper_MajorCowardice_Num:SetText(strformat("Coward: |c%s%d/%d|r", color, numDebuffed, numTotal))
			IAHelper_MajorCowardice_Text:SetWidth(0)
			IAHelper_MajorCowardice_Text:SetText(strformat("%s|u25:0::|u", table.concat(namesColored, ", ")))
			IAHelper_MajorCowardice_Text:SetWidth(zo_max(200, zo_min(450, IAHelper_MajorCowardice_Text:GetWidth())))
			IAHelper_MajorCowardice_BG:SetWidth(IAHelper_MajorCowardice_Text:GetWidth() + 70)
			IAHelper_MajorCowardice_BG:SetHeight(IAHelper_MajorCowardice_Text:GetHeight() + 55)
		else
			IAHelper_MajorCowardice:SetHidden(true)
		end
	end

	local function MajorCowardiceDelayed()
		EM:UnregisterForUpdate(EVENT_MAJOR_COWARDICE_DELAYED)
		EM:RegisterForUpdate(EVENT_MAJOR_COWARDICE_TICK, 500, MajorCowardiceTick)
		MajorCowardiceTick()
	end

	function A.MajorCowardice(_, change, _, _, unitTag, beginTime, endTime, stackCount, _, _, _, _, _, unitName, unitId, abilityId, sourceUnitType)
		--d(strformat('[%s] %s #%s: %s -> %s #%s', change, GetAbilityName(abilityId), abilityId, sourceUnitType == COMBAT_UNIT_TYPE_PLAYER and 'P' or sourceUnitType, unitName, unitId))
		if not SW.enableMajorCowardice then return end
		if change == EFFECT_RESULT_GAINED or change == EFFECT_RESULT_UPDATED then
			majorCowardiceUnits[unitId] = endTime
			if not units[unitId] and unitTag:find('boss') then
				units[unitId] = SplitName(unitName, unitTag)
			end
		elseif change == EFFECT_RESULT_FADED then
			majorCowardiceUnits[unitId] = nil
		end
		-- Prevent multiple calls within a short time span
		EM:UnregisterForUpdate(EVENT_MAJOR_COWARDICE_DELAYED)
		EM:RegisterForUpdate(EVENT_MAJOR_COWARDICE_DELAYED, 100, MajorCowardiceDelayed)
	end
end

--[[
function A.CowardTest(s)
	if s then
		IAHelper_MajorCowardice:SetHidden(false)

		IAHelper_MajorCowardice_Num:SetText(strformat("Coward: |c%s%d/%d|r", 'FFFF00', 5, 10))

		IAHelper_MajorCowardice_Text:SetWidth(0)
		IAHelper_MajorCowardice_Text:SetText(strformat("%s|u25:0::|u", s))
		IAHelper_MajorCowardice_Text:SetWidth(zo_max(200, zo_min(450, IAHelper_MajorCowardice_Text:GetWidth())))

		IAHelper_MajorCowardice_BG:SetWidth(IAHelper_MajorCowardice_Text:GetWidth() + 70)
		IAHelper_MajorCowardice_BG:SetHeight(IAHelper_MajorCowardice_Text:GetHeight() + 55)
	else
		IAHelper_MajorCowardice:SetHidden(true)
	end
end
]]

-- Visions
do
	-- 192667: swift gale
	-- 192848: pustulent globes
	-- 193984: exsanguinate
	-- 200020: magical multitudes
	-- 200904: focused efforts
	-- 201443: extended favor
	-- 201491: attuned enchants
	-- 201504: vicious poisons
	-- 202804: scorching support
	-- 203352: fire orb
	-- 201098: lessons learned (best buff)
	function A.OnBuffStackCountChanged(buffType, abilityId, stackCount, previousStackCount)
		--[[
		if stackCount > previousStackCount then
			d(strformat('|t32:32:%s|t [%s] %s #%s : %s->%s', GetAbilityIcon(abilityId), buffType, GetAbilityName(abilityId), abilityId, previousStackCount, stackCount))
		end
		]]
		if abilityId == SCORCHING_SUPPORT_VISION_ID and SW.enableScorchingSupport then
			if stackCount > previousStackCount then
				A.RegisterScorchingSupport(true)
			elseif stackCount == 0 then
				hasScorchingSupport = false
				EM:UnregisterForUpdate(EVENT_SCORCHING_SUPPORT_TICK)
				fragments.scorching:Refresh()
			end
		end
		-- Share data with another player
		if SW.enableDataSharing and DataShare and stackCount > previousStackCount and IsUnitGrouped('player') and not IsEndlessDungeonCompleted() then
			local _, isAvatarVision = GetAbilityEndlessDungeonBuffType(abilityId)
			-- Get current number of parts for avatars
			if isAvatarVision then
				local _, _, visionParts = string.find(GetAbilityDescription(abilityId), '(%d)|r|cFFFFFF/3')
				if visionParts then
					visionParts = tonumber(visionParts)
					if visionParts < 3 then
						stackCount = visionParts + 1 -- ability description isn't updated before this event
					end
				end
			end
			DataShare:QueueData(abilityId * 10 + stackCount)
		end
	end

	function A.RegisterScorchingSupport(updateTime)
		hasScorchingSupport = true
		if updateTime then
			SW.scorchingSupportTime = time()
		end
		if SW.scorchingSupportTime > 0 then
			EM:UnregisterForUpdate(EVENT_SCORCHING_SUPPORT_TICK)
			EM:RegisterForUpdate(EVENT_SCORCHING_SUPPORT_TICK, 200, A.ScorchingSupportTick)
			A.ScorchingSupportTick()
		end
		fragments.scorching:Refresh()
	end

	function A.ScorchingSupport(_, _, _, _, _, _, _, sourceType)
		if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end

		-- There is no combat event when scorching support ends, so just count manually
		scorchingSupportActive = true
		zo_callLater(function() scorchingSupportActive = false end, SCORCHING_SUPPORT_DURATION)

		-- Reset timer to ensure accuracy
		A.RegisterScorchingSupport(true)
	end

	local scorchingSupportCountPrev = 0
	function A.ScorchingSupportTick()
		-- The game just checks for proc every 15 seconds after the latest proc (even out of combat)
		-- Always show the countdown because it's also useful before starting combat
		scorchingSupportCount = SCORCHING_SUPPORT_COOLDOWN - math.floor((time() - SW.scorchingSupportTime) / 1000) % SCORCHING_SUPPORT_COOLDOWN
		local color = 'FFFFFF'
		if scorchingSupportActive then
			color = '00FF00'
		elseif scorchingSupportCount <= 5 then
			color = 'FFFF00'
		end
		IAHelper_ScorchingSupport_Duration:SetText(strformat('|c%s%d|r', color, scorchingSupportCount))

		if scorchingSupportCount == 5 and scorchingSupportCountPrev == 6 and inCombat then A.PlaySound('ENDLESS_DUNGEON_BUFF_SELECT_AVATAR_VISION') end

		scorchingSupportCountPrev = scorchingSupportCount
	end
end

-- Infuser
do
	local EVENT_INFUSE_TICK = A.NAME .. "InfuseTick"
	local infuser1 = 0 -- unitId of the 1st infuser
	local infuser2 = 0 -- unitId if the 2nd infuser (there can be two)
	local interruptTime1 = 0
	local interruptTime2 = 0
	local soundTime = 0 -- last time() sound played

	-- Update countdown text
	local function UpdateTimer(s)
		A.ShowWin1(s)
	end

	-- Stop countdown
	local function StopTimer(unitId)
		--d(strformat("|c00FFFFInfuser#%s stopped: %s|r", unitId, time()))
		if infuser1 == unitId then
			interruptTime1 = 0
		elseif infuser2 == unitId then
			interruptTime2 = 0
		end
		if not unitId or not units[infuser1] and not units[infuser2] then
			EM:UnregisterForUpdate(EVENT_INFUSE_TICK)
			A.HideWin1()
			interruptTime1 = 0
			interruptTime2 = 0
		end
	end

	local function InfuseTick()
		local t1 = interruptTime1 - time()
		local t2 = interruptTime2 - time()
		if t1 < -3000 and t2 < -3000 then
			StopTimer()
		else
			if units[infuser1] and units[infuser2] then -- both infusers are alive
				UpdateTimer(strformat("Interrupt: |c%s%0.1f|r / |c%s%0.1f|r", t1 > 5000 and "00FF00" or "FFFF00", t1 > 0 and t1 / 1000 or 0, t2 > 5000 and "00FF00" or "FFFF00", t2 > 0 and t2 / 1000 or 0))
			else
				local t = units[infuser1] and t1 or t2
				UpdateTimer(strformat("Interrupt: |c%s%0.1f|r", t > 5000 and "00FF00" or "FFFF00", t > 0 and t / 1000 or 0))
			end
			-- play sound when close to interrupt
			if (t1 > 0 and t1 < 4000 or t2 > 0 and t2 < 4000) and time() - soundTime > 10000 then
				soundTime = time()
				A.PlaySound('BATTLEGROUND_NEARING_VICTORY')
			end
		end
	end

	-- Begin countdown to Infuse mechanic (weird function placement because of local scope -.-)
	local function StartTimer(duration, unitId)
		if infuser1 == unitId then
			interruptTime1 = time() + duration
		else
			interruptTime2 = time() + duration
		end
		EM:UnregisterForUpdate(EVENT_INFUSE_TICK)
		EM:RegisterForUpdate(EVENT_INFUSE_TICK, 100, InfuseTick)
		InfuseTick()
	end

	local spawnTime = 0
	function A.InfuserSpawn(unitId)
		--d(strformat("|c00FFFFInfuser#%s spawn: %s|r", unitId, time()))
		if time() - spawnTime > 1000 then
			infuser1 = unitId
		else
			infuser2 = unitId
		end
		spawnTime = time()
		StartTimer(16000, unitId)
	end

	-- There is no way to know infuser's unitId when he begins the cast
	function A.InfuserInfuse()
		--d(strformat("Infuse @ %s", time()))
	end

	function A.InfuserInterrupt(unitId)
		--d(strformat("|c00FFFFInfuser#%s interrupt: %s|r", unitId, time()))
		local t = 15000
		if units[unitId] and units[unitId][2] == 'Flameshaper' then
			t = 20000
		end
		StartTimer(t, unitId)
	end

	-- Infuser buffs allies
	local lastTargetTime = 0 -- only process the event once
	function A.InfuserTargetAllies(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
		if hitValue == 1 and result == 2240 and time() - lastTargetTime > 1000 then
			StartTimer(15000, sourceUnitId)
		end
	end

	function A.Inferno(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
		-- There is no sourceUnitId for Inferno cast, so use whatever we have
		if infuser1 > 0 and units[infuser1] and units[infuser1][2] == 'Flameshaper' then
			sourceUnitId = infuser1
		else
			sourceUnitId = infuser2
		end
		A.ShowWin2("Inferno!")
		A.PlaySound('DUEL_START')
		zo_callLater(function() A.HideWin2() end, 2000)
		StartTimer(20000, sourceUnitId)
	end

	function A.InfuserDeath(unitId)
		--d(strformat("|c00FFFFInfuser#%s died: %s|r", unitId, time()))
		StopTimer(unitId)
	end

	function A.InfuserPoolOfShadow(_, result, _, _, _, _, _, _, _, _, hitValue)
		if result == ACTION_RESULT_BEGIN then
			A.PlaySound('CHAMPION_POINTS_COMMITTED')
			A.ShowReticle('MOVE')
			zo_callLater(function() A.HideReticle() end, hitValue)
		end
	end

	--[[
	function A.TestInfuser()
		units[1] = {}
		units[2] = {}
		A.InfuserSpawn(1)
		A.InfuserSpawn(2)
		zo_callLater(function() d('interrupt 1'); A.InfuserInterrupt(1) end, 5000)
		zo_callLater(function() d('target 2'); A.InfuserTargetAllies(2) end, 7000)
		zo_callLater(function() d('dead 2'); units[2] = nil; A.InfuserDeath(2) end, 15000)
	end
	]]
end

-- Storm Imp
do
	function A.StormImpZap(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
		if targetType == COMBAT_UNIT_TYPE_PLAYER then
			if result == ACTION_RESULT_BEGIN and hitValue == 500 then
				A.RegisterHeavyAttack(750, 'FF0000', 'ZAP')
			elseif result == ACTION_RESULT_EFFECT_GAINED_DURATION and hitValue > 0 then
				A.ShowCastbar(hitValue)
			elseif result == ACTION_RESULT_EFFECT_FADED and hitValue == 4000 then
				A.HideCastbar()
			end
		end
	end

	local EVENT_STORM_IMP_TICK = A.NAME .. "StormImpTick"
	local endTime = 0
	local function StormImpTick()
		local t = endTime - time()
		if t < 0 then
			EM:UnregisterForUpdate(EVENT_STORM_IMP_TICK)
			A.HideWin1()
		else
			A.ShowWin1(strformat("Imp: |c%s%0.1f|r", "FFFF00", t / 1000))
		end
	end

	-- Start countdown until the first zap.
	function A.StormImpSpawn()
		endTime = time() + 5000
		EM:UnregisterForUpdate(EVENT_STORM_IMP_TICK)
		EM:RegisterForUpdate(EVENT_STORM_IMP_TICK, 100, StormImpTick)
		StormImpTick()
	end
end

-- Blobs and tentacles
do
	local spawnCount = 0
	local EVENT_CRAP = A.NAME .. 'Crap'

	local function CrapSpawned()
		EM:UnregisterForUpdate(EVENT_CRAP)
		A.RegisterHeavyAttack(1250, 'FFFFFF', spawnCount == 1 and 'BLOB' or 'CRAP', SOUNDS.DUEL_INVITE_RECEIVED)
		spawnCount = 0
	end

	function A.Crap()
		if not isBossFight then
			spawnCount = spawnCount + 1
			EM:UnregisterForUpdate(EVENT_CRAP)
			EM:RegisterForUpdate(EVENT_CRAP, 100, CrapSpawned)
		end
	end
end

-- Aramril
do
	local EVENT_ARAMRIL_TICK = A.NAME .. "AramrilTick"
	local interruptTime = 0

	local function AramrilTick()
		local t = interruptTime - time()
		if t < -3000 then
			EM:UnregisterForUpdate(EVENT_ARAMRIL_TICK)
			A.HideWin1()
		else
			A.ShowWin1(strformat("Cast: |c%s%0.1f|r", t > 3000 and "00FF00" or "FFFF00", t > 0 and t / 1000 or 0))
		end
	end

	-- Start fight
	function A.Aramril()
		interruptTime = time() + 15000
		EM:UnregisterForUpdate(EVENT_ARAMRIL_TICK)
		EM:RegisterForUpdate(EVENT_ARAMRIL_TICK, 100, AramrilTick)
		AramrilTick()
	end

	function A.AramrilCast()
		A.RegisterHeavyAttack(2000, 'FF0000')--, 'BASH')
		interruptTime = time() + 17000
		EM:UnregisterForUpdate(EVENT_ARAMRIL_TICK)
		EM:RegisterForUpdate(EVENT_ARAMRIL_TICK, 100, AramrilTick)
		AramrilTick()
	end

	-- Stop combat
	function A.AramrilStop()
		interruptTime = 0
		EM:UnregisterForUpdate(EVENT_ARAMRIL_TICK)
		A.HideWin1()
	end
end

-- Misc
function A.VenomousArrow(_, result, _, _, _, _, _, _, _, targetType)
	if targetType == COMBAT_UNIT_TYPE_PLAYER then
		A.RegisterHeavyAttack(750, IA_COLOR_RED, 'BLOCK')
	end
end

function A.ShockBarrage(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
	if hitValue < 3000 then
		A.RegisterHeavyAttack(3000, IA_COLOR_RED, 'SPHERE')
	end
end

function A.MendingMiasma(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
	A.RegisterHeavyAttack(2000, IA_COLOR_RED, 'MIASMA')
end

function A.MundusBreach(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
	A.RegisterHeavyAttack(1000, IA_COLOR_YELLOW, 'WAVE', SOUNDS.NONE)
end

local nullTime = 0 -- can be too spammy in some cases
function A.Nullification(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
	if time() - nullTime > 2000 then
		nullTime = time()
		A.RegisterHeavyAttack(1000, 'BF40BF', 'NULL')
	end
end

function A.DaedricInfluence(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
	A.RegisterHeavyAttack(3000, nil, 'BUBBLE')
end

function A.LamiaResonate(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
	A.RegisterHeavyAttack(1500, nil, 'BASH')
end

function A.Negate(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
	A.PlaySound('CHAMPION_POINTS_COMMITTED')
	A.ShowWin2("Negate!")
	zo_callLater(function() A.HideWin2() end, 2000)
end

function A.ShadowrendPounce(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
	A.RegisterHeavyAttack(2000, IA_COLOR_RED, 'BASH')
end

function A.SerpentTotem(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
	A.PlaySound('CHAMPION_POINTS_COMMITTED')
	A.ShowWin1("Totem")
	zo_callLater(function() A.HideWin1() end, 3000)
end

function A.IndrikStaticCharge(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
	A.ShowWin1("Interrupt!")
	zo_callLater(function() A.HideWin1() end, 3000)
end

function A.WarriorInferno()
	A.PlaySound('DUEL_START')
	A.ShowWin1("Inferno")
	zo_callLater(function() A.HideWin1() end, 3000)	
end

function A.Scamp()
	if not scampSpawned then
		scampSpawned = true
		A.PlaySound('TELVAR_GAINED')
		A.ShowWave("|c00FF00Scamp!|r")
		zo_callLater(function() A.HideWave() end, 3000)	
	end
end

function A.ScampEscape()
	A.ShowWave("|cFF0000Scamp!|r")
	zo_callLater(function() A.HideWave() end, 3000)
end

function A.PillarsOfNirn()
	A.PlaySound('CHAMPION_POINTS_COMMITTED')
	A.ShowWave("|cFF0000Pillars of Nirn|r")
	zo_callLater(function() A.HideWave() end, 4000)
end

function A.SoulCage()
	A.PlaySound('CHAMPION_POINTS_COMMITTED')
	A.ShowWave("|cFF0000Soul Cage|r")
	zo_callLater(function() A.HideWave() end, 4000)
end

function A.MeteorCall()
	A.PlaySound('CHAMPION_POINTS_COMMITTED')
	A.ShowWave("|cFF0000Meteor|r")
	zo_callLater(function() A.HideWave() end, 4000)
end

function A.Abyss()
	A.PlaySound('CHAMPION_POINTS_COMMITTED')
	A.ShowWave("|cFF0000Abyss|r")
	zo_callLater(function() A.HideWave() end, 4000)
end

function A.Totem() -- mage totem
	A.ShowWave("|cFF0000Totem|r")
	zo_callLater(function() A.HideWave() end, 3000)
end

-- Castbar (only used for Storm Imp's Zap ability for now)
do
	local EVENT_CASTBAR_TICK = A.NAME .. 'Castbar'
	local duration = 3500
	local endTime = 0
	local soundPlayed = false

	local function CastbarTick()
		local t = endTime - time()
		if t >= 0 then
			local w = 200 * (duration - t) / duration
			IAHelper_Castbar_Bar:SetWidth(w)
			IAHelper_Castbar_Time:SetText(strformat('%0.1f', t / 1000))
			if w < 150 then
				IAHelper_Castbar_Bar:SetCenterColor(0, 0.75, 0.75, 0.75)
			else
				IAHelper_Castbar_Bar:SetCenterColor(0.75, 0, 0, 0.75)
				if not soundPlayed then
					A.PlaySound('DUEL_START')
					soundPlayed = true
				end
			end
		else
			EM:UnregisterForUpdate(EVENT_CASTBAR_TICK)
			IAHelper_Castbar:SetHidden(true)
		end
	end

	function A.ShowCastbar(d)
		if SW.enableCastbar then
			duration = d or 3500
			endTime = time() + duration
			soundPlayed = false
			IAHelper_Castbar:SetHidden(false)
			EM:UnregisterForUpdate(EVENT_CASTBAR_TICK)
			EM:RegisterForUpdate(EVENT_CASTBAR_TICK, 20, CastbarTick)
			CastbarTick()
		end
	end

	function A.HideCastbar()
		EM:UnregisterForUpdate(EVENT_CASTBAR_TICK)
		IAHelper_Castbar:SetHidden(true)
	end
end

-------------------------------------------------
---- HUD
-------------------------------------------------

function A.SetControlAnchor(control, pos, x, y)
	if x or y then
		control:ClearAnchors()
		control:SetAnchor(pos, GuiRoot, TOPLEFT, x, y)
	end
end

function A.SaveControlPosition(control, pos, x, y)
	if pos == CENTER then
		SW[x], SW[y] = control:GetCenter()
	elseif pos == TOPLEFT then
		SW[x] = control:GetLeft()
		SW[y] = control:GetTop()
	end
end

-- Restore positions of controls from saved variables
function A.RestoreHUD()
	A.SetControlAnchor(IAHelper_Reticle, CENTER, SW.reticleCenterX, SW.reticleCenterY)
	A.SetControlAnchor(IAHelper_Win1, CENTER, SW.win1CenterX, SW.win1CenterY)
	A.SetControlAnchor(IAHelper_Win2, CENTER, SW.win2CenterX, SW.win2CenterY)
	A.SetControlAnchor(IAHelper_Wave, CENTER, SW.waveCenterX, SW.waveCenterY)
	A.SetControlAnchor(IAHelper_Castbar, CENTER, SW.castbarCenterX, SW.castbarCenterY)

	A.SetControlAnchor(IAHelper_Weakening, TOPLEFT, SW.weakeningLeft, SW.weakeningTop)
	A.SetControlAnchor(IAHelper_ScorchingSupport, TOPLEFT, SW.scorchingSupportLeft, SW.scorchingSupportTop)
	A.SetControlAnchor(IAHelper_MajorCowardice, TOPLEFT, SW.majorCowardiceLeft, SW.majorCowardiceTop)

	IAHelper_Weakening_Icon:SetTexture(GetAbilityIcon(WEAKENING_ID))
	IAHelper_ScorchingSupport_Icon:SetTexture(GetAbilityIcon(SCORCHING_SUPPORT_VISION_ID))
end

function A.ResetHUD(reload)
	SW.reticleCenterX, SW.reticleCenterY = nil, nil
	SW.win1CenterX, SW.win1CenterY = nil, nil
	SW.win2CenterX, SW.win2CenterY = nil, nil
	SW.waveCenterX, SW.waveCenterY = nil, nil
	SW.castbarCenterX, SW.castbarCenterY = nil, nil
	SW.weakeningLeft, SW.weakeningTop = nil, nil
	SW.scorchingSupportLeft, SW.scorchingSupportTop = nil, nil
	SW.majorCowardiceLeft, SW.majorCowardiceTop = nil, nil
	if reload then ReloadUI() end
end

-- Reticle
do
	function A.ShowReticle(text)
		IAHelper_Reticle:SetHidden(false)
		if (text ~= nil) then
			IAHelper_Reticle_Label:SetText(text)
		end
	end

	function A.HideReticle()
		IAHelper_Reticle:SetHidden(true)
	end
end

-- Generic controls
do
	function A.ShowWin1(text)
		IAHelper_Win1:SetHidden(false)
		if (text ~= nil) then
			IAHelper_Win1_Label:SetText(text)
		end
	end

	function A.HideWin1()
		IAHelper_Win1:SetHidden(true)
	end

	function A.ShowWin2(text)
		IAHelper_Win2:SetHidden(false)
		if (text ~= nil) then
			IAHelper_Win2_Label:SetText(text)
		end
	end

	function A.HideWin2()
		IAHelper_Win2:SetHidden(true)
	end
end

-- Wave
do
	function A.ShowWave(text)
		IAHelper_Wave:SetHidden(false)
		if text ~= nil then
			IAHelper_Wave_Label:SetText(text)
		end
	end

	function A.HideWave()
		IAHelper_Wave:SetHidden(true)
	end
end

-- UI visibility
do
	function A.RefreshUI()
		for _, fragment in pairs(fragments) do
			fragment:Refresh()
		end
	end

	function A.ToggleUI(locked)
		A.uiLocked = locked or false
		for _, fragment in pairs(fragments) do
			fragment.control:SetMouseEnabled(not A.uiLocked)
			fragment.control:SetMovable(not A.uiLocked)
		end
		-- Set default text when UI is unlocked
		if not A.uiLocked then
			IAHelper_Reticle_Label:SetText('> |cFFFF001.0|r / |cFF00002.5|r <')
			IAHelper_Win1_Label:SetText('Interrupt: |cFFFF007.5|r')
			IAHelper_Win2_Label:SetText('Oh yes, focus on the dragon!')
			IAHelper_Wave_Label:SetText('|cFF0000Infuser|r + |cFF00FFSpellthief|r')
			IAHelper_MajorCowardice_Text:SetText('|cFFFF00Infuser|r, |c00FF00Archer|r, |c00FF00Imp|r')
		end
		IAHelper_Buttons:SetHidden(A.uiLocked)
		A.RefreshUI()
	end
end

-------------------------------------------------
---- Load & Initialize
-------------------------------------------------

function A.IsDebugMode()
	return DEBUG
end

function A.SetDebugMode(enabled)
	DEBUG = enabled and true
	EM:UnregisterForEvent(EVENT_COMBAT, EVENT_COMBAT_EVENT)
	if DEBUG then
		EM:RegisterForEvent(EVENT_COMBAT, EVENT_COMBAT_EVENT, CombatEvent)
	end
end

-- Create a simple HUD_SCENE/HUD_UI_SCENE fragment with a display condition function
local function AddSimpleFragment(name, control, condition)
	local f = ZO_SimpleSceneFragment:New(control)
	f:SetConditional(condition or function() return not A.uiLocked end)
	HUD_SCENE:AddFragment(f)
	HUD_UI_SCENE:AddFragment(f)
	fragments[name] = f
	return f
end

local function Initialize()
	-- Create callback manager
	A.cm = A.cm or ZO_CallbackObject:New()

	-- Retrieve account wide saved variables
	SW = ZO_SavedVars:NewAccountWide('IAHelperSavedVariables', 1, nil, SW_DEFAULTS)

	-- Initialize modules
	A.units.Initialize()

	-- Register events
	EM:RegisterForEvent(A.NAME .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, PlayerActivated)

	-- Reposition UI elements
	A.RestoreHUD()

	-- Create UI fragments
	AddSimpleFragment('reticle', IAHelper_Reticle, function() return SW.enableTimers and not A.uiLocked end)
	AddSimpleFragment('win1', IAHelper_Win1)
	AddSimpleFragment('win2', IAHelper_Win2)
	AddSimpleFragment('wave', IAHelper_Wave, function() return SW.enableWave and not A.uiLocked end)
	AddSimpleFragment('castbar', IAHelper_Castbar, function() return SW.enableCastbar and not A.uiLocked end)
	AddSimpleFragment('weakening', IAHelper_Weakening, function() return SW.enableWeakening and (isBossFight and weakeningEnd > 0 or not A.uiLocked) end)
	AddSimpleFragment('cowardice', IAHelper_MajorCowardice, function() return SW.enableMajorCowardice and not A.uiLocked end)
	AddSimpleFragment('scorching', IAHelper_ScorchingSupport, function() return SW.enableScorchingSupport and (hasScorchingSupport or not A.uiLocked) end)

	-- Build LibAddonMenu2
	A.BuildMenu(SW, SW_DEFAULTS)

	-- Register Betnikh map for data sharing
	if SW.enableDataSharing and LibDataShare then
		DataShare = LibDataShare:RegisterMap("IAHelper", 20, function(tag, data)
			-- ability ids for verses and visions are around 200.000, +one more digit for stacks
			if data > 1800000 and data < 2300000 then
				local abilityId = zo_floor(data / 10)
				local stackCount = data % 10
				local buffType, isAvatarVision = GetAbilityEndlessDungeonBuffType(abilityId)
				if buffType == ENDLESS_DUNGEON_BUFF_TYPE_VERSE then
					d(strformat('|c00FFFF%s|r gets |t32:32:%s|t |cFFFFFF%s|r', GetUnitDisplayName(tag), GetAbilityIcon(abilityId), GetAbilityName(abilityId)))
				elseif buffType == ENDLESS_DUNGEON_BUFF_TYPE_VISION then
					d(strformat('|c00FFFF%s|r gets |t32:32:%s|t |cFFFFFF%s|r. %s: |c00FF00%d|r', GetUnitDisplayName(tag), GetAbilityIcon(abilityId), GetAbilityName(abilityId), isAvatarVision and 'Avatar Parts' or 'Stacks', stackCount))
				end
			else
				d(strformat('[IAHelper] Unknown data: %d', data))
			end
		end)
	end

	-- Hide annoying stage announcement
	if SW.hideStageAnnouncement then
		ZO_PreHook(CENTER_SCREEN_ANNOUNCE, 'QueueMessage', function(self, messageParams)
			if messageParams and messageParams.csaType == CENTER_SCREEN_ANNOUNCE_TYPE_ENDLESS_DUNGEON_PROGRESS then
				-- copied UpdateEndlessDungeonTrackers() function from centerscreenannouncehandlers.lua, otherwise HUD won't update without this announcement
				ENDLESS_DUNGEON_HUD_TRACKER:UpdateProgress()
				ENDLESS_DUNGEON_BUFF_TRACKER_GAMEPAD:UpdateProgress()
				if ENDLESS_DUNGEON_BUFF_TRACKER_KEYBOARD then
					ENDLESS_DUNGEON_BUFF_TRACKER_KEYBOARD:UpdateProgress()
				end
				return true -- skip calling the original function
			end
		end)
	end
end

local function OnAddOnLoaded(event, addonName)
	if addonName == A.NAME then
		EM:UnregisterForEvent(A.NAME, EVENT_ADD_ON_LOADED)
		Initialize()
	end
end

EM:RegisterForEvent(A.NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
