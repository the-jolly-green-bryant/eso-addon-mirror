local LIB_IDENTIFIER = "LibShifterBox"

--local globals
local CM = CALLBACK_MANAGER
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

local tos = tostring
local tcon = table.concat
local tins = table.insert
local tsort = table.sort
local strfor = string.format
local zostrlow = zo_strlower


--Error text output
local function _errorText(textTemplate, ...)
    local errorTextStr = LIB_IDENTIFIER .. "_Error: "
    if ... ~= nil then
        errorTextStr =  errorTextStr .. strfor(textTemplate, ...)
    else
        errorTextStr = errorTextStr .. textTemplate
    end
    return errorTextStr
end
assert(not _G[LIB_IDENTIFIER], _errorText(GetString(LIBSHIFTERBOX_ALLREADY_LOADED)))

--Global Library variable
local lib = {}
lib.name = LIB_IDENTIFIER
lib.version = "0.7.0"

lib.doDebug = false

------------------------------------------------------------------------------------------------------------------------
--Global variable LibShifterBox
_G[LIB_IDENTIFIER] = lib
------------------------------------------------------------------------------------------------------------------------


-- =================================================================================================================
-- == LIBRARY CONSTANTS/VARIABLES == --
-- -----------------------------------------------------------------------------------------------------------------
local LIST_SPACING = 40
local ARROW_SIZE = 36
local HEADER_HEIGHT = 32
local DATA_TYPE_DEFAULT = 1
local DATA_DEFAULT_CATEGORY = "LSBDefCat"
local SCROLLBAR_WIDTH = ZO_SCROLL_BAR_WIDTH
local RESELECTING_DURING_REBUILD = true
local ANIMATION_FIELD_NAME = "SelectionAnimation"
local FONT_STYLE = "MEDIUM_FONT"
local FONT_WEIGHT = "soft-shadow-thin"

local CURSORTLC
local CURSOR_TLC_NAME = LIB_IDENTIFIER .. "_Cursor_TLC"
local EVENT_HANDLER_NAMESPACE = LIB_IDENTIFIER  .. "_Event"
local GLOBAL_MOUSE_DOWN = "_GLOBAL_MOUSE_DOWN"
local GLOBAL_MOUSE_UP   = "_GLOBAL_MOUSE_UP"
local multipleRowsDraggedText = GetString(LIBSHIFTERBOX_DRAG_MULTIPLE)

--Mouse cursors
local MOUSECURSOR_UIHAND     = MOUSE_CURSOR_UI_HAND
local MOUSECURSOR_DONOTCATRE = MOUSE_CURSOR_DO_NOT_CARE
--local MOUSECURSOR_RESIZEEW   = MOUSE_CURSOR_RESIZE_EW
local MOUSECURSOR_NEXTLEFT  = MOUSE_CURSOR_NEXT_LEFT
local MOUSECURSOR_NEXTRIGHT = MOUSE_CURSOR_NEXT_RIGHT

--Textures
local searchTexture = " |t40:40:/esoui/art/tutorial/gamepad/gp_inventory_trait_not_researched_icon.dds|t"

--Validation types (special ones) for customSettings
local specialTypeTexts = {
    ["number+"]     = true,
    ["number-"]     = true,
    ["stringValue"] = true,
    ["sound"]       = true,
}
local validationTypeToFunc = {} --will be filled at EVENT_ADD_ON_LOADED

--The possible customSettings entries and their validation type
-->Each non-function validationtype coudl be a function -> which returns the actual value then.
-->function's signature: validationFunc(keyToCheck, customSettingsTable)
-->It will always pass in the customSettingsTable in total as 2nd param: You can provide additional values in that table to do further checks in your validation function
local possibleCustomSettings = {
    ["head"] = {
        { name = "showMoveAllButtons",              validationType = "boolean" },
        { name = "dragDropEnabled",                 validationType = "boolean" },
        { name = "sortEnabled",                     validationType = "boolean" },
        { name = "sortBy",                          validationType = "stringValueKey" },
        { name = "search",                          validationType = "table" },

   },
   ["leftList"] = {
        { name = "title",                           validationType = "string" },
        { name = "rowTemplateName",                 validationType = "string" },
        { name = "emptyListText",                   validationType = "string" },
        { name = "fontName",                        validationType = "string" },
        { name = "rowHeight",                       validationType = "positiveNumber" },
        { name = "fontSize",                        validationType = "positiveNumber" },
        { name = "rowOnMouseEnter",                 validationType = "function" },
        { name = "rowOnMouseExit",                  validationType = "function" },
        { name = "rowOnMouseRightClick",            validationType = "function" },
        { name = "rowSetupCallback",                validationType = "function" },
        { name = "rowDataTypeSelectSound",          validationType = "sound" },
        { name = "rowResetControlCallback",         validationType = "function" },
        { name = "rowSetupAdditionalDataCallback",  validationType = "function" },
        { name = "callbackRegister",                validationType = "table" },
   },
}
possibleCustomSettings["rightList"] = ZO_ShallowTableCopy(possibleCustomSettings["leftList"]) --Same custom settings for the rightList as available for the leftList

--Shifter box events for the callbacks
local shifterBoxEvents = {
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
}
lib.allowedEventNames = shifterBoxEvents
local allowedShifterBoxEvents = {}
for value, eventName in ipairs(shifterBoxEvents) do
    lib[eventName] = value
    allowedShifterBoxEvents[value] = true
end

local existingShifterBoxes = {}
lib.existingShifterBoxes = existingShifterBoxes --todo: Removed after debugging

local defaultListSettings = {
    title = "",
    rowHeight = 32,
    rowTemplateName = "ShifterBoxEntryTemplate",
    emptyListText = GetString(LIBSHIFTERBOX_EMPTY),
    fontSize = 18,
}

local defaultSettings = {
    showMoveAllButtons = true,
    dragDropEnabled = true,
    sortEnabled = true,
    sortBy = "value",
    leftList = defaultListSettings,
    rightList = defaultListSettings,
    search = {
        enabled = false,
        --searchFunc = function(shifterBox, entry, searchStr) return string.find(.......)  end
    },
}

-- KNOWN ISSUES
-- TODO: Calling UnselectAllEntries() when mouse-over causes text to become white

-- =================================================================================================================
-- == SHIFTERBOX PRIVATE FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
local function _getDeepClonedTable(sourceTable)
    if sourceTable == nil then return end
    local targetTable = {}
    ZO_DeepTableCopy(sourceTable, targetTable)
    return targetTable
end

local function _getShallowClonedTable(sourceTable)
    if sourceTable == nil then return end
    local targetTable = {}
    ZO_ShallowTableCopy(sourceTable, targetTable)
    return targetTable
end

--Run function arg to get the return value (passing in ... as optional params to that function),
--or directly use non-function return value arg
local function getValueOrCallback(arg, ...)
	if type(arg) == "function" then
		return arg(...)
	else
		return arg
	end
end

-- ---------------------------------------------------------------------------------------------------------------------

local function _getUniqueShifterBoxEventName(shifterBox, eventId)
    if shifterBox == nil then return nil end
    return tcon({LIB_IDENTIFIER, "_", shifterBox.addonName, "_", shifterBox.shifterBoxName, "_", eventId})
end

local function _fireCallback(shifterBox, controlForCallback, eventId, ...)
    local callbackIdentifier = _getUniqueShifterBoxEventName(shifterBox, eventId)
    controlForCallback = controlForCallback or shifterBox
    CM:FireCallbacks(callbackIdentifier, controlForCallback, ...)
end

local function _refreshFilter(list, checkForClearTrigger)
    list:RefreshFilters()
    if checkForClearTrigger and next(list.list.data) == nil then
        _fireCallback(list.shifterBox, nil, (list.isLeftList and lib.EVENT_LEFT_LIST_CLEARED) or lib.EVENT_RIGHT_LIST_CLEARED
                )
    end
end

local function _refreshFilters(list, anotherList, checkForClearTrigger)
    if list then _refreshFilter(list, checkForClearTrigger) end
    if anotherList then _refreshFilter(anotherList, checkForClearTrigger) end
end

local function defaultSearchFunc(shifterBox, entry, searchStr)
    local name = entry.value or entry.key
	return zostrlow(name):find(searchStr) ~= nil
end

-- validation function for custom settings
local function _validateType(customSettingsTbl, parameterName, settingsTbl, typeText)
    local customValue = customSettingsTbl[parameterName]
    if customValue ~= nil then
        --Resolve callbackFunctions used to return an actual value
        customValue = getValueOrCallback(customValue, customSettingsTbl)

        local isSpecialTypeText = specialTypeTexts[typeText] or false
        local assertionBool = (not isSpecialTypeText and type(customValue) == typeText) or false
        if typeText == "number+" then
            assertionBool = customValue > 0
            typeText = typeText .. " and positive"
        elseif typeText == "number-" then
            assertionBool = customValue < 0
            typeText = typeText .. " and negative"
        elseif typeText == "stringValue" then
            assertionBool = (type(customValue) == "string" and (customValue == "value" or customValue == "key")) or false
            typeText = "either \'value\' or \'key\'"
        elseif typeText == "sound" then
            local sounds = SOUNDS
            assertionBool = (type(customValue) == "string" and sounds[customValue] ~= nil) or false
            typeText = "String and existing in global SOUNDS table"
        end
        assert(assertionBool == true, _errorText("Invalid %s parameter '%s' provided! Must be " .. tos(typeText), parameterName, tos(customValue)))
        settingsTbl[parameterName] = customValue
    end
end

local function _assertValidShifterBoxEvent(shifterBoxEvent)
    assert(allowedShifterBoxEvents[shifterBoxEvent] == true,
            _errorText("Invalid shifterBoxEvent parameter provided! Must be one of table \'LibShifterBox.allowedEventNames\'!")
    )
end

local function _assertKeyIsNotInTable(key, value, self, sideControl)
    local masterList = self.masterList
    assert(masterList[key] == nil, _errorText("Violation of UNIQUE KEY. Cannot insert duplicate key '%s' with value '%s' in control '%s'. The statement has been terminated.", tos(key), tos(value), sideControl:GetName()))
end

local function _assertPositiveNumber(customSettingsTbl, parameterName, settingsTbl)
    _validateType(customSettingsTbl, parameterName, settingsTbl, "number+")
end
local function _assertBoolean(customSettingsTbl, parameterName, settingsTbl)
    _validateType(customSettingsTbl, parameterName, settingsTbl, "boolean")
end
local function _assertString(customSettingsTbl, parameterName, settingsTbl)
    _validateType(customSettingsTbl, parameterName, settingsTbl, "string")
end
local function _assertStringValueKey(customSettingsTbl, parameterName, settingsTbl)
    _validateType(customSettingsTbl, parameterName, settingsTbl, "stringValue")
end
local function _assertFunction(customSettingsTbl, parameterName, settingsTbl)
    _validateType(customSettingsTbl, parameterName, settingsTbl, "function")
end
local function _assertSound(customSettingsTbl, parameterName, settingsTbl)
    _validateType(customSettingsTbl, parameterName, settingsTbl, "sound")
end
local function _assertTable(customSettingsTbl, parameterName, settingsTbl)
    _validateType(customSettingsTbl, parameterName, settingsTbl, "table")
end

local function _moveEntryFromTo(fromList, toList, moveKey, shifterBox)
    local retVar = false
    local key, value, categoryId = fromList:RemoveEntry(moveKey)
    if key ~= nil then
        toList:AddEntry(key, value, categoryId)
        retVar = true
        -- then trigger the callback if present
        _fireCallback(shifterBox, nil, lib.EVENT_ENTRY_MOVED,
                key, value, categoryId, toList.isLeftList, fromList, toList)
    end
    return retVar
end

--Search header
local function _onSearchHeaderEditBoxReturnKey(shifterBox, listObj, editBoxCtrl)
    if shifterBox == nil or listObj == nil or editBoxCtrl == nil then return end
    if listObj.searchStr == nil then return end
    _refreshFilters(listObj, nil, false)
end

local function _onSearchHeaderEditBoxTextChanged(shifterBox, listObj, editBoxCtrl, textData)
    if shifterBox == nil or listObj == nil or editBoxCtrl == nil then return end
    local searchStr = editBoxCtrl:GetText()
    listObj.searchStr = searchStr
end

local function _toggleSearchHeaderUI(shifterBox, listObj, searchButtonCtrl)
    local currentState = listObj.isSearchHeaderUIShown
    local newState = not currentState
    --Hide/Unhide the search backdrop with the editbox
    local searchHeaderUIControl = listObj.searchHeaderUI
    searchHeaderUIControl:SetHidden(not newState)

    --Hide/Unhide the sort headers
    local sortHeaderGroup = listObj.sortHeaderGroup
    sortHeaderGroup.headerContainer:GetNamedChild("Arrow"):SetHidden(newState)
    sortHeaderGroup.headerContainer:GetNamedChild("Value"):SetHidden(newState)

    listObj.isSearchHeaderUIShown = newState
    if newState == true then
        listObj.searchHeaderUIEditBox:TakeFocus()
        listObj.searchHeaderUIEditBox:SelectAll()
    end

    --Is the textBox still containing text then remove it and update the list
    -->But that prevents us to use the sort header on the results!
    --[[
    local currentFilterText = listObj.searchHeaderUIEditBox:GetText()
    if currentFilterText ~= nil and currentFilterText ~= "" then
        listObj.searchHeaderUIEditBox:SetText("")
        _onSearchHeaderEditBoxReturnKey(shifterBox, listObj, listObj.searchHeaderUIEditBox)
    end
    ]]
end

local function _onSearchHeaderButtonClicked(shifterBox, listObj, buttonCtrl)
    if shifterBox == nil or listObj == nil or buttonCtrl == nil then return end
    listObj.searchStr = nil

    _toggleSearchHeaderUI(shifterBox, listObj, buttonCtrl)
end


local function _createShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl)
    local shifterBoxName = tcon({uniqueAddonName, "_", uniqueShifterBoxName})
    return CreateControlFromVirtual(shifterBoxName, parentControl, "ShifterBoxTemplate")
end

local function _applyCustomSettings(obj, customSettings)
    if lib.doDebug then
        LSB_Debug = LSB_Debug or {}
        LSB_Debug[obj.shifterBoxName] = LSB_Debug[obj.shifterBoxName] or {}
        LSB_Debug[obj.shifterBoxName].addonName = obj.addonName
        LSB_Debug[obj.shifterBoxName].shifterBoxName = obj.shifterBoxName
        LSB_Debug[obj.shifterBoxName].customSettings = ZO_ShallowTableCopy(customSettings)
    end

    -- if no custom settings provided, use the default ones
    local defSettingsForCustomSettings = _getDeepClonedTable(defaultSettings)
    if not ZO_IsTableEmpty(customSettings) then
        for customSettingsSection, customSettingsSectionData in pairs(possibleCustomSettings) do
            for _, validationData in ipairs(customSettingsSectionData) do
                if validationData.validationType ~= nil then
                    local validationFunc = validationTypeToFunc[validationData.validationType]
                    if type(validationFunc) == "function" then
                        if lib.doDebug then d(">validating ShifterBox section '" .. tos(customSettingsSection) .. "' setting: " ..tos(validationData.name)) end
                        if customSettingsSection == "head" then
                            -- validate the individual custom settings
                            validationFunc(customSettings, validationData.name, defSettingsForCustomSettings)
                        else
                            if customSettingsSection == "leftList" then
                                -- validate leftList settings
                                validationFunc(customSettings.leftList, validationData.name, defSettingsForCustomSettings.leftList)

                            elseif customSettingsSection == "rightList" then
                                -- validate rightList settings
                                validationFunc(customSettings.rightList, validationData.name, defSettingsForCustomSettings.rightList)
                            end
                        end
                    end
                end
            end
        end
    end
    defSettingsForCustomSettings.search.searchFunc = defSettingsForCustomSettings.search.searchFunc or defaultSearchFunc

    return defSettingsForCustomSettings
end

local function _initShifterBoxControls(obj)
    local control = obj.shifterBoxControl
    local shifterBoxSettings = obj.shifterBoxSettings
    local leftControl = control:GetNamedChild("Left")
    local rightControl = control:GetNamedChild("Right")
    local fromLeftButtonControl = leftControl:GetNamedChild("Button")
    local fromRightButtonControl = rightControl:GetNamedChild("Button")
    local rightListControl = rightControl:GetNamedChild("List")
    local leftListControl = leftControl:GetNamedChild("List")

    if lib.doDebug then
        LSB_Debug = LSB_Debug or {}
        LSB_Debug[obj.shifterBoxName] = LSB_Debug[obj.shifterBoxName] or {}
        LSB_Debug[obj.shifterBoxName].addonName = obj.addonName
        LSB_Debug[obj.shifterBoxName].shifterBoxName = obj.shifterBoxName
        LSB_Debug[obj.shifterBoxName].shifterBoxSettings = ZO_ShallowTableCopy(shifterBoxSettings)
    end

    local function initListFrames(parentListControl)
        local listFrameControl = parentListControl:GetNamedChild("Frame")
        listFrameControl:SetCenterColor(0, 0, 0, 1)
        listFrameControl:SetEdgeTexture(nil, 1, 1, 1)
    end

    local function initHeaders(objVar, leftListTitle, rightListTitle)
        if lib.doDebug then d("[LSB]initHeaders-addonName: " .. tos(objVar.addonName) .. ", boxName: "..tos(objVar.shifterBoxName) ..", leftListTitle: " ..tos(leftListTitle) .. ", rightListTitle: " .. tos(rightListTitle)) end
        if leftListTitle ~= nil or rightListTitle ~= nil then
            objVar.headerHeight = HEADER_HEIGHT
            -- show the headers (default = hidden)
            local leftHeaders = leftControl:GetNamedChild("Headers")
            local leftHeadersTitle = leftHeaders:GetNamedChild("Value"):GetNamedChild("Name")
            leftHeaders:SetHeight(objVar.headerHeight)
            leftHeaders:SetHidden(false)
            leftHeadersTitle:SetText(leftListTitle or "")

            local rightHeaders = rightControl:GetNamedChild("Headers")
            local rightHeadersTitle = rightHeaders:GetNamedChild("Value"):GetNamedChild("Name")
            rightHeaders:SetHeight(objVar.headerHeight)
            rightHeaders:SetHidden(false)
            rightHeadersTitle:SetText(rightListTitle or "")
        else
            objVar.headerHeight = 0
        end
    end

    -- initialise the headers
    local leftListSettings = shifterBoxSettings.leftList
    local rightListSettings = shifterBoxSettings.rightList
    initHeaders(obj, leftListSettings.title, rightListSettings.title)

    -- initialize the frame/border around the listBoxes
    initListFrames(leftListControl)
    initListFrames(rightListControl)

    -- initialize the buttons in disabled state
    fromLeftButtonControl:SetState(BSTATE_DISABLED, true)
    fromRightButtonControl:SetState(BSTATE_DISABLED, true)
end

local function _initShifterBoxHandlers(obj)
    local control = obj.shifterBoxControl

    local leftControl = control:GetNamedChild("Left")
    local fromLeftButtonControl = leftControl:GetNamedChild("Button")
    local fromLeftAllButtonControl = leftControl:GetNamedChild("AllButton")
    local rightControl = control:GetNamedChild("Right")
    local fromRightButtonControl = rightControl:GetNamedChild("Button")
    local fromRightAllButtonControl = rightControl:GetNamedChild("AllButton")

    local function toLeftButtonClicked(buttonControl)
        local leftList = obj.leftList
        local rightList = obj.rightList
        local rightListSelectedData = _getShallowClonedTable(rightList.list.selectedMultiData)
        local retVarLoop = false
        local retVar = true
        for key, data in pairs(rightListSelectedData) do
            retVarLoop = _moveEntryFromTo(rightList, leftList, data.key, obj)
            if not retVarLoop then
                retVar = false
            end
        end
        -- then commit the changes to the scrollList and refresh the hidden states
        _refreshFilter(leftList)
        _refreshFilter(rightList, true)
        -- finally disable the button itself
        buttonControl:SetState(BSTATE_DISABLED, true)
        return retVar
    end
    local function toLeftAllButtonClicked(buttonControl)
        -- move all entries
        obj:MoveAllEntriesToLeftList()
    end

    local function toRightButtonClicked(buttonControl)
        local leftList = obj.leftList
        local rightList = obj.rightList
        local leftListSelectedData = _getShallowClonedTable(leftList.list.selectedMultiData)
        local retVarLoop = false
        local retVar = true
        for key, data in pairs(leftListSelectedData) do
            retVarLoop = _moveEntryFromTo(leftList, rightList, data.key, obj)
            if not retVarLoop then
                retVar = false
            end
        end
        -- then commit the changes to the scrollList and refresh the hidden states
        _refreshFilter(leftList, true)
        _refreshFilter(rightList)
        -- finally disable the button itself
        buttonControl:SetState(BSTATE_DISABLED, true)
        return retVar
    end
    local function toRightAllButtonClicked(buttonControl)
        -- move all entries
        obj:MoveAllEntriesToRightList()
    end

    -- initialize the handler when the buttons are clicked
    fromLeftButtonControl:SetHandler("OnClicked", toRightButtonClicked)
    fromLeftAllButtonControl:SetHandler("OnClicked", toRightAllButtonClicked)
    fromRightButtonControl:SetHandler("OnClicked", toLeftButtonClicked)
    fromRightAllButtonControl:SetHandler("OnClicked", toLeftAllButtonClicked)
end

local function _getListBoxWidthAndArrowOffset(width, height)
    -- widh must be at least three times the space between the listBoxes
    if width < (3 * LIST_SPACING) then width = (3 * LIST_SPACING) end
    -- the width of a listBox is the total width minus the spacing divided by two
    local singleListWidth = (width - LIST_SPACING) / 2
    -- get the "free height" that is not required by the arrows
    local freeHeight = height - (4 * ARROW_SIZE)
    -- the offset of the arrow is 2/4th of the remaining height plus the height of the arrow
    local arrowOffset = ARROW_SIZE + (freeHeight / 5 * 2)
    -- the offset of the all-arrow is 1/5th of the remaining height
    local arrowAllOffset = freeHeight / 5
    return singleListWidth, arrowOffset, arrowAllOffset
end

local function _setListBoxDimensions(list, singleListWidth, height, headerHeight, buttonAnchorOptions, buttonAllAnchorOptions)
    local buttonControl = list.control:GetNamedChild("Button")
    buttonControl:ClearAnchors()
    buttonControl:SetAnchor(unpack(buttonAnchorOptions))
    local buttonAllControl = list.control:GetNamedChild("AllButton")
    buttonAllControl:ClearAnchors()
    buttonAllControl:SetAnchor(unpack(buttonAllAnchorOptions))
    list:SetCustomDimensions(singleListWidth, height, headerHeight)
    list:Refresh()
end

-- ---------------------------------------------------------------------------------------------------------------------

local function _selectEntries(list, keys)
    local listsList = list.list
    local visibleData = listsList.visibleData
    for _, visibleKey in ipairs(visibleData) do
        local dataEntry = listsList.data[visibleKey]
        local data = dataEntry.data
        for _, key in pairs(keys) do
            if data.key == key then
                local control = dataEntry.control -- can be nil if control is out-of-scroll-view
                list:ToggleEntrySelection(data, control, nil, nil, false)
                break
            end
        end
    end
end

local function _selectEntry(list, key)
    local keys = { key }
    _selectEntries(list, keys)
end

local function _removeEntriesFromList(list, keys)
    local hasAtLeastOneRemoved = false
    for _, key in pairs(keys) do
        local removedKey = list:RemoveEntry(key)
        if removedKey ~= nil then
            hasAtLeastOneRemoved = true
            --For the REMOVED callback
            local entryRemoved = {
                key=key,
            }
            -- then trigger the callback if present
            _fireCallback(list.shifterBox, nil, (list.isLeftList and lib.EVENT_LEFT_LIST_ENTRY_REMOVED) or lib.EVENT_RIGHT_LIST_ENTRY_REMOVED,
                          list, entryRemoved)
        end
    end
    if hasAtLeastOneRemoved then
        _refreshFilter(list, true)
    end
end

local function _removeEntryFromList(list, key)
    local keys = { key }
    _removeEntriesFromList(list, keys)
end

local function _getEntries(list, includeHiddenEntries, withCategoryId)
    local exportList = {}
    local masterList = list.masterList
    if includeHiddenEntries then
        if withCategoryId then
            exportList = _getShallowClonedTable(masterList)
        else
            for key, entry in pairs(masterList) do
                exportList[key] = entry.value
            end
        end
    else
        local categories = list.list.categories
        for key, entry in pairs(masterList) do
            local categoryId = entry.categoryId
            if categoryId == nil or categories[categoryId] == nil or categories[categoryId].hidden == false then
                -- add if entry has no category, category is unknown, or category is known but not hidden
                if withCategoryId then
                    exportList[key] = {
                        value = entry.value,
                        categoryId = entry.categoryId
                    }
                else
                    exportList[key] = entry.value
                end
            end
        end
    end
    return exportList
end

local function _addEntriesToList(list, entries, replace, otherList, categoryId)
    local hasAtLeastOneAdded = false
    local hasAtLeastOneRemoved = false
    local listControl = list.control
    local otherListControl = otherList.control
    if categoryId ~= nil then
        -- if a category is provided, ensure that it definitely is registered to the scrollist
        ZO_ScrollList_AddCategory(list.list, categoryId)
        ZO_ScrollList_AddCategory(otherList.list, categoryId)
    end
    local entriesList
    if type(entries) == "function" then
        entriesList = entries()
    else
        entriesList = entries
    end
    if entriesList then
        local entryAdded = {}
        local entryRemoved = {}
        for key, value in pairs(entriesList) do
            local listRemovedFrom
            if replace and replace == true then
                -- if replace is set to true, make sure that a potential entry with the same key is removed from both lists
                local removeKey = list:RemoveEntry(key)
                local otherRemoveKey = otherList:RemoveEntry(key)
                if removeKey ~= nil or otherRemoveKey ~= nil then
                    listRemovedFrom = (removeKey ~= nil and list) or otherList
                    hasAtLeastOneRemoved = true
                    --For the REMOVED callback
                    if listRemovedFrom ~= nil then
                        entryRemoved = {
                            key=key,
                            value=value,
                            categoryId=categoryId,
                            listRemovedFrom=listRemovedFrom,
                        }
                    end
                    -- then trigger the callback if present
                    _fireCallback(list.shifterBox, nil, (list.isLeftList and lib.EVENT_LEFT_LIST_ENTRY_REMOVED) or lib.EVENT_RIGHT_LIST_ENTRY_REMOVED,
                                  list, entryRemoved)
                end
            else
                -- if replace is not set or set to false, then assert that key does not exist in either list
                _assertKeyIsNotInTable(key, value, list, listControl)
                _assertKeyIsNotInTable(key, value, otherList, otherListControl)
            end
            -- then add entry to the corresponding list
            list:AddEntry(key, value, categoryId)
            --For the ADDED callback
            entryAdded = {
                key=key,
                value=value,
                categoryId=categoryId,
            }
            hasAtLeastOneAdded = true
            -- then trigger the callback if present
            _fireCallback(list.shifterBox, nil, (list.isLeftList and lib.EVENT_LEFT_LIST_ENTRY_ADDED) or lib.EVENT_RIGHT_LIST_ENTRY_ADDED,
                          list, entryAdded)
        end
        if hasAtLeastOneAdded then
            -- Afterwards refresh the visualisation of the data
            _refreshFilter(list)
            if hasAtLeastOneRemoved then
                _refreshFilter(otherList, true)
            end
        end
    end
end

local function _addEntryToList(list, key, value, replace, otherList, categoryId)
    local entries = { [key] = value }
    _addEntriesToList(list, entries, replace, otherList, categoryId)
end

local function _moveEntriesToOtherList(sourceList, keys, destList, shifterBox)
    local retVarLoop = false
    local retVar = true
    for _, key in pairs(keys) do
        retVarLoop = _moveEntryFromTo(sourceList, destList, key, shifterBox)
        if not retVarLoop then
            retVar = false
        end
    end
    -- refresh the display afterwards
    _refreshFilter(sourceList, true)
    _refreshFilter(destList)
    return retVar
end

local function _moveEntryToOtherList(sourceList, key, destList, shifterBox)
    local keys = { key }
    return _moveEntriesToOtherList(sourceList, keys, destList, shifterBox)
end

local function _clearList(list)
    list:ClearMasterList()
    list.buttonControl:SetState(BSTATE_DISABLED, true)
end

local function _hasSameShifterBoxParent(aListBox, otherListBox)
    return aListBox.shifterBox.shifterBoxControl == otherListBox.shifterBox.shifterBoxControl
end

local function _getOtherSideShifterBoxListControl(sourceList)
    local shifterBox = sourceList.shifterBox
    local otherListBox = sourceList.isLeftList and shifterBox.rightList or shifterBox.leftList
    return otherListBox.list
end

-- ---------------------------------------------------------------------------------------------------------------------
--Functions of the cursor UI related TLC
local function _setMouseCursor(cursorName)
    WM:SetMouseCursor(cursorName)
end

local function _getCursorTLC()
--d(">_getCursorTLC")
    CURSORTLC = CURSORTLC or WM:GetControlByName(CURSOR_TLC_NAME, nil)
    if not CURSORTLC then return end
    CURSORTLC.label = CURSORTLC.label or GetControl(CURSORTLC, "Label")
    CURSORTLC:ClearAnchors()
    CURSORTLC:SetDimensions(0, 0)
end

-- ---------------------------------------------------------------------------------------------------------------------
--Drag & drop functions
local function _getDraggedDataAndTarget(shifterBox)
    local dragData = shifterBox.currentDragData
    local sourceListControl = dragData and dragData._sourceListControl
    local otherSideShifterBox = sourceListControl and _getOtherSideShifterBoxListControl(sourceListControl)
    return dragData, sourceListControl, otherSideShifterBox
end

local function _clearDragging(shifterBox)
--d(">_clearDragging")
    shifterBox.currentDragData = nil
    shifterBox.draggingUpdateTime = nil
    shifterBox.draggingMouseButtonPressed = nil
end

local function _disableOnUpdateHandler(shifterBox)
--d(">_disableOnUpdateHandlerAndResetMouseCursor")
    EM:UnregisterForEvent(EVENT_HANDLER_NAMESPACE .. GLOBAL_MOUSE_DOWN, EVENT_GLOBAL_MOUSE_DOWN)
    EM:UnregisterForEvent(EVENT_HANDLER_NAMESPACE .. GLOBAL_MOUSE_UP,   EVENT_GLOBAL_MOUSE_UP)
    shifterBox.shifterBoxControl:SetHandler("OnUpdate", nil)

    --Hide the label control at the cursor again
    shifterBox:UpdateCursorTLC(true, nil)
end

local function _abortDragging(shifterBox)
--d(">_abortDragging")
    _disableOnUpdateHandler(shifterBox)
    _clearDragging(shifterBox)
end

local function _checkIfDraggedAndDisableUpdateHandler(lamPanel)
--d("_checkIfDraggedAndDisableUpdateHandler")
    if CURSORTLC == nil then _getCursorTLC() end
    if not CURSORTLC then return end
    local shifterBox = CURSORTLC.shifterBox
    if shifterBox == nil or shifterBox.currentDragData == nil then return end
    _abortDragging(shifterBox)
    _setMouseCursor(MOUSECURSOR_DONOTCATRE)
end

local function _resetDragData(shifterBox)
--d(">>resetDragData")
    _abortDragging(shifterBox)
    _setMouseCursor(MOUSECURSOR_DONOTCATRE)
end

--Auto scroll the orderListBox upon dragging an entry to the top/bottom of the list
local function _autoScroll(shifterBox)
--d(">autoscroll")
    local dragData, sourceListControl, otherSideShifterBoxList = _getDraggedDataAndTarget(shifterBox)
    if not dragData or not sourceListControl or not otherSideShifterBoxList then
        _resetDragData(shifterBox)
    end
    local contents = otherSideShifterBoxList.contents
    local numContentChildren = (contents ~= nil and contents:GetNumChildren()) or 0
    local contentsHeight = contents:GetHeight()
    if not contents or numContentChildren == 0 then return end
    local controlBelowMouse = moc()
    if not controlBelowMouse or not controlBelowMouse.GetParent or controlBelowMouse:GetParent() ~= contents then return end
    local isValid, point, relTo, relPoint, offsetX, offsetY = controlBelowMouse:GetAnchor(0)
    local libShifterBoxRowHeight = otherSideShifterBoxList.rowHeight or defaultListSettings.rowHeight
    local libShifterBoxScrollArea = libShifterBoxRowHeight * 1.5
    local scrollValue
    if offsetY < 0 or (offsetY >= 0 and offsetY <= libShifterBoxScrollArea) then
        --Scroll up
        scrollValue = (libShifterBoxRowHeight * 2) * -1
    elseif offsetY <= contentsHeight and offsetY >= contentsHeight - libShifterBoxScrollArea then
        --Scroll down
        scrollValue = libShifterBoxRowHeight * 2
    end
    if scrollValue == nil or scrollValue == 0 then return end
--d(">scrollValue: " ..tos(scrollValue))
    ZO_ScrollList_ScrollRelative(otherSideShifterBoxList, scrollValue, nil, true)
end


-- =================================================================================================================
-- == SCROLL-LISTS == --
-- -----------------------------------------------------------------------------------------------------------------
-- Source: https://esoapi.uesp.net/100028/src/libraries/zo_sortfilterlist/zo_sortfilterlist.lua.html
local ShifterBoxList = ZO_SortFilterList:Subclass()

ShifterBoxList.SORT_KEYS = {
    ["value"] = {},
    ["key"] = {tiebreaker="value"}
}

function ShifterBoxList:New(shifterBox, control, isLeftList)
    local shifterBoxSettings = shifterBox.shifterBoxSettings
    local listObj            = ZO_SortFilterList.New(self, control, shifterBoxSettings, isLeftList, shifterBox) -->ShifterBoxList:Initialize

    --Buttons
    listObj.buttonControl    = control:GetNamedChild("Button")
    listObj.buttonAllControl = control:GetNamedChild("AllButton")
    listObj.buttonAllControl:SetState(BSTATE_DISABLED, true) -- init it as disabled
    if shifterBoxSettings.showMoveAllButtons == false then listObj.buttonAllControl:SetHidden(true) end
    --Search button
    local searchEnabled         = shifterBoxSettings.search.enabled
    listObj.searchHeaderUI = control:GetNamedChild("HeadersSearchUI")
    listObj.searchHeaderUIEditBox = listObj.searchHeaderUI:GetNamedChild("Box")
    listObj.buttonSearchControl = control:GetNamedChild("HeadersSearchButton")
    listObj.buttonSearchControl:SetAlpha(0.5)
    listObj.buttonSearchControl:SetState((searchEnabled and BSTATE_NORMAL) or BSTATE_DISABLED, not searchEnabled) -- init via customOptions
    listObj.buttonSearchControl:SetHidden(not searchEnabled)
    listObj.buttonSearchControl:SetHandler("OnClicked", function(...) _onSearchHeaderButtonClicked(shifterBox, listObj, ...) end)
    listObj.buttonSearchControl:SetHandler("OnMouseEnter", function(buttonCtrl)
        ZO_Tooltips_HideTextTooltip()
        local tooltipText
        if listObj.searchHeaderUIEditBox:IsHidden() then
            buttonCtrl:SetAlpha(1)
            buttonCtrl:SetDimensions(32, 32)

            tooltipText = GetString(SI_SEARCH_FILTER_BY)
            local currentText = listObj.searchHeaderUIEditBox:GetText()
            if currentText ~= "" then
                tooltipText = tooltipText .. "\n|c00FF00" .. GetString(SI_COLOR_PICKER_CURRENT) .. "|r: " .. currentText
            end
        end
        local scrollData = ZO_ScrollList_GetDataList(listObj.list)
        if tooltipText == nil then
            tooltipText = "#" ..tos(#scrollData)
        else
            tooltipText = tooltipText .. "\n#" ..tos(#scrollData)
        end
        if tooltipText then
            ZO_Tooltips_ShowTextTooltip(buttonCtrl, TOP, tooltipText)
        end
    end)
    listObj.buttonSearchControl:SetHandler("OnMouseExit", function(buttonCtrl)
        ZO_Tooltips_HideTextTooltip()
        if listObj.searchHeaderUIEditBox:IsHidden() then
            local currentText = listObj.searchHeaderUIEditBox:GetText()
            if currentText == "" then
                buttonCtrl:SetAlpha(0.5)
                buttonCtrl:SetDimensions(28, 28)
            end
        end
    end)
    listObj.searchHeaderUI:SetHidden(true)
    listObj.isSearchHeaderUIShown = false
    listObj.searchStr             = nil
    listObj.searchHeaderUIEditBox:SetHandler("OnTextChanged", function(...) _onSearchHeaderEditBoxTextChanged(shifterBox, listObj, ...) end)
    listObj.searchHeaderUIEditBox:SetHandler("OnEnter", function(...) _onSearchHeaderEditBoxReturnKey(shifterBox, listObj, ...) end)

    listObj.enabled               = true
    listObj.masterList            = {}

    listObj.shifterBox            = shifterBox -- keep a reference to the "parent" ShifterBox
    return listObj
end

function ShifterBoxList:OnSelectionChanged(previouslySelectedData, selectedData, reselectingDuringRebuild)
    local selectedMultiData = _getShallowClonedTable(self.list.selectedMultiData)
    if selectedMultiData then
        local count = 0
        for _ in pairs(selectedMultiData) do count = count + 1 end
        if count > 0 and self.enabled then
            self.buttonControl:SetState(BSTATE_NORMAL, false)
        else
            self.buttonControl:SetState(BSTATE_DISABLED, true)
        end
    end
end

function ShifterBoxList:Initialize(control, shifterBoxSettings, isLeftList, shifterBox) --from ShifterBoxList:New -> ZO_SortFilterList.New(...
    local selfVar = self
    self.shifterBoxSettings = shifterBoxSettings

    local listBoxSettings
    if isLeftList then
        listBoxSettings = shifterBoxSettings.leftList
    else
        listBoxSettings = shifterBoxSettings.rightList
    end
    self.listBoxSettings = listBoxSettings

    self.isLeftList = isLeftList
    self.rowHeight = listBoxSettings.rowHeight
    self.rowWidth = 180 -- default value to init
    -- initialize the SortFilterList
    ZO_SortFilterList.Initialize(self, control)
    -- set a text that is displayed when there are no entries
    self:SetEmptyText(listBoxSettings.emptyListText)
    if  self.shifterBoxSettings.sortEnabled then
        -- default sorting key
        -- Source: https://esodata.uesp.net/100028/src/libraries/zo_sortheadergroup/zo_sortheadergroup.lua.html
        self.sortHeaderGroup:SelectHeaderByKey("value")
        ZO_SortHeader_OnMouseExit(self.control:GetNamedChild("Headers"):GetNamedChild("Value"))
    else
        -- disable sortHeaderGroup by hiding the Arrow and disable the mouse on the text
        self.sortHeaderGroup.headerContainer:GetNamedChild("Arrow"):SetHidden(true)
        self.sortHeaderGroup.headerContainer:GetNamedChild("Value"):SetMouseEnabled(false)
    end
    -- define the datatype for this list and enable the highlighting
    ZO_ScrollList_AddCategory(self.list, DATA_DEFAULT_CATEGORY)

    --Adds a new control type for the list to handle. It must maintain a consistent size.
    --@typeId - A unique identifier to give to CreateDataEntry when you want to add an element of this type.
    --@templateName - The name of the virtual control template that will be used to hold this data
    --@height - The control height
    --@setupCallback - The function that will be called when a control of this type becomes visible. Signature: setupCallback(control, data)
    --@dataTypeSelectSound - An optional sound to play when a row of this data type is selected.
    --@resetControlCallback - An optional callback when the datatype control gets reset.
    --function ZO_ScrollList_AddDataType(self, typeId, templateName, height, setupCallback, hideCallback, dataTypeSelectSound, resetControlCallback)
    local additionalDataCallbackFunc = listBoxSettings.rowSetupAdditionalDataCallback or nil
    local function standardSetupCallback(rowControl, data, doNotSetupRowNow)
        local dataTabEnriched = data
        if additionalDataCallbackFunc ~= nil then
            rowControl, dataTabEnriched = additionalDataCallbackFunc(rowControl, data)
        end
        self:SetupRowEntry(rowControl, dataTabEnriched, doNotSetupRowNow)
    end
    local setupCallbackFunc = standardSetupCallback
    if listBoxSettings.rowSetupCallback ~= nil then
        setupCallbackFunc = function(rowControl, data)
            standardSetupCallback(rowControl, data, true)
            self.listBoxSettings.rowSetupCallback(rowControl, data)
            ZO_SortFilterList.SetupRow(selfVar, rowControl, data)
        end
    end
    local hideCallbackFunc      = listBoxSettings.rowHideCallback or nil
    local dataTypeSelectSound   = listBoxSettings.rowDataTypeSelectSound or nil
    local resetControlCallback  = listBoxSettings.rowResetControlCallback or nil
    ZO_ScrollList_AddDataType(self.list,
            DATA_TYPE_DEFAULT,
            listBoxSettings.rowTemplateName,
            listBoxSettings.rowHeight,
            setupCallbackFunc,
            hideCallbackFunc,
            dataTypeSelectSound,
            resetControlCallback
    )
    ZO_ScrollList_EnableSelection(self.list, "ZO_ThinListHighlight", function(...)
        self:OnSelectionChanged(...)
    end)
    -- set up sorting function and refresh all data
    self.sortFunction = function(listEntry1, listEntry2)
        return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.shifterBoxSettings.sortBy, ShifterBoxList.SORT_KEYS, self.currentSortOrder)
    end
    self:RefreshData()

    -- handle stop draging -> Moved to self:StopDragging
    self.list:SetHandler("OnReceiveDrag", function(...) self:StopDragging(...) end)
    self.list:SetMouseEnabled(true)

    --Any callbacks to register now from the settings (e.g. the "List created" one, which would not fire again later :-) )
    if self.listBoxSettings.callbackRegister ~= nil then
        for shifterBoxEventId, callbackFunc in pairs(listBoxSettings.callbackRegister) do
            shifterBox:RegisterCallback(shifterBoxEventId, callbackFunc)
        end
    end
    -- then trigger the callback if present
    _fireCallback(shifterBox, control, (isLeftList and lib.EVENT_LEFT_LIST_CREATED) or lib.EVENT_RIGHT_LIST_CREATED,
            shifterBox)
end

-- ZO_SortFilterList:RefreshData()      =>  BuildMasterList()   =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshFilters()                           =>  FilterScrollList()  =>  SortScrollList()    =>  CommitScrollList()
-- ZO_SortFilterList:RefreshSort()                                                      =>  SortScrollList()    =>  CommitScrollList()

function ShifterBoxList:BuildMasterList()
    -- intended to be overridden
    -- should build the master list of data that is later filtered by FilterScrollList
end

function ShifterBoxList:FilterScrollList()
    -- intended to be overridden
    -- should take the master list data and filter it
    --Check for any search enabled and current search text is set
    local shifterBoxSettings = self.shifterBoxSettings
    local searchSettings = shifterBoxSettings.search
    local searchEnabled = (self.searchStr ~= nil and getValueOrCallback(searchSettings.enabled, searchSettings)) or false
    local searchFunc = (searchEnabled == true and searchSettings.searchFunc) or nil
    if type(searchFunc) ~= "function" then
        searchEnabled = false
    end

    local hasAtLeastOneEntry = false
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
    if self.masterList then
        local categories = self.list.categories
        for key, data in pairs(self.masterList) do
            -- check if the categoryId is NOT existing; or NOT set to hidden
            local category = categories[data.categoryId]
            if category == nil or category.hidden == false then
                local rowData = {
                    key = key,
                    value = data.value
                }

                if not searchEnabled or (searchEnabled and searchFunc(self, data, self.searchStr)) then
                    tins(scrollData, ZO_ScrollList_CreateDataEntry(DATA_TYPE_DEFAULT, rowData, data.categoryId or DATA_DEFAULT_CATEGORY))
                    hasAtLeastOneEntry = true
                end
            else
                -- entry will not (or will no longer) be visible
                if self.list.selectedMultiData then
                    self.list.selectedMultiData[key] = nil
                end
            end
        end
    end
    if hasAtLeastOneEntry and self.enabled then
        -- when there is at least one entry, the move-all button can be enabled
        self.buttonAllControl:SetState(BSTATE_NORMAL, false)
        self:OnSelectionChanged()
    else
        -- if there are no entries ; disable both move buttons
        if self.buttonControl then
            self.buttonControl:SetState(BSTATE_DISABLED, true)
        end
        if self.buttonAllControl then
            self.buttonAllControl:SetState(BSTATE_DISABLED, true)
        end
    end
end

function ShifterBoxList:SortScrollList()
    -- intended to be overridden
    -- should take the filtered data and sort it
    local shifterBoxSettings = self.shifterBoxSettings
    if shifterBoxSettings.sortEnabled then
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        tsort(scrollData, self.sortFunction)
    end
end

function ShifterBoxList:AddEntry(key, value, categoryId)
    local data = {
        value = value,
        categoryId = categoryId
    }
    self.masterList[key] = data
end

function ShifterBoxList:RemoveEntry(key)
    if self.masterList[key] ~= nil then
        local data = _getShallowClonedTable(self.masterList[key])
        -- remove the entry from the masterList
        self.masterList[key] = nil
        -- and remove it from the selectedList
        if self.list.selectedMultiData then
            self.list.selectedMultiData[key] = nil
        end
        return key, data.value, data.categoryId
    end
    return nil
end

function ShifterBoxList:ClearMasterList()
    self.masterList = {}
    _refreshFilter(self, true)
end

function ShifterBoxList:UnselectEntries()
    self.list.selectedMultiData = {}
    self:CommitScrollList()
    self.buttonControl:SetState(BSTATE_DISABLED, true)
end

--- this function only visually selects an entry, it does NOT store it in the selected-list though!
function ShifterBoxList:SelectControl(control, animateInstantly)
    local controlTemplate = self.list.selectionTemplate
    local animationFieldName = ANIMATION_FIELD_NAME
    -- SelectControl()
    if controlTemplate then
        if not control[animationFieldName] then
            local highlight = CreateControlFromVirtual("$(parent)Scroll", control, controlTemplate, animationFieldName)
            control[animationFieldName] = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", highlight)
        end
        if animateInstantly then
            control[animationFieldName]:PlayInstantlyToEnd()
        else
            control[animationFieldName]:PlayForward()
        end
    end
end

--- this function only visually unselects an entry, it does NOT remove it from the selected-list though!
function ShifterBoxList:UnselectControl(control, animateInstantly)
    local animationFieldName = ANIMATION_FIELD_NAME
    -- UnselectControl()
    if control[animationFieldName] then
        if animateInstantly then
            control[animationFieldName]:PlayInstantlyToStart()
        else
            control[animationFieldName]:PlayBackward()
        end
    end
end

-- Custom implementation based on: https://esoapi.uesp.net/100028/src/libraries/zo_templates/scrolltemplates.lua.html#1456
--- this function toggles the selection of an entry and also adds/removes it to/from the selected-list
-- @param data - the table with the data of the entry (mandatory)
-- @param control - the control of the entry (optional - can be deferred from data)
-- @param reselectingDuringRebuild - to be defined
-- @param animateInstantly - if the selection animation is instantly or not
-- @param deselectOnReselect - if the entry is already selected, instead of reselecting it will be deselected
function ShifterBoxList:ToggleEntrySelection(data, control, reselectingDuringRebuild, animateInstantly, deselectOnReselect )
    if not self.enabled then return end -- if the listBox is not enabled; immediately exit the function
    if reselectingDuringRebuild == nil then
        reselectingDuringRebuild = false
    end
    if animateInstantly == nil then
        animateInstantly = false
    end
    if deselectOnReselect  == nil then
        deselectOnReselect  = true
    end
    local dataKey
    if data ~= nil then
        for i = 1, #self.list.data do
            local currData = self.list.data[i].data
            if currData == data then
                dataKey = currData.key
                break
            end
        end
        -- this data we tried to select isn't in the scroll list at all, just abort
        if dataKey == nil then
            return
        end
    end
    if self.list.selectedMultiData == nil then
        self.list.selectedMultiData = {}
    end
    if data ~= nil then
        if not control then
            control = ZO_ScrollList_GetDataControl(self.list, data)
        end
        -- check if already selected
        if self.list.selectedMultiData[dataKey] == nil then
            -- add selected data
            self.list.selectedMultiData[dataKey] = data
            -- and select the control (if applicable)
            if control then self:SelectControl(control, animateInstantly) end
            -- then trigger the callback if present
            _fireCallback(self.shifterBox, control, lib.EVENT_ENTRY_HIGHLIGHTED,
                    self.shifterBox, dataKey, data.value, data.categoryId, self.isLeftList)

        elseif deselectOnReselect then
            -- remove selected data
            self.list.selectedMultiData[dataKey] = nil
            -- and unselect the control (if applicable)
            if control then self:UnselectControl(control, animateInstantly) end
            -- then trigger the callback if present
            _fireCallback(self.shifterBox, control, lib.EVENT_ENTRY_UNHIGHLIGHTED,
                    self.shifterBox, dataKey, data.value, data.categoryId, self.isLeftList)
        end
    end
    if self.list.selectionCallback then
        self.list.selectionCallback(data, self.list.selectedMultiData, reselectingDuringRebuild)
    end
end

function ShifterBoxList:SetupRowEntry(rowControl, rowData, doNotSetupRowNow)
    doNotSetupRowNow = doNotSetupRowNow or false
    local function onRowMouseEnter(p_rowControl)
        if self.enabled then
            -- then trigger the callback if present
            _fireCallback(self.shifterBox, p_rowControl, (self.isLeftList and lib.EVENT_LEFT_LIST_ROW_ON_MOUSE_ENTER) or lib.EVENT_RIGHT_LIST_ROW_ON_MOUSE_ENTER,
                    self.shifterBox, rowData)

            if self.listBoxSettings.rowOnMouseEnter ~= nil then
                self.listBoxSettings.rowOnMouseEnter(p_rowControl)
            else
                local labelControl = p_rowControl:GetNamedChild("Label")
                local textWidth = labelControl:GetTextWidth()
                local desiredWidth = labelControl:GetDesiredWidth()
                -- only show tooltip if the text/label was truncated or if the text is wider than the desiredWidth minus the scrollbar width
                local wasTruncated = p_rowControl:GetNamedChild("Label"):WasTruncated()
                if wasTruncated or (textWidth + SCROLLBAR_WIDTH) > desiredWidth then
                    local data = ZO_ScrollList_GetData(p_rowControl)
                    ZO_Tooltips_ShowTextTooltip(p_rowControl, TOP, data.value)
                end
            end
        end
    end
    local function onRowMouseExit(p_rowControl)
        if self.enabled then
            -- then trigger the callback if present
            _fireCallback(self.shifterBox, p_rowControl, (self.isLeftList and lib.EVENT_LEFT_LIST_ROW_ON_MOUSE_EXIT) or lib.EVENT_RIGHT_LIST_ROW_ON_MOUSE_EXIT,
                    self.shifterBox, rowData)

            if self.listBoxSettings.rowOnMouseExit ~= nil then
                self.listBoxSettings.rowOnMouseExit(p_rowControl)
            else
                ZO_Tooltips_HideTextTooltip()
            end
        end
    end
    local function onRowMouseUp(p_rowControl, mouseButton, isInside, ctrlKey, altKey, shiftKey, commandKey)
        if self.enabled then
            -- then trigger the callback if present
            _fireCallback(self.shifterBox, p_rowControl, (self.isLeftList and lib.EVENT_LEFT_LIST_ROW_ON_MOUSE_UP) or lib.EVENT_RIGHT_LIST_ROW_ON_MOUSE_UP,
                    self.shifterBox, mouseButton, isInside, ctrlKey, altKey, shiftKey, commandKey, rowData)

            if not isInside then return end
            if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
                local data = ZO_ScrollList_GetData(p_rowControl)
                self:ToggleEntrySelection(data, p_rowControl, RESELECTING_DURING_REBUILD, false)
            elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
                if self.listBoxSettings.rowOnMouseRightClick ~= nil then
                    local data = ZO_ScrollList_GetData(p_rowControl)
                    self.listBoxSettings.rowOnMouseRightClick(p_rowControl, data)
                end
            end
        end
    end
    local function onDragStart(p_rowControl, mouseButton)
        if self.enabled then
            self:StartDragging(p_rowControl, mouseButton)
        end
    end
    -- set the value for the row entry
    local labelControl = rowControl:GetNamedChild("Label")
    labelControl:SetText(rowData.value)
    -- the below two handlers only work if "PersonalAssistantBankingRuleListRowTemplate" is set to a <Button> control
    rowControl:SetHandler("OnMouseEnter", onRowMouseEnter)
    rowControl:SetHandler("OnMouseExit", onRowMouseExit)
    -- handle single clicks to mark entry
    rowControl:SetHandler("OnMouseUp", onRowMouseUp)
    -- handle start dragging
    if self.shifterBoxSettings.dragDropEnabled then
        rowControl:SetHandler("OnDragStart", onDragStart)
    end

    local listBoxSettings = self.listBoxSettings
    -- set the height for the row
    rowControl:SetHeight(listBoxSettings.rowHeight)
    -- and also set the width for the row (to ensure tooltips work properly)
    rowControl:SetWidth(self.rowWidth)
    labelControl:SetWidth(self.rowWidth)

    -- set the font
    local customFont = strfor("$(%s)|$(KB_%s)|%s", FONT_STYLE, listBoxSettings.fontSize, FONT_WEIGHT)
    labelControl:SetFont(customFont)

    -- reselect entries (only visually) if necessary
    local selectedMultiData = _getShallowClonedTable(self.list.selectedMultiData)
    if selectedMultiData and selectedMultiData[rowData.key] ~= nil then
        self:SelectControl(rowControl, false)
    end

    -- then setup the row
    if doNotSetupRowNow then return end
    ZO_SortFilterList.SetupRow(self, rowControl, rowData)
end

function ShifterBoxList:SetCustomDimensions(width, height, headerHeight)
    -- first set width/height of the listbox itself
    self.rowWidth = width - SCROLLBAR_WIDTH
    self.list:SetDimensions(width, height)
    self.headersContainer:SetDimensions(width, headerHeight)
    -- and of the header (needed to cut down headers that are too long)
    local headerValueControl = self.headersContainer:GetNamedChild("Value")
    headerValueControl:SetWidth(width)
    -- then re-set the anchor for the arrow to reposition itself
    local headerValueNameControl = headerValueControl:GetNamedChild("Name")
    local headerArrowControl = self.headersContainer:GetNamedChild("Arrow")
    local headerTextWidth = headerValueNameControl:GetTextWidth()
    headerArrowControl:ClearAnchors()
    if headerTextWidth > width then
        -- FIXME: does not correctly work when the ShifterBox is made bigger because the TextWidth() is not updated yet
        headerArrowControl:SetAnchor(LEFT, headerValueNameControl, LEFT, width, 0)
    else
        headerArrowControl:SetAnchor(LEFT, headerValueNameControl, LEFT, headerTextWidth, 0)
    end
end

function ShifterBoxList:Refresh()
    -- make sure that all rows have the correct width
    local rowControls = self.list.contents
    for childIndex = 1, rowControls:GetNumChildren() do
        local rowControl = rowControls:GetChild(childIndex)
        local rowControlLabel = rowControl:GetNamedChild("Label")
        rowControlLabel:SetWidth(rowControl:GetWidth())
    end
    -- then update the scroll list (i.e. update scrollbar)
    self:CommitScrollList()
end

function ShifterBoxList:SetEntriesEnabled(enabled)
    if not enabled then
        -- unselect all entries
        self:UnselectEntries()
    end
    -- after unselecting all entries, change the actual state of the rowControl-buttons
    local list = self.list
    local rowControls = list.contents
    for childIndex = 1, rowControls:GetNumChildren() do
        local rowControl = rowControls:GetChild(childIndex)
        rowControl:SetMouseEnabled(enabled)
    end
    rowControls:SetAlpha(enabled and 1 or 0.3)
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    local numChildren = #scrollData
    -- enable/disable the "all" and "Search" button
    if enabled and numChildren > 0 then
        self.buttonAllControl:SetState(BSTATE_NORMAL, false)
    else
        self.buttonAllControl:SetState(BSTATE_DISABLED, true)
    end
    -- disable sortHeaderGroup
    local sortHeaderGroup = self.sortHeaderGroup
    sortHeaderGroup:SetEnabled(enabled)
    local arrowCtrl = sortHeaderGroup.headerContainer:GetNamedChild("Arrow")
    local valueCtrl = sortHeaderGroup.headerContainer:GetNamedChild("Value")
    if enabled then
        arrowCtrl:SetAlpha(1)
    else
        arrowCtrl:SetAlpha(0.5)
    end

    list.scrollbar:SetMouseEnabled(enabled)
    list.downButton:SetMouseEnabled(enabled)
    list.upButton:SetMouseEnabled(enabled)

    self.searchHeaderUI:SetMouseEnabled(enabled)
    self.searchHeaderUIEditBox:SetMouseEnabled(enabled)
    self.buttonSearchControl:SetMouseEnabled(enabled)
    if not enabled then
        arrowCtrl:SetHidden(false)
        valueCtrl:SetHidden(false)
        self.searchHeaderUI:SetHidden(true)
        self.searchHeaderUIEditBox:SetText("")
        self.searchText = nil
        self.buttonSearchControl:GetHandler("OnMouseExit")(self.buttonSearchControl)
        self.isSearchHeaderUIShown = false
    end

    -- finally, store the enabled state
    self.enabled = enabled
end

--Drag & drop functions
function ShifterBoxList:OnGlobalMouseDownDuringDrag(eventId, mouseButton, ctrl, alt, shift, command)
--d("[OrderListBox]OnGlobalMouseDownDuringDrag - draggedKey: " ..tos(self.shifterBox.currentDragData.key) .. ", mouseButton: " ..tos(mouseButton))
    if not self.enabled or not self.shifterBoxSettings.dragDropEnabled then return end
    if self.shifterBox.currentDragData then
        self.shifterBox.draggingMouseButtonPressed = mouseButton
    end
end

function ShifterBoxList:OnGlobalMouseUpDuringDrag(eventId, mouseButton, ctrl, alt, shift, command)
--d("[OrderListBox]OnGlobalMouseUpDuringDrag - draggedKey: " ..tos(self.shifterBox.currentDragData.key) .. ", mouseButton: " ..tos(mouseButton))
    if not self.enabled or not self.shifterBoxSettings.dragDropEnabled then return end
    if mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then
--d("<ABORT due to wrong mouse button!")
        _resetDragData(self.shifterBox)
    end
    local dragData, sourceListControl, otherSideShifterBox = _getDraggedDataAndTarget(self.shifterBox)
    if not dragData or not sourceListControl or not otherSideShifterBox then
--d(">drag data or source list or other side's list of shifterbox is missing")
        _resetDragData(self.shifterBox)
    end
    --is the control below the mouse, or it's parent, a valid LibShifterBox's other side, e.g left->dragged to right)
    local controlBelowMouse = moc()
    local parentOfMoc = controlBelowMouse:GetParent()
    if (not controlBelowMouse or not parentOfMoc or
            (
                    (controlBelowMouse and parentOfMoc) and
                    (parentOfMoc == sourceListControl or
                        (parentOfMoc ~= otherSideShifterBox and parentOfMoc ~= otherSideShifterBox.contents))
            )
    ) then
--d(">control below mouse is not supported")
        _resetDragData(self.shifterBox)
    end
end

function ShifterBoxList:DragOnUpdateCallback(draggedControl)
    if not self.enabled or not self.shifterBoxSettings.dragDropEnabled then
        _abortDragging(self.shifterBox)
        return
    end

    --Check the actual shown rows of the list (contents)
    -->Check the anchor's offsetY of the row of the contents. If between 0 and 2*rowHeight -> Scroll up
    -->If between contents:GetHeight()- 2*rowHeight and contents:GetHeight() -> Scroll down
    --Only run the following code once every 200 ms!
    local gameTimeMS = GetGameTimeMilliseconds()
    local gameTimeDeltaNeeded = 200 --milliseconds
    local draggingUpdateTime = self.shifterBox.draggingUpdateTime
--d("[LibShifterBox]OnUpdate-gameTime: " ..tos(gameTimeMS) .. ", self.draggingUpdateTime: " ..tos(self.draggingUpdateTime))
    local updateAutoScroll = false
    if draggingUpdateTime == nil then
        self.shifterBox.draggingUpdateTime = gameTimeMS
        updateAutoScroll = true
    elseif draggingUpdateTime > 0 then
        if gameTimeMS >= (draggingUpdateTime + gameTimeDeltaNeeded) then
            self.shifterBox.draggingUpdateTime = gameTimeMS
            updateAutoScroll = true
        end
    end
--d(">updateAutoScroll: " .. tos(updateAutoScroll) ..", needed: " ..tos(self.draggingUpdateTime + gameTimeDeltaNeeded))
    if updateAutoScroll == true then
        _autoScroll(self.shifterBox)
    end
end

function ShifterBoxList:StartDragging(draggedControl, mouseButton)
--d("StartDragging")
    if not self.enabled or not self.shifterBoxSettings.dragDropEnabled then return end
    if mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then return end

    local currentDragData = ZO_ScrollList_GetData(draggedControl)
    local selectedData = _getShallowClonedTable(self.list.selectedMultiData)
    local numRowsSelected = (selectedData ~= nil and NonContiguousCount(selectedData)) or 1
    local draggedDataEntry = draggedControl.dataEntry.data
    --Multiple rows were selected. Is the row we started the drag on also selected?
    --If not: Select it!
    local isSelected = selectedData and selectedData[draggedDataEntry.key] ~= nil
--d("[ShifterBoxList]StartDragging - key: " ..tos(draggedDataEntry.key) .. ", draggedControlKey: " ..tos(draggedControl.key) ..", isSelected: " ..tos(isSelected))
    if not isSelected and selectedData then
        for _, selectedRowData in pairs(selectedData) do
            if draggedDataEntry.key == selectedRowData.key then
                isSelected = true
                break
            end
        end
        if not isSelected then
            _selectEntry(self, draggedDataEntry.key)
            numRowsSelected = numRowsSelected + 1
            isSelected = true
        end
    end
    local hasMultipleRowsSelected = numRowsSelected > 1 or false
    currentDragData._sourceListControl = self
    currentDragData._sourceDraggedControl = draggedControl
    currentDragData._isSelected = isSelected
    currentDragData._hasMultipleRowsSelected = hasMultipleRowsSelected
    currentDragData._numRowsSelected = numRowsSelected
    currentDragData._isFromLeftList = self.isLeftList
    currentDragData._draggedText = draggedDataEntry.value
    currentDragData._draggedAdditionalText = (hasMultipleRowsSelected and zo_strformat(multipleRowsDraggedText, tos(numRowsSelected - 1))) or nil
    self.shifterBox.currentDragData  = currentDragData

    self.shifterBox.draggingMouseButtonPressed = mouseButton

    -- then trigger the callback if present
    _fireCallback(self.shifterBox, draggedControl, (self.isLeftList and lib.EVENT_LEFT_LIST_ROW_ON_DRAG_START) or lib.EVENT_RIGHT_LIST_ROW_ON_DRAG_START,
            self.shifterBox, mouseButton, currentDragData)

    --Anchor the TLC with the label showing the text of the dragged row element(s) to GuiMouse
    self.shifterBox:UpdateCursorTLC(false, draggedControl)

    local mouseCursor = self.isLeftList and MOUSECURSOR_NEXTRIGHT or MOUSECURSOR_NEXTLEFT
    _setMouseCursor(mouseCursor)
    --Unselect any selected entry
    --ZO_ScrollList_SelectData(self.list, nil, nil, nil, true)
    --Enable a global MouseUp check and see if the mouse is above the ZO_SortList where the drag started
    --If not: End the drag&drop
    local selfVar = self
    EM:RegisterForEvent(EVENT_HANDLER_NAMESPACE .. GLOBAL_MOUSE_DOWN, EVENT_GLOBAL_MOUSE_DOWN, function(...) selfVar:OnGlobalMouseDownDuringDrag(...) end)
    EM:RegisterForEvent(EVENT_HANDLER_NAMESPACE .. GLOBAL_MOUSE_UP, EVENT_GLOBAL_MOUSE_UP, function(...) selfVar:OnGlobalMouseUpDuringDrag(...) end)

    --Set the OnUpdate handler to check for the autosroll position of the cursor
    self.shifterBox.draggingUpdateTime = nil
    self.shifterBox.shifterBoxControl:SetHandler("OnUpdate", function() selfVar:DragOnUpdateCallback(draggedControl) end)
end


function ShifterBoxList:StopDragging(draggedOnToControl)
--d("ShifterBoxList:StopDragging")
    --Delay so the OnMouseButtonDown/Up handlers fire first
    -->ShifterBoxList:OnGlobalMouseUpDuringDrag will clear teh draggedData if the draggedToControl is not a supported one
    zo_callLater(function()
        local mouseButton = self.shifterBox.draggingMouseButtonPressed
--d("StopDragging - mouseButton: " ..tos(mouseButton) ..", contentType: " ..tos(GetCursorContentType()))
        if not self.enabled or not self.shifterBoxSettings.dragDropEnabled then return end
        _disableOnUpdateHandler(self.shifterBox)
        _setMouseCursor(MOUSECURSOR_DONOTCATRE)

        if mouseButton and mouseButton == MOUSE_BUTTON_INDEX_LEFT and GetCursorContentType() == MOUSE_CONTENT_EMPTY then
--d("[ShifterBoxList]StopDragging -- from key: " ..tos(self.shifterBox.currentDragData.key) .." to key: " ..tos(draggedOnToControl.key))
            local dragData = self.shifterBox.currentDragData
            if dragData then
                local wasDragSuccessful = false

                -- make sure the sourceListBox and "this" listBox belong to the same shifterBox
                local sourceListControl = dragData._sourceListControl
                local hasSameShifterBoxParent = _hasSameShifterBoxParent(self, sourceListControl)
                local isLeftList = self.isLeftList
                if hasSameShifterBoxParent then
                    local sourceList = isLeftList and self.shifterBox.rightList or self.shifterBox.leftList
                    local destList = self
                    local isDragDataSelected = dragData._isSelected
                    if isDragDataSelected and isLeftList ~= dragData._isFromLeftList then
                        -- if the dragged data was selected (and is not from the same list), then move all selected entries (by "clicking" the button)
                        local buttonControl = sourceListControl.buttonControl
                        local buttonOnClickedFunction = buttonControl:GetHandler("OnClicked")
                        wasDragSuccessful = buttonOnClickedFunction(buttonControl)
                    else
                        -- if the dragged data was NOT selected, then only move that single entry
                        wasDragSuccessful = _moveEntryToOtherList(sourceList, dragData.key, destList, self.shifterBox)
                    end
                end

                -- then trigger the callback if present
                _fireCallback(self.shifterBox, draggedOnToControl, (isLeftList and lib.EVENT_LEFT_LIST_ROW_ON_DRAG_END) or lib.EVENT_RIGHT_LIST_ROW_ON_DRAG_END,
                        self.shifterBox, mouseButton, dragData, hasSameShifterBoxParent, wasDragSuccessful)
            end
        end
        _clearDragging(self)
    end, 50)
end

-- =================================================================================================================
-- == SHIFTERBOX PUBLIC FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
local ShifterBox = ZO_Object:Subclass()

--- Creates a new ShifterBox object with optional list headers
-- @param uniqueAddonName - the unique name of your addon
-- @param uniqueShifterBoxName - the unique name of this shifterBox (within your addon)
-- @param parentControl - the control reference to which the shifterBox should be added as a child
-- @param customSettings - OPTIONAL: override the default settings
-- @param dimensionOptions - OPTIONAL: directly provide dimensionOptions instead of calling :SetDimensions afterwards (must be table with: number width, number height)
-- @param anchorOptions - OPTIONAL: directly provide anchorOptions instead of calling :SetAnchor afterwards (must be table with: number whereOnMe, object anchorTargetControl, number whereOnTarget, number offsetX, number offsetY)
-- @param leftListEntries - OPTIONAL: directly provide entries for left listBox (a table or a function returning a table)
-- @param rightListEntries - OPTIONAL: directly provide entries for right listBox (a table or a function returning a table)
function ShifterBox:New(uniqueAddonName, uniqueShifterBoxName, parentControl, customSettings, anchorOptions, dimensionOptions, leftListEntries, rightListEntries)
    if existingShifterBoxes[uniqueAddonName] == nil then
        existingShifterBoxes[uniqueAddonName] = {}
    end
    local addonShifterBoxes = existingShifterBoxes[uniqueAddonName]
    assert(addonShifterBoxes[uniqueShifterBoxName] == nil, _errorText("ShifterBox with the unique identifier '%s' is already registered for the addon '%s'!", tos(uniqueShifterBoxName), tos(uniqueAddonName)))
    local obj = ZO_Object.New(self)
    obj.addonName = uniqueAddonName
    obj.shifterBoxName = uniqueShifterBoxName
    obj.shifterBoxControl = _createShifterBox(uniqueAddonName, uniqueShifterBoxName, parentControl)
    obj.shifterBoxSettings = _applyCustomSettings(obj, customSettings)
    _initShifterBoxControls(obj)
    _initShifterBoxHandlers(obj)
    -- initialize the ShifterBoxLists
    local leftControl = obj.shifterBoxControl:GetNamedChild("Left")
    local rightControl = obj.shifterBoxControl:GetNamedChild("Right")
    obj.leftList = ShifterBoxList:New(obj, leftControl, true)
    obj.rightList = ShifterBoxList:New(obj, rightControl, false)
    -- anchorOptions; if provided
    if anchorOptions then
        obj:SetAnchor(unpack(anchorOptions))
    end
    -- dimensionOptions; if provided
    if dimensionOptions then
        obj:SetDimensions(unpack(dimensionOptions))
    end
    -- leftListEntries; if provided
    if leftListEntries then
        obj:AddEntriesToLeftList(leftListEntries)
    end
    -- rightListEntries; if provided
    if rightListEntries then
        obj:AddEntriesToRightList(rightListEntries)
    end
    -- register the shifterBox in the internal list and return it
    addonShifterBoxes[uniqueShifterBoxName] = obj
    return addonShifterBoxes[uniqueShifterBoxName]
end

function ShifterBox:GetControl()
    return self.shifterBoxControl, self
end

--- Clears the current anchor(s) and sets a new one
function ShifterBox:SetAnchor(...)
    self.shifterBoxControl:ClearAnchors()
    self.shifterBoxControl:SetAnchor(...)
end

--- Sets the dimensions for the shifterBox
-- @param width - the width for the whole shifterBox
-- @param height - the height for the whole shifterBox (incl. headers if applicable)
function ShifterBox:SetDimensions(width, height)
    assert(type(width) == "number" and type(height) == "number", _errorText("width and height must be numeric values!"))
    -- height must be at least 4x the height of the arrows
    if height < 4 * ARROW_SIZE then height = 4 * ARROW_SIZE end
    local singleListWidth, arrowOffset, arrowAllOffset = _getListBoxWidthAndArrowOffset(width, height)
    local headerHeight = self.headerHeight
    local leftList = self.leftList
    local rightList = self.rightList
    local leftButtonAnchorOptions = {TOPLEFT, leftList.list, TOPRIGHT, 0, arrowOffset}
    local leftButtonAllAnchorOptions = {TOPLEFT, leftList.list, TOPRIGHT, 0, arrowAllOffset}
    local rightButtonAnchorOptions = {BOTTOMRIGHT, rightList.list, BOTTOMLEFT, -2, arrowOffset * -1} -- lower arrow requires negative offset
    local rightButtonAllAnchorOptions = {BOTTOMRIGHT, rightList.list, BOTTOMLEFT, -2, arrowAllOffset * -1} -- lower arrow requires negative offset
    _setListBoxDimensions(leftList, singleListWidth, height, self.headerHeight, leftButtonAnchorOptions, leftButtonAllAnchorOptions)
    _setListBoxDimensions(rightList, singleListWidth, height, self.headerHeight, rightButtonAnchorOptions, rightButtonAllAnchorOptions)
end

function ShifterBox:SetEnabled(enabled)
    self.leftList:SetEntriesEnabled(enabled)
    self.rightList:SetEntriesEnabled(enabled)
end

--- Sets the complete shifterBox to hidden, or shows it again
-- @param isHidden - whether the shifterBox should be hidden (boolean)
function ShifterBox:SetHidden(hidden)
    self.shifterBoxControl:SetHidden(hidden)
end

function ShifterBox:ShowCategory(categoryId)
    assert(categoryId ~= nil, _errorText("categoryId cannot be nil!"))
    ZO_ScrollList_ShowCategory(self.leftList.list, categoryId)
    ZO_ScrollList_ShowCategory(self.rightList.list, categoryId)
    _refreshFilters(self.leftList, self.rightList)
end

function ShifterBox:ShowOnlyCategory(categoryId)
    local leftList = self.leftList.list
    for currCategoryId in pairs(leftList.categories) do
        if currCategoryId == categoryId then
            ZO_ScrollList_ShowCategory(leftList, currCategoryId)
        else
            ZO_ScrollList_HideCategory(leftList, currCategoryId)
        end
    end
    local rightList = self.rightList.list
    for currCategoryId in pairs(rightList.categories) do
        if currCategoryId == categoryId then
            ZO_ScrollList_ShowCategory(rightList, currCategoryId)
        else
            ZO_ScrollList_HideCategory(rightList, currCategoryId)
        end
    end
    _refreshFilters(self.leftList, self.rightList, true)
end

function ShifterBox:ShowAllCategories()
    local leftList = self.leftList.list
    for categoryId in pairs(leftList.categories) do
        ZO_ScrollList_ShowCategory(leftList, categoryId)
    end
    local rightList = self.rightList.list
    for categoryId in pairs(rightList.categories) do
        ZO_ScrollList_ShowCategory(rightList, categoryId)
    end
    _refreshFilters(self.leftList, self.rightList)
end

function ShifterBox:HideCategory(categoryId)
    assert(categoryId ~= nil, _errorText("categoryId cannot be nil!"))
    ZO_ScrollList_HideCategory(self.leftList.list, categoryId)
    ZO_ScrollList_HideCategory(self.rightList.list, categoryId)
    _refreshFilters(self.leftList, self.rightList, true)
end

function ShifterBox:SelectEntryByKey(key)
    _selectEntry(self.leftList, key)
    _selectEntry(self.rightList, key)
end

function ShifterBox:SelectEntriesByKey(keys)
    _selectEntries(self.leftList, keys)
    _selectEntries(self.rightList, keys)
end

function ShifterBox:UnselectAllEntries()
    self.leftList:UnselectEntries()
    self.rightList:UnselectEntries()
end

function ShifterBox:RemoveEntryByKey(key)
    _removeEntryFromList(self.leftList, key)
    _removeEntryFromList(self.rightList, key)
end

function ShifterBox:RemoveEntriesByKey(keys)
    _removeEntriesFromList(self.leftList, keys)
    _removeEntriesFromList(self.rightList, keys)
end

-- ---------------------------------------------------------------------------------------------------------------------

function ShifterBox:RegisterCallback(shifterBoxEvent, callbackFunction)
    _assertValidShifterBoxEvent(shifterBoxEvent)
    assert(type(callbackFunction) == "function", _errorText("Invalid callbackFunction parameter of type '%s' provided! Must be of type 'function'.", type(callbackFunction)))
    -- register the callback with ESO
    local callbackIdentifier = _getUniqueShifterBoxEventName(self, shifterBoxEvent)
    CM:RegisterCallback(callbackIdentifier, callbackFunction)
end

function ShifterBox:UnregisterCallback(shifterBoxEvent, callbackFunction)
    _assertValidShifterBoxEvent(shifterBoxEvent)
    local callbackIdentifier = _getUniqueShifterBoxEventName(self, shifterBoxEvent)
    CM:RegisterCallback(callbackIdentifier, callbackFunction)
end

-- ---------------------------------------------------------------------------------------------------------------------

function ShifterBox:GetLeftListEntries(withCategoryId)
    return _getEntries(self.leftList, false, withCategoryId)
end

function ShifterBox:GetLeftListEntriesFull(withCategoryId)
    return _getEntries(self.leftList, true, withCategoryId)
end

function ShifterBox:AddEntryToLeftList(key, value, replace, categoryId)
    _addEntryToList(self.leftList, key, value, replace, self.rightList, categoryId)
end

function ShifterBox:AddEntriesToLeftList(entries, replace, categoryId)
    _addEntriesToList(self.leftList, entries, replace, self.rightList, categoryId)
end

function ShifterBox:MoveEntryToLeftList(key)
    _moveEntryToOtherList(self.rightList, key, self.leftList, self)
end

function ShifterBox:MoveEntriesToLeftList(keys)
    _moveEntriesToOtherList(self.rightList, keys, self.leftList, self)
end

function ShifterBox:MoveAllEntriesToLeftList()
    local keyset = {}
    for _, entry in pairs(self.rightList.list.data) do
        tins(keyset, entry.data.key)
    end
    _moveEntriesToOtherList(self.rightList, keyset, self.leftList, self)
end

function ShifterBox:ClearLeftList()
    _clearList(self.leftList)
end

-- ---------------------------------------------------------------------------------------------------------------------

function ShifterBox:GetRightListEntries(withCategoryId)
    return _getEntries(self.rightList, false, withCategoryId)
end

function ShifterBox:GetRightListEntriesFull(withCategoryId)
    return _getEntries(self.rightList, true, withCategoryId)
end

function ShifterBox:AddEntryToRightList(key, value, replace, categoryId)
    _addEntryToList(self.rightList, key, value, replace, self.leftList, categoryId)
end

function ShifterBox:AddEntriesToRightList(entries, replace, categoryId)
    _addEntriesToList(self.rightList, entries, replace, self.leftList, categoryId)
end

function ShifterBox:MoveEntryToRightList(key)
    _moveEntryToOtherList(self.leftList, key, self.rightList, self)
end

function ShifterBox:MoveEntriesToRightList(keys)
    _moveEntriesToOtherList(self.leftList, keys, self.rightList, self)
end

function ShifterBox:MoveAllEntriesToRightList()
    local keyset = {}
    for _, entry in pairs(self.leftList.list.data) do
        tins(keyset, entry.data.key)
    end
    _moveEntriesToOtherList(self.leftList, keyset, self.rightList, self)
end

function ShifterBox:ClearRightList()
    _clearList(self.rightList)
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Drag & drop operations -> Show dragged items at the cursor
function ShifterBox:UpdateCursorTLC(isHidden, draggedControl)
    if CURSORTLC == nil then _getCursorTLC() end
    if not CURSORTLC then return end
    CURSORTLC:ClearAnchors()
    CURSORTLC.label:ClearAnchors()
    local draggedData = self.currentDragData
    if not isHidden and draggedData ~= nil then
        local minLabelHeight = defaultListSettings.rowHeight
        local maxLabelWidth = 400
        local maxLabelHeight = 80

        CURSORTLC.shifterBox = self
        CURSORTLC:SetResizeToFitDescendents(true)

        local draggedControlText = draggedData._draggedText
        local draggedAdditionalText = draggedData._draggedAdditionalText
        local draggedAdditionalTextIsGiven = (draggedAdditionalText ~= nil and draggedAdditionalText ~= "") or false
        local textForLabel = draggedControlText
        local textWidth = GetStringWidthScaledPixels(ZoFontGame, draggedControlText, 1) + 2
        local textWidthAdditionalText = (draggedAdditionalTextIsGiven == true and (GetStringWidthScaledPixels(ZoFontGame, draggedAdditionalText, 1) + 2)) or 0
        if draggedAdditionalTextIsGiven and textWidthAdditionalText > 0 then
            if textWidthAdditionalText > textWidth then
                textWidth = textWidthAdditionalText
            end
            textForLabel = draggedControlText .. "\n" .. draggedAdditionalText
        end
        local textHeight = (draggedAdditionalTextIsGiven == true and (2 * minLabelHeight)) or minLabelHeight
--d(">draggedAdditionalText: " ..tos(draggedAdditionalText) .. ", textWidth: " .. tos(textWidth) .. ", textHeight: " ..tos(textHeight))

        CURSORTLC.label:SetText(textForLabel)
        CURSORTLC.label:SetWidth(textWidth)
        CURSORTLC.label:SetHeight(textHeight)
        CURSORTLC:SetWidth(textWidth)
        CURSORTLC:SetHeight(textHeight)

        local width, height = CURSORTLC.label:GetDimensions()
        if width > maxLabelWidth then width = maxLabelWidth end
        if height > maxLabelHeight then height = maxLabelHeight end
--d(">GuiMouse:isHidden: " ..tos(GuiMouse:IsHidden()) .. ", cursorTLC.width: " ..tos(CURSORTLC:GetWidth()) ..", cursorTLC.height: " ..tos(CURSORTLC:GetHeight()) .. ", text: " ..tos(textForLabel))

        CURSORTLC:SetDimensionConstraints(width, height, maxLabelWidth, maxLabelHeight)
        CURSORTLC:SetDrawTier(DT_HIGH)
        CURSORTLC:SetDrawLayer(DL_OVERLAY)
        CURSORTLC:SetDrawLevel(5)
        CURSORTLC:SetAlpha(0.8)

        local offsetX = draggedData._isFromLeftList and 10 or 35
        CURSORTLC:SetAnchor(LEFT, GuiMouse, RIGHT, offsetX, 0)
        CURSORTLC.label:SetAnchor(TOPLEFT, CURSORTLC, TOPLEFT, 0, 0)
        CURSORTLC.label:SetAnchor(BOTTOMRIGHT, CURSORTLC, BOTTOMRIGHT, 0, 0)
    else
        CURSORTLC.shifterBox = nil
        CURSORTLC:SetDimensions(0, 0)
        CURSORTLC.label:SetText("")
        CURSORTLC:SetDrawTier(DT_LOW)
        CURSORTLC:SetDrawLayer(DL_BACKGROUND)
        CURSORTLC:SetDrawLevel(0)
        CURSORTLC:SetAlpha(0)
    end
    CURSORTLC:SetHidden(isHidden)
    CURSORTLC:SetMouseEnabled(false)
end

-- =================================================================================================================
-- == LIBRARY API FUNCTIONS == --
-- -----------------------------------------------------------------------------------------------------------------
lib.DEFAULT_CATEGORY                    = DATA_DEFAULT_CATEGORY

--- Returns an existing ShifterBox instance
-- @param uniqueAddonName - a string identifier for the consuming addon
-- @param uniqueShifterBoxName - a string identifier for the specific shifterBox
-- @return an existing shifterBox instance or nil if not found with the passed names
function lib.GetShifterBox(uniqueAddonName, uniqueShifterBoxName)
    local addonShifterBoxes = existingShifterBoxes[uniqueAddonName]
    if addonShifterBoxes ~= nil then
        return addonShifterBoxes[uniqueShifterBoxName]
    end
    return nil
end

--- Returns the CT_CONTROL object of an existing ShifterBox instance
-- @param uniqueAddonName - a string identifier for the consuming addon
-- @param uniqueShifterBoxName - a string identifier for the specific shifterBox
-- @return an existing shifterBox CT_CONTROL object or nil if not found with the passed names
--         2nd return param: The shifterbox instance of that control or nil
function lib.GetControl(uniqueAddonName, uniqueShifterBoxName)
    local shifterBox = lib.GetShifterBox(uniqueAddonName, uniqueShifterBoxName)
    if shifterBox ~= nil then
        return shifterBox.shifterBoxControl, shifterBox
    end
    return nil, nil
end

function lib.Create(...)
    return ShifterBox:New(...)
end
setmetatable(lib, { __call = function(_, ...) return lib.Create(...) end })




------------------------------------------------------------------------------------------------------------------------
local function _OnAddOnLoaded(eventId, addonName)
    if addonName ~= LIB_IDENTIFIER then return end
    EM:UnregisterForEvent(LIB_IDENTIFIER .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)

    --Validation for customSettings - Prepare needed data and functions
    validationTypeToFunc = {
        ["boolean"] =           _assertBoolean,
        ["stringValueKey"] =    _assertStringValueKey,
        ["string"] =            _assertString,
        ["positiveNumber"] =    _assertPositiveNumber,
        ["function"] =          _assertFunction,
        ["sound"] =             _assertSound,
        ["table"] =             _assertTable,
    }

    --Register a callback to the close of any LAM panel to hide dragged control at the mouse cursor, e.g. if ESC key
    --was pressed during drag&drop, or if any other key closes the addon settings
    if LibAddonMenu2 ~= nil then
        CM:RegisterCallback("LAM-PanelClosed", _checkIfDraggedAndDisableUpdateHandler)
    end
end
EM:RegisterForEvent(LIB_IDENTIFIER .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, _OnAddOnLoaded)