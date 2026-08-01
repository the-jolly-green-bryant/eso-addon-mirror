--[[--------------------------------------------
    Project:    Clock - Tamriel Standard Time
    Author:     Arne Rantzen (Tyx) & Phinix
    Created:    2020-01-22
    Updated:    2020-02-11
    License:    GPL-3.0
--------------------------------------------]]--

Clock_TST = Clock_TST or {}

ZO_ONE_YEAR_IN_SECONDS = ZO_ONE_MONTH_IN_SECONDS * 12 -- 31104000

--- Find the largest line in a string
--- Lines are counted when separated by "\n"
--- @param str string with one or more lines
--- @return number length of largest line
function Clock_TST.GetLargestLine(str)
    if str:sub(-1) ~= "\n" then
        str = str .. "\n"
    end
    local length = str:len()
    for l in str:gmatch("(.-)\n") do
        if length == str:len() or l:len() > length then
            length = l:len()
        end
    end
    return length
end

--- Function to get a list of keys of a table
--- @param object table where the keys should be extracted from
--- @return table of keys
function Clock_TST.GetKeys(object)
    assert(type(object) == "table", "Please provide a table.")
    local keys = {}
    for k, _ in pairs(object) do
        table.insert(keys, k)
    end
    return keys
end

--- Function to copy only objects from table which are not in the default one
--- @param object table base object
--- @param default table default object to compare it with
--- @param ... string additional keys to ignore
function Clock_TST.SelectiveCopy(object, default, ...)
    if type(object) == "table" then
        local next = next
        local result = {}
        for k, v in pairs(object) do
            local skip = false
            -- skip over ignored keys
            for i = 1, select('#', ...) do
                skip = skip or k == select(i, ...)
            end
            if not skip then
                if type(default) == "table" and default[k] ~= nil then
                    result[k] = Clock_TST.SelectiveCopy(v, default[k])
                else
                    result[k] = v
                end
            end
        end
        for k, v in pairs(result) do
            if type(v) == "table" and not next(v) then
                result[k] = nil
            end
        end
        if not next(result) then
            result = nil
        end
        return result
    elseif type(object) == "function" or object == default then
        return nil
    else
        return object
    end
end

--- Function to deeply compare two tables if the are the same
--- @param table1 table first table
--- @param table2 table second table
--- @return boolean if the tables are the same
function Clock_TST.DeepCompare(table1, table2)
    if table2 and not table1 or table1 and not table2 then return false end
    if type(table1) == "table" and type(table2) == "table" then
        local next = next
        local t1Next = next(table1)
        local t2Next = next(table2)
        if t1Next and not t2Next or not t1Next and t2Next then
            return false
        elseif not (t1Next or t2Next) then
            return true
        else
            local same = true
            for k, v1 in pairs(table1) do
                local v2 = table2[k]
                same = same and Clock_TST.DeepCompare(v1, v2)
            end
            return same
        end
    else
        return table1 == table2
    end
end

--- Function to merge numerous tables together into the first
--- @param t1 table first table the rest will be merged into
--- @param ... table in a undefined number
--- @return table merge product of all inputs
function Clock_TST.MergeTable(t1, ...)
    for i = 1, select('#', ...) do
        local t2 = select(i, ...)
        if type(t2) == "table" then
            for k, v in pairs(t2) do
                if (type(v) == "table") and (type(t1[k] or false) == "table") then
                    Clock_TST.MergeTable(t1[k], t2[k])
                else
                    t1[k] = v
                end
            end
        end
    end
    return t1
end
