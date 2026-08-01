--[[ 
Title: ScrollListExample
Description: Example of ScrollList implementation
Author: pills, updated by ShadowMau (2021-04-01)
Date: 2014-06-06

@NOTES
>>> Taken From MailR which took it from Librarian

@ShadowMau
Much has changed in the 7 years since this was originally written so I decided to entirely rewrite this example.
I tried to stay true to what I surmise was the original intent of the author, which was to provide a simple
example that demonstrates the major elements of scroll lists.  From the example, a person should learn enough
to be able to apply the concepts to more complex applications.

I also added in a lot of documentation and a few examples on a couple ways to accomplish the same results.
I am in no way and expert in Lua, XML, or scroll lists so someone more experienced may look at this and wonder
why I did something a certain way when there may be a better way to do it.  Thank you for your understanding.

>>> Entirely rewritten to update for current API and added documentation and some current recommended practices.

  ]]


local name = "ScrollListExample"
-- Create a table to contain all of our stuff so we don't pollute the global table.
-- Needs to be unique, so I tend to use the addon's name as the name of the table.
ScrollListExample = {}
local SLE = ScrollListExample -- Give ourself a shortcut (optional)

UnitList = ZO_SortFilterList:Subclass()
UnitList.defaults = {}
SLE = {}
-- SLE.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1) -- scroll list row text color
-- SLE.UnitList = nil
-- SLE.units = {}

UnitList.SORT_KEYS = {
		["name"] = {},
		["race"] = {tiebreaker="name"},
		["class"] = {tiebreaker="name"},
		["zone"] = {tiebreaker="name"}
}
d("At UnitList Sort Keys")
d(UnitList)

-- function UnitList:New()
-- --AAA
	-- d("Checkpoint 2")
	-- d("Self:")
	-- d(self)
	
	-- -- AAA Added ScrollListExampleMainWindowList from ScrollListExampleMainWindow 
	-- local units = ZO_SortFilterList.New("ScrollListExampleMainWindow") -- AAA Jumps to UnitList:Initialize
	-- -- AAA
	-- d("Checkpoint 3")
	-- d("Self: ")
	-- d(self)
	-- units:Initialize()
	-- return units
-- end

-- function UnitList:Initialize()
-- -- AAA
	-- d("Checkpoint 2.1")
	-- d("Self:")
	-- d(self)
	-- d(self.list)
	-- d("UnitList")
	-- d(UnitList)
	-- d("UnitList.defaults")
	-- d(UnitList.defaults)
 	-- self.masterList = {}
	-- -- AAA Replaced self.list with UnitList
 	-- ZO_ScrollList_AddDataType(UnitList, 1, "ScrollListExampleUnitRow", 30, function(control, data) self:SetupUnitRow(control, data) end)
 	-- d("Checkpoint 2.2")
	
	-- ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
 	-- self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, UnitList.SORT_KEYS, self.currentSortOrder) end
	-- self:RefreshData()
-- end

-- function UnitList:BuildMasterList()
	-- self.masterList = {}
	-- local units = SLE.units
	-- for k, v in pairs(units) do
		-- local data = v
		-- data["name"] = k
		-- table.insert(self.masterList, data)
	-- end
-- end

-- function UnitList:FilterScrollList()
    -- local scrollData = ZO_ScrollList_GetDataList(self.list)
    -- ZO_ClearNumericallyIndexedTable(scrollData)

    -- for i = 1, #self.masterList do
        -- local data = self.masterList[i]
    	-- table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    -- end    
-- end

-- function UnitList:SortScrollList()
    -- local scrollData = ZO_ScrollList_GetDataList(self.list)
    -- table.sort(scrollData, self.sortFunction)
-- end

-- function UnitList:SetupUnitRow(control, data)
	-- control.data = data
	-- control.name = GetControl(control, "Name")
	-- control.race = GetControl(control, "Race")
	-- control.class = GetControl(control, "Class")
	-- control.zone = GetControl(control, "Zone")

	-- control.name:SetText(data.name)
	-- control.race:SetText(data.race)
	-- control.class:SetText(data.class)
	-- control.zone:SetText(data.zone)

	-- control.name.normalColor = SLE.DEFAULT_TEXT
	-- control.race.normalColor = SLE.DEFAULT_TEXT
	-- control.class.normalColor = SLE.DEFAULT_TEXT
	-- control.zone.normalColor = SLE.DEFAULT_TEXT

	-- ZO_SortFilterList.SetupRow(self, control, data)
-- end

-- function UnitList:Refresh()
	-- self:RefreshData()
-- end

-- function SLE.MouseEnter(control)
	-- SLE.UnitList:Row_OnMouseEnter(control)
-- end

-- function SLE.MouseExit(control)
	-- SLE.UnitList:Row_OnMouseExit(control)
-- end

-- function SLE.MouseUp(control, button, upInside)
	-- local name = control.data.name
	-- local gender = control.data.gender
	-- local class = control.data.class
	-- local level = control.data.level
	-- d(name, gender, class, level)
-- end

-- function SLE.TrackUnit()
	-- local targetName = GetUnitName("reticleover") 
	-- if targetName == "" then return end
	-- local targetRace = GetUnitRace("reticleover")
	-- local targetClass = GetUnitClass("reticleover")
	-- local targetZone = GetUnitZone("reticleover")
	-- SLE.units[targetName] = {race=tagetRace, class=targetClass, zone=targetZone}
	-- SLE.UnitList:Refresh()
-- end

-- do all this when the addon is loaded
function SLE.Init(eventCode, addOnName)
	if addOnName ~= "ScrollListExample" then return end

	-- Event Registration
	-- AAA Turned off for now
--	EVENT_MANAGER:RegisterForEvent("SLE_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED, SLE.TrackUnit)

--	AAA
	d("Checkpoint 1")
	d("Self:")
	d(self)
	d("UnitList")
	d(UnitList)
	d("UnitList defaults")
	d(UnitList.defaults)
	d("SLE.UnitList")
	d(SLE.UnitList)
	-- SLE.UnitList = UnitList:New()
	-- AAA
	d("Checkpoint End")
	d("Self:")
	d(self)
	local playerName = GetUnitName("player") 
	local playerRace = GetUnitRace("player")
	local playerClass = GetUnitClass("player")
	local playerZone = GetUnitZone("player")
	-- SLE.units[playerName] = {race=playerRace, class=playerClass, zone=playerZone}
	-- SLE.UnitList:Refresh()

	ScrollListExampleMainWindow:SetHidden(false)
end

EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED , SLE.Init)