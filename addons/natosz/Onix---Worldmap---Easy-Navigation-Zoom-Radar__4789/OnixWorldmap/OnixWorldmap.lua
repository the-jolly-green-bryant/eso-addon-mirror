OnixWorldmap = OnixWorldmap or {}
local ADDON_NAME = "OnixWorldmap"
local ADDON_VERSION = "1.0.0"

local UPDATE_HANDLE = "OnixRealtimeFrameUpdater"
local ringControl = nil
local isHighlightActive = false
local startTime = 0
local lastNavTime = 0
local NAV_COOLDOWN = 0.40

local DELAY_STAGE1_MS = 0
local DELAY_STAGE2_MS = 15

local RING_TEXTURE = "OnixWorldmap/mapicons/player_ring3.dds"

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

local function GetPZ()
    return ZO_WorldMap_GetPanAndZoom and ZO_WorldMap_GetPanAndZoom()
end

local function GetUserMax()
    return (OnixWorldmap.db and OnixWorldmap.db.maxZoomLimit) or defaults.maxZoomLimit
end

function OnixWorldmap.ApplyZoom(pz)
    pz = pz or GetPZ()
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
    local db = OnixWorldmap.db or defaults
    if not db.forceOpenZoom then return end

    local pz = GetPZ()
    if not pz then return end

    OnixWorldmap.ApplyZoom(pz)

    local targetNorm = (db.initialOpenZoom or 0) / 100.0

    if pz.SetCurrentNormalizedZoom then
        pz:SetCurrentNormalizedZoom(targetNorm)
    end
    if pz.SetTargetNormalizedZoom then
        pz:SetTargetNormalizedZoom(targetNorm)
    end
    if pz.zoomSlider then
        pz.zoomSlider:SetValue(targetNorm)
    end
end

local function TriggerMapAscend()
    if not (OnixWorldmap.db and OnixWorldmap.db.enableZoomOutAscend) then return end

    local now = GetFrameTimeSeconds()
    if (now - lastNavTime) < NAV_COOLDOWN then return end
    lastNavTime = now

    local container = ZO_WorldMapContainer
    if container and container.GetHandler then
        local onMouseUp = container:GetHandler("OnMouseUp")
        if onMouseUp then
            onMouseUp(container, 2, true)
        end
    end
end

local function TriggerMapDescend()
    if not (OnixWorldmap.db and OnixWorldmap.db.enableZoomInDescend) then return end

    local now = GetFrameTimeSeconds()
    if (now - lastNavTime) < NAV_COOLDOWN then return end

    if ZO_WorldMapPins and ZO_WorldMapPins.GetMouseOverPin then
        local pin = ZO_WorldMapPins:GetMouseOverPin()
        if pin and pin.OnClicked then
            lastNavTime = now
            pin:OnClicked(1)
            return
        end
    end

    local container = ZO_WorldMapContainer
    if container and container.GetHandler then
        local onMouseUp = container:GetHandler("OnMouseUp")
        if onMouseUp then
            lastNavTime = now
            onMouseUp(container, 1, true)
        end
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

    local c = (OnixWorldmap.db and OnixWorldmap.db.ringColor) or defaults.ringColor
    ringControl:SetColor(c.r, c.g, c.b, c.a)

    local baseSize = (OnixWorldmap.db and OnixWorldmap.db.ringSize) or defaults.ringSize
    ringControl:SetDimensions(baseSize, baseSize)
    ringControl:SetDrawLayer(DL_OVERLAY)
    ringControl:SetDrawTier(DT_HIGH)
    ringControl:SetDrawLevel(30)

    ringControl:ClearAnchors()
    ringControl:SetAnchor(CENTER, container, TOPLEFT, 0, 0)
    ringControl:SetHidden(true)

    return ringControl
end

local function RenderFrame()
    local db = OnixWorldmap.db or defaults
    if not db.enableHighlight or not isHighlightActive or not ringControl then
        StopHighlight()
        return
    end

    if not ZO_WorldMap or ZO_WorldMap:IsHidden() then
        StopHighlight()
        return
    end

    local now = GetGameTimeMilliseconds()
    local elapsed = now - startTime
    local maxDurationMs = ((db.displayDuration) or defaults.displayDuration) * 1000

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
    if not container then return end

    local localX, localY = 0, 0
    if ZO_WorldMap_GetLocalCoordinatesFromNormalized then
        localX, localY = ZO_WorldMap_GetLocalCoordinatesFromNormalized(normX, normY)
    else
        local contW, contH = container:GetDimensions()
        localX = normX * contW
        localY = normY * contH
    end

    ringControl:SetAnchorOffsets(localX, localY)

    local pSpeedMs = math.max(100, ((db.pulseSpeed) or defaults.pulseSpeed) * 1000)
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
    local db = OnixWorldmap.db or defaults
    if not db.enableHighlight then
        StopHighlight()
        return
    end

    if not ZO_WorldMap or ZO_WorldMap:IsHidden() then return end

    local normX, normY = GetMapPlayerPosition("player")
    if not normX or not normY or normX <= 0 or normX >= 1 or normY <= 0 or normY >= 1 then
        return
    end

    if not forceNoPan and OnixWorldmap.db and OnixWorldmap.db.panToPlayer then
        local pz = GetPZ()
        if pz and pz.PanToNormalizedPosition then
            pz:PanToNormalizedPosition(normX, normY)
        elseif pz and pz.PanTo then
            pz:PanTo(normX, normY)
        end
    end

    local ring = CreateHighlightControl()
    if not ring then return end

    ring:SetTexture(RING_TEXTURE)
    startTime = GetGameTimeMilliseconds()
    isHighlightActive = true

    EVENT_MANAGER:UnregisterForUpdate(UPDATE_HANDLE)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_HANDLE, 0, RenderFrame)
    RenderFrame()
end

local function HandleMapScroll(delta)
    local pz = GetPZ()
    if not pz then return false end

    OnixWorldmap.ApplyZoom(pz)

    local triggerOnZoom = (OnixWorldmap.db and OnixWorldmap.db.triggerOnZoom ~= nil) and OnixWorldmap.db.triggerOnZoom or defaults.triggerOnZoom
    if triggerOnZoom then
        TriggerHighlight(true)
    end

    local currentNorm = pz:GetCurrentNormalizedZoom() or 0.0
    local currentPercent = currentNorm * 100

    local outThresh = (OnixWorldmap.db and OnixWorldmap.db.zoomOutThreshold) or defaults.zoomOutThreshold
    local inThresh = (OnixWorldmap.db and OnixWorldmap.db.zoomInThreshold) or defaults.zoomInThreshold

    if delta < 0 then
        if not (OnixWorldmap.db and OnixWorldmap.db.enableZoomOutAscend) then
            return false
        end

        if currentPercent <= outThresh then
            TriggerMapAscend()
            return true
        end

    elseif delta > 0 then
        if not (OnixWorldmap.db and OnixWorldmap.db.enableZoomInDescend) then
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
    if not ZO_WorldMapPanAndZoom then return end
    if ZO_WorldMapPanAndZoom.OnixZoomHooked then return end
    ZO_WorldMapPanAndZoom.OnixZoomHooked = true

    local origCompute = ZO_WorldMapPanAndZoom.ComputeZoomLimits
    if origCompute then
        ZO_WorldMapPanAndZoom.ComputeZoomLimits = function(self, ...)
            origCompute(self, ...)
            OnixWorldmap.ApplyZoom(self)
        end
    end

    local origSetMapCustom = ZO_WorldMapPanAndZoom.SetMapCustom
    if origSetMapCustom then
        ZO_WorldMapPanAndZoom.SetMapCustom = function(self, ...)
            origSetMapCustom(self, ...)
            OnixWorldmap.ApplyZoom(self)
        end
    end

    local origSetMap = ZO_WorldMapPanAndZoom.SetMap
    if origSetMap then
        ZO_WorldMapPanAndZoom.SetMap = function(self, ...)
            origSetMap(self, ...)
            OnixWorldmap.ApplyZoom(self)
        end
    end

    local origAddZoom = ZO_WorldMapPanAndZoom.AddZoom
    ZO_WorldMapPanAndZoom.AddZoom = function(self, delta, ...)
        OnixWorldmap.ApplyZoom(self)
        if origAddZoom then
            return origAddZoom(self, delta, ...)
        end
    end
end

local function ResetToDefaults()
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            OnixWorldmap.db[k] = ZO_DeepTableCopy(v)
        else
            OnixWorldmap.db[k] = v
        end
    end

    if ringControl then
        local c = OnixWorldmap.db.ringColor
        ringControl:SetColor(c.r, c.g, c.b, c.a)
        ringControl:SetDimensions(OnixWorldmap.db.ringSize, OnixWorldmap.db.ringSize)
        ringControl:SetAlpha(OnixWorldmap.db.ringOpacity / 100)
        ringControl:SetTexture(RING_TEXTURE)
    end

    OnixWorldmap.ApplyZoom()
    ForceApplyOpenZoom()
end

function OnixWorldmap.CreateSettingsMenu()
    local lam = LibAddonMenu2 or (LibStub and LibStub("LibAddonMenu-2.0", true))
    if not lam then return end

    local panelData = {
        type = "panel",
        name = "0nix Worldmap",
        displayName = "|cF8F8F80nix|r |cFFFABBWorldmap|r - |c55FF55Easy Navigation|r",
        author = "|c00E5FFNatosz|r",
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
                if OnixWorldmap.db.forceOpenZoom == nil then return defaults.forceOpenZoom end
                return OnixWorldmap.db.forceOpenZoom
            end,
            setFunc = function(val)
                OnixWorldmap.db.forceOpenZoom = (val == true)
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
            getFunc = function() return OnixWorldmap.db.initialOpenZoom or defaults.initialOpenZoom end,
            setFunc = function(val)
                OnixWorldmap.db.initialOpenZoom = val
                ForceApplyOpenZoom()
            end,
            disabled = function() return not (OnixWorldmap.db and OnixWorldmap.db.forceOpenZoom) end,
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
            getFunc = function() return OnixWorldmap.db.maxZoomLimit end,
            setFunc = function(val)
                OnixWorldmap.db.maxZoomLimit = val
                OnixWorldmap.ApplyZoom()
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
            getFunc = function() return OnixWorldmap.db.enableZoomOutAscend end,
            setFunc = function(val)
                OnixWorldmap.db.enableZoomOutAscend = (val == true)
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
            getFunc = function() return OnixWorldmap.db.zoomOutThreshold end,
            setFunc = function(val)
                OnixWorldmap.db.zoomOutThreshold = val
            end,
            disabled = function() return not OnixWorldmap.db.enableZoomOutAscend end,
            default = defaults.zoomOutThreshold,
        },
        {
            type = "checkbox",
            name = "Descend Map Level on Zoom In",
            tooltip = "Automatically enters subzone/city under cursor when zooming in.",
            getFunc = function() return OnixWorldmap.db.enableZoomInDescend end,
            setFunc = function(val)
                OnixWorldmap.db.enableZoomInDescend = (val == true)
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
            getFunc = function() return OnixWorldmap.db.zoomInThreshold end,
            setFunc = function(val)
                OnixWorldmap.db.zoomInThreshold = val
            end,
            disabled = function() return not OnixWorldmap.db.enableZoomInDescend end,
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
                if OnixWorldmap.db.enableHighlight == nil then return defaults.enableHighlight end
                return OnixWorldmap.db.enableHighlight
            end,
            setFunc = function(val)
                OnixWorldmap.db.enableHighlight = (val == true)
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
            getFunc = function() return OnixWorldmap.db.panToPlayer end,
            setFunc = function(val) OnixWorldmap.db.panToPlayer = (val == true) end,
            disabled = function() return not OnixWorldmap.db.enableHighlight end,
            default = defaults.panToPlayer,
        },
        {
            type = "checkbox",
            name = "Trigger Radar on Zoom",
            tooltip = "Re-triggers the highlight radar whenever you zoom in or zoom out with the mouse wheel.",
            getFunc = function()
                if OnixWorldmap.db.triggerOnZoom == nil then return defaults.triggerOnZoom end
                return OnixWorldmap.db.triggerOnZoom
            end,
            setFunc = function(val) OnixWorldmap.db.triggerOnZoom = (val == true) end,
            disabled = function() return not OnixWorldmap.db.enableHighlight end,
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
            getFunc = function() return OnixWorldmap.db.pulseSpeed or defaults.pulseSpeed end,
            setFunc = function(val)
                OnixWorldmap.db.pulseSpeed = val
                TriggerHighlight(true)
            end,
            disabled = function() return not OnixWorldmap.db.enableHighlight end,
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
            getFunc = function() return OnixWorldmap.db.displayDuration or defaults.displayDuration end,
            setFunc = function(val)
                OnixWorldmap.db.displayDuration = val
                TriggerHighlight(true)
            end,
            disabled = function() return not OnixWorldmap.db.enableHighlight end,
            default = defaults.displayDuration,
        },
        {
            type = "slider",
            name = "Radar Base Size",
            tooltip = "Base size of the radar texture in pixels.",
            min = 16,
            max = 256,
            step = 4,
            getFunc = function() return OnixWorldmap.db.ringSize or defaults.ringSize end,
            setFunc = function(val)
                OnixWorldmap.db.ringSize = val
                if ringControl then
                    ringControl:SetDimensions(val, val)
                end
                TriggerHighlight(true)
            end,
            disabled = function() return not OnixWorldmap.db.enableHighlight end,
            default = defaults.ringSize,
        },
        {
            type = "slider",
            name = "Radar Opacity (%)",
            tooltip = "Overall visibility transparency of the radar icon.",
            min = 10,
            max = 100,
            step = 5,
            getFunc = function() return OnixWorldmap.db.ringOpacity or defaults.ringOpacity end,
            setFunc = function(val)
                OnixWorldmap.db.ringOpacity = val
                if ringControl then
                    ringControl:SetAlpha(val / 100)
                end
                TriggerHighlight(true)
            end,
            disabled = function() return not OnixWorldmap.db.enableHighlight end,
            default = defaults.ringOpacity,
        },
        {
            type = "colorpicker",
            name = "Radar Color",
            tooltip = "Tint color applied to the custom radar texture.",
            getFunc = function()
                local c = OnixWorldmap.db.ringColor or defaults.ringColor
                return c.r, c.g, c.b, c.a
            end,
            setFunc = function(r, g, b, a)
                OnixWorldmap.db.ringColor = { r = r, g = g, b = b, a = a }
                if ringControl then
                    ringControl:SetColor(r, g, b, a)
                end
                TriggerHighlight(true)
            end,
            disabled = function() return not OnixWorldmap.db.enableHighlight end,
            default = defaults.ringColor,
        },
    }

    lam:RegisterAddonPanel("0nixWorldmapSettingsPanel", panelData)
    lam:RegisterOptionControls("0nixWorldmapSettingsPanel", optionsData)
end

SLASH_COMMANDS["/onix"] = function()
    TriggerHighlight()
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    OnixWorldmap.db = ZO_SavedVars:NewAccountWide("OnixWorldmapSavedVars", 1, nil, defaults)

    InstallZoomHooks()
    OnixWorldmap.ApplyZoom()

    if ZO_WorldMapContainer then
        ZO_PreHookHandler(ZO_WorldMapContainer, "OnMouseWheel", function(self, delta)
            if HandleMapScroll(delta) then
                return true
            end
            return false
        end)
    end

    if ZO_WorldMap then
        ZO_PreHookHandler(ZO_WorldMap, "OnMouseWheel", function(self, delta)
            if HandleMapScroll(delta) then
                return true
            end
            return false
        end)
    end

    SecurePostHook("ZO_WorldMap_UpdateMap", function()
        OnixWorldmap.ApplyZoom()
        if isHighlightActive then
            RenderFrame()
        end
    end)

    if WORLD_MAP_SCENE then
        WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWN then
                OnixWorldmap.ApplyZoom()
                zo_callLater(function()
                    ForceApplyOpenZoom()
                    TriggerHighlight()
                end, DELAY_STAGE1_MS)
                zo_callLater(function()
                    ForceApplyOpenZoom()
                end, DELAY_STAGE2_MS)
            elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                StopHighlight()
            end
        end)
    end

    OnixWorldmap.CreateSettingsMenu()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)