Conductor.NetworkSerialization = Conductor.NetworkSerialization or {}
local S = Conductor.NetworkSerialization

function S:EncodePrimitiveMap(values)
    local parts = {}
    for key, value in pairs(values or {}) do
        if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
            parts[#parts + 1] = tostring(key) .. "=" .. tostring(value)
        end
    end
    table.sort(parts)
    return table.concat(parts, ";")
end

function S:DecodePrimitiveMap(text)
    local output = {}
    for token in string.gmatch(tostring(text or ""), "[^;]+") do
        local split = string.find(token, "=", 1, true)
        if split then output[string.sub(token, 1, split - 1)] = string.sub(token, split + 1) end
    end
    return output
end
