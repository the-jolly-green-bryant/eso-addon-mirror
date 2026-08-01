--[[

function HealerHelper.GetEchoingVigorTime(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 61506 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end
--]]

function HealerHelper.GetEchoingVigorTimeOldway(unit)
	for i=1,GetNumBuffs(unit) do
		local _, _, timeEnding, _, stacks, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)
        if abilityId == 61506 then
            return (timeEnding-GetGameTimeSeconds())
        end
    end
    return 0
end


local PURGE_UNIT_TAG       = 3
local PURGE_AT_NAME        = 5
local PURGE_UNIT_ID        = 7
local PURGE_ECHOING_VIGOR_EXPIRES = 9

function HealerHelper.GetEchoingVigorTime(unit)
	if unit == "player" then unit = "group1" end
	for i=1, 12 do
		if HealerHelper.purgeMembers[i][PURGE_UNIT_TAG] ==unit then
			local sRemaining = (HealerHelper.purgeMembers[i][PURGE_ECHOING_VIGOR_EXPIRES]-GetGameTimeMilliseconds())/1000
			if sRemaining>0 then

				return sRemaining
			else
				return 0
			end

		end
	end
	return 0

end


function HealerHelper.CountGuaranteedEchoingVigorTargets()

    local playersThatNeedAndAreEligableForEV = 0
	local playersThatHaveAndAreEligableForEV = 0


	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") and i==1 then
			searchBy = "player"
		end

		local inRange = false
		local needsEV = false



		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then

			local role = GetGroupMemberSelectedRole(searchBy)
			local validRole = (role == 1 or role == 2 or role == 4)

			if validRole and HealerHelper.GetDistance("player",searchBy) <=12 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end

		local timeRemaining = HealerHelper.GetEchoingVigorTime(searchBy)
		if timeRemaining <= 0 then
            needsEV = true
		end

		if needsEV and inRange then
		    playersThatNeedAndAreEligableForEV = playersThatNeedAndAreEligableForEV + 1
		elseif inRange then
			playersThatHaveAndAreEligableForEV = playersThatHaveAndAreEligableForEV + 1
		end
	end

	local newEvTargets = 6 - playersThatHaveAndAreEligableForEV
	if newEvTargets < 0 then
		newEvTargets = 0
	end
	if newEvTargets < playersThatNeedAndAreEligableForEV then
		playersThatNeedAndAreEligableForEV = newEvTargets
	end

    return playersThatNeedAndAreEligableForEV
end

--[[
function HealerHelper.CountEchoingVigorTargets()

    local playersThatNeedAndAreEligableForEV = 0


	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") and i==1 then
			searchBy = "player"
		end

		local inRange = false
		local needsEV = false

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.GetDistance("player",searchBy) <=12 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end

		local timeRemaining = HealerHelper.GetEchoingVigorTime(searchBy)
		if timeRemaining <= 0 then
            needsEV = true
		end

		if needsEV and needsEV then
		    playersThatNeedAndAreEligableForEV = playersThatNeedAndAreEligableForEV + 1
		end
	end

    return playersThatNeedAndAreEligableForEV
end
--]]
function HealerHelper.ShouldCastEchoingVigor()

	if HealerHelper.savedVars.echoingVigorEnabled == false then
		return false
	end

    --local targets = HealerHelper.CountEchoingVigorTargets()
	local targets = HealerHelper.CountGuaranteedEchoingVigorTargets()

    local minTargets = HealerHelper.savedVars.minimumEchoingVigorTargetsTrials
    if HealerHelper.CountPlayersInGroupAndZone()<=6 then -- due to the way EV works, we'll consider a trial anything over 6
        minTargets = HealerHelper.savedVars.minimumEchoingVigorTargetsDungeons
    end

	--d(targets.. " "..minTargets)

    if targets >= minTargets then
        return true
    else
        return false
    end
end





function HealerHelper.EchoingVigorCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
	--d("HealerHelper.EchoingVigorCombatEvent")
	for i=1, 12 do
		if HealerHelper.purgeMembers[i][PURGE_UNIT_ID] ==targetUnitId then
			HealerHelper.purgeMembers[i][PURGE_ECHOING_VIGOR_EXPIRES]=GetGameTimeMilliseconds()+hitValue
			--d("HH: found echoing vigor on "..HealerHelper.purgeMembers[i][PURGE_AT_NAME])
		end
	end
end


HealerHelper.EchoingVigorTrackingEnable = false

function HealerHelper.InitialiseEchoingVigorTracking()
    if HealerHelper.EchoingVigorTrackingEnable == false then

		EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "EchoingVigorTracking_61506", EVENT_COMBAT_EVENT, HealerHelper.EchoingVigorCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(HealerHelper.name .. "EchoingVigorTracking_61506", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 61506,REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        HealerHelper.EchoingVigorTrackingEnable = true
    end
end

function HealerHelper.DeinitialiseEchoingVigorTracking()
    if HealerHelper.EchoingVigorTrackingEnable == true then

		EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "EchoingVigorTracking_61506", EVENT_COMBAT_EVENT)

        HealerHelper.EchoingVigorTrackingEnable = false
    end
end
