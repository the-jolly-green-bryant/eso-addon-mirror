local Addon = LarvalTearMod
local LTM_ATTRIBUTE_SNAPSHOT = Addon.Modules.AttributeSnapshot
local DOMAINS = Addon.Common.Domains
local ATTRIBUTE_TYPES = DOMAINS.AttributeTypes
local ATTRIBUTE_ORDER = DOMAINS.AttributeOrder

local function IsWholeNumber(value)
    return type(value) == "number" and value >= 0 and value == math.floor(value)
end

function LTM_ATTRIBUTE_SNAPSHOT:NormalizeTargetAttributeState(config)
    if type(config) ~= "table" then
        return nil, "attribute_target_missing"
    end

    local normalized = {}
    for _, key in ipairs(ATTRIBUTE_ORDER) do
        local value = config[key]
        if not IsWholeNumber(value) then
            return nil, string.format("%s must be a non-negative integer", key)
        end
        normalized[key] = value
    end

    local total = normalized.health + normalized.magicka + normalized.stamina
    if total > 64 then
        return nil, string.format("attribute total exceeds supported limit: %d", total)
    end

    return normalized
end

function LTM_ATTRIBUTE_SNAPSHOT:CaptureCurrentAttributeState(context)
    local state = {
        ok = true,
        diagnostics = {
            source = "committed_attribute_getters",
        },
    }

    local hasSpentApi = type(GetAttributeSpentPoints) == "function"
    state.diagnostics.hasSpentApi = hasSpentApi

    if hasSpentApi then
        for _, key in ipairs(ATTRIBUTE_ORDER) do
            local attributeType = ATTRIBUTE_TYPES[key]
            state[key] = GetAttributeSpentPoints(attributeType)
        end
    end

    if type(GetAttributeUnspentPoints) == "function" then
        state.unspent = GetAttributeUnspentPoints()
        state.diagnostics.hasUnspentApi = true
    else
        state.diagnostics.hasUnspentApi = false
    end

    return state
end
