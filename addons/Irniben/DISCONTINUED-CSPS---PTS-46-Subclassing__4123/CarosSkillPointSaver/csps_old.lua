-- containing compability functions only used if saved variables come from an older version...

local GS = GetString
local skillTable = CSPS.skillTable

local needMapping = false
local updNeedMapping = false

local classReMap = false
local raceReMap = false
local skLocMappings = {}

local function createReMaps()
	classReMap = {}
	local classSkills = {
		[1] = {35,36,37},		-- DK
		[2] = {41,42,43}, 		-- Sorc
		[3] = {38,39,40}, 		-- NB
		[4] = {127,128,129}, 	-- Warden
		[5] = {131,132,133},	-- Necro
		[6] = {22,27,28}, 		-- Temp
		[117] = {218, 219, 220},
	}
	
	local auxClassMap = {} 
	local auxSkillLineMap = {}
	for i, v in pairs(classSkills) do 
		for j=1, 3 do 
			auxClassMap[v[j]] = i
			auxSkillLineMap[v[j]] = j
		end 
	end
	for i=1, GetNumClasses()*3 do
		local lineId = GetSkillLineId(1, i)
		classReMap[auxClassMap[lineId]] = classReMap[auxClassMap[lineId]] or {}
		classReMap[auxClassMap[lineId]][auxSkillLineMap[lineId]] = i
	end

	raceReMap = {}
	local raceSkillsT = {
		[60] = 1, --Breton
		[62] = 2, --Redguard
		[52] = 3, --Orc
		[64] = 4, --Dark elf
		[65] = 5, --North
		[63] = 6, --Argonian
		[56] = 7, --Highelf
		[57] = 8, --Dunmer
		[58] = 9, --Khajiit
		[59] = 10, --Imperial
	}
	for i=1, 10 do
		local lineId = GetSkillLineId(7, i)
		raceReMap[raceSkillsT[lineId]] = i
	end

	return classReMap, raceReMap
end

-- Compare keys to see if data has been saved in a different language
-- Generate subkeys

local function hkGenerate(i)
	local auxKey = string.format("%s-%s", 1, GetSkillLineId(i, 1))
	for j=2, GetNumSkillLines(i) do
		auxKey = string.format("%s,%s-%s", auxKey, j, GetSkillLineId(i, j))
	end
	return auxKey
end

-- Generate keys to compare

local function generateKeys()
	local aKey = {hkGenerate(4), hkGenerate(5), hkGenerate(6), hkGenerate(8)}
	return table.concat(aKey, ";")
end

-- Compare keys

function CSPS.compareKeys()
	needMapping = false
	if CSPS.currentCharData.myKeys == nil then return end
	local myKeys = generateKeys()
	if CSPS.currentCharData.myKeys == myKeys then return myKeys end
	local allKeys = {SplitString(";", CSPS.currentCharData.myKeys)}
	local myKeyMap = {4, 5, 6, 8} -- skill types that are ordered alphabetically
	skLocMappings = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
	for i,k in pairs(myKeyMap) do --generating table with mappings for all skill lines
		for j=1, GetNumSkillLines(k) do
			skLocMappings[i][j] = j
		end
	end	
	for keyInd1, aKey in pairs(allKeys) do
		local auxKey = {SplitString(",", aKey)}
		for keyInd2, v in pairs(auxKey) do
			local sklNum, sklInd = SplitString("-", v)
			local _, meineLinie = GetSkillLineIndicesFromSkillLineId(tonumber(sklInd)) 
			skLocMappings[myKeyMap[keyInd1]][tonumber(sklNum)] = meineLinie
		end
	end
	needMapping = true
	return myKeys
end

function CSPS.mapSkills(myKeys)
	local morphs, upgrades = CSPS.skTableExtract(CSPS.currentCharData.werte.prog, CSPS.currentCharData.werte.pass)
	local auxTable = CSPS.compressLists(morphs, upgrades)
	CSPS.currentCharData.werte = auxTable
	if needMapping then
		local auxHbTable = CSPS.hbExtract(CSPS.currentCharData.hbwerte)
		CSPS.currentCharData.hbwerte = CSPS.hbCompress(auxHbTable)
	end
	for i, v in pairs(CSPS.profiles) do
		if v.werte ~= nil then
			local morphs, upgrades = CSPS.skTableExtract(v.werte.prog, v.werte.pass)
			local auxTable = CSPS.compressLists(morphs, upgrades)
			v.werte = auxTable
			if needMapping then
				local auxHbTable = CSPS.hbExtract(v.hbwerte)
				auxHbTable = CSPS.hbCompress(auxHbTable)
				v.hbwerte = auxHbTable
			end
		end
	end
	
	if needMapping then 
		d(string.format("[CSPS] %s", GS(CSPS_TxtLangDiff)))
	end
	needMapping = false
	CSPS.currentCharData.myKeys = myKeys
	CSPS.currentCharData.svApi = GetAPIVersion()	
	CSPS.currentCharData.profiles = CSPS.profiles
	updNeedMapping = false
end

function CSPS.convertAllCharsToAbilityIDs()
	createReMaps()
	for charInd=1, GetNumCharacters() do
		local name, _, _, classId, raceId, _, charId = GetCharacterInfo(charInd)
		local thisData = CSPS.savedVariables.charData[charId]
		if thisData and thisData.werte and not (thisData.werte.prog.part1 or thisData.werte.pass.part1) then
			local morphs, upgrades = {}, {}
			if type(thisData.werte.prog) == "table" or type(thisData.werte.pass) == "table" then 
				morphs, upgrades = CSPS.oldSkExtract(thisData.werte.prog, thisData.werte.pass, raceId, classId)
			else
				morphs, upgrades = CSPS.skTableExtract(thisData.werte.prog, thisData.werte.pass)
			end
			local thisHotbar = CSPS.hbExtract(thisData.hbwerte, classId)
			local auxTable = CSPS.compressLists(morphs, upgrades)
			local auxHB = CSPS.hbCompress(thisHotbar)
			thisData.werte = auxTable
			thisData.hbwerte = auxHB
			if thisData.profiles and type(thisData.profiles) == "table" then
				for profIndex, thisProfile in pairs(thisData.profiles) do
					if thisProfile.werte and not (thisProfile.werte.pass.part1 or thisProfile.werte.prog.part1) then
						local proMorphs, proUpgrades = {}, {}
						if type(thisProfile.werte.prog) == "table" or type(thisProfile.werte.pass) == "table" then 
							proMorphs, proUpgrades = CSPS.oldSkExtract(thisProfile.werte.prog, thisProfile.werte.pass, raceId, classId)
						else
							proMorphs, proUpgrades = CSPS.skTableExtract(thisProfile.werte.prog, thisProfile.werte.pass)
						end
						local thisHotbar2 = CSPS.hbExtract(thisProfile.hbwerte, classId)
						local auxTable2 = CSPS.compressLists(proMorphs, proUpgrades)
						local auxHB2 = CSPS.hbCompress(thisHotbar2)
						thisProfile.werte = auxTable2
						thisProfile.hbwerte = auxHB2
					end
				end
			end
			thisData.myKeys = nil
		end
	end
	CSPS.freshlyConverted = true
	CSPS.savedVariables.wasConverted = true
end

function CSPS.oldSkExtract(progTab, passTab, raceId, classId)
	local morphs, upgrades = {}, {}
	for progInd, skMorph in pairs(progTab) do --extract all the skills with progressionIndices (morphable skills)
		local i, j, k, l = SplitString("-", skMorph)
		i = tonumber(i) -- Skill type
		j = tonumber(j) -- Skill line
		if classId and i == 1 then j = classReMap[classId][j] end
		if raceId and i == 7 then j = raceReMap[raceId] end
		if needMapping and (i == 4 or i == 5 or i == 6 or i == 8) then -- language mapping for skill types with alphabetical order
			j = skLocMappings[i][j]
		end
		k = tonumber(k) -- Skill number
		l = tonumber(l) -- Morph
		if IsSkillAbilityPassive(i,j,k) then 
			l = 0
			upgrades[#upgrades+1] = {i, j, k, l}
			local myName = GetSkillAbilityInfo(i,j,k)
			d(string.format("[CSPS] %s", zo_strformat(GS(CSPS_LoadingError), myName)))
		else 
			morphs[#morphs + 1] = {i, j, k, l}
		end
	end
				
	for passInd, skPass in pairs(passTab) do --extract all the skills without progressionIndices (passives)
		local i, j, k, l = SplitString("-", skPass)
		i = tonumber(i) -- SkillType
		j = tonumber(j) -- SkillLine
		if classId and i == 1 then j = classReMap[classId][j] end
		if raceId and i == 7 then j = raceReMap[raceId] end		
		if needMapping and (i == 4 or i == 5 or i == 6 or i == 8) then -- Remap SkillType 4,5,6,8, if the data comes from a different language 
			j = skLocMappings[i][j]
		end
		k = tonumber(k) -- SkillNumber
		if updNeedMapping and i == 3 then
			if (j == 1 or j == 3) and k > 1 then k = k + 2 end
			if j == 2 and k > 1 then k = k +1 end
		elseif updNeedMapping then
			local myLineId = GetSkillLineId(i,j)
			if myLineId == 76 or myLineId == 78 then
				if k < 3 then
					local _, maxRank = GetSkillAbilityUpgradeInfo(i, j, 1)
					if maxRank == 10 or maxRank == 6 then
						k = k == 1 and 2 or 1
					end
				end
			elseif myLineId == 72 then
				if k == 3 or k == 4 then	-- Switch 3rd and 4th skill of soul magic (only if the abilityIds fit
					local myAbId3 = GetSpecificSkillAbilityInfo(i,j,3, 0, 2)
					local myAbId4 = GetSpecificSkillAbilityInfo(i,j,4, 0, 2)
					
					if myAbId3 == 45590 and myAbId4 == 45583 then
						k = k == 3 and 4 or 3
					end
				end
			end
		end
		l = tonumber(l) -- Rank
		if IsSkillAbilityPassive(i,j,k) then
			local _, maxRank = GetSkillAbilityUpgradeInfo(i, j, k)
			if maxRank then
				if l > maxRank then
					if i == 8 then
						local myLineId = GetSkillLineId(i,j)
						if (myLineId == 76 or myLineId == 78) and k == 2 then
							if upgrades[#upgrades][1] == i and upgrades[#upgrades][2] == j and upgrades[#upgrades][3] == 1 then
								local auxL = l
								_, maxRank2 = GetSkillAbilityUpgradeInfo(i, j, 1)
								if auxL > maxRank2 then auxL = maxRank2 end
								l = upgrades[#upgrades][4]
								upgrades[#upgrades][4] = auxL
							else
								k = 1
								_, maxRank = GetSkillAbilityUpgradeInfo(i, j, k)
							end
						end
					end
					l = maxRank
					local myName = GetSkillAbilityInfo(i,j,k)
					d(string.format("[CSPS] %s", zo_strformat(GS(CSPS_LoadingError), myName)))
				end
			end
			upgrades[#upgrades + 1] = {i, j, k, l}
		else
			l = 0 
			local myName = GetSkillAbilityInfo(i,j,k)
			d(string.format("[CSPS] %s", zo_strformat(GS(CSPS_LoadingError), myName)))
			morphs[#morphs+1] = {i, j, k, l}
		end
	end
	return morphs, upgrades
end

function CSPS.extractOldHbSkill(aSkill)
	skTyp, skLin, skId = SplitString("-", aSkill)
	skTyp = tonumber(skTyp)
	skLin = tonumber(skLin)
	skId = tonumber(skId)
	if classId and skTyp == 1 then skLin = classReMap[classId][skLin] end
	if needMapping and (skTyp == 4 or skTyp == 5 or skTyp == 6 or skTyp == 8) then -- language mapping for skill types with alphabetical order
		skLin = skLocMappings[skTyp][skLin]
	end
end

function CSPS.convertOldSVs()
	local oldApi = CSPS.currentCharData.svApi or 0
	if oldApi < 100034 then updNeedMapping = true else updNeedMapping = false end
	local myKeys = CSPS.compareKeys()	
	if needMapping or updNeedMapping then CSPS.mapSkills(myKeys) end
	CSPS.convertAllCharsToAbilityIDs() 
end

