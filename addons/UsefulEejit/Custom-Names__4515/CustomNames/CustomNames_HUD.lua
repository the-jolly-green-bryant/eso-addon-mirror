-- CustomNames_HUD.lua
-- Overrides zone/location/condition name API functions so renamed strings
-- propagate to all HUD surfaces automatically.
--
-- NOTE: Loading screen zone name is NOT patchable from addon code.
--   It runs in the "app" Lua layer - a separate environment from ingame addons.

local CN = CustomNames

------------------------------------------------------------------------
-- LookupZone with <br> stripping
-- The blob override applies its own \n substitution after calling LookupZone,
-- so LookupZone itself must return the name without <br> for all other surfaces
-- (title bar, Locations tab, compass, etc.) where <br> would appear literally.
------------------------------------------------------------------------

local _baseLookupZone
local function InitLookupZoneWrapper()
    _baseLookupZone = CN.LookupZone
    CN.LookupZone = function(name)
        local result = _baseLookupZone(name)
        if result and result:find("<br>", 1, true) then
            result = result:gsub("<br>", " ")
        end
        return result
    end
end

------------------------------------------------------------------------
-- API overrides
------------------------------------------------------------------------

-- ZO_WorldMap_GetMapTitle calls GetMapName() internally and passes the result
-- through zo_strformat. String substitution after the fact can fail if
-- zo_strformat applies any character transformation to the name.
-- Fix: temporarily swap GetMapName to return the renamed string for the
-- duration of orig_GetMapTitle(), so the format receives it directly.
-- ZO_WorldMap.zoneName is set by ZO_WorldMap_UpdateMap calling GetMapName()
-- outside of GetMapTitle, so it stays raw and the mouseover suppression
-- comparison in UpdateBlobs continues to work correctly.
local orig_GetMapName  = GetMapName
local orig_GetMapTitle = ZO_WorldMap_GetMapTitle
ZO_WorldMap_GetMapTitle = function()
    local raw     = orig_GetMapName()
    local renamed = CN.LookupAny(raw)
    if renamed == raw then
        return orig_GetMapTitle()
    end
    GetMapName = function() return renamed end
    local result = orig_GetMapTitle()
    GetMapName = orig_GetMapName
    return result
end

local orig_GetZoneNameByIndex = GetZoneNameByIndex
GetZoneNameByIndex = function(zoneIndex)
    return CN.LookupZone(orig_GetZoneNameByIndex(zoneIndex))
end

local orig_GetMapInfoByIndex = GetMapInfoByIndex
GetMapInfoByIndex = function(zoneIndex)
    local mapName, mapType, mapContentType, zIdx, description = orig_GetMapInfoByIndex(zoneIndex)
    return CN.LookupZone(mapName), mapType, mapContentType, zIdx, description
end

local orig_GetJournalQuestLocationInfo = GetJournalQuestLocationInfo
GetJournalQuestLocationInfo = function(questIndex)
    local zoneName, objectiveName, zoneIndex, poiIndex = orig_GetJournalQuestLocationInfo(questIndex)
    return CN.LookupZone(zoneName), objectiveName, zoneIndex, poiIndex
end

-- GetMapMouseoverInfo feeds the centered header text when hovering blobs.
-- worldmap.lua compares the returned name against self.control.zoneName (raw
-- GetMapName()) to decide whether to suppress the header (same zone = same
-- level, no point showing). If we rename here, renamed name == renamed zoneName
-- and the header is wrongly suppressed.
-- Fix: return the RAW name and rename later inside SetMapHeader instead.
-- We keep the location rename for non-zone surfaces that use this API.
local orig_GetMapMouseoverInfo = GetMapMouseoverInfo
GetMapMouseoverInfo = function(xN, yN)
    local locationName, textureFile, w, h, lx, ly, mapId = orig_GetMapMouseoverInfo(xN, yN)
    -- Only rename via locationNames, not zoneNames, so the blob comparison
    -- in UpdateBlobs stays raw. Zone blob names are renamed in SetMapHeader.
    local renamed = CN.LookupLocation(locationName)
    if renamed == locationName then
        -- Not a known location — still pass raw so comparison works.
        return locationName, textureFile, w, h, lx, ly, mapId
    end
    return renamed, textureFile, w, h, lx, ly, mapId
end

-- Hook ZO_WorldMapManager:SetMapHeader to rename zone blob names in the
-- centered header text. This fires after the raw comparison in UpdateBlobs
-- and DoMouseExitForPin, so suppression logic stays correct.
local function HookSetMapHeader()
    if not WORLD_MAP_MANAGER then return end
    if WORLD_MAP_MANAGER._CN_headerHooked then return end
    WORLD_MAP_MANAGER._CN_headerHooked = true

    local origSetMapHeader = WORLD_MAP_MANAGER.SetMapHeader
    WORLD_MAP_MANAGER.SetMapHeader = function(self, headerInfo)
        if headerInfo and headerInfo.nameText and headerInfo.nameText ~= "" then
            -- The nameText is zo_strformat(SI_WORLD_MAP_LOCATION_NAME, rawName).
            -- We can't un-format it, so rename the raw name stored in
            -- mouseoverCurrentLocation which is set just before SetMapHeader is called.
            local raw = self.mouseoverCurrentLocation
            if raw and raw ~= "" then
                local renamed = CN.LookupZone(raw)
                if renamed == raw then renamed = CN.LookupLocation(raw) end
                if renamed ~= raw then
                    -- Replace the raw name inside the already-formatted nameText.
                    local s, e = headerInfo.nameText:find(raw, 1, true)
                    if s then
                        headerInfo = {
                            nameText        = headerInfo.nameText:sub(1, s-1) .. renamed .. headerInfo.nameText:sub(e+1),
                            descriptionText = headerInfo.descriptionText,
                            owner           = headerInfo.owner,
                        }
                    end
                end
            end
        end
        return origSetMapHeader(self, headerInfo)
    end
end

local orig_GetPOIInfo = GetPOIInfo
GetPOIInfo = function(zoneIndex, poiIndex)
    local name, startDesc, finishedDesc, nX, nY, poiType, icon, isDisc, isShown = orig_GetPOIInfo(zoneIndex, poiIndex)
    return CN.LookupLocation(name), startDesc, finishedDesc, nX, nY, poiType, icon, isDisc, isShown
end

local orig_GetFastTravelNodeInfo = GetFastTravelNodeInfo
GetFastTravelNodeInfo = function(nodeIndex)
    local known, name, nX, nY, icon, glowIcon, poiType, isLocal, locked, disabled = orig_GetFastTravelNodeInfo(nodeIndex)
    return known, CN.LookupLocation(name), nX, nY, icon, glowIcon, poiType, isLocal, locked, disabled
end

local orig_GetMapNameById = GetMapNameById
GetMapNameById = function(mapId)
    return CN.LookupZone(orig_GetMapNameById(mapId))
end

local orig_GetZoneName = GetZoneName
GetZoneName = function(zoneId)
    return CN.LookupZone(orig_GetZoneName(zoneId))
end

-- Used by AppendWayshrineTooltip to show the parent zone label.
local orig_GetZoneNameById = GetZoneNameById
GetZoneNameById = function(zoneId)
    return CN.LookupZone(orig_GetZoneNameById(zoneId))
end

-- Blob names (handwritten font labels on the zoomed world map).
-- <br> is converted to \n here for the blob label specifically.
-- LookupZone already strips <br> to spaces for all other surfaces,
-- so we call _baseLookupZone directly to get the raw custom value with <br>.

-- CN.blobDefaultScales is wired to savedVars.blobDefaultScales in CustomNames.lua
-- after savedVars is initialised, so defaults persist across sessions.
local orig_GetMapBlobNameInfo = GetMapBlobNameInfo
GetMapBlobNameInfo = function(blobIndex)
    local locationName, normalizedLocX, normalizedLocY, normalizedWidth, nameScale = orig_GetMapBlobNameInfo(blobIndex)

    -- Record the raw default scale the first time we see this zone name.
    -- CN.blobDefaultScales is wired to savedVars after boot; guard here
    -- in case a blob renders before savedVars is ready.
    if CN.blobDefaultScales and not CN.blobDefaultScales[locationName] and nameScale and nameScale > 0 then
        CN.blobDefaultScales[locationName] = nameScale
    end

    -- Apply absolute scale override if set.
    -- zoneBlobScales stores the absolute nameScale value directly.
    local scales = CN.savedVars and CN.savedVars.zoneBlobScales
    if scales then
        local s = scales[locationName]
        if s == nil then
            local lower = locationName:lower()
            for k, v in pairs(scales) do
                if k:lower() == lower then s = v; break end
            end
        end
        if s then nameScale = s end
    end

    -- Use _baseLookupZone (pre-<br>-strip wrapper) to get the raw custom name,
    -- then substitute <br> with actual newlines for the blob label.
    local renamed = _baseLookupZone(locationName)
    if renamed:find("<br>", 1, true) then
        renamed = renamed:gsub("<br>", "\n")
    end
    return renamed, normalizedLocX, normalizedLocY, normalizedWidth, nameScale
end

-- Quest condition text: shown in tracker rows and compass area-override banner.
local orig_GetJournalQuestConditionInfo = GetJournalQuestConditionInfo
GetJournalQuestConditionInfo = function(questIndex, stepIndex, conditionIndex)
    local conditionText, curCount, maxCount, isFailCondition, isComplete, isGroupCreditShared, isVisible =
        orig_GetJournalQuestConditionInfo(questIndex, stepIndex, conditionIndex)
    return CN.LookupAny(conditionText), curCount, maxCount, isFailCondition, isComplete, isGroupCreditShared, isVisible
end

------------------------------------------------------------------------
-- Locations tab fix
-- ZO_MapLocationsData_Singleton:RefreshLocationList builds a cached list
-- from GetMapInfoByIndex (already overridden) but only refreshes once.
-- We hook it to ensure renamed names appear when the list is rebuilt.
------------------------------------------------------------------------

local function HookLocationsData()
    if not WORLD_MAP_LOCATIONS_DATA then return end
    if WORLD_MAP_LOCATIONS_DATA._CN_hooked then return end
    WORLD_MAP_LOCATIONS_DATA._CN_hooked = true

    local origRefresh = WORLD_MAP_LOCATIONS_DATA.RefreshLocationList
    WORLD_MAP_LOCATIONS_DATA.RefreshLocationList = function(self)
        self.mapData = nil
        origRefresh(self)
    end

    -- Invalidate the cache and rebuild. BuildLocationList appends to scrollData
    -- without clearing first, so we must clear it ourselves via ZO_ScrollList_Clear.
    WORLD_MAP_LOCATIONS_DATA.mapData = nil
    if WORLD_MAP_LOCATIONS and WORLD_MAP_LOCATIONS.list then
        pcall(function()
            ZO_ScrollList_Clear(WORLD_MAP_LOCATIONS.list)
            WORLD_MAP_LOCATIONS:BuildLocationList()
        end)
    end
end

------------------------------------------------------------------------
-- Subzone alert hook (EVENT_ZONE_CHANGED top-right notification)
------------------------------------------------------------------------

local function HookSubzoneAlert()
    local handlers = ZO_AlertText_GetHandlers and ZO_AlertText_GetHandlers()
    if not handlers then return end
    local orig = handlers[EVENT_ZONE_CHANGED]
    if not orig then return end
    handlers[EVENT_ZONE_CHANGED] = function(zoneName, subzoneName)
        return orig(CN.LookupZone(zoneName), CN.LookupAny(subzoneName))
    end
end

------------------------------------------------------------------------
-- Utility
------------------------------------------------------------------------

function CN.GetCurrentZoneName()
    local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex()
    if zoneIndex then
        local name = orig_GetZoneNameByIndex(zoneIndex)
        if name and name ~= "" then return name end
    end
    return GetUnitZone("player") or "Unknown"
end


local function HookLocationListRows()
    if WORLD_MAP_LOCATIONS and WORLD_MAP_LOCATIONS.list then
        pcall(function()
            if WORLD_MAP_LOCATIONS_DATA then
                WORLD_MAP_LOCATIONS_DATA.mapData = nil
            end
            ZO_ScrollList_Clear(WORLD_MAP_LOCATIONS.list)
            WORLD_MAP_LOCATIONS:BuildLocationList()
        end)
    end
end

function CN.RefreshHUDLabels()
    pcall(function()
        local title = ZO_WorldMap_GetMapTitle()
        if ZO_WorldMapTitle       then ZO_WorldMapTitle:SetText(title)       end
        if ZO_WorldMapCornerTitle then ZO_WorldMapCornerTitle:SetText(title) end
    end)
    pcall(function()
        if WORLD_MAP_MANAGER then WORLD_MAP_MANAGER.blobNamesDirty = true end
    end)
    HookLocationListRows()
end

------------------------------------------------------------------------
-- Init
------------------------------------------------------------------------

function CN.InitHUD()
    -- Apply the <br>-stripping wrapper to LookupZone now that CN is fully set up.
    InitLookupZoneWrapper()

    -- Directly patch the corner title label (ZO_WorldMapCornerTitle) on every
    -- map change. The corner registers its own OnWorldMapChanged callback at XML
    -- init time and calls ZO_WorldMap_GetMapTitle() — our hook on that function
    -- handles the world map title bar, but the corner title can lag or use a
    -- slightly different code path. Forcing it here guarantees correctness.
    local function UpdateCornerTitle()
        pcall(function()
            local label = ZO_WorldMapCornerTitle
            if label then
                label:SetText(ZO_WorldMap_GetMapTitle())
            end
        end)
    end

    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
        pcall(function()
            if WORLD_MAP_MANAGER then WORLD_MAP_MANAGER.blobNamesDirty = true end
        end)
        UpdateCornerTitle()
    end)

    CALLBACK_MANAGER:RegisterCallback("OnWorldMapCampaignChanged", UpdateCornerTitle)

    EVENT_MANAGER:RegisterForEvent(CN.ADDON_NAME .. "_MapShown",
        EVENT_WORLD_MAP_SCENE_SHOWN,
        function()
            pcall(function()
                if WORLD_MAP_MANAGER then WORLD_MAP_MANAGER.blobNamesDirty = true end
            end)
            zo_callLater(HookLocationListRows, 200)
            zo_callLater(HookLocationsData, 200)
            zo_callLater(HookSetMapHeader, 200)
            zo_callLater(UpdateCornerTitle, 100)
        end
    )

    EVENT_MANAGER:RegisterForEvent(CN.ADDON_NAME .. "_Activated",
        EVENT_PLAYER_ACTIVATED,
        function()
            zo_callLater(function()
                CN.RefreshHUDLabels()
                HookLocationsData()
                HookSetMapHeader()
            end, 500)
        end
    )

    -- Patch the subzone alert handler after all addons have loaded.
    EVENT_MANAGER:RegisterForEvent(CN.ADDON_NAME .. "_SubzoneHook",
        EVENT_ADD_ON_LOADED,
        function(_, name)
            if name == "ZO_UX" or name == "EsoUI" then
                HookSubzoneAlert()
                EVENT_MANAGER:UnregisterForEvent(CN.ADDON_NAME .. "_SubzoneHook", EVENT_ADD_ON_LOADED)
            end
        end
    )
end

