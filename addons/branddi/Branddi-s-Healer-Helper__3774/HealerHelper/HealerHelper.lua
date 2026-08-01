--HealerHelper = HealerHelper or { }
if HealerHelper == nil then HealerHelper = {} end
local HealerHelper = HealerHelper

--local EM		= GetEventManager()
HealerHelper.name		= "HealerHelper"
HealerHelper.version		= "1.3.2"
HealerHelper.varVersion 	= "1"

HealerHelper.addonLoaded = false

HealerHelper.skillSuggesterActive = false

HealerHelper.MIN_HEIGHT = 150
HealerHelper.MAX_HEIGHT = 200

HealerHelper.MIN_VERTICALOFFSET = 25
HealerHelper.MAX_VERTICALOFFSET = 120

HealerHelper.playerClass = 0 -- initially no class, set it later upon player activation

HealerHelper.defaults	= {
    ["global"] = true,

    ["ROoffsetX"]	= 500,
    ["ROoffsetY"]	= 500,


    ["CombatMessageOffsetX"]	= 500,
    ["CombatMessageOffsetY"]	= 700,

    ["GearMessageOffsetX"]	= 500,
    ["GearMessageOffsetY"]	= 900,



    ["arrowWidth"] = 52,
    ["arrowHeight"] = 26,
    ["arrowYOffset"] = 0,

    ["height"] = 158,
    ["verticalOffset"] = 56,
    ["gapWidth"] = 0,

    ["showYellowforOffCooldownSkills"] = true,

    ["debugCombatEventSkillDetection"] = false,

    ["extraFeatures"] = false,
    ["advancedUI"] = false,

    ["pillagersPearlsEnable"] = true,
    ["pillagersPearlsNightbladeForcePotions"] = true,
    ["pillagersPearlsMagTarget"] = 35, -- percent mag to recommend skills that generate mag (potions, blue betty, siphoning attacks)


    ["wardRecommendedHPUnderPercentage"] = 50,
    ["burstHealRecommendedHPUnderPercentage"] = 75,


    ["minimumRojoTargetsTrials"] = 2,
    ["minimumRojoTargetsDungeons"] = 1,
    ["tanksIncludedInRojoTargets"] = false,
    ["healersIncludedInRojoTargets"] = false,

    ["RojoProcWarningDuration"] = 16.0,
    ["RojoProcWarning"] = true,

    ["displayLightAttackUltigen"] = true,
    ["fontSizeLightAttackUltigen"] = 24,


    ["displayHeavyAttack"] = true,
    ["fontSizeHeavyAttack"] = 36,

    ["powerfulAssaultEnabled"] = true,
    ["minimumPaTargetsTrials"] = 2,
    ["minimumPaTargetsDungeons"] = 1,
    ["tanksIncludedInPaTargets"] = false,
    ["healersIncludedInPaTargets"] = false,


    ["recommendPillagersAtUlt"] = 375,

    ["unnecessaryHeavyAttackWarnings"] = true,
    ["unnecessaryResourcePercentage"] = 60,
    ["wrongBarHeavyAttackWarnings"] = true,

    ["metaGearWarnings"] = true,

    ["ozezanMeta"] = false,


    ["skillMorphWarning"] = true,
    ["skillMorphWarningSupressedWhileLevelingSkill"] = true, -- prevent morph warning when skill is < rank 4

    ["skillMorphWarningIllustrusHealing"] = true,
    ["skillMorphWarningMercilessResolve"] = true,



    ["enableHud"] = true,




    ["blockCastingInnerLight"] = false,
    ["blockCastingCamoHunter"] = false,
    ["blockCastingRevealingFlare"] = false,
    ["blockCastingBarrier"] = false,
    ["blockCastingFlawlessDawnbreaker"] = false,
    ["blockCastingTemporalGuard"] = false,
    ["blockCastingRelentlessFocus"] = false,

    ["enableSpaulderWarning"] = true,


    ["minorSorceryBrutalityWarning"] = true,
    ["minimumMsbTargetsTrials"] = 3,
    ["minimumMsbTargetsDungeons"] = 1,
    ["tanksIncludedInMsbTargets"] = false,
    ["healersIncludedInMsbTargets"] = false,

    ["minorProphecySavageryWarning"] = true,
    ["minimumMpsTargetsTrials"] = 3,
    ["minimumMpsTargetsDungeons"] = 1,
    ["tanksIncludedInMpsTargets"] = false,
    ["healersIncludedInMpsTargets"] = false,

    ["betaTestingMinorToughness"] = false,
    ["minorToughnessWarning"] = false,
    ["minimumMtTargetsTrials"] = 2,
    ["minimumMtTargetsDungeons"] = 1,
    ["tanksIncludedInMtTargets"] = true,
    ["healersIncludedInMtTargets"] = true,

    ["enablePotionReminder"] = true,

    ["spaulderBuffActive"] = false, -- remember the status of spaulder after /reloadui
    ["spaulderLastZoneID"] = 0,-- remember the status of spaulder after /reloadui

    ["radiatingRegenerationEnabled"] = true,
    ["radiatingRegenerationTrials"] = false,

    ["echoingVigorEnabled"] = true,

    ["minimumEchoingVigorTargetsTrials"] = 3,
    ["minimumEchoingVigorTargetsDungeons"] = 1,



    ["funnelHealthEnabled"] = true,
    ["funnelHealthTrials"] = false,


    ["majorResolveEnabled"] = true,
    ["minorVulnerabilityEnabled"] = true,
    ["olorimeEnabled"] = true,
    ["purgeEnabled"] = true,
    ["shieldEnabled"] = true,
    ["burstEnabled"] = true,


    ["traumaEnabled"] = true,

    ["debugToChat"] = false,
    --["hotkeysUnderActonBar"] = false, -- doing this automatically now

    ["enableHudWithoutFancyActionBar"] = false,


    ["fontSizeCombatMessage"] = 18,
    ["fontCombatMessage"]="Univers 57",
    ["fontColorCombatMessage"]=   {0.0, 1.0, 1.0, 1.0},


    ["fontSizeBuildMessage"] = 18,
    ["fontBuildMessage"]="Univers 57",
    ["fontColorBuildMessage"]=   {0.0, 1.0, 1.0, 1.0},


    ["audibleRojo"]=false,
    ["audibleRojoSoundEffect"]="GroupElection_Requested",

}








function HealerHelper.OnPlayerCombatState(event, inCombat)

    HealerHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()

    if inCombat ~= HealerHelper.inCombat then
        HealerHelper.inCombat = inCombat
        HealerHelper.updateUltimateCosts()

        -- reset sets as we enter into combat so that while in combat we dont' have to keep checking for new sets
        if HealerHelper.inCombat then
            HealerHelper.clearSetCountersAsEnteringCombat()
            HealerHelper.countEquipedSets(false)
        end
    end

    HealerHelper.resetPlayers()
end


function HealerHelper.combatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
    --d("combat event")

    if targetName==HealerHelper.playerName and abilityId==46331 and result == ACTION_RESULT_EFFECT_FADED then
        for slot=1,12 do -- look for crystal weapon
            if slot==6 or slot==12 then
            else
                if HealerHelper.Skills[slot] == 46331 then -- crystal activeWeaponPair
                    HealerHelper.SkillLastUsed[slot]=HealerHelper.SkillLastUsed[slot]-6000 -- make the skill expire immediatly
                end
            end
        end
    end


    if not (sourceType == COMBAT_UNIT_TYPE_PLAYER) then return end
    --if not (sourceName == HealerHelper.playerName) then return end
    --d("combat event-player")


    local combatEventSkillTime = HealerHelper.combatEventsToAdjustSkillCastTimes[abilityId]
    if combatEventSkillTime ~= nil then
        if result == ACTION_RESULT_EFFECT_GAINED_DURATION and targetType == COMBAT_UNIT_TYPE_PLAYER and sourceType == COMBAT_UNIT_TYPE_PLAYER then
            local seconds = hitValue/1000
            if HealerHelper.savedVars.debugCombatEventSkillDetection then
                d("Duration of " .. combatEventSkillTime[1] .. " needs to be adjusted to "..seconds.."s")
            end
            HealerHelper.skillProperties[combatEventSkillTime[2]][2]=seconds
        end
    end
    
    --if abilityId==81519 and (result == ACTION_RESULT_EFFECT_GAINED) then
    --    -- detected a fully charged heavy attack by using IA set bonus
    --    if HealerHelper.savedVars.debugHeavyAttackDetection then
    --        d("Fully Charged Heavy successful (via IA)")
    --    end
    --end





    local combatEvent = HealerHelper.combatEventsToSkills[abilityId]
    if combatEvent==nil then return end
    --d("combat event-player-match combat event")







    for i,results in ipairs(combatEvent[3]) do
        if results==result then
            --d("combat event-player-match combat event-match event")
            -- found match now try to match it to the correct skill on your bars
            for slot=1,12 do
                if i==6 or i==12 then
                    -- skip ultimates
                else


                    if HealerHelper.Skills[slot] == combatEvent[2] then


                        if ((GetGameTimeMilliseconds()-HealerHelper.SkillLastUsed[slot])< 200) then
                            -- some skills re-appear multiple times quickly, remove the second appearance
                            break
                        end

                        -- 61919, -- Merciless Resolve
                        -- 61930, -- Assassin's Will
                        if HealerHelper.Skills[slot] == 61930 then -- Assassin's Will
                            -- do not record a skill for Assasin's Will as we will just track merc resolve
                        else
                            HealerHelper.SkillLastUsed[slot] = GetGameTimeMilliseconds()
                        end
                        if HealerHelper.savedVars.debugCombatEventSkillDetection then
                            d("HealerHelper-Found: "..combatEvent[1])
                        end
                        break -- done stop searching now
                    else
                        --d("slot:"..slot.."  -> "..HealerHelper.Skills[slot].."!="..combatEvent[2])
                    end
                end
            end
            break -- done stop searching now
        end
    end



end

function HealerHelper.EventWeaponSwap( activeWeaponPair, locked )
    HealerHelper.currentBar = locked
    HealerHelper.loadSkills()
    HealerHelper.countEquipedSets(false)

end





function HealerHelper.OnActionSlotEffectUpdated(hotBar, hotbarCategory, actionSlotIndex)
    if false then
        d("OnActionSlotEffectUpdated hotBar:".." hotbarCategory:"..hotbarCategory.." actionSlotIndex:"..actionSlotIndex.." bound:"..GetSlotBoundId(actionSlotIndex, hotbarCategory))
    end
    --hotbarCategory = 0,1 for bar 1 and bar 2
    --actionSlotIndex 1,2,3,4,5,6,7,8 for action??
end




function HealerHelper.loadSkills()
    for slot=3,8 do

        local value = GetSlotBoundId(slot)

        -- convert skill to main skill id if needed
        if not (HealerHelper.remapSkillId[value] == nil) then
            value = HealerHelper.remapSkillId[value]
        end

        local u = IsSlotUsable(slot)
        local t = HasTargetFailure(slot)
        local r = HasRangeFailure(slot)
        local w = HasWeaponSlotFailure(slot)
        local q = HasRequirementFailure(slot)

        local skillSlotNumber = slot - 2 + ((HealerHelper.currentBar-1) * 6)

        if HealerHelper.Skills[skillSlotNumber] ~= value then
            if value==61930 and HealerHelper.Skills[slot-2]==61919 then -- do not reset timers for this skill
                -- 61919, -- Merciless Resolve
                -- 61930, -- Assassin's Will
                HealerHelper.Skills[skillSlotNumber] = value
            elseif value==61919 and HealerHelper.Skills[slot-2]==61930 then
                -- 61919, -- Merciless Resolve
                -- 61930, -- Assassin's Will
                HealerHelper.Skills[skillSlotNumber] = value
            else
                HealerHelper.Skills[skillSlotNumber] = value
                HealerHelper.SkillLastUsed[skillSlotNumber] = 0
            end
        end

        if u and (not t) and (not r) and (not w) and (not q) then
           -- skill is usable
           HealerHelper.SkillUsable[skillSlotNumber] = true
        else
           HealerHelper.SkillUsable[skillSlotNumber] = false
        end
    end
    HealerHelper.checkForIncorrectMorphs()
end


function HealerHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()
	local pvp = IsPlayerInAvAWorld() or IsActiveWorldBattleground() -- disable in PVP

    if pvp == false and (GetSelectedLFGRole()==4 or HealerHelper.forceEnable) then -- healer==4
	    HealerHelper.LoadAddon()
	    if HealerHelper.HudCanBeDisplayed and HealerHelper.savedVars.enableHud then
            HealerHelperFrame:SetHidden(false)
        end
	    --HealerHelperRoFrame:SetHidden(true)

	else
	    HealerHelper.UnloadAddon()
	    HealerHelperFrame:SetHidden(true)
	    HealerHelperRoFrame:SetHidden(true)
        HealerHelperCombatMessageFrame:SetHidden(true)
        HealerHelperGearMessageFrame:SetHidden(true)
	end
end

function HealerHelper.LoadAddon()
    if HealerHelper.addonLoaded == false then
        --d("Healer Helper Loaded")

        EVENT_MANAGER:RegisterForEvent(HealerHelper.name.."ECE", EVENT_COMBAT_EVENT, HealerHelper.combatEvent)
        EVENT_MANAGER:RegisterForEvent(HealerHelper.name, EVENT_ACTION_SLOT_ABILITY_USED, HealerHelper.onActionSlotAbilityUsed)



        --EVENT_MANAGER:RegisterForEvent(HealerHelper.name, EVENT_EFFECT_CHANGED, HealerHelper.checkEffectChanged)
        EVENT_MANAGER:RegisterForEvent(HealerHelper.name, EVENT_ACTION_SLOT_EFFECT_UPDATE, HealerHelper.OnActionSlotEffectUpdated)

        HealerHelper.InitialiseHud()
	    HealerHelper.InitialisePurgeTracking()
        HealerHelper.InitialiseRoTracking()
        HealerHelper.InitialiseArchdruidTracking()
        HealerHelper.InitialiseUltimateGenerationTracking()
        HealerHelper.InitialiseGetSetsTracking()
        HealerHelper.InitialiseSpaulderTracking()
        HealerHelper.InitialiseOlorimeTracking()
        HealerHelper.InitialiseHeavyAttackTracking()
        HealerHelper.InitialiseSkillBlocking()
        HealerHelper.InitialiseTraumaTracking()
        HealerHelper.InitialiseEchoingVigorTracking()

	    HealerHelper.addonLoaded=true

	    HealerHelper.loadSkills()

	    HealerHelper.activateSkillSuggester()
	end
end

function HealerHelper.UnloadAddon()
    if HealerHelper.addonLoaded == true then
        --d("Healer Helper Unloaded")
        HealerHelper.deactivateSkillSuggester()
        EVENT_MANAGER:UnregisterForEvent(HealerHelper.name.."ECE", EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(HealerHelper.name, EVENT_ACTION_SLOT_ABILITY_USED)

   	    HealerHelper.DeinitialisePurgeTracking()
        HealerHelper.DeinitialiseRoTracking()
        HealerHelper.DeinitialiseArchdruidTracking()
        HealerHelper.DeinitialiseUltimateGenerationTracking()
        HealerHelper.DeinitialiseGetSetsTracking()
        HealerHelper.DeinitialiseSpaulderTracking()
        HealerHelper.DeinitialiseOlorimeTracking()
        HealerHelper.DeinitialiseHeavyAttackTracking()
        HealerHelper.DeinitialiseSkillBlocking()
        HealerHelper.DeinitialiseTraumaTracking()
        HealerHelper.DeinitialiseEchoingVigorTracking()

	    HealerHelper.addonLoaded=false
	end
end


function HealerHelper.onActionSlotAbilityUsed (eventCode,slotNum)



    if slotNum < 3 or slotNum > 7 then return end

    local useSlotNum = slotNum - 2
    if HealerHelper.currentBar == 2 then
        useSlotNum= useSlotNum + 6
    end



    local skillProperties = HealerHelper.skillProperties[HealerHelper.Skills[useSlotNum]]
    if not(skillProperties==nil) then
        if skillProperties[4]==true then
            return -- do not set time based on AbilityUsed, rather use combatEvents
        end
    end
    HealerHelper.SkillLastUsed[useSlotNum] = GetGameTimeMilliseconds()
end




function HealerHelper.printDebug() -- had to add 2 because it was runnign the wrong code
    local currentTime = GetGameTimeMilliseconds()
    for skillSlot=1,12 do
        if skillSlot == 6 or skillSlot==12 then
            -- skip ultimates
        else

            local skillId = HealerHelper.Skills[skillSlot]
            if skillId == nil then
                skillId = -1
            end

            local skillLastUsed = HealerHelper.SkillLastUsed[skillSlot]
            if skillLastUsed==nil then
                skillLastUsed=0
            end
            local skillSinceLastUsed = (currentTime-skillLastUsed)/1000
            local skillSinceLastUsedUnits = "s"
            if skillSinceLastUsed>60 then
                skillSinceLastUsed="never"
                skillSinceLastUsedUnits=""
            end

            local skillProperty = HealerHelper.skillProperties[skillId]
            local skillName="Unknown Skill"
            local secondsBetweenCasts=-100
            local HpUnderPercentCasts=-1

            if not (skillProperty==nil) then
                skillName=skillProperty[1] -- name of the skill
                secondsBetweenCasts=skillProperty[2] -- how often to cast the skill
                HpUnderPercentCasts=skillProperty[3] -- cast HP under %
                --d("not nil")
            end
            --d(skillProperty)
            local secondsBetweenCastsUnits="s"
            if secondsBetweenCasts == -100 then
                secondsBetweenCasts=""
                secondsBetweenCastsUnits=""
            elseif secondsBetweenCasts == -1 then
                secondsBetweenCasts="demand"
                secondsBetweenCastsUnits=""
            elseif secondsBetweenCasts == 0 then
                secondsBetweenCasts="spam"
                secondsBetweenCastsUnits=""
            end

            HpUnderPercentCastsUnits="%"
            if HpUnderPercentCasts==-1 then
                HpUnderPercentCasts="n/a"
                HpUnderPercentCastsUnits=""
            end

            local shouldCast = "False"
            if HealerHelper.doSkillNeedToBeCastBasedOnCooldown(skillSlot) then
                shouldCast="True"
            end


            d("slot"..skillSlot..": "..skillName.."  ("..skillId..") cast: "..secondsBetweenCasts..secondsBetweenCastsUnits.." HP%: "..HpUnderPercentCasts..HpUnderPercentCastsUnits.. " LastUsed:"..skillSinceLastUsed..skillSinceLastUsedUnits.." Cast? "..shouldCast)



            local activeWeaponPair = GetActiveWeaponPairInfo()
        end
    end

end





function HealerHelper.Init(event, addon)

	if addon ~= HealerHelper.name then return end

	EVENT_MANAGER:UnregisterForEvent(HealerHelper.name.."Load", EVENT_ADD_ON_LOADED)



    HealerHelper.playerName = GetRawUnitName("player")

    HealerHelper.Skills = {}
    HealerHelper.SkillUsable = {}
    HealerHelper.SkillLastUsed = {}

	HealerHelper.inCombat = IsUnitInCombat("player")


    local currentHotbarCategory = GetActiveHotbarCategory()

	if currentHotbarCategory == HOTBAR_CATEGORY_PRIMARY then
		HealerHelper.currentBar = 1
	elseif currentHotbarCategory == HOTBAR_CATEGORY_BACKUP then
		HealerHelper.currentBar = 2
	else
        HealerHelper.currentBar = 1 -- default to 1 until we know what bar we are on
	end




    HealerHelper.forceEnable = false -- by default only enable addon for Healers



    HealerHelper.savedVars = ZO_SavedVars:NewCharacterIdSettings(HealerHelper.name.."SavedVars",  HealerHelper.varVersion, nil, HealerHelper.defaults)
    if HealerHelper.savedVars.global then
        HealerHelper.savedVars = ZO_SavedVars:NewAccountWide(HealerHelper.name.."SavedVars",  HealerHelper.varVersion, nil, HealerHelper.defaults)
        HealerHelper.savedVars.global = true
    end

    if GetDisplayName() == "@Branddi" then -- enable debugging by default for myself
        HealerHelper.savedVars.debugToChat = true
    end

    if HealerHelper.savedVars.betaTestingMinorToughness == false then
        HealerHelper.savedVars.minorToughnessWarning = false
    end



    SLASH_COMMANDS["/hh"] = HealerHelper.slashCommands

    EVENT_MANAGER:RegisterForEvent(HealerHelper.name.."Player_Active", EVENT_PLAYER_ACTIVATED, HealerHelper.PlayerActivated)

end





function HealerHelper.PlayerActivated(_, initial)
	EVENT_MANAGER:UnregisterForEvent(HealerHelper.name.."Player_Active", EVENT_PLAYER_ACTIVATED)


    HealerHelper.playerClass = GetUnitClassId("player")

    HealerHelper.setupMenu()



    EVENT_MANAGER:RegisterForEvent(HealerHelper.name.."PassiveHide", EVENT_PLAYER_COMBAT_STATE, HealerHelper.OnPlayerCombatState)

    EVENT_MANAGER:RegisterForEvent(HealerHelper.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, HealerHelper.EventWeaponSwap)
    EVENT_MANAGER:RegisterForEvent(HealerHelper.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, HealerHelper.adjustFrameLocation)


    HealerHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()

    HealerHelper.adjustFrameLocation()
    HealerHelper.updateSkillBlocking()

    HealerHelper.SpaulderOnPlayerActivatedTask(initial)
end
EVENT_MANAGER:RegisterForEvent(HealerHelper.name.."Load", EVENT_ADD_ON_LOADED, HealerHelper.Init)
