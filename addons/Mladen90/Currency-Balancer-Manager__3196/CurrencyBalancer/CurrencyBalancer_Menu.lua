CurrencyBalancer_MENU.LAM2 = LibAddonMenu2


CurrencyBalancer_MENU.PanelData =
{
	type = "panel",
	name = "Currency Balancer",
	displayName = "Currency Balancer",
	author = "Mladen90 (@Mladen90 EU)",
	version = CurrencyBalancer.StringVersion,
	registerForRefresh = true
}


CurrencyBalancer_MENU.OptionData = 
{
	{
		type = "header",
		name = "Settings"
	},
	{
		type = "dropdown",
		name = "Thousand separator",
		tooltip = "Separator to split thousand values",
		width = "half",
		choices = {"'", ",", ".", "_", CURRENCY_BALANCER_SPACE, CURRENCY_BALANCER_EMPTY},
		getFunc = function() return CurrencyBalancer.SavedVariables.Separator end,
		setFunc = function(newValue) CurrencyBalancer.SavedVariables.Separator = newValue end
	},
	{
		type = "submenu",
		name = "Balance settings",
		controls =
		{
			{
				type = "colorpicker",
				name = "Balancing Log Color",
				width = "half",
				getFunc = function()
					return
					CurrencyBalancer.SavedVariables.LogColor.Red,
					CurrencyBalancer.SavedVariables.LogColor.Green,
					CurrencyBalancer.SavedVariables.LogColor.Blue
				end,
				setFunc = function(r, g, b)
					CurrencyBalancer.SavedVariables.LogColor.Red = r
					CurrencyBalancer.SavedVariables.LogColor.Green = g
					CurrencyBalancer.SavedVariables.LogColor.Blue = b
				end
			},
			{
				type = "submenu",
				name = "Gold settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Enable Gold Inventory Balance",
						tooltip = "When checked, balances your Gold in Inventory when opening Bank",
						width = "half",
						getFunc = function() return CurrencyBalancer.SavedVariables.UseBalanceGold end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.UseBalanceGold = newValue end
					},
					{
						type = "checkbox",
						name = "Log Gold changes",
						tooltip = "Logs the changes in Gold when opening Bank",
						width = "half",
						getFunc = function() return CurrencyBalancer.SavedVariables.LogBalanceGold end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.LogBalanceGold = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseBalanceGold) end
					},
					{
						type = "slider",
						name = "Gold Amount to hold",
						tooltip = "Amount of Gold to hold when opening Bank",
						width = "full",
						min = 0,
						max = 1000000,
						step = 1,
						getFunc = function() return CurrencyBalancer.SavedVariables.BalanceGold end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.BalanceGold = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseBalanceGold) end
					},
				}
			},
			{
				type = "submenu",
				name = "Alliance Point settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Enable AP Inventory Balance",
						tooltip = "When checked, balances your AP in Inventory when opening Bank",
						width = "half",
						getFunc = function() return CurrencyBalancer.SavedVariables.UseBalanceAP end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.UseBalanceAP = newValue end
					},
					{
						type = "checkbox",
						name = "Log AP changes",
						tooltip = "Logs the changes in AP when opening Bank",
						width = "half",
						getFunc = function() return CurrencyBalancer.SavedVariables.LogBalanceAP end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.LogBalanceAP = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseBalanceAP) end
					},
					{
						type = "slider",
						name = "AP Amount to hold",
						tooltip = "Amount of AP to hold when opening Bank",
						width = "full",
						min = 0,
						max = 1000000,
						step = 1,
						getFunc = function() return CurrencyBalancer.SavedVariables.BalanceAP end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.BalanceAP = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseBalanceAP) end
					},
				}
			},
			{
				type = "submenu",
				name = "Tel Var settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Enable TV Inventory Balance",
						tooltip = "When checked, balances your TV in Inventory when opening Bank",
						width = "half",
						getFunc = function() return CurrencyBalancer.SavedVariables.UseBalanceTV end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.UseBalanceTV = newValue end
					},
					{
						type = "checkbox",
						name = "Log TV changes",
						tooltip = "Logs the changes in TV when opening Bank",
						width = "half",
						getFunc = function() return CurrencyBalancer.SavedVariables.LogBalanceTV end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.LogBalanceTV = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseBalanceTV) end
					},
					{
						type = "slider",
						name = "TV Amount to hold",
						tooltip = "Amount of TV to hold when opening Bank",
						width = "full",
						min = 0,
						max = 10000,
						step = 1,
						getFunc = function() return CurrencyBalancer.SavedVariables.BalanceTV end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.BalanceTV = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseBalanceTV) end
					},
				}
			},
			{
				type = "submenu",
				name = "Writ Voucher settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Enable Writ Voucher Inventory Balance",
						tooltip = "When checked, balances your Writ Voucher in Inventory when opening Bank",
						width = "half",
						getFunc = function() return CurrencyBalancer.SavedVariables.UseBalanceWritVoucher end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.UseBalanceWritVoucher = newValue end
					},
					{
						type = "checkbox",
						name = "Log Writ Voucher changes",
						tooltip = "Logs the changes in Writ Voucher when opening Bank",
						width = "half",
						getFunc = function() return CurrencyBalancer.SavedVariables.LogBalanceWritVoucher end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.LogBalanceWritVoucher = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseBalanceWritVoucher) end
					},
					{
						type = "slider",
						name = "Writ Voucher Amount to hold",
						tooltip = "Amount of Writ Voucher to hold when opening Bank",
						width = "full",
						min = 0,
						max = 10000,
						step = 1,
						getFunc = function() return CurrencyBalancer.SavedVariables.BalanceWritVoucher end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.BalanceWritVoucher = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseBalanceWritVoucher) end
					},
				}
			},
		}
	},
	{
		type = "submenu",
		name = "Warning settings",
		controls =
		{
			{
				type = "colorpicker",
				name = "Warning Log Color",
				width = "half",
				getFunc = function()
					return
					CurrencyBalancer.SavedVariables.LogWarningColor.Red,
					CurrencyBalancer.SavedVariables.LogWarningColor.Green,
					CurrencyBalancer.SavedVariables.LogWarningColor.Blue
				end,
				setFunc = function(r, g, b)
					CurrencyBalancer.SavedVariables.LogWarningColor.Red = r
					CurrencyBalancer.SavedVariables.LogWarningColor.Green = g
					CurrencyBalancer.SavedVariables.LogWarningColor.Blue = b
				end
			},
			{
				type = "slider",
				name = "Warning Timer in Seconds",
				tooltip = "Warning will be checked after this amount of seconds",
				width = "half",
				min = 15,
				max = 3600,
				step = 15,
				getFunc = function() return CurrencyBalancer.SavedVariables.WarningTimer end,
				setFunc = function(newValue) CurrencyBalancer.SavedVariables.WarningTimer = newValue end,
			},
			{
				type = "submenu",
				name = "Tel Var settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Enable TV Warning",
						tooltip = "When checked, gives you a Warning when TV Warning amount is reached",
						width = "half",
						getFunc = function() return CurrencyBalancer.SavedVariables.UseWarningTV end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.UseWarningTV = newValue end
					},
					{
						type = "slider",
						name = "Repeat Warning",
						tooltip = "Warning will be repeated more times",
						width = "half",
						min = 1,
						max = 100,
						step = 1,
						getFunc = function() return CurrencyBalancer.SavedVariables.Repeat_TV_Warning end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.Repeat_TV_Warning = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseWarningTV) end
					},
					{
						type = "slider",
						name = "TV Warning Amount",
						tooltip = "Amount of TV for Warning",
						width = "full",
						min = 0,
						max = 100000,
						step = 1,
						getFunc = function() return CurrencyBalancer.SavedVariables.WarningTV end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.WarningTV = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseWarningTV) end
					},
				}
			},
			{
				type = "submenu",
				name = "Event Ticket settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Enable Event Ticket Warning",
						tooltip = "When checked, gives you a Warning when Event Ticket Warning amount is reached",
						width = "half",
						getFunc = function() return CurrencyBalancer.SavedVariables.UseWarningEventTicket end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.UseWarningEventTicket = newValue end
					},
					{
						type = "slider",
						name = "Repeat Warning",
						tooltip = "Warning will be repeated more times",
						width = "half",
						min = 1,
						max = 100,
						step = 1,
						getFunc = function() return CurrencyBalancer.SavedVariables.Repeat_EventTicket_Warning end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.Repeat_EventTicket_Warning = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseWarningEventTicket) end
					},
					{
						type = "slider",
						name = "Event Ticket Warning Amount",
						tooltip = "Amount of Event Ticket for Warning",
						width = "full",
						min = 0,
						max = 12,
						step = 1,
						getFunc = function() return CurrencyBalancer.SavedVariables.WarningEventTicket end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.WarningEventTicket = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseWarningEventTicket) end
					},
				}
			},
			{
				type = "submenu",
				name = "Transmute Crystal settings",
				controls =
				{
					{
						type = "checkbox",
						name = "Enable Transmute Crystal Warning",
						tooltip = "When checked, gives you a Warning when Transmute Crystal Warning amount is reached",
						width = "half",
						getFunc = function() return CurrencyBalancer.SavedVariables.UseWarningTransmuteCrystal end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.UseWarningTransmuteCrystal = newValue end
					},
					{
						type = "slider",
						name = "Repeat Warning",
						tooltip = "Warning will be repeated more times",
						width = "half",
						min = 1,
						max = 100,
						step = 1,
						getFunc = function() return CurrencyBalancer.SavedVariables.Repeat_TransmuteCrystal_Warning end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.Repeat_TransmuteCrystal_Warning = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseWarningTransmuteCrystal) end
					},
					{
						type = "slider",
						name = "Transmute Crystal Warning Amount",
						tooltip = "Amount of Transmute Crystal for Warning",
						width = "full",
						min = 0,
						max = 1000,
						step = 1,
						getFunc = function() return CurrencyBalancer.SavedVariables.WarningTransmuteCrystal end,
						setFunc = function(newValue) CurrencyBalancer.SavedVariables.WarningTransmuteCrystal = newValue end,
						disabled = function() return (not CurrencyBalancer.SavedVariables.UseWarningTransmuteCrystal) end
					},
				}
			},
		}
	},
}


CurrencyBalancer_MENU.Init = function()
	CurrencyBalancer_MENU.LAM2:RegisterAddonPanel("CURRENCY_BALANCER_SETTINGS", CurrencyBalancer_MENU.PanelData)
	CurrencyBalancer_MENU.LAM2:RegisterOptionControls("CURRENCY_BALANCER_SETTINGS", CurrencyBalancer_MENU.OptionData)
end