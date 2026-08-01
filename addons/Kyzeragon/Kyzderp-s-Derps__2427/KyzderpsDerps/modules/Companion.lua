KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Companion = KyzderpsDerps.Companion or {}
local Companion = KyzderpsDerps.Companion

---------------------------------------------------------------------
-- Summon result
---------------------------------------------------------------------
local function OnSummonResult(_, summonResult, companionId)
    if (not KyzderpsDerps.savedOptions.companion.showSummonResult) then return end

    local summonResults = {
        [COMPANION_SUMMON_RESULT_ADDED_FOR_GROUP_PLAYER] = "ADDED_FOR_GROUP_PLAYER",
        [COMPANION_SUMMON_RESULT_BLOCKED_BY_ASSISTANT] = "BLOCKED_BY_ASSISTANT",
        [COMPANION_SUMMON_RESULT_BLOCKED_BY_FOLLOWER] = "BLOCKED_BY_FOLLOWER",
        [COMPANION_SUMMON_RESULT_BLOCKED_BY_SUBZONE] = "BLOCKED_BY_SUBZONE",
        [COMPANION_SUMMON_RESULT_BLOCKED_BY_WORLD_BOSS] = "BLOCKED_BY_WORLD_BOSS",
        [COMPANION_SUMMON_RESULT_BLOCKED_BY_WORLD_EVENT] = "BLOCKED_BY_WORLD_EVENT",
        [COMPANION_SUMMON_RESULT_DATA_NOT_LOADED] = "DATA_NOT_LOADED",
        [COMPANION_SUMMON_RESULT_DEACTIVATED_VANITY_PET] = "DEACTIVATED_VANITY_PET",
        [COMPANION_SUMMON_RESULT_EFFECT_LIMIT] = "EFFECT_LIMIT",
        [COMPANION_SUMMON_RESULT_EXPECTED_DIFFERENT_COMPANION] = "EXPECTED_DIFFERENT_COMPANION",
        [COMPANION_SUMMON_RESULT_GROUP_FULL] = "GROUP_FULL",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_ASSISTANT] = "REMOVED_FOR_ASSISTANT",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_FOLLOWER] = "REMOVED_FOR_FOLLOWER",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_GROUP_PLAYER] = "REMOVED_FOR_GROUP_PLAYER",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_PERF] = "REMOVED_FOR_PERF",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_SUBZONE] = "REMOVED_FOR_SUBZONE",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_VANITY_PET] = "REMOVED_FOR_VANITY_PET",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_WORLD_BOSS] = "REMOVED_FOR_WORLD_BOSS",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_WORLD_EVENT] = "REMOVED_FOR_WORLD_EVENT",
        [COMPANION_SUMMON_RESULT_SPAWN_FAILED] = "SPAWN_FAILED",
        [COMPANION_SUMMON_RESULT_SUMMON_AUTO_REQUESTED] = "SUMMON_AUTO_REQUESTED",
        [COMPANION_SUMMON_RESULT_SUMMON_FAILED] = "SUMMON_FAILED",
        [COMPANION_SUMMON_RESULT_SUMMON_FAILED_LOW_RAPPORT] = "SUMMON_FAILED_LOW_RAPPORT",
        [COMPANION_SUMMON_RESULT_SUMMON_REQUESTED] = "SUMMON_REQUESTED",
    }
    KyzderpsDerps:msg(zo_strformat("Summon result for <<1>>: <<2>>", GetCompanionName(companionId), summonResults[summonResult]))
end

---------------------------------------------------------------------
-- Rapport
---------------------------------------------------------------------
local function OnCompanionRapportUpdated(_, companionId, previousRapport, currentRapport)
    if (not KyzderpsDerps.savedOptions.companion.showRapport) then return end

    local arrow = ""
    local change = currentRapport - previousRapport
    if (currentRapport > previousRapport) then
        arrow = "|c00FF00↑ +"
    else
        arrow = "|cFF0000↓ "
    end
    KyzderpsDerps:msg(zo_strformat("Rapport changed for <<1>>: <<2>> → <<3>> <<4>><<5>>|r", GetCompanionName(companionId), previousRapport, currentRapport, arrow, change))
end


---------------------------------------------------------------------
-- Called on initial player activated
---------------------------------------------------------------------
function Companion.Initialize()
    KyzderpsDerps:dbg("    Initializing Companion module...")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CompanionSummonResult", EVENT_COMPANION_SUMMON_RESULT, OnSummonResult)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CompanionRapport", EVENT_COMPANION_RAPPORT_UPDATE, OnCompanionRapportUpdated)

    -- Only for debug for now
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CompanionStateChanged", EVENT_ACTIVE_COMPANION_STATE_CHANGED, function(_, newState, oldState)
        local companionState = {
            [COMPANION_STATE_ACTIVE] = "ACTIVE",
            [COMPANION_STATE_BLOCKED_PERMANENT] = "BLOCKED_PERMANENT",
            [COMPANION_STATE_BLOCKED_TEMPORARY] = "BLOCKED_TEMPORARY",
            [COMPANION_STATE_HIDDEN] = "HIDDEN",
            [COMPANION_STATE_INACTIVE] = "INACTIVE",
            [COMPANION_STATE_INITIALIZED_PENDING] = "INITIALIZED_PENDING",
            [COMPANION_STATE_INITIALIZING] = "INITIALIZING",
            [COMPANION_STATE_PENDING] = "PENDING",
        }
        KyzderpsDerps:dbg(zo_strformat("companion state: <<1>> -> <<2>>", companionState[oldState], companionState[newState]))
    end)
end

function Companion.GetSettings()
    return {
        {
            type = "description",
            title = nil,
            text = "You can toggle companions with the |c99FF99/bastian|r, |c99FF99/mirri|r, |c99FF99/ember|r, |c99FF99/isobel|r, |c99FF99/sharp|r, |c99FF99/azandar|r, |c99FF99/tanlorin|r, and |c99FF99/zerith|r commands.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Display rapport changes",
            tooltip = "Shows a message in chat when your companion's rapport changes",
            default = true,
            getFunc = function() return KyzderpsDerps.savedOptions.companion.showRapport end,
            setFunc = function(value)
                    KyzderpsDerps.savedOptions.companion.showRapport = value
                end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Display unsummon results",
            tooltip = "Shows a message in chat when your companion is unsummoned or cannot be summoned for error reasons",
            default = true,
            getFunc = function() return KyzderpsDerps.savedOptions.companion.showSummonResult end,
            setFunc = function(value)
                    KyzderpsDerps.savedOptions.companion.showSummonResult = value
                end,
            width = "full",
        },
    }
end
