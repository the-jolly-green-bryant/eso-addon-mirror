local hrwm_name = "HighResWorldMap"
local hrwm_version = "1.9"

local tiles = {
    "Art/maps/tamriel/Tamriel_0.dds",
    "Art/maps/tamriel/Tamriel_1.dds",
    "Art/maps/tamriel/Tamriel_2.dds",
    "Art/maps/tamriel/Tamriel_3.dds",
    "Art/maps/tamriel/Tamriel_4.dds",
    "Art/maps/tamriel/Tamriel_5.dds",
    "Art/maps/tamriel/Tamriel_6.dds",
    "Art/maps/tamriel/Tamriel_7.dds",
    "Art/maps/tamriel/Tamriel_8.dds",
    "Art/maps/tamriel/Tamriel_9.dds",
    "Art/maps/tamriel/Tamriel_10.dds",
    "Art/maps/tamriel/Tamriel_11.dds",
    "Art/maps/tamriel/Tamriel_12.dds",
    "Art/maps/tamriel/Tamriel_13.dds",
    "Art/maps/tamriel/Tamriel_14.dds",
    "Art/maps/tamriel/Tamriel_15.dds",
}

local enabled = true
local _GetMapTileTexture = GetMapTileTexture
local function hrwm_GetMapTileTexture(index)
    local tex = _GetMapTileTexture(index)
    if not enabled then return tex end
    for i = 1, 16 do
        if tiles[i] == tex then
            return "HighResWorldMap/tiles/tamriel_" .. i .. ".dds"
        end
    end
    return tex
end

local _GetMapCustomMaxZoom = GetMapCustomMaxZoom
local function hrwm_GetMapCustomMaxZoom()
    if not enabled then return _GetMapCustomMaxZoom() end
    if GetMapName() == "Tamriel" then
        return 12
    else
        return _GetMapCustomMaxZoom()
    end
end

local _UpdateBlobs = WORLD_MAP_MANAGER.UpdateBlobs
local function IsMouseOverMap() -- local function from esoui source
	-- WORLD_MAP_AUTO_NAVIGATION_OVERLAY_FRAGMENT will eat all the mouse input, so the mouse can't be over the map
	if not WORLD_MAP_AUTO_NAVIGATION_OVERLAY_FRAGMENT:IsShowing() then
		if IsInGamepadPreferredMode() then
			return SCENE_MANAGER:IsShowing("gamepad_worldMap")
		else
			return not ZO_WorldMapScroll:IsHidden() and MouseIsOver(ZO_WorldMapScroll) and SCENE_MANAGER:IsShowing("worldMap")
		end
	end

	return false
end
local function NormalizePreferredMousePositionToMap() -- local function from esoui source
	if IsInGamepadPreferredMode() then
		local x, y = ZO_WorldMapScroll:GetCenter()
		return NormalizePointToControl(x, y, ZO_WorldMapContainer)
	else
		return NormalizeMousePositionToControl(ZO_WorldMapContainer)
	end
end
local function hrwm_UpdateBlobs(self, currentFrameTimeS)
	if not enabled then return _UpdateBlobs(self, currentFrameTimeS) end
	
	-- Setup "locals"
	local g_mapPanAndZoom = ZO_WorldMap_GetPanAndZoom()
	
    local zoomChanged = false
    if self.lastBlobZoom ~= g_mapPanAndZoom:GetCurrentCurvedZoom() then
        self.lastBlobZoom = g_mapPanAndZoom:GetCurrentCurvedZoom()
        zoomChanged = true
    end

    -- Mouseover
    local normalizedMouseX, normalizedMouseY = nil, nil
    local forceShowMouseoverBlob = false
    if self:IsAutoNavigating() then
        if self:ShouldShowAutoNavigateHighlightBlob() then
            forceShowMouseoverBlob = true
            normalizedMouseX, normalizedMouseY = GetAutoMapNavigationNormalizedPositionForCurrentMap()
        end
    elseif IsMouseOverMap() then
        normalizedMouseX, normalizedMouseY = NormalizePreferredMousePositionToMap()
    end

    local mouseoverLocationName = ""
    local mouseoverTextureFile = ""
    local mouseoverTextureUIWidth, mouseoverTextureUIHeight, mouseoverTextureXOffset, mouseoverTextureYOffset

    if normalizedMouseX and normalizedMouseY then
        local normalizedLocX, normalizedLocY, normalizedWidth, normalizedHeight
        mouseoverLocationName, mouseoverTextureFile, normalizedWidth, normalizedHeight, normalizedLocX, normalizedLocY = GetMapMouseoverInfo(normalizedMouseX, normalizedMouseY)
        mouseoverTextureUIWidth = normalizedWidth * ZO_MAP_CONSTANTS.MAP_WIDTH
        mouseoverTextureUIHeight = normalizedHeight * ZO_MAP_CONSTANTS.MAP_HEIGHT
        mouseoverTextureXOffset = normalizedLocX * ZO_MAP_CONSTANTS.MAP_WIDTH
        mouseoverTextureYOffset = normalizedLocY * ZO_MAP_CONSTANTS.MAP_HEIGHT
    end

    if mouseoverLocationName ~= self.mouseoverCurrentLocation and ZO_WorldMapMouseoverName.owner ~= "poi" then
        if mouseoverLocationName ~= ZO_WorldMap.zoneName then
            ZO_WorldMapMouseoverName:SetText(zo_strformat(SI_WORLD_MAP_LOCATION_NAME, mouseoverLocationName))
        else
            ZO_WorldMapMouseoverName:SetText("")
        end
        self.mouseoverCurrentLocation = mouseoverLocationName
    end

    local textureChanged = false
    if mouseoverTextureFile ~= self.mouseoverBlobCurrentTexture then
        self:HideCurrentMouseoverBlob()
        self.mouseoverBlobCurrentTexture = mouseoverTextureFile
        textureChanged = true
    end

    if zoomChanged then
        textureChanged = true
        self.blobNamesDirty = true
    end

    if textureChanged then
        if mouseoverTextureFile ~= "" then
            local mouseoverBlobTexture = self.mouseoverBlobTexture
            mouseoverBlobTexture:SetTexture(mouseoverTextureFile)
            mouseoverBlobTexture:SetDimensions(mouseoverTextureUIWidth, mouseoverTextureUIHeight)
            mouseoverBlobTexture:SetSimpleAnchorParent(mouseoverTextureXOffset, mouseoverTextureYOffset)
            mouseoverBlobTexture:SetHidden(false)
        end
    end

    -- Blob Names
    if self.blobNamesDirty then
        self.blobNamesDirty = false
        local VISIBILITY_THRESHOLD = 0.15
        local MAX_ALPHA_THRESHOLD = 0.50
        local MIN_ALPHA = 0.2
        local zoomMin, zoomMax = g_mapPanAndZoom:GetZoomMinMax()
		local origMaxZoom = 3.2869135802469 -- Original value from unpatched world map
        local scale = self.lastBlobZoom / origMaxZoom
        local zoomLerp = zo_percentBetween(zoomMin, origMaxZoom, self.lastBlobZoom)
        if zoomLerp > VISIBILITY_THRESHOLD then
            if not self.blobNamesVisible then
                self.blobNamesVisible = true
                if self.blobNamesReset then
                    -- Don't fade in if we zoomed out from another map straight into visibility
                    self.blobNameLabelFadeProgress = 1
                else
                    self.blobNameLabelFadeProgress = 0
                    self.blobNameLabelFadeTimeline:PlayFromStart()
                end
            end
        else
            if self.blobNamesVisible then
                self.blobNameLabelFadeTimeline:PlayBackward()
            end
        end

        self.blobNamesReset = false
        if self.blobNamesVisible then
            local alpha
			-- If zoomed in far enough, start fading out the labels again to view map detail close up
			if zoomLerp < 2 then
				alpha = zo_percentBetween(VISIBILITY_THRESHOLD, MAX_ALPHA_THRESHOLD, zoomLerp) + MIN_ALPHA
			else
				alpha = zo_lerp(1, 0, zoomLerp - 2) + MIN_ALPHA
			end
            alpha = alpha * self.blobNameLabelFadeProgress
            for blobIndex = 1, GetNumMapBlobs() do
                local locationName, normalizedLocX, normalizedLocY, normalizedWidth, nameScale = GetMapBlobNameInfo(blobIndex)
                if locationName ~= "" then
                    local finalScale = zo_min(1, scale) * nameScale
                    locationName = zo_strformat(SI_ZONE_NAME, locationName)
                    local nameUIWidth = (normalizedWidth * ZO_MAP_CONSTANTS.MAP_WIDTH) / finalScale
                    local nameOffsetX = normalizedLocX * ZO_MAP_CONSTANTS.MAP_WIDTH
                    local nameOffsetY = normalizedLocY * ZO_MAP_CONSTANTS.MAP_HEIGHT
                    local label = self.blobNameLabelControlPool:AcquireObject(blobIndex)
                    label:SetText(locationName)
                    label:SetAnchor(CENTER, nil, TOPLEFT, nameOffsetX, nameOffsetY)
                    label:SetScale(finalScale)
                    label:SetAlpha(alpha)
                    label.shadowLabel:SetText(locationName)
                end
            end
        end
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= hrwm_name then return end
    EVENT_MANAGER:UnregisterForEvent(hrwm_name, EVENT_ADD_ON_LOADED)

    GetMapTileTexture = hrwm_GetMapTileTexture
    GetMapCustomMaxZoom = hrwm_GetMapCustomMaxZoom
    
	WORLD_MAP_MANAGER.blobNameLabelControlPool.templateName = "HRWM_MapBlobName"
	WORLD_MAP_MANAGER.UpdateBlobs = hrwm_UpdateBlobs
	
    SLASH_COMMANDS["/highresworldmap"] = function(option)
			enabled = not enabled
	end
end
EVENT_MANAGER:RegisterForEvent(hrwm_name, EVENT_ADD_ON_LOADED, OnAddonLoaded)