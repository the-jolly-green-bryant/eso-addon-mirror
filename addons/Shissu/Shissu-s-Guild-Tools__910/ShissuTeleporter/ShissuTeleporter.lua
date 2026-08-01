-- Shissu Guild Tools Addon
-- ShissuTeleporter
--
-- Version: v1.6.1
-- Last Update: 14.12.2020
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

-- Framework Globals
local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local blue = _globals["blue"]
local green = _globals["green"]
local yellow = _globals["yellow"]
local red = _globals["red"]

local _addon = {}
_addon.Name = "ShissuTeleporter"
_addon.Name_2 = "ShissuTeleporter2"
_addon.Version = "1.6.1"
_addon.lastUpdate = "14.12.2020"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s Teleporter"                                               
_addon.cache = {}

local _selected = {}
local ShissuTeleporter = ZO_SocialListKeyboard:Subclass()

-- Framework Functions
local cutStringAtLetter = ShissuFramework["functions"]["datatypes"].cutStringAtLetter
local createFlatWindow = ShissuFramework["interface"].createFlatWindow
local createFlatButton = ShissuFramework["interface"].createFlatButton
local getWindowPosition = ShissuFramework["interface"].getWindowPosition
local saveWindowPosition = ShissuFramework["interface"].saveWindowPosition
local setPanel = ShissuFramework["setPanel"]
local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version, _addon.lastUpdate)
_addon.controls = {}

ShissuTeleporter.SORT_KEYS = {
  ["name"] = {},
}

local _L = ShissuFramework["func"]._L(_addon.Name)
          
function _addon.createControls()
  local removeKey = ShissuFramework["functions"]["datatypes"].removeKey

  local controls = _addon.controls 
  controls[#controls+1] = {
    type = "title",
    name = _L("INFO"),
  }

  controls[#controls+1] = {
    type = "description",
    text = _L("DESC"),
  }

  controls[#controls+1] = {
    type = "description",
    text = _L("DESC2") .. "\n\n\n\n\n",
  }

  local accountArr = { _L("NAME_2"), _L("NAME_3"), _L("NAME_4"), }
  
  local possibleZone = {}
  for mapId = 1, GetNumMaps(), 1 do
    local zoneName = GetMapInfo(mapId)   
    table.insert(possibleZone, cutStringAtLetter(zoneName, "^"))
  end

  controls[#controls+1] = {
    type = "title",
    name = _L("STANDARD"),
  }

  controls[#controls+1] = {
    type = "description",
    text = _L("STANDARD_DESC"),
  }

  controls[#controls+1] = {
    type = "combobox",
    name = _L("STANDARD"),
    items = possibleZone or nil,
    getFunc = shissuTeleporter["standard"],
    setFunc = function(_, value)
      shissuTeleporter["standard"] = value
    end,
  }  

  controls[#controls+1] = {
    type = "title",
    name = _L("TELE_ADVERT"),
  }

  controls[#controls+1] = {
    type = "description",
    text = _L("DESC3") .. "\n",
  }

  controls[#controls+1] = {
    type = "slider", 
    name = _L("TELEIN"),
    minimum=10,
    maximum=60,
    steps=1,
    getFunc = shissuTeleporter["secondsToNext"] or 20,
    setFunc = function(value)
      shissuTeleporter["secondsToNext"] = value
    end,
  }        

  guildNames = {}
  local saveAdvertising = shissuTeleporter["advertising"]

  for key, text in pairs(saveAdvertising) do
    table.insert(guildNames, key)
  end

  for guildId=1, GetNumGuilds() do
    local gId = GetGuildId(guildId)
    local guildName = GetGuildName(gId) 
   
    if (saveAdvertising[guildName] == nil) then
      table.insert(guildNames, guildName)
    end
  end

  controls[#controls+1] = {
    type = "combobox",
    name = _L("ADVERTISING"),
    dynamic = true,
    items = guildNames,
    getFunc = shissuTeleporter["selected"],
    setFunc = function(_, value)
      shissuTeleporter["selected"] = value
      ShissuTeleportSelectedAdvertising.label:SetText(value)
      ShissuTeleportSelectedAdvertising.editbox:SetText(shissuTeleporter["advertising"][value] or value)
    end,
    deleteFunc = function(value)
      shissuTeleporter["advertising"] = removeKey(shissuTeleporter["advertising"], value)
      shissuTeleporter["selected"] = ""

      ShissuTeleportSelectedAdvertising.label:SetText("")
      ShissuTeleportSelectedAdvertising.editbox:SetText("")
    end,
  } 

  controls[#controls+1] = {
    type = "editbox",
    reference = "ShissuTeleportSelectedAdvertising",
    name = shissuTeleporter["selected"] or "",
    getFunc = shissuTeleporter["advertising"][shissuTeleporter["selected"]] or "",
    setFunc = function(value)
      shissuTeleporter["advertising"][shissuTeleporter["selected"]] = value 
    end,
  }   
end

function ShissuTeleporter:New(...)
  return ZO_SocialListKeyboard.New(self, ...)
end

function ShissuTeleporter:Initialize(control)     
  ZO_SocialListKeyboard.Initialize(self, control)

  control:SetHandler("OnEffectivelyHidden", function() self:OnEffectivelyHidden() end)

  ZO_ScrollList_AddDataType(self.list, 1, "ShissuTeleporterRow", 30, function(control, data) self:SetupRow(control, data) end)
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
end

function ShissuTeleporter:BuildMasterList()
  self.masterList = {} 

  -- Gruppe
  local groupList = _addon.getGroupZones()
  local sortedData = _addon.sortTable(groupList) 

  if (sortedData ~= false) then
    local numEntrys = #sortedData

    for i = 1, numEntrys do
      local data = {}
      data["name"] = red .. sortedData[i].displayName
      data["displayName"] = sortedData[i].displayName
      data["zone"] = sortedData[i].zoneName
      data["what"] = sortedData[i].what
      
      table.insert(self.masterList, data)
    end  
  end 
    
  -- Gilde
  local guildList = _addon.getGuildsZones()
  sortedData = _addon.sortTable(guildList)
  
  if (sortedData ~= false) then
    numEntrys = #sortedData

    for i = 1, numEntrys do
      local data = {}
      data["name"] = sortedData[i].zoneName
      data["displayName"] = sortedData[i].displayName
      data["zone"] = sortedData[i].zoneName
      data["what"] = sortedData[i].what
      
      if _selected["zone"] == sortedData[i].zoneName then
        data["zone"] = stdColor .. sortedData[i].zoneName
      end
      
      table.insert(self.masterList, data)
    end
  end  

  -- Freunde
  local friendList = _addon.getFriendsZones()
  sortedData = _addon.sortTable(friendList)
  
  if (sortedData ~= false) then
    numEntrys = #sortedData
    
    for i = 1, numEntrys do
      local data = {}
      data["name"] = yellow .. sortedData[i].displayName
      data["displayName"] = sortedData[i].displayName
      data["zone"] = sortedData[i].zoneName
      data["what"] = sortedData[i].what
      
      table.insert(self.masterList, data)
    end  
  end
  
end

function ShissuTeleporter:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)
    
  for i = 1, #self.masterList do
    if ((self.masterList[i].hidden == nil) or (self.masterList[i].hidden == false)) then
      local entry = self.masterList[i]
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1,  entry))
     end
  end
end

-- |H0:guild:46077|h[Legacy of Heaven] sucht neue deutschsprachige Mitspieler, die Spaß am Spiel haben. Zwangloses, gemeinsames Spielen mit einer Prise Schabernack von A-Z. Es spielt keine Rolle, wie lange Du schon zockst.|h Bei Interesse einfach anflüstern^^


function ShissuTeleporter:SetupRow(control, data)
  control.data = data
  
  local nameControl = control:GetNamedChild('Name')
  nameControl:SetText(data.name) 
end
        
function ShissuTeleporter:Refresh()
  ShissuTeleporter:BuildMasterList()
  self:RefreshData()
end

function ShissuTeleporter:UnlockSelection()
  ZO_SortFilterList.UnlockSelection(self)
  self:RefreshVisible()
end

function ShissuTeleporter:OnEffectivelyHidden()
  ClearMenu()
end

function ShissuTeleporter:Refresh()
  self:RefreshData()
end
                                                                              
function ShissuTeleporter_OnInitialized(self)
  ShissuTeleporter = ShissuTeleporter:New(self)
end

function ShissuTeleporterRowName_OnMouseUp(self)
  local parent = self:GetParent()
  local data = ZO_ScrollList_GetData(parent)

  _selected["displayName"] = data.displayName
  _selected["zone"] = data.zone
  _selected["what"] = data.what          
   
  ShissuTeleporter:Refresh()

  ShissuTeleporter_ButtonTeleport_LABEL:SetText(green .. data.zone) 

  ShissuTeleporter:BuildMasterList()
  ShissuTeleporter:Refresh()   
end

function ShissuTeleporterRowEnter(self)
  local parent = self:GetParent()
  local data = ZO_ScrollList_GetData(parent)

  self.cacheName = self:GetText()

  self:SetText(blue .. self.cacheName)

  ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, white .. data["displayName"] .. " (" .. stdColor .. data["zone"] .. white.. ")")
end

function ShissuTeleporterRowExit(self)
  self:SetText(self.cacheName)

  ZO_Tooltips_HideTextTooltip()
end

-- Zufallsteleport zu irgendeinen Gildenmitglied
function _addon.rndTeleport()
  _addon.clearSearchField()
  
  local data = _addon.getGuildsZones()
  local count = #data
  local rnd = math.random(0, count)  
  
  if (data[rnd].displayName ~= nil) then
    JumpToGuildMember(data[rnd].displayName)
  else
    _addon.rndTeleport()
  end
end

local advertisingActive = 0

-- /script ShissuTeleporterAdvertising:SetHidden(false)
function _addon.initAdvertising()
  ShissuTeleporterAdvertising_Version:SetText(_addon.formattedName .. " " .. _addon.Version)

  local control = GetControl("ShissuTeleporterAdvertising")

  createFlatWindow(
    "ShissuTeleporterAdvertising",
    control,  
    {330, 174}, 
    function() control:SetHidden(true) end,
    "Werbung"
  ) 

  saveWindowPosition(control, shissuTeleporter["adPosition"])
  getWindowPosition(control, shissuTeleporter["adPosition"])

  local ShissuTeleporterAdvertising_Button = createFlatButton("ShissuTeleporterAdvertising_Toggle", control, {200, 120}, {110, 30}, green .. "START", TOPLEFT)   
    
  ShissuTeleporterAdvertising_Button:SetHandler("OnMouseEnter", function(self) 
    if (advertisingActive == 0) then
      self:SetColor(119/255, 255/255, 112/255, 1)
    else
      self:SetColor(1, 0.48627451062202, 0.56078433990479, 1)
    end
  end) 
  
  ShissuTeleporterAdvertising_Button:SetHandler("OnMouseUp", function(self) 
    if (advertisingActive == 0) then
      self.label:SetText(red .. "STOP")
      self:SetColor(1, 0.48627451062202, 0.56078433990479, 1)
      advertisingActive = 1

      _addon.advertising()
    else
      self.label:SetText(green .. "START")
      self:SetColor(119/255, 255/255, 112/255, 1)
      advertisingActive = 0

      EVENT_MANAGER:UnregisterForUpdate("SGT_ADVERT_COUNT")    
    end
  end)

  ShissuTeleporterAdvertising_CurrentX:SetText(_addon.getPlayerZone())
end

function _addon.getPlayerZone()
  local playerZone = GetUnitZone('player')

  if (playerZone ~= nil) then
    playerZone = cutStringAtLetter(playerZone, "^")                                                     
  end

  return playerZone
end

function _addon.advertising()
  local data = _addon.getGuildsZones()
  local zoneData = {}
  local cacheData = {}
  local playerZone = _addon.getPlayerZone()

  -- Nach Zonennamen umsortieren
  for i = 1, #data do
    zoneData[data[i]["zoneName"]] = data[i]["displayName"]
    cacheData[i] = { data[i]["zoneName"], data[i]["gId"], data[i]["mId"] }
    --d(GetGuildMemberCharacterInfo(data[i]["gId"], data[i]["mId"]))
  end  

  data = zoneData
  zoneData = nil

  local zoneName = GetUnitZone('player')
  local cacheAvailable = #cacheData
  local count = 1

  local secondsToNext = shissuTeleporter["secondsToNext"] or 20

  EVENT_MANAGER:RegisterForUpdate("SGT_ADVERT_COUNT", 1000, function()   
    ShissuTeleporterAdvertising_CurrentX:SetText(_addon.getPlayerZone())

    if (secondsToNext <= 5) then
      ShissuTeleporterAdvertising_InX:SetText(red .. secondsToNext)
    else
      ShissuTeleporterAdvertising_InX:SetText(secondsToNext)
    end

    local zone = cacheData[count][1]
    ShissuTeleporterAdvertising_NextX:SetText(green .. zone)

    if (secondsToNext == 0) then
      count = count + 1
      secondsToNext = (shissuTeleporter["secondsToNext"] or 20)
    end

    if (secondsToNext == 8) then
      local gId = cacheData[count][2]
      local mId = cacheData[count][3]
  
      local _, _, memberZone, _, _ = GetGuildMemberCharacterInfo(gId, mId)
      memberZone = cutStringAtLetter(memberZone, "^")

      --d("Teleport: " .. zone .. " (" .. data[zone] .. ")")
      --d("Aktuell: " .. memberZone)
  
      if (memberZone == zone) then
        JumpToGuildMember(data[zone])
        ZO_ChatWindowTextEntryEditBox:SetText("/zone " .. shissuTeleporter["advertising"][shissuTeleporter["selected"]]
          or "Download Shissu Guild Tools :-)"
        )
     end

      if count == cacheAvailable then
        ShissuTeleporterAdvertising_InX:SetText(green .. "FERTIG")
        ShissuTeleporterAdvertising_NextX:SetText("...")

        EVENT_MANAGER:UnregisterForUpdate("SGT_ADVERT_COUNT")    
      end
    end
    
    secondsToNext = secondsToNext - 1
  end)    
end

-- * Initialisierung                                                                         
function _addon.initialized()
  _addon.createControls()

  ShissuFramework["interface"].initChatButton()

  SLASH_COMMANDS["/rndteleport"] = _addon.rndTeleport
  SLASH_COMMANDS["/rnd"] = _addon.rndTeleport
  SLASH_COMMANDS["/teleport"] = _addon.toggleWindow
  SLASH_COMMANDS["/tele"] = _addon.toggleWindow
  SLASH_COMMANDS["/advertising"] = function() ShissuTeleporterAdvertising:SetHidden(false) end
  SLASH_COMMANDS["/standardtele"] = _addon.standardTeleport

  _addon.cache.ImperialCity = cutStringAtLetter(GetMapInfo(26), "^")
  _addon.cache.Cyrodiil = cutStringAtLetter(GetMapInfo(14), "^")
  _addon.cache.ColdHarbour = cutStringAtLetter(GetMapInfo(23), "^")
  _addon.cache.Craglore = cutStringAtLetter(GetMapInfo(25), "^")

  ShissuTeleporter_Version:SetText(_addon.formattedName .. " " .. _addon.Version)

  local control = GetControl("ShissuTeleporter")
    
  ShissuTeleporter_ButtonTeleport = createFlatButton("ShissuTeleporter_ButtonTeleport", control, {160, 60}, {160, 30}, white .. _L("TELE"), TOPLEFT)   
  ShissuTeleporter_ButtonRandom = createFlatButton("ShissuTeleporter_ButtonRandom", ShissuTeleporter_ButtonTeleport, {0, 40}, {160, 30}, white .. _L("RND"))    
  ShissuTeleporter_ButtonGrp = createFlatButton("ShissuTeleporter_ButtonGrp", ShissuTeleporter_ButtonRandom, {0, 50}, {160, 30}, _L("GRP"), nil, {1, 0.48627451062202, 0.56078433990479})    
  ShissuTeleporter_ButtonHouse = createFlatButton("ShissuTeleporter_ButtonHouse", ShissuTeleporter_ButtonGrp, {0, 50}, {160, 30}, _L("HOUSE"), nil, {1, 0.96078431606293, 0.50196081399918})     
  ShissuTeleporter_ButtonRefresh = createFlatButton("ShissuTeleporter_ButtonRefresh", ShissuTeleporter_ButtonHouse, {0, 50}, {160, 30}, _L("REFRESH"))    

  ShissuTeleporter_ButtonAdvertising = createFlatButton("ShissuTeleporter_AdvertisingRefresh", ShissuTeleporter_ButtonRefresh, {0, 50}, {160, 30}, white .. _L("ADVERTISING"))    

  ShissuTeleporter_Legends:ClearAnchors()
  ShissuTeleporter_Legends:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 170, -100)

  ShissuTeleporter_FilterText:SetHandler("OnTextChanged", function()  
    ShissuTeleporter:BuildMasterList()
    ShissuTeleporter:Refresh()       
  end) 
  
  ShissuTeleporter_FilterText:SetDrawLayer(1)
  
  createFlatWindow(
    "ShissuTeleporter",
    control,  
    {330, 500}, 
    function() ShissuTeleporter_FilterText:SetText("") control:SetHidden(true) end,
    "Teleporter"
  ) 
  
  ShissuTeleporter_Position:ClearAnchors()
  ShissuTeleporter_Position:SetAnchor(TOPLEFT, ShissuTeleporter_TitleLine, TOPLEFT, 2, 5)
  ShissuTeleporter_FilterText:SetDrawLayer(1)

  ShissuTeleporter_Legends:SetText(
    white .. _L("LEGEND1") .. "\n" ..
    "- " .. yellow .. _L("LEGEND2") .. white .. "\n" ..
    "- " .. red .. _L("LEGEND3")
  )
  
	EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED, function() 
    local zoneName = GetUnitZone('player')
      
    if (zoneName ~= nil) then
      zoneName = cutStringAtLetter(zoneName, "^")
      ShissuTeleporter_Position:SetText(stdColor .. zoneName)
    end
  end) 
      
  local zoneName = GetUnitZone('player')
    
  if (zoneName ~= nil) then
    zoneName = cutStringAtLetter(zoneName, "^")                                                     
    ShissuTeleporter_Position:SetText(stdColor .. zoneName)
  end

  saveWindowPosition(control, shissuTeleporter["position"])
  getWindowPosition(control, shissuTeleporter["position"])

  ShissuTeleporter_ButtonRefresh:SetHandler("OnMouseUp", function() 
    ShissuTeleporter:BuildMasterList()
    ShissuTeleporter:Refresh()     
  end)
 
  ShissuTeleporter_ButtonAdvertising:SetHandler("OnMouseUp", function() 
    ShissuTeleporterAdvertising:SetHidden(false) 

    local control = GetControl("ShissuTeleporter")
    control:SetHidden(true)
  end)
  
  ShissuTeleporter_ButtonTeleport:SetHandler("OnMouseUp", _addon.toPlayer)
  ShissuTeleporter_ButtonRandom:SetHandler("OnMouseUp", function(self) _addon.rndTeleport() end) 
  ShissuTeleporter_ButtonGrp:SetHandler("OnMouseUp", function(self) JumpToGroupLeader() end) 
  ShissuTeleporter_ButtonHouse:SetHandler("OnMouseUp", function(self) 
    local houseId = GetHousingPrimaryHouse()
    
    if (houseId == nil) then return end
		  RequestJumpToHouse(houseId)
  end)  
   
  ShissuTeleporter = ShissuTeleporter:New(control)
  ShissuTeleporter:BuildMasterList()
  ShissuTeleporter:Refresh()     
  ShissuTeleporterHeadersName:SetHidden(true)

  control:SetHidden(true)
  
  _addon.initAdvertising()
end

function _addon.standardTeleport()
  local _P = ShissuFramework["functions"]["chat"].print
  local standard = shissuTeleporter["standard"]

  if (standard == nil) then
    _P(_L("STANDARD_SET"), {}, _addon.formattedName)
    return
  end

  local zones = _addon.getGuildsZones()
  local found = 0
  for i=1, #zones do
    if (zones[i].zoneName == standard) then
      JumpToGuildMember(zones[i].displayName)
      found = 1
      break
    end
  end
  
  if (found == 0) then
    _P(_L("STANDARD_NOPOS"), {red .. standard, white}, _addon.formattedName)
  end
end

function _addon.getGuildsZones()
  local playerZone = cutStringAtLetter(GetPlayerLocationName() , "^") 
  local searchTerm = ShissuTeleporter_FilterText:GetText()  or ""
  local availableZones = {}
  
  -- DBG 
  --for mapId = 1, GetNumMaps(), 1 do
  --  local zoneName = GetMapInfo(mapId)
  --  d(mapId .. " ---- " .. zoneName)
  --end
  
  -- Gilde
  local ownName = GetDisplayName()   
  
  for guildId = 1, GetNumGuilds() do
    if #availableZones == GetNumMaps() - 2 then break end
    local guildId = GetGuildId(guildId)
    
    for memberId = 1, GetNumGuildMembers(guildId) do
      local _, _, memberZone, _, memberAlliance = GetGuildMemberCharacterInfo(guildId, memberId)
      local memberName, _, _ , memberStatus = GetGuildMemberInfo(guildId, memberId)
    
      if memberStatus ~= PLAYER_STATUS_OFFLINE then
        for mapId = 1, GetNumMaps(), 1 do
          local zoneName = GetMapInfo(mapId)
          local zoneExist = 0
          local zoneInsert = 0
          local playerInZone = 0
          
          zoneName = cutStringAtLetter(zoneName, "^")
          memberZone = cutStringAtLetter(memberZone, "^")
          
          if playerZone == zoneName then playerInZone = 1 end
          if ownName == memberName then playerInZone = 1 end
           
          -- Auch entfernen, da man nicht hin joinen kann per Teleport
          if zoneName == _addon.cache["ImperialCity"] then playerInZone = 1 end
          if zoneName == _addon.cache["Cyrodiil"] then playerInZone = 1 end
          
          -- Spieler in der Zone, dann ignorieren
          if playerInZone ~= 1 then
            -- Zonen die schon existieren ignorieren 
            for i = 1, #availableZones do
              if availableZones[i].zoneName == zoneName then
                zoneExist = 1
                break
              end
            end      
          end

          -- Zone erfüllt alle Bedingungen
          if zoneName == memberZone and zoneExist ~= 1 and playerInZone ~= 1 and (searchTerm == "" or string.find(zoneName, searchTerm) or string.find(memberName, searchTerm)) then
            table.insert(availableZones, {
              ["zoneName"] = cutStringAtLetter(zoneName, "^"),
              ["displayName"] = memberName,
              ["gId"] = guildId,
              ["mId"] = memberId,
              ["what"] = "guild",
            })
            break
          end
        end            
      end 
    end
  end 
  
  return availableZones
end

-- FREUNDE
function _addon.getFriendsZones()
  local searchTerm = ShissuTeleporter_FilterText:GetText()  or ""
  local numFriends = GetNumFriends()
  local availableZones = {}
  
  for friendId = 1, numFriends do
    local _, _, zoneName = GetFriendCharacterInfo(friendId)
    local displayName, _, playerStatus = GetFriendInfo(friendId)
    
    if (playerStatus == 1 or playerStatus == 2 or playerStatus == 3) then
      if (searchTerm == "" or string.find(zoneName, searchTerm) or string.find(displayName, searchTerm)) then
        table.insert(availableZones, {
          ["zoneName"] = cutStringAtLetter(zoneName, "^"),
          ["displayName"] = displayName,
          ["what"] = "friend",
        })
      end
    end 
  end
   
  return availableZones
end

-- GRUPPE
function _addon.getGroupZones()
  local searchTerm = ShissuTeleporter_FilterText:GetText()  or ""
  local availableZones = {}
  local availableCount = 1
  
  local numGroup = GetGroupSize()
  local ownName = string.lower(GetUnitName("player"))
  
  for i = 1, numGroup do
    local unitTag = GetGroupUnitTagByIndex(i)
    local unitName = GetUnitName(unitTag)
    
    if unitTag ~= nil and IsUnitOnline(unitTag) and string.lower(unitName) ~= ownName then
      local zoneName = GetUnitZone(unitTag)
      local displayName = GetUnitDisplayName(unitTag)   
         
      if (searchTerm == "" or string.find(zoneName, searchTerm) or string.find(displayName, searchTerm)) then        
        table.insert(availableZones, {
          ["zoneName"] = cutStringAtLetter(zoneName, "^"),
          ["displayName"] = displayName,
          ["what"] = "group",
        })         
      end
    end
  end
   
  return availableZones
end

function _addon.toPlayer()
  if _selected["what"] ~= nil then
    if _selected["what"] == "friend" or _selected["what"] == "group" then
      JumpToGuildMember(_selected["displayName"])  
    else
      local list = _addon.getGuildsZones()
      
      for i=1, #list do
        local data = list[i]
        
        if _selected["zone"] == data.zoneName then
          _addon.clearSearchField()
          JumpToGuildMember(data.displayName)
          break 
        end
      end
    end
  end
end

function _addon.clearSearchField()
  ShissuTeleporter_FilterText:SetText("")
end

function _addon.sortTable(list)
  if (list == nil) then return false end
  
  local list = list
  local numEntrys = #list
  local sortedTitle = {}
  local sortedData = {}

  for i = 1, numEntrys do
    table.insert(sortedTitle, i, list[i].zoneName .. "**shissu" .. i)
  end
  
  table.sort(sortedTitle)
  
  for i = 1, numEntrys do
    local length = string.len(sortedTitle[i])
    local number = string.sub(sortedTitle[i], string.find(sortedTitle[i], "**shissu"), length)
    
    number = string.gsub(number, "**shissu", "")
    number = string.gsub(number, " ", "")
    number = tonumber(number)
    
    sortedData[i] = {}
    sortedData[i].displayName = list[number].displayName
    sortedData[i].zoneName = list[number].zoneName
    sortedData[i].what = list[number].what
  end  

  return sortedData
end

function _addon.toggleWindow()
  local control = GetControl("ShissuTeleporter")
  if (control) then
    if (control:IsHidden()) then
      control:SetHidden(false)
    else
      control:SetHidden(true)
    end
  end
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  shissuTeleporter = shissuTeleporter or {}
  if (shissuTeleporter["advertising"] == nil) then
    shissuTeleporter["advertising"] = {}
  end

  zo_callLater(function()               
    ShissuFramework._settings[_addon.Name_2] = {}
    ShissuFramework._settings[_addon.Name_2].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name_2].controls = _addon.controls  
    ShissuFramework.initAddon(_addon.Name_2, _addon.initialized)

    ShissuFramework._bindings.teleportToogle = _addon.toggleWindow
    ShissuFramework._bindings.standardTeleport = _addon.standardTeleport
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Nrme, EVENT_ADD_ON_LOADED)
end
 
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)