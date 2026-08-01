AetheriusGuildHalls = AetheriusGuildHalls or {}

function AetheriusGuildHalls_Initialize(eventCode, addOnName)

	if (addOnName ~= "AetheriusGuildHalls") then return end
	
	local button1 =  WINDOW_MANAGER:CreateControl("AetheriusGuildHalls1", ZO_ChatWindow, CT_BUTTON)
    button1:SetDimensions(20, 20)
    button1:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 65, 5)
    -- Ниже тултипы
	button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Justicelessness") end)
	button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
	button1:SetNormalTexture("AetheriusGuildHalls/imgs/AE.dds")
    button1:SetPressedTexture("AetheriusGuildHalls/imgs/AE.dds")
    button1:SetMouseOverTexture("AetheriusGuildHalls/imgs/AE.dds")
	
	local button2 =  WINDOW_MANAGER:CreateControl("AetheriusGuildHalls2", ZO_ChatWindow, CT_BUTTON)
    button2:SetDimensions(20, 20)
    button2:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 95, 5)
    -- Ниже тултипы
    button2:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Lucian_Corde") end)
    button2:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
    button2:SetNormalTexture("AetheriusGuildHalls/imgs/AG.dds")
    button2:SetPressedTexture("AetheriusGuildHalls/imgs/AG.dds")
    button2:SetMouseOverTexture("AetheriusGuildHalls/imgs/AG.dds")
	
	local button3 =  WINDOW_MANAGER:CreateControl("AetheriusGuildHalls3", ZO_ChatWindow, CT_BUTTON)
    button3:SetDimensions(20, 20)
    button3:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 125, 5)
    -- Ниже тултипы
    button3:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Xarmonia") end)
    button3:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
    button3:SetNormalTexture("AetheriusGuildHalls/imgs/AL.dds")
    button3:SetPressedTexture("AetheriusGuildHalls/imgs/AL.dds")
    button3:SetMouseOverTexture("AetheriusGuildHalls/imgs/AL.dds")
	
	local button4 =  WINDOW_MANAGER:CreateControl("AetheriusGuildHalls4", ZO_ChatWindow, CT_BUTTON)
    button4:SetDimensions(20, 20)
    button4:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 155, 5)
    -- Ниже тултипы
    button4:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "SIDMAY") end)
    button4:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
    button4:SetNormalTexture("AetheriusGuildHalls/imgs/AS.dds")
    button4:SetPressedTexture("AetheriusGuildHalls/imgs/AS.dds")
    button4:SetMouseOverTexture("AetheriusGuildHalls/imgs/AS.dds")
	
	
	
	button1:SetHandler("OnClicked", function(...)
		JumpToHouse("@Justicelessness")
	end)
	
	button2:SetHandler("OnClicked", function(...)
		JumpToHouse("@Lucian_Corde")
	end)
	
	button3:SetHandler("OnClicked", function(...)
		JumpToHouse("@Xarmonia")
	end)
	
	button4:SetHandler("OnClicked", function(...)
		JumpToHouse("@SIDMAY")
	end)
			
end

EVENT_MANAGER:RegisterForEvent("AetheriusGuildHallsLoaded", EVENT_ADD_ON_LOADED, function(...) 	AetheriusGuildHalls_Initialize(...) 	end)