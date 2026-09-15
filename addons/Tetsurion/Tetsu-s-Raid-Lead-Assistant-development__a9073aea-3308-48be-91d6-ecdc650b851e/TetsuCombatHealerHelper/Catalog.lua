-- Healer-facing effect catalog. IDs are representative ranks; live matching
-- also uses localized ability/effect names because console ranks differ.
-- Friend healer picks the short-list later. Do not load extra events from here.

TetsuCombatHealerHelper = TetsuCombatHealerHelper or {}
local T = TetsuCombatHealerHelper

T.Catalog = {
    -- How we know the effect landed on a unit.
    -- effect: EVENT_EFFECT_CHANGED on group/player unitTag (name and/or id).
    -- slotCd: GetSlotCooldownRemaining on the caster's bar (self only).
    -- selfAura: effect on "player" while the construct lives (orb, altar).
    -- synergyCd: lockout aura on the person who took the synergy.

    heals = {
        illustrious = {
            label = "Illustrious Healing",
            morphOf = "Grand Healing",
            ids = { 40058, 41251, 41253, 41255, 28385 },
            names = { "illustrious healing", "блистательн", "grand healing", "великое исцеление" },
            detect = "effect",
            note = "Ground HoT 8m / 15s. Allies IN the circle get a ticking HoT. Standing in the puddle = they have this effect. Leaving = FADED. Healing Springs (other morph) is the same family.",
        },
        healingSprings = {
            label = "Healing Springs",
            morphOf = "Grand Healing",
            ids = { 40060, 41244, 41247, 41250 },
            names = { "healing springs", "исцеляющие родник" },
            detect = "effect",
            note = "Same puddle family. Extra magicka return on caster, same ally HoT detect.",
        },
        prayer = {
            label = "Combat Prayer",
            morphOf = "Blessing of Protection",
            ids = { 40094, 41175, 41182, 41189, 22265 },
            names = { "combat prayer", "боевая молитва", "blessing of protection", "благословение защиты" },
            alsoApplies = { "minorBerserk", "minorResolve" },
            detect = "effect+minors",
            note = "Cone, 10s. Event on allies is often Minor Berserk + Minor Resolve, not the skill name. Track those minors when source is you/group healer.",
        },
        blessingRestoration = {
            label = "Blessing of Restoration",
            morphOf = "Blessing of Protection",
            ids = { 40103, 35696 },
            names = { "blessing of restoration", "благословение восстанов" },
            alsoApplies = { "minorResolve" },
            detect = "effect",
        },
        radiatingRegen = {
            label = "Radiating Regeneration",
            morphOf = "Regeneration",
            ids = { 40079, 41278, 41283, 40066 },
            names = { "radiating regeneration", "излучающая регенерация" },
            detect = "effect",
            note = "HoT on up to 3 allies. Effect name is the skill.",
        },
        rapidRegen = {
            label = "Rapid Regeneration",
            morphOf = "Regeneration",
            ids = { 27068, 40076 },
            names = { "rapid regeneration", "быстрая регенерация" },
            detect = "effect",
        },
        echoingVigor = {
            label = "Echoing Vigor",
            morphOf = "Vigor",
            ids = { 61507, 63227 },
            names = { "echoing vigor", "раздающаяся бодрость", "эхо бодрости" },
            detect = "effect",
            note = "Assault line HoT, also trips Powerful Assault set.",
        },
        resolvingVigor = {
            label = "Resolving Vigor",
            morphOf = "Vigor",
            ids = { 61798, 63231 },
            names = { "resolving vigor", "крепнущая бодрость" },
            detect = "effect",
        },
        energyOrb = {
            label = "Energy Orb",
            morphOf = "Necrotic Orb",
            ids = { 85434, 85431, 95057, 63512 },
            names = { "energy orb", "энергетическая сфера", "necrotic orb", "некротическая сфера" },
            detect = "selfAura+effect",
            note = "One orb at a time, ~10s travel. Recast replaces. NO long ability CD — healers spam because they cannot see if the previous orb is dead. Detect: caster still has the orb aura, OR allies near it tick a heal named Energy Orb. Ready to recast = caster aura faded. Synergy Healing Combustion applies lockout 85434/63512/48052 on the person who took it (~20s shared with Spear Shards).",
        },
        mysticOrb = {
            label = "Mystic Orb",
            morphOf = "Necrotic Orb",
            ids = { 85432 },
            names = { "mystic orb" },
            detect = "selfAura",
        },
    },

    buffs = {
        minorBerserk = { label = "Minor Berserk", effect = "+5% damage done", sources = { "Combat Prayer", "various class/sets" }, names = { "minor berserk", "малое ожесточение" } },
        minorResolve = { label = "Minor Resolve", effect = "+2974 phys/spell resist", sources = { "Combat Prayer", "Blessing morphs" }, names = { "minor resolve", "малая решимость" } },
        majorCourage = { label = "Major Courage", effect = "+430 WD/SD", sources = { "Spell Power Cure (overheal 5s)", "Olorime ground circle 20s", "Pearlescent Ward stack", "Saint and the Seducer" }, ids = { 61708, 109966, 142305 }, names = { "major courage", "великая храбрость" }, detect = "effect" },
        minorCourage = { label = "Minor Courage", effect = "+215 WD/SD", sources = { "Power Extraction", "some sets" }, names = { "minor courage", "малая храбрость" } },
        majorSlayer = { label = "Major Slayer", effect = "+10% dmg to dungeon/trial/arena", sources = { "Aggressive Warhorn", "slayer sets" }, names = { "major slayer", "великая решимость убийцы" } },
        minorSlayer = { label = "Minor Slayer", effect = "+5% dmg to dungeon/trial/arena", sources = { "many monster/trial sets" }, names = { "minor slayer" } },
        majorForce = { label = "Major Force", effect = "+20% crit dmg", sources = { "Aggressive Warhorn", "some sets" }, names = { "major force", "великая сила" } },
        majorBerserk = { label = "Major Berserk", effect = "+10% dmg done", sources = { "class ults / sets" }, names = { "major berserk" } },
        majorVitality = { label = "Major Vitality", effect = "+12% healing taken", sources = { "Overflowing Altar synergy", "some sets" }, names = { "major vitality" } },
        minorVitality = { label = "Minor Vitality", effect = "+6% healing taken", sources = { "class / sets" }, names = { "minor vitality" } },
        majorAegis = { label = "Major Aegis", effect = "-10% dmg from PvE bosses", sources = { "Warhorn morph?", "trial sets" }, names = { "major aegis" } },
        minorAegis = { label = "Minor Aegis", effect = "-5% dmg from PvE bosses", sources = { "Olorime 3pc", "many trial sets" }, names = { "minor aegis" } },
        majorResolve = { label = "Major Resolve", effect = "+5948 resist", sources = { "Igneous Shield / class tanks" }, names = { "major resolve" } },
        minorBreach = { label = "Minor Breach", effect = "-2974 enemy resist", sources = { "Elemental Drain / wall" }, names = { "minor breach" } },
        majorBreach = { label = "Major Breach", effect = "-5948 enemy resist", sources = { "Elemental Susceptibility", "tank taunts" }, names = { "major breach" } },
        minorMagickaSteal = { label = "Minor Magickasteal", effect = "allies restore magicka on hit", sources = { "Elemental Drain", "Siphon Spirit" }, names = { "minor magickasteal", "малое похищение магии" } },
        minorLifesteal = { label = "Minor Lifesteal", effect = "allies heal on hit", sources = { "Blood Altar", "Force Siphon" }, names = { "minor lifesteal" } },
        empowered = { label = "Empower", effect = "next heavy/light boosted (current rules)", sources = { "class / sets" }, names = { "empower" } },
    },

    sets = {
        powerfulAssault = {
            label = "Powerful Assault",
            bonus = "Cast Assault skill in combat: you + 5 allies in 12m get +307 WD/SD for 15s.",
            ids = { 61771, 61763, 61772 },
            names = { "powerful assault", "мощный натиск" },
            detect = "effect",
            triggersOn = { "echoingVigor", "resolvingVigor", "any Assault skill" },
            note = "Buff name is the set name. Not Major Courage.",
        },
        spellPowerCure = {
            label = "Spell Power Cure",
            bonus = "Overheal self or ally -> target gets Major Courage 5s.",
            grants = "majorCourage",
            detect = "effect:majorCourage",
            note = "Cannot see the set, only the Courage it applies. Short 5s, needs constant overheal.",
        },
        olorime = {
            label = "Vestment of Olorime",
            bonus = "Ground ability in combat creates a 5s circle; allies in it get Major Courage 20s. 10s ICD.",
            grants = "majorCourage",
            detect = "effect:majorCourage",
        },
        pearlescentWard = {
            label = "Pearlescent Ward",
            bonus = "Stacking Major Courage / damage reduction by group size.",
            grants = "majorCourage",
            detect = "effect:majorCourage",
        },
        symphonyOfBlades = {
            label = "Symphony of Blades",
            bonus = "Overheal restores resources to the target.",
            detect = "none-visible-buff",
            note = "No clean ally aura. Skip for icons.",
        },
        roaringOpportunist = {
            label = "Roaring Opportunist",
            bonus = "Heavy attack grants Major Slayer to group.",
            grants = "majorSlayer",
            detect = "effect:majorSlayer",
        },
        masterArchitect = {
            label = "Master Architect",
            bonus = "Ult grants Major Slayer to group.",
            grants = "majorSlayer",
            detect = "effect:majorSlayer",
        },
        wormKings = {
            label = "Worm's Raiment",
            bonus = "Group magicka recover.",
            detect = "none-or-set-aura",
        },
        sanctuary = {
            label = "Sanctuary",
            bonus = "Group healing received.",
            detect = "none-or-set-aura",
        },
        jorvuld = {
            label = "Jorvuld's Guidance",
            bonus = "Longer buff durations on you.",
            detect = "none",
        },
        pillagers = {
            label = "Pillager's Profit",
            bonus = "Ult dump gives group ult gen.",
            detect = "none-clean",
        },
        sentinelRkugamz = {
            label = "Sentinel of Rkugamz",
            bonus = "Heal + resource totem.",
            detect = "ground-pet",
        },
    },

    cooldowns = {
        energyOrbCast = {
            label = "Energy Orb ready",
            who = "caster",
            how = "Self aura of the orb faded AND bar slot is usable. Ability itself has no long CD; the living orb is the lock.",
        },
        healingCombustion = {
            label = "Orb synergy lockout",
            who = "person who took synergy",
            ids = { 85434, 63512, 48052, 95924 },
            names = { "spear shards / necrotic orb cd", "healing combustion" },
            how = "Effect on the ally after they press synergy. ~20s shared with Spear Shards.",
        },
        warhorn = {
            label = "Warhorn",
            who = "caster",
            how = "Ultimate slot cooldown + Major Force/Slayer remaining on group.",
        },
    },
}

function T.CatalogKeys()
    local keys = {}
    for k in pairs(T.Catalog.heals) do keys[#keys + 1] = k end
    for k in pairs(T.Catalog.sets) do keys[#keys + 1] = k end
    for k in pairs(T.Catalog.buffs) do keys[#keys + 1] = k end
    return keys
end
