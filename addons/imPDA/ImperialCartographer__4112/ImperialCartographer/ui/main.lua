local SCROLL_LIST_CONTROL
-- local DISCOVERED_POIS_CONTROL

-- local IC = ImperialCartographer

local DEFAULT = 1
local USER_ADDED = 2
local UNDISCOVERED = 3

local CURRENT_ZONE_NAME_COLOR = {0, 1, 0}
local DEFAULT_ZONE_NAME_COLOR = {1, 1, 1}

local TOTAL_LIST = {}
local function createTotalList()
    for zoneIndex = 1, GetNumZones() do
        TOTAL_LIST[zoneIndex] = {}

        for poiIndex = 1, GetNumPOIs(zoneIndex) do
            local objectiveName, objectiveLevel, startDescription, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)
            if objectiveName and objectiveName ~= '' then
                TOTAL_LIST[zoneIndex][poiIndex] = UNDISCOVERED
            end
        end
    end

    for poiId, _ in pairs(ImperialCartographer.DefaultPOIsData) do
        local zoneIndex, poiIndex = GetPOIIndices(poiId)
        TOTAL_LIST[zoneIndex][poiIndex] = DEFAULT
    end
end

do
    createTotalList()
end

local function showTextTooltip(rowControl, zoneIndex)
    local rows = {}

    for poiIndex, status in pairs(TOTAL_LIST[zoneIndex]) do
        local objectiveName, objectiveLevel, startDescription, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)
        local x, z = GetPOIMapInfo(zoneIndex, poiIndex)
        if status == DEFAULT then
            -- rows[#rows+1] = ('|c00FF00[V]|r %s'):format(objectiveName)
        else
            rows[#rows+1] = ('|cFF0000[X]|r %s (%.2f, %.2f)'):format(objectiveName, x * 100, z * 100)
        end
    end

    if #rows == 0 then return end

    local tooltip = table.concat(rows, '\n')

    ZO_Tooltips_ShowTextTooltip(rowControl, LEFT, tooltip)
end

local function CreateScrollListDataType(listControl)
    local function LayoutRow(rowControl, data, scrollList)
        local zoneIndex = data.zoneIndex
        local poiDiscovered = data.poiDiscovered
        local poiTotal = data.poiTotal
        -- local poiTotalV2 = GetNumPOIs(zoneIndex)

        local characterZoneIndex = GetUnitZoneIndex('player')
        local currentZone = characterZoneIndex == zoneIndex
        local color = currentZone and CURRENT_ZONE_NAME_COLOR or DEFAULT_ZONE_NAME_COLOR

        GetControl(rowControl, 'Index'):SetText(('%d / %d'):format(zoneIndex, GetZoneId(zoneIndex)))
        GetControl(rowControl, 'Index'):SetColor(unpack(color))
        GetControl(rowControl, 'Name'):SetText(zo_strformat(SI_ZONE_NAME, GetZoneNameByIndex(zoneIndex)))
        GetControl(rowControl, 'Name'):SetColor(unpack(color))
        -- GetControl(rowControl, 'Discovered'):SetText(('%d / %d (%d)'):format(poiDiscovered, poiTotal, poiTotalV2))
        GetControl(rowControl, 'Discovered'):SetText(('%d / %d'):format(poiDiscovered, poiTotal))

        if poiDiscovered == poiTotal and poiTotal ~= 0 then
            GetControl(rowControl, 'Discovered'):SetColor(0, 1, 0)
        else
            GetControl(rowControl, 'Discovered'):SetColor(1, 65/255, 0)
        end

        rowControl:SetHandler('OnMouseEnter', function() showTextTooltip(rowControl, zoneIndex) end)
        rowControl:SetHandler('OnMouseExit', ZO_Tooltips_HideTextTooltip)
    end

	local control = listControl
	local typeId = 1
	local templateName = 'IMP_CART_DiscoveredPOIRowTemplate'
	local height = 32
	local setupFunction = LayoutRow
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil

	ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)

    -- local selectTemplate = 'ZO_ThinListHighlight'
	-- local selectCallback = nil
	-- ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)

    SCROLL_LIST_CONTROL = listControl
end

local SUMMARY_TABLE = {}
local function updateSummary()
    -- ZO_ClearTable(SUMMARY_TABLE)

    local grandTotalDiscovered = 0
    local grandTotal = 0

    for zoneIndex = 1, GetNumZones() do
        local totalDefault = 0
        local totalUserAdded = 0
        local totalUndiscovered = 0

        if not SUMMARY_TABLE[zoneIndex] then SUMMARY_TABLE[zoneIndex] = {} end

        for poiIndex, status in pairs(TOTAL_LIST[zoneIndex]) do
            if status == DEFAULT then
                totalDefault = totalDefault + 1
            elseif status == USER_ADDED then
                totalUserAdded = totalUserAdded + 1
            elseif status == UNDISCOVERED then
                totalUndiscovered = totalUndiscovered + 1
            end
        end

        local totalDiscovered = totalDefault + totalUserAdded

        SUMMARY_TABLE[zoneIndex][1] = totalDiscovered
        SUMMARY_TABLE[zoneIndex][2] = totalDiscovered + totalUndiscovered

        grandTotalDiscovered = grandTotalDiscovered + totalDiscovered
        grandTotal = grandTotal + totalDiscovered + totalUndiscovered
    end

    -- for poiId, poiData in pairs(ImperialCartographer.DefaultPOIsData) do
    --     local zoneIndex, poiIndex = GetPOIIndices(poiId)
    --     -- if not SUMMARY_TABLE[zoneIndex] then SUMMARY_TABLE[zoneIndex] = {0, 0} end
    --     SUMMARY_TABLE[zoneIndex][1] = SUMMARY_TABLE[zoneIndex][1] + (poiData[2] == true and 1 or 0)
    --     SUMMARY_TABLE[zoneIndex][2] = SUMMARY_TABLE[zoneIndex][2] + 1
    -- end

    -- for poiId, poiData in pairs(ImperialCartographer.DefaultPOIsData) do
    --     if not ImperialCartographer.DefaultPOIsData[poiId] then
    --         local zoneIndex, poiIndex = GetPOIIndices(poiId)
    --         -- if not SUMMARY_TABLE[zoneIndex] then SUMMARY_TABLE[zoneIndex] = {0, 0} end
    --         SUMMARY_TABLE[zoneIndex][1] = SUMMARY_TABLE[zoneIndex][1] + (poiData[2] == true and 1 or 0)
    --         SUMMARY_TABLE[zoneIndex][2] = SUMMARY_TABLE[zoneIndex][2] + 1
    --     end
    -- end

    -- local totalDiscovered = 0
    -- local grandTotal = 0
    -- for zoneIndex, zoneStats in pairs(SUMMARY_TABLE) do
    --     totalDiscovered = totalDiscovered + zoneStats[1]
    --     grandTotal = grandTotal + zoneStats[2]
    -- end

    IMP_CART_DiscoveredPOIsHeaderTotalDiscoveredLabel:SetText(('(total: %d/%d)'):format(grandTotalDiscovered, grandTotal))
end

-- ----------------------------------------------------------------------------

function IMP_CART_UpdateScrollListControl()
    -- TODO: For version 6 (probably)
    -- if DISCOVERED_POIS_CONTROL:IsHidden() then
    --     self.dirty = true
    -- end

    local scrollList = SCROLL_LIST_CONTROL
    local dataList = ZO_ScrollList_GetDataList(scrollList)

    updateSummary()

    local function CreateAndAddDataEntry(zoneIndex, poiDiscovered, poiTotal)
        local value = {zoneIndex = zoneIndex, zoneName = GetZoneNameByIndex(zoneIndex), poiDiscovered = poiDiscovered, poiTotal = poiTotal}
        local entry = ZO_ScrollList_CreateDataEntry(1, value)

		table.insert(dataList, entry)
    end

    ZO_ScrollList_Clear(scrollList)

    for zoneIndex, poiData in pairs(SUMMARY_TABLE) do
        local totalDiscovered, total = poiData[1], poiData[2]
        if total > 0 then
            CreateAndAddDataEntry(zoneIndex, totalDiscovered, total)
        end
    end

    table.sort(dataList, function(a, b) return a.data.zoneName < b.data.zoneName end)

    ZO_ScrollList_Commit(scrollList)
end

function IMP_CART_DiscoveredPOIs_OnInitialised(control)
    CreateScrollListDataType(control:GetNamedChild('ScrollableList'))
    -- DISCOVERED_POIS_CONTROL = control

    local trackButton = control:GetNamedChild('Header'):GetNamedChild('TrackButton')
    trackButton:SetHandler('OnMouseDown', function()
        ImperialCartographer.sv.pinned = not ImperialCartographer.sv.pinned
        if ImperialCartographer.sv.pinned then
            trackButton:SetNormalTexture('EsoUI/Art/Buttons/radioButton_pin_up_disabled.dds')
        else
            trackButton:SetNormalTexture('EsoUI/Art/Buttons/radioButton_pin_up.dds')
        end
    end)

    IMP_CART_UpdateScrollListControl()
end
