local Addon = LarvalTearMod
local M = Addon.Modules.SpSaverPolicyResolver
local SpSaverModes = Addon.Common.SpSaverModes

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

function M:Resolve(commonSettings, buildSettings, evaluatorDiagnostics)
    commonSettings = type(commonSettings) == "table" and commonSettings or {}
    buildSettings = type(buildSettings) == "table" and buildSettings or {}

    local useBuildOverride = buildSettings.useOverride == true
    local selectedSettings = useBuildOverride and buildSettings or commonSettings
    local resolved = {
        activeMode = SpSaverModes:NormalizeActiveMode(selectedSettings.activeMode),
        passiveMode = SpSaverModes:NormalizePassiveMode(selectedSettings.passiveMode),
        source = useBuildOverride and "build_override" or "common",
        evaluated = false,
        activeAction = "normal",
        passiveAction = "normal",
        reason = nil,
    }

    local skillPointPlan = ResolveSkillPointPlan(evaluatorDiagnostics)
    local expectedResult = type(skillPointPlan) == "table" and skillPointPlan.expectedResult or nil
    local passiveShortage = type(skillPointPlan) == "table" and skillPointPlan.shortage or nil
    if expectedResult == "passive_partial"
        and type(passiveShortage) == "number"
        and passiveShortage > 0 then
        resolved.evaluated = true
        resolved.reason = "passive_partial"
        if resolved.passiveMode == "all_or_nothing" or resolved.passiveMode == "preserve_current" then
            resolved.passiveAction = "skip_passive_changes"
        end
    elseif expectedResult == "skill_phase_skip" then
        resolved.evaluated = true
        resolved.reason = "skill_phase_skip"
        if resolved.activeMode == "skip_skill_changes" then
            -- This mode covers Active, Morph, and Normal Passive changes.
            resolved.activeAction = "skip_skill_changes"
            resolved.passiveAction = "skip_passive_changes"
        end
    end

    return resolved
end
