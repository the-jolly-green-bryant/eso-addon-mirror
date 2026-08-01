local AD_BLOCK_PLUS_HISTORY_DATA = 1

--Initialize a new FilteredList with a control that has $(parent)Headers and $(parent)List children
function AD_BLOCK_PLUS_LIST:InitializeList(control)
	self:InitializeSortFilterList(control)

	ZO_ScrollList_AddDataType(self.list, AD_BLOCK_PLUS_HISTORY_DATA, "AdBlockPlusHistoryRow", 28, function(control, data) self:SetupHistoryRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")

	self:SetAlternateRowBackgrounds(true)
	self:SetEmptyText("No History")
	self.emptyRow:ClearAnchors()
	self.emptyRow:SetAnchor(TOPLEFT, GetControl(control, "List"), TOPLEFT, 0,0)
	self.emptyRow:SetWidth(280)

	local sortKeys = {
		["number"] = { caseInsensitive = true },
	}
	self.currentSortKey = "number"
	self.currentSortOrder = ZO_SORT_ORDER_DOWN
	self.sortFunction = function(listEntry1, listEntry2)
		return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder))
	end

	--self.editbox = GetControl(control, "ScriptBox")
	--self.evaluate = GetControl(control, "EvaluateButton")
	--self.evaluate:SetHandler("OnClicked", function() if self.editbox:GetText() ~= "" then runScript(self.editbox:GetText()) end end)

	return self
end

function AD_BLOCK_PLUS_LIST:OnInitialized(control)
	self:InitializeList(control)					
	self:RefreshData()
end

function AD_BLOCK_PLUS_LIST:NewEntry(command, index)

	local data = setmetatable({number = index, command = command, sortIndex = -1}, noNewIndexes)
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.insert(scrollData, ZO_ScrollList_CreateDataEntry(AD_BLOCK_PLUS_HISTORY_DATA, data))

	self:RefreshFilters()

	return data
end

function AD_BLOCK_PLUS_LIST:UpdateHistory()

	local scrollData = ZO_ScrollList_GetDataList(self.list)
	local data, newdata

	for k, v in ipairs(scrollData) do
		data = setmetatable({number = k-1, command = AD_BLOCK_PLUS.history[k-1], sortIndex = -1}, noNewIndexes)
		newdata = ZO_ScrollList_CreateDataEntry(AD_BLOCK_PLUS_HISTORY_DATA, data)
		scrollData[k] = newdata
	end

	self:RefreshFilters()

	return data
end

function AD_BLOCK_PLUS_LIST:UpdateTotalBlocked(data)
	GetControl(AdBlockPlusHistory, "TotalBlocked"):SetText(data.." "..AD_BLOCK_PLUS.numberFormat(GetString(SI_AD_BLOCK_PLUS_BLOCKED_TOTAL)))
end

--Callback called by "ZO_ScrollList_CreateDataEntry" to setup a row
function AD_BLOCK_PLUS_LIST:SetupHistoryRow( control, data )
	control.data = data
	data.control = control

	GetControl(control,"Number"):SetText(""..tostring(data.number)..".")
	GetControl(control, "Command"):SetText(data.command)

	--GetControl(control, "BG"):SetHidden(false)

	self:SetupRow(control, data)
end

function AD_BLOCK_PLUS_LIST:EnterRow(row)
	if not selflockedForUpdates then
		ZO_ScrollList_MouseEnter(self.list, row)

		local data = ZO_ScrollList_GetData(row)
		if data then
			InitializeTooltip(InformationTooltip, row, TOPLEFT, 0, 0, TOPRIGHT)
			SetTooltipText(InformationTooltip, data.command)
		end

		self.mouseOverRow = row
	end
end

function AD_BLOCK_PLUS_LIST:ExitRow(row)
   if not self.lockedForUpdates then
      ZO_ScrollList_MouseExit(self.list, row)
      
      self.mouseOverRow = nil
      ZO_Options_OnMouseExit(row) 
   end   
end

function AD_BLOCK_PLUS_LIST:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end

function AD_BLOCK_PLUS_LIST:Refresh() self:RefreshData() end