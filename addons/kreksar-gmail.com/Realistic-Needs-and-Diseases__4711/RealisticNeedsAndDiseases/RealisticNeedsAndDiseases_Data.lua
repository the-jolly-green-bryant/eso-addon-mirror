-- RealisticNeedsAndDiseases_Data.lua
-- Static data: the 6 disease definitions, cured by alchemy ingredients
-- carrying specific traits (3 tiers of real, UESP-verified ingredients per
-- disease, common → rare), plus the confirmed alchemy-water-solvent harvest
-- list. Most diseases have their own distinct cure trait; Fighter's Bane and
-- Thief's Bane are the exception, by request — they intentionally REUSE
-- Restore Health and an existing Restore Stamina ingredient set
-- respectively, rather than getting distinct ones of their own.

RealisticNeeds = RealisticNeeds or {}
local RN = RealisticNeeds

RN.SEVERITY_MILD     = 1
RN.SEVERITY_MODERATE = 2
RN.SEVERITY_SEVERE   = 3

-- Stable 1-6 ordering used by index-based commands (e.g. /rnd debug disease).
-- Index position here is permanent — don't reorder existing entries even if
-- you add another disease later, or old saved references/macros would shift.
RN.DISEASE_ORDER = { "frostbite", "heatstroke", "mageBane", "fightersBane", "thiefsBane" }

-- ─────────────────────────────────────────────────────────────────────────────
-- DISEASE CATALOG
-- Cured by RAW ALCHEMY INGREDIENTS (never potions), one specific ingredient
-- per tier, sourced from UESP's "Online:Alchemy Ingredients" page
-- (https://en.uesp.net/wiki/Online:Alchemy_Ingredients) where verified.
--
-- ITEM ID VERIFICATION STATUS: frostbite carries over its previously-
-- confirmed boneChill ingredient list unchanged (same disease, renamed —
-- Restore Health ingredients don't change just because the disease's name
-- and trigger did). Thief's Bane's Dragon's Blood (tier 3) is STILL
-- unconfirmed — the player never had one to scan; run /rnd debug
-- ingredients again once you acquire one.
--
-- heatstroke and magicBlight are NEW diseases with NO verified
-- ingredients yet — remedyIngredients below are intentionally EMPTY rather
-- than guessed. Confirm real itemIds in-game while holding candidate
-- Restore Health / Restore Magicka
-- (magicBlight) / [unspecified — heatstroke's curative trait wasn't given in
-- the spec, defaulted to Restore Health below, flag if that should be
-- something else] ingredients to fill these in for real. Until then these
-- 3 diseases can be contracted and will progress in severity, but cannot be
-- cured by ingredients — only by /rnd debug disease <index> 0, or the
-- care-cure path once a tier-1 ingredient is added.
--
-- remedyIngredients[tier] = { { name = "...", itemId = ... }, ... }
--   Each tier is a LIST of one-or-more interchangeable ingredients — ANY one
--   of them cures that tier (e.g. Frostbite/Heatstroke's tier 3 accepts
--   either Vile Coagulant OR Powdered Mother of Pearl). Most tiers only have
--   one real-world option and so are single-element lists; that's normal.
--   tier 1 = common/cheap (Default nodes or common creature loot)
--   tier 2 = uncommon (specific creature loot or zone-restricted)
--   tier 3 = rare (Dragons, Harrowstorms, Blackreach, or similarly rare source)
-- A tier-N ingredient cures that disease at severity <= N.
--
-- careCure: the SAME tier-1 ingredient(s), eaten repeatedly while
-- hunger/thirst/fatigue are all above the "well cared for" threshold (see
-- Settings), can gradually downgrade a more severe case one tier at a time
-- instead of requiring the rarer tier-matched ingredient outright. See
-- Disease.lua's OnCareCureProgress(). Diseases with no tier-1 ingredient yet
-- (the 3 new ones below) simply can't use this path until one is added.
-- ─────────────────────────────────────────────────────────────────────────────
RN.Diseases = {
    frostbite = {
        name = "Frostbite",
        overlayColor = { 0.55, 0.75, 1.0 },
        -- Real custom art (player-supplied, replaces the earlier placeholder).
        overlayTexture = "RealisticNeedsAndDiseases/textures/overlays/Frostbite.dds",
        -- Renamed from boneChill — same trigger mechanism, unchanged. Per
        -- spec: "use Frostfall to detect prolonged exposure to cold... if
        -- Frostfall is not installed, fall back to only using LibZoneTemp
        -- and tracking overall time spent in a frozen zone." This is exactly
        -- what Calculator.GetCurrentTemperature() already does — Frostfall's
        -- GetEffectiveTemp() (which factors in the player's own insulation,
        -- i.e. "not keeping warm") preferred, LibZoneTemp's raw zone
        -- temperature (no insulation factored in at all, so exposure time
        -- IS purely "time spent in a cold zone") as the fallback. See
        -- Disease.CheckSustainedCold in Disease.lua. Exposure threshold is
        -- Disease.EXPOSURE_THRESHOLD_SECONDS (5 minutes) before there's
        -- even a CHANCE to roll the disease — see that constant in
        -- Disease.lua.
        triggerType = "sustainedCold",
        curativeTraitName = "Protection",
        -- VERIFIED against UESP's Alchemy Ingredients page: only 4 reagents
        -- in the entire table carry Protection as one of their 4 effects —
        -- Beetle Scuttle, Mudcrab Chitin, Powdered Mother of Pearl, and Vile
        -- Coagulant. Frostbite and Heatstroke use the IDENTICAL set (by
        -- request) — Mudcrab Chitin tier 1, Beetle Scuttle tier 2, and tier
        -- 3 now accepts EITHER Vile Coagulant OR Powdered Mother of Pearl
        -- interchangeably (also by request), so all 4 known Protection
        -- reagents are actually in use across the two diseases' tier 3.
        -- ItemIds carried over from this project's own EARLIER
        -- in-game-confirmed scans (previously verified for the
        -- now-retired wormwoodPlague/bloodFever), not re-guessed.
        remedyIngredients = {
            [1] = { { name = "Mudcrab Chitin", itemId = 77591 } },  -- Mudcrabs (not Coral Crabs)
            [2] = { { name = "Beetle Scuttle", itemId = 77583 } },  -- Beetles, Thunderbugs, Assassin Beetles, Shalks
            [3] = {
                { name = "Vile Coagulant", itemId = 150670 },  -- Harrowstorms — shared with Heatstroke and Magic Blight
                { name = "Powdered Mother of Pearl", itemId = 139019 },  -- Giant Clams (Summerset/High Isle) — shared with Heatstroke
            },
        },
        flavorNote = "A creeping chill that settles into the joints after too long exposed to the cold.",
    },
    heatstroke = {
        name = "Heatstroke",
        -- Aesthetic pick only (not game data) — a warm orange/red distinct
        -- from the diseases below, just so they don't read as
        -- the same color if overlayTexture is ever removed and it falls
        -- back to this flat tint.
        overlayColor = { 0.95, 0.55, 0.10 },
        overlayTexture = "RealisticNeedsAndDiseases/textures/overlays/Heatstroke.dds",
        -- New disease — mirrors frostbite's CheckSustainedCold exactly, just
        -- inverted to the HOT side of the same Calculator.GetCurrentTemperature()
        -- comfort band (temp > COMFORT_MAX instead of < COMFORT_MIN). Same
        -- Frostfall-preferred/LibZoneTemp-fallback temperature source, so the
        -- same optional-Frostfall behavior applies here too even though the
        -- spec only mentioned it explicitly for frostbite. Same 5-minute
        -- exposure threshold as Frostbite — Disease.EXPOSURE_THRESHOLD_SECONDS.
        triggerType = "sustainedHeat",
        curativeTraitName = "Protection",
        -- IDENTICAL set to Frostbite, by request — see the longer note on
        -- Frostbite's remedyIngredients above for sourcing. Tier 3 accepts
        -- either Vile Coagulant or Powdered Mother of Pearl, same as
        -- Frostbite.
        remedyIngredients = {
            [1] = { { name = "Mudcrab Chitin", itemId = 77591 } },  -- Mudcrabs (not Coral Crabs)
            [2] = { { name = "Beetle Scuttle", itemId = 77583 } },  -- Beetles, Thunderbugs, Assassin Beetles, Shalks
            [3] = {
                { name = "Vile Coagulant", itemId = 150670 },  -- Harrowstorms — shared with Frostbite and Magic Blight
                { name = "Powdered Mother of Pearl", itemId = 139019 },  -- Giant Clams (Summerset/High Isle) — shared with Frostbite
            },
        },
        flavorNote = "Relentless heat that leaves the skin flushed and the head pounding.",
    },
    mageBane = {
        name = "Mage's Bane",
        -- Aesthetic pick — a brighter purple, reads as
        -- "magical" rather than reusing wormwoodPlague's old purple exactly.
        overlayColor = { 0.55, 0.30, 0.85 },
        -- Renamed alongside the disease itself: was Magicpox.dds (the
        -- literal file the player originally uploaded, from when this
        -- disease was called Magicpox/Magic Blight) — now renamed to
        -- MagesBane.dds to match the current disease name.
        overlayTexture = "RealisticNeedsAndDiseases/textures/overlays/MagesBane.dds",
        -- WIDENED per request: previously only DAMAGE_TYPE_MAGIC. Now any of
        -- the four "spell damage" types — Magic, Fire, Cold ("Frost
        -- Damage" in the UI, but the underlying engine constant is
        -- DAMAGE_TYPE_COLD, not DAMAGE_TYPE_FROST — an earlier version of
        -- this used the wrong name and crashed the whole addon on load;
        -- see the longer note above DAMAGE_TYPE_TO_DISEASES in Disease.lua),
        -- and Shock — has an independent chance to contract this on a
        -- qualifying hit. See AddDiseaseTrigger calls in Disease.lua.
        -- DAMAGE_TYPE_MAGIC was already in use elsewhere in this project;
        -- DAMAGE_TYPE_FIRE, DAMAGE_TYPE_COLD, and DAMAGE_TYPE_SHOCK are
        -- believed-real but individually unconfirmed against a live
        -- client — Disease.lua now resolves all of these defensively
        -- (skips and warns rather than crashing if any turn out wrong)
        -- rather than assuming they're correct.
        triggerType = "magicalDamageTaken",
        curativeTraitName = "Restore Magicka",
        -- CORRECTED: a previous version of this comment claimed these
        -- itemIds were "verified via RolePlayNeeds' own RPN_REAGENT_TRAITS
        -- lookup table" and even cited a specific line number for it. That
        -- table does not exist anywhere in RolePlayNeeds' actual published
        -- source (checked directly against the official v0.7 BETA release)
        -- — it was mistakenly attributed to RPN when it was really an
        -- addition to a local, personally-modified copy of RPN, never
        -- published. This comment also previously named the wrong
        -- ingredients (Mountain Flower/Water Hyacinth/Crimson Nirnroot,
        -- which are actually Fighter's Bane's set below, not this one's).
        --
        -- Corn Flower/Lady's Smock/Vile Coagulant are UESP-confirmed to
        -- carry Restore Magicka as one of their 4 effects. Their itemIds
        -- come from this project's own in-game scan (`/rnd debug
        -- ingredients`), not from any RolePlayNeeds cross-check. Tier 1
        -- and tier 2 are both Default-node reagents — per UESP's Alchemy
        -- Ingredients page, Default-node Restore Magicka reagents are
        -- Bugloss/Columbine/Corn Flower/Lady's Smock, with no zone-
        -- restricted/creature-loot option in between common and the
        -- Harrowstorm-only Vile Coagulant, so there's no real rarity
        -- gradient between tier 1 and 2 here the way other diseases have —
        -- just two different common reagents.
        remedyIngredients = {
            [1] = { { name = "Corn Flower", itemId = 30161 } },  -- Default nodes
            [2] = { { name = "Lady's Smock", itemId = 30158 } },  -- Default nodes
            [3] = { { name = "Vile Coagulant", itemId = 150670 } },  -- Harrowstorms
        },
        flavorNote = "An itching magical rash that spreads after one too many arcane wounds.",
    },
    fightersBane = {
        name = "Fighter's Bane",
        -- Aesthetic pick — a duller, bruise-like red distinct from
        -- the other diseases' reds, since this disease has its own
        -- martial-damage flavor but isn't the same affliction.
        overlayColor = { 0.6, 0.25, 0.2 },
        -- Real custom art (player-supplied).
        overlayTexture = "RealisticNeedsAndDiseases/textures/overlays/FightersBane.dds",
        -- NEW disease per request: martial damage taken (Bleed or Physical)
        -- has an independent chance to cause this, mirroring the
        -- per-hit-chance mechanism but on the other half of the
        -- martial/physical damage-type pair. CURRENTLY WIRED TO
        -- DAMAGE_TYPE_PHYSICAL ONLY: "Bleed" appears in ESO's combat model
        -- as a status EFFECT applied by Physical damage, not a distinct
        -- DamageType of its own — an earlier version of this file assumed
        -- a separate DAMAGE_TYPE_BLEED constant existed and used it as a
        -- literal table key, which would have crashed the addon on load
        -- the same way DAMAGE_TYPE_FROST did for mageBane (see the longer
        -- note above AddDiseaseTrigger in Disease.lua) if Physical hadn't
        -- happened to be checked first. If a real distinct Bleed
        -- damage-type constant is later confirmed, add it via
        -- Disease.lua's AddDiseaseTrigger the same defensive way the other
        -- triggers are wired, rather than a literal table key.
        triggerType = "martialPhysicalDamageTaken",
        curativeTraitName = "Restore Health",
        -- Uses the same Restore Health ingredient set/itemIds as
        -- Frostbite's old (pre-Protection-switch) reagents — already
        -- in-game-confirmed.
        remedyIngredients = {
            [1] = { { name = "Mountain Flower", itemId = 30163 } },  -- Default nodes
            [2] = { { name = "Water Hyacinth", itemId = 30166 } },  -- Water nodes
            [3] = { { name = "Crimson Nirnroot", itemId = 150672 } },  -- Blackreach (unique node type)
        },
        flavorNote = "A deep, lingering soreness that sets into old wounds dealt by blade and bleeding alike.",
    },
    thiefsBane = {
        name = "Thief's Bane",
        -- Aesthetic pick — a sickly yellow-green, distinct from both
        -- mageBane's purple.
        overlayColor = { 0.55, 0.6, 0.2 },
        -- Real custom art (player-supplied).
        overlayTexture = "RealisticNeedsAndDiseases/textures/overlays/ThiefsBane.dds",
        -- NEW disease per request: martial damage taken (Poison or Disease)
        -- has an independent chance to cause this. Note DAMAGE_TYPE_DISEASE
        -- feeds this disease's trigger, per DAMAGE_TYPE_TO_DISEASES in
        -- Disease.lua.
        triggerType = "martialPhysicalDamageTaken",
        curativeTraitName = "Restore Stamina",
        -- This ingredient set/itemIds were originally shared with Ashen
        -- Lung (since removed per request) — now solely Thief's Bane's.
        -- Blessed Thistle and Chaurus Egg are in-game-confirmed; Dragon's
        -- Blood is STILL unconfirmed — the player never had one to scan.
        remedyIngredients = {
            [1] = { { name = "Blessed Thistle", itemId = 30157 } },  -- Default nodes
            [2] = { { name = "Chaurus Egg", itemId = 150669 } },  -- Chauruses
            [3] = { { name = "Dragon's Blood", itemId = 150731 } },  -- Dragons (UNCONFIRMED, not in player scan yet)
        },
        flavorNote = "A creeping sickness picked up from a poisoned blade or a filthy, festering wound.",
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Confirmed alchemy water-solvent itemIds — these are the real water-type
-- data (already verified in-game, used across Frostfall and RolePlayNeeds):
-- 883, 1187, 4570, 23265-23268, 64500, 64501.
-- ─────────────────────────────────────────────────────────────────────────────
RN.ALCHEMY_WATER_SOLVENT_IDS = {
    [883] = true, [1187] = true, [4570] = true,
    [23265] = true, [23266] = true, [23267] = true, [23268] = true,
    [64500] = true, [64501] = true,
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Alcohol/coffee detection — ESO has no ITEMTYPE flag distinguishing
-- alcoholic drinks or coffee from other ITEMTYPE_DRINK items, so this is a
-- NAME-KEYWORD HEURISTIC (same honest-limitation pattern as the old
-- undead-enemy keyword list). It will miss any drink whose name doesn't
-- contain these words — expand as you find ones that slip through.
-- ─────────────────────────────────────────────────────────────────────────────
-- ─────────────────────────────────────────────────────────────────────────────
-- Alcohol detection — two real signals, sourced from this project's own
-- Spoilage addon (Krek's own prior work, not a third party):
--
-- 1. PREPARED DRINKS (ITEMTYPE_DRINK): ESO doesn't expose a native flag
--    distinguishing alcoholic from non-alcoholic prepared drinks, so
--    Spoilage uses name-keyword matching — this exact keyword list is
--    copied from Spoilage's PST.preparedDrinkKeywords.DrinkAlcohol table,
--    which includes real ESO-lore-specific drink names (rotmeth, sujamma,
--    flin, mazte, greef, jagga) that a generic English-word list wouldn't
--    have caught.
-- 2. RAW ALCOHOL INGREDIENTS (ITEMTYPE_INGREDIENT): these DO have a real
--    native flag — SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL, confirmed via
--    Spoilage's GetItemCategory() function. Checked directly in
--    RealisticNeedsAndDiseases.lua's consumption handler, not via keyword.
-- ─────────────────────────────────────────────────────────────────────────────
RN.ALCOHOL_KEYWORDS = {
    "ale", "beer", "mead", "wine", "rum", "rotmeth", "sujamma", "flin", "mazte",
    "greef", "jagga", "spirits", "whiskey", "brandy", "liqueur", "double malt",
}
RN.COFFEE_KEYWORDS = { "coffee", "joe", "espresso" }
