-- Copyright (c) 2014 User Froali from ESOUI.com
-- All Rights Reserved. If you want to use arts of my AddOns for your own work, please contact me first!

TI = {}
TI.version = 1.5
TI.varsVersion = 8
-- version also contained in global\setttings.lua function TI.createMenu, as well as README

-- Initialization
function TI.Initialize(eventCode, addonName)
	if(addonName ~= "ThurisazGuildInfo") then return end
	TI.vars = ZO_SavedVars:NewAccountWide("ThI_savedVars", TI.varsVersion, nil , TI.defaults , nil)

	zo_callLater(function()
		TI.SCANNER.Initialize()
		TI.createMenu()

		TI.ROSTER.Initialize()
		TI.FRIEND.Initialize()

	end, 1000); -- Start initialization after 1 second to lower load on UI reload
end

function TI.OnPlayerReady(eventCode, ...)
	--if(addonName ~= "ThurisazGuildInfo") then return end
	TI.ANNOUNCES.Initialize()
	EVENT_MANAGER:UnregisterForEvent( "ThurisazGuildInfo" , EVENT_PLAYER_ACTIVATED);
end
EVENT_MANAGER:RegisterForEvent( "ThiIni" , EVENT_ADD_ON_LOADED , TI.Initialize )
EVENT_MANAGER:RegisterForEvent( "ThurisazGuildInfo" , EVENT_PLAYER_ACTIVATED , TI.OnPlayerReady )
