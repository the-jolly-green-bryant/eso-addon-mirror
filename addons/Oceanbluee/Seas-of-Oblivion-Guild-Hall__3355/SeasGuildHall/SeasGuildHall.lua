SeasGuildHall = SeasGuildHall or {}

function SeasGuildHall_Initialize(eventCode, addOnName)

	if (addOnName ~= "SeasGuildHall") then return end
	
MLbtn =  WINDOW_MANAGER:CreateControl("MaxMLGH", ZO_ChatWindow, CT_BUTTON)
    MLbtn:SetDimensions(20, 20)
    MLbtn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 200, 13)
    MLbtn:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Seas of Oblivion") end)
	MLbtn:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    MLbtn:SetNormalTexture("SeasGuildHall/img/SO.dds")
    MLbtn:SetPressedTexture("SeasGuildHall/img/SO.dds")
    MLbtn:SetMouseOverTexture("SeasGuildHall/img/SO.dds")	
	MLbtn:SetHandler("OnClicked", function(...)
		local entries = {
              {
                label = "Guild House",
                callback = function() JumpToSpecificHouse("@Oceanbluee", 86) end,
              },
              {
                label = "-",
              },
              {
                label = "Parse House",
                callback = function() JumpToSpecificHouse("@Oceanbluee", 13) end,
              },
            }
			ClearMenu()
			AddCustomSubMenuItem("Guild Halls ", entries)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("My Home", function() RequestJumpToHouse(GetHousingPrimaryHouse()) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("Discord", function() RequestOpenUnsafeURL("https://discord.gg/soo") end)
			ShowMenu()
	end)
	
	MLbtnMin =  WINDOW_MANAGER:CreateControl("MinMLGH", ZO_ChatWindowMinBar, CT_BUTTON)
    MLbtnMin:SetDimensions(25, 25)
    MLbtnMin:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, 0, 423)
    MLbtnMin:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Seas of Oblivion") end)
	MLbtnMin:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    MLbtnMin:SetNormalTexture("SeasGuildHall/img/SO.dds")
    MLbtnMin:SetPressedTexture("SeasGuildHall/img/SO.dds")
    MLbtnMin:SetMouseOverTexture("SeasGuildHall/img/SO.dds")
	MLbtnMin:SetHandler("OnClicked", function(...)
		local entries = {
              {
                label = "Guild House",
                callback = function() JumpToSpecificHouse("@Oceanbluee", 86) end,
              },
              {
                label = "-",
              },
              {
                label = "Guild Master",
                callback = function() JumpToSpecificHouse("@Oceanbluee", 86) end,
              },
            }
			ClearMenu()
			AddCustomSubMenuItem("Guild House ", entries)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("My Home", function() RequestJumpToHouse(GetHousingPrimaryHouse()) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("Discord", function() RequestOpenUnsafeURL("https://discord.gg/soo") end)
			ShowMenu()
			
	end)		


			
end

EVENT_MANAGER:RegisterForEvent("SeasGuildHallLoaded", EVENT_ADD_ON_LOADED, function(...) 	SeasGuildHall_Initialize(...) 	end)
