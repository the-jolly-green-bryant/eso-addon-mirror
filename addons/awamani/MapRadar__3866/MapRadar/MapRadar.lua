MapRadar = {
    pinPool = ZO_ControlPool:New("PinTemplate", MapRadarContainer, "Pin"),
    pointerPool = ZO_ControlPool:New("PointerTemplate", MapRadarContainer, "Pointer"),
    pinLabelPool = ZO_ControlPool:New("LabelTemplate", MapRadarContainer, "Distance"),

    maxRadarDistance = 0, -- limit distance to keep icons on radar outer edge (is set in setOverlayMode())
    pinSize = 0, -- positionLabel = {},
    activePins = {},
    customPinLayer = {},
    modeSettings = {},
    scale = 1, -- This meant to be used and scale param when measuring and calibrating pins on different zones
    value = function(valueOrMethod, ...)
        if type(valueOrMethod) == "function" then
            -- MapRadar.debugDebounce("Execute method with params: <<1>>", MapRadar.getStrVal(...))
            return valueOrMethod(...)
        else
            return valueOrMethod
        end
    end, -- ==================================================================================================
    -- Debug stuff
    showAllPins = false,
    showPinLoc = false,
    showPinNames = false,
    showPinParams = false,
    debug = function(formatString, ...)
        d(zo_strformat(formatString, ...))
    end,
    lastdebugMsg = "",
    debugDebounce = function(formatString, ...)
        local msg = zo_strformat(formatString, ...)

        if MapRadar.lastdebugMsg == msg then
            return
        end

        d(msg)

        MapRadar.lastdebugMsg = msg
    end,
    getStrVal = function(obj)
        if obj == nil then
            return "nil"
        end
        return tostring(obj)
    end,
    tablelength = function(T)
        local count = 0
        for _ in pairs(T) do
            count = count + 1
        end
        return count
    end,
    listElements = function(obj)
        MapRadar.debug("-------------------------------------------------")
        for key, val in pairs(obj) do
            MapRadar.debug("<<1>>: <<2>>", key, MapRadar.getStrVal(val))
        end
    end
 }

local MR = MapRadar
local radarTexture = MapRadarContainerRadarTexture

-- Localize global objects for better performance
local sceneManager = SCENE_MANAGER
local getPlayerCameraHeading = GetPlayerCameraHeading
local getMapPlayerPosition = GetMapPlayerPosition
local pinManager = ZO_WorldMap_GetPinManager()

local UIWidth, UIHeight = GuiRoot:GetDimensions()
local playerPin = pinManager:GetPlayerPin()
local pinsPool = ZO_ControlPool:New("PinTemplate", MapRadarContainer, "Pin")
local pointerPool = ZO_ControlPool:New("PointerTemplate", MapRadarContainer, "Pointer")
local distanceLabelPool = ZO_ControlPool:New("LabelTemplate", MapRadarContainer, "Distance")

-- https://esoapi.uesp.net/100031/src/ingame/map/mappin.lua.html
-- https://esodata.uesp.net/100025/src/ingame/map/worldmap.lua.html
local function registerMapPins()

    if sceneManager:IsShowing("worldMap") then
        return -- Block further execution while map is opened
    end

    local pins = pinManager:GetActiveObjects()

    -- TODO: Should this IsValidPin check be here? or in the pin class?

    -- Dispose invalid pins
    for k, radarPin in pairs(MR.activePins) do
        if radarPin.isCorrupted or not MapRadarPin:IsValidPin(radarPin.pin) or pins[k] ~= radarPin.pin then
            MR.activePins[k]:Dispose()
            MR.activePins[k] = nil
        end
    end

    local playerX, playerY = getMapPlayerPosition("player")
    local heading = getPlayerCameraHeading()

    -- Add new pins that did not exist
    for key, pin in pairs(pins) do
        if MR.activePins[key] == nil and MapRadarPin:IsValidPin(pin) and pin.normalizedX and pin.normalizedY then
            local radarPin = MapRadarPin:New(pin, key)
            radarPin:UpdatePin(playerX, playerY, heading, true)
            MR.activePins[key] = radarPin
        end
    end
end

-- ==================================================================================================
-- Mode change
local function setVisibilityForRadarTexture()
    local isHidden = MR.config.isOverlayMode or MR.config.radarSettings.hideRadarTexture
    radarTexture:SetHidden(isHidden)
end

local function setOverlayMode(flag)
    MR.playerPinTexture:ClearAnchors()

    if flag then
        MR.playerPinTexture:SetAnchor(CENTER, GuiRoot, BOTTOM, 0, -UIHeight * 0.4)
        MR.maxRadarDistance = UIHeight * 0.5
        MR.pinSize = 25
    else
        MR.playerPinTexture:SetAnchor(CENTER, MapRadarContainer, CENTER)
        MR.maxRadarDistance = 110
        MR.pinSize = 20
    end

    MR.config.isOverlayMode = flag

    if flag then
        MR.modeSettings = MR.config.overlaySettings
    else
        MR.modeSettings = MR.config.radarSettings
    end

    setVisibilityForRadarTexture()
    CALLBACK_MANAGER:FireCallbacks("MapRadar_Reset")
end

local function updateOverlay()
    if MR.config.isOverlayMode then
        setOverlayMode(true)
    end
end

-- ==================================================================================================
-- Event handlers
local playerHeading, playerX, playerY = 0, 0, 0
local function mapUpdate()
    if sceneManager:IsShowing("worldMap") then
        return -- Block further execution while map is opened
    end

    local px, py = getMapPlayerPosition("player")
    local heading = getPlayerCameraHeading()

    local hasPlayerMoved = playerHeading ~= heading or playerX ~= px or playerY ~= py
    playerHeading = heading
    playerX = px
    playerY = py

    radarTexture:SetTextureRotation(-heading, 0.5, 0.5)

    -- reposition pins
    for key, radarPin in pairs(MR.activePins) do
        radarPin:UpdatePin(playerX, playerY, heading, hasPlayerMoved)
    end

    if hasPlayerMoved then
        for key, customPin in pairs(MR.customPinLayer) do
            customPin:UpdatePin(playerX, playerY, heading, hasPlayerMoved)
        end
    end
end

local function mapPinIntegrityCheck()
    for key, radarPin in pairs(MR.activePins) do
        if not radarPin:CheckIntegrity() then
            radarPin.isCorrupted = true
            CALLBACK_MANAGER:FireCallbacks("MapRadar_CorruptedPin")
        end
    end
end

-- ==================================================================================================
-- Custom pin layer methods

local function MapRadar_ClearHarvestPins()
    -- Dispose pins
    for k, _ in pairs(MR.customPinLayer) do
        MR.customPinLayer[k]:Dispose()
        MR.customPinLayer[k] = nil
    end
end

local function MapRadar_LoadHarvestPins()

    MapRadar_ClearHarvestPins()

    if not MapRadar.modeSettings.showHarvestMap then
        return
    end

    local harvestMapPins = Harvest["mapPins"]

    -- -- List Harvest mapPins module elements
    -- MR.debug("harvestMapPins module -------------------------------------------------")
    -- for key, v in pairs(harvestMapPins) do
    --     MR.debug("<<1>>: <<2>>", key, MR.getStrVal(v))
    -- end

    -- This can be null if Harvest has disabled "Show on minimap"
    if (harvestMapPins.mapCache) then
        -- MR.debug("harvestMapPins.mapCache --------------------------------------------------")
        -- for key, v in pairs(harvestMapPins.mapCache) do
        --     MR.debug("<<1>>: <<2>>", key, MR.getStrVal(v))
        -- end

        local playerX, playerY = getMapPlayerPosition("player")
        local heading = getPlayerCameraHeading()

        -- MR.debug("harvestMapPins.mapCache.divisions --------------------------------------------------")
        for pinTypeId, division in pairs(harvestMapPins.mapCache.divisions) do

            if Harvest.InRangePins.worldFilterProfile[pinTypeId] then
                -- MR.debug("-------------------- PinTypeId <<1>>", MR.getStrVal(pinTypeId))

                for diviKey, divI in pairs(division) do
                    -- MR.debug("<<1>>: <<2>> --------------", diviKey, MR.getStrVal(divI))

                    for nodeKey, nodeId in pairs(divI) do
                        local x, y = harvestMapPins.mapCache:GetLocal(nodeId)
                        local texturePath = Harvest.settings.savedVars.settings.pinLayouts[pinTypeId].texture
                        -- MR.debug("<<1>>: <<2>>  (<<3>> <<4>>) <<5>>", nodeKey, MR.getStrVal(nodeId), MR.getStrVal(x), MR.getStrVal(y), texturePath)

                        local customPin = MapRadarHarvestPin:New(nodeId, x, y, pinTypeId, texturePath)
                        customPin:UpdatePin(playerX, playerY, heading, true)
                        MR.customPinLayer[nodeId] = customPin
                        -- MR.debug("Added customPin with key: <<1>>", nodeId)
                    end

                end
            end
        end
    end

end

-- ==================================================================================================
-- Init / Load

local function initialize(eventType, addonName)
    if addonName ~= "MapRadar" then
        return
    end

    CALLBACK_MANAGER:FireCallbacks("OnMapRadarInitializing")

    local playerPinTexture = CreateControl("$(parent)PlayerPin", MapRadarContainer, CT_TEXTURE)
    playerPinTexture:SetTexture("EsoUI/Art/MapPins/UI-WorldMapPlayerPip.dds")
    playerPinTexture:SetDimensions(20, 20)
    playerPinTexture:SetAlpha(0.5)
    MR.playerPinTexture = playerPinTexture

    -- Set mode to radar from start (should be saved to variables later)
    setOverlayMode(MR.config.isOverlayMode);

    local fragment = ZO_SimpleSceneFragment:New(MapRadarContainer)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)

    EVENT_MANAGER:RegisterForUpdate("MapRadar_OnUpdate", 30, mapUpdate)
    EVENT_MANAGER:RegisterForUpdate("MapRadar_PinRefresh", 200, registerMapPins)
    EVENT_MANAGER:RegisterForUpdate("MapRadar_PinCheck", 300, mapPinIntegrityCheck)

    CALLBACK_MANAGER:RegisterCallback(
        "MapRadar_Reset", function()
            playerHeading = 0

            MapRadar_LoadHarvestPins()
            setVisibilityForRadarTexture()
        end)

    CALLBACK_MANAGER:FireCallbacks("OnMapRadarInitialized")
end

local function onPlayerActivated(eventCode, initial)
    -- All addons already loaded at this stage.
    if Harvest then
        -- Guard against HarvestMap renaming/removing events (e.g. NEW_NODES_LOADED_TO_CACHE
        -- was replaced by NEW_ZONE_ENTERED), so a missing event degrades gracefully
        -- instead of crashing on login inside CallbackManager:RegisterCallback.
        local function safeRegister(eventId, callback)
            if eventId then
                Harvest.callbackManager:RegisterCallback(eventId, callback)
            end
        end

        safeRegister(
            Harvest.events.NEW_ZONE_ENTERED, function()
                MapRadar_LoadHarvestPins()
            end)

        safeRegister(
            Harvest.events.MAP_CHANGE, function()
                MapRadar_LoadHarvestPins()
            end)

        safeRegister(
            Harvest.events.FILTER_PROFILE_CHANGED, function()
                MapRadar_LoadHarvestPins()
            end)
    end

    -- Prevents from firing this event each zone change
    EVENT_MANAGER:UnregisterForEvent("MapRadar", EVENT_PLAYER_ACTIVATED)
end

-- ==================================================================================================
-- Event subscription

-- This is good to trigger pin reset (if quest changes 1 marker then pin count check does not see difference)
EVENT_MANAGER:RegisterForEvent(
    "MapRadar", EVENT_QUEST_ADVANCED, function()
        zo_callLater(registerMapPins, 200)
    end)

EVENT_MANAGER:RegisterForEvent(
    "MapRadar", EVENT_QUEST_COMPLETE, function()
        zo_callLater(registerMapPins, 200)
    end)

EVENT_MANAGER:RegisterForEvent(
    "MapRadar", EVENT_QUEST_ADDED, function()
        zo_callLater(registerMapPins, 200)
    end)

EVENT_MANAGER:RegisterForEvent(
    "MapRadar", EVENT_QUEST_POSITION_REQUEST_COMPLETE, function()
        zo_callLater(registerMapPins, 200)
    end)

EVENT_MANAGER:RegisterForEvent(
    "MapRadar", EVENT_QUEST_CONDITION_COUNTER_CHANGED, function()
        zo_callLater(registerMapPins, 200)
    end)

EVENT_MANAGER:RegisterForEvent(
    "MapRadar", EVENT_ALL_GUI_SCREENS_RESIZED, function()
        UIWidth, UIHeight = GuiRoot:GetDimensions()
        updateOverlay()
    end)

EVENT_MANAGER:RegisterForEvent("MapRadar", EVENT_ADD_ON_LOADED, initialize)
EVENT_MANAGER:RegisterForEvent("MapRadar", EVENT_PLAYER_ACTIVATED, onPlayerActivated)
-- ==================================================================================================
-- Key binding

local hotkeyDebouncer = MapRadarCommon.Debouncer:New(
    function(count)

        if count == 1 then
            return setOverlayMode(not MR.config.isOverlayMode)
        end

        if count == 2 then
            return MapRadar_toggleSettings()
        end

        if count == 3 then
            -- ZO_ActionBarAssignmentManager:SetCurrentHotbar(HOTBAR_CATEGORY_BACKUP)
            -- ZO_ActionBarAssignmentManager.hotbarProxy()

            -- local addonManager = GetAddOnManager()

            -- for i = 1, addonManager:GetNumAddOns() do
            --     local name, _, _, _, _, state = addonManager:GetAddOnInfo(i)
            --     if state == ADDON_STATE_ENABLED then
            --         MR.debug(name)
            --     end
            -- end

            local x, y = getMapPlayerPosition("player")
            PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, x, y)
        end

    end)

ZO_CreateStringId("SI_BINDING_NAME_MAPRADAR_HOTKEY", "Hotkey")

-- Handler for configured hotkey
function MapRadar_Hotkey()
    hotkeyDebouncer:Invoke()
end

-- ==================================================================================================
-- Slash commands
local function slashCommands(args)
    if args == "config" then
        MapRadar_toggleSettings()
    end

    if args == "mode" then
        setOverlayMode(not MR.config.isOverlayMode)
    end

    if args == "all" then
        MR.showAllPins = not MR.showAllPins
        local flagStr = MR.showAllPins and "ON" or "OFF"
        MR.debug("Show all pins: <<1>>", flagStr)
    end

    if args == "names" then
        MR.showPinNames = not MR.showPinNames
        local flagStr = MR.showPinNames and "ON" or "OFF"
        MR.debug("Show names: <<1>>", flagStr)
    end

    if args == "para" then
        MR.showPinParams = not MR.showPinParams
        local flagStr = MR.showPinParams and "ON" or "OFF"
        MR.debug("Show params: <<1>>", flagStr)
    end

    if args == "calibrate" then
        MR.config.showCalibrate = not MR.config.showCalibrate
        local flagStr = MR.config.showCalibrate and "ON" or "OFF"
        MR.debug("Show calibrate: <<1>>", flagStr)
    end

    if args == "analyzer" then
        MR.config.showAnalyzer = not MR.config.showAnalyzer
        local flagStr = MR.config.showAnalyzer and "ON" or "OFF"
        MR.debug("Show analyzer: <<1>>", flagStr)
    end

    if args == "speed" then
        MR.config.showSpeedometer = not MR.config.showSpeedometer
        local flagStr = MR.config.showSpeedometer and "ON" or "OFF"
        MR.debug("Show Speedometer: <<1>>", flagStr)
    end

    if args == "wipe asc" then
        MapRadar.accountData.worldScaleData = {}
        MR.debug("Wiped Account world scale data")
    end

    local wipeMapMatch = string.match(args, "wipe asc (%d+)")
    if wipeMapMatch then
        local mapId = tonumber(wipeMapMatch)
        if MapRadar.accountData.worldScaleData[mapId] then
            MapRadar.accountData.worldScaleData[mapId] = nil
            MR.debug("Wiped Account world scale data for mapId: <<1>>", mapId)
        end
    end

    if args == "recalibrate" then
        local mapId = GetCurrentMapId()
        MapRadarAutoscaled[mapId] = nil
        MapRadar.accountData.worldScaleData[mapId] = nil
        MR.debug("Recalibrating mapId: <<1>>", mapId)
    end

    CALLBACK_MANAGER:FireCallbacks("MapRadar_Reset")
    CALLBACK_MANAGER:FireCallbacks("OnMapRadarSlashCommand", args)
end

SLASH_COMMANDS["/mapradar"] = slashCommands
SLASH_COMMANDS["/mr"] = slashCommands

-- ==================================================================================================
-- Test stuff 

-- GetCurrentMapIndex() 
-- GetPlayerActiveSubzoneName() -> Returns: string subzoneName 
-- GetPlayerActiveZoneName() -> Returns: string zoneName 

-- local worldMapMode = WORLD_MAP_MANAGER:GetMode()
--[[
MAP_MODE_AVA_KEEP_RECALL
	6
MAP_MODE_AVA_RESPAWN
	5
MAP_MODE_DIG_SITES
	7
MAP_MODE_FAST_TRAVEL
	4
MAP_MODE_KEEP_TRAVEL
	3
MAP_MODE_LARGE_CUSTOM
	2
MAP_MODE_SMALL_CUSTOM
--]]

-- ZO_WorldMapScroll:IsHidden()
-- WORLD_MAP_AUTO_NAVIGATION_OVERLAY_FRAGMENT:IsShowing()
-- SCENE_MANAGER:IsShowing("worldMap")

-- local zoneId, pwx1, pwh1, pwy1 = GetUnitRawWorldPosition("player")
-- local _, pwx2, pwh2, pwy2 = GetUnitWorldPosition("player")

-- GetMapTileTexture()    whats that??

--[[
local x, y = GetMapPlayerPosition("player")
local numTiles = GetMapNumTiles()
local tilePixelWidth = ZO_WorldMapContainer1:GetTextureFileDimensions()
local totalPixels = numTiles * tilePixelWidth
local w, h = ZO_WorldMapScroll:GetDimensions()
]]

-- 			needChange, oldMapType, mapId = not DoesCurrentMapMatchMapForPlayerLocation(), GetMapType(), GetMapTileTexture()
-- DoesCurrentMapShowPlayerWorld()

-- Search on ESOUI Source Code WorldPositionToGuiRender3DPosition(integer worldX, integer worldY, integer worldZ)
-- Returns: number renderX, number renderY, number renderZ 

-- 	local subzone=string.match(string.gsub(GetMapTileTexture(),"_base[_%w]*",""),"([%w%-_]+).dds$")

-- GetMapType(), -- Returns: UIMapType mapType: https://wiki.esoui.com/Globals#UIMapType
