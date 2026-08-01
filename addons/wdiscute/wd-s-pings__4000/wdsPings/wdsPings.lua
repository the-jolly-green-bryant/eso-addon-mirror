---@diagnostic disable: trailing-space
wdsPings = {}
wdsPings.name = "wdsPings"
wdsPings.ImportString = ""
wdsPings.SenderPosition = {}

--Export to elms
--add option to choose sound
--detect when player is standing still and auto share pings
--delete ping close to where youre looking and share that deleted ping
--shapes?
--animations
--  -none
--  -pulse
--  -up and down
--  -flash color


function wdsPings.Initialize()

  EVENT_MANAGER:UnregisterForEvent(wdsPings.name, EVENT_ADD_ON_LOADED)

  --SUBSCRIBE TO DATA SHARE MAP NUMBER
  wdsPings.share = LibDataShare:RegisterMap("wdsPings", 31, wdsPings.CreatePingReceived)

  wdsPings.submenuLocked = false
  wdsPings.headerLocked = false
  wdsPings.headerString = ""
  wdsPings.array = {}
  
  local fakePing = {}

  fakePing[1] = {
    [1] = 11,
    [2] = 11,
    [3] = 11,
    [4] = "wdsPings/icons/default_ping.dds",
  }
  fakePing[2] = {
    [1] = 11,
    [2] = 11,
    [3] = 11,
    [4] = "wdsPings/icons/default_ping.dds",
  }

  wdsPings.defaultSavedVariables =
  {
    pingIconTemp = "wdsPings/icons/default_ping.dds",
    pingIconPerm = "wdsPings/icons/default_ping_purple.dds",
    showTempDungeons = "Everyone",
    showTempTrials = "Everyone",
    showPermDungeons = "Everyone",
    showPermTrials = "Group Leader Only",
    scaleTempPing = 8,
    scalePermPing = 8,
    SavedPings = {},
    ESS = false
  }

  wdsPings.savedVariables = ZO_SavedVars:NewAccountWide("wdsPingsVariables", 23, nil, wdsPings.defaultSavedVariables,
    GetWorldName())


  wdsPings.savedVariables.SavedPings[363] = fakePing

  wdsPings.settings =
  {
    pingIconTemp = wdsPings.savedVariables.pingIconTemp,
    pingIconPerm = wdsPings.savedVariables.pingIconPerm,
    showTempDungeons = wdsPings.savedVariables.showTempDungeons,
    showTempTrials = wdsPings.savedVariables.showTempTrials,
    showPermDungeons = wdsPings.savedVariables.showPermDungeons,
    showPermTrials = wdsPings.savedVariables.showPermTrials,
    scaleTempPing = wdsPings.savedVariables.scaleTempPing,
    scalePermPing = wdsPings.savedVariables.scalePermPing,
    SavedPings = wdsPings.savedVariables.SavedPings
  }

  wdsPings.optionsTable = {}

  if(ElmsMarkers == nil and wdsPings.savedVariables.ESS == true)then
    ElmsMarkers = 1;
  end

  SLASH_COMMANDS["/wd"] = wdsPings.SlashCommand

  --starts LAM so that message doesnt show in chat??? unsure why that is but this fixes it
  wdsPings.statLAM()


end

function wdsPings.SlashCommand(input)
  local LAM = LibAddonMenu2
  input = string.lower(input)
  local command = input:match("%w+")
  if (command == nil) then
    LAM:OpenToPanel(wdsPings.panel)
    return
  end
  local rest = input.sub(input, string.len(command) + 2, 100)

  if (command == "debug") then

    --wdsPings.share:SendData(30000000001)
    --local _, senderx, sendery, senderz = GetUnitRawWorldPosition('player')
    --OSI.CreatePositionIcon(senderx, sendery, senderz, wdsPings.textures[1], 80, OSI.BASECOLOR, -0.3)

  end

  if (command == "debug2") then
    --wdsPings.array[1].data.texture = "wdsPings/icons/Arrow_aqua.dds"
    --OSI.UpdateIconData(wdsPings.array[1], "wdsPings/icons/Arrow_orange.dds", OSI.BASECOLOR, nil)
  end  
  
  if (command == "debug3") then
    --OSI.DiscardPositionIcon(wdsPings.array[i])
  end

  if (command == "clear" or command == "2" or command == "c" or command == "remove" or command == "x") then
    wdsPings.RemovePing("0", true)
    return
  end

  if (command == "clearall" or command == "ca" or command == "removeall" or command == "xx") then
    if (IsUnitGroupLeader('player') == false) then
      d("|cEAC8E9[wd's pings] |cee5555[!] group leader is required to clear everyone's pings [!]")
      return
    end
    wdsPings.RemovePing("1", true)
    return
  end

  if (command == "t" or command == "ping" or command == "temp" or command == "temporary") then
    wdsPings.CreatePingLocal("1")
    return
  end

  if (command == "p" or command == "perm" or command == "permanent") then
    wdsPings.CreatePingLocal("2")
    return
  end

  if (command == "s" or command == "share") then
    if (IsUnitGroupLeader('player') == false) then
      d("|cEAC8E9[wd's pings] |cee5555[!] group leader is required to share your pings [!]")
      return
    end
    wdsPings.ShareClose()

  end

  if (command == "pos") then
    d(GetUnitRawWorldPosition("player"))
  end

  if (command == "d" or command == "data") then
    --/wd d 10001450153
    d("input data: " .. rest)
    if (rest == "") then
      wdsPings.share:QueueData(10001450153)
      d("no number after /wd d, defaulting to sending 10001450153")
    else
      local intToSend = tonumber(rest)
      wdsPings.share:QueueData(intToSend)
    end
    return
  end

  if (command == "r" or command == "receive") then
    --/wd d 10001450153
    d("receiving input data: " .. rest)
    if (rest == "") then
      d("no number after /wd r, defaulting to receiving 10001450153")
      wdsPings.CreatePingReceived('player', 10001450153)
    else
      local intToSend = tonumber(rest)
      d("triggering received data with " .. rest)
      wdsPings.CreatePingReceived('player', rest)
    end
    return
  end

  if (command == "ess") then

    wdsPings.savedVariables.ESS = not wdsPings.savedVariables.ESS
    ReloadUI()

  end

end

function wdsPings.UpdatePingsAnim(icon)

  if(false)then
    if(icon.counter == nil)then
      icon.counter = 300
      icon.direction = "down"
    end
  
    if(icon.counter < 80)then
      icon.direction = "stop"
    end
  
    if(icon.direction == "down")then
      icon.counter = icon.counter - 3
      --icon.data.texture = "wdsPings/icons/Arrow_aqua.dds"
    end
  
    icon.data.size = icon.counter
    --icon.data.color = {math.random(), math.random(), math.random()}
  
  end
end

function wdsPings.getTextureIdFromString(textureString)
  for i = 1, #wdsPings.textures do
    if (textureString == wdsPings.textures[i]) then
      return i
    end
  end
end

function wdsPings.CreatePingReceived(tag, data)
  local senderzoneid, senderx, sendery, senderz = GetUnitRawWorldPosition(tag)
  local playerzoneid, _, _, _ = GetUnitRawWorldPosition('player')

  --ignores ping if not on the same zone as sender
  if(playerzoneid ~= senderzoneid)then
    return
  end

  -- MAX VALUE 62331613569
  -- Example:  10099120063
  -- 1        00          99         120       0       63
  -- LENGTH   future?     ICON       VALUE     SIGN    RADIANSPERCENTAGE

  local length                            = string.sub(data, 1, 1)   --1 = temp, 2 = permanent, 3 = remove pings & other stuff, 4 = mass share
  local icon                              = string.sub(data, 4, 5)   --0 to 99 icon texture
  local value                             = string.sub(data, 6, 8)   --hardcoded distance to spawn ping calculated from camera angle on ping spawn
  local sign                              = string.sub(data, 9, 9)   --whether the radians are positive or negative
  local radiansPercentage                 = string.sub(data, 10, 11) --from 0 to 100 % of 0 to pi
  local isSenderGroupLeader               = IsUnitGroupLeader(tag)

  if (length == "3") then
    if(radiansPercentage == "01")then
      d("|cEAC8E9[wd's pings] Receiving pings data... Do not open your map.")
      wdsPings.SenderPosition[1] = senderx
      wdsPings.SenderPosition[2] = sendery
      wdsPings.SenderPosition[3] = senderz
      return
    end

    if(radiansPercentage == "02")then
      --30000000002
      local pingsreceived = string.sub(data, 2, 4)
      d("|cEAC8E9[wd's pings] All data received. [" .. pingsreceived .. "] pings loaded.")
      return
    end

    if(isSenderGroupLeader == true)then
      for k = 1, #wdsPings.array do
        OSI.DiscardPositionIcon(wdsPings.array[k])
      end
      for j = 1, #wdsPings.array do
        table.remove(wdsPings.array, 1)
      end
      d("|cEAC8E9[wd's pings] Your group leader has cleared all pings for everyone.")
      return
    end

  end
  
  --if ping received is from share functionality
  if(length == "4") then
    wdsPings.CreatePingShared(tag, data)
    return
  end

  --cancels ping if it was a remove
  if (length == "3") then return end
  --temp dungeons settings
  if (length == "1" and GetGroupSize() < 5) then
    if (wdsPings.settings.showTempDungeons == "Group Leader Only" and isSenderGroupLeader == false) then return end
    if (wdsPings.settings.showTempDungeons == "None") then return end
  end
  --temp trials settings
  if (length == "1" and GetGroupSize() > 4) then
    if (wdsPings.settings.showTempTrials == "Group Leader Only" and isSenderGroupLeader == false) then return end
    if (wdsPings.settings.showTempTrials == "None") then return end
  end
  --perm dungeons settings
  if (length == "2" and GetGroupSize() < 5) then
    if (wdsPings.settings.showPermDungeons == "Group Leader Only" and isSenderGroupLeader == false) then return end
    if (wdsPings.settings.showPermDungeons == "None") then return end
  end
  --perm trials settings
  if (length == "2" and GetGroupSize() > 4) then
    if (wdsPings.settings.showPermTrials == "Group Leader Only" and isSenderGroupLeader == false) then return end
    if (wdsPings.settings.showPermTrials == "None") then return end
  end
  --get scale from settings
  local scale = 10
  if (length == "1") then
    scale = wdsPings.settings.scaleTempPing
  else
    scale = wdsPings.settings.scalePermPing
  end

  local senderCameraHeading = math.pi * radiansPercentage / 100
  if (sign == "0") then
    senderCameraHeading = -senderCameraHeading
  end

  senderx = senderx + (math.sin(senderCameraHeading) * (tonumber(value) * 10))
  senderz = senderz + (math.cos(senderCameraHeading) * (tonumber(value) * 10))

  local iconOSI = OSI.CreatePositionIcon(senderx, sendery, senderz, wdsPings.textures[tonumber(icon)], scale * 10,
    OSI.BASECOLOR, -0.3)

  --saves icon in array to delete with /wd clear
  wdsPings.array[#wdsPings.array + 1] = iconOSI

  --if temporary, remove after 3500
  --CHANGE TO CUSTOMIZABLE TIMER LATER
  if (length == "1") then
    zo_callLater(
      function()
        OSI.DiscardPositionIcon(iconOSI)

        for i = 1, #wdsPings.array do
          if (wdsPings.array[i] == iconOSI) then
            table.remove(wdsPings.array, i)
          end
        end
      end, 3500)

    PlaySound("Campaign_Ready_Check")
  else
    PlaySound("Campaign_Ready_Check")
  end
end

function wdsPings.CreatePingShared(tag, data)
  local senderzoneid, _, _, _ = GetUnitRawWorldPosition(tag)
  local senderx = wdsPings.SenderPosition[1]
  local sendery = wdsPings.SenderPosition[2]
  local senderz = wdsPings.SenderPosition[3]
  local playerzoneid, _, _, _ = GetUnitRawWorldPosition('player')

  if(playerzoneid ~= senderzoneid)then
    d("|cEAC8E9[wd's pings] Your group leader is trying to share their pings but you are not on the same zone.")
    return
  end

  -- MAX VALUE 62331613569
  -- Example:  4073305938         
  --4    07   18   752        327
  --TYPE ID   Y    DISTANCE   RADPERCENT

  local type                              = string.sub(data, 1, 1)   --always gonna be 4 since shared = 4
  local icon                              = string.sub(data, 2, 3)   --0 to 99 icon texture
  local offsety                           = string.sub(data, 4, 5)   --distance of ping in the direction of RADPERCENT * 10
  local distance                          = string.sub(data, 6, 8)   --whether the radians are positive or negative
  local radpercent                        = string.sub(data, 9, 11)   --whether the radians are positive or negative
  local isSenderGroupLeader               = IsUnitGroupLeader(tag)   --always true if this function is being ran normaly
  
  --fix up data received
  local _, rem = math.modf(offsety / 2)
  if (rem == 0) then
    offsety = offsety
  else
    offsety = offsety * -1
  end
  local tex = wdsPings.textures[tonumber(icon)]
  distance = distance * 10
  offsety = offsety * 10
  local radpluspi = tonumber(radpercent) * (math.pi * 2) / 999
  radpluspi = radpluspi - math.pi

  local x = math.sin(radpluspi) * distance
  local z = math.cos(radpluspi) * distance
  x = tonumber(x) + senderx
  offsety = tonumber(offsety) + sendery
  z = tonumber(z) + senderz
  
  PlaySound("Campaign_Ready_Check")

  local iconOSI = OSI.CreatePositionIcon(tonumber(x), tonumber(offsety), tonumber(z), tex, wdsPings.settings.scalePermPing * 10,
    OSI.BASECOLOR, -0.3)

  --saves icon in array
  wdsPings.array[#wdsPings.array + 1] = iconOSI

end

function wdsPings.CreatePingLocal(length)
  local zoneid, x, y, z = GetUnitRawWorldPosition("player")

  local cameraHeading = GetPlayerCameraHeading() - math.pi
  local xsin = math.sin(cameraHeading)
  local zcos = math.cos(cameraHeading)

  --TODO check if i can get if its positive angle or negative compared to horizon
  local uX, uY, uZ = OSI.ctrl:Get3DRenderSpaceUp()
  local angle = uY

  --TOOD there's probably some math way to do this but i had to hard code because i dont know math
  --max range: 5000
  local value = "500"
  if true then
    if angle > 0.999 and angle < 0.9995 then
      value = "400"
    end
    if angle > 0.9985 and angle < 0.999 then
      value = "350"
    end
    if angle > 0.998 and angle < 0.9985 then
      value = "315"
    end
    if angle > 0.996 and angle < 0.998 then
      value = "280"
    end
    if angle > 0.993 and angle < 0.996 then
      value = "240"
    end
    if angle > 0.99 and angle < 0.993 then
      value = "200"
    end
    if angle > 0.987 and angle < 0.99 then
      value = "170"
    end
    if angle > 0.985 and angle < 0.987 then
      value = "150"
    end
    if angle > 0.983 and angle < 0.985 then
      value = "135"
    end
    if angle > 0.98 and angle < 0.983 then
      value = "120"
    end
    if angle > 0.97 and angle < 0.98 then
      value = "100"
    end
    if angle > 0.96 and angle < 0.97 then
      value = "085"
    end
    if angle > 0.94 and angle < 0.96 then
      value = "075"
    end
    if angle > 0.93 and angle < 0.94 then
      value = "065"
    end
    if angle > 0.92 and angle < 0.93 then
      value = "057"
    end
    if angle > 0.90 and angle < 0.92 then
      value = "050"
    end
    if angle > 0.85 and angle < 0.90 then
      value = "045"
    end
    if angle > 0.80 and angle < 0.85 then
      value = "038"
    end
    if angle > 0.75 and angle < 0.80 then
      value = "032"
    end
    if angle > 0.70 and angle < 0.75 then
      value = "028"
    end
    if angle > 0.6 and angle < 0.7 then
      value = "020"
    end
    if angle > 0.5 and angle < 0.6 then
      value = "018"
    end
    if angle > 0.4 and angle < 0.5 then
      value = "014"
    end
    if angle > 0.3 and angle < 0.4 then
      value = "011"
    end
    if angle > 0.2 and angle < 0.3 then
      value = "007"
    end
    if angle > 0.1 and angle < 0.2 then
      value = "005"
    end
    if angle > 0.0 and angle < 0.1 then
      value = "000"
    end
  end

  local sign
  if (cameraHeading > 0) then
    sign = 1
  else
    sign = 0
  end

  --slightly more accurate rotation than sending raw radians
  local radiansPercentage = math.abs(cameraHeading) * 100 / math.pi
  radiansPercentage = string.sub(radiansPercentage, 1, 2)

  --adds a 0 if radiansPercentage is single digit so data string stays consistent in size
  if (tonumber(radiansPercentage) < 10) then
    radiansPercentage = "0" .. radiansPercentage
  end

  -- MAX VALUE 62331613569
  -- Example:  10099120063
  -- 1        00          99         120       0       63
  -- LENGTH   future?     ICON       VALUE     SIGN    RADIANSPERCENTAGE

  local pingString = 0

  if (length == "1") then
    PlaySound("Campaign_Ready_Check")  
    pingString = wdsPings.getTextureIdFromString(wdsPings.settings.pingIconTemp)
  else
    PlaySound("Campaign_Ready_Check")  
    pingString = wdsPings.getTextureIdFromString(wdsPings.settings.pingIconPerm)
  end

  local pingString2 = "00"
  if (pingString < 10) then
    pingString2 = "0" .. tostring(pingString)
  else
    pingString2 = tostring(pingString)
  end

  local icontexture
  if (length == "1") then
    icontexture = wdsPings.settings.pingIconTemp
  else
    icontexture = wdsPings.settings.pingIconPerm
  end

  --get scale from settings
  local scale = 1
  if (length == "1") then
    scale = wdsPings.settings.scaleTempPing
  else
    scale = wdsPings.settings.scalePermPing
  end

  local valueFinal = tonumber(value) * 10

  local extraDataForFutureUse = "00"
  local dataToSend = length .. extraDataForFutureUse .. pingString2 .. value .. sign .. radiansPercentage
  local dataToSendint = tonumber(dataToSend)

  x = x + (xsin * tonumber(valueFinal))
  z = z + (zcos * tonumber(valueFinal))

  wdsPings.share:SendData(dataToSendint)
  
  --TODO PLAY AROUND WITH THIS
  local callback = nil

  --spawn icon using OSI
  local iconOSI = OSI.CreatePositionIcon(x, y, z, icontexture, scale * 10, OSI.BASECOLOR, 0, callback)
  --this ^^^^
  --saves icon returned by OSI in array so i have my own version of the pings collection
  wdsPings.array[#wdsPings.array + 1] = iconOSI
  iconOSI.counter = nil
  iconOSI.callback = function() wdsPings.UpdatePingsAnim(iconOSI) end

  --if temp then delete after 3500ms
  --TODO: CHANGE 3500 TO SOMETHING CONFIGURABLE
  if (length == "1") then
    zo_callLater(
      function()
        OSI.DiscardPositionIcon(iconOSI)

        --remove from array, should prob change the name at some point (edit 2 weeks later: i will not)
        for i = 1, #wdsPings.array do
          if (wdsPings.array[i] == iconOSI) then
            table.remove(wdsPings.array, i)
          end
        end
      end, 3500)
  end
end

function wdsPings.RemovePing(type, showInChat)
  for i = 1, #wdsPings.array do
    OSI.DiscardPositionIcon(wdsPings.array[i])
    
  end
  for i = 1, #wdsPings.array do
    table.remove(wdsPings.array, 1)
  end
  --type 0 = local
  --type 1 = everyone, requires raid lead to trigger

  if (type == "1") then
    if (IsUnitGroupLeader('player')) then
      if (showInChat == true) then d("|cEAC8E9[wd's pings] You have removed all pings for everyone.") end
      wdsPings.share:QueueData(3000000000)
    else
      if (showInChat == true) then
        d(
          "|cEAC8E9[wd's pings] Only group leaders may clearall. Use |cff0000/wd |cEAC8E9 if you meant to clear only your pings.")
      return
      end
    end
  end

  if (type == "0") then
    if (showInChat == true) then d("|cEAC8E9[wd's pings] You have removed all pings for yourself only.") end
  end
end

function wdsPings.OnAddOnLoaded(event, addonName)
  if addonName == wdsPings.name then
    EVENT_MANAGER:UnregisterForEvent(wdsPings.name, EVENT_ADD_ON_LOADED)

    wdsPings.Initialize()
  end
end

ZO_CreateStringId("SI_BINDING_NAME_PING_TEMP", "Temporary Ping")
ZO_CreateStringId("SI_BINDING_NAME_PING_PERM", "Permanent Ping")
ZO_CreateStringId("SI_BINDING_NAME_CLEAR_PINGS", "Clear Pings")
ZO_CreateStringId("SI_BINDING_NAME_CLEAR_PINGS_ALL", "Clear Pings for Everyone")


EVENT_MANAGER:RegisterForEvent(wdsPings.name, EVENT_ADD_ON_LOADED, wdsPings.OnAddOnLoaded)
