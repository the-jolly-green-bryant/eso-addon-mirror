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
			name = GetCollectibleCategoryNameByCategoryId(13),
			width = "full",
			getFunc = function() return options.showOutfits end,
			setFunc = function(value) 
					options.showOutfits = value
					CSPS.outfits.toggleShowInTree()
				end,
		},
		{
			type = "checkbox",
			name = GS(CSPS_IgnoreEmptyOutfitSlots),
			width = "full",
			disabled = function() return not options.showOutfits end,
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
					name = zo_strformat("<<C:1>>", GS(SI_CHAMPION_POINT_EARNED)),
					width = "full",
					tooltip = GS(SI_CHAMPION_POINT_EARNED),
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
				},
				{
					type = "checkbox",
					name = GS(CSPS_LAM_ShowOutdatedPresets),
					width = "full",
					tooltip = GS(CSPS_LAM_ShowOutdatedPresets),
					getFunc = function() return options.showOutdatedPresets end,
					setFunc = function(value) options.showOutdatedPresets = value end,
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
							CSPS.getTreeControl():RefreshVisible()
						end,
					disabled = function() return not CSPS.doGear end,
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
					disabled = function() return not CSPS.doGear end,
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
					disabled = function() return not (CSPS.doGear and options.showGearMarkers) end,
				},	
				{
					type = "checkbox",
					name = GS(CSPS_LAM_ShowNumSetItems),
					width = "full",
					tooltip = GS(CSPS_LAM_ShowNumSetItems),
					getFunc = function() return not options.hideNumSetItems end,
					setFunc = function(value) 
							options.hideNumSetItems = not value 
							CSPS.getTreeControl():RefreshVisible()
						end,
					disabled = function() return not (CSPS.doGear and options.showGearMarkers) end,
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
				{
					type = "checkbox",
					name = GS(CSPS_LAM_ShowBindBuild),
					tooltip = GS(CSPS_LAM_ShowBindBuild),
					width = "full",
					getFunc = function() return options.showBuildProfilesInBindingManager end,
					setFunc = function(value) options.showBuildProfilesInBindingManager = value end,
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
			controls = {
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
				{
					type = "checkbox",
					name = GS(SI_CHARACTER_MENU_SKILLS),
					width = "full",
					getFunc = function() return not options.applyAllExclude.skills end,
					setFunc = function(value) 
							options.applyAllExclude.skills = not value
						end,
					disabled = function() return not options.showApplyAll end,
				}, 
				{
					type = "checkbox",
					name = GS(SI_COLLECTIBLECATEGORYTYPE30),
					width = "full",
					getFunc = function() return not options.applyAllExclude.skillStyles end,
					setFunc = function(value) 
							options.applyAllExclude.skillStyles = not value
						end,
					disabled = function() return not options.showApplyAll end,
				},
				
				{
					type = "checkbox",
					name = GS(SI_CHARACTER_MENU_STATS),
					width = "full",
					getFunc = function() return not options.applyAllExclude.attr end,
					setFunc = function(value) 
							options.applyAllExclude.attr = not value
						end,
					disabled = function() return not options.showApplyAll end,
				},
				{
					type = "checkbox",
					name = GS(SI_STAT_GAMEPAD_CHAMPION_POINTS_LABEL),
					width = "full",
					getFunc = function() return not options.applyAllExclude.cp end,
					setFunc = function(value) 
							options.applyAllExclude.cp = not value
						end,
					disabled = function() return not options.showApplyAll end,
				},
				{
					type = "checkbox",
					name = GS(SI_INTERFACE_OPTIONS_ACTION_BAR),
					width = "full",
					getFunc = function() return not options.applyAllExclude.hb end,
					setFunc = function(value) 
							options.applyAllExclude.hb = not value
						end,
					disabled = function() return not options.showApplyAll end,
				},
				{
					type = "checkbox",
					name = GS(SI_GAMEPAD_DYEING_EQUIPMENT_HEADER),
					width = "full",
					getFunc = function() return CSPS.doGear and not options.applyAllExclude.gear end,
					setFunc = function(value) 
							options.applyAllExclude.gear = not value
						end,
					disabled = function() return not options.showApplyAll or not CSPS.doGear end,
				},
				{
					type = "checkbox",
					name = GS(SI_HOTBARCATEGORY10),
					width = "full",
					getFunc = function() return not options.applyAllExclude.qs end,
					setFunc = function(value) 
							options.applyAllExclude.qs = not value
						end,
					disabled = function() return not options.showApplyAll end,
				},
				{
					type = "checkbox",
					name = GetCollectibleCategoryNameByCategoryId(13),
					width = "full",
					getFunc = function() return options.showOutfits and not options.applyAllExclude.outfit end,
					setFunc = function(value) 
							options.applyAllExclude.outfit = not value
						end,
					disabled = function() return not options.showOutfits or not options.showApplyAll end,
				},
				
			}
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