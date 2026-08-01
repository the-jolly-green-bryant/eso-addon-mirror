RawrGuildhall = RawrGuildhall or {}

function RawrGuildhall_Initialize(eventCode, addOnName)

	if (addOnName ~= "RawrGuildhall") then return end
	
	local button1 =  WINDOW_MANAGER:CreateControl("RawrGuildhal1", ZO_ChatWindow, CT_BUTTON)
    button1:SetDimensions(20, 20)
    button1:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 180, 5)
    -- Ниже тултипы
	button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "RawrGuildhal") end)
	button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
	button1:SetNormalTexture("RawrGuildhall/imgs/knUp.dds")
    button1:SetPressedTexture("RawrGuildhall/imgs/knDown.dds")
    button1:SetMouseOverTexture("RawrGuildhall/imgs/knOver.dds")
	
	
	button1:SetHandler("OnClicked", function(...)
		JumpToHouse("@Varlav")
	end)
	
	
			
end

EVENT_MANAGER:RegisterForEvent("RawrGuildhallLoaded", EVENT_ADD_ON_LOADED, function(...) 	RawrGuildhall_Initialize(...) 	end)