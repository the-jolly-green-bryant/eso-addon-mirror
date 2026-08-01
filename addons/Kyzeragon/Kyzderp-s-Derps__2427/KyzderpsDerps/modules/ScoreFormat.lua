KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.ScoreFormat = KyzderpsDerps.ScoreFormat or {}
local ScoreFormat = KyzderpsDerps.ScoreFormat

---------------------------------------------------------------------
-- Upon completion of a leaderboard instance, outputs a string that
-- can be easily copied to paste in Discord
---------------------------------------------------------------------

local TRIALS_DICTIONARY = {
    ["Hel Ra Citadel"] = "vHRC",
    ["Aetherian Archive"] = "vAA",
    ["Sanctum Ophidia"] = "vSO",
    ["Dragonstar Arena"] = "vDSA",
    ["Maw of Lorkhaj"] = "vMoL",
    ["Maelstrom Arena"] = "vMA",
    ["Halls of Fabrication"] = "vHoF HM",
    ["Asylum Sanctorium"] = "vAS",
    ["Cloudrest"] = "vCR",
    ["Blackrose Prison"] = "vBRP",
    ["Sunspire"] = "vSS",
    ["Kyne's Aegis"] = "vKA",
    ["Vateshran Hollows"] = "vVH",
    ["Rockgrove"] = "vRG",
    ["Dreadsail Reef"] = "vDSR",
    ["Sanity's Edge"] = "vSE",
    ["Endless Archive"] = "EA",
    ["Infinite Archive"] = "IA",
    ["Lucent Citadel"] = "vLC",
    ["Ossein Cage"] = "vOC",
}

local MONTHS_DICTIONARY = {
    ["1"] = "January",
    ["2"] = "February",
    ["3"] = "March",
    ["4"] = "April",
    ["5"] = "May",
    ["6"] = "June",
    ["7"] = "July",
    ["8"] = "August",
    ["9"] = "September",
    ["10"] = "October",
    ["11"] = "November",
    ["12"] = "December",
}

---------------------------------------------------------------------
-- Keep track of vitality because for some reason, the completion
-- event doesn't provide that...
---------------------------------------------------------------------
local maxVitality = 0
local vitality = 0

-- EVENT_RAID_TRIAL_STARTED (number eventCode, string trialName, boolean weekly)
local function OnTrialStarted()
    vitality = GetRaidReviveCountersRemaining()
    maxVitality = GetCurrentRaidStartingReviveCounters()
end

-- EVENT_RAID_REVIVE_COUNTER_UPDATE (number eventCode, number currentCounter, number countDelta)
local function OnVitalityChanged(_, currentCounter, countDelta)
    vitality = currentCounter
    maxVitality = GetCurrentRaidStartingReviveCounters()
end

---------------------------------------------------------------------
local function BuildGroupRoles()

    local isInGroup = GetGroupSize() > 1

    if not isInGroup then
        return ""
    end

    local tanks = ""
    local healers = ""
    local dps = ""
    local unknown = ""

    for i = 1, GetGroupSize() do

        local unitTag = GetGroupUnitTagByIndex(i)
        local member = string.gsub(GetUnitDisplayName(unitTag), "@", "")
        local role = GetGroupMemberSelectedRole(unitTag)

        if (role == LFG_ROLE_TANK) then
            tanks = tanks .. " " .. member
        elseif (role == LFG_ROLE_HEAL) then
            healers = healers .. " " .. member
        elseif (role == LFG_ROLE_DPS) then
            dps = dps .. " " .. member
        else
            unknown = unknown .. " " .. member
        end
    end

    local result = ""
    if (tanks ~= "") then result = result .. "Tanks:" .. tanks .. " | " end
    if (healers ~= "") then result = result .. "Healers:" .. healers .. " | " end
    if (dps ~= "") then result = result .. "Dps:" .. dps .. " | " end
    if (unknown ~= "") then result = result .. "UNKNOWN:" .. unknown .. " | " end

    return string.gsub(result, " %| $", "")
end

local function BuildScoreFormat(trialName, score, totalSeconds, vitality, maxVitality)
    local abbreviation = TRIALS_DICTIONARY[string.gsub(trialName, " %(Veteran%)", "")]
    if (not abbreviation) then
        abbreviation = "???" -- Other languages, or if I forget to update the dict on updates oops
    end
    local result = "__**" .. abbreviation .. "**__\n"

    -- score
    result = result .. "**" .. tostring(score) .. " - "

    -- time
    local time = string.format("%d:%02d:%02d",
        math.floor(totalSeconds / 3600),
        math.floor(totalSeconds / 60) % 60,
        totalSeconds % 60)
    result = result .. string.gsub(time, "^[0:]+", "") .. " - "

    -- vitality
    result = result .. ":vitality: " .. tostring(vitality) .. "/" .. tostring(maxVitality) .. "**\n"

    -- date
    local _, _, mon, day, year = string.find(GetDateStringFromTimestamp(GetTimeStamp()), "(%d+)/(%d+)/(%d+)")
    if (MONTHS_DICTIONARY[mon]) then
        result = result .. MONTHS_DICTIONARY[mon] .. " " .. day .. ", " .. year .. " - \n"
    else
        result = result .. "??? (date formats vary in other languages) - \n"
    end

    -- group members
    result = result .. BuildGroupRoles()

    return result
end

-- EVENT_RAID_TRIAL_COMPLETE (number eventCode, string trialName, number score, number totalTime)
local function OnTrialComplete(_, trialName, score, totalTime)
    local kyzFormat = BuildScoreFormat(trialName, score, totalTime / 1000, vitality, maxVitality)

    vitality = 0
    maxVitality = 0

    CHAT_ROUTER:AddSystemMessage(kyzFormat)
    -- And also log it again 15 seconds later because it gets buried in muh loot spying
    EVENT_MANAGER:RegisterForUpdate("KyzFormat", 15000, function()
        CHAT_ROUTER:AddSystemMessage(kyzFormat)
        if (KyzderpsDerps.savedOptions.misc.startChatScoreFormat and KEYBOARD_CHAT_SYSTEM) then
            KEYBOARD_CHAT_SYSTEM:StartTextEntry(kyzFormat, CHAT_CHANNEL_PARTY)
        end
        EVENT_MANAGER:UnregisterForUpdate("KyzFormat")
    end)
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function ScoreFormat.Initialize()
    if (KyzderpsDerps.savedOptions.misc.printScoreFormat) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ScoreFormatTrialComplete", EVENT_RAID_TRIAL_COMPLETE, OnTrialComplete)
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ScoreFormatTrialStart", EVENT_RAID_TRIAL_STARTED, OnTrialStarted)
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ScoreFormatTrialVitalityChange", EVENT_RAID_REVIVE_COUNTER_UPDATE, OnVitalityChanged)

        local raidId = GetCurrentParticipatingRaidId()
        if (raidId ~= nil and raidId ~= 0) then
            OnTrialStarted()
        end
    else
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "ScoreFormatTrialComplete", EVENT_RAID_TRIAL_COMPLETE)
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "ScoreFormatTrialStart", EVENT_RAID_TRIAL_STARTED)
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "ScoreFormatTrialVitalityChange", EVENT_RAID_REVIVE_COUNTER_UPDATE)
    end
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function ScoreFormat.GetSettings()
    return {
        {
            type = "checkbox",
            name = "Print formatted score",
            tooltip = "Upon completion of leaderboard content such as a veteran trial, prints text that lists the name, score, time, vitality, date, and group members formatted for copy pasting to Discord (use in conjunction with an addon like pChat to copy). Also prints it again 15 seconds later in case it gets buried in other chat spam like loot spying",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.misc.printScoreFormat end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.misc.printScoreFormat = value
                ScoreFormat.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "    Start formatted score chat entry",
            tooltip = "Also starts a chat entry (as if you are typing it) with the formatted score, for even easier copying. This happens at the same time as the 15-second late print",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.misc.startChatScoreFormat end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.misc.startChatScoreFormat = value
                ScoreFormat.Initialize()
            end,
            disabled = function() return not KyzderpsDerps.savedOptions.misc.printScoreFormat end,
            width = "full",
        }
    }
end
