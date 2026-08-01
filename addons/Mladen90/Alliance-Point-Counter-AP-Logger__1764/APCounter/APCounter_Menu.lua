APC_MENU.LAM2 = LibAddonMenu2


APC_MENU.PanelData =
{
	type = "panel",
	name = "Alliance Points Counter",
	displayName = "Alliance Points Counter",
	author = "Mladen90 (@Mladen90 EU)",
	version = APC.StringVersion,
	registerForRefresh = true
}


local screenMessageUnLock = false


APC_MENU.OptionData = 
{
	{
		type = "header",
		name = "Settings"
	},
	{
		type = "checkbox",
		name = "Use Alliance Point icon",
		tooltip = "When checked, uses icon instead of text for Alliance Points",
		width = "half",
		getFunc = function() return APC.SavedVariables.UseAPIcon end,
		setFunc = function(newValue) APC.SavedVariables.UseAPIcon = newValue end
	},
	{
		type = "colorpicker",
		name = "Logging Color",
		width = "half",
		getFunc = function()
			return
			APC.SavedVariables.LogColor.Red,
			APC.SavedVariables.LogColor.Green,
			APC.SavedVariables.LogColor.Blue
		end,
		setFunc = function(r, g, b)
			APC.SavedVariables.LogColor.Red = r
			APC.SavedVariables.LogColor.Green = g
			APC.SavedVariables.LogColor.Blue = b
		end
    },
	{
		type = "checkbox",
		name = "Restore alliance points",
		tooltip = "When checked, restores alliance points after relog/reload",
		width = "half",
		getFunc = function() return APC.SavedVariables.RestoreAP end,
		setFunc = function(newValue) APC.SavedVariables.RestoreAP = newValue end
	},
	{
		type = "slider",
		name = "Skip restoring after last gain in mins",
		tooltip = "Skip restoring AP when this amount of minutes elapsed from last AP gain, instead it will reset the data",
		width = "half",
		min = 1,
		max = 120,
		step = 1,
		getFunc = function() return APC.SavedVariables.SkipRestoreApAfterMins end,
		setFunc = function(newValue) APC.SavedVariables.SkipRestoreApAfterMins = newValue end,
		disabled = function() return (not APC.SavedVariables.RestoreAP) end
	},
	{
		type = "checkbox",
		name = "Show available commands on startup",
		tooltip = "When checked, shows startup message which commands are available",
		width = "half",
		getFunc = function() return APC.SavedVariables.ShowAvailableCommandsMessageOnStart end,
		setFunc = function(newValue) APC.SavedVariables.ShowAvailableCommandsMessageOnStart = newValue end
	},
	{
		type = "dropdown",
		name = "Thousand separator",
		tooltip = "Separator to split thousand values",
		width = "half",
		choices = {"'", ",", ".", "_", APC_SPACE},
		getFunc = function() return APC.SavedVariables.Separator end,
		setFunc = function(newValue) APC.SavedVariables.Separator = newValue end
	},
	{
		type = "submenu",
		name = "Start / Stop settings",
		controls =
		{
			{
				type = "description",
				text = "Counter starts default on Alliance Point gain",
				width = "full"
			},
			{
				type = "checkbox",
				name = "Start Counter when entering Cyrodiil",
				width = "full",
				getFunc = function() return APC.SavedVariables.StartCounterInCyrodiil end,
				setFunc = function(newValue) APC.SavedVariables.StartCounterInCyrodiil = newValue end
			},
			{
				type = "checkbox",
				name = "Start Counter when entering Imperial City",
				width = "full",
				getFunc = function() return APC.SavedVariables.StartCounterInImperialCity end,
				setFunc = function(newValue) APC.SavedVariables.StartCounterInImperialCity = newValue end
			},
		}
	},
	{
		type = "submenu",
		name = "Alliance point log settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Log Alliance Points to chat",
				tooltip = "When checked, logs Alliance Points to chat",
				width = "half",
				getFunc = function() return APC.SavedVariables.LogEnabled end,
				setFunc = function(newValue) APC.SavedVariables.LogEnabled = newValue end
			},
			{
				type = "slider",
				name = "Log after this amount of AP",
				tooltip = "Logs each time you get this amount of alliance point over time (If set to 1 will show log with AP type, else will show current AP and time)",
				width = "half",
				min = 1,
				max = 10000,
				step = 1,
				getFunc = function() return APC.SavedVariables.LogAPAmount end,
				setFunc = function(newValue) APC.SavedVariables.LogAPAmount = newValue end,
				disabled = function() return (not APC.SavedVariables.LogEnabled) end
			},
			{
				type = "dropdown",
				name = "AP log format",
				tooltip = "Format for logging AP",
				width = "half",
				choices =
				{
					AP_LOG_FORMAT_LONG,
					AP_LOG_FORMAT_NORMAL,
					AP_LOG_FORMAT_SHORT
				},
				getFunc = function() return APC.SavedVariables.ApLogFormat end,
				setFunc = function(newValue) APC.SavedVariables.ApLogFormat = newValue end,
				disabled = function() return (not APC.SavedVariables.LogEnabled) end
			},
			{
				type = "checkbox",
				name = "Log tick resource name",
				tooltip = "Log the resource name from which you got the tick",
				width = "half",
				getFunc = function() return APC.SavedVariables.LogTickResourceName end,
				setFunc = function(newValue) APC.SavedVariables.LogTickResourceName = newValue end
			},
			{
				type = "checkbox",
				name = "Log every tick (even if logging is disabled)",
				tooltip = "When checked, logs Alliance Points gain for ticks",
				width = "half",
				getFunc = function() return APC.SavedVariables.LogEveryTickEnabled end,
				setFunc = function(newValue) APC.SavedVariables.LogEveryTickEnabled = newValue end
			}
		}
	},
	{
		type = "submenu",
		name = "Screen message settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Unlock position",
				width = "half",
				getFunc = function() return screenMessageUnLock end,
				setFunc = function(newValue)
					screenMessageUnLock = newValue

					APC.SavedVariables.MainWindowLeft = APC_FORMS.MainWindow:GetLeft()
					APC.SavedVariables.MainWindowBottom = APC_FORMS.MainWindow:GetBottom()

					APC_FORMS.MainWindow:SetMovable(screenMessageUnLock)
					APC_FORMS.MainWindow:SetMouseEnabled(screenMessageUnLock)

					if screenMessageUnLock then
						APC_FORMS.MainWindowBackGround:SetAlpha(1)
						APC_FORMS.MainWindowText:SetAlpha(0.5)
					else
						APC_FORMS.MainWindowBackGround:SetAlpha(0)
						APC_FORMS.MainWindowText:SetAlpha(0)
					end
				end
			},
			{
			    type = "button",
			    name = "Reset position",
				width = "half",
				func = function()
					APC_FORMS.MainWindow:ClearAnchors()
					APC_FORMS.MainWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
					APC.SavedVariables.MainWindowLeft = APC_FORMS.MainWindow:GetLeft()
					APC.SavedVariables.MainWindowBottom = APC_FORMS.MainWindow:GetBottom()
				end
			},
			{
				type = "checkbox",
				name = "Show messages",
				tooltip = "When checked, shows message on screen",
				width = "half",
				getFunc = function() return APC.SavedVariables.UseScreenMessage end,
				setFunc = function(newValue) APC.SavedVariables.UseScreenMessage = newValue end
			},
			{
				type = "slider",
				name = "Show ticks with this amount of AP",
				tooltip = "Shows tick message when you get this amount from tick",
				width = "half",
				min = 1,
				max = 10000,
				step = 1,
				getFunc = function() return APC.SavedVariables.TickAPAmount end,
				setFunc = function(newValue) APC.SavedVariables.TickAPAmount = newValue end,
				disabled = function() return (not APC.SavedVariables.UseScreenMessage) end
			},
			{
				type = "checkbox",
				name = "Display tick resource name",
				tooltip = "Display the resource name from which you got the tick",
				width = "half",
				getFunc = function() return APC.SavedVariables.DisplayTickResourceName end,
				setFunc = function(newValue)
					APC.SavedVariables.DisplayTickResourceName = newValue
					
					if (APC.SavedVariables.DisplayTickResourceName) then APC_FORMS.MainWindow:SetDimensions(500 * APC.SavedVariables.ScreenMessageScaling, 80 * APC.SavedVariables.ScreenMessageScaling)
					else APC_FORMS.MainWindow:SetDimensions(350 * APC.SavedVariables.ScreenMessageScaling, 80 * APC.SavedVariables.ScreenMessageScaling) end
		
					APC_FORMS.MainWindowBackGround:SetDimensions(APC_FORMS.MainWindow:GetWidth(), APC_FORMS.MainWindow:GetHeight())
				end,
				disabled = function() return (not APC.SavedVariables.UseScreenMessage) end
			},
			{
				type = "slider",
				name = "Scale the display tick message",
				tooltip = "Change the scale of the screen tick message",
				width = "half",
				min = 25,
				max = 200,
				step = 5,
				getFunc = function() return APC.SavedVariables.ScreenMessageScaling * 100.0 end,
				setFunc = function(newValue)
					APC.SavedVariables.ScreenMessageScaling = newValue / 100.0

					if (APC.SavedVariables.DisplayTickResourceName) then APC_FORMS.MainWindow:SetDimensions(500 * APC.SavedVariables.ScreenMessageScaling, 80 * APC.SavedVariables.ScreenMessageScaling)
					else APC_FORMS.MainWindow:SetDimensions(350 * APC.SavedVariables.ScreenMessageScaling, 80 * APC.SavedVariables.ScreenMessageScaling) end
		
					APC_FORMS.MainWindowBackGround:SetDimensions(APC_FORMS.MainWindow:GetWidth(), APC_FORMS.MainWindow:GetHeight())
					APC_FORMS.MainWindowText:SetScale(0.5 * APC.SavedVariables.ScreenMessageScaling)
				end
			},
			{
				type = "slider",
				name = "Tick fade time",
				tooltip = "Fades the tick screen message after this amount of sec",
				width = "half",
				min = 1,
				max = 10,
				step = 1,
				getFunc = function() return APC.SavedVariables.TickFadeTime end,
				setFunc = function(newValue) APC.SavedVariables.TickFadeTime = newValue end,
				disabled = function() return (not APC.SavedVariables.UseScreenMessage) end
			},
			{
				type = "colorpicker",
				name = "Tick color",
				tooltip = "Color for the tick",
				width = "half",
				getFunc = function()
					return
					APC.SavedVariables.TickColor.Red,
					APC.SavedVariables.TickColor.Green,
					APC.SavedVariables.TickColor.Blue
				end,
				setFunc = function(r, g, b)
					APC.SavedVariables.TickColor.Red = r
					APC.SavedVariables.TickColor.Green = g
					APC.SavedVariables.TickColor.Blue = b
				end,
				disabled = function() return (not APC.SavedVariables.UseScreenMessage) end
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
				name = "Enable AP Inventory Balance",
				tooltip = "When checked, balances your AP in Inventory when opening Bank",
				width = "half",
				getFunc = function() return APC.SavedVariables.UseBalanceAP end,
				setFunc = function(newValue) APC.SavedVariables.UseBalanceAP = newValue end
			},
			{
				type = "checkbox",
				name = "Log AP changes",
				tooltip = "Logs the changes when opening Bank",
				width = "half",
				getFunc = function() return APC.SavedVariables.LogBalance end,
				setFunc = function(newValue) APC.SavedVariables.LogBalance = newValue end,
				disabled = function() return (not APC.SavedVariables.UseBalanceAP) end
			},
			{
				type = "slider",
				name = "AP Amount to hold",
				tooltip = "Amount of AP to hold when opening Bank",
				width = "full",
				min = 0,
				max = 1000000,
				step = 1,
				getFunc = function() return APC.SavedVariables.BalanceAP end,
				setFunc = function(newValue) APC.SavedVariables.BalanceAP = newValue end,
				disabled = function() return (not APC.SavedVariables.UseBalanceAP) end
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
					local apcTest = "APCTEST: "

					local reason = APC_REASON_ARRAY[math.random(1, table.getn(APC_REASON_ARRAY))]

					local resourceName = ""
					if APC.SavedVariables.LogTickResourceName and APC_IsTick(reason) then
						resourceName = APC_GetResourceName(math.random(1,90))
						if APC_IsStringEmpty(resourceName) then resourceName = APC_GetResourceName(1) end
						resourceName = "APCTEST: " .. resourceName
					end

					local oldAP = math.random(1, 100000)
					local diffAP = math.random(1, 100000)
					local newAP = oldAP + diffAP

					local minsText = " (" .. APC_NumberFormat(math.random(0, 100)) .. " mins) "
					
					local status = APC_GetBaseApSourceInfoForDisplay(reason)

					if (APC.SavedVariables.ApLogFormat == AP_LOG_FORMAT_LONG) then
						APC_SystemPrint(apcTest .. status .. " -> " .. APC_NumberFormat(oldAP) .. APC_GetApText() .. " + " .. APC_NumberFormat(diffAP) .. APC_GetApText() .. " = " .. APC_NumberFormat(newAP) .. APC_GetApText() .. minsText, resourceName)
					elseif (APC.SavedVariables.ApLogFormat == AP_LOG_FORMAT_NORMAL) then
						APC_SystemPrint(apcTest .. status .. " +" .. APC_NumberFormat(diffAP) .. APC_GetApText() .. " -> " .. APC_NumberFormat(newAP) .. APC_GetApText() .. minsText, resourceName)
					else
						APC_SystemPrint(apcTest .. status .. " -> " .. APC_NumberFormat(newAP) .. APC_GetApText() .. minsText, resourceName)
					end
				end
			},
			{
			    type = "button",
			    name = "Test screen message",
				width = "half",
				func = function()
					local apcTest = "APCTEST: "

					local resourceName = ""
					if APC.SavedVariables.DisplayTickResourceName then
						resourceName = APC_GetResourceName(math.random(1,90))
						if APC_IsStringEmpty(resourceName) then resourceName = APC_GetResourceName(1) end
						resourceName = apcTest .. resourceName
					end
					
					local reason = APC_REASON_TICK_ARRAY[math.random(1, table.getn(APC_REASON_TICK_ARRAY))]

					local difference = math.random(1, 100000)
					
					if (reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD) then APC_FORMS.Functions.DisplayTick(resourceName, apcTest .. "DTICK " .. APC_NumberFormat(difference) .. APC_GetApText(true))
					elseif(reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD) then APC_FORMS.Functions.DisplayTick(resourceName, apcTest .. "OTICK " .. APC_NumberFormat(difference) .. APC_GetApText(true)) end
				end,
				disabled = function() return (not APC.SavedVariables.UseScreenMessage) end
			}
		}
	}
}


APC_MENU.Init = function()
	APC_MENU.LAM2:RegisterAddonPanel("APC_SETTINGS", APC_MENU.PanelData)
	APC_MENU.LAM2:RegisterOptionControls("APC_SETTINGS", APC_MENU.OptionData)
end