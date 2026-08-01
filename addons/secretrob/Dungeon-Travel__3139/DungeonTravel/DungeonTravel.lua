local LAM = LibAddonMenu2
local ADDON_NAME = "DungeonTravel"
local ADDON_VERSION = "2.3.0"
local hasPledges = false
local allButtonsHidden = true
local buttons = {}
--ZONES
local POITYPE_OVERLAND = 1
local POITYPE_ARENA = 2
local POITYPE_TRIAL = 3
local POITYPE_DUNGEON = 6
local POITYPE_HOUSES = 7

DungeonTravel = {}

DungeonTravel.DefaultSettings = {
   ["ShowOnMapOpen"] = true,
   ["HideOnMapClose"] = true,   
   ["ShowWithoutPledges"] = false,   
   ["ShowUnlockedOnly"] = false,
   ["closeMapOnPorting"] = true,
   ["dtUIoffsetX"] = -52,
   ["dtUIoffsetY"] = -74,
   ["dtUIAnchor"] = BOTTOMRIGHT,
   ["dtUIRelativePoint"] = BOTTOMRIGHT,
}

function ConfigureOptionsMenu()
   
   local panel = {
      type           = "panel",
      name           = ADDON_NAME,
      displayName    = "|c80ff80Dungeon|r Travel",
      author         = "|c8000ffsecretrob|r",
      version        = string.format("|cffffff%s|r", ADDON_VERSION),
      slashCommand = "/dtui",      
      registerForDefaults = true,
      registerForRefresh = true,
   }

   local options = 
   {
      {
         type = "header",
         name = "GENERAL SETTINGS"
      },
      {
            type = "checkbox",
            name = "Show DungeonTravel when the map is opened",
            tooltip = "Show DungeonTravel when the map is opened",
            getFunc = function() return mDTSavedVars.ShowOnMapOpen end,
            setFunc = function(value) mDTSavedVars.ShowOnMapOpen = value end,
            default = DungeonTravel.DefaultSettings["ShowOnMapOpen"],           
      },
      {
            type = "checkbox",
            name = "Hide DungeonTravel when the map is closed",
            tooltip = "Hide DungeonTravel when the map is closed",
            getFunc = function() return mDTSavedVars.HideOnMapClose end,
            setFunc = function(value) mDTSavedVars.HideOnMapClose = value end,
            default = DungeonTravel.DefaultSettings["HideOnMapClose"],           
      },
      {
            type = "checkbox",
            name = "Close map on travel",
            tooltip = "Close map when traveling",
            getFunc = function() return mDTSavedVars.closeMapOnPorting end,
            setFunc = function(value) mDTSavedVars.closeMapOnPorting = value end,
            default = DungeonTravel.DefaultSettings["closeMapOnPorting"],           
      },
      {
            type = "checkbox",
            name = "Show UI without pledges",
            tooltip = "Show UI event without having any pledges",
            getFunc = function() return mDTSavedVars.ShowWithoutPledges end,
            setFunc = function(value) mDTSavedVars.ShowWithoutPledges = value end,
            default = DungeonTravel.DefaultSettings["ShowWithoutPledges"],           
      },
      {
            type = "checkbox",
            name = "Only Show Unlocked Dungeons",
            tooltip = "Only Show Unlocked Dungeons, i.e. DLC you own",
            warning = "You will need to reload UI after changing this option for the list to update.\n\nIf you attempt to travel to an Arena you haven't unlocked then nothing will happen.",
            getFunc = function() return mDTSavedVars.ShowUnlockedOnly end,
            setFunc = function(value) mDTSavedVars.ShowUnlockedOnly = value end,
            default = DungeonTravel.DefaultSettings["ShowUnlockedOnly"],           
      },
   }

   if not LAM then return end
   local name = ADDON_NAME.."Options"      
   LAM:RegisterAddonPanel(name, panel)
   LAM:RegisterOptionControls(name, options)   
end

function DungeonTravelToggleVisibility(setValue)
   if setValue ~= nil and (hasPledges or mDTSavedVars.ShowWithoutPledges) then
      DTUI:SetHidden(setValue)
   end
end

function MapStateChanged(oldState, newState)      
   if newState == SCENE_SHOWING then
      if mDTSavedVars.ShowOnMapOpen then
         GetPledges()
         DungeonTravelToggleVisibility(false)         
      end
   else 
      if newState == SCENE_HIDDEN then
         if mDTSavedVars.HideOnMapClose then
            DungeonTravelToggleVisibility(true)
         end
      end
   end   

   if (allButtonsHidden and mDTSavedVars.ShowWithoutPledges == false) then DungeonTravelToggleVisibility(true) end
end

function DungeonTravelSaveLoc()
   local isValidAnchor, anchor, relativeTo, relativePoint, offx, offy, AnchorConstrains = DTUI:GetAnchor()   
   mDTSavedVars.dtUIAnchor = anchor
   mDTSavedVars.dtUIRelativePoint = relativePoint
   mDTSavedVars.dtUIoffsetX = offx
   mDTSavedVars.dtUIoffsetY = offy
end

function GetPledges()   
   local count = GetNumJournalQuests()
   local dungeonList = ""   
   local offset = 60
   local addedButtons = false
   allButtonsHidden = true

   for i,button in pairs(buttons) do
      button:SetHidden(true)
      button:ClearAnchors()
   end

   for i = 1, count do
      if GetJournalQuestRepeatType(i) == QUEST_REPEAT_DAILY then
         local name = GetJournalQuestName(i)
         if string.match(name, "Pledge: ") then
            hasPledges = true
            local button
            local dungeonName = name.gsub(name, "Pledge: ", "")
            if string.match(dungeonName, "Darkshade") then
               dungeonName = dungeonName.gsub(dungeonName, "Darkshade", "Darkshade Caverns")
            end
            local zone = DungeonTravel:GetZoneFromPartialName(dungeonName)
            if(zone ~= nil) then
               local buttonExists = buttons[zone.id] ~= nil
               if buttonExists == false then
                  addedButtons = true
                  allButtonsHidden = false
                  --local button, key = DungeonTravel.pool:AcquireObject()
                  button = CreateControlFromVirtual("DTUIButton", DTUI, "ZO_DefaultTextButton", zone.id)                  
               else
                  button = buttons[zone.id]
                  button:SetHidden(false)
                  allButtonsHidden = false
               end
               
               button:SetAnchor(CENTER, row, TOP, 0, offset)
               button:SetWidth(250)
               button:SetText('Pledge: '..tostring(zone.name))
               button:SetHandler("OnMouseDown", function(self) DungeonTravel:JumpTo(zone) end)
               buttons[zone.id] = button
               offset = offset + 20
            end
         end
      end
   end

   if( allButtonsHidden ) then DungeonTravelToggleVisibility(true) end
   
   DTUI:ClearAnchors()   
   DTUI:SetDimensions(250,offset)
   DTUI:SetAnchor(mDTSavedVars.dtUIAnchor, GuiRoot, mDTSavedVars.dtUIRelativePoint, mDTSavedVars.dtUIoffsetX, mDTSavedVars.dtUIoffsetY)   
end

local function Initialize()
   mDTSavedVars = ZO_SavedVars:NewAccountWide("DungeonTravel_SavedVariables", ADDON_VERSION, nil, DungeonTravel.DefaultSettings, nil)
   WORLD_MAP_SCENE:RegisterCallback("StateChange", MapStateChanged)
   GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", MapStateChanged)   
   InitializeZones()
   ConfigureOptionsMenu()

   DTUI:ClearAnchors()      
   DTUI:SetAnchor(mDTSavedVars.dtUIAnchor, GuiRoot, mDTSavedVars.dtUIRelativePoint, mDTSavedVars.dtUIoffsetX, mDTSavedVars.dtUIoffsetY)
      
   --DungeonTravel.pool = ZO_ObjectPool:New(function(objectPool)      
   --   return ZO_ObjectPool_CreateNamedControl("DTUIButton", "DTUIButton", objectPool, DTUI)
   --end)   
end

function IsArena(index)
   local arenas = {
      [1] = { id = 250 }, -- Maelstrom Arena
      [2] = { id = 270 }, -- Dragonstar Arena
      [3] = { id = 378 }, -- Blackrose Prison
      [4] = { id = 457 } -- Vateshran Hollows
   }

   for i,id in ipairs(arenas) do
      if( id.id == index ) then
         return true
      end
   end
   return false
end


function InitializeZones()
    DungeonTravel.zoneById = {}    
    DungeonTravel.zoneByName = {}
    DungeonTravel.zoneAutocompleteList = {}

    local totalNodes = GetNumFastTravelNodes()
    local i = 1    
    while i <= totalNodes do
        local known, nodeName, _, _, _, _, poiType = GetFastTravelNodeInfo(i)
        if( (known or mDTSavedVars.ShowUnlockedOnly == false) and (poiType == POITYPE_DUNGEON or poiType == POITYPE_TRIAL or IsArena(i)) ) then
            local dungeonName = ""
            if( poiType == POITYPE_DUNGEON ) then
               dungeonName = nodeName.gsub(nodeName, "Dungeon: ", "")
            else
               dungeonName = nodeName
            end

            AddEntry(i, dungeonName)
        end
        i = i + 1
    end
end

function AddEntry(zoneId, zoneName)
    local zoneData = {
        id = zoneId,        
        name = zoneName
    }
    DungeonTravel.zoneById[zoneId] = zoneData    
    DungeonTravel.zoneByName[zoneName] = zoneData
    DungeonTravel.zoneAutocompleteList[zo_strlower(zoneData.name)] = zoneData.name
end

function DungeonTravel:GetZoneByZoneName(zoneName)
    return DungeonTravel.zoneByName[zo_strformat("<<1>>", zoneName)]
end

function DungeonTravel:GetZoneList()
    return DungeonTravel.zoneByName
end

function DungeonTravel:GetZoneFromPartialName(partialZone)
    local filtered = partialZone.gsub(zo_strlower(partialZone), "the ", "")
    local results = GetTopMatchesByLevenshteinSubStringScore(DungeonTravel.zoneAutocompleteList, filtered, 1, 1)    
    if(#results == 0) then return end
    return DungeonTravel.zoneByName[results[1]]
end

function DungeonTravel:JumpTo(zone)
    if(IsUnitInCombat("player")) then return false end
    --zone: name, id
    if(not zone) then return end
    d(zo_strformat("Attempting to travel to <<1>>", zone.name))
    FastTravelToNode(zone.id)
    if mDTSavedVars.closeMapOnPorting then
      -- hide world map if open
      SCENE_MANAGER:Hide("worldMap")
      --DungeonTravelToggleVisibility(true)      
   end
    return
end

local function OnAddOnLoaded(eventCode, addOnName)
   if addOnName == ADDON_NAME then
      Initialize()
   end
   EVENT_MANAGER:UnregisterForEvent(eventHandle, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)