local identifier = "LibBossFight"
local version = 1.4
local LibBossFight = LibStub:NewLibrary(identifier, 1)
if not LibBossFight then return end

-- Craglorn (Basegame)
TRIAL_HEL_RA_CITADEL 		= 1
TRIAL_AETHERIAN_ARCHIVE 	= 2
TRIAL_SANCTUM_OPHIDIA 		= 3
TRIAL_DRAGONSTAR_ARENA 		= 4
-- ThievesGuild (DLC)
TRIAL_MAW_OF_LORKHAJ 		= 5
-- Orsinium (DLC)
TRIAL_MAELSTROM_ARENA 		= 6
-- Morrowind (Addon)
TRIAL_HALLS_OF_FABRICATION 	= 7
-- ClockworkCity (DLC)
TRIAL_ASYLUM_SANCTORIUM 	= 8
-- Summerset (Addon)
TRIAL_CLOUDREST				= 9
-- Murkmire (DLC)
TRIAL_BLACKROSE_PRISON		= 11

-- Basegame
DNG_FUNGAL_GROTTO_I 		= 1
DNG_FUNGAL_GROTTO_II 		= 2
DNG_SPINDLECLUTCH_I 		= 3
DNG_SPINDLECLUTCH_II 		= 4
DNG_BANISHED_CELLS_I 		= 5
DNG_BANISHED_CELLS_II 		= 6
DNG_DARKSHADE_CAVERNS_I 	= 7
DNG_DARKSHADE_CAVERNS_II 	= 8
DNG_ELDEN_HOLLOW_I 			= 9
DNG_ELDEN_HOLLOW_II 		= 10
DNG_WAYREST_SEWERS_I 		= 11
DNG_WAYREST_SEWERS_II 		= 12
DNG_ARX_CORINIUM_I 			= 13
DNG_CITY_OF_ASH_I 			= 14
DNG_CITY_OF_ASH_II 			= 15
DNG_CRYPT_OF_HEARTS_I 		= 16
DNG_CRYPT_OF_HEARTS_II 		= 17
DNG_DIREFROST_KEEP_I 		= 18
DNG_TEMPEST_ISLAND_I 		= 19
DNG_VOLENFELL_I 			= 20
DNG_BLEACKHEART_HAVEN_I 	= 21
DNG_BLESSED_CRUCIBLE_I 		= 22
DNG_SELENES_WEB_I 			= 23
DNG_VAULTS_OF_MADNESS_I 	= 24
-- ImperialCity DLC
DNG_WHITEGOLD_TOWER_I 		= 25
DNG_IMPERIAL_CITY_PRISON_I 	= 26
-- ShadowOfTheHist DLC
DNG_RUINS_OF_MAZZATUN_I 	= 27
DNG_CRADLE_OF_SHADOWS_I 	= 28
-- HornsOfTheReach DLC
DNG_BLOODROOT_FORGE_I 		= 29
DNG_FALKREATH_HOLD_I 		= 30
-- Dragonbones DLC
DNG_FANG_LAIR_I 			= 31
DNG_SCALECALLER_PEAK_I 		= 32
-- Wolfhunter DLC
DNG_MOONHUNTER_KEEP_I		= 33
DNG_MARCH_OF_SACRIFICES_I	= 34
-- Wrathstone DLC
DNG_DEPTHS_OF_MALATAR_I		= 35
DNG_FROSTVAULT_I			= 36

DNG_MIN = 1
DNG_MAX = 36

local DUNGEONS = {
	[DNG_DEPTHS_OF_MALATAR_I] = {
		zone = 1081,
		ft_node = 390,
		name = 'placeholder',
		access = 'dlc'
	},
	[DNG_FROSTVAULT_I] = {
		zone = 1080,
		ft_node = 389,
		name = 'placeholder',
		access = 'dlc'
	},
	[DNG_MARCH_OF_SACRIFICES_I] = {
		zone = 1055,
		ft_node = 370,
		name = 'placeholder',
		access = 'dlc'
	},
	[DNG_MOONHUNTER_KEEP_I] = {
		zone = 1052,
		ft_node = 371,
		name = 'placeholder',
		access = 'dlc'
	},
	[DNG_RUINS_OF_MAZZATUN_I] = {
        name = 'placeholder',
        zone = 843,
        ft_node = 260,
        access = 'dlc'
    },
	[DNG_SCALECALLER_PEAK_I] = {
        name = 'placeholder',
        zone = 1010,
        ft_node = 363,
        access = 'dlc'
    },
	[DNG_BLESSED_CRUCIBLE_I] = {
        name = 'placeholder',
        zone = 64,
        ft_node = 187,
        access = 'basegame'
    },
	[DNG_IMPERIAL_CITY_PRISON_I] = {
        name = 'placeholder',
        zone = 678,
        ft_node = 236,
        access = 'dlc'
    },
	[DNG_VOLENFELL_I] = {
        name = 'placeholder',
        zone = 22,
        ft_node = 196,
        access = 'basegame'
    },
	[DNG_FANG_LAIR_I] = {
        name = 'placeholder',
        zone = 1009,
        ft_node = 341,
        access = 'dlc'
    },
	[DNG_FALKREATH_HOLD_I] = {
        name = 'placeholder',
        zone = 974,
        ft_node = 332,
        access = 'dlc'
    },
	[DNG_SPINDLECLUTCH_I] = {
        name = 'placeholder',
        zone = 144,
        ft_node = 193,
        access = 'basegame'
    },
	[DNG_BLOODROOT_FORGE_I] = {
        name = 'placeholder',
        zone = 973,
        ft_node = 326,
        access = 'dlc'
    },
	[DNG_TEMPEST_ISLAND_I] = {
        name = 'placeholder',
        zone = 131,
        ft_node = 188,
        access = 'basegame'
    },
	[DNG_SPINDLECLUTCH_II] = {
        name = 'placeholder',
        zone = 936,
        ft_node = 267,
        access = 'basegame'
    },
	[DNG_BANISHED_CELLS_II] = {
        name = 'placeholder',
        zone = 935,
        ft_node = 262,
        access = 'basegame'
    },
	[DNG_WAYREST_SEWERS_II] = {
        name = 'placeholder',
        zone = 933,
        ft_node = 263,
        access = 'basegame'
    },
	[DNG_SELENES_WEB_I] = {
        name = 'placeholder',
        zone = 31,
        ft_node = 185,
        access = 'basegame'
    },
	[DNG_CITY_OF_ASH_I] = {
        name = 'placeholder',
        zone = 176,
        ft_node = 197,
        access = 'basegame'
    },
	[DNG_ELDEN_HOLLOW_I] = {
        name = 'placeholder',
        zone = 126,
        ft_node = 191,
        access = 'basegame'
    },
	[DNG_ELDEN_HOLLOW_II] = {
        name = 'placeholder',
        zone = 931,
        ft_node = 265,
        access = 'basegame'
    },
	[DNG_DARKSHADE_CAVERNS_II] = {
        name = 'placeholder',
        zone = 930,
        ft_node = 264,
        access = 'basegame'
    },
	[DNG_BANISHED_CELLS_I] = {
        name = 'placeholder',
        zone = 380,
        ft_node = 194,
        access = 'basegame'
    },
	[DNG_CRADLE_OF_SHADOWS_I] = {
        name = 'placeholder',
        zone = 848,
        ft_node = 261,
        access = 'dlc'
    },
	[DNG_WHITEGOLD_TOWER_I] = {
        name = 'placeholder',
        zone = 688,
        ft_node = 247,
        access = 'dlc'
    },
	[DNG_CITY_OF_ASH_II] = {
        name = 'placeholder',
        zone = 681,
        ft_node = 268,
        access = 'basegame'
    },
	[DNG_DIREFROST_KEEP_I] = {
        name = 'placeholder',
        zone = 449,
        ft_node = 195,
        access = 'basegame'
    },
	[DNG_ARX_CORINIUM_I] = {
        name = 'placeholder',
        zone = 148,
        ft_node = 192,
        access = 'basegame'
    },
	[DNG_BLEACKHEART_HAVEN_I] = {
        name = 'placeholder',
        zone = 38,
        ft_node = 186,
        access = 'basegame'
    },
	[DNG_WAYREST_SEWERS_I] = {
        name = 'placeholder',
        zone = 146,
        ft_node = 189,
        access = 'basegame'
    },
	[DNG_DARKSHADE_CAVERNS_I] = {
        name = 'placeholder',
        zone = 63,
        ft_node = 198,
        access = 'basegame'
    },
	[DNG_VAULTS_OF_MADNESS_I] = {
        name = 'placeholder',
        zone = 11,
        ft_node = 184,
        access = 'basegame'
    },
	[DNG_CRYPT_OF_HEARTS_II] = {
        name = 'placeholder',
        zone = 932,
        ft_node = 269,
        access = 'basegame'
    },
    [DNG_CRYPT_OF_HEARTS_I] = {
        name = 'placeholder',
        zone = 130,
        ft_node = 190,
        access = 'basegame'
    },
	[DNG_FUNGAL_GROTTO_I] = {
		zone = 283,
		ft_node = 98,
		name = 'placeholder',
		access = 'basegame'
	},
	[DNG_FUNGAL_GROTTO_II] = {
		zone = 934,
		ft_node = 266,
		name = 'placeholder',
		access = 'basegame'
	},
}

-- Localize dungeon names;
for dungeon, data in pairs(DUNGEONS) do
	data.name = GetZoneNameById(data.zone)
end

--[[
														Public LibBossFight dungeon API
]]-- 

function PrintDungeonList()
	for dng_id = DNG_MIN, DNG_MAX do
		dng = DUNGEONS[dng_id]
		d(string.format('[%s] %s (%s/%s) - %s', dng_id, dng.name, dng.zone, dng.ft_node, dng.access))
	end
end

function GetDungeonInfo(dungeon_id)
	if dungeon_id > DNG_MAX or dungeon_id < DNG_MIN then return nil end
	if not DUNGEONS[dungeon_id] then return nil end
	local dungeon = ZO_ShallowTableCopy(DUNGEONS[dungeon_id], dungeon)
	return dungeon
end

function GetUnitDungeonInfo(unit)
	local unit_tag = (unit or 'player')
	local zone_id = GetZoneId(GetUnitZoneIndex(unit_tag))
	for dungeon_id, dungeon in pairs(DUNGEONS) do
		if zone_id == dungeon.zone then
			return GetDungeonInfo(dungeon_id)
		end
	end
	return nil
end

function GetUnitDungeon(unit)
	local unit_tag = (unit or 'player')
	local zone_id = GetZoneId(GetUnitZoneIndex(unit_tag))
	for dungeon_id, dungeon in pairs(DUNGEONS) do
		if zone_id == dungeon.zone then
			return dungeon_id
		end
	end
	return 0
end

function TravelToDungeon(dungeon_id)
	local dungeon = GetDungeonInfo(dungeon_id)
	if not dungeon then return false end
	FastTravelToNode(dungeon.ft_node)
	return true
end

----------------------------------------------------------------------------------------------------------------------

local CONF = {
	dps_threshold_duration = 0.5,
	debug_level = 0
}

local hardmode = false
local boss_index = 0
local boss_count = 0
local boss_list = {}
local boss_history = {}
local fight = {
	active = false,
	start = 0
}

local unit_list = {}
local trash_health_registry = {}

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

local function DebugMessage(message, level)
	local dblvl = (level or 0)
	if CONF.debug_level == 0 or dblvl > CONF.debug_level then return end
	message = string.format('[%s] LBF - %s', type_to_str[dblvl], message)
	CHAT_SYSTEM:AddMessage('|cffffff'..message..'|c')
end

local function FixName(name)
	name = string.gsub(name, '%^.+', '')
	return name
end

local function GetNonModBoss(hash)
	local _boss = ZO_ShallowTableCopy(boss_list[hash], _boss)
	return _boss
end 

local function GetBossByUnitTag(unit_tag, editable)
	for hash, boss in pairs(boss_list) do
		if unit_tag == boss.unit_tag then
			if editable then return boss 
			else return GetNonModBoss(hash) end
		end
	end
	return nil
end

local function GetBossByUnitName(unit_name, editable)
	local _hash = HashString(unit_name)
	for hash, boss in pairs(boss_list) do
		if string.match(boss.name, unit_name) or hash == _hash then
			if editable then return boss 
			else return GetNonModBoss(hash) end
		end
	end
	return nil
end

local function GetAnyBoss(editable)
	for hash, boss in pairs(boss_list) do
		if boss.hash == hash then
			if editable then return boss 
			else return GetNonModBoss(hash) end
		end
	end
	return nil
end

local function GetNonModUnit(hash)
	local _unit = ZO_ShallowTableCopy(unit_list[hash], _unit)
	return _unit
end 

local function GetUnitByName(unit_name, editable)
	local _hash = HashString(unit_name)
	for hash, unit in pairs(unit_list) do
		if string.match(unit.name, unit_name) or hash == _hash then
			if editable then return unit 
			else return GetNonModUnit(hash) end
		end
	end
	return nil
end

local function GetUnitByUnitId(unit_id, editable)
	for hash, unit in pairs(unit_list) do
		if unit_id == unit.unit_id then
			if editable then return unit 
			else return GetNonModUnit(hash) end
		end
	end
	return nil
end

local function GetUnitByHash(_hash, editable)
	for hash, unit in pairs(unit_list) do
		if hash == _hash then
			if editable then return unit 
			else return GetNonModUnit(hash) end
		end
	end
	return nil
end

local function RemUnit(hash)
	local unit = GetNonModUnit(hash)
	unit_list[hash] = nil
	DebugMessage(string.format('(Unit) Tracking stop (%s, %s, %s)', unit.name, unit.unit_id, unit.hash), msg.info)
	CALLBACK_MANAGER:FireCallbacks('OnUnitTrackingStop', unit)
end

local function CreateUnit(unit_id, unit_name)
	local hash = HashString(string.format('%s:%s', tostring(unit_name), tostring(unit_id)))
	unit_list[hash] = {
		hash = hash,
		unit_id = unit_id,
		name = unit_name,
		registered = GetTimeStamp(),
		alive = true,
		damage_taken = 0,
		max_health = (trash_health_registry[unit_name] or false)
	}
	if unit_list[hash].max_health == nil then unit_list[hash].max_health = false end
	local unit = GetNonModUnit(hash)
	if not unit then return GetUnit(unit_id, unit_name) end
	DebugMessage(string.format('(Unit) Tracking start (%s, %s, %s, [%s])', unit_name, unit_id, hash, tostring(unit.max_health)), msg.info)
	CALLBACK_MANAGER:FireCallbacks('OnUnitTrackingStart', unit)
	return unit
end

local function GetUnit(unit_id, unit_name)
	if unit_name == '' or unit_name == 'Offline' or unit_name == nil or unit_id == nil or unit_id == 0 then return nil end
	local hash = HashString(string.format('%s:%s', tostring(unit_name), tostring(unit_id)))
	local unit
	unit = GetUnitByUnitId(unit_name)
	if unit == nil then unit = GetUnitByHash(hash) end
	if unit == nil then unit = CreateUnit(unit_id, unit_name) end
	return unit
end

local function ProvideTrashWithMaxHealthValue(name, max_health)
	if not trash_health_registry[name] then
		trash_health_registry[name] = max_health
	end
	for hash, unit in pairs(unit_list) do
		if string.match(unit.name, name) then
			if unit.max_health == nil or unit.max_health == false or unit.max_health <= 0 then
				DebugMessage(string.format('(Unit) Max health set [%s] (%s, %s)', max_health, unit.name, unit.unit_id), msg.info)
				unit.max_health = max_health
			end
		end
	end
end 

local function IsFinalRaidBoss()
	if GetBossByUnitTag('boss1') == nil then return false end
	local raid_id = GetCurrentParticipatingRaidId()
	local map = GetMapTileTexture()
	if raid_id == TRIAL_ASYLUM_SANCTORIUM then
		if string.match(map, 'Art/maps/clockwork/UI_Map_AsylumSanctorum001_Base_0.dds') then return true end
	elseif raid_id == TRIAL_MAW_OF_LORKHAJ then
		if string.match(map, 'Art/maps/reapersmarch/MawLorkajSevenRiddles_Base_0.dds') then return true end
	elseif raid_id == TRIAL_HEL_RA_CITADEL then
		if string.match(map, 'Art/maps/craglorn/helracitadelhallofwarrior_base_0.dds') then return true end
	elseif raid_id == TRIAL_AETHERIAN_ARCHIVE then
		if string.match(map, 'Art/maps/craglorn/aetherianarchiveend_base_0.dds') then return true end
	elseif raid_id == TRIAL_SANCTUM_OPHIDIA then
		if string.match(map, 'Art/maps/craglorn/trl_so_map03_base_0.dds') then return true end
	elseif raid_id == TRIAL_HALLS_OF_FABRICATION then
		if string.match(map, 'Art/maps/vvardenfell/UI_Map_HOFabricBoss3_Base_0.dds') then return true end
	elseif raid_id == TRIAL_CLOUDREST then
		if string.match(map, 'Art/maps/summerset/UI_Map_CloudRestTrial_base_0.dds') then return true end
	elseif raid_id == TRIAL_BLACKROSE_PRISON then
		if string.match(map, 'Art/maps/murkmire/ui_map_blackroseprison01_base_1.dds') then return true end
	end
	return false
end

local function OnBossesChanged( ... )
	local unitTag, curr, max, effmax, is_boss, hash, name
	for hash, boss in pairs(boss_list) do
		unitTag = boss.unit_tag
		
		if not DoesUnitExist(unitTag) or hash ~= boss.hash then
			local _boss = ZO_ShallowTableCopy(boss, _boss)
			DebugMessage(string.format('(Boss) Tracking stop (%s)', _boss.name), msg.info)
			CALLBACK_MANAGER:FireCallbacks('OnBossTrackingStop', GetNonModBoss(hash))
			boss_list[hash] = nil
		end
	end
	boss_count = 0
	for i = 1, MAX_BOSSES do
		unitTag = 'boss'..i
		name = GetUnitName(unitTag)
		hash = HashString(name)
		if DoesUnitExist(unitTag) then
			boss_count = boss_count + 1
			if not boss_list[hash] then
				curr, max, effmax = GetUnitPower(unitTag, POWERTYPE_HEALTH)
				boss_list[hash] = {
					name = name,
					health = {
						current = curr,
						max = max,
						effmax = effmax,
						delta = 0
					},
					fight = {
						start = 0,
						dps = 0,
						last_update = 0
					},
					is_final = IsFinalRaidBoss(),
					unit_tag = unitTag,
					hash = hash
				}
				CALLBACK_MANAGER:FireCallbacks('OnBossTrackingStart', GetNonModBoss(hash))
				DebugMessage(string.format('(Boss) Tracking start (%s, %s, [final: %s])', boss_list[hash].name, unitTag, tostring(boss_list[hash].is_final)), msg.info)
			end
		end
	end
end

local function OnPowerUpdate(_, unitTag, index, ptype, value, max, effective_max)
	if not IsUnitPlayer(unitTag) and not IsUnitPvPFlagged(unitTag) and ptype == POWERTYPE_HEALTH then
		local hash = HashString(GetUnitName(unitTag))
		if not boss_list[hash] then return end
		local boss = boss_list[hash]
		if max > boss.health.max or effective_max > boss.health.effmax then -- Health increased
			boss.health.effmax = effective_max
			boss.health.max = max
			hardmode = true
			DebugMessage(string.format('(Boss) Hardmode activated (%s, %s) [attackable: %s]', boss.name, boss.unit_tag, tostring(IsUnitAttackable(boss.unit_tag))), msg.info)
			CALLBACK_MANAGER:FireCallbacks('OnHardmodeActivation', GetNonModBoss(hash), true)
		elseif max < boss.health.max or effective_max < boss.health.effmax then -- Health reduced
			boss.health.effmax = effective_max
			boss.health.max = max
			hardmode = false
			DebugMessage(string.format('(Boss) Hardmode deactivated (%s, %s) [attackable: %s]', boss.name, boss.unit_tag, tostring(IsUnitAttackable(boss.unit_tag))), msg.info)
			CALLBACK_MANAGER:FireCallbacks('OnHardmodeDeactivation', GetNonModBoss(hash), true)
		elseif value == boss.health.max and value == boss.health.effmax and boss.fight.start > 0 then -- Wipe
			boss.fight.start = 0
			boss.health.current = value
			fight.active = false
			DebugMessage(string.format('(Boss) Fight over (%s, %s)', boss.name, boss.unit_tag), msg.info)
			CALLBACK_MANAGER:FireCallbacks('OnBossFightOver', GetNonModBoss(hash))
		elseif value <= 0 and fight.active then -- Killed
			boss.fight.start = 0
			boss.health.current = value
			fight.active = false
			DebugMessage(string.format('(Boss) Fight over [Killed] (%s, %s)', boss.name, boss.unit_tag), msg.info)
			CALLBACK_MANAGER:FireCallbacks('OnBossFightOver', GetNonModBoss(hash))
			boss_index = boss_index + 1
		elseif value < max then
			if boss.fight.start == 0 and value ~= 0 then
				boss.fight.start = GetTimeStamp()
				fight.start = boss.fight.start
				fight.active = true
				hardmode = LibBossFight:IsHardModeActive()
				DebugMessage(string.format('(Boss) Fight start (%s, %s)', boss.name, boss.unit_tag), msg.info)
				CALLBACK_MANAGER:FireCallbacks('OnBossFightStart', GetNonModBoss(hash), LibBossFight:IsHardModeActive())
			end
		end
		
		if boss.fight.start > 0 then
			boss.health.current = value
			boss.health.delta = max - value
			boss.fight.dps = boss.health.delta / (GetTimeStamp() - boss.fight.start)
			if boss.fight.dps == math.huge then boss.fight.dps = 0 end
			if GetTimeStamp() - boss.fight.last_update > CONF.dps_threshold_duration then 
				boss.fight.last_update = GetTimeStamp()
				DebugMessage(string.format('(Boss) DPS [%s] (%s, %s)', boss.fight.dps, boss.name, boss.unit_tag), msg.spam)
				DebugMessage(string.format('(Boss) FULL-DPS [%s]', LibBossFight:FullFightDPS()), msg.spam)
				CALLBACK_MANAGER:FireCallbacks('OnBossFightBossDPSUpdate', GetNonModBoss(hash), boss.fight.dps, boss.fight.start)
				CALLBACK_MANAGER:FireCallbacks('OnBossFightDPSUpdate', LibBossFight:FullFightDPS())
			end
		end
	end
end

local function OnTrialStart( ... )
	DebugMessage(string.format('(General) Trial start'), msg.info)
	hardmode = LibBossFight:IsHardModeActive()
	boss_index = 0
	boss_count = 0
	boss_list = {}
	boss_history = {}
	fight = {
		active = false,
		start = 0
	}
end

local first = true
local function OnPlayerActivated( ... )
	if first then
		if IsRaidInProgress() then
			OnTrialStart()
		end
		first = false
	end
	OnBossesChanged()
end

local function OnTargetChanged()
	local name = FixName(GetUnitName('reticleover'))
	local unit = LibBossFight:DetectUnit(nil, name)
	if unit or IsUnitPlayer('reticleover') then return end -- Is boss or player so idc
	local health, max_health = GetUnitPower('reticleover', POWERTYPE_HEALTH)
	if max_health > 0 then
		ProvideTrashWithMaxHealthValue(name, max_health)
	end
end

local unit_types = {
	[COMBAT_UNIT_TYPE_GROUP] = 'GROUP',
	[COMBAT_UNIT_TYPE_NONE] = 'NONE',
	[COMBAT_UNIT_TYPE_OTHER] = 'OTHER',
	[COMBAT_UNIT_TYPE_PLAYER_PET] = 'PLAYER_PET',
	[COMBAT_UNIT_TYPE_PLAYER] = 'PLAYER',
	[COMBAT_UNIT_TYPE_TARGET_DUMMY] = 'TARGET_DUMMY'
}

local function OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	--d(string.format('abilityName: %s (%s), source: %s [%s], target: %s [%s], value: %s [%s] | log: %s', abilityName, abilityId, sourceName, unit_types[sourceType], targetName, unit_types[targetType], hitValue, powerType, tostring(log) ))
	local killing_blow = false
	targetName = FixName(targetName)
	sourceName = FixName(sourceName)
	if targetName == 'Offline' or sourceName == 'Offline' then return end
	local source_by_name = LibBossFight:DetectUnit(nil, sourceName)
	local target_by_name = LibBossFight:DetectUnit(nil, targetName)
	if not source_by_name and not target_by_name then
		if sourceName:len() > 1 and (sourceType == COMBAT_UNIT_TYPE_NONE or sourceType == COMBAT_UNIT_TYPE_OTHER) then 
			LibBossFight:DetectTrashUnit(sourceUnitId, sourceName) 
			--d(string.format('abilityName: %s (%s), source: %s [%s], target: %s [%s], value: %s [%s] | log: %s', abilityName, abilityId, sourceName, unit_types[sourceType], targetName, unit_types[targetType], hitValue, powerType, tostring(log) ))
			if (targetType == COMBAT_UNIT_TYPE_GROUP or targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET) then
				
				local unit = GetUnitByUnitId(sourceUnitId, true)
				if unit then
					if result == ACTION_RESULT_DIED then
						unit.alive = false						
					elseif targetType == COMBAT_UNIT_TYPE_NONE and hitValue > 1 and (powerType == 0 or powerType == 6) then
						unit.damage_taken = unit.damage_taken + hitValue
						if unit.max_health and unit.max_health > 0 and unit.damage_taken > unit.max_health then
							unit.alive = false
							killing_blow = true
							DebugMessage(string.format('(Unit) Death [killing_blow] (%s, %s)', unit.name, unit.unit_id), msg.info)
							CALLBACK_MANAGER:FireCallbacks('OnUnitDeath', GetNonModUnit(unit.hash))
						end	
						DebugMessage(string.format('(Unit) Damage [%s (%s)] (%s, %s)', hitValue, unit.damage_taken, unit.name, unit.unit_id), msg.spam)
						CALLBACK_MANAGER:FireCallbacks('OnUnitDamageTakenUpdate', GetNonModUnit(unit.hash), killing_blow)
					end
				end
			end

		elseif targetName:len() > 1 and (targetType == COMBAT_UNIT_TYPE_NONE or targetType == COMBAT_UNIT_TYPE_OTHER) then
			LibBossFight:DetectTrashUnit(targetUnitId, targetName) 
			--d(string.format('abilityName: %s (%s), source: %s [%s], target: %s [%s], value: %s [%s] | log: %s', abilityName, abilityId, sourceName, unit_types[sourceType], targetName, unit_types[targetType], hitValue, powerType, tostring(log) ))
			if (sourceType == COMBAT_UNIT_TYPE_GROUP or sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET) then
				
				local unit = GetUnitByUnitId(targetUnitId, true)
				
				if unit then
					if result == ACTION_RESULT_DIED then
						unit.alive = false
						DebugMessage(string.format('(Unit) Death [ACTION_RESULT_DIED] (%s, %s)', unit.name, unit.unit_id), msg.info)
						CALLBACK_MANAGER:FireCallbacks('OnUnitDeath', GetNonModUnit(unit.hash))
					elseif targetType == COMBAT_UNIT_TYPE_NONE and hitValue > 1 and (powerType == 0 or powerType == 6) then
						unit.damage_taken = unit.damage_taken + hitValue
						if unit.max_health and unit.max_health > 0 and unit.damage_taken > unit.max_health then
							unit.alive = false
							killing_blow = true
							DebugMessage(string.format('(Unit) Death [killing_blow] (%s, %s)', unit.name, unit.unit_id), msg.info)
							CALLBACK_MANAGER:FireCallbacks('OnUnitDeath', GetNonModUnit(unit.hash))
						end	
						DebugMessage(string.format('(Unit) Damage [%s (%s)] (%s, %s)', hitValue, unit.damage_taken, unit.name, unit.unit_id), msg.spam)
						CALLBACK_MANAGER:FireCallbacks('OnUnitDamageTakenUpdate', GetNonModUnit(unit.hash), killing_blow)
					end
				end
			end
		end
	end
end

function LibBossFight:Init(dps_threshold_duration, debug_level)
	if dps_threshold_duration then
		CONF.dps_threshold_duration = dps_threshold_duration
	end
	if debug_level then
		CONF.debug_level = debug_level
	end
	EVENT_MANAGER:RegisterForEvent(identifier, EVENT_PLAYER_ACTIVATED, 			OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(identifier, EVENT_RAID_TRIAL_STARTED, 		OnTrialStart)
	EVENT_MANAGER:RegisterForEvent(identifier, EVENT_BOSSES_CHANGED, 			OnBossesChanged)
	EVENT_MANAGER:RegisterForEvent(identifier, EVENT_POWER_UPDATE, 				OnPowerUpdate)
	EVENT_MANAGER:RegisterForEvent(identifier, EVENT_RETICLE_TARGET_CHANGED,	OnTargetChanged)
	EVENT_MANAGER:RegisterForEvent(identifier, EVENT_COMBAT_EVENT, 				OnCombatEvent)
end

function LibBossFight:IsInRaidBossFight(raid_id, check_final, boss)
	if GetCurrentParticipatingRaidId() ~= raid_id then return false end
	if check_final and not IsFinalRaidBoss() then return false end
	local _boss = GetAnyBoss()
	if _boss and fight.active then return true end
	return false
end

function LibBossFight:IsInFight(boss)
	if not boss then return fight.active
	else
		local _boss = GetAnyBoss()
		if _boss and fight.active then return true end
	end
	return false
end

function LibBossFight:GetKilledBosses()
	return boss_index
end

function LibBossFight:IsArenaRaid(raid)
	local raid_id = (raid or GetCurrentParticipatingRaidId())
	if raid_id == TRIAL_MAELSTROM_ARENA or raid_id == TRIAL_DRAGONSTAR_ARENA or raid_id == TRIAL_BLACKROSE_PRISON then return true end
	return false
end

function LibBossFight:IsSoloRaid(raid)
	local raid_id = (raid or GetCurrentParticipatingRaidId())
	if raid_id == TRIAL_MAELSTROM_ARENA then return true end
	return false
end

function LibBossFight:IsSoloTrial(raid)
	return LibBossFight:IsSoloRaid(raid)
end

function LibBossFight:GetArenaString()
	local str = ''
	local raid_id, map = GetCurrentParticipatingRaidId(), GetMapTileTexture()
	map = map:lower()
	if raid_id == TRIAL_DRAGONSTAR_ARENA then
		local status, stage = pcall(function() 
			return tonumber(string.match(map, "dragonstararena(.-)_"))
		end)
		if status and stage ~= nil then
			if stage < 10 and stage > 0 then
				str = string.format('Arena %s/9', stage)	
			elseif stage == 10 then
				str = 'Final boss'
			else
				str = 'Lobby'
			end
		else
			str = 'Lobby'
		end
	elseif raid_id == TRIAL_MAELSTROM_ARENA then 
		local stage = 0
		if map:match('arenasshiveringisles_base_0.dds') then stage = 1
		elseif map:match('art/maps/wrothgar/arenasclockworkint_base_0.dds') then stage = 2
		elseif map:match('art/maps/wrothgar/arenasmurkmireexterior_base_0.dds') then stage = 3
		elseif map:match('art/maps/wrothgar/arenasclockwork2_base_0.dds') then stage = 4
		elseif map:match('art/maps/wrothgar/arenaswrothgarexterior_base_0.dds') then stage = 5
		elseif map:match('art/maps/wrothgar/arenasmephalaexterior_base_0.dds') then stage = 6
		elseif map:match('art/maps/wrothgar/arenasmurkmirecaveint_base_0.dds') then stage = 7
		elseif map:match('art/maps/wrothgar/arenaslavacaveinterior_base_0.dds') then stage = 8
		elseif map:match('art/maps/wrothgar/arenasoblivionexterior_base_0.dds') then stage = 9
		end
		if stage == 0 then
			str = 'Lobby'
		else
			str = string.format('Arena %s/9', stage)
		end
	elseif raid_id == TRIAL_BLACKROSE_PRISON then
		local killed_bosses = (kb or LibBossFight:GetKilledBosses())
		if killed_bosses == 5 then
			str = 'Finished'
		else
			str = string.format('Boss %s/5', killed_bosses+1)
		end
	end
	return str
end

-- ESO Trial Scoring by LZH (https://docs.google.com/spreadsheets/d/1NgYDFakUm0GLcMdwxVBOT8gWQ4fS_gi841i23A-Fe18)
function LibBossFight:GetEstimatedScore(raid, tt, duration, remaining, hm, kb)
	local raid_id = (raid or GetCurrentParticipatingRaidId())
	if not raid_id then return 0 end

	local estimated_score = 0
	local target_time = (tt or GetRaidTargetTime())
	local raid_duration = (duration or GetRaidDuration())/1000
	local vitality = (remaining or GetRaidReviveCountersRemaining())
	local hardmode = (hm or LibBossFight:IsHardModeActive())
	local killed_bosses = (kb or LibBossFight:GetKilledBosses())

	local base_score = 0
	if not LibBossFight:IsNoTrashRaid(raid_id) then
		if raid_id == TRIAL_HEL_RA_CITADEL then
			base_score = 93100

		elseif raid_id == TRIAL_AETHERIAN_ARCHIVE then
			base_score = 84300

		elseif raid_id == TRIAL_SANCTUM_OPHIDIA then
			base_score = 104700

		elseif raid_id == TRIAL_DRAGONSTAR_ARENA then
			base_score = 20000

		elseif raid_id == TRIAL_MAELSTROM_ARENA then
			base_score = 426000

		elseif raid_id == TRIAL_MAW_OF_LORKHAJ then
			base_score = 68150

		elseif raid_id == TRIAL_HALLS_OF_FABRICATION then
			base_score = 120100
		end
		if hardmode then
			base_score = base_score + 40000
		end
	else
		if raid_id == TRIAL_ASYLUM_SANCTORIUM then
			if killed_bosses == 2 then
				base_score = 15000
			elseif killed_bosses == 1 then
				base_score = 30000
			else
				base_score = 70000
			end
		elseif raid_id == TRIAL_CLOUDREST then
			if killed_bosses == 3 then
				base_score = 57240
			elseif killed_bosses == 2 then
				base_score = 72345
			elseif killed_bosses == 1 then
				base_score = 87450
			else
				base_score = 129055
			end
		end
	end
	if base_score == 0 then estimated_score = 0
	else estimated_score = (base_score + 1000*vitality) * (1+((target_time/1000)-raid_duration)/10000) end
	return estimated_score
end

function LibBossFight:IsHardModeActive()
	local ishardmode, boss = false, GetBossByUnitTag('boss1')
	local raid_id = GetCurrentParticipatingRaidId()
	if raid_id == TRIAL_MAELSTROM_ARENA or raid_id == TRIAL_DRAGONSTAR_ARENA or raid_id == TRIAL_BLACKROSE_PRISON then return false end -- they dont have hardmodes
	if raid_id == TRIAL_ASYLUM_SANCTORIUM then
		if boss_index == 0 then
			ishardmode = true
		end
	elseif raid_id == TRIAL_CLOUDREST then
		if boss_index == 0 then
			ishardmode = true
		end
	else
		if not IsFinalRaidBoss() or boss == nil then return false end
		if raid_id == TRIAL_AETHERIAN_ARCHIVE then
			if boss.health.max > 86000000 then ishardmode = true end
		elseif raid_id == TRIAL_HEL_RA_CITADEL then
			if boss.health.max > 86000000 then ishardmode = true end
		elseif raid_id == TRIAL_SANCTUM_OPHIDIA then
			if boss.health.max > 59000000 then ishardmode = true end
		elseif raid_id == TRIAL_MAW_OF_LORKHAJ then
			if boss.health.max > 80000000 then ishardmode = true end
		elseif raid_id == TRIAL_HALLS_OF_FABRICATION then
			if boss.health.max > 107000000 then ishardmode = true end
		else
			ishardmode = hardmode
		end
	end
	return ishardmode
end

function LibBossFight:DetectUnit(unitTag, unitName)
	local boss = nil
	if unitTag then
		boss = GetBossByUnitTag(unitTag, false)
	elseif unitName then
		boss = GetBossByUnitName(unitName, false)
	end
	return (boss or nil)
end

function LibBossFight:DetectTrashUnit(unitId, unitName)
	local unit = GetUnit(unitId, unitName)
	return (unit or nil)
end

function LibBossFight:FullFightDPS()
	local dps = 0
	for hash, boss in pairs(boss_list) do
		if boss.fight.start > 0 then
			dps = dps + boss.fight.dps
		end
	end
	return dps
end

function LibBossFight:IsNoTrashRaid(raid)
	local raid_id = (raid or GetCurrentParticipatingRaidId())
	if raid_id == TRIAL_ASYLUM_SANCTORIUM or raid_id == TRIAL_CLOUDREST then
		return true
	else
		return false
	end
end

function LibBossFight:BossOverview()
	bosses = {}
	DebugMessage(string.format('---- BossOverview ----'), msg.info)
	for hash, boss in pairs(boss_list) do
		DebugMessage(string.format('[%s] %s - final: %s', boss.unit_tag, boss.name, tostring(boss.is_final)), msg.info)
		table.insert(bosses, GetNonModBoss(hash))
	end
	return bosses
end

function LibBossFight:UnitOverview()
	units = {}
	DebugMessage(string.format('---- UnitOverview ----'), msg.info)
	for hash, unit in pairs(unit_list) do
		table.insert(units, GetNonModUnit(hash))
		DebugMessage(string.format('[%s] %s - alive: %s, damage_taken: %s, max_health: %s', unit.hash, unit.name, tostring(unit.alive), tostring(unit.damage_taken), tostring(unit.max_health)), msg.info)
	end
	return units
end