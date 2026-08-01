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
local FL = FRIENDS_LIST
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER


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
Inputs:				Parent 					- The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function Settings:Initialize(Parent)
  self.Parent = Parent
	self.eventSpace = "SSFSettings"

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
		name = "Static's Social Features",
		displayName = "|cFF6600Static's Social Features|r",
		author = Parent.author,
		website = "https://www.esoui.com/downloads/info4239-StaticsSocialFeatures.html",
		feedback = "https://www.esoui.com/portal.php?&uid=6533",
		slashCommand = "/ssfmenu",
		registerForRefresh = true,
		registerForDefaults = true,
		version = Parent.addonVersion,
	}

  local optionsData = {}
	local controls = {}
	local i = 1
	local k = 1

	optionsData[i] = {
		type = "header",
		name = "Friends List",
	}

	i = i + 1
	optionsData[i] = {
		type = "description",
    text = "You can add or remove friends from your Fav list by right clicking on their name in the friends list.",
    width = "full",
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Show Fav Friends at Top",
    getFunc = function() return Parent.SV.favFriendsTop end,
    setFunc = function(value)
			Parent.SV.favFriendsTop = value
			if value == false then
				FL.currentSortKey = "status"
			end
			FL:RefreshFilters()
		end,
    tooltip = "Shows your Fav friends at the top of your friends list at all times.",
    width = "full",
		default = Parent.Defaults.favFriendsTop,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Shared Guild Info", -- or string id or function returning a string
		choices = Parent.AllFavNone:GetChoices(),
		choicesValues = Parent.AllFavNone:GetValues(), -- if specified, these values will get passed to setFunc instead (optional)
		getFunc = function() return Parent.SV.sharedGuilds end, -- if multiSelect is true the getFunc must return a table
		setFunc = function(var) Parent.SV.sharedGuilds = var end, -- if multiSelect is true the setFunc's var must be a table
		tooltip = "Displays which guilds you share with the highlighted friend.",
		width = "full", -- or "half" (optional)
		scrollable = false, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
		default = Parent.Defaults.sharedGuilds, -- default value or function that returns the default value (optional)
		multiSelect = false, -- boolean or function returning a boolean. If set to true you can select multiple entries at the list (optional)
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Shared Guild Info in Group",
    getFunc = function() return Parent.SV.sharedGuildsGroup end,
    setFunc = function(value) Parent.SV.sharedGuildsGroup = value end,
    tooltip = "Displays which guilds you share with the highlighted group member.",
    width = "full",
		default = Parent.Defaults.sharedGuildsGroup,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Offline Group Invite", -- or string id or function returning a string
		choices = Parent.AllFavNone:GetChoices(),
		choicesValues = Parent.AllFavNone:GetValues(), -- if specified, these values will get passed to setFunc instead (optional)
		getFunc = function() return Parent.SV.groupInvite end, -- if multiSelect is true the getFunc must return a table
		setFunc = function(var) Parent.SV.groupInvite = var end, -- if multiSelect is true the setFunc's var must be a table
		tooltip = "Allows you to attempt to send group invite requests to friends showing as offline.",
		width = "full", -- or "half" (optional)
		scrollable = false, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
		default = Parent.Defaults.groupInvite, -- default value or function that returns the default value (optional)
		multiSelect = false, -- boolean or function returning a boolean. If set to true you can select multiple entries at the list (optional)
	}

	i = i + 1
	optionsData[i] = {
		type = "iconpicker",
		name = "Fav Icon", -- or string id or function returning a string
		choices = Parent.IconTextures,
		getFunc = function() return Parent.SV.favIconTexture end,
		setFunc = function(icon) Parent.SV.favIconTexture = icon Parent.Lists:UpdateFavIcon() end,
		maxColumns = 5, -- number of icons in one row (optional)
		visibleRows = 3, -- number of visible rows (optional)
		iconSize = 32, -- size of the icons (optional)
		width = "full", --or "half" (optional)
		default = Parent.Defaults.favIconTexture, -- default value or function that returns the default value (optional)
	}

	i = i + 1
	optionsData[i] = {
		type = "slider",
		name = "Icon Size (%)",
		getFunc = function() return Parent.SV.favIconSize end,
		setFunc = function(value) Parent.SV.favIconSize = value Parent.Lists:UpdateFavIcon() end,
		min = 50,
		max = 150,
		step = 5,
		clampInput = true,
		decimals = 0,
		autoSelect = false,
		readOnly = false,
		width = "full", -- or "half" (optional)
		default = Parent.Defaults.favIconSize,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Inherit Text Color",
    getFunc = function() return Parent.SV.favIconInheritColor end,
    setFunc = function(value) Parent.SV.favIconInheritColor = value Parent.Lists:UpdateFavIcon() end,
    tooltip = "Makes the icon match the color of the text in the friends list.",
    width = "full",
		default = Parent.Defaults.favIconInheritColor,
	}

	i = i + 1
	optionsData[i] = {
		type = "header",
		name = "Player Status",
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "AFK Timeout",
    getFunc = function() return Parent.SV.afkTimerEnabled end,
    setFunc = function(value) Parent.SV.afkTimerEnabled = value if value then Parent.Status:StartAFKTimerAgain() end end,
    tooltip = "If enabled, switches you to Away after the timeout. Also automatically switches you back to Online when activity is detected.",
    width = "full",
		default = Parent.Defaults.afkTimerEnabled,
	}

	i = i + 1
	optionsData[i] = {
		type = "slider",
		name = "AFK Timeout (s)",
		getFunc = function() return Parent.SV.afkTimeout end,
		setFunc = function(value) Parent.SV.afkTimeout = value end,
		min = 30,
		max = 1200,
		step = 1,
		clampInput = false,
		decimals = 0,
		autoSelect = true,
		readOnly = false,
		width = "full", -- or "half" (optional)
		disabled = function() return not Parent.SV.afkTimerEnabled end,
		default = Parent.Defaults.afkTimeout,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Offline Timeout",
    getFunc = function() return Parent.SV.offlineTimerEnabled end,
    setFunc = function(value) Parent.SV.offlineTimerEnabled = value end,
    tooltip = "If enabled, switches you to Online after the timeout. Usefull if you forget to turn yourself Online often. Disabling while the timer is running will cause it to stop. Relog to re-enable.",
    width = "full",
		default = Parent.Defaults.offlineTimerEnabled,
	}

	i = i + 1
	optionsData[i] = {
		type = "slider",
		name = "Offline Timeout (m)",
		getFunc = function() return Parent.SV.offlineTimeout end,
		setFunc = function(value) Parent.SV.offlineTimeout = value end,
		tooltip = "Changes to this will take effect on the next login.",
		min = 5,
		max = 30,
		step = 1,
		clampInput = false,
		decimals = 0,
		autoSelect = true,
		readOnly = false,
		width = "full", -- or "half" (optional)
		disabled = function() return not Parent.SV.offlineTimerEnabled end,
		default = Parent.Defaults.offlineTimeout,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
		name = "Account Wide Override",
		getFunc = function() return Parent.SV.accountOverrideEnabled end,
		setFunc = function(value) Parent.SV.accountOverrideEnabled = value end,
		width = "Full",
		tooltip = "When enabled, all characters will use the same settings. Disable to set indivually for each character.",
		default = Parent.Defaults.accountOverrideEnabled,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Account Wide Status", -- or string id or function returning a string
		choices = Parent.PlayerStatus:GetChoices(),
		choicesValues = Parent.PlayerStatus:GetValues(), -- if specified, these values will get passed to setFunc instead (optional)
		getFunc = function() return Parent.SV.accountOverride end, -- if multiSelect is true the getFunc must return a table
		setFunc = function(var) Parent.SV.accountOverride = var end, -- if multiSelect is true the setFunc's var must be a table
		width = "full", -- or "half" (optional)
		scrollable = false, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
		default = Parent.Defaults.accountOverride, -- default value or function that returns the default value (optional)
		multiSelect = false, -- boolean or function returning a boolean. If set to true you can select multiple entries at the list (optional)
		disabled = function() return not Parent.SV.accountOverrideEnabled end,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
		name = "Login",
		getFunc = function() return Parent.SV.accountOverrideLogin end,
		setFunc = function(value) Parent.SV.accountOverrideLogin = value end,
		width = "half",
		tooltip = "Force the selected status on character login.",
		disabled = function() return Parent.SV.accountOverride == Parent.PlayerStatus.disabled or not Parent.SV.accountOverrideEnabled end,
		default = Parent.Defaults.accountOverrideLogin,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
		name = "Logout",
		getFunc = function() return Parent.SV.accountOverrideLogout end,
		setFunc = function(value) Parent.SV.accountOverrideLogout = value end,
		width = "half",
		tooltip = "Force the selected status on character logout.",
		disabled = function() return Parent.SV.accountOverride == Parent.PlayerStatus.disabled or not Parent.SV.accountOverrideEnabled end,
		default = Parent.Defaults.accountOverrideLogout,
	}

	controls[k] = {
		type = "description",
    text = "If enabled, forces your player status for the specific characters.",
    width = "full",
	}

	for key, char in ipairs(Parent.SV.Characters) do
		k = k + 1
		local subcontrols = {}
		local j = 1
		subcontrols[j] = {
			type = "dropdown",
			name = "Status", -- or string id or function returning a string
			choices = Parent.PlayerStatus:GetChoices(),
			choicesValues = Parent.PlayerStatus:GetValues(), -- if specified, these values will get passed to setFunc instead (optional)
			getFunc = function() return char.charOverride end, -- if multiSelect is true the getFunc must return a table
			setFunc = function(var) char.charOverride = var end, -- if multiSelect is true the setFunc's var must be a table
			width = "full", -- or "half" (optional)
			scrollable = false, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
			default = Parent.Defaults.charOverride, -- default value or function that returns the default value (optional)
			multiSelect = false, -- boolean or function returning a boolean. If set to true you can select multiple entries at the list (optional)
		}

		j = j + 1
		subcontrols[j] = {
			type = "checkbox",
			name = "Login",
			getFunc = function() return char.charOverrideLogin end,
			setFunc = function(value) char.charOverrideLogin = value end,
			width = "half",
			tooltip = "Force the selected status on character login.",
			disabled = function() return char.charOverride == Parent.PlayerStatus.Disabled end,
			default = Parent.Defaults.charOverrideLogin,
		}

		j = j + 1
		subcontrols[j] = {
			type = "checkbox",
			name = "Logout",
			getFunc = function() return char.charOverrideLogout end,
			setFunc = function(value) char.charOverrideLogout = value end,
			width = "half",
			tooltip = "Force the selected status on character logout.",
			disabled = function() return char.charOverride == Parent.PlayerStatus.Disabled end,
			default = Parent.Defaults.charOverrideLogout,
		}

		controls[k] = {
			type = "submenu",
			name = char.name,
			controls = subcontrols,
		}			
	end

	i = i + 1
	optionsData[i] = {
		type = "submenu",
		name = "Character Status",
		controls = controls,
		disabled = function() return Parent.SV.accountOverrideEnabled end,
		tooltip = function() if Parent.SV.accountOverrideEnabled then return "Disable Account Wide Overide to select per character status." end end,
	}

	i = i + 1
	optionsData[i] = {
		type = "header",
		name = "Notifications",
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Notification Type", -- or string id or function returning a string
		choices = Parent.NotificationTypes:GetChoices(),
		choicesValues = Parent.NotificationTypes:GetValues(), -- if specified, these values will get passed to setFunc instead (optional)
		getFunc = function() return Parent.SV.notificationType end, -- if multiSelect is true the getFunc must return a table
		setFunc = function(var) Parent.SV.notificationType = var end, -- if multiSelect is true the setFunc's var must be a table
		tooltip = "Choose where to redirect the notifications from this add-on. If directed to chat, chat messages must be enabled in Misc.",
		width = "full", -- or "half" (optional)
		scrollable = false, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
		default = Parent.Defaults.notificationType, -- default value or function that returns the default value (optional)
		multiSelect = false, -- boolean or function returning a boolean. If set to true you can select multiple entries at the list (optional)
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Notification Size", -- or string id or function returning a string
		choices = Parent.NotificationSizes:GetChoices(),
		choicesValues = Parent.NotificationSizes:GetValues(), -- if specified, these values will get passed to setFunc instead (optional)
		getFunc = function() return Parent.SV.notificationSize end, -- if multiSelect is true the getFunc must return a table
		setFunc = function(var) Parent.SV.notificationSize = var end, -- if multiSelect is true the setFunc's var must be a table
		tooltip = "Size of center screen notifications.",
		width = "full", -- or "half" (optional)
		scrollable = false, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
		default = Parent.Defaults.notificationSize, -- default value or function that returns the default value (optional)
		multiSelect = false, -- boolean or function returning a boolean. If set to true you can select multiple entries at the list (optional)
		disabled = function() return Parent.SV.notificationType ~= Parent.NotificationTypes["Center Screen"] end,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Notification Sound", -- or string id or function returning a string
		choices = Parent.NotificationSounds:GetChoices(),
		choicesValues = Parent.NotificationSounds:GetValues(), -- if specified, these values will get passed to setFunc instead (optional)
		getFunc = function() return Parent.SV.notificationSound end, -- if multiSelect is true the getFunc must return a table
		setFunc = function(var) Parent.SV.notificationSound = var PlaySound(Parent.SV.notificationSound) end, -- if multiSelect is true the setFunc's var must be a table
		width = "full", -- or "half" (optional)
		scrollable = false, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
		default = Parent.Defaults.notificationSound, -- default value or function that returns the default value (optional)
		multiSelect = false, -- boolean or function returning a boolean. If set to true you can select multiple entries at the list (optional)
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Offline Notice",
    getFunc = function() return Parent.SV.offlineNotice end,
    setFunc = function(value) Parent.SV.offlineNotice = value end,
    tooltip = "Notifies you on login if you're set to Offline.",
    width = "full",
		default = Parent.Defaults.offlineNotice,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Offline Timer Notice",
    getFunc = function() return Parent.SV.offlineTimerNotice end,
    setFunc = function(value) Parent.SV.offlineTimerNotice = value end,
    tooltip = "Notifies you when you are automatically set to Online via the Offline Timer.",
    width = "full",
		default = Parent.Defaults.offlineTimerNotice,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Whisper Notice",
    getFunc = function() return Parent.SV.whisperNotice end,
    setFunc = function(value) Parent.SV.whisperNotice = value end,
    tooltip = "Notifies you when you send a whisper and are offline.",
    width = "full",
		default = Parent.Defaults.whisperNotice,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "AFK Notice",
    getFunc = function() return Parent.SV.afkNotice end,
    setFunc = function(value) Parent.SV.afkNotice = value end,
    tooltip = "Notifies you when you are set to AFK or back to Online from AFK.",
    width = "full",
		default = Parent.Defaults.afkNotice,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Multi-Rider as Passenger Notice",
    getFunc = function() return Parent.SV.multiMountNotify end,
    setFunc = function(value) Parent.SV.multiMountNotify = value end,
		tooltip = "Shows a notification with the name of the person you mounted.",
    width = "full",
		default = Parent.Defaults.multiMountNotify,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Friend Status Messages", -- or string id or function returning a string
		choices = Parent.AllFavNone:GetChoices(), --{"All", "Fav Only", "None"},
		choicesValues = Parent.AllFavNone:GetValues(), -- if specified, these values will get passed to setFunc instead (optional)
		getFunc = function() return Parent.SV.friendMsg end, -- if multiSelect is true the getFunc must return a table
		setFunc = function(var) Parent.SV.friendMsg = var end, -- if multiSelect is true the setFunc's var must be a table
		tooltip = "Control which friend status messages are displayed.",
		width = "full", -- or "half" (optional)
		scrollable = false, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
		default = Parent.Defaults.friendMsg, -- default value or function that returns the default value (optional)
		multiSelect = false, -- boolean or function returning a boolean. If set to true you can select multiple entries at the list (optional)
		requiresReload = true, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Friend Status to Chat",
    getFunc = function() return Parent.SV.friendMsgChat end,
    setFunc = function(value) Parent.SV.friendMsgChat = value end,
    tooltip = "If disabled the friend notices will follow the notification settings above.",
    width = "full",
		default = Parent.Defaults.friendMsgChat,
		disabled = function() return Parent.SV.friendMsg == Parent.AllFavNone.None end,
	}

  i = i + 1
  optionsData[i] = {
		type = "header",
		name = "Mount Features",
	}

	i = i + 1
  optionsData[i] = {
		type = "description",
    text = "These settings are character specific.",
    width = "full",
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Auto Switch to Multi-Rider",
    getFunc = function() return Parent.CH.multiMountEnable end,
    setFunc = function(value) Parent.CH.multiMountEnable = value end,
    width = "full",
		default = Parent.CharDefaults.multiMountEnable,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Solo Mount", -- or string id or function returning a string
		choices = Parent.Mounts.SoloMount:GetChoices(), --{"All", "Fav Only", "None"},
		choicesValues = Parent.Mounts.SoloMount:GetValues(), -- if specified, these values will get passed to setFunc instead (optional)
		getFunc = function() return Parent.CH.soloMount end, -- if multiSelect is true the getFunc must return a table
		setFunc = function(var) Parent.CH.soloMount = var end, -- if multiSelect is true the setFunc's var must be a table
		tooltip = "Which solo mount to switch to.",
		width = "full", -- or "half" (optional)
		scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
		default = Parent.CharDefaults.soloMount, -- default value or function that returns the default value (optional)
		multiSelect = false, -- boolean or function returning a boolean. If set to true you can select multiple entries at the list (optional)
		requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
		disabled = function() return not Parent.CH.multiMountEnable end,
		reference = "SSF_SoloMountDropdown_LAM",
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Multi Mount", -- or string id or function returning a string
		choices = Parent.Mounts.MultiMount:GetChoices(), --{"All", "Fav Only", "None"},
		choicesValues = Parent.Mounts.MultiMount:GetValues(), -- if specified, these values will get passed to setFunc instead (optional)
		getFunc = function() return Parent.CH.multiMount end, -- if multiSelect is true the getFunc must return a table
		setFunc = function(var) Parent.CH.multiMount = var end, -- if multiSelect is true the setFunc's var must be a table
		tooltip = "Which multi mount to switch to.",
		width = "full", -- or "half" (optional)
		scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
		default = Parent.CharDefaults.multiMount, -- default value or function that returns the default value (optional)
		multiSelect = false, -- boolean or function returning a boolean. If set to true you can select multiple entries at the list (optional)
		requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
		disabled = function() return not Parent.CH.multiMountEnable end,
		reference = "SSF_MultiMountDropdown_LAM",
	}

	i = i + 1
  optionsData[i] = {
		type = "header",
		name = "Repped Guild",
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Use Account Wide Repped Guild",
    getFunc = function() return Parent.CH.reppedGuildAccountEnabled end,
    setFunc = function(value) Parent.CH.reppedGuildAccountEnabled = value Parent:ReppedGuildAccountWideUpdate() end,
    width = "full",
		tooltip = "When enabled, this character's repped guild will be set to the selected account wide repped guild.",
		default = Parent.CharDefaults.reppedGuildAccountEnabled,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Account Wide Repped Guild",
		choices = Parent.Guilds:GetChoices(),
		choicesValues = Parent.Guilds:GetValues(),
		getFunc = function() return Parent.SV.reppedGuildAccountSelection end,
		setFunc = function(var) Parent.SV.reppedGuildAccountSelection = var Parent:ReppedGuildAccountWideUpdate() end,
		width = "full",
		scrollable = false,
		default = Parent.Defaults.reppedGuildAccountSelection,
		multiSelect = false,
		requiresReload = false,
		reference = "SSF_ReppedGuildAccountWideDropdown_LAM",
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Marquee Enabled",
    getFunc = function() return Parent.CH.reppedGuildMarqueeEnabled end,
    setFunc = function(value) Parent.CH.reppedGuildMarqueeEnabled = value Parent:MarqueeUpdate() end,
    width = "full",
		tooltip = "The marquee rotates through the selected repped guilds on a timer. This setting overrides the Account Wide Repped Guild setting and is character specific.",
		default = Parent.CharDefaults.reppedGuildMarqueeEnabled,
	}

	i = i + 1
	optionsData[i] = {
		type = "slider",
		name = "Marquee Interval (m)",
		getFunc = function() return Parent.CH.reppedGuildMarqueeInterval end,
		setFunc = function(value) Parent.CH.reppedGuildMarqueeInterval = value Parent:MarqueeUpdate() end,
		tooltip = "How long before the repped guild will be changed to the next selection in minutes.",
		min = 0.5,
		max = 15,
		step = 0.5,
		clampInput = true,
		decimals = 1,
		autoSelect = true,
		readOnly = false,
		width = "full",
		disabled = function() return not Parent.CH.reppedGuildMarqueeEnabled end,
		default = Parent.CharDefaults.reppedGuildMarqueeInterval,
	}

	i = i + 1
	optionsData[i] = {
    type = "dropdown",
    name = "Marquee Guilds",
    choices = Parent.Guilds:GetChoices(),
    --choicesValues = Parent.Guilds:GetValues(),
    getFunc = function() return Parent.Guilds:GetSelectedChoicesByValues(Parent.CH.reppedGuildMarqueeSelections) end,
    setFunc = function(var) Parent.CH.reppedGuildMarqueeSelections = Parent.Guilds:GetSelectedValuesByChoices(var) Parent:MarqueeUpdate() end,
		tooltip = "Must select at least two options for the marquee to work.",
    width = "full", -- or "half" (optional)
    scrollable = false,
    disabled = function() return not Parent.CH.reppedGuildMarqueeEnabled end,
    default = Parent.CharDefaults.reppedGuildMarqueeSelections,
    reference = "SSF_ReppedGuildMarqueeDropdown_LAM",
    multiSelect = true,
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
		disabled = not Parent.SV.debugEnabled,
	}

	local function LAMPanelCreated(panel)
		if panel ~= Parent.LAMSettingsPanel then return end
		Parent.Controls = {
			SoloMDD = WM:GetControlByName("SSF_SoloMountDropdown_LAM"),
			MultiMDD = WM:GetControlByName("SSF_MultiMountDropdown_LAM"),
			RepGuildDD = WM:GetControlByName("SSF_ReppedGuildAccountWideDropdown_LAM"),
			MarqueeDD = WM:GetControlByName("SSF_ReppedGuildMarqueeDropdown_LAM"),
		}
		Parent.LAMReady = true
	end

	local function LAMPanelOpened(panel)
		if panel ~= Parent.LAMSettingsPanel then return end
		if not Parent.LAMReady then return end
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

	local C = Parent.Controls
	local M = Parent.Mounts
	local G = Parent.Guilds

	M:UpdateMountData()
	C.SoloMDD:UpdateChoices(M.SoloMount:GetChoices(), M.SoloMount:GetValues())
	C.SoloMDD:UpdateValue()
	C.MultiMDD:UpdateChoices(M.MultiMount:GetChoices(), M.MultiMount:GetValues())
	C.MultiMDD:UpdateValue()

	Parent:UpdateGuildList()
	C.RepGuildDD:UpdateChoices(G:GetChoices(), G:GetValues())
	C.RepGuildDD:UpdateValue()
	C.MarqueeDD:UpdateChoices(G:GetChoices(), G:GetValues())
	C.MarqueeDD:UpdateValue()
end


--[[------------------------------------------------------------------------------------------------
Settings:Changed()
Inputs:				None
Outputs:			None
Description:	Fired when the player first loads in after a settings reset is forced.
------------------------------------------------------------------------------------------------]]--
function Settings:Changed()
	local Parent = self:GetParent()
	if Parent.SV.settingsChanged then 
		Parent.Chat:Msg(zo_strformat("Static's Social Features updated to <<1>>. Settings have been reset.", Parent.addonVersion))
		Parent.SV.settingsChanged = false
	end
	EM:UnregisterForEvent(self.eventSpace, EVENT_PLAYER_ACTIVATED)
end


--[[------------------------------------------------------------------------------------------------
Settings:GetParent()
Inputs:				None
Outputs:			Parent          - The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function Settings:GetParent()
  return self.Parent
end


--[[------------------------------------------------------------------------------------------------
Global template assignment
------------------------------------------------------------------------------------------------]]--
StaticsSocialFeatures.Settings = Settings