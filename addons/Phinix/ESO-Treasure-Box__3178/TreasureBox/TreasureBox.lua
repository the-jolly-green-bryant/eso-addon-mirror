-------------------------------------------------------------------------------
-- Treasure Box
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2021-2023 James A. Keene (Phinix) All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation (the "Software"),
-- to operate the Software for personal use only. Permission is NOT granted
-- to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
-- copies of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--]]

local TBoxAddon = _G['TBoxAddon']
local DB = TBoxAddon.DB
local L = DB.Strings
local version = '1.08'
local uVersion = 1.07 -- only change this when manually forcing a database update for maintenance

-- Library functions:
local pTC = TBoxAddon.TColor
local pEA = TBoxAddon.SubExtendedASCII
local dQC = DB.QualityColors

local Defaults = TBoxAddon.DB.DefaultVars() -- returns table of saved variable defaults
local scaleAnimation = ZO_ReversibleAnimationProvider:New("IconSlotMouseOverAnimation") -- used for animating recent items list


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Local variable reference
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- session variables
local editText = 0							-- status of the text input search box
local textInput = ""						-- current contents of the text input search box
local textBuffer = 0

-- variable tables
local searchTable = {}						-- main data table for treasure list items
local charName2ID = {}						-- table of character ID's indexed by name
local charID2Name = {}						-- table of character names indexed by ID
local charNamesGUI_T = {}					-- raw table of characters ordered by game's selection menu (game may not account for dragging)
local charNamesGUI = {}						-- sorted table of string names ([1 - i]) of character (used in GUI menu)
local recentState = {}						-- holds values of the mouseover state for recent quality buttons

-- control variables
local TreasureItemTooltipControl			-- used for popup treasure tooltips in the GUI
local categoryDropdown						-- category navigation dropdown control
local zoneDropdown							-- list of zones where treasure has been found
local charnameDropdown						-- character name list dropdown control

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Various utility functions
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function RestorePosition() -- Restores previous window position when opened
	local left = TBoxAddon.ASV.aOpts.xpos
	local top = TBoxAddon.ASV.aOpts.ypos
	TBoxAddon_MainFrame:ClearAnchors()
	TBoxAddon_MainFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function CloseMain(option) -- Closes the main window and returns cursor control
	if option == 1 then
		InitializeTooltip(InformationTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
		SetTooltipText(InformationTooltip, L.TBoxAddon_CLOSE)
	elseif option == 2 then
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		SCENE_MANAGER:HideTopLevel(TBoxAddon_MainFrame)
	end
end

local function OnMoveStop() -- Saves the current window position when closed
	TBoxAddon.ASV.aOpts.xpos = TBoxAddon_MainFrame:GetLeft()
	TBoxAddon.ASV.aOpts.ypos = TBoxAddon_MainFrame:GetTop()
end

local function LowerSpaceSpecial(text) -- Remove non-standard ASCII & spaces and change to lower case
-- NOTE: Game/LUA treats non-standard ASCII characters as punctuation so %p can't be used without breaking non-English localization.
-- Partially resolved using lookup table for situations that require removal of actual punctuation for string matching to work (game quirks).
	local cText = pEA(text)
	return zo_strlower(zo_strformat("<<t:1>>",cText)):gsub(":.*",''):gsub("%s",'') -- remove extra M/F tags
end

local function ScaleSelectedIcon(control, scaledUp, instant) -- Plays ZOS function to zoom icons on mouseover
	if control then
		if scaledUp then
			scaleAnimation:PlayForward(control, instant)
		else
			scaleAnimation:PlayBackward(control, instant)
		end                
	end
end

local function TableSelect() -- Sets the active treasure table based on only show found toggle state
	if (TBoxAddon.ASV.aOpts.showOnlyKnown) then
		local oTable = {}
		for k, _ in pairs(TBoxAddon.AT.TreasureTableF) do
			oTable[k] = TBoxAddon.AT.TreasureTable[k]
		end
		return oTable
	else
		return TBoxAddon.AT.TreasureTable
	end
end

local function CheckText() -- Maintain active text search results when applying filters
	local control = TBoxAddon_MainFrameListFrameSearchBox
	if textInput ~= "" and textInput ~= L.TBoxAddon_SEARCHBOX and control:GetText() ~= L.TBoxAddon_SEARCHBOX then
		return true
	else
		return false
	end
end

local function HideQualitySelect() -- Hides UI recent item quality filter buttons after a delay
	local stateCheck = 0
	for _, s in pairs(recentState) do stateCheck = stateCheck + s end
	if stateCheck == 0 then
		for i = 1, 5 do
			local tControl = TBoxAddon_MainFrameNavFrame:GetNamedChild('QualityCheckbox'..tostring(i))
			tControl:SetHidden(true)
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Main scroll list filter configuration functions
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function ResetQualityNav(set) -- Tracks the current quality list for nav icon setup
	for i = 1, 6 do
		if i ~= set then
			DB.QualityNav[i].active = false
			GetControl(DB.QualityNav[i].c1):SetAlpha(1)
			GetControl(DB.QualityNav[i].c2):SetAlpha(0)
		end
	end
	DB.QualityNav[set].active = true
	TBoxAddon_MainFrameNavFrameQualityText:SetText(DB.QualityNav[set].opt)
	TBoxAddon.ASV.aOpts.qualityNav = DB.QualityNav[set].opt
	GetControl(DB.QualityNav[set].c1):SetAlpha(0)
	GetControl(DB.QualityNav[set].c2):SetAlpha(1)
end

local function ResetTimeNav(set) -- Tracks the current time list for nav icon setup
	for i = 1, 6 do
		if i ~= set then
			DB.TimeNav[i].active = false
			GetControl(DB.TimeNav[i].c1):SetAlpha(1)
			GetControl(DB.TimeNav[i].c2):SetAlpha(0)
		end
	end
	DB.TimeNav[set].active = true
	TBoxAddon_MainFrameNavFrameTimeDays:SetText(DB.TimeNav[set].days)
	TBoxAddon.ASV.aOpts.timeNav = DB.TimeNav[set].days
	GetControl(DB.TimeNav[set].c1):SetAlpha(0)
	GetControl(DB.TimeNav[set].c2):SetAlpha(1)
end

local function ClearSearchList(datalist) -- Clears the current scroll list and search tables
	for k,v in pairs(datalist) do datalist[k] = nil end
	for k,v in pairs(searchTable) do searchTable[k] = nil end
	ZO_ScrollList_Clear(TBoxAddon_MainFrameListFrameList)
	ZO_ScrollList_Commit(TBoxAddon_MainFrameListFrameList, datalist)
end

local function NavigateScrollList(nTable) -- Populate treasure list based on filter options
	local datalist = ZO_ScrollList_GetDataList(TBoxAddon_MainFrameListFrameList)
	ClearSearchList(datalist)

	local tCrossCheck = {}
	local tSearchTable = {}
	local tDatalist = {}
	local oTable = {}
	local TL = {}
	local TLnames = {}
	local TN = {}
	local tIndexed = {}
	local row = 0

------------------------------------------------------------------------------------------------------------------
-- remove entries that do not match filter criteria from the final data table
------------------------------------------------------------------------------------------------------------------

	local filterTable = {}
	for k, _ in pairs(nTable) do filterTable[k] = TBoxAddon.AT.TreasureTable[k] end

	for k, v in pairs(filterTable) do -- Quality filter
		if TBoxAddon.ASV.aOpts.qualityNav ~= L.TBoxAddon_ANY then
			if TBoxAddon.ASV.aOpts.qualityNav == L.TBoxAddon_QUALITY1 then
				if v.quality ~= 1 then filterTable[k] = nil end
			elseif TBoxAddon.ASV.aOpts.qualityNav == L.TBoxAddon_QUALITY2 then
				if v.quality ~= 2 then filterTable[k] = nil end
			elseif TBoxAddon.ASV.aOpts.qualityNav == L.TBoxAddon_QUALITY3 then
				if v.quality ~= 3 then filterTable[k] = nil end
			elseif TBoxAddon.ASV.aOpts.qualityNav == L.TBoxAddon_QUALITY4 then
				if v.quality ~= 4 then filterTable[k] = nil end
			elseif TBoxAddon.ASV.aOpts.qualityNav == L.TBoxAddon_QUALITY5 then
				if v.quality ~= 5 then filterTable[k] = nil end
			end
		end
	end

	for k, v in pairs(filterTable) do -- Time filter
		if TBoxAddon.ASV.aOpts.timeNav ~= L.TBoxAddon_ANY then
			if TBoxAddon.ASV.TreasureDB[k].lastFound == 0 then
				filterTable[k] = nil
			else
				local lastFound = TBoxAddon.ASV.TreasureDB[k].lastFound
				local currentTime = GetTimeStamp()
				local timeDiff = (currentTime - lastFound) / 86400 -- convert 'epoch time' stamp to days passed
				if TBoxAddon.ASV.aOpts.timeNav == DB.TimeNav[1].days then -- 3 days
					if timeDiff > 3 then filterTable[k] = nil end
				elseif TBoxAddon.ASV.aOpts.timeNav == DB.TimeNav[2].days then -- 7 days
					if timeDiff > 7 then filterTable[k] = nil end
				elseif TBoxAddon.ASV.aOpts.timeNav == DB.TimeNav[3].days then -- 14 days
					if timeDiff > 14 then filterTable[k] = nil end
				elseif TBoxAddon.ASV.aOpts.timeNav == DB.TimeNav[4].days then -- 21 days
					if timeDiff > 21 then filterTable[k] = nil end
				elseif TBoxAddon.ASV.aOpts.timeNav == DB.TimeNav[5].days then -- 30 days
					if timeDiff > 30 then filterTable[k] = nil end
				end
			 end
		end
	end

	for k, v in pairs(filterTable) do -- Category filter
		if TBoxAddon.ASV.aOpts.categoryNav ~= L.TBoxAddon_ALLTYPES then
			if not TBoxAddon.ASV.TreasureDB[k].categories[TBoxAddon.ASV.aOpts.categoryNav] then filterTable[k] = nil end
		end
	end

	for k, v in pairs(filterTable) do -- Zone filter
		if TBoxAddon.ASV.aOpts.zoneNav ~= L.TBoxAddon_ALLZONES then
			if not TBoxAddon.ASV.TreasureDB[k].zones[TBoxAddon.ASV.aOpts.zoneNav] then filterTable[k] = nil end
		end
	end

	for k, v in pairs(filterTable) do -- Character
		if TBoxAddon.ASV.aOpts.characterNav ~= L.TBoxAddon_ANYFOUND then
			if not TBoxAddon.ASV.TreasureDB[k].IDs[charName2ID[TBoxAddon.ASV.aOpts.characterNav]] then filterTable[k] = nil end
		end
	end

------------------------------------------------------------------------------------------------------------------
-- build the final table of entries and display in the treasure box scroll list
------------------------------------------------------------------------------------------------------------------
	
	for k, v in pairs(filterTable) do
		local tName = v.name
		local sName =  LowerSpaceSpecial(tName)
		local color = dQC[v.quality]
		row = row + 1
		tCrossCheck[row] = {name = tName, row = row}
		tSearchTable[row] = { ID = k, text = pTC(color,tName), name = tName}
		tDatalist[row] = pTC(color,tName)
	end

	if TBoxAddon.ASV.aOpts.sortState == 1 then -- sort alphabetically
		for k, v in pairs(tCrossCheck) do
			local iName = v.name
			local iTag = tostring(tSearchTable[v.row].ID)
			table.insert(TL,iName..iTag)
			TLnames[iName..iTag] = v
		end
		table.sort(TL)
	elseif TBoxAddon.ASV.aOpts.sortState == 2 then -- sort by number found
		for k, v in pairs(tCrossCheck) do
			local iName = v.name
			local iID = tSearchTable[v.row].ID
			local iTag = string.format("%06d",tostring(iID))
			local iFound = (TBoxAddon.ASV.TreasureDB[iID] and TBoxAddon.ASV.TreasureDB[iID].total > 0) and TBoxAddon.ASV.TreasureDB[iID].total or 0
			local iTotal = string.format("%06d",tostring(iFound))
			if not tIndexed[iTotal] then tIndexed[iTotal] = {} end
			table.insert(tIndexed[iTotal],iName..iTag)
			TLnames[iName..iTag] = v -- also sort alphabetically within sub-tables of number found
		end

		for k, v in pairs(tIndexed) do table.insert(TN, k) end
		table.sort(TN, function(a, b) return a > b end)

		local function sortSub(tTable)
			table.sort(tTable)
			for k, v in ipairs(tTable) do
				table.insert(TL,v)
			end
		end
		for k, v in ipairs(TN) do
			sortSub(tIndexed[v])
		end
	end

	for k, v in ipairs(TL) do
		oTable[#oTable + 1] = TLnames[v]
	end

	for k, v in ipairs(oTable) do
		local sData = tSearchTable[v.row]
		local rData = tDatalist[v.row]
		searchTable[k] = sData
		datalist[k] = ZO_ScrollList_CreateDataEntry( 1, 
		{
			TreasureName = rData,
		}
		)
	end

	ZO_ScrollList_Commit(TBoxAddon_MainFrameListFrameList, datalist)

--	ZO_ScrollList_ScrollDataIntoView(TBoxAddon_MainFrameListFrameList, 1)
end

local function QualityNavigation(val, extra) -- Keeps the quality navigation triangle active for current list
	if extra == 1 then
		InitializeTooltip(InformationTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
		SetTooltipText(InformationTooltip, DB.QualityNav[val].quality)
	elseif extra == 2 then
		if DB.QualityNav[val].active == false then
			GetControl(DB.QualityNav[val].c1):SetAlpha(1)
			GetControl(DB.QualityNav[val].c2):SetAlpha(0)
		end
		ClearTooltip(InformationTooltip)
	end
end

local function TimeNavigation(val, extra) -- Keeps the time navigation icon active for current list
	if extra == 1 then
		InitializeTooltip(InformationTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
		SetTooltipText(InformationTooltip, DB.TimeNav[val].days)
	elseif extra == 2 then
		if DB.TimeNav[val].active == false then
			GetControl(DB.TimeNav[val].c1):SetAlpha(1)
			GetControl(DB.TimeNav[val].c2):SetAlpha(0)
		end
		ClearTooltip(InformationTooltip)
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Text search functions
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function TextSearch(refresh) -- Populate treasure list based on text search
	local datalist = ZO_ScrollList_GetDataList(TBoxAddon_MainFrameListFrameList)
	local tempText = TBoxAddon_MainFrameListFrameSearchBox:GetText()
	local searchtext

	if editText == 1 or refresh == 1 then
		ZO_ScrollList_Clear(TBoxAddon_MainFrameListFrameList)
		if refresh == 1 then searchtext = LowerSpaceSpecial(textInput) else searchtext = LowerSpaceSpecial(tempText) end
		if searchtext == "" then
			for k,v in pairs(datalist) do datalist[k] = nil end
			ZO_ScrollList_Commit(TBoxAddon_MainFrameListFrameList, datalist)
		else
			for k,v in pairs(searchTable) do searchTable[k] = nil end
			if refresh ~= 1 then searchtext = LowerSpaceSpecial(searchtext) end

			local opTable = {}
			local nTable = TableSelect()
			for k, v in pairs(nTable) do
				local sName =  LowerSpaceSpecial(v.name)
				if (string.find(sName,searchtext) ~= nil) then -- pre-build match tables for sorting
					opTable[k] = v
				end
			end
			NavigateScrollList(opTable)
		end
	end
end

local function TextSearchDelay() -- Avoid text search bogging down with type speed by adding a 200ms update delay
	textBuffer = 0
	TextSearch()
end

local function TextBoxEvents(option, extra) -- Text search mouse events
	local control = TBoxAddon_MainFrameListFrameSearchBox
	local controlBG = TBoxAddon_MainFrameListFrameSearchBG
	if option == 1 then -- On Mouse Enter
		if editText == 0 then
			controlBG:SetAlpha(0.5)
			if textInput == '' then
				control:SetText(L.TBoxAddon_SEARCHBOX	)
			else
				control:SetText(textInput)
			end
		end
		if (extra) then
			InitializeTooltip(InformationTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, L.TBoxAddon_RESETSEARCH)
		end
	elseif option == 2 then -- On Mouse Exit
		if editText == 0 then
			controlBG:SetAlpha(0)
			if control:GetText() == L.TBoxAddon_SEARCHBOX then
				textInput = L.TBoxAddon_SEARCHBOX
			end
			control:SetText('')
		end
		if (extra) then
			ClearTooltip(InformationTooltip)
		end
	elseif option == 3 then -- On Focus Gained
		control:SetText('')
		textInput = ''
		editText = 1
		TextSearch()
	elseif option == 4 then -- On Focus Lost
		editText = 0
		textInput = control:GetText()
		control:SetText('')
		controlBG:SetAlpha(0)
	--	TextSearch(1)
	elseif option == 5 then -- On Text Changed
		if textInput ~= L.TBoxAddon_SEARCHBOX and control:GetText() ~= L.TBoxAddon_SEARCHBOX then
			if textBuffer == 0 then
				textBuffer = 1
				zo_callLater(function() TextSearchDelay() end, 200)
			end
		end
	elseif option == 6 then -- Reset text search
		editText = 0
		control:SetText(L.TBoxAddon_SEARCHBOX)
		TextBoxEvents(2)
		local nTable = TableSelect()
		NavigateScrollList(nTable)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event and GUI functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnInventorySlotUpdate(e, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange) -- On treasure looted
	local itemType, specializedItemType = GetItemType(bagId, slotId)

	if itemType == ITEMTYPE_TREASURE and specializedItemType == SPECIALIZED_ITEMTYPE_TREASURE then
		local tId = GetItemId(bagId, slotId)
		local charID = GetCurrentCharacterId()
		if TBoxAddon.ASV.TreasureDB[tId] then
			local tZone = zo_strformat("<<t:1>>",GetZoneNameById(GetParentZoneId(GetZoneId(GetUnitZoneIndex("player"))))) -- get the base zone the treasure was found in
			local zOpt = ""
			if tZone ~= nil and tZone ~= "" then
				zOpt = tZone
			else
				zOpt = L.TBoxAddon_UNKNOWN -- fallback in case game returns "" for player zone
			end
			TBoxAddon.ASV.TreasureDB[tId].found = true
			TBoxAddon.ASV.TreasureDB[tId].lastFound = GetTimeStamp()
			TBoxAddon.ASV.TreasureDB[tId].lastZone = zOpt
			TBoxAddon.ASV.TreasureDB[tId].lastID = charID
			TBoxAddon.ASV.TreasureDB[tId].total = TBoxAddon.ASV.TreasureDB[tId].total + 1

			if not TBoxAddon.ASV.TreasureDB[tId].IDs[charID] then -- update the list of characters that have found this treasure
				TBoxAddon.ASV.TreasureDB[tId].IDs[charID] = true
			end
			if not TBoxAddon.ASV.TreasureDB[tId].zones[zOpt] then -- update the list of zones where this treasure was found
				TBoxAddon.ASV.TreasureDB[tId].zones[zOpt] = true
			end
			if not TBoxAddon.ASV.Zones[zOpt] and zOpt ~= L.TBoxAddon_UNKNOWN then -- update the list of all zones where any treasure has been found
				TBoxAddon.ASV.Zones[zOpt] = true
			end
		end
	end
end

local function OnCategorySelected(_, categoryName) -- Category filter dropbox callback
	TBoxAddon.ASV.aOpts.categoryNav = categoryName
	local nTable = TableSelect()
	NavigateScrollList(nTable)
end

local function OnZoneSelected(_, zoneName) -- Zone filter dropbox callback
	TBoxAddon.ASV.aOpts.zoneNav = zoneName
	local nTable = TableSelect()
	NavigateScrollList(nTable)
end

local function OnCharacterSelected(_, charName) -- Character filter dropbox callback
	TBoxAddon.ASV.aOpts.characterNav = charName
	local nTable = TableSelect()
	NavigateScrollList(nTable)
end

local function OnTreasureClick(clicktext, button) -- Handles shift-clicking of list items to link in chat
	local tooltipstyle = TBoxAddon.ASV.aOpts.tooltipstyle
	for i = 1, #searchTable do
		local name = searchTable[i].text
		local tId = searchTable[i].ID
		if clicktext == name then
			if IsShiftKeyDown() == true then
				local ChatEditControl = CHAT_SYSTEM.textEntry.editControl
				if not ChatEditControl:HasFocus() then 
					StartChatInput()
				end
				ChatEditControl:InsertText(TBoxAddon.AT.TreasureTable[tId].link)
			end
		end
	end
	ZO_ScrollList_RefreshVisible(TBoxAddon_MainFrameListFrameList)
end

local function OnTreasureTooltip(control, tId) -- Generate the extra statistical tooltip
	local cString = ""
	local lfiText = ""
	local lfbText = ""
	local foText = ""
	local fizText = ""
	
	local lastZone = TBoxAddon.ASV.TreasureDB[tId].lastZone
	local lastChar = TBoxAddon.ASV.TreasureDB[tId].lastID
	local lastName = (charID2Name[lastChar] ~= nil) and charID2Name[lastChar] or L.TBoxAddon_UNKNOWN 
	local total = TBoxAddon.ASV.TreasureDB[tId].total
	local zones = TBoxAddon.ASV.TreasureDB[tId].zones
	local timestamp = TBoxAddon.ASV.TreasureDB[tId].lastFound
	local tfText = L.TBoxAddon_TOTALF..pTC("00FF00", tostring(total))

	if (TBoxAddon.ASV.TreasureDB[tId].found) then
		local tdTable = os.date("*t", timestamp)
		local AMPM = ""
		local hour = ""
		local mint = ""
		if (TBoxAddon.ASV.aOpts.USTime) then
			if tdTable.hour == 0 then
				hour = "12"
				AMPM = "am"
			elseif tdTable.hour == 12 then
				hour = "12"
				AMPM = "pm"
			elseif tdTable.hour > 12 then
				tdTable.hour = tdTable.hour - 12
				hour = tostring(tdTable.hour)
				AMPM = "pm"
			else
				hour = tostring(tdTable.hour)
				AMPM = "am"
			end
		else
			hour = (tdTable.hour < 10) and "0"..tostring(tdTable.hour) or tostring(tdTable.hour)
		end
		mint = (tdTable.min < 10) and "0"..tostring(tdTable.min) or tostring(tdTable.min)
		local month = tostring(tdTable.month)
		local day = tostring(tdTable.day)
		local year = tostring(tdTable.year)
		lfiText = L.TBoxAddon_LFOUNDIN..pTC("00FF00", lastZone)
		lfbText = L.TBoxAddon_LFOUNDBY..pTC("00FF00", lastName)
		foText = L.TBoxAddon_FOUNDON..pTC("00FF00", month.."/"..day.."/"..year.." "..hour..":"..mint..AMPM)
		fizText = L.TBoxAddon_FINZONES
		for k in pairs(zones) do
			if fizText == L.TBoxAddon_FINZONES then
				fizText = fizText.."\n"..pTC("00FF00", tostring(k))
			else
				fizText = fizText..", "..pTC("00FF00", tostring(k))
			end
		end
	else
		lfiText = L.TBoxAddon_LFOUNDIN..pTC("00FF00", L.TBoxAddon_NONE)
		lfbText = L.TBoxAddon_LFOUNDIN..pTC("00FF00", L.TBoxAddon_NONE)
		foText = L.TBoxAddon_FOUNDON..pTC("00FF00", L.TBoxAddon_NEVER)
		fizText = L.TBoxAddon_FINZONES.." "..pTC("00FF00", L.TBoxAddon_NONE)
	end

	cString = lfiText.."\n"..lfbText.."\n"..foText.."\n"..tfText.."\n\n"..fizText
	InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 3, BOTTOMLEFT)
	InformationTooltip:AddLine(cString, "ZoFontWinH5", 1,1,1, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
end

local function OnMiniRecentQualityClick(button, option) -- Handles changing the recent item quality filter on button clicks
	if option == 1 then
		recentState[button] = 1
		InitializeTooltip(InformationTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
		SetTooltipText(InformationTooltip, L.TBoxAddon_RQUALITYS1..TBoxAddon.DB.RecentQualityValues[button]..L.TBoxAddon_RQUALITYS2)
	elseif option == 2 then
		recentState[button] = 0
		ClearTooltip(InformationTooltip)
		zo_callLater(function() HideQualitySelect() end, 200)
	elseif option == 3 then
		if TBoxAddon_MainFrameNavFrame:GetNamedChild('QualityCheckbox'..tostring(button)):GetState() ~= 1 then
			for i = 1, 5 do if i ~= button then TBoxAddon_MainFrameNavFrame:GetNamedChild('QualityCheckbox'..tostring(i)):SetState(0) end end
			TBoxAddon_MainFrameNavFrame:GetNamedChild('QualityCheckbox'..tostring(button)):SetState(1)
			TBoxAddon.ASV.aOpts.recentQuality = button
			TBoxAddon.DB.RecentIconGrid()
		end
	end
end

local function OnMiniRecentSelect(option) -- Show the recent item quality filter select buttons on mouseover
	if option == 1 then
		recentState[6] = 1
		for i = 1, 5 do
			local tControl = TBoxAddon_MainFrameNavFrame:GetNamedChild('QualityCheckbox'..tostring(i))
			tControl:SetHidden(false)
		end
	elseif option == 2 then
		recentState[6] = 0
		zo_callLater(function() HideQualitySelect() end, 200)
	end
end

local function OnSortByClick(button, option)
	if option <= 2 then
		local tText = (option == 1) and L.TBoxAddon_SALPHA or (option == 2) and L.TBoxAddon_SFOUND or L.TBoxAddon_STIME
		InitializeTooltip(InformationTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
		SetTooltipText(InformationTooltip, tText)
	elseif option <= 4 then
		ClearTooltip(InformationTooltip)
	elseif option <= 6 then
		if option == 5 then
			TBoxAddon_MainFrameSortByAlpha:SetState(1)
			TBoxAddon_MainFrameSortByFound:SetState(0)
			TBoxAddon.ASV.aOpts.sortState = 1
		elseif option == 6 then
			TBoxAddon_MainFrameSortByAlpha:SetState(0)
			TBoxAddon_MainFrameSortByFound:SetState(1)
			TBoxAddon.ASV.aOpts.sortState = 2
		end
		local nTable = TableSelect()
		NavigateScrollList(nTable)
	end
end

local function OnMiniRecentClick(icon, option, index) -- Handles shift-clicking of recent items to link in chat
	local itemLink = TBoxAddon.AT.TreasureTable[index].link
	local MiniRecentTooltip = TreasureItemTooltipControl
	if option == 1 then
		ScaleSelectedIcon(icon, true, false)
		InitializeTooltip(MiniRecentTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
		PopupTooltip.SetLink(MiniRecentTooltip, itemLink)
		OnTreasureTooltip(MiniRecentTooltip, index)
	elseif option == 2 then
		ScaleSelectedIcon(icon, false, false)
		ClearTooltip(MiniRecentTooltip)
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		ScaleSelectedIcon(icon, false, true)
	elseif option == 4 then
		ScaleSelectedIcon(icon, true, false)
		if IsShiftKeyDown() == true then
			local ChatEditControl = CHAT_SYSTEM.textEntry.editControl
			if not ChatEditControl:HasFocus() then 
				StartChatInput() 
			end
			ChatEditControl:InsertText(itemLink)
		end
	end
end

local function ToggleFound(option) -- Toggle only showing found treasures on and off
	if option == 1 then
		InitializeTooltip(InformationTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
		if (TBoxAddon.ASV.aOpts.showOnlyKnown) then
			SetTooltipText(InformationTooltip, L.TBoxAddon_TFOUNDOFF)
		else
			SetTooltipText(InformationTooltip, L.TBoxAddon_TFOUNDON)
		end
	elseif option == 2 then
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		if (TBoxAddon.ASV.aOpts.showOnlyKnown) then
			TBoxAddon.ASV.aOpts.showOnlyKnown = false
			ClearTooltip(InformationTooltip)
			InitializeTooltip(InformationTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, L.TBoxAddon_TFOUNDON)
		else
			TBoxAddon.ASV.aOpts.showOnlyKnown = true
			ClearTooltip(InformationTooltip)
			InitializeTooltip(InformationTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, L.TBoxAddon_TFOUNDOFF)
		end
		local nTable = TableSelect()
		NavigateScrollList(nTable)
	end
end

local function UpdateZoneList() -- Dynamically adds entries to the zone list when treasure is found there for the first time
	TBoxAddon.AT.Zones = {} -- sort the zone table alphabetically
	for k, v in pairs(TBoxAddon.ASV.Zones) do
		TBoxAddon.AT.Zones[#TBoxAddon.AT.Zones + 1] = k
	end
	table.sort(TBoxAddon.AT.Zones)

	zoneDropdown.dropdown:ClearItems()
	zoneDropdown.dropdown:AddItem(zoneDropdown.dropdown:CreateItemEntry(L.TBoxAddon_ALLZONES, OnZoneSelected)) -- add default header
	
	for k, v in ipairs(TBoxAddon.AT.Zones) do -- add pre-sorted entry list
		local entry = zoneDropdown.dropdown:CreateItemEntry(v, OnZoneSelected)
		zoneDropdown.dropdown:AddItem(entry)
	end
	zoneDropdown.dropdown:SetSelectedItem(TBoxAddon.ASV.aOpts.zoneNav) -- set the dropdown selected item to the default
end

local function ShowMain(option) -- Launch the main Treasure Box GUI
	if TBoxAddon.InitCheck == 3 then
		if (TBoxAddon.InitCheck) then
			if option == 'reposition' then
				TBoxAddon.ASV.aOpts.xpos = 0
				TBoxAddon.ASV.aOpts.ypos = 0
				RestorePosition()
			elseif option == 'update' then
				DB.InitTables(true, uVersion)
			else
				local control = GetControl('TBoxAddon_MainFrame')
				if ( control:IsHidden() ) then
					SCENE_MANAGER:ShowTopLevel(TBoxAddon_MainFrame)
					RestorePosition()
					UpdateZoneList()
					TBoxAddon.DB.RecentIconGrid()
	
					local nTable = TableSelect()
					NavigateScrollList(nTable)
				else
					SCENE_MANAGER:HideTopLevel(TBoxAddon_MainFrame)
				end
			end
		else
			d(L.TBoxAddon_UPDATE3)
		end
	else
		d(L.TBoxAddon_UPDATE3)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Initialize tooltip & list item controls
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function InitTreasureTooltip(control) -- Initialize the popup tooltip template
	if not control then return end
	TreasureItemTooltipControl = control
	control:SetParent(PopupTooltipTopLevel)
end

local function ListTooltips(control, text, option) -- Generate the popup list tooltips
	local TreasureItemTooltip = TreasureItemTooltipControl
	if option == 1 then
		for i = 1, #searchTable do
			local tId = searchTable[i].ID
			local name = searchTable[i].text
			if text == name then
				local itemLink = TBoxAddon.AT.TreasureTable[tId].link
				InitializeTooltip(TreasureItemTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
				PopupTooltip.SetLink(TreasureItemTooltip, itemLink)
				OnTreasureTooltip(TreasureItemTooltip, tId)
			end
		end
		control:SetAlpha(.5)
	elseif option == 2 then
		ClearTooltip(TreasureItemTooltip)
		ClearTooltip(InformationTooltip)
		control:SetAlpha(1)
	end
end

local function SetListItem(control, data) -- Hook the ScrollList entry callback
	local listitemtext = control:GetNamedChild( 'Name' )
	listitemtext:SetText( data.TreasureName )
end

local function InitMain() -- Initialize ScrollList from XML template
	local control = GetControl('TBoxAddon_MainFrameListFrameList')
	ZO_ScrollList_AddDataType(control, 1 , 'TBoxAddon_ListItemTemplate', 20,  SetListItem)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon initialization
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function SetupCharacters() -- Initialize and update account list & dropbox selection of all tracked characters
	local tempIDs = {}
	charNamesGUI_T = {}
	charNamesGUI = {}
	for i = 1, GetNumCharacters() do -- populate table of all character names on the current account indexed by unique ID
		local charName, _, _, _, _, _, charID = GetCharacterInfo(i)
		charName = zo_strformat(SI_UNIT_NAME, charName)
		tempIDs[#tempIDs + 1] = {name = charName, ID = charID}
		charName2ID[charName] = charID
		charID2Name[charID] = charName
	end
	for k, v in ipairs(tempIDs) do -- build list of valid account characters the addon knows about
		local cName = tempIDs[k].name
		local cID = tempIDs[k].ID
		charNamesGUI_T[#charNamesGUI_T + 1] = cName
	end
	charNamesGUI = (TBoxAddon.ASV.aOpts.charSortAlpha) and table.sort(charNamesGUI_T) or charNamesGUI_T -- sort character database alphabetically or as account order

	-- set up the character dropdown selection box
	if charnameDropdown == nil then
		charnameDropdown = WINDOW_MANAGER:CreateControlFromVirtual('TBoxAddonCharacterList', TBoxAddon_MainFrameNavFrame, 'ZO_StatsDropdownRow')
		charnameDropdown:SetWidth(300)
		charnameDropdown:SetAnchor(BOTTOMLEFT, TBoxAddon_MainFrame, BOTTOMLEFT, -6, 2)
		charnameDropdown:GetNamedChild('Dropdown'):SetWidth(295)
	end

	charnameDropdown.dropdown.m_sortsItems = false -- prevent game auto-sorting so default header stays on top
	charnameDropdown.dropdown:ClearItems()
	charnameDropdown.dropdown:AddItem(charnameDropdown.dropdown:CreateItemEntry(L.TBoxAddon_ANYFOUND, OnCharacterSelected)) -- add default header

	for k, v in ipairs(charNamesGUI) do -- add pre-sorted entry list
		local entry = charnameDropdown.dropdown:CreateItemEntry(v, OnCharacterSelected)
		charnameDropdown.dropdown:AddItem(entry)
	end
	charnameDropdown.dropdown:SetSelectedItem(TBoxAddon.ASV.aOpts.characterNav) -- set the dropdown selected item to the default
end

local function SetupZones() -- Initialize dropdown zone selection
	if zoneDropdown == nil then
		zoneDropdown = WINDOW_MANAGER:CreateControlFromVirtual('TBoxAddonZoneList', TBoxAddon_MainFrameNavFrame, 'ZO_StatsDropdownRow')
		zoneDropdown:SetWidth(300)
		zoneDropdown:SetAnchor(BOTTOMLEFT, GetControl('TBoxAddonCharacterList'), TOPLEFT, 0, -2)
		zoneDropdown:GetNamedChild('Dropdown'):SetWidth(295)
	end

	zoneDropdown.dropdown.m_sortsItems = false -- prevent game auto-sorting so default header stays on top
	zoneDropdown.dropdown:ClearItems()
	zoneDropdown.dropdown:AddItem(zoneDropdown.dropdown:CreateItemEntry(L.TBoxAddon_ALLZONES, OnZoneSelected)) -- add default header

	for k, v in ipairs(TBoxAddon.AT.Zones) do -- add pre-sorted entry list
		local entry = zoneDropdown.dropdown:CreateItemEntry(v, OnZoneSelected)
		zoneDropdown.dropdown:AddItem(entry)
	end
	zoneDropdown.dropdown:SetSelectedItem(TBoxAddon.ASV.aOpts.zoneNav) -- set the dropdown selected item to the default

	local function ShowHide(opt)
		if opt == 1 then
			GetControl('TBoxAddonCharacterList'):SetHidden(true)
		elseif opt == 2 then
			GetControl('TBoxAddonCharacterList'):SetHidden(false)
		end
	end
	ZO_PreHook(zoneDropdown.dropdown, "ShowDropdownInternal", function( ... ) ShowHide(1) end)
	ZO_PreHook(zoneDropdown.dropdown, "HideDropdownInternal", function( ... ) ShowHide(2) end)
end

local function SetupCategories() -- Initialize dropdown category selection
	if categoryDropdown == nil then
		categoryDropdown = WINDOW_MANAGER:CreateControlFromVirtual('TBoxAddonCategoryList', TBoxAddon_MainFrameNavFrame, 'ZO_StatsDropdownRow')
		categoryDropdown:SetWidth(300)
		categoryDropdown:SetAnchor(BOTTOMLEFT, GetControl('TBoxAddonZoneList'), TOPLEFT, 0, -2)
		categoryDropdown:GetNamedChild('Dropdown'):SetWidth(295)
	end

	categoryDropdown.dropdown.m_sortsItems = false -- prevent game auto-sorting so default header stays on top
	categoryDropdown.dropdown:ClearItems()
	categoryDropdown.dropdown:AddItem(categoryDropdown.dropdown:CreateItemEntry(L.TBoxAddon_ALLTYPES, OnCategorySelected)) -- add default header

	for k, v in ipairs(TBoxAddon.AT.Categories) do -- add pre-sorted entry list
		local entry = categoryDropdown.dropdown:CreateItemEntry(v, OnCategorySelected)
		categoryDropdown.dropdown:AddItem(entry)
	end
	categoryDropdown.dropdown:SetSelectedItem(TBoxAddon.ASV.aOpts.categoryNav) -- set the dropdown selected item to the default

	local function ShowHide(opt)
		if opt == 1 then
			GetControl('TBoxAddonZoneList'):SetHidden(true)
			GetControl('TBoxAddonCharacterList'):SetHidden(true)
		elseif opt == 2 then
			GetControl('TBoxAddonZoneList'):SetHidden(false)
			GetControl('TBoxAddonCharacterList'):SetHidden(false)
		end
	end
	ZO_PreHook(categoryDropdown.dropdown, "ShowDropdownInternal", function( ... ) ShowHide(1) end)
	ZO_PreHook(categoryDropdown.dropdown, "HideDropdownInternal", function( ... ) ShowHide(2) end)
end

local function SetupQuality() -- Initialize the quality navigation 
	for i = 1, 6 do if TBoxAddon.ASV.aOpts.qualityNav == DB.QualityNav[i].opt then ResetQualityNav(i) end end
end

local function SetupRecentQuality() -- Initialize the UI pop-out checkbox controls for recent treasure quality filtering
	local rTable = {[1]=5,[2]=4,[3]=3,[4]=2,[5]=1}
	for i = 1, 5 do
		if TBoxAddon_MainFrameNavFrame:GetNamedChild('TBoxAddon_MainFrameNavFrameQualityCheckbox'..tostring(rTable[i])) == nil then

			local tControl = WINDOW_MANAGER:CreateControlFromVirtual('TBoxAddon_MainFrameNavFrameQualityCheckbox'..tostring(rTable[i]), TBoxAddon_MainFrameNavFrame, 'ZO_CheckButton')
			tControl:SetHandler("OnMouseEnter", function() OnMiniRecentQualityClick(rTable[i], 1) end)
			tControl:SetHandler("OnMouseExit", function() OnMiniRecentQualityClick(rTable[i], 2) end)
			tControl:SetHandler("OnClicked", function() OnMiniRecentQualityClick(rTable[i], 3) end)
			if rTable[i] == 5 then
				tControl:SetAnchor(RIGHT, TBoxAddon_MainFrameNavFrameRecentQualitySelect, LEFT, 0, 0)
			else
				tControl:SetAnchor(RIGHT, TBoxAddon_MainFrameNavFrame:GetNamedChild('QualityCheckbox'..tostring(rTable[i]+1)), LEFT, 0, 0)
			end
			tControl:SetHidden(true)
		end
	end
	for i = 1, 5 do
		if i ~= TBoxAddon.ASV.aOpts.recentQuality then
			TBoxAddon_MainFrameNavFrame:GetNamedChild('QualityCheckbox'..tostring(i)):SetState(0)
		else
			TBoxAddon_MainFrameNavFrame:GetNamedChild('QualityCheckbox'..tostring(i)):SetState(1)
		end
	end
	for s = 1, 6 do recentState[s] = 0 end
end

local function SetupTime() -- Initialize the time navigation
	for i = 1, 6 do if TBoxAddon.ASV.aOpts.timeNav == DB.TimeNav[i].days then ResetTimeNav(i) end end
end

local function ResetFilters(option) -- Reset all filters and text search
	if option == 1 then
		InitializeTooltip(InformationTooltip, TBoxAddon_MainFrameCloseButton, TOPLEFT, 8, -44, BOTTOMRIGHT)
		SetTooltipText(InformationTooltip, L.TBoxAddon_RESETFILTER)
	elseif option == 2 then
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		TBoxAddon.ASV.aOpts.qualityNav = Defaults.qualityNav
		TBoxAddon.ASV.aOpts.timeNav = Defaults.timeNav
		TBoxAddon.ASV.aOpts.categoryNav = Defaults.categoryNav
		TBoxAddon.ASV.aOpts.zoneNav = Defaults.zoneNav
		TBoxAddon.ASV.aOpts.characterNav = Defaults.characterNav
		TextBoxEvents(6)
		zoneDropdown.dropdown:SetSelectedItem(TBoxAddon.ASV.aOpts.zoneNav)
		charnameDropdown.dropdown:SetSelectedItem(TBoxAddon.ASV.aOpts.characterNav)
		categoryDropdown.dropdown:SetSelectedItem(TBoxAddon.ASV.aOpts.categoryNav)
		SetupQuality()
		SetupTime()
		local nTable = TableSelect()
		NavigateScrollList(nTable)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Handle function calls from XML
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function TBoxAddon.XMLNavigation(option, control, extra, n1, n2)
-- List click and tooltips
	if option == 001 then
		ListTooltips(control, extra, n1)
	elseif option == 002 then
		OnTreasureClick(extra, n1)
-- Main Frame functions
	elseif option == 101 then
		OnMoveStop()
	elseif option == 102 then
		InitMain()
	elseif option == 103 then
		InitTreasureTooltip(control)
	elseif option == 104 then
		CloseMain(n1)
	elseif option == 105 then
		ToggleFound(n1)
	elseif option == 106 then
		ResetFilters(n1)
	elseif option == 107 then
		SetupCharacters()
-- Text search options
	elseif option == 201 then
		TextBoxEvents(n1, extra)
-- Open Main Window
	elseif option == 301 then
		ShowMain()
-- Quality Navigation
	elseif option == 401 then
		ResetQualityNav(n1)
		if (CheckText()) then
			textBuffer = 0
			TextSearch(1)
		else
			local nTable = TableSelect()
			NavigateScrollList(nTable)
		end
	elseif option == 402 then
		QualityNavigation(n1, extra)
-- Time Navigation
	elseif option == 403 then
		ResetTimeNav(n1)
		if (CheckText()) then
			textBuffer = 0
			TextSearch(1)
		else
			local nTable = TableSelect()
			NavigateScrollList(nTable)
		end
	elseif option == 404 then
		TimeNavigation(n1, extra)
-- Mini recent frame
	elseif option == 501 then
		OnMiniRecentClick(control, extra, n1)
	elseif option == 502 then
		OnMiniRecentSelect(n1)
-- Sort By selection
	elseif option == 503 then
		OnSortByClick(control, extra)
	end
end

local function DBMaintenance() -- Checks if update to the database tables is necessary
	if TBoxAddon.ASV.aOpts.version < uVersion then
		if not TBoxAddon.ResetPending then
			DB.InitTables(true, uVersion)
		end
	end
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= 'TreasureBox' then return end
	EVENT_MANAGER:UnregisterForEvent('TreasureBox', EVENT_ADD_ON_LOADED)
	SCENE_MANAGER:RegisterTopLevel(TBoxAddon_MainFrame, false) -- register with scene manager for show/hide functions
	ZO_CreateStringId('SI_BINDING_NAME_TOGGLE_TREASURE_BOX_WINDOW', 'Toggle Main Window') -- register binding strings
	DB.SetupVars() --Saved variables setup
	TBoxAddon.InitCheck = 0
	TBoxAddon.ResetPending = false
end

local function Init(_, initial)

	if TBoxAddon.InitCheck == 0 then
		TBoxAddon.InitCheck = 1
		DB.InitTables(false, uVersion) -- runs the main init script for the addon
		zo_callLater(function() Init(_, initial) end, 1000) -- starts the wait loop before running final startup functions

	elseif TBoxAddon.InitCheck == 2 then

	-- Run startup functions
		DBMaintenance()
		SetupCharacters()
		SetupZones()
		SetupCategories()
		SetupQuality()
		SetupRecentQuality()
		SetupTime()
		DB.PostFrames()
		DB.CreateSettingsWindow(addonName, version)

		TBoxAddon.InitCheck = 3 -- put in 'running' state to avoid re-initializing whenever the game does load screens

--	elseif TBoxAddon.InitCheck == 3 then
--		d("load screen check")

	elseif TBoxAddon.InitCheck == 1 then -- wait for main init process to finish
		zo_callLater(function() Init(_, initial) end, 1000)
	end

-- Pre-filter for supported criteria using event filters for speed on heavy events
	EVENT_MANAGER:RegisterForEvent('TreasureBox', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
	EVENT_MANAGER:AddFilterForEvent('TreasureBox', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
	EVENT_MANAGER:AddFilterForEvent('TreasureBox', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
	EVENT_MANAGER:AddFilterForEvent('TreasureBox', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
end

SLASH_COMMANDS['/tbox'] = function(option) ShowMain(option) end
EVENT_MANAGER:RegisterForEvent('TreasureBox', EVENT_PLAYER_ACTIVATED, Init)
EVENT_MANAGER:RegisterForEvent('TreasureBox', EVENT_ADD_ON_LOADED, OnAddonLoaded)
