LibWorldEvents = {}

LibWorldEvents.name  = "LibWorldEvents"
LibWorldEvents.ready = false
LibWorldEvents.list  = nil

-- Define sub-directory namespaces
LibWorldEvents.Dragons = {}
LibWorldEvents.POI     = {}

--[[
-- Module initialiser
--]]
function LibWorldEvents:Initialise()
    LibWorldEvents.ready = true

    if LibWorldEvents.POIList ~= nil then
        self.list = LibWorldEvents.POIList:New(LibWorldEventPOIListUI)
    end
end
