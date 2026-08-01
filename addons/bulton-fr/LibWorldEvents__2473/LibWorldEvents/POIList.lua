LibWorldEvents.POIList = ZO_SortFilterList:Subclass()

LibWorldEvents.POIList.masterList = {}

--[[
-- Instanciate a new ZO_SortFilterList which use us and return it
--
-- @return ZO_SortFilterList
--]]
function LibWorldEvents.POIList:New(control)
	return ZO_SortFilterList.New(self, control)
end

--[[
-- @inheritdoc
--]]
function LibWorldEvents.POIList:Initialize(control)
    ZO_SortFilterList.Initialize(self, control)

	ZO_ScrollList_AddDataType(
        self.list,
        1,
        "LibWorldEventPOIListUIRow",
        30,
        function(control, data)
            self:SetupItemRow(control, data)
        end
    )
end

--[[
-- @inheritdoc
--]]
function LibWorldEvents.POIList:BuildMasterList()
    self.masterList = {}

    local currentZoneId  = GetZoneId(GetCurrentMapZoneIndex())
    local currentZoneIdx = GetZoneIndex(currentZoneId)
    local poiId = 1
    local maxId = 3000

    for poiId=1,maxId do
        local zoneIdx, poiIdx = GetPOIIndices(poiId)
        local name = GetPOIInfo(zoneIdx, poiIdx)
        local _, _, _, icon = GetPOIMapInfo(zoneIdx, poiIdx)

        if zoneIdx == currentZoneIdx then
            if zoneIdx and poiIdx then
                table.insert(
                    self.masterList,
                    {
                        id   = poiId,
                        idx  = poiIdx,
                        icon = icon,
                        name = name
                    }
                )
            end
        end
    end
end

--[[
-- @inheritdoc
-- Note : Populate the ScrollList's rows, using our data model as a source.
--]]
function LibWorldEvents.POIList:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    for i = 1, #self.masterList do
        local data = self.masterList[i]
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end
end

--[[
-- @inheritdoc
-- Define each row
--]]
function LibWorldEvents.POIList:SetupItemRow(control, data)
    control.data = data
    
    local labelId   = control:GetNamedChild("Id")
    local labelIdx  = control:GetNamedChild("Idx")
    local labelIcon = control:GetNamedChild("Icon")
    local labelName = control:GetNamedChild("Name")

    labelId:SetText(data.id)
    labelIdx:SetText(data.idx)
    labelName:SetText(zo_strformat(data.name))
    labelIcon:SetTexture(data.icon)
end

SLASH_COMMANDS["/libwe"] = function(param)
    if param == "show" then
        LibWorldEventPOIListUI:SetHidden(false)
        LibWorldEventPOIListUIZone:SetText(zo_strformat(
            "Current zone ID = <<1>> / Current mapName=<<2>>",
            GetZoneId(GetCurrentMapZoneIndex()),
            LibMapPins:GetZoneAndSubzone(true)
        ))
        LibWorldEvents.list:RefreshData()
    elseif param == "hide" then
        LibWorldEventPOIListUI:SetHidden(true)
    end
end
