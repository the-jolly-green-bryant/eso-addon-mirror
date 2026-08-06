-- LCM Demo: realistic settings menu that exercises every LibConsoleMenu control
-- and field. Root + centered branches use options-style centering; Alignment
-- Modes showcases left+indent and left+flush (indent = false).

LCMDemo = LCMDemo or {}
local Addon = LCMDemo

Addon.name = "LCMDemo"
Addon.displayName = "LCM Demo"
Addon.version = "1.1.2"

Addon.defaults = {
	-- General
	enabled = true,
	accountWide = true,
	-- Toggle label showcase
	labelYesNo = true,
	labelEnabledDisabled = true,
	labelShowHide = true,
	labelCharacterAccount = false,
	labelCustomScope = true,
	labelCheckboxAlias = false,
	-- Performance
	updateRate = 1.0,
	updateFrequency = 5,
	opacity = 80,
	windowOpacity = 0.85,
	-- Profiles / lists
	profile = "balanced",
	difficultyMode = "seasoned",
	featureTags = { "ui", "combat" },
	-- Identity
	playerTag = "Demo",
	pinCode = "1234",
	-- Appearance
	accentColor = { 0.2, 0.75, 1.0, 1 },
	warningColor = { 1.0, 0.35, 0.2, 1 },
	statusIcon = 1,
	atlasIcon = 1,
	atlasSubsetIcon = 1,
	-- Alerts
	showAlerts = true,
	alertSound = true,
	combatOnly = false,
	combatPriority = "normal",
	filterNote = "Ready",
	-- Currency overlays (nested chip groups)
	showGold = true,
	showAlliancePoints = true,
	showTelVar = false,
	showWritVouchers = true,
	goldThreshold = 10000,
	apThreshold = 50000,
	telVarThreshold = 1000,
	writThreshold = 50,
	-- Alignment showcase
	navTheme = "dark",
	navChecklist = { "ui" },
	navNote = "ok",
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
	if not LCM or type(LCM.RegisterAddonPanel) ~= "function" then
		return
	end

	local sv = Addon.sv
	local defaults = Addon.defaults

	LCM:RegisterAddonPanel(Addon.name, {
		name = Addon.displayName,
		author = "Fluazinam",
		version = Addon.version,
		category = "UTILITY",
		registerForDefaults = true,
		registerForRefresh = true,
		centerSubmenus = true,
		collapseToggleLabels = true,
		collapseSliderLabels = true,
		resetFunc = function()
			Addon:ResetToDefaults()
		end,
	})

	LCM:RegisterOptionControls(Addon.name, {
		---------------------------------------------------------------------------
		-- Root: options-style (centered headers). Master switch gates several rows.
		---------------------------------------------------------------------------
		{ type = "header", name = "General", align = "center" },
		{
			type = "toggle",
			name = "Enable LCM Demo Features",
			tooltip = "Master switch. Several rows below disable when this is off (registerForRefresh).",
			getFunc = function()
				return sv.enabled
			end,
			setFunc = function(value)
				sv.enabled = value
			end,
			default = defaults.enabled,
		},
		{
			type = "toggle",
			name = "Account-Wide Settings",
			tooltip = "Custom On/Off labels via values (wins over preset).",
			values = {
				on = "Account",
				off = "Character",
			},
			getFunc = function()
				return sv.accountWide
			end,
			setFunc = function(value)
				sv.accountWide = value
			end,
			default = defaults.accountWide,
			disabled = function()
				return not sv.enabled
			end,
		},

		{ type = "header", name = "Toggle Labels", align = "center" },
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
			type = "checkbox",
			name = "Checkbox Alias",
			tooltip = "type = \"checkbox\" is accepted as an alias for toggle.",
			getFunc = function()
				return sv.labelCheckboxAlias
			end,
			setFunc = function(value)
				sv.labelCheckboxAlias = value
			end,
			default = defaults.labelCheckboxAlias,
		},
		{
			type = "toggle",
			name = "Always Locked",
			tooltip = "Static disabled = true example.",
			getFunc = function()
				return sv.labelCustomScope
			end,
			setFunc = function(value)
				sv.labelCustomScope = value
			end,
			default = defaults.labelCustomScope,
			disabled = true,
		},

		{ type = "header", name = "Performance", align = "center" },
		{
			type = "slider",
			name = "Update Rate",
			tooltip = "Fractional step with decimals.",
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
			tooltip = "Integer slider with unit text and bigStep.",
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

		{ type = "header", name = "Profiles", align = "center" },
		{
			type = "selector",
			name = "Profile",
			tooltip = "String choices + choicesValues.",
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
			tooltip = "Table choices with per-item tips. Open with A.",
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
			type = "checklist",
			name = "Feature Tags",
			tooltip = "Multi-select with cap and custom empty/multi text.",
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
			type = "selector",
			name = "Locked Selector",
			choices = { "One", "Two", "Three" },
			choicesValues = { "one", "two", "three" },
			getFunc = function()
				return "two"
			end,
			setFunc = function()
			end,
			default = "two",
			disabled = true,
		},

		{ type = "header", name = "Identity", align = "center" },
		{
			type = "editbox",
			name = "Player Tag",
			tooltip = "Free-text edit (TEXT_TYPE_ALL).",
			getFunc = function()
				return sv.playerTag
			end,
			setFunc = function(value)
				sv.playerTag = value
			end,
			default = defaults.playerTag,
			maxChars = 24,
			textType = TEXT_TYPE_ALL,
		},
		{
			type = "editbox",
			name = "PIN Code",
			tooltip = "Numeric-only editbox example.",
			getFunc = function()
				return sv.pinCode
			end,
			setFunc = function(value)
				sv.pinCode = value
			end,
			default = defaults.pinCode,
			maxChars = 8,
			textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		},
		{
			type = "button",
			name = "Print Status to Chat",
			tooltip = "Fires clickHandler (func).",
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
		-- Centered submenus (panel centerSubmenus = true). Chip edge ownership
		-- is covered by the Currencies group under Alerts.
		---------------------------------------------------------------------------
		{
			type = "submenu",
			name = "Appearance",
			tooltip = "Colors, icons, and opacity.",
			onEnter = function()
				d("[LCM Demo] Entered Appearance")
			end,
			onExit = function()
				d("[LCM Demo] Left Appearance")
			end,
			controls = {
				{ type = "header", name = "Colors", align = "center" },
				{
					type = "colorpicker",
					name = "Accent",
					tooltip = "RGBA colorpicker.",
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
				{ type = "header", name = "Icons", align = "center" },
				{
					type = "iconpicker",
					name = "Status Icon",
					tooltip = "Path-list iconpicker (choices).",
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
					tooltip = "Spritesheet atlas (texture + atlasSizeX/Y).",
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
					tooltip = "Same atlas with atlasIndices subset.",
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
			},
		},

		{
			type = "submenu",
			name = "Alerts",
			tooltip = "Centered drill-in with nested packs and a currency chip group.",
			controls = {
				{ type = "header", name = "Behavior", align = "center" },
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
					tooltip = "Disabled while Show Alerts is off.",
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
					tooltip = "Nested centered submenu (depth 2).",
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
							tooltip = "Nested centered submenu (depth 3).",
							controls = {
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
									maxChars = 32,
								},
							},
						},
					},
				},

				-- Four sibling centered chips under one header → edge ownership.
				{ type = "header", name = "Currencies", align = "center" },
				{
					type = "submenu",
					name = "Gold",
					controls = {
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
					controls = {
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
					controls = {
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
					controls = {
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

		---------------------------------------------------------------------------
		-- Alignment showcase: centered entry into left+indent, then left+flush.
		---------------------------------------------------------------------------
		{ type = "header", name = "Alignment Modes", align = "center" },
		{
			type = "submenu",
			name = "Left Alignment",
			tooltip = "Indented left controls, then a flush (no-indent) Tools page.",
			align = "center",
			controls = {
				{ type = "header", name = "Diagnostics", align = "left", indent = true },
				{
					type = "dropdown",
					name = "Nav Theme",
					tooltip = "Left + indent dropdown.",
					align = "left",
					indent = true,
					choices = { "Dark", "Light", "System" },
					choicesValues = { "dark", "light", "system" },
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
					tooltip = "Left + indent checklist.",
					align = "left",
					indent = true,
					choices = { "UI", "Combat", "Map" },
					choicesValues = { "ui", "combat", "map" },
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
					tooltip = "Left + indent edit.",
					align = "left",
					indent = true,
					getFunc = function()
						return sv.navNote
					end,
					setFunc = function(value)
						sv.navNote = value
					end,
					default = defaults.navNote,
					maxChars = 24,
					textType = TEXT_TYPE_ALL,
				},
				{
					type = "button",
					name = "Run Diagnostics",
					tooltip = "Left + indent button.",
					align = "left",
					indent = true,
					func = function()
						d(string.format(
							"[LCM Demo] theme=%s modules=%d note=%s",
							tostring(sv.navTheme),
							sv.navChecklist and #sv.navChecklist or 0,
							tostring(sv.navNote)
						))
					end,
				},
				{
					type = "submenu",
					name = "Tools",
					tooltip = "Opens a flush-left (no indent) page.",
					align = "left",
					controls = {
						{ type = "header", name = "Actions", align = "left", indent = false },
						{
							type = "dropdown",
							name = "Tools Theme",
							tooltip = "Left + flush dropdown.",
							align = "left",
							indent = false,
							choices = { "Dark", "Light", "System" },
							choicesValues = { "dark", "light", "system" },
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
							tooltip = "Left + flush checklist.",
							align = "left",
							indent = false,
							choices = { "UI", "Combat", "Map" },
							choicesValues = { "ui", "combat", "map" },
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
							tooltip = "Left + flush edit.",
							align = "left",
							indent = false,
							getFunc = function()
								return sv.toolsNote
							end,
							setFunc = function(value)
								sv.toolsNote = value
							end,
							default = defaults.toolsNote,
							maxChars = 24,
							textType = TEXT_TYPE_ALL,
						},
						{
							type = "button",
							name = "Restore Player Tag",
							align = "left",
							indent = false,
							func = function()
								sv.playerTag = defaults.playerTag
								d("[LCM Demo] Player tag restored to default.")
							end,
						},
						{
							type = "button",
							name = "Locked Button",
							align = "left",
							indent = false,
							func = function()
							end,
							disabled = true,
						},
					},
				},
			},
		},
	})
end

EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
