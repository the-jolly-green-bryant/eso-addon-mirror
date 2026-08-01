WorldEventsTracker.GUITimer         = setmetatable({}, {__index = LibWorldEvents.Timer})
WorldEventsTracker.GUITimer.__index = WorldEventsTracker.GUITimer

-- @var string name The timer's name
WorldEventsTracker.GUITimer.name = "WorldEventsTracker_GUITimer"

-- @var number time The time in ms where update() which will be called
WorldEventsTracker.GUITimer.time = 1000

--[[
-- Callback function on timer.
-- Called each 1sec in dragons|poi zone.
-- Update the GUI for each dragons|poi.
--]]
function WorldEventsTracker.GUITimer:update()
    if LibWorldEvents.Dragons.ZoneInfo.onMap == true then
        LibWorldEvents.Dragons.DragonList:execOnAll(function(dragon)
            dragon.GUI.item:update()
        end)
    else
        -- poi events; update method not called on others maps
        LibWorldEvents.POI.POIList:execOnAll(function(poi)
            poi.GUI.item:update()
        end)
    end
end
