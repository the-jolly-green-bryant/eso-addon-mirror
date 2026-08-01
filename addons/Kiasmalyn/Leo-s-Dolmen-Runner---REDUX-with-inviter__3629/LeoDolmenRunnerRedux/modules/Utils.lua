-- Utils.lua
-- @Kiasmalyn
-- use to consolidate common functions.. and to try to reduce the repeated code in the origional base
-- 5/5/23

local Utils = {
    chatPrefix = "|c39B027LDR-Redux|r: ",
    isDebug = false
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
    Utils:Log("[LDR] Debug mode: " .. option)
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
    term = string.lower(term)
    if LDR.utils:FindValuePosInArray(iterable, value) ~= false then
        return false
    end

    table.insert(iterable, value)
    return true
end

-----------------------------------------------------------
--- value can be numeric to directly reference the position
-----------------------------------------------------------
function Utils:RemoveValueFromArrayIfNotExists(iterable, value)
    -- try to convert to number, if not its a string
    local pos = tonumber(value)
    if pos == nil then
        pos = LDR.utils:FindValuePosInArray(iterable, string.lower(value))
    end

    -- its not in there!
    if pos == false then
        return false
    end

    local removed = iterable[pos]
    table.remove(iterable, pos)

    -- return the original string for messaging
    return removed
end

----------------------------------------------------------
--- iterable, numbered = false
----------------------------------------------------------
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

-- initialise
LeoDolmenRunnerRedux.utils = Utils