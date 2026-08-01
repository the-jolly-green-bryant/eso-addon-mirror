HomeHR = HomeHR or {}

-- initialization stuff
function HomeHR_Initialize(eventCode, addOnName)

	if (addOnName ~= "HomeHR") then return end
	
	local button =  WINDOW_MANAGER:CreateControl("HomeHR", ZO_ChatWindow, CT_BUTTON)
    button:SetDimensions(20, 20)
    button:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 160, 5)
	-- courtesy of votan&manavortex! \o/
    button:SetNormalTexture("HomeHR/imgs/HomeHR.dds")
    button:SetPressedTexture("HomeHR/imgs/HomeHR.dds")
    button:SetMouseOverTexture("HomeHR/imgs/HomeHR.dds")
	
	--Set the callback function of the button
	button:SetHandler("OnClicked", function(...)
		JumpToHouse("@Braunizt")
	end)
	
end

EVENT_MANAGER:RegisterForEvent("HomeHRLoaded", EVENT_ADD_ON_LOADED, function(...) 	HomeHR_Initialize(...) 	end)