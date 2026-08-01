local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "CA_M_U41"
Module.NAME = CA2.GenerateModuleName(41, 1470, 1471)
Module.AUTHOR = "@code65536"
Module.ZONES = {
	1470, -- Oathsworn Pit
	1471, -- Bedlam Veil
}

Module.STRINGS = {
	-- Custom
	erupting = { default = "Erupting" },
}

Module.DATA = {
	banners = {
		[206488] = 0x00CCFFFF, -- Glass Stomp
		[207005] = 0x00CCFFFF, -- Malediction
	},
	targeted = {
		[205597] = true, -- Scent
		[205692] = true, -- Spiderling
	},
	poison = 216820,
	webspinner = {
		spawn = 205731,
		name = 76342,
	},
	impale = {
		start = 203184,
		damage = 215433,
		offset = 150,
	},
}
local DATA = Module.DATA
local Vars

function Module:Initialize( )
	self.MONITOR_UNIT_IDS = true

	self.TIMER_ALERTS_LEGACY = {
		-- Bedlam Veil
		[204628] = { -2, 2 }, -- Terrorizing Strike
		[204663] = { -2, 2 }, -- Terrorizing Strike
		[207145] = { -2, 0, false, { 1, 0, 0.6, 0.8 } }, -- Crushing Shards
		[208268] = { -2, 0, false, { 1, 0, 0.6, 0.8 } }, -- Heavy Attack
		[218548] = { -3, 2 }, -- Ball Lightning

		-- Oathsworn Pit
		[203042] = { -2, 2 }, -- Emblazoned Strike
		[204164] = { -2, 2 }, -- Monstrous Blow
		[204899] = { -2, 0, false, { 1, 0, 0.6, 0.8 } }, -- Vicious Strikes
		[205154] = { -2, 2 }, -- Ravage
		[207619] = { -2, 2 }, -- Hammer
		[209242] = { -2, 2 }, -- Crush
	}

	self.AOE_ALERTS = {
		-- { alert_duration, exclude_tanks }
		[203149] = { 300, false }, -- Molten Tile
		[207094] = { 600, false }, -- Razor Glass
		[208489] = { 600, false }, -- Angry Balefire
		[208867] = { 400, false }, -- Sharp Glass
		[215803] = { 300, false }, -- Venting Heat
	}

	self.vars = {
		impale = {
			earliest = 0,
			latest = 0,
			duration = 0,
		},
	}
	Vars = self.vars

	self.StatusPoll_OB3 = function( )
		local currentTime = GetGameTimeMilliseconds()
		if (Vars.impale.earliest >= currentTime) then
			local remaining = Vars.impale.earliest - currentTime
			local ratio = zo_clamp(remaining / Vars.impale.duration, 0, 1)
			CA2.StatusModifyCell(1, 2, {
				text = LCA.FormatTime(remaining, LCA.TIME_FORMAT_COUNTDOWN),
				color = LCA.PackRGBA(LCA.HSLToRGB(ratio / 3, 1, 0.5, 1)),
			})
		elseif (Vars.impale.latest + DATA.impale.offset >= currentTime) then
			CA2.StatusModifyCell(1, 2, {
				text = self:GetString("erupting"),
				color = 0xFF0000FF,
			})
		else
			CA2.StatusSetRowHidden(1, true)
		end
	end
end

function Module:PostStopListening( )
	CA2.StatusDisable()
end

function Module:ProcessCombatEvents( result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	if (result == ACTION_RESULT_BEGIN and DATA.banners[abilityId]) then
		CA1.Alert(nil, LCA.GetAbilityName(abilityId), DATA.banners[abilityId], nil, 1500)
	elseif (result == ACTION_RESULT_EFFECT_GAINED_DURATION and DATA.targeted[abilityId]) then
		local _, name = LCA.IdentifyGroupUnitIdWithRole(targetUnitId, true)
		CA1.Alert(LCA.GetAbilityName(abilityId), name, 0xCC3399FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
	elseif (result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == DATA.poison and targetType == COMBAT_UNIT_TYPE_PLAYER) then
		CA1.Alert(nil, LCA.GetAbilityName(abilityId), 0x00CC00FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2500)
	elseif (result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == DATA.webspinner.spawn) then
		CA1.Alert(nil, LCA.GetAbilityName(DATA.webspinner.name), 0xFFFFFFFF, SOUNDS.OBJECTIVE_DISCOVERED, 1500)
	elseif (LCA.isVet and result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == DATA.impale.start) then
		local currentTime = GetGameTimeMilliseconds()
		local endTime = currentTime + hitValue
		if (Vars.impale.earliest < currentTime) then
			Vars.impale.earliest = endTime
			Vars.impale.duration = hitValue
		end
		if (Vars.impale.latest < endTime) then
			Vars.impale.latest = endTime
		end
		CA2.StatusEnable({
			ownerId = "u41ob3",
			rowLabels = LCA.GetAbilityName(DATA.impale.damage),
			alignFirstColumn = false,
			pollingFunction = self.StatusPoll_OB3,
		})
	end
end

CA2.RegisterModule(Module)
