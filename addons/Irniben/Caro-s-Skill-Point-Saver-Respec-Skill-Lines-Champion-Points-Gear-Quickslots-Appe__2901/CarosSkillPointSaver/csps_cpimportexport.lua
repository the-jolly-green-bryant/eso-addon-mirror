local GS = GetString
local cspsPost = CSPS.post
local cspsD = CSPS.cspsD
local cp = CSPS.cp

local cpNameKeys = CSPS.cpNameKeys
local numMapSuccessful = 0
local unmappedSkills = {}
local mappingIndex = 1
local cpSkillToMap = nil
local cpDisciToMap = nil
local numRemapped = 0
local mappingUnclear = {}
local numMapUnclear = 0
local numMapCleared = 0
local skillsToImport = {}
local skillsToSlot = {}
local markedToSlot = {}
local slotMarkers = false
local newProfileBringToTop = nil




function CSPS.importListCP()
	local theLink = CSPSWindowImportExportTextEdit:GetText()
	if theLink == nil or theLink == "" then return end
	local lnkParameter = {SplitString(";", theLink)}
	if lnkParameter == nil then return end
	local lnkSkills = lnkParameter[1]
	local lnkHb = ""
	local importedDisciplines = {}
	local importedAnything = false
	if #lnkParameter > 1 then 
		lnkHb = lnkParameter[2]
	end
	lnkSkills = {SplitString(",", lnkSkills)}
	local discLists = {{}, {}, {}}
	for i, v in pairs(lnkSkills) do
		local skId, skValue = SplitString(":", v)
		skId = tonumber(skId)
		skValue = tonumber(skValue)
		if skId and skValue then
			local skillData = cp.table[skId]
			if skillData then
				if discLists[skillData.discipline] ~= nil then
					table.insert(discLists[skillData.discipline], {skId, math.min(skValue, skillData.maxValue)})
				end
			end
		end
	end
	for disciplineIndex, myList in pairs(discLists) do
		importedDisciplines[disciplineIndex] = false
		local remainingPoints = 42000
		if CSPS.cpImportCap then
			remainingPoints = GetNumSpentChampionPoints(GetChampionDisciplineId(disciplineIndex)) + GetNumUnspentChampionPoints(GetChampionDisciplineId(disciplineIndex))
		end
		if #myList > 0 then
			cp.resetTable(disciplineIndex)
			for i, v in pairs(myList) do
				local skId, newValue = unpack(v)
				if newValue and newValue - cp.table[skId].value <= remainingPoints then 
					remainingPoints = remainingPoints -  newValue + cp.table[skId].value
					cp.table[skId].value = newValue
				end
			end
			cp.updateUnlock(disciplineIndex)
			cp.updateSum(disciplineIndex)
			importedDisciplines[disciplineIndex] = true
			importedAnything = true
		end
	end
	cp.updateClusterSum()
	lnkHb = {SplitString(",", lnkHb)}
	local hbTables = {{},{}, {}}
	for i,v in pairs(lnkHb) do
		local skId = tonumber(v)
		local myDisc = cp.table[skId].discipline
		if myDisc ~= nil then 
			if hbTables[myDisc] ~= nil then
				table.insert(hbTables[myDisc], skId)
			end
		end
	end
	
	for i, v in pairs(hbTables) do
		if #v > 0 then
			importedAnything = true
			cp.bar[i] = {}
			for j, w in pairs(v) do
				table.insert(cp.bar[i], cp.table[w])
			end
		end
	end
	if not importedAnything then return end
	cp.recheckHotbar()

	cp.updateSlottedMarks()
	if not CSPS.treeIsReady then 
		CSPS.createTable(true) -- Create the treeview for CP only if no treeview exists yet
		CSPS.toggleCP(0, false)
	end
	for i, v in pairs( importedDisciplines) do
		CSPS.toggleCP(i, v)
	end	
	 CSPS.refreshTree()
	
	CSPS.toggleImportExport(false)
	changedCP = true
	CSPS.showElement("save", true)
end

local function tryToSlot(myDiscipline)
	local unslottedSkills = {}
	if #skillsToSlot > 0 then
		if #skillsToSlot < 5 then
			cp.bar[myDiscipline] = skillsToSlot
		else
			cp.bar[myDiscipline] = {}
			for _, skillData in pairs(skillsToSlot) do
				if v.jumpPoints then
					if skillData.value < skillData.jumpPoints[2] then 
						table.insert(unslottedSkills, skillData.id)
					else
						if #cp.bar[myDiscipline] < 4 then 
							table.insert(cp.bar[myDiscipline], skillData)
						else	
							table.insert(unslottedSkills, skillData.id)
						end
					end
				else 
					if #cp.bar[myDiscipline] < 4 then 
						table.insert(cp.bar[myDiscipline], skillData) 
					else
						table.insert(unslottedSkills, skillData.id)
					end
				end
			end
		end
	end
	if #unslottedSkills > 0 then
		cspsPost(GS(CSPS_MSG_Unslotted))
		for  i,v in pairs(unslottedSkills) do
			cspsPost(cpColors[cp.table[v].discipline]:Colorize(zo_strformat(" - <<C:1>>", GetChampionSkillName(v))), true)
		end
	end	
end

local function applyCPMapping()
		tryToSlot(cpDisciToMap)
		cp.updateUnlock(cpDisciToMap)
		cp.updateSum(cpDisciToMap)
		cp.updateClusterSum()
		cp.recheckHotbar(cpDisciToMap)
		cp.updateSlottedMarks()		
		CSPS.toggleCP(cpDisciToMap, true)
		 CSPS.refreshTree()
		CSPS.showElement("save", true)
		changedCP = true
		CSPS.showElement("cpImport", true)
end

local function updateCPMapProg()
	CSPSWindowCPImportSuccessNum:SetText(numMapSuccessful + numRemapped + numMapCleared)
	CSPSWindowCPImportOpenNum:SetText(#unmappedSkills + #mappingUnclear + 1 - mappingIndex) 
	if mappingIndex <= #unmappedSkills + #mappingUnclear then 
		local mapMe = nil
		if mappingIndex <= #mappingUnclear then 
			cpSkillToMap = cpSkillToMap or mappingUnclear[mappingIndex][1] 
			mapMe = mappingUnclear[mappingIndex][2] 
			CSPSWindowCPImportMapText:SetText(mappingUnclear[mappingIndex][3])
		else
			CSPSWindowCPImportMapText:SetText(unmappedSkills[mappingIndex - #mappingUnclear][1])
			mapMe = unmappedSkills[mappingIndex - #mappingUnclear][2]
			
		end
		-- CSPSWindowSubProfiles:SetHeight(277)
		CSPSWindowSubProfiles:SetAnchor(BOTTOMRIGHT, CSPSWindowSPPlaceholder, RIGHT, -7, 150)
		CSPSWindowCPImportMap:SetHidden(false)
		CSPSWindowCPImportMapApply:SetEnabled(cpSkillToMap ~= nil)
		CSPSWindowCPImportClose:SetHidden(true)
		CSPSWindowCPImportMapNote:SetText(GS(CSPS_CPImp_Note))
		CSPS.inCpRemapMode = true
		if cpSkillToMap ~= nil then
			CSPSWindowCPImportMapNew:SetText(zo_strformat(GS(CSPS_CPImp_New), cpColors[cpDisciToMap]:ToHex(), mappingIndex, #unmappedSkills + #mappingUnclear, mapMe, GetChampionSkillName(cpSkillToMap)))
		else
			CSPSWindowCPImportMapNew:SetText(zo_strformat(GS(CSPS_CPImp_New), cpColors[cpDisciToMap]:ToHex(), mappingIndex, #unmappedSkills + #mappingUnclear,  mapMe, "?"))
		end		
	else
		CSPS.inCpRemapMode = false
		CSPSWindowCPImportClose:SetHidden(false)
		CSPSWindowCPImportMap:SetHidden(true)
		applyCPMapping()
		-- CSPSWindowSubProfiles:SetHeight(77)
		CSPSWindowSubProfiles:SetAnchor(BOTTOMRIGHT, CSPSWindowBuild, BOTTOMRIGHT, 0, 5 + 77)
	end
end

function CSPS.cpDiscardMap()
	mappingIndex = mappingIndex + 1
	cpSkillToMap = nil
	updateCPMapProg()
end

function CSPS.cpDiscardAll()
	mappingIndex = #unmappedSkills + #mappingUnclear + 1
	cpSkillToMap = nil
	updateCPMapProg()
end

function CSPS.cpDoMap()
	if cpSkillToMap == nil then return end
	local skillData = cp.table[cpSkillToMap]
	local mapMe = nil
	if mappingIndex <= #mappingUnclear then
		mapMe = mappingUnclear[mappingIndex][2]
		if skillData.maxValue < mapMe then cspsPost(GS(CSPS_CPValueTooHigh)) return end
		numMapCleared = numMapCleared + 1
		numMapUnclear = numMapUnclear - 1
	else
		mapMe = unmappedSkills[mappingIndex - #mappingUnclear][2]
		if skillData.maxValue < mapMe then cspsPost(GS(CSPS_CPValueTooHigh)) return end
		numRemapped = numRemapped + 1
	end
	skillData.value = mapMe
	
	if CanChampionSkillTypeBeSlotted(GetChampionSkillType(cpSkillToMap)) and (markedToSlot[cpSkillToMap] or not slotMarkers) then
		table.insert(skillsToSlot, skillData)
	end
	 CSPS.refreshTree()
	mappingIndex = mappingIndex + 1
	updateCPMapProg()
end

function CSPS.remapClicked(control, skillData, mouseButton)
	if CSPSWindowCPImport:IsHidden() then CSPS.inCpRemapMode = false return end
	if cpDisciToMap ~= skillData.discipline then return end
	cpSkillToMap = skillData.id
	updateCPMapProg()
end

function CSPS.cleanUpText()
	local myText = CSPSWindowImportExportTextEdit:GetText()
	myText = string.gsub(myText, "(%d+%-%d+)", "") -- remove CP ranges ("CP 100-180")
	myText = string.gsub(myText, "[^a-z0-9A-Z%s]", "") -- remove special characters
	CSPSWindowImportExportTextEdit:SetText(myText)
end

function CSPS.checkTextExportCP(myDiscipline)
	if string.lower(GetCVar("Language.2")) == "en" then CSPS.exportTextCP(myDiscipline, true) return end
	ZO_Dialogs_ShowDialog(CSPS.name.."_YesNoDiag", 
		{
			yesFunc = function() CSPS.exportTextCP(myDiscipline, false) end,
			noFunc = function() CSPS.exportTextCP(myDiscipline, true) end,
		}, 
		{
			mainTextParams = {GS(CSPS_MSG_ExpTextLang)}
		}
	) 
end

function CSPS.exportTextCP(myDiscipline)
	local exportSlotted = {}
	for i, skillData in pairs(cp.bar[myDiscipline]) do
		exportSlotted[skillData.id] = true
	end
	cpNameKeys = CSPS.cpNameKeys
	local CSPScpNameKeysRev = {}
	if not CSPS.cpImportLang then
		for i, v in pairs(cpNameKeys[myDiscipline]) do
			CSPScpNameKeysRev[v] = i
		end
	end
	local exportList = {}
	local function insertInExportList(myId)
		local skillData = myId ~= -1 and cp.table[myId]
		if skillData and skillData.unlocked and skillData.value > 0 then
				local mySkillName = CSPS.cpImportLang and zo_strformat("<<C:1>>", GetChampionSkillName(myId)) or CSPScpNameKeysRev[myId]
				local mySlotText = exportSlotted[myId] and " (slot)" or ""
				local myTextLine = ""
				if CSPS.cpImportReverse == 2 then
					myTextLine = string.format("%s%s %s", mySkillName, mySlotText,  skillData.value)
				elseif CSPS.cpImportReverse == 3 then
					myTextLine = string.format("%s %s%s", mySkillName, skillData.value, mySlotText)
				else
					myTextLine = string.format("%s %s%s", skillData.value, mySkillName, mySlotText) 
				end
				table.insert(exportList, myTextLine)
		end
	end
	for _, skillData in pairs(cp.sortedLists[myDiscipline]) do	-- not sorted by id
		if skillData.cluster then
			for _, clusterSkillData in pairs(skillData.cluster) do
				insertInExportList(clusterSkillData.id)
			end
		else
			insertInExportList(skillData.id)
		end
	end
	CSPSWindowImportExportTextEdit:SetText(table.concat(exportList, "\n"))
end

function CSPS.checkCPNameKeys(engl)
	cpNameKeys = CSPS.cpNameKeys
	local myList = {}
	CSPScpNameKeysT = {}
	for i, v in pairs(cpNameKeys) do
		for j, w in pairs(v) do
			CSPScpNameKeysT[w] = j
		end
	end
	for skillId, skillData in pairs(cp.table) do
		local myNameKey = zo_strformat("<<C:1>>", GetChampionSkillName(skillId))
		myNameKey = string.gsub(string.lower(myNameKey), "[^a-z]", "")
		if not CSPScpNameKeysT[skillId] then 
			table.insert(myList, string.format('["%s"] = %s --%s', myNameKey, skillId, skillData.discipline))
		elseif engl then
			if CSPScpNameKeysT[skillId] ~= myNameKey then cspsPost(string.format("Changed: %s from %s to %s", skillId, CSPScpNameKeysT[skillId], myNameKey)) end
		end
	end
	cspsPost(myList)
	CSPSWindowImportExportTextEdit:SetText(table.concat(myList, "\n"))
end

local function getLocalizedNameKeys()
	local nameKeys = {{},{},{}}
	for skillId, skillData in pairs(cp.table) do
		local myNameKey = zo_strformat("<<C:1>>", GetChampionSkillName(skillId))
		myNameKey = string.gsub(string.lower(myNameKey), "[^a-z]", "")
		nameKeys[skillData.discipline][myNameKey] = skillId
	end
	return nameKeys
end

function CSPS.importTextCP(myDiscipline, convertMe, sumUp, createDynamicProfile, accountWide)
	local myText = CSPSWindowImportExportTextEdit:GetText()
	local myStartPos = 1
	local myImportTable = {}
	local reverseOrder = false
	local slotPrevious = false
	if CSPS.cpImportReverse == 2 then
		reverseOrder = true 
	elseif CSPS.cpImportReverse == 3 then 
		reverseOrder = true 
		slotPrevious = true
	end
	cpNameKeys = CSPS.cpImportLang and getLocalizedNameKeys() or CSPS.cpNameKeys
	markedToSlot = {}
	markedAsBase = {}
	slotMarkers = false
	-- myText = string.gsub(myText, "%b()", "")
	myText = string.format("%s\n", myText)
	while true do
		local i, j = string.find(myText, "%d+", myStartPos)
		if i == nil then break end
		local k = string.find(myText, "%d+", j + 1)
		local nextLine = string.find(myText, "\n", j + 1)
		local myValue = tonumber(string.sub(myText, i, j))
		local myEndPos = -1
		if k ~= nil or nextLine ~= nil then 
			if k == nil or nextLine == nil then myEndPos = k or nextLine else myEndPos = math.min(k, nextLine) end
			myEndPos = myEndPos - 1
		end
		local mySubString = string.sub(myText, j + 1, myEndPos)
		if reverseOrder then 
			mySubString = string.sub(myText, myStartPos, i)
			k = j + 1
		end
		local mySubStringOneLine = string.gsub(mySubString, "\n", " ")
		local mySubstringSimple = string.gsub(string.lower(mySubString), "[^a-z]", "")
        if string.len(mySubStringOneLine) > 84 then mySubStringOneLine = string.sub(mySubStringOneLine, 1, 84) end
		table.insert(myImportTable, {mySubstringSimple, myValue, mySubStringOneLine})
		if k == nil then break end
		myStartPos = k
	end
	skillsToImport = {}
	unmappedSkills = {}
	numMapSuccessful = 0
	numRemapped = 0
	mappingIndex = 1
	mappingUnclear = {}
	numMapUnclear = 0
	numMapCleared = 0
	local namesChecked = {}
	-- Trying to map the normalized skill names directly to keys
	for i, v in pairs(myImportTable) do
		local myKey = cpNameKeys[myDiscipline][v[1]]
		local mustSlot = string.find(v[1], "slot")
		local isBasestat = string.find(v[1], "basestat")
		if myKey ~= nil then
			if v[2] > GetChampionSkillMaxPoints(myKey) or GetChampionAbilityId(myKey) == 0 then 
				local cpSkName = GetChampionSkillName(myKey)
				cpSkName = cpSkName ~= "" and cpSkName or v[1]
				table.insert(mappingUnclear , {myKey, v[2], cpSkName})
				namesChecked[myKey] = true
				numMapUnclear = numMapUnclear + 1	
				if mustSlot then 
					if slotPrevious then
						markedToSlot[mappingUnclear[#mappingUnclear-1][1]] = true 
					else
						markedToSlot[myKey] = true 
					end
					slotMarkers = true
				end
				if isBasestat then markedAsBase[myKey] = true end
			else
				table.insert(skillsToImport, {myKey, v[2]})
				namesChecked[myKey] = true
				if mustSlot then 
					if slotPrevious then
						markedToSlot[skillsToImport[#skillsToImport-1][1]] = true
					else
						markedToSlot[myKey] = true 
					end
					slotMarkers = true
				end
				if isBasestat then markedAsBase[myKey] = true end
				numMapSuccessful = numMapSuccessful + 1
			end
		else
			-- Go through all keys and check if they at least fit partwise
			local myMinStart = string.len(v[1])
			local myMinStartB = 42
			if myMinStart > 4 and v[2] <= 100 then
				local keyInString = nil
				local stringInKey = nil
				for j,w in pairs(cpNameKeys[myDiscipline]) do
					if (not namesChecked[j]) or convertMe or createDynamicProfile then
						-- Check if the normalized skill name is part of the namekey
						local startA = string.find(v[1], j)
						-- Check if the namekey is part of the normalized skill name
						local startB = string.find(j, v[1])
						if startA ~= nil then
							if startA < myMinStart then 
								myMinStart = startA 
								keyInString = j 
							end
						end
						if startB ~= nil then
							if startB < myMinStartB then
								myMinStartB = startB
								stringInKey = j
							end
						end
					end
				end
				if keyInString ~= nil then
					myKey = cpNameKeys[myDiscipline][keyInString]
					table.insert(skillsToImport, {myKey, v[2]})
					namesChecked[myKey] = true
					if mustSlot then 
						if slotPrevious then
							markedToSlot[skillsToImport[#skillsToImport-1][1]] = true
						else
							markedToSlot[myKey] = true 
						end
						slotMarkers = true
					end
					if isBasestat then markedAsBase[myKey] = true end
					numMapSuccessful = numMapSuccessful + 1
				elseif stringInKey then
					if string.len(v[1]) > string.len(stringInKey) / 2 then
						myKey = cpNameKeys[myDiscipline][stringInKey]
						table.insert(skillsToImport, {myKey, v[2]})
						numMapSuccessful = numMapSuccessful + 1
						if mustSlot then 
							if slotPrevious then
								markedToSlot[skillsToImport[#skillsToImport-1][1]] = true
							else
								markedToSlot[myKey] = true 
							end
							slotMarkers = true
						end
						if isBasestat then markedAsBase[myKey] = true end
					else
						myKey = cpNameKeys[myDiscipline][stringInKey]
						table.insert(mappingUnclear , {myKey, v[2], v[3]})
						numMapUnclear = numMapUnclear + 1
						if mustSlot then 
							if slotPrevious then
								markedToSlot[mappingUnclear[#mappingUnclear-1][1]] = true
							else
								markedToSlot[myKey] = true 
							end
							slotMarkers = true
						end
						if isBasestat then markedAsBase[myKey] = true end
					end
					namesChecked[myKey] = true
				end
			end
		end
		if myKey == nil then
			table.insert(unmappedSkills, {v[3], v[2]})
		end
	end
		
	if convertMe or createDynamicProfile then
		local myRole =  GetSelectedLFGRole()
		local myName = GS(CSPS_Txt_NewProfile2)
		if myRole ~= 3 then 
			myName = CSPS.getProfileNameAbbr(myName)
		end
		if myRole == 1 and  CSPS.isMagOrStam() > 0 then myRole = 4 + CSPS.isMagOrStam() end
		if myRole == 3 then myRole = 7 end

		local convPreset = {
			"[x] = {",
			"\tname = \"Put name here\",",
			"\twebsite = \"Put source URL here (as short as possible)\",",
			os.date("\tupdated = {%m, %d, %Y},"),
			"\tpoints = \"(dynamic)\",",
			string.format("\tsource = \"%s\",", GetDisplayName()),
			string.format("\trole = %s,", myRole),
			string.format("\tdiscipline = %s,", myDiscipline),
			"\tpreset = {",
		}
		local setValue = {}
		local myDynamicList = {}
		for i, v in pairs(skillsToImport) do
			if setValue[v[1]] ~= v[2] or sumUp then
				local thisValue = v[2]
				if sumUp and setValue[v[1]] ~= 0 and setValue[v[1]] ~= nil then
					thisValue = thisValue + setValue[v[1]]
				end
				setValue[v[1]] = thisValue
				table.insert(convPreset, string.format("\t\t{%s, %s},", v[1], thisValue))
				table.insert(myDynamicList, string.format("%s-%s", v[1], thisValue))
			end
		end
		table.insert(convPreset, "\t},")
		
		local mySlottables = {}
		local maxFour = 1
		for i, v in pairs(markedToSlot) do
			if CanChampionSkillTypeBeSlotted(GetChampionSkillType(i)) then
				table.insert(mySlottables, i)
				maxFour = maxFour + 1
				if maxFour == 5 then break end
			end
		end
		local myBasestats = {}
		maxFour = 1 -- ok actually max three now
		for i,v in pairs( markedAsBase) do
			table.insert(myBasestats, i)
			maxFour = maxFour + 1
			if maxFour == 4 then break end
		end
		mySlottables = table.concat(mySlottables, ",")
		myBasestats = table.concat(myBasestats, ",")
		mySlottables = mySlottables or ""
		myBasestats = myBasestats or ""
		table.insert(convPreset, string.format("\tbasestatsToFill = {%s},", myBasestats))
		table.insert(convPreset, string.format("\tslotted = {%s},", mySlottables))
		table.insert(convPreset, "}")
		if createDynamicProfile then 
			local myDynamicProfile = {
				["name"] = myName,
				["cpComp"] = table.concat(myDynamicList, ";"),
				["hbComp"] = mySlottables,
				["points"] = "(dynamic)",
				["discipline"] = myDiscipline,
				["isNew"] = true,
			}
			CSPS.savedVariables.cpProfiles = CSPS.savedVariables.cpProfiles or {}
			CSPS.currentCharData.cpProfiles = CSPS.currentCharData.cpProfiles or {}
			if accountWide then
				table.insert(CSPS.savedVariables.cpProfiles, myDynamicProfile)
			else
				table.insert(CSPS.currentCharData.cpProfiles, myDynamicProfile)
			end
			CSPS.toggleImportExport(false)
			
			newProfileBringToTop = true
			if CSPS.subProfileList then CSPS.subProfileList:RefreshData()	end
			if CSPSWindowSubProfiles:IsHidden() == true or CSPS.subProfileDiscipline ~= myDiscipline then 
				CSPS.subProfileType = accountWide and 1 or 2
				CSPS.showSubProfileDiscipline(myDiscipline) 
			end
			for i, v in pairs(CSPS.savedVariables.cpProfiles) do
				v.isNew = nil
			end
			for i, v in pairs(CSPS.currentCharData.cpProfiles) do
				v.isNew = nil
			end
			for i, v in pairs(CSPS.currentCharData.cpHbProfiles) do
				v.isNew = nil
			end
		else
			local myConvertedText = table.concat(convPreset, "\n")
			CSPSWindowImportExportTextEdit:SetText(myConvertedText)
		end
		return
	end
	local remainingPoints = 42000
	if CSPS.cpImportCap then
		remainingPoints = GetNumSpentChampionPoints(GetChampionDisciplineId(disciplineIndex)) + GetNumUnspentChampionPoints(GetChampionDisciplineId(disciplineIndex))
	end
	if #skillsToImport + #unmappedSkills + numMapUnclear > 0 then
		cp.resetTable(myDiscipline)
		skillsToSlot = {}
		local skillsToSlotRev = {}
		for i, v in pairs( skillsToImport) do
			local skillData = cp.table[v[1]]
			if skillData then
				v[2] = math.min(v[2], skillData.maxValue)
				if v[2] <= remainingPoints + skillData.value then
					remainingPoints = remainingPoints - v[2] + skillData.value
					skillData.value = v[2] 
					if CanChampionSkillTypeBeSlotted(GetChampionSkillType(v[1])) and not skillsToSlotRev[v[1]] and  (markedToSlot[v[1]] or not slotMarkers) then
						table.insert(skillsToSlot, skillData)
						skillsToSlotRev[v[1]] = true
					end
				end
			end
		end
		cp.updateSum(myDiscipline)
		cp.updateClusterSum()
		if not CSPS.treeIsReady then 
			CSPS.createTable(true) -- Create the treeview for CP only if no treeview exists yet
			CSPS.toggleCP(0, false)
		end
		
		CSPS.openTreeToSection(4, myDiscipline)
		
		CSPS.toggleCP(myDiscipline, true)
		CSPS.refreshTree()
		CSPS.toggleImportExport(false)
		CSPS.showElement("save", false)
		CSPS.showElement("cpImport", true)
		cpDisciToMap = myDiscipline
		updateCPMapProg()
	else
		cspsPost(GS(CSPS_CPImp_NoMatch))
	end
end
