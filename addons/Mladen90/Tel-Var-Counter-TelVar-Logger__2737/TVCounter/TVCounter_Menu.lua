TVC_MENU.LAM2 = LibAddonMenu2


TVC_MENU.PanelData =
{
	type = "panel",
	name = "Tel Var Counter",
	displayName = "Tel Var Counter",
	author = "Mladen90 (@Mladen90 EU)",
	version = TVC.StringVersion,
	registerForRefresh = true
}


local screenMessageUnLock = false


TVC_MENU.OptionData =
{
	{
		type = "header",
		name = "Settings"
	},
	{
		type = "checkbox",
		name = "Use Tel Var icon",
		tooltip = "When checked, uses icon instead of text for Tel Var",
		width = "half",
		getFunc = function() return TVC.SavedVariables.UseTVIcon end,
		setFunc = function(newValue) TVC.SavedVariables.UseTVIcon = newValue end
	},
	{
		type = "colorpicker",
		name = "Logging Color",
		width = "half",
		getFunc = function()
			return
			TVC.SavedVariables.LogColor.Red,
			TVC.SavedVariables.LogColor.Green,
			TVC.SavedVariables.LogColor.Blue
		end,
		setFunc = function(r, g, b)
			TVC.SavedVariables.LogColor.Red = r
			TVC.SavedVariables.LogColor.Green = g
			TVC.SavedVariables.LogColor.Blue = b
		end
    },
	{
		type = "checkbox",
		name = "Restore tel var",
		tooltip = "When checked, restores tel var after relog/reload",
		width = "half",
		getFunc = function() return TVC.SavedVariables.RestoreTV end,
		setFunc = function(newValue) TVC.SavedVariables.RestoreTV = newValue end
	},
	{
		type = "slider",
		name = "Skip restoring after last gain in mins",
		tooltip = "Skip restoring TV when this amount of minutes elapsed from last TV gain, instead it will reset the data",
		width = "half",
		min = 1,
		max = 120,
		step = 1,
		getFunc = function() return TVC.SavedVariables.SkipRestoreTvAfterMins end,
		setFunc = function(newValue) TVC.SavedVariables.SkipRestoreTvAfterMins = newValue end,
		disabled = function() return (not TVC.SavedVariables.RestoreTV) end
	},
	{
		type = "checkbox",
		name = "Show available commands on startup",
		tooltip = "When checked, shows startup message which commands are available",
		width = "half",
		getFunc = function() return TVC.SavedVariables.ShowAvailableCommandsMessageOnStart end,
		setFunc = function(newValue) TVC.SavedVariables.ShowAvailableCommandsMessageOnStart = newValue end
	},
	{
		type = "dropdown",
		name = "Thousand separator",
		tooltip = "Separator to split thousand values",
		width = "half",
		choices = {"'", ",", ".", "_", TVC_SPACE},
		getFunc = function() return TVC.SavedVariables.Separator end,
		setFunc = function(newValue) TVC.SavedVariables.Separator = newValue end
	},
	{
		type = "submenu",
		name = "Start / Stop settings",
		controls =
		{
			{
				type = "description",
				text = "Counter starts default on Tel Var change",
				width = "full"
			},
			{
				type = "checkbox",
				name = "Start Counter when entering Imperial City",
				width = "full",
				getFunc = function() return TVC.SavedVariables.StartCounterInImperialCity end,
				setFunc = function(newValue) TVC.SavedVariables.StartCounterInImperialCity = newValue end
			},
		}
	},
	{
		type = "submenu",
		name = "TV log settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Log Tel Var to chat",
				tooltip = "When checked, logs Tel Var to chat",
				width = "half",
				getFunc = function() return TVC.SavedVariables.LogEnabled end,
				setFunc = function(newValue) TVC.SavedVariables.LogEnabled = newValue end
			},
			{
				type = "slider",
				name = "Log after this amount of TV",
				tooltip = "Logs each time you get this amount of tel var over time (If set to 1 will show log with TV type, else will show current TV and time)",
				width = "half",
				min = 1,
				max = 10000,
				step = 1,
				getFunc = function() return TVC.SavedVariables.LogTVAmount end,
				setFunc = function(newValue) TVC.SavedVariables.LogTVAmount = newValue end,
				disabled = function() return (not TVC.SavedVariables.LogEnabled) end
			},
			{
				type = "dropdown",
				name = "TV log format",
				tooltip = "Format for logging TV",
				width = "half",
				choices =
				{
					TV_LOG_FORMAT_LONG,
					TV_LOG_FORMAT_NORMAL,
					TV_LOG_FORMAT_SHORT
				},
				getFunc = function() return TVC.SavedVariables.TvLogFormat end,
				setFunc = function(newValue) TVC.SavedVariables.TvLogFormat = newValue end,
				disabled = function() return (not TVC.SavedVariables.LogEnabled) end
			}
		}
	},
	{
		type = "submenu",
		name = "TV screen message settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Unlock position",
				width = "half",
				getFunc = function() return screenMessageUnLock end,
				setFunc = function(newValue)
					screenMessageUnLock = newValue

					TVC.SavedVariables.MainWindowLeft = TVC_FORMS.MainWindow:GetLeft()
					TVC.SavedVariables.MainWindowBottom = TVC_FORMS.MainWindow:GetBottom()

					TVC_FORMS.MainWindow:SetMovable(screenMessageUnLock)
					TVC_FORMS.MainWindow:SetMouseEnabled(screenMessageUnLock)

					if screenMessageUnLock then
						TVC_FORMS.MainWindowBackGround:SetAlpha(1)
						TVC_FORMS.MainWindowText:SetAlpha(0.5)
					else
						TVC_FORMS.MainWindowBackGround:SetAlpha(0)
						TVC_FORMS.MainWindowText:SetAlpha(0)
					end
				end
			},
			{
			    type = "button",
			    name = "Reset position",
				width = "half",
				func = function()
					TVC_FORMS.MainWindow:ClearAnchors()
					TVC_FORMS.MainWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
					TVC.SavedVariables.MainWindowLeft = TVC_FORMS.MainWindow:GetLeft()
					TVC.SavedVariables.MainWindowBottom = TVC_FORMS.MainWindow:GetBottom()
				end
			},
			{
				type = "checkbox",
				name = "Show messages",
				tooltip = "When checked, shows message on screen",
				width = "half",
				getFunc = function() return TVC.SavedVariables.UseScreenMessage end,
				setFunc = function(newValue) TVC.SavedVariables.UseScreenMessage = newValue end
			},
			{
				type = "slider",
				name = "Min. Tel Var gain for message",
				tooltip = "The minimal amount of TV gain to show message",
				width = "half",
				min = 1,
				max = 10000,
				step = 1,
				getFunc = function() return TVC.SavedVariables.ScreenMessageTelVarGain end,
				setFunc = function(newValue) TVC.SavedVariables.ScreenMessageTelVarGain = newValue end,
				disabled = function() return (not TVC.SavedVariables.UseScreenMessage) end
			},
			{
				type = "slider",
				name = "Scale the display message",
				tooltip = "Change the scale of the screen message",
				width = "half",
				min = 25,
				max = 200,
				step = 5,
				getFunc = function() return TVC.SavedVariables.ScreenMessageScaling * 100.0 end,
				setFunc = function(newValue)
					TVC.SavedVariables.ScreenMessageScaling = newValue / 100.0

					TVC_FORMS.MainWindow:SetDimensions(350 * TVC.SavedVariables.ScreenMessageScaling, 80 * TVC.SavedVariables.ScreenMessageScaling)

					TVC_FORMS.MainWindowBackGround:SetDimensions(TVC_FORMS.MainWindow:GetWidth(), TVC_FORMS.MainWindow:GetHeight())
					TVC_FORMS.MainWindowText:SetScale(0.5 * TVC.SavedVariables.ScreenMessageScaling)
				end
			},
			{
				type = "slider",
				name = "Screen message fade time",
				tooltip = "Fades the screen message after this amount of sec",
				width = "half",
				min = 1,
				max = 10,
				step = 1,
				getFunc = function() return TVC.SavedVariables.ScreenMessageFadeTime end,
				setFunc = function(newValue) TVC.SavedVariables.ScreenMessageFadeTime = newValue end,
				disabled = function() return (not TVC.SavedVariables.UseScreenMessage) end
			},
			{
				type = "colorpicker",
				name = "Screen message color",
				tooltip = "Color for the screen message",
				width = "half",
				getFunc = function()
					return
					TVC.SavedVariables.ScreenMessageColor.Red,
					TVC.SavedVariables.ScreenMessageColor.Green,
					TVC.SavedVariables.ScreenMessageColor.Blue
				end,
				setFunc = function(r, g, b)
					TVC.SavedVariables.ScreenMessageColor.Red = r
					TVC.SavedVariables.ScreenMessageColor.Green = g
					TVC.SavedVariables.ScreenMessageColor.Blue = b
				end,
				disabled = function() return (not TVC.SavedVariables.UseScreenMessage) end
			}
		}
	},
	{
		type = "submenu",
		name = "Bank settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Enable TV Inventory Balance",
				tooltip = "When checked, balances your TV in Inventory when opening Bank",
				width = "half",
				getFunc = function() return TVC.SavedVariables.UseBalanceTV end,
				setFunc = function(newValue) TVC.SavedVariables.UseBalanceTV = newValue end
			},
			{
				type = "checkbox",
				name = "Log TV changes",
				tooltip = "Logs the changes when opening Bank",
				width = "half",
				getFunc = function() return TVC.SavedVariables.LogBalance end,
				setFunc = function(newValue) TVC.SavedVariables.LogBalance = newValue end,
				disabled = function() return (not TVC.SavedVariables.UseBalanceTV) end
			},
			{
				type = "slider",
				name = "TV Amount to hold",
				tooltip = "Amount of TV to hold when opening Bank",
				width = "full",
				min = 0,
				max = 10000,
				step = 1,
				getFunc = function() return TVC.SavedVariables.BalanceTV end,
				setFunc = function(newValue) TVC.SavedVariables.BalanceTV = newValue end,
				disabled = function() return (not TVC.SavedVariables.UseBalanceTV) end
			},
		}
	},
	{
		type = "submenu",
		name = "Test buttons",
		controls =
		{
			{
			    type = "button",
			    name = "Test chat text",
				width = "half",
				func = function()
					local tvcTest = "TVCTEST: "

					local reason = TVC_REASON_ARRAY[math.random(1, table.getn(TVC_REASON_ARRAY))]

					local oldTV = math.random(1, 10000)
					if (math.random(0, 1) == 0) then oldTV = -oldTV end

					local diffTV = math.random(1, 10000)
					if (math.random(0, 1) == 0) then diffTV = -diffTV end

					local newTV = oldTV + diffTV

					local minsText = " (" .. TVC_NumberFormat(math.random(0, 100)) .. " mins) "

					local status = TVC_GetBaseTvSourceInfoForDisplay(reason)

					if (TVC.SavedVariables.TvLogFormat == TV_LOG_FORMAT_LONG) then
						TVC_SystemPrint(tvcTest .. status .. " -> " .. TVC_NumberFormat(oldTV) .. TVC_GetTvText() .. " " .. TVC_GetStringSign(diffTV) .. " " .. TVC_NumberFormat(diffTV) .. TVC_GetTvText() .. " = " .. TVC_NumberFormat(newTV) .. TVC_GetTvText() .. minsText)
					elseif (TVC.SavedVariables.TvLogFormat == TV_LOG_FORMAT_NORMAL) then
						TVC_SystemPrint(tvcTest .. status .. " " .. TVC_GetStringSign(diffTV) .. TVC_NumberFormat(diffTV) .. TVC_GetTvText() .. " -> " .. TVC_NumberFormat(newTV) .. TVC_GetTvText() .. minsText)
					else
						TVC_SystemPrint(tvcTest .. status .. " -> " .. TVC_NumberFormat(newTV) .. TVC_GetTvText() .. minsText)
					end
				end
			},
			{
			    type = "button",
			    name = "Test screen message",
				width = "half",
				func = function()
					local tvcTest = "TVCTEST: "
					local difference = math.random(TVC.SavedVariables.ScreenMessageTelVarGain, 10000)
					TVC_FORMS.Functions.DisplayScreenMessage(nil, tvcTest .. TVC_NumberFormat(difference) .. TVC_GetTvText(true))
				end,
				disabled = function() return (not TVC.SavedVariables.UseScreenMessage) end
			}
		}
	}
}


TVC_MENU.Init = function()
	TVC_MENU.LAM2:RegisterAddonPanel("TVC_SETTINGS", TVC_MENU.PanelData)
	TVC_MENU.LAM2:RegisterOptionControls("TVC_SETTINGS", TVC_MENU.OptionData)
end