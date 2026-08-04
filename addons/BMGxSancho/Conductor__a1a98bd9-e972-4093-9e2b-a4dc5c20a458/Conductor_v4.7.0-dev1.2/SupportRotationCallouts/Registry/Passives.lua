local R = Conductor.Registry

-- Organized-PvE passives that materially affect raid capability, sustain,
-- survivability, ultimate economy, or group support. Ability IDs are left
-- validation-gated where the live API/source data has not yet been confirmed.
local passives = {
    {"PASSIVE_MOUNTAIN_BLESSING", "Mountain's Blessing", "Dragonknight", {"MINOR_BRUTALITY"}, "GROUP_BUFF"},
    {"PASSIVE_HEMORRHAGE", "Hemorrhage", "Nightblade", {"MINOR_SAVAGERY"}, "GROUP_BUFF"},
    {"PASSIVE_EXPLOITATION", "Exploitation", "Sorcerer", {"MINOR_PROPHECY"}, "GROUP_BUFF"},
    {"PASSIVE_ILLUMINATE", "Illuminate", "Templar", {"MINOR_SORCERY"}, "GROUP_BUFF"},
    {"PASSIVE_GLACIAL_PRESENCE", "Glacial Presence", "Warden", {"MINOR_BRITTLE"}, "STATUS_SUPPORT"},
    {"PASSIVE_CORPSE_CONSUMPTION", "Corpse Consumption", "Necromancer", {"ULTIMATE_RESTORE"}, "ULTIMATE_ECONOMY"},
    {"PASSIVE_TRANSFER", "Transfer", "Necromancer", {"ULTIMATE_RESTORE"}, "ULTIMATE_ECONOMY"},
    {"PASSIVE_COMBAT_MEDIC", "Combat Medic", "Alliance War", {}, "GROUP_DEFENSE"},
    {"PASSIVE_UNDAUNTED_COMMAND", "Undaunted Command", "Undaunted", {"RESOURCE_RESTORE"}, "SYNERGY_SUSTAIN"},
    {"PASSIVE_UNDAUNTED_METTLE", "Undaunted Mettle", "Undaunted", {}, "PERSONAL_STATS"},
}

for _, entry in ipairs(passives) do
    R:Register("PASSIVES", entry[1], {
        name = entry[2], classOrLine = entry[3], provides = entry[4],
        classification = entry[5], providerType = "PASSIVE",
        coordinated = entry[5] == "GROUP_BUFF" or entry[5] == "STATUS_SUPPORT",
        needsIdValidation = true, lastVerifiedPatch = 101050,
        tags = {"PVE", "PASSIVE", entry[5]},
    })
end
