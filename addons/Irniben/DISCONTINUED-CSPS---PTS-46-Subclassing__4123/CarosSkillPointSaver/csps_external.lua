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
	for i, v in ipairs(CSPS.skillTable) do
		if skillTypesT[i] then
			local typeTable = {GS("SI_SKILLTYPE", i)}
			local typeHasEntries = false
			for j, w in ipairs(v) do
				local lineTable = {}
				local lineHasEntries = false
				for k, z in ipairs(w) do
					if z.purchased then
						typeHasEntries = true
						lineHasEntries = true
						local myName = string.format("    - %s", z.name)
						if z.passive then myName = string.format("    - %s (%s)", z.name, z.rank) end
						table.insert(lineTable, myName)
					end
				end
				if lineHasEntries and GetSkillLineId(i, j) ~= 71 then -- don't include emperor skills
					table.insert(typeTable, string.format(" - %s", w.name))
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
				mySkill = string.format("   %s) %s", j, CSPS.skillTable[mySkill[1]][mySkill[2]][mySkill[3]].name)
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

local function generateLinkSF()	
	local lang = string.lower(GetCVar("Language.2"))
	basisUrlTab = {
		["en"] = "https://www.eso-skillfactory.com/en/build-planer/#",
		["de"] = "https://www.eso-skillfactory.com/de/skillplaner/#",
		["fr"] = "https://www.eso-skillfactory.com/fr/planificateur-de-talents/#",
	}
	basisUrl = basisUrlTab[lang] or basisUrlTab["en"]

	-- Skills
	local lnkSkTab = {}
	local skillsToIgnore = {
		[150185] = true, -- armor passives that are auto grant
		[152778] = true,
		[150181] = true,
		[150184] = true,
		[152780] = true,
	}
	for i, skTyp in ipairs(CSPS.skillTable) do
		for j, skLin in ipairs(skTyp) do
			for k, skId in ipairs(skLin) do
				if skId.purchased == true then
					local myRank = skId.rank
					myRank = myRank or 0
					local myId = GetSpecificSkillAbilityInfo(i,j,k,skId.morph,1)
					myId = skillsToIgnore[myId] and "-" or skMap[myId]
					if myId ~= nil then
						if myId ~= "-" then table.insert(lnkSkTab, string.format("%s:%s", myId,myRank)) end
					else
						cspsPost( zo_strformat(GetString(CSPS_ImpEx_ErrSk), skId.name))
					end
				end
			end
		end
	end
	local hbTab = {}
	if CSPS.hbTables ~= nil and CSPS.hbTables ~= {} then
		for ind1= 1, 2 do
			hbTab[ind1] = {}
			for ind2=1,6 do
				local ijk = CSPS.hbTables[ind1][ind2]
				if ijk ~= nil then
					local myId = GetSpecificSkillAbilityInfo(ijk[1],ijk[2],ijk[3],CSPS.skillTable[ijk[1]][ijk[2]][ijk[3]].morph,1)
					myId = skMap[myId]
					if myId ~= nil then
						table.insert(hbTab[ind1], myId)
					else
						table.insert(hbTab[ind1], 0)
					end
				else 
					table.insert(hbTab[ind1], 0)
				end
				
			end
		end
	else
		hbTab = {{"", "", "", "", "", ""}, {"","","","","",""}}
	end
	-- Read CP
	local cpTable = {}
	for skillId, skillData in pairs (cp.table) do
		local myId = cp2Map[skillId]
		if skillData.value ~= 0 and myId then 			
			table.insert(cpTable, string.format("%s:%s", myId, skillData.value))
		end
	end
	local cpHbTable = {}
	for discipline, barData in pairs(cp.bar) do
		for slotIndex, skillData in pairs(barData) do 
			local myPos = (discipline-1) * 4 + slotIndex
			local myId = skillData and cp2Map[skillData.id]
			if myId then
				table.insert(cpHbTable, string.format("%s:%s", myPos, myId))
			end
		end
	end
	-- Generate the whole link 
	-- Alliance, Race, Class, Attributes
	local myAlliance , myRace, myClass = GetUnitAlliance("player"), GetUnitRaceId("player"), GetUnitClassId("player")
	local lnkBaseData = {"v2", 
		alMap[myAlliance] or 0,
		raMap[myRace] or 0, 
		clMap[myClass] or 0,
		CSPS.currentMundus and muMap[CSPS.currentMundus] or 0,
		CSPS.attrPoints[2], 
		CSPS.attrPoints[1], 
		CSPS.attrPoints[3]}
	local linkTable = { } 
	
	CSPS.impExpAddInfo(myAlliance, myRace, myClass)
	showMundus(CSPS.currentMundus)
	
	linkTable[1] = table.concat(lnkBaseData, ",")
	linkTable[2] = table.concat(lnkSkTab, ",") -- includes alliance/race/class because they are separated by , not ;
	
	linkTable[3] = string.format("%s,%s", table.concat(hbTab[1], ":"), table.concat(hbTab[2], ":"))  -- Hotbar 2
	linkTable[4] = "" --setInfo
	if CSPS.BuildSkillFactorySetList then linkTable[4] = CSPS.BuildSkillFactorySetList() end
	linkTable[5] = string.format("%s,%s,%s", unpack(cp.sums))-- cp-sums green blue red
	linkTable[6] = table.concat(cpTable, ",") -- cp as id:value
	linkTable[7] = table.concat(cpHbTable, ",") -- cp hb as pos:id
	linkTable[8] = "" -- placeholder to close with a ;
	local linkParam = table.concat(linkTable, ";")
	theLink = string.format("%s%s", basisUrl, linkParam)
	--CSPSWindowImportExportTextEdit:SetText(theLink)
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
	CSPS.refreshSkillSumsAndErrors()
end

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
	
	CSPS.impExpAddInfo(myAlliance, myRace, myClass)
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
	if lnkGearTab and CSPS.doGear then CSPS.ImportSkillFactorySetList(lnkGearTab) end
	
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
	
	if not CSPS.tabEx then CSPS.createTable()	end		
	CSPS.refreshTree() 
	CSPS.showElement("apply", true)
	CSPS.showElement("save", true)
end

local function importCompressed()
	local compressedString = CSPSWindowImportExportTextEdit:GetText()
	if compressedString == nil or compressedString == "" then return end
	local compTable = {SplitString("#", compressedString)}
	local partTable = CSPS.savedVariables.settings.importExportParts -- skills, hotbar, attributes , mundus, cp, gear, quickslots
		
	if not CSPS.tabEx then CSPS.createTable() end
	
	local invalidStr = {[""] = true, ["-"] = true}
	
	if compTable[1] and not invalidStr[compTable[1]] and partTable.skills then 
		local prog, pass, crafted, styles = SplitString('*', compTable[1])
		CSPS.tableExtract({part1 = prog}, {part1 = pass}, crafted, styles)
	end
	
	if compTable[2] and not invalidStr[compTable[2]] and partTable.hotbars then 
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
	
	if compTable[6] and not invalidStr[compTable[6]] and partTable.gear and CSPS.doGear then CSPS.setTheGear(CSPS.extractGearString(compTable[6])) end
	
	if compTable[7] and not invalidStr[compTable[7]] and partTable.quickslots then CSPS.extractQS(compTable[7], CSPS.getQsBars()) end
	
	if compTable[8] and not invalidStr[compTable[8]] and partTable.outfit then CSPS.outfits.extract(compTable[8]) end
	
	CSPS.refreshTree() 
	CSPS.toggleImportExport(false)
end

local function exportCompressed()
	local partTable = CSPS.savedVariables.settings.importExportParts -- skills, hotbar, attributes , mundus, cp, gear, quickslots
	local compTable = {"-", "-", "-", "-", "-", "-", "-", "-"}
	
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
		compTable[1] = string.format("%s*%s*%s", prog ~= "" and prog or "-" , pass ~= "" and pass or "-", crafted, styles)
	end
	
	if partTable.hotbar then compTable[2] = CSPS.hbCompress(CSPS.hbTables) or "-" end
	if partTable.attributes then compTable[3] = CSPS.attrCompress(CSPS.attrPoints) or "-" end
	if partTable.mundus then compTable[4] = CSPS.currentMundus or "-" end
	if partTable.cp then
		local cpComp = cp.compress(cp.table) or "-"
		local cpHbComp = cp.hotBarCompress(cp.bar) or "-"
		compTable[5]= string.format("%s*%s", cpComp, cpHbComp)
	end
	
	if CSPS.doGear and partTable.gear then compTable[6] = CSPS.buildGearString() or "-" end
		
	if partTable.quickslots then compTable[7] = CSPS.compressQS(CSPS.getQsBars()) or "-" end
	
	if partTable.outfit then compTable[8] = CSPS.outfits.compress() end
	
	CSPSWindowImportExportTextEdit:SetText(table.concat(compTable, "#"))
end

local transferLevels = {}

function CSPS.transferProfile(cpPSub)
	CSPS.showElement("apply", true)
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
		local skillTableClean = myTable.werte
		local attrComp = myTable.attribute
		local hbComp = myTable.hbwerte
		CSPS.tableExtract(skillTableClean.prog, skillTableClean.pass, skillTableClean.crafted, skillTableClean.styles)
			
		if CSPS.doGear then
			local gearComp = myTable.gearComp or ""
			local gearCompUnique = myTable.gearCompUnique or ""
			CSPS.setTheGear(CSPS.extractGearString(gearComp, gearCompUnique))
		end
		
		CSPS.extractQS(myTable.qs, CSPS.getQsBars())
		
		CSPS.hbTables = CSPS.hbExtract(hbComp)
		CSPS.hbLinkToSkills(CSPS.hbTables)
		CSPS.hbPopulate()
		CSPS.attrExtract(attrComp)
		CSPS.refreshSkillSumsAndErrors()
		
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
	
	if not CSPS.tabEx then CSPS.createTable() end

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
	CSPS.showElement("apply", true)
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

function CSPS.updateTransferCombo(myLevel)
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
		
	local selectPrompt = myPromptNames[myLevel]
		-- tooltip 
	myControl.data = {tooltipText = selectPrompt}
	myControl:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	myControl:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	myControl.comboBox = myControl.comboBox or ZO_ComboBox_ObjectFromContainer(myControl)
	local myComboBox = myControl.comboBox
	myComboBox:ClearItems()
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
	if not CSPS.tabEx then CSPSWindowImportExportTextEdit:SetText(GetString(CSPS_ImpEx_NoData)) return end
	local exportFunctions = {
		txtCP2_1 = function() CSPS.exportTextCP(1) end,
		txtCP2_2 = function() CSPS.exportTextCP(2) end,
		txtCP2_3 = function() CSPS.exportTextCP(3) end,
		sf = function() generateLinkSF() showLink() end,
		txtExport = textExport,
		csps = exportCompressed,
	}
	
	if exportFunctions[formatImpExp] then exportFunctions[formatImpExp]() end
end

function CSPS.importLink(ctrl, shift, alt, button)
	local importFunctions = {
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