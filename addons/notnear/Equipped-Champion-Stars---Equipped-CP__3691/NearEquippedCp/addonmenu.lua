local addon = NEAR_EC

local str = {
    type = {
        name = GetString(NEAREC_am_type_name),
    },
    show = {
        all = {
            name = GetString(NEAREC_am_show_all_name),
        },
        craft = {
            name = GetString(NEAREC_am_show_craft_name),
        },
        warfare = {
            name = GetString(NEAREC_am_show_warfare_name),
        },
        fitness = {
            name = GetString(NEAREC_am_show_fitness_name),
        },
    },
    hide = {
        inMenu = {
            name = GetString(NEAREC_am_hide_inMenu_name),
        },
        inCombat = {
            name = GetString(NEAREC_am_hide_inCombat_name),
        },
    },
    align = {
        name = GetString(NEAREC_am_align_name),
        choices = {
            GetString(NEAREC_am_align_left),
            GetString(NEAREC_am_align_right),
        },
    },
    lock = {
        name = GetString(NEAREC_am_lock_name),
    },
    resetpos = {
        name = GetString(NEAREC_am_resetpos_name),
        warning = GetString(NEAREC_am_resetpos_warning),
    },
    profile = {
        toggle = {
            name = GetString(NEAREC_am_profile_toggle_name),
            tooltip = GetString(NEAREC_am_profile_toggle_tooltip),
        },
        selector = {
            name = GetString(NEAREC_am_profile_selector_name),
        },
        copy = {
            name = GetString(NEAREC_am_profile_copy_name),
            warning = GetString(NEAREC_am_profile_copy_warning),
        },
    },
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon settings panel
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NEAR_EC.SetupSettings()
	local LAM2 = LibAddonMenu2
    if not LAM2 then return end

	local sv = addon.ASV

	local panelData = {
		type				= "panel",
		name 				= addon.title,
		displayName 		= addon.title,
		author 				= addon.author,
		version				= addon.version,
		slashCommand 		= "/ecpsettings",
		registerForRefresh	= true,
		registerForDefaults	= true,
	}
	LAM2:RegisterAddonPanel(addon.name, panelData)

	local controls = {}

    controls[#controls + 1] = {
        type = 'checkbox',
        name = str.type.name,
        getFunc = function() return addon.ASV_main.accountwide end,
        setFunc = function(v) addon.ASV_main.accountwide = v end,
        default = true,
        requiresReload = true,
    }
    ---------------------------------------------------------------------------------
    controls[#controls + 1] = { type = 'divider' }
    ---------------------------------------------------------------------------------
    controls[#controls + 1] = {
        type = 'checkbox',
        name = str.show.all.name,
        getFunc = function() return sv.show_all end,
        setFunc = function(v)
            sv.show_all = v
            addon.ShowByType()
        end,
        default = addon.defaults.account.show_all,
    }
    controls[#controls + 1] = {
        type = 'checkbox',
        name = str.show.craft.name,
        getFunc = function() return sv.show_craft end,
        setFunc = function(v)
            sv.show_craft = v
            addon.ShowByType()
        end,
        default = addon.defaults.account.show_craft,
    }
    controls[#controls + 1] = {
        type = 'checkbox',
        name = str.show.warfare.name,
        getFunc = function() return sv.show_warfare end,
        setFunc = function(v)
            sv.show_warfare = v
            addon.ShowByType()
        end,
        default = addon.defaults.account.show_warfare,
    }
    controls[#controls + 1] = {
        type = 'checkbox',
        name = str.show.fitness.name,
        getFunc = function() return sv.show_fitness end,
        setFunc = function(v)
            sv.show_fitness = v
            addon.ShowByType()
        end,
        default = addon.defaults.account.show_fitness,
    }
    ---------------------------------------------------------------------------------
    controls[#controls + 1] = { type = 'divider' }
    ---------------------------------------------------------------------------------
    controls[#controls + 1] = {
        type = 'checkbox',
        name = str.hide.inMenu.name,
        getFunc = function() return sv.hide.inMenu end,
        setFunc = function(v)
            sv.hide.inMenu = v
            addon.events.menu()
        end,
        default = addon.defaults.account.hide.inMenu,
    }
    controls[#controls + 1] = {
        type = 'checkbox',
        name = str.hide.inCombat.name,
        getFunc = function() return sv.hide.inCombat end,
        setFunc = function(v)
            sv.hide.inCombat = v
            addon.events.combat()
        end,
        default = addon.defaults.account.hide.inCombat,
    }
    ---------------------------------------------------------------------------------
    controls[#controls + 1] = { type = 'divider' }
    ---------------------------------------------------------------------------------
    controls[#controls + 1] = {
        type = 'dropdown',
        name = str.align.name,
        choices = str.align.choices,
        choicesValues = {TOPLEFT, TOPRIGHT},
        getFunc = function() return sv.labelAnchors.point end,
        setFunc = function(v)
            sv.labelAnchors.point = v
            if v == TOPLEFT then
                sv.labelAnchors.relativePoint = BOTTOMLEFT
            else
                sv.labelAnchors.relativePoint = BOTTOMRIGHT
            end
            addon.SavePos()
            addon.SetAnchors()
            addon.ShowByType()
        end,
    }
    ---------------------------------------------------------------------------------
    controls[#controls + 1] = { type = 'divider' }
    ---------------------------------------------------------------------------------
    controls[#controls + 1] = {
        type = 'checkbox',
        name = str.lock.name,
        getFunc = function() return sv.lockUI end,
        setFunc = function(v)
            sv.lockUI = v
            addon.lockUI()
        end,
        default = addon.defaults.account.lockUI,
    }
    controls[#controls + 1] = {
        type = 'button',
        name = str.resetpos.name,
        func = function() addon.ResetPos() end,
        isDangerous = true,
        warning = str.resetpos.warning,
    }
    ---------------------------------------------------------------------------------
    controls[#controls + 1] = { type = 'divider' }
    ---------------------------------------------------------------------------------

    local profilesList = addon.CreateProfileList()

    local enablePE = false
    controls[#controls + 1] = {
        type = 'checkbox',
        name = str.profile.toggle.name,
        getFunc = function() return enablePE end,
        setFunc = function(v) enablePE = v end,
        tooltip = function()
            if #profilesList.choices == 0 then
                return str.profile.toggle.tooltip
            else
                return nil
            end
        end,
        disabled = function()
            if #profilesList.choices == 0 then
                return true
            else
                return false
            end
        end,
    }

    local choice = profilesList.choicesValues[1]
	controls[#controls + 1] = {
		type = 'dropdown',
		name = str.profile.selector.name,
		choices = profilesList.choices,
		choicesValues = profilesList.choicesValues,
		getFunc = function() return choice end,
		setFunc = function(v) choice = v end,
		width = 'half',
		disabled = function() return not enablePE end,
	}

    controls[#controls + 1] = {
		type = 'button',
		name = str.profile.copy.name,
        warning = str.profile.copy.warning,
		func = function () addon.OverwriteData(choice) end,
		width = 'half',
		disabled = function() return not enablePE end,
        isDangerous = true,
	}

	LAM2:RegisterOptionControls(addon.name, controls)

end
