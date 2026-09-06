AbilityIDToolkit = AbilityIDToolkit or {}
local AIT = AbilityIDToolkit

AIT.KnownIDs = {
    [61726]  = { name = "Combat Prayer", category = "SKILL", notes = "Known project lookup example; provides Combat Prayer effects." },
    [106754] = { name = "Major Vulnerability", category = "DEBUFF", notes = "Correlated in early Conductor Colossus diagnostics." },
    [122174] = { name = "Frozen Colossus", category = "ULTIMATE", notes = "Necromancer Colossus morph ID used by Conductor diagnostics." },
    [122388] = { name = "Glacial Colossus", category = "ULTIMATE", notes = "Necromancer Colossus morph ID used by Conductor diagnostics." },
    [122395] = { name = "Pestilent Colossus", category = "ULTIMATE", notes = "Necromancer Colossus morph ID used by Conductor diagnostics." },
    [131353] = { name = "Feeding Frenzy", category = "BUFF", notes = "Unique Werewolf 6% damage buff tracked by Better Buffs." },
    [136123] = { name = "Sload's Call", category = "MYTHIC_EFFECT", notes = "Thrassian Stranglers stack effect; project research indicates combat-event fallback may be required." },
    [154737] = { name = "Sul-Xan proc", category = "GEAR_EFFECT", notes = "30s Sul-Xan effect ID recorded in project research." },
    [172054] = { name = "Pillager candidate cooldown/effect", category = "RESEARCH", notes = "Historical addon sources disagree; preserve for live reconciliation." },
    [172055] = { name = "Pillager ultimate-generation effect", category = "GEAR_EFFECT", notes = "Project research identifies this as the ultimate-generation effect." },
    [172056] = { name = "Pillager recipient cooldown candidate", category = "GEAR_COOLDOWN", notes = "Group Buff Panels research path; verify live." },
    [252048] = { name = "Mark of Hircine", category = "MYTHIC_DEBUFF", notes = "Huntsman's Warmask target debuff." },
    [252050] = { name = "Huntsman's Warmask player state", category = "MYTHIC_EFFECT", notes = "Player-side Warmask state from project ID audit." },
}
