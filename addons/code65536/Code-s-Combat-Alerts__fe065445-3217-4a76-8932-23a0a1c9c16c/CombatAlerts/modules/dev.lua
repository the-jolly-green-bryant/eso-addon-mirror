local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "CA_M_DEV"
Module.NAME = "Developer Mode"
Module.AUTHOR = "@code65536"

function Module:ProcessCombatEvents( result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	if (result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER and abilityId > 70000 and hitValue >= 1000) then
		CA1.AlertCast(abilityId, sourceName, hitValue, { -1, 0, false, { 1, 1, 1, 0.2 }, { 1, 1, 1, 0.4 } })
		CA2.ChatMessage(LocalizeString("<<t:1>> [<<2>>] (<<3>>ms) from <<4>>", GetAbilityName(abilityId), abilityId, hitValue, sourceName))
	end
end

CA2.RegisterModule(Module)
