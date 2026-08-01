StunBreak = {}
 
StunBreak.name = "StunBreak"
StunBreak.playerName = GetRawUnitName("player")

function StunBreak:Initialize()
  self.inStun = IsPlayerStunned("player")
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_STUNNED_STATE_CHANGED, self.OnPlayerStunState)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, self.OnPlayerFearState)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_REMOVE_ACTIVE_COMBAT_TIP, self.TipOutView)
end

function StunBreak.OnAddOnLoaded(event, addonName)
  if addonName == StunBreak.name then
    StunBreak:Initialize()
  end
end
 
 function StunBreak.OnPlayerStunState(event, stunState)
  if stunState ~= StunBreak.inStun then
    StunBreak.inStun = stunState
	StunIndicator:SetHidden(not stunState)
  end
end

function StunBreak.OnPlayerFearState(_,result,_,_,_,_,_,_,targetName)
	if targetName == StunBreak.playerName then 
		if result == ACTION_RESULT_FEARED then
			StunBreak.inFear = true
			if StunBreak.inFear ~= StunBreak.inStun then
				StunBreak.inStun = StunBreak.inFear
				StunIndicator:SetHidden(not StunBreak.inFear)
			end
		end
	end
end

function StunBreak.TipOutView(event, tipType, result)
	StunBreak.inStun = false
	StunIndicator:SetHidden(not StunBreak.inRoot)
end

EVENT_MANAGER:RegisterForEvent(StunBreak.name, EVENT_ADD_ON_LOADED, StunBreak.OnAddOnLoaded)