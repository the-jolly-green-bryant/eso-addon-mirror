local BEV = BetterEffectViewer

function BEV:EnsureSavedVarSchema()
    local defaults = self.defaults

    self.sv.filterMode = self.sv.filterMode or defaults.filterMode
    self.sv.autoWhitelistDuration = self.sv.autoWhitelistDuration or defaults.autoWhitelistDuration
    self.sv.targetSwitchDelay = self.sv.targetSwitchDelay or defaults.targetSwitchDelay
    self.sv.reticleHoldDuration = self.sv.reticleHoldDuration or defaults.reticleHoldDuration
    self.sv.performanceMode = self.sv.performanceMode or defaults.performanceMode
    self.sv.fallbackRescanInterval = self.sv.fallbackRescanInterval or defaults.fallbackRescanInterval
    self.sv.autoConsoleTuning = self.sv.autoConsoleTuning
    if self.sv.autoConsoleTuning == nil then
        self.sv.autoConsoleTuning = defaults.autoConsoleTuning
    end
    self.sv.consoleSlotRowsCap = self.sv.consoleSlotRowsCap or defaults.consoleSlotRowsCap
    self.sv.consoleEffectCap = self.sv.consoleEffectCap or defaults.consoleEffectCap
    self.sv.consoleMaxColsCap = self.sv.consoleMaxColsCap or defaults.consoleMaxColsCap

    self.sv.whitelist = self.sv.whitelist or {}
    self.sv.blacklist = self.sv.blacklist or {}

    if self.sv.pveLayout and self.sv.pveLayout.whitelist then
        for abilityId, isEnabled in pairs(self.sv.pveLayout.whitelist) do
            if isEnabled then
                self.sv.whitelist[abilityId] = true
            end
        end
        self.sv.pveLayout.whitelist = nil
    end

    if self.sv.pveLayout and self.sv.pveLayout.blacklist then
        for abilityId, isEnabled in pairs(self.sv.pveLayout.blacklist) do
            if isEnabled then
                self.sv.blacklist[abilityId] = true
            end
        end
        self.sv.pveLayout.blacklist = nil
    end

    if next(self.sv.whitelist) == nil then
        for abilityId, isEnabled in pairs(defaults.whitelist) do
            if isEnabled then
                self.sv.whitelist[abilityId] = true
            end
        end
    end

    if next(self.sv.blacklist) == nil then
        for abilityId, isEnabled in pairs(defaults.blacklist) do
            if isEnabled then
                self.sv.blacklist[abilityId] = true
            end
        end
    end

    self.sv.pveLayout = self.sv.pveLayout or {}
    self.sv.pvpLayout = self.sv.pvpLayout or {}

    self.sv.pveLayout.iconSize = self.sv.pveLayout.iconSize or defaults.pveLayout.iconSize
    self.sv.pveLayout.fontSize = self.sv.pveLayout.fontSize or defaults.pveLayout.fontSize
    self.sv.pveLayout.maxCols = self.sv.pveLayout.maxCols or defaults.pveLayout.maxCols

    self.sv.pvpLayout.iconSize = self.sv.pvpLayout.iconSize or defaults.pvpLayout.iconSize
    self.sv.pvpLayout.fontSize = self.sv.pvpLayout.fontSize or defaults.pvpLayout.fontSize
    self.sv.pvpLayout.maxCols = self.sv.pvpLayout.maxCols or defaults.pvpLayout.maxCols
end
