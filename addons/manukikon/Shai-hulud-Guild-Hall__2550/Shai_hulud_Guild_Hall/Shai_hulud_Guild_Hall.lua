Shai_hulud_Guild_Hall = Shai_hulud_Guild_Hall or {}

function Shai_hulud_Guild_Hall_Initialize(eventCode, addOnName)

	if (addOnName ~= "Shai_hulud_Guild_Hall") then return end
	
	local button1 =  WINDOW_MANAGER:CreateControl("Shai_hulud_Guild_Hall1", ZO_ChatWindow, CT_BUTTON)
    button1:SetDimensions(20, 20)
    button1:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 50, 5)
    -- Ниже тултипы
    button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Shai-hulud Guild Hall") end)
    button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
	button1:SetNormalTexture("Shai_hulud_Guild_Hall/imgs/covUp.dds")
    button1:SetPressedTexture("Shai_hulud_Guild_Hall/imgs/covDown.dds")
    button1:SetMouseOverTexture("Shai_hulud_Guild_Hall/imgs/covOver.dds")
	
    local button4 =  WINDOW_MANAGER:CreateControl("Shai_hulud_Guild_Hall4", ZO_ChatWindow, CT_BUTTON)
    button4:SetDimensions(20, 20)
    button4:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 85, 5)
    -- Ниже тултипы
    button4:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Reload UI") end)
    button4:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
    button4:SetNormalTexture("Shai_hulud_Guild_Hall/imgs/reload.dds")
    --button4:SetPressedTexture("Shai_hulud_Guild_Hall/imgs/reload.dds")
    --button4:SetMouseOverTexture("Shai_hulud_Guild_Hall/imgs/reload.dds")
	
	button1:SetHandler("OnClicked", function(...)
		JumpToHouse("@doctorosen", 40)
	end)
    
    button4:SetHandler("OnClicked", function(...)
		ReloadUI("ingame")
    end)
    
    SLASH_COMMANDS["/rl"] = function(...) ReloadUI("ingame") end
	
end

EVENT_MANAGER:RegisterForEvent("Shai_hulud_Guild_HallLoaded", EVENT_ADD_ON_LOADED, function(...) 	Shai_hulud_Guild_Hall_Initialize(...) 	end)