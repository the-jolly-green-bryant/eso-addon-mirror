--[[------------------------------------------------------------------------------------------------
Title:          House Data Manager
Author:         Static_Recharge
Description:    Creates and controls the settings menu and related saved variables.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local LAM2 = LibAddonMenu2
local CM = CALLBACK_MANAGER
local WM = WINDOW_MANAGER


--[[------------------------------------------------------------------------------------------------
SDM Class Initialization
SDM    - Object containing all functions, tables, variables,and constants.
  |-  Parent    - Reference to parent object.
------------------------------------------------------------------------------------------------]]--
local SDM = ZO_InitializingObject:Subclass()


--[[------------------------------------------------------------------------------------------------
SDM:Initialize(Parent)
Inputs:				Parent 					- The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function SDM:Initialize(Parent)
  self.Parent = Parent
	-- Load previously selected profile into memory
	self:LoadProfile(self:GetParent().SavedVars.selectedProfile)
  self:CreateSettingsPanel()
end


--[[------------------------------------------------------------------------------------------------
SDM:CreateSettingsPanel()
Inputs:				None  
Outputs:			None
Description:	Creates and registers the settings panel with LibAddonMenu.
------------------------------------------------------------------------------------------------]]--
function SDM:CreateSettingsPanel()
	local panelData = {
		type = "panel",
		name = "Static's Recruiter",
		displayName = "|c66CCFFStatic's Recruiter|r",
		author = self:GetParent().author,
		website = "https://www.esoui.com/downloads/info3836-StaticsRecruiter.html",
		feedback = "https://www.esoui.com/portal.php?&uid=6533",
		slashCommand = "/srmenu",
		registerForRefresh = true,
		registerForDefaults = true,
		version = self:GetParent().addonVersion,
	}

  local optionsData = {}
	local i = 1

	optionsData[i] = {
		type = "header",
		name = "Guild Settings",
	}

	-- Auto fill guild information. Enters empty guilds as placeholders for people with fewer than MAX_GUILDS.
	i = i + 1
	for k = 1, MAX_GUILDS do
		if self:GetParent().GM.Data[k] then
			v = self:GetParent().GM.Data[k]
			optionsData[i] = {
				type = "submenu",
				name = v.name .. " [" .. k .. "]",
				reference = "StaticsRecruiter_GuildRecruitmentSubmenu_" .. k,
				disabled = false,
				controls = {
					[1] = {
						type = "editbox",
						name = "Recruitment Message",
						getFunc = function() return self:GetParent().SavedVars.Guilds[v.guildID].recruitMsg end,
						setFunc = function(text) self:GetParent().SavedVars.Guilds[v.guildID].recruitMsg = text end,
						isMultiline = true,
						isExtraWide = true,
						maxChars = self:GetParent().msgMaxChars,
						textType = TEXT_TYPE_ALL,
						width = "full",
						reference = "StaticsRecruiter_GuildRecruitmentMessageEditBox_" .. k,
						disabled = false,
						default = "",
					}
				}
			}
		else
			optionsData[i] = {
				type = "submenu",
				name = "Empty Guild Slot [" .. k .. "]",
				reference = "StaticsRecruiter_GuildRecruitmentSubmenu_" .. k,
				disabled = true,
				controls = {
					[1] = {
						type = "editbox",
						name = "Recruitment Message",
						getFunc = function() return nil end,
						setFunc = function(text) end,
						isMultiline = true,
						isExtraWide = true,
						maxChars = self:GetParent().msgMaxChars,
						textType = TEXT_TYPE_ALL,
						width = "full",
						reference = "StaticsRecruiter_GuildRecruitmentMessageEditBox_" .. k,
						disabled = true,
						default = "",
					}
				}
			}
		end
		i = i + 1
	end

	optionsData[i] = {
		type = "header",
		name = "Auto Travel Settings",
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Pay Wayshrine Fee",
    getFunc = function() return self:GetParent().SavedVars.payWayshrineFee end,
    setFunc = function(value) self:GetParent().SavedVars.payWayshrineFee = value end,
    tooltip = "If there are no friends or guild members online at the location you want to travel to the addon will fast travel you to the wayshrine there for the standard travel fee.",
    width = "full",
		default = self:GetParent().Defaults.payWayshrineFee,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Auto Fill Chat After Traveling",
    getFunc = function() return self:GetParent().SavedVars.autoFill end,
    setFunc = function(value) self:GetParent().SavedVars.autoFill = value end,
    tooltip = "Automatically fill the chatbox with guild recruit messages after traveling to the destination. You will still have to press Enter to actually post the recruitment message.",
    width = "full",
		default = self:GetParent().Defaults.autoFill,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
    name = "Auto Fill Recruit Message",
		choices = self:GetParent().GM:GetGuildNamesList(),
    choicesValues = self:GetParent().GM:GetGuildIDList(),
    getFunc = function() return self:GetParent().SavedVars.autoFillGuildSelection end,
    setFunc = function(value) self:GetParent().SavedVars.autoFillGuildSelection = value end,
    tooltip = "Automatically fill the chatbox with guild recruit messages after traveling to the destination. You will still have to press Enter to actually post the recruitment message.",
    width = "full",
		disabled = function() return not self:GetParent().SavedVars.autoFill end,
		reference = "StaticsRecruiter_GuildRecruitmentDropdownSelectionBox",
		default = nil,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Auto Travel to Next Zone After Posting",
    getFunc = function() return self:GetParent().SavedVars.autoNext end,
    setFunc = function(value) self:GetParent().SavedVars.autoNext = value end,
    tooltip = "If there are no friends or guild members online at the location you want to travel to the addon will fast travel you to the wayshrine there for the standard travel fee. Ensure you have the Wanderer champion point passive unlocked if applicable.",
    width = "full",
		default = self:GetParent().Defaults.autoNext,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Auto Retry on Zone Mismatch",
    getFunc = function() return self:GetParent().SavedVars.autoRetry end,
    setFunc = function(value) self:GetParent().SavedVars.autoRetry = value end,
    tooltip = "If the current zone doesn't match the intended destination the add-on will try again to port to the desired zone.",
    width = "full",
		default = self:GetParent().Defaults.autoRetry,
	}

	i = i + 1
	optionsData[i] = {
    type = "button",
    name = "Reset Auto Travel", 
    func = function() self:GetParent():ResetAutoTravelProgress() end,
    tooltip = "Reset auto travel progress to start from the beginning.",
    width = "full",
	}

	i = i + 1
	optionsData[i] = {
		type = "header",
		name = "Profile Management",
	}

	i = i + 1
	optionsData[i] = {
		type = "description",
    text = "The zone information from below is automatically saved to the selected profile. Profile management is disabled during auto recruiting.",
    width = "full",
	}

	i = i + 1
	optionsData[i] = {
    type = "editbox",
    name = "New Profile", -- or string id or function returning a string
    getFunc = function() return end,
    setFunc = function(text) end,
    isMultiline = false, -- boolean (optional)
    isExtraWide = false, -- boolean (optional)
    maxChars = 100, -- number (optional)
    textType = TEXT_TYPE_ALL, -- number (optional) or function returning a number. Valid TextType numbers: TEXT_TYPE_ALL, TEXT_TYPE_ALPHABETIC, TEXT_TYPE_ALPHABETIC_NO_FULLWIDTH_LATIN, TEXT_TYPE_NUMERIC, TEXT_TYPE_NUMERIC_UNSIGNED_INT, TEXT_TYPE_PASSWORD
    width = "half", -- or "half" (optional)
    reference = "StaticsRecruiter_CreateNewProfileEditBox", -- unique global reference to control (optional)
		disabled = function() return self:GetParent().autoStarted end,
	}

	i = i + 1
	optionsData[i] = {
    type = "button",
    name = "Create", 
    func = function() self:CreateProfile(self:GetParent().Controls.CreateNewProfileEditBox.editbox:GetText()) end,
    width = "half",
		disabled = function() return self:GetParent().autoStarted end,
		tooltip = "Creates a blank zone profile.",
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
    name = "Selected Profile",
		choices = self:GetProfileNamesList(),
    choicesValues = self:GetProfilesList(),
    getFunc = function() return self:GetParent().SavedVars.selectedProfile end,
    setFunc = function(value) self:LoadProfile(value) self:GetParent().SavedVars.selectedProfile = value end,
    width = "half",
		disabled = function() return self:GetParent().autoStarted end,
		reference = "StaticsRecruiter_SelectedProfileDropdownSelectionBox",
	}

	i = i + 1
	optionsData[i] = {
    type = "button",
    name = "Delete", 
    func = function() self:DeleteProfile(self:GetParent().SavedVars.selectedProfile) end,
    width = "half",
		tooltip = "Deletes the selected zone profile.",
		disabled = function() return self:GetParent().autoStarted end,
	}

	i = i + 1
	optionsData[i] = {
		type = "header",
		name = "Zones",
	}

	i = i + 1
	optionsData[i] = {
		type = "description",
    text = "Select the zones you want to travel to. The addon will check if you have houses/friends/guild mates in that zone before attempting to travel directly to a wayshrine. Zone toggling is disabled during auto recruiting.",
    width = "full",
	}

	i = i + 1
	optionsData[i] = {
    type = "dropdown",
    name = "Toggle All", -- or string id or function returning a string
    choices = {"-", "On", "Off"},
    choicesValues = {0, true, false}, -- if specified, these values will get passed to setFunc instead (optional)
    getFunc = function() return 0 end, -- if multiSelect is true the getFunc must return a table
    setFunc = function(var) if var ~= 0 then for index, value in pairs(self:GetParent().ZM.Data) do self:GetParent().Zones[value.zoneID] = var end end end,
    tooltip = "Force all of the below options to either on or off. Select '-' to do nothing.", -- or string id or function returning a string (optional)
    width = "full", -- or "half" (optional)
    scrollable = false, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
    multiSelect = false, -- boolean or function returning a boolean. If set to true you can select multiple entries at the list (optional)
		disabled = function() return self:GetParent().autoStarted end, -- or boolean (optional)
	}

	i = i + 1
	for k = 1, #self:GetParent().ZM.Data do
		local v = self:GetParent().ZM.Data[k]
		optionsData[i] = {
			type = "checkbox",
			name = v.name,
			getFunc = function() return self:GetParent().Zones[v.zoneID] end,
			setFunc = function(var) self:GetParent().Zones[v.zoneID] = var self:GetParent().SavedVars.Profiles[self:GetParent().SavedVars.selectedProfile].Zones[v.zoneID] = var end,
			width = "half",
			default = self:GetParent().Defaults.zoneCheckbox,
			disabled = function() return self:GetParent().autoStarted end, -- or boolean (optional)
		}
		i = i + 1
	end

	optionsData[i] = {
		type = "header",
		name = "Misc.",
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Chat Messages Enabled",
    getFunc = function() return self:GetParent().SavedVars.chatMsgEnabled end,
    setFunc = function(value) self:GetParent().SavedVars.chatMsgEnabled = value end,
    tooltip = "Disables ALL chat messages from this add-on.",
    width = "half",
		default = self:GetParent().Defaults.chatMsgEnabled,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Debugging Mode",
    getFunc = function() return self:GetParent().SavedVars.debugMode end,
    setFunc = function(value) self:GetParent().SavedVars.debugMode = value end,
    tooltip = "Turns on extra messages for the purposes of debugging. Not intended for normal use.",
    width = "half",
		default = self:GetParent().Defaults.debugMode,
	}

	local function LAMPanelCreated(panel)
		if panel ~= self:GetParent().LAMSettingsPanel then return end
		self:GetParent().LAMReady = true
		self:GetParent().Controls = {
			GuildSelectionDropdown = WM:GetControlByName("StaticsRecruiter_GuildRecruitmentDropdownSelectionBox"),
			GuildSubMenu = {},
			GuildEditBox = {},
			CreateNewProfileEditBox = WM:GetControlByName("StaticsRecruiter_CreateNewProfileEditBox"),
			SelectedProfileDropdown = WM:GetControlByName("StaticsRecruiter_SelectedProfileDropdownSelectionBox"),
		}
		for i = 1, 5 do
			table.insert(self:GetParent().Controls.GuildSubMenu, WM:GetControlByName("StaticsRecruiter_GuildRecruitmentSubmenu_" .. i))
			table.insert(self:GetParent().Controls.GuildEditBox, WM:GetControlByName("StaticsRecruiter_GuildRecruitmentMessageEditBox_" .. i))
		end

		self:GetParent().GM:Update()
		self:Update()
	end

	local function LAMPanelOpened(panel)
		if panel ~= self:GetParent().LAMSettingsPanel then return end
		self:GetParent().GM:Update()
		self:Update()
	end

	self:GetParent().LAMSettingsPanel = LAM2:RegisterAddonPanel(self:GetParent().addonName .. "_LAM", panelData)
	CM:RegisterCallback("LAM-PanelControlsCreated", LAMPanelCreated)
	CM:RegisterCallback("LAM-PanelOpened", LAMPanelOpened)
	LAM2:RegisterOptionControls(self:GetParent().addonName .. "_LAM", optionsData)
end


--[[------------------------------------------------------------------------------------------------
SDM:Update()
Inputs:				None
Outputs:			None
Description:	Updates the settings panel in LibAddonMenu.
------------------------------------------------------------------------------------------------]]--
function SDM:Update()
	local parent = self:GetParent()
	if not parent.LAMReady then return end
	-- Update guild dropdown
	local control = parent.Controls.GuildSelectionDropdown
	control:UpdateChoices(self:GetParent().GM:GetGuildNamesList(), self:GetParent().GM:GetGuildIDList())
	control:UpdateValue(false, nil)
	-- Update guild recruitment info
	for i=1, 5 do
		local data = parent.GM.Data[i]
		if data then
			local id = data.guildID
			local var = parent.SavedVars.Guilds[id]
			control = parent.Controls.GuildSubMenu[i]
			control.data.name = data.name .. " [" .. i .. "]"
			control:UpdateValue()
			control.data.disabled = false
			control:UpdateDisabled()
			control = parent.Controls.GuildEditBox[i]
			control.data.getFunc = function() return var.recruitMsg end
			control.data.setFunc = function(value) var.recruitMsg = value end
			control:UpdateValue(false, nil)
			control.data.disabled = false
			control:UpdateDisabled()
		else
			control = parent.Controls.GuildSubMenu[i]
			control.data.name = "Empty Guild Slot [" .. i .. "]"
			control:UpdateValue()
			control.data.disabled = true
			control:UpdateDisabled()
			control = parent.Controls.GuildEditBox[i]
			control.data.getFunc = function() return nil end
			control.data.setFunc = function(value) end
			control:UpdateValue(false, nil)
			control.data.disabled = true
			control:UpdateDisabled()
		end
	end
	control = parent.Controls.SelectedProfileDropdown
	control:UpdateChoices(self:GetProfileNamesList(), self:GetProfilesList())
	control:UpdateValue(false, nil)
end


--[[------------------------------------------------------------------------------------------------
SDM:GetProfileNamesList()
Inputs:				None
Outputs:			Names       	- Table of names in order of index.
Description:	Returns a table of names for the purposes of creating drowpdown menus.
------------------------------------------------------------------------------------------------]]--
function SDM:GetProfileNamesList()
	local Names = {}
	for i,v in ipairs(self:GetParent().SavedVars.Profiles) do
		table.insert(Names, v.name)
	end
	return Names
end


--[[------------------------------------------------------------------------------------------------
SDM:GetProfilesList()
Inputs:				None
Outputs:			Profiles       	- Table of profiles in order of index.
Description:	Returns a table of profiles for the purposes of creating drowpdown menus.
------------------------------------------------------------------------------------------------]]--
function SDM:GetProfilesList()
	local Profiles = {}
	for i,v in ipairs(self:GetParent().SavedVars.Profiles) do
		table.insert(Profiles, i)
	end
	return Profiles
end


--[[------------------------------------------------------------------------------------------------
SDM:LoadProfile(profile)
Inputs:				profile 				- The profile to load.
Outputs:			None
Description:	Loads the selected profile.
------------------------------------------------------------------------------------------------]]--
function SDM:LoadProfile(profile)
	for i,v in pairs(self:GetParent().ZM.Data) do
		self:GetParent().Zones[v.zoneID] = self:GetParent().SavedVars.Profiles[profile].Zones[v.zoneID]
	end
	return Profiles
end


--[[------------------------------------------------------------------------------------------------
SDM:CreateProfile(name)
Inputs:				name 						- The profile to create.
Outputs:			None
Description:	Checks if the proposed profile already exists, if not then creates the new profile and
							selects it.
------------------------------------------------------------------------------------------------]]--
function SDM:CreateProfile(name)
	if name == nil or name == "" then self:GetParent():SendToChat("Invalid profile name.") return end
	for i,v in ipairs(self:GetParent().SavedVars.Profiles) do
		if v.name == name then self:GetParent():SendToChat(zo_strformat("Profile <<1>> already exists!", name)) return end
	end
	local new = {name = name, Zones = {}}
	table.insert(self:GetParent().SavedVars.Profiles, new)
	self:GetParent().SavedVars.selectedProfile = #self:GetParent().SavedVars.Profiles
	self:LoadProfile(self:GetParent().SavedVars.selectedProfile)
	self:Update()
end


--[[------------------------------------------------------------------------------------------------
SDM:DeleteProfile(profile)
Inputs:				name 						- The profile to delete.
Outputs:			None
Description:	Deletes the selected profile. There must always be at least one profile.
------------------------------------------------------------------------------------------------]]--
function SDM:DeleteProfile(profile)
	if #self:GetParent().SavedVars.Profiles == 1 then self:GetParent():SendToChat("Cannot delete last profile. Create another profile first.") return end
	table.remove(self:GetParent().SavedVars.Profiles, profile)
	self:GetParent().SavedVars.selectedProfile = 1
	self:LoadProfile(self:GetParent().SavedVars.selectedProfile)
	self:Update()
end


--[[------------------------------------------------------------------------------------------------
SDM:GetParent()
Inputs:				None
Outputs:			Parent          - The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function SDM:GetParent()
  return self.Parent
end


--[[------------------------------------------------------------------------------------------------
StaticsRecruiterInitSettingsDataManager(Parent)
Inputs:				Parent          - The parent object of the object to be created.
Outputs:			FDM             - The new object created.
Description:	Global function to create a new instance of this object.
------------------------------------------------------------------------------------------------]]--
function StaticsRecruiterInitSettingsDataManager(Parent)
	return SDM:New(Parent)
end