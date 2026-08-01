CurrentlyEquipped = CurrentlyEquipped or {}
local CE = CurrentlyEquipped

function CE.AddonMenu()

    local menuOptions = {
        type = "panel",
        name = CE.name,
        displayName = CE_DISPLAY_NAME,
        author = CE.author,
        version = CE.version,
        slashCommand = "/ce",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local dataTable = {
        {
            type = "description",
            text = CE_MENU_DESCRIPTION
        },
        {
            type = "header",
            name = CE_MENU_OPTIONS_HEADER,
            width = "full",
        },
        {
			type    = "checkbox",
			name    = CE_MENU_UNLOCK_UI,
			tooltip = CE_MENU_UNLOCK_UI_TIP,
			default = false,
			getFunc = function() return not CE.lockedUI end,
			setFunc = function(newVal) CE.MoveUI() CE.lockedUI = not newVal; end,
		},
        {
			type    = "checkbox",
			name    = CE_MENU_SHOW_IN_TRIAL_ARENA,
			tooltip = CE_MENU_SHOW_IN_TRIAL_ARENA_TIP,
			getFunc = function() return CE.show_in_zone end,
			setFunc = function(newVal) CE.SaveShowInZone(newVal) CE.show_in_zone = newVal; end,
			warning = CE_MENU_SHOW_IN_TRIAL_ARENA_WARN
		},
        {
			type    = "checkbox",
			name    = CE_MENU_HIDE_IN_COMBAT,
			tooltip = CE_MENU_HIDE_IN_COMBAT_TIP,
			getFunc = function() return CE.hideInCombat end,
			setFunc = function(newVal) CE.SaveHideInCombat(newVal) CE.hideInCombat = newVal; end,
		},  
        {
			type = "slider",
			name = CE_MENU_HIDE_IN_COMBAT_DELAY,
			tooltip = CE_MENU_HIDE_IN_COMBAT_DELAY_TIP,
			min = 0,
			max = 15,
			step = 1,	
			getFunc = function() return CE.hide_delay end,
			setFunc = function(value) CE.SaveHideDelay(value) CE.hide_delay = value end,
			width = "full",	
            disabled = function() return not CE.hideInCombat end
			--default = 15,	
		},
		{
			type    = "checkbox",
			name    = CE_MENU_HIDE_IN_MENU,
			tooltip = CE_MENU_HIDE_IN_MENU_TIP,
			getFunc = function() return CE.hideInMenu end,
			setFunc = function(newVal) CE.SaveHideInMenu(newVal) CE.hideInMenu = newVal; end,
		},       
        {
            type = "header",
            name = CE_MENU_COLORS_HEADER,
            width = "full",
        },
        {
			type = "colorpicker",
			name = CE_MENU_HEADER_COLOR,
			tooltip = CE_MENU_HEADER_COLOR_TIP,
			getFunc = function() return unpack(CE.head_color) end,
			setFunc = function(r,g,b,a) CE.SaveHeadColor(r, g, b, a) end,
			width = "full",
			--warning = "Color will update next time text updates",
		},
        {
			type = "colorpicker",
			name = CE_MENU_COMPLETE_SET_COLOR,
			tooltip = CE_MENU_COMPLETE_SET_COLOR_TIP,
			getFunc = function() return unpack(CE.comp_color) end,
			setFunc = function(r,g,b,a) CE.SaveCompColor(r, g, b, a) end,
			width = "full",
			--warning = "Color will update next time text updates",
		},
        {
			type = "colorpicker",
			name = CE_MENU_INCOMPLETE_SET_COLOR,
			tooltip = CE_MENU_INCOMPLETE_SET_COLOR_TIP,
			getFunc = function() return unpack(CE.incomp_color) end,
			setFunc = function(r,g,b,a) CE.SaveIncompColor(r, g, b, a) end,
			width = "full",
			--warning = "Color will update next time text updates",
		},
        {
			type = "colorpicker",
			name = CE_MENU_WARNING_COLOR,
			tooltip = CE_MENU_WARNING_COLOR_TIP,
			getFunc = function() return unpack(CE.warn_color) end,
			setFunc = function(r,g,b,a) CE.SaveWarnColor(r, g, b, a) end,
			width = "full",
			--warning = "Color will update next time text updates",
		},
        {
            type = "header",
            name = CE_MENU_DEBUG_HEADER,
            width = "full",
        },
        {
            type = "button",
            name = CE_MENU_FORCE_UPDATE,
            tooltip = CE_MENU_FORCE_UPDATE_TIP,
            func = function() CE.OnSetUpdate() end,
            width = "full",	--or "full" (optional)
        },
    }

    LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(CE.name .. "Options", menuOptions)
	LAM:RegisterOptionControls(CE.name .. "Options", dataTable)
end