local LAM2 = LibStub("LibAddonMenu-2.0")
local ZNL={}
ZNL.name = "ZoneNameLogger"
ZNL.active = true

function ZNL.OnActivated()
	if ZNL.active == true then
		d("--Entered " .. GetUnitZone("player") .. "--")
	end
end

function ZNL.Toggle()
	ZNL.active = not ZNL.active
	if ZNL.active then
		d("ZoneNameLogger active.")
	else
		d("ZoneNameLogger disabled.")
	end
end

function ZNL.OnLoad(eventCode, addonName)
	if addonName~=ZNL.name then return end
	ZNL.savedVariables = ZO_SavedVars:NewAccountWide("ZoneNameLoggerDB", 1, nil, {})
	EVENT_MANAGER:UnregisterForEvent(ZNL.name, EVENT_ADD_ON_LOADED, ZNL.OnLoad)
	EVENT_MANAGER:RegisterForEvent(ZNL.name, EVENT_PLAYER_ACTIVATED, ZNL.OnActivated)
	SLASH_COMMANDS["/znl"] = ZNL.Toggle
end

EVENT_MANAGER:RegisterForEvent(ZNL.name, EVENT_ADD_ON_LOADED, ZNL.OnLoad)
