-----------------------------------------------------------
-- Resurrections
-- Counts the player's successful resurrection casts in combat
--
-- EVENT_RESURRECT_RESULT fires for the resurrector when their
-- attempt settles; RESURRECT_RESULT_SUCCESS means the cast
-- completed and the offer was presented (the soul gem was spent).
-- Whether the target accepts is their choice and not counted.
-----------------------------------------------------------

if not SemisPlaygroundCheckAccess() then
    return
end

BattleScrolls = BattleScrolls or {}

---@class BattleScrollsResurrections
local resurrections = {}
BattleScrolls.resurrections = resurrections

function resurrections:Initialize()
    EVENT_MANAGER:RegisterForEvent("BattleScrolls_Resurrections", EVENT_RESURRECT_RESULT,
            function(_, _targetCharacterName, result, _targetDisplayName)
                if result ~= RESURRECT_RESULT_SUCCESS then
                    return
                end
                local state = BattleScrolls.state
                if not state or not state.initialized then
                    return
                end
                state.resurrectionCount = (state.resurrectionCount or 0) + 1
            end)
end

function resurrections:Cleanup()
    EVENT_MANAGER:UnregisterForEvent("BattleScrolls_Resurrections", EVENT_RESURRECT_RESULT)
end
