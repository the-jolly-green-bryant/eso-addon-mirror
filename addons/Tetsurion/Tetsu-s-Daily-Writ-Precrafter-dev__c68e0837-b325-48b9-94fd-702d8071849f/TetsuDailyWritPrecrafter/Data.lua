TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}
local Data = {}
TetsuDailyWritPrecrafter.Data = Data

-- CRAFTING_TYPE_BLACKSMITHING=1 CLOTHIER=2 ENCHANTING=3
-- ALCHEMY=4 PROVISIONING=5 WOODWORKING=6 JEWELRYCRAFTING=7
Data.CRAFT_BLACKSMITHING = 1
Data.CRAFT_CLOTHIER      = 2
Data.CRAFT_ENCHANTING    = 3
Data.CRAFT_WOODWORKING   = 6
Data.CRAFT_JEWELRY       = 7

local SECONDS_PER_DAY = 86400

-- Daily writs reset at 10:00 UTC on NA and 03:00 UTC on EU (Update 37+).
-- The old 06:00 UTC offset is wrong on both megaservers.
function Data.GetResetOffsetSeconds()
    local world = string.lower(GetWorldName() or "")
    if string.find(world, "eu", 1, true) then
        return 3 * 3600
    end
    return 10 * 3600
end

function Data.GetDayNumber()
    return math.floor((GetTimeStamp() - Data.GetResetOffsetSeconds()) / SECONDS_PER_DAY)
end

function Data.GetTodayPatternIndex()
    return (Data.GetDayNumber() % 3) + 1
end

function Data.GetDayKey()
    return tostring(Data.GetDayNumber())
end

-- Smithing materialIndex is NOT Metalworking rank 1..10.
-- Each rank maps to the first (lowest-level) row of that material in the station UI.
-- Values from the battle-tested LibLazyCrafting / Lazy Writ Crafter tables.
Data.EquipMaterialIndexByRank = { 1, 8, 13, 18, 23, 26, 29, 32, 34, 40 }
Data.JewelryMaterialIndexByRank = { 1, 13, 26, 33, 40 }

function Data.GetMaterialIndex(craftType, rank)
    rank = tonumber(rank) or 1
    if craftType == Data.CRAFT_JEWELRY then
        if rank < 1 then rank = 1 end
        if rank > 5 then rank = 5 end
        return Data.JewelryMaterialIndexByRank[rank] or 1
    end
    if rank < 1 then rank = 1 end
    if rank > 10 then rank = 10 end
    return Data.EquipMaterialIndexByRank[rank] or 1
end

local BONUS_GLOBAL = {
    [1] = "NON_COMBAT_BONUS_BLACKSMITHING_LEVEL",
    [2] = "NON_COMBAT_BONUS_CLOTHIER_LEVEL",
    [3] = "NON_COMBAT_BONUS_ENCHANTING_LEVEL",
    [4] = "NON_COMBAT_BONUS_ALCHEMY_LEVEL",
    [5] = "NON_COMBAT_BONUS_PROVISIONING_LEVEL",
    [6] = "NON_COMBAT_BONUS_WOODWORKING_LEVEL",
    [7] = "NON_COMBAT_BONUS_JEWELRYCRAFTING_LEVEL",
}

-- Runtime lookup: never bake SKILL_TYPE_* numeric fallbacks (6 is Alliance War, not tradeskill).
function Data.GetCraftingTier(craftType)
    local bonusName = BONUS_GLOBAL[craftType]
    local bonusId = bonusName and _G[bonusName]
    if bonusId then
        local tier = GetNonCombatBonus(bonusId)
        if tier and tier > 0 then
            return tier
        end
    end
    if GetCraftingSkillLineIndices then
        local skillType, skillIndex = GetCraftingSkillLineIndices(craftType)
        if skillType and skillIndex then
            local rank = GetSkillAbilityUpgradeInfo(skillType, skillIndex, 1)
            if rank and rank > 0 then
                return rank
            end
        end
    end
    return 1
end

function Data.GetMaxCraftingTier(craftType)
    if craftType == Data.CRAFT_JEWELRY or craftType == 7 then
        return 5
    end
    if craftType == 4 then
        return 8  -- Solvent Proficiency max
    end
    if craftType == 5 then
        return 6  -- Recipe Improvement max
    end
    return 10
end

function Data.IsMaxedIn(craftType)
    local tier = Data.GetCraftingTier(craftType)
    return tier >= Data.GetMaxCraftingTier(craftType)
end

-- Fallback 3-day item-type rotation. Used ONLY when no writ quest is in the journal.
-- Pattern indices are station-local (GetSmithingPatternInfo).
-- Blacksmithing: 1 Axe, 2 Mace, 3 Sword, 4 Battle Axe, 5 Maul, 6 Greatsword, 7 Dagger,
--                8 Cuirass, 9 Sabatons, 10 Gauntlets, 11 Greaves, 12 Pauldrons, 13 Helm
-- Woodworking:   1 Bow, 2 Shield, 3 Inferno, 4 Ice, 5 Lightning, 6 Restoration
-- Jewelry:       1 Ring, 2 Necklace
-- Clothier mixes light + medium; indices are verified against GetSmithingPatternInfo at the station
-- when a quest is present, so this table is a last resort.
Data.Patterns = {
    [1] = {
        [1] = { 8, 9, 10 },
        [2] = { 13, 3, 12 },
        [3] = { 11, 1, 2 },
    },
    [2] = {
        [1] = { 1, 7, 5 },
        [2] = { 11, 10, 13 },
        [3] = { 2, 4, 8 },
    },
    [6] = {
        [1] = { 1, 2, 6 },
        [2] = { 2, 1, 1 },
        [3] = { 3, 4, 5 },
    },
    -- Jewelry: patternIndex 1 = necklace, 2 = ring
    -- Daily writs: 2 necks | 3 rings | 1 neck + 1 ring
    [7] = {
        [1] = { 1, 1 },       -- 2 necklaces
        [2] = { 2, 2, 2 },    -- 3 rings
        [3] = { 1, 2 },       -- 1 necklace + 1 ring
    },
    [3] = {
        [1] = { 45832 }, -- Makko (Magicka)
        [2] = { 45833 }, -- Deni (Stamina)
        [3] = { 45831 }, -- Oko (Health)
    },
}

-- Additive potency used by daily Health/Magicka/Stamina armor glyphs.
-- IDs from UESP Online:Runestones. Rank 10 daily writs ask for CP160 (Repora).
Data.EnchantingPotency = {
    [1]  = 45855, -- Jora
    [2]  = 45857, -- Jera
    [3]  = 45807, -- Odra
    [4]  = 45809, -- Edora
    [5]  = 45811, -- Pora
    [6]  = 45813, -- Rera
    [7]  = 45814, -- Derado
    [8]  = 45815, -- Rekura
    [9]  = 45816, -- Kura
    [10] = 68341, -- Repora (CP160)
}

-- Rank 10 also commonly requests Rejera (CP150). Parser tries both.
Data.EnchantingPotencyAlt = {
    [10] = 64509, -- Rejera
}

Data.ESSENCE_OKO   = 45831
Data.ESSENCE_MAKKO = 45832
Data.ESSENCE_DENI  = 45833
Data.ASPECT_TA     = 45850
Data.EnchantingEssences = { 45831, 45832, 45833 }

-- Language-independent writ-board detection: match ANY locale keyword.
-- Avoids GetCVar("language.2") failures changing behaviour between clients.
Data.WritKeywords = {
    "writ", "schrieb", "commande", "encargo", "заказ", "委托", "依頼",
    "blacksmith", "clothier", "woodwork", "enchant", "alchem", "provision", "jewel",
    "кузнец", "портн", "столяр", "зачаров", "алхим", "снабжен", "ювел",
    "schmied", "schneider", "schreiner", "verzauber", "alchemie", "versorg", "schmuck",
    "forge", "coutur", "ebénist", "enchant", "alchim", "cuisine", "joaill",
    "herrer", "sastr", "carpinter", "encant", "alquim", "cocina", "joyer",
}

function Data.Lower(str)
    if not str or str == "" then return "" end
    local lowered = zo_strformat("<<z:1>>", str)
    if lowered and lowered ~= "" then
        return lowered
    end
    return string.lower(str)
end

function Data.TextLooksLikeWrit(text)
    if not text or text == "" then return false end
    local hay = Data.Lower(text)
    for i = 1, #Data.WritKeywords do
        if zo_plainstrfind(hay, Data.Lower(Data.WritKeywords[i])) then
            return true
        end
    end
    return false
end

function Data.FindItemInBags(itemId)
    if not itemId then return nil, nil end

    local bagSize = GetBagSize(BAG_BACKPACK) or 0
    for slotIndex = 0, bagSize - 1 do
        if GetItemId(BAG_BACKPACK, slotIndex) == itemId then
            local stack = GetSlotStackSize(BAG_BACKPACK, slotIndex)
            if stack and stack > 0 then
                return BAG_BACKPACK, slotIndex
            end
        end
    end

    if HasCraftBagAccess and HasCraftBagAccess() then
        local stack = GetSlotStackSize(BAG_VIRTUAL, itemId)
        if stack and stack > 0 then
            return BAG_VIRTUAL, itemId
        end
    end

    return nil, nil
end

-- Count item. includeBank=true also scans bank (for "already crafted" skip).
-- Craft pre-check must use includeBank=false — station only sees backpack + craft bag.
function Data.CountItemById(itemId, includeBank)
    if not itemId then return 0 end
    local total = 0
    local function countBag(bagId)
        local size = GetBagSize(bagId) or 0
        for slotIndex = 0, size - 1 do
            if GetItemId(bagId, slotIndex) == itemId then
                total = total + (GetSlotStackSize(bagId, slotIndex) or 0)
            end
        end
    end
    countBag(BAG_BACKPACK)
    if HasCraftBagAccess and HasCraftBagAccess() then
        total = total + (GetSlotStackSize(BAG_VIRTUAL, itemId) or 0)
    end
    if includeBank then
        countBag(BAG_BANK)
        if BAG_SUBSCRIBER_BANK then
            countBag(BAG_SUBSCRIBER_BANK)
        end
    end
    return total
end

function Data.GetItemNameById(itemId)
    if not itemId then return "?" end
    -- Craft bag slot == itemId when present
    if HasCraftBagAccess and HasCraftBagAccess() then
        local link = GetItemLink(BAG_VIRTUAL, itemId)
        if link and link ~= "" then
            return zo_strformat("<<t:1>>", GetItemLinkName(link))
        end
    end
    local bagSize = GetBagSize(BAG_BACKPACK) or 0
    for slotIndex = 0, bagSize - 1 do
        if GetItemId(BAG_BACKPACK, slotIndex) == itemId then
            local link = GetItemLink(BAG_BACKPACK, slotIndex)
            if link and link ~= "" then
                return zo_strformat("<<t:1>>", GetItemLinkName(link))
            end
        end
    end
    -- Fallback: build a minimal item link
    local fake = string.format("|H0:item:%d:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
    local name = GetItemLinkName(fake)
    if name and name ~= "" then
        return zo_strformat("<<t:1>>", name)
    end
    return tostring(itemId)
end

function Data.GetMaterialItemId(patternIndex, materialIndex)
    if not GetSmithingPatternMaterialItemLink then return nil end
    local link = GetSmithingPatternMaterialItemLink(patternIndex, materialIndex, LINK_STYLE_DEFAULT)
    if link and link ~= "" and GetItemLinkItemId then
        return GetItemLinkItemId(link), link
    end
    return nil, nil
end

function Data.GetStyleMaterialItemId(styleId)
    if not styleId or styleId < 1 then return nil, nil end
    if GetItemStyleMaterialLink then
        local link = GetItemStyleMaterialLink(styleId, LINK_STYLE_DEFAULT)
        if link and link ~= "" and GetItemLinkItemId then
            return GetItemLinkItemId(link), link
        end
    end
    return nil, nil
end

-- materialQuantity for CraftSmithingItem = how many bars/ounces to spend.
-- IMPORTANT: Do NOT read the 11th return of GetSmithingPatternMaterialItemInfo —
-- that is createsItemOfLevel (e.g. 160), NOT the material count. That bug made
-- pre-check demand 160 platinum per necklace instead of ~10–15.
function Data.GetRequiredMaterialQuantity(patternIndex, materialIndex)
    patternIndex = patternIndex or 1
    materialIndex = materialIndex or 1
    local craftType = GetCraftingInteractionType and GetCraftingInteractionType() or 0
    local trait = Data.TRAIT_NONE or 1
    local styleId = 1
    if craftType == Data.CRAFT_JEWELRY or craftType == 7 then
        styleId = 0
    elseif Data.GetAvailableStyleId then
        styleId = Data.GetAvailableStyleId(patternIndex) or 1
    end

    if GetSmithingPatternResultLink then
        local candidates = { 7, 8, 9, 10, 11, 12, 13, 14, 15, 6, 5, 4, 3, 2, 1, 16, 18, 20 }
        if craftType == Data.CRAFT_JEWELRY or craftType == 7 then
            candidates = { 10, 15, 8, 12, 7, 9, 11, 13, 14, 6, 5 }
        end
        for i = 1, #candidates do
            local qty = candidates[i]
            local link = GetSmithingPatternResultLink(
                patternIndex, materialIndex, qty, styleId, trait, LINK_STYLE_DEFAULT
            )
            if link and link ~= "" then
                if GetMaxIterationsPossibleForSmithingItem then
                    local n = GetMaxIterationsPossibleForSmithingItem(
                        patternIndex, materialIndex, qty, styleId, trait, false
                    )
                    if n ~= nil then
                        return qty
                    end
                else
                    return qty
                end
            end
        end
    end

    if craftType == Data.CRAFT_JEWELRY or craftType == 7 then
        return 10
    end
    return 7
end

-- Pick a style the character KNOWS and has materials for.
-- patternIndex (optional) lets us prefer GetFirstKnownItemStyleId for that pattern.
function Data.GetAvailableStyleId(patternIndex)
    local function hasStyleMats(styleId)
        if not styleId or styleId < 1 then return false end
        if GetCurrentSmithingStyleItemCount then
            local count = GetCurrentSmithingStyleItemCount(styleId)
            if count and count > 0 then return true end
        end
        return false
    end

    local function isKnown(styleId)
        if not styleId or styleId < 1 then return false end
        if IsSmithingStyleKnown then
            -- patternIndex 1 is a safe probe when none given
            return IsSmithingStyleKnown(styleId, patternIndex or 1)
        end
        return true
    end

    -- 1) Game's preferred known style for this pattern
    if patternIndex and GetFirstKnownItemStyleId then
        local sid = GetFirstKnownItemStyleId(patternIndex)
        if sid and isKnown(sid) and hasStyleMats(sid) then
            return sid
        end
        -- known but maybe no mats — still prefer it if any known
        if sid and isKnown(sid) then
            return sid
        end
    end

    -- 2) Racial styles 1..9 that are known AND have materials
    for styleId = 1, 9 do
        if isKnown(styleId) and hasStyleMats(styleId) then
            return styleId
        end
    end

    -- 3) Any valid known style with materials
    if GetNumValidItemStyles and GetValidItemStyleId then
        local num = GetNumValidItemStyles() or 0
        for i = 1, num do
            local styleId = GetValidItemStyleId(i)
            if isKnown(styleId) and hasStyleMats(styleId) then
                return styleId
            end
        end
    end

    -- 4) Fallback: first known racial without mat check
    for styleId = 1, 9 do
        if isKnown(styleId) then
            return styleId
        end
    end

    return 1
end

-- traitIndex 1 = "no trait" (white daily writ items). Index 0 is INVALID and breaks
-- both result-link generation and CraftSmithingItem on current API.
Data.TRAIT_NONE = 1

function Data.GetSmithingResultLink(patternIndex, materialIndex, materialQuantity, styleId)
    if not GetSmithingPatternResultLink then return nil end
    local link = GetSmithingPatternResultLink(
        patternIndex,
        materialIndex,
        materialQuantity or 1,
        styleId or 1,
        Data.TRAIT_NONE,
        LINK_STYLE_DEFAULT
    )
    if link and link ~= "" then
        return link
    end
    return nil
end


-- =============================================================================
-- Alchemy / Provisioning — "3 days ahead" pre-craft templates
-- Daily writs rotate; we pre-craft the classic restore set that covers all
-- common daily potion writs (Health / Magicka / Stamina) once per day slot.
-- Pattern index 1/2/3 maps to the three potion types; for offsets 0..2 we craft
-- all three types so the player is covered for today+2 regardless of rotation.
-- =============================================================================
Data.CRAFT_ALCHEMY = 4
Data.CRAFT_PROVISIONING = 5

-- Solvent itemIds by Solvent Proficiency rank (1..8).
-- Rank maps to alchemy skill line / NON_COMBAT_BONUS_ALCHEMY_LEVEL.
-- Main (maxed) can craft any rank; we pick the solvent matching the TARGET character.
Data.AlchemySolventByRank = {
    [1] = { 883 },           -- Natural Water  -> Sip
    [2] = { 33774 },         -- Clear Water    -> Tincture
    [3] = { 33775 },         -- Pristine Water -> Dram
    [4] = { 33776 },         -- Cleansed Water -> Potion
    [5] = { 33777 },         -- Filtered Water -> Solution
    [6] = { 33778 },         -- Purified Water -> Elixir
    [7] = { 33779 },         -- Cloud Mist     -> Panacea
    [8] = { 64501, 33780 },  -- Lorkhan's Tears (Essence) / Star Dew fallback
}

-- Reagent pairs for restore potions (covers standard daily writ variants)
Data.AlchemyRecipes = {
    { name = "Health",   r1 = 30164, r2 = 30166 }, -- Mountain Flower + Water Hyacinth
    { name = "Magicka",  r1 = 30149, r2 = 30153 }, -- Columbine + Corn Flower
    { name = "Stamina",  r1 = 30157, r2 = 30149 }, -- Blessed Thistle + Columbine
}

function Data.GetAlchemySolventIdsForRank(rank)
    rank = tonumber(rank) or 1
    if rank < 1 then rank = 1 end
    if rank > 8 then rank = 8 end
    return Data.AlchemySolventByRank[rank] or Data.AlchemySolventByRank[1]
end

-- Jobs for current character at a given alchemy tier: 3 restore types × N day slots.
-- days defaults to 5 (fixed for alchemy/provisioning as requested).
function Data.GetAlchemyJobsForTier(tier, days)
    days = tonumber(days) or 5
    if days < 1 then days = 1 end
    if days > 10 then days = 10 end
    local solventIds = Data.GetAlchemySolventIdsForRank(tier)
    local jobs = {}
    for day = 1, days do
        for i = 1, #Data.AlchemyRecipes do
            local r = Data.AlchemyRecipes[i]
            table.insert(jobs, {
                craftType = 4,
                dayOffset = day - 1,
                alchemyTier = tier,
                recipeName = r.name .. " (rank " .. tostring(tier) .. ")",
                reagent1Id = r.r1,
                reagent2Id = r.r2,
                solventIds = solventIds,
            })
        end
    end
    return jobs
end

-- Alias for compatibility
function Data.GetAlchemyThreeDayJobsForTier(tier)
    return Data.GetAlchemyJobsForTier(tier, 5)
end

function Data.GetAlchemyThreeDayJobs()
    return Data.GetAlchemyJobsForTier(Data.GetCraftingTier(4), 5)
end


-- =============================================================================
-- Provisioning daily writs: locale-INDEPENDENT matching by ingredient item IDs
-- (GetRecipeInfo names are translated; item IDs never are.)
-- Pattern index: Data.GetTodayPatternIndex() -> 1=A, 2=B, 3=C
-- =============================================================================

-- Stable ingredient item IDs (UESP / community; same on every client language)
Data.ProvIng = {
    -- meats / produce
    Poultry      = 34321,
    Fish         = 33753,
    WhiteMeat    = 33754,
    SmallGame    = 33756,
    RedMeat      = 33752,
    Game         = 28609,
    Apples       = 34311,
    Bananas      = 33755,
    Jazbay       = 28610,
    Melon        = 34308,
    Pumpkin      = 34305,
    Tomato       = 28603,
    Beets        = 34309,
    Carrots      = 34324,
    Corn         = 34323,
    Greens       = 28604,
    Potato       = 33758,
    Radish       = 34307,
    Cheese       = 27057,
    Flour        = 27100,
    Garlic       = 26954,
    Millet       = 27064,
    Saltrice     = 27063,
    Seasoning    = 27058,
    -- drinks
    Barley       = 34329,
    Rice         = 29030,
    Rye          = 28639,
    Surilie      = 34345,
    Wheat        = 34348,
    Yeast        = 33774,
    Bittergreen  = 34334,
    Comberry     = 33768,
    Jasmine      = 33771,
    Lotus        = 34330,
    Mint         = 33773,
    Rose         = 28636,
    Acai         = 34349,
    Coffee       = 33772,
    Ginkgo       = 34346,
    Ginseng      = 34347,
    Guarana      = 34333,
    YerbaMate    = 34335,
    Ginger       = 27052,
    Honey        = 27043,
    Isinglass    = 27035,
    Lemon        = 27049,
    Metheglin    = 27048,
    Seaweed      = 28666,
}

local P = Data.ProvIng

-- Each entry: foodIng / drinkIng = sorted-unique ingredient item IDs for that writ recipe
Data.ProvisioningWrits = {
    [1] = {
        AD = {
            [1] = { foodIng = { P.Poultry }, drinkIng = { P.Rice } },
            [2] = { foodIng = { P.Bananas }, drinkIng = { P.Wheat, P.Seaweed } },
            [3] = { foodIng = { P.Potato }, drinkIng = { P.Rye } },
        },
        DC = {
            [1] = { foodIng = { P.Apples }, drinkIng = { P.Rice, P.Lemon } },
            [2] = { foodIng = { P.Carrots }, drinkIng = { P.Wheat } },
            [3] = { foodIng = { P.Fish }, drinkIng = { P.Surilie } },
        },
        EP = {
            [1] = { foodIng = { P.Jazbay }, drinkIng = { P.Surilie, P.Isinglass } }, -- Grape Preserves approx; Clarified Syrah
            [2] = { foodIng = { P.Corn }, drinkIng = { P.Barley } },
            [3] = { foodIng = { P.Poultry }, drinkIng = { P.Yeast } },
        },
    },
    [2] = {
        AD = {
            [1] = { foodIng = { P.Fish, P.Cheese }, drinkIng = { P.Barley, P.Seaweed } },
            [2] = { foodIng = { P.Pumpkin, P.Garlic }, drinkIng = { P.Comberry, P.Metheglin } },
            [3] = { foodIng = { P.Carrots, P.Garlic }, drinkIng = { P.Barley, P.Honey } },
        },
        DC = {
            [1] = { foodIng = { P.Tomato, P.Saltrice }, drinkIng = { P.Lotus, P.Seaweed } },
            [2] = { foodIng = { P.Beets, P.Cheese }, drinkIng = { P.Rice, P.Isinglass } },
            [3] = { foodIng = { P.WhiteMeat, P.Seasoning }, drinkIng = { P.Wheat, P.Ginger } },
        },
        EP = {
            [1] = { foodIng = { P.Melon, P.Seasoning }, drinkIng = { P.Bittergreen, P.Lemon } }, -- approx
            [2] = { foodIng = { P.Greens, P.Flour }, drinkIng = { P.Rye, P.Seaweed } },
            [3] = { foodIng = { P.Game, P.Flour }, drinkIng = { P.Rye, P.Honey } },
        },
    },
    [3] = {
        AD = {
            [1] = { foodIng = { P.Game, P.Seasoning }, drinkIng = { P.Wheat, P.Honey } },
            [2] = { foodIng = { P.Pumpkin, P.Flour }, drinkIng = { P.Comberry, P.Ginger } },
            [3] = { foodIng = { P.Corn, P.Seasoning }, drinkIng = { P.Rice, P.Seasoning } },
        },
        DC = {
            [1] = { foodIng = { P.Jazbay, P.Seasoning }, drinkIng = { P.Mint, P.Metheglin } },
            [2] = { foodIng = { P.Potato, P.Garlic }, drinkIng = { P.Surilie, P.Metheglin } },
            [3] = { foodIng = { P.Fish, P.Saltrice }, drinkIng = { P.Surilie, P.Seaweed } },
        },
        EP = {
            [1] = { foodIng = { P.Bananas, P.Flour }, drinkIng = { P.Jasmine, P.Seaweed } },
            [2] = { foodIng = { P.Carrots, P.Flour }, drinkIng = { P.Barley, P.Lemon } },
            [3] = { foodIng = { P.SmallGame, P.Garlic }, drinkIng = { P.Rye, P.Metheglin } },
        },
    },
    [4] = {
        ALL = {
            [1] = { foodIng = { P.Game, P.Flour }, drinkIng = { P.Rose, P.Isinglass } },
            [2] = { foodIng = { P.Jazbay, P.Flour }, drinkIng = { P.Coffee, P.Metheglin } },
            [3] = { foodIng = { P.Corn, P.Flour }, drinkIng = { P.Yeast, P.Metheglin } },
        },
    },
    [5] = {
        ALL = {
            [1] = { foodIng = { P.Apples, P.Garlic }, drinkIng = { P.Guarana, P.Ginger } },
            [2] = { foodIng = { P.Corn, P.Millet }, drinkIng = { P.Rye, P.Ginger } },
            [3] = { foodIng = { P.WhiteMeat, P.Millet }, drinkIng = { P.Jasmine, P.Metheglin } },
        },
    },
    [6] = {
        ALL = {
            [1] = { foodIng = { P.Fish, P.Garlic }, drinkIng = { P.Ginkgo, P.Ginger } },
            [2] = { foodIng = { P.Garlic, P.Corn }, drinkIng = { P.Barley, P.Metheglin } },
            [3] = { foodIng = { P.Jazbay, P.Cheese }, drinkIng = { P.Bittergreen, P.Metheglin } },
        },
    },
}

function Data.AllianceKey(allianceId)
    allianceId = tonumber(allianceId) or 0
    if allianceId == 1 or allianceId == (ALLIANCE_ALDMERI_DOMINION or -1) then return "AD" end
    if allianceId == 2 or allianceId == (ALLIANCE_EBONHEART_PACT or -1) then return "EP" end
    if allianceId == 3 or allianceId == (ALLIANCE_DAGGERFALL_COVENANT or -1) then return "DC" end
    local a = GetUnitAlliance and GetUnitAlliance("player") or 1
    if a == 1 then return "AD" end
    if a == 2 then return "EP" end
    if a == 3 then return "DC" end
    return "AD"
end

local function IngredientKey(ids)
    if not ids or #ids == 0 then return "" end
    local t = {}
    local seen = {}
    for i = 1, #ids do
        local id = tonumber(ids[i])
        if id and not seen[id] then
            seen[id] = true
            t[#t + 1] = id
        end
    end
    table.sort(t)
    return table.concat(t, ":")
end

function Data.GetProvisioningPair(rank, allianceId, group)
    rank = tonumber(rank) or 1
    if rank < 1 then rank = 1 end
    if rank > 6 then rank = 6 end
    group = tonumber(group) or 1
    if group < 1 then group = 1 end
    if group > 3 then group = ((group - 1) % 3) + 1 end

    local byRank = Data.ProvisioningWrits[rank]
    if not byRank then return nil end
    local key = (rank <= 3) and Data.AllianceKey(allianceId) or "ALL"
    local byAlly = byRank[key] or byRank.ALL or byRank.AD
    if not byAlly then return nil end
    return byAlly[group]
end

-- Cache: ingredientKey -> { listIndex, recipeIndex, name, resultId }
local _recipeByIng = nil
local _recipeByIngBuilt = false

function Data.ClearRecipeCache()
    _recipeByIng = nil
    _recipeByIngBuilt = false
end

function Data.BuildRecipeMapByIngredients()
    if _recipeByIngBuilt and _recipeByIng then
        return _recipeByIng
    end
    -- map.byIng[key] = entry; map.byResultId[id] = entry; map.list = array of all known entries
    local map = { byIng = {}, byResultId = {}, list = {}, knownCount = 0 }
    if not GetNumRecipeLists then
        _recipeByIng = map
        _recipeByIngBuilt = true
        return map
    end
    local numLists = GetNumRecipeLists() or 0
    for listIndex = 1, numLists do
        local numRecipes = 0
        if GetRecipeListInfo then
            local ok, a, b = pcall(GetRecipeListInfo, listIndex)
            if ok then
                -- API: name, numRecipes, ...
                if type(a) == "number" then numRecipes = a
                elseif type(b) == "number" then numRecipes = b
                end
            end
        end
        for recipeIndex = 1, numRecipes do
            local known, name, numIng, provLevel, qualityReq, specialType, stationType, resultItemId
            if GetRecipeInfo then
                local ok, r1, r2, r3, r4, r5, r6, r7, r8 = pcall(GetRecipeInfo, listIndex, recipeIndex)
                if ok then
                    known, name, numIng, provLevel, qualityReq, specialType, stationType, resultItemId =
                        r1, r2, r3, r4, r5, r6, r7, r8
                end
            end
            if known then
                map.knownCount = map.knownCount + 1
                numIng = tonumber(numIng) or 0
                if numIng == 0 and GetRecipeNumIngredients then
                    local ok2, n = pcall(GetRecipeNumIngredients, listIndex, recipeIndex)
                    if ok2 then numIng = tonumber(n) or 0 end
                end
                local ids = {}
                for i = 1, numIng do
                    local link
                    if GetRecipeIngredientItemLink then
                        local ok3, lnk = pcall(GetRecipeIngredientItemLink, listIndex, recipeIndex, i, LINK_STYLE_DEFAULT)
                        if ok3 then link = lnk end
                        if (not link or link == "") and LINK_STYLE_BRACKETS then
                            ok3, lnk = pcall(GetRecipeIngredientItemLink, listIndex, recipeIndex, i, LINK_STYLE_BRACKETS)
                            if ok3 then link = lnk end
                        end
                    end
                    if link and link ~= "" and GetItemLinkItemId then
                        local id = GetItemLinkItemId(link)
                        if id and id > 0 then ids[#ids + 1] = id end
                    end
                end
                local resultId = tonumber(resultItemId)
                local rlink
                if (not resultId or resultId == 0) and GetRecipeResultItemLink then
                    local ok4, rl = pcall(GetRecipeResultItemLink, listIndex, recipeIndex, LINK_STYLE_DEFAULT)
                    if ok4 then rlink = rl end
                    if rlink and GetItemLinkItemId then
                        resultId = GetItemLinkItemId(rlink)
                    end
                end
                local quality
                if rlink and GetItemLinkDisplayQuality then
                    quality = GetItemLinkDisplayQuality(rlink)
                elseif rlink and GetItemLinkQuality then
                    quality = GetItemLinkQuality(rlink)
                end
                local isFine = (quality == ITEM_QUALITY_FINE or quality == (ITEM_FUNCTIONAL_QUALITY_FINE or -1) or quality == 2)
                local itemType
                if rlink and GetItemLinkItemType then
                    itemType = GetItemLinkItemType(rlink)
                end
                local entry = {
                    listIndex = listIndex,
                    recipeIndex = recipeIndex,
                    name = name,
                    resultId = resultId,
                    isFine = isFine,
                    provLevel = tonumber(provLevel) or 0,
                    ingredientIds = ids,
                    itemType = itemType,
                    specialType = specialType,
                }
                map.list[#map.list + 1] = entry
                local key = IngredientKey(ids)
                if key ~= "" then
                    local existing = map.byIng[key]
                    if not existing or (isFine and not existing.isFine) then
                        map.byIng[key] = entry
                    end
                end
                if resultId and resultId > 0 then
                    map.byResultId[resultId] = entry
                end
            end
        end
    end
    _recipeByIng = map
    _recipeByIngBuilt = true
    return map
end

-- Compatibility shim
function Data.ResolveNeededRecipes(_ignored)
    return Data.BuildRecipeMapByIngredients()
end

-- Match: exact ingredient key, else soft (all required IDs present + same count preferred)
function Data.FindRecipeByIngredients(recipeMap, ingIds)
    if not recipeMap or not ingIds then return nil end
    local key = IngredientKey(ingIds)
    if recipeMap.byIng and recipeMap.byIng[key] then
        return recipeMap.byIng[key]
    end
    -- Soft match across all known recipes
    local needSet, needCount = {}, 0
    for i = 1, #ingIds do
        local id = tonumber(ingIds[i])
        if id and not needSet[id] then
            needSet[id] = true
            needCount = needCount + 1
        end
    end
    if needCount == 0 then return nil end
    local best, bestScore = nil, -1
    local list = recipeMap.list or {}
    for i = 1, #list do
        local e = list[i]
        local ids = e.ingredientIds or {}
        local have = 0
        local seen = {}
        for j = 1, #ids do
            local id = ids[j]
            if needSet[id] and not seen[id] then
                seen[id] = true
                have = have + 1
            end
        end
        if have == needCount then
            local score = 10
            if e.isFine then score = score + 5 end
            if #ids == needCount then score = score + 3 end
            if score > bestScore then
                bestScore = score
                best = e
            end
        end
    end
    return best
end

function Data.CollectProvisioningIngredientSets(charSpecs)
    local sets, seen = {}, {}
    local today = Data.GetTodayPatternIndex()
    for i = 1, #(charSpecs or {}) do
        local spec = charSpecs[i]
        local tier = tonumber(spec.tier) or 1
        local allianceId = spec.allianceId or 0
        for offset = 0, 2 do
            local group = ((today - 1 + offset) % 3) + 1
            local pair = Data.GetProvisioningPair(tier, allianceId, group)
            if pair then
                for _, kind in ipairs({ "foodIng", "drinkIng" }) do
                    local ids = pair[kind]
                    if ids then
                        local key = IngredientKey(ids)
                        if key ~= "" and not seen[key] then
                            seen[key] = true
                            sets[#sets + 1] = ids
                        end
                    end
                end
            end
        end
    end
    return sets
end

-- Legacy name collect (unused for matching; kept for any external refs)
function Data.CollectProvisioningRecipeNames(charSpecs)
    return {} -- matching is ingredient-based; names come from GetRecipeInfo at resolve time
end

function Data.GetProvisioningJobsForChar(tier, allianceId, recipeMap, days)
    tier = tonumber(tier) or 1
    if tier < 1 then tier = 1 end
    if tier > 6 then tier = 6 end
    days = tonumber(days) or 5
    if days < 1 then days = 1 end
    if days > 10 then days = 10 end
    recipeMap = recipeMap or Data.BuildRecipeMapByIngredients()
    local today = Data.GetTodayPatternIndex()
    local jobs = {}
    for offset = 0, days - 1 do
        local group = ((today - 1 + offset) % 3) + 1
        local pair = Data.GetProvisioningPair(tier, allianceId, group)
        if pair then
            for _, kind in ipairs({ "foodIng", "drinkIng" }) do
                local ids = pair[kind]
                local found = Data.FindRecipeByIngredients(recipeMap, ids)
                local displayName = found and found.name or (kind == "foodIng" and "Food" or "Drink")
                jobs[#jobs + 1] = {
                    craftType = 5,
                    dayOffset = offset,
                    group = group,
                    provisioningTier = tier,
                    ingredientIds = ids,
                    wantName = displayName,
                    name = displayName,
                    recipeListIndex = found and found.listIndex or nil,
                    recipeIndex = found and found.recipeIndex or nil,
                    resultId = found and found.resultId or nil,
                    recipeKnown = found ~= nil,
                }
            end
        end
    end
    return jobs
end

-- Compatibility alias (fixed 5 days)
function Data.GetProvisioningThreeDayJobsForChar(tier, allianceId, recipeMap)
    return Data.GetProvisioningJobsForChar(tier, allianceId, recipeMap, 5)
end

function Data.PlayerName()
    return zo_strformat("<<1>>", GetUnitName("player"))
end

function Data.CharacterNameFromIndex(index)
    local name = GetCharacterInfo(index)
    return zo_strformat("<<1>>", name)
end
