MotA_Helpers = {}

-- Check if user is a vampire --------------------------------------------------
function MotA_Helpers:IsVampire()
	local numBuffs       = GetNumBuffs("player")
	local isVampire      = false
	local hasBloodRitual = false
	local readyTime      = -1

	for buffIndex = 1, numBuffs do
		local _, _, endTime, _, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", buffIndex)

		if (abilityId == 135397) or (abilityId == 135399) or (abilityId == 135400) or (abilityId == 135402) or (abilityId == 135412) then
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

-- Check vampirism stage -------------------------------------------------------
function MotA_Helpers:GetVampireStage()
	local numBuffs     = GetNumBuffs("player")
	local vampireStage = nil

	for buffIndex = 1, numBuffs do
		local _, _, endTime, _, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", buffIndex)

		if (abilityId == 135397) then
			vampireStage = 1
		elseif (abilityId == 135399) then
			vampireStage = 2
		elseif (abilityId == 135400) then
			vampireStage = 3
		elseif (abilityId == 135402) then
			vampireStage = 4
		elseif (abilityId == 135412) then
			vampireStage = 5
		end
	end

	return vampireStage
end

-- Check if user is a werewolf -------------------------------------------------
function MotA_Helpers:IsWerewolf()
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
