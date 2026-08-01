local HCS = HazeCharswap

function HCS.Settings_Initialize()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type                = "panel",
        name                = GetString(HAZECS_SET_HEADER),
        displayName         = "|cFFD700" .. GetString(HAZECS_SET_HEADER) .. "|r",
        author              = "haze068",
        version             = HCS.version,
        registerForRefresh  = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel("HazeCharswap_Settings", panelData)

    local options = {
        {
            type = "description",
            text = GetString(HAZECS_SET_DESC),
        },
        {
            type = "header",
            name = GetString(HAZECS_SET_HEADER),
        },
        {
            type    = "checkbox",
            name    = GetString(HAZECS_SET_AUTO_OPEN),
            tooltip = GetString(HAZECS_SET_AUTO_OPEN_TT),
            getFunc = function() return HCS.sv.autoOpenAtBank end,
            setFunc = function(v) HCS.sv.autoOpenAtBank = v end,
            default = HCS.defaults.autoOpenAtBank,
        },
        {
            type    = "checkbox",
            name    = GetString(HAZECS_SET_CHAT_MSGS),
            tooltip = GetString(HAZECS_SET_CHAT_MSGS_TT),
            getFunc = function() return HCS.sv.showChatMessages end,
            setFunc = function(v) HCS.sv.showChatMessages = v end,
            default = HCS.defaults.showChatMessages,
        },
        {
            type    = "checkbox",
            name    = GetString(HAZECS_SET_INCLUDE_STOLEN),
            tooltip = GetString(HAZECS_SET_INCLUDE_STOLEN_TT),
            getFunc = function() return HCS.sv.includeStolen end,
            setFunc = function(v) HCS.sv.includeStolen = v end,
            default = HCS.defaults.includeStolen,
        },
        {
            type    = "checkbox",
            name    = GetString(HAZECS_SET_SHOW_ICONS),
            getFunc = function() return HCS.sv.showIcons end,
            setFunc = function(v)
                HCS.sv.showIcons = v
                HCS.UI_Refresh()
            end,
            default = HCS.defaults.showIcons,
        },
        {
            type    = "button",
            name    = GetString(HAZECS_SET_RESET_LIST),
            tooltip = GetString(HAZECS_SET_RESET_LIST_TT),
            func    = function() HCS.ClearList() end,
            warning = GetString(HAZECS_SET_RESET_LIST_TT),
        },
    }

    LAM:RegisterOptionControls("HazeCharswap_Settings", options)
end
