local ADDON_NAME = "OnixWorldmap"
local ADDON_VERSION = "1.0.0"

local UPDATE_HANDLE = "OnixRealtimeFrameUpdater"
local ringControl = nil
local isHighlightActive = false
local isHooksInstalled = false
local startTime = 0
local lastNavTime = 0
local NAV_COOLDOWN = 0.40

local RING_TEXTURE = "OnixWorldmap/mapicons/player_ring3.dds"

local db = {}
local defaults = {
    maxZoomLimit = 8.00,
    forceOpenZoom = true,
    initialOpenZoom = 30,
    zoneChangeZoom = 0,
    enableHighlight = true,
    displayDuration = 2.0,
    panToPlayer = true,
    triggerOnZoom = true,
    ringSize = 144,
    ringOpacity = 100,
    pulseSpeed = 1.4,
    ringColor = { r = 0.0, g = 0.9254902005, b = 0.9803921580, a = 0.9803921580 },
    enableZoomOutAscend = true,
    zoomOutThreshold = 5,
    enableZoomInDescend = true,
    zoomInThreshold = 95,
}

local function GetUserMax()
    return db.maxZoomLimit or defaults.maxZoomLimit
end

local function ApplyZoom(pz)
    pz = pz or ZO_WorldMap_GetPanAndZoom()
    if not pz then return end

    local userMax = GetUserMax()
    pz.minZoom = 1.0
    pz.maxZoom = userMax
    pz.mapMin = 1.0
    pz.mapMax = userMax

    if pz.zoomSlider then
        pz.zoomSlider:SetMinMax(0.0, 1.0)
    end
end

local function ForceApplyOpenZoom()
    if not db.forceOpenZoom then return end

    local pz = ZO_WorldMap_GetPanAndZoom()
    if not pz then return end

    ApplyZoom(pz)

    local targetNorm = (db.initialOpenZoom or 0) / 100.0

    pz:SetCurrentNormalizedZoom(targetNorm)
    pz:SetTargetNormalizedZoom(targetNorm)
    if pz.zoomSlider then
        pz.zoomSlider:SetValue(targetNorm)
    end
end

local function TriggerMapAscend()
    if not db.enableZoomOutAscend then return end

    local now = GetFrameTimeSeconds()
    if (now - lastNavTime) < NAV_COOLDOWN then return end
    lastNavTime = now

    local container = ZO_WorldMapContainer
    local onMouseUp = container and container:GetHandler("OnMouseUp")
    if onMouseUp then
        onMouseUp(container, 2, true)
    end
end

local function TriggerMapDescend()
    if not db.enableZoomInDescend then return end

    local now = GetFrameTimeSeconds()
    if (now - lastNavTime) < NAV_COOLDOWN then return end
    lastNavTime = now

    local container = ZO_WorldMapContainer
    local onMouseUp = container and container:GetHandler("OnMouseUp")
    if onMouseUp then
        onMouseUp(container, 1, true)
    end
end

local function StopHighlight()
    isHighlightActive = false
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_HANDLE)
    if ringControl then
        ringControl:SetHidden(true)
    end
end

local function CreateHighlightControl()
    if ringControl then return ringControl end

    local container = ZO_WorldMapContainer
    if not container then return nil end

    ringControl = WINDOW_MANAGER:CreateControl("OnixPlayerMapHighlightRing", container, CT_TEXTURE)
    ringControl:SetTexture(RING_TEXTURE)

    local c = db.ringColor or defaults.ringColor
    ringControl:SetColor(c.r, c.g, c.b, c.a)
    ringControl:SetDrawLayer(DL_OVERLAY)
    ringControl:SetDrawTier(DT_HIGH)
    ringControl:SetDrawLevel(30)

    ringControl:ClearAnchors()
    ringControl:SetAnchor(CENTER, container, TOPLEFT, 0, 0)
    ringControl:SetHidden(true)

    return ringControl
end

local function RenderFrame()
    if not db.enableHighlight or not isHighlightActive or not ringControl or ZO_WorldMap:IsHidden() then
        StopHighlight()
        return
    end

    local now = GetGameTimeMilliseconds()
    local elapsed = now - startTime
    local maxDurationMs = (db.displayDuration or defaults.displayDuration) * 1000

    if elapsed >= maxDurationMs then
        StopHighlight()
        return
    end

    local normX, normY = GetMapPlayerPosition("player")
    if not normX or not normY or normX <= 0 or normX >= 1 or normY <= 0 or normY >= 1 then
        ringControl:SetHidden(true)
        return
    end

    local container = ZO_WorldMapContainer
    if not container then
        StopHighlight()
        return
    end

    local mapWidth, mapHeight = container:GetDimensions()
    if mapWidth > 0 and mapHeight > 0 then
        local localX = normX * mapWidth
        local localY = normY * mapHeight
        ringControl:SetAnchorOffsets(localX, localY)
    end

    local pSpeedMs = math.max(100, (db.pulseSpeed or defaults.pulseSpeed) * 1000)
    local progress = (elapsed % pSpeedMs) / pSpeedMs
    local wave = 0.5 * (1 + math.sin((progress * math.pi * 2) - (math.pi / 2)))
    local scale = 0.15 + (1.35 * wave)

    local baseSize = db.ringSize or defaults.ringSize
    ringControl:SetDimensions(baseSize * scale, baseSize * scale)

    local baseAlpha = (db.ringOpacity or defaults.ringOpacity) / 100
    local remaining = maxDurationMs - elapsed
    if remaining < 600 then
        ringControl:SetAlpha(baseAlpha * (remaining / 600))
    else
        ringControl:SetAlpha(baseAlpha)
    end

    ringControl:SetHidden(false)
end

local function TriggerHighlight(forceNoPan)
    if not db.enableHighlight or ZO_WorldMap:IsHidden() then
        StopHighlight()
        return
    end

    local normX, normY = GetMapPlayerPosition("player")
    if not normX or not normY or normX <= 0 or normX >= 1 or normY <= 0 or normY >= 1 then
        return
    end

    if not forceNoPan and db.panToPlayer then
        local pz = ZO_WorldMap_GetPanAndZoom()
        if pz and pz.PanToNormalizedPosition then
            pz:PanToNormalizedPosition(normX, normY)
        end
    end

    local ring = CreateHighlightControl()
    if not ring then return end

    startTime = GetGameTimeMilliseconds()
    isHighlightActive = true

    EVENT_MANAGER:UnregisterForUpdate(UPDATE_HANDLE)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_HANDLE, 16, RenderFrame)
    RenderFrame()
end

local function HandleMapScroll(delta)
    local pz = ZO_WorldMap_GetPanAndZoom()
    if not pz then return false end

    ApplyZoom(pz)

    if db.triggerOnZoom then
        TriggerHighlight(true)
    end

    local currentNorm = pz:GetCurrentNormalizedZoom() or 0.0
    local currentPercent = currentNorm * 100

    local outThresh = db.zoomOutThreshold or defaults.zoomOutThreshold
    local inThresh = db.zoomInThreshold or defaults.zoomInThreshold

    if delta < 0 then
        if not db.enableZoomOutAscend then
            return false
        end

        if currentPercent <= outThresh then
            TriggerMapAscend()
            return true
        end

    elseif delta > 0 then
        if not db.enableZoomInDescend then
            return false
        end

        if currentPercent >= inThresh then
            TriggerMapDescend()
            return true
        end
    end

    return false
end

local function InstallZoomHooks()
    if isHooksInstalled then return end

    local pz = ZO_WorldMap_GetPanAndZoom()
    if not pz then return end

    isHooksInstalled = true

    local origCompute = pz.ComputeZoomLimits
    if origCompute then
        pz.ComputeZoomLimits = function(self, ...)
            origCompute(self, ...)
            ApplyZoom(self)
        end
    end

    local origSetMapCustom = pz.SetMapCustom
    if origSetMapCustom then
        pz.SetMapCustom = function(self, ...)
            origSetMapCustom(self, ...)
            ApplyZoom(self)
        end
    end

    local origSetMap = pz.SetMap
    if origSetMap then
        pz.SetMap = function(self, ...)
            origSetMap(self, ...)
            ApplyZoom(self)
        end
    end

    local origAddZoom = pz.AddZoom
    if origAddZoom then
        pz.AddZoom = function(self, delta, ...)
            ApplyZoom(self)
            return origAddZoom(self, delta, ...)
        end
    end

    ZO_PreHookHandler(ZO_WorldMapContainer, "OnMouseWheel", function(self, delta)
        return HandleMapScroll(delta)
    end)

    ZO_PreHookHandler(ZO_WorldMap, "OnMouseWheel", function(self, delta)
        return HandleMapScroll(delta)
    end)
end

local function ResetToDefaults()
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            db[k] = ZO_DeepTableCopy(v)
        else
            db[k] = v
        end
    end

    if ringControl then
        local c = db.ringColor
        ringControl:SetColor(c.r, c.g, c.b, c.a)
        ringControl:SetDimensions(db.ringSize, db.ringSize)
        ringControl:SetAlpha(db.ringOpacity / 100)
        ringControl:SetTexture(RING_TEXTURE)
    end

    ApplyZoom()
    ForceApplyOpenZoom()
end

local function CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "0nix Worldmap",
        displayName = "|cF8F8F80nix|r |cFFFABBWorldmap|r - |c55FF55Easy Navigation|r",
        author = "|cc0c0c0NATOSZ|r",
        version = "|c00FF66" .. ADDON_VERSION .. "|r",
        registerForDefaults = true,
        registerForRefresh = true,
    }

    local optionsData = {
        {
            type = "header",
            name = "|cFFFFFFGlobal Settings & Zoom Configuration|r",
        },
        {
            type = "button",
            name = "|cFF3333Reset to Default Settings|r",
            tooltip = "Resets all settings back to recommended default values.",
            warning = "|cFF2222WARNING:|r Are you sure you want to restore all settings to default values?",
            func = function()
                ResetToDefaults()
            end,
        },
        {
            type = "checkbox",
            name = "Force Zoom Level on Map Open (M)",
            tooltip = "Overrides the remembered zoom level exclusively when you open the map by pressing M.",
            getFunc = function()
                if db.forceOpenZoom == nil then return defaults.forceOpenZoom end
                return db.forceOpenZoom
            end,
            setFunc = function(val)
                db.forceOpenZoom = (val == true)
            end,
            default = defaults.forceOpenZoom,
        },
        {
            type = "slider",
            name = "Initial Map Open Zoom (%)",
            tooltip = "Sets the fixed zoom level when opening the map with M (0% = Full view of zone, 100% = Maximum close-up).",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return db.initialOpenZoom or defaults.initialOpenZoom end,
            setFunc = function(val)
                db.initialOpenZoom = val
                ForceApplyOpenZoom()
            end,
            disabled = function() return not db.forceOpenZoom end,
            default = defaults.initialOpenZoom,
        },
        {
            type = "slider",
            name = "Maximum Zoom Limit",
            tooltip = "Controls how close you can zoom into any map using mouse scroll.",
            min = 1.50,
            max = 8.00,
            step = 0.50,
            decimals = 1,
            getFunc = function() return db.maxZoomLimit end,
            setFunc = function(val)
                db.maxZoomLimit = val
                ApplyZoom()
            end,
            default = defaults.maxZoomLimit,
        },
        {
            type = "header",
            name = "|cFFFFFFMap Navigation|r",
        },
        {
            type = "checkbox",
            name = "Ascend Map Level on Zoom Out",
            tooltip = "Automatically returns to parent map level when scrolling back.",
            getFunc = function() return db.enableZoomOutAscend end,
            setFunc = function(val)
                db.enableZoomOutAscend = (val == true)
            end,
            default = defaults.enableZoomOutAscend,
        },
        {
            type = "slider",
            name = "Zoom Out Trigger Percentage",
            tooltip = "Map will ascend when scrolling out while zoom is at or below this percentage (0% to 100%).",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return db.zoomOutThreshold end,
            setFunc = function(val)
                db.zoomOutThreshold = val
            end,
            disabled = function() return not db.enableZoomOutAscend end,
            default = defaults.zoomOutThreshold,
        },
        {
            type = "checkbox",
            name = "Descend Map Level on Zoom In",
            tooltip = "Automatically enters subzone/city under cursor when zooming in.",
            getFunc = function() return db.enableZoomInDescend end,
            setFunc = function(val)
                db.enableZoomInDescend = (val == true)
            end,
            default = defaults.enableZoomInDescend,
        },
        {
            type = "slider",
            name = "Zoom In Trigger Percentage",
            tooltip = "Map will enter the subzone/city when scrolling in while zoom is at or below this percentage (0% to 100%).",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return db.zoomInThreshold end,
            setFunc = function(val)
                db.zoomInThreshold = val
            end,
            disabled = function() return not db.enableZoomInDescend end,
            default = defaults.zoomInThreshold,
        },
        {
            type = "header",
            name = "|cFFFFFFPlayer Location Radar|r",
        },
        {
            type = "checkbox",
            name = "Enable Player Radar Highlight",
            tooltip = "Toggles the player highlight effect completely ON or OFF.",
            getFunc = function()
                if db.enableHighlight == nil then return defaults.enableHighlight end
                return db.enableHighlight
            end,
            setFunc = function(val)
                db.enableHighlight = (val == true)
                if val then
                    TriggerHighlight(true)
                else
                    StopHighlight()
                end
            end,
            default = defaults.enableHighlight,
        },
        {
            type = "checkbox",
            name = "Center Camera on Player",
            tooltip = "Smoothly pans the map camera to your current position when opening the map.",
            getFunc = function() return db.panToPlayer end,
            setFunc = function(val) db.panToPlayer = (val == true) end,
            disabled = function() return not db.enableHighlight end,
            default = defaults.panToPlayer,
        },
        {
            type = "checkbox",
            name = "Trigger Radar on Zoom",
            tooltip = "Re-triggers the highlight radar whenever you zoom in or zoom out with the mouse wheel.",
            getFunc = function()
                if db.triggerOnZoom == nil then return defaults.triggerOnZoom end
                return db.triggerOnZoom
            end,
            setFunc = function(val) db.triggerOnZoom = (val == true) end,
            disabled = function() return not db.enableHighlight end,
            default = defaults.triggerOnZoom,
        },
        {
            type = "slider",
            name = "Radar Pulse Speed (Seconds)",
            tooltip = "Controls the cycle duration for the radar breathing expansion.",
            min = 0.2,
            max = 3.0,
            step = 0.1,
            decimals = 1,
            getFunc = function() return db.pulseSpeed or defaults.pulseSpeed end,
            setFunc = function(val)
                db.pulseSpeed = val
                TriggerHighlight(true)
            end,
            disabled = function() return not db.enableHighlight end,
            default = defaults.pulseSpeed,
        },
        {
            type = "slider",
            name = "Radar Duration (Seconds)",
            tooltip = "How long the radar icon stays visible on screen.",
            min = 1.0,
            max = 10.0,
            step = 0.5,
            decimals = 1,
            getFunc = function() return db.displayDuration or defaults.displayDuration end,
            setFunc = function(val)
                db.displayDuration = val
                TriggerHighlight(true)
            end,
            disabled = function() return not db.enableHighlight end,
            default = defaults.displayDuration,
        },
        {
            type = "slider",
            name = "Radar Base Size",
            tooltip = "Base size of the radar texture in pixels.",
            min = 16,
            max = 256,
            step = 4,
            getFunc = function() return db.ringSize or defaults.ringSize end,
            setFunc = function(val)
                db.ringSize = val
                if ringControl then
                    ringControl:SetDimensions(val, val)
                end
                TriggerHighlight(true)
            end,
            disabled = function() return not db.enableHighlight end,
            default = defaults.ringSize,
        },
        {
            type = "slider",
            name = "Radar Opacity (%)",
            tooltip = "Overall visibility transparency of the radar icon.",
            min = 10,
            max = 100,
            step = 5,
            getFunc = function() return db.ringOpacity or defaults.ringOpacity end,
            setFunc = function(val)
                db.ringOpacity = val
                if ringControl then
                    ringControl:SetAlpha(val / 100)
                end
                TriggerHighlight(true)
            end,
            disabled = function() return not db.enableHighlight end,
            default = defaults.ringOpacity,
        },
        {
            type = "colorpicker",
            name = "Radar Color",
            tooltip = "Tint color applied to the custom radar texture.",
            getFunc = function()
                local c = db.ringColor or defaults.ringColor
                return c.r, c.g, c.b, c.a
            end,
            setFunc = function(r, g, b, a)
                db.ringColor = { r = r, g = g, b = b, a = a }
                if ringControl then
                    ringControl:SetColor(r, g, b, a)
                end
                TriggerHighlight(true)
            end,
            disabled = function() return not db.enableHighlight end,
            default = defaults.ringColor,
        },
    }

    LibAddonMenu2:RegisterAddonPanel("0nixWorldmapSettingsPanel", panelData)
    LibAddonMenu2:RegisterOptionControls("0nixWorldmapSettingsPanel", optionsData)
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    local worldName = GetWorldName()
    db = ZO_SavedVars:NewAccountWide("OnixWorldmapSavedVars", 1, worldName, defaults)

    SLASH_COMMANDS["/onix"] = function()
        TriggerHighlight()
    end

    SecurePostHook("ZO_WorldMap_UpdateMap", function()
        ApplyZoom()
        if isHighlightActive then
            RenderFrame()
        end
    end)

    WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWN then
            InstallZoomHooks()
            ApplyZoom()
            ForceApplyOpenZoom()
            TriggerHighlight()

            zo_callLater(function()
                ForceApplyOpenZoom()
            end, 25)
            zo_callLater(function()
                ForceApplyOpenZoom()
            end, 80)
        elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
            StopHighlight()
        end
    end)

    CreateSettingsMenu()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)