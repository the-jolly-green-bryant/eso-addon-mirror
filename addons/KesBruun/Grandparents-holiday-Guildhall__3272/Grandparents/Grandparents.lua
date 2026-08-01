Grandparents = {}

function Grandparents_Init(eventCode, addOnName)
    if (addOnName ~= "Grandparents") then return end

	local 
	toGHall =  WINDOW_MANAGER:CreateControl("GrandparentsButton", ZO_ChatWindow, CT_BUTTON)
    toGHall:SetDimensions(30,30)
    toGHall:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 35, 5)
    toGHall:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Grandparents holidays") end)
	toGHall:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    toGHall:SetNormalTexture("Grandparents/imgs/Grandparents.dds")
    toGHall:SetPressedTexture("Grandparents/imgs/Grandparents.dds")
    toGHall:SetMouseOverTexture("Grandparents/imgs/Grandparents.dds")	

	
	toGHall:SetHandler("OnClicked", function(...)
		 JumpToHouse("@Kes_Bruun")
	end)
	
			
end

EVENT_MANAGER:RegisterForEvent("GrandparentsLoaded", EVENT_ADD_ON_LOADED, function(...) Grandparents_Init(...) end)

	
