local R = Conductor.Registry

local responsibilities = {
    { "RESP_MAJOR_FORCE", "Major Force", "MAJOR_FORCE", "BUFF", "BURN_SUPPORT", true },
    { "RESP_MAJOR_SLAYER", "Major Slayer", "MAJOR_SLAYER", "BUFF", "BURN_SUPPORT", true },
    { "RESP_MAJOR_VULNERABILITY", "Major Vulnerability", "MAJOR_VULNERABILITY", "DEBUFF", "BURN_SUPPORT", true },
    { "RESP_MAJOR_COURAGE", "Major Courage", "MAJOR_COURAGE", "BUFF", "DAMAGE_SUPPORT", true },
    { "RESP_MINOR_COURAGE", "Minor Courage", "MINOR_COURAGE", "BUFF", "DAMAGE_SUPPORT", false },
    { "RESP_MAJOR_BRITTLE", "Major Brittle", "MAJOR_BRITTLE", "DEBUFF", "CRITICAL_SUPPORT", false },
    { "RESP_MINOR_BRITTLE", "Minor Brittle", "MINOR_BRITTLE", "DEBUFF", "CRITICAL_SUPPORT", false },
    { "RESP_MAJOR_BREACH", "Major Breach", "MAJOR_BREACH", "DEBUFF", "RESISTANCE_REDUCTION", true },
    { "RESP_MINOR_BREACH", "Minor Breach", "MINOR_BREACH", "DEBUFF", "RESISTANCE_REDUCTION", true },
    { "RESP_CRUSHER", "Crusher", "CRUSHER", "DEBUFF", "RESISTANCE_REDUCTION", true },
    { "RESP_MINOR_BERSERK", "Minor Berserk", "MINOR_BERSERK", "BUFF", "DAMAGE_SUPPORT", false },
    { "RESP_MINOR_RESOLVE", "Minor Resolve", "MINOR_RESOLVE", "BUFF", "DEFENSIVE_SUPPORT", false },
    { "RESP_MAJOR_RESOLVE", "Major Resolve", "MAJOR_RESOLVE", "BUFF", "DEFENSIVE_SUPPORT", false },
    { "RESP_MAJOR_MENDING", "Major Mending", "MAJOR_MENDING", "BUFF", "HEALING_SUPPORT", false },
    { "RESP_POWERFUL_ASSAULT", "Powerful Assault", "POWERFUL_ASSAULT", "BUFF", "DAMAGE_SUPPORT", false },
    { "RESP_ULTIMATE_RESTORE", "Ultimate Restore", "ULTIMATE_RESTORE", "OTHER", "RECOVERY", false },
    { "RESP_DEBUFF_EXTENSION", "Debuff Extension", "DEBUFF_EXTENSION", "OTHER", "EXTENSION", false },
    { "RESP_BUFF_EXTENSION", "Buff Extension", "BUFF_EXTENSION", "OTHER", "EXTENSION", false },
    { "RESP_RESOURCE_RESTORE", "Resource Restore", "RESOURCE_RESTORE", "OTHER", "SUSTAIN", false },
    { "RESP_GROUP_SHIELDING", "Group Shielding", "GROUP_SHIELDING", "OTHER", "DEFENSIVE_SUPPORT", false },
    { "RESP_PULL_STACK", "Pull and Stack", "PULL_STACK", "OTHER", "CONTROL", false },
    { "RESP_CROWD_CONTROL", "Crowd Control", "CROWD_CONTROL", "OTHER", "CONTROL", false },
    { "RESP_CLEANSE", "Cleanse", "CLEANSE", "OTHER", "DEFENSIVE_SUPPORT", false },
    { "RESP_SYNERGY_PROVIDER", "Synergy Provider", "SYNERGY_PROVIDER", "OTHER", "UTILITY", false },
    { "RESP_OFF_BALANCE", "Off Balance", "OFF_BALANCE", "DEBUFF", "DAMAGE_SUPPORT", false },
    { "RESP_WARHORN", "Warhorn Rotation", "ULT_WARHORN", "OTHER", "ULTIMATE_ROTATION", false },
    { "RESP_BARRIER", "Barrier Rotation", "ULT_BARRIER", "OTHER", "ULTIMATE_ROTATION", false },
    { "RESP_COLOSSUS", "Colossus Rotation", "ULT_COLOSSUS", "OTHER", "ULTIMATE_ROTATION", false },
}

for _, entry in ipairs(responsibilities) do
    R:Register("RESPONSIBILITIES", entry[1], {
        name = entry[2], effectKey = entry[3], classification = entry[4],
        family = entry[5], requiredByDefault = entry[6],
        assignmentMode = "PLAYER_AND_PROVIDER", manualOverride = true,
    })
end
