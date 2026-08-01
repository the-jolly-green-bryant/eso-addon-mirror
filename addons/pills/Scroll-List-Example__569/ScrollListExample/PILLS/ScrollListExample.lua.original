--[[ 
Title: ScrollListExample
Description: Example of ScrollList implementation
Author: pills
Date: 2014-06-06

@NOTES
>>> Taken From MailR which took it from Librarian
  ]]

UnitList = ZO_SortFilterList:Subclass()
UnitList.defaults = {}
SLE = {}
SLE.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1) -- scroll list row text color
SLE.UnitList = nil
SLE.units = {}

UnitList.SORT_KEYS = {
		["name"] = {},
		["race"] = {tiebreaker="name"},
		["class"] = {tiebreaker="name"},
		["zone"] = {tiebreaker="name"}
}

function UnitList:New()
	local units = ZO_SortFilterList.New(self, ScrollListExampleMainWindow)
	units:Initialize()
	return units
end

function UnitList:Initialize()
 	self.masterList = {}
 	ZO_ScrollList_AddDataType(self.list, 1, "ScrollListExampleUnitRow", 30, function(control, data) self:SetupUnitRow(control, data) end)
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, UnitList.SORT_KEYS, self.currentSortOrder) end
	self:RefreshData()
end

function UnitList:BuildMasterList()
	self.masterList = {}
	local units = SLE.units
	for k, v in pairs(units) do
		local data = v
		data["name"] = k
		table.insert(self.masterList, data)
	end
end

function UnitList:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    for i = 1, #self.masterList do
        local data = self.masterList[i]
    	table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end    
end

function UnitList:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end

function UnitList:SetupUnitRow(control, data)
	control.data = data
	control.name = GetControl(control, "Name")
	control.race = GetControl(control, "Race")
	control.class = GetControl(control, "Class")
	control.zone = GetControl(control, "Zone")

	control.name:SetText(data.name)
	control.race:SetText(data.race)
	control.class:SetText(data.class)
	control.zone:SetText(data.zone)

	control.name.normalColor = SLE.DEFAULT_TEXT
	control.race.normalColor = SLE.DEFAULT_TEXT
	control.class.normalColor = SLE.DEFAULT_TEXT
	control.zone.normalColor = SLE.DEFAULT_TEXT

	ZO_SortFilterList.SetupRow(self, control, data)
end

function UnitList:Refresh()
	self:RefreshData()
end

function SLE.MouseEnter(control)
	SLE.UnitList:Row_OnMouseEnter(control)
end

function SLE.MouseExit(control)
	SLE.UnitList:Row_OnMouseExit(control)
end

function SLE.MouseUp(control, button, upInside)
	local name = control.data.name
	local gender = control.data.gender
	local class = control.data.class
	local level = control.data.level
	d(name, gender, class, level)
end

function SLE.TrackUnit()
	local targetName = GetUnitName("reticleover") 
	if targetName == "" then return end
	local targetRace = GetUnitRace("reticleover")
	local targetClass = GetUnitClass("reticleover")
	local targetZone = GetUnitZone("reticleover")
	SLE.units[targetName] = {race=tagetRace, class=targetClass, zone=targetZone}
	SLE.UnitList:Refresh()
end

-- do all this when the addon is loaded
function SLE.Init(eventCode, addOnName)
	if addOnName ~= "ScrollListExample" then return end

	-- Event Registration
	EVENT_MANAGER:RegisterForEvent("SLE_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED, SLE.TrackUnit)

	SLE.UnitList = UnitList:New()
	local playerName = GetUnitName("player") 
	local playerRace = GetUnitRace("player")
	local playerClass = GetUnitClass("player")
	local playerZone = GetUnitZone("player")
	SLE.units[playerName] = {race=playerRace, class=playerClass, zone=playerZone}
	SLE.UnitList:Refresh()

	ScrollListExampleMainWindow:SetHidden(false)
end

EVENT_MANAGER:RegisterForEvent("SLE_Init", EVENT_ADD_ON_LOADED , SLE.Init)