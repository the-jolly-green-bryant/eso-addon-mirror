WorldEventsTracker.Events = {}

--[[
-- Called when the addon is loaded
--
-- @param number eventCode
-- @param string addonName name of the loaded addon
--]]
function WorldEventsTracker.Events.onLoaded(eventCode, addOnName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addOnName == WorldEventsTracker.name then
        WorldEventsTracker:Initialise()
    end
end

--[[
-- Called when the user's interface loads and their character is activated after logging in or performing a reload of the UI.
-- This happens after <EVENT_ADD_ON_LOADED>, so the UI and all addons should be initialised already.
--
-- @param table zone : The Zone instance from LibWorldEvents
--]]
function WorldEventsTracker.Events.onZoneUpdate(zone)
    if WorldEventsTracker.ready == false then
        return
    end

    WorldEventsTracker.GUITimer:changeStatus(LibWorldEvents.Zone.onWorldEventMap)
    WorldEventsTracker.GUI:display(LibWorldEvents.Zone.onWorldEventMap)
end

--[[
-- Called when a new dragon instance is created
--
-- @param table dragon The new dragon instance
--]]
function WorldEventsTracker.Events.onNewDragon(dragon)
    dragon.GUI = {
        item  = nil,
        title = dragon.title,
    }

    dragon.GUI.item = WorldEventsTracker.GUI:createItem(dragon)

    WorldEventsTracker.Events.onDragonChangeType(dragon)
end

--[[
-- Called when all dragon are created from DragonList
--
-- @param table dragonList The DragonList table
--]]
function WorldEventsTracker.Events.onCreateAllDragon(dragonList)
    WorldEventsTracker.GUI:defineLabelType(WorldEventsTracker.savedVariables.gui.labelFormat)
end

--[[
-- Called when all dragon is removed from DragonList
--
-- @param table dragonList The DragonList table
--]]
function WorldEventsTracker.Events.onRemoveAllFromDragonList(dragonList)
    WorldEventsTracker.GUI:resetAllItems()
end

--[[
-- Called when a dragon's type change
--
-- @param Dragon dragon The concerned dragon
--]]
function WorldEventsTracker.Events.onDragonChangeType(dragon)
    if dragon.GUI == nil then
        return
    end
    
    local alpha = 1
    if dragon.type.colorRGB == nil then
        alpha = 0
    end

    dragon.GUI.item:changeColor(dragon.type.colorRGB, alpha)
end

--[[
-- Called when a dragon is killed
--
-- @param Dragon dragon The killed dragon
--]]
function WorldEventsTracker.Events.onDragonKilled(dragon)
    if dragon.GUI == nil then
        return
    end
    
    dragon.GUI.item:changeColor(nil, 0)
end

--[[
-- Called when a new poi instance is created
--
-- @param table poi The new poi instance
--]]
function WorldEventsTracker.Events.onNewPOI(poi)
    poi.GUI = {
        item  = nil,
        title = poi.title,
    }

    poi.GUI.item = WorldEventsTracker.GUI:createItem(poi)
end

--[[
-- Called when all poi are created from POIList
--]]
function WorldEventsTracker.Events.onCreateAllPOI()
    WorldEventsTracker.GUI:defineLabelType(WorldEventsTracker.savedVariables.gui.labelFormat)
end

--[[
-- Called when all poi is removed from POIList
--]]
function WorldEventsTracker.Events.onRemoveAllFromPOIList()
    WorldEventsTracker.GUI:resetAllItems()
end

--[[
-- Called when GUI items has been moved by user
--]]
function WorldEventsTracker.Events.onGuiMoveStop()
    if WorldEventsTracker.ready == false then
        return
    end

    WorldEventsTracker.GUI:savePosition()
end

--[[
-- Called when something change in GUI (like open inventory).
-- Used to some debug, the add to event is commented.
--]]
function WorldEventsTracker.Events.onGuiChanged(eventCode)
    if WorldEventsTracker.ready == false then
        return
    end
end

--[[
-- Called when player use the keybind to show/hide the GUI
--]]
function WorldEventsTracker.Events.keybindingsToggle()
    if WorldEventsTracker.ready == false then
        return
    end

    WorldEventsTracker.GUI:toggleToDisplay()
end

--[[
-- Called when the slash command is used
--
-- @param string extra All arguments passed to the command
--]]
function WorldEventsTracker.Events.command(extra)
    -- Thanks to wiki for argument parser
    local options = {}
    local searchResult = { string.match(extra, "^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end

    if #options == 0 then
        WorldEventsTracker.GUI:toggleToDisplay()
    elseif options[1] == "show" then
        WorldEventsTracker.GUI:show()
    elseif options[1] == "hide" then
        WorldEventsTracker.GUI:hide()
    elseif options[1] == "label" then
        if options[2] == nil then
            d('WorldEventsTracker : You must indicate the label type to use ("cp", or "name", or "ln")')
        elseif options[2] == "name" or options[2] == "ln" then
            WorldEventsTracker.GUI:labelUseName()
        else
            WorldEventsTracker.GUI:labelUseCardinalPoint()
        end
    else
        d("WorldEventsTracker : Unknown argument")
    end
end