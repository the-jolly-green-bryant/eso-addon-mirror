local LTF = LibTextFormat

LTF.CoreProtocols = LTF.CoreProtocols or { ["v1"] = {} }

LTF.ProtocolMeta = LTF.ProtocolMeta or {
    todotpath = { consumes = "table", produces = "string" },
    fromdotpath = { consumes = "string", produces = "table" },
}

local function strtrim(str)
    -- The extra parentheses are used to discard the additional return value (which is the total number of matches)
    return(zo_strgsub(str, "^%s*(.-)%s*$", "%1"))
end

local function ParseValue(v)
    v = v:match("^%s*(.-)%s*$")

    if v == "true" then return true end
    if v == "false" then return false end

    local n = tonumber(v)
    if n then return n end

    if v:sub(1,1) == '"' then
        return v:sub(2, -2):gsub('\\"', '"')
    end

    return v
end

local function FormatValue(v)
    local t = type(v)
    if t == "string" then
        return '"' .. v:gsub('"', '\\"') .. '"'
    elseif t == "number" or t == "boolean" then
        return tostring(v)
    elseif t == "nil" then
        return ""
    else
        -- should never hit here now
        return tostring(v)
    end
end

local function SplitPath(path, sep)
    path = tostring(path)
    sep = sep or "."

    local parts = {}

    -- escape separator for Lua patterns
    local pattern = "([^" .. sep:gsub("(%W)", "%%%1") .. "]+)"

    for part in path:gmatch(pattern) do
        table.insert(parts, part)
    end

    return parts
end

local function clone(obj)
    local copy = {}
    for k, v in pairs(obj) do
        copy[k] = v
    end
    return copy
end

local function wrap(index, key, value)
    return {
        [index] = {
            [key] = value
        }
    }
end

local function SetPath(root, path, value, sep)
    local parts = SplitPath(path, sep)
    local node = root

    for i = 1, #parts do
        local key = tonumber(parts[i]) or parts[i]

        -- leaf: assign value
        if i == #parts then
            node[key] = value
            return
        end

        local nextNode = node[key]

        -- if missing OR not a table, replace with table
        if type(nextNode) ~= "table" then
            nextNode = {}
            node[key] = nextNode
        end

        node = nextNode
    end
end

local function Flatten(obj, prefix, out, ctx)
    out = out or {}
    prefix = prefix or ""
    local sep = ctx and ctx.pathSep or "."

    local t = type(obj)
    if t ~= "table" then
        table.insert(out, { key = prefix, value = obj })
        return out
    end

    for k, v in pairs(obj) do
        local keyPart = tostring(k)
        local key = prefix ~= "" and (prefix .. sep .. keyPart) or keyPart

        if type(v) == "table" and next(v) then
            -- recurse into arrays or dictionaries
            Flatten(v, key, out, ctx)
        else
            table.insert(out, { key = key, value = v })
        end
    end

    return out
end

LTF.CoreProtocols["v1"]["todotpath"] = function(ctx, value, part)
    value = value or ctx.scope:Get(part)

    assert(value, LTF.error(" Value passed with the todotpath key is either empty or there is no todotpath key."))
    assert(type(value) == "table", LTF.error(" Value passed to the todotpath key is not a table."))

    -- Empty values are permitted
    if LTF.IsEmpty(value) then
      return ""
    end

    local sep = ctx.scope:Get("pathSep") or "."
    local recordSep = ctx.scope:Get("recordSep") or "\n"
    local itemSep = ctx.scope:Get("itemSep") or "="

    local fields = Flatten(value, nil, nil, ctx)

    table.sort(fields, function(a, b)
        return a.key < b.key
    end)

    local lines = {}
    for _, f in ipairs(fields) do
        lines[#lines+1] = f.key .. itemSep .. FormatValue(f.value)
    end


    return table.concat(lines, recordSep)
end

LTF.CoreProtocols["v1"]["fromdotpath"] = function(ctx, value, part)

    value = value or ctx.scope:Get(part)

    assert(value, LTF.error(" Value passed with the fromdotpath key is either empty or there is no fromdotpath key."))
    assert(type(value) == "string", LTF.error(" Value passed to the fromdotpath key is not a string."))

    -- Empty values are permitted
    if LTF.IsEmpty(value) then
      return ""
    end

    local sep = ctx.scope:Get("pathSep") or "."
    local recordSep = ctx.scope:Get("recordSep") or "\n"
    local itemSep = ctx.scope:Get("itemSep") or "="

    local out = {}

    -- escape record separator for Lua patterns
    local patternSep = recordSep:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])","%%%1")

    for line in value:gmatch("([^" .. patternSep .. "]+)") do
        local key, raw = line:match("^([^"..itemSep.."]+)".. itemSep .. "(.+)$")
        if key then
            key = strtrim(key)
            local v = ParseValue(raw)

            SetPath(out, key, v, sep)
        end
    end
    return out
end


