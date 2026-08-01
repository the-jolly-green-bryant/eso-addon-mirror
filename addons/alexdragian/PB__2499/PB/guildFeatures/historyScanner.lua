function PB.SetupHistoryScans()
  PB.NewScan( 1 )
end

local function trimHistory( guildId )
  if( PB.db.roster.guildData[guildId] == nil ) then
    PB.db.roster.guildData[guildId] = {
      lastScan = 0,
      inviteHistory = {},
      priorMembers = {}
    }
  else
    local trimList = {}
    local maxSecondsLast = 60 * 60 * 24 * 7 * 3
    --trim saved list
    for k, v in ipairs(PB.db.roster.guildData[guildId].inviteHistory) do 
      if PB.db.roster.guildData[guildId].inviteHistory[k].timeStamp > GetTimeStamp() - maxSecondsLast then
        table.insert( trimList, PB.db.roster.guildData[guildId].inviteHistory[k] )
      end
    end
  
    PB.db.roster.guildData[guildId].inviteHistory = trimList
  end
end

function PB.NewScan( guildIndex )
  local guilds = PB.guildList or PB.GetGuilds()
  if guilds[guildIndex] ~= nil then
    local guildId = guilds[guildIndex]
    trimHistory( guildId )
    PB.ScanHistory( guildId, guildIndex + 1 )
  else
    zo_callLater(function() PB.SetupHistoryScans() end, 60 * 1000)
  end
end

function PB.PrepGuildEvents( guildId )
  local numberOfEvents = GetNumGuildEvents(guildId, GUILD_HISTORY_GENERAL_ROSTER)
  local allEvents = {};
  local currentEvent = 1
  while currentEvent <= numberOfEvents do
    local theEvent = {}
    theEvent.eventType, theEvent.secondsSince, theEvent.member, theEvent.invitee = GetGuildEventInfo(guildId, GUILD_HISTORY_GENERAL_ROSTER, currentEvent)
    allEvents[currentEvent] = theEvent
    currentEvent = currentEvent + 1
  end

  table.sort(allEvents, function (k1, k2) return k1.secondsSince < k2.secondsSince end )

  return allEvents
end

function PB.ScanHistory( guildId, nextGuildIndex, oldNumberOfEvents, badLoads )
  badLoads = badLoads or 0
  oldNumberOfEvents = oldNumberOfEvents or 0

  local allEvents = PB.PrepGuildEvents( guildId )
  local maxSecondsLast = 60 * 60 * 24 * 7 * 3
  local secondsLast = maxSecondsLast + 1
  if #allEvents > 0 then
    secondsLast = allEvents[#allEvents].secondsSince
  end
  
  local lastEventTimeStamp = GetTimeStamp() - secondsLast
  if #allEvents > 0 then
    if DoesGuildHistoryCategoryHaveMoreEvents(guildId, GUILD_HISTORY_GENERAL_ROSTER)
     and badLoads < 10 and lastEventTimeStamp > PB.db.roster.guildData[guildId].lastScan
     and secondsLast < maxSecondsLast then
      badLoads = PB.Roe3ScanRequestMoreEvents( guildId, badLoads )
      zo_callLater(function() PB.ScanHistory(guildId, nextGuildIndex, #allEvents, badLoads) end, 5000)
    else
      PB.MapEventsToMemory( allEvents, guildId )
      PB.NewScan( nextGuildIndex )
    end
  end
end

function PB.Roe3ScanRequestMoreEvents( guildId, badLoads )
  if DoesGuildHistoryCategoryHaveOutstandingRequest(guildId, GUILD_HISTORY_GENERAL_ROSTER) then
    return 0
  elseif IsGuildHistoryCategoryRequestQueued(guildId, GUILD_HISTORY_GENERAL_ROSTER) then
    return 0
  elseif RequestMoreGuildHistoryCategoryEvents(guildId, GUILD_HISTORY_GENERAL_ROSTER, true) then
    return 0
  else
    return badLoads + 1
  end
end

function PB.MapEventsToMemory( allEvents, guildId )
  local scanTime = PB.db.roster.guildData[guildId].lastScan
  local numberOfEvents = GetNumGuildEvents(guildId, GUILD_HISTORY_GENERAL_ROSTER)
  local currentEvent = 1
  local eventTimeStamp = GetTimeStamp()
  local eventMap = {}
  while currentEvent <= #allEvents do
    local theEvent = allEvents[currentEvent]
    eventTimeStamp = GetTimeStamp() - theEvent.secondsSince
    
    if scanTime < eventTimeStamp then
      scanTime = eventTimeStamp
    end

    theEvent.timeStamp = eventTimeStamp
    theEvent.secondsSince = nil
    if eventTimeStamp > PB.db.roster.guildData[guildId].lastScan then
      if theEvent.eventType == 1 then
        table.insert( eventMap, theEvent )
      elseif theEvent.eventType == 8 then
        PB.db.roster.guildData[guildId].priorMembers[theEvent.member] = theEvent
      elseif theEvent.eventType == 12 then
        PB.db.roster.guildData[guildId].priorMembers[theEvent.invitee] = theEvent
      end
    end
    currentEvent = currentEvent + 1
  end
  
  for i = #eventMap, 1, -1 do
    table.insert(PB.db.roster.guildData[guildId].inviteHistory, eventMap[i])
  end

  PB.db.roster.guildData[guildId].lastScan = scanTime
end