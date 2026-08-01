----------------------------------------------------------------------
-- SmartGear — Core Scoring Engine
----------------------------------------------------------------------
SmartGear = SmartGear or {}

-- Rating constants
SmartGear.RATING_RECOMMENDED = 4   -- ★★★ + meta
SmartGear.RATING_GOOD        = 3   -- ★★★
SmartGear.RATING_DECENT      = 2   -- ★★☆
SmartGear.RATING_MAYBE       = 1   -- ★☆☆
SmartGear.RATING_BAD         = 0   -- ☆☆☆
SmartGear.RATING_STICKERBOOK = -1  -- collect for another role

----------------------------------------------------------------------
-- Get currently equipped set IDs for synergy detection
----------------------------------------------------------------------
local function GetEquippedSets()
    local sets = {}
    for slot = 0, 16 do
        local itemLink = GetItemLink(BAG_WORN, slot)
        if itemLink and itemLink ~= "" then
            local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, true)
            if hasSet and setId then
                if not sets[setId] then
                    sets[setId] = {
                        name = setName,
                        equipped = numEquipped,
                        max = maxEquipped,
                        id = setId,
                    }
                end
            end
        end
    end
    return sets
end

----------------------------------------------------------------------
-- Check if item's set matches any equipped set
----------------------------------------------------------------------
local function CheckSetSynergy(itemLink, equippedSets)
    local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
    if not hasSet then
        return nil, nil, nil, nil
    end

    local isEquippedSet = false
    local currentCount = 0
    local maxCount = maxEquipped or 5

    if equippedSets[setId] then
        isEquippedSet = true
        currentCount = equippedSets[setId].equipped
    end

    return setName, isEquippedSet, currentCount, maxCount
end

----------------------------------------------------------------------
-- Look up set in meta database
----------------------------------------------------------------------
local function GetMetaInfo(setName)
    if not setName then return nil end
    -- Try exact match first
    local meta = SmartGear.MetaSets[setName]
    if meta then return meta end

    -- Try case-insensitive / partial match
    local lowerName = string.lower(setName)
    for name, data in pairs(SmartGear.MetaSets) do
        if string.lower(name) == lowerName then
            return data
        end
    end
    return nil
end

----------------------------------------------------------------------
-- Check if set is relevant for a role
----------------------------------------------------------------------
local function IsSetForRole(metaInfo, role, pvpMode)
    if not metaInfo or not metaInfo.roles then return false end
    if metaInfo.pvpOnly and not pvpMode then return false end
    for _, r in ipairs(metaInfo.roles) do
        if r == role then return true end
    end
    return false
end

----------------------------------------------------------------------
-- Check if set is relevant for ANY role (for stickerbook recommendation)
----------------------------------------------------------------------
local function IsSetForAnyRole(metaInfo)
    if not metaInfo then return false end
    return metaInfo.tier == "S" or metaInfo.tier == "A"
end

----------------------------------------------------------------------
-- Dual Wield weapon type bonuses (Twin Blade and Blunt passive)
-- Each weapon type gives a different bonus, regardless of hand
----------------------------------------------------------------------
SmartGear.DW_WEAPON_BONUSES = {
    [WEAPONTYPE_DAGGER] = { stat = "crit",   desc_en = "Crit Chance",       desc_ru = "Шанс крита" },
    [WEAPONTYPE_AXE]    = { stat = "critdmg", desc_en = "Crit Damage",      desc_ru = "Крит. урон" },
    [WEAPONTYPE_SWORD]  = { stat = "damage",  desc_en = "Weapon/Spell Dmg", desc_ru = "Сила урона" },
    [WEAPONTYPE_HAMMER] = { stat = "pen",    desc_en = "Penetration",       desc_ru = "Пробивание" },
}

----------------------------------------------------------------------
-- Weapon slot awareness
--
-- Three placement rules in dual wield:
--
-- 1. TRAIT SCALING: Main hand = 100% damage scaling, off-hand = ~18%.
--    So Nirnhoned (+200 dmg) goes in MAIN hand.
--    Charged/Infused/Precise go in OFF hand (flat bonuses, no scaling).
--
-- 2. DUAL WIELD EXPERT passive: "Weapon/Spell Damage increased by
--    3% of off-hand weapon's base damage." Higher base damage weapons
--    (axe/sword/mace) should go in OFF hand.
--    Daggers have LOWEST base damage -> best in MAIN hand.
--
-- 3. TWIN BLADE AND BLUNT passive: Each weapon type gives a bonus
--    regardless of hand. Dagger=Crit, Axe=CritDmg, Sword=Dmg, Mace=Pen.
--
-- OPTIMAL META SETUP:
--   Main hand: Dagger (Nirnhoned) — crit from TBB, trait scales 100%
--   Off hand:  Axe (Precise/Charged) — crit dmg from TBB, high base for DWE
----------------------------------------------------------------------
local MAIN_HAND_TRAITS = {
    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = true,
}
local OFF_HAND_TRAITS = {
    [ITEM_TRAIT_TYPE_WEAPON_CHARGED]   = true,
    [ITEM_TRAIT_TYPE_WEAPON_INFUSED]   = true,
    [ITEM_TRAIT_TYPE_WEAPON_PRECISE]   = true,
}

-- Weapons with HIGH base damage -> better in off-hand (DW Expert passive)
local HIGH_BASE_DMG = {
    [WEAPONTYPE_AXE]    = true,
    [WEAPONTYPE_SWORD]  = true,
    [WEAPONTYPE_HAMMER] = true,
}
-- Weapons with LOW base damage -> better in main hand
local LOW_BASE_DMG = {
    [WEAPONTYPE_DAGGER] = true,
}

----------------------------------------------------------------------
-- Analyze weapon placement: is this weapon optimal for the target slot?
-- Returns: advice string, score bonus, dwBonus info, placement hints
----------------------------------------------------------------------
function SmartGear.AnalyzeWeaponPlacement(itemLink, targetSlot)
    if not itemLink or itemLink == "" then return nil, 0 end

    local weaponType = GetItemLinkWeaponType(itemLink)
    local traitType = GetItemLinkTraitType(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)

    -- Only relevant for one-hand weapons in dual wield context
    if equipType ~= EQUIP_TYPE_ONE_HAND then return nil, 0 end

    local isMainHand = (targetSlot == EQUIP_SLOT_MAIN_HAND or targetSlot == EQUIP_SLOT_BACKUP_MAIN)
    local isOffHand = (targetSlot == EQUIP_SLOT_OFF_HAND or targetSlot == EQUIP_SLOT_BACKUP_OFF)

    local advice = nil
    local scoreBonus = 0
    local placementHints = {}

    -- === TRAIT PLACEMENT (100% vs 18% scaling) ===
    if traitType then
        if isMainHand and MAIN_HAND_TRAITS[traitType] then
            scoreBonus = scoreBonus + 3
            advice = "trait_correct_main"
        elseif isOffHand and MAIN_HAND_TRAITS[traitType] then
            scoreBonus = scoreBonus - 5
            advice = "trait_wrong_offhand"
            table.insert(placementHints, "nirnhoned_offhand")
        elseif isOffHand and OFF_HAND_TRAITS[traitType] then
            scoreBonus = scoreBonus + 2
            advice = "trait_correct_off"
        end
    end

    -- === DUAL WIELD EXPERT: base damage in off-hand ===
    if weaponType then
        if isOffHand and HIGH_BASE_DMG[weaponType] then
            -- High base damage in off-hand = correct (DW Expert bonus)
            scoreBonus = scoreBonus + 3
            table.insert(placementHints, "high_dmg_offhand_good")
        elseif isOffHand and LOW_BASE_DMG[weaponType] then
            -- Dagger in off-hand = bad for DW Expert (low base damage)
            scoreBonus = scoreBonus - 2
            table.insert(placementHints, "low_dmg_offhand_bad")
        elseif isMainHand and LOW_BASE_DMG[weaponType] then
            -- Dagger in main hand = correct (low base, but 100% trait scaling)
            scoreBonus = scoreBonus + 2
            table.insert(placementHints, "dagger_main_good")
        elseif isMainHand and HIGH_BASE_DMG[weaponType] then
            -- Axe/sword in main hand = lost DW Expert potential
            scoreBonus = scoreBonus - 1
            table.insert(placementHints, "high_dmg_main_suboptimal")
        end
    end

    -- === TWIN BLADE AND BLUNT info ===
    local dwBonus = SmartGear.DW_WEAPON_BONUSES[weaponType]
    if dwBonus then
        advice = advice or "dw_bonus"
    end

    return advice, scoreBonus, dwBonus, placementHints
end

----------------------------------------------------------------------
-- Check if equipped DW weapons on a bar should be swapped
-- Returns: { shouldSwap, bar, mainSlot, offSlot, mainLink, offLink,
--            scoreBenefit, reasons{} }  or nil
----------------------------------------------------------------------
function SmartGear.CheckEquippedWeaponSwap(bar)
    -- bar 1 = primary, bar 2 = backup
    local mainSlot, offSlot
    if bar == 2 then
        mainSlot = EQUIP_SLOT_BACKUP_MAIN
        offSlot  = EQUIP_SLOT_BACKUP_OFF
    else
        mainSlot = EQUIP_SLOT_MAIN_HAND
        offSlot  = EQUIP_SLOT_OFF_HAND
    end

    local mainLink = GetItemLink(BAG_WORN, mainSlot)
    local offLink  = GetItemLink(BAG_WORN, offSlot)
    if (not mainLink or mainLink == "") or (not offLink or offLink == "") then
        return nil  -- need both weapons
    end

    -- Both must be one-hand
    local mainEquip = GetItemLinkEquipType(mainLink)
    local offEquip  = GetItemLinkEquipType(offLink)
    if mainEquip ~= EQUIP_TYPE_ONE_HAND or offEquip ~= EQUIP_TYPE_ONE_HAND then
        return nil
    end

    -- Score current placement
    local _, curMainScore = SmartGear.AnalyzeWeaponPlacement(mainLink, mainSlot)
    local _, curOffScore  = SmartGear.AnalyzeWeaponPlacement(offLink, offSlot)
    local currentTotal = curMainScore + curOffScore

    -- Score swapped placement (main weapon in off slot, off weapon in main slot)
    local _, swapMainScore = SmartGear.AnalyzeWeaponPlacement(offLink, mainSlot)
    local _, swapOffScore  = SmartGear.AnalyzeWeaponPlacement(mainLink, offSlot)
    local swappedTotal = swapMainScore + swapOffScore

    local benefit = swappedTotal - currentTotal
    if benefit < 3 then return nil end  -- not worth swapping

    -- Build reasons
    local reasons = {}
    local mainWeaponType = GetItemLinkWeaponType(mainLink)
    local offWeaponType  = GetItemLinkWeaponType(offLink)
    local mainTrait = GetItemLinkTraitType(mainLink)
    local offTrait  = GetItemLinkTraitType(offLink)

    if MAIN_HAND_TRAITS[offTrait] then
        table.insert(reasons, "nirnhoned_to_main")
    end
    if HIGH_BASE_DMG[mainWeaponType] then
        table.insert(reasons, "high_dmg_to_offhand")
    end
    if LOW_BASE_DMG[offWeaponType] then
        table.insert(reasons, "dagger_to_main")
    end

    return {
        shouldSwap = true,
        bar = bar,
        mainSlot = mainSlot,
        offSlot = offSlot,
        mainLink = mainLink,
        offLink = offLink,
        scoreBenefit = benefit,
        reasons = reasons,
    }
end

----------------------------------------------------------------------
-- Check both bars for suboptimal weapon placement
----------------------------------------------------------------------
function SmartGear.CheckAllBarsWeaponSwap()
    local results = {}
    for bar = 1, 2 do
        local swap = SmartGear.CheckEquippedWeaponSwap(bar)
        if swap then
            table.insert(results, swap)
        end
    end
    return results
end

----------------------------------------------------------------------
-- Evaluate armor trait quality for role
----------------------------------------------------------------------
local function EvaluateArmorTrait(traitType, role, pvpMode)
    local config = SmartGear.RoleConfig[role]
    if not config then return "unknown", false end

    if pvpMode then
        if config.pvpTraits and config.pvpTraits[traitType] then
            return "optimal", true
        end
    else
        if config.optimalTraits and config.optimalTraits[traitType] then
            return "optimal", true
        end
    end

    -- Infused is always acceptable on large pieces
    if traitType == ITEM_TRAIT_TYPE_ARMOR_INFUSED then
        return "good", false
    end

    -- Training is never good for endgame
    if traitType == ITEM_TRAIT_TYPE_ARMOR_TRAINING then
        return "bad", false
    end

    return "suboptimal", false
end

----------------------------------------------------------------------
-- Evaluate jewelry trait quality
----------------------------------------------------------------------
local function EvaluateJewelryTrait(traitType, role)
    local config = SmartGear.RoleConfig[role]
    if not config then return "unknown", false end

    if config.optimalJewelryTrait and config.optimalJewelryTrait[traitType] then
        return "optimal", true
    end

    -- Infused is generally acceptable
    if traitType == ITEM_TRAIT_TYPE_JEWELRY_INFUSED then
        return "good", false
    end

    return "suboptimal", false
end

----------------------------------------------------------------------
-- Evaluate weapon trait quality
----------------------------------------------------------------------
local function EvaluateWeaponTrait(traitType, role)
    local config = SmartGear.RoleConfig[role]
    if not config then return "unknown", false end

    if config.optimalWeaponTraits and config.optimalWeaponTraits[traitType] then
        return "optimal", true
    end

    return "suboptimal", false
end

----------------------------------------------------------------------
-- Check armor weight fitness
----------------------------------------------------------------------
local function EvaluateArmorWeight(armorType, role)
    local config = SmartGear.RoleConfig[role]
    if not config then return false end
    return config.optimalWeights and config.optimalWeights[armorType] or false
end

----------------------------------------------------------------------
-- SHARED SCORING FUNCTION
-- Computes score and rating from an already-populated result table.
-- Called by both EvaluateItem and EvaluateItemLink.
----------------------------------------------------------------------
function SmartGear.ComputeScore(result, role, pvpMode)
    -- Ensure player profile is up to date for adaptive scoring
    SmartGear.EnsureProfileFresh()

    local score = 0

    -- === SET TIER SCORING ===
    if result.isMetaSet and result.isForCurrentRole then
        local tierBase = 10
        if result.metaTier == "S" then tierBase = 40
        elseif result.metaTier == "A" then tierBase = 30
        elseif result.metaTier == "B" then tierBase = 20 end

        local ratingBonus = 0
        if result.metaRating and result.metaRating > 0 then
            ratingBonus = math.floor(result.metaRating / 10)
        end
        score = score + tierBase + ratingBonus

        -- === ADAPTIVE SET BONUS (gap-based) ===
        local metaInfo = SmartGear.MetaSets and SmartGear.MetaSets[result.setName]
        if metaInfo and metaInfo.statContributions then
            local gaps = SmartGear.ComputeStatGaps(role)
            local setAdjust = 0
            for stat, contribution in pairs(metaInfo.statContributions) do
                if gaps[stat] then
                    local statAdj = math.floor((gaps[stat] - 0.2) * contribution * 30)
                    statAdj = math.max(-1, math.min(3, statAdj))
                    setAdjust = setAdjust + statAdj
                end
            end
            setAdjust = math.max(-3, math.min(8, setAdjust))
            score = score + setAdjust
            result.setGapAdjust = setAdjust
        end
    elseif result.setName and not result.isMetaSet then
        score = score + 5
    end

    -- === TRAIT SCORING (static base + adaptive adjustment) ===
    local traitScore = 0
    if result.isOptimalTrait then
        traitScore = 20
    elseif result.traitQuality == "good" then
        traitScore = 10
    elseif result.traitQuality == "suboptimal" then
        traitScore = 3
    elseif result.traitQuality == "bad" then
        traitScore = -5
    end

    -- Adaptive trait adjustment based on stat gaps
    local traitType = result.itemLink and GetItemLinkTraitType(result.itemLink) or nil
    if traitType and SmartGear.TraitStatMap then
        local traitStat = SmartGear.TraitStatMap[traitType]
        if traitStat and traitStat.stat ~= "none" and traitStat.weight > 0 then
            local gaps = SmartGear.ComputeStatGaps(role)
            if gaps[traitStat.stat] then
                local gapValue = gaps[traitStat.stat]
                local adjustment = math.floor((gapValue - 0.3) * traitStat.weight * 12)
                adjustment = math.max(-4, math.min(8, adjustment))
                traitScore = traitScore + adjustment
                result.traitGapAdjust = adjustment
            end
        end
    end

    score = score + traitScore

    -- === WEIGHT SCORING ===
    if result.isOptimalWeight then
        score = score + 10
    elseif result.armorWeight and result.armorWeight ~= ARMORTYPE_NONE then
        score = score - 5
    end

    -- === SET SYNERGY ===
    if result.completesSet then
        score = score + 15
    elseif result.isEquippedSet then
        score = score + 8
    end

    -- === QUALITY ===
    if result.quality then
        if result.quality == ITEM_DISPLAY_QUALITY_LEGENDARY then
            score = score + 5
        elseif result.quality == ITEM_DISPLAY_QUALITY_ARTIFACT then
            score = score + 3
        end
    end

    -- === ITEM LEVEL ===
    if result.itemLevel and result.itemLevel > 0 then
        local maxLevel = 210
        local levelRatio = result.itemLevel / maxLevel
        score = score + math.floor(levelRatio * 15)
    end

    -- === MYTHIC ===
    if result.isMythic and result.isForCurrentRole then
        score = score + 20
    end

    -- === CONVERT TO RATING ===
    if score >= 55 then
        result.rating = SmartGear.RATING_RECOMMENDED
        result.stars = 3
    elseif score >= 35 then
        result.rating = SmartGear.RATING_GOOD
        result.stars = 3
    elseif score >= 20 then
        result.rating = SmartGear.RATING_DECENT
        result.stars = 2
    elseif score >= 5 then
        result.rating = SmartGear.RATING_MAYBE
        result.stars = 1
    else
        if result.isMetaSet and result.isForAnyRole and not result.isForCurrentRole then
            result.rating = SmartGear.RATING_STICKERBOOK
            result.stars = 0
        else
            result.rating = SmartGear.RATING_BAD
            result.stars = 0
        end
    end

    result.score = score
end

----------------------------------------------------------------------
-- MAIN SCORING FUNCTION
-- Returns a table with all evaluation details
----------------------------------------------------------------------
function SmartGear.EvaluateItem(bagId, slotIndex)
    local itemLink = GetItemLink(bagId, slotIndex)
    if not itemLink or itemLink == "" then return nil end

    local itemType = GetItemType(bagId, slotIndex)
    -- Only evaluate equipment
    if itemType ~= ITEMTYPE_ARMOR and itemType ~= ITEMTYPE_WEAPON and itemType ~= ITEMTYPE_JEWELRYCRAFTING
       and GetItemLinkItemType(itemLink) ~= ITEMTYPE_ARMOR
       and GetItemLinkItemType(itemLink) ~= ITEMTYPE_WEAPON then
        -- Check via link as fallback
        local linkItemType = GetItemLinkItemType(itemLink)
        if linkItemType ~= ITEMTYPE_ARMOR and linkItemType ~= ITEMTYPE_WEAPON then
            return nil
        end
    end

    local role = SmartGear.currentRole or "MagDD"
    local pvpMode = SmartGear.savedVars and SmartGear.savedVars.pvpMode or false
    local equippedSets = GetEquippedSets()

    local result = {
        itemLink = itemLink,
        role = role,
        rating = SmartGear.RATING_BAD,
        stars = 0,
        -- Set info
        setName = nil,
        isMetaSet = false,
        metaTier = nil,
        metaNotes = nil,
        isForCurrentRole = false,
        isForAnyRole = false,
        isEquippedSet = false,
        setEquipped = 0,
        setMax = 0,
        completesSet = false,
        -- Trait info
        traitName = nil,
        traitQuality = "unknown",  -- optimal/good/suboptimal/bad
        isOptimalTrait = false,
        -- Weight info
        armorWeight = nil,
        isOptimalWeight = true,  -- default true for non-armor
        -- Quality
        quality = GetItemLinkQuality(itemLink),
        -- Level & stats
        itemLevel = 0,
        requiredLevel = 0,
        requiredCP = 0,
        -- Flags
        isMythic = false,
        isMonsterSet = false,
        isPvpSet = false,
        recommendTransmute = false,
        equipType = GetItemLinkEquipType(itemLink),
    }

    -- === LEVEL ANALYSIS ===
    local hasReqLevel, reqLevel, hasReqCP, reqCP = GetItemLinkGlyphMinLevels(itemLink)
    result.requiredLevel = GetItemRequiredLevel(bagId, slotIndex) or 0
    result.requiredCP = GetItemRequiredChampionPoints(bagId, slotIndex) or 0
    -- Effective item level: CP160 = max, lower = weaker
    if result.requiredCP > 0 then
        result.itemLevel = 50 + result.requiredCP
    else
        result.itemLevel = result.requiredLevel
    end

    -- === SET ANALYSIS ===
    local setName, isEquippedSet, currentCount, maxCount = CheckSetSynergy(itemLink, equippedSets)
    result.setName = setName

    if setName then
        result.isEquippedSet = isEquippedSet or false
        result.setEquipped = currentCount or 0
        result.setMax = maxCount or 5

        -- Would this item complete or advance the set?
        if isEquippedSet and currentCount and maxCount then
            result.completesSet = (currentCount + 1) >= maxCount
        end

        local metaInfo = GetMetaInfo(setName)
        if metaInfo then
            result.isMetaSet = true
            result.metaTier = metaInfo.tier
            result.metaRating = metaInfo.rating or 50
            result.metaNotes = metaInfo.notes
            result.isMythic = metaInfo.isMythic or false
            result.isMonsterSet = metaInfo.isMonsterSet or false
            result.isPvpSet = metaInfo.pvpOnly or false
            result.isForCurrentRole = IsSetForRole(metaInfo, role, pvpMode)
            result.isForAnyRole = IsSetForAnyRole(metaInfo)
        end
    end

    -- === TRAIT ANALYSIS ===
    local traitType = GetItemTrait(bagId, slotIndex)
    if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
        result.traitName = SmartGear.TraitNames[traitType] or GetString("SI_ITEMTRAITTYPE", traitType)

        local equipType = GetItemLinkEquipType(itemLink)
        -- Determine if jewelry, weapon, or armor
        if equipType == EQUIP_TYPE_NECK or equipType == EQUIP_TYPE_RING then
            result.traitQuality, result.isOptimalTrait = EvaluateJewelryTrait(traitType, role)
        elseif equipType == EQUIP_TYPE_MAIN_HAND or equipType == EQUIP_TYPE_OFF_HAND
            or equipType == EQUIP_TYPE_ONE_HAND or equipType == EQUIP_TYPE_TWO_HAND then
            result.traitQuality, result.isOptimalTrait = EvaluateWeaponTrait(traitType, role)
        else
            result.traitQuality, result.isOptimalTrait = EvaluateArmorTrait(traitType, role, pvpMode)
        end

        -- Should we recommend transmute?
        if result.isMetaSet and result.isForCurrentRole and not result.isOptimalTrait then
            result.recommendTransmute = true
        end
    end

    -- === ARMOR WEIGHT ANALYSIS ===
    local armorType = GetItemArmorType(bagId, slotIndex)
    if armorType and armorType ~= ARMORTYPE_NONE then
        result.armorWeight = armorType
        result.isOptimalWeight = EvaluateArmorWeight(armorType, role)
    end

    -- === COMPUTE FINAL RATING (shared function) ===
    SmartGear.ComputeScore(result, role, pvpMode)
    return result
end

----------------------------------------------------------------------
-- Evaluate an equipped item by its worn slot index
----------------------------------------------------------------------
local function EvaluateEquippedSlot(wornSlot)
    local itemLink = GetItemLink(BAG_WORN, wornSlot)
    if not itemLink or itemLink == "" then return nil end
    return SmartGear.EvaluateItemLink(itemLink)
end

----------------------------------------------------------------------
-- SMART SLOT RESOLUTION
-- Returns a list of {slot, label} for comparison, aware of paired slots
-- Strategy: for paired slots (rings, dual wield), compare against
-- the WEAKEST equipped item so we suggest replacing it
----------------------------------------------------------------------
local function GetComparisonSlots(equipType)
    -- Single-slot equipment: straightforward
    local singleSlots = {
        [EQUIP_TYPE_HEAD]      = { { slot = EQUIP_SLOT_HEAD, label = "Head" } },
        [EQUIP_TYPE_CHEST]     = { { slot = EQUIP_SLOT_CHEST, label = "Chest" } },
        [EQUIP_TYPE_SHOULDERS] = { { slot = EQUIP_SLOT_SHOULDERS, label = "Shoulders" } },
        [EQUIP_TYPE_WAIST]     = { { slot = EQUIP_SLOT_WAIST, label = "Waist" } },
        [EQUIP_TYPE_LEGS]      = { { slot = EQUIP_SLOT_LEGS, label = "Legs" } },
        [EQUIP_TYPE_FEET]      = { { slot = EQUIP_SLOT_FEET, label = "Feet" } },
        [EQUIP_TYPE_HAND]      = { { slot = EQUIP_SLOT_HAND, label = "Hands" } },
        [EQUIP_TYPE_NECK]      = { { slot = EQUIP_SLOT_NECK, label = "Neck" } },
    }

    if singleSlots[equipType] then
        return singleSlots[equipType], "single"
    end

    -- RINGS: compare against both, suggest replacing the worse one
    if equipType == EQUIP_TYPE_RING then
        return {
            { slot = EQUIP_SLOT_RING1, label = "Ring 1" },
            { slot = EQUIP_SLOT_RING2, label = "Ring 2" },
        }, "paired_replace_worst"
    end

    -- TWO-HAND: compare against main bar and backup bar main slots
    if equipType == EQUIP_TYPE_TWO_HAND then
        return {
            { slot = EQUIP_SLOT_MAIN_HAND, label = "Main Bar" },
            { slot = EQUIP_SLOT_BACKUP_MAIN, label = "Backup Bar" },
        }, "bar_choice"
    end

    -- MAIN_HAND type: can go in main hand of either bar
    if equipType == EQUIP_TYPE_MAIN_HAND then
        return {
            { slot = EQUIP_SLOT_MAIN_HAND, label = "Main Bar" },
            { slot = EQUIP_SLOT_BACKUP_MAIN, label = "Backup Bar" },
        }, "bar_choice"
    end

    -- OFF_HAND (shield, torch, etc.): compare off-hand slots
    -- But SKIP bars where a 2H weapon is equipped (2H blocks the off-hand)
    if equipType == EQUIP_TYPE_OFF_HAND then
        local slots = {}

        -- Main bar: only if NOT using 2H
        local mainLink = GetItemLink(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
        local mainIs2H = false
        if mainLink and mainLink ~= "" then
            mainIs2H = (GetItemLinkEquipType(mainLink) == EQUIP_TYPE_TWO_HAND)
        end
        if not mainIs2H then
            table.insert(slots, { slot = EQUIP_SLOT_OFF_HAND, label = "Main Bar Off-hand" })
        end

        -- Backup bar: only if NOT using 2H
        local backupLink = GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
        local backupIs2H = false
        if backupLink and backupLink ~= "" then
            backupIs2H = (GetItemLinkEquipType(backupLink) == EQUIP_TYPE_TWO_HAND)
        end
        if not backupIs2H then
            table.insert(slots, { slot = EQUIP_SLOT_BACKUP_OFF, label = "Backup Bar Off-hand" })
        end

        -- If both bars are 2H, no valid off-hand slot exists
        if #slots == 0 then
            return nil, nil
        end

        return slots, "bar_choice"
    end

    -- ONE_HAND: can go main hand OR off-hand on either bar
    -- But skip off-hand slots where a 2H weapon occupies the main hand
    -- (2H weapon = off-hand is blocked/empty by design)
    if equipType == EQUIP_TYPE_ONE_HAND then
        local slots = {}

        -- Main bar: check if main hand has a 2H weapon
        local mainLink = GetItemLink(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
        local mainIs2H = false
        if mainLink and mainLink ~= "" then
            local mainEquipType = GetItemLinkEquipType(mainLink)
            mainIs2H = (mainEquipType == EQUIP_TYPE_TWO_HAND)
        end

        if mainIs2H then
            -- 2H on main bar: only compare against main hand (replacing the 2H)
            table.insert(slots, { slot = EQUIP_SLOT_MAIN_HAND, label = "Main Hand (2H)" })
        else
            table.insert(slots, { slot = EQUIP_SLOT_MAIN_HAND, label = "Main Hand" })
            table.insert(slots, { slot = EQUIP_SLOT_OFF_HAND, label = "Off Hand" })
        end

        -- Backup bar: check if backup main has a 2H weapon
        local backupLink = GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
        local backupIs2H = false
        if backupLink and backupLink ~= "" then
            local backupEquipType = GetItemLinkEquipType(backupLink)
            backupIs2H = (backupEquipType == EQUIP_TYPE_TWO_HAND)
        end

        if backupIs2H then
            -- 2H on backup bar: only compare against backup main
            table.insert(slots, { slot = EQUIP_SLOT_BACKUP_MAIN, label = "Backup Main (2H)" })
        else
            -- Check if backup has anything at all
            if backupLink and backupLink ~= "" then
                table.insert(slots, { slot = EQUIP_SLOT_BACKUP_MAIN, label = "Backup Main" })
                table.insert(slots, { slot = EQUIP_SLOT_BACKUP_OFF, label = "Backup Off" })
            else
                -- Backup bar empty — offer both slots
                table.insert(slots, { slot = EQUIP_SLOT_BACKUP_MAIN, label = "Backup Main" })
                table.insert(slots, { slot = EQUIP_SLOT_BACKUP_OFF, label = "Backup Off" })
            end
        end

        return slots, "paired_replace_worst"
    end

    return nil, nil
end

----------------------------------------------------------------------
-- Build all comparisons for an item and pick the smartest one
-- "paired_replace_worst": compare against worst equipped in group
-- "bar_choice": compare against each bar, pick most beneficial
-- "single": only one slot, straightforward
----------------------------------------------------------------------
local function SmartCompare(newEval, equipType)
    local slotDefs, strategy = GetComparisonSlots(equipType)
    if not slotDefs then return nil end

    local comparisons = {}
    for _, slotDef in ipairs(slotDefs) do
        local comp = SmartGear._BuildComparison(newEval, slotDef.slot)
        comp.slotLabel = slotDef.label
        table.insert(comparisons, comp)
    end

    if #comparisons == 0 then return nil end

    if strategy == "paired_replace_worst" then
        -- Smart priority for paired slots (rings, dual wield):
        -- 1. Empty valid slot = free upgrade, always best option
        -- 2. Occupied slot with lowest score = suggest replacing worst
        local worstOccupied = nil
        local firstEmpty = nil
        for _, comp in ipairs(comparisons) do
            if comp.slotEmpty then
                if not firstEmpty then firstEmpty = comp end
            else
                if not worstOccupied or comp.equippedScore < worstOccupied.equippedScore then
                    worstOccupied = comp
                end
            end
        end
        -- Empty slot = free equip (no loss), always prefer it
        -- Unless no empty slots, then suggest replacing the weakest item
        if firstEmpty then
            return firstEmpty
        end
        return worstOccupied

    elseif strategy == "bar_choice" then
        -- For weapons on different bars, show comparison for the bar
        -- where this item would be the biggest upgrade.
        -- Prefer occupied slots over empty ones.
        local bestOccupied = nil
        local firstEmpty = nil
        for _, comp in ipairs(comparisons) do
            if comp.slotEmpty then
                if not firstEmpty then firstEmpty = comp end
            else
                if not bestOccupied or comp.scoreDiff > bestOccupied.scoreDiff then
                    bestOccupied = comp
                end
            end
        end
        return bestOccupied or firstEmpty

    else -- "single"
        return comparisons[1]
    end
end

----------------------------------------------------------------------
-- COMPARATOR: Compare inventory item against equipped item(s)
----------------------------------------------------------------------
function SmartGear.CompareWithEquipped(bagId, slotIndex)
    local itemLink = GetItemLink(bagId, slotIndex)
    if not itemLink or itemLink == "" then return nil end

    local equipType = GetItemLinkEquipType(itemLink)
    if not equipType or equipType == EQUIP_TYPE_INVALID then return nil end

    local newEval = SmartGear.EvaluateItem(bagId, slotIndex)
    if not newEval then return nil end

    local comp = SmartCompare(newEval, equipType)
    if comp then comp.newEval = newEval end
    return comp
end

----------------------------------------------------------------------
-- COMPARATOR from item link (for tooltip hooks)
----------------------------------------------------------------------
function SmartGear.CompareWithEquippedByLink(itemLink)
    if not itemLink or itemLink == "" then return nil end

    local equipType = GetItemLinkEquipType(itemLink)
    if not equipType or equipType == EQUIP_TYPE_INVALID then return nil end

    local newEval = SmartGear.EvaluateItemLink(itemLink)
    if not newEval then return nil end

    local comp = SmartCompare(newEval, equipType)
    if comp then comp.newEval = newEval end
    return comp
end

----------------------------------------------------------------------
-- Internal: build a comparison struct between newEval and a worn slot
----------------------------------------------------------------------
function SmartGear._BuildComparison(newEval, wornSlot)
    local equippedLink = GetItemLink(BAG_WORN, wornSlot)
    local slotEmpty = (not equippedLink or equippedLink == "")
    local equippedEval = nil
    local equippedName = nil

    if not slotEmpty then
        equippedEval = EvaluateEquippedSlot(wornSlot)
        equippedName = GetItemName(BAG_WORN, wornSlot)
        if equippedName then equippedName = zo_strformat("<<1>>", equippedName) end
    end

    local eqScore = equippedEval and equippedEval.score or 0

    -- TWO-HAND vs DUAL WIELD penalty:
    -- If the new item is 2H and the current main hand is 1H (dual wield),
    -- equipping 2H will REMOVE the off-hand weapon too.
    -- We must add the off-hand score to the "cost" of switching.
    local twoHandPenalty = 0
    local displacedOffName = nil
    if newEval.equipType == EQUIP_TYPE_TWO_HAND and equippedEval then
        local curEquipType = GetItemLinkEquipType(equippedLink)
        if curEquipType == EQUIP_TYPE_ONE_HAND or curEquipType == EQUIP_TYPE_MAIN_HAND then
            -- Find the corresponding off-hand slot
            local offSlot = nil
            if wornSlot == EQUIP_SLOT_MAIN_HAND then
                offSlot = EQUIP_SLOT_OFF_HAND
            elseif wornSlot == EQUIP_SLOT_BACKUP_MAIN then
                offSlot = EQUIP_SLOT_BACKUP_OFF
            end
            if offSlot then
                local offLink = GetItemLink(BAG_WORN, offSlot)
                if offLink and offLink ~= "" then
                    local offEval = EvaluateEquippedSlot(offSlot)
                    if offEval then
                        twoHandPenalty = offEval.score
                        displacedOffName = GetItemName(BAG_WORN, offSlot)
                        if displacedOffName then
                            displacedOffName = zo_strformat("<<1>>", displacedOffName)
                        end
                    end
                end
            end
        end
    end

    local totalEqScore = eqScore + twoHandPenalty

    local comp = {
        wornSlot        = wornSlot,
        slotEmpty       = slotEmpty,
        equippedLink    = equippedLink,
        equippedName    = equippedName or "",
        equippedScore   = totalEqScore,
        equippedSetName = equippedEval and equippedEval.setName or nil,
        equippedTraitName = equippedEval and equippedEval.traitName or nil,
        equippedRating  = equippedEval and equippedEval.rating or SmartGear.RATING_BAD,
        newScore        = newEval.score,
        scoreDiff       = newEval.score - totalEqScore,
        isUpgrade       = false,
        isDowngrade     = false,
        isSidegrade     = false,
        verdict         = "unknown",
        changes         = {},
        twoHandPenalty  = twoHandPenalty,
        displacedOffName = displacedOffName,
    }

    if slotEmpty then
        comp.isUpgrade = true
        comp.verdict = "upgrade"
        table.insert(comp.changes, { aspect = "slot", direction = "up", detail = "empty_slot" })
        return comp
    end

    -- 2H displaces off-hand warning
    if twoHandPenalty > 0 then
        table.insert(comp.changes, {
            aspect = "weapon", direction = "down",
            detail = "displaces_offhand",
            value = displacedOffName or "?",
            penalty = twoHandPenalty,
        })
    end

    -- Detailed change tracking
    if newEval.setName and equippedEval then
        -- Meta tier comparison
        if newEval.isMetaSet and not equippedEval.isMetaSet then
            table.insert(comp.changes, { aspect = "set", direction = "up", detail = "meta_vs_nonmeta" })
        elseif not newEval.isMetaSet and equippedEval.isMetaSet then
            table.insert(comp.changes, { aspect = "set", direction = "down", detail = "nonmeta_vs_meta" })
        elseif newEval.isMetaSet and equippedEval.isMetaSet then
            local tierVal = { S = 4, A = 3, B = 2, C = 1 }
            local nv = tierVal[newEval.metaTier] or 0
            local ev = tierVal[equippedEval.metaTier] or 0
            if nv > ev then
                table.insert(comp.changes, { aspect = "set", direction = "up", detail = "higher_tier" })
            elseif nv < ev then
                table.insert(comp.changes, { aspect = "set", direction = "down", detail = "lower_tier" })
            end
        end
        -- Set completion
        if newEval.completesSet and not (equippedEval.completesSet) then
            table.insert(comp.changes, { aspect = "set_bonus", direction = "up", detail = "completes_set" })
        end
    end

    -- Trait
    if newEval.traitName and equippedEval and equippedEval.traitName then
        if newEval.isOptimalTrait and not equippedEval.isOptimalTrait then
            table.insert(comp.changes, { aspect = "trait", direction = "up", detail = "better_trait" })
        elseif not newEval.isOptimalTrait and equippedEval.isOptimalTrait then
            table.insert(comp.changes, { aspect = "trait", direction = "down", detail = "worse_trait" })
        end
    end

    -- Weight
    if newEval.armorWeight and equippedEval and equippedEval.armorWeight then
        if newEval.isOptimalWeight and not equippedEval.isOptimalWeight then
            table.insert(comp.changes, { aspect = "weight", direction = "up", detail = "better_weight" })
        elseif not newEval.isOptimalWeight and equippedEval.isOptimalWeight then
            table.insert(comp.changes, { aspect = "weight", direction = "down", detail = "worse_weight" })
        end
    end

    -- Quality
    if newEval.quality and equippedEval and equippedEval.quality then
        if newEval.quality > equippedEval.quality then
            table.insert(comp.changes, { aspect = "quality", direction = "up", detail = "higher_quality" })
        elseif newEval.quality < equippedEval.quality then
            table.insert(comp.changes, { aspect = "quality", direction = "down", detail = "lower_quality" })
        end
    end

    -- Item level comparison
    if newEval.itemLevel and equippedEval and equippedEval.itemLevel then
        comp.newItemLevel = newEval.itemLevel
        comp.equippedItemLevel = equippedEval.itemLevel
        comp.levelDiff = newEval.itemLevel - equippedEval.itemLevel
        if newEval.itemLevel > equippedEval.itemLevel then
            table.insert(comp.changes, {
                aspect = "level", direction = "up",
                detail = "higher_level",
                value = "+" .. (newEval.itemLevel - equippedEval.itemLevel),
            })
        elseif newEval.itemLevel < equippedEval.itemLevel then
            table.insert(comp.changes, {
                aspect = "level", direction = "down",
                detail = "lower_level",
                value = tostring(newEval.itemLevel - equippedEval.itemLevel),
            })
        end
    end

    -- Weapon placement analysis (trait + DW Expert + Twin Blade)
    if newEval.itemLink then
        local advice, placementBonus, dwBonus, hints = SmartGear.AnalyzeWeaponPlacement(newEval.itemLink, wornSlot)
        if advice then
            comp.weaponAdvice = advice
            comp.weaponDwBonus = dwBonus
            comp.scoreDiff = comp.scoreDiff + placementBonus

            -- Trait hand warnings
            if advice == "trait_wrong_offhand" then
                table.insert(comp.changes, {
                    aspect = "weapon", direction = "down",
                    detail = "trait_wrong_hand",
                })
            elseif advice == "trait_correct_main" then
                table.insert(comp.changes, {
                    aspect = "weapon", direction = "up",
                    detail = "trait_correct_hand",
                })
            end

            -- DW Expert placement hints
            if hints then
                for _, hint in ipairs(hints) do
                    if hint == "low_dmg_offhand_bad" then
                        table.insert(comp.changes, {
                            aspect = "weapon", direction = "down",
                            detail = "dw_expert_bad_offhand",
                        })
                    elseif hint == "high_dmg_offhand_good" then
                        table.insert(comp.changes, {
                            aspect = "weapon", direction = "up",
                            detail = "dw_expert_good_offhand",
                        })
                    elseif hint == "dagger_main_good" then
                        table.insert(comp.changes, {
                            aspect = "weapon", direction = "up",
                            detail = "dagger_main_optimal",
                        })
                    elseif hint == "high_dmg_main_suboptimal" then
                        table.insert(comp.changes, {
                            aspect = "weapon", direction = "down",
                            detail = "high_dmg_main_waste",
                        })
                    end
                end
            end

            -- Twin Blade and Blunt info
            if dwBonus then
                table.insert(comp.changes, {
                    aspect = "weapon_type", direction = "info",
                    detail = "dw_bonus",
                    value = dwBonus.desc_en,
                })
            end
        end
    end

    -- Verdict
    local diff = comp.scoreDiff
    if diff >= 10 then
        comp.isUpgrade = true;   comp.verdict = "upgrade"
    elseif diff >= 3 then
        comp.isUpgrade = true;   comp.verdict = "slight_upgrade"
    elseif diff > -3 then
        comp.isSidegrade = true; comp.verdict = "sidegrade"
    elseif diff > -10 then
        comp.isDowngrade = true; comp.verdict = "slight_downgrade"
    else
        comp.isDowngrade = true; comp.verdict = "downgrade"
    end

    return comp
end

----------------------------------------------------------------------
-- Evaluate from item link directly (for tooltip hooks)
----------------------------------------------------------------------
function SmartGear.EvaluateItemLink(itemLink)
    if not itemLink or itemLink == "" then return nil end

    local linkItemType = GetItemLinkItemType(itemLink)
    if linkItemType ~= ITEMTYPE_ARMOR and linkItemType ~= ITEMTYPE_WEAPON then
        return nil
    end

    local role = SmartGear.currentRole or "MagDD"
    local pvpMode = SmartGear.savedVars and SmartGear.savedVars.pvpMode or false
    local equippedSets = GetEquippedSets()

    local result = {
        itemLink = itemLink,
        role = role,
        rating = SmartGear.RATING_BAD,
        stars = 0,
        setName = nil,
        isMetaSet = false,
        metaTier = nil,
        metaNotes = nil,
        isForCurrentRole = false,
        isForAnyRole = false,
        isEquippedSet = false,
        setEquipped = 0,
        setMax = 0,
        completesSet = false,
        traitName = nil,
        traitQuality = "unknown",
        isOptimalTrait = false,
        armorWeight = nil,
        isOptimalWeight = true,
        quality = GetItemLinkQuality(itemLink),
        -- Level & stats
        itemLevel = 0,
        requiredLevel = 0,
        requiredCP = 0,
        isMythic = false,
        isMonsterSet = false,
        isPvpSet = false,
        recommendTransmute = false,
        equipType = GetItemLinkEquipType(itemLink),
    }

    -- === LEVEL ANALYSIS (from link) ===
    result.requiredLevel = GetItemLinkRequiredLevel(itemLink) or 0
    result.requiredCP = GetItemLinkRequiredChampionPoints(itemLink) or 0
    if result.requiredCP > 0 then
        result.itemLevel = 50 + result.requiredCP
    else
        result.itemLevel = result.requiredLevel
    end

    -- === SET ANALYSIS ===
    local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
    if hasSet then
        result.setName = setName
        -- Check equipped sets
        if equippedSets[setId] then
            result.isEquippedSet = true
            result.setEquipped = equippedSets[setId].equipped
        end
        result.setMax = maxEquipped or 5
        if result.isEquippedSet then
            result.completesSet = (result.setEquipped + 1) >= result.setMax
        end

        local metaInfo = GetMetaInfo(setName)
        if metaInfo then
            result.isMetaSet = true
            result.metaTier = metaInfo.tier
            result.metaRating = metaInfo.rating or 50
            result.metaNotes = metaInfo.notes
            result.isMythic = metaInfo.isMythic or false
            result.isMonsterSet = metaInfo.isMonsterSet or false
            result.isPvpSet = metaInfo.pvpOnly or false
            result.isForCurrentRole = IsSetForRole(metaInfo, role, pvpMode)
            result.isForAnyRole = IsSetForAnyRole(metaInfo)
        end
    end

    -- === TRAIT ANALYSIS (from link) ===
    local traitType = GetItemLinkTraitType(itemLink)
    if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
        result.traitName = SmartGear.TraitNames[traitType] or GetString("SI_ITEMTRAITTYPE", traitType)

        local equipType = GetItemLinkEquipType(itemLink)
        if equipType == EQUIP_TYPE_NECK or equipType == EQUIP_TYPE_RING then
            result.traitQuality, result.isOptimalTrait = EvaluateJewelryTrait(traitType, role)
        elseif equipType == EQUIP_TYPE_MAIN_HAND or equipType == EQUIP_TYPE_OFF_HAND
            or equipType == EQUIP_TYPE_ONE_HAND or equipType == EQUIP_TYPE_TWO_HAND then
            result.traitQuality, result.isOptimalTrait = EvaluateWeaponTrait(traitType, role)
        else
            result.traitQuality, result.isOptimalTrait = EvaluateArmorTrait(traitType, role, pvpMode)
        end

        if result.isMetaSet and result.isForCurrentRole and not result.isOptimalTrait then
            result.recommendTransmute = true
        end
    end

    -- === ARMOR WEIGHT (from link) ===
    local armorType = GetItemLinkArmorType(itemLink)
    if armorType and armorType ~= ARMORTYPE_NONE then
        result.armorWeight = armorType
        result.isOptimalWeight = EvaluateArmorWeight(armorType, role)
    end

    -- === SCORING (shared function) ===
    SmartGear.ComputeScore(result, role, pvpMode)
    return result
end
