-- =============================================================================
-- Localized Globals
-- =============================================================================
local pairs = pairs

local GetCompletedQuestInfo = GetCompletedQuestInfo
local ZO_GetEffectiveDungeonDifficulty = ZO_GetEffectiveDungeonDifficulty

local GAFE = GroupActivityFinderExtensions
local QueueManager = GAFE.QueueManager
local PledgeTracker = GAFE.PledgeTracker
local DungeonActivityData = GAFE.DUNGEONS_ACTIVITY_DATA

-- =============================================================================
-- Constants
-- =============================================================================

-- =============================================================================
-- Module Declaration
-- =============================================================================
local DungeonCommands = {}

-- =============================================================================
-- Private Functions
-- =============================================================================

-- =============================================================================
-- Public Functions
-- =============================================================================

--- Gets the current dungeon activity type based on group difficulty.
--- @return number activityType LFG_ACTIVITY_DUNGEON or LFG_ACTIVITY_MASTER_DUNGEON
function DungeonCommands.GetCurrentDungeonActivityType()
  local savedVars = GAFE.SavedVars
  return savedVars.collapse == GAFE.COLLAPSE_MODE.Group and
      (
        ZO_GetEffectiveDungeonDifficulty() == DUNGEON_DIFFICULTY_NORMAL
        and LFG_ACTIVITY_DUNGEON
        or LFG_ACTIVITY_MASTER_DUNGEON
      )
      or
      (
        savedVars.collapse == GAFE.COLLAPSE_MODE.Normal
        and LFG_ACTIVITY_DUNGEON
        or LFG_ACTIVITY_MASTER_DUNGEON
      )
end

--- Queues dungeons where the associated quest has not been completed.
--- @param verbose string|nil Pass "verbose" to show locked locations in output
function DungeonCommands.Quests(verbose)
  local function condition(activityData)
    return GetCompletedQuestInfo(activityData.q) == ""
  end

  local activityType = DungeonCommands.GetCurrentDungeonActivityType()
  QueueManager.QueueWhere(activityType, DungeonActivityData, condition,
    verbose)
end

--- Queues dungeons for incomplete pledges currently in the journal.
--- @param verbose string|nil Pass "verbose" to show locked locations in output
function DungeonCommands.Pledges(verbose)
  local function condition(activityData)
    return PledgeTracker.IsIncompletePledge(activityData.p)
  end

  local activityType = DungeonCommands.GetCurrentDungeonActivityType()
  QueueManager.QueueWhere(activityType, DungeonActivityData, condition,
    verbose)
end

--- Queues dungeons for incomplete sets collection.
--- @param verbose string|nil Pass "verbose" to show locked locations in output
function DungeonCommands.Sets(verbose)
  local function condition(activityData)
    for _, setId in pairs(activityData.sets) do
      local setCollectionData = ITEM_SET_COLLECTIONS_DATA_MANAGER
          :GetItemSetCollectionData(setId)
      local numUnlockedPieces = setCollectionData:GetNumUnlockedPieces()
      local numPieces = setCollectionData:GetNumPieces()
      if numUnlockedPieces ~= numPieces then
        return true
      end
    end
    return false
  end

  local activityType = DungeonCommands.GetCurrentDungeonActivityType()
  QueueManager.QueueWhere(activityType, DungeonActivityData, condition,
    verbose)
end

--- Queues a random dungeon at the current effective difficulty.
function DungeonCommands.Dungeon()
  local activityType = DungeonCommands.GetCurrentDungeonActivityType()
  QueueManager.QueueByActivityType(activityType)
end

--- Initializes slash commands for dungeon queuing.
function DungeonCommands.Init()
  local commandsList = {
    { name = "/qq", func = DungeonCommands.Quests },
    { name = "/qp", func = DungeonCommands.Pledges },
    { name = "/qd", func = DungeonCommands.Dungeon },
    { name = "/qs", func = DungeonCommands.Sets },
  }

  for _, param in pairs(commandsList) do
    SLASH_COMMANDS[param.name] = param.func
  end
end

-- =============================================================================
-- Module Registration
-- =============================================================================
GAFE.DungeonCommands = DungeonCommands
