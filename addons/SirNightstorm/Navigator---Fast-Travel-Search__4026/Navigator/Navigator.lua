Navigator = {
  name = "Navigator",
  menuName = "Navigator",          -- A UNIQUE identifier for menu object.
  displayName = "|c66CC66N|r|c66CCFFavigator|r",
  settingsName = "NavigatorSettings",
  author = "SirNightstorm",
  appVersion = "1.3.0",
  svName = "Navigator_SavedVariables",
  isCLI = false,
  isDeveloper = (GetDisplayName() == '@SirNightstorm' and true) or false,
  mapVisible = false,
  currentNodeIndex = nil,
  callback = ZO_CallbackObject:New()
}
local Nav = Navigator

Nav.CONFIRMFASTTRAVEL_ALWAYS = 0
Nav.CONFIRMFASTTRAVEL_WHENCOST = 1
Nav.CONFIRMFASTTRAVEL_NEVER = 2

Nav.ACTION_SHOWONMAP = 0
Nav.ACTION_SETDESTINATION = 1
Nav.ACTION_TRAVEL = 2
Nav.ACTION_TRAVELOUTSIDE = 3
Nav.ACTION_VISITHOUSE = 4
Nav.ACTION_SELECT = 5

Nav.JUMPSTATE_WORLD = 0
Nav.JUMPSTATE_WAYSHRINE = 1
Nav.JUMPSTATE_CYRODIIL = 2
Nav.JUMPSTATE_TRANSITUS = 3
Nav.jumpState = Nav.JUMPSTATE_WORLD

Nav.default = {
  recentNodes = {},
  bookmarks = {},
  defaultTab = true,
  showAtWayshrine = true,
  autoFocus = false,
  includeUndiscovered = false,
  tpCommand = "/nav",
  loggingEnabled = false,
  recentsCount = 10,
  ignoreDefiniteArticlesInSort = false,
  listPOIs = true,
  useHouseNicknames = false,
  destinationActions = {
      singleClick = Nav.ACTION_TRAVEL,
      doubleClick = Nav.ACTION_TRAVEL,
      enterKey = Nav.ACTION_TRAVEL,
      slash = Nav.ACTION_TRAVEL
  },
  zoneActions = {
      singleClick = Nav.ACTION_SHOWONMAP,
      doubleClick = Nav.ACTION_TRAVEL,
      enterKey = Nav.ACTION_SHOWONMAP,
      slash = Nav.ACTION_TRAVEL
  },
  poiActions = {
      singleClick = Nav.ACTION_SHOWONMAP,
      doubleClick = Nav.ACTION_SETDESTINATION,
      enterKey = Nav.ACTION_SHOWONMAP,
      slash = Nav.ACTION_SHOWONMAP
  },
  houseActions = {
      singleClick = Nav.ACTION_TRAVEL,
      doubleClick = Nav.ACTION_TRAVELOUTSIDE,
      enterKey = Nav.ACTION_TRAVEL,
      slash = Nav.ACTION_TRAVEL
  },
  questActions = {
      singleClick = Nav.ACTION_SELECT,
      doubleClick = Nav.ACTION_TRAVEL,
      enterKey = Nav.ACTION_SELECT
  },
  singleClickZone = false,
  confirmFastTravel = Nav.CONFIRMFASTTRAVEL_ALWAYS,

  replaceHousesTab = false,
  replaceLocationsTab = false,
  replaceQuestsTab = false
}

local logger = LibDebugLogger and LibDebugLogger(Nav.name)

local _events = {}

function Nav.log(...)
  if logger and Nav.saved and Nav.saved["loggingEnabled"] then
    logger:Debug(string.format(...))
  end
end

function Nav.logWarning(...)
  if logger and Nav.saved and Nav.saved["loggingEnabled"] then
    logger:Warn(string.format(...))
  end
end

function Nav.mkstr(id, str)
    if _G[id] then
        SafeAddString(_G[id], str, 1)
    else
        ZO_CreateStringId(id, str)
        SafeAddVersion(id, 1)
    end
end

-- @usage Triggered when the Focus Search key is pressed
-- @param keyDown
function Nav:OnFocusSearchPressed(_)
    if self.mapVisible then
        self.showSearch()
        return true
    else
        return false
    end
end

local function findTabIndexWithIsNavigator()
    local arr = GAMEPAD_WORLD_MAP_INFO.baseHeaderData.tabBarEntries
    for i = 1, #arr do
        local t = arr[i]
        if type(t) == "table" and t.isNavigator then
            Nav.log("findTabIndexWithIsNavigator: %d", i)
            return i
        end
    end
    return nil -- not found
end

function Nav.showSearch(callback)
    Nav.log("showSearch")
    ZO_WorldMap_ShowWorldMap()
    if IsInGamepadPreferredMode() then
        GAMEPAD_WORLD_MAP_INFO:Show()
        Nav.mainTab_gamepad:ResetSearch()
        ZO_GamepadGenericHeader_SetActiveTabIndex(GAMEPAD_WORLD_MAP_INFO.header, findTabIndexWithIsNavigator())
        --GAMEPAD_WORLD_MAP_INFO:SwitchToFragment(Nav.mainTab_gamepad.fragment, false) -- Doesn't work
    else
        local tabVisible = Nav.mainTab.visible
        --MAIN_MENU_KEYBOARD:ShowScene("worldMap")
        WORLD_MAP_INFO:SelectTab(NAVIGATOR_TAB_SEARCH)
        Nav.mainTab:ResetSearch()
        if Nav.saved.autoFocus or tabVisible then
            Nav.mainTab.editControl:TakeFocus()
            Nav.log("showSearch: setting editControl focus")
        end
        if callback then
            callback()
        end
    end
end

function Nav.AttachMapTab(name, xmlObj, baseObj, view)
    Nav[name] = xmlObj
    for k, v in pairs(baseObj) do
        Nav[name][k] = Nav.Utils.deepCopy(v)
    end
    Nav[name].currentView = view

    if PP and PP.ADDON_NAME then
        local success, error = pcall(function()
            local listCtrl = xmlObj:GetNamedChild("List")
            PP.ScrollBar(listCtrl:GetNamedChild("ScrollBar"))
            ZO_Scroll_SetMaxFadeDistance(listCtrl, PP.savedVars.ListStyle.list_fade_distance)
        end)
        if not success then
            Nav.logWarning("OnAddOnLoaded: PP error '%s'", error)
        end
    end
end

local function GetUniqueEventId(id)
  local count = _events[id] or 0
  count = count + 1
  _events[id] = count
  return count
end

local function getEventName(id)
  return table.concat({ Nav.name, tostring(id), tostring(GetUniqueEventId(id)) }, "_")
end

local function addEvent(id, func)
  local name = getEventName(id)
  EVENT_MANAGER:RegisterForEvent(name, id, func)
end

local function addEvents(func, ...)
  local count = select('#', ...)
  local id
  for i = 1, count do
  id = select(i, ...)
  if not id then
    df('%s element %d is nil.  Please report.', Nav.name, i)
  else
    addEvent(id, func)
  end
  end
end

local ButtonGroup

local function OnMapStateChange(_, newState)
    if not ButtonGroup then
        ButtonGroup = {
            {
                name = GetString(NAVIGATOR_KEYBIND_SEARCH),
                keybind = "NAVIGATOR_FOCUSSEARCH", --"UI_SHORTCUT_QUICK_SLOTS", --"NAVIGATOR_SEARCH",
                order = 200,
                visible = function() return true end,
                callback = function() Nav.showSearch() end,
            },
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
        }
    end

  if newState == SCENE_SHOWING then
    Nav.mapVisible = true
    local zone = Nav.Locations:getCurrentMapZone()
    Nav.initialMapZoneId = zone and zone.zoneId or nil
    Nav.log("WorldMap showing; initialMapZoneId=%d", Nav.initialMapZoneId or 0)
    PushActionLayerByName("Map")
    KEYBIND_STRIP:AddKeybindButtonGroup(ButtonGroup)
    --if Nav.saved and Nav.saved["defaultTab"] and not FasterTravel then
    --  WORLD_MAP_INFO:SelectTab(NAVIGATOR_TAB_SEARCH)
    --end
    Nav.Locations:SetTreasureData()

    if zone and Nav.Locations:ShouldCollapseCategories(zone.zoneId) then
        Nav.mainTab.collapsedCategories = { bookmarks = true, recents = true }
    else
        Nav.mainTab.collapsedCategories = {}
    end
  elseif newState == SCENE_HIDDEN then
    Nav.log("WorldMap hidden")
    Nav.mapVisible = false
    KEYBIND_STRIP:RemoveKeybindButtonGroup(ButtonGroup)
    RemoveActionLayerByName("Map")
  end
end

local function OnMapChanged()
    if Nav.mainTab.visible then
        Nav.Locations:UpdateKeeps()
        Nav.mainTab:ImmediateRefresh()
    end
    Nav.callback:FireCallbacks("OnMapChanged")
end

local function OnStartFastTravel(eventCode, nodeIndex)
    Nav.jumpState = Nav.JUMPSTATE_WAYSHRINE
    Nav.currentNodeIndex = nodeIndex
    Nav.log("OnStartFastTravel(%d,%d) jumpState %d", eventCode, nodeIndex, Nav.jumpState)

    if Nav.Locations:ShouldCollapseCategories(Nav.currentZoneId) then
        Nav.mainTab.collapsedCategories = { bookmarks = true, recents = true }
    else
        Nav.mainTab.collapsedCategories = {}
    end

    Nav.mainTab:ImmediateRefresh()

    if Nav.saved.showAtWayshrine then
        -- Override the default behaviour that opens the Locations tab
        WORLD_MAP_INFO:SelectTab(Nav.lastTab.descriptor or NAVIGATOR_TAB_SEARCH)
    end
end

local function OnStartFastTravelKeep(eventCode, nodeIndex)
    Nav.jumpState = Nav.JUMPSTATE_TRANSITUS
    Nav.Locations:UpdateKeeps()
    Nav.log("OnStartFastTravelKeep(%d,%d) jumpState %d", eventCode, nodeIndex, Nav.jumpState)
    Nav.mainTab:ImmediateRefresh()
end

local function OnEndFastTravel()
  Nav.jumpState = Nav.currentZoneId == Nav.ZONE_CYRODIIL and Nav.JUMPSTATE_CYRODIIL or Nav.JUMPSTATE_WORLD
  Nav.currentNodeIndex = nil
  Nav.Locations:SetKeepsInaccessible()
  Nav.log("OnEndFastTravel() jumpState %d", Nav.jumpState)
end

local function OnPlayerActivated()
  Nav.Recents:onPlayerActivated()
  Nav.currentZoneId = ZO_ExplorationUtils_GetPlayerCurrentZoneId()
  Nav.jumpState = Nav.currentZoneId == Nav.ZONE_CYRODIIL and Nav.JUMPSTATE_CYRODIIL or Nav.JUMPSTATE_WORLD
  Nav.log("OnPlayerActivated() zoneId %d jumpState %d", Nav.currentZoneId, Nav.jumpState)
end

local function OnPOIUpdated()
  Nav.Locations:clearKnownNodes()
end

local function SetPlayersDirty(_)
    -- Nav.log("SetPlayersDirty("..eventCode..")")
    Nav.Players:ClearPlayers()
    Nav.mainTab:queueRefresh()
    if Nav.zonesTab then
        Nav.zonesTab:queueRefresh()
    end
end

local function UpdatePlayer(userID)
    Nav.Players:UpdatePlayer(userID)
    Nav.mainTab:queueRefresh(Nav.REFRESH_EXISTING)
end

local function SetKeepsDirty(_)
    Nav.Locations:SetKeepsDirty()
    Nav.mainTab:queueRefresh()
end

local function RefreshQuests()
    Nav.Quest.ClearCache()
    Nav.mainTab:queueRefresh()
    if Nav.questTab then
        Nav.questTab:queueRefresh()
    end
end

local function setupEvents()
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnMapChanged)
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", OnMapChanged)

    addEvent(EVENT_START_FAST_TRAVEL_INTERACTION, OnStartFastTravel)
    addEvent(EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, OnStartFastTravelKeep)
    addEvent(EVENT_END_FAST_TRAVEL_INTERACTION, OnEndFastTravel)
    addEvent(EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, OnEndFastTravel)
    addEvent(EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    addEvents(OnPOIUpdated, EVENT_POI_DISCOVERED, EVENT_POI_UPDATED, EVENT_FAST_TRAVEL_NETWORK_UPDATED)

    addEvents(SetPlayersDirty,
            EVENT_GROUP_MEMBER_JOINED, EVENT_GROUP_MEMBER_LEFT, EVENT_GROUP_MEMBER_CONNECTED_STATUS,
            EVENT_GUILD_SELF_JOINED_GUILD, EVENT_GUILD_SELF_LEFT_GUILD, EVENT_GUILD_MEMBER_ADDED, EVENT_GUILD_MEMBER_REMOVED,
            EVENT_FRIEND_ADDED, EVENT_FRIEND_REMOVED, EVENT_GROUP_MEMBER_ROLE_CHANGED)

    addEvent(EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED, function(_, _, displayName, _, _)
        UpdatePlayer(displayName);
    end)

    addEvent(EVENT_FRIEND_CHARACTER_ZONE_CHANGED, function(_, displayName, _, _)
        UpdatePlayer(displayName);
    end)

    addEvent(EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, function(_, _, displayName, oldStatus, newStatus)
        if newStatus == PLAYER_STATUS_OFFLINE or (oldStatus == PLAYER_STATUS_OFFLINE and newStatus == PLAYER_STATUS_ONLINE) then
            --Nav.log("EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED displayName=%s, status=%s", displayName, newStatus)
            UpdatePlayer(displayName);
        end
    end)

    addEvents(SetKeepsDirty, EVENT_FAST_TRAVEL_NETWORK_UPDATED, EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED,
            EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED, EVENT_CAMPAIGN_STATE_INITIALIZED,
            EVENT_CAMPAIGN_SELECTION_DATA_CHANGED, EVENT_CURRENT_CAMPAIGN_CHANGED, EVENT_ASSIGNED_CAMPAIGN_CHANGED,
            EVENT_KEEPS_INITIALIZED, EVENT_KEEP_ALLIANCE_OWNER_CHANGED, EVENT_KEEP_UNDER_ATTACK_CHANGED
    )

    addEvents(RefreshQuests, EVENT_QUEST_ADDED, EVENT_QUEST_REMOVED, EVENT_QUEST_CONDITION_COUNTER_CHANGED,
            EVENT_QUEST_ADVANCED, EVENT_QUEST_LIST_UPDATED)
    FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerTrackingStateChanged", RefreshQuests)
end

local function findTabIndexByName(name)
    for i, buttonData in ipairs(WORLD_MAP_INFO.modeBar.buttonData) do
        if buttonData.descriptor == name then
            return i
        end
    end
    return nil
end

local function moveLastTabToIndex(index, replace)
    local buttons = WORLD_MAP_INFO.modeBar.menuBar.m_object.m_buttons
    local ourButton = buttons[#buttons]
    buttons[#buttons] = nil

    if replace then
        buttons[index] = ourButton
    else
        table.insert(buttons, index, ourButton)
    end

    local buttonData = WORLD_MAP_INFO.modeBar.buttonData
    local ourData = buttonData[#buttonData]
    buttonData[#buttonData] = nil
    if replace then
        buttonData[index] = ourData
    else
        table.insert(buttonData, index, ourData)
    end

    WORLD_MAP_INFO.modeBar:UpdateButtons(false)
    Nav.log("Menu re-ordered")
end

local function replaceWorldMapTab(name, fragmentGroup, buttonData)
    local tabIndex = findTabIndexByName(name)
    WORLD_MAP_INFO.modeBar:Add(name, fragmentGroup, buttonData)
    moveLastTabToIndex(tabIndex, true)

end

local function setupTabs(self)
    local buttonData = {
        pressed = "Navigator/media/tabicons/tabicon_down.dds",
        highlight = "Navigator/media/tabicons/tabicon_over.dds",
        normal = "Navigator/media/tabicons/tabicon_up.dds",
        callback = function()
            -- Hide the modebar title
            WORLD_MAP_INFO.modeBar.label:SetText("")
        end
    }
    WORLD_MAP_INFO.modeBar:Add(NAVIGATOR_TAB_SEARCH, { self.mainTab.fragment }, buttonData)
    if self.saved["defaultTab"] and not FasterTravel then
        moveLastTabToIndex(1)
        WORLD_MAP_INFO:SelectTab(NAVIGATOR_TAB_SEARCH)
    end

    if self.saved.replaceQuestsTab and self.questTab then
        local questButtonData = {
            normal = "EsoUI/Art/WorldMap/map_indexIcon_quests_up.dds",
            pressed = "EsoUI/Art/WorldMap/map_indexIcon_quests_down.dds",
            highlight = "EsoUI/Art/WorldMap/map_indexIcon_quests_over.dds"
        }
        replaceWorldMapTab(SI_MAP_INFO_MODE_QUESTS, { self.questTab.fragment }, questButtonData)
    end

    if self.saved.replaceLocationsTab and self.zonesTab then
        local zonesButtonData = {
            normal = "EsoUI/Art/WorldMap/map_indexIcon_locations_up.dds",
            pressed = "EsoUI/Art/WorldMap/map_indexIcon_locations_down.dds",
            highlight = "EsoUI/Art/WorldMap/map_indexIcon_locations_over.dds"
        }
        replaceWorldMapTab(SI_MAP_INFO_MODE_LOCATIONS, { self.zonesTab.fragment }, zonesButtonData)
    end

    if self.saved.replaceHousesTab and self.housingTab then
        local housingButtonData = {
            normal = "EsoUI/Art/WorldMap/map_indexIcon_housing_up.dds",
            pressed = "EsoUI/Art/WorldMap/map_indexIcon_housing_down.dds",
            highlight = "EsoUI/Art/WorldMap/map_indexIcon_housing_over.dds"
        }
        replaceWorldMapTab(SI_MAP_INFO_MODE_HOUSES, { self.housingTab.fragment }, housingButtonData)
    end

    self.lastTab = self.mainTab
end

local function setupGamepadTabs(self)
    local mapInfo = GAMEPAD_WORLD_MAP_INFO
    local tabBarEntries = mapInfo.tabBarEntries
    self.originalHeaderData = GAMEPAD_WORLD_MAP_INFO.baseHeaderData

    local newTab = {
        isNavigator = true,
        text = GetString(NAVIGATOR_TAB_SEARCH),
        callback = function() GAMEPAD_WORLD_MAP_INFO:SwitchToFragment(Nav.mainTab_gamepad.fragment) end,
    }

    table.insert(tabBarEntries, 1, newTab)

    self.tabBarEntries = tabBarEntries
    mapInfo.tabBarEntries = tabBarEntries

    --ZO_GamepadGenericHeader_Refresh(mapInfo.header, mapInfo:GetHeaderData())
    ZO_GamepadGenericHeader_SetActiveTabIndex(mapInfo.header, 1)
end

local function hookGamepadWorldMapKeybinds(self)
    local getDescriptor = function()
        for keybindButtonDescriptor, _ in pairs(KEYBIND_STRIP.keybindGroups) do
            return keybindButtonDescriptor
        end
        return nil
    end
    local hasNavigatorKeybind = function(descriptor)
        for i = 1, #descriptor do
            if descriptor[i].name == GetString(NAVIGATOR_TAB_SEARCH) then
                return true
            end
        end
        return false
    end

    local oldFunc
    local newFunc = function(enabled)
        oldFunc(enabled)
        if enabled then
            local descriptor = getDescriptor()

            if descriptor and not hasNavigatorKeybind(descriptor) then
                table.insert(descriptor, {
                    name = GetString(NAVIGATOR_TAB_SEARCH),
                    keybind = "UI_SHORTCUT_QUINARY",
                    visible = function() return true end,
                    enabled = function()
                        return not WORLD_MAP_MANAGER:IsPreventingMapNavigation()
                    end,
                    callback = function()
                        Nav.showSearch()
                    end,
                    sound = SOUNDS.GAMEPAD_MENU_FORWARD
                })
            end
            KEYBIND_STRIP:RemoveKeybindButtonGroup(descriptor)
            KEYBIND_STRIP:AddKeybindButtonGroup(descriptor)
        end
        return true
    end
    oldFunc = ZO_PreHook("ZO_WorldMap_SetGamepadKeybindsShown", newFunc)
end

function Nav:initialize()
  Nav.log("initialize starts")
  -- https://wiki.esoui.com/How_to_add_buttons_to_the_keybind_strip

  self.saved = ZO_SavedVars:NewAccountWide(self.svName, 1, nil, self.default)

  SCENE_MANAGER:GetScene('worldMap'):RegisterCallback("StateChange", OnMapStateChange)

  self.currentAlliance = GetUnitAlliance("player")

  setupTabs(self)
  setupGamepadTabs(self)
  hookGamepadWorldMapKeybinds(self)

  self.Recents:init()
  self.Bookmarks:init()
  self.Chat:Init()
  self:loadSettings()

  setupEvents()

  CreateDefaultActionBind("NAVIGATOR_FOCUSSEARCH", KEY_TAB)

    Nav.log("Initialize exits")
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= "Navigator" then return end

    Nav:initialize()

    --if PP and PP.ADDON_NAME then
    --    local success, error = pcall(function()
    --        PP.ScrollBar(Navigator_MainTab:GetNamedChild("List"):GetNamedChild("ScrollBar")) --Navigator_MainTabListScrollBar
    --        ZO_Scroll_SetMaxFadeDistance(Navigator_MainTab:GetNamedChild("List"), PP.savedVars.ListStyle.list_fade_distance)
    --    end)
    --    if not success then
    --        Nav.logWarning("OnAddOnLoaded: PP error '%s'", error)
    --    end
    --end

    EVENT_MANAGER:UnregisterForEvent(Nav.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(Nav.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
