KyzderpsDerps = KyzderpsDerps or {}

-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnCombatIn(_, result, isError, aName, aGraphic, aActionSlotType, sName, sType, tName, tType, hitValue, pType, dType, log, sUnitId, tUnitId, abilityId)
    if (abilityId == 104646 and KyzderpsDerps.savedOptions.grievous.enable == true) then
        if (tType ~= COMBAT_UNIT_TYPE_PLAYER and KyzderpsDerps.savedOptions.grievous.selfOnly) then
            return
        end
        GrievousRetaliation:SetHidden(false)
        EVENT_MANAGER:RegisterForUpdate("KDD_HideGrievous", KyzderpsDerps.savedOptions.grievous.timer, function()
            GrievousRetaliation:SetHidden(true)
            EVENT_MANAGER:UnregisterForUpdate("KDD_HideGrievous")
        end)
    end
end

function KyzderpsDerps.InitializeGrievous()
    KyzderpsDerps:dbg("    Initializing Grievous module...")

    -- Register
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "Grievous", EVENT_COMBAT_EVENT, OnCombatIn)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "Grievous", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE)
end
