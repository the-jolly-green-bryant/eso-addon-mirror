ArrowGuildHalls = ArrowGuildHalls or {}

function ArrowGuildHalls_Initialize(eventCode, addOnName)

	if (addOnName ~= "ArrowGuildHalls") then return end
	
MLbtn =  WINDOW_MANAGER:CreateControl("MaxMLGH", ZO_ChatWindow, CT_BUTTON)
    MLbtn:SetDimensions(20, 20)
    MLbtn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 200, 13)
    MLbtn:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Arrow To The Knee") end)
	MLbtn:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    MLbtn:SetNormalTexture("ArrowGuildHalls/imgs/AS.dds")
    MLbtn:SetPressedTexture("ArrowGuildHalls/imgs/AS.dds")
    MLbtn:SetMouseOverTexture("ArrowGuildHalls/imgs/AS.dds")	
	MLbtn:SetHandler("OnClicked", function(...)
		local entries = {
              {
                label = "Guild House",
                callback = function() JumpToSpecificHouse("@Mihrruna", 64) end,
              },
              {
                label = "-",
              },
              {
                label = "Guild Master",
                callback = function() JumpToSpecificHouse("@Animalu", 62) end,
              },
            }
			ClearMenu()
			AddCustomSubMenuItem("Guild Halls ", entries)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("My Home", function() RequestJumpToHouse(GetHousingPrimaryHouse()) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("Discord", function() RequestOpenUnsafeURL("https://discord.gg/TRdJRX4U8E") end)
			ShowMenu()
	end)
	
	MLbtnMin =  WINDOW_MANAGER:CreateControl("MinMLGH", ZO_ChatWindowMinBar, CT_BUTTON)
    MLbtnMin:SetDimensions(25, 25)
    MLbtnMin:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, 0, 423)
    MLbtnMin:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Arrow To The Knee") end)
	MLbtnMin:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    MLbtnMin:SetNormalTexture("ArrowGuildHalls/imgs/AS.dds")
    MLbtnMin:SetPressedTexture("ArrowGuildHalls/imgs/AS.dds")
    MLbtnMin:SetMouseOverTexture("ArrowGuildHalls/imgs/AS.dds")
	MLbtnMin:SetHandler("OnClicked", function(...)
		local entries = {
              {
                label = "Guild House",
                callback = function() JumpToSpecificHouse("@Mihrruna", 64) end,
              },
              {
                label = "-",
              },
              {
                label = "Guild Master",
                callback = function() JumpToSpecificHouse("@Animalu", 62) end,
              },
            }
			ClearMenu()
			AddCustomSubMenuItem("Guild House ", entries)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("My Home", function() RequestJumpToHouse(GetHousingPrimaryHouse()) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("Discord", function() RequestOpenUnsafeURL("https://discord.gg/TRdJRX4U8E") end)
			ShowMenu()
			
	end)		


			
end

EVENT_MANAGER:RegisterForEvent("ArrowGuildHallsLoaded", EVENT_ADD_ON_LOADED, function(...) 	ArrowGuildHalls_Initialize(...) 	end)