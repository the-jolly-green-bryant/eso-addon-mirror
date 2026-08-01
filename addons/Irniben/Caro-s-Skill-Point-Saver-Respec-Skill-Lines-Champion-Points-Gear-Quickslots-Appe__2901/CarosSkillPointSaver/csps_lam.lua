local GS = GetString
local LAM = LibAddonMenu2
local cspsPost = CSPS.post
local cspsD = CSPS.cspsD
	
function CSPS.setupLam()
	local options = CSPS.savedVariables.settings
	options.applyAllExclude = options.applyAllExclude or {}
	
	local panelData = {
		type = "panel",
		name = "Caro's Skill Point Saver",
		displayName =  "|c9e0911Caro|r's Skill Point Saver",
		author = "|c1d6dadIrniben|r",
		registerForRefresh = true,
    }
	
	options.importQsSlots = options.importQsSlots or {{8,7,6,5},{1,2,3,4}}
	local quickSlotPositionNames = {"-"}
	
	for i=1,8 do table.insert(quickSlotPositionNames, string.format("%s) %s", i, GS("CSPS_QuickSlotPosition", i))) end
	
	local optionsForHubImport = {}
	local buffFoodPotionImport = {zo_strformat("<<C:1>>/<<C:2>>", GS(SI_ITEMTYPE4), GS(SI_ITEMTYPE12)), zo_strformat("<<C:1>>", GS(SI_ITEMTYPE7))} --food/drink, potion
	for j=1,2 do
		for i=1,4 do
			table.insert(optionsForHubImport, {
				type = "dropdown",
				name = string.format("%s %s", buffFoodPotionImport[j], i),
				width = "full",
				choices = quickSlotPositionNames,
				choicesValues = {0,1,2,3,4,5,6,7,8},
				sort = "value-up",
				default = 0,
				--disabled = function() return(not options.cpCustomBar) end,
				getFunc = function() return options.importQsSlots[j][i] or 0 end,
				setFunc = function(value) 
					for jj=1,2 do
						for ii=1,4 do
							if options.importQsSlots[jj][ii] == value and not (ii==i and jj==j) then
								options.importQsSlots[jj][ii] = 0
							end
						end
					end
					options.importQsSlots[j][i] = value
				end,
				--disabled = function() return CSPS.moduleExclude.cp end,
			})
		end
	end
		
	local optionsForApplyAll = {
		{
			type = "checkbox",
			name = GS(CSPS_ShowBtnApplyAll),
			width = "full",
			getFunc = function() return options.showApplyAll end,
			setFunc = function(value) 
					options.showApplyAll = value
					CSPSWindowBtnApplyAll:SetHidden(not value)
				end,
		},
		
		{
			type = "divider",
			width = "full",
		},
	}
	
	local applyAllCats = CSPS.getApplyAllCats()
	
	for i, v in pairs(applyAllCats) do
		table.insert(optionsForApplyAll, {
			type = "checkbox",
			name = type(v[1]) == "string" and v[1] or GS(v[1]),
			width = "full",
			getFunc = function() return not options.applyAllExclude[v[2]] end,
			setFunc = function(value) 
					options.applyAllExclude[v[2]] = not value
				end,
			disabled = function() return CSPS.moduleExclude[v[2]] or not options.showApplyAll end,
		})
	end
				
	local optionsData = {
		{
			type = "header",
			name = GS(SI_VIDEO_OPTIONS_INTERFACE),
			width = "full",
		},	
		
		{
			type = "checkbox",
			name = GS(CSPS_ShowHb),
			width = "full",
			tooltip = GS(CSPS_ShowHb),
			getFunc = function() return not options.hideHotbar end,
			setFunc = function(value) options.hideHotbar = not value CSPS.showElement("hotbar", value) end,
			disabled = function() return CSPS.moduleExclude.skills end,
		},
		{
			type = "checkbox",
			name = GS(CSPS_ShowDateInProfileName),
			width = "full",
			getFunc = function() return not options.suppressLastModified end,
			setFunc = function(value) 
					options.suppressLastModified = not value
					CSPS.UpdateProfileCombo()
				end,
		},
		{
			type = "dropdown",
			name = GS(CSPS_LAM_JumpShiftKey),
			tooltip = GS(CSPS_LAM_JumpShiftKey),
			width = "full",
			choices = {GS(SI_KEYCODE7), GS(SI_KEYCODE4), GS(SI_KEYCODE5)},
			choicesValues = {7,4,5}, -- shift / ctrl / alt
			default = 7,
			getFunc = function() return options.jumpShiftKey or 7 end,
			setFunc = function(value) options.jumpShiftKey = value end,
		},		
		{
			type = "checkbox",
			name = GS(CSPS_IgnoreEmptyOutfitSlots),
			tooltip = GS(CSPS_IgnoreEmptyOutfitSlotsTT),
			width = "full",
			disabled = function() return CSPS.moduleExclude.outfit end,
			getFunc = function() return not options.ignoreEmptyOutfitslots end,
			setFunc = function(value) 
					options.ignoreEmptyOutfitslots = not value
				end,
		},
		
		{
			type = "checkbox",
			name = GS(CSPS_KeepLastBuild),
			tooltip = GS(CSPS_KeepLastBuildTT),
			width = "full",
			getFunc = function() return options.keepLastBuild end,
			setFunc = function(value) 
					options.keepLastBuild = value
					if not value then
						ZO_Dialogs_ShowDialog(CSPS.name.."_YesNoDiag", 
							{yesFunc = function() 
								for _, charData in pairs(CSPS.savedVariables.charData) do
									charData.auxProfile = nil
								end
							end,
							noFunc = function() end,
							}, 
							{mainTextParams = {GS(CSPS_DeleteLastBuilds)}}
							) 
					
					end
				end,
		},
		{
			type = "slider",
			name = GS(CSPS_LAM_VersionHistory),
			width = "full",
			tooltip = GS(CSPS_LAM_VersionHistoryTT),
			min = 0,
			max = 8,
			decimals = 0, 
			getFunc = function() return options.versionHistory or 0 end,
			setFunc = function(value) 
					options.versionHistory = value ~= 0 and value or false
				end,
		},		
		
		{
			type = "dropdown",
			name = GS(CSPS_LAM_SortProfiles),
			tooltip = GS(CSPS_LAM_SortProfiles),
			width = "full",
			choices = {GS(SI_GAMEPAD_BANK_SORT_ORDER_UP_TEXT), GS(SI_GAMEPAD_BANK_SORT_ORDER_DOWN_TEXT), GS(CSPS_LAM_NewestFirst), GS(CSPS_LAM_OldestFirst)}, --alphabetical, alphabetical reverse, newest, oldest
			choicesValues = {1,2,3,4},
			default = 7,
			getFunc = function() return options.profileOrder or 1 end,
			setFunc = function(value) options.profileOrder = value CSPS.UpdateProfileCombo() end,
		},		
		{
			type = "checkbox",
			name = GS(CSPS_StandardProfileFirst),
			tooltip = GS(CSPS_StandardProfileFirstTT),
			width = "full",
			getFunc = function() return options.standardOnTop end,
			setFunc = function(value) options.standardOnTop = value CSPS.UpdateProfileCombo() end,
		},
		{
			type = "checkbox",
			name = GS(CSPS_LAM_ShowAllClassSkills),
			tooltip = GS(CSPS_LAM_ShowAllClassSkillsTT),
			width = "full",
			getFunc = function() return options.showAllClassSkills end,
			setFunc = function(value) 
					options.showAllClassSkills = value
					if not CSPS.treeIsReady then return end
					CSPS.reCreateClassSkillTree()
					if not value then
						local classesInBuild = {}
						for i,v in pairs(CSPS.getSubClasses()) do
							classesInBuild[v] = true
						end
						for i=1, 3*GetNumClasses() do
							if not classesInBuild[i] then CSPS.removeSkillLine(1, i) end
						end
					end
					CSPS.refreshTree()
				end,
			disabled = function() return CSPS.moduleExclude.skills end,
		},
		{
			type = "slider",
			name = GS(CSPS_LAM_BGAlpha),
			width = "full",
			tooltip = GS(CSPS_LAM_BGAlpha),
			min = 40,
			max = 100,
			decimals = 0, 
			getFunc = function() return options.bgalpha * 100 or 100 end,
			setFunc = function(value) CSPS.setTransparencyBG(value/100)	end,
		},
		{
			type = "slider",
			name = GS(CSPS_LAM_WinAlpha),
			width = "full",
			tooltip = GS(CSPS_LAM_WinAlpha),
			min = 40,
			max = 100,
			decimals = 0, 
			getFunc = function() return options.winalpha * 100 or 100 end,
			setFunc = function(value) CSPS.setTransparencyWin(value/100)	end,
		},		
		{
			type = "checkbox",
			name = GS(CSPS_LAM_DeveloperOptions),
			width = "full",
			tooltip = GS(CSPS_LAM_DeveloperOptionsTT),
			getFunc = function() return options.devOpt end,
			setFunc = function(value) options.devOpt = value end,
		},
		
		{
			type = "submenu",
			name = GS(CSPS_AutoOpen),
			icon = "esoui/art/guild/tabicon_history_up.dds",
			controls = {
				{
					type = "checkbox",
					name = GS(CSPS_CPAutoOpen),
					width = "full",
					tooltip = GS(CSPS_Tooltip_CPAutoOpen),
					getFunc = function() return options.autoShowScenes["championPerks"]  end,
					setFunc = function(value) 
							options.autoShowScenes["championPerks"]  = value
							CSPS.registerFragment()
						end,
				},
				{
					type = "checkbox",
					name = GS(CSPS_ArmoryAutoOpen),
					width = "full",
					tooltip = GS(CSPS_Tooltip_ArmoryAutoOpen),
					getFunc = function() return options.autoShowScenes["armoryKeyboard"]  end,
					setFunc = function(value) 
							options.autoShowScenes["armoryKeyboard"] = value
							CSPS.registerFragment()
						end,
				},
				{
					type = "checkbox",
					name = GS(CSPS_SkillWindowAutoOpen),
					width = "full",
					tooltip = GS(CSPS_SkillWindowAutoOpen),
					getFunc = function() return options.autoShowScenes["skills"]  end,
					setFunc = function(value) 
							options.autoShowScenes["skills"]  = value
							CSPS.registerFragment()
						end,
				},
				{
					type = "checkbox",
					name = GS(CSPS_StatsWindowAutoOpen),
					width = "full",
					tooltip = GS(CSPS_StatsWindowAutoOpen),
					getFunc = function() return options.autoShowScenes["stats"]  end,
					setFunc = function(value) 
							options.autoShowScenes["stats"]  = value
							CSPS.registerFragment()
						end,
				},    
				{
					type = "checkbox",
					name = GS(SI_LEVEL_UP_NOTIFICATION),
					width = "full",
					tooltip = GS(SI_LEVEL_UP_NOTIFICATION),
					getFunc = function() return options.openOnLevelUp  end,
					setFunc = function(value) 
							options.openOnLevelUp = value
							CSPS.registerFragment()
						end,
				},
				{
					type = "checkbox",
					name = zo_strformat(GS(SI_CHAMPION_POINT_EARNED), 1),
					width = "full",
					tooltip = zo_strformat(GS(SI_CHAMPION_POINT_EARNED), 1),
					getFunc = function() return options.openOnCPGain  end,
					setFunc = function(value) 
							options.openOnCPGain  = value
							CSPS.registerFragment()
						end,
				},
			}
		},
		{
			type = "submenu",
			name = GS(SI_STAT_GAMEPAD_CHAMPION_POINTS_LABEL),
			icon = "esoui/art/champion/champion_icon.dds",
			controls = {
				{
					type = "dropdown",
					name = GS(CSPS_LAM_SortCP),
					width = "full",
					choices = {GS(CSPS_LAM_SortCP_1), GS(CSPS_LAM_SortCP_2), GS(CSPS_LAM_SortCP_3)},
					choicesValues = {1,2,3},
					sort = "value-up",
					default = 1,
					getFunc = function() return options.sortCPs or 1 end,
					setFunc = function(value) 
						options.sortCPs = value 
						CSPS.cp.reSortList()
					end,
					disabled = function() return CSPS.moduleExclude.cp end,
				},
				{
					type = "checkbox",
					name = GS(CSPS_CPCustomIcons),
					width = "full",
					tooltip = GS(CSPS_Tooltip_CPCustomIcons),
					getFunc = function() return options.useCustomIcons end,
					setFunc = function(value) 
							options.useCustomIcons = value
							CSPS.toggleCPCustomIcons()
						end,
					disabled = function() return CSPS.moduleExclude.cp end,
				},
				{
					type = "checkbox",
					name = GS(CSPS_CPCustomBar),
					width = "full",
					tooltip = GS(CSPS_Tooltip_CPCustomBar),
					getFunc = function() return options.cpCustomBar end,
					setFunc = function(value) 
							if not options.cpCustomBar or not value then
								options.cpCustomBar = value and 1 or false
								CSPS.toggleCPCustomBar()
							end
						end,
					disabled = function() return CSPS.moduleExclude.cp end,
				},
				{
					type = "dropdown",
					name = GS(CSPS_CPCustomBarLayout),
					width = "full",
					choices = {"1x4", "3x4", "1x12"},
					choicesValues = {3,2,1},
					sort = "value-up",
					default = 3,
					disabled = function() return(not options.cpCustomBar) end,
					getFunc = function() return options.cpCustomBar or 1 end,
					setFunc = function(value) 
						options.cpCustomBar = value 
						CSPS.toggleCPCustomBar() 
					end,
					disabled = function() return CSPS.moduleExclude.cp end,
				},
				{
					type = "checkbox",
					name = GS(CSPS_LAM_ShowOutdatedPresets),
					width = "full",
					tooltip = GS(CSPS_LAM_ShowOutdatedPresets),
					getFunc = function() return options.showOutdatedPresets end,
					setFunc = function(value) options.showOutdatedPresets = value end,
					disabled = function() return CSPS.moduleExclude.cp end,
				},
			}
		},
		{
			type = "submenu",
			name = GS(SI_GAMEPAD_DYEING_EQUIPMENT_HEADER),
			icon = "esoui/art/armory/builditem_icon.dds",
			controls = {
				{
					type = "slider",
					name = GS(CSPS_AcceptedLevelDifference),
					width = "full",
					tooltip = GS(CSPS_AcceptedLevelDifferenceTooltip),
					min = 0,
					max = 50,
					decimals = 0, 
					getFunc = function() return options.maxLevelDiff or 10 end,
					setFunc = function(value) 
							options.maxLevelDiff = value
							CSPS.refreshTree()
						end,
					disabled = function() return CSPS.moduleExclude.gear end,
				},
				
				{
					type = "checkbox",
					name = GS(CSPS_ShowGearMarkers),
					width = "full",
					tooltip = GS(CSPS_ShowGearMarkersTooltip),
					getFunc = function() return options.showGearMarkers end,
					setFunc = function(value) 
							CSPS.setGearMarkerOption(value)
						end,
					disabled = function() return CSPS.moduleExclude.gear end,
				},
				{
					type = "checkbox",
					name = GS(CSPS_ShowGearMarkerDataBased),
					width = "full",
					tooltip = GS(CSPS_ShowGearMarkerDataBasedTooltip),
					getFunc = function() return options.showGearMarkerDataBased end,
					setFunc = function(value) 
							CSPS.setGearMarkerOptionData(value)
						end,
					disabled = function() return CSPS.moduleExclude.gear or not options.showGearMarkers end,
				},	
				{
					type = "checkbox",
					name = GS(CSPS_LAM_ShowNumSetItems),
					width = "full",
					tooltip = GS(CSPS_LAM_ShowNumSetItems),
					getFunc = function() return not options.hideNumSetItems end,
					setFunc = function(value) 
							options.hideNumSetItems = not value 
							CSPS.refreshTree()
						end,
					disabled = function() return CSPS.moduleExclude.gear or not options.showGearMarkers end,
				},	
				{
					type = "checkbox",
					name = GS(CSPS_LAM_UpgradeAnyway),
					width = "full",
					tooltip = GS(CSPS_LAM_UpgradeAnywayTT),
					getFunc = function() return options.upgradeAnyway end,
					setFunc = function(value) options.upgradeAnyway = value end,
					disabled = function() return CSPS.moduleExclude.gear or not CSPS.LLC end,
				},					
			}				
		},
		{
			type = "submenu",
			name = GS(SI_GAME_MENU_KEYBINDINGS),
			icon = "esoui/art/tutorial/tutorial_idexicon_uibasics_up.dds",
			controls = {
				{
					type = "description",
					text = GS(CSPS_LAM_KB_Descr),
				},
				{
					type = "dropdown",
					name = GS(CSPS_LAM_KB_ShiftMode),
					tooltip = GS(CSPS_LAM_KB_ShiftMode),
					width = "full",
					choices = {GS(SI_ALLIANCE0), GS(SI_KEYCODE7), GS(SI_KEYCODE4), GS(SI_KEYCODE5)},
					choicesValues = {0,7,4,5}, -- shift / ctrl / alt
					default = 7,
					getFunc = function() return options.accountWideShiftKey or 7 end,
					setFunc = function(value) options.accountWideShiftKey = value CSPS.barManagerRefreshGroup() end,
				},		
			}
		},
		{
			type = "submenu",
			name = GS(SI_SOCIAL_OPTIONS_NOTIFICATIONS),
			icon = "esoui/art/mainmenu/menubar_notifications_up.dds",
			controls = {
				{
					type = "checkbox",
					name = GS(CSPS_LAM_ShowCpPresetNotifications),
					tooltip = GS(CSPS_LAM_ShowCpPresetNotifications),
					width = "full",
					getFunc = function() return not options.suppressCpPresetNotifications end,
					setFunc = function(value) options.suppressCpPresetNotifications = not value	end,
				},
				{
					type = "checkbox",
					name = GS(CSPS_LAM_ShowCpNotSaved),
					tooltip = GS(CSPS_LAM_ShowCpNotSaved),
					width = "full",
					getFunc = function() return not options.suppressCpNotSaved end,
					setFunc = function(value) options.suppressCpNotSaved = not value	end,
					disabled = function() return CSPS.moduleExclude.cp end,
				},
				{
					type = "checkbox",
					name = GS(CSPS_LAM_ShowSaveOther),
					tooltip = GS(CSPS_LAM_ShowSaveOther),
					width = "full",
					getFunc = function() return not options.suppressSaveOther end,
					setFunc = function(value) options.suppressSaveOther = not value	end,
				},
			}
		},
		{
			type = "submenu",
			name = GS(CSPS_BtnApplyAll),
			icon = "esoui/art/campaign/campaign_tabicon_summary_up.dds",
			controls = optionsForApplyAll,	
		},
		{
			type = "submenu",
			name = GS(CSPS_LAM_Modules),
			icon = "esoui/art/campaign/campaign_tabicon_summary_up.dds",
			controls = {
				--[[
				{
					type = "checkbox",
					name = string.format("%s: %s", GS(CSPS_LAM_Module), GS(SI_CHARACTER_MENU_SKILLS)),
					width = "full",
					getFunc = function() return not options.moduleExclude.skills end,
					setFunc = function(value) 
							options.applyAllExclude.skills = not value
						end,
					requiresReload = true,
				}, 
				{
					type = "checkbox",
					name = string.format("%s: %s", GS(CSPS_LAM_Module), GS(SI_COLLECTIBLECATEGORYTYPE30)),
					width = "full",
					getFunc = function() return not options.moduleExclude.skillStyles end,
					setFunc = function(value) 
							options.moduleExclude.skillStyles = not value
						end,
					requiresReload = true,
				},
				
				{
					type = "checkbox",
					name = string.format("%s: %s", GS(CSPS_LAM_Module), GS(SI_CHARACTER_MENU_STATS)),
					width = "full",
					getFunc = function() return not options.moduleExclude.attr end,
					setFunc = function(value) 
							options.moduleExclude.attr = not value
						end,
					requiresReload = true,
				},
				{
					type = "checkbox",
					name = string.format("%s: %s", GS(CSPS_LAM_Module), GS(SI_STAT_GAMEPAD_CHAMPION_POINTS_LABEL)),
					width = "full",
					getFunc = function() return not options.moduleExclude.cp end,
					setFunc = function(value) 
							options.moduleExclude.cp = not value
						end,
					requiresReload = true,
				},
				{
					type = "checkbox",
					name = string.format("%s: %s", GS(CSPS_LAM_Module), GS(SI_INTERFACE_OPTIONS_ACTION_BAR)),
					width = "full",
					getFunc = function() return not options.moduleExclude.hb end,
					setFunc = function(value) 
							options.moduleExclude.hb = not value
						end,
					requiresReload = true,
				},
				]]--
				{
					type = "checkbox",
					name = string.format("%s: %s", GS(CSPS_LAM_Module), GS(SI_GAMEPAD_DYEING_EQUIPMENT_HEADER)),
					width = "full",
					getFunc = function() return CSPS.canDoGear and not options.moduleExclude.gear end,
					setFunc = function(value) 
							options.moduleExclude.gear = not value
						end,
					disabled = function() return not CSPS.canDoGear end,
					requiresReload = true,
				},
				{
					type = "checkbox",
					name = string.format("%s: %s", GS(CSPS_LAM_Module), GS(SI_HOTBARCATEGORY10)),
					width = "full",
					getFunc = function() return not options.moduleExclude.qs end,
					setFunc = function(value) 
							options.moduleExclude.qs = not value
						end,
					requiresReload = true,
				},
				{
					type = "checkbox",
					name = string.format("%s: %s", GS(CSPS_LAM_Module), GetCollectibleCategoryNameByCategoryId(13)),
					width = "full",
					getFunc = function() return not options.moduleExclude.outfit end,
					setFunc = function(value) 
							options.moduleExclude.outfit = not value
						end,
					requiresReload = true,
				},
				{
					type = "checkbox",
					name = string.format("%s: %s", GS(CSPS_LAM_Module), GS(SI_GROUP_LIST_PANEL_PREFERRED_ROLES_LABEL)),
					width = "full",
					getFunc = function() return not options.moduleExclude.role end,
					setFunc = function(value) 
							options.moduleExclude.role = not value
						end,
					requiresReload = true,
				},
				{
					type = "checkbox",
					name = string.format("%s: %s", GS(CSPS_LAM_Module), GS(SI_STATS_MUNDUS_TITLE)),
					width = "full",
					getFunc = function() return not options.moduleExclude.mundus end,
					setFunc = function(value) 
							options.moduleExclude.mundus = not value
						end,
					requiresReload = true,
				},
				
			}
		},
		
		
		{
			type = "submenu",
			name = "Wizard's Wardrobe",
			icon = "esoui/art/art/armory/builditem_icon.dds",
			disabled = function() return not WizardsWardrobe end,
			controls = {
				{
					type = "checkbox",
					name = GS(CSPS_LAM_CheckWW),
					tooltip = GS(CSPS_LAM_CheckWWTT),
					width = "full",
					getFunc = function() return options.checkWWSetup end,
					setFunc = function(value) 
							options.checkWWSetup = value
						end,
				},
				{
					type = "checkbox",
					name = GS(CSPS_LAM_CheckWWAuto),
					tooltip = GS(CSPS_LAM_CheckWWAutoTT),
					width = "full",
					getFunc = function() return options.checkWWSetupAuto end,
					setFunc = function(value) 
							options.checkWWSetupAuto = value
						end,
				},
				{
					type = "checkbox",
					name = GS(CSPS_LAM_CheckWWPassives),
					tooltip = GS(CSPS_LAM_CheckWWPassivesTT),
					width = "full",
					getFunc = function() return options.checkWWSetupPassives end,
					setFunc = function(value) 
							options.checkWWSetupPassives = value
						end,
				},
				
			}
		},
		{
			type = "submenu",
			name = "ESO-Hub Import",
			icon = "esoui/art/campaign/campaign_tabicon_summary_up.dds",
			controls = optionsForHubImport
		},
	}
	

	
	if not LibSets then 
		for i, v in pairs(optionsData) do
			if v.name == GS(SI_GAMEPAD_DYEING_EQUIPMENT_HEADER) then
				table.insert(v.controls, 1, 
					{
						type = "description",
						text = CSPS.colors.orange:Colorize(GS(CSPS_RequiresLibSets))
					}
				)
				break
			end
		end
	end
	
	local cspsPanel = LAM:RegisterAddonPanel("cspsOptions", panelData)
	LAM:RegisterOptionControls("cspsOptions", optionsData)	
	CSPS.panel = cspsPanel
	--[[
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel ~= cwsPanel then return end
			CarosWornSetsIndicator:SetHidden(false)
	end)

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
		if panel ~= cwsPanel then return end
		CarosWornSetsIndicator:SetHidden(true)
	end)
	]]--
end

function CSPS.openLAM()
	LAM:OpenToPanel(CSPS.panel)
	CSPSWindowOptions:SetHidden(true)
end