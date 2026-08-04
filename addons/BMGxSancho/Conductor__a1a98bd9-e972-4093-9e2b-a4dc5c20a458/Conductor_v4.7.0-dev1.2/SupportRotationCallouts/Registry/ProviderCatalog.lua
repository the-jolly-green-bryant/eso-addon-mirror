local R = Conductor.Registry

local collections = {
    {"SKILLS","SKILL"},
    {"ULTIMATES","ULTIMATE"},
    {"GEAR","GEAR"},
    {"MONSTER_SETS","MONSTER_SET"},
    {"ENCHANTMENTS","ENCHANTMENT"},
    {"MASTERIES","CLASS_MASTERY"},
    {"SCRIBED_ABILITIES","SCRIBED_ABILITY"},
    {"CHAMPION_POINTS","CHAMPION_POINT"},
    {"PASSIVES","PASSIVE"},
    {"SYNERGIES","SYNERGY"},
}

for _, source in ipairs(collections) do
    for _, entry in ipairs(R:GetAll(source[1], true)) do
        if not R:Get("PROVIDERS", entry.key) then
            R:Register("PROVIDERS", entry.key, {
                name = entry.name,
                providerType = source[2],
                sourceRegistry = source[1],
                sourceKey = entry.key,
                provides = entry.provides or {},
                classification = entry.classification or "VALID",
                needsIdValidation = entry.needsIdValidation,
                status = entry.status,
                introducedPatch = entry.introducedPatch,
                lastVerifiedPatch = entry.lastVerifiedPatch,
                instructions = entry.instructions or "Detected through the Conductor capability registry.",
            })
        end
    end
end
