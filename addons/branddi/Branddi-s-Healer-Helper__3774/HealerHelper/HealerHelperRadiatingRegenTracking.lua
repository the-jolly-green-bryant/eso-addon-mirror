function HealerHelper.GetRadiatingRegenTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 40079 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end

function HealerHelper.CountRadiatingRegenTargets()

    local playersThatNeedAndAreEligableForRR = 0

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

		local timeRemaining = HealerHelper.GetRadiatingRegenTime(searchBy)
		if timeRemaining <= 0 then
            needsRR = true
		end

		if needsRR and inRange then
		    playersThatNeedAndAreEligableForRR=playersThatNeedAndAreEligableForRR+1
		end
	end

    return playersThatNeedAndAreEligableForRR
end

function HealerHelper.ShouldCastRadiatingRegen()

	if HealerHelper.savedVars.radiatingRegenerationEnabled == false then
		return false
	end
	if HealerHelper.savedVars.radiatingRegenerationTrials and HealerHelper.CountPlayersInGroupAndZone()>4 then
		return false
	end

    local targets = HealerHelper.CountRadiatingRegenTargets()

    if (HealerHelper.CountPlayersInGroupAndZone()<=4 and targets >= 1) or (targets >= 3) then -- 1 or more in dungeons, 3 or more targets in trials
        return true
    else
        return false
    end
end