-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.data = PITHKA.data or {}
PITHKA.data.savedVars = PITHKA.data.savedVars or {}

-- convenient namespacing
local utils = PITHKA.common.utils
local savedVars = PITHKA.data.savedVars

-- Debug printing
local debug_enabled = false  -- Set to false to disable debug output
local function debug(msg)
    if debug_enabled then
        d("|cFF00FF[SAVEDVARS]|r " .. tostring(msg))
    end
end

-----------------------------------------------------------------------
-- Saved Variables
-----------------------------------------------------------------------

-- initialize saved vars from file or set defaults
function savedVars.initalize()
    debug("Initializing saved variables")
    -- Initialize saved variables
    PITHKA.data.savedVars.db = ZO_SavedVars:NewAccountWide("PithkaSavedVariables", 1, nil, {
        -- options        = {
        --   enableTeleport = true,
        -- },
        -- state          = {
        --               showExtra = true,
        --               showWatermark = true,
        --               showQR = false,
        --               currentScreen = 'dungeon',
        --               title = '',
        --               },
        scores         = {},
        -- runOnce        = {},
        
        -- Group Finder usage tracking for QR analytics
        groupFinderUsage = {
            joiningAttempts = 0  -- Track how many times user enters JOINING state
        },
  
        -- -- Add toggle buttons state
        -- toggleButtonStates = {
        --     groupFinderHealer = true,
        --     groupFinderTank = true,
        --     groupFinderDps = true,
        --     groupFinderDungeons = true,
        --     groupFinderTrials = true,
        --     groupFinderNormal = true,
        --     groupFinderVeteran = true,  
        --     runGroupFinder = true,
        -- },

        -- values that should fire callbacks when they are set
        valuesWithCallbacks = {
            showWatermark = false,
            showGroupFinder = false,
            currentScreen = '4 Man Trifectas',
            currentTray = 'Export',

            -- group finder search toggles
            groupFinderHealer = true,
            groupFinderTank = true,
            groupFinderDps = true,
            groupFinderDungeons = true,
            groupFinderTrials = true,
            groupFinderNormal = true,
            groupFinderVeteran = true,  
            runGroupFinder = true,
        }
      })
end

-----------------------------------------------------------------------
-- Callback System
-----------------------------------------------------------------------

savedVars.callbacks = {}

-- Register a callback (all callbacks get called on any set)
function savedVars.registerCallback(fn)
    debug("Registering savedVars callback: " .. tostring(fn))
    table.insert(savedVars.callbacks, fn)
end

-- Set a variable and fire all callbacks
function savedVars.doCallbacks(var, value)
    debug("Firing savedVars callbacks for var: " .. tostring(var) .. ", value: " .. tostring(value))
    for _, fn in ipairs(savedVars.callbacks) do
        debug("Calling callback: " .. tostring(fn))
        fn(var, value)
    end
end

-- explicity used for the valuesWithCallbacks variables
function savedVars.get(var)
    return PITHKA.data.savedVars.db.valuesWithCallbacks[var]
end

-- explicity used for the valuesWithCallbacks variables
function savedVars.set(var, value)
    debug('>> set ' .. var .. ' to ' .. tostring(value))
    PITHKA.data.savedVars.db.valuesWithCallbacks[var] = value
    savedVars.doCallbacks(var, value)
end


-----------------------------------------------------------------------
-- Button Linking Using Callbacks
-----------------------------------------------------------------------

-- only allow one to be turned on at a time, since QR and GF share the same UI
local function linkWatermarkToGroupFinder(var, value)
  -- if group finder is turned on, turn off watermark
  if var == 'showGroupFinder' and value then
    savedVars.set('showWatermark', false)

  -- if watermark is turned on, turn off group finder
  elseif var == 'showWatermark' and value then
    savedVars.set('showGroupFinder', false)
  end

  -- note, allow them both to be turned off
end

-- register the callback
savedVars.registerCallback(linkWatermarkToGroupFinder)  
