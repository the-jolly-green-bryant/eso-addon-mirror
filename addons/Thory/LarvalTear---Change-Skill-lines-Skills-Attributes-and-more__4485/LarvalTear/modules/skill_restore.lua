local Addon = LarvalTearMod
local LTM = Addon
local Log = Addon.Common.Log
local LTM_SKILL_RESTORE = Addon.Modules.SkillRestore
local LTM_TRANSFORM_SKILLS = Addon.Modules.TransformSkills

-- Route A restore-only lane.
-- This module restores slots/action bar state and must not own any respec,
-- morph, subclass, or purchase responsibilities.

local SHARED_UTIL = Addon.Common.Util
local FIRST_ASSIGNABLE_SLOT = 3
local LAST_ASSIGNABLE_SLOT = 8
local RESULT_APPLIED = "applied"
local RESULT_SKIPPED = "skipped"
local RESULT_ERROR = "error"
local CRYPT_CANON_ITEM_ID = 194509
local CRYPT_CANON_SPECIAL_ULTIMATE_ID = 195031

local function IsSummaryDebugEnabled()
    return type(Log.IsSummaryDebugEnabled) == "function" and Log.IsSummaryDebugEnabled() == true
end

local function ResolveDisplaySlot(slotIndex)
    if slotIndex == 8 then
        return "ult"
    end

    if slotIndex >= 3 and slotIndex <= 7 then
        return tostring(slotIndex - 2)
    end

    return "invalid"
end

local function NormalizeTargets(config)
    if type(SHARED_UTIL) == "table" and type(SHARED_UTIL.NormalizeSlotTargets) == "function" then
        return SHARED_UTIL:NormalizeSlotTargets(config)
    end

    return {}
end

local function GetPendingSlotAbilityId(slotIndex, hotbarCategory)
    if type(ACTION_BAR_ASSIGNMENT_MANAGER) ~= "table"
        or type(ACTION_BAR_ASSIGNMENT_MANAGER.GetHotbar) ~= "function" then
        return nil
    end

    local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarCategory)
    if type(hotbar) ~= "table" or type(hotbar.GetSlotData) ~= "function" then
        return nil
    end

    local slotAction = hotbar:GetSlotData(slotIndex)
    if type(slotAction) ~= "table" then
        return nil
    end

    if type(slotAction.IsEmpty) == "function" and slotAction:IsEmpty() then
        return 0
    end

    if type(slotAction.GetEffectiveAbilityId) == "function" then
        local effectiveAbilityId = slotAction:GetEffectiveAbilityId()
        if effectiveAbilityId ~= nil then
            return effectiveAbilityId
        end
    end

    if type(slotAction.GetActionId) == "function" then
        local actionId = slotAction:GetActionId()
        if actionId ~= nil then
            return actionId
        end
    end

    return nil
end

local function GetPendingSlotAction(slotIndex, hotbarCategory)
    if type(ACTION_BAR_ASSIGNMENT_MANAGER) ~= "table"
        or type(ACTION_BAR_ASSIGNMENT_MANAGER.GetHotbar) ~= "function" then
        return nil
    end

    local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarCategory)
    if type(hotbar) ~= "table" or type(hotbar.GetSlotData) ~= "function" then
        return nil
    end

    local slotAction = hotbar:GetSlotData(slotIndex)
    return type(slotAction) == "table" and slotAction or nil
end

local function FindExistingSlotForAbility(hotbarCategory, targetAbilityId, excludeSlotIndex)
    if type(targetAbilityId) ~= "number" or targetAbilityId <= 0 then
        return nil
    end

    for slotIndex = FIRST_ASSIGNABLE_SLOT, LAST_ASSIGNABLE_SLOT do
        if slotIndex ~= excludeSlotIndex and GetPendingSlotAbilityId(slotIndex, hotbarCategory) == targetAbilityId then
            return slotIndex
        end
    end

    return nil
end

local function IsAssignableSlot(slotIndex)
    return slotIndex >= FIRST_ASSIGNABLE_SLOT and slotIndex <= LAST_ASSIGNABLE_SLOT
end

local function ResolveEquipmentEntryItemId(entry)
    if type(entry) ~= "table" then
        return nil
    end

    local itemId = tonumber(entry.itemId)
    if itemId ~= nil and itemId > 0 then
        return math.floor(itemId)
    end

    local itemLink = entry.itemLink
    if type(itemLink) == "string" and itemLink ~= "" and type(GetItemLinkItemId) == "function" then
        local resolvedItemId = GetItemLinkItemId(itemLink)
        if type(resolvedItemId) == "number" and resolvedItemId > 0 then
            return resolvedItemId
        end
    end

    return nil
end

local function CreateResult(target, status, reason, extra)
    local result = {
        hotbarCategory = target.hotbarCategory,
        slotIndex = target.slotIndex,
        targetAbilityId = target.abilityId,
        slotActionType = target.slotActionType,
        craftedAbilityId = target.craftedAbilityId,
        progressionId = target.progressionId,
        deferredTransformKind = target.deferredTransformKind,
        targetTransformPurchased = target.targetTransformPurchased,
        status = status,
        reason = reason,
    }

    if type(extra) == "table" then
        for key, value in pairs(extra) do
            result[key] = value
        end
    end

    return result
end

local function ResolvePostStateMatchesTarget(target, resultState, targetSkillData, slotAction)
    if type(target) ~= "table" then
        return nil
    end

    local targetAbilityId = tonumber(target.abilityId)
    local normalizedResultState = tonumber(resultState)
    if targetAbilityId ~= nil
        and normalizedResultState ~= nil
        and normalizedResultState == targetAbilityId then
        return true
    end

    if type(targetSkillData) ~= "table" or type(slotAction) ~= "table" then
        return false
    end

    if type(slotAction.EqualsSkillData) == "function"
        and slotAction:EqualsSkillData(targetSkillData) == true then
        return true
    end

    local pendingSkillData = type(slotAction.GetPlayerSkillData) == "function"
        and slotAction:GetPlayerSkillData()
        or slotAction.skillData
    if pendingSkillData == targetSkillData then
        return true
    end

    local targetProgressionId = tonumber(target.progressionId)
    if targetProgressionId == nil and type(targetSkillData.GetProgressionId) == "function" then
        targetProgressionId = tonumber(targetSkillData:GetProgressionId())
    end
    local pendingProgressionId = type(pendingSkillData) == "table"
        and type(pendingSkillData.GetProgressionId) == "function"
        and tonumber(pendingSkillData:GetProgressionId())
        or nil
    return targetProgressionId ~= nil
        and pendingProgressionId ~= nil
        and targetProgressionId == pendingProgressionId
end

local function SummarizeResults(results)
    local summary = {
        total = #results,
        applied = 0,
        skipped = 0,
        errors = 0,
        warningCount = 0,
        reasonCounts = {},
    }

    for _, result in ipairs(results) do
        if result.status == RESULT_APPLIED then
            summary.applied = summary.applied + 1
        elseif result.status == RESULT_ERROR then
            summary.errors = summary.errors + 1
        else
            summary.skipped = summary.skipped + 1
        end

        if type(result) == "table" and result.warning == true then
            summary.warningCount = summary.warningCount + 1
        end

        local reason = type(result) == "table" and tostring(result.reason or "unknown") or "unknown"
        summary.reasonCounts[reason] = (summary.reasonCounts[reason] or 0) + 1
    end

    return summary
end

local function BuildReasonSummary(results)
    local counts = {}
    local orderedReasons = {}

    for _, result in ipairs(results or {}) do
        local reason = tostring(type(result) == "table" and result.reason or "unknown")
        if counts[reason] == nil then
            counts[reason] = 0
            orderedReasons[#orderedReasons + 1] = reason
        end
        counts[reason] = counts[reason] + 1
    end

    table.sort(orderedReasons)

    local parts = {}
    for _, reason in ipairs(orderedReasons) do
        parts[#parts + 1] = string.format("%s=%s", reason, tostring(counts[reason]))
    end

    return #parts > 0 and table.concat(parts, ",") or "none"
end

local CloneScriptIds

local function BuildRestorePathSamples(results, limit)
    limit = limit or 5
    local samples = {}

    for _, result in ipairs(results or {}) do
        local include = type(result) == "table"
            and (result.restorePath == "crafted" or result.reason == "unknown_ability")
        if include then
            samples[#samples + 1] = string.format(
                "%s:%s:%s:craftedAbilityId=%s:fallbackCraftedAbilityId=%s:source=%s:path=%s:reason=%s",
                tostring(result.hotbarCategory),
                tostring(result.slotIndex),
                tostring(result.targetAbilityId),
                tostring(result.resolvedCraftedAbilityId or result.craftedAbilityId),
                tostring(result.fallbackCraftedAbilityId),
                tostring(result.craftedResolveSource),
                tostring(result.restorePath or "normal"),
                tostring(result.reason)
            )
            if #samples >= limit then
                break
            end
        end
    end

    return #samples > 0 and table.concat(samples, "|") or nil
end

local function FormatScriptIds(scriptIds)
    scriptIds = CloneScriptIds(scriptIds)
    if scriptIds == nil then
        return "nil"
    end

    return table.concat({
        tostring(scriptIds[1] or 0),
        tostring(scriptIds[2] or 0),
        tostring(scriptIds[3] or 0),
    }, ",")
end

local function BuildWarningSamples(results, limit)
    limit = limit or 5
    local samples = {}

    for _, result in ipairs(results or {}) do
        if type(result) == "table" and result.warning == true then
            samples[#samples + 1] = string.format(
                "%s:%s:%s:craftedAbilityId=%s:method=%s:savedScripts=%s:currentScripts=%s:savedEffectiveAbilityId=%s:currentEffectiveAbilityId=%s:reason=%s",
                tostring(result.hotbarCategory),
                tostring(result.slotIndex),
                tostring(result.targetAbilityId),
                tostring(result.resolvedCraftedAbilityId or result.craftedAbilityId),
                tostring(result.warningMethod),
                FormatScriptIds(result.savedScriptIds),
                FormatScriptIds(result.activeScriptIds),
                tostring(result.savedEffectiveAbilityId),
                tostring(result.currentEffectiveAbilityId),
                tostring(result.reason)
            )
            if #samples >= limit then
                break
            end
        end
    end

    return #samples > 0 and table.concat(samples, "|") or nil
end

local function GetPendingSlotActionDetails(slotIndex, hotbarCategory)
    if type(ACTION_BAR_ASSIGNMENT_MANAGER) ~= "table"
        or type(ACTION_BAR_ASSIGNMENT_MANAGER.GetHotbar) ~= "function" then
        return nil, nil, nil
    end

    local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarCategory)
    if type(hotbar) ~= "table" or type(hotbar.GetSlotData) ~= "function" then
        return nil, nil, nil
    end

    local slotAction = hotbar:GetSlotData(slotIndex)
    if type(slotAction) ~= "table" then
        return nil, nil, nil
    end

    local actionType = type(slotAction.GetActionType) == "function" and slotAction:GetActionType() or nil
    local actionId = type(slotAction.GetActionId) == "function" and slotAction:GetActionId() or nil
    local effectiveAbilityId = type(slotAction.GetEffectiveAbilityId) == "function" and slotAction:GetEffectiveAbilityId() or nil
    return actionType, actionId, effectiveAbilityId
end

local function ResolveCraftedAbilityBaseId(abilityId)
    if type(abilityId) ~= "number" or abilityId <= 0 then
        return nil
    end

    if type(GetAbilityIdForCraftedAbilityId) ~= "function" then
        return nil
    end

    local ok, baseAbilityId = pcall(GetAbilityIdForCraftedAbilityId, abilityId)
    if not ok or type(baseAbilityId) ~= "number" or baseAbilityId <= 0 then
        return nil
    end

    return baseAbilityId
end

function CloneScriptIds(scriptIds)
    if type(scriptIds) ~= "table" then
        return nil
    end

    local normalized = {}
    local hasValue = false
    for index = 1, 3 do
        local scriptId = tonumber(scriptIds[index])
        if scriptId ~= nil and scriptId > 0 then
            normalized[index] = math.floor(scriptId)
            hasValue = true
        else
            normalized[index] = 0
        end
    end

    if hasValue then
        return normalized
    end

    return nil
end

local function ResolveStoredCraftedAbilityId(target)
    if type(SHARED_UTIL) == "table" and type(SHARED_UTIL.ResolveCraftedAbilityTarget) == "function" then
        local craftedInfo = SHARED_UTIL:ResolveCraftedAbilityTarget(target)
        local craftedAbilityId = type(craftedInfo) == "table" and tonumber(craftedInfo.craftedAbilityId) or nil
        if craftedAbilityId ~= nil and craftedAbilityId > 0 then
            return math.floor(craftedAbilityId), craftedInfo
        end
    end

    return nil
end

local function IsCraftedSlotTarget(target)
    if type(target) ~= "table" then
        return false, nil
    end

    if type(SHARED_UTIL) == "table" and type(SHARED_UTIL.ResolveCraftedAbilityTarget) == "function" then
        local craftedInfo = SHARED_UTIL:ResolveCraftedAbilityTarget(target)
        return type(craftedInfo) == "table" and craftedInfo.isCrafted == true, craftedInfo
    end

    return false, nil
end

local function ResolveCraftedActiveScriptIds(craftedAbilityId)
    if type(craftedAbilityId) ~= "number" or craftedAbilityId <= 0 then
        return nil
    end

    if type(GetCraftedAbilityActiveScriptIds) ~= "function" then
        return nil
    end

    local ok, primaryScriptId, secondaryScriptId, tertiaryScriptId =
        pcall(GetCraftedAbilityActiveScriptIds, craftedAbilityId)
    if not ok then
        return nil
    end

    return CloneScriptIds({ primaryScriptId, secondaryScriptId, tertiaryScriptId })
end

local function AreScriptIdsEqual(left, right)
    left = CloneScriptIds(left)
    right = CloneScriptIds(right)
    if left == nil or right == nil then
        return nil
    end

    for index = 1, 3 do
        if (left[index] or 0) ~= (right[index] or 0) then
            return false
        end
    end

    return true
end

local function ResolveCraftedMismatch(target, craftedAbilityId, savedScriptIds, activeScriptIds)
    local scriptMatch = AreScriptIdsEqual(savedScriptIds, activeScriptIds)
    if savedScriptIds ~= nil and scriptMatch == false then
        return true, "saved_script_ids", nil, nil
    end

    if savedScriptIds ~= nil then
        return false, nil, nil, nil
    end

    local savedEffectiveAbilityId = type(target) == "table" and tonumber(target.abilityId) or nil
    local currentEffectiveAbilityId = ResolveCraftedAbilityBaseId(craftedAbilityId)
    if savedEffectiveAbilityId ~= nil
        and savedEffectiveAbilityId > 0
        and currentEffectiveAbilityId ~= nil
        and currentEffectiveAbilityId > 0
        and math.floor(savedEffectiveAbilityId) ~= math.floor(currentEffectiveAbilityId) then
        return true, "legacy_effective_ability_id", math.floor(savedEffectiveAbilityId), currentEffectiveAbilityId
    end

    return false, nil, savedEffectiveAbilityId, currentEffectiveAbilityId
end

local function ResolveCraftedSkillData(craftedAbilityId)
    if type(craftedAbilityId) ~= "number" or craftedAbilityId <= 0 then
        return nil
    end

    if type(SCRIBING_DATA_MANAGER) ~= "table"
        or type(SCRIBING_DATA_MANAGER.GetCraftedAbilityData) ~= "function" then
        return nil
    end

    local craftedAbilityData = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(craftedAbilityId)
    if type(craftedAbilityData) ~= "table" or type(craftedAbilityData.GetSkillData) ~= "function" then
        return nil
    end

    return craftedAbilityData:GetSkillData(), craftedAbilityData
end

function LTM_SKILL_RESTORE:GetLastResult()
    return self.lastResult
end

function LTM_SKILL_RESTORE:Log(...)
    if type(Log.LogDebugSummary) == "function" then
        Log.LogDebugSummary("Skill restore summary", ...)
    end
end

function LTM_SKILL_RESTORE:NotifyScriptMismatch(summary)
    if type(summary) ~= "table" or (summary.warningCount or 0) <= 0 then
        return false
    end

    if type(Log.WriteChat) == "function" and type(LTM) == "table" and type(LTM.GetStringText) == "function" then
        Log.WriteChat(LTM.GetStringText("SI_LTM_STATUS_SCRIPT_MISMATCH"))
        return true
    end

    return false
end

function LTM_SKILL_RESTORE:ResolveCryptCanonState(config)
    local pipelineContext = type(config) == "table" and config._pipelineContext or nil
    local targetBuild = type(pipelineContext) == "table" and pipelineContext.targetBuild or nil
    local targetEquipment = type(targetBuild) == "table" and targetBuild.equipment or nil
    local targetChestItemId = ResolveEquipmentEntryItemId(type(targetEquipment) == "table" and targetEquipment[EQUIP_SLOT_CHEST] or nil)
    local state = {
        currentEquipped = type(GetItemId) == "function"
            and GetItemId(BAG_WORN, EQUIP_SLOT_CHEST) == CRYPT_CANON_ITEM_ID
            or false,
        targetIncludes = targetChestItemId == CRYPT_CANON_ITEM_ID,
        overwriteNoticeShown = false,
    }
    state.active = state.currentEquipped == true or state.targetIncludes == true
    return state
end

function LTM_SKILL_RESTORE:NotifyCryptCanonOverwriteRequired(state)
    if type(state) ~= "table" or state.overwriteNoticeShown == true then
        return
    end

    state.overwriteNoticeShown = true
    if type(Log.WriteChat) == "function" and type(LTM) == "table" and type(LTM.GetStringText) == "function" then
        Log.WriteChat(LTM.GetStringText("SI_LTM_STATUS_CRYPTCANON_OVERWRITE_REQUIRED"))
    end
end

function LTM_SKILL_RESTORE:LogTargetSummary(targets)
    local frontCount = 0
    local backCount = 0

    for _, target in ipairs(targets or {}) do
        if type(target) == "table" then
            if target.hotbarCategory == 0 then
                frontCount = frontCount + 1
            elseif target.hotbarCategory == 1 then
                backCount = backCount + 1
            end
        end
    end

    local note = backCount == 0 and "back_bar_targets_missing" or "ok"
    self:Log(
        "targets",
        "frontCount=" .. tostring(frontCount),
        "backCount=" .. tostring(backCount),
        "total=" .. tostring(#(targets or {})),
        "note=" .. tostring(note)
    )
end

function LTM_SKILL_RESTORE:ValidateA1Config(config)
    config = config or {}

    if type(config.subclassChanges) == "table" and next(config.subclassChanges) ~= nil then
        return false, "route_a1_disallows_subclass_changes"
    end

    if type(config.morphChanges) == "table" and next(config.morphChanges) ~= nil then
        return false, "route_a1_disallows_morph_changes"
    end

    return true
end

function LTM_SKILL_RESTORE:RunInternal(config, mode)
    config = config or {}
    mode = mode or "normal"
    local pipelineContext = type(config) == "table" and config._pipelineContext or nil

    if mode ~= "post_route_b" then
        local ok, err = self:ValidateA1Config(config)
        if not ok then
            return false, err
        end
    end

    local interactionType = type(GetInteractionType) == "function" and GetInteractionType() or nil
    if interactionType == INTERACTION_SKILL_RESPEC then
        if mode ~= "post_route_b" then
            return false, "route_a1_requires_non_respec_state"
        end
    end

    if type(ACTION_BAR_ASSIGNMENT_MANAGER) ~= "table" then
        return false, "action_bar_assignment_manager_unavailable"
    end

    if type(SKILLS_DATA_MANAGER) ~= "table" then
        return false, "skills_data_manager_unavailable"
    end

    local targets = NormalizeTargets(config)
    local deferredTargets, deferredResolveErrors =
        LTM_TRANSFORM_SKILLS:ResolveDeferredSlotTargets(config.deferredTransformSlots)
    for _, target in ipairs(deferredTargets or {}) do
        targets[#targets + 1] = target
    end

    if #targets == 0 and #(deferredResolveErrors or {}) == 0 then
        self.lastResult = {
            route = "route_a1",
            results = {},
            summary = SummarizeResults({}),
        }
        self:Log("mode=" .. tostring(mode), "total=0", "applied=0", "skipped=0", "errors=0")
        Log.Debug("Skill restore finished")
        return true
    end

    self:LogTargetSummary(targets)
    self._cryptCanonState = self:ResolveCryptCanonState(config)

    local results = {}
    for _, target in ipairs(deferredResolveErrors or {}) do
        results[#results + 1] = CreateResult(
            target,
            RESULT_ERROR,
            target.resolveError or "transform_deferred_slot_resolve_failed",
            {
                assignInvoked = false,
                assignSucceeded = nil,
                alreadyMatched = false,
            }
        )
    end
    for _, target in ipairs(targets) do
        local result = self:RestoreSingleSlot(target)
        results[#results + 1] = result
    end

    local summary = SummarizeResults(results)
    local reasonSummary = BuildReasonSummary(results)
    self.lastResult = {
        route = "route_a1",
        results = results,
        summary = summary,
        reasonSummary = reasonSummary,
    }

    self:Log(
        "mode=" .. tostring(mode),
        "total=" .. tostring(summary.total),
        "applied=" .. tostring(summary.applied),
        "skipped=" .. tostring(summary.skipped),
        "errors=" .. tostring(summary.errors),
        "warnings=" .. tostring(summary.warningCount or 0)
    )
    self:Log("reasonSummary=" .. tostring(reasonSummary))
    local scriptMismatchNotified = self:NotifyScriptMismatch(summary)
    if IsSummaryDebugEnabled() then
        local pathSamples = BuildRestorePathSamples(results)
        if pathSamples ~= nil then
            self:Log("pathSamples=" .. pathSamples)
        end
        local warningSamples = BuildWarningSamples(results)
        if warningSamples ~= nil then
            self:Log(
                "warningSamples=" .. warningSamples,
                "warningCount=" .. tostring(summary.warningCount or 0),
                "notified=" .. tostring(scriptMismatchNotified == true)
            )
        end
    end
    Log.Debug("Skill restore finished")
    self._cryptCanonState = nil
    if config._suppressTransformDeferredPartial ~= true then
        LTM_TRANSFORM_SKILLS:RecordDeferredRestoreResults(pipelineContext, results)
    end
    return true
end

function LTM_SKILL_RESTORE:RestoreCraftedSlot(target, hotbarData, currentAbilityId, craftedInfo)
    if type(craftedInfo) ~= "table" then
        craftedInfo = select(2, ResolveStoredCraftedAbilityId(target))
    end
    local craftedAbilityId = type(craftedInfo) == "table" and tonumber(craftedInfo.craftedAbilityId) or nil
    if craftedAbilityId ~= nil and craftedAbilityId > 0 then
        craftedAbilityId = math.floor(craftedAbilityId)
    end
    if craftedAbilityId == nil then
        return CreateResult(target, RESULT_ERROR, "crafted_ability_id_missing", {
            pendingAbilityId = currentAbilityId,
            restorePath = "crafted",
            craftedResolveSource = type(craftedInfo) == "table" and craftedInfo.source or "none",
            resolvedCraftedAbilityId = nil,
            fallbackCraftedAbilityId = type(craftedInfo) == "table" and craftedInfo.fallbackCraftedAbilityId or nil,
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingResultAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory),
            targetExistingSlotIndex = nil,
        })
    end

    local currentActionType, currentActionId, currentEffectiveAbilityId =
        GetPendingSlotActionDetails(target.slotIndex, target.hotbarCategory)
    local savedScriptIds = CloneScriptIds(target.scriptIds)
    local activeScriptIds = ResolveCraftedActiveScriptIds(craftedAbilityId)
    local craftedMismatchWarning, craftedMismatchMethod, savedEffectiveAbilityId, currentCraftedEffectiveAbilityId =
        ResolveCraftedMismatch(target, craftedAbilityId, savedScriptIds, activeScriptIds)
    local displaySlot = ResolveDisplaySlot(target.slotIndex)

    local skillData = ResolveCraftedSkillData(craftedAbilityId)
    if type(skillData) ~= "table" then
        return CreateResult(target, RESULT_ERROR, "crafted_skill_data_unavailable", {
            pendingAbilityId = currentAbilityId,
            restorePath = "crafted",
            craftedResolveSource = type(craftedInfo) == "table" and craftedInfo.source or "none",
            resolvedCraftedAbilityId = craftedAbilityId,
            fallbackCraftedAbilityId = type(craftedInfo) == "table" and craftedInfo.fallbackCraftedAbilityId or nil,
            displaySlot = displaySlot,
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingResultAbilityId = currentEffectiveAbilityId,
            targetExistingSlotIndex = nil,
            savedScriptIds = savedScriptIds,
            activeScriptIds = activeScriptIds,
        })
    end

    if type(skillData.IsPurchased) == "function" and not skillData:IsPurchased() then
        return CreateResult(target, RESULT_ERROR, "crafted_skill_not_purchased", {
            pendingAbilityId = currentAbilityId,
            restorePath = "crafted",
            craftedResolveSource = type(craftedInfo) == "table" and craftedInfo.source or "none",
            resolvedCraftedAbilityId = craftedAbilityId,
            fallbackCraftedAbilityId = type(craftedInfo) == "table" and craftedInfo.fallbackCraftedAbilityId or nil,
            displaySlot = displaySlot,
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingResultAbilityId = currentEffectiveAbilityId,
            targetExistingSlotIndex = nil,
            savedScriptIds = savedScriptIds,
            activeScriptIds = activeScriptIds,
        })
    end

    if currentActionType == ACTION_TYPE_CRAFTED_ABILITY and currentActionId == craftedAbilityId then
        return CreateResult(
            target,
            RESULT_SKIPPED,
            craftedMismatchWarning and "already_matches_script_mismatch" or "already_matches",
            {
                pendingAbilityId = currentAbilityId,
                pendingCraftedAbilityId = currentActionId,
                restorePath = "crafted",
                craftedResolveSource = type(craftedInfo) == "table" and craftedInfo.source or "none",
                resolvedCraftedAbilityId = craftedAbilityId,
                fallbackCraftedAbilityId = type(craftedInfo) == "table" and craftedInfo.fallbackCraftedAbilityId or nil,
                availableAbilityId = currentEffectiveAbilityId,
                displaySlot = displaySlot,
                assignInvoked = false,
                assignSucceeded = nil,
                alreadyMatched = true,
                pendingResultAbilityId = currentEffectiveAbilityId,
                pendingResultCraftedAbilityId = currentActionId,
                targetExistingSlotIndex = nil,
                warning = craftedMismatchWarning,
                warningMethod = craftedMismatchMethod,
                savedEffectiveAbilityId = savedEffectiveAbilityId,
                currentEffectiveAbilityId = currentCraftedEffectiveAbilityId,
                savedScriptIds = savedScriptIds,
                activeScriptIds = activeScriptIds,
            }
        )
    end

    local existingSlotIndex = FindExistingSlotForAbility(target.hotbarCategory, currentEffectiveAbilityId, target.slotIndex)
    local assigned = hotbarData:AssignSkillToSlot(target.slotIndex, skillData)
    local pendingActionType, pendingActionId, pendingEffectiveAbilityId =
        GetPendingSlotActionDetails(target.slotIndex, target.hotbarCategory)
    local pendingSlotAction = GetPendingSlotAction(target.slotIndex, target.hotbarCategory)
    local postStateMatchesTarget = pendingActionType == ACTION_TYPE_CRAFTED_ABILITY
        and pendingActionId == craftedAbilityId
        or ResolvePostStateMatchesTarget(
            target,
            pendingEffectiveAbilityId,
            skillData,
            pendingSlotAction
        )
    if assigned == false then
        if postStateMatchesTarget then
            return CreateResult(
                target,
                RESULT_SKIPPED,
                craftedMismatchWarning and "already_matches_script_mismatch" or "already_matches",
                {
                    pendingAbilityId = currentAbilityId,
                    pendingCraftedAbilityId = currentActionId,
                    restorePath = "crafted",
                    craftedResolveSource = type(craftedInfo) == "table" and craftedInfo.source or "none",
                    resolvedCraftedAbilityId = craftedAbilityId,
                    fallbackCraftedAbilityId = type(craftedInfo) == "table" and craftedInfo.fallbackCraftedAbilityId or nil,
                    availableAbilityId = pendingEffectiveAbilityId,
                    displaySlot = displaySlot,
                    assignInvoked = true,
                    assignSucceeded = false,
                    alreadyMatched = true,
                    pendingResultAbilityId = pendingEffectiveAbilityId,
                    pendingResultCraftedAbilityId = pendingActionId,
                    pendingResultActionType = pendingActionType,
                    targetExistingSlotIndex = existingSlotIndex,
                    warning = craftedMismatchWarning,
                    warningMethod = craftedMismatchMethod,
                    savedEffectiveAbilityId = savedEffectiveAbilityId,
                    currentEffectiveAbilityId = currentCraftedEffectiveAbilityId,
                    savedScriptIds = savedScriptIds,
                    activeScriptIds = activeScriptIds,
                }
            )
        end

        return CreateResult(
            target,
            RESULT_ERROR,
            "assign_failed",
            {
                pendingAbilityId = currentAbilityId,
                pendingCraftedAbilityId = currentActionId,
                restorePath = "crafted",
                craftedResolveSource = type(craftedInfo) == "table" and craftedInfo.source or "none",
                resolvedCraftedAbilityId = craftedAbilityId,
                fallbackCraftedAbilityId = type(craftedInfo) == "table" and craftedInfo.fallbackCraftedAbilityId or nil,
                displaySlot = displaySlot,
                assignInvoked = true,
                assignSucceeded = false,
                alreadyMatched = false,
                pendingResultAbilityId = pendingEffectiveAbilityId,
                pendingResultCraftedAbilityId = pendingActionId,
                pendingResultActionType = pendingActionType,
                targetExistingSlotIndex = existingSlotIndex,
                savedScriptIds = savedScriptIds,
                activeScriptIds = activeScriptIds,
            }
        )
    end

    return CreateResult(
        target,
        RESULT_APPLIED,
        craftedMismatchWarning and "assigned_script_mismatch" or "assigned",
        {
            pendingAbilityId = currentAbilityId,
            pendingCraftedAbilityId = currentActionId,
            restorePath = "crafted",
            craftedResolveSource = type(craftedInfo) == "table" and craftedInfo.source or "none",
            resolvedCraftedAbilityId = craftedAbilityId,
            fallbackCraftedAbilityId = type(craftedInfo) == "table" and craftedInfo.fallbackCraftedAbilityId or nil,
            availableAbilityId = pendingEffectiveAbilityId,
            displaySlot = displaySlot,
            assignInvoked = true,
            assignSucceeded = true,
            alreadyMatched = false,
            pendingResultAbilityId = pendingEffectiveAbilityId,
            pendingResultCraftedAbilityId = pendingActionId,
            pendingResultActionType = pendingActionType,
            targetExistingSlotIndex = existingSlotIndex,
            warning = craftedMismatchWarning,
            warningMethod = craftedMismatchMethod,
            savedEffectiveAbilityId = savedEffectiveAbilityId,
            currentEffectiveAbilityId = currentCraftedEffectiveAbilityId,
            savedScriptIds = savedScriptIds,
            activeScriptIds = activeScriptIds,
        }
    )
end

function LTM_SKILL_RESTORE:RestoreSingleSlot(target)
    if not IsAssignableSlot(target.slotIndex) then
        return CreateResult(target, RESULT_ERROR, "slot_out_of_range", {
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingAbilityId = nil,
            pendingResultAbilityId = nil,
            targetExistingSlotIndex = nil,
        })
    end

    local cryptCanonState = self._cryptCanonState
    if target.slotIndex == LAST_ASSIGNABLE_SLOT
        and tonumber(target.abilityId) == CRYPT_CANON_SPECIAL_ULTIMATE_ID
        and type(cryptCanonState) == "table"
        and cryptCanonState.active == true then
        self:NotifyCryptCanonOverwriteRequired(cryptCanonState)
        return CreateResult(target, RESULT_ERROR, "cryptcanon_special_ultimate_requires_overwrite", {
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory),
            pendingResultAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory),
            targetExistingSlotIndex = nil,
        })
    end

    local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER and ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(target.hotbarCategory) or nil
    if type(hotbarData) ~= "table" then
        return CreateResult(target, RESULT_ERROR, "hotbar_unavailable", {
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingAbilityId = nil,
            pendingResultAbilityId = nil,
            targetExistingSlotIndex = nil,
        })
    end

    local currentAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory)
    if target.abilityId <= 0 then
        if currentAbilityId == 0 then
            return CreateResult(target, RESULT_SKIPPED, "already_empty", {
                pendingAbilityId = currentAbilityId,
                displaySlot = ResolveDisplaySlot(target.slotIndex),
                assignInvoked = false,
                assignSucceeded = nil,
                alreadyMatched = true,
                pendingResultAbilityId = currentAbilityId,
                targetExistingSlotIndex = nil,
            })
        end

        local cleared = hotbarData:ClearSlot(target.slotIndex)
        if cleared == false then
            return CreateResult(target, RESULT_ERROR, "clear_failed", {
                pendingAbilityId = currentAbilityId,
                displaySlot = ResolveDisplaySlot(target.slotIndex),
                assignInvoked = false,
                assignSucceeded = nil,
                alreadyMatched = false,
                pendingResultAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory),
                targetExistingSlotIndex = nil,
            })
        end

        return CreateResult(target, RESULT_APPLIED, "cleared", {
            pendingAbilityId = currentAbilityId,
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingResultAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory),
            targetExistingSlotIndex = nil,
        })
    end

    local isCraftedSlot, craftedInfo = IsCraftedSlotTarget(target)
    if isCraftedSlot then
        return self:RestoreCraftedSlot(target, hotbarData, currentAbilityId, craftedInfo)
    end

    local progressionData = SKILLS_DATA_MANAGER and SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(target.abilityId) or nil
    if progressionData == nil then
        return CreateResult(target, RESULT_ERROR, "unknown_ability", {
            pendingAbilityId = currentAbilityId,
            restorePath = "normal",
            craftedResolveSource = type(craftedInfo) == "table" and craftedInfo.source or "none",
            resolvedCraftedAbilityId = type(craftedInfo) == "table" and craftedInfo.craftedAbilityId or nil,
            fallbackCraftedAbilityId = type(craftedInfo) == "table" and craftedInfo.fallbackCraftedAbilityId or nil,
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingResultAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory),
            targetExistingSlotIndex = nil,
        })
    end

    local skillData = progressionData:GetSkillData()
    if skillData == nil then
        return CreateResult(target, RESULT_ERROR, "skill_data_unavailable", {
            pendingAbilityId = currentAbilityId,
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingResultAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory),
            targetExistingSlotIndex = nil,
        })
    end

    if type(skillData.IsCraftedAbility) == "function" and skillData:IsCraftedAbility() == true then
        craftedInfo = type(craftedInfo) == "table" and craftedInfo or {}
        craftedInfo.isCrafted = true
        craftedInfo.source = "skill_data"
        return self:RestoreCraftedSlot(target, hotbarData, currentAbilityId, craftedInfo)
    end

    if skillData:IsPassive() then
        return CreateResult(target, RESULT_ERROR, "passive_not_slottable", {
            pendingAbilityId = currentAbilityId,
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingResultAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory),
            targetExistingSlotIndex = nil,
        })
    end

    if not skillData:IsPurchased() then
        return CreateResult(target, RESULT_ERROR, "skill_not_purchased", {
            pendingAbilityId = currentAbilityId,
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingResultAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory),
            targetExistingSlotIndex = nil,
        })
    end

    local currentProgressionData = skillData:GetPointAllocatorProgressionData()
    if currentProgressionData == nil then
        return CreateResult(target, RESULT_ERROR, "current_progression_unavailable", {
            pendingAbilityId = currentAbilityId,
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = false,
            pendingResultAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory),
        })
    end

    local availableAbilityId = currentProgressionData:GetEffectiveAbilityId(target.hotbarCategory)
    local currentMorphSlot = skillData.GetCurrentMorphSlot and skillData:GetCurrentMorphSlot() or nil
    local targetMorphSlot = progressionData.GetMorphSlot and progressionData:GetMorphSlot() or nil
    local morphMatchesTarget = targetMorphSlot == nil
        or currentMorphSlot == nil
        or currentMorphSlot == targetMorphSlot

    if availableAbilityId ~= target.abilityId and not morphMatchesTarget then
        return CreateResult(
            target,
            RESULT_ERROR,
            "target_morph_not_currently_available",
            {
                pendingAbilityId = currentAbilityId,
                availableAbilityId = availableAbilityId,
                currentMorphSlot = currentMorphSlot,
                targetMorphSlot = targetMorphSlot,
                displaySlot = ResolveDisplaySlot(target.slotIndex),
                assignInvoked = false,
                assignSucceeded = nil,
                alreadyMatched = false,
                pendingResultAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory),
                targetExistingSlotIndex = nil,
            }
        )
    end

    if currentAbilityId == target.abilityId then
        return CreateResult(target, RESULT_SKIPPED, "already_matches", {
            pendingAbilityId = currentAbilityId,
            availableAbilityId = availableAbilityId,
            currentMorphSlot = currentMorphSlot,
            targetMorphSlot = targetMorphSlot,
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = false,
            assignSucceeded = nil,
            alreadyMatched = true,
            pendingResultAbilityId = currentAbilityId,
            targetExistingSlotIndex = nil,
        })
    end

    local existingSlotIndex = FindExistingSlotForAbility(target.hotbarCategory, target.abilityId, target.slotIndex)

    local assigned = hotbarData:AssignSkillToSlotByAbilityId(target.slotIndex, target.abilityId)
    local pendingResultAbilityId = GetPendingSlotAbilityId(target.slotIndex, target.hotbarCategory)
    local pendingSlotAction = GetPendingSlotAction(target.slotIndex, target.hotbarCategory)
    local postStateMatchesTarget = ResolvePostStateMatchesTarget(
        target,
        pendingResultAbilityId,
        skillData,
        pendingSlotAction
    )
    if assigned == false then
        if postStateMatchesTarget then
            return CreateResult(target, RESULT_SKIPPED, "already_matches", {
                pendingAbilityId = currentAbilityId,
                availableAbilityId = availableAbilityId,
                currentMorphSlot = currentMorphSlot,
                targetMorphSlot = targetMorphSlot,
                displaySlot = ResolveDisplaySlot(target.slotIndex),
                assignInvoked = true,
                assignSucceeded = false,
                alreadyMatched = true,
                pendingResultAbilityId = pendingResultAbilityId,
                targetExistingSlotIndex = existingSlotIndex,
            })
        end

        return CreateResult(
            target,
            RESULT_ERROR,
            "assign_failed",
            {
                pendingAbilityId = currentAbilityId,
                availableAbilityId = availableAbilityId,
                currentMorphSlot = currentMorphSlot,
                targetMorphSlot = targetMorphSlot,
                displaySlot = ResolveDisplaySlot(target.slotIndex),
                assignInvoked = true,
                assignSucceeded = false,
                alreadyMatched = false,
                pendingResultAbilityId = pendingResultAbilityId,
                targetExistingSlotIndex = existingSlotIndex,
            }
        )
    end

    return CreateResult(
        target,
        RESULT_APPLIED,
        "assigned",
        {
            pendingAbilityId = currentAbilityId,
            availableAbilityId = availableAbilityId,
            currentMorphSlot = currentMorphSlot,
            targetMorphSlot = targetMorphSlot,
            displaySlot = ResolveDisplaySlot(target.slotIndex),
            assignInvoked = true,
            assignSucceeded = true,
            alreadyMatched = false,
            pendingResultAbilityId = pendingResultAbilityId,
            targetExistingSlotIndex = existingSlotIndex,
        }
    )
end

function LTM_SKILL_RESTORE:Run(config)
    return self:RunInternal(config, "normal")
end

function LTM_SKILL_RESTORE:RunRestoreOnly(config)
    return self:RunInternal(config, "post_route_b")
end

function LTM_SKILL_RESTORE:RunDeferredTransformSlots(config, suppressPartial)
    config = type(config) == "table" and config or {}
    return self:RunInternal({
        deferredTransformSlots = config.deferredTransformSlots,
        _pipelineContext = config._pipelineContext,
        _suppressTransformDeferredPartial = suppressPartial == true,
    }, "post_route_b")
end
