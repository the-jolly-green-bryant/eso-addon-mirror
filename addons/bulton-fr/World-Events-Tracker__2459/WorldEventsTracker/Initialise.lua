WorldEventsTracker = {}

WorldEventsTracker.name           = "WorldEventsTracker"
WorldEventsTracker.savedVariables = nil
WorldEventsTracker.ready          = false
WorldEventsTracker.LAM            = LibAddonMenu2

--[[
-- Module initialiser
-- Intiialise savedVariables, settings panel and GUI
--]]
function WorldEventsTracker:Initialise()
    WorldEventsTracker.savedVariables = ZO_SavedVars:NewAccountWide("WorldEventsTrackerSavedVariables", 1, nil, {})
    self:initSavedVars()

    WorldEventsTracker.Settings:init()
    WorldEventsTracker.GUI:init()
    WorldEventsTracker.ready = true
end

--[[
-- Initialise all savedVariable's default values
--]]
function WorldEventsTracker:initSavedVars()
    if WorldEventsTracker.savedVariables.gui == nil then
        WorldEventsTracker.savedVariables.gui = {}
    end
    local gui = WorldEventsTracker.savedVariables.gui

    if gui.labelFormat == nil then
        gui.labelFormat = "cp"
    end
    if gui.labelFormat ~= "cp" and gui.labelFormat ~= "ln" then
        gui.labelFormat = "cp"
    end

    if gui.position == nil then
        gui.position = {}
    end
    if gui.position.left == nil then
        gui.position.left = 0
    end
    if gui.position.top == nil then
        gui.position.top = 0
    end

    if gui.locked == nil then
        gui.locked = false
    end

    if gui.displayWithWMap == nil then
        gui.displayWithWMap = false
    end

    if gui.toDisplay == nil then
        gui.toDisplay = true
    end

    if gui.track == nil then
        gui.track = {}
    end

    if gui.track[LibWorldEvents.Zone.WORLD_EVENT_TYPE.DOLMEN] == nil then
        gui.track[LibWorldEvents.Zone.WORLD_EVENT_TYPE.DOLMEN] = true
    end
    if gui.track[LibWorldEvents.Zone.WORLD_EVENT_TYPE.GEYSER] == nil then
        gui.track[LibWorldEvents.Zone.WORLD_EVENT_TYPE.GEYSER] = true
    end
    if gui.track[LibWorldEvents.Zone.WORLD_EVENT_TYPE.DRAGON] == nil then
        gui.track[LibWorldEvents.Zone.WORLD_EVENT_TYPE.DRAGON] = true
    end
    if gui.track[LibWorldEvents.Zone.WORLD_EVENT_TYPE.HARROWSTORM] == nil then
        gui.track[LibWorldEvents.Zone.WORLD_EVENT_TYPE.HARROWSTORM] = true
    end
    if gui.track[LibWorldEvents.Zone.WORLD_EVENT_TYPE.VOLCANIC_VENT] == nil then
        gui.track[LibWorldEvents.Zone.WORLD_EVENT_TYPE.VOLCANIC_VENT] = true
    end

    -- Convert old gui info
    if WorldEventsTracker.savedVariables.labelFormat ~= nil then
        gui.labelFormat = WorldEventsTracker.savedVariables.labelFormat
        WorldEventsTracker.savedVariables.labelFormat = nil
    end
    if WorldEventsTracker.savedVariables.left ~= nil then
        gui.position.left = WorldEventsTracker.savedVariables.left
        WorldEventsTracker.savedVariables.left = nil
    end
    if WorldEventsTracker.savedVariables.top ~= nil then
        gui.position.top = WorldEventsTracker.savedVariables.top
        WorldEventsTracker.savedVariables.top = nil
    end
end
