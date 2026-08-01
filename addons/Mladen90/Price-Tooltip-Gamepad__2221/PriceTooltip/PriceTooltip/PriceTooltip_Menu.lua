PriceTooltip_MENU.PanelData =
{
	type = "panel",
	name = "Price Tooltip",
	displayName = "Price Tooltip",
	author = "Mladen90 (@Mladen90 EU), Infixo (CoAuthor)",
	version = PriceTooltip.StringVersion,
	registerForRefresh = true
}


PriceTooltip_MENU.OptionData = 
{
	{
		type = "header",
		name = "Format settings"
	},
	{
		type = "dropdown",
		name = "Thousand separator",
		tooltip = "Separator to split thousand values",
		width = "half",
		choices = {"'", ",", ".", "_", PRICE_TOOLTIP_SPACE, PRICE_TOOLTIP_EMPTY},
		getFunc = function() return PriceTooltip.SavedVariables.Separator end,
		setFunc = function(newValue) PriceTooltip.SavedVariables.Separator = newValue end
	},
	{
		type = "checkbox",
		name = "Round price",
		width = "half",
		getFunc = function() return PriceTooltip.SavedVariables.RoundPrice end,
		setFunc = function(newValue) PriceTooltip.SavedVariables.RoundPrice = newValue end
	},
	{
		type = "colorpicker",
		name = "Tooltip Color",
		width = "half",
		getFunc = function()
			return
			PriceTooltip.SavedVariables.TooltipColor.Red,
			PriceTooltip.SavedVariables.TooltipColor.Green,
			PriceTooltip.SavedVariables.TooltipColor.Blue
		end,
		setFunc = function(r, g, b)
			PriceTooltip.SavedVariables.TooltipColor.Red = r
			PriceTooltip.SavedVariables.TooltipColor.Green = g
			PriceTooltip.SavedVariables.TooltipColor.Blue = b
		end
    },
	{
		type = "colorpicker",
		name = "Tooltip info color",
		width = "half",
		getFunc = function()
			return
			PriceTooltip.SavedVariables.TooltipPriceInfoColor.Red,
			PriceTooltip.SavedVariables.TooltipPriceInfoColor.Green,
			PriceTooltip.SavedVariables.TooltipPriceInfoColor.Blue
		end,
		setFunc = function(r, g, b)
			PriceTooltip.SavedVariables.TooltipPriceInfoColor.Red = r
			PriceTooltip.SavedVariables.TooltipPriceInfoColor.Green = g
			PriceTooltip.SavedVariables.TooltipPriceInfoColor.Blue = b
		end
    },
	{
		type = "slider",
		name = "[Keyboard] Tooltip line spacing",
		tooltip = "Change the spacing for each tooltip line",
		width = "half",
		min = -10,
		max = 10,
		step = 1,
		getFunc = function() return PriceTooltip.SavedVariables.TooltipLineSpacing end,
		setFunc = function(newValue) PriceTooltip.SavedVariables.TooltipLineSpacing = newValue end
	},
	{
		type = "checkbox",
		name = "Remove Startup messages",
		tooltip = "Removes messages on Startup except 'Initialized'",
		width = "half",
		getFunc = function() return PriceTooltip.SavedVariables.DisableStartupLog end,
		setFunc = function(newValue) PriceTooltip.SavedVariables.DisableStartupLog = newValue end,
	},
	{
		type = "submenu",
		name = "Bound Items",
		controls =
		{
			{
				type = "checkbox",
				name = "Vendor Price for Grid",
				tooltip = "Calculates Vendor Price for Bound Items in Grid and Sort",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.BoundItemsAsVendorPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.BoundItemsAsVendorPrice = newValue end,
				requiresReload = true,
			},
			{
				type = "checkbox",
				name = "Indicator",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.MarkBoundItems end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.MarkBoundItems = newValue end
			},
			{
				type = "colorpicker",
				name = "Indicator Color",
				width = "full",
				getFunc = function()
					return
					PriceTooltip.SavedVariables.BoundItemMarkColor.Red,
					PriceTooltip.SavedVariables.BoundItemMarkColor.Green,
					PriceTooltip.SavedVariables.BoundItemMarkColor.Blue
				end,
				setFunc = function(r, g, b)
					PriceTooltip.SavedVariables.BoundItemMarkColor.Red = r
					PriceTooltip.SavedVariables.BoundItemMarkColor.Green = g
					PriceTooltip.SavedVariables.BoundItemMarkColor.Blue = b
				end
			},
		}
	},
	{
		type = "submenu",
		name = "Tooltip Font",
		controls =
		{
			{
				type = "dropdown",
				name = "[Keyboard] Tooltip Font",
				tooltip = "Font for the price in tooltip",
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
				getFunc = function() return PriceTooltip.SavedVariables.Font end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.Font = newValue end
			},
			{
				type = "dropdown",
				name = "[Keyboard] Tooltip Info Font",
				tooltip = "Font for the info in tooltip",
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
				getFunc = function() return PriceTooltip.SavedVariables.PriceInfoFont end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.PriceInfoFont = newValue end
			},
			{
				type = "dropdown",
				name = "[Gamepad] Tooltip Font",
				tooltip = "Font for the price in tooltip",
				width = "half",
				choices = PriceTooltip_GamepadStyles,
				getFunc = function() return PriceTooltip.SavedVariables.GamepadFont end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.GamepadFont = newValue end
			},
			{
				type = "dropdown",
				name = "[Gamepad] Tooltip Info Font",
				tooltip = "Font for the info in tooltip",
				width = "half",
				choices = PriceTooltip_GamepadStyles,
				getFunc = function() return PriceTooltip.SavedVariables.GamepadPriceInfoFont end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.GamepadPriceInfoFont = newValue end
			},
		},
	},
	{
		type = "submenu",
		name = "Context Menu",
		controls =
		{
			{
				type = "colorpicker",
				name = "Context Menu Color",
				width = "full",
				getFunc = function()
					return
					PriceTooltip.SavedVariables.ContextMenuColor.Red,
					PriceTooltip.SavedVariables.ContextMenuColor.Green,
					PriceTooltip.SavedVariables.ContextMenuColor.Blue
				end,
				setFunc = function(r, g, b)
					PriceTooltip.SavedVariables.ContextMenuColor.Red = r
					PriceTooltip.SavedVariables.ContextMenuColor.Green = g
					PriceTooltip.SavedVariables.ContextMenuColor.Blue = b
				end,
			},
			{
				type = "checkbox",
				name = "[Keyboard] Use PriceTooltip Menu",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UsePriceTooltipMenu end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UsePriceTooltipMenu = newValue end,
			},
			{
				type = "checkbox",
				name = "[Gamepad] Use PriceTooltip Menu",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UsePriceTooltipMenuGamepad end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UsePriceTooltipMenuGamepad = newValue end,
			},
		},
	},
	{
		type = "submenu",
		name = "Low price indicator",
		controls =
		{
			{
				type = "checkbox",
				name = "Use low price indicator for tooltip",
				tooltip = "Shows low price indicator in tooltip, if price is lower or equal vendor price or if price is lower than profit price (if enabled)",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.LowPriceIndicatorTooltip end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.LowPriceIndicatorTooltip = newValue end,
			},
			{
				type = "checkbox",
				name = "[Keyboard] Use low price indicator for grid",
				tooltip = "Works when override grid price is enabled",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.LowPriceIndicatorGrid end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.LowPriceIndicatorGrid = newValue end
			},
			{
				type = "colorpicker",
				name = "Vendor price indicator color",
				width = "half",
				getFunc = function()
					return
					PriceTooltip.SavedVariables.VendorPriceLowPriceIndicatorColor.Red,
					PriceTooltip.SavedVariables.VendorPriceLowPriceIndicatorColor.Green,
					PriceTooltip.SavedVariables.VendorPriceLowPriceIndicatorColor.Blue
				end,
				setFunc = function(r, g, b)
					PriceTooltip.SavedVariables.VendorPriceLowPriceIndicatorColor.Red = r
					PriceTooltip.SavedVariables.VendorPriceLowPriceIndicatorColor.Green = g
					PriceTooltip.SavedVariables.VendorPriceLowPriceIndicatorColor.Blue = b
				end
			},
			{
				type = "colorpicker",
				name = "Profit price indicator color",
				tooltip = "Works when profit price is enabled",
				width = "half",
				getFunc = function()
					return
					PriceTooltip.SavedVariables.ProfitPriceLowPriceIndicatorColor.Red,
					PriceTooltip.SavedVariables.ProfitPriceLowPriceIndicatorColor.Green,
					PriceTooltip.SavedVariables.ProfitPriceLowPriceIndicatorColor.Blue
				end,
				setFunc = function(r, g, b)
					PriceTooltip.SavedVariables.ProfitPriceLowPriceIndicatorColor.Red = r
					PriceTooltip.SavedVariables.ProfitPriceLowPriceIndicatorColor.Green = g
					PriceTooltip.SavedVariables.ProfitPriceLowPriceIndicatorColor.Blue = b
				end
			},
		}
	},
	{
		type = "submenu",
		name = "[Keyboard] Grid sort settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Use grid sort",
				tooltip = "Enabled grid sort",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UseGridSort end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UseGridSort = newValue end,
				requiresReload = true,
			},
			{
				type = "checkbox",
				name = "Use Grid Cache Modus",
				tooltip = "Cache Modus improves perfomance, but does not work fine when you change some PT settings without reloadui",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UseGridCacheModus end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UseGridCacheModus = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridSort) end
			},
			{
				type = "checkbox",
				name = "Sort by stack value",
				tooltip = "Sort by stack * item value instead only item value",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.SortGridByStackValue end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.SortGridByStackValue = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridSort) end
			},
			{
				type = "dropdown",
				name = "Grid sort behaviour",
				tooltip = "Set the behaviour of the grid sort",
				width = "half",
				choices = {PRICE_TOOLTIP_DEFAULT_PRICE, PRICE_TOOLTIP_AVERAGE_PRICE, PRICE_TOOLTIP_MM_PRICE, PRICE_TOOLTIP_TTC_PRICE, PRICE_TOOLTIP_ATT_PRICE, PRICE_TOOLTIP_UESP_PRICE, PRICE_TOOLTIP_BEST_PRICE, PRICE_TOOLTIP_PROFIT_PRICE},
				getFunc = function() return PriceTooltip.SavedVariables.GridSortBehaviour end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.GridSortBehaviour = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridSort) end
			},
			{
				type = "divider",
				width = "full",
			},
			{
				type = "checkbox",
				name = "Use new Sort Button",
				width = "full",
				getFunc = function() return PriceTooltip.SavedVariables.UseNewSortButton end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UseNewSortButton = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridSort) end,
				requiresReload = true
			},
			{
                type = "editbox",
                name = "PT Value Sort Name",
                tooltip = "Sort Name for PT Value (default PTV)",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.SortNamePTV end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.SortNamePTV = newValue end,
                isMultiline = false,
                default = "PTV",
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridSort)
					or (not PriceTooltip.SavedVariables.UseNewSortButton) end,
				requiresReload = true
			},
			{
				type = "slider",
				name = "Move PT Value Sort",
				tooltip = "Change the position of PT Value Sort (default -65)",
				width = "half",
				min = -1000,
				max = 1000,
				step = 1,
				getFunc = function() return PriceTooltip.SavedVariables.PTValueSortPositionX end,
				setFunc = function(newValue)
					PriceTooltip.SavedVariables.PTValueSortPositionX = newValue
					PriceTooltip_UpdateAllSortByValueHeader()
				end,
                default = -65,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridSort)
					or (not PriceTooltip.SavedVariables.UseNewSortButton) end
			},
			{
				type = "checkbox",
				name = "Replace Standard Value Sort",
				tooltip = "Replace Standard Value Sort with PT Sort",
				width = "full",
				getFunc = function() return PriceTooltip.SavedVariables.ReplaceStandardValueSort end,
				setFunc = function(newValue)
					PriceTooltip.SavedVariables.ReplaceStandardValueSort = newValue
					PriceTooltip_UpdateAllSortByValueHeader()
				end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridSort)
					or (not PriceTooltip.SavedVariables.UseNewSortButton) end
			},
			{
				type = "checkbox",
				name = "Enable move for Standard Value Sort",
				tooltip = "Allows to move Standard Sort Value",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.EnableMoveStandardValueSort end,
				setFunc = function(newValue)
					PriceTooltip.SavedVariables.EnableMoveStandardValueSort = newValue
					PriceTooltip_UpdateAllSortByValueHeader()
				end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridSort)
					or (not PriceTooltip.SavedVariables.UseNewSortButton)
					or (PriceTooltip.SavedVariables.ReplaceStandardValueSort) end
			},
			{
				type = "slider",
				name = "Move Standard Value Sort",
				tooltip = "Change the position of standard Value Sort (default -100)",
				width = "half",
				min = -1000,
				max = 1000,
				step = 1,
				getFunc = function() return PriceTooltip.SavedVariables.StandardValueSortPositionX end,
				setFunc = function(newValue)
					PriceTooltip.SavedVariables.StandardValueSortPositionX = newValue
					PriceTooltip_UpdateAllSortByValueHeader()
				end,
                default = -100,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridSort)
					or (not PriceTooltip.SavedVariables.UseNewSortButton)
					or (not PriceTooltip.SavedVariables.EnableMoveStandardValueSort)
					or (PriceTooltip.SavedVariables.ReplaceStandardValueSort) end
			},
		}
	},
	{
		type = "submenu",
		name = "[Keyboard] Override settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Override grid price",
				tooltip = "Overrides the item price in grid",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UseGridItemPriceOverride end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UseGridItemPriceOverride = newValue end,
				requiresReload = true,
			},
			{
				type = "dropdown",
				name = "Grid price override behaviour",
				tooltip = "Set the behaviour of the override grid price",
				width = "half",
				choices = {PRICE_TOOLTIP_DEFAULT_PRICE, PRICE_TOOLTIP_AVERAGE_PRICE, PRICE_TOOLTIP_MM_PRICE, PRICE_TOOLTIP_TTC_PRICE, PRICE_TOOLTIP_ATT_PRICE, PRICE_TOOLTIP_UESP_PRICE, PRICE_TOOLTIP_BEST_PRICE, PRICE_TOOLTIP_PROFIT_PRICE},
				getFunc = function() return PriceTooltip.SavedVariables.GridItemPriceOverrideBehaviour end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.GridItemPriceOverrideBehaviour = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridItemPriceOverride) end,
			},
			{
				type = "checkbox",
				name = "Use min item price color",
				tooltip = "Change the color if the price has specific value",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.UseMinItemGridPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.UseMinItemGridPrice = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridItemPriceOverride) end,
			},
			{
				type = "slider",
				name = "Min price for color change",
				tooltip = "Change the color of the price if higher or equal to this price",
				width = "half",
				min = 1,
				max = 10000,
				step = 1,
				getFunc = function() return PriceTooltip.SavedVariables.MinItemGridPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.MinItemGridPrice = newValue end,
				disabled = function() return not (PriceTooltip.SavedVariables.UseGridItemPriceOverride and PriceTooltip.SavedVariables.UseMinItemGridPrice) end,
			},
			{
				type = "checkbox",
				name = "Switch single price to top and stack price to bottom",
				tooltip = "Show the single price on top and stack price on bottom in grid",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.ShowSingleItemPriceInGrid end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.ShowSingleItemPriceInGrid = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridItemPriceOverride) end,
			},
			{
				type = "colorpicker",
				name = "Grid price color",
				tooltip = "Colors the price to other color if: 1. Min price is enabled and the new price is higher or equal to defined min price. 2. Min price is disabled and new price is different than vendor price.",
				width = "half",
				getFunc = function()
					return
					PriceTooltip.SavedVariables.GridPriceColor.Red,
					PriceTooltip.SavedVariables.GridPriceColor.Green,
					PriceTooltip.SavedVariables.GridPriceColor.Blue
				end,
				setFunc = function(r, g, b)
					PriceTooltip.SavedVariables.GridPriceColor.Red = r
					PriceTooltip.SavedVariables.GridPriceColor.Green = g
					PriceTooltip.SavedVariables.GridPriceColor.Blue = b
				end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridItemPriceOverride) end,
			},
			{
				type = "checkbox",
				name = "Enable first price (top position)",
				tooltip = "Show the first price in grid (top position)",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.EnableFirstPriceInGrid end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.EnableFirstPriceInGrid = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridItemPriceOverride) end,
			},
			{
				type = "checkbox",
				name = "Enable second price (bottom position)",
				tooltip = "Show the second price in grid (bottom position)",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.EnableSecondPriceInGrid end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.EnableSecondPriceInGrid = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridItemPriceOverride) end,
			},
			{
				type = "checkbox",
				name = "Override Master Merchant",
				tooltip = "Override Master Merchant Grid price option",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.OverrideMM end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.OverrideMM = newValue end,
				disabled = function() return (not PriceTooltip.SavedVariables.UseGridItemPriceOverride) end,
				requiresReload = true,
			},
		},
	},
	{
		type = "submenu",
		name = "Price settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Display vendor price tooltip",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.DisplayVendorPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayVendorPrice = newValue end
			},
			{
				type = "checkbox",
				name = "Round price to nearest gold",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.RoundPrice end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.RoundPrice = newValue end
			},
			{
				type = "submenu",
				name = "Profit price settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Use profit price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.UseProfitPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.UseProfitPrice = newValue end,
					},
					{
						type = "checkbox",
						name = "Display profit price tooltip",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.DisplayProfitPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayProfitPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseProfitPrice) end
					},
					{
						type = "slider",
						name = "Scale profit price",
						tooltip = "Scales profit price by percent (%)",
						width = "full",
						min = 10,
						max = 200,
						step = 1,
						getFunc = function() return PriceTooltip.SavedVariables.ScaleProfitPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.ScaleProfitPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseProfitPrice) end
					}
				}
			},
			{
				type = "submenu",
				name = "TTC price settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Use TTC price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.UseTTCPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.UseTTCPrice = newValue end,
					},
					{
						type = "slider",
						name = "Scale original TTC price",
						tooltip = "Scales original TTC price by percent (%)",
						width = "half",
						min = -50,
						max = 50,
						step = 1,
						getFunc = function() return PriceTooltip.SavedVariables.ScaleTTCPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.ScaleTTCPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseTTCPrice) end
					},
					{
						type = "checkbox",
						name = "Include ALT TTC price",
						tooltip = "Set Alternative Average TTC price when no suggested TTC price exists",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.IncludeAvgTTCPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.IncludeAvgTTCPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseTTCPrice) end
					},
					{
						type = "slider",
						name = "Scale ALT TTC price",
						tooltip = "Scales Alternative Average TTC price by percent (%)",
						width = "half",
						min = -50,
						max = 50,
						step = 1,
						getFunc = function() return PriceTooltip.SavedVariables.ScaleAvgTTCPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.ScaleAvgTTCPrice = newValue end,
						disabled = function() return not (PriceTooltip.SavedVariables.UseTTCPrice and PriceTooltip.SavedVariables.IncludeAvgTTCPrice) end
					},
					{
						type = "colorpicker",
						name = "ALT TTC price color",
						tooltip = "Overrides some colors when price includes Alternative Average TTC price",
						width = "full",
						getFunc = function()
							return
							PriceTooltip.SavedVariables.AvgTTCPriceColor.Red,
							PriceTooltip.SavedVariables.AvgTTCPriceColor.Green,
							PriceTooltip.SavedVariables.AvgTTCPriceColor.Blue
						end,
						setFunc = function(r, g, b)
							PriceTooltip.SavedVariables.AvgTTCPriceColor.Red = r
							PriceTooltip.SavedVariables.AvgTTCPriceColor.Green = g
							PriceTooltip.SavedVariables.AvgTTCPriceColor.Blue = b
						end,
						disabled = function() return not (PriceTooltip.SavedVariables.UseTTCPrice and PriceTooltip.SavedVariables.IncludeAvgTTCPrice) end
					},
					{
						type = "checkbox",
						name = "Display TTC price in tooltip",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.DisplayTTCPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayTTCPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseTTCPrice) end
					},
					{
						type = "checkbox",
						name = "Display original TTC price info in tooltip",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.DisplayTTCPriceInfo end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayTTCPriceInfo = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseTTCPrice) end
					}
				}
			},
			{
				type = "submenu",
				name = "MM price settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Use MM price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.UseMMPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.UseMMPrice = newValue end,
					},
					{
						type = "slider",
						name = "Scale MM price",
						tooltip = "Scales MM price by percent (%)",
						width = "half",
						min = -50,
						max = 50,
						step = 1,
						getFunc = function() return PriceTooltip.SavedVariables.ScaleMMPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.ScaleMMPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseMMPrice) end
					},
					{
						type = "checkbox",
						name = "Display MM price in tooltip",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.DisplayMMPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayMMPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseMMPrice) end
					},
					{
						type = "checkbox",
						name = "Display original MM price info in tooltip",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.DisplayMMPriceInfo end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayMMPriceInfo = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseMMPrice) end
					}
				}
			},
			{
				type = "submenu",
				name = "ATT price settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Use ATT price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.UseATTPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.UseATTPrice = newValue end,
					},
					{
						type = "slider",
						name = "Scale ATT price",
						tooltip = "Scales ATT price by percent (%)",
						width = "half",
						min = -50,
						max = 50,
						step = 1,
						getFunc = function() return PriceTooltip.SavedVariables.ScaleATTPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.ScaleATTPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseATTPrice) end
					},
					{
						type = "slider",
						name = "ATT price days range",
						tooltip = "Calculate ATT price for this amount of days",
						width = "half",
						min = 1,
						max = 30,
						step = 1,
						getFunc = function() return PriceTooltip.SavedVariables.ATTDays end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.ATTDays = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseATTPrice) end
					},
					{
						type = "checkbox",
						name = "Display ATT price tooltip",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.DisplayATTPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayATTPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseATTPrice) end
					},
					{
						type = "checkbox",
						name = "Display original ATT price info in tooltip",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.DisplayATTPriceInfo end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayATTPriceInfo = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseATTPrice) end
					}
				}
			},
			{
				type = "submenu",
				name = "UESP price settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Use UESP price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.UseUESPPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.UseUESPPrice = newValue end,
					},
					{
						type = "slider",
						name = "Scale UESP price",
						tooltip = "Scales UESP price by percent (%)",
						width = "half",
						min = -50,
						max = 50,
						step = 1,
						getFunc = function() return PriceTooltip.SavedVariables.ScaleUESPPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.ScaleUESPPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseUESPPrice) end
					},
					{
						type = "checkbox",
						name = "Display UESP price tooltip",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.DisplayUESPPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayUESPPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseUESPPrice) end
					},
					--{
					--	type = "checkbox",
					--	name = "Display original UESP price info in tooltip",
					--	width = "half",
					--	getFunc = function() return PriceTooltip.SavedVariables.DisplayUESPPriceInfo end,
					--	setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayUESPPriceInfo = newValue end,
					--	disabled = function() return (not PriceTooltip.SavedVariables.UseUESPPrice) end
					--}
				}
			},
			{
				type = "submenu",
				name = "Average (trade) price settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Use average (trade) price",
						tooltip = "Use average (trade) price from enabled scaled prices: MM, TTC, ATT",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.UseAveragePrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.UseAveragePrice = newValue end,
					},
					{
						type = "checkbox",
						name = "Display average (trade) price tooltip",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.DisplayAveragePrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayAveragePrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseAveragePrice) end
					},
					{
						type = "checkbox",
						name = "Include TTC price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.IncludeTTCInAP end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.IncludeTTCInAP = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseAveragePrice) end
					},
					{
						type = "checkbox",
						name = "Include TTC ALT price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.IncludeTTCAvgInAP end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.IncludeTTCAvgInAP = newValue end,
						disabled = function() return not (PriceTooltip.SavedVariables.UseAveragePrice and PriceTooltip.SavedVariables.IncludeTTCInAP) end
					},
					{
						type = "checkbox",
						name = "Include MM price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.IncludeMMInAP end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.IncludeMMInAP = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseAveragePrice) end
					},
					{
						type = "checkbox",
						name = "Include ATT price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.IncludeATTInAP end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.IncludeATTInAP = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseAveragePrice) end
					},
					{
						type = "checkbox",
						name = "Include UESP price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.IncludeUESPInAP end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.IncludeUESPInAP = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseAveragePrice) end
					},
				}
			},
			{
				type = "submenu",
				name = "Best price settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Use best price",
						tooltip = "Use best price from enabled scaled prices: Profit, MM, TTC, ATT",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.UseBestPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.UseBestPrice = newValue end,
					},
					{
						type = "checkbox",
						name = "Display best price tooltip",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.DisplayBestPrice end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.DisplayBestPrice = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseBestPrice) end
					},
					{
						type = "checkbox",
						name = "Include TTC ALT price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.IncludeTTCAvgInBP end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.IncludeTTCAvgInBP = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseBestPrice) end
					},
					{
						type = "checkbox",
						name = "Include profit price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.IncludePPInBP end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.IncludePPInBP = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseBestPrice) end
					},
					{
						type = "checkbox",
						name = "Display source of the price",
						width = "half",
						getFunc = function() return PriceTooltip.SavedVariables.DisplaySourceInBP end,
						setFunc = function(newValue) PriceTooltip.SavedVariables.DisplaySourceInBP = newValue end,
						disabled = function() return (not PriceTooltip.SavedVariables.UseBestPrice) end
					},
				}
			}
		}
	},
	{
		type = "submenu",
		name = "Beta fix",
		controls =
		{
			{
				type = "checkbox",
				name = "Double tooltip fix",
				width = "half",
				getFunc = function() return PriceTooltip.SavedVariables.FixDoubleTooltip end,
				setFunc = function(newValue) PriceTooltip.SavedVariables.FixDoubleTooltip = newValue end
			}
		}
	},
}


PriceTooltip_MENU.Init = function()
	LibAddonMenu2:RegisterAddonPanel("PRICE_TOOLTIP_SETTINGS", PriceTooltip_MENU.PanelData)
	LibAddonMenu2:RegisterOptionControls("PRICE_TOOLTIP_SETTINGS", PriceTooltip_MENU.OptionData)
end