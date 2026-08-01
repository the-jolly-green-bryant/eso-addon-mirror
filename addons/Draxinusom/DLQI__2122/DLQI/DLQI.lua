DLQI = {}

DLQI.name = "DLQI"

function DLQI.SwitchQuest(questIndex)
  local currentQuestIndex = FOCUSED_QUEST_TRACKER:GetLastTracked().arg1
  if questIndex ~= currentQuestIndex then
    local pre = FOCUSED_QUEST_TRACKER.disableAudio
    FOCUSED_QUEST_TRACKER.disableAudio = true
    FOCUSED_QUEST_TRACKER:BeginTracking(TRACK_TYPE_QUEST, questIndex)
    FOCUSED_QUEST_TRACKER.disableAudio = pre
  end
end

function DLQI.OnAddonEventQuestAdvanced(...)
  DLQI.SwitchQuest(select(2, ...))
end

function DLQI.OnAddonEventQuestCounterAdvanced(...)
  DLQI.SwitchQuest(select(2, ...))
end

function DLQI.OnAddonLoaded(event, addonName)
  if addonName == DLQI.name then
    EVENT_MANAGER:RegisterForEvent(DLQI.name, EVENT_QUEST_ADVANCED, DLQI.OnAddonEventQuestAdvanced)
    EVENT_MANAGER:RegisterForEvent(DLQI.name, EVENT_QUEST_CONDITION_COUNTER_CHANGED, DLQI.OnAddonEventQuestCounterAdvanced)
  end
end

EVENT_MANAGER:RegisterForEvent(DLQI.name, EVENT_ADD_ON_LOADED, DLQI.OnAddonLoaded)