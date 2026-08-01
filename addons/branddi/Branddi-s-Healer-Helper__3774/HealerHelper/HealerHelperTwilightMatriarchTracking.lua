function HealerHelper.TwilightMatriarchInRange(unit1,unit2)
    if HealerHelper.GetDistance(unit1,unit2) <= 28 then -- Twilight Matriarch is 28m
        return true
    else
        return false
    end
end

function HealerHelper.CountTwilightMatriarchTargets()

    local playersThatNeedAndAreEligableForTM = 0
    local burstHealTriggered= false
	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end

		local inRange = false
		local needBurst = false

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.TwilightMatriarchInRange("player",searchBy) and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end


		local current, max, effectiveMax = GetUnitPower(searchBy, POWERTYPE_HEALTH)
		if (current/max)*100 <= HealerHelper.savedVars.burstHealRecommendedHPUnderPercentage then -- BURST HEALING UNDER this percentage!
		    needBurst = true
		end


		if needBurst and inRange then
            burstHealTriggered=true

		    playersThatNeedAndAreEligableForTM=playersThatNeedAndAreEligableForTM+1
		end
	end

    return playersThatNeedAndAreEligableForTM,burstHealTriggered
end

function HealerHelper.ShouldCastTwilightMatriarchBurst()
	if HealerHelper.savedVars.burstEnabled == false then
		return false
	end

    local targets, burst = HealerHelper.CountTwilightMatriarchTargets()

    if burst and targets >= 1 then
        return true
    else
        return false
    end
end