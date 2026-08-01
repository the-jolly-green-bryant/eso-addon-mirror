local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "CA_M_U29"
Module.NAME = CA2.GenerateModuleName(29, 1228, 1229)
Module.AUTHOR = "@code65536"
Module.ZONES = {
	1228, -- Black Drake Villa
	1229, -- The Cauldron
}

Module.DATA = {
	prison = 146371,
}
local DATA = Module.DATA

function Module:Initialize( )
	self.MONITOR_UNIT_IDS = true

	self.TIMER_ALERTS_LEGACY = {
		-- Black Drake Villa
		[141427] = { -3, 2 }, -- Heartsfire Spear
		[141457] = { -2, 2 }, -- Sunburst
		[141958] = { -2, 2 }, -- Knuckle Duster
		[142612] = { -3, 2 }, -- Fiery Blast
		[142717] = { -2, 2, offset = -1500 }, -- Clobber
		[143764] = { -3, 2 }, -- Gelid Globe
		[150355] = { -2, 2 }, -- Freezing Bash
		[150366] = { -2, 2, offset = -900 }, -- Ravaging Blow
		[150380] = { 0, 0, false, { 0.3, 0.9, 1, 0.6 } }, -- Glacial Gash
		[151647] = { -2, 2 }, -- Slice
		[151651] = { -3, 2, true }, -- Targeted Salvo

		-- The Cauldron
		[146142] = { -2, 2 }, -- Hammer Down
		[146179] = { 0, 0, false, { 0.3, 0.9, 1, 0.6 } }, -- Galvanic Blow
		[146677] = { -2, 2 }, -- Uppercut
		[146681] = { -2, 2 }, -- Crush
		[146747] = { -2, 2 }, -- Bludgeon
		[151281] = { -2, 2, offset = -620 }, -- Uppercut
		[151314] = { -2, 2 }, -- Monstrous Cleave
	}
end

function Module:ProcessCombatEvents( result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	if (result == ACTION_RESULT_BEGIN and abilityId == DATA.prison) then
		local _, name = LCA.IdentifyGroupUnitIdWithRole(targetUnitId, true)
		CA1.Alert(LCA.GetAbilityName(abilityId), name, 0x009900FF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
	end
end

CA2.RegisterModule(Module)
