COTUGuildhall = COTUGuildhall or {}

function COTUGuildhall_Initialize(eventCode, addOnName)

	if (addOnName ~= "COTUGuildhall") then return end
	
	local button1 =  WINDOW_MANAGER:CreateControl("COTUGuildhall", ZO_ChatWindow, CT_BUTTON)
    button1:SetDimensions(25, 25)
    button1:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 30, 2)
    -- Below tooltips
	button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Guildhall") end)
	button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- End tooltips
	button1:SetNormalTexture("COTUGuildhall/imgs/cotuUp.dds")
    button1:SetPressedTexture("COTUGuildhall/imgs/cotuDown.dds")
    button1:SetMouseOverTexture("COTUGuildhall/imgs/cotuOver.dds")
	
	
	button1:SetHandler("OnClicked", function(...)
		JumpToHouse("@CapitalFlash")
	end)
	
	
			
end

EVENT_MANAGER:RegisterForEvent("CGuildhallLoaded", EVENT_ADD_ON_LOADED, function(...) 	COTUGuildhall_Initialize(...) 	end)