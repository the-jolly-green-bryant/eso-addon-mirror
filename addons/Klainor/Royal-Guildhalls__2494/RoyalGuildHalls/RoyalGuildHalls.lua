RoyalGuildHalls = RoyalGuildHalls or {}

function RoyalGuildHalls_Initialize(eventCode, addOnName)

	if (addOnName ~= "RoyalGuildHalls") then return end
	
	local button1 =  WINDOW_MANAGER:CreateControl("RoyalGuildHalls1", ZO_ChatWindow, CT_BUTTON)
    button1:SetDimensions(20, 20)
    button1:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 115, 5)
    -- Ниже тултипы
	button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Ilbirs EN") end)
	button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
	button1:SetNormalTexture("RoyalGuildHalls/imgs/knUp.dds")
    button1:SetPressedTexture("RoyalGuildHalls/imgs/knDown.dds")
    button1:SetMouseOverTexture("RoyalGuildHalls/imgs/knOver.dds")
	
	local button2 =  WINDOW_MANAGER:CreateControl("RoyalGuildHalls2", ZO_ChatWindow, CT_BUTTON)
    button2:SetDimensions(20, 20)
    button2:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 145, 5)
    -- Ниже тултипы
    button2:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Maksat RU") end)
    button2:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
    button2:SetNormalTexture("RoyalGuildHalls/imgs/arUp.dds")
    button2:SetPressedTexture("RoyalGuildHalls/imgs/arDown.dds")
    button2:SetMouseOverTexture("RoyalGuildHalls/imgs/arOver.dds")
	
	
	
	button1:SetHandler("OnClicked", function(...)
		JumpToHouse("@ilbirs", 40)
	end)
	
	button2:SetHandler("OnClicked", function(...)
		JumpToHouse("@maksat", 47)
	end)
			
end

EVENT_MANAGER:RegisterForEvent("RoyalGuildHallsLoaded", EVENT_ADD_ON_LOADED, function(...) 	RoyalGuildHalls_Initialize(...) 	end)