-- seige counter
-- ========================================
-- Accessor values
local Kills = 1
local KillingBlows = 2
local Avenge_Kills = 3
local Revent_Kills = 4
local Alliance = 5
local vLevel = 6
local Name = 7
local Level = 8
local Class = 9
local KilledBy = 10
-- ========================================
-- local objectiveControls = {
-- [OBJECTIVE_CONTROL_EVENT_AREA_INFLUENCE_CHANGED] = "OBJECTIVE_CONTROL_EVENT_AREA_INFLUENCE_CHANGED",
-- [OBJECTIVE_CONTROL_EVENT_AREA_NEUTRAL] = "OBJECTIVE_CONTROL_EVENT_AREA_NEUTRAL",
-- [OBJECTIVE_CONTROL_EVENT_ASSAULTED] = "OBJECTIVE_CONTROL_EVENT_ASSAULTED",
-- [OBJECTIVE_CONTROL_EVENT_CAPTURED] = "OBJECTIVE_CONTROL_EVENT_CAPTURED",
-- [OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED] = "OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED",
-- [OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED] = "OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED",
-- [OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED_BY_TIMER] = "OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED_BY_TIMER",
-- [OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED] = "OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED",
-- [OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN] = "OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN",
-- [OBJECTIVE_CONTROL_EVENT_FULLY_HELD] = "OBJECTIVE_CONTROL_EVENT_FULLY_HELD",
-- [OBJECTIVE_CONTROL_EVENT_LOST] = "OBJECTIVE_CONTROL_EVENT_LOST",
-- [OBJECTIVE_CONTROL_EVENT_NONE] = "OBJECTIVE_CONTROL_EVENT_NONE",
-- [OBJECTIVE_CONTROL_EVENT_RECAPTURED] = "OBJECTIVE_CONTROL_EVENT_RECAPTURED",
--    [OBJECTIVE_CONTROL_EVENT_UNDER_ATTACK] = "OBJECTIVE_CONTROL_EVENT_UNDER_ATTACK"
-- }

-- local keepTypes = {
--    [KEEPTYPE_ARTIFACT_GATE] = "KEEPTYPE_ARTIFACT_GATE",
--    [KEEPTYPE_ARTIFACT_KEEP] = "KEEPTYPE_ARTIFACT_KEEP",
--    [KEEPTYPE_BORDER_KEEP] = "KEEPTYPE_BORDER_KEEP",
--    [KEEPTYPE_IMPERIAL_CITY_DISTRICT] = "KEEPTYPE_IMPERIAL_CITY_DISTRICT",
--    [KEEPTYPE_KEEP] = "KEEPTYPE_KEEP",
--    [KEEPTYPE_OUTPOST] = "KEEPTYPE_OUTPOST",
--    [KEEPTYPE_RESOURCE] = "KEEPTYPE_RESOURCE", 
--    [KEEPTYPE_TOWN] = "KEEPTYPE_TOWN" 
-- }
-- local objectiveTypes = {
--    [OBJECTIVE_ARTIFACT_DEFENSIVE] = "OBJECTIVE_ARTIFACT_DEFENSIVE",
--    [OBJECTIVE_ARTIFACT_OFFENSIVE] = "OBJECTIVE_ARTIFACT_OFFENSIVE",
--    [OBJECTIVE_ARTIFACT_RETURN] = "OBJECTIVE_ARTIFACT_RETURN",
--    [OBJECTIVE_ASSAULT] = "OBJECTIVE_ASSAULT",
--    [OBJECTIVE_BALL] = "OBJECTIVE_BALL",
--    [OBJECTIVE_CAPTURE_AREA] = "OBJECTIVE_CAPTURE_AREA",
--    [OBJECTIVE_CAPTURE_POINT] = "OBJECTIVE_CAPTURE_POINT",
--    [OBJECTIVE_FLAG_CAPTURE] = "OBJECTIVE_FLAG_CAPTURE",
--    [OBJECTIVE_NONE] = "OBJECTIVE_NONE",
--    [OBJECTIVE_RETURN] = "OBJECTIVE_RETURN"
-- }

SC_G = {}
local shouldTrack = false
local takingKeep = false
local keepTakenByMe = false
local lastKeepFlag = ""

local keepCaptures = 0
local resourceCaptures = 0
local keepStreak = 0
local resourceStreak = 0
local showSeige = true

function SC_G.ResetCurrentObjectiveStreaks() resourceStreak, keepStreak = 0, 0 end

local seigeAlertColor = "|CA15406"
local captureAlertColor = "|C7685A3"

kStreakArray = {}
rStreakArray = {}

function SC_G.GetKCaps() return keepCaptures end
function SC_G.GetRCaps() return resourceCaptures end
function SC_G.GetKStreak() return keepStreak end
function SC_G.GetRStreak() return resourceStreak end

-- EVENT_KEEP_ALLIANCE_OWNER_CHANGED (number eventCode, number keepId, number battlegroundContext, number Alliance owningAlliance, number Alliance oldOwningAlliance)
function SC_G.KeepOwnerChanged(_, keepId, bgContext, newOwner, oldOwner)
    local myLocation, keepName = (GetPlayerLocationName()),
                                 (GetKeepName(keepId))

    if myLocation == keepName and newOwner == GetUnitAlliance('player') then
        if KC_Fn.CheckSetting("ChatCaptures") then
            df("|C7685A3You have captured|r %s", keepName)
        end
        local keepType = GetKeepType(keepId)
        if keepType == KEEPTYPE_KEEP then
            SC_G.addKeepCapture()
        elseif keepType == KEEPTYPE_RESOURCE then
            SC_G.addResourceCapture()
        end
        -- else
        --    df("|CA15406(%d) %s captured by %s from %s!|r", bgContext, keepName,
        -- 	 GetAllianceName(newOwner), GetAllianceName(oldOwner))
    end
end

--[[
   |-----------------------+--------------------------------------------------------------|
   | Parameter             | Description                                                  |
   |-----------------------+--------------------------------------------------------------|
   | objectiveKeepId       | The id of the main keep or resource                          |
   | objectiveObjectiveId  | (possibly just the id of the flag/objective)                 |
   | battlegroundContext   | Something to do with the current campaign (guest/home)       |
   | objectiveName         | The name of the objective being taken                        |
   | objectiveType         | The important value here is OBJECTIVE_FLAG_CAPTURE           |
   | objectiveControlEvent | The control change type OBJECTIVE_CONTROL_EVENT_CAPTURED     |
   |                       | is the only one we really care about here (50% flag capture) |
   | objectiveControlState | not sure, unused by me                                       |
   |-----------------------+--------------------------------------------------------------|
   | objectiveParam1       | These two are a little strange, the value of                 |
   | objectiveParam2       | objectiveControlEvent determines whether or not each or      |
   |                       | either of these is set. For OBJECTIVE_CONTROL_EVENT_CAPTURED |
   |                       | objectiveParam1 is the capturing alliance id, and param2     |
   |                       | is set to 0 (Alliance "None")                                |
   |-----------------------+--------------------------------------------------------------|
--]]
function SC_G.ObjectiveControlState(eventId, objectiveKeepId,
                                    objectiveObjectiveId, battlegroundContext,
                                    objectiveName, objectiveType,
                                    objectiveControlEvent,
                                    objectiveControlState, objectiveParam1,
                                    objectiveParam2)
    if not IsPlayerInAvAWorld() then return end

    local eventCaptureTypes = {
        --[[
	 
      --]]
        [OBJECTIVE_CONTROL_EVENT_CAPTURED] = true,
        [OBJECTIVE_CONTROL_EVENT_RECAPTURED] = true
    }

    if eventCaptureTypes[objectiveControlEvent] then
        -- d("keep captured")

        -- d(objectiveName,battlegroundContext, objectiveType, , )
        local keepname = GetKeepName(objectiveKeepId)
        local keepType = GetKeepType(objectiveKeepId)
        -- local kkkk = GetKeepName(-5000)
        -- d(keepname)
        if keepType ~= KEEPTYPE_IMPERIAL_CITY_DISTRICT then
            if KC_Fn.CheckSetting("ChatSeiges") then
                d(seigeAlertColor .. objectiveName .. " has been Taken by " ..
                      KC_Fn.Alliance_From_Id(objectiveParam1, true))
            end
        else
            if KC_Fn.CheckSetting("ImperialDistrictFlags") then
                d(seigeAlertColor .. objectiveName .. " has been Taken by " ..
                      KC_Fn.Alliance_From_Id(objectiveParam1, true))
            end
        end
    end
end

function SC_G.CaptureAreaStatus(self, keepId, objectiveId, battlegroundContext,
                                curValue, maxValue, currentCapturePlayers,
                                alliance1, alliance2)
    if not IsPlayerInAvAWorld() then return end
    -- d(curValue .. " " .. maxValue)
    if curValue == maxValue and alliance1 == GetUnitAlliance("player") then
        -- d("capture status")
        -- d(keepId, objectiveId, battlegroundContext, curValue, maxValue, currentCapturePlayers, alliance1, alliance2)
        if shouldTrack then
            local keepname = GetKeepName(keepId)
            local objectivename = GetAvAObjectiveInfo(keepId, objectiveId,
                                                      battlegroundContext)

            -- d("You have taken " .. on .. " at " .. kn)

            local pieces = KC_Fn.string_split(objectivename)
            -- d(pieces)
            if pieces ~= nil then
                -- get last item
                local last = pieces[#pieces]
                -- d(last)
                if last == "Nave" or last == "Apse" or last == "Tower" or last ==
                    "Courtyard" then
                    -- lkf=on because above event happens before this one.
                    keepname = zo_strformat("<<1>>", keepname)
                    objectivename = zo_strformat("<<1>>", objectivename)
                    if not takingKeep or lastKeepFlag == objectivename then
                        takingKeep = true
                        lastKeepFlag = objectivename
                        if KC_Fn.CheckSetting("ChatCaptures") then
                            -- d("1/2 flags for " .. keepname .. " taken.")
                        end
                        keepTakenByMe = true
                    else
                        local resetLast = false
                        -- we are taking a keep. compare peices of last to peices of first
                        local lastpieces = KC_Fn.string_split(lastKeepFlag)
                        if #lastpieces ~= #pieces then
                            -- not even the same size. abandon ship!
                            resetLast = true
                        else
                            -- compare the first n-1 things. they should be the same
                            for j = 1, #lastpieces - 1 do
                                if lastpieces[j] ~= pieces[j] then
                                    resetLast = true
                                    break
                                end
                            end

                            -- this shouldnt happen, because if they are equal, the above if should be true, but just in case 
                            if lastpieces[#lastpieces] == pieces[#pieces] then
                                resetLast = true
                            end

                        end
                        -- now we know whether or not resetLast is true
                        if resetLast then
                            -- this was a diffent keep. treat it like a normal one
                            takingKeep = true -- just in case
                            lastKeepFlag = objectivename
                            keepTakenByMe = true
                        else
                            -- We have captured the keep!
                            if KC_Fn.CheckSetting("ChatCaptures") then
                                d(captureAlertColor .. "You have captured " ..
                                      keepname)
                            end
                            -- do keep capture processing
                            SC_G.addKeepCapture()
                        end
                    end
                else
                    -- this is a normal resource
                    if KC_Fn.CheckSetting("ChatCaptures") then
                        d(captureAlertColor .. "You have captured the " ..
                              keepname .. ".")
                    end
                    -- do resource processing
                    resourceCaptures = resourceCaptures + 1
                    resourceStreak = resourceStreak + 1
                    KC_G.savedVars.SC.resourcesCaptured =
                        KC_G.savedVars.SC.resourcesCaptured + 1
                    SC_G.doRStreak()
                    lastKeepFlag = ""
                end
            end

            shouldTrack = false
        end
    else
        shouldTrack = true
    end

end

function SC_G.addKeepCapture()
    keepCaptures = keepCaptures + 1
    keepStreak = keepStreak + 1
    KC_G.savedVars.SC.keepsCaptured = KC_G.savedVars.SC.keepsCaptured + 1
    SC_G.doKStreak()
end

function SC_G.addResourceCapture()
    resourceCaptures = resourceCaptures + 1
    resourceStreak = resourceStreak + 1
    KC_G.savedVars.SC.resourcesCaptured =
        KC_G.savedVars.SC.resourcesCaptured + 1
    SC_G.doRStreak()
end

function SC_G.slashCommands()
    SLASH_COMMANDS["/sc"] = function(extra)
        if string.lower(extra) == "stats" then
            d("Keep Captures: " .. keepCaptures,
              "Resource Captures: " .. resourceCaptures,
              "Keep Captures Streak: " .. keepStreak,
              "Resource Captures Streak: " .. resourceStreak,
              "Total Keep Captures: " .. KC_G.savedVars.SC.keepsCaptured,
              "Total Resource Captures: " .. KC_G.savedVars.SC.resourcesCaptured,
              "Longest Keep Streak: " .. KC_G.savedVars.SC.longestKeepStreak,
              "Longest Resource Streak: " ..
                  KC_G.savedVars.SC.longestResourceStreak)
        end
        if string.lower(extra) == "showcaps" then showSeige = true end
        if string.lower(extra) == "hidecaps" then showSeige = false end
    end
end

function SC_G.doKStreak()
    if keepStreak > KC_G.savedVars.SC.longestKeepStreak then
        if KC_Fn.CheckSetting("ChatCapStreak") then
            d("New Keep Capture Streak Record!")
        end
        KC_G.savedVars.SC.longestKeepStreak = keepStreak
    end

    if kStreakArray[keepStreak] ~= nil then
        if KC_Fn.CheckSetting("ChatCapStreak") then
            d(kStreakArray[keepStreak] .. " (" .. keepStreak .. " Keeps)")
        end

        -- if keepStreak < 5 then
        -- 	 --play sounds
        -- elseif keepStreak <= 50 then
        -- 	 --play sounds
        -- end
        return true
    end
    return false
end

function SC_G.doRStreak()
    if resourceStreak > KC_G.savedVars.SC.longestResourceStreak then
        if KC_Fn.CheckSetting("ChatCapStreak") then
            d("New Resource Capture Streak Record!")
        end
        KC_G.savedVars.SC.longestResourceStreak = resourceStreak
    end

    if rStreakArray[resourceStreak] ~= nil then
        if KC_Fn.CheckSetting("ChatCapStreak") then
            d(rStreakArray[resourceStreak] .. " (" .. resourceStreak ..
                  " Resources)")
        end

        return true
    end
    return false
end

function SC_G.initStreak()

    -- kill streaks
    kStreakArray[2] = "Vanquisher!"
    kStreakArray[3] = "Subjugator!"
    kStreakArray[4] = "Usurper"
    kStreakArray[5] = "Conqueror!"
    kStreakArray[6] = "King Maker!"
    kStreakArray[7] = "Holy Crusader!"
    kStreakArray[8] = "Agent of Akatosh!"

    rStreakArray[2] = "Outlaw!"
    rStreakArray[3] = "Raider!"
    rStreakArray[6] = "Pillager!"
    rStreakArray[9] = "Marauder!"
    rStreakArray[12] = "Plunderer!"
    rStreakArray[18] = "Ravager!"
    rStreakArray[24] = "Viking King!"
    rStreakArray[25] = "Telel, is that you?"
end

function SC_G.resetStreaks()
    KC_G.savedVars.SC.keepStreak = 0
    KC_G.savedVars.SC.resourceStreak = 0
end

function SC_G.ResetSeigeStats()
    SC_G.resetStreaks()
    KC_G.savedVars.SC = KC_Fn.table_shallow_copy(KC_G.svDefaults.SC)
end
-- control stat fires before capture area status, but capstatus only happens when you are there.

---objective types in OBJECTIVE section of zgoo under other CONSTS
-- I think i'm interested in OBJECTIVE_ARTIFACT_OFFENSIVE, OBJECTIVE_CAPTURE_AREA,
-- seems for keeps, they  split into two flags, Aspe and Nave yep definitely
-- towe keeps like bleakers go Tower and Courtyard
--[[
   ["SC"] = {
   keepsCaptured = 0,
   resourcesCaptured = 0,
   longestKeepStreak = 0,
   longestResourceStreak = 0

   }
--]]
