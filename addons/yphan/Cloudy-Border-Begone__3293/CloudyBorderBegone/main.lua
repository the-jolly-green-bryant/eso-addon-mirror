pzk_CBB = {}
pzk_CBB.name = "CloudyBorderBegone"

function pzk_CBB.begone() 
	SetCVar("PPFXOverlaysEnabled", "0")
    EVENT_MANAGER:UnregisterForEvent(pzk_CBB.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(pzk_CBB.name, EVENT_ADD_ON_LOADED, pzk_CBB.begone)