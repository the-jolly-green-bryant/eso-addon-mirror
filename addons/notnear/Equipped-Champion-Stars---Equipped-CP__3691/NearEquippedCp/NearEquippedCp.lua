NEAR_EC = {
    name 		= "NearEquippedCp",
	title 		= "Near's Equipped Champion Stars",
	version 	= "1.1.1",
	author 		= "|cCC99FFnotnear|r",
}
local addon = NEAR_EC

NEAR_EC.defaults = {
	accountwide = true,
	account = {
		show_all      = true,
		show_craft    = true,
		show_warfare  = true,
		show_fitness  = true,
		lockUI        = true,
		labelAnchors = {
			point = TOPLEFT,
			relativePoint = BOTTOMLEFT,
		},
		hide = {
			inMenu	 = true,
			inCombat = false,
		}
	},
	char = {}
}

local function Init()
	addon.RestorePos()
	addon.SetColors()
	addon.SetAnchors()
	addon.ShowByType()
	addon.lockUI()
	addon.GetAssigned()
	addon.UpdateText()

	-- Register slash commands
	addon.slash_commands.activateSlashCommands()

	-- Register events
	addon.events.register()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon loading
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(event, name)
	if name ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	NEAR_EC.ASV_main = ZO_SavedVars:NewAccountWide(addon.name .. "_Data", 2, "settings", addon.defaults, GetWorldName())
	local svm = NEAR_EC.ASV_main

	NEAR_EC.ASV = svm.account

	if not addon.ASV_main.accountwide then
		local charId = GetCurrentCharacterId()
		if svm.char[charId] == nil then svm.char[charId] = {} end -- if its the first time running this character create an empty table

		-- check for keys and copy default data if needed
		for key, value in pairs(addon.defaults.account) do
			if svm.char[charId][key] == nil then
				svm.char[charId][key] = value
			end
		end

		NEAR_EC.ASV = svm.char[charId]
	end

	Init()
	addon.SetupSettings()

end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
