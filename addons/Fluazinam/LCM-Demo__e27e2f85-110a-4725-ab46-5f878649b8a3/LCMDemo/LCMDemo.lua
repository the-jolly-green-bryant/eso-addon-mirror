-- LCM Demo: realistic settings menu that exercises every LibConsoleMenu control
-- and field. Root uses options-style centering; left-aligned sections showcase
-- leftIndent vs leftFlush layout on the root page.

LCMDemo = LCMDemo or {}
local Addon = LCMDemo

Addon.name = "LCMDemo"
Addon.title = "LCM Demo"
Addon.version = "1.1.7"

Addon.defaults = {
	-- General
	enabled = true,
	-- Toggles
	labelYesNo = true,
	labelEnabledDisabled = true,
	labelShowHide = true,
	labelCharacterAccount = false,
	labelDawnDusk = true,
	labelCustomScope = true,
	-- Sliders
	updateRate = 1.0,
	updateFrequency = 5,
	opacity = 80,
	windowOpacity = 0.85,
	-- Edit
	playerTag = "Demo",
	pinCode = "1234",
	bioBlurb = "",
	secretCode = "hunter2",
	inviteHint = "",
	-- Selectors
	profile = "balanced",
	uiTheme = "ember",
	sortMode = "name",
	-- Dropdowns
	difficultyMode = "seasoned",
	travelStyle = "mount",
	lockedDropdown = "beta",
	-- Checklists
	featureTags = { "ui", "combat" },
	craftSkills = { "blacksmithing" },
	lockedChecklist = { "a" },
	-- Color pickers
	accentColor = { 0.2, 0.75, 1.0, 1 },
	warningColor = { 1.0, 0.35, 0.2, 1 },
	lockedColor = { 0.45, 0.45, 0.45, 1 },
	-- Icon pickers
	statusIcon = 1,
	atlasIcon = 1,
	atlasSubsetIcon = 1,
	lockedIcon = 2,
	-- Into the Nest
	showAlerts = true,
	alertSound = true,
	combatOnly = false,
	combatPriority = "normal",
	filterNote = "Ready",
	showGold = true,
	showAlliancePoints = true,
	showTelVar = false,
	showWritVouchers = true,
	goldThreshold = 10000,
	apThreshold = 50000,
	telVarThreshold = 1000,
	writThreshold = 50,
	-- Left indent
	navTheme = "dark",
	navChecklist = { "ui" },
	navNote = "ok",
	-- Left flush
	toolsTheme = "system",
	toolsChecklist = { "map" },
	toolsNote = "flush",
}

local ICON_CHOICES = {
	"/esoui/art/inventory/gamepad/gp_inventory_icon_all.dds",
	"/esoui/art/inventory/gamepad/gp_inventory_icon_currencies.dds",
	"/esoui/art/currency/gamepad/gp_alliancePoints.dds",
	"/esoui/art/currency/gamepad/gp_telvar.dds",
	"/esoui/art/icons/icon_emptyslot.dds",
}

-- Small stock sheet for atlas iconpicker (2×2).
local ATLAS_TEXTURE = "/esoui/art/buttons/gamepad/console/navoptions_arrowstrip.dds"

local function CopyDefaults()
	local sv = Addon.sv
	for key, value in pairs(Addon.defaults) do
		if type(value) == "table" then
			local copy = {}
			if value[1] ~= nil then
				for i = 1, #value do
					copy[i] = value[i]
				end
			else
				for k, v in pairs(value) do
					copy[k] = v
				end
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

local function OnAddOnLoaded(_, name)
	if name ~= Addon.name then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(Addon.name, EVENT_ADD_ON_LOADED)

	Addon.sv = ZO_SavedVars:NewAccountWide("LCMDemoSV", 2, nil, Addon.defaults)

	if not IsConsoleUI() then
		return
	end

	local LCM = LibConsoleMenu
	if not LCM or type(LCM.CreateAddonMenu) ~= "function" then
		return
	end

	local sv = Addon.sv
	local defaults = Addon.defaults

	local menu = LCM:CreateAddonMenu(Addon.name, {
		title = Addon.title,
		author = "Fluazinam",
		version = Addon.version,
		category = "UTILITY",
		enableDefaults = true,
		enableReset = true,
		collapseToggleLabels = true,
		collapseSliderLabels = true,
		resetFunc = function()
			Addon:ResetToDefaults()
		end,
		header = {
			messageText = "Sample menu for LibConsoleMenu. Scroll to try each control type.",
		},
	})

	menu:AddOptions({
		---------------------------------------------------------------------------
		-- Root: control-type order (toggle → … → button), then alignment, then submenus.
		---------------------------------------------------------------------------
		{
			type = "section",
			name = "General", align = "center",
			options = {
			{
				type = "toggle",
				name = "Enable LCM Demo Features",
				tooltip = "Master switch. Some settings below lock when this is off.",
				getFunc = function()
					return sv.enabled
				end,
				setFunc = function(value)
					sv.enabled = value
				end,
				default = defaults.enabled,
			},
			},
		},

		{
			type = "section",
			name = "Toggles", align = "center",
			options = {
			{
				type = "toggle",
				name = "Yes / No",
				preset = LCM.TogglePresets.YES_NO,
				getFunc = function()
					return sv.labelYesNo
				end,
				setFunc = function(value)
					sv.labelYesNo = value
				end,
				default = defaults.labelYesNo,
			},
			{
				type = "toggle",
				name = "Enabled / Disabled",
				preset = LCM.TogglePresets.ENABLED_DISABLED,
				getFunc = function()
					return sv.labelEnabledDisabled
				end,
				setFunc = function(value)
					sv.labelEnabledDisabled = value
				end,
				default = defaults.labelEnabledDisabled,
			},
			{
				type = "toggle",
				name = "Show / Hide",
				preset = LCM.TogglePresets.SHOW_HIDE,
				getFunc = function()
					return sv.labelShowHide
				end,
				setFunc = function(value)
					sv.labelShowHide = value
				end,
				default = defaults.labelShowHide,
			},
			{
				type = "toggle",
				name = "Character / Account",
				preset = LCM.TogglePresets.CHARACTER_ACCOUNT,
				getFunc = function()
					return sv.labelCharacterAccount
				end,
				setFunc = function(value)
					sv.labelCharacterAccount = value
				end,
				default = defaults.labelCharacterAccount,
			},
			{
				type = "toggle",
				name = "Dawn / Dusk",
				tooltip = "Custom values, not a preset: labels read Dawn and Dusk.",
				values = {
					on = "Dawn",
					off = "Dusk",
				},
				getFunc = function()
					return sv.labelDawnDusk
				end,
				setFunc = function(value)
					sv.labelDawnDusk = value
				end,
				default = defaults.labelDawnDusk,
				disabled = function()
					return not sv.enabled
				end,
			},
			{
				type = "toggle",
				name = "Always Locked",
				tooltip = "Permanently locked so you can see the disabled look.",
				getFunc = function()
					return sv.labelCustomScope
				end,
				setFunc = function(value)
					sv.labelCustomScope = value
				end,
				default = defaults.labelCustomScope,
				disabled = true,
			},
			},
		},

		{
			type = "section",
			name = "Sliders", align = "center",
			options = {
			{
				type = "slider",
				name = "Update Rate",
				tooltip = "Refresh interval in seconds, in half-second steps.",
				min = 0.5,
				max = 5,
				step = 0.5,
				decimals = 1,
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
				tooltip = "Seconds between updates. L1 / R1 jump in larger steps.",
				min = 1,
				max = 60,
				step = 1,
				bigStep = 10,
				format = "%.0f",
				unit = " seconds",
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
				type = "slider",
				name = "HUD Opacity",
				min = 0,
				max = 100,
				step = 5,
				bigStep = 25,
				unit = "%",
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
			type = "section",
			name = "Edit", align = "center",
			options = {
			{
				type = "editbox",
				name = "Player Tag",
				tooltip = "Short label used in status messages.",
				getFunc = function()
					return sv.playerTag
				end,
				setFunc = function(value)
					sv.playerTag = value
				end,
				default = defaults.playerTag,
				maxInputCharacters = 24,
				textType = TEXT_TYPE_ALL,
			},
			{
				type = "editbox",
				name = "PIN Code",
				tooltip = "Digits only; letters are rejected.",
				getFunc = function()
					return sv.pinCode
				end,
				setFunc = function(value)
					sv.pinCode = value
				end,
				default = defaults.pinCode,
				maxInputCharacters = 8,
				textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
			},
			{
				type = "editbox",
				name = "Bio",
				tooltip = "multiLine field; Enter inserts a newline.",
				multiLine = true,
				placeholderText = "Write a short bio...",
				getFunc = function()
					return sv.bioBlurb
				end,
				setFunc = function(value)
					sv.bioBlurb = value
				end,
				default = defaults.bioBlurb,
				maxInputCharacters = 200,
				textType = TEXT_TYPE_ALL,
			},
			{
				type = "editbox",
				name = "Secret Code",
				tooltip = "Masked with isPassword (not TEXT_TYPE_PASSWORD).",
				isPassword = true,
				getFunc = function()
					return sv.secretCode
				end,
				setFunc = function(value)
					sv.secretCode = value
				end,
				default = defaults.secretCode,
				maxInputCharacters = 32,
				textType = TEXT_TYPE_ALL,
			},
			},
		},
		{
			type = "section",
			name = "Invite Code", align = "center",
			options = {
			{
				type = "editbox",
				placeholderText = "Enter code",
				tooltip = "Nameless row: omit name; label comes from header + placeholder.",
				textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
				maxInputCharacters = 6,
				getFunc = function()
					return sv.inviteHint
				end,
				setFunc = function(value)
					sv.inviteHint = value
				end,
				default = defaults.inviteHint,
			},
			},
		},

		{
			type = "section",
			name = "Selectors", align = "center",
			options = {
			{
				type = "selector",
				name = "Profile",
				tooltip = "Cycle with left/right. Labels can differ from the stored value.",
				choices = {
					{ name = "Performance", value = "performance" },
					{ name = "Balanced", value = "balanced" },
					{ name = "Quality", value = "quality" },
				},
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
				type = "selector",
				name = "UI Theme",
				tooltip = "Cosmetic theme for the demo UI.",
				choices = {
					{ name = "Ember", value = "ember" },
					{ name = "Frost", value = "frost" },
					{ name = "Moss", value = "moss" },
				},
				getFunc = function()
					return sv.uiTheme
				end,
				setFunc = function(value)
					sv.uiTheme = value
				end,
				default = defaults.uiTheme,
			},
			{
				type = "selector",
				name = "Sort Mode",
				choices = {
					{ name = "Name", value = "name" },
					{ name = "Level", value = "level" },
					{ name = "Recent", value = "recent" },
				},
				getFunc = function()
					return sv.sortMode
				end,
				setFunc = function(value)
					sv.sortMode = value
				end,
				default = defaults.sortMode,
			},
			{
				type = "selector",
				name = "Locked Selector",
				choices = {
					{ name = "One", value = "one" },
					{ name = "Two", value = "two" },
					{ name = "Three", value = "three" },
				},
				getFunc = function()
					return "two"
				end,
				setFunc = function()
				end,
				default = "two",
				disabled = true,
			},
			},
		},

		{
			type = "section",
			name = "Dropdown", align = "center",
			options = {
			{
				type = "dropdown",
				name = "Challenge Style",
				tooltip = "Open with A. Some options show their own tips when highlighted.",
				align = "center",
				choices = {
					{ name = "Adventurer", value = "adventurer", tooltip = "Gentler overland experience." },
					{ name = "Seasoned", value = "seasoned", tooltip = "Standard challenge for regular play." },
					{
						name = "Master",
						value = "master",
						tooltip = function()
							return "Highest challenge. Current profile: " .. tostring(sv.profile)
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
				type = "dropdown",
				name = "Travel Style",
				tooltip = "Open with A. Options here have no extra tips.",
				align = "center",
				choices = {
					{ name = "Mount", value = "mount" },
					{ name = "Boat", value = "boat" },
					{ name = "Wayshrine", value = "wayshrine" },
				},
				getFunc = function()
					return sv.travelStyle
				end,
				setFunc = function(value)
					sv.travelStyle = value
				end,
				default = defaults.travelStyle,
			},
			{
				type = "dropdown",
				name = "Locked Dropdown",
				align = "center",
				choices = {
					{ name = "Alpha", value = "alpha" },
					{ name = "Beta", value = "beta" },
					{ name = "Gamma", value = "gamma" },
				},
				getFunc = function()
					return sv.lockedDropdown
				end,
				setFunc = function()
				end,
				default = defaults.lockedDropdown,
				disabled = true,
			},
			},
		},

		{
			type = "section",
			name = "Checklist", align = "center",
			options = {
			{
				type = "checklist",
				name = "Feature Tags",
				tooltip = "Pick up to three tags. Empty and multi-select wording is customized.",
				align = "center",
				choices = {
					{ name = "UI", value = "ui", tooltip = "Interface and layout." },
					{ name = "Combat", value = "combat", tooltip = "Combat feedback and alerts." },
					{ name = "Social", value = "social", tooltip = "Guild and group helpers." },
					{ name = "Economy", value = "economy", tooltip = "Currency and inventory." },
					{ name = "Housing", value = "housing", tooltip = "Home and furnishing." },
				},
				maxSelections = 3,
				noSelectionText = "No Tags",
				selectionTextFormat = "<<1[$d Tag/$d Tags]>>",
				getFunc = function()
					return sv.featureTags
				end,
				setFunc = function(values)
					sv.featureTags = values
				end,
				default = defaults.featureTags,
			},
			{
				type = "checklist",
				name = "Craft Skills",
				tooltip = "Multi-select craft skills. Options have no extra tips.",
				align = "center",
				choices = {
					{ name = "Blacksmithing", value = "blacksmithing" },
					{ name = "Clothing", value = "clothing" },
					{ name = "Woodworking", value = "woodworking" },
					{ name = "Jewelry", value = "jewelry" },
				},
				noSelectionText = "None",
				getFunc = function()
					return sv.craftSkills
				end,
				setFunc = function(values)
					sv.craftSkills = values
				end,
				default = defaults.craftSkills,
			},
			{
				type = "checklist",
				name = "Locked Checklist",
				align = "center",
				choices = {
					{ name = "A", value = "a" },
					{ name = "B", value = "b" },
					{ name = "C", value = "c" },
				},
				noSelectionText = "None",
				getFunc = function()
					return sv.lockedChecklist
				end,
				setFunc = function()
				end,
				default = defaults.lockedChecklist,
				disabled = true,
			},
			},
		},

		{
			type = "section",
			name = "Color Pickers", align = "center",
			options = {
			{
				type = "colorpicker",
				name = "Accent",
				tooltip = "Primary accent color for the demo UI.",
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
			{
				type = "colorpicker",
				name = "Locked Color",
				tooltip = "Permanently locked so you can see the disabled look.",
				getFunc = function()
					local c = sv.lockedColor
					return c[1], c[2], c[3], c[4] or 1
				end,
				setFunc = function()
				end,
				default = {
					defaults.lockedColor[1],
					defaults.lockedColor[2],
					defaults.lockedColor[3],
					defaults.lockedColor[4],
				},
				disabled = true,
			},
			},
		},

		{
			type = "section",
			name = "Icon Pickers", align = "center",
			options = {
			{
				type = "iconpicker",
				name = "Status Icon",
				tooltip = "Choose from a short list of icon paths.",
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
				tooltip = "Pick a tile from a 2×2 spritesheet.",
				texture = ATLAS_TEXTURE,
				atlasSizeX = 2,
				atlasSizeY = 2,
				atlasStart = 1,
				atlasEnd = 4,
				getFunc = function()
					return sv.atlasIcon
				end,
				setFunc = function(index)
					sv.atlasIcon = index
				end,
				default = defaults.atlasIcon,
			},
			{
				type = "iconpicker",
				name = "Atlas Subset",
				tooltip = "Same spritesheet, but only two tiles are offered.",
				texture = ATLAS_TEXTURE,
				atlasSizeX = 2,
				atlasSizeY = 2,
				atlasIndices = { 1, 3 },
				getFunc = function()
					return sv.atlasSubsetIcon
				end,
				setFunc = function(index)
					sv.atlasSubsetIcon = index
				end,
				default = defaults.atlasSubsetIcon,
			},
			{
				type = "iconpicker",
				name = "Locked Icon",
				tooltip = "Permanently locked so you can see the disabled look.",
				choices = ICON_CHOICES,
				getFunc = function()
					return sv.lockedIcon
				end,
				setFunc = function()
				end,
				default = defaults.lockedIcon,
				disabled = true,
			},
			},
		},

		{
			type = "section",
			name = "Button", align = "center",
			options = {
			{
				type = "button",
				name = "Print Status to Chat",
				tooltip = "Prints enabled state, profile, and player tag to chat.",
				func = function()
					d(string.format(
						"[LCM Demo] enabled=%s profile=%s tag=%s",
						tostring(sv.enabled),
						tostring(sv.profile),
						tostring(sv.playerTag)
					))
				end,
			},
			---------------------------------------------------------------------------
			-- Submenus
			---------------------------------------------------------------------------
			},
		},
		{
			type = "section",
			name = "Submenus",
			align = "center",
			options = {
				{
					type = "submenu",
					name = "Into the Nest",
					tooltip = "Alerts, combat filters, and currency overlays.",
					options = {
						{
							type = "section",
							name = "Behavior",
							align = "center",
							options = {
								{
									type = "toggle",
									name = "Show Alerts",
									getFunc = function()
										return sv.showAlerts
									end,
									setFunc = function(value)
										sv.showAlerts = value
									end,
									default = defaults.showAlerts,
								},
								{
									type = "toggle",
									name = "Play Sound",
									tooltip = "Only available while Show Alerts is on.",
									getFunc = function()
										return sv.alertSound
									end,
									setFunc = function(value)
										sv.alertSound = value
									end,
									default = defaults.alertSound,
									disabled = function()
										return not sv.showAlerts
									end,
								},
								{
									type = "toggle",
									name = "Combat Only",
									getFunc = function()
										return sv.combatOnly
									end,
									setFunc = function(value)
										sv.combatOnly = value
									end,
									default = defaults.combatOnly,
									disabled = function()
										return not sv.showAlerts
									end,
								},
								{
									type = "submenu",
									name = "Combat Pack",
									tooltip = "Priority and filter settings for combat alerts.",
									options = {
										{
											type = "selector",
											name = "Priority",
											choices = {
												{ name = "Low", value = "low" },
												{ name = "Normal", value = "normal" },
												{ name = "High", value = "high" },
											},
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
											tooltip = "Narrow which combat events can fire.",
											options = {
												{
													type = "editbox",
													name = "Filter Note",
													getFunc = function()
														return sv.filterNote
													end,
													setFunc = function(value)
														sv.filterNote = value
													end,
													default = defaults.filterNote,
													maxInputCharacters = 32,
												},
											},
										},
									},
								},
							},
						},
						{
							type = "section",
							name = "Currencies",
							align = "center",
							options = {
								{
									type = "submenu",
									name = "Gold",
									options = {
										{
											type = "toggle",
											name = "Show Gold Overlay",
											getFunc = function()
												return sv.showGold
											end,
											setFunc = function(value)
												sv.showGold = value
											end,
											default = defaults.showGold,
										},
										{
											type = "slider",
											name = "Warn Below",
											min = 0,
											max = 100000,
											step = 500,
											bigStep = 5000,
											format = "%.0f",
											getFunc = function()
												return sv.goldThreshold
											end,
											setFunc = function(value)
												sv.goldThreshold = value
											end,
											default = defaults.goldThreshold,
										},
									},
								},
								{
									type = "submenu",
									name = "Alliance Points",
									options = {
										{
											type = "toggle",
											name = "Show AP Overlay",
											getFunc = function()
												return sv.showAlliancePoints
											end,
											setFunc = function(value)
												sv.showAlliancePoints = value
											end,
											default = defaults.showAlliancePoints,
										},
										{
											type = "slider",
											name = "Warn Below",
											min = 0,
											max = 200000,
											step = 1000,
											bigStep = 10000,
											format = "%.0f",
											getFunc = function()
												return sv.apThreshold
											end,
											setFunc = function(value)
												sv.apThreshold = value
											end,
											default = defaults.apThreshold,
										},
									},
								},
								{
									type = "submenu",
									name = "Tel Var Stones",
									options = {
										{
											type = "toggle",
											name = "Show Tel Var Overlay",
											getFunc = function()
												return sv.showTelVar
											end,
											setFunc = function(value)
												sv.showTelVar = value
											end,
											default = defaults.showTelVar,
										},
										{
											type = "slider",
											name = "Warn Below",
											min = 0,
											max = 10000,
											step = 100,
											bigStep = 500,
											format = "%.0f",
											getFunc = function()
												return sv.telVarThreshold
											end,
											setFunc = function(value)
												sv.telVarThreshold = value
											end,
											default = defaults.telVarThreshold,
										},
									},
								},
								{
									type = "submenu",
									name = "Writ Vouchers",
									options = {
										{
											type = "toggle",
											name = "Show Writ Overlay",
											getFunc = function()
												return sv.showWritVouchers
											end,
											setFunc = function(value)
												sv.showWritVouchers = value
											end,
											default = defaults.showWritVouchers,
										},
										{
											type = "slider",
											name = "Warn Below",
											min = 0,
											max = 500,
											step = 5,
											bigStep = 25,
											format = "%.0f",
											getFunc = function()
												return sv.writThreshold
											end,
											setFunc = function(value)
												sv.writThreshold = value
											end,
											default = defaults.writThreshold,
										},
									},
								},
							},
						},
					},
				},
			},
		},
		---------------------------------------------------------------------------
		-- Left alignment showcase on the root.
		---------------------------------------------------------------------------
		{
			type = "section",
			name = "Left Alignment",
			align = "leftIndent",
			options = {
				{
					type = "dropdown",
					name = "Nav Theme",
					tooltip = "Theme used by the diagnostics sample.",
					align = "leftIndent",
					choices = {
						{ name = "Dark", value = "dark" },
						{ name = "Light", value = "light" },
						{ name = "System", value = "system" },
					},
					getFunc = function()
						return sv.navTheme
					end,
					setFunc = function(value)
						sv.navTheme = value
					end,
					default = defaults.navTheme,
				},
				{
					type = "checklist",
					name = "Nav Modules",
					tooltip = "Which modules the diagnostics sample reports on.",
					align = "leftIndent",
					choices = {
						{ name = "UI", value = "ui" },
						{ name = "Combat", value = "combat" },
						{ name = "Map", value = "map" },
					},
					noSelectionText = "None",
					getFunc = function()
						return sv.navChecklist
					end,
					setFunc = function(values)
						sv.navChecklist = values
					end,
					default = defaults.navChecklist,
				},
				{
					type = "editbox",
					name = "Nav Note",
					tooltip = "Free-text note included in the diagnostics printout.",
					align = "leftIndent",
					getFunc = function()
						return sv.navNote
					end,
					setFunc = function(value)
						sv.navNote = value
					end,
					default = defaults.navNote,
					maxInputCharacters = 24,
					textType = TEXT_TYPE_ALL,
				},
				{
					type = "button",
					name = "Run Diagnostics",
					tooltip = "Prints theme, module count, and note to chat.",
					align = "leftIndent",
					func = function()
						d(string.format(
							"[LCM Demo] theme=%s modules=%d note=%s",
							tostring(sv.navTheme),
							sv.navChecklist and #sv.navChecklist or 0,
							tostring(sv.navNote)
						))
					end,
				},
			},
		},
		{
			type = "section",
			name = "Left Alignment Without Indent",
			align = "leftFlush",
			options = {
				{
					type = "dropdown",
					name = "Tools Theme",
					tooltip = "Theme shown in this left-aligned section.",
					align = "leftFlush",
					choices = {
						{ name = "Dark", value = "dark" },
						{ name = "Light", value = "light" },
						{ name = "System", value = "system" },
					},
					getFunc = function()
						return sv.toolsTheme
					end,
					setFunc = function(value)
						sv.toolsTheme = value
					end,
					default = defaults.toolsTheme,
				},
				{
					type = "checklist",
					name = "Tools Modules",
					tooltip = "Modules included in this left-aligned section.",
					align = "leftFlush",
					choices = {
						{ name = "UI", value = "ui" },
						{ name = "Combat", value = "combat" },
						{ name = "Map", value = "map" },
					},
					noSelectionText = "None",
					getFunc = function()
						return sv.toolsChecklist
					end,
					setFunc = function(values)
						sv.toolsChecklist = values
					end,
					default = defaults.toolsChecklist,
				},
				{
					type = "editbox",
					name = "Tools Note",
					tooltip = "Optional note for this left-aligned section.",
					align = "leftFlush",
					getFunc = function()
						return sv.toolsNote
					end,
					setFunc = function(value)
						sv.toolsNote = value
					end,
					default = defaults.toolsNote,
					maxInputCharacters = 24,
					textType = TEXT_TYPE_ALL,
				},
				{
					type = "button",
					name = "Restore Player Tag",
					align = "leftFlush",
					func = function()
						sv.playerTag = defaults.playerTag
						d("[LCM Demo] Player tag restored to default.")
					end,
				},
				{
					type = "button",
					name = "Locked Button",
					align = "leftFlush",
					func = function()
					end,
					disabled = true,
				},
			},
		},
	})
end

EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
