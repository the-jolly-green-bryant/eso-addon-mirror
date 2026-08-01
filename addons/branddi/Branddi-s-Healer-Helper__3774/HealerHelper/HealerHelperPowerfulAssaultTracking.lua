-- /script  d(HealerHelper.countTable(HealerHelper.roDatabase))
HealerHelper.powerfulAssaultSkills = {
    -- Alliance War
    [33376]={true,"Caltrops"},
    [40242]={true,"Razor Caltrops"},
    [40255]={true,"Anti-Cavalry Caltrops"},

    [61505]={true,"Echoing Vigor"},
    [61507]={true,"Resolving Vigor"},
    -- TODO: Unmorphed vigor

    [61500]={true,"Proximity Detonation"},

}


function HealerHelper.ShouldCastSkillForPowerfulAssault(skill, bar)

    if skill == nil then return false end -- not a valid skill id
    if HealerHelper.checkIfGearSetEquipped("Powerful Assault") == false then return false end -- PA not on any bar
    if HealerHelper.powerfulAssaultSkills[skill] == nil then return false end -- not an PA skill anyways
    if HealerHelper.powerfulAssaultSkills[skill][1] == false then return false end -- PA skill is disabled
    if not (HealerHelper.getGetSetBars("Powerful Assault") == bar or HealerHelper.getGetSetBars("Powerful Assault") == 3) then return false end -- skill not on the correct bar

    if HealerHelper.ShouldCastPowerfulAssault() == false then return false end -- we shouldn't even bother to cast PA

    return true
end


function HealerHelper.GetPowerfulAssaultTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 61771 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end


function HealerHelper.CountPowerfulAssaultTargets()

    local playersThatNeedAndAreEligableForPA = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end

		local inRange = false
		local needsPA = false
        local roleForPa = true

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.GetDistance("player",searchBy) <=12 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end


        local role = GetGroupMemberSelectedRole(unitTag)

        if role == 2 and HealerHelper.savedVars.tanksIncludedInPaTargets == false then roleForPa = false end -- tanks don't need RO
        if role == 4 and HealerHelper.savedVars.healersIncludedInPaTargets == false then roleForPa = false end -- healers don't need RO



		local timeRemaining = HealerHelper.GetPowerfulAssaultTime(searchBy)
		if timeRemaining <= 0 then
            needsPA = true
		end

		if needsPA and inRange and roleForPa then
		    playersThatNeedAndAreEligableForPA=playersThatNeedAndAreEligableForPA+1
		end
	end

    return playersThatNeedAndAreEligableForPA


end

function HealerHelper.ShouldCastPowerfulAssault()

    if HealerHelper.savedVars.powerfulAssaultEnabled == false then
        return false
    end
    local targets = HealerHelper.CountPowerfulAssaultTargets()

    local minTargets = HealerHelper.savedVars.minimumPaTargetsTrials
    if HealerHelper.CountPlayersInGroupAndZone()<=4 then
        minTargets = HealerHelper.savedVars.minimumPaTargetsDungeons
    end

    if targets >= minTargets then
        return true
    else
        return false
    end


end


function HealerHelper.skillMissingToProcPowerfulAssault()
    if HealerHelper.savedVars.powerfulAssaultEnabled == false then
        return false
    end
    if HealerHelper.checkIfGearSetEquipped("Powerful Assault") then

        for i=1,12 do
            if i == 6 or i == 12 then
                -- skip ultimates
            else
                local skillSlot = i -- 1,2,3,4,5    7,8,9,10,11

                local bar = 1
                if i >= 7 then
                    bar = 2
                end

                local skillId = HealerHelper.Skills[skillSlot]
                if HealerHelper.getGetSetBars("Powerful Assault")==3 or  HealerHelper.getGetSetBars("Powerful Assault")==bar then
                    if HealerHelper.powerfulAssaultSkills[skillId]~= nil then
                        if HealerHelper.powerfulAssaultSkills[skillId][1] == true then
                            return false -- found a skill to proc PA
                        end
                    end
                end
            end
        end
        return true -- no skills to proc PA
    else
        return false -- not wearing PA anyways
    end

end