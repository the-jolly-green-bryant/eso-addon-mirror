--[[dropdownData = {
    type = "multiselectdropdown",
    name = "My Multi Select Dropdown", -- or string id or function returning a string
    noSelectionText = GetString(SI_KEEPRESOURCETYPE0), -- String or function returning a string to show if no selection was done yet
    multiSelectionTextFormatter = "<<1[$d Item/$d Items]>>" -- if specified, this will be used with zo_strformat(multiSelectionTextFormat, numSelectedItems) to set the "selected item text" (optional)
    tooltip = "Dropdown's tooltip text.", -- or string id or function returning a string (optional)
    multiSelectType = "normal", -- or "allowed". "normal" = a list with key = number index an value = String, "allowed" = a list with key = any String or number and value = boolean. If value == true then the entry will be added. Default = "normal" (optional)
    choices = {"table", "of", "choices"},
    choicesValues = {"foo", 2, "three"}, -- if specified, these values will get passed to setFunc instead (optional)
    choicesTooltips = {"tooltip 1", "tooltip 2", "tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
    getFunc = function() return db.var end,
    setFunc = function(var) db.var = var doStuff() end,
    sort = "name-up", -- or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
    width = "full", -- or "half" (optional)
    disabled = function() return db.someBooleanSetting end, -- or boolean (optional)
    warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
    requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
    default = default.var, -- default values or function that returns the default values (optional)
    helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
    reference = "MyAddonMultiSelectDropdown" -- unique global reference to control (optional)
} ]]

local widgetVersion = 2
local widgetName = "LibAddonMenuMultiSelectDropdown"
local widgetPrefix = "[" .. widgetName .. "]"

local LAM = LibAddonMenu2
local util = LAM.util
local getDefaultValue = util.GetDefaultValue

local em = EVENT_MANAGER
local wm = WINDOW_MANAGER

local tos = tostring
local strform = string.format

--Translations
local translations = {
    ["de"] = {
        ENTRY =     "Eintrag",
        ENTRIES =   "Einträge",
    },
    ["en"] = {
        ENTRY =     "entry",
        ENTRIES =   "entries",
    },
    ["es"] = {
        ENTRY =     "apunte",
        ENTRIES =   "apuntes",
    },
    ["fr"] = {
        ENTRY =     "remarque",
        ENTRIES =   "remarques",
    },
    ["jp"] = {
        ENTRY =     "選択",
        ENTRIES =   "選択",
    },
    ["ru"] = {
        ENTRY =     "статья",
        ENTRIES =   "статьяs",
    },
    ["zh"] = {
        ENTRY =     "入口",
        ENTRIES =   "条目",
    },
}
local lang = string.lower(GetCVar("Language.2"))
local translation = (translations[lang] ~= nil and translations[lang]) or translations["en"]

local SORT_BY_VALUE         = { ["value"] = {} }
local SORT_BY_VALUE_NUMERIC = { ["value"] = { isNumeric = true } }
local SORT_TYPES = {
    name = ZO_SORT_BY_NAME,
    numeric = ZO_SORT_BY_NAME_NUMERIC,
    value = SORT_BY_VALUE,
    numericvalue = SORT_BY_VALUE_NUMERIC,
}
local SORT_ORDERS = {
    up = ZO_SORT_ORDER_UP,
    down = ZO_SORT_ORDER_DOWN,
}

local function UpdateDisabled(control)
    local disable
    if type(control.data.disabled) == "function" then
        disable = control.data.disabled()
    else
        disable = control.data.disabled
    end

    control.dropdown:SetEnabled(not disable)
    if disable then
        control.label:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
    else
        control.label:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    end
end


local function updateMultiSelectSelected(control, values)
    local multiSelectType = control.data.multiSelectType
    assert(multiSelectType == "normal" or multiSelectType == "allowed", strform(widgetPrefix .. "Unknown multiSelectType: %s", multiSelectType))
    assert(values ~= nil, strform(widgetPrefix .. "Values for multiSelect %q are missing", control:GetName()))

    local dropdown = control.dropdown
    dropdown.m_selectedItemData = {}
    if multiSelectType == "normal" then
        for _, v in ipairs(values) do
            dropdown:AddItemToSelected(control.entries[v])
        end
    elseif multiSelectType == "allowed" then
        for k, isAllowed in pairs(values) do
            if isAllowed then
                dropdown:AddItemToSelected(control.entries[k])
            end
        end
    end
    dropdown:RefreshSelectedItemText()
end

local refreshIsNeeded = false
local function callMultiSelectSetFunc(control, values)
    if values == nil then
        values = {}
        local multiSelectType = control.data.multiSelectType
        for _, entry in ipairs(control.dropdown.m_selectedItemData) do
            local k = (entry.value ~= nil and entry.value) or entry.name
            if multiSelectType == "normal" then
                values[#values + 1] = k
            elseif multiSelectType == "allowed" then
                values[k] = true
            end
        end
    end
    control.data.setFunc(values)

    --after setting this value, let's refresh the others to see if any should be disabled or have their settings changed
    -- util.RequestRefreshIfNeeded(control)
    -->Atention: Closes dropdown! To prevent this set a flag "doRefresh" and hook into OnDropdownHideInternal and check if "doRefresh"
    --> was set to true > call the refresh then?
    refreshIsNeeded = true
end

local function UpdateValue(control, forceDefault, value)
--d(widgetPrefix .. "forceDefault: " ..tos(forceDefault) .. ", value: " ..tos(value))
    if forceDefault then --if we are forcing defaults
        local values = getDefaultValue(control.data.default)
        values = values or {}
        updateMultiSelectSelected(control, values)
        control.data.setFunc(values)
    elseif value ~= nil then
        --Coming from LAM 2.0 DiscardChangesOnReloadControls? Passing in the saved control.startValue table
        if type(value) ~= "table" then
            value = nil
        else
--d(">>table was passed in as value")
        end
        callMultiSelectSetFunc(control, value)
    else
        local values = control.data.getFunc()
        values = values or {}
        updateMultiSelectSelected(control, values)
    end
end

local function DropdownCallback(control, choiceText, choice)
--d("DropdownCallback_choiceText: " ..tos(choiceText) ..", choice: " ..tos(choice))
    local updateValue = choice.value
    if updateValue == nil then updateValue = choiceText end
    choice.control:UpdateValue(false, updateValue)
end

local TOOLTIP_HANDLER_NAMESPACE = "LAM2_Multiselect_Tooltip"

local function DoShowTooltip(control, tooltip)
    InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
    SetTooltipText(InformationTooltip, util.GetStringFromValue(tooltip))
    InformationTooltipTopLevel:BringWindowToTop()
end

local function ShowTooltip(control)
    DoShowTooltip(control, control.tooltip)
end

local function HideTooltip()
    ClearTooltip(InformationTooltip)
end

local function SetupTooltips(comboBox, choicesTooltips, control)
    -- allow for tooltips on the drop down entries
    local originalShow = comboBox.ShowDropdownInternal
    comboBox.ShowDropdownInternal = function(comboBox)
        originalShow(comboBox)
        local entries = ZO_Menu.items
        for i = 1, #entries do
            local entryControl = entries[i].item
            entryControl.tooltip = choicesTooltips[i]
            if entryControl.tooltip then
                entryControl:SetHandler("OnMouseEnter", ShowTooltip, TOOLTIP_HANDLER_NAMESPACE)
                entryControl:SetHandler("OnMouseExit", HideTooltip, TOOLTIP_HANDLER_NAMESPACE)
            end
        end
    end

    local originalHide = comboBox.HideDropdownInternal
    comboBox.HideDropdownInternal = function(self)
        local entries = ZO_Menu.items
        for i = 1, #entries do
            local entryControl = entries[i].item
            if entryControl.tooltip then
                entryControl:SetHandler("OnMouseEnter", nil, TOOLTIP_HANDLER_NAMESPACE)
                entryControl:SetHandler("OnMouseExit", nil, TOOLTIP_HANDLER_NAMESPACE)
                entryControl.tooltip = nil
            end
        end
        originalHide(self)

        if refreshIsNeeded == true then
            refreshIsNeeded = false
            util.RequestRefreshIfNeeded(control)
        end
    end
end

local function UpdateChoices(control, choices, choicesValues, choicesTooltips)
    control.dropdown:ClearItems() --removes previous choices
    ZO_ClearTable(control.entries)

    local data = control.data
    local dropdown = control.dropdown

    --build new list of choices
    choices = choices or data.choices
    choicesValues = choicesValues or data.choicesValues
    choicesTooltips = choicesTooltips or data.choicesTooltips

    if choicesValues then
        assert(#choices == #choicesValues, "choices and choicesValues need to have the same size")
    end

    if choicesTooltips then
        assert(#choices == #choicesTooltips, "choices and choicesTooltips need to have the same size")
        if not control.scrollHelper then -- only do this for non-scrollable
            SetupTooltips(dropdown, choicesTooltips, control)
        end
    end

    for i = 1, #choices do
        local entry = dropdown:CreateItemEntry(choices[i], DropdownCallback)
        entry.control = control
        if choicesValues then
            entry.value = choicesValues[i]
        end
        if choicesTooltips and control.scrollHelper then
            entry.tooltip = choicesTooltips[i]
        end
        local entryValue = entry.value
        if entryValue == nil then entryValue = entry.name end
        control.entries[entryValue] = entry
        dropdown:AddItem(entry, not data.sort and ZO_COMBOBOX_SUPRESS_UPDATE) --if sort type/order isn't specified, then don't sort
    end
end

local function GrabSortingInfo(sortInfo)
    local t, i = {}, 1
    for info in string.gmatch(sortInfo, "([^%-]+)") do
        t[i] = info
        i = i + 1
    end
    return t
end


function LAMCreateControl.multiselectdropdown(parent, multiSelectDropdownData, controlName)
--d("[LAMCreateControl]multiselectdropdown")
    local control = util.CreateLabelAndContainerControl(parent, multiSelectDropdownData, controlName)
    control.entries = {}
    -- control.selected = {}

    local countControl = parent
    local name = parent:GetName()
    if not name or #name == 0 then
        countControl = LAMCreateControl
        name = "LAM"
    end
    local comboboxCount = (countControl.comboboxCount or 0) + 1
    countControl.comboboxCount = comboboxCount
    control.combobox = wm:CreateControlFromVirtual(zo_strjoin(nil, name, "MultiSelect", comboboxCount), control.container, "ZO_MultiselectComboBox")

    local combobox = control.combobox
    combobox:SetAnchor(TOPLEFT)
    combobox:SetDimensions(control.container:GetDimensions())
    combobox:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseEnter(control) end)
    combobox:SetHandler("OnMouseExit", function() ZO_Options_OnMouseExit(control) end)

    control.CallMultiSelectSetFunc = callMultiSelectSetFunc
    local mouseUp = combobox:GetHandler("OnMouseUp")
    local function onMouseUp(combobox, button, upInside, alt, shift, ctrl, command)
        if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            ClearMenu()
            local dropdown = ZO_ComboBox_ObjectFromContainer(combobox)
            AddMenuItem(GetString(SI_ITEMFILTERTYPE0), function()
                dropdown.m_selectedItemData = {}
                for _, entry in pairs(dropdown.m_sortedItems) do
                    table.insert(dropdown.m_selectedItemData, entry)
                end
                dropdown:RefreshSelectedItemText()
                control:CallMultiSelectSetFunc(nil)
            end)
            AddMenuItem(GetString(SI_KEEPRESOURCETYPE0), function()
                dropdown:ClearAllSelections()
                control.data.setFunc({})
            end)
            ShowMenu(combobox)
        else
            mouseUp(combobox, button, upInside, alt, shift, ctrl, command)
        end
    end
    combobox:SetHandler("OnMouseUp", onMouseUp)
    control.dropdown = ZO_ComboBox_ObjectFromContainer(combobox)
    local dropdown = control.dropdown
    dropdown:SetSortsItems(false) -- need to sort ourselves in order to be able to sort by value

    dropdown.noSelectionText = (multiSelectDropdownData.noSelectionText ~= nil and getDefaultValue(multiSelectDropdownData.noSelectionText)) or GetString(SI_KEEPRESOURCETYPE0)
    dropdown.multiSelectionTextFormatter = (multiSelectDropdownData.multiSelectionTextFormatter and getDefaultValue(multiSelectDropdownData.multiSelectionTextFormatter))
            or "<<1[$d " .. translation.ENTRY .. "/$d ".. translation.ENTRIES .."]>>"

    ZO_PreHook(dropdown, "UpdateItems", function(self)
        assert(not self.m_sortsItems, "built-in dropdown sorting was reactivated, sorting is handled by LAM")
        if control.m_sortOrder ~= nil and control.m_sortType then
            local sortKey = next(control.m_sortType)
            local sortFunc = function(item1, item2) return ZO_TableOrderingFunction(item1, item2, sortKey, control.m_sortType, control.m_sortOrder) end
            table.sort(self.m_sortedItems, sortFunc)
        end
    end)

    if multiSelectDropdownData.sort then
        local sortInfo = GrabSortingInfo(multiSelectDropdownData.sort)
        control.m_sortType, control.m_sortOrder = SORT_TYPES[sortInfo[1]], SORT_ORDERS[sortInfo[2]]
    elseif multiSelectDropdownData.choicesValues then
        control.m_sortType, control.m_sortOrder = ZO_SORT_ORDER_UP, SORT_BY_VALUE
    end

    if multiSelectDropdownData.warning ~= nil or multiSelectDropdownData.requiresReload then
        control.warning = wm:CreateControlFromVirtual(nil, control, "ZO_Options_WarningIcon")
        control.warning:SetAnchor(RIGHT, combobox, LEFT, -5, 0)
        control.UpdateWarning = util.UpdateWarning
        control:UpdateWarning()
    end

    control.UpdateChoices = UpdateChoices
    control:UpdateChoices(multiSelectDropdownData.choices, multiSelectDropdownData.choicesValues)
    control.UpdateValue = UpdateValue
    control:UpdateValue()
    if multiSelectDropdownData.disabled ~= nil then
        control.UpdateDisabled = UpdateDisabled
        control:UpdateDisabled()
    end

    util.RegisterForRefreshIfNeeded(control)
    util.RegisterForReloadIfNeeded(control)

    return control
end


--Load the widget into LAM
local eventAddOnLoadedForWidgetName = widgetName .. "_EVENT_ADD_ON_LOADED"
local function registerWidget(_, addonName)
    if addonName ~= widgetName then return end
    em:UnregisterForEvent(eventAddOnLoadedForWidgetName, EVENT_ADD_ON_LOADED)

    if not LAM:RegisterWidget("multiselectdropdown", widgetVersion) then return end
end
em:RegisterForEvent(eventAddOnLoadedForWidgetName, EVENT_ADD_ON_LOADED, registerWidget)