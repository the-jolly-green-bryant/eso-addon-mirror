-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Track cooldowns for various sets
--
-- Main.lua
-- -----------------------------------------------------------------------------
PvPCooldownTracker            = {}
PvPCooldownTracker.name       = "PvPCooldownTracker"
PvPCooldownTracker.version    = "1.1.1"
PvPCooldownTracker.dbVersion  = 1
PvPCooldownTracker.slash      = "/PvPCooldownTracker"
PvPCooldownTracker.prefix     = "[PvPCooldownTracker] "
PvPCooldownTracker.HUDHidden  = false
PvPCooldownTracker.ForceShow  = false
PvPCooldownTracker.isInCombat = false
PvPCooldownTracker.isDead     = false

local EM = EVENT_MANAGER

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
PvPCooldownTracker.debugMode = 0
-- -----------------------------------------------------------------------------

function PvPCooldownTracker:Trace(debugLevel, ...)
    if debugLevel <= PvPCooldownTracker.debugMode then
        local message = zo_strformat(...)
        d(PvPCooldownTracker.prefix .. message)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function PvPCooldownTracker.Initialize(event, addonName)
    if addonName ~= PvPCooldownTracker.name then return end

    PvPCooldownTracker:Trace(1, "PvPCooldownTracker Loaded")
    EM:UnregisterForEvent(PvPCooldownTracker.name, EVENT_ADD_ON_LOADED)

    -- Populate default settings for sets
    PvPCooldownTracker.Defaults:Generate()

    -- Account-wide: Sets and synergy prefs
    PvPCooldownTracker.preferences = ZO_SavedVars:New("CooldownsVariables1", PvPCooldownTracker.dbVersion, nil, PvPCooldownTracker.Defaults.Get())

    -- Per-Character: Synergy display status
    -- Other synergy preferences are still account-wide
    PvPCooldownTracker.character = ZO_SavedVars:New("CooldownsVariables2", PvPCooldownTracker.dbVersion, nil, PvPCooldownTracker.Defaults.GetCharacter())
    PvPCooldownTracker.Settings.Upgrade()

    -- Use saved debugMode value
    PvPCooldownTracker.debugMode = PvPCooldownTracker.preferences.debugMode

    SLASH_COMMANDS[PvPCooldownTracker.slash] = PvPCooldownTracker.UI.SlashCommand

    -- Update initial combat/dead state
    -- In the event that UI is loaded mid-combat or while dead
    PvPCooldownTracker.isInCombat = IsUnitInCombat("player")
    PvPCooldownTracker.isDead = IsUnitDead("player")

    PvPCooldownTracker.Settings.Init()
    PvPCooldownTracker.Tracking.RegisterEvents()
    -- EM:RegisterForEvent(PvPCooldownTracker.name .. "_" .. "1234", EVENT_COMBAT_EVENT, function (...) PvPCooldownTracker:Debug(...) end)
    EM:AddFilterForEvent(PvPCooldownTracker.name .. "_1234", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    -- Configure and register LibEquipmentBonus
    local LEB = LibEquipmentBonus
    local Equip = LEB:Init(PvPCooldownTracker.name)
    Equip:Register(PvPCooldownTracker.Tracking.EnableTrackingForSet)

    PvPCooldownTracker.UI.ToggleHUD()

    PvPCooldownTracker:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EM:RegisterForEvent(PvPCooldownTracker.name, EVENT_ADD_ON_LOADED, PvPCooldownTracker.Initialize)

