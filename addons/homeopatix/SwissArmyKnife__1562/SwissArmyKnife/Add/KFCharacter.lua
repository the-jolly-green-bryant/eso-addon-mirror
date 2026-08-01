-- Character Addon File
-- @author    : Homeo
-- @lastModif : 06/01/2017

--------------------
---- CHAR DATAS ----
--------------------

function ReturnPVPRank()
	local rank = GetUnitAvARank("player")
	local rankIcon 	= GetAvARankIcon(rank)

	
	local icon = "|t130%:130%:".. rankIcon .."|t"

	
	return icon, rank
end


function ReturnLevel()
 	local lvl = GetUnitLevel("player")
	local chp = 0
	local xpNeeded = 0
	
	if(lvl == 50) then
		lvl = GetPlayerChampionPointsEarned("player")
		xpNeeded = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned("player"))
		chp = GetPlayerChampionXP()
	else
		xpNeeded =  GetUnitXPMax("player")
		chp = GetUnitXP("player")
	end
	
	return lvl, chp, xpNeeded
end

function IsVampire()
	local numBuffs       = GetNumBuffs("player")
	local isVampire      = false
	local hasBloodRitual = false
	local readyTime      = -1

	for buffIndex = 1, numBuffs do
		local _, _, endTime, _, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", buffIndex)

		if (abilityId == 35771) or (abilityId == 35776) or (abilityId == 35783) or (abilityId == 35792) then
			isVampire = true
		end
	end

	if isVampire then
		local numSkillLines = GetNumSkillLines(SKILL_TYPE_WORLD)

		for skillIndex = 1, numSkillLines do
			local numSkillAbilities = GetNumSkillAbilities(SKILL_TYPE_WORLD, skillIndex)

			for abilityIndex = 1, numSkillAbilities do
				local name, _, _, passive, _, purchased, _ = GetSkillAbilityInfo(SKILL_TYPE_WORLD, skillIndex, abilityIndex)

				if purchased then
					local abilityId = GetSkillAbilityId(SKILL_TYPE_WORLD, skillIndex, abilityIndex, false)

					if abilityId == 33091 then
						hasBloodRitual = true
					end
				end
			end
		end
	end

	if hasBloodRitual then
		for buffIndex = 1, numBuffs do
			local _, startTime, endTime, _, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", buffIndex)

			if abilityId == 40359 then
				readyTime = endTime - (GetFrameTimeMilliseconds()/1000) + GetTimeStamp()
			end
		end
	end

	return isVampire, hasBloodRitual, readyTime
end

function IsWerewolf()
	local numBuffs     = GetNumBuffs("player")
	local isWerewolf   = false
	local hasBloodmoon = false
	local readyTime    = -1

	for buffIndex = 1, numBuffs do
		local _, _, endTime, _, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", buffIndex)

		if abilityId == 35658 then
			isWerewolf = true
		end
	end

	if isWerewolf then
		local numSkillLines = GetNumSkillLines(SKILL_TYPE_WORLD)

		for skillIndex = 1, numSkillLines do
			local numSkillAbilities = GetNumSkillAbilities(SKILL_TYPE_WORLD, skillIndex)

			for abilityIndex = 1, numSkillAbilities do
				local name, _, _, passive, _, purchased, _ = GetSkillAbilityInfo(SKILL_TYPE_WORLD, skillIndex, abilityIndex)

				if purchased then
					local abilityId = GetSkillAbilityId(SKILL_TYPE_WORLD, skillIndex, abilityIndex, false)

					if abilityId == 32639 then
						hasBloodmoon = true
					end
				end
			end
		end
	end

	if hasBloodmoon then
		for buffIndex = 1, numBuffs do
			local _, _, endTime, _, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", buffIndex)

			if abilityId == 40525 then
				readyTime = endTime - (GetFrameTimeMilliseconds()/1000) + GetTimeStamp()
			end
		end
	end

	return isWerewolf, hasBloodmoon, readyTime
end

function IsNotHuman()
	local iconToDisplay
	local resTime = 0
    	local i, numBuffs, buffName, iconFilename, matchResult
	numBuffs = GetNumBuffs("player")
    	for i = 1, numBuffs do
        	buffName, _, _, _, _, iconFilename, _, _, _, _ = GetUnitBuffInfo("player",i)
        	if (PlainStringFind(iconFilename,"ability_vampire_007") == true) then
			lang = GetCVar("Language.2")
			if(lang == "fr") then
				long = string.len(zo_strformat("<<1>>", buffName))
				resTime = string.sub(zo_strformat("<<1>>", buffName), long-1)	
			end
			if(lang == "en") then
				resTime = string.sub(zo_strformat("<<1>>", buffName), 7,8)	
			end
			if(lang == "de") then
				long = string.len(zo_strformat("<<1>>", buffName))
				resTime = string.sub(zo_strformat("<<1>>", buffName), long-1)	
			end	
            		iconToDisplay = iconFilename
			--d(" name : " .. buffName .. " : " .. resTime .. " lang : " .. lang)
            		break
        	end
		if (PlainStringFind(iconFilename,"ability_werewolf_010") == true) then
            		iconToDisplay = iconFilename
            		break
        	end
    	end

	return iconToDisplay, resTime
end

function ReturnAlliance()
	local Alliance = GetUnitAlliance("player")
	--d("Alliance : " .. Alliance)

	if(Alliance == 1) then
		AllianceIcon = SAK.Alliance_1
	end
	if(Alliance == 2) then
		AllianceIcon = SAK.Alliance_2
	end
	if(Alliance == 3) then
		AllianceIcon = SAK.Alliance_3
	end

	return AllianceIcon
end

function ReturnClass()
	local class = GetUnitClassId("player")
	--d("classe : " .. class)

	local cla
	if(class == 1) then
		cla = "dragonknight"
	end
	if(class == 2) then
		cla = "sorcerer"
	end
	if(class == 3) then
		cla = "nightblade"
	end
	if(class == 4) then
		cla = "warden"
	end
	if(class == 5) then
		cla = "sorcerer"
	end
	if(class == 6) then
		cla = "templar"
	end

	local texture = "|t130%:130%:esoui/art/contacts/social_classicon_" .. cla .. ".dds|t"

	if(class == 5) then
		texture = "|t130%:130%:art/fx/texture/sigil_necromancy_01.dds|t"
	end


	return texture
end

function ReturnRace()
	local raceTable = {
   		["Breton"] = "breton",
   		["Bretone"] = "breton", --de, male
   		["Bretonin"] = "breton", --de, female
   		["Bréton"] = "breton", --fr, male
   		["Brétonne"] = "breton", --fr, female
   		["Orc"] = "orc",
   		["Ork"] = "orc", --de, male/female
   		["Orque"] = "orc", --fr, male/female
   		["Redguard"] = "redguard",
   		["Rothwardone"] = "redguard", --de, male
   		["Rothwardonin"] = "redguard", --de, female
   		["Rougegarde"] = "redguard", --fr, male/female
   		["High Elf"] = "altmer",
   		["Hochelf"] = "altmer", --de, male
   		["Hochelfin"] = "altmer", --de, female
   		["Haut-Elfe"] = "altmer", --fr, male
   		["Haute-Elfe"] = "altmer", --fr, female
   		["Wood Elf"] = "bosmer",
   		["Waldelf"] = "bosmer", --de, male
   		["Waldelfin"] = "bosmer", --de, female
   		["Elfe des bois"] = "bosmer", --fr, male/female
   		["Khajiit"] = "khajiit",
   		["Argonian"] = "argonian",
   		["Argonier"] = "argonian", --de, male
   		["Argonierin"] = "argonian", --de, female
   		["Argonien"] = "argonian", --fr, male
   		["Argonienne"] = "argonian", --fr, female
   		["Dark Elf"] = "dunmer",
		["Dunkelelf"] = "dunmer", --de, male
   		["Dunkelelfin"] = "dunmer", --de, female
   		["Elfe Noir"] = "dunmer", --fr, male
   		["Elfe Noire"] = "dunmer", --fr, female
   		["Nord"] = "nord",
   		["Nordique"] = "nord", --fr, male/female
   		["Imperial"] = "imperial",
   		["Kaiserlicher"] = "imperial", --de, male
   		["Kaiserliche"] = "imperial", --de, female
   		["Impérial"] = "imperial", --fr, male
   		["Impériale"] = "imperial", --fr, female
		}
 
	local race = zo_strformat(SI_RACE_NAME, GetUnitRace("player"))
	local raceCode = raceTable[race]

	local texture = ""
	if(raceCode == nil) then
		texture =  "         "
	else
		texture = "|t120%:120%:esoui/art/charactercreate/charactercreate_" .. raceCode .. "icon_up.dds|t" 
	end

	return texture
end
