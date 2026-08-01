--
-- create the panel and the options of the Settings (Settings -> addons)
--

-- If the global variable was created, continue with the execution
if not FsBountyDecay.fsAddonCreated then return end

function FsBountyDecay.setWindowDefault()
	FsBountyDecay.settings.x = FsBountyDecay.defaults.x
	FsBountyDecay.settings.y = FsBountyDecay.defaults.y
	FsBountyDecay.settings.point = FsBountyDecay.defaults.point
	FsBountyDecay.settings.relPoint = FsBountyDecay.defaults.relPoint
	FsBountyDecay.Timer:ClearAnchors()
	FsBountyDecay_Timer:SetAnchor(FsBountyDecay.settings.point, GuiRoot, FsBountyDecay.settings.relPoint, FsBountyDecay.settings.x, FsBountyDecay.settings.y)
end
--
-- Register the settings with the variables from FsSettings.lua
--
function FsBountyDecay.MakeMenu()
	local nameSettings = FsBountyDecay.name .. 'Settings'
	if( _G[nameSettings] ~= nil) then return end
	
	-- load the settings->addons menu library
	local menu = LibAddonMenu2
	
	local set = FsBountyDecay.settings

	-- the panel for the addons settings
	local panelSettings = {
		type = "panel",
		name = FsBountyDecay.menuName,
		displayName = FsBountyDecay.Utils.Colorize(FsBountyDecay.menuName),
		author = FsBountyDecay.author,
		version = FsBountyDecay.Utils.Colorize(FsBountyDecay.version, "AA00FF"),
		slashCommand = FsBountyDecay.slashCommandName .. 'conf',
		registerForRefresh = true,
		registerForDefaults = true
	}

	-- this addons entries in the addon settings
	local optionsSettings = {
		{
			type = "header",
			name = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_FSBOUNTDECAY_HEADER_GENERAL_SETTINGS)),
		},
		{
			type = "checkbox",
			name = GetString(SI_FSBOUNTDECAY_CHECKBOX_ISCLOCK),
			tooltip = GetString(SI_FSBOUNTDECAY_CHECKBOX_ISCLOCK_TOOLTIP),
			getFunc = function() return set.isClock end,
			setFunc = function(value)
					set.isClock = value
			end
		},
		{
			type = "checkbox",
			name = GetString(SI_FSBOUNTDECAY_CHECKBOX_SHOW_INFO),
			tooltip = GetString(SI_FSBOUNTDECAY_CHECKBOX_SHOW_INFO_TOOLTIP),
			getFunc = function() return set.showInfo end,
			setFunc = function(value)
					set.showInfo = value
			end
		},
		{
			type = "button",
			name = GetString(SI_FSBOUNTDECAY_BUTTON_DEFAULT),
			tooltip = GetString(SI_FSBOUNTDECAY_BUTTON_DEFAULT_TOOLTIP),
			func = function() FsBountyDecay.setWindowDefault() end,
			width = "half"
		}
	}
	
	menu:RegisterAddonPanel(nameSettings , panelSettings)
	menu:RegisterOptionControls(nameSettings, optionsSettings)
end
