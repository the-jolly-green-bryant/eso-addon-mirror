


function EchoingVigorTracker.validEchoingVigorTarget(unit2)
	local unit1="player"


	if not DoesUnitExist(unit1) or not DoesUnitExist(unit2) or IsUnitDead(unit1) or IsUnitDead(unit2) then
		--d("not exist")
		return false
	end

	if  IsUnitInGroupSupportRange(unit2)==false then
		--d("unit2:"..unit2.." not support")
		return false
	end

	local zone1, x1, y1, z1 = GetUnitWorldPosition(unit1)
	local zone2, x2, y2, z2 = GetUnitWorldPosition(unit2)

	if zone1~=zone2 then

		--d("unit2:"..unit2.." not zone")
		return false
	end

    if math.abs((y1-y2)/100)>10 then --  if the player if 10 meters above or below the player, we'll just assume they are too far away to get buffs
		--d("unit2:"..unit2.." too high")
		return false
    end

	local distance = (zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) / 100)

	if distance > 15 then
		--d("unit2:"..unit2.." too far")
		return false
	else
		--d("unit2:"..unit2.." good")
		return true
	end

end
function EchoingVigorTracker.targetHpPercentage(searchBy)
	if IsUnitGrouped(searchBy) then
		local current, max, effectiveMax = GetUnitPower(searchBy, POWERTYPE_HEALTH)
		return (current/max)*100
	else
		return 100
	end
end

function EchoingVigorTracker.countEchoingVigorTargets()
	local countAlreadyHasEv = 0
	local countDoesNotHaveEv = 0
	local totalTargets = 0
	local lowestHPofEvTarget = 100
	for i=1, 12 do
		local unitTag = "group"..i
		if IsUnitGrouped("player")==false and i == 1 then
			unitTag="player"
		end
		if IsUnitGrouped(unitTag) then
			totalTargets=totalTargets+1
		end

		local targetHp = EchoingVigorTracker.targetHpPercentage(unitTag)


		EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_HP_PERCENT] = targetHp
		EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_HP_ORDER] = 0



		local evUntil = EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_ECHOING_VIGOR_EXPIRES]
		local evRemainingMs = evUntil-GetGameTimeMilliseconds()
		if evRemainingMs<0 then
			evRemainingMs=0
		end

		local validEvTarget = EchoingVigorTracker.validEchoingVigorTarget(unitTag)

		EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_VALID_TARGET] = validEvTarget

		if validEvTarget and evRemainingMs>0 then
			countAlreadyHasEv = countAlreadyHasEv +1
		elseif validEvTarget then
			countDoesNotHaveEv = countDoesNotHaveEv + 1
		end

		if lowestHPofEvTarget > targetHp and validEvTarget and evRemainingMs>0 then
			lowestHPofEvTarget = targetHp
		end

	end

	-- sorting the players with HP less than 95% and are in range of Echoing Vigor
	for order=1, 12 do
		local lowestHpValue = 100
		local lowestIndex = 0
		for i=1, 12 do
			if EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_HP_PERCENT] <= lowestHpValue and EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_HP_ORDER]==0 and EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_VALID_TARGET]==true then
				lowestHpValue=EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_HP_PERCENT]
				lowestIndex = i
			end
		end
		if lowestIndex > 0 and lowestHpValue < 95 then -- 95% hp is the max hp we will consider for assigning EV targets by missing HP (mainly because they will likely be at 100% by the time EV could be cast)
			--d("lowestIndex:"..lowestIndex.." "..EchoingVigorTracker.EVT_HP_ORDER.." "..order)
			EchoingVigorTracker.echoingVigorMembers[lowestIndex][EchoingVigorTracker.EVT_HP_ORDER] = order
		end
	end

	local totalTargetsBasedOnHp = 0
	if EchoingVigorTracker.savedVars.includeMissingHpWhenRecommending and totalTargets > 6 then
		for i=1, 12 do
			if EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_HP_ORDER] <= 6 and EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_HP_ORDER] >=1 then
				local evUntil = EchoingVigorTracker.echoingVigorMembers[i][EchoingVigorTracker.EVT_ECHOING_VIGOR_EXPIRES]
				local evRemainingMs = evUntil-GetGameTimeMilliseconds()
				if evRemainingMs <= 0 then
					totalTargetsBasedOnHp=totalTargetsBasedOnHp+1
				end
			end
		end
		if totalTargetsBasedOnHp>6 then
			totalTargetsBasedOnHp=6
		end
	end


	local freeEvSpots = 6 - countAlreadyHasEv
	if freeEvSpots < 0 then
		freeEvSpots = 0
	end
	local guarantedWouldGetEv = countDoesNotHaveEv
	if guarantedWouldGetEv > freeEvSpots then
		guarantedWouldGetEv = freeEvSpots
	end
	if totalTargetsBasedOnHp > guarantedWouldGetEv then
		guarantedWouldGetEv=totalTargetsBasedOnHp
		--d("EV: based on low hp")
	end

	return guarantedWouldGetEv, countAlreadyHasEv, totalTargets
end



