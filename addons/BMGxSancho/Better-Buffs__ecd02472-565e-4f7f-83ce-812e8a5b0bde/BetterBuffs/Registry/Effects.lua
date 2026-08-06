local BB = BetterBuffs
BB.Registry = BB.Registry or {}
local Registry = BB.Registry

local function E(key, name, effectType, timer, coverage, defaultTracked, aliases, options)
    options = options or {}
    return {
        key=key, name=name, effectType=effectType,
        timer=timer == true, coverage=coverage == true,
        defaultTracked=defaultTracked == true,
        aliases=aliases or {}, abilityIds=options.abilityIds or {},
        showMissingPlayers=options.showMissingPlayers == true,
        missingWindow=tonumber(options.missingWindow) or 0,
        coverageCap=tonumber(options.coverageCap),
        activeUntilFade=options.activeUntilFade == true,
        targetType=options.targetType or (effectType == "BUFF" and "PLAYER" or "HOSTILE"),
    }
end

Registry.definitions = {
    -- Buffs. Timer and coverage are independent, so an effect can display both.
    E("MAJOR_FORCE","Major Force","BUFF",true,true,true),
    E("MINOR_FORCE","Minor Force","BUFF",true,true,false),
    E("MAJOR_SLAYER","Major Slayer","BUFF",true,true,true,nil,{showMissingPlayers=true,missingWindow=5}),
    E("MINOR_SLAYER","Minor Slayer","BUFF",false,true,false),
    E("MAJOR_COURAGE","Major Courage","BUFF",true,true,true),
    E("MINOR_COURAGE","Minor Courage","BUFF",false,true,true),
    E("AURA_OF_PRIDE","Aura of Pride","BUFF",false,true,true,{"Spaulder of Ruin"},{coverageCap=6,targetType="GROUP",activeUntilFade=true}),
    E("MAJOR_MENDING","Major Mending","BUFF",true,false,true,nil,{targetType="SELF"}),
    E("MAJOR_RESOLVE","Major Resolve","BUFF",false,true,true),
    E("MINOR_RESOLVE","Minor Resolve","BUFF",false,true,true),
    E("MAJOR_BERSERK","Major Berserk","BUFF",true,true,false),
    E("MINOR_BERSERK","Minor Berserk","BUFF",false,true,true),
    E("MINOR_BRUTALITY","Minor Brutality","BUFF",false,true,false),
    E("MINOR_SORCERY","Minor Sorcery","BUFF",false,true,false),
    E("MINOR_PROPHECY","Minor Prophecy","BUFF",false,true,false),
    E("MINOR_SAVAGERY","Minor Savagery","BUFF",false,true,false),
    E("MAJOR_BRUTALITY","Major Brutality","BUFF",true,true,false),
    E("MAJOR_SORCERY","Major Sorcery","BUFF",true,true,false),
    E("MAJOR_PROPHECY","Major Prophecy","BUFF",true,true,false),
    E("MAJOR_SAVAGERY","Major Savagery","BUFF",true,true,false),
    E("MAJOR_EXPEDITION","Major Expedition","BUFF",true,true,false),
    E("MINOR_EXPEDITION","Minor Expedition","BUFF",true,true,false),
    E("MAJOR_PROTECTION","Major Protection","BUFF",true,true,false),
    E("MINOR_PROTECTION","Minor Protection","BUFF",true,true,false),
    E("MAJOR_HEROISM","Major Heroism","BUFF",true,true,false),
    E("MINOR_HEROISM","Minor Heroism","BUFF",true,true,false),
    E("MINOR_INTELLECT","Minor Intellect","BUFF",false,true,false),
    E("MINOR_ENDURANCE","Minor Endurance","BUFF",false,true,false),
    E("MINOR_FORTITUDE","Minor Fortitude","BUFF",false,true,false),
    E("MINOR_VITALITY","Minor Vitality","BUFF",false,true,false),
    E("MAJOR_VITALITY","Major Vitality","BUFF",true,true,false),
    E("POWERFUL_ASSAULT","Powerful Assault","BUFF",true,true,true,nil,{showMissingPlayers=true,missingWindow=5}),

    -- Debuffs are timed and stored per hostile target.
    E("MAJOR_VULNERABILITY","Major Vulnerability","DEBUFF",true,false,true),
    E("MINOR_VULNERABILITY","Minor Vulnerability","DEBUFF",true,false,true),
    E("MAJOR_BRITTLE","Major Brittle","DEBUFF",true,false,true),
    E("MINOR_BRITTLE","Minor Brittle","DEBUFF",true,false,true),
    E("MAJOR_BREACH","Major Breach","DEBUFF",true,false,true),
    E("MINOR_BREACH","Minor Breach","DEBUFF",true,false,true),
    E("CRUSHER","Crusher","DEBUFF",true,false,true,{"Crusher Enchantment"}),
    E("MAJOR_MAIM","Major Maim","DEBUFF",true,false,false),
    E("MINOR_MAIM","Minor Maim","DEBUFF",true,false,false),
    E("MAJOR_COWARDICE","Major Cowardice","DEBUFF",true,false,false),
    E("MINOR_COWARDICE","Minor Cowardice","DEBUFF",true,false,true),
    E("MAJOR_DEFILE","Major Defile","DEBUFF",true,false,false),
    E("MINOR_DEFILE","Minor Defile","DEBUFF",true,false,false),
    E("MINOR_MAGICKASTEAL","Minor Magickasteal","DEBUFF",true,false,false),
    E("MINOR_LIFESTEAL","Minor Lifesteal","DEBUFF",true,false,false),
    E("OFF_BALANCE","Off Balance","DEBUFF",true,false,true),
    E("CHILLED","Chilled","DEBUFF",true,false,false),
    E("CONCUSSION","Concussion","DEBUFF",true,false,false),
    E("BURNING","Burning","DEBUFF",true,false,false),
    E("POISONED","Poisoned","DEBUFF",true,false,false),
    E("DISEASED","Diseased","DEBUFF",true,false,false),
    E("ZEN_DAMAGE_TAKEN","Touch of Z'en","DEBUFF",true,false,false,{"Touch of Zen","Z'en's Redress"}),
    E("ALKOSH_RESISTANCE_REDUCTION","Roar of Alkosh","DEBUFF",true,false,true,{"Roar of Alkosh"},{targetType="HOSTILE_ENCOUNTER_UNIT"}),
    E("MORAG_TONG_AMPLIFICATION","Morag Tong","DEBUFF",true,false,false,{"The Morag Tong"}),
    E("ELEMENTAL_CATALYST_AMPLIFICATION","Elemental Catalyst","DEBUFF",true,false,false),
    E("MARTIAL_KNOWLEDGE_AMPLIFICATION","Martial Knowledge","DEBUFF",true,false,false,{"Way of Martial Knowledge"}),
    E("HEMORRHAGING","Hemorrhaging","DEBUFF",true,false,false),
    E("SUNDERED","Sundered","DEBUFF",true,false,false),
    E("OVERCHARGED","Overcharged","DEBUFF",true,false,false),
}

function Registry:Initialize()
    self.byKey, self.byName, self.byAbilityId, self.buffs, self.debuffs = {}, {}, {}, {}, {}
    for _, effect in ipairs(self.definitions) do
        self.byKey[effect.key] = effect
        self.byName[BB:NormalizeText(effect.name)] = effect
        for _, alias in ipairs(effect.aliases or {}) do self.byName[BB:NormalizeText(alias)] = effect end
        for _, abilityId in ipairs(effect.abilityIds or {}) do self.byAbilityId[tonumber(abilityId)] = effect end
        local list = effect.effectType == "BUFF" and self.buffs or self.debuffs
        list[#list + 1] = effect
    end
    table.sort(self.buffs, function(a,b) return a.name < b.name end)
    table.sort(self.debuffs, function(a,b) return a.name < b.name end)
end

function Registry:Resolve(effectName, abilityId)
    abilityId = tonumber(abilityId)
    if abilityId and self.byAbilityId[abilityId] then return self.byAbilityId[abilityId] end
    return self.byName[BB:NormalizeText(effectName)]
end
