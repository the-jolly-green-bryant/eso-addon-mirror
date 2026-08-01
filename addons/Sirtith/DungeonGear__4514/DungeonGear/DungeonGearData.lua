-- DungeonGear recommendations, keyed by role.
-- Edit freely between patches.
--
-- Row fields:
--   set       (required) display name of the gear set
--   dungeon   (required) where to farm it (dungeon, zone, or "Crafted")
--   priority  (required) "core" | "situational"
--   reason    (required) one-line "why pick this"
--   traits    (optional) recommended traits, e.g. "Infused / Reinforced"
--   weight    (optional) "Heavy" | "Medium" | "Light" | "Mixed"
--   slots      (optional) slot hint: "body" | "jewelry+weapons" | "monster (helm+shoulder)" | "front bar" | "back bar"
--   bis        (optional) true = current meta top pick (renders with a star)
--   classes    (optional) list of class names this especially fits; empty/nil = all
--   damageType (optional) "stam" | "mag" | "hybrid" | nil (universal). Drives the damage filter.
--   setId      (optional) ESO set itemId, used by LibSets to resolve localized name
--
-- Class names: "Arcanist", "DragonKnight", "Nightblade", "Sorcerer", "Templar", "Necromancer", "Warden"

DungeonGear_Classes = {
    "Any", "Arcanist", "DragonKnight", "Nightblade", "Sorcerer", "Templar", "Necromancer", "Warden",
}

DungeonGear_Roles = { "tank", "healer", "dps", "beginner", "monster", "overland", "trial" }

DungeonGear_Data = {
    tank = {
        { set = "Turning Tide", dungeon = "Shipwright's Regret", priority = "core", bis = true,
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "Applies Major Vulnerability - biggest group DPS debuff in the game." },
        { set = "Lucent Echoes", dungeon = "Lucent Citadel (Trial)", priority = "core", bis = true,
          weight = "Heavy", traits = "Reinforced", slots = "jewelry+weapons",
          reason = "Modern group buff set - strong uptime in trials. Pairs with Turning Tide." },
        { set = "Ebon Armory", dungeon = "Crypt of Hearts I", priority = "core",
          weight = "Heavy", traits = "Reinforced / Sturdy", slots = "body",
          reason = "+1000 max health to group. Classic group health buff." },
        { set = "Plague Doctor", dungeon = "Deshaan (overland)", priority = "core",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "+4227 max health. Great starter tank set while farming dungeons." },
        { set = "Torug's Pact", dungeon = "Crafted (Deshaan/Grahtwood/Stormhaven)", priority = "core",
          weight = "Heavy", traits = "Infused (weapons) / Reinforced", slots = "jewelry+weapons",
          reason = "Boosts Crusher enchant uptime - staple tank weapon enchant source." },
        { set = "Claw of Yolnahkriin", dungeon = "Sunspire (Trial)", priority = "core",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "Minor Courage group buff (+215 weapon/spell damage)." },
        { set = "Drake's Rush", dungeon = "Black Drake Villa", priority = "situational",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          classes = { "DragonKnight" },
          reason = "Ultimate generation for 4-player group - pairs best with DK." },
        { set = "Saxhleel Champion", dungeon = "Rockgrove (Trial)", priority = "situational",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          classes = { "DragonKnight", "Sorcerer" },
          reason = "Major Force for group on ultimate cast - strong with high-ult-gen classes." },
        { set = "Powerful Assault", dungeon = "Imperial City (Tel Var)", priority = "situational",
          weight = "Medium", traits = "Reinforced", slots = "jewelry+weapons",
          reason = "+307 Weapon/Spell Damage to group when you cast an Assault ability." },
        { set = "Crimson Oath's Rive", dungeon = "The Dread Cellar", priority = "core",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "Reduces nearby enemy Armor by 3541 on buff activation. Strong group pen debuff." },
        { set = "Meridia's Blessed Armor", dungeon = "Graven Deep", priority = "situational",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "Ult gain and resist buff when taking damage - solid modern tank option." },
        { set = "Ironblood", dungeon = "Crafted (Wrothgar)", priority = "core",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "Flat +5280 physical/spell resist on block. Cheap craftable tank starter." },
        { set = "Fortified Brass", dungeon = "Crafted (Orsinium)", priority = "core",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "+5280 physical resist. Classic new-tank staple from Orsinium stations." },
        { set = "Armor Master", dungeon = "Crafted (Craglorn)", priority = "situational",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "Major Resolve + bonus resists on bar swap. Classic crafted tank set." },
        { set = "Akaviri Dragonguard", dungeon = "Crafted (Imperial City Sewers)", priority = "situational",
          weight = "Heavy", traits = "Infused (weapons) / Reinforced", slots = "jewelry+weapons",
          reason = "Ultimate cost reduction - strong for spammable ults like Aggressive Horn." },
        { set = "Tormentor", dungeon = "Crafted (Stormhaven/Stonefalls/Auridon)", priority = "situational",
          weight = "Heavy", traits = "Reinforced", slots = "jewelry+weapons",
          reason = "AoE taunt on Pierce Armor - easy group threat set for new tanks." },
        { set = "Leki's Focus", dungeon = "Blackwood (overland)", priority = "situational",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "Block mitigation stacking. Overland-farmable alternative to dungeon sets." },
        { set = "Puncturing Remedy", dungeon = "Fang Lair", priority = "situational",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "Burst heal on taunt - good self-sustain for tough pulls." },
    },

    healer = {
        { set = "Pillager's Profit", dungeon = "Dreadsail Reef (Trial)", priority = "core", bis = true,
          weight = "Light", traits = "Divines", slots = "body",
          reason = "Current meta 5pc - 5% of ultimate spent returned to group." },
        { set = "Spell Power Cure", dungeon = "White-Gold Tower", priority = "core", bis = true,
          weight = "Light", traits = "Divines", slots = "jewelry+weapons",
          reason = "Major Courage via overheal - cleanest source in the game." },
        { set = "Symphony of Blades", dungeon = "Depths of Malatar (vet)", priority = "core",
          slots = "monster (helm+shoulder)",
          reason = "Monster set: restores resources to low-resource allies via Meridia's Favor." },
        { set = "Jorvuld's Guidance", dungeon = "Scalecaller Peak (vet)", priority = "core",
          weight = "Light", traits = "Divines", slots = "body",
          reason = "Extends all buff and damage shield durations by 40%." },
        { set = "Olorime", dungeon = "Cloudrest (Trial)", priority = "core",
          weight = "Light", traits = "Divines", slots = "jewelry+weapons",
          reason = "Alternate Major Courage source via ground AoE." },
        { set = "Kagrenac's Hope", dungeon = "Crafted (Nchuleftingth / Mzeneldt / etc)", priority = "situational",
          weight = "Light", traits = "Divines", slots = "body",
          reason = "Craftable healer stat stick - cheap baseline." },
        { set = "Transformative Hope", dungeon = "Sanity's Edge (Trial)", priority = "situational",
          weight = "Light", traits = "Divines", slots = "body",
          reason = "Returns resources when casting on low-resource allies." },
    },

    dps = {
        { set = "Coral Riptide", dungeon = "Dreadsail Reef (Trial)", priority = "core", bis = true,
          weight = "Medium", traits = "Divines", slots = "body (stamina)",
          damageType = "stam",
          classes = { "DragonKnight", "Nightblade", "Warden", "Arcanist", "Templar" },
          reason = "Scales weapon/spell damage as stamina drops - top stam parse set." },
        { set = "Slivers of the Null Arca", dungeon = "Lucent Citadel (Trial)", priority = "core", bis = true,
          weight = "Medium", traits = "Divines", slots = "body",
          damageType = "hybrid",
          reason = "Burst damage proc on crits. Universal trial DPS set." },
        { set = "Deadly Strike", dungeon = "Cyrodiil / Imperial City", priority = "core", bis = true,
          weight = "Medium", traits = "Divines", slots = "jewelry+weapons",
          damageType = "hybrid",
          classes = { "Templar", "Necromancer", "Arcanist", "Warden" },
          reason = "+15% DoT and channeled ability damage. BiS for Jabs/channels." },
        { set = "Ansuul's Torment", dungeon = "Sanity's Edge (Trial)", priority = "core", bis = true,
          weight = "Medium", traits = "Divines", slots = "jewelry+weapons",
          damageType = "hybrid",
          reason = "+7% damage vs monsters, +14% when you interrupt. Universal trial DPS set." },
        { set = "Pillar of Nirn", dungeon = "Falkreath Hold", priority = "core",
          weight = "Medium", traits = "Divines", slots = "body",
          damageType = "stam",
          classes = { "DragonKnight", "Nightblade", "Warden" },
          reason = "Strong bleed DoT - stamina DPS staple for years." },
        { set = "Medusa", dungeon = "Arx Corinium", priority = "core",
          weight = "Heavy", traits = "Divines", slots = "jewelry+weapons",
          damageType = "mag",
          classes = { "Arcanist", "Sorcerer", "Nightblade", "Necromancer", "Templar" },
          reason = "Minor Force (+10% crit damage) permanently. Use on jewelry+weapons for mag DPS." },
        { set = "Whorl of the Depths", dungeon = "Dreadsail Reef (Trial)", priority = "core",
          weight = "Light", traits = "Divines", slots = "body",
          damageType = "mag",
          reason = "Frost DoT + AoE whirlpool proc on light attacks. Strong mag DPS trial set." },
        { set = "Mother's Sorrow", dungeon = "Deshaan (overland)", priority = "core",
          weight = "Light", traits = "Divines", slots = "body",
          damageType = "mag",
          reason = "+1924 critical chance - easy overland starter for mag DPS." },
        { set = "Order's Wrath", dungeon = "Crafted (High Isle, 3 traits)", priority = "core",
          weight = "Medium / Light", traits = "Divines", slots = "jewelry+weapons",
          damageType = "hybrid",
          reason = "+8% crit damage/healing - universal crafted DPS set (3 traits)." },
    },

    beginner = {
        { set = "Order's Wrath", dungeon = "Crafted (High Isle, 3 traits)", priority = "core", bis = true,
          weight = "Medium / Light", traits = "any", slots = "body",
          damageType = "hybrid",
          reason = "Universal new-player DPS set - +8% crit damage/healing. Crafted at 3 traits." },
        { set = "Mother's Sorrow", dungeon = "Deshaan (overland)", priority = "core", bis = true,
          weight = "Light", traits = "any", slots = "jewelry+weapons",
          damageType = "mag",
          reason = "Easy overland farm - strong crit chance for new magicka DPS." },
        { set = "Hunding's Rage", dungeon = "Crafted (Bangkorai/Reaper's March/Stormhaven)", priority = "core",
          weight = "Medium", traits = "any", slots = "body",
          damageType = "stam",
          reason = "Craftable at 6 traits. Stamina DPS starter - +300 weapon damage." },
        { set = "Law of Julianos", dungeon = "Crafted (Craglorn)", priority = "core",
          weight = "Light", traits = "any", slots = "body",
          damageType = "mag",
          reason = "Craftable at 6 traits. Magicka DPS starter - +300 spell damage." },
        { set = "Torug's Pact", dungeon = "Crafted (Deshaan/Grahtwood/Stormhaven)", priority = "core",
          weight = "Any", traits = "any", slots = "jewelry+weapons",
          reason = "Craftable at 3 traits. Useful for tanks AND enchant-focused DPS." },
        { set = "Seducer", dungeon = "Crafted (Grahtwood/Greenshade/Reaper's March)", priority = "core",
          weight = "Light", traits = "any", slots = "body",
          damageType = "mag",
          reason = "Craftable at 3 traits. Cheap magicka-cost reduction for new healers/mag DPS." },
        { set = "Plague Doctor", dungeon = "Deshaan (overland)", priority = "core",
          weight = "Heavy", traits = "any", slots = "body",
          reason = "+4227 health. Easy farm in Deshaan chests/delves for new tanks." },
    },

    -- Monster helms drop as 1pc (shoulder from Maj-ul-Xulabaal writs, helm from last dungeon boss).
    -- 2pc bonus is what matters; 1pc is a flat stat the addon ignores.
    -- slots = "monster (helm+shoulder)" on all of these.
    monster = {
        { set = "Slimecraw", dungeon = "Wayrest Sewers I", priority = "core", bis = true,
          slots = "monster (helm+shoulder)",
          reason = "DPS BiS: Minor Berserk (+8% dmg). Cheap, normal dungeon drop." },
        { set = "Bloodspawn", dungeon = "Spindleclutch II", priority = "core", bis = true,
          slots = "monster (helm+shoulder)",
          reason = "Tank BiS: +20% physical/spell resist and Ultimate gen on hit." },
        { set = "Earthgore", dungeon = "Bloodroot Forge", priority = "core", bis = true,
          slots = "monster (helm+shoulder)",
          reason = "Healer BiS: massive burst heal pool when allies are hurt." },
        { set = "Stormfist", dungeon = "Tempest Island", priority = "situational",
          slots = "monster (helm+shoulder)",
          reason = "DPS: AoE shock damage proc. Normal dungeon drop." },
        { set = "Selene", dungeon = "Selene's Web", priority = "situational",
          slots = "monster (helm+shoulder)",
          reason = "DPS: huge single-target proc on light attack." },
        { set = "Maw of the Infernal", dungeon = "Banished Cells II", priority = "situational",
          slots = "monster (helm+shoulder)",
          reason = "DPS: summons a daedroth - solo/leveling favorite." },
        { set = "Lord Warden", dungeon = "Imperial City Prison", priority = "core",
          slots = "monster (helm+shoulder)",
          reason = "Tank: AoE resistances for nearby group members." },
        { set = "Nazaray", dungeon = "Coral Aerie", priority = "core",
          slots = "monster (helm+shoulder)",
          reason = "Tank/support: Major Vitality + damage taken reduction pulse." },
        { set = "Encratis's Behemoth", dungeon = "Black Drake Villa", priority = "situational",
          slots = "monster (helm+shoulder)",
          reason = "DPS: flame damage taken reduction debuff on enemy." },
        { set = "Sentinel of Rkugamz", dungeon = "Darkshade Caverns I", priority = "core",
          slots = "monster (helm+shoulder)",
          reason = "Healer: dwemer spider pet - passive AoE heal + stam return." },
        { set = "Symphony of Blades", dungeon = "Depths of Malatar", priority = "situational",
          slots = "monster (helm+shoulder)",
          reason = "Healer: resources to low-resource allies." },
        { set = "Roksa the Warped", dungeon = "Bal Sunnar", priority = "situational",
          slots = "monster (helm+shoulder)",
          reason = "Tank: stacking recovery in combat (+8 Stam/Mag/Health Recovery per sec, up to 30 stacks)." },
    },

    -- Overland sets: drop from world bosses, delves, public dungeons, and zone chests.
    -- Farmable solo - great for new players and alts before running dungeons.
    overland = {
        { set = "Order's Wrath", dungeon = "Crafted (High Isle, 3 traits)", priority = "core", bis = true,
          weight = "Medium / Light", traits = "Divines", slots = "jewelry+weapons",
          damageType = "hybrid",
          reason = "+8% crit damage/healing. Universal crafted DPS set - only 3 traits needed." },
        { set = "Mother's Sorrow", dungeon = "Deshaan (overland)", priority = "core", bis = true,
          weight = "Light", traits = "Divines", slots = "body",
          damageType = "mag",
          reason = "+1924 crit chance. Classic mag DPS overland farm." },
        { set = "Briarheart", dungeon = "Wrothgar (overland)", priority = "core",
          weight = "Medium", traits = "Divines", slots = "body",
          damageType = "stam",
          classes = { "DragonKnight", "Nightblade", "Warden" },
          reason = "Stamina DPS - weapon damage proc on crit." },
        { set = "Hunt Leader", dungeon = "Western Skyrim (overland)", priority = "core",
          weight = "Medium", traits = "Divines", slots = "body",
          damageType = "stam",
          classes = { "DragonKnight", "Nightblade", "Warden" },
          reason = "Stamina DPS - extra weapon damage on heavy attack." },
        { set = "Spinner's Garments", dungeon = "Malabal Tor (overland)", priority = "core",
          weight = "Light", traits = "Divines", slots = "body",
          damageType = "mag",
          reason = "+2752 penetration - magicka DPS staple for unbuffed content." },
        { set = "Mechanical Acuity", dungeon = "Clockwork City (overland)", priority = "situational",
          weight = "Medium / Light", traits = "Divines", slots = "body",
          damageType = "hybrid",
          reason = "100% crit for 5s every 18s - burst windows for dungeons." },
        { set = "Plague Doctor", dungeon = "Deshaan (overland)", priority = "core",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "+4227 max health. New tank starter - easy Deshaan farm." },
        { set = "Senche-raht's Grit", dungeon = "Northern Elsweyr (overland)", priority = "situational",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "Damage taken reduction scaling with max health. Beginner tank." },
        { set = "Amber Plasm", dungeon = "Murkmire (overland)", priority = "situational",
          weight = "Light", traits = "Divines", slots = "body",
          reason = "Healer overland set - magicka return when healing low allies." },
        { set = "Way of Fire", dungeon = "Bangkorai (overland)", priority = "situational",
          weight = "Medium", traits = "Divines", slots = "body",
          damageType = "stam",
          reason = "Stam DPS - flame damage proc on ability use." },
        { set = "Hrothgar's Chill", dungeon = "Western Skyrim (overland)", priority = "situational",
          weight = "Light", traits = "Divines", slots = "body",
          damageType = "mag",
          reason = "Mag DPS AoE - frost explosion proc for trash packs." },
    },

    -- Trial sets: drop from 12-player trials. Many have 'Perfected' versions from vet hard modes.
    -- Usually the highest-ceiling sets in the game - most BiS picks for endgame live here.
    trial = {
        { set = "Coral Riptide", dungeon = "Dreadsail Reef", priority = "core", bis = true,
          weight = "Medium", traits = "Divines", slots = "body (stamina)",
          damageType = "stam",
          classes = { "DragonKnight", "Nightblade", "Warden", "Arcanist", "Templar" },
          reason = "Top stamina DPS parse set - scales weapon/spell damage as stam drops." },
        { set = "Pillager's Profit", dungeon = "Dreadsail Reef", priority = "core", bis = true,
          weight = "Light", traits = "Divines", slots = "body",
          reason = "Current meta healer 5pc - returns 5% of ultimate spent to group." },
        { set = "Slivers of the Null Arca", dungeon = "Lucent Citadel", priority = "core", bis = true,
          weight = "Medium", traits = "Divines", slots = "body",
          damageType = "hybrid",
          reason = "Burst damage proc on crits. Universal trial DPS set." },
        { set = "Ansuul's Torment", dungeon = "Sanity's Edge", priority = "core", bis = true,
          weight = "Medium", traits = "Divines", slots = "jewelry+weapons",
          damageType = "hybrid",
          reason = "+7% damage vs monsters, +14% when you interrupt. Universal trial DPS set." },
        { set = "Lucent Echoes", dungeon = "Lucent Citadel", priority = "core", bis = true,
          weight = "Heavy", traits = "Reinforced", slots = "jewelry+weapons",
          reason = "Tank BiS group buff set - pairs with Turning Tide." },
        { set = "Transformative Hope", dungeon = "Sanity's Edge", priority = "core",
          weight = "Light", traits = "Divines", slots = "body",
          reason = "Healer: returns resources when casting on low-resource allies." },
        { set = "Claw of Yolnahkriin", dungeon = "Sunspire", priority = "core",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "Tank support - Minor Courage group buff (+215 weapon/spell damage)." },
        { set = "Olorime", dungeon = "Cloudrest", priority = "core",
          weight = "Light", traits = "Divines", slots = "jewelry+weapons",
          reason = "Healer: Major Courage via ground AoE. Alternate to Spell Power Cure." },
        { set = "Relequen", dungeon = "Cloudrest", priority = "core",
          weight = "Medium", traits = "Divines", slots = "body",
          damageType = "stam",
          classes = { "Nightblade", "DragonKnight", "Warden", "Arcanist" },
          reason = "Classic stamina DPS trial set - stacking light attack damage." },
        { set = "Roar of Alkosh", dungeon = "Maw of Lorkhaj", priority = "core",
          weight = "Medium", traits = "Reinforced", slots = "body",
          reason = "Tank: Minor Resolve/Maim debuff AoE - classic group debuff set." },
        { set = "Kinras's Wrath", dungeon = "Black Drake Villa", priority = "core",
          weight = "Medium", traits = "Divines", slots = "body",
          damageType = "stam",
          classes = { "DragonKnight", "Nightblade", "Warden", "Arcanist" },
          reason = "Stamina DPS - stacking weapon damage on light attacks." },
        { set = "Pearlescent Ward", dungeon = "Dreadsail Reef", priority = "situational",
          weight = "Heavy", traits = "Reinforced", slots = "body",
          reason = "Tank/support - group damage done buff from heavy attacks." },
        { set = "Xoryn's Masterpiece", dungeon = "Lucent Citadel", priority = "situational",
          weight = "Medium", traits = "Divines", slots = "body",
          damageType = "stam",
          reason = "Stam DPS - bleed damage boost, strong with dual-wield." },
    },
}

-- ---------------------------------------------------------------------------
-- Curated complete loadouts. One entry = one archetype build.
-- Each build names the three sets that make the loadout work.
-- Fields: name, role, class (optional), damageType (optional), body, jewelry, monster, summary

-- Build URLs use AlcastHQ site-search URLs (guaranteed to resolve).
-- Edit to point at specific pages if you know them.

DungeonGear_Builds = {
    {
        name       = "Stamina DragonKnight DPS",
        role       = "dps",
        class      = "DragonKnight",
        damageType = "stam",
        body       = "Coral Riptide",
        jewelry    = "Deadly Strike",
        monster    = "Slimecraw",
        summary    = "Classic stam DK bleed/DoT parse build. Front bar dual-wield, back bar bow.",
        url        = "https://alcasthq.com/?s=stamina+dragonknight+build",
    },
    {
        name       = "Magicka Arcanist DPS",
        role       = "dps",
        class      = "Arcanist",
        damageType = "mag",
        body       = "Slivers of the Null Arca",
        jewelry    = "Ansuul's Torment",
        monster    = "Slimecraw",
        summary    = "Top Arcanist trial parse. Slivers on body for Fatecarver burst, Ansuul's for monster damage.",
        url        = "https://alcasthq.com/?s=magicka+arcanist+build",
    },
    {
        name       = "Stamina Warden DPS",
        role       = "dps",
        class      = "Warden",
        damageType = "stam",
        body       = "Coral Riptide",
        jewelry    = "Whorl of the Depths",
        monster    = "Slimecraw",
        summary    = "Warden stam build emphasizing Shalks + bleeds. Whorl for frost damage proc.",
        url        = "https://alcasthq.com/?s=stamina+warden+build",
    },
    {
        name       = "Magicka Sorcerer DPS",
        role       = "dps",
        class      = "Sorcerer",
        damageType = "mag",
        body       = "Slivers of the Null Arca",
        jewelry    = "Medusa",
        monster    = "Slimecraw",
        summary    = "Mag Sorc crit/pet build. Slivers for burst, Medusa for Minor Force.",
        url        = "https://alcasthq.com/?s=magicka+sorcerer+build",
    },
    {
        name       = "Stamina Nightblade DPS",
        role       = "dps",
        class      = "Nightblade",
        damageType = "stam",
        body       = "Coral Riptide",
        jewelry    = "Relequen",
        monster    = "Slimecraw",
        summary    = "Stam NB light-attack-weaving build. Double stack set ceiling.",
        url        = "https://alcasthq.com/?s=stamina+nightblade+build",
    },
    {
        name       = "Stamina Templar DPS (Jabs)",
        role       = "dps",
        class      = "Templar",
        damageType = "stam",
        body       = "Coral Riptide",
        jewelry    = "Deadly Strike",
        monster    = "Slimecraw",
        summary    = "Stam Templar Jabs spam - Deadly Strike is massive for Biting Jabs damage.",
        url        = "https://alcasthq.com/?s=stamina+templar+build",
    },
    {
        name       = "Any DragonKnight Tank",
        role       = "tank",
        class      = "DragonKnight",
        body       = "Turning Tide",
        jewelry    = "Drake's Rush",
        monster    = "Bloodspawn",
        summary    = "DK tank with ult-gen. Major Vulnerability uptime + group ult gen + Bloodspawn resists.",
        url        = "https://alcasthq.com/?s=dragonknight+tank+build",
    },
    {
        name       = "Any Class Tank (meta)",
        role       = "tank",
        body       = "Turning Tide",
        jewelry    = "Lucent Echoes",
        monster    = "Bloodspawn",
        summary    = "Universal trial tank loadout. Major Vulnerability + Lucent Echoes group buff.",
        url        = "https://alcasthq.com/category/pve-group-builds/",
    },
    {
        name       = "Budget Beginner Tank",
        role       = "tank",
        body       = "Plague Doctor",
        jewelry    = "Torug's Pact",
        monster    = "Lord Warden",
        summary    = "No dungeon grinds needed. Plague Doctor (Deshaan overland) + crafted + IC Prison monster.",
        url        = "https://alcasthq.com/?s=beginner+tank+build",
    },
    {
        name       = "Any Class Healer (meta)",
        role       = "healer",
        body       = "Pillager's Profit",
        jewelry    = "Spell Power Cure",
        monster    = "Earthgore",
        summary    = "Current meta healer. 5pc body Pillager's + Major Courage from SPC overhealing.",
        url        = "https://alcasthq.com/?s=healer+build",
    },
    {
        name       = "Alternate Healer (no trial)",
        role       = "healer",
        body       = "Jorvuld's Guidance",
        jewelry    = "Spell Power Cure",
        monster    = "Sentinel of Rkugamz",
        summary    = "All from 4-player dungeons. Extended buffs + Major Courage + spider heal pet.",
        url        = "https://alcasthq.com/?s=healer+dungeons",
    },
    {
        name       = "Beginner DPS (overland only)",
        role       = "dps",
        damageType = "hybrid",
        body       = "Order's Wrath",
        jewelry    = "Mother's Sorrow",
        monster    = "Slimecraw",
        summary    = "Order's Wrath is crafted (3 traits). Gold-viable starter loadout for any DPS class.",
        url        = "https://alcasthq.com/?s=beginner+dps+build",
    },
}

-- Map pin coordinates (requires LibMapPins-1.0).
-- Each entry uses:
--   zone = "zone/subzone" key matching LMP:GetZoneAndSubzone(true)
--   x, y = normalized 0-1 coordinates on that zone's map
-- Pins only appear when the player is viewing the matching zone map.
-- Zone keys can be found in-game with: /script d(LibMapPins:GetZoneAndSubzone(true))
-- Coordinates can be found with: /script d(GetMapPlayerPosition("player"))
--
-- NOTE: These zone keys and coordinates are approximate and should be
-- verified in-game. Use /dg pinhelp to print current zone and position.
DungeonGear_DungeonMapCoords = {
    -- Deshaan (overland sets: Mother's Sorrow, Plague Doctor)
    ["Deshaan (overland)"]         = { zone = "deshaan/deshaan_base",           x = 0.50, y = 0.50 },
    -- Stormhaven (Wayrest Sewers I, Spindleclutch II)
    ["Wayrest Sewers I"]           = { zone = "stormhaven/stormhaven_base",     x = 0.62, y = 0.41 },
    ["Spindleclutch II"]           = { zone = "stormhaven/stormhaven_base",     x = 0.17, y = 0.53 },
    -- Rivenspire (Crypt of Hearts I)
    ["Crypt of Hearts I"]          = { zone = "rivenspire/rivenspire_base",     x = 0.60, y = 0.76 },
    -- Shadowfen (Arx Corinium)
    ["Arx Corinium"]               = { zone = "shadowfen/shadowfen_base",       x = 0.85, y = 0.41 },
    -- Bangkorai
    ["Bangkorai (overland)"]       = { zone = "bangkorai/bangkorai_base",       x = 0.50, y = 0.50 },
    -- Wrothgar / Orsinium
    ["Wrothgar (overland)"]        = { zone = "wrothgar/wrothgar_base",         x = 0.50, y = 0.50 },
    -- Malabal Tor
    ["Malabal Tor (overland)"]     = { zone = "malabaltor/malabaltor_base",     x = 0.50, y = 0.50 },
    -- High Isle
    ["High Isle (overland)"]       = { zone = "systres/u34_systreszone_base",         x = 0.50, y = 0.50 },
    -- Blackwood
    ["Blackwood (overland)"]       = { zone = "blackwood/blackwood_base",       x = 0.50, y = 0.50 },
    -- Western Skyrim
    ["Western Skyrim (overland)"]  = { zone = "skyrim/westernskryim_base", x = 0.50, y = 0.50 },
    -- Northern Elsweyr
    ["Northern Elsweyr (overland)"]= { zone = "elsweyr/elsweyr_base",           x = 0.50, y = 0.50 },
    -- Murkmire
    ["Murkmire (overland)"]        = { zone = "murkmire/murkmire_base",         x = 0.50, y = 0.50 },
    -- Clockwork City
    ["Clockwork City (overland)"]  = { zone = "clockwork/clockwork_base", x = 0.50, y = 0.50 },
    -- Auridon (Banished Cells II)
    ["Banished Cells II"]          = { zone = "auridon/auridon_base",           x = 0.54, y = 0.62 },
    -- Grahtwood (Selene's Web)
    ["Selene's Web"]               = { zone = "grahtwood/grahtwood_base",       x = 0.83, y = 0.16 },
    -- Stonefalls (Darkshade Caverns I)
    ["Darkshade Caverns I"]        = { zone = "stonefalls/stonefalls_base",     x = 0.72, y = 0.28 },
    -- Tempest Island (Malabal Tor)
    ["Tempest Island"]             = { zone = "malabaltor/malabaltor_base",     x = 0.92, y = 0.09 },
    -- Eastmarch (Bloodroot Forge, Falkreath Hold)
    ["Bloodroot Forge"]            = { zone = "craglorn/craglorn_base",         x = 0.20, y = 0.55 },
    ["Falkreath Hold"]             = { zone = "craglorn/craglorn_base",         x = 0.25, y = 0.50 },
    ["Fang Lair"]                  = { zone = "craglorn/craglorn_base",         x = 0.30, y = 0.45 },
    ["Scalecaller Peak (vet)"]     = { zone = "craglorn/craglorn_base",         x = 0.35, y = 0.40 },
    -- Gold Coast dungeons
    ["Black Drake Villa"]          = { zone = "wrothgar/goldcoast_base",       x = 0.55, y = 0.40 },
    ["Red Petal Bastion"]          = { zone = "wrothgar/goldcoast_base",       x = 0.50, y = 0.60 },
    ["The Dread Cellar"]           = { zone = "wrothgar/goldcoast_base",       x = 0.45, y = 0.55 },
    -- Imperial City
    ["Imperial City Prison"]       = { zone = "cyrodiil/imperialcity_base", x = 0.50, y = 0.50 },
    ["Imperial City (Tel Var)"]    = { zone = "cyrodiil/imperialcity_base", x = 0.50, y = 0.50 },
    ["Cyrodiil / Imperial City"]   = { zone = "cyrodiil/imperialcity_base", x = 0.50, y = 0.50 },
    ["White-Gold Tower"]           = { zone = "cyrodiil/imperialcity_base", x = 0.50, y = 0.50 },
    -- Systres / High Isle dungeons
    ["Coral Aerie"]                = { zone = "systres/u34_systreszone_base",         x = 0.80, y = 0.20 },
    ["Graven Deep"]                = { zone = "systres/u34_systreszone_base",         x = 0.20, y = 0.80 },
    ["Shipwright's Regret"]        = { zone = "systres/u34_systreszone_base",         x = 0.70, y = 0.70 },
    -- The Reach / Markarth
    ["Bal Sunnar"]                 = { zone = "reach/reach_base",               x = 0.50, y = 0.50 },
    -- West Weald / Scrivener's Hall
    ["Scrivener's Hall"]           = { zone = "westweald/westwealdoverland_base",       x = 0.50, y = 0.50 },
    -- Depths of Malatar (Gold Coast)
    ["Depths of Malatar"]          = { zone = "wrothgar/goldcoast_base",       x = 0.60, y = 0.45 },
    ["Depths of Malatar (vet)"]    = { zone = "wrothgar/goldcoast_base",       x = 0.60, y = 0.45 },
    -- Summerset (Cloudrest)
    ["Cloudrest"]                  = { zone = "summerset/summerset_base",       x = 0.65, y = 0.35 },
    ["Cloudrest (Trial)"]          = { zone = "summerset/summerset_base",       x = 0.65, y = 0.35 },
    -- Elsweyr (Sunspire)
    ["Sunspire"]                   = { zone = "elsweyr/elsweyr_base",           x = 0.70, y = 0.20 },
    ["Sunspire (Trial)"]           = { zone = "elsweyr/elsweyr_base",           x = 0.70, y = 0.20 },
    -- High Isle (Dreadsail Reef)
    ["Dreadsail Reef"]             = { zone = "systres/u34_systreszone_base",         x = 0.85, y = 0.15 },
    ["Dreadsail Reef (Trial)"]     = { zone = "systres/u34_systreszone_base",         x = 0.85, y = 0.15 },
    -- Reaper's March (Maw of Lorkhaj)
    ["Maw of Lorkhaj"]             = { zone = "reapersmarch/reapersmarch_base", x = 0.50, y = 0.50 },
    -- Western Skyrim (Kyne's Aegis)
    ["Kyne's Aegis"]               = { zone = "skyrim/westernskryim_base", x = 0.70, y = 0.15 },
    -- Sanity's Edge / Lucent Citadel (West Weald area)
    ["Sanity's Edge"]              = { zone = "westweald/westwealdoverland_base",       x = 0.40, y = 0.50 },
    ["Sanity's Edge (Trial)"]      = { zone = "westweald/westwealdoverland_base",       x = 0.40, y = 0.50 },
    ["Lucent Citadel"]             = { zone = "westweald/westwealdoverland_base",       x = 0.60, y = 0.50 },
    ["Lucent Citadel (Trial)"]     = { zone = "westweald/westwealdoverland_base",       x = 0.60, y = 0.50 },
    -- Blackwood (Rockgrove)
    ["Rockgrove"]                  = { zone = "blackwood/blackwood_base",       x = 0.65, y = 0.35 },
    ["Rockgrove (Trial)"]          = { zone = "blackwood/blackwood_base",       x = 0.65, y = 0.35 },
}
