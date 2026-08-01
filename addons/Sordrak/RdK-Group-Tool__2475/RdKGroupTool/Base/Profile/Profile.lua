-- RdK Group Tool Profile
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.profile = RdKGTool.profile or {}
local RdKGToolProfile = RdKGTool.profile
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem

RdKGToolProfile.profileChangeListeners = {}

RdKGToolProfile.constants = RdKGToolProfile.constants or {}
RdKGToolProfile.constants.DEFAULT_PROFILE = "Default"
RdKGToolProfile.constants.PREFIX = "Profile"
RdKGToolProfile.constants.references = RdKGToolProfile.constants.references or {}
RdKGToolProfile.constants.references.PROFILE_ERROR_MESSAGE_DESCRIPTION = "RdKGTool.menu.ProfileErrorMessageDescription"
RdKGToolProfile.constants.references.PROFILE_SELECTED_PROFILE_DROPDOWN = "RdKGTool.menu.ProfileSelectedProfileDropdown"

RdKGToolProfile.state = RdKGToolProfile.state or {}
RdKGToolProfile.state.newProfileName = ""

--initialization
function RdKGToolProfile.Initialize(accountVars, charVars)
	RdKGToolProfile.savedVars = {}
	RdKGToolProfile.savedVars.acc = accountVars
	RdKGToolProfile.savedVars.char = charVars
	--RdKGToolProfile.savedVars.char.test = "test"
end

function RdKGToolProfile.GetAccountDefaults()
	local defaults = {}
	defaults.profiles = {}
	defaults.profiles[1] = {}
	defaults.profiles[1].name = RdKGToolProfile.constants.DEFAULT_PROFILE
	return defaults
end

function RdKGToolProfile.GetCharacterDefaults()
	local defaults = {}
	defaults.selectedProfile = RdKGToolProfile.constants.DEFAULT_PROFILE
	return defaults
end



--util
function RdKGToolProfile.GetCharacterVars()
	return RdKGToolProfile.savedVars.char
end

function RdKGToolProfile.GetSelectedProfile()
	local currentProfile = nil
	for i = 1, #RdKGToolProfile.savedVars.acc.profiles do
		if RdKGToolProfile.savedVars.acc.profiles[i].name == RdKGToolProfile.savedVars.char.selectedProfile then
			currentProfile = RdKGToolProfile.savedVars.acc.profiles[i]
			break
		end
	end
	if currentProfile == nil then
		currentProfile = RdKGToolProfile.savedVars.acc.profiles[1]
		RdKGToolProfile.savedVars.char.selectedProfile = currentProfile.name
		
	end
	return currentProfile
end

function RdKGToolProfile.ProfileExists(value)
	local profileExists = false
	for i = 1, #RdKGToolProfile.savedVars.acc.profiles do
		if RdKGToolProfile.savedVars.acc.profiles[i].name == value then
			profileExists = true
			break
		end
	end
	return profileExists
end

function RdKGToolProfile.GetAllAccProfiles()
	return RdKGToolProfile.savedVars.acc.profiles
end

function RdKGToolProfile.GetSpecificAccProfile(name)
	local profile = nil
	for i = 1, #RdKGToolProfile.savedVars.acc.profiles do
		if RdKGToolProfile.savedVars.acc.profiles[i].name == name then
			profile = RdKGToolProfile.savedVars.acc.profiles[i]
			break
		end
	end
	return profile
end

function RdKGToolProfile.AddNewProfileData(profile)
	if profile ~= nil then
		profile.name = zo_strtrim(profile.name)
		if RdKGToolProfile.ProfileExists(profile.name) == false then
			table.insert(RdKGToolProfile.savedVars.acc.profiles, profile)
			RdKGToolProfile.UpdateProfileSection()
		end
	end
end

--profile change listener code
function RdKGToolProfile.AddProfileChangeListener(moduleName, callback, update)
	if RdKGToolProfile.ProfileChangeListenerExists(moduleName) == false then
		local newModule = {}
		newModule.moduleName = moduleName
		newModule.callback = callback
		table.insert(RdKGToolProfile.profileChangeListeners, newModule)
		if (update == true or update == nil) and type(callback) == "function" then
			callback(RdKGToolProfile.GetSelectedProfile())
		end
	else
		RdKGToolChat.SendChatMessage("Listener already exists: " .. moduleName, RdKGToolProfile.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
	end
end

function RdKGToolProfile.RemoveProfileChangeListener(moduleName)
	for i = 1, #RdKGToolProfile.profileChangeListeners do
		if RdKGToolProfile.profileChangeListeners[i].moduleName == moduleName then
			table.remove(RdKGToolProfile.profileChangeListeners, i)
			i = i - 1 
		end
	end
end

function RdKGToolProfile.ProfileChangeListenerExists(moduleName)
	local retVal = false
	for i = 1, #RdKGToolProfile.profileChangeListeners do
		if RdKGToolProfile.profileChangeListeners[i].moduleName == moduleName then
			retVal = true
			break
		end
	end
	return retVal
end

function RdKGToolProfile.NotifyChangeListeners(moduleName)
	local currentProfile = RdKGToolProfile.GetSelectedProfile()
	if moduleName == nil then
		for i = 1, #RdKGToolProfile.profileChangeListeners do
			if type(RdKGToolProfile.profileChangeListeners[i].callback) == "function" then
				RdKGToolProfile.profileChangeListeners[i].callback(currentProfile)
			end
		end
	else
		for i = 1, #RdKGToolProfile.profileChangeListeners do
			if RdKGToolProfile.profileChangeListeners[i].name == moduleName and type(RdKGToolProfile.profileChangeListeners[i].callback) == "function" then
				RdKGToolProfile.profileChangeListeners[i].callback(currentProfile)
				break
			end
		end
	end
end

--Menu Interaction
function RdKGToolProfile.GetMenu()
	local menu = {
		[1] = {
			type = "header",
			name = RdKGToolMenu.constants.PROFILE_HEADER,
			width = "full",
		},
		[2] = {
			type = "dropdown",
			name = RdKGToolMenu.constants.PROFILE_SELECTED_PROFILE,
			tooltip = RdKGToolMenu.constants.PROFILE_SELECTED_PROFILE_TOOLTIP,
			choices = RdKGToolProfile.GetAvailableProfiles(),
			getFunc = RdKGToolProfile.GetSelectedProfileName,
			setFunc = RdKGToolProfile.SetSelectedProfileName,
			width = "full",
			--requiresReload = true,
			reference = RdKGToolProfile.constants.references.PROFILE_SELECTED_PROFILE_DROPDOWN
		},
		[3] = {
			type = "button",
			name = RdKGToolMenu.constants.PROFILE_REMOVE_PROFILE,
			func = RdKGToolProfile.RemoveSelectedProfile,
			width = "full"
		},
		[4] = {
			type = "editbox",
			name = RdKGToolMenu.constants.PROFILE_NEW_PROFILE,
			getFunc = RdKGToolProfile.GetNewProfileName,
			setFunc = RdKGToolProfile.SetNewProfileName,
			isMultiline = false,
			width = "full",
			default = ""
		},
		[5] = {
			type = "button",
			name = RdKGToolMenu.constants.PROFILE_ADD_PROFILE,
			func = RdKGToolProfile.AddNewProfile,
			width = "full"
		},
		[6] = {
			type = "button",
			name = RdKGToolMenu.constants.PROFILE_CLONE_PROFILE,
			func = RdKGToolProfile.CloneProfile,
			width = "full"
		},
		[7] = {
			type = "description",
			title = nil,
			text = "",
			width = "full",
			reference = RdKGToolProfile.constants.references.PROFILE_ERROR_MESSAGE_DESCRIPTION
		}
	}
	RdKGToolProfile.state.dropDownMenuEntry = menu[2]
	return menu
end

function RdKGToolProfile.GetAvailableProfiles()
	local profiles = {}
	local acc = RdKGToolProfile.savedVars.acc.profiles
	for i = 1, #acc do
		profiles[i] = acc[i].name
	end
	return profiles
end

function RdKGToolProfile.GetSelectedProfileName()
	return RdKGToolProfile.savedVars.char.selectedProfile
end

function RdKGToolProfile.SetSelectedProfileName(value)
	if RdKGToolProfile.ProfileExists(value) == true then
		RdKGToolProfile.savedVars.char.selectedProfile = value
		RdKGToolProfile.NotifyChangeListeners()
	end
end

function RdKGToolProfile.AddNewProfile()
	local value = RdKGToolProfile.state.newProfileName
	--d(value)
	if RdKGToolProfile.ProfileExists(value) == true then
		RdKGToolMenu.SetErrorMessage(RdKGToolProfile.constants.references.PROFILE_ERROR_MESSAGE_DESCRIPTION, RdKGToolMenu.constants.PROFILE_EXISTS)
		--d("error message set")
	else
		if value ~= nil and zo_strtrim(value) ~= "" then
			local newProfile = RdKGTool.CreateCleanProfile()
			newProfile.name = value
			table.insert(RdKGToolProfile.savedVars.acc.profiles, newProfile)
		end
		RdKGToolProfile.UpdateProfileSection()
	end
end

function RdKGToolProfile.CloneProfile()
	local value = RdKGToolProfile.state.newProfileName
	--d(value)
	if RdKGToolProfile.ProfileExists(value) == true then
		RdKGToolMenu.SetErrorMessage(RdKGToolProfile.constants.references.PROFILE_ERROR_MESSAGE_DESCRIPTION, RdKGToolMenu.constants.PROFILE_EXISTS)
		--d("error message set")
	else
		local oldProfile = RdKGToolProfile.GetSelectedProfile()
		if value ~= nil and zo_strtrim(value) ~= "" and oldProfile ~= nil then
			--local newProfile = RdKGTool.CreateCleanProfile()
			local newProfile = {}
			
			RdKGToolUtil.DeepCopy(newProfile, oldProfile)
			newProfile.name = value
			table.insert(RdKGToolProfile.savedVars.acc.profiles, newProfile)
		end
		RdKGToolProfile.UpdateProfileSection()
	end
end

function RdKGToolProfile.RemoveSelectedProfile()
	if RdKGToolProfile.savedVars.char.selectedProfile == RdKGToolProfile.constants.DEFAULT_PROFILE then
		RdKGToolMenu.SetErrorMessage(RdKGToolProfile.constants.references.PROFILE_ERROR_MESSAGE_DESCRIPTION, RdKGToolMenu.constants.PROFILE_CANT_REMOVE_DEFAULT)
		--d("error message set")
	else
		local index = 0
		for i = 1, #RdKGToolProfile.savedVars.acc.profiles do
			if RdKGToolProfile.savedVars.acc.profiles[i].name == RdKGToolProfile.savedVars.char.selectedProfile then
				index = i
				break
			end
		end
		table.remove(RdKGToolProfile.savedVars.acc.profiles, index)
		index = index - 1
		if index >= 1 then
			RdKGToolProfile.savedVars.char.selectedProfile = RdKGToolProfile.savedVars.acc.profiles[index].name
		else
			RdKGToolProfile.savedVars.char.selectedProfile = RdKGToolProfile.constants.DEFAULT_PROFILE
		end
		RdKGToolProfile.NotifyChangeListeners()
		RdKGToolProfile.UpdateProfileSection()
	end
end

function RdKGToolProfile.UpdateProfileSection()
	--d("update profile section")
	RdKGToolProfile.state.newProfileName = ""
	RdKGToolMenu.SetErrorMessage(RdKGToolProfile.constants.references.PROFILE_ERROR_MESSAGE_DESCRIPTION, "")
	local dropdownControl = GetWindowManager():GetControlByName(RdKGToolProfile.constants.references.PROFILE_SELECTED_PROFILE_DROPDOWN)
	if dropdownControl ~= nil then
		dropdownControl:UpdateChoices(RdKGToolProfile.GetAvailableProfiles())
	else
		RdKGToolProfile.state.dropDownMenuEntry.choices = RdKGToolProfile.GetAvailableProfiles()
	end
end


function RdKGToolProfile.GetNewProfileName()
	return RdKGToolProfile.state.newProfileName
end

function RdKGToolProfile.SetNewProfileName(value)
	RdKGToolProfile.state.newProfileName = value
end
