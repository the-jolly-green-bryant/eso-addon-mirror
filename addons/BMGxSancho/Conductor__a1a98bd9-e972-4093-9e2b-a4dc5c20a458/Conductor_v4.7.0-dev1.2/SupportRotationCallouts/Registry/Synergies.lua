local R = Conductor.Registry

-- Synergies are modeled independently from their casting skills because the
-- provider and activator are different players. This registry captures the
-- organized-PvE result Conductor may coordinate or validate.
local synergies = {
    {"SYNERGY_COMBUSTION", "Combustion", "Necrotic Orb", {"RESOURCE_RESTORE"}, "SUSTAIN"},
    {"SYNERGY_HEALING_COMBUSTION", "Healing Combustion", "Energy Orb", {"RESOURCE_RESTORE"}, "SUSTAIN"},
    {"SYNERGY_BLOOD_FEAST", "Blood Feast", "Blood Altar", {"RESOURCE_RESTORE"}, "HEALING"},
    {"SYNERGY_HARVEST", "Harvest", "Budding Seeds", {"RESOURCE_RESTORE"}, "HEALING"},
    {"SYNERGY_CONDUIT", "Conduit", "Lightning Splash", {"SYNERGY_PROVIDER"}, "DAMAGE"},
    {"SYNERGY_GRAVITY_CRUSH", "Gravity Crush", "Nova", {"SYNERGY_PROVIDER"}, "DAMAGE"},
    {"SYNERGY_SHACKLE", "Shackle", "Bone Shield", {"GROUP_SHIELDING"}, "DEFENSE"},
    {"SYNERGY_IGNITE", "Ignite", "Inner Fire", {"SYNERGY_PROVIDER"}, "DAMAGE"},
    {"SYNERGY_RADIATE", "Radiate", "Trapping Webs", {"SYNERGY_PROVIDER"}, "DAMAGE"},
    {"SYNERGY_PURIFY", "Purify", "Cleansing Ritual", {"CLEANSE"}, "CLEANSE"},
    {"SYNERGY_HIDDEN_REFRESH", "Hidden Refresh", "Consuming Darkness", {"RESOURCE_RESTORE"}, "SUSTAIN"},
    {"SYNERGY_BONE_WALL", "Bone Wall", "Bone Surge", {"GROUP_SHIELDING"}, "DEFENSE"},
}

for _, entry in ipairs(synergies) do
    R:Register("SYNERGIES", entry[1], {
        name = entry[2], sourceName = entry[3], provides = entry[4],
        classification = entry[5], providerType = "SYNERGY",
        requiresActivator = true, needsIdValidation = true,
        lastVerifiedPatch = 101050,
        tags = {"PVE", "SYNERGY", entry[5]},
    })
end
