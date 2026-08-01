GearOverview = {}
local lib = GearOverview

lib.name = "GearOverview"
lib.author = "@ronnievdc"
lib.version = "0.11.0"
lib.setList = {}
lib.presets = {}
lib.applicablePresets = nil
lib.activePreset = nil
lib.bag = {}
lib.setNameToId = {}
lib.maxSetId = 0
lib.scanMaxSetId = 1000 -- As of "Update 47 Feast of Shadows" there are 846 sets, scan till 1000 to be future ready

local logger

lib.LOG_LEVEL_VERBOSE = "V"
lib.LOG_LEVEL_DEBUG = "D"
lib.LOG_LEVEL_INFO = "I"
lib.LOG_LEVEL_WARNING = "W"
lib.LOG_LEVEL_ERROR = "E"

if LibDebugLogger then
    logger = LibDebugLogger.Create(lib.name)
end

--- Log a line to debuglogger
--- @param level string LOG_LEVEL_X
--- @return void
lib.log = function(level, ...)
    if logger == nil then
        return
    end
    if type(logger.Log) == "function" then
        logger:Log(level, ...)
    end
end

lib.debug = function (...)
    lib.log(lib.LOG_LEVEL_DEBUG, ...)
end

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
--- Fired when an addon is loaded
--- @param event table
--- @param addonName string The name of the loaded addon
--- @return void
function lib.OnAddOnLoaded(_, addonName)
    if addonName ~= lib.name then
        return
    end
    lib:Initialize()
end

-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
------ Fired when this addon is loaded
----- @return void
function lib:Initialize()
    EVENT_MANAGER:UnregisterForEvent(lib.name, EVENT_ADD_ON_LOADED)

    -- Register slash commands
    SLASH_COMMANDS['/gear'] = lib.showWindow

    lib.applicablePresets = lib.getApplicablePresets()

    -- Initialize settings
    lib.createSettings()

    local scene = ZO_Scene:New("GearOverviewUI", SCENE_MANAGER)
    scene:AddFragment(ZO_SimpleSceneFragment:New(GearOverviewUI))

    lib.scanSets()

    ZO_CreateStringId("SI_BINDING_NAME_OPEN_GEAR_OVERVIEW", "Show window")
end

-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(lib.name, EVENT_ADD_ON_LOADED, lib.OnAddOnLoaded)