




function HealerHelper.GetMinorProphecyTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 61691 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end

function HealerHelper.CountMinorProphecyTargets()

    local playersThatNeedAndAreEligableForMP = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end

		local inRange = false
		local needsRR = false

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.GetDistance("player",searchBy) <=28 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end

		local timeRemaining = HealerHelper.GetMinorProphecyTime(searchBy)
		if timeRemaining <= 0 then
            needsRR = true
		end

		if needsRR and inRange then
		    playersThatNeedAndAreEligableForMP=playersThatNeedAndAreEligableForMP+1
		end
	end

    return playersThatNeedAndAreEligableForMP


end

function HealerHelper.ShouldCastMinorProphecy()


	if  HealerHelper.isModuleOn(HealerHelper.MODULE_MINOR_PROPHECY) == false then
        return false
    end

    local targets = HealerHelper.CountMinorProphecyTargets()

    if targets >= 1 then
        return true
    else
        return false
    end
end