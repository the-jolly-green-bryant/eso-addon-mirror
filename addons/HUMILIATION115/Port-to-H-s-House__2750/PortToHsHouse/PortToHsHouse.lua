-- *** PortToHsHouse ***

PortToHsHouse = {}
PortToHsHouse.name = "PortToHsHouse"

function PortToHsHouse.PortToHouse()
	d("Porting to H's house :D")
	JumpToSpecificHouse("@HUMILIATION115", 47)
end

function PortToHsHouse.OnAddOnLoaded(event, addonName)
	if addonName == PortToHsHouse.name then
		SLASH_COMMANDS["/hhouse"] = PortToHsHouse.PortToHouse
		EVENT_MANAGER:UnregisterForEvent(PortToHsHouse.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(PortToHsHouse.name, EVENT_ADD_ON_LOADED, PortToHsHouse.OnAddOnLoaded)