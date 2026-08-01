local SRC = SupportRotationCallouts
SRC.BarrierEventAdapter = SRC.BarrierEventAdapter or {}
local Adapter = SRC.BarrierEventAdapter

function Adapter:Initialize()
    for abilityId in pairs(SRC.Barrier.ABILITY_IDS) do
        local eventName = SRC.name .. "BarrierCast" .. tostring(abilityId)
        EVENT_MANAGER:RegisterForEvent(
            eventName,
            EVENT_COMBAT_EVENT,
            function(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                    sourceName, sourceType, targetName, targetType, hitValue, powerType,
                    damageType, log, sourceUnitId, targetUnitId, observedAbilityId, overflow)
                SRC.Diagnostics:AddFields("RAW_CAST", "Barrier combat event", {
                    abilityId = observedAbilityId,
                    configuredAbilityId = abilityId,
                    abilityName = abilityName,
                    result = result,
                    sourceName = sourceName,
                    sourceType = sourceType,
                    targetName = targetName,
                    targetType = targetType,
                    sourceUnitId = sourceUnitId,
                    targetUnitId = targetUnitId,
                })
            end
        )
        EVENT_MANAGER:AddFilterForEvent(
            eventName,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_ABILITY_ID,
            abilityId
        )
    end

    SRC.Diagnostics:Add("BARRIER", "Barrier listeners registered")
end
