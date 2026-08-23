local Addon = LarvalTearMod
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext

local function CloneTableShallow(source)
    -- Shallow copy only: nested build sections such as skills, equipment,
    -- and subclass remain shared with the source build. Use this only for
    -- top-level replacement, not for mutating nested tables.
    local clone = {}
    for key, value in pairs(source or {}) do
        clone[key] = value
    end
    return clone
end

local function CloneRunOptions(options)
    return CloneTableShallow(options)
end

local function AppendUniqueString(target, seen, value)
    if type(value) ~= "string" or value == "" or seen[value] then
        return
    end

    seen[value] = true
    target[#target + 1] = value
end

local function AppendResidualSummary(entry, residualSummary)
    if type(residualSummary) ~= "table" then
        return
    end

    entry.residualSummaries = entry.residualSummaries or {}
    for _, existing in ipairs(entry.residualSummaries) do
        if existing == residualSummary then
            return
        end
    end

    entry.residualSummaries[#entry.residualSummaries + 1] = residualSummary
    if type(entry.residualSummary) ~= "table" then
        entry.residualSummary = residualSummary
        return
    end

    local merged = CloneTableShallow(entry.residualSummary)
    for key, value in pairs(residualSummary) do
        merged[key] = value
    end
    entry.residualSummary = merged
end

local function RefreshPartialSuccessCompatibilityView(context)
    context.partialSuccessResult = nil
    local transformFallback = nil
    for _, entry in ipairs(context.domainResults or {}) do
        if entry.severity == "partial" then
            local compatibilityEntry = {
                sourcePhase = entry.sourcePhase,
                resultCode = entry.resultCode,
                reasons = entry.reasons,
                residualSummary = entry.residualSummary,
            }
            if entry.domain ~= "TransformSkills" then
                context.partialSuccessResult = compatibilityEntry
                return
            end
            transformFallback = transformFallback or compatibilityEntry
        end
    end
    context.partialSuccessResult = transformFallback
end

local SKILL_SETTINGS_TARGET_NORMAL_SKILLS = "normal_skill_changes"
local SKILL_SETTINGS_TARGET_NORMAL_PASSIVES = "normal_passive_changes"

local function ResolveSkillSettings(context)
    return context.runOptions.skillSettings
end

local function ResolveSkillSettingsReason(settings, target)
    if target == SKILL_SETTINGS_TARGET_NORMAL_SKILLS then
        return settings.activeAction == "skip_all"
            and "skill_settings_skip_all"
            or nil
    end

    if target ~= SKILL_SETTINGS_TARGET_NORMAL_PASSIVES then
        return nil
    end

    if settings.activeAction == "skip_all" then
        return "skill_settings_skip_all"
    end
    if settings.passiveAction ~= "skip_passive_changes" then
        return nil
    end
    if settings.passiveShortage == "all_or_nothing" then
        return "skill_settings_passive_all_or_nothing_skipped"
    end

    return nil
end

local function ResolveCharacterId()
    if type(GetCurrentCharacterId) == "function" then
        local ok, characterId = pcall(GetCurrentCharacterId)
        if ok then
            return characterId
        end
    end

    return nil
end

local function ResolveBaseClassId()
    if type(GetUnitClassId) == "function" then
        local ok, classId = pcall(GetUnitClassId, "player")
        if ok then
            return classId
        end
    end

    return nil
end

function LTM_PIPELINE_CONTEXT:Create(build, options)
    options = type(options) == "table" and options or {}
    local runOptions = CloneRunOptions(options)
    return {
        characterId = ResolveCharacterId(),
        baseClassId = ResolveBaseClassId(),
        targetBuild = build,
        currentState = {},
        runtime = {},
        phaseResults = {},
        domainResults = {},
        _domainResultIndexByDomain = {},
        _domainResultReasonSets = {},
        resolvedPlan = nil,
        cancelRequested = false,
        cancelReason = nil,
        cancelRequestedAtPhase = nil,
        partialScope = runOptions.partialScope,
        preflightMode = runOptions.preflightMode,
        onPhaseUpdate = type(runOptions.onPhaseUpdate) == "function" and runOptions.onPhaseUpdate or nil,
        onStatusUpdate = type(runOptions.onStatusUpdate) == "function" and runOptions.onStatusUpdate or nil,
        runOptions = runOptions,
    }
end

function LTM_PIPELINE_CONTEXT:RecordDomainResult(context, result)
    if type(context) ~= "table" or type(result) ~= "table" then
        return nil
    end

    local domain = result.domain or result.sourcePhase
    if type(domain) ~= "string" or domain == "" then
        return nil
    end

    context.domainResults = type(context.domainResults) == "table" and context.domainResults or {}
    context._domainResultIndexByDomain = type(context._domainResultIndexByDomain) == "table"
        and context._domainResultIndexByDomain
        or {}
    context._domainResultReasonSets = type(context._domainResultReasonSets) == "table"
        and context._domainResultReasonSets
        or {}

    local entryIndex = context._domainResultIndexByDomain[domain]
    local entry = entryIndex ~= nil and context.domainResults[entryIndex] or nil
    if type(entry) ~= "table" then
        entry = {
            domain = domain,
            sourcePhase = type(result.sourcePhase) == "string" and result.sourcePhase or domain,
            severity = result.severity == "failure" and "failure" or "partial",
            resultCode = result.resultCode,
            reasons = {},
            residualSummary = nil,
            residualSummaries = {},
        }
        context.domainResults[#context.domainResults + 1] = entry
        context._domainResultIndexByDomain[domain] = #context.domainResults
        context._domainResultReasonSets[domain] = {}
    elseif entry.severity ~= "failure" and result.severity == "failure" then
        entry.severity = "failure"
    end

    if (type(entry.sourcePhase) ~= "string" or entry.sourcePhase == "")
        and type(result.sourcePhase) == "string" then
        entry.sourcePhase = result.sourcePhase
    end
    if (type(entry.resultCode) ~= "string" or entry.resultCode == "")
        and type(result.resultCode) == "string" then
        entry.resultCode = result.resultCode
    end

    local reasonSet = context._domainResultReasonSets[domain]
    for _, reason in ipairs(type(result.reasons) == "table" and result.reasons or {}) do
        AppendUniqueString(entry.reasons, reasonSet, reason)
    end
    AppendResidualSummary(entry, result.residualSummary)
    RefreshPartialSuccessCompatibilityView(context)
    return entry
end

function LTM_PIPELINE_CONTEXT:GetDomainResults(context)
    if type(context) ~= "table" or type(context.domainResults) ~= "table" then
        return {}
    end

    return context.domainResults
end

function LTM_PIPELINE_CONTEXT:SetPhaseResult(context, phaseName, result)
    if type(context) ~= "table" or type(phaseName) ~= "string" then
        return nil
    end

    context.phaseResults = context.phaseResults or {}
    context.phaseResults[phaseName] = result
    return result
end

function LTM_PIPELINE_CONTEXT:GetPhaseResult(context, phaseName)
    if type(context) ~= "table" or type(phaseName) ~= "string" then
        return nil
    end

    return type(context.phaseResults) == "table" and context.phaseResults[phaseName] or nil
end

function LTM_PIPELINE_CONTEXT:GetRuntime(context)
    if type(context) ~= "table" then
        return nil
    end

    context.runtime = context.runtime or {}
    return context.runtime
end

function LTM_PIPELINE_CONTEXT:SetRuntimeFlag(context, key, value)
    if type(context) ~= "table" or type(key) ~= "string" then
        return nil
    end

    local runtime = self:GetRuntime(context)
    runtime[key] = value
    return value
end

function LTM_PIPELINE_CONTEXT:GetRuntimeFlag(context, key)
    if type(context) ~= "table" or type(key) ~= "string" then
        return nil
    end

    local runtime = self:GetRuntime(context)
    return runtime[key]
end

function LTM_PIPELINE_CONTEXT:GetSkillSettingsSkipReason(context, target)
    return ResolveSkillSettingsReason(ResolveSkillSettings(context), target)
end

function LTM_PIPELINE_CONTEXT:GetSkillSettings(context)
    return CloneTableShallow(ResolveSkillSettings(context))
end

function LTM_PIPELINE_CONTEXT:RecordSkillSettingsExpectedSkip(context, target)
    if type(context) ~= "table"
        or (target ~= SKILL_SETTINGS_TARGET_NORMAL_SKILLS
            and target ~= SKILL_SETTINGS_TARGET_NORMAL_PASSIVES) then
        return false
    end

    context.skillSettingsExpected = type(context.skillSettingsExpected) == "table" and context.skillSettingsExpected or {
        skippedTargets = {},
    }
    context.skillSettingsExpected.skippedTargets[target] = true
    return true
end

function LTM_PIPELINE_CONTEXT:GetSkillSettingsExpectedSummary(context)
    local expected = type(context) == "table" and context.skillSettingsExpected or nil
    if type(expected) ~= "table" then
        return nil
    end

    return {
        skippedTargets = CloneTableShallow(expected.skippedTargets),
    }
end

function LTM_PIPELINE_CONTEXT:RecordSkillSettingsSkip(context, target, reason)
    if type(context) ~= "table"
        or (target ~= SKILL_SETTINGS_TARGET_NORMAL_SKILLS
            and target ~= SKILL_SETTINGS_TARGET_NORMAL_PASSIVES) then
        return false
    end

    local resolvedReason = reason or self:GetSkillSettingsSkipReason(context, target)
    if type(resolvedReason) ~= "string" or resolvedReason == "" then
        return false
    end

    local runtime = type(context.skillSettingsRuntime) == "table" and context.skillSettingsRuntime or {
        skippedTargets = {},
        reasons = {},
        reasonSet = {},
    }
    context.skillSettingsRuntime = runtime
    runtime.skippedTargets[target] = true
    if runtime.reasonSet[resolvedReason] ~= true then
        runtime.reasonSet[resolvedReason] = true
        runtime.reasons[#runtime.reasons + 1] = resolvedReason
    end
    return true
end

function LTM_PIPELINE_CONTEXT:GetSkillSettingsRuntimeSummary(context)
    local runtime = type(context) == "table" and context.skillSettingsRuntime or nil
    if type(runtime) ~= "table" then
        return nil
    end

    local skippedTargets = CloneTableShallow(runtime.skippedTargets)
    local reasons = {}
    for index, reason in ipairs(runtime.reasons or {}) do
        reasons[index] = reason
    end
    return {
        skippedTargets = skippedTargets,
        reasons = reasons,
    }
end

function LTM_PIPELINE_CONTEXT:GetTargetSubclassState(context)
    if type(context) ~= "table" then
        return nil
    end

    return context.targetBuild and context.targetBuild.subclass or nil
end

function LTM_PIPELINE_CONTEXT:GetCurrentSubclassState(context)
    if type(context) ~= "table" then
        return nil
    end

    return self:GetCurrentState(context, "subclass")
end

function LTM_PIPELINE_CONTEXT:SetCurrentState(context, key, value)
    if type(context) ~= "table" or type(key) ~= "string" then
        return nil
    end

    context.currentState = context.currentState or {}
    context.currentState[key] = value
    return value
end

function LTM_PIPELINE_CONTEXT:GetCurrentState(context, key)
    if type(context) ~= "table" or type(key) ~= "string" then
        return nil
    end

    return context.currentState and context.currentState[key] or nil
end

function LTM_PIPELINE_CONTEXT:SetResolvedPlan(context, plan)
    if type(context) ~= "table" then
        return nil
    end

    context.resolvedPlan = plan
    return plan
end

function LTM_PIPELINE_CONTEXT:GetResolvedPlan(context)
    if type(context) ~= "table" then
        return nil
    end

    return context.resolvedPlan
end

function LTM_PIPELINE_CONTEXT:GetPartialScope(context)
    if type(context) ~= "table" then
        return nil
    end

    return context.partialScope
end

function LTM_PIPELINE_CONTEXT:GetPreflightMode(context)
    if type(context) ~= "table" then
        return nil
    end

    return context.preflightMode
end
