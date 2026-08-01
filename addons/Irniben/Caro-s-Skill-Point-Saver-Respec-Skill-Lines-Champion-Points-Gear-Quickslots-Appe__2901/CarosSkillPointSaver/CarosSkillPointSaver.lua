CSPS = {
	name = "CarosSkillPointSaver",
	tabEx = false,
	skillTable = {},
	applyCP = false,
	applyCPc = {false, false, false},
	cp = {table = {}, bar = {{},{},{}}, sums = {0,0,0}}, -- will be filled in csps_cp2.lua
	cpProfiles = {},
	cpColors = {
		ZO_ColorDef:New(0.65098, 0.84706, 0.32157), -- 166/255, 216/255, 82/255, green cp
		ZO_ColorDef:New(0.36863, 0.74118, 0.90588), --94/255, 189/255, 231/255 , blue cp
		ZO_ColorDef:New(0.870588, 0.396078, 0.192157), --222/255, 101/255, 49/255 , red cp
		ZO_ColorDef:New(0.83137, 0.196078, 0.87451), --212/255, 50/255, 223/255	-- quickslots (purple)
		ZO_ColorDef:New(0.784314, 0.635294, 0.392157), --(200/255, 162/255, 100/255 -- skills (tan)
		ZO_ColorDef:New(0.337255, 0.529412, 0.427451), -- gear 86, 135, 109 --gear 
		ZO_ColorDef:New(56/255, 126/255, 90/255), -- outfits 76,136,50 
	},
	colors = {
		white = ZO_ColorDef:New(1,1,1),
		green = ZO_ColorDef:New(0.1,0.7,0.1),
		red = ZO_ColorDef:New(0.84, 0.12, 0.12),
		orange = ZO_ColorDef:New(1, 0.24, 0),
		gray = ZO_ColorDef:New(0.21, 0.21, 0.21),
	},
	cp2ColorsA = {{70/255,107/255,7/255}, {23/255,101/255,135/255}, {166/255,58/255,11/255}},
	cpAutoOpen = false,
	cpImportCap = false,
	cpImportReverse = false,
	useCustomIcons = false,
	hbTables = {{},{}, {}},
	attrPoints = {0, 0, 0},
	unlockedCP = true,
	kaiserFranz = 1,
	subProfileDiscipline = 1,
	subProfileType = 1,
	ec = {correct = 1, wrongMorph = 2, rankHigher = 3, skillLocked = 4, rankLocked = 5, morphLocked = 6, lineNotActive = 7, craftedLocked = 8, craftedScriptLocked = 9},
	showHotbar = false,
	bindings = {},
	profiles = {
	},
	currentProfile = 0,
	profileToLoad = 0,
	unsavedChanges = false,
	secSpace = string.char(194, 160),
}

local GS = GetString
local sdm = SKILLS_DATA_MANAGER

local skillTable = CSPS.skillTable
local cspsDoDebug = false

local ec = CSPS.ec
local cp = CSPS.cp


local function anyEntryNotFalse(table1, checkForSubTables)
	if not table1 then return false end
	for i, v in pairs(table1) do
		if v then
			if type(v) == "table" and checkForSubTables then 
				if anyEntryNotFalse(v) then return true end 
			else 
				return true 
			end
		end
	end
	return false
end

local hf = {
	entryInTable = function(table1, entry1)
		for i, v in pairs(table1) do
			if entry1 == v then return true end
		end
		return false
	end,
	tableParamsFit = function(table1, table2, paramList)
		for i, v in pairs(paramList) do
			if table1[v] ~= table2[v] then return false end
		end
		return true
	end,
	anyEntryNotFalse = anyEntryNotFalse,
	anyEntryFalse = function(table1, maxIndex)
		if maxIndex then
			for i=1, maxIndex do
				if not table1[i] then return true end
			end
			return false
		end
		for i, v in pairs(table1) do
			if v == false then return true end
		end
	end,
	getEmptyEntries = function(table1, maxIndex)
		local returnTable = {}
		for i=1, maxIndex do if not table1[i] then table.insert(returnTable, i) end end
		return returnTable
	end,
	fillNumericTable = function(fillTable, maxIndex, fillValue, fillWithEmptyTables, deleteHigher, deleteNonNumeric)
		if deleteHigher or deleteNonNumeric then
			for i, v in pairs(fillTable) do
				if type(i) ~= number then
					if deleteNonNumeric then fillTable[i] = nil end
				else
					if i > maxIndex and deleteHigher then fillTable[i] = nil end
				end
			end
		end
		for i=1, maxIndex do
			if fillTable[i] == nil then fillTable[i] = fillWithEmptyTables and {} or fillValue end
		end
	end,
	ttAddLine = function(text, font, r, g, b)
		if type(r) == "table" then r,g,b = r:UnpackRGB() end
		InformationTooltip:AddLine(text, font or "ZoFontGame", r,g,b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	end,
}

CSPS.helperFunctions = hf

function CSPS.cspsD(...)
	if not cspsDoDebug then return end
	if #{...} == 1 and type((...)) ~= "table" then d(string.format("|c9e0911[CSPS-DEBUG]|r %s", tostring((...)))) return end
	d("|c9e0911[CSPS-DEBUG]:|r")
	d(...)
end

local cspsD = CSPS.cspsD

function CSPS.debug(arg)
	if arg ~= nil then cspsDoDebug = arg else cspsDoDebug = not cspsDoDebug end
	d("|c9e0911[CSPS IS DEBUGGING]:|r"..tostring(cspsDoDebug))
end

local function cspsPost(myMessage, noFormatter)
	if type(myMessage) ~= "table" then 
		myMessage = noFormatter and myMessage or string.format("|c9e0911[CSPS]|r %s", tostring(myMessage))
		CHAT_SYSTEM:AddMessage(myMessage)
		return
	end
	local addFormatter = not noFormatter
	for i, v in pairs(myMessage) do
		cspsPost(v, noFormatter)
	end
end

CSPS.post = cspsPost

function CSPS.isMagOrStam()
	local magStam = 0
	if CSPS.attrPoints[2] == 0 and CSPS.attrPoints[3] == 0 then
		if GetAttributeSpentPoints(2) > GetAttributeSpentPoints(3) then
			magStam = 1
		elseif GetAttributeSpentPoints(3) > GetAttributeSpentPoints(2) then
			magStam = 2
		end
	else
		if CSPS.attrPoints[2] > CSPS.attrPoints[3] then
			magStam = 1
		elseif CSPS.attrPoints[2] < CSPS.attrPoints[3] then
			magStam = 2
		end
	end
	return magStam
end

function CSPS.moveItem(sourceBag, sourceSlot, destBag, destSlot, stackSize)
	if GetInteractionType() ~= INTERACTION_BANK then return false end
	if IsProtectedFunction("RequestMoveItem") then
		CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, destBag, destSlot or FindFirstEmptySlotInBag(destBag), stackSize or 1)
		return true
	end
	RequestMoveItem(control.retrieveItem[1], sourceBag, sourceSlot, destBag, destSlot or FindFirstEmptySlotInBag(destBag), stackSize or 1)
	return true
end

-- Initializing the addon on load

function CSPS:Initialize()
	local svName= "CSPSSavedVariables"
	local svVersion = 1
	local svNamesSpace = nil
	local currentCharId = GetCurrentCharacterId()
	local svDefaults = {	
		settings = {
			applyCP = false,
		},
		charData = {
			[currentCharId] = {},
		},
	} 
	local svProfile = GetWorldName()
	
	CSPS.canDoGear = LibSets and true or false
	
	CSPS.savedVariables = ZO_SavedVars:NewAccountWide(svName, svVersion, svNamesSpace, svDefaults, svProfile, nil) -- savedvars account wide, server dependent
	-- CSPS.kaiserFranz: id for the emperor skill line (named after emperor Franz, the 52nd of his name)
	if string.lower(GetCVar("Language.2")) ~= "de" then
		_, CSPS.kaiserFranz, _ = GetSkillLineIndicesFromSkillLineId(71)
	end
	
	CSPS.currentCharData = CSPS.savedVariables.charData[currentCharId]
					
				
	CSPS.currentCharData.profiles = CSPS.currentCharData.profiles or {}
	CSPS.currentCharData.bindings = CSPS.currentCharData.bindings or {} -- connections between hotkey-groups and situations etc.
	CSPS.savedVariables.bindings = CSPS.savedVariables.bindings or {}
	
	CSPS.profiles = CSPS.currentCharData.profiles
	CSPS.bindings = CSPS.currentCharData.bindings
	CSPS.bindingsA = CSPS.savedVariables.bindings
	
	CSPS.currentCharData.cpHbProfiles = CSPS.currentCharData.cpHbProfiles  or {}
	CSPS.savedVariables.cpHbProfiles = CSPS.savedVariables.cpHbProfiles  or {}
	
	local mySettings = CSPS.savedVariables.settings
	
	mySettings.moduleExclude = mySettings.moduleExclude or {}
	
	if mySettings.showOutfits ~= nil then -- legacy setting
		mySettings.moduleExclude.outfit = not mySettings.showOutfits 
		mySettings.showOutfits = nil 
	end
	
	CSPS.moduleExclude = {}
	
	for i, v in pairs(mySettings.moduleExclude) do
		CSPS.moduleExclude[i] = v
	end
	
	CSPS.moduleExclude.gear = not CSPS.canDoGear or CSPS.moduleExclude.gear
	
	CSPSWindowBuildGearProfiles:SetHidden(CSPS.moduleExclude.gear)
	if CSPS.moduleExclude.gear then CSPSWindowBuildGearProfiles:SetWidth(0) end
	
	-- if no skills have been saved yet for this char, save everything once
	if CSPS.currentCharData.werte == nil then
		CSPS.populateTable()
		CSPS.saveBuildGo()
	end
		
	-- Hide CP-Option if no Character has reached level 50 yet.
	if GetPlayerChampionPointsEarned() == 0 then 
		CSPS.unlockedCP = false
		CSPS.applyCP = false
	end

	
	CSPS.setupImportExportTextEdit()
	
	local formatImpExp = mySettings.formatImpExp or "hub"
	CSPS.toggleImpExpSource(formatImpExp, true)
	
	mySettings.importExportParts = mySettings.importExportParts or {skills = true, hotbar = true, attributes = true, mundus = true, cp = true, gear = true, quickslots = true}
	CSPS.toggleCPImpExpParts()
	
	CSPS.cpImportCap =  mySettings.cpImportCap or false
	CSPS.cpImportLang = mySettings.cpImportLang or false
	CSPS.cpImportReverse = mySettings.cpImportReverse or false
	
	CSPS.toggleCPCapImport(CSPS.cpImportCap)
	CSPS.toggleCPImportLanguage(CSPS.cpImportLang)
	CSPS.toggleCPReverseImport(CSPS.cpImportReverse)
	
	CSPS.InitLocalText()
			
	cp.CreateTable()
	cp.createList()
	
	if not CSPS.moduleExclude.mundus then
		CSPS.InitializeMundusMenu()
	end
	
	if not CSPS.moduleExclude.role then
		CSPS.InitializeRoleMenu()
	end
	
	CSPS:RestorePosition()
	CSPS.prepareTheTree()
	
	CSPS.currentCharData.cp2hbpHotkeys = CSPS.currentCharData.cp2hbpHotkeys or {}
	CSPS.spHotkeysC = CSPS.currentCharData.cp2hbpHotkeys
	CSPS.savedVariables.spHotkeys = CSPS.savedVariables.spHotkeys or {}
	CSPS.spHotkeysA = CSPS.savedVariables.spHotkeys
	
	if #CSPS.spHotkeysC < 20 then
		for i=1, 20 do
			table.insert(CSPS.spHotkeysC, {})
			if #CSPS.spHotkeysC == 20 then break end
		end
	end
	
	if #CSPS.spHotkeysA < 20 then
		for i=1, 20 do
			table.insert(CSPS.spHotkeysA, {})
			if #CSPS.spHotkeysA == 20 then break end
		end
	end
	
	mySettings.accountWideShiftKey = mySettings.accountWideShiftKey or 7
	
	--CSPS.initConnect() now happens in player activated in subprofiles
	
	CSPS.showElement("modules")

	
	CSPS.toggleStrictOrder(mySettings.strictOrder or false)
	--local cpRemindMe = mySettings.cpReminder or false
	mySettings.autoShowScenes = mySettings.autoShowScenes or {}
	if mySettings.cpAutoOpen ~= nil then 
		mySettings.autoShowScenes["championPerks"] = mySettings.cpAutoOpen
		mySettings.cpAutoOpen = nil
	end
	if mySettings.armoryAutoOpen ~= nil then 
		mySettings.autoShowScenes["armoryKeyboard"] = mySettings.armoryAutoOpen
		mySettings.armoryAutoOpen = nil
	end
	CSPS.registerFragment()
	--CSPS.toggleCPAutoOpen()
	--CSPS.toggleArmoryAutoOpen()
	CSPS.toggleCP(0, mySettings.applyCP and CSPS.unlockedCP)
	mySettings.showHotbar = nil
	
	CSPS.showElement("hotbar", not mySettings.hideHotbar and not CSPS.moduleExclude.skills)
	
	CSPS.toggleCPCustomBar()
	CSPS.toggleCPCustomIcons()
	CSPSWindowBtnApplyAll:SetHidden(not mySettings.showApplyAll)
	
	if not CSPS.moduleExclude.gear then 	
		CSPS.setGearMarkerOption(CSPS.savedVariables.settings.showGearMarkers)
		CSPS.setGearMarkerOptionData(CSPS.savedVariables.settings.showGearMarkerDataBased)
		CSPS.setupGearMarkers()
	end
	
	CSPS.setupLam()
		
	cp.setupZoHooks()
		
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."OnPlayerActivated", EVENT_PLAYER_ACTIVATED, function() CSPS.onPlayerActivated() end)
	EVENT_MANAGER:UnregisterForEvent(CSPS.name.."OnAddOnLoaded", EVENT_ADD_ON_LOADED)
end

function CSPS.OnAddOnLoaded(event, addonName)
	if addonName == CSPS.name then
		EVENT_MANAGER:UnregisterForEvent(CSPS.name.."OnAddOnLoaded", EVENT_ADD_ON_LOADED)
		CSPS:Initialize()
	end
end

-- display the current skills

function CSPS.showBuild(initOpen)
	CSPS.showElement("save", true)
	CSPS.populateTable()
	cp.readCurrent()
	CSPS.hbRead()
	CSPS.hbPopulate()
	CSPS.readCurrentQS()
	CSPS.outfits.read()
	if not CSPS.treeIsReady then CSPS.createTree() end
	
	cp.updateSidebarIcons()
	cp.updateSlottedMarks()
	
	if not CSPS.moduleExclude.gear then
		CSPS.getCurrentGear()
	end
	
	CSPS.refreshTree() 
	CSPS.unsavedChanges = not initOpen
end

function CSPS.saveBuild()
	local myName = GS(CSPS_Txt_StandardProfile)
	if CSPS.currentProfile ~= 0 then myName = CSPS.profiles[CSPS.currentProfile].name end
	local myWarning = not CSPS.savedVariables.settings.suppressSaveOther and (not CSPSWindowSubProfiles:IsHidden()) and GS(CSPS_MSG_NoCPProfiles) or ""
	
	ZO_Dialogs_ShowDialog(CSPS.name.."_OkCancelDiag", 
		{returnFunc = function() CSPS.saveBuildGo()   end},  
		{mainTextParams = {zo_strformat(GS(CSPS_MSG_ConfirmSave), myName, myWarning)}, titleParams = {GS(CSPS_MyWindowTitle)}})
end

function CSPS.saveBuildGo(useAuxProfile)
	local skillTableClean = CSPS.compressLists()
			
	local hbComp = CSPS.hbCompress(CSPS.hbTables)
	local attrComp = CSPS.attrCompress(CSPS.attrPoints)
	local cpComp = cp.compress(cp.table) 
	local cpHbComp = cp.hotBarCompress(cp.bar)
	local gearComp, gearCompUnique = nil
	if  not CSPS.moduleExclude.gear  then
		gearComp, gearCompUnique = CSPS.buildGearString()
	end
	
	local profileToSave = {}
	if useAuxProfile then
		CSPS.currentCharData.auxProfile = CSPS.currentCharData.auxProfile or {}
		profileToSave = CSPS.currentCharData.auxProfile
		profileToSave.profileIndex = CSPS.currentProfile
	elseif	CSPS.currentProfile == 0 then
		profileToSave = CSPS.currentCharData
	else 
		profileToSave = CSPS.profiles[CSPS.currentProfile]
	end

	
	if not useAuxProfile and CSPS.savedVariables.settings.versionHistory then
		profileToSave.history = profileToSave.history or {}
		local backupTable = {
			werte = profileToSave.werte,
			attribute = profileToSave.attribute,
			hbwerte = profileToSave.hbwerte,
			cp2werte = profileToSave.cp2werte,
			cp2hbwerte = profileToSave.cp2hbwerte,
			qs = profileToSave.qs,
			role = profileToSave.role,
			mundus = profileToSave.mundus,
			comp1 = profileToSave.comp1,
			comp2 = profileToSave.comp2,
			gearComp = profileToSave.gearComp,
			gearCompUnique = profileToSave.gearCompUnique,
			outfitComp = profileToSave.outfitComp,
			lastSaved = os.time(),
		}
		table.insert(profileToSave.history, 1, backupTable)
		if #profileToSave.history > CSPS.savedVariables.settings.versionHistory then
			for i=#profileToSave.history,CSPS.savedVariables.settings.versionHistory+1,-1 do
				table.remove(profileToSave.history, i)
			end
		end
	end

	profileToSave.werte = skillTableClean
	
	local outfitComp = not CSPS.moduleExclude.outfit and CSPS.outfits.compress() or "-"
	local qsComp = CSPS.compressQS(CSPS.getQsBars())
	
	local function neS(value) --no empty string
		return value ~= "" and value or "-"
	end
	profileToSave.comp1 = table.concat({neS(attrComp), neS(hbComp),neS(cpComp), neS(cpHbComp), neS(qsComp), CSPS.role or "-", CSPS.currentMundus or "-"}, "#")
	
	profileToSave.attribute = nil --attrComp
	profileToSave.hbwerte = nil --hbComp
	profileToSave.cp2werte = nil --cpComp
	profileToSave.cp2hbwerte = nil --cpHbComp
	profileToSave.qs = nil --qsComp
	profileToSave.role = nil --CSPS.role
	profileToSave.mundus = nil --CSPS.currentMundus
		
	profileToSave.comp2 = table.concat({neS(gearComp), neS(gearCompUnique), neS(outfitComp)}, "#")
	
	profileToSave.gearComp = nil --gearComp
	profileToSave.gearCompUnique = nil --gearCompUnique
	profileToSave.outfitComp = nil --outfitComp
	
	profileToSave.lastSaved = os.time()
	
	CSPS.currentCharData.profiles = CSPS.profiles
	
	if not CSPS.moduleExclude.gear  then 
		CSPS.buildGearMarkerTable()
	end

	CSPS.currentCharData.svApi = GetAPIVersion()
	-- CSPS.currentCharData.myKeys = myKeys
	CSPS.currentCharData["$lastCharacterName"] = ZO_CachedStrFormat(SI_UNIT_NAME, GetRawUnitName('player'))
	CSPS.showElement("load")
	CSPS.unsavedChanges = false
	if CSPSWindowBuildProfiles.comboBox then CSPS.UpdateProfileCombo() end
end


function CSPS.populateTable(doNotFill)
	CSPS.populateAttributes()
	CSPS.getCurrentRole()
	cp.resetTable()
	CSPS.refreshTree()
	--- Read Current Skills
	if #skillTable == 0 then CSPS.createSkillTable() else CSPS.resetSkills() end	
	if not doNotFill then CSPS.readCurrentSkills() end
end


function CSPS.hbCompress(hbTables)
	local hbComp = ""
	local auxHb = {}
	for i=1,3 do
		if hbTables[i] then
			local auxHb1 = {}
			local anySkillsInBar = false
			for j=1,6 do
				if hbTables[i][j] ~= nil then 
					-- auxHb1[j] = table.concat(hbTables[i][j], "-")
					if IsCraftedAbilitySkill(unpack(hbTables[i][j])) then
						auxHb1[j] = "c"..GetCraftedAbilitySkillCraftedAbilityId(unpack(hbTables[i][j]))
					else
						auxHb1[j] = GetSpecificSkillAbilityInfo(hbTables[i][j][1], hbTables[i][j][2], hbTables[i][j][3], 0, 1)
					end
					anySkillsInBar = true
				else
					auxHb1[j] = "-"
				end
			end
			auxHb[i] = table.concat(auxHb1, ",")
			if i == 3 and not anySkillsInBar then auxHb[i] = nil end
		end
	end
	hbComp = table.concat(auxHb, ";")
	return hbComp
end

function CSPS.compressLists()
	local activeAbs, passiveAbs = {{}}, {{}}
	local activeTab, passiveTab = {},{}
	local stylesTab = {}
	
	for skillType, skillTypeData in ipairs(skillTable) do
		for skillLineIndex, skillLineData in ipairs(skillTypeData) do
			for skillIndex, skEntry in ipairs(skillLineData) do
				if skEntry.purchased and not skEntry.craftedId then
					local myId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, skillIndex, not skEntry.passive and skEntry.morph or 0, 1)
					if skEntry.passive and not (skEntry.autoGrant and skEntry.rank == 1) then
						table.insert(passiveAbs[#passiveAbs], string.format("%s:%s", myId, skEntry.rank or 1))
						if #passiveAbs[#passiveAbs] == 100 then table.insert(passiveAbs, {}) end
					elseif not skEntry.passive and not (skEntry.autoGrant and skEntry.morph == 0) then
						table.insert(activeAbs[#activeAbs], string.format("%s:%s", myId, skEntry.morph or 0))
						if #activeAbs[#activeAbs] == 100 then table.insert(activeAbs, {}) end
					end
					if skEntry.styleCollectible and skEntry.styleCollectible ~= 0 then
						table.insert(stylesTab, string.format("%s:%s", myId, skEntry.styleCollectible))
					end
				end
			end
		end
	end
	
	for i, v in pairs(passiveAbs) do passiveTab[string.format("part%s", i)] = table.concat(v, ",") end	
	for i, v in pairs(activeAbs) do activeTab[string.format("part%s", i)] = table.concat(v, ",") end
	stylesTab = #stylesTab > 0 and table.concat(stylesTab, ",") or nil
		
	local crafted = {}
	local anythingScripted = false
	for i=1, GetNumCraftedAbilities() do
		local craftedId = GetCraftedAbilityIdAtIndex(i)
		local skillType, skillLineIndex, skillIndex = CSPS.getCraftedAbilityIndices(craftedId)
		local skEntry = skillTable[skillType][skillLineIndex][skillIndex]
		if skEntry and skEntry.scripts then
			local hasScripts = false
			local scriptsForSkill = {craftedId}
			for j=1, 3 do
				table.insert(scriptsForSkill, skEntry.scripts[j] or 0)
				if skEntry.scripts[j] then hasScripts = true end
			end
			if hasScripts then 
				table.insert(crafted, table.concat(scriptsForSkill, ":")) 
				anythingScripted = true
			end
		end
	end
		
	crafted = anythingScripted and table.concat(crafted, ",") or nil
	
	local subclasses = CSPS.hasAnySubclasses() and table.concat(CSPS.getSubClassIds(), ",")
	
	local scribeStyleSubclass = table.concat(
		{
			crafted ~= "" and crafted or "-",
			stylesTab ~= "" and stylesTab or "-",
			subclasses ~= "" and subclasses or "-"
		}, "*")
	
	local rTable = {prog = activeTab, pass = passiveTab, scribeStyleSubclass = scribeStyleSubclass}
	
	return rTable
end


function CSPS.skTableExtract(progTab, passTab, ignoreClass, changeSilent, craftedTab, stylesTab, subClassTab, resetSubclasses, scribeStyleSubclass)
	local racialChange = false
	
	if scribeStyleSubclass then
		craftedTab, stylesTab, subClassTab = SplitString("*", scribeStyleSubclass)
	end
		
	if type(progTab) == "table"  or type(passTab) == "table" then 
		progTab = progTab or {} 
		passTab = passTab or {}
		stylesTab = stylesTab or {}
		local isSubClassInBuild = {}
		if subClassTab and subClassTab ~= "-" then
			subClassTab = {SplitString(",", subClassTab or "")}
			for i, v in pairs(subClassTab) do
				local _, skillLineIndex = GetSkillLineIndicesFromSkillLineId(tonumber(v))
				subClassTab[i] = skillLineIndex
				isSubClassInBuild[skillLineIndex] = true
			end
		elseif resetSubclasses then
			subClassTab = {1,2,3}
			for i=1, 3 do
				isSubClassInBuild[i] = true
			end
		else
			subClassTab = {}
			for i, v in pairs(CSPS.getSubClasses()) do
				table.insert(subClassTab, v)
				isSubClassInBuild[v] = true
			end
			table.sort(subClassTab)
		end
		if not progTab["part1"] and not passTab["part1"] then return {}, {}, racialChange, {}, {}, {1,2,3} end -- old format should not be there but who knows...
		
		local morphs, upgrades, crafted, styles = {}, {}, {}, {}
		
		for listIndex, myList in pairs(progTab) do
			local thisList = {SplitString(",", myList)}
			for progInd, skMorph in pairs(thisList) do --extract all the skills with progressionIndices (morphable skills)
				local myId, l = SplitString(":", skMorph)
				myId, l = tonumber(myId), tonumber(l)
				local i, j, k = GetSpecificSkillAbilityKeysByAbilityId(myId) 
				if i ~= 1 or ignoreClass or isSubClassInBuild[j] or CSPS.savedVariables.settings.showAllClassSkills then
					if i == 7 and j > 1 then racialChange = true j = 1 end -- If racial skills just change to the current race
					if IsSkillAbilityPassive(i,j,k) then 
						l = 0
						table.insert(upgrades, {i, j, k, l})
						local myName = GetSkillAbilityInfo(i,j,k)
						cspsPost(zo_strformat(GS(CSPS_LoadingError), myName))
					else 
						table.insert(morphs, {i, j, k, l})
					end
				end
			end
		end	
		local classMasteryIndex = CSPS.getClassMasterySkillLineIndex()
		for listIndex, myList in pairs(passTab) do
			local thisList = {SplitString(",", myList)}
			for passInd, skPass in pairs(thisList) do --extract all the skills without progressionIndices (passives)
				local myId, l = SplitString(":", skPass)
				myId, l = tonumber(myId), tonumber(l)
				local i, j, k = GetSpecificSkillAbilityKeysByAbilityId(myId) 
				if i ~= 1 or isSubClassInBuild[j] or j==classMasteryIndex or ignoreClass or CSPS.savedVariables.settings.showAllClassSkills then
					if i == 7 and j > 1 then racialChange = true j = 1 end -- If racial skills just change to the current race
					if IsSkillAbilityPassive(i,j,k) then
						local _, maxRank = GetSkillAbilityUpgradeInfo(i, j, k)
						if maxRank then
							if l > maxRank then
								l = maxRank
								local myName = GetSkillAbilityInfo(i,j,k)
								cspsPost(zo_strformat(GS(CSPS_LoadingError), myName))
							end
						end
						table.insert(upgrades, {i, j, k, l})
					else
						l = 0 
						local myName = GetSkillAbilityInfo(i,j,k)
						cspsPost(zo_strformat(GS(CSPS_LoadingError), myName))
						table.insert(morphs, {i, j, k, l})
					end
				end	
			end
		end	
				
		if craftedTab and craftedTab ~= "-" then
			local craftedListComp = {SplitString(",", craftedTab)}
			for _, craftedComp in pairs(craftedListComp) do
				local craftedParams = {SplitString(":", craftedComp)}
				for i,v in pairs(craftedParams) do
					craftedParams[i] = v ~= "0" and tonumber(v) or false
				end
				local craftedId = craftedParams[1]
				table.remove(craftedParams, 1)
				crafted[craftedId] = {unpack(craftedParams)}
			end
		end
		if stylesTab and stylesTab ~= "-" and #stylesTab ~= 0 then
			local stylesListComp = {SplitString(",", stylesTab)}
			for _, styleComp in pairs(stylesListComp) do 
				local myId, styleCollectible = SplitString(":", styleComp)
				myId, styleCollectible = tonumber(myId), tonumber(styleCollectible)
				local i, j, k = GetSpecificSkillAbilityKeysByAbilityId(myId) 
				if i ~= 1 or isSubClassInBuild[j] or ignoreClass then
					table.insert(styles, {i, j, k, styleCollectible})
				end
			end
		end
		if racialChange and not changeSilent then cspsPost(zo_strformat("<<C:1>>", GS(SI_SERVICETOKENTYPE2))) end 
		return morphs, upgrades, racialChange, crafted, styles, subClassTab
	else
		return {}, {}, racialChange, {}, {}, {1,2,3}
	end
end

function CSPS.tableExtract(progTab, passTab, craftedTab, stylesTab, subClassTab, resetSubclasses, scribeStyleSubclass)
	local morphs, upgrades, _, crafted, styles, subclasses = CSPS.skTableExtract(progTab, passTab, false, false, craftedTab, stylesTab, subClassTab, resetSubclasses, scribeStyleSubclass)
	CSPS.populateSkills(morphs, upgrades, false, crafted, styles, subclasses)
end

function CSPS.populateSkills(morphs, upgrades, keepOld, crafted, styles, subclasses)
	if #skillTable == 0 then CSPS.createSkillTable() elseif not keepOld then CSPS.resetSkills() end
	local subClassesInBuild = {}
	if subclasses then
		for i, v in pairs(subclasses) do
			subClassesInBuild[v] = true
		end
		if keepOld and not CSPS.savedVariables.settings.showAllClassSkills then
			for i, v in pairs(CSPS.getSubClasses()) do
				if not subClassesInBuild[v] then CSPS.removeSkillLine(1, v) end
			end
		end
		CSPS.setSubClasses(subclasses)
	else
		subClassesInBuild = {true,true,true}
		if keepOld and not CSPS.savedVariables.settings.showAllClassSkills then	
			for i, v in pairs(CSPS.getSubClasses()) do
				if v > 3 then CSPS.removeSkillLine(1, v) end
			end
		elseif not keepOld then
			CSPS.setSubClasses({1,2,3})
		end
		
	end
	local classMasteryIndex = CSPS.getClassMasterySkillLineIndex()
	subClassesInBuild[classMasteryIndex] = true
	local function fillSkill(auxListIndex, skillData, isActive)
		local skillType, skillLineIndex, skillIndex, rankOrMorph = unpack(skillData)
		if skillType == 1 and not subClassesInBuild[skillLineIndex] and not CSPS.savedVariables.settings.showAllClassSkills then return end
		-- Fill in the table entry
		local theSkill = skillTable[skillType][skillLineIndex][skillIndex]
		if theSkill then
			theSkill.rank = isActive and 1 or rankOrMorph
			theSkill.purchased = true
			theSkill.morph = isActive and (rankOrMorph or 0) or nil
			theSkill.hb = {}
		end	
	end
	
	for progInd, mV in pairs(morphs) do
		fillSkill(progInd, mV, true)
	end
	for passInd, mV in pairs(upgrades) do
		fillSkill(passInd, mV, false)
	end
	if styles then
		for _, styleData in pairs(styles) do
			local skillType, skillLineIndex, skillIndex, styleCollectible = unpack(styleData)
			local theSkill = skillTable[skillType][skillLineIndex][skillIndex] 
			if theSkill and theSkill.numSkillStyles and theSkill.numSkillStyles > 0 then
				theSkill.styleCollectible = styleCollectible
			end
		end
	end
	
	if crafted then
		for craftedId, scripts in pairs(crafted) do
			if craftedId then
				local skillType, skillLineIndex, skillIndex = CSPS.getCraftedAbilityIndices(craftedId)
				skillTable[skillType][skillLineIndex][skillIndex].scripts = {unpack(scripts)}
			end
		end
	end
	CSPS.checkClassMasteries()
	CSPS.refreshSkillSumsAndErrors()
end

function CSPS.hbExtract(hbComp, classId, subClasses)
	local subClasses = subClasses or CSPS.getSubClasses()
	local hbTables = {{},{},{}}
	hbComp = hbComp or ""
	if hbComp ~= "" and hbComp ~= "-" then
		local auxHb = {SplitString(";", hbComp)}
		hbTables = {}
		for hbIndex=1,3 do
			hbTables[hbIndex] = {}
			if auxHb[hbIndex] then
				local auxHb1 = {SplitString(",", auxHb[hbIndex])}
				for hbPosition, aSkill in pairs(auxHb1) do
					if aSkill == "" or aSkill == "-" then 
						hbTables[hbIndex][hbPosition] = nil
					else
						local skTyp, skLin, skId
						if string.find(aSkill, "-") then
							skTyp, skLin, skId = nil,nil,nil -- old format should not be there but who knows...
						elseif string.gsub(aSkill, "%d", "") == "c" then
							local myCraftedAbId = string.gsub(aSkill, "%D", "")
							myCraftedAbId = tonumber(myCraftedAbId)
							skTyp, skLin, skId = CSPS.getCraftedAbilityIndices(myCraftedAbId)
						else
							local myAbId = tonumber(aSkill)
							skTyp, skLin, skId = GetSpecificSkillAbilityKeysByAbilityId(myAbId)
						end
						if skTyp and skLin and skId and (skTyp ~=1 or classId or hf.entryInTable(subClasses, skLin) or CSPS.savedVariables.settings.showAllClassSkills) and skTyp ~= 0 then 
							hbTables[hbIndex][hbPosition] = {skTyp, skLin, skId} 
						end
					end
				end
			end
		end
	end
	return hbTables
end
--GetSkillAbilityIndicesFromCraftedAbilityId
--GetCraftedAbilitySkillCraftedAbilityId
	
function CSPS.loadBuild(useAuxProfile, givenTable)
	CSPS.showElement("save", true)
	if not givenTable and CSPS.currentCharData.werte == nil and CSPS.profiles == {} and (not CSPS.currentCharData.auxProfile or not useAuxProfile) then cspsPost(GS(CSPS_NoSavedData)) return end
		
	local myProfile = givenTable or CSPS.currentProfile == 0 and CSPS.currentCharData or CSPS.profiles[CSPS.currentProfile]
	if useAuxProfile then
		myProfile = CSPS.currentCharData.auxProfile
	end
		
	local skillTableClean = myProfile.werte
	local cpComp = myProfile.cp2werte or ""
	local cpHbComp = myProfile.cp2hbwerte or ""
	local attrComp = myProfile.attribute
	local hbComp = myProfile.hbwerte
	local gearComp = myProfile.gearComp or ""
	local gearCompUnique = myProfile.gearCompUnique
	local outfitComp = myProfile.outfitComp or false
	local qsComp = myProfile.qs
	local myMundus = myProfile.mundus
	local myRole = myProfile.role
	
	if myProfile.comp1 then
		attrComp, hbComp, cpComp, cpHbComp, qsComp, myRole, myMundus = SplitString("#", myProfile.comp1)
		gearComp, gearCompUnique, outfitComp = SplitString("#", myProfile.comp2)
	end
	
	CSPS.setMundus(tonumber(myMundus))
	CSPS.role = tonumber(myRole)
	CSPS.showRole()

	CSPS.tableExtract(skillTableClean.prog, skillTableClean.pass,  skillTableClean.crafted, skillTableClean.styles, skillTableClean.subclasses, true, skillTableClean.scribeStyleSubclass)
	
	myProfile.connections = myProfile.connections or {}
	
	local hasConnections = {}
	local cpProfilesToLoad = {}
	local cpPresetsToLoad = {}
		
	for myDiscipline=1, 3 do
		if myProfile.connections[myDiscipline] then 
			hasConnections[myDiscipline] = true 
		end
	end
	
	CSPS.extractQS(qsComp, CSPS.getQsBars())
	CSPS.loadConnectedQuickSlots() 
		
	cp.extract(cpComp, hasConnections)
	cp.hotBarExtract(cpHbComp, cp.bar, hasConnections)

	local outdatedPresets = false
	
		for myDiscipline=1, 3 do
		if myProfile.connections[myDiscipline] then 
			local myType, myId = SplitString("-", myProfile.connections[myDiscipline])
			if myType == "4" then 
				outdatedPresets = CSPS.loadCPPreset(tonumber(myType), tonumber(myId), myDiscipline, true) or outdatedPresets
			else
				CSPS.loadCPProfile(tonumber(myType), tonumber(myId), myDiscipline)
			end
		end
	end

	if outdatedPresets then cspsPost(GS(CSPS_CPOldPreset)) end

	CSPS.hbTables = CSPS.hbExtract(hbComp, false, skillTableClean.subClasses)
	CSPS.hbLinkToSkills(CSPS.hbTables)
	CSPS.hbPopulate()
	CSPS.attrExtract(attrComp)
	if not CSPS.treeIsReady then CSPS.createTree() end
	
	cp.updateSidebarIcons()
	
	cp.updateSlottedMarks()
	
	if not CSPS.moduleExclude.gear then
		CSPS.setTheGear(CSPS.extractGearString(gearComp, gearCompUnique))
	end
	
	if not CSPS.moduleExclude.outfit and outfitComp and outfitComp ~= "-" then 
		CSPS.outfits.extract(outfitComp)
	end
	
	CSPS.refreshTree() 
	CSPS.unsavedChanges = useAuxProfile == true or givenTable ~= nil
end

function CSPS.canRespecFromUI()
	
	if IsCurrentCampaignVengeanceRuleset() then 
		return false, GS("SI_RESPECRESULT", RESPEC_RESULT_IN_VENGEANCE) 
	end

	if IsRaidInProgress() then
		return false, GS("SI_RESPECRESULT", RESPEC_RESULT_DISALLOWED_IN_ACTIVITY)
	end

	if IsUnitInCombat("player") then
		return false, GS("SI_RESPECRESULT", RESPEC_RESULT_IS_IN_COMBAT)
	end
	
	return true
end


function CSPS.text(arg)
	if type(arg) == "table" then
		for i, v in pairs(arg) do
			if type(v) ~= "string" then return end
		end
		arg = table.concat(arg, "\n")
	elseif type(arg) ~= "string" then 
		return 
	end
	CSPS.toggleImportExport(true)
	CSPSWindowImportExportTextEdit:SetText(arg)
end

function CSPS.carotest42(args)
	args = args or 1
	cspsPost('[CSPS] Congratulations, you found my internal function for testing purposes. Have a good day and remember to always bring a towel! (Irniben)')
	cspsPost(CSPS.skillTable[1][args].name)
	local myText = {}
	for i, v in ipairs(CSPS.skillTable[1][args]) do
		local abId = GetSkillAbilityId(1,args,i)
		if v.passive then
			table.insert(myText, abId.." -- "..v.name)
		else
			for j=0,2 do
				abId = GetSpecificSkillAbilityInfo(1,args,i, j)
				local abName = GetAbilityName(abId)
				table.insert(myText, abId.." -- "..abName)
			end
		end
	end
	CSPS.text(table.concat(myText, "\n"))
end

 SLASH_COMMANDS["/carotest42"] = CSPS.carotest42
 SLASH_COMMANDS["/csps"] = function() CSPSWindow:SetHidden(not CSPSWindow:IsHidden()) end
 EVENT_MANAGER:RegisterForEvent(CSPS.name.."OnAddOnLoaded", EVENT_ADD_ON_LOADED, CSPS.OnAddOnLoaded)