CombatTip = {}
 
CombatTip.name = "CombatTip"
CombatTip.rootTip = 19
CombatTip.stunTip = 18
CombatTip.blockTip = 1

function CombatTip:Initialize()
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DISPLAY_ACTIVE_COMBAT_TIP, self.tipView)
end

function CombatTip.OnAddOnLoaded(event, addonName)
  if addonName == CombatTip.name then
    CombatTip:Initialize()
  end
end
 
function CombatTip.tipView(event, tipId)
	if tipId == CombatTip.rootTip then
		d("Rooted")
	elseif tipId == CombatTip.stunTip then
		d("Stunned")
	else
		d("Heavy Attack Incoming")
	end
end

EVENT_MANAGER:RegisterForEvent(CombatTip.name, EVENT_ADD_ON_LOADED, CombatTip.OnAddOnLoaded)