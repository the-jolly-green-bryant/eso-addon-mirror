AUI.Settings.Combat = {}

local DEFAULT_SCROLLING_TEXT_DAMAGE_OUT_NORMAL_COLOR = "#36a527"
local DEFAULT_SCROLLING_TEXT_DAMAGE_OUT_CRIT_COLOR = "#a01010"
local DEFAULT_SCROLLING_TEXT_DAMAGE_IN_NORMAL_COLOR = "#36a527"
local DEFAULT_SCROLLING_TEXT_DAMAGE_IN_CRIT_COLOR = "#a01010"
local DEFAULT_SCROLLING_TEXT_HEAL_OUT_NORMAL_COLOR = "#bda72b"
local DEFAULT_SCROLLING_TEXT_HEAL_OUT_CRIT_COLOR = "#b77102"
local DEFAULT_SCROLLING_TEXT_HEAL_IN_NORMAL_COLOR = "#bda72b"
local DEFAULT_SCROLLING_TEXT_HEAL_IN_CRIT_COLOR = "#b77102"
local DEFAULT_SCROLLING_TEXT_EXP_COLOR = "#3697db"
local DEFAULT_SCROLLING_TEXT_CXP_COLOR = "#31bfd9"
local DEFAULT_SCROLLING_TEXT_AP_COLOR = "#14aa34"
local DEFAULT_SCROLLING_TEXT_TELVAR_COLOR = "#6685a5"
local DEFAULT_SCROLLING_TEXT_COMBAT_START_COLOR = "#b80716"
local DEFAULT_SCROLLING_TEXT_COMBAT_END_COLOR = "#0cb82f"
local DEFAULT_SCROLLING_TEXT_INSTANT_CAST_COLOR = "#db7f1d"
local DEFAULT_SCROLLING_TEXT_ULTIMATE_READY_COLOR = "#e7e000"
local DEFAULT_SCROLLING_TEXT_POTION_READY_COLOR = "#08dc55"
local DEFAULT_SCROLLING_TEXT_HEALTH_LOW_COLOR = "#c00000"
local DEFAULT_SCROLLING_TEXT_MAGICKA_LOW_COLOR = "#0235ee"
local DEFAULT_SCROLLING_TEXT_STAMINA_LOW_COLOR = "#2dc000"
local DEFAULT_SCROLLING_TEXT_HEALTH_REG_COLOR = "#c00000"
local DEFAULT_SCROLLING_TEXT_MAGICKA_REG_COLOR = "#0235ee"
local DEFAULT_SCROLLING_TEXT_STAMINA_REG_COLOR = "#2dc000"
local DEFAULT_SCROLLING_TEXT_HEALTH_DEREG_COLOR = "#c00000"
local DEFAULT_SCROLLING_TEXT_MAGICKA_DEREG_COLOR = "#0235ee"
local DEFAULT_SCROLLING_TEXT_STAMINA_DEREG_COLOR = "#2dc000"

local DEFAULT_DAMAGE_METER_FONT_COLOR = "#ffffff"

local g_LAM = LibAddonMenu2
local g_isInit = false
local g_isPreviewShowing = false
local g_changedEnabled = false

local function GetDefaultSettings()
	local defaultSettings =
	{
		lock_windows = false,
	
		--minimeter
		minimeter_position = 
		{
			point = TOPLEFT,
			relativePoint = TOPLEFT,
			offsetX = 0,
			offsetY = 0
		},	
		minimeter_enabled = true,
		minimeter_show_background = true,
		minimeter_show_dps_out = true,
		minimeter_show_total_damage_out = true,
		minimeter_show_hps_out = true,
		minimeter_show_total_heal_out = true,
		minimeter_show_dps_in = false,
		minimeter_show_total_damage_in = false,
		minimeter_show_hps_in = false,
		minimeter_show_total_heal_in = false,		
		minimeter_show_combat_time = true,
		minimeter_show_group_damage_out = true,
		minimeter_show_group_heal_out = true,
		minimeter_font_art = "esoui/common/fonts/univers67.otf",
		minimeter_font_size = 16,
		minimeter_font_style = "thick-outline",
		
		--combat statistics
		detail_statistic_window_position = 
		{
			point = CENTER,
			relativePoint = CENTER,
			offsetX = 0,
			offsetY = 0
		},	
		
		--scrolling text
		scrolling_text_enabled = true,		

		scrolling_text_panel_positions = {},
		scrolling_text_panel_width = {},
		scrolling_text_panel_height = {},	
		scrolling_text_panel_show_icons	= {},		
		scrolling_text_panel_animation	= {},		
		scrolling_text_panel_animation_mode	= {},			
		scrolling_text_panel_duration = {},	
			
		--Damage out
		scrolling_text_show_damage_out = false,	
		scrolling_text_out_damage_normal_size = 34,
		scrolling_text_damage_out_normal_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_damage_out_parent_panelName = "panel1",
		scrolling_text_assemble_damage_in_normal = true,
		scrolling_text_damage_out_color_normal = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_DAMAGE_OUT_NORMAL_COLOR, 1),	

		--Crital Damage out
		scrolling_text_show_critical_damage_out = false,	
		scrolling_text_out_damage_crit_size = 34,
		scrolling_text_damage_out_crit_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_damage_out_crit_parent_panelName = "panel1",
		scrolling_text_assemble_damage_out_crit = true,		
		scrolling_text_damage_out_color_crit = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_DAMAGE_OUT_CRIT_COLOR, 1),
		
		--Heal out
		scrolling_text_show_heal_out = false,
		scrolling_text_out_heal_normal_size = 34,
		scrolling_text_heal_out_normal_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_heal_out_parent_panelName = "panel1",		
		scrolling_text_assemble_heal_out_normal = true,
		scrolling_text_heal_out_color_normal = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_HEAL_OUT_NORMAL_COLOR, 1),			
		
		--Critical Heal out
		scrolling_text_show_critical_heal_out = false,
		scrolling_text_out_heal_crit_size = 34,		
		scrolling_text_heal_out_crit_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_heal_out_crit_parent_panelName = "panel1",
		scrolling_text_assemble_heal_out_crit = true,
		scrolling_text_heal_out_color_crit = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_HEAL_OUT_CRIT_COLOR, 1),				
				
		--Damage in		
		scrolling_text_show_damage_in = false,
		scrolling_text_in_damage_normal_size = 34,	
		scrolling_text_damage_in_normal_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_damage_in_parent_panelName = "panel3",
		scrolling_text_assemble_damage_in_normal = true,
		scrolling_text_damage_in_color_normal = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_DAMAGE_IN_NORMAL_COLOR, 1),
			
		--Crital Damage in
		scrolling_text_show_critical_damage_in = false,			
		scrolling_text_in_damage_crit_size = 34,
		scrolling_text_damage_in_crit_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_damage_in_crit_parent_panelName = "panel3",
		scrolling_text_assemble_damage_in_crit = true,
		scrolling_text_damage_in_color_crit = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_DAMAGE_IN_CRIT_COLOR, 1),			
			
		--Heal in
		scrolling_text_show_heal_in = false,
		scrolling_text_in_heal_normal_size = 34,	
		scrolling_text_heal_in_normal_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_heal_in_parent_panelName = "panel3",
		scrolling_text_assemble_heal_in_normal = true,
		scrolling_text_heal_in_color_normal = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_HEAL_IN_NORMAL_COLOR, 1),	
			
		--Critical Heal in
		scrolling_text_show_critical_heal_in = false,
		scrolling_text_in_heal_crit_size = 34,		
		scrolling_text_heal_in_crit_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_heal_in_crit_parent_panelName = "panel3",
		scrolling_text_assemble_heal_in_crit = true,		
		scrolling_text_heal_in_color_crit = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_HEAL_IN_CRIT_COLOR, 1),
		
		--EXP
		scrolling_text_show_exp = false,
		scrolling_text_exp_size = 24,
		scrolling_text_exp_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_exp_parent_panelName = "panel2",
		scrolling_text_exp_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_EXP_COLOR, 1),		
		
		--CXP
		scrolling_text_show_cxp = true,
		scrolling_text_cxp_size = 24,
		scrolling_text_cxp_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_cxp_parent_panelName = "panel2",
		scrolling_text_cxp_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_CXP_COLOR, 1),
			
		--Tel'Var
		scrolling_text_show_telvar = true,
		scrolling_text_telvar_size = 24,
		scrolling_text_telvar_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_telvar_parent_panelName = "panel2",
		scrolling_text_telvar_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_TELVAR_COLOR, 1),	
		
		--alliance points
		scrolling_text_show_ap = true,
		scrolling_text_ap_size = 24,
		scrolling_text_ap_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_ap_parent_panelName = "panel2",
		scrolling_text_ap_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_AP_COLOR, 1),
		
		--combat start
		scrolling_text_show_combat_start = false,
		scrolling_text_combat_start_size = 34,
		scrolling_text_combat_start_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_combat_start_parent_panelName = "panel2",
		scrolling_text_combat_start_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_COMBAT_START_COLOR, 1),
		
		--combat end
		scrolling_text_show_combat_end = false,
		scrolling_text_combat_end_size = 34,
		scrolling_text_combat_end_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_combat_end_panelName = "panel2",
		scrolling_text_combat_end_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_COMBAT_END_COLOR, 1),
		
		--procs
		scrolling_text_show_instant_casts = true,
		scrolling_text_instant_cast_size = 34,		
		scrolling_text_instant_cast_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_instant_cast_parent_panelName = "panel2",
		scrolling_text_instant_cast_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_INSTANT_CAST_COLOR, 1),
				
		--ultimate
		scrolling_text_show_ultimate_ready = false,
		scrolling_text_ultimate_ready_size = 34,
		scrolling_text_ultimate_ready_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_ultimate_ready_parent_panelName = "panel2",
		scrolling_text_ultimate_ready_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_ULTIMATE_READY_COLOR, 1),		
							
		--potion ready
		scrolling_text_show_potion_ready = false,
		scrolling_text_potion_ready_size = 34,		
		scrolling_text_potion_ready_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_potion_ready_parent_panelName = "panel2",
		scrolling_text_potion_ready_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_POTION_READY_COLOR, 1),		
		
		--health low
		scrolling_text_show_health_low = true,
		scrolling_text_health_low_size = 34,
		scrolling_text_health_low_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_health_low_parent_panelName = "panel2",
		scrolling_text_health_low_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_HEALTH_LOW_COLOR, 1),			
		
		--magicka low
		scrolling_text_show_magicka_low = true,
		scrolling_text_magicka_low_size = 34,
		scrolling_text_magicka_low_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_magicka_low_parent_panelName = "panel2",
		scrolling_text_magicka_low_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_MAGICKA_LOW_COLOR, 1),	
		
		--stamina low
		scrolling_text_show_stamina_low = true,
		scrolling_text_stamina_low_size = 34,
		scrolling_text_stamina_low_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_stamina_low_parent_panelName = "panel2",
		scrolling_text_stamina_low_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_STAMINA_LOW_COLOR, 1),					
		
		--health reg
		scrolling_text_show_health_reg = false,
		scrolling_text_health_reg_size = 24,
		scrolling_text_health_reg_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_health_reg_parent_panelName = "panel1",
		scrolling_text_health_reg_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_HEALTH_REG_COLOR, 1),			
		
		--magicka reg
		scrolling_text_show_magicka_reg = false,
		scrolling_text_magicka_reg_size = 24,
		scrolling_text_magicka_reg_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_magicka_reg_parent_panelName = "panel1",
		scrolling_text_magicka_reg_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_MAGICKA_REG_COLOR, 1),	
		
		--stamina reg
		scrolling_text_show_stamina_reg = false,
		scrolling_text_stamina_reg_size = 24,
		scrolling_text_stamina_reg_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_stamina_reg_parent_panelName = "panel1",
		scrolling_text_stamina_reg_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_STAMINA_REG_COLOR, 1),				

		--health dereg
		scrolling_text_show_health_dereg = false,
		scrolling_text_health_dereg_size = 24,
		scrolling_text_health_dereg_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_health_dereg_parent_panelName = "panel3",
		scrolling_text_health_dereg_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_HEALTH_DEREG_COLOR, 1),			
		
		--magicka dereg
		scrolling_text_show_magicka_dereg = false,
		scrolling_text_magicka_dereg_size = 24,
		scrolling_text_magicka_dereg_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_magicka_dereg_parent_panelName = "panel3",
		scrolling_text_magicka_dereg_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_MAGICKA_DEREG_COLOR, 1),	
		
		--stamina dereg
		scrolling_text_show_stamina_dereg = false,
		scrolling_text_stamina_dereg_size = 24,
		scrolling_text_stamina_dereg_font_art = "esoui/common/fonts/eso_fwntlgudc70-db.slug",
		scrolling_text_stamina_dereg_parent_panelName = "panel3",
		scrolling_text_stamina_dereg_color = AUI.Color.ConvertHexToRGBA(DEFAULT_SCROLLING_TEXT_STAMINA_DEREG_COLOR, 1),						
		
		--weapon charge warner
		weapon_charge_warner_enabled = false,
		weapon_charge_warner_visible_threshold = 6,
		weapon_charge_warner_anchor = 
		{
			point = TOPRIGHT,
			relativePoint = TOPRIGHT,
			offsetX = -550,
			offsetY = 200
		},	
	}	

	for _, panelData in pairs(AUI.Combat.Text.GetPanelList()) do		
		defaultSettings.scrolling_text_panel_positions[panelData.internName] = panelData.anchorData
		defaultSettings.scrolling_text_panel_width[panelData.internName] = panelData.width
		defaultSettings.scrolling_text_panel_height[panelData.internName] = panelData.height
		defaultSettings.scrolling_text_panel_show_icons[panelData.internName] = panelData.showIcons
		defaultSettings.scrolling_text_panel_animation[panelData.internName] = panelData.animationType
		defaultSettings.scrolling_text_panel_animation_mode[panelData.internName] = panelData.animationMode
		defaultSettings.scrolling_text_panel_duration[panelData.internName] = panelData.animationTime		
	end	

	return defaultSettings
end

local function AcceptSettings()
	AUI.Settings.Combat.minimeter_enabled = minimeter_enabled
	AUI.Settings.Combat.scrolling_text_enabled = scrolling_text_enabled
	AUI.Settings.Combat.weapon_charge_warner_enabled = weapon_charge_warner_enabled
	
	ReloadUI()
end

local function GetWeaponChargeWarnerOptions()
	local optionsTable = 
	{	
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("weapon_charge_warner")),
		},
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("general")),
			controls =
			{
				{
					type = "slider",
					name = AUI.L10n.GetString("threshold_visibility_percent"),
					tooltip = AUI.L10n.GetString("threshold_visibility_percent_tooltip"),
					min = 0,
					max = 100,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.weapon_charge_warner_visible_threshold end,
					setFunc = function(value) 
						AUI.Settings.Combat.weapon_charge_warner_visible_threshold = value
						AUI.Combat.WeaponChargeWarner.UpdateAll()
					  end,
					default = GetDefaultSettings().weapon_charge_warner_visible_threshold,
					width = "half",
				},			
				{
					type = "button",
					name = AUI.L10n.GetString("reset_to_default_position"),
					tooltip = AUI.L10n.GetString("reset_to_default_position_tooltip"),
					func = function() AUI.Combat.WeaponChargeWarner.SetToDefaultPosition(GetDefaultSettings()) end,
				},			
			}
		},		
	}
	
	return optionsTable
end

local function GetMinimeterOptions()
	local optionsTable = 
	{	
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("minimeter")),
		},
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("general")),
			controls = 
			{		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_background"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_background end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_background = value
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_background,
					width = "full",
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.minimeter_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.minimeter_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Minimeter.UpdateUI()						
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().minimeter_font_art),	
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 10,
					max = 24,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.minimeter_font_size end,
					setFunc = function(value)
						if value ~= nil then
							AUI.Settings.Combat.minimeter_font_size = value
							AUI.Combat.Minimeter.UpdateUI()	
						end
					end,
					default = GetDefaultSettings().minimeter_font_size,
					width = "full",
				},						
				-- {
					-- type = "dropdown",
					-- name = AUI.L10n.GetString("font_style"),
					-- tooltip = AUI.L10n.GetString("font_style_tooltip"),
					-- choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontStyleList(), "value"),
					-- getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), AUI.Settings.Combat.minimeter_font_style) end,
					-- setFunc = function(value) 
						-- value = AUI.Table.GetKey(AUI.Menu.GetFontStyleList(), value)					
						-- if value ~= nil then
							-- AUI.Settings.Combat.minimeter_font_style = value
							-- AUI.Combat.Minimeter.UpdateUI()	
						-- end	
					-- end,
					-- default = AUI.Table.GetValue(AUI.Menu.GetFontStyleList(), GetDefaultSettings().minimeter_font_style),
				-- },					
				{
					type = "header",
					name = AUI.L10n.GetString("outgoing"),
				},			
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_dps"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_dps_out end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_dps_out = value
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_dps_out,
					width = "full",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_total_damage"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_total_damage_out end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_total_damage_out = value
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_total_damage_out,
					width = "full",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_hps"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_hps_out end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_hps_out = value
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_hps_out,
					width = "full",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_total_heal"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_total_heal_out end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_total_heal_out = value
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_total_heal_out,
					width = "full",
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_group_damage"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_group_damage_out end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_group_damage_out = value
						AUI.Combat.Minimeter.Update()
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_group_damage_out,
					width = "full",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_group_heal"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_group_heal_out end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_group_heal_out = value
						AUI.Combat.Minimeter.Update()
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_group_heal_out,
					width = "full",
				},					
				{
					type = "header",
					name = AUI.L10n.GetString("incoming"),
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_dps"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_dps_in end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_dps_in = value
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_dps_in,
					width = "full",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_total_damage"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_total_damage_in end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_total_damage_in = value
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_total_damage_in,
					width = "full",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_hps"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_hps_in end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_hps_in = value
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_hps_in,
					width = "full",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_total_heal"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_total_heal_in end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_total_heal_in = value
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_total_heal_in,
					width = "full",
				},	
				{
					type = "header",
				},			
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_combat_time"),
					getFunc = function() return AUI.Settings.Combat.minimeter_show_combat_time end,
					setFunc = function(value)
						AUI.Settings.Combat.minimeter_show_combat_time = value
						AUI.Combat.Minimeter.UpdateUI()
					end,
					default = GetDefaultSettings().minimeter_show_combat_time,
					width = "full",
				},					
				{
					type = "button",
					name = AUI.L10n.GetString("reset_to_default_position"),
					tooltip = AUI.L10n.GetString("reset_to_default_position_tooltip"),
					func = function() AUI.Combat.Minimeter.SetToDefaultPosition(GetDefaultSettings()) end,
				},					
			}
		},
	}
	
	return optionsTable
end

local function GetDefaultFightData()
	local data =
	{
		records = {}
	}

	return data
end

local function GetScrollingTextOptions()
	local generalOptions = {}
		
	for panelId, panelData in pairs(AUI.Combat.Text.GetPanelList()) do
			
		table.insert(generalOptions,
			{
				type = "header",
				name = panelData.name,
			})
			
		table.insert(generalOptions,
			{
				type = "slider",
				name = AUI.L10n.GetString("width"),
				tooltip = AUI.L10n.GetString("width_tooltip"),
				min = 200,
				max = 1000,
				step = 1,
				getFunc = function() return AUI.Settings.Combat.scrolling_text_panel_width[panelData.internName] end,
				setFunc = function(value) 
					AUI.Settings.Combat.scrolling_text_panel_width[panelData.internName] = value
					AUI.Combat.Text.UpdateUI()
				  end,
				default = GetDefaultSettings().scrolling_text_panel_width[panelData.internName],
				width = "half",
			})		


		table.insert(generalOptions,
			{
				type = "slider",
				name = AUI.L10n.GetString("height"),
				tooltip = AUI.L10n.GetString("height_tooltip"),
				min = 200,
				max = 1000,
				step = 1,
				getFunc = function() return AUI.Settings.Combat.scrolling_text_panel_height[panelData.internName] end,
				setFunc = function(value) 
					AUI.Settings.Combat.scrolling_text_panel_height[panelData.internName] = value
					AUI.Combat.Text.UpdateUI()
				  end,
				default = GetDefaultSettings().scrolling_text_panel_height[panelData.internName],
				width = "half",
			})		
			
		table.insert(generalOptions,
			{
				type = "checkbox",
				name = AUI.L10n.GetString("show_icons"),
				getFunc = function() return AUI.Settings.Combat.scrolling_text_panel_show_icons[panelData.internName] end,
				setFunc = function(value)
					AUI.Settings.Combat.scrolling_text_panel_show_icons[panelData.internName] = value
					AUI.Combat.Text.UpdatePreview(panelData.internName)
				end,
				default = GetDefaultSettings().scrolling_text_panel_show_icons[panelData.internName],
				width = "full",
			})
			
		table.insert(generalOptions,				
			{
				type = "dropdown",
				name = AUI.L10n.GetString("animation_art"),
				tooltip = AUI.L10n.GetString("animation_art_tooltip"),
				choices = AUI.Table.GetChoiceList(AUI.Menu.GetTextAnimationList(), "value"),
				getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetTextAnimationList(), AUI.Settings.Combat.scrolling_text_panel_animation[panelData.internName]) end,
				setFunc = function(value) 		
					AUI.Settings.Combat.scrolling_text_panel_animation[panelData.internName] = AUI.Table.GetKey(AUI.Menu.GetTextAnimationList(), value)
					AUI.Combat.Text.UpdatePreview(panelData.internName)
				end,
				default = AUI.Table.GetValue(AUI.Menu.GetTextAnimationList(), GetDefaultSettings().scrolling_text_panel_animation[panelData.internName]),		
			})
			
		table.insert(generalOptions,
			{
				type = "dropdown",
				name = AUI.L10n.GetString("animation_mode"),
				tooltip = AUI.L10n.GetString("animation_mode_tooltip"),
				choices = AUI.Table.GetChoiceList(AUI.Menu.GetTextAnimationTypeList(), "value"),
				getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetTextAnimationTypeList(), AUI.Settings.Combat.scrolling_text_panel_animation_mode[panelData.internName]) end,
				setFunc = function(value) 		
					AUI.Settings.Combat.scrolling_text_panel_animation_mode[panelData.internName] = AUI.Table.GetKey(AUI.Menu.GetTextAnimationTypeList(), value)
					AUI.Combat.Text.UpdatePreview(panelData.internName)
				end,
				default = AUI.Table.GetValue(AUI.Menu.GetTextAnimationTypeList(), GetDefaultSettings().scrolling_text_panel_animation_mode[panelData.internName]),				
			})
			
		table.insert(generalOptions,
			{
				type = "slider",
				name = AUI.L10n.GetString("animation_duration"),
				tooltip = AUI.L10n.GetString("animation_duration_tooltip"),
				min = 1,
				max = 5,
				step = 0.0625,
				getFunc = function() return AUI.Settings.Combat.scrolling_text_panel_duration[panelData.internName] end,
				setFunc = function(value) 
					AUI.Settings.Combat.scrolling_text_panel_duration[panelData.internName] = value
					AUI.Combat.Text.UpdatePreview(panelData.internName)
				  end,
				default = GetDefaultSettings().scrolling_text_panel_duration[panelData.internName],
				width = "full",
			})	

		table.insert(generalOptions,				
			{
				type = "button",
				name = AUI.L10n.GetString("reset_to_default_position"),
				tooltip = AUI.L10n.GetString("reset_to_default_position_tooltip"),
				func = function() AUI.Combat.Text.SetPanelToDefaultPosition(GetDefaultSettings(), panelData.internName) end,
			})							
	end			
		
	local optionsTable = 
	{	
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("scrolling_text")),
		},	
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("general")),
			controls = generalOptions,
		},		
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("messages")),
			controls = 
			{
				{
					type = "header",
					name = AUI.L10n.GetString("damage") .. " (" .. AUI.L10n.GetString("outgoing") .. ")",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_damage_out end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_damage_out = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_damage_out,
					width = "full",
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_out_damage_normal_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_out_damage_normal_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_out_damage_normal_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_damage_out_normal_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_damage_out_normal_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_damage_out_normal_font_art),	
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName, 2) end,
					setFunc = function(value) 	
						AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_damage_out_parent_panelName),						
				},					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("assembling_value"),
					tooltip = AUI.L10n.GetString("assembling_value_tooltip"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_assemble_damage_out_normal end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_assemble_damage_out_normal = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_assemble_damage_out_normal,
					width = "full",
				},					
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_damage_out_color_normal):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_damage_out_color_normal = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_damage_out_color_normal,
					width = "full",
				},	
				{
					type = "header",
					name = AUI.L10n.GetString("critical_damage") .. " (" .. AUI.L10n.GetString("outgoing") .. ")",
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_critical_damage_out end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_critical_damage_out = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_critical_damage_out,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_out_damage_crit_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_out_damage_crit_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_out_damage_crit_size,
					width = "full",
				},		
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_damage_out_crit_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_damage_out_crit_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_damage_out_crit_font_art),						
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_damage_out_crit_parent_panelName),	
				},					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("assembling_value"),
					tooltip = AUI.L10n.GetString("assembling_value_tooltip"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_assemble_damage_out_crit end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_assemble_damage_out_crit = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_assemble_damage_out_crit,
					width = "full",
				},					
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_damage_out_color_crit):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_damage_out_color_crit = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_damage_out_color_crit,
					width = "full",
				},	
				{
					type = "header",
					name = AUI.L10n.GetString("healing") .. " (" .. AUI.L10n.GetString("outgoing") .. ")",
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_heal_out end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_heal_out = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_heal_out,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_out_heal_normal_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_out_heal_normal_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_out_heal_normal_size,
					width = "full",
				},		
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_heal_out_normal_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_heal_out_normal_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_heal_out_normal_font_art),						
				},						
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_heal_out_parent_panelName),						
				},					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("assembling_value"),
					tooltip = AUI.L10n.GetString("assembling_value_tooltip"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_assemble_heal_out_normal end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_assemble_heal_out_normal = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_assemble_heal_out_normal,
					width = "full",
				},					
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_heal_out_color_normal):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_heal_out_color_normal = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_heal_out_color_normal,
					width = "full",
				},	
				{
					type = "header",
					name = AUI.L10n.GetString("critical_healing") .. " (" .. AUI.L10n.GetString("outgoing") .. ")",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_critical_heal_out end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_critical_heal_out = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_critical_heal_out,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_out_heal_crit_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_out_heal_crit_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_out_heal_crit_size,
					width = "full",
				},		
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_heal_out_crit_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_heal_out_crit_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_heal_out_crit_font_art),					
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_heal_out_crit_parent_panelName),					
				},					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("assembling_value"),
					tooltip = AUI.L10n.GetString("assembling_value_tooltip"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_assemble_heal_out_crit end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_assemble_heal_out_crit = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_assemble_heal_out_crit,
					width = "full",
				},					
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_heal_out_color_crit):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_heal_out_color_crit = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_heal_out_color_crit,
					width = "full",
				},	
				{
					type = "header",
					name = AUI.L10n.GetString("damage") .. " (" .. AUI.L10n.GetString("incoming") .. ")",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_damage_in end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_damage_in = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_damage_in,
					width = "full",
				},							
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_in_damage_normal_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_in_damage_normal_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_in_damage_normal_size,
					width = "full",
				},		
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_damage_in_normal_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_damage_in_normal_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName)
					end,	
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_damage_in_normal_font_art),		
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_damage_in_parent_panelName),					
				},					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("assembling_value"),
					tooltip = AUI.L10n.GetString("assembling_value_tooltip"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_assemble_damage_in_normal end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_assemble_damage_in_normal = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_assemble_damage_in_normal,
					width = "full",
				},					
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_damage_in_color_normal):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_damage_in_color_normal = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_damage_in_color_normal,
					width = "full",
				},	
				{
					type = "header",
					name = AUI.L10n.GetString("critical_damage") .. " (" .. AUI.L10n.GetString("incoming") .. ")",
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_critical_damage_in end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_critical_damage_in = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_critical_damage_in,
					width = "full",
				},									
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_in_damage_crit_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_in_damage_crit_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_in_damage_crit_size,
					width = "full",
				},		
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_damage_in_crit_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_damage_in_crit_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_damage_in_crit_font_art),					
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_damage_in_crit_parent_panelName),					
				},						
				{
					type = "checkbox",
					name = AUI.L10n.GetString("assembling_value"),
					tooltip = AUI.L10n.GetString("assembling_value_tooltip"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_assemble_damage_in_crit end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_assemble_damage_in_crit = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_assemble_damage_in_crit,
					width = "full",
				},				
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_damage_in_color_crit):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_damage_in_color_crit = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_damage_in_color_crit,
					width = "full",
				},	
				{
					type = "header",
					name = AUI.L10n.GetString("healing") .. " (" .. AUI.L10n.GetString("incoming") .. ")",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_heal_in end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_heal_in = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_heal_in,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_in_heal_normal_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_in_heal_normal_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_in_heal_normal_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_heal_in_normal_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_heal_in_normal_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_heal_in_normal_font_art),
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_heal_in_parent_panelName),					
				},				
				{
					type = "checkbox",
					name = AUI.L10n.GetString("assembling_value"),
					tooltip = AUI.L10n.GetString("assembling_value_tooltip"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_assemble_heal_in_normal end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_assemble_heal_in_normal = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_assemble_heal_in_normal,
					width = "full",
				},				
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_heal_in_color_normal):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_heal_in_color_normal = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_heal_in_color_normal,
					width = "full",
				},	
				{
					type = "header",
					name = AUI.L10n.GetString("critical_healing") .. " (" .. AUI.L10n.GetString("incoming") .. ")",
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_critical_heal_in end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_critical_heal_in = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_critical_heal_in,
					width = "full",
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_in_heal_crit_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_in_heal_crit_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_in_heal_crit_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_heal_in_crit_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_heal_in_crit_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_heal_in_crit_font_art),
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_heal_in_crit_parent_panelName),						
				},					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("assembling_value"),
					tooltip = AUI.L10n.GetString("assembling_value_tooltip"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_assemble_heal_in_crit end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_assemble_heal_in_crit = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_assemble_heal_in_crit,
					width = "full",
				},						
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_heal_in_color_crit):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_heal_in_color_crit = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_heal_in_color_crit,
					width = "full",
				},			
				{
					type = "header",
					name = AUI.L10n.GetString("experience"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_exp end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_exp = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_exp_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_exp,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_exp_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_exp_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_exp_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_exp_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_exp_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_exp_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_exp_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_exp_font_art),
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_exp_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_exp_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_exp_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_exp_parent_panelName),
				},									
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_exp_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_exp_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_exp_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_exp_color,
					width = "full",
				},
				{
					type = "header",
					name = AUI.L10n.GetString("champion_experience"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_cxp end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_cxp = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_cxp_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_cxp,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_cxp_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_cxp_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_cxp_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_cxp_size,
					width = "full",
				},		
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_cxp_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_cxp_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_cxp_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_cxp_font_art),
				},							
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_cxp_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_cxp_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_cxp_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_cxp_parent_panelName),
				},									
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_cxp_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_cxp_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_cxp_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_cxp_color,
					width = "full",
				},				
				{
					type = "header",
					name = AUI.L10n.GetString("telvar"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_telvar end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_telvar = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_telvar_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_telvar,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_telvar_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_telvar_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_telvar_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_telvar_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_telvar_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_telvar_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_telvar_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_telvar_font_art),					
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_telvar_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_telvar_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_telvar_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_telvar_parent_panelName),
				},								
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_telvar_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_telvar_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_telvar_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_telvar_color,
					width = "full",
				},
				{
					type = "header",
					name = AUI.L10n.GetString("alliance_points"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_ap end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_ap = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ap_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_ap,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_ap_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_ap_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ap_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_ap_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_ap_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_ap_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ap_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_ap_font_art),						
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_ap_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_ap_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ap_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_ap_parent_panelName),					
				},										
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_ap_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_ap_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ap_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_ap_color,
					width = "full",
				},				
				{
					type = "header",
					name =AUI.L10n.GetString("combat_start"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_combat_start end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_combat_start = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_start_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_combat_start,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_combat_start_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_combat_start_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_start_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_combat_start_size,
					width = "full",
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_combat_start_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_combat_start_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_start_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_combat_start_font_art),					
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_combat_start_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_combat_start_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_start_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_combat_start_parent_panelName),					
				},					
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_combat_start_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_combat_start_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_start_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_combat_start_color,
					width = "full",
				},				
				{
					type = "header",
					name = AUI.L10n.GetString("combat_end"),
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_combat_end end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_combat_end = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_end_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_combat_end,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_combat_end_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_combat_end_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_end_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_combat_end_size,
					width = "full",
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_combat_end_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_combat_end_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_end_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_combat_end_font_art),							
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_combat_end_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_combat_end_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_end_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_combat_end_panelName),	
				},				
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_combat_end_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_combat_end_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_end_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_combat_end_color,
					width = "full",
				},
				{
					type = "header",
					name = AUI.L10n.GetString("ability_procs"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_instant_casts end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_instant_casts = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_instant_cast_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_instant_casts,
					width = "full",
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_instant_cast_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_instant_cast_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_instant_cast_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_instant_cast_size,
					width = "full",
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_instant_cast_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_instant_cast_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_instant_cast_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_instant_cast_font_art),						
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_instant_cast_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_instant_cast_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_instant_cast_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_instant_cast_parent_panelName),					
				},					
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_instant_cast_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_instant_cast_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_instant_cast_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_instant_cast_color,
					width = "full",
				},	
				{
					type = "header",
					name = AUI.L10n.GetString("ultimate"),
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_ultimate_ready end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_ultimate_ready = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ultimate_ready_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_ultimate_ready,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_ultimate_ready_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_ultimate_ready_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ultimate_ready_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_ultimate_ready_size,
					width = "full",
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_ultimate_ready_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_ultimate_ready_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ultimate_ready_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_ultimate_ready_font_art),					
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_ultimate_ready_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_ultimate_ready_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ultimate_ready_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_ultimate_ready_parent_panelName),					
				},					
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_ultimate_ready_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_ultimate_ready_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ultimate_ready_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_ultimate_ready_color,
					width = "full",
				},					
				{
					type = "header",
					name = AUI.L10n.GetString("potions"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_potion_ready end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_potion_ready = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_potion_ready_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_potion_ready,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_potion_ready_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_potion_ready_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_potion_ready_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_potion_ready_size,
					width = "full",
				},						
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_potion_ready_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_potion_ready_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_potion_ready_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_potion_ready_font_art),			
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_potion_ready_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_potion_ready_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_potion_ready_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_potion_ready_parent_panelName),					
				},					
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_potion_ready_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_potion_ready_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_potion_ready_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_potion_ready_color,
					width = "full",
				},
				{
					type = "header",
					name = AUI.L10n.GetString("health_low"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_health_low end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_health_low = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_low_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_health_low,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_health_low_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_health_low_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_low_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_health_low_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_health_low_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_health_low_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_low_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_health_low_font_art),						
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_health_low_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_low_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_stamina_low_parent_panelName),						
				},									
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_health_low_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_health_low_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_low_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_health_low_color,
					width = "full",
				},					
				{
					type = "header",
					name = AUI.L10n.GetString("magicka_low"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_magicka_low end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_magicka_low = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_low_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_magicka_low,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_magicka_low_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_magicka_low_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_low_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_magicka_low_size,
					width = "full",
				},			
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_magicka_low_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_magicka_low_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_low_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_magicka_low_font_art),					
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_magicka_low_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_low_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_stamina_low_parent_panelName),	
				},								
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_magicka_low_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_magicka_low_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_low_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_magicka_low_color,
					width = "full",
				},					
				{
					type = "header",
					name = AUI.L10n.GetString("stamina_low"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_stamina_low end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_stamina_low = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_stamina_low,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_stamina_low_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_stamina_low_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_stamina_low_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_stamina_low_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_stamina_low_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_stamina_low_font_art),	
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_stamina_low_parent_panelName),					
				},								
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_stamina_low_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_stamina_low_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_stamina_low_color,
					width = "full",
				},				
				{
					type = "header",
					name = AUI.L10n.GetString("health_reg"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_health_reg end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_health_reg = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_reg_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_show_health_reg,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_health_reg_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_health_reg_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_reg_parent_panelName)
					  end,
					default = GetDefaultSettings().scrolling_text_health_reg_size,
					width = "full",
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_health_reg_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_health_reg_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_reg_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_health_reg_font_art),	
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_health_reg_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_health_reg_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_reg_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_health_reg_parent_panelName),	
				},								
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_health_reg_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_health_reg_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_reg_parent_panelName)
					end,
					default = GetDefaultSettings().scrolling_text_health_reg_color,
					width = "full",
				},						
				{
					type = "header",
					name = AUI.L10n.GetString("magicka_reg"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_magicka_reg end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_magicka_reg = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_reg_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_magicka_reg,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_magicka_reg_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_magicka_reg_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_reg_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_magicka_reg_size,
					width = "full",
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_magicka_reg_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_magicka_reg_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_reg_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_magicka_reg_font_art),
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_magicka_reg_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_magicka_reg_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_reg_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_magicka_reg_parent_panelName),
				},								
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_magicka_reg_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_magicka_reg_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_reg_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_magicka_reg_color,
					width = "full",
				},		
				{
					type = "header",
					name = AUI.L10n.GetString("stamina_reg"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_stamina_reg end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_stamina_reg = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_reg_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_stamina_reg,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_stamina_reg_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_stamina_reg_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_reg_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_stamina_reg_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_stamina_reg_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_stamina_reg_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_reg_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_stamina_reg_font_art),					
				},					
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_stamina_reg_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_stamina_reg_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_reg_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_stamina_reg_parent_panelName),
				},									
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_stamina_reg_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_stamina_reg_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_reg_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_stamina_reg_color,
					width = "full",
				},	
				{
					type = "header",
					name = AUI.L10n.GetString("health_dereg"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_health_dereg end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_health_dereg = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_dereg_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_health_dereg,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_health_dereg_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_health_dereg_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_dereg_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_health_dereg_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_health_dereg_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_health_dereg_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_dereg_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_health_dereg_font_art),						
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_health_dereg_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_health_dereg_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_dereg_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_health_dereg_parent_panelName),					
				},								
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_health_dereg_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_health_dereg_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_dereg_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_health_dereg_color,
					width = "full",
				},						
				{
					type = "header",
					name = AUI.L10n.GetString("mana_dereg"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_magicka_dereg end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_magicka_dereg = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_dereg_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_magicka_dereg,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_magicka_dereg_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_magicka_dereg_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_dereg_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_magicka_dereg_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_magicka_dereg_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_magicka_dereg_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_dereg_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_magicka_dereg_font_art),					
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_magicka_dereg_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_magicka_dereg_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_dereg_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_magicka_dereg_parent_panelName),					
				},								
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_magicka_dereg_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_magicka_dereg_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_dereg_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_magicka_dereg_color,
					width = "full",
				},		
				{
					type = "header",
					name = AUI.L10n.GetString("stamina_dereg"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					getFunc = function() return AUI.Settings.Combat.scrolling_text_show_stamina_dereg end,
					setFunc = function(value)
						AUI.Settings.Combat.scrolling_text_show_stamina_dereg = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_dereg_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_show_stamina_dereg,
					width = "full",
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("size"),
					tooltip = AUI.L10n.GetString("size_tooltip"),
					min = 18,
					max = 40,
					step = 1,
					getFunc = function() return AUI.Settings.Combat.scrolling_text_stamina_dereg_size end,
					setFunc = function(value) 
						AUI.Settings.Combat.scrolling_text_stamina_dereg_size = value
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_dereg_parent_panelName)	
					  end,
					default = GetDefaultSettings().scrolling_text_stamina_dereg_size,
					width = "full",
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetFontTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), AUI.Settings.Combat.scrolling_text_stamina_dereg_font_art) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_stamina_dereg_font_art = AUI.Table.GetKey(AUI.Menu.GetFontTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_dereg_parent_panelName)
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetFontTypeList(), GetDefaultSettings().scrolling_text_stamina_dereg_font_art),					
				},				
				{
					type = "dropdown",
					name = AUI.L10n.GetString("panel"),
					tooltip = AUI.L10n.GetString("panel_tooltip"),
					choices = AUI.Table.GetChoiceList(AUI.Menu.GetSCTPanelTypeList(), "value"),
					getFunc = function() return AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), AUI.Settings.Combat.scrolling_text_stamina_dereg_parent_panelName, 2) end,
					setFunc = function(value) 		
						AUI.Settings.Combat.scrolling_text_stamina_dereg_parent_panelName = AUI.Table.GetKey(AUI.Menu.GetSCTPanelTypeList(), value)
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_dereg_parent_panelName)	
					end,
					default = AUI.Table.GetValue(AUI.Menu.GetSCTPanelTypeList(), GetDefaultSettings().scrolling_text_stamina_dereg_parent_panelName),						
				},								
				{
					type = "colorpicker",
					name = AUI.L10n.GetString("color"),
					getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Combat.scrolling_text_stamina_dereg_color):UnpackRGBA() end,
					setFunc = function(r,g,b,a) 
						AUI.Settings.Combat.scrolling_text_stamina_dereg_color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}	
						AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_dereg_parent_panelName)	
					end,
					default = GetDefaultSettings().scrolling_text_stamina_dereg_color,
					width = "full",
				},						
			}
		},	
	}
	return optionsTable
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
			getFunc = function() return AUI.Settings.MainMenu.modul_combat_account_wide end,
			setFunc = function(value)				
				if value ~= AUI.Settings.MainMenu.modul_combat_account_wide then
					AUI.Settings.MainMenu.modul_combat_account_wide = value
					ReloadUI()
				else
					AUI.Settings.MainMenu.modul_combat_account_wide = value
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
			getFunc = function() return AUI.Settings.Combat.lock_windows end,
			setFunc = function(value)
				AUI.Settings.Combat.lock_windows = value
			end,
			default = GetDefaultSettings().lock_windows,
			width = "full",
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("preview"),
			tooltip = AUI.L10n.GetString("preview_tooltip"),
			getFunc = function() return g_isPreviewShowing end,
			setFunc = function(value)
						if value then
							AUI.Combat.Minimeter.ShowPreview()
							AUI.Combat.Text.ShowPreview()
							AUI.Combat.WeaponChargeWarner.ShowPreview()
						else
							AUI.Combat.Minimeter.HidePreview()
							AUI.Combat.Text.HidePreview()
							AUI.Combat.WeaponChargeWarner.HidePreview()
						end
						g_isPreviewShowing = value
			end,
			default = g_isPreviewShowing,
			width = "full",
			warning = AUI.L10n.GetString("preview_warning"),	
		},		
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("display_elements")),
			controls = 
			{	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("minimeter"),
					getFunc = function() return minimeter_enabled end,
					setFunc = function(value)
						minimeter_enabled = value
						g_changedEnabled = true
					end,
					default = GetDefaultSettings().minimeter_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),			
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("scrolling_text"),
					getFunc = function() return scrolling_text_enabled end,
					setFunc = function(value)
						scrolling_text_enabled = value
						g_changedEnabled = true
					end,
					default = GetDefaultSettings().scrolling_text_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),		
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("weapon_charge_warner"),
					getFunc = function() return weapon_charge_warner_enabled end,
					setFunc = function(value)
						weapon_charge_warner_enabled = value
						g_changedEnabled = true
					end,
					default = GetDefaultSettings().weapon_charge_warner_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),		
				},									
				{
					type = "button",
					name = AUI.L10n.GetString("accept_settings"),
					func = function() AcceptSettings() end,
					disabled = function() return not g_changedEnabled end,
				},			
			}
		},		
	}	
	
	if minimeter_enabled then
		local minimeterOptions = GetMinimeterOptions()
		for i = 1 , #minimeterOptions do 
			table.insert(optionsTable, minimeterOptions[i]) 
		end		
	end		
	
	if scrolling_text_enabled then
		local scrollingTextOptions = GetScrollingTextOptions()
		for i = 1 , #scrollingTextOptions do 
			table.insert(optionsTable, scrollingTextOptions[i]) 
		end		
	end	

	if weapon_charge_warner_enabled then
		local weaponChargeWarnerOptions = GetWeaponChargeWarnerOptions()
		for i = 1 , #weaponChargeWarnerOptions do 
			table.insert(optionsTable, weaponChargeWarnerOptions[i]) 
		end		
	end
	
	return optionsTable
end

function AUI.Combat.LoadSettings()
	if g_isInit then
		return
	end
	
	g_isInit = true
	
	if AUI.Settings.MainMenu.modul_combat_account_wide then
		AUI.Settings.Combat = ZO_SavedVars:NewAccountWide("AUI_Combat", 10, nil, GetDefaultSettings())
	else
		AUI.Settings.Combat = ZO_SavedVars:New("AUI_Combat", 10, nil, GetDefaultSettings())
	end		
	
	minimeter_enabled = AUI.Settings.Combat.minimeter_enabled
	scrolling_text_enabled = AUI.Settings.Combat.scrolling_text_enabled
	weapon_charge_warner_enabled = AUI.Settings.Combat.weapon_charge_warner_enabled
	
	local panelData = 
	{
		type = "panel",
		name = AUI_MAIN_NAME .. " (" ..  AUI.L10n.GetString("combat_module_name") .. ")",
		displayName = "|cFFFFB0" .. AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("combat_module_name") .. ")",
		author = AUI_TXT_COLOR_AUTHOR:Colorize(AUI_COMBAT_AUTHOR),
		version = AUI_TXT_COLOR_VERSION:Colorize(AUI_COMBAT_VERSION),
		slashCommand = "/auicombat",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	g_LAM:RegisterOptionControls("AUI_Menu_Combat", CreateOptions())	
	g_LAM:RegisterAddonPanel("AUI_Menu_Combat", panelData)
end
