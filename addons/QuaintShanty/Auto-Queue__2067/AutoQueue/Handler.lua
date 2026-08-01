-- AutoQueue namespace
local AutoQueue = _G['AutoQueue']
AutoQueue.Handler = {}

local Handler = AutoQueue.Handler
local Settings = AutoQueue.Settings

function Handler.Initialize()
  EVENT_MANAGER:RegisterForEvent(AutoQueue.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, Handler.AutoAcceptActivity)
end

function Handler.AutoAcceptActivity(eventCode, status)
  if status ~= ACTIVITY_FINDER_STATUS_READY_CHECK then
    return
  end

  if IsActiveWorldBattleground() then
    return
  end

  if HasLFGReadyCheckNotification() then
    if not Settings.vars.autoQueue then
      if not Settings.vars.muted then
        d('This queue was not automatically accepted. Turn it off with /autoqueue.')
      end
      return
    end
    AcceptLFGReadyCheckNotification()
  end
end
