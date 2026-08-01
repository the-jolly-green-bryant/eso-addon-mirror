KecajTrialIcons = {}
KecajTrialIcons.name = "KecajTrialIcons"

function KecajTrialIcons.OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= KecajTrialIcons.name) then return end
	EVENT_MANAGER:UnregisterForEvent(KecajTrialIcons.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(KecajTrialIcons.name, EVENT_PLAYER_ACTIVATED, KecajTrialIcons.LoadZonePins)
	EVENT_MANAGER:RegisterForEvent(KecajTrialIcons.name, EVENT_ZONE_CHANGED, KecajTrialIcons.LoadZonePins)
end

EVENT_MANAGER:RegisterForEvent(KecajTrialIcons.name, EVENT_ADD_ON_LOADED, KecajTrialIcons.OnAddOnLoaded)
