-- Beltalowda Synergy Tracker
-- Data layer for tracking synergy cooldowns across group members
-- Detection via EVENT_COMBAT_EVENT, broadcasting via LGB protocol 223

Beltalowda = Beltalowda or {}
Beltalowda.Data = Beltalowda.Data or {}
Beltalowda.Data.SynergyTracker = Beltalowda.Data.SynergyTracker or {}

local ST = Beltalowda.Data.SynergyTracker

-- ============================================================================
-- Constants
-- ============================================================================

-- Universal synergy cooldown (milliseconds)
ST.COOLDOWN_MS = 20000

-- Synergy category constants
ST.CATEGORY_DAMAGE = 1
ST.CATEGORY_SUPPORT = 2

-- ============================================================================
-- Synergy Definitions
-- Each entry: id, name, category, abilityIds (trigger IDs), iconPath, cooldown
--
-- Ability IDs are the ESO ability IDs that fire ACTION_RESULT_EFFECT_GAINED
-- on the player who activates (takes) the synergy. These were validated
-- in-game using the Synergy audit tool (see issue #92).
--
-- IDs are our internal identifiers used in the LGB protocol (1 byte).
-- They don't need to be sequential but must be unique and fit in 0-255.
-- ============================================================================

ST.SYNERGIES = {

    -- ========================================================================
    -- UNDAUNTED SYNERGIES
    -- ========================================================================

    -- Combustion / Shards (shared cooldown group)
    -- Necrotic Orb → Combustion, Energy Orb → Healing Combustion
    -- Spear Shards → Blessed Shards, Luminous Shards → Holy Shards
    -- These all share the same 20s synergy cooldown.
    [1] = {
        id = 1,
        name = "Combustion / Shards",
        category = ST.CATEGORY_SUPPORT,
        displayOrder = 2,
        abilityIds = {85434, 63512, 48052, 95926, 95924},
        -- 85434 = Combustion (Necrotic Orb, Mystic Orb)
        -- 63512 = Healing Combustion (Energy Orb)
        -- 48052 = Blessed Shards (Spear Shards)
        -- 95926 = Holy Shards (Luminous Shards)
        -- 95924 = Holy Shards (alternate ID)
        iconPath = "/esoui/art/icons/ability_undaunted_004b.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- Blood Altar → Blood Funnel, Overflowing Altar → Blood Feast
    -- Sanguine Altar also uses Blood Funnel (same as base Blood Altar)
    [4] = {
        id = 4,
        name = "Blood Altar",
        category = ST.CATEGORY_SUPPORT,
        displayOrder = 3,
        abilityIds = {39519, 41965},
        -- 39519 = Blood Funnel (Blood Altar, Sanguine Altar)
        -- 41965 = Blood Feast (Overflowing Altar)
        iconPath = "/esoui/art/icons/ability_undaunted_001_b.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- Bone Shield → Bone Wall, Bone Surge → Spinal Surge
    [7] = {
        id = 7,
        name = "Bone Shield",
        category = ST.CATEGORY_SUPPORT,
        displayOrder = 1,
        abilityIds = {39424, 42196},
        -- 39424 = Bone Wall (Bone Shield)
        -- 42196 = Spinal Surge (Bone Surge)
        iconPath = "/esoui/art/icons/ability_undaunted_005b.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- Inner Fire / Inner Beast / Inner Rage → Radiate
    [11] = {
        id = 11,
        name = "Radiate",
        category = ST.CATEGORY_DAMAGE,
        displayOrder = 2,
        abilityIds = {41840},
        -- 41840 = Radiate (all morphs of Inner Fire)
        iconPath = "/esoui/art/icons/ability_undaunted_002_b.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- TODO: Trapping Webs / Shadow Silk / Tangling Webs → Spawn Broodlings / Black Widows / Arachnophobia
    -- Currently BUGGED on PTS — synergy does not appear. Uncomment and fill in validated IDs when fixed.
    -- RdK had: 39451 (Trapping Webs), 41997 (Shadow Silk), 42019 (Tangling Webs) — unverified
    --[[ [2] = {
        id = 2,
        name = "Spawn Broodlings",
        category = ST.CATEGORY_DAMAGE,
        abilityIds = {39451, 41997, 42019},  -- UNVERIFIED — needs in-game audit
        iconPath = "/esoui/art/icons/ability_undaunted_003_b.dds",
        cooldown = ST.COOLDOWN_MS,
    }, ]]--

    -- ========================================================================
    -- CLASS SYNERGIES — ARCANIST
    -- ========================================================================

    -- The Imperfect Ring / Rune of Displacement / Fulminating Rune → Runebreak
    [22] = {
        id = 22,
        name = "Runebreak",
        category = ST.CATEGORY_DAMAGE,
        displayOrder = 1,
        abilityIds = {191080},
        -- 191080 = Runebreak (all morphs)
        iconPath = "/esoui/art/icons/ability_arcanist_004.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- Passage Between Worlds (Apocryphal Gate morph) → Passage
    [23] = {
        id = 23,
        name = "Passage",
        category = ST.CATEGORY_SUPPORT,
        displayOrder = 9,
        abilityIds = {190646},
        -- 190646 = Passage (Passage Between Worlds morph only)
        iconPath = "/esoui/art/icons/ability_arcanist_016_b.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- ========================================================================
    -- CLASS SYNERGIES — DRAGONKNIGHT
    -- ========================================================================

    -- Dragonknight Standard / Shifting Standard / Standard of Might → Shackle
    [5] = {
        id = 5,
        name = "Shackle",
        category = ST.CATEGORY_DAMAGE,
        displayOrder = 5,
        abilityIds = {67717},
        -- 67717 = Shackle (all morphs of DK Standard)
        iconPath = "/esoui/art/icons/ability_dragonknight_006.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- TODO: Dark Talons / Burning Talons / Choking Talons → Ignite
    -- Currently BUGGED on PTS — synergy does not appear. Uncomment and fill in validated IDs when fixed.
    -- RdK had: 48040 — unverified
    --[[ [6] = {
        id = 6,
        name = "Ignite",
        category = ST.CATEGORY_DAMAGE,
        abilityIds = {48040},  -- UNVERIFIED — needs in-game audit
        iconPath = "/esoui/art/icons/ability_dragonknight_010.dds",
        cooldown = ST.COOLDOWN_MS,
    }, ]]--

    -- ========================================================================
    -- CLASS SYNERGIES — NECROMANCER
    -- ========================================================================

    -- Boneyard / Unnerving Boneyard / Avid Boneyard → Grave Robber
    [15] = {
        id = 15,
        name = "Grave Robber",
        category = ST.CATEGORY_DAMAGE,
        displayOrder = 6,
        abilityIds = {115567},
        -- 115567 = Grave Robber (all morphs)
        iconPath = "/esoui/art/icons/ability_necromancer_004.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- Agony Totem (Bone Totem morph) → Pure Agony
    [9] = {
        id = 9,
        name = "Pure Agony",
        category = ST.CATEGORY_DAMAGE,
        displayOrder = 7,
        abilityIds = {118610},
        -- 118610 = Pure Agony (Agony Totem morph only)
        iconPath = "/esoui/art/icons/ability_necromancer_010.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- ========================================================================
    -- CLASS SYNERGIES — NIGHTBLADE
    -- ========================================================================

    -- Consuming Darkness / Bolstering Darkness / Veil of Blades → Hidden Refresh
    [17] = {
        id = 17,
        name = "Hidden Refresh",
        category = ST.CATEGORY_SUPPORT,
        displayOrder = 8,
        abilityIds = {77769},
        -- 77769 = Hidden Refresh (all morphs of Consuming Darkness)
        -- Note: Multiple IDs fire (37729-37733, 77769), but 77769 is the primary
        iconPath = "/esoui/art/icons/ability_nightblade_015.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- ========================================================================
    -- CLASS SYNERGIES — SORCERER
    -- ========================================================================

    -- Lightning Splash / Liquid Lightning / Lightning Flood → Conduit
    [8] = {
        id = 8,
        name = "Conduit",
        category = ST.CATEGORY_DAMAGE,
        displayOrder = 8,
        abilityIds = {43769},
        -- 43769 = Conduit (all morphs of Lightning Splash)
        iconPath = "/esoui/art/icons/ability_sorcerer_liquid_lightning.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- Summon Storm Atronach / Greater Storm Atronach / Summon Charged Atronach → Charged Lightning
    [10] = {
        id = 10,
        name = "Charged Lightning",
        category = ST.CATEGORY_DAMAGE,
        displayOrder = 9,
        abilityIds = {48085},
        -- 48085 = Charged Lightning (all morphs of Storm Atronach)
        iconPath = "/esoui/art/icons/ability_sorcerer_storm_atronach.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- ========================================================================
    -- CLASS SYNERGIES — TEMPLAR
    -- ========================================================================

    -- Spear Shards / Luminous Shards → see Combustion/Shards group (ID 1)

    -- Nova / Solar Prison / Solar Disturbance → Supernova / Gravity Crush
    [3] = {
        id = 3,
        name = "Nova",
        category = ST.CATEGORY_DAMAGE,
        displayOrder = 4,
        abilityIds = {48939, 48938},
        -- 48939 = Supernova (Nova, Solar Disturbance)
        -- 48938 = Gravity Crush (Solar Prison)
        iconPath = "/esoui/art/icons/ability_templar_solar_disturbance.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- Cleansing Ritual / Extended Ritual / Ritual of Retribution → Purify
    [13] = {
        id = 13,
        name = "Purify",
        category = ST.CATEGORY_SUPPORT,
        displayOrder = 5,
        abilityIds = {22270},
        -- 22270 = Purify (all morphs of Cleansing Ritual)
        iconPath = "/esoui/art/icons/ability_templar_extended_ritual.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- ========================================================================
    -- CLASS SYNERGIES — WARDEN
    -- ========================================================================

    -- Healing Seed / Budding Seeds / Corrupting Pollen → Harvest
    [14] = {
        id = 14,
        name = "Harvest",
        category = ST.CATEGORY_SUPPORT,
        displayOrder = 6,
        abilityIds = {85576, 85577},
        -- 85576 = Harvest (base + one morph)
        -- 85577 = Harvest (alternate morph)
        iconPath = "/esoui/art/icons/ability_warden_007.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- Frozen Retreat (Frozen Gate morph) → Icy Escape
    [16] = {
        id = 16,
        name = "Icy Escape",
        category = ST.CATEGORY_SUPPORT,
        displayOrder = 7,
        abilityIds = {88892},
        -- 88892 = Icy Escape (Frozen Retreat morph only)
        iconPath = "/esoui/art/icons/ability_warden_005_b.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- ========================================================================
    -- WORLD SYNERGIES — WEREWOLF
    -- ========================================================================

    -- Howl of Despair (Piercing Howl morph) → Feeding Frenzy
    -- Not commonly relevant in PvP but included for completeness
    [18] = {
        id = 18,
        name = "Feeding Frenzy",
        category = ST.CATEGORY_DAMAGE,
        displayOrder = 10,
        abilityIds = {58813},
        -- 58813 = Feeding Frenzy (Howl of Despair morph only)
        iconPath = "/esoui/art/icons/achievement_u26_skyrim_werewolfdevour100.dds",
        cooldown = ST.COOLDOWN_MS,
    },

    -- ========================================================================
    -- SET SYNERGIES
    -- ========================================================================

    -- Recovery Convergence → Convergence Release
    [24] = {
        id = 24,
        name = "Convergence Release",
        category = ST.CATEGORY_SUPPORT,
        displayOrder = 4,
        abilityIds = {241235},
        -- 241235 = Convergence Release (Recovery Convergence set)
        iconPath = "/esoui/art/icons/ability_healer_018.dds",
        cooldown = ST.COOLDOWN_MS,
    },
}

-- Default synergies for each category tracker (role-based display)
ST.DEFAULT_DAMAGE_SYNERGIES = {22, 11}                   -- Runebreak, Radiate
ST.DEFAULT_SUPPORT_SYNERGIES = {7, 1, 4, 24}            -- Bone Shield, Combustion/Shards, Altar, Recovery Convergence

-- Default synergies for classic tracker (mix of both)
ST.DEFAULT_CLASSIC_SYNERGIES = {22, 11, 7, 1, 4}         -- Runebreak, Radiate, Bone Shield, Combustion/Shards, Altar

-- ============================================================================
-- Synergy Provider Lookup Tables
-- Maps SOURCE ability IDs (the skill a player SLOTS) to the synergy it provides.
-- This is the inverse of abilityToSynergy which maps ACTIVATION IDs (what you
-- press to take the synergy). Used by SynergyComposition to scan player bars.
-- ============================================================================

ST.SYNERGY_PROVIDERS = {
    -- Combustion / Shards (synergy ID 1)
    [63498] = 1,   -- Energy Orb
    [63470] = 1,   -- Necrotic Orb
    [95957] = 1,   -- Mystic Orb
    [22234] = 1,   -- Spear Shards
    [22465] = 1,   -- Luminous Shards
    [22461] = 1,   -- Blazing Spear

    -- Blood Altar (synergy ID 4)
    [39489] = 4,   -- Blood Altar
    [41967] = 4,   -- Overflowing Altar
    [39525] = 4,   -- Sanguine Altar

    -- Bone Shield (synergy ID 7)
    [39369] = 7,   -- Bone Shield
    [42176] = 7,   -- Bone Surge
    [42138] = 7,   -- Bone Wall (morph)

    -- Radiate (synergy ID 11)
    [28924] = 11,  -- Inner Fire
    [41947] = 11,  -- Inner Beast
    [42056] = 11,  -- Inner Rage

    -- Shackle (synergy ID 5) - DK Standard
    [29012] = 5,   -- Dragonknight Standard
    [32958] = 5,   -- Shifting Standard
    [32947] = 5,   -- Standard of Might

    -- Grave Robber (synergy ID 15) - Necromancer Boneyard
    [114850] = 15, -- Boneyard
    [117805] = 15, -- Unnerving Boneyard
    [117850] = 15, -- Avid Boneyard

    -- Pure Agony (synergy ID 9) - Agony Totem (Bone Totem morph)
    [118619] = 9,  -- Agony Totem

    -- Runebreak (synergy ID 22) - Arcanist
    [183006] = 22, -- The Imperfect Ring
    [185805] = 22, -- Rune of Displacement
    [185816] = 22, -- Fulminating Rune

    -- Passage (synergy ID 23) - Arcanist portal
    [189935] = 23, -- Passage Between Worlds (Apocryphal Gate morph)

    -- Hidden Refresh (synergy ID 17) - Nightblade
    [33194] = 17,  -- Consuming Darkness
    [36207] = 17,  -- Bolstering Darkness
    [36493] = 17,  -- Veil of Blades

    -- Conduit (synergy ID 8) - Sorcerer
    [23182] = 8,   -- Lightning Splash
    [23200] = 8,   -- Liquid Lightning
    [23205] = 8,   -- Lightning Flood

    -- Charged Lightning (synergy ID 10) - Sorcerer
    [23634] = 10,  -- Summon Storm Atronach
    [23492] = 10,  -- Greater Storm Atronach
    [23495] = 10,  -- Summon Charged Atronach

    -- Nova (synergy ID 3) - Templar
    [21752] = 3,   -- Nova
    [21755] = 3,   -- Solar Prison
    [21758] = 3,   -- Solar Disturbance

    -- Purify (synergy ID 13) - Templar
    [22265] = 13,  -- Cleansing Ritual
    [22259] = 13,  -- Extended Ritual
    [22262] = 13,  -- Ritual of Retribution

    -- Harvest (synergy ID 14) - Warden
    [85532] = 14,  -- Healing Seed
    [85840] = 14,  -- Budding Seeds
    [85845] = 14,  -- Corrupting Pollen

    -- Icy Escape (synergy ID 16) - Warden
    [86175] = 16,  -- Frozen Retreat (Frozen Gate morph)

    -- Feeding Frenzy (synergy ID 18) - Werewolf
    [58317] = 18,  -- Howl of Despair (Piercing Howl morph)
}

-- ============================================================================
-- Synergy Provider Name Fallback
-- Maps English ability NAMES to synergy IDs. Used as a fallback when the
-- hardcoded ability IDs in SYNERGY_PROVIDERS don't match what GetSlotBoundId()
-- returns (e.g., due to rank-specific IDs or patch changes).
-- This makes detection resilient to ID drift across ESO updates.
-- ============================================================================

ST.SYNERGY_PROVIDER_NAMES = {
    -- Combustion / Shards (synergy ID 1)
    ["Necrotic Orb"]       = 1,
    ["Energy Orb"]         = 1,
    ["Mystic Orb"]         = 1,
    ["Spear Shards"]       = 1,
    ["Luminous Shards"]    = 1,
    ["Blazing Spear"]      = 1,

    -- Blood Altar (synergy ID 4)
    ["Blood Altar"]        = 4,
    ["Overflowing Altar"]  = 4,
    ["Sanguine Altar"]     = 4,

    -- Bone Shield (synergy ID 7)
    ["Bone Shield"]        = 7,
    ["Bone Surge"]         = 7,
    ["Bone Wall"]          = 7,

    -- Radiate (synergy ID 11)
    ["Inner Fire"]         = 11,
    ["Inner Beast"]        = 11,
    ["Inner Rage"]         = 11,

    -- Shackle (synergy ID 5) - DK Standard
    ["Dragonknight Standard"] = 5,
    ["Shifting Standard"]     = 5,
    ["Standard of Might"]     = 5,

    -- Grave Robber (synergy ID 15) - Necromancer Boneyard
    ["Boneyard"]             = 15,
    ["Unnerving Boneyard"]   = 15,
    ["Avid Boneyard"]        = 15,

    -- Pure Agony (synergy ID 9)
    ["Agony Totem"]          = 9,

    -- Runebreak (synergy ID 22) - Arcanist
    ["The Imperfect Ring"]   = 22,
    ["Rune of Displacement"] = 22,
    ["Fulminating Rune"]     = 22,

    -- Passage (synergy ID 23) - Arcanist portal
    ["Passage Between Worlds"] = 23,

    -- Hidden Refresh (synergy ID 17) - Nightblade
    ["Consuming Darkness"]   = 17,
    ["Bolstering Darkness"]  = 17,
    ["Veil of Blades"]       = 17,

    -- Conduit (synergy ID 8) - Sorcerer
    ["Lightning Splash"]     = 8,
    ["Liquid Lightning"]     = 8,
    ["Lightning Flood"]      = 8,

    -- Charged Lightning (synergy ID 10) - Sorcerer
    ["Summon Storm Atronach"]   = 10,
    ["Greater Storm Atronach"]  = 10,
    ["Summon Charged Atronach"] = 10,

    -- Nova (synergy ID 3) - Templar
    ["Nova"]                 = 3,
    ["Solar Prison"]         = 3,
    ["Solar Disturbance"]    = 3,

    -- Purify (synergy ID 13) - Templar
    ["Cleansing Ritual"]     = 13,
    ["Extended Ritual"]      = 13,
    ["Ritual of Retribution"] = 13,

    -- Harvest (synergy ID 14) - Warden
    ["Healing Seed"]         = 14,
    ["Budding Seeds"]        = 14,
    ["Corrupting Pollen"]    = 14,

    -- Icy Escape (synergy ID 16) - Warden
    ["Frozen Retreat"]       = 16,

    -- Feeding Frenzy (synergy ID 18) - Werewolf
    ["Howl of Despair"]      = 18,
}

-- Set synergy providers: set ID → synergy ID
-- Used to detect gear-based synergy sources via LibSetDetection
ST.SET_SYNERGY_PROVIDERS = {
    [817] = 24,    -- Recovery Convergence → Convergence Release (synergy ID 24)
}

-- ============================================================================
-- Ability ID → Synergy ID reverse lookup (built at load time)
-- ============================================================================

ST.abilityToSynergy = {}

-- Build reverse lookup
for synergyId, synergy in pairs(ST.SYNERGIES) do
    for _, abilityId in ipairs(synergy.abilityIds) do
        ST.abilityToSynergy[abilityId] = synergyId
    end
end

-- ============================================================================
-- Combustion / Shards Sub-Type Classification (Synergy ID 1)
-- Classifies source abilities (slotted skills) and activation abilities
-- (combat events) into "orb" or "shards" variants for icon differentiation.
-- ============================================================================

ST.SYNERGY1_SUBTYPE = "orb"  -- default sub-type for synergy 1

-- Source ability IDs (what the player SLOTS) → sub-type
ST.SYNERGY1_PROVIDER_SUBTYPE = {
    -- Orb variants
    [63498] = "orb",     -- Energy Orb
    [63470] = "orb",     -- Necrotic Orb
    [95957] = "orb",     -- Mystic Orb
    -- Shards variants
    [22234] = "shards",  -- Spear Shards
    [22465] = "shards",  -- Luminous Shards
    [22461] = "shards",  -- Blazing Spear
}

-- Source ability names → sub-type (fallback for ID drift)
ST.SYNERGY1_PROVIDER_NAME_SUBTYPE = {
    ["Energy Orb"]      = "orb",
    ["Necrotic Orb"]    = "orb",
    ["Mystic Orb"]      = "orb",
    ["Spear Shards"]    = "shards",
    ["Luminous Shards"] = "shards",
    ["Blazing Spear"]   = "shards",
}

-- Activation ability IDs (combat event) → sub-type
ST.SYNERGY1_ACTIVATION_SUBTYPE = {
    [85434] = "orb",     -- Combustion (Necrotic Orb, Mystic Orb)
    [63512] = "orb",     -- Healing Combustion (Energy Orb)
    [48052] = "shards",  -- Blessed Shards (Spear Shards)
    [95926] = "shards",  -- Holy Shards (Luminous Shards)
    [95924] = "shards",  -- Holy Shards (alternate ID)
}

-- Base ability IDs for icon lookup via GetAbilityIcon()
ST.SYNERGY1_BASE_ABILITY = {
    orb    = 63470,  -- Necrotic Orb (base undaunted orb)
    shards = 22234,  -- Spear Shards (base templar shards)
}

-- Last detected activation sub-type from combat events
-- Updated when the local player takes a Combustion/Shards synergy
ST.lastSynergy1ActivationSubtype = nil

-- ============================================================================
-- Ordered synergy lists for menus
-- ============================================================================

ST.DAMAGE_SYNERGIES = {}
ST.SUPPORT_SYNERGIES = {}
ST.ALL_SYNERGIES = {}

for synergyId, synergy in pairs(ST.SYNERGIES) do
    table.insert(ST.ALL_SYNERGIES, synergy)
    if synergy.category == ST.CATEGORY_DAMAGE then
        table.insert(ST.DAMAGE_SYNERGIES, synergy)
    elseif synergy.category == ST.CATEGORY_SUPPORT then
        table.insert(ST.SUPPORT_SYNERGIES, synergy)
    end
end

-- Sort alphabetically
local function sortByName(a, b) return a.name < b.name end
table.sort(ST.ALL_SYNERGIES, sortByName)
table.sort(ST.DAMAGE_SYNERGIES, sortByName)
table.sort(ST.SUPPORT_SYNERGIES, sortByName)

-- ============================================================================
-- Cooldown State
-- cooldowns[charName][synergyId] = timestampMs (when synergy was taken)
-- ============================================================================

ST.cooldowns = {}

-- ============================================================================
-- State
-- ============================================================================

ST.initialized = false
ST.pendingMessage = nil  -- Queued synergy message waiting to be sent
ST.logger = nil          -- Module logger instance
ST.auditCallbackName = "BeltalowdaSynergyAudit"
ST.auditRegistered = false

-- ============================================================================
-- API Functions
-- ============================================================================

--[[
    Record that a player used a synergy.
    @param charName: Character name of the player
    @param synergyId: Synergy ID (1-23)
    @param delayMs: Network delay in milliseconds (0 for local)
]]--
function ST.RecordSynergy(charName, synergyId, delayMs)
    if not charName or not synergyId then return end
    if not ST.SYNERGIES[synergyId] then return end

    ST.cooldowns[charName] = ST.cooldowns[charName] or {}
    ST.cooldowns[charName][synergyId] = GetGameTimeMilliseconds() - (delayMs or 0)
end

--[[
    Get remaining cooldown in milliseconds for a player's synergy.
    @return ms remaining (0 if ready)
]]--
function ST.GetCooldownRemaining(charName, synergyId)
    if not charName or not synergyId then return 0 end
    if not ST.cooldowns[charName] or not ST.cooldowns[charName][synergyId] then return 0 end

    local synergy = ST.SYNERGIES[synergyId]
    if not synergy then return 0 end

    local elapsed = GetGameTimeMilliseconds() - ST.cooldowns[charName][synergyId]
    local remaining = synergy.cooldown - elapsed
    return remaining > 0 and remaining or 0
end

--[[
    Get cooldown as a percentage (1.0 = just used, drains to 0.0).
    @return 0.0 to 1.0
]]--
function ST.GetCooldownPercent(charName, synergyId)
    if not charName or not synergyId then return 0 end

    local synergy = ST.SYNERGIES[synergyId]
    if not synergy then return 0 end

    local remaining = ST.GetCooldownRemaining(charName, synergyId)
    return remaining / synergy.cooldown
end

--[[
    Check if a player is on cooldown for a synergy.
    @return boolean
]]--
function ST.IsOnCooldown(charName, synergyId)
    return ST.GetCooldownRemaining(charName, synergyId) > 0
end

--[[
    Get all players currently on cooldown for a specific synergy.
    Returns sorted list of {charName, unitTag, remainingMs, percent}
    Sorted by remaining cooldown descending (most recent first).
]]--
function ST.GetPlayersOnCooldown(synergyId)
    local result = {}

    for charName, synergies in pairs(ST.cooldowns) do
        if synergies[synergyId] then
            local remaining = ST.GetCooldownRemaining(charName, synergyId)
            if remaining > 0 then
                local unitTag = ST.FindUnitTagForCharName(charName)
                table.insert(result, {
                    charName = charName,
                    unitTag = unitTag,
                    remainingMs = remaining,
                    percent = remaining / ST.COOLDOWN_MS,
                })
            end
        end
    end

    -- Sort by remaining cooldown descending (most recently used first)
    table.sort(result, function(a, b) return a.remainingMs > b.remainingMs end)
    return result
end

--[[
    Look up the synergy ID for an ESO ability ID.
    @return synergyId or nil
]]--
function ST.GetSynergyIdForAbilityId(abilityId)
    return ST.abilityToSynergy[abilityId]
end

--[[
    Get synergy data by ID.
    @return synergy table or nil
]]--
function ST.GetSynergyById(synergyId)
    return ST.SYNERGIES[synergyId]
end

--[[
    Find unitTag for a character name by scanning group.
]]--
function ST.FindUnitTagForCharName(charName)
    if not charName then return nil end

    -- Check player first
    if GetUnitName("player") == charName then
        return "player"
    end

    -- Scan group
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag and GetUnitName(unitTag) == charName then
            return unitTag
        end
    end

    return nil
end

-- ============================================================================
-- Combat Event Detection
-- ============================================================================

--[[
    Combat event handler for synergy detection.
    Detects synergy activations for self and nearby group members.
    Two detection paths (matching RdK's approach):
      1. Target is self or group member → direct detection
      2. Source is self (we cast the skill) and someone else took it
    We broadcast only OUR OWN synergy usage to the network so other
    Beltalowda clients learn about us even if out of combat range.
]]--
function ST.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType,
    hitValue, powerType, damageType, isLog, sourceUnitId, targetUnitId, abilityId)

    -- Accept effect gained and effect gained with duration (matching RdK)
    if result ~= ACTION_RESULT_EFFECT_GAINED
        and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION then
        return
    end

    local synergyId = ST.abilityToSynergy[abilityId]
    if not synergyId then return end

    -- Only detect when the LOCAL player is the one who took the synergy.
    -- Other group members' Beltalowda instances will broadcast their own usage.
    if targetName ~= GetRawUnitName("player") then return end

    -- Resolve target character name (strip raw name decorators)
    local charName = zo_strformat("<<1>>", targetName)
    if not charName or charName == "" then return end

    -- Record locally
    ST.RecordSynergy(charName, synergyId, 0)
    
    -- Track Combustion/Shards sub-type for icon differentiation
    if synergyId == 1 and ST.SYNERGY1_ACTIVATION_SUBTYPE[abilityId] then
        ST.lastSynergy1ActivationSubtype = ST.SYNERGY1_ACTIVATION_SUBTYPE[abilityId]
    end

    -- Broadcast to group so everyone's tracker updates
    ST.pendingMessage = {
        synergyId = synergyId,
        timeStamp = GetGameTimeMilliseconds(),
        sent = false,
    }
    ST.SendPendingMessage()
end

--[[
    Send pending synergy message via network.
]]--
function ST.SendPendingMessage()
    if not ST.pendingMessage or ST.pendingMessage.sent then return end

    local BeltalowdaNetwork = Beltalowda.network
    if not BeltalowdaNetwork or not BeltalowdaNetwork.BroadcastSynergy then return end

    -- Calculate delay since detection
    local delayMs = GetGameTimeMilliseconds() - ST.pendingMessage.timeStamp
    local delay100ms = math.floor(delayMs / 100)  -- Convert to 100ms units
    delay100ms = math.min(delay100ms, 255)  -- Cap at 255 (25.5 seconds)

    BeltalowdaNetwork.BroadcastSynergy(ST.pendingMessage.synergyId, delay100ms)
    ST.pendingMessage.sent = true
    ST.pendingMessage = nil
end

-- ============================================================================
-- Synergy Audit Logging
-- Controlled by the Synergy module log level in settings:
--   DEBUG   = Log confirmed synergy activations (matched ability IDs)
--   VERBOSE = Log ALL EFFECT_GAINED on self (for discovering new ability IDs)
-- ============================================================================

--[[
    Register or unregister the audit combat event listener
    based on the current Synergy module log level.
]]--
function ST.UpdateAuditRegistration()
    local Logger = Beltalowda.Logger
    if not Logger then return end

    local level = Logger.GetModuleLevel("Synergy")
    local needsAudit = (level >= Logger.Levels.DEBUG)

    if needsAudit and not ST.auditRegistered then
        -- Register an UNFILTERED listener to see ALL EFFECT_GAINED on self
        EVENT_MANAGER:RegisterForEvent(ST.auditCallbackName, EVENT_COMBAT_EVENT,
            ST.OnAuditCombatEvent)
        ST.auditRegistered = true
        if ST.logger then
            ST.logger:Info("Synergy audit listener ENABLED (level: %s)",
                Logger.LevelNames[level] or "?")
        end
        d("[Beltalowda] Synergy audit logging active — set Synergy module to ERROR to disable")
    elseif not needsAudit and ST.auditRegistered then
        EVENT_MANAGER:UnregisterForEvent(ST.auditCallbackName, EVENT_COMBAT_EVENT)
        ST.auditRegistered = false
        if ST.logger then
            ST.logger:Info("Synergy audit listener DISABLED")
        end
    end
end

--[[
    Audit combat event handler.
    Logs EFFECT_GAINED events on self based on log level:
      DEBUG:   only known synergy ability IDs
      VERBOSE: all ability IDs (full firehose)
]]--
function ST.OnAuditCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType,
    hitValue, powerType, damageType, isLog, sourceUnitId, targetUnitId, abilityId)

    if result ~= ACTION_RESULT_EFFECT_GAINED then return end
    if targetName ~= GetRawUnitName("player") then return end

    local Logger = Beltalowda.Logger
    local level = Logger and Logger.GetModuleLevel("Synergy") or 1

    local knownSynergy = ST.abilityToSynergy[abilityId]
    if knownSynergy then
        local synergy = ST.SYNERGIES[knownSynergy]
        d(string.format("[Beltalowda|Synergy] CONFIRMED | id=%d | %s | synergyId=%d | %s | src=%s",
            abilityId, abilityName or "?", knownSynergy, synergy and synergy.name or "?", sourceName or ""))
    elseif level >= (Logger and Logger.Levels.VERBOSE or 5) then
        -- Full firehose: print ALL effects at VERBOSE level
        d(string.format("[Beltalowda|Synergy] EFFECT | id=%d | %s | src=%s | srcType=%s",
            abilityId, abilityName or "", sourceName or "", tostring(sourceType)))
    end
end

-- ============================================================================
-- Initialization
-- ============================================================================

--[[
    Initialize synergy tracking.
    Registers combat event filters for all tracked synergy ability IDs.
    Sets up audit logging based on the Synergy module log level.
]]--
function ST.Initialize()
    if ST.initialized then return end

    -- Create the Synergy module logger
    if Beltalowda.Logger then
        ST.logger = Beltalowda.Logger.CreateModuleLogger("Synergy")

        -- Register for level change notifications so audit toggles automatically
        Beltalowda.Logger.RegisterLevelChangeCallback("Synergy", function(newLevel)
            ST.UpdateAuditRegistration()
        end)
    end

    -- Register combat event for each tracked ability ID
    local eventName = "BeltalowdaSynergyTracker"
    local filterIndex = 1

    for abilityId, _ in pairs(ST.abilityToSynergy) do
        EVENT_MANAGER:RegisterForEvent(
            eventName .. filterIndex,
            EVENT_COMBAT_EVENT,
            ST.OnCombatEvent
        )
        EVENT_MANAGER:AddFilterForEvent(
            eventName .. filterIndex,
            EVENT_COMBAT_EVENT,
            REGISTER_FILTER_ABILITY_ID, abilityId
        )
        filterIndex = filterIndex + 1
    end

    -- Register a periodic update to resend pending messages (fallback)
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaSynergyTrackerMessageLoop", 200, function()
        ST.SendPendingMessage()
    end)

    -- Enable audit logging if the Synergy log level is already set high enough
    ST.UpdateAuditRegistration()

    ST.initialized = true
end

--[[
    Clean up expired cooldowns (optional, called periodically).
    Removes entries older than cooldown duration to prevent memory growth.
]]--
function ST.CleanupExpiredCooldowns()
    local now = GetGameTimeMilliseconds()
    for charName, synergies in pairs(ST.cooldowns) do
        for synergyId, timestamp in pairs(synergies) do
            local synergy = ST.SYNERGIES[synergyId]
            if synergy and (now - timestamp) > synergy.cooldown then
                synergies[synergyId] = nil
            end
        end
        -- Remove empty player entries
        if next(synergies) == nil then
            ST.cooldowns[charName] = nil
        end
    end
end
