ArtempapaGuildHall = {
	name = "ArtempapaGuildHall"
}

function ArtempapaGuildHall_Initialize(eventCode, addOnName)

	if (addOnName ~= "ArtempapaGuildHall") then return end
	
	local button1 =  WINDOW_MANAGER:CreateControl("Artempapa1", ZO_ChatWindow, CT_BUTTON)
    button1:SetDimensions(20, 20)
    button1:SetAnchor(TOPLEFT,ZO_ChatOptionsSectionLabel, TOPRIGHT, -100, 11)
	button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Artempapa Guild Hall") end)
	button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)	button1:SetNormalTexture("ArtempapaGuildHall/imgs/1.dds")
    button1:SetPressedTexture("ArtempapaGuildHall/imgs/1.dds")
    button1:SetMouseOverTexture("ArtempapaGuildHall/imgs/1.dds")
	
		
	
	
	button1:SetHandler("OnClicked", function(...)
		JumpToHouse("@Artempapa")
	end)
	
			
end

EVENT_MANAGER:RegisterForEvent("ArtempapaGuildHallLoaded", EVENT_ADD_ON_LOADED, function(...) 	ArtempapaGuildHall_Initialize(...) 	end)