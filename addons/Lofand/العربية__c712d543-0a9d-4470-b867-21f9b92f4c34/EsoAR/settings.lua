local ADDON_NAME = "EsoAR"
local SV_VERSION = 1

local defaults = {
    enabled = true,        -- Arabic ON/OFF (addon features)
    keyboardArabic = true, -- Arabic keyboard conversion
}

function EsoAR_InitMenu()
    EsoAR_Variables = ZO_SavedVars:NewAccountWide("EsoAR_Variables", SV_VERSION, nil, defaults)

    if not LibAddonMenu2 then return end
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = "EsoAR",
        displayName = "EsoAR - ﺔﻴﺑﺮﻌﻟﺍ ",
        author = "@MATREX-X",
        version = "305",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("EsoAR_SettingsPanel", panelData)

    local optionsData = {
        {
            type = "checkbox",
            name = "Arabic (Addon) ON/OFF",
            tooltip = "تشغيل/إيقاف خصائص الأدون. يحتاج ReloadUI.",
            getFunc = function() return EsoAR_Variables.enabled end,
            setFunc = function(v)
                EsoAR_Variables.enabled = v
                ReloadUI()
            end,
            default = defaults.enabled,
        },
        {
            type = "checkbox",
            name = "Arabic Keyboard",
            tooltip = "تحويل كتابة الشات لحروف عربية.",
            getFunc = function() return EsoAR_Variables.keyboardArabic end,
            setFunc = function(v)
                EsoAR_Variables.keyboardArabic = v
            end,
            default = defaults.keyboardArabic,
        },
    }

    LAM:RegisterOptionControls("EsoAR_SettingsPanel", optionsData)
end
