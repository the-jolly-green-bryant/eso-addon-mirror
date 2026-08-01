local skMap = CSPS.SkillFactoryDBExport.skMap
local cpMap = CSPS.SkillFactoryDBExport.cpMap
local cp2Map = CSPS.SkillFactoryDBExport.cp2Map
local muMap = CSPS.SkillFactoryDBExport.mundusMap
local raMap = CSPS.SkillFactoryDBExport.raceMap
local clMap = CSPS.SkillFactoryDBExport.classMap
local alMap = CSPS.SkillFactoryDBExport.allianceMap
local basisUrl = ""
local GS = GetString
local cp = CSPS.cp

local cspsPost = CSPS.post
local cspsD = CSPS.cspsD

local theLink = ""

local function showLink()
	CSPSWindowImportExportTextEdit:SetText(theLink)
	CSPSWindowImportExportTextEdit:SelectAll()
	CSPSWindowImportExportTextEdit:TakeFocus()
end

local function table_invert(t)
   local s={}
   for k,v in pairs(t) do
     s[v]=k
   end
   return s
end

local function showMundus(myMundusId)
	local myMundus = "-"
	if myMundusId then 
		myMundus = zo_strformat("<<C:1>>", GetAbilityName(myMundusId)) 
		CSPS.setMundus(myMundusId) 
	else
		myMundus = "-" 
	end
	myMundus = {SplitString(":", myMundus)}
	
	myMundus = myMundus[#myMundus]
	local ctrMundus = CSPSWindowImportExportMundusValue
	ctrMundus:SetText(myMundus)
	if myMundus ~= "-" and (not CSPS.currentMundus or CSPS.currentMundus ~= myMundusId) then
		ctrMundus:SetMouseEnabled(true)
		ctrMundus:SetColor(CSPS.colors.orange:UnpackRGB())
		ctrMundus:SetHandler("OnMouseEnter", function() CSPS.showMundusTooltip(ctrMundus, myMundusId) end)
		ctrMundus:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
	elseif CSPS.currentMundus == myMundusId then
		ctrMundus:SetColor(CSPS.colors.green:UnpackRGB())
		ctrMundus:SetHandler("OnMouseEnter", function() end)
	else
		ctrMundus:SetColor(CSPS.colors.white:UnpackRGB())
		ctrMundus:SetHandler("OnMouseEnter", function() end)
	end
end


local function generateTextSkills(skillTypes)
	local myText = {}
	local skillTypesT = {}
	for i, v in pairs(skillTypes) do skillTypesT[v] = true end
	for skillType, typeData in ipairs(CSPS.skillTable) do
		if skillTypesT[skillType] then
			local typeTable = {GS("SI_SKILLTYPE", skillType)}
			local typeHasEntries = false
			for lineIndex, lineData in ipairs(typeData) do
				local lineTable = {}
				local lineHasEntries = false
				for skillIndex, skillData in ipairs(lineData) do
					if skillData.purchased then
						typeHasEntries = true
						lineHasEntries = true
						local myName = skillData.morph and skillData.morph > 0 and skillData.morphNames[skillData.morph] or skillData.name
						if skillData.craftedId and skillData.scripts then
							local scripts = {}
							for _, scriptId in pairs(skillData.scripts) do
								if scriptId and tonumber(scriptId) ~= 0 then
									table.insert(scripts, zo_strformat("<<C:1>>", GetCraftedAbilityScriptDisplayName(scriptId)))
								end
							end
							if #scripts > 0 then
								myName = string.format("%s (%s)", myName, table.concat(scripts, ", "))
							end
						end
						myName = string.format("    - %s", myName)
						if skillData.passive then myName = string.format("    - %s (%s)", skillData.name, skillData.rank) end
						table.insert(lineTable, myName)
					end
				end
				if lineHasEntries and not lineData.emperor and not lineData.vengeance then 
				--  GetSkillLineNameById(skillLineId)), 
					local lineName = string.match(lineData.name, "(.+)%s%|") or lineData.name
					if lineData.class then lineName = zo_strformat("<<1>> (<<C:2>>)", lineName, GetClassName(GetUnitGender("player"), lineData.class)) end
					table.insert(typeTable, string.format(" - %s", lineName))
					table.insert(typeTable, table.concat(lineTable, "\n"))
				end
			end
			if typeHasEntries then
				table.insert(myText, table.concat(typeTable, "\n"))
			end
		end	
	end
	myText = table.concat(myText, "\n")
	CSPSWindowImportExportTextEdit:SetText(myText)
end

local function generateTextOther()
	local myTable = {zo_strformat("<<C:1>>", GetUnitName("player"))}

	table.insert(myTable, zo_strformat("<<C:1>>", GetRaceName(GetUnitGender('player'), GetUnitRaceId('player'))))
	table.insert(myTable, zo_strformat("<<C:1>>", GetAllianceName(GetUnitAlliance('player'))))
	table.insert(myTable, zo_strformat("<<C:1>>", GetClassName(GetUnitGender('player'), GetUnitClassId('player'))))
	local myAttributes = {GS(SI_STATS_ATTRIBUTES)}
	table.insert(myAttributes, string.format(" - %s: %s", GS(SI_ATTRIBUTES1), CSPS.attrPoints[1]))
	table.insert(myAttributes, string.format(" - %s: %s", GS(SI_ATTRIBUTES2), CSPS.attrPoints[2]))
	table.insert(myAttributes, string.format(" - %s: %s", GS(SI_ATTRIBUTES3), CSPS.attrPoints[3]))
	myAttributes = table.concat(myAttributes, "\n")
	table.insert(myTable, myAttributes)
	local myMundus = CSPS.currentMundus and zo_strformat("<<C:1>>", GetAbilityName(CSPS.currentMundus)) or "-"
	table.insert(myTable, myMundus)
	for i=1, 2 do
		table.insert(myTable, string.format("%s %s:", GS(CSPS_ImpEx_HbTxt), i))
		for j=1, 6 do
			local mySkill = CSPS.hbTables[i][j]
			if mySkill ~= nil then 
				local skillData = CSPS.skillTable[mySkill[1]][mySkill[2]][mySkill[3]]
				mySkill = string.format("   %s) %s", j, skillData.morph and skillData.morph > 0 and skillData.morphNames[skillData.morph] or skillData.name)
			else
				mySkill = string.format("   %s) -", j)
			end
		table.insert(myTable, mySkill)
		end
	end
	myTable = table.concat(myTable, "\n")
	CSPSWindowImportExportTextEdit:SetText(myTable)
end

local function textExport()
	ClearMenu()
	for i, v in pairs({{1,2,3}, {4,5,6,7}, {8}}) do
		local myEntryName = {}
		for j,w in pairs(v) do table.insert(myEntryName, GS("SI_SKILLTYPE", w)) end
		AddCustomMenuItem(table.concat(myEntryName, "/"), function() generateTextSkills(v) end)
	end
	AddCustomMenuItem("-", function() end)
	AddCustomMenuItem(GS(CSPS_ImpExp_TextOd), function() generateTextOther() end)
	ShowMenu()
end

function importSkills(auxTable)
	if #auxTable == 0 then return end
	CSPS.resetSkills()
	local skillTable = CSPS.skillTable
	for skillType, typeData in pairs(auxTable) do
		for skillLineIndex, lineData in pairs(typeData) do
			for skillIndex, skillData in pairs(lineData) do
				local isPassive = IsSkillAbilityPassive(skillType, skillLineIndex, skillIndex)
				local skEntry = skillTable[skillType][skillLineIndex][skillIndex]
				
				skEntry.rank = isPassive and skillData[2] or 1
				skEntry.purchased = true
				skEntry.morph = not isPassive and skillData[1] or nil
			end
		end
	end
	CSPS.unsavedChanges = true
	CSPS.checkClassMasteries()
	CSPS.refreshSkillSumsAndErrors()
end

local function exportESOHUB()
	local skillsToIgnore = {
		[150185] = true, -- armor passives that are auto grant
		[152778] = true,
		[150181] = true,
		[150184] = true,
		[152780] = true,
	}
	local myLink = {}
	table.insert(myLink, GetUnitClassId("player")) --class
	table.insert(myLink, GetUnitRaceId("player")) --race
	CSPS.impExpAddInfo(GetUnitRaceId("player"), GetUnitClassId("player"))
	table.insert(myLink, CSPS.role) --role
	table.insert(myLink, table.concat(CSPS.attrPoints, ":")) --attributes
	table.insert(myLink, "0") --curse
	table.insert(myLink, CSPS.getMundus()) --mundus
	--subclasses
	local subclasses = {}
	for i, v in pairs(CSPS.getSubClasses()) do
		table.insert(subclasses, GetSkillLineId(1, v))
	end
	table.insert(myLink, table.concat(subclasses, ","))
	
	for hbIndex=1,2 do
		local oneHotbar = {}
		for slotIndex=1,6 do
			local skillParams = CSPS.hbTables[hbIndex][slotIndex]
			local abilityId = 0
			if skillParams then
				local skillType, skillLineIndex, skillIndex = unpack(skillParams)
				local skillData = CSPS.skillTable[skillType][skillLineIndex][skillIndex]
				abilityId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, skillIndex, skillData.morph, 1)
				if IsCraftedAbilitySkill(skillType, skillLineIndex, skillIndex) then
					local script1, script2, script3 = unpack(skillData.scripts)
					abilityId = table.concat({abilityId, script1 or 0, script2 or 0, script3 or 0}, ":")
				end
			end
			table.insert(oneHotbar, abilityId)
		end
		oneHotbar = table.concat(oneHotbar, ",")
		table.insert(myLink, oneHotbar)
	end
	
	local passives = {}
	for skillType, typeData in ipairs(CSPS.skillTable) do
		for skillLineIndex, lineData in ipairs(typeData) do
			for skillIndex, skillData in ipairs(lineData) do
				if skillData.purchased and skillData.passive then
					local abilityId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, skillIndex, 0, 1)
					table.insert(passives, abilityId)
				end
			end
		end
	end
	table.insert(myLink, table.concat(passives, ","))
	local slottedCP = {}
	local passiveCP = {}
	
	for discipline = 1, 3 do
		for slotIndex = 1,4 do
			local skillData = cp.bar[discipline][slotIndex]
			table.insert(slottedCP, skillData and skillData.id or 0)
		end
	end
	
	table.insert(myLink, table.concat(slottedCP, ","))
	
	for cpId, skillData in pairs(cp.table) do
		if skillData.active and skillData.value > 0 and skillData.type == 1 then
			table.insert(passiveCP, string.format("%s:%s", cpId, skillData.value))
		end
	end
	passiveCP = #passiveCP > 0 and passiveCP or {0}
	table.insert(myLink, table.concat(passiveCP, ","))
	local gearStr = "0"
	if not CSPS.moduleExclude.gear then
		gearStr = CSPS.exportGearToESOHUB()
	end
	table.insert(myLink, gearStr)
	
	local buffFood = "0"
	local potions = "0"
	
	if not CSPS.moduleExclude.qs then
		local qsBar = CSPS.getQsBars()[1]
		buffFood, potions = {}, {}
		local tablesToInsert = {[ITEMTYPE_DRINK] = buffFood, [ITEMTYPE_POTION] = potions, [ITEMTYPE_FOOD] = buffFood}
		for slotIndex, slotData in pairs(qsBar) do
			if slotData.type == ACTION_TYPE_ITEM then
				local itemType = GetItemLinkItemType(slotData.value)
				local id1, _, _, id2 = CSPS.getItemIdsFromLink(slotData.value)
				if tablesToInsert[itemType] then table.insert(tablesToInsert[itemType], string.format("%s:%s", id1, id2)) end
			end
		end
		buffFood = #buffFood > 0 and buffFood or {0}
		potions = #potions > 0 and potions or {0}
		buffFood = table.concat(buffFood, ",")
		potions = table.concat(potions, ",")
	end	
	table.insert(myLink, buffFood)
	table.insert(myLink, potions)
	theLink = table.concat(myLink, ";")
	theLink = theLink
	showLink()
end

local function buildCompleteLink()
	local languagesForEsoHub = {
		["en"] = true,
		["de"] = true,
		["fr"] = true,
		["ru"] = true,
		["es"] = true,
	}

	local language = GetCVar("language.2")
	language = languagesForEsoHub[language] and language or "en"
	return string.format("https://eso-hub.com/%s/build-editor?addondata=%s", language, theLink)
end

function CSPS.openLink()
	if not theLink or theLink == "" then exportESOHUB() end
	RequestOpenUnsafeURL(buildCompleteLink())
end

function CSPS.showLinkTT(control)
	ZO_Tooltips_ShowTextTooltip(control, TOP, buildCompleteLink())
end

local function importSubclasses(subclasses)
	
	local subclassesInImport = {}
	local myClassThere = false
	local linesByClass = {}
	local oldClasses = {}
	local newSubclasses = {}
	for i=1,3 do
		subclasses[i] = subclasses[i] and tonumber(subclasses[i])
		if subclasses[i] and subclasses[i] ~= 0 then
			local _, skillLineIndex = GetSkillLineIndicesFromSkillLineId(tonumber(subclasses[i]))
			local classId = GetSkillLineClassId(1,skillLineIndex)
			if skillLineIndex > 3 then 
				linesByClass[classId] = linesByClass[classId] or {}
				table.insert(linesByClass[classId], i)
			else 
				myClassThere = true
			end
			oldClasses[CSPS.getSubClasses(i)] = true
			newSubclasses[i] = skillLineIndex
			subclassesInImport[skillLineIndex] = true
		end
	end
	CSPS.setSubClasses(newSubclasses)
	if not CSPS.savedVariables.settings.importExportParts.reset and not CSPS.savedVariables.settings.showAllClassSkills then
		for i=1, 3 do
			if oldClasses[i] and not subclassesInImport[oldClasses[i]] then
				CSPS.removeSkillLine(1, oldClasses[i])
			end
		end	
	end
	
	for _, classLines in pairs(linesByClass) do
		if #classLines > 1 then
			for i=2, #classLines do
				for j=1,3 do
					if not subclassesInImport[j] then
						CSPS.post(zo_strformat(GS(CSPS_SubclassesIncompatible), GetSkillLineNameById(GetSkillLineId(1, CSPS.getSubClasses(classLines[i]))), GetSkillLineNameById(GetSkillLineId(1, j))))
						subclassesInImport[CSPS.getSubClasses(classLines[i])] = nil
						CSPS.setSubClass(classLines[i], j)
						subclassesInImport[j] = true
						myClassThere = true
						break
					end
				end
			end
		end
	end
	if not myClassThere then
		local changeIndex = math.random(3)
		CSPS.post(zo_strformat(GS(CSPS_SubclassesIncompatible), GetSkillLineNameById(GetSkillLineId(1, CSPS.getSubClasses(changeIndex))), GetSkillLineNameById(GetSkillLineId(1, changeIndex))))
		subclassesInImport[CSPS.getSubClasses(changeIndex)] = nil
		CSPS.setSubClass(changeIndex, changeIndex)
	end
	
	if not CSPS.savedVariables.settings.showAllClassSkills then
		for i,v in pairs(subclasses) do --only relevant for wizards import
			if not subclassesInImport[v] then 
				CSPS.removeSkillLine(1,v)
			end		
		end
	end
	return subclassesInImport
end

CSPS.importSubclasses = importSubclasses

local function unlockDirtyCP()
	local oldValues = cp.updateUnlock()
	cspsD("Checking old cp values after update locking and finding paths")
	if oldValues  then --and CSPS.helperFunctions.anyEntryNotFalse(oldValues)
		cspsD(oldValues) 
		local unlockPaths = {}
		for cpId, value in pairs(oldValues) do
			local unlockPath = cp.cpFastestWays(cpId)
			table.insert(unlockPaths, unlockPath[1])
		end
		table.sort(unlockPaths, function(a,b) return a.points < b.points end)
		local checkedSteps = {}
		for _, unlockPath in pairs(unlockPaths) do
			for stepIndex, stepCP in pairs(unlockPath.steps) do
				if not checkedSteps[stepCP] then
					local _, unlockPoints = GetChampionSkillJumpPoints(stepCP)
					cp.table[stepCP].value = math.max(cp.table[stepCP].value or 0, oldValues[stepCP] or 0, unlockPoints)
					cspsD("Set "..GetChampionSkillName(stepCP).." to "..cp.table[stepCP].value)
					checkedSteps[stepCP] = true
				end
			end
		end
		for cpId, value in pairs(oldValues) do
			cp.table[cpId].value = cp.table[cpId].value > 0 and cp.table[cpId].value or value
		end
	end
	cspsD("Checking cp values again")
	oldValues = cp.updateUnlock()
	if oldValues and #oldValues > 0 then 
		cspsD(oldValues) 
	end
	
	cp.updateSum()
	cp.recheckHotbar()

	cp.updateSlottedMarks()
	cp.updateClusterSum()
end

local function importFromWizards(setup)
	-- already here but not the time to finish this function atm...
	local WW = WizardsWardrobe
	if not WW then return end
	--local setup = WW.setups[zone] and WW.setups[zone][page] and WW.setups[zone][page][setupIndex]
	if not setup then return end
	cspsD("Importing "..setup.name)
	
	
	local skillTable = CSPS.skillTable
	local classLines = {}
	local classLinesInBuild = {}
	
	for hbIndex, hbData in pairs(setup.skills) do
		for slotIndex, abilityIdDirty in pairs(hbData) do
			
			local progression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId( abilityIdDirty )
			local abilityId = progression and progression:GetAbilityId()
			local skillType, skillLineIndex, skillIndex, morphSlot = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
			if skillType ~= 0 then
				local skillData = skillTable[skillType][skillLineIndex][skillIndex]
				if skillType == 1 then
					local skillLineId = GetSkillLineId(skillType, skillLineIndex)
					if not classLinesInBuild[skillLineId] then
						table.insert(classLines, skillLineId)
						classLinesInBuild[skillLineId] = true
					end
				end
				skillData.purchased = true
				skillData.morph = morphSlot
				CSPS.hbTables[hbIndex + 1][slotIndex - 2] = {skillType, skillLineIndex, skillIndex}
				CSPS.skillTable[skillType][skillLineIndex][skillIndex].hb[hbIndex + 1] = slotIndex - 2
			else
				CSPS.hbTables[hbIndex + 1][slotIndex - 2] = nil
			end
		end
	end
	if #classLines > 0 then
		importSubclasses(classLines)
	end
	CSPS.checkClassMasteries()
	CSPS.refreshSkillSumsAndErrors()
	CSPS.hbPopulate()
	
	for barPos, cpId in pairs(setup.cp) do
		local skillData = cp.table[cpId or 0]
		if skillData then
			skillData.value = skillData.maxValue
			local discipline = math.floor((barPos-1) / 4)
			local slotIndex = barPos - (discipline * 4)
			discipline = discipline + 1
			if cp.bar[discipline] then
				cp.bar[discipline][slotIndex] = skillData
			end
		end
	end
	unlockDirtyCP()
	if  not CSPS.moduleExclude.gear  then
		CSPS.setGearFromWizards(setup.gear)
	end
	--.food = {id (itemId), link}
end

CSPS.importFromWizards = importFromWizards

local function importESOHUB()
	local myLink = CSPSWindowImportExportTextEdit:GetText()
	if myLink == nil or myLink == "" then return end
	myLink = string.gsub(myLink, "http.*%=", "") --remove link data
	local lnkParameter = {SplitString(";", myLink)}
	cspsD(lnkParameter)
	if lnkParameter == nil or #lnkParameter < 14 then return end
	cspsD("All parameters are there")
	local classId, raceIdList, combatRoleIndex, attributes, curseId, mundusId, subclasses, hb1, hb2, passives, slottedCP, passiveCP, gear, buffFood, potions = unpack(lnkParameter)
	-- curseId not yet included 
	
	raceIdList = {SplitString(",", raceIdList)}
	CSPS.impExpAddInfo(tonumber(raceIdList[1]), tonumber(classId)) -- no alliance set
	
	CSPS.role = tonumber(combatRoleIndex)
	CSPS.showRole()
	
	CSPS.attrExtract(attributes, ":")
	
	-- curseId not (yet) included in CSPS
	
	CSPS.setMundus(tonumber(mundusId))
	
	if CSPS.savedVariables.settings.importExportParts.reset then CSPS.resetSkills() end
	
	subclasses = {SplitString(",",  subclasses)}
	local subclassesInImport = importSubclasses(subclasses)
	
	local skillTable = CSPS.skillTable
	
	local function setAbility(strValue)
		if strValue == "0" then return 0 end
		if string.find(strValue, ":") then 
			local craftedAbilityId, script1, script2, script3 = SplitString(":", strValue)
			craftedAbilityId = tonumber(craftedAbilityId)
			local skillType, skillLineIndex, skillIndex = CSPS.getCraftedAbilityIndices(GetAbilityCraftedAbilityId(craftedAbilityId))
			if skillType == 0 then cspsD("Couldn't import crafted ability: "..craftedAbilityId) return 0 end
			local scripts = skillTable[skillType][skillLineIndex][skillIndex].scripts
			scripts[1] = tonumber(script1)
			scripts[2] = tonumber(script2)
			scripts[3] = tonumber(script3)
			return skillType, skillLineIndex, skillIndex
		else
			local skillType, skillLineIndex, skillIndex, morphSlot = GetSpecificSkillAbilityKeysByAbilityId(tonumber(strValue))
			if skillType == 0 then return 0 end
			if skillType == SKILL_TYPE_RACIAL then skillLineIndex = 1 end -- always change it to 1 but keep the passives
			if skillType == 1 and not subclassesInImport[skillLineIndex] and not CSPS.savedVariables.settings.showAllClassSkills then 
				cspsD("Subclass not in build: "..strValue) 
				return 0 
			end
			local skillData = skillTable[skillType]
			skillData = skillData and skillData[skillLineIndex]
			skillData = skillData and skillData[skillIndex]
			if not skillData then cspsD("No skillData for "..strValue) return 0 end 
			skillData.purchased = true
			skillData.rank = skillData.passive and 42 or nil	-- 42 will later be reduced to the maxRank
			skillData.morph = not skillData.passive and morphSlot or nil
			skillData:setPoints()
			--theSkill.lineData:sumUpSkills()
			--theSkill.typeData:sumUpSkills()
			return skillType, skillLineIndex, skillIndex
		end
	end
	
	local function setHotbar(strValue, hbIndex)
		strValue = {SplitString(",", strValue)}
		if #strValue < 6 then return end
		for i, v in pairs(strValue) do
			local skillType, skillLineIndex, skillIndex = setAbility(v)
			if skillType and skillType > 0 then
				CSPS.hbTables[hbIndex][i] = {skillType, skillLineIndex, skillIndex}
				CSPS.skillTable[skillType][skillLineIndex][skillIndex].hb[hbIndex] = i
			else
				CSPS.hbTables[hbIndex][i] = nil
			end
		end
	end
	setHotbar(hb1, 1)
	setHotbar(hb2, 2)

	passives = {SplitString(",", passives)}
	for i, v in pairs(passives) do
		setAbility(v)
	end
	
	CSPS.checkClassMasteries()
	CSPS.refreshSkillSumsAndErrors()
	CSPS.hbPopulate()
	
	passiveCP = {SplitString(",", passiveCP)} 
	slottedCP = {SplitString(",", slottedCP)}
	
	cp.resetTable()
	
	local function setCP(cpId)
		if not cpId or cpId == "0" then return false end
		local value = false
		if string.find(cpId, ":") then 
			cpId, value = SplitString(":", cpId)
			value = tonumber(value)
		end
		local skillData = cp.table[tonumber(cpId)]
		if not skillData then cspsD("No CP data for "..cpId) return false end
		skillData.value = value or skillData.maxValue
		return skillData
	end
	
	for _, cpId in pairs(passiveCP) do
		setCP(cpId)
	end
	
	for barPos, cpId in pairs(slottedCP) do
		local skillData = setCP(cpId)
		if skillData then
			local discipline = math.floor((barPos-1) / 4)
			local slotIndex = barPos - (discipline * 4)
			discipline = discipline + 1
			if cp.bar[discipline] then
				cp.bar[discipline][slotIndex] = skillData
			end
		end
	end

	unlockDirtyCP()
	
	
	if not CSPS.moduleExclude.gear then CSPS.importGearFromHub(gear) end -- happens in csps_gear.lua
	
	if not CSPS.moduleExclude.qs then 
		local qsBars = CSPS.getQsBars()
		buffFood = {SplitString(",", buffFood)}
		potions = {SplitString(",", potions)}
		local indicesSet = {}
		local itemsDone = {}
		local slotRoutes = CSPS.savedVariables.settings.importQsSlots
		local counters = {1,2}
		local function setSlot(strValue, itemCat)
			local param1, param2 = SplitString(":", strValue)
			local itemLink = CSPS.findItemLinkForTwoIds(tonumber(param1), tonumber(param2))
			param1, _, _, param2 = CSPS.getItemIdsFromLink(itemLink) --in case param2 was not needed or changed
			local barIndex = slotRoutes[itemCat][counters[itemCat]]
			if barIndex and barIndex ~= 0 then				
				local slotData = qsBars[1][barIndex]
				slotData.type = ACTION_TYPE_ITEM
				slotData.value = itemLink
				indicesSet[barIndex] = true
				table.insert(itemsDone, {tonumber(param1), tonumber(param2)})
				counters[itemCat] = counters[itemCat] + 1
			end	
		end
		for i, v in pairs(buffFood) do
			setSlot(v,1)
		end
		for i, v in pairs(potions) do
			setSlot(v,2)		
		end
		local function findParamsInTable(tableToSearch, paramsToFind)
			for i, v in pairs(tableToSearch) do
				if v[1] == paramsToFind[1] and v[2] == paramsToFind[2] then return true end
			end
			return false
		end
		cspsD(itemsDone)
		cspsD(indicesSet)
		
		for slotIndex, slotData in pairs(qsBars[1]) do
			if not indicesSet[slotIndex] then
				if slotData.type == ACTION_TYPE_ITEM then
					local firstId, _, _, lastId = CSPS.getItemIdsFromLink(slotData.value)
					if findParamsInTable(itemsDone, {firstId, lastId}) then 
						slotData.value = ""
						slotData.type = ACTION_TYPE_NOTHING
					end
				end
			end
		end
	end
	
	if not CSPS.treeIsReady then CSPS.createTree() end -- create tree view
	CSPS.refreshTree() 
	CSPS.showElement("save", true)
end

CSPS.importESOHUB = importESOHUB

local function importLinkSF()
	local myLink = CSPSWindowImportExportTextEdit:GetText()
	if myLink == nil or myLink == "" then return end
	local lnkParameter = {SplitString("#", myLink)}
	if lnkParameter == nil or #lnkParameter < 2 then return end
	lnkParameter = lnkParameter[2]
	local sfV2 = false
	if string.sub(lnkParameter, 1, 3) == "v2," then sfV2 = true end
	lnkParameter = string.gsub(lnkParameter, ';;', ';-;')
	lnkParameter = {SplitString(";", lnkParameter)}
	CSPS.lnkParameter = lnkParameter
	local muMapBw = table_invert(muMap) -- invert the mapping-tables
	local skMapBw = table_invert(skMap)
	local alMapBw = table_invert(alMap)
	local cp2MapBw = table_invert(cp2Map)
	local raMapBw = table_invert(raMap)
	local clMapBw = table_invert(clMap)
	if lnkParameter[1] == nil or lnkParameter[1] == "-" then cspsPost('No Parameter 1') return end
	local lnkSkTab = {SplitString(",", lnkParameter[1])}
	if #lnkSkTab < 3 or (sfV2 and #lnkSkTab < 8) then cspsPost('Missing parameters') return end
	
	local lnkBaseData = {}
	if sfV2 then 
		for i=1, 7 do -- in version 2 the first parameter is reserved for the version number
			lnkBaseData[i] = tonumber(lnkSkTab[i+1]) or 0
		end
	else
		for i=1, 3 do
			local baseDataString = SplitString("flrc", lnkSkTab[i])
			lnkBaseData[i] = tonumber(baseDataString) or 0
		end
	end
	
	local myAlliance = alMapBw[lnkBaseData[1]]
	local myRace = raMapBw[lnkBaseData[2]]
	local myClass = clMapBw[lnkBaseData[3]]
	
	CSPS.impExpAddInfo(myRace, myClass)
	local raceCorrect = true
	if GetUnitRaceId('player') ~= myRace then raceCorrect = false end
	local classCorrect = true
	if GetUnitClassId('player') ~= myClass then classCorrect = false end
	local auxTable = {}
	
	if sfV2 then	-- in v1 the skill list was part of the first array, in v2 it's the next one
		lnkSkTab = {SplitString(",", lnkParameter[2])}
	else
		for i=1, 3 do 
			table.remove(lnkSkTab, 1)
		end
	end
	
	if lnkSkTab ~= nil and lnkSkTab ~= "-" then
		for i, v in ipairs(lnkSkTab) do
			local abilityId, myRank = SplitString(":", v)
			abilityId = skMapBw[tonumber(abilityId)]
			if abilityId ~= nil then
				local skTyp, skLin, skId, morph, rank = GetSpecificSkillAbilityKeysByAbilityId(abilityId)	
				if not ((skTyp==1 and classCorrect == false) or (skTyp==7 and raceCorrect == false)) then -- only try to read class/race skills if fitting
					if auxTable[skTyp] == nil then auxTable[skTyp] = {} end
					if auxTable[skTyp][skLin] == nil then auxTable[skTyp][skLin] = {} end
					auxTable[skTyp][skLin][skId] = {morph, tonumber(myRank)}
				end
			end
		end
	end
	importSkills(auxTable)
	local versionAdd = sfV2 and 1 or 0
	if lnkParameter[2 + versionAdd] ~= nil and lnkParameter[2 + versionAdd] ~= "-" then
		-- Hotbar
		local lnkHotbars = {}
		if sfV2 then 
			lnkHotbars = {SplitString(",", lnkParameter[3])}
		else
			lnkHotbars = {lnkParameter[3], lnkParameter[4]}
		end
		
		for ind1= 1, 2 do
			CSPS.hbEmpty(ind1)
			local lnkHbTab = {SplitString(":", lnkHotbars[ind1])}
			if #lnkHbTab == 6 then
				CSPS.hbTables[ind1] = {}
				for ind2=1,6 do
					local myId = skMapBw[tonumber(lnkHbTab[ind2])]
					if myId ~= nil then
						local i, j, k, morph, rank = GetSpecificSkillAbilityKeysByAbilityId(myId)
						if i == 1 and j > 3 then
							CSPS.hbTables[ind1][ind2] = nil
						else
							CSPS.hbTables[ind1][ind2] = {i, j, k}
							CSPS.skillTable[i][j][k].hb[ind1] = ind2
						end
					else
						CSPS.hbTables[ind1][ind2] = nil
					end
				end
			else
				cspsPost( zo_strformat(GetString(CSPS_ImpEx_ErrHb), ind1))
			end
		end
		CSPS.hbPopulate()
	end
	local myMundus = sfV2 and lnkBaseData[4] or tonumber(lnkParameter[4])
	myMundus = muMapBw[myMundus]
	showMundus(myMundus)
	--5 Attributes
	if sfV2 then 
		CSPS.attrPoints[2] = lnkBaseData[5]
		CSPS.attrPoints[1] = lnkBaseData[6]
		CSPS.attrPoints[3] = lnkBaseData[7]
	else
		local myAttributes = {SplitString(",", lnkParameter[5])} 
		CSPS.attrPoints[2] = tonumber(myAttributes[1]) or 0
		CSPS.attrPoints[1] = tonumber(myAttributes[2]) or 0
		CSPS.attrPoints[3] = tonumber(myAttributes[3]) or 0
	end
	--v1: 6 Armorpieces, 7 CP,8 Cp sums, 9 Weapons
	--v2: 
	-- 4: gear info, comma separated format posistion:setid:type:quality:trait:enchantement (planned for the future)
	-- 5: CP-sums (green-blue-red)
	-- 6: CP-values (id:value), 7: CP-hotbars (position:id), 1-4 = green, 5-8 = blue, 9-12 = red
	local lnkGearTab = sfV2 and lnkParameter[4] and lnkParameter[4] ~= "-" and lnkParameter[4]
	if lnkGearTab and  not CSPS.moduleExclude.gear  then CSPS.ImportSkillFactorySetList(lnkGearTab) end
	
	local lnkCpTab = false
	lnkCpTab = sfV2 and lnkParameter[6] ~= nil and lnkParameter[6] ~= "-" and {SplitString(",", lnkParameter[6])}
	if lnkCpTab and type(lnkCpTab) == "table" and #lnkCpTab > 0 then
		cp.resetTable()
		for i, v in pairs(lnkCpTab) do
			local myId, myValue = SplitString(":", v)
			myId = tonumber(myId)
			myValue = tonumber(myValue)
			if myId and myValue then
				myId = cp2MapBw[myId]
				local skillData = cp.table[myId]
				if skillData then
					skillData.value = math.min(myValue, skillData.maxValue)
				end
			end
		end
		local lnkCpHb = false
		lnkCpHb = lnkParameter[7] ~= nil and lnkParameter[7] ~= "-" and {SplitString(",", lnkParameter[7])}
		if lnkCpHb and type(lnkCpHb) == "table" and #lnkCpHb > 0 then
			for i=1, 3 do cp.bar[i] = {} end
			for i, v in pairs(lnkCpHb) do
				local myPos, myId = SplitString(":", v)
				myPos = tonumber(myPos)
				myId = tonumber(myId)
				if myId then myId = cp2MapBw[myId] end
				if myPos and myId then
					local myDisc = math.floor((myPos-1) / 4)
					myPos = myPos - (myDisc * 4)
					myDisc = myDisc + 1
					cp.bar[myDisc][myPos] = cp.table[myId]
				end
			end
		end

		cp.updateUnlock()
		cp.updateSum()
		cp.recheckHotbar()

		cp.updateSlottedMarks()
		cp.updateClusterSum()
	end
	
	if not CSPS.treeIsReady then CSPS.createTree()	end		
	CSPS.refreshTree() 
	CSPS.showElement("save", true)
end

local function importCompressed()
	local compressedString = CSPSWindowImportExportTextEdit:GetText()
	if compressedString == nil or compressedString == "" then return end
	local compTable = {SplitString("#", compressedString)}
	local partTable = CSPS.savedVariables.settings.importExportParts -- skills, hotbar, attributes , mundus, cp, gear, quickslots
		
	if not CSPS.treeIsReady then CSPS.createTree() end
	
	local invalidStr = {[""] = true, ["-"] = true}
	
	if compTable[1] and not invalidStr[compTable[1]] and partTable.skills then 
		local prog, pass, crafted, styles, subclasses = SplitString('*', compTable[1])
		CSPS.tableExtract({part1 = prog}, {part1 = pass}, crafted, styles, subclasses)
	end
	
	if compTable[2] and not invalidStr[compTable[2]] and partTable.hotbar then 
		CSPS.hbTables = CSPS.hbExtract(compTable[2]) 
		CSPS.hbLinkToSkills(CSPS.hbTables) 
		CSPS.hbPopulate() 
	end
	
	if compTable[3] and not invalidStr[compTable[3]] and partTable.attributes then CSPS.attrExtract(compTable[3]) end
	
	if compTable[4] and not invalidStr[compTable[4]] and partTable.mundus then CSPS.setMundus(tonumber(compTable[4])) end
	
	if compTable[5] and not invalidStr[compTable[5]] and partTable.cp then
		local cpComp, cpHbComp = SplitString("*", compTable[5])
		cp.extract(cpComp)
		cp.hotBarExtract(cpHbComp, cp.bar)
		cp.updateSidebarIcons()
		cp.updateSlottedMarks()

	end
	
	if compTable[6] and not invalidStr[compTable[6]] and partTable.gear and  not CSPS.moduleExclude.gear then CSPS.setTheGear(CSPS.extractGearString(compTable[6])) end
	
	if compTable[7] and not invalidStr[compTable[7]] and partTable.quickslots then CSPS.extractQS(compTable[7], CSPS.getQsBars()) end
	
	if compTable[8] and not invalidStr[compTable[8]] and partTable.outfit then CSPS.outfits.extract(compTable[8]) end
	
	if compTable[9] and not invalidStr[compTable[9]] then CSPS.role = tonumber(compTable[9]) CSPS.showRole() end
	
	CSPS.refreshTree() 
	CSPS.toggleImportExport(false)
end

local function exportCompressed()
	local partTable = CSPS.savedVariables.settings.importExportParts -- skills, hotbar, attributes , mundus, cp, gear, quickslots
	local compTable = {"-", "-", "-", "-", "-", "-", "-", "-", "-"}
	
	if partTable.skills then 
		local skillTable = CSPS.compressLists()
		
		local prog = {}
		for i, v in pairs(skillTable.prog) do table.insert(prog, v) end
		prog = table.concat(prog, ",")
		local pass = {}
		for i, v in pairs(skillTable.pass) do table.insert(pass, v) end
		pass = table.concat(pass, ",")
		local crafted = skillTable.crafted ~= "" and skillTable.crafted or "-"
		local styles = skillTable.styles ~= "" and skillTable.styles or "-"
		local subclasses = skillTable.subclasses ~= "" and skillTable.subclasses or "-"
		local scribeStyleSubclass = skillTable.scribeStyleSubclass or table.concat({crafted, styles, subclasses}, "*")
		compTable[1] = table.concat({prog ~= "" and prog or "-" , pass ~= "" and pass or "-", scribeStyleSubclass}, "*")
	end
	
	if partTable.hotbar then compTable[2] = CSPS.hbCompress(CSPS.hbTables) or "-" end
	if partTable.attributes then compTable[3] = CSPS.attrCompress(CSPS.attrPoints) or "-" end
	if partTable.mundus then compTable[4] = CSPS.currentMundus or "-" end
	if partTable.role then compTable[9] = CSPS.role or "-" end
	if partTable.cp then
		local cpComp = cp.compress(cp.table) or "-"
		local cpHbComp = cp.hotBarCompress(cp.bar) or "-"
		compTable[5]= string.format("%s*%s", cpComp, cpHbComp)
	end
	
	if  not CSPS.moduleExclude.gear  and partTable.gear then compTable[6] = CSPS.buildGearString() or "-" end
		
	if partTable.quickslots then compTable[7] = CSPS.compressQS(CSPS.getQsBars()) or "-" end
	
	if partTable.outfit then compTable[8] = CSPS.outfits.compress() end
	
	CSPSWindowImportExportTextEdit:SetText(table.concat(compTable, "#"))
end

local transferLevels = {}

function CSPS.transferProfile(cpPSub)
	CSPS.showElement("save", true)
	local myTable
	if not cpPSub then 
		if transferLevels[4] == 0 then
			myTable = CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]
		else
			myTable = CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["profiles"][transferLevels[4]]
		end
		
		if myTable == nil then return end
		
		if myTable.werte == nil then cspsPost( GS(CSPS_NoSavedData)) return end
	elseif cpPSub == 1 then
		myTable = CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["cpProfiles"][transferLevels[4]]
	elseif cpPSub == 2 then
		myTable = CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["cpHbProfiles"][transferLevels[4]]
	end
	if not cpPSub then
		CSPS.loadBuild(nil, myTable)
	end
	
	if cpPSub ~= 2 then
		local cp2Comp = ""
		if not cpPSub then cp2Comp = myTable.cp2werte or "" else cp2Comp = myTable.cpComp or "" end
		cp.resetTable()
		cp.extract(cp2Comp)
	end
	local cp2HbComp = ""
	if not cpPSub then cp2HbComp = myTable.cp2hbwerte or "" else cp2HbComp = myTable.hbComp or "" end
	cp.hotBarExtract(cp2HbComp, cp.bar)
	
	if not CSPS.treeIsReady then CSPS.createTree() end

	cp.updateSidebarIcons()

	cp.updateSlottedMarks()
	
	 CSPS.refreshTree() 
	CSPS.unsavedChanges = false
	CSPS.toggleImportExport(false)
end


function CSPS.transferCPProfile()
	CSPS.transferProfile(1)
end

function CSPS.transferCPHbProfile()
	CSPS.transferProfile(2)
end

function CSPS.transferBindingsDiag(keepThem)
	local sourceName = CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["$lastCharacterName"]
	local destName = CSPS.currentCharData["$lastCharacterName"]
	ZO_Dialogs_ShowDialog(CSPS.name.."_YesNoDiag", 
				{yesFunc = function() CSPS.transferBindings(keepThem) end,
				noFunc = function() end,
				}, 
				{mainTextParams = {zo_strformat(GS(CSPS_ImpExp_TransConfirm), sourceName, destName)}}
				) 
end

function CSPS.transferBindings(keepThem)
	CSPS.showElement("save", true)
	local myTableBd = CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["bindings"] or {}
	local myTableHk = CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["cp2hbpHotkeys"] or {}
	local myTableHb = CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["cpHbProfiles"]
	if myTableHb == nil then cspsPost( GS(CSPS_NoSavedData)) return end
	local myMappings = {}
	local takenInd = 0
	if not keepThem then ZO_ClearNumericallyIndexedTable(CSPS.currentCharData.cpHbProfiles)  end
	for i, _ in pairs(CSPS.currentCharData.cpHbProfiles) do
		if i > takenInd then takenInd = i end
	end
	for i, v in pairs(myTableHb) do
		local newIndex = i + takenInd
		CSPS.currentCharData.cpHbProfiles[newIndex] = v
	end
	for i=1, 20 do
		CSPS.spHotkeysC[i] = {}
	end
	for i, v in pairs(myTableHk) do
		for j, w in pairs(v) do
			CSPS.spHotkeysC[i][j] = w + takenInd
		end
	end
	ZO_DeepTableCopy(myTableBd,  CSPS.bindings)
	CSPS.currentCharData.cp2hbpHotkeys = CSPS.spHotkeysC 
	CSPS.initConnect()
end

local function basicSetupComboBox(myControl, tooltipText, sortItems)
	-- tooltip 
	myControl.data = {tooltipText = tooltipText}
	myControl:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	myControl:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	myControl.comboBox = myControl.comboBox or ZO_ComboBox_ObjectFromContainer(myControl)
	myControl.comboBox:ClearItems()	
	myControl.comboBox:SetSortsItems(sortItems)
	return myControl.comboBox
end

local function updateComboWW()
	local WW = WizardsWardrobe
	if not WW then 
		CSPS.toggleImpExpSource("hub")
		return 
	end
	local wwZone, wwPage, wwSetupIndex = false, false, false
	local ctrNames = {"Server", "Account", "Char", "Profiles", "CPProfiles", "CPHbProfiles"}
	
	local function setupWWLevel(myLevel)
		
		local myControl = CSPSWindowImportExportTransfer:GetNamedChild(ctrNames[myLevel])	
		
		local myComboBox = basicSetupComboBox(myControl, "WizardsWardrobe Import", false) --TODO make tooltip specific
		myControl:SetHidden(false)
		
		if myLevel == 1 then
			wwZone, wwPage, wwSetupIndex = false, false, false
			for i, v in pairs(WW.gui.GetSortedZoneList()) do
				if v then
					myComboBox:AddItem(myComboBox:CreateItemEntry(v.name, function()  
						wwZone = v.tag
						setupWWLevel(2)
					end))
				end
			end
		elseif myLevel == 2 then
			for i, v in pairs(WW.setups[wwZone]) do
				if v then
					myComboBox:AddItem(myComboBox:CreateItemEntry(WW.pages[wwZone][i] and WW.pages[wwZone][i].name or i, function()  
						wwPage = i
						setupWWLevel(3)
					end))
				end
			--WW.setups[zone][page] and WW.setups[zone][page][setupIndex]
			end
		elseif myLevel == 3 then
			for i, v in pairs(WW.setups[wwZone][wwPage]) do
				if v then
					myComboBox:AddItem(myComboBox:CreateItemEntry(v.name, function()  
						importFromWizards(v)
						CSPS.toggleImportExport(false)
					end))
				end
			end
		end		
	end	
	setupWWLevel(1)
end

function CSPS.updateTransferCombo(myLevel, forWW)
	if myLevel == nil then return end
	
	local preselectChoice = false
	
	local cpColTex = CSPS.cpColTex
	local ctrNames = {"Server", "Account", "Char", "Profiles", "CPProfiles", "CPHbProfiles"}
	local myControl = CSPSWindowImportExportTransfer:GetNamedChild(ctrNames[myLevel])
	local myButton = CSPSWindowImportExportTransfer:GetNamedChild(ctrNames[myLevel].."Btn")
	local myPromptNames = {
		GS(CSPS_ImpExp_Transfer_Server).."...", 
		GS(SI_CURRENCYLOCATION3).."...", 		-- Account
		GS(SI_CURRENCYLOCATION0).."...", 		-- Character
		GS(CSPS_ImpExp_Transfer_Profiles),
		GS(CSPS_ImpExp_Transfer_CPP),
		GS(CSPS_ImpExp_Transfer_CPHb)
		}
	
	local choices = {}
	if CSPSSavedVariables == nil then return end
	for i=4, 6 do
		CSPSWindowImportExportTransfer:GetNamedChild(ctrNames[i].."Btn"):SetHidden(true)
	end
	if myLevel < 4 then
		for i=4, 6 do
			CSPSWindowImportExportTransfer:GetNamedChild(ctrNames[i]):SetHidden(true)
			CSPSWindowImportExportTransfer:GetNamedChild(ctrNames[i].."Btn"):SetHidden(true)
		end
		CSPSWindowImportExportTransfer:GetNamedChild("CPHkCopyReplace"):SetHidden(true)
		CSPSWindowImportExportTransfer:GetNamedChild("CPHkCopyAdd"):SetHidden(true)
	end
	if myLevel < 3 then	CSPSWindowImportExportTransfer:GetNamedChild(ctrNames[3]):SetHidden(true) end
	if myLevel < 2 then	CSPSWindowImportExportTransfer:GetNamedChild(ctrNames[2]):SetHidden(true) end
	
	if forWW then
		updateComboWW()
		return
	end
		
	local selectPrompt = myPromptNames[myLevel]
	
	local myComboBox = basicSetupComboBox(myControl, selectPrompt, true) 
	
	-- CSPSSavedVariables["EU Megaserver"]["@Irniben"]["$AccountWide"]["charData"]
	
	-- Nothing is selected, filling the server list
	if myLevel == 1 then	
		for i, _ in pairs(CSPSSavedVariables) do
			choices[i] = i
			if GetWorldName() == i then 
				preselectChoice = i
			end
		end
	-- Server selected, fill account list
	elseif myLevel == 2 then
		for i, _ in pairs(CSPSSavedVariables[transferLevels[1]]) do
			choices[i] = i
			if GetUnitDisplayName("player") == i then preselectChoice = i end
		end

	-- Account selected, fill char list
	elseif myLevel == 3 then
		for i, v in pairs(CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"]) do
			local myName = v["$lastCharacterName"]
		    if myName ~= nil then choices[myName] = i end
		end
	
	-- Char selected, fill and show the profile lists etc.
	elseif myLevel == 4 then
		choices["Standard"] = 0
		if CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["profiles"] ~= nil then
			for i, v in pairs(CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["profiles"]) do
				local myName = v["name"]
				if myName ~= nil then choices[myName] = i end
			end	
		end
		
		CSPSWindowImportExportTransfer:GetNamedChild("CPHkCopyReplace"):SetHidden(false)
		CSPSWindowImportExportTransfer:GetNamedChild("CPHkCopyAdd"):SetHidden(false)
	elseif myLevel == 5 then
		if CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["cpProfiles"] ~= nil then
			for i, v in pairs(CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["cpProfiles"]) do
				local myName = v["name"]
				if myName ~= nil then 
					myName = string.format("|t25:25:%s|t %s", cpColTex[v["discipline"]], myName)
					choices[myName] = i 
				end
			end	
		end
	elseif myLevel == 6 then
		if CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["cpHbProfiles"] ~= nil then
			for i, v in pairs(CSPSSavedVariables[transferLevels[1]][transferLevels[2]]["$AccountWide"]["charData"][transferLevels[3]]["cpHbProfiles"]) do
				local myName = v["name"]
				if myName ~= nil then 
					myName = string.format("|t25:25:%s|t %s", cpColTex[v["discipline"]], myName)
					choices[myName] = i 
				end
			end	
		end
	end
	myControl:SetHidden(false)	
	local function OnItemSelect(_, choiceText, _)
		local myGroup = choices[choiceText] or nil
		transferLevels[myLevel] = myGroup
		if myLevel < 4 then CSPS.updateTransferCombo(myLevel + 1) end
		if myLevel == 3 then
			CSPS.updateTransferCombo(5) 
			CSPS.updateTransferCombo(6) 
		end
		if myLevel > 3 then 
			myButton:SetHidden(false)
			myButton:SetText(GS(CSPS_ImpExp_TransferLoad))
		end
		PlaySound(SOUNDS.POSITIVE_CLICK)
	end

	myComboBox:SetSortsItems(true)
	
	for i,j in pairs(choices) do
		myComboBox:AddItem(myComboBox:CreateItemEntry(i, OnItemSelect))
	end
	
	myComboBox:SetSelectedItem(preselectChoice or selectPrompt)
	
	if preselectChoice then OnItemSelect(_, preselectChoice) end
end

function CSPS.generateLink()
	local formatImpExp = CSPS.savedVariables.settings.formatImpExp
	if not CSPS.treeIsReady then CSPSWindowImportExportTextEdit:SetText(GetString(CSPS_ImpEx_NoData)) return end
	local exportFunctions = {
		txtCP2_1 = function() CSPS.exportTextCP(1) end,
		txtCP2_2 = function() CSPS.exportTextCP(2) end,
		txtCP2_3 = function() CSPS.exportTextCP(3) end,
		hub = exportESOHUB,
		txtExport = textExport,
		csps = exportCompressed,
	}
	
	if exportFunctions[formatImpExp] then exportFunctions[formatImpExp]() end
end

function CSPS.importLink(ctrl, shift, alt, button)
	local importFunctions = {
		hub = importESOHUB,
		sf = importLinkSF,
		csvCP = CSPS.importListCP,
		txtCP2_1 = function()
			CSPS.importTextCP(1, button == 1 and ctrl, shift, button == 2, ctrl)
			-- (discipline, convertMe, sumUp, createDynamicProfile, accountWide)
		end,
		txtCP2_2 = function()
			CSPS.importTextCP(2, button == 1 and ctrl, shift, button == 2, ctrl)
		end,
		txtCP2_3 = function()
			CSPS.importTextCP(3, button == 1 and ctrl, shift, button == 2, ctrl)
		end,
		csps = 	importCompressed,
	}
	importFunctions[CSPS.savedVariables.settings.formatImpExp]()
end