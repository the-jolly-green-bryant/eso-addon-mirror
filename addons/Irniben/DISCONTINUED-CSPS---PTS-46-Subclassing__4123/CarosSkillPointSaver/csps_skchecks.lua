function CSPS.noRank(skTyp, skLin, skId)
	local _, maxRank = GetSkillAbilityUpgradeInfo(skTyp, skLin, skId)
	if maxRank == nil then return true else return false end
end

function CSPS.costsNoRank(skTyp, skLin, skId)
	local retVal = true
	if (IsSkillAbilityAutoGrant(skTyp, skLin, skId) == true) or (IsSkillAbilityPassive(skTyp, skLin, skId) == false) then
		retVal = false
	else
		if CSPS.noRank(skTyp, skLin, skId) == false then retVal = false end
	end
	return retVal
end

function CSPS.freeNoRank(skTyp, skLin, skId)
	if IsSkillAbilityAutoGrant(skTyp, skLin, skId) and CSPS.noRank(skTyp, skLin, skId) then return true else return false end
end

function CSPS.getSpecialPassives(i, j, k, l)
	local sklUnique = GetSkillLineId(i, j)
	if i == 8 and k == 1 then
		return 1 -- First skill in every crafting line
	end
	if (sklUnique == 78 or sklUnique == 76) and k == 2 then
		return 1 -- Second skill in enchant and provisioning
	end
	if sklUnique == 71 then
		return 1 -- The emperor has no clothes.
	end
	local freeSkillsList = {
		{50,1}, -- werwolve ulti
		{72,2}, -- soultrap Base
		{157,1}, -- excavation 1
		{157,2}, -- excavation 2
		{155,2}, -- scouting
	}
	for _, freeSkill in pairs(freeSkillsList) do
		if freeSkill[1] == sklUnique and freeSkill[2] == k then return 1 end
	end
	if CSPS.costsNoRank(i,j,k) then return -1 end
	return 0
end

function CSPS.skUnlocked(skTyp, skLin, skId)
	local linRank, _, active, discovered = GetSkillLineDynamicInfo(skTyp, skLin)
	if not active or not discovered then 
		return false
    elseif linRank < GetSkillAbilityLineRankNeededToUnlock(skTyp,skLin,skId) then 
		return false
	else 
		return true
	end
end

function CSPS.morphUnlocked(skTyp, skLin, skId)
	local skProg = GetProgressionSkillProgressionIndex(skTyp, skLin, skId)
	if skProg == nil then 
		return false
	else
		local _, _, _, atMorph = GetAbilityProgressionXPInfo(skProg) 
		local _, morph = GetAbilityProgressionInfo(skProg)
		if morph > 0 or atMorph then 
			return true
		else 
			return false
		end
	end
end



function CSPS.rankUnlocked(skTyp, skLin, skId, rank)
	local linRank, _, active, discovered = GetSkillLineDynamicInfo(skTyp, skLin)
	if rank == 0 then return true end
	if GetUpgradeSkillHighestRankAvailableAtSkillLineRank(skTyp, skLin, skId, linRank) == nil then return false end
	if rank > GetUpgradeSkillHighestRankAvailableAtSkillLineRank(skTyp, skLin, skId, linRank) then return false end
	return true
end

function CSPS.wrongMorph(skTyp, skLin, skId, skMo)
	local skProg = GetProgressionSkillProgressionIndex(skTyp, skLin, skId)
	if skProg == nil then 
		if skMo == 0 then return true else return false end
	end
	local _, morph = GetAbilityProgressionInfo(skProg)
	return (skMo ~= morph)
end

function CSPS.buildCheck()
	local prot1 = {}
	local toBuyPt = 0
	-- local toBuyBase = 0
	--local toBuyMorph = 0
	--local toBuyPass = 0
	local morphWrong = 0
	local morphLocked = 0
	local rankLocked = 0
	local rankHigher = 0
	local skLocked = 0
	local skillMorphs = CSPS.skillMorphs
	CSPS.kRed = {{},{},{},{},{},{},{},{},}
	CSPS.kOra = {{},{},{},{},{},{},{},{},}
	for _, skMorph in pairs(skillMorphs) do
		local skTyp = skMorph[1]
		local skLin = skMorph[2]
		local skId = skMorph[3]
		local skMo = skMorph[4]
		local _, _, _, _, _, purchased, skProg = GetSkillAbilityInfo(skTyp, skLin, skId)
		local name = ""
		local morph = 0
		if skProg ~= nil then 
			name, morph = GetAbilityProgressionInfo(skProg)
			name = zo_strformat("<<C:1>>", name)
		end
		
		if not CSPS.skUnlocked(skTyp, skLin, skId) then	-- Skill not yet unlocked?
			local skLinId = GetSkillLineId(skTyp, skLin)
			if skLinId ~= 50 or skId ~= 1 or skMo ~= 0 then
				skLocked = skLocked + 1
				CSPS.kRed[skTyp][skLin] = true
				CSPS.kRed[skTyp][42] = true		
			end
		else
			if not purchased then 	-- Skill not already purchased?
				toBuyPt = toBuyPt + 1
				--toBuyBase[#toBuyBase+1] = {skTyp, skLin, skId}
				prot1[#prot1+1] = "1 point: "..name
			end
			if not CSPS.morphUnlocked(skTyp, skLin, skId) then	-- Morph not yet unlocked
				--if skMo > 0 then morphLocked[#morphLocked+1] = {skTyp, skLin, skId, name} end
				if skMo > 0 then 
					morphLocked = morphLocked + 1 
					CSPS.kRed[skTyp][skLin] = true 
					CSPS.kRed[skTyp][42] = true
				end
			elseif purchased and CSPS.wrongMorph(skTyp, skLin, skId, skMo) and morph > 0 then -- Wrong morph already in place
				--morphWrong[#morphWrong+1] = {skTyp, skLin, skId, name}
				morphWrong = morphWrong + 1
				CSPS.kRed[skTyp][skLin] = true
				CSPS.kRed[skTyp][42] = true
			elseif skMo > 0 and skMo ~= morph then
					toBuyPt = toBuyPt + 1
					--toBuyMorph[#toBuyMorph+1] = {skProg, skMo}
					prot1[#prot1+1] = "1 point (Morph): "..name
			end
		end
	end
	local skillUpgrades = CSPS.skillUpgrades
	for _, skUpgd in pairs(skillUpgrades) do
		local skTyp = skUpgd[1]
		local skLin = skUpgd[2]
		local skId = skUpgd[3]
		local skRa = skUpgd[4]
		local name, _, _, _, _, purchased, _, rank = GetSkillAbilityInfo(skTyp, skLin, skId) 
		name = zo_strformat("<<C:1>>", name)
		local rangDiff = skRa - rank
		if not CSPS.skUnlocked(skTyp, skLin, skId) then	-- Skill not yet unlocked?
			--skLocked[#skLocked+1] = {skTyp, skLin, skId, name}
			local skLinId = GetSkillLineId(skTyp, skLin)
			if not((skLinId == 50 or skLinId == 51) and skId == 7) then
				skLocked = skLocked + 1
				CSPS.kRed[skTyp][skLin] = true
				CSPS.kRed[skTyp][42] = true
			end
		else
			if not purchased then
				toBuyPt = toBuyPt + 1
				prot1[#prot1+1] = "1 point: "..name
				rangDiff = skRa - 1 -- otherwise rank will be 1 which will be a problem later
			end
			if rangDiff > 0 then
				for ranks=1, rangDiff do
					if CSPS.rankUnlocked(skTyp, skLin, skId, rank + ranks) == true then
						toBuyPt = toBuyPt + 1
						prot1[#prot1+1] = rangDiff.." points (Upgrade): "..name
					else
						rankLocked = rankLocked + 1
						CSPS.kRed[skTyp][skLin] = true
						CSPS.kRed[skTyp][42] = true
					end
				end
			elseif rangDiff < 0 and not skRa == 0 then
				rankHigher = rankHigher + 1
				CSPS.kOra[skTyp][skLin] = true
				CSPS.kOra[skTyp][42] = true
			end
		end
	end
	CSPS.toBuyPt = toBuyPt
	CSPS.toBuyBase = toBuyBase
	CSPS.toBuyMorph = toBuyMorph
	CSPS.toBuyPass = toBuyPass
	CSPS.morphWrong = morphWrong
	CSPS.morphLocked = morphLocked
	CSPS.rankLocked = rankLocked
	CSPS.rankHigher = rankHigher
	CSPS.skLocked = skLocked
	CSPSWindowIncludeSkLabel:SetText(string.format("%s (%s/%s)", GetString(SI_CHARACTER_MENU_SKILLS), CSPS.toBuyPt, GetAvailableSkillPoints()))
	CSPS.prot1 = prot1 -- for testing purposes
end

function CSPS.getErrorCode(skTyp, skLin, skId, morph, rang)
	if CSPS.skUnlocked(skTyp, skLin, skId) == false then 						-- Skill unlocked..
		return 2
	elseif morph ~= nil then														-- Looking for morph?
		if morph > 0 and CSPS.morphUnlocked(skTyp, skLin, skId) == false then			-- Morph unlocked?
			return 2
		else
			local skProg = GetProgressionSkillProgressionIndex(skTyp, skLin, skId) 		-- Progression id?
			if morph > 0 and skProg == nil then 
				return 2
			else
				local _, meinMorph = GetAbilityProgressionInfo(skProg)
				if IsSkillAbilityPurchased(skTyp, skLin, skId) == true then				-- ability purchased?
					if morph == meinMorph then												-- morph correct?
						return 1
					elseif meinMorph > 0 and meinMorph ~= morph then						-- other morph in place?
						return 3
					else																	-- everything normal
						return 0
					end
				else
					return 0
				end
			end
		end
	elseif rang ~= nil then	
			local _, _, _, _, _, purchased, _, meinRang = GetSkillAbilityInfo(skTyp, skLin, skId) 
			if CSPS.costsNoRank(skTyp, skLin, skId) == true then
				if purchased then return 1 else return 0 end
			elseif CSPS.freeNoRank(skTyp, skLin, skId) == true then
				return 1
			elseif CSPS.rankUnlocked(skTyp, skLin, skId, rang) == false then
				return 2
			elseif meinRang > rang then
				return 4
			elseif meinRang == rang then
				if purchased then return 1 else return 0 end
			else
				return 0
			end
	else
		if IsSkillAbilityPurchased(skTyp, skLin, skId) == true then	
			return 1
		else
			return 0
		end
	end
end