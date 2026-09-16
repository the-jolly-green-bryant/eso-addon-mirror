-- Native ESO world-map adapter for Bandit's existing minimap settings.
-- Uses a separate map mode and stock WORLD_MAP_FRAGMENT; never reparents ZO_WorldMapScroll.
local Mini = BUI.MiniMap
local Core = {}
Mini.Core = Core
local EVENT_NAME = "SXUI_NativeMinimap"
local FOLLOW_NAME = "SXUI_NativeMinimapFollow"
local RETRY_NAME = "SXUI_NativeMinimapRetry"
local mapVars
local mapMode
local registered = false
local refreshing = false
local retryCount = 0
local mapRetryCount = 0
local wantedVisible = false
local lastMapId
local lastMapType
local announcedVisible = false

local function Log(message)
    if BUI.Vars and BUI.Vars.DeveloperMode and type(d) == "function" then
        d("[BXUI Minimap] " .. message)
    end
end

local function Duplicate(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Duplicate(item) end
    return result
end

local function Schedule(delay, reason)
    if not BUI.CallLater then return end
    BUI.CallLater(RETRY_NAME, delay, function() Mini.EnsureMinimapState(reason) end)
end

local function SceneShowing(scene)
    return scene and scene.IsShowing and scene:IsShowing()
end

local function FullMapShowing()
    return SceneShowing(rawget(_G, "WORLD_MAP_SCENE"))
        or SceneShowing(rawget(_G, "GAMEPAD_WORLD_MAP_SCENE"))
        or SceneShowing(rawget(_G, "SCRYING_SCENE"))
        or (type(ZO_WorldMap_IsWorldMapShowing) == "function" and ZO_WorldMap_IsWorldMapShowing())
end

local function MapControlReady()
    return rawget(_G, "ZO_WorldMap") and rawget(_G, "WORLD_MAP_MANAGER")
        and rawget(_G, "WORLD_MAP_FRAGMENT")
        and type(ZO_WorldMap_GetPanAndZoom) == "function"
        and type(ZO_WorldMap_GetPinManager) == "function"
end

local function CreateMode()
    if mapMode then return true end
    if type(mapVars) ~= "table" or not rawget(_G, "MAP_MODE_SMALL_CUSTOM") then return false end
    local small = mapVars[MAP_MODE_SMALL_CUSTOM]
    if type(small) ~= "table" then return false end
    local candidate = 60
    while mapVars[candidate] and candidate < 100 do candidate = candidate + 1 end
    if mapVars[candidate] then return false end
    local clone = Duplicate(small)
    local size = tonumber(BUI.Vars.MiniMapDimensions) or 250
    clone.width, clone.height = size, size
    clone.mapSize = small.mapSize
    mapVars[candidate] = clone
    mapMode = candidate
    Core.modeData = clone
    return true
end

local function EnsureContainer()
    local container = rawget(_G, "BUI_Minimap")
    if not container then
        local size = tonumber(BUI.Vars.MiniMapDimensions) or 250
        container = BUI.UI.Control("BUI_Minimap", SatuveUI, {size, size}, BUI.Vars.BUI_Minimap, false)
        container:SetMovable(true)
        container:SetMouseEnabled(false)
        container:SetHandler("OnMouseUp", function(self) BUI.Menu:SaveAnchor(self) end)
        container.backdrop = BUI.UI.Backdrop("BUI_Minimap_B", container, "inherit",
            {CENTER, CENTER, 0, 0}, {0, 0, 0, 0.4}, {0, 0, 0, 1}, nil, true)
        container.label = BUI.UI.Label("BUI_Minimap_L", container.backdrop, "inherit",
            {CENTER, CENTER, 0, 0}, BUI.UI.Font("standard", 20, true), nil, {1, 1}, BUI.Loc("MiniMap_Label"))
    end
    return container
end

local function SetFragmentOnScene(scene, enabled)
    if not scene or not WORLD_MAP_FRAGMENT then return end
    if enabled then
        if scene.AddFragment then scene:AddFragment(WORLD_MAP_FRAGMENT) end
    elseif scene.RemoveFragment then
        scene:RemoveFragment(WORLD_MAP_FRAGMENT)
    end
end

local function UpdateHUDFragments(enabled)
    SetFragmentOnScene(rawget(_G, "HUD_SCENE"), enabled)
    SetFragmentOnScene(rawget(_G, "HUD_UI_SCENE"), enabled)
    SetFragmentOnScene(rawget(_G, "SIEGE_BAR_SCENE"), enabled)
    SetFragmentOnScene(rawget(_G, "SIEGE_BAR_UI_SCENE"), enabled)
    SetFragmentOnScene(rawget(_G, "LOOT_SCENE"), enabled)
end

local function NativeMapLayout()
    local container = EnsureContainer()
    local size = math.max(200, math.min(500, tonumber(BUI.Vars.MiniMapDimensions) or 250))
    Mini.size = size
    Mini.pinscale = (tonumber(BUI.Vars.PinScale) or 75) / 100
    container:SetDimensions(size, size)
    if container.backdrop then container.backdrop:SetDimensions(size, size) end
    if container.label then container.label:SetDimensions(size, size) end
    if Core.modeData then Core.modeData.width, Core.modeData.height = size, size end
    ZO_WorldMap:ClearAnchors()
    ZO_WorldMap:SetAnchor(CENTER, container, CENTER, 0, 0)
    ZO_WorldMap:SetDimensions(size, size)
    ZO_WorldMap:SetAlpha(math.max(0, math.min(1, (tonumber(BUI.Vars.MiniMapAlpha) or 100) / 100)))
    if rawget(_G, "ZO_WorldMapTitle") then
        ZO_WorldMapTitle:SetHidden(not BUI.Vars.MiniMapTitle)
        ZO_WorldMapTitle:SetFont(BUI.UI.Font("standard", 20, "shadow"))
    end
    if container.backdrop then container.backdrop:SetAlpha(0) end
    container:SetHidden(false)
    if rawget(_G, "ZO_FocusedQuestTrackerPanel") and not BUI.Vars.ZO_FocusedQuestTrackerPanel then
        ZO_FocusedQuestTrackerPanel:ClearAnchors()
        ZO_FocusedQuestTrackerPanel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 0, size + 20)
    end
end

local function ResetFullMapVisuals()
    if rawget(_G, "ZO_WorldMap") then ZO_WorldMap:SetAlpha(1) end
    if rawget(_G, "ZO_WorldMapTitle") then ZO_WorldMapTitle:SetHidden(false) end
    if rawget(_G, "ZO_MapPin") and ZO_MapPin.PIN_DATA and Mini.ResizePins then Mini.ResizePins(false) end
end

local function DesiredZoom()
    local mapType = type(GetMapType) == "function" and GetMapType() or nil
    local content = type(GetMapContentType) == "function" and GetMapContentType() or nil
    local texture = type(GetMapTileTexture) == "function" and tostring(GetMapTileTexture()) or ""
    local value
    if mapType == rawget(_G, "MAP_CONTENT_DUNGEON") or content == rawget(_G, "MAP_CONTENT_DUNGEON") then
        value = BUI.Vars.ZoomDungeon
    elseif string.find(string.lower(texture), "imperialsewer", 1, true) then
        value = BUI.Vars.ZoomImperialsewer
    elseif string.find(string.lower(texture), "imperialcity", 1, true) then
        value = BUI.Vars.ZoomImperialCity
    elseif content == rawget(_G, "MAP_CONTENT_AVA") then
        value = BUI.Vars.ZoomCyrodiil
    elseif mapType == rawget(_G, "MAP_TYPE_SUBZONE") or mapType == rawget(_G, "MAP_TYPE_LOCAL") then
        value = BUI.Vars.ZoomSubZone
    else
        value = BUI.Vars.ZoomZone
    end
    local mounted = type(IsMounted) == "function" and IsMounted()
    local ratio = mounted and ((tonumber(BUI.Vars.ZoomMountRatio) or 100) / 100) or 1
    return math.max(0.01, math.min(1, ((tonumber(value) or 60) / 100) * ratio))
end

local function CenterPlayer()
    if not wantedVisible or FullMapShowing() then return end
    local pinManager = Mini.PinManager
    local panZoom = Mini.MapPanAndZoom
    local pin = pinManager and pinManager.GetPlayerPin and pinManager:GetPlayerPin()
    if pin and panZoom and panZoom.JumpToPin then
        panZoom:JumpToPin(pin, true)
    elseif type(ZO_WorldMap_JumpToPlayer) == "function" then
        ZO_WorldMap_JumpToPlayer()
    end
end

local function FollowTick()
    if not BUI.Vars.MiniMap or FullMapShowing() or not wantedVisible
        or (WORLD_MAP_FRAGMENT.IsShowing and not WORLD_MAP_FRAGMENT:IsShowing()) then
        EVENT_MANAGER:UnregisterForUpdate(FOLLOW_NAME)
        return
    end
    CenterPlayer()
    local x, y = type(GetMapPlayerPosition) == "function" and GetMapPlayerPosition("player") or nil
    if x and y and (not Mini.LastX1 or math.abs(x - Mini.LastX1) + math.abs(y - Mini.LastY1) > 0.0002) then
        Mini.LastX1, Mini.LastY1 = x, y
        if CALLBACK_MANAGER then CALLBACK_MANAGER:FireCallbacks("BUI_MiniMap_Update", true) end
    end
end

local function StartFollow()
    EVENT_MANAGER:UnregisterForUpdate(FOLLOW_NAME)
    EVENT_MANAGER:RegisterForUpdate(FOLLOW_NAME, 250, FollowTick)
end

local function RefreshPlayerMap()
    if refreshing or FullMapShowing() then return true end
    if type(DoesCurrentMapMatchMapForPlayerLocation) == "function"
        and DoesCurrentMapMatchMapForPlayerLocation() then return true end
    if type(SetMapToPlayerLocation) ~= "function" then return false end
    refreshing = true
    local ok, result = pcall(SetMapToPlayerLocation)
    if ok and result == rawget(_G, "SET_MAP_RESULT_MAP_CHANGED") and CALLBACK_MANAGER then
        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
    end
    refreshing = false
    if not ok then return false end
    return type(DoesCurrentMapMatchMapForPlayerLocation) ~= "function"
        or DoesCurrentMapMatchMapForPlayerLocation()
end

local attachedScenes = {}
local function AttachScene(scene, callback)
    if scene and scene.RegisterCallback and not attachedScenes[scene] then
        scene:RegisterCallback("StateChange", callback)
        attachedScenes[scene] = true
    end
end
local function OnHUDScene(_, newState)
    if newState == SCENE_SHOWING or newState == SCENE_SHOWN then Schedule(120, "HUD_RETURN") end
end
local function OnWorldScene(_, newState)
    if newState == SCENE_SHOWING or newState == SCENE_SHOWN then Core:Ensure("WORLD_MAP_OPEN")
    elseif newState == SCENE_HIDDEN then Schedule(100, "WORLD_MAP_CLOSED") end
end
local function AttachScenes()
    AttachScene(rawget(_G, "HUD_SCENE"), OnHUDScene)
    AttachScene(rawget(_G, "HUD_UI_SCENE"), OnHUDScene)
    AttachScene(rawget(_G, "WORLD_MAP_SCENE"), OnWorldScene)
    AttachScene(rawget(_G, "GAMEPAD_WORLD_MAP_SCENE"), OnWorldScene)
    AttachScene(rawget(_G, "SCRYING_SCENE"), OnWorldScene)
end

function Core:Ensure(reason)
    if not BUI.Vars then return false end
    if reason ~= "PLAYER_MAP_RETRY" then mapRetryCount = 0 end
    AttachScenes()
    if not BUI.Vars.MiniMap then
        wantedVisible = false
        Mini.MapSceneIsShowing = FullMapShowing()
        Mini.init = false
        BUI.init.MiniMap = false
        EVENT_MANAGER:UnregisterForUpdate(FOLLOW_NAME)
        UpdateHUDFragments(false)
        local container = rawget(_G, "BUI_Minimap")
        if container then container:SetHidden(true) end
        ResetFullMapVisuals()
        if announcedVisible and CALLBACK_MANAGER then CALLBACK_MANAGER:FireCallbacks("BUI_MiniMap_Shown", false) end
        announcedVisible = false
        if mapMode and WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.GetMode
            and WORLD_MAP_MANAGER:GetMode() == mapMode and WORLD_MAP_MANAGER.SetToMode
            and rawget(_G, "MAP_MODE_LARGE_CUSTOM") then
            pcall(WORLD_MAP_MANAGER.SetToMode, WORLD_MAP_MANAGER, MAP_MODE_LARGE_CUSTOM)
        end
        return true
    end
    if not MapControlReady() then
        retryCount = retryCount + 1
        if retryCount <= 6 then Schedule(math.min(2500, 350 * retryCount), "CONTROLS_RETRY") end
        return false
    end
    Mini.MapPanAndZoom = ZO_WorldMap_GetPanAndZoom()
    Mini.PinManager = ZO_WorldMap_GetPinManager()
    if not Mini.MapPanAndZoom or not Mini.PinManager then
        retryCount = retryCount + 1
        if retryCount <= 6 then Schedule(500 * retryCount, "MANAGER_RETRY") end
        return false
    end
    if not CreateMode() then
        retryCount = retryCount + 1
        if retryCount <= 6 then Schedule(500 * retryCount, "MODE_RETRY") end
        return false
    end
    retryCount = 0
    EnsureContainer()
    UpdateHUDFragments(true)
    if FullMapShowing() then
        Mini.MapSceneIsShowing = true
        wantedVisible = false
        BUI.init.MiniMap = false
        EVENT_MANAGER:UnregisterForUpdate(FOLLOW_NAME)
        ResetFullMapVisuals()
        if WORLD_MAP_MANAGER.GetMode and WORLD_MAP_MANAGER:GetMode() == mapMode
            and WORLD_MAP_MANAGER.SetToMode and rawget(_G, "MAP_MODE_LARGE_CUSTOM") then
            pcall(WORLD_MAP_MANAGER.SetToMode, WORLD_MAP_MANAGER, MAP_MODE_LARGE_CUSTOM)
        end
        if announcedVisible and Mini.MapPanAndZoom.SetCurrentNormalizedZoomInternal then
            pcall(Mini.MapPanAndZoom.SetCurrentNormalizedZoomInternal, Mini.MapPanAndZoom,
                math.max(0, math.min(1, (tonumber(BUI.Vars.ZoomGlobal) or 3) / 100)))
        end
        if announcedVisible and CALLBACK_MANAGER then CALLBACK_MANAGER:FireCallbacks("BUI_MiniMap_Shown", false) end
        announcedVisible = false
        return true
    end
    if WORLD_MAP_MANAGER.inSpecialMode
        or (WORLD_MAP_MANAGER.IsPreventingMapNavigation and WORLD_MAP_MANAGER:IsPreventingMapNavigation()) then
        Schedule(450, "SPECIAL_MODE_WAIT")
        return false
    end
    if WORLD_MAP_MANAGER.GetMode and WORLD_MAP_MANAGER:GetMode() ~= mapMode then
        local ok = pcall(WORLD_MAP_MANAGER.SetToMode, WORLD_MAP_MANAGER, mapMode)
        if not ok or WORLD_MAP_MANAGER:GetMode() ~= mapMode then
            Schedule(500, "MODE_RETRY")
            return false
        end
    end
    Mini.MapSceneIsShowing = false
    NativeMapLayout()
    if rawget(_G, "ZO_MapPin") and ZO_MapPin.PIN_DATA then
        if Mini.PinColors and BUI.Vars.PinColor then Mini.PinColors() end
        if Mini.ResizePins then Mini.ResizePins(true) end
    end
    local mapReady = RefreshPlayerMap()
    local tile = type(GetMapTileTexture) == "function" and GetMapTileTexture() or nil
    if mapReady and tile ~= nil and tile ~= "" then
        mapRetryCount = 0
    else
        mapRetryCount = mapRetryCount + 1
        if mapRetryCount <= 4 then Schedule(400 * mapRetryCount, "PLAYER_MAP_RETRY") end
    end
    local mapId = type(GetCurrentMapId) == "function" and GetCurrentMapId() or tile
    local mapType = type(GetMapContentType) == "function" and GetMapContentType() or nil
    if lastMapId ~= mapId or lastMapType ~= mapType or reason == "SETTINGS" or reason == "SHOW" or reason == "MOUNTED"
        or reason == "WORLD_MAP_CLOSED" then
        lastMapId, lastMapType = mapId, mapType
        if Mini.MapPanAndZoom.SetCurrentNormalizedZoomInternal then
            pcall(Mini.MapPanAndZoom.SetCurrentNormalizedZoomInternal, Mini.MapPanAndZoom, DesiredZoom())
        end
    end
    wantedVisible = true
    BUI.init.MiniMap = true
    Mini.CurrentMapId = mapId
    Mini.Environment = Mini.GetMinimapEnvironment and Mini.GetMinimapEnvironment() or "WORLD"
    if rawget(_G, "WORLD_MAP_FRAGMENT") and WORLD_MAP_FRAGMENT.Refresh then WORLD_MAP_FRAGMENT:Refresh() end
    if ZO_WorldMap:IsHidden() and (SceneShowing(rawget(_G, "HUD_SCENE")) or SceneShowing(rawget(_G, "HUD_UI_SCENE"))) then
        ZO_WorldMap:SetHidden(false)
        Schedule(250, "FRAGMENT_VISIBILITY_RETRY")
    end
    StartFollow()
    CenterPlayer()
    if not announcedVisible and CALLBACK_MANAGER then CALLBACK_MANAGER:FireCallbacks("BUI_MiniMap_Shown", true) end
    announcedVisible = true
    Log("validated: " .. tostring(reason or "UNKNOWN"))
    return true
end

function Mini.EnsureMinimapState(reason) return Core:Ensure(reason) end
function Mini.Initialize()
    if not Mini.SettingsReady then
        Mini.Settings_Init()
        Mini.SettingsReady = true
    end
    if not registered then
        registered = true
        EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_PLAYER_ACTIVATED,
            function() Schedule(250, "PLAYER_ACTIVATED") end)
        if rawget(_G, "EVENT_PLAYER_DEACTIVATED") then
            EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_PLAYER_DEACTIVATED, function()
                wantedVisible = false
                EVENT_MANAGER:UnregisterForUpdate(FOLLOW_NAME)
                if WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.inSpecialMode and WORLD_MAP_MANAGER.PopSpecialMode then
                    pcall(WORLD_MAP_MANAGER.PopSpecialMode, WORLD_MAP_MANAGER)
                end
            end)
        end
        if rawget(_G, "EVENT_PLAYER_ALIVE") then
            EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_PLAYER_ALIVE, function() Schedule(300, "RESPAWN") end)
        end
        if rawget(_G, "EVENT_PLAYER_DEAD") then
            EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_PLAYER_DEAD, function() Schedule(300, "DEATH") end)
        end
        if rawget(_G, "EVENT_ACCESSIBILITY_MODE_CHANGED") then
            EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_ACCESSIBILITY_MODE_CHANGED,
                function() Schedule(200, "ACCESSIBILITY_MODE") end)
        end
        EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_ZONE_CHANGED,
            function() Schedule(200, "ZONE_CHANGED") end)
        if rawget(_G, "EVENT_ZONE_UPDATE") then
            EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_ZONE_UPDATE,
                function(_, unitTag) if unitTag == "player" then Schedule(250, "ZONE_UPDATE") end end)
        end
        if rawget(_G, "EVENT_CURRENT_SUBZONE_LIST_CHANGED") then
            EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_CURRENT_SUBZONE_LIST_CHANGED,
                function() Schedule(250, "SUBZONE_CHANGED") end)
        end
        if rawget(_G, "EVENT_PLAYER_TELEPORTED_LOCALLY") then
            EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_PLAYER_TELEPORTED_LOCALLY,
                function() Schedule(300, "TELEPORTED") end)
        end
        if rawget(_G, "EVENT_MOUNTED_STATE_CHANGED") then
            EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_MOUNTED_STATE_CHANGED,
                function() Schedule(100, "MOUNTED") end)
        end
        if rawget(_G, "EVENT_SCREEN_RESIZED") then
            EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_SCREEN_RESIZED,
                function() Schedule(100, "SCREEN_RESIZED") end)
        end
        if rawget(_G, "EVENT_GAMEPAD_PREFERRED_MODE_CHANGED") then
            EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
                function() Schedule(200, "GAMEPAD_MODE") end)
        end
        if CALLBACK_MANAGER then
            CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
                if not refreshing then Schedule(150, "WORLD_MAP_CHANGED") end
            end)
        end
    end
    Core:Ensure("INITIALIZE")
    Schedule(750, "INITIALIZE_RETRY")
end

function Mini.Show() return Core:Ensure("SHOW") end
function Mini.ReInit() return Core:Ensure("SETTINGS") end
function Mini.Restore() return Core:Ensure("WORLD_MAP_OPEN") end
function Mini.ZoneChanged() Schedule(100, "ZONE_CHANGED") end
function Mini.RefreshMapContext(reason) return Core:Ensure(reason or "MAP_CONTEXT") end
function Mini.UpdatePosition() if not FullMapShowing() then NativeMapLayout() end end
function Mini.UpdateDimensions() if not FullMapShowing() then NativeMapLayout() end end
function Mini.SetSize(value)
    BUI.Vars.MiniMapDimensions = math.max(200, math.min(500, tonumber(value) or 250))
    return Core:Ensure("SETTINGS")
end
function Mini.ApplyTransparency()
    if not FullMapShowing() and ZO_WorldMap then
        ZO_WorldMap:SetAlpha(math.max(0, math.min(1, (tonumber(BUI.Vars.MiniMapAlpha) or 100) / 100)))
    end
end
function Mini.ZoomUpdate() return Core:Ensure("SETTINGS") end
function Mini.OnMount() Schedule(100, "MOUNTED") end
function Mini.SnapMinimapToPlayer() CenterPlayer() end
function Mini.Update() FollowTick() end

if CALLBACK_MANAGER then
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapSavedVarsReady", function(vars)
        mapVars = vars
        Schedule(50, "MAP_VARS_READY")
    end)
end

