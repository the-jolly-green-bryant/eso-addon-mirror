---------------------------------------------------------
--	ARKadium's Extended Guild Notes test file  		    -
--	Written by @Carter_DC (EU) / coirier.rom1@gmail.com -
--------------------------------------------------------- 




ARK_EGN              	= ARK_EGN or {}
local EGN 			 	= ARK_EGN
EGN.GuildHouse		 	= ARK_EGN.GuildHouse or{}
local GH				= ARK_EGN.GuildHouse


do

	function GH.Initialize()

		--intialize ui
		GH.InitUI()
		
		zo_callLater(function() EGN.Debug( "GuildHouse","Module Loaded" ) end, 2600)
		
	end

	function GH.InitUI()
	
		--retrieve guildhouse button 
		local guildHouseButton = WINDOW_MANAGER:GetControlByName("ARK_EGN_GH_GuildHouseButton")
		EGN.SetToolTip(guildHouseButton, "Maison de Guilde")
		guildHouseButton:SetHandler("OnClicked", function(self) GH.TeleportToGuildHouse() end)
		--retrieve primaryhouse button
		local primaryHouseButton = WINDOW_MANAGER:GetControlByName("ARK_EGN_GH_PrimaryHouseButton")
		EGN.SetToolTip(primaryHouseButton, "Résidence Principale")
		primaryHouseButton:SetHandler("OnClicked", function(self) GH.TeleportToPrimaryHouse() end)
		
		--add fragment to scene
		local tlc =  WINDOW_MANAGER:GetControlByName("ARK_EGN_GH")
		local fragment = ZO_SimpleSceneFragment:New(tlc)
		GUILD_HOME_SCENE:AddFragment(fragment)
		
		--move lower icons
		local myKeep =  WINDOW_MANAGER:GetControlByName("ZO_GuildHomeKeep")
		myKeep:SetAnchor(TOPLEFT, guildHouseButton, BOTTOMLEFT, -40,5)	
	
	end
	
 	function GH.TeleportToGuildHouse()
		local guildMaster =  WINDOW_MANAGER:GetControlByName("ZO_GuildHomeGuildMaster") 
		JumpToHouse(guildMaster:GetText())  
	end
	
	function GH.TeleportToPrimaryHouse()
		local houseId = GetHousingPrimaryHouse()
		RequestJumpToHouse(houseId)
	end
	
end