function HealerHelper.CombatPrayerInRange(unit1,unit2)

	local rx, ry = HealerHelper.GetRelativeXYWithRotation(unit1,unit2)
	if rx == nil or ry == nil then
		return false
	else
		if math.abs(rx) < 400 and ry < 2000 and ry >= 0 then -- CP is 8m wide (400 cm to each side) and 20m long (2000cm long)
			return true
		else
			return false
		end
	end
end

function HealerHelper.GetCombatPrayerTime(unit)
	local value = 0
	for i=1,GetNumBuffs(unit) do
		local buffName, timeStarted, timeEnding, _, stacks, _, buffType, effectType, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)


        --if buffName=="Minor Berserk" then
            --d(string.format("%s %d type:%d",buffName,abilityId,effectType))

        --else
            --d(string.format("+ %s %d",buffName,abilityId))
        --end


        if abilityId == 61744 or abilityId == 62636 or abilityId == 17655 then -- minor berserk from CP 61744
            if timeEnding-timeStarted<2 then
				value = 10
                --return (10)
            else
                if (timeEnding-GetGameTimeSeconds())>10 then
					value = 10
                    --return (10)
                else
					value = (timeEnding-GetGameTimeSeconds())
                    --return (timeEnding-GetGameTimeSeconds())
                end
            end
        --elseif abilityId == 61745 then -- Major Berserk from Kinras 61745
        --    return (10)
        else

        end


    end
    return value
end



function HealerHelper.CountCombatPayerTargets()

    local playersThatNeedAndAreEligableForCP = 0
    local burstHealTriggered= false
	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") and i == 1 then
			searchBy = "player"
		end

		local inRange = false
		local needsCP = false
		local needBurst = false

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.CombatPrayerInRange("player",searchBy) and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end

		local timeRemaining = HealerHelper.GetCombatPrayerTime(searchBy)
		if timeRemaining <= 0 then
            needsCP = true
		end


		local current, max, effectiveMax = GetUnitPower(searchBy, POWERTYPE_HEALTH)
		if (current/max)*100 <= HealerHelper.savedVars.burstHealRecommendedHPUnderPercentage then -- BURST HEALING UNDER this percentage
		    needBurst = true
		end


		if (needsCP or needBurst) and inRange then
		    if needBurst then
		        burstHealTriggered=true
		    end
		    playersThatNeedAndAreEligableForCP=playersThatNeedAndAreEligableForCP+1
		end
	end

    return playersThatNeedAndAreEligableForCP,burstHealTriggered


end

function HealerHelper.ShouldCastCombatPrayer()


    local targets, burst = HealerHelper.CountCombatPayerTargets()

    if targets >= 1 then
        return true
    else
        return false
    end
end

function HealerHelper.ShouldCastCombatPrayerBurst()
	if HealerHelper.savedVars.burstEnabled == false then
		return false
	end

    local targets, burst = HealerHelper.CountCombatPayerTargets()

    if burst and targets >= 1 then
        return true
    else
        return false
    end
end