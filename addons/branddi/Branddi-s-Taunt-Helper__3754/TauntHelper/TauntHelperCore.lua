
function TauntHelper.lookForMechs(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
    if result==ACTION_RESULT_EFFECT_FADED then return end -- not interested in the end of the skill Sarydil does this for example


    --if abilityId == 207422 then -- vBV last boss last wall phase
    --    local current, max, effective = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    --    local bossHP = ( current / max ) * 100
    --    if (bossHP>20.5) then
    --        return -- this is one of the phases where the boss is gone for possibly less than 15s
    --    end
    --end

    if abilityId == 120825 then -- Nahviintaas only for specific add spawens
        local current, max, effective = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
        local bossHP = ( current / max ) * 100
        if (bossHP>80) or (bossHP<75 and bossHP>60) or (bossHP<55 and bossHP>40) or (bossHP<35) then
            return -- these adds must be portal adds ignore them
        end
    end

    if abilityId == 166909 or abilityId == 166745 then  -- DSR Lylanar / Turlassil
        local current, max, effective = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
        local bossHP1 = ( current / max ) * 100

        current, max, effective = GetUnitPower("boss2", COMBAT_MECHANIC_FLAGS_HEALTH)
        local bossHP2 = ( current / max ) * 100

        if bossHP1 < 100 and bossHP2 < 100 then
            --if TauntHelper.savedVars.debugToChat then d("skipping MultiLoc since it's the second one") end
            return -- only clear taunt for the teleports of the first twin teleport/bash phase
        end
    end



    if TauntHelper.combatEventsToClearTauntFromList[abilityId] ~= nil then
        local mobName1 = TauntHelper.combatEventsToClearTauntFromList[abilityId][2]
        local mobName2 = TauntHelper.combatEventsToClearTauntFromList[abilityId][3]


        if TauntHelper.combatEventsToClearTauntFromList[abilityId][1]==true and TauntHelper.savedVars.debugToChat then d("lookForMechs found abilitID = "..abilityId .." result:"..result.." mobName1:"..mobName1) end


        if mobName1 ~= nil then

            if TauntHelper.combatEventsToClearTauntFromList[abilityId][1]==true and TauntHelper.savedVars.debugToChat then d("removing taunts for mobName1:"..mobName1) end

            TauntHelper.removeMobDueToMechanicByName(mobName1)
        end

        if mobName2 ~= nil then

            if TauntHelper.combatEventsToClearTauntFromList[abilityId][1]==true and TauntHelper.savedVars.debugToChat then d("removing taunts for mobName2:"..mobName2) end

            TauntHelper.removeMobDueToMechanicByName(mobName2)
        end
    end
end


function TauntHelper.lookForLoose(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)

    local mobAttackedPlayer = false
    local looseUnitId =nil
    local unitNameClean=""
    --local stopProcessingLoose = false

    if TauntHelper.combatEventsToClearTauntFromList[abilityId] ~= nil then return end
    -- do not proceed further if the ability is in TauntHelper.combatEventsToClearTauntFromList




    if sourceType == COMBAT_UNIT_TYPE_NONE then
	    if sourceName == nil then return end
        unitNameClean = zo_strformat("<<1>>",sourceName)
        if unitNameClean == "Offline" then return end

        looseUnitId = sourceUnitId
        mobAttackedPlayer = true

        if TauntHelper.bossesThatCastWhenImmuneFromTauntList[unitNameClean] then return end


        --  d("source type none "..unitNameClean.." ("..sourceType..")")
    elseif targetType == COMBAT_UNIT_TYPE_NONE or targetType == COMBAT_UNIT_TYPE_TARGET_DUMMY then
	    if targetName == nil then return end
        unitNameClean = zo_strformat("<<1>>",targetName)
        if unitNameClean == "Offline" then return end
        looseUnitId = targetUnitId
        --d("target type none "..unitNameClean.." ("..targetType..")")

    end
    if unitNameClean == "" then return end
    if unitNameClean == nil then return end
    if looseUnitId == nil then return end
    local internationalName = unitNameClean
    unitNameClean = TauntHelper.getEnglishNameForInternationalName(unitNameClean)


    if TauntHelper.neverCheckForLoose[unitNameClean] ~= nil then return end


    local tauntListEntry = TauntHelper.createOrGetTauntListEntry(looseUnitId, unitNameClean, internationalName)


    if tauntListEntry[TauntHelper.TAUNT_LIST_IGNOREUNTILTIME] > GetGameTimeMilliseconds() then return end -- ignore due to sometime like cowering

    if TauntHelper.isMobLoosableForCurrentZone (unitNameClean, mobAttackedPlayer, internationalName) then
        if tauntListEntry[TauntHelper.TAUNT_LIST_DIED]==false then


            tauntListEntry[TauntHelper.TAUNT_LIST_ENABLE]=true
            tauntListEntry[TauntHelper.TAUNT_LIST_LASTSEENTIME]=GetGameTimeMilliseconds()



            if unitNameClean == "Scorion Collector" and abilityId == 157886 then -- DC Scorion Collector - Collect (in portal)
                tauntListEntry[TauntHelper.TAUNT_LIST_ENABLE]=false
                tauntListEntry[TauntHelper.TAUNT_LIST_DIED]=true -- remove this mob as it's not something we need to taunt
            end

            if unitNameClean == "Daedroth" and abilityId == 88401 then
                tauntListEntry[TauntHelper.TAUNT_LIST_ENABLE]=false
                tauntListEntry[TauntHelper.TAUNT_LIST_DIED]=true -- this is Maw of the Infernal - just presume it has died

            elseif unitNameClean == "Daedroth" then -- troubleshoot Maw of the Infernal
                if TauntHelper.savedVars.debugToChat then
                    if abilityId == 20546 or abilityId == 202397 or abilityId == 202401 or abilityId == 202403 or abilityId == 202400 or abilityId == 69773 or abilityId == 202407 or abilityId == 202396  or abilityId == 202416  or abilityId == 2874 or abilityId == 202412 or abilityId == 202413 or abilityId == 202415 or abilityId == 4750 or abilityId == 91949 or abilityId == 91953 or abilityId == 91946 or abilityId == 4772 or abilityId == 201265 or abilityId == 91938 or abilityId == 91940 or abilityId == 91941  or abilityId == 91937 or abilityId == 91939 or abilityId == 91943 then -- or  abilityId == x  then --or  abilityId == x or  then                    else
                        -- don't show these ability Ids
                    else
                        if sourceType == COMBAT_UNIT_TYPE_NONE then
                            if TauntHelper.savedVars.debugToChat then d("Daedroth source "..abilityId) end
                        else
                            --if TauntHelper.savedVars.debugToChat then d("Daedroth target "..abilityId) end
                        end

                    end
                end

            end

        else
            --if TauntHelper.savedVars.debugToChat then d("dead mob found loose, did not add") end
        end

    else
        --tauntListEntry[TauntHelper.TAUNT_LIST_ENABLE]=false -- if we do this then disabling loose mobs turns off all mobs
    end
end


function TauntHelper.onCowerStart( _,  changeType,  _,  _,  _, beginTime, endTime,  stackCount,  _,  _,  effectType, _,  _,  unitName, unitId, abilityId, sourceType)

    if TauntHelper.effectChangedToClearTauntFromList[abilityId] ~= nil then
        if TauntHelper.effectChangedToClearTauntFromList[abilityId][1]==true and TauntHelper.savedVars.debugToChat then d("abilityId==".. abilityId .." changeType:"..changeType.." was found in onCowerStart") end

        --if abilityId==104925 or abilityId==111729 or  abilityId==112458 then -- one of these is MHK Ary/Zel
        --    if TauntHelper.savedVars.debugToChat then d("abilityId==".. abilityId .." was found in onCowerStart") end
        --end

        if changeType==EFFECT_RESULT_GAINED or changeType==EFFECT_RESULT_UPDATED then
            if TauntHelper.effectChangedToClearTauntFromList[abilityId][2]=="SELF" then

                if unitId == nil then return end


                if TauntHelper.effectChangedToClearTauntFromList[abilityId][1]==true and TauntHelper.savedVars.debugToChat then d("removing taunts for unitId:"..unitId) end


                TauntHelper.removeMobDueToMechanic(unitId) -- remove mob at start of mechanic for a few seconds

            else
                local mobName1 = TauntHelper.effectChangedToClearTauntFromList[abilityId][2]
                local mobName2 = TauntHelper.effectChangedToClearTauntFromList[abilityId][3]


                if TauntHelper.effectChangedToClearTauntFromList[abilityId][1]==true and TauntHelper.savedVars.debugToChat then d("onCowerStart found abilitID = "..abilityId .." mobName1:"..mobName1.." changeType:"..changeType) end


                if mobName1 ~= nil then

                    if TauntHelper.effectChangedToClearTauntFromList[abilityId][1]==true and TauntHelper.savedVars.debugToChat then d("removing taunts for mobName1:"..mobName1) end

                    TauntHelper.removeMobDueToMechanicByName(mobName1)
                end


                if mobName2 ~= nil then

                    if TauntHelper.effectChangedToClearTauntFromList[abilityId][1]==true and TauntHelper.savedVars.debugToChat then d("removing taunts for mobName2:"..mobName2) end

                    TauntHelper.removeMobDueToMechanicByName(mobName2)
                end
            end
        end
	end
end

function TauntHelper.onTaunt( _,  changeType,  _,  _,  _, beginTime, endTime,  stackCount,  _,  _,  effectType, _,  _,  unitName, unitId, abilityId, sourceType)
    --d("TauntHelper.onTaunt")
	if (changeType~=EFFECT_RESULT_GAINED and changeType~=EFFECT_RESULT_FADED and changeType~=EFFECT_RESULT_UPDATED and effectType~=BUFF_EFFECT_TYPE_DEBUFF and effectType~=BUFF_EFFECT_TYPE_BUFF) then return end
	--if (sourceType~=COMBAT_UNIT_TYPE_PLAYER) then return end  -- disable this so we can see taunts others applied
   	--if changeType == 1 and abilityId == 88401 then return end
	if unitId == nil then return end

    if abilityId==38541 then
        if TauntHelper.savedVars.debugToChat then d("abilityId==38541 was found in ontaunt") end
    end


	local unitNameClean = zo_strformat("<<1>>",unitName)
	local internationalName = unitNameClean
    unitNameClean = TauntHelper.getEnglishNameForInternationalName(unitNameClean)

	TauntHelper.createOrGetTauntListEntry(unitId, unitNameClean,internationalName)


    if TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_IGNOREUNTILTIME] > GetGameTimeMilliseconds() then return end -- ignore due to sometime like cowering
    -- we don't add or remove taunt as cowering will put taunt in the past where we will leave it

    local endTimeInMs = endTime * 1000

	if changeType==EFFECT_RESULT_GAINED or changeType==EFFECT_RESULT_UPDATED then

        if (sourceType==COMBAT_UNIT_TYPE_PLAYER) then
            TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_IHAVETAUNT] = true
            TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_LASTTIMEWASMINE] = false
            if TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_DIED] == true then
                --if TauntHelper.savedVars.debugToChat then d("taunted dead add?? bringing to life (A)") end
                TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_DIED] = false
            end
        else
            --d("check for stolen")
            --d(TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_IHAVETAUNT])
            --d(TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_LASTTIMEWASMINE] == true)
            --d(GetGameTimeMilliseconds()-TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_LASTTAUNTLOSTTIME]<100)

            if TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_LASTTIMEWASMINE] == true  and GetGameTimeMilliseconds()-TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_LASTTAUNTLOSTTIME]<100 then
                --d("taunt stolen")
                TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_IHAVETAUNT] = false
                TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_STOLENTAUNTTIME] = GetGameTimeMilliseconds()
            end
        end

      --  d("name: "..TauntHelper.tauntList[unitId][1])
		TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_ENDTIME]=endTimeInMs

		--d("added taunt to "..TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_NAME].." "..unitId.." endTime:"..endTimeInMs.." "..stackCount.." stacks")
        if TauntHelper.isMobTrackableForCurrentZone (TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_NAME],TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_INTERNATIONAL_NAME]) then
            TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_ENABLE]=true
            if TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_DIED] == true then
                --if TauntHelper.savedVars.debugToChat then d("taunted dead add?? bringing to life (B)") end
                TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_DIED]=false
            end
            --d("taunt "..TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_NAME])
        else
            TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_ENABLE]=false
            --d("no taunt "..TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_NAME])
        end

        TauntHelper.checkRetcleForActiveTaunt() -- check for taunt right after it gets added to the database incase it's our current target

	elseif changeType==EFFECT_RESULT_FADED then
	    local dif = TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_ENDTIME]-GetGameTimeMilliseconds()
	    if dif > 50 or dif < -200 then -- faded at the wrong time, removed by boss mech???

            --d("taunt taunt dropped early "..dif) -- this usually happens when the boss does some mech that removes taunt from itself, or is re-taunted

            if TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_IHAVETAUNT] then
                TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_LASTTIMEWASMINE]=true
            end

            TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_LASTTAUNTLOSTTIME]=GetGameTimeMilliseconds()

            TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_ENDTIME]=0
            TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_IHAVETAUNT]=false

            if TauntHelper.bossesThatRemoveTauntList[TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_NAME]] then -- this is a boss that does drop taunt
                TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_ENABLE]=false  -- for these bosses remove from list when taunt dropps off
            end

        else
            --d("taunt was dropped at the end 15s "..dif)
            -- leave taunt on the list since we didn't renew it

	    end

        --TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_ENDTIME]=0
        --TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_ENABLE]=false
        --d("removed taunt from "..TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_NAME].." "..unitId)

	end

end




--(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityID)
function TauntHelper.onTauntImmunity( _,  changeType,  _,  _,  _, beginTime, endTime,  stackCount,  _,  _,  effectType, _,  _,  unitName, unitId, abilityId, sourceType)
    --d("TauntHelper.onTaunt")
	if (changeType~=EFFECT_RESULT_GAINED and changeType~=EFFECT_RESULT_FADED and changeType~=EFFECT_RESULT_UPDATED and effectType~=BUFF_EFFECT_TYPE_DEBUFF and effectType~=BUFF_EFFECT_TYPE_BUFF) then return end
	--if (sourceType~=COMBAT_UNIT_TYPE_PLAYER) then return end  -- disable this so we can see taunts others applied
   	--if changeType == 1 and abilityId == 88401 then return end
	if unitId == nil then return end




	local unitNameClean = zo_strformat("<<1>>",unitName)
	local internationalName = unitNameClean
    unitNameClean = TauntHelper.getEnglishNameForInternationalName(unitNameClean)

	TauntHelper.createOrGetTauntListEntry(unitId, unitNameClean, internationalName)





    local endTimeInMs = endTime * 1000
    --if abilityId==52788 then
    --    if TauntHelper.savedVars.debugToChat then d("abilityId==52788 was found in onTauntImmunity stacks:"..stackCount.." "..endTimeInMs-GetGameTimeMilliseconds().."ms remaining") end
    --end


	if changeType==EFFECT_RESULT_GAINED or changeType==EFFECT_RESULT_UPDATED then
        TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_TAUNTIMMUNITYENDTIME] = endTimeInMs
	elseif changeType==EFFECT_RESULT_FADED then
        TauntHelper.tauntList[unitId][TauntHelper.TAUNT_LIST_TAUNTIMMUNITYENDTIME] = 0
	end


end



function TauntHelper.OnUnitDeath(_, result, _, _, _, _, _, _, targetName, targetType, _, _, _, _, _, targetUnitId, _)
    local tauntInfo = TauntHelper.tauntList[targetUnitId]
    if tauntInfo ~= nil then
        --d("unit died: "..TauntHelper.tauntList[targetUnitId][TauntHelper.TAUNT_LIST_NAME].." ".. TauntHelper.tauntList[targetUnitId][TauntHelper.TAUNT_LIST_ENDTIME]-GetGameTimeMilliseconds() .. "ms remaining")
        TauntHelper.tauntList[targetUnitId][TauntHelper.TAUNT_LIST_ENDTIME]=0
        TauntHelper.tauntList[targetUnitId][TauntHelper.TAUNT_LIST_ENABLE]=false
        TauntHelper.tauntList[targetUnitId][TauntHelper.TAUNT_LIST_IHAVETAUNT]=false
        TauntHelper.tauntList[targetUnitId][TauntHelper.TAUNT_LIST_DIED]=true

    else
        --d("something died")
    end
end


--[[
function TauntHelper.checkRetcleForTrackableMob()
    if not DoesUnitExist("reticleover") then
        TauntHelper.reticleIsTrackedMob = false
        if TauntHelper.savedVars.debugToChat then d("reticle: False") end
        return
    end

    local unitNameClean = zo_strformat("<<1>>",GetUnitName("reticleover"))

    if unitNameClean == "" then
        TauntHelper.reticleIsTrackedMob = false
        if TauntHelper.savedVars.debugToChat then d("reticle: False") end
        return
    end

    local internationalName = unitNameClean
    unitNameClean = TauntHelper.getEnglishNameForInternationalName(unitNameClean)

    if TauntHelper.isMobTrackableForCurrentZone (unitNameClean,internationalName) then
        TauntHelper.reticleIsTrackedMob = true
        if TauntHelper.savedVars.debugToChat then d("reticle: True") end
        return
    else
        TauntHelper.reticleIsTrackedMob = false
        if TauntHelper.savedVars.debugToChat then d("reticle: False") end
        return
    end
end
--]]


function TauntHelper.checkRetcleForActiveTaunt()
    TauntHelper.reticleOverUnitId = 0
    TauntHelper.reticleOverStacks = 0

	if not DoesUnitExist("reticleover") then return end
    local difficulty = GetUnitDifficulty("reticleover")
    local tauntCounter = 0

	for i = 1, GetNumBuffs("reticleover") do

		local buffName, startTime, endTime, buffSlot, stackCount, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("reticleover", i)

        if buffName == "Taunt Counter" and abilityId~=52790 then
            d(buffName.." "..abilityId)
        end

        if abilityId == 52790 then
            tauntCounter = stackCount
             --d(buffName.." "..abilityId.." '"..stackCount.."'")
            TauntHelper.reticleOverStacks = stackCount
        end
        if abilityId==38254 or abilityId==38541 then
            --d("abilityId".. abilityId.. " "..buffName)
            if abilityId==38541 then
                if TauntHelper.savedVars.debugToChat then d("abilityId==38541 was found in target change") end
            end
            for unitId, tauntDetails in pairs(TauntHelper.tauntList) do
                if tauntDetails[TauntHelper.TAUNT_LIST_ENDTIME]==endTime*1000 then
                    TauntHelper.reticleOverUnitId=unitId -- identify which is the active unitId
                    if tauntDetails[TauntHelper.TAUNT_LIST_DIFFICULTY]==nil then
                        tauntDetails[TauntHelper.TAUNT_LIST_DIFFICULTY]=difficulty -- apply the difficulty since not already set
                    end
                end
            end
            --break
        end
	end
    if tauntCounter>1 and TauntHelper.savedVars.enableTauntStacks then
        TauntHelperTauntStacksFrameLabel:SetText(tauntCounter)
        TauntHelperTauntStacksFrame:SetHidden(false)
    else
        TauntHelperTauntStacksFrame:SetHidden(true)
    end

end


function TauntHelper.OnTargetChange()
    --TauntHelper.checkRetcleForTrackableMob()

    TauntHelper.updateUI() -- this will check the activeTaunt for us anyways
   --TauntHelper.checkRetcleForActiveTaunt()
end





function TauntHelper.OnTauntCleanup()

    TauntHelper.tauntList={}
end

TauntHelper.onTauntInitialized = false

function TauntHelper.InitializeOnTaunt()

    if TauntHelper.onTauntInitialized == false then

        if TauntHelper.savedVars.debugToChat then d("Taunt Helper on") end


        EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."_TAUNT_38254", EVENT_EFFECT_CHANGED, TauntHelper.onTaunt)
        EVENT_MANAGER:AddFilterForEvent(TauntHelper.name.."_TAUNT_38254", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 38254, REGISTER_FILTER_IS_ERROR, false) -- just taunt 38254 this is the common one, not sure about the other?

        EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."_TAUNT_38541", EVENT_EFFECT_CHANGED, TauntHelper.onTaunt)
        EVENT_MANAGER:AddFilterForEvent(TauntHelper.name.."_TAUNT_38541", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 38541, REGISTER_FILTER_IS_ERROR, false) -- just taunt 38541



        for k,v in pairs(TauntHelper.effectChangedToClearTauntFromList ) do
            EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."_OnCower_"..k, EVENT_EFFECT_CHANGED, TauntHelper.onCowerStart)
            EVENT_MANAGER:AddFilterForEvent(TauntHelper.name.."_OnCower_"..k, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, k, REGISTER_FILTER_IS_ERROR, false) -- just taunt 38254 this is the common one, not sure about the other?
        end



        EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."_TAUNT_52788", EVENT_EFFECT_CHANGED, TauntHelper.onTauntImmunity)
        EVENT_MANAGER:AddFilterForEvent(TauntHelper.name.."_TAUNT_52788", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 52788, REGISTER_FILTER_IS_ERROR, false) -- just taunt immunity 52788



        --EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."_LookForLooseSource", EVENT_COMBAT_EVENT, TauntHelper.lookForLoose)
        --EVENT_MANAGER:AddFilterForEvent(TauntHelper.name.."_LookForLooseSource", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE, REGISTER_FILTER_IS_ERROR, false)


        EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."_LookForLooseTarget", EVENT_COMBAT_EVENT, TauntHelper.lookForLoose)
        EVENT_MANAGER:AddFilterForEvent(TauntHelper.name.."_LookForLooseTarget", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE, REGISTER_FILTER_IS_ERROR, false)


        EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."_LookForLooseDummy", EVENT_COMBAT_EVENT, TauntHelper.lookForLoose)
        EVENT_MANAGER:AddFilterForEvent(TauntHelper.name.."_LookForLooseDummy", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_TARGET_DUMMY, REGISTER_FILTER_IS_ERROR, false)



        EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."_OnUnitDeath_2260", EVENT_COMBAT_EVENT, TauntHelper.OnUnitDeath)
        EVENT_MANAGER:AddFilterForEvent(TauntHelper.name.."_OnUnitDeath_2260", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, 2260, REGISTER_FILTER_IS_ERROR, false) -- not needed?

        EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."_OnUnitDeath_2262", EVENT_COMBAT_EVENT, TauntHelper.OnUnitDeath)
        EVENT_MANAGER:AddFilterForEvent(TauntHelper.name.."_OnUnitDeath_2262", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, 2262, REGISTER_FILTER_IS_ERROR, false)



        for k,v in pairs(TauntHelper.combatEventsToClearTauntFromList ) do
            EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."_lookForMechs_"..k, EVENT_COMBAT_EVENT, TauntHelper.lookForMechs)
            EVENT_MANAGER:AddFilterForEvent(TauntHelper.name.."_lookForMechs_"..k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k, REGISTER_FILTER_IS_ERROR, false)
        end







        EVENT_MANAGER:RegisterForEvent(TauntHelper.name.."_TargetChange", EVENT_RETICLE_TARGET_CHANGED , TauntHelper.OnTargetChange)

        EVENT_MANAGER:RegisterForUpdate(TauntHelper.name.."UpdateUI", 100, function(gameTimeMs) TauntHelper.updateUI() end)

        TauntHelper.onTauntInitialized = true
    end
end


function TauntHelper.DeinitializeOnTaunt()
    if TauntHelper.onTauntInitialized == true then

        if TauntHelper.savedVars.debugToChat then d("Taunt Helper off") end

        EVENT_MANAGER:UnregisterForUpdate(TauntHelper.name.."UpdateUI")

        EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."_TAUNT_38254", EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."_TAUNT_38541", EVENT_EFFECT_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."_TAUNT_52788", EVENT_EFFECT_CHANGED)


        for k,v in pairs(TauntHelper.effectChangedToClearTauntFromList ) do
            EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."_OnCower_"..k, EVENT_EFFECT_CHANGED)
        end



        EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."_LookForLooseSource", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."_LookForLooseTarget", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."_LookForLooseDummy", EVENT_COMBAT_EVENT)


        EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."_OnUnitDeath_2260", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."_OnUnitDeath_2262", EVENT_COMBAT_EVENT)


        for k,v in pairs(TauntHelper.combatEventsToClearTauntFromList ) do
            EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."_lookForMechs_"..k, EVENT_COMBAT_EVENT)
        end



        EVENT_MANAGER:UnregisterForEvent(TauntHelper.name.."_TargetChange", EVENT_RETICLE_TARGET_CHANGED)

        TauntHelper.onTauntInitialized = false

        TauntHelper.updateUI()
	end
end

function TauntHelper.isTauntNeededInSeconds(seconds)
    if TauntHelper.onTauntInitialized then

        for unitId, tauntDetails in pairs(TauntHelper.tauntList) do
            if tauntDetails[TauntHelper.TAUNT_LIST_ENABLE] then
                local tauntExpires = tauntDetails[TauntHelper.TAUNT_LIST_ENDTIME] - GetGameTimeMilliseconds()

                if tauntExpires > 0 and tauntExpires < seconds*1000 then

                    return true
                end
            end
        end
    end
    return false
end
