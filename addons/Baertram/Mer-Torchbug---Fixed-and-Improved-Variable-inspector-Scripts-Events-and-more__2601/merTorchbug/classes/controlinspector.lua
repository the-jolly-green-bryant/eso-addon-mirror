local tbug = TBUG or SYSTEMS:GetSystem("merTorchbug")

local tos = tostring
local ton = tonumber
local strformat = string.format

local types = tbug.types
local stringType = types.string
local numberType = types.number
local functionType = types.func
local tableType = types.table
local userDataType = types.userdata
local structType = types.struct

local libAS = LibAsync_NONEXISTING --currently disabled! 20250509

local typeColors = tbug.cache.typeColors

local rowTypes = tbug.RowTypes
local childrenNumberHeaderStr = "Children (%s)"

local tbug_inspect = tbug.inspect

local tbug_buildRowContextMenuData = tbug.buildRowContextMenuData
local tbug_glookup = tbug.glookup
local tbug_glookupEnum = tbug.glookupEnum

local controlInspectorDataTypes = tbug.controlInspectorDataTypes

local invoke = tbug.invoke
local getControlName = tbug.getControlName
local getControlType = tbug.getControlType

local hideContextMenus = tbug.HideContextMenus
local valueSlider_CancelThrottled = tbug.valueSlider_CancelThrottled
local setLastRowClickedData = tbug.setLastRowClickedData

---------------------------------
-- class ControlInspectorPanel --
local classes = tbug.classes
local ObjectInspectorPanel = classes.ObjectInspectorPanel
local ControlInspectorPanel = classes.ControlInspectorPanel .. ObjectInspectorPanel

ControlInspectorPanel.CONTROL_PREFIX = "$(parent)PanelC"
ControlInspectorPanel.TEMPLATE_NAME = "tbugControlInspectorPanel"

--Update the table tbug.panelClassNames with the ControlInspectorPanel class
tbug.panelClassNames["controlInspector"] = ControlInspectorPanel



function ControlInspectorPanel:__init__(control, ...)
    ObjectInspectorPanel.__init__(self, control, ...)
end


local function createPropEntry(data)
    -->Created within "ControlInspectorPanel:initScrollList" for the list
    return ZO_ScrollList_CreateDataEntry(data.prop.typ, data)
end


local function getControlChild(data, control)
    return control:GetChild(data.childIndex)
end


function ControlInspectorPanel:buildMasterList(libAsyncTask)
    --d("[tbug]ControlInspectorPanel:buildMasterList")
    local g_specialProperties = controlInspectorDataTypes.g_specialProperties
    local g_controlPropListRow = controlInspectorDataTypes.g_controlPropListRow
    local td = tbug.td

    local masterList, n = self.masterList, 0
    local subject = self.subject
    local _, controlType = pcall(invoke, subject, "GetType")
    local _, numChildren = pcall(invoke, subject, "GetNumChildren")
    if numChildren == nil then numChildren = 0 end
    local childrenHeaderId

    local _parentSubject = self._parentSubject
    local controlPropsListRows = g_controlPropListRow[controlType]
    local controlProps = g_specialProperties[controlType]

    local loopBeforeDone = true

    if libAS ~= nil then
        local start = GetGameTimeMilliseconds()

        libAsyncTask = libAsyncTask or libAS:Create("TBug_task-ControlInspectorPanel-builMasterList")

        --Add the _parentControl -> if you are at a __index invoked metatable control
        -->adds the "__Object" name
        libAsyncTask:Call(function(p_task)
--d("[Tbug]LibAsync - ControlInspector - Start")
            if _parentSubject ~= nil then
                loopBeforeDone = false
--d(">>commonProperties_parentSubject")
                p_task:For(ipairs(controlInspectorDataTypes.commonProperties_parentSubject)):Do(function(key, prop)
                    local doAdd = true
                    if prop.checkFunc then
                        doAdd = prop.checkFunc(subject)
                    end
                    if doAdd == true then
                        n = n + 1
                        masterList[n] = createPropEntry{prop = prop}
                    end
                end)
                loopBeforeDone = true
            end

            --Common properties (e.g. name, type, parent) added to the inspector list
            libAS:WaitUntil(function()
                return loopBeforeDone == true
            end):Then(function()
--d(">>g_commonProperties")
                loopBeforeDone = false
                p_task:For(ipairs(controlInspectorDataTypes.g_commonProperties)):Do(function(key, prop)
                    local doAdd = true
                    if prop.checkFunc then
                        doAdd = prop.checkFunc(subject)
                    end
                    if doAdd == true then
                        n = n + 1
                        masterList[n] = createPropEntry{prop = prop}
                    end
                end)
                loopBeforeDone = true
            end)

            --CT_* control properties added to the inspector list
            if controlPropsListRows then
                libAS:WaitUntil(function()
                    return loopBeforeDone == true
                end):Then(function()
                    loopBeforeDone = false
                    local _, controlName = pcall(invoke, subject, "GetName")
                    if controlName and controlName ~= "" then
                        if tbug.isSupportedInventoryRowPattern(controlName) == true then
--d(">>controlPropsListRows")
                            p_task:For(ipairs(controlPropsListRows)):Do(function(key, prop)
                                n = n + 1
                                masterList[n] = createPropEntry{prop = prop}
                            end)
                        end
                    end
                    loopBeforeDone = true
                end)
            end

            --Common properties part 2 (e.g. anchors, dimensions) added to the inspector list
            libAS:WaitUntil(function()
                return loopBeforeDone == true
            end):Then(function()
                loopBeforeDone = false
--d(">>g_commonProperties2")
                p_task:For(ipairs(controlInspectorDataTypes.g_commonProperties2)):Do(function(key, prop)
                    n = n + 1
                    masterList[n] = createPropEntry{prop = prop}
                end)
                loopBeforeDone = true
            end)

            --Special properties (e.g. bagId/slotIndex/itemLink) added to the inspector list
            if controlProps then
                libAS:WaitUntil(function()
                    return loopBeforeDone == true
                end):Then(function()
                    loopBeforeDone = false
--d(">>controlProps")
                    p_task:For(ipairs(controlProps)):Do(function(key, prop)
                        if prop.isChildrenHeader == true then
                            childrenHeaderId = prop.headerId
                            prop.name = strformat(childrenNumberHeaderStr, tos(numChildren))
                        end
                        n = n + 1
                        masterList[n] = createPropEntry{prop = prop}
                    end)
                    loopBeforeDone = true
                end)
            end

            --Explicit CT_CONTROL properties added to the inspector list
            if controlType ~= CT_CONTROL then
                libAS:WaitUntil(function()
                    return loopBeforeDone == true
                end):Then(function()
                    loopBeforeDone = false
--d(">>g_specialProperties[CT_CONTROL]")
                    p_task:For(ipairs(g_specialProperties[CT_CONTROL])):Do(function(key, prop)
                        if prop.isChildrenHeader == true then
                            childrenHeaderId = prop.headerId
                            prop.name = strformat(childrenNumberHeaderStr, tos(numChildren))
                        end
                        n = n + 1
                        masterList[n] = createPropEntry{prop = prop}
                    end)
                    loopBeforeDone = true
                end)
            end

            --Child controls
            libAS:WaitUntil(function()
                return loopBeforeDone == true
            end):Then(function()
                loopBeforeDone = false

                tbug.tdBuildChildControls = true
--d(">>children")
                p_task:For(1, ton(numChildren) or 0):Do(function(i)
                    local childProp = td{name = tos(i), get = getControlChild, enum = "CT_names", parentId=childrenHeaderId}
                    n = n + 1
                    masterList[n] = createPropEntry{prop = childProp, childIndex = i}
                end)
                :Then(function()
                    tbug.tdBuildChildControls = false
                    childrenHeaderId = nil

                    loopBeforeDone = true
        --d(">>truncate")
                    tbug.truncate(masterList, n)
        --d("<<<<<<< END - took: " .. tostring(GetGameTimeMilliseconds() - start) .. "ms")
                end)
            end)
        end)

    ------------------------------------------------------------------------------------------------------------------------
    else
        --Add the _parentControl -> if you are at a __index invoked metatable control
        -->adds the "__Object" name
        if _parentSubject ~= nil then
            for _, prop in ipairs(controlInspectorDataTypes.commonProperties_parentSubject) do
                local doAdd = true
                if prop.checkFunc then
                    doAdd = prop.checkFunc(subject)
                end
                if doAdd == true then
                    n = n + 1
                    masterList[n] = createPropEntry{prop = prop}
                end
            end
        end

        --Common properties (e.g. name, type, parent) added to the inspector list
        for _, prop in ipairs(controlInspectorDataTypes.g_commonProperties) do
            local doAdd = true
            if prop.checkFunc then
                doAdd = prop.checkFunc(subject)
            end
            if doAdd == true then
                n = n + 1
                masterList[n] = createPropEntry{prop = prop}
            end
        end

        --CT_* control properties added to the inspector list
        if controlPropsListRows then
            local _, controlName = pcall(invoke, subject, "GetName")
            if controlName and controlName ~= "" then
                if tbug.isSupportedInventoryRowPattern(controlName) == true then
                    for _, prop in ipairs(controlPropsListRows) do
                        n = n + 1
                        masterList[n] = createPropEntry{prop = prop}
                    end
        --else
                end
            end
        end

        --Common properties part 2 (e.g. anchors, dimensions) added to the inspector list
        for _, prop in ipairs(controlInspectorDataTypes.g_commonProperties2) do
            n = n + 1
            masterList[n] = createPropEntry{prop = prop}
        end

        --Special properties (e.g. bagId/slotIndex/itemLink) added to the inspector list
        if controlProps then
            for _, prop in ipairs(controlProps) do
                if prop.isChildrenHeader == true then
                    childrenHeaderId = prop.headerId
                    prop.name = strformat(childrenNumberHeaderStr, tos(numChildren))
                end
                n = n + 1
                masterList[n] = createPropEntry{prop = prop}
            end
        end

        --Explicit CT_CONTROL properties added to the inspector list
        if controlType ~= CT_CONTROL then
            for _, prop in ipairs(g_specialProperties[CT_CONTROL]) do
                if prop.isChildrenHeader == true then
                    childrenHeaderId = prop.headerId
                    prop.name = strformat(childrenNumberHeaderStr, tos(numChildren))
                end
                n = n + 1
                masterList[n] = createPropEntry{prop = prop}
            end
        end

        --Child controls
        tbug.tdBuildChildControls = true
        for i = 1, ton(numChildren) or 0 do
            local childProp = td{name = tos(i), get = getControlChild, enum = "CT_names", parentId=childrenHeaderId}
            n = n + 1
            masterList[n] = createPropEntry{prop = childProp, childIndex = i}
        end
        tbug.tdBuildChildControls = false
        childrenHeaderId = nil

        tbug.truncate(masterList, n)
    end
end


function ControlInspectorPanel:canEditValue(data)
    return data.prop.set ~= nil
end


function ControlInspectorPanel:initScrollList(control)
    ObjectInspectorPanel.initScrollList(self, control)

    local function setupValue(cell, typ, val)
        if typ ~= nil then
            cell:SetColor(typeColors[typ]:UnpackRGBA())
        end
        cell:SetText(tos(val))
    end

    local function setupValueLookup(cell, typ, val)
        cell:SetColor(typeColors[typ]:UnpackRGBA())
        local name = tbug_glookup(val)
        if name then
            cell:SetText(strformat("%s: %s", typ, name))
        else
            cell:SetText(tos(val))
        end
    end

    local function setupHeader(row, data, list)
        row.label:SetText(data.prop.name)
    end

    local function setupSimple(row, data, list)
        local prop = data.prop
        local getter = prop.get
        local ok, v

        if type(getter) == functionType then
            ok, v = pcall(getter, data, self.subject, self)
        else
            ok, v = pcall(invoke, self.subject, getter)
        end
        local k = prop.name
        local tk = (k == "__index" and "event" or type(k))
        local tv = type(v)
        data.value = v

        self:setupRow(row, data)
        setupValue(row.cKeyLeft, tk, k)
        setupValue(row.cKeyRight, tk, "")

        if tv == stringType then
            setupValue(row.cVal, tv, strformat("%q", v))
            if prop.isColor and prop.isColor == true then
                setupValue(row.cKeyRight, nil, "[COLOR EXAMPLE, click to change]")
                local currentColor = tbug.parseColorDef(v)
                row.cKeyRight:SetColor(currentColor:UnpackRGBA())
            end
        elseif tv == numberType then
            local enum = prop.enum
            if enum then
                local nv = tbug_glookupEnum(enum)[v]
                if v ~= nv then
                    setupValue(row.cKeyRight, tv, nv)
                end
            end
            setupValue(row.cVal, tv, v)
        elseif tv == userDataType then
            local ct, ctName = getControlType(v, prop.enum)
            if ct then
                setupValue(row.cKeyRight, type(ct), ctName)
                setupValue(row.cVal, tv, getControlName(v))
                return
            end
            setupValueLookup(row.cVal, tv, v)
        else
            setupValueLookup(row.cVal, tv, v)
        end
    end

    local function hideCallback(row, data)
        if self.editData == data then
            self.editBox:ClearAnchors()
            self.editBox:SetAnchor(BOTTOMRIGHT, nil, TOPRIGHT, 0, -20)
        end
    end

    --Using height param = nil will read the actual height from the tbug.UITemplates/savedVariables
    --> See basicInspector:addDataType
    self:addDataType(rowTypes.ROW_TYPE_HEADER,   "tbugTableInspectorHeaderRow",  nil, setupHeader, hideCallback)
    self:addDataType(rowTypes.ROW_TYPE_PROPERTY, "tbugTableInspectorRow",        nil, setupSimple, hideCallback)
end

function ControlInspectorPanel:onRowClicked(row, data, mouseButton, ctrl, alt, shift)
    if tbug.doDebug then
        --d("[TBUG]ControlInspector:onRowClicked")
        tbug._debugControlInspectorRowClicked = {
            row = row,
            data = data,
            self = self,
        }
    end
    setLastRowClickedData("control", self, nil, nil)

    hideContextMenus()
    local sliderCtrl = self.sliderControl
    if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
        self.editBox:LoseFocus()
        if sliderCtrl ~= nil then
            --sliderCtrl.panel:valueSliderCancel(sliderCtrl)
            valueSlider_CancelThrottled(sliderCtrl, 50)
        end

        if MouseIsOver(row.cKeyRight) then
            local prop = data.prop
            if prop and prop.isColor and prop.isColor == true then
                tbug.showColorPickerAtRow(self, row, data)
            end
        else
            local title = data.prop.name
            --Control got children and we clicked any of them?
            -->Show the children's name at the tab, and no abbreviated string
            data.childName = nil
            data.specialMasterlistType = nil

            if data.childIndex ~= nil then
                -- data.prop.name is just the string form of data.childIndex,
                -- it's better to use the child's name for title in this case
                local ok, name = pcall(invoke, data.value, "GetName")
--d(">child name: " ..tos(name))
                if ok then

                    --Check if the parent name contains the childname and only show the child's name as title
                    -->20230124: Add the total childName as info to the data table too!
                    local parentName = getControlName(self.subject)
--d(">parentName name: " ..tos(parentName))
                    local ms, me = name:find(parentName, 1, true)
                    if ms == 1 and me < #name then
                        -- take only the part after the parent's name
                        title = name:sub(me + 1)
                        data.childName = name
                    else
                        title = name
                    end
                    title = name
                end
--d(">title: " ..tos(title))
            else
                --Get metatable of a control? Save the subjectParent
                if title == "__index" then
--d(">clicked on __index")
                    --Add the subject as new line __Object to the inspector result rows
                    local subject = self.subject
                    data._parentSubject = subject
                end
            end

            setLastRowClickedData("control", self, row, data)
            if shift then
                --object, tabTitle, winTitle, recycleActive, objectParent, currentResultIndex, allResults, data
                local inspector = tbug_inspect(data.value, title, nil, false, nil, nil, nil, data, nil)
                if inspector then
                    inspector.control:BringWindowToTop()
                end
            else
                self.inspector:openTabFor(data.value, title, nil, nil, data, nil, true)
            end
        end
    elseif mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
        self.editBox:LoseFocus()
        local mouseIsOverRightKey = MouseIsOver(row.cKeyRight)
        if MouseIsOver(row.cVal) then
            if sliderCtrl ~= nil then
                --sliderCtrl.panel:valueSliderCancel(sliderCtrl)
                valueSlider_CancelThrottled(sliderCtrl, 50)
            end
            if self:canEditValue(data) then
                self:valueEditStart(self.editBox, row, data)
            end
            tbug_buildRowContextMenuData(self, row, data, false, nil)
        elseif mouseIsOverRightKey or MouseIsOver(row.cKeyLeft) then
            self.editBox:LoseFocus()
            if sliderCtrl ~= nil then
                --sliderCtrl.panel:valueSliderCancel(sliderCtrl)
                valueSlider_CancelThrottled(sliderCtrl, 50)
            end
            tbug_buildRowContextMenuData(self, row, data, true, mouseIsOverRightKey)
        else
            self.editBox:LoseFocus()
            if sliderCtrl ~= nil then
                --sliderCtrl.panel:valueSliderCancel(sliderCtrl)
                valueSlider_CancelThrottled(sliderCtrl, 50)
            end
        end
    end
end

function ControlInspectorPanel:onRowDoubleClicked(row, data, mouseButton, ctrl, alt, shift)
--df("tbug:ControlInspectorPanel:onRowDoubleClicked")
    hideContextMenus()
    if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
        if MouseIsOver(row.cVal) then
            if self:canEditValue(data) then
                if type(data.value) == "boolean" then
                    local oldValue = data.value
                    if oldValue == true then
                        data.value = false
                    else
                        data.value = true
                    end
                    tbug.setEditValueFromContextMenu(self, row, data, oldValue)
                else
                    local prop = data.prop
                    if prop and prop.isColor and prop.isColor == true then
                        tbug.showColorPickerAtRow(self, row, data)
                    end
                end
            end
        end
    end
end

function ControlInspectorPanel:valueEditConfirmed(editBox, evalResult)
    local editData = self.editData
    if editData then
        local setter = editData.prop.set
        local ok, setResult
        if type(setter) == functionType then
            ok, setResult = pcall(setter, editData, self.subject, evalResult)
        else
            ok, setResult = pcall(invoke, self.subject, setter, evalResult)
        end
        if not ok then
            return setResult
        end
        self.editData = nil
        -- the modified value might affect multiple related properties,
        -- so we have to refresh all visible rows, not just editData
        ZO_ScrollList_RefreshVisible(self.list)
    end
    editBox:LoseFocus()
end

function ControlInspectorPanel:valueSliderConfirmed(sliderControl, evalResult)
--d("ControlInspectorPanel:valueSliderConfirmed-evalResult: "..tos(evalResult))
    ZO_Tooltips_HideTextTooltip()
    local sliderData = self.sliderData
    if sliderData then
        local setter = sliderData.prop.set
        local ok, setResult
        if type(setter) == functionType then
            ok, setResult = pcall(setter, sliderData, self.subject, ton(evalResult))
        else
            ok, setResult = pcall(invoke, self.subject, setter, ton(evalResult))
        end
--d(">>ok: " ..tos(ok) .. ", setResult: " .. tos(setResult))
        if not ok then
            return setResult
        end
        self.sliderData = nil
        -- the modified value might affect multiple related properties,
        -- so we have to refresh all visible rows, not just sliderData
        ZO_ScrollList_RefreshVisible(self.list)
    end
end