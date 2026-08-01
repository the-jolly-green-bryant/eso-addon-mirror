AvalonGuildHall = {}

function AvalonGuildHall_Init(eventCode, addOnName)
    if (addOnName ~= "AvalonGuildHall") then return end

	local toGHall =  WINDOW_MANAGER:CreateControl("AvalonGuildHallButton", ZO_ChatWindow, CT_BUTTON)
    toGHall:SetDimensions(20, 20)
    toGHall:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 35, 5)
    toGHall:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Avalon Guild Hall") end)
	toGHall:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    toGHall:SetNormalTexture("AvalonGuildHall/imgs/avalon.dds")
    toGHall:SetPressedTexture("AvalonGuildHall/imgs/avalon.dds")
    toGHall:SetMouseOverTexture("AvalonGuildHall/imgs/avalon.dds")
			
	toGHall:SetHandler("OnClicked", function(...)
		JumpToHouse("@JKaba40k")
	end)
			
end

EVENT_MANAGER:RegisterForEvent("AvalonGuildHallLoaded", EVENT_ADD_ON_LOADED, function(...) AvalonGuildHall_Init(...) end)