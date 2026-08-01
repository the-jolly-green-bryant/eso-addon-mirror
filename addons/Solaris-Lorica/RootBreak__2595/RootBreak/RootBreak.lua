RootBreak = {}
 
RootBreak.name = "RootBreak"
RootBreak.rootTip = 19
RootBreak.stunTip = 18
RootBreak.blockTip = 1

function RootBreak:Initialize()
	if IsPlayerMoving("player") and IsPlayerTryingToMove("player") then
		self.inRoot = false
	end
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DISPLAY_ACTIVE_COMBAT_TIP, self.TipView)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_REMOVE_ACTIVE_COMBAT_TIP, self.TipOutView)
end

function RootBreak.OnAddOnLoaded(event, addonName)
  if addonName == RootBreak.name then
    RootBreak:Initialize()
  end
end
 
function RootBreak.TipView(event, tipType)
	if tipType == RootBreak.rootTip then 
		RootBreak.tipRoot = true
	else 
		RootBreak.tipRoot = false
	end
	if RootBreak.tipRoot ~= RootBreak.inRoot then
		RootBreak.inRoot = RootBreak.tipRoot
		RootIndicator:SetHidden(not RootBreak.inRoot)
	end
end

function RootBreak.TipOutView(event, tipType, result)
	RootBreak.inRoot = false
	RootIndicator:SetHidden(not RootBreak.inRoot)
end

EVENT_MANAGER:RegisterForEvent(RootBreak.name, EVENT_ADD_ON_LOADED, RootBreak.OnAddOnLoaded)