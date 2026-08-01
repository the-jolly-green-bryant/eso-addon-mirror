-- Beltalowda Set Database
-- Comprehensive database of sets for role detection and composition analysis

Beltalowda = Beltalowda or {}
Beltalowda.SetDatabase = {}

local SetDB = Beltalowda.SetDatabase

--[[
    PvP Role Categories:
    - damage: Primary damage dealers (catch-all role)
    - support: Buff/healing/utility focused
    - pull: Mobility control and enemy grouping (highest priority, overrides others)
]]--

-- Pull sets (highest priority - override any other detection)
SetDB.PULL_SETS = {
    [267] = "Swarm Mother",
    [558] = "Void Bash",
    [604] = "Rush of Agony",
    [616] = "Dark Convergence",
    [792] = "Farstrider",
}

-- Support sets (buffs, heals, utility)
SetDB.SUPPORT_SETS = {
    -- Regular sets (support)
    [122] = "Ebon Armory",
    [123] = "Hircine's Veneer",
    [124] = "Worm's Raiment",
    [180] = "Powerful Assault",
    [184] = "Brands of the Imperium",
    [185] = "Spell Power Cure",
    [261] = "Gossamer",
    [341] = "Earthgore",
    [346] = "Jorvuld's Guidance",
    [391] = "Vestment of Olorime",
    [436] = "Symphony of Blades",
    [518] = "Arkasis' Genius",
    [629] = "Rallying Cry",
    [685] = "Apocryphal Inspiration",
    [768] = "Lucent Echoes",
    [818] = "Recovery Convergence",
    -- Monster sets (support)
    [163] = "Bloodspawn",
    [164] = "Lord Warden",
    [166] = "Engine Guardian",
    [167] = "Nightflame",
    [268] = "Sentinel of Rkugamz",
    [278] = "Troll King",
}

-- Damage sets (heavy weight indicators)
SetDB.DAMAGE_SETS = {
    [225] = "Clever Alchemist",
    [232] = "Roar of Alkosh",
    [236] = "Vicious Death",
    [617] = "Plaguebreak",
    [618] = "Hrothgar's Chill",
    [688] = "Snake in the Stars",
    [830] = "Spellshredder",
    -- Mythic sets (damage)
    [520] = "Malacath's Band of Brutality",
    [575] = "Ring of the Pale Order",
    [625] = "Markyn Ring of Majesty",
    [626] = "Belharza's Band",
    [654] = "Mora's Whispers",
    [657] = "Sea-Serpent's Coil",
    [762] = "The Saint and the Seducer",
    [811] = "Mad God's Dancing Shoes",
    [812] = "Rakkhat's Voidmantle",
    [813] = "Monomyth Reforged",
    [845] = "Huntsman's Warmask",
    [848] = "Shattered Paths Signet",
    -- Mythic sets (defensive/utility)
    [519] = "Snow Treaders",
    -- Monster sets (damage)
    [169] = "Valkyn Skoria",
    [170] = "Maw of the Infernal",
    [257] = "Velidreth",
    [266] = "Kra'gh",
    [270] = "Slimecraw",
    [272] = "Infernal Guardian",
    [273] = "Ilambris",
    [274] = "Iceheart",
    [275] = "Stormfist",
    [279] = "Selene",
    [280] = "Grothdarr",
    [349] = "Thurvokun",
    [350] = "Zaan",
    [397] = "Balorgh",
    [711] = "Colovian Highlands General",
}

-- Ultimate-spending sets (sets whose bonuses scale with total ult spent)
-- Used to flag players sitting on 500 ult with unused potential
SetDB.ULT_SPENDING_SETS = {
    [397] = "Balorgh",
    [649] = "Pillager's Profit",
    [650] = "Perfected Pillager's Profit",
    [691] = "Cryptcanon Vestments",
    [848] = "Shattered Paths Signet",

}

-- Set weights for role detection
SetDB.WEIGHTS = {
    PULL = 10,      -- Highest priority, overrides everything
    SUPPORT = 3,    -- Clear support indicator
    DAMAGE = 2,     -- Clear damage indicator
}

--[[
    Check if a player has any ultimate-spending set equipped
    @param setData: Equipment data from LibSetDetection (raw set table)
    @return: boolean, string|nil (true + set name if found)
]]--
function SetDB.HasUltSpendingSet(setData)
    if not setData or type(setData) ~= "table" then
        return false, nil
    end
    for setId, _ in pairs(setData) do
        if type(setId) == "number" and SetDB.ULT_SPENDING_SETS[setId] then
            return true, SetDB.ULT_SPENDING_SETS[setId]
        end
    end
    return false, nil
end

--[[
    Detect player role based on equipped sets
    @param setData: Equipment data from LibSetDetection
    @return: "damage", "support", or "pull"
]]--
function SetDB.DetectRole(setData)
    if not setData or type(setData) ~= "table" then
        return "damage"  -- Default
    end
    
    local roleScores = { pull = 0, support = 0, damage = 0 }
    
    -- Check each equipped set
    for setId, setInfo in pairs(setData) do
        if type(setId) == "number" then
            -- Check for pull sets (highest priority)
            if SetDB.PULL_SETS[setId] then
                roleScores.pull = roleScores.pull + SetDB.WEIGHTS.PULL
            end
            
            -- Check for support sets
            if SetDB.SUPPORT_SETS[setId] then
                roleScores.support = roleScores.support + SetDB.WEIGHTS.SUPPORT
            end
            
            -- Check for damage sets
            if SetDB.DAMAGE_SETS[setId] then
                roleScores.damage = roleScores.damage + SetDB.WEIGHTS.DAMAGE
            end
        end
    end
    
    -- Pull role overrides everything (highest score)
    if roleScores.pull > 0 then
        return "pull"
    end
    
    -- Otherwise, highest score wins
    if roleScores.support > roleScores.damage then
        return "support"
    end
    
    return "damage"  -- Default to damage
end

--[[
    Extract "useful bits" from equipment data for broadcasting
    @param setData: Equipment data from LibSetDetection
    @return: Table with role, sets, and buffs provided
]]--

-- LSD set type constants (from LibSetDetection)
local LSD_SET_TYPE_NORMAL = 0
local LSD_SET_TYPE_MYSTICAL = 1    -- Mythics (1-piece)
local LSD_SET_TYPE_UNDAUNTED = 2   -- Monster sets (2-piece)
local LSD_SET_TYPE_ABILITY_ALTERING = 3  -- Arena weapons (2-piece)

-- ESO quality tier constants
-- ITEM_FUNCTIONAL_QUALITY_TRASH      = 0  (gray)
-- ITEM_FUNCTIONAL_QUALITY_NORMAL     = 1  (white)
-- ITEM_FUNCTIONAL_QUALITY_MAGIC      = 2  (green)
-- ITEM_FUNCTIONAL_QUALITY_ARCANE     = 3  (blue)
-- ITEM_FUNCTIONAL_QUALITY_ARTIFACT   = 4  (purple)
-- ITEM_FUNCTIONAL_QUALITY_LEGENDARY  = 5  (gold)
-- Synthetic:  6 = Mythic (orange) — not an ESO constant, used internally
local QUALITY_MYTHIC = 6

-- Equipment slots to scan for quality detection (BAG_WORN)
local WORN_EQUIPMENT_SLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

--[[
    Scan the local player's worn equipment to determine the minimum quality
    per equipped set.
    @return: Table mapping setId → minimum quality (0-5)
]]--
local function ScanLocalPlayerSetQualities()
    local minQualityPerSet = {}
    for _, slotIndex in ipairs(WORN_EQUIPMENT_SLOTS) do
        if slotIndex ~= nil then  -- Guard against undefined slot constants
            local hasSet, _, _, _, _, setId = GetItemSetInfo(BAG_WORN, slotIndex)
            if hasSet and setId and setId > 0 then
                local quality = GetItemFunctionalQuality(BAG_WORN, slotIndex)
                if quality and quality >= 0 then
                    local prev = minQualityPerSet[setId]
                    if prev == nil or quality < prev then
                        minQualityPerSet[setId] = quality
                    end
                end
            end
        end
    end
    return minQualityPerSet
end

--[[
    Get the sort tier for a set based on its type and completion status.
    Lower tier = displayed first.
    Tier 1: Monster sets (complete)
    Tier 2: Mythics
    Tier 3: Arena weapons (complete)
    Tier 4: Normal sets (complete)
    Tier 5: Incomplete sets (any type)
]]--
local function GetSetSortTier(setEntry)
    local isComplete = setEntry.pieces >= setEntry.maxPieces
    if not isComplete then
        return 5  -- All incomplete sets at the bottom
    end
    local setType = setEntry.setType or LSD_SET_TYPE_NORMAL
    if setType == LSD_SET_TYPE_UNDAUNTED then
        return 1  -- Monster sets first
    elseif setType == LSD_SET_TYPE_MYSTICAL then
        return 2  -- Mythics second
    elseif setType == LSD_SET_TYPE_ABILITY_ALTERING then
        return 3  -- Arena weapons third
    else
        return 4  -- Normal complete sets
    end
end

--[[
    Comparator for sorting sets in the desired display order.
    Within each tier: alphabetical by name.
    For incomplete sets (tier 5): by piece count descending, then alphabetical.
]]--
function SetDB.CompareSetOrder(a, b)
    local tierA = GetSetSortTier(a)
    local tierB = GetSetSortTier(b)
    if tierA ~= tierB then
        return tierA < tierB
    end
    -- Within incomplete tier, sort by pieces descending
    if tierA == 5 then
        if a.pieces ~= b.pieces then
            return a.pieces > b.pieces
        end
    end
    -- Tie-break alphabetically
    return (a.name or "") < (b.name or "")
end

function SetDB.ExtractUsefulBits(setData)
    if not setData or type(setData) ~= "table" then
        return {
            role = "damage",
            sets = {},
            buffsProvided = {},
            warnings = {}
        }
    end
    
    local result = {
        role = SetDB.DetectRole(setData),
        sets = {},
        buffsProvided = {},
        warnings = {}
    }
    
    -- Scan local player's worn equipment for minimum quality per set
    local minQualities = ScanLocalPlayerSetQualities()
    
    -- Extract notable sets (only sets with 5 pieces)
    for setId, setInfo in pairs(setData) do
        if type(setId) == "number" and setInfo then
            local pieceCount = 0
            local barInfo = ""  -- Track which bar(s) have this set
            if setInfo.numEquip then
                local bodyCount = setInfo.numEquip.body or 0
                local frontCount = setInfo.numEquip.front or 0
                local backCount = setInfo.numEquip.back or 0
                
                -- Weapons don't stack between bars - only one bar is active at a time
                -- So the actual piece count is: body + max(front, back)
                local weaponCount = math.max(frontCount, backCount)
                pieceCount = bodyCount + weaponCount
                
                -- Determine bar information for display
                if frontCount > 0 and backCount > 0 then
                    barInfo = " (Both Bars)"
                elseif frontCount > 0 then
                    barInfo = " (Front Bar)"
                elseif backCount > 0 then
                    barInfo = " (Back Bar)"
                end
            end
            
            -- Include sets that meet their activation threshold (filters out incomplete sets upstream via LibSetDetection)
            if pieceCount >= 1 then
                local setName = SetDB.PULL_SETS[setId] or 
                                SetDB.SUPPORT_SETS[setId] or 
                                SetDB.DAMAGE_SETS[setId] or
                                SetDB.ULT_SPENDING_SETS[setId] or
                                (setInfo.setName or "Unknown Set")
                
                -- Capture set type from LibSetDetection data
                local setType = setInfo.setType
                if setType == nil and LibSetDetection and LibSetDetection.GetSetType then
                    setType = LibSetDetection.GetSetType(setId)
                end
                
                -- Determine quality: mythics always orange, others use min piece quality
                local quality = 5  -- Default to Legendary if unknown
                if setType == LSD_SET_TYPE_MYSTICAL then
                    quality = QUALITY_MYTHIC  -- Mythic (orange)
                elseif minQualities[setId] then
                    quality = minQualities[setId]
                end
                
                table.insert(result.sets, {
                    id = setId,
                    name = setName,
                    pieces = pieceCount,
                    maxPieces = SetDB.GetSetMaxPieces(setId),
                    barInfo = barInfo,
                    setType = setType or LSD_SET_TYPE_NORMAL,
                    quality = quality,
                })
                
                -- Add buffs this set provides (only for completed sets at full bonus)
                local setMaxPieces = SetDB.GetSetMaxPieces(setId)
                if pieceCount >= setMaxPieces then
                    local BuffDB = Beltalowda.Data and Beltalowda.Data.BuffDatabase
                    if BuffDB and BuffDB.GetBuffForSet then
                        local buffName = BuffDB.GetBuffForSet(setId)
                        if buffName then
                            local def = BuffDB.BUFF_DEFINITIONS[buffName]
                            if def and def.displayPrefix then
                                -- Use localized source-aware label
                                local setDisplayName = setName or ("Set #" .. tostring(setId))
                                table.insert(result.buffsProvided,
                                    string.format("%s from %s", def.displayPrefix, setDisplayName))
                            else
                                table.insert(result.buffsProvided, buffName)
                            end
                        end
                    end
                    -- Non-buff set-specific labels (sets that don't map to a standard buff)
                    if setId == 122 then  -- Ebon Armory
                        table.insert(result.buffsProvided, "Max Health")
                    elseif setId == 629 then  -- Rallying Cry
                        table.insert(result.buffsProvided, "Critical Resistance + Weapon/Spell Damage (Group)")
                    end
                end
            end
        end
    end
    
    -- Sort sets into consistent display order
    table.sort(result.sets, SetDB.CompareSetOrder)
    
    -- Check for common warnings
    -- TODO: Add skill-based checks when skill tracking is implemented
    -- For now, just flag if no support sets detected in a support role
    if result.role == "support" and #result.buffsProvided == 0 then
        table.insert(result.warnings, "Support role but no group buffs detected")
    end
    
    return result
end

--[[
    Get display name for a role
]]--
function SetDB.GetRoleDisplayName(role)
    if role == "pull" then
        return "Pull"
    elseif role == "support" then
        return "Support"
    else
        return "Damage"
    end
end

--[[
    Get color for a role
    @return: r, g, b values (0-1)
]]--
function SetDB.GetRoleColor(role)
    if role == "pull" then
        return 1, 0.5, 0  -- Orange
    elseif role == "support" then
        return 0.3, 1, 0.3  -- Green
    else
        return 1, 0.3, 0.3  -- Red (damage)
    end
end

--[[
    Get set name by ID
    @param setId: Set ID number
    @return: Set name string
]]--
function SetDB.GetSetName(setId)
    if not setId then return "Unknown Set" end
    
    -- First check our database for known sets
    local name = SetDB.PULL_SETS[setId] or
                 SetDB.SUPPORT_SETS[setId] or
                 SetDB.DAMAGE_SETS[setId] or
                 SetDB.ULT_SPENDING_SETS[setId]
    
    if name then
        return name
    end
    
    -- Fallback 1: Use ESO's native GetItemSetInfo() API to get set name by ID
    -- This works for ANY set ID regardless of who's wearing it
    local hasSet, setName = GetItemSetInfo(setId)
    if hasSet and setName and setName ~= "" then
        return setName
    end
    
    -- Fallback 2: Try LibSetDetection if available
    -- Check player first, then group members
    if LibSetDetection then
        -- Try player data
        local setData = LibSetDetection.GetUnitSetData("player")
        if setData and setData[setId] and setData[setId].setName then
            return setData[setId].setName
        end
        
        -- Try group members
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag then
                setData = LibSetDetection.GetUnitSetData(unitTag)
                if setData and setData[setId] and setData[setId].setName then
                    return setData[setId].setName
                end
            end
        end
    end
    
    return "Unknown Set"
end

--[[
    Get maximum equippable pieces for a set based on its type
    Monster sets (Undaunted) have max 2 pieces, regular sets have max 5
    
    @param setId: Set ID number
    @return: Max pieces (2 for monster sets, 5 for others, or 5 if unknown)
]]--
function SetDB.GetSetMaxPieces(setId)
    if not setId then
        return 5 -- Default to 5 if we can't determine
    end
    
    -- Try LibSetDetection first (most reliable for set type)
    if LibSetDetection then
        -- Try player data first
        local setData = LibSetDetection.GetUnitSetData("player")
        if setData and setData[setId] then
            local setInfo = setData[setId]
            if setInfo.maxEquip then
                return setInfo.maxEquip  -- Use maxEquip directly if available
            end
            -- Fallback: determine max pieces from set type
            -- LSD set types match ESO's native API: 0=Normal, 1=Mythic, 2=Undaunted(Monster), 3=AbilityAltering(Arena)
            if setInfo.setType == LSD_SET_TYPE_MYSTICAL then
                return 1  -- Mythic sets: 1 piece
            elseif setInfo.setType == LSD_SET_TYPE_UNDAUNTED or setInfo.setType == LSD_SET_TYPE_ABILITY_ALTERING then
                return 2  -- Monster sets and arena weapons: 2 pieces
            end
        end
        
        -- Try group members' data
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag then
                setData = LibSetDetection.GetUnitSetData(unitTag)
                if setData and setData[setId] then
                    local setInfo = setData[setId]
                    if setInfo.maxEquip then
                        return setInfo.maxEquip
                    end
                    if setInfo.setType == LSD_SET_TYPE_MYSTICAL then
                        return 1
                    elseif setInfo.setType == LSD_SET_TYPE_UNDAUNTED or setInfo.setType == LSD_SET_TYPE_ABILITY_ALTERING then
                        return 2
                    end
                end
            end
        end
    end
    
    return 5 -- Default to 5 for regular sets
end
