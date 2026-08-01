--[[orderListBoxData = {
    type = "orderlistbox",
    name = "My OrderListBox", -- or string id or function returning a string
    listEntries = {
        [1] = {
            value = "Value of the entry", -- or number or boolean or function returning the value of this entry
            uniqueKey = 1, --number of the unique key of this list entry. This will not change if the order changes. Will be used to identify the entry uniquely
            text  = "Text of this entry", -- or string id or function returning a string (optional)
            tooltip = "Tooltip text shown at this entry", -- or string id or function returning a string (optional)
        },
        [2] = {...},
        ...
    },
    getFunc = function() return db.currentSortedListEntries end,
    setFunc = function(currentSortedListEntries) db.currentSortedListEntries = currentSortedListEntries doStuff() end,
    tooltip = "OrderListBox's tooltip text.", -- or string id or function returning a string (optional)
    width = "full", -- or "half" (optional)
    isExtraWide = false, -- or function returning a boolean (optional). Show the listBox as extra wide box
    minHeight = function() return db.minHeightNumber end, --or number for the minimum height of this control. Default: 125 (optional)
    maxHeight = function() return db.maxHeightNumber end, --or number for the maximum height of this control. Default: value of minHeight (optional)
    rowHeight = function() return db.rowHeightNumber end, --or number for the height of the row of the entries in listEntries. Default: 25 (optional)
    rowTemplate = "LAM2_OrderListBox_Widget_Scrolllist_Row", --String defining the XML virtual template control for a row of the listEntries (optional)
    rowFont = "ZoFontWinH4", --or function returning a String of the font to use for the row (optional),
    rowMaxLineCount = 1, --or function returning a number of the maximum text lines within the row. 1 = Only 1 text line, no wrapping, get#s truncated. (optional)
    rowSelectionTemplate = "ZO_ThinListHighlight", --String defining the XML virtual template control for the selection at a row of the listEntries (optional)
    rowSelectedCallback = function() doStuffOnSelection(rowControl, previouslySelectedData, selectedData, reselectingDuringRebuild) end, --An optional callback function when a row of the listEntries got selected (optional)
    rowHideCallback = function() doStuffOnHide(rowControl, currentRowData) end, --An optional callback function when a row of the listEntries got hidden (optional)
    dataTypeSelectSound = SOUNDS["NONE"], --or function returning a String of a sound from the global SOUNDS table. Will be played as any row containing the datatype (1) of the orderListBox will be selected (optional)
    dataTypeResetControlCallback = function doStuffOnReset(control) end, --An optional callback function when the datatype control gets reset. (optional)
    disableDrag = false, -- or function returning a boolean (optional). Disable the drag&drop of the rows
    disableButtons = false, -- or function returning a boolean (optional). Disable the move up/move down/move to top/move to bottom buttons
    showPosition = false, -- or function returning a boolean (optional). Show the position number in front of the list entry
    showValue = false, -- or function returning a boolean (optional). Show the value of the entry after the list entry text, surrounded by []
    showValueAtTooltip = false, -- or function returning a boolean (optional). Show the value of the entry after the tooltip text, surrounded by []
    addEntryDialog = { title="Add new entry", text="Enter new text here", textType=TEXT_TYPE_ALL, buttonTexture="", maxInputCharacters=0, specialCharacters={"a", "b", "c"}, selectAll=false, defaultText="Type text here", validatesText=false, validator = function(text) return type(text) == "string" end, instructions=table (example See line below) }, -- or function returning a table (optional). If the table exists: Add an "Add value" button to the list which opens a dialog. Inside the table you can pass in additional data and options to the ZO_Dialog dialog, e.g. title, text, editbox in dialog only accepts digits -> TEXT_TYPE_NUMERIC_UNSIGNED_INT, and other custom data
    --> example instructions = ZO_ValidNameInstructions:New(GetControl(self, "NameInstructions"), nil, { NAME_RULE_TOO_SHORT, NAME_RULE_CANNOT_START_WITH_SPACE, NAME_RULE_MUST_END_WITH_LETTER })
    addCustomEntryDialog = { title="Add new entry", buttonTexture="", customAddFunction = function(orderListBox, dialog) get new entry data from custom dialog XML controls and return text, value end, customSetupFunction = function(orderListBox, dialog) get the dialog's child controls which your XML tempalte added and populate entries into them, e.g. a dropdown/ZO_ComboBox end, validator = function(text) return type(text) == "string" end, XMLtemplate = "MyGlobalXMLDialogTemplateWithTitleAndCustomControls_InheritedFrom_ZO_CustomDialogBase_with_Accept_and_Cancel_buttons",  }, -- or function returning a table (optional). If the table exists: Add an "Add value" button to the list which opens a custom XML dialog, with your XML template. The dialog has 2 buttons, 1 for accept and 1 for decline. It can have custom controls like a dropdown/slider/exitBox. You must specify a customAddFunction(orderListBoxObject, dialog) which returns text, value of the new added entry!
    addEntryCallbackFunction = function(orderListBox, newAddedEntry, orderListBoxData) return true end, -- (optional) function returning a boolean (true = added, false = not added) called as the entry get's added via the add(Custom)EntryDialog
    showRemoveEntryButton = false, -- or function returning a boolean (optional). Show a button to remove the currently selected entry
    askBeforeRemoveEntry = false, -- or function returning a boolean (optional). If showRemoveEntryButton is enabled: Ask via a dialog if the entry should be removed
    removeEntryCheckFunction = function(orderListBox, selectedIndex, orderListBoxData) return true end, -- (optional) function returning a boolean (true = remove, false = keep) if the entry can be removed or not
    removeEntryCallbackFunction = function(orderListBox, selectedEntry, orderListBoxData) return true end, -- (optional) function returning a boolean (true = removed, false = not removed) called as the entry get's removed,
    disabled = function() return db.someBooleanSetting end, -- or boolean (optional)
    warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
    requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
    default = defaults.var, -- default value or function that returns the default value (optional)
    helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
    reference = "MyAddonOrderListBox" -- function returning String, or String unique global reference to control (optional)
}

------------------------------------------------------------------------------------------------------------------------
--[Custom Dialog examples]
------------------------------------------------------------------------------------------------------------------------
----Example1 - Simple label at dialog
------addCustomEntryDialog.XMLtemplate:
            <TopLevelControl name="MyGlobalXMLDialogTemplateWithTitleAndCustomControls" inherits="ZO_CustomDialogBase" mouseEnabled="true" virtual="true">
                <OnInitialized>
                </OnInitialized>
                <Controls>
                    <!-- 1 custom control label with child name "Value" here -->
                    <Label name="$(parent)Value" text="Hello!" verticalAlignment="CENTER" font="ZoFontWinH5" color="INTERFACE_COLOR_TYPE_TEXT_COLORS:INTERFACE_TEXT_COLOR_CONTEXT_HIGHLIGHT" maxLineCount="1">
                        <Anchor point="TOPLEFT" relativePoint="TOPLEFT" offsetX="0" />
                    </Label>
                    <!-- 2 default buttons - mandatory! -->
                    <Control name="$(parent)Cancel" inherits="ZO_CustomDialogButton"/>
                    <Control name="$(parent)Accept" inherits="ZO_CustomDialogButton"/>
                </Controls>
            </TopLevelControl>

------addCustomEntryDialog.customAddFunction:
            customAddFunction = function(orderListBox, dialog)
                --Get the child control "Value" -> the label
                local value = dialog:GetNamedChild("Value")
                if value then
                    --Return the label's text as newText for the entry, and the value = nil (will be set automatically to current #listEntries + 1, if missing in returned 2nd parameter)
                    return value:GetText(), nil
                end
            end,


----Example2 - ZO_Combobox at dialog
------addCustomEntryDialog.XMLtemplate:
            <TopLevelControl name="MyGlobalXMLDialogTemplateWithTitleAndCustomControls" inherits="ZO_CustomDialogBase" mouseEnabled="true" virtual="true">
                <OnInitialized>
                </OnInitialized>
                <Controls>
                    <Control name="$(parent)Value" inherits="ZO_ComboBox" mouseEnabled="true">
                        <Dimensions x="350" y="20" />
                        <Anchor point="TOPLEFT" relativePoint="TOPLEFT" offsetX="30" offsetY="60" />
                    </Control>
                    <Control name="$(parent)Cancel" inherits="ZO_CustomDialogButton"/>
                    <Control name="$(parent)Accept" inherits="ZO_CustomDialogButton"/>
                </Controls>
            </TopLevelControl>

------addCustomEntryDialog.customAddFunction:
            customAddFunction = function(orderListBox, dialog)
                local comboBox = dialog:GetNamedChild("Value")
                if comboBox then
                    d(">found combobox")
                    local dropdown = ZO_ComboBox_ObjectFromContainer(comboBox)
                    local selectedItem = dropdown:GetSelectedItemData()
                    if selectedItem ~= nil then
                        d(">found combobox selectedItemData")
                        local data = selectedItem.data or selectedItem
                        return data.label or data.name or data.guildName, data.value or data.guildId
                    end
                end
            end,

------addCustomEntryDialog.customSetupFunction:
            customSetupFunction = function(orderListBox, dialog)
                local data = dialog.data
                local comboBoxControl = dialog:GetNamedChild("Value")
                if comboBoxControl then
                    d(">found combobox")
                    local dropdown = ZO_ComboBox_ObjectFromContainer(comboBoxControl)
                    dropdown:SetSortsItems(false)
                    dropdown:SetDropdownFont("ZoFontHeader")
                    dropdown:SetSpacing(8)
                    --Add current guilds to the dropdown
                    local function OnCategorySelectionChanged(control, name, entry, selectionChanged)
                        d("Selected guild: " .. tostring(entry.name))
                    end
                    for guildIndex=1, GetNumGuilds(), 1 do
                        local guildId = GetGuildId(guildIndex)
                        local guildName = GetGuildName(guildId)
                        local entry = dropdown:CreateItemEntry(guildName, OnCategorySelectionChanged)
                        entry.guildId = guildId
                        entry.guildIndex = guildIndex
                        entry.name = guildName
                        dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
                    end
                end
            end,

]]

local widgetVersion = 15
local LAM = LibAddonMenu2
local util = LAM.util
local em = EVENT_MANAGER
local wm = WINDOW_MANAGER
local cm = CALLBACK_MANAGER

local LAMgetStringFromValue = util.GetStringFromValue
local LAMgetDefaultValue = util.GetDefaultValue

local orderListBoxNameTemplate            = "LAMOrderListBox_%s"
local orderListBoxAddNewEntryDialogSuffix = "AddNewEntryDialog"
local orderListBoxAskBeforeRemoveEntryDialogSuffix = "AskBeforeRemoveEntryDialog"
local orderListBoxAddNewEntryButtonSuffix = "AddNewEntryButton"
local orderListBoxRemoveEntryButtonSuffix = "RemoveEntryButton"
local orderListBoxCounter                 = 0

--Translations
local moveText = GetString(SI_HOUSINGEDITORCOMMANDTYPE1)
local moveTextLower = string.lower(moveText)
local translations = {
    ["de"] = {
        UP              = "Hoch " .. moveTextLower,
        DOWN            = "Herrunter " .. moveTextLower,
        TOTAL_UP        = "Zum Anfang " .. moveTextLower,
        TOTAL_DOWN      = "Zum Ende " .. moveTextLower,
        ADD_ENTRY       = "Eintrag hinzufügen",
        ADD_ENTRY_DESC  = "Wert eingeben:",
        REMOVE_ENTRY    = "Eintrag entfernen",
        REMOVE_ENTRY_DESC = "Selektierten Eintrag wirklich entfernen?",
    },
    ["en"] = {
        UP              = moveText .. " up",
        DOWN            = moveText .. " down",
        TOTAL_UP        = moveText .. " to top",
        TOTAL_DOWN      = moveText .. " to bottom",
        ADD_ENTRY       = "Add entry",
        ADD_ENTRY_DESC  = "Enter value:",
        REMOVE_ENTRY    = "Remove entry",
        REMOVE_ENTRY_DESC = "Really remove selected entry?",
    },
    ["es"] = {
        UP              = "Mover hacia arriba",
        DOWN            = "Mover hacia abajo",
        TOTAL_UP        = "Mover todo hacia arriba",
        TOTAL_DOWN      = "Mover todo hacia abajo",
    },
    ["fr"] = {
        UP              = moveText .. " en haut",
        DOWN            = moveText .. " en bas",
        TOTAL_UP        = moveText .. " jusqu'au sommet",
        TOTAL_DOWN      = moveText .. " vers le bas",
    },
    ["jp"] = {
        UP              = moveText .. " 上",
        DOWN            = moveText .. " 下へ",
        TOTAL_UP        = moveText .. " 頂点に",
        TOTAL_DOWN      = moveText .. " 一番下に",
    },
    ["ru"] = {
        UP              = moveText .. " вверх",
        DOWN            = moveText .. " вниз",
        TOTAL_UP        = moveText .. " наверх",
        TOTAL_DOWN      = moveText .. " ко дну",
    },
    ["zh"] = {
        UP              = "提升",
        DOWN            = "向下移动",
        TOTAL_UP        = "全部向上移动",
        TOTAL_DOWN      = "全部向下移动",
    },
}
--Widget constants
local widgetPrefix = "LAM2_OrderListBox_Widget"
local widgetCursorTLCName = widgetPrefix .. "_Cursor_TLC"

--Error constants
local errorTexts = {
    ["no_line_text_given"]              = "No text given for this line",
    ["no_list_entries"]                 = "List entries are empty!",
    ["list_entry_no_table"]             = "List entry is no table, index: \'%s\'",
    ["list_entry_field_missing"]        = "List entry field is missing, index: \'%s\' - field: \'%s\'!",
    ["list_entry_field_format_wrong"]   = "List entry field format is wrong, index: \'%s\' - field: \'%s\'=%s. Needs to be: \'%s\'!",
}

local lang = string.lower(GetCVar("Language.2"))
local translation = (translations[lang] ~= nil and translations[lang]) or translations["en"]

--Event handler constants
local EVENT_HANDLER_NAMESPACE = widgetPrefix  .. "_Event"
local globalMouseDown   = "_GLOBAL_MOUSE_DOWN"
local globalMouseUp     = "_GLOBAL_MOUSE_UP"

--Constants visuals
local LAM_SORT_LIST_BOX_SCROLL_LIST_DATATYPE = 1

local SORT_LIST_ROW_DEFAULT_HEIGHT          = 25
local SORT_LIST_ROW_DEFAULT_FONT            = "ZoFontWinH4"
local SORT_LIST_ROW_DEFAULT_MAXLINES        = 1
local SORT_LIST_ROW_TEMPLATE_NAME           = widgetPrefix .. "_Scrolllist_Row" --"ZO_SelectableLabel"
local SORT_LIST_ROW_SELECTION_TEMPLATE_NAME = "ZO_ThinListHighlight"

local MIN_HEIGHT                            = SORT_LIST_ROW_DEFAULT_HEIGHT * 5

local mouseCursorHand           = MOUSE_CURSOR_UI_HAND
local mouseCursorDoNotCare      = MOUSE_CURSOR_DO_NOT_CARE
local mouseCursorResizeNS       = MOUSE_CURSOR_RESIZE_NS

local scrollboxUpTexture        = "/esoui/art/buttons/scrollbox_uparrow_%s.dds"
local scrollboxDownTexture      = "/esoui/art/buttons/scrollbox_downarrow_%s.dds"
local scrollbarEndArrowTexture  = "/esoui/art/chatwindow/chat_scrollbar_endarrow_%s.dds"

local cursorTLC
local cursorTLCLabel

------------------------------------------------------------------------------------------------------------------------
--Local helper functions
------------------------------------------------------------------------------------------------------------------------
--Error handling
local function errorOutput(errorTextName, values, buildText)
    buildText = buildText or false
    local errorOutputText = errorTexts[errorTextName]
    if errorOutputText and errorOutputText ~= "" then
        if values ~= nil then
            errorOutputText = string.format(errorOutputText, unpack(values))
        end
        errorOutputText = "["..widgetPrefix .. "] ERROR - " .. errorOutputText
        if buildText then
            return errorOutputText
        else
            d(errorOutputText)
        end
    end
end

local function buildErrorOutput(errorTextName, values)
    return errorOutput(errorTextName, values, true)
end


local function checkOrderListBoxEntriesForCorrectFormat(listEntries)
    assert(listEntries ~= nil, buildErrorOutput("no_list_entries", nil))
    for idx, listEntry in ipairs(listEntries) do
        assert(type(listEntry) == "table", buildErrorOutput("list_entry_no_table", {idx}))
        local uniqueKey = listEntry.uniqueKey
        assert(uniqueKey ~= nil, buildErrorOutput("list_entry_field_missing", {idx, "uniqueKey"}))
        assert(type(uniqueKey) == "number", buildErrorOutput("list_entry_field_format_wrong", {idx, "uniqueKey", tostring(uniqueKey), "number"}))
        local value = listEntry.value
        assert(value ~= nil, buildErrorOutput("list_entry_field_missing", {idx, "value"}))
        local textVar = listEntry.text
        assert(textVar ~= nil, buildErrorOutput("list_entry_field_missing", {idx, "text"}))
    end
end

--Functions of the cursor UI related TLC
local function setMouseCursor(cursorName)
    wm:SetMouseCursor(cursorName)
end

local function getCursorTLC()
    cursorTLC = wm:GetControlByName(widgetCursorTLCName, nil)
    cursorTLCLabel = GetControl(cursorTLC, "Label")
    cursorTLC:ClearAnchors()
    cursorTLC:SetDimensions(0, 0)
    cursorTLC:SetResizeToFitDescendents(true)
end

--Functions of the listBox data table
local function getShowPositionInfoFromListBoxData(orderListBoxData)
    local showPosition = (orderListBoxData.showPosition ~= nil and LAMgetDefaultValue(orderListBoxData.showPosition)) or false
    return showPosition
end

local function getRowInfoFromOrderListBoxData(orderListBoxData)
    local rowHeight = (orderListBoxData.rowHeight and LAMgetDefaultValue(orderListBoxData.rowHeight)) or SORT_LIST_ROW_DEFAULT_HEIGHT
    local rowTemplate = (orderListBoxData.rowTemplate and LAMgetDefaultValue(orderListBoxData.rowTemplate)) or SORT_LIST_ROW_TEMPLATE_NAME
--d("[LAMOrderListBox]rowTemplate: " ..tostring(rowTemplate))
    local rowFont = (orderListBoxData.rowFont and LAMgetDefaultValue(orderListBoxData.rowFont)) or SORT_LIST_ROW_DEFAULT_FONT
    local rowMaxLineCount = (orderListBoxData.rowMaxLineCount and LAMgetDefaultValue(orderListBoxData.rowMaxLineCount)) or SORT_LIST_ROW_DEFAULT_MAXLINES
    local rowSelectionTemplate = (orderListBoxData.rowSelectionTemplate and LAMgetDefaultValue(orderListBoxData.rowSelectionTemplate)) or SORT_LIST_ROW_SELECTION_TEMPLATE_NAME
    local rowSelectedCallback = (orderListBoxData.rowSelectedCallback and LAMgetDefaultValue(orderListBoxData.rowSelectedCallback)) or nil
    local dataTypeSelectSound = (orderListBoxData.dataTypeSelectSound and LAMgetDefaultValue(orderListBoxData.dataTypeSelectSound)) or nil
    local rowHideCallback = (orderListBoxData.rowHideCallback and LAMgetDefaultValue(orderListBoxData.rowHideCallback)) or nil
    local dataTypeResetControlCallback = (orderListBoxData.dataTypeResetControlCallback and LAMgetDefaultValue(orderListBoxData.dataTypeResetControlCallback)) or nil
    return rowHeight, rowTemplate, rowFont, rowMaxLineCount, rowSelectionTemplate, rowSelectedCallback, rowHideCallback, dataTypeSelectSound, dataTypeResetControlCallback
end

local function getShowValueInfoFromListBoxData(orderListBoxData)
    local showValue = (orderListBoxData.showValue ~= nil and LAMgetDefaultValue(orderListBoxData.showValue)) or false
    local showValueAtTooltip = (orderListBoxData.showValueAtTooltip ~= nil and LAMgetDefaultValue(orderListBoxData.showValueAtTooltip)) or false
    return showValue, showValueAtTooltip
end

local function getDisabledInfoFromListBoxData(orderListBoxData)
    local disabledDrag      = (orderListBoxData.disableDrag and LAMgetDefaultValue(orderListBoxData.disableDrag)) or false
    local disableButtons    = (orderListBoxData.disableButtons and LAMgetDefaultValue(orderListBoxData.disableButtons)) or false
    return disabledDrag, disableButtons
end

--Update & disabled
local function updateButtonsEnabledState(control, areButtonsDisabled, orderListBoxData, buttonMoveUpControl, buttonMoveDownControl, buttonMoveTotalUpControl, buttonMoveTotalDownControl)
    if not control then return end
    if orderListBoxData == nil or buttonMoveUpControl == nil or buttonMoveDownControl  == nil or buttonMoveTotalUpControl  == nil or buttonMoveTotalDownControl == nil then
        local orderListBox  = control.orderListBox
        orderListBoxData = orderListBox.orderListBoxData
        buttonMoveUpControl, buttonMoveDownControl, buttonMoveTotalUpControl, buttonMoveTotalDownControl = orderListBox.moveUpButton, orderListBox.moveDownButton, orderListBox.moveTotalUpButton, orderListBox.moveTotalDownButton
    end
    if areButtonsDisabled == nil then
        areButtonsDisabled = orderListBoxData ~= nil and select(2, getDisabledInfoFromListBoxData(orderListBoxData))
    end
    if areButtonsDisabled == nil then areButtonsDisabled = false end
    local mouseEnabled = not areButtonsDisabled

    buttonMoveUpControl:SetHidden(areButtonsDisabled)
    buttonMoveUpControl:SetMouseEnabled(mouseEnabled)
    buttonMoveDownControl:SetHidden(areButtonsDisabled)
    buttonMoveDownControl:SetMouseEnabled(mouseEnabled)
    buttonMoveTotalUpControl:SetHidden(areButtonsDisabled)
    buttonMoveTotalUpControl:SetMouseEnabled(mouseEnabled)
    buttonMoveTotalDownControl:SetHidden(areButtonsDisabled)
    buttonMoveTotalDownControl:SetMouseEnabled(mouseEnabled)
end

local function updateRemoveEntryEnabledState(control)
    if control.RemoveEntryButton == nil then return end
    control.RemoveEntryButton:SetMouseEnabled(ZO_ScrollList_GetSelectedDataIndex(control.orderListBox.scrollListControl) ~= nil)
end

local function updateDisabledStateOfControls(control, disable)
    local enabledState = not disable
    control:SetMouseEnabled(enabledState)
    local orderListBox  = control.orderListBox
    local scrollList    = control.orderListBox.scrollListControl

    scrollList:SetMouseEnabled(enabledState)

    orderListBox.disabled = disable
    local areButtonsDisabled = disable
    --Hide the buttons as no entry was selected, as we currently are building the LAM controls.
    --Or after re-enabling the LAM control again via the UpdateDisabled function and no entry is selected.
    if areButtonsDisabled == false and (control.isBuilding == true or (scrollList and scrollList.selectedDataIndex == nil)) then
        areButtonsDisabled = true
    elseif areButtonsDisabled == false then
        areButtonsDisabled = orderListBox.areButtonsDisabled
    end
    if control.AddNewValueButton ~= nil then
        control.AddNewValueButton:SetMouseEnabled(enabledState)
    end
    updateRemoveEntryEnabledState(control)

    updateButtonsEnabledState(control, areButtonsDisabled, orderListBox.orderListBoxData, orderListBox.moveUpButton, orderListBox.moveDownButton, orderListBox.moveTotalUpButton, orderListBox.moveTotalDownButton)

    --Disable scrollbar
    ZO_ScrollList_SetUseScrollbar(scrollList, enabledState)
    --Redraw the scrolllist
    ZO_ScrollList_Commit(scrollList)
end

local function updateOrderListBoxEntries(control, value)
    --d("updateOrderListBoxEntries")
    local orderListBox = control.orderListBox
    orderListBox.orderListBoxData.listEntries = value
    --Update the order list now with new populated masterlist
    orderListBox.masterList = orderListBox:Populate(orderListBox.orderListBoxData)
    orderListBox:UpdateScrollList(orderListBox.scrollListControl, orderListBox.masterList, LAM_SORT_LIST_BOX_SCROLL_LIST_DATATYPE, orderListBox)

    updateRemoveEntryEnabledState(control)
end

--Drag & drop functions
local function clearDragging(selfVar)
    selfVar.draggingEntryId = nil
    selfVar.draggingSortListContents = nil
    selfVar.draggingText = nil
    selfVar.draggingUpdateTime = nil
    selfVar.mouseButtonPressed = nil
end

local function disableOnUpdateHandlerAndResetMouseCursor(orderListBoxObject)
    em:UnregisterForEvent(EVENT_HANDLER_NAMESPACE .. globalMouseDown, EVENT_GLOBAL_MOUSE_DOWN)
    em:UnregisterForEvent(EVENT_HANDLER_NAMESPACE .. globalMouseUp, EVENT_GLOBAL_MOUSE_UP)
    orderListBoxObject.scrollListControl:SetHandler("OnUpdate", nil)

    --Hide the label control at the cursor again
    orderListBoxObject:UpdateCursorTLC(true, nil)
end

local function abortDragging(orderListBoxObject)
    disableOnUpdateHandlerAndResetMouseCursor(orderListBoxObject)
    clearDragging(orderListBoxObject)
end

local function checkIfDraggedAndDisableUpdateHandler(lamPanel)
    if cursorTLC == nil then getCursorTLC() end
    if not cursorTLC then return end
    local orderListBoxObject = cursorTLC.orderListBox
    if orderListBoxObject == nil or orderListBoxObject.draggingEntryId == nil then return end
    abortDragging(orderListBoxObject)
    setMouseCursor(mouseCursorDoNotCare)
end


local function UpdateDisabled(control)
    local dataDisabled = control.data.disabled
    local disable = (dataDisabled ~= nil and LAMgetDefaultValue(dataDisabled)) or false
    if disable then
        control.label:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
    else
        control.label:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    end
    local orderListBox = control.orderListBox
    abortDragging(orderListBox)

    updateDisabledStateOfControls(control, disable)
end

local function UpdateValue(control, forceDefault, value)
--d(">UpdateValue - value: " ..tostring(value))
    local requestRefresh = false
    if forceDefault then --if we are forcing defaults
        value = LAMgetDefaultValue(control.data.default)
        control.data.setFunc(value)
    elseif value then
        control.data.setFunc(value)
        requestRefresh = true
    else
        value = control.data.getFunc()
    end
    updateOrderListBoxEntries(control, value)
    if requestRefresh == true then
        --after setting this value, let's refresh the others to see if any should be disabled or have their settings changed
        util.RequestRefreshIfNeeded(control)
    end
end

------------------------------------------------------------------------------------------------------------------------
--OrderListBox class
------------------------------------------------------------------------------------------------------------------------
local OrderListBox = ZO_Object:Subclass()

function OrderListBox:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end


function OrderListBox:Initialize(panel, control, orderListBoxData)
    --local combobox = control.combobox
    --local selfVar = self
    self.panel = panel
    self.control = control
    self.name = control.orderListBoxName

    self.orderListBoxData = orderListBoxData

    --Attributes of the orderListBoxData -> Set default values
    -->Will be updated within self:Create() function (from orderListBoxData)
    self.disabled = false
    self.areButtonsDisabled = false
    self.isDragDisabled = false
    self.showPosition = false
    self.showValue = false
    self.showValueAtTooltip = false
    self.rowHeight = SORT_LIST_ROW_DEFAULT_HEIGHT
    self.rowTemplate = SORT_LIST_ROW_TEMPLATE_NAME
    self.rowFont = SORT_LIST_ROW_DEFAULT_FONT
    self.rowMaxLineCount = SORT_LIST_ROW_DEFAULT_MAXLINES
    self.rowSelectionTemplate = SORT_LIST_ROW_SELECTION_TEMPLATE_NAME
    self.rowSelectedCallback = nil
    self.rowHideCallback = nil
    self.dataTypeSelectSound = nil
    self.dataTypeResetControlCallback = nil

    --Create the ZO_ScrollList with the move up and down buttons
    self.scrollListControl, self.moveUpButton, self.moveDownButton, self.moveTotalUpButton, self.moveTotalDownButton = self:Create(control, orderListBoxData)
end

--Create the scroll list and it's dataType, set the init values etc. Control is the LAM "container" containing the ZO_ScrollList we create here
function OrderListBox:Create(control, orderListBoxData)
    --d("[LAM2]OrderListBox:Create")
    local selfVar = self
    local controlContainer = control.container
    local controlName = control:GetName()

    --OrderListBox -> ZO_ScrollList control
    local scrollListControl = wm:CreateControlFromVirtual(controlName .. "_OrderListBox", control, "ZO_ScrollList")
    local controlHeight = control:GetHeight()
    local widthXMinus = (orderListBoxData.width=="half" and 16) or 12
    local width = controlContainer:GetWidth() - widthXMinus
    scrollListControl:SetDimensions(width, controlHeight)
    scrollListControl:SetAnchor(TOPLEFT, controlContainer, TOPLEFT)
    scrollListControl:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, (widthXMinus * -1), 0)
    scrollListControl:SetHidden(false)

    --Add the move up and move down button controls at the right of the ZO_ScrollList
    local function onButtonClicked(buttonCtrl, mouseButton, ctrl, alt, shift, command, isUp, moveToTopOrBottom)
        --d(">Clicked - isUp: " ..tostring(isUp))
        --Left mouse clicked?
        if mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then return end
        --Is any item selected?
        local selectedEntry = ZO_ScrollList_GetSelectedData(scrollListControl)
        if selectedEntry == nil then return end
        local selectedIndex = ZO_ScrollList_GetSelectedDataIndex(scrollListControl)
        --Move up or down button clicked
        if isUp then
            --Is the selected entry the most top entry already?
            if selectedIndex == 1 then return end
        else
            --Is the selected entry the most bottom entry already?
            if selectedIndex == #scrollListControl.data then return end
        end
        selfVar:MoveItem(selectedIndex, isUp, nil, moveToTopOrBottom)
    end

    local buttonMoveUpControl = wm:CreateControl(controlName .. "_ButtonMoveUp", scrollListControl, CT_BUTTON)
    buttonMoveUpControl:SetDimensions(16, 16)
    buttonMoveUpControl:SetNormalTexture(string.format(scrollboxUpTexture, "up"))
    buttonMoveUpControl:SetMouseOverTexture(string.format(scrollboxUpTexture, "over"))
    buttonMoveUpControl:SetPressedMouseOverTexture(string.format(scrollboxUpTexture, "down"))
    buttonMoveUpControl:SetPressedTexture(string.format(scrollboxUpTexture, "down"))
    buttonMoveUpControl:SetDisabledTexture(string.format(scrollboxUpTexture, "up_disabled"))
    buttonMoveUpControl:SetPressedOffset(2, 2)
    buttonMoveUpControl:SetAnchor(LEFT, scrollListControl, RIGHT, 0, -16)
    buttonMoveUpControl:SetHidden(true)
    buttonMoveUpControl:SetClickSound("Click")
    buttonMoveUpControl.data = {tooltipText = LAMgetStringFromValue(translation.UP)}
    buttonMoveUpControl:SetHandler("OnMouseEnter", function(button)
        if selfVar.disabled then return end
        ZO_Options_OnMouseEnter(button)
        setMouseCursor(mouseCursorHand)
    end)
    buttonMoveUpControl:SetHandler("OnMouseExit", function(button)
        if selfVar.disabled then return end
        ZO_Options_OnMouseExit(button)
        setMouseCursor(mouseCursorDoNotCare)
    end)
    buttonMoveUpControl:SetHandler("OnClicked", function(buttonCtrl, button, ctrl, alt, shift, command)
        if selfVar.disabled then return end
        onButtonClicked(buttonCtrl, button, ctrl, alt, shift, command, true, false)
    end)
    buttonMoveUpControl:SetMouseEnabled(false)

    local buttonMoveDownControl = wm:CreateControl(controlName .. "_ButtonMoveDown", scrollListControl, CT_BUTTON)
    buttonMoveDownControl:SetDimensions(16, 16)
    buttonMoveDownControl:SetNormalTexture(string.format(scrollboxDownTexture, "up"))
    buttonMoveDownControl:SetMouseOverTexture(string.format(scrollboxDownTexture, "over"))
    buttonMoveDownControl:SetPressedMouseOverTexture(string.format(scrollboxDownTexture, "down"))
    buttonMoveDownControl:SetPressedTexture(string.format(scrollboxDownTexture, "down"))
    buttonMoveDownControl:SetDisabledTexture(string.format(scrollboxDownTexture, "up_disabled"))
    buttonMoveDownControl:SetPressedOffset(2, 2)
    buttonMoveDownControl:SetAnchor(LEFT, scrollListControl, RIGHT, 0, 12)
    buttonMoveDownControl:SetHidden(true)
    buttonMoveDownControl:SetClickSound("Click")
    buttonMoveDownControl.data = {tooltipText = LAMgetStringFromValue(translation.DOWN)}
    buttonMoveDownControl:SetHandler("OnMouseEnter", function(button)
        if selfVar.disabled then return end
        ZO_Options_OnMouseEnter(button)
        setMouseCursor(mouseCursorHand)
    end)
    buttonMoveDownControl:SetHandler("OnMouseExit", function(button)
        if selfVar.disabled then return end
        ZO_Options_OnMouseExit(button)
        setMouseCursor(mouseCursorDoNotCare)
    end)
    buttonMoveDownControl:SetHandler("OnClicked", function(buttonCtrl, button, ctrl, alt, shift, command)
        if selfVar.disabled then return end
        onButtonClicked(buttonCtrl, button, ctrl, alt, shift, command, false, false)
    end)
    buttonMoveDownControl:SetMouseEnabled(false)

    local buttonMoveTotalUpControl = wm:CreateControl(controlName .. "_ButtonMoveTotalUp", scrollListControl, CT_BUTTON)
    buttonMoveTotalUpControl:SetDimensions(16, 16)
    buttonMoveTotalUpControl:SetNormalTexture(string.format(scrollbarEndArrowTexture, "up"))
    buttonMoveTotalUpControl:SetMouseOverTexture(string.format(scrollbarEndArrowTexture, "over"))
    buttonMoveTotalUpControl:SetPressedMouseOverTexture(string.format(scrollbarEndArrowTexture, "down"))
    buttonMoveTotalUpControl:SetPressedTexture(string.format(scrollbarEndArrowTexture, "down"))
    buttonMoveTotalUpControl:SetDisabledTexture(string.format(scrollbarEndArrowTexture, "disabled"))
    buttonMoveTotalUpControl:SetPressedOffset(2, 2)
    buttonMoveTotalUpControl:SetTextureCoords(1, 0, 1, 0) -- rotate by 180° so the texture points up
    buttonMoveTotalUpControl:SetAnchor(BOTTOM, buttonMoveUpControl, TOP, 0, -4)
    buttonMoveTotalUpControl:SetHidden(true)
    buttonMoveTotalUpControl:SetClickSound("Click")
    buttonMoveTotalUpControl.data = {tooltipText = LAMgetStringFromValue(translation.TOTAL_UP)}
    buttonMoveTotalUpControl:SetHandler("OnMouseEnter", function(button)
        if selfVar.disabled then return end
        ZO_Options_OnMouseEnter(button)
        setMouseCursor(mouseCursorHand)
    end)
    buttonMoveTotalUpControl:SetHandler("OnMouseExit", function(button)
        if selfVar.disabled then return end
        ZO_Options_OnMouseExit(button)
        setMouseCursor(mouseCursorDoNotCare)
    end)
    buttonMoveTotalUpControl:SetHandler("OnClicked", function(buttonCtrl, button, ctrl, alt, shift, command)
        if selfVar.disabled then return end
        onButtonClicked(buttonCtrl, button, ctrl, alt, shift, command, true, true)
    end)
    buttonMoveTotalUpControl:SetMouseEnabled(false)

    local buttonMoveTotalDownControl = wm:CreateControl(controlName .. "_ButtonMoveTotalDown", scrollListControl, CT_BUTTON)
    buttonMoveTotalDownControl:SetDimensions(16, 16)
    buttonMoveTotalDownControl:SetNormalTexture(string.format(scrollbarEndArrowTexture, "up"))
    buttonMoveTotalDownControl:SetMouseOverTexture(string.format(scrollbarEndArrowTexture, "over"))
    buttonMoveTotalDownControl:SetPressedMouseOverTexture(string.format(scrollbarEndArrowTexture, "down"))
    buttonMoveTotalDownControl:SetPressedTexture(string.format(scrollbarEndArrowTexture, "down"))
    buttonMoveTotalDownControl:SetDisabledTexture(string.format(scrollbarEndArrowTexture, "disabled"))
    buttonMoveTotalDownControl:SetPressedOffset(2, 2)
    buttonMoveTotalDownControl:SetAnchor(TOP, buttonMoveDownControl, BOTTOM, 0, 4)
    buttonMoveTotalDownControl:SetHidden(true)
    buttonMoveTotalDownControl:SetClickSound("Click")
    buttonMoveTotalDownControl.data = {tooltipText = LAMgetStringFromValue(translation.TOTAL_DOWN)}
    buttonMoveTotalDownControl:SetHandler("OnMouseEnter", function(button)
        if selfVar.disabled then return end
        ZO_Options_OnMouseEnter(button)
        setMouseCursor(mouseCursorHand)
    end)
    buttonMoveTotalDownControl:SetHandler("OnMouseExit", function(button)
        if selfVar.disabled then return end
        ZO_Options_OnMouseExit(button)
        setMouseCursor(mouseCursorDoNotCare)
    end)
    buttonMoveTotalDownControl:SetHandler("OnClicked", function(buttonCtrl, button, ctrl, alt, shift, command)
        if selfVar.disabled then return end
        onButtonClicked(buttonCtrl, button, ctrl, alt, shift, command, false, true)
    end)
    buttonMoveTotalDownControl:SetMouseEnabled(false)

    --Are the buttons disabled?
    self.isDragDisabled, self.areButtonsDisabled = getDisabledInfoFromListBoxData(orderListBoxData)
    updateButtonsEnabledState(control, self.areButtonsDisabled, orderListBoxData, buttonMoveUpControl, buttonMoveDownControl, buttonMoveTotalUpControl, buttonMoveTotalDownControl)

    --Show the position number in front of the row entry text?
    self.showPosition = getShowPositionInfoFromListBoxData(orderListBoxData)

    --OrderListBox datatype and data population + commit to show the entries
    --[[
		https://github.com/esoui/esoui/blob/e554eb0d0a24ad9b49c0a775a1e18babf8ef54d4/esoui/libraries/zo_templates/scrolltemplates.lua#L789
		ZO_ScrollList_AddDataType(control self, number typeId, string templateName, number height, function setupCallback, function hideCallback, dataTypeSelectSound, function:nilable resetControlCallback)
		This function registers a data type for the list to display.
		The dataTypeId must be unique to this data type. It's okay if data types in completely different scroll lists have the same identifiers.
		The templateName is the name of the virtual control that will be used to create list item controls for this data type.
		The setupFunction is a function that will be used to set up a list item control. It will be passed two arguments: the list item control, and the list item data.
		The dataTypeSelectSound will be played when a row of this type is selected.
		The resetControlCallback will be called when a list item control goes out of use.
	]]
    local dataTypeId = LAM_SORT_LIST_BOX_SCROLL_LIST_DATATYPE

    --Get the row XML templates and callback functions, sound etc.
    self.rowHeight, self.rowTemplate, self.rowFont, self.rowMaxLineCount, self.rowSelectionTemplate, self.rowSelectedCallback, self.rowHideCallback, self.dataTypeSelectSound, self.dataTypeResetControlCallback = getRowInfoFromOrderListBoxData(orderListBoxData)

    local templateName = self.rowTemplate
    local selectTemplate = self.rowSelectionTemplate

    local rowHeight = self.rowHeight

    local dataTypeSelectSound = self.dataTypeSelectSound

    local rowHideCallback = self.rowHideCallback
    local resetControlCallback = self.dataTypeResetControlCallback

    self.showValue, self.showValueAtTooltip = getShowValueInfoFromListBoxData(orderListBoxData)

    local setupFunction = function(control, data, scrollList)
        selfVar:RowSetupFunction(control, data, scrollList)
    end
    local selectCallback = function(previouslySelectedData, selectedData, reselectingDuringRebuild)
        --Check the disabled state of the LAM control and do not select any entry if it is disabled
        if selfVar.disabled then return end
        selfVar:OnRowSelected(previouslySelectedData, selectedData, reselectingDuringRebuild, buttonMoveUpControl, buttonMoveDownControl, buttonMoveTotalUpControl, buttonMoveTotalDownControl)
        if selfVar.rowSelectedCallback ~= nil and type(selfVar.rowSelectedCallback) == "function" then
            selfVar.rowSelectedCallback(selfVar, previouslySelectedData, selectedData, reselectingDuringRebuild)
        end
    end
--d(">templateName: " ..tostring(templateName))
    ZO_ScrollList_AddDataType(scrollListControl, dataTypeId, templateName, rowHeight, setupFunction, rowHideCallback, dataTypeSelectSound, resetControlCallback)
    ZO_ScrollList_EnableSelection(scrollListControl, selectTemplate, selectCallback)

    --Will be done via UpdateValue -> GetFunc
    --self.masterList = self:Populate(orderListBoxData)
    --self:UpdateScrollList(scrollListControl, self.masterList, dataTypeId)

    return scrollListControl, buttonMoveUpControl, buttonMoveDownControl, buttonMoveTotalUpControl, buttonMoveTotalDownControl
end


--Build the scroll list entries
function OrderListBox:Populate(orderListBoxData)
--d("[LAM2]OrderListBox:Populate")
    local masterList = orderListBoxData.listEntries or {}

    --[[
        [1] = {
            uniqueKey = 1, --number of the unique key of this list entry. This will not change if the order changes. Will be used to identify the entry uniquely
            value = "Value of the entry", -- or number or boolean or function returning the value of this entry
            text  = "Text of this entry", -- or string id or function returning a string (optional)
            tooltip = "Tooltip text shown at this entry", -- or string id or function returning a string (optional)
        },
    ]]

    --2 example entries
    --[[
    if masterList == nil or #masterList == 0 then
        masterList[1] = {
            uniqueKey = 1,
            value = 1,
            text = "Test Entry 1",
            tooltip = "Test description 1",
        }
        masterList[2] = {
            uniqueKey = 2,
            value = 2,
            text = "Test Entry 2",
            tooltip = "Test description 2",
        }
    end
    ]]

    --Check if the row's data table is of the correct format or got errors
    checkOrderListBoxEntriesForCorrectFormat(masterList)

    return masterList
end


--------------------------------------------------
-- Update any changes to a scroll list data table then commit those changes to the screen
-- Repeat this step as needed if you have a data table that will have changing data (like an inventory).
--------------------------------------------------
function OrderListBox:UpdateScrollList(control, data, rowDataType, lamControl)
--d("[LAM2]OrderListBox:UpdateScrollList")
	--[[ 	Adds data to the datalist. Already stored in the control rowtype is the typeId we assigned in CreateScrollListDataType.

			From LibScroll:
			"Must use ZO_DeepTableCopy or it WILL crash if the user passes in a dataTable that is stored in saved variables.
			This is because ZO_ScrollList_CreateDataEntry creates a recursive reference to the data.
			Although this is only necessary for data saved in saved vars, I'm doing it to protect users against themselves"
	--]]
	local dataCopy = ZO_DeepTableCopy(data)
	local dataList = ZO_ScrollList_GetDataList(control)

	-- Clears out the scroll list.  Dont' worry, we made a copy called dataList.
	ZO_ScrollList_Clear(control)

	-- Create the data entries for the scroll list from the copy of the new data table.
	for key, value in ipairs(dataCopy) do
		local entry = ZO_ScrollList_CreateDataEntry(rowDataType, value)
		table.insert(dataList, entry) -- By using table.insert, we add to whatever data may already be there.
	end

	-- Sort if needed.  In our case we want to sort by the text
	--table.sort(dataList, function(a,b) return a.data.text < b.data.text end)

	-- Redraw the scroll list.
    --> Not if the LAM control is currently building, as the UpdateDisabled function will call the commit then!
    if lamControl.isBuilding == true then return end
	ZO_ScrollList_Commit(control)
end


--Row get's created/setup callback function
function OrderListBox:RowSetupFunction(rowControl, data, scrollList)
    -- The rowControl, data, and scrollListControl are all supplied by the internal callback trigger
    -- What is contained in data is determined by the structure of the table of data items you used in the Populate function
    rowControl:SetFont(self.rowFont)
    rowControl:SetMaxLineCount(self.rowMaxLineCount) -- 1 = Forces the text to only use one row

    --The row's text
    local rowText = (data.text ~= nil and LAMgetStringFromValue(data.text)) or errorTexts["no_line_text_given"]
    if self.showPosition then
        rowText = tostring(rowControl.index) .. ") " .. rowText
    end
    if self.showValue then
        rowText = rowText .. " [" .. tostring(data.value) .. "]"
    end
    rowControl:SetText(rowText)

    -- When we added the data type earlier we also enabled being able to select an item and which function to run
    -- when an row is slected.  We still need to set up a handler to actuall register the mouse click which
    -- then triggers the row as "selected".  See https://wiki.esoui.com/UI_XML#OnAddGameData and following
    -- entries for "On" events that can be set as handlers.
    rowControl:SetHandler("OnMouseUp", function(p_rowControl, mouseButton, upInside, ctrl, alt, shift, command)
--d(">OnMouseUp - upInside: " ..tostring(upInside) .. ", mouseButton: " ..tostring(mouseButton) .. ", draggingEntryId: " .. tostring(self.draggingEntryId))
        if self.disabled then return end
        self.mouseDown = nil
        if not upInside or mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then return end
        setMouseCursor(mouseCursorHand)
        if self.draggingEntryId ~= nil then return end
        ZO_ScrollList_MouseClick(scrollList, p_rowControl)
    end)
    rowControl:SetHandler("OnMouseDown", function(p_rowControl, mouseButton, ctrl, alt, shift, command)
--d("row OnMouseDown - mouseButton: " .. tostring(mouseButton) .. ", draggingId: " ..tostring(self.draggingEntryId))
        if self.disabled then return end
        self.mouseDown = true
        if self.draggingEntryId == nil then
            --Is the left mouse pressed down (before dragging)
            if mouseButton == MOUSE_BUTTON_INDEX_LEFT and not self.isDragDisabled then
                setMouseCursor(mouseCursorResizeNS)
            else
                setMouseCursor(mouseCursorHand)
            end
        else
            setMouseCursor(mouseCursorResizeNS)
        end
    end)

    --The tooltip
    local tooltip = data.tooltip
    if self.showValueAtTooltip then
        tooltip = tooltip .. " [" .. tostring(data.value) .."]"
    end

    rowControl:SetHandler("OnMouseEnter", function(p_rowControl)
--d(">OnMouseEnter, draggingEntryId: " .. tostring(self.draggingEntryId))
        if self.disabled then return end
        local isMouseDown = self.mouseDown
        if self.draggingEntryId == nil and not isMouseDown then
            setMouseCursor(mouseCursorHand)
        end
        if not isMouseDown and tooltip then
            ZO_Tooltips_ShowTextTooltip(p_rowControl, LEFT, tooltip)
        end
    end)
    rowControl:SetHandler("OnMouseExit", function(p_rowControl)
--d(">OnMouseExit, draggingEntryId: " .. tostring(self.draggingEntryId))
        if self.disabled then return end
        if self.draggingEntryId == nil and not self.mouseDown then
            setMouseCursor(mouseCursorDoNotCare)
        end
        ZO_Tooltips_HideTextTooltip()
    end )
    rowControl:SetHidden(false)
    rowControl:SetMouseEnabled(not self.disabled)
end


--Row was selected callback function
function OrderListBox:OnRowSelected(previouslySelectedData, selectedData, reselectingDuringRebuild, buttonMoveUpControl, buttonMoveDownControl, buttonMoveTotalUpControl, buttonMoveTotalDownControl)
--d(">OnRowSelected, draggingEntryId: " .. tostring(self.draggingEntryId))
    if self.disabled then return end
    if not selectedData then
        buttonMoveUpControl:SetMouseEnabled(false)
        buttonMoveUpControl:SetHidden(true)
        buttonMoveDownControl:SetMouseEnabled(false)
        buttonMoveDownControl:SetHidden(true)
        buttonMoveTotalUpControl:SetMouseEnabled(false)
        buttonMoveTotalUpControl:SetHidden(true)
        buttonMoveTotalDownControl:SetMouseEnabled(false)
        buttonMoveTotalDownControl:SetHidden(true)
        updateRemoveEntryEnabledState(self.control)
    else
        local selectedIndex = ZO_ScrollList_GetSelectedDataIndex(self.scrollListControl)
        if not selectedIndex then return end
        self:UpdateMoveButtonsEnabledState(selectedIndex)
    end
end


--Move an entry of the list up or down
function OrderListBox:MoveItem(selectedIndex, moveUp, moveToIndex, moveToTopOrBottom)
    if self.disabled then return end
    local movedUp
    if moveUp == nil and moveToIndex == nil then return end
    local scrollListControl = self.scrollListControl
    if not ZO_ScrollList_HasVisibleData(scrollListControl) then return end
    selectedIndex = selectedIndex or ZO_ScrollList_GetSelectedDataIndex(scrollListControl)
    if selectedIndex == nil then return end
    --d(string.format("[LAM2]OrderListBox:MoveItem - selectedIndex: %s, moveUp: %s", tostring(selectedIndex), tostring(moveUp)))
    --Get the current data table of the list
    local currentData = scrollListControl.data
    if not currentData then return end
    local maxEntries = #currentData
    local entryToMove = self.orderListBoxData.listEntries[selectedIndex]
    if not entryToMove then return end
    --d(">entryToMove: " ..tostring(entryToMove.text))
    --Move item up by 1
    local newIndex
    if moveUp == true and selectedIndex > 1 then
        newIndex = (moveToTopOrBottom ~= nil and moveToTopOrBottom == true and 1) or selectedIndex - 1
        table.remove(self.orderListBoxData.listEntries, selectedIndex)
        table.insert(self.orderListBoxData.listEntries, newIndex, entryToMove)
        movedUp = true

        --Move item down by 1
    elseif moveUp == false and selectedIndex < maxEntries then
        --d(">move 1 down")
        newIndex = (moveToTopOrBottom ~= nil and moveToTopOrBottom == true and maxEntries) or selectedIndex + 1
        table.remove(self.orderListBoxData.listEntries, selectedIndex)
        table.insert(self.orderListBoxData.listEntries, newIndex, entryToMove)
        movedUp = false
    elseif moveUp == nil and moveToTopOrBottom == nil and moveToIndex ~= nil and moveToIndex >= 1 and moveToIndex <= maxEntries then
        newIndex = moveToIndex
        table.remove(self.orderListBoxData.listEntries, selectedIndex)
        table.insert(self.orderListBoxData.listEntries, newIndex, entryToMove)
    else
        return
    end

    --Refresh the list contents! Will remove selection
    UpdateValue(self.control, false, self.orderListBoxData.listEntries)

    local wasMovedToLastEntry = newIndex == maxEntries
    local wasMovedToFirstEntry = newIndex == 1

    zo_callLater(function()
        local scrollBar = scrollListControl.scrollbar
        local valueMin, valueMax = scrollBar:GetMinMax()
        valueMin = valueMin or 0
        valueMax = valueMax or 9999
--d(">wasMovedToLastEntry: " ..tostring(wasMovedToLastEntry) .. ", wasMovedToFirstEntry: " ..tostring(wasMovedToFirstEntry) .. ", moveUp: " ..tostring(moveUp) .. ", valueMin/valueMax: " ..tostring(valueMin).."/" ..tostring(valueMax))

        if moveUp == nil then
            --Select the dragged & dropped entry now
            if wasMovedToLastEntry then
                ZO_ScrollList_ScrollAbsolute(scrollListControl, valueMax)
                ZO_ScrollList_SelectData(scrollListControl, scrollListControl.data[newIndex].data, nil, nil, true)
            elseif wasMovedToFirstEntry then
                ZO_ScrollList_ResetToTop(scrollListControl)
                ZO_ScrollList_SelectData(scrollListControl, scrollListControl.data[newIndex].data, nil, nil, true)
            else
                ZO_ScrollList_SelectDataAndScrollIntoView(scrollListControl, scrollListControl.data[newIndex].data, nil, false)
            end
        else
            if wasMovedToLastEntry then
                ZO_ScrollList_ScrollAbsolute(scrollListControl, valueMax)
                ZO_ScrollList_SelectData(scrollListControl, scrollListControl.data[newIndex].data, nil, nil, true)
            elseif wasMovedToFirstEntry then
                ZO_ScrollList_ResetToTop(scrollListControl)
                ZO_ScrollList_SelectData(scrollListControl, scrollListControl.data[newIndex].data, nil, nil, true)
            else
                --Reselect the last moved entry now and scroll it into view
                --Therefor we manually need to set the selectedDataIndex here without selecting a control
                -->(selection of the last moved control was removed at UpdateValue -> scrollList:Commit())
                scrollListControl.selectedDataIndex = selectedIndex
                if movedUp == true then
                    ZO_ScrollList_SelectPreviousData(scrollListControl, nil, false)
                else
                    ZO_ScrollList_SelectNextData(scrollListControl, nil, false)
                end
            end
        end
        self:UpdateMoveButtonsEnabledState(newIndex)
    end, 100)
end


function OrderListBox:UpdateMoveButtonsEnabledState(newIndex)
--d("[LAM2 OrderListBox]UpdateMoveButtonsEnabledState")
    if self.disabled or self.areButtonsDisabled then return end
    updateRemoveEntryEnabledState(self.control)
    if not newIndex then return end
    self.moveUpButton:SetHidden(false)
    self.moveDownButton:SetHidden(false)
    self.moveTotalUpButton:SetHidden(false)
    self.moveTotalDownButton:SetHidden(false)
    if newIndex == 1 then
        self.moveUpButton:SetMouseEnabled(false)
        self.moveUpButton:SetHidden(true)
        self.moveDownButton:SetMouseEnabled(true)
        self.moveTotalUpButton:SetMouseEnabled(false)
        self.moveTotalUpButton:SetHidden(true)
        self.moveTotalDownButton:SetMouseEnabled(true)
    elseif newIndex == #self.scrollListControl.data then
        self.moveUpButton:SetMouseEnabled(true)
        self.moveDownButton:SetMouseEnabled(false)
        self.moveDownButton:SetHidden(true)
        self.moveTotalUpButton:SetMouseEnabled(true)
        self.moveTotalDownButton:SetMouseEnabled(false)
        self.moveTotalDownButton:SetHidden(true)
    else
        self.moveUpButton:SetMouseEnabled(true)
        self.moveDownButton:SetMouseEnabled(true)
        self.moveTotalUpButton:SetMouseEnabled(true)
        self.moveTotalDownButton:SetMouseEnabled(true)
    end
end

--Auto scroll the orderListBox upon dragging an entry to the top/bottom of the list
local function autoScroll(orderListBoxVar)
--d(">autoscroll")
    local scrollListControl = orderListBoxVar.scrollListControl
    local contents = scrollListControl.contents
    local numContentChildren = (contents ~= nil and contents:GetNumChildren()) or 0
    local contentsHeight = contents:GetHeight()
    if not contents or numContentChildren == 0 then return end
    local controlBelowMouse = moc()
    if not controlBelowMouse or not controlBelowMouse.GetParent or controlBelowMouse:GetParent() ~= contents then return end
    local isValid, point, relTo, relPoint, offsetX, offsetY = controlBelowMouse:GetAnchor(0)
    local orderListBoxRowHeight = orderListBoxVar.rowHeight or SORT_LIST_ROW_DEFAULT_HEIGHT
    local orderListBoxScrollArea = orderListBoxRowHeight * 1.5
    local scrollValue
    if offsetY < 0 or (offsetY >= 0 and offsetY <= orderListBoxScrollArea) then
        --Scroll up
        scrollValue = (orderListBoxRowHeight * 2) * -1
    elseif offsetY <= contentsHeight and offsetY >= contentsHeight - orderListBoxScrollArea then
        --Scroll down
        scrollValue = orderListBoxRowHeight * 2
    end
    if scrollValue == nil or scrollValue == 0 then return end
--d(">scrollValue: " ..tostring(scrollValue))
    ZO_ScrollList_ScrollRelative(scrollListControl, scrollValue, nil, true)
end

function OrderListBox:OnGlobalMouseDownDuringDrag(eventId, mouseButton, ctrl, alt, shift, command)
--d("[OrderListBox]OnGlobalMouseDownDuringDrag - draggedIndex: " ..tostring(self.draggingEntryId) .. ", mouseButton: " ..tostring(mouseButton))
    if self.disabled or self.isDragDisabled then return end
    if self.draggingEntryId and self.draggingSortListContents then
        self.mouseButtonPressed = mouseButton
    end
end

function OrderListBox:OnGlobalMouseUpDuringDrag(eventId, mouseButton, ctrl, alt, shift, command)
--d("[OrderListBox]OnGlobalMouseUpDuringDrag - draggedIndex: " ..tostring(self.draggingEntryId) .. ", mouseButton: " ..tostring(mouseButton))
    if self.disabled or self.isDragDisabled then return end
    if mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then
        abortDragging(self)
        setMouseCursor(mouseCursorDoNotCare)
    end
    if self.draggingEntryId and self.draggingSortListContents then
        local controlBelowMouse = moc()
        if not controlBelowMouse or controlBelowMouse and controlBelowMouse:GetParent() ~= self.draggingSortListContents then
            abortDragging(self)
            setMouseCursor(mouseCursorDoNotCare)
        end
    end
end

local maxCursorTextWidth    = 600
local maxCursorTextHeight   = 100
function OrderListBox:UpdateCursorTLC(isHidden, draggedControl)
    if cursorTLC == nil then getCursorTLC() end
    if not cursorTLC then return end
    cursorTLC:ClearAnchors()
    cursorTLC:SetResizeToFitDescendents(true)
    if not isHidden then
        cursorTLC.orderListBox = self
        cursorTLC:SetAnchor(LEFT, GuiMouse, RIGHT, 8, 0)
        cursorTLCLabel:SetDimensionConstraints(0, 0, maxCursorTextWidth, maxCursorTextHeight)
        cursorTLCLabel:SetResizeToFitConstrains(ANCHOR_CONSTRAINS_XY)
        cursorTLCLabel:SetText(self.draggingText)
        zo_callLater(function()
            local textWidth = (cursorTLCLabel:GetTextWidth()) + 2
            textWidth = zo_clamp(textWidth, 0, maxCursorTextWidth)
            --Fallback if textWidth was not determined properly: Sometimes the textlabel only showed the first character
            if textWidth == 0 and self.draggingText ~= "" then
                textWidth = maxCursorTextWidth
            end
            cursorTLCLabel:SetWidth(textWidth)
            cursorTLCLabel:SetHeight(self.rowHeight or SORT_LIST_ROW_DEFAULT_HEIGHT)
            --should autoamtically be resized by the label (resizeToFitDescendents = true)
            --cursorTLC:SetWidth(textWidth)
            --cursorTLC:SetHeight(self.rowHeight or SORT_LIST_ROW_DEFAULT_HEIGHT)
            --For debugging
            --[[
            local width, height = cursorTLCLabel:GetDimensions()
            width = zo_clamp(width, 0, maxCursorTextWidth)
            height = zo_clamp(height, 0, maxCursorTextHeight)
            ]]
            --d(">GuiMouse:isHidden: " ..tostring(GuiMouse:IsHidden()) .. ", cursorTLC.width: " ..tostring(cursorTLC:GetWidth()) ..", cursorTLC.height: " ..tostring(cursorTLC:GetHeight()) .. ", text: " ..tostring(self.draggingText))
        end, 0) --next framecheck so label text was updated and text size returns properly!
        cursorTLC:SetDrawTier(DT_HIGH)
        cursorTLC:SetDrawLayer(DL_OVERLAY)
        cursorTLC:SetDrawLevel(5)
        cursorTLC:SetAlpha(0.7)
    else
        cursorTLC.orderListBox = nil
        cursorTLCLabel:SetDimensions(0, 0)
        cursorTLCLabel:SetText("")
        cursorTLC:SetDimensions(0, 0)
        cursorTLC:SetDrawTier(DT_LOW)
        cursorTLC:SetDrawLayer(DL_BACKGROUND)
        cursorTLC:SetDrawLevel(0)
        cursorTLC:SetAlpha(0)
    end
    cursorTLC:SetHidden(isHidden)
    cursorTLC:SetMouseEnabled(false)
end

function OrderListBox:DragOnUpdateCallback(draggedControl)
    if self.disabled or self.isDragDisabled then
        abortDragging(self)
        return
    end

    --Check the actual shown rows of the list (contents)
    -->Check the anchor's offsetY of the row of the contents. If between 0 and 2*rowHeight -> Scroll up
    -->If between contents:GetHeight()- 2*rowHeight and contents:GetHeight() -> Scroll down
    --Only run the following code once every 500 MS!
    local gameTimeMS = GetGameTimeMilliseconds()
    local gameTimeDeltaNeeded = 200 --milliseconds
--d("[LAM2OrderListBox]OnUpdate-gameTime: " ..tostring(gameTimeMS) .. ", self.draggingUpdateTime: " ..tostring(self.draggingUpdateTime))
    local updateAutoScroll = false
    if self.draggingUpdateTime == nil then
        self.draggingUpdateTime = gameTimeMS
        updateAutoScroll = true
    elseif self.draggingUpdateTime > 0 then
        if gameTimeMS >= (self.draggingUpdateTime + gameTimeDeltaNeeded) then
            self.draggingUpdateTime = gameTimeMS
            updateAutoScroll = true
        end
    end
--d(">updateAutoScroll: " .. tostring(updateAutoScroll) ..", needed: " ..tostring(self.draggingUpdateTime + gameTimeDeltaNeeded))
    if updateAutoScroll == true then
        autoScroll(self)
    end
end

function OrderListBox:StartDragging(draggedControl, mouseButton)
--d("StartDragging")
    local selfVar = self
    if self.disabled or selfVar.isDragDisabled then return end
    if mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then return end
    --d("[OrderListBox]StartDragging - index: " ..tostring(draggedControl.index))
    self.draggingEntryId            = draggedControl.index
    self.draggingSortListContents   = draggedControl:GetParent()
    self.draggingText               = LAMgetStringFromValue(draggedControl.dataEntry.data.text)
    self.mouseButtonPressed         = MOUSE_BUTTON_INDEX_LEFT

    --Anchor the TLC with the label of the dragged row element to GuiMouse
    self:UpdateCursorTLC(false, draggedControl)

    setMouseCursor(mouseCursorResizeNS)
    --Unselect any selected entry
    ZO_ScrollList_SelectData(self.scrollListControl, nil, nil, nil, true)
    --Enable a global MouseUp check and see if the mouse is above the ZO_SortList where the drag started
    --If not: End the drag&drop
    em:RegisterForEvent(EVENT_HANDLER_NAMESPACE .. globalMouseDown, EVENT_GLOBAL_MOUSE_DOWN, function(...) selfVar:OnGlobalMouseDownDuringDrag(...) end)
    em:RegisterForEvent(EVENT_HANDLER_NAMESPACE .. globalMouseUp, EVENT_GLOBAL_MOUSE_UP, function(...) selfVar:OnGlobalMouseUpDuringDrag(...) end)

    --Set the OnUpdate handler to check for the autosroll position of the cursor
    self.draggingUpdateTime = nil
    self.scrollListControl:SetHandler("OnUpdate", function() selfVar:DragOnUpdateCallback(draggedControl) end)
end


function OrderListBox:StopDragging(draggedOnToControl)
    --Delay so the OnMouseButtonDown/Up handlers fire first
    zo_callLater(function()
        local mouseButton = self.mouseButtonPressed
    --d("StopDragging - mouseButton: " ..tostring(mouseButton))
        if self.disabled or self.isDragDisabled then return end
        disableOnUpdateHandlerAndResetMouseCursor(self)
        setMouseCursor(mouseCursorHand)
        if mouseButton and mouseButton == MOUSE_BUTTON_INDEX_LEFT and self.draggingEntryId ~= nil and self.draggingSortListContents ~= nil then
            --local totalDeltaX = GetUIMousePosition() - self.draggingXStart
            --local lastFrameDeltaX = GetUIMouseDeltas() * 15
            --self:SetSelectedIndex(zo_round((self:CalculateSelectedIndexOffset() + totalDeltaX + lastFrameDeltaX) / self.controlEntryWidth))
    --d("[OrderListBox]StopDragging -- from index: " ..tostring(self.draggingEntryId) .." to index: " ..tostring(draggedOnToControl.index))
            --Remove the entry at index self.draggingEntryId and insert it at draggedOnToControl.dataEntry.data.index
            self:MoveItem(self.draggingEntryId, nil, draggedOnToControl.index, nil)
        end
        clearDragging(self)
    end, 50)
end

function OrderListBox:GetCurrentEntries()
    return self.control.data.getFunc()
end

function OrderListBox:RemoveValue(index, uniqueKey)
    if index == nil and uniqueKey == nil then return false end
    local wasRemoved = false
    local currentEntries = self:GetCurrentEntries()
    if currentEntries then
        if index ~= nil then
            if currentEntries[index] ~= nil then
                table.remove(currentEntries, index)
                wasRemoved = true
            end
        else
            if uniqueKey ~= nil then
                for idx, entryData in ipairs(currentEntries) do
                    if uniqueKey == entryData.uniqueKey then
                        table.remove(currentEntries, idx)
                        wasRemoved = true
                        break
                    end
                end
            end
        end
        if wasRemoved then
            self.control:UpdateValue(false, currentEntries)
            return true
        end
    end
    return false
end

function OrderListBox:RemoveSelectedEntry()
    local selectedIndex = ZO_ScrollList_GetSelectedDataIndex(self.scrollListControl)
--d("OrderListBox:RemoveSelectedEntry-selectedIndex: " ..tostring(selectedIndex))
    if not selectedIndex then return end
    local selectedEntry
    local currentEntries = self:GetCurrentEntries()
    if currentEntries then
        local currentlySelectedEntry = currentEntries[selectedIndex]
        selectedEntry = currentlySelectedEntry --double local to remove direct pointer so it's still available after deleting it below
    end

    local orderListBoxData = self.orderListBoxData
    if orderListBoxData and type(orderListBoxData.removeEntryCheckFunction) == "function" then
        if orderListBoxData.removeEntryCheckFunction(self, selectedIndex, orderListBoxData) == false then return false end
    end

    if self:RemoveValue(selectedIndex, nil) == true then
        if selectedEntry and orderListBoxData and type(orderListBoxData.removeEntryCallbackFunction) == "function" then
            return orderListBoxData.removeEntryCallbackFunction(self, selectedEntry, orderListBoxData)
        end
    end
end

function OrderListBox:AddNewEntry(newText, newValue, validateFunction)
    if self.disabled then return end
    if newText == nil then return end
    local validated = true
    if validateFunction ~= nil then
        validated = validateFunction(newText)
    end
    if not validated then return end

    local currentEntries = self:GetCurrentEntries()
    if currentEntries then
        --Check if newValue is not already added to the list
        for _, entryData in ipairs(currentEntries) do
            if newText == entryData.text then return false end
        end

        --Add the new value to the list now
        -->Get the next uniqueKey
        local newUniqueKey = #currentEntries + 1
        -->Text will be newValue
        -->if newValue is not provided it will be same as the uniqueKey!
        newValue = newValue or newUniqueKey
        local newEntry = {
            uniqueKey = newUniqueKey,
            text = newText,
            value = newValue,
        }
        currentEntries[newUniqueKey] = newEntry
        self.control:UpdateValue(false, currentEntries)

        local orderListBoxData = self.orderListBoxData
        if orderListBoxData and type(orderListBoxData.addEntryCallbackFunction) == "function" then
            return orderListBoxData.addEntryCallbackFunction(self, newEntry, orderListBoxData)
        end
        return true
    end
end

function OrderListBox:AddNewEntryFromDialog(newText, validateFunction)
    if self.disabled then return end
    return self:AddNewEntry(newText, nil, validateFunction)
end

function OrderListBox:AddNewEntryFromCustomDialog(dialog, customAddFunction, validateFunction)
--d("[OrderListBox]AddNewEntryFromCustomDialog")
    if self.disabled then return end
    local text, value = customAddFunction(self, dialog)
    return self:AddNewEntry(text, value, validateFunction)
end


function OrderListBox:ShowAddNewEntryDialog(dialogName)
--d("[LAM]OrderListBox:ShowAddNewEntryDialog-dialogName: " ..tostring(dialogName))
    if self.disabled then return end
    local orderListBoxData = self.orderListBoxData
    if orderListBoxData.addEntryDialog == nil and orderListBoxData.addCustomEntryDialog == nil then return end
    dialogName = dialogName or self.control.addNewEntryDialogName
    if dialogName ~= nil and ZO_Dialogs_IsDialogRegistered(dialogName) then
        local data
        ZO_Dialogs_ShowPlatformDialog(dialogName, data)
    end
end

function OrderListBox:ShowAskBeforeRemoveEntryDialog(dialogName)
--d("[LAM]OrderListBox:ShowAskBeforeRemoveEntryDialog-dialogName: " ..tostring(dialogName))
    if self.disabled then return end
    if self.orderListBoxData.showRemoveEntryButton == nil then return end
    dialogName = dialogName or self.control.askBeforeRemoveEntryDialogName
    if dialogName ~= nil and ZO_Dialogs_IsDialogRegistered(dialogName) then
        local data
        ZO_Dialogs_ShowPlatformDialog(dialogName, data)
    end
end


function LAM2_orderlistbox_widget_OnDragStart(draggedControl, mouseButton)
--d("[LAM2_orderlistbox_widget_OnDragStart] - " ..tostring(draggedControl.dataEntry.data.text))
    local orderListBox = draggedControl:GetParent():GetParent():GetParent().orderListBox
    orderListBox:StartDragging(draggedControl, mouseButton)
end
function LAM2_orderlistbox_widget_OnReceiveDrag(draggedOnToControl, mouseButton)
--d("[LAM2_orderlistbox_widget_OnReceiveDrag] - " ..tostring(draggedOnToControl.dataEntry.data.text))
    local orderListBox = draggedOnToControl:GetParent():GetParent():GetParent().orderListBox
    orderListBox:StopDragging(draggedOnToControl, mouseButton)
end


------------------------------------------------------------------------------------------------------------------------
--The orderlistbox widget
------------------------------------------------------------------------------------------------------------------------
function LAMCreateControl.orderlistbox(parent, orderListBoxData, controlName)
    orderListBoxCounter = orderListBoxCounter + 1
    --GitHub issue #2 controlName ("reference") is not always provided so "parent" name could be empty and thus duplicate "scrollList" names could occur
    --and issue #5 controlName provided will not use reference any longer in LibAddonMenu2.util.CreateBaseControl(parent, controlData, controlName)
    controlName = controlName or LAMgetDefaultValue(orderListBoxData.reference) or string.format(orderListBoxNameTemplate, tostring(orderListBoxCounter))
    local control = util.CreateLabelAndContainerControl(parent, orderListBoxData, controlName)
    control.isBuilding = true
    control.orderListBoxName = controlName

    local container = control.container

    local width = control:GetWidth()
    local minHeight = (control.data.minHeight and util.GetDefaultValue(control.data.minHeight)) or MIN_HEIGHT
    local maxHeight = (control.data.maxHeight and util.GetDefaultValue(control.data.maxHeight)) or (minHeight * 4)

    local isExtraWide = (orderListBoxData.isExtraWide and LAMgetDefaultValue(orderListBoxData.isExtraWide)) or false
    if isExtraWide == true then
        control.container:SetDimensionConstraints(width, minHeight, width, maxHeight)

        control.label:ClearAnchors()
        control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)

        container:ClearAnchors()
        container:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 0, 0)
        container:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0)

        if control.isHalfWidth then
            container:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0)
        end

        control:SetHeight(container:GetHeight() + control.label:GetHeight())
    else
        control:SetDimensionConstraints(width, minHeight, width, maxHeight)
    end

    control:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseEnter(control) end)
    control:SetHandler("OnMouseExit", function() ZO_Options_OnMouseExit(control) end)

    local orderListBox = OrderListBox:New(util.GetTopPanel(parent), control, orderListBoxData)
    control.orderListBox = orderListBox

    if orderListBoxData.warning ~= nil or orderListBoxData.requiresReload then
        control.warning = wm:CreateControlFromVirtual(nil, control, "ZO_Options_WarningIcon")
        control.warning:SetAnchor(RIGHT, control.container, LEFT, -5, 0)
        control.UpdateWarning = util.UpdateWarning
        control:UpdateWarning()
    end

    local addEntryStr = LAMgetStringFromValue(translation.ADD_ENTRY)
    local addEntryDescStr = LAMgetStringFromValue(translation.ADD_ENTRY_DESC)


    --Add a "Add new value" button which opens a ZO_Dialog with default editbox, or a ZO_Dialog with csutom controls where one must be named "Value" and hold the new added entry value
    local addEntryDialogData = LAMgetDefaultValue(orderListBoxData.addEntryDialog)
    local useAddEntryDialog = false
    local addCustomEntryDialogData = LAMgetDefaultValue(orderListBoxData.addCustomEntryDialog)
    local useCustomAddEntryDialog = false

    local dialogTitle, addNewEntryDialogName

    --Custom dialog
    if addCustomEntryDialogData ~= nil then
        if addCustomEntryDialogData.XMLtemplate ~= nil then
            dialogTitle =               LAMgetDefaultValue(addCustomEntryDialogData.title) or addEntryStr
--d(">found addCustomEntryDialogData title: " .. tostring(dialogTitle) .. ", XML template: " ..tostring(addCustomEntryDialogData.XMLtemplate))
            local customAddFunction =   addCustomEntryDialogData.customAddFunction or nil
            if type(customAddFunction) == "function" then
                local validateFunction =    addCustomEntryDialogData.validator or nil
                if type(validateFunction) ~= "function" then
                    validateFunction = nil
                end
                local customSetupFunction =   addCustomEntryDialogData.customSetupFunction or nil
                if type(customSetupFunction) ~= "function" then
                    customSetupFunction = nil
                end


                --d(">>customAddFunction was provided")
                addNewEntryDialogName   = controlName .. orderListBoxAddNewEntryDialogSuffix
--d(">>addNewEntryDialogName: " ..tostring(addNewEntryDialogName))
                control.addNewEntryDialogName = addNewEntryDialogName
                local XMLcustomControl = CreateControlFromVirtual(addNewEntryDialogName .. "CustomControl", nil, addCustomEntryDialogData.XMLtemplate)

                if not ZO_Dialogs_IsDialogRegistered(addNewEntryDialogName) then
                    useCustomAddEntryDialog = true

                    local customDialogInfo = {
                        gamepadInfo =
                        {
                            dialogType = GAMEPAD_DIALOGS.CUSTOM,
                        },
                        customControl = XMLcustomControl,
                        title =
                        {
                            text = dialogTitle,
                        },
                        mainText =
                        {
                            text = dialogTitle,
                        },
                        buttons =
                        {
                            [1] = {
                                text = SI_DIALOG_ACCEPT,
                                callback = function(dialog)
                                    orderListBox:AddNewEntryFromCustomDialog(dialog, customAddFunction, validateFunction)
                                end,
                                control = XMLcustomControl:GetNamedChild("Accept"),
                            },
                            [2] = {
                                text = SI_DIALOG_EXIT,
                                control = XMLcustomControl:GetNamedChild("Cancel"),
                            },
                        },
                        --noChoiceCallback =
                    }

                    if customSetupFunction ~= nil then
                        customDialogInfo.setup = function(dialog) customSetupFunction(orderListBox, dialog) end
                    end

                    ZO_Dialogs_RegisterCustomDialog(addNewEntryDialogName, customDialogInfo)
                end
            end
        end
    end

    --Default ZO_Dialog
    if not useCustomAddEntryDialog and addEntryDialogData ~= nil then
        dialogTitle =               LAMgetDefaultValue(addEntryDialogData.title) or addEntryStr
        local text =                LAMgetDefaultValue(addEntryDialogData.text) or addEntryDescStr
        local textType =            LAMgetDefaultValue(addEntryDialogData.textType) or TEXT_TYPE_ALL
        local specialCharacters =   LAMgetDefaultValue(addEntryDialogData.specialCharacters) or nil
        local maxInputCharacters =  LAMgetDefaultValue(addEntryDialogData.maxInputCharacters) or nil
        local validateFunction =    addEntryDialogData.validator or nil
        if type(validateFunction) ~= "function" then
            validateFunction = nil
        end
        local validatesText =       type(validateFunction) == "function" or false
        local defaultText =         LAMgetDefaultValue(addEntryDialogData.defaultText) or nil
        local instructions =        LAMgetDefaultValue(addEntryDialogData.instructions) or nil
        local selectAll =           LAMgetDefaultValue(addEntryDialogData.selectAll) or nil

        addNewEntryDialogName   = controlName .. orderListBoxAddNewEntryDialogSuffix
        control.addNewEntryDialogName = addNewEntryDialogName
        if not ZO_Dialogs_IsDialogRegistered(addNewEntryDialogName) then
            useAddEntryDialog = true

            ZO_Dialogs_RegisterCustomDialog(addNewEntryDialogName,
                    {
                        gamepadInfo =
                        {
                            dialogType = GAMEPAD_DIALOGS.BASIC,
                        },
                        title =
                        {
                            text = dialogTitle,
                        },
                        mainText =
                        {
                            text = text,
                        },
                        editBox = {
                            textType =              textType,
                            specialCharacters =     specialCharacters,
                            maxInputCharacters =    maxInputCharacters,
                            defaultText =           defaultText,
                            instructions =          instructions,
                            selectAll =             selectAll,
                            validatesText =         validatesText,
                            validator =             validateFunction,
                        },
                        buttons =
                        {
                            [1] = {
                                text = SI_DIALOG_ACCEPT,
                                callback = function(dialog)
                                    local editControl = dialog:GetNamedChild("EditBox")
                                    orderListBox:AddNewEntryFromDialog(editControl:GetText(), validateFunction)
                                end
                            },
                            [2] = {
                                text = SI_DIALOG_EXIT,
                            },
                        },
                        --noChoiceCallback =
                    })
        end
    end

    local showRemoveButton = LAMgetDefaultValue(orderListBoxData.showRemoveEntryButton)
    --Add the "Add new value" button -> A small + icon next to the LAM listbox control
    if useCustomAddEntryDialog or useAddEntryDialog then
        local addNewEntryButton = wm:CreateControl(controlName .. orderListBoxAddNewEntryButtonSuffix, control, CT_BUTTON)
        addNewEntryButton:SetDimensions(24, 24)

        local addNewValueButtonTexture = LAMgetDefaultValue((useCustomAddEntryDialog and addCustomEntryDialogData.buttonTexture) or (useAddEntryDialog and addEntryDialogData.buttonTexture)) or nil
        local useDefaultButton = (addNewValueButtonTexture == nil or addNewValueButtonTexture == "" and true) or false
        if useDefaultButton then
            addNewEntryButton:SetNormalTexture("/esoui/art/buttons/plus_up.dds")
            addNewEntryButton:SetPressedTexture("/esoui/art/buttons/plus_down.dds")
            addNewEntryButton:SetMouseOverTexture("/esoui/art/buttons/plus_over.dds")
            addNewEntryButton:SetDisabledTexture("/esoui/art/buttons/plus_disabled.dds")
        else
            addNewEntryButton:SetNormalTexture(addNewValueButtonTexture)
            addNewEntryButton:SetPressedOffset(2, 2)
        end
        addNewEntryButton:SetMouseEnabled(true)
        addNewEntryButton:SetHidden(false)
        local offsetXAddNewButon = showRemoveButton and -24 or 0
        if isExtraWide then
            if control.isHalfWidth then
                addNewEntryButton:SetAnchor(TOPRIGHT, control, TOPRIGHT, offsetXAddNewButon, 0)
            else
                addNewEntryButton:SetAnchor(TOPRIGHT, control, TOPRIGHT, offsetXAddNewButon, 0)
            end
        else
            if control.isHalfWidth then
                addNewEntryButton:SetAnchor(TOPRIGHT, control, TOPRIGHT, offsetXAddNewButon, 0)
            else
                addNewEntryButton:SetAnchor(TOP, control, TOP, offsetXAddNewButon, 0)
            end
        end
        addNewEntryButton:SetClickSound("Click")
        addNewEntryButton.data = { tooltipText = dialogTitle }
        addNewEntryButton:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
        addNewEntryButton:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
        addNewEntryButton:SetHandler("OnClicked", function(...)
            orderListBox:ShowAddNewEntryDialog(addNewEntryDialogName)
        end)
        control.AddNewEntryButton = addNewEntryButton
    end

    local askBeforeRemoveEntryDialogName = controlName .. orderListBoxAskBeforeRemoveEntryDialogSuffix
    if showRemoveButton == true then
        local removeEntryStr = LAMgetStringFromValue(translation.REMOVE_ENTRY)
        local removeEntryDescStr = LAMgetStringFromValue(translation.REMOVE_ENTRY_DESC)

        --Show "Ask before delete dialog"?
        local askBeforeRemoveEntry = LAMgetDefaultValue(orderListBoxData.askBeforeRemoveEntry)
        if askBeforeRemoveEntry then
            control.askBeforeRemoveEntryDialogName = askBeforeRemoveEntryDialogName
            if not ZO_Dialogs_IsDialogRegistered(askBeforeRemoveEntryDialogName) then
                ZO_Dialogs_RegisterCustomDialog(askBeforeRemoveEntryDialogName,
                        {
                            gamepadInfo =
                            {
                                dialogType = GAMEPAD_DIALOGS.BASIC,
                            },
                            title =
                            {
                                text = removeEntryStr,
                            },
                            mainText =
                            {
                                text = removeEntryDescStr,
                            },
                            buttons =
                            {
                                [1] = {
                                    text = SI_DIALOG_ACCEPT,
                                    callback = function(dialog)
                                        orderListBox:RemoveSelectedEntry()
                                    end
                                },
                                [2] = {
                                    text = SI_DIALOG_EXIT,
                                },
                            },
                            --noChoiceCallback =
                        })
            end
        end

        --Add the "Add new value" button -> A small + icon next to the LAM listbox control
        local removeEntryButton = wm:CreateControl(controlName .. orderListBoxRemoveEntryButtonSuffix, control, CT_BUTTON)
        removeEntryButton:SetDimensions(24, 24)
        removeEntryButton:SetNormalTexture("/esoui/art/buttons/minus_up.dds")
        removeEntryButton:SetPressedTexture("/esoui/art/buttons/minus_down.dds")
        removeEntryButton:SetMouseOverTexture("/esoui/art/buttons/minus_over.dds")
        removeEntryButton:SetDisabledTexture("/esoui/art/buttons/minus_disabled.dds")
        removeEntryButton:SetMouseEnabled(false)
        removeEntryButton:SetHidden(false)

        local addNewButtonCreated = control.AddNewEntryButton ~= nil
        if isExtraWide then
            if control.isHalfWidth then
                if addNewButtonCreated then
                    removeEntryButton:SetAnchor(LEFT, control.AddNewEntryButton, RIGHT, 1, 0)
                else
                    removeEntryButton:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
                end
            else
                if addNewButtonCreated then
                    removeEntryButton:SetAnchor(LEFT, control.AddNewEntryButton, RIGHT, 1, 0)
                else
                    removeEntryButton:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
                end
            end
        else
            if control.isHalfWidth then
                if addNewButtonCreated then
                    removeEntryButton:SetAnchor(LEFT, control.AddNewEntryButton, RIGHT, 1, 0)
                else
                    removeEntryButton:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
                end
            else
                if addNewButtonCreated then
                    removeEntryButton:SetAnchor(LEFT, control.AddNewEntryButton, RIGHT, 1, 0)
                else
                    removeEntryButton:SetAnchor(TOP, control, TOP, 0, 0)
                end
            end
        end
        removeEntryButton:SetClickSound("Click")
        removeEntryButton.data = { tooltipText = removeEntryStr }
        removeEntryButton:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
        removeEntryButton:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
        removeEntryButton:SetHandler("OnClicked", function(...)
            if askBeforeRemoveEntry then
                orderListBox:ShowAskBeforeRemoveEntryDialog(askBeforeRemoveEntryDialogName)
            else
                orderListBox:RemoveSelectedEntry()
            end
        end)
        control.RemoveEntryButton = removeEntryButton
    end

    control.data.tooltipText = LAMgetStringFromValue(orderListBoxData.tooltip)

    control.UpdateValue = UpdateValue
    control:UpdateValue()

    control.UpdateDisabled = UpdateDisabled
    control:UpdateDisabled()

    control.isBuilding = false

    local faqTexture = LAM.util.CreateFAQTexture(control)
    if faqTexture then
        faqTexture:ClearAnchors()
        faqTexture:SetAnchor(LEFT, control, RIGHT, 0, 0)
    end

    util.RegisterForRefreshIfNeeded(control)
    util.RegisterForReloadIfNeeded(control)

    return control
end

local function registerWidget(eventId, addonName)
    if addonName ~= "LibAddonMenuOrderListBox" then return end
    em:UnregisterForEvent("LibAddonMenuOrderListBox_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)

    cursorTLC = getCursorTLC()

    if not LAM:RegisterWidget("orderlistbox", widgetVersion) then return end
    --Register a callback to the close of the LAM panel to hide a dragged control e.g. if ESC key was pressed
    cm:RegisterCallback("LAM-PanelClosed", checkIfDraggedAndDisableUpdateHandler)
end

em:RegisterForEvent("LibAddonMenuOrderListBox_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, registerWidget)
