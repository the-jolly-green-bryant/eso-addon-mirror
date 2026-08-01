ElmsMarkers = ElmsMarkers or { }

function ElmsMarkers.HandleDataShareReceived(tag, data)
	if tag and data then
    if(tag == GetGroupLeaderUnitTag() and ElmsMarkers.savedVars.subscribeToLead) then
      local tuple = ElmsMarkers.dataShareTuple
      local isRendezvous = false
      local dataIdentifier = data % 10

      if dataIdentifier == 1 then
        local wX = math.floor(data / 100000)
        local iconId = math.floor(data % 100000 / 10)
        tuple.wX = wX
        tuple.iconId = iconId
      elseif dataIdentifier == 2 then
        local wZ = math.floor(data / 100000)
        local zone = math.floor(data % 100000 / 10)
        tuple.wZ = wZ
        tuple.zone = zone
      elseif dataIdentifier == 3 or dataIdentifier == 9 then
        local wY = math.floor(data / 1000)
        local isAdd = math.floor(data % 1000 / 100)
        tuple.wY = wY
        tuple.isAdd = isAdd
        if dataIdentifier == 9 then
          isRendezvous = true
        end
      end

      if tuple.zone and tuple.wX and tuple.wY and tuple.wZ and tuple.iconId and tuple.isAdd then
        if(isRendezvous) then
          ElmsMarkers.PlaceRendezvousAt({tuple.zone, tuple.wX, tuple.wY, tuple.wZ, tuple.iconId}, false)
        elseif(tuple.isAdd == 2) then
          ElmsMarkers.PlaceAtLocation({tuple.zone, tuple.wX, tuple.wY, tuple.wZ, tuple.iconId})
        else
          ElmsMarkers.RemoveExactMarkerAt({tuple.zone, tuple.wX, tuple.wY, tuple.wZ})
        end
        ElmsMarkers.dataShareTuple = { }
      end
    end
  end
end

function ElmsMarkers.PlaceRendezvousAt(location, isLeader)
  if not isLeader and not ElmsMarkers.savedVars.optIntoCommands then return end
  if not OSI or not OSI.CreatePositionIcon then return end
  local zone, wX, wY, wZ, iconId = unpack(location)
  local texture = ElmsMarkers.iconData[iconId]
  -- local zone, wX, wY, wZ = GetUnitRawWorldPosition( "player" )

  local iconSize = ElmsMarkers.savedVars.selectedIconSize / 64.0
  local iconPlacement = OSI.CreatePositionIcon( wX, wY, wZ, texture, iconSize * OSI.GetIconSize(), {1,1,1}, 2.5, function( data )
      data.offset = 1 + 1 * math.sin( GetGameTimeMilliseconds() / 1000 * 7 )
    end
  )
  PlaySound(SOUNDS.BATTLEGROUND_ONE_MINUTE_WARNING)
  ElmsMarkers.UI.announcementBannerLabel:SetText("[Elms Markers] REGROUP!")
  ElmsMarkers.UI.announcementBanner:SetHidden(false)

  zo_callLater(function() 
    OSI.DiscardPositionIcon(iconPlacement)
    ElmsMarkers.UI.announcementBannerLabel:SetText("[Elms Markers] Sample text")
    ElmsMarkers.UI.announcementBanner:SetHidden(true)
    end
  , 3500)

  return {zone, wX, wY, wZ, iconId}
end

function ElmsMarkers.PreparePublish(isAdd) 
  local timeNow = GetGameTimeMilliseconds()
  if(ElmsMarkers.lastPingTime == nil or (timeNow - ElmsMarkers.lastPingTime > ElmsMarkers.PING_RATE)) then
    if AreUnitsEqual(GetGroupLeaderUnitTag(), 'player') then
      local location
      if isAdd then
        location = ElmsMarkers.PlaceAtMe()
      else
        location = ElmsMarkers.RemoveNearMe()
      end

      ElmsMarkers.EncodeEnqueuePublish(location, isAdd, false)
      return location
    else
      CHAT_SYSTEM:AddMessage("[ElmsMarkers] You must be the group lead to publish markers!")
    end
  else 
    CHAT_SYSTEM:AddMessage("[ElmsMarkers] You're publishing too quickly! Publish not sent, try again later.")
  end
end

function ElmsMarkers.PrepareRendezvous()
  local timeNow = GetGameTimeMilliseconds()
  if(ElmsMarkers.lastPingTime == nil or (timeNow - ElmsMarkers.lastPingTime > ElmsMarkers.PING_RATE)) then
    if AreUnitsEqual(GetGroupLeaderUnitTag(), 'player') then
      local zone, wX, wY, wZ = GetUnitRawWorldPosition("player")
      local iconId = 13 --arrow
      ElmsMarkers.EncodeEnqueuePublish({zone, wX, wY, wZ, iconId}, true, true)
      ElmsMarkers.PlaceRendezvousAt({zone, wX, wY, wZ, iconId}, true)
    else
      CHAT_SYSTEM:AddMessage("[ElmsMarkers] You must be the group lead to send group commands!")
    end
  else 
    CHAT_SYSTEM:AddMessage("[ElmsMarkers] You're sending group commands too quickly! Command not sent, try again later.")
  end
end

function ElmsMarkers.EncodeEnqueuePublish(location, isAdd, isRendezvous)
  local zone, wX, wY, wZ, iconId = unpack(location)
  -- ping 1: wX iconId
  -- ping 2: wZ zone
  -- ping 3: wY isAdd/isRemove endSignature

  local addBit = isAdd and 2 or 1
  local endSignature = isRendezvous and 9 or 3

  local dataPacket1 = wX * 100000 + iconId * 10 + 1
  local dataPacket2 = wZ * 100000 + zone * 10 + 2
  local dataPacket3 = wY * 1000 + addBit * 100 + endSignature
  
  ElmsMarkers.dataQueue = {dataPacket1, dataPacket2, dataPacket3}
  EVENT_MANAGER:RegisterForUpdate(ElmsMarkers.name .. 'Cycle', 100, ElmsMarkers.ShareData)
  ElmsMarkers.lastPingTime = GetGameTimeMilliseconds()
end

function ElmsMarkers.ShareData() 
  dataPacket = table.remove(ElmsMarkers.dataQueue, 1)
  if(dataPacket) then
    ElmsMarkers.shareMapData:SendData(dataPacket)
  else
    EVENT_MANAGER:UnregisterForUpdate(ElmsMarkers.name..'Cycle')
  end
end

function ElmsMarkers.RemoveExactMarkerAt(location)
  local zone, wX, wY, wZ = unpack(location)
  local zoneIcons = ElmsMarkers.placedIcons[zone]
  if(not zoneIcons) then return end

  for k,v in pairs(ElmsMarkers.savedVars.positions[zone]) do
    if v[1] == wX and v[2] == wY and v[3] == wZ then
      ElmsMarkers.savedVars.positions[zone][k] = nil
      ElmsMarkers.CreateConfigString()
    end
  end

  for k, v in pairs(ElmsMarkers.placedIcons[zone]) do
    if v.x == wX and v.y == wY and v.z == wZ then
      OSI.DiscardPositionIcon(v)
      ElmsMarkers.placedIcons[zone][k] = nil
    end
  end
end