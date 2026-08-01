--
-- create the panel and the options of the Settings (Settings -> addons)
--

-- If the global variable was created, continue with the execution
if not FsTest.fsAddonCreated then return end
--
-- Register the settings with the variables from FsSettings.lua
--
function FsTest.MakeMenu()
	local nameSettings = FsTest.name .. 'Settings'
	if( _G[nameSettings] ~= nil) then return end
	
	-- load the settings->addons menu library
	local menu = LibAddonMenu2
	
	local set = FsTest.settings

	-- the panel for the addons settings
	local panelSettings = {
		type = "panel",
		name = FsTest.menuName,
		displayName = FsTest.Utils.Colorize(FsTest.menuName),
		author = FsTest.author,
		version = FsTest.Utils.Colorize(FsTest.version, "AA00FF"),
		slashCommand = FsTest.slashCommandName .. 'conf',
		registerForRefresh = true,
		registerForDefaults = true
	}

	-- this addons entries in the addon settings
	local optionsSettings = {
		{
			type = "header",
			name = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_FSTEST_HEADER_GENERAL_SETTINGS)),
			--width = "full",	--or "half" (optional)
		},
		{
			type = "slider",
			name = GetString(SI_GuildEvents_SLIDER_WINDOWBACKGROUD),
			tooltip = GetString(SI_GuildEvents_SLIDER_WINDOWBACKGROUD_TOOLTIP),
			min = 0,
			max = 100,
			step = 5,
			getFunc = function() return set.alpha end,
			setFunc = function(value) 
				set.alpha = value
				GuildEvents.window.bg:SetCenterColor(0, 0, 0, set.alpha / 100)
				GuildEvents.window.bg:SetEdgeColor(0, 0, 0, set.alpha / 100)
			end,
			default = 0,
			width = "half",	--or "half" (optional)
		},
		{
			type = "checkbox",
			name = GetString(SI_GuildEvents_CHECKBOX_TITLE),
			tooltip = GetString(SI_GuildEvents_CHECKBOX_TITLE_TOOLTIP),
			getFunc = function() return set.showtitle end,
			setFunc = function(value)
					GuildEvents.ShowTitle(value) 
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_GuildEvents_CHECKBOX_WINDOW),
			tooltip = GetString(SI_GuildEvents_CHECKBOX_WINDOW_TOOLTIP),
			getFunc = function() return set.shown end,
			setFunc = function(value)
				set.shown = value
			end,
		},
		{
			type = "button",
			name = "Button",
			tooltip = "tooltip...",
			func = function()  GuildEvents.Utils.PrintMsgColorize('button') end,
			warning = "Will need to reload the UI.",	--(optional)
		},
		{
			type = "description",
			title = "Others",	--(optional)
			--title = nil,	--(optional)
			text = "Others Options.",
			width = "full",	--or "half" (optional)
		},
		{
			type = "dropdown",
			name = "My Dropdown",
			tooltip = "Dropdown's tooltip text.",
			choices = {"table", "of", "choices"},
			getFunc = function() return "of" end,
			setFunc = function(var) print(var) end,
			width = "half",	--or "half" (optional)
			warning = "Will need to reload the UI.",	--(optional)
		},
		{
			type = "custom",
			reference = nameSettings .. "CustomControl",	--unique name for your control to use as reference
			refreshFunc = function(customControl) end,	--(optional) function to call when panel/controls refresh
			width = "half",	--or "half" (optional)
		},
		{
			type = "submenu",
			name = "Submenu Title",
			tooltip = "My submenu tooltip",	--(optional)
			controls = {
				[1] = {
					type = "checkbox",
					name = "My Checkbox",
					tooltip = "Checkbox's tooltip text.",
					getFunc = function() return true end,
					setFunc = function(value) GuildEvents.Utils.PrintMsgColorize(value) end,
					width = "half",	--or "half" (optional)
					warning = "Will need to reload the UI.",	--(optional)
				},
				[2] = {
					type = "colorpicker",
					name = "My Color Picker",
					tooltip = "Color Picker's tooltip text.",
					getFunc = function() return 1, 0, 0, 1 end,	--(alpha is optional)
					setFunc = function(r,g,b,a) print(r, g, b, a) end,	--(alpha is optional)
					width = "half",	--or "half" (optional)
					warning = "warning text",
				},
				[3] = {
					type = "editbox",
					name = "My Editbox",
					tooltip = "Editbox's tooltip text.",
					getFunc = function() return "this is some text" end,
					setFunc = function(text) print(text) end,
					isMultiline = false,	--boolean
					width = "half",	--or "half" (optional)
					warning = "Will need to reload the UI.",	--(optional)
					default = "",	--(optional)
				},
			},
		},
		{
			type = "texture",
			image = "EsoUI\\Art\\ActionBar\\abilityframe64_up.dds",
			imageWidth = 64,	--max of 250 for half width, 510 for full
			imageHeight = 64,	--max of 100
			tooltip = "Image's tooltip text.",	--(optional)
			width = "half",	--or "half" (optional)
		}
}
	
	menu:RegisterAddonPanel(nameSettings , panelSettings)
	menu:RegisterOptionControls(nameSettings, optionsSettings)
end
--
-- Function that show/hide the title
--
function GuildEvents.ShowTitle(value)
	GuildEvents.settings.showtitle = value
	GuildEvents.window.title:SetHidden(not value)
	if (value) then
		GuildEvents.window.zone:ClearAnchors()
		GuildEvents.window.zone:SetAnchor(TOP, GuildEvents.window.title, BOTTOM, 0, 5)
	else
		GuildEvents.window.zone:ClearAnchors()
		GuildEvents.window.zone:SetAnchor(TOP, GuildEvents.window, TOP, 0, 5)
	end
end
