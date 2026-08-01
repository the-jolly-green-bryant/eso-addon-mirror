SoldatiiGuildHalls = SoldatiiGuildHalls or {}

function SoldatiiGuildHalls_Initialize(eventCode, addOnName)

	if (addOnName ~= "SoldatiiGuildHalls") then return end
	
SDbtn =  WINDOW_MANAGER:CreateControl("MaxSDGH", ZO_ChatWindow, CT_BUTTON)
    SDbtn:SetDimensions(20, 20)
    SDbtn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 185, 13)
    SDbtn:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Soldatii La Dreptate") end)
	SDbtn:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    SDbtn:SetNormalTexture("SoldatiiGuildHalls/imgs/AS.dds")
    SDbtn:SetPressedTexture("SoldatiiGuildHalls/imgs/AS.dds")
    SDbtn:SetMouseOverTexture("SoldatiiGuildHalls/imgs/AS.dds")	
	SDbtn:SetHandler("OnClicked", function(...)
			ClearMenu()
			AddCustomMenuItem("Guild Hall", function() JumpToSpecificHouse("@Mihrruna", 64) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("My Home", function() RequestJumpToHouse(GetHousingPrimaryHouse()) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("Discord", function() RequestOpenUnsafeURL("https://discord.gg/TRdJRX4U8E") end)
			ShowMenu()
	end)
	
	SDbtnMin =  WINDOW_MANAGER:CreateControl("MinSDGH", ZO_ChatWindowMinBar, CT_BUTTON)
    SDbtnMin:SetDimensions(25, 25)
    SDbtnMin:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, 0, 430)
    SDbtnMin:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Soldatii La Dreptate") end)
	SDbtnMin:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    SDbtnMin:SetNormalTexture("SoldatiiGuildHalls/imgs/AS.dds")
    SDbtnMin:SetPressedTexture("SoldatiiGuildHalls/imgs/AS.dds")
    SDbtnMin:SetMouseOverTexture("SoldatiiGuildHalls/imgs/AS.dds")
	SDbtnMin:SetHandler("OnClicked", function(...)
			ClearMenu()
			AddCustomMenuItem("Guild Hall", function() JumpToSpecificHouse("@Mihrruna", 64) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("My Home", function() RequestJumpToHouse(GetHousingPrimaryHouse()) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("Discord", function() RequestOpenUnsafeURL("https://discord.gg/TRdJRX4U8E") end)
			ShowMenu()
			
	end)		


			
end

EVENT_MANAGER:RegisterForEvent("SoldatiiGuildHallsLoaded", EVENT_ADD_ON_LOADED, function(...) 	SoldatiiGuildHalls_Initialize(...) 	end)