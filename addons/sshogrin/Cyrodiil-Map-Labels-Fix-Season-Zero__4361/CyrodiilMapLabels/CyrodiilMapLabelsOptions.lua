local ADDON_NAME = "CyrodiilMapLabels"
local wm = WINDOW_MANAGER
local labels = {}
CyrodiilMapLabelsAddon = { name = ADDON_NAME, wm = wm, labels = labels }

CyrodiilMapLabelsDefaults = {
    version = "1.7.0",
    variableVersion = 1,
    datasetChoice = "Long Names",
    useAllianceColors = true,
    fontScale = 1.0,
    fallbackR = 0.2,
    fallbackG = 1.0,
    fallbackB = 0.0,
}

CyrodiilMapLabelsData = CyrodiilMapLabelsData or {}
CyrodiilMapLabelsDataShort = CyrodiilMapLabelsDataShort or {}

local function IsPlayerInCyrodiilMainMap()
    local zoneId = GetZoneId(GetCurrentMapZoneIndex())
    local mapTexture = GetMapTileTexture()
    if not mapTexture then return false end
    return zoneId == 181 and string.find(mapTexture:lower(), "ava_whole") ~= nil
end

function CyrodiilMapLabelsAddon.UpdateLabels()
    local db = CyrodiilMapLabelsAddon.db
    for _, labelPair in pairs(labels) do
        if labelPair.shadow then labelPair.shadow:SetHidden(true) end
        if labelPair.main then labelPair.main:SetHidden(true) end
    end

    if not IsPlayerInCyrodiilMainMap() then return end
    if not ZO_WorldMapContainer or not ZO_WorldMapContainer.GetDimensions then return end

    local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()
    if not mapWidth or not mapHeight or mapWidth == 0 or mapHeight == 0 then return end

    local activeData = CyrodiilMapLabelsData
    if not activeData or type(activeData) ~= "table" or #activeData == 0 then return end

    -- FIX: Declared table values using explicit dot notations to prevent markdown filters from dropping your keys!
    local ALLIANCE_COLORS = {}
    ALLIANCE_COLORS[1] = { r = 0.9, g = 0.8, b = 0.2 } -- AD (Yellow)
    ALLIANCE_COLORS[2] = { r = 0.9, g = 0.2, b = 0.2 } -- EP (Red)
    ALLIANCE_COLORS[3] = { r = 0.2, g = 0.5, b = 0.9 } -- DC (Blue)

    local currentScale = db and db.fontScale or CyrodiilMapLabelsDefaults.fontScale
    local prefix = "SI_CYRODIILMAPLABELS_"

    for index, keep in ipairs(activeData) do
        local xPos = keep.x * mapWidth
        local yPos = keep.y * mapHeight

        if not labels[index] then
            local sName = "CyrodiilMapLabel_Shadow_" .. index
            local mName = "CyrodiilMapLabel_Main_" .. index
            labels[index] = {
                shadow = wm:CreateControl(sName, ZO_WorldMapContainer, CT_LABEL),
                main = wm:CreateControl(mName, ZO_WorldMapContainer, CT_LABEL)
            }
            labels[index].shadow:SetFont("ZoFontGameBold")
            labels[index].shadow:SetColor(0, 0, 0, 1)
            labels[index].shadow:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            labels[index].shadow:SetDimensions(150, 25)
            labels[index].shadow:SetDrawLayer(DL_OVERLAY)
            labels[index].shadow:SetDrawTier(DT_HIGH)

            labels[index].main:SetFont("ZoFontGameBold")
            labels[index].main:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            labels[index].main:SetDimensions(150, 25)
            labels[index].main:SetDrawLayer(DL_OVERLAY)
            labels[index].main:SetDrawTier(DT_HIGH)
        end

        labels[index].shadow:SetScale(currentScale)
        labels[index].main:SetScale(currentScale)

        local r = db and db.fallbackR or CyrodiilMapLabelsDefaults.fallbackR
        local g = db and db.fallbackG or CyrodiilMapLabelsDefaults.fallbackG
        local b = db and db.fallbackB or CyrodiilMapLabelsDefaults.fallbackB
        
        local stringType = (db and db.datasetChoice == "Short Names") and "SHORT_" or "KEEP_"
        local targetGlobalKey = prefix .. stringType .. keep.keepId
        local displayName = GetString(_G[targetGlobalKey])

        if displayName == "" or displayName == nil then
            displayName = (db and db.datasetChoice == "Short Names") and CyrodiilMapLabelsDataShort[index].name or keep.name
        end

        local shouldShowFactionColor = true

        if keep.keepId and keep.keepId >= 124 and keep.keepId <= 129 then
            if keep.keepId == 127 and GetKeepAlliance(11, 1) ~= 2 and GetKeepAlliance(10, 1) ~= 2 then shouldShowFactionColor = false
            elseif keep.keepId == 126 and GetKeepAlliance(12, 1) ~= 2 and GetKeepAlliance(10, 1) ~= 2 then shouldShowFactionColor = false
            elseif keep.keepId == 128 and GetKeepAlliance(3, 1) ~= 3 and GetKeepAlliance(5, 1) ~= 3 then shouldShowFactionColor = false
            elseif keep.keepId == 129 and GetKeepAlliance(4, 1) ~= 3 and GetKeepAlliance(5, 1) ~= 3 then shouldShowFactionColor = false
            elseif keep.keepId == 124 and GetKeepAlliance(19, 1) ~= 1 and GetKeepAlliance(16, 1) ~= 1 then shouldShowFactionColor = false
            elseif keep.keepId == 125 and GetKeepAlliance(20, 1) ~= 1 and GetKeepAlliance(16, 1) ~= 1 then shouldShowFactionColor = false end
        end

        if db and db.useAllianceColors and keep.keepId and shouldShowFactionColor then
            local allianceId = GetKeepAlliance(keep.keepId, 1)
            if allianceId and ALLIANCE_COLORS[allianceId] then
                local colorProfile = ALLIANCE_COLORS[allianceId]
                r, g, b = colorProfile.r, colorProfile.g, colorProfile.b
            end
        end

        labels[index].shadow:SetText(displayName)
        labels[index].main:SetText(displayName)
        labels[index].main:SetColor(r, g, b, 1)

        labels[index].shadow:ClearAnchors()
        labels[index].shadow:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, xPos + 2, yPos + 2)
        labels[index].main:ClearAnchors()
        labels[index].main:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, xPos, yPos)
        labels[index].shadow:SetHidden(false)
        labels[index].main:SetHidden(false)
    end
end

ZO_WorldMapContainer:SetHandler("OnRectChanged", CyrodiilMapLabelsAddon.UpdateLabels)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, CyrodiilMapLabelsAddon.UpdateLabels)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ZONE_CHANGED, CyrodiilMapLabelsAddon.UpdateLabels)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_SCREEN_RESIZED, CyrodiilMapLabelsAddon.UpdateLabels)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_KEEP_ALLIANCE_CHANGED, function() CyrodiilMapLabelsAddon.UpdateLabels() end)

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == ADDON_NAME then
        CyrodiilMapLabelsAddon.db = ZO_SavedVars:NewAccountWide("CyrodiilMapLabelsSavedVars", CyrodiilMapLabelsDefaults.variableVersion, nil, CyrodiilMapLabelsDefaults)
        if CyrodiilMapLabelsAddon.CreateSettingsMenu then CyrodiilMapLabelsAddon.CreateSettingsMenu() end
        zo_callLater(function() CyrodiilMapLabelsAddon.UpdateLabels() end, 500)
    end
end)
