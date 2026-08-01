-- ============================================================================
-- Localized Globals
-- ============================================================================
local EVENT_MANAGER = EVENT_MANAGER
local QUEST_REPEAT_DAILY = QUEST_REPEAT_DAILY
local QUEST_REPEAT_REPEATABLE = QUEST_REPEAT_REPEATABLE
local CHATTER_TALK_CHOICE = CHATTER_TALK_CHOICE
local CHATTER_START_NEW_QUEST_BESTOWAL = CHATTER_START_NEW_QUEST_BESTOWAL
local CHATTER_START_TALK = CHATTER_START_TALK
local CHATTER_START_COMPLETE_QUEST = CHATTER_START_COMPLETE_QUEST
local INTERACTION_CONVERSATION = INTERACTION_CONVERSATION
local EVENT_QUEST_OFFERED = EVENT_QUEST_OFFERED
local EVENT_QUEST_COMPLETE_DIALOG = EVENT_QUEST_COMPLETE_DIALOG
local EVENT_CONVERSATION_UPDATED = EVENT_CONVERSATION_UPDATED
local EVENT_CHATTER_BEGIN = EVENT_CHATTER_BEGIN
local EVENT_CHATTER_END = EVENT_CHATTER_END
local GetUnitName = GetUnitName
local GetChatterOption = GetChatterOption
local SelectChatterOption = SelectChatterOption
local AcceptOfferedQuest = AcceptOfferedQuest
local CompleteQuest = CompleteQuest
local EndInteraction = EndInteraction
local ipairs = ipairs
local pairs = pairs
local table_insert = table.insert

local GAFE = GroupActivityFinderExtensions
local LQD = LibQuestData
local LUP = LibUndauntedPledges

-- ============================================================================
-- Constants
-- ============================================================================
-- Crafting writ quest IDs used to identify writ givers
local CRAFTING_WRIT_QUEST_ID_1 = 5394
local CRAFTING_WRIT_QUEST_ID_2 = 5415

-- ============================================================================
-- Module Declaration
-- ============================================================================
local QuestAutomation = {
  dailyNpcName = {},
  craftingWritNpcName = {}
}

-- ============================================================================
-- Private Functions
-- ============================================================================

--- Checks if a value exists in a table array.
--- @param data table The array to search
--- @param value any The value to find
--- @return boolean found True if value exists in data
local function contains(data, value)
  for _, item in ipairs(data) do
    if item == value then
      return true
    end
  end

  return false
end

--- Checks if an NPC is one of the three Undaunted pledge givers.
--- @param npcName string The NPC name to check
--- @return boolean isPledgeGiver True if the NPC is a pledge giver
local function IsPledgeGiver(npcName)
  return npcName == LUP.GetPledgeGiverName(LUP.BASE1)
      or npcName == LUP.GetPledgeGiverName(LUP.BASE2)
      or npcName == LUP.GetPledgeGiverName(LUP.DLC1)
end

--- Checks if quest ID is one of the crafting writs.
--- Only checks for one of each type. Used to get the quest giver name.
--- @param questId number The quest ID to check
--- @return boolean isCraftingWrit True if the quest is a crafting writ
local function IsCraftingWrit(questId)
  return questId == CRAFTING_WRIT_QUEST_ID_1 or
      questId == CRAFTING_WRIT_QUEST_ID_2
end

-- ============================================================================
-- Public Functions
-- ============================================================================

--- Initializes the quest automation module.
--- Populates NPC name lists from LibQuestData for daily and crafting writ quests.
function QuestAutomation.Init()
  local allZones = LibQuestData_GetAllZones()
  for _, zone in pairs(allZones) do
    for _, questPinData in ipairs(zone) do
      local questId = questPinData[LQD.quest_map_pin_index.quest_id]
      local questRepeat = LQD:get_quest_repeat(questId)

      if questRepeat == QUEST_REPEAT_DAILY or questRepeat == QUEST_REPEAT_REPEATABLE then
        local npcName = LQD:get_quest_giver(
          questPinData[LQD.quest_map_pin_index.quest_giver],
          GAFE.lang
        )
        local isCraftingWrit = IsCraftingWrit(questId)

        if isCraftingWrit and not contains(QuestAutomation.craftingWritNpcName, npcName) then
          table_insert(QuestAutomation.craftingWritNpcName, npcName)
        elseif not contains(QuestAutomation.dailyNpcName, npcName) then
          table_insert(QuestAutomation.dailyNpcName, npcName)
        end
      end
    end
  end

  QuestAutomation.AutomaticallyHandleQuests(
    GAFE.SavedVars.dungeons.handlePledgeQuest
  )
end

--- Enables or disables automatic quest acceptance and completion for daily NPCs.
--- @param enable boolean True to enable automation, false to disable
function QuestAutomation.AutomaticallyHandleQuests(enable)
  local questOfferedEventName, questOffered = GAFE.name .. "_QuestOffered", false
  local conversationUpdatedEventName = GAFE.name .. "_ConversationUpdated"
  local questCompletedEventName, questCompleted = GAFE.name .. "_QuestCompleted",
      false

  local function HandleQuestOffered()
    if questOffered then
      EVENT_MANAGER:UnregisterForEvent(questOfferedEventName, EVENT_QUEST_OFFERED)
    end

    questOffered = true
    AcceptOfferedQuest()
  end

  local function HandleQuestCompleted()
    EVENT_MANAGER:UnregisterForEvent(questCompletedEventName,
      EVENT_QUEST_COMPLETE_DIALOG)

    questCompleted = true
    CompleteQuest()
  end

  local function HandleConversationUpdated(_, conversationBodyText, optionCount)
    EVENT_MANAGER:UnregisterForEvent(conversationUpdatedEventName,
      EVENT_QUEST_OFFERED)

    if optionCount ~= 0 then
      for optionIndex = 1, optionCount + 1 do
        local optionString, optionType = GetChatterOption(optionIndex)
        if optionType == CHATTER_TALK_CHOICE then
          questCompleted = false
          EVENT_MANAGER:RegisterForEvent(
            questCompletedEventName,
            EVENT_QUEST_COMPLETE_DIALOG,
            HandleQuestCompleted
          )
          SelectChatterOption(optionIndex)
        end
      end
    end
  end

  local function HandleChatterBegin(_, optionCount, _debugSource_)
    local npcName = GetUnitName("interact")

    if questOffered or questCompleted then
      EndInteraction(INTERACTION_CONVERSATION)
    end

    if contains(QuestAutomation.dailyNpcName, npcName) and not contains(QuestAutomation.craftingWritNpcName, npcName) then
      if optionCount ~= 0 then
        for optionIndex = 1, optionCount + 1 do
          local optionString, optionType = GetChatterOption(optionIndex)

          if optionType == CHATTER_START_NEW_QUEST_BESTOWAL then
            questOffered = false
            EVENT_MANAGER:RegisterForEvent(
              questOfferedEventName,
              EVENT_QUEST_OFFERED,
              HandleQuestOffered
            )
            SelectChatterOption(optionIndex)
          elseif optionType == CHATTER_START_TALK and IsPledgeGiver(npcName) then
            -- Pledges hide EVENT_QUEST_COMPLETE_DIALOG behind one chatter start
            questCompleted = false
            EVENT_MANAGER:RegisterForEvent(
              conversationUpdatedEventName,
              EVENT_CONVERSATION_UPDATED,
              HandleConversationUpdated
            )
            SelectChatterOption(optionIndex)
          elseif optionType == CHATTER_START_COMPLETE_QUEST then
            questCompleted = false
            EVENT_MANAGER:RegisterForEvent(
              questCompletedEventName,
              EVENT_QUEST_COMPLETE_DIALOG,
              HandleQuestCompleted
            )
            SelectChatterOption(optionIndex)
          end
        end
      end
    end
  end

  local function HandleChatterEnd()
    questOffered = false
    questCompleted = false
  end

  local chatterBeginName = GAFE.name .. "_QuestAutomation_ChatterBegin"
  local chatterEndName = GAFE.name .. "_QuestAutomation_ChatterEnd"

  if enable then
    EVENT_MANAGER:RegisterForEvent(
      chatterBeginName,
      EVENT_CHATTER_BEGIN,
      HandleChatterBegin
    )
    EVENT_MANAGER:RegisterForEvent(
      chatterEndName,
      EVENT_CHATTER_END,
      HandleChatterEnd
    )
  else
    EVENT_MANAGER:UnregisterForEvent(chatterBeginName, EVENT_CHATTER_BEGIN)
    EVENT_MANAGER:UnregisterForEvent(chatterBeginName, EVENT_CHATTER_END)
    EVENT_MANAGER:UnregisterForEvent(questOfferedEventName, EVENT_QUEST_OFFERED)
    EVENT_MANAGER:UnregisterForEvent(questCompletedEventName,
      EVENT_QUEST_COMPLETE_DIALOG)
    EVENT_MANAGER:UnregisterForEvent(conversationUpdatedEventName,
      EVENT_QUEST_OFFERED)
  end

  GAFE.SavedVars.dungeons.handlePledgeQuest = enable
end

-- ============================================================================
-- Module Registration
-- ============================================================================
GAFE.QuestAutomation = QuestAutomation
