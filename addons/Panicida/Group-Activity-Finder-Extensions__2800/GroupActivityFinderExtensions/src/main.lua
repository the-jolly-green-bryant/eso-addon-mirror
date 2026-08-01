-- ============================================================================
-- LOCALIZED GLOBALS
-- ============================================================================
local EVENT_MANAGER = EVENT_MANAGER
local ZO_SavedVars = ZO_SavedVars
local GetWorldName = GetWorldName
local pcall = pcall
local EVENT_ADD_ON_LOADED = EVENT_ADD_ON_LOADED

-- ============================================================================
-- CONSTANTS
-- ============================================================================
local ADDON_EVENT_NAMESPACE = "GroupActivityFinderExtensions_Event"

-- ============================================================================
-- MODULE DECLARATION
-- ============================================================================
local GAFE = GroupActivityFinderExtensions

-- ============================================================================
-- PRIVATE FUNCTIONS
-- ============================================================================

--- Initializes all addon modules after saved variables are loaded.
local function initializeModules()
  GAFE.TrialsChests.Init()
  GAFE.GroupExtensions.Init()
  GAFE.UnitFrameExtensions.Init()
  GAFE.DungeonsExtensions.Init()
  GAFE.DungeonCommands.Init()
  GAFE.BattlegroundsExtensions.Init()
  GAFE.BattlegroundCommands.Init()
  GAFE.QueueExtensions.Init()
  GAFE.Schedule.Init()
  GAFE.Map.Init()
  GAFE.QuestAutomation.Init()
  GAFE.Inventory.Init()
  GAFE.SettingsMenu.Init()
end

--- Event handler for addon loaded event.
--- Initializes the addon when it is fully loaded.
--- @param _ number The event code (unused)
--- @param addonName string The name of the addon that was loaded
local function onAddOnLoaded(_, addonName)
  if addonName ~= GAFE.name then return end
  EVENT_MANAGER:UnregisterForEvent(ADDON_EVENT_NAMESPACE, EVENT_ADD_ON_LOADED)

  -- Migrate old saved vars versions
  if not pcall(GAFE.Vars.Migrate) then
    LibPanicida.Debug.LogLater(
      "Could not migrate Group & Activity Finder Extensions settings. Reset to default.")
  end

  -- Load saved variables
  GAFE.SavedVars = ZO_SavedVars:NewAccountWide(
    GAFE.name .. "_Vars",
    GAFE.varsVersion,
    nil,
    GAFE.DefaultVars,
    GetWorldName()
  )

  initializeModules()
end

-- ============================================================================
-- MODULE REGISTRATION
-- ============================================================================
EVENT_MANAGER:RegisterForEvent(ADDON_EVENT_NAMESPACE, EVENT_ADD_ON_LOADED,
  onAddOnLoaded)
