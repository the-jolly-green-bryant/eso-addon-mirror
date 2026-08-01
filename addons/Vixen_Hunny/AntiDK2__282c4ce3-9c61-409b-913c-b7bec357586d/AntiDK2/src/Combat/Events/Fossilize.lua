local ADK = AntiDK2
local M   = {}
ADK.Combat.Events.Fossilize = M

local ID   = ADK.IDS.FOSSILIZE
local NAME = "Fossilize"

function M.Register()
    EVENT_MANAGER:RegisterForEvent(
        ADK.name .. "_Fossilize", EVENT_COMBAT_EVENT,
        function(_, _, _, _, _, _, sourceName, sourceType, targetName, _, _, _, _, _, _, targetUnitId, abilityId)
            if not ADK.savedVars.trackFossilize        then return end
            if abilityId ~= ID                         then return end
            local name = zo_strformat("<<1>>", sourceName)
            --if name == GetUnitName("player") then return end
            --if sourceType == COMBAT_UNIT_TYPE_PLAYER   then return end
            local tName = zo_strformat("<<1>>", targetName)
            --if tName ~= GetUnitName("player") then return end]]
            if tName == "" and name == "" then return end
            ADK.UI.Stuns.ShowAvoidWithRoll(NAME)
            --ADK.Combat.Events.Wings.TrackEnemy(sourceName, sourceType)
        end
    )
end
function M.Unregister()
    EVENT_MANAGER:UnregisterForEvent(ADK.name .. "_Fossilize", EVENT_COMBAT_EVENT)
end
function M.Reset() end
