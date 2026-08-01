local GS = GetString
local cpColors = CSPS.cpColors
local hf = CSPS.helperFunctions
local cspsPost = CSPS.post
local cspsD = CSPS.cspsD
local cp = CSPS.cp

local lastZoneName = ""

local qsCooldown = false

local roles = {"DD", GS(CSPS_CPP_Tank), "", GS(SI_LFGROLE4), "DD(Mag)", "DD(Stam)", GS(SI_GEMIFIABLEFILTERTYPE0)}

local PROFILE_TYPE_BUILD = 0
local PROFILE_TYPE_CP_ACCOUNT, PROFILE_TYPE_CP_CHAR, PROFILE_TYPE_CP_IMPORT, PROFILE_TYPE_CP_PRESET, PROFILE_TYPE_CP_HOTBARS = 1, 2, 3, 4, 5
local PROFILE_TYPE_QS_ACCOUNT, PROFILE_TYPE_QS_CHAR, PROFILE_TYPE_SK_ACCOUNT, PROFILE_TYPE_SK_CHAR = 6, 7, 8, 9
local PROFILE_TYPE_GEAR_ACCOUNT, PROFILE_TYPE_GEAR_CHAR = 10, 11
local PROFILE_TYPE_CP_HOTBARS_ACCOUNT = 12 -- only a placeholder...
local PROFILE_TYPE_OUTFIT_ACCOUNT, PROFILE_TYPE_OUTFIT_CHAR = 13, 14
local PROFILE_TYPE_MAX = 14

local PROFILE_CATEGORY_CP, PROFILE_CATEGORY_QS, PROFILE_CATEGORY_SK, PROFILE_CATEGORY_GEAR, PROFILE_CATEGORY_OUTFIT = 1, 2, 3, 4, 5
local PROFILE_DISCIPLINE_CP_GREEN, PROFILE_DISCIPLINE_CP_BLUE, PROFILE_DISCIPLINE_CP_RED, PROFILE_DISCIPLINE_QUICKSLOTS, PROFILE_DISCIPLINE_SKILLS, PROFILE_DISCIPLINE_GEAR, PROFILE_DISCIPLINE_OUTFIT = 1,2,3,4,5,6,7

local firstTypeOfCategory = { -- is used to tranfer 1/2 to other categories
	[PROFILE_CATEGORY_CP] = PROFILE_TYPE_CP_ACCOUNT,
	[PROFILE_CATEGORY_QS] = PROFILE_TYPE_QS_ACCOUNT,
	[PROFILE_CATEGORY_SK] = PROFILE_TYPE_SK_ACCOUNT,
	[PROFILE_CATEGORY_GEAR] = PROFILE_TYPE_GEAR_ACCOUNT,
	[PROFILE_CATEGORY_OUTFIT] = PROFILE_TYPE_OUTFIT_ACCOUNT,
}

local nonCustomTypes = {
	[PROFILE_TYPE_CP_IMPORT] = true,
	[PROFILE_TYPE_CP_PRESET] = true,
}

local typesWithKeybinds = {
	[PROFILE_TYPE_CP_HOTBARS] = true,
	[PROFILE_TYPE_CP_HOTBARS_ACCOUNT] = true,	
	[PROFILE_TYPE_QS_ACCOUNT] = true,
	[PROFILE_TYPE_QS_CHAR] = true,
}

local cpHotBarProfileTypes = {[PROFILE_TYPE_CP_HOTBARS] = true, [PROFILE_TYPE_CP_HOTBARS_ACCOUNT] = true}

local accountWideProfileTypes = 
	{[PROFILE_TYPE_CP_ACCOUNT] = true, 
	[PROFILE_TYPE_GEAR_ACCOUNT] = true,
	[PROFILE_TYPE_CP_HOTBARS_ACCOUNT] = true,
	[PROFILE_TYPE_OUTFIT_ACCOUNT] = true,
	[PROFILE_TYPE_QS_ACCOUNT] = true,
	[PROFILE_TYPE_SK_ACCOUNT] = true}

local profileCatByDiscipline = {
	[PROFILE_DISCIPLINE_CP_BLUE] = PROFILE_CATEGORY_CP,
	[PROFILE_DISCIPLINE_CP_GREEN] = PROFILE_CATEGORY_CP,
	[PROFILE_DISCIPLINE_CP_RED] = PROFILE_CATEGORY_CP,
	[PROFILE_DISCIPLINE_SKILLS] = PROFILE_CATEGORY_SK,
	[PROFILE_DISCIPLINE_QUICKSLOTS] = PROFILE_CATEGORY_QS,
	[PROFILE_DISCIPLINE_GEAR] = PROFILE_CATEGORY_GEAR,
	[PROFILE_DISCIPLINE_OUTFIT] = PROFILE_CATEGORY_OUTFIT,
}

local profileCatByType = {
	[PROFILE_TYPE_CP_ACCOUNT] = PROFILE_CATEGORY_CP,	[PROFILE_TYPE_CP_CHAR] = PROFILE_CATEGORY_CP,	[PROFILE_TYPE_CP_IMPORT] = PROFILE_CATEGORY_CP,	[PROFILE_TYPE_CP_PRESET] = PROFILE_CATEGORY_CP,	[PROFILE_TYPE_CP_HOTBARS] = PROFILE_CATEGORY_CP,
	[PROFILE_TYPE_QS_ACCOUNT] = PROFILE_CATEGORY_QS,	[PROFILE_TYPE_QS_CHAR] = PROFILE_CATEGORY_QS,	[PROFILE_TYPE_SK_ACCOUNT] = PROFILE_CATEGORY_SK,	[PROFILE_TYPE_SK_CHAR] = PROFILE_CATEGORY_SK,
	[PROFILE_TYPE_GEAR_ACCOUNT] = PROFILE_CATEGORY_GEAR,
	[PROFILE_TYPE_GEAR_CHAR] = PROFILE_CATEGORY_GEAR,
	[PROFILE_TYPE_CP_HOTBARS_ACCOUNT] = PROFILE_CATEGORY_CP, 
	[PROFILE_TYPE_OUTFIT_ACCOUNT] = PROFILE_CATEGORY_OUTFIT,
	[PROFILE_TYPE_OUTFIT_CHAR] = PROFILE_CATEGORY_OUTFIT,
}

local profileDisciplineByCategory = {
	[PROFILE_CATEGORY_GEAR] = PROFILE_DISCIPLINE_GEAR,
	[PROFILE_CATEGORY_QS] = PROFILE_DISCIPLINE_QUICKSLOTS,
	[PROFILE_CATEGORY_SK] = PROFILE_DISCIPLINE_SKILLS,
	[PROFILE_CATEGORY_OUTFIT] = PROFILE_DISCIPLINE_OUTFIT,
}

local profileDisciplineTitles = {
	[PROFILE_DISCIPLINE_QUICKSLOTS] = GS(SI_COLLECTIONS_BOOK_QUICKSLOT_KEYBIND),
	[PROFILE_DISCIPLINE_SKILLS] = GS(SI_CHARACTER_MENU_SKILLS),
	[PROFILE_DISCIPLINE_GEAR] = GS(SI_ARMORY_EQUIPMENT_LABEL),
	[PROFILE_DISCIPLINE_OUTFIT] = GetCollectibleCategoryNameByCategoryId(13),
}

local profileCatsThatCanBeConnected = {[PROFILE_CATEGORY_CP] = true, [PROFILE_CATEGORY_QS] = true,}
		
local zoneAbbrByType = {
	trial = {[636] = "HRC", [638] = "AA", [639] = "SO", [1263] = "RG", [1344] = "DSR", [725] = "MoL", [975] = "HoF", [1000] = "AS", [1051] = "CR", [1121] = "SS", [1196] = "KA", [1427] = "SE", [1478] = "LC", [1548] = "OC", },
	solo = {[1227] = "VH", [677] = "MA",},
	arena = {[1082] = "BRP", [635] = "DSA", [1436]="EA",}
}

local roleAbbr = {"DD", "T", "", "H",}

local classAbbr = {"DK", "Sorc", "NB", "Warden", "Necro", "Temp", [117] = "Arc"}

local roleFilter = ""

local function getProfileTypeLists(createIfEmpty, presetsToo)
	local sV = CSPS.savedVariables
	local cC = CSPS.currentCharData
	if createIfEmpty then
		sV.cpProfiles = sV.cpProfiles or {}
		cC.cpProfiles = cC.cpProfiles or {}
		cC.cpHbProfiles = cC.cpHbProfiles or {}
		sV.cpHbProfiles = sV.cpHbProfiles or {}
		cC.qsProfiles = cC.qsProfiles or {}
		sV.qsProfiles = sV.qsProfiles or {}
		cC.skProfiles = cC.skProfiles or {}
		sV.skProfiles = sV.skProfiles or {}
		cC.gearProfiles = cC.gearProfiles or {}
		sV.gearProfiles = sV.gearProfiles or {}
		cC.outfitProfiles = cC.outfitProfiles or {}
		sV.outfitProfiles = sV.outfitProfiles or {}
	end
	local profileTypeLists = {
		sV.cpProfiles, cC.cpProfiles, 			--1,2
		nil, 									--3
		presetsToo and CSPS.CPPresets or nil, 	--4
		cC.cpHbProfiles,						--5
		sV.qsProfiles,	cC.qsProfiles,			--6,7
		sV.skProfiles,	cC.skProfiles,			--8,9
		sV.gearProfiles, cC.gearProfiles, 		--10,11
		sV.cpHbProfiles,						--12 
		sV.outfitProfiles, cC.outfitProfiles, -- 13, 14
	}
	return profileTypeLists
end

local function getProfileListByType(myType)
	local profileTypeLists = getProfileTypeLists(true, true)
	return profileTypeLists[myType]
end

CSPS.getProfileListByType = getProfileListByType

local function getProfileByTypeAndId(myType, myId, cat)
	if cat and cat ~= profileCatByType[myType] then return false end
	local profileList = getProfileListByType(myType)
	if not profileList then return false end
	return profileList[myId]
end

CSPS.getProfileByTypeAndId = getProfileByTypeAndId

function CSPS.getTrialArenaList()
	local trialArenaByName = {}
	local zoneAbbreviations = {}
	for _, typeData in pairs(zoneAbbrByType) do
		for zoneId, abbr in pairs(typeData) do
			local myName = zo_strformat("<<C:1>>", GetZoneNameById(zoneId))
			trialArenaByName[myName] = zoneId
			zoneAbbreviations[zoneId] = abbr
		end
	end
	return trialArenaByName, zoneAbbreviations, zoneAbbrByType
end

local function getCpHbId(myId)
	if not myId or type(myId) == "number" then return myId, false end
	local myId, accountWide = SplitString("-", myId)
	return tonumber(myId), accountWide ~= nil
end

CSPS.getCpHbId =getCpHbId

local function getBindingProfileByDisciplineAndId(discipline, myId)
	local myId, accountWide = getCpHbId(myId)
	if not myId then return false end
	local myType = discipline == PROFILE_DISCIPLINE_QUICKSLOTS and (accountWide and PROFILE_TYPE_QS_ACCOUNT or PROFILE_TYPE_QS_CHAR) 
		or accountWide and PROFILE_TYPE_CP_HOTBARS_ACCOUNT or PROFILE_TYPE_CP_HOTBARS
	local myProfile = getProfileByTypeAndId(myType, myId, nil)
	return myProfile, accountWide
end

CSPS.getBindingProfileByDisciplineAndId = getBindingProfileByDisciplineAndId

local function getBindingGroupByDisciplineAndId(discipline, myId, profileIsAccountWide)
	local idToLookFor = profileIsAccountWide and myId.."-a" or myId
	
	local myHotkey = false
	local bindingIsAccountWide = false
	
	if profileIsAccountWide then
		for i, v in ipairs(CSPS.spHotkeysA) do
			if v[discipline] == idToLookFor then myHotkey = i bindingIsAccountWide = true end
		end
	end
	
	for i, v in ipairs(CSPS.spHotkeysC) do
		if v[discipline] == idToLookFor then return i, false end
	end
	
	return myHotkey, bindingIsAccountWide
end

function CSPS.getProfileNameAbbr(myName)
	myName = myName or ""
	local myRole = CSPS.role or GetSelectedLFGRole()
	if not myRole or myRole == 3 then return myName end
	local myMagStam = CSPS.isMagOrStam()
	if myMagStam > 0 and myRole == 1 then
		local magStamAbbr = {"Mag", "Stam"}
		myName = string.format("%s (%s/%s-%s)", myName, classAbbr[GetUnitClassId("player")], magStamAbbr[myMagStam], roleAbbr[myRole]) 
	else
		myName = string.format("%s (%s/%s)", myName, classAbbr[GetUnitClassId("player")], roleAbbr[myRole]) 
	end
	return myName
end

function CSPS.getConnectedProfileName(myConnection)
	local myType, myId = SplitString("-", myConnection)
	local typeLists = getProfileTypeLists(false, true)
	
	local myName = typeLists[tonumber(myType)] 
	myName = myName and myName[tonumber(myId)] or false
	return myName and myName.name or "-"
end

local function addConnectionToTooltip(myType, myId, discipline)
	-- if discipline == 4 then return end
	ZO_Tooltip_AddDivider(InformationTooltip)
	local myProfile = CSPS.currentProfile == 0 and CSPS.currentCharData or CSPS.profiles[CSPS.currentProfile]
	local myText = ""
	if myProfile.connections and myProfile.connections[discipline] == string.format("%s-%s", myType, myId) then 
		myText = GS(CSPS_Tooltip_RemoveConnection) 
	else
		myText = GS(CSPS_Tooltip_AddConnection)
	end	
	local r,g,b = ZO_SELECTED_TEXT:UnpackRGB()
	InformationTooltip:AddLine(string.format("|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t + %s: %s", GS("SI_KEYCODE", CSPS.savedVariables.settings.jumpShiftKey or 7), myText), "$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
end

local subProfileCLASS = ZO_SortFilterList:Subclass()

function subProfileCLASS:New( control )
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control
	list:Setup()
	return list
end

local function loadQuickSlots(myType, myId, _, andApply)
	
	local compressedProfile = getProfileByTypeAndId(myType, myId, PROFILE_CATEGORY_QS)
	
	if not compressedProfile then return end
	
	CSPS.extractQS(compressedProfile.hbComp, CSPS.getQsBars())
		
	CSPS.refreshTree()
	
	if andApply then
		CSPS.applyQS(compressedProfile.cat ~= 0 and compressedProfile.cat)
	end
end

local function subProfileKeyLoadAndApply(myDiscipline, myId, accountWide) -- only for quickslots and cp hotbars 
	if myDiscipline == PROFILE_DISCIPLINE_QUICKSLOTS then
		loadQuickSlots(accountWide and PROFILE_TYPE_QS_ACCOUNT or PROFILE_TYPE_QS_CHAR, myId, nil, true)
		return
	end
	local hotbarsOnly = {false, false, false}
	local myProfile = getProfileByTypeAndId(accountWide and PROFILE_TYPE_CP_HOTBARS_ACCOUNT or PROFILE_TYPE_CP_HOTBARS, myId, nil)
	local hbComp = myProfile["hbComp"]
	local myDiscipline = myProfile["discipline"]
	hotbarsOnly[myDiscipline] = true
	cp.bar[myDiscipline] = cp.singleBarExtract(hbComp)
	cp.updateSidebarIcons(myDiscipline)		
	cp.updateSlottedMarks()
	CSPS.unsavedChanges = true
	CSPS.showElement("save", true)
	cp.applyConfirm(false, hotbarsOnly)
	cp.recheckHotbar()
	cp.updateSidebarIcons(myDiscipline)		
	cp.updateSlottedMarks()
	CSPS.refreshTree()
end

local function assignHkGroup(myGroup)
	local myId = CSPSWindowCpHbHkNumberList.idToAssign
	local myDiscipline = CSPSWindowCpHbHkNumberList.disciToAssign
	myId = string.match(myId, "%d+")
	myId = CSPSWindowCpHbHkNumberList.profileIsAccountWide and myId.."-a" or myId
	local spHotkeys = CSPSWindowCpHbHkNumberList.bindingIsAccountWide and CSPS.spHotkeysA or CSPS.spHotkeysC
	if spHotkeys[myGroup][myDiscipline] == myId then 
		spHotkeys[myGroup][myDiscipline] = nil
	else
		spHotkeys[myGroup][myDiscipline] = myId
	end	
	CSPS.currentCharData.cp2hbpHotkeys = CSPS.spHotkeysC
	CSPS.savedVariables.cp2hbpHotkeys = CSPS.spHotkeysA
	CSPSWindowCpHbHkNumberList:listDetails(myGroup)
	CSPSWindowCpHbHkNumberList:showHotkeySelector(myId, myDiscipline, nil, CSPSWindowCpHbHkNumberList.profileIsAccountWide)
	
end

function CSPS.getHotkeyByGroup(myHotkey, bindingIsAccountWide)
	local myKeyText = "-"
	local addShiftToName = false
	if bindingIsAccountWide and hf.anyEntryNotFalse(CSPS.spHotkeysC[myHotkey]) then
		if CSPS.savedVariables.settings.accountWideShiftKey ~= 0 then
			addShiftToName = true 
		else
			return "-"
		end
	end
	local layInd, catInd, actInd = GetActionIndicesFromName("CSPS_CPHK"..myHotkey)
	if layInd and catInd and actInd then 
		local keyCode, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layInd, catInd, actInd, 1)
		if keyCode > 0 then 
			myKeyText = ZO_Keybindings_GetBindingStringFromKeys(keyCode, mod1, mod2, mod3, mod4)
		--else
			--myKeyText = ZO_Keybindings_GetBindingStringFromKeys(nil, 0, 0, 0, 0)
		end
	end
	if addShiftToName then myKeyText = string.format("%s + %s", GS("SI_KEYCODE", CSPS.savedVariables.settings.accountWideShiftKey), myKeyText) end
	return myKeyText
end

local function getProfileNamesByGroup(myGroupId)
	local myNames = {"-", "-", "-", "-"}
	local spHotkeys = CSPSWindowCpHbHkNumberList.bindingIsAccountWide and CSPS.spHotkeysA or CSPS.spHotkeysC
	local myGroup = spHotkeys[myGroupId]
	if myGroup == nil then return myNames end
	for discipline=1, 4 do
		local myProfile = getBindingProfileByDisciplineAndId(discipline, myGroup[discipline])
		myNames[discipline] = myProfile and myProfile.name or "-"
	end
	return myNames
end

function CSPS.initHkNumberList()
	CSPSWindowCpHbHkNumberList.initialized = true
	CSPSWindowCpHbHkNumberList.btns = {}
	local btns = CSPSWindowCpHbHkNumberList.btns
	for i=1, 20 do
		local oneBtn = WINDOW_MANAGER:CreateControlFromVirtual(string.format("CSPSWindowCpHbHkNumberListBtn%s", i), CSPSWindowCpHbHkNumberList, "CSPScppBtnPreset")
		oneBtn:SetDimensions(42, 24)
		if i == 1 then
			oneBtn:SetAnchor(TOPLEFT, CSPSWindowCpHbHkNumberListCharBtn, BOTTOMLEFT, 0, 5)
		elseif i % 5 == 1 then
			oneBtn:SetAnchor(TOPLEFT, btns[i-5], BOTTOMLEFT, 0, 5)
		else
			oneBtn:SetAnchor(TOPLEFT, btns[i-1], TOPRIGHT, 5, 0)
		end
		
		-- local oneBtn = CSPSWindowCpHbHkNumberList:GetNamedChild(string.format("Btn%s", i))
		btns[i] = oneBtn
		oneBtn:SetHandler("OnMouseEnter", function() CSPSWindowCpHbHkNumberList:listDetails(i) end)
		oneBtn:SetHandler("OnMouseExit", function() CSPSWindowCpHbHkNumberList:listDetails(nil) end)
		oneBtn:SetHandler("OnClicked", function() assignHkGroup(i) end)
	end
	local curKey = CSPSWindowCpHbHkNumberList:GetNamedChild("CurKey")
	
	curKey:SetAnchor(TOPLEFT, btns[16], BOTTOMLEFT, 0, 5)
	curKey:SetAnchor(TOPRIGHT, btns[20], BOTTOMRIGHT, 0, 5)
	
	for i=1,4 do
		CSPSWindowCpHbHkNumberList:GetNamedChild("Col"..i):SetColor(CSPS.cpColors[i]:UnpackRGB())
	end
	
	
	function CSPSWindowCpHbHkNumberList:listDetails(myGroupId)
		curKey:SetText(myGroupId and string.format("Hotkey: %s",  CSPS.getHotkeyByGroup(myGroupId, self.bindingIsAccountWide)) or "")
		local myColNames = myGroupId and getProfileNamesByGroup(myGroupId)
		for i=1,4 do
			self:GetNamedChild("Col"..i):SetText(myColNames and myColNames[i] or "")
		end
	end
	function CSPSWindowCpHbHkNumberList:showHotkeySelector(myId, myDiscipline, control, profileIsAccountWide)
		self.col = CSPS.cpColors[myDiscipline]
		self.idToAssign = myId
		self.disciToAssign = myDiscipline
		if self.bindingIsAccountWide == nil then self.bindingIsAccountWide = false end
		self.profileIsAccountWide = profileIsAccountWide

		self.bindingIsAccountWide = profileIsAccountWide and self.bindingIsAccountWide or false
		local accBtn = self:GetNamedChild("AccBtn")
		local charBtn = self:GetNamedChild("CharBtn")
		accBtn:SetHidden(not profileIsAccountWide)
		
		charBtn:SetEnabled(self.bindingIsAccountWide)
		accBtn:SetEnabled(not self.bindingIsAccountWide)
			
		if self.bindingIsAccountWide then
			charBtn:SetNormalTexture("esoui/art/inventory/inventory_currencytab_oncharacter_up.dds")
			accBtn:SetNormalTexture("esoui/art/inventory/inventory_currencytab_accountwide_down.dds")
			charBtn:SetHandler("OnClicked", function(_, mouseButton) if mouseButton == 1 then self.bindingIsAccountWide = false self:showHotkeySelector(myId, myDiscipline, nil, profileIsAccountWide) end end)
		else
			charBtn:SetNormalTexture("esoui/art/inventory/inventory_currencytab_oncharacter_down.dds")
			accBtn:SetNormalTexture("esoui/art/inventory/inventory_currencytab_accountwide_up.dds")
			accBtn:SetHandler("OnClicked", function(_, mouseButton) if mouseButton == 1 then self.bindingIsAccountWide = true self:showHotkeySelector(myId, myDiscipline, nil, profileIsAccountWide) end end)
		end
		
		
		
		local spHotkeys = self.bindingIsAccountWide and CSPS.spHotkeysA or CSPS.spHotkeysC
		
		for i=1, 20 do
			local myBtn = self.btns[i]
			local myBG = myBtn:GetNamedChild("BG")
			if spHotkeys[i][myDiscipline] == myId then
				local r,g,b = self.col:UnpackRGB()
				myBG:SetCenterColor(r, g, b, 0.4)
				myBtn:SetEnabled(true)
			elseif spHotkeys[i][myDiscipline] == nil then
				myBG:SetCenterColor(0.0314, 0.0314, 0.0314)
				myBtn:SetEnabled(true)
			else
				myBG:SetCenterColor(1, 1, 1, 0.4)
				myBtn:SetEnabled(false)
			end
		end
		if control then
			self:ClearAnchors()
			self:SetAnchor(TOPLEFT, control, BOTTOM)
			self:SetHidden(false)
			local function hideMe()
				local moCtrl = WINDOW_MANAGER:GetMouseOverControl()
				if string.find(moCtrl:GetName(), self:GetName()) == nil and string.find(moCtrl:GetName(), "Hotkey") == nil then
					self:SetHidden(true)
					EVENT_MANAGER:UnregisterForEvent(CSPS.name, EVENT_GLOBAL_MOUSE_DOWN)
				end
			end
			EVENT_MANAGER:RegisterForEvent(CSPS.name, EVENT_GLOBAL_MOUSE_DOWN, hideMe)
		end	
	end
end

local function setupRoleFilterCombo()
	CSPSWindowSubProfilesRoleFilter.comboBox = CSPSWindowSubProfilesRoleFilter.comboBox or ZO_ComboBox_ObjectFromContainer(CSPSWindowSubProfilesRoleFilter)
	local myComboBox = CSPSWindowSubProfilesRoleFilter.comboBox	
	myComboBox:ClearItems()
	myComboBox:SetSortsItems(true)
	
	local function OnItemSelect(_, choiceText, _)
		roleFilter = choiceText
		
		CSPS.subProfileList:RefreshData()
		PlaySound(SOUNDS.POSITIVE_CLICK)
	end
	
	for roleIndex, roleName in pairs(roles) do
		if roleName ~= "" and roleIndex ~= 1 then myComboBox:AddItem(myComboBox:CreateItemEntry(roleName, OnItemSelect)) end
	end
	
	myComboBox:SetSelectedItem(roleFilter ~= "" and roleFilter or GS(SI_CHAT_OPTIONS_FILTERS))

end

local function hbHkClick(myId, myDiscipline, control, mouseButton, profileIsAccountWide)
	if not CSPSWindowCpHbHkNumberList.initialized then CSPS.initHkNumberList() end
	if not CSPSWindowCpHbHkNumberList:IsHidden() then 
		CSPSWindowCpHbHkNumberList:SetHidden(true) 
		return 
	end
	CSPSWindowCpHbHkNumberList:showHotkeySelector(myId, myDiscipline, control, profileIsAccountWide)
	ZO_Tooltips_HideTextTooltip()
end

local function hbPshowTTApply(myId, myDiscipline, profileIsAccountWide, control)
	local myTooltip = {GS(CSPS_Tooltiptext_LoadAndApply)}
	if profileCatByDiscipline[myDiscipline] == PROFILE_CATEGORY_CP then
		local myProfile = profileIsAccountWide and CSPS.savedVariables.cpHbProfiles[myId] or not profileIsAccountWide and CSPS.currentCharData.cpHbProfiles[myId]
		local myHb = {SplitString(",", myProfile["hbComp"])}
		for i, v in pairs(myHb) do
			local myString = zo_strformat("<<C:1>>", GetChampionSkillName(tonumber(v))) or "-"
			local myColor = cpColors[myDiscipline]:ToHex()
			myString = string.format(" |t24:24:esoui/art/champion/champion_icon_32.dds|t %s) |c%s%s|r", i, myColor, myString)
			table.insert(myTooltip, myString)
		end
		myTooltip = table.concat(myTooltip, "\n")
		ZO_Tooltips_ShowTextTooltip(control, RIGHT, myTooltip)
	else
		InitializeTooltip(InformationTooltip, control, LEFT)	
		local r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
		InformationTooltip:AddLine(myTooltip[1], "ZoFontGame", r, g, b)
		local myProfile = not profileIsAccountWide and CSPS.currentCharData.qsProfiles[myId] or profileIsAccountWide and CSPS.savedVariables.qsProfiles[myId]
		CSPS.addQsBarsToTooltip(CSPS.extractQS(myProfile.hbComp))
	end
end

local function ShowCustomCPProfileTT(control, data)
	if data.type ~= PROFILE_TYPE_CP_ACCOUNT and data.type ~= PROFILE_TYPE_CP_CHAR then return end
	InitializeTooltip(InformationTooltip, control, LEFT)	
	local r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
	InformationTooltip:AddLine(data.name, "ZoFontWinH2", r, g, b)
	local myId = data.myId
	local myProfile = data.type == 1 and CSPS.savedVariables.cpProfiles and CSPS.savedVariables.cpProfiles[myId] or data.type == 2 and CSPS.currentCharData.cpProfiles and CSPS.currentCharData.cpProfiles[myId]
	if not myProfile then return end
	if myProfile.lastSaved then 
		InformationTooltip:AddLine(string.format("(%s)", os.date("%x", myProfile.lastSaved)), "ZoFontGame", r, g, b) 
	end
	local myProfileIcon = cpColors[myProfile.discipline]:ToHex()
	local myColor = cpColors[myProfile.discipline]:ToHex()
	if myProfile.hbComp then
		ZO_Tooltip_AddDivider(InformationTooltip)
		local myHbText = {}
		for _, cpId in pairs({SplitString(",", myProfile.hbComp)}) do
			if tonumber(cpId) then table.insert(myHbText, string.format("|c%s%s|r", myColor, zo_strformat("<<C:1>>", GetChampionSkillName(tonumber(cpId))))) end
		end
		InformationTooltip:AddLine(string.format("|t28:28:%s|t %s", myProfileIcon, table.concat(myHbText, ", ")), "ZoFontGame", r, g, b)
	end
	if myProfile.cpComp then
		local myCPList = {}
		for _, cpValuePair in pairs({SplitString(";", myProfile.cpComp)}) do
			local myPair = {SplitString("-", cpValuePair)}
			local myCPKey = tonumber(myPair[1])
			local myCPValue = tonumber(myPair[2])
			if myCPKey and myCPValue then table.insert(myCPList, string.format("|c%s%s|r(%s)", myColor, zo_strformat("<<C:1>>", GetChampionSkillName(myCPKey)), myCPValue)) end
		end		
		ZO_Tooltip_AddDivider(InformationTooltip)
		InformationTooltip:AddLine(table.concat(myCPList, ", "), "ZoFontGame", r, g, b)
	end
	addConnectionToTooltip(data.type, myId, myProfile.discipline)
end

function CSPS.showSkillProfileTT(control, myType, myId)
	local myProfile = getProfileByTypeAndId(myType, myId)
	if not myProfile or not myProfile.actionBar and (not myProfile.hbComp or not myProfile.hbComp.prog or not myProfile.hbComp.pass) then return end
	local activeSkills, passiveSkills, changedRace, crafted, styles, subclasses = false, false, false, false, false, false
	
	if myProfile.hbComp then 
		activeSkills, passiveSkills, changedRace, crafted, styles, subclasses = CSPS.skTableExtract(myProfile.hbComp.prog, myProfile.hbComp.pass, true, true, myProfile.hbComp.crafted, myProfile.hbComp.styles, myProfile.hbComp.subclasses, false, myProfile.hbComp.scribeStyleSubclass) 
		if not myProfile.hbComp.subclasses then subclasses = false end
	end
	
	InitializeTooltip(InformationTooltip, control, LEFT)	
	local r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
	InformationTooltip:AddLine(myProfile.name, "ZoFontWinH2", r, g, b)
	if myProfile.lastSaved then 
		InformationTooltip:AddLine(string.format("(%s)", os.date("%x", myProfile.lastSaved)), "ZoFontGame") 
	end
	
	
	if myProfile.hbComp then
		ZO_Tooltip_AddDivider(InformationTooltip)
		if subclasses and myProfile.hbComp.subclasses then
			for i, v in pairs(subclasses) do
				local skillLineId = GetSkillLineId(1,v)
				InformationTooltip:AddLine(zo_strformat("|t23:23:<<1>>|t <<C:2>>", GetCollectibleIcon(GetSkillLineMasteryCollectibleId(skillLineId)), GetSkillLineNameById(skillLineId)), "ZoFontGame", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
			end
			
			InformationTooltip:AddLine("", "ZoFontGame", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
		end
		if #activeSkills + #passiveSkills < 30 then
			--local activeTooltip = {}
			InformationTooltip:AddLine(GS(SI_SKILLS_ACTIVE_ABILITIES), "ZoFontWinH4", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
			for _, skillIndices in pairs(activeSkills) do
				local abId = GetSpecificSkillAbilityInfo(unpack(skillIndices))
				InformationTooltip:AddLine(zo_strformat("|t23:23:<<1>>|t <<C:2>>", GetAbilityIcon(abId), GetAbilityName(abId)), "ZoFontGame", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)				
			end
			if #activeSkills == 0 then InformationTooltip:AddLine("-") end
	
			InformationTooltip:AddLine(GS(SI_SKILLS_PASSIVE_ABILITIES), "ZoFontWinH4", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
			for _, skillIndices in pairs(passiveSkills) do
				local abId = GetSpecificSkillAbilityInfo(skillIndices[1], skillIndices[2], skillIndices[3], nil, skillIndices[4])
				InformationTooltip:AddLine(zo_strformat("|t23:23:<<1>>|t <<C:2>> (<<C:3>> <<4>>)", GetAbilityIcon(abId), GetAbilityName(abId), GS(SI_STAT_TRADESKILL_RANK), skillIndices[4]), "ZoFontGame", r, g, b, CENTER, nil, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
			end
			if #passiveSkills == 0 then InformationTooltip:AddLine("-") end
		else
			local skillTypeNumbers = {false, false, false, false, false, false, false, false} --pre-fill the table so it still will be sorted by numbers
			local skillPoints = {}
			local skillTypeColors = {}
			if changedRace then skillTypeColors[7] = ZO_ERROR_COLOR end
			for _, skillIndices in pairs(activeSkills) do
				local skillType = skillIndices[1]
				skillTypeNumbers[skillType] = skillTypeNumbers[skillType] or {}
				skillTypeNumbers[skillType].active = (skillTypeNumbers[skillType].active or 0) + 1
				skillPoints[skillType] = (skillPoints[skillType] or 0) + (not IsSkillAbilityAutoGrant(unpack(skillIndices)) and 1 or 0) + (skillIndices[4] > 0 and 1 or 0)
				if skillType == 1 and skillIndices[2] > 3 then skillTypeColors[skillType] = ZO_ERROR_COLOR end
			end
			for _, skillIndices in pairs(passiveSkills) do
				local skillType = skillIndices[1]
				skillTypeNumbers[skillType] = skillTypeNumbers[skillType] or {}
				skillTypeNumbers[skillType].passive = (skillTypeNumbers[skillType].passive or 0) + 1
				skillPoints[skillType] = (skillPoints[skillType] or 0) + (not IsSkillAbilityAutoGrant(unpack(skillIndices)) and 1 or 0) + (skillIndices[4] > 1 and skillIndices[4] - 1 or 0)
				if skillType == 1 and skillIndices[2] > 3 then skillTypeColors[skillType] = ZO_ERROR_COLOR end
			end
			for i, v in pairs(skillTypeNumbers) do
				if v then
					local myColor = skillTypeColors[i] or ZO_SELECTED_TEXT
					InformationTooltip:AddLine(string.format("%s (%s %s)", GS("SI_SKILLTYPE", i), skillPoints[i] or 0, GS(SI_LEVEL_UP_REWARDS_SKILL_POINT_TOOLTIP_HEADER)), "ZoFontWinH4", myColor:UnpackRGB())
					InformationTooltip:AddLine(string.format("%s: %s / %s: %s", GS(SI_SKILLS_ACTIVE_ABILITIES), v.active or 0, GS(SI_ABILITY_TOOLTIP_PASSIVE), v.passive or 0), "ZoFontGame", myColor:UnpackRGB())
				end
			end
		end
	end
	
	if myProfile.actionBar then		
		ZO_Tooltip_AddDivider(InformationTooltip)
		for _, subString in pairs({SplitString(";", myProfile.actionBar)}) do
			local myBar = {}
			for _, abId in pairs({SplitString(",", subString)}) do
				table.insert(myBar, string.format("|t24:24:%s|t", abId ~= "-" and GetAbilityIcon(tonumber(abId)) or "esoui/art/actionbar/abilityframe64_down.dds"))
			end
			InformationTooltip:AddLine(table.concat(myBar, " "), "ZoFontGame", r, g, b)
		end
	end
end

local function showOutfitTT(control, myType, myId)
	local myProfile = getProfileByTypeAndId(myType, myId)
	if not myProfile or not myProfile.outfitComp then return end
	InitializeTooltip(InformationTooltip, control, LEFT)	
	InformationTooltip:AddLine(myProfile.name, "ZoFontWinH2")
	if myProfile.lastSaved then 
		InformationTooltip:AddLine(string.format("(%s)", os.date("%x", myProfile.lastSaved)), "ZoFontGame") 
	end
	ZO_Tooltip_AddDivider(InformationTooltip)
	CSPS.outfits.addToTooltip(CSPS.outfits.extract(myProfile.outfitComp, {}))
end

local function showGearTT(control, myType, myId)
	local myProfile = getProfileByTypeAndId(myType, myId)
	if not myProfile or not myProfile.gear and not myProfile.gearUnique then return end
	local gearTable = CSPS.extractGearString(myProfile.gear, myProfile.gearUnique)
	
	InitializeTooltip(InformationTooltip, control, LEFT)	
	InformationTooltip:AddLine(myProfile.name, "ZoFontWinH2")
	if myProfile.lastSaved then 
		InformationTooltip:AddLine(string.format("(%s)", os.date("%x", myProfile.lastSaved)), "ZoFontGame") 
	end
	
	ZO_Tooltip_AddDivider(InformationTooltip)
	
	local poisonItemLink = "|H0:item:%s:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:%s|h|h"
	
	for _, gearSlot in pairs(CSPS.getSortedGearSlots()) do
		local gearData = gearTable[gearSlot]
		if gearData then 
			InformationTooltip:AddLine(gearData.link or string.format(poisonItemLink, gearData.firstId or 0, gearData.secondId or 0), "ZoFontGame") 
		end
	end
	
end

local function showPresetProfileTT(control, data)
	InitializeTooltip(InformationTooltip, control, LEFT)	
	InformationTooltip:AddLine(control.data.name, "ZoFontWinH2")
	ZO_Tooltip_AddDivider(InformationTooltip)
	if control.data.addInfo then
		InformationTooltip:AddLine(control.data.addInfo, "ZoFontGame") 
		ZO_Tooltip_AddDivider(InformationTooltip)
	end
	InformationTooltip:AddLine(zo_strformat(GS(CSPS_Tooltip_CPPUpdate), control.data.updated[1], control.data.updated[2], control.data.updated[3]), "ZoFontGame")
	if control.data.website then InformationTooltip:AddLine(zo_strformat(GS(CSPS_Tooltip_CPPWebsite), control.data.website), "ZoFontGame") end
	addConnectionToTooltip(4, control.data.myId, control.data.discipline)
	InformationTooltip:AddLine(string.format("|t26:26:esoui/art/miscellaneous/icon_rmb.dds|t: %s", GS(SI_GAMEPAD_HELP_DETAILS)))
end

local function getSubProfileName(myId, myType)
	local myProfile = getProfileByTypeAndId(myType, myId, nil)
	local myName = myProfile and myProfile.name or false
	return myName
end

local function subProfileDelete(myId, myType, myDiscipline)
	local profileTypeLists = getProfileTypeLists(false, false)	
	local accountWide = accountWideProfileTypes[myType]
	
	if typesWithKeybinds[myType] then	-- delete hotkey bindings for deleted cp bar profile
		
		local idToLookFor = accountWide and myId.."-a" or myId
		
		for i, v in ipairs(CSPS.spHotkeysC) do
			if v[myDiscipline] == idToLookFor then v[myDiscipline] = nil end
		end		
		
		for i, v in ipairs(CSPS.spHotkeysA) do
			if v[myDiscipline] == idToLookFor then v[myDiscipline] = nil end
		end		
	end
	
	if profileTypeLists[myType] then profileTypeLists[myType][myId] = nil end

	CSPS.subProfileList:RefreshData()
end

local function subProfileMinus(myId, myType, myDiscipline)
	local myName = getSubProfileName(myId, myType)
	if not myName then return end
	ZO_Dialogs_ShowDialog(CSPS.name.."_OkCancelDiag", 
		{returnFunc = function()  subProfileDelete(myId, myType, myDiscipline)  end},  
		{mainTextParams = {zo_strformat(GS(CSPS_MSG_DeleteProfile), myName, "", "")}, titleParams = {GS(CSPS_MyWindowTitle)}})
end


function subProfileCLASS:SetupItemRow( control, data )
	control.data = data
	local ctrName = GetControl(control, "Name")
	local ctrPoints = GetControl(control, "Points")
	local ctrRole = GetControl(control, "Role")
	local ctrSource = GetControl(control, "Source")
	
	ctrName.normalColor = ZO_DEFAULT_TEXT
	ctrName:SetText(data.name)
	
	local tooltipFunction = {
		[PROFILE_DISCIPLINE_QUICKSLOTS] = function() CSPS.showQuickSlotProfileTT(control, data.type, data.myId) end,
		[PROFILE_DISCIPLINE_SKILLS] = function()  CSPS.showSkillProfileTT(control, data.type, data.myId) end,
		[PROFILE_DISCIPLINE_GEAR] = function() showGearTT(control, data.type, data.myId) end,
		[PROFILE_DISCIPLINE_OUTFIT] = function() showOutfitTT(control, data.type, data.myId) end,
	}

	tooltipFunction = tooltipFunction[data.discipline] 
	
	tooltipFunction = tooltipFunction 
		or (data.type == PROFILE_TYPE_CP_ACCOUNT or data.type == PROFILE_TYPE_CP_CHAR) and function() ShowCustomCPProfileTT(control, data) end
		or data.type == PROFILE_TYPE_CP_PRESET and function() showPresetProfileTT(control, data) end
		or ctrName:WasTruncated() and data.type ~=PROFILE_TYPE_CP_PRESET and function() ZO_Tooltips_ShowTextTooltip(ctrName, RIGHT, data.name) end
		or function() end
	
	ctrName:SetHandler("OnMouseEnter", function() tooltipFunction() CSPS.SubProfileListRowMouseEnter(control) end)
	
	ctrPoints.normalColor = ZO_DEFAULT_TEXT
	ctrPoints:SetText(data.points)
	
	local typesToShowConnectionsFor = {
		[PROFILE_TYPE_CP_ACCOUNT] = true, 
		[PROFILE_TYPE_CP_CHAR]= true, 
		[PROFILE_TYPE_CP_PRESET]= true, 
		[PROFILE_TYPE_QS_ACCOUNT] = true, 
		[PROFILE_TYPE_QS_CHAR] = true
	}
	
	if typesToShowConnectionsFor[data.type] then
		local myProfile = CSPS.currentProfile == 0 and CSPS.currentCharData or CSPS.profiles[CSPS.currentProfile]
		local showConnectionIcon = myProfile.connections and myProfile.connections[data.discipline] == string.format("%s-%s", data.type, data.myId)
		GetControl(control, "Connection"):SetHidden(not showConnectionIcon)
		local theColor = showConnectionIcon and CSPS.cpColors[data.discipline] or ZO_DEFAULT_TEXT
		ctrName.normalColor = theColor
		ctrPoints.normalColor = theColor
		
	end
	
	
	if not nonCustomTypes[data.type] then 
		control:GetNamedChild("Rename"):SetHandler("OnClicked", function() CSPS.subProfileRename(data.myId, data.type) end)
		control:GetNamedChild("Save"):SetHandler("OnClicked", function() CSPS.subProfileSave(data.myId, data.type) end)
		control:GetNamedChild("Minus"):SetHandler("OnClicked", function() subProfileMinus(data.myId, data.type, data.discipline) end)
		if data.isNew then 
			ctrName.normalColor = ZO_GAME_REPRESENTATIVE_TEXT
			ctrPoints.normalColor = ZO_GAME_REPRESENTATIVE_TEXT
		end
	end
	ctrName:ClearAnchors()
	ctrName:SetAnchor(RIGHT, data.type == PROFILE_TYPE_CP_PRESET and ctrRole or control:GetNamedChild("Rename"), LEFT, -5, 0, ANCHOR_CONSTRAINS_X)
	ctrName:SetAnchor(LEFT, ctrPoints, RIGHT, 5, 0)
	ctrRole:SetHidden(data.type  ~= PROFILE_TYPE_CP_PRESET )
	ctrSource:SetHidden(data.type ~= PROFILE_TYPE_CP_PRESET )
	
	if data.type == PROFILE_TYPE_CP_PRESET  then
		ctrRole:SetText(data.role)
		ctrSource:SetText(data.source)
		ctrRole.normalColor = ZO_DEFAULT_TEXT
		ctrSource.normalColor = ZO_DEFAULT_TEXT
	end
	
	local showKeybinds = typesWithKeybinds[data.type]
	ctrPoints:SetHidden(showKeybinds)
	control:GetNamedChild("Hotkey"):SetHidden(not showKeybinds)
	control:GetNamedChild("Apply"):SetHidden(not showKeybinds)
	
	if cpHotBarProfileTypes[data.type] then
		GetControl(control, "Connection"):SetHidden(false)
		local myTexture = accountWideProfileTypes[data.type] and "esoui/art/inventory/inventory_currencytab_accountwide_down.dds" or "esoui/art/inventory/inventory_currencytab_oncharacter_down.dds"
		GetControl(control, "Connection"):SetTexture(myTexture)
	end
	
	if showKeybinds then
		local profileIsAccountWide = accountWideProfileTypes[data.type]
		control:GetNamedChild("Apply"):SetHandler("OnClicked", function() subProfileKeyLoadAndApply(data.discipline, data.myId, profileIsAccountWide) end) 
		control:GetNamedChild("Apply"):SetHandler("OnMouseEnter", function() hbPshowTTApply(data.myId, data.discipline, profileIsAccountWide, control:GetNamedChild("Apply")) end)
		
		local myHotkey, bindingIsAccountWide = getBindingGroupByDisciplineAndId(data.discipline, data.myId, profileIsAccountWide)
		
		local myKeyText = myHotkey and myHotkey > 0 and CSPS.getHotkeyByGroup(myHotkey, bindingIsAccountWide) or "-"
				
		control:GetNamedChild("Hotkey"):SetHandler("OnClicked", function(_, mouseButton) hbHkClick(data.myId, data.discipline, control:GetNamedChild("Hotkey"), mouseButton, profileIsAccountWide) end)
		control:GetNamedChild("Hotkey"):SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(control:GetNamedChild("Hotkey"), RIGHT, GS(CSPS_Tooltiptext_CpHbHk)) end)
	end
	
	local myIcon = control:GetNamedChild("Icon")
	if myIcon then 
		myIcon:SetTexture(CSPS.cpColTex[data.discipline]) 
		myIcon:SetColor(CSPS.cpColors[data.discipline]:UnpackRGB())
	end

	ZO_SortFilterList.SetupRow(self, control, data)
end



function CSPS.sortSubProfiles(newSortKey)
	if CSPS.savedVariables.settings.cppSortKey ~= newSortKey then
		CSPS.savedVariables.settings.cppSortKey = newSortKey
		CSPS.subProfileList.currentSortKey = newSortKey
	else
		CSPS.savedVariables.settings.cppSortOrder  = CSPS.savedVariables.settings.cppSortOrder  or false -- false = value for sort_order_down
		CSPS.savedVariables.settings.cppSortOrder = not CSPS.savedVariables.settings.cppSortOrder 
		CSPS.subProfileList.currentSortOrder = CSPS.savedVariables.settings.cppSortOrder
	end
	CSPS.subProfileList:RefreshData()
end

function subProfileCLASS:Setup()
	ZO_ScrollList_AddDataType(self.list, 1, "CSPSsubprofileLE", 30, function(control, data) self:SetupItemRow(control, data) end)
	ZO_ScrollList_AddDataType(self.list, 2, "CSPSsubprofileLECUST", 30, function(control, data) self:SetupItemRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)
	self.masterList = { }
	
	local sortKeys = {
		["name"]     = { caseInsensitive = true, },
		["points"] = { caseInsensitive = true, tiebreaker = "name" },
		["role"] = { caseInsensitive = true, tiebreaker = "name" },
		["source"] = { caseInsensitive = true, tiebreaker = "role" },
	}
	
	self.currentSortKey = CSPS.savedVariables.settings.cppSortKey or "name"
	self.currentSortOrder = CSPS.savedVariables.settings.cppSortOrder == nil and ZO_SORT_ORDER_UP or CSPS.savedVariables.settings.cppSortOrder 
	self.sortFunction = function( listEntry1, listEntry2 )
		return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder)
	end

	self:RefreshData()
end

function subProfileCLASS:SortScrollList( )
	if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
		table.sort(ZO_ScrollList_GetDataList(self.list), self.sortFunction)
		self:RefreshVisible()
	end
	if newProfileBringToTop then
		local iToTop = 0
		for i, v in pairs(ZO_ScrollList_GetDataList(self.list)) do
			if v.data.isNew then iToTop = i end
		end
		if iToTop > 0 then
			table.insert(ZO_ScrollList_GetDataList(self.list), 1, table.remove(ZO_ScrollList_GetDataList(self.list), iToTop))
		end
		newProfileBringToTop = false
	end
end

function subProfileCLASS:BuildMasterList()
	self.masterList = { }
	local profileTypeLists = getProfileTypeLists(false, true)
	for myType, myList in pairs(profileTypeLists) do
		for myId, myData in pairs(myList) do
			local myDiscipline = profileDisciplineByCategory[profileCatByType[myType]] or myData.discipline
			local insertData = {type = myType, name = myData.name, discipline = myDiscipline, myId = myId, points = myData.points, isNew = myData.isNew}
			if myDiscipline == PROFILE_DISCIPLINE_QUICKSLOTS then
				insertData.cat = myData.cat
			end
			if myType == PROFILE_TYPE_CP_PRESET then
				insertData.role = roles[myData.role or 7]
				insertData.source = myData.source
				insertData.addInfo = myData.addInfo
				insertData.website = myData.website
				insertData.updated = myData.updated
				insertData.old = myData.old
			end			
			table.insert(self.masterList, insertData)
		end
	end
end

function subProfileCLASS:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	local showCPHotbarAccount = CSPS.subProfileType == PROFILE_TYPE_CP_HOTBARS -- one list for both types
	for _, data in ipairs(self.masterList) do
		local templateType = 2 -- My type here refers to the UI element not the data type: 1 being a list entry for presets, 2 also contains the profile buttons
		if nonCustomTypes[data.type] then templateType = 1 end 
		if (CSPS.subProfileDiscipline == nil or CSPS.subProfileDiscipline == data.discipline) and (CSPS.subProfileType == nil or CSPS.subProfileType == data.type or (showCPHotbarAccount and data.type == PROFILE_TYPE_CP_HOTBARS_ACCOUNT)) then
			if not data.old or CSPS.savedVariables.settings.showOutdatedPresets then
				if data.type ~= 4 or roleFilter == "" or roleFilter == roles[7] or roleFilter == data.role or data.role == roles[7] or (data.role == 1 and (roleFilter == roles[5] or roleFilter == roles[6])) then
					table.insert(scrollData, ZO_ScrollList_CreateDataEntry(templateType, data))
				end
			end
		end
	end
end

function CSPS.showSubProfileDiscipline(newDiscipline, silentChange)
	if silentChange and CSPSWindowSubProfiles:IsHidden() then 
		CSPS.subProfileDiscipline = newDiscipline
		return 
	elseif CSPSWindowSubProfiles:IsHidden() == false and CSPS.subProfileDiscipline == newDiscipline and silentChange == nil then
		CSPSWindowSubProfiles:SetHidden(true)
		CSPSWindowCPImport:SetHidden(true)
		--CSPSWindowSubProfiles:SetHeight(0)
		CSPSWindowSubProfiles:SetAnchor(BOTTOMRIGHT, CSPSWindowBuild, BOTTOMRIGHT, 0, 5)
		return
	end
	newDiscipline = newDiscipline or CSPS.subProfileDiscipline or PROFILE_DISCIPLINE_CP_BLUE
	if newDiscipline < 4 and not CSPS.treeIsReady then  
		cp.readCurrent()
		CSPS.createTree() -- Create the treeview if no treeview exists yet
		CSPS.toggleCP(0, false)
	end
	CSPSWindowManageBars:SetHidden(true)
	CSPSWindowOptions:SetHidden(true)
	CSPSWindowMain:SetHidden(false)
	CSPS.subProfileDiscipline = newDiscipline
	CSPS.setSubProfileType()
		
	CSPSWindowSubProfilesTitle:SetText(profileDisciplineTitles[CSPS.subProfileDiscipline] or GS(CSPS_Tooltiptext_CPProfile))
	
	local r, g, b = CSPS.cpColors[CSPS.subProfileDiscipline]:UnpackRGB()
	CSPSWindowSubProfilesTitle:SetColor(r,g,b)
	CSPSWindowSubProfilesHeaderPoints:SetColor(r,g,b)
	CSPSWindowSubProfilesHeaderName:SetColor(r,g,b)
	CSPSWindowSubProfilesHeaderRole:SetColor(r,g,b)
	CSPSWindowSubProfilesHeaderSource:SetColor(r,g,b)
	CSPS.showElement("cpProfiles", true)
	if newDiscipline < 4 then 
		CSPS.openTreeToSection(4, newDiscipline)
	else
		local sectionByDiscipline = {[PROFILE_DISCIPLINE_QUICKSLOTS] = 8, [PROFILE_DISCIPLINE_SKILLS] = 3, [PROFILE_DISCIPLINE_GEAR] = 7, }
		CSPS.openTreeToSection(sectionByDiscipline[newDiscipline])
	end
end

local function addSubProfile(myProfile, myType)
	local profileTypeLists = getProfileTypeLists(true, false)
	local myPos = profileTypeLists[myType] and #profileTypeLists[myType] + 1
	if profileTypeLists[myType] then
		table.insert(profileTypeLists[myType], myProfile)
	end
	
	newProfileBringToTop = true
	
	if not CSPS.subProfileList then
		CSPS.subProfileList = subProfileCLASS:New(CSPSWindowSubProfiles)
	else
		CSPS.subProfileList:RefreshData()
	end
	
	-- setting .isnew to nil after refreshing so it will only show until the next refresh
	for j, w in pairs(profileTypeLists) do
		for i, v in pairs(w) do
			v.isNew = nil
		end
	end
	
	return myProfile, profileTypeLists[myType], myPos
end

function CSPS.subProfilePlus(myType, qsBarIndex, addonName)
	
	local myProfile = {}
	local myTable = {}
	local myPoints = 0
	local myBar = ""
	
	local myName = GS(CSPS_Txt_NewProfile2)
	local myZone = GetUnitWorldPosition("player")
	
	local _, zoneAbbr = CSPS.getTrialArenaList()
	
	myName = not cpHotBarProfileTypes[myType] and zoneAbbr[myZone] or myName -- add zone to name
	myName = not cpHotBarProfileTypes[myType] and CSPS.getProfileNameAbbr(myName) -- add role to name
	
	myName = addonName and string.format("%s (%s)", os.date("%x", os.time())) or myName
	
	if profileCatByType[myType] == PROFILE_CATEGORY_CP and not cpHotBarProfileTypes[myType] then
		for i, skillData in pairs (cp.table) do
			if skillData.discipline == CSPS.subProfileDiscipline then 
				myTable[i] = skillData
				myPoints = myPoints + skillData.value
			end
		end
		myTable = cp.compress(myTable)
	end
	if profileCatByType[myType] == PROFILE_CATEGORY_CP then
		myBar = cp.singleBarCompress(cp.bar[CSPS.subProfileDiscipline])	
	elseif profileCatByType[myType] == PROFILE_CATEGORY_OUTFIT then
		local outfitComp = CSPS.outfits.compress()
		myProfile = {name = myName, discipline = CSPS.subProfileDiscipline, outfitComp = outfitComp, isNew = true}
		addSubProfile(myProfile, myType)
		return
	elseif profileCatByType[myType] == PROFILE_CATEGORY_GEAR then
		local gear, gearUnique = CSPS.buildGearString()
		if not gear and not gearUnique then return end
		if not gear and not gearUnique then return end
		local points = 0
		for i, v in pairs(CSPS.getTheGear()) do if v then points = points + 1 end end
		myProfile = {name = myName, discipline = CSPS.subProfileDiscipline, points = points, gear = gear, gearUnique = gearUnique, isNew = true}
		addSubProfile(myProfile, myType)
		return
	elseif profileCatByType[myType] == PROFILE_CATEGORY_QS then
		local function addQSProfile(barIndex)
			local barsToCompress = CSPS.getQsBars()
			barsToCompress = barIndex and barIndex ~= 0 and barsToCompress[barIndex] or barsToCompress
			local myBar = CSPS.compressQS(barsToCompress, barIndex)
			local myPoints = 0
			local _, nameCat = CSPS.getQSProfileCategoryName(nil, barIndex or 0)
			myName = string.format("%s: %s", myName, nameCat)
			myProfile = {name = myName, discipline = CSPS.subProfileDiscipline,  hbComp = myBar, points = myPoints, cat = barIndex, isNew = true}
			addSubProfile(myProfile, myType)
		end
		
		if qsBarIndex ~= nil then addQSProfile(qsBarIndex) return end
		
		ClearMenu()
		AddCustomMenuItem(GS(SI_INVENTORY_WALLET_ALL_FILTER), function() addQSProfile(nil) end)
		AddCustomMenuItem("-", function() end)
		for barIndex, barCategory in pairs(CSPS.qsBarCategories) do
			AddCustomMenuItem(GS("SI_HOTBARCATEGORY", barCategory), function() addQSProfile(barIndex) end)
		end
		ShowMenu()
		
		return
	elseif profileCatByType[myType] == PROFILE_CATEGORY_SK then
		local function addSkProfile(doSkills, doHb, doSubclasses)
			myPoints = doSkills and CSPS.skillTable.points or 0
			myBar = doSkills and CSPS.compressLists() or nil
			if myBar and doSubclasses then myBar.subclasses = true end
			local actionBar = doHb and CSPS.hbCompress(CSPS.hbTables) or nil
			myProfile = {name = myName, discipline = CSPS.subProfileDiscipline,  hbComp = myBar, actionBar = actionBar, points = myPoints, isNew = true}
			return addSubProfile(myProfile,  myType)
		end
		if addonName then 
			return addSkProfile(true, false, true) -- doSkills, doHb, doSubclasses
		end
		ClearMenu()
		AddCustomMenuItem(string.format("%s / %s", GS(SI_CHARACTER_MENU_SKILLS), GS(SI_INTERFACE_OPTIONS_ACTION_BAR)), function() addSkProfile(true, true, true) end)
		AddCustomMenuItem(string.format("%s / %s (%s)", GS(SI_CHARACTER_MENU_SKILLS), GS(SI_INTERFACE_OPTIONS_ACTION_BAR), GS(CSPS_IgnoreSubClasses)), function() addSkProfile(true, true, false) end)
		
		AddCustomMenuItem("-", function() end)
		AddCustomMenuItem(GS(SI_CHARACTER_MENU_SKILLS), function() addSkProfile(true, false, true) end)
		AddCustomMenuItem(string.format("%s (%s)", GS(SI_CHARACTER_MENU_SKILLS), GS(CSPS_IgnoreSubClasses)), function() addSkProfile(true, false, false) end)
		AddCustomMenuItem(GS(SI_INTERFACE_OPTIONS_ACTION_BAR), function() addSkProfile(false, true) end)
		
		ShowMenu()
		return
	end
			
	if myType == PROFILE_TYPE_CP_HOTBARS then 
		myProfile = {name = GS(CSPS_Txt_NewProfile2), discipline = CSPS.subProfileDiscipline, hbComp = myBar, isNew = true}
		ClearMenu()
		AddCustomMenuItem(GS(SI_CURRENCYLOCATION0), function() addSubProfile(myProfile, PROFILE_TYPE_CP_HOTBARS) end) -- character
		AddCustomMenuItem(GS(SI_CURRENCYLOCATION3), function() addSubProfile(myProfile, PROFILE_TYPE_CP_HOTBARS_ACCOUNT) end)  -- account
		ShowMenu()
		return		
	elseif myType > PROFILE_TYPE_CP_HOTBARS then -- not cp, it will never be PROFILE_TYPE_CP_HOTBARS_ACCOUNT (which would be higher)
		myProfile = {name = myName, discipline = CSPS.subProfileDiscipline,  hbComp = myBar, points = myPoints, isNew = true} -- myBar can be quickslots etc
	else --cp
	
		ClearMenu()
		
		AddCustomMenuItem(GS(CSPS_Static), function() 
			myProfile = {name = myName, discipline = CSPS.subProfileDiscipline, points = myPoints, cpComp = myTable, hbComp = myBar, isNew = true}
			addSubProfile(myProfile,  myType)
		end)
		AddCustomMenuItem(GS(CSPS_Dynamic), function() 
			myProfile = {name = myName, discipline = CSPS.subProfileDiscipline, points = "(dynamic)", cpComp = myTable, hbComp = myBar, isNew = true}
			addSubProfile(myProfile,  myType)
		end)
		local menuItemControl = ZO_Menu.items[#ZO_Menu.items].item 
		menuItemControl.onEnter = function() ZO_Tooltips_ShowTextTooltip(menuItemControl, RIGHT, GS(CSPS_Tooltip_DynamicProfile)) end
		menuItemControl.onExit = function() ZO_Tooltips_HideTextTooltip() end
		
		ShowMenu()
		return
	end
	
	addSubProfile(myProfile,  myType)
	
end

local function subProfileRenameGo(newName, myId, myType)
	if newName == "" then return end
	local myProfile = getProfileByTypeAndId(myType, myId)
	if myProfile then
		myProfile.name = newName
		CSPS.subProfileList:RefreshData()
	end
end

function CSPS.subProfileRename(myId, myType)
	local myName = getSubProfileName(myId, myType)
	if not myName then return end
	
	ZO_Dialogs_ShowDialog(CSPS.name.."_TextInputDiag", 
		{confirmFunc = function(txt) if not txt or txt == "" then return end subProfileRenameGo(txt, myId, myType) end},
		{mainTextParams = {zo_strformat(GS(CSPS_MSG_RenameProfile), myName, "")}, initialEditText = myName})
end



function CSPS.subProfileSave(myId, myType)
	local myName = getSubProfileName(myId, myType)
	if not myName then return end
	local profileToSave = getProfileByTypeAndId(myType, myId, nil)
	if profileToSave.points == "(dynamic)" then  CSPS.subProfileSaveGo(myId, myType) return  end
	ZO_Dialogs_ShowDialog(CSPS.name.."_OkCancelDiag", 
		{returnFunc = function() CSPS.subProfileSaveGo(myId, myType)  end},  
		{mainTextParams = {zo_strformat(GS(CSPS_MSG_ConfirmSave), myName, "")}, titleParams = {GS(CSPS_MyWindowTitle)}})
end

local function skillProfileSaveGo(myId, myType, profileToSave)

	profileToSave.points = profileToSave.hbComp and CSPS.skillTable.points or 0
	local usesSubClasses = profileToSave.hbComp and profileToSave.hbComp.subclasses or false
	profileToSave.hbComp = profileToSave.hbComp and CSPS.compressLists()
	profileToSave.hbComp.subclasses = usesSubClasses
	profileToSave.actionBar = profileToSave.actionbar and CSPS.hbCompress(CSPS.hbTables)
	profileToSave.lastSaved = os.time()

	CSPS.subProfileList:RefreshData()	
end

local function gearProfileSaveGo(myId, myType, profileToSave)
	local gear, gearUnique, numberOfItems = CSPS.buildGearString()
	if not gear and not gearUnique then return end
	profileToSave.gear = gear
	profileToSave.points = numberOfItems

	profileToSave.gearUnique = gearUnique
	profileToSave.lastSaved = os.time()

	CSPS.subProfileList:RefreshData()	
end

local function quickslotSaveGo(myId, myType, profileToSave)
	local hbCat = profileToSave.cat or 0
	profileToSave.points = hbCat
	local barsToCompress = CSPS.getQsBars()
	barsToCompress = hbCat ~= 0 and barsToCompress[hbCat] or barsToCompress
	profileToSave.hbComp = CSPS.compressQS(barsToCompress, hbCat ~= 0 and hbCat)
	profileToSave.lastSaved = os.time()

	CSPS.subProfileList:RefreshData()
end

local function outfitSaveGo(myId, myType, profileToSave)
	profileToSave.outfitComp = CSPS.outfits.compress()
	profileToSave.lastSaved = os.time()
	CSPS.subProfileList:RefreshData()
end

local function cpSaveGo(myId, myType, profileToSave)
	local myTable = {}
	local myPoints = 0
	if profileToSave.points == "(dynamic)" then 
		myPoints = "(dynamic)"
		local oldValues = {}
		local sortedList = {SplitString(";", profileToSave.cpComp)}
		for _, entry in ipairs(sortedList) do
			local cpId, cpValue = SplitString("-", entry)
			oldValues[tonumber(cpId)] = tonumber(cpValue)
		end
		for skillId, skillData in pairs (cp.table) do
			if skillData.discipline == CSPS.subProfileDiscipline then 
				if (not oldValues[skillId] or skillData.value > oldValues[skillId]) and skillData.value > 0 then
					table.insert(sortedList,  string.format("%s-%s", skillId, skillData.value))
				end
			end
		end
		
		myTable = table.concat(sortedList, ";")
		
	elseif not cpHotBarProfileTypes[myType] then
		for i, skillData in pairs (cp.table) do
			if skillData.discipline == CSPS.subProfileDiscipline then 
				myTable[i] = skillData 
				myPoints = myPoints + skillData.value
			end
		end
		
		myTable = cp.compress(myTable)
	end
	local myBar = cp.singleBarCompress(cp.bar[CSPS.subProfileDiscipline])
	profileToSave.hbComp = myBar
	
	if myType ~= 5 then
		profileToSave.points = myPoints
		profileToSave.cpComp = myTable
	end
	CSPS.subProfileList:RefreshData()
end

function CSPS.subProfileSaveGo(myId, myType)
	local profileToSave = getProfileByTypeAndId(myType, myId, nil)
	local savingFunctions = {
		[PROFILE_CATEGORY_CP] = cpSaveGo,
		[PROFILE_CATEGORY_QS] = quickslotSaveGo,
		[PROFILE_CATEGORY_SK] = skillProfileSaveGo,
		[PROFILE_CATEGORY_GEAR] = gearProfileSaveGo,
		[PROFILE_CATEGORY_OUTFIT] = outfitSaveGo,
	}
	savingFunctions[profileCatByType[myType]](myId, myType, profileToSave)	
end

local originalRowColorFunction = subProfileCLASS.GetRowColors
subProfileCLASS.GetRowColors = function(self, data, mouseIsOver, control)
	local textColor, iconColor = originalRowColorFunction(self, data, mouseIsOver, control)
	--if data.discipline and profileCatByDiscipline[data.discipline] ~= PROFILE_CATEGORY_CP then -- not mouseIsOver and 
		-- iconColor = CSPS.cpColors[data.discipline]
	--	iconColor = nil
	--end
	return textColor, nil
end

function CSPS.setSubProfileType(myType, forceRefresh)
	CSPSWindowSubProfilesOpenCraftingList:SetHidden(CSPS.subProfileDiscipline ~= PROFILE_DISCIPLINE_GEAR)
	if myType == CSPS.subProfileType and not forceRefresh then return end
	if myType == PROFILE_TYPE_CP_HOTBARS_ACCOUNT then myType = PROFILE_TYPE_CP_HOTBARS end
	if myType ~= nil then 
		if myType == PROFILE_TYPE_CP_IMPORT then
			if CSPS.savedVariables.settings.formatImpExp ~= string.format("txtCP2_%d", CSPS.subProfileDiscipline) then
				CSPSWindowImportExportSrcList.comboBox:SetSelectedItem(GetString("CSPS_ImpEx_TxtCP2_", CSPS.subProfileDiscipline))
				CSPS.toggleImpExpSource(string.format("txtCP2_%d", CSPS.subProfileDiscipline))
			end
			CSPS.toggleImportExport(true)
			CSPS.showElement("cpProfiles", false)
			return
		end
		CSPS.subProfileType = myType
	end
		
	if profileCatByDiscipline[CSPS.subProfileDiscipline] ~= profileCatByType[CSPS.subProfileType] then
		local addMe = firstTypeOfCategory[profileCatByType[CSPS.subProfileType]] == CSPS.subProfileType and 0 or 1	
		CSPS.subProfileType = firstTypeOfCategory[profileCatByDiscipline[CSPS.subProfileDiscipline]] + addMe
	end
	
	myType = CSPS.subProfileType
	
	CSPSWindowSubProfilesCPProfilePlus:SetHidden(nonCustomTypes[myType])
	
	local showKeybinds = typesWithKeybinds[myType]
	
	CSPSWindowSubProfilesHeaderPoints:SetText(showKeybinds and GS(CSPS_CPP_Hotkey) or GS(CSPS_CPP_Points))
	CSPSWindowSubProfilesHeaderPoints:SetHorizontalAlignment(showKeybinds and 0 or 1)
	CSPSWindowSubProfilesHeaderHotkey:SetHidden(not showKeybinds)
	CSPSWindowSubProfilesHeaderPoints:SetWidth(showKeybinds and 59 or 84)
	CSPSWindowSubProfilesHeaderHotkey:SetWidth(showKeybinds and 25 or 0)
	
	CSPSWindowSubProfilesHeaderName:SetWidth( myType == PROFILE_TYPE_CP_PRESET and 200 or 342)
	CSPSWindowSubProfilesHeaderRole:SetHidden(myType ~= PROFILE_TYPE_CP_PRESET)
	CSPSWindowSubProfilesHeaderSource:SetHidden(myType ~= PROFILE_TYPE_CP_PRESET)
	CSPSWindowSubProfilesRoleFilter:SetHidden(myType ~= PROFILE_TYPE_CP_PRESET)
	CSPSWindowSubProfilesLblStrictOrder:SetHidden(myType ~= PROFILE_TYPE_CP_PRESET)
	CSPSWindowSubProfilesChkStrictOrder:SetHidden(myType ~= PROFILE_TYPE_CP_PRESET)
	if myType == PROFILE_TYPE_CP_PRESET and not CSPSWindowSubProfilesRoleFilter.comboBox then setupRoleFilterCombo() end

	local cppTypes = {"CustomAcc", "CustomChar", "ImportFromText", "Presets", "BarsOnly"}
	for i, v in pairs(cppTypes) do
		local myBtn = CSPSWindowSubProfiles:GetNamedChild(v)
		local addToIndex = firstTypeOfCategory[profileCatByDiscipline[CSPS.subProfileDiscipline]] - 1
		
		if profileCatByDiscipline[CSPS.subProfileDiscipline] ~= PROFILE_CATEGORY_CP and i > 2 then
			myBtn:SetHidden(true)
			myBtn:SetWidth(0)
		else
			myBtn:SetHidden(false)
			myBtn:SetWidth(100)
			local myBG = myBtn:GetNamedChild("BG")
			local r,g,b = CSPS.cpColors[CSPS.subProfileDiscipline]:UnpackRGB()
			if i + addToIndex == myType then myBG:SetCenterColor(r,g,b, 0.4) else myBG:SetCenterColor(0.0314, 0.0314, 0.0314) end
		end
	end
	CSPSWindowSubProfilesCPProfilePlus:SetHandler("OnClicked", function() CSPS.subProfilePlus(myType) end)
	if not CSPS.subProfileList then
		CSPS.subProfileList = subProfileCLASS:New(CSPSWindowSubProfiles)
	else
		CSPS.subProfileList:RefreshData()
	end
	CSPS.subProfileList:FilterScrollList()
	CSPS.subProfileList:SortScrollList()
end

function CSPS.SubProfileListRowMouseExit( control )
	CSPS.subProfileList:Row_OnMouseExit(control)
	if control.data then ZO_Tooltips_HideTextTooltip() end
end

function CSPS.SubProfileListRowMouseEnter(control)
	CSPS.subProfileList:Row_OnMouseEnter(control)
end

local function loadDynamicCP(myList, mySlotted, myBase, discipline)
	if myList == nil then return end
	local myBase = myBase or {}
	local mySlotted = mySlotted or {}
	local i = 1
	local remainingPoints = GetNumSpentChampionPoints(GetChampionDisciplineId(discipline)) + GetNumUnspentChampionPoints(GetChampionDisciplineId(discipline))
	
	local strictOrder = CSPS.savedVariables.settings.strictOrder

	cp.resetTable(discipline)
	while i <= #myList and remainingPoints > 0 do
		local skillData = cp.table[myList[i][1]]
		if skillData and skillData.unlocked then
			if remainingPoints >= myList[i][2] - skillData.value then
				remainingPoints = remainingPoints + skillData.value
				skillData.value = math.min(myList[i][2], skillData.maxValue)
				cp.updateUnlock(discipline)
				remainingPoints = remainingPoints -  skillData.value
			else
				cspsD("Not enough points for "..myList[i][1])
				if skillData.jumpPoints then
					local myJumpPoint = 0
					for j, w in ipairs(skillData.jumpPoints) do
						if w <= remainingPoints + skillData.value then myJumpPoint = w else break end
					end
					if myJumpPoint > skillData.value then
						remainingPoints = remainingPoints + skillData.value
						skillData.value = myJumpPoint
						cp.updateUnlock(discipline)
						remainingPoints = remainingPoints - myJumpPoint
					end
				else
					skillData.value = skillData.value + remainingPoints
					remainingPoints = 0
					if skillData.value > skillData.maxValue then
						remainingPoints = skillData.value - skillData.maxValue
						skillData.value = skillData.maxValue
					end
				end
				if strictOrder then break end
			end
		else
			cspsD("Not found:"..myList[i][1])
		end
		if remainingPoints <= 0 then cspsD("No points left") end
		i = i +1
	end
	if remainingPoints > 0 then
		for i, v in pairs(myBase) do
			local skillData = cp.table[v]
			if skillData.maxValue > skillData.value then
				skillData.value = skillData.value + remainingPoints
				if skillData.value > skillData.maxValue  then
					remainingPoints = skillData.value - skillData.maxValue
					skillData.value = skillData.maxValue
				else
					remainingPoints = 0
					break
				end
			end
		end
	end
	cp.bar[discipline] = {}
	for i, v in pairs(mySlotted) do
		table.insert(cp.bar[discipline], cp.table[v])
	end
	cp.recheckHotbar(discipline)
	cp.updateSidebarIcons(discipline)		
	cp.updateSlottedMarks()
	CSPS.unsavedChanges = true
	changedCP = true
	CSPS.showElement("save", true)
	CSPS.toggleCP(discipline, true)
	cp.updateSum(discipline)
	cp.updateClusterSum()
	 CSPS.refreshTree()
	CSPS.showElement("cpProfiles", false)
end

local function loadCPProfile(myType, myId, discipline)
	local myProfile = getProfileByTypeAndId(myType, myId, nil)
	local cp2Comp = myProfile.cpComp or "" 
	local hbComp = myProfile.hbComp or "" 
	if not cpHotBarProfileTypes[myType] then
		if myProfile.points == "(dynamic)" then
			local myAuxList = {SplitString(";", cp2Comp)}
			local myList = {}
			for i, v in ipairs(myAuxList) do
				local oneId, oneValue = SplitString("-", v)
				table.insert(myList, {tonumber(oneId), tonumber(oneValue)})
			end
			hbComp = {SplitString(",", hbComp)}
			for i, v in pairs(hbComp) do
				hbComp[i] = tonumber(v)
			end
			loadDynamicCP(myList, hbComp, {}, discipline)
			return
		end
		cp.extract(cp2Comp, discipline) 
	end
	cp.bar[discipline] = cp.singleBarExtract(hbComp)
	cp.updateUnlock(discipline)
	cp.recheckHotbar(discipline)
	cp.updateSidebarIcons(discipline)
	cp.updateSlottedMarks()
	CSPS.toggleCP(discipline, true)
	CSPS.unsavedChanges = true
	changedCP = true
	CSPS.showElement("save", true)
	 CSPS.refreshTree()
	CSPS.showElement("cpProfiles", false)
end

CSPS.loadCPProfile = loadCPProfile

local function loadCPPreset(myType, myId, discipline, suppressInfoAlert)
	local myPreset = {}
	if myType == 4 then 
		myPreset = CSPS.CPPresets[myId]
	else
		return false
	end
	if myPreset.points == "(dynamic)" then loadDynamicCP(myPreset.preset, myPreset.slotted, myPreset.basestatsToFill, myPreset.discipline) end
	local myMessage = ""
	if myPreset.switch then
		myMessage = zo_strformat(GS(CSPS_MSG_SwitchCP), cpColors[myPreset.discipline]:ToHex(), GetChampionSkillName(myPreset.switch))
	end
	if myPreset.situational and #myPreset.situational > 0 or myPreset.aoe or myPreset.penetration or myPreset.offBalance or myPreset.crit then
		local mySituationals = {}
		
		local function addSublist(subList)
			--local tempSubList = {}
			for i, v in pairs(subList) do 
				local myIcon = cp.useCustomIcons and cp.table[v].icon or "esoui/art/champion/champion_icon_32.dds"
				table.insert(mySituationals, zo_strformat("   |t24:24:<<1>>|t |c<<2>>'<<C:3>>'|r", myIcon, cpColors[myPreset.discipline]:ToHex(), GetChampionSkillName(v)))
			end
		end
		
		if myPreset.situational and #myPreset.situational > 0 then
			addSublist(myPreset.situational)
		end
		if myPreset.aoe then
			table.insert(mySituationals, string.format("%s:", GS(CSPS_AOE)))
			addSublist(myPreset.aoe)
		end
		if myPreset.penetration then
			table.insert(mySituationals, zo_strformat("<<C:1>> < 18200:", GS(SI_DERIVEDSTATS27)))
			addSublist(myPreset.aoe)
		end
		if myPreset.offBalance then
			table.insert(mySituationals, string.format("%s > %s%%:", GS(CSPS_OffBalance), myPreset.offBalanceUp))
			addSublist(myPreset.offBalance)
		end
		if myPreset.crit then
			table.insert(mySituationals, string.format("%s < 125%%:", GS(CSPS_CRIT)))
			addSublist(myPreset.crit)
		end
				
		mySituationals = table.concat(mySituationals, "\n")
		if myMessage ~= "" then
			myMessage = string.format("%s\n\n%s\n%s", myMessage, GS(CSPS_MSG_SituationalCP), mySituationals)
		else
			myMessage = string.format("%s\n%s", GS(CSPS_MSG_SituationalCP), mySituationals)
		end	
	end
	if myMessage ~= "" and not suppressInfoAlert and not CSPS.savedVariables.settings.suppressCpPresetNotifications then
		ZO_Dialogs_ShowDialog(CSPS.name.."_OkDiag", {},  {mainTextParams = {myMessage}, titleParams = {GS(CSPS_MyWindowTitle)}})
	end
	return myPreset.old
end

CSPS.loadCPPreset = loadCPPreset

local function showPresetProfileContent(control, myType, myId, discipline, shift, ctrl)
	if not myId or not myType or not discipline then return end
	local myList = {}
	local myName = ""
	
	myName = CSPS.CPPresets[myId].name
	myList = CSPS.CPPresets[myId].preset
	
	InitializeTooltip(InformationTooltip, control, LEFT)

	InformationTooltip:AddLine(myName , "ZoFontWinH2")
	ZO_Tooltip_AddDivider(InformationTooltip)
	
	local myTooltip = {}
	local unformattedList = {}
	local values = {}
	local maxedOut = {}
	for i, v in pairs(myList) do
		values[v[1]] = v[2]
		table.insert(myTooltip, zo_strformat("|c<<1>><<C:2>>|r|cffffff(<<3>>)|r", cpColors[discipline]:ToHex(), GetChampionSkillName(v[1]), v[2]))
		table.insert(unformattedList, zo_strformat("<<C:1>>: <<2>>/<<3>> (ID <<4>>)", GetChampionSkillName(v[1]), v[2], GetChampionSkillMaxPoints(v[1]), v[1]))
		if GetChampionSkillMaxPoints(v[1]) == v[2] then maxedOut[v[1]] = true end
	end
	InformationTooltip:AddLine(table.concat(myTooltip, ", "))
	if shift or ctrl then
		if shift and ctrl then
			for i, skillData in pairs (cp.table) do
				if skillData.discipline == discipline then
					if not values[i] then
						table.insert(unformattedList, zo_strformat("0/<<2>>: <<C:1>> (ID <<3>>)", GetChampionSkillName(i), GetChampionSkillMaxPoints(i), i))
					elseif not maxedOut[i] then
						table.insert(unformattedList, zo_strformat("Below <<2>>: <<C:1>> (ID <<3>>)", GetChampionSkillName(i), GetChampionSkillMaxPoints(i), i))
					end
				end
			end
		end
		CSPS.toggleImportExport(true)
		CSPSWindowImportExportTextEdit:SetText( table.concat(unformattedList, "\n"))
	end
end

function CSPS.showQuickSlotProfileTT(control, myType, myId)
	local theName = getSubProfileName(myId, myType)
	
	local compressedProfile = getProfileByTypeAndId(myType, myId, PROFILE_CATEGORY_QS)
	
	if not compressedProfile then return end
	
	local qsProfile, qsActive = CSPS.extractQS(compressedProfile.hbComp)
	
	if not qsProfile or type(qsProfile) ~= "table" then return end
	
	InitializeTooltip(InformationTooltip, control, LEFT)
	InformationTooltip:AddLine(theName , "ZoFontWinH3")

	ZO_Tooltip_AddDivider(InformationTooltip)
	
	CSPS.addQsBarsToTooltip(qsProfile, qsActive)
	
	addConnectionToTooltip(myType, myId, 4)
end

function CSPS.loadConnectedQuickSlots()
	local myProfile = CSPS.currentProfile == 0 and CSPS.currentCharData or CSPS.profiles[CSPS.currentProfile]
	if not myProfile.connections or not myProfile.connections[4] then return end
	local myType, myId = SplitString("-", myProfile.connections[4])
	myType = tonumber(myType)
	myId = tonumber(myId)
	loadQuickSlots(myType, myId)
end

local function connectToProfile(myType, myId, discipline)
	local myProfile = CSPS.currentProfile == 0 and CSPS.currentCharData or CSPS.profiles[CSPS.currentProfile]
	myProfile.connections = myProfile.connections or {}
	if myProfile.connections[discipline] == string.format("%s-%s", myType, myId) then 
		myProfile.connections[discipline] = nil 
	else
		myProfile.connections[discipline] = string.format("%s-%s", myType, myId)
	end
	CSPS.subProfileList:RefreshVisible()
	CSPS.refreshTree()
end

local function loadSkillProfile(myType, myId, _)
	local profileTypeLists = getProfileTypeLists(false, false)
	local myProfile = profileTypeLists[myType] and profileTypeLists[myType][myId]
	if not myProfile or not myProfile.actionBar and (not myProfile.hbComp or not myProfile.hbComp.prog or not myProfile.hbComp.pass) then return end
	
	if myProfile.hbComp then
		local morphs, upgrades, _, crafted, styles, subclasses = CSPS.skTableExtract(myProfile.hbComp.prog, myProfile.hbComp.pass, false, false, myProfile.hbComp.crafted, myProfile.hbComp.styles, myProfile.hbComp.subclasses, false, myProfile.hbComp.scribeStyleSubclass)
		if not myProfile.hbComp.subclasses then subclasses = nil end
		CSPS.populateSkills(morphs, upgrades, true, crafted, styles, subclasses) -- 3rd: true = don't reset the lists beforehand
	end
	
	if myProfile.actionBar then
		CSPS.hbTables = CSPS.hbExtract(myProfile.actionBar)
		CSPS.hbLinkToSkills(CSPS.hbTables)
		CSPS.hbPopulate()
	end
	
	CSPS.refreshTree()
end

local function loadGearProfile(myType, myId, _)
	local profileTypeLists = getProfileTypeLists(false, false)
	local myProfile = profileTypeLists[myType] and profileTypeLists[myType][myId]
	if not myProfile or not myProfile.gear and not myProfile.gearUnique then return end
	CSPS.setTheGear(CSPS.extractGearString(myProfile.gear, myProfile.gearUnique))
	CSPS.refreshTree()
end

local function loadOutfitProfile(myType, myId, _)
	local profileTypeLists = getProfileTypeLists(false, false)
	local myProfile = profileTypeLists[myType] and profileTypeLists[myType][myId]
	if not myProfile or not myProfile.outfitComp then return end
	CSPS.outfits.extract(myProfile.outfitComp)
	CSPS.refreshTree()	
end

local loadingFunctions = {
	[PROFILE_CATEGORY_CP] = function(myType, myId, myDiscipline) 
		if nonCustomTypes[myType] then 
			loadCPPreset(myType, myId, myDiscipline) 
		else 
			loadCPProfile(myType, myId, myDiscipline) 
		end 
	end,
	[PROFILE_CATEGORY_QS] = loadQuickSlots,
	[PROFILE_CATEGORY_SK] = loadSkillProfile,
	[PROFILE_CATEGORY_GEAR] = loadGearProfile,
	[PROFILE_CATEGORY_OUTFIT] = loadOutfitProfile,
}


function CSPS.SubProfileListRowMouseUp( control, button, upInside, ctrl, alt, shift)	
	if not upInside then return end
	local myType = control.data.type
	local myId = control.data.myId
	local myDiscipline = control.data.discipline
	
	local myShiftKey = CSPS.savedVariables.settings.jumpShiftKey or 7
	myShiftKey = myShiftKey == 7 and shift or myShiftKey == 4 and ctrl or myShiftKey == 5 and alt or false
	
	if button == 1 then
		if myShiftKey and profileCatsThatCanBeConnected[profileCatByDiscipline[myDiscipline]] then
			if cpHotBarProfileTypes[myType] then return end
			connectToProfile(myType, myId, myDiscipline)
			return
		end	
				
		loadingFunctions[profileCatByType[myType]](myType, myId, myDiscipline)		
	elseif myType == PROFILE_TYPE_CP_PRESET then
		showPresetProfileContent(control, myType, myId, myDiscipline, shift, ctrl)
	end

end


-- switch CP when entering a zone

local initActivated = false
function CSPS.onPlayerActivated() 
	if not initActivated then
		CSPS.initConnect()
		initActivated = true
	end
	local zoneId = GetUnitWorldPosition("player")
	if zoneId == CSPS.lastZoneID then return end
	CSPS.lastZoneID = zoneId
	CSPS.locationBinding(zoneId)
end

-- Here come the functions open for wizards and other addons. others can be used but these ones should be more user friendly

local wwFunctions = {}

function wwFunctions.addSubProfile(myType, myDiscipline, addonName)
	if myType == PROFILE_TYPE_BUILD then
		CSPS.populateTable(false)
		cp.readCurrent()
		return CSPS.profilePlus()
	end
	if myDiscipline then CSPS.showSubProfileDiscipline(myDiscipline, true) end -- for CP the discipline has to be set inside the addon
	-- refresh (todo: only refresh category? not how CSPS works atm)
	CSPS.populateTable(false)
	cp.readCurrent()
	return CSPS.subProfilePlus(myType, nil, addonName)
end

function wwFunctions.getProfileTypes()
	return {
		COMPLETE_BUILD = PROFILE_TYPE_BUILD,
		CP_ACCOUNT = PROFILE_TYPE_CP_ACCOUNT,
		CP_CHARACTER = PROFILE_TYPE_CP_CHAR,
		CP_PRESET = PROFILE_TYPE_CP_PRESET,
		SKILLS_ACCOUNT = PROFILE_TYPE_SK_ACCOUNT,
		SKILLS_CHAR = PROFILE_TYPE_SK_CHAR,
	}	
end

function wwFunctions.getProfileDisciplines()
	return {
		cp_green = PROFILE_DISCIPLINE_CP_GREEN, 
		cp_blue = PROFILE_DISCIPLINE_CP_BLUE, 
		cp_red = PROFILE_DISCIPLINE_CP_RED, 
		-- PROFILE_DISCIPLINE_QUICKSLOTS, 
		skills = PROFILE_DISCIPLINE_SKILLS, 
		-- PROFILE_DISCIPLINE_GEAR, 
		-- PROFILE_DISCIPLINE_OUTFIT 
	}
end

function wwFunctions.getSubProfileList(myType)
	if myType == PROFILE_TYPE_BUILD then return CSPS.profiles end
	return CSPS.getProfileListByType(myType)
end

function wwFunctions.loadAndApplySubProfiles(listOfProfilesToApply) 
	-- listOfProfilesToApply contains entrys {myType, myDiscipline, myId}
	-- only give the discipline for cp profiles
	
	-- refresh the category
	local applyCP = false
	local oldApplyCP = CSPS.applyCPc -- don't need the toggle-function because it will be reversed afterwards
	CSPS.applyCPc = {false, false, false}
	local applySk = false
	local applyAttributes = false
	
	for _, profileData in pairs(listOfProfilesToApply) do
		local myType, myDiscipline, myId = unpack(profileData) 
		if myType == PROFILE_TYPE_BUILD then
			if not CSPS.profiles[myId] then return end
			CSPS.selectProfile(myId)
			CSPS.loadBuild()
			applySk = true
			CSPS.applyCPc = {true, true, true}
			applyAttributes = true
			applyCP = true
		else	
			local myCat = profileCatByType[myType]
			if myCat == PROFILE_CATEGORY_CP then
				if myDiscipline then CSPS.showSubProfileDiscipline(myDiscipline, true) end -- for CP the discipline has to be set inside the addon
				applyCP = true
				CSPS.applyCP [myDiscipline] = true	
			end
			loadingFunctions[myCat](myType, myId, myDiscipline)
		end
	end
	
	local function afterSk(skSuccess)
		local function afterAttr()		
			if applyCP then
				cp.applyGo(true, true)
				CSPS.applyCPc = oldApplyCP
			end
		end		
		if applyAttributes then
			zo_callLater(function() CSPS.applyAttr(true, afterAttr) end, 420)
		else
			afterAttr()
		end
	end
	if applySk then
		CSPS.applySkills(true, function() afterSk(true) end, function() afterSk(false) end,  true) -- skipDiag, callOnSuccess, callOnFail, ignoreStyles
	else
		afterSk(false)
	end
	
	
	
end


CSPS.wwFunctions = wwFunctions
