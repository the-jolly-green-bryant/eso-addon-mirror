BSCGpQuitFix = BSCGpQuitFix or {}
local BSCGQF = BSCGpQuitFix

BSCGQF.Name = "BSCs-GampadQuitFix"

--https://esoapi.uesp.net/101045/src/ingame/mainmenu/gamepad/zo_mainmenu_gamepad.lua.html
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Init -- //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCGQF.init(event, addonName)	
	if addonName ~= BSCGQF.Name then
		return 
	end			
	EVENT_MANAGER:UnregisterForEvent(BSCGQF.Name, EVENT_ADD_ON_LOADED)	
	--	
	local logout = ZO_MENU_ENTRIES[ZO_MENU_MAIN_ENTRIES.LOG_OUT]
	local quit = ZO_MENU_ENTRIES[ZO_MENU_MAIN_ENTRIES.QUIT]
	
	
	ZO_MENU_ENTRIES[ZO_MENU_MAIN_ENTRIES.LOG_OUT] = quit
	ZO_MENU_ENTRIES[ZO_MENU_MAIN_ENTRIES.LOG_OUT].text = "BSC's "..GetString(SI_GAME_MENU_QUIT)
	ZO_MENU_ENTRIES[ZO_MENU_MAIN_ENTRIES.QUIT] = logout
	ZO_MENU_ENTRIES[ZO_MENU_MAIN_ENTRIES.QUIT].text = "BSC's "..GetString(SI_GAME_MENU_LOGOUT)
end
EVENT_MANAGER:RegisterForEvent(BSCGQF.Name, EVENT_ADD_ON_LOADED, BSCGQF.init)
