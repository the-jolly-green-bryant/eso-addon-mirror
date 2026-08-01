HealerHelper.debugMinorToughness = false
-- /script HealerHelper.debugMinorToughness = true
-- /script HealerHelper.debugMinorToughness = false

-- warden class skill
function HealerHelper.GetMinorToughnessTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 88490 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end


function HealerHelper.CountMinorToughnessTargets()

    local playersThatNeedAndAreEligableForMT = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end


		local inRange = false
		local needsMT = false
        local roleForMT = true

        -- Minor toughness does not have a specific range, but anyone inside 20m should likely have it if healer is healing
		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.GetDistance("player",searchBy) <= 20 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end

        local role = GetGroupMemberSelectedRole(unitTag)

        if role == 2 and HealerHelper.savedVars.tanksIncludedInMtTargets == false then roleForMT = false end -- tanks don't need MSB
        if role == 4 and HealerHelper.savedVars.healersIncludedInMtTargets == false then roleForMT = false end -- healers don't need MSB

		local timeRemainingMT = HealerHelper.GetMinorToughnessTime(searchBy)

		if timeRemainingMT <= 0 then
            needsMT = true
		end



		if needsMT and inRange and roleForMT then
		    playersThatNeedAndAreEligableForMT=playersThatNeedAndAreEligableForMT+1
            if HealerHelper.debugMinorToughness then d("minorToughness - " ..searchBy .." +1") end
		end
	end

    return playersThatNeedAndAreEligableForMT


end




function HealerHelper.ShouldCastMinorToughness()



    if HealerHelper.savedVars.minorToughnessWarning == false then return false end

    if not (HealerHelper.playerClass == HealerHelper.CLASS_WARDEN ) then
        return false -- only warden
    end




    local targets = HealerHelper.CountMinorToughnessTargets()

    local minTargets = HealerHelper.savedVars.minimumMtTargetsTrials
    if HealerHelper.CountPlayersInGroupAndZone()<=4 then
        minTargets = HealerHelper.savedVars.minimumMtTargetsDungeons
    end

    if targets >= minTargets then
        return true
    else
        return false
    end
end





function HealerHelper.ShouldProcHealForMinorToughness()

        if HealerHelper.playerClass ~= HealerHelper.CLASS_WARDEN then
		return false -- only sorcerer proceed
	end

    if HealerHelper.savedVars.minorToughnessWarning == false then return false end

    if HealerHelper.ShouldCastMinorToughness() == false then return false end

    return true
end

function HealerHelper.minorToughnessDebugToggle()

    HealerHelper.debugMinorToughness = not HealerHelper.debugMinorToughness
    if HealerHelper.debugMinorToughness then
        d("HH: Minor Toughness Debug ON")
    else
        d("HH: Minor Toughness Debug OFF")

    end
end

function HealerHelper.minorToughnessBetaToggle()

    HealerHelper.betaTestingMinorToughness = not HealerHelper.betaTestingMinorToughness
    if HealerHelper.betaTestingMinorToughness then
        d("HH: Minor Toughness Beta ON")
    else
        d("HH: Minor Toughness Beta OFF")

    end
end
