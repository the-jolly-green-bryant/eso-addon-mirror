-- Namespace
CombatStatus = {}
 
-- Addon Name
CombatStatus.name = "CombatStatus-Console"

-- Initialization
function CombatStatus.Initialize()
    d("Initializing CombatStatus Addon")

    -- Initialize combat status
    CombatStatus.inCombat = IsUnitInCombat("player")

    -- Subscribe to combat state change event
    EVENT_MANAGER:RegisterForEvent(CombatStatus.name, EVENT_PLAYER_COMBAT_STATE, CombatStatus.OnPlayerCombatState)
end
 
-- Event Handler: OnLoaded
function CombatStatus.OnAddOnLoaded(event, addonName)
    d("CombatStatus Addon Loading...")

    -- Check if the loaded addon is this one
    if addonName == CombatStatus.name then
        CombatStatus.Initialize()

        -- Unregister from event as it is no longer needed
        EVENT_MANAGER:UnregisterForEvent(CombatStatus.name, EVENT_ADD_ON_LOADED)
    end
end

-- Event Handler: OnCombatStateChanged
function CombatStatus.OnPlayerCombatState(event, inCombat)
  if inCombat ~= CombatStatus.inCombat then
    -- The player's state has changed. Update the stored state.
    CombatStatus.inCombat = inCombat

    -- Announce the change.
    if inCombat then
      d("Entering combat.")
    else
      d("Exiting combat.")
    end

    -- Update the UI control
    CombatStatusAddonIndicator:SetHidden(not inCombat) 
  end
end

-- Subscribe to OnLoaded event
EVENT_MANAGER:RegisterForEvent(CombatStatus.name, EVENT_ADD_ON_LOADED, CombatStatus.OnAddOnLoaded, true)
