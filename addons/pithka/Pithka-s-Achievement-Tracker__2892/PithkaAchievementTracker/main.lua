-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.name = "PithkaAchievementTracker"
PITHKA.isInitialized = false  -- Flag to track initialization state

-- convenient namespacing
local api = PITHKA.common.api
local constants = PITHKA.common.constants
local utils = PITHKA.common.utils
local layout = PITHKA.layout
local ui = PITHKA.ui
local data = PITHKA.data
local groupFinder = PITHKA.groupFinder

-- Debug function
local debugEnabled = false -- Disabled now that keybinding issue is resolved
local function debug(msg)
    if debugEnabled then
        d('|c00FFFF[PITHKA]|r ' .. msg)
    end
end

---------------------------------------------------------------------------------------------------------
-- Toggle UI
---------------------------------------------------------------------------------------------------------

function PITHKA.toggleUI()
  api.gui.toggleUI()
end

---------------------------------------------------------------------------------------------------------
-- Toggle Group Finder UI
---------------------------------------------------------------------------------------------------------

function PITHKA.toggleGroupFinderUI()
  if PITHKA.views.groupFinderStandalone then
    PITHKA.views.groupFinderStandalone.toggleUI()
  else
    debug("Group Finder Standalone not initialized")
  end
end

---------------------------------------------------------------------------------------------------------
-- Dialog testing
---------------------------------------------------------------------------------------------------------


-- Dialog shown when attempting to join a group (blocks further join attempts)
ZO_Dialogs_RegisterCustomDialog("PITHKA_JOIN_ATTEMPT_DIALOG", {
  title = { text = "Joining Group..." },
  mainText = { text = "Attempting to join group. Please wait..." },
  buttons = {
      [1] = {
          text = SI_OK,
      }
  }
})

---------------------------------------------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------------------------------------------

function PITHKA:Initialize()
  -- Check if already initialized
  if PITHKA.isInitialized then
    debug("PITHKA already initialized, skipping...")
    return
  end
  
  debug("Starting PITHKA initialization...")
  
  -- Load savedVars to drive initialization
  PITHKA.data.savedVars.initalize()
  
  -- Initialize groupFinder
  PITHKA.groupFinder.instance = PITHKA.groupFinder.GroupFinder:New()
  
  -- Build UI
  SCENE_MANAGER:RegisterTopLevel(PITHKA_GUI, locksUIMode)

  -- create screens views
  s1 = PITHKA.views.baseDungeons.initialize() 
  s2 = PITHKA.views.trifectaDungeons.initialize()
  s3 = PITHKA.views.trials.initialize()
  s4 = PITHKA.views.scoresAndTris.initialize()
  -- create tray views
  PITHKA.views.groupFinderStandalone.initialize()
  PITHKA.views.QR.initialize()
  -- Note: joinGF tray removed since Group Finder is now standalone
  -- create nav bar
  nb = layout.navBar.new()
  nb:addScreen(s1)
  nb:addScreen(s2)
  nb:addScreen(s3)
  nb:addScreen(s4)
  nb:registerScreenCallback()

  -- create common view
  PITHKA.views.commonView.initialize()

  -- Trigger the callback to show the correct screen on startup
  local currentScreen = data.savedVars.get('currentScreen')
  data.savedVars.set('currentScreen', currentScreen)

  -- Don't automatically start GroupFinder during initialization
  -- It will start only when user opens the groupFinder tray
  -- Start fetching trial scores
  PITHKA.data.scores.fetchTrials()
  -- Start fetching endless archive scores
  PITHKA.data.scores.fetchEndless()
  -- initialize slash commands
  SLASH_COMMANDS["/4m"] = PITHKA.toggleUI
  SLASH_COMMANDS["/pat"] = PITHKA.toggleUI
  SLASH_COMMANDS["/pgf"] = PITHKA.toggleGroupFinderUI
  
  -- Mark as initialized
  PITHKA.isInitialized = true
  debug("PITHKA initialization completed")
end

---------------------------------------------------------------------------------------------------------
-- Addon Callbacks Updater (on trial complete)
---------------------------------------------------------------------------------------------------------


-- On Toon Load ---------------------- 
function PITHKA.OnToonLoaded()
  zo_callLater(function()
    debug('Delayed PITHKA:Initialize() starting...')
    PITHKA:Initialize()
  end, 500)
end
EVENT_MANAGER:RegisterForEvent(PITHKA.name, EVENT_PLAYER_ACTIVATED, PITHKA.OnToonLoaded)

-- On Addon Load ----------------------
function PITHKA.OnAddOnLoaded(event, addonName)
    ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_PITHKA", "Toggle Achievement Tracker")
    ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_PITHKA_GROUP_FINDER", "Toggle Group Finder")
  -- used to initialize here, moved it for faster load screens
end

EVENT_MANAGER:RegisterForEvent(PITHKA.name, EVENT_ADD_ON_LOADED, PITHKA.OnAddOnLoaded)
