
function LoreLibrary.GetPlayer3DPosition()
	local _, worldX, worldZ, worldY = GetUnitRawWorldPosition("player")
	return worldX / 100, worldY / 100, worldZ / 100
end

-- zoneId of the map that is currently being viewed, i.e. the world map or the
-- currently open sub map, not necessarily the player's location
function LoreLibrary.GetViewedZoneId()
	return GetZoneId(GetCurrentMapZoneIndex())
end

-- zoneId of the zone the player is physically standing in
function LoreLibrary.GetPlayerZoneId()
	return GetZoneId(GetUnitZoneIndex("player"))
end

-- returns the title of bookId, or nil if it can't be resolved
function LoreLibrary.GetBookTitle(bookId)
	local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(bookId)
	if not categoryIndex then return nil end
	return GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
end

local SHOW_ON_MAP_POLL_INTERVAL_MS = 16 -- roughly one frame
local SHOW_ON_MAP_POLL_TIMEOUT_S = 2 -- give up waiting and pan anyway past this point

--[[
WORLD_MAP_MANAGER:SetMapById synchronously fires "OnWorldMapChanged", which
runs ZO_MapPanAndZoom:InitializeMap(). That's supposed to be safe on its own:
if the new map's texture hasn't finished loading yet (InitializeMap's
CanInitializeMap() check is ZO_WorldMapContainer1:IsTextureLoaded() and not
:IsHidden()), it sets pendingInitializeMap = true instead of computing zoom
bounds, to be retried once the texture is actually ready - and
PanToNormalizedPosition itself checks that flag, just storing the target
position for InitializeMap to replay later instead of moving anything if it's
still true.

In practice that isn't sufficient: switching maps repeatedly (observed from
the 2nd switch onward, regardless of which map) still ends up panning/zooming
against stale bounds even though we're only ever calling
PanToNormalizedPosition, never touching zoom bounds ourselves. That suggests
CanInitializeMap()'s texture-loaded check can read "ready" a moment before the
new map's texture has actually finished swapping in - i.e. InitializeMap
completes "successfully" against data for the *previous* map rather than
staying pending.

Since pendingInitializeMap can't be trusted alone, poll the same readiness
check CanInitializeMap() itself uses (a field read, not a private upvalue -
ZO_WorldMap_GetPanAndZoom() returns the real object) once per frame until it
agrees the map is ready, then pan. This self-adjusts to however long the
actual texture swap takes instead of hoping a guessed fixed delay is always
long enough, with a timeout as a fallback in case something never settles.
]]--
local function IsWorldMapReadyToPanTo()
	local panAndZoom = ZO_WorldMap_GetPanAndZoom()
	return not panAndZoom.pendingInitializeMap
		and ZO_WorldMapContainer1 and ZO_WorldMapContainer1:IsTextureLoaded() and not ZO_WorldMapContainer1:IsHidden()
end

local function PanWhenMapIsReady(normalizedX, normalizedY, deadlineS)
	if IsWorldMapReadyToPanTo() or GetFrameTimeSeconds() >= deadlineS then
		ZO_WorldMap_PanToNormalizedPosition(normalizedX, normalizedY)
		return
	end
	zo_callLater(function()
		PanWhenMapIsReady(normalizedX, normalizedY, deadlineS)
	end, SHOW_ON_MAP_POLL_INTERVAL_MS)
end

local AURBIS_MAP_ID = 439

-- shows the top-level "Aurbis" (cosmic) map - the overview of Tamriel and
-- the other realms - used as a fallback by ShowLocationOnMap when a location
-- has no navigable map of its own even after Data:GetBookLocations' one-level
-- parent-zone fallback (e.g. a zone nested deeper than one level of
-- parenting)
function LoreLibrary.ShowAurbisMap()
	WORLD_MAP_MANAGER:SetMapById(AURBIS_MAP_ID)
	ZO_WorldMap_ShowWorldMap()
end

function LoreLibrary.ShowLocationOnMap(location)
	if not location then return end
	if location.mapId <= 0 then
		LoreLibrary.ShowAurbisMap()
		return
	end

	-- if we dont set to player location first
	-- then the SET_MAP_RESULT_MAP_CHANGED condition
	-- in WORLD_MAP_MANAGER:SetMapById might fail
	SetMapToPlayerLocation()
	WORLD_MAP_MANAGER:SetMapById(location.mapId)

	local normalizedX, normalizedY = GetNormalizedWorldPosition(location.zoneId, location.worldX * 100, location.worldZ * 100, location.worldY * 100)
	ZO_WorldMap_ShowWorldMap()

	ZO_WorldMap_GetGamepadMap():StopMotion()
	PanWhenMapIsReady(normalizedX, normalizedY, GetFrameTimeSeconds() + SHOW_ON_MAP_POLL_TIMEOUT_S)
end
