-- Shissu Guild Tools Addon
-- ShissuTeleporter
--
-- Version: v1.5.0
-- Last Update: 24.05.2019
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local blue = _globals["blue"]
local yellow = _globals["yellow"]
local red = _globals["red"]

local cutStringAtLetter = ShissuFramework["func"].cutStringAtLetter
local createFlatWindow = ShissuFramework["interface"].createFlatWindow
local createFlatButton = ShissuFramework["interface"].createFlatButton

local getWindowPosition = ShissuFramework["interface"].getWindowPosition
local saveWindowPosition = ShissuFramework["interface"].saveWindowPoition

local _addon = {}
_addon.Name = "ShissuTeleporter"
_addon.Version = "1.5.0"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s Teleporter"                                                

_addon.cache = {}

local _selected = {}
local ShissuTeleporter = ZO_SocialListKeyboard:Subclass()

ShissuTeleporter.SORT_KEYS = {
  ["name"] = {},
}

local _L = ShissuFramework["func"]._L(_addon.Name)
          
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
   
   local oldText = self:GetText()
   oldText = string.gsub(oldText, yellow, "")
   self:SetText(stdColor .. oldText)     

   ShissuTeleporter_ButtonTeleport_LABEL:SetText(stdColor .. data.zone) 

  ShissuTeleporter:BuildMasterList()
  ShissuTeleporter:Refresh()   
end

function ShissuTeleporterRowEnter(self)
  local parent = self:GetParent()
  local data = ZO_ScrollList_GetData(parent)
  
  ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, white .. data["displayName"] .. " (" .. stdColor .. data["zone"] .. white.. ")")
end

function ShissuTeleporterRowExit(self)
  ZO_Tooltips_HideTextTooltip()
end

-- Zufallsteleport zu irgendeinen Gildenmitglied
function _addon.rndTeleport()
  local data = _addon.getGuildsZones()
  local count = #data
  local rnd = math.random(0, count)  

  JumpToGuildMember(data[rnd].displayName) 
end
                                                                              
-- * Initialisierung                                                                         
function _addon.initialized()
  SLASH_COMMANDS["/rndteleport"] = _addon.rndTeleport
  SLASH_COMMANDS["/rnd"] = _addon.rndTeleport
  SLASH_COMMANDS["/teleport"] = function() SGT_Teleport:SetHidden(false) end
  SLASH_COMMANDS["/tele"] = function() SGT_Teleport:SetHidden(false) end

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
    function() control:SetHidden(true) end,
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
  
  --saveWindowPosition(ShissuTeleporter, shissuTeleporter["position"])
  --getWindowPosition(ShissuTeleporter, shissuTeleporter["position"])

  ShissuTeleporter_ButtonRefresh:SetHandler("OnMouseUp", function() 
    ShissuTeleporter:BuildMasterList()
    ShissuTeleporter:Refresh()     
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
end

function _addon.getGuildsZones()
  local playerZone = cutStringAtLetter(GetPlayerLocationName() , "^") 
  local searchTerm = ShissuTeleporter_FilterText:GetText()  or ""
  local availableZones = {}
  
  --for mapId = 1, GetNumMaps(), 1 do
  --  local zoneName = GetMapInfo(mapId)
  --  d(mapId .. " ---- " .. zoneName)
  --end
  
  -- Gilde
  local ownName = GetDisplayName()   
  
  for guildId = 1, GetNumGuilds() do
    if #availableZones == GetNumMaps() - 2 then break end
    guildId = GetGuildId(guildId)
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
          JumpToGuildMember(data.displayName)
          break 
        end
      end
    end
  end
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

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  shissuTeleporter = shissuTeleporter or {}

  zo_callLater(function()               
    ShissuFramework.initAddon(_addon.Name, _addon.initialized)

    ShissuFramework["interface"].initChatButton()

    ShissuFramework._bindings.teleportToogle = function() 
      local control = GetControl("ShissuTeleporter")
      if (control) then
        if (control:IsHidden()) then
          control:SetHidden(false)
        else
          control:SetHidden(true)
        end
      end
    end
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end
 
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)