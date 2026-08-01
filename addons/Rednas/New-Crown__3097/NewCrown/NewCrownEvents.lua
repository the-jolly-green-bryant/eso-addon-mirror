NewCrown = NewCrown or {}

function NewCrown.OnPlayerActivated()
	NewCrown.SetLocation()
	
	NewCrown.UpdateCrown()
end

function NewCrown.OnLeaderUpdate()
	NewCrown.CheckNewLeader()
end

function NewCrown.OnGroupSizeChanged()
	NewCrown.OldGroupSize = NewCrown.GroupSize
	NewCrown.SetNewGroupSize()
	
	if NewCrown.OldGroupSize == 0 and NewCrown.GroupSize > 0 then
		NewCrown.DebugMessage("Group created")
		NewCrown.CheckNewLeader()
	elseif NewCrown.OldGroupSize > 0 and NewCrown.GroupSize == 0 then
		NewCrown.CheckNewLeader()
		NewCrown.DebugMessage("Group disbanded")
	end

end

function NewCrown.OnPlayerCombatState(e, InCombat)
	NewCrown.InCombat = InCombat

	if NewCrown.SavedVars.WhenToActivate == NewCrown.WhenToActivateChoices[2] 
	or NewCrown.SavedVars.WhenToActivate == NewCrown.WhenToActivateChoices[3] then
		NewCrown.UpdateCrown()
	end
end

function NewCrown.OnTrialStarted()
	local OldLocation = NewCrown.Location
	NewCrown.SetLocation()
		
	if OldLocation ~= NewCrown.Location then
		NewCrown.UpdateCrown()
	end
end

--It's only needed to register the event EVENT_PLAYER_COMBAT_STATE when the crown is dependend on the current combat state.
--Check if we need to (un)register the EVENT based on the settings.
function NewCrown.RegisterUnregisterPlayerCombatState()
	
	if NewCrown.CombatStateRegisterd == true then 
		if NewCrown.SavedVars.WhenToActivate == NewCrown.WhenToActivateChoices[1] or
		   NewCrown.SavedVars.WhenToActivate == NewCrown.WhenToActivateChoices[4] then
			EVENT_MANAGER:UnregisterForEvent(NewCrown.Name, EVENT_PLAYER_COMBAT_STATE)
			NewCrown.InCombat = IsUnitInCombat("player")
			NewCrown.CombatStateRegisterd = false
			NewCrown.DebugMessage("Event Player Combat state unregisterd")
		end
	elseif NewCrown.CombatStateRegisterd == false then
		if NewCrown.SavedVars.WhenToActivate == NewCrown.WhenToActivateChoices[2] or
		   NewCrown.SavedVars.WhenToActivate == NewCrown.WhenToActivateChoices[3] then
			EVENT_MANAGER:RegisterForEvent(NewCrown.Name, EVENT_PLAYER_COMBAT_STATE, NewCrown.OnPlayerCombatState)
			NewCrown.InCombat = IsUnitInCombat("player")
			NewCrown.CombatStateRegisterd = true
			NewCrown.DebugMessage("Event Player Combat state registerd")
		end
	end
	
end


-- It's only needed to register for the EVENTS: EVENT_GROUP_MEMBER_JOINED, EVENT_GROUP_MEMBER_LEFT, EVENT_LEADER_UPDATE if the special feature is enabled.
-- Check if we need to (un)register the EVENT based on the settings.
function NewCrown.RegisterUnregisterGroupEvents()

	if NewCrown.GroupEventsRegisterd == true then
		if NewCrown.SavedVars.SpecialFeatureEnabled == false then
			EVENT_MANAGER:UnregisterForEvent(NewCrown.Name, EVENT_GROUP_MEMBER_JOINED)
			EVENT_MANAGER:UnregisterForEvent(NewCrown.Name, EVENT_GROUP_MEMBER_LEFT)
			EVENT_MANAGER:UnregisterForEvent(NewCrown.Name, EVENT_LEADER_UPDATE)
			NewCrown.SavedVars.SpecialFeatureEnabled = false
		end	
	elseif NewCrown.GroupEventsRegisterd == false then
		if NewCrown.SavedVars.SpecialFeatureEnabled == true then
			EVENT_MANAGER:RegisterForEvent(NewCrown.Name, EVENT_GROUP_MEMBER_JOINED, NewCrown.OnGroupSizeChanged)
			EVENT_MANAGER:RegisterForEvent(NewCrown.Name, EVENT_GROUP_MEMBER_LEFT, NewCrown.OnGroupSizeChanged)
			EVENT_MANAGER:RegisterForEvent(NewCrown.Name, EVENT_LEADER_UPDATE, NewCrown.OnLeaderUpdate)
			NewCrown.SavedVars.SpecialFeatureEnabled = true
		end	
	end
	
end


function NewCrown.OnAddOnLoaded(event, addonName)
	if addonName ~= NewCrown.Name then return end
	EVENT_MANAGER:UnregisterForEvent(NewCrown.Name, event)

	NewCrown.Init()

	EVENT_MANAGER:RegisterForEvent(NewCrown.Name, EVENT_PLAYER_ACTIVATED, NewCrown.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(NewCrown.Name, EVENT_RAID_TRIAL_STARTED, NewCrown.OnTrialStarted)
	NewCrown.RegisterUnregisterPlayerCombatState()
	NewCrown.RegisterUnregisterGroupEvents()
end

EVENT_MANAGER:RegisterForEvent(NewCrown.Name, EVENT_ADD_ON_LOADED, NewCrown.OnAddOnLoaded)