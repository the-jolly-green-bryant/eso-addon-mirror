PriceTooltipNote_MENU.PanelData =
{
	type = "panel",
	name = "Price Tooltip Note",
	displayName = "Price Tooltip Note",
	author = "Mladen90 (@Mladen90 EU)",
	version = PriceTooltipNote.StringVersion,
	registerForRefresh = true,
}


PriceTooltipNote_MENU.OptionData =
{
	{
		type = "header",
		name = "Format settings",
	},
	{
		type = "colorpicker",
		name = "Tooltip Color",
		width = "full",
		getFunc = function()
			return
			PriceTooltipNote.SavedVariables.TooltipColor.Red,
			PriceTooltipNote.SavedVariables.TooltipColor.Green,
			PriceTooltipNote.SavedVariables.TooltipColor.Blue
		end,
		setFunc = function(r, g, b)
			PriceTooltipNote.SavedVariables.TooltipColor.Red = r
			PriceTooltipNote.SavedVariables.TooltipColor.Green = g
			PriceTooltipNote.SavedVariables.TooltipColor.Blue = b
		end,
    },
	{
		type = "slider",
		name = "[ Tooltip line spacing ]",
		tooltip = "Change the spacing for each tooltip line",
		width = "half",
		min = -10,
		max = 10,
		step = 1,
		getFunc = function() return PriceTooltipNote.SavedVariables.TooltipLineSpacing end,
		setFunc = function(newValue) PriceTooltipNote.SavedVariables.TooltipLineSpacing = newValue end,
	},
	{
		type = "dropdown",
		name = "[ Tooltip Font ]",
		tooltip = "Font for the Tooltip",
		width = "half",
		choices =
		{
			"ZoFontWinH5",
			"ZoFontWinH4",
			"ZoFontWinH3",
			"ZoFontWinH2",
			"ZoFontGameSmall",
			"ZoFontGame",
			"ZoFontGameBold",
		},
		getFunc = function() return PriceTooltipNote.SavedVariables.Font end,
		setFunc = function(newValue) PriceTooltipNote.SavedVariables.Font = newValue end,
	},
	{
		type = "dropdown",
		name = "[Gamepad] Tooltip Font",
		tooltip = "Font for the Tooltip",
		width = "half",
		choices = PriceTooltipNote_GamepadStyles,
		getFunc = function() return PriceTooltipNote.SavedVariables.GamepadFont end,
		setFunc = function(newValue) PriceTooltipNote.SavedVariables.GamepadFont = newValue end,
	},
	{
		type = "divider",
		width = "full",
	},
	{
		type = "colorpicker",
		name = "[ Context Menu Color ]",
		width = "full",
		getFunc = function()
			return
			PriceTooltipNote.SavedVariables.ContextMenuColor.Red,
			PriceTooltipNote.SavedVariables.ContextMenuColor.Green,
			PriceTooltipNote.SavedVariables.ContextMenuColor.Blue
		end,
		setFunc = function(r, g, b)
			PriceTooltipNote.SavedVariables.ContextMenuColor.Red = r
			PriceTooltipNote.SavedVariables.ContextMenuColor.Green = g
			PriceTooltipNote.SavedVariables.ContextMenuColor.Blue = b
		end,
	},
	{
		type = "divider",
		width = "full",
	},
	{
		type = "checkbox",
		name = "Double Tooltip Fix",
		width = "half",
		getFunc = function() return PriceTooltipNote.SavedVariables.FixDoubleTooltip end,
		setFunc = function(newValue) PriceTooltipNote.SavedVariables.FixDoubleTooltip = newValue end,
	},
}


PriceTooltipNote_MENU.Init = function()
	LibAddonMenu2:RegisterAddonPanel("PRICE_TOOLTIP_NOTE_SETTINGS", PriceTooltipNote_MENU.PanelData)
	LibAddonMenu2:RegisterOptionControls("PRICE_TOOLTIP_NOTE_SETTINGS", PriceTooltipNote_MENU.OptionData)
end