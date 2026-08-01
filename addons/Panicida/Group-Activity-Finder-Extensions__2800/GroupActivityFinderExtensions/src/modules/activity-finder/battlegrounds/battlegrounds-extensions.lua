-- ============================================================================
-- Localized Globals
-- ============================================================================
local EVENT_MANAGER = EVENT_MANAGER

local GAFE = GroupActivityFinderExtensions
local RewardTracker = GAFE.RewardTracker

-- ============================================================================
-- Constants
-- ============================================================================
local BATTLEGROUND_REWARD_CHECK_DELAY_MS = 1000

-- ============================================================================
-- Module Declaration
-- ============================================================================
local BattlegroundsExtensions = {
  extender = GAFE.ActivityFinderExtender:New()
}
local extender = BattlegroundsExtensions.extender

-- ============================================================================
-- Private Functions
-- ============================================================================

-- ============================================================================
-- Public Functions
-- ============================================================================

--- Initializes the battlegrounds extensions module.
--- Sets up the extender and registers for battleground state change events.
function BattlegroundsExtensions.Init()
  extender:Initialize({
    rewardsVars = GAFE.SavedVars.battlegrounds,
    root = "ZO_Battleground",
  })

  local onActivityFinderStatusUpdate = RewardTracker
      .CreateCompletionHandler({
        activityType = LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION,
        extender = extender,
        delayMs = BATTLEGROUND_REWARD_CHECK_DELAY_MS,
      })

  EVENT_MANAGER:RegisterForEvent(
    GAFE.name .. extender.root .. "Activity_Update",
    EVENT_BATTLEGROUND_STATE_CHANGED,
    onActivityFinderStatusUpdate
  )
end

-- ============================================================================
-- Module Registration
-- ============================================================================
GAFE.BattlegroundsExtensions = BattlegroundsExtensions
