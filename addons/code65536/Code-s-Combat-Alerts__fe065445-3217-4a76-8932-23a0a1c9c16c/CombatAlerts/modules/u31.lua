local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "CA_M_U31"
Module.NAME = CA2.GenerateModuleName(31, 1267, 1268)
Module.AUTHOR = "@code65536"
Module.ZONES = {
	1267, -- Red Petal Bastion
	1268, -- The Dread Cellar
}

Module.STRINGS = {
	-- Custom
	wall = { default = "Wall" },
}

Module.DATA = {
	-- General
	stacks = {
		[159532] = true, -- Buck Wild
		[161484] = true, -- Flame Dancer
	},

	-- Red Petal Bastion
	wall = 154542,
	blades = 154349,
	mending = 157030,
	gaze = 157573,

	-- The Dread Cellar
	soulstorm = 154386,
	outburst = 154623,
	catastrophe = {
		cast = 155184,
		name = 160055,
	},
}
local DATA = Module.DATA
local Vars

function Module:Initialize( )
	self.MONITOR_UNIT_IDS = true

	self.TIMER_ALERTS_LEGACY = {
		-- Red Petal Bastion
		[155590] = { -2, 2 }, -- Bludgeon
		[156315] = { -2, 2 }, -- Smite
		[154264] = { -2, 2 }, -- Heinous Highkick

		-- The Dread Cellar
		[154591] = { -2, 2 }, -- Lightning Rod Slam
		[155937] = { -2, 2, offset = -1200 }, -- Crush
		[156590] = { -2, 2, offset = -500 }, -- Uppercut
		[156691] = { -2, 2 }, -- Frenzy
		[161258] = { -2, 2 }, -- Sunburst
		[161743] = { -2, 2 }, -- Dissonant Blow
	}

	self.vars = {
		lastWall = 0,
	}
	Vars = self.vars
end

function Module:ProcessCombatEvents( result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	if (result == ACTION_RESULT_BEGIN and abilityId == DATA.wall) then
		local currentTime = GetGameTimeMilliseconds()
		if (currentTime - Vars.lastWall > 5000) then
			Vars.lastWall = currentTime
			CA1.Alert(nil, self:GetString("wall"), 0xFFFF00FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 1500)
		end
	elseif (result == ACTION_RESULT_BEGIN and abilityId == DATA.blades and hitValue < 1000) then
		CA1.Alert(nil, LCA.GetAbilityName(abilityId), 0x0099FFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 1500)
	elseif (result == ACTION_RESULT_BEGIN and abilityId == DATA.gaze and hitValue < 2000) then
		local _, name = LCA.IdentifyGroupUnitIdWithRole(targetUnitId, true)
		CA1.Alert(LCA.GetAbilityName(abilityId), name, 0x6633FFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 1500)
	elseif (result == ACTION_RESULT_BEGIN and abilityId == DATA.mending and hitValue < 2000 and GetUnitName("boss1") ~= "") then
		CA1.Alert(GetString(SI_BINDING_NAME_SPECIAL_MOVE_INTERRUPT), LCA.GetAbilityName(abilityId), 0x00CC00FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 1500)
	elseif (targetType == COMBAT_UNIT_TYPE_PLAYER and DATA.stacks[abilityId] and LCA.isVet) then
		local stacks
		if (result == ACTION_RESULT_EFFECT_GAINED) then
			stacks = hitValue
		elseif (result == ACTION_RESULT_EFFECT_FADED and hitValue > 100) then
			stacks = 0
		end
		if (stacks) then
			CA2.ChatMessage(string.format("%s: %d", LCA.GetAbilityName(abilityId), stacks))
		end
	elseif (result == ACTION_RESULT_EFFECT_GAINED and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == DATA.soulstorm and hitValue > 1000) then
		CA1.AlertCast(abilityId, nil, hitValue - 200, { -3, 2 })
	elseif (result == ACTION_RESULT_BEGIN and abilityId == DATA.outburst) then
		CA1.Alert(nil, LCA.GetAbilityName(abilityId), 0xFF0000FF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
	elseif (result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == DATA.catastrophe.cast and CombatAlerts.vars.extTDC) then
		CA1.AlertCast(DATA.catastrophe.name, nil, hitValue, { -2, 0, false, { 0.7, 0.3, 1, 0.3 }, { 0.7, 0.3, 1, 0.7 } })
	end
end

CA2.RegisterModule(Module)
