SMCGuildHalls = SMCGuildHalls or {}

function SMCGuildHalls_Initialize(eventCode, addOnName)

	if (addOnName ~= "SMCGuildHalls") then return end
	
	local button1 =  WINDOW_MANAGER:CreateControl("SMCGuildHalls1", ZO_ChatWindow, CT_BUTTON)
    button1:SetDimensions(32, 32)
    button1:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 20, -2)
    -- Button sshogrin
	button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "sshogrin") end)
	button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Button Images
	button1:SetNormalTexture("SMCGuildHalls/imgs/sshogrinUp.dds")
    button1:SetPressedTexture("SMCGuildHalls/imgs/teleport.dds")
    button1:SetMouseOverTexture("SMCGuildHalls/imgs/sshogrinOver.dds")
	
	local button2 =  WINDOW_MANAGER:CreateControl("SMCGuildHalls2", ZO_ChatWindow, CT_BUTTON)
    button2:SetDimensions(30, 30)
    button2:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 55, 0)
    -- Button barcabeagle
    button2:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "barcabeagle") end)
    button2:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Button Images
    button2:SetNormalTexture("SMCGuildHalls/imgs/barcaUp.dds")
    button2:SetPressedTexture("SMCGuildHalls/imgs/teleport.dds")
    button2:SetMouseOverTexture("SMCGuildHalls/imgs/barcaOver.dds")
	
	
	
	button1:SetHandler("OnClicked", function(...)
		JumpToHouse("@sshogrin", PRIMARY_RESIDENCE)
		end)
	
	button2:SetHandler("OnClicked", function(...)
		JumpToHouse("@barcabeagle", PRIMARY_RESIDENCE)
		end)
			
end

EVENT_MANAGER:RegisterForEvent("SMCGuildHallsLoaded", EVENT_ADD_ON_LOADED, function(...) 	SMCGuildHalls_Initialize(...) 	end)