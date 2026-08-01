-- LCM Demo: sample settings menu exercising every LibConsoleMenu control type.

LCMDemo = LCMDemo or {}
local Addon = LCMDemo

Addon.name = "LCMDemo"
Addon.displayName = "LCM Demo"
Addon.version = "1.0.6"

Addon.defaults = {
	enabled = true,
	updateRate = 1.0,
	updateFrequency = 5,
	profile = "balanced",
	difficultyMode = "adventurer",
	featureTags = { "ui", "combat" },
	playerTag = "Demo",
	showAlerts = true,
	alertSound = true,
	combatOnly = false,
	opacity = 80,
	windowOpacity = 0.8,
	accentColor = { 0.2, 0.75, 1.0, 1 },
	warningColor = { 1.0, 0.35, 0.2, 1 },
	statusIcon = 1,
	atlasIcon = 1,
	nestedNote = "Ready",
	combatPriority = "normal",
	debugLogging = false,
}

local ICON_CHOICES = {
	"/esoui/art/inventory/gamepad/gp_inventory_icon_all.dds",
	"/esoui/art/inventory/gamepad/gp_inventory_icon_currencies.dds",
	"/esoui/art/currency/gamepad/gp_alliancePoints.dds",
	"/esoui/art/currency/gamepad/gp_telvar.dds",
	"/esoui/art/icons/icon_emptyslot.dds",
}

-- Small stock sheet used to show atlas iconpicker mode (2x2).
local ATLAS_TEXTURE = "/esoui/art/buttons/gamepad/console/navoptions_arrowstrip.dds"
local ATLAS_SIZE_X = 2
local ATLAS_SIZE_Y = 2

local function CopyDefaults()
	local sv = Addon.sv
	for key, value in pairs(Addon.defaults) do
		if type(value) == "table" then
			local copy = {}
			for i = 1, #value do
				copy[i] = value[i]
			end
			sv[key] = copy
		else
			sv[key] = value
		end
	end
end

function Addon:ResetToDefaults()
	CopyDefaults()
end

local function BuildMenu()
	local LCM = LibConsoleMenu
	if not LCM or type(LCM.RegisterAddonPanel) ~= "function" then
		return
	end

	local sv = Addon.sv
	local defaults = Addon.defaults

	local function Toggle(name, key, disabled)
		return {
			type = "toggle",
			name = name,
			getFunc = function()
				return sv[key]
			end,
			setFunc = function(value)
				sv[key] = value
			end,
			default = defaults[key],
			disabled = disabled,
		}
	end

	LCM:RegisterAddonPanel(Addon.name, {
		type = "panel",
		name = Addon.displayName,
		author = "Fluazinam",
		version = Addon.version,
		registerForDefaults = true,
		registerForRefresh = true,
		centerSubmenus = true,
		resetFunc = function()
			Addon:ResetToDefaults()
		end,
	})

	LCM:RegisterOptionControls(Addon.name, {
		{ type = "header", name = "General" },
		{
			type = "description",
			text = "Sample panel for LibConsoleMenu. Values are saved but unused in-game.",
		},
		Toggle("Enable Demo Features", "enabled"),
		{
			type = "slider",
			name = "Update Rate",
			min = 0.5,
			max = 5,
			step = 0.5,
			getFunc = function()
				return sv.updateRate
			end,
			setFunc = function(value)
				sv.updateRate = value
			end,
			default = defaults.updateRate,
			disabled = function()
				return not sv.enabled
			end,
		},
		{
			type = "slider",
			name = "Update Frequency",
			tooltip = "How often to update in seconds",
			min = 1,
			max = 60,
			step = 1,
			format = "%.0f",
			unit = " seconds",
			bigStep = 10,
			getFunc = function()
				return sv.updateFrequency
			end,
			setFunc = function(value)
				sv.updateFrequency = value
			end,
			default = defaults.updateFrequency,
			disabled = function()
				return not sv.enabled
			end,
		},
		{
			type = "selector",
			name = "Profile",
			choices = { "Performance", "Balanced", "Quality" },
			choicesValues = { "performance", "balanced", "quality" },
			getFunc = function()
				return sv.profile
			end,
			setFunc = function(value)
				sv.profile = value
			end,
			default = defaults.profile,
			disabled = function()
				return not sv.enabled
			end,
		},
		{
			type = "dropdown",
			name = "Challenge Style",
			tooltip = "Open with A. Item tips update as you highlight options.",
			align = "left",
			choices = {
				{ name = "Adventurer", value = "adventurer", tooltip = "A gentler overland experience." },
				{ name = "Seasoned", value = "seasoned", tooltip = "Standard challenge for regular play." },
				{
					name = "Master",
					value = "master",
					tooltip = function()
						return "Highest challenge. Profile is currently: " .. tostring(sv.profile)
					end,
				},
				{ name = "Vestige", value = "vestige" },
			},
			getFunc = function()
				return sv.difficultyMode
			end,
			setFunc = function(value)
				sv.difficultyMode = value
			end,
			default = defaults.difficultyMode,
		},
		{
			type = "checklist",
			name = "Feature Tags",
			tooltip = "Open with A. Pick up to 3 tags (Home Tours style).",
			choices = {
				{ name = "UI", value = "ui", tooltip = "Interface and layout features." },
				{ name = "Combat", value = "combat", tooltip = "Combat feedback and alerts." },
				{ name = "Social", value = "social", tooltip = "Guild and group helpers." },
				{ name = "Economy", value = "economy", tooltip = "Currency and inventory tools." },
				{ name = "Housing", value = "housing", tooltip = "Home and furnishing tools." },
			},
			maxSelections = 3,
			noSelectionText = "No Tags",
			multiSelectionTextFormatter = "<<1[$d Tag/$d Tags]>>",
			getFunc = function()
				return sv.featureTags
			end,
			setFunc = function(values)
				sv.featureTags = values
			end,
			default = defaults.featureTags,
		},
		{
			type = "editbox",
			name = "Player Tag",
			getFunc = function()
				return sv.playerTag
			end,
			setFunc = function(value)
				sv.playerTag = value
			end,
			default = defaults.playerTag,
			maxChars = 24,
		},
		{
			type = "button",
			name = "Print Status",
			func = function()
				d(string.format(
					"[LCM Demo] enabled=%s profile=%s tag=%s",
					tostring(sv.enabled),
					tostring(sv.profile),
					tostring(sv.playerTag)
				))
			end,
		},

		{
			type = "submenu",
			name = "Appearance",
			icon = "/esoui/art/inventory/gamepad/gp_inventory_icon_all.dds",
			centerSubmenu = false,
			controls = {
				{ type = "header", name = "Colors", align = "center" },
				{
					type = "colorpicker",
					name = "Accent",
					getFunc = function()
						local c = sv.accentColor
						return c[1], c[2], c[3], c[4] or 1
					end,
					setFunc = function(r, g, b, a)
						sv.accentColor = { r, g, b, a or 1 }
					end,
					default = {
						defaults.accentColor[1],
						defaults.accentColor[2],
						defaults.accentColor[3],
						defaults.accentColor[4],
					},
				},
				{
					type = "colorpicker",
					name = "Warning",
					getFunc = function()
						local c = sv.warningColor
						return c[1], c[2], c[3], c[4] or 1
					end,
					setFunc = function(r, g, b, a)
						sv.warningColor = { r, g, b, a or 1 }
					end,
					default = {
						defaults.warningColor[1],
						defaults.warningColor[2],
						defaults.warningColor[3],
						defaults.warningColor[4],
					},
				},
				{ type = "header", name = "Icons", align = "left" },
				{
					type = "iconpicker",
					name = "Status Icon",
					choices = ICON_CHOICES,
					getFunc = function()
						return sv.statusIcon
					end,
					setFunc = function(index)
						sv.statusIcon = index
					end,
					default = defaults.statusIcon,
				},
				{
					type = "iconpicker",
					name = "Atlas Icon",
					texture = ATLAS_TEXTURE,
					atlasSizeX = ATLAS_SIZE_X,
					atlasSizeY = ATLAS_SIZE_Y,
					getFunc = function()
						return sv.atlasIcon
					end,
					setFunc = function(index)
						sv.atlasIcon = index
					end,
					default = defaults.atlasIcon,
				},
				{
					type = "slider",
					name = "Opacity",
					min = 0,
					max = 100,
					step = 5,
					getFunc = function()
						return sv.opacity
					end,
					setFunc = function(value)
						sv.opacity = value
					end,
					default = defaults.opacity,
				},
				{
					type = "slider",
					name = "Window Opacity",
					min = 0,
					max = 1,
					step = 0.01,
					format = "%.2f",
					unit = "%",
					getFunc = function()
						return sv.windowOpacity
					end,
					setFunc = function(value)
						sv.windowOpacity = value
					end,
					default = defaults.windowOpacity,
				},
			},
		},

		{
			type = "submenu",
			name = "Alerts",
			centerSubmenu = true,
			controls = {
				{ type = "header", name = "Behavior" },
				Toggle("Show Alerts", "showAlerts"),
				Toggle("Play Sound", "alertSound", function()
					return not sv.showAlerts
				end),
				Toggle("Combat Only", "combatOnly", function()
					return not sv.showAlerts
				end),
				{
					type = "description",
					title = "Note",
					text = "Centered submenu rows use the chip layout when centerSubmenus is on.",
				},
				{
					type = "submenu",
					name = "Combat Pack",
					centerSubmenu = true,
					controls = {
						{
							type = "selector",
							name = "Priority",
							choices = { "Low", "Normal", "High" },
							choicesValues = { "low", "normal", "high" },
							getFunc = function()
								return sv.combatPriority
							end,
							setFunc = function(value)
								sv.combatPriority = value
							end,
							default = defaults.combatPriority,
						},
						{
							type = "submenu",
							name = "Filters",
							centerSubmenu = true,
							controls = {
								{
									type = "editbox",
									name = "Filter Note",
									getFunc = function()
										return sv.nestedNote
									end,
									setFunc = function(value)
										sv.nestedNote = value
									end,
									default = defaults.nestedNote,
									maxChars = 32,
								},
								{
									type = "description",
									text = "Third-level page for nested submenu testing.",
								},
							},
						},
					},
				},
			},
		},

		{
			type = "submenu",
			name = "Advanced",
			icon = "/esoui/art/options/gamepad/gp_options_audio.dds",
			centerSubmenu = false,
			controls = {
				{ type = "header", name = "Diagnostics", align = "left" },
				Toggle("Debug Logging", "debugLogging"),
				{
					type = "button",
					name = "Clear Tag",
					func = function()
						sv.playerTag = defaults.playerTag
						d("[LCM Demo] Player tag restored to default.")
					end,
				},
				{
					type = "description",
					text = "Use Defaults on this page, or Reset All on the root page.",
				},
				{
					type = "toggle",
					name = "Locked Example",
					getFunc = function()
						return false
					end,
					setFunc = function()
					end,
					default = false,
					disabled = true,
				},
			},
		},
	})
end

local function OnAddOnLoaded(_, name)
	if name ~= Addon.name then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(Addon.name, EVENT_ADD_ON_LOADED)

	Addon.sv = ZO_SavedVars:NewAccountWide("LCMDemoSV", 1, nil, Addon.defaults)

	if IsConsoleUI() then
		BuildMenu()
	end
end

EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

