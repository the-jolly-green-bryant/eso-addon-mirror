EchoesOfLore = {
    name            = "EchoesOfLore",	-- Matches folder and Manifest file names.
    displayName     = "Elder Scrolls of Alts",
    version         = "0.0.1",			-- A nuisance to match to the Manifest.
    author          = "Echomap",
    color           = "DDFFEE",			 -- Used in menu titles and so on.    
    menuName        = "EchoesOfLore_Options", -- Unique identifier for menu object.
    menuDisplayName = "EchoesOfLore",
    view            = {},
    -- Saved Settings
    savedVariables  = {},
}

--ZO_SORT_ORDER_UP, --ZO_SORT_ORDER_DOWN
local defaultSettings = {   
  sversion   = EchoesOfLore.version,
  window     = {
      ["top"]       = 100,
      ["left"]      = 100,
      ["width"]     = 830,
      ["height"]    = 325,
  },
  selected = {
    ["charactername"] = nil,
  },
}

local defaultSettingsGlobal = {
  debug      = false,
  beta       = false,
}

--Commands, help/debug/beta/testdata/deltestdata
function EchoesOfLore.SlashCommandHandler(text)
	EchoesOfLore:debugMsg("SlashCommandHandler: " .. text)
	local options = {}
	local searchResult = { string.match(text,"^(%S*)%s*(.-)$") }
	for i,v in pairs(searchResult) do
		if (v ~= nil and v ~= "") then
		    options[i] = string.lower(v)
		end
	end

	if #options == 0 then
    EchoesOfLore.ToggleGui()
	elseif options[1] == "help" then
		-- TODO Display help  
	elseif options[1] == "debug" then
		local dg = EchoesOfLore.savedVariables.debug
		EchoesOfLore.savedVariables.debug = not dg
		d("EchoesOfLore: Debug = " .. tostring(EchoesOfLore.savedVariables.debug) )    
	elseif options[1] == "beta" then
		local dg = EchoesOfLore.savedVariables.beta
		EchoesOfLore.savedVariables.beta = not dg
		d("EchoesOfLore: Beta = " .. tostring(EchoesOfLore.savedVariables.beta) )
  elseif options[1] == "testdata" then
    --EchoesOfLore:LoadTestData1()
  elseif options[1] == "deltestdata" then
    --EchoesOfLore:DelTestData1()    
	end
end

--when ride along, 131257, subZoneName/subZoneId filledin
--Shrine port: player unloaded called 589825
--ride into new zone: uloaded 58925
--dungeon port lfg: playerunloaded=
--Into subzone: eventCode=131257, zoneName=, subZoneName=Temple of the Eight, newSubzone=, zoneId=0, subZoneId=7422
--(number eventCode, string zoneName, string subZoneName, boolean newSubzone, number zoneId, number subZoneId) 
function EchoesOfLore.OnEventZoneChange(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId) 
  --EchoesOfLore:debugMsg("OnEventZoneChange called")
  local strI = "OnEventZoneChange: eventCode=<<1>>, zoneName=<<2>>, subZoneName=<<3>>, newSubzone=<<4>>, zoneId=<<5>>, subZoneId=<<6>>"
  local strL = zo_strformat( strI, eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId )
  EchoesOfLore:debugMsg(strL)
  if( zoneName ~= nil ) then
    EchoesOfLore.view.zoneName    = zoneName
    EchoesOfLore.view.subZoneName = subZoneName
    if(subZoneId~=nil and subZoneName~=nil) then
      EchoesOfLore:ShowSubZoneLoreText(subZoneId,subZoneName)
    end
  end
end
--
-- (number eventCode, string unitTag, string newZoneName) 
function EchoesOfLore.OnEventZoneUpdate(eventCode,  unitTag,  newZoneName) 
  --EchoesOfLore:debugMsg("OnEventZoneUpdate called") 
  local strI = "OnEventZoneUpdate: eventCode=<<1>>, unitTag=<<2>>, newZoneName=<<3>>"
  local strL = zo_strformat(strI, eventCode, unitTag, newZoneName )
  EchoesOfLore:debugMsg(strL)
end
--
function EchoesOfLore.EventSubZoneListUpdate(eventCode) 
  --EchoesOfLore:debugMsg("EventSubZoneListUpdate called")
  local strI = "EventSubZoneListUpdate: eventCode=<<1>>"
  local strL = zo_strformat(strI, eventCode )
  EchoesOfLore:debugMsg(strL)
end
--131258 travel in city
--131124 group member changed area
--131257
function EchoesOfLore.EventSubZoneChange(eventCode)
  --EchoesOfLore:debugMsg("EventSubZoneChange called")
  if( eventCode ~= nil and eventCode ~= 131258 ) then
    local strI = "EventSubZoneChange: eventCode=<<1>>"
    local strL = zo_strformat(strI, eventCode )
    EchoesOfLore:debugMsg(strL)
  end
end
--
function EchoesOfLore.OnAreaLoadStarted(evt, area, instance, zoneName, zoneDescription, loadingTexture, instanceType)  
  --EchoesOfLore:debugMsg("OnAreaLoadStarted2 called")
  local strI = "OnAreaLoadStarted: evt=<<1>>, area=<<2>>, zoneName=<<3>>, zoneDescription=<<4>>, loadingTexture=<<5>>, instanceType=<<6>>"
  local strL = zo_strformat( strI, evt, area, zoneName, zoneDescription, loadingTexture, subZoneId, instanceType )
  EchoesOfLore:debugMsg(strL)
end
--
function EchoesOfLore.OnAreaLoadStarted(area, instance, zoneName, zoneDescription, loadingTexture, instanceType)  
  --EchoesOfLore:debugMsg("OnAreaLoadStarted called")
  local strI = "OnAreaLoadStarted: area=<<1>>, instance=<<2>>, zoneName=<<3>>, zoneDescription=<<4>>, loadingTexture=<<5>>, instanceType=<<6>>"
  local strL = zo_strformat(strI, area, instance, zoneName, zoneDescription, loadingTexture, instanceType )
  EchoesOfLore:debugMsg(strL)  
end
function EchoesOfLore.OnPOISInitialized(eventCode)
  local strI = "OnPOISInitialized: eventCode=<<1>>"
  local strL = zo_strformat(strI, eventCode )
  EchoesOfLore:debugMsg(strL)
end

function EchoesOfLore:DisableEvents()
  EchoesOfLore:debugMsg("DisableEvents called")
  EVENT_MANAGER:UnregisterForEvent(EchoesOfLore.name, EVENT_CURRENT_SUBZONE_LIST_CHANGED)
  EVENT_MANAGER:UnregisterForEvent(EchoesOfLore.name, EVENT_POIS_INITIALIZED)
  EVENT_MANAGER:UnregisterForEvent(EchoesOfLore.name, EVENT_ZONE_CHANGED)
  EVENT_MANAGER:UnregisterForEvent(EchoesOfLore.name, EVENT_ZONE_UPDATE)
  --OnWorldMapChanged
  --GetZoneNameByIndex()
  --GetCurrentMapZoneIndex()
end

function EchoesOfLore:EnableEvents()
  EchoesOfLore:debugMsg("EnableEvents called")
  
  --<--ZONES-->
  EVENT_MANAGER:RegisterForEvent(EchoesOfLore.name, EVENT_CURRENT_SUBZONE_LIST_CHANGED, EchoesOfLore.EventSubZoneChange)
  EVENT_MANAGER:RegisterForEvent(EchoesOfLore.name, EVENT_POIS_INITIALIZED, EchoesOfLore.OnPOISInitialized)
  EVENT_MANAGER:RegisterForEvent(EchoesOfLore.name, EVENT_ZONE_CHANGED, EchoesOfLore.OnEventZoneChange)
  EVENT_MANAGER:RegisterForEvent(EchoesOfLore.name, EVENT_ZONE_UPDATE, EchoesOfLore.OnEventZoneUpdate)
  EVENT_MANAGER:RegisterForEvent(EchoesOfLore.name, EVENT_CURRENT_SUBZONE_LIST_CHANGED, EchoesOfLore.EventSubZoneListUpdate)
  EVENT_MANAGER:RegisterForEvent(EchoesOfLore.name, EVENT_AREA_LOAD_STARTED, EchoesOfLore.OnAreaLoadStarted)
  --<--ZONES-->
end

--EVENT_PLAYER_ACTIVATED (number eventCode, boolean initial)
function EchoesOfLore.OnPlayerLoaded(eventCode, initial) 
  EchoesOfLore:debugMsg("OnPlayerLoaded called")
  if( event ~= nil ) then
    local strI = "OnPlayerLoaded: eventCode=<<1>>"
    local strL = zo_strformat(strI, event )
    EchoesOfLore:debugMsg(strL)
  end
  --
  local currMZIndx = GetCurrentMapZoneIndex()
  local currMZName = GetZoneNameByIndex(currMZIndx) 
  local oldMZIndx = EchoesOfLore.savedVariables.currMZIndex
  if(currMZName~=nil)then
    EchoesOfLore.savedVariables.currMZIndex = currMZIndx
    EchoesOfLore.savedVariables.currMZName  = currMZName    
    if(oldMZIndx ~= EchoesOfLore.savedVariables.currMZIndex)then
      d( zo_strformat(GetString(SI_EOL_ENTERED_ZONE), currMZName ) )          
      EchoesOfLore:ShowLoreText()
    else
      d( zo_strformat(GetString(SI_EOL_REENTERED_ZONE), currMZName ) )          
    end
  elseif(currMZName~=nil)then
    d("currMZIndx = ".. currMZIndx)
    --[14:59] (EchoesOfLore) OnPlayerUnloaded: eventCode=589825
    --TODO still in same zone?
    --EchoesOfLore.savedVariables.currMZName
    d( zo_strformat(GetString(SI_EOL_IN_ZONE), currMZName ) )          
    currMZName = EchoesOfLore.savedVariables.currMZName
  else
    d("Entered zone... unknown?")
  end
  
  if(EchoesOfLore.Dungeons[currMZName]~=nil)then
    if( EchoesOfLoreMain:IsHidden()) then
      EchoesOfLore:showViewDungeon(currMZName)
      EchoesOfLore.view.dungeonselected = currMZName
    end
  end 
  --Dungeon OnEventZoneChange: eventCode=131257, zoneName=, subZoneName=Wayrest Sewers, newSubzone=, zoneId=0, subZoneId=993
 
  --GetMapIndexByZoneId(number zoneId) 
  --TODO find lore for zone
  --TODO settings to not do this
  
  EchoesOfLore:debugMsg("OnPlayerLoaded: done") -- Prints to chat.
end

-- EVENT
-- 589825 changed local
function EchoesOfLore.OnPlayerUnloaded(event)
  EchoesOfLore:debugMsg("OnPlayerUnloaded called")
end
 
function EchoesOfLore:ShowSubZoneLoreText(subZoneId,subZoneName)
  if(subZoneId==nil or subZoneName==nil) then
    return
  end  
  local key = zo_strformat("<<1>>-<<2>>",subZoneName,subzoneId)
  local areaData =  EchoesOfLore.SubZones[key]
  if(areaData~=nil)then
    local areaInfo = areaData["Description"]
    if(areaInfo~=nil)then
      local areaVal  =  areaInfo.value
      if(areaVal~=nil)then
        d("LORE: "..areaVal)
      end
    end
  end
end

function EchoesOfLore:ShowLoreText()
  local area = EchoesOfLore.savedVariables.currMZName
  local areaData =  EchoesOfLore.Zones[area]
  if(areaData~=nil)then
    local areaInfo = areaData["Description"]
    if(areaInfo~=nil)then
      local areaVal  =  areaInfo.value
      if(areaVal~=nil)then
        d("LORE: "..areaVal)
      end
    end
  end
end

-- EVENT
function EchoesOfLore.OnAddOnLoaded(event, addonName)
    if addonName ~= EchoesOfLore.name then return end
    EVENT_MANAGER:UnregisterForEvent(EchoesOfLore.name, EVENT_ADD_ON_LOADED)
    
    --(savedVariableTable, version, namespace, defaults, profile, displayName, characterName)
    EchoesOfLore.savedVariables = ZO_SavedVars:New("EchoesOfLore_SavedVariables", 1, nil, defaultSettings)

    EchoesOfLore:debugMsg(EchoesOfLore.name .. GetString(SI_EOL_MESSAGE_P)) 
    ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil,
        EchoesOfLore.name .. GetString(SI_EOL_MESSAGE_P)) -- Top-right alert.
    --
    -- LMM Settings menu in Settings.lua.
    EchoesOfLore.LoadSettings()  
    EchoesOfLore:InitializeUI()
    EchoesOfLore:EnableEvents()

    -- Slash commands must be lowercase. Set to nil to disable.
    SLASH_COMMANDS["/EchoesOfLore"] = EchoesOfLore.SlashCommandHandler
    SLASH_COMMANDS["/echolore"]     = EchoesOfLore.SlashCommandHandler
    -- Reset autocomplete cache to update it.
    SLASH_COMMAND_AUTO_COMPLETE:InvalidateSlashCommandCache()
    
    --d(EchoesOfLore.name .. GetString(SI_NEW_ADDON_MESSAGE2)) -- Prints to chat.
    ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil,
        EchoesOfLore.name .. GetString(SI_EOL_MESSAGE_A)) -- Top-right alert.
    EchoesOfLore:debugMsg("OnAddOnLoaded done")
end

--SCENE_MANAGER:RegisterTopLevel(HarvensQuestJournalTopLevel, false)

-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(EchoesOfLore.name, EVENT_ADD_ON_LOADED, EchoesOfLore.OnAddOnLoaded)
--
-- When player is ready, after everything has been loaded. (after addon loaded)
EVENT_MANAGER:RegisterForEvent(EchoesOfLore.name, EVENT_PLAYER_ACTIVATED, EchoesOfLore.OnPlayerLoaded)
EVENT_MANAGER:RegisterForEvent(EchoesOfLore.name, EVENT_PLAYER_DEACTIVATED, EchoesOfLore.OnPlayerUnloaded)

--EOF