-- LeadReminder.lua
-- Main addon module for antiquity lead expiration alerts

local ADDON_NAME = "LeadReminder"
local ADDON_VERSION = "1.0.2"
local ADDON_SAVED_VARS_NAME = "LeadReminderSavedVars"
local ADDON_AUTHOR = "aronsini"
local ADDON_DISPLAY_NAME = "Lead Reminder"
local ADDON_SLASH_ADDON = "/leadreminder" -- comand to open settings panel
local ADDON_SETTINGS_DISPLAY_NAME = "Lead Reminder - Settings"


local LeadReminder = {
    name = ADDON_NAME,
    version = ADDON_VERSION,
    author = ADDON_AUTHOR,
    settings = nil,
    alreadyNotifiedLeads = {}, -- prevent duplicate alerts
    settingsPanel = nil,       -- reference to settings control for LibHarvensAddonSettings
}

local DEFAULT_SETTINGS = {
    enabled = true,
    alertDays = 5,
    minDifficulty = ANTIQUITY_DIFFICULTY_INTERMEDIATE, -- Default to Simple (1)
    checkIntervalMinutes = 30,                         -- Default periodic check every 30 minutes
}

local DIFFICULTY_LABELS = {
    { name = "Trivial",      data = ANTIQUITY_DIFFICULTY_TRIVIAL },
    { name = "Simple",       data = ANTIQUITY_DIFFICULTY_SIMPLE },
    { name = "Intermediate", data = ANTIQUITY_DIFFICULTY_INTERMEDIATE },
    { name = "Advanced",     data = ANTIQUITY_DIFFICULTY_ADVANCED },
    { name = "Master",       data = ANTIQUITY_DIFFICULTY_MASTER },
    { name = "Ultimate",     data = ANTIQUITY_DIFFICULTY_ULTIMATE }
}

function LeadReminder:OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    self.settings = ZO_SavedVars:NewAccountWide(ADDON_SAVED_VARS_NAME, 1, nil, DEFAULT_SETTINGS)
    self.alreadyNotifiedLeads = {}

    self:InitSettings()
    self:RegisterEvents()
    self:StartPeriodicCheck()
end

function LeadReminder:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        self:CheckAllAntiquities()
    end)
end

function LeadReminder:StartPeriodicCheck()
    local intervalMs = self.settings.checkIntervalMinutes * 60 * 1000
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_PeriodicCheck", intervalMs, function()
        self:CheckAllAntiquities()
    end)
end

function LeadReminder:CheckAllAntiquities()
    local antiquityId = GetNextAntiquityId()
    while antiquityId do
        self:CheckSingleAntiquity(antiquityId)
        antiquityId = GetNextAntiquityId(antiquityId) -- Get next antiquity ID
    end
end

---@param antiquityId integer
function LeadReminder:CheckSingleAntiquity(antiquityId)
    if not self.settings.enabled then return end
    if self.alreadyNotifiedLeads[antiquityId] then
        -- if is expired is removed from the list
        if GetAntiquityLeadTimeRemainingSeconds(antiquityId) <= 0 then
            self.alreadyNotifiedLeads[antiquityId] = nil
        else
            return -- already notified, skip further checks
        end
    end

    -- Verify if antiquity difficulty is valid
    local difficulty = GetAntiquityDifficulty(antiquityId)
    if not difficulty then
        d(string.format("[LeadReminder] Antiquity ID %d has no difficulty set. Skipping.", antiquityId))
        return
    end
    if difficulty < self.settings.minDifficulty then return end

    -- Check if lead is active and has a valid expiration time
    local remainingSecs = GetAntiquityLeadTimeRemainingSeconds(antiquityId)
    if not remainingSecs or remainingSecs < 0 then return end

    local daysLeft = math.floor(remainingSecs / 86400)
    if daysLeft <= self.settings.alertDays then
        local name = GetAntiquityName(antiquityId)
        if not name or name == "" then
            d(string.format("[LeadReminder] Antiquity ID %d has no name set. Skipping.", antiquityId))
            return
        end
        local remainingTimeMsg = ZO_FormatTimeLargestTwo(remainingSecs, TIME_FORMAT_STYLE_DESCRIPTIVE)
        local message = string.format("[LeadReminder] Lead '%s' (Difficulty: %s) expires in %s",
            name,
            DIFFICULTY_LABELS[difficulty].name,
            remainingTimeMsg
        )
        CHAT_SYSTEM:AddMessage(message)
        self.alreadyNotifiedLeads[antiquityId] = true
    end
end

function SetDefaultSettings()
    LeadReminder.settings.alertDays = DEFAULT_SETTINGS.alertDays
    LeadReminder.settings.minDifficulty = DEFAULT_SETTINGS.minDifficulty
    LeadReminder.settings.checkIntervalMinutes = DEFAULT_SETTINGS.checkIntervalMinutes
    LeadReminder.settings.enabled = DEFAULT_SETTINGS.enabled
    LeadReminder.alreadyNotifiedLeads = {} -- reset notifications
    LeadReminder:CheckAllAntiquities()     -- recheck all leads
end

function InitSettings()
    local LibHarvensAddonSettings = LibHarvensAddonSettings
    if not LibHarvensAddonSettings then
        d("[LeadReminder] LibHarvensAddonSettings not found. Please install it to use settings.")
        return
    end

    local options = {
        allowDefaults = true,
        allowRefresh = false,
        defaultsFunction = function() SetDefaultSettings() end
    }

    local panel = LibHarvensAddonSettings:AddAddon(ADDON_SETTINGS_DISPLAY_NAME, options)
    if not panel then
        d(string.format("[LeadReminder] Failed to create settings panel for %s", ADDON_DISPLAY_NAME))
        return
    end

    LeadReminder.settingsPanel = panel
    panel.allowDefaults = true
    panel.version = LeadReminder.version

    panel:AddSetting {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Enable addon",
        tooltip = "Enable or disable LeadReminder alerts.",
        default = DEFAULT_SETTINGS.enabled,
        getFunction = function()
            return LeadReminder.settings.enabled
        end,
        setFunction = function(value)
            LeadReminder.settings.enabled = value
        end
    }

    panel:AddSetting {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Alert days",
        tooltip = "How many days before expiration to alert.",
        default = DEFAULT_SETTINGS.alertDays,
        format = "%.0f", -- No decimal places
        unit = " days",
        min = 1,
        max = 30,
        step = 1,
        getFunction = function()
            return LeadReminder.settings.alertDays
        end,
        setFunction = function(value)
            LeadReminder.settings.alertDays = value
            LeadReminder.alreadyNotifiedLeads = {} -- reset notifications when changing alert days
            LeadReminder:CheckAllAntiquities()     -- recheck all leads
        end
    }

    panel:AddSetting {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Check Interval (minutes)",
        tooltip = "How often to check for expiring leads.",
        default = DEFAULT_SETTINGS.checkIntervalMinutes,
        format = "%.0f", -- No decimal places
        unit = " minutes",
        min = 5,
        max = 120,
        step = 5,
        getFunction = function()
            return LeadReminder.settings.checkIntervalMinutes
        end,
        setFunction = function(value)
            LeadReminder.settings.checkIntervalMinutes = value
            EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_PeriodicCheck")
            LeadReminder:StartPeriodicCheck() -- restart periodic check with new interval
        end
    }

    panel:AddSetting {
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Minimum lead difficulty",
        tooltip = "Only show alerts for leads of this difficulty or higher.",
        items = DIFFICULTY_LABELS,
        default = DIFFICULTY_LABELS[DEFAULT_SETTINGS.minDifficulty].name,
        getFunction = function()
            return DIFFICULTY_LABELS[LeadReminder.settings.minDifficulty].name
        end,
        setFunction = function(control, itemName, itemData)
            LeadReminder.settings.minDifficulty = itemData
            LeadReminder.alreadyNotifiedLeads = {} -- reset notifications when changing difficulty
            LeadReminder:CheckAllAntiquities()     -- recheck all leads
        end
    }
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, LeadReminder.OnAddOnLoaded)
