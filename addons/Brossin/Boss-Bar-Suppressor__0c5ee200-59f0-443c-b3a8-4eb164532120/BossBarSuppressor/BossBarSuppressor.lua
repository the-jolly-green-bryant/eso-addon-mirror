local ADDON_NAME = "BossBarSuppressor"
local BossBarSuppressor = {}
local SV

-- Default settings
local defaults = {
    HideBossHealth = true,
    ShowOverheadCompass = true,
}

-- Safely get LibHarvensAddonSettings (LAM)
local function GetLAM()
    if LibHarvensAddonSettings then
        return LibHarvensAddonSettings
    else
        d(ADDON_NAME .. ": LibHarvensAddonSettings not loaded, skipping settings panel.")
        return nil
    end
end

-- Refresh compass safely
local function RefreshCompass()
    if ZO_Compass then
        ZO_Compass:RefreshPosition()
    end
    if ZO_CompassFrame then
        ZO_CompassFrame:RefreshVisibleMapPins()
        ZO_CompassFrame:SetHidden(true)
        ZO_CompassFrame:SetHidden(false)
    end
end

-- Apply current settings safely
local function ApplySettings()
    if ZO_BossBar then
        ZO_BossBar:SetHidden(SV.HideBossHealth)
        if SV.HideBossHealth then
            ZO_BossBar:SetHandler("OnShow", function(self) self:SetHidden(true) end)
        else
            ZO_BossBar:SetHandler("OnShow", nil)
        end
    end

    if ZO_CompassFrame then
        ZO_CompassFrame:SetHidden(not SV.ShowOverheadCompass)
        RefreshCompass()
    end
end

-- Create settings panel safely
local function CreateSettingsPanel()
    local LAM = GetLAM()
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Boss Bar Suppressor",
        displayName = "|c00BFFF" .. ADDON_NAME,
        author = "Brossin",
        version = "1.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "checkbox",
            name = "Hide Boss Health Bar",
            tooltip = "Toggle hiding the top boss health bar",
            getFunc = function() return SV.HideBossHealth end,
            setFunc = function(value)
                SV.HideBossHealth = value
                ApplySettings()
            end,
            width = "full",
            default = defaults.HideBossHealth,
        },
        {
            type = "checkbox",
            name = "Show Overhead Compass",
            tooltip = "Toggle showing the overhead compass with full directions and map markers",
            getFunc = function() return SV.ShowOverheadCompass end,
            setFunc = function(value)
                SV.ShowOverheadCompass = value
                ApplySettings()
            end,
            width = "full",
            default = defaults.ShowOverheadCompass,
        },
    }

    LAM:RegisterAddonPanel(ADDON_NAME .. "OptionsPanel", panelData)
    LAM:RegisterOptionControls(ADDON_NAME .. "OptionsPanel", optionsTable)
end

-- Event: AddOn Loaded
function BossBarSuppressor.OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    SV = ZO_SavedVars:NewAccountWide("BossBarSuppressor_SavedVars", 1, nil, defaults)

    CreateSettingsPanel()
    ApplySettings()

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, BossBarSuppressor.OnAddOnLoaded)
