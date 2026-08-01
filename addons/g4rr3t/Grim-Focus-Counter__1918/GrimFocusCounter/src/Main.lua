-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Dec 20, 2017
--
-- Track stacks of Grim Focus and its morphs and display
-- the stacks in a very visual and obvious way.
--
-- Main.lua
-- -----------------------------------------------------------------------------

--- @type table Global addon table
GFC            = {}
--- @type string Addon name
GFC.name       = "GrimFocusCounter"
--- @type string Addon version, human readable
GFC.version    = "1.6.0"
--- @type integer Saved variables database version
GFC.dbVersion  = 1
--- @type string Slash command string
GFC.slash      = "/gfc"
--- @type string Chat output prefix
GFC.prefix     = "[GFC] "
--- @type boolean True when the HUD is hidden
GFC.HUDHidden  = false
--- @type boolean True when UI is requested to be always shown
GFC.ForceShow  = false

-- Local assignment of globals
local EM       = EVENT_MANAGER
local SC       = SLASH_COMMANDS

--- @enum debugModes table
GFC.debugModes = {
    off    = 0, -- Disable debug messages
    low    = 1, -- Basic debug info, show core functionality
    medium = 2, -- More information about skills and addon details
    high   = 3, -- Everything
}

--- @type debugModes
GFC.debugMode  = GFC.debugModes.off

--- Output a debug message
--- @param debugLevel debugModes Debug level to output
--- @param ... any Message to output, formatted via zo_strformat()
--- @return nil
function GFC:Trace(debugLevel, ...)
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
function GFC:Initialize(_, addonName)
    if GetUnitClassId("player") ~= 3 then
        self:Trace(1, "Non-nightblade class detected, aborting addon initialization.")
        EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
        return
    end

    if addonName ~= self.name then return end

    self:Trace(1, "GFC Loaded")
    EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    -- First two traces use above debugMode value until preferences are loaded.
    -- The only way these messages will appear is by changing the above
    -- value to greater than 0.
    --
    -- Since these are only used during dev and QA, it should not impact
    -- any user functionality or features.

    self.preferences = ZO_SavedVars:NewAccountWide("GrimFocusCounterVariables", self.dbVersion, nil, self:GetDefaults())
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

--- Wrapper for GFC initalize function
--- @param eventId integer Addon loaded event ID
--- @param addonName string Name of the addon that loaded
--- @return nil
local function init(eventId, addonName)
    GFC:Initialize(eventId, addonName)
end

EM:RegisterForEvent(GFC.name .. "_Init", EVENT_ADD_ON_LOADED, init)
