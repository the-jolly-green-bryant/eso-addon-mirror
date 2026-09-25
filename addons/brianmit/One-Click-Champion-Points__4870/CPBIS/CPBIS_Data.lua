-- CPBIS_Data.lua
-- All build data lives here so it is easy to edit when the meta changes.
-- Structure: CPBIS.Data[mode][role]  where mode = "PVE" | "PVP", role = "MAG" | "STAM" | "HEAL" | "TANK"
-- HEAL and TANK exist for PvE only.
-- Each slot list = the 4 slottable stars of that tree, in priority order.
-- "passives" = the non-slottable stars worth investing in, with suggested points.
-- Per-class differences go in CPBIS.ClassOverrides at the bottom (only what differs).

CPBIS = CPBIS or {}

CPBIS.Data = {

    ---------------------------------------------------------------- PvE (DPS)
    PVE = {
        MAG = {
            source   = "AlcastHQ Magicka PvE, all classes (U51, Sept 2026)",
            verified = true,
            warfare  = { "Wrathful Strikes", "Deadly Aim", "Master-at-Arms", "Backstabber" },
            fitness  = { "Boundless Vitality", "Bastion", "Siphoning Spells", "Fortified" },
            craft    = { "Steed's Blessing", "Rationer", "Liquid Efficiency", "Treasure Hunter (optional)" },
            passives = {
                warfare = "Precision 20, Piercing 20, Eldritch Insight 20, Flawless Ritual 40, War Mage 30, Quick Recovery 20, Preparation 20, Elemental Aegis 20, Hardy 20, Blessed 20, Tireless Discipline 20, Battle Mastery 40, Mighty 30",
                fitness = "Tumbling 30, Mystic Tenacity 50, Hero's Vigor 20, Shield Master 10, Defiance 20, Hasty 16, Tireless Guardian 20, Fortification 30, Sprinter 20, Nimble Protector 6, Savage Defense 30, Bashing Brutality 20, Piercing Gaze 30, Tempered Soul 50",
                craft   = "Breakfall 50, Wanderer 75, Steadfast Enchantment 50, Fortune's Favor 40, Gilded Fingers 40, Inspiration Boost 45",
            },
            note = "Magicka DPS uses the same setup on every class (1575 CP allocation).",
        },
        STAM = {
            source   = "AlcastHQ Stamina Dragonknight / Nightblade / Sorcerer / Necromancer PvE (U51, Sept 2026)",
            verified = true,
            warfare  = { "Wrathful Strikes", "Deadly Aim", "Master-at-Arms", "Backstabber" },
            fitness  = { "Boundless Vitality", "Fortified", "Bastion", "Bloody Renewal" },
            craft    = { "Steed's Blessing", "Rationer", "Liquid Efficiency", "Treasure Hunter (optional)" },
            passives = {
                warfare = "Precision 20, Piercing 20, Tireless Discipline 20, Battle Mastery 40, Mighty 30, Quick Recovery 20, Preparation 20, Elemental Aegis 20, Hardy 20, Blessed 20, Eldritch Insight 20, Flawless Ritual 40, War Mage 30",
                fitness = "Tumbling 30, Mystic Tenacity 10, Hero's Vigor 20, Shield Master 10, Defiance 20, Hasty 16, Tireless Guardian 20, Fortification 30, Sprinter 20, Nimble Protector 6, Savage Defense 30, Bashing Brutality 20, Piercing Gaze 30, Tempered Soul 50",
                craft   = "Breakfall 50, Wanderer 75, Steadfast Enchantment 50, Fortune's Favor 50, Gilded Fingers 50, Inspiration Boost 45",
            },
            note = "Arcanist, Templar and Warden use different Warfare stars (see their class entries).",
        },
        HEAL = {
            source   = "AlcastHQ Healer PvE, all classes (U51, Sept 2026)",
            verified = true,
            warfare  = { "Arcane Supremacy", "From the Brink", "Enlivening Overflow", "Hope Infusion" },
            fitness  = { "Boundless Vitality", "Rejuvenation", "Fortified", "Spirit Mastery" },
            craft    = { "Steed's Blessing", "Rationer", "Liquid Efficiency", "Treasure Hunter (optional)" },
            passives = {
                warfare = "Precision 20, Piercing 20, Blessed 20, Eldritch Insight 20, Flawless Ritual 40, War Mage 30, Quick Recovery 20, Preparation 20, Elemental Aegis 20, Hardy 20, Tireless Discipline 20, Battle Mastery 40, Mighty 30",
                fitness = "Tumbling 30, Mystic Tenacity 10, Hero's Vigor 20, Defiance 20, Hasty 16, Tireless Guardian 20, Fortification 30, Sprinter 20, Nimble Protector 6, Savage Defense 30, Bashing Brutality 20, Piercing Gaze 30, Tempered Soul 50",
                craft   = "Breakfall 50, Wanderer 75, Steadfast Enchantment 50, Fortune's Favor 50, Gilded Fingers 50, Inspiration Boost 45",
            },
            note = "Healers use the same setup on every class (1575 CP allocation).",
        },
        TANK = {
            source   = "AlcastHQ Tank PvE, all classes (U51, Sept 2026)",
            verified = true,
            warfare  = { "Duelist's Rebuff", "Enduring Resolve", "Unassailable", "Bulwark" },
            fitness  = { "Boundless Vitality", "Rejuvenation", "Fortified", "Expert Evasion" },
            craft    = { "Steed's Blessing", "Rationer", "Liquid Efficiency", "Treasure Hunter (optional)" },
            passives = {
                warfare = "Eldritch Insight 20, Tireless Discipline 20, Quick Recovery 20, Preparation 20, Elemental Aegis 20, Hardy 20, Blessed 20, Piercing 20, Battle Mastery 40, Flawless Ritual 40, Mighty 30, War Mage 30, Precision 20",
                fitness = "Tireless Guardian 20, Fortification 30, Hasty 16, Hero's Vigor 20, Tumbling 30, Defiance 20, Nimble Protector 6, Mystic Tenacity 10, Savage Defense 30, Bashing Brutality 20, Sprinter 20, Piercing Gaze 30, Tempered Soul 50",
                craft   = "Breakfall 50, Wanderer 75, Steadfast Enchantment 50, Fortune's Favor 40, Gilded Fingers 50, Inspiration Boost 45",
            },
            note = "Tanks use the same setup on every class (1575 CP allocation).",
        },
    },

    ---------------------------------------------------------------- PvP (Cyrodiil / BG)
    PVP = {
        MAG = {
            source   = "AlcastHQ Magicka Sorcerer / Dragonknight / Nightblade / Warden PvP (U51, Sept 2026)",
            verified = true,
            warfare  = { "Deadly Aim", "Arcane Supremacy", "Duelist's Rebuff", "Wrathful Strikes" },
            fitness  = { "Boundless Vitality", "Sustained by Suffering", "Pain's Refuge", "Slippery" },
            craft    = { "Steed's Blessing", "Rationer", "Liquid Efficiency", "Treasure Hunter (optional)" },
            passives = {
                warfare = "Precision 20, Piercing 20, Eldritch Insight 20, Flawless Ritual 40, War Mage 30, Quick Recovery 20, Hardy 20, Elemental Aegis 20, Blessed 20, Tireless Discipline 20, Battle Mastery 40, Mighty 30",
                fitness = "Tumbling 30, Mystic Tenacity 50, Hero's Vigor 20, Defiance 20, Hasty 16, Tireless Guardian 20, Fortification 30, Savage Defense 30, Sprinter 20, Nimble Protector 6, Bashing Brutality 20, Piercing Gaze 30, Tempered Soul 50",
                craft   = "Breakfall 50, Wanderer 75, Steadfast Enchantment 50, Fortune's Favor 50, Gilded Fingers 50, Out of Sight 30, Fleet Phantom 40, Soul Reservoir 33",
            },
            note = "Slots per class guides; passive spread from the Magicka Necromancer PvP setup (the only PvP guide with a full passive list).",
        },
        STAM = {
            source   = "AlcastHQ Stamina PvP, all classes except Templar (U51, Sept 2026)",
            verified = true,
            warfare  = { "Deadly Aim", "Master-at-Arms", "Wrathful Strikes", "Duelist's Rebuff" },
            fitness  = { "Boundless Vitality", "Sustained by Suffering", "Pain's Refuge", "Slippery" },
            craft    = { "Steed's Blessing", "Rationer", "Liquid Efficiency", "Treasure Hunter (optional)" },
            passives = {
                warfare = "Precision 20, Piercing 20, Tireless Discipline 20, Battle Mastery 40, Mighty 30, Quick Recovery 20, Hardy 20, Elemental Aegis 20, Blessed 20, Eldritch Insight 20, Flawless Ritual 40, War Mage 30",
                fitness = "Tumbling 30, Mystic Tenacity 50, Hero's Vigor 20, Defiance 20, Hasty 16, Tireless Guardian 20, Fortification 30, Savage Defense 30, Sprinter 20, Nimble Protector 6, Bashing Brutality 20, Piercing Gaze 30, Tempered Soul 50",
                craft   = "Breakfall 50, Wanderer 75, Steadfast Enchantment 50, Fortune's Favor 50, Gilded Fingers 50, Out of Sight 30, Fleet Phantom 40, Soul Reservoir 33",
            },
            note = "Slots per class guides; passive spread adapted from the Magicka Necromancer PvP setup (stamina Warfare stars first).",
        },
    },
}

-- Per-class overrides. Only fill in what differs from the tables above.
-- Class IDs: 1 Dragonknight, 2 Sorcerer, 3 Nightblade, 4 Warden, 5 Necromancer, 6 Templar, 117 Arcanist
-- Anything not listed here falls back to the standard setup for that mode/role.
CPBIS.ClassOverrides = {
    -- Explicit entries for every class. Empty tables inherit the shared build
    -- and keep the class selector/application system uniform across all classes.
    [1] = {}, -- Dragonknight
    [2] = {}, -- Sorcerer
    [3] = {}, -- Nightblade
    [4] = { -- Warden
        PVE = {
            STAM = {
                source  = "AlcastHQ Stamina Warden PvE (U51, Sept 2026)",
                warfare = { "Fighting Finesse", "Deadly Aim", "Master-at-Arms", "Backstabber" },
                note    = "Warden slots Fighting Finesse in place of Wrathful Strikes.",
            },
        },
    },
    [5] = { -- Necromancer
        PVP = {
            MAG = {
                source  = "AlcastHQ Magicka Necromancer PvP (U51, Sept 2026)",
                warfare = { "Deadly Aim", "Arcane Supremacy", "Duelist's Rebuff", "Untamed Aggression" },
            },
        },
    },
    [6] = { -- Templar
        PVE = {
            STAM = {
                source  = "AlcastHQ Stamina Templar PvE (U51, Sept 2026)",
                warfare = { "Wrathful Strikes", "Thaumaturge", "Biting Aura", "Backstabber" },
                note    = "Templar slots Thaumaturge and Biting Aura for its damage-over-time skills.",
            },
        },
        PVP = {
            MAG = {
                source  = "AlcastHQ Magicka Templar PvP (U51, Sept 2026), warfare only",
                warfare = { "Thaumaturge", "Biting Aura", "Duelist's Rebuff", "Wrathful Strikes" },
            },
            STAM = {
                source  = "AlcastHQ Stamina Templar PvP (U51, Sept 2026), warfare only",
                warfare = { "Untamed Aggression", "Biting Aura", "Wrathful Strikes", "Duelist's Rebuff" },
            },
        },
    },
    [117] = { -- Arcanist
        PVE = {
            STAM = {
                source  = "AlcastHQ Stamina Arcanist PvE (U51, Sept 2026)",
                warfare = { "Wrathful Strikes", "Thaumaturge", "Biting Aura", "Backstabber" },
                note    = "Arcanist slots Thaumaturge and Biting Aura for its damage-over-time skills.",
            },
        },
        PVP = {
            MAG = {
                source  = "AlcastHQ Magicka Arcanist PvP (U51, Sept 2026)",
                warfare = { "Deadly Aim", "Master-at-Arms", "Duelist's Rebuff", "Wrathful Strikes" },
            },
        },
    },
}
