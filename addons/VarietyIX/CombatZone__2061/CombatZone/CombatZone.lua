CombatZone = {}

CombatZone.name = "CombatZone"

function CombatZone:RestorePosition()
	local left = self.savedVariables.left
	local top = self.savedVariables.top
	
	CombatZoneIndicator:ClearAnchors()
	CombatZoneIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function CombatZone:Initialize()
	self.inCombat = IsUnitInCombat("player")
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
	
	self.savedVariables = ZO_SavedVars:NewAccountWide("CombatZoneSavedVariables", 1, nil, {})
	
	self:RestorePosition()
end

function CombatZone.OnAddOnLoaded(event, addonName)
	if addonName == CombatZone.name then
	CombatZone:Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(CombatZone.name, EVENT_ADD_ON_LOADED, CombatZone.OnAddOnLoaded)

function CombatZone.OnPlayerCombatState(event, inCombat)
	if inCombat ~= CombatZone.inCombat then
		CombatZone.inCombat = inCombat
		
		CombatZoneIndicator:SetHidden(not inCombat)
	end
end

function CombatZone.OnIndicatorMoveStop()
	CombatZone.savedVariables.left = CombatZoneIndicator:GetLeft()
	CombatZone.savedVariables.top = CombatZoneIndicator:GetTop()
end
