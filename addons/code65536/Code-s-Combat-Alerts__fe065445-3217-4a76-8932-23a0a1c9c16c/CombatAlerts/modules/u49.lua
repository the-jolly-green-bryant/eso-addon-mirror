local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "CA_M_U49"
Module.NAME = CA2.GenerateModuleName(49, 1559)
Module.AUTHOR = "@code65536"
Module.ZONES = {
	1559, -- Night Market
	1562, -- Gossamer Crypt
	1563, -- Mournful Catacomb
	1564, -- Timeless Wallow
	1565, -- Opulent Ordeal
}

Module.STRINGS = {
	-- Extracted

	-- Custom (Settings)
}

Module.DEFAULT_SETTINGS = {
}

Module.DATA = {
}
local DATA = Module.DATA
local Vars

function Module:Initialize( )
	self.MONITOR_UNIT_IDS = true

	self.TIMER_ALERTS_LEGACY = {
		[250487] = { 0, 0, false, { 1, 0, 0.6, 0.8 } }, -- Immutable Strike
		[250668] = { -3, 2 }, -- Revolting Scarab
		[252712] = { -3, 2, true }, -- Taking Aim
		[254142] = { -2, 2, true }, -- Eviscerate
	}

	self.AOE_ALERTS = {
		-- { alert_duration, exclude_tanks }
	}

	self.vars = {
	}
	Vars = self.vars
end

function Module:PreStartListening( )
end

function Module:PostStopListening( )
	CA2.StatusDisable()
	CA2.GroupPanelDisable()
	CA2.ScreenBorderDisable()
end

function Module:ProcessCombatEvents( result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
end

CA2.RegisterModule(Module)
