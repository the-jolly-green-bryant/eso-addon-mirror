local ADK = AntiDK2
local M   = {}
ADK.Combat.Events.DragonknightStandard = M

local ID   = ADK.IDS.SHIFTING_STANDARD
local NAME = "Shifting Standard"

function M.Register()
    EVENT_MANAGER:RegisterForEvent(
        ADK.name .. "_Standard", EVENT_COMBAT_EVENT,
        function(_, _, _, _, _, _, sourceName, sourceType, targetName, _, _, _, _, _, _, targetUnitId, abilityId)
            if not ADK.savedVars.trackShiftingStandard then return end
            if abilityId ~= ID                         then return end
            if sourceType == COMBAT_UNIT_TYPE_PLAYER   then return end
            local tName = zo_strformat("<<1>>", targetName)
            if tName ~= GetUnitName("player") then return end
            ADK.UI.Stuns.ShowAvoid(NAME)
            --ADK.Combat.Events.Wings.TrackEnemy(sourceName, sourceType)
        end
    )
end
function M.Unregister()
    EVENT_MANAGER:UnregisterForEvent(ADK.name .. "_Standard", EVENT_COMBAT_EVENT)
end
function M.Reset() end
