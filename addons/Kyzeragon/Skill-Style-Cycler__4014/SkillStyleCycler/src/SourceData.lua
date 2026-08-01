SkillStyleCycler = SkillStyleCycler or {}
local SSC = SkillStyleCycler

local CLASS_STYLE_PACK = "This is 1 of 21 styles in the Class Style Pack: Tamriel United bundle, previously available for free (with 2 >L50 characters) in the Crown Store."

local GOLDEN_PURSUIT = "This was available as a reward from a Golden Pursuit campaign."

local NEW_LIFE_STYLES = "This is 1 of 3 styles in the New Life Styles: Winter bundle, previously available for 2500 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store."
local NOCTURNAL_STYLES = "This is 1 of 3 styles in the Nocturnal Styles: Night's Crows bundle, previously available for 2500 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store."

local CARNAVAL_CRATE_LEGENDARY = "This is a Legendary reward from Carnaval Crates, or directly purchased with 100 |t16:16:/esoui/art/currency/crowngem_mipmap.dds|t or 3600 |t16:16:/esoui/art/currency/currency_seals_of_endeavor_64.dds|t."
local CARNAVAL_CRATE_EPIC = "This is an Epic reward from Carnaval Crates, or directly purchased with 40 |t16:16:/esoui/art/currency/crowngem_mipmap.dds|t or 2000 |t16:16:/esoui/art/currency/currency_seals_of_endeavor_64.dds|t."
local AKATOSH_CRATE_LEGENDARY = "This is a Legendary reward from Akatosh vs. Alduin Crates, or directly purchased with 100 |t16:16:/esoui/art/currency/crowngem_mipmap.dds|t or 3600 |t16:16:/esoui/art/currency/currency_seals_of_endeavor_64.dds|t."
local AKATOSH_CRATE_EPIC = "This is an Epic reward from Akatosh vs. Alduin Crates, or directly purchased with 40 |t16:16:/esoui/art/currency/crowngem_mipmap.dds|t or 2000 |t16:16:/esoui/art/currency/currency_seals_of_endeavor_64.dds|t."
local HIDDEN_KINDRED_CRATE_LEGENDARY = "This is a Legendary reward from Hidden Kindred Crates, or directly purchased with 100 |t16:16:/esoui/art/currency/crowngem_mipmap.dds|t or 3600 |t16:16:/esoui/art/currency/currency_seals_of_endeavor_64.dds|t."
local MOONS_OVER_ORSINIUM_CRATE_LEGENDARY = "This is a Legendary reward from Moons Over Orsinium Crates, or directly purchased with 100 |t16:16:/esoui/art/currency/crowngem_mipmap.dds|t or 3600 |t16:16:/esoui/art/currency/currency_seals_of_endeavor_64.dds|t."

-- This is a manual map of where "purchasable" collectibles came from, if known.
-- The intention is to continually update this as more styles are
-- released, because scattered information is annoying, and uncollected
-- crown store styles don't show up in the collectibles menu.
SSC.sourceData = {
-----------------------------
-- CLASS
    [12945] = CLASS_STYLE_PACK, -- Lava Whip, Ice Blue
    [12944] = CLASS_STYLE_PACK, -- Fiery Breath, Ice Blue
    [12943] = CLASS_STYLE_PACK, -- Spiked Armor, Azure Blue
    [13874] = NOCTURNAL_STYLES, -- Dragon Leap, Nocturnal

    [12952] = CLASS_STYLE_PACK, -- Puncturing Strikes, Ice Blue
    [12954] = CLASS_STYLE_PACK, -- Backlash, Ice Blue
    [12953] = CLASS_STYLE_PACK, -- Rushed Ceremony, Azure Blue
    [14027] = MOONS_OVER_ORSINIUM_CRATE_LEGENDARY, -- Puncturing Strikes, Honorfeather

    [12947] = CLASS_STYLE_PACK, -- Death Stroke, Lilac Purple
    [12948] = CLASS_STYLE_PACK, -- Veiled Strike, Lilac Purple
    [12946] = CLASS_STYLE_PACK, -- Assassin's Blade, Lilac Purple
    [14022] = MOONS_OVER_ORSINIUM_CRATE_LEGENDARY, -- Grim Focus, Malacath's Fury

    [13059] = "This was available for 2000 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store.", -- Summon Winged Twilight, Warrior
    [12949] = CLASS_STYLE_PACK, -- Crystal Shard, Ruby Red
    [12951] = CLASS_STYLE_PACK, -- Daedric Curse, Ruby Red
    [12950] = CLASS_STYLE_PACK, -- Lightning Form, Ruby Red

    [1260] = "This is part of the Morrowind Collector's Pack.", -- Slate-Gray Summoned Bear
    [13051] = CLASS_STYLE_PACK, -- Scorch, Blazing Orange
    [13052] = CLASS_STYLE_PACK, -- Fungal Growth, Blazing Orange
    [13053] = CLASS_STYLE_PACK, -- Arctic Wind, Blazing Orange
    [13793] = "This was available for 1800 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store.", -- Feral Guardian, Snow Bear
    [13873] = NOCTURNAL_STYLES, -- Dive, Nocturnal Crow
    [13872] = NOCTURNAL_STYLES, -- Swarm, Murder of Crows

    [13048] = CLASS_STYLE_PACK, -- Frozen Colossus, Carmine Red
    [13115] = CLASS_STYLE_PACK, -- Flame Skull, Onyx and Red
    [13050] = CLASS_STYLE_PACK, -- Death Scythe, Carmine Red

    [13046] = CLASS_STYLE_PACK, -- Runeblades, Azure Blue
    [13045] = CLASS_STYLE_PACK, -- Fatecarver, Soothing Blue
    [13047] = CLASS_STYLE_PACK, -- Runemend, Azure Blue
    [13856] = "This was available for 2000 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store.", -- The Unblinking Eye, Hollowjack
    [14024] = "This was available for 2000 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store.", -- Fatecarver, Aetherius

-----------------------------
-- WEAPON
    [13058] = NEW_LIFE_STYLES, -- Critical Charge, Winter's Gale
    [13056] = NEW_LIFE_STYLES, -- Volley, Winterfall
    [13446] = CARNAVAL_CRATE_LEGENDARY, -- Wall of Elements, Autumn Leaves
    [13447] = CARNAVAL_CRATE_EPIC, -- Whirlwind, Cinnabar Red
    [13455] = "This was available for 500 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store.", -- Low Slash, Ruby Red
    [13883] = HIDDEN_KINDRED_CRATE_LEGENDARY, -- Defensive Posture, Spell Breaker
    [13843] = HIDDEN_KINDRED_CRATE_LEGENDARY, -- Flurry, Peryite
    [13790] = AKATOSH_CRATE_LEGENDARY, -- Volley of the World-Eater
    [13791] = AKATOSH_CRATE_LEGENDARY, -- Shield Charge, Dragonclash
    [13794] = GOLDEN_PURSUIT, -- Blade Cloak, Mirrormoor
    [14025] = "This was available for 1500 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store.", -- Snipe, Sanguine's Rose
    [14335] = "This was available for 1200 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store.", -- Blessing of Protection, Verdant Green

-----------------------------
-- ARMOR

-----------------------------
-- WORLD

-----------------------------
-- GUILD
    [13057] = NEW_LIFE_STYLES, -- Meteor, Winter's Blast
    [13448] = "This was available for 1500 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store.", -- Magelight, Passion Blossom
    [13457] = "This was available for 500 |t16:16:/esoui/art/currency/crowns_mipmap.dds|t in the Crown Store.", -- Dawnbreaker, Vibrant Yellow

-----------------------------
-- ALLIANCE WAR
    [13449] = CARNAVAL_CRATE_LEGENDARY, -- War Horn, Aquatic
    [13460] = CARNAVAL_CRATE_EPIC, -- Vigor, Verdant Green
    [13452] = GOLDEN_PURSUIT, -- Barrier, Verdant Green
}
