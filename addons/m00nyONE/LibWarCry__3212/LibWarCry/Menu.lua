local LAM2 = LibAddonMenu2
LibWarCry = LibWarCry or {}

-- create a custom menu by using LibCustomMenu
function LibWarCry.createMenu()
    local panelData = {
        type = "panel",
        name = "WarCry",
        displayName = "WarCry",
        author = "|c76c3f4@m00nyONE|r",
        version = LibWarCry.version,
        website = "https://github.com/m00nyONE/LibWarCry",
        feedback = "https://www.esoui.com/downloads/info3212-LibWarCry.html#comments",
        donation = LibWarCry.donate,
        slashCommand = "/wcsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local optionsTable = {
        [1] = {
            type = "header",
            name = GetString(LIBWARCRY_MENU_GCS_NAME),
            width = "full",
        },
        [2] = {
            type = "checkbox",
            name = GetString(LIBWARCRY_MENU_GCS_SYNCED_WARCRY_TITLE),
            tooltip = GetString(LIBWARCRY_MENU_GCS_SYNCED_WARCRY_TOOLTIP),
            getFunc = function() return LibWarCry.savedVariables.groupCommands end,
            setFunc = function(value) LibWarCry.toggleListener(value) end,
            width = "half",
            default = true,
        },
        [3] = {
            type = "texture",
            image = "/esoui/art/icons/trophy_malacaths_wrathful_flame.dds",
            imageWidth = 64,
            imageHeight = 64,
            width = "half",
        },
    }

    LAM2:RegisterAddonPanel("LibWarCryMenu", panelData)
    LAM2:RegisterOptionControls("LibWarCryMenu", optionsTable)
end