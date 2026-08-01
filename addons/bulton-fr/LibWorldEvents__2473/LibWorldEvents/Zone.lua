LibWorldEvents.Zone = {}

-- @var table All managed world event type
LibWorldEvents.Zone.WORLD_EVENT_TYPE = {
    DRAGON        = "dragon",
    HARROWSTORM   = "harrowstorm",
    GEYSER        = "geyser",
    DOLMEN        = "dolmen",
    VOLCANIC_VENT = "volcanicvent",
    -- OBLIVON_PORTAL = "oblivon portal" -- Not plugged
    -- NYMIC = "nymic" -- Not plugged
    MIRRORMOOR    = "mirrormoor",
    WRITHING      = "writhing",
}

-- @var boolean If player is on a map with world events
LibWorldEvents.Zone.onWorldEventMap = false

-- @var nil|string The current world event type on the map
LibWorldEvents.Zone.worldEventMapType = nil

-- @var nil|number The previous ZoneId
LibWorldEvents.Zone.lastZoneId = nil

-- @var boolean If the player has changed zone
LibWorldEvents.Zone.changedZone = false

-- @var ref-to-table Info about the current zone (ref to list value corresponding to the zone)
LibWorldEvents.Zone.info = nil

--[[
-- Update info about the current zone.
--]]
function LibWorldEvents.Zone:updateInfo()
    local currentZoneId = GetZoneId(GetUnitZoneIndex("player"))

    self.changedZone = false
    if self.lastZoneId ~= currentZoneId then
        self.changedZone = true
        self.lastZoneId  = currentZoneId
    end

    self:checkWorldEvent(currentZoneId)
    self:initWorldEvent()

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.zone.updateInfo,
        self
    )
end

--[[
-- Reset all properties about the world event on the current map
--]]
function LibWorldEvents.Zone:resetZoneData()
    self.info              = nil
    self.onWorldEventMap   = false
    self.worldEventMapType = nil

    LibWorldEvents.Dragons.ZoneInfo.onMap = false
    LibWorldEvents.POI.HarrowStorms.onMap = false
    LibWorldEvents.POI.Geyser.onMap       = false
    LibWorldEvents.POI.Dolmen.onMap       = false
    LibWorldEvents.POI.VolcanicVent.onMap = false
    LibWorldEvents.POI.Mirrormoor.onMap   = false
    LibWorldEvents.POI.Writhing.onMap     = false
end

--[[
-- Check if it's a zone with managed world events.
--
-- @param number currentZoneId The current zone id
--]]
function LibWorldEvents.Zone:checkWorldEvent(currentZoneId)
    self:resetZoneData()

    local dragonsZoneList      = LibWorldEvents.Dragons.ZoneInfo:obtainList()
    local harrowstormZoneList  = LibWorldEvents.POI.HarrowStorms:obtainList()
    local geyserZoneList       = LibWorldEvents.POI.Geyser:obtainList()
    local dolmenZoneList       = LibWorldEvents.POI.Dolmen:obtainList()
    local volcanicVentZoneList = LibWorldEvents.POI.VolcanicVent:obtainList()
    local mirrormoorZoneList   = LibWorldEvents.POI.Mirrormoor:obtainList()
    local writhingZoneList     = LibWorldEvents.POI.Writhing:obtainList()

    self:checkWorldEventForType(currentZoneId, self.WORLD_EVENT_TYPE.DRAGON, dragonsZoneList)
    self:checkWorldEventForType(currentZoneId, self.WORLD_EVENT_TYPE.HARROWSTORM, harrowstormZoneList)
    self:checkWorldEventForType(currentZoneId, self.WORLD_EVENT_TYPE.GEYSER, geyserZoneList)
    self:checkWorldEventForType(currentZoneId, self.WORLD_EVENT_TYPE.DOLMEN, dolmenZoneList)
    self:checkWorldEventForType(currentZoneId, self.WORLD_EVENT_TYPE.VOLCANIC_VENT, volcanicVentZoneList)
    self:checkWorldEventForType(currentZoneId, self.WORLD_EVENT_TYPE.MIRRORMOOR, mirrormoorZoneList)
    self:checkWorldEventForType(currentZoneId, self.WORLD_EVENT_TYPE.WRITHING, writhingZoneList)

    -- If we are in a dungeon/delve/battleground or in an house : no world event.
    if IsUnitInDungeon("player") or GetCurrentZoneHouseId() ~= 0 then
        self:resetZoneData()
    end

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.zone.checkWorldEvents,
        self
    )
end

--[[
-- Check if a specific world event type exist on the current zone
--
-- @param number currentZoneId
-- @param string weType The type of world event check (cf self.WORLD_EVENT_TYPE table)
-- @param table zoneList The list of zone where the check world event exist
    (cf Dragons.ZoneList.list, POI.(Dolmen|Geyser|HarrowStorms).list)
--]]
function LibWorldEvents.Zone:checkWorldEventForType(currentZoneId, weType, zoneList)
    if self.onWorldEventMap == true then
        return
    end

    for zoneListIdx, zoneInfo in ipairs(zoneList) do
        if currentZoneId == zoneInfo.zoneId then
            self.info              = zoneList[zoneListIdx]
            self.onWorldEventMap   = true
            self.worldEventMapType = weType
            return
        end
    end
end

--[[
-- Initialise the system for the current type of world event
-- * Define the "onMap" property for the world event type table
-- * Update the list for the world event type
-- * Call the check of status for all world event available on the map
--]]
function LibWorldEvents.Zone:initWorldEvent()
    if self.onWorldEventMap == false then
        return
    end

    if self.worldEventMapType == self.WORLD_EVENT_TYPE.DRAGON then
        LibWorldEvents.Dragons.ZoneInfo.onMap = true

        LibWorldEvents.Dragons.DragonList:update()
        LibWorldEvents.Dragons.DragonStatus:checkAllDragon()
    else
        if self.worldEventMapType == self.WORLD_EVENT_TYPE.HARROWSTORM then
            LibWorldEvents.POI.HarrowStorms.onMap = true
        elseif self.worldEventMapType == self.WORLD_EVENT_TYPE.GEYSER then
            LibWorldEvents.POI.Geyser.onMap = true
        elseif self.worldEventMapType == self.WORLD_EVENT_TYPE.DOLMEN then
            LibWorldEvents.POI.Dolmen.onMap = true
        elseif self.worldEventMapType == self.WORLD_EVENT_TYPE.VOLCANIC_VENT then
            LibWorldEvents.POI.VolcanicVent.onMap = true
        elseif self.worldEventMapType == self.WORLD_EVENT_TYPE.MIRRORMOOR then
            LibWorldEvents.POI.Mirrormoor.onMap = true
        elseif self.worldEventMapType == self.WORLD_EVENT_TYPE.WRITHING then
            LibWorldEvents.POI.Writhing.onMap = true
        else
            -- d("unknown event")
            return
        end

        LibWorldEvents.POI.POIList:update()
        LibWorldEvents.POI.POIStatus:checkAllPOI()
    end
end
