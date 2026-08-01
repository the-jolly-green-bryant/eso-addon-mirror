local tbug = TBUG or SYSTEMS:GetSystem("merTorchbug")

local wm = WINDOW_MANAGER
local EsoStrings = EsoStrings

local strformat = string.format
local strlow = string.lower
local tos = tostring

local osdate = os.date

local types = tbug.types
local stringType = types.string
local numberType = types.number
local functionType = types.func
local tableType = types.table
local userDataType = types.userdata
local structType = types.struct

local libAS = nil --LibAsync --> Disabled 20241103

local UPDATE_NONE = 0
local UPDATE_SCROLL = 1
local UPDATE_SORT = 2
local UPDATE_FILTER = 3
local UPDATE_MASTER = 4

local earliestTimeStamp = 1
local latestTimeStamp = 2147483647

local RT = tbug.RT
local panelNames = tbug.panelNames
local possibleTranslationTextKeys = tbug.possibleTranslationTextKeys

local valueEdit_CancelThrottled = tbug.valueEdit_CancelThrottled
local valueSlider_CancelThrottled = tbug.valueSlider_CancelThrottled

--local tbug_SetTemplate = tbug.SetTemplate

local hideContextMenus = tbug.HideContextMenus
local getTBUGGlobalInspectorPanelIdByName = tbug.getTBUGGlobalInspectorPanelIdByName
local getGlobalInspector = tbug.getGlobalInspector

local function createPanelFunc(inspector, panelClass)
    local function createPanel(pool)
        local XMLtemplateName = panelClass.TEMPLATE_NAME
        local panelName = panelClass.CONTROL_PREFIX .. pool:GetNextControlId()
        local panelControl = wm:CreateControlFromVirtual(panelName, inspector.control,
                                                         XMLtemplateName)
        return panelClass(panelControl, inspector, pool)
    end
    return createPanel
end


local function resetPanel(panel, pool)
    panel:reset()
end


local function startMovingOnMiddleDown(control, mouseButton)
    if mouseButton == MOUSE_BUTTON_INDEX_MIDDLE then
        local owningWindow = control:GetOwningWindow()
        if owningWindow:StartMoving() then
            --df("tbug: middle down => start moving %s", owningWindow:GetName())
            control.tbugMovingWindow = owningWindow
            return true
        end
    end
end


local function stopMovingOnMiddleUp(control, mouseButton)
    if mouseButton == MOUSE_BUTTON_INDEX_MIDDLE then
        local movingWindow = control.tbugMovingWindow
        if movingWindow then
            --df("tbug: middle up => stop moving %s", movingWindow:GetName())
            movingWindow:StopMovingOrResizing()
            control.tbugMovingWindow = nil
            return true
        end
    end
end


-------------------------------
-- class BasicInspectorPanel --
local classes = tbug.classes
local BasicInspectorPanel = classes.BasicInspectorPanel

--Update the table tbug.panelClassNames with the BasicInspectorPanel class
tbug.panelClassNames["basicInspector"] = BasicInspectorPanel


function BasicInspectorPanel:__init__(control, inspector, pool)
--d("[TBUG]BasicInspectorPanel:__init__")
    self._pool = pool
    self._pendingUpdate = UPDATE_NONE
    self._lockedForUpdates = false
    self.control = assert(control)
    self.inspector = inspector

    local listContents = control:GetNamedChild("ListContents")
    if listContents then
        listContents:SetHandler("OnMouseDown", startMovingOnMiddleDown)
        listContents:SetHandler("OnMouseUp", stopMovingOnMiddleUp)
    end
end

function BasicInspectorPanel:addDataType(typeId, templateName, controlHeight, showCallback, hideCallback)
--d("[TBUG]BasicInspectorPanel:addDataType - typeId: " .. tos(typeId) .. ", templateName: " .. tos(templateName))
    local list = self.list

    local function rowMouseEnter(row)
        local data = ZO_ScrollList_GetData(row)
        self:onRowMouseEnter(row, data)
    end

    local function rowMouseExit(row)
        local data = ZO_ScrollList_GetData(row)
        self:onRowMouseExit(row, data)
    end

    local function rowMouseUp(row, ...)
        if stopMovingOnMiddleUp(row, ...) then
            return
        end
        local data = ZO_ScrollList_GetData(row)
        self:onRowMouseUp(row, data, ...)
    end

    local function rowMouseDoubleClick(row, button, ctrl, alt, shift)
--df("[tbug]rowMouseDoubleClick-button: %s, upInside: %s, ctrl: %s, alt: %s, shift: %s", tos(button), tos(ctrl), tos(alt), tos(shift))
        local data = ZO_ScrollList_GetData(row)
        self:onRowMouseDoubleClick(row, data, button, ctrl, alt, shift)
    end

    local function rowCreate(pool)
        local name = strformat("$(grandparent)%dRow%d", typeId, pool:GetNextControlId())
        local row = wm:CreateControlFromVirtual(name, list.contents, templateName)
        row:SetHandler("OnMouseDown", startMovingOnMiddleDown)
        row:SetHandler("OnMouseEnter", rowMouseEnter)
        row:SetHandler("OnMouseExit", rowMouseExit)
        row:SetHandler("OnMouseUp", rowMouseUp)
        row:SetHandler("OnMouseDoubleClick", rowMouseDoubleClick)
        --tbug_SetTemplate(self, self.cKeyLeft, self.cKeyRight, self.cVal, self.cVal2) --> See templates.xml <OnEffectivelyShown>
        return row
    end


	-- local instanceData = ZO_ScrollList_GetData(control)
	-- local instanceData = dataEntry.data
	controlHeight = controlHeight or function(instanceData)
		return (tbug.savedVars ~= nil and tbug.savedVars.customTemplate ~= nil and tbug.savedVars.customTemplate.height) or 25
	end
	-- Cannot be nil or "ScrollTemplates.lua:1063: operator + is not supported for number + nil"
	local spacingX, spacingY, indentX = 0, 0, 0
    local controlWidth --, selectable, centerEntries
--	ZO_ScrollList_AddDataType(list, typeId, templateName, ...)
	ZO_ScrollList_AddControlOperation(list, typeId, templateName, controlWidth, controlHeight, ZO_ObjectPool_DefaultResetControl, showCallback, hideCallback, spacingX, spacingY, indentX) --, selectable, centerEntries)

    local dataTypeTable = ZO_ScrollList_GetDataTypeTable(list, typeId)
    dataTypeTable.pool = ZO_ObjectPool:New(rowCreate, ZO_ObjectPool_DefaultResetControl) --add reset function
end

--Will be overwritten at the other classes, e.g. ControlInspectorPanel:buildMasterList(), or GlobalInspectorPanel:buildMasterList() ...
function BasicInspectorPanel:buildMasterList(libAsyncTask)
--d("[TBUG]BasicInspectorPanel:buildMasterList")
end


function BasicInspectorPanel:colorRow(row, data, mouseOver)
    local hiBg = row:GetNamedChild("HiBg")
    if hiBg then
        hiBg:SetHidden(not mouseOver)
    end
end


function BasicInspectorPanel:commitScrollList()
--d("[TBUG]BasicInspectorPanel:commitScrollList")
    self:exitRowIf(self._mouseOverRow)
    ZO_ScrollList_Commit(self.list)
end


function BasicInspectorPanel:enterRow(row, data)
    if not self._lockedForUpdates then
        ZO_ScrollList_MouseEnter(self.list, row)
        self:colorRow(row, data, true)
        self._mouseOverRow = row
    end
end


function BasicInspectorPanel:exitRow(row, data)
    if not self._lockedForUpdates then
        ZO_ScrollList_MouseExit(self.list, row)
        self:colorRow(row, data, false)
        self._mouseOverRow = nil
    end
end


function BasicInspectorPanel:exitRowIf(row)
    if row then
        self:exitRow(row, ZO_ScrollList_GetData(row))
    end
end

function BasicInspectorPanel:UpdateContentsCount()
    if not self.inspector or not self.inspector.contentsCount then return end
    self.inspector.contentsCount:SetText("")
    if self.list == nil then return end
    local dataList = ZO_ScrollList_GetDataList(self.list)
    if dataList == nil then return end
    local count = #dataList
    self.inspector.contentsCount:SetText("#" ..tos(count))
end


function BasicInspectorPanel:filterScrollList(libAsyncTask)
--d("[TBUG]BasicInspectorPanel:filterScrollList")
    local masterList = self.masterList
    local filterFunc = self.filterFunc
    local dropdownFilterFunc = self.dropdownFilterFunc
    local dataList = ZO_ScrollList_GetDataList(self.list)

    ZO_ScrollList_Clear(self.list)

    if filterFunc ~= nil or dropdownFilterFunc ~= nil then
        local filterFuncIsFunc = (filterFunc ~= nil and type(filterFunc) == functionType and true) or false
        local dropdownFilterFuncIsFunc = (dropdownFilterFunc ~= nil and type(dropdownFilterFunc) == functionType and true) or false
--d(">filterFuncIsFunc: " .. tos(filterFuncIsFunc) .. ", dropdownFilterFuncIsFunc: " ..tos(dropdownFilterFuncIsFunc))
        local j = 1
--[[
if TBUG.doDebugNow then
    TBUG._debugLastMasterList = ZO_ShallowTableCopy(masterList)
    local dropdownFilterFuncCopy = dropdownFilterFunc
    TBUG._debugDropdownFilterFunc = dropdownFilterFuncCopy
end
]]

        local selfVar = self
        if libAS ~= nil then
            local start = GetGameTimeMilliseconds()
--d("[Tbug]LibAsync - BasicInspectorPanel - filterScrollList - Start")

            libAsyncTask = libAsyncTask or libAS:Create("TBug_task-BasicInspectorPanel-filterScrollList")
            libAsyncTask:For(1, #masterList):Do(function(i)
                local dataEntry = masterList[i]
                local data = dataEntry.data

                local dropdownFilterResult = (dropdownFilterFuncIsFunc == true and dropdownFilterFunc(data, selfVar)) or false --comboBox dropdown filter
                if dropdownFilterResult == false and dropdownFilterFunc == false then dropdownFilterResult = true end

                local textFilterResult = (dropdownFilterResult == true and (filterFuncIsFunc == true and filterFunc(data))) or false --text editbox filter
                if textFilterResult == false and filterFunc == false then textFilterResult = true end

                if dropdownFilterResult == true and textFilterResult == true then
                    dataList[j] = dataEntry
                    j = j + 1
                end
            end):Then(function()
--d("<<<<LibAsync BasicInspectorPanel - filterScrollList - End - Took: " .. tostring(GetGameTimeMilliseconds() - start) .. "ms")
                self:UpdateContentsCount()
            end)

        else
            for i = 1, #masterList do
                local dataEntry = masterList[i]
                local data = dataEntry.data

                local dropdownFilterResult = (dropdownFilterFuncIsFunc == true and dropdownFilterFunc(data, self)) or false --comboBox dropdown filter
                if dropdownFilterResult == false and dropdownFilterFunc == false then dropdownFilterResult = true end

                local textFilterResult = (dropdownFilterResult == true and (filterFuncIsFunc == true and filterFunc(data))) or false --text editbox filter
                if textFilterResult == false and filterFunc == false then textFilterResult = true end

                if dropdownFilterResult == true and textFilterResult == true then
                    dataList[j] = dataEntry
                    j = j + 1
                end
            end
            self:UpdateContentsCount()
        end


    else
        for i = 1, #masterList do
            dataList[i] = masterList[i]
        end
        self:UpdateContentsCount()
    end
end


function BasicInspectorPanel:initScrollList(control)
    --d("[TBUG]BasicInspectorPanel:initScrollList")
    local list = assert(control:GetNamedChild("List"))

    tbug.inspectorScrollLists[list] = self

    self.list = list
    self.compareFunc = false
    self.filterFunc = false
    self.dropdownFilterFunc = false
    self.dropdownFiltersSelected = {}
    self.masterList = {}

    ZO_ScrollList_AddResizeOnScreenResize(list)
    self:setLockedForUpdates(true)

    list:SetHandler("OnEffectivelyShown", function(list)
        ZO_ScrollAreaBarBehavior_OnEffectivelyShown(list)
        list.windowHeight = list:GetHeight()
        self:refreshScroll()
        self:setLockedForUpdates(false)
    end)

    list:SetHandler("OnEffectivelyHidden", function(list)
        ZO_ScrollAreaBarBehavior_OnEffectivelyHidden(list)
        self:setLockedForUpdates(true)
    end)

    local scrollBar = list.scrollbar
    local thumb = scrollBar:GetThumbTextureControl()
    thumb:SetDimensionConstraints(8, 8, 0, 0)

    local function onScrollBarMouseUp(selfScrollbarVar, mouseButton, upInside)
        if upInside then
            valueEdit_CancelThrottled(self.editBox, 100)
            valueSlider_CancelThrottled(self.sliderControl, 100)
        end
    end
    local scrollBarOnMouseUpHandler = scrollBar:GetHandler("OnMouseUp")
    if scrollBarOnMouseUpHandler ~= nil then
        ZO_PostHookHandler(scrollBar, "OnMouseUp", onScrollBarMouseUp)
    else
        scrollBar:SetHandler("OnMouseUp", onScrollBarMouseUp)
    end

    local function onScrollBarMouseDown(selfScrollbarVar, mouseButton)
        --d("[tbug]onScrollBarMouseDown")
        valueEdit_CancelThrottled(self.editBox, 100)
        valueSlider_CancelThrottled(self.sliderControl, 100)
        hideContextMenus()
    end
    local scrollBarOnMouseDownHandler = scrollBar:GetHandler("OnMouseDown")
    if scrollBarOnMouseDownHandler ~= nil then
        ZO_PostHookHandler(scrollBar, "OnMouseDown", onScrollBarMouseDown)
    else
        scrollBar:SetHandler("OnMouseDown", onScrollBarMouseDown)
    end
end


function BasicInspectorPanel:onResizeUpdate(newHeight)
    local list = self.list
    local listHeight = (newHeight ~= nil and newHeight >= tbug.minInspectorWindowHeight and newHeight)
    if listHeight == nil or listHeight == 0 then listHeight = list:GetHeight() end
--d(">onResizeUpdate: " ..tos(listHeight))
    if list.windowHeight ~= listHeight then
        list.windowHeight = listHeight
        ZO_ScrollList_Commit(list)
    end
end


function BasicInspectorPanel:onRowClicked(row, data, mouseButton, ...)
--d("[tbug]BasicInspectorPanel:onRowClicked")
end

function BasicInspectorPanel:onRowDoubleClicked(row, data, mouseButton, ...)
end

local function isTextureRow(rowText)
    if not rowText or type(rowText) ~= stringType or rowText == "" then return end
    local textureString = rowText:match('(%.dds)$')
    if textureString == ".dds" then return true end
    return false
end

local function isMouseCursorRow(row, cursorConstant)
    --d(">isMouseCursorRow: " ..tos(rowText))
    if row._isCursorConstant then return true end
    if not cursorConstant or type(cursorConstant) ~= stringType or cursorConstant == "" then return end
    local mouseCursorName = cursorConstant:match('^MOUSE_CURSOR_GENERIC_.*')
    if mouseCursorName ~= nil then return false end
    mouseCursorName = cursorConstant:match('^MOUSE_CURSOR_.*')
    if mouseCursorName ~= nil then return true end
    return false
end

local blockedTimeStampKeys = {
    ["_frametime"] = true
}
local function isNotBlockedTimeStampKeyOrProp(keyOrProp)
    if type(keyOrProp) == stringType then
        local keyLow = strlow(keyOrProp)
        if not blockedTimeStampKeys[keyLow] and keyLow ~= nil and ((keyLow:match('time') ~= nil or keyLow:match('date') ~= nil)) then
            return true
        end
    end
    return false
end

local function isTimeStampRow(row, data, value)
    if row._isTimeStamp then return true end
    local key = data.key
    local prop = data.prop
    local propName = prop and prop.name
--d(">isTimeStampRow: " ..tos(value) .. ", key: " ..tos(key) .. ", propName: " ..tos(propName))
    if type(value) == numberType and (value >= earliestTimeStamp and value <= latestTimeStamp) then
        if isNotBlockedTimeStampKeyOrProp(key) then
            return true
        else
            if isNotBlockedTimeStampKeyOrProp(propName) then
                return true
            end
        end
    end
    return false
end

local function isTranslationTextRow(row, data, value)
    if row._isTranslationText then return true end
    local key = data.key
    local prop = data.prop
    local propName = prop and prop.name
--d(">isTranslationTextRow: " ..tos(value) .. ", key: " ..tos(key) .. ", propName: " ..tos(propName))
    if value and type(value) == numberType and EsoStrings[value] ~= nil then --Check against SI* constant valid in table tbug.tmpStringIds
        --tooltipText exists? Then descriptor is no number for GetString but just a number
        --todo
        local list = row:GetParent():GetParent()
        if list ~= nil then
            local listData = list.data
            for i=#listData, 1, -1 do
                local dataEntryData = listData[i].data
                if dataEntryData and dataEntryData.key == "tooltipText" then
                    return false
                end
            end
        end

        if key ~= nil and type(key) == stringType then
            local keyLow = strlow(key)
            if keyLow ~= nil and possibleTranslationTextKeys[keyLow] then
                return true
            end
        elseif propName ~= nil and type(propName) == stringType  then
            local propNameLow = strlow(propName)
            if propNameLow ~= nil and possibleTranslationTextKeys[propNameLow] then
                return true
            end
        end
    end
    return false
end

function BasicInspectorPanel:onRowMouseEnter(row, data)
    self:enterRow(row, data)

    if not data then return end
    local key       = data.key
    local prop      = data.prop
    local propName  = (prop and prop.name) or key
    local value     = data.value
--d("[tbug:onRowMouseEnter]key: " ..tos(key) .. ", propName: " ..tos(propName) .. ", value: " ..tos(value))
--[[
tbug._BasicInspectorPanel_onRowMouseEnter = {
    row = row,
    data = data,
    value = value,
    prop = prop,
}
]]

    if propName ~= nil and propName ~= "" and value ~= nil and value ~= "" then
        local typeId = (data.dataEntry ~= nil and data.dataEntry.typeId) or nil
        if typeId ~= nil and typeId == RT.SCRIPTHISTORY_TABLE then
            ZO_ScrollList_MouseEnter(self.list, row)
            local scriptHistoryRowData = ZO_ScrollList_GetData(row)
            if scriptHistoryRowData ~= nil and scriptHistoryRowData.value ~= nil and scriptHistoryRowData.value ~= "" then
                InitializeTooltip(InformationTooltip, row, TOPLEFT, 0, 0, TOPRIGHT)
                SetTooltipText(InformationTooltip, scriptHistoryRowData.value)
            end
        elseif typeId ~= nil and typeId == RT.SAVEDINSPECTORS_TABLE then
            ZO_ScrollList_MouseEnter(self.list, row)
            local savedInspectorsRowData = ZO_ScrollList_GetData(row)
            if savedInspectorsRowData ~= nil and savedInspectorsRowData.tooltip ~= nil and savedInspectorsRowData.tooltip ~= "" then
                InitializeTooltip(InformationTooltip, row, TOPLEFT, 0, 0, TOPRIGHT)
                SetTooltipText(InformationTooltip, savedInspectorsRowData.tooltip)
            end

        else
            --d(">propName:  " ..tos(propName) .. ", value: " ..tos(value))
            --Show the itemlink as ItemTooltip
            if propName == "itemLink" then
                InitializeTooltip(InformationTooltip, row, LEFT, 0, 40)
                InformationTooltip:ClearLines()
                InformationTooltip:SetLink(value)
                --Show the texture as tooltip
            elseif tbug.textureNamesSupported[propName] == true or isTextureRow(value) then
                local width     = (prop and prop.textureFileWidth) or 48
                local height    = (prop and prop.textureFileHeight) or 48
                if width > tbug.maxInspectorTexturePreviewWidth then
                    width = tbug.maxInspectorTexturePreviewWidth
                end
                if height > tbug.maxInspectorTexturePreviewHeight then
                    height = tbug.maxInspectorTexturePreviewHeight
                end
                local textureText = zo_iconTextFormatNoSpace(tostring(value), width, height, "", nil)
                if textureText and textureText ~= "" then
                    ZO_Tooltips_ShowTextTooltip(row, RIGHT, textureText)
                end
                --Change the mouse cursor to the cursor constant below the mouse
            elseif isMouseCursorRow(row, propName) then
                row._isCursorConstant = true
                wm:SetMouseCursor(_G[propName])
                --Add a tooltip to timestamps
            elseif isTimeStampRow(row, data, value) then
                row._isTimeStamp = true
                --Show formated timestamp text tooltip
                local noError, resultStr = pcall(function() return osdate("%c", value) end)
                if noError == true and resultStr ~= nil then
                    ZO_Tooltips_ShowTextTooltip(row, RIGHT, resultStr)
                end
                --Add a translation text to descriptor or other relevant SI* constants
            elseif isTranslationTextRow(row, data, value) then
                local translatedText = GetString(value)
                if translatedText and translatedText ~= "" then
                    ZO_Tooltips_ShowTextTooltip(row, RIGHT, translatedText)
                end
            else
                --Show table's # of entries as tooltip
                if type(value) == tableType and value ~= _G then
                    local tableEntries = NonContiguousCount(value)
                    if tableEntries ~= nil then
                        InitializeTooltip(InformationTooltip, row, LEFT, 20, 0, RIGHT)
                        InformationTooltip:AddLine("#" .. tos(tableEntries) .." entries", "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
                    end
                end
            end
        end
    end
end


function BasicInspectorPanel:onRowMouseExit(row, data)
    self:exitRow(row, data)
    ZO_Tooltips_HideTextTooltip()
    ClearTooltip(InformationTooltip)

    --Reset custom row variables
    if row._isCursorConstant == true then
        wm:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
        row._isCursorConstant = nil
    end
    row._isTimeStamp = nil
    row._isTranslationText = nil
end


function BasicInspectorPanel:onRowMouseUp(row, data, mouseButton, upInside, ...)
    if upInside then
        self:onRowClicked(row, data, mouseButton, ...)
    end
end

function BasicInspectorPanel:onRowMouseDoubleClick(row, data, mouseButton, ...)
    self:onRowDoubleClicked(row, data, mouseButton, ...)
end

function BasicInspectorPanel:readyForUpdate(pendingUpdate)
--d("[TBUG]BasicInspectorPanel:readyForUpdate-pendingUpdateNew: " ..tos(pendingUpdate) .. ", lockedForUpd: " ..tos(self._lockedForUpdates))
    if not self._lockedForUpdates then
        return true
    end
    if self._pendingUpdate < pendingUpdate then
--d(">pendingUpdate changed from: " .. tos(self._pendingUpdate) .. " to: " ..tos(pendingUpdate))
        self._pendingUpdate = pendingUpdate
    end
    return false
end


function BasicInspectorPanel:refreshData()
--d("[TBUG]BasicInspectorPanel:refreshData")
    if self:readyForUpdate(UPDATE_MASTER) then
        local doRefreshDirectly = true
        if libAS ~= nil then
            local currentPanel = self.currentPanel
            --Is global inspector panel?
            if currentPanel and currentPanel.control.isGlobalInspector then
                local currentPanelTabId = getTBUGGlobalInspectorPanelIdByName(currentPanel)
                if currentPanelTabId ~= nil and panelNames[currentPanelTabId].async == true then
                    getGlobalInspector = getGlobalInspector or tbug.getGlobalInspector
                    local globalInspector = getGlobalInspector(true)
                    if globalInspector ~= nil then
                        doRefreshDirectly = false
                        globalInspector:UpdateLoadingState(false)

                        local selfVar = self

                        --local start = GetGameTimeMilliseconds()

                        --Use LibAsync tasks to call the functions
                        local task = libAS:Create("TBug_task-BasicInspector_refreshData")
                        task:Call(function(p_task)
--d("[Tbug]LibAsync - BasicInspectorPanel - refreshData - Start")
                            ---First task
                            --d(">MasterList")
                            selfVar:buildMasterList(p_task)

                        end):Then(function(p_task)
                            --Then:
                            --d(">>FilterScrollList")
                            selfVar:filterScrollList(p_task)
                        end):Then(function(p_task)
                            --Then
                            --d(">>SortScrollList")
                            selfVar:sortScrollList()
                        end):Then(function(p_task)
                            --Final task
                            --d(">>CommitScrollList")
                            selfVar:commitScrollList()
                            globalInspector:UpdateLoadingState(true)
                        end):Then(function()
--d("<<<<<LibAsync - BasicInspectorPanel - refreshData - End, took: " .. tostring(GetGameTimeMilliseconds() - start) .. "ms")
                        end)
                    end
                end
            end
        end
        if doRefreshDirectly then
            --d(">MasterList")
            self:buildMasterList()
            --d(">>FilterScrollList")
            self:filterScrollList()
            --d(">>SortScrollList")
            self:sortScrollList()
            --d(">>CommitScrollList")
            self:commitScrollList()
        end
    end
end


function BasicInspectorPanel:refreshFilter(override)
    override = override or false
--d("[TBUG]BasicInspectorPanel:refreshFilter-override: " ..tos(override))
    if override == true or self:readyForUpdate(UPDATE_FILTER) then
--d(">filter update starting")
        self:filterScrollList()
        self:sortScrollList()
        self:commitScrollList()
    end
end


function BasicInspectorPanel:refreshScroll()
    if self:readyForUpdate(UPDATE_SCROLL) then
        self:commitScrollList()
    end
end


function BasicInspectorPanel:refreshSort()
    if self:readyForUpdate(UPDATE_SORT) then
        self:sortScrollList()
        self:commitScrollList()
    end
end


function BasicInspectorPanel:refreshVisible()
    ZO_ScrollList_RefreshVisible(self.list)
end


function BasicInspectorPanel:release()
    if self._pool and self._pkey then
        if self.list ~= nil then
            tbug.inspectorScrollLists[self.list] = nil
        end
        self._pool:ReleaseObject(self._pkey)
    end
end


function BasicInspectorPanel:reset()
end


function BasicInspectorPanel:setFilterFunc(filterFunc, forceRefresh)
    forceRefresh = forceRefresh or false
    if tbug.doDebug then d("[TBUG]BasicInspectorPanel:setFilterFunc: " ..tos(filterFunc) .. ", forceRefresh: " ..tos(forceRefresh)) end
--d("[TBUG]BasicInspectorPanel:setFilterFunc: " ..tos(filterFunc) .. ", forceRefresh: " ..tos(forceRefresh))
    if forceRefresh == true or self.filterFunc ~= filterFunc then
--d(">filterFunc change")
        self.filterFunc = filterFunc
        self:refreshFilter(true)
    end
end

function BasicInspectorPanel:setDropDownFilterFunc(dropdownFilterFunc, selectedDropdownFilters)
    if tbug.doDebug then d("[TBUG]BasicInspectorPanel:setDropDownFilterFunc: " ..tos(dropdownFilterFunc)) end

--tbug._debug = tbug._debug or {}
--tbug._debug.dropdownFiltersSelected = selectedDropdownFilters

--d("[TBUG]BasicInspectorPanel:setDropDownFilterFunc: " ..tos(dropdownFilterFunc) .. ", #selectedDropdownFilters: " ..tos(selectedDropdownFilters))
    if self.dropdownFilterFunc ~= dropdownFilterFunc then
        self.dropdownFilterFunc = dropdownFilterFunc
        self.dropdownFiltersSelected = selectedDropdownFilters
--d(">refreshing the filters")
        self:refreshFilter(true)
    end
end

function BasicInspectorPanel:setLockedForUpdates(locked)
    if self._lockedForUpdates ~= locked then
        self._lockedForUpdates = locked
        if locked then
            return
        end
    else
        return
    end

    self:exitRowIf(self._mouseOverRow)

    local pendingUpdate = self._pendingUpdate
    self._pendingUpdate = UPDATE_NONE

    if pendingUpdate >= UPDATE_SCROLL then
        if pendingUpdate >= UPDATE_SORT then
            if pendingUpdate >= UPDATE_FILTER then
                if pendingUpdate >= UPDATE_MASTER then
                    self:buildMasterList()
                end
                self:filterScrollList()
            end
            self:sortScrollList()
        end
        self:commitScrollList()
    end
end


function BasicInspectorPanel:setupRow(row, data)
    row._isCursorConstant = nil
    if self._lockedForUpdates then
        self:colorRow(row, data, self._mouseOverRow == row)
    elseif MouseIsOver(row) then
        self:enterRow(row, data)
    else
        self:colorRow(row, data, false)
    end
end


function BasicInspectorPanel:sortScrollList()
    local compareFunc = self.compareFunc
    if compareFunc then
        local dataList = ZO_ScrollList_GetDataList(self.list)
        table.sort(dataList, compareFunc)
    end
end

function BasicInspectorPanel:valueEditCancel(editBox)
    --Needs to be overriden
end

function BasicInspectorPanel:valueSliderCancel(sliderCtrl)
    --Needs to be overriden
end


--------------------------
-- class BasicInspector --
local TabWindow = classes.TabWindow
local BasicInspector = classes.BasicInspector .. TabWindow


function BasicInspector:__init__(id, control)
--d("[TBUG]BasicInspectorPanel:__init__ - id: " .. tos(id))
    TabWindow.__init__(self, control, id)
    self.panelPools = {}
end

--panelData: The data of the panel from table tbug.panelNames
function BasicInspector:acquirePanel(panelClass)
--d("[TBUG]BasicInspector:acquirePanel - panelClass: " ..tos(panelClass))

    local pool = self.panelPools[panelClass]
    if not pool then
        pool = ZO_ObjectPool:New(createPanelFunc(self, panelClass), resetPanel)
        self.panelPools[panelClass] = pool
    end
    local panel, pkey = pool:AcquireObject()
    panel._pkey = pkey
    return panel
end