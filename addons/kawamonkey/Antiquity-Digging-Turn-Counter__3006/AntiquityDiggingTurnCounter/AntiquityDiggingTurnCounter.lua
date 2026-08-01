local function RefreshStabilityBar()
    ANTIQUITY_DIGGING.stabilityText:SetText(GetDigSpotStability())
end

local function onAddOnLoaded(eventCode, addonName)
	if addonName == "AntiquityDiggingTurnCounter" then
		EVENT_MANAGER:UnregisterForEvent("AntiquityDiggingTurnCounter", EVENT_ADD_ON_LOADED)

		ZO_PostHook(ZO_AntiquityDigging, "RefreshStabilityBar", RefreshStabilityBar)
	end
end

EVENT_MANAGER:RegisterForEvent("AntiquityDiggingTurnCounter", EVENT_ADD_ON_LOADED, onAddOnLoaded)