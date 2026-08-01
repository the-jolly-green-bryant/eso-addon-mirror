
HealerHelper.minorProphecySavagerySkills = {

    -- SORCERER
    [43714]={true,"Crystal Shard"},
    [46331]={true,"Crystal Weapon"},
    [46324]={true,"Crystal Fragments"},

    [28025]={true,"Encase"},
    [28308]={true,"Shattering Prison"},
    [28311]={true,"Restraining Prison"},


    [24371]={true,"Rune Prison"},
    [24578]={true,"Rune Cage"},
    [24574]={true,"Defensive Rune"},


    [24584]={true,"Dark Exchange"},
    [24595]={true,"Dark Deal"},
    [24589]={true,"Dark Conversion"},


    [24828]={true,"Daedric Mines"},
    [24842]={true,"Daedric Tomb"},
    [24834]={true,"Daedric Minefield"},


	-- NIGHTBLADES DO NOT HAVE SPECIFIC SKILLS TO PROC Minor Savagery

	-- Note: We don't consider ultimates as procing Minor Brutality as they will not happen often enough
}



-- sorc class skill
function HealerHelper.GetMinorProphecyTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 61691 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end

-- nightblade class skill
function HealerHelper.GetMinorSavageryTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 61666 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end

function HealerHelper.CountMinorProphecySavageryTargets()

    local playersThatNeedAndAreEligableForMPS = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end

		local inRange = false
		local needsMPS = false
        local roleForMPS = true

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.GetDistance("player",searchBy) <=28 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end

		local role = GetGroupMemberSelectedRole(unitTag)

        if role == 2 and HealerHelper.savedVars.tanksIncludedInMpsTargets == false then roleForMPS = false end -- tanks don't need MPS
        if role == 4 and HealerHelper.savedVars.healersIncludedInMpsTargets == false then roleForMPS = false end -- healers don't need MPS


		local timeRemainingMP = HealerHelper.GetMinorProphecyTime(searchBy)
		local timeRemainingMS = HealerHelper.GetMinorSavageryTime(searchBy)
		if timeRemainingMP <= 0 and timeRemainingMS <= 0 then
            needsMPS = true
		end


		if needsMPS and inRange and roleForMPS then
		    playersThatNeedAndAreEligableForMPS=playersThatNeedAndAreEligableForMPS+1
		end
	end

    return playersThatNeedAndAreEligableForMPS


end




function HealerHelper.ShouldCastMinorProphecySavagery()



    if HealerHelper.savedVars.minorProphecySavageryWarning == false then return false end

    if not (HealerHelper.playerClass == HealerHelper.CLASS_SORCERER or HealerHelper.playerClass == HealerHelper.CLASS_NIGHTBLADE ) then
        return false -- only Sorc can cast skill to affect this
    end

    local targets = HealerHelper.CountMinorProphecySavageryTargets()

    local minTargets = HealerHelper.savedVars.minimumMpsTargetsTrials
    if HealerHelper.CountPlayersInGroupAndZone()<=4 then
        minTargets = HealerHelper.savedVars.minimumMpsTargetsDungeons
    end

    if targets >= minTargets then
        return true
    else
        return false
    end
end




function HealerHelper.ShouldCastSkillForMinorProphecySavagery(skill)
    if HealerHelper.savedVars.minorProphecySavageryWarning == false then return false end

    if HealerHelper.ShouldCastMinorProphecySavagery() == false then return false end

    if skill == nil then return false end -- not a valid skill id
    if HealerHelper.minorProphecySavagerySkills[skill] == nil then return false end
    if HealerHelper.minorProphecySavagerySkills[skill][1] == false then return false end

    return true
end


function HealerHelper.skillMissingToProcMinorProphecy()

    if HealerHelper.playerClass ~= HealerHelper.CLASS_SORCERER then
		return false -- only sorcerer proceed
	end

    if HealerHelper.ShouldCastMinorProphecySavagery() == false then return false end

    for i=1,12 do
        if i == 6 or i == 12 then
            -- skip ultimates
        else
            local skillSlot = i -- 1,2,3,4,5    7,8,9,10,11

            local skillId = HealerHelper.Skills[skillSlot]

            if HealerHelper.minorProphecySavagerySkills[skillId]~= nil then
                if HealerHelper.minorProphecySavagerySkills[skillId][1] == true then
                    return false -- found a skill to proc minor Prophecy
                end
            end

        end
    end
    return true -- no skills to proc minor sorcery

end


function HealerHelper.ShouldProcDamageForMinorSavagery()

        if HealerHelper.playerClass ~= HealerHelper.CLASS_NIGHTBLADE then
		return false -- only sorcerer proceed
	end

    if HealerHelper.savedVars.minorProphecySavageryWarning == false then return false end

    if HealerHelper.ShouldCastMinorProphecySavagery() == false then return false end

    return true
end