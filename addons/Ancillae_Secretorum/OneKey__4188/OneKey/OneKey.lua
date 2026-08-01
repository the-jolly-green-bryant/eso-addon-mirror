ONEKEY = ONEKEY or {
	name = "OneKey",
	displayName = "One Key",
	author = "Ancillae_Secretorum",
	version = "0.1",
	variableVersion = 1,
	defaults = {}
}

function ONEKEY.PortToFavHouse()
	RequestJumpToHouse(GetHousingPrimaryHouse(), false)
end

function ONEKEY.LeavePartyAndInstance()
	GroupLeave()
	ExitInstanceImmediately()
end

-- Creates this addon's settings in Main Game Menu > Settings > Addons
function ONEKEY.CreateSettingsPanel()
	local strings = ONEKEY.localization.settings
	local panelData = {
		type = "panel",
		name = ONEKEY.name,
		displayName = ONEKEY.displayName .. strings.joke,
		author = ONEKEY.author,
		version = ONEKEY.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LibAddonMenu2:RegisterAddonPanel(ONEKEY.name, panelData)
	local optionsData = {
		[1] = {
			type = "divider"
		},
		[2] = {
			type = "description",
			text = strings.description
		},
		[3] = {
			type = "divider"
		}
	}
	LibAddonMenu2:RegisterOptionControls(ONEKEY.name, optionsData)
end

-- Create this addon's controls in Main Game Menu > Controls
function ONEKEY.CreateControls()
	local strings = ONEKEY.localization.settings
	ZO_CreateStringId("SI_BINDING_NAME_ONEKEY_LOGOUT", strings.logout)
	ZO_CreateStringId("SI_BINDING_NAME_ONEKEY_PORT_FAVOURITE_HOUSE", strings.portFavHouse)
	ZO_CreateStringId("SI_BINDING_NAME_ONEKEY_RELOADUI", strings.reloadUi)
	ZO_CreateStringId("SI_BINDING_NAME_ONEKEY_QUIT", strings.quit)
	ZO_CreateStringId("SI_BINDING_NAME_ONEKEY_LEAVE_PARTY_AND_INSTANCE", strings.leave)
end

-- Initializating the addon
function ONEKEY.OnAddOnLoaded(event, addonName)
	if addonName == ONEKEY.name then
		ONEKEY.savedVariables = ZO_SavedVars:NewAccountWide("OneKeySavedVariables", ONEKEY.variableVersion, nil, ONEKEY.defaults)
		ONEKEY.clientLanguage = GetCVar("language.2") or ""
		ONEKEY.CreateControls()
		ONEKEY.CreateSettingsPanel()
    	EVENT_MANAGER:UnregisterForEvent(ONEKEY.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(ONEKEY.name, EVENT_ADD_ON_LOADED, ONEKEY.OnAddOnLoaded)