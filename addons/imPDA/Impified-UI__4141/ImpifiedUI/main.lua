local addon = {}
addon.name = 'ImpifiedUI'
addon.displayName = 'Impified UI'

addon.features = {}

local EVENT_NAMESPACE = 'IMPIFIED_UI_EVENT_NAMESPACE'

local DEFAULT_SETTINGS = {
    groupFinder = {
        turnOffShowOwnRole = false,
    },
    guildBrowser =
    {
        alphabeticalSorting = false
    },
    characterWindow = {
        mundusResize = {
            enabled = true,
            size = 20,
        }
    },
    permaglow = {
        enabled = false,
    }
}

local SETTINGS_CONTROLS = {}

function addon:SetupSettings()
    local LAM = LibAddonMenu2

    local panelName = 'IMPIFIED_UI_SETTINGS'

    local panelData = {
        type = 'panel',
        name = 'Impified UI',
        author = '@impda',
    }

    local panel = LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, SETTINGS_CONTROLS)
end

function addon:AddFeature(feature)
    self.features[#self.features+1] = feature
end

function addon:SetupFeatures()
    for i, feature in ipairs(self.features) do
        feature.Setup(self)

        if feature.GetSettingsControl then
            for _, control in ipairs(feature.GetSettingsControl(self)) do
                SETTINGS_CONTROLS[#SETTINGS_CONTROLS+1] = control
            end
        end
    end
end

function addon:OnAddonLoaded(addonName)
    if self.name ~= addonName then return end

    self.savedVariables = ZO_SavedVars:NewAccountWide('ImpifiedUISavedVariables', 1, nil, DEFAULT_SETTINGS)

    self:SetupFeatures()
    self:SetupSettings()
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED, function(_, addonName) addon:OnAddonLoaded(addonName) end)

ImpifiedUI = addon