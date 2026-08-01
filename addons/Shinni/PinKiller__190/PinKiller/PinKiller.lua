
PinKiller = PinKiller or {}

function OnAddonLoaded( _, addon )
	if addon ~= "PinKiller" then
		return
	end
	
	PinKiller:InitializeSettings()
	PinKiller:InitializeCompassPins()
	PinKiller:InitializeMapPins()
end

EVENT_MANAGER:RegisterForEvent("PinKiller", EVENT_ADD_ON_LOADED , OnAddonLoaded)
