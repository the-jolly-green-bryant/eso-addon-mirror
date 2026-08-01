--[[------------------------------------------------------------------------------------------------
Title:          Settings
Author:         Static_Recharge
Description:    Creates and controls the settings menu and related saved variables.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local LAM2 = LibAddonMenu2
local CM = CALLBACK_MANAGER
EM = EVENT_MANAGER


--[[------------------------------------------------------------------------------------------------
Settings Class Initialization
Settings    													            - Parent object containing all functions, tables, variables, constants and other data managers.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ :CreateSettingsPanel()													- Creates and registers the settings panel with LibAddonMenu.
├─ :Update()                											- Updates the settings panel in LibAddonMenu.
├─ :Changed()               							- Fired when the player first loads in after a settings reset is forced.
└─ :GetParent()                                   - Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
local Settings = {}


--[[------------------------------------------------------------------------------------------------
Settings:Initialize(Parent)
Inputs:				Parent 															- The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function Settings:Initialize(Parent)
  self.Parent = Parent
  self.eventSpace = "SLOSettings"

  self:CreateSettingsPanel()

  -- Event Registrations
	EM:RegisterForEvent(self.eventSpace, EVENT_PLAYER_ACTIVATED, function(...) self:Changed() end)

	self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
Settings:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function Settings:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
Settings:CreateSettingsPanel()
Inputs:				None  
Outputs:			None
Description:	Creates and registers the settings panel with LibAddonMenu.
------------------------------------------------------------------------------------------------]]--
function Settings:CreateSettingsPanel()
	local Parent = self:GetParent()
	local panelData = {
		type = "panel",
		name = "Static's Letter Opener",
		displayName = "|cFFFFFFStatic's Letter Opener|r",
		author = Parent.author,
		--website = "https://www.esoui.com/downloads/info3836-StaticsRecruiter.html",
		feedback = "https://www.esoui.com/portal.php?&uid=6533",
		slashCommand = "/slomenu",
		registerForRefresh = true,
		registerForDefaults = true,
		version = Parent.addonVersion,
	}

  local optionsData = {}
	local controls = {}
	local i = 1

  optionsData[i] = {
		type = "header",
		name = "Containers",
	}

  i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Open Surveys",
    getFunc = function() return Parent.SV.surveys end,
    setFunc = function(value) Parent.SV.surveys = value end,
    width = "full",
		default = Parent.Defaults.surveys,
	}

  i = i + 1
  optionsData[i] = {
		type = "checkbox",
    name = "Open Master Writs",
    getFunc = function() return Parent.SV.masterWrits end,
    setFunc = function(value) Parent.SV.masterWrits = value end,
    width = "full",
		default = Parent.Defaults.masterWrits,
	}

	i = i + 1
  optionsData[i] = {
		type = "checkbox",
    name = "Open Maps",
    getFunc = function() return Parent.SV.maps end,
    setFunc = function(value) Parent.SV.maps = value end,
    width = "full",
		default = Parent.Defaults.maps,
	}

  i = i + 1
  optionsData[i] = {
		type = "checkbox",
    name = "Open All",
    getFunc = function() return Parent.SV.openAll end,
    setFunc = function(value) Parent.SV.openAll = value end,
    tooltip = "If enabled, when one envelope of a particular type is opened, the add-on will attempt to open the whole stack.",
    width = "full",
		default = Parent.Defaults.openAll,
	}

  i = i + 1
  optionsData[i] = {
		type = "header",
		name = "Misc.",
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Chat Messages",
    getFunc = function() return Parent.SV.chatEnabled end,
    setFunc = function(value) Parent.SV.chatEnabled = value Parent.Chat:SetChatEnabled(value) end,
    tooltip = "Disables ALL chat messages from this add-on.",
    width = "half",
		default = Parent.Defaults.chatEnabled,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Debugging Mode",
    getFunc = function() return Parent.SV.debugEnabled end,
    setFunc = function(value) Parent.SV.debugEnabled = value Parent.Chat:SetDebugEnabled(value) end,
    tooltip = "Turns on extra messages for the purposes of debugging. Not intended for normal use. Must have chat messages enabled.",
    width = "half",
		default = Parent.Defaults.debugEnabled,
		disabled = not Parent.SV.chatEnabled,
	}

	local function LAMPanelCreated(panel)
		if panel ~= Parent.LAMSettingsPanel then return end
		Parent.LAMReady = true
		Parent.Controls = {}
		self:Update()
	end

	local function LAMPanelOpened(panel)
		if panel ~= Parent.LAMSettingsPanel then return end
		self:Update()
	end

	Parent.LAMSettingsPanel = LAM2:RegisterAddonPanel(Parent.addonName .. "_LAM", panelData)
	CM:RegisterCallback("LAM-PanelControlsCreated", LAMPanelCreated)
	CM:RegisterCallback("LAM-PanelOpened", LAMPanelOpened)
	LAM2:RegisterOptionControls(Parent.addonName .. "_LAM", optionsData)
end


--[[------------------------------------------------------------------------------------------------
Settings:Update()
Inputs:				None
Outputs:			None
Description:	Updates the settings panel in LibAddonMenu.
------------------------------------------------------------------------------------------------]]--
function Settings:Update()
	local Parent = self:GetParent()
	if not Parent.LAMReady then return end
end


--[[------------------------------------------------------------------------------------------------
Settings:Changed()
Inputs:				None
Outputs:			None
Description:	Sends a message the the settings have been reset.
------------------------------------------------------------------------------------------------]]--
function Settings:Changed()
	local Parent = self:GetParent()
	if not Parent.SV.settingsChanged then return end
	Parent.SV.settingsChanged = false
	Parent.Chat:Msg("Settings have been reset, please ensure they are to your preference.")
end


--[[------------------------------------------------------------------------------------------------
Settings:GetParent()
Inputs:				None
Outputs:			Parent          										- The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function Settings:GetParent()
  return self.Parent
end

--[[------------------------------------------------------------------------------------------------
Global template assignment
------------------------------------------------------------------------------------------------]]--
StaticsLetterOpener.Settings = Settings