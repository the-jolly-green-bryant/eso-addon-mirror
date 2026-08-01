local AITUF = AITUF

-- Creates the addon settings menu
function AITUF.InitializeAddonMenu()
    local panelData = {
        type = "panel",
        name = "Added Info - Target Unit Frame",
        displayName = "Added Info - Target Unit Frame (AITUF)",
        author = "MrPikPik",
        version = AITUF.version,
        website = 'https://www.esoui.com/downloads/info2631-AddedInfo-TargetedUnitFrame.html#donate',
        donation = function()
            SCENE_MANAGER:Show('mailSend')
            zo_callLater(function() 
                ZO_MailSendToField:SetText("@MrPikPik")
                ZO_MailSendSubjectField:SetText("Thank you for making addons!")
                ZO_MailSendBodyField:SetText("I like using your addon 'Added Info - Targeted Unit Frames'")
                ZO_MailSendBodyField:TakeFocus()
            end, 250)
        end,
        registerForRefresh = true,
        registerForDefaults = true
    }

    local optionsData = {}

    -- Description
    table.insert(optionsData, {
        type = "description",
        text = GetString(AITUF_OPTIONS_DESCRIPTION),
    })
    
    -- Character Data Collector Link
    if MPPCDC then
        table.insert(optionsData, {
            type = "description",
            text = GetString(AITUF_OPTIONS_CDCLINK_D),
        })
        table.insert(optionsData, {
            type = "checkbox",
            name = GetString(AITUF_OPTIONS_CDCLINK),
            tooltip = GetString(AITUF_OPTIONS_CDCLINK_TT),
            default = AITUF.SV.showCPifAvailable,
            getFunc = function() return AITUF.SV.showCPifAvailable end,
            setFunc = function(newValue) AITUF.SV.showCPifAvailable = newValue end,
        })
    end
    
    -- Options header
    table.insert(optionsData, {
        type = "header",
        name = GetString(AITUF_OPTIONS_HEADER),
    })
    
    -- Account wide setting
    table.insert(optionsData, {
        type = "checkbox",
        name = GetString(AITUF_OPTIONS_ACCOUNTWIDE_SETTINGS),
        tooltip = GetString(AITUF_OPTIONS_ON) .. GetString(AITUF_OPTIONS_ACCOUNTWIDE_SETTINGS_TT_ON) .. "\n" .. GetString(AITUF_OPTIONS_OFF) .. GetString(AITUF_OPTIONS_ACCOUNTWIDE_SETTINGS_TT_OFF),
        requiresReload = true,
        default = AITUF.accountWideDefaults.accountWide,
        getFunc = function() return AITUF.DS.accountWide end,
        setFunc = function(newValue) AITUF.DS.accountWide = newValue end,
    })
    
    -- Divider
    table.insert(optionsData, {
        type = "divider",
    })
    
    -- Display Type
    table.insert(optionsData, {
        type = "dropdown",
        name = GetString(AITUF_OPTIONS_DISPLAY_TYPE),
        tooltip = GetString(AITUF_OPTIONS_DISPLAY_TYPE_TT),
        choices = {
            GetString(AITUF_OPTIONS_DISPLAY_NONE),
            GetString(AITUF_OPTIONS_DISPLAY_RACE),
            GetString(AITUF_OPTIONS_DISPLAY_CLASS),
            GetString(AITUF_OPTIONS_DISPLAY_BOTH)
        },
        getFunc = function() 
            if AITUF.SV.showClass and AITUF.SV.showRace then 
                return GetString(AITUF_OPTIONS_DISPLAY_BOTH)
            elseif AITUF.SV.showClass then
                return GetString(AITUF_OPTIONS_DISPLAY_CLASS)				
            elseif AITUF.SV.showRace then
                return GetString(AITUF_OPTIONS_DISPLAY_RACE)
            else
                return GetString(AITUF_OPTIONS_DISPLAY_NONE)
            end
        end,
        setFunc = function(newValue)
            if newValue == GetString(AITUF_OPTIONS_DISPLAY_CLASS) then 
                AITUF.SV.showClass = true
                AITUF.SV.showRace = false
            elseif newValue == GetString(AITUF_OPTIONS_DISPLAY_RACE) then
                AITUF.SV.showClass = false
                AITUF.SV.showRace = true
            elseif newValue == GetString(AITUF_OPTIONS_DISPLAY_BOTH) then
                AITUF.SV.showClass = true
                AITUF.SV.showRace = true
            elseif newValue == GetString(AITUF_OPTIONS_DISPLAY_NONE) then
                AITUF.SV.showClass = false
                AITUF.SV.showRace = false
            end
        end,
        default = GetString(AITUF_OPTIONS_DISPLAY_NONE)
    })
    
    -- Use Class Icon
    table.insert(optionsData, {
        type = "checkbox",
        name = GetString(AITUF_OPTIONS_USE_ICON_CLASS),
        tooltip = GetString(AITUF_OPTIONS_ON) .. GetString(AITUF_OPTIONS_USE_ICONS_TT_ON) .. "\n" .. GetString(AITUF_OPTIONS_OFF) .. GetString(AITUF_OPTIONS_USE_ICONS_TT_OFF),
        disabled = function()
            return not AITUF.SV.showClass
        end,
        default = AITUF.defaults.useClassIcon,
        getFunc = function() return AITUF.SV.useClassIcon end,
        setFunc = function(newValue) AITUF.SV.useClassIcon = newValue end,
    })
    
    -- Use Race Icon
    table.insert(optionsData, {
        type = "checkbox",
        name = GetString(AITUF_OPTIONS_USE_ICON_RACE),
        tooltip = GetString(AITUF_OPTIONS_ON) .. GetString(AITUF_OPTIONS_USE_ICONS_TT_ON) .. "\n" .. GetString(AITUF_OPTIONS_OFF) .. GetString(AITUF_OPTIONS_USE_ICONS_TT_OFF),
        disabled = function()
            return not AITUF.SV.showRace
        end,
        default = AITUF.defaults.useRaceIcon,
        getFunc = function() return AITUF.SV.useRaceIcon end,
        setFunc = function(newValue) AITUF.SV.useRaceIcon = newValue end,
    })
    
    -- Race Icon Size
    table.insert(optionsData, {
        type = "dropdown",
        name = GetString(AITUF_OPTIONS_ICON_SIZE_RACE),
        tooltip = GetString(AITUF_OPTIONS_ICON_SIZE_TT),
        choices = {
            GetString(AITUF_OPTIONS_ICON_SIZE_NORMAL),
            GetString(AITUF_OPTIONS_ICON_SIZE_LARGE)
        },
        disabled = function()
            return not (AITUF.SV.useRaceIcon and AITUF.SV.showRace)
        end,
        getFunc = function() 
            if AITUF.SV.iconSizeRace == 24 then 
                return GetString(AITUF_OPTIONS_ICON_SIZE_NORMAL)
            elseif AITUF.SV.iconSizeRace == 32  then
                return GetString(AITUF_OPTIONS_ICON_SIZE_LARGE)				
            end
        end,
        setFunc = function(newValue)
            if newValue == GetString(AITUF_OPTIONS_ICON_SIZE_NORMAL) then 
                AITUF.SV.iconSizeRace = 24
            elseif newValue == GetString(AITUF_OPTIONS_ICON_SIZE_LARGE) then
                AITUF.SV.iconSizeRace = 32
            end
        end,
        default = GetString(AITUF_OPTIONS_ICON_SIZE_NORMAL)
    })
    
    -- Highlight Friends
    table.insert(optionsData, {
        type = "checkbox",
        name = GetString(AITUF_OPTIONS_SHOW_FRIENDS),
        tooltip = GetString(AITUF_OPTIONS_SHOW_FRIENDS_TT),
        default = AITUF.defaults.highlightFriends,
        getFunc = function() return AITUF.SV.highlightFriends end,
        setFunc = function(newValue) AITUF.SV.highlightFriends = newValue end,
    })
    
    -- Highlight Guild Members
    table.insert(optionsData, {
        type = "checkbox",
        name = GetString(AITUF_OPTIONS_SHOW_GUILD),
        tooltip = GetString(AITUF_OPTIONS_SHOW_GUILD_TT),
        default = AITUF.defaults.highlightGuildMembers,
        getFunc = function() return AITUF.SV.highlightGuildMembers end,
        setFunc = function(newValue) AITUF.SV.highlightGuildMembers = newValue end,
    })

    -- Color Guild Member icon
    table.insert(optionsData, {
        type = "checkbox",
        name = GetString(AITUF_OPTIONS_COLORIZE_GUILD),
        tooltip = GetString(AITUF_OPTIONS_COLORIZE_GUILD_TT),
        default = AITUF.defaults.colorGuildIcon,
        getFunc = function() return AITUF.SV.colorGuildIcon end,
        setFunc = function(newValue) AITUF.SV.colorGuildIcon = newValue end,
    })
    
    -- Highlight ESO Plus Members
    table.insert(optionsData, {
        type = "checkbox",
        name = GetString(AITUF_OPTIONS_SHOW_ESOPLUS),
        tooltip = GetString(AITUF_OPTIONS_SHOW_ESOPLUS_TT),
        default = AITUF.defaults.highlightEsoPlus,
        getFunc = function() return AITUF.SV.highlightEsoPlus end,
        setFunc = function(newValue) AITUF.SV.highlightEsoPlus = newValue end,
    })
    
    -- Hide Title
    table.insert(optionsData, {
        type = "checkbox",
        name = GetString(AITUF_OPTIONS_HIDETITLE),
        tooltip = GetString(AITUF_OPTIONS_HIDETITLE_TT),
        default = AITUF.defaults.hideTitle,
        getFunc = function() return AITUF.SV.hideTitle end,
        setFunc = function(newValue) AITUF.SV.hideTitle = newValue end,
    })
    
    local optionsPanel = LibAddonMenu2:RegisterAddonPanel(AITUF.name, panelData)
    LibAddonMenu2:RegisterOptionControls(AITUF.name, optionsData)
end