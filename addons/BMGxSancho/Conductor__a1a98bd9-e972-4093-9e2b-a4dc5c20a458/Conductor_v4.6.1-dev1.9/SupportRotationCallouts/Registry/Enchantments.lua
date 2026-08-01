local R = Conductor.Registry
local entries = {
    {"CRUSHER_ENCHANTMENT","Crusher Enchantment",{"CRUSHER","RESISTANCE_REDUCTION"}},
    {"WEAKENING_ENCHANTMENT","Weakening Enchantment",{"MINOR_COWARDICE"}},
    {"ABSORB_STAMINA_ENCHANTMENT","Absorb Stamina Enchantment",{"RESOURCE_RESTORE"}},
    {"ABSORB_MAGICKA_ENCHANTMENT","Absorb Magicka Enchantment",{"RESOURCE_RESTORE"}},
    {"ABSORB_HEALTH_ENCHANTMENT","Absorb Health Enchantment",{}},
    {"FLAME_ENCHANTMENT","Flame Enchantment",{"BURNING"}},
    {"FROST_ENCHANTMENT","Frost Enchantment",{"CHILLED","MINOR_BRITTLE"}},
    {"SHOCK_ENCHANTMENT","Shock Enchantment",{"CONCUSSION","OFF_BALANCE"}},
    {"POISON_ENCHANTMENT","Poison Enchantment",{"POISONED"}},
    {"DISEASE_ENCHANTMENT","Disease Enchantment",{"DISEASED"}},
}
for _, entry in ipairs(entries) do R:Register("ENCHANTMENTS",entry[1],{name=entry[2],provides=entry[3],enchantIds={},needsIdValidation=true}) end
