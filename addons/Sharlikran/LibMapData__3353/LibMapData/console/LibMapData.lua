local libName, libVersion = "LibMapData", 122
local lib = {}
local internal = {}
_G["LibMapData"] = lib
_G["LibMapData_Internal"] = internal
local GPS = LibGPS3

lib.callbackType = {}
lib.callbackType.EVENT_ZONE_CHANGED = "LibMapDataEventZoneChanged"
lib.callbackType.EVENT_LINKED_WORLD_POSITION_CHANGED = "LibMapDataEventLinkedWorldPositionChanged"
lib.callbackType.EVENT_PLAYER_ACTIVATED = "LibMapDataEventPlayerActivated"
lib.callbackType.OnWorldMapChanged = "LibMapDataOnWorldMapChanged"
lib.callbackType.WorldMapSceneStateChange = "LibMapDataWorldMapSceneStateChange"

local callbackObject = ZO_CallbackObject:New()
lib.callbackObject = {}
lib.callbackObject = callbackObject

function lib:RegisterCallback(...)
  return lib.callbackObject:RegisterCallback(...)
end

function lib:UnregisterCallback(...)
  return lib.callbackObject:UnregisterCallback(...)
end

function lib:FireCallbacks(...)
  return callbackObject:FireCallbacks(...)
end

lib.mapType = nil
lib.zoneIndex = nil
lib.mapIndex = nil
lib.mapId = nil
lib.parentZoneMapId = nil
lib.mapTexture = nil
lib.isMainZone = nil
lib.isSubzone = nil
lib.newSubzone = false
lib.isWorld = nil
lib.isCosmic = nil
lib.isMacroMap = nil
lib.isDungeon = nil
lib.zoneName = nil
lib.mapName = nil
lib.subzoneName = nil
lib.subZoneId = nil
lib.currentFloor = nil
lib.numFloors = nil
lib.reticleInteractionName = nil
lib.lastInteractionTarget = nil
lib.questShared = false -- for LibQuestData
lib.pseudoMapIndex = nil
lib.lastMapTexture = nil
lib.lastMapId = nil
lib.wasSetMapToPlayerLocationCalled = false
lib.setMapToPlayerLocationQueueInProgress = false
lib.onPrepareForJumpInProgress = false
lib.onAddonLoadInProgress = true
lib.SetMapToPlayerLocationQueueStart = 0

-- Added and grouped as requested
lib.zoneId = nil
lib.worldX = nil
lib.worldY = nil
lib.worldZ = nil
lib.normalizedX = nil
lib.normalizedY = nil
lib.libGPSX = nil
lib.libGPSY = nil

lib.MAPINDEX_MIN = 1
lib.MAPINDEX_MAX = 53 -- 45, 46, 48, 50, 51, 52
lib.MAX_NUM_MAPIDS = 2807 -- 2192, 2223, 2314, 2406, 2619, 2734
lib.MAX_NUM_ZONEINDEXES = 1079 -- 881, 907, 931, 972, 1018, 1017, 1059
lib.MAX_NUM_ZONEIDS = 1584 -- 1345, 1364, 1387, 1435, 1492, 1557
-- max zoneId 1345 using valid zoneIndex
lib.MAX_ATTEMPT_MAP_UPDATE_SECONDS = 15

-----
--- API functions
-----
function lib:GetParentMapIdFromMapId(mapId)
  local _, _, _, zoneIndex, _ = GetMapInfoById(mapId)
  local zoneId = GetZoneId(zoneIndex)
  local zoneMapZoneId = GetParentZoneId(zoneId)
  local zoneMapMapId = GetMapIdByZoneId(zoneMapZoneId)
  return zoneMapMapId
end

function lib:GetParentMapIdFromZoneId(zoneId)
  local zoneMapZoneId = GetParentZoneId(zoneId)
  local zoneMapMapId = GetMapIdByZoneId(zoneMapZoneId)
  return zoneMapMapId
end

function lib:GetMapTileTextureFromMapId(mapId)
  local mapTextureByMapId = GetMapTileTextureForMapId(mapId, 1)
  local mapTexture = string.lower(mapTextureByMapId)
  mapTexture = mapTexture:gsub("^.*/maps/", "")
  mapTexture = mapTexture:gsub("%.dds$", "")
  lib.mapTexture = mapTexture
end

function lib:SetMapIdFromAPI()
  lib.mapId = GetCurrentMapId()
end

function lib:IsOverlandMap()
  if not lib.mapIndex then return false end
  if lib.mapIndexData[lib.mapIndex]["mapIndex"] == lib.mapIndex and lib.mapIndexData[lib.mapIndex]["mapTexture"] == lib.mapTexture then return true end
  return false
end

-----
--- Internal Callback Functions for Queue
-----

function internal:FireCallbackEventZoneChanged()
  internal:dm("Debug", "Fire LMD Callback EVENT_ZONE_CHANGED")
  lib.callbackObject:FireCallbacks(lib.callbackType.EVENT_ZONE_CHANGED)
end

function internal:FireCallbackWorldPositionChanged()
  internal:dm("Debug", "Fire LMD Callback EVENT_LINKED_WORLD_POSITION_CHANGED")
  lib.callbackObject:FireCallbacks(lib.callbackType.EVENT_LINKED_WORLD_POSITION_CHANGED)
end

function internal:FireCallbackEventPlayerActivated()
  internal:dm("Debug", "Fire LMD Callback EVENT_PLAYER_ACTIVATED")
  lib.callbackObject:FireCallbacks(lib.callbackType.EVENT_PLAYER_ACTIVATED)
end

function internal:FireCallbackOnWorldMapChanged()
  internal:dm("Debug", "Fire LMD Callback OnWorldMapChanged")
  lib.callbackObject:FireCallbacks(lib.callbackType.OnWorldMapChanged)
end

function internal:FireCallbackWorldMapSceneStateChange()
  internal:dm("Debug", "Fire LMD Callback WorldMapSceneStateChange")
  lib.callbackObject:FireCallbacks(lib.callbackType.WorldMapSceneStateChange)
end

-----
--- Internal functions
-----

function internal:SetWasSetMapToPlayerLocationCalledFalse()
  if lib.wasSetMapToPlayerLocationCalled then
    -- internal:dm("Debug", "-->> Set wasSetMapToPlayerLocationCalled False <<--")
    lib.wasSetMapToPlayerLocationCalled = false
    return
  end
  if not lib.wasSetMapToPlayerLocationCalled then
    -- internal:dm("Debug", "<< Set wasSetMapToPlayerLocationCalled Was Already False >>")
    return
  end
end

-- /script LibMapData_Internal:SetUpSetPlayerLocationQueue()
function internal:MapTextureMapIdUpdated()
  local mapTextureMapIdUnchanged = lib.mapId == lib.lastMapId and lib.mapTexture == lib.lastMapTexture
  if mapTextureMapIdUnchanged then
    return false
  else
    return true
  end
end

function internal:CheckSetPlayerLocationQueue()
  if ZO_WorldMap_IsWorldMapShowing() then return end
  lib.setMapToPlayerLocationQueueInProgress = true

  local timeElapsed = GetTimeStamp() - lib.SetMapToPlayerLocationQueueStart
  if timeElapsed > lib.MAX_ATTEMPT_MAP_UPDATE_SECONDS then
    lib.SetMapToPlayerLocationQueueStart = 0
    lib.setMapToPlayerLocationQueueInProgress = false
    internal:UpdateMapInfo()
  else
    local SetMapToPlayerLocationResult = SetMapToPlayerLocation()
    if SetMapToPlayerLocationResult == SET_MAP_RESULT_MAP_CHANGED then
      CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
    else
      zo_callLater(function() internal:CheckSetPlayerLocationQueue() end, 1000)
    end
  end
end

-- /script LibMapData_Internal:SetUpSetPlayerLocationQueue()
function internal:SetUpSetPlayerLocationQueue()
  if ZO_WorldMap_IsWorldMapShowing() then return end
  if lib.onPrepareForJumpInProgress then
    return
  end
  if lib.setMapToPlayerLocationQueueInProgress then
    return
  end
  if lib.onAddonLoadInProgress then
    return
  end
  lib.SetMapToPlayerLocationQueueStart = GetTimeStamp()
  internal:CheckSetPlayerLocationQueue()
end

-- /script LibMapData_Internal:UpdateMapInfo()
function internal:UpdateMapInfo()
  local mapType = MAPTYPE_NONE
  local mapTypeFound = GetMapType()
  if mapTypeFound ~= nil then mapType = mapTypeFound end
  lib.zoneIndex = GetCurrentMapZoneIndex()
  lib.mapIndex = GetCurrentMapIndex()
  -- no lib.mapId = because this sets the global variable lib.mapId
  lib:SetMapIdFromAPI()
  lib.currentFloor, lib.numFloors = GetMapFloorInfo()

  -- assign directly to lib.* instead of locals
  lib.zoneId, lib.worldX, lib.worldY, lib.worldZ = GetUnitWorldPosition("player")
  lib.normalizedX, lib.normalizedY = GetNormalizedWorldPosition(lib.zoneId, lib.worldX, lib.worldY, lib.worldZ)
  lib.libGPSX, lib.libGPSY = GPS:LocalToGlobal(lib.normalizedX, lib.normalizedY)
  lib.parentZoneMapId = lib:GetParentMapIdFromZoneId(lib.zoneId)

  --[[We do not set the mapId because of SetMapIdFromAPI() ]]--
  -- lib.mapId = mapId
  lib.mapType = mapType

  -- no lib.mapTexture = because this sets the global variable lib.mapTexture
  lib:GetMapTileTextureFromMapId(lib.mapId)

  local name, _, mapContentType, _, description = GetMapInfoById(lib.mapId)
  lib.isMainZone = mapType == MAPTYPE_ZONE
  lib.isSubzone = mapType == MAPTYPE_SUBZONE
  lib.isWorld = mapType == MAPTYPE_WORLD
  lib.isCosmic = mapType == MAPTYPE_COSMIC
  lib.isMacroMap = lib.isWorld or lib.isCosmic
  lib.isDungeon = mapContentType == MAP_CONTENT_DUNGEON

  local zoneName = GetZoneNameByIndex(lib.zoneIndex)
  local mapName = GetMapNameById(lib.mapId)
  if not zoneName then zoneName = "[Empty String]" end
  if not mapName then mapName = "[Empty String]" end
  lib.zoneName = zoneName
  lib.mapName = mapName
  local subzoneName = GetPlayerActiveSubzoneName()
  if subzoneName == "" then subzoneName = nil end
  lib.subzoneName = subzoneName
end

local climbLocalization = {
  ["en"] = "Climb",
}
local wordClimb = climbLocalization[GetCVar("Language.2")]
local approved_interaction_types = {
  [GetString(SI_GAMECAMERAACTIONTYPE1)] = true, -- Search
  [GetString(SI_GAMECAMERAACTIONTYPE5)] = true, -- Use
  [GetString(SI_GAMECAMERAACTIONTYPE13)] = true, -- Open
  [GetString(SI_GAMECAMERAACTIONTYPE6)] = true, -- Read
  [GetString(SI_GAMECAMERAACTIONTYPE10)] = true, -- Inspect
  [GetString(SI_GAMECAMERAACTIONTYPE15)] = true, -- Examine
}

ZO_PreHook(ZO_Reticle, "TryHandlingInteraction", function(interactionPossible, currentFrameTimeSeconds)
  if IsGameCameraActive() and not IsGameCameraUIModeActive() then
    local action, name, interactBlocked, isOwned, additionalInfo, contextualInfo, contextualLink, isCriminalInteract = GetGameCameraInteractableActionInfo()
    local validInteraction = approved_interaction_types[action]
    if name and validInteraction and not interactBlocked then
      lib.reticleInteractionName = name
    elseif not validInteraction then
      lib.reticleInteractionName = nil
    end
  end
end)

--[[ added mostly for LibQuestData so hopefully eroneous names are not assigned
to quest info for the NPC
]]--
local function OnPrepareForJump(eventCode, zoneName, zoneDescription, loadingTexture, instanceDisplayType)
  lib.reticleInteractionName = nil
  lib.lastInteractionTarget = nil
  lib.onPrepareForJumpInProgress = true
end
EVENT_MANAGER:RegisterForEvent(libName .. "_OnPrepareForJump", EVENT_PREPARE_FOR_JUMP, OnPrepareForJump)

local function OnZoneChanged(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
  lib.reticleInteractionName = nil
  lib.lastInteractionTarget = nil
  lib.newSubzone = newSubzone
  lib.subZoneId = subZoneId
  internal:SetUpSetPlayerLocationQueue()
end
EVENT_MANAGER:RegisterForEvent(libName .. "_zone_changed", EVENT_ZONE_CHANGED, OnZoneChanged)

local function OnWorldPositionChanged(eventCode, clientInteractResult, interactTargetName)
  lib.reticleInteractionName = nil
  lib.lastInteractionTarget = nil
  internal:SetUpSetPlayerLocationQueue()
end
EVENT_MANAGER:RegisterForEvent(libName .. "_OnWorldPositionChanged", EVENT_LINKED_WORLD_POSITION_CHANGED, OnWorldPositionChanged)

local function OnPlayerActivated(eventCode, initial)
  if initial then
    -- internal:dm("Debug", "->> initial Activattion <<-")
  end
  if not initial then
    -- internal:dm("Debug", "- Not Initial Activattion clear target and reticle  -")
    lib.reticleInteractionName = nil
    lib.lastInteractionTarget = nil
  end
  lib.onPrepareForJumpInProgress = false
  lib.onAddonLoadInProgress = false
end
EVENT_MANAGER:RegisterForEvent(libName .. "_activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

local function OnPlayerDeactivated(eventCode)
  lib.reticleInteractionName = nil
  lib.lastInteractionTarget = nil
end
EVENT_MANAGER:RegisterForEvent(libName .. "_OnPlayerDeactivated", EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)

CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
  lib.SetMapToPlayerLocationQueueStart = 0
  lib.setMapToPlayerLocationQueueInProgress = false
  lib.lastMapId = lib.mapId
  lib.lastMapTexture = lib.mapTexture
  internal:UpdateMapInfo()
  internal:SetWasSetMapToPlayerLocationCalledFalse()
  internal:MapTextureMapIdUpdated()
end)

WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
  lib.SetMapToPlayerLocationQueueStart = 0
  lib.setMapToPlayerLocationQueueInProgress = false
  if newState == SCENE_SHOWING then
    -- internal:dm("Debug", "SCENE_SHOWING")
    -- internal:UpdateMapInfo()
  elseif newState == SCENE_HIDDEN then
    -- internal:dm("Debug", "SCENE_HIDDEN")
    -- internal:UpdateMapInfo()
    internal:SetWasSetMapToPlayerLocationCalledFalse()
  end
end)

local function OnInteract(eventCode, result, interactTargetName)
  -- internal:dm("Debug", "OnInteract Occured")
  local text = zo_strformat(SI_CHAT_MESSAGE_FORMATTER, interactTargetName)
  -- internal:dm("Debug", text)
  lib.lastInteractionTarget = text
end
EVENT_MANAGER:RegisterForEvent(libName .. "_OnInteract", EVENT_CLIENT_INTERACT_RESULT, OnInteract)

--[[ added mostly for LibQuestData so hopefully eroneous names are not assigned
to quest info for the NPC
]]--
local function OnQuestSharred(eventCode, questID)
  lib.reticleInteractionName = nil
  lib.lastInteractionTarget = nil
  lib.questShared = true
end
EVENT_MANAGER:RegisterForEvent(libName .. "_OnQuestSharred", EVENT_QUEST_SHARED, OnQuestSharred) -- Verified

local function GetPlayerPos()
  internal:dm("Debug", "-----")
  internal:dm("Debug", "GetPlayerPos")
  if lib.lastInteractionTarget ~= nil then internal:dm("Debug", "Last Interaction Target: " .. lib.lastInteractionTarget) end
  if lib.reticleInteractionName ~= nil then internal:dm("Debug", "Reticle Interaction Name: " .. lib.reticleInteractionName) end

  local currentLogSetting = internal.show_log
  internal.show_log = true
  internal:UpdateMapInfo()

  internal:dm("Debug", lib.mapTexture)
  if lib.zoneName then internal:dm("Debug", "zoneName: " .. lib.zoneName) end
  if lib.mapName then internal:dm("Debug", "mapName: " .. lib.mapName) end
  if lib.subzoneName then internal:dm("Debug", "subzoneName: " .. lib.subzoneName) end
  if lib.subZoneId then internal:dm("Debug", "subZoneId: " .. lib.subZoneId) end
  if lib.zoneId then internal:dm("Debug", "ZoneId: " .. lib.zoneId) end
  if lib.mapIndex then internal:dm("Debug", "MapIndex: " .. lib.mapIndex) end
  if lib.mapId then internal:dm("Debug", "mapId: " .. lib.mapId) end
  if lib.parentZoneMapId then internal:dm("Debug", "parentZoneMapId: " .. lib.parentZoneMapId) end
  if lib.zoneIndex then internal:dm("Debug", "zoneIndex: " .. lib.zoneIndex) end
  internal:dm("Debug", "isDungeon: " .. tostring(lib.isDungeon))
  internal:dm("Debug", "isMainZone: " .. tostring(lib.isMainZone))
  internal:dm("Debug", "isSubzone: " .. tostring(lib.isSubzone))
  internal:dm("Debug", "isWorld: " .. tostring(lib.isWorld))
  internal:dm("Debug", "isCosmic: " .. tostring(lib.isCosmic))
  internal:dm("Debug", "isMacroMap: " .. tostring(lib.isMacroMap))
  if lib.currentFloor and lib.numFloors then
    local floorString = string.format("currentFloor: %d of %d", lib.currentFloor, lib.numFloors)
    internal:dm("Debug", floorString)
  end

  internal:dm("Debug", "X: " .. lib.normalizedX)
  internal:dm("Debug", "Y: " .. lib.normalizedY)
  internal:dm("Debug", "GPS X: " .. lib.libGPSX)
  internal:dm("Debug", "GPS Y: " .. lib.libGPSY)
  internal:dm("Debug", "worldX: " .. lib.worldX)
  internal:dm("Debug", "worldY: " .. lib.worldY)
  internal:dm("Debug", "worldZ: " .. lib.worldZ)

  --local distance = zo_round(GPS:GetLocalDistanceInMeters(0.62716490030289, 0.56329780817032, 0.62702748199203, 0.61508411169052))
  --d(distance)

  --local distance = zo_round(GPS:GetLocalDistanceInMeters(0.62716490030289, 0.56329780817032, 0.63227427005768, 0.70292204618454))
  --d(distance)

  --local distance = zo_round(GPS:GetLocalDistanceInMeters(0.6324172616, 0.7026107907, 0.63227427005768, 0.70292204618454))
  --d(distance)
  --local distance = zo_round(GPS:GetLocalDistanceInMeters(0.6500588655, 0.6869461536, 0.63227427005768, 0.70292204618454))
  --d(distance)

  --local distance = zo_round(GPS:GetLocalDistanceInMeters(0.6388558745, 0.5947756767, 0.63227427005768, 0.70292204618454))
  --d(distance)
  internal.show_log = currentLogSetting
end

local function OnAddOnLoaded(eventCode, addonName)
  if addonName == libName then
    internal:dm("Debug", "OnAddOnLoaded")
    EVENT_MANAGER:UnregisterForEvent(libName .. "_onload", EVENT_ADD_ON_LOADED)

    SLASH_COMMANDS["/lmdgetpos"] = function() GetPlayerPos() end -- used

    -- internal:dm("Debug", "->> Initial SetUp <<-")
    --[[Initial SetUp happens in OnAddOnLoaded because OnWorldPositionChanged
    will run prior to OnPlayerActivated so using the 'initial' flag from that is useless
    to initialize everything. Using UpdateMapInfo here is a bit overkill but needed for
    Lorebooks because it requires that the ZoneId is set to get the parent MapId
    ]]--
    internal:UpdateMapInfo()
    if lib.lastMapTexture == nil then lib.lastMapTexture = lib.mapTexture end
    if lib.lastMapId == nil then lib.lastMapId = lib.mapId end
    --[[newSubzone is true for some reason for OnAddOnLoaded prior to OnWorldPositionChanged
    or OnPlayerActivated but it is only set in OnZoneChanged.

    set setMapToPlayerLocationQueueInProgress also as it seems to be true after OnAddOnLoaded
    as well.
    ]]--
    lib.newSubzone = false
    lib.setMapToPlayerLocationQueueInProgress = false

  end
end
EVENT_MANAGER:RegisterForEvent(libName .. "_onload", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-------------------------------------------------
----- Logger Function                       -----
-------------------------------------------------
internal.show_log = false
if LibDebugLogger then
  internal.logger = LibDebugLogger.Create(libName)
end
local logger
local viewer
if DebugLogViewer then viewer = true else viewer = false end
if LibDebugLogger then logger = true else logger = false end

local function create_log(log_type, log_content)
  if not viewer and log_type == "Info" then
    CHAT_ROUTER:AddSystemMessage(log_content)
    return
  end
  if not internal.show_log then return end
  if logger and log_type == "Debug" then
    internal.logger:Debug(log_content)
  end
  if logger and log_type == "Info" then
    internal.logger:Info(log_content)
  end
  if logger and log_type == "Verbose" then
    internal.logger:Verbose(log_content)
  end
  if logger and log_type == "Warn" then
    internal.logger:Warn(log_content)
  end
end

local function emit_message(log_type, text)
  if (text == "") then
    text = "[Empty String]"
  end
  create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
  indent = indent or "."
  table_history = table_history or {}

  for k, v in pairs(t) do
    local vType = type(v)

    emit_message(log_type, indent .. "(" .. vType .. "): " .. tostring(k) .. " = " .. tostring(v))

    if (vType == "table") then
      if (table_history[v]) then
        emit_message(log_type, indent .. "Avoiding cycle on table...")
      else
        table_history[v] = true
        emit_table(log_type, v, indent .. "  ", table_history)
      end
    end
  end
end

function internal:dm(log_type, ...)
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    if (type(value) == "table") then
      emit_table(log_type, value)
    else
      emit_message(log_type, tostring(value))
    end
  end
end
