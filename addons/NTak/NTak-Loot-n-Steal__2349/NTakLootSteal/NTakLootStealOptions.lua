local NTakLootSteal = NTLnS
local ADDON_NAME = "NTakLootSteal"
local texts = NTLnS_Texts
local icons = NTLnS_Icons


------------------------------------------
--		CONSTANTS

--	Variables from languages files
local hPos_Left		= texts.choices.hPosition[1]
local hPos_Center	= texts.choices.hPosition[2]
local hPos_Right	= texts.choices.hPosition[3]


------------------------------------------
--		SETTINGS


local LAM2 = LibAddonMenu2
function NTLnS.InitSettings()
	--	Usefull
	local function Titler(text)
		return ZO_HIGHLIGHT_TEXT:Colorize(zo_strformat("<<Z:1>>", text))
	end
	local function IsNeeded(text)
		return "“" .. text .. "”" .. texts.isNeeded
	end
	local SUBDIVIDER = {
		type = "divider",
		alpha = 0.33,
		width = "half",
	}
	local SPACER = {
		type = "description",
		title = nil,
		text = " ",
	}

	--	Panel
	local panelData = {
		type = "panel",
		name = "N'Tak' Loot'n'Steal",
		displayName = "N'|c887788Tak'|r Loot'n'Steal", 
		author = "N'|c887788Tak'|r",
		version = "1.8.14",
		slashCommand = "/ntlns",
		website = "https://www.esoui.com/portal.php?&uid=10379",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	--	Options
	local options =
	{
		{ -- ACCOUNT WIDE
			type = "checkbox",
			name = Titler(texts.cat00.title),
			getFunc = function()
				return NTakLootSteal_SavedVariables.Default[GetDisplayName()][GetCurrentCharacterId()]["Settings"]["accountWide"]
			end,
			setFunc = function(value)
				NTakLootSteal_SavedVariables.Default[GetDisplayName()][GetCurrentCharacterId()]["Settings"]["accountWide"] = value
				zo_callLater(function() ReloadUI() end, 200)
			end,
			requiresReload = true,
			width = "full",
		},
		SPACER,
		{ -- PREFERRED LOOT SETTINGS
			type = "header",
			name = Titler(texts.cat0.title),
			width = "full",
		},
			{ -- Description
				type = "description",
				title = nil,
				text = texts.cat0.desc0,
				width = "full",
			},
			{ -- Auto Loot
				type = "checkbox",
				name = texts.cat0.opt1,
				getFunc = function() return NTakLootSteal.settings.autoLoot end,
				setFunc = function(value)
					NTakLootSteal.settings.autoLoot = value
					NTakLootSteal.Init()
				end,
				width = "full",
				default = false,
			},
			{ -- Auto Steal
				type = "checkbox",
				name = texts.cat0.opt2,
				getFunc = function() return NTakLootSteal.settings.autoSteal end,
				setFunc = function(value)
					NTakLootSteal.settings.autoSteal = value
					NTakLootSteal.Init()
				end,
				width = "full",
				default = false,
			},
		SPACER,
		{ -- LOOTING TWEAKS
			type = "header",
			name = Titler(texts.cat1.title), -- icons["Loot"] .. 
			width = "full",
		},
			{ -- Hide interaction if empty
				type = "checkbox",
				name = texts.cat1.opt11,
				getFunc = function() return NTakLootSteal.settings.hideInteractEmpty end,
				setFunc = function(value)
					NTakLootSteal.settings.hideInteractEmpty = value
					NTakLootSteal.Init()
				end,
				width = "full",
				default = false,
			},
			{ -- Hide interaction on insects
				type = "checkbox",
				name = texts.cat1.opt12,
				getFunc = function() return NTakLootSteal.settings.hideInteractInsects end,
				setFunc = function(value)
					NTakLootSteal.settings.hideInteractInsects = value
					NTakLootSteal.Init()
				end,
				width = "full",
				default = false,
			},
			SUBDIVIDER,
			{ -- Prevent container loot if low space
				type = "checkbox",
				name = texts.cat1.opt1,
				getFunc = function() return NTakLootSteal.settings.openContainerIfBagLow end,
				setFunc = function(value)
					NTakLootSteal.settings.openContainerIfBagLow = value
					NTakLootSteal.Init()
				end,
				width = "full",
				warning = IsNeeded(texts.cat0.opt1),
				default = false,
				disabled = function() return not(NTakLootSteal.settings.autoLoot) end,
			},
			{ -- Low limit
				type = "slider",
				name = texts.cat1.opt1b,
				min = 0,
				step = 1,
				max = 50, -- 200 is max for backpack
				getFunc = function() return NTakLootSteal.settings.openContainerLowLimit end,
				setFunc = function(value)
					NTakLootSteal.settings.openContainerLowLimit = value
					NTakLootSteal.Init()
				end,
				width = "full",
				disabled = function() return
					not(NTakLootSteal.settings.autoLoot) or
					not(NTakLootSteal.settings.openContainerIfBagLow)
				end,
				default = 10,
			},
		SPACER,
		{ -- STEALING TWEAKS
			type = "header",
			name = Titler(" " .. texts.cat2.title), -- icons["Steal"] .. 
			width = "full",
		},
			{ -- Smart Stealing
				type = "checkbox",
				name = texts.cat2.opt1,
				getFunc = function() return NTakLootSteal.settings.smartStealing end,
				setFunc = function(value)
					if not(value) then SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, 1) end
					NTakLootSteal.settings.smartStealing = value
				end,
				width = "full",
				-- warning = texts.cat2.warn1,
				default = false,
			},
      		{ -- DOUBLE TAP DELAY
				type = "slider",
				name = texts.cat2.opt1b,
				min = 0,
				step = 50,
				max = 2000,
				getFunc = function() return NTakLootSteal.settings.smartDoubleTap end,
				setFunc = function(value) NTakLootSteal.settings.smartDoubleTap = value end,
				width = "full",
				disabled = function() return not(NTakLootSteal.settings.smartStealing) end,
				default = 0,
			},
			{ -- Description
				type = "description",
				title = nil,
				text = texts.cat2.desc1,
				width = "full",
				disabled = function() return not(NTakLootSteal.settings.smartStealing) end,
			},
			{ -- Advanced menu
				type = "submenu",
				name = texts.cat2.menu,
				disabled = function() return not(NTakLootSteal.settings.smartStealing) end,
				controls =
				{
					{ -- Use Advanced settings
						type = "checkbox",
						name = texts.cat2.opt10,
						getFunc = function() return NTakLootSteal.settings.smartAdvanced end,
						setFunc = function(value)
							NTakLootSteal.settings.smartAdvanced = value
							if not(value) then
								NTakLootSteal.settings.smartAdvContainers	= true
								NTakLootSteal.settings.smartAdvLocked		= true
								NTakLootSteal.settings.smartAdvWorldItems	= true
								NTakLootSteal.settings.smartAdvPickpocket	= true
							end
						end,
						width = "full",
						default = false,
					},
					{ -- Description
						type = "description",
						title = nil,
						text = texts.cat2.desc10,
						disabled = function() return not(NTakLootSteal.settings.smartAdvanced) end,
						width = "full",		
					},
					SUBDIVIDER,
					{ -- Containers
						type = "checkbox",
						name = texts.cat2.opt11,
						getFunc = function() return NTakLootSteal.settings.smartAdvContainers end,
						setFunc = function(value)
							if value then SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, 1) end
							NTakLootSteal.settings.smartAdvContainers = value
						end,
						width = "full",
						warning = IsNeeded(texts.cat0.opt2),
						default = true,
						disabled = function() return
							not(NTakLootSteal.settings.smartAdvanced) or
							not(NTakLootSteal.settings.autoSteal)
						end,
					},
					{ -- Lockpicking
						type = "checkbox",
						name = texts.cat2.opt11b,
						getFunc = function() return NTakLootSteal.settings.smartAdvLocked end,
						setFunc = function(value)
							NTakLootSteal.settings.smartAdvLocked = value
						end,
						width = "full",
						default = true,
						disabled = function() return not(NTakLootSteal.settings.smartAdvanced) end,
					},
					{ -- Items in world
						type = "checkbox",
						name = texts.cat2.opt12,
						getFunc = function() return NTakLootSteal.settings.smartAdvWorldItems end,
						setFunc = function(value) NTakLootSteal.settings.smartAdvWorldItems = value end,
						width = "full",
						default = true,
						disabled = function() return not(NTakLootSteal.settings.smartAdvanced) end,
					},
					{ -- Pickpocket
						type = "checkbox",
						name = texts.cat2.opt13,
						getFunc = function() return NTakLootSteal.settings.smartAdvPickpocket end,
						setFunc = function(value) NTakLootSteal.settings.smartAdvPickpocket = value end,
						width = "full",
						default = true,
						disabled = function() return not(NTakLootSteal.settings.smartAdvanced) end,
					},
				},
			},
			SUBDIVIDER,
			{ -- Lock icon when stealing prevented
				type = "checkbox",
				name = icons["Lock"] .. texts.cat2.opt2,
				getFunc = function() return NTakLootSteal.settings.lockIcon end,
				setFunc = function(value) NTakLootSteal.settings.lockIcon = value end,
				width = "full",
				disabled = function() return not(NTakLootSteal.settings.smartStealing) end,
				default = true,
			},
			{ -- Lock icon alternate position
				type = "checkbox",
				name = texts.cat2.opt2b .. icons["Lock"],
				getFunc = function() return NTakLootSteal.settings.lockAltPosition end,
				setFunc = function(value)
					NTakLootSteal.settings.lockAltPosition = value
					NTakLootSteal.Init()
				end,
				width = "full",
				disabled = function() return
					not(NTakLootSteal.settings.smartStealing) or
					not(NTakLootSteal.settings.lockIcon)
				end,
				default = false,
			},
			SUBDIVIDER,
			{ -- Show bounty timers
				type = "checkbox",
				name = texts.cat2.opt3,
				getFunc = function() return NTakLootSteal.settings.showBountyTimers end,
				setFunc = function(value)
					NTakLootSteal.settings.showBountyTimers = value					
					NTakLootSteal.Init()
				end,
				width = "full",
				default = true,
			},
			{ -- Opacity
				type = "slider",
				name = texts.alpha,
				min = 0,
				step = 1,
				max = 100,
				getFunc = function() return NTakLootSteal.settings.alphaBountyTimers * 100 end,
				setFunc = function(value)
					NTakLootSteal.settings.alphaBountyTimers = value / 100
					NTakLootSteal.Init()
				end,
				width = "full",
				disabled = function() return not(NTakLootSteal.settings.showBountyTimers) end,
				default = 100,
			},
			-- SUBDIVIDER,
			-- { -- Prevent sit when stealthy
				-- type = "checkbox",
				-- name = texts.cat2.opt4,
				-- getFunc = function() return NTakLootSteal.settings.hideInteractSit end,
				-- setFunc = function(value) NTakLootSteal.settings.hideInteractSit = value end,
				-- width = "full",
				-- default = true,
			-- },
		SPACER,
		{ -- ADDITIONAL INFOS
			type = "header",
			name = Titler(texts.cat3.title),
			width = "full",
		},
			{ -- IN INVENTORY
				type = "checkbox",
				name = Titler(texts.cat3.sub0),
				getFunc = function() return NTakLootSteal.settings.infoInventory end,
				setFunc = function(value)
					NTakLootSteal.settings.infoInventory = value
					NTakLootSteal.Init()
				end,
				width = "full",
				default = false,
			},
				{ -- Inventory Icon
					type = "checkbox",
					name = texts.cat3.opt01 .. icons["Bag"],
					getFunc = function() return NTakLootSteal.settings.infoInventoryIcon end,
					setFunc = function(value)
						NTakLootSteal.settings.infoInventoryIcon = value
						NTakLootSteal.Init()
					end,
					width = "full",
					disabled = function() return not(NTakLootSteal.settings.infoInventory) end,
					default = false,
				},
				{ -- Stolen filter
					type = "checkbox",
					name = "TO BE FIXED - " .. texts.cat3.opt02,
					-- warning = texts.cat3.opt02tt,
					getFunc = function() return NTakLootSteal.settings.stolenFilter end,
					setFunc = function(value)
						NTakLootSteal.settings.stolenFilter = value
					end,
					width = "full",
					requiresReload = true,
					disabled = true,
					-- disabled = function() return NTakLootSteal.libFilters==nil end,
					default = false,
				},
				{ -- Skip a line
					type = "checkbox",
					name = texts.cat3.opt03,
					getFunc = function() return NTakLootSteal.settings.infoInventoryBelow end,
					setFunc = function(value)
						NTakLootSteal.settings.infoInventoryBelow = value
						NTakLootSteal.Init()
					end,
					width = "full",
					--requiresReload = true,
					disabled = function() return not(NTakLootSteal.settings.infoInventory) end,
					default = false,
				},
			SUBDIVIDER,
			{ -- IN LOOT WINDOW
				type = "checkbox",
				name = Titler(texts.cat3.sub1),
				getFunc = function() return NTakLootSteal.settings.infoLoot end,
				setFunc = function(value)
					NTakLootSteal.settings.infoLoot = value
					NTakLootSteal.Init()
				end,
				width = "full",
				default = false,
			},
				{ -- Alignment
					type = "dropdown",
					name = texts.align,
					choices = texts.choices.hPosition,
					getFunc = function() return NTakLootSteal.settings.infoLootAlign end,
					setFunc = function(value)
						NTakLootSteal.settings.infoLootAlign = value
						NTakLootSteal.Init()
					end,
					width = "full",
					disabled = function() return not(NTakLootSteal.settings.infoLoot) end,
					default = hPos_Center,
				},
				{ -- Opacity
					type = "slider",
					name = texts.alpha,
					min = 0,
					step = 1,
					max = 100,
					getFunc = function() return NTakLootSteal.settings.infoLootAlpha * 100 end,
					setFunc = function(value)
						NTakLootSteal.settings.infoLootAlpha = value / 100
						NTakLootSteal.Init()
					end,
					width = "full",
					disabled = function() return not(NTakLootSteal.settings.infoLoot) end,
					default = 100,
				},
			SUBDIVIDER,
			{ -- CONTENT
				type = "description",
				title = Titler(texts.cat3.sub2),
				text = nil,
			},
				{ -- Bag info
					type = "checkbox",
					name = icons["Bag"] .. " " .. texts.cat3.opt21,
					getFunc = function() return NTakLootSteal.settings.infoBag end,
					setFunc = function(value)
						NTakLootSteal.settings.infoBag = value
						NTakLootSteal.Init()
					end,
					width = "half",
					default = false,
				},
				{ -- Low limit
					type = "slider",
					name = texts.cat3.optRed,
					min = 0,
					step = 1,
					max = 50, -- 200 is max for backpack
					getFunc = function() return NTakLootSteal.settings.infoBagLowLimit end,
					setFunc = function(value)
						NTakLootSteal.settings.infoBagLowLimit = value
						NTakLootSteal.Init()
					end,
					width = "half",
					disabled = function() return not(NTakLootSteal.settings.infoBag) end,
					default = 10,
				},
				-- { -- Stolen info
					-- type = "checkbox",
					-- name = icons["Steal"] .. " " .. texts.cat3.opt21b,
					-- getFunc = function() return NTakLootSteal.settings.infoBagStolen end,
					-- setFunc = function(value)
						-- NTakLootSteal.settings.infoBagStolen = value
						-- NTakLootSteal.Init()
					-- end,
					-- width = "full",
					-- default = false,
				-- },
				{ -- Fenced info
					type = "checkbox",
					name = icons["Fence"] .. " " .. texts.cat3.opt22,
					getFunc = function() return NTakLootSteal.settings.infoSold end,
					setFunc = function(value)
						if value == false then
							NTakLootSteal.settings.infoGroupFenced = false
							if not(NTakLootSteal.settings.infoLaunder) then
								NTakLootSteal.settings.infoTimer = false
							end
						end
						NTakLootSteal.settings.infoSold = value
						NTakLootSteal.Init()
					end,
					width = "half",
					default = false,
				},
				{ -- Low limit
					type = "slider",
					name = texts.cat3.optRed,
					min = 0,
					step = 1,
					max = 50, -- 140 is max sellings for stolen
					getFunc = function() return NTakLootSteal.settings.infoSoldLowLimit end,
					setFunc = function(value)
						NTakLootSteal.settings.infoSoldLowLimit = value
						NTakLootSteal.Init()
					end,
					width = "half",
					disabled = function() return not(NTakLootSteal.settings.infoSold) end,
					default = 10,
				},
				{ -- Laundered info
					type = "checkbox",
					name = icons["Launder"] .. " " .. texts.cat3.opt23,
					getFunc = function() return NTakLootSteal.settings.infoLaunder end,
					setFunc = function(value)
						if value == false then
							NTakLootSteal.settings.infoGroupFenced = false
							if not(NTakLootSteal.settings.infoSold) then
								NTakLootSteal.settings.infoTimer = false
							end
						end
						NTakLootSteal.settings.infoLaunder = value
						NTakLootSteal.Init()
					end,
					width = "half",
					default = false,
				},
				{ -- Low limit
					type = "slider",
					name = texts.cat3.optRed,
					min = 0,
					step = 1,
					max = 50, -- 140 is max for laundering
					getFunc = function() return NTakLootSteal.settings.infoLaunderLowLimit end,
					setFunc = function(value)
						NTakLootSteal.settings.infoLaunderLowLimit = value
						NTakLootSteal.Init()
					end,
					width = "half",
					disabled = function() return not(NTakLootSteal.settings.infoLaunder) end,
					default = 10,
				},
				{ -- Group Fenced/Laundered
					type = "checkbox",
					name = icons["Fence"] .. " " .. texts.cat3.opt223,
					getFunc = function() return NTakLootSteal.settings.infoGroupFenced end,
					setFunc = function(value)
						NTakLootSteal.settings.infoGroupFenced = value
						NTakLootSteal.Init()
					end,
					width = "full",
					disabled = function() return
						not(NTakLootSteal.settings.infoSold) or
						not(NTakLootSteal.settings.infoLaunder)
					end,
					default = false,
				},
				{ -- Fenced/Laundered timer
					type = "checkbox",
					name = icons["Refresh"] .. " " .. texts.cat3.opt24,
					getFunc = function() return NTakLootSteal.settings.infoTimer end,
					setFunc = function(value)
						NTakLootSteal.settings.infoTimer = value
						NTakLootSteal.Init()
					end,
					width = "full",
					disabled = function() return
						not(NTakLootSteal.settings.infoSold) and
						not(NTakLootSteal.settings.infoLaunder)
					end,
					default = false,
				},
		SPACER,
	}
	
	--	Create options panel
	LAM2:RegisterAddonPanel(ADDON_NAME, panelData)
	LAM2:RegisterOptionControls(ADDON_NAME, options)
end