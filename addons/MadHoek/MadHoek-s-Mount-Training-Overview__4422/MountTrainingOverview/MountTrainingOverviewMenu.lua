----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- 						Settings Menu: Mount Training Overview aka HorseTrainingTime (MHMTO) ESO AddOn by MadHoek 										----
---- 										Thanks to Cosh`s BiteTimers from which I learned a lot!															----
----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates.													----
---- The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 		----
---- All rights reserved																																	----
----																																						----
---- You can read the full terms at https://account.elderscrollsonline.com/add-on-terms																		----
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Sentry to make sure MHMTO is declared before use
if MHMTO == nil then MHMTO = {} end

--------------------------------------------------------------------------------

-- Register with LibMenu and ESO
local wasMenuCreated = false
--
function MHMTO.CreateMenu()

	if wasMenuCreated then return end

	-- ensure window exists before menu callbacks touch MHMTO.window.*
	if MHMTO.window == nil then
		MHMTO.CreateWindow()
	end
	
    -- The panel for the MTO menu
	local panel = {
		type = "panel",
		name = GetString(MHMTO_PANEL),
		displayName = GetString(MHMTO_PANEL_TITLE),
		author = "MadHoek",
        version = "" .. MHMTO.version,
		registerForDefaults = true,
		registerForRefresh = true,
	}

    -- MHMTO's entries in the addon menu
	local options = {
		[1] = {
			type = "header",
			name = GetString(MHMTO_WINSET),
		},
		[2] = {
			type = "slider",
			name = GetString(MHMTO_WINBG),
			tooltip = GetString(MHMTO_WINBG_TT),
			min = 0,
			max = 100,
			step = 5,
			getFunc = function() return MHMTO.settings.alpha end,
			setFunc = function(value) 
				MHMTO.settings.alpha = value
				MHMTO.window.bg:SetCenterColor(0, 0, 0, MHMTO.settings.alpha / 100)
				-- MHMTO.window.bg:SetEdgeColor(0, 0, 0, MHMTO.settings.alpha / 100)
			end,
			default = 50,
		},
		[3] = {
			type = "checkbox",
			name = GetString(MHMTO_SHOWTITLE),
			tooltip = GetString(MHMTO_SHOWTITLE_TT),
			getFunc = function() return MHMTO.settings.showtitle end,
			setFunc = function(value)
				MHMTO.settings.showtitle = value
				MHMTO.ApplyTitleLayout()
				MHMTO.RefreshWindow()
			end,
		},
		[4] = {
			type = "checkbox",
			name = GetString(MHMTO_SHOW_WINDOW),
			tooltip = GetString(MHMTO_SHOW_WINDOW_TT),
			-- reference = "MHMTOMenuControlShowWindow",
			getFunc = function()
				return MHMTO.settings.shown
			end,
			setFunc = function(value)
				if MHMTO.settings.shown ~= value then
					MHMTO.SetWindowShown(value)
				end
			end,
		},
		[5] = {
			type = "checkbox",
			name = GetString(MHMTO_WINDOW_LOCK),
			tooltip = GetString(MHMTO_WINDOW_LOCK_TT),
			-- reference = "MHMTOMenuControlLockWindow",
			getFunc = function() return MHMTO.settings.locked end,
			setFunc = function(value)
				MHMTO.settings.locked = value
				MHMTO.RefreshWindow()
			end,
			default = false,
		},
		[6] = {
			type = "slider",
			name = GetString(MHMTO_FONTSIZE),
			tooltip = GetString(MHMTO_FONTSIZE_TT),
			min = 5,
			max = 75,
			step = 1,
			getFunc = function() return MHMTO.settings.fontSize end,
			setFunc = function(value)
				MHMTO.settings.fontSize = value
				MHMTO.SetFontSize(value)
				MHMTO.RefreshWindow()
			end,
			default = 18,
		},
		[7] = {
			type = "dropdown",
			name = GetString(MHMTO_TIMEFORMAT),
			tooltip = GetString(MHMTO_TIMEFORMAT_TT),
			choices = {
				GetString(MHMTO_TIMEFORMAT_24H),
				GetString(MHMTO_TIMEFORMAT_12H),
			},
			getFunc = function()
				return MHMTO.settings.use24h
					and GetString(MHMTO_TIMEFORMAT_24H)
					or GetString(MHMTO_TIMEFORMAT_12H)
			end,
			setFunc = function(choice)
				MHMTO.settings.use24h = (choice == GetString(MHMTO_TIMEFORMAT_24H))
			end,
			width = "full",
			default = GetString(MHMTO_TIMEFORMAT_24H),
		},
		[8] = {
			type = "dropdown",
			name = GetString(MHMTO_DATEFORMAT),
			tooltip = GetString(MHMTO_DATEFORMAT_TT),
			choices = {
				GetString(MHMTO_DATEFORMAT_CLIENT),
				GetString(MHMTO_DATEFORMAT_DMY),
				GetString(MHMTO_DATEFORMAT_MDY),
				GetString(MHMTO_DATEFORMAT_ISO),
			},
			getFunc = function()
				local mode = MHMTO.settings.dateFormatMode or 0
				local choices = {
					GetString(MHMTO_DATEFORMAT_CLIENT),
					GetString(MHMTO_DATEFORMAT_DMY),
					GetString(MHMTO_DATEFORMAT_MDY),
					GetString(MHMTO_DATEFORMAT_ISO),
				}
				return choices[mode + 1]
			end,
			setFunc = function(choice)
				local map = {
					[GetString(MHMTO_DATEFORMAT_CLIENT)] = 0,
					[GetString(MHMTO_DATEFORMAT_DMY)]    = 1,
					[GetString(MHMTO_DATEFORMAT_MDY)]    = 2,
					[GetString(MHMTO_DATEFORMAT_ISO)]    = 3,
				}
				MHMTO.settings.dateFormatMode = map[choice] or 0

				if MHMTO.settingsPanel then
					CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MHMTO.settingsPanel)
				end
			end,
			default = GetString(MHMTO_DATEFORMAT_CLIENT),
			width = "full",
		},
		[9] = {
			type = "checkbox",
			name = GetString(MHMTO_CHAR_SHOW_ALLY),
			tooltip = GetString(MHMTO_CHAR_SHOW_ALLY_TT),
			-- reference = "MHMTOMenuControlShowAlliance",
			getFunc = function() return MHMTO.settings.showAlliance end,
			setFunc = function(value)
				MHMTO.settings.showAlliance = value
				MHMTO.RefreshWindow()
			end,
		},
		[10] = {
			type = "checkbox",
			name = GetString(MHMTO_HORSE_SHOW_STATS),
			tooltip = GetString(MHMTO_HORSE_SHOW_STATS_TT),
			-- reference = "MHMTOMenuControlShowStats",
			getFunc = function()
				return MHMTO.settings.showStats
			end,
			setFunc = function(value)
				MHMTO.settings.showStats = value
				MHMTO.RefreshWindow()
			end,
		},
		[11] = {
			type = "checkbox",
			name = GetString(MHMTO_HORSE_SHOW_TRAINABLE),
			tooltip = GetString(MHMTO_HORSE_SHOW_TRAINABLE_TT),
			-- reference = "MHMTOMenuControlShowTrainableHorse",
			getFunc = function()
				return MHMTO.settings.showTrainable
			end,
			setFunc = function(value)
				MHMTO.settings.showTrainable = value
				MHMTO.ShowOrHideCharacters()
				MHMTO.RefreshWindow()
			end,
		},
		[12] = {
			type = "checkbox",
			name = GetString(MHMTO_HORSE_SHOW_MAXED),
			tooltip = GetString(MHMTO_HORSE_SHOW_MAXED_TT),
			-- reference = "MHMTOMenuControlShowMaxed",
			getFunc = function()
				return MHMTO.settings.showMaxed
			end,
			setFunc = function(value)
				MHMTO.settings.showMaxed = value
				MHMTO.ShowOrHideCharacters()
				MHMTO.RefreshWindow()
			end,
		},
		[13] = {
			type = "checkbox",
			name = GetString(MHMTO_CHAR_SHOW_ID),
			tooltip = GetString(MHMTO_CHAR_SHOW_ID_TT),
			-- reference = "MHMTOMenuControlShowCharID",
			getFunc = function()
				return MHMTO.settings.showCharID
			end,
			setFunc = function(value)
				MHMTO.settings.showCharID = value
				MHMTO.RefreshWindow()
			end,
		},
		-- Color Settings Submenu
		[14] = {
			type = "submenu",
			name = GetString(MHMTO_MENU_COLOR),
			-- tooltip = GetString(MHMTO_MENU_COLOR_TT), --(optional)
			controls = {
				[1] = {
					type = "colorpicker",
					name = GetString(MHMTO_COLOR_TITLE),
					tooltip = GetString(MHMTO_COLOR_TITLE_TT),
					getFunc = function() return MHMTO.settings.colors.titleR, MHMTO.settings.colors.titleG, MHMTO.settings.colors.titleB, MHMTO.settings.colors.titleA end,
					setFunc = function(r,g,b,a)
						MHMTO.settings.colors.titleR, MHMTO.settings.colors.titleG, MHMTO.settings.colors.titleB, MHMTO.settings.colors.titleA = r,g,b,a
						MHMTO.RefreshWindow()
					end,
					width = "full"
					},
				[2] = {
					type = "colorpicker",
					name = GetString(MHMTO_COLOR_CANTRAIN),
					tooltip = GetString(MHMTO_COLOR_CANTRAIN_TT),
					getFunc = function() return MHMTO.settings.colors.canTrainR, MHMTO.settings.colors.canTrainG, MHMTO.settings.colors.canTrainB, MHMTO.settings.colors.canTrainA end,
					setFunc = function(r,g,b,a)
						MHMTO.settings.colors.canTrainR, MHMTO.settings.colors.canTrainG, MHMTO.settings.colors.canTrainB, MHMTO.settings.colors.canTrainA = r,g,b,a
						MHMTO.RefreshWindow()
					end,
					width = "full"
					},
				[3] = {
					type = "colorpicker",
					name = GetString(MHMTO_COLOR_MAXED),
					tooltip = GetString(MHMTO_COLOR_MAXED_TT),
					getFunc = function() return MHMTO.settings.colors.maxR, MHMTO.settings.colors.maxG, MHMTO.settings.colors.maxB, MHMTO.settings.colors.maxA end,
					setFunc = function(r,g,b,a)
						MHMTO.settings.colors.maxR, MHMTO.settings.colors.maxG, MHMTO.settings.colors.maxB, MHMTO.settings.colors.maxA = r,g,b,a
						MHMTO.RefreshWindow()
					end,
					width = "full"
					},
				[4] = {
					type = "colorpicker",
					name = GetString(MHMTO_COLOR_NOTMAXED),
					tooltip = GetString(MHMTO_COLOR_NOTMAXED_TT),
					getFunc = function() return MHMTO.settings.colors.notMaxR, MHMTO.settings.colors.notMaxG, MHMTO.settings.colors.notMaxB, MHMTO.settings.colors.notMaxA end,
					setFunc = function(r,g,b,a)
						MHMTO.settings.colors.notMaxR, MHMTO.settings.colors.notMaxG, MHMTO.settings.colors.notMaxB, MHMTO.settings.colors.notMaxA = r,g,b,a
						MHMTO.RefreshWindow()
					end,
					width = "full"
				},
				[5] = {
					type = "colorpicker",
					name = GetString(MHMTO_COLOR_NOTRAIN),
					tooltip = GetString(MHMTO_COLOR_NOTRAIN_TT),
					getFunc = function() return MHMTO.settings.colors.noTrainR, MHMTO.settings.colors.noTrainG, MHMTO.settings.colors.noTrainB, MHMTO.settings.colors.noTrainA end,
					setFunc = function(r,g,b,a)
						MHMTO.settings.colors.noTrainR, MHMTO.settings.colors.noTrainG, MHMTO.settings.colors.noTrainB, MHMTO.settings.colors.noTrainA = r,g,b,a
						MHMTO.RefreshWindow()
					end,
					width = "full"
				},
				[6] = {
					type = "colorpicker",
					name = GetString(MHMTO_COLOR_TIME),
					tooltip = GetString(MHMTO_COLOR_TIME_TT),
					getFunc = function() return MHMTO.settings.colors.timeR, MHMTO.settings.colors.timeG, MHMTO.settings.colors.timeB, MHMTO.settings.colors.timeA end,
					setFunc = function(r,g,b,a)
						MHMTO.settings.colors.timeR, MHMTO.settings.colors.timeG, MHMTO.settings.colors.timeB, MHMTO.settings.colors.timeA = r,g,b,a
						MHMTO.RefreshWindow()
					end,
					width = "full"
				},
				[7] = {
					type = "colorpicker",
					name = GetString(MHMTO_COLOR_TIME_ERROR),
					tooltip = GetString(MHMTO_COLOR_TIME_ERROR_TT),
					getFunc = function() return MHMTO.settings.colors.timeErrorR, MHMTO.settings.colors.timeErrorG, MHMTO.settings.colors.timeErrorB, MHMTO.settings.colors.timeErrorA end,
					setFunc = function(r,g,b,a)
						MHMTO.settings.colors.timeErrorR, MHMTO.settings.colors.timeErrorG, MHMTO.settings.colors.timeErrorB, MHMTO.settings.colors.timeErrorA = r,g,b,a
						MHMTO.RefreshWindow()
					end,
					width = "full"
				},
				[8] = {
					type = "button",
					name = GetString(MHMTO_COLOR_DEFAULT),
					tooltip = GetString(MHMTO_COLOR_DEFAULT_TT),
					func = function()
						MHMTO.SetDefaultColors()
						MHMTO.RefreshWindow()
						CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MHMTO.settingsPanel)
					end,
					width = "full"
				}
			}
		}
	}

	MHMTO.settingsPanel = LibAddonMenu2:RegisterAddonPanel("MountTrainingOverviewPanel", panel)
	LibAddonMenu2:RegisterOptionControls("MountTrainingOverviewPanel", options)
	
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MHMTO.settingsPanel)
	
	wasMenuCreated = true
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- EOF ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->