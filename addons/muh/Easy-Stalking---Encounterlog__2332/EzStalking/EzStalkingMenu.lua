if EzStalking == nil then EzStalking = { } end
local Ez = _G['EzStalking']
local L = Ez:GetLocale()


Ez.Menu = { }

function Ez.Menu:initialize()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local libDialog = LibDialog

    local panel_data = {
        type = "panel",
        name = Ez.title,
        displayName = Ez.title,
        author = Ez.author,
        version = Ez.version,
        registerForDefaults = true,
        registerForRefresh = true,
    }
    LAM:RegisterAddonPanel(Ez.name, panel_data)

    local options_table = { }
    options_table[#options_table+1] =
    {
        type = "header",
        name = L.menu.header,
    }
    -- [[
    options_table[#options_table+1] =
    {
        type = "description",
        text = L.menu.description,
    }
    --]]
    options_table[#options_table+1] =
    {
        type = "divider",
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.accountwide,
        tooltip = L.menu.accountwide_tooltip,
        getFunc = function() return EzStalking_SavedVars.Default[GetDisplayName()]['$AccountWide']["account_wide"] end,
        setFunc = function(value) EzStalking_SavedVars.Default[GetDisplayName()]['$AccountWide']["account_wide"] = value end,
        requiresReload = true,
        default = Ez.defaults.account_wide,
    }
    options_table[#options_table+1] =
    {
        type = "divider",
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        width = "half",
        name = L.menu.logging_enabled,
        tooltip = L.menu.logging_enabled_tooltip,
        getFunc = function() return Ez.settings.log.enabled end,
        setFunc = function(value)
            Ez.enable_automatic_logging(value)
            Ez.settings.log.enabled = value
        end,
        requiresReload = false,
        default = Ez.defaults.log.enabled,
    }
    if libDialog then
        options_table[#options_table+1] =
        {
            type = "checkbox",
            width = "half",
            name = L.menu.normal_difficulty,
            tooltip = L.menu.normal_difficulty_tooltip,
            getFunc = function() return Ez.settings.log.normal_difficulty end,
            setFunc = function(value) Ez.settings.log.normal_difficulty = value end,
            disabled = function() return not Ez.settings.log.enabled end,
            requiresReload = false,
            default = Ez.defaults.log.normal_difficulty,
        }
    end
    if libDialog then
        options_table[#options_table+1] =
        {
            type = "checkbox",
            width = "half",
            name = L.menu.use_dialog,
            tooltip = L.menu.use_dialog_tooltip,
            getFunc = function() return Ez.settings.log.use_dialog end,
            setFunc = function(value) Ez.settings.log.use_dialog = value end,
            disabled = function() return not Ez.settings.log.enabled end,
            requiresReload = false,
            default = Ez.defaults.log.use_dialog,
        }
    end
    if libDialog then
        options_table[#options_table+1] =
        {
            type = "checkbox",
            width = "half",
            name = L.menu.remember_zone,
            tooltip = L.menu.remember_zone_tooltip,
            getFunc = function() return Ez.settings.log.remember_zone end,
            setFunc = function(value) Ez.settings.log.remember_zone = value end,
            disabled = function()
                return not Ez.settings.log.use_dialog or not Ez.settings.log.enabled
            end,
            requiresReload = false,
            default = Ez.defaults.log.remember_zone,
        }
    end
    --[[
    if libDialog then
        options_table[#options_table+1] =
        {
            type = "checkbox",
            name = L.menu.upload_reminder,
            tooltip = L.menu.upload_reminder_tooltip,
            getFunc = function() return EzStalking.settings.upload_reminder end,
            setFunc = function(value)
                EzStalking.show_upload_reminder_dialog(value)
                EzStalking.settings.upload_reminder = value
            end,
            requiresReload = false,
            default = EzStalking.defaults.upload_reminder,
        }
    end
    --]]
    options_table[#options_table+1] =
    {
        type = "header",
        name = L.menu.location.header,
    }
    options_table[#options_table+1] =
    {
        type  = "header",
        width = "half",
        name  = "PvE", 
    }
    options_table[#options_table+1] =
    {
        type  = "header",
        width = "half",
        name  = "PvP",

    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        width = "half",
        name = L.menu.location.dungeons,
        tooltip = L.menu.location.dungeons_tooltip,
        getFunc = function() return Ez.settings.log.dungeons end,
        setFunc = function(value) Ez.settings.log.dungeons = value end,
        disabled = function() return not Ez.settings.log.enabled end,
        requiresReload = false,
        default = Ez.defaults.log.dungeons,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        width = "half",
        name = L.menu.location.battlegrounds,
        tooltip = L.menu.location.battlegrounds_tooltip,
        getFunc = function() return Ez.settings.log.battlegrounds end,
        setFunc = function(value) Ez.settings.log.battlegrounds = value end,
        disabled = function() return not Ez.settings.log.enabled end,
        requiresReload = false,
        default = Ez.defaults.log.battlegrounds,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        width = "half",
        name = L.menu.location.endless,
        tooltip = L.menu.location.endless_tooltip,
        getFunc = function() return Ez.settings.log.endless end,
        setFunc = function(value) Ez.settings.log.endless = value end,
        disabled = function() return not Ez.settings.log.enabled end,
        requiresReload = false,
        default = Ez.defaults.log.endless,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        width = "half",
        name = L.menu.location.imperial_city,
        tooltip = L.menu.location.imperial_city_tooltip,
        getFunc = function() return Ez.settings.log.imperial_city end,
        setFunc = function(value) Ez.settings.log.imperial_city = value end,
        disabled = function() return not Ez.settings.log.enabled end,
        requiresReload = false,
        default = Ez.defaults.log.imperial_city,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        width = "half",
        name =  L.menu.location.arenas,
        tooltip = L.menu.location.arenas_tooltip,
        getFunc = function() return Ez.settings.log.arenas end,
        setFunc = function(value) Ez.settings.log.arenas = value end,
        disabled = function() return not Ez.settings.log.enabled end,
        requiresReload = false,
        default = Ez.defaults.log.arenas,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        width = "half",
        name = L.menu.location.cyrodiil,
        tooltip = L.menu.location.cyrodiil_tooltip,
        getFunc = function() return Ez.settings.log.cyrodiil end,
        setFunc = function(value) Ez.settings.log.cyrodiil = value end,
        disabled = function() return not Ez.settings.log.enabled end,
        requiresReload = false,
        default = Ez.defaults.log.cyrodiil,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        width = "half",
        name = L.menu.location.trials,
        tooltip = L.menu.location.trials_tooltip,
        getFunc = function() return Ez.settings.log.trials end,
        setFunc = function(value) Ez.settings.log.trials = value end,
        disabled = function() return not Ez.settings.log.enabled end,
        requiresReload = false,
        default = Ez.defaults.log.trials,
    }
    options_table[#options_table+1] =
    {
        type = "divider",
        width = "half",
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        width = "half",
        name = L.menu.location.housing,
        tooltip = L.menu.location.housing_tooltip,
        getFunc = function() return Ez.settings.log.housing end,
        setFunc = function(value) Ez.settings.log.housing = value end,
        disabled = function() return not Ez.settings.log.enabled end,
        requiresReload = false,
        default = Ez.defaults.log.housing,
    }
    options_table[#options_table+1] =
    {
        type = "header",
        name = L.menu.indicator.header,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.indicator.enabled,
        tooltip = L.menu.indicator.enabled_tooltip,
        getFunc = function() return Ez.settings.indicator.enabled end,
        setFunc = function(value)
            Ez.settings.indicator.enabled = value
            Ez.UI.enable_indicator(value)
        end,
        requiresReload = false,
        default = Ez.defaults.indicator.enabled,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.indicator.locked,
        tooltip = L.menu.indicator.locked_tooltip,
        getFunc = function() return Ez.settings.indicator.locked end,
        setFunc = function(value)
            Ez.UI.lock(value)
        end,
        disabled = function() return not Ez.settings.indicator.enabled end,
        requiresReload = false,
        default = Ez.defaults.indicator.locked,
    }
    options_table[#options_table+1] =
    {
        type = "colorpicker",
        name = L.menu.indicator.color,
        tooltip = L.menu.indicator.color_tooltip,
        getFunc = function() return unpack(Ez.settings.indicator.color) end,
        setFunc = function(r, g, b)
            Ez.settings.indicator.color = {r, g, b}
            Ez.settings.indicator.unlocked_color = {1 - r, 1 - g, 1 - b}
            Ez.UI.update_color()
        end,
        disabled = function() return not Ez.settings.indicator.enabled end,
        requiresReload = false,
        default = Ez.defaults.indicator.color,
    }

    LAM:RegisterOptionControls(Ez.name, options_table)
end