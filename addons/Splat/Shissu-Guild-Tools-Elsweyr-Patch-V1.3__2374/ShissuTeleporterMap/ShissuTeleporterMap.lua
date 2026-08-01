-- Shissu Guild Tools Addon
-- ShissuTeleporterMap
--
-- Version: v1.2.0
-- Last Update: 24.05.2019
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!


local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local red = _globals["red"]

local cutStringAtLetter = ShissuFramework["func"].cutStringAtLetter

local ShissuMapLocations = ZO_MapLocations_Shared:Subclass()

local _addon = {}
_addon.Name = "ShissuTeleporterMap"
_addon.Version = "1.2.0"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s TeleporterMap"
_addon.core = {}

local LOCATION_DATA = 1

function ShissuMapLocations:New(...)
  local object = ZO_MapLocations_Shared.New(self,...)
  return object
end

function ShissuMapLocations:Initialize(control) 
  ZO_MapLocations_Shared.Initialize(self, control)
    
  WORLD_MAP_SHISSU_LOCATIONS_FRAGMENT = ZO_FadeSceneFragment:New(control)     
     
  local sgtButtonData = {
    normal = "ShissuFramework/textures/button_sgt1.dds",
    pressed = "ShissuFramework/textures/button_sgt1.dds",
    highlight = "ShissuFramework/textures/button_sgt2.dds", 
  }
    
  WORLD_MAP_INFO.modeBar:Add("Teleporter", { WORLD_MAP_SHISSU_LOCATIONS_FRAGMENT }, sgtButtonData)    
  
  ShissuMapLocationsVersion:SetText(_addon.formattedName .. " " .. _addon.Version)
end

function ShissuMapLocations:InitializeList(control)
  self.list = control:GetNamedChild("List")
end

function ShissuMapLocations:UpdateSelectedMap()
  self.selectedMapIndex = GetCurrentMapIndex()            
  ZO_ScrollList_RefreshVisible(self.list)
end

function ShissuMapLocations:SetListDisabled(disabled)
  self.listDisabled = disabled
  ZO_ScrollList_RefreshVisible(self.list)
end

function _addon.core.sortTable(list)
  if (list == nil) then return false end
  
  local list = list
  local numEntrys = #list
  local sortedTitle = {}
  local sortedData = {}

  for i = 1, numEntrys do
    table.insert(sortedTitle, i, list[i].locationName .. "**shissu" .. i)
  end
  
  table.sort(sortedTitle)
  
  for i = 1, numEntrys do
    local length = string.len(sortedTitle[i])
    local number = string.sub(sortedTitle[i], string.find(sortedTitle[i], "**shissu"), length)
    
    number = string.gsub(number, "**shissu", "")
    number = string.gsub(number, " ", "")
    number = tonumber(number)
    
    sortedData[i] = {}
    sortedData[i].locationName = list[number].locationName
    sortedData[i].description = list[number].description
    sortedData[i].player = list[number].player
    sortedData[i].index = list[number].index
  end  

  return sortedData
end

function ShissuMapLocations:BuildLocationList()
  ZO_ScrollList_AddDataType(self.list, LOCATION_DATA, "ShissuMapLocationsRow", 23, function(control, data) self:SetupLocation(control, data) end)

  local scrollData = ZO_ScrollList_GetDataList(self.list)
  local ownName = GetDisplayName()   
  local availableZones = {}
 
  local availableLocations = {} 
 
  for guildId = 1, GetNumGuilds() do
    local guildId = GetGuildId(guildId)
    
    for memberId = 1, GetNumGuildMembers(guildId) do
      local _, _, memberlocationName = GetGuildMemberCharacterInfo(guildId, memberId)
      local memberName, _, _ , memberStatus = GetGuildMemberInfo(guildId, memberId)
      
      local foundZone = 0
      
      for zoneId, zoneData in pairs(availableZones) do 
        if (zoneData["locationName"]  == memberlocationName) then
          foundZone = 1 
          break
        end
      end

      for mapId = 2, GetNumMaps(), 1 do
        if (mapId ~= 14 and mapId ~= 26) then
          if (GetMapInfo(mapId) == memberlocationName) then
            break
          end
        end
        
        if mapId == GetNumMaps() then foundZone = 1 end
      end

      if ownName == memberName then foundZone = 1 end

      -- Cyrodiil ID=14
      -- Kaiserstadt ID=26
      if (foundZone == 0 and memberStatus ~= 4) then 
        table.insert(availableZones, {
          ["locationName"] = memberlocationName,
          ["description"]  = memberName,
          ["player"] = 1,
          ["index"] = 1,
        })
      end
    end
  end
  
  availableZones = _addon.core.sortTable(availableZones)

  for i, entry in ipairs(availableZones) do
    scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(LOCATION_DATA, entry)
  end

  ZO_ScrollList_Commit(self.list)
end

function ShissuMapLocations:SetupLocation(control, data)
  local listDisabled = self:GetDisabled()
  local locationLabel = control:GetNamedChild("Location")

  locationLabel:SetText(white .. cutStringAtLetter(data.locationName, "^"))
  locationLabel:SetSelected(self.selectedMapIndex == data.index)    
  locationLabel:SetEnabled(not listDisabled)
  locationLabel:SetMouseEnabled(not listDisabled)
end

function ShissuMapLocations:RowLocation_OnMouseDown(label, button)
  if(button == MOUSE_BUTTON_INDEX_LEFT) then
    label:SetAnchor(LEFT, nil, LEFT, 0, 1)
  end
end

function ShissuMapLocations:RowLocation_OnMouseUp(label, button, upInside)  
  local data = ZO_ScrollList_GetData(label:GetParent())

  if (data.player == 1) then
    SCENE_MANAGER:Hide("worldMap")
    JumpToGuildMember(data.description) 
  end
end

function ShissuTeleporterMapRowLocation_OnMouseEnter(label)
  local data = ZO_ScrollList_GetData(label:GetParent())
  
  if (data.description) then
    ZO_Tooltips_ShowTextTooltip(self, TOPRIGHT, white .. data.description)
  end
end

function ShissuTeleporterMapRowLocation_OnMouseExit()
  ZO_Tooltips_HideTextTooltip()
end

function ShissuTeleporterMapRowLocation_OnMouseDown(label, button)
  WORLD_SHISSU_MAP_LOCATIONS:RowLocation_OnMouseDown(label, button)
end

function ShissuTeleporterMapRowLocation_OnMouseUp(label, button, upInside)
  WORLD_SHISSU_MAP_LOCATIONS:RowLocation_OnMouseUp(label, button, upInside)
end

function _addon.initialized()
  --d(_addon.formattedName .. " " .. _addon.Version)

  local control = GetControl("ShissuMapLocations") 
  WORLD_SHISSU_MAP_LOCATIONS = ShissuMapLocations:New(control)
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end
   
  zo_callLater(function()               
    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)