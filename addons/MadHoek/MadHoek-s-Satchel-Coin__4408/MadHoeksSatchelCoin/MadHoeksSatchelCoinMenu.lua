----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- 									Settings Menu: MadHoek's Satchel & Coin (MHSBC) ESO AddOn by MadHoek 												----
---- 												-------------------------------------																	----
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----    This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates.												----
----    The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 	----
----    All rights reserved																																	----
----																																						----
----    You can read the full terms at https://account.elderscrollsonline.com/add-on-terms																	----
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------


-- sentry to make sure MHSBC is declared before use
if MHSBC == nil then MHSBC = {} end

--
-- Register with LibMenu and ESO

local wasMenuCreated = false
--
function MHSBC.CreateMenu()

	if wasMenuCreated then return end

	local savedColor = MHSBC.data.savedvariables.Colors
	local saved = MHSBC.data.savedvariables
	
    -- the panel for the addons menu
	local panel = {
		type = "panel",
		name = GetString(MHSBC_PANEL),
		displayName = GetString(MHSBC_PANEL_TITLE),
		author = "MadHoek",
        version = "" .. MHSBC.version,
		registerForDefaults = true,
		registerForRefresh = true,
	}

    -- this addons entries in the addon menu
	local options = {
		[1] = {
			type = "header",
			name = GetString(MHSBC_PANEL_HEADER),
		},
		[2] = {
			type = "checkbox",
			name = GetString(MHSBC_WINDOW_SHOW),
			tooltip = GetString(MHSBC_WINDOW_SHOW_TT),
			reference = "MHSBCMenuControlShowWindow",
			getFunc = function() return saved.shown end,
			setFunc = function(value)
				saved.shown = value
				MHSBC.RefreshWindow()
			end,
			default = true,
		},
		[3] = {
			type = "checkbox",
			name = GetString(MHSBC_WINDOW_LOCK),
			tooltip = GetString(MHSBC_WINDOW_LOCK_TT),
			reference = "MHSBCMenuControlLockWindow",
			getFunc = function() return saved.locked end,
			setFunc = function(value)
				saved.locked = value
				MHSBC.RefreshWindow()
			end,
			default = false,
		},
		[4] = {
			type = "slider",
			name = GetString(MHSBC_WINDOW_BG),
			tooltip = GetString(MHSBC_WINDOW_BG_TT),
			min = 0,
			max = 100,
			step = 5,
			getFunc = function() return saved.alpha end,
			setFunc = function(value) 
				saved.alpha = value
				MHSBC.window.bg:SetCenterColor(0, 0, 0, saved.alpha / 100)
				MHSBC.window.bg:SetEdgeColor(0, 0, 0, saved.alpha / 100)
				MHSBC.RefreshWindow()
			end,
			default = 60,
		},
		[5] = {
			type = "slider",
			name = GetString(MHSBC_WINDOW_FONTSIZE),
			tooltip = GetString(MHSBC_FONTSIZE_TT),
			min = 5,
			max = 75,
			step = 1,
			getFunc = function() return saved.fontSize end,
			setFunc = function(value)
				saved.fontSize = value
				MHSBC.SetFontSize(value)
				MHSBC.RefreshWindow()
			end,
			default = 18,
		},
		[6] = {
			type = "slider",
			name = GetString(MHSBC_WINDOW_BAGWARNING),
			tooltip = GetString(MHSBC_WINDOW_BAGWARNING_TT),
			min = 0,
			max = 20,
			step = 1,
			getFunc = function() return saved.bagWarning end,
			setFunc = function(value) saved.bagWarning = value end,
			default = 5,
		},
		[7] = {
			type = "slider",
			name = GetString(MHSBC_WINDOW_BANKWARNING),
			tooltip = GetString(MHSBC_WINDOW_BANKWARNING_TT),
			min = 0,
			max = 20,
			step = 1,
			getFunc = function() return saved.bankWarning end,
			setFunc = function(value) saved.bankWarning = value end,
			default = 5,
		},
		-- Layout 1 Settings Submenu
		[8] = {
			type = "submenu",
			name = GetString(MHSBC_MENU_LAYOUT),
			tooltip = GetString(MHSBC_MENU_LAYOUT_TT),
			controls = {
			  [1] = {
				type = "checkbox",
				name = GetString(MHSBC_LAYOUT_SHOWBAGS),
				-- tooltip = GetString(MHSBC_LAYOUT_SHOWBAGS_TT), --(optional)
				getFunc = function() return saved.showBags end,
				setFunc = function(value)
					saved.showBags = value
					MHSBC.RefreshLayout()
				end,
				default = true,
			  },
			  [2] = {
				type = "checkbox",
				name = GetString(MHSBC_LAYOUT_SHOWBANK),
				-- tooltip = GetString(MHSBC_LAYOUT_SHOWBANK_TT), --(optional)
				getFunc = function() return saved.showBank end,
				setFunc = function(value)
					saved.showBank = value
					MHSBC.RefreshLayout()
				end,
				default = true,
			  },
			  [3] = {
				type = "checkbox",
				name = GetString(MHSBC_LAYOUT_SHOWGOLD),
				-- tooltip = GetString(MHSBC_LAYOUT_SHOWGOLD_TT), --(optional)
				getFunc = function() return saved.showGold end,
				setFunc = function(value)
					saved.showGold = value
					MHSBC.RefreshLayout()
				end,
				default = true,
			  },
			}
		},
		-- Layout 2 Settings Submenu
		[9] = {
			type = "submenu",
			name = GetString(MHSBC_MENU_LAYOUT_2),
			tooltip = GetString(MHSBC_MENU_LAYOUT_2_TT),
			controls = {
			[1] = {
				type = "checkbox",
				name = GetString(MHSBC_LAYOUT_SHOWCURRENCYROW),
				tooltip = GetString(MHSBC_LAYOUT_SHOWCURRENCYROW_TT),
				getFunc = function() return saved.showCurrency end,
				setFunc = function(value)
					saved.showCurrency = value
					MHSBC.RefreshLayout()
				end,
				default = false,
			},
			[2] = {
				type = "checkbox",
				name = GetString(MHSBC_LAYOUT_SHOWBANKGOLD),
				-- tooltip = GetString(MHSBC_LAYOUT_SHOWBANKGOLD_TT), --(optional)
				getFunc = function() return saved.showBankGold end,
				setFunc = function(value)
					saved.showBankGold = value
					MHSBC.RefreshLayout()
				end,
				default = true,
			},
			[3] = {
				type = "checkbox",
				name = GetString(MHSBC_LAYOUT_SHOWTELVAR),
				-- tooltip = GetString(MHSBC_LAYOUT_SHOWTELVAR_TT), --(optional)
				getFunc = function() return saved.showTelVar end,
				setFunc = function(value)
					saved.showTelVar = value
					MHSBC.RefreshLayout()
				end,
				default = true,
			},
			[4] = {
				type = "checkbox",
				name = GetString(MHSBC_LAYOUT_SHOWAP),
				-- tooltip = GetString(MHSBC_LAYOUT_SHOWAP_TT), --(optional)
				getFunc = function() return saved.showAlliancePoints end,
				setFunc = function(value)
					saved.showAlliancePoints = value
					MHSBC.RefreshLayout()
				end,
				default = true,
			},
			[5] = {
				type = "checkbox",
				name = GetString(MHSBC_LAYOUT_SHOWWRIT),
				-- tooltip = GetString(MHSBC_LAYOUT_SHOWWRIT_TT), --(optional)
				getFunc = function() return saved.showWritVouchers end,
				setFunc = function(value)
					saved.showWritVouchers = value
					MHSBC.RefreshLayout()
				end,
				default = true,
			},
			[6] = {
				type = "checkbox",
				name = GetString(MHSBC_LAYOUT_SHOWBARS),
				-- tooltip = GetString(MHSBC_LAYOUT_SHOWBARS_TT), --(optional)
				getFunc = function() return saved.showTradeBars end,
				setFunc = function(value)
					saved.showTradeBars = value
					MHSBC.RefreshLayout()
				end,
				default = true,
			},
			}
		},
		-- Color Settings Submenu
		[10] = {
			type = "submenu",
			name = GetString(MHSBC_MENU_COLOR),
			tooltip = GetString(MHSBC_MENU_COLOR_TT),
			controls = {
				[1] = {
					type = "colorpicker",
					name = GetString(MHSBC_COLOR_NORMAL),
					tooltip = GetString(MHSBC_COLOR_NORMAL_TT),
					getFunc = function() return savedColor.normal_R, savedColor.normal_G, savedColor.normal_B, savedColor.normal_A end,
					setFunc = function(r,g,b,a) savedColor.normal_R, savedColor.normal_G, savedColor.normal_B, savedColor.normal_A = r,g,b,a end,
					width = "full"
					},
				[2] = {
					type = "colorpicker",
					name = GetString(MHSBC_COLOR_WARNING),
					tooltip = GetString(MHSBC_COLOR_WARNING_TT),
					getFunc = function() return savedColor.warn_R, savedColor.warn_G, savedColor.warn_B, savedColor.warn_A end,
					setFunc = function(r,g,b,a) savedColor.warn_R, savedColor.warn_G, savedColor.warn_B, savedColor.warn_A = r,g,b,a end,
					width = "full"
					},
				[3] = {
					type = "colorpicker",
					name = GetString(MHSBC_COLOR_FULL),
					tooltip = GetString(MHSBC_COLOR_FULL_TT),
					getFunc = function() return savedColor.full_R, savedColor.full_G, savedColor.full_B, savedColor.full_A end,
					setFunc = function(r,g,b,a) savedColor.full_R, savedColor.full_G, savedColor.full_B, savedColor.full_A = r,g,b,a end,
					width = "full"
					},
				[4] = {
					type = "button",
					name = GetString(MHSBC_COLOR_DEFAULT),
					tooltip = GetString(MHSBC_COLOR_DEFAUL_TT),
					func = function() MHSBC.SetDefaultColors() end,
					width = "full"
				}
			}
		}
	}

	MHSBC.SettingsPanel = LibAddonMenu2:RegisterAddonPanel("MadHoeksSatchelCoinPanel", panel)
	LibAddonMenu2:RegisterOptionControls("MadHoeksSatchelCoinPanel", options)
	
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MHSBC.SettingsPanel)
	
	wasMenuCreated = true
end