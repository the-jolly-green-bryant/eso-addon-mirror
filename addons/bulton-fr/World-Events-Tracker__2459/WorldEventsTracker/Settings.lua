WorldEventsTracker.Settings = {}

-- @var string panelName The name of the settings panel
WorldEventsTracker.Settings.panelName = "WorldEventsTrackerSettingsPanel"

--[[
-- Initialise the settings panel
--]]
function WorldEventsTracker.Settings:init()
    local panelData = {
        type   = "panel",
        name   = "World Events Tracker",
        author = "bulton-fr",
    }

    WorldEventsTracker.LAM:RegisterAddonPanel(self.panelName, panelData)
    self:build()
end

--[[
-- Build the settings panel
--]]
function WorldEventsTracker.Settings:build()
    local optionsData = {
        self:buildGUILocked(),
        self:buildDisplayedWithWorldMap(),
        self:buildPositionType(),
        {
            type = "header",
            name = GetString(SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_HEAD)
        },
        {
            type = "description",
            text = GetString(SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_DESC)
        },
        self:buildTrack(LibWorldEvents.Zone.WORLD_EVENT_TYPE.DOLMEN),
        self:buildTrack(LibWorldEvents.Zone.WORLD_EVENT_TYPE.GEYSER),
        self:buildTrack(LibWorldEvents.Zone.WORLD_EVENT_TYPE.DRAGON),
        self:buildTrack(LibWorldEvents.Zone.WORLD_EVENT_TYPE.HARROWSTORM),
        self:buildTrack(LibWorldEvents.Zone.WORLD_EVENT_TYPE.VOLCANIC_VENT),
        self:buildTrack(LibWorldEvents.Zone.WORLD_EVENT_TYPE.MIRRORMOOR),
        self:buildTrack(LibWorldEvents.Zone.WORLD_EVENT_TYPE.WRITHING)
    }

    WorldEventsTracker.LAM:RegisterOptionControls(self.panelName, optionsData)
end

--[[
-- Build the "GUI Locked" part of the panel
--
-- @return table
--]]
function WorldEventsTracker.Settings:buildGUILocked()
    return {
        type = "checkbox",
        name = GetString(SI_WORLD_EVENTS_TRACKER_SETTINGS_LOCK_UI),
        getFunc = function()
            return WorldEventsTracker.GUI:isLocked()
        end,
        setFunc = function(value)
            WorldEventsTracker.GUI:defineLocked(value)
        end,
    }
end

--[[
-- Build the "Displayed with the World Map" part of the panel
--
-- @return table
--]]
function WorldEventsTracker.Settings:buildDisplayedWithWorldMap()
    return {
        type = "checkbox",
        name = GetString(SI_WORLD_EVENTS_TRACKER_SETTINGS_DISPLAY_WITH_WM),
        getFunc = function()
            return WorldEventsTracker.GUI:isDisplayWithWMap()
        end,
        setFunc = function(value)
            WorldEventsTracker.GUI:defineDisplayWithWMap(value)
        end,
    }
end

--[[
-- Build the "Position type" part of the panel
--
-- @return table
--]]
function WorldEventsTracker.Settings:buildPositionType()
    return {
        type          = "dropdown",
        name          = GetString(SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE),
        tooltip       = GetString(SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE_TOOLTIP),
        choices       = {
            GetString(SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE_CHOICE_LN),
            GetString(SI_WORLD_EVENTS_TRACKER_SETTINGS_POSITION_TYPE_CHOICE_CP)
        },
        choicesValues = {"ln", "cp"},
        getFunc       = function()
            return WorldEventsTracker.GUI:obtainLabelType()
        end,
        setFunc       = function(labelMode)
            if labelMode == "ln" then
                WorldEventsTracker.GUI:labelUseName()
            else
                WorldEventsTracker.GUI:labelUseCardinalPoint()
            end
        end
    }
end

--[[
-- Build the "Track Dolmen" part of the panel
--
-- @return table
--]]
function WorldEventsTracker.Settings:buildTrack(trackedType)
    return {
        type = "checkbox",
        name = GetString(_G["SI_WORLD_EVENTS_TRACKER_SETTINGS_TRACK_"..string.upper(trackedType)]),
        getFunc = function()
            return WorldEventsTracker.GUI:isTracked(trackedType)
        end,
        setFunc = function(value)
            WorldEventsTracker.GUI:defineTracked(trackedType, value)
        end,
    }
end
