AUI.Settings.Buffs = {}

local isLoaded = false
local isPreviewShowing = false

local LAM = LibStub("LibAddonMenu-2.0")
local LMP = LibStub("LibMediaProvider-1.0")

local function GetDefaultSettings()
	local defaultSettings =
	{
		--general
		lock_window = false,			

    show_buff_names = false,

		--player buffs
		
		player_buff_position = 
		{
			point = BOTTOM,
			relativePoint = BOTTOM,
			offsetX = -180,
			offsetY = -210,
		},		
		
		player_show_buff_time = true,
		player_buff_font_art = "Univers 55",
		player_buff_font_size = 11,
			
		player_buff_size = 38,
		player_buff_distance = 10,

		player_show_permanent_buffs = false,
		player_show_time_limit_buffs = true,
		player_buff_sorting = AUI_SORTING_LARGE_TO_SMALL,
		player_buff_alignment = AUI_HORIZONTAL,
	
		--player debuffs
		
		player_debuff_position = 
		{
			point = BOTTOM,
			relativePoint = BOTTOM,
			offsetX = -180,
			offsetY = -94,
		},			
		
		player_show_debuff_time = true,
		player_debuff_font_art = "Univers 55",
		player_debuff_font_size = 11,		
		
		player_show_debuffs = true,			
		player_debuff_size = 38,
		player_debuff_distance = 10,		
		player_debuff_sorting = AUI_SORTING_LARGE_TO_SMALL,
		player_debuff_alignment = AUI_HORIZONTAL,
		
		--target buffs
		
		target_buff_position = 
		{
			point = TOP,
			relativePoint = TOP,
			offsetX = -146,
			offsetY = 79,
		},

		target_show_buff_time = true,
		target_buff_font_art = "Univers 55",
		target_buff_font_size = 11,	
	
		target_buff_size = 34,
		target_buff_distance = 10,
		target_show_permanent_buffs = false,
		target_show_time_limit_buffs = true,
		target_buff_sorting = AUI_SORTING_LARGE_TO_SMALL,
		target_buff_alignment = AUI_HORIZONTAL,	

		--target debuffs
			
		target_debuff_position = 
		{
			point = TOP,
			relativePoint = TOP,
			offsetX = -146,
			offsetY = 232,
		},

		target_show_debuff_time = true,
		target_debuff_font_art = "Univers 55",
		target_debuff_font_size = 11,			
		
		target_show_debuffs = true,	
		target_debuff_size = 34,
		target_debuff_distance = 10,
		target_debuff_sorting = AUI_SORTING_LARGE_TO_SMALL,	
		target_debuff_alignment = AUI_HORIZONTAL,				
	}

	return defaultSettings
end

local function GetCurrentTemplateName()
	local templateData = AUI.Buffs.GetCurrentTemplateData()
	return templateData.internName
end

local function CreateOptionTable()
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
			getFunc = function() return AUI.MainSettings.modul_buffs_account_wide end,
			setFunc = function(value)
				AUI.MainSettings.modul_buffs_account_wide = value
				ReloadUI()
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
				AUI.Settings.Buffs.lock_window = value
			end,
			default = GetDefaultSettings().lock_window,
			width = "full",
		},			
		{
			type = "checkbox",
			name = AUI.L10n.GetString("preview"),
			tooltip = AUI.L10n.GetString("preview_tooltip"),
			getFunc = function() return isPreviewShowing end,
			setFunc = function(value)
				AUI.Buffs.ShowPreview(value)	
				isPreviewShowing = value					
			end,
			default = isPreviewShowing,
			width = "full",
			warning = AUI.L10n.GetString("preview_warning"),	
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("template"),
			tooltip = AUI.L10n.GetString("template_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Buffs.GetTemplateNames(), "value"),
			getFunc = function() return AUI.Table.GetValue(AUI.Buffs.GetTemplateNames(), GetCurrentTemplateName()) end,
			setFunc = function(value) 
				value = AUI.Table.GetKey(AUI.Buffs.GetTemplateNames(), value)
				if GetCurrentTemplateName() ~= value then
					AUI.Settings.Template.Buffs = value
					ReloadUI()
				end
			end,
			warning = AUI.L10n.GetString("reloadui_warning_tooltip"),
		},
		{
		  type = "checkbox",
		  name = AUI.L10n.GetString("show_buff_names"),
		  tooltip = AUI.L10n.GetString("show_buff_names_tooltip"),
		  getFunc = function() return AUI.Settings.Buffs.show_buff_names end,
		  setFunc = function(value)
		    AUI.Settings.Buffs.show_buff_names = value
		    AUI.Buffs.RefreshAll()

		    if value then
		      if (AUI.Settings.Buffs.player_buff_distance + 10) < 24 then
		        AUI.Settings.Buffs.player_buff_distance = AUI.Settings.Buffs.player_buff_distance + 10
		      end
		      if (AUI.Settings.Buffs.player_debuff_distance + 10) < 24 then
		        AUI.Settings.Buffs.player_debuff_distance = AUI.Settings.Buffs.player_debuff_distance + 10
		      end
		    end
		  end,
		  default = GetDefaultSettings().show_buff_names,
		  width = "full",
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
						AUI.Settings.Buffs.player_show_permanent_buffs = value
						AUI.Buffs.RefreshAll()	
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
						AUI.Settings.Buffs.player_show_time_limit_buffs = value
						AUI.Buffs.RefreshAll()	
					end,
					default = GetDefaultSettings().player_show_time_limit_buffs,
					width = "full",
				},					
				{
					type = "slider",
					name =  AUI.L10n.GetString("size"),
					tooltip =  AUI.L10n.GetString("size_tooltip"),
					min = 24,
					max = 48,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.player_buff_size end,
					setFunc = function(value) 
						AUI.Settings.Buffs.player_buff_size = value
						AUI.Buffs.RefreshAll()
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
						AUI.Settings.Buffs.player_buff_distance = value
						AUI.Buffs.RefreshAll()						
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
						AUI.Settings.Buffs.player_buff_alignment = AUI.Table.GetKey(AUI.Menu.GetAlignmentList(), value)
						AUI.Buffs.RefreshAll()
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
						AUI.Settings.Buffs.player_buff_sorting = AUI.Table.GetKey(AUI.Menu.GetSortingList(), value)
						AUI.Buffs.RefreshAll()
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSortingList(), GetDefaultSettings().player_buff_sorting),			
				},
				{
					type = "checkbox",
					name =  AUI.L10n.GetString("show_buff_remain_time"),
					tooltip = AUI.L10n.GetString("show_buff_remain_time_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.player_show_buff_time end,
					setFunc = function(value)
						AUI.Settings.Buffs.player_show_buff_time = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().player_show_buff_time,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Buffs.player_buff_font_art end,
					setFunc = function(value) 		
						AUI.Settings.Buffs.player_buff_font_art  = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().player_buff_font_art,		
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4 ,
					max = 22 ,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.player_buff_font_size end,
					setFunc = function(value) 
						AUI.Settings.Buffs.player_buff_font_size = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().player_buff_font_size,
					width = "full",
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
						AUI.Settings.Buffs.player_show_debuffs = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().player_show_debuffs,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 24,
					max = 48,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.player_debuff_size end,
					setFunc = function(value) 
						AUI.Settings.Buffs.player_debuff_size = value
						AUI.Buffs.RefreshAll()
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
						AUI.Settings.Buffs.player_debuff_distance = value
						AUI.Buffs.RefreshAll()						
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
						AUI.Settings.Buffs.player_debuff_alignment = AUI.Table.GetKey(AUI.Menu.GetAlignmentList(), value)
						AUI.Buffs.RefreshAll()
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
						AUI.Settings.Buffs.player_debuff_sorting = AUI.Table.GetKey(AUI.Menu.GetSortingList(), value)
						AUI.Buffs.RefreshAll()
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSortingList(), GetDefaultSettings().player_debuff_sorting),			
				},	
				{
					type = "checkbox",
					name =  AUI.L10n.GetString("show_buff_remain_time"),
					tooltip = AUI.L10n.GetString("show_buff_remain_time_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.player_show_debuff_time end,
					setFunc = function(value)
						AUI.Settings.Buffs.player_show_debuff_time = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().player_show_debuff_time,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Buffs.player_debuff_font_art end,
					setFunc = function(value) 		
						AUI.Settings.Buffs.player_debuff_font_art  = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().player_debuff_font_art,		
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4 ,
					max = 22 ,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.player_buff_font_size end,
					setFunc = function(value) 
						AUI.Settings.Buffs.player_buff_font_size = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().player_buff_font_size,
					width = "full",
				},										
				{
					type = "header",
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
						AUI.Settings.Buffs.target_show_permanent_buffs = value
						AUI.Buffs.RefreshAll()
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
						AUI.Settings.Buffs.target_show_time_limit_buffs = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().target_show_time_limit_buffs,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 24,
					max = 48,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.target_buff_size end,
					setFunc = function(value) 
						AUI.Settings.Buffs.target_buff_size = value
						AUI.Buffs.RefreshAll()
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
						AUI.Settings.Buffs.target_buff_distance = value
						AUI.Buffs.RefreshAll()						
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
						AUI.Settings.Buffs.target_buff_alignment = AUI.Table.GetKey(AUI.Menu.GetAlignmentList(), value)
						AUI.Buffs.RefreshAll()
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
						AUI.Settings.Buffs.target_buff_sorting = AUI.Table.GetKey(AUI.Menu.GetSortingList(), value)
						AUI.Buffs.RefreshAll()
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSortingList(), GetDefaultSettings().target_buff_sorting),			
				},	
				{
					type = "checkbox",
					name =  AUI.L10n.GetString("show_buff_remain_time"),
					tooltip = AUI.L10n.GetString("show_buff_remain_time_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.target_show_buff_time end,
					setFunc = function(value)
						AUI.Settings.Buffs.target_show_buff_time = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().target_show_buff_time,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Buffs.target_buff_font_art end,
					setFunc = function(value) 		
						AUI.Settings.Buffs.target_buff_font_art  = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().target_buff_font_art,		
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4 ,
					max = 22 ,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.target_buff_font_size end,
					setFunc = function(value) 
						AUI.Settings.Buffs.target_buff_font_size = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().target_buff_font_size,
					width = "full",
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
						AUI.Settings.Buffs.target_show_debuffs = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().target_show_debuffs,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 24,
					max = 48,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.target_debuff_size end,
					setFunc = function(value) 
						AUI.Settings.Buffs.target_debuff_size = value
						AUI.Buffs.RefreshAll()
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
						AUI.Settings.Buffs.target_debuff_distance = value
						AUI.Buffs.RefreshAll()						
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
						AUI.Settings.Buffs.target_debuff_alignment = AUI.Table.GetKey(AUI.Menu.GetAlignmentList(), value)
						AUI.Buffs.RefreshAll()
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
						AUI.Settings.Buffs.target_debuff_sorting = AUI.Table.GetKey(AUI.Menu.GetSortingList(), value)
						AUI.Buffs.RefreshAll()
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSortingList(), GetDefaultSettings().target_debuff_sorting),			
				},	
				{
					type = "checkbox",
					name =  AUI.L10n.GetString("show_buff_remain_time"),
					tooltip = AUI.L10n.GetString("show_buff_remain_time_tooltip"),
					getFunc = function() return AUI.Settings.Buffs.target_show_debuff_time end,
					setFunc = function(value)
						AUI.Settings.Buffs.target_show_debuff_time = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().target_show_debuff_time,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Buffs.target_debuff_font_art end,
					setFunc = function(value) 		
						AUI.Settings.Buffs.target_debuff_font_art  = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().target_debuff_font_art,		
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4 ,
					max = 22 ,
					step = 1,
					getFunc = function() return AUI.Settings.Buffs.target_debuff_font_size end,
					setFunc = function(value) 
						AUI.Settings.Buffs.target_debuff_font_size = value
						AUI.Buffs.RefreshAll()
					end,
					default = GetDefaultSettings().target_debuff_font_size,
					width = "full",
				},									
			}
		},
		{
			type = "header",
		},				
		{
			type = "button",
			name = AUI.L10n.GetString("reset_to_default_position"),
			tooltip = AUI.L10n.GetString("reset_to_default_position_tooltip"),
			func = function() AUI.Buffs.SetToDefaultPosition(GetDefaultSettings()) end,
		},			
	}

	LAM:RegisterOptionControls("AUI_Menu_Buffs", optionsTable)
end

local function LoadSettings()
	if AUI.MainSettings.modul_buffs_account_wide then
		AUI.Settings.Buffs = ZO_SavedVars:NewAccountWide("AUI_Buffs", 2, nil, GetDefaultSettings())
	else
		AUI.Settings.Buffs = ZO_SavedVars:New("AUI_Buffs", 2, nil, GetDefaultSettings())
	end		
end

function AUI.Buffs.SetMenuData()
	if isLoaded then
		return
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
	
	LoadSettings()
	CreateOptionTable()
	
	LAM:RegisterAddonPanel("AUI_Menu_Buffs", panelData)
	
	isLoaded = true
end
