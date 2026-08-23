local Addon = LarvalTearMod
local Log = Addon.Common.Log
local Util = Addon.Common.Util
local M = Addon.Modules.TransformSkills

local BASE_MORPH_SLOT = type(MORPH_SLOT_BASE) == "number" and MORPH_SLOT_BASE or 0
local MORPH_ONE_SLOT = type(MORPH_SLOT_MORPH_1) == "number" and MORPH_SLOT_MORPH_1 or 1
local MORPH_TWO_SLOT = type(MORPH_SLOT_MORPH_2) == "number" and MORPH_SLOT_MORPH_2 or 2
local VAMPIRE_BASE_ABILITY_ANCHORS = {
    { abilityId = 32624, name = "Blood Scion" },
    { abilityId = 32893, name = "Eviscerate" },
    { abilityId = 32986, name = "Mist Form" },
}
local KIND_ORDER = { "werewolf", "vampire" }
local SHRINE_ICON_TEXTURES = {
    werewolf = "/esoui/art/icons/ability_werewolf_010.dds",
    vampire = "/esoui/art/icons/ability_vampire_007.dds",
}

local function NormalizeInteger(value, minimum)
    value = tonumber(value)
    minimum = minimum or 0
    if value == nil or value < minimum or math.floor(value) ~= value then
        return nil
    end
    return math.floor(value)
end

local function GetLineId(skillLineData)
    local skillLineId = NormalizeInteger(Util:SafeCallMethod(skillLineData, "GetId"), 1)
    if skillLineId == nil then
        skillLineId = NormalizeInteger(Util:SafeCallMethod(skillLineData, "GetSkillLineId"), 1)
    end
    return skillLineId
end

local function GetSkillLineData(skillData)
    return Util:SafeCallMethod(skillData, "GetSkillLineData")
end

local function GetSkillLineId(skillData)
    local skillLineId = NormalizeInteger(Util:SafeCallMethod(skillData, "GetSkillLineId"), 1)
    if skillLineId == nil then
        skillLineId = GetLineId(GetSkillLineData(skillData))
    end
    return skillLineId
end

local function GetSkillType(skillLineData)
    local skillTypeData = Util:SafeCallMethod(skillLineData, "GetSkillTypeData")
    return NormalizeInteger(Util:SafeCallMethod(skillTypeData, "GetSkillType"), 0)
end

local function IsWorldLine(skillLineData)
    return GetSkillType(skillLineData) == SKILL_TYPE_WORLD
end

local function IsWerewolfLine(skillLineData)
    local skillLineId = GetLineId(skillLineData)
    return skillLineId ~= nil
        and type(IsWerewolfSkillLineById) == "function"
        and Util:SafeCall(IsWerewolfSkillLineById, skillLineId) == true
end

local function GetPlayerCurseKind()
    if type(GetPlayerCurseType) ~= "function" then
        return nil, "player_curse_type_unavailable"
    end
    local curseType = Util:SafeCall(GetPlayerCurseType)
    if type(CURSE_TYPE_WEREWOLF) == "number" and curseType == CURSE_TYPE_WEREWOLF then
        return "werewolf"
    end
    if type(CURSE_TYPE_VAMPIRE) == "number" and curseType == CURSE_TYPE_VAMPIRE then
        return "vampire"
    end
    if type(CURSE_TYPE_NONE) == "number" and curseType == CURSE_TYPE_NONE then
        return nil, nil
    end
    return nil, "player_curse_type_unresolved"
end

local function LogVampireAnchorResolution(skillLineId, matchedAnchorCount, reason)
    if Log.IsSummaryDebugEnabled() ~= true then
        return
    end
    Log.LogDebugSummary(
        "Transform Vampire anchor resolution",
        "lineId=" .. tostring(skillLineId),
        "matchedAnchors=" .. tostring(matchedAnchorCount)
            .. "/" .. tostring(#VAMPIRE_BASE_ABILITY_ANCHORS),
        "reason=" .. tostring(reason or "")
    )
end

local function ResolveVampireAnchorLine(anchor)
    local progressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(anchor.abilityId)
    local skillData = Util:SafeCallMethod(progressionData, "GetSkillData")
    local skillLineData = GetSkillLineData(skillData)
    local skillLineId = GetSkillLineId(skillData)
    if type(skillData) ~= "table"
        or skillLineId == nil
        or not IsWorldLine(skillLineData)
        or IsWerewolfLine(skillLineData)
        or Util:SafeCallMethod(skillData, "IsActive") ~= true
        or Util:SafeCallMethod(skillData, "IsPassive") ~= false
        or Util:SafeCallMethod(skillData, "IsCraftedAbility") ~= false
        or NormalizeInteger(Util:SafeCallMethod(skillData, "GetProgressionId"), 1) == nil then
        return nil, "anchor_guard_failed", anchor.name
    end

    local morphSlot = NormalizeInteger(Util:SafeCallMethod(progressionData, "GetMorphSlot"), 0)
    if morphSlot ~= BASE_MORPH_SLOT then
        return nil, "anchor_not_base_morph", anchor.name
    end
    return skillLineId, nil, nil, skillLineData
end

local function ResolveVampireLine()
    if GetPlayerCurseKind() ~= "vampire"
        or type(SKILLS_DATA_MANAGER) ~= "table"
        or type(SKILLS_DATA_MANAGER.GetProgressionDataByAbilityId) ~= "function" then
        if Log.IsSummaryDebugEnabled() == true then
            LogVampireAnchorResolution(nil, 0, "vampire_gate_or_manager_unavailable")
        end
        return nil
    end

    local resolvedLineId = nil
    local resolvedLineData = nil
    local matchedAnchorCount = 0
    for _, anchor in ipairs(VAMPIRE_BASE_ABILITY_ANCHORS) do
        local anchorLineId, anchorErr, anchorDetail, anchorLineData = ResolveVampireAnchorLine(anchor)
        if anchorLineId == nil then
            if Log.IsSummaryDebugEnabled() == true then
                LogVampireAnchorResolution(
                    resolvedLineId,
                    matchedAnchorCount,
                    tostring(anchorErr) .. ":" .. tostring(anchorDetail)
                )
            end
            return nil
        end
        if resolvedLineId ~= nil and anchorLineId ~= resolvedLineId then
            if Log.IsSummaryDebugEnabled() == true then
                LogVampireAnchorResolution(
                    resolvedLineId,
                    matchedAnchorCount,
                    "anchor_line_mismatch:" .. tostring(resolvedLineId) .. ":" .. tostring(anchorLineId)
                )
            end
            return nil
        end
        resolvedLineId = anchorLineId
        resolvedLineData = resolvedLineData or anchorLineData
        matchedAnchorCount = matchedAnchorCount + 1
    end
    if Log.IsSummaryDebugEnabled() == true then
        LogVampireAnchorResolution(resolvedLineId, matchedAnchorCount, "matched")
    end
    return resolvedLineId, resolvedLineData
end

local function RefreshLine(skillLineData)
    if type(skillLineData) == "table" and type(skillLineData.RefreshDynamicData) == "function" then
        Util:SafeCallMethod(skillLineData, "RefreshDynamicData", true)
    end
    return skillLineData
end

local function GetLineById(skillLineId)
    if type(SKILLS_DATA_MANAGER) ~= "table"
        or type(SKILLS_DATA_MANAGER.GetSkillLineDataById) ~= "function" then
        return nil
    end
    return RefreshLine(SKILLS_DATA_MANAGER:GetSkillLineDataById(skillLineId))
end

local function IsLineUsableForKind(skillLineData, kind, vampireLineId)
    local usable = type(skillLineData) == "table"
        and GetPlayerCurseKind() == kind
        and Util:SafeCallMethod(skillLineData, "IsAvailable") == true
        and Util:SafeCallMethod(skillLineData, "IsActive") == true
    if not usable then
        return false
    end
    if kind == "werewolf" then
        return IsWerewolfLine(skillLineData)
    end
    return kind == "vampire"
        and vampireLineId ~= nil
        and GetLineId(skillLineData) == vampireLineId
end

local function ResolveUsableLine(kind, requestedLineId)
    if GetPlayerCurseKind() ~= kind or type(SKILLS_DATA_MANAGER) ~= "table" then
        return nil
    end

    local skillLineData = nil
    local vampireLineId = nil
    if kind == "vampire" then
        vampireLineId, skillLineData = ResolveVampireLine()
        if vampireLineId == nil
            or (requestedLineId ~= nil and requestedLineId ~= vampireLineId) then
            return nil
        end
        skillLineData = RefreshLine(skillLineData)
    elseif kind == "werewolf" then
        if requestedLineId ~= nil then
            skillLineData = GetLineById(requestedLineId)
        elseif type(SKILLS_DATA_MANAGER.GetWerewolfSkillLineData) == "function" then
            skillLineData = RefreshLine(SKILLS_DATA_MANAGER:GetWerewolfSkillLineData())
        end
    end

    return IsLineUsableForKind(skillLineData, kind, vampireLineId) and skillLineData or nil
end

local function FindAvailableLines()
    local lines = {}
    local curseKind = GetPlayerCurseKind()
    if curseKind == nil
        or type(SKILLS_DATA_MANAGER) ~= "table" then
        return lines
    end

    local skillLineData = ResolveUsableLine(curseKind)
    if skillLineData ~= nil then
        lines[curseKind] = skillLineData
    end
    return lines
end

function M:ResolveLiveOwnerSkillLineSet()
    local ownerSkillLineIds = {}
    local curseKind, curseErr = GetPlayerCurseKind()
    if curseKind == nil then
        if curseErr ~= nil then
            return nil, curseErr
        end
        return ownerSkillLineIds, nil
    end

    local skillLineData = ResolveUsableLine(curseKind)
    local skillLineId = GetLineId(skillLineData)
    if skillLineId == nil then
        return nil, "transform_live_owner_line_unavailable:" .. tostring(curseKind)
    end

    ownerSkillLineIds[skillLineId] = true
    return ownerSkillLineIds, nil
end

local function GetCommittedMorphSlot(skillData)
    local morphSlot = NormalizeInteger(Util:SafeCallMethod(skillData, "GetCurrentMorphSlot"), 0)
    return morphSlot or BASE_MORPH_SLOT
end

local function GetProgressionRank(skillData, morphSlot)
    local progressionData = Util:SafeCallMethod(skillData, "GetProgressionData", morphSlot)
    return NormalizeInteger(Util:SafeCallMethod(progressionData, "GetCurrentRank"), 1)
end

local function CaptureLine(kind, skillLineData, applyEnabled)
    if type(skillLineData) ~= "table" or type(skillLineData.SkillIterator) ~= "function" then
        return nil
    end

    local snapshot = {
        kind = kind,
        skillLineId = GetLineId(skillLineData),
        apply = applyEnabled ~= false,
        skills = {},
    }

    local seenProgressions = {}
    local seenIndexes = {}
    for _, skillData in skillLineData:SkillIterator() do
        if Util:SafeCallMethod(skillData, "IsActive") == true
            and Util:SafeCallMethod(skillData, "IsPassive") ~= true
            and Util:SafeCallMethod(skillData, "IsCraftedAbility") ~= true then
            local progressionId = NormalizeInteger(Util:SafeCallMethod(skillData, "GetProgressionId"), 1)
            local skillIndex = NormalizeInteger(Util:SafeCallMethod(skillData, "GetSkillIndex"), 1)
            if progressionId ~= nil and skillIndex ~= nil then
                if seenIndexes[skillIndex] then
                    return nil, "transform_snapshot_duplicate_skill_index:" .. kind .. ":" .. tostring(skillIndex)
                end
                if seenProgressions[progressionId] then
                    return nil, "transform_snapshot_duplicate_progression_id:" .. kind .. ":" .. tostring(progressionId)
                end
                seenIndexes[skillIndex] = true
                seenProgressions[progressionId] = true
                local purchased = Util:SafeCallMethod(skillData, "IsPurchased") == true
                local morphSlot = purchased and GetCommittedMorphSlot(skillData) or BASE_MORPH_SLOT
                snapshot.skills[#snapshot.skills + 1] = {
                    progressionId = progressionId,
                    skillIndex = skillIndex,
                    purchased = purchased,
                    morphSlot = morphSlot,
                    rank = purchased and GetProgressionRank(skillData, morphSlot) or nil,
                }
            end
        end
    end

    table.sort(snapshot.skills, function(left, right)
        return left.skillIndex < right.skillIndex
    end)
    if snapshot.skillLineId == nil or #snapshot.skills == 0 then
        return nil
    end
    return snapshot
end

function M:CaptureAvailableSnapshots(existingSnapshots)
    local captured = {}
    local lines = FindAvailableLines()
    for _, kind in ipairs(KIND_ORDER) do
        local line = lines[kind]
        if line ~= nil then
            local existing = type(existingSnapshots) == "table" and existingSnapshots[kind] or nil
            local captureErr = nil
            captured[kind], captureErr = CaptureLine(
                kind,
                line,
                type(existing) ~= "table" or existing.apply ~= false
            )
            if captureErr ~= nil then
                return nil, captureErr
            end
        end
    end
    return next(captured) ~= nil and captured or nil
end

local function NormalizeSkillEntry(entry)
    if type(entry) ~= "table" then
        return nil
    end
    local progressionId = NormalizeInteger(entry.progressionId, 1)
    local skillIndex = NormalizeInteger(entry.skillIndex, 1)
    local morphSlot = NormalizeInteger(entry.morphSlot, 0)
    local purchased = entry.purchased == true
    local rank = entry.rank ~= nil and NormalizeInteger(entry.rank, 0) or nil
    if progressionId == nil
        or skillIndex == nil
        or (morphSlot ~= BASE_MORPH_SLOT and morphSlot ~= MORPH_ONE_SLOT and morphSlot ~= MORPH_TWO_SLOT) then
        return nil
    end
    if not purchased then
        morphSlot = BASE_MORPH_SLOT
        rank = nil
    elseif rank ~= nil and rank < 1 then
        return nil
    end
    return {
        progressionId = progressionId,
        skillIndex = skillIndex,
        purchased = purchased,
        morphSlot = morphSlot,
        rank = rank,
    }
end

function M:NormalizeSnapshots(snapshots)
    if snapshots == nil then
        return nil, nil
    end
    if type(snapshots) ~= "table" then
        return nil, "transform_snapshot_not_table"
    end
    if snapshots.__decodeError ~= nil then
        return nil, tostring(snapshots.__decodeError)
    end

    local normalized = {}
    for _, kind in ipairs(KIND_ORDER) do
        local source = snapshots[kind]
        if source ~= nil then
            if type(source) ~= "table" then
                return nil, "transform_line_not_table:" .. kind
            end
            local skillLineId = NormalizeInteger(source.skillLineId, 1)
            if skillLineId == nil or type(source.skills) ~= "table" or #source.skills == 0 then
                return nil, "transform_line_malformed:" .. kind
            end
            local line = {
                kind = kind,
                skillLineId = skillLineId,
                apply = source.apply ~= false,
                skills = {},
            }
            local seenProgressions = {}
            local seenIndexes = {}
            for index, entry in ipairs(source.skills) do
                local skill = NormalizeSkillEntry(entry)
                if skill == nil
                    or seenProgressions[skill.progressionId]
                    or seenIndexes[skill.skillIndex] then
                    return nil, "transform_skill_malformed:" .. kind .. ":" .. tostring(index)
                end
                seenProgressions[skill.progressionId] = true
                seenIndexes[skill.skillIndex] = true
                line.skills[#line.skills + 1] = skill
            end
            table.sort(line.skills, function(left, right)
                return left.skillIndex < right.skillIndex
            end)
            normalized[kind] = line
        end
    end
    if next(normalized) == nil then
        return nil, nil
    end
    return normalized, nil
end

local function ResolveTargetAbilityId(progressionId, morphSlot)
    if type(GetProgressionSkillMorphSlotAbilityId) ~= "function" then
        return nil
    end
    return NormalizeInteger(
        Util:SafeCall(GetProgressionSkillMorphSlotAbilityId, progressionId, morphSlot),
        1
    )
end

local function BuildSlotProgressionTargets(skillConfig, activeTargetStates)
    local byProgression = {}
    local targets = Util:NormalizeSlotTargets(skillConfig)
    local states = type(activeTargetStates) == "table" and activeTargetStates or {}
    for targetIndex, target in ipairs(targets) do
        local resolved = states[targetIndex]
        if type(resolved) ~= "table" then
            resolved = Util:ResolveActiveSkillTargetState(target)
        end
        local progressionId = type(resolved) == "table"
            and NormalizeInteger(resolved.progressionId, 1)
            or nil
        if progressionId ~= nil then
            local morphSlot = NormalizeInteger(resolved.targetMorphSlot, 0)
            local existing = byProgression[progressionId]
            if existing ~= nil and existing.morphSlot ~= morphSlot then
                return nil, "normal_skill_target_conflict:" .. tostring(progressionId)
            end
            byProgression[progressionId] = {
                morphSlot = morphSlot,
                abilityId = resolved.targetAbilityId,
            }
        end
    end
    return byProgression
end

local function AppendBlock(plan, reason)
    if plan.blockReason == nil then
        plan.blockReason = reason
    end
    plan.ok = false
end

local function AppendUnique(target, seen, value)
    if type(value) ~= "string" or value == "" or seen[value] then
        return
    end
    seen[value] = true
    target[#target + 1] = value
end

local function AppendResidual(plan, reason)
    AppendUnique(plan.residuals, plan.residualSet, reason)
end

local function BuildLiveProgressionMap(skillLineData)
    local liveByProgression = {}
    for _, skillData in skillLineData:SkillIterator() do
        if Util:SafeCallMethod(skillData, "IsActive") == true
            and Util:SafeCallMethod(skillData, "IsPassive") ~= true
            and Util:SafeCallMethod(skillData, "IsCraftedAbility") ~= true then
            local progressionId = NormalizeInteger(Util:SafeCallMethod(skillData, "GetProgressionId"), 1)
            if progressionId ~= nil then
                liveByProgression[progressionId] = skillData
            end
        end
    end
    return liveByProgression
end

function M:BuildPlan(snapshots, skillConfig, activeTargetStates)
    local normalized, normalizeErr = self:NormalizeSnapshots(snapshots)
    local plan = {
        ok = true,
        hasTarget = false,
        hasDiff = false,
        targets = {},
        reductions = {},
        appliedSnapshots = {},
        residuals = {},
        residualSet = {},
        skippedKinds = {},
        blockReason = nil,
    }
    if snapshots ~= nil and normalized == nil then
        if normalizeErr ~= nil then
            AppendResidual(plan, normalizeErr)
        end
        return plan
    end
    if normalized == nil then
        return plan
    end

    local slotTargets, slotErr = BuildSlotProgressionTargets(skillConfig, activeTargetStates)
    if slotTargets == nil then
        AppendBlock(plan, slotErr)
        return plan
    end

    for _, kind in ipairs(KIND_ORDER) do
        local targetLine = normalized[kind]
        if type(targetLine) == "table" and targetLine.apply == true then
            local skillLineData = ResolveUsableLine(kind, targetLine.skillLineId)
            if skillLineData == nil then
                AppendResidual(plan, "transform_skill_line_unavailable:" .. kind)
                plan.skippedKinds[kind] = "skill_line_unavailable"
            else
                local liveByProgression = BuildLiveProgressionMap(skillLineData)
                local laneValid = true
                local laneTargets = {}
                local laneReductions = {}
                local laneHasDiff = false
                for _, targetSkill in ipairs(targetLine.skills) do
                    local skillData = liveByProgression[targetSkill.progressionId]
                    local slotTarget = slotTargets[targetSkill.progressionId]
                    if type(skillData) ~= "table" then
                        AppendResidual(
                            plan,
                            "transform_progression_unavailable:" .. kind .. ":" .. tostring(targetSkill.progressionId)
                        )
                        laneValid = false
                    else
                        local slotTargetConflict = slotTarget ~= nil
                            and (targetSkill.purchased ~= true
                                or slotTarget.morphSlot ~= targetSkill.morphSlot)
                        if slotTargetConflict then
                            AppendResidual(
                                plan,
                                "transform_slot_target_precedence:" .. tostring(targetSkill.progressionId)
                            )
                        end

                        if targetSkill.purchased == true then
                            local targetAbilityId = ResolveTargetAbilityId(
                                targetSkill.progressionId,
                                targetSkill.morphSlot
                            )
                            if targetAbilityId == nil then
                                AppendResidual(
                                    plan,
                                    "transform_target_ability_unavailable:" .. tostring(targetSkill.progressionId)
                                )
                                laneValid = false
                            else
                                local retainedRank = GetProgressionRank(skillData, targetSkill.morphSlot)
                                if retainedRank == nil or targetSkill.rank == nil then
                                    AppendResidual(
                                        plan,
                                        "transform_rank_exact_unavailable:" .. kind .. ":"
                                            .. tostring(targetSkill.progressionId)
                                            .. ":saved=" .. tostring(targetSkill.rank)
                                            .. ":retained=" .. tostring(retainedRank)
                                    )
                                elseif retainedRank ~= targetSkill.rank then
                                    AppendResidual(
                                        plan,
                                        "transform_rank_not_restorable:" .. kind .. ":"
                                            .. tostring(targetSkill.progressionId)
                                            .. ":saved=" .. tostring(targetSkill.rank)
                                            .. ":retained=" .. tostring(retainedRank)
                                    )
                                end
                                local currentPurchased = Util:SafeCallMethod(skillData, "IsPurchased") == true
                                local currentMorphSlot = currentPurchased
                                    and GetCommittedMorphSlot(skillData)
                                    or BASE_MORPH_SLOT
                                if slotTarget == nil then
                                    laneTargets[#laneTargets + 1] = {
                                        targetAbilityId = targetAbilityId,
                                        targetMorphSlot = targetSkill.morphSlot,
                                        currentPurchased = currentPurchased,
                                        currentMorphSlot = currentMorphSlot,
                                        costMultiplier = NormalizeInteger(
                                            Util:SafeCallMethod(skillData, "GetSkillPointCostMultiplier"),
                                            1
                                        ),
                                        transformKind = kind,
                                        skillLineId = targetLine.skillLineId,
                                        progressionId = targetSkill.progressionId,
                                    }
                                    if not currentPurchased or currentMorphSlot ~= targetSkill.morphSlot then
                                        laneHasDiff = true
                                    end
                                end
                            end
                        else
                            local currentPurchased = Util:SafeCallMethod(skillData, "IsPurchased") == true
                            if currentPurchased and slotTarget == nil then
                                laneHasDiff = true
                                if Util:SafeCallMethod(skillData, "IsAutoGrant") == true then
                                    AppendResidual(
                                        plan,
                                        "transform_auto_grant_unpurchase_not_restorable:"
                                            .. tostring(targetSkill.progressionId)
                                    )
                                    laneValid = false
                                end
                                laneReductions[#laneReductions + 1] = {
                                    transformKind = kind,
                                    skillLineId = targetLine.skillLineId,
                                    progressionId = targetSkill.progressionId,
                                    action = "clear",
                                }
                            end
                        end
                    end
                end

                if laneValid then
                    plan.hasTarget = true
                    plan.hasDiff = plan.hasDiff or laneHasDiff
                    -- targetLine belongs to this newly normalized plan and is not
                    -- exposed through the input snapshot, so no second copy is needed.
                    plan.appliedSnapshots[kind] = targetLine
                    for _, target in ipairs(laneTargets) do
                        plan.targets[#plan.targets + 1] = target
                    end
                    for _, reduction in ipairs(laneReductions) do
                        plan.reductions[#plan.reductions + 1] = reduction
                    end
                else
                    plan.skippedKinds[kind] = "lane_validation_failed"
                end
            end
        end
    end
    if next(plan.appliedSnapshots) == nil then
        plan.appliedSnapshots = nil
    end
    return plan
end

local function RecordPartial(pipelineContext, reasons, residualSummary)
    if type(pipelineContext) ~= "table"
        or type(reasons) ~= "table"
        or #reasons == 0 then
        return
    end
    Addon.Modules.PipelineContext:RecordDomainResult(pipelineContext, {
        domain = "TransformSkills",
        sourcePhase = "Skills",
        severity = "partial",
        resultCode = "transform_partial",
        reasons = reasons,
        residualSummary = residualSummary,
    })
end

local function WarnUnavailableKinds(pipelineContext, skippedKinds)
    if type(pipelineContext) ~= "table" or type(skippedKinds) ~= "table" then
        return
    end
    pipelineContext.transformUnavailableWarnings = pipelineContext.transformUnavailableWarnings or {}
    for _, kind in ipairs(KIND_ORDER) do
        if skippedKinds[kind] == "skill_line_unavailable"
            and not pipelineContext.transformUnavailableWarnings[kind] then
            pipelineContext.transformUnavailableWarnings[kind] = true
            local stringId = kind == "werewolf"
                and "SI_LTM_TRANSFORM_WARNING_LINE_UNAVAILABLE_WEREWOLF"
                or "SI_LTM_TRANSFORM_WARNING_LINE_UNAVAILABLE_VAMPIRE"
            Log.WriteImportantChat(Addon.GetStringText(stringId))
        end
    end
end

local function WarnIncompleteKinds(pipelineContext, kinds)
    if type(pipelineContext) ~= "table" or type(kinds) ~= "table" then
        return
    end
    pipelineContext.transformIncompleteWarnings =
        pipelineContext.transformIncompleteWarnings or {}
    for _, kind in ipairs(KIND_ORDER) do
        if kinds[kind] == true and not pipelineContext.transformIncompleteWarnings[kind] then
            pipelineContext.transformIncompleteWarnings[kind] = true
            local stringId = kind == "werewolf"
                and "SI_LTM_TRANSFORM_WARNING_APPLY_INCOMPLETE_WEREWOLF"
                or "SI_LTM_TRANSFORM_WARNING_APPLY_INCOMPLETE_VAMPIRE"
            Log.WriteImportantChat(Addon.GetStringText(stringId))
        end
    end
end

function M:RecordPlanResiduals(pipelineContext, plan)
    if type(pipelineContext) ~= "table"
        or type(pipelineContext.runId) ~= "number"
        or type(plan) ~= "table" then
        return
    end
    RecordPartial(pipelineContext, plan.residuals, {
        skippedKinds = Util:DeepCopy(plan.skippedKinds or {}),
        residualCount = #(plan.residuals or {}),
    })
    WarnUnavailableKinds(pipelineContext, plan.skippedKinds)
end

function M:VerifySnapshots(snapshots, pipelineContext, options)
    local normalized, normalizeErr = self:NormalizeSnapshots(snapshots)
    local expectedMissing = type(options) == "table" and options.expectedMissingProgressionSet or nil
    local expectedMissingPurchases = type(expectedMissing) == "table" and expectedMissing.purchases or {}
    local expectedMissingMorphs = type(expectedMissing) == "table" and expectedMissing.morphs or {}
    local residuals = {}
    local residualSet = {}
    local incompleteKinds = {}
    if snapshots ~= nil and normalized == nil then
        if normalizeErr ~= nil then
            AppendUnique(residuals, residualSet, normalizeErr)
        end
    elseif normalized ~= nil then
        for _, kind in ipairs(KIND_ORDER) do
            local targetLine = normalized[kind]
            if type(targetLine) == "table" and targetLine.apply == true then
                local currentLine = CaptureLine(
                    kind,
                    ResolveUsableLine(kind, targetLine.skillLineId),
                    true
                )
                if type(currentLine) == "table" then
                    local currentByProgression = {}
                    for _, currentSkill in ipairs(currentLine.skills) do
                        currentByProgression[currentSkill.progressionId] = currentSkill
                    end
                    for _, targetSkill in ipairs(targetLine.skills) do
                        local currentSkill = currentByProgression[targetSkill.progressionId]
                        local progressionExpectedMissing = expectedMissingPurchases[targetSkill.progressionId] ~= nil
                            or expectedMissingMorphs[targetSkill.progressionId] ~= nil
                        if not progressionExpectedMissing
                            and type(currentSkill) == "table"
                            and currentSkill.purchased == targetSkill.purchased
                            and currentSkill.morphSlot == targetSkill.morphSlot
                            and targetSkill.purchased == true then
                            if targetSkill.rank == nil or currentSkill.rank == nil then
                                AppendUnique(
                                    residuals,
                                    residualSet,
                                    "transform_rank_exact_unavailable:" .. kind .. ":"
                                        .. tostring(targetSkill.progressionId)
                                        .. ":saved=" .. tostring(targetSkill.rank)
                                        .. ":current=" .. tostring(currentSkill.rank)
                                )
                                incompleteKinds[kind] = true
                            elseif currentSkill.rank ~= targetSkill.rank then
                                AppendUnique(
                                    residuals,
                                    residualSet,
                                    "transform_rank_not_restorable:" .. kind .. ":"
                                        .. tostring(targetSkill.progressionId)
                                        .. ":saved=" .. tostring(targetSkill.rank)
                                        .. ":current=" .. tostring(currentSkill.rank)
                                )
                                incompleteKinds[kind] = true
                            end
                        end
                    end
                end
            end
        end
    end

    RecordPartial(pipelineContext, residuals, {
        stage = "post_commit_verify",
        residualCount = #residuals,
    })
    WarnIncompleteKinds(pipelineContext, incompleteKinds)
    return {
        ok = true,
        matched = true,
        exactMatched = #residuals == 0,
        reason = #residuals > 0 and residuals[1] or "transform_matched",
        residuals = residuals,
    }
end

function M:GetDisplayEntries(snapshots)
    local normalized = self:NormalizeSnapshots(snapshots)
    local entries = {}
    for _, kind in ipairs(KIND_ORDER) do
        local line = type(normalized) == "table" and normalized[kind] or nil
        if type(line) == "table" then
            local displaySkills = {}
            for _, skill in ipairs(line.skills) do
                local abilityId = ResolveTargetAbilityId(skill.progressionId, skill.morphSlot)
                local abilityName = type(GetAbilityName) == "function"
                    and abilityId ~= nil
                    and Util:SafeCall(GetAbilityName, abilityId)
                    or nil
                local iconTexture = type(GetAbilityIcon) == "function"
                    and abilityId ~= nil
                    and Util:SafeCall(GetAbilityIcon, abilityId)
                    or nil
                displaySkills[#displaySkills + 1] = {
                    progressionId = skill.progressionId,
                    skillIndex = skill.skillIndex,
                    purchased = skill.purchased,
                    morphSlot = skill.morphSlot,
                    rank = skill.rank,
                    abilityId = abilityId,
                    abilityName = type(abilityName) == "string" and abilityName or "",
                    iconTexture = type(iconTexture) == "string" and iconTexture or "",
                }
            end
            entries[#entries + 1] = {
                kind = kind,
                skillLineId = line.skillLineId,
                apply = line.apply == true,
                skills = displaySkills,
                iconTexture = SHRINE_ICON_TEXTURES[kind],
            }
        end
    end
    return entries
end

function M:GetCurrentDisplayEntries()
    return self:GetDisplayEntries(self:CaptureAvailableSnapshots())
end

function M:LogPlan(plan)
    if Log.IsSummaryDebugEnabled() ~= true then
        return
    end
    Log.LogDebugSummary(
        "Transform skill plan",
        "ok=" .. tostring(type(plan) == "table" and plan.ok == true),
        "hasTarget=" .. tostring(type(plan) == "table" and plan.hasTarget == true),
        "hasDiff=" .. tostring(type(plan) == "table" and plan.hasDiff == true),
        "targets=" .. tostring(type(plan) == "table" and #(plan.targets or {}) or 0),
        "reductions=" .. tostring(type(plan) == "table" and #(plan.reductions or {}) or 0),
        "residuals=" .. tostring(type(plan) == "table" and #(plan.residuals or {}) or 0),
        "reason=" .. tostring(type(plan) == "table" and plan.blockReason or "")
    )
end
