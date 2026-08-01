-- Beltalowda Buff Database
-- Central catalog of group-wide buffs and their sources (sets and abilities).
-- Only sources that provide the buff to the ENTIRE GROUP are tracked here.
-- Self-only sources are intentionally excluded.
--
-- This is the single source of truth for buff→source mappings. SetDatabase
-- and Composition both reference this file.

Beltalowda = Beltalowda or {}
Beltalowda.Data = Beltalowda.Data or {}
Beltalowda.Data.BuffDatabase = {}

local BuffDB = Beltalowda.Data.BuffDatabase

-- ============================================================================
-- Buff Definitions
-- ============================================================================

-- Maximum number of buff bits in the bitmask (for BuffComposition protocol 226)
BuffDB.MAX_BUFF_BITS = 8  -- Room for future expansion (currently 3 used)
BuffDB.MAX_BITMASK_VALUE = 255  -- 2^8 - 1

--[[
    BUFF_DEFINITIONS: Master table of group-wide buffs.
    
    Each entry is keyed by buff name and contains:
      - buffId:             Sequential ID (1-based) for bitmask bit position
      - type:               "offensive" or "defensive"
      - description:        Human-readable description of the buff effect
      - groupSetSources:    { [setId] = "Set Name" } — sets that provide this
                            buff to the group when at full bonus (5/5)
      - groupAbilitySources:{ [abilityId] = "Ability Name" } — abilities that
                            provide this buff to the group when slotted
      - groupAbilityNames:  { ["Ability Name"] = true } — name-based fallback
                            for ability detection (mirrors SynergyTracker pattern)
]]--
BuffDB.BUFF_DEFINITIONS = {
    ["Major Courage"] = {
        buffId = 1,
        type = "offensive",
        description = "Increase Weapon and Spell Damage by 430",
        groupSetSources = {
            [185] = "Spell Power Cure",
            [391] = "Vestment of Olorime",
            -- Perfected Olorime: ID TBD (to be added when provided)
        },
        groupAbilitySources = {},
        groupAbilityNames = {},
    },
    ["Major Resolve"] = {
        buffId = 2,
        type = "defensive",
        description = "Increases physical and spell resistance by 5948",
        groupSetSources = {},
        groupAbilitySources = {
            -- Frost Cloak and morphs (Warden skill line)
            -- These apply Major Resolve to nearby group members
            [86122] = "Frost Cloak",
            [86126] = "Expansive Frost Cloak",
            [86130] = "Ice Fortress",
        },
        groupAbilityNames = {
            ["Frost Cloak"] = true,
            ["Expansive Frost Cloak"] = true,
            ["Ice Fortress"] = true,
        },
    },
    ["Major Evasion"] = {
        buffId = 3,
        type = "defensive",
        description = "Reduces damage from area attacks by 20%",
        groupSetSources = {
            [261] = "Gossamer",
        },
        groupAbilitySources = {},
        groupAbilityNames = {},
        -- Individual sources: abilities that provide this buff to the caster only.
        -- Tracked separately so the composition check can verify per-player coverage
        -- while still recognizing that a group source (Gossamer) covers everyone.
        individualBuffId = 4,
        individualAbilitySources = {
            [29556] = "Evasion",
            [39195] = "Shuffle",
            [39192] = "Elude",
        },
        individualAbilityNames = {
            ["Evasion"] = true,
            ["Shuffle"] = true,
            ["Elude"] = true,
        },
    },
    ["Immunity to Snares and Immobilizations"] = {
        buffId = 5,
        type = "defensive",
        description = "Immune to snares and immobilizations",
        groupSetSources = {
            [519] = "Snow Treaders",
        },
        groupAbilitySources = {},
        groupAbilityNames = {},
        -- Per-player check: each player must bring their own source.
        -- Unlike group buffs, one player having it does NOT cover the group.
        perPlayer = true,
        -- Scribing sources: crafted abilities that provide this buff when
        -- assembled with a specific focus script.
        scribingSources = {
            {
                craftedAbilityId = 12,       -- Banner Bearer (grimoire support skill)
                focusScriptId    = 15,       -- Immobilize focus
                resolvedAbilityId = 230289,  -- Banner Bearer with Immobilize = "Binding Banner"
                description      = "Banner Bearer with Immobilize focus",
            },
        },
        -- Custom display: "Immunity to Snares and Immobilizations from <source>" using localized names
        displayPrefix = "Immunity to Snares and Immobilizations",
    },
    ["Minor Toughness"] = {
        buffId = 6,
        type = "defensive",
        description = "Increases Max Health by 10%",
        groupSetSources = {},
        groupAbilitySources = {},
        groupAbilityNames = {},
        -- Passive ability sources: class passives that provide this buff to the
        -- group when purchased. Detected by scanning the player's class skill
        -- lines for purchased passives matching the ability name.
        classPassiveSources = {
            { abilityName = "Maturation" },  -- Warden Green Balance passive (abilityId 85881)
        },
    },
}

-- ============================================================================
-- Reverse Lookup Tables (built at load time)
-- ============================================================================

-- setId → buff name (for sets that provide group buffs)
BuffDB.setToBuff = {}

-- abilityId → buff name (for abilities that provide group buffs)
BuffDB.abilityToBuff = {}

-- abilityName → buff name (name-based fallback)
BuffDB.abilityNameToBuff = {}

-- individual abilityId → buff name (for self-only buff abilities)
BuffDB.individualAbilityToBuff = {}

-- individual abilityName → buff name (name-based fallback for self-only)
BuffDB.individualAbilityNameToBuff = {}

-- buffId → buff name (for bitmask decoding)
BuffDB.idToBuff = {}

-- Set of bit IDs that represent individual (self-only) buff sources
BuffDB.individualBitIds = {}

-- Build reverse lookup tables
for buffName, def in pairs(BuffDB.BUFF_DEFINITIONS) do
    -- Set sources
    for setId, _ in pairs(def.groupSetSources) do
        BuffDB.setToBuff[setId] = buffName
    end
    -- Ability sources (ID-based)
    for abilityId, _ in pairs(def.groupAbilitySources) do
        BuffDB.abilityToBuff[abilityId] = buffName
    end
    -- Ability sources (name-based fallback)
    for abilityName, _ in pairs(def.groupAbilityNames) do
        BuffDB.abilityNameToBuff[abilityName] = buffName
    end
    -- Individual ability sources (self-only buffs)
    if def.individualAbilitySources then
        for abilityId, _ in pairs(def.individualAbilitySources) do
            BuffDB.individualAbilityToBuff[abilityId] = buffName
        end
    end
    if def.individualAbilityNames then
        for abilityName, _ in pairs(def.individualAbilityNames) do
            BuffDB.individualAbilityNameToBuff[abilityName] = buffName
        end
    end
    -- ID to name (both group and individual bits)
    BuffDB.idToBuff[def.buffId] = buffName
    if def.individualBuffId then
        BuffDB.idToBuff[def.individualBuffId] = buffName
        BuffDB.individualBitIds[def.individualBuffId] = true
    end
end

-- ============================================================================
-- Public API
-- ============================================================================

--[[
    Get the buff name that a given set provides to the group.
    @param setId: Numeric set ID
    @return: Buff name string, or nil if this set doesn't provide a group buff
]]--
function BuffDB.GetBuffForSet(setId)
    return BuffDB.setToBuff[setId]
end

--[[
    Get the buff name that a given ability provides to the group.
    First checks by ability ID, then falls back to name-based lookup.
    @param abilityId: Numeric ability ID
    @return: Buff name string, or nil if this ability doesn't provide a group buff
]]--
function BuffDB.GetBuffForAbility(abilityId)
    -- Fast path: direct ID lookup
    local buffName = BuffDB.abilityToBuff[abilityId]
    if buffName then return buffName end

    -- Fallback: name-based lookup
    local abilityName = GetAbilityName(abilityId)
    if abilityName and abilityName ~= "" then
        buffName = BuffDB.abilityNameToBuff[abilityName]
        if buffName then
            -- Cache the ID mapping for future lookups
            BuffDB.abilityToBuff[abilityId] = buffName
        end
    end
    return buffName
end

--[[
    Get the buff name that a given ability provides individually (self-only).
    First checks by ability ID, then falls back to name-based lookup.
    @param abilityId: Numeric ability ID
    @return: Buff name string, or nil if this ability doesn't provide an individual buff
]]--
function BuffDB.GetIndividualBuffForAbility(abilityId)
    local buffName = BuffDB.individualAbilityToBuff[abilityId]
    if buffName then return buffName end

    local abilityName = GetAbilityName(abilityId)
    if abilityName and abilityName ~= "" then
        buffName = BuffDB.individualAbilityNameToBuff[abilityName]
        if buffName then
            BuffDB.individualAbilityToBuff[abilityId] = buffName
        end
    end
    return buffName
end

--[[
    Get the buff definition by buff ID (for bitmask decoding).
    @param buffId: Numeric buff ID (1-based)
    @return: Buff definition table, or nil
]]--
function BuffDB.GetBuffById(buffId)
    local buffName = BuffDB.idToBuff[buffId]
    if buffName then
        return BuffDB.BUFF_DEFINITIONS[buffName]
    end
    return nil
end

--[[
    Get the buff definition by name.
    @param buffName: Buff name string (e.g., "Major Courage")
    @return: Buff definition table, or nil
]]--
function BuffDB.GetBuff(buffName)
    return BuffDB.BUFF_DEFINITIONS[buffName]
end

--[[
    Get the set sources that provide a given buff to the group.
    @param buffName: Buff name string
    @return: Table of { [setId] = "Set Name" }, or empty table
]]--
function BuffDB.GetGroupSetSourcesForBuff(buffName)
    local def = BuffDB.BUFF_DEFINITIONS[buffName]
    if def then
        return def.groupSetSources
    end
    return {}
end

--[[
    Get an ordered list of all buff names, sorted by buffId.
    @return: Array of buff name strings
]]--
function BuffDB.GetAllBuffNames()
    local names = {}
    for buffName, def in pairs(BuffDB.BUFF_DEFINITIONS) do
        names[def.buffId] = buffName
    end
    -- Convert to dense array
    local result = {}
    for _, name in ipairs(names) do
        if name then
            table.insert(result, name)
        end
    end
    return result
end

--[[
    Get all buff names of a specific type ("offensive" or "defensive").
    @param buffType: "offensive" or "defensive"
    @return: Array of buff name strings, sorted by buffId
]]--
function BuffDB.GetBuffNamesByType(buffType)
    local result = {}
    for buffName, def in pairs(BuffDB.BUFF_DEFINITIONS) do
        if def.type == buffType then
            table.insert(result, { name = buffName, id = def.buffId })
        end
    end
    table.sort(result, function(a, b) return a.id < b.id end)
    local names = {}
    for _, entry in ipairs(result) do
        table.insert(names, entry.name)
    end
    return names
end

--[[
    Build a human-readable description of all known sources for a buff.
    Used for tooltip text in settings UI.
    @param buffName: Buff name string
    @return: String listing all sources
]]--
function BuffDB.GetSourceDescription(buffName)
    local def = BuffDB.BUFF_DEFINITIONS[buffName]
    if not def then return "" end

    local parts = {}

    -- Set sources
    local setNames = {}
    for _, setName in pairs(def.groupSetSources) do
        table.insert(setNames, setName)
    end
    if #setNames > 0 then
        table.sort(setNames)
        table.insert(parts, "Sets: " .. table.concat(setNames, ", "))
    end

    -- Ability sources
    local abilityNames = {}
    for _, abilityName in pairs(def.groupAbilitySources) do
        abilityNames[abilityName] = true  -- deduplicate
    end
    local sortedAbilities = {}
    for name, _ in pairs(abilityNames) do
        table.insert(sortedAbilities, name)
    end
    if #sortedAbilities > 0 then
        table.sort(sortedAbilities)
        table.insert(parts, "Abilities: " .. table.concat(sortedAbilities, ", "))
    end

    -- Individual ability sources
    if def.individualAbilitySources then
        local indivNames = {}
        for _, name in pairs(def.individualAbilitySources) do
            indivNames[name] = true
        end
        local sortedIndiv = {}
        for name, _ in pairs(indivNames) do
            table.insert(sortedIndiv, name)
        end
        if #sortedIndiv > 0 then
            table.sort(sortedIndiv)
            table.insert(parts, "Individual: " .. table.concat(sortedIndiv, ", "))
        end
    end

    -- Class passive sources
    if def.classPassiveSources then
        local passiveNames = {}
        for _, passiveSource in ipairs(def.classPassiveSources) do
            table.insert(passiveNames, passiveSource.abilityName)
        end
        if #passiveNames > 0 then
            table.sort(passiveNames)
            table.insert(parts, "Passives: " .. table.concat(passiveNames, ", "))
        end
    end

    if #parts == 0 then
        return "No known sources"
    end
    return table.concat(parts, "\n")
end
