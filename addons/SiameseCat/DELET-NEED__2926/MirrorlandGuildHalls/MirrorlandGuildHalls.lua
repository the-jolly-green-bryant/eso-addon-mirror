MirrorlandGuildHalls = MirrorlandGuildHalls or {}

function MirrorlandGuildHalls_Initialize(eventCode, addOnName)

	if (addOnName ~= "MirrorlandGuildHalls") then return end
	
	local button1 =  WINDOW_MANAGER:CreateControl("MirrorlandGuildHalls1", ZO_ChatWindow, CT_BUTTON)
    button1:SetDimensions(20, 20)
    button1:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 65, 5)
    button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Mirrorland") end)
	button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    button1:SetNormalTexture("MirrorlandGuildHalls/imgs/MR3.dds")
    button1:SetPressedTexture("MirrorlandGuildHalls/imgs/MR3.dds")
    button1:SetMouseOverTexture("MirrorlandGuildHalls/imgs/MR3.dds")
			
	button1:SetHandler("OnClicked", function(...)
		JumpToHouse("@SiameseCat")
	end)
			
end

EVENT_MANAGER:RegisterForEvent("MirrorlandGuildHallsLoaded", EVENT_ADD_ON_LOADED, function(...) 	MirrorlandGuildHalls_Initialize(...) 	end)