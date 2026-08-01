
HealerHelper.minorSorceryBrutalitySkills = {

    -- TEMPLAR SKILLS
    [21726]={true,"Sun Fire"},
    [21729]={true,"Vampire's Bane"},
    [21732]={true,"Reflective Light"},

    [22057]={true,"Solar Flare"},
    [22110]={true,"Dark Flare"},
    [22095]={true,"Solar Barrage"},

    [21761]={true,"Backlash"},
    [21765]={true,"Purifying Light"},
    [21763]={true,"Power of the Light"},

    [21776]={true,"Eclipse"},
    [22006]={true,"Living Dark"},
    [22004]={true,"Unstable Core"},

    [63029]={true,"Radiant Destruction"},
    [63044]={true,"Radiant Glory"},
    [63046]={true,"Radiant Oppression"},


    -- DRAGONKIGHT SKILLS

	[29224]={true,"Igneous Shield"},
	[29071]={true,"Obsidian Shield"},
	[32673]={true,"Fragmented Shield"},

	[31816]={true,"Stone Giant"},
	[29032]={true,"Stonefist"},
	[31820]={true,"Obsidian Shard"},

	[29071]={true,"Molten Weapons"},
	[31888]={true,"Molten Armaments"},
	[31874]={true,"Igneous Weapons"},


    [20779]={true,"Cinder Storm"},
	[29059]={true,"Ash Cloud"},
	[32710]={true,"Eruption"},

    [29037]={true,"Petrify"},
	[32685]={true,"Fossilize"},
	[32678]={true,"Shattering Rocks"},

	-- Note: We don't consider ultimates as procing Minor Brutality as they will not happen often enough
}



function HealerHelper.GetMinorSorceryTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 61685 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end

function HealerHelper.GetMinorBrutalityTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 61662 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end


function HealerHelper.CountMinorSorceryBrutalityTargets()

    local playersThatNeedAndAreEligableForMSB = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end

		local inRange = false
		local needsMSB = false
        local roleForMSB = true

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.GetDistance("player",searchBy) <=28 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end


        local role = GetGroupMemberSelectedRole(unitTag)

        if role == 2 and HealerHelper.savedVars.tanksIncludedInMsbTargets == false then roleForMSB = false end -- tanks don't need MSB
        if role == 4 and HealerHelper.savedVars.healersIncludedInMsbTargets == false then roleForMSB = false end -- healers don't need MSB

		local timeRemainingMS = HealerHelper.GetMinorSorceryTime(searchBy)
		local timeRemainingMB = HealerHelper.GetMinorBrutalityTime(searchBy)
		if timeRemainingMS <= 0 and timeRemainingMB <= 0 then
            needsMSB = true
		end

		if needsMSB and inRange and roleForMSB then
		    playersThatNeedAndAreEligableForMSB=playersThatNeedAndAreEligableForMSB+1
		end
	end

    return playersThatNeedAndAreEligableForMSB
end

function HealerHelper.ShouldCastMinorSorceryBrutality()



    if HealerHelper.savedVars.minorSorceryBrutalityWarning == false then return false end

    if not (HealerHelper.playerClass == HealerHelper.CLASS_DRAGONKIGHT or HealerHelper.playerClass == HealerHelper.CLASS_TEMPLAR) then
        return false -- only DK and Templar go past this
    end

    local targets = HealerHelper.CountMinorSorceryBrutalityTargets()

    local minTargets = HealerHelper.savedVars.minimumMsbTargetsTrials
    if HealerHelper.CountPlayersInGroupAndZone()<=4 then
        minTargets = HealerHelper.savedVars.minimumMsbTargetsDungeons
    end

    if targets >= minTargets then
        return true
    else
        return false
    end
end


function HealerHelper.ShouldCastSkillForMinorSorceryBrutality(skill)
    if HealerHelper.savedVars.minorSorceryBrutalityWarning == false then return false end

    if HealerHelper.ShouldCastMinorSorceryBrutality() == false then return false end

    if skill == nil then return false end -- not a valid skill id
    if HealerHelper.minorSorceryBrutalitySkills[skill] == nil then return false end
    if HealerHelper.minorSorceryBrutalitySkills[skill][1] == false then return false end

    return true
end


function HealerHelper.skillMissingToProcMinorSorcery()

    if HealerHelper.playerClass ~= HealerHelper.CLASS_TEMPLAR then
		return false -- only Templar proceed
	end

    if HealerHelper.ShouldCastMinorSorceryBrutality() == false then return false end

    for i=1,12 do
        if i == 6 or i == 12 then
            -- skip ultimates
        else
            local skillSlot = i -- 1,2,3,4,5    7,8,9,10,11

            local skillId = HealerHelper.Skills[skillSlot]

            if HealerHelper.minorSorceryBrutalitySkills[skillId]~= nil then
                if HealerHelper.minorSorceryBrutalitySkills[skillId][1] == true then
                    return false -- found a skill to proc minor Sorcery
                end
            end

        end
    end
    return true -- no skills to proc minor sorcery

end



function HealerHelper.skillMissingToProcMinorBrutality()

    if HealerHelper.playerClass ~= HealerHelper.CLASS_DRAGONKIGHT then
		return false -- only Templar proceed
	end

    if HealerHelper.ShouldCastMinorSorceryBrutality() == false then return false end

    for i=1,12 do
        if i == 6 or i == 12 then
            -- skip ultimates
        else
            local skillSlot = i -- 1,2,3,4,5    7,8,9,10,11

            local skillId = HealerHelper.Skills[skillSlot]

            if HealerHelper.minorSorceryBrutalitySkills[skillId]~= nil then
                if HealerHelper.minorSorceryBrutalitySkills[skillId][1] == true then
                    return false -- found a skill to proc minor Brutality
                end
            end

        end
    end
    return true -- no skills to proc minor brutality

end
