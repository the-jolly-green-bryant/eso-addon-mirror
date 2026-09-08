local ISL = ItemSaverLite

local LAM = LibAddonMenu2

function ISL.CreateSettingsMenu()
	local ANCHOR_OPTIONS = {
		"Top Left",
		"Top",
		"Top Right",
		"Right",
		"Bottom Right",
		"Bottom",
		"Bottom Left",
		"Left",
		"Center"
	}

	local markerTexturePaths, markerTextureNames = ISL.GetMarkerTextureArrays()

	local optionsData = {
		{
			type = "header",
			name = "|t30:30:/esoui/art/menubar/gamepad/gp_playermenu_icon_emotes.dds|t Appearance"
		},
		{
			type = "iconpicker",
			name = "Marker Texture",
			tooltip = "Icon style for your markers.",
			choices = markerTexturePaths,
			choicesTooltips = markerTextureNames,
			iconSize = 32,
			maxRowCount = 2,
			width = "half",
			getFunc = function()
				return ISL.markerTextures[ISL.SV.markerTexture]
			end,
			setFunc = function(path)
				for name, texPath in pairs(ISL.markerTextures) do
					if texPath == path then
						ISL.SV.markerTexture = name
						break
					end
				end
				ISL.RefreshAll()
			end,
		},
		{
			type = "colorpicker",
			name = "Marker Color",
			tooltip = "The color tint applied to the marker icon.",
			width = "half",
			getFunc = function()
				local color = ZO_ColorDef:New(ISL.SV.markerColor)
				return color:UnpackRGB()
			end,
			setFunc = function(r, g, b)
				local color = ZO_ColorDef:New(r, g, b)
				ISL.SV.markerColor = color:ToHex()
				ISL.RefreshAll()
			end,
		},
		{
			type = "dropdown",
			name = "Marker Position",
			tooltip = "Position of the saved item marker.",
			choices = ANCHOR_OPTIONS,
			width = "half",
			getFunc = function()
				return ANCHOR_OPTIONS[ISL.SV.markerAnchor]
			end,
			setFunc = function(value)
				for i, option in ipairs(ANCHOR_OPTIONS) do
					if option == value then
						ISL.SV.markerAnchor = i
						break
					end
				end
				ISL.RefreshAll()
			end,
		},
		{
			type = "slider",
			name = "Marker Scale",
			tooltip = "Size modifier for the texture marker overlay.",
			min = 0.2,
			max = 2.0,
			step = 0.1,
			width = "half",
			getFunc = function() return ISL.SV.markerScale end,
			setFunc = function(value)
				ISL.SV.markerScale = value
				ISL.RefreshAll()
			end,
		},
		{
			type = "slider",
			name = "Horizontal Offset",
			tooltip = "Add an additional offset to the marker's horizontal position.",
			min = -10,
			max = 10,
			step = 1,
			width = "half",
			getFunc = function() return ISL.SV.offsetX end,
			setFunc = function(value)
				ISL.SV.offsetX = value
				ISL.RefreshAll()
			end,
		},
		{
			type = "slider",
			name = "Vertical Offset",
			tooltip = "Add an additional offset to the marker's vertical position.",
			min = -10,
			max = 10,
			step = 1,
			width = "half",
			getFunc = function() return ISL.SV.offsetY end,
			setFunc = function(value)
				ISL.SV.offsetY = value
				ISL.RefreshAll()
			end,
		},

		{
			type = "header",
			name = "|t30:30:/esoui/art/inventory/gamepad/gp_inventory_icon_miscellaneous.dds|t General Settings"
		},
		{
			type = "checkbox",
			name = "Enable Context Menu Options",
			tooltip = "Show 'Save Item' / 'Unlock' option in the right-click context menu.",
			getFunc = function() return ISL.SV.enableContextMenu end,
			setFunc = function(value)
				ISL.SV.enableContextMenu = value
			end,
			requiresReload = true,
		},
	}

	LAM:RegisterAddonPanel("ItemSaverLiteSettingsPanel", {
		type = "panel",
		name = "|cFFD700Item Saver Lite|r",
		author = "|cFFD700@Atharti|r"
	})
	LAM:RegisterOptionControls("ItemSaverLiteSettingsPanel", optionsData)
end