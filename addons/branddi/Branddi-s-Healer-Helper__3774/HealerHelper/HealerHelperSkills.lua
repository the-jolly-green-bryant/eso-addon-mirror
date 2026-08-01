
function HealerHelper.doSkillNeedToBeCastBasedOnCooldown(slot)
    local skillId = HealerHelper.Skills[slot]
    local skillProperty = HealerHelper.skillProperties[skillId]
    local currentTime = GetGameTimeMilliseconds()


    if skillProperty == nil then
        --d("slot "..slot.." exit due to nil (skillProperty)")
        return false
    end

    local castTime = skillProperty[2]

    if castTime==nil then
        --d("slot "..slot.." exit due to nil (castTime)")
        return false
    end

    local skillLastUsed = HealerHelper.SkillLastUsed[slot]
    if skillLastUsed == nil then
        skillLastUsed=0
    end
    local skillSinceLastUsed = (currentTime-skillLastUsed)/1000

    if castTime > 0 and skillSinceLastUsed>=castTime then -- is this a time based cast? and if so is it more than 0 seconds

        return true -- we should cast this skill
    else

        return false

    end
end

function HealerHelper.doSkillSelectionTasks()

    HealerHelper.setMessage("FancyActionBar", HealerHelper.HudCanBeDisplayed == false and HealerHelper.savedVars.enableHud)

    -- had to disable this for @zerodeeps UI was incorrectly reporting an error with the UI Position
    --HealerHelper.setMessage("Hud_Edge", HealerHelper.HudCanBeDisplayed and HealerHelper.savedVars.enableHud and HealerHelper.HudHitEdgeOfScreen)

    HealerHelper.setMessage("Spaulder_Off", HealerHelper.isSpaulderNeeded())
    local trauma, who = HealerHelper.isTraumaActiveAndOnWho()
    HealerHelper.setMessage("Trauma", trauma, who)

    HealerHelper.setMessage("Wrong_Bar_HA", HealerHelper.lastWrongBarHeavyAttackTime+3000 > GetGameTimeMilliseconds() and HealerHelper.savedVars.wrongBarHeavyAttackWarnings)
    HealerHelper.setMessage("Unnecessary_HA", HealerHelper.lastUnnessisaryHeavyAttackTime+3000 > GetGameTimeMilliseconds() and HealerHelper.savedVars.unnecessaryHeavyAttackWarnings)

    HealerHelper.setMessage("MinorSorcery_Skill", HealerHelper.skillMissingToProcMinorSorcery())
    HealerHelper.setMessage("MinorBrutality_Skill", HealerHelper.skillMissingToProcMinorBrutality())
    HealerHelper.setMessage("MinorProphecy_Skill", HealerHelper.skillMissingToProcMinorProphecy())

    HealerHelper.setMessage("MinorSavagery", HealerHelper.ShouldProcDamageForMinorSavagery())
    HealerHelper.setMessage("MinorToughness", HealerHelper.ShouldProcHealForMinorToughness())

    HealerHelper.setMessage("ROJOProcShort", HealerHelper.RoProcDurationTime+10000 > GetGameTimeMilliseconds() and HealerHelper.RoProcDurationSeconds < HealerHelper.savedVars.RojoProcWarningDuration and HealerHelper.checkIfGearSetEquipped("Roaring Opportunist's") and HealerHelper.checkIfGearSetEquipped("Jorvuld's") and HealerHelper.savedVars.RojoProcWarning)


    if HealerHelper.isPotionUsable() and HealerHelper.PillagersAndPearlsRecommendBlockingPotion() ==false and HealerHelper.savedVars.enablePotionReminder then
        HealerHelper.setArrowColor(101, "smallgreen")
        HealerHelper.setArrowColor(102, "")
    else
        HealerHelper.setArrowColor(101, "")
        HealerHelper.setArrowColor(102, "")
    end

    local locatedSkillSlot = false

    for i=1,12 do
        if i == 6 or i == 12 then
            -- skip ultimates
        else
            local skillSlot = i -- 1,2,3,4,5    7,8,9,10,11
            local arrowNumber=i
            if i > 6 then
                arrowNumber=i+1 -- 8,9,10,11,12 icons
            end
            local bar = 1
            if i >= 7 then
                bar = 2
            end

            local skillId = HealerHelper.Skills[skillSlot]


            if skillId == 40079 and HealerHelper.ShouldCastRadiatingRegen() then -- Radiating Regeneration Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallgreen")
            elseif skillId == 34838 and HealerHelper.ShouldCastFunnelHealth() then -- Funnel Health Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallgreen")
            elseif skillId == 61505 and HealerHelper.ShouldCastEchoingVigor() then -- Echoing Vigor Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallgreen")
            elseif (skillId == 86126) and HealerHelper.ShouldCastExpansiveFrostCloak() then -- Expansive Frost Cloak Major Resolve Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallgreen")
            elseif (skillId == 86130) and HealerHelper.ShouldCastIceFortress() then -- Ice Fortress Major Resolve Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallgreen")
            elseif skillId == 40094 and HealerHelper.ShouldCastCombatPrayerBurst() then -- Combat Prayer Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallred")
            elseif skillId == 117883 and HealerHelper.ShouldCastResistantFleshBurst() then -- Resistant Flesh Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallred")
            elseif skillId == 77369 and HealerHelper.ShouldCastTwilightMatriarchBurst() then -- Twilight Matriarch Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallred")
            elseif skillId == 40094 and HealerHelper.ShouldCastCombatPrayer() then -- Combat Prayer Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallgreen")

            elseif skillId == 39095 and HealerHelper.targetMissingMajorBreach() then -- Elemental Drain Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallyellow")


            elseif (skillId == 40130 or skillId == 40126) and HealerHelper.ShouldCastWardAlly() then -- Ward Ally / Healing Ward Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallred")
            elseif (skillId == 39186 or skillId == 39182) and HealerHelper.ShouldCastDampenMagic() then -- Dampen Magic / Harness Magika Tracker
                HealerHelper.setArrowColor(arrowNumber, "smallred")
            elseif (skillId == 40232) and HealerHelper.ShouldCastGroupPurge() then -- Efficient Purge
                HealerHelper.setArrowColor(arrowNumber, "smallred")
            elseif (skillId == 86054) and HealerHelper.ShouldCastSelfishPurge() then -- Blue Betty
                HealerHelper.setArrowColor(arrowNumber, "smallred")

            elseif HealerHelper.ShouldCastSkillForOlorime(skillId, bar)  then -- Olorime Skills
                HealerHelper.setArrowColor(arrowNumber, "smallgreen")

            elseif HealerHelper.ShouldCastSkillForMinorSorceryBrutality(skillId)  then -- Minor Sorcery / Brutality Skills
                HealerHelper.setArrowColor(arrowNumber, "smallgreen")

            elseif HealerHelper.ShouldCastSkillForMinorProphecySavagery(skillId)  then -- Minor Prophecy / Savagery Skills
                HealerHelper.setArrowColor(arrowNumber, "smallgreen")

            elseif HealerHelper.ShouldCastSkillForPowerfulAssault(skillId, bar)  then -- Powerful Assault Skills
                HealerHelper.setArrowColor(arrowNumber, "smallgreen")

            elseif HealerHelper.ShouldCastSkillForMinorVulnerability(skillId)  then -- Minor Vulnerability Skills
                HealerHelper.setArrowColor(arrowNumber, "smallyellow")




            elseif (skillId == 86054) and HealerHelper.PillagersAndPearlsRecommendBlockingMagRegen() then -- Blue Betty
                HealerHelper.setArrowColor(arrowNumber, "") -- display nothing if recommend blocking blue betty
            elseif (skillId == 36935) and HealerHelper.PillagersAndPearlsRecommendBlockingMagRegen() then -- Siphoning Attacks
                HealerHelper.setArrowColor(arrowNumber, "") -- display nothing if recommend blocking Siphoning Attacks
            elseif (skillId == 22240) and HealerHelper.PillagersAndPearlsRecommendBlockingMagRegen() then -- Channeled Focus
                HealerHelper.setArrowColor(arrowNumber, "") -- display nothing if recommend blocking Channeled Focus


            elseif HealerHelper.doSkillNeedToBeCastBasedOnCooldown(skillSlot) then
                HealerHelper.setArrowColor(arrowNumber, "hexyellow")
            else
                HealerHelper.setArrowColor(arrowNumber, "")

            end



        end
    end

    if not (locatedSkillSlot) then -- no recommended skill
        HealerHelper.currentRecommendedSkillSlot = 0
    end

    local allowFrontBarUlt = true
    local allowBackBarUlt = true
    -- do we have an ult set on, in which case we will restrict the ults recommended
    if HealerHelper.getGetSetBars("Master Architect")>0 or HealerHelper.getGetSetBars("Pillager's")>0 then
        if HealerHelper.getGetSetBars("Master Architect") == 1 or HealerHelper.getGetSetBars("Pillager's")==1 then
            allowBackBarUlt=false
        end
        if HealerHelper.getGetSetBars("Master Architect") == 2 or HealerHelper.getGetSetBars("Pillager's")==2 then
            allowFrontBarUlt=false
        end
    end

    if allowBackBarUlt == false and allowFrontBarUlt == false then
        allowFrontBarUlt = true
        allowBackBarUlt = true
        HealerHelper.setMessage("Split_Ultisets", true)
    else
        HealerHelper.setMessage("Split_Ultisets", false)
    end



    -- check ultimate
    local skillId = HealerHelper.Skills[6]
    local skillIdBackBar = HealerHelper.Skills[12]
    local ultiPower = GetUnitPower("player", POWERTYPE_ULTIMATE)

    local skillProperty = HealerHelper.skillProperties[skillId]
    local skillPropertyBackBar = HealerHelper.skillProperties[skillIdBackBar]
    if not (skillProperty == nil) then
        if ultiPower>=skillProperty[5]  and allowFrontBarUlt then -- required ultimate
            if HealerHelper.PillagersAtSpecifiedUltimate() and (HealerHelper.getGetSetBars("Pillager's")==1 or HealerHelper.getGetSetBars("Pillager's")==3) then
                HealerHelper.setArrowColor(6, "smallgreen")
            else
                HealerHelper.setArrowColor(6, "hexyellow")
            end

        else
            HealerHelper.setArrowColor(6, "")
        end
    else
        HealerHelper.setArrowColor(6, "")
    end


    if not (skillPropertyBackBar == nil) then
        if ultiPower>=skillPropertyBackBar[5] and allowBackBarUlt then -- required ultimate

            if HealerHelper.PillagersAtSpecifiedUltimate() and (HealerHelper.getGetSetBars("Pillager's")==2 or HealerHelper.getGetSetBars("Pillager's")==3) then
                HealerHelper.setArrowColor(13, "smallgreen")
            else
                HealerHelper.setArrowColor(13, "hexyellow")
            end

        else
            HealerHelper.setArrowColor(13, "")
        end
    else
        HealerHelper.setArrowColor(13, "")
    end

    -- check for RoJo
    local needHeavy= false
    if HealerHelper.ShouldProcRoaringOpportunist() or HealerHelper.ShouldProcArchdruid() then
        needHeavy = true
    end

    local needLight = false
    if HealerHelper.requireUltimateGeneration(1) then
        needLight = true
    end

    if (needHeavy and HealerHelper.savedVars.displayHeavyAttack and HealerHelper.inCombat and (IsUnitDead("player") == false) and IsReticleHidden()==false) or HealerHelper.manuallyShowUi then
        --HealerHelperRoFrameHA:SetHidden(false)
        HealerHelperRoFrameHA:SetText("HA")
        HealerHelperRoFrameHA:SetFont (string.format('%s|%d|%s', '$(CHAT_FONT)', HealerHelper.savedVars.fontSizeHeavyAttack, 'soft-shadow-thick'))


        HealerHelperRoFrame:SetHidden(false)
        --d("Show RO A")
    elseif (needLight and HealerHelper.savedVars.displayLightAttackUltigen and HealerHelper.inCombat and (IsUnitDead("player") == false) and IsReticleHidden()==false) then
        HealerHelperRoFrameHA:SetFont (string.format('%s|%d|%s', '$(CHAT_FONT)', HealerHelper.savedVars.fontSizeLightAttackUltigen, 'soft-shadow-thick'))
        HealerHelperRoFrameHA:SetText("LA")
        HealerHelperRoFrame:SetHidden(false)
    else
        --HealerHelperRoFrameHA:SetHidden(true)
        HealerHelperRoFrame:SetHidden(true)
        --d("Hide RO A")
    end
end





function HealerHelper.skillSuggesterUpdateTimer()
    if HealerHelper.manuallyShowUi then
        HealerHelperRoFrame:SetHidden(false) -- HA Frame
        --d("Show RO")

        HealerHelper.setArrowColor(1, "smallgreen")
        HealerHelper.setArrowColor(2, "smallgreen")
        HealerHelper.setArrowColor(3, "smallgreen")
        HealerHelper.setArrowColor(4, "smallgreen")
        HealerHelper.setArrowColor(5, "smallgreen")
        HealerHelper.setArrowColor(6, "smallgreen")
        HealerHelper.setArrowColor(7, "")
        HealerHelper.setArrowColor(8, "smallgreen")
        HealerHelper.setArrowColor(9, "smallgreen")
        HealerHelper.setArrowColor(10, "smallgreen")
        HealerHelper.setArrowColor(11, "smallgreen")
        HealerHelper.setArrowColor(12, "smallgreen")
        HealerHelper.setArrowColor(13, "smallgreen")

        if HealerHelper.HudCanBeDisplayed and HealerHelper.savedVars.enableHud then
            HealerHelperFrame:SetHidden(false)
        end

        HealerHelper.doMessageUI()
    else

        if HealerHelper.inCombat and (IsUnitDead("player") == false) and IsReticleHidden()==false then
            HealerHelper.doSkillSelectionTasks()

            HealerHelper.setArrowColor(7, "") -- remove the message flag
            if HealerHelper.HudCanBeDisplayed and HealerHelper.savedVars.enableHud then
                HealerHelperFrame:SetHidden(false)
            end
            --HealerHelperRoFrame:SetHidden(false)

            HealerHelper.doMessageUI()
        else
            HealerHelper.currentRecommendedSkillSlot = 0
            HealerHelperFrame:SetHidden(true) -- show GUI
            HealerHelperRoFrame:SetHidden(true)
            HealerHelperCombatMessageFrame:SetHidden(true)
            HealerHelperGearMessageFrame:SetHidden(true)
            --d("Hide RO A")
            --HealerHelperRoFrameHA:SetHidden(true)
        end

    end

end



function HealerHelper.activateSkillSuggester()
    --d("active skill suggester")
    HealerHelper.skillSuggesterActive = true
    HealerHelper.skillSuggesterUpdateTimer()
    EVENT_MANAGER:RegisterForUpdate(HealerHelper.name.."SkillSuggester", 100, function(gameTimeMs) HealerHelper.skillSuggesterUpdateTimer() end)

end


function HealerHelper.deactivateSkillSuggester()

    EVENT_MANAGER:UnregisterForUpdate(HealerHelper.name.."SkillSuggester")

    HealerHelper.skillSuggesterActive = false
end
