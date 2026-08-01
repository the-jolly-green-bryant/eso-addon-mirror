QUEST_ACCEPT_AND_TURN_IN = {}

local systemName = "Quest Auto Accept and Turn In"

function QUEST_ACCEPT_AND_TURN_IN.GetName() return systemName end

local function GetStatus()
    local activeStatus = MAIN.characterVariables.skipDialogue
    if activeStatus == true then
        d("Quest auto-accept is active.")
        d("Quest auto-turn in is active.")
    elseif activeStatus == false then
        d("Quest auto-accept is inactive.")
        d("Quest auto-turn in is inactive.")
    else
        d("WARNING - unkown status for "..systemName..": "..activeStatus)
        SOUNDS.PlayError()
    end
end

function QUEST_ACCEPT_AND_TURN_IN.OnDialogueSkipUpdate()
    if MAIN.characterVariables.skipDialogue == true then
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_ACTIVE_QUEST_TOOL_CHANGED, function(eventCode, journalIndex, toolIndex) d("EVENT_ACTIVE_QUEST_TOOL_CHANGED") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_ACTIVE_QUEST_TOOL_CLEARED, function(eventCode) d("EVENT_ACTIVE_QUEST_TOOL_CLEARED") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_HIDE_OBJECTIVE_STATUS, function(eventCode) d("EVENT_HIDE_OBJECTIVE_STATUS") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_MOUSE_REQUEST_ABANDON_QUEST, function(eventCode, journalIndex, name) d("EVENT_MOUSE_REQUEST_ABANDON_QUEST") end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_ADDED, function(eventCode, journalIndex, questName, objectiveName)
            d("EVENT_QUEST_ADDED")
            d(journalIndex..": "..questName)
        end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_ADVANCED, function(eventCode, journalIndex, questName, isPushed, isComplete, mainStepChanged) d("EVENT_QUEST_ADVANCED") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_COMPLETE, function(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType) d("EVENT_QUEST_COMPLETE") end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL, function(eventCode) d("EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL") end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_COMPLETE_DIALOG, function(eventCode, journalIndex) CompleteQuest() end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_CONDITION_COUNTER_CHANGED, function(eventCode, journalIndex, questName, conditionText, conditionType, currConditionVal, newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, isComplete, isConditionComplete, isStepHidden, isConditionCompleteStatusChanged, isConditionCompletableBySiblingStatusChanged) d("EVENT_QUEST_CONDITION_COUNTER_CHANGED") end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_LIST_UPDATED, function(eventCode) d("EVENT_QUEST_LIST_UPDATED") end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_LOG_IS_FULL, function(eventCode) d("EVENT_QUEST_LOG_IS_FULL") end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_OFFERED, function(eventCode) d("EVENT_QUEST_OFFERED") AcceptOfferedQuest() end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_OPTIONAL_STEP_ADVANCED, function(eventCode, text) d("EVENT_QUEST_OPTIONAL_STEP_ADVANCED") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_POSITION_REQUEST_COMPLETE, function(eventCode, taskId, pinType, xLoc, yLoc, areaRadius, insideCurrentMapWorld, isBreadcrumb) d("EVENT_QUEST_POSITION_REQUEST_COMPLETE") end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_REMOVED, function(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID) d("EVENT_QUEST_REMOVED") end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_SHARED, function(eventCode, questId) d("EVENT_QUEST_SHARED") end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_SHARE_REMOVED, function(eventCode, questId) d("EVENT_QUEST_SHARE_REMOVED") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_SHARE_RESULT, function(eventCode, shareTargetCharacterName, shareTargetDisplayName, questName, result) d("EVENT_QUEST_SHARE_RESULT") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_SHOW_JOURNAL_ENTRY, function(eventCode, journalIndex) d("EVENT_QUEST_SHOW_JOURNAL_ENTRY") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_TIMER_PAUSED, function(eventCode, journalIndex, isPaused) d("EVENT_QUEST_TIMER_PAUSED") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_TIMER_UPDATED, function(eventCode, journalIndex) d("EVENT_QUEST_TIMER_UPDATED") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_TOOL_UPDATED, function(eventCode, journalIndex, questName, countDelta, iconFilename, questItemId, name) d("EVENT_QUEST_TOOL_UPDATED") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_OBJECTIVES_UPDATED, function(eventCode) d("EVENT_OBJECTIVES_UPDATED") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_OBJECTIVE_COMPLETED, function(eventCode, zoneIndex, poiIndex, level, previousExperience, currentExperience, championPoints) d("EVENT_OBJECTIVE_COMPLETED") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_OBJECTIVE_CONTROL_STATE, function(eventCode, objectiveKeepId, objectiveObjectiveId, battlegroundContext, objectiveName, objectiveType, objectiveControlEvent, objectiveControlState, objectiveParam1, objectiveParam2, pinType) d("EVENT_OBJECTIVE_CONTROL_STATE") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_SCRIPTED_WORLD_EVENT_INVITE, function(eventCode, eventId, scriptedEventName, inviterName, questName) d("EVENT_SCRIPTED_WORLD_EVENT_INVITE") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_SCRIPTED_WORLD_EVENT_INVITE_REMOVED, function(eventCode, eventId) d("EVENT_SCRIPTED_WORLD_EVENT_INVITE_REMOVED") end)
        --EVENT_MANAGER:RegisterForEvent(systemName, EVENT_TRACKING_UPDATE, function(eventCode) d("EVENT_TRACKING_UPDATE") end)
        EVENT_MANAGER:RegisterForEvent(systemName, EVENT_ACCEPT_SHARED_QUEST_RESPONSE, function(eventCode) d("EVENT_ACCEPT_SHARED_QUEST_RESPONSE") end)
    else
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_ACTIVE_QUEST_TOOL_CHANGED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_ACTIVE_QUEST_TOOL_CLEARED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_HIDE_OBJECTIVE_STATUS)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_MOUSE_REQUEST_ABANDON_QUEST)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_ADDED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_ADVANCED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_COMPLETE)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_COMPLETE_DIALOG)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_CONDITION_COUNTER_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_LIST_UPDATED)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_LOG_IS_FULL)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_OFFERED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_OPTIONAL_STEP_ADVANCED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_POSITION_REQUEST_COMPLETE)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_REMOVED)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_SHARED)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_SHARE_REMOVED)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_SHARE_RESULT)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_SHOW_JOURNAL_ENTRY)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_TIMER_PAUSED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_TIMER_UPDATED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_QUEST_TOOL_UPDATED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_OBJECTIVES_UPDATED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_OBJECTIVE_COMPLETED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_OBJECTIVE_CONTROL_STATE)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_SCRIPTED_WORLD_EVENT_INVITE)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_SCRIPTED_WORLD_EVENT_INVITE_REMOVED)
        --EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_TRACKING_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_ACCEPT_SHARED_QUEST_RESPONSE)
    end
    GetStatus()
end

DIALOGUE_SKIPPER.AddToUpdateSystemsList(QUEST_ACCEPT_AND_TURN_IN)