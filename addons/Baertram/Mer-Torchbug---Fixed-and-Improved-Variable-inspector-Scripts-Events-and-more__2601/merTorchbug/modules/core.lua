local tbug = TBUG or SYSTEMS:GetSystem("merTorchbug")

local strfind = string.find
local strlower = string.lower
local strlen = string.len
local strsub = string.sub

--Mouse over control (MOC) - Number of opened tabs
tbug.numMOCTabs = 0

--Track merTorchbug load time and session time
local startTimeTimeStamp = GetTimeStamp()
tbug.startTimeTimeStamp = startTimeTimeStamp
local startTime = startTimeTimeStamp * 1000
tbug.startTime = startTime
tbug.sessionStartTime = startTime - GetGameTimeMilliseconds()

local EM = EVENT_MANAGER

local getmetatable = getmetatable
--local next = next
local rawget = rawget
local rawset = rawset
local select = select
local setmetatable = setmetatable
local tos = tostring
local strupper = string.upper
local strgmatch = string.gmatch
local tins = table.insert
local tsort = table.sort

local osdate = os.date

local types = tbug.types
local stringType = types.string
local numberType = types.number
local functionType = types.func
local tableType = types.table
local userDataType = types.userdata
local structType = types.struct

local prefixForLeftKey = tbug.prefixForLeftKey
local prefixForLeftKeyLen = strlen(prefixForLeftKey)

local rtSpecialReturnValues = tbug.RTSpecialReturnValues
local excludeTypes = { [CT_INVALID_TYPE] = true }
local panelNames = tbug.panelNames
local uiTemplates = tbug.UITemplates

local lookupTabClass = tbug.LookupTabs["class"]
local lookupTabObject = tbug.LookupTabs["object"]
local lookupTabLibrary = tbug.LookupTabs["library"]

local classIdentifierKeys = tbug.classIdentifierKeys

local getControlType
local doNotGetParentInvokerNameAttributes = tbug.doNotGetParentInvokerNameAttributes
local tbug_glookup = tbug.glookup
local tbug_glookupEnum = tbug.glookupEnum
local functionsItemLink = tbug.functionsItemLink
local functionsItemLinkSorted = tbug.functionsItemLinkSorted
local isPrivateOrProtectedFunction


------------------------------------------------------------------------------------------------------------------------
local function throttledCall(callbackName, timer, callback, ...)
    if not callbackName or callbackName == "" or not callback then return end
    local args = ... ~= nil and  {...} or {}
    local function Update()
        EM:UnregisterForUpdate(callbackName)
        callback(unpack(args))
    end
    EM:UnregisterForUpdate(callbackName)
    EM:RegisterForUpdate(callbackName, timer, Update)
end
tbug.throttledCall = throttledCall

local function hideContextMenus()
    ClearMenu()
    if LibScrollableMenu then
        ClearCustomScrollableMenu()
    end
end
tbug.HideContextMenus = hideContextMenus

local function hideLoadingSpinner(control, doHide)
    if control and control.isGlobalInspector == true then
        --d("[Tbug]hideLoadingSpinner - isGlobalInspector: true, doHide: " ..tos(doHide))
        --Show the loading spinner at the global inspector
        local globalInspector = tbug.getGlobalInspector()
        if globalInspector ~= nil then
            globalInspector:UpdateLoadingState(doHide)
        end
    end
end
tbug.hideLoadingSpinner = hideLoadingSpinner

local function strsplit(inputstr, sep)
   sep = sep or "%s" --whitespace
   local t={}
   for str in strgmatch(inputstr, "([^"..sep.."]+)") do
      tins(t, str)
   end
   return t
end
tbug.strSplit = strsplit

local function isSplittableString(str, sepparator)
    if type(str) ~= stringType then return false, nil end
    local splitTab = strsplit(str, sepparator)
    local isSplittable = (splitTab ~= nil and #splitTab > 1 and true) or false
    return isSplittable, splitTab
end
tbug.isSplittableString = isSplittableString

local function findUpperCaseCharsAndReturnOffsetsTab(str)
    local retTab = {}
    if type(str) ~= stringType then return retTab end

    --Only repeat the string.find 20 times at max (prevent endless loop)
    local counter = 20

    local foundPos = 1
    local strLen = strlen(str)

    while counter >= 1 do
        local startPos, endPos
        startPos, endPos = strfind(str, "%u+", foundPos)
        --d("startPos: " ..tos(startPos) .. ", endPos: " ..tos(endPos))
        if startPos ~= nil and endPos  ~= nil then
            --Check if the offsets of any uppercase found characters are directly after the before one
            -->Then it's an uppercase string -> Combine those again until next offset of an uppercase char is not current +1
            retTab[#retTab + 1] = { startPos=startPos, endPos=endPos }

            if endPos <= strLen then
                foundPos = endPos + 1
            else
                --reached string end
                counter = 0
                break -- end the while loop
            end
        else
            --nothing found with uppercase -> Abort
            counter = 0
            break --end the while loop
        end
        counter = counter - 1
    end
    return retTab
end
tbug.findUpperCaseCharsAndReturnOffsetsTab = findUpperCaseCharsAndReturnOffsetsTab

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function inherit(class, base)
    getmetatable(class).__index = base
    return class
end


local function new(class, ...)
    local instance = setmetatable({}, class)
    return instance, instance:__init__(...)
end


local function newClass(dict, name)
    local classMT = {__call = new, __concat = inherit}
    local class = {}
    rawset(class, "__index", class)
    rawset(dict, name, class)
    return setmetatable(class, classMT)
end


tbug.classes = setmetatable({}, {__index = newClass})


function tbug.autovivify(mt)
    local function setdefault(self, key)
        local sub = setmetatable({}, mt)
        rawset(self, key, sub)
        return sub
    end
    return {__index = setdefault}
end
local autovivify = tbug.autovivify


tbug.cache = setmetatable({}, autovivify(nil))


local function invoke(object, method, ...)
    return object[method](object, ...)
end
tbug.invoke = invoke


function tbug.isControl(object)
    return type(object) == userDataType and type(object.IsControlHidden) == functionType
end


function tbug.getControlName(control)
    local ok, name = pcall(invoke, control, "GetName")
    if not ok or name == "" then
        return tos(control)
    else
        return tos(name)
    end
end


function tbug.getControlType(control, enumType)
    local ok, ct = pcall(invoke, control, "GetType")
    if ok then
        enumType = enumType or "CT"
        tbug_glookupEnum = tbug_glookupEnum or tbug.glookupEnum
        local enum = tbug_glookupEnum(enumType)
        return ct, enum[ct]
    end
end
getControlType = tbug.getControlType

local function getGlobalInspectorPanelTabName(tabName)
    if type(tabName) ~= stringType then return end
    for k, globalInspectrTabData in ipairs(panelNames) do
        if globalInspectrTabData.key == tabName or globalInspectrTabData.name == tabName then
            return globalInspectrTabData.key
        end
    end
    return
end
tbug.getGlobalInspectorPanelTabName = getGlobalInspectorPanelTabName

local function getTBUGGlobalInspectorPanelIdByName(tabKeyOrName)
    for panelId, panelData in ipairs(panelNames) do
        if panelData.key == tabKeyOrName or panelData.name == tabKeyOrName then return panelId end
    end
    return
end
tbug.getTBUGGlobalInspectorPanelIdByName = getTBUGGlobalInspectorPanelIdByName

function tbug.bind1(func, arg1)
    return function(...)
        return func(arg1, ...)
    end
end


function tbug.bind2(func, arg1, arg2)
    return function(...)
        return func(arg1, arg2, ...)
    end
end


function tbug.foreach(tab, func)
    for key, val in zo_insecureNext , tab do
        func(key, val)
    end
end


function tbug.foreachValue(tab, func)
    for key, val in zo_insecureNext , tab do
        func(val)
    end
end


function tbug.gettype(tab, key)
    local mt = getmetatable(tab)
    if mt then
        local gettype = mt._tbug_gettype
        if gettype then
            return gettype(tab, key)
        end
    end
    return type(rawget(tab, key))
end


function tbug.setindex(tab, key, val)
    local mt = getmetatable(tab)
    if mt then
        local setindex = mt._tbug_setindex
        if setindex then
            setindex(tab, key, val)
            return rawget(tab, key)
        end
    end
    rawset(tab, key, val)
    return val
end


function tbug.subtable(tab, ...)
    for i = 1, select("#", ...) do
        local key = select(i, ...)
        local sub = tab[key]
        if type(sub) ~= tableType then
            sub = {}
            tab[key] = sub
        end
        tab = sub
    end
    return tab
end


do
    local function tail(name, t1, ...)
        local t2 = GetGameTimeMilliseconds()
        df("%s took %.3fms", name, t2 - t1)
        return ...
    end

    function tbug.timed(name, func)
        return function(...)
            local t1 = GetGameTimeMilliseconds()
            return tail(name, t1, func(...))
        end
    end
end


function tbug.truncate(tab, len)
    for i = #tab, len + 1, -1 do
        tab[i] = nil
    end
    return tab
end

local typeOrder =
{
    ["nil"] = 0,
    ["boolean"] = 1,
    [numberType] = 2,
    [stringType] = 3,
    [tableType] = 4,
    [userDataType] = 5,
    [functionType] = 6,
}

setmetatable(typeOrder,
{
    __index = function(t, k)
        df("tbug: typeOrder[%q] undefined", tos(k))
        return -1
    end
})

local typeComparePattern = "^_*"
local typeCompare =
{
    ["nil"] = function(a, b) return false end,
    ["boolean"] = function(a, b) return not a and b end,
    [numberType] = function(a, b) return a < b end,
    [stringType] = function(a, b)
        local _, na = a:find(typeComparePattern)
        local _, nb = b:find(typeComparePattern)
        if na ~= nb then
            return na > nb
        else
            return a < b
        end
    end,
    [tableType] = function(a, b) return tos(a) < tos(b) end,
    [userDataType] = function(a, b) return tos(a) < tos(b) end,
    [functionType] = function(a, b) return tos(a) < tos(b) end,
}

function tbug.typeSafeLess(a, b)
    local ta, tb = type(a), type(b)
    if ta ~= tb then
        return typeOrder[ta] < typeOrder[tb]
    else
        return typeCompare[ta](a, b)
    end
end

function tbug.firstToUpper(str)
    return (str:gsub("^%l", strupper))
end

function tbug.startsWith(str, start)
    if str == nil or start == nil or start  == "" then return false end
    return str:sub(1, #start) == start
end

function tbug.endsWith(str, ending)
    if str == nil or ending == nil or ending  == "" then return false end
    return ending == "" or str:sub(-#ending) == ending
end

local getStringKeys = tbug.getStringKeys
local function isGetStringKey(key)
    return getStringKeys[key] or false
end
tbug.isGetStringKey = isGetStringKey

local function isObjectOrClassOrLibrary(subject, key)
    tbug_glookup = tbug_glookup or tbug.glookup
    local lookupName = (subject ~= nil and tbug_glookup(subject)) or nil
--d(">subject: " .. tos(subject) ..", key: " .. tos(key) .. ", lookupName: " ..tos(lookupName))
    if type(lookupName) ~= stringType then return nil, nil, nil, nil end

    local isLibrary = lookupTabLibrary[lookupName] or false
    local isClass = (not isLibrary and lookupTabClass[lookupName]) or false
    local isObject = (not isLibrary and not isClass and lookupTabObject[lookupName]) or false

 --d("[tbug]isObjectOrClassOrLibrary: " ..tos(lookupName) .. ", key: " .. tos(key) .. ", isLibrary: " .. tos(isLibrary).. ", isClass: " .. tos(isClass).. ", isObject: " .. tos(isObject))

    if not isObject and not isClass and not isLibrary then
        local tv = type(subject)
        if tv == tableType then
            if subject == _G then
                isPrivateOrProtectedFunction = isPrivateOrProtectedFunction or tbug.isPrivateOrProtectedFunction
                local isKeyPrivOrProtFunc = isPrivateOrProtectedFunction(subject, key)
                if isKeyPrivOrProtFunc == true then
--d(">isKeyPrivOrProtFunc: " ..tos(isKeyPrivOrProtFunc) .. ", key: " ..tos(key) .. "; subject: " .. tos(subject))
                    return false, false, false, nil
                end

                -- Check if the value is a function before proceeding
                local value = (key ~= nil and _G[key]) or nil
                if value == nil then return false, false, false, lookupName end

                local valueType = type(value)
                if valueType == functionType then
                    return false, false, false, nil
                elseif valueType == tableType then
                    -- Only proceed with rawget if we know it's a table
                    lookupName = tbug_glookup(value) or nil
                    -- d(">>lookupName: " ..tos(lookupName))
                    if type(lookupName) ~= stringType then return nil, nil, nil, nil end

                    if rawget(value, "__index") then
                        lookupTabClass[lookupName] = true
                        -- class
                        return false, true, false, lookupName
                    else
                        for l_key, _ in zo_insecureNext, value do
                            if not isClass and classIdentifierKeys[l_key] then
                                -- isClass = true
                                lookupTabClass[lookupName] = true
                                -- class
                                return false, true, false, lookupName
                            end
                        end
                        -- if not isClass then
                        -- Object
                        lookupTabObject[lookupName] = true
                        return true, false, false, lookupName
                        -- end
                    end
                end
            else
                -- Only proceed with rawget if subject is a table
                if rawget(subject, "__index") then
                    lookupTabClass[lookupName] = true
                    -- class
                    return false, true, false, lookupName
                else
                    for l_key, _ in zo_insecureNext, subject do
                        if not isClass and classIdentifierKeys[l_key] then
                            isClass = true
                            lookupTabClass[lookupName] = true
                            -- class
                            return false, true, false, lookupName
                        end
                    end

                    if not isClass then
                        lookupTabObject[lookupName] = true
                        -- Object
                        return true, false, false, lookupName
                    end
                end
            end
        end
    end
    return isObject, isClass, isLibrary, lookupName
end
tbug.isObjectOrClassOrLibrary = isObjectOrClassOrLibrary


--Get a property of a control in the TorchBugControlInspector list, at index indexInList, and the name should be propName
function tbug.getPropOfControlAtIndex(listWithProps, indexInList, propName, searchWholeList)
    if not listWithProps or not indexInList or not propName or propName == "" then return end
    searchWholeList = searchWholeList or false
    local listEntryAtIndex = listWithProps[indexInList]
    if listEntryAtIndex then
        local listEntryAtIndexData = listEntryAtIndex.data
        if listEntryAtIndexData then
            if (listEntryAtIndexData.prop and listEntryAtIndexData.prop.name and listEntryAtIndexData.prop.name == propName) or
             (listEntryAtIndexData.data and listEntryAtIndexData.data.key and listEntryAtIndexData.data.key == propName) then
                return listEntryAtIndexData.value
            else
                --The list is not control inspector and thus the e.g. bagId and slotIndex are not next to each other, so we
                --need to search the whole list for the propName
                if searchWholeList == true then
                    for _, propData in ipairs(listWithProps) do
                        if (propData.prop and propData.prop.name and propData.prop.name == propName) or
                            (propData.data and propData.data.key and propData.data.key == propName) then
                            return propData.data and propData.data.value
                        end
                    end
                end
            end
        end
    end
    return nil
end

local specialEntriesAtInspectorLists = tbug.specialEntriesAtInspectorLists
local function isSpecialEntryAtInspectorList(entry)
    local specialKeys = specialEntriesAtInspectorLists
    return specialKeys[entry] or false
end

--Check if the number at the currently clicked row at the controlInspectorList is a special number
--like a pair of bagid and slotIndex
function tbug.isSpecialEntryAtInspectorList(p_self, p_row, p_data)
    if not p_self or not p_row or not p_data then return end
    local props = p_data.prop
    if not props then

        --Check if it's not a control but another type having only a key
        if p_data.key then
            props = {}
            props.isSpecial = isSpecialEntryAtInspectorList(p_data.key)
        end
    end
    if not props then return end
    return props.isSpecial or false
end

local function returnTextAfterLastDot(str)
    local strAfterLastDot = str:match("[^%.]+$")
    return strAfterLastDot
end

--Try to get the key of the object (the string behind the last .)
function tbug.getKeyOfObject(objectStr)
    if objectStr and objectStr ~= "" then
        return returnTextAfterLastDot(objectStr)
    end
    return nil
end

--Clean the key of a key String (remove trailing () or [])
function tbug.cleanKey(keyStr)
    if keyStr == nil or keyStr == "" then return end
    if not tbug.endsWith(keyStr, "()") and not tbug.endsWith(keyStr, "[]") then return keyStr end
    local retStr = keyStr:sub(1, (keyStr:len()-2))
    return retStr
end

local inventoryRowPatterns = tbug.inventoryRowPatterns
--Is the control an inventory list row? Check by it's name pattern
function tbug.isSupportedInventoryRowPattern(controlName)
    if not controlName then return false, nil end
    if not inventoryRowPatterns then return false, nil end
    for _, patternToCheck in ipairs(inventoryRowPatterns) do
        if controlName:find(patternToCheck) ~= nil then
            return true, patternToCheck
        end
    end
    return false, nil
end

function tbug.formatTime(timeStamp)
    if type(timeStamp) ~= numberType then return end
    return osdate("%F %T.%%03.0f %z", timeStamp / 1000):format(timeStamp % 1000)
end

function tbug.formatTimestamp(timeStamp)
    if type(timeStamp) ~= numberType then return end
    return osdate("%c", timeStamp)
end

--Get the zone and subZone string from the given map's tile texture (or the current's map's tile texture name)
function tbug.getZoneInfo(mapTileTextureName, patternToUse)
--[[
    Possible texture names are e.g.
    /art/maps/southernelsweyr/els_dragonguard_island05_base_8.dds
    /art/maps/murkmire/tsofeercavern01_1.dds
    /art/maps/housing/blackreachcrypts.base_0.dds
    /art/maps/housing/blackreachcrypts.base_1.dds
    Art/maps/skyrim/blackreach_base_0.dds
    Textures/maps/summerset/alinor_base.dds
]]
    mapTileTextureName = mapTileTextureName or GetMapTileTexture()
    if not mapTileTextureName or mapTileTextureName == "" then return end
    local mapTileTextureNameLower = mapTileTextureName:lower()
    mapTileTextureNameLower = mapTileTextureNameLower:gsub("ui_map_", "")
    --mapTileTextureNameLower = mapTileTextureNameLower:gsub(".base", "_base")
    --mapTileTextureNameLower = mapTileTextureNameLower:gsub("[_+%d]*%.dds$", "") -> Will remove the 01_1 at the end of tsofeercavern01_1
    mapTileTextureNameLower = mapTileTextureNameLower:gsub("%.dds$", "")
    mapTileTextureNameLower = mapTileTextureNameLower:gsub("_%d*$", "")
    local regexData = {}
    if not patternToUse or patternToUse == "" then patternToUse = "([%/]?.*%/maps%/)(%w+)%/(.*)" end
    regexData = {mapTileTextureNameLower:find(patternToUse)} --maps/([%w%-]+/[%w%-]+[%._][%w%-]+(_%d)?)
    local zoneName, subzoneName = regexData[4], regexData[5]
    local zoneId = GetZoneId(GetCurrentMapZoneIndex())
    local parentZoneId = GetParentZoneId(zoneId)
    d("========================================\n[TBUG.getZoneInfo]\nzone: " ..tos(zoneName) .. ", subZone: " .. tos(subzoneName) .. "\nmapTileTexture: " .. tos(mapTileTextureNameLower).."\nzoneId: " ..tos(zoneId).. ", parentZoneId: " ..tos(parentZoneId))
    return zoneName, subzoneName, mapTileTextureNameLower, zoneId, parentZoneId
end

--Check if not the normal data.key should be returned (and used for e.g. a string search or the RAW string copy context
-- menu), but any other of the data entries (e.g. data.value._eventName for the "Events" tab)
local function checkForSpecialDataEntryAsKey(data, isRightKey)
    --Use the left key's text
    local key = data.key
--d("[TBub]checkForSpecialDataEntryAsKey - key: " ..tos(key) .. ", isRightKey: " ..tos(isRightKey))
    local dataEntry = data.dataEntry
    if isRightKey == nil then
        local typeId = dataEntry.typeId
        local specialReturnValue = rtSpecialReturnValues[typeId]
        local specialPlaceWhereTheStringsIsFound = (specialReturnValue ~= nil and specialReturnValue.replaceName) or nil
        if specialPlaceWhereTheStringsIsFound ~= nil then
            local funcToGetStr, err = zo_loadstring("return data." .. specialPlaceWhereTheStringsIsFound)
            if err ~= nil or not funcToGetStr then
--d(">err or funcToGetStr is nil")
                return key
            else
                local filterEnv = setmetatable({}, {__index = tbug.env})
                setfenv(funcToGetStr, filterEnv)
                filterEnv.data = data
                local isOkay
                isOkay, key = pcall(funcToGetStr)
--d(">isOkay: " ..tos(isOkay) .. ", key: " ..tos(key))
                if not isOkay then return key end

                local typeReplaceFunc = type(specialReturnValue.replaceFunc)
                if typeReplaceFunc == functionType then
                    local replaceFunc = specialReturnValue.replaceFunc() --get tbug.formatTime
--d(">specialReturnValue.replaceFunc CALL")
                    key = replaceFunc(key)
                end
            end
        end
    else
        --Copy the right's key text
        if isRightKey == true then
            local rowCtrl = dataEntry.control
            local cKeyRight = rowCtrl and rowCtrl.cKeyRight
            if cKeyRight and cKeyRight.GetText then
                key = cKeyRight:GetText()

                --Strip the <-- prefix for a rightKey that shows the value of the leftKey, and not for the value
                if strfind(key, prefixForLeftKey, 1, true) == 1 then
                    key = strsub(key, prefixForLeftKeyLen-1)
                end
            end
        end
    end
    return key
end
tbug.checkForSpecialDataEntryAsKey = checkForSpecialDataEntryAsKey

local function getControlCTType(control)
    if control == nil or (control ~= nil and control.SetHidden == nil) then return end
    return getControlType(control, "CT_names")
end

--Check if the value is a control and what type that control is (CT_CONTROL, CT_TOPLEVELCONTROL, etc.)
function tbug.isAControlOfTypes(data, searchedControlTypes)
    if data == nil then return false end
    local key = data.key
    local value = data.value

    --d("[TBUG]isAControlOfTypes-key: " ..tos(key) .. ", value: " ..tos(value))
    if key == nil or (value == nil or (value ~= nil and (value.SetHidden == nil) or (type(value) ~= userDataType))) then return false end

    if searchedControlTypes == nil then
        --No dropdown filterTypes selected -> Allow all
        return true
    else
        local typeOfControl, _ = getControlCTType(value)
--[[
if TBUG._debugNow == true then
    d("[TBUG]isAControlOfTypes-type: " ..tos(typeOfControl))
end
]]
        if typeOfControl ~= nil then
            for typeToCheck, isAllowed in pairs(searchedControlTypes) do
                if isAllowed and not excludeTypes[typeToCheck] then
                    if typeToCheck == typeOfControl then
                        return true
                    end
                end
            end
        end
    end
    return false
end

--Check if the refVar contains any attribute/entry with the name specified in constants tbug.doNotGetParentInvokerNameAttributes
function tbug.isNotGetParentInvokerNameAttributes(refVar)
    if refVar == nil then return true end
    for attributeName, isNotAllowed in pairs(doNotGetParentInvokerNameAttributes) do
        if isNotAllowed == true and refVar[attributeName] ~= nil then
            return false
        end
    end
    return true
end
local isNotGetParentInvokerNameAttributes = tbug.isNotGetParentInvokerNameAttributes

--Get the relevant name of a control/userdata like scene/fragment which can be used to call functions with that name
function tbug.getRelevantNameForCall(refVar)
    local relevantNameForCallOfRefVar
    tbug_glookup = tbug_glookup or tbug.glookup
    if isNotGetParentInvokerNameAttributes(refVar) and type(refVar) == userDataType then
        relevantNameForCallOfRefVar = (refVar.GetName ~= nil and refVar:GetName()) or nil
    end
    --ComboBoxes and other global controls using m_* attributes
    if relevantNameForCallOfRefVar == nil or relevantNameForCallOfRefVar == "" then
        if refVar.m_name ~= nil and refVar.m_name ~= "" then
            relevantNameForCallOfRefVar = tbug_glookup(refVar.m_name)
        end
    end
    --All other global controls
    if relevantNameForCallOfRefVar == nil or relevantNameForCallOfRefVar == "" then
        --Try to get the name by help of global table _G
        relevantNameForCallOfRefVar = tbug_glookup(refVar)
    end
    if type(relevantNameForCallOfRefVar) ~= stringType then relevantNameForCallOfRefVar = nil end
    return relevantNameForCallOfRefVar
end


--Check if the key/value is any itemLink API function like GetItemLink*. or IsItemLink* or CheckItemLink*
local function checkIfItemLinkFunc(key, value)
--d("[tbug]checkIfItemLinkFunc-k: " ..tos(key) ..", value: " .. tos(value))
    --Already in the table?
    if functionsItemLink[key] == nil then
        --Does the function name contain any itemlink?
        if strfind(strlower(key), "itemlink", 1, true) then
            functionsItemLink[key] = value
            return true
        end
    end
    return false
end
tbug.checkIfItemLinkFunc = checkIfItemLinkFunc

local function sortItemLinkFunctions()
    --functions panel: ItemLink functions were found? Sort them by name now
    if not ZO_IsTableEmpty(functionsItemLink) then
--d("[tbug]found itemLink functions: " ..tos(NonContiguousCount(functionsItemLink)))
        local entryCount = 0
        for k, _ in pairs(functionsItemLink) do
            entryCount = entryCount + 1
--d(">entryCount added: " ..tos(entryCount) .. " - name: " ..tos(k))
            functionsItemLinkSorted[entryCount] = k
        end
        tsort(functionsItemLinkSorted)
    end
end
tbug.sortItemLinkFunctions = sortItemLinkFunctions


--UI font template functions
function tbug.GetDefaultTemplate()
    return uiTemplates[1] --default
end
local tbug_getDefaultTemplate = tbug.GetDefaultTemplate

function tbug.GetTemplate()
	local template = tbug.savedVars.customTemplate or tbug_getDefaultTemplate()
    return template
end
local tbug_getTemplate = tbug.GetTemplate

function tbug.GetTemplateFontAndHeight()
    local template = tbug_getTemplate()
    if template == nil then return 'ZoFontGameSmall', 23 end
    local font = template.font or 'ZoFontGameSmall'
    local height = template.height or 23
    return font, height
end
local tbug_GetTemplateFontAndHeight = tbug.GetTemplateFontAndHeight

function tbug.SetTemplate(control, ...)
	--local template = tbug.savedVars.customTemplate or getDefaultTemplate()
    local font, height = tbug_GetTemplateFontAndHeight()
    local numEntries = select("#", ...) or 0
    if numEntries > 0 then
        for i = 1, numEntries do
            local label = select(i, ...)
            if label ~= nil and label.SetFont ~= nil then
                label:SetFont(font)
                if label.SetHeight ~= nil then
                    label:SetHeight(height)
                end
            end
        end
    end

    --Update the controls's height and if it's no control check if it's a table and apply the height to all of it entries (if these are controls -> e.g. tabScroll's tabs)
    if control ~= nil then
        if height ~= nil and control.SetHeight ~= nil then
            control:SetHeight(height)
        elseif type(control) == tableType then
            for _, ctrl in ipairs(control) do
                local label = ctrl.label or ctrl
                if label ~= nil then
                    if label.SetHeight ~= nil then
                        label:SetHeight(height)
                    end
                    if label.SetFont ~= nil then
                        label:SetFont(font)
                    end
                end
            end
        end
    end
end


------------------------------------------------------------------------------------------------------------------------

--Create list of TopLevelControls (boolean parameter onlyVisible: only add visible, or all TLCs)
function TBUG_ListTLC(onlyVisible)
    onlyVisible = onlyVisible or false
    local res = {}
    local l_guiRoot = GuiRoot
    if l_guiRoot then
        for i = 1, l_guiRoot:GetNumChildren() do
            local doAdd = false
            local c = l_guiRoot:GetChild(i)
            if c then
                if onlyVisible then
                    if not c.IsHidden or (c.IsHidden and not c:IsHidden()) then
                        doAdd = true
                    end
                else
                    doAdd = true
                end
                if doAdd then
                    --Do not add the "key" as index/number, but use the control's name so one can search it in the shown inspector via string search
                    --res[i] = c
                    local ctrlName = tbug.getControlName(c)
                    if ctrlName ~= nil then
                        res[ctrlName] = c
                    end
                end
            end
        end
    end
    return res
end