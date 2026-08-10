-- Remove from the global namespace
LibCombatAlertsInternal = nil

-- Prevent outside modification
LibCombatAlerts = LibCombatAlerts.ReadOnlyTable(LibCombatAlerts)
