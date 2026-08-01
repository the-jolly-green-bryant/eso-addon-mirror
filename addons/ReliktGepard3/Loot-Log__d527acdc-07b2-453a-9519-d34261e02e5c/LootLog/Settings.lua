LootLog = LootLog or {}
local LL = LootLog

local function GetSettings()
    LL.EnsureSaved()
    return LL.saved and LL.saved.settings or {}
end

local function GetUIScaleSetting()
    local settings = GetSettings()
    return tonumber(settings.uiScale) or 1.0
end

function LL.RegisterAddonMenu()
    local LHAS = LibHarvensAddonSettings
    if not LHAS then
        return
    end

    local panel = LHAS:AddAddon("Loot Log", {
        allowDefaults = false,
        allowRefresh = true,
    })
    if not panel or type(panel.AddSetting) ~= "function" then
        return
    end

    panel:AddSetting({
        type = LHAS.ST_SECTION,
        label = "Browser",
    })

    panel:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Open Loot Log",
        buttonText = "Open",
        clickHandler = function()
            LL.ShowUI()
        end,
    })

    panel:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "UI Scale",
        min = 0.8,
        max = 2.0,
        step = 0.05,
        format = "%.2f",
        default = 1.0,
        getFunction = function()
            return GetUIScaleSetting()
        end,
        setFunction = function(value)
            LL.SetUIScale(value)
        end,
    })

    panel:AddSetting({
        type = LHAS.ST_SECTION,
        label = "Diagnostics",
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Debug Logging",
        default = false,
        getFunction = function()
            local settings = GetSettings()
            return settings.debug == true
        end,
        setFunction = function(value)
            local settings = GetSettings()
            settings.debug = value == true
        end,
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Event Probe",
        default = false,
        getFunction = function()
            local settings = GetSettings()
            return settings.eventProbe == true
        end,
        setFunction = function(value)
            local settings = GetSettings()
            settings.eventProbe = value == true
        end,
    })
end
