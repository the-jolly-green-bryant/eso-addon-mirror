LibWorldEvents.POI.POI = {}
LibWorldEvents.POI.POI.__index = LibWorldEvents.POI.POI

--[[
-- Instanciate a new POI "object"
--
-- @param number poiListIdx The poi index in POIList.list
--
-- @return POI
--]]
function LibWorldEvents.POI.POI:new(poiListIdx)
    local zoneIdx, poiIdx = GetPOIIndices(
        LibWorldEvents.Zone.info.list.poiIDs[poiListIdx]
    )

    local newPOI = {
        eventType    = LibWorldEvents.Zone.worldEventMapType,
        eventIdx     = poiListIdx,
        WEInstanceId = nil,
        WEId         = nil,
        title        = {
            cp = LibWorldEvents.Zone.info.list.title.cp[poiListIdx],
            ln = LibWorldEvents.Zone.info.list.title.ln[poiListIdx]
        },
        poi         = {
            zoneIdx = zoneIdx,
            poiIdx  = poiIdx
        },
        status       = {
            previous  = nil,
            current   = nil,
            time      = 0,
        },
        repop        = {
            endTime  = 0,
            -- repopTime = 0, --@TODO
        },
    }

    setmetatable(newPOI, self)

    newPOI:updateWEInstanceId()
    LibWorldEvents.POI.POIStatus:initForPOI(newPOI)

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.poi.new,
        newPOI
    )

    return newPOI
end

--[[
-- Update the WorldEventId
-- Seem to be a not used method for POI, who comes from a Dragon copy/paste
-- @TODO Check if useless or not
--]]
function LibWorldEvents.POI.POI:updateWEId()
    self.WEId = GetWorldEventId(self.WEInstanceId)
end

--[[
-- Update the WorldEventInstanceId
--]]
function LibWorldEvents.POI.POI:updateWEInstanceId()
    self.WEInstanceId = GetPOIWorldEventInstanceId(self.poi.zoneIdx, self.poi.poiIdx)

    if self.WEInstanceId ~= 0 and LibWorldEvents.POI.POIList.currentWEListIdx == 0 then
        LibWorldEvents.POI.POIList.currentWEListIdx = self.eventIdx
    end
end

--[[
-- Change the poi's current status
--
-- @param string newStatus The poi's new status in POIStatus.list
-- @param string unitTag (default nil) The new unitTag
-- @param number unitPin (default nil) The new unitPin
--]]
function LibWorldEvents.POI.POI:changeStatus(newStatus, unitTag, unitPin)
    self.status.previous = self.status.current
    self.status.current  = newStatus
    self.status.time     = os.time()

    -- d(zo_strformat("WE POI ChangeStatus for <<1>> / <<2>>", self.title.ln, self.title.cp))

    if self.status.previous == nil or self.status.previous == self.status.current then
        self.status.time = 0
    end
    
    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.poi.changeStatus,
        self,
        newStatus
    )

    self:execStatusFunction()
end

--[[
-- Reset poi's status info and define the status with newStatus.
--
-- @param string newStatus The poi's new status in POIStatus.list
--]]
function LibWorldEvents.POI.POI:resetWithStatus(newStatus)
    self.status.previous = nil
    self.status.current  = newStatus
    self.status.time     = 0

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.poi.resetStatus,
        self,
        newStatus
    )
end

--[[
-- Execute the dedicated function for a status
--]]
function LibWorldEvents.POI.POI:execStatusFunction()
    if self.status.current == LibWorldEvents.POI.POIStatus.list.started then
        self:started()
    elseif self.status.current == LibWorldEvents.POI.POIStatus.list.ended then
        self:ended()
    end
end

--[[
-- Called when the poi (re)start
--]]
function LibWorldEvents.POI.POI:started()
    -- @TODO : repopTime

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.poi.started,
        self
    )
end

--[[
-- Called when the poi is ended
--]]
function LibWorldEvents.POI.POI:ended()
    self.repop.endTime = os.time()

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.poi.ended,
        self
    )
end
