local BLS = {}
local database
local LAM = LibAddonMenu2

BLS.name = "BurningLanguageSelector"
BLS.version = 1

--------------------
-- Change Setting --
--------------------
function SettingsChange(lang)
	df("language changed to : %s", lang)
	database.lang = lang -- Change value of Saved Variable
	zo_callLater(function()			--------------------------------------------
		SetCVar("language.2", lang) -- Change Language and ReloadUI for Apply --
		ReloadUI()					--------------------------------------------
	end, 500)
end

---------------
-- LAM Menu --
---------------
local panelData = {
	type = "panel",
	name = "Burning Language Menu",
	displayName  = "Burning Language Menu",
	author = "IBurningTV",
	version = "1.0",
	registerForRefresh = true,
	registerForDefault = true,
}

local optionsData = {
	[1] = {
		type = "dropdown",
        name = "Language Selector",
        tooltip = "Select your language",
        choices = {"French","English","German","Russian"},
        getFunc = function()
        	if(database.lang == "fr") then return "French"
        	elseif(database.lang == "en") then return "English"
			elseif(database.lang == "de") then return "German"
			elseif(database.lang == "ru") then return "Russian" end end,
        setFunc = function(var) --d(var) end,
        	if(var == "French") then SettingsChange("fr")
        	elseif(var == "English") then SettingsChange("en")
        	elseif(var == "German") then SettingsChange("de")
        	elseif(var == "Russian") then SettingsChange("ru") end end,

        width = "half",
        warning = "Will need to reload the UI.",
	},
}

----------
-- Init --
----------
function  BLS:Initialize()
 	EVENT_MANAGER:RegisterForEvent(BLS.name, EVENT_PLAYER_ACTIVATED, BLS.OnPlayerActivated)
 	LAM:RegisterAddonPanel("BLS_Setting", panelData)		---------------------------
 	LAM:RegisterOptionControls("BLS_Setting", optionsData)	-- Register SettingPanel --
end															---------------------------


------------
-- Events --
------------
function BLS.OnPlayerActivated(_, initial)
    EVENT_MANAGER:UnregisterForEvent(BLS.name, EVENT_PLAYER_ACTIVATED)
    if(initial) then
        database.needsReload = true
        SetCVar("language.2",database.lang)
    elseif(database.needsReload) then
        database.needsReload = false
        ReloadUI()
    end
end

function BLS.OnAddOnLoaded(event,addonName)
	if(addonName == BLS.name) then 
		-- default SavedVariable
		local defaults = {
			needsReload = false,
			lang = "en",
		}
		-- Fetch the saved variables
		database = ZO_SavedVars:NewAccountWide("BLS_DATA", BLS.version, nil, defaults)
		BLS:Initialize() end
end

EVENT_MANAGER:RegisterForEvent(BLS.name, EVENT_ADD_ON_LOADED, BLS.OnAddOnLoaded)