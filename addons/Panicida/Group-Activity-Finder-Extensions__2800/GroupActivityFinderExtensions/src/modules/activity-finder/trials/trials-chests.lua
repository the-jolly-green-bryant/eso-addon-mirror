-- =============================================================================
-- Localized Globals
-- =============================================================================
local EVENT_MANAGER = EVENT_MANAGER
local EVENT_QUEST_REMOVED = EVENT_QUEST_REMOVED
local GetCharacterInfo = GetCharacterInfo
local GetCurrentCharacterId = GetCurrentCharacterId
local GetNumCharacters = GetNumCharacters
local GetTimeStamp = GetTimeStamp
local pairs = pairs

local GAFE = GroupActivityFinderExtensions

-- =============================================================================
-- Constants
-- =============================================================================
-- Lookup table for trial quests that reward weekly chests (lazily initialized)
local TRIAL_QUEST_IDS = nil

-- =============================================================================
-- Module Declaration
-- =============================================================================
local TrialsChests = {}

-- =============================================================================
-- Private Functions
-- =============================================================================

--- Builds the trial quest lookup table from activity data.
--- Uses lazy initialization to ensure GAFE.TRIALS_ACTIVITY_DATA is available.
--- @return table A lookup table mapping quest IDs to true
local function GetTrialQuestIds()
  if TRIAL_QUEST_IDS then
    return TRIAL_QUEST_IDS
  end

  TRIAL_QUEST_IDS = {
    [GAFE.TRIALS_ACTIVITY_DATA[GAFE.ACTIVITY_ID.NormalAetherianArchive].q] = true,
    [GAFE.TRIALS_ACTIVITY_DATA[GAFE.ACTIVITY_ID.NormalHelRaCitadel].q] = true,
    [GAFE.TRIALS_ACTIVITY_DATA[GAFE.ACTIVITY_ID.NormalSanctumOphidia].q] = true,
    [GAFE.TRIALS_ACTIVITY_DATA[GAFE.ACTIVITY_ID.NormalMawOfLorkhaj].q] = true,
    [GAFE.TRIALS_ACTIVITY_DATA[GAFE.ACTIVITY_ID.NormalHallsOfFabrication].q] = true,
    [GAFE.TRIALS_ACTIVITY_DATA[GAFE.ACTIVITY_ID.NormalAsylumSanctorium].q] = true,
    [GAFE.TRIALS_ACTIVITY_DATA[GAFE.ACTIVITY_ID.NormalCloudrest].q] = true,
    [GAFE.TRIALS_ACTIVITY_DATA[GAFE.ACTIVITY_ID.NormalSunspire].q] = true,
    [GAFE.TRIALS_ACTIVITY_DATA[GAFE.ACTIVITY_ID.NormalKynesAegis].q] = true,
    [GAFE.TRIALS_ACTIVITY_DATA[GAFE.ACTIVITY_ID.NormalDreadsailReef].q] = true,
  }

  return TRIAL_QUEST_IDS
end

--- Event handler for quest removal.
--- Records chest completion time when a trial quest is completed.
--- @param eventCode number The event code (unused)
--- @param isCompleted boolean Whether the quest was completed
--- @param journalIndex number Journal index (unused)
--- @param questName string Quest name (unused)
--- @param zoneIndex number Zone index (unused)
--- @param poiIndex number POI index (unused)
--- @param questId number The ID of the removed quest
local function UpdateChestTimes(_, isCompleted, _, _, _, _, questId)
  local trialQuestIds = GetTrialQuestIds()

  if not trialQuestIds[questId] or not isCompleted then
    return
  end

  local canGetChest = TrialsChests.GetTimeUntilNextChest(
    GetCurrentCharacterId(),
    questId
  ) <= 0

  if canGetChest then
    TrialsChests.ResetChest(questId)
  end
end

-- =============================================================================
-- Public Functions
-- =============================================================================

--- Initializes the trials chest tracking system.
--- Sets up saved variables for all characters and registers event handlers.
function TrialsChests.Init()
  local chestsVars = GAFE.SavedVars.trials.chests

  -- Build lookup of valid character IDs
  local characters = {}
  local numCharacters = GetNumCharacters()
  for i = 1, numCharacters do
    local _, _, _, _, _, _, id = GetCharacterInfo(i)

    if chestsVars[id] == nil then
      chestsVars[id] = {}
    end

    characters[id] = true
  end

  -- Remove stale character entries
  for id in pairs(chestsVars) do
    if not characters[id] then
      chestsVars[id] = nil
    end
  end

  EVENT_MANAGER:RegisterForEvent(
    GAFE.name .. "_QuestRemoved",
    EVENT_QUEST_REMOVED,
    UpdateChestTimes
  )
end

--- Calculates time remaining until a character can receive a trial chest.
--- @param characterId string The character's unique identifier
--- @param questId number The trial quest ID
--- @return number Time in seconds until chest is available (0 if available now)
function TrialsChests.GetTimeUntilNextChest(characterId, questId)
  local completedTimeStamp = GAFE.SavedVars.trials.chests[characterId][questId]

  if not completedTimeStamp then
    return 0
  end

  local currentWeekStart = GAFE.RewardTracker.GetCurrentWeeklyResetTimestamp()

  -- If completed during or after current week's reset, chest is locked until next Tuesday
  if completedTimeStamp >= currentWeekStart then
    local timeUntilReset = GAFE.RewardTracker.GetTimeUntilWeeklyReset()
    return timeUntilReset >= 0 and timeUntilReset or 0
  end

  -- Chest is available (completedTimeStamp < currentWeekStart)
  return 0
end

--- Records that a trial chest was obtained for the current character.
--- @param questId number The trial quest ID
function TrialsChests.ResetChest(questId)
  local characterId = GetCurrentCharacterId()
  GAFE.SavedVars.trials.chests[characterId][questId] = GetTimeStamp()
end

-- =============================================================================
-- Module Registration
-- =============================================================================
GAFE.TrialsChests = TrialsChests
