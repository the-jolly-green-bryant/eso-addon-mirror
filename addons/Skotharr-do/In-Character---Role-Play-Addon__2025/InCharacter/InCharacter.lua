--[[
Title:   Main File
Version: 1.1.2
Author:  @Skotharr-do [PC/EU]
--]]

local function OnAddOnLoaded(event, addonName)
	if addonName ~= IC.Addon.NAME then
		return
	end
	-- unregister initialization callback to save performance
	EVENT_MANAGER:UnregisterForEvent(IC.Addon.NAME, EVENT_ADD_ON_LOADED)
	
	IC.AccountWide.Initialize()
	IC.CharacterWide.Initialize()
	IC.ReticleWindow.Create()
	IC.EditWindow.Create()
	IC.AddonMenu.Create()
	IC.RegisterForEvents()
end

-- register initialization callback
EVENT_MANAGER:RegisterForEvent(IC.Addon.NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)