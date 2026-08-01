--[[dualListBoxData = {
    type = "duallistbox",
    reference = "MyAddonDualListBox1", -- unique name for your control to use as reference (optional) The <reference>.dualListBox is the direct reference to the dual list box control then
    refreshFunc = function(customControl) end, -- function to call when panel/controls refresh (optional)
    width = "full", -- or "half" (optional)
    minHeight = function() return db.minHeightNumber end, --or number for the minimum height of this control. Default: 26 (optional)
    maxHeight = function() return db.maxHeightNumber end, --or number for the maximum height of this control. Default: 4 * minHeight (optional)
    disabled  = false,    --boolean value or function returning a boolean to tell if the dual list box widget is disabled (default = false). (optional)
    getFuncLeftList = function() return db.leftListTable end -- returning a table of the left list entries. The table returned MUST BE CHANGABLE via this pointer!
    getFuncRightList = function() return db.rightListTable end -- returning a table of the right list entries. The table returned MUST BE CHANGABLE via this pointer!
    setFuncLeftList = function(table) db.leftListTable = var doStuff() end -- Saving a table for the left list entries, where table uses a unique number (accross left & right list!) key and a String as value,
    setFuncRightList = function(table) db.rightListTable = var doStuff() end -- Saving a table for the right list entries, where table uses a unique number (accross left & right list!) key and a String as value,
    defaultLeftList =  { [1] = "Test", [2] = "Test2" }, --table or function returning a table with the default entries at the left list (optional). Left and right list's keys must be unique in total!
    defaultRightList = { [3] = "Value1", [4] = "Value2" }, --table or function returning a table with the default entries at the right list (optional). Left and right list's keys must be unique in total!
    resetFunc = function(customControl) your code to reset the 2 listBoxes now. customControl.dualListBox provides functions ClearLeftList(), ClearRightList(), AddEntriesToLeftList(listEntries), AddEntriesToRightList(listEntries)  end, (optional)
--======================================================================================================================
    -- -v- The dual lists setup data                                                                                -v-
--======================================================================================================================
    setupData = {
        --The overall dual list box control setup data
        name = "LAM_DUALLISTBOX_EXAMPLE1",
        width       = 580,      --number or function returning a number for the width of both list boxes together. If > the width of the LAM control container then the width willbe the LAM control container's width.
        height      = 200,      --number or function returning a number for the height of both list boxes together. minHeight of the LAM control needs to be >= this value! If > maxHeight then maxHeight of the LAM contro will be used

--======================================================================================================================
    ----  -v- The custom settings for the dual lists                                                            -v-
--======================================================================================================================
        --The setup data for the lists
        -->The custom settings are defined via the library LibShifterBox. You can find the documentation here:
        -->https://github.com/klingo/ESO-LibShifterBox#api-reference    Search for "customSettings"
        customSettings = {
            showMoveAllButtons = true,  -- the >> and << buttons to move all entries can be hidden if set to false (default = true). (optional)
            dragDropEnabled = true,     -- entries can be moved between lsit with drag-and-drop (default = true). (optional)
            sortEnabled = true,         -- sorting of the entries can be disabled (default = true). (optional)
            sortBy = "value",           -- sort the list by value or key (allowed are: "value" or "key")  (default = "value"). (optional)

--======================================================================================================================
            leftList = {                -- list-specific settings that apply to the LEFT list
                title = "",                                         -- the title/header of the list (default = ""). (optional)
                rowHeight = 32,                                     -- the height of an individual row/entry (default = 32). (optional)
                rowTemplateName = "ShifterBoxEntryTemplate",        -- an individual XML (cirtual) control can be provided for the rows/entries (default = "ShifterBoxEntryTemplate"). (optional)
                emptyListText = GetString(LIBSHIFTERBOX_EMPTY),     -- the text to be displayed if there are no entries left in the list (default = GetString(LIBSHIFTERBOX_EMPTY)). (optional)
                fontSize = 18,                                      -- size of the font (default = 18). (optional)
                rowDataTypeSelectSound = SOUNDS.ABILITY_SLOTTED,    -- an optional String for an internal soundName to play when a row of this data type is selected (default = SOUNDS.ABILITY_SLOTTED). (optional)
                rowOnMouseRightClick = function(rowControl, data)   -- an optional callback function when a right-click is done inside a row element (e.g. for custom context menus) (optional)
                    d("LSB: OnMouseRightClick: "..tostring(data.tooltipText))   -- reading custom 'tooltipText' from 'rowSetupAdditionalDataCallback'
                end,
                rowSetupCallback = function(rowControl, data)       -- function that will be called when a control of this type becomes visible (optional)
                    d("LSB: RowSetupCallback")                      -- Calls self:SetupRowEntry, then this function, finally ZO_SortFilterList.SetupRow
                end,
                rowSetupAdditionalDataCallback = function(rowControl, data) -- an optional function to extended data table of the row with additional data during the 'rowSetupCallback' (optional)
                    d("LSB: SetupAdditionalDataCallback")
                    data.tooltipText = data.value
                    return rowControl, data                         -- this callback function must return the rowControl and (enriched) data again
                end,
                rowResetControlCallback = function()                -- an optional callback function when the datatype control gets reset (optional)
                    d("LSB: RowResetControlCallback")
                end,
            },

--======================================================================================================================
            rightList = {               -- list-specific settings that apply to the RIGHT list
                title = "" ,
                ...
                --> See "leftList = {" above -> The entries are the same!
            },

--======================================================================================================================
            --Callbacks that fire as a list is created, filled, cleared, entry is slected, unselected, row mouseOver, row mouseExit, dragDropStart, dragDropEnd, etc. happens
            callbackRegister = {                                    -- directly register callback functions with any of the exposed events
                [LibShifterBox.EVENT_LEFT_LIST_ROW_ON_MOUSE_ENTER] = function(rowControl, shifterBox, data)
                    d("LSB: LeftListRowOnMouseEnter")
                end,
                [LibShifterBox.EVENT_RIGHT_LIST_ROW_ON_MOUSE_ENTER] = function(rowControl, shifterBox, data)
                    d("LSB: RightListRowOnMouseEnter")
                end
                ...
                -> For a complete list of the events please visit the LibShifterBox documentation:
                -> https://github.com/klingo/ESO-LibShifterBox#api-reference  Search for "ShifterBox:RegisterCallback"
            }
        },

--======================================================================================================================
    ----  -^- The custom settings for the dual lists                                                            -^-
--======================================================================================================================
    },
--======================================================================================================================
    -- -^- The dual lists setup data                                                                                -^-
--======================================================================================================================
} ]]

local widgetVersion = 2
local widgetName = "LibAddonMenuDualListBox"
local errorPrefix = "[LibAddonMenu]ERROR"

local LAM = LibAddonMenu2
local LSB = LibShifterBox --will be updated at EVENT_ADD_ON_LOADED again
local entryMovedEventId = LSB.EVENT_ENTRY_MOVED

local util = LAM.util
local getDefaultValue = util.GetDefaultValue

local em = EVENT_MANAGER

local tos = tostring
local strfor = string.format
local zocl = zo_clamp

if not LAM:RegisterWidget("duallistbox", widgetVersion) then return end


local MIN_HEIGHT = 26
local MIN_WIDTH = 50
local MAX_WIDTH = 0


--LibShifterBox dependent variables
local libShifterBoxPossibleEventNames = LSB ~= nil and LSB.allowedEventNames    --will be updated at EVENT_ADD_ON_LOADED again
local libShifterBoxEventNameToId = {}                                           --will be updated at EVENT_ADD_ON_LOADED
local myShifterBoxLocalEventFunctions = {}                                      --The table with the local event callback functions for each eventId. See function assignLocalCallbackFunctionsToEventNames

------------------------------------------------------------------------------------------------------------------------
-- variables for LibShifterBox

--The created LibShifterBoxes
local libShifterBoxes = {
    --[[
    --Example entry
    ["dualListBoxData.setupData.name] = {
        name                = dualListBoxData.setupData.name,
        shifterBoxSetupData = dualListBoxData.setupData,
        lamCustomControl    = <the control of the LAM custom control where the LibShifterBox control will be added to>
        shifterBoxControl   = <the control of the LibShifterBox>
    }
    ]]
}


------------------------------------------------------------------------------------------------------------------------
-- functions for LibShifterBox

local function getBoxName(shifterBox)
    if not shifterBox then return end
    for k, dataTab in pairs(libShifterBoxes) do
        local shifterBoxControl = dataTab.shifterBoxControl
        if shifterBoxControl ~= nil and shifterBoxControl == shifterBox then
            return k
        end
    end
    return nil
end


local function checkAndGetShifterBoxNameAndData(shifterBox)
    if not shifterBox then return nil, nil end
    local boxName = shifterBox.boxName or getBoxName(shifterBox)
    if not boxName or boxName == "" then return nil, nil end
    local shifterBoxData = libShifterBoxes[boxName]
    if not shifterBoxData then return nil, nil end
    return boxName, shifterBoxData
end


local function checkShifterBoxValid(customControl, shifterBoxSetupData, newBox)
    newBox = newBox or false
    if not shifterBoxSetupData then
        d(strfor(errorPrefix.." - Widget %q is missing the subtable setupData for the customControl name: %q", tos(widgetName), tos(customControl:GetName())))
        return false
    end
    local boxName = shifterBoxSetupData.name
    if not customControl or not boxName or boxName == "" then
        d(strfor(errorPrefix.." - Widget %q is missing the setupData subtable for box name: %q", tos(widgetName), tos(boxName)))
        return false
    end
    local boxData = libShifterBoxes[boxName]
    if newBox and boxData ~= nil then
        d(strfor(errorPrefix.." - Widget %q tried to register an already existing box name: %q", tos(widgetName), tos(boxName)))
        return false
    elseif not newBox then
        if boxData == nil then
            d(strfor(errorPrefix.." - Widget %q tried to update an non existing box name: %q", tos(widgetName), tos(boxName)))
            return false
        elseif boxData ~= nil and boxData.shifterBoxControl == nil then
            d(strfor(errorPrefix.." - Widget %q tried to update an non existing LibShifterBox control of box name: %q", tos(widgetName), tos(boxName)))
            return false
        end
    end
    return true
end


------------------------------------------------------------------------------------------------------------------------

--[[
local function checkAndUpdateRightListDefaultEntries(shifterBox, rightListEntries, shifterBoxData)
    if shifterBox and rightListEntries and NonContiguousCount(rightListEntries) == 0 then
        --d("Right list is empty!")
        local defaultRightListKeys = shifterBoxData and shifterBoxData.defaultRightListKeys
        if defaultRightListKeys and #defaultRightListKeys > 0 then
            shifterBox:MoveEntriesToRightList(defaultRightListKeys)
        end
    end
end
]]

local getFuncInProgress            = false
local updateValuesCallFromCreation = false
local function updateLibShifterBoxEntries(customControl, dualListBoxData, shifterBoxControl, isLeftList, newValues, forceReset)
--d("[LAM2 dualListBox widget]updateLibShifterBoxEntries - updateValuesCallFromCreation: " ..tos(updateValuesCallFromCreation) ..", isLeftList: " ..tos(isLeftList) .. ", newValues: " ..tos(newValues).. ", forceReset: " ..tos(forceReset))
    forceReset = forceReset or false
    local shifterBoxSetupData = dualListBoxData.setupData
    if not checkShifterBoxValid(customControl, shifterBoxSetupData, false) then return end

    local boxName = shifterBoxSetupData.name
    local shifterBoxData = libShifterBoxes[boxName]
    shifterBoxSetupData = shifterBoxSetupData or shifterBoxData.shifterBoxSetupData
    if not shifterBoxSetupData then return end

    local refreshControlNow = false
    local noNormalProcessing = false

    shifterBoxControl = shifterBoxControl or shifterBoxData.shifterBoxControl
    if not shifterBoxControl then return end

    --Force defaults?
    local newValuesAreNil = (newValues == nil and true) or false
    local forceDefaults = ((forceReset == true and true)
                            or (((updateValuesCallFromCreation == true and newValuesAreNil == true) or (not updateValuesCallFromCreation and newValuesAreNil == true)) and true))
                            or false
    local leftListEntries, rightListEntries

    --Use default list entries or reset
    if forceDefaults == true and (not getFuncInProgress or (getFuncInProgress and updateValuesCallFromCreation)) then
--d(">forcing to defaults")
        --Copy the values to a new table so we do not update the defaults table by accident
        --with non-default values! Else the next call to setFuncLeftList or setFuncRightList will
        --reference the dfaults tbale to the SV and connect them!
        if dualListBoxData.defaultLeftList ~= nil then
            leftListEntries = getDefaultValue(ZO_ShallowTableCopy(dualListBoxData.defaultLeftList))
--d(">left list defaults loaded")
        end
        if dualListBoxData.defaultRightList ~= nil then
            rightListEntries = getDefaultValue(ZO_ShallowTableCopy(dualListBoxData.defaultRightList))
--d(">right list defaults loaded")
        end

        --Update the lists visually now
        if leftListEntries == nil or rightListEntries == nil then
            return
        end

        --First clear both lists so we do not get any duplicate key error from LibShifterBox
        --because we had moved items from left to right and try to add the same at the left again!
        shifterBoxControl:ClearLeftList()
        shifterBoxControl:ClearRightList()

        shifterBoxControl:AddEntriesToLeftList(leftListEntries)
        dualListBoxData.setFuncLeftList(leftListEntries)
        shifterBoxControl:AddEntriesToRightList(rightListEntries)
        dualListBoxData.setFuncRightList(rightListEntries)
         --Only refresh if defaults are loaded as the control get's created. Else the refresh will be initiated by the
        --LAM panel's ForceDefaults function via cm:FireCallbacks("LAM-RefreshPanel", panel) already
        refreshControlNow = updateValuesCallFromCreation
        noNormalProcessing = true

        --LAM2_DLB = LAM2_DLB or {}
        --LAM2_DLB.leftListDefaults = leftListEntries
        --LAM2_DLB.rightListDefaults = rightListEntries
    end

--d(">forceDefaults: " .. tos(forceDefaults) .. ", getFuncInProgress: " .. tos(getFuncInProgress) .. ", refreshControlNow: " .. tos(refreshControlNow))
    if not noNormalProcessing then
        --Update the lists visually now
        if isLeftList == true then
            leftListEntries = newValues
            if leftListEntries == nil then
                return
            end

            shifterBoxControl:ClearLeftList()
            shifterBoxControl:AddEntriesToLeftList(leftListEntries)
            dualListBoxData.setFuncLeftList(leftListEntries)
            refreshControlNow = true
        else
            rightListEntries = newValues
            if rightListEntries == nil then
                return
            end

            shifterBoxControl:ClearRightList()
            shifterBoxControl:AddEntriesToRightList(rightListEntries)
            dualListBoxData.setFuncRightList(rightListEntries)
            refreshControlNow = true
        end

        --Check for empty right list? fill up with default values again
        --checkAndUpdateRightListDefaultEntries(shifterBoxControl, rightListEntries, shifterBoxData)
    end

    if refreshControlNow and not getFuncInProgress then
        util.RequestRefreshIfNeeded(customControl)
    end
end


local function updateLibShifterBoxEnabledState(customControl, shifterBoxControl, isEnabled)
--d("[LAM2 dualListBox widget]updateLibShifterBoxEnabledState - isEnabled: " ..tos(isEnabled))
    if not customControl then return end
    if not shifterBoxControl then return end

    customControl:SetHidden(false)
    customControl:SetMouseEnabled(isEnabled)
    shifterBoxControl:SetHidden(false)
    shifterBoxControl:SetEnabled(isEnabled)
end


local function UpdateDisabled(control)
    if control.dualListBox ~= nil then
        local disable = getDefaultValue(control.data.disabled)
--d("[LAM2 dualListBox widget]UpdateDisabled - disable: " ..tos(disable))
        updateLibShifterBoxEnabledState(control, control.dualListBox, not disable)
    end
end


local function UpdateValuesAtList(control, isLeftList, newValues, forceReset)
    forceReset = forceReset or false
--d("[LAM2 dualListBox widget]UpdateValuesAtList - isLeftList: " ..tos(isLeftList) .. ", newValues: " ..tos(newValues) .. ", forceReset: " ..tos(forceReset))
    local shifterBoxControl = control.dualListBox
    if not shifterBoxControl then return false end

    local newValuesTable = (newValues ~= nil and getDefaultValue(newValues)) or nil

    --customControl, dualListBoxData, shifterBoxControl, isLeftList, newValues
    updateLibShifterBoxEntries(control, control.data, shifterBoxControl, isLeftList, newValuesTable, forceReset)
end


local function UpdateLeftListValues(control, values)
--d("[LAM2 dualListBox widget]UpdateLeftListValues-values: " ..tos(values))
    UpdateValuesAtList(control, true, values, nil)
end


local function UpdateRightListValues(control, values)
--d("[LAM2 dualListBox widget]UpdateRightListValues-values: " ..tos(values))
    UpdateValuesAtList(control, false, values, nil)
end

local function ForceReset(control)
--d("[LAM2 dualListBox widget]ForceReset")
    UpdateValuesAtList(control, nil, nil, true)
end

--Will be called as the event LibShifterBox.EVENT_ENTRY_MOVED was raised for each moved item
-->Uses the getFunc of left/right list to get the SavedVariables table and update the entries
local function UpdateListEntry(control, shifterBoxData, key, value, categoryId, isToLeftList, fromList, toList)
--d("[LAM2 dualListBox widget]UpdateListEntry - isLeft: " ..tos(isToLeftList) .. ", key: " ..tos(key) .. ", value: " ..tos(value))
    if key ~= nil and value ~= nil then
        local data = control.data
        if isToLeftList == true then
            local valuesRight = data.getFuncRightList()
            --Get current entries at left list
            local valuesLeft = data.getFuncLeftList()
            if valuesLeft ~= nil and valuesRight ~= nil and valuesRight[key] ~= nil then
                --Update left list entry
                --Add the new entry from right list
                valuesLeft[key] = value
                --Remove in right list SV
                valuesRight[key] = nil
            else
                return
            end
--LAM2_DLB = LAM2_DLB or {}
--LAM2_DLB.rightListSV = valuesRight
--LAM2_DLB.leftListSV = valuesLeft
            UpdateValuesAtList(control, true, valuesLeft, nil)
        else
            --Update right list entry
            --Get current entries at right list
            local valuesRight = data.getFuncRightList()
            --Get current entries at left list
            local valuesLeft = data.getFuncLeftList()
            if valuesRight ~= nil and valuesLeft ~= nil and valuesLeft[key] ~= nil then
                --Add the new entry from left list
                valuesRight[key] = value
                --Remove in left list SV
                valuesLeft[key] = nil
            else
                return
            end
--LAM2_DLB = LAM2_DLB or {}
--LAM2_DLB.rightListSV = valuesRight
--LAM2_DLB.leftListSV = valuesLeft
            UpdateValuesAtList(control, false, valuesRight, nil)
        end
    end
end

local function UpdateBothLists(control, forceDefault, values)
--d("[LAM2 dualListBox widget]UpdateBothLists - updateValuesCallFromCreation: " .. tos(updateValuesCallFromCreation) ..", forceDefault: " ..tos(forceDefault) .. ", values: " ..tos(values))
    if forceDefault == true then --if we are forcing defaults
--d(">force to defaults")
        ForceReset(control)
    elseif values ~= nil then --update the values via the setFuncLeftList and setFuncRightList now and refresh the LAM control afterwards
--d(">set to SV")
        UpdateLeftListValues(control, values)
        UpdateRightListValues(control, values)
    else --get the list values from SV via getFuncLeftList and getFuncRightList
--d(">get from SV")
        getFuncInProgress = true --suppres refresh of the customControl via LAM refresh handlers

        local data = control.data
        --Get the values
        --Update the list entries. If the values are empty: Use the defaults on 1st call
        local valuesLeft =  data.getFuncLeftList()
        UpdateLeftListValues(control, valuesLeft)

        local valuesRight = data.getFuncRightList()
        UpdateRightListValues(control, valuesRight)

--LAM2_DLB = LAM2_DLB or {}
--LAM2_DLB.leftListSV = valuesLeft
--LAM2_DLB.rightListSV = valuesRight

        getFuncInProgress = false
    end
end

------------------------------------------------------------------------------------------------------------------------
-- LibShifterBox - Event callback functions
local function defaultEventCallbackWrapperFunc(idxOfShifterBox, customFunc, ...)
    local shifterBox = select(idxOfShifterBox, ...)
    local boxName, shifterBoxData = checkAndGetShifterBoxNameAndData(shifterBox)
    if not boxName or not shifterBoxData then return end
    return customFunc(...)
end


local function assignLocalCallbackFunctionsToEventNames()
    --Set the local event callback function for each event Id, inside table myShifterBoxLocalEventFunctions
    --[[
        --At date: 2022-04-19
        -->LibShifterBox possible event ID = event name constant (e.g. LibShifterBox.EVENT_ENTRY_HIGHLIGHTED
        -->See table LibShifterBox.allowedEventNames
        [1]  = "EVENT_ENTRY_HIGHLIGHTED",
        [2]  = "EVENT_ENTRY_UNHIGHLIGHTED",
        [3]  = "EVENT_ENTRY_MOVED",
        [4]  = "EVENT_LEFT_LIST_CLEARED",
        [5]  = "EVENT_RIGHT_LIST_CLEARED",
        [6]  = "EVENT_LEFT_LIST_ENTRY_ADDED",
        [7]  = "EVENT_RIGHT_LIST_ENTRY_ADDED",
        [8]  = "EVENT_LEFT_LIST_ENTRY_REMOVED",
        [9]  = "EVENT_RIGHT_LIST_ENTRY_REMOVED",
        [10] = "EVENT_LEFT_LIST_CREATED",
        [11] = "EVENT_RIGHT_LIST_CREATED",
        [12] = "EVENT_LEFT_LIST_ROW_ON_MOUSE_ENTER",
        [13] = "EVENT_RIGHT_LIST_ROW_ON_MOUSE_ENTER",
        [14] = "EVENT_LEFT_LIST_ROW_ON_MOUSE_EXIT",
        [15] = "EVENT_RIGHT_LIST_ROW_ON_MOUSE_EXIT",
        [16] = "EVENT_LEFT_LIST_ROW_ON_MOUSE_UP",
        [17] = "EVENT_RIGHT_LIST_ROW_ON_MOUSE_UP",
        [18] = "EVENT_LEFT_LIST_ROW_ON_DRAG_START",
        [19] = "EVENT_RIGHT_LIST_ROW_ON_DRAG_START",
        [20] = "EVENT_LEFT_LIST_ROW_ON_DRAG_END",
        [21] = "EVENT_RIGHT_LIST_ROW_ON_DRAG_END",
    ]]

    --The event_entry_moved function callback will always be registered and added to call control:UpdateListEntry(), and save the changed entry to the SV of left and right lists
    myShifterBoxLocalEventFunctions[widgetName .. "_" .. entryMovedEventId] = function(shifterBox, key, value, categoryId, isToLeftList, fromList, toList)
        local boxName, shifterBoxData = checkAndGetShifterBoxNameAndData(shifterBox)
--d(string.format("[LAM2 dualListBox widget]EVENT_ENTRY_MOVED -  boxName: %q, key: %s, value: %s, categoryId: %s, toLeft: %s", tos(boxName), tos(key),tos(value),tos(categoryId),tos(isToLeftList)))
        if not boxName or not shifterBoxData then return end
        --Call the LAMcustomControl:UpdateListEntry() function to update the savedvariables tables as the entries got moved
        if shifterBoxData.lamCustomControl ~= nil then
            shifterBoxData.lamCustomControl:UpdateListEntry(shifterBoxData, key, value, categoryId, isToLeftList, fromList, toList)
        end
    end

    --Standard event entry moved callback function for other addons
    myShifterBoxLocalEventFunctions[entryMovedEventId] = function(customFunc, ...)
        return defaultEventCallbackWrapperFunc(1, customFunc, ...)
    end


    --All other events:
    myShifterBoxLocalEventFunctions[LSB.EVENT_ENTRY_HIGHLIGHTED] = function(customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_ENTRY_UNHIGHLIGHTED] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_LEFT_LIST_CLEARED] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(1, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_RIGHT_LIST_CLEARED] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(1, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_LEFT_LIST_ENTRY_ADDED] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(1, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_RIGHT_LIST_ENTRY_ADDED] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(1, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_LEFT_LIST_ENTRY_REMOVED] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(1, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_RIGHT_LIST_ENTRY_REMOVED] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(1, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_LEFT_LIST_CREATED] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_RIGHT_LIST_CREATED] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_LEFT_LIST_ROW_ON_MOUSE_ENTER] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_RIGHT_LIST_ROW_ON_MOUSE_ENTER] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_LEFT_LIST_ROW_ON_MOUSE_EXIT] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_RIGHT_LIST_ROW_ON_MOUSE_EXIT] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_LEFT_LIST_ROW_ON_MOUSE_UP] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_RIGHT_LIST_ROW_ON_MOUSE_UP] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_LEFT_LIST_ROW_ON_DRAG_START] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_RIGHT_LIST_ROW_ON_DRAG_START] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_LEFT_LIST_ROW_ON_DRAG_END] = function (customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end

    myShifterBoxLocalEventFunctions[LSB.EVENT_RIGHT_LIST_ROW_ON_DRAG_END] = function(customFunc, ...)
        return defaultEventCallbackWrapperFunc(2, customFunc, ...)
    end
end


local function updateLibShifterBoxEventCallbacks(customControl, dualListBoxData, shifterBoxControl, alreadyChecked)
    alreadyChecked = alreadyChecked or false
    local shifterBoxSetupData = dualListBoxData.setupData
    if alreadyChecked == false and not checkShifterBoxValid(customControl, shifterBoxSetupData, false) then return end

    shifterBoxControl.LAMduallistBox_EventCallbacks = {}
    local LAMduallistBox_EventCallbacks = shifterBoxControl.LAMduallistBox_EventCallbacks

    --Always register the EVENT_ENTRY_MOVED with the internal callback function
    local callbackFuncForEVENT_ENTRY_MOVED = myShifterBoxLocalEventFunctions[widgetName .. "_" .. entryMovedEventId]
    if callbackFuncForEVENT_ENTRY_MOVED ~= nil then
        shifterBoxControl:RegisterCallback(entryMovedEventId, callbackFuncForEVENT_ENTRY_MOVED)
        --Better readability at the control
        LAMduallistBox_EventCallbacks[entryMovedEventId] = {
            eventId =   entryMovedEventId,
            eventName = libShifterBoxPossibleEventNames[entryMovedEventId],
            callback =  callbackFuncForEVENT_ENTRY_MOVED
        }
    end

    --All other events as per shifterBoxSetupData.customSettings.callbackRegister table
    --Add the callback functions, if provided
    local customSettings = shifterBoxSetupData.customSettings
    if not customSettings then return end

    local callbackRegister = customSettings.callbackRegister
    if callbackRegister ~= nil then

        --Dynamic
        --Enable the callback functions if they are added to the customSettings of the LibShifterBox
        for eventId, eventName in ipairs(libShifterBoxPossibleEventNames) do
            local callbackFuncForEventId = callbackRegister[eventId]
            if callbackFuncForEventId ~= nil and type(callbackFuncForEventId) == "function" then
                if eventId ~= entryMovedEventId then
                    local callbackFuncForEventName = myShifterBoxLocalEventFunctions[eventId]
                    if callbackFuncForEventName ~= nil then
                        local callbackFuncToUse = function(...) callbackFuncForEventName(callbackFuncForEventId, ...) end
                        shifterBoxControl:RegisterCallback(
                                eventId,
                                callbackFuncToUse
                        )
                        --Better readability at the control
                        LAMduallistBox_EventCallbacks[eventId] = {
                            eventId =   eventId,
                            eventName = eventName,
                            callback =  callbackFuncToUse
                        }
                    end
                else
                    --EVENT_ENTRY_MOVED already was registered by default to update the SavedVariables properly!
                    --If another custom same callback is provided by we need to
                    --PostHook our default callback function with that new callback function
                    if callbackFuncForEVENT_ENTRY_MOVED ~= nil then
                        local newEventEntryMovedCallbackFunc = myShifterBoxLocalEventFunctions[entryMovedEventId]
                        if newEventEntryMovedCallbackFunc ~= nil then
                            local origEventEntryMovedCallbackFunc = callbackFuncForEVENT_ENTRY_MOVED
                            callbackFuncForEVENT_ENTRY_MOVED = function(...)
                                local retValueOrigEventEntryMovedCallback = origEventEntryMovedCallbackFunc(...)
                                if retValueOrigEventEntryMovedCallback == nil then retValueOrigEventEntryMovedCallback = true end
                                local retValueCustomEventEntryMovedCallback = newEventEntryMovedCallbackFunc(callbackFuncForEventId, ...)
                                if retValueCustomEventEntryMovedCallback == nil then retValueCustomEventEntryMovedCallback = true end
                                return retValueOrigEventEntryMovedCallback and retValueCustomEventEntryMovedCallback
                            end
                            --Better readability at the control
                            LAMduallistBox_EventCallbacks[entryMovedEventId] = {
                                eventId =   entryMovedEventId,
                                eventName = eventName,
                                callback =  callbackFuncForEVENT_ENTRY_MOVED
                            }
                        end
                    else
                        --[[ TODO Was added in version 2 - Is this valid code?
                        --No entry moved callback registered, register a new one
                        local callbackFuncForEventName = myShifterBoxLocalEventFunctions[entryMovedEventId]
                        if callbackFuncForEventName ~= nil then
                            local callbackFuncToUse = function(...) callbackFuncForEventName(callbackFuncForEventId, ...) end
                            shifterBoxControl:RegisterCallback(
                                    entryMovedEventId,
                                    callbackFuncToUse
                            )
                            --Better readability at the control
                            LAMduallistBox_EventCallbacks[entryMovedEventId] = {
                                eventId =   entryMovedEventId,
                                eventName = eventName,
                                callback =  callbackFuncToUse
                            }
                        end
                        ]]
                    end
                end
            end
        end
    end
end


------------------------------------------------------------------------------------------------------------------------

local function updateLibShifterBoxState(customControl, dualListBoxData, shifterBoxControl, alreadyChecked)
    alreadyChecked = alreadyChecked or false
    local shifterBoxSetupData = dualListBoxData.setupData
    if alreadyChecked == false and not checkShifterBoxValid(customControl, shifterBoxSetupData, false) then return end

    local boxName = shifterBoxSetupData.name
    local shifterBoxData = libShifterBoxes[boxName]
    shifterBoxSetupData = shifterBoxSetupData or shifterBoxData.shifterBoxSetupData
    if not shifterBoxSetupData then return end
    shifterBoxControl = shifterBoxControl or shifterBoxData.shifterBoxControl
    if not shifterBoxControl then return end

    local isEnabled = shifterBoxSetupData.enabled ~= nil and getDefaultValue(shifterBoxSetupData.enabled)
    if isEnabled == nil then isEnabled = true end

    updateLibShifterBoxEnabledState(customControl, shifterBoxControl, isEnabled)
end


local function updateLibShifterBox(customControl, dualListBoxData, shifterBoxControl)
    local shifterBoxSetupData = dualListBoxData.setupData
    if not checkShifterBoxValid(customControl, shifterBoxSetupData, false) then return end

    local boxName = shifterBoxSetupData.name
    local shifterBoxData = libShifterBoxes[boxName]
    shifterBoxSetupData = shifterBoxSetupData or shifterBoxData.shifterBoxSetupData
    if not shifterBoxSetupData then return end
    shifterBoxControl = shifterBoxControl or shifterBoxData.shifterBoxControl
    if not shifterBoxControl then return end

    --Tell the custom control to auto-resize dependent on the dual list boxes size
    customControl:SetResizeToFitDescendents(true)
    --Re-Anchor to the custom control
    shifterBoxControl:SetAnchor(TOPLEFT, customControl, TOPLEFT, 0, 0) -- will automatically call ClearAnchors
    --Change the dimensions
    local width = shifterBoxSetupData.width ~= nil and getDefaultValue(shifterBoxSetupData.width)
    local newWidth = zocl(width, MIN_WIDTH, MAX_WIDTH - 1)

    local height =    (shifterBoxSetupData.height ~= nil    and getDefaultValue(shifterBoxSetupData.height)) or MIN_HEIGHT
    local minHeight = (dualListBoxData.minHeight ~= nil and getDefaultValue(dualListBoxData.minHeight)) or MIN_HEIGHT
    local maxHeight = (dualListBoxData.maxHeight ~= nil and getDefaultValue(dualListBoxData.maxHeight)) or (minHeight * 4)
    local newHeight = zocl(height, minHeight, maxHeight)
    shifterBoxControl:SetDimensions(newWidth, newHeight)


    --Add the entries to the left and right shifter boxes
    -->Currently not needed. Use shifterBoxSetupData.leftListDefaultKeys and shifterBoxSetupData.rightListDefaultKeys
    --updateLibShifterBoxEntries(customControl, shifterBoxSetupData, shifterBoxControl)

    --Upate the EVENT callback functions of the shifter box
    updateLibShifterBoxEventCallbacks(customControl, dualListBoxData, shifterBoxControl, true)

    --Update the enabled state of the shifter box
    --updateLibShifterBoxState(customControl, dualListBoxData, shifterBoxControl, true)
end

------------------------------------------------------------------------------------------------------------------------

--Create a LibShifterBox for e.g. LAM settings panel
local function createLibShifterBox(customControl, dualListBoxData)
    local shifterBoxSetupData = dualListBoxData.setupData
    if not checkShifterBoxValid(customControl, shifterBoxSetupData, true) then return end

    --Create the new LibShifterBox now
    local boxName = shifterBoxSetupData.name

    --LSB(... = LSB:New( ... via metatables
    -- @param uniqueAddonName - the unique name of your addon
    -- @param uniqueShifterBoxName - the unique name of this shifterBox (within your addon)
    -- @param parentControl - the control reference to which the shifterBox should be added as a child
    -- @param customSettings - OPTIONAL: override the default settings
    -- @param dimensionOptions - OPTIONAL: directly provide dimensionOptions instead of calling :SetDimensions afterwards (must be table with: number width, number height)
    -- @param anchorOptions - OPTIONAL: directly provide anchorOptions instead of calling :SetAnchor afterwards (must be table with: number whereOnMe, object anchorTargetControl, number whereOnTarget, number offsetX, number offsetY)
    -- @param leftListEntries - OPTIONAL: directly provide entries for left listBox (a table or a function returning a table)
    -- @param rightListEntries - OPTIONAL: directly provide entries for right listBox (a table or a function returning a table)
    --LibShifterBox:New(uniqueAddonName, uniqueShifterBoxName, parentControl, customSettings, anchorOptions, dimensionOptions, leftListEntries, rightListEntries)
    local shifterBox = LSB(widgetName,                  --uniqueAddonName
            boxName,                                    --uniqueShifterBoxName
            customControl,                              --parentControl
            shifterBoxSetupData.customSettings,         --customSettings
            nil,                                        --dimensionOptions
            nil,                                        --anchorOptions
            nil, --shifterBoxSetupData.defaultLeftList -> updated via control:UpdateValue(),        --leftListEntries
            nil  --shifterBoxSetupData.defaultRightList -> updated via control:UpdateValue(),       --rightListEntries
    )
    if shifterBox ~= nil then
        shifterBox.boxName = boxName

        libShifterBoxes[boxName] = {}
        libShifterBoxes[boxName].name =                 boxName
        libShifterBoxes[boxName].dualListBoxData =      dualListBoxData
        libShifterBoxes[boxName].shifterBoxSetupData =  shifterBoxSetupData
        libShifterBoxes[boxName].lamCustomControl =     customControl
        libShifterBoxes[boxName].shifterBoxControl =    shifterBox

        --Update the shifter box position, entries, state
        updateLibShifterBox(customControl, dualListBoxData, shifterBox)

        return shifterBox
    else
        d(strfor(errorPrefix.." - Widget %q was unable to create the LibShifterBox control for box name: %q", tos(widgetName), tos(boxName)))
        return
    end
end


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function getLeftListEntriesFull(customControl)
    if not customControl then return end
    local shifterBox = customControl.dualListBoxData
    if not shifterBox then return end
    return shifterBox:GetLeftListEntriesFull()
end


local function getRightListEntriesFull(customControl)
    if not customControl then return end
    local shifterBox = customControl.dualListBoxData
    if not shifterBox then return end
    return shifterBox:GetRightListEntriesFull()
end



------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local function createFunc(parent, customControl, dualListBoxData)
    --Create the LibShifterBox boxes with the provided leftList and rightList setup data
    local shifterBoxSetupData = dualListBoxData.setupData
    if not shifterBoxSetupData then
        d(strfor(errorPrefix.." - Widget %q is missing the setupData subtable for box custom control: %q", tos(widgetName), tos(customControl:GetName())))
        return
    end
    return createLibShifterBox(customControl, dualListBoxData)
end


function LAMCreateControl.duallistbox(parent, dualListBoxData, controlName)
    if dualListBoxData.setupData == nil then return end
    dualListBoxData.disabled = dualListBoxData.disabled or false

    local control = util.CreateBaseControl(parent, dualListBoxData, controlName)
    local width = control:GetWidth()
    control:SetResizeToFitDescendents(true)

    local data = control.data
    local minHeight = (data.minHeight and getDefaultValue(data.minHeight)) or MIN_HEIGHT
    local maxHeight = (data.maxHeight and getDefaultValue(data.maxHeight)) or (minHeight * 4)

    if control.isHalfWidth then --note these restrictions
        control:SetDimensionConstraints(width / 2, minHeight, width / 2, maxHeight)
    else
        control:SetDimensionConstraints(width, minHeight, width, maxHeight)
    end
    MAX_WIDTH = control:GetWidth()

    --Create the LibShifterBox dual list boxes (left and right)
    local dualListBoxControl = createFunc(parent, control, dualListBoxData)
    if dualListBoxControl == nil then
        d(strfor(errorPrefix.." - Widget %q did not create the dual list boxes for control %q", tos(widgetName), tos(control:GetName())))
        return
    end
    control.dualListBox = dualListBoxControl
    control.dualListBox.dualListBoxData = dualListBoxData

    --Get functions, w/o updating the SavedVariables (w/o calling the getFuncLeftList or getFuncRightList)
    control.GetLeftListEntries =    getLeftListEntriesFull
    control.GetRightListEntries =   getRightListEntriesFull

    --Set functions with updating the SavedVariables (w/ calling the setFuncLeftList AND setFuncRightList
    ---> Called from duallistbox widget create function e.g., see 3 rows below control:UpdateValue())
    control.UpdateValue = UpdateBothLists
    control.UpdateListEntry = UpdateListEntry --Update a single entry at a specified list

    --Add the reset function (to set default values) to the widget data table
    local resetFunc = dualListBoxData.resetFunc
    if resetFunc == nil or resetFunc ~= nil and type(resetFunc) ~= "function" then
        dualListBoxData.resetFunc = function()
            UpdateBothLists(control, true, nil)
        end
    end

    --Use the getFuncs to set the values from the SavedVariables of the addon now
    -->Set variable updateValuesCallFromCreation to true to prevent a "set to defaults values"!
    updateValuesCallFromCreation = true
    control:UpdateValue() --will call UpdateBothLists() to init the variables in both lists, either from SV or from defaultLeftList/defaultRightList attributes of data
    updateValuesCallFromCreation = false

    --Left list/right list entries handling
    control.UpdateLeftListValues =  UpdateLeftListValues
    control.UpdateRightListValues = UpdateRightListValues

    --Disabled state handling
    control.UpdateDisabled =        UpdateDisabled
    control:UpdateDisabled()

    util.RegisterForRefreshIfNeeded(control)

    return control --the LAM custom control containing the .dualListBox subTable/control
end


--Load the widget into LAM
local eventAddOnLoadedForWidgetName = widgetName .. "_EVENT_ADD_ON_LOADED"
local function registerWidget(_, addonName)
    if addonName ~= widgetName then return end
    em:UnregisterForEvent(eventAddOnLoadedForWidgetName, EVENT_ADD_ON_LOADED)

    --LibShifterBox
    LSB = LibShifterBox
    if not LSB then return end

    --Update the LibShifterBox EVENT_* callback names which are possible with their ID number (lookup table)
    libShifterBoxPossibleEventNames = LSB.allowedEventNames
    for eventId, eventName in ipairs(libShifterBoxPossibleEventNames) do
        libShifterBoxEventNameToId[eventName] = eventId
    end
    --Assign the local callback functions to the eventNames, inside table myShifterBoxLocalEventFunctions
    assignLocalCallbackFunctionsToEventNames()

    if not LAM:RegisterWidget("duallistbox", widgetVersion) then return end
end
em:RegisterForEvent(eventAddOnLoadedForWidgetName, EVENT_ADD_ON_LOADED, registerWidget)
