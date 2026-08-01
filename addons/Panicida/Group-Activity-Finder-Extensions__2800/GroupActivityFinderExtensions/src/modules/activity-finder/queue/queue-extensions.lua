-- ============================================================================
-- Localized Globals
-- ============================================================================
local GAFE = GroupActivityFinderExtensions

local EVENT_MANAGER = EVENT_MANAGER
local GetActivityFinderStatus = GetActivityFinderStatus
local HasAcceptedLFGReadyCheck = HasAcceptedLFGReadyCheck
local IsActiveWorldBattleground = IsActiveWorldBattleground
local AcceptLFGReadyCheckNotification = AcceptLFGReadyCheckNotification
local GetLFGSearchTimes = GetLFGSearchTimes
local GetFrameTimeMilliseconds = GetFrameTimeMilliseconds
local ZO_FormatTimeMilliseconds = ZO_FormatTimeMilliseconds
local GetString = GetString
local zo_strformat = zo_strformat
local PlaySound = PlaySound

-- ============================================================================
-- Constants
-- ============================================================================
local LOOP_SOUND_INTERVAL_MS = 2000
local TIMER_UPDATE_INTERVAL_MS = 1000
local NO_ICON = ""

-- ============================================================================
-- Module Declaration
-- ============================================================================
local QueueExtensions = {}

-- ============================================================================
-- Private Variables
-- ============================================================================
local autoConfirmCheckbox
local timerLabel

-- ============================================================================
-- Private Functions
-- ============================================================================

--- Refreshes the auto confirm event registrations based on saved settings.
--- Registers or unregisters event handlers for activity finder status changes.
local function RefreshAutoConfirmEvents()
  local savedVars = GAFE.SavedVars
  local eventName = GAFE.name .. "_QueueExtensions_AutoConfirm"
  local loopSoundEventName = GAFE.name .. "_QueueExtensions_LoopSound"

  --- Plays a looping sound while waiting for ready check confirmation.
  local function LoopSound()
    if GetActivityFinderStatus() ~= ACTIVITY_FINDER_STATUS_READY_CHECK or HasAcceptedLFGReadyCheck() then
      EVENT_MANAGER:UnregisterForUpdate(loopSoundEventName)
    else
      PlaySound(SOUNDS.LFG_SEARCH_FINISHED)
    end
  end

  --- Handles activity finder status changes.
  --- @param _ any Unused event code
  --- @param status number The new activity finder status
  local function OnActivityFinderStatusChange(_, status)
    if status == ACTIVITY_FINDER_STATUS_READY_CHECK and not IsActiveWorldBattleground() then
      if savedVars.autoConfirm.enabled and savedVars.autoConfirm.value then
        LibPanicida.Utils.CallLater("ReadyCheck",
          GAFE.SavedVars.autoConfirm.delay,
          AcceptLFGReadyCheckNotification)
      end

      if savedVars.autoConfirm.loopSound then
        EVENT_MANAGER:RegisterForUpdate(loopSoundEventName,
          LOOP_SOUND_INTERVAL_MS, LoopSound)
      end
    end
  end

  if (savedVars.autoConfirm.enabled and savedVars.autoConfirm.value) or savedVars.autoConfirm.loopSound then
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_PLAYER_ACTIVATED, function()
      EVENT_MANAGER:RegisterForEvent(eventName,
        EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnActivityFinderStatusChange)
    end)
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_PLAYER_DEACTIVATED,
      function()
        EVENT_MANAGER:UnregisterForEvent(eventName,
          EVENT_ACTIVITY_FINDER_STATUS_UPDATE)
      end)
  else
    EVENT_MANAGER:UnregisterForEvent(eventName,
      EVENT_ACTIVITY_FINDER_STATUS_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_PLAYER_DEACTIVATED)
  end
end

--- Initializes the auto confirm checkbox and event handlers.
local function InitializeAutoConfirm()
  local savedVars = GAFE.SavedVars

  --- Toggles the auto confirm setting and refreshes events.
  local function ToggleAutoConfirm()
    savedVars.autoConfirm.value = not savedVars.autoConfirm.value
    autoConfirmCheckbox.SetChecked(savedVars.autoConfirm.value)
    RefreshAutoConfirmEvents()
  end

  local parent = ZO_SearchingForGroupStatus
  if parent then
    autoConfirmCheckbox = LibPanicida.Controls.Checkbox(
      "GAFE_AutoConfirmActivity",
      parent,
      { 200, 28 },
      { BOTTOM, parent, TOP, 0, 0 },
      GAFE.Loc("AutoConfirm"),
      ToggleAutoConfirm, true,
      savedVars.autoConfirm.value,
      not savedVars.autoConfirm.enabled
    )
  end

  RefreshAutoConfirmEvents()
end

--- Initializes the queue timer display.
local function InitializeTimer()
  local ACTUAL_HEADER_TEXT = GetString(SI_GAMEPAD_LFG_QUEUE_ACTUAL)
  local registered = false

  --- Updates the timer label with current queue duration.
  local function UpdateTimer()
    local searchStartTimeMs = GetLFGSearchTimes()
    local timeSinceSearchStartMs = GetFrameTimeMilliseconds() - searchStartTimeMs
    local textStartTime = ZO_FormatTimeMilliseconds(
      timeSinceSearchStartMs,
      TIME_FORMAT_STYLE_COLONS,
      TIME_FORMAT_PRECISION_TWELVE_HOUR
    )

    timerLabel:SetText(zo_strformat(SI_ACTIVITY_QUEUE_STATUS_LABEL_FORMAT,
      ACTUAL_HEADER_TEXT, NO_ICON,
      textStartTime))
  end

  --- Handles activity finder status updates for timer registration.
  --- @param status number The new activity finder status
  local function OnActivityFinderStatusUpdate(status)
    if status == ACTIVITY_FINDER_STATUS_QUEUED and not registered then
      registered = true
      UpdateTimer()
      EVENT_MANAGER:RegisterForUpdate(GAFE.name .. "_QueueExtensions_Timer",
        TIMER_UPDATE_INTERVAL_MS, UpdateTimer)
    elseif status ~= ACTIVITY_FINDER_STATUS_QUEUED and registered then
      registered = false
      EVENT_MANAGER:UnregisterForUpdate(GAFE.name .. "_QueueExtensions_Timer")
    end
  end

  local parent = ZO_ActivityTrackerContainerSubLabel
  timerLabel = LibPanicida.Controls.Label(
    "GAFE_ActivityTracker_QueueTimer",
    parent,
    { 125, 20 },
    { LEFT, parent, LEFT, 0, 20 },
    "ZoFontGameShadow",
    nil,
    { 0, 1 }
  )

  ZO_ACTIVITY_FINDER_ROOT_MANAGER:RegisterCallback(
    "OnActivityFinderStatusUpdate", OnActivityFinderStatusUpdate)
end

-- ============================================================================
-- Public Functions
-- ============================================================================

--- Initializes the Queue Extensions module.
--- Sets up auto confirm checkbox and queue timer display.
function QueueExtensions.Init()
  InitializeAutoConfirm()
  InitializeTimer()
end

--- Toggles auto confirm feature visibility and functionality.
--- @param enable boolean Whether to enable the auto confirm feature
function QueueExtensions.AutoConfirm(enable)
  local savedVars = GAFE.SavedVars
  savedVars.autoConfirm.enabled = enable
  autoConfirmCheckbox:SetHidden(not enable)
  RefreshAutoConfirmEvents()
end

-- ============================================================================
-- Module Registration
-- ============================================================================
GAFE.QueueExtensions = QueueExtensions
