local Addon = {}
Addon.Name = "AGS_UnknownGearFilter"
Addon.DisplayName = "AGS_UnknownGearFilter"
Addon.Author = "tomstock"
Addon.Version = "1.4"

AGS_UGF.savedVars = {}

function AGS_UGF.onLoad(eventCode, name)

	if name ~= Addon.Name then return end
	AGS_UGF.savedVars = ZO_SavedVars:NewAccountWide("AGS_UGFVars", 1, nil, nil, GetWorldName(), nil)
	AwesomeGuildStore:RegisterCallback( AwesomeGuildStore.callback.AFTER_FILTER_SETUP, function() AGS_UGF.initAGS() end)
	EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED)
end


EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, AGS_UGF.onLoad)