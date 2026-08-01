local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
if ( not LAM2 ) then return end

HGF.Menu = {}

function HGF.Menu.SetVar(var, value)
	HGF.savedVars["presets"][HGF.savedVars["activePreset"]][var] = value
	HGF.UI.ApplySettings()
	HGF.SyncUnitList(true)
end

function HGF.Menu.GetVar(var)
	return HGF.savedVars["presets"][HGF.savedVars["activePreset"]][var]
end

HGF.Menu.textTypes = { ["None"] = HGF.textNone,
					   ["Name"] = HGF.textName,
					   ["HP percentage"] = HGF.textHPPerc,
					   ["HP left"] = HGF.textHPLeft,
					   ["HP lost"] = HGF.textHPLost,
					   ["HP left and max HP"] = HGF.textHPLeftMax,
					   ["Current shield"] = HGF.textShield,
					   ["At Name"] = HGF.textAtName
					}

function HGF.Menu.SetTextType(nbr, value)
	HGF.savedVars["presets"][HGF.savedVars["activePreset"]]["textType"][nbr] = HGF.Menu.textTypes[value]
	HGF.UI.ApplySettings()
	HGF.SyncUnitList(true)
end

function HGF.Menu.GetTextType(nbr)
	local toFind = HGF.savedVars["presets"][HGF.savedVars["activePreset"]]["textType"][nbr]
	for k, v in pairs(HGF.Menu.textTypes) do
		if v == toFind then
			return k
		end
	end
end

function HGF.Menu.ListPresets()
	local list = {}
	for preset, data in pairs(HGF.savedVars["presets"]) do
		table.insert(list, preset)
	end
	table.sort(list)
	return list
end

function HGF.Menu.ChangePreset()
	HGF.ChangePreset()
end

function HGF.Menu.CreatePreset()
	local newPreset = HGF.CreatePreset()
	HGF.SetActivePreset(newPreset)
end

function HGF.Menu.RemovePreset()
	HGF.RemovePreset(HGF.savedVars["activePreset"])
end

function HGF.Menu.Initialize()
	local textTypes = {}
	local n = 0
	for k, v in pairs(HGF.Menu.textTypes) do
		n = n + 1
		textTypes[n] = k
	end
	table.sort(textTypes)

	ZO_CreateStringId("SI_BINDING_NAME_HGF_CHANGE_PRESET", "Change Preset")

	HGF.Menu.panel = {
		type = "panel",
		name = "HealersGroupFrameImproved",
		displayName	= "Healers Group Frame Improved",
		author = "ShaiT, Wheels, Amasuriel",
		version = HGF.version,
		registerForRefresh = true,
		registerForDefaults = false,
	}

	HGF.Menu.options = {
		-- Settings presets
		{
			type = "header",
			name = "Settings presets",
			width = "full"
		},

		{
			type = "description",
			text = "Use presets to switch between different looks for different occasions",
		},

		{
			type = "button",
			name = "Create new preset",
			tooltip = "Creates a new preset copying settings of currently active preset.",
			func = function() HGF.Menu.CreatePreset() end,
			width = "half",
		},

		{
			type = "button",
			name = "Remove current preset",
			tooltip = "Removes currently active preset.",
			func = function() HGF.Menu.RemovePreset() end,
			width = "half",
		},

		{
			type = "button",
			name = "Next preset",
			tooltip = "Changes active preset to the next in line.",
			func = function() HGF.Menu.ChangePreset() end,
			width = "half",
		},

		{
			type = "editbox",
			name = "Active preset",
			tooltip = "Preset to use and change settings for at the moment.",
			getFunc = function() return HGF.savedVars["activePreset"] end,
			setFunc = function(text) HGF.SetActivePreset(tonumber(text)) end,
			isMultiline = false,
			width = "half",
		},

		{
			type = "description",
			text = "You can set a keybinding for changing preset in the keybindings menu (Controls -> Keybindings) under Healers Group Frame",
		},

		{
			type = "editbox",
			name = "Preset name",
			tooltip = "Name of the current preset, only use is for your memory.",
			getFunc = function() return HGF.Menu.GetVar("presetName") end,
			setFunc = function(text) HGF.Menu.SetVar("presetName", text) end,
			isMultiline = false,
		},

		-- Frame layout
		{
			type = "header",
			name = "Frame layout",
			width = "full"
		},

		{
			type = "button",
			name = "Toggle move mode",
			tooltip = "Enables you to move the position of the frames on screen. Click button once to enable move mode, then move the gray frame to desired position and click the button again to return to normal mode.",
			func = function() HGF.ToggleMoveMode() end,
			width = "half",
		},

		{
			type = "description",
			text = "You can also click and drag the first frame while in cursor mode to set a new position.",
			width = "half",
		},

		{
			type = "slider",
			name = "Distance between frames",
			tooltip = "Distance between frames, both horizontally and vertically.",
			min = 0,
			max = 500,
			getFunc = function() return HGF.Menu.GetVar("frameDistance") end,
			setFunc = function(value) HGF.Menu.SetVar("frameDistance", value) end,
		},

		{
			type = "slider",
			name = "Max frames per column",
			tooltip = "Max number of rows.",
			min = 1,
			max = 24,
			getFunc = function() return HGF.Menu.GetVar("maxPerCol") end,
			setFunc = function(value) HGF.Menu.SetVar("maxPerCol", value) end,
		},

		{
			type = "dropdown",
			name = "Vertical grow direction",
			tooltip = "Which vertical direction the group frames should grow.",
			choices = {"up", "down"},
			getFunc = function() return HGF.Menu.GetVar("growDirV") end,
			setFunc = function(value) HGF.Menu.SetVar("growDirV", value) end,
		},

		{
			type = "dropdown",
			name = "Horizontal grow direction",
			tooltip = "Which horizontal direction the group frames should grow.",
			choices = {"left", "right"},
			getFunc = function() return HGF.Menu.GetVar("growDirH") end,
			setFunc = function(value) HGF.Menu.SetVar("growDirH", value) end,
		},

		-- Information display
		{
			type = "header",
			name = "Information display",
			width = "full"
		},

		{
			type = "dropdown",
			name = "Upper left text information",
			tooltip = "What type of information should be displayed in the upper left.",
			choices = textTypes,
			getFunc = function() return HGF.Menu.GetTextType(1) end,
			setFunc = function(value) HGF.Menu.SetTextType(1, value) end
		},

		{
			type = "dropdown",
			name = "Upper right text information",
			tooltip = "What type of information should be displayed in the upper right.",
			choices = textTypes,
			getFunc = function() return HGF.Menu.GetTextType(2) end,
			setFunc = function(value) HGF.Menu.SetTextType(2, value) end
		},

		{
			type = "dropdown",
			name = "Lower left text information",
			tooltip = "What type of information should be displayed in the lower left.",
			choices = textTypes,
			getFunc = function() return HGF.Menu.GetTextType(3) end,
			setFunc = function(value) HGF.Menu.SetTextType(3, value) end
		},

		{
			type = "dropdown",
			name = "Lower right text information",
			tooltip = "What type of information should be displayed in the lower right.",
			choices = textTypes,
			getFunc = function() return HGF.Menu.GetTextType(4) end,
			setFunc = function(value) HGF.Menu.SetTextType(4, value) end
		},

		{
			type = "checkbox",
			name = "Truncate large values",
			tooltip = "Truncate large values, showing 16.8k instead of 16789.",
			getFunc = function() return HGF.Menu.GetVar("truncateValues") end,
			setFunc = function(value) HGF.Menu.SetVar("truncateValues", value) end,
		},

		{
			type = "slider",
			name = "Decimals shown",
			tooltip = "If values are truncated, this is the number of decimals shown.",
			min = 0,
			max = 10,
			getFunc = function() return HGF.Menu.GetVar("truncateDecimals") end,
			setFunc = function(value) HGF.Menu.SetVar("truncateDecimals", value) end,
		},

		{
			type = "editbox",
			name = "Thousand separator",
			tooltip = "Set character to insert as a thousand separator (',' would result in values such as '10,000' for example).",
			getFunc = function() return HGF.Menu.GetVar("thousandSeparator") end,
			setFunc = function(value) HGF.Menu.SetVar("thousandSeparator", value) end,
		},

		{
			type = "checkbox",
			name = "Treat shield as extra HP",
			tooltip = "Adds shield to current HP of players. Max HP is not changed, meaning HP can be at more than 100%.",
			getFunc = function() return HGF.Menu.GetVar("shieldAsHp") end,
			setFunc = function(value) HGF.Menu.SetVar("shieldAsHp", value) end,
		},

		{
			type = "checkbox",
			name = "Show leader icon",
			tooltip = "Show an icon indicating the leader.",
			getFunc = function() return HGF.Menu.GetVar("showLeaderIcon") end,
			setFunc = function(value) HGF.Menu.SetVar("showLeaderIcon", value) end,
		},

		{
			type = "checkbox",
			name = "Show shield indicator",
			tooltip = "Show a bar indicating current shield level.",
			getFunc = function() return HGF.Menu.GetVar("showShieldIndicator") end,
			setFunc = function(value) HGF.Menu.SetVar("showShieldIndicator", value) end,
		},

		{
			type = "checkbox",
			name = "Indicate Warhorn change",
			tooltip = "Changes color of health bar based on whether warhorn is active on a player.",
			getFunc = function() return HGF.Menu.GetVar("showWarhorn") end,
			setFunc = function(value) HGF.Menu.SetVar("showWarhorn", value) end
		},
		
		{
			type = "checkbox",
			name = "Indicate Berserk change",
			tooltip = "Changes color of health bar based on whether Minor Berserk is active on a player.",
			getFunc = function() return HGF.Menu.GetVar("showBerserk") end,
			setFunc = function(value) HGF.Menu.SetVar("showBerserk", value) end
		},
		
		{
			type = "checkbox",
			name = "Indicate Warhorn and Berserk change",
			tooltip = "Changes color of health bar based on whether Warhorn and Minor Berserk is active on a player.",
			getFunc = function() return HGF.Menu.GetVar("showWarhornAndBerserk") end,
			setFunc = function(value) HGF.Menu.SetVar("showWarhornAndBerserk", value) end
		},		

		{
			type = "checkbox",
			name = "Show stealth icon",
			tooltip = "Show an icon indicating if the person is crouching.",
			getFunc = function() return HGF.Menu.GetVar("showStealthIndicator") end,
			setFunc = function(value) HGF.Menu.SetVar("showStealthIndicator", value) end,
		},

		-- Frame display
		{
			type = "header",
			name = "Frame display",
			width = "full"
		},

		{
			type = "slider",
			name = "Frame width",
			tooltip = "Width of the frames.",
			min = 1,
			max = 500,
			getFunc = function() return HGF.Menu.GetVar("frameWidth") end,
			setFunc = function(value) HGF.Menu.SetVar("frameWidth", value) end,
		},

		{
			type = "slider",
			name = "Frame height",
			tooltip = "Height of the frames.",
			min = 1,
			max = 500,
			getFunc = function() return HGF.Menu.GetVar("frameHeight") end,
			setFunc = function(value) HGF.Menu.SetVar("frameHeight", value) end,
		},

		{
			type = "slider",
			name = "In range opacity",
			tooltip = "Transparency level when unit is within support range.",
			min = 0,
			max = 100,
			step = 1,
			getFunc = function() return (HGF.Menu.GetVar("inRangeAlpha") * 100) end,
			setFunc = function(value) HGF.Menu.SetVar("inRangeAlpha", value / 100) end,
		},

		{
			type = "slider",
			name = "Out of range opacity",
			tooltip = "Transparency level when unit is outside support range.",
			min = 0,
			max = 100,
			step = 1,
			getFunc = function() return (HGF.Menu.GetVar("outOfRangeAlpha") * 100) end,
			setFunc = function(value) HGF.Menu.SetVar("outOfRangeAlpha", value / 100) end,
		},

		-- Cosmetic
		{
			type = "header",
			name = "Cosmetic",
			width = "full"
		},

		{
			type = "colorpicker",
			name = "HP bar color",
			tooltip = "Select color for HP bar.",
			getFunc = function() return HGF.Menu.GetVar("healthBarColor")[1], HGF.Menu.GetVar("healthBarColor")[2], HGF.Menu.GetVar("healthBarColor")[3] end,
			setFunc = function(r, g, b, a) HGF.Menu.SetVar("healthBarColor", {r, g, b}) end,
		},

		{
			type = "colorpicker",
			name = "Warhorn active color",
			tooltip = "Select color for HP bar when Warhorn is active.",
			getFunc = function() return HGF.Menu.GetVar("hornBarColor")[1], HGF.Menu.GetVar("hornBarColor")[2], HGF.Menu.GetVar("hornBarColor")[3] end,
			setFunc = function(r, g, b, a) HGF.Menu.SetVar("hornBarColor", {r, g, b}) end,
		},
		
		{
			type = "colorpicker",
			name = "Minor Berserk active color",
			tooltip = "Select color for HP bar when Minor Berserk is active.",
			getFunc = function() return HGF.Menu.GetVar("berserkBarColor")[1], HGF.Menu.GetVar("berserkBarColor")[2], HGF.Menu.GetVar("berserkBarColor")[3] end,
			setFunc = function(r, g, b, a) HGF.Menu.SetVar("berserkBarColor", {r, g, b}) end,
		},

		{
			type = "colorpicker",
			name = "Warhorn and Berserk active color",
			tooltip = "Select color for HP bar when Warhorn and Minor Berserk is active.",
			getFunc = function() return HGF.Menu.GetVar("hornAndBerserkBarColor")[1], HGF.Menu.GetVar("hornAndBerserkBarColor")[2], HGF.Menu.GetVar("hornAndBerserkBarColor")[3] end,
			setFunc = function(r, g, b, a) HGF.Menu.SetVar("hornAndBerserkBarColor", {r, g, b}) end,
		},		

		{
			type = "colorpicker",
			name = "Shield bar color",
			tooltip = "Select color for shield indicator bar.",
			getFunc = function() return HGF.Menu.GetVar("shieldColor")[1], HGF.Menu.GetVar("shieldColor")[2], HGF.Menu.GetVar("shieldColor")[3] end,
			setFunc = function(r, g, b, a) HGF.Menu.SetVar("shieldColor", {r, g, b}) end,
		},

		{
			type = "colorpicker",
			name = "Text color",
			tooltip = "Select color for text printed on the frame.",
			getFunc = function() return HGF.Menu.GetVar("textColor")[1], HGF.Menu.GetVar("textColor")[2], HGF.Menu.GetVar("textColor")[3] end,
			setFunc = function(r, g, b, a) HGF.Menu.SetVar("textColor", {r, g, b}) end,
		},

		{
			type = "editbox",
			name = "Font",
			tooltip = "Font to use. This must correspond to a ZO font name.",
			getFunc = function() return HGF.Menu.GetVar("font") end,
			setFunc = function(text) HGF.Menu.SetVar("font", text) end,
			isMultiline = false,
		},

		{
			type = "editbox",
			name = "Frame texture",
			tooltip = "Texture to use for frames. You can set a texture of your own or an existing ESO texture.",
			getFunc = function() return HGF.Menu.GetVar("frame_texture") end,
			setFunc = function(text) HGF.Menu.SetVar("frame_texture", text) end,
			isMultiline = false,
		},

	}

	-- Setup the initial panel
	LAM2:RegisterAddonPanel("HGF_Menu" , HGF.Menu.panel)
	LAM2:RegisterOptionControls("HGF_Menu", HGF.Menu.options)
end --HGF.Menu.Initialize()
