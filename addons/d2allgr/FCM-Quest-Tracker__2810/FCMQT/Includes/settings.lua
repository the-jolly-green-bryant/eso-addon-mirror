FCMQT = FCMQT or {}
-- defaults Vars
-- Version : 1.5.5.26

function CreateSettings()
    --figure out 
    --Load LibAddonMenu
    local LAM  = LibAddonMenu2
    --Load LibMediaProvider
    local LMP   = LibMediaProvider
	
	local QTAuthor = "DesertDwellers"
	local QTVersion = "1.5.5.25"
	local lg = FCMQT.mylanguage
	local fontList = LMP:List('font')
	local langList = {"English", "Français", "Deutsch"}
	local fontStyles = {"normal", "outline", "shadow", "soft-shadow-thick", "soft-shadow-thin", "thick-outline"}
	local iconList = {"Arrow ESO (Default)", "Icon Dragonknight", "Icon Nightblade", "Icon Sorcerer", "Icon Templar"}
	-- This one has quest to chat maybe 1.6 version
	--local actionList = {"None", "Change Assisted Quest", "Filter by Current Zone", "Share a Quest", "Show on Map", "Remove a Quest", "Quest Info to Chat", "Quest Options Menu"}
	local actionList = {"None", "Change Assisted Quest", "Filter by Current Zone", "Share a Quest", "Show on Map", "Remove a Quest", "Quest Options Menu"}
	local sortList = {"Zone+Name", "Focused+Zone+Name"}
	--local sortlist = {FCMQT.mylanguage.sort_zone_name, FCMQT.mylanguage.sort_focus_zone_name}
	local DirectionList = {"TOP", "BOTTOM"}
	local presetList = {"Custom", "Default", "Preset1", "Preset2","Preset3"}
	local HideObjOptionList = {"Disabled","Focused Quest","Focused Zone"}
	local ChatSetupList = {"Disabled","Tracker Messages Only","Quest Details Only","All Chat Messages"}

	local optionsData = {}
	

    -- Create new menu
	local panelData = {
		type = "panel",
		name = FCMQT.mylanguage.lang_fcmqt_settings,
		displayName = ZO_HIGHLIGHT_TEXT:Colorize(FCMQT.mylanguage.lang_fcmqt_settings),	author = QTAuthor,
		version = QTVersion,
		slashCommand = "/fcmqt",
		registerForRefresh = true,
		--registerFordefaults = true,
		}
	LAM:RegisterAddonPanel("FCMQT_Settings", panelData)
	-- **setup info**
	--Global Settings
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = FCMQT.mylanguage.lang_global_settings,
		controls = {
			{--Language drop down
				type = "dropdown",
				name = FCMQT.mylanguage.lang_language_settings,
				tooltip = FCMQT.mylanguage.lang_language_settings_tip,
				choices = langList,
				getFunc = FCMQT.GetLanguage,
				setFunc = FCMQT.SetLanguage,
				warning = FCMQT.mylanguage.lang_menu_warn_1,
			},
			{--Preset Selection
				type = "dropdown",
				name = FCMQT.mylanguage.lang_preset_settings,
				tooltip = FCMQT.mylanguage.lang_preset_settings_tip,
				choices = presetList,
				getFunc = FCMQT.GetPreset,
				setFunc = FCMQT.SetPreset,
				warning = FCMQT.mylanguage.lang_menu_warn_2,
			},
			{--Hide When in Combat
				type = "checkbox",
				name = FCMQT.mylanguage.lang_HideInCombat,
				tooltip = FCMQT.mylanguage.lang_HideInCombat_tip,
				getFunc = FCMQT.GetHideInCombatOption,
				setFunc = FCMQT.SetHideInCombatOption,
			},
			{--Overall Transparency, if back ground
				type = "slider",
				name = FCMQT.mylanguage.lang_overall_transparency,
				tooltip = FCMQT.mylanguage.lang_overall_transparency_tip,
				min = 1,
				max = 100,
				getFunc = FCMQT.GetBgAlpha,
				setFunc = FCMQT.SetBgAlpha,
			},
			{--Overall Width
				type = "slider",
				name = FCMQT.mylanguage.lang_overall_width,
				tooltip = FCMQT.mylanguage.lang_overall_width_tip,
				min = 100,
				max = 600,
				getFunc = FCMQT.GetBgWidth,
				setFunc = FCMQT.SetBgWidth,
			},
			{--Lock BackGround Position
				type = "checkbox",
				name = FCMQT.mylanguage.lang_position_lock,
				tooltip = FCMQT.mylanguage.lang_position_lock_tip,
				getFunc = FCMQT.GetPositionLockOption,
				setFunc = FCMQT.SetPositionLockOption,
			},
			{--Enable Back Ground Color
				type = "checkbox",
				name = FCMQT.mylanguage.lang_backgroundcolor_opt,
				tooltip = FCMQT.mylanguage.lang_backgroundcolor_opt_tip,
				getFunc = FCMQT.GetBgOption,
				setFunc = FCMQT.SetBgOption,
			},
			{--Background Color picker
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_backgroundcolor_value,
				tooltip = FCMQT.mylanguage.lang_backgroundcolor_value_tip,
				getFunc = FCMQT.GetBgColor,
				setFunc = FCMQT.SetBgColor,
			},
		},
	} -- Mouse
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = FCMQT.mylanguage.lang_mouse_settings,
		controls = {
			{--Mouse Left Button
				type = "dropdown",
				name = FCMQT.mylanguage.lang_mouse_1,
				tooltip = FCMQT.mylanguage.lang_mouse_1_tip,
				choices = actionList,
				getFunc = FCMQT.GetButton1,
				setFunc = FCMQT.SetButton1,
			},
			{--Mouse Cnter Button
				type = "dropdown",
				name = FCMQT.mylanguage.lang_mouse_2,
				tooltip = FCMQT.mylanguage.lang_mouse_2_tip,
				choices = actionList,
				getFunc = FCMQT.GetButton3,
				setFunc = FCMQT.SetButton3,
			},
			{--Mouse Right Button
				type = "dropdown",
				name = FCMQT.mylanguage.lang_mouse_3,
				tooltip = FCMQT.mylanguage.lang_mouse_3_tip,
				choices = actionList,
				getFunc = FCMQT.GetButton2,
				setFunc = FCMQT.SetButton2,
			},
			{--Mouse Button 4
				type = "dropdown",
				name = FCMQT.mylanguage.lang_mouse_4,
				tooltip = FCMQT.mylanguage.lang_mouse_4_tip,
				choices = actionList,
				getFunc = FCMQT.GetButton4,
				setFunc = FCMQT.SetButton4,
			},
			{--Mouse Button 5
				type = "dropdown",
				name = FCMQT.mylanguage.lang_mouse_5,
				tooltip = FCMQT.mylanguage.lang_mouse_5_tip,
				choices = actionList,
				getFunc = FCMQT.GetButton5,
				setFunc = FCMQT.SetButton5,
			},
		},
	--[[}-- Chat Setup
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = FCMQT.mylanguage.lang_chat_settings,
		controls = {
			{--Enbaled Addon Messaging
				type = "checkbox",
				name = FCMQT.mylanguage.lang_Chat_AddonMessages,
				tooltip = FCMQT.mylanguage.lang_Chat_AddonMessages_tip,
				getFunc = FCMQT.GetChat_AddonMessages,
				setFunc = FCMQT.SetChat_AddonMessages,
			},
			{--Chat Addon Message Header Color
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_Chat_AddonMessage_HeaderColor,
				tooltip = FCMQT.mylanguage.lang_Chat_AddonMessage_HeaderColor_tip,
				getFunc = FCMQT.GetChat_AddonMessage_HeaderColor,
				setFunc = FCMQT.SetChat_AddonMessage_HeaderColor,
				disabled = function() return not FCMQT.SavedVars.Chat_AddonMessages end,
			},
			{--Chat Addon Message Header Color
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_Chat_AddonMessage_MsgColor,
				tooltip = FCMQT.mylanguage.lang_Chat_AddonMessage_MsgColor_tip,
				getFunc = FCMQT.GetChat_AddonMessage_MsgColor,
				setFunc = FCMQT.SetChat_AddonMessage_MsgColor,
				disabled = function() return not FCMQT.SavedVars.Chat_AddonMessages end,
			},
			{--Enable Quest Info
				type = "checkbox",
				name = FCMQT.mylanguage.lang_Chat_QuestInfo,
				tooltip = FCMQT.mylanguage.lang_Chat_Chat_QuestInfo,
				getFunc = FCMQT.GetChat_QuestInfo,
				setFunc = FCMQT.SetChat_QuestInfo,
			},
			{--Chat Addon Message Header Color
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_Chat_QuestInfo_HeaderColor,
				tooltip = FCMQT.mylanguage.lang_Chat_QuestInfo_HeaderColor_tip,
				getFunc = FCMQT.GetChat_QuestInfo_HeaderColor,
				setFunc = FCMQT.SetChat_QuestInfo_HeaderColor,
				disabled = function() return not FCMQT.SavedVars.Chat_QuestInfo end,
			},
			{--Chat Addon Message Header Color
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_Chat_QuestInfo_MsgColor,
				tooltip = FCMQT.mylanguage.lang_Chat_QuestInfo_MsgColor_tip,
				getFunc = FCMQT.GetChat_QuestInfo_MsgColor,
				setFunc = FCMQT.SetChat_QuestInfo_MsgColor,
				disabled = function() return not FCMQT.SavedVars.Chat_QuestInfo end,
			},
		},]]--
	}--zone
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = FCMQT.mylanguage.lang_area_settings,
		controls = {
			--zone/area enabled
			{
				type = "checkbox",
				name = FCMQT.mylanguage.lang_area_name,
				tooltip = FCMQT.mylanguage.lang_area_name_tip,
				getFunc = FCMQT.GetQuestsAreaOption,
				setFunc = FCMQT.SetQuestsAreaOption,
			},
			--zone/area hybrid/pure zone
			{
				type = "checkbox",
				name = FCMQT.mylanguage.lang_area_hybrid,
				tooltip = FCMQT.mylanguage.lang_area_hybrid_tip,
				getFunc = FCMQT.GetQuestsHybridOption,
				setFunc = FCMQT.SetQuestsHybridOption,
				disabled = function() return not FCMQT.SavedVars.QuestsAreaOption end,
			},
			--zone/area font
			{
				type = "dropdown",
				name = FCMQT.mylanguage.lang_area_font,
				tooltip = FCMQT.mylanguage.lang_area_font_tip,
				choices = fontList,
				getFunc = FCMQT.GetQuestsAreaFont,
				setFunc = FCMQT.SetQuestsAreaFont,
				disabled = function() return not FCMQT.SavedVars.QuestsAreaOption end,
			},
			--zone/area font style
			{
				type = "dropdown",
				name = FCMQT.mylanguage.lang_area_style,
				tooltip = FCMQT.mylanguage.lang_area_style_tip,
				choices = fontStyles,
				getFunc = FCMQT.GetQuestsAreaStyle,
				setFunc = FCMQT.SetQuestsAreaStyle,
				disabled = function() return not FCMQT.SavedVars.QuestsAreaOption end,
			},
			--zone/area font size
			{
				type = "slider",
				name = FCMQT.mylanguage.lang_area_size,
				tooltip = FCMQT.mylanguage.lang_area_size_tip,
				min = 8,
				max = 45,
				getFunc = FCMQT.GetQuestsAreaSize,
				setFunc = FCMQT.SetQuestsAreaSize,
				disabled = function() return not FCMQT.SavedVars.QuestsAreaOption end,
			},
			--zone/area padding
			{
				type = "slider",
				name = FCMQT.mylanguage.lang_area_padding,
				tooltip = FCMQT.mylanguage.lang_area_padding_tip,
				min = 1,
				max = 60,
				getFunc = FCMQT.GetQuestsAreaPadding,
				setFunc = FCMQT.SetQuestsAreaPadding,
				disabled = function() return not FCMQT.SavedVars.QuestsAreaOption end,
			},
			--zone/area color
			{
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_area_color,
				tooltip = FCMQT.mylanguage.lang_area_color_tip,
				getFunc = FCMQT.GetQuestsAreaColor,
				setFunc = FCMQT.SetQuestsAreaColor,
				disabled = function() return not FCMQT.SavedVars.QuestsAreaOption end,
			},
			--enable auto hide zone
			{
				type = "checkbox",
				name = FCMQT.mylanguage.lang_autohidequestzone_option,
				tooltip = FCMQT.mylanguage.lang_autohidequestzone_option_tip,
				getFunc = FCMQT.GetQuestsHideZoneOption,
				setFunc = FCMQT.SetQuestsHideZoneOption,
				disabled = function() return not FCMQT.SavedVars.QuestsAreaOption end,
			},
			--current zone only
			{
				type = "checkbox",
				name = FCMQT.mylanguage.lang_questzone_option,
				tooltip = FCMQT.mylanguage.lang_questzone_option_tip,
				getFunc = FCMQT.GetQuestsZoneOption,
				setFunc = FCMQT.SetQuestsZoneOption,
				disabled = function() return not FCMQT.SavedVars.QuestsAreaOption end, 
			},
		},
	}--Category Zone View Options
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = FCMQT.mylanguage.lang_quests_category_view_settings,
		controls = {
			{--Show/Hide Zone in Class Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_class_show_zone,
				tooltip = FCMQT.mylanguage.lang_class_show_zone_tip,
				getFunc = FCMQT.GetQuestsCategoryClassOption,
				setFunc = FCMQT.SetQuestsCategoryClassOption,
				disabled = function() return not FCMQT.SavedVars.QuestsHybridOption end,
			},
			{--Show/Hide Zone in Group Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_Group_show_zone,
				tooltip = FCMQT.mylanguage.lang_Group_show_zone_tip,
				getFunc = FCMQT.GetQuestsCategoryGroupOption,
				setFunc = FCMQT.SetQuestsCategoryGroupOption,
				disabled = function() return not FCMQT.SavedVars.QuestsHybridOption end,
			},
			{--Show/Hide Zone in Dungeon Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_Dungeon_show_zone,
				tooltip = FCMQT.mylanguage.lang_Dungeon_show_zone_tip,
				getFunc = FCMQT.GetQuestsCategoryDungeonOption,
				setFunc = FCMQT.SetQuestsCategoryDungeonOption,
				disabled = function() return not FCMQT.SavedVars.QuestsHybridOption end,
			},
		},
			{--Show/Hide Zone in Raid Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_Raid_show_zone,
				tooltip = FCMQT.mylanguage.lang_Raid_show_zone_tip,
				getFunc = FCMQT.GetQuestsCategoryRaidOption,
				setFunc = FCMQT.SetQuestsCategoryRaidOption,
				disabled = function() return not FCMQT.SavedVars.QuestsHybridOption end,
			},
	}--show quest types
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = FCMQT.mylanguage.lang_quests_filtered_settings,
		controls = {
			{--Show/Hide Quild Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_guild,
				tooltip = FCMQT.mylanguage.lang_quests_guild_tip,
				getFunc = FCMQT.GetQuestsZoneGuildOption,
				setFunc = FCMQT.SetQuestsZoneGuildOption,
			},
			{--Show/Hide Main Story Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_mainstory,
				tooltip = FCMQT.mylanguage.lang_quests_mainstory_tip,
				getFunc = FCMQT.GetQuestsZoneMainOption,
				setFunc = FCMQT.SetQuestsZoneMainOption,
			},
			{--Show/Hide Cyrodiil Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_cyrodiil,
				tooltip = FCMQT.mylanguage.lang_quests_cyrodiil_tip,
				getFunc = FCMQT.GetQuestsZoneCyrodiilOption,
				setFunc = FCMQT.SetQuestsZoneCyrodiilOption,
			},
			{--Show/Hide Class Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_class,
				tooltip = FCMQT.mylanguage.lang_quests_class_tip,
				getFunc = FCMQT.GetQuestsZoneClassOption,
				setFunc = FCMQT.SetQuestsZoneClassOption,
			},
			{--Show/Hide Quild Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_crafting,
				tooltip = FCMQT.mylanguage.lang_quests_crafting_tip,
				getFunc = FCMQT.GetQuestsZoneCraftingOption,
				setFunc = FCMQT.SetQuestsZoneCraftingOption,
			},
			{--Show/Hide Group Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_group,
				tooltip = FCMQT.mylanguage.lang_quests_group_tip,
				getFunc = FCMQT.GetQuestsZoneGroupOption,
				setFunc = FCMQT.SetQuestsZoneGroupOption,
			},
			{--Show/Hide Dungeon Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_dungeon,
				tooltip = FCMQT.mylanguage.lang_quests_dungeon_tip,
				getFunc = FCMQT.GetQuestsZoneDungeonOption,
				setFunc = FCMQT.SetQuestsZoneDungeonOption,
			},
			{--Show/Hide Raid Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_raid,
				tooltip = FCMQT.mylanguage.lang_quests_raid_tip,
				getFunc = FCMQT.GetQuestsZoneRaidOption,
				setFunc = FCMQT.SetQuestsZoneRaidOption,
			},
			{--Show/Hide AVA Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_AVA,
				tooltip = FCMQT.mylanguage.lang_quests_AVA_tip,
				getFunc = FCMQT.GetQuestsZoneAVAOption,
				setFunc = FCMQT.SetQuestsZoneAVAOption,
			},
			{--Show/Hide Event/Holiday Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_event,
				tooltip = FCMQT.mylanguage.lang_quests_event_tip,
				getFunc = FCMQT.GetQuestsZoneEventOption,
				setFunc = FCMQT.SetQuestsZoneEventOption,
			},
			{--Show/Hide Battle Ground Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_BG,
				tooltip = FCMQT.mylanguage.lang_quests_BG_tip,
				getFunc = FCMQT.GetQuestsZoneBGOption,
				setFunc = FCMQT.SetQuestsZoneBGOption,
			},
		},
	}--quest settings
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = FCMQT.mylanguage.lang_quests_settings,
		controls = {
			{--Quest Sorting
				type = "dropdown",
				name = FCMQT.mylanguage.lang_quests_sort,
				tooltip = FCMQT.mylanguage.lang_quests_sort_tip,
				choices = sortList,
				getFunc = FCMQT.GetSortQuests,
				setFunc = FCMQT.SetSortQuests,
			},
			{--Number of Quests Viewable
				type = "slider",
				name = FCMQT.mylanguage.lang_quests_nb,
				tooltip = FCMQT.mylanguage.lang_quests_nb_tip,
				min = 1,
				max = MAX_JOURNAL_QUESTS,
				getFunc = FCMQT.GetNbQuests,
				setFunc = FCMQT.SetNbQuests,
			},
			{--Auto Share Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_autoshare,
				tooltip = FCMQT.mylanguage.lang_quests_autoshare_tip,
				getFunc = FCMQT.GetAutoShareOption,
				setFunc = FCMQT.SetAutoShareOption,
			},
			--[[{--Auto Untrack Hidden Quets
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_autountrack,
				tooltip = FCMQT.mylanguage.lang_quests_autountrack_tip,
				getFunc = FCMQT.GetQuestsUntrackHiddenOption,
				setFunc = FCMQT.SetQuestsUntrackHiddenOption,
			},]]
			{--Enable Assisted Quest Icon
				type = "checkbox",
				name = FCMQT.mylanguage.lang_icon_opt,
				tooltip = FCMQT.mylanguage.lang_icon_opt_tip,
				getFunc = FCMQT.GetQuestIconOption,
				setFunc = FCMQT.SetQuestIconOption,
			},
			{--Quest Icon Texture
				type = "dropdown",
				name = FCMQT.mylanguage.lang_icon_texture,
				tooltip = FCMQT.mylanguage.lang_icon_texture_tip,
				choices = iconList,
				getFunc = FCMQT.GetQuestIcon,
				setFunc = FCMQT.SetQuestIcon,
				disabled = function() return not FCMQT.SavedVars.QuestIconOption end,
			},
			{--Quest Icon Size
				type = "slider",
				name = FCMQT.mylanguage.lang_icon_size,
				tooltip = FCMQT.mylanguage.lang_icon_size_tip,
				min = 18,
				max = 40,
				getFunc = FCMQT.GetQuestIconSize,
				setFunc = FCMQT.SetQuestIconSize,
				disabled = function() return not FCMQT.SavedVars.QuestIconOption end,
			},
			{--Quest Icon Color
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_icon_color,
				tooltip = FCMQT.mylanguage.lang_icon_color_tip,
				getFunc = FCMQT.GetQuestIconColor,
				setFunc = FCMQT.SetQuestIconColor,
				disabled = function() return not FCMQT.SavedVars.QuestIconOption end,
			},
			{--Enable Transparency for Not Focused Quests
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_transparency_opt,
				tooltip = FCMQT.mylanguage.lang_quests_transparency_opt_tip,
				getFunc = FCMQT.GetQuestsNoFocusOption,
				setFunc = FCMQT.SetQuestsNoFocusOption,
			},
			{--Focused Quest Zone Not Transparent
				type = "checkbox",
				name = FCMQT.mylanguage.lang_no_trans_focused_zone,
				tooltip = FCMQT.mylanguage.lang_no_trans_focused_zone_tip,
				getFunc = FCMQT.GetFocusedQuestAreaNoTrans,
				setFunc = FCMQT.SetFocusedQuestAreaNoTrans,
				disable = function() return not FCMQT.SavedVars.QuestsNoFocusOption end,
			},			
			{-- Not Focus Quests Transparency
				type = "slider",
				name = FCMQT.mylanguage.lang_quests_transparency,
				tooltip = FCMQT.mylanguage.lang_quests_transparency_tip,
				min = 1,
				max = 100,
				getFunc = FCMQT.GetQuestsNoFocusTransparency,
				setFunc = FCMQT.SetQuestsNoFocusTransparency,
				disable = function() return not FCMQT.SavedVars.QuestsNoFocusOption end,
			},
		},
		}--Quest Timer Settings
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = FCMQT.mylanguage.lang_quests_timer_settings,
		controls = {
			{-- Show Timer
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_show_timer,
				tooltip = FCMQT.mylanguage.lang_quests_show_timer_tip,
				getFunc = FCMQT.GetQuestsShowTimerOption,
				setFunc = FCMQT.SetQuestsShowTimerOption,
			},
			{--Timer Font
				type = "dropdown",
				name = FCMQT.mylanguage.lang_timer_title_font,
				tooltip = FCMQT.mylanguage.lang_timer_title_font_tip,
				choices = fontList,
				getFunc = FCMQT.GetTimerTitleFont,
				setFunc = FCMQT.SetTimerTitleFont,
				disabled = function() return not FCMQT.SavedVars.QuestsShowTimerOption end,
			},
			{--Timer Style
				type = "dropdown",
				name = FCMQT.mylanguage.lang_timer_title_style,
				tooltip = FCMQT.mylanguage.lang_timer_title_style_tip,
				choices = fontStyles,
				getFunc = FCMQT.GetTimerTitleStyle,
				setFunc = FCMQT.SetTimerTitleStyle,
				disabled = function() return not FCMQT.SavedVars.QuestsShowTimerOption end,
			},
			{--Timer Font Size
				type = "slider",
				name = FCMQT.mylanguage.lang_timer_title_size,
				tooltip = FCMQT.mylanguage.lang_timer_title_size_tip,
				min = 8,
				max = 45,
				getFunc = FCMQT.GetTimerTitleSize,
				setFunc = FCMQT.SetTimerTitleSize,
				disabled = function() return not FCMQT.SavedVars.QuestsShowTimerOption end,
			},
			{--Timer Color Picker
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_timer_title_color,
				tooltip = FCMQT.mylanguage.lang_timer_title_color_tip,
				getFunc = FCMQT.GetTimerTitleColor,
				setFunc = FCMQT.SetTimerTitleColor,
				disabled = function() return not FCMQT.SavedVars.QuestsShowTimerOption end,
			},
		},--
	}--Quest Name Settings
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = FCMQT.mylanguage.lang_titles_settings,
		controls = {
			{
				type = "dropdown",
				name = FCMQT.mylanguage.lang_titles_font,
				tooltip = FCMQT.mylanguage.lang_titles_font_tip,
				choices = fontList,
				getFunc = FCMQT.GetTitleFont,
				setFunc = FCMQT.SetTitleFont,
			},
			{
				type = "dropdown",
				name = FCMQT.mylanguage.lang_titles_style,
				tooltip = FCMQT.mylanguage.lang_titles_style_tip,
				choices = fontStyles,
				getFunc = FCMQT.GetTitleStyle,
				setFunc = FCMQT.SetTitleStyle,
			},
			{
				type = "slider",
				name = FCMQT.mylanguage.lang_titles_size,
				tooltip = FCMQT.mylanguage.lang_titles_size_tip,
				min = 8,
				max = 45,
				getFunc = FCMQT.GetTitleSize,
				setFunc = FCMQT.SetTitleSize,
			},
			{
				type = "slider",
				name = FCMQT.mylanguage.lang_titles_padding,
				tooltip = FCMQT.mylanguage.lang_titles_padding_tip,
				min = 1,
				max = 60,
				getFunc = FCMQT.GetTitlePadding,
				setFunc = FCMQT.SetTitlePadding,
			},
			{
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_titles_default,
				tooltip = FCMQT.mylanguage.lang_titles_default_tip,
				getFunc = FCMQT.GetTitleColor,
				setFunc = FCMQT.SetTitleColor,
			},
		},
	}-- Objective Settings
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = FCMQT.mylanguage.lang_obj_settings,
		controls = {
			{--font
				type = "dropdown",
				name = FCMQT.mylanguage.lang_obj_font,
				tooltip = FCMQT.mylanguage.lang_obj_font_tip,
				choices = fontList,
				getFunc = FCMQT.GetTextFont,
				setFunc = FCMQT.SetTextFont,
			},
			{--font style
				type = "dropdown",
				name = FCMQT.mylanguage.lang_obj_style,
				tooltip = FCMQT.mylanguage.lang_obj_style_tip,
				choices = fontStyles,
				getFunc = FCMQT.GetTextStyle,
				setFunc = FCMQT.SetTextStyle,
			},
			{--font size
				type = "slider",
				name = FCMQT.mylanguage.lang_obj_size,
				tooltip = FCMQT.mylanguage.lang_obj_size_tip,
				min = 8,
				max = 45,
				getFunc = FCMQT.GetTextSize,
				setFunc = FCMQT.SetTextSize,
			},
			{--objecitvie padding --
				type = "slider",
				name = FCMQT.mylanguage.lang_obj_padding,
				tooltip = FCMQT.mylanguage.lang_obj_padding_tip,
				min = 1,
				max = 60,
				getFunc = FCMQT.GetTextPadding,
				setFunc = FCMQT.SetTextPadding,
			},
			{--Use Condition/Quest Step Icons
				type = "checkbox",
				name = FCMQT.mylanguage.lang_QuestObjIcon,
				tooltip = FCMQT.mylanguage.lang_QuestObjIcon_tip,
				getFunc = FCMQT.GetQuestObjIcon,
				setFunc = FCMQT.SetQuestObjIcon,
			},
			{--Hide Objective/Hints Except when option (HideObjOption)
				type = "dropdown",
				name = FCMQT.mylanguage.lang_HideObjOption,
				tooltip = FCMQT.mylanguage.lang_HideObjOption_tip,
				choices = HideObjOptionList,
				getFunc = FCMQT.GetHideObjOption,
				setFunc = FCMQT.SetHideObjOption,
				default = "Disabled"
			},
			{-- Hide completed--
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_hide_obj_optional,
				tooltip = FCMQT.mylanguage.lang_quests_hide_obj_optional_tip,
				getFunc = FCMQT.GetHideCompleteObjHints,
				setFunc = FCMQT.SetHideCompleteObjHints,
			},
			{-- Objective Color--
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_obj_color,
				tooltip = FCMQT.mylanguage.lang_obj_color_tip,
				getFunc = FCMQT.GetTextColor,
				setFunc = FCMQT.SetTextColor,
			},
			{-- Objective Color Completed--
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_obj_ccolor,
				tooltip = FCMQT.mylanguage.lang_obj_ccolor_tip,
				getFunc = FCMQT.GetTextCompleteColor,
				setFunc = FCMQT.SetTextCompleteColor,
			},
			{--Hide Optional/Hidden Quest Info/Hints ALL
				type = "checkbox",
				name = FCMQT.mylanguage.lang_quests_optinfos,
				tooltip = FCMQT.mylanguage.lang_quests_optinfos_tip,
				getFunc = FCMQT.GetHideInfoHintsOption,
				setFunc = FCMQT.SetHideInfoHintsOption,
			},
			{--Hide Optional Information
				type = "checkbox",
				name = FCMQT.mylanguage.lang_HideOptionalInfo,
				tooltip = FCMQT.mylanguage.lang_HideOptionalInfo_tip,
				getFunc = FCMQT.GetHideOptionalInfo,
				setFunc = FCMQT.SetHideOptionalInfo,
				disabled = function() return FCMQT.SavedVars.HideInfoHintsOption end,
			},
			{--Hide Optional Objectives
				type = "checkbox",
				name = FCMQT.mylanguage.lang_HideOptObjective,
				tooltip = FCMQT.mylanguage.lang_HideOptObjective_tip,
				getFunc = FCMQT.GetHideOptObjective,
				setFunc = FCMQT.SetHideOptObjective,
				disabled = function() return FCMQT.SavedVars.HideInfoHintsOption end,
			},
			{--Optional Color--
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_obj_optcolor,
				tooltip = FCMQT.mylanguage.lang_obj_optcolor_tip,
				getFunc = FCMQT.GetTextOptionalColor,
				setFunc = FCMQT.SetTextOptionalColor,
				disabled = function() return FCMQT.SavedVars.HideInfoHintsOption end,
			},
			{--Completed Optional Color Complete--
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_obj_optccolor,
				tooltip = FCMQT.mylanguage.lang_obj_optccolor_tip,
				getFunc = FCMQT.GetTextOptionalCompleteColor,
				setFunc = FCMQT.SetTextOptionalCompleteColor,
				disabled = function() return FCMQT.SavedVars.HideInfoHintsOption end,
			},
			{--Hide Hints--
				type = "checkbox",
				name = FCMQT.mylanguage.lang_HideHintsOption,
				tooltip = FCMQT.mylanguage.lang_HideHintsOption_tip,
				getFunc = FCMQT.GetHideHintsOption,
				setFunc = FCMQT.SetHideHintsOption,
				disabled = function() return FCMQT.SavedVars.HideInfoHintsOption end,
			},
			{--Hide Hidden Hints--
				type = "checkbox",
				name = FCMQT.mylanguage.lang_HideHiddenOptions,
				tooltip = FCMQT.mylanguage.lang_HideHiddenOptions_tip,
				getFunc = FCMQT.GetHideHiddenOptions,
				setFunc = FCMQT.SetHideHiddenOptions,
				disabled = function() return FCMQT.SavedVars.HideInfoHintsOption end,
			},
			{--Hints Color--
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_HintColor,
				tooltip = FCMQT.mylanguage.lang_HintColor_tip,
				getFunc = FCMQT.GetHintColor,
				setFunc = FCMQT.SetHintColor,
				disabled = function() return FCMQT.SavedVars.HideInfoHintsOption end,
			},
			{--Completed Hints Color--not
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_HintCompleteColor,
				tooltip = FCMQT.mylanguage.lang_HintCompleteColor_tip,
				getFunc = FCMQT.GetHintCompleteColor,
				setFunc = FCMQT.SetHintCompleteColor,
				disabled = function() return FCMQT.SavedVars.HideInfoHintsOption end,
			},
		},
	}--Info Settings
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = FCMQT.mylanguage.lang_infos_settings,
		controls = {
			{
				type = "checkbox",
				name = FCMQT.mylanguage.lang_infos_opt,
				tooltip = FCMQT.mylanguage.lang_infos_opt_tip,
				getFunc = FCMQT.GetShowJournalInfosOption,
				setFunc = FCMQT.SetShowJournalInfosOption,
			},
			{
				type = "dropdown",
				name = FCMQT.mylanguage.lang_infos_font,
				tooltip = FCMQT.mylanguage.lang_infos_font_tip,
				choices = fontList,
				getFunc = FCMQT.GetShowJournalInfosFont,
				setFunc = FCMQT.SetShowJournalInfosFont,
			},
			{
				type = "dropdown",
				name = FCMQT.mylanguage.lang_infos_style,
				tooltip = FCMQT.mylanguage.lang_infos_style_tip,
				choices = fontStyles,
				getFunc = FCMQT.GetShowJournalInfosStyle,
				setFunc = FCMQT.SetShowJournalInfosStyle,
			},
			{
				type = "slider",
				name = FCMQT.mylanguage.lang_infos_size,
				tooltip = FCMQT.mylanguage.lang_infos_size_tip,
				min = 8,
				max = 45,
				getFunc = FCMQT.GetShowJournalInfosSize,
				setFunc = FCMQT.SetShowJournalInfosSize,
			},
			{
				type = "colorpicker",
				name = FCMQT.mylanguage.lang_infos_color,
				tooltip = FCMQT.mylanguage.lang_infos_color_tip,
				getFunc = FCMQT.GetShowJournalInfosColor,
				setFunc = FCMQT.SetShowJournalInfosColor,
			},
		},
	}
	--LAM:RegisterAddonPanel("FCMQT_Settings", panelData)
	LAM:RegisterOptionControls("FCMQT_Settings", optionsData)
	
	--    LAM2:RegisterAddonPanel('LUIEAddonOptions', panelData)
    --LAM2:RegisterOptionControls('LUIEAddonOptions', optionsData)
end