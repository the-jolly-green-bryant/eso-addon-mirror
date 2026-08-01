function HealerHelper.GetFunnelHealthTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 34841 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end

function HealerHelper.CountFunnelHealthTargets()

    local playersThatNeedAndAreEligableForFH = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") and i == 1 then
			searchBy = "player"
		end

		local inRange = false
		local needsFH = false

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.GetDistance("player",searchBy) <= 15 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy) == false then
				inRange=true
			end
		end

		local timeRemaining = HealerHelper.GetFunnelHealthTime(searchBy)
		if timeRemaining <= 0 then
            needsFH = true
		end

		if needsFH and inRange then
		    playersThatNeedAndAreEligableForFH=playersThatNeedAndAreEligableForFH+1
		end
	end

    return playersThatNeedAndAreEligableForFH
end

function HealerHelper.ShouldCastFunnelHealth()

	if HealerHelper.savedVars.funnelHealthEnabled == false then
		return false
	end

	if HealerHelper.savedVars.funnelHealthTrials and HealerHelper.CountPlayersInGroupAndZone()>4 then
		return false
	end


    local targets = HealerHelper.CountFunnelHealthTargets()



    if targets >= 1 then
        return true
    else
        return false
    end
end