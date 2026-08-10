-- Optional bonus: Settings -> Add-Ons panel when LibHarvensAddonSettings is present.

local AddonMenu = {}
local DR = DolmenRunner
local panel = nil

local function HasLibrary()
    return LibHarvensAddonSettings ~= nil
end

local function RunnerStatusText()
    return DR.runner.started and "|c33FF33Running|r (" .. DR.runner:GetDirectionLabel() .. ")" or "|cFF3333Stopped|r"
end

function AddonMenu:IsRegistered()
    return panel ~= nil
end

function AddonMenu:HasLibrary()
    return HasLibrary()
end

function AddonMenu:Register()
    if panel or not HasLibrary() then
        return false
    end

    local LHAS = LibHarvensAddonSettings
    panel = LHAS:AddAddon(DR.displayName, {
        allowDefaults = true,
        defaultsFunction = function()
            DR.settings.runner = ZO_ShallowTableCopy(DR.defaults.runner)
            DR:RefreshSettings()
            panel:RefreshSettings()
            DR:Log("Settings reset to defaults.")
        end,
        allowRefresh = true,
    })

    panel:AddSetting({
        type = LHAS.ST_SECTION,
        label = "Runner",
    })

    panel:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Runner",
        buttonText = function()
            return DR.runner.started and "Stop" or "Start"
        end,
        tooltip = "Start or stop automatic dolmen wayshrine routing.",
        clickHandler = function()
            DR.runner:StartStop()
            panel:RefreshSettings()
        end,
    })

    panel:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Direction",
        buttonText = function()
            return DR.runner:GetDirectionLabel()
        end,
        tooltip = "Toggle clockwise / counter-clockwise routing.",
        clickHandler = function()
            DR.runner:CWCCW()
            panel:RefreshSettings()
        end,
    })

    panel:AddSetting({
        type = LHAS.ST_LABEL,
        label = function()
            return "Status: " .. RunnerStatusText()
        end,
        tooltip = "Current runner state.",
    })

    panel:AddSetting({
        type = LHAS.ST_SECTION,
        label = "Runner options",
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Auto travel",
        tooltip = "Automatically fast-travel to the next dolmen wayshrine.",
        getFunction = function() return DR.settings.runner.autoTravel end,
        setFunction = function(value)
            DR.settings.runner.autoTravel = value
            DR:RefreshSettings()
        end,
        default = DR.defaults.runner.autoTravel,
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Dismiss assistants in combat",
        tooltip = "Dismiss non-combat assistants when you enter combat.",
        getFunction = function() return DR.settings.runner.autoDismiss end,
        setFunction = function(value)
            DR.settings.runner.autoDismiss = value
            DR:RefreshSettings()
        end,
        default = DR.defaults.runner.autoDismiss,
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Reapply XP buff",
        tooltip = "Reapply experience scroll or ambrosia when the buff expires.",
        getFunction = function() return DR.settings.runner.reapplyBuff end,
        setFunction = function(value)
            DR.settings.runner.reapplyBuff = value
            DR:RefreshSettings()
        end,
        default = DR.defaults.runner.reapplyBuff,
    })

    return true
end

function AddonMenu:Initialize()
    if not HasLibrary() then
        EVENT_MANAGER:RegisterForEvent(DR.name .. "_LHAS", EVENT_ADD_ON_LOADED, function(_, addonName)
            if addonName ~= "LibHarvensAddonSettings" then
                return
            end
            EVENT_MANAGER:UnregisterForEvent(DR.name .. "_LHAS", EVENT_ADD_ON_LOADED)
            self:Register()
        end)
        return
    end

    self:Register()
end

DolmenRunner.addonMenu = AddonMenu