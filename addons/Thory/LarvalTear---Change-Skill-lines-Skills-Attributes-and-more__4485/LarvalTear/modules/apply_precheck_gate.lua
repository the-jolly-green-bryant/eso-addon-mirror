local Addon = LarvalTearMod
local M = Addon.Modules.ApplyPrecheckGate

local function CloneRequest(request)
    if type(request) ~= "table" then
        return {}
    end

    local cloned = {}
    for key, value in pairs(request) do
        cloned[key] = value
    end
    return cloned
end

local function ResolveActivityRestrictionType(plan)
    local hasAttributeChange = false
    for _, reason in ipairs(type(plan) == "table" and plan.activityCommitReasons or {}) do
        if reason == "attribute_change" then
            hasAttributeChange = true
        else
            return "class_skills"
        end
    end

    return hasAttributeChange and "attributes" or nil
end

function M:Evaluate(request, plan)
    local normalizedRequest = CloneRequest(request)
    local inCombat = type(IsUnitInCombat) == "function"
        and IsUnitInCombat("player")
        and normalizedRequest.skipCombatQueue ~= true
        or false

    if inCombat then
        return {
            action = "queue",
            diagnostics = {
                inCombat = true,
            },
            request = normalizedRequest,
        }
    end

    local inActivity = type(IsRaidInProgress) == "function" and IsRaidInProgress() or false
    if inActivity
        and type(plan) == "table"
        and plan.requiresActivityRestrictedCommit == true then
        return {
            action = "block",
            error = "activity_disallowed",
            diagnostics = {
                inCombat = false,
                inActivity = true,
                activityRestrictionType = ResolveActivityRestrictionType(plan),
                activityCommitReasons = plan.activityCommitReasons,
            },
            request = normalizedRequest,
        }
    end

    return {
        action = "run_now",
        diagnostics = {
            inCombat = false,
            inActivity = inActivity,
        },
        request = normalizedRequest,
    }
end
