local R = Conductor.Registry
R:Register("COMBAT_FORMS", "MORTAL", { name="Mortal", baseClassIndependent=true, roles={"TANK","HEALER","DD","SUPPORT"} })
R:Register("COMBAT_FORMS", "WEREWOLF", {
    name="Werewolf", baseClassIndependent=true, roles={"DD","SUPPORT"},
    preferredBaseClasses={"NIGHTBLADE","SORCERER","WARDEN","DRAGONKNIGHT"},
    provides={"MINOR_COURAGE","OFF_BALANCE"},
    detectionSkills={"WEREWOLF_BERSERKER","PACK_LEADER","FEROCIOUS_ROAR","DEAFENING_ROAR","HIRCINES_BOUNTY","POUNCE","HOWL_OF_AGONY","INFECTIOUS_CLAWS"},
    verifiedPatch=50, lastVerifiedPatch=50, verifiedDate="2026-07",
    source="Update 50 community build research", metaStatus="CURRENT_U50",
})
