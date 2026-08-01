local C = Conductor
C.ResponsibilityEngine = C.ResponsibilityEngine or {}
local Engine = C.ResponsibilityEngine

local function CopyArray(values)
    local output = {}
    for index, value in ipairs(values or {}) do output[index] = value end
    return output
end

function Engine:GetDefinition(responsibilityKey)
    return C.KnowledgeBase:GetResponsibility(responsibilityKey)
end

function Engine:GetAcceptableProviders(responsibilityKey, includeUnresolved)
    return C.KnowledgeBase:GetProvidersForResponsibility(responsibilityKey, includeUnresolved)
end

function Engine:CanProviderFulfill(responsibilityKey, providerKey)
    local normalizedProvider = C.Registry:ResolveKey("PROVIDERS", providerKey)
    for _, provider in ipairs(self:GetAcceptableProviders(responsibilityKey, true)) do
        if provider.key == normalizedProvider or provider.sourceKey == normalizedProvider then
            return true, provider
        end
    end
    return false, nil
end

function Engine:Evaluate(responsibilityKey, capabilityProfile, assignment)
    local definition = self:GetDefinition(responsibilityKey)
    local result = {
        responsibilityKey = responsibilityKey,
        definition = definition,
        required = definition and definition.requiredByDefault == true or false,
        assigned = assignment ~= nil and assignment.player ~= nil and assignment.player ~= "",
        available = false,
        confirmed = false,
        providerKey = assignment and assignment.providerKey or nil,
        player = assignment and assignment.player or nil,
        matchingCapabilities = {},
        status = "UNKNOWN",
    }

    if not definition then
        result.status = "INVALID_RESPONSIBILITY"
        return result
    end

    local effectKey = definition.effectKey
    for _, capability in ipairs((capabilityProfile and capabilityProfile.interpreted) or capabilityProfile or {}) do
        if capability.key == effectKey or capability.responsibilityKey == responsibilityKey then
            result.available = true
            result.matchingCapabilities[#result.matchingCapabilities + 1] = capability
            if capability.confidence == "CONFIRMED" then result.confirmed = true end
        end
    end

    if result.assigned and result.providerKey then
        local validProvider = self:CanProviderFulfill(responsibilityKey, result.providerKey)
        if not validProvider then
            result.status = "INVALID_PROVIDER"
            return result
        end
    end

    if result.assigned and result.available and result.confirmed then
        result.status = "CONFIRMED"
    elseif result.assigned and result.available then
        result.status = "AVAILABLE"
    elseif result.assigned then
        result.status = "ASSIGNED_UNAVAILABLE"
    elseif result.available then
        result.status = "AVAILABLE_UNASSIGNED"
    elseif result.required then
        result.status = "MISSING"
    else
        result.status = "OPTIONAL_MISSING"
    end

    result.acceptableProviders = CopyArray(self:GetAcceptableProviders(responsibilityKey, true))
    return result
end

function Engine:EvaluateAll(capabilityProfile, assignments, includeOptional)
    local results = {}
    assignments = assignments or {}
    for _, responsibility in ipairs(C.Registry:GetAll("RESPONSIBILITIES")) do
        if includeOptional or responsibility.requiredByDefault then
            results[#results + 1] = self:Evaluate(responsibility.key, capabilityProfile, assignments[responsibility.key])
        end
    end
    table.sort(results, function(a, b)
        return tostring(a.definition and a.definition.name or a.responsibilityKey) < tostring(b.definition and b.definition.name or b.responsibilityKey)
    end)
    return results
end

function Engine:Initialize()
    self.initialized = true
end
