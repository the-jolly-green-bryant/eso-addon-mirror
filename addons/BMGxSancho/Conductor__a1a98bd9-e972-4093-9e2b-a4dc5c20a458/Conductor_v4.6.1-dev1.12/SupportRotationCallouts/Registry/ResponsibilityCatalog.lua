local R = Conductor.Registry

local familyByClassification = {
    BUFF = "GROUP_BUFF",
    DEBUFF = "ENEMY_DEBUFF",
    OTHER = "UTILITY",
}

local requiredEffects = {
    MAJOR_FORCE=true, MAJOR_SLAYER=true, MAJOR_VULNERABILITY=true,
    MAJOR_COURAGE=true, MAJOR_BREACH=true, MINOR_BREACH=true, CRUSHER=true,
}

local existingByEffect = {}
for _, responsibility in ipairs(R:GetAll("RESPONSIBILITIES", true)) do
    if responsibility.effectKey then existingByEffect[responsibility.effectKey] = true end
end

-- Every tracked effect is a first-class responsibility. Explicit definitions
-- remain authoritative; this catalog fills only gaps, preserving stable IDs.
for _, effect in ipairs(R:GetAll("EFFECTS", true)) do
    if not existingByEffect[effect.key] then
        R:Register("RESPONSIBILITIES", "RESP_" .. effect.key, {
            name = effect.name,
            effectKey = effect.key,
            classification = effect.classification or effect.effectType or "OTHER",
            family = familyByClassification[effect.classification or effect.effectType] or "UTILITY",
            requiredByDefault = requiredEffects[effect.key] == true,
            assignmentMode = "PLAYER_AND_PROVIDER",
            manualOverride = true,
            generatedFromEffect = true,
            lastVerifiedPatch = effect.lastVerifiedPatch or 101050,
            tags = {"AUTO_CATALOG", "PVE"},
        })
    end
end
