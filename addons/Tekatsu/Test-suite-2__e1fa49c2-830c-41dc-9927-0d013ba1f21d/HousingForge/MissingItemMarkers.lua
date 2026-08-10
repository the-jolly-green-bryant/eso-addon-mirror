HF.MissingItemMarkers = {
    pins = {},
    initialized = false,
    enabled = false,
    items = {},
    nearby = {},
}

local MARKER_PIN_SIZE = 60
local MIN_MARKER_PIN_SIZE = 28
local MARKER_FADE_START_DISTANCE = 2000
local MARKER_MAX_DISTANCE = 12000
local MIN_MARKER_OPACITY_FACTOR = 0.25
local UPDATE_NAME = "HousingForge_MissingMarkerUpdate"

local function InitMarkers()
    if HF.MissingItemMarkers.initialized then return true end
    if not HF_WorldPins then return false end

    HF_WorldPins:Create3DRenderSpace()
    Set3DRenderSpaceToCurrentCamera("HF_WorldPins")
    HF_WorldPins:SetHidden(false)

    local maxMarkers = HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.maxMarkers or 30
    for i = 1, maxMarkers do
        local pin = CreateControlFromVirtual("HF_MissingMarker", HF_WorldPins, "HF_MissingMarkerPin", i)
        pin:Create3DRenderSpace()
        pin:Set3DRenderSpaceSystem(GUI_RENDER_3D_SPACE_SYSTEM_CONTROL)
        pin:Set3DRenderSpaceUsesDepthBuffer(false)

        local icon = pin:GetNamedChild("Icon")
        if icon then
            icon:Create3DRenderSpace()
            icon:Set3DRenderSpaceSystem(GUI_RENDER_3D_SPACE_SYSTEM_CONTROL)
            icon:Set3DRenderSpaceUsesDepthBuffer(false)
            icon:Set3DLocalDimensions(MARKER_PIN_SIZE, MARKER_PIN_SIZE)
            icon:SetColor(1, 0.25, 0.05, HF.savedVars.settings.markerOpacity or 0.9)
        end
        pin.hfIcon = icon

        pin:SetHidden(true)
        table.insert(HF.MissingItemMarkers.pins, pin)
    end

    HF.MissingItemMarkers.initialized = true
    return true
end

function HF.MissingItemMarkers.SetItems(items)
    HF.MissingItemMarkers.items = items or {}
    if HF.savedVars and HF.savedVars.settings and HF.savedVars.settings.showMissingMarkers then
        HF.MissingItemMarkers.Enable()
    end
end

function HF.MissingItemMarkers.Clear()
    HF.MissingItemMarkers.items = {}
    HF.MissingItemMarkers.Disable()
end

function HF.MissingItemMarkers.Update()
    if not HF.MissingItemMarkers.enabled then return end
    if not InitMarkers() then return end

    local _, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")
    local nearby = HF.MissingItemMarkers.nearby
    for i = #nearby, 1, -1 do
        nearby[i] = nil
    end

    local maxPins = #HF.MissingItemMarkers.pins
    local maxDistSq = MARKER_MAX_DISTANCE * MARKER_MAX_DISTANCE

    for _, item in ipairs(HF.MissingItemMarkers.items or {}) do
        local dx = (item.worldX or 0) - playerX
        local dy = (item.worldY or 0) - playerY
        local dz = (item.worldZ or 0) - playerZ
        local distSq = dx * dx + dy * dy + dz * dz
        if distSq < maxDistSq then
            item.distSq = distSq
            local insertAt = #nearby + 1
            for i = 1, #nearby do
                if distSq < (nearby[i].distSq or 0) then
                    insertAt = i
                    break
                end
            end

            if insertAt <= maxPins then
                local newCount = math.min(#nearby + 1, maxPins)
                for i = newCount, insertAt + 1, -1 do
                    nearby[i] = nearby[i - 1]
                end
                nearby[insertAt] = item
            end
        end
    end

    local heading = GetPlayerCameraHeading and GetPlayerCameraHeading() or 0
    local settings = HF.savedVars and HF.savedVars.settings or {}
    local markerOpacity = tonumber(settings.markerOpacity) or 0.9
    markerOpacity = math.max(0, math.min(1, markerOpacity))
    for i, pin in ipairs(HF.MissingItemMarkers.pins) do
        local item = nearby[i]
        if item then
            local rx, ry, rz = WorldPositionToGuiRender3DPosition(item.worldX, item.worldY, item.worldZ)
            pin:Set3DRenderSpaceOrigin(rx, ry, rz)
            pin:Set3DRenderSpaceOrientation(0, heading, 0)
            local distance = math.sqrt(item.distSq or 0)
            local fade = 1
            if distance > MARKER_FADE_START_DISTANCE then
                fade = 1 - ((distance - MARKER_FADE_START_DISTANCE) / (MARKER_MAX_DISTANCE - MARKER_FADE_START_DISTANCE))
                fade = math.max(0, math.min(1, fade))
            end
            local size = MIN_MARKER_PIN_SIZE + ((MARKER_PIN_SIZE - MIN_MARKER_PIN_SIZE) * fade)
            local alphaFactor = MIN_MARKER_OPACITY_FACTOR + ((1 - MIN_MARKER_OPACITY_FACTOR) * fade)
            local icon = pin.hfIcon or pin:GetNamedChild("Icon")
            if icon then
                icon:Set3DLocalDimensions(size, size)
                icon:SetColor(1, 0.25, 0.05, markerOpacity * alphaFactor)
            end
            pin:SetHidden(false)
        else
            pin:SetHidden(true)
        end
    end
end

function HF.MissingItemMarkers.Enable()
    if not InitMarkers() then return end
    if HF_WorldPins then
        HF_WorldPins:SetHidden(false)
        Set3DRenderSpaceToCurrentCamera("HF_WorldPins")
    end
    HF.MissingItemMarkers.enabled = true
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 100, HF.MissingItemMarkers.Update)
    HF.MissingItemMarkers.Update()
    HF.Chat("Missing item markers enabled.")
end

function HF.MissingItemMarkers.Disable()
    HF.MissingItemMarkers.enabled = false
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    for _, pin in ipairs(HF.MissingItemMarkers.pins or {}) do
        pin:SetHidden(true)
    end
    if HF_WorldPins then HF_WorldPins:SetHidden(true) end
end

function HF.MissingItemMarkers.Toggle()
    if HF.MissingItemMarkers.enabled then
        HF.MissingItemMarkers.Disable()
        HF.Chat("Missing item markers hidden.")
    else
        if not HF.MissingItemMarkers.items or #HF.MissingItemMarkers.items == 0 then
            HF.Chat("No missing items to mark.")
            return
        end
        HF.MissingItemMarkers.Enable()
    end
    if HF.RefreshUI then HF.RefreshUI() end
end
