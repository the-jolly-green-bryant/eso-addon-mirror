function HealerHelper.ResistantFleshInRange(unit1,unit2)

	local rx, ry = HealerHelper.GetRelativeXYWithRotation(unit1,unit2)
	if rx == nil or ry == nil then
		return false
	else
		if math.abs(rx) < 600 and ry < 2800 and ry >= 0 then -- Resistant Flesh is 12m wide (600 cm to each side) and 28m long (2800cm long)
			return true
		else
			return false
		end
	end
end

function HealerHelper.CountResistantFleshTargets()

    local playersThatNeedAndAreEligableForRF = 0
    local burstHealTriggered= false
	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end

		local inRange = false
		local needBurst = false

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.ResistantFleshInRange("player",searchBy) and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end


		local current, max, effectiveMax = GetUnitPower(searchBy, POWERTYPE_HEALTH)
		if (current/max)*100 <= HealerHelper.savedVars.burstHealRecommendedHPUnderPercentage then -- BURST HEALING UNDER this percentage
		    needBurst = true
		end


		if needBurst and inRange then
            burstHealTriggered=true

		    playersThatNeedAndAreEligableForRF=playersThatNeedAndAreEligableForRF+1
		end
	end

    return playersThatNeedAndAreEligableForRF,burstHealTriggered
end

function HealerHelper.ShouldCastResistantFleshBurst()
	if HealerHelper.savedVars.burstEnabled == false then
		return false
	end

    local targets, burst = HealerHelper.CountResistantFleshTargets()

    if burst and targets >= 1 then
        return true
    else
        return false
    end
end