HealerHelper.skillBlockingDatabase = {
    [40478] =  {false, "Inner Light"},
    [40195] =  {false, "Camo Hunter"},
    [61489] =  {false, "Revealing Flare"}, -- TODO: add 2 morphs

    [38573] =  {false, "Barrier"},
    [40237] =  {false, "Reviving Barrier"},
    [40239] =  {false, "Replenishing Barrier"},

    [40161] =  {false, "Flawless Dawnbreaker"},
    [103564] = {false, "Temporal Guard"},

    [61927] =  {false, "Relentless Focus"},
}

function HealerHelper.updateSkillBlocking()
    HealerHelper.skillBlockingDatabase[40478][1]=HealerHelper.savedVars.blockCastingInnerLight
    HealerHelper.skillBlockingDatabase[40195][1]=HealerHelper.savedVars.blockCastingCamoHunter
    HealerHelper.skillBlockingDatabase[61489][1]=HealerHelper.savedVars.blockCastingRevealingFlare
    HealerHelper.skillBlockingDatabase[38573][1]=HealerHelper.savedVars.blockCastingBarrier
    HealerHelper.skillBlockingDatabase[40237][1]=HealerHelper.savedVars.blockCastingBarrier
    HealerHelper.skillBlockingDatabase[40239][1]=HealerHelper.savedVars.blockCastingBarrier
    HealerHelper.skillBlockingDatabase[40161][1]=HealerHelper.savedVars.blockCastingFlawlessDawnbreaker
    HealerHelper.skillBlockingDatabase[103564][1]=HealerHelper.savedVars.blockCastingTemporalGuard
    HealerHelper.skillBlockingDatabase[61927][1]=HealerHelper.savedVars.blockCastingRelentlessFocus


    if HealerHelper.SkillBlockingEnable then --and HealerHelper.isModuleOn(HealerHelper.MODULE_SKILL_BLOCKING) then

        for k,v in pairs(HealerHelper.skillBlockingDatabase) do
            LibSkillBlocker.UnregisterSkillBlock(HealerHelper.name, k)
        end

        for k,v in pairs(HealerHelper.skillBlockingDatabase) do
            if v[1]==true then
                LibSkillBlocker.RegisterSkillBlock(HealerHelper.name, k)
            end
        end
    end
end

HealerHelper.SkillBlockingEnable = false

function HealerHelper.InitialiseSkillBlocking()
    if LibSkillBlocker == nil then
        return false
    end

    if HealerHelper.SkillBlockingEnable == false then
        HealerHelper.SkillBlockingEnable = true
    end
end

function HealerHelper.DeinitialiseSkillBlocking()
    if HealerHelper.SkillBlockingEnable == true then
        for k,v in pairs(HealerHelper.skillBlockingDatabase) do
            LibSkillBlocker.UnregisterSkillBlock(HealerHelper.name, k)
        end
        HealerHelper.SkillBlockingEnable = false
    end
end