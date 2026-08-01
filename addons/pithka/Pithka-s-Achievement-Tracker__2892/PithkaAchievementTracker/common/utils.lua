-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.common = PITHKA.common or {}
PITHKA.common.utils = {}

-- convenient namespacing
local utils = PITHKA.common.utils
local data = PITHKA.data

-- debug printing
local debugEnabled = false
local function debug(msg)
    if debugEnabled then
        d('|cFF0000[common.utils]|r ' .. msg )
    end
end

-- return unique id
function utils.uid()
    -- use a global variable to increment each time a uid is needed
    utils.uidCurrent = (utils.uidCurrent or 10000) + 1
    return utils.uidCurrent
end


-- return the max vaule in an array
function utils.maxValue(array)
    local max = 0
    for _, value in pairs(array) do
        local numValue = tonumber(value)
        if numValue and numValue > max then
                max = numValue
        end
    end
    return max
end

-- Sort a table by its numeric values and return t[key]=value into t[index]={key,value} sorted by value
function utils.sortedByValues(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    
    table.sort(keys, function(a, b)
        return tbl[a] > tbl[b]  -- Sort in descending order
    end)
    
    -- convert t[key]=value into t[index]={key,value}   
    local sorted = {}
    for i, k in ipairs(keys) do
        sorted[i] = {k, tbl[k]}
    end
    return sorted
end


--/script PITHKA.common.utils.printTable(PITHKA.groupFinder.db.getAll())
-- print a table in JSON-like format
function utils.printTable(tbl, indent, visited)
    indent = indent or 0
    visited = visited or {}
    
    -- Check for circular references
    if visited[tbl] then
        return '"<circular reference>"'
    end
    visited[tbl] = true
    
    local indentStr = string.rep("  ", indent)
    local result = "{\n"
    local first = true
    
    -- Sort keys for consistent output
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b)
        if type(a) == type(b) then
            return tostring(a) < tostring(b)
        end
        return type(a) < type(b)
    end)
    
    for _, k in ipairs(keys) do
        local v = tbl[k]
        
        -- Add comma for all but first item
        if not first then
            result = result .. ",\n"
        end
        first = false
        
        -- Format the key
        local key = type(k) == "string" and '"' .. k .. '"' or tostring(k)
        
        -- Format the value
        local value
        if v == nil then
            value = "null"
        elseif type(v) == "table" then
            if next(v) == nil then
                value = "{}"  -- Empty table
            else
                -- Recursively print nested table with increased indentation
                local nestedTable = utils.printTable(v, indent + 1, visited)
                value = "\n" .. indentStr .. "  " .. nestedTable
            end
        elseif type(v) == "string" then
            value = '"' .. v:gsub('"', '\\"') .. '"'
        elseif type(v) == "boolean" then
            value = v and "true" or "false"
        else
            value = tostring(v)
        end
        
        -- Add the key-value pair with proper indentation
        if type(v) == "table" and next(v) ~= nil then
            -- For nested tables, we already have the newline and indentation in the value
            result = result .. indentStr .. "  " .. key .. ": " .. value
        else
            -- For simple values, add them on the same line
            result = result .. indentStr .. "  " .. key .. ": " .. value
        end
    end
    
    result = result .. "\n" .. indentStr .. "}"
    return result
end


-- Concatenates multiple tables into a single table, handling both single items and arrays
function utils.concatTables(tables)
    local result = {}
    
    for _, table_or_item in ipairs(tables) do
        if table_or_item then
            if type(table_or_item) == "table" then
                for _, item in ipairs(table_or_item) do
                    table.insert(result, item)
                end
            else
                table.insert(result, table_or_item)
            end
        end
    end
    
    return result
end