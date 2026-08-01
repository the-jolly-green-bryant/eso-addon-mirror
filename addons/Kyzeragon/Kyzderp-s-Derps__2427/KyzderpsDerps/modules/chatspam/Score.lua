KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.ChatSpam = KyzderpsDerps.ChatSpam or {}
local Spam = KyzderpsDerps.ChatSpam

---------------------------------------------------------------------
-- On score update
---------------------------------------------------------------------
local scoreReasons = {
    [RAID_POINT_REASON_BONUS_ACTIVITY_HIGH] = "BONUS_ACTIVITY_HIGH",
    [RAID_POINT_REASON_BONUS_ACTIVITY_LOW] = "BONUS_ACTIVITY_LOW",
    [RAID_POINT_REASON_BONUS_ACTIVITY_MEDIUM] = "BONUS_ACTIVITY_MEDIUM",
    [RAID_POINT_REASON_BONUS_POINT_ONE] = "BONUS_POINT_ONE",
    [RAID_POINT_REASON_BONUS_POINT_THREE] = "BONUS_POINT_THREE",
    [RAID_POINT_REASON_BONUS_POINT_TWO] = "BONUS_POINT_TWO",
    [RAID_POINT_REASON_KILL_BANNERMEN] = "KILL_BANNERMEN",
    [RAID_POINT_REASON_KILL_BOSS] = "KILL_BOSS",
    [RAID_POINT_REASON_KILL_CHAMPION] = "KILL_CHAMPION",
    [RAID_POINT_REASON_KILL_MINIBOSS] = "KILL_MINIBOSS",
    [RAID_POINT_REASON_KILL_NORMAL_MONSTER] = "KILL_NORMAL_MONSTER",
    [RAID_POINT_REASON_KILL_NOXP_MONSTER] = "KILL_NOXP_MONSTER",
    [RAID_POINT_REASON_LIFE_REMAINING] = "LIFE_REMAINING",
    [RAID_POINT_REASON_SOLO_ARENA_COMPLETE] = "SOLO_ARENA_COMPLETE",
    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_FOUR] = "SOLO_ARENA_PICKUP_FOUR",
    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_ONE] = "SOLO_ARENA_PICKUP_ONE",
    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_THREE] = "SOLO_ARENA_PICKUP_THREE",
    [RAID_POINT_REASON_SOLO_ARENA_PICKUP_TWO] = "SOLO_ARENA_PICKUP_TWO",
}

-- EVENT_RAID_TRIAL_SCORE_UPDATE (number eventCode, RaidPointReason scoreUpdateReason, number scoreAmount, number totalScore)
local function OnScoreUpdate(_, scoreUpdateReason, scoreAmount, totalScore)
    if (scoreUpdateReason == RAID_POINT_REASON_LIFE_REMAINING) then return end

    Spam.AddMessage(string.format("%s |cAAFFAA%d", scoreReasons[scoreUpdateReason]  or "UNKNOWN", scoreAmount))
end

---------------------------------------------------------------------
-- Register/Unregister
---------------------------------------------------------------------
function Spam.RegisterScore()
    EVENT_MANAGER:RegisterForEvent(Spam.name .. "Score", EVENT_RAID_TRIAL_SCORE_UPDATE, OnScoreUpdate)
end

function Spam.UnregisterScore()
    EVENT_MANAGER:UnregisterForEvent(Spam.name .. "Score", EVENT_RAID_TRIAL_SCORE_UPDATE)
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spam.InitializeScore()
    if (KyzderpsDerps.savedOptions.chatSpam.printScore) then
        Spam.RegisterScore()
    end
end