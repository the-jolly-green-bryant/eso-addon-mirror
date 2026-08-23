local Addon = LarvalTearMod
local SkillSettings = Addon.Common.SkillSettings

SkillSettings.ActiveRestoreModes = {
    "required_only",
    "exact",
    "clear_unused",
}
SkillSettings.PassiveRestoreModes = {
    "none",
    "class_purchase_all",
    "class_exact",
    "all_exact",
}
SkillSettings.PassiveShortageModes = {
    "best_effort",
    "all_or_nothing",
}
SkillSettings.ActiveShortageModes = {
    "active_priority",
    "skip_all",
}

SkillSettings.ActiveRestoreDefault = "required_only"
SkillSettings.PassiveRestoreDefault = "class_purchase_all"
SkillSettings.PassiveShortageDefault = "best_effort"
SkillSettings.ActiveShortageDefault = "active_priority"

local function BuildValueSet(values)
    local valueSet = {}
    for _, value in ipairs(values) do
        valueSet[value] = true
    end
    return valueSet
end

local ACTIVE_RESTORE_SET = BuildValueSet(SkillSettings.ActiveRestoreModes)
local PASSIVE_RESTORE_SET = BuildValueSet(SkillSettings.PassiveRestoreModes)
local PASSIVE_SHORTAGE_SET = BuildValueSet(SkillSettings.PassiveShortageModes)
local ACTIVE_SHORTAGE_SET = BuildValueSet(SkillSettings.ActiveShortageModes)

function SkillSettings:NormalizeActiveRestore(value)
    return ACTIVE_RESTORE_SET[value] and value or self.ActiveRestoreDefault
end

function SkillSettings:NormalizePassiveRestore(value)
    return PASSIVE_RESTORE_SET[value] and value or self.PassiveRestoreDefault
end

function SkillSettings:NormalizePassiveShortage(value)
    return PASSIVE_SHORTAGE_SET[value] and value or self.PassiveShortageDefault
end

function SkillSettings:NormalizeActiveShortage(value)
    return ACTIVE_SHORTAGE_SET[value] and value or self.ActiveShortageDefault
end

local function NormalizeValues(owner, settings)
    settings = type(settings) == "table" and settings or {}
    return {
        activeRestore = owner:NormalizeActiveRestore(settings.activeRestore),
        passiveRestore = owner:NormalizePassiveRestore(settings.passiveRestore),
        passiveShortage = owner:NormalizePassiveShortage(settings.passiveShortage),
        activeShortage = owner:NormalizeActiveShortage(settings.activeShortage),
    }
end

function SkillSettings:NormalizeGlobal(settings)
    return NormalizeValues(self, settings)
end

function SkillSettings:NormalizeBuild(settings)
    local normalized = NormalizeValues(self, settings)
    normalized.useOverride = type(settings) == "table" and settings.useOverride == true
    return normalized
end

function SkillSettings:ResolveEffective(globalSettings, buildSettings)
    local normalizedBuild = self:NormalizeBuild(buildSettings)
    if normalizedBuild.useOverride then
        return {
            activeRestore = normalizedBuild.activeRestore,
            passiveRestore = normalizedBuild.passiveRestore,
            passiveShortage = normalizedBuild.passiveShortage,
            activeShortage = normalizedBuild.activeShortage,
        }, "build_override"
    end

    return self:NormalizeGlobal(globalSettings), "global"
end

local function ResolveSkillPointPlan(diagnostics)
    if type(diagnostics) ~= "table" then
        return nil
    end
    if type(diagnostics.expectedResult) == "string" then
        return diagnostics
    end

    local skillPointPlan = diagnostics.skillPointPlan
    return type(skillPointPlan) == "table" and skillPointPlan or nil
end

function SkillSettings:ResolveShortage(effectiveSettings, evaluatorDiagnostics)
    local resolved = self:NormalizeGlobal(effectiveSettings)
    resolved.source = type(effectiveSettings) == "table" and effectiveSettings.source or nil
    resolved.evaluated = false
    resolved.activeAction = "normal"
    resolved.passiveAction = "normal"
    resolved.reason = nil

    local skillPointPlan = ResolveSkillPointPlan(evaluatorDiagnostics)
    local expectedResult = type(skillPointPlan) == "table" and skillPointPlan.expectedResult or nil
    if expectedResult == "passive_partial" then
        resolved.evaluated = true
        resolved.reason = "passive_partial"
        if resolved.passiveShortage == "all_or_nothing" then
            resolved.passiveAction = "skip_passive_changes"
        end
    elseif expectedResult == "skill_phase_skip" then
        resolved.evaluated = true
        resolved.reason = "skill_phase_skip"
        if resolved.activeShortage == "skip_all" then
            resolved.activeAction = "skip_all"
            resolved.passiveAction = "skip_passive_changes"
        end
    end

    return resolved
end
