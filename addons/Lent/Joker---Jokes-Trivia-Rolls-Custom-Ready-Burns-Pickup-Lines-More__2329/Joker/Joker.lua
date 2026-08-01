-- * _JOKER_VERSION: 8.0.0 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------
  *
	* Authors:
	* - Lent (IGN @CallMeLent, Github @adefee)
  *
  * Contributors & Special Thanks:
  * - Sirinsidiator (IGN, Github @Sirinsidiator)
  * - Baertram (IGN, Github @Baertram)
  * - Manavortex (IGN, Github @Baertram)
  *
  * Contents:
  * - Utility (imported from Joker-Util.lua via Joker.txt)
  * - Data Ops (imported from Joker-Data.lua via Joker.txt)
  * - Core & Default Values
  * - Addon Instantiation
  *
]]--


--[[----------------------------------------------------------
  Core & Default Values
  - Import data, set any additional defaults or overwrites, etc
  ----------------------------------------------------------
]]--

-- Handle includes
JokerData = JokerData or {} -- content
JokerData.Config = JokerData.Config or {} -- content-specific config (commands, etc)
JokerL = JokerL or {} -- i18n
Joker = Joker or {} -- vars, defaults

local L = Joker.locale -- sets our locale
local Util = JokerUtilityFn or {} -- utility functions used throughout
local Data = JokerDataFn or {} -- data and content processing & display

--[[----------------------------------------------------------
  Constants
  ----------------------------------------------------------
]]--
local ENABLED = 1
local DISABLED = 0
local SAVED_VARS_VERSION = 2
local VERSION_4_2_0 = 402000
local VERSION_4_3_0 = 403000
local VERSION_8_4_0 = 804000
local VERSION_999_999_0 = 999999000

--[[----------------------------------------------------------
  Helper Functions
  ----------------------------------------------------------
]]--

-- debugLog()
-- Helper; Outputs debug message to console if debug mode is enabled
local function debugLog(message)
  if Joker and Joker.saved and Joker.saved.internal and Joker.saved.internal.showDebug and Joker.saved.internal.showDebug > DISABLED then
    d('Joker: ' .. message)
  end
end

-- Joker.ToggleDebug()
function Joker.ToggleDebug()
  if not Joker.saved or not Joker.saved.internal then
    d('Joker: Error - saved variables not initialized yet.')
    return
  end
  
  if Joker.saved.internal.showDebug > DISABLED then
    d('Disabling Joker debug mode.')
    Joker.saved.internal.showDebug = DISABLED
  else
    d('Enabling Joker debug mode.')
    Joker.saved.internal.showDebug = ENABLED
  end
end

-- Joker.OutputJoke()
-- Display; Output a joke to either console or chat based on settings
local function OutputJoke(joke, logToConsole)
  if joke and not Util.isEmpty(joke) then
    if logToConsole or Joker.saved.enable.consoleOnly then
      d(joke)
    else
      StartChatInput(joke, CHAT_CHANNEL)
    end
  end
end

-- Joker.Joke()
-- Display; Retrieve and display a joke (either in chatbox or in console). We aren't allowed to send on user's behalf.
function Joker.Joke(category, context, logToConsole)
  local joke = Data.GetJoke(category, context)
  OutputJoke(joke, logToConsole)
end

-- Joker.AnyJoke()
-- Display; Retrieve and display a random joke based on context
function Joker.AnyJoke(context, logToConsole)
  local joke = Data.GetRandomJoke(context)
  OutputJoke(joke, logToConsole)
end

-- Joker.Trivia()
-- Display; Retrieve and display a trivia (either in chatbox or in console). We aren't allowed to send on user's behalf.
function Joker.Trivia(category, context, logToConsole)
  local trivia = Data.GetTrivia(category, context)
  OutputJoke(trivia, logToConsole)
end

-- Joker.AnyTrivia()
-- Display; Retrieve and display a random trivia based on context
function Joker.AnyTrivia(context, logToConsole)
  local trivia = Data.GetRandomTrivia(context)
  OutputJoke(trivia, logToConsole)
end



--[[----------------------------------------------------------
  Addon Instantiation
  - Initialize any runtimes & ESO hooks

  CONTENTS:
  - runtime_maiden()
  - runtime_onload()
  - Joker.Activated()
  - EVENT: event_player_activated
  - Joker.OnAddOnLoaded
  - EVENT: event_add_on_loaded
  ----------------------------------------------------------
]]--



-- Runs only the first time load
-- Specifically snake_case because it's a runtime function
local function runtime_maiden()
  debugLog('Running runtime_maiden()')
  d('Joker ' .. Joker.version .. ' is now active! Type /joker at any time to view and customize Joker commands & settings.')
  Joker.saved.internal.firstLoad = DISABLED
end

--[[----------------------------------------------------------
  Version Migration Functions
  ----------------------------------------------------------
]]--

-- migrate_to_4_2_0()
-- Migration; Update 4.2.0 added curses, needs to not be default
local function migrate_to_4_2_0()
  debugLog('Housekeeping for update to version 4.2.0')
  table.insert(Joker.saved.randomPool.blacklist, 'Curse')
  Util.sortSet(Joker.saved.randomPool.blacklist)
  Joker.saved.internal.lastUpdate = VERSION_4_2_0
end

-- migrate_to_4_3_0()
-- Migration; Update 4.3.0 updates settings to toggle rolls being posted to chat, adds new savedVar option
local function migrate_to_4_3_0()
  debugLog('Housekeeping for update to version 4.3.0')
  Joker.saved.rolls.postToChat = DISABLED
  Joker.saved.internal.lastUpdate = VERSION_4_3_0
end

-- migrate_to_8_4_0()
-- Migration; Update 8.4.0 refactored code for better maintainability and clearer variable names
local function migrate_to_8_4_0()
  debugLog('Housekeeping for update to version 8.4.0')
  
  -- Rename randomPool.enabled to randomPool.enabledCategories for clarity
  if Joker.saved.randomPool.enabled then
    Joker.saved.randomPool.enabledCategories = Joker.saved.randomPool.enabled
    Joker.saved.randomPool.enabled = nil -- Remove old key
  end
  
  Joker.saved.internal.lastUpdate = VERSION_8_4_0
end

-- migrate_to_999_998_0()
-- Migration; This is a test migration only visible in debug mode.
local function migrate_to_999_998_0()
  debugLog('Housekeeping for update to version 999_999_0')
  debugLog('(This is a test migration only visible in debug mode.)')
  Joker.saved.internal.testMigration = Joker.saved.internal.lastUpdate
end

-- Run any updates needed if addon has been updated
local function runtime_updates()
  debugLog('Running runtime_updates()')
  debugLog('Joker.saved.internal.lastUpdate: ' .. Joker.saved.internal.lastUpdate)
  if Joker.saved.internal.lastUpdate < Joker.versionESO then
    local oldVersion = Joker.saved.internal.lastUpdate
    debugLog('oldVersion: ' .. oldVersion)
    -- Run migrations in order
    if oldVersion < VERSION_4_2_0 then
      migrate_to_4_2_0()
    end

    if oldVersion < VERSION_4_3_0 then
      migrate_to_4_3_0()
    end

    if oldVersion < VERSION_8_4_0 then
      migrate_to_8_4_0()
    end

    if oldVersion < VERSION_999_999_0 then
      migrate_to_999_998_0()
    end
  end
end

-- registerJokeCommand()
-- Helper; Register slash commands for a joke category
local function registerJokeCommand(category, config)
  -- Register primary command: /joke-<command>
  SLASH_COMMANDS["/joke-" .. config.command] = function(context) 
    Joker.Joke(category, context) 
  end
  
  -- Optionally register shorthand command: /<command>
  if config.whitelistSlashCommand then
    SLASH_COMMANDS["/" .. config.command] = function(context) 
      Joker.Joke(category, context) 
    end
  end
end

-- registerTriviaCommand()
-- Helper; Register slash commands for a trivia category
local function registerTriviaCommand(category, config)
  -- Register primary command: /<command> (e.g., /trivia-eso)
  SLASH_COMMANDS["/" .. config.command] = function(context) 
    Joker.Trivia(category, context) 
  end
  
  -- Optionally register shorthand command (if whitelistSlashCommand is true)
  -- This is less common for trivia since the command names are already unique
  if config.whitelistSlashCommand then
    -- Already registered above, no need to duplicate
  end
end

-- loadJokeCategories()
-- Helper; Load and register all joke categories, returns total joke count
local function loadJokeCategories()
  local countAllJokes = 0
  Joker.saved.randomPool.enabledCategories = {}
  
  for categoryKey, categoryData in pairs(JokerData) do
    if categoryKey == 'Config' then
      -- Metadata entries, ignore
    else
      if Util.setContains(JokerData.Config, categoryKey) and JokerData.Config[categoryKey].label and JokerData.Config[categoryKey].command then
        if not JokerData.Config[categoryKey].disable and not JokerData.Config[categoryKey].trivia then
          -- Load & count all the jokes for this category
          local categoryJokeCount = Util.countSet(JokerData[categoryKey])
          countAllJokes = countAllJokes + categoryJokeCount
          Joker.saved.count.categories[categoryKey] = categoryJokeCount
          Joker.saved.activeJokes = Joker.saved.activeJokes or {}
          Joker.saved.activeJokes[categoryKey] = JokerData.Config[categoryKey].label

          -- If there are jokes (> 0), enable:
          if categoryJokeCount > 0 then

            -- Add joke to list of enabled categories
            table.insert(Joker.saved.randomPool.enabledCategories, categoryKey);

            -- Register slash commands for this category
            registerJokeCommand(categoryKey, JokerData.Config[categoryKey])
          else
            d('Joker: The category "' .. categoryKey .. '" was enabled but contains no jokes. It has not been loaded (uhhh ... there\'s nothing to load!).')
          end
        else
          debugLog('The category "' .. categoryKey .. '" is available, but is disabled. It has not been loaded.')
        end
      end
    end
  end
  
  return countAllJokes
end

-- loadTriviaCategories()
-- Helper; Load and register all trivia categories, returns total trivia count
local function loadTriviaCategories()
  local countAllTrivia = 0
  Joker.saved.randomPoolTrivia.enabledCategories = {}
  
  for categoryKey, categoryData in pairs(JokerData) do
    if categoryKey == 'Config' then
      -- Metadata entries, ignore
    else
      if Util.setContains(JokerData.Config, categoryKey) and JokerData.Config[categoryKey].label and JokerData.Config[categoryKey].command then
        if JokerData.Config[categoryKey].trivia and not JokerData.Config[categoryKey].disable then
          -- Load & count all the trivia for this category
          local categoryTriviaCount = Util.countSet(JokerData[categoryKey])
          countAllTrivia = countAllTrivia + categoryTriviaCount
          Joker.saved.count.triviaCategories[categoryKey] = categoryTriviaCount
          Joker.saved.activeTrivia = Joker.saved.activeTrivia or {}
          Joker.saved.activeTrivia[categoryKey] = JokerData.Config[categoryKey].label

          -- If there is trivia (> 0), enable:
          if categoryTriviaCount > 0 then

            -- Add trivia to list of enabled categories
            table.insert(Joker.saved.randomPoolTrivia.enabledCategories, categoryKey);

            -- Register slash commands for this category
            registerTriviaCommand(categoryKey, JokerData.Config[categoryKey])
          else
            d('Joker: The trivia category "' .. categoryKey .. '" was enabled but contains no trivia. It has not been loaded.')
          end
        end
      end
    end
  end
  
  return countAllTrivia
end

-- Runs each time `EVENT_ADD_ON_LOADED` fires
-- Specifically snake_case because it's a runtime function
local function runtime_onload()
  debugLog('Running runtime_onload()')

  runtime_updates()

  -- Load and register all joke categories
  local countAllJokes = loadJokeCategories()

  -- Load and register all trivia categories
  local countAllTrivia = loadTriviaCategories()

  -- Update savedVars
  Joker.saved.count.loaded = countAllJokes
  Joker.saved.count.triviaLoaded = countAllTrivia

  --[[
    Periodic Events
    > Jokes
    > Mental Health / Excercise Reminders
  ]]
  Data.runPeriodicEvents('joke', {
    joke = function() Joker.AnyJoke('', 1) end
  })


  --[[
    Additional Slash Commands
  ]]

  SLASH_COMMANDS["/joke"] = Joker.AnyJoke -- Add cmd: random joke
  SLASH_COMMANDS["/trivia"] = Joker.AnyTrivia -- Add cmd: random trivia
  SLASH_COMMANDS["/8ball"] = Data.eightBall -- Add cmd: 8ball
  SLASH_COMMANDS["/ready"] = Data.readyCheck -- Add cmd: ready checks
  SLASH_COMMANDS["/choose"] = Data.choose -- Add cmd: choose
  SLASH_COMMANDS["/roll"] = Data.roll -- Add cmd: roll

  -- Add cmd: attribution
  -- SLASH_COMMANDS["/joker-guild"] = function (context) 
  --   d(L.Joker_Guild_A .. Joker.attribution.guildNameLink .. L.Joker_Guild_B .. Joker.attribution.guildDiscord .. L.Joker_Guild_C)
  -- end
  SLASH_COMMANDS["/joker-author"] = function (context) 
    d(L.Joker_Author_A .. Joker.attribution.authorIGN .. L.Joker_Author_B .. Joker.attribution.authorDiscord .. ' :)')
  end

  -- Add cmd: debug & misc utilities
  SLASH_COMMANDS["/_joker-debug"] = function () Joker.ToggleDebug() end
  SLASH_COMMANDS["/rl"] = function() ReloadUI("ingame") end

end

-- Runs each time `EVENT_PLAYER_ACTIVATED` fires
local function runtime_onactivated()
  debugLog('Running runtime_onactivated()')

  debugLog('Debug mode enabled. Run /_joker-debug to toggle off.')
  debugLog('Version ' .. Joker.version .. ' is now active!') -- Log current version
end

--[[
  *****************************
  ** Addon Instantiation, Hook to Ingame Events
  *****************************
]]
-- `EVENT_ADD_ON_LOADED` fires when the game has finished loading (or attempting to load) all of an add-on's files. This event will fire once for EACH of the enabled addons, whicis why we unregister it after we've done our thing.
-- `EVENT_PLAYER_ACTIVATED` fires after the player has loaded (each time the player logs in or UI is reloaded). This runs after `EVENT_ADD_ON_LOADED`.


function Joker.Activated(e)
  debugLog('Running Joker.Activated()')

  EVENT_MANAGER:UnregisterForEvent(Joker.name, EVENT_PLAYER_ACTIVATED)

  if Joker.saved then
    debugLog('Joker.saved is available')
    if Joker.saved.internal.firstLoad > DISABLED then
      runtime_maiden()
    end

    -- Run through any necessary updates
    runtime_updates()

    -- Run any necessary functions that should run each EVENT_PLAYER_ACTIVATED event.
    runtime_onactivated()
  end
end

-- Attach to event: When player is ready, only after everything is loaded.
EVENT_MANAGER:RegisterForEvent(Joker.name, EVENT_PLAYER_ACTIVATED, Joker.Activated) 


function Joker.OnAddOnLoaded(event, addonName)
  debugLog('Running Joker.OnAddOnLoaded()')

  if addonName ~= Joker.name then return end
  EVENT_MANAGER:UnregisterForEvent(Joker.name, EVENT_ADD_ON_LOADED)

  -- Keybinds
  ZO_CreateStringId('SI_BINDING_NAME_JOKER_READYCHECK', L.Joker_Quick_Btn_JokeReady_Label)

  -- Load Saved Variables
  Joker.saved = ZO_SavedVars:NewAccountWide('JokerSavedVars', SAVED_VARS_VERSION, nil, Joker.defaults)

  -- Init our primary runtime (runs each load)
  runtime_onload()

  -- Settings menu in Settings.lua.
  Joker.LoadSettings()

end

EVENT_MANAGER:RegisterForEvent(Joker.name, EVENT_ADD_ON_LOADED, Joker.OnAddOnLoaded) -- Press Start.
