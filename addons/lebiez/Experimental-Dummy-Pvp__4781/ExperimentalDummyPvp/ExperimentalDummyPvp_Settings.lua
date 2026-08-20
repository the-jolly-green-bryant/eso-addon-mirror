local PDC = ExperimentalDummyPvp

function PDC:ApplyProfile(profile)
    local profiles = {
        ["Light"] = { targetResistance = 18000, extraMitigation = 0 },
        ["Balanced"] = { targetResistance = 26000, extraMitigation = 0 },
        ["Tank"] = { targetResistance = 33000, extraMitigation = 10 },
    }
    local values = profiles[profile]
    if not values then return end
    self.sv.targetResistance = values.targetResistance
    self.sv.extraMitigation = values.extraMitigation
    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", self.settingsPanel)
end

function PDC:CreateSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        d("|cE94B3CExperimental Dummy PvP: LibAddonMenu-2.0 is required.|r")
        return
    end

    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = "|cE94B3C" .. self.displayName .. "|r",
        author = "Bièz",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    self.settingsPanel = LAM:RegisterAddonPanel(self.name .. "Options", panelData)

    local options = {
        {
            type = "description",
            text = "Converts damage observed on a PvE dummy into a PvP estimate. The calculation first removes the dummy's estimated mitigation, then applies the simulated PvP target profile.",
        },
        {
            type = "checkbox", name = "Enable conversion",
            getFunc = function() return self.sv.enabled end,
            setFunc = function(v) self.sv.enabled = v end,
            default = self.defaults.enabled,
        },
        {
            type = "checkbox", name = "Restrict to NPC targets",
            tooltip = "Prevents conversion against players and player pets. ESO does not always provide a reliable way to distinguish every training dummy from other NPCs.",
            getFunc = function() return self.sv.onlyTrainingDummies end,
            setFunc = function(v) self.sv.onlyTrainingDummies = v end,
            default = self.defaults.onlyTrainingDummies,
        },
        { type = "header", name = "Profiles" },
        {
            type = "dropdown", name = "Apply a PvP profile",
            choices = { "Custom", "Light", "Balanced", "Tank" },
            getFunc = function() return "Custom" end,
            setFunc = function(v) self:ApplyProfile(v) end,
            default = "Custom",
        },
        { type = "header", name = "Mitigation and Resistance" },
        {
            type = "slider", name = "PvE dummy resistance (requires calibration with Two-Handed Ultimate)",
            tooltip = "Estimated resistance already included in the damage displayed on the dummy. Calibrate it using the Two-Handed Ultimate.",
            min = 0, max = 50000, step = 100,
            getFunc = function() return self.sv.dummyResistance end,
            setFunc = function(v) self.sv.dummyResistance = v end,
            default = self.defaults.dummyResistance,
        },
        {
            type = "slider", name = "PvP target resistance",
            min = 0, max = 50000, step = 100,
            getFunc = function() return self.sv.targetResistance end,
            setFunc = function(v) self.sv.targetResistance = v end,
            default = self.defaults.targetResistance,
        },
        {
            type = "slider", name = "Player penetration",
            tooltip = "Subtracted from both the dummy resistance and the simulated target resistance.",
            min = 0, max = 30000, step = 100,
            getFunc = function() return self.sv.penetration end,
            setFunc = function(v) self.sv.penetration = v end,
            default = self.defaults.penetration,
        },
        {
            type = "slider", name = "Battle Spirit reduction (%)",
            min = 0, max = 60, step = 1,
            getFunc = function() return self.sv.battleSpiritReduction end,
            setFunc = function(v) self.sv.battleSpiritReduction = v end,
            default = self.defaults.battleSpiritReduction,
        },
        {
            type = "slider", name = "Additional mitigation (%)",
            tooltip = "Additional reductions from buffs, passives, blocking or protection effects.",
            min = 0, max = 80, step = 1,
            getFunc = function() return self.sv.extraMitigation end,
            setFunc = function(v) self.sv.extraMitigation = v end,
            default = self.defaults.extraMitigation,
        },
        {
            type = "slider", name = "Resistance mitigation cap (%)",
            min = 0, max = 60, step = 1,
            getFunc = function() return self.sv.resistanceCap end,
            setFunc = function(v) self.sv.resistanceCap = v end,
            default = self.defaults.resistanceCap,
        },
        { type = "header", name = "Critical Resistance" },
        {
            type = "slider", name = "Attacker critical damage bonus (%)",
            tooltip = "The attacker's total critical damage bonus before Critical Resistance. The standard base value is 50%.",
            min = 0, max = 150, step = 1,
            getFunc = function() return self.sv.attackerCriticalDamage end,
            setFunc = function(v) self.sv.attackerCriticalDamage = v end,
            default = self.defaults.attackerCriticalDamage,
        },
        {
            type = "slider", name = "PvP target Critical Resistance",
            tooltip = "Only affects critical hits. Every 66 points remove 1 percentage point from the attacker's critical damage bonus.",
            min = 0, max = 6600, step = 66,
            getFunc = function() return self.sv.targetCriticalResistance end,
            setFunc = function(v) self.sv.targetCriticalResistance = v end,
            default = self.defaults.targetCriticalResistance,
        },
        { type = "header", name = "Display" },
        {
            type = "checkbox", name = "Show actual dummy damage",
            getFunc = function() return self.sv.showOriginal end,
            setFunc = function(v) self.sv.showOriginal = v end,
            default = self.defaults.showOriginal,
        },
        {
            type = "checkbox", name = "Show ability name",
            getFunc = function() return self.sv.showAbility end,
            setFunc = function(v) self.sv.showAbility = v end,
            default = self.defaults.showAbility,
        },
        {
            type = "slider", name = "Display duration (ms)",
            min = 300, max = 4000, step = 100,
            getFunc = function() return self.sv.displayDuration end,
            setFunc = function(v) self.sv.displayDuration = v end,
            default = self.defaults.displayDuration,
        },
        {
            type = "slider", name = "Display size (%)",
            min = 50, max = 200, step = 5,
            getFunc = function() return zo_round(self.sv.displayScale * 100) end,
            setFunc = function(v) self.sv.displayScale = v / 100 end,
            default = self.defaults.displayScale * 100,
        },
        {
            type = "checkbox", name = "Debug log",
            getFunc = function() return self.sv.debug end,
            setFunc = function(v) self.sv.debug = v end,
            default = self.defaults.debug,
        },
        {
            type = "button", name = "Open summary",
            func = function() self:ShowSummary() end,
            width = "half",
        },
        {
            type = "button", name = "Reset session",
            func = function() self:ResetSession() end,
            width = "half",
        },
    }

    LAM:RegisterOptionControls(self.name .. "Options", options)
end
