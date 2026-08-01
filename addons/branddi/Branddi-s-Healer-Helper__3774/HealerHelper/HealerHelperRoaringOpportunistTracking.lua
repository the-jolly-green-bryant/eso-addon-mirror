-- /script  d(HealerHelper.countTable(HealerHelper.roDatabase))
HealerHelper.roDatabase = {
-- id       name
[93109] = {"Major Slayer"}, -- RO Major Slayer (or any other source)
}


-- max distance of RO is ... 28m


local RO_MAJOR_SLAYER_EXPIRES   = 1
local RO_RO_COOLDOWN_EXPIRES    = 2


HealerHelper.roMembers = {
-- parameter 1 RO_MAJOR_SLAYER_EXPIRES = when major slayer expires
-- parameter 2 RO_RO_COOLDOWN_EXPIRES = when RO expires

-- unitTag  MajorSlayerExpire, RoCooldownExpire
["group1"]  = {0, 0}, -- , false, "", "", 0},
["group2"]  = {0, 0}, -- , false, "", "", 0},
["group3"]  = {0, 0}, -- , false, "", "", 0},
["group4"]  = {0, 0}, -- , false, "", "", 0},
["group5"]  = {0, 0}, -- , false, "", "", 0},
["group6"]  = {0, 0}, -- , false, "", "", 0},
["group7"]  = {0, 0}, -- , false, "", "", 0},
["group8"]  = {0, 0}, -- , false, "", "", 0},
["group9"]  = {0, 0}, -- , false, "", "", 0},
["group10"] = {0, 0}, -- , false, "", "", 0},
["group11"] = {0, 0}, -- , false, "", "", 0},
["group12"] = {0, 0}, -- , false, "", "", 0},

}



function HealerHelper.CountPlayersInGroupAndZone()

    local playersinZone = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") and i == 1 then
			searchBy = "player"
		end

		if HealerHelper.GetDistance("player",searchBy)~=-1 then
		    playersinZone=playersinZone+1
		end
	end

    return playersinZone
end




function HealerHelper.printRoDebug()
    for unitTag,roMemberInfo in pairs(HealerHelper.roMembers) do
        local expiresIn = (roMemberInfo[RO_MAJOR_SLAYER_EXPIRES] - GetGameTimeMilliseconds())/1000
        if  expiresIn < 0 then
            expiresIn = 0
        end

        local cooldown = (roMemberInfo[RO_RO_COOLDOWN_EXPIRES] - GetGameTimeMilliseconds())/1000
        if  cooldown < 0 then
            cooldown = 0
        end

        d("unitTag:" .. unitTag.. " MS:" .. expiresIn ..  "s. cooldown:" .. cooldown.."s")
    end
end


function HealerHelper.doesPlayerNeedRo(unitTag)
    local searchTag = unitTag
    if IsUnitGrouped("player")== false and unitTag == "player" then searchTag = "group1" end


    if HealerHelper.roMembers[searchTag]==nil then return false end

    if HealerHelper.roMembers[searchTag][RO_MAJOR_SLAYER_EXPIRES]-1400>GetGameTimeMilliseconds() then return false end -- player has major slayer already remove 1400 for the time it takes to do a heavy attack

    if HealerHelper.roMembers[searchTag][RO_RO_COOLDOWN_EXPIRES]-1400>GetGameTimeMilliseconds() then return false end -- player has RO Cooldown and cannot accept more RO for the time it takes to do a heavy attack

    local distance = HealerHelper.GetDistance("player",unitTag)

    if IsUnitInGroupSupportRange(unitTag)==false then return false end -- useful to remove units people in portal vSS for example

    if distance < 0 or distance > 28 then return false end -- not in the correct zone or too far away

    local role = GetGroupMemberSelectedRole(unitTag)

    if role == 2 and HealerHelper.savedVars.tanksIncludedInRojoTargets == false then return false end -- tanks don't need RO
    if role == 4 and HealerHelper.savedVars.healersIncludedInRojoTargets == false then return false end -- healers don't need RO

    return true -- otherwise, yeah take RO

end

HealerHelper.RoProcDurationSeconds = 0
HealerHelper.RoProcDurationTime = 0

function HealerHelper.MajorSlayerCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    HealerHelper.RoProcDurationSeconds = hitValue / 1000
    HealerHelper.RoProcDurationTime = GetGameTimeMilliseconds()
	--d("ROJO Proc: "..hitValue)
end




HealerHelper.RoTrackingEnable = false

function HealerHelper.InitialiseRoTracking()
    if HealerHelper.RoTrackingEnable == false then


        EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "RoEffectChanged", EVENT_EFFECT_CHANGED, HealerHelper.OnRoEffectChanged)
        EVENT_MANAGER:AddFilterForEvent(HealerHelper.name.. "RoEffectChanged",  EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 93109, REGISTER_FILTER_IS_ERROR, false) -- major slayer

		EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "MajorSlayerTracking_135923", EVENT_COMBAT_EVENT, HealerHelper.MajorSlayerCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(HealerHelper.name .. "MajorSlayerTracking_135923", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 135923, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        HealerHelper.RoTrackingEnable = true
    end
end

function HealerHelper.DeinitialiseRoTracking()
    if HealerHelper.RoTrackingEnable == true then

        EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "RoEffectChanged", EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "MajorSlayerTracking_135923", EVENT_COMBAT_EVENT)

        HealerHelper.RoTrackingEnable = false
    end
end

-- this is just to assign names to players
function HealerHelper.OnRoEffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )

    if abilityId ~= 93109 then return end -- only proceed with Major Slayer buff

    local majorSlayerDurationInMs = (endTime-beginTime) * 1000

    if (changeType==EFFECT_RESULT_GAINED or changeType==EFFECT_RESULT_UPDATED) and majorSlayerDurationInMs==0 then return end -- if duration is 0 lets just ignore this Major Slayer effect changed status

    local maxiumLengthOfRoJoInMs = (12 * 1.4 * 1000) + 100 -- 12s of RO max * 40% JO increase = 16.8seconds maximum (add 100 to make of for the fact that the endtime sometimes is slightly longer)

    local assumeRoJo = true
    if  majorSlayerDurationInMs > maxiumLengthOfRoJoInMs then -- if Major Slayer is greater than this time we assume it's not a RoJo proc (maybe WM, MA, or other?)
        assumeRoJo = false
        --if HealerHelper.savedVars.debugToChat then
        --    d("Not RoJo MS proc: "..majorSlayerDurationInMs .. " max: "..maxiumLengthOfRoJoInMs)
        --end
    end

    if IsUnitGrouped("player") == false then
        if unitTag == "player" then
            unitTag = "group1"  -- just use group1 for player if not in a group
        end
    end


    if false then -- enable debug
        local name = zo_strformat('<<1>>', unitName)
        local changeTypeStr=zo_strformat('UNKNOWN_<<1>>', changeType)
        if changeType==EFFECT_RESULT_FADED then
            changeTypeStr="FADED"
        elseif changeType==EFFECT_RESULT_GAINED then
            changeTypeStr="GAINED"
        elseif changeType==EFFECT_RESULT_UPDATED then
            changeTypeStr="UPDATED"
        end

        local abilityIdStr = zo_strformat('<<1>>_<<2>>', GetAbilityName(abilityId),abilityId)

        d("OnRoEffectChanged unitTag: "..unitTag.." abilityId:"..abilityIdStr.." changeType:"..changeTypeStr.." duration:"..majorSlayerDurationInMs.."ms RoJo:"..HealerHelper.boolToString(assumeRoJo))
    end

    -- todo if in group of 1 player then switch player to group1
    if HealerHelper.roMembers[unitTag]~=nil then
        if changeType == EFFECT_RESULT_FADED then
            HealerHelper.roMembers[unitTag][RO_MAJOR_SLAYER_EXPIRES]=0
        elseif changeType == EFFECT_RESULT_UPDATED or changeType == EFFECT_RESULT_GAINED then
            HealerHelper.roMembers[unitTag][RO_MAJOR_SLAYER_EXPIRES] = endTime * 1000
            if assumeRoJo then
                HealerHelper.roMembers[unitTag][RO_RO_COOLDOWN_EXPIRES] = GetGameTimeMilliseconds() + 22000 -- RO cooldown is 22 seconds
            end
        end
    end

end


function HealerHelper.CountRoaringOpportunistTargets()

    local playersThatNeedAndAreEligableForRO = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") and i == 1 then
			searchBy = "player"
		end

		if HealerHelper.doesPlayerNeedRo(searchBy) then
		    playersThatNeedAndAreEligableForRO=playersThatNeedAndAreEligableForRO+1
		end
	end

    return playersThatNeedAndAreEligableForRO
end


HealerHelper.lastRoaringOpportunistState = false

function HealerHelper.ShouldProcRoaringOpportunist()



    if  HealerHelper.checkIfGearSetEquipped("Roaring Opportunist's") == false then return false end -- no RO checkIfRoaringOpportunistEquipped

    local targets = HealerHelper.CountRoaringOpportunistTargets()

    local minTargets = HealerHelper.savedVars.minimumRojoTargetsTrials
    if HealerHelper.CountPlayersInGroupAndZone()<=4 then
        minTargets = HealerHelper.savedVars.minimumRojoTargetsDungeons
    end

    if targets >= minTargets then
        if HealerHelper.lastRoaringOpportunistState == false and HealerHelper.savedVars.audibleRojo and HealerHelper.inCombat and IsUnitDead("player") == false then
            PlaySound(HealerHelper.savedVars.audibleRojoSoundEffect) -- time to play RO sound effect
        end
        HealerHelper.lastRoaringOpportunistState = true
        return true
    else
        HealerHelper.lastRoaringOpportunistState = false
        return false
    end
end


