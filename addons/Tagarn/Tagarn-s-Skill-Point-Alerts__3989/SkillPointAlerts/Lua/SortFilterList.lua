-- Copyright (c) 2025 by Tagarn

-- This add-on may be copied, shared, and used as-is while playing Elder
-- Scrolls Online, provided this notice is left intact. However, this
-- add-on, in part or in full, may not be used in the creation of other
-- add-ons without the express written consent of Tagarn.

-- The Elder Scrolls Online add-on provided by Tagarn ("we," "us," or "our")
-- is for entertainment purposes only. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY
-- LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF
-- THE USE OF OUR ADD-ON. YOUR USE OF OUR ADD-ON IS SOLELY AT YOUR OWN RISK.

SkillPointAlerts = SkillPointAlerts or {}

local SPA = SkillPointAlerts
local WM = WINDOW_MANAGER


local SortFilterList = ZO_SortFilterList:Subclass()
local SFL = SortFilterList
SFL.defaults = {}
SFL.fourColumn = false -- whether this is a three column or a four column list
SFL.rowSize = 20 -- the size of the rows in the list
SFL.data = {}
SFL.listControl = nil

SFL.SORT_KEYS = {
	["name"] = {},
	["zone"] = {tiebreaker="name"},
}

SFL.listNormalColor = {0.4627, 0.737, 0.7647}
SFL.lineHighlightBackground = {1, 1, 1, 0.1}

function SFL:New(control, fourColumn)
	if (fourColumn == nil) then
		fourColumn = false
	end
	
	self.fourColumn = fourColumn

	local sortlist = ZO_SortFilterList.New(self, control)
	sortlist.listControl = control
	return sortlist
end

function SFL:Initialize(control)
	ZO_SortFilterList.Initialize(self, control)

	self.sortHeaderGroup:SelectHeaderByKey("name")

	self.masterList = {}
	if (self.fourColumn == false) then
		ZO_ScrollList_AddDataType(self.list, 1, "SPA_RowDelve", SFL.rowSize, function(control, data) self:SetupUnitRow(control, data) end)
	else
		ZO_ScrollList_AddDataType(self.list, 1, "SPA_RowDungeon", SFL.rowSize, function(control, data) self:SetupUnitRow(control, data) end)
	end
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)
	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, SFL.SORT_KEYS, self.currentSortOrder) end
	self:RefreshData()
end

function SFL:BuildMasterList()
	self.masterList = {}
	local data = self.data
	for k, v in pairs(data) do
		local data = v
		data["name"] = k
		table.insert(self.masterList, data)
	end
end

function SFL:FilterScrollList()
	ZO_ScrollList_Clear(self.list)
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)


	for i = 1, #self.masterList do
		local data = self.masterList[i]
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end

function SFL:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)

	table.sort(scrollData, self.sortFunction)
end

local once = false


function SFL:SetupUnitRow(control, data)
	control.data = data
	control.name = GetControl(control, "Name")
	control.zone = GetControl(control, "Zone")

	control.name:SetText(data.name)
	control.zone:SetText(data.zone)

	control.name:SetColor(SFL.listNormalColor[1], SFL.listNormalColor[2], SFL.listNormalColor[3])
	control.zone:SetColor(SFL.listNormalColor[1], SFL.listNormalColor[2], SFL.listNormalColor[3])

	local locked = control:GetNamedChild("Lock")

	if (data.locked == true) then
		locked:SetText(SPA.C.LOCK)
	else
		locked:SetText(" ")
	end

	if (self.fourColumn == true) then
		local quest = control:GetNamedChild("Quest")
		if (quest == nil) then --FIXME: Why is this happening?
			return
		end
		local groupEvent = control:GetNamedChild("GroupEvent")
		if (groupEvent == nil) then
			return
		end
		local skyshard = control:GetNamedChild("Skyshard")
		if (skyshard == nil) then
			return
		end
		if (data.skyshard == true) then
			skyshard:SetHidden(false)
		else
			skyshard:SetHidden(true)
		end

		if (data.groupEvent == true) then
			groupEvent:SetHidden(false)
		else
			groupEvent:SetHidden(true)
		end

		if (data.quest == true) then
			quest:SetHidden(false)
		else
			quest:SetHidden(true)
		end

	end

	ZO_SortFilterList.SetupRow(self, control, data)
end

function SFL:Refresh()
	self:RefreshData()
end

function SFL:MouseEnter(control)
	self:Row_OnMouseEnter(control)
end

function SFL:MouseExit(control)
	self:Row_OnMouseExit(control)
end

function SFL:MouseUp(control, button, upInside)
	local cd = control.data
end

SkillPointAlerts.SortFilterList = SortFilterList
