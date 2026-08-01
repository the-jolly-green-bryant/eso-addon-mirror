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
