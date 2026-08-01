
HealerHelper.olorimeSkills = {
    -- Warden
    [85840]={true,"Budding Seeds"},
    [86169]={true,"Winter's Revenge"},

    -- Nightblade
    [36028]={true,"Refreshing Path"},
    [36049]={true,"Twisting Path"},
    --[]={true,"Path of Darkness"},
    -- TODO: other morph of twisting path


    -- Necro Healer
    [117805]={true,"Unnerving Boneyard"},
    [117850]={true,"Avid Boneyard"},
    --[]={true,"Boneyard"},
    -- TODO: unmorphed version

    -- Alliance War
    [33376]={true,"Caltrops"},
    [40242]={true,"Razor Caltrops"},
    [40255]={true,"Anti-Cavalry Caltrops"},

    -- Fighters Guild
    [40169]={true,"Ring of Preservation"},
    [35737]={true,"Circle of Protection"},
    [40181]={true,"Turn Evil"},

    -- Undaunted
    [41958]={true,"Overflowing Altar"},
    [39489]={true,"Blood Altar"},
    [41967]={true,"Sanguine Altar"},

    -- Resto taff
    [40060]={true,"Healing Springs"},
    [40058]={true,"Illustrious Healing"},
    [28385]={true,"Grand Healing"},

    -- Mages Guild
    [40465]={true,"Scalding Rune"},

    -- Destro staff
    [39053]={true,"Unstable Wall of Fire"},
    [39073]={true,"Unstable Wall of Storms"},
    [39067]={true,"Unstable Wall of Frost"},
    [39012]={true,"Blockade of Fire"},
    [39018]={true,"Blockade of Storms"},
    [39028]={true,"Blockade of Frost"},

    -- TODO: Add skills for other classes, and other morphs

}


HealerHelper.OlorimeTimerExpires = 0

function HealerHelper.OlorimeCombatEvent(_, _, _, _, _, _, sourceName, _, _, _, _, _, _, _, _, _, abilityID)
    HealerHelper.OlorimeTimerExpires  = GetGameTimeMilliseconds() + 10000	-- 10 seconds after olorime procs
    --d("Olorime proc")
end


HealerHelper.OlorimeTrackingEnable = false

function HealerHelper.InitialiseOlorimeTracking()
    if HealerHelper.OlorimeTrackingEnable == false then

		EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "OlorimeTracking_107141", EVENT_COMBAT_EVENT, HealerHelper.OlorimeCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(HealerHelper.name .. "OlorimeTracking_107141", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 107141,REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

		EVENT_MANAGER:RegisterForEvent(HealerHelper.name .. "OlorimeTracking_109084", EVENT_COMBAT_EVENT, HealerHelper.OlorimeCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(HealerHelper.name .. "OlorimeTracking_109084", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 109084, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        HealerHelper.OlorimeTrackingEnable = true
    end
end

function HealerHelper.DeinitialiseOlorimeTracking()
    if HealerHelper.OlorimeTrackingEnable == true then

		EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "OlorimeTracking_107141", EVENT_COMBAT_EVENT)
		EVENT_MANAGER:UnregisterForEvent(HealerHelper.name .. "OlorimeTracking_109084", EVENT_COMBAT_EVENT)

        HealerHelper.OlorimeTrackingEnable = false
    end
end


function HealerHelper.ShouldCastSkillForOlorime(skill, bar)

    if HealerHelper.savedVars.olorimeEnabled == false then return false end
    if skill == nil then return false end -- not a valid skill id
    if HealerHelper.checkIfGearSetEquipped("Olorime's") == false then return false end -- Olorime not on any bar
    if HealerHelper.olorimeSkills[skill] == nil then return false end -- not an olorime skill anyways
    if HealerHelper.olorimeSkills[skill][1] == false then return false end -- olorime skill is disabled
    if not (HealerHelper.getGetSetBars("Olorime's") == bar or HealerHelper.getGetSetBars("Olorime's") == 3) then return false end -- skill not on the correct bar
    if HealerHelper.OlorimeTimerExpires > GetGameTimeMilliseconds() then return false end -- Olorime on cooldown ignore

    return true
end


function HealerHelper.skillMissingToProcOlorime()
    if HealerHelper.savedVars.olorimeEnabled == false then return false end

    if HealerHelper.checkIfGearSetEquipped("Olorime's") then

        for i=1,12 do
            if i == 6 or i == 12 then
                -- skip ultimates
            else
                local skillSlot = i -- 1,2,3,4,5    7,8,9,10,11

                local bar = 1
                if i >= 7 then
                    bar = 2
                end

                local skillId = HealerHelper.Skills[skillSlot]
                if HealerHelper.getGetSetBars("Olorime's")==3 or HealerHelper.getGetSetBars("Olorime's")==bar then
                    if HealerHelper.olorimeSkills[skillId]~= nil then
                        if HealerHelper.olorimeSkills[skillId][1] == true then
                            return false -- found a skill to proc Olo
                        end
                    end
                end
            end
        end
        return true -- no skills to proc Olo
    else
        return false -- not wearing Olo anyways
    end

end