local LAM = LibAddonMenu2

CCSentinelSettings = CCSentinelSettings or {}

function CCSentinelSettings:Initialize()
    self.savedVars = ZO_SavedVars:New("CCSentinelSV", 1, nil, {
        baseX = 500,
        baseY = 520,
        iconScale = 1.0,
    })

    local panelData = {
        type = "panel",
        name = "CCSentinel",
        displayName = "|cFFD700CCSentinel|r",
        author = "Synkronist",
        version = "2.4",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.settingsPanel = LAM:RegisterAddonPanel("CCSentinelSettings", panelData)

    local optionsData = {
        {
            type = "slider",
            name = "Base X Offset",
            tooltip = "Adjust the horizontal position of the Crowd Control Immunity icon.",
            min = 0,
            max = 1920,
            step = 10,
            getFunc = function() return self.savedVars.baseX end,
            setFunc = function(value)
                self.savedVars.baseX = value
                self.baseX = value
                CCSentinelFloats:RefreshSettings()
            end,
            default = 500,
        },
        {
            type = "slider",
            name = "Base Y Offset",
            tooltip = "Adjust the vertical position of the Crowd Control Immunity icon.",
            min = 0,
            max = 1080,
            step = 10,
            getFunc = function() return self.savedVars.baseY end,
            setFunc = function(value)
                self.savedVars.baseY = value
                self.baseY = value
                CCSentinelFloats:RefreshSettings()
            end,
            default = 520,
        },
        {
            type = "slider",
            name = "Icon Scale",
            tooltip = "Adjust the size of the Crowd Control Immunity icon (0.1x to 5.0x).",
            min = 0.1,
            max = 5.0,
            step = 0.1,
            getFunc = function() return self.savedVars.iconScale end,
            setFunc = function(value)
                self.savedVars.iconScale = value
                self.iconScale = value
                CCSentinelFloats:RefreshSettings()
            end,
            default = 1.0,
        },
    }

    LAM:RegisterOptionControls("CCSentinelSettings", optionsData)
end

EVENT_MANAGER:RegisterForEvent("CCSentinelSettingsInit", EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
    if addOnName == "CCSentinel" then
        CCSentinelSettings:Initialize()
        CCSentinelFloats:RefreshSettings()
    end
end)
