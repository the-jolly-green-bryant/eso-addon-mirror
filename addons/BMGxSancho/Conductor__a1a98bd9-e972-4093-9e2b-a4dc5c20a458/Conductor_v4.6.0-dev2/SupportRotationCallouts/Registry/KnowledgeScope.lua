local R = Conductor.Registry

local scopes = {
    {"SCOPE_ORGANIZED_PVE_EFFECTS", "Organized PvE Effects", "EFFECTS", "All raid-relevant buffs, debuffs, status effects, and utility outcomes tracked by Conductor."},
    {"SCOPE_RESPONSIBILITIES", "Raid Responsibilities", "RESPONSIBILITIES", "Every tracked effect has a stable responsibility object."},
    {"SCOPE_SUPPORT_GEAR", "Support Gear", "GEAR", "Commonly coordinated five-piece, trial, dungeon, arena, mythic, and support gear sources."},
    {"SCOPE_MONSTER_SETS", "Monster Sets", "MONSTER_SETS", "Monster sets with organized-PvE support, damage, sustain, or defensive relevance."},
    {"SCOPE_SKILLS", "Support Skills", "SKILLS", "Skills that provide coordinated effects, utility, positioning, sustain, or encounter support."},
    {"SCOPE_ULTIMATES", "Ultimates", "ULTIMATES", "Ultimates relevant to burn, defense, recovery, control, or group support."},
    {"SCOPE_PASSIVES", "Group Passives", "PASSIVES", "Passives that materially influence organized PvE group capability."},
    {"SCOPE_SYNERGIES", "Synergies", "SYNERGIES", "Synergies relevant to sustain, damage, cleansing, shielding, and coordinated activation."},
    {"SCOPE_SCRIBING", "Scribing", "SCRIBED_ABILITIES", "Compositional Scribing providers normalized into effects and responsibilities."},
    {"SCOPE_ENCOUNTERS", "Trial Encounters", "ENCOUNTERS", "Current 12-player trials, bosses, mechanics, and foundation metadata."},
}

for _, entry in ipairs(scopes) do
    R:Register("KNOWLEDGE_SCOPE", entry[1], {
        name = entry[2], collection = entry[3], description = entry[4],
        target = "PUBLIC_RELEASE", status = "ACTIVE", lastVerifiedPatch = 101050,
    })
end
