-- Guiild For The Soloiists Tools - GuildHalls

SoloiistGuildHalls = SoloiistGuildHalls or {}

Soloiist_GuildName = "Guiild For The Soloiist"
Soloiist_Discord_URL = "https://discord.gg/8rGVFfa"

Soloiist_GuildHouseID = 62
Soloiist_GuildHouseOwner = "@Exquisition"
-- HouseID list : https://docs.google.com/spreadsheets/d/1YBf5fghDWFiZbLgVpmLemhcieKP-cojDojItGNpWgEU/edit#gid=0


function SoloiistGuildHalls_Initialize(eventCode, addOnName)
  -- Skip multiple loads
	if (addOnName ~= "SoloiistGuildHalls") then return end
	
  -- Guild Hall Button for opened chat window
  SoloiistsGHCtrl = WINDOW_MANAGER:CreateControl("SoloiistsGHCtrl", ZO_ChatWindow, CT_BUTTON)
  SoloiistsGHCtrl:SetDimensions(20, 20)
  SoloiistsGHCtrl:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 200, 13)
  SoloiistsGHCtrl:SetNormalTexture("SoloiistGuildHalls/imgs/Soloiists.dds")
  SoloiistsGHCtrl:SetPressedTexture("SoloiistGuildHalls/imgs/Soloiists.dds")
  SoloiistsGHCtrl:SetMouseOverTexture("SoloiistGuildHalls/imgs/Soloiists.dds")	
  
  SoloiistsGHCtrl:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, Soloiist_GuildName) end)
	SoloiistsGHCtrl:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
  
	SoloiistsGHCtrl:SetHandler("OnClicked", function(...)
		ClearMenu()
		AddCustomSubMenuItem("Guild Halls ", {
      {
        label = "Guild Villa",
        callback = function() JumpToSpecificHouse(Soloiist_GuildHouseOwner, Soloiist_GuildHouseID) end,
      },
    })
		AddCustomMenuItem("-", function() end)
		AddCustomMenuItem("My Home", function() RequestJumpToHouse(GetHousingPrimaryHouse()) end)
		AddCustomMenuItem("-", function() end)
		AddCustomMenuItem("Discord", function() RequestOpenUnsafeURL(Soloiist_Discord_URL) end)
		ShowMenu()
  end)

  -- Guild Hall Button for minimized chat window
	SoloiistsGHCtrlMini = WINDOW_MANAGER:CreateControl("SoloiistsGHCtrlMini", ZO_ChatWindowMinBar, CT_BUTTON)
  
  SoloiistsGHCtrlMini:SetDimensions(25, 25)
  SoloiistsGHCtrlMini:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, 0, 423)
  SoloiistsGHCtrlMini:SetNormalTexture("SoloiistGuildHalls/imgs/Soloiists.dds")
  SoloiistsGHCtrlMini:SetPressedTexture("SoloiistGuildHalls/imgs/Soloiists.dds")
  SoloiistsGHCtrlMini:SetMouseOverTexture("SoloiistGuildHalls/imgs/Soloiists.dds")

  SoloiistsGHCtrlMini:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, Soloiist_GuildName) end)	
  SoloiistsGHCtrlMini:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)

	SoloiistsGHCtrlMini:SetHandler("OnClicked", function(...)
			ClearMenu()
			AddCustomSubMenuItem("Guild Halls ",{
        {
          label = "Guild Villa",
          callback = function() JumpToSpecificHouse(Soloiist_GuildHouseOwner, Soloiist_GuildHouseID) end,
        },
      })
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("My Home", function() RequestJumpToHouse(GetHousingPrimaryHouse()) end)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem("Discord", function() RequestOpenUnsafeURL(Soloiist_Discord_URL) end)
			ShowMenu()		
	end)		

end

EVENT_MANAGER:RegisterForEvent("SoloiistGuildHallsLoaded", EVENT_ADD_ON_LOADED, SoloiistGuildHalls_Initialize)