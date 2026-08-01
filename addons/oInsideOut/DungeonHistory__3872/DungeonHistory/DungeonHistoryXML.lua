DungeonHistory.XML = {}


function DungeonHistory.XML.ToggleDungeonHistoryWindow()
    DungeonHistoryListMainWindow:SetHidden(not DungeonHistoryListMainWindow:IsHidden())
end

function DungeonHistory.XML.ToggleDateFormat()
	local dateMDY = not DungeonHistory.saveData.options.dateMDY

	DungeonHistory.saveData.options.dateMDY = dateMDY
	DungeonHistory.XML.FillListSavedVariables()
	DungeonHistory.XML.SL.DungeonList:Refresh()
	if dateMDY then
		d("[DungeonHistory] Changed Date Format to m/d/Y")
	else
		d("[DungeonHistory] Changed Date Format to d/m/Y")
	end
end

SLASH_COMMANDS[DungeonHistory.slashShort] = DungeonHistory.XML.ToggleDungeonHistoryWindow
SLASH_COMMANDS[DungeonHistory.slashLong] = DungeonHistory.XML.ToggleDungeonHistoryWindow
SLASH_COMMANDS[DungeonHistory.slashDateFormat] = DungeonHistory.XML.ToggleDateFormat
SLASH_COMMANDS[DungeonHistory.slashEraseAllData] = DungeonHistory.eraseAllData

DungeonHistory.XML.DungeonList = ZO_SortFilterList:Subclass()
DungeonHistory.XML.DungeonList.defaults = {}
DungeonHistory.XML.SL = {}
DungeonHistory.XML.SL.DEFAULT_TEXT = ZO_ColorDef:New(0.4627, 0.737, 0.7647, 1)
DungeonHistory.XML.SL.DungeonList = nil
DungeonHistory.XML.SL.dungeons = {}

DungeonHistory.XML.DungeonList.SORT_KEYS = {
		["started"] = {},
		["startedDate"] = {tiebreaker="started"},
		["dungeon"] = {tiebreaker="started"},
		["character"] = {tiebreaker="started"},
		["duration"] = {tiebreaker="started"},
		["difficulty"] = {tiebreaker="started"}
}

function DungeonHistory.XML.DungeonList:New()
	local dungeons = ZO_SortFilterList.New(self, DungeonHistoryListMainWindow)
	return dungeons
end

function DungeonHistory.XML.DungeonList:Initialize(control)
	ZO_SortFilterList.Initialize(self, control)

	self.sortHeaderGroup:SelectHeaderByKey("started")
	ZO_SortHeader_OnMouseExit(DungeonHistoryListMainWindowHeadersDungeon)

	self.masterList = {}
	ZO_ScrollList_AddDataType(self.list, 1, "DungeonHistoryListEntityRow", 30, function(control, data) self:SetupDungeonRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, DungeonHistory.XML.DungeonList.SORT_KEYS, self.currentSortOrder) end
	self:RefreshData()
end

function DungeonHistory.XML.DungeonList:BuildMasterList()
	self.masterList = {}
	local dungeons = DungeonHistory.XML.SL.dungeons
	for k, v in pairs(dungeons) do
		local data = v
		data["Dungeon"] = k
		table.insert(self.masterList, data)
	end
end

function DungeonHistory.XML.DungeonList:FilterScrollList()
	local counter = 0
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	DungeonHistory.XML.PrintDungeonStatsToGui(DungeonHistory.XML.comboBoxSelectedItem)
	DungeonHistory.XML.LoadNotepad(DungeonHistory.XML.comboBoxSelectedItem)

	for i = 1, #self.masterList do
		local data = self.masterList[i]
		if DungeonHistory.XML.comboBoxSelectedItem == "All Dungeons" then
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
			counter = counter + 1
		elseif DungeonHistory.XML.comboBoxSelectedItem == data.dungeon then
			table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
			counter = counter + 1
		end
	end
	DungeonHistory.XML.TotalLabelNumber = WINDOW_MANAGER:GetControlByName("DungeonHistoryListMainWindowTotalLabelNumber")
	DungeonHistory.XML.TotalLabelNumber:SetText(counter)
end

function DungeonHistory.XML.DungeonList:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end

function DungeonHistory.XML.DungeonList:SetupDungeonRow(control, data)
	control.data = data
	control.dungeon = GetControl(control, "Dungeon")
	control.character = GetControl(control, "Character")
	control.duration = GetControl(control, "Duration")
	control.difficulty = GetControl(control, "Difficulty")
    control.started = GetControl(control, "Started")
	control.startedDate = GetControl(control, "StartedDate")

	control.dungeon:SetText(data.dungeon)
	control.character:SetText(data.character)
	control.duration:SetText(data.duration)
	control.difficulty:SetText(data.difficulty)
    control.started:SetText(data.started)
	control.startedDate:SetText(data.startedDate)

	control.dungeon.normalColor = DungeonHistory.XML.SL.DEFAULT_TEXT
	control.character.normalColor = DungeonHistory.XML.SL.DEFAULT_TEXT
	control.duration.normalColor = DungeonHistory.XML.SL.DEFAULT_TEXT
	control.difficulty.normalColor = DungeonHistory.XML.SL.DEFAULT_TEXT
    control.started.normalColor = DungeonHistory.XML.SL.DEFAULT_TEXT
	control.startedDate.normalColor = DungeonHistory.XML.SL.DEFAULT_TEXT

	ZO_SortFilterList.SetupRow(self, control, data)
end

function DungeonHistory.XML.DungeonList:Refresh()
	self:RefreshData()
end

function DungeonHistory.XML.SL.MouseEnter(control)
	DungeonHistory.XML.SL.DungeonList:Row_OnMouseEnter(control)
	--ZO_Tooltips_ShowTextTooltip(control, nil, zo_iconTextFormat('EsoUI/art/tutorial/gamepad/gp_lfg_dps.dds', 24, 24, "Groupmember\n1.\n2.\n3."))
end

function DungeonHistory.XML.SL.MouseExit(control)
	DungeonHistory.XML.SL.DungeonList:Row_OnMouseExit(control)
	--ZO_Tooltips_HideTextTooltip()
end

function DungeonHistory.XML.SL.MouseUp(control, button, upInside)
	local cd = control.data
	--d(table.concat( { cd.dungeon, cd.character, cd.duration, cd.difficulty, cd.started }, " "))
end

function DungeonHistory.XML.FillListSavedVariables()
	local dungeonHistoryEntities =  DungeonHistory.GetSavedDungeonEntityNames()
	local counter = 1

	for key, value in pairs(dungeonHistoryEntities) do
		local val = value
		local subTable = DungeonHistory.saveData.dungeonCompleted[val]

		if DungeonHistory.saveData.options.dateMDY == false then
			DungeonHistory.XML.SL.dungeons[counter] = {dungeon=subTable["Dungeon"], character=subTable["Character"], duration=subTable["Duration"], difficulty=DungeonHistory.dungeonDifficultyToString(subTable["Difficulty"]), started=subTable["Started"], startedDate=os.date('%d/%m/%Y %H:%M' ,subTable["Started"])}
		else
			DungeonHistory.XML.SL.dungeons[counter] = {dungeon=subTable["Dungeon"], character=subTable["Character"], duration=subTable["Duration"], difficulty=DungeonHistory.dungeonDifficultyToString(subTable["Difficulty"]), started=subTable["Started"], startedDate=os.date('%m/%d/%Y %H:%M' ,subTable["Started"])}
		end
		counter = counter + 1
	end
end

function DungeonHistory.XML.InitializeComboBox()
	DungeonHistory.XML.comboBox = WINDOW_MANAGER:GetControlByName("DungeonHistoryListMainWindowComboBox")

	if not DungeonHistory.XML.comboBox then
		return
	end

	local allDungeonsList = DungeonHistory.allDungeons
	DungeonHistory.XML.comboBoxObject = ZO_ComboBox_ObjectFromContainer(DungeonHistory.XML.comboBox)
	DungeonHistory.XML.comboBoxObject.m_height = 390
	DungeonHistory.XML.comboBoxObject:ClearItems()

	for _, item in ipairs(allDungeonsList) do
        local entry = DungeonHistory.XML.comboBoxObject:CreateItemEntry(item, function()
			DungeonHistory.XML.comboBoxSelectedItem = item
			DungeonHistory.XML.SL.DungeonList:Refresh()

            -- Additional actions on selection
        end)
        DungeonHistory.XML.comboBoxObject:AddItem(entry)
    end

	DungeonHistory.XML.comboBoxObject:SetSelectedItem(allDungeonsList[1])
	DungeonHistory.XML.comboBoxSelectedItem = allDungeonsList[1]
end

function DungeonHistory.XML.PrintDungeonStatsToGui(dungeon)
	DungeonHistory.XML.counterNumber = WINDOW_MANAGER:GetControlByName("DungeonHistoryListMainWindowDungeonCounterNumber")
	DungeonHistory.XML.counterLastResetTime = WINDOW_MANAGER:GetControlByName("DungeonHistoryListMainWindowDungeonCounterResetTimeDate")

	DungeonHistory.XML.counterNumber:SetText(DungeonHistory.saveData.dungeonStats[dungeon].dungeonCounter)
	if DungeonHistory.saveData.options.dateMDY == false then
		DungeonHistory.XML.counterLastResetTime:SetText(os.date('%d/%m/%Y %H:%M', DungeonHistory.saveData.dungeonStats[dungeon].lastCounterReset))
	else
		DungeonHistory.XML.counterLastResetTime:SetText(os.date('%m/%d/%Y %H:%M', DungeonHistory.saveData.dungeonStats[dungeon].lastCounterReset))
	end
end

function DungeonHistory.XML.ResetDungeonCouter()
	local dungeon = DungeonHistory.XML.comboBoxSelectedItem

	DungeonHistory.saveData.dungeonStats[dungeon].dungeonCounter = 0
	DungeonHistory.saveData.dungeonStats[dungeon].lastCounterReset = os.time()

	DungeonHistory.XML.SL.DungeonList:Refresh()
end

function DungeonHistory.XML.InitializeEditBox()
	DungeonHistory.XML.EditBox = GetControl("DungeonHistoryListMainWindowEditBox")

	DungeonHistory.XML.EditBox:SetMaxInputChars(1500)
	DungeonHistory.XML.EditBox:SetHandler("OnFocusLost", DungeonHistory.XML.SaveNotepad)
end

function DungeonHistory.XML.ToggleEditBox()
	DungeonHistoryListMainWindowEditBoxHeading:SetHidden(not DungeonHistoryListMainWindowEditBoxHeading:IsHidden())
	DungeonHistoryListMainWindowEditBoxHeadingDivider:SetHidden(not DungeonHistoryListMainWindowEditBoxHeadingDivider:IsHidden())
	DungeonHistoryListMainWindowEditBoxBG:SetHidden(not DungeonHistoryListMainWindowEditBoxBG:IsHidden())
	DungeonHistoryListMainWindowEditBox:SetHidden(not DungeonHistoryListMainWindowEditBox:IsHidden())

	if DungeonHistoryListMainWindowEditBoxBG:IsHidden() then
		DungeonHistoryListMainWindowButtonToggleEditBox:SetNormalTexture("EsoUI/Art/Buttons/large_rightarrow_up.dds")
		DungeonHistoryListMainWindowButtonToggleEditBox:SetPressedTexture("EsoUI/Art/Buttons/large_rightarrow_down.dds")
		DungeonHistoryListMainWindowButtonToggleEditBox:SetMouseOverTexture("EsoUI/Art/Buttons/large_rightarrow_over.dds")
		DungeonHistoryListMainWindowButtonToggleEditBox:SetDisabledTexture("EsoUI/Art/Buttons/large_rightarrow_disabled.dds")
	else
		DungeonHistoryListMainWindowButtonToggleEditBox:SetNormalTexture("EsoUI/Art/Buttons/large_leftarrow_up.dds")
		DungeonHistoryListMainWindowButtonToggleEditBox:SetPressedTexture("EsoUI/Art/Buttons/large_leftarrow_down.dds")
		DungeonHistoryListMainWindowButtonToggleEditBox:SetMouseOverTexture("EsoUI/Art/Buttons/large_leftarrow_over.dds")
		DungeonHistoryListMainWindowButtonToggleEditBox:SetDisabledTexture("EsoUI/Art/Buttons/large_leftarrow_disabled.dds")
	end
end

DungeonHistory.XML.targetChars = {[["]], [[']], [[\]]}
DungeonHistory.XML.replaceChars = {[[%%34]], [[%%39]], [[%%92]]}

function DungeonHistory.XML.SaveNotepad()
	local text = DungeonHistory.XML.EditBox:GetText()

	for i = 1, #DungeonHistory.XML.targetChars do
		text = string.gsub(text, DungeonHistory.XML.targetChars[i], DungeonHistory.XML.replaceChars[i])
	end

	DungeonHistory.saveData.dungeonStats[DungeonHistory.XML.comboBoxSelectedItem].dungeonNotes = text
end

function DungeonHistory.XML.LoadNotepad(dungeon)
	local text = DungeonHistory.saveData.dungeonStats[dungeon].dungeonNotes

	for i = 1, #DungeonHistory.XML.targetChars do
		text = string.gsub(text, DungeonHistory.XML.replaceChars[i], DungeonHistory.XML.targetChars[i])
	end

	DungeonHistory.XML.EditBox:SetText(text)
end
--[[
function DungeonHistory.XML.DungeonMembersToString(control)
	local dungeonMembers = "-"

	if control.members == not nil then
		
		--zo_iconTextFormat('EsoUI/art/tutorial/gamepad/gp_lfg_dps.dds', 24, 24, "Groupmember\n1.\n2.\n3.")
	else return dungeonMembers
	end
	
end
]]--

--[[
art\icons\class\class_dragonknight.dds
art\icons\class\class_nightblade.dds
art\icons\class\class_sorcerer.dds
art\icons\class\class_templar.dds
art\icons\class\class_warden.dds

art\tutorial\gamepad\gp_lfg_tank.dds
art\tutorial\gamepad\gp_lfg_dps.dds
art\tutorial\gamepad\gp_lfg_healer.dds
]]