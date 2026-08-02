local C = Conductor
local SRC = SupportRotationCallouts
SRC.BurnWindowGuide = SRC.BurnWindowGuide or {}
C.BurnWindowGuide = SRC.BurnWindowGuide
local Guide = SRC.BurnWindowGuide

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Copy(item) end
    return result
end

local function Key(value)
    return string.upper(tostring(value or "")):gsub("[^A-Z0-9]+", "_")
end

Guide.WINDOW_TYPES = {
    HOLD = true,
    CONTROLLED_PUSH = true,
    SPAMMABLES_ONLY = true,
    PREPARE_BURN = true,
    FULL_BURN = true,
    EXECUTE = true,
    RECOVERY = true,
}

Guide.DEFAULTS = {
    opening = {
        id = "OPENING_BURN",
        type = "FULL_BURN",
        label = "OPENING BURN",
        trigger = { type="ENCOUNTER_STATE", state="OPENING" },
        once = true,
        confidence = "FOUNDATION",
    },
    execute = {
        id = "EXECUTE_BURN",
        type = "EXECUTE",
        label = "EXECUTE",
        trigger = { type="BOSS_HEALTH", percent=25 },
        once = true,
        confidence = "FOUNDATION",
    },
}

function Guide:NormalizeWindow(source, index, profile)
    source = Copy(source or {})
    source.id = Key(source.id or ((profile and profile.id or "ENCOUNTER") .. "_WINDOW_" .. tostring(index)))
    source.type = Key(source.type or source.instruction or "FULL_BURN")
    source.label = source.label or source.type:gsub("_", " ")
    source.priority = Key(source.priority or ((source.type == "HOLD" or source.type == "SPAMMABLES_ONLY") and "CRITICAL" or "ENCOUNTER"))
    source.once = source.once ~= false
    source.trigger = Copy(source.trigger or { type="SIGNAL", key=source.id })
    source.releaseSignal = Key(source.releaseSignal or source.waitForSignal or "")
    source.completeSignal = Key(source.completeSignal or "")
    source.cancelSignals = Copy(source.cancelSignals or {})
    source.requiredState = source.requiredState and Key(source.requiredState) or nil
    source.expectedDurationSeconds = tonumber(source.expectedDurationSeconds) or nil
    source.prewarnSeconds = tonumber(source.prewarnSeconds) or 3
    source.targetHealth = tonumber(source.targetHealth) or nil
    source.strategy = source.strategy and Key(source.strategy) or nil
    source.confidence = Key(source.confidence or "FOUNDATION")
    return source
end

function Guide:GetWindows(profile, strategy)
    if type(profile) ~= "table" then return {} end
    strategy = Key(strategy or "AUTOMATIC")
    local source = profile.burnWindowGuide or profile.burnWindows or {}
    local output = {}

    for index, window in ipairs(source) do
        local normalized = self:NormalizeWindow(window, index, profile)
        if not normalized.strategy or normalized.strategy == strategy or normalized.strategy == "AUTOMATIC" then
            output[#output + 1] = normalized
        end
    end

    -- Foundation profiles receive only an objective execute window. They never
    -- receive repeating speculative burn cycles.
    if #output == 0 then
        local executePercent = nil
        for _, signal in ipairs(profile.observationSignals and profile.observationSignals.health or {}) do
            if Key(signal.key) == "EXECUTE" then executePercent = tonumber(signal.percent or signal.value); break end
        end
        if executePercent then
            local execute = Copy(self.DEFAULTS.execute)
            execute.id = Key((profile.id or "ENCOUNTER") .. "_EXECUTE")
            execute.trigger.percent = executePercent
            output[#output + 1] = self:NormalizeWindow(execute, 1, profile)
        end
    end
    return output
end

function Guide:Validate(profile)
    local report = { valid=true, errors={}, warnings={}, count=0 }
    local seen = {}
    for _, window in ipairs(self:GetWindows(profile, "AUTOMATIC")) do
        report.count = report.count + 1
        if seen[window.id] then
            report.valid = false
            report.errors[#report.errors + 1] = "Duplicate burn window ID: " .. tostring(window.id)
        end
        seen[window.id] = true
        if not self.WINDOW_TYPES[window.type] then
            report.valid = false
            report.errors[#report.errors + 1] = "Unknown burn window type: " .. tostring(window.type)
        end
        if not window.trigger then
            report.valid = false
            report.errors[#report.errors + 1] = "Window has no trigger: " .. tostring(window.id)
        end
        if window.confidence == "FOUNDATION" then
            report.warnings[#report.warnings + 1] = tostring(window.id) .. " requires live validation"
        end
    end
    return report
end

function Guide:Initialize()
    self.initialized = true
end
