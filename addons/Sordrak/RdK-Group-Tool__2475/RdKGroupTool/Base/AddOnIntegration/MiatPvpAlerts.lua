-- RdK Miat AddOn Integration
-- By @s0rdrak (PC / EU)
-- Not running Miats PvP Alerts AddOn Integration anymore as it did not really
-- fix the bug causing frame drops. Therefore, this module isn't active in any way anymore.

RdKGTool.addOnIntegration.mpa = RdKGTool.addOnIntegration.mpa or {}
local RdKGToolMpa = RdKGTool.addOnIntegration.mpa
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu

RdKGToolMpa.callbackName = RdKGTool.addonName .. "AOIMiatsPvpAlerts"

RdKGToolMpa.state = {}
RdKGToolMpa.state.initialized = false
RdKGToolMpa.state.registeredActivation = false

function RdKGToolMpa.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolMpa.callbackName, RdKGToolMpa.OnProfileChanged)
	RdKGToolMpa.state.initialized = true
	RdKGToolMpa.SetEnabled(RdKGToolMpa.mpaVars.enabled, RdKGToolMpa.mpaVars.enabledOnPlayerActivation)
end

function RdKGToolMpa.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.enabledOnPlayerActivation = false
	return defaults
end


function RdKGToolMpa.SetEnabled(enabled, enabledOnPlayerActivation)
	if RdKGToolMpa.state.initialized == true and enabled ~= nil and enabledOnPlayerActivation ~= nil then
		if enabled == true and RdKGToolMpa.mpaVars.enabled == false then
			RdKGToolMpa.ClearMiatsPvpAlertsVars()
		end
		RdKGToolMpa.mpaVars.enabled = enabled
		RdKGToolMpa.mpaVars.enabledOnPlayerActivation = enabledOnPlayerActivation
		if enabled == true and enabledOnPlayerActivation == true then
			if RdKGToolMpa.state.registeredActivation == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolMpa.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolMpa.OnPlayerActivation)
				RdKGToolMpa.state.registeredActivation = true
			end
		elseif enabled == true and enabledOnPlayerActivation == false then
			if RdKGToolMpa.state.registeredActivation == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolMpa.callbackName, EVENT_PLAYER_ACTIVATED)
				RdKGToolMpa.state.registeredActivation = false
			end
		elseif enabled == false then
			if RdKGToolMpa.state.registeredActivation == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolMpa.callbackName, EVENT_PLAYER_ACTIVATED)
				RdKGToolMpa.state.registeredActivation = false
			end
		end
	end
end

function RdKGToolMpa.ClearMiatsPvpAlertsVars()
	--d("Clear Miats Pvp Alerts Vars")
	if PVP_Alerts_Main_Table ~= nil and PVP_Alerts_Main_Table.SV ~= nil then
		if PVP_Alerts_Main_Table.playerNames ~= nil then
			PVP_Alerts_Main_Table.playerNames = {}
		end
		if PVP_Alerts_Main_Table.playerSpec ~= nil then
			PVP_Alerts_Main_Table.playerSpec = {}
		end
		if PVP_Alerts_Main_Table.namesToDisplay ~= nil then
			PVP_Alerts_Main_Table.namesToDisplay = {}
		end
		if PVP_Alerts_Main_Table.SV.CP ~= nil then
			PVP_Alerts_Main_Table.SV.CP = {}
		end
		if PVP_Alerts_Main_Table.SV.playersDB ~= nil then
			PVP_Alerts_Main_Table.SV.playersDB = {}
		end
		--d("vars cleared")

	else
		--d("no vars identified")
	end
end

--callbacks
function RdKGToolMpa.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then

		RdKGToolMpa.mpaVars = currentProfile.addOnIntegration.mpa
		RdKGToolMpa.SetEnabled(RdKGToolMpa.mpaVars.enabled, RdKGToolMpa.mpaVars.enabledOnPlayerActivation)
	end
end

function RdKGToolMpa.OnPlayerActivation(eventCode)
	if eventCode == EVENT_PLAYER_ACTIVATED then
		RdKGToolMpa.ClearMiatsPvpAlertsVars()
	end
end

--menu interaction
function RdKGToolMpa.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.MPAI_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.MPAI_ENABLED,
					getFunc = RdKGToolMpa.GetMpaEnabled,
					setFunc = RdKGToolMpa.SetMpaEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.MPAI_ONPLAYERACTIVATION,
					getFunc = RdKGToolMpa.GetMpaOnPlayerActivationEnabled,
					setFunc = RdKGToolMpa.SetMpaOnPlayerActivationEnabled
				},
				[3] = {
					type = "button",
					name = RdKGToolMenu.constants.MPAI_CLEAR_VARS,
					func = RdKGToolMpa.ClearMiatsPvpAlertsVars,
					width = "full"
				},
			}
		}
	}
	return menu
end

function RdKGToolMpa.GetMpaEnabled()
	return RdKGToolMpa.mpaVars.enabled
end

function RdKGToolMpa.SetMpaEnabled(value)
	RdKGToolMpa.SetEnabled(value, RdKGToolMpa.mpaVars.enabledOnPlayerActivation)
end

function RdKGToolMpa.GetMpaOnPlayerActivationEnabled()
	return RdKGToolMpa.mpaVars.enabledOnPlayerActivation
end

function RdKGToolMpa.SetMpaOnPlayerActivationEnabled(value)
	RdKGToolMpa.SetEnabled(RdKGToolMpa.mpaVars.enabled, value)
end