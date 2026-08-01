local BEV = BetterEffectViewer

local function clampInt(value, minValue, maxValue, fallback)
    local n = math.floor(tonumber(value) or fallback)
    if n < minValue then
        return minValue
    end
    if n > maxValue then
        return maxValue
    end
    return n
end

local function clampNumber(value, minValue, maxValue, fallback)
    local n = tonumber(value) or fallback
    if n < minValue then
        return minValue
    end
    if n > maxValue then
        return maxValue
    end
    return n
end

function BEV:IsXboxPlatform()
    if IsConsoleUI == nil or not IsConsoleUI() then
        return false
    end

    if GetPlatformServiceType ~= nil and PLATFORM_SERVICE_XBOX ~= nil then
        return GetPlatformServiceType() == PLATFORM_SERVICE_XBOX
    end

    return true
end

function BEV:ApplyRuntimePlatformTuning()
    self.runtimeSlotRows = nil
    self.runtimeEffectCap = nil
    self.runtimeMaxColsCap = nil
    self.runtimePerformanceMode = nil
    self.runtimeRescanInterval = nil

    if not self.sv.autoConsoleTuning then
        return
    end

    if self:IsXboxPlatform() then
        -- Xbox-friendly memory profile with user-tunable caps.
        self.runtimeSlotRows = clampInt(self.sv.consoleSlotRowsCap, 1, 256, self.defaults.consoleSlotRowsCap)
        self.runtimeEffectCap = clampInt(self.sv.consoleEffectCap, 1, 256, self.defaults.consoleEffectCap)
        self.runtimeMaxColsCap = clampInt(self.sv.consoleMaxColsCap, 1, 256, self.defaults.consoleMaxColsCap)
        self.runtimeRescanInterval = clampNumber(self.sv.fallbackRescanInterval, 0.5, 5.0, self.defaults.fallbackRescanInterval)
        self.runtimePerformanceMode = "ultra"
    end
end
