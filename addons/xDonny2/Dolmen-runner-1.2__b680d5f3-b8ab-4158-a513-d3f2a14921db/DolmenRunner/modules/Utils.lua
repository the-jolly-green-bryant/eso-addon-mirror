local Utils = {
    chatPrefix = "|c39B027DolmenRunner|r: ",
    isDebug = false,
}

function Utils:Log(message)
    d(Utils.chatPrefix .. message)
end

function Utils:Debug(message)
    if not Utils.isDebug then
        return
    end
    Utils:Log("[Debug] " .. message)
end

function Utils:ToggleDebug(option)
    Utils.isDebug = option == "on"
    Utils:Log("Debug mode: " .. option)
end

function Utils:FindValuePosInArray(iterable, value)
    if type(iterable) ~= "table" then
        return false
    end
    for i, char in pairs(iterable) do
        if char == value then
            return i
        end
    end
    return false
end

function Utils:AddValueToArrayIfNotExists(iterable, value)
    value = string.lower(value)
    if self:FindValuePosInArray(iterable, value) ~= false then
        return false
    end
    table.insert(iterable, value)
    return true
end

function Utils:RemoveValueFromArrayIfNotExists(iterable, value)
    local pos = tonumber(value)
    if pos == nil then
        pos = self:FindValuePosInArray(iterable, string.lower(value))
    end
    if pos == false then
        return false
    end
    local removed = iterable[pos]
    table.remove(iterable, pos)
    return removed
end

function Utils:PrintArrayInList(iterable, numbered)
    numbered = numbered or false
    for i, char in ipairs(iterable) do
        local output = char
        if numbered then
            output = tostring(i) .. ") " .. char
        end
        d(output)
    end
end

DolmenRunner.utils = Utils
