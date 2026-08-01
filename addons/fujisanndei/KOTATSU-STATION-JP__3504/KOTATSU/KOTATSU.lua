KOTATSU = {
	name = "KOTATSU"
}

function KOTATSU_Initialize(eventCode, addOnName)

	if (addOnName ~= "KOTATSU") then return end
	
	local button1 =  WINDOW_MANAGER:CreateControl("fujisanndei", ZO_ChatWindow, CT_BUTTON)
    button1:SetDimensions(20, 20)
    button1:SetAnchor(TOPLEFT,ZO_ChatOptionsSectionLabel, TOPRIGHT, -100, 11)
	button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "KOTATSU") end)
	button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)	button1:SetNormalTexture("KOTATSU/imgs/fujisanndei.dds")
    button1:SetPressedTexture("KOTATSU/imgs/fujisanndei.dds")
    button1:SetMouseOverTexture("KOTATSU/imgs/fujisanndei.dds")
	
		
	
	
	button1:SetHandler("OnClicked", function(...)
		JumpToHouse("@fujisanndei")
	end)
	
			
end

EVENT_MANAGER:RegisterForEvent("KOTATSULoaded", EVENT_ADD_ON_LOADED, function(...) 	KOTATSU_Initialize(...) 	end)