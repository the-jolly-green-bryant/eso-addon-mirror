local Addon = LarvalTearMod
local LTM = Addon
local Log = Addon.Common.Log
local LTM_APPLY_START_STATE = Addon.Modules.ApplyStartState
local LTM_ATTRIBUTE_APPLY = Addon.Modules.AttributeApply
local LTM_ATTRIBUTE_SNAPSHOT = Addon.Modules.AttributeSnapshot
local LTM_CHAMPION_APPLY = Addon.Modules.ChampionApply
local LTM_EQUIPMENT_APPLY = Addon.Modules.EquipmentApply
local LTM_PIPELINE = Addon.Core.Pipeline
local LTM_PIPELINE_CONTEXT = Addon.Modules.PipelineContext
local LTM_PIPELINE_FINALIZE = Addon.Modules.PipelineFinalize
local LTM_PIPELINE_PLANNER = Addon.Modules.PipelinePlanner
local LTM_ROLE_APPLY = Addon.Modules.RoleApply
local LTM_ROLE_STATE = Addon.Modules.RoleState
local LTM_CLASS_MASTERY_APPLY = Addon.Modules.ClassMasteryApply
local LTM_SKILL_APPLY = Addon.Modules.SkillApply
local LTM_SKILL_PASSIVE_APPLY = Addon.Modules.SkillPassiveApply
local LTM_SUBCLASS_APPLY = Addon.Modules.SubclassApply
local LTM_SUBCLASS_SNAPSHOT = Addon.Modules.SubclassSnapshot
local SHARED_UTIL = Addon.Common.Util
LTM_PIPELINE.isRunning = LTM_PIPELINE.isRunning == true
LTM_PIPELINE.activeRunId = tonumber(LTM_PIPELINE.activeRunId) or 0

local INTERPHASE_RESET_POLL_INTERVAL_MS = 200
local INTERPHASE_RESET_TIMEOUT_MS = 7000
local INTERPHASE_RESET_SETTLE_DELAY_MS = 750
local PIPE_E_INTERPHASE_RESET_TIMEOUT = "PIPE_E_INTERPHASE_RESET_TIMEOUT"
local PIPELINE_ABORT_REASON_DEFAULT = "unsafe_to_continue"
local DOMAIN_PHASE_ORDER = {
    Equipment = 1,
    Role = 2,
    Subclass = 3,
    Skills = 4,
    PassiveSkills = 5,
    ClassMastery = 6,
    Attribute = 7,
    ChampionPoints = 8,
    Finalize = 9,
    Pipeline = 10,
}

LTM_PIPELINE.SAFE_ABORT_REASONS = {
    ATTR_E_SCENE_READY_TIMEOUT = true,
    combat_entered_after_apply_start = true,
    equipment_final_verify_timeout = true,
    equipment_weapon_prepass_incomplete = true,
    equipment_weapon_stage_equip_failed = true,
    equipment_weapon_stage_failed = true,
    equipment_weapon_stage_timeout = true,
    mythic_target_not_equipped = true,
    player_in_combat = true,
    route_b_cleanup_incomplete = true,
    route_b_completion_timeout = true,
    route_b_unresolved_slot_target_before_commit = true,
    route_b_verify_retry_exhausted = true,
    skill_pending_changes_blocking_apply = true,
    subclass_verify_mismatch = true,
}

local function CloneConfigWithMeta(config, meta)
    if config == nil then
        return nil
    end

    local cloned = {}
    for key, value in pairs(config or {}) do
        cloned[key] = value
    end
    for key, value in pairs(meta or {}) do
        cloned[key] = value
    end
    return cloned
end

local function TracePipeline(...)
    Log.LogDebugSummary(...)
end

local function NotifyPhaseUpdate(context, phaseName)
    local callback = type(context) == "table" and context.onPhaseUpdate or nil
    if type(callback) ~= "function" then
        return
    end

    local ok, err = pcall(callback, phaseName)
    if ok ~= true then
        Log.Debug("Pipeline phase update callback failed error=" .. tostring(err))
    end
end

local function NotifyStatusUpdate(context, statusName, detail)
    local callback = type(context) == "table" and context.onStatusUpdate or nil
    if type(callback) ~= "function" then
        return
    end

    local ok, err = pcall(callback, statusName, detail)
    if ok ~= true then
        Log.Debug("Pipeline status update callback failed error=" .. tostring(err))
    end
end

local function MarkPipelineAbortRequested(context, reason, phaseName)
    if type(context) ~= "table" then
        return false, nil
    end

    if context.cancelRequested == true then
        return false, context.cancelReason
    end

    context.cancelRequested = true
    context.cancelReason = tostring(reason or PIPELINE_ABORT_REASON_DEFAULT)
    context.cancelRequestedAtPhase = phaseName
    return true, context.cancelReason
end

local function ResolvePipelineAbortReason(context)
    if type(context) == "table" and type(context.cancelReason) == "string" and context.cancelReason ~= "" then
        return context.cancelReason
    end

    return PIPELINE_ABORT_REASON_DEFAULT
end

local function BuildPartialScopePhaseSet(partialScope)
    if partialScope == "attributes" then
        return {
            attribute_apply = true,
            finalize = true,
        }
    end

    if partialScope == "class_skills" then
        return {
            subclass_apply = true,
            skill_apply = true,
            skill_passive_apply = true,
            class_mastery_apply = true,
            finalize = true,
        }
    end

    if partialScope == "equipment" then
        return {
            equipment_apply = true,
            finalize = true,
        }
    end

    if partialScope == "champion_points" then
        return {
            champion_apply = true,
            finalize = true,
        }
    end

    return nil
end

local function AppendPhase(phases, name, module, config)
    if config == nil then
        return
    end

    phases[#phases + 1] = {
        name = name,
        module = module,
        config = config,
    }
end

local function GetPlannedPhaseConfig(plan, key)
    return plan.configs[key]
end

function LTM_PIPELINE:BuildPhases(continuation, context)
    local phases = {}
    local plan = LTM_PIPELINE_CONTEXT:GetResolvedPlan(context)
    local meta = {
        _pipelineContext = context,
        _pipelineContinuation = continuation,
        _pipelinePlan = plan,
    }
    local phaseSpecs = {
        {
            phaseName = "equipment_apply",
            displayName = "Equipment",
            module = LTM_EQUIPMENT_APPLY,
            config = GetPlannedPhaseConfig(plan, "equipment"),
        },
        {
            phaseName = "role_apply",
            displayName = "Role",
            module = LTM_ROLE_APPLY,
            config = GetPlannedPhaseConfig(plan, "role"),
        },
        {
            phaseName = "subclass_apply",
            displayName = "Subclass",
            module = LTM_SUBCLASS_APPLY,
            config = GetPlannedPhaseConfig(plan, "subclass"),
        },
        {
            phaseName = "skill_apply",
            displayName = "Skills",
            module = LTM_SKILL_APPLY,
            config = GetPlannedPhaseConfig(plan, "skills"),
        },
        {
            phaseName = "skill_passive_apply",
            displayName = "PassiveSkills",
            module = LTM_SKILL_PASSIVE_APPLY,
            config = GetPlannedPhaseConfig(plan, "skillPassive"),
        },
        {
            phaseName = "class_mastery_apply",
            displayName = "ClassMastery",
            module = LTM_CLASS_MASTERY_APPLY,
            config = GetPlannedPhaseConfig(plan, "classMastery"),
        },
        {
            phaseName = "attribute_apply",
            displayName = "Attribute",
            module = LTM_ATTRIBUTE_APPLY,
            config = GetPlannedPhaseConfig(plan, "attributes"),
        },
        {
            phaseName = "champion_apply",
            displayName = "ChampionPoints",
            module = LTM_CHAMPION_APPLY,
            config = GetPlannedPhaseConfig(plan, "championPoints"),
        },
        {
            phaseName = "finalize",
            displayName = "Finalize",
            module = LTM_PIPELINE_FINALIZE,
            config = {},
        },
    }

    local allowed = {}
    for _, phaseName in ipairs(plan.phases) do
        allowed[phaseName] = true
    end

    for _, spec in ipairs(phaseSpecs) do
        if allowed[spec.phaseName] then
            local phaseMeta = CloneConfigWithMeta(meta, {
                _pipelinePhaseName = spec.displayName,
            })
            AppendPhase(phases, spec.displayName, spec.module, CloneConfigWithMeta(spec.config, phaseMeta))
        end
    end

    return phases
end

local function IsSafeAbortCompletion(context, success)
    return success ~= true and type(context) == "table" and context.cancelRequested == true
end

local function RunSafeAbortCleanup(context, onComplete)
    if type(context) ~= "table" then
        if type(onComplete) == "function" then
            onComplete()
        end
        return
    end

    if context.safeAbortCleanupCompleted == true then
        if type(onComplete) == "function" then
            onComplete()
        end
        return
    end

    if context.safeAbortCleanupStarted == true then
        return
    end

    context.safeAbortCleanupStarted = true
    local abortReason = ResolvePipelineAbortReason(context)
    Log.Debug(
        "Pipeline safe abort cleanup begin reason="
            .. tostring(abortReason)
            .. " phase="
            .. tostring(context.cancelRequestedAtPhase)
            .. " runId="
            .. tostring(context.runId)
    )

    local function finish(ok, cleanReason, cleanSnapshot)
        if context.safeAbortCleanupCompleted == true then
            return
        end

        context.safeAbortCleanupCompleted = true

        if ok == true then
            Log.Debug(
                "Pipeline safe abort cleanup done reason="
                    .. tostring(abortReason)
                    .. " runId="
                    .. tostring(context.runId)
            )
        else
            Log.Debug(
                "Pipeline safe abort cleanup failed reason="
                    .. tostring(cleanReason or "safe_abort_cleanup_failed")
                    .. " abortReason="
                    .. tostring(abortReason)
                    .. " runId="
                    .. tostring(context.runId)
            )
        end

        if type(onComplete) == "function" then
            onComplete()
        end
    end

    local started, startErr = LTM_APPLY_START_STATE:NormalizeToHudBaseline(function(ok, cleanReason, cleanSnapshot)
        finish(ok == true, cleanReason, cleanSnapshot)
    end)

    if started ~= true then
        Log.Debug(
            "Pipeline safe abort cleanup skipped reason="
                .. tostring(startErr or "normalize_start_failed")
                .. " abortReason="
                .. tostring(abortReason)
                .. " runId="
                .. tostring(context.runId)
        )
        finish(false, startErr or "normalize_start_failed", nil)
    end
end

local function ResolveFailurePhases(context)
    local phases = {}
    for _, phaseError in ipairs(type(context) == "table" and context.phaseErrors or {}) do
        local phaseId = type(phaseError) == "table" and (phaseError.phaseId or phaseError.phase) or nil
        if type(phaseId) == "string" and phaseId ~= "" then
            phases[#phases + 1] = phaseId
        end
    end
    return phases
end

local function AppendUniqueReason(reasons, seenReasons, reason)
    if type(reason) ~= "string" or reason == "" or seenReasons[reason] then
        return
    end

    seenReasons[reason] = true
    reasons[#reasons + 1] = reason
end

local function CloneTerminalDomainEntry(source, sequence)
    local reasons = {}
    local seenReasons = {}
    for _, reason in ipairs(type(source) == "table" and source.reasons or {}) do
        AppendUniqueReason(reasons, seenReasons, reason)
    end

    local entry = {
        domain = source.domain or source.sourcePhase,
        sourcePhase = source.sourcePhase or source.domain,
        severity = source.severity == "failure" and "failure" or "partial",
        resultCode = source.resultCode,
        reasons = reasons,
        residualSummary = source.residualSummary,
        _sequence = sequence,
        _reasonSet = seenReasons,
    }
    if type(source.residualSummaries) == "table" and #source.residualSummaries > 1 then
        entry.residualSummaries = {}
        for _, residualSummary in ipairs(source.residualSummaries) do
            entry.residualSummaries[#entry.residualSummaries + 1] = residualSummary
        end
    end
    return entry
end

local function BuildTerminalDomainResults(context, success, err)
    local results = {}
    local domainIndex = {}
    local sourceResults = LTM_PIPELINE_CONTEXT:GetDomainResults(context)

    for _, source in ipairs(sourceResults) do
        local domain = type(source) == "table" and (source.domain or source.sourcePhase) or nil
        if type(domain) == "string" and domain ~= "" and domainIndex[domain] == nil then
            local entry = CloneTerminalDomainEntry(source, #results + 1)
            entry.domain = domain
            results[#results + 1] = entry
            domainIndex[domain] = #results
        end
    end

    local failureCount = 0
    for _, phaseError in ipairs(type(context) == "table" and context.phaseErrors or {}) do
        local domain = type(phaseError) == "table" and (phaseError.phaseId or phaseError.phase) or nil
        local reason = type(phaseError) == "table" and phaseError.reason or nil
        if type(domain) == "string" and domain ~= "" then
            local entryIndex = domainIndex[domain]
            local entry = entryIndex ~= nil and results[entryIndex] or nil
            if type(entry) ~= "table" then
                entry = CloneTerminalDomainEntry({
                    domain = domain,
                    sourcePhase = domain,
                    severity = "failure",
                    resultCode = reason,
                    reasons = {},
                }, #results + 1)
                results[#results + 1] = entry
                domainIndex[domain] = #results
            end
            if entry.severity ~= "failure" then
                entry.severity = "failure"
                entry.resultCode = reason
            elseif type(entry.resultCode) ~= "string" or entry.resultCode == "" then
                entry.resultCode = reason
            end
            AppendUniqueReason(entry.reasons, entry._reasonSet, reason)
            failureCount = failureCount + 1
        end
    end

    if success ~= true and failureCount == 0 then
        local domain = type(context) == "table" and context.cancelRequestedAtPhase or nil
        if type(domain) ~= "string" or domain == "" then
            domain = "Pipeline"
        end
        local entryIndex = domainIndex[domain]
        local entry = entryIndex ~= nil and results[entryIndex] or nil
        if type(entry) ~= "table" then
            entry = CloneTerminalDomainEntry({
                domain = domain,
                sourcePhase = domain,
                severity = "failure",
                resultCode = err,
                reasons = {},
            }, #results + 1)
            results[#results + 1] = entry
            domainIndex[domain] = #results
        end
        entry.severity = "failure"
        entry.resultCode = err
        AppendUniqueReason(entry.reasons, entry._reasonSet, err)
    end

    table.sort(results, function(left, right)
        local leftOrder = DOMAIN_PHASE_ORDER[left.domain] or 999
        local rightOrder = DOMAIN_PHASE_ORDER[right.domain] or 999
        if leftOrder == rightOrder then
            return left._sequence < right._sequence
        end
        return leftOrder < rightOrder
    end)
    for _, entry in ipairs(results) do
        entry._sequence = nil
        entry._reasonSet = nil
    end
    return results
end

local function BuildTerminalDomainResultTrace(results)
    local entries = {}
    for _, entry in ipairs(results or {}) do
        entries[#entries + 1] = tostring(entry.domain) .. ":" .. tostring(entry.severity)
    end
    return table.concat(entries, ",")
end

local function ResolveSkillSettingsRuntimeSummary(context)
    return LTM_PIPELINE_CONTEXT:GetSkillSettingsRuntimeSummary(context)
end

local function ResolveSkillSettingsExpectedSummary(context)
    return LTM_PIPELINE_CONTEXT:GetSkillSettingsExpectedSummary(context)
end

local function NotifyPipelineCompletion(context, success, err)
    if type(context) ~= "table" then
        return
    end

    local completion = context.pipelineCompletion
    if type(completion) ~= "function" or context.pipelineCompletionNotified then
        return
    end

    if IsSafeAbortCompletion(context, success) and context.safeAbortCleanupCompleted ~= true then
        RunSafeAbortCleanup(context, function()
            NotifyPipelineCompletion(context, success, err)
        end)
        return
    end

    context.pipelineCompletionNotified = true
    if context.logBuildName ~= nil then
        Log.LogEnd(context.logBuildName)
    end
    Log.LogDebugSaved()
    LTM_PIPELINE:FinishRun(context.runId)
    local terminalDomainResults = BuildTerminalDomainResults(context, success, err)
    local finalResult = nil
    if success == true then
        local partialResult = type(context) == "table" and context.partialSuccessResult or nil
        if type(partialResult) == "table" then
            finalResult = {
                finalStatus = "partial_success",
                resultCode = partialResult.resultCode,
                reasons = partialResult.reasons,
                residualSummary = partialResult.residualSummary,
                sourcePhase = partialResult.sourcePhase,
                results = terminalDomainResults,
                skillSettingsRuntime = ResolveSkillSettingsRuntimeSummary(context),
                skillSettingsExpected = ResolveSkillSettingsExpectedSummary(context),
            }
        else
            finalResult = {
                finalStatus = "full_success",
                resultCode = nil,
                reasons = {},
                residualSummary = nil,
                sourcePhase = nil,
                results = terminalDomainResults,
                skillSettingsRuntime = ResolveSkillSettingsRuntimeSummary(context),
                skillSettingsExpected = ResolveSkillSettingsExpectedSummary(context),
            }
        end
    else
        local isSafeAbort = IsSafeAbortCompletion(context, success)
        local failurePhases = ResolveFailurePhases(context)
        finalResult = {
            finalStatus = "failure",
            resultCode = err,
            reasons = {
                err,
            },
            residualSummary = nil,
            sourcePhase = nil,
            failurePhase = failurePhases[1],
            failurePhases = failurePhases,
            isSafeAbort = isSafeAbort,
            safeAbortReason = isSafeAbort and context.cancelReason or nil,
            results = terminalDomainResults,
            skillSettingsRuntime = ResolveSkillSettingsRuntimeSummary(context),
            skillSettingsExpected = ResolveSkillSettingsExpectedSummary(context),
        }
    end

    TracePipeline(
        "Pipeline final status",
        "finalStatus=" .. tostring(finalResult.finalStatus),
        "partial=" .. tostring(finalResult.finalStatus == "partial_success"),
        "resultCode=" .. tostring(finalResult.resultCode),
        "success=" .. tostring(finalResult.finalStatus ~= "failure"),
        "results=" .. BuildTerminalDomainResultTrace(finalResult.results)
    )
    completion(finalResult.finalStatus ~= "failure", err, finalResult)
end

local function ResolveLogBuildName(build)
    local defaultBuildName = LTM.GetStringText("SI_LTM_COMMON_BUILD")
    if type(build) ~= "table" then
        return defaultBuildName
    end

    if type(build.name) == "string" and build.name ~= "" then
        return build.name
    end

    if type(build.displayName) == "string" and build.displayName ~= "" then
        return build.displayName
    end

    if type(build.id) == "string" and build.id ~= "" then
        return build.id
    end

    return defaultBuildName
end

local function ResolveUserPhaseName(phaseName)
    if phaseName == "ChampionPoints" then
        return LTM.GetStringText("SI_LTM_PHASE_NAME_CHAMPION_POINTS")
    end

    if phaseName == nil then
        return LTM.GetStringText("SI_LTM_COMMON_UNKNOWN")
    end

    return tostring(phaseName or "Unknown")
end

function LTM_PIPELINE:ResolvePhaseTargetLabel(phaseName)
    local labels = {
        Equipment = "SI_LTM_PHASE_TARGET_EQUIPMENT",
        Subclass = "SI_LTM_PHASE_TARGET_SUBCLASS",
        Role = "SI_LTM_PHASE_TARGET_ROLE",
        Skills = "SI_LTM_PHASE_TARGET_SKILLS",
        ActionBarRestore = "SI_LTM_PHASE_TARGET_ACTION_BAR_RESTORE",
        TransformSkills = "SI_LTM_PHASE_TARGET_TRANSFORM_SKILLS",
        PassiveSkills = "SI_LTM_PHASE_TARGET_PASSIVE_SKILLS",
        ClassMastery = "SI_LTM_PHASE_TARGET_CLASS_MASTERY",
        Attribute = "SI_LTM_PHASE_TARGET_ATTRIBUTE",
        ChampionPoints = "SI_LTM_PHASE_TARGET_CHAMPION",
        Finalize = "SI_LTM_PHASE_TARGET_FINALIZE",
        Pipeline = "SI_LTM_PHASE_TARGET_INTERPHASE_RESET",
    }

    local stringIdName = labels[phaseName]
    if type(stringIdName) == "string" then
        return LTM.GetStringText(stringIdName)
    end

    return LTM.GetStringText("SI_LTM_PHASE_TARGET_GENERIC", {
        phase = tostring(phaseName or LTM.GetStringText("SI_LTM_COMMON_UNKNOWN")),
    })
end

local function RecordPhaseFailure(context, phaseName, reason, targetLabel)
    local normalizedReason = tostring(reason or "unknown_error")
    local normalizedPhaseName = ResolveUserPhaseName(phaseName)
    local normalizedTarget = tostring(targetLabel or LTM_PIPELINE:ResolvePhaseTargetLabel(phaseName))

    if type(context) == "table" then
        context.phaseErrors = context.phaseErrors or {}
        context.phaseErrors[#context.phaseErrors + 1] = {
            phaseId = phaseName,
            phase = normalizedPhaseName,
            target = normalizedTarget,
            reason = normalizedReason,
        }
        context.hadErrors = true
        if context.firstError == nil then
            context.firstError = normalizedReason
        end
    end

    Log.LogError(
        type(context) == "table" and context.logBuildName or ResolveLogBuildName(nil),
        normalizedPhaseName,
        normalizedTarget,
        normalizedReason
    )
end

local function ShouldAbortPipelineAfterFailure(reason)
    return reason == "cryptcanon_special_ultimate_requires_overwrite"
        or LTM_PIPELINE.SAFE_ABORT_REASONS[tostring(reason or "")] == true
end

local function IsEquipmentAbortReason(reason)
    local normalizedReason = tostring(reason or "")
    return normalizedReason == "equipment_final_verify_timeout"
        or normalizedReason == "equipment_weapon_prepass_incomplete"
        or normalizedReason == "equipment_weapon_stage_equip_failed"
        or normalizedReason == "equipment_weapon_stage_failed"
        or normalizedReason == "equipment_weapon_stage_timeout"
        or normalizedReason == "mythic_target_not_equipped"
end

local function NormalizePipelinePhaseName(phaseName)
    if phaseName == "subclass_apply" then
        return "Subclass"
    end

    if phaseName == "skill_apply" then
        return "Skills"
    end

    if phaseName == "attribute_apply" then
        return "Attribute"
    end

    return phaseName
end

local function ShouldAbortPipelineAfterPhaseFailure(phaseName, reason)
    local normalizedPhaseName = NormalizePipelinePhaseName(phaseName)

    if reason == "combat_entered_after_apply_start" then
        return true
    end

    if normalizedPhaseName == "Subclass"
        and (reason == "route_b_completion_timeout"
            or reason == "route_b_verify_retry_exhausted"
            or reason == "subclass_verify_mismatch") then
        return true
    end

    if normalizedPhaseName == "Skills"
        and (reason == "skill_pending_changes_blocking_apply"
            or reason == "player_in_combat"
            or reason == "route_b_completion_timeout") then
        return true
    end

    if normalizedPhaseName == "Attribute" and reason == "ATTR_E_SCENE_READY_TIMEOUT" then
        return true
    end

    if normalizedPhaseName == "Equipment" and IsEquipmentAbortReason(reason) then
        TracePipeline(
            "Equipment abort pipeline reason",
            "reason=" .. tostring(reason)
        )
        return true
    end

    return false
end

local function GetInterphaseResetKey(pendingContext)
    if type(pendingContext) ~= "table" then
        return nil
    end

    local nextPhase = pendingContext.phases and pendingContext.phases[pendingContext.nextPhaseIndex] or nil
    if type(nextPhase) ~= "table" then
        return nil
    end

    return tostring(pendingContext.nextPhaseIndex) .. ":" .. tostring(nextPhase.name)
end

local function HasInterphaseResetAttempted(pendingContext)
    local context = type(pendingContext) == "table" and pendingContext.context or nil
    local resetKey = GetInterphaseResetKey(pendingContext)
    local attempted = type(context) == "table" and context.interphaseResetAttempted or nil
    return resetKey ~= nil and type(attempted) == "table" and attempted[resetKey] == true
end

local function MarkInterphaseResetAttempted(pendingContext)
    local context = type(pendingContext) == "table" and pendingContext.context or nil
    local resetKey = GetInterphaseResetKey(pendingContext)
    if type(context) ~= "table" or resetKey == nil then
        return
    end

    if type(context.interphaseResetAttempted) ~= "table" then
        context.interphaseResetAttempted = {}
    end
    context.interphaseResetAttempted[resetKey] = true
end

local function GetCurrentSceneState(sceneName)
    local isShowing = SCENE_MANAGER:IsShowing(sceneName)
    local scene = SCENE_MANAGER:GetScene(sceneName)
    local sceneState = nil
    if type(scene) == "table" and type(scene.GetState) == "function" then
        local ok, state = pcall(scene.GetState, scene)
        if ok then
            sceneState = state
        end
    end
    if type(scene) ~= "table" or type(scene.IsTransitioning) ~= "function" then
        return isShowing, false, sceneState
    end

    return isShowing, scene:IsTransitioning() == true, sceneState
end

local function GetSkillPointAllocationModeSafe()
    if type(SKILLS_AND_ACTION_BAR_MANAGER) ~= "table"
        or type(SKILLS_AND_ACTION_BAR_MANAGER.GetSkillPointAllocationMode) ~= "function" then
        return nil
    end

    local ok, mode = pcall(
        SKILLS_AND_ACTION_BAR_MANAGER.GetSkillPointAllocationMode,
        SKILLS_AND_ACTION_BAR_MANAGER
    )
    return ok and mode or nil
end

local function GetAttributePointAllocationModeSafe(statsManager)
    if type(statsManager) ~= "table" then
        return nil
    end

    if type(statsManager.GetAttributePointAllocationMode) == "function" then
        local ok, mode = pcall(statsManager.GetAttributePointAllocationMode, statsManager)
        if ok then
            return mode
        end
    end

    return statsManager.attributePointAllocationMode
end

local function BuildInterphaseResetSnapshot(context)
    local interaction = type(GetInteractionType) == "function" and GetInteractionType() or nil
    local statsShowing, statsTransitioning, statsSceneState = GetCurrentSceneState("stats")
    local gamepadStatsShowing, gamepadStatsTransitioning, gamepadStatsSceneState = GetCurrentSceneState(
        "gamepad_stats_root"
    )
    local skillsShowing, skillsTransitioning, skillsSceneState = GetCurrentSceneState("skills")
    local gamepadSkillsShowing, gamepadSkillsTransitioning, gamepadSkillsSceneState = GetCurrentSceneState(
        "gamepad_skills_root"
    )
    local currentSceneName = nil
    local elapsedMs = nil
    local pipelineContext = type(context) == "table" and context.context or nil
    local runtime = type(pipelineContext) == "table" and pipelineContext.runtime or nil
    local runOptions = type(pipelineContext) == "table" and pipelineContext.runOptions or nil
    local skillSettings = type(runOptions) == "table" and runOptions.skillSettings or nil
    local nextPhase = type(context) == "table"
        and type(context.phases) == "table"
        and type(context.nextPhaseIndex) == "number"
        and context.phases[context.nextPhaseIndex]
        or nil

    local scene = SCENE_MANAGER:GetCurrentScene()
    if type(scene) == "table" and type(scene.GetName) == "function" then
        currentSceneName = scene:GetName()
    end

    if type(context) == "table" and context.resetStartedAt ~= nil then
        elapsedMs = SHARED_UTIL:GetFrameTimeMillisecondsSafe() - context.resetStartedAt
    end

    local sceneTransitioning = statsTransitioning or gamepadStatsTransitioning or skillsTransitioning or gamepadSkillsTransitioning
    local interactionReady = interaction == 0
    local scenesClosed = not statsShowing and not gamepadStatsShowing and not skillsShowing and not gamepadSkillsShowing

    return {
        interaction = interaction,
        interactionReady = interactionReady,
        scenesClosed = scenesClosed,
        elapsedMs = elapsedMs,
        attemptCount = type(context) == "table" and context.resetAttemptCount or nil,
        currentSceneName = currentSceneName,
        nextPhaseName = type(nextPhase) == "table" and nextPhase.name or nil,
        skillAllocationMode = GetSkillPointAllocationModeSafe(),
        statsAllocationMode = GetAttributePointAllocationModeSafe(STATS),
        gamepadStatsAllocationMode = GetAttributePointAllocationModeSafe(GAMEPAD_STATS),
        statsShowing = statsShowing,
        statsTransitioning = statsTransitioning,
        statsSceneState = statsSceneState,
        gamepadStatsShowing = gamepadStatsShowing,
        gamepadStatsTransitioning = gamepadStatsTransitioning,
        gamepadStatsSceneState = gamepadStatsSceneState,
        skillsShowing = skillsShowing,
        skillsTransitioning = skillsTransitioning,
        skillsSceneState = skillsSceneState,
        gamepadSkillsShowing = gamepadSkillsShowing,
        gamepadSkillsTransitioning = gamepadSkillsTransitioning,
        gamepadSkillsSceneState = gamepadSkillsSceneState,
        sceneTransitioning = sceneTransitioning,
        priorSkillRespecCommitted = type(runtime) == "table" and runtime.priorSkillRespecCommitted == true,
        skillPhaseMode = type(runOptions) == "table" and runOptions.skillPhaseMode or nil,
        skillPhaseReason = type(runOptions) == "table" and runOptions.skillPhaseReason or nil,
        resolvedPreflightMode = type(pipelineContext) == "table" and pipelineContext.preflightMode or nil,
        skillSettingsActiveAction = type(skillSettings) == "table" and skillSettings.activeAction or nil,
        skillSettingsPassiveAction = type(skillSettings) == "table" and skillSettings.passiveAction or nil,
        routeBSubclassOnly = type(runtime) == "table" and runtime.routeBSubclassOnly == true,
    }
end

local function LogInterphaseResetTimeoutSnapshotOnce(resetContext, snapshot)
    if type(resetContext) ~= "table" or resetContext.timeoutSnapshotLogged == true then
        return
    end

    resetContext.timeoutSnapshotLogged = true
    if Log.IsSummaryDebugEnabled() ~= true then
        return
    end

    snapshot = type(snapshot) == "table" and snapshot or {}
    Log.LogDebugSummary(
        "[ONCE] Pipeline interphase reset timeout snapshot",
        "interaction=" .. tostring(snapshot.interaction),
        "skillAllocationMode=" .. tostring(snapshot.skillAllocationMode),
        "statsAllocationMode=" .. tostring(snapshot.statsAllocationMode),
        "gamepadStatsAllocationMode=" .. tostring(snapshot.gamepadStatsAllocationMode),
        "skillsShowing=" .. tostring(snapshot.skillsShowing),
        "gamepadSkillsShowing=" .. tostring(snapshot.gamepadSkillsShowing),
        "statsShowing=" .. tostring(snapshot.statsShowing),
        "gamepadStatsShowing=" .. tostring(snapshot.gamepadStatsShowing),
        "skillsSceneState=" .. tostring(snapshot.skillsSceneState),
        "gamepadSkillsSceneState=" .. tostring(snapshot.gamepadSkillsSceneState),
        "statsSceneState=" .. tostring(snapshot.statsSceneState),
        "gamepadStatsSceneState=" .. tostring(snapshot.gamepadStatsSceneState),
        "sceneTransitioning=" .. tostring(snapshot.sceneTransitioning),
        "currentSceneName=" .. tostring(snapshot.currentSceneName),
        "nextPhaseName=" .. tostring(snapshot.nextPhaseName),
        "priorSkillRespecCommitted=" .. tostring(snapshot.priorSkillRespecCommitted),
        "skillPhaseMode=" .. tostring(snapshot.skillPhaseMode),
        "skillPhaseReason=" .. tostring(snapshot.skillPhaseReason),
        "resolvedPreflightMode=" .. tostring(snapshot.resolvedPreflightMode),
        "skillSettings.activeAction=" .. tostring(snapshot.skillSettingsActiveAction),
        "skillSettings.passiveAction=" .. tostring(snapshot.skillSettingsPassiveAction),
        "routeBSubclassOnly=" .. tostring(snapshot.routeBSubclassOnly),
        "attemptCount=" .. tostring(snapshot.attemptCount),
        "elapsedMs=" .. tostring(snapshot.elapsedMs)
    )
end

function LTM_PIPELINE:IsInterphaseResetReady(context)
    local snapshot = BuildInterphaseResetSnapshot(context)
    local ready = snapshot.interactionReady and snapshot.scenesClosed and not snapshot.sceneTransitioning
    return ready, snapshot
end

function LTM_PIPELINE:ShouldResetBetweenPhases(pendingContext)
    if type(pendingContext) ~= "table" then
        return false
    end

    if HasInterphaseResetAttempted(pendingContext) then
        return false
    end

    local nextPhase = pendingContext.phases and pendingContext.phases[pendingContext.nextPhaseIndex] or nil
    if type(nextPhase) ~= "table" or (nextPhase.name ~= "Attribute" and nextPhase.name ~= "ClassMastery") then
        return false
    end

    return LTM_PIPELINE_CONTEXT:GetRuntimeFlag(
        pendingContext.context,
        "priorSkillRespecCommitted"
    ) == true
end

function LTM_PIPELINE:ResetBeforePhaseIfNeeded(boundaryContext)
    if not self:ShouldResetBetweenPhases(boundaryContext) then
        return false
    end

    MarkInterphaseResetAttempted(boundaryContext)
    NotifyStatusUpdate(boundaryContext.context, "deferred", "interphase_reset")
    local resetOk, resetErr = self:ResetAfterMutatingRespec(boundaryContext, function(ready, resetFailureErr)
        if not ready then
            RecordPhaseFailure(boundaryContext.context, "Pipeline", resetFailureErr)
            self:RunPhases(
                boundaryContext.build,
                boundaryContext.nextPhaseIndex,
                boundaryContext.phases,
                boundaryContext.context
            )
            return
        end

        self:RunPhases(
            boundaryContext.build,
            boundaryContext.nextPhaseIndex,
            boundaryContext.phases,
            boundaryContext.context
        )
    end)

    if not resetOk then
        RecordPhaseFailure(boundaryContext.context, "Pipeline", resetErr)
        return false
    end

    return true
end

function LTM_PIPELINE:ResetAfterMutatingRespec(context, continuation)
    if type(continuation) ~= "function" then
        return false, "continuation_required"
    end

    if type(zo_callLater) ~= "function" then
        return false, "zo_callLater_unavailable"
    end

    local resetContext = {
        completed = false,
        startedAt = SHARED_UTIL:GetFrameTimeMillisecondsSafe(),
        attemptCount = 0,
        timeoutSnapshotLogged = false,
    }
    context.resetStartedAt = resetContext.startedAt

    local function finish(success, err, snapshot)
        if resetContext.completed then
            return
        end

        resetContext.completed = true
        continuation(success, err, snapshot)
    end

    SCENE_MANAGER:ShowBaseScene()

    local function poll()
        if resetContext.completed then
            return
        end

        resetContext.attemptCount = resetContext.attemptCount + 1
        context.resetAttemptCount = resetContext.attemptCount
        local ready, snapshot = self:IsInterphaseResetReady(context)
        local waitElapsedMs = SHARED_UTIL:GetFrameTimeMillisecondsSafe() - resetContext.startedAt

        if ready then
            zo_callLater(function()
                finish(true, nil, snapshot)
            end, INTERPHASE_RESET_SETTLE_DELAY_MS)
            return
        end

        if waitElapsedMs >= INTERPHASE_RESET_TIMEOUT_MS then
            LogInterphaseResetTimeoutSnapshotOnce(resetContext, snapshot)
            finish(false, PIPE_E_INTERPHASE_RESET_TIMEOUT, snapshot)
            return
        end

        zo_callLater(poll, INTERPHASE_RESET_POLL_INTERVAL_MS)
    end

    poll()
    return true
end

function LTM_PIPELINE:Validate(build)
    if type(build) ~= "table" then
        return false, "build must be a table"
    end

    return true
end

function LTM_PIPELINE:RunPhases(build, startIndex, phases, context)
    local deferred = false
    local aborted = false

    for index = startIndex, #phases do
        local phase = phases[index]
        if type(context) == "table" and context.cancelRequested == true then
            local abortReason = ResolvePipelineAbortReason(context)
            Log.Debug(
                "Pipeline safe abort at phase boundary reason="
                    .. tostring(abortReason)
                    .. " boundary=before_phase"
                    .. " phase="
                    .. tostring(phase and phase.name or nil)
                    .. " nextPhaseIndex="
                    .. tostring(index)
                    .. " runId="
                    .. tostring(context.runId)
            )
            NotifyStatusUpdate(context, "safe_abort", abortReason)
            aborted = abortReason
            break
        end

        local boundaryContext = {
            build = build,
            context = context,
            phases = phases,
            nextPhaseIndex = index,
        }
        if self:ResetBeforePhaseIfNeeded(boundaryContext) then
            deferred = true
            break
        end

        self.currentPhaseName = phase.name
        local phaseStartedAt = SHARED_UTIL:GetFrameTimeMillisecondsSafe()
        NotifyPhaseUpdate(context, phase.name)
        local phaseOk, phaseErr = phase.module:Run(phase.config or {})
        if not phaseOk then
            Log.Debug(tostring(phase.name) .. " failed error=" .. tostring(phaseErr))
            RecordPhaseFailure(context, phase.name, phaseErr)
            if ShouldAbortPipelineAfterPhaseFailure(phase.name, phaseErr) then
                local abortReason = tostring(phaseErr or PIPELINE_ABORT_REASON_DEFAULT)
                MarkPipelineAbortRequested(context, abortReason, phase.name)
                NotifyStatusUpdate(context, "safe_abort", abortReason)
                Log.Debug(
                    "Pipeline safe abort requested after phase failure phase="
                        .. tostring(phase.name)
                        .. " reason="
                        .. tostring(phaseErr)
                        .. " abortReason="
                        .. abortReason
                        .. " runId="
                        .. tostring(type(context) == "table" and context.runId or nil)
                )
            end
            if ShouldAbortPipelineAfterFailure(phaseErr) then
                aborted = context and context.firstError or phaseErr or "phase_boundary_abort"
                break
            end
        elseif phaseErr == "deferred" then
            deferred = true
            NotifyStatusUpdate(context, "deferred", phase.name)
            self.pendingContext = {
                build = build,
                context = context,
                phases = phases,
                deferredPhaseName = phase.name,
                nextPhaseIndex = index + 1,
                phaseStartedAt = phaseStartedAt,
            }
            break
        else
            Log.Debug(
                "Pipeline phase end "
                    .. tostring(phase.name)
                    .. " elapsedMs="
                    .. tostring(SHARED_UTIL:GetFrameTimeMillisecondsSafe() - phaseStartedAt)
            )
            self.currentPhaseName = nil
        end
    end

    if not deferred or aborted then
        self.currentPhaseName = nil
        if aborted then
            NotifyPipelineCompletion(context, false, tostring(aborted))
        else
            NotifyPipelineCompletion(context, context and context.hadErrors ~= true, context and context.firstError or nil)
        end
    end
    return true
end

function LTM_PIPELINE:AbortPipeline(reason)
    local normalizedReason = tostring(reason or PIPELINE_ABORT_REASON_DEFAULT)
    if self.isRunning ~= true then
        Log.Debug("Pipeline safe abort requested but no active pipeline reason=" .. normalizedReason)
        return false, "no_active_pipeline"
    end

    local pendingContext = type(self.pendingContext) == "table" and self.pendingContext or nil
    local context = pendingContext and pendingContext.context or self.activeContext
    local phaseName = pendingContext and pendingContext.deferredPhaseName or self.currentPhaseName
    local marked, existingReason = MarkPipelineAbortRequested(context, normalizedReason, phaseName)

    if pendingContext ~= nil and type(pendingContext.context) == "table" and pendingContext.context ~= context then
        MarkPipelineAbortRequested(pendingContext.context, normalizedReason, phaseName)
    end

    if not marked then
        Log.Debug(
            "Pipeline safe abort already requested reason="
                .. tostring(existingReason or normalizedReason)
                .. " phase="
                .. tostring(type(context) == "table" and context.cancelRequestedAtPhase or phaseName)
        )
        return true, "already_requested"
    end

    Log.Debug(
        "Pipeline safe abort requested reason="
            .. normalizedReason
            .. " phase="
            .. tostring(phaseName)
            .. " deferredPhase="
            .. tostring(pendingContext and pendingContext.deferredPhaseName or nil)
            .. " nextPhaseIndex="
            .. tostring(pendingContext and pendingContext.nextPhaseIndex or nil)
    )
    NotifyStatusUpdate(context, "safe_abort", normalizedReason)
    return true
end

function LTM_PIPELINE:ResumeDeferredPhase(success, err)
    local pendingContext = self.pendingContext
    if type(pendingContext) ~= "table" then
        return false
    end

    if not success then
        self.pendingContext = nil
        RecordPhaseFailure(
            pendingContext.context,
            pendingContext.deferredPhaseName,
            err or "deferred_phase_failed"
        )
        local shouldAbortAfterDeferredFailure = ShouldAbortPipelineAfterPhaseFailure(
            pendingContext.deferredPhaseName,
            err
        ) or ShouldAbortPipelineAfterFailure(err)
        if shouldAbortAfterDeferredFailure then
            local abortReason = tostring(err or PIPELINE_ABORT_REASON_DEFAULT)
            MarkPipelineAbortRequested(pendingContext.context, abortReason, pendingContext.deferredPhaseName)
            NotifyStatusUpdate(pendingContext.context, "safe_abort", abortReason)
            Log.Debug(
                "Pipeline safe abort requested after deferred phase failure phase="
                    .. tostring(pendingContext.deferredPhaseName)
                    .. " reason="
                    .. tostring(err)
                    .. " abortReason="
                    .. abortReason
                    .. " runId="
                    .. tostring(
                        type(pendingContext.context) == "table" and pendingContext.context.runId or nil
                    )
            )
        end
        return self:RunPhases(
            pendingContext.build,
            pendingContext.nextPhaseIndex,
            pendingContext.phases,
            pendingContext.context
        )
    end

    self.pendingContext = nil
    Log.Debug(
        "Pipeline phase end "
            .. tostring(pendingContext.deferredPhaseName)
            .. " elapsedMs="
            .. tostring(
                SHARED_UTIL:GetFrameTimeMillisecondsSafe()
                    - (tonumber(pendingContext.phaseStartedAt) or SHARED_UTIL:GetFrameTimeMillisecondsSafe())
            )
    )
    if self:ResetBeforePhaseIfNeeded(pendingContext) then
        return true
    end

    return self:RunPhases(pendingContext.build, pendingContext.nextPhaseIndex, pendingContext.phases, pendingContext.context)
end

function LTM_PIPELINE:Run(build, completion, options)
    if self.isRunning == true then
        return false, "pipeline_busy"
    end

    local ok, err = self:Validate(build)
    if not ok then
        return false, err
    end

    self.activeRunId = (tonumber(self.activeRunId) or 0) + 1
    self.isRunning = true

    options = type(options) == "table" and options or {}
    local partialScope = options.partialScope
    local buildLogName = ResolveLogBuildName(build)

    local context = LTM_PIPELINE_CONTEXT:Create(build, options)
    context.pipelineCompletion = completion
    context.runId = self.activeRunId
    context.logBuildName = buildLogName
    context.phaseErrors = {}
    context.hadErrors = false
    context.firstError = nil
    self.activeContext = context

    Log.LogStart(buildLogName)

    local continuation = function(success, continuationErr)
        return LTM_PIPELINE:ResumeDeferredPhase(success, continuationErr)
    end

    local currentState = {}
    currentState.subclass = LTM_SUBCLASS_SNAPSHOT:CaptureCurrentSubclassState(context)
    LTM_PIPELINE_CONTEXT:SetCurrentState(context, "subclass", currentState.subclass)

    currentState.attributes = LTM_ATTRIBUTE_SNAPSHOT:CaptureCurrentAttributeState(context)
    LTM_PIPELINE_CONTEXT:SetCurrentState(context, "attributes", currentState.attributes)

    currentState.role = LTM_ROLE_STATE:CaptureCurrentRoleState()
    LTM_PIPELINE_CONTEXT:SetCurrentState(context, "role", currentState.role)

    local plan = LTM_PIPELINE_PLANNER:BuildPipelinePlan(context, currentState, build)
    LTM_PIPELINE_CONTEXT:SetResolvedPlan(context, plan)

    local allowedPhases = BuildPartialScopePhaseSet(partialScope)
    if type(allowedPhases) == "table" then
        local filteredPhases = {}
        for _, phaseName in ipairs(plan.phases) do
            if allowedPhases[phaseName] then
                filteredPhases[#filteredPhases + 1] = phaseName
            else
                TracePipeline("Phase skipped by partial scope", "scope=" .. tostring(partialScope), "phase=" .. tostring(phaseName))
            end
        end
        plan.phases = filteredPhases
    end

    if partialScope ~= nil then
        TracePipeline("Partial apply started", "scope=" .. tostring(partialScope), "phases=" .. table.concat(plan.phases, ","))
    end

    local phases = self:BuildPhases(continuation, context)
    return self:RunPhases(build, 1, phases, context)
end

function LTM_PIPELINE:FinishRun(runId)
    if type(runId) ~= "number" or self.activeRunId ~= runId then
        return false
    end

    self.isRunning = false
    if type(self.activeContext) == "table" and self.activeContext.runId == runId then
        self.activeContext = nil
    end
    self.currentPhaseName = nil
    if type(self.pendingContext) == "table" and self.pendingContext.context and self.pendingContext.context.runId == runId then
        self.pendingContext = nil
    end
    return true
end
