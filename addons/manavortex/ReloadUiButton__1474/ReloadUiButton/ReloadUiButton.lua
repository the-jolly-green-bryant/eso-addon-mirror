ReloadUiButton = ReloadUiButton or {}

-- initialization stuff
function ReloadUiButton_Initialize(eventCode, addOnName)

	if (addOnName ~= "ReloadUiButton") then return end
	
	local button =  WINDOW_MANAGER:CreateControl("ReloadUiButton", ZO_ChatWindow, CT_BUTTON)
    button:SetDimensions(20, 20)
    button:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 35, 5)
	-- courtesy of votan! \o/
    button:SetNormalTexture("ReloadUiButton/imgs/reload_up.dds")
    button:SetPressedTexture("ReloadUiButton/imgs/reload_down.dds")
    button:SetMouseOverTexture("ReloadUiButton/imgs/reload_over.dds")
	
	--Set the callback function of the button
	button:SetHandler("OnClicked", function(...)
		ReloadUI()
	end)
	
end

EVENT_MANAGER:RegisterForEvent("ReloadUiButtonLoaded", EVENT_ADD_ON_LOADED, function(...) 	ReloadUiButton_Initialize(...) 	end)