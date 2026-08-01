-- /script  d(HealerHelper.countTable(HealerHelper.purgeDatabase))
HealerHelper.purgeDatabase = {
-- id       name              selfishonly
--[40079]  = {"Radiating Regen",               false}, -- testing only using RR
[109992] = {"Poisonbloom",                   false}, -- vBRP netch
[113150] = {"Arrowpoison",                   false}, -- vBRP archer cone

--[113164] = {"Venomous Spit",                   false}, -- vBRP arena 2 spider spit can be purged only for testing (easy to proc)

[168776] = {"Ignited",                       false}, -- vCA second boss fire
[168897] = {"Aperture",                      false}, -- vCA second boss paint floor

[126417] = {"Drain Vitality",                false}, -- vMGF HM last boss DOT
[99131]  = {"Bleeding",                       true}, -- vAS2 Felms Bleeding
[101101] = {"Trial by Fire",                 false}, -- vAS2 Execute Fire



[123210] = {"Azure Blaze",                   false}, -- vLoM Azure Blaze
[124441] = {"Spit",                          false}, -- vLoM Spit
[126595] = {"Blight Burst",                  false}, -- vLoM Blight Burst
[126700] = {"Dark Talons",                   false}, -- vLoM Dark Talons
[123662] = {"Storm Bound",                   false}, -- vSS Storm Bound

[27748] = {"Enervating Seal",                false}, -- vSpindleclutch II
[73244] = {"Ruthless Salvo Bleed",           false}, -- vMoL
[73807] = {"Lunar Flare (Rage of S'Kinrai)", false}, -- vMoL
[75738] = {"Lunar Flare (S'kinrai)",         false}, -- vMoL
--[133634] = {"Immolation",                   false}, -- vSG Second Boss -- i think this is the non-purgable version that stacks???
[144763] = {"Immolation",                    false}, -- vSG Second Boss - i think this might be the one that gets applied to the players

[ 84221] = {"Sickening Poison",              false}, -- vCoS -- Sickening Poison (Veteran)
[ 84222] = {"Sickening Poison",              false}, -- vCoS -- Sickening Poison (Normal)
[ 84224] = {"Delirium Poison",               false}, -- vCoS -- Delirium Poison (Normal)
[ 84225] = {"Delirium Poison",               false}, -- vCoS -- Delirium Poison (Veteran)
[ 84227] = {"Enfeebling Poison",             false}, -- vCoS -- Enfeebling Poison (Veteran)
[ 84228] = {"Enfeebling Poison",             false}, -- vCoS -- Enfeebling Poison (Normal)

[123210] = {"Azure Blaze",                   false}, -- vLoM -- HM last boss (unconfirmed this is correct)

[ 95230] = {"Venom Injection",               false}, -- vHoF boss 1 Venom Injection
[ 90409] = {"Melting Point",                 false}, -- vHoF boss 4 triplet Melting Point

--[] = {"",         false}, -- v
--[] = {"",         false}, -- v

}





local PURGE_DEBUFF_COUNT   = 1
local PURGE_DEBUFF_EXPIRES = 2
local PURGE_UNIT_TAG       = 3
local PURGE_IS_PLAYER      = 4
local PURGE_AT_NAME        = 5
local PURGE_NAME           = 6
local PURGE_UNIT_ID        = 7
local PURGE_TRAUMA_ACTIVE  = 8
local PURGE_ECHOING_VIGOR_EXPIRES = 9
HealerHelper.purgeMembers = {
-- parameter 1 PURGE_DEBUFF_COUNT = how many purgables
-- parameter 2 PURGE_DEBUFF_EXPIRES = expire last purgable by GameTimeMilliseconds()
-- parameter 3 PURGE_UNIT_TAG = player UnitTag
-- parameter 4 PURGE_IS_PLAYER = is the active player (myself)
-- parameter 5 PURGE_AT_NAME = player's @name
-- parameter 6 PURGE_NAME = player's character name
-- parameter 7 PURGE_UNIT_ID = player's unit id
-- parameter 8 PURGE_TRAUMA_ACTIVE = is trauma active
-- parameter 9 PURGE_ECHOING_VIGOR_EXPIRES = when echoing vigor expires GetGameTimeMilliseconds()

-- index: player index "group2"
[1]  = {0, 0, "", false, "", "", 0, false, 0},
[2]  = {0, 0, "", false, "", "", 0, false, 0},
[3]  = {0, 0, "", false, "", "", 0, false, 0},
[4]  = {0, 0, "", false, "", "", 0, false, 0},
[5]  = {0, 0, "", false, "", "", 0, false, 0},
[6]  = {0, 0, "", false, "", "", 0, false, 0},
[7]  = {0, 0, "", false, "", "", 0, false, 0},
[8]  = {0, 0, "", false, "", "", 0, false, 0},
[9]  = {0, 0, "", false, "", "", 0, false, 0},
[10] = {0, 0, "", false, "", "", 0, false, 0},
[11] = {0, 0, "", false, "", "", 0, false, 0},
[12] = {0, 0, "", false, "", "", 0, false, 0},

}

function HealerHelper.boolToString(bool)
    if bool then
        return "true"
    else
        return "false"
    end
end
function HealerHelper.printPurgeDebug()
    for i = 1, 12 do
        local expiresIn = HealerHelper.purgeMembers[i][PURGE_DEBUFF_EXPIRES] - GetGameTimeMilliseconds()
        if  expiresIn < 0 then
            expiresIn = 0
        end
        --d(i)
        --d(HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT])
        --d(expiresIn)
        --d(HealerHelper.purgeMembers[i][PURGE_UNIT_TAG])
        --d(HealerHelper.boolToString(HealerHelper.purgeMembers[i][PURGE_IS_PLAYER]))

        d("[" .. i .. "] P:" .. HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT] .. " E:" .. expiresIn .. " G:" .. HealerHelper.purgeMembers[i][PURGE_UNIT_TAG] .. " Self:" .. HealerHelper.boolToString(HealerHelper.purgeMembers[i][PURGE_IS_PLAYER]).. " Name:" .. HealerHelper.purgeMembers[i][PURGE_AT_NAME] .." "..HealerHelper.purgeMembers[i][PURGE_NAME])
    end
end

function HealerHelper.printTraumaDebug()
    for i = 1, 12 do

        --d(i)
        --d(HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT])
        --d(expiresIn)
        --d(HealerHelper.purgeMembers[i][PURGE_UNIT_TAG])
        --d(HealerHelper.boolToString(HealerHelper.purgeMembers[i][PURGE_IS_PLAYER]))

        d("[" .. i .. "] T:" ..  HealerHelper.boolToString(HealerHelper.purgeMembers[i][PURGE_TRAUMA_ACTIVE]) .. " G:" .. HealerHelper.purgeMembers[i][PURGE_UNIT_TAG] .. " Self:" .. HealerHelper.boolToString(HealerHelper.purgeMembers[i][PURGE_IS_PLAYER]).. " Name:" .. HealerHelper.purgeMembers[i][PURGE_AT_NAME] .." "..HealerHelper.purgeMembers[i][PURGE_NAME])
    end
end


function HealerHelper.resetPlayers()
    if IsUnitGrouped("player") then
        for i = 1, 12 do
            HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT]   = 0 -- nothing to purge
            HealerHelper.purgeMembers[i][PURGE_DEBUFF_EXPIRES] = 0 -- expire in the past
            HealerHelper.purgeMembers[i][PURGE_TRAUMA_ACTIVE] = false -- remove any trauma
            HealerHelper.purgeMembers[i][PURGE_ECHOING_VIGOR_EXPIRES] = 0 -- remove any echoing vigor

            local searchBy = "group"..i
            HealerHelper.purgeMembers[i][PURGE_UNIT_TAG]       = searchBy
            HealerHelper.purgeMembers[i][PURGE_IS_PLAYER]      = AreUnitsEqual("player", searchBy)
            local atName = GetUnitDisplayName(searchBy)
            if atName == nil then
                atName = ""
            end
            local didNameChange = false
            if HealerHelper.purgeMembers[i][PURGE_AT_NAME] ~= atName then
                HealerHelper.purgeMembers[i][PURGE_AT_NAME] = atName
                didNameChange=true
            end

            local characterName = GetUnitName(searchBy)
            if characterName == nil then
                characterName = ""
            end

            if HealerHelper.purgeMembers[i][PURGE_NAME] ~= characterName then
                HealerHelper.purgeMembers[i][PURGE_NAME] = characterName
                didNameChange=true
            end
            if didNameChange then
                HealerHelper.purgeMembers[i][PURGE_UNIT_ID] = 0
            end
        end
    else
        HealerHelper.purgeMembers[1][PURGE_DEBUFF_COUNT]   = 0 -- nothing to purge
        HealerHelper.purgeMembers[1][PURGE_DEBUFF_EXPIRES] = 0 -- expire in the past
        HealerHelper.purgeMembers[1][PURGE_TRAUMA_ACTIVE] = false -- remove any trauma
        HealerHelper.purgeMembers[1][PURGE_ECHOING_VIGOR_EXPIRES] = 0 -- remove any echoing vigor


        local searchBy = "player"
        HealerHelper.purgeMembers[1][PURGE_UNIT_TAG]       = searchBy
        HealerHelper.purgeMembers[1][PURGE_IS_PLAYER]      = true

        local didNameChange = false

        local atName = GetUnitDisplayName(searchBy)
        if atName == nil then
            atName = ""
        end
        local didNameChange = false
        if HealerHelper.purgeMembers[1][PURGE_AT_NAME] ~= atName then
            HealerHelper.purgeMembers[1][PURGE_AT_NAME] = atName
            didNameChange=true
        end

        HealerHelper.purgeMembers[1][PURGE_AT_NAME] = atName
        local characterName = GetUnitName(searchBy)
        if characterName == nil then
            characterName = ""
        end
        if HealerHelper.purgeMembers[1][PURGE_NAME] ~= characterName then
            HealerHelper.purgeMembers[1][PURGE_NAME] = characterName
            didNameChange=true
        end

        if didNameChange then
            HealerHelper.purgeMembers[1][PURGE_UNIT_ID] = 0
        end

        for i = 2, 12 do
            HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT]   = 0 -- nothing to purge
            HealerHelper.purgeMembers[i][PURGE_DEBUFF_EXPIRES] = 0 -- expire in the past
            HealerHelper.purgeMembers[i][PURGE_UNIT_TAG]       = ""
            HealerHelper.purgeMembers[i][PURGE_IS_PLAYER]      = false
            HealerHelper.purgeMembers[i][PURGE_AT_NAME]        = ""
            HealerHelper.purgeMembers[i][PURGE_NAME]           = ""
            HealerHelper.purgeMembers[i][PURGE_UNIT_ID]        = 0
            HealerHelper.purgeMembers[i][PURGE_TRAUMA_ACTIVE]  = false
            HealerHelper.purgeMembers[i][PURGE_ECHOING_VIGOR_EXPIRES]  = 0
        end
    end

    if HealerHelper.countTable(HealerHelper.purgeMembers) > 12 then
        d("HH: HealerHelper.purgeMembers growing ".. HealerHelper.countTable(HealerHelper.purgeMembers))
    end
end

function HealerHelper.addPurgable(targetName, targetUnitId, abilitId, duration)
    local name = zo_strformat('<<1>>', targetName)
    --d("characterName:"..name)
    local found =false
    for i = 1, 12 do
        if (name~="" and HealerHelper.purgeMembers[i][PURGE_NAME] == name) or HealerHelper.purgeMembers[i][PURGE_UNIT_ID]==targetUnitId then
            if targetUnitId~=nil then
                HealerHelper.purgeMembers[i][PURGE_UNIT_ID] = targetUnitId
            end
            HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT] = HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT] + 1 -- add a purgable to this player

            local purgeEndTime = GetGameTimeMilliseconds() + duration + 10000
            if purgeEndTime > HealerHelper.purgeMembers[i][PURGE_DEBUFF_EXPIRES] then
                HealerHelper.purgeMembers[i][PURGE_DEBUFF_EXPIRES] = purgeEndTime
            end
            --d("Adding purge to "..HealerHelper.purgeMembers[i][PURGE_AT_NAME].."-->"..HealerHelper.purgeMembers[i][PURGE_NAME])
            if found==true then
                d("HH: Error found add twice???")
            end
            found=true

        end
    end
    if found==false then
        d("HH: Error could not find who to add purge to")
    end

    if HealerHelper.countTable(HealerHelper.purgeDatabase) > 100 then
        d("HH: HealerHelper.purgeDatabase growing ".. HealerHelper.countTable(HealerHelper.purgeDatabase))
    end

end

function HealerHelper.removePurgable(targetName, targetUnitId, abilitId)
    local name = zo_strformat('<<1>>', targetName)
    --d("characterName:"..name)
    local found=false
    for i = 1, 12 do
        if (name~="" and HealerHelper.purgeMembers[i][PURGE_NAME] == name)  or HealerHelper.purgeMembers[i][PURGE_UNIT_ID]==targetUnitId then
            HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT] = HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT] - 1 -- add a purgable to this player

            if HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT] < 0 then
                HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT] = 0
            end

            if HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT]==0 then
                HealerHelper.purgeMembers[i][PURGE_DEBUFF_EXPIRES] = 0
            end
            --d("Removing purge from "..HealerHelper.purgeMembers[i][PURGE_AT_NAME].."-->"..HealerHelper.purgeMembers[i][PURGE_NAME])



            if found==true then
                d("HH: Error found remove twice???")
            end
            found=true
        end
    end

    if found==false then
        d("HH: Error could not find who to remove purge from")
    end

    if HealerHelper.countTable(HealerHelper.purgeDatabase) > 100 then
        d("HH: HealerHelper.purgeDatabase growing ".. HealerHelper.countTable(HealerHelper.purgeDatabase))
    end

end

function HealerHelper.maintainPurgable()
    for i = 1, 12 do
        if HealerHelper.purgeMembers[i][PURGE_DEBUFF_EXPIRES] < GetGameTimeMilliseconds() then
            HealerHelper.purgeMembers[i][PURGE_DEBUFF_COUNT]   = 0 -- clear all purgable
            HealerHelper.purgeMembers[i][PURGE_DEBUFF_EXPIRES] = 0 -- clear timer for purgable
        end
    end
    if HealerHelper.countTable(HealerHelper.purgeMembers) > 12 then
        d("HH: HealerHelper.purgeMembers growing ".. HealerHelper.countTable(HealerHelper.purgeMembers))
    end
end

function HealerHelper.GetPurgableDebuffs(index)
    return HealerHelper.purgeMembers[index][PURGE_DEBUFF_COUNT]
end


function HealerHelper.GetSelfishPurgableDebuffs(index)
    if HealerHelper.purgeMembers[index][PURGE_IS_PLAYER] then
        return HealerHelper.purgeMembers[index][PURGE_DEBUFF_COUNT]
    else
        return 0
    end
end


function HealerHelper.CountPurgableDebuffsInGroup(selfish)
    HealerHelper.maintainPurgable()

    local debuffsThatNeedAndAreEligableForPurge = 0

	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end

		local inRange = false
		local needsPurge = false

		if DoesUnitExist("group"..i) or (i==1 and not IsUnitGrouped("player")) then
			if HealerHelper.GetDistance("player",searchBy) <=18 and HealerHelper.GetDistance("player",searchBy) ~= -1  and IsUnitDead(searchBy)==false then
				inRange=true
			end
		end

		local debuffs = HealerHelper.GetPurgableDebuffs(i)
		if selfish then
		    debuffs = HealerHelper.GetSelfishPurgableDebuffs(i)
		end
		if debuffs > 0 then
            needsPurge = true
		end

		if needsPurge and inRange then
		    debuffsThatNeedAndAreEligableForPurge=debuffsThatNeedAndAreEligableForPurge+debuffs
		end
	end

    return debuffsThatNeedAndAreEligableForPurge
end





function HealerHelper.ShouldCastGroupPurge()
    if HealerHelper.savedVars.purgeEnabled == false then
        return false
    end

    local debuffs = HealerHelper.CountPurgableDebuffsInGroup(false) -- selfish = false

    if debuffs >= 1 then
        return true
    else
        return false
    end
end

function HealerHelper.ShouldCastSelfishPurge()

    if HealerHelper.savedVars.purgeEnabled == false then
        return false
    end

    local debuffs = HealerHelper.CountPurgableDebuffsInGroup(true) -- selfish = true

    if debuffs >= 1 then
        return true
    else
        return false
    end
end



function HealerHelper.PurgeOnCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)

    local purge = HealerHelper.purgeDatabase[abilityId]
    if purge ~= nil then
        local desc = purge[1]
        local selfishOnly = purge[2]

        local pass = false
        if selfishOnly then
            if targetType == COMBAT_UNIT_TYPE_PLAYER then -- only look at the purable if its on me
                pass = true
            end
        else
            pass = true
        end

        if pass then

            if ACTION_RESULT_EFFECT_GAINED_DURATION == result then
                --d("HHPurge:"..targetName.."("..targetUnitId.."/"..targetType..") src:"..sourceName.." ("..sourceUnitId..") ability:"..abilityName.."("..abilityId..") duration:"..hitValue.." "..desc)
                HealerHelper.addPurgable(targetName, targetUnitId, abilityId, hitValue)
            end
            if ACTION_RESULT_EFFECT_FADED == result then
                --d("HHPurge:"..targetName.."("..targetUnitId.."/"..targetType..") src:"..sourceName.." ("..sourceUnitId..") ability:"..abilityName.."("..abilityId..") faded "..desc)
                HealerHelper.removePurgable(targetName, targetUnitId, abilityId)
            end
        end
    end
end

HealerHelper.PurgeTrackingEnable = false

function HealerHelper.InitialisePurgeTracking()


    if HealerHelper.PurgeTrackingEnable == false then

        EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "PurgeTrackingGainedDuration" , EVENT_COMBAT_EVENT, HealerHelper.PurgeOnCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(HealerHelper.name .. "PurgeTrackingGainedDuration", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)

        EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "PurgeTrackingFaded" , EVENT_COMBAT_EVENT, HealerHelper.PurgeOnCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(HealerHelper.name .. "PurgeTrackingFaded", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)


        EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "UnitsEffectChanged", EVENT_EFFECT_CHANGED, HealerHelper.OnEffectChanged)

        HealerHelper.PurgeTrackingEnable = true
    end
end

function HealerHelper.DeinitialisePurgeTracking()
    if HealerHelper.PurgeTrackingEnable == true then
        EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "PurgeTrackingGainedDuration" , EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "PurgeTrackingFaded" , EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "UnitsEffectChanged", EVENT_EFFECT_CHANGED)

        HealerHelper.PurgeTrackingEnable = false
    end
end



-- this is just to assign names to players
function HealerHelper.OnEffectChanged(_, _, _, _, _, _, _, _, _, _, _, _, _, unitName, unitId)
    local name = zo_strformat('<<1>>', unitName)

    for i = 1, 12 do
        if  HealerHelper.purgeMembers[i][PURGE_NAME]==name then
            if HealerHelper.purgeMembers[i][PURGE_UNIT_ID]~=unitId then
                if HealerHelper.purgeMembers[i][PURGE_UNIT_ID]~=0 then
                    --d("changing the unit ID for "..HealerHelper.purgeMembers[i][PURGE_NAME].." "..HealerHelper.purgeMembers[i][PURGE_AT_NAME])
                end
                HealerHelper.purgeMembers[i][PURGE_UNIT_ID] = unitId -- assign name to player
                --d("assinging unit id ".. unitId .. " to ".. HealerHelper.purgeMembers[i][PURGE_NAME])
            end
        end
    end
end


function HealerHelper.countTable(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end