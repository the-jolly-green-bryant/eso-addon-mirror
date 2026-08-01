local EZReport = _G['EZReport']
local L = EZReport:GetLanguage()
local pTC = EZReport.TColor
local pR2 = EZReport.RGB2Hex

local nameList = {}
local editList = {}
local optionDrop
local activeItem
local selectControl
local selectPrompt = 0

local Options = {[0] = L.EZReport_Accounts,[1] = L.EZReport_Characters,[2] = L.EZReport_Locations}
EZReport.rReasons = {[0] = L.EZReport_CReason1,[1] = L.EZReport_CReason2,[2] = L.EZReport_CReason3,[3] = L.EZReport_CReason4,[4] = L.EZReport_CReason1}

------------------------------------------------------------------------------------------------------------------------------------
-- Main window and utility functions
------------------------------------------------------------------------------------------------------------------------------------
local function OnMoveStop() -- Saves the current window position when closed.
	EZReport.ASV.sVars.xpos = EZReport_MainFrame:GetLeft()
	EZReport.ASV.sVars.ypos = EZReport_MainFrame:GetTop()
end

local function RestorePosition() -- Restores previous window position when opened.
	local left = EZReport.ASV.sVars.xpos
	local top = EZReport.ASV.sVars.ypos
	EZReport_MainFrame:ClearAnchors()
	EZReport_MainFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function CloseMain(control, option) -- Closes the main window and returns cursor control.
	if selectPrompt == 0 then
		if option == 1 then
			InitializeTooltip(InformationTooltip, EZReport_MainFrame, TOPLEFT, 10, -8, TOPRIGHT)
			SetTooltipText(InformationTooltip, "Close")
		elseif option == 2 then
			ClearTooltip(InformationTooltip)
		elseif option == 3 then
			SCENE_MANAGER:ToggleTopLevel(EZReport_MainFrame)
		end
	end
end

local function GetSortedNames(tTable) -- Sorts table names alphanumerically.
	local tNames = {}
	local sNames = {}
	for k, _ in pairs(tTable) do
		table.insert(tNames, k) 
	end
	table.sort(tNames)
	for k, n in ipairs(tNames) do
		sNames[#sNames + 1] = n
	end
	return sNames
end

local function ResetNav() -- Clear the entry list frame.
	ZO_ScrollList_Clear(EZReport_MainFrame_ListFrame_EditBox)
	local datalist = ZO_ScrollList_GetDataList(EZReport_MainFrame_ListFrame_EditBox)
	for k,v in pairs(datalist) do datalist[k] = nil end
	ZO_ScrollList_Commit(EZReport_MainFrame_ListFrame_EditBox, datalist)
end

local function OptionSelected(_, sText, choice) -- Dropbox callback.
	for k,v in pairs(Options) do
		if (string.find(sText,v) ~= nil) then
			EZReport.ASV.sVars.nMode = k
			ResetNav()
			EZReport.SetupList()
			return
		end
	end
end

local function SwapMode(control, option) -- Swap between text report and db edit mode.
	if selectPrompt == 0 then
		if option == 1 then
			local text = (EZReport.ASV.sVars.rMode == 0) and L.EZReport_TTEMode or L.EZReport_TTRMode
			InitializeTooltip(InformationTooltip, EZReport_MainFrame, TOPLEFT, 10, -8, TOPRIGHT)
			SetTooltipText(InformationTooltip, text)
		elseif option == 2 then
			ClearTooltip(InformationTooltip)
		elseif option == 3 then
			local tvar = (EZReport.ASV.sVars.rMode == 0) and 1 or 0
			EZReport.ASV.sVars.rMode = tvar
			if tvar == 0 then
				EZReport_MainFrame_ListFrame_TextBox:SetHidden(false)
				EZReport_MainFrame_ListFrame_EditBox:SetHidden(true)
			else
				EZReport_MainFrame_ListFrame_TextBox:SetHidden(true)
				EZReport_MainFrame_ListFrame_EditBox:SetHidden(false)
			end
			ClearTooltip(InformationTooltip)
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------
-- List functions
------------------------------------------------------------------------------------------------------------------------------------
local function SetListItem(control,data) -- Hook the scroll list data table.
	local listitemtext = control:GetNamedChild( '_Name' )
	listitemtext:SetText( data.ReportName )
end

local function InitMain() -- Configures the scroll list parameters.
	local list1 = GetControl('EZReport_MainFrame_ListFrame_List')
	local list2 = GetControl('EZReport_MainFrame_ListFrame_EditBox')
	ZO_ScrollList_AddDataType(list1, 1 , 'EZReport_ListItemTemplate', 20,  SetListItem)
	ZO_ScrollList_AddDataType(list2, 1 , 'EZReport_ListEditTemplate', 50,  SetListItem)
end

local function ListTooltips(control, option) -- List item tooltips.
	if selectPrompt == 0 then
		if option == 1 then
			local nl = "\n"
			local c1 = "|cffffff"
			local c2 = "|cffff00"
			local cc = "|r"
			local t1 = L.EZReport_TTShow
			local t2 = L.EZReport_TTClick
			local t3 = L.EZReport_TTSelect1
			local t4 = L.EZReport_TTSelect2
			local t5 = L.EZReport_TTCopy1
			local t6 = L.EZReport_TTCopy2
			local t7 = L.EZReport_TTPaste1
			local t8 = L.EZReport_TTPaste2
			local text = c2..t1..cc..nl..c1..t2..cc..nl..c2..t3..cc..t4..nl..c2..t5..cc..t6..nl..c2..t7..cc..t8
			InitializeTooltip(InformationTooltip, EZReport_MainFrame, TOPLEFT, 10, -8, TOPRIGHT)
			SetTooltipText(InformationTooltip, text)
			control:SetAlpha(.5)
		elseif option == 2 then
			ClearTooltip(InformationTooltip)
			control:SetAlpha(1)
		end
	end
end

local function PopulateEditList() -- Populate list based on display setting.
	ZO_ScrollList_Clear(EZReport_MainFrame_ListFrame_EditBox)
	local datalist = ZO_ScrollList_GetDataList(EZReport_MainFrame_ListFrame_EditBox)
	for k,v in pairs(datalist) do datalist[k] = nil end

	for i = 1, #editList do
		local name = editList[i].text
		datalist[i] = ZO_ScrollList_CreateDataEntry( 1, 
		{
			ReportName = pTC("ffff00",name),
		}
		)
		ZO_ScrollList_Commit(EZReport_MainFrame_ListFrame_EditBox, datalist)
	end
end

local function ListClick(text, manual) -- Handles clicking left-side category navigation items.
	if selectPrompt == 0 or manual == 1 then
		EZReport_MainFrame_ListFrame_TextBox:SetText("")
		for k,v in pairs(editList) do editList[k] = nil end
		activeItem = text
		local sVar = EZReport.ASV.sVars.nMode
		local c1 = "|cffff00"
		local c2 = "|cffffff"
		local c3 = "|c66ccff"
		local cc = "|r"
		local tText = ""

		local function ShowByName(ttable, tvals)
			local count = 0
			for _, nt in ipairs(ttable) do
				local dt = tostring(nt)

				if tvals[dt].rAC == 1 then
					local rName = tvals[dt].rName
					local rDT = EZReport.ASV.characterDB[rName][dt].rDT
					local rZone = EZReport.ASV.characterDB[rName][dt].rZone
					local rSub = EZReport.ASV.characterDB[rName][dt].rSub
					local rMap = (rSub ~= "") and rZone..rSub or rZone
					local rReason = EZReport.ASV.characterDB[rName][dt].rReason
					local rColor = "|c"..pR2(EZReport.ASV.rColor[rReason].color)
					local rText = EZReport.rReasons[rReason]

					local tString = rDT.." - "..rName.." \("..L.EZReport_AccUnavail.."\)\n     "..rText..": "..rMap
					local cString = c1..rDT..cc..c2.." - "..rName.." \("..cc..c3..L.EZReport_AccUnavail..cc..c1.."\)\n     "..cc..rColor..rText..": "..cc..c2..rMap..cc

					local nlb = (count > 0) and "\r\n\n" or ""
					tText = tText..nlb..tString
					count = count + 1

					editList[#editList + 1] = {text=cString,char=rName,acc=L.EZReport_AccUnavail,dTime=dt,rAC=1}

				elseif tvals[dt].rAC == 0 then
					local rName = tvals[dt].rName
					for aName, _ in pairs(EZReport.ASV.accountDB) do
						for name, _ in pairs(EZReport.ASV.accountDB[aName].names) do
							if (string.find(rName,name) ~= nil) then
								local rDT = EZReport.ASV.accountDB[aName].names[name][dt].rDT
								local rZone = EZReport.ASV.accountDB[aName].names[name][dt].rZone
								local rSub = EZReport.ASV.accountDB[aName].names[name][dt].rSub
								local rMap = (rSub ~= "") and rZone..rSub or rZone
								local rReason = EZReport.ASV.accountDB[aName].names[name][dt].rReason
								local rColor = "|c"..pR2(EZReport.ASV.rColor[rReason].color)
								local rText = EZReport.rReasons[rReason]

								local tString = rDT.." - "..name.." \("..aName.."\)\n     "..rText..": "..rMap
								local cString = c1..rDT..cc..c2.." - "..name.." \("..cc..c3..aName..cc..c1.."\)\n     "..cc..rColor..rText..": "..cc..c2..rMap..cc

								local nlb = (count > 0) and "\r\n\n" or ""
								tText = tText..nlb..tString
								count = count + 1

								editList[#editList + 1] = {text=cString,char=name,acc=aName,dTime=dt,rAC=0}

							end
						end
					end
				end
			end
			EZReport_MainFrame_ListFrame_TextBox:SetText(tText)
			PopulateEditList()
		end

		if sVar == 0 then
			local count = 0
			for aName, _ in pairs(EZReport.ASV.accountDB) do
				if (string.find(text,aName) ~= nil) then

					local sortNames = {}
					for name, _ in pairs(EZReport.ASV.accountDB[aName].names) do
						table.insert(sortNames, name)
					end
					table.sort(sortNames)

					for _, sName in ipairs(sortNames) do
						local tsort = {}
						local rsort = {}

						for k, _ in pairs(EZReport.ASV.accountDB[aName].names[sName]) do table.insert(tsort, tonumber(k)) end
						table.sort(tsort)

						for _, rt in ipairs(tsort) do
							table.insert(rsort, 1, rt)
						end

						for _, nt in ipairs(rsort) do
							local dt = tostring(nt)

							local rDT = EZReport.ASV.accountDB[aName].names[sName][dt].rDT
							local rZone = EZReport.ASV.accountDB[aName].names[sName][dt].rZone
							local rSub = EZReport.ASV.accountDB[aName].names[sName][dt].rSub
							local rMap = (rSub ~= "") and rZone..rSub or rZone
							local rReason = EZReport.ASV.accountDB[aName].names[sName][dt].rReason
							local rColor = "|c"..pR2(EZReport.ASV.rColor[rReason].color)
							local rText = EZReport.rReasons[rReason]

							local tString = rDT.." - "..sName.." \("..aName.."\)\n     "..rText..": "..rMap
							local cString = c1..rDT..cc..c2.." - "..sName.." \("..cc..c3..aName..cc..c1.."\)\n     "..cc..rColor..rText..": "..cc..c2..rMap..cc

							local nlb = (count > 0) and "\r\n\n" or ""
							tText = tText..nlb..tString
							count = count + 1

							editList[#editList + 1] = {text=cString,char=sName,acc=aName,dTime=dt,rAC=0}

						end
					end
				end
			end
			EZReport_MainFrame_ListFrame_TextBox:SetText(tText)
			PopulateEditList()

		elseif sVar == 1 then
			local tsort = {}
			local rsort = {}
			local tvals = {}

			local sortNames = {}
			for name, _ in pairs(EZReport.ASV.characterDB) do
				if (string.find(text,name) ~= nil) then
					table.insert(sortNames, name)
				end
			end
			for aName, _ in pairs(EZReport.ASV.accountDB) do
				for name, _ in pairs(EZReport.ASV.accountDB[aName].names) do
					if (string.find(text,name) ~= nil) then
						table.insert(sortNames, name)
					end
				end
			end
			table.sort(sortNames)
			
			for _, sName in ipairs(sortNames) do
				if EZReport.ASV.characterDB[sName] then
					for dt, _ in pairs(EZReport.ASV.characterDB[sName]) do
						table.insert(tsort, tonumber(dt))
						tvals[dt] = {rAC=1,rName=sName}
					end
				else
					for aName, _ in pairs(EZReport.ASV.accountDB) do
						if EZReport.ASV.accountDB[aName].names[sName] then
							for dt, _ in pairs(EZReport.ASV.accountDB[aName].names[sName]) do
								table.insert(tsort, tonumber(dt))
								tvals[dt] = {rAC=0,rName=sName}
							end
						end
					end
				end
			end

			table.sort(tsort)
			for _, rt in ipairs(tsort) do table.insert(rsort, 1, rt) end
			ShowByName(rsort, tvals)

		elseif sVar == 2 then
			local tsort = {}
			local rsort = {}
			local tvals = {}

			local sortNames = {}
			for name, _ in pairs(EZReport.ASV.characterDB) do
				table.insert(sortNames, name)
			end
			for aName, _ in pairs(EZReport.ASV.accountDB) do
				for name, _ in pairs(EZReport.ASV.accountDB[aName].names) do
					table.insert(sortNames, name)
				end
			end
			table.sort(sortNames)

			for _, sName in ipairs(sortNames) do
				if EZReport.ASV.characterDB[sName] then
					for dt, _ in pairs(EZReport.ASV.characterDB[sName]) do
						local zone = EZReport.ASV.characterDB[sName][dt].rZone
						if (string.find(text,zone) ~= nil) then
							table.insert(tsort, tonumber(dt))
							tvals[dt] = {rAC=1,rName=sName}
						end
					end
				else
					for aName, _ in pairs(EZReport.ASV.accountDB) do
						if EZReport.ASV.accountDB[aName].names[sName] then
							for dt, _ in pairs(EZReport.ASV.accountDB[aName].names[sName]) do
								local zone = EZReport.ASV.accountDB[aName].names[sName][dt].rZone
								if (string.find(text,zone) ~= nil) then
									table.insert(tsort, tonumber(dt))
									tvals[dt] = {rAC=0,rName=sName}
								end
							end
						end
					end
				end
			end
			table.sort(tsort)
			for _, rt in ipairs(tsort) do table.insert(rsort, 1, rt) end
			ShowByName(rsort, tvals)

		end
	end
end

local function ConfirmSelection() -- Handles deleting clicked entry from the database and re-populating lists.
	local sVar = EZReport.ASV.sVars.nMode
	local list = selectControl:GetParent()
	local data = editList[list.index]
	EZReport_MainFrame_ListFrame_Delete:SetHidden(true)
	local function CountKeys(cTable)
		local count = 0
		for k, v in pairs(cTable) do
			count = count + 1
		end
		return count
	end

	if editList[list.index].rAC == 1 then
		EZReport.ASV.characterDB[data.char][data.dTime] = nil
		local t1 = EZReport.ASV.characterDB[data.char]
		local t2 = (EZReport.ASV.accountDB[data.acc] ~= nil) and ((EZReport.ASV.accountDB[data.acc].names[data.char] ~= nil) and EZReport.ASV.accountDB[data.acc].names[data.char] or nil) or nil
		local c1 = (t1 ~= nil) and CountKeys(t1) or nil
		local c2 = (t2 ~= nil) and CountKeys(t2) or nil
		if c1 == 0 then
			EZReport.ASV.characterDB[data.char] = nil
			c1 = nil
		end
		if c2 == 0 then
			EZReport.ASV.accountDB[data.acc].names[data.char] = nil
			if EZReport.ASV.accountDB[data.acc] ~= nil then
				if CountKeys(EZReport.ASV.accountDB[data.acc].names) == 0 then
					EZReport.ASV.accountDB[data.acc] = nil
				end
			end
			c2 = nil
		end
		if c1 == nil and c2 == nil then
			ResetNav()
			activeItem = ""
			EZReport.SetupList()
		else
			ResetNav()
			ListClick(activeItem, 1)
		end
	elseif editList[list.index].rAC == 0 then
		EZReport.ASV.accountDB[data.acc].names[data.char][data.dTime] = nil
		if sVar == 0 then
			if CountKeys(EZReport.ASV.accountDB[data.acc].names[data.char]) == 0 then
				EZReport.ASV.accountDB[data.acc].names[data.char] = nil
				if CountKeys(EZReport.ASV.accountDB[data.acc].names) == 0 then
					EZReport.ASV.accountDB[data.acc] = nil
					ResetNav()
					activeItem = ""
					EZReport.SetupList()
				else
					ResetNav()
					ListClick(activeItem, 1)
				end
			else
				ResetNav()
				ListClick(activeItem, 1)
			end
		elseif sVar == 1 then
			local t1 = EZReport.ASV.characterDB[data.char]
			local t2 = (EZReport.ASV.accountDB[data.acc] ~= nil) and ((EZReport.ASV.accountDB[data.acc].names[data.char] ~= nil) and EZReport.ASV.accountDB[data.acc].names[data.char] or nil) or nil
			local c1 = (t1 ~= nil) and CountKeys(t1) or nil
			local c2 = (t2 ~= nil) and CountKeys(t2) or nil
			if c1 == 0 then
				EZReport.ASV.characterDB[data.char] = nil
				c1 = nil
			end
			if c2 == 0 then
				EZReport.ASV.accountDB[data.acc].names[data.char] = nil
				if EZReport.ASV.accountDB[data.acc] ~= nil then
					if CountKeys(EZReport.ASV.accountDB[data.acc].names) == 0 then
						EZReport.ASV.accountDB[data.acc] = nil
					end
				end
				c2 = nil
			end
			if c1 == nil and c2 == nil then
				ResetNav()
				activeItem = ""
				EZReport.SetupList()
			else
				ResetNav()
				ListClick(activeItem, 1)
			end
		elseif sVar == 2 then
			local t1 = EZReport.ASV.characterDB[data.char]
			local t2 = (EZReport.ASV.accountDB[data.acc] ~= nil) and ((EZReport.ASV.accountDB[data.acc].names[data.char] ~= nil) and EZReport.ASV.accountDB[data.acc].names[data.char] or nil) or nil
			local c1 = (t1 ~= nil) and CountKeys(t1) or nil
			local c2 = (t2 ~= nil) and CountKeys(t2) or nil
			if c1 == 0 then
				EZReport.ASV.characterDB[data.char] = nil
				c1 = nil
			end
			if c2 == 0 then
				EZReport.ASV.accountDB[data.acc].names[data.char] = nil
				if EZReport.ASV.accountDB[data.acc] ~= nil then
					if CountKeys(EZReport.ASV.accountDB[data.acc].names) == 0 then
						EZReport.ASV.accountDB[data.acc] = nil
					end
				end
				c2 = nil
			end

			local countLoc = 0
			for aName, _ in pairs(EZReport.ASV.accountDB) do
				for name, _ in pairs(EZReport.ASV.accountDB[aName].names) do
					for dt, _ in pairs(EZReport.ASV.accountDB[aName].names[name]) do
						local rZone = EZReport.ASV.accountDB[aName].names[name][dt].rZone
						if (string.find(activeItem,rZone) ~= nil) then
							countLoc = countLoc + 1
						end
					end
				end
			end
			for name, _ in pairs(EZReport.ASV.characterDB) do
				for dt, _ in pairs(EZReport.ASV.characterDB[name]) do
					local rZone = EZReport.ASV.characterDB[name][dt].rZone
					if (string.find(activeItem,rZone) ~= nil) then
						countLoc = countLoc + 1
					end
				end
			end
			if countLoc == 0 then
				ResetNav()
				activeItem = ""
				EZReport.SetupList()
			else
				ResetNav()
				ListClick(activeItem, 1)
			end
		end
	end
	EZReportDropdown:SetHidden(false)
	EZReport_MainFrame_EmptyDrop:SetHidden(true)
	selectPrompt = 0
end

local function SelectionBox(option, choice) -- Popup message box offering confirmation of entry delete.
	local yText = EZReport_MainFrame_ListFrame_EditBox_PopUp_YText
	local nText = EZReport_MainFrame_ListFrame_EditBox_PopUp_NText
	local cText = (choice == 1) and L.EZReport_Confirm or L.EZReport_Cancel
	local bText = (choice == 1) and L.EZReport_Delete or L.EZReport_Cancel
	local cButton = (choice == 1) and yText or nText
	if option == 1 then
		cButton:SetText(pTC("ffffff",bText))
		InitializeTooltip(InformationTooltip, EZReport_MainFrame, TOPLEFT, 10, -8, TOPRIGHT)
		SetTooltipText(InformationTooltip, cText)
	elseif option == 2 then
		cButton:SetText(pTC("808080",bText))
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		if choice == 1 then
			EZReport_MainFrame_EmptyDrop:SetHidden(false)
			ConfirmSelection()
		else
			EZReportDropdown:SetHidden(false)
			EZReport_MainFrame_EmptyDrop:SetHidden(true)
			selectPrompt = 0
		end
		EZReport_MainFrame_ListFrame_EditBox_PopUp:SetHidden(true)
		EZReport_MainFrame_ListFrame_Delete:SetHidden(true)
		selectControl:SetAlpha(1)
	end
end

local function EditButtons(control, button, option) -- Show db entry delete button/tooltip.
	local dButton = EZReport_MainFrame_ListFrame_Delete
	if option == 1 then
		if selectPrompt == 0 then
			local nl = "\n"
			local c1 = "|cffff00"
			local cc = "|r"
			local t1 = L.EZReport_TTCEntry1
			local t2 = L.EZReport_TTCEntry2
			local t3 = L.EZReport_TTAEntry1
			local t4 = L.EZReport_TTAEntry2
			local t5 = L.EZReport_TTDEntry1
			local t6 = L.EZReport_TTDEntry2
			local text = c1..t1..cc..t2..nl..c1..t3..cc..t4..nl..c1..t5..cc..t6
			InitializeTooltip(InformationTooltip, EZReport_MainFrame, TOPLEFT, 10, -8, TOPRIGHT)
			SetTooltipText(InformationTooltip, text)
			dButton:ClearAnchors()
			dButton:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
			dButton:SetHidden(false)
			control:SetAlpha(.5)
		end
	elseif option == 2 then
		if selectPrompt == 0 then
			ClearTooltip(InformationTooltip)
			dButton:SetHidden(true)
			control:SetAlpha(1)
		end
	elseif option == 3 then
		if selectPrompt == 0 then
			local list = control:GetParent()
			local aText = editList[list.index].acc
			local cText = editList[list.index].char
			ClearTooltip(InformationTooltip)
			dButton:SetHidden(true)
			if button == 1 then
				control:SetAlpha(1)
				if IsShiftKeyDown() == true then
					EZReport.ASV.sVars.nMode = 0
					optionDrop.dropdown:SetSelectedItem(Options[0])
					EZReport.SetupList()
					ListClick(aText)
				elseif IsShiftKeyDown() == false then
					EZReport.ASV.sVars.nMode = 1
					optionDrop.dropdown:SetSelectedItem(Options[1])
					EZReport.SetupList()
					ListClick(cText)
				end
			elseif button == 2 then
				selectPrompt = 1
				selectControl = control
				EZReportDropdown:SetHidden(true)
				EZReport_MainFrame_EmptyDrop:SetHidden(false)
				EZReport_MainFrame_ListFrame_EditBox_PopUp:SetHidden(false)
				EZReport_MainFrame_ListFrame_EditBox_PopUp_MessageText:SetText(L.EZReport_Confirm..":")
				EZReport_MainFrame_ListFrame_EditBox_PopUp_YText:SetText(L.EZReport_Delete)
				EZReport_MainFrame_ListFrame_EditBox_PopUp_NText:SetText(L.EZReport_Cancel)
			end
		end
	end
end

local function NavigateScrollList() -- Populate list based on display setting.
	ZO_ScrollList_Clear(EZReport_MainFrame_ListFrame_List)
	local datalist = ZO_ScrollList_GetDataList(EZReport_MainFrame_ListFrame_List)
	for k,v in pairs(datalist) do datalist[k] = nil end

	for i = 1, #nameList do
		local name = nameList[i]
		datalist[i] = ZO_ScrollList_CreateDataEntry( 1, 
		{
			ReportName = pTC("ffff00",name),
		}
		)
		ZO_ScrollList_Commit(EZReport_MainFrame_ListFrame_List, datalist)
	end
end

------------------------------------------------------------------------------------------------------------------------------------
-- Global functions
------------------------------------------------------------------------------------------------------------------------------------
function EZReport.ShowMain() -- Open the main addon GUI.
	local control = GetControl('EZReport_MainFrame')
	if ( control:IsHidden() ) then
		SCENE_MANAGER:ToggleTopLevel(EZReport_MainFrame)
		RestorePosition()
		EZReport.SetupList()
		NavigateScrollList()
	else
		SCENE_MANAGER:ToggleTopLevel(EZReport_MainFrame)
	end
end

function EZReport.SetupList() -- Initialize active list.
	EZReport_MainFrame_Title:SetText(pTC("ffffff","EZ")..pTC("66ccff","REPORT"))
	EZReport_MainFrame_Title:ClearAnchors()
	EZReport_MainFrame_Title:SetAnchor(LEFT, EZReportDropdown, RIGHT, 4, -6)
	EZReport_MainFrame_ListFrame_TextBox:SetText("")

	ZO_ScrollList_Clear(EZReport_MainFrame_ListFrame_List)
	local datalist = ZO_ScrollList_GetDataList(EZReport_MainFrame_ListFrame_List)
	for k,v in pairs(datalist) do datalist[k] = nil end
	ZO_ScrollList_Commit(EZReport_MainFrame_ListFrame_List, datalist)

	local svar = EZReport.ASV.sVars.nMode
	for k,v in pairs(nameList) do nameList[k] = nil end
	local sortList = {}

	if svar == 0 then
		for aName, _ in pairs(EZReport.ASV.accountDB) do
			if not sortList[aName] then sortList[aName] = true end
		end
	elseif svar == 1 then
		for aName, _ in pairs(EZReport.ASV.accountDB) do
			for name, _ in pairs(EZReport.ASV.accountDB[aName].names) do
				if not sortList[name] then sortList[name] = true end
			end
		end
		for name, _ in pairs(EZReport.ASV.characterDB) do
			if not sortList[name] then sortList[name] = true end
		end
	elseif svar == 2 then
		for aName, _ in pairs(EZReport.ASV.accountDB) do
			for name, _ in pairs(EZReport.ASV.accountDB[aName].names) do
				for dt, _ in pairs(EZReport.ASV.accountDB[aName].names[name]) do
					local loc = EZReport.ASV.accountDB[aName].names[name][dt].rZone
					if not sortList[loc] then sortList[loc] = true end
				end
			end
		end
		for name, _ in pairs(EZReport.ASV.characterDB) do
			for dt, _ in pairs(EZReport.ASV.characterDB[name]) do
				local loc = EZReport.ASV.characterDB[name][dt].rZone
				if not sortList[loc] then sortList[loc] = true end
			end
		end
	end
	nameList = GetSortedNames(sortList)
	NavigateScrollList()
end

function EZReport.SetupCharacterDropbox() -- Initialize dropbox selection.
	local sVar = EZReport.ASV.sVars.nMode
	local optName = Options[sVar]

	if EZReport.ASV.sVars.rMode == 0 then
		EZReport_MainFrame_ListFrame_TextBox:SetHidden(false)
		EZReport_MainFrame_ListFrame_EditBox:SetHidden(true)
	else
		EZReport_MainFrame_ListFrame_TextBox:SetHidden(true)
		EZReport_MainFrame_ListFrame_EditBox:SetHidden(false)
	end

	optionDrop = WINDOW_MANAGER:CreateControlFromVirtual('EZReportDropdown', EZReport_MainFrame, 'ZO_StatsDropdownRow')
	optionDrop:SetWidth(275)
	optionDrop:SetAnchor(TOPLEFT, EZReport_MainFrame, TOPLEFT, -7, -2)
	optionDrop:GetNamedChild('Dropdown'):SetWidth(270)
	optionDrop.dropdown:SetSelectedItem(optName)

	for k,v in pairs(Options) do
		local entry = optionDrop.dropdown:CreateItemEntry(v, OptionSelected)
		optionDrop.dropdown:AddItem(entry)
	end
	EZReport.SetupList()
end

------------------------------------------------------------------------------------------------------------------------------------
-- Handle function calls from XML.
------------------------------------------------------------------------------------------------------------------------------------
function EZReport.XMLNavigation(option, control, text, n1, n2) -- Handles calls from XML.
	if option == 001 then
		ListTooltips(control, n1)
	elseif option == 002 then
		ListClick(text)
	elseif option == 003 then
		EditButtons(control, n1, n2)
	elseif option == 004 then
		SelectionBox(n1, n2)
	elseif option == 101 then
		OnMoveStop()
	elseif option == 102 then
		InitMain()
	elseif option == 103 then
		CloseMain(control, n1)
	elseif option == 104 then
		SwapMode(control, n1)
	end
end
