--[[
2022-02-14 - Not working properly as watchpoint will not be "watched" if not changed by /script from chat. Any other addon changing the values does not fire the "changed" metatable proxy

local tbug = TBUG or SYSTEMS:GetSystem("merTorchbug")

local strfor = string.format
local tos= tostring
local parseSlashCommandArgumentsAndReturnTable = tbug.parseSlashCommandArgumentsAndReturnTable

local addWatchpointTo = tbug.AddTableVariableWatchpoint --tableRef, variableName, onChangeOnly, callbackFunction
local removeWatchpointFrom = tbug.RemoveTableVariableWatchpoint --tableRef, variableName,
function tbug.slashCommandWatchpoint(args)
    --Add a watchpoint to the variable, if it is a table variable and if it is global
    if args ~= "" then
--tbug._AddWatchpointArgs = args
        local argsOptions = parseSlashCommandArgumentsAndReturnTable(args, false)
--tbug._AddWatchpointArgsOptions = argsOptions
        local isOnlyOneArg = (argsOptions and #argsOptions == 1) or false
        local tableName, variableName
        if isOnlyOneArg == true then
--d(">Only 1 argument, try to split at .")
            local helpStrToSplitAtPoint = argsOptions[1]
            if strfind(helpStrToSplitAtPoint, ".", 1, true) ~= nil then
--d(">>found a . in " ..tos(helpStrToSplitAtPoint))
                --Split at first . to table . variable
                local splitUpStrParts = strsplit(helpStrToSplitAtPoint, ".")
                if splitUpStrParts ~= nil and #splitUpStrParts == 2 then
--d(">>found 2 split parts")
                    tableName = splitUpStrParts[1] --table name in _G
                    variableName = splitUpStrParts[2] --variable in table
                end
            end
        else
--d(">found more than 1 argument")
            tableName = argsOptions[1] --table name in _G
            variableName = argsOptions[2] --variable in table
        end
        if tableName ~= nil and tableName ~= "" and variableName ~= nil and variableName ~= ""
            and _G[tableName] ~= nil then
--d("[TBUG]Adding watchpoint - tableName: " ..tos(tableName) ..", varName: " .. tos(variableName))
            --Add the watchpoint on tableName, variableName
            addWatchpointTo(tableName, variableName, true, nil)
        end
    end
end

-- Watchpoints: Inspect variable changes -> Only works for table variables via set- and getmetatable
--found here
--https://stackoverflow.com/questions/59492946/change-update-value-of-a-local-variable-lua-upvalue
--->Enhanded by IsJustAGhost 2022-02-08 in esoui gitter. With his permission "go ahead" using his code example and enhancing it to the needs

--The stored table references where watchpoints are added
local watchpointTables = {}
tbug.watchpointTables = watchpointTables
local watchpointTables_Private = {}
tbug.watchpointTables_Private = watchpointTables_Private
local watchpointTables_ProxyFuncs = {}
tbug.watchpointTables_ProxyFuncs = watchpointTables_ProxyFuncs

--The watchpoints (variable names) per table
local watchpoints = {}
tbug.watchpoints = watchpoints

--Ignore these table keys inside the callback funtion of setmetatable index
local ignoreTableKeysForMetatables = {
   ["RegisterCallback"] =                   true,
   ["UnregisterCallback"] =                 true,
   ["_tbugWatchpoint_callbackFunctions"] =  true,
   ["_tbugWatchpoint_onChangeOnly"] =       true,
   ["_tbugWatchpoint_tableRef"] =           true
}

--Metatable index check table: Calling the updateFunction if any value changes in that table's key
local function onNewTableIndex(tabRef, key, value)
    if not ignoreTableKeysForMetatables[key] then
d("[TBUG]onNewTableIndex - key: " ..tos(key) .. ", value: " ..tos(value))
        --Do not fire the callback if no value was changed?
        if tabRef._tbugWatchpoint_onChangeOnly[key] == true and tabRef[key] == value then return end
        --Get the callack function for the value
        local updateFunction = tabRef._tbugWatchpoint_callbackFunctions[key]
        if updateFunction ~= nil then
            updateFunction(key, value, tabRef)
        end
    end
    --Call the original index function of the table, via the getmetatable
    getmetatable(tabRef).__index[key] = value
end

local function variableChangedOutput(key, value, tableRef)
    d(strfor("[TBUG]Watchpoint on {%s}: %q=%s", tos(tableRef), tos(key), tos(value)))
end

local function addWatchpointCallbackHandler(tableRef)
    --Do not add another reference for the callback register/unregister to the same table
    if watchpointTables[tableRef] ~= nil then
d("<existing watchpoint table handler was found")
        return watchpointTables[tableRef]
    end
d(">adding new watchpoint table handler now")

    local privateTableRef = tableRef
    watchpointTables_Private[tableRef] = privateTableRef
    --Metatable proxy function
    local metatableProxyFunc = {
      __index = function (t,k)
            return privateTableRef[k]   -- access the original table
      end,

      __newindex = function (t,k,v)
            privateTableRef[k] = v   -- update original table
            onNewTableIndex(t,k,v)
      end
    }
    watchpointTables_ProxyFuncs[tableRef] = metatableProxyFunc

    --Add function "onNewIndex" that fires each time as any index in tableRef changes and store that into a reference to the metatable of the table to watch
    --local callbackHandlerForWatchedTableVariable = setmetatable({}, { __newindex = onNewTableIndex, __index = tableRef}) --use the entries of passed in table, at same index. Call onNewTableIndex if an inde get's added
    local callbackHandlerForWatchedTableVariable = setmetatable(tableRef, metatableProxyFunc)
    if callbackHandlerForWatchedTableVariable == nil then return end
    callbackHandlerForWatchedTableVariable._tbugWatchpoint_tableRef = tableRef
    callbackHandlerForWatchedTableVariable._tbugWatchpoint_callbackFunctions = {}
    callbackHandlerForWatchedTableVariable._tbugWatchpoint_onChangeOnly = {}

    watchpointTables[tableRef] = callbackHandlerForWatchedTableVariable
    watchpoints[tableRef] = watchpoints[tableRef] or {}

    --Add callback register and unregister functions to that
    function callbackHandlerForWatchedTableVariable.RegisterCallback(name, callbackFunction, onChangeOnly)
d(">>>ADD Callback on table watchpoint: Register on variable: " ..tos(name))
        if callbackHandlerForWatchedTableVariable._tbugWatchpoint_tableRef[name] == nil then return false end

        callbackHandlerForWatchedTableVariable._tbugWatchpoint_callbackFunctions[name] = callbackFunction
        watchpoints[tableRef][name] = { onChangeOnly = onChangeOnly, callbackFunc = callbackFunction }

        --Remember which variable of the table should only fire a changed callback if the value really changed
        callbackHandlerForWatchedTableVariable._tbugWatchpoint_onChangeOnly[name] = onChangeOnly or false
    end

    function callbackHandlerForWatchedTableVariable.UnregisterCallback(name)
d(">>>REM Callback on table watchpoint: Register on variable: " ..tos(name))
        local lTableRef = callbackHandlerForWatchedTableVariable._tbugWatchpoint_tableRef
        local callbackFuncs = callbackHandlerForWatchedTableVariable._tbugWatchpoint_callbackFunctions
        if lTableRef ~= nil and callbackFuncs ~= nil and callbackFuncs[name] ~= nil then
            callbackHandlerForWatchedTableVariable._tbugWatchpoint_callbackFunctions[name] = nil
            watchpoints[lTableRef][name] = nil

            --Check how many variables are still tracked at the table and remove the metatable again if 0
            if NonContiguousCount(watchpoints[lTableRef]) == 0 then
                --The metatable is not at the lTableRef but it is at callbackHandlerForWatchedTableVariable -> self
                if getmetatable(callbackHandlerForWatchedTableVariable) ~= nil then
                    setmetatable(callbackHandlerForWatchedTableVariable, nil)
                end
                watchpoints[lTableRef] = nil
                watchpointTables[lTableRef] = nil
                local refToMetaTableProxyFunc = watchpointTables_ProxyFuncs[lTableRef]
                if refToMetaTableProxyFunc ~= nil then
                    refToMetaTableProxyFunc = nil
                end
                watchpointTables_ProxyFuncs[lTableRef] = nil
                watchpointTables_Private[lTableRef] = nil
                zo_callLater(function() callbackHandlerForWatchedTableVariable = nil  end, 20)
            end
            return true
        end
        return false
    end
    return callbackHandlerForWatchedTableVariable
end

local function removeWatchpointFrom(tableRef, variableName)
d("[TBUG]removeWatchpointFrom]tab: " ..tos(tableRef)..", var: " ..tos(variableName))
    local callbackHandlerForTableRef = watchpointTables[tableRef]
    if not callbackHandlerForTableRef then return false end
    return callbackHandlerForTableRef.UnregisterCallback(variableName)
end
tbug.RemoveTableVariableWatchpoint = removeWatchpointFrom

local function addWatchpointTo(tableRef, variableName, onChangeOnly, callbackFunction)
d("[TBUG]addWatchpointTo]tab: " ..tos(tableRef)..", var: " ..tos(variableName) .. ", onChangeOnly: " ..tos(onChangeOnly))
    if onChangeOnly == nil then onChangeOnly = true end
    if callbackFunction == nil then callbackFunction = variableChangedOutput end
    if (tableRef == nil and _G[tableRef] == nil) or variableName == nil then return end
    local tableRefType = type(tableRef)
    local isTableRefString = tableRefType == stringType
    if not isTableRefString and tableRef ~= nil then
d(">1")
        if tableRefType ~= tableType and tableRefType ~= userDataType then return end
        if tableRef[variableName] == nil then return end
    elseif isTableRefString == true and _G[tableRef] ~= nil then
d(">2")
        tableRefType = type(_G[tableRef])
        if tableRefType ~= tableType and tableRefType ~= userDataType then return end
        if _G[tableRef][variableName] == nil then return end
d(">3")
        tableRef = _G[tableRef]
    end
    if tableRef == nil then return false end
    --Watchpoint was already added?
    if watchpoints[tableRef] ~= nil then
d(">>4")
        --Remove it again
        if watchpoints[tableRef][variableName] ~= nil then
d("<<<5")
            return removeWatchpointFrom(tableRef, variableName)
        end
    end
d(">6")
    --Add new callbackHandler to the table, via setmetatable
    local callbackHandlerForTableRef = addWatchpointCallbackHandler(tableRef)
    if not callbackHandlerForTableRef then return end
    --Register a new callback handler to the table's variable change
    return callbackHandlerForTableRef.RegisterCallback(variableName, callbackFunction, onChangeOnly)
end
tbug.AddTableVariableWatchpoint = addWatchpointTo



--CallbackVariable:RegisterCallback('foo', callbackFunction, UpdateIfValuesDifferOnly)
--CallbackVariable:RegisterCallback('bar', callbackFunction)
--CallbackVariable.foo = 'bar' -- fires callback
--CallbackVariable.foo = 'bar' -- does not fire callback
--CallbackVariable.foo = 'change' -- fires callback
--CallbackVariable.bar = 'foo'-- fires callback

--CallbackVariable:UnregisterCallback('bar')

--CallbackVariable.bar = 'foo' -- does not fire callback
------------------------------------------------------------------------------------------------------------------------
]]