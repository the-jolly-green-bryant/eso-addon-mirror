HealerHelper.incorrectMorphs = {

    [61503] = {true, "Vigor", "EchoingVigor_Morph"},
    [61507] = {true, "Resolving Vigor", "EchoingVigor_Morph"},

    [38563] = {true, "War Horn", "AggressiveWarhorn_Morph"},
    [40220] = {true, "Sturdy Horn", "AggressiveWarhorn_Morph"},

    [38571] = {true, "Purge", "EfficientPurge_Morph"},
    [40234] = {true, "Cleanse", "EfficientPurge_Morph"},

    [61511] = {true, "Guard", "Guard_Morph"},

    --[38573] = {true, "Barrier", "Barrier_Morph"},

    [40058] = {true, "Illustrious Healing", "HealingSprings_Morph"},
    [28385] = {true, "Grand Healing", "HealingSprings_Morph"},

    [28536] = {true, "Regeneration", "RadiatingRegeneration_Morph"},
    [40076] = {true, "Rapid Regeneration", "RadiatingRegeneration_Morph"},

    [37243] = {true, "Blessing of Protection", "CombatPrayer_Morph"},
    [40103] = {true, "Blessing Of Restoration", "CombatPrayer_Morph"},

    [37232] = {true, "Steadfast Ward", "SteadfastWard_Morph"},

    [61919] = {true, "Merciless Resolve", "RelentlessFocus_Morph"},

    [61902] = {true, "Grim Focus", "RelentlessFocus_Morph"},

    [185921] = {true, "Rune of Uncanny Adoration", "RuneColorlessPool_Morph"},
    [185918] = {true, "Rune of Eldritch Horror", "RuneColorlessPool_Morph"},


    [185918] = {true, "Arcanist's Domain", "Zena_Morph"},
    [185918] = {false, "Reconstructive Domain", "Zena_Morph"}, -- This morph is acceptable in some situations, no warnings

    [18342] = {true, "Teleport Strike", "LotusFan_Morph"},
    [25484] = {true, "Ambush", "LotusFan_Morph"},



}



function HealerHelper.adjustMorphs()
    -- adjust morph warnings for certain situational morphs
    HealerHelper.incorrectMorphs[40058][1]=HealerHelper.savedVars.skillMorphWarningIllustrusHealing
    HealerHelper.incorrectMorphs[61919][1]=HealerHelper.savedVars.skillMorphWarningMercilessResolve

end

function HealerHelper.checkForIncorrectMorphs()
    HealerHelper.adjustMorphs()

    for k, v in pairs(HealerHelper.incorrectMorphs) do
        HealerHelper.setMessage(v[3], false) -- reset all messages re: morphs to false
    end


    for i=1,12 do
        local abilitId = HealerHelper.Skills[i]
        local incorrectMorph = HealerHelper.incorrectMorphs[abilitId]
        if incorrectMorph ~= nil then
            if incorrectMorph[1]== true then
                if GetAbilityProgressionRankFromAbilityId(abilitId) == 4 or HealerHelper.savedVars.skillMorphWarningSupressedWhileLevelingSkill then
                    HealerHelper.setMessage(incorrectMorph[3], true) -- mark morph as incorrect
                end
            end
        end
    end
end