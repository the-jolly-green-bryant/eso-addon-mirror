-- -----------------------------------------------------------------------------
-- Bound Armaments Counter
-- Author:  g4rr3t
-- Created: Dec 20, 2017
-- Fixed by Faint_One Aug 15 2026
-- Track stacks of Bound Armaments to display
-- the stacks in a very visual and obvious way.
--
-- Main.lua
-- -----------------------------------------------------------------------------

--- @type table Global addon table
BAC            = {}
--- @type string Addon name
BAC.name       = "BoundArmamentsCounter"
--- @type string Addon version, human readable
BAC.version    = "1.2.3"
--- @type integer Saved variables database version
BAC.dbVersion  = 1
--- @type string Slash command string
BAC.slash      = "/BAC"
--- @type string Chat output prefix
BAC.prefix     = "[BAC] "
--- @type boolean True when the HUD is hidden
BAC.HUDHidden  = false
--- @type boolean True when UI is requested to be always shown
BAC.ForceShow  = false

-- Local assignment of globals
local EM       = EVENT_MANAGER
local SC       = SLASH_COMMANDS

--- @enum debugModes table
BAC.debugModes = {
    off    = 0, -- Disable debug messages
    low    = 1, -- Basic debug info, show core functionality
    medium = 2, -- More information about skills and addon details
    high   = 3, -- Everything
}

--- @type debugModes
BAC.debugMode  = BAC.debugModes.off

--- Output a debug message
--- @param debugLevel debugModes Debug level to output
--- @param ... any Message to output, formatted via zo_strformat()
--- @return nil
function BAC:Trace(debugLevel, ...)
    if debugLevel <= self.debugMode then
        d(self.prefix .. zo_strformat(...))
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

--- Initialize the addon
--- @param _ integer Addon loaded event ID
--- @param addonName string Name of the addon that loaded
--- @return nil
function BAC:Initialize(_, addonName)
--[[     if GetUnitClassId("player") ~= 2 then
        self:Trace(1, "Non-sorcerer class detected, aborting addon initialization.")
        EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
        return
    end ]]

    if addonName ~= self.name then return end

    self:Trace(1, "BAC Loaded")
    EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    -- First two traces use above debugMode value until preferences are loaded.
    -- The only way these messages will appear is by changing the above
    -- value to greater than 0.
    --
    -- Since these are only used during dev and QA, it should not impact
    -- any user functionality or features.

    self.preferences = ZO_SavedVars:NewAccountWide("BoundArmamentsCounterVariables", self.dbVersion, nil, self:GetDefaults())
    self:UpgradeSettings()

    -- Use saved debugMode value if the above value has not been changed
    if self.debugMode == 0 then
        self.debugMode = self.preferences.debugMode
        self:Trace(1, "Setting debug value to saved: " .. self.preferences.debugMode)
    end

    SC[self.slash] = function(...) self:SlashCommand(...) end;

    self:InitSettings()
    self:DrawUI()
    self:RegisterHotbarEvents()
    self:OnPlayerChanged()

    self:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

--- Wrapper for BAC initalize function
--- @param eventId integer Addon loaded event ID
--- @param addonName string Name of the addon that loaded
--- @return nil
local function init(eventId, addonName)
    BAC:Initialize(eventId, addonName)
end

EM:RegisterForEvent(BAC.name .. "_Init", EVENT_ADD_ON_LOADED, init)
