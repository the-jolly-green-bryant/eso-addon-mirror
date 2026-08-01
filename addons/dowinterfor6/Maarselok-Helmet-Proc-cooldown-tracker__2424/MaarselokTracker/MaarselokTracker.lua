-- Create namespace with top level table
MaarselokTracker = {}

-- Namespace varaiables
MaarselokTracker.NAME = "MaarselokTracker"
MaarselokTracker.PROC_COOLDOWN = 7000 -- ms
MaarselokTracker.timeOfProc = 0
MaarselokTracker.UPDATE_INTERVAL = 100 -- ms
MaarselokTracker.MAARSELOK_ID = 126941
MaarselokTracker.onCooldown = false

-- Restore saved position from savedVariables
function MaarselokTracker:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top

  MaarselokTrackerIndicator:ClearAnchors()
  MaarselokTrackerIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-- Initialize addon
function MaarselokTracker:Initialize()
  -- Equivalent to MaarselokTracker.inCombat when using : to assign self
  self.inCombat = IsUnitInCombat("player");

  -- Register combat change event
  EVENT_MANAGER:RegisterForEvent(
    MaarselokTracker.NAME, 
    EVENT_PLAYER_COMBAT_STATE, 
    self.OnPlayerCombatState
  )

  EVENT_MANAGER:RegisterForEvent(MaarselokTracker.NAME, EVENT_COMBAT_EVENT, MaarselokTracker.OnCombatEvent)
  EVENT_MANAGER:AddFilterForEvent(
    MaarselokTracker.NAME, 
    EVENT_COMBAT_EVENT, 
    REGISTER_FILTER_ABILITY_ID, 
    MaarselokTracker.MAARSELOK_ID
  )
  EVENT_MANAGER:AddFilterForEvent(
    MaarselokTracker.NAME,
    EVENT_COMBAT_EVENT,
    REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
    COMBAT_UNIT_TYPE_PLAYER
  )

  -- Initialize saved variables
  self.savedVariables = ZO_SavedVars:NewAccountWide(
    "MaarselokTrackerSavedVariables", 
    1, 
    nil, 
    {}
  )

  self:RestorePosition()
end

-- Event handler callback function, initialize addon after
-- resources are loaded
function MaarselokTracker.OnAddOnLoaded(event, addonName)
  -- EVENT_ADD_ON_LOADED fires for each addon, check for own
  if addonName ~= MaarselokTracker.NAME then return end

  -- Unregister addon load listener
  EVENT_MANAGER:UnregisterForEvent(MaarselokTracker.NAME, EVENT_ADD_ON_LOADED)
  MaarselokTracker:Initialize()
end

-- Callback for player state change
function MaarselokTracker.OnPlayerCombatState(event, inCombat)
  if inCombat ~= MaarselokTracker.inCombat then
    -- Combat state has changed, change store
    MaarselokTracker.inCombat = inCombat

    if inCombat == false then
      MaarselokTrackerIndicator:SetHidden(not inCombat)
    end
  end
end

-- Callback to handle movement stop
function MaarselokTracker.OnIndicatorMoveStop()
  MaarselokTracker.savedVariables.left = MaarselokTrackerIndicator:GetLeft()
  MaarselokTracker.savedVariables.top = MaarselokTrackerIndicator:GetTop()
end

-- Callback for starting cooldown
function MaarselokTracker.OnCombatEvent(setKey, _, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, abilityId)
  MaarselokTrackerIndicator:SetHidden(false)

  if MaarselokTracker.onCooldown == true then return end

  MaarselokTracker.timeOfProc = GetGameTimeMilliseconds()
  MaarselokTracker.onCooldown = true
  MaarselokTrackerIndicatorTimer:SetColor(1,0,0)
  MaarselokTrackerIndicatorNotification:SetHidden(true)

  EVENT_MANAGER:RegisterForUpdate(
    MaarselokTracker.NAME,
    MaarselokTracker.UPDATE_INTERVAL,
    MaarselokTracker.countDown
  )
end

-- Count down the timer
function MaarselokTracker.countDown()
  countdown = (MaarselokTracker.timeOfProc + MaarselokTracker.PROC_COOLDOWN - GetGameTimeMilliseconds()) / 1000
  MaarselokTrackerIndicatorTimer:SetText(string.format("%.1f", countdown))
  
  if countdown <= 0 then
    EVENT_MANAGER:UnregisterForUpdate(
      MaarselokTracker.NAME
    )
    MaarselokTracker.onCooldown = false
    MaarselokTrackerIndicatorTimer:SetColor(0,1,0)
    MaarselokTrackerIndicatorTimer:SetText(
      string.format("%.1f", "0.0")
    )
    MaarselokTrackerIndicatorNotification:SetHidden(false)
  end
end

-- Register event listener with namespace, event, and callback
EVENT_MANAGER:RegisterForEvent(
  MaarselokTracker.NAME, 
  EVENT_ADD_ON_LOADED, 
  MaarselokTracker.OnAddOnLoaded
)