local PTTG = PriceTooltip

PriceTTG_MENU.PanelData =
{
	type = "panel",
	name = "Price Tooltip Gamepad",
	displayName = "Price Tooltip Gamepad",
	author = "Mladen90 (@Mladen90 EU), Infixo (CoAuthor), Muffins714 (Gamepad)",
	version = PTTG.StringVersion,
	registerForRefresh = true
}


PriceTTG_MENU.OptionData =
{
	{
		type = "header",
		name = "Format settings"
	},
	{
		type = "dropdown",
		name = "Thousand separator",
		tooltip = "Separator to split thousand values",
		width = "full",
		choices = { "'", ",", ".", "_", PRICE_TOOLTIP_SPACE, PRICE_TOOLTIP_EMPTY },
		getFunc = function() return PTTG.SavedVariables.Separator end,
		setFunc = function(newValue) PTTG.SavedVariables.Separator = newValue end
	},
	{
		type = "checkbox",
		name = "Round price",
		width = "half",
		getFunc = function() return PTTG.SavedVariables.RoundPrice end,
		setFunc = function(newValue) PTTG.SavedVariables.RoundPrice = newValue end
	},
	{
		type = "colorpicker",
		name = "Tooltip Color",
		width = "half",
		getFunc = function()
			return
				PTTG.SavedVariables.TooltipColor.Red,
				PTTG.SavedVariables.TooltipColor.Green,
				PTTG.SavedVariables.TooltipColor.Blue
		end,
		setFunc = function(r, g, b)
			PTTG.SavedVariables.TooltipColor.Red = r
			PTTG.SavedVariables.TooltipColor.Green = g
			PTTG.SavedVariables.TooltipColor.Blue = b
		end
	},
	{
		type = "colorpicker",
		name = "Tooltip info color",
		width = "half",
		getFunc = function()
			return
				PTTG.SavedVariables.TooltipPriceInfoColor.Red,
				PTTG.SavedVariables.TooltipPriceInfoColor.Green,
				PTTG.SavedVariables.TooltipPriceInfoColor.Blue
		end,
		setFunc = function(r, g, b)
			PTTG.SavedVariables.TooltipPriceInfoColor.Red = r
			PTTG.SavedVariables.TooltipPriceInfoColor.Green = g
			PTTG.SavedVariables.TooltipPriceInfoColor.Blue = b
		end
	},
	{
		type = "checkbox",
		name = "Remove Startup messages",
		tooltip = "Removes messages on Startup except 'Initialized'",
		width = "half",
		getFunc = function() return PTTG.SavedVariables.DisableStartupLog end,
		setFunc = function(newValue) PTTG.SavedVariables.DisableStartupLog = newValue end,
	},
	{
		type = "checkbox",
		name = "Display Material Cost (Crafting Table)",
		tooltip = "Material cost at the crafting station. Doesn't account for multicraft yield bonuses.",
		width = "half",
		getFunc = function() return PTTG.SavedVariables.DisplayCraftCost end,
		setFunc = function(newValue) PTTG.SavedVariables.DisplayCraftCost = newValue end
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
				getFunc = function() return PTTG.SavedVariables.BoundItemsAsVendorPrice end,
				setFunc = function(newValue) PTTG.SavedVariables.BoundItemsAsVendorPrice = newValue end,
				requiresReload = true,
			},
			{
				type = "checkbox",
				name = "Indicator",
				width = "half",
				getFunc = function() return PTTG.SavedVariables.MarkBoundItems end,
				setFunc = function(newValue) PTTG.SavedVariables.MarkBoundItems = newValue end
			},
			{
				type = "colorpicker",
				name = "Indicator Color",
				width = "full",
				getFunc = function()
					return
						PTTG.SavedVariables.BoundItemMarkColor.Red,
						PTTG.SavedVariables.BoundItemMarkColor.Green,
						PTTG.SavedVariables.BoundItemMarkColor.Blue
				end,
				setFunc = function(r, g, b)
					PTTG.SavedVariables.BoundItemMarkColor.Red = r
					PTTG.SavedVariables.BoundItemMarkColor.Green = g
					PTTG.SavedVariables.BoundItemMarkColor.Blue = b
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
				name = "[Gamepad] Tooltip Font",
				tooltip = "Font for the price in tooltip",
				width = "half",
				choices = PriceTTG_GamepadStyles,
				getFunc = function() return PTTG.SavedVariables.GamepadFont end,
				setFunc = function(newValue) PTTG.SavedVariables.GamepadFont = newValue end
			},
			{
				type = "dropdown",
				name = "[Gamepad] Tooltip Info Font",
				tooltip = "Font for the info in tooltip",
				width = "half",
				choices = PriceTTG_GamepadStyles,
				getFunc = function() return PTTG.SavedVariables.GamepadPriceInfoFont end,
				setFunc = function(newValue) PTTG.SavedVariables.GamepadPriceInfoFont = newValue end
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
						PTTG.SavedVariables.ContextMenuColor.Red,
						PTTG.SavedVariables.ContextMenuColor.Green,
						PTTG.SavedVariables.ContextMenuColor.Blue
				end,
				setFunc = function(r, g, b)
					PTTG.SavedVariables.ContextMenuColor.Red = r
					PTTG.SavedVariables.ContextMenuColor.Green = g
					PTTG.SavedVariables.ContextMenuColor.Blue = b
				end,
			},
			{
				type = "checkbox",
				name = "[Gamepad] Use PTTG Menu",
				width = "half",
				getFunc = function() return PTTG.SavedVariables.UsePriceTooltipMenuGamepad end,
				setFunc = function(newValue) PTTG.SavedVariables.UsePriceTooltipMenuGamepad = newValue end,
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
				tooltip =
				"Shows low price indicator in tooltip, if price is lower or equal vendor price or if price is lower than profit price (if enabled)",
				width = "half",
				getFunc = function() return PTTG.SavedVariables.LowPriceIndicatorTooltip end,
				setFunc = function(newValue) PTTG.SavedVariables.LowPriceIndicatorTooltip = newValue end,
			},
			{
				type = "colorpicker",
				name = "Vendor price indicator color",
				width = "half",
				getFunc = function()
					return
						PTTG.SavedVariables.VendorPriceLowPriceIndicatorColor.Red,
						PTTG.SavedVariables.VendorPriceLowPriceIndicatorColor.Green,
						PTTG.SavedVariables.VendorPriceLowPriceIndicatorColor.Blue
				end,
				setFunc = function(r, g, b)
					PTTG.SavedVariables.VendorPriceLowPriceIndicatorColor.Red = r
					PTTG.SavedVariables.VendorPriceLowPriceIndicatorColor.Green = g
					PTTG.SavedVariables.VendorPriceLowPriceIndicatorColor.Blue = b
				end
			},
			{
				type = "colorpicker",
				name = "Profit price indicator color",
				tooltip = "Works when profit price is enabled",
				width = "half",
				getFunc = function()
					return
						PTTG.SavedVariables.ProfitPriceLowPriceIndicatorColor.Red,
						PTTG.SavedVariables.ProfitPriceLowPriceIndicatorColor.Green,
						PTTG.SavedVariables.ProfitPriceLowPriceIndicatorColor.Blue
				end,
				setFunc = function(r, g, b)
					PTTG.SavedVariables.ProfitPriceLowPriceIndicatorColor.Red = r
					PTTG.SavedVariables.ProfitPriceLowPriceIndicatorColor.Green = g
					PTTG.SavedVariables.ProfitPriceLowPriceIndicatorColor.Blue = b
				end
			},
		}
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
				getFunc = function() return PTTG.SavedVariables.DisplayVendorPrice end,
				setFunc = function(newValue) PTTG.SavedVariables.DisplayVendorPrice = newValue end
			},
			{
				type = "checkbox",
				name = "Round price to nearest gold",
				width = "half",
				getFunc = function() return PTTG.SavedVariables.RoundPrice end,
				setFunc = function(newValue) PTTG.SavedVariables.RoundPrice = newValue end
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
						getFunc = function() return PTTG.SavedVariables.UseProfitPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.UseProfitPrice = newValue end,
					},
					{
						type = "checkbox",
						name = "Display profit price tooltip",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.DisplayProfitPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.DisplayProfitPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseProfitPrice) end
					},
					{
						type = "slider",
						name = "Scale profit price",
						tooltip = "Scales profit price by percent (%)",
						width = "full",
						min = 10,
						max = 200,
						step = 1,
						getFunc = function() return PTTG.SavedVariables.ScaleProfitPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.ScaleProfitPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseProfitPrice) end
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
						getFunc = function() return PTTG.SavedVariables.UseTTCPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.UseTTCPrice = newValue end,
					},
					{
						type = "slider",
						name = "Scale original TTC price",
						tooltip = "Scales original TTC price by percent (%)",
						width = "half",
						min = -50,
						max = 50,
						step = 1,
						getFunc = function() return PTTG.SavedVariables.ScaleTTCPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.ScaleTTCPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseTTCPrice) end
					},
					{
						type = "checkbox",
						name = "Include ALT TTC price",
						tooltip = "Set Alternative Average TTC price when no suggested TTC price exists",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.IncludeAvgTTCPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.IncludeAvgTTCPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseTTCPrice) end
					},
					{
						type = "slider",
						name = "Scale ALT TTC price",
						tooltip = "Scales Alternative Average TTC price by percent (%)",
						width = "half",
						min = -50,
						max = 50,
						step = 1,
						getFunc = function() return PTTG.SavedVariables.ScaleAvgTTCPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.ScaleAvgTTCPrice = newValue end,
						disabled = function() return not (PTTG.SavedVariables.UseTTCPrice and PTTG.SavedVariables.IncludeAvgTTCPrice) end
					},
					{
						type = "colorpicker",
						name = "ALT TTC price color",
						tooltip = "Overrides some colors when price includes Alternative Average TTC price",
						width = "full",
						getFunc = function()
							return
								PTTG.SavedVariables.AvgTTCPriceColor.Red,
								PTTG.SavedVariables.AvgTTCPriceColor.Green,
								PTTG.SavedVariables.AvgTTCPriceColor.Blue
						end,
						setFunc = function(r, g, b)
							PTTG.SavedVariables.AvgTTCPriceColor.Red = r
							PTTG.SavedVariables.AvgTTCPriceColor.Green = g
							PTTG.SavedVariables.AvgTTCPriceColor.Blue = b
						end,
						disabled = function() return not (PTTG.SavedVariables.UseTTCPrice and PTTG.SavedVariables.IncludeAvgTTCPrice) end
					},
					{
						type = "checkbox",
						name = "Display TTC price in tooltip",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.DisplayTTCPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.DisplayTTCPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseTTCPrice) end
					},
					{
						type = "checkbox",
						name = "Display original TTC",
						tooltip = "Display Avg, Min, Max TTC price info in tooltip",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.DisplayTTCPriceInfo end,
						setFunc = function(newValue) PTTG.SavedVariables.DisplayTTCPriceInfo = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseTTCPrice) end
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
						getFunc = function() return PTTG.SavedVariables.UseMMPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.UseMMPrice = newValue end,
					},
					{
						type = "slider",
						name = "Scale MM price",
						tooltip = "Scales MM price by percent (%)",
						width = "half",
						min = -50,
						max = 50,
						step = 1,
						getFunc = function() return PTTG.SavedVariables.ScaleMMPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.ScaleMMPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseMMPrice) end
					},
					{
						type = "checkbox",
						name = "Display MM price in tooltip",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.DisplayMMPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.DisplayMMPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseMMPrice) end
					},
					{
						type = "checkbox",
						name = "Display original MM price",
						tooltip = "Display Avg, Min, Max MM price info in tooltip",

						width = "half",
						getFunc = function() return PTTG.SavedVariables.DisplayMMPriceInfo end,
						setFunc = function(newValue) PTTG.SavedVariables.DisplayMMPriceInfo = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseMMPrice) end
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
						getFunc = function() return PTTG.SavedVariables.UseATTPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.UseATTPrice = newValue end,
					},
					{
						type = "slider",
						name = "Scale ATT price",
						tooltip = "Scales ATT price by percent (%)",
						width = "half",
						min = -50,
						max = 50,
						step = 1,
						getFunc = function() return PTTG.SavedVariables.ScaleATTPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.ScaleATTPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseATTPrice) end
					},
					{
						type = "slider",
						name = "ATT price days range",
						tooltip = "Calculate ATT price for this amount of days",
						width = "half",
						min = 1,
						max = 30,
						step = 1,
						getFunc = function() return PTTG.SavedVariables.ATTDays end,
						setFunc = function(newValue) PTTG.SavedVariables.ATTDays = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseATTPrice) end
					},
					{
						type = "checkbox",
						name = "Display ATT price tooltip",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.DisplayATTPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.DisplayATTPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseATTPrice) end
					},
					{
						type = "checkbox",
						name = "Display original ATT price",
						tooltip = "Display Avg, Min, Max ATT price info in tooltip",

						width = "half",
						getFunc = function() return PTTG.SavedVariables.DisplayATTPriceInfo end,
						setFunc = function(newValue) PTTG.SavedVariables.DisplayATTPriceInfo = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseATTPrice) end
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
						getFunc = function() return PTTG.SavedVariables.UseUESPPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.UseUESPPrice = newValue end,
					},
					{
						type = "slider",
						name = "Scale UESP price",
						tooltip = "Scales UESP price by percent (%)",
						width = "half",
						min = -50,
						max = 50,
						step = 1,
						getFunc = function() return PTTG.SavedVariables.ScaleUESPPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.ScaleUESPPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseUESPPrice) end
					},
					{
						type = "checkbox",
						name = "Display UESP price tooltip",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.DisplayUESPPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.DisplayUESPPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseUESPPrice) end
					},
					--{
					--	type = "checkbox",
					--	name = "Display original UESP price info in tooltip",
					--	width = "half",
					--	getFunc = function() return PTTG.SavedVariables.DisplayUESPPriceInfo end,
					--	setFunc = function(newValue) PTTG.SavedVariables.DisplayUESPPriceInfo = newValue end,
					--	disabled = function() return (not PTTG.SavedVariables.UseUESPPrice) end
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
						tooltip = "Use average (trade) price from enabled scaled prices: MM, TTC",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.UseAveragePrice end,
						setFunc = function(newValue) PTTG.SavedVariables.UseAveragePrice = newValue end,
					},
					{
						type = "checkbox",
						name = "Display average (trade) price tooltip",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.DisplayAveragePrice end,
						setFunc = function(newValue) PTTG.SavedVariables.DisplayAveragePrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseAveragePrice) end
					},
					{
						type = "checkbox",
						name = "Include TTC price",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.IncludeTTCInAP end,
						setFunc = function(newValue) PTTG.SavedVariables.IncludeTTCInAP = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseAveragePrice) end
					},
					{
						type = "checkbox",
						name = "Include TTC ALT price",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.IncludeTTCAvgInAP end,
						setFunc = function(newValue) PTTG.SavedVariables.IncludeTTCAvgInAP = newValue end,
						disabled = function() return not (PTTG.SavedVariables.UseAveragePrice and PTTG.SavedVariables.IncludeTTCInAP) end
					},
					{
						type = "checkbox",
						name = "Include MM price",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.IncludeMMInAP end,
						setFunc = function(newValue) PTTG.SavedVariables.IncludeMMInAP = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseAveragePrice) end
					},
					{
						type = "checkbox",
						name = "Include ATT price",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.IncludeATTInAP end,
						setFunc = function(newValue) PTTG.SavedVariables.IncludeATTInAP = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseAveragePrice) end
					},
					{
						type = "checkbox",
						name = "Include UESP price",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.IncludeUESPInAP end,
						setFunc = function(newValue) PTTG.SavedVariables.IncludeUESPInAP = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseAveragePrice) end
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
						tooltip = "Use best price from enabled scaled prices: Profit, MM, TTC",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.UseBestPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.UseBestPrice = newValue end,
					},
					{
						type = "checkbox",
						name = "Display best price tooltip",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.DisplayBestPrice end,
						setFunc = function(newValue) PTTG.SavedVariables.DisplayBestPrice = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseBestPrice) end
					},
					{
						type = "checkbox",
						name = "Include TTC ALT price",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.IncludeTTCAvgInBP end,
						setFunc = function(newValue) PTTG.SavedVariables.IncludeTTCAvgInBP = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseBestPrice) end
					},
					{
						type = "checkbox",
						name = "Include profit price",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.IncludePPInBP end,
						setFunc = function(newValue) PTTG.SavedVariables.IncludePPInBP = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseBestPrice) end
					},
					{
						type = "checkbox",
						name = "Display source of the price",
						width = "half",
						getFunc = function() return PTTG.SavedVariables.DisplaySourceInBP end,
						setFunc = function(newValue) PTTG.SavedVariables.DisplaySourceInBP = newValue end,
						disabled = function() return (not PTTG.SavedVariables.UseBestPrice) end
					},
				}
			}
		}
	},
	--[[
	{
		type = "submenu",
		name = "Beta fix",
		controls =
		{
			{
				type = "checkbox",
				name = "Double tooltip fix",
				width = "half",
				getFunc = function() return PTTG.SavedVariables.FixDoubleTooltip end,
				setFunc = function(newValue) PTTG.SavedVariables.FixDoubleTooltip = newValue end
			}
		}
	},
	]]
}


PriceTTG_MENU.Init = function()
	LibAddonMenu2:RegisterAddonPanel("PRICE_TOOLTIP_SETTINGS", PriceTTG_MENU.PanelData)
	LibAddonMenu2:RegisterOptionControls("PRICE_TOOLTIP_SETTINGS", PriceTTG_MENU.OptionData)
end
