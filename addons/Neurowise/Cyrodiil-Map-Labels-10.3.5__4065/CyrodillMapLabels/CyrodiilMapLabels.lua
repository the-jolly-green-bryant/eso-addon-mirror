local ADDON_NAME = "CyrodiilMapLabels"
local wm = WINDOW_MANAGER
local labels = {}

-- Load data file
CyrodiilMapLabelsData = CyrodiilMapLabelsData or {}

-- Check if player is on the main Cyrodiil map (not sub-maps like gate maps)
local function IsPlayerInCyrodiilMainMap()
    local zoneId = GetZoneId(GetCurrentMapZoneIndex())
    local mapTexture = GetMapTileTexture()  -- Get the current map texture

    if not mapTexture then return false end  -- Ensure it’s valid

    -- Main Cyrodiil Map uses "ava_whole"
    local isMainMap = string.find(mapTexture:lower(), "ava_whole")

    return zoneId == 181 and isMainMap ~= nil
end

-- Create a label
local function CreateLabel(text, x, y)
    local label = wm:CreateControl(nil, ZO_WorldMapContainer, CT_LABEL)
    label:SetFont("ZoFontGameBold")
    label:SetText(text)
    label:SetColor(1, 1, 0.8, 1) -- Yellowish color
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetDimensions(150, 25)
    label:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, x, y)
    return label
end

-- Function to update and reposition labels correctly
local function UpdateLabels()
    -- Remove existing labels
    for _, labelPair in pairs(labels) do
        labelPair.shadow:SetHidden(true)
        labelPair.main:SetHidden(true)
    end

    -- Show labels only if the player is on the main Cyrodiil map
    if not IsPlayerInCyrodiilMainMap() then return end

    -- Ensure the map container exists before getting its dimensions
    if not ZO_WorldMapContainer or not ZO_WorldMapContainer.GetDimensions then
        d("❌ ERROR: ZO_WorldMapContainer is not ready!")
        return
    end

    -- Get current map dimensions
    local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()

    -- Ensure map dimensions are valid
    if not mapWidth or not mapHeight or mapWidth == 0 or mapHeight == 0 then
        d("❌ ERROR: Map dimensions are invalid!")
        return
    end

    for _, keep in ipairs(CyrodiilMapLabelsData) do
        local xPos = keep.x * mapWidth
        local yPos = keep.y * mapHeight

        -- Create labels if they don’t already exist
        if not labels[keep.name] then
            labels[keep.name] = {
                shadow = wm:CreateControl(nil, ZO_WorldMapContainer, CT_LABEL),
                main = wm:CreateControl(nil, ZO_WorldMapContainer, CT_LABEL)
            }

            -- Set up shadow label (darker, slightly offset)
            labels[keep.name].shadow:SetFont("ZoFontGameBold")
            labels[keep.name].shadow:SetText(keep.name)
            labels[keep.name].shadow:SetColor(0, 0, 0, 1) -- Black shadow
            labels[keep.name].shadow:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            labels[keep.name].shadow:SetDimensions(150, 25)

            -- Set up main label (normal color)
            labels[keep.name].main:SetFont("ZoFontGameBold")
            labels[keep.name].main:SetText(keep.name)
            labels[keep.name].main:SetColor(1, 1, 0.8, 1) -- Yellowish color
            labels[keep.name].main:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            labels[keep.name].main:SetDimensions(150, 25)
        end

        -- Properly anchor labels to the map
        labels[keep.name].shadow:ClearAnchors()
        labels[keep.name].shadow:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, xPos + 2, yPos + 2) -- Offset for shadow

        labels[keep.name].main:ClearAnchors()
        labels[keep.name].main:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, xPos, yPos)

        -- Show the labels
        labels[keep.name].shadow:SetHidden(false)
        labels[keep.name].main:SetHidden(false)
    end
end

ZO_WorldMapContainer:SetHandler("OnRectChanged", UpdateLabels)

-- Refresh labels when the player moves to a new zone
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, UpdateLabels)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ZONE_CHANGED, UpdateLabels)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_SCREEN_RESIZED, UpdateLabels)

-- Initialize the add-on
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == ADDON_NAME then
        zo_callLater(function()
            UpdateLabels()
        end, 500) -- Wait 0.5 seconds to ensure the map is ready
    end
end)