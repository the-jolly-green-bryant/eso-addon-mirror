CompassHide = {}

local ADDON_NAME          = "CompassHide"
local QUEST_POLL_INTERVAL = 500   -- milliseconds

-- Committed positions from the last completed poll cycle (global coords).
local cachedGoals  = {}    -- array of {gx, gy, radiusM}
local shouldHide   = false
local wasHiding    = false

-- Per-cycle state: accumulates responses until all tasks complete.
local cycleId      = 0
local cyclePending = 0
local cycleGoals   = {}
local taskCycle    = {}    -- taskId -> cycleId it belongs to
local taskAssisted = {}    -- taskId -> true if from the focused quest

local function GetFocusedQuestIndex()
    local questObj = FOCUSED_QUEST_TRACKER:GetLastTracked()
    if questObj then
        return questObj:GetJournalIndex() or 0
    end
    return 0
end

local function OnQuestPositionRequestComplete(event, taskId, pinType, xLoc, yLoc, areaRadius, insideCurrentMapWorld, isBreadcrumb)
    if taskCycle[taskId] ~= cycleId then return end
    local isAssisted = taskAssisted[taskId]
    taskCycle[taskId]    = nil
    taskAssisted[taskId] = nil
    cyclePending = cyclePending - 1

    -- Only include real (non-breadcrumb) goals of the focused quest.
    if isAssisted and not isBreadcrumb and (xLoc ~= 0 or yLoc ~= 0) then
        local gx, gy = LibGPS3:LocalToGlobal(xLoc, yLoc)
        if gx then
            local radiusM = 0
            if areaRadius and areaRadius > 0 then
                local rx, ry = LibGPS3:LocalToGlobal(xLoc + areaRadius, yLoc)
                if rx then
                    radiusM = LibGPS3:GetGlobalDistanceInMeters(gx, gy, rx, gy) or 0
                end
            end
            cycleGoals[#cycleGoals + 1] = { gx = gx, gy = gy, radiusM = radiusM }
        end
    end

    if cyclePending == 0 then
        cachedGoals = cycleGoals
    end
end

local function RequestAllQuestPositions()
    SetMapToPlayerLocation()

    cycleId      = cycleId + 1
    cyclePending = 0
    cycleGoals   = {}

    local trackedIdx = GetFocusedQuestIndex()
    local trackedGoalCount = 0

    for i = 1, MAX_JOURNAL_QUESTS do
        if GetJournalQuestName(i) ~= "" then
            local isAssisted = (i == trackedIdx)
            local numSteps = GetJournalQuestNumSteps(i)
            for s = 1, numSteps do
                local numConditions = GetJournalQuestNumConditions(i, s)
                for c = 1, numConditions do
                    if DoesJournalQuestConditionHavePosition(i, s, c) then
                        local _, _, _, _, isComplete = GetJournalQuestConditionInfo(i, s, c)
                        if isAssisted or not isComplete then
                            local taskId = RequestJournalQuestConditionAssistance(i, s, c)
                            taskCycle[taskId]    = cycleId
                            taskAssisted[taskId] = isAssisted
                            cyclePending = cyclePending + 1
                            if isAssisted then trackedGoalCount = trackedGoalCount + 1 end
                        end
                    end
                end
            end
        end
    end

    -- Fallback for quests whose ending step reports 0 conditions (e.g. "Talk to NPC").
    -- Force-request condition (numSteps, 1) — the position may still be available
    -- even when GetJournalQuestNumConditions returns 0.
    if trackedIdx > 0 and trackedGoalCount == 0 then
        local numSteps = GetJournalQuestNumSteps(trackedIdx)
        local taskId = RequestJournalQuestConditionAssistance(trackedIdx, math.max(1, numSteps), 1)
        if taskId then
            taskCycle[taskId]    = cycleId
            taskAssisted[taskId] = true
            cyclePending = cyclePending + 1
        end
    end

    if cyclePending == 0 then
        cachedGoals = {}
    end
end

-- Called every frame: uses LibGPS3 to compute accurate distances in metres.
local function OnUpdate()
    if not CompassHide.savedVars.enabled or #cachedGoals == 0 or not LibGPS3:IsReady() then
        shouldHide = false
    else
        SetMapToPlayerLocation()
        local px, py = GetMapPlayerPosition("player")
        if px ~= 0 or py ~= 0 then
            local pgx, pgy = LibGPS3:LocalToGlobal(px, py)
            if pgx then
                local minDist = math.huge
                for _, goal in ipairs(cachedGoals) do
                    local rawDist = LibGPS3:GetGlobalDistanceInMeters(pgx, pgy, goal.gx, goal.gy)
                    if rawDist then
                        local distToEdge = math.max(0, rawDist - goal.radiusM)
                        if distToEdge < minDist then
                            minDist = distToEdge
                        end
                    end
                end
                if minDist < math.huge then
                    shouldHide = minDist < CompassHide.savedVars.threshold
                end
            end
        end
    end

    if shouldHide and not wasHiding then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Compass was hidden: a quest goal is nearby")
    end
    wasHiding = shouldHide

    local inHud = SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
    if shouldHide and inHud then
        ZO_CompassFrame:SetHidden(true)
    elseif not shouldHide and inHud then
        ZO_CompassFrame:SetHidden(false)
    end
end

-- Called every 500ms: issues async position requests for all quest conditions.
local function QuestPollLoop()
    local scene = SCENE_MANAGER:GetCurrentSceneName()
    if scene == "hud" or scene == "hudui" then
        RequestAllQuestPositions()
    end
    zo_callLater(QuestPollLoop, QUEST_POLL_INTERVAL)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    local defaults = {
        enabled   = true,
        threshold = 100,  -- metres
    }

    CompassHide.savedVars = ZO_SavedVars:NewAccountWide(
        "CompassHide_SavedVars", 2, GetWorldName(), defaults, nil, nil
    )

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_POSITION_REQUEST_COMPLETE, OnQuestPositionRequestComplete)
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME, 0, OnUpdate)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function() cachedGoals = {} end)

    -- Re-apply hiding when Alt is pressed (hudui scene becomes active).
    local hudUiScene = SCENE_MANAGER:GetScene("hudui")
    if hudUiScene then
        hudUiScene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING and shouldHide then
                ZO_CompassFrame:SetHidden(true)
            end
        end)
    end

    SLASH_COMMANDS["/compasshide"] = function(args)
        local value = tonumber(args)
        if value then
            CompassHide.savedVars.threshold = value
            d("CompassHide: threshold set to " .. value .. " m")
        else
            CompassHide.savedVars.enabled = not CompassHide.savedVars.enabled
            if CompassHide.savedVars.enabled then
                d("Compass is hidden near quest goals (threshold: " .. CompassHide.savedVars.threshold .. " m)")
            else
                d("Compass always visible")
            end
        end
    end

    QuestPollLoop()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
