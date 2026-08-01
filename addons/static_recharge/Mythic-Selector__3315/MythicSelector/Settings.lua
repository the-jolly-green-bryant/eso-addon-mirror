MS = {}
local LAM = LibAddonMenu2

--[[----------------------------------------------
Settings Menu
----------------------------------------------]]--
function MS.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Mythic Selector",
		displayName = "|cFF8C1AMythic Selector|r",
		author = MS.author,
		feedback = "https://www.esoui.com/portal.php?&uid=6533",
		slashCommand = "/msmenu",
		registerForRefresh = true,
		version = MS.addonVersion,
	}

  local optionsData = {}
	local submenuData1 = {}

	table.insert(submenuData1, {
		type = "description",
		title = "",
    text = "|cFF8C1A/ms|r - Shows/hides the Mythic Selector window.\n|cFF8C1A/msmenu|r - Shows this menu.\n\nAdd items to the Mythic Selector window from the |cFF8C1Aright click menu on jewelry|r either in your inventory or already equipped.\n\nIn the Mythic Selector window:\n -|cFF8C1ALeft clicking|r on an item in the list will move it up one spot\n -|cFF8C1ARight clicking|r on an item in the list will remove it from the list\n\nCycle through your selected jewelry with the respective hotkeys in the controls menu.",
    width = "full",
	})

	table.insert(optionsData, {
		type = "submenu",
    name = "How to Use", -- or string id or function returning a string
    controls = submenuData1
	})

	table.insert(optionsData, {
		type = "header",
		name = "Equipped Jewelry Indicator",
	})

	table.insert(optionsData, {
		type = "description",
		title = "Account Wide Settings",
    text = "",
    width = "full",
	})
	
	table.insert(optionsData, {
		type = "slider",
		name = "Background opacity (%)",
		getFunc = function() return MS.SavedVars.indicatorBGAlpha end,
		setFunc = function(var) MS.SavedVars.indicatorBGAlpha = var MS_IndicatorBG:SetAlpha(var / 100) end,
		width = "full",
    min = 0,
    max = 100,
    step = 5,
    clampInput = true,
	})

	table.insert(optionsData, {
		type = "checkbox",
		name = "Only show on item change",
		getFunc = function() return MS.SavedVars.indicatorShowOnChange end,
		setFunc = function(var) MS.SavedVars.indicatorShowOnChange = var MS.ShowIndicator() end,
		width = "full",
    disabled = function() return not MS.SavedVars[MS.nameSpace].neckIndicator and not MS.SavedVars[MS.nameSpace].ringIndicator end,
	})
	
	table.insert(optionsData, {
		type = "slider",
		name = "Display time (s)",
		getFunc = function() return MS.SavedVars.indicatorFadeDelay end,
		setFunc = function(var) MS.SavedVars.indicatorFadeDelay = var end,
		width = "full",
    min = 0.5,
    max = 3,
    step = 0.5,
		decimal = 1,
    clampInput = true,
		disabled = function() return not MS.SavedVars.indicatorShowOnChange end,
	})

	table.insert(optionsData, {
		type = "slider",
		name = "Font Size",
		getFunc = function() return MS.SavedVars.fontSize end,
		setFunc = function(var) MS.SavedVars.fontSize = var MS.SetFontSize() end,
		width = "full",
    min = 10,
    max = 30,
    step = 1,
    clampInput = true,
	})

	table.insert(optionsData, {
		type = "slider",
		name = "Indicator Width",
		getFunc = function() return MS.SavedVars.width end,
		setFunc = function(var) MS.SavedVars.width = var MS_Indicator:SetWidth(var) end,
		width = "full",
    min = 100,
    max = 500,
    step = 10,
    clampInput = false,
	})

	table.insert(optionsData, {
		type = "checkbox",
		name = "Right Align Text",
		getFunc = function() return MS.SavedVars.rightAlign end,
		setFunc = function(var) MS.SavedVars.rightAlign = var MS.ChangeAlignment() end,
		width = "full",
	})

	table.insert(optionsData, {
		type = "divider",
    width = "full",
    alpha = 0.0,
	})

	table.insert(optionsData, {
		type = "description",
		title = "Profile Settings",
    text = "",
    width = "full",
	})
	
  table.insert(optionsData, {
		type = "checkbox",
		name = "Necklace indicator",
		getFunc = function() return MS.SavedVars[MS.nameSpace].neckIndicator end,
		setFunc = function(var) MS.SavedVars[MS.nameSpace].neckIndicator = var MS.ShowIndicator() end,
		width = "full",
	})
	
  table.insert(optionsData, {
		type = "checkbox",
		name = "Ring indicator",
		getFunc = function() return MS.SavedVars[MS.nameSpace].ringIndicator end,
		setFunc = function(var) MS.SavedVars[MS.nameSpace].ringIndicator = var MS.ShowIndicator() end,
		width = "full",
	})

	table.insert(optionsData, {
		type = "header",
		name = "Profile Management",
	})

	table.insert(optionsData, {
		type = "description",
		title = "",
    text = "Profiles include the saved jewelry lists.",
    width = "full",
	})

	table.insert(optionsData, {
		type = "checkbox",
		name = "Use Account Wide profile",
		getFunc = function() return MS.SavedVars[MS.characterID].useAccountWide end,
		setFunc = function(var) MS.SavedVars[MS.characterID].useAccountWide = var end,
		width = "full",
		requiresReload = true,
		warning = "Other profile management features will be disabled when this setting is enabled."
	})

	table.insert(optionsData, {
		type = "dropdown",
    name = "Profile selection",
    choices = MS.SavedVars.CharacterList,
    choicesValues = MS.SavedVars.CharacterIDList,
    getFunc = function() return nil end,
    setFunc = function(var) MS.targetProfile = var end,
    sort = "name-up",
    width = "full",
    scrollable = true,
    disabled = function() return MS.SavedVars[MS.characterID].useAccountWide end,
	})

	table.insert(optionsData, {
		type = "button",
    name = "Copy Profile",
    func = function() MS.CopyProfile(MS.targetProfile) end,
    width = "full",
    disabled = function() return MS.SavedVars[MS.characterID].useAccountWide end,
    isDangerous = true,
    warning = "Will copy all settings from the selected profile and reload UI.",
	})

	table.insert(optionsData, {
		type = "button",
    name = "Delete Profile",
    func = function() MS.DeleteProfile(MS.targetProfile) end,
    width = "full",
    disabled = function() return MS.SavedVars[MS.characterID].useAccountWide end,
    isDangerous = true,
    warning = "Will delete all settings from the selected profile and reload UI.",
	})

	table.insert(optionsData, {
		type = "header",
		name = "Misc.",
	})

	table.insert(optionsData, {
		type = "checkbox",
		name = "Chat Messages",
		getFunc = function() return MS.SavedVars.chatMessages end,
		setFunc = function(var) MS.SavedVars.chatMessages = var end,
		width = "half",
	})

  LAM:RegisterAddonPanel(MS.addonName, panelData)
	LAM:RegisterOptionControls(MS.addonName, optionsData)
end