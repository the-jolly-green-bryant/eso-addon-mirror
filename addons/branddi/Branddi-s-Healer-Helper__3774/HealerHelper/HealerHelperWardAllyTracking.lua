function HealerHelper.CountWardAllyTargets()

    local playersThatNeedAndAreEligableForWA = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end

		local inRange = false
		local needsShield = false

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.GetDistance("player",searchBy) <=28 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end

		local current, max, effectiveMax = GetUnitPower(searchBy, POWERTYPE_HEALTH)
		if (current/max)*100 <= HealerHelper.savedVars.wardRecommendedHPUnderPercentage then -- SHIELD UNDER this percentagewardRecommendedHPUnderPercentage
		    if GetUnitAttributeVisualizerEffectInfo(searchBy,ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH) ==nil then
		        needsShield = true -- person has no shield on them and HP under 50%
		    end
		end

		if needsShield and inRange then
		    playersThatNeedAndAreEligableForWA=playersThatNeedAndAreEligableForWA+1
		end
	end

    return playersThatNeedAndAreEligableForWA


end

function HealerHelper.ShouldCastWardAlly()

	if HealerHelper.savedVars.shieldEnabled == false then
		return false
	end

    local targets = HealerHelper.CountWardAllyTargets()

    if targets >= 1 then
        return true
    else
        return false
    end
end


function HealerHelper.ShouldCastDampenMagic()
	if HealerHelper.savedVars.shieldEnabled == false then
		return false
	end


    local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_HEALTH)
    if (current/max)*100 <= 50 then -- SHIELD UNDER 50%!
        if GetUnitAttributeVisualizerEffectInfo("player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH) ==nil then
            return true -- HP under 50% and not currently shielded
        else
            return false
        end
    else
        return false
    end
end

