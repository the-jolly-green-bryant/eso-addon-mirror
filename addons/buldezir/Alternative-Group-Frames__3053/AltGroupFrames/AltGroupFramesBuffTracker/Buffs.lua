-- Canonical list of trackable buff ability IDs.
-- Names are resolved at runtime via GetAbilityName(); these comments are for reference only.
-- Keep related pairs adjacent for the half-width checkbox layout in settings (weapon + spell, or major + minor)
-- Order determines display order; entries within the same cat are grouped under one header.
ALTGF_BUFFS = {
    { id = 61744,  cat = "Damage done" }, -- Minor Berserk
    { id = 62195,  cat = "Damage done" }, -- Major Berserk
    { id = 147226, cat = "Damage done" }, -- Minor Slayer
    { id = 93109,  cat = "Damage done" }, -- Major Slayer
    { id = 40224,  cat = "Damage done" }, -- Aggressive Horn
    { id = 217705, cat = "Damage done" }, -- Magical Banner
    { id = 217706, cat = "Damage done" }, -- Shocking Banner
    { id = 227003, cat = "Damage done" }, -- Fiery Banner
    { id = 217704, cat = "Damage done" }, -- Sundering Banner
    { id = 227004, cat = "Damage done" }, -- Shattering Banner
    { id = 151033, cat = "Damage done" }, -- Behemoth's Aura
    { id = 61737,  cat = "Damage done" }, -- Empower
    -- TODO: track Pillager's Profit 25s cooldown (not visible through buffs in-game)
    { id = 135924, cat = "Damage done", icon = "/esoui/art/icons/gear_seagiantlgt_helmet.dds" }, -- Roaring Opportunist Cooldown

    { id = 61665,  cat = "Weapon/spell damage" }, -- Major Brutality
    { id = 61687,  cat = "Weapon/spell damage" }, -- Major Sorcery
    { id = 61667,  cat = "Weapon/spell damage" }, -- Major Savagery
    { id = 61689,  cat = "Weapon/spell damage" }, -- Major Prophecy
    { id = 61662,  cat = "Weapon/spell damage" }, -- Minor Brutality
    { id = 61685,  cat = "Weapon/spell damage" }, -- Minor Sorcery
    { id = 61666,  cat = "Weapon/spell damage" }, -- Minor Savagery
    { id = 61691,  cat = "Weapon/spell damage" }, -- Minor Prophecy
    { id = 109966, cat = "Weapon/spell damage" }, -- Major Courage
    { id = 147417, cat = "Weapon/spell damage" }, -- Minor Courage
    { id = 61771,  cat = "Weapon/spell damage" }, -- Powerful Assault
    { id = 163401, cat = "Weapon/spell damage" }, -- Aura of Pride

    { id = 61747,  cat = "Critical" }, -- Major Force
    { id = 61746,  cat = "Critical" }, -- Minor Force

    { id = 194875, cat = "Critical" }, -- Fated Fortune

    { id = 172055, cat = "Ultimates" }, -- Pillager's Profit
    { id = 172056, cat = "Ultimates", suffix = "Cooldown", icon = GetAbilityIcon(172055) }, -- Pillager's Profit Cooldown

    { id = 61709,  cat = "Ultimates" }, -- Major Heroism
    { id = 61708,  cat = "Ultimates" }, -- Minor Heroism

    { id = 61694,  cat = "Defensive" }, -- Major Resolve
    { id = 61693,  cat = "Defensive" }, -- Minor Resolve
    { id = 61716,  cat = "Defensive" }, -- Major Evasion
    { id = 184933, cat = "Defensive" }, -- Minor Evasion
    { id = 61736,  cat = "Defensive" }, -- Major Expedition
    { id = 61735,  cat = "Defensive" }, -- Minor Expedition

    { id = 88490,  cat = "Defensive" }, -- Minor Toughness

    { id = 156011, cat = "Resources" }, -- Enlivening Overflow

    { id = 99781,  cat = "Resources" }, -- Grand Rejuvenation
    { id = 117111, cat = "Resources" }, -- Meridia's Favor

    { id = 61705,  cat = "Resources" }, -- Major Endurance
    { id = 61704,  cat = "Resources" }, -- Minor Endurance
    { id = 61707,  cat = "Resources" }, -- Major Intellect
    { id = 61706,  cat = "Resources" }, -- Minor Intellect
    { id = 68405,  cat = "Resources" }, -- Major Fortitude
    { id = 61697,  cat = "Resources" }, -- Minor Fortitude
}
