LibWorldEvents.POI.POIStatus = {}

-- @var table : List of all status which can be defined
LibWorldEvents.POI.POIStatus.list = {
    ended   = "ended",
    started = "started",
}

--[[
-- Initialise the status for a poi
--
-- @param POI poi : The poi with the status to initialise
--]]
function LibWorldEvents.POI.POIStatus:initForPOI(poi)
    self:update(poi)

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.poiStatus.initPOI,
        self,
        poi
    )
end

--[[
-- Check the status for all poi instancied
--]]
function LibWorldEvents.POI.POIStatus:checkAllPOI()
    LibWorldEvents.POI.POIList:execOnAll(self.checkForPOI)

    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.poiStatus.checkAll,
        self
    )
end

--[[
-- Check the status for a specific poi.
-- It's a callback for POIList:execOnAll
--
-- @param POI poi The poi to check
--]]
function LibWorldEvents.POI.POIStatus.checkForPOI(poi)
    LibWorldEvents.POI.POIStatus:update(poi)
    
    LibWorldEvents.Events.callbackManager:FireCallbacks(
        LibWorldEvents.Events.callbackEvents.poiStatus.check,
        LibWorldEvents.POI.POIStatus,
        poi
    )
end

--[[
-- Check and update the status for a specific poi
--
-- @param POI poi The poi instance to update
--]]
function LibWorldEvents.POI.POIStatus:update(poi)
    poi:updateWEInstanceId()

    local realStatus = self.list.ended
    if poi.WEInstanceId ~= 0 then
        realStatus = self.list.started
    end

    if poi.status.current ~= realStatus then
        poi:resetWithStatus(realStatus)
    end
end
