local em = GetEventManager()
local ln = LibNotification

-- Initialize our addon global
OFN = OFN or {}
OFN.name = "OfflineNotify"

-- Initialize is the entry point for the addon.
function OFN.Initialize(event, addon)
  if addon ~= OFN.name then return end
  OFN.settings = ZO_SavedVars:NewAccountWide("OfflineNotifySavedVariables", 1, nil, {})
  OFN.alerted = false

  -- Initialize the last seen timestamp if it's not set.
  OFN.settings.lastSeen = OFN.settings.lastSeen or GetTimeStamp()
  em:UnregisterForEvent("OfflineNotifyInitialize", EVENT_ADD_ON_LOADED)
  em:RegisterForEvent("OfflineNotifyStart", EVENT_PLAYER_ACTIVATED, function(...) OFN.Start(...) end)
end

-- Start is the first function to execute after the player has loaded.
function OFN.Start()
  OFN.provider = ln:CreateProvider()
  OFN.StartTimer()
end

-- DeleteNotification will delete the first notification from the provider.
-- TODO(lobato): Delete the correct notification based on index.
function OFN.DeleteNotification(msg)
  table.remove(OFN.provider.notifications)
  OFN.provider:UpdateNotifications()
end

-- OnPlayerStatus is called when the player changes their visibility status,
-- and will then update their lastSeen.
function OFN.OnPlayerStatus(event, oldStatus, newStatus)
  if newStatus == PLAYER_STATUS_OFFLINE then
    OFN.settings.lastSeen = GetTimeStamp()
    OFN.alerted = false
  end
end

-- ShouldNotify will determine if the player should see a notification
-- message, and send that message via LibNotification.
function OFN.ShouldNotify()
  if OFN.provider.notifications[1] ~= nil then
    return
  end
  playerStatus = GetPlayerStatus()
  -- The player isn't offline, no need to notify.
  if playerStatus ~= PLAYER_STATUS_OFFLINE then
    return
  end

  local lastSeen = OFN.settings.lastSeen
  local now = GetTimeStamp()
  local diff = GetDiffBetweenTimeStamps(now, lastSeen)
  -- 82800 is 23 hours.
  -- TODO(lobato): Make this configurable.
  if diff >= 82800 then
    OFN.SendNotification(diff)
    return
  end
end

-- SendNotification sends a notification to the player via LibNotification.
function OFN.SendNotification(diffTime)
  -- Display alerts only once per login, or per offline/online cycle.
  if OFN.alerted then return end
  
  local hours = math.floor(diffTime / 60 / 60)
  local msgText = string.format("You've been offline for over %d hours!", hours)
  local msg = {
    dataType                = NOTIFICATIONS_ALERT_DATA,
    secsSinceRequest        = ZO_NormalizeSecondsSince(0),
    note                    = "You should probably switch to online mode before you get kicked from all your guilds.",
    message                 = msgText,
    heading                 = "Offline Notify",
    texture                 = "/esoui/art/miscellaneous/eso_icon_warning.dds",
    shortDisplayText        = "Custom Notification",
    controlsOwnSounds       = true,
    keyboardAcceptCallback  = OFN.DeleteNotification,
    keyboardDeclineCallback = OFN.DeleteNotification,
    gamepadAcceptCallback   = OFN.DeleteNotification,
    gamepadDeclineCallback  = OFN.DeleteNotification,
    data                    = {},
  }
  table.insert(OFN.provider.notifications, msg)
  OFN.provider:UpdateNotifications()

  local alert = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINT_GAINED)
  alert:SetText(msgText)
  alert:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
  alert:MarkSuppressIconFrame()
	CENTER_SCREEN_ANNOUNCE:DisplayMessage(alert)
  OFN.alerted = true
end

function doTimer()
  OFN.ShouldNotify()
  zo_callLater(doTimer, 60 * 1000)
end

-- StartTimer starts the timer for notifications.
function OFN.StartTimer()
  doTimer()
end

em:RegisterForEvent("OfflineNotifyInitialize", EVENT_ADD_ON_LOADED, function (...) OFN.Initialize(...) end)
em:RegisterForEvent("OfflineNotifyPlayerStatus", EVENT_PLAYER_STATUS_CHANGED, function (...) OFN.OnPlayerStatus(...) end)