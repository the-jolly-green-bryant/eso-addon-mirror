-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  @g4rr3t[NA], @nogetrandom[EU], @kabs12[NA]
-- Created: May 5, 2018
--
-- Track cooldowns for various sets
--
-- Main.lua
-- -----------------------------------------------------------------------------
JHSetTrackers                  = {}
JHSetTrackers.name             = "JHSetTrackers"
JHSetTrackers.version          = "2.3"
JHSetTrackers.dbVersion        = 1
JHSetTrackers.slash            = "/cool"
JHSetTrackers.prefix           = "[Cooldowns] "
JHSetTrackers.inMenu           = false
JHSetTrackers.HUDHidden        = false
JHSetTrackers.inventoryHidden  = true
JHSetTrackers.HUDUIHidden      = false
JHSetTrackers.ForceShow        = false
JHSetTrackers.hideInMenu	      = false
JHSetTrackers.isInCombat       = false
JHSetTrackers.isDead           = false
JHSetTrackers.playerID         = 0
JHSetTrackers.hasJorvuld	      = false
JHSetTrackers.resTrackerOn     = false
JHSetTrackers.resourceSets     = {
  ["Pearls of Ehlnofey"] = {
    description = "Customize how the display behaves in regards to your resources",
  },
  ["Esoteric Environment Greaves"] = {
    description = "Customize how the display behaves in regards to your resources",
  }
}
JHSetTrackers.resSets          = {
	[1] = "Pearls of Ehlnofey",
  [2] = "Esoteric Environment Greaves"
}
JHSetTrackers.JorvuldIds       = {
		-- Sets
		[93120]  = true, -- Master Architecht
		[93442]  = true, -- War Machine
		[93125]  = true, -- Inventor's Guard
		[93444]  = true, -- Automated Defense
		[150974] = true, -- Drake's Rush
		[154830] = true, -- Saxhleel
		[107141] = true, -- Olorime
		[109084] = true, -- Olorime (perfected)
		[113509] = true, -- Steadfast Hero
		[121878] = true, -- Yolnahkriin
		-- Synergies
		[121059] = true, -- Major Berserk (Storm Atronarch synergy)
		-- Passives
		[61685]  = true, -- Minor Sorcery (templar passive)
		[62320]  = true, -- Minor Prophecy (sorc passive)
		-- [137986] = true,
		-- [135923] = true,
}

JHSetTrackers.spaulderTrack    = false

local EM = EVENT_MANAGER

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
JHSetTrackers.debugMode = 0
-- -----------------------------------------------------------------------------

function JHSetTrackers:Trace(debugLevel, ...)
  if debugLevel <= JHSetTrackers.debugMode then
    local message = zo_strformat(...)
    d(JHSetTrackers.prefix .. message)
  end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function JHSetTrackers.Initialize(event, addonName)
  if addonName ~= "TrackersByJH" then return end

  JHSetTrackers:Trace(1, "JHSetTrackers Loaded")
  EM:UnregisterForEvent(JHSetTrackers.name, EVENT_ADD_ON_LOADED)

  -- Populate default settings for sets
  JHSetTrackers.Defaults:Generate()

  -- Account-wide: Sets and synergy prefs
  JHSetTrackers.preferences            = ZO_SavedVars:NewAccountWide("JHSetTrackersVariables", JHSetTrackers.dbVersion, nil, JHSetTrackers.Defaults.Get())

  -- Per-Character: Synergy display status
  -- Other synergy preferences are still account-wide
  JHSetTrackers.character              = ZO_SavedVars:New("JHSetTrackersVariables", JHSetTrackers.dbVersion, nil, JHSetTrackers.Defaults.GetCharacter())
  JHSetTrackers.Settings.Upgrade()

  -- Use saved debugMode value
  JHSetTrackers.debugMode              = JHSetTrackers.preferences.debugMode

  SLASH_COMMANDS[JHSetTrackers.slash]  = JHSetTrackers.UI.SlashCommand

  -- Update initial combat/dead state
  -- In the event that UI is loaded mid-combat or while dead
  JHSetTrackers.isInCombat             = IsUnitInCombat("player")
  JHSetTrackers.isDead                 = IsUnitDead("player")
  JHSetTrackers.UI.ToggleHUD()

  -- Settings are integrated into the main Trackers by JH LAM panel.
  -- JHSetTrackers.Settings.Init()
  JHSetTrackers.Tracking.RegisterEvents()
  JHSetTrackers.Tracking.EnableSynergiesFromPrefs()
  JHSetTrackers.Tracking.EnablePassivesFromPrefs()
  JHSetTrackers.Tracking.EnableCPFromPrefs()

  -- Configure and register LibEquipmentBonus
  local LEB                   = LibEquipmentBonus
  local Equip                 = LEB:Init(JHSetTrackers.name)
  Equip:Register(JHSetTrackers.Tracking.EnableTrackingForSet, JHSetTrackers.Tracking.EnableTrackingForCP)

  JHSetTrackers:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EM:RegisterForEvent(JHSetTrackers.name, EVENT_ADD_ON_LOADED, JHSetTrackers.Initialize)
