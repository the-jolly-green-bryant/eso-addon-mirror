local Addon = {}
Addon.Name = "AGS_UnknownOnAltsFilter"
Addon.DisplayName = "AGS_UnknownOnAltsFilter"
Addon.Author = "remosito"
Addon.Version = "37.0"


AGS_UOAF.savedVars = {}



function AGS_UOAF.onLoad(eventCode, name)
	
	if name ~= Addon.Name then return end
	AGS_UOAF.savedVars = ZO_SavedVars:NewAccountWide("AGS_UOAFVars", 1, nil, nil, GetWorldName(), nil)
	if not AGS_UOAF.savedVars.crafters then AGS_UOAF.savedVars.crafters = {GetCurrentCharacterId()} end
	LibCharacterKnowledge.RegisterForCallback("AGS_UOAF", LibCharacterKnowledge.EVENT_INITIALIZED, function() AGS_UOAF.CreateMenu() end)
	AwesomeGuildStore:RegisterCallback( AwesomeGuildStore.callback.AFTER_FILTER_SETUP, function() AGS_UOAF.initAGS() end)
	EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED)
end


EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, AGS_UOAF.onLoad)