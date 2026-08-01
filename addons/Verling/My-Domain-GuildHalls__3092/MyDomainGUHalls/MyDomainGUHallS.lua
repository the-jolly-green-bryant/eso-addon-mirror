MyDomainGUHallS = MyDomainGUHallS or {}

function MyDomainGUHallS_Initialize(eventCode, addOnName)

  if (addOnName ~= "MyDomainGUHallS") then return end

    local button1 =  WINDOW_MANAGER:CreateControl("MyDomainGUHallS1", ZO_ChatWindow, CT_BUTTON)

    button1:SetDimensions(30, 30)
    button1:SetAnchor(TOPRight, ZO_ChatWindowOptions, TOPRight, -170, 0)
    button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "My Domain RU") end)
    button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)

    button1:SetNormalTexture("MyDomainGUHallS/md_ru.dds")
    button1:SetPressedTexture("MyDomainGUHallS/md_ru.dds")
    button1:SetMouseOverTexture("MyDomainGUHallS/md_ru.dds")

    local button2 =  WINDOW_MANAGER:CreateControl("MyDomainGUHallS2", ZO_ChatWindow, CT_BUTTON)

    button2:SetDimensions(30, 30)
    button2:SetAnchor(TOPRight, ZO_ChatWindowOptions, TOPRight, -130, 0)
    button2:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "My Domain EN") end)
    button2:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)

    button2:SetNormalTexture("MyDomainGUHallS/md_en.dds")
    button2:SetPressedTexture("MyDomainGUHallS/md_en.dds")
    button2:SetMouseOverTexture("MyDomainGUHallS/md_en.dds")

    local button3 =  WINDOW_MANAGER:CreateControl("MyDomainGUHallS3", ZO_ChatWindow, CT_BUTTON)

--    button3:SetDimensions(30, 30)
--    button3:SetAnchor(TOPRight, ZO_ChatWindowOptions, TOPRight, -90, 0)
--    button3:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "My House") end)
--    button3:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
--
--    button3:SetNormalTexture("MyDomainGUHallS/MyHome.dds")
--    button3:SetPressedTexture("MyDomainGUHallS/MyHome.dds")
--    button3:SetMouseOverTexture("MyDomainGUHallS/MyHome.dds")
	
    button1:SetHandler("OnClicked", function(...)
            JumpToHouse("@Kibert")
            end)

    button2:SetHandler("OnClicked", function(...)
            JumpToHouse("@red_fenix")
            end)

--    button3:SetHandler("OnClicked", function(...)
--            RequestJumpToHouse(GetHousingPrimaryHouse())
--            end)

end

EVENT_MANAGER:RegisterForEvent("MyDomainGUHallSLoaded", EVENT_ADD_ON_LOADED, function(...) 	MyDomainGUHallS_Initialize(...) 	end)