local Addon = LarvalTearMod
local M = Addon.Modules.ApplyPrecheck
local LTM_APPLY_PRECHECK_DECISION = Addon.Modules.ApplyPrecheckDecision
local LTM_APPLY_PRECHECK_GATE = Addon.Modules.ApplyPrecheckGate
local LTM_BUILD_STORE = Addon.Modules.BuildStore
local LTM_APPLY_START_STATE = Addon.Modules.ApplyStartState

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

local function NormalizeSource(request)
    request.source = type(request.source) == "string" and request.source ~= ""
        and request.source
        or "unknown"
    return request
end

local function CloneAcceptedPrecheck(precheck)
    local cloned = CloneRequest(precheck)
    cloned.route = CloneRequest(precheck.route)
    cloned.diagnostics = CloneRequest(precheck.diagnostics)
    return cloned
end

local function ResolveBuildIdentity(request, build)
    if type(request) == "table" and type(request.buildId) == "string" and request.buildId ~= "" then
        return request.buildId
    end
    if type(build) == "table" and type(build.id) == "string" and build.id ~= "" then
        return build.id
    end
    return nil
end

function M:ResolveBuild(request)
    local normalizedRequest = NormalizeSource(CloneRequest(request))
    local build = normalizedRequest.build

    if type(build) ~= "table" then
        local buildId = normalizedRequest.buildId
        build = LTM_BUILD_STORE:GetBuildById(buildId)
    end

    if type(build) ~= "table" then
        return nil, "build_not_found"
    end

    normalizedRequest.build = build
    return build, nil, normalizedRequest
end

function M:Evaluate(request, options)
    local build, buildErr, normalizedRequest = self:ResolveBuild(request)
    if type(build) ~= "table" then
        return nil, buildErr or "build_not_found"
    end

    local gateResult = LTM_APPLY_PRECHECK_GATE:Evaluate(normalizedRequest)
    gateResult.request = normalizedRequest
    gateResult.build = build

    if gateResult.action ~= "run_now" then
        return gateResult
    end

    local acceptedPrecheck = normalizedRequest.acceptedSkillPointPrecheck
    local decisionOptions = CloneRequest(options)
    if type(acceptedPrecheck) == "table" then
        local acceptedBuild = acceptedPrecheck.build
        local acceptedIdentity = ResolveBuildIdentity(acceptedPrecheck.request, acceptedBuild)
        local currentIdentity = ResolveBuildIdentity(normalizedRequest, build)
        if acceptedBuild == build
            or (acceptedIdentity ~= nil and acceptedIdentity == currentIdentity) then
            decisionOptions.acceptedPrecheck = CloneAcceptedPrecheck(acceptedPrecheck)
        end
    end

    local decisionResult = LTM_APPLY_PRECHECK_DECISION:Evaluate(
        normalizedRequest,
        build,
        decisionOptions
    )

    decisionResult = type(decisionResult) == "table" and decisionResult or {}
    decisionResult.request = normalizedRequest
    decisionResult.build = build
    decisionResult.gate = gateResult
    return decisionResult
end

function M:Begin(request, completion, continueFn)
    if type(continueFn) ~= "function" then
        return false, "apply_precheck_continue_required"
    end

    local _, buildErr, normalizedRequest = self:ResolveBuild(request)
    if type(normalizedRequest) ~= "table" then
        return false, buildErr or "build_not_found"
    end

    if normalizedRequest.skipStartStateCheck ~= true then
        return LTM_APPLY_START_STATE:Begin(normalizedRequest, completion, function(cleanRequest, cleanCompletion)
            local resumedRequest = CloneRequest(cleanRequest)
            resumedRequest.skipStartStateCheck = true
            return continueFn(resumedRequest, cleanCompletion)
        end)
    end

    return continueFn(normalizedRequest, completion)
end
