local WR = Wegesruhe

WR.mapHooked = false
WR.mapRefreshSerial = 0
WR.mapRefreshDelayMs = 100

function WR:InitializeMap()
    if self.mapHooked or type(ZO_WorldMap_IsPinGroupShown) ~= "function" then
        return
    end
    self.mapHooked = true
    self.originalWorldMapIsPinGroupShown = ZO_WorldMap_IsPinGroupShown
    local original = self.originalWorldMapIsPinGroupShown

    function ZO_WorldMap_IsPinGroupShown(pinTag)
        if pinTag == MAP_FILTER_QUESTS then
            local profile = WR:GetActiveProfile()
            if profile.mapQuestPins == false then
                return false
            end
        end
        return original(pinTag)
    end
end

local function IsWorldMapShowing()
    return type(ZO_WorldMap_IsWorldMapShowing) == "function" and ZO_WorldMap_IsWorldMapShowing()
end

function WR:RefreshMapNow(serial, force)
    -- A newer request supersedes this one. This coalesces rapid help-key presses
    -- into a single expensive world-map rebuild and prevents visible hitching.
    if serial ~= self.mapRefreshSerial then
        return
    end

    -- Normal/profile/help refreshes only rebuild pins while the map is open. A
    -- master enable/disable transition passes force=true and deliberately runs
    -- one complete callback even with the map closed so no stale quest-pin state
    -- survives until the next /reloadui or another map event.
    if not force and not IsWorldMapShowing() then
        return
    end

    if CALLBACK_MANAGER then
        -- OnWorldMapChanged reinitializes ZO_MapPanAndZoom and resets the
        -- normalized zoom/offset. Wegesruhe only needs the pins rebuilt, so
        -- preserve the user's current map view around that callback.
        local panAndZoom
        local savedZoom
        local savedOffsetX
        local savedOffsetY

        if IsWorldMapShowing() and type(ZO_WorldMap_GetPanAndZoom) == "function" then
            panAndZoom = ZO_WorldMap_GetPanAndZoom()
            if panAndZoom and panAndZoom.GetCurrentNormalizedZoom and ZO_WorldMapContainer then
                savedZoom = panAndZoom:GetCurrentNormalizedZoom()

                -- ZO_MapPanAndZoom represents panning as the offset between the
                -- map container's center and the scroll control's center. Save
                -- exactly that value so a pin refresh cannot recenter the map.
                if ZO_WorldMapScroll and ZO_WorldMapContainer.GetCenter and ZO_WorldMapScroll.GetCenter then
                    local containerCenterX, containerCenterY = ZO_WorldMapContainer:GetCenter()
                    local scrollCenterX, scrollCenterY = ZO_WorldMapScroll:GetCenter()
                    if containerCenterX and containerCenterY and scrollCenterX and scrollCenterY then
                        savedOffsetX = containerCenterX - scrollCenterX
                        savedOffsetY = containerCenterY - scrollCenterY
                    end
                end

                -- Defensive fallback for unusual UI layouts: GetAnchor returns
                -- six values; the X/Y offsets are values five and six.
                if savedOffsetX == nil or savedOffsetY == nil then
                    local _, _, _, _, offsetX, offsetY = ZO_WorldMapContainer:GetAnchor(0)
                    savedOffsetX = offsetX or 0
                    savedOffsetY = offsetY or 0
                end
            end
        end

        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")

        if savedZoom ~= nil and panAndZoom and panAndZoom.SetCurrentNormalizedZoom and panAndZoom.SetCurrentOffset then
            panAndZoom:SetCurrentNormalizedZoom(savedZoom)
            panAndZoom:SetCurrentOffset(savedOffsetX, savedOffsetY)
        end
        return
    end

    -- Fallback for an unexpectedly unavailable callback manager.
    if ZO_WorldMap_UpdateMap then
        ZO_WorldMap_UpdateMap()
    end
end

function WR:RefreshMap(force)
    self.mapRefreshSerial = self.mapRefreshSerial + 1
    local serial = self.mapRefreshSerial
    force = force == true

    -- Master on/off is infrequent. Do its full rebuild immediately so the state
    -- transition is deterministic. The hold-to-help key still uses the delayed,
    -- map-open-only path below.
    if force then
        self:RefreshMapNow(serial, true)
        return
    end

    if not IsWorldMapShowing() then
        return
    end

    if type(zo_callLater) == "function" then
        zo_callLater(function()
            WR:RefreshMapNow(serial, false)
        end, self.mapRefreshDelayMs)
    else
        self:RefreshMapNow(serial, false)
    end
end
