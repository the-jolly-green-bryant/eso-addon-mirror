local AA = Archaeology

local function ClampLeadAgeDays(value)
    local days = tonumber(value) or AA.defaults.loginMaxLeadAgeDays
    days = math.floor(days)
    if days < 1 then
        return 1
    end
    if days > 30 then
        return 30
    end
    return days
end

function AA:ApplySavedSettings()
    local days = self.defaults.loginMaxLeadAgeDays
    local autoLoginSummaryEnabled = self.defaults.autoLoginSummaryEnabled
    local autoZoneSummaryEnabled = self.defaults.autoZoneSummaryEnabled

    if type(self.savedVariables) == "table" then
        days = ClampLeadAgeDays(self.savedVariables.loginMaxLeadAgeDays)
        autoLoginSummaryEnabled = self.savedVariables.autoLoginSummaryEnabled ~= false
        autoZoneSummaryEnabled = self.savedVariables.autoZoneSummaryEnabled ~= false

        self.savedVariables.loginMaxLeadAgeDays = days
        self.savedVariables.autoLoginSummaryEnabled = autoLoginSummaryEnabled
        self.savedVariables.autoZoneSummaryEnabled = autoZoneSummaryEnabled
    end

    self.loginMaxLeadAgeDays = days
    self.loginMaxLeadAgeSeconds = days * 24 * 60 * 60
    self.autoLoginSummaryEnabled = autoLoginSummaryEnabled
    self.autoZoneSummaryEnabled = autoZoneSummaryEnabled
end

function AA:InitializeSavedVariables()
    if type(ZO_SavedVars) ~= "table" or type(ZO_SavedVars.NewAccountWide) ~= "function" then
        self.savedVariables = nil
        self:ApplySavedSettings()
        return
    end

    self.savedVariables = ZO_SavedVars:NewAccountWide("ArchaeologySavedVariables", 1, nil, self.defaults)
    self:ApplySavedSettings()
end

function AA:RegisterAddonMenu()
    local LHAS = LibHarvensAddonSettings
    if not LHAS then
        self:Print("LibHarvensAddonSettings not found. Settings panel is disabled.")
        return
    end

    local panel = LHAS:AddAddon("Archaeology", {
        allowDefaults = true,
        allowRefresh = true,
    })
    if not panel or type(panel.AddSetting) ~= "function" then
        self:Print("LibHarvensAddonSettings panel could not be created.")
        return
    end

    panel:AddSetting({
        type = LHAS.ST_SECTION,
        label = "Login Summary",
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Automatic Login Message",
        default = self.defaults.autoLoginSummaryEnabled,
        getFunction = function()
            return self.autoLoginSummaryEnabled
        end,
        setFunction = function(value)
            local enabled = value == true
            if type(self.savedVariables) == "table" then
                self.savedVariables.autoLoginSummaryEnabled = enabled
            end
            self:ApplySavedSettings()
        end,
    })

    panel:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Max Lead Age (days)",
        tooltip = "Only leads expiring within this many days are shown in the automatic login summary.",
        min = 1,
        max = 30,
        step = 1,
        unit = " days",
        default = self.defaults.loginMaxLeadAgeDays,
        getFunction = function()
            return self.loginMaxLeadAgeDays
        end,
        setFunction = function(value)
            local days = ClampLeadAgeDays(value)
            if type(self.savedVariables) == "table" then
                self.savedVariables.loginMaxLeadAgeDays = days
            end
            self:ApplySavedSettings()
        end,
    })

    panel:AddSetting({
        type = LHAS.ST_SECTION,
        label = "Zone Summary",
    })

    panel:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Automatic Zone Message",
        default = self.defaults.autoZoneSummaryEnabled,
        getFunction = function()
            return self.autoZoneSummaryEnabled
        end,
        setFunction = function(value)
            local enabled = value == true
            if type(self.savedVariables) == "table" then
                self.savedVariables.autoZoneSummaryEnabled = enabled
            end
            self:ApplySavedSettings()
        end,
    })
end
