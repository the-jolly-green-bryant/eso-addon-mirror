local BB = BetterBuffs
BB.Registry = BB.Registry or {}
local Registry = BB.Registry

local function I(name)
    return "EsoUI/Art/Icons/" .. name .. ".dds"
end

local function E(key, name, effectType, timer, coverage, defaultTracked, aliases, options)
    options = options or {}
    return {
        key=key, name=name, effectType=effectType,
        timer=timer == true, coverage=coverage == true,
        defaultTracked=defaultTracked == true,
        aliases=aliases or {}, abilityIds=options.abilityIds or {},
        combatEventIds=options.combatEventIds or {},
        showMissingPlayers=options.showMissingPlayers == true,
        recipientDisplay=options.recipientDisplay or (options.showMissingPlayers and "MISSING" or "NONE"),
        missingWindow=tonumber(options.missingWindow) or 0,
        coverageCap=tonumber(options.coverageCap),
        coveragePerProvider=tonumber(options.coveragePerProvider),
        observedProviderCapacity=options.observedProviderCapacity == true,
        activeUntilFade=options.activeUntilFade == true,
        targetType=options.targetType or (effectType == "BUFF" and "PLAYER" or "HOSTILE"),
        displayPriority=tonumber(options.displayPriority) or 100,
        icon=options.icon,
        iconAbilityId=tonumber(options.iconAbilityId),
        showDuration=options.showDuration ~= false and timer == true,
        showCoverage=options.showCoverage ~= false and coverage == true,
        showStacks=options.showStacks == true,
        showReady=options.showReady == true,
        providerCooldown=tonumber(options.providerCooldown),
        cooldownStartsEveryApplication=options.cooldownStartsEveryApplication == true,
        providerCooldownOverridesActive=options.providerCooldownOverridesActive == true,
        preserveProviderCooldownOnEncounterEnd=options.preserveProviderCooldownOnEncounterEnd == true,
        singleActiveTarget=options.singleActiveTarget == true,
        recipientCooldown=tonumber(options.recipientCooldown),
        intelligenceMode=options.intelligenceMode,
        releaseTriggerIds=options.releaseTriggerIds or {},
        targetCooldown=tonumber(options.targetCooldown),
        targetCooldownOnFade=options.targetCooldownOnFade == true,
        bossPriority=options.bossPriority ~= false and effectType == "DEBUFF",
        readyRequiresObservedProvider=options.readyRequiresObservedProvider == true,
        preserveRecipientCooldownOnEncounterEnd=options.preserveRecipientCooldownOnEncounterEnd == true,
        compositeChildren=options.compositeChildren,
        lifecycle=options.lifecycle or (
            options.intelligenceMode == "RECIPIENT_COOLDOWN" and "RECIPIENT_COOLDOWN" or
            (options.targetCooldown and "TARGET_ACTIVE_COOLDOWN" or
            (options.providerCooldown and effectType == "DEBUFF" and "TARGET_PROVIDER_COOLDOWN" or
            (options.compositeChildren and "COMPOSITE_TARGET" or
            (options.showStacks and "STACK_EFFECT" or
            (effectType == "DEBUFF" and "TARGET_TIMED" or
            (options.targetType == "SELF" and "SELF_EFFECT" or "BUFF_EFFECT"))))))),
    }
end

Registry.definitions = {
    E("MAJOR_FORCE","Major Force","BUFF",true,true,true,nil,{displayPriority=10,icon=I("ability_buff_major_force")}),
    E("MINOR_FORCE","Minor Force","BUFF",true,true,false,nil,{displayPriority=70,icon=I("ability_buff_minor_force")}),
    E("MAJOR_SLAYER","Major Slayer","BUFF",true,true,true,nil,{abilityIds={93109},showMissingPlayers=true,missingWindow=5,displayPriority=5,iconAbilityId=93109}),
    E("MINOR_SLAYER","Minor Slayer","BUFF",false,true,false,nil,{displayPriority=75,icon=I("ability_buff_minor_slayer")}),
    E("MAJOR_COURAGE","Major Courage","BUFF",true,true,true,nil,{displayPriority=15,icon=I("ability_buff_major_courage")}),
    E("MINOR_COURAGE","Minor Courage","BUFF",false,true,true,nil,{displayPriority=25,icon=I("ability_buff_minor_courage")}),
    E("AURA_OF_PRIDE","Aura of Pride","BUFF",false,true,true,{"Spaulder of Ruin"},{coveragePerProvider=6,observedProviderCapacity=true,targetType="GROUP",activeUntilFade=true,recipientDisplay="ACTIVE",displayPriority=20,icon=I("ability_mage_065")}),
    E("MAJOR_MENDING","Major Mending","BUFF",true,false,true,nil,{targetType="SELF",displayPriority=45,icon=I("ability_buff_major_mending")}),
    E("MAJOR_RESOLVE","Major Resolve","BUFF",false,true,true,nil,{displayPriority=55,icon=I("ability_buff_major_resolve")}),
    E("MINOR_RESOLVE","Minor Resolve","BUFF",false,true,true,nil,{displayPriority=40,icon=I("ability_buff_minor_resolve")}),
    E("MAJOR_BERSERK","Major Berserk","BUFF",true,true,false,nil,{displayPriority=60,icon=I("ability_buff_major_berserk")}),
    E("MINOR_BERSERK","Minor Berserk","BUFF",false,true,true,nil,{displayPriority=35,icon=I("ability_buff_minor_berserk")}),
    E("MINOR_BRUTALITY","Minor Brutality","BUFF",false,true,false,nil,{icon=I("ability_buff_minor_brutality")}),
    E("MINOR_SORCERY","Minor Sorcery","BUFF",false,true,false,nil,{icon=I("ability_buff_minor_sorcery")}),
    E("MINOR_PROPHECY","Minor Prophecy","BUFF",false,true,false,nil,{icon=I("ability_buff_minor_prophecy")}),
    E("MINOR_SAVAGERY","Minor Savagery","BUFF",false,true,false,nil,{icon=I("ability_buff_minor_savagery")}),
    E("MAJOR_BRUTALITY","Major Brutality","BUFF",true,true,false,nil,{icon=I("ability_buff_major_brutality")}),
    E("MAJOR_SORCERY","Major Sorcery","BUFF",true,true,false,nil,{icon=I("ability_buff_major_sorcery")}),
    E("MAJOR_PROPHECY","Major Prophecy","BUFF",true,true,false,nil,{icon=I("ability_buff_major_prophecy")}),
    E("MAJOR_SAVAGERY","Major Savagery","BUFF",true,true,false,nil,{icon=I("ability_buff_major_savagery")}),
    E("MAJOR_EXPEDITION","Major Expedition","BUFF",true,true,false,nil,{icon=I("ability_buff_major_expedition")}),
    E("MAJOR_EVASION","Major Evasion","BUFF",true,true,false,nil,{displayPriority=72,icon=I("ability_buff_major_evasion")}),
    E("MINOR_EXPEDITION","Minor Expedition","BUFF",true,true,false,nil,{icon=I("ability_buff_minor_expedition")}),
    E("MAJOR_PROTECTION","Major Protection","BUFF",true,true,false,nil,{icon=I("ability_buff_major_protection")}),
    E("MINOR_PROTECTION","Minor Protection","BUFF",true,true,false,nil,{icon=I("ability_buff_minor_protection")}),
    E("MAJOR_HEROISM","Major Heroism","BUFF",true,true,false,nil,{icon=I("ability_buff_major_heroism")}),
    E("MINOR_HEROISM","Minor Heroism","BUFF",true,true,false,nil,{icon=I("ability_buff_minor_heroism")}),
    E("MINOR_INTELLECT","Minor Intellect","BUFF",false,true,false,nil,{icon=I("ability_buff_minor_intellect")}),
    E("MINOR_ENDURANCE","Minor Endurance","BUFF",false,true,false,nil,{icon=I("ability_buff_minor_endurance")}),
    E("MINOR_FORTITUDE","Minor Fortitude","BUFF",false,true,false,nil,{icon=I("ability_buff_minor_fortitude")}),
    E("MINOR_VITALITY","Minor Vitality","BUFF",false,true,false,nil,{icon=I("ability_buff_minor_vitality")}),
    E("MAJOR_VITALITY","Major Vitality","BUFF",true,true,false,nil,{icon=I("ability_buff_major_vitality")}),
    E("POWERFUL_ASSAULT","Powerful Assault","BUFF",true,true,true,nil,{showMissingPlayers=true,missingWindow=5,displayPriority=18,icon=I("ability_healer_019")}),

    -- Pillager recipient eligibility is a real group-member cooldown state. 172056
    -- is consumed through EVENT_COMBAT_EVENT and does not create a second tracker.
    E("PILLAGERS_PROFIT","Pillager's Profit","BUFF",false,true,true,{"Pillagers Profit"},{combatEventIds={172056},recipientCooldown=45,intelligenceMode="RECIPIENT_COOLDOWN",showReady=true,readyRequiresObservedProvider=true,preserveRecipientCooldownOnEncounterEnd=true,lifecycle="RECIPIENT_COOLDOWN",displayPriority=8,iconAbilityId=172055}),

    -- Mythic effect intelligence. Entries without a verified numeric ID resolve by
    -- the exact ESO effect name instead of inventing an ID. This keeps the runtime
    -- event-driven and lets the live icon reported by ESO remain authoritative.
    E("HARPOONERS_WADING_KILT","Harpooner's Wading Kilt","BUFF",true,false,false,{"Hunter's Focus"},{targetType="SELF",showStacks=true,displayPriority=76,activeUntilFade=true}),
    E("DEATH_DEALERS_FETE","Death Dealer's Fete","BUFF",false,false,false,{"Escalating Fete"},{targetType="SELF",showStacks=true,displayPriority=77,activeUntilFade=true,icon=I("antiquities_u30_mythic_ring02")}),
    E("BELHARZAS_BAND","Belharza's Band","BUFF",true,false,false,{"Belharza's Temper"},{targetType="SELF",showStacks=true,displayPriority=78}),
    E("DOV_RHA_SABATONS","Dov-Rha Sabatons","BUFF",true,false,false,{"Draconic Scales"},{targetType="SELF",showStacks=true,displayPriority=79,activeUntilFade=true}),
    E("THRASSIAN_STRANGLERS","Thrassian Stranglers","BUFF",false,false,false,{"Sload's Call"},{abilityIds={136123},targetType="SELF",showStacks=true,displayPriority=80,activeUntilFade=true,icon=I("gear_thrassianstranglers_a")}),
    E("ROURKEN_STEAMGUARDS","Rourken Steamguards","BUFF",true,false,false,{"Steam Guardian"},{targetType="SELF",displayPriority=81}),

    -- Huntsman's Warmask: 252048 is the verified Mark of Hircine target effect.
    -- The player-side 252050 state is intentionally not duplicated as another tile.
    E("HUNTSMANS_WARMASK","Huntsman's Warmask","DEBUFF",true,false,false,{"Mark of Hircine"},{abilityIds={252048},targetType="RETICLE_HOSTILE",providerCooldown=10,cooldownStartsEveryApplication=true,providerCooldownOverridesActive=true,preserveProviderCooldownOnEncounterEnd=true,singleActiveTarget=true,showReady=true,readyRequiresObservedProvider=true,lifecycle="TARGET_PROVIDER_COOLDOWN",displayPriority=4,iconAbilityId=252048}),

    E("MAJOR_VULNERABILITY","Major Vulnerability","DEBUFF",true,false,true,nil,{abilityIds={106754},displayPriority=5,icon=I("ability_debuff_major_vulnerability")}),
    E("MINOR_VULNERABILITY","Minor Vulnerability","DEBUFF",true,false,true,nil,{displayPriority=55,icon=I("ability_debuff_minor_vulnerability")}),
    E("MAJOR_BRITTLE","Major Brittle","DEBUFF",true,false,true,nil,{displayPriority=12,icon=I("ability_debuff_major_brittle")}),
    E("MINOR_BRITTLE","Minor Brittle","DEBUFF",true,false,true,nil,{displayPriority=60,icon=I("ability_debuff_minor_brittle")}),
    E("MAJOR_BREACH","Major Breach","DEBUFF",true,false,true,nil,{displayPriority=20,icon=I("ability_debuff_major_breach")}),
    E("MINOR_BREACH","Minor Breach","DEBUFF",true,false,true,nil,{displayPriority=25,icon=I("ability_debuff_minor_breach")}),
    E("CRUSHER","Crusher","DEBUFF",true,false,true,{"Crusher Enchantment"},{displayPriority=10,icon=I("ability_armor_001")}),
    E("MAJOR_MAIM","Major Maim","DEBUFF",true,false,false,nil,{icon=I("ability_debuff_major_maim")}),
    E("MINOR_MAIM","Minor Maim","DEBUFF",true,false,false,nil,{icon=I("ability_debuff_minor_maim")}),
    E("MAJOR_COWARDICE","Major Cowardice","DEBUFF",true,false,false,nil,{icon=I("ability_debuff_major_cowardice")}),
    E("MINOR_COWARDICE","Minor Cowardice","DEBUFF",true,false,true,nil,{icon=I("ability_debuff_minor_cowardice")}),
    E("MAJOR_DEFILE","Major Defile","DEBUFF",true,false,false,nil,{icon=I("ability_debuff_major_defile")}),
    E("MINOR_DEFILE","Minor Defile","DEBUFF",true,false,false,nil,{icon=I("ability_debuff_minor_defile")}),
    E("MINOR_MAGICKASTEAL","Minor Magickasteal","DEBUFF",true,false,false,nil,{icon=I("ability_destructionstaff_011a")}),
    E("MINOR_LIFESTEAL","Minor Lifesteal","DEBUFF",true,false,false,nil,{icon=I("ability_undaunted_001")}),
    E("OFF_BALANCE","Off Balance","DEBUFF",true,false,true,nil,{targetCooldown=15,targetCooldownOnFade=true,lifecycle="TARGET_ACTIVE_COOLDOWN",displayPriority=30,icon=I("ability_debuff_offbalance")}),
    E("CHILLED","Chilled","DEBUFF",true,false,false,nil,{icon=I("ability_destructionstaff_002a")}),
    E("CONCUSSION","Concussion","DEBUFF",true,false,false,nil,{icon=I("ability_destructionstaff_011b")}),
    E("BURNING","Burning","DEBUFF",true,false,false,nil,{icon=I("ability_dragonknight_003_b")}),
    E("POISONED","Poisoned","DEBUFF",true,false,false,nil,{icon=I("ability_dragonknight_004_a")}),
    E("DISEASED","Diseased","DEBUFF",true,false,false,nil,{icon=I("ability_debuff_major_defile")}),
    E("ZEN_DAMAGE_TAKEN","Touch of Z'en","DEBUFF",true,false,false,{"Touch of Zen","Z'en's Redress"},{displayPriority=16,iconAbilityId=126597}),
    E("ALKOSH_RESISTANCE_REDUCTION","Roar of Alkosh","DEBUFF",true,false,true,{"Roar of Alkosh"},{targetType="HOSTILE_ENCOUNTER_UNIT",displayPriority=14,icon=I("gear_dromathra_medium_head_a")}),
    E("MORAG_TONG_AMPLIFICATION","Morag Tong","DEBUFF",true,false,false,{"The Morag Tong"},{icon=I("ability_armor_001")}),
    E("ELEMENTAL_CATALYST_AMPLIFICATION","Elemental Catalyst","DEBUFF",true,false,false,{"Flame Weakness","Frost Weakness","Shock Weakness"},{showStacks=true,lifecycle="COMPOSITE_TARGET",compositeChildren={ ["Flame Weakness"]="FLAME", ["Frost Weakness"]="FROST", ["Shock Weakness"]="SHOCK" },displayPriority=22,icon=I("ability_mage_065")}),
    E("MARTIAL_KNOWLEDGE_AMPLIFICATION","Martial Knowledge","DEBUFF",true,false,false,{"Way of Martial Knowledge"},{displayPriority=24,icon=I("ability_armor_001")}),
    E("HEMORRHAGING","Hemorrhaging","DEBUFF",true,false,false,nil,{icon=I("ability_dualwield_001_b")}),
    E("SUNDERED","Sundered","DEBUFF",true,false,false,nil,{icon=I("ability_debuff_minor_fracture")}),
    E("OVERCHARGED","Overcharged","DEBUFF",true,false,false,nil,{icon=I("ability_mage_065")}),
}

function Registry:Initialize()
    self.byKey, self.byName, self.byAbilityId, self.byCombatEventId, self.releaseByAbilityId, self.buffs, self.debuffs = {}, {}, {}, {}, {}, {}, {}
    for _, effect in ipairs(self.definitions) do
        self.byKey[effect.key] = effect
        self.byName[BB:NormalizeText(effect.name)] = effect
        for _, alias in ipairs(effect.aliases or {}) do self.byName[BB:NormalizeText(alias)] = effect end
        for _, abilityId in ipairs(effect.abilityIds or {}) do self.byAbilityId[tonumber(abilityId)] = effect end
        for _, abilityId in ipairs(effect.combatEventIds or {}) do self.byCombatEventId[tonumber(abilityId)] = effect end
        for _, abilityId in ipairs(effect.releaseTriggerIds or {}) do self.releaseByAbilityId[tonumber(abilityId)] = effect end
        if effect.compositeChildren then
            effect.compositeByName = {}
            for childName, childKey in pairs(effect.compositeChildren) do
                effect.compositeByName[BB:NormalizeText(childName)] = childKey
            end
        end
        local list = effect.effectType == "BUFF" and self.buffs or self.debuffs
        list[#list + 1] = effect
    end
    local function byName(a,b) return a.name < b.name end
    table.sort(self.buffs, byName)
    table.sort(self.debuffs, byName)
end

function Registry:Resolve(effectName, abilityId)
    abilityId = tonumber(abilityId)
    if abilityId and self.byAbilityId[abilityId] then return self.byAbilityId[abilityId] end
    return self.byName[BB:NormalizeText(effectName)]
end

function Registry:GetCompositeChild(definition, effectName)
    if not definition or not definition.compositeByName then return nil end
    return definition.compositeByName[BB:NormalizeText(effectName)]
end

function Registry:GetIcon(definition, observedIcon)
    if observedIcon and observedIcon ~= "" then return observedIcon end
    if definition.icon and definition.icon ~= "" then return definition.icon end
    if definition.iconAbilityId and GetAbilityIcon then
        local icon = GetAbilityIcon(definition.iconAbilityId)
        if icon and icon ~= "" then return icon end
    end
    return "EsoUI/Art/Inventory/inventory_tabIcon_consumables_up.dds"
end
