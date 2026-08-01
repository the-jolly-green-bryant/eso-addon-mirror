LootTrackerSolution.SolutionScrollList = {}

function LootTrackerSolution.SolutionScrollList.UpdateScrollList(control, data, rowType)

    local dataCopy = ZO_DeepTableCopy(data)
    local dataList = ZO_ScrollList_GetDataList(control)

    ZO_ScrollList_Clear(control)

    for key, value in ipairs(dataCopy) do
        local entry = ZO_ScrollList_CreateDataEntry(rowType, value)
        table.insert(dataList, entry) 
    end

    ZO_ScrollList_Commit(control)
end

function LootTrackerSolution.SolutionScrollList.ClearList(control)
    ZO_ScrollList_Clear(control)
    ZO_ScrollList_Commit(control)
end

function LootTrackerSolution.SolutionScrollList.CreateScrollList(name, parent, layoutRow, onRowSelect, tName, rHeight)
    local control = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_ScrollList")
    local width, height = parent:GetDimensions()
    control:SetDimensions(width - 14, height - 71)
    control:SetAnchor(CENTER, parent, CENTER, 7, 10)

    local typeId = 1
    local templateName = tName
    local rowHeight = rHeight or 30
    local setupFunction = layoutRow
    local hideCallback = nil
    local dataTypeSelectSound = nil
    local resetControlCallback = nil

    control.scrollData = {}
    ZO_ScrollList_AddDataType(control, typeId, templateName, rowHeight, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
    ZO_ScrollList_SetTypeSelectable(control, typeId, true)
    ZO_ScrollList_EnableSelection(control, "ZO_ThinListHighlight", onRowSelect)

    return control
end