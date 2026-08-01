local tbug = TBUG or SYSTEMS:GetSystem("merTorchbug")

local tos = tostring
local strfind = string.find
local strlower = string.lower

local types = tbug.types
local stringType = types.string
local numberType = types.number
local functionType = types.func
local tableType = types.table
local userDataType = types.userdata
local structType = types.struct


local RT = tbug.RT
local RT_local_string = RT.LOCAL_STRING
local rowTypes = tbug.RowTypes
local filterModes = tbug.filterModes


local tbug_glookupEnum = tbug.glookupEnum
local checkForSpecialDataEntryAsKey = tbug.checkForSpecialDataEntryAsKey
local isAControlOfTypes = tbug.isAControlOfTypes

local rtSpecialReturnValues = tbug.RTSpecialReturnValues
local localizationStringKeyText = rtSpecialReturnValues[RT_local_string].replaceName

------------------------------------------------------------------------------------------------------------------------
-- Filter and search
local headerIdsToShow = {}

local function tolowerstring(x)
    return strlower(tos(x))
end

--Check if an entry in the searched list got prop data (prop defines if the entry is some special entry like the ones
--with getter and setter functions (e.g. hidden -> IsHidden() / SetHidden()), or a headline, via the "typ" attribute == 6)

local function checkForProp(data, tosFunc, expr)
    local prop = data.prop
    rowTypes = rowTypes or tbug.RowTypes

    local isHeadline = false
    local searchPropName = false
    local propName = (prop ~= nil and prop.name) or nil
    if prop ~= nil and propName ~= nil then
        if prop.typ ~= nil then
            --No headlines! prop.type == rowTypes.ROW_TYPE_HEADER (6)
            if not prop.isHeader and prop.typ ~= rowTypes.ROW_TYPE_HEADER then
                --Show the entry because the headerId (parentId) is wanted?
                local parentId = prop.parentId
                if parentId ~= nil then
                    if headerIdsToShow[parentId] == true then
                        return true
                    else
                        searchPropName = true
                    end
                else
                    searchPropName = true
                end
            elseif prop.isHeader == true then
                --Headlines
                isHeadline = true
                local headerId = prop.headerId
                if headerId ~= nil then
                    --Search the headline for the string and find relating rows (below) of the headline
                    if strfind(tosFunc(propName), expr, 1, true) ~= nil then
                        headerIdsToShow[headerId] = true
--d(">found headerId: " ..tos(headerId))
                        return true --Show the headline too
                    end
                end
            end
        end
        if searchPropName == true then
            --Search the prop.name for the string
            if strfind(tosFunc(propName), expr, 1, true) ~= nil then
                return true
            end
        end
    end
    return
end


tbug.FilterFactory = {}
local FilterFactory = tbug.FilterFactory
FilterFactory.searchedData = {}
for _,filterMode in ipairs(filterModes) do
    FilterFactory.searchedData[filterMode] = {}
end
FilterFactory.searchedData["ctrl"] = {}

--Search for condition
--[[
    The expression is evaluated for each list item, with environment containing 'k' and 'v' as the list item key and value. Items for which the result is truthy pass the filter.
    For example, this is how you can search the Constants tab for items whose key starts with "B" and whose value is an even number:
    k:find("^B") and v % 2 == 0
]]
function FilterFactory.con(expr)
    local func, _ = zo_loadstring("return " .. expr)
    if not func then
        return nil
    end

    local filterEnv = setmetatable({}, {__index = tbug.env})
    setfenv(func, filterEnv)

    local function conditionFilter(data)
        FilterFactory.searchedData["con"][data] = data

        filterEnv.k = data.key
        filterEnv.v = data.value
        local ok, res = pcall(func)
        return ok and res
    end

    return conditionFilter
end

--Search for patern
function FilterFactory.pat(expr)
    headerIdsToShow = {}
    --local tosFunc = tos

    if not pcall(strfind, "", expr) then
        return nil
    end

    local function patternFilter(data)
        FilterFactory.searchedData["pat"][data] = data

        local value = tos(data.value)
        if strfind(value, expr) ~= nil then
            return true
        end

        --[[
        local prop = data.prop
        --No headlines! prop.type == 6
        if prop ~= nil and prop.name ~= nil and prop.typ ~= nil and prop.typ ~= 6 then
            if not strfind(expr, "%u") then -- ignore case
                tosFunc = tolowerstring
            end
            return strfind(tosFunc(prop.name), expr)
        end
        ]]
    end

    return patternFilter
end

--Search for string
function FilterFactory.str(expr)
    headerIdsToShow = {}
    tbug_glookupEnum = tbug_glookupEnum or tbug.glookupEnum
    local tosFunc = tos
    expr = tolowerstring(expr)

    if not strfind(expr, "%u") then -- ignore case
        tosFunc = tolowerstring
    end

    local function findSI(data)
        local dataEntry = data.dataEntry
        if dataEntry ~= nil and dataEntry.typeId == RT_local_string then
            --local si = rawget(tbug.glookupEnum("SI"), data.key)
            local si = data[localizationStringKeyText]
            if si == nil then si = rawget(tbug_glookupEnum("SI"), data.key) end
            if type(si) == stringType then
                return strfind(tosFunc(si), expr, 1, true)
            end
        end
        return false
    end

    local function stringFilter(data)

        local key = data.key
        FilterFactory.searchedData["str"][data] = data
        if key ~= nil then
--tbug_DEBUG = tbug_DEBUG or {}
--local keyOrig = key
--tbug_DEBUG[keyOrig] = {}
--tbug_DEBUG[keyOrig].expr = expr

--tbug_DEBUG[keyOrig] = { keyOrig = keyOrig, key = key }
            if type(tonumber(key)) == numberType then
--tbug_DEBUG[keyOrig].isKeyNuber = true
                if findSI(data) then
--tbug_DEBUG[keyOrig].isKeySI_Str = true
                    return true
                else
                    --local value = data.value
                    --[[
                    if typeId == RT.ADDONS_TABLE then
                        key = value.name
                    elseif typeId == RT.EVENTS_TABLE then
                        key = value._eventName
                    end
                    ]]
                    key = checkForSpecialDataEntryAsKey(data, nil)
--if keyOrig ~= key then
--    tbug_DEBUG[keyOrig].isKeySpecialDataEntry = true
--    tbug_DEBUG[keyOrig].key = key
--end
                end
            end
            if strfind(tosFunc(key), expr, 1, true) then
--tbug_DEBUG[keyOrig].stringFind1 = true
                return true
            end
        end

        local value = tosFunc(data.value)
        if value ~= nil then
--tbug_DEBUG[value] = { valueOrig = value }
            if strfind(value, expr, 1, true) then
--tbug_DEBUG[value].stringFindValue = true
                return true
            end
        end

        if checkForProp(data, tosFunc, expr) == true then
--tbug_DEBUG[data] = { dataOrig = data }
--tbug_DEBUG[data].checkForProp = true
            return true
        end

    end

    return stringFilter
end

--Search for value
function FilterFactory.val(expr)
    headerIdsToShow = {}
    local ok, result = pcall(zo_loadstring("return " .. expr))
    if not ok then
        return nil
    end

    local function valueFilter(data)
        FilterFactory.searchedData["val"][data] = data
        --local tosFunc = tos

        if data.value ~= nil then
--d(">value: " ..tos(data.value) .. ", result: " ..tos(result))
            if type(data.value) == stringType and type(result) == stringType then
                if rawequal(string.lower(data.value), string.lower(result)) == true then
                    return true
                end
            else
                if rawequal(data.value, result) == true then
                    return true
                end
            end
        end

        --[[
        local prop = data.prop
        --No headlines! prop.type == 6
        if prop ~= nil and prop.name ~= nil and prop.typ ~= nil and prop.typ ~= 6 then
d(">propName: " ..tos(prop.name) .. ", propTyp: " ..tos(prop.typ))
            expr = tolowerstring(expr)
            if not strfind(expr, "%u") then -- ignore case
                tosFunc = tolowerstring
            end
            return strfind(tosFunc(prop.name), expr, 1, true)
        end
        ]]
    end

    return valueFilter
end

--Search for the control type if the row contains a control at the key, or the key2 e.g. CT_TOPLEVELCONTROL
-->selectedDropdownFilters is a table that contains the selected multi select dropdown filterTypes
function FilterFactory.ctrl(selectedDropdownFilters)
    headerIdsToShow = {}
    local function ctrlFilter(data, selfVar)
        local retVar = false
        local key = data.key
        FilterFactory.searchedData["ctrl"][data] = data

--[[
if TBUG._debugNow == true then
TBUG._debugSelectedDropdownFilters = ZO_ShallowTableCopy(selectedDropdownFilters)
d("FilterFactory.ctrl-key: " ..tos(key) .. "; value: " ..tos(data.value) .. "; retVar: " .. tos(isAControlOfTypes(data, selectedDropdownFilters)))
end
]]

        if key ~= nil and type(key) == stringType then
            --Check if the value is a control and if the control type matches
            retVar = isAControlOfTypes(data, selectedDropdownFilters)
        end
        return retVar
    end

    return ctrlFilter
end

--search for the key2 field contents
function FilterFactory.key(expr)
    headerIdsToShow = {}
    local ok, result = pcall(zo_loadstring("return " .. expr))
    if not ok then
        return nil
    end

    local function valueFilter(data)
        FilterFactory.searchedData["key"][data] = data
        --local tosFunc = tos

        if data.key ~= nil then
--d(">keyR: " ..tos(data.keyR) .. ", result: " ..tos(result))
            if rawequal(data.key, result) == true then
                return true
            end
        end

        --[[
        local prop = data.prop
        --No headlines! prop.type == 6
        if prop ~= nil and prop.name ~= nil and prop.typ ~= nil and prop.typ ~= 6 then
d(">propName: " ..tos(prop.name) .. ", propTyp: " ..tos(prop.typ))
            expr = tolowerstring(expr)
            if not strfind(expr, "%u") then -- ignore case
                tosFunc = tolowerstring
            end
            return strfind(tosFunc(prop.name), expr, 1, true)
        end
        ]]
    end

    return valueFilter
end
