TrialRecorder = TrialRecorder or {}
local TR = TrialRecorder

TR.Menu = TR.Menu or {}
local Menu = TR.Menu

local GOLD = "|cD9B66F"
local RESET = "|r"

function Menu:Register()
    if self.registered then
        return true
    end

    local settingsLibrary = LibHarvensAddonSettings
    if not settingsLibrary or type(settingsLibrary.AddAddon) ~= "function" then
        return false
    end

    local panel = settingsLibrary:AddAddon(TR.DISPLAY_NAME, {
        allowDefaults = false,
        allowRefresh = false,
    })

    if not panel then
        return false
    end

    panel:AddSetting({
        type = settingsLibrary.ST_LABEL,
        label = GOLD .. "Every clear counts." .. RESET,
    })

    panel:AddSetting({
        type = settingsLibrary.ST_LABEL,
        label = GOLD .. "A BMG Addon" .. RESET,
    })

    panel:AddSetting({
        type = settingsLibrary.ST_LABEL,
        label = GOLD .. "Created and maintained by @BMGXSANCHO" .. RESET,
    })

    panel:AddSetting({
        type = settingsLibrary.ST_SECTION,
        label = "Active Timer",
    })

    panel:AddSetting({
        type = settingsLibrary.ST_CHECKBOX,
        label = "Enable Active Timer",
        tooltip = "Show ESO's live raid timer while a scored trial is in progress.",
        getFunction = function()
            return TR.sv.settings.activeTimerEnabled == true
        end,
        setFunction = function(value)
            TR.sv.settings.activeTimerEnabled = value == true
            TR.Timer:ApplySettings()
        end,
        default = true,
    })

    panel:AddSetting({
        type = settingsLibrary.ST_SLIDER,
        label = "Horizontal Position",
        tooltip = "Move the timer left or right on the screen.",
        min = 5,
        max = 95,
        step = 1,
        format = "%.0f",
        unit = "%",
        getFunction = function()
            return TR.sv.settings.activeTimerX or 50
        end,
        setFunction = function(value)
            TR.sv.settings.activeTimerX = value
            TR.Timer:ApplySettings(true)
        end,
        default = 50,
    })

    panel:AddSetting({
        type = settingsLibrary.ST_SLIDER,
        label = "Vertical Position",
        tooltip = "Move the timer up or down on the screen.",
        min = 5,
        max = 95,
        step = 1,
        format = "%.0f",
        unit = "%",
        getFunction = function()
            return TR.sv.settings.activeTimerY or 12
        end,
        setFunction = function(value)
            TR.sv.settings.activeTimerY = value
            TR.Timer:ApplySettings(true)
        end,
        default = 12,
    })

    panel:AddSetting({
        type = settingsLibrary.ST_SLIDER,
        label = "Timer Scale",
        tooltip = "Adjust the size of the live timer.",
        min = 0.75,
        max = 1.50,
        step = 0.05,
        format = "%.2f",
        getFunction = function()
            return TR.sv.settings.activeTimerScale or 1.0
        end,
        setFunction = function(value)
            TR.sv.settings.activeTimerScale = value
            TR.Timer:ApplySettings(true)
        end,
        default = 1.0,
    })

    panel:AddSetting({
        type = settingsLibrary.ST_BUTTON,
        label = "Timer Position",
        buttonText = "Reset Position",
        tooltip = "Restore the Active Timer to its default position and size.",
        clickHandler = function()
            TR.sv.settings.activeTimerX = 50
            TR.sv.settings.activeTimerY = 12
            TR.sv.settings.activeTimerScale = 1.0
            TR.Timer:ApplySettings(true)
        end,
    })

    panel:AddSetting({
        type = settingsLibrary.ST_SECTION,
        label = "Trial Records",
    })

    for _, trial in ipairs(TR.Trials) do
        local trialKey = trial.key
        panel:AddSetting({
            type = settingsLibrary.ST_BUTTON,
            label = trial.name,
            buttonText = "View Record",
            tooltip = "View recorded veteran and Hard Mode clears, scores, times, dates, and personal records for " .. trial.name .. ".",
            clickHandler = function()
                TR.UI:ShowTrial(trialKey)
            end,
        })
    end

    self.panel = panel
    self.registered = true
    return true
end

function Menu:RegisterWhenAvailable()
    if self:Register() then
        return
    end

    local attempts = 0
    EVENT_MANAGER:RegisterForUpdate("TrialRecorder_MenuRegistration", 250, function()
        attempts = attempts + 1

        if Menu:Register() or attempts >= 40 then
            EVENT_MANAGER:UnregisterForUpdate("TrialRecorder_MenuRegistration")
        end
    end)
end
