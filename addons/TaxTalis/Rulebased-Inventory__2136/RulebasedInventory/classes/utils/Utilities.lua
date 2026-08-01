-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis, demawi
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Utilities.lua
-- File Description: This class offers helper functions.
-- Load Order Requirements: directly after RulebasedInventory
--
-----------------------------------------------------------------------------------

-- imports
local RbI = RulebasedInventory
local utils = {}
RbI.class.Utilities = utils -- static class
RbI.utils = utils -- shortcut

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- ESO-environment functions --------------------------------------------------
------------------------------------------------------------------------------

function utils.readConstantsAll(callback)
    for key, value in zo_insecurePairs(_G) do
        if(not IsProtectedFunction(key) and not IsPrivateFunction(key)) then
            if(callback(key, value) == false) then
                return
            end
        end
    end
end

-- callback(matchedKey, value, originalFullKey)
function utils.readConstants(regex, callback)
    utils.readConstantsAll(function(key, value)
        local match = key:match(regex)
        if(match and callback(match, value, key) == false) then return false end
    end)
end

-- create a reader so we have to iterate only once over all constants
function utils.ConstanteReaderNew()
    local packedCallbacks = {}
    local baseLength = 100

    local function addCallback(matcher, callback, onFinish)
        local detectedBaseLength = matcher:find("%(")
        if(not detectedBaseLength) then error("Matcher doesn't define a search group") end
        baseLength = math.min(baseLength, detectedBaseLength-1)
        packedCallbacks[#packedCallbacks+1] = { matcher, callback, onFinish }
    end

    local function buildCallbacks()
        local callbacks = {}
        local onFinishCallbacks = {}
        for _, packedCallback in pairs(packedCallbacks) do
            local matcher, callback, onFinish = unpack(packedCallback)
            local baseKey = matcher:sub(1, baseLength)
            local callbackFns = callbacks[baseKey]
            if(callbackFns == nil) then
                callbackFns = {}
                callbacks[baseKey] = callbackFns
            end
            if(callbackFns[matcher] ~= nil) then
                error('Matcher already exists! '..baseKey..' '..matcher)
            end
            callbackFns[matcher] = callback
            if(onFinish) then onFinishCallbacks[#onFinishCallbacks+1] = onFinish end
        end
        return callbacks, onFinishCallbacks
    end

    local function read()
        local callbacks, onFinishCallbacks = buildCallbacks()
        utils.readConstantsAll(function(key, value)
            local baseKey = key:sub(1, baseLength)
            local callbackFns = callbacks[baseKey]
            if(callbackFns ~= nil) then
               for regex, callback in pairs(callbackFns) do
                   local match = key:match(regex)
                   if(match ~= nil) then
                       callback(match, value, key)
                   end
               end
            end
        end)
        for _, cb in ipairs(onFinishCallbacks) do cb() end
    end

    return {
        addCallback = addCallback,
        read = read,
    }
end



------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- General string functions ---------------------------------------------------
------------------------------------------------------------------------------

function utils.startsWith(String, Start)
    return string.sub(String,1,string.len(Start))==Start
end

function utils.endsWith(String, End)
    return string.sub(String,string.len(String)-string.len(End)+1)==End
end

function utils.chatColor(string, hexColor)
    return '|c'..hexColor..string..'|r'
end

function utils.textCheck(a, b, withLibTextFilter)
    if(a == b) then
        return true
    elseif(withLibTextFilter and LibTextFilter ~= nil) then
        local filter = '$' .. b .. '$' --RbI's LibTextFilter Extention
        local result, status = LibTextFilter:Filter(filter, a)
        if(status == LibTextFilter.RESULT_OK) then
            return result and true or false
        else
            local message
            if(status == LibTextFilter.RESULT_INVALID_ARGUMENT_COUNT) then
                message = 'An operator with too little arguments was encountered'
            elseif(status == LibTextFilter.RESULT_INVALID_VALUE_COUNT) then
                message = 'There where left over tokens that could not be matched'
            elseif(status == LibTextFilter.RESULT_INVALID_INPUT) then
                message = 'No string or a string with only operators was encountered'
            end
            return nil, message
        end
    else
        return false
    end
end

function utils.textCheckMany(input, itemDatas, withLibTextFilter)
	for i = 1, #input do
		for k = 1, #itemDatas do
			local inputI = string.lower(input[i])
			local itemData = tostring(itemDatas[k])
			local match, message = utils.textCheck(inputI, itemData, withLibTextFilter)
			if match then
				return true
			elseif match == nil then
				return nil, message
			end
		end
	end
	return false
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Table functions -----------------------------------------------------------
------------------------------------------------------------------------------

function utils.cloneFlat(obj, into)
    local result = into or {}
    for k, v in pairs(obj) do result[k] = v end
    return result
end

function utils.cloneDeep(obj, into)
    local result = into or {}
    for k, v in pairs(obj) do
        if(type(v) == 'table') then
            result[k] = utils.cloneDeep(v)
        else
            result[k] = v
        end
    end
    return result
end

function utils.clear(tbl)
    for key in pairs(tbl) do
        tbl[key] = nil
    end
end

-- appends t2 into t1
function utils.tableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function utils.isArray(t)
    return #t > 0
end

function utils.isArrayFull(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

local next = next
function utils.isEmpty(tbl)
    if next(tbl) == nil then
        return true
    end
    return false
end

function utils.count(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
    end
    return i
end

-- function by M. Kottman, https://stackoverflow.com/questions/15706270/sort-a-table-in-lua [2018-07-29]
-- pairs in a sorted order
function utils.spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- @return concats the values of the map to a string
function utils.ArrayValuesToString(array, delimeter, stringQuoting)
    delimeter = delimeter or ', '
    stringQuoting = stringQuoting or '\''
    local result = {}
    for _, val in pairs(array) do
        if(type(val)=="string") then
            result[#result+1] = stringQuoting..val..stringQuoting
        else
            result[#result+1] = tostring(val)
        end
    end
    return table.concat(result, delimeter)
end

-- @return concats the keys of the map to a string
function utils.ArrayKeysToString(array, delimeter)
    delimeter = delimeter or ', '
    local result = {}
    for key in pairs(array) do
        result[#result+1] = '\''..tostring(key)..'\''
    end
    return table.concat(result, delimeter)
end

function utils.tableDiff(table1, table2)
    local result = {}
    if(#table1 ~= #table2) then
        result[#result+1] = 'Size: '..#table1..' <> '..#table2
    end
    if(utils.isArray(table1) ~= utils.isArray(table2)) then
        result[#result+1] = 'IsArray: '..tostring(utils.isArray(table1))..' <> '..tostring(utils.isArray(table2))
    end
    local one = 0 -- both have values
    for key, value in pairs(table1) do
        if(table2[key] ~= value and table2[key]~=nil) then
            result[#result+1] = '\''..key..'\': '..tostring(value)..' <> '..tostring(table2[key])
            one = one+1
        end
    end
    result[#result+1] = ''
    local two = 0 -- only left has a value, right is nil
    for key, value in pairs(table1) do
        if(table2[key] == nil) then
            result[#result+1] = '\''..key..'\': '..tostring(value)..' <> '..tostring(nil)
            two = two+1
        end
    end
    result[#result+1] = ''
    local three = 0 -- only right has a value, left is nil
    for key, value in pairs(table2) do
        if(table1[key] == nil) then
            result[#result+1] = '\''..key..'\': '..tostring(nil)..' <> '..tostring(value)
            three = three+1
        end
    end
    table.insert(result, 1, 'Diffs found: '..(one+two+three)..' '..one..'/'..two..'/'..three)
    return result
end

-- Creates an table value -> list of keys => boolean
local function values2Keymap(table)
    local result = {}
    for key, value in pairs(table) do
        local keyList = result[value]
        if(keyList == nil) then
            keyList = {}
            result[value] = keyList
        end
        keyList[key] = true
    end
    return result
end
function utils.tableMapping(table1, table2)
    local new = {}
    local mapping = {}
    local error = {}

    local table1Rev = values2Keymap(table1)
    local table2Rev = values2Keymap(table2)

    local keysToString = function(keyList)
        local result = ""
        for key in pairs(keyList) do
            if(result:len() > 0) then
                result = result..", "
            end
            result = result.."'"..key.."'"
        end
        return result
    end

    for key, value in pairs(table1) do
        if(table2[key] ~= value and table2[key] ~= nil) then
            error[#error+1] = 'Error value changed for: \''..key..'\': '..tostring(value)..' <> '..tostring(table2[key])
        end
    end

    for value, keys in pairs(table1Rev) do
        local keys2 = table2Rev[value]
        if(keys2 == nil) then
            error[#error+1] = 'Error: Lost: '..value..' was '..keysToString(keys)
        else
            local both = {}
            for key in pairs(keys) do
                if(keys2[key]) then
                    keys[key] = nil
                    keys2[key] = nil
                    both[key] = true
                elseif(utils.startsWith(key, "s_")) then
                    local secondKey = key:sub(3)
                    if(keys2[secondKey]) then
                        keys[key] = nil
                        keys2[secondKey] = nil
                        both[key] = true
                    end
                end
            end
            if(utils.count(keys)>0) then
                if(utils.count(keys2)>0) then
                    mapping[#mapping+1] = "Mapping for "..value..": "..keysToString(keys).."  => "..keysToString(keys2)
                end
            elseif(utils.count(keys2)>0) then
                new[#new+1] = "Add for "..value..": "..keysToString(keys2).." others: "..keysToString(both)
            end
        end
    end

    for value, keys2 in pairs(table2Rev) do
        if(table1Rev[value] == nil) then
            new[#new+1] = "New for "..value..": "..keysToString(keys2)
        end
    end

    local result = {}
    if(#error > 0) then
        result[#result+1] = table.concat(error, '\n')
    end
    if(#mapping > 0) then
        if(#result > 0) then result[#result+1] = '' end
        result[#result+1] = "Mappings: "..#mapping
        result[#result+1] = table.concat(mapping, '\n')
    end
    if(#new > 0) then
        if(#result > 0) then result[#result+1] = '' end
        result[#result+1] = "News: "..#new
        result[#result+1] = table.concat(new, '\n')
    end
    return result
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Table search functions ----------------------------------------------------
------------------------------------------------------------------------------

function utils.TableContainsLowercasedKey(lowerCasedKey, table)
    for key in pairs(table) do
        if(lowerCasedKey == key:lower()) then return true end
    end
    return false
end

function utils.TableGetWithLowercasedKey(table, lowerCasedKey)
    for key in pairs(table) do
        if(lowerCasedKey == key:lower()) then return key end
    end
end

function utils.TableContainsValue(table, element)
    for _, cur in ipairs(table) do
        if cur == element then return true end
    end
    return false
end

function utils.TableSearchValueIgnoreCase(table, element)
    element = element:lower()
    for _, cur in ipairs(table) do
        if cur:lower() == element then return cur end
    end
end

function utils.GetKeysForValue(value, data)
    local keys = {}
    for key, val in pairs(data) do
        if (val == value) then keys[#keys+1] = key end
    end
    return keys
end

function utils.GetKeys(table)
    local keys = {}
    for key in pairs(table) do
        keys[#keys+1] = key
    end
    return keys
end

function utils.GetKeyForValue(value, data)
    for key, val in pairs(data) do
        if (val == value) then return key end
    end
    return nil
end

function utils.TableToString(outTable)
    local out = {}
    for key, value in pairs(outTable) do
        out[#out+1] = key..": "..tostring(value)
    end
    return table.concat(out, "\n")
end

function utils.TableFindIndex(curTable, element)
    for index, value in pairs(curTable) do
        if value == element then
            return index
        end
    end
end

function utils.TableRemoveElement(curTable, element)
    table.remove(curTable, utils.TableFindIndex(curTable, element) )
end

RbI.class.Create = function()
    local initials = {}
    local publics = {}
    local myClass = {
        new = function(additonalFns)
            local instance = {}
            for key, value in pairs(initials) do
                instance[key] = value
            end
            for key, fn in pairs(additonalFns) do
                instance[key] = fn
            end
            return setmetatable(instance, {__index = publics})
        end
    }
    local builder
    builder = {
        addProperty = function(property, default, listener)
            property = property:lower()
            initials[property] = default
            initials[property.."Listener"] = listener
            local upProperty = property:sub(1,1):upper()..property:sub(2)
            publics["get"..upProperty] = function(self)
                return self[property]
            end
            publics["set"..upProperty] = function(self, value, update)
                self[property] = value
                if(update ~= false) then
                    local listener = self[property.."Listener"]
                    if(listener) then
                        listener(self, value)
                    end
                end
                return self
            end
            publics["onChange"..upProperty] = function(self, listener)
                self[property.."Listener"] = listener
                return self
            end
            return builder
        end,
        addFunctions = function(tbl)
            for key, fn in pairs(tbl) do
                publics[key] = fn
            end
            return builder
        end,
        addFunction = function(name, fn)
            publics[name] = fn
            return builder
        end,
        -- returns class
        build = function()
            return myClass
        end
    }
    return builder
end