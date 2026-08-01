-------------------------------------
--- RoleCrowns by TheWizardLizard ---
--- Settings - February, 2020 -------
-------------------------------------

function RoleCrowns:CreateRCSettingsMenu()
	local RCM = LibStub("LibAddonMenu-2.0")
	local data_panel = {
        type = "panel",
        name = "Role Crowns",
		displayName = ZO_HIGHLIGHT_TEXT:Colorize("Role Crowns"),
		author = "TheWizardLizard",
		version = "1.0.1",
		registerForRefresh  = true,
		registerForDefaults = true,
		slashCommand = "/rcs",
		website = "https://www.esoui.com/downloads/fileinfo.php?id=2539",
	}
	
	-- Add metadata and title to the addon menu
	RCM:RegisterAddonPanel("RCOptions", data_panel)
	
	local settings_panel = {}
	
	-- Note about dungeons and trials
	table.insert(settings_panel, {
		type = "description",
		title = nil,
		text = "Note: Role Crowns cannot be drawn during trials or dungeons. This is not a bug but a restriction imposed by ZOS. Sorry for any inconvenience.",
		width = "full",
	})
	
	-- General Settings
	table.insert(settings_panel, {
		type = "header",
		name = ZO_HIGHLIGHT_TEXT:Colorize("General Settings"),
	})
		-- Show DPS crowns
		table.insert(settings_panel, {
			type = "checkbox",
			name = "Show DPS Crowns",
			tooltip = "Toggles crowns for group members with their role set to DPS",
			default = RoleCrowns.default_settings.show_dps_crowns,
			getFunc = function() return RoleCrowns.settings.show_dps_crowns end,
			setFunc = function(bool) 
				RoleCrowns.settings.show_dps_crowns = bool 
				UpdateCrownUI()
			end,
		})
		-- Show Healer crowns
		table.insert(settings_panel, {
			type = "checkbox",
			name = "Show Healer Crowns",
			tooltip = "Toggles crowns for group members with their role set to Healer",
			default = RoleCrowns.default_settings.show_healer_crowns,
			getFunc = function() return RoleCrowns.settings.show_healer_crowns end,
			setFunc = function(bool) 
				RoleCrowns.settings.show_healer_crowns = bool
				UpdateCrownUI()				
			end,
		})
		-- Show Tank crowns
		table.insert(settings_panel, {
			type = "checkbox",
			name = "Show Tank Crowns",
			tooltip = "Toggles crowns for group members with their role set to Tank",
			default = RoleCrowns.default_settings.show_tank_crowns,
			getFunc = function() return RoleCrowns.settings.show_tank_crowns end,
			setFunc = function(bool) 
				RoleCrowns.settings.show_tank_crowns = bool 
				UpdateCrownUI()
			end,
		})
		-- Show No Role crowns
		table.insert(settings_panel, {
			type = "checkbox",
			name = "Show Battlegrounds Crowns",
			tooltip = "Toggles crowns for group members with their role hidden (roles are hidden during Battlegrounds)",
			default = RoleCrowns.default_settings.show_no_role_crowns,
			getFunc = function() return RoleCrowns.settings.show_no_role_crowns end,
			setFunc = function(bool) 
				RoleCrowns.settings.show_no_role_crowns = bool 
				UpdateCrownUI()
			end,
		})
		-- Show Player crown
		table.insert(settings_panel, {
			type = "checkbox",
			name = "Show Player Crown",
			tooltip = "Toggles showing a crown for yourself",
			default = RoleCrowns.default_settings.show_player_crown,
			getFunc = function() return RoleCrowns.settings.show_player_crown end,
			setFunc = function(bool) 
				RoleCrowns.settings.show_player_crown = bool
				UpdateCrownUI()
			end,
		})		
		-- Pulse crowns
		table.insert(settings_panel, {
			type = "checkbox",
			name = "Pulse Animation",
			tooltip = "Adds an animation where crowns fade in and out (Note: Overrides the icon's transparency settings)",
			default = RoleCrowns.default_settings.pulse_crowns,
			getFunc = function() return RoleCrowns.settings.pulse_crowns end,
			setFunc = function(bool) 
				RoleCrowns.settings.pulse_crowns = bool 
				UpdateCrownUI()
			end,
		})
		
	-- Size & Positioning Settings
	table.insert(settings_panel, {
		type = "header",
		name = ZO_HIGHLIGHT_TEXT:Colorize("Size & Positioning"),
	})
		-- Crown size
		table.insert(settings_panel, {
			type = "slider",
			name =  "Crown Size",
			tooltip = "Sets the size of the crowns",
			min = 1,
			max = 50,
			step = 1,	--(optional)
			getFunc = function() return RoleCrowns.settings.crown_size end,
			setFunc = function(value)
				RoleCrowns.settings.crown_size = value
				UpdateCrownUI()
			end,
			default = RoleCrowns.default_settings.crown_size,
		})
		-- Crown offset
		table.insert(settings_panel, {
			type = "slider",
			name =  "Crown Y Offset",
			tooltip = "Raises or lowers the crowns",
			min = 1,
			max = 50,
			step = 1,	--(optional)
			getFunc = function() return RoleCrowns.settings.crown_y_offset end,
			setFunc = function(value)
				RoleCrowns.settings.crown_y_offset = value
			end,
			default = RoleCrowns.default_settings.crown_y_offset,
		})
	
	-- Theme Settings
	table.insert(settings_panel, {
		type = "header",
		name = ZO_HIGHLIGHT_TEXT:Colorize("Theme"),
	})
		-- Change DPS crown color.
		table.insert(settings_panel, {
			type = "colorpicker",
			name = "DPS Crown Color",
			tooltip = "Sets crown color for DPS group members",
			getFunc = function() return unpack(RoleCrowns.settings.dps_color) end,
			setFunc = function(r, g, b, a)
				RoleCrowns.settings.dps_color = {r, g, b, a}
				UpdateCrownUI()
			end,
			default = { r = RoleCrowns.default_settings.dps_color[1], g = RoleCrowns.default_settings.dps_color[2], 
			            b = RoleCrowns.default_settings.dps_color[3], a = RoleCrowns.default_settings.dps_color[4]},
		})
		-- Change DPS texture.
		table.insert(settings_panel, {
			type = "dropdown",
			name = "DPS Crown Icon",
			tooltip = "Change the texture of the DPS crown",
			choices = ICON_CHOICES,
			choicesValues = DPS_ICONS,
			getFunc = function() return RoleCrowns.settings.dps_icon end,
			setFunc = function(value)
				RoleCrowns.settings.dps_icon = value
				UpdateCrownUI()
			end,
			default = RoleCrowns.default_settings.dps_icon,
		})
		-- Change Healer crown color.
		table.insert(settings_panel, {
			type = "colorpicker",
			name = "Healer Crown Color",
			tooltip = "Sets crown color for Healer group members",
			getFunc = function() return unpack(RoleCrowns.settings.healer_color) end,
			setFunc = function(r, g, b, a)
				RoleCrowns.settings.healer_color = {r, g, b, a}
				UpdateCrownUI()
			end,
			default = { r = RoleCrowns.default_settings.healer_color[1], g = RoleCrowns.default_settings.healer_color[2], 
			            b = RoleCrowns.default_settings.healer_color[3], a = RoleCrowns.default_settings.healer_color[4]},
		})	
		-- Change Healer texture.
		table.insert(settings_panel, {
			type = "dropdown",
			name = "Healer Crown Icon",
			tooltip = "Change the texture of the Healer crown",
			choices = ICON_CHOICES,
			choicesValues = HEALER_ICONS,
			getFunc = function() return RoleCrowns.settings.healer_icon end,
			setFunc = function(value)
				RoleCrowns.settings.healer_icon = value
				UpdateCrownUI()
			end,
			default = RoleCrowns.default_settings.healer_icon,
		})			
		-- Change Tank crown color.
		table.insert(settings_panel, {
			type = "colorpicker",
			name = "Tank Crown Color",
			tooltip = "Sets crown color for Tank group members",
			getFunc = function() return unpack(RoleCrowns.settings.tank_color) end,
			setFunc = function(r, g, b, a)
				RoleCrowns.settings.tank_color = {r, g, b, a}
				UpdateCrownUI()
			end,
			default = { r = RoleCrowns.default_settings.tank_color[1], g = RoleCrowns.default_settings.tank_color[2],
               			b = RoleCrowns.default_settings.tank_color[3], a = RoleCrowns.default_settings.tank_color[4]},
		})
		-- Change Tank texture.
		table.insert(settings_panel, {
			type = "dropdown",
			name = "Tank Crown Icon",
			tooltip = "Change the texture of the Tank crown",
			choices = ICON_CHOICES,
			choicesValues = TANK_ICONS,
			getFunc = function() return RoleCrowns.settings.tank_icon end,
			setFunc = function(value)
				RoleCrowns.settings.tank_icon = value
				UpdateCrownUI()
			end,
			default = RoleCrowns.default_settings.tank_icon,
		})	
		-- Change No Role crown color.
		table.insert(settings_panel, {
			type = "colorpicker",
			name = "Battlegrounds Crown Color",
			tooltip = "Sets crown color for group members with their role hidden (roles are hidden during Battlegrounds)",
			getFunc = function() return unpack(RoleCrowns.settings.no_role_color) end,
			setFunc = function(r, g, b, a)
				RoleCrowns.settings.no_role_color = {r, g, b, a}
				UpdateCrownUI()
			end,
			default = { r = RoleCrowns.default_settings.no_role_color[1], g = RoleCrowns.default_settings.no_role_color[2], 
			            b = RoleCrowns.default_settings.no_role_color[3], a = RoleCrowns.default_settings.no_role_color[4]},
		})	
		-- Change No Role texture.
		table.insert(settings_panel, {
			type = "dropdown",
			name = "Battlegrounds Crown Icon",
			tooltip = "Change the texture of the Battlegrounds group member crown",
			choices = ICON_CHOICES,
			choicesValues = NO_ROLE_ICONS,
			getFunc = function() return RoleCrowns.settings.no_role_icon end,
			setFunc = function(value)
				RoleCrowns.settings.no_role_icon = value
				UpdateCrownUI()
			end,
			default = RoleCrowns.default_settings.no_role_icon,
		})
		
	-- Add controls and settings to the addon menu
	RCM:RegisterOptionControls("RCOptions", settings_panel)
end
