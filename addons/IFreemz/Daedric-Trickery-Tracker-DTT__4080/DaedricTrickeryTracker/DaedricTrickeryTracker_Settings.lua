local LAM = LibAddonMenu2

function DTT_CreateSettingsMenu()
    if not DTT then d("!!! ERROR: Global DTT table not found!") return false end
    local PrintDebug = DTT.PrintDebug and function(msg) DTT:PrintDebug(msg) end or function() end
    if not LAM then PrintDebug("!!! ERROR: LibAddonMenu-2.0 (LAM) not found!"); return false end
    PrintDebug("CreateSettingsMenu: Entered.")

    local panelData = {
        type = "panel",
        name = DTT_SETTINGS_TITLE,
        displayName = DTT_SETTINGS_TITLE,
        author = DTT.author or "@IFreemz954",
        version = DTT.version,
        registerForRefresh = true,
        registerForDefaults = true,
        slashCommand = "/dtt",
    }
    PrintDebug("Panel data prepared.")
    local defaultSettings = DTT:DefaultSettings()

    local optionsTable = {
        { type = "header", name = "General", },
        { type = "checkbox", name = DTT_SETTINGS_ENABLED_NAME, tooltip = DTT_SETTINGS_ENABLED_TOOLTIP, getFunc = function() return DTT.savedVariables and DTT.savedVariables.enabled end, setFunc = function(v) if DTT.savedVariables then DTT.savedVariables.enabled=v; DTT:UpdateFragmentVisibility(); if _G["DTT_GUI_UpdateGUIDisplay"] then pcall(DTT_GUI_UpdateGUIDisplay) end end end, default = defaultSettings.enabled, width = "full", },
        { type = "checkbox", name = DTT_SETTINGS_LOCK_NAME, tooltip = DTT_SETTINGS_LOCK_TOOLTIP, getFunc = function() return DTT.savedVariables and DTT.savedVariables.locked end, setFunc = function(v) if DTT.savedVariables then DTT.savedVariables.locked=v; if DTT.ApplyLockState then pcall(DTT.ApplyLockState, DTT) else PrintDebug("ERR: ApplyLockState not found.") end end end, default = defaultSettings.locked, width = "full", },

        { type = "header", name = "Appearance", },
        { type = "slider", name = DTT_SETTINGS_ICON_SIZE_NAME, tooltip = DTT_SETTINGS_ICON_SIZE_TOOLTIP, min = 20, max = 100, step = 2, getFunc = function() return DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.iconSize end, setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.design then DTT.savedVariables.design.iconSize=v; if _G["DTT_GUI_ApplyDesignSettings"] then pcall(DTT_GUI_ApplyDesignSettings) end end end, default = defaultSettings.design.iconSize, },
        { type = "slider", name = DTT_SETTINGS_BORDER_THICKNESS_NAME, tooltip = DTT_SETTINGS_BORDER_THICKNESS_TOOLTIP, min = 0, max = 10, step = 1, getFunc = function() return DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.borderThickness end, setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.design then DTT.savedVariables.design.borderThickness=v; if _G["DTT_GUI_ApplyDesignSettings"] then pcall(DTT_GUI_ApplyDesignSettings) end end end, default = defaultSettings.design.borderThickness, width = "half" },
        {
            type = "slider",
            name = DTT_SETTINGS_BUFF_BORDER_THICKNESS_NAME,
            tooltip = DTT_SETTINGS_BUFF_BORDER_THICKNESS_TOOLTIP,
            min = 0, max = 10, step = 1,
            getFunc = function() return DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.buffBorderThickness end,
            setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.design then DTT.savedVariables.design.buffBorderThickness=v; if _G["DTT_GUI_ApplyDesignSettings"] then pcall(DTT_GUI_ApplyDesignSettings) end end end,
            default = defaultSettings.design.buffBorderThickness,
            width = "half",
        },
        { type = "header", name = DTT_SETTINGS_COLOR_HEADER, },
        { type = "colorpicker", name = DTT_SETTINGS_COLOR_ACTIVE_NAME, tooltip = DTT_SETTINGS_COLOR_ACTIVE_TOOLTIP, getFunc = function() local c=DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.colors; return unpack(c and c.active or defaultSettings.design.colors.active) end, setFunc = function(r,g,b,a) if DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.colors then DTT.savedVariables.design.colors.active={r,g,b,a}; if _G["DTT_GUI_UpdateGUIDisplay"] then pcall(DTT_GUI_UpdateGUIDisplay) end end end, default = defaultSettings.design.colors.active, },
        { type = "colorpicker", name = DTT_SETTINGS_COLOR_COOLDOWN_NAME, tooltip = DTT_SETTINGS_COLOR_COOLDOWN_TOOLTIP, getFunc = function() local c=DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.colors; return unpack(c and c.cooldown or defaultSettings.design.colors.cooldown) end, setFunc = function(r,g,b,a) if DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.colors then DTT.savedVariables.design.colors.cooldown={r,g,b,a}; if _G["DTT_GUI_UpdateGUIDisplay"] then pcall(DTT_GUI_UpdateGUIDisplay) end end end, default = defaultSettings.design.colors.cooldown, },
        { type = "slider", name = DTT_SETTINGS_COLOR_STANDBY_ALPHA_NAME, tooltip = DTT_SETTINGS_COLOR_STANDBY_ALPHA_TOOLTIP, min = 0, max = 100, step = 5, getFunc = function() return DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.standbyOpacity end, setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.design then DTT.savedVariables.design.standbyOpacity=v; if _G["DTT_GUI_UpdateGUIDisplay"] then pcall(DTT_GUI_UpdateGUIDisplay) end end end, default = defaultSettings.design.standbyOpacity, },
        { type = "header", name = DTT_SETTINGS_TIMER_HEADER, },
        { type = "checkbox", name = DTT_SETTINGS_SHOW_TIMER_NAME, tooltip = DTT_SETTINGS_SHOW_TIMER_TOOLTIP, getFunc = function() return DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.showTimerText end, setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.design then DTT.savedVariables.design.showTimerText=v; if _G["DTT_GUI_UpdateGUIDisplay"] then pcall(DTT_GUI_UpdateGUIDisplay) end end end, default = defaultSettings.design.showTimerText, width = "full", },
        { type = "slider", name = DTT_SETTINGS_TIMER_FONT_SIZE_NAME, tooltip = DTT_SETTINGS_TIMER_FONT_SIZE_TOOLTIP, min = 20, max = 80, step = 5, getFunc = function() return DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.timerFontSizeScale and (DTT.savedVariables.design.timerFontSizeScale*100) or (defaultSettings.design.timerFontSizeScale*100) end, setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.design then DTT.savedVariables.design.timerFontSizeScale=v/100; if _G["DTT_GUI_ApplyDesignSettings"] then pcall(DTT_GUI_ApplyDesignSettings) end end end, default = defaultSettings.design.timerFontSizeScale*100, width = "half", },
        { type = "checkbox", name = DTT_SETTINGS_TIMER_DECIMAL_NAME, tooltip = DTT_SETTINGS_TIMER_DECIMAL_TOOLTIP, getFunc = function() return DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.showDecimal end, setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.design then DTT.savedVariables.design.showDecimal=v; if _G["DTT_GUI_UpdateGUIDisplay"] then pcall(DTT_GUI_UpdateGUIDisplay) end end end, default = defaultSettings.design.showDecimal, width = "half", },
        { type = "header", name = DTT_SETTINGS_BUFF_DISPLAY_HEADER, },
        { type = "slider", name = DTT_SETTINGS_BUFF_ICON_SCALE_NAME, tooltip = DTT_SETTINGS_BUFF_ICON_SCALE_TOOLTIP, min = 30, max = 100, step = 5, getFunc = function() return DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.buffIconScale and (DTT.savedVariables.design.buffIconScale*100) or (defaultSettings.design.buffIconScale*100) end, setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.design then DTT.savedVariables.design.buffIconScale=v/100; if _G["DTT_GUI_ApplyDesignSettings"] then pcall(DTT_GUI_ApplyDesignSettings) end end end, default = defaultSettings.design.buffIconScale*100, width = "full", },
        { type = "slider", name = DTT_SETTINGS_BUFF_TIMER_SCALE_NAME, tooltip = DTT_SETTINGS_BUFF_TIMER_SCALE_TOOLTIP, min = 30, max = 120, step = 5, getFunc = function() return DTT.savedVariables and DTT.savedVariables.design and DTT.savedVariables.design.buffTimerScale and (DTT.savedVariables.design.buffTimerScale*100) or (defaultSettings.design.buffTimerScale*100) end, setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.design then DTT.savedVariables.design.buffTimerScale=v/100; if _G["DTT_GUI_ApplyDesignSettings"] then pcall(DTT_GUI_ApplyDesignSettings) end end end, default = defaultSettings.design.buffTimerScale*100, width = "full", },

        { type = "header", name = DTT_SETTINGS_VISIBILITY_HEADER, },
        { type = "checkbox", name = DTT_SETTINGS_HIDE_OOC_NAME, tooltip = DTT_SETTINGS_HIDE_OOC_TOOLTIP, getFunc = function() return DTT.savedVariables and DTT.savedVariables.visibility and DTT.savedVariables.visibility.hideOOC end, setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.visibility then DTT.savedVariables.visibility.hideOOC=v; DTT:UpdateFragmentVisibility() end end, default = defaultSettings.visibility.hideOOC, width = "full", },
        {
            type = "checkbox",
            name = DTT_SETTINGS_REQUIRE_MIN_PIECES_NAME,
            tooltip = DTT_SETTINGS_REQUIRE_MIN_PIECES_TOOLTIP,
            getFunc = function() return DTT.savedVariables and DTT.savedVariables.visibility and DTT.savedVariables.visibility.requireMinPieces end,
            setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.visibility then DTT.savedVariables.visibility.requireMinPieces=v; DTT:UpdateFragmentVisibility() end end,
            default = defaultSettings.visibility.requireMinPieces,
            width = "full",
        },
        {
            type = "slider",
            name = DTT_SETTINGS_MIN_PIECES_TO_SHOW_NAME,
            tooltip = DTT_SETTINGS_MIN_PIECES_TO_SHOW_TOOLTIP,
            min = 1, max = 5, step = 1,
            getFunc = function() return DTT.savedVariables and DTT.savedVariables.visibility and DTT.savedVariables.visibility.minPiecesToShow end,
            setFunc = function(v) if DTT.savedVariables and DTT.savedVariables.visibility then DTT.savedVariables.visibility.minPiecesToShow=v; DTT:UpdateFragmentVisibility() end end,
            default = defaultSettings.visibility.minPiecesToShow,
            width = "full",
            disabled = function() return not (DTT.savedVariables and DTT.savedVariables.visibility and DTT.savedVariables.visibility.requireMinPieces) end,
        },
    }
    PrintDebug("Options table prepared.")

    PrintDebug("Attempting LAM:RegisterAddonPanel..."); local panelId = DTT.name.."Options"; local s,p = pcall(LAM.RegisterAddonPanel, LAM, panelId, panelData); if not s or not p then PrintDebug("!!! ERR: LAM Panel Reg fail! S:"..tostring(s)..", P:"..tostring(p)); DTT.settingsPanel=nil; return false end; DTT.settingsPanel = p; PrintDebug("Panel Registration SUCCESS.")
    PrintDebug("Attempting LAM:RegisterOptionControls..."); local cs,cr = pcall(LAM.RegisterOptionControls, LAM, panelId, optionsTable); if cs then PrintDebug("Controls Registration SUCCESS.") else PrintDebug("!!! ERR: LAM Ctrls Reg fail! "..tostring(cr)); DTT.settingsPanel=nil; return false end

    return true
end