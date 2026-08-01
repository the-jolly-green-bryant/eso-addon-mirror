-- -----------------------------------------------------------------------------
-- Bound Armaments Counter
-- Author:  g4rr3t/Masel92
-- Created: Sep 27, 2019
--
-- Track stacks of Bound Armaments and display
-- the stacks in a very visual and obvious way. 
-- Coded for Grim Focus and its morphs by g4rr3t,
-- adapted for Bound Armaments by Masel92
-- updated for Ascending Tide by DerMatse
-- Main.lua
-- -----------------------------------------------------------------------------
BAC             = {}
BAC.name        = "BoundArmamentsCounter"
BAC.version     = "1.0.10"
BAC.dbVersion   = 1
BAC.slash       = "/bac"
BAC.prefix      = "[BAC] "
BAC.HUDHidden   = false
BAC.ForceShow   = false
BAC.isInCombat  = false

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
BAC.debugMode = 0
-- -----------------------------------------------------------------------------

function BAC:Trace(debugLevel, ...)
    if debugLevel <= BAC.debugMode then
        d(BAC.prefix .. ...)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function BAC.Initialize(event, addonName)
    if addonName ~= BAC.name then return end

    -- First trace uses above debugMode value until preferences are loaded.
    -- The only way these two messages will appear is by changing the above
    -- value to greater than 0.
    -- Since these are only used during dev and QA, it should not impact
    -- any user functionality or features.
    if GetUnitClassId("player") ~= 2 then
        BAC:Trace(1, "Non-sorcerer class detected, aborting addon initialization.")
        EVENT_MANAGER:UnregisterForEvent(BAC.name, EVENT_ADD_ON_LOADED)
        return
    end

    BAC:Trace(1, "BAC Loaded")
    EVENT_MANAGER:UnregisterForEvent(BAC.name, EVENT_ADD_ON_LOADED)

    BAC.preferences = ZO_SavedVars:NewAccountWide("BoundArmamentsCounterVariables", BAC.dbVersion, nil, BAC:GetDefaults())
    BAC:UpgradeSettings()

    -- Use saved debugMode value if the above value has not been changed
    if BAC.debugMode == 0 then
        BAC.debugMode = BAC.preferences.debugMode
        BAC:Trace(1, "Setting debug value to saved: " .. BAC.preferences.debugMode)
    end

    SLASH_COMMANDS[BAC.slash] = BAC.SlashCommand

    BAC:InitSettings()
    BAC.DrawUI()
    BAC.ToggleHUD()
    BAC.RegisterEvents()

    BAC:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(BAC.name, EVENT_ADD_ON_LOADED, function(...) BAC.Initialize(...) end)

