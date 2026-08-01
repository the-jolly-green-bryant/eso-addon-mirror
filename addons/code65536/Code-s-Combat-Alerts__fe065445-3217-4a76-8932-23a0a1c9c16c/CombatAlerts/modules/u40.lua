local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "CA_M_U40"
Module.NAME = CA2.GenerateModuleName(40, 1436)
Module.AUTHOR = "@code65536"
Module.ZONES = {
	1436, -- Infinite Archive
}

Module.DATA = {
	mirror = {
		shattered = 192039,
		name = 192013,
		timing = 2000,
	},
	sky = {
		id = 208132,
		damage = 208131,
		offset = -250,
	},
	thresh = 204225,
	meteor = {
		call = 211976,
		timer = 211977,
	},
	taupezuConduit = {
		id = 209137,
		damage = 209138,
		offset = 350,
	},
}
local DATA = Module.DATA

function Module:Initialize( )
	self.TIMER_ALERTS_LEGACY = {
		[192205] = { -2, 0 }, -- Tempered Blow
		[199608] = { -2, 0 }, -- Heinous Highkick
		[210028] = { -3, 0 }, -- Marauder Gothmau: Bouncing Flames (first in sequence)
		[210519] = { -2, 0 }, -- Marauder Hilkarax: Dual Strike
		[210840] = { -2, 0 }, -- Marauder Ulmor: Heavy Attack
		[220298] = { -2, 0 }, -- Marauder Zulfimbul: Clobber
		[221112] = { 500, 0 }, -- Marauder Bittog: Slaughter
		[221979] = { -3, 0 }, -- Yandir the Butcher: Toxic Tide
	}

	self.SMALL_GROUP_SIZE = true
	self.PURGEABLE_EFFECTS = {
		[196690] = 0, -- Venomous Arrow
		[196780] = 0, -- Blood Craze
		[196862] = 0, -- Rotbone
		[209970] = 0, -- Bleeding (Marauder Gothmau)
		[221109] = 0, -- Bleeding (Marauder Bittog)
		[221981] = 0, -- Toxic Tide (Yandir the Butcher)
	}
end

function Module:ProcessCombatEvents( result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	if (result == ACTION_RESULT_EFFECT_FADED and abilityId == DATA.mirror.shattered) then
		CA1.AlertCast(DATA.mirror.name, nil, DATA.mirror.timing, { 600, 0, false })
	elseif (result == ACTION_RESULT_EFFECT_GAINED_DURATION and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == DATA.sky.id) then
		CA1.AlertCast(DATA.sky.damage, nil, hitValue + DATA.sky.offset, { -2, 0 })
	elseif (result == ACTION_RESULT_BEGIN and abilityId == DATA.thresh) then
		CA1.Alert(nil, LCA.GetAbilityName(abilityId), 0x9966FFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
	elseif (result == ACTION_RESULT_BEGIN and abilityId == DATA.meteor.call) then
		CA1.Alert(nil, LCA.GetAbilityName(abilityId), 0xFF9900FF, nil, 3000)
		LCA.PlaySounds("DUEL_BOUNDARY_WARNING", 3, 750, "DUEL_BOUNDARY_WARNING", 3, 750, "DUEL_BOUNDARY_WARNING", 4)
	elseif (result == ACTION_RESULT_BEGIN and abilityId == DATA.taupezuConduit.id) then
		CA1.AlertCast(DATA.taupezuConduit.damage, nil, hitValue + DATA.taupezuConduit.offset, { 0, 0, false, { 1, 0, 0.6, 0.8 } })
	end
end

CA2.RegisterModule(Module)
