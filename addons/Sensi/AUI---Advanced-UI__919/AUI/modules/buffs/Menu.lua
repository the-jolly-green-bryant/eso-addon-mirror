AUI.Settings.Buffs = {}

local g_LAM = LibAddonMenu2
local g_isInit = false
local g_isPreviewShowing = false

local function GetDefaultSettings()
	local defaultSettings =
	{
		--general
		lock_window = false,			

		--player buffs
		
		player_buff_position = 
		{
			point = BOTTOM,
			relativePoint = BOTTOM,
			offsetX = -180,
			offsetY = -210,
		},		
		
		player_show_buff_time = true,
		player_buff_font_art = "EsoUI/Common/Fonts/univers67.otf",
		player_buff_font_size = 12,
			
		player_buff_size = 40,
		gamepad_player_buff_size = 60,
		player_buff_distance = 10,

		player_show_permanent_buffs = false,
		player_show_time_limit_buffs = true,
		player_allow_only_own_buffs = false,
		player_buff_sorting = AUI_SORTING_LARGE_TO_SMALL,
		player_buff_alignment = AUI_HORIZONTAL,
		player_buff_text_position = AUI_TEXT_ANCHOR_INSIDE,

		--player debuffs
		
		player_debuff_position = 
		{
			point = BOTTOM,
			relativePoint = BOTTOM,
			offsetX = -180,
			offsetY = -87,
		},			
		
		player_show_debuff_time = true,
		player_debuff_font_art = "EsoUI/Common/Fonts/univers67.otf",
		player_debuff_font_size = 12,		
		
		player_show_debuffs = true,			
		player_debuff_size = 40,
		gamepad_player_debuff_size = 40,
		player_debuff_distance = 10,		
		player_debuff_sorting = AUI_SORTING_LARGE_TO_SMALL,
		player_debuff_alignment = AUI_HORIZONTAL,
		player_debuff_text_position = AUI_TEXT_ANCHOR_INSIDE,
		
		--target buffs
		
		target_buff_position = 
		{
			point = TOP,
			relativePoint = TOP,
			offsetX = -130,
			offsetY = 84,
		},

		target_show_buff_time = true,
		target_buff_font_art = "EsoUI/Common/Fonts/univers67.otf",
		target_buff_font_size = 12,	

		target_buff_size = 40,
		gamepad_target_buff_size = 60,
		target_buff_distance = 10,
		target_show_permanent_buffs = false,
		target_show_time_limit_buffs = true,
		target_buff_sorting = AUI_SORTING_LARGE_TO_SMALL,
		target_buff_alignment = AUI_HORIZONTAL,	
		target_buff_text_position = AUI_TEXT_ANCHOR_INSIDE,

		--target debuffs
			
		target_debuff_position = 
		{
			point = TOP,
			relativePoint = TOP,
			offsetX = -130,
			offsetY = 220,
		},

		target_show_debuff_time = true,
		target_debuff_font_art = "EsoUI/Common/Fonts/univers67.otf",
		target_debuff_font_size = 12,			
		
		target_show_debuffs = true,	
		player_allow_only_own_debuffs = true,
		target_debuff_size = 40,
		gamepad_target_debuff_size = 60,
		target_debuff_distance = 10,
		target_debuff_sorting = AUI_SORTING_LARGE_TO_SMALL,	
		target_debuff_alignment = AUI_HORIZONTAL,	
		target_debuff_text_position = AUI_TEXT_ANCHOR_INSIDE,		
	}
	
	return defaultSettings
end 

local function GetCurrentTemplateName()
	return AUI.Buffs.GetCurrentTemplateData().internName
end

local function CreateOptions()
	local optionsTable = 
	{	
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("general"))
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("acount_wide"),
			tooltip = AUI.L10n.GetString("acount_wide_tooltip"),
			getFunc = function() return AUI.Settings.MainMenu.modul_buffs_account_wide end,
			setFunc = function(value)
				if value ~= nil then
					if value ~= AUI.Settings.MainMenu.modul_buffs_account_wide then
						AUI.Settings.MainMenu.modul_buffs_account_wide = value
						ReloadUI()
					else
						AUI.Settings.MainMenu.modul_buffs_account_wide = value
					end
				end
			end,
			default = true,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_warning_tooltip"),
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("lock_window"),
			tooltip = AUI.L10n.GetString("lock_window_tooltip"),
			getFunc = function() return AUI.Settings.Buffs.lock_window end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Settings.Buffs.lock_window = value
				end
			end,
			default = GetDefaultSettings().lock_window,
			width = "full",
		},			
		{
			type = "checkbox",
			name = AUI.L10n.GetString("preview"),
			tooltip = AUI.L10n.GetString("preview_tooltip"),
			getFunc = function() return g_isPreviewShowing end,
			setFunc = function(value)
				if value ~= nil then
					AUI.Buffs.ShowPreview(value)	
					g_isPreviewShowing = value
				end
			end,
			default = g_isPreviewShowing,
			width = "full",
			warning = AUI.L10n.GetString("preview_warning"),	
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("template"),
			tooltip = AUI.L10n.GetString("template_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Buffs.GetThemeNames(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Buffs.GetThemeNames(), GetCurrentTemplateName()) end,
			setFunc = function(value) 
				value = AUI.Table.GetKey(AUI.Buffs.GetThemeNames(), value)
				if value ~= nil then
					if GetCurrentTemplateName() ~= value then
						if value ~= AUI.Settings.Templates.Buffs then
							AUI.Settings.Templates.Buffs = value
							ReloadUI()
						else
							AUI.Settings.Templates.Buffs = value
						end
					end
				end
			end,			
			warning = AUI.L10n.GetString("reloadui_warning_tooltip"),
		},		
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize( AUI.L10n.GetString("player")),
			controls = 
			{	
				{
					type = "header",
					name =  AUI.L10n.GetString("buffs"),
				},	
				{
					type = "checkbox",
					name =  AUI.L10n.GetString("show_permanent_buffs"),
					tooltip = AUI.L10n.GetString("show_permanent_buffs_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.player_show_permanent_buffs end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.player_show_permanent_buffs = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_show_permanent_buffs,
					width = "full",
				},	
				{
					type = "checkbox",
					name =  AUI.L10n.GetString("show_time_limit_buffs"),
					tooltip = AUI.L10n.GetString("show_time_limit_buffs_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.player_show_time_limit_buffs end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.player_show_time_limit_buffs = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_show_time_limit_buffs,
					width = "full",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("allow_only_own"),
					tooltip = AUI.L10n.GetString("allow_only_own_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.player_allow_only_own_buffs end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.player_allow_only_own_buffs = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_allow_only_own_buffs,
					width = "full",
				},					
				{
					type = "slider",
					name =  AUI.L10n.GetString("size"),
					tooltip =  AUI.L10n.GetString("size_tooltip"),
					min = 24,
					max = 80,
					step = 1,
					getFunc = function()
						if IsInGamepadPreferredMode() then
							return AUI.Settings.Buffs.gamepad_player_buff_size
						else
							return AUI.Settings.Buffs.player_buff_size
						end
					end,
					setFunc = function(value)
						if value ~= nil then
							if IsInGamepadPreferredMode() then
								AUI.Settings.Buffs.gamepad_player_buff_size = value
							else
								AUI.Settings.Buffs.player_buff_size = value
							end
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_buff_size,
					width = "full",
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("distance"),
					tooltip = AUI.L10n.GetString("distance_tooltip"),
					min = 2,
					max = 24,
					step = 2,
					getFunc = function() return AUI.Settings.Buffs.player_buff_distance end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.player_buff_distance = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_buff_distance,
					width = "full",			
				},								
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAlignmentList(), AUI.Settings.Buffs.player_buff_alignment) end,
					setFunc = function(value) 	
						if value ~= nil then
							AUI.Settings.Buffs.player_buff_alignment = AUI.Table.GetKey(AUI.Menu.GetAlignmentList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAlignmentList(), GetDefaultSettings().player_buff_alignment),			
				},			
				{
					type = "dropdown",
					name = AUI.L10n.GetString("sorting"),
					tooltip = AUI.L10n.GetString("sorting_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSortingList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSortingList(), AUI.Settings.Buffs.player_buff_sorting) end,
					setFunc = function(value) 	
						if value ~= nil then
							AUI.Settings.Buffs.player_buff_sorting = AUI.Table.GetKey(AUI.Menu.GetSortingList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSortingList(), GetDefaultSettings().player_buff_sorting),			
				},
				{
					type = "checkbox",
					name =  AUI.L10n.GetString("show_buff_remain_time"),
					tooltip = AUI.L10n.GetString("show_buff_remain_time_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.player_show_buff_time end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.player_show_buff_time = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_show_buff_time,
					width = "full",
				},		
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Buffs.player_buff_font_art) end,
					setFunc = function(value) 	
						if value ~= nil then
							AUI.Settings.Buffs.player_buff_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,	
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().player_buff_font_art),
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 2,
					max = 30 ,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.player_buff_font_size end,
					setFunc = function(value) 
						if value ~= nil then
							AUI.Settings.Buffs.player_buff_font_size = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_buff_font_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("text_position"),
					tooltip = AUI.L10n.GetString("text_position_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAnchorList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAnchorList(), AUI.Settings.Buffs.player_buff_text_position) end,
					setFunc = function(value) 	
						if value ~= nil then
							AUI.Settings.Buffs.player_buff_text_position = AUI.Table.GetKey(AUI.Menu.GetAnchorList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAnchorList(), GetDefaultSettings().player_buff_text_position),			
				},					
				{
					type = "header",
					name = AUI.L10n.GetString("debuffs"),
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_debuffs"),
					tooltip = AUI.L10n.GetString("show_debuffs_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.player_show_debuffs end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.player_show_debuffs = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_show_debuffs,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 24,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.player_debuff_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.player_debuff_size = value
							AUI.Settings.Buffs.gamepad_player_debuff_size = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_debuff_size,
					width = "full",
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("distance"),
					tooltip = AUI.L10n.GetString("distance_tooltip"),
					min = 2,
					max = 24,
					step = 2,
					getFunc = function() return AUI.Settings.Buffs.player_debuff_distance end,
					setFunc = function(value) 
						if value ~= nil then
							AUI.Settings.Buffs.player_debuff_distance = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_debuff_distance,
					width = "full",			
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAlignmentList(), AUI.Settings.Buffs.player_debuff_alignment) end,
					setFunc = function(value) 		
						if value ~= nil then
							AUI.Settings.Buffs.player_debuff_alignment = AUI.Table.GetKey(AUI.Menu.GetAlignmentList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAlignmentList(), GetDefaultSettings().player_debuff_alignment),			
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("sorting"),
					tooltip = AUI.L10n.GetString("sorting_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSortingList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSortingList(), AUI.Settings.Buffs.player_debuff_sorting) end,
					setFunc = function(value) 	
						if value ~= nil then
							AUI.Settings.Buffs.player_debuff_sorting = AUI.Table.GetKey(AUI.Menu.GetSortingList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSortingList(), GetDefaultSettings().player_debuff_sorting),			
				},	
				{
					type = "checkbox",
					name =  AUI.L10n.GetString("show_buff_remain_time"),
					tooltip = AUI.L10n.GetString("show_buff_remain_time_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.player_show_debuff_time end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.player_show_debuff_time = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_show_debuff_time,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Buffs.player_debuff_font_art) end,
					setFunc = function(value) 
						if value ~= nil then
							AUI.Settings.Buffs.player_debuff_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().player_debuff_font_art),					
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 2,
					max = 30 ,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.player_debuff_font_size end,
					setFunc = function(value) 
						if value ~= nil then
							AUI.Settings.Buffs.player_debuff_font_size = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_debuff_font_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("text_position"),
					tooltip = AUI.L10n.GetString("text_position_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAnchorList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAnchorList(), AUI.Settings.Buffs.player_debuff_text_position) end,
					setFunc = function(value) 	
						if value ~= nil then
							AUI.Settings.Buffs.player_debuff_text_position = AUI.Table.GetKey(AUI.Menu.GetAnchorList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAnchorList(), GetDefaultSettings().player_debuff_text_position),			
				},												
			}
		},		
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("target")),
			controls = 
			{	
				{
					type = "header",
					name = AUI.L10n.GetString("buffs"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_permanent_buffs"),
					tooltip = AUI.L10n.GetString("show_permanent_buffs_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.target_show_permanent_buffs end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.target_show_permanent_buffs = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().target_show_permanent_buffs,
					width = "full",
				},				
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_time_limit_buffs"),
					tooltip = AUI.L10n.GetString("show_time_limit_buffs_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.target_show_time_limit_buffs end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.target_show_time_limit_buffs = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().target_show_time_limit_buffs,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 24,
					max = 80,
					step = 1,
					getFunc = function()
						if IsInGamepadPreferredMode() then
							return AUI.Settings.Buffs.gamepad_target_buff_size
						else
							return AUI.Settings.Buffs.target_buff_size
						end
					end,
					setFunc = function(value)
						if value ~= nil then
							if IsInGamepadPreferredMode() then
								AUI.Settings.Buffs.gamepad_target_buff_size = value
							else
								AUI.Settings.Buffs.target_buff_size = value
							end
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().target_buff_size,
					width = "full",
				},		
				{
					type = "slider",
					name = AUI.L10n.GetString("distance"),
					tooltip = AUI.L10n.GetString("distance_tooltip"),
					min = 2,
					max = 24,
					step = 2,
					getFunc = function() return AUI.Settings.Buffs.target_buff_distance end,
					setFunc = function(value) 
						if value ~= nil then
							AUI.Settings.Buffs.target_buff_distance = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().target_buff_distance,
					width = "full",			
				},								
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAlignmentList(), AUI.Settings.Buffs.target_buff_alignment) end,
					setFunc = function(value) 
						if value ~= nil then
							AUI.Settings.Buffs.target_buff_alignment = AUI.Table.GetKey(AUI.Menu.GetAlignmentList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAlignmentList(), GetDefaultSettings().target_buff_alignment),			
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("sorting"),
					tooltip = AUI.L10n.GetString("sorting_buff_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSortingList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSortingList(), AUI.Settings.Buffs.target_buff_sorting) end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.target_buff_sorting = AUI.Table.GetKey(AUI.Menu.GetSortingList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSortingList(), GetDefaultSettings().target_buff_sorting),			
				},	
				{
					type = "checkbox",
					name =  AUI.L10n.GetString("show_buff_remain_time"),
					tooltip = AUI.L10n.GetString("show_buff_remain_time_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.target_show_buff_time end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.target_show_buff_time = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().target_show_buff_time,
					width = "full",
				},		
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Buffs.target_buff_font_art) end,
					setFunc = function(value) 
						if value ~= nil then
							AUI.Settings.Buffs.target_buff_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().target_buff_font_art),					
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 2,
					max = 30 ,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.target_buff_font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.target_buff_font_size = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().target_buff_font_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("text_position"),
					tooltip = AUI.L10n.GetString("text_position_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAnchorList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAnchorList(), AUI.Settings.Buffs.target_buff_text_position) end,
					setFunc = function(value) 	
						if value ~= nil then
							AUI.Settings.Buffs.target_buff_text_position = AUI.Table.GetKey(AUI.Menu.GetAnchorList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAnchorList(), GetDefaultSettings().target_buff_text_position),			
				},					
				{
					type = "header",
					name = AUI.L10n.GetString("debuffs"),
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_debuffs"),
					tooltip = AUI.L10n.GetString("show_debuffs_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.target_show_debuffs end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.target_show_debuffs = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().target_show_debuffs,
					width = "full",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("allow_only_own"),
					tooltip = AUI.L10n.GetString("allow_only_own_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.player_allow_only_own_debuffs end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.player_allow_only_own_debuffs = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().player_allow_only_own_debuffs,
					width = "full",
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 24,
					max = 80,
					step = 1,
					getFunc = function()
						if IsInGamepadPreferredMode() then
							return AUI.Settings.Buffs.gamepad_target_debuff_size
						else
							return AUI.Settings.Buffs.target_debuff_size
						end
					end,
					setFunc = function(value)
						if value ~= nil then
							if IsInGamepadPreferredMode() then
								AUI.Settings.Buffs.gamepad_target_debuff_size = value
							else
								AUI.Settings.Buffs.target_debuff_size = value
							end
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().target_debuff_size,
					width = "full",
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("distance"),
					tooltip = AUI.L10n.GetString("distance_tooltip"),
					min = 2,
					max = 24,
					step = 2,
					getFunc = function() return AUI.Settings.Buffs.target_debuff_distance end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.target_debuff_distance = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().target_debuff_distance,
					width = "full",			
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("alignment"),
					tooltip = AUI.L10n.GetString("alignment_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAlignmentList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAlignmentList(), AUI.Settings.Buffs.target_debuff_alignment) end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.target_debuff_alignment = AUI.Table.GetKey(AUI.Menu.GetAlignmentList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAlignmentList(), GetDefaultSettings().target_debuff_alignment),			
				},						
				{
					type = "dropdown",
					name = AUI.L10n.GetString("sorting"),
					tooltip = AUI.L10n.GetString("sorting_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSortingList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSortingList(), AUI.Settings.Buffs.target_debuff_sorting) end,
					setFunc = function(value) 		
						if value ~= nil then
							AUI.Settings.Buffs.target_debuff_sorting = AUI.Table.GetKey(AUI.Menu.GetSortingList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSortingList(), GetDefaultSettings().target_debuff_sorting),			
				},	
				{
					type = "checkbox",
					name =  AUI.L10n.GetString("show_buff_remain_time"),
					tooltip = AUI.L10n.GetString("show_buff_remain_time_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.target_show_debuff_time end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Buffs.target_show_debuff_time = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().target_show_debuff_time,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Buffs.target_debuff_font_art) end,
					setFunc = function(value) 	
						if value ~= nil then
							AUI.Settings.Buffs.target_debuff_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().target_debuff_font_art),					
				},		
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 2,
					max = 30 ,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.target_debuff_font_size end,
					setFunc = function(value) 
						if value ~= nil then
							AUI.Settings.Buffs.target_debuff_font_size = value
							AUI.Buffs.RefreshAll()
						end
					end,
					default = GetDefaultSettings().target_debuff_font_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("text_position"),
					tooltip = AUI.L10n.GetString("text_position_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetAnchorList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetAnchorList(), AUI.Settings.Buffs.target_debuff_text_position) end,
					setFunc = function(value) 	
						if value ~= nil then
							AUI.Settings.Buffs.target_debuff_text_position = AUI.Table.GetKey(AUI.Menu.GetAnchorList(), value)
							AUI.Buffs.RefreshAll()
						end
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetAnchorList(), GetDefaultSettings().target_debuff_text_position),			
				},					
			}
		},			
		{
			type = "button",
			name = AUI.L10n.GetString("reset_to_default_position"),
			tooltip = AUI.L10n.GetString("reset_to_default_position_tooltip"),
			func = function() AUI.Buffs.SetToDefaultPosition(GetDefaultSettings()) end,
		},			
	}
	
	return optionsTable
end

function AUI.Buffs.LoadSettings()
	if g_isInit then
		return
	end

	g_isInit = true

	if AUI.Settings.MainMenu.modul_buffs_account_wide then
		AUI.Settings.Buffs = ZO_SavedVars:NewAccountWide("AUI_Buffs", 0, nil, GetDefaultSettings())
	else
		AUI.Settings.Buffs = ZO_SavedVars:New("AUI_Buffs", 0, nil, GetDefaultSettings())
	end		

	local panelData = 
	{
		type = "panel",
		name = AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("buffs_module_name") .. ")",
		displayName = "|cFFFFB0" .. AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("buffs_module_name")  .. ")",
		author = AUI_TXT_COLOR_AUTHOR:Colorize(AUI_BUFFS_AUTHOR),
		version = AUI_TXT_COLOR_VERSION:Colorize(AUI_BUFFS_VERSION),
		slashCommand = "/auibuffs",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	g_LAM:RegisterOptionControls("AUI_Menu_Buffs", CreateOptions())	
	g_LAM:RegisterAddonPanel("AUI_Menu_Buffs", panelData)
	
end
