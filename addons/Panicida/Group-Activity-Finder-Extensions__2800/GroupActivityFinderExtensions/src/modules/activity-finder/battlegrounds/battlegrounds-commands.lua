-- =============================================================================
-- Localized Globals
-- =============================================================================
local pairs = pairs

local GAFE = GroupActivityFinderExtensions
local QueueManager = GAFE.QueueManager


-- =============================================================================
-- Module Declaration
-- =============================================================================
local BattlegroundCommands = {}

-- =============================================================================
-- Private Functions
-- =============================================================================

-- =============================================================================
-- Public Functions
-- =============================================================================

--- Queues a random battleground based on player eligibility.
function BattlegroundCommands.Battleground()
  local activityType = nil
  if GetUnitLevel("player") ~= 50 then
    activityType = LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL
  else
    activityType = LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION
  end
  QueueManager.QueueByActivityType(activityType)
end

--- Initializes slash commands for battleground queuing.
function BattlegroundCommands.Init()
  local commandsList = {
    { name = "/qb", func = BattlegroundCommands.Battleground },
  }
  for _, param in pairs(commandsList) do
    SLASH_COMMANDS[param.name] = param.func
  end
end

-- =============================================================================
-- Module Registration
-- =============================================================================
GAFE.BattlegroundCommands = BattlegroundCommands
