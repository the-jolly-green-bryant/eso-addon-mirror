-- * _ANDY_VERSION: 1.0.0 ** Please do not modify this line.
--[[----------------------------------------------------------
	AddonAnalyzer (Andy)
  ----------------------------------------------------------
  *
	* Authors:
	* - Lent (IGN @CallMeLent, Github @adefee)
  *
  * Contents:
  * - Addon Instantiation
  *
]]--

Andy = Andy or {}
local AndyUtil = AndyUtil or {} -- utility functions used throughout
local ANDY_SAVED_VARS_VERSION = 1

-- debugLog()
-- Helper; Outputs debug message to console if debug mode is enabled
function Andy.debugLog(message)
  if Andy and Andy.saved and Andy.saved.internal and Andy.saved.internal.showDebug and Andy.saved.internal.showDebug > 0 then
    d('Andy: ' .. message)
  end
end

-- ToggleDebug()
function Andy.ToggleDebug()
  if not Andy.saved or not Andy.saved.internal then
    d('Andy: Error - saved variables not initialized yet.')
    return
  end
  
  if Andy.saved.internal.showDebug > 0 then
    d('Disabling Andy debug mode.')
    Andy.saved.internal.showDebug = 0
  else
    d('Enabling Andy debug mode.')
    Andy.saved.internal.showDebug = 1
  end
end

-- ScanCommand()
-- Slash command handler for /andy scan
function Andy.ScanCommand()
  Andy.quickScanAllAddons(true) -- Pass true to indicate manual/on-demand scan
end

-- SuppressCommand()
-- Slash command handler for /andy suppress
function Andy.SuppressCommand()
  if not Andy.saved or not Andy.saved.ignore then
    d('Andy: Error - saved variables not initialized yet.')
    return
  end
  
  -- Run a scan to get current flagged addons
  local flaggedAddons = Andy.quickScanAllAddons()
  
  if #flaggedAddons == 0 then
    d('|cFF8800[Andy]|r No flagged addons found. Nothing to suppress.')
    return
  end
  
  -- Store the flagged addons and current version
  Andy.saved.ignore.enabled = true
  Andy.saved.ignore.versionWhenIgnored = Andy.versionESO
  Andy.saved.ignore.flaggedAddons = {}
  
  for _, result in ipairs(flaggedAddons) do
    table.insert(Andy.saved.ignore.flaggedAddons, result.addonName)
  end
  
  d('|cFF8800[Andy]|r Suppressing warnings for ' .. #flaggedAddons .. ' flagged addon(s). Warnings will be suppressed until a new flagged addon is detected or AddonAnalyzer is updated.')
  Andy.debugLog('Suppressed addons: ' .. table.concat(Andy.saved.ignore.flaggedAddons, ', '))
end

-- MonitorCommand()
-- Slash command handler for /andy monitor
function Andy.MonitorCommand()
  if not Andy.saved or not Andy.saved.ignore then
    d('Andy: Error - saved variables not initialized yet.')
    return
  end
  
  if not Andy.saved.ignore.enabled then
    d('|cFF8800[Andy]|r Monitoring is already enabled.')
    return
  end
  
  -- Clear suppress state
  Andy.saved.ignore.enabled = false
  Andy.saved.ignore.versionWhenIgnored = nil
  Andy.saved.ignore.flaggedAddons = {}
  
  d('|cFF8800[Andy]|r Monitoring re-enabled. You will now receive all warnings.')
  
  -- Run a scan to show current state
  Andy.quickScanAllAddons()
end

-- SoundCommand()
-- Slash command handler for /andy sound
function Andy.SoundCommand()
  if not Andy.saved or not Andy.saved.enable then
    d('Andy: Error - saved variables not initialized yet.')
    return
  end
  
  if Andy.saved.enable.playSound > 0 then
    d('|cFF8800[Andy]|r Warning sound disabled.')
    Andy.saved.enable.playSound = 0
  else
    d('|cFF8800[Andy]|r Warning sound enabled. Playing sample...')
    Andy.saved.enable.playSound = 1
    AndyUtil.PlayAlertSound()
  end
end

-- AnnounceCommand()
-- Slash command handler for /andy announce
function Andy.AnnounceCommand()
  if not Andy.saved or not Andy.saved.enable then
    d('Andy: Error - saved variables not initialized yet.')
    return
  end
  
  if Andy.saved.enable.showBanner > 0 then
    d('|cFF8800[Andy]|r Center screen banner disabled.')
    Andy.saved.enable.showBanner = 0
  else
    d('|cFF8800[Andy]|r Center screen banner enabled.')
    Andy.saved.enable.showBanner = 1
  end
end

-- QuietCommand()
-- Slash command handler for /andy quiet
function Andy.QuietCommand()
  if not Andy.saved or not Andy.saved.enable then
    d('Andy: Error - saved variables not initialized yet.')
    return
  end
  
  if Andy.saved.enable.quietMode > 0 then
    d('|cFF8800[Andy]|r Quiet mode disabled. You will see messages even when no flagged addons are found.')
    Andy.saved.enable.quietMode = 0
  else
    d('|cFF8800[Andy]|r Quiet mode enabled. Messages will only appear when flagged addons are detected.')
    Andy.saved.enable.quietMode = 1
  end
end

-- Runs only the first time load
-- Specifically snake_case because it's a runtime function
function Andy.FirstRun()
  Andy.debugLog('Running Andy.FirstRun()')
  d('Andy (Addon Analyzer) ' .. Andy.version .. ' is now active! Type /andy at any time to view available options.')
  Andy.saved.internal.firstLoad = 0
end


-- Intended to run each time `EVENT_ADD_ON_LOADED` fires
function Andy.RuntimeOnLoad()
  Andy.debugLog('Running RuntimeOnLoad()')

  --[[
    Periodic Events
    > Auto scans
  ]]
  AndyUtil.runPeriodicEvents('scan', {
    scan = function() Andy.quickScanAllAddons() end
  })

  --[[
    Add our Slash commands
  ]]
  SLASH_COMMANDS["/andy"] = function(args)
    local command = string.lower(args or "")
    if command == "scan" then
      Andy.ScanCommand()
    elseif command == "debug" then
      Andy.ToggleDebug()
    elseif command == "suppress" then
      Andy.SuppressCommand()
    elseif command == "monitor" then
      Andy.MonitorCommand()
    elseif command == "sound" then
      Andy.SoundCommand()
    elseif command == "announce" then
      Andy.AnnounceCommand()
    elseif command == "quiet" then
      Andy.QuietCommand()
    else
      d('|cFF8800[Andy]|r Available commands:')
      d('  |cFFFFFF/andy scan|r - Manually scan for flagged addons')
      d('  |cFFFFFF/andy suppress|r - Suppress current warnings until new flagged addon is found, or Andy is updated')
      d('  |cFFFFFF/andy monitor|r - Re-enable warnings (undo suppress)')
      d('  |cFFFFFF/andy sound|r - Toggle warning sound on/off')
      d('  |cFFFFFF/andy announce|r - Toggle center screen banner on/off')
      d('  |cFFFFFF/andy quiet|r - Toggle quiet mode (only show messages when flagged addons are found)')
      d('  |cFFFFFF/andy debug|r - Enable debug mode (additional logging)')
    end
  end
end

-- Intended to run each time `EVENT_PLAYER_ACTIVATED` fires
function Andy.RuntimeOnActivated()
  Andy.debugLog('Running AndyRuntimeOnActivated()')

  Andy.debugLog('Debug mode enabled. Run /_andy-debug to toggle off.')
  Andy.debugLog('Version ' .. Andy.version .. ' is now active!') -- Log current version

  if IsConsoleUI() then
    Andy.debugLog('Console UI detected.')
  else
    Andy.debugLog('PC UI detected.')
  end
end

--[[
  *****************************
  ** Addon Instantiation, Hook to Ingame Events
  *****************************

  - `EVENT_ADD_ON_LOADED` fires when the game has finished loading (or attempting to load) all of an add-on's files. This event will fire once for EACH of the enabled addons, which is why we unregister it after we've done our thing.
  - `EVENT_PLAYER_ACTIVATED` fires after the player has loaded (each time the player logs in or UI is reloaded). This runs after `EVENT_ADD_ON_LOADED`.
]]

function Andy.Activated(e)
  Andy.debugLog('Running Andy.Activated()')

  EVENT_MANAGER:UnregisterForEvent(Andy.name, EVENT_PLAYER_ACTIVATED)

  if Andy.saved then
    Andy.debugLog('Andy.saved is available')
    if Andy.saved.internal and Andy.saved.internal.firstLoad > 0 then
      Andy.FirstRun()
    end

    -- Run any necessary functions that should run each EVENT_PLAYER_ACTIVATED event.
    Andy.RuntimeOnActivated()
  end
end

-- Attach to event: When player is ready, only after everything is loaded.
EVENT_MANAGER:RegisterForEvent(Andy.name, EVENT_PLAYER_ACTIVATED, Andy.Activated) 


function Andy.OnAddonLoaded(event, addonName)
  Andy.debugLog('Running Andy.OnAddonLoaded()')
  if addonName ~= Andy.name then return end

  EVENT_MANAGER:UnregisterForEvent(Andy.name, EVENT_ADD_ON_LOADED)

  -- Load Saved Variables
  Andy.saved = ZO_SavedVars:NewAccountWide('AndySavedVars', ANDY_SAVED_VARS_VERSION, nil, Andy.defaults)

  -- Init primary runtime (each load)
  Andy.RuntimeOnLoad()
end

EVENT_MANAGER:RegisterForEvent(Andy.name, EVENT_ADD_ON_LOADED, Andy.OnAddonLoaded) -- Press Start.
