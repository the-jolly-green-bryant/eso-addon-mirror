-- =============================================================================
-- Localized Globals
-- =============================================================================
local GetTimeStamp = GetTimeStamp
local IsActivityEligibleForDailyReward = IsActivityEligibleForDailyReward
local zo_callLater = zo_callLater

local GAFE = GroupActivityFinderExtensions

-- =============================================================================
-- Constants
-- =============================================================================
local DEFAULT_DELAY_MS = 1000
local SECONDS_PER_DAY = 86400
local SECONDS_PER_WEEK = 604800
local TUESDAY = 2 -- Day of week (0=Sunday)

-- =============================================================================
-- Module Declaration
-- =============================================================================
local RewardTracker = {}

-- =============================================================================
-- Reset Timer Functions
-- =============================================================================

--- Gets the timestamp of the next daily reset.
--- @return number timestamp The Unix timestamp of the next daily reset
function RewardTracker.GetNextDailyResetTimestamp()
  local today = LibPanicida.Utils.GetDailyResetDay()
  return (today + 1) * SECONDS_PER_DAY + LibPanicida.Utils.GetDailyResetBase()
end

--- Calculates time until the next daily reset.
--- @return number timeRemaining Seconds until the next daily reset
function RewardTracker.GetTimeUntilDailyReset()
  return RewardTracker.GetNextDailyResetTimestamp() - GetTimeStamp()
end

--- Gets the timestamp of the most recent weekly reset (Tuesday at daily reset time).
--- @return number timestamp The Unix timestamp of the most recent Tuesday reset
function RewardTracker.GetCurrentWeeklyResetTimestamp()
  local dailyResetBase = LibPanicida.Utils.GetDailyResetBase()
  local today = LibPanicida.Utils.GetDailyResetDay()

  -- Unix epoch (Jan 1, 1970) was Thursday. In 0=Sunday system, Thursday=4
  local dayOfWeek = (today + 4) % 7 -- 0=Sunday, 2=Tuesday

  local daysSinceTuesday = (dayOfWeek - TUESDAY + 7) % 7

  -- If we're on Tuesday but before reset time, use last Tuesday
  if daysSinceTuesday == 0 then
    local todayReset = dailyResetBase + (today * SECONDS_PER_DAY)
    if GetTimeStamp() < todayReset then
      daysSinceTuesday = 7
    end
  end

  return dailyResetBase + ((today - daysSinceTuesday) * SECONDS_PER_DAY)
end

--- Calculates time until the next weekly reset (Tuesday at daily reset time).
--- @return number timeRemaining Seconds until the next Tuesday reset
function RewardTracker.GetTimeUntilWeeklyReset()
  local currentWeekReset = RewardTracker.GetCurrentWeeklyResetTimestamp()
  local nextWeekReset = currentWeekReset + SECONDS_PER_WEEK
  return nextWeekReset - GetTimeStamp()
end

-- =============================================================================
-- Public Functions
-- =============================================================================

function RewardTracker.CreateCompletionHandler(params)
  local activityType = params.activityType
  local extender = params.extender
  local delayMs = params.delayMs or DEFAULT_DELAY_MS

  return function(_eventCode, _previousState, _nextState)
    zo_callLater(function()
      local isRewardAvailableByTimer = extender.GetTimeUntilNextReward(
        extender.characterId, extender.rewardsVars) <= 0
      local isRewardAvailableByZos = IsActivityEligibleForDailyReward(
        activityType)

      if isRewardAvailableByTimer and not isRewardAvailableByZos then
        extender.rewardsVars.randomRewards[extender.characterId] = GetTimeStamp()
      end
    end, delayMs)
  end
end

-- Module Registration
GAFE.RewardTracker = RewardTracker
