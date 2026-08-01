-- =============================================================================
-- Localized Globals
-- =============================================================================
local GetCurrentCharacterId = GetCurrentCharacterId
local GetJournalQuestInfo = GetJournalQuestInfo
local pairs = pairs

local GAFE = GroupActivityFinderExtensions
local LQD = LibQuestData
local LUP = LibUndauntedPledges

-- =============================================================================
-- Constants
-- =============================================================================
local MAX_JOURNAL_QUESTS = MAX_JOURNAL_QUESTS

-- =============================================================================
-- Module Declaration
-- =============================================================================
local PledgeTracker = {}

-- =============================================================================
-- Private State
-- =============================================================================
local todayPledges = {
  day = nil
}

local pledgesInJournal = {}

-- =============================================================================
-- Private Functions
-- =============================================================================

--- Converts a quest name to its corresponding pledge ID.
--- @param questName string The quest name to look up
--- @return number|nil pledgeId The pledge ID or nil if not found
local function questNameToPledgeId(questName)
  for _, data in pairs(GAFE.DUNGEONS_ACTIVITY_DATA) do
    if data.p then
      local pledgeName = LQD:get_quest_name(data.p, GAFE.lang)
      if questName == pledgeName then
        return data.p
      end
    end
  end
  return nil
end

-- =============================================================================
-- Public Functions
-- =============================================================================

--- Gets the current today pledges table.
--- @return table todayPledges Map of pledge ID to true for today's pledges
function PledgeTracker.GetTodayPledges()
  return todayPledges
end

--- Gets the current pledges in journal table.
--- @return table pledgesInJournal Map of pledge ID to completion status
function PledgeTracker.GetPledgesInJournal()
  return pledgesInJournal
end

--- Converts a quest name to its pledge ID.
--- @param questName string The quest name
--- @return number|nil pledgeId The pledge ID or nil
function PledgeTracker.QuestNameToPledgeId(questName)
  return questNameToPledgeId(questName)
end

--- Updates the todayPledges table based on the daily reset.
--- Also resets done pledges if the day has changed.
function PledgeTracker.UpdateTodayPledges()
  todayPledges = {
    day = nil
  }

  todayPledges.day = LibPanicida.Utils.GetDailyResetDay()

  local pledges = LUP.GetPledges(0)
  todayPledges[pledges[LUP.BASE1].questId] = true
  todayPledges[pledges[LUP.BASE2].questId] = true
  todayPledges[pledges[LUP.DLC1].questId] = true

  local characterId = GetCurrentCharacterId()
  local savedVars = GAFE.SavedVars
  if savedVars.dungeons.donePledges.day ~= todayPledges.day then
    savedVars.dungeons.donePledges = {}
    savedVars.dungeons.donePledges.day = todayPledges.day
  end
  if savedVars.dungeons.donePledges[characterId] == nil then
    savedVars.dungeons.donePledges[characterId] = {}
  end
end

--- Updates the pledgesInJournal table by scanning the quest journal.
--- @return table pledgesInJournal Map of pledge ID to completion status (true = completed step, false = in progress)
function PledgeTracker.UpdatePledgesInJournal()
  pledgesInJournal = {}

  for i = 1, MAX_JOURNAL_QUESTS do
    local questName, _, _, stepType, _, completed, _, _, _, questType, instanceType =
        GetJournalQuestInfo(i)
    if questName and questName ~= "" and not completed and questType == QUEST_TYPE_UNDAUNTED_PLEDGE and
        instanceType == INSTANCE_TYPE_GROUP then
      local pledgeId = questNameToPledgeId(questName)

      if pledgeId then
        pledgesInJournal[pledgeId] = stepType ~= QUEST_STEP_TYPE_AND
      else
        LibPanicida.Debug.LogLater(
          "Group & Activity Finder Extensions has encounter an unknown pledge quest name: " ..
          questName)
      end
    end
  end

  return pledgesInJournal
end

--- Marks a pledge as done in saved variables.
--- @param pledgeId number The pledge ID to mark as done
function PledgeTracker.MarkPledgeDone(pledgeId)
  local characterId = GetCurrentCharacterId()
  local donePledges = GAFE.SavedVars.dungeons.donePledges
  donePledges[characterId][pledgeId] = true
end

--- Renders pledge status on a dungeon control by coloring the text.
--- Green = completed or done, Gold = in progress, Blue = available but not picked up
--- @param pledgeId number The pledge ID
--- @param control table The UI control to modify
function PledgeTracker.AddPledge(pledgeId, control)
  local characterId = GetCurrentCharacterId()
  local donePledges = GAFE.SavedVars.dungeons.donePledges[characterId]
  local text = control.text:GetText()

  if pledgesInJournal[pledgeId] or donePledges[pledgeId] then
    -- In Journal and completed or done and not in journal
    text = "|c32CD32" .. text .. "|r" -- green
  elseif pledgesInJournal[pledgeId] == false then
    -- In Journal and not completed
    text = "|cFFD700" .. text .. "|r" -- gold
  elseif todayPledges[pledgeId] then
    -- Not done and not in journal
    text = "|c00CED1" .. text .. "|r" -- blue
  end
  control.text:SetText(text)

  control.gafePledge = pledgesInJournal[pledgeId] == false
end

--- Checks if a pledge is incomplete and in the journal.
--- @param pledgeId number The pledge ID to check
--- @return boolean isIncompletePledge True if the pledge is in journal but not completed
function PledgeTracker.IsIncompletePledge(pledgeId)
  return pledgesInJournal[pledgeId] == false
end

GAFE.PledgeTracker = PledgeTracker
