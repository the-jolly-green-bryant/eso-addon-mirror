Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.notifications = ERG.notifications or {}
local Notifications = ERG.notifications

function Notifications.Initialize()
  Notifications.name = ERG.name.."Notification"

  Notifications.bannerList = {}
  Notifications.subtitleList = {}
  Notifications.warningList = {}

  Notifications.RegisterEvents()
end


function Notifications.RegisterEvents()

  local function RegisterBasicEventAndAbilityFilter(encounter, id, data, eventName, notification, abilityId)
    if not abilityId then abilityId = id end
    ERG.EM:RegisterForEvent( eventName, data.event, function(...)
          local func = Notifications[notification]
          func(encounter, id, data, ...)
        end)
    ERG.EM:AddFilterForEvent( eventName, data.event, REGISTER_FILTER_ABILITY_ID, abilityId)
  end

  local function AddStaticFilterForEvent(eventName, data)
    if not data.staticFilter then return end
    for type, param in pairs(data.staticFilter) do
      ERG.EM:AddFilterForEvent( eventName, data.event, type, param)
    end
  end

  for _, encounter in ipairs( ERG.GetEncounterList() ) do
    local notificationList = ERG[encounter].GetNotificationList()
    for id, specificNotificationList in pairs(notificationList) do
      for notification, data in pairs(specificNotificationList) do
        local eventName = ERG.name..encounter..tostring(id)..notification
        RegisterBasicEventAndAbilityFilter(encounter, id, data, eventName, notification)
        AddStaticFilterForEvent( eventName, data)
        if ERG[encounter].GetMechanicData()[id].alternativeIds then
          for _, alternativeId in pairs( ERG[encounter].GetMechanicData()[id].alternativeIds ) do
            eventName = eventName..tostring(alternativeId)
            RegisterBasicEventAndAbilityFilter(encounter, id, data, eventName, notification, alternativeId)
            AddStaticFilterForEvent( eventName, data)
          end
        end
      end
    end
  end

  ERG.EM:RegisterForEvent( Notifications.name.."Subtitle", EVENT_CHAT_MESSAGE_CHANNEL, Notifications.OnSubtitle)

end


function Notifications.RegisterSubtitle(boss, subtitle, callback)
  Notifications.subtitleList[boss] = Notifications.subtitleList[boss] or {}
  table.insert(Notifications.subtitleList[boss], {subtitle = subtitle, callback = callback})
end


--TODO OnCombatEnd unregister all warning/banner
function Notifications.OnCombatEnd()
  for _, callbackId in ipairs( Notifications.warningList ) do
    zo_removeCallLater( callbackId )
  end
  Notifications.warningList = {}
end

---------------------
-- Utilities --
---------------------

local function IsDynamicFilterFulfilled(store, data, ...)
  if not data.dynamicFilter then return true end

  local params = {...}
  local paramTable = ERG.GetEventParameterNames( params[1] )

  for type, param in pairs(data.dynamicFilter) do
    if params[ paramTable[type] ] ~= param then return false end
  end

  return true
end


local function ExecuteCallback(data)
  --local func = Rockgroover.oaxiltso[data.callback]
  local func = data.callback
  if type(func) == "function" then
    func()
  end
end


function Notifications.GetMinorText(id, text)
  if not ERG.SV.showAbilityName then return "" end
  local abilityName = ERG.GetFormattedAbilityName(id)
  if text ~= abilityName then
    return abilityName
  else
    return ""
  end
end


function Notifications.AddIconToAlert(encounter, id, major)
  if not ERG.SV.showIconWithAlerts then return major end
  local mechanicData = ERG[encounter].GetMechanicData()
  return ERG.AddIconToString( major ,mechanicData[id].icon or id, 44, true)
end


------------
-- Alerts --
------------

function Notifications.OnTextAlert(encounter, id, data, ...)
  local store = ERG.store[encounter][id]
  if type(data) ~= "table" then data = {} end

  ExecuteCallback(data)

  if not store.OnTextAlert then return end
  if not IsDynamicFilterFulfilled(store, data, ...) then return end

  local major = Notifications.AddIconToAlert(encounter, id, store.OnTextAlertText)
  local minor = Notifications.GetMinorText(id, store.OnTextAlertText)

  --CombatAlerts.Alert( textMinor, textMajor, color, sound, duration )
  zo_callLater( function() CombatAlerts.Alert(minor, major, ERG.GetCombatAlertsColor(store.color), store.sound, data.duration or 1500) end, data.delay or 0) --TODO why data.duration?
end



function Notifications.OnBannerAlert(encounter, id, data, ...)
  local store = ERG.store[encounter][id]

  ExecuteCallback(data)

  if not store.OnBannerAlert then return end
  if not IsDynamicFilterFulfilled(store, data, ...) then return end

  Notifications.bannerList[id] = Notifications.bannerList[id] or {}
  zo_callLater( function()
    local function OnBannerUpdate()
      local timeRemaining = ERG.GetTimeRemaining( Notifications.bannerList[id].endTime, true )
      local major = zo_strformat("<<1>>: <<2>>",store.OnBannerAlertText, timeRemaining)
      major = Notifications.AddIconToAlert(encounter, id, major)
      local minor = Notifications.GetMinorText(id, store.OnBannerAlertText)
      --CombatAlerts.ModifyBanner( id, textMinor, textMajor, color, radialPercent, radialText, radialColor, show )
      CombatAlerts.ModifyBanner(Notifications.bannerList[id].id, minor, major, ERG.GetCombatAlertsColor(store.color) )
      if ERG.GetRemainingMilliseconds( Notifications.bannerList[id].endTime ) == 0 then
        CombatAlerts.DisableBanner(Notifications.bannerList[id].id)
        Notifications.bannerList[id] = nil
      end
    end

    if Notifications.bannerList[id].id then CombatAlerts.DisableBanner(Notifications.bannerList[id].id) end
    --CombatAlerts.AlertBannerEx( textMinor, textMajor, color, icon, show, sound, callback )
    Notifications.bannerList[id].id = CombatAlerts.AlertBannerEx(nil, nil, nil, nil, true, store.sound, OnBannerUpdate)
    Notifications.bannerList[id].endTime = GetGameTimeMilliseconds() + data.duration

  end, data.delay or 0)
end



function Notifications.OnCastAlert(encounter, id, data, ...)
  local store = ERG.store[encounter][id]

  ExecuteCallback(data)

  if not store.OnCastAlert then return end
  if not IsDynamicFilterFulfilled(store, data, ...) then return end

  local mechanicData = ERG[encounter].GetMechanicData()

  --CombatAlerts.CastAlertsStart( abilityIconId, caption, duration, durationMax, color, action )
  --action[1] = time, action[2] = text, action[3] = r, action[4] = g, action[5] = b, action[6] = a, action[7] = sound

  local icon = mechanicData[id].iconId or id
  local text = mechanicData[id].name or ERG.GetFormattedAbilityName(id)
  local duration = data.duration
  local actionTime = data.actionTime or duration
  CombatAlerts.CastAlertsStart( icon, text, duration, duration, nil, {actionTime, store.OnCastAlertText or "", store.color[1],store.color[2],store.color[3],store.color[4], store.sound} )

  --/script CombatAlerts.CastAlertsStart( 149414, "text", 2750, 2750, nil, {2750, "actionText", 0.6,0,0,1, SOUNDS.DUEL_START} )
end



function Notifications.OnSubtitle(_, channelType, _, message)
  local npcTalking = false
  for _, channel in ipairs( ERG.GetNPCChannelList() ) do
    if channel == channelType then
      npcTalking = true
      break
    end
  end
  if not npcTalking then return end

  if type( Notifications.subtitleList[ERG.arena.boss] ) == "table" then
    for _, entry in ipairs( Notifications.subtitleList[ERG.arena.boss] ) do
      if entry.subtitle == message then
        entry.callback()
        break
      end
    end
  end
end
