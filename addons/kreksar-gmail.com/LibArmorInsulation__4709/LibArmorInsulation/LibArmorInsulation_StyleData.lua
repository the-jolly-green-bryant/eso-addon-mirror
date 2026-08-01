-- LibArmorInsulation_StyleData.lua
-- Insulation data tables for armor styles, outfit styles, costumes, and polymorphs.
--
-- ─────────────────────────────────────────────────────────────────────────────
-- STAGGERED TIER SYSTEM (v2.6.0+)
-- ─────────────────────────────────────────────────────────────────────────────
-- Every style, outfit piece, costume, and polymorph resolves to one of eleven
-- fixed TIER values, staggered in increments of 10 from -10 to 90. This
-- replaces the old free-floating 0-100 continuous scale. See
-- LibArmorInsulation.Data.TIER_VALUES / TierInfo below for the full ladder.
--
--   -10  Magically Cooled        — magically cooled equipment (e.g. refrigeration)
--     0  No Insulation           — no insulation
--    10  Minimal                 — underwear/swimwear
--    20  Light                   — light silks, breathable thin fabrics, or minimal coverage
--    30  Coarse Light            — linens, coarser fabrics, or small amounts of leather with light coverage
--    40  Layered/Leather         — thick or many-layered fabrics, or majority-coverage leathers
--    50  Full Leather/Light Metal — full coverage leathers, mild coverage metals, or full-coverage multi-layered thick fabrics
--    60  Heavy Leather/Fur       — full coverage heavy/thick leathers, mild coverage furs, or moderate coverage metals
--    70  Full Fur/Metal          — full coverage furs or full coverage metals
--    80  Heavy Fur/Metal         — full coverage heavy furs and/or metals
--    90  Magically Heated        — magically heated equipment
--
-- -10 and 90 are reserved for entries explicitly flagged `magical = true`
-- (enchanted/elemental sources — Flame Atronach, Ice Wraith, etc.). Every
-- other entry is clamped to the mundane 0–80 range before being snapped to
-- the nearest tier, so ordinary armor/clothing can never accidentally read
-- as "magically" hot or cold. See Calc.SnapToTier() in the Calculator module.
--
-- HOW AN ENTRY BECOMES A TIER:
--   Armor styles / outfit styles keep their existing baseMaterial + coverage
--   + flavorBonus authoring fields (nothing here needed to be hand-rewritten).
--   The Calculator computes the same full-body reference score it always has
--   (0.90 * coverage * materialCoeff * SCALE_FACTOR + flavorBonus) and then
--   snaps that score onto the nearest tier via Calc.SnapToTier(). Costumes
--   and polymorphs keep their existing hand-authored totalInsulation field,
--   which is likewise snapped to the nearest tier at lookup time.
--
-- PER-SLOT ADJUSTMENT (unless it's a full costume):
--   A style/outfit piece's tier is its FULL-BODY reference value. Individual
--   armor/outfit slots contribute a PERCENTAGE of that tier based on how much
--   of the body they cover (see SlotCoverage / OutfitSlotCoverage below,
--   which now sum to exactly 1.00 across the 7 thermally-relevant slots).
--     slot_contribution = round(tier * slotPercentage)
--     total = sum(slot_contribution for every worn slot)
--   A full matching set (every slot the same tier) reproduces that tier as
--   the total, since the percentages sum to 1.00. Missing slots count as
--   bare skin (tier 0) for that percentage of the body.
--
--   Costumes and polymorphs are NOT slot-adjusted — they represent the whole
--   body at once, so their snapped tier IS the total, unadjusted.
--
-- ─────────────────────────────────────────────────────────────────────────────
-- FULL-SET REFERENCE (coverage=1.0, no flavor bonus) — pre-snap raw scores
-- ─────────────────────────────────────────────────────────────────────────────
--   fur=90  wool=75  heavy_leather=65  leather=50  scale=40  bone/cloth=35
--   chitin/hide=30  iron/steel/silk=25  linen/aetherial=20  daedric=15  crystal=10
-- (each already lands exactly on a tier once snapped, since they're multiples
-- of 5; per-style coverage/flavorBonus modifiers shift the raw score before
-- snapping picks the nearest tier.)
--
-- ─────────────────────────────────────────────────────────────────────────────
-- NOTE ON STYLE TABLE KEYS
-- Keys are the *English* display names returned by GetItemStyleName() in the
-- ESO API.  At initialisation, LibArmorInsulation.Calc.BuildStyleIdMaps() calls
-- GetItemStyleName() for every style ID up to GetHighestItemStyleId() and builds
-- two runtime tables:
--
--   LibArmorInsulation.Data.StyleIdByName  – { ["Breton"] = 1, ["Nord"] = 5, … }
--   LibArmorInsulation.Data.StyleNameById  – { [1] = "Breton", [5] = "Nord", … }
--
-- Lookups in the Calculator always go through those maps, so:
--   • Raw ITEM_STYLE_* integers still flow in from GetItemLinkItemStyle()
--     (that API is unchanged — items carry style IDs, not style names).
--   • The integer is resolved to an English name via StyleNameById.
--   • The name is looked up in Styles[] here.
--
-- This means the data table never needs to change when ZOS reassigns integers
-- between API updates; only the runtime maps (rebuilt automatically) need to
-- reflect the new assignment.
--
-- Override keys in saved variables remain "style_N" (integer-based) because the
-- user picked the style at a specific moment when N meant a specific thing.
-- On load, overrides are resolved through StyleNameById just like any other lookup.
-- ─────────────────────────────────────────────────────────────────────────────

LibArmorInsulation = LibArmorInsulation or {}
LibArmorInsulation.Data = LibArmorInsulation.Data or {}

-- ─────────────────────────────────────────────────────────────────────────────
-- TIER LADDER
-- ─────────────────────────────────────────────────────────────────────────────
-- The eleven fixed insulation tiers. Ordered ascending; every insulation
-- value computed or stored by this addon (styles, outfit pieces, costumes,
-- polymorphs, and user overrides) resolves to one of these.
LibArmorInsulation.Data.TIER_VALUES = { -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90 }

-- Mundane entries (no `magical = true` flag) are clamped to this range before
-- snapping, so -10 and 90 stay reserved for explicitly magical sources.
LibArmorInsulation.Data.MUNDANE_MIN = 0
LibArmorInsulation.Data.MUNDANE_MAX = 80

-- Human-readable label/description per tier, keyed by tier value. Used by the
-- Settings override dropdown and by slash-command output.
LibArmorInsulation.Data.TierInfo = {
    [-10] = { label = "Magically Cooled",         desc = "Magically cooled equipment (e.g. refrigeration)" },
    [0]   = { label = "No Insulation",            desc = "No insulation" },
    [10]  = { label = "Minimal",                  desc = "Underwear/swimwear" },
    [20]  = { label = "Light",                    desc = "Light silks, breathable thin fabrics, or minimal coverage" },
    [30]  = { label = "Coarse Light",             desc = "Linens, coarser fabrics, or small amounts of leather with light coverage" },
    [40]  = { label = "Layered/Leather",          desc = "Thick or many-layered fabrics, or majority-coverage leathers" },
    [50]  = { label = "Full Leather/Light Metal", desc = "Full coverage leathers, mild coverage metals, or full-coverage multi-layered thick fabrics" },
    [60]  = { label = "Heavy Leather/Fur",        desc = "Full coverage heavy/thick leathers, mild coverage furs, or moderate coverage metals" },
    [70]  = { label = "Full Fur/Metal",           desc = "Full coverage furs or full coverage metals" },
    [80]  = { label = "Heavy Fur/Metal",          desc = "Full coverage heavy furs and/or metals" },
    [90]  = { label = "Magically Heated",         desc = "Magically heated equipment" },
}

LibArmorInsulation.Data.SlotCoverage       = {}
LibArmorInsulation.Data.OutfitSlotCoverage = {}

-- Runtime maps populated by LibArmorInsulation.Calc.BuildStyleIdMaps() on
-- EVENT_ADD_ON_LOADED.  Both start empty; callers must not use them before that.
LibArmorInsulation.Data.StyleIdByName = {}   -- ["Breton"] = 1, etc.
LibArmorInsulation.Data.StyleNameById = {}   -- [1] = "Breton", etc.

-- Called once from LibArmorInsulation.lua after EVENT_ADD_ON_LOADED fires,
-- because EQUIP_SLOT_* and OUTFIT_SLOT_* globals are nil at file-load time.
-- SLOT PERCENTAGES (tier system)
-- These now sum to exactly 1.00 across the 7 thermally-relevant body slots
-- (previously summed to 0.90, with a separate SCALE_FACTOR compensating so a
-- full set landed on 50). Under the tier model there is no separate scale
-- factor for slot summation — a slot's contribution is simply its style's
-- tier multiplied by its percentage of total body coverage, so a full
-- matching set reproduces that tier exactly as the total. Relative weights
-- between slots are unchanged from the original SlotCoverage table; each was
-- scaled up by 1/0.90 and rounded to a clean whole percentage.
function LibArmorInsulation.Data.InitSlotTables()
    LibArmorInsulation.Data.SlotCoverage = {
        [EQUIP_SLOT_HEAD]        = 0.11,
        [EQUIP_SLOT_CHEST]       = 0.33,
        [EQUIP_SLOT_LEGS]        = 0.28,
        [EQUIP_SLOT_HAND]        = 0.06,
        [EQUIP_SLOT_FEET]        = 0.06,
        [EQUIP_SLOT_WAIST]       = 0.05,
        [EQUIP_SLOT_SHOULDERS]   = 0.11,
        [EQUIP_SLOT_RING1]       = 0.00,
        [EQUIP_SLOT_RING2]       = 0.00,
        [EQUIP_SLOT_NECK]        = 0.00,
        [EQUIP_SLOT_MAIN_HAND]   = 0.00,
        [EQUIP_SLOT_OFF_HAND]    = 0.00,
        [EQUIP_SLOT_BACKUP_MAIN] = 0.00,
        [EQUIP_SLOT_BACKUP_OFF]  = 0.00,
    }
    -- Gloves = OUTFIT_SLOT_HANDS (plural). OUTFIT_SLOT_COSTUME / POLYMORPH excluded.
    LibArmorInsulation.Data.OutfitSlotCoverage = {
        [OUTFIT_SLOT_HEAD]      = 0.11,
        [OUTFIT_SLOT_CHEST]     = 0.33,
        [OUTFIT_SLOT_LEGS]      = 0.28,
        [OUTFIT_SLOT_HANDS]     = 0.06,
        [OUTFIT_SLOT_FEET]      = 0.06,
        [OUTFIT_SLOT_WAIST]     = 0.05,
        [OUTFIT_SLOT_SHOULDERS] = 0.11,
    }

    -- Canonical slot key -> EQUIP_SLOT_*/OUTFIT_SLOT_* constant. Lets callers
    -- (notably the Settings panel's independent per-layer lookups) go from a
    -- stable string like "chest" straight to the constant needed for
    -- GetItemLink()/GetSlotManipulator(), without needing their own copy of
    -- this mapping or depending on the equipSlotMeta/outfitSlotMeta tables
    -- that are private to the Calculator module. Built here (not at file
    -- scope) for the same reason as SlotCoverage above: EQUIP_SLOT_*/
    -- OUTFIT_SLOT_* globals are nil until EVENT_ADD_ON_LOADED fires.
    LibArmorInsulation.Data.CanonicalSlotOrder = {
        "head", "shoulders", "chest", "hands", "waist", "legs", "feet",
    }
    LibArmorInsulation.Data.EquipSlotByKey = {
        head      = EQUIP_SLOT_HEAD,
        chest     = EQUIP_SLOT_CHEST,
        legs      = EQUIP_SLOT_LEGS,
        hands     = EQUIP_SLOT_HAND,
        feet      = EQUIP_SLOT_FEET,
        waist     = EQUIP_SLOT_WAIST,
        shoulders = EQUIP_SLOT_SHOULDERS,
    }
    LibArmorInsulation.Data.OutfitSlotByKey = {
        head      = OUTFIT_SLOT_HEAD,
        chest     = OUTFIT_SLOT_CHEST,
        legs      = OUTFIT_SLOT_LEGS,
        hands     = OUTFIT_SLOT_HANDS,
        feet      = OUTFIT_SLOT_FEET,
        waist     = OUTFIT_SLOT_WAIST,
        shoulders = OUTFIT_SLOT_SHOULDERS,
    }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MATERIAL COEFFICIENTS
-- ─────────────────────────────────────────────────────────────────────────────
LibArmorInsulation.Data.MaterialCoefficient = {
    ["fur"]           = 1.8,   -- Dense pelts, exceptional cold-weather insulation
    ["wool"]          = 1.5,   -- Thick woven wool, very warm
    ["heavy_leather"] = 1.3,   -- Reinforced multi-layer leather
    ["leather"]       = 1.0,   -- Standard tanned leather (baseline)
    ["scale"]         = 0.8,   -- Interlocked scales over padding
    ["runic"]         = 0.8,   -- Enchanted reinforced material
    ["bone"]          = 0.7,   -- Bone plates over hide backing
    ["cloth"]         = 0.7,   -- Woven fabric
    ["chitin"]        = 0.6,   -- Insect chitin with thin hide backing
    ["hide"]          = 0.6,   -- Thin raw-hide wraps
    ["iron"]          = 0.5,   -- Cold metal, poor without padding
    ["steel"]         = 0.5,   -- Polished steel, conducts cold
    ["silk"]          = 0.5,   -- Thin luxurious cloth
    ["linen"]         = 0.4,   -- Light breathable cloth
    ["aetherial"]     = 0.4,   -- Partially ethereal, reduced thermal mass
    ["daedric"]       = 0.3,   -- Emanates unnatural cold/heat
    ["crystal"]       = 0.2,   -- Magically resonant but thermally inert
    ["none"]          = 0.0,   -- No material
}

-- ─────────────────────────────────────────────────────────────────────────────
-- ARMOR STYLE DATABASE
-- Keys are the English GetItemStyleName() strings, which are stable across
-- API updates even when the underlying integer IDs are reassigned.
--
-- [styleName] = { baseMaterial, coverage, flavorBonus (integer), flavorNote }
--   baseMaterial : key into MaterialCoefficient table above
--   coverage     : style-level modifier (1.0=normal; >1.0=extra layers; <1.0=sparse)
--   flavorBonus  : flat integer added to total after scaling (range typically -10..+10)
-- ─────────────────────────────────────────────────────────────────────────────
LibArmorInsulation.Data.Styles = {

    ["DEFAULT"] = { baseMaterial="leather", coverage=1.0, flavorBonus=0, flavorNote="" },

    -- ── Base racial styles ──────────────────────────────────────────────────
    -- Names match GetItemStyleName() output for IDs 1–10 on EN clients.
    ["Breton"]    = { baseMaterial="leather", coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Redguard"]  = { baseMaterial="leather", coverage=0.9,  flavorBonus=-3, flavorNote="Open desert construction, poor in cold" },
    ["Orc"]       = { baseMaterial="iron",    coverage=1.1,  flavorBonus= 0, flavorNote="" },
    ["Dark Elf"]  = { baseMaterial="scale",   coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Nord"]      = { baseMaterial="fur",     coverage=1.1,  flavorBonus= 8, flavorNote="Crafted to endure the bitter winds of Skyrim" },
    ["High Elf"]  = { baseMaterial="steel",   coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Wood Elf"]  = { baseMaterial="cloth",   coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Khajiit"]   = { baseMaterial="hide",    coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Argonian"]  = { baseMaterial="chitin",  coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Imperial"]  = { baseMaterial="steel",   coverage=1.0,  flavorBonus= 0, flavorNote="" },

    -- ── Crafting Motifs (Motifs 11–129) ────────────────────────────────────
    -- Each name matches the English string returned by GetItemStyleName() for
    -- that motif's StyleItemIndex.  If ZOS renames a style in a future patch,
    -- update the key here and the runtime maps handle the ID side automatically.
    ["Ancient Elf"]           = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Barbaric"]              = { baseMaterial="hide",          coverage=0.7,  flavorBonus= 0, flavorNote="" },
    ["Primal"]                = { baseMaterial="bone",          coverage=0.7,  flavorBonus= 0, flavorNote="" },
    ["Daedric"]               = { baseMaterial="daedric",       coverage=0.9,  flavorBonus=-10, flavorNote="Radiates unnatural cold into the wearer's bones" },
    ["Dwemer"]                = { baseMaterial="iron",          coverage=1.0,  flavorBonus= 5, flavorNote="Internal heat vents maintain a steady warmth" },
    ["Glass"]                 = { baseMaterial="crystal",       coverage=0.8,  flavorBonus= 0, flavorNote="" },
    ["Xivkyn"]                = { baseMaterial="daedric",       coverage=1.0,  flavorBonus=-5, flavorNote="Infused with cold Oblivion energy" },
    ["Akaviri"]               = { baseMaterial="scale",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Mercenary"]             = { baseMaterial="leather",       coverage=1.05, flavorBonus= 2, flavorNote="Practical layered construction for road travel" },
    ["Yokudan"]               = { baseMaterial="wool",          coverage=1.1,  flavorBonus= 5, flavorNote="Ancient Hammerfell layered wool padding" },
    ["Ancient Orc"]           = { baseMaterial="iron",          coverage=1.1,  flavorBonus= 0, flavorNote="" },
    ["Trinimac"]              = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 3, flavorNote="Blessed with Trinimac's warmth" },
    ["Malacath"]              = { baseMaterial="bone",          coverage=0.8,  flavorBonus= 0, flavorNote="" },
    ["Outlaw"]                = { baseMaterial="hide",          coverage=0.8,  flavorBonus= 0, flavorNote="" },
    ["Aldmeri Dominion"]      = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Daggerfall Covenant"]   = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Ebonheart Pact"]        = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Ra Gada"]               = { baseMaterial="leather",       coverage=0.8,  flavorBonus=-5, flavorNote="Designed to vent desert heat, poor in cold" },
    ["Soul-Shriven"]          = { baseMaterial="linen",         coverage=0.5,  flavorBonus= 0, flavorNote="" },
    ["Morag Tong"]            = { baseMaterial="silk",          coverage=0.85, flavorBonus= 0, flavorNote="" },
    ["Skinchanger"]           = { baseMaterial="fur",           coverage=1.2,  flavorBonus=10, flavorNote="Woven with warm pelts of the northern beasts" },
    ["Abah's Watch"]          = { baseMaterial="leather",       coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Thieves Guild"]         = { baseMaterial="leather",       coverage=0.85, flavorBonus= 0, flavorNote="" },
    ["Assassins League"]      = { baseMaterial="silk",          coverage=0.85, flavorBonus= 0, flavorNote="" },
    ["Dro-m'Athra"]           = { baseMaterial="hide",          coverage=0.9,  flavorBonus=-5, flavorNote="Carries the chill of the Bent-Dance" },
    ["Dark Brotherhood"]      = { baseMaterial="leather",       coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Ebony"]                 = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Draugr"]                = { baseMaterial="bone",          coverage=0.8,  flavorBonus=-5, flavorNote="Carries the chill of Sovngarde's halls" },
    ["Minotaur"]              = { baseMaterial="hide",          coverage=1.05, flavorBonus= 3, flavorNote="Dense layered hide from the Minotaur tribes" },
    ["Order of the Hour"]     = { baseMaterial="steel",         coverage=1.1,  flavorBonus= 3, flavorNote="Blessed with Akatosh's warmth" },
    ["Celestial"]             = { baseMaterial="aetherial",     coverage=0.9,  flavorBonus= 2, flavorNote="Star-touched aetherial weave" },
    ["Hollowjack"]            = { baseMaterial="bone",          coverage=0.8,  flavorBonus= 0, flavorNote="" },
    ["Grim Harlequin"]        = { baseMaterial="silk",          coverage=0.8,  flavorBonus= 0, flavorNote="" },
    ["Silken Ring"]           = { baseMaterial="silk",          coverage=0.75, flavorBonus= 0, flavorNote="" },
    ["Mazzatun"]              = { baseMaterial="chitin",        coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Stalhrim Frostcaster"]  = { baseMaterial="crystal",       coverage=1.0,  flavorBonus=-8, flavorNote="Stalhrim plates actively radiate cold" },
    ["Buoyant Armiger"]       = { baseMaterial="leather",       coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Ashlander"]             = { baseMaterial="hide",          coverage=0.75, flavorBonus= 0, flavorNote="" },
    ["Militant Ordinator"]    = { baseMaterial="steel",         coverage=1.05, flavorBonus= 0, flavorNote="" },
    ["Telvanni"]              = { baseMaterial="cloth",         coverage=0.9,  flavorBonus= 5, flavorNote="Mushroom-fiber lining retains body warmth" },
    ["Hlaalu"]                = { baseMaterial="cloth",         coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Redoran"]               = { baseMaterial="chitin",        coverage=1.05, flavorBonus= 0, flavorNote="" },
    ["Tsaesci"]               = { baseMaterial="silk",          coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Bloodforge"]            = { baseMaterial="iron",          coverage=1.05, flavorBonus= 2, flavorNote="Blood-infused metal retains body heat" },
    ["Dreadhorn"]             = { baseMaterial="bone",          coverage=1.0,  flavorBonus= 2, flavorNote="Thick Dreadhorn minotaur hide backing" },
    ["Apostle"]               = { baseMaterial="iron",          coverage=1.0,  flavorBonus= 6, flavorNote="Mechanically-assisted temperature regulation" },
    ["Ebonshadow"]            = { baseMaterial="cloth",         coverage=0.8,  flavorBonus=-3, flavorNote="Shadow-woven cloth carries a chill" },
    ["Fang Lair"]             = { baseMaterial="bone",          coverage=0.9,  flavorBonus=-8, flavorNote="Dragon bones carry the cold of death" },
    ["Scalecaller"]           = { baseMaterial="scale",         coverage=1.0,  flavorBonus=-5, flavorNote="Venom-treated scales lower surface temperature" },
    ["Worm Cult"]             = { baseMaterial="linen",         coverage=0.8,  flavorBonus=-3, flavorNote="Necrotic wrappings carry the cold of undeath" },
    ["Psijic"]                = { baseMaterial="aetherial",     coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Sapiarch"]              = { baseMaterial="cloth",         coverage=1.0,  flavorBonus= 3, flavorNote="Layered Altmeri scholarly construction" },
    ["Dremora"]               = { baseMaterial="daedric",       coverage=1.0,  flavorBonus=-8, flavorNote="Emanates the consuming cold of Coldharbour" },
    ["Pyandonean"]            = { baseMaterial="scale",         coverage=0.95, flavorBonus= 0, flavorNote="" },
    ["Huntsman"]              = { baseMaterial="leather",       coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Silver Dawn"]           = { baseMaterial="heavy_leather", coverage=1.1,  flavorBonus= 3, flavorNote="" },
    ["Welkynar"]              = { baseMaterial="leather",       coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Honor Guard"]           = { baseMaterial="steel",         coverage=1.1,  flavorBonus= 2, flavorNote="Heavy Imperial ceremonial plate" },
    ["Dead-Water"]            = { baseMaterial="heavy_leather", coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Elder Argonian"]        = { baseMaterial="chitin",        coverage=1.05, flavorBonus= 0, flavorNote="" },
    ["Coldsnap"]              = { baseMaterial="wool",          coverage=1.2,  flavorBonus=10, flavorNote="Specially constructed to resist northern coldsnap gales" },
    ["Meridian"]              = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 5, flavorNote="Meridia's light infuses the armor with gentle warmth" },
    ["Anequina"]              = { baseMaterial="leather",       coverage=0.85, flavorBonus=-3, flavorNote="Open desert Elsweyr construction, vents heat" },
    ["Pellitine"]             = { baseMaterial="silk",          coverage=0.85, flavorBonus= 0, flavorNote="" },
    ["Sunspire"]              = { baseMaterial="steel",         coverage=1.0,  flavorBonus=-2, flavorNote="Frost Ember accents lend a slight chill" },
    ["Dragonguard"]           = { baseMaterial="heavy_leather", coverage=1.05, flavorBonus= 2, flavorNote="Dragon-scale reinforced Dragonguard construction" },
    ["Stags of Z'en"]         = { baseMaterial="cloth",         coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Moongrave Fane"]        = { baseMaterial="scale",         coverage=1.0,  flavorBonus=-3, flavorNote="Blood-ritual construction carries an unnatural chill" },
    ["Refabricated"]          = { baseMaterial="iron",          coverage=1.0,  flavorBonus= 4, flavorNote="Clockwork City composite, temperature-regulated" },
    ["Shield of Senchal"]     = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["New Moon Priest"]       = { baseMaterial="bone",          coverage=0.9,  flavorBonus=-4, flavorNote="Cult construction carries a draconic chill" },
    ["Icereach Coven"]        = { baseMaterial="fur",           coverage=1.1,  flavorBonus= 6, flavorNote="Hagraven fur-woven ritual construction" },
    ["Pyre Watch"]            = { baseMaterial="heavy_leather", coverage=1.0,  flavorBonus= 5, flavorNote="Fire-tempered treatment provides insulating char layer" },
    ["Blackreach Vanguard"]   = { baseMaterial="chitin",        coverage=1.0,  flavorBonus= 2, flavorNote="Deep-earth chitin provides surprising warmth" },
    ["Greymoor"]              = { baseMaterial="leather",       coverage=1.0,  flavorBonus=-3, flavorNote="Vampire-gothic styling carries a chill" },
    ["Sea Giant"]             = { baseMaterial="heavy_leather", coverage=1.15, flavorBonus= 2, flavorNote="Dense sea-giant hide construction" },
    ["Ancestral Nord"]        = { baseMaterial="fur",           coverage=1.15, flavorBonus= 8, flavorNote="Thick fur trim against Skyrim's cold" },
    ["Ancestral Orc"]         = { baseMaterial="iron",          coverage=1.05, flavorBonus= 0, flavorNote="" },
    ["Ancestral High Elf"]    = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Thorn Legion"]          = { baseMaterial="steel",         coverage=1.0,  flavorBonus=-5, flavorNote="Vampire-forged steel remains unnaturally cold" },
    ["Hazardous Alchemy"]     = { baseMaterial="leather",       coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Ancestral Akaviri"]     = { baseMaterial="scale",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Ancestral Breton"]      = { baseMaterial="leather",       coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Ancestral Reach"]       = { baseMaterial="hide",          coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Nighthollow"]           = { baseMaterial="cloth",         coverage=0.8,  flavorBonus=-5, flavorNote="Shadow-umbral cloth bleeds warmth away" },
    ["Arkthzand Armory"]      = { baseMaterial="iron",          coverage=1.05, flavorBonus= 4, flavorNote="Dwemer-engineered thermal plating" },
    ["Wayward Guardian"]      = { baseMaterial="leather",       coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["House Hexos"]           = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Waking Flame"]          = { baseMaterial="leather",       coverage=1.0,  flavorBonus=-2, flavorNote="Deadlands-tinged construction carries a mild chill" },
    ["True-Sworn"]            = { baseMaterial="daedric",       coverage=1.0,  flavorBonus=-6, flavorNote="Mehrunes Dagon's service leaves armour cold as Oblivion" },
    ["Ivory Brigade"]         = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Sul-Xan"]               = { baseMaterial="chitin",        coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Black Fin Legion"]      = { baseMaterial="scale",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Ancient Daedric"]       = { baseMaterial="daedric",       coverage=1.0,  flavorBonus=-10, flavorNote="Ancient Daedric construction bleeds unnatural cold" },
    ["Crimson Oath"]          = { baseMaterial="iron",          coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Silver Rose"]           = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 2, flavorNote="Finely crafted plate with polished engraving" },
    ["Annihilarch's Chosen"]  = { baseMaterial="daedric",       coverage=1.0,  flavorBonus=-7, flavorNote="Deadlands prism-infused armour radiates chill" },
    ["Fargrave Guardian"]     = { baseMaterial="cloth",         coverage=0.95, flavorBonus=-2, flavorNote="Oblivion market construction, mildly cold" },
    ["Dreadsails"]            = { baseMaterial="leather",       coverage=0.95, flavorBonus= 0, flavorNote="" },
    ["Ascendant Order"]       = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Syrbanic Marine"]       = { baseMaterial="scale",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Steadfast Society"]     = { baseMaterial="heavy_leather", coverage=1.0,  flavorBonus= 3, flavorNote="Holy order construction, Stendarr-blessed" },
    ["Systres Guardian"]      = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Y'ffre's Will"]         = { baseMaterial="cloth",         coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Drowned Mariner"]       = { baseMaterial="leather",       coverage=0.9,  flavorBonus=-2, flavorNote="Saltwater treatment makes this armour clammy" },
    ["Firesong"]              = { baseMaterial="cloth",         coverage=1.0,  flavorBonus= 4, flavorNote="Druidic firesong warmth woven into the cloth" },
    ["House Mornard"]         = { baseMaterial="cloth",         coverage=0.9,  flavorBonus= 0, flavorNote="" },
    ["Blessed Inheritor"]     = { baseMaterial="leather",       coverage=1.0,  flavorBonus= 0, flavorNote="" },
    ["Scribes of Mora"]       = { baseMaterial="aetherial",     coverage=0.85, flavorBonus= 0, flavorNote="" },
    ["Clan Dreamcarver"]      = { baseMaterial="hide",          coverage=0.9,  flavorBonus=-3, flavorNote="Daedric-oil treatment chills the hide" },
    ["Dead Keeper"]           = { baseMaterial="linen",         coverage=0.8,  flavorBonus=-4, flavorNote="Funerary wrappings retain the cold of interment" },
    ["Kindred's Concord"]     = { baseMaterial="cloth",         coverage=0.9,  flavorBonus=-2, flavorNote="Apocrypha dreamcloth carries an eldritch chill" },
    ["The Recollection"]      = { baseMaterial="leather",       coverage=0.95, flavorBonus= 0, flavorNote="" },
    ["Blind Path Cultist"]    = { baseMaterial="cloth",         coverage=0.9,  flavorBonus=-4, flavorNote="Mirrormoor shards bleed otherworldly cold" },
    ["Shardborn"]             = { baseMaterial="crystal",       coverage=0.9,  flavorBonus=-3, flavorNote="Obliviate lacquer makes this armour thermally inert" },
    ["West Weald Legion"]     = { baseMaterial="steel",         coverage=1.05, flavorBonus= 2, flavorNote="Heavy Weald Legion ceremonial plate" },
    ["Lucent Sentinel"]       = { baseMaterial="aetherial",     coverage=0.85, flavorBonus= 0, flavorNote="" },
    ["Hircine Bloodhunter"]   = { baseMaterial="fur",           coverage=1.1,  flavorBonus= 7, flavorNote="Hircine-blessed pelt construction, hunter's warmth" },

    -- ── Outfit-Style-only motifs (account-wide Crown Crate/Collector's Edition
    -- unlocks, not found as crafting motif books) — added to extend coverage
    -- via the Styles[name] fallback in GetOutfitStyleData(). Sourced from UESP
    -- "Online:Styles" and individual style pages; several explicitly resemble
    -- an existing entry above, in which case the same material/coverage was
    -- reused for consistency.
    ["Swordthane"]            = { baseMaterial="heavy_leather", coverage=1.0,  flavorBonus= 3, flavorNote="Western Skyrim thane's regalia, Greymoor Collector's Edition exclusive" },
    ["Dark Executioner"]      = { baseMaterial="leather",       coverage=0.9,  flavorBonus= 0, flavorNote="Signature style explicitly resembling Dark Brotherhood armor (internally called Void-Kissed)" },
    ["Necrom Armiger"]        = { baseMaterial="leather",       coverage=1.0,  flavorBonus= 0, flavorNote="Signature style explicitly resembling Buoyant Armiger armor from Necrom" },
    ["Order of the Lamp"]     = { baseMaterial="steel",         coverage=1.0,  flavorBonus= 2, flavorNote="Signature style resembling the armor of Mages Guild Lamp Knights" },
    ["Ancient Mirrormoor"]    = { baseMaterial="crystal",       coverage=0.9,  flavorBonus=-3, flavorNote="Themed after the eldritch Mirrormoor realm; mirror-shard cold per Blind Path Cultist precedent" },
    ["Companion Revelry"]     = { baseMaterial="leather",       coverage=1.0,  flavorBonus= 0, flavorNote="10th Anniversary commemorative style honoring the five Companions" },
    ["Fharun Moonlight"]      = { baseMaterial="iron",          coverage=1.0,  flavorBonus=-2, flavorNote="Orcish moonlit-themed style from Moons Over Orsinium Crates" },
    ["Chosen of Anu"]         = { baseMaterial="aetherial",     coverage=0.9,  flavorBonus= 3, flavorNote="Aedric order/stasis cosmic-duality theme; Anu vs. Padomay Crates" },
    ["Chosen of Padomay"]     = { baseMaterial="daedric",       coverage=0.9,  flavorBonus=-3, flavorNote="Daedric chaos/change cosmic-duality theme; Anu vs. Padomay Crates" },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- COSTUME DATA  (flat integer 0–100 authoring scale, pre-snap; costume covers
-- the entire body — snapped onto the nearest tier at lookup time via
-- Calc.SnapToTier(), see the tier system overview at the top of this file)
-- Lookup: CostumeInsulationById first, then CostumeInsulation by name, then DEFAULT_COSTUME.
-- Name keys: lowercase, spaces normalised.
--
-- Scale reference for costumes:
--    0 = body of ice / completely exposed
--   10 = swimwear / near-nothing
--   20 = dancer's silks / minimal coverage
--   35 = light dress / summer wear
--   50 = neutral — everyday clothing, standard armor equivalent
--   58 = heavy winter wear / wool layers
--   65 = dense fur lining / northern ceremonial robes
--   78 = werewolf form — dense pelt + elevated body heat
--   92 = flame atronach — body of living fire
-- ─────────────────────────────────────────────────────────────────────────────
LibArmorInsulation.Data.CostumeInsulation = {
    ["DEFAULT_COSTUME"]             = { totalInsulation=50, flavorNote="" },

    ["ancestral nordic ceremonial"] = { totalInsulation=68, flavorNote="Heavy ceremonial robes of the ancient Nords" },
    ["fur-lined traveler's garb"]   = { totalInsulation=62, flavorNote="Lined with dense northern fur" },
    ["stormcloak officer"]          = { totalInsulation=58, flavorNote="Sturdy wool and leather, northern cut" },
    ["psijic order robe"]           = { totalInsulation=52, flavorNote="Aetherial weave provides moderate warmth" },
    ["undaunted aspirant"]          = { totalInsulation=50, flavorNote="" },
    ["witchmother's servant"]       = { totalInsulation=40, flavorNote="" },

    ["senche"]                      = { totalInsulation=50, flavorNote="Dense short fur covering" },
    ["guar"]                        = { totalInsulation=35, flavorNote="Thick hide, but cold-blooded" },
    ["welwa ravager"]               = { totalInsulation=25, flavorNote="Short fur, lean build" },
    ["dwarven spider"]              = { totalInsulation=15, flavorNote="Metal exoskeleton conducts cold efficiently" },

    ["flame atronach"]              = { totalInsulation=92, flavorNote="Body of living fire — extreme warmth", magical=true },
    ["storm atronach"]              = { totalInsulation=10, flavorNote="Elemental form provides no thermal protection" },
    ["frost atronach"]              = { totalInsulation=-10, flavorNote="Body of living frost actively leeches warmth", magical=true },
    ["indrik"]                      = { totalInsulation=18, flavorNote="Spectral form has limited physical thermal mass" },
    ["wormmouth"]                   = { totalInsulation=20, flavorNote="" },

    ["skeleton costume"]            = { totalInsulation= 5, flavorNote="No insulating material; bones offer no warmth" },
    ["hollowjack scarecrow"]        = { totalInsulation=12, flavorNote="Hollow gourd and thin cloth wrap" },

    -- ── Manually-sourced costume entries (UESP-derived, name-keyed) ──────────
    -- Added via UESP search-snippet research; confidence noted per entry.
    -- high = explicit material stated in source text
    -- medium = strong contextual/regional inference
    -- low = thematic guess with no explicit material cue (candidate for
    --       UESP re-verification or letting /scancostumes override instead)
    ["abah's watch full armor"] = { totalInsulation=50, flavorNote="Hew's Bane desert pirate-town guard armor; no strong thermal cues in description [confidence: medium]" },
    ["abah's watch night patrol"] = { totalInsulation=50, flavorNote="Same Abah's Watch armor set worn for night patrol duty; desert climate [confidence: medium]" },
    ["abah's watch pursuit suit"] = { totalInsulation=36, flavorNote="Lightweight desert-heat patrol gear explicitly worn to vent daytime heat [confidence: medium]" },
    ["abecean privateer's apparel"] = { totalInsulation=48, flavorNote="Nautical pirate outfit with leather boots; mild damp-sea discount applied [confidence: medium]" },
    ["oblivion explorer garb"] = { totalInsulation=48, flavorNote="Quest-reward explorer gear with leather gloves and panels; no thermal lore cues [confidence: medium]" },
    ["old orsinium sentry"] = { totalInsulation=100, flavorNote="CORRECTION: explicit text reads \"a mix of metal and leather melded with the hide of a great black bear\"; supersedes chunk_01's unverified heavy_leather guess; raw value 103 clamped to 100 [confidence: high]" },
    ["orc wise woman's vestment"] = { totalInsulation=55, flavorNote="Ceremonial gilt-broidered vestment worn by an Orc Wise Woman; ceremonial ware [confidence: low]" },
    ["orcish scout armor"] = { totalInsulation=68, flavorNote="Mountain-scout armor styled after Skyrim/High Rock scouts; cold-climate use [confidence: low]" },
    ["servant's outfit"] = { totalInsulation=32, flavorNote="Plain servant clothing from Hew's Bane (desert climate) [confidence: low]" },
    ["servant's robes"] = { totalInsulation=32, flavorNote="Servant robes from Stros M'Kai (tropical island climate) [confidence: low]" },
    ["seventh legion armor"] = { totalInsulation=28, flavorNote="Imperial legionary armor worn at Hallin's Stand in Bangkorai [confidence: medium]" },
    ["sea viper armor"] = { totalInsulation=50, flavorNote="Ancient Elf style armor worn by pirate crews allied with the Veiled Heritance in temperate Greenshade [confidence: medium]" },
    ["seasworn navigator"] = { totalInsulation=34, flavorNote="Lightweight sailor's outfit with beaded turban and sandals; warm-climate sea wear [confidence: medium]" },
    ["wandering brewer"] = { totalInsulation=55, flavorNote="Nord-themed brewer's outfit; moderate northern-climate construction [confidence: low]" },
    ["whisperweft gala wear"] = { totalInsulation=24, flavorNote="Redguard formal gala dress; fine lightweight fabric [confidence: medium]" },
    ["windcaller garb"] = { totalInsulation=80, flavorNote="Skaal shaman garb from arctic Solstheim; thick cold-weather construction implied [confidence: medium]" },
    ["black hand robe"] = { totalInsulation=39, flavorNote="Dark Brotherhood Black Hand ceremonial robe; no thermal lore cues [confidence: low]" },
    ["cavalier of the sworn oath"] = { totalInsulation=90, flavorNote="Metal and leather melded with great snow bear hide [confidence: high]" },
    ["merchant lord's formal regalia"] = { totalInsulation=24, flavorNote="Wealthy merchant lord's formal event finery from Abah's Landing [confidence: low]" },
    ["dark seducer"] = { totalInsulation=14, flavorNote="Daedric-realm regal costume tied to Sheogorath's Shivering Isles [confidence: low]" },
    ["battlemage tribune armor"] = { totalInsulation=28, flavorNote="Imperial Battlemage Tribune field armor; metal-armor styling explicitly described [confidence: medium]" },
    ["bazaar bargain hunter"] = { totalInsulation=35, flavorNote="Khajiit costume; multiple colorful fabric layers (purple/white/orange) explicitly described [confidence: medium]" },
    ["baker"] = { totalInsulation=33, flavorNote="Practical baker's apron-and-clothing outfit; no thermal lore cues [confidence: low]" },
    ["barbarian"] = { totalInsulation=33, flavorNote="Generic savage tribal outfit; no explicit material given; inferred from theme [confidence: low]" },
    ["bardic tavern-singer's dress"] = { totalInsulation=24, flavorNote="Free-swinging layered tavern performance dress; light formal wear [confidence: low]" },
    ["desert garden gala overdress"] = { totalInsulation=24, flavorNote="Redguard elegant overdress explicitly worn in desert sandstorm conditions [confidence: medium]" },
    ["vampire lord (costume)"] = { totalInsulation=33, flavorNote="Sleek dark vampiric apparel; mild cold discount applied for consistency with existing Vampire Lord polymorph entry (18) [confidence: medium]" },
    ["singing skald"] = { totalInsulation=24, flavorNote="Flashy bardic performance regalia; no explicit thermal cues [confidence: low]" },
    ["strid river fisherfolk"] = { totalInsulation=33, flavorNote="Rugged fisherfolk garb from Gold Road's Strid River region; practical outdoor work gear [confidence: medium]" },
    ["city isle tunic dress"] = { totalInsulation=24, flavorNote="Elegant Imperial Second-Empire-styled tunic dress; light formal wear [confidence: low]" },
    ["classic ordinator armor"] = { totalInsulation=28, flavorNote="Dark-gold metal armor of Tribunal Ordinators in Morrowind [confidence: medium]" },
    ["carnaval celebrant"] = { totalInsulation=24, flavorNote="Scarlet-adorned festive dance outfit from Carnaval Crown Crates [confidence: low]" },
    ["carnaval feathered dancing dress"] = { totalInsulation=22, flavorNote="Very light dance outfit with plush feathers; explicitly airy/buoyant theme [confidence: medium]" },
    ["dar-m'athra stealth outfit"] = { totalInsulation=50, flavorNote="Explicitly described as Dro-m'Athra style medium armor [confidence: high]" },
    ["do-m'athra battle armor"] = { totalInsulation=65, flavorNote="Explicitly described as Dro-m'Athra style heavy armor [confidence: high]" },
    ["jo-m'athra spellcaster suit"] = { totalInsulation=39, flavorNote="Explicitly described as Dro-m'Athra style light armor [confidence: high]" },
    ["vampire noble"] = { totalInsulation=33, flavorNote="Sleek dark vampiric coat ensemble; cold discount applied for consistency with Vampire Lord polymorph (18) and Vampire Lord costume [confidence: medium]" },
    ["dark passions regalia"] = { totalInsulation=50, flavorNote="Seductive ensemble with explicit brown leather straps and trim [confidence: high]" },
    ["thrafey debutante gown"] = { totalInsulation=40, flavorNote="Crafted from Scaly Cloth Scraps Fragments — explicit scale-cloth hybrid material [confidence: high]" },
    ["anchorwright raiment"] = { totalInsulation=22, flavorNote="Chain-embellished protective gear worn by Molag Bal's Dark Anchor workers; heat-exposure flavor bonus applied [confidence: medium]" },
    ["court of bedlam"] = { totalInsulation=28, flavorNote="Masked golden-toned Daedric plate armor worn by Auroran-aligned cultists [confidence: medium]" },
    ["daggerfall paladin"] = { totalInsulation=30, flavorNote="Breton holy-knight armor; mild blessed-warmth flavor bonus [confidence: medium]" },
    ["doeskin-and-chamois woods wear"] = { totalInsulation=28, flavorNote="Explicitly described as a light doeskin-and-chamois outfit [confidence: high]" },
    ["dark eliminator's garb"] = { totalInsulation=45, flavorNote="Dark Brotherhood eliminator's distinctive hunting garb; light leather construction implied [confidence: medium]" },
    ["courier's costume"] = { totalInsulation=50, flavorNote="Explicitly described as a studded leather doublet [confidence: high]" },
    ["eternity tunic with pants"] = { totalInsulation=39, flavorNote="Modern Orc fashion tunic and pants set; no explicit thermal material cues [confidence: low]" },
    ["eveli's adventuring leathers"] = { totalInsulation=50, flavorNote="Explicitly described as supple leather adventuring gear [confidence: high]" },
    ["evening dress"] = { totalInsulation=24, flavorNote="Casual evening-wear dress for marketplace or tavern [confidence: low]" },
    ["east skyrim scout outfit"] = { totalInsulation=68, flavorNote="Scout armor of Eastern Skyrim's cold holds (the Rift; Eastmarch; Winterhold) [confidence: medium]" },
    ["elder council tunic and sash"] = { totalInsulation=35, flavorNote="Simple stylish tunic and sash designed to display tattoos and markings [confidence: low]" },
    ["blacksmith"] = { totalInsulation=46, flavorNote="Explicitly described as a heavy leather smith's apron and gauntlets [confidence: high]" },
    ["voldsea arvel's ashland attire"] = { totalInsulation=39, flavorNote="Outer layers explicitly woven from kresh fiber (a Morrowind cloth fiber) [confidence: medium]" },
    ["fighters guild combat armor"] = { totalInsulation=50, flavorNote="Standard Fighters Guild combat uniform; no thermal distinction in name [confidence: medium]" },
    ["fighters guild cool-weather gear"] = { totalInsulation=88, flavorNote="Explicitly named for cool-weather use — high insulation by design [confidence: high]" },
    ["fighters guild warm-weather gear"] = { totalInsulation=17, flavorNote="Explicitly named for warm-weather use — low insulation by design [confidence: high]" },
    ["falkreath thane"] = { totalInsulation=68, flavorNote="Nord chieftain's kilted jerkin and horned helmet from Falkreath (Skyrim cold region) [confidence: medium]" },
    ["fire drakes outfit"] = { totalInsulation=50, flavorNote="Battlegrounds team-branded combat outfit; draconic theme is cosmetic naming only [confidence: low]" },
    ["fisherfolk work wear"] = { totalInsulation=30, flavorNote="Practical fisherfolk work clothing for hauling nets [confidence: low]" },
    ["pit daemon outfit"] = { totalInsulation=50, flavorNote="Battlegrounds team-branded combat outfit; infernal theme is cosmetic naming only [confidence: low]" },
    ["priestess of mara vestments"] = { totalInsulation=55, flavorNote="Ceremonial holy vestments of Mara's priesthood [confidence: low]" },
    ["alliance rider outfit"] = { totalInsulation=50, flavorNote="Heraldic Alliance-branded rider outfit; no explicit material given [confidence: low]" },
    ["passion dancer's attire"] = { totalInsulation=24, flavorNote="Light dance attire with decorative leather vine accents on legs and neck (accent only; not structural) [confidence: low]" },
    ["greenspeaker's garb"] = { totalInsulation=35, flavorNote="Bosmer nature-themed costume with antler embellishments [confidence: low]" },
    ["garb of grinning horrors"] = { totalInsulation=35, flavorNote="Fiendish jester garment worn for Jester's Festival or Daedric encounters [confidence: low]" },
    ["gem prospector"] = { totalInsulation=46, flavorNote="Explicitly described as crafted from sturdy materials for mining work [confidence: medium]" },
    ["glenmoril witch robes"] = { totalInsulation=42, flavorNote="Bosmer/Hircine-aligned witch coven robes from the cold Western Skyrim region [confidence: medium]" },
    ["golden saint"] = { totalInsulation=28, flavorNote="Golden Daedric-aligned armored form in Sheogorath's service [confidence: medium]" },
    ["graht-climber outfit"] = { totalInsulation=24, flavorNote="Light halter-and-skirt outfit for everyday Wood Elf wear [confidence: low]" },
    ["siegemaster's uniform"] = { totalInsulation=50, flavorNote="Cyrodiil siege engineer's uniform; no explicit thermal cues [confidence: low]" },
    ["hakoshae festival attire"] = { totalInsulation=35, flavorNote="Festival celebration attire; no explicit thermal cues [confidence: low]" },
    ["hands of almalexia armor"] = { totalInsulation=28, flavorNote="Distinctive white-and-blue elite Ordinator armor guarding Mother Morrowind [confidence: medium]" },
    ["high rock pioneer outfit"] = { totalInsulation=50, flavorNote="Breton frontier pioneer outfit from temperate High Rock [confidence: low]" },
    ["highborn jarl's dress"] = { totalInsulation=30, flavorNote="Exquisite tailored gown for Skyrim/Bleakrock jarls; mild noble-warmth bonus [confidence: low]" },
    ["arena gladiator"] = { totalInsulation=39, flavorNote="Heavy gladiator armor explicitly noted to have significant gaps for crowd appeal [confidence: medium]" },
    ["skald's damask jerkin"] = { totalInsulation=31, flavorNote="Explicitly a damask-twill jerkin worn by Skyrim skalds; advertised as needing a separate warm tunic underneath [confidence: high]" },
    ["sisei flowering dress"] = { totalInsulation=24, flavorNote="Argonian springtime festival dress; colorful and light [confidence: low]" },
    ["sixth house robe"] = { totalInsulation=35, flavorNote="Forbidden Morrowind cult robe assembled from seven collected parts [confidence: low]" },
    ["stillrise ritecaller"] = { totalInsulation=35, flavorNote="Garb of Ideal Masters-aligned ritecasters from Stillrise Village [confidence: low]" },
    ["ancestral homage formal gown"] = { totalInsulation=24, flavorNote="Explicitly described as silk shirtings for Dunmer ancestral ceremonies [confidence: high]" },
    ["imperial chancellor"] = { totalInsulation=28, flavorNote="Traditional war armor donned by the Imperial Elder Council Chancellor [confidence: medium]" },
    ["imperial city temple tunic"] = { totalInsulation=24, flavorNote="Explicitly described as shimmering satin temple wear [confidence: high]" },
    ["jester's daedroth suit"] = { totalInsulation=33, flavorNote="Crafted from Scrap of Minstrel's Cloth; reptilian Daedroth bodysuit theme gives mild cold-blooded discount [confidence: medium]" },
    ["jakarn's ensemble"] = { totalInsulation=50, flavorNote="Well-tailored riding outfit; no explicit thermal cues [confidence: low]" },
    ["jaqspur"] = { totalInsulation=50, flavorNote="Explicitly described as made entirely of leather accented with bone [confidence: high]" },
    ["jarl finery"] = { totalInsulation=100, flavorNote="Explicit fur collar on rugged northern Western Skyrim nobility raiment; raw value 103 clamped to 100 [confidence: high]" },
    ["priests of y'ffre outfit (bosmeri spiritual leader costume)"] = { totalInsulation=83, flavorNote="Explicitly described as made of leather; wool; bone; and antlers [confidence: high]" },
    ["vanguard uniform"] = { totalInsulation=50, flavorNote="Dark Elf disguise-based costume from Stonefalls; no thermal cues [confidence: low]" },
    ["vengeance day dress"] = { totalInsulation=24, flavorNote="Orc festival dress for Malacath's Vengeance Day; no thermal cues [confidence: low]" },
    ["king emeric's diamond regalia"] = { totalInsulation=28, flavorNote="Explicitly described as featuring high-quality silks and fabrics [confidence: high]" },
    ["kinlord's alinor attire"] = { totalInsulation=24, flavorNote="Formal High Elf noble ensemble for Alinor's Royal Palace [confidence: low]" },
    ["knight of the flame"] = { totalInsulation=28, flavorNote="Armored knight costume from the Armored Knights Pack; flame is cosmetic theming only [confidence: low]" },
    ["liespinner's vestments"] = { totalInsulation=33, flavorNote="Concealing cult vestments worn by acolytes of Mephala [confidence: low]" },
    ["lion guard elite"] = { totalInsulation=28, flavorNote="Explicitly described as plate and scale mail armor of whitened steel [confidence: high]" },
    ["breton knight (armored knights pack; unnamed)"] = { totalInsulation=28, flavorNote="Generic Breton knight armor costume [confidence: medium]" },
    ["lizardly four-fabric skirt set"] = { totalInsulation=35, flavorNote="Explicitly made of flax; feathers; alit-scales; and spun dank-cotton [confidence: high]" },
    ["antiquarian field garb"] = { totalInsulation=48, flavorNote="Durable field outfit with weatherproofed backpack for antiquity hunting [confidence: medium]" },
    ["antiquarian robes"] = { totalInsulation=35, flavorNote="Decorous tasseled scholarly robes for the Antiquarian's Circle [confidence: low]" },
    ["mages guild formal robes"] = { totalInsulation=35, flavorNote="Standard Mages Guild formal robe; no thermal cues [confidence: low]" },
    ["mages guild leggings uniform"] = { totalInsulation=35, flavorNote="Mages Guild uniform variant with leggings [confidence: low]" },
    ["mages guild research robes"] = { totalInsulation=37, flavorNote="Research robes with explicit fur trim on the shoe area [confidence: medium]" },
    ["mages guildmaster garb"] = { totalInsulation=35, flavorNote="Formal robe based on Guildmaster Vanus Galerion's attire [confidence: low]" },
    ["mercymother's attire"] = { totalInsulation=35, flavorNote="Healer-aligned ceremonial attire; no explicit thermal cues [confidence: low]" },
    ["midnight union garb"] = { totalInsulation=50, flavorNote="Dark smuggler garb from Stormhaven's Midnight Union operation [confidence: low]" },
    ["night mother's evangelist"] = { totalInsulation=33, flavorNote="Dark Brotherhood cult-aligned evangelist robe [confidence: low]" },
    ["mara's disciple frock"] = { totalInsulation=33, flavorNote="Devotional frock honoring Mara; Goddess of Love [confidence: low]" },
    ["naryu's assassin's armor"] = { totalInsulation=65, flavorNote="Explicitly described as black and gray leather and boiled leather armor [confidence: high]" },
    ["naryu's morag tong costume"] = { totalInsulation=45, flavorNote="Explicitly described as functional; low-profile leather armor [confidence: high]" },
    ["necrom evening attire"] = { totalInsulation=24, flavorNote="Opulent evening wear for Dunmer funeral ceremonies in Necrom [confidence: low]" },
    ["off-the-shoulder evening dress"] = { totalInsulation=24, flavorNote="Traditional Breton evening dress; no explicit thermal cues [confidence: low]" },
    ["negligee of the coven shrike"] = { totalInsulation=17, flavorNote="Witches Festival-themed negligee; minimal coverage implied by garment type [confidence: medium]" },
    ["pirate swab outfit"] = { totalInsulation=50, flavorNote="Deckhand pirate costume from the Pirate Costume Pack [confidence: low]" },
    ["priest of the green"] = { totalInsulation=35, flavorNote="Nature-priest robe of Y'ffre's traveling devotees [confidence: low]" },
    ["pellitine dancer's garb"] = { totalInsulation=19, flavorNote="Explicitly described as a light garb for dancing [confidence: medium]" },
    ["pellitine tea-fete gown"] = { totalInsulation=24, flavorNote="Classic Khajiiti tea-ceremony gown; light formal wear [confidence: low]" },
    ["renegade dragon priest"] = { totalInsulation=35, flavorNote="Ancient Nordic Dragon Priest mask-and-robe costume from Scalecaller [confidence: medium]" },
    ["pact mother elite ensemble"] = { totalInsulation=38, flavorNote="Almalexia-blessed Tribunal Temple ceremonial robes; mild blessed-warmth bonus [confidence: medium]" },
    ["peryite skeevemaster"] = { totalInsulation=68, flavorNote="Explicitly described as heavy and concealing clothes with full facial coverage [confidence: medium]" },
    ["queen ayrenn's diamond gown"] = { totalInsulation=24, flavorNote="Explicitly tailored with the finest silks money can buy [confidence: high]" },
    ["queen's-eye spymaster"] = { totalInsulation=45, flavorNote="Sleek low-profile spymaster outfit; no explicit thermal cues [confidence: low]" },
    ["quendelunn veiled heritance garb"] = { totalInsulation=35, flavorNote="High Elf disguise-based costume from Auridon; no explicit thermal cues [confidence: low]" },
    ["robes of truth and law"] = { totalInsulation=35, flavorNote="Mystic morph-collectible robes; no explicit thermal cues [confidence: low]" },
    ["royal courier"] = { totalInsulation=50, flavorNote="Courier outfit with hidden document pockets; no explicit thermal cues [confidence: low]" },
    ["royal court jester"] = { totalInsulation=33, flavorNote="Jovial jester garb with mask and bell-cap [confidence: low]" },
    ["ragebound harness"] = { totalInsulation=55, flavorNote="Karth River valley harness themed around inner fire/rage; mild warmth bonus [confidence: medium]" },
    ["crocskin overkilt"] = { totalInsulation=33, flavorNote="Explicitly described as made of crocskin (reptile hide); durable and mudproof [confidence: high]" },
    ["red rook armor"] = { totalInsulation=67, flavorNote="Explicitly uses the Orc style motif (iron base material per existing Styles table) [confidence: medium]" },
    ["sand-kissed salwar ensemble"] = { totalInsulation=20, flavorNote="Explicitly described as light clothing for hot Alik'r Desert climate [confidence: high]" },
    ["sea drake garb"] = { totalInsulation=50, flavorNote="Loose-fitting pirate garb worn around Stros M'Kai [confidence: low]" },
    ["drifting sand tunic and sash"] = { totalInsulation=20, flavorNote="Billowing desert-flow tunic and breeches ensemble [confidence: medium]" },
    ["satakalaaam imperial armor"] = { totalInsulation=25, flavorNote="Well-fitted Imperial troop armor deployed to the hot Alik'r Desert [confidence: medium]" },
    ["pirate first mate's outfit"] = { totalInsulation=50, flavorNote="Sea raider's rank outfit for a ship's First Mate [confidence: low]" },
    ["pirate sash and bandolier garb"] = { totalInsulation=50, flavorNote="Full pirate rig with sash and bandolier [confidence: low]" },
    ["ancient sites explorer"] = { totalInsulation=48, flavorNote="Field gear for active ancient-ruins investigators [confidence: low]" },
    ["blackheart pirate armor"] = { totalInsulation=50, flavorNote="Pirate armor from Blackheart Haven; no explicit thermal cues [confidence: low]" },
    ["traveling merchant"] = { totalInsulation=35, flavorNote="Practical merchant's traveling outfit; no explicit thermal cues [confidence: low]" },
    ["tavern maid"] = { totalInsulation=33, flavorNote="Pretty and practical tavern common-room work outfit [confidence: low]" },
    ["telvanni master wizard"] = { totalInsulation=35, flavorNote="Stately understated robe of a Telvanni Master Wizard [confidence: low]" },
    ["toxin doctor"] = { totalInsulation=46, flavorNote="Explicitly described as protective garb designed to guard against self-poisoning [confidence: medium]" },
    ["wayrest suede doublet ensemble"] = { totalInsulation=30, flavorNote="Explicitly described as a suede doublet over velveteen breeches [confidence: high]" },
    ["wedding dress"] = { totalInsulation=24, flavorNote="White formal wedding dress; no explicit thermal cues [confidence: low]" },
    ["wedding suit"] = { totalInsulation=33, flavorNote="Formal dapper wedding suit for grooms; no explicit thermal cues [confidence: low]" },
    ["west skyrim scout outfit"] = { totalInsulation=68, flavorNote="Scout armor of Western Skyrim's cold holds (Haafingar; Hjaalmarch; Karthald) [confidence: medium]" },
    ["xanmeer doyen's worship robe"] = { totalInsulation=50, flavorNote="Explicitly described as a corset of kagouti-leather with a dank-cotton skirt and bird-skull pauldrons [confidence: high]" },
    ["10-year anniversary nord hero"] = { totalInsulation=100, flavorNote="Explicit white fur trimmings on a Nord hero costume; raw value 103 clamped to 100 [confidence: high]" },
    ["10-year anniversary breton hero"] = { totalInsulation=28, flavorNote="Metallic chest/shoulder/wrist accents on an intimidating Breton hero costume [confidence: medium]" },
    ["10-year anniversary elven hero"] = { totalInsulation=28, flavorNote="Gold-and-ivory accented mage robe theme for a High Elf hero costume [confidence: medium]" },
    ["pellitine anniversary drape"] = { totalInsulation=24, flavorNote="Explicitly black fabric with gold trimming; light Khajiit drape and sandals [confidence: medium]" },
    ["kamali akaviri assassin outfit"] = { totalInsulation=44, flavorNote="Armor worn by assassins of the Kamali Akaviri invasion force [confidence: low]" },
    ["vinedusk vigilant"] = { totalInsulation=35, flavorNote="Bosmer nature-guardian costume; no explicit thermal cues [confidence: low]" },
    ["vulkhel guard marine armor"] = { totalInsulation=28, flavorNote="Explicitly described as sturdy High Elf marine armor [confidence: medium]" },
    ["moon-sugar festival suit"] = { totalInsulation=24, flavorNote="Explicitly blends five different silks for a Khajiiti harvest festival suit [confidence: high]" },
    ["budi-shirt and galligaskins"] = { totalInsulation=20, flavorNote="Explicitly described as breeze-catching light trousers and shirt [confidence: high]" },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- POLYMORPH DATA  (flat integer 0–100 authoring scale, pre-snap — see
-- COSTUME DATA note above; snapped onto the nearest tier at lookup time)
-- ─────────────────────────────────────────────────────────────────────────────
LibArmorInsulation.Data.PolymorphInsulation = {
    ["DEFAULT_POLYMORPH"]    = { totalInsulation=38, flavorNote="" },

    ["shadow spectre"]       = { totalInsulation= 2, flavorNote="Intangible shadow form — no thermal mass" },
    ["vestige of darkness"]  = { totalInsulation= 2, flavorNote="" },
    ["undead horror"]        = { totalInsulation= 8, flavorNote="Undead body does not generate warmth" },
    ["flame atronach form"]  = { totalInsulation=95, flavorNote="Entire body is living fire", magical=true },
    ["storm atronach form"]  = { totalInsulation=10, flavorNote="Lightning form, minimal thermal mass" },
    ["ice wraith"]           = { totalInsulation=-10, flavorNote="Body of living ice — aggressively cold", magical=true },
    ["scamp"]                = { totalInsulation=30, flavorNote="Leathery Daedric skin" },
    ["golden saint"]         = { totalInsulation=48, flavorNote="Divine armored form" },
    ["dremora kynreeve"]     = { totalInsulation=35, flavorNote="Daedric armored form, cold emanation" },
    ["werewolf"]             = { totalInsulation=78, flavorNote="Dense fur pelt and elevated body temperature" },
    ["vampire lord"]         = { totalInsulation=18, flavorNote="Undead physiology — reduced warmth retention" },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- OUTFIT STYLE DATA  (per-slot, same formula as armor styles)
-- Keyed by collectible ID from slotManipulator:GetCurrentCollectibleId().
-- NOT ITEM_STYLE_* integers — a completely separate number space.
-- To find collectible IDs: equip the outfit and run /outfitids in-game.
-- ─────────────────────────────────────────────────────────────────────────────
LibArmorInsulation.Data.OutfitStyles = {
    -- Default for any unrecognised collectible (leather equivalent at 0.9 coverage).
    ["DEFAULT"] = { baseMaterial="leather", coverage=0.9, flavorBonus=0, flavorNote="Unknown outfit style — using default insulation" },

    -- Populate with real collectible IDs from /outfitids.
    -- Format: [collectibleId] = { baseMaterial, coverage, flavorBonus, flavorNote }
    -- [12402] = { baseMaterial="fur",     coverage=1.1, flavorBonus=8,  flavorNote="Nordic fur-trimmed helmet" },
    -- [13215] = { baseMaterial="leather", coverage=1.0, flavorBonus=0,  flavorNote="" },

    -- PROMOTED FROM VERIFIED PLAYER OVERRIDES (SavedVariables "outfit_<id>" entries).
    -- The final tier for each of these was explicitly set by a player after
    -- observing the outfit in-game, so the TIER itself is confirmed-correct.
    -- However, this table only stores baseMaterial/coverage/flavorBonus, not a
    -- direct tier — so the fields below were chosen as the minimal combination
    -- that reproduces the confirmed tier through the standard formula. They are
    -- NOT an independent assessment of these outfits' actual material or
    -- coverage — the collectible names have not yet been looked up via
    -- /outfitids. [confidence: high on the tier, low on baseMaterial/coverage]
    -- flavorNote is intentionally blank here: this reasoning is authoring-time
    -- context for maintainers, not something a player needs to see in the
    -- Settings panel's Current Insulation display.
    [4804]  = { baseMaterial="none", coverage=1.0, flavorBonus=0,   flavorNote="" },
    [4798]  = { baseMaterial="none", coverage=1.0, flavorBonus=0,   flavorNote="" },
    [4800]  = { baseMaterial="none", coverage=1.0, flavorBonus=0,   flavorNote="" },
    [9746]  = { baseMaterial="hide", coverage=1.0, flavorBonus=0,   flavorNote="" },
    [7195]  = { baseMaterial="hide", coverage=1.0, flavorBonus=0,   flavorNote="" },
    [8786]  = { baseMaterial="hide", coverage=1.0, flavorBonus=0,   flavorNote="" },
    [11819] = { baseMaterial="fur",  coverage=1.0, flavorBonus=-10, flavorNote="" },
    [11818] = { baseMaterial="fur",  coverage=1.0, flavorBonus=-10, flavorNote="" },
    [11820] = { baseMaterial="fur",  coverage=1.0, flavorBonus=-10, flavorNote="" },
    [11851] = { baseMaterial="fur",  coverage=1.0, flavorBonus=-10, flavorNote="" },
    [5309]  = { baseMaterial="none", coverage=1.0, flavorBonus=-10, magical=true, flavorNote="" },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- COSTUME INSULATION — by collectible ID (checked before name table)
-- To find an ID: equip the costume and run /costumeids
-- ─────────────────────────────────────────────────────────────────────────────
LibArmorInsulation.Data.CostumeInsulationById = {
    -- [collectibleId] = { totalInsulation=integer, flavorNote=string }

    -- PROMOTED FROM VERIFIED PLAYER OVERRIDES (SavedVariables "costume_<id>"
    -- entries). Each of these superseded an existing auto-rated cache guess
    -- after a player manually corrected it in-game — the corrected value is
    -- taken as the reliable one. [confidence: high]
    [12717] = { totalInsulation=75, flavorNote="10-Year Anniversary Nord Hero — manually verified in-game; supersedes an auto-rated guess of 50 [confidence: high]" },
    [1101]  = { totalInsulation=30, flavorNote="Ever Damp Reed-Fiber Kilt — manually verified in-game; supersedes an auto-rated guess of 50 [confidence: high]" },
    [12719] = { totalInsulation=70, flavorNote="New Life Winter Storm Robes — manually verified in-game; supersedes an auto-rated guess of 58 [confidence: high]" },
    [286]   = { totalInsulation=20, flavorNote="Graht-Climber's Active Wear — manually verified in-game; supersedes an auto-rated guess of 50 [confidence: high]" },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- POLYMORPH INSULATION — by collectible ID (checked before name table)
-- ─────────────────────────────────────────────────────────────────────────────
LibArmorInsulation.Data.PolymorphInsulationById = {
    -- [collectibleId] = { totalInsulation=integer, flavorNote=string }
}
