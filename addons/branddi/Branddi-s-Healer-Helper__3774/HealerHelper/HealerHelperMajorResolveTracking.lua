function HealerHelper.GetMajorResolveTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 61694 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end

function HealerHelper.CountExpansiveFrostCloakTargets()

    local playersThatNeedAndAreEligableForEFC = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") and i == 1  then
			searchBy = "player"
		end

		local inRange = false
		local needsMR = false

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.GetDistance("player",searchBy) <=36 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end

		local timeRemaining = HealerHelper.GetMajorResolveTime(searchBy)
		if timeRemaining <= 0 then
            needsMR = true
		end

		if needsMR and inRange then
		    playersThatNeedAndAreEligableForEFC=playersThatNeedAndAreEligableForEFC+1
		end
	end

    return playersThatNeedAndAreEligableForEFC
end




function HealerHelper.CountIceFortressTargets()

    local playersThatNeedAndAreEligableForIF = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end

		local inRange = false
		local needsMR = false

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.GetDistance("player",searchBy) <=8 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end

		local timeRemaining = HealerHelper.GetMajorResolveTime(searchBy)
		if timeRemaining <= 0 then
            needsMR = true
		end

		if needsMR and inRange then
		    playersThatNeedAndAreEligableForIF=playersThatNeedAndAreEligableForIF+1
		end
	end

    return playersThatNeedAndAreEligableForIF
end

function HealerHelper.ShouldCastExpansiveFrostCloak()

	if HealerHelper.savedVars.majorResolveEnabled == false then
		return false
	end

	local targets = HealerHelper.CountExpansiveFrostCloakTargets()

	if targets >= 1 then
		return true
	else
		return false
	end
end


function HealerHelper.ShouldCastIceFortress()

	if HealerHelper.savedVars.majorResolveEnabled == false then
		return false
	end

    local targets = HealerHelper.CountIceFortressTargets()

    if targets >= 1 then
        return true
    else
        return false
    end
end

