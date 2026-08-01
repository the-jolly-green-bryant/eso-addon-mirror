local cspsAG = nil 
local cspsDR = nil 
local cspsWW = nil 
local currentGroup = 1
local groupSlotControls = {}
local GS = GetString
local cspsPost = CSPS.post
local cspsD = CSPS.cspsD
local hf = CSPS.helperFunctions
local myGroupRole = 1
local triggerTypes = {
	DR = 1, AG = 2, LOC = 3, WW = 4,
}
local cp = CSPS.cp

local accountWideMode = true -- will be set to false on initConnect
local modeIcons = {[true] = "esoui/art/inventory/inventory_currencytab_accountwide_up.dds", [false] = "esoui/art/inventory/inventory_currencytab_oncharacter_up.dds"}

local triggerAddingFunctions = {}


local triggers = {
	DR = {},
	DRbyRole = {},
	AG = {},
	LOC = {},
	WW = {},
}

local bindingNames = {}
local isZoneType = {}
local colTbl = CSPS.colors

local function findTriggerByParameters(accountWide, triggerParams, includeCurrentGroup)
	local bindings = accountWide and CSPS.bindingsA or CSPS.bindings
	for groupIndex, groupBindings in pairs(bindings) do
		for triggerIndex, triggerData in pairs(groupBindings) do
			if (groupIndex ~= currentGroup or includeCurrentGroup) and hf.tableParamsFit(triggerData, triggerParams, {2,3,4,5}) then return accountWide and groupIndex.."-a" or groupIndex, triggerIndex end
		end
	end
	return false
end

local function refreshTriggers()
	
	triggers.AG = {}
	triggers.DR = {}
	triggers.DRbyRole = {}
	triggers.LOC = {}
	triggers.WW = {}
	
	local bindingTables = {[true] = CSPS.bindingsA, [false] = CSPS.bindings}
	
	for accountWide, bindings in pairs(bindingTables) do
		for groupIndex, groupBindings in pairs(bindings) do 
			local groupIndex = accountWide and groupIndex.."-a" or groupIndex
			for _, triggerData in pairs(groupBindings) do
				local triggerName, triggerType, triggerGroup, triggerSet, triggerFilter = unpack(triggerData)
				if triggerType == triggerTypes.DR then 
					if triggerFilter then -- groupRole
						triggers.DRbyRole[triggerGroup] = triggers.DRbyRole[triggerGroup] or {}
						triggers.DRbyRole[triggerGroup][triggerSet] = triggers.DRbyRole[triggerGroup][triggerSet] or {}
						triggers.DRbyRole[triggerGroup][triggerSet][triggerFilter] = groupIndex
					else
						triggers.DR[triggerGroup] = triggers.DR[triggerGroup] or {}
						triggers.DR[triggerGroup][triggerSet] = groupIndex
					end
				elseif triggerType == triggerTypes.AG then
					triggers.AG[triggerGroup] = triggers.AG[triggerGroup] or {}
					triggers.AG[triggerGroup][triggerSet] = groupIndex
				elseif triggerType == triggerTypes.LOC then
					triggers.LOC[triggerSet] = groupIndex
				elseif triggerType == triggerTypes.WW then
					triggers.WW[triggerGroup] = triggers.WW[triggerGroup] or {}
					triggers.WW[triggerGroup][triggerSet] = triggers.WW[triggerGroup][triggerSet] or {}
					triggers.WW[triggerGroup][triggerSet][triggerFilter] = groupIndex
				end
			end
		end
	end
end

function CSPS.groupBarInit(self, discipline)
	local dropdownControl = self:GetNamedChild("Profiles")
	if not dropdownControl then return end
	local dropdownBtnControl = dropdownControl:GetNamedChild("OpenDropdown")
	
	local disciplineNames = {
		GetChampionDisciplineName(1),
		GetChampionDisciplineName(2),
		GetChampionDisciplineName(3),
		GS(SI_COLLECTIONS_BOOK_QUICKSLOT_KEYBIND),
	}
	
	dropdownControl.comboBox = dropdownControl.comboBox or ZO_ComboBox_ObjectFromContainer(dropdownControl)
	dropdownControl.data = {tooltipText = string.format(GS(CSPS_Tooltip_SelectBarProfile), disciplineNames[discipline] or "...")}
	dropdownControl:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	dropdownControl:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	if not dropdownBtnControl then return end
	
	local textureParts = {
		"ESOUI/art/champion/champion_points_stamina_icon",
		"ESOUI/art/champion/champion_points_magicka_icon",
		"ESOUI/art/champion/champion_points_health_icon",
	}
	
	dropdownControl:SetHandler("OnMouseUp",
		function(_, mouseButton, upInside) 
			if not upInside then return end
			if mouseButton == 1 then 
				ZO_ComboBox_DropdownClicked(dropdownControl, MOUSE_BUTTON_INDEX_LEFT, true)
				PlaySound(SOUNDS.COMBO_CLICK)
			else
				CSPS.showSubProfileDiscipline(discipline) 
				CSPS.setSubProfileType(5)
			end
		end)
	
	dropdownBtnControl:SetHandler("OnClicked",
		function(_, mouseButton) 
			if mouseButton == 1 then 
				ZO_ComboBox_DropdownClicked(dropdownControl, MOUSE_BUTTON_INDEX_LEFT, true)
				PlaySound(SOUNDS.COMBO_CLICK)
			else
				CSPS.showSubProfileDiscipline(discipline) 
				CSPS.setSubProfileType(5)
			end
		end)
		
	if discipline < 4 then
		dropdownBtnControl:SetNormalTexture(string.format("%s.dds", textureParts[discipline]))
		dropdownBtnControl:SetMouseOverTexture(string.format("%s_active.dds", textureParts[discipline]))
		dropdownBtnControl:SetPressedTexture(string.format("%s-hud.dds", textureParts[discipline]))	 
	elseif discipline == 4 then
		--dropdownBtnControl:SetNormalTexture("ESOUI/art/menubar/gamepad/gp_playermenu_icon_collections.dds")
		--dropdownBtnControl:SetMouseOverTexture("ESOUI/art/menubar/gamepad/gp_playermenu_icon_collections.dds")
		--dropdownBtnControl:SetPressedTexture("ESOUI/art/menubar/gamepad/gp_playermenu_icon_collections.dds")
	end
end

function CSPS.groupSlotInit(control, myNumber)
	local myDiscipline = tonumber(string.sub(control:GetParent():GetName(), -1, -1))
	if not myDiscipline then return end
	groupSlotControls[myDiscipline] = groupSlotControls[myDiscipline] or {}
	groupSlotControls[myDiscipline][myNumber] = control
	local cpSlT = {
		"esoui/art/champion/actionbar/champion_bar_world_selection.dds",
		"esoui/art/champion/actionbar/champion_bar_combat_selection.dds",
		"esoui/art/champion/actionbar/champion_bar_conditioning_selection.dds",
		"esoui/art/champion/actionbar/champion_bar_slot_frame.dds",	-- use this for quickslots
	} 
	control.circle = control:GetNamedChild("Circle")
	control.circle:SetTexture(cpSlT[myDiscipline])
	if myDiscipline == 1 then 
		control.circle:SetColor(0.8235, 0.8235, 0)  -- re-color the not-so-green circle for the green cp...
	elseif myDiscipline == 4 then
		control.circle:SetColor(0.8,0,1)
	end	
	control.label = control:GetNamedChild("Label")
	control.icon = control:GetNamedChild("Icon")	
end

function CSPS.setBarManagerAccountMode(arg)
	if arg ~= nil then accountWideMode = arg else accountWideMode = not accountWideMode end
	CSPS.savedVariables.settings.barManagerAccountMode = accountWideMode
	
	local accountModeNames = {[true] = GS(SI_CURRENCYLOCATION3), [false] = GetUnitName("player")}
	
	CSPSWindowManageBarsAccCharLabel:SetText(accountModeNames[accountWideMode])
	
	local textureName = accountWideMode and "inventory_currencytab_accountwide_" or "inventory_currencytab_oncharacter_"
	
	CSPSWindowManageBarsAccCharBtn:SetMouseOverTexture(string.format("esoui/art/inventory/%sover.dds", textureName))
	CSPSWindowManageBarsAccCharBtn:SetNormalTexture(string.format("esoui/art/inventory/%sup.dds", textureName))
	CSPSWindowManageBarsAccCharBtn:SetPressedTexture(string.format("esoui/art/inventory/%sdown.dds", textureName))
	
	ZO_Tooltips_HideTextTooltip()
	local ttText = string.format("%s: %s", GS(SI_DIALOG_COPY_HOUSING_PERMISSION_DEFAULT_CHOICE), accountModeNames[not accountWideMode])
	CSPSWindowManageBarsAccCharBtn:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(CSPSWindowManageBarsAccCharLabel, RIGHT, ttText) end)
	CSPSWindowManageBarsAccCharLabel:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(CSPSWindowManageBarsAccCharLabel, RIGHT, ttText) end)
	
	CSPS.barManagerRefreshGroup()
end

local function selectProfile(myDiscipline, myProfile)
	if not myDiscipline then return end
	if myProfile == -1 then myProfile = nil end
	
	local spHotkeys = accountWideMode and CSPS.spHotkeysA or CSPS.spHotkeysC 
	spHotkeys[currentGroup][myDiscipline] = myProfile
	CSPS.currentCharData.cp2hbpHotkeys = CSPS.spHotkeysC
	CSPS.savedVariables.cp2hbpHotkeys = CSPS.spHotkeysA
	CSPS.barManagerRefreshGroup()
end

function CSPS.updatePrCombo(myDiscipline)
	if not myDiscipline then return end
	local myControl = WINDOW_MANAGER:GetControlByName(string.format("CSPSWindowManageBarsDisc%sProfiles", myDiscipline))

	local myComboBox = myControl.comboBox
	myComboBox:ClearItems()
	
	local choices = {["0) - "] = -1}
	
	local spHotkeys = accountWideMode and CSPS.spHotkeysA or CSPS.spHotkeysC
	
	if myDiscipline ~= 4 then
		if not accountWideMode then
			for i, v in pairs(CSPS.currentCharData.cpHbProfiles or {}) do
				local myName = string.format("|t24:24:%s|t %s) %s", modeIcons[false], i, v.name)
				if v.discipline == myDiscipline then choices[myName] = i end
			end
		end
		
		for i, v in pairs(CSPS.savedVariables.cpHbProfiles or {}) do
			local myName = string.format("|t24:24:%s|t %s) %s", modeIcons[true], i, v.name)
			if v.discipline == myDiscipline then choices[myName] = i.."-a" end
		end
	else
		if not accountWideMode then
			for i, v in pairs(CSPS.currentCharData.qsProfiles or {}) do
				local myName = string.format("|t24:24:%s|t %s) %s", modeIcons[false], i, v.name)
				choices[myName] = i
			end
		end
		for i, v in pairs(CSPS.savedVariables.qsProfiles or {}) do
			local myName = string.format("|t24:24:%s|t %s) %s", modeIcons[true], i, v.name)
			choices[myName] = i.."-a"
		end
	end
	
	local function OnItemSelect(_, choiceText)
		local myProfile = choices[choiceText] or nil
		selectProfile(myDiscipline, myProfile)
		PlaySound(SOUNDS.POSITIVE_CLICK)
	end

	myComboBox:SetSortsItems(true)
	local spHotkeys = accountWideMode and CSPS.spHotkeysA or CSPS.spHotkeysC
	local currentProfile = spHotkeys[currentGroup][myDiscipline]
	
	for choiceText, choiceValue in pairs(choices) do
		myComboBox:AddItem(myComboBox:CreateItemEntry(choiceText, OnItemSelect))
		if currentProfile == choiceValue then
			myComboBox:SetSelectedItem(choiceText)
		end
	end
end

function CSPS.barManagerRefreshGroup()
	CSPS.cpKbList:RefreshData()	
	CSPSWindowManageBarsGroup:SetText(string.format(GS(CSPS_CPBar_GroupHeading), currentGroup, 20))
	local myKeyText = CSPS.getHotkeyByGroup(currentGroup, accountWideMode)
	
	CSPSWindowManageBarsKeybind:SetText(string.format(GS(CSPS_CPBar_GroupKeybind), myKeyText))
	local spHotkeys = accountWideMode and CSPS.spHotkeysA or CSPS.spHotkeysC
	local myGroup = spHotkeys[currentGroup]
	CSPSWindowManageBarsMinus:SetHidden(not hf.anyEntryNotFalse(myGroup, true))
	local numSlots = {4, 4, 4, 8}
	for discipline=1, 4 do
		local profileId = myGroup[discipline] or false
		local myProfile, profileIsAccountWide = CSPS.getBindingProfileByDisciplineAndId(discipline, profileId)
		local ctrG = groupSlotControls[discipline]
		if myProfile then
			ctrG[1]:GetParent():GetNamedChild("Profiles").comboBox:SetSelectedItem(myProfile.name)
			if discipline < 4 then
				local myHb = {SplitString(",", myProfile["hbComp"])}
				for slotIndex=1,4 do
					local myCtr = ctrG[slotIndex]
					if myHb[slotIndex] ~= "-" then	
						local myId = tonumber(myHb[slotIndex])
						local skillData = cp.table[myId]
						if myId and skillData.icon then
							myCtr.icon:SetTexture(skillData.icon)
						else
							myCtr.icon:SetTexture("esoui/art/champion/champion_icon_32.dds")
						end
						myCtr.icon:SetHidden(false)
						myCtr.label:SetText(zo_strformat("<<C:1>>", GetChampionSkillName(myId)))
						myCtr.label:SetHandler("OnMouseEnter", function() CSPS.showCpTT(myCtr.label, skillData, nil, true) end)
						myCtr.label:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
					else
						myCtr.icon:SetHidden(true)
						myCtr.label:SetHandler("OnMouseEnter", function() end)
						myCtr.label:SetText("-")
						
					end
				end
			else
				local myQsProfile = CSPS.extractQS(myProfile.hbComp)
				local numCats = 0
				local hbWithEntries = 1
				for hbIndex, hbData in pairs(myQsProfile) do
					if type(hbData) == "table" and #hbData > 0 then
						numCats = numCats + 1
						hbWithEntries = hbIndex
					end
				end
				local entriesToShow = {}
				if numCats > 1 then
					for hbIndex, hbData in pairs(myQsProfile) do
						table.insert(entriesToShow,  
							{name = GS("SI_HOTBARCATEGORY", CSPS.qsBarCategories[hbIndex]),
							tooltipFunc = function(ttCtr) 
								InitializeTooltip(InformationTooltip, ttCtr, LEFT) 
								CSPS.addQsBarsToTooltip({[hbIndex] = myQsProfile[hbIndex]})
							end})
					end
				else
					for slotIndex, slotData in pairs(myQsProfile[hbWithEntries]) do
						local myIcon, listText, myName, subtitle, additionalDescription, name, nameColor = CSPS.qsActionInfo(slotData)
						table.insert(entriesToShow,  
							{name = nameColor:Colorize(name),
							icon = myIcon,
							tooltipFunc = function(ttCtr) 
								if name == "" then return end
								InitializeTooltip(InformationTooltip, ttCtr, LEFT)
								local r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
								InformationTooltip:AddLine(zo_strformat("|t28:28:<<1>>|t <<C:2>>", myIcon , myName), "ZoFontWinH2", r, g, b)
								--, r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
								--ZO_Tooltip_AddDivider(InformationTooltip)
								if subtitle then InformationTooltip:AddLine(subtitle, "ZoFontGame", r, g, b) end 
								if additionalDescription and #additionalDescription > 0 then
									ZO_Tooltip_AddDivider(InformationTooltip)
									for i, v in pairs(additionalDescription) do
										InformationTooltip:AddLine(v, "ZoFontGame", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
									end
								end
							end})
					end
				end
				for slotIndex=1,8 do
					
					local myCtr = ctrG[slotIndex]
					
					if entriesToShow[slotIndex] then
						myCtr.circle:SetHidden(false)
						myCtr.icon:SetHidden(not entriesToShow[slotIndex].icon)
						myCtr.icon:SetTexture(entriesToShow[slotIndex].icon)
						myCtr.label:SetText(entriesToShow[slotIndex].name)
						myCtr.label:SetHandler("OnMouseEnter", function() entriesToShow[slotIndex].tooltipFunc(myCtr.label) end)
						myCtr.label:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
					else
						myCtr.icon:SetHidden(true)
						myCtr.circle:SetHidden(numCats > 1)
						myCtr.label:SetHandler("OnMouseEnter", function() end)
						myCtr.label:SetText(numCats == 1 and "-" or "")
						
					end
				end	
			end
		else
			ctrG[1]:GetParent():GetNamedChild("Profiles").comboBox:SetSelectedItem("")
			for slotIndex=1,numSlots[discipline] do
				ctrG[slotIndex].circle:SetHidden(false)
				ctrG[slotIndex].icon:SetHidden(true)
				ctrG[slotIndex].label:SetHandler("OnMouseEnter", function() end)
				ctrG[slotIndex].label:SetText("-")
				
			end
		end	
	end
	CSPS.barManagerShowSpecialDisc(not accountWideMode)
end

function CSPS.emptyCurrentGroup()
	local spHotkeys = accountWideMode and CSPS.spHotkeysA or CSPS.spHotkeysC 
	spHotkeys[currentGroup] = {}
	CSPS.barManagerRefreshGroup()
end

function CSPS.prevGroup()
	currentGroup = currentGroup - 1
	currentGroup = currentGroup > 0 and currentGroup or 20
	CSPS.barManagerRefreshGroup()
end

function CSPS.nextGroup()
	currentGroup = currentGroup + 1
	currentGroup = currentGroup < 21 and currentGroup or 1
	CSPS.barManagerRefreshGroup()
end


function CSPS.groupShortkeyUp(myGroupId)
	zo_callLater(function() -- we need a short delay for the Shift/Control/Alt functions to work properly after KeyUpEvent
		local hasAccountWide = hf.anyEntryNotFalse(CSPS.spHotkeysA[myGroupId])
		local hasCharBased = hf.anyEntryNotFalse(CSPS.spHotkeysC[myGroupId])
		if not hasAccountWide and not hasCharBased then cspsD("Nothing to load") return end
		local accountWide = not hasCharBased and hasAccountWide
		cspsD("Getting group id from shiftkey")
		cspsD("Accountwide by groupid: "..tostring(accountWide))
		local forceAccountwide = {[7] = IsShiftKeyDown,	[4] = IsControlKeyDown,	[5] = IsAltKeyDown, [0] = function() return false end,}
		if forceAccountwide[CSPS.savedVariables.settings.accountWideShiftKey or 0]() then
			cspsD("Forcing accountwide...")
			accountWide = true
		end
		CSPS.groupApply(myGroupId, accountWide)
		end, 10)
end

function CSPS.loadAndApplyCpHotbars(compressedBars, doApply)
	local hotbarsOnly = {false, false, false}
	local needToApply = false
	local currentHotbar = {{},{},{}}
	
	for i=1, 12 do
		local mySk = GetSlotBoundId(i, HOTBAR_CATEGORY_CHAMPION)
		if mySk ~= nil and mySk ~= 0 then 
			currentHotbar[cp.table[mySk].discipline][mySk] = true 
		end
	end
	
	for discipline, hbComp in pairs(compressedBars) do
		hotbarsOnly[discipline] = true
		cp.bar[discipline] = cp.singleBarExtract(hbComp)
		local newHotbar = {}
		
		for _, skillData in pairs(cp.bar[discipline]) do
			newHotbar[skillData.id] = true
		end
		
		for slotIndex, skillData in pairs(cp.bar[discipline]) do
			if not WouldChampionSkillNodeBeUnlocked(skillData.id, GetNumPointsSpentOnChampionSkill(skillData.id)) then
				local foundAlternative = false
				for alternativeChampionSkillId, x in pairs(currentHotbar[discipline]) do
					if not newHotbar[alternativeChampionSkillId] then
						cp.bar[discipline][slotIndex] = cp.table[alternativeChampionSkillId]
						newHotbar[alternativeChampionSkillId] = true 
						foundAlternative = true
						break 
					end
				end
				if not foundAlternative then cp.bar[discipline][slotIndex] = nil end
			end
		end
		for _, skillData in pairs(cp.bar[discipline]) do -- only change if there are actually different skills (not if they just change position)
			if not currentHotbar[discipline][skillData.id] then 
				needToApply = true 
			end
		end
		cp.updateSidebarIcons(discipline)
	end
	
	cp.updateSlottedMarks()
	
	if needToApply and doApply then cp.applyConfirm(false, hotbarsOnly) else cspsPost(GS(CSPS_CPNoChanges)) end
	
	cp.recheckHotbar()
end


function CSPS.groupApply(myGroupId, accountWide)
	if not myGroupId then return end
	
	cspsPost(string.format(GS(CSPS_LoadingGroup), myGroupId, accountWide and GS(CSPS_AccountWide) or ""))
	
	local spHotkeys = accountWide and CSPS.spHotkeysA or CSPS.spHotkeysC
	local myGroup = spHotkeys[myGroupId]
	
	local buildProfile = myGroup[5]
	local excludeFromApplyAll = {}
		
	if buildProfile and (not buildProfile.profileIndex or buildProfile.profileIndex > 0 and not CSPS.profiles[buildProfile.profileIndex]) then 
		myGroup[5] = nil 
		buildProfile = nil 
	end
	
	if buildProfile then	
		for i, ii in pairs({1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 10}) do -- remap role and skillStyles = skills
			excludeFromApplyAll[i] = buildProfile[ii] or false
		end
		CSPS.selectProfile(buildProfile.profileIndex, true)
		
		CSPS.loadBuild()
	end
	
	local groupContainsProfiles = false
		
	local compressedBars = {}
	for i=1, 3 do
		if myGroup[i] ~= nil then			
			local myProfile = CSPS.getBindingProfileByDisciplineAndId(i, myGroup[i])
			if myProfile then
				local hbComp = myProfile["hbComp"]
				excludeFromApplyAll[i+2] = false
				compressedBars[i] = hbComp 
				groupContainsProfiles = true
			end
		end
	end
	
	if groupContainsProfiles then CSPS.loadAndApplyCpHotbars(compressedBars, not buildProfile) end
	
	local qsProfile = CSPS.getBindingProfileByDisciplineAndId(4, myGroup[4])
	if qsProfile then 
		excludeFromApplyAll[8] = false
		CSPS.extractQS(qsProfile.hbComp, CSPS.getQsBars())
		if not buildProfile then CSPS.applyQS(qsProfile.cat ~= 0 and qsProfile.cat) end
		groupContainsProfiles = true
	end
	
	if not buildProfile and not groupContainsProfiles then cspsPost( GS(CSPS_CPNoChanges)) return end
	
	if buildProfile then CSPS.applyAll(unpack(excludeFromApplyAll)) end
	
	CSPS.unsavedChanges = true
	CSPS.showElement("save", true)
	CSPS.refreshTree()

end

function CSPS.applyCurrentGroup()
	CSPS.groupApply(currentGroup, accountWideMode)
end


local function compareOldTrigger(oldEntry)
	local oldEntry, accountWide = CSPS.getCpHbId(oldEntry)
	if oldEntry == currentGroup and accountWide == accountWideMode then return true end
end

local function getWWZoneName()

end

local function getWWSetName()

end

triggerAddingFunctions[triggerTypes.WW] = function()

	if not (cspsWW and cspsWW.zones and cspsWW.pages and cspsWW.setups) then return end

	local function addIt(name, triggerGroup, triggerValue, triggerFilter)
		triggers.WW = triggers.WW or {}
		triggers.WW[triggerGroup] = triggers.WW[triggerGroup] or {}
		triggers.WW[triggerGroup][triggerValue] = triggers.WW[triggerGroup][triggerValue] or {}
		
		if compareOldTrigger(triggers.WW[triggerGroup][triggerValue][triggerFilter]) then return end
		
		local bindings = accountWideMode and CSPS.bindingsA or CSPS.bindings
		bindings[currentGroup] = bindings[currentGroup] or {}
		table.insert(bindings[currentGroup], {name, triggerTypes.WW, triggerGroup, triggerValue, triggerFilter})
		refreshTriggers()
		
		CSPS.cpKbList:RefreshData()	
	end

	ClearMenu()
	for zoneAbbr, zoneData in pairs(cspsWW.zones) do
		if zoneData.tag and cspsWW.pages[zoneData.tag] ~= nil then
			local zoneSubMenu = {}
			for pageId, pageData in pairs(cspsWW.pages[zoneData.tag]) do -- ipairs works. but deleted pages move all the ids...
				local pageName = pageData.name
				if pageName ~= nil and cspsWW.setups[zoneData.tag] and cspsWW.setups[zoneData.tag][pageId] then
					local pageSetups = cspsWW.setups[zoneData.tag][pageId]
					for setupId = 1, #pageSetups do -- same thing here
						--local setupId = preOrderingSetupId + 1
						--setupId = setupId <= #pageSetups and setupId or 1
						local setupData = pageSetups[setupId] 
						if setupData.name ~= nil then
							table.insert(zoneSubMenu, 
								{label = string.format("%s - %s", pageName, setupData.name),
								callback = function() addIt(string.format("%s: %s - %s", zoneAbbr, pageName, setupData.name), zoneAbbr, pageId, setupId) end})
						end
					end
				end
			end
			if #zoneSubMenu > 0 then
				AddCustomSubMenuItem(zoneAbbr, zoneSubMenu)
			end
		end
	end
	ShowMenu() 
end

triggerAddingFunctions[triggerTypes.LOC] = function()
	local function addIt(name, triggerGroup, triggerValue)
		
		triggers.LOC = triggers.LOC or {}
		
		if compareOldTrigger(triggers.LOC[triggerValue]) then return end
				
		local bindings = accountWideMode and CSPS.bindingsA or CSPS.bindings
		bindings[currentGroup] = bindings[currentGroup] or {}
		table.insert(bindings[currentGroup], {string.format("%s: %s", GS(CSPS_CPBar_Location), name), triggerTypes.LOC, triggerGroup, triggerValue})
		refreshTriggers()

		CSPS.cpKbList:RefreshData()	
	end

	ClearMenu()
	
	local subMenuLocTrial = {}
	for zoneName, zoneId in pairs((CSPS.getTrialArenaList())) do
		table.insert(subMenuLocTrial, {label = zoneName, callback = function() addIt(zoneName, 1, zoneId) end})
	end	
	AddCustomSubMenuItem(GS(CSPS_CPBar_LocTrial), subMenuLocTrial) --bindingGroup 1
		
	local zoneId = GetUnitWorldPosition("player")
	local myZoneName = zo_strformat("<<C:1>>", GetZoneNameById(zoneId))
	local subMenuLocCurrent = {{label = myZoneName, callback = function() addIt(myZoneName, 2, zoneId) end}}
	local parentZoneId = GetParentZoneId(zoneId)
	if parentZoneId ~= zoneId then
		table.insert(subMenuLocCurrent, {label = zo_strformat("<<C:1>>", GetZoneNameById(parentZoneId)), callback = function() addIt(parentZoneName, 2, parentZoneId) end})
	end	
	AddCustomSubMenuItem(GS(CSPS_CPBar_LocCurr), subMenuLocCurrent) --bindingGroup 2

	local subMenuLocationTypes = {}
	local locationTypes = {trial = SI_INSTANCETYPE3, dungeon = SI_INSTANCETYPE2, housing = SI_INSTANCEDISPLAYTYPE8, bg = SI_INSTANCEDISPLAYTYPE9}
		 -- toDo: solo-/group-arena
		 
	for typeId, typeNameId in pairs(locationTypes) do
		local typeName = zo_strformat("<<C:1>>", GS(typeNameId))
		table.insert(subMenuLocationTypes, {label = typeName, callback = function() addIt(typeName, 3, typeId) end})
	end
	
	AddCustomSubMenuItem(GS(CSPS_CPBar_LocType), subMenuLocationTypes)--bindingGroup 3

	ShowMenu() 
end

local function getDrPageName(pageIndex)
	if not cspsDR or not cspsDR.ram or not cspsDR.ram.page or not cspsDR.ram.page.name or not cspsDR.ram.page.name[pageIndex] then return false end	
	return string.format("%s) %s", pageIndex, cspsDR.ram.page.name[pageIndex] or "")
end

local function getDrSetName(pageIndex, pageData, setIndex, setData)
	if not cspsDR or not cspsDR.ram or not cspsDR.ram.page then return false end
	local pageName = getDrPageName(pageIndex, pageIndex)
	if not pageName then return false end
	if not pageData then pageData = cspsDR.ram.page.pages and cspsDR.ram.page.pages[pageIndex] end
	if not pageData then return false end
	setData = setData or pageData.gearSet and pageData.gearSet[setIndex]
	if not setData then return false end
	local setName = pageData.customSetName[setIndex]
	setName = setName or (pageData.gearSet[setIndex] and pageData.gearSet[setIndex].name)
	setName = setName or string.format("Set %s", setIndex)
	setName = string.format("%s) %s", setIndex, setName)
				
	return string.format("Dressing Room %s %s", pageName, setName), setName
end

triggerAddingFunctions[triggerTypes.DR] = function()

	if not (cspsDR and cspsDR.ram and cspsDR.ram.page and cspsDR.ram.page.pages) then return end
	
	local drUsesRoles = cspsDR ~= nil and cspsDR.roleSpecificPresets 
	local myGroupRole = drUsesRoles and cspsDR.currentGroupRole or cspsDR:GetGroupRoleFromLFGTool()
	
	local roleNames = {"dps", "tank", "healer"}
	
	local roleIcon = drUsesRoles and (roleNames[myGroupRole] and string.format("ESOUI/art/lfg/lfg_icon_%s.dds", roleNames[myGroupRole]) or "ESOUI/art/icons/icon_missing.dds")
		
	local function addIt(name, triggerGroup, triggerValue, triggerFilter)
		local tN = drUsesRoles and "DRbyRole" or "DR"
		triggers[tN][triggerGroup] = triggers[tN][triggerGroup] or {}
		local tGroupData = triggers[tN][triggerGroup]
		if drUsesRoles then tGroupData[triggerValue] = tGroupData[triggerValue] or {} end
		local oldEntry = drUsesRoles and tGroupData[triggerValue][myGroupRole] or not drUsesRoles and tGroupData[triggerValue]

		if compareOldTrigger(oldEntry) then return end
				
		local bindings = accountWideMode and CSPS.bindingsA or CSPS.bindings
		bindings[currentGroup] = bindings[currentGroup] or {}
		
		table.insert(bindings[currentGroup], {name, triggerTypes.DR, triggerGroup, triggerValue, triggerFilter})
		
		refreshTriggers()

		CSPS.cpKbList:RefreshData()	
	end

	ClearMenu()
	
	for pageIndex, pageData in pairs(cspsDR.ram.page.pages) do
		local pageName = getDrPageName(pageIndex)
		if pageName then
			local pageSubMenu = {}
			for setIndex = 1, cspsDR:numSets() do
				local longSetName, setName = getDrSetName(pageIndex, pageData, setIndex)
				table.insert(pageSubMenu, {
					label = setName, 
					callback = function() addIt(longSetName, pageIndex, setIndex, drUsesRoles and myGroupRole or nil) end,
				})
			end
			AddCustomSubMenuItem(drUsesRoles and string.format("|t24:24:%s|t %s", roleIcon, pageName) or pageName, pageSubMenu)
		end
	end
	ShowMenu() 

end

local function getAgProfileName(profileIndex, profileData)
	local profileData = profileData or cspsAG and cspsAG.setdata and cspsAG.setdata.profiles and cspsAG.setdata.profiles[profileIndex] 
	return profileData and string.format("%s) %s", profileIndex, profileData.name) or false
end

local function getAgSetName(profileIndex, profileData, setIndex, setData)
	local profileData = profileData or cspsAG and cspsAG.setdata and cspsAG.setdata.profiles and cspsAG.setdata.profiles[profileIndex] 
	if not profileData then return false end
	local profileName = getAgProfileName(profileIndex, profileData) or string.format("%s: ", profileIndex)
	local setData = setData or profileData.setdata and profileData.setdata[setIndex]
	local setName = setData and setData.Set and setData.Set.text and setData.Set.text[1] or 0
	setName = setName == 0 and string.format("%s) Build %s", setIndex, setIndex)  or string.format("%s) %s", setIndex, setName)
	
	return string.format("Alpha Gear - %s %s", profileName, setName), setName
end

triggerAddingFunctions[triggerTypes.AG] = function()
	if not (cspsAG and cspsAG.setdata and cspsAG.setdata.profiles) then return end

	local function addIt(name, triggerGroup, triggerValue)
		triggers.AG = triggers.AG or {}
		triggers.AG[triggerGroup] = triggers.AG[triggerGroup] or {}
		if compareOldTrigger(triggers.AG[triggerGroup][triggerValue]) then return end
		
		local bindings = accountWideMode and CSPS.bindingsA or CSPS.bindings
		bindings[currentGroup] = bindings[currentGroup] or {}
		table.insert(bindings[currentGroup], {name, triggerTypes.AG, triggerGroup, triggerValue})
		refreshTriggers()
		CSPS.cpKbList:RefreshData()	
	end

	ClearMenu()
	for profileIndex, profileData in pairs(cspsAG.setdata.profiles) do
		local profileName = getAgProfileName(profileIndex, profileData)
		if profileData.setdata ~= nil then
			local profileSubMenu = {}
			for setIndex, setData in pairs(profileData.setdata) do
				if type(setIndex) == "number" then
					local longSetName, setName = getAgSetName(profileIndex, profileData, setIndex, setData)
					table.insert(profileSubMenu, {label = setName, callback = function() addIt(longSetName, profileIndex, setIndex) end})
				end
			end
			AddCustomSubMenuItem(profileName, profileSubMenu)
		end
	end
	ShowMenu() 
			
end

-- Bindinglist 

CSPSbindingsList = ZO_SortFilterList:Subclass()

local CSPSbindingsList = CSPSbindingsList

function CSPSbindingsList:New( control )
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control
	list:Setup()
	return list
end

function CSPSbindingsList:SetupItemRow( control, data )
	control.data = data
	local ctrName = control:GetNamedChild("Name")
	ctrName.normalColor = ZO_DEFAULT_TEXT
	ctrName.selectedColor = ZO_SELECTED_TEXT
	
	local myName = data.name

	if data.role ~= nil then	
		local roleNames = {"dps", "tank", "healer"}
		local myTexture = string.format("|t28:28:esoui/art/lfg/lfg_icon_%s.dds|t", roleNames[data.role])
		myName = string.format("%s %s", myTexture, myName)
	end
	ctrName:SetText(myName)
	control:GetNamedChild("Minus"):SetHandler("OnClicked", function(_, mouseButton) CSPS.kbRemove(data.myIndex) end)

	local overwrittenBy = false
	
	if accountWideMode then overwrittenBy = findTriggerByParameters(false, {false, data.triggerType, data.triggerGroup, data.triggerValue, data.triggerFilter}, true) end
	local conflictGroup, conflictTriggerIndex = findTriggerByParameters(accountWideMode, {false, data.triggerType, data.triggerGroup, data.triggerValue, data.triggerFilter}, false)
	
	overwrittenBy = overwrittenBy and CSPS.getCpHbId(overwrittenBy)
	
	control.rightClickFunction = false
	
	if overwrittenBy or conflictGroup then
		ctrName:SetHandler("OnMouseEnter", 
			function() 
				local tooltip = {}
				if overwrittenBy then table.insert(tooltip, string.format(GS(CSPS_Binding_Overwritten), overwrittenBy, GetUnitName("player"))) end
				if conflictGroup then table.insert(tooltip, string.format(GS(CSPS_Binding_Conflict), conflictGroup)) end
				ZO_Tooltips_ShowTextTooltip(ctrName, TOP, table.concat(tooltip, "\n"))
				CSPS.KBListRowMouseEnter(control)
			end)
		if conflictGroup then control.rightClickFunction = function() CSPS.kbRemove(conflictTriggerIndex, conflictGroup) end end
		ctrName:SetHandler("OnMouseUp", function(_, mouseButton, upInside) CSPS.KBListRowMouseUp(control, mouseButton, upInside) end)
		ctrName:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() CSPS.KBListRowMouseExit(control) end)	
		ctrName.normalColor = conflictGroup and ZO_ERROR_COLOR or ZO_ORANGE
		ctrName.selectedColor = conflictGroup and ZO_ERROR_COLOR or ZO_ORANGE
	end
	ctrName:SetMouseEnabled(overwrittenBy ~= false or conflictGroup ~= false)
	
	ZO_SortFilterList.SetupRow(self, control, data)
end

function CSPSbindingsList:Setup( )
	ZO_ScrollList_AddDataType(self.list, 1, "CSPSCPKBLE", 30, function(control, data) self:SetupItemRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)
	self.masterList = { }
	
	local sortKeys = {
		["name"]     = { caseInsensitive = true },
	}
	self.currentSortKey = "name"
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortFunction = function( listEntry1, listEntry2 )
		return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder)
	end
	
	self:RefreshData()
end

function CSPSbindingsList:BuildMasterList( )
	self.masterList = { }
	
	local bindings = accountWideMode and CSPS.bindingsA or CSPS.bindings
	local myBindingList = bindings[currentGroup] or {}
	for i,v in pairs(myBindingList) do
		if v[2] == triggerTypes.DR then
			v[1] = getDrSetName(v[3], nil, v[4]) or v[1]
		elseif v[2] == triggerTypes.AG then
			v[1] = getAgSetName(v[3], nil, v[4]) or v[1]
		elseif v[1] == triggerTypes.WW then
			v[1] = getWWSetName() or v[1]
		end
		table.insert(self.masterList, {name = v[1], myIndex = i, triggerType=v[2], triggerGroup=v[3], triggerValue=v[4], triggerFilter=v[5], role = v[2] == triggerTypes.DR and v[5] or nil })
	end
end

function CSPSbindingsList:FilterScrollList( )
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	for _, data in ipairs(self.masterList) do
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end

local function HookDR(mySetId)
	
	if not (cspsDR and cspsDR.ram and cspsDR.ram.page) then return end
	local drPageId = cspsDR.sv and cspsDR.sv.page and cspsDR.sv.page.current
	if not drPageId then return end
	local myKBGroup = false
	local drUsesRoles = cspsDR.roleSpecificPresets 
	if drUsesRoles then
		local myGroupRole = cspsDR.currentGroupRole or cspsDR:GetGroupRoleFromLFGTool()
		if not triggers.DRbyRole[drPageId] then return end
		if not triggers.DRbyRole[drPageId][mySetId] then return end
		myKBGroup = triggers.DRbyRole[drPageId][mySetId][myGroupRole] or nil
	else
		if not triggers.DR[drPageId] then return end
		myKBGroup = triggers.DR[drPageId][mySetId] or nil
	end
	local myKBGroup, accountWide = CSPS.getCpHbId(myKBGroup)
	if not myKBGroup then return end
	cspsPost(string.format("%s %s", GS(CSPS_CPLoadGroup), myKBGroup))
	 CSPS.groupApply(myKBGroup, accountWide)
end

local function checkWWSetup(setup, auto, callOnSuccess, callOnFail)
	cspsD("Checking WW Setup")
	if not CSPS.savedVariables.settings.checkWWSetup then return end
	if auto and not CSPS.savedVariables.settings.checkWWSetupAuto then return end
	callOnSuccess = callOnSuccess or function() end
	callOnFail = callOnFail or function() end
	local wwSkills = setup.skills
	if not wwSkills then callOnSuccess() return end
	local setupWorks = true
	local wwIndices, subclasses, classSkillLineInBuild, subclassIndices = {}, {}, {}, {}

	for hbIndex, hbData in pairs(setup.skills) do
		for slotIndex, abilityIdDirty in pairs(hbData) do
			local progression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId( abilityIdDirty )
			if progression then
				local skillType, skillLineIndex, skillIndex, morphSlot = progression:GetIndices()
				local skillLineId = GetSkillLineId(skillType, skillLineIndex)
				if skillType == 1 and not classSkillLineInBuild[skillLineId] then
					classSkillLineInBuild[skillLineId] = true
					table.insert(subclasses, skillLineId)
					table.insert(subclassIndices, skillLineIndex)
				end
				table.insert(wwIndices, {hbIndex=hbIndex, slotIndex=slotIndex, indices={skillType, skillLineIndex, skillIndex, morphSlot}})
				if not progression:GetSkillData():IsCraftedAbility() and (not progression:GetSkillData():IsPurchased() or progression:GetSkillData():GetCurrentMorphSlot() ~= morphSlot) then
					setupWorks = false
					if not progression:GetSkillData():IsPurchased() then
						cspsD(zo_strformat("Needs to purchase skill <<C:1>>.", progression:GetName()))
					else
						cspsD(zo_strformat("Needs to change skill <<C:1>> from morph <<2>> to morph <<3>>.", progression:GetName(), progression:GetSkillData():GetCurrentMorphSlot(), morphSlot))
					end
				
				end
			else
				cspsD("No progression data for "..GetAbilityName(abilityIdDirty))
			end
		end
	end
	if setupWorks then return end -- if everything can be slotted stop here
	cspsPost(GS(CSPS_WW_ADJUST))
	local canRespec, respecProblem = CSPS.canRespecFromUI()
	if not canRespec then cspsPost(respecProblem) return end
	local oldSkillTable, oldHb = false, false
	if #CSPS.skillTable ~= 0 then
		oldSkillTable = CSPS.compressLists()
		oldHb = CSPS.hbCompress(CSPS.hbTables)
	end
	CSPS.readCurrentSkills()
	CSPS.importSubclasses(subclasses)
	for i, v in pairs(wwIndices) do
		local skillType, skillLineIndex, skillIndex, morphSlot = unpack(v.indices)
		local skillData = CSPS.skillTable[skillType][skillLineIndex][skillIndex]
		if skillData then
			skillData.purchased = true
			skillData.morph = morphSlot
			skillData:setPoints()
			CSPS.hbTables[v.hbIndex + 1][v.slotIndex - 2] = {skillType, skillLineIndex, skillIndex}
		else
			cspsD("Could not find skill: "..skillType.."-"..skillLineIndex.."-"..skillIndex.."-"..morphSlot)
		end
	end
	if CSPS.savedVariables.settings.checkWWSetupPassives then
		for i, v in pairs(subclassIndices) do
			CSPS.plusClickSkillLine(1, v) --add passives for skill lines
		end
	end
	CSPS.hbLinkToSkills(CSPS.hbTables)
	local function redoTables()
		if not oldSkillTable then return end
		CSPS.tableExtract(oldSkillTable.prog, oldSkillTable.pass,  oldSkillTable.crafted, oldSkillTable.styles, oldSkillTable.subclasses, true, oldSkillTable.scribeStyleSubclass)
		CSPS.hbTables = CSPS.hbExtract(oldHb)
		CSPS.hbLinkToSkills(CSPS.hbTables)
		CSPS.hbPopulate()
		CSPS.refreshTree()
	end
	CSPS.applySkills(true, function() cspsD("Success. Applying Hotbar now.") CSPS.hbApply() redoTables() callOnSuccess() end, function() cspsD("Fail. Undoing tree changes in CSPS.") redoTables() callOnFail() end, true, false) -- second function call on fail
	
end

local function HookWW(zoneTag, pageId, setupId, auto)
	local setup = cspsWW and cspsWW.setups and cspsWW.setups[zoneTag] and cspsWW.setups[zoneTag][pageId] and cspsWW.setups[zoneTag][pageId][setupId]
	if not setup then return end
	local myKBGroup = triggers.WW[zoneTag] and triggers.WW[zoneTag][pageId] and triggers.WW[zoneTag][pageId][setupId]
	local myKBGroup, accountWide = CSPS.getCpHbId(myKBGroup)
	if not myKBGroup then checkWWSetup(setup, auto) return end
	cspsPost(string.format("%s %s", GS(CSPS_CPLoadGroup), myKBGroup))
	CSPS.groupApply(myKBGroup, accountWide)
end

local function HookAG(mySetId)
	local agProfileId = cspsAG.setdata and cspsAG.setdata.currentProfileId
	if not agProfileId then return end
	if not triggers.AG[agProfileId] then return end
	local myKBGroup = triggers.AG[agProfileId][mySetId]
	local myKBGroup, accountWide = CSPS.getCpHbId(myKBGroup)
	if not myKBGroup then return end
	cspsPost(string.format("%s %s", GS(CSPS_CPLoadGroup), myKBGroup))
	 CSPS.groupApply(myKBGroup, accountWide)
end

function CSPS.initConnect()

	cspsAG = AG and AG.name == "AlphaGear" and AG or nil
	cspsDR = DressingRoom and DressingRoom.ram and DressingRoom.ram.page and DressingRoom or nil
	cspsWW = WizardsWardrobe and WizardsWardrobe.name == "WizardsWardrobe" and WizardsWardrobe or nil
	-- WW.LoadSetup(zone, pageId, index, auto)

	local activeTriggerTypes = {
		cspsDR ~= nil and {"Dressing Room", "DR"}, 
		cspsAG ~= nil and {"Alpha Gear", "AG"}, 
		{GS(CSPS_CPBar_Location), GS(CSPS_CPBar_Location)},
		cspsWW ~= nil and {"Wizard's Wardrobe", "WW"},
	}	
		
	for triggerType, triggerData in pairs(activeTriggerTypes) do
		local btnPlus = CSPSWindowManageBars:GetNamedChild(string.format("AddBindType%sPlus", triggerType))
		local ctrLabel = CSPSWindowManageBars:GetNamedChild(string.format("AddBindType%sLabel", triggerType))
		btnPlus:SetHidden(not triggerData)
		ctrLabel:SetHidden(not triggerData)
		btnPlus:SetWidth(not triggerData and 0 or 25)
		ctrLabel:SetText(not triggerData and "" or triggerData[2])
		if triggerData then
			ctrLabel:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(ctrLabel, TOP, triggerData[1]) end)
			ctrLabel:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
			btnPlus:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(btnPlus, TOP, triggerData[1]) end)
			btnPlus:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
			ctrLabel:SetHandler("OnMouseUp", function(_, mouseButton, upInside) if mouseButton == 1 and upInside then triggerAddingFunctions[triggerType]() end end)
			btnPlus:SetHandler("OnClicked", function(_, mouseButton) triggerAddingFunctions[triggerType]() end)
			ctrLabel:SetMouseEnabled(true)
		end
	end
	
	CSPS.cpKbList = CSPSbindingsList:New(CSPSWindowManageBars)
	CSPS.cpKbList:FilterScrollList()
	CSPS.cpKbList:SortScrollList( )
		
	
	local disciplineNames = {GS(SI_CHARACTER_MENU_SKILLS), GS(SI_CHARACTER_MENU_STATS), false, false, false, -- don't apply the loop to the cp checkboxes
		GS(SI_INTERFACE_OPTIONS_ACTION_BAR), GS(SI_GAMEPAD_DYEING_EQUIPMENT_HEADER), GS(SI_HOTBARCATEGORY10), GetCollectibleCategoryNameByCategoryId(13), GS(SI_GROUP_LIST_PANEL_PREFERRED_ROLES_LABEL)}
	
	local cpDiscReroute = {[3] = 2, [4] = 3, [5] = 1}
	
	local allButtons = {}

	
	for i=1, 10 do
		local chkButton = CSPSWindowManageBarsDiscsSpecial:GetNamedChild("Include"..i)
		allButtons[i] = chkButton
		if disciplineNames[i] then -- = if not CP
			chkButton.setStateFunc = function(value) ZO_CheckButton_SetCheckState(chkButton, value and 1 or 0) end
			ZO_CheckButton_SetLabelText(chkButton, disciplineNames[i])
			chkButton.label:SetHeight(24)
			chkButton.label:SetWrapMode(1)
			ZO_CheckButton_SetTooltipText(chkButton, disciplineNames[i])
			ZO_CheckButton_SetToggleFunction(chkButton, function(_, value) 
				CSPS.spHotkeysC[currentGroup][5][i] = not value or nil
			end)
		else
			chkButton.setStateFunc = function(value) CSPS.barManagerSetCP(chkButton, i, true) end
		end
	end	
	-- top row: Include1, 6, 2, 9; downrow: (cp), 7,8,10
	
	allButtons[1].label:SetAnchor(RIGHT, allButtons[6], LEFT, -3, 0, ANCHOR_CONSTRAINS_X )
	allButtons[6].label:SetAnchor(RIGHT, allButtons[2], LEFT, -3, 0, ANCHOR_CONSTRAINS_X )
	allButtons[2].label:SetAnchor(RIGHT, allButtons[9], LEFT, -3, 0, ANCHOR_CONSTRAINS_X )
	allButtons[9].label:SetAnchor(RIGHT, CSPSWindowManageBarsDiscsSpecial, RIGHT, -3, 0, ANCHOR_CONSTRAINS_X )
	allButtons[7].label:SetAnchor(RIGHT, allButtons[8], LEFT, -3, 0, ANCHOR_CONSTRAINS_X )
	allButtons[8].label:SetAnchor(RIGHT, allButtons[10], LEFT, -3, 0, ANCHOR_CONSTRAINS_X )
	allButtons[10].label:SetAnchor(RIGHT, CSPSWindowManageBarsDiscsSpecial, RIGHT, -3, 0, ANCHOR_CONSTRAINS_X )
	
	CSPS.setBarManagerAccountMode(CSPS.savedVariables.settings.barManagerAccountMode) -- includes refreshGroups
	
	for i=1, 4 do
		CSPS.updatePrCombo(i)
	end
	
	_, _, isZoneType = CSPS.getTrialArenaList()

	refreshTriggers()
	
	if cspsAG ~= nil then
		ZO_PostHook(AG, "LoadSet", function(x1) HookAG(x1) end)
	end
	if cspsDR ~= nil then
		ZO_PostHook(DressingRoom, "LoadSet", function(_, x2) HookDR(x2) end)
	end
	if cspsWW ~= nil then
		local loadingCompleteSetup = false
		ZO_PostHook(WizardsWardrobe, "LoadSkills", function(setup) if not loadingCompleteSetup then checkWWSetup(setup) end end)
		ZO_PostHook(WizardsWardrobe, "LoadSetup", function(zone, pageId, setupId, auto) loadingCompleteSetup = true if not zone then return end HookWW(zone.tag, pageId, setupId, auto) zo_callLater(function() loadingCompleteSetup = false end, 420) end)
	end	
end

function CSPS.barManagerShowSpecialDisc(show)
	if not show then CSPSWindowManageBarsDiscsSpecial:SetHidden(true) return end
	CSPSWindowManageBarsDiscsSpecial:SetHidden(false)
	
	local profileIndex = CSPS.spHotkeysC[currentGroup] and CSPS.spHotkeysC[currentGroup][5] and CSPS.spHotkeysC[currentGroup][5].profileIndex
	if profileIndex and profileIndex > 0 and not CSPS.profiles[profileIndex] then profileIndex = nil CSPS.spHotkeysC[currentGroup][5] = nil end
	
	local dropdownControl = CSPSWindowManageBarsDiscsSpecial:GetNamedChild("BuildProfile")

	dropdownControl.comboBox = dropdownControl.comboBox or ZO_ComboBox_ObjectFromContainer(dropdownControl)
	dropdownControl.data = {tooltipText = ""}
	dropdownControl:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	dropdownControl:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	local comboBox = dropdownControl.comboBox
	comboBox:ClearItems()
	comboBox:SetSortsItems(true)
	
	local function OnItemSelect(choiceIndex)
		if choiceIndex then
			CSPS.spHotkeysC[currentGroup] = CSPS.spHotkeysC[currentGroup] or {}
			CSPS.spHotkeysC[currentGroup][5] = CSPS.spHotkeysC[currentGroup][5] or {}
			CSPS.spHotkeysC[currentGroup][5].profileIndex = choiceIndex
		elseif CSPS.spHotkeysC[currentGroup] then 
			CSPS.spHotkeysC[currentGroup][5] = nil
		end
		CSPS.barManagerShowSpecialDisc(true)
		PlaySound(SOUNDS.POSITIVE_CLICK)
	end
	
	
	comboBox:AddItem(comboBox:CreateItemEntry("-", function() OnItemSelect(false) end))
	comboBox:AddItem(comboBox:CreateItemEntry(GS(CSPS_Txt_StandardProfile), function() OnItemSelect(0) end))
	
	for i, v in pairs(CSPS.profiles) do
		comboBox:AddItem(comboBox:CreateItemEntry(v.name, function() OnItemSelect(i) end))
	end
	
	if profileIndex then
		-- 1 skills, 2 stats, 3-5 cp, 6 actin bar, 7 gear, 8 quickslots, 9 outfits, 10 roles
		local checkExcludeModules = {"skills", "attr", "cp", "cp", "cp", "skills", "gear", "qs", "outfit", "role"}
		comboBox:SetSelectedItem(profileIndex > 0 and CSPS.profiles[profileIndex].name or GS(CSPS_Txt_StandardProfile))
		for i,v in pairs(checkExcludeModules) do
			local chkButton = CSPSWindowManageBarsDiscsSpecial:GetNamedChild("Include"..i)
			chkButton:SetHidden(CSPS.moduleExclude[v])
			chkButton.setStateFunc(not CSPS.spHotkeysC[currentGroup] or not CSPS.spHotkeysC[currentGroup][5] or not CSPS.spHotkeysC[currentGroup][5][i])
		end	
		CSPSWindowManageBarsDiscsSpecialIncludeCPLabel:SetHidden(false)
	else
		comboBox:SetSelectedItem("-")
		for i=1, 10 do
			CSPSWindowManageBarsDiscsSpecial:GetNamedChild("Include"..i):SetHidden(true)
		end
		CSPSWindowManageBarsDiscsSpecialIncludeCPLabel:SetHidden(true)
	end	
end

function CSPS.barManagerSetCP(ctrButton, includeIndex, keepValue)
	CSPSWindowManageBarsDiscsSpecial:GetNamedChild("Include"..(includeIndex))
	CSPS.spHotkeysC[currentGroup]  = CSPS.spHotkeysC[currentGroup] or {}
	CSPS.spHotkeysC[currentGroup][5]  = CSPS.spHotkeysC[currentGroup][5] or {}
	local value = CSPS.spHotkeysC[currentGroup][5][includeIndex] == nil
	if not keepValue then
		value = not value
		CSPS.spHotkeysC[currentGroup][5][includeIndex] = not value or nil
	end
	CSPS.toggleChkTexture(ctrButton, value)
end

function CSPS.kbRemove(myIndex, groupIndex)
	groupIndex = groupIndex or currentGroup
	groupIndex = CSPS.getCpHbId(groupIndex)
	local bindings = accountWideMode and CSPS.bindingsA or CSPS.bindings
	bindings[groupIndex][myIndex] = nil
	refreshTriggers()
	CSPS.cpKbList:RefreshData()	
end

function CSPS.KBListRowMouseUp(self, button, upInside)
	if button == 2 and self.rightClickFunction then self.rightClickFunction() return end 
end

function CSPS.KBListRowMouseExit( control )
	CSPS.cpKbList:Row_OnMouseExit(control)
	ZO_Tooltips_HideTextTooltip()
end

function CSPS.KBListRowMouseEnter(control)
	CSPS.cpKbList:Row_OnMouseEnter(control)
end

function CSPS.locationBinding(zoneId)
	if triggers.LOC[zoneId] then
		local myKBGroup, accountWide = CSPS.getCpHbId(triggers.LOC[zoneId])
		zo_callLater(function() CSPS.groupApply( myKBGroup, accountWide) end, 500) 
		return true
	else
		local zoneCat = ""
		if IsUnitInDungeon("player")  then
			if GetCurrentZoneDungeonDifficulty() ~= 0 then
				if isZoneType.trial[zoneId] ~= nil then 
					zoneCat = "trial"
				elseif isZoneType.solo[zoneId] ~= nil then 
					zoneCat = "arena1"
				elseif isZoneType.arena[zoneId] ~= nil then
					zoneCat = "arena4"
				else
					zoneCat = "dungeon"
				end
			end
		elseif GetCurrentZoneHouseId() ~= 0 then
			zoneCat = "housing"
		elseif GetCurrentBattlegroundId() ~= 0 then
			zoneCat = "bg"
		end
		if zoneCat ~= "" then
			if triggers.LOC[zoneCat] then
				local myKBGroup, accountWide = CSPS.getCpHbId(triggers.LOC[zoneCat])
				zo_callLater(function() CSPS.groupApply( myKBGroup, accountWide) end, 500) 
				return true
			end
		end
		return false
	end
end