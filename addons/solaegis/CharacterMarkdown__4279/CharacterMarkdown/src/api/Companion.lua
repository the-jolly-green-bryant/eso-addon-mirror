-- CharacterMarkdown - API Layer - Companion
-- Abstraction for companion data, skills, and equipment

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.companion = {}

local api = CM.api.companion

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetAllCompanions()
    -- Returns list of all companions (both unlocked and locked)
    -- Uses Collectible API to find all companions

    local companions = {}
    local count = 0

    -- Get total companions from the collectible category
    -- Note: COLLECTIBLE_CATEGORY_TYPE_COMPANION should be available in API
    local categoryType = COLLECTIBLE_CATEGORY_TYPE_COMPANION
    if not categoryType then
        -- Fallback if constant not defined (older API versions)
        return { list = {}, count = 0 }
    end

    local total = CM.SafeCall(GetTotalCollectiblesByCategoryType, categoryType) or 0

    for i = 1, total do
        local id = CM.SafeCall(GetCollectibleIdFromType, categoryType, i)
        if id then
            local name = CM.SafeCall(GetCollectibleName, id)
            local nickname = CM.SafeCall(GetCollectibleNickname, id)
            local isUnlocked = CM.SafeCall(IsCollectibleUnlocked, id)

            -- Get companion specific info if needed
            -- local companionId = GetCollectibleReferenceId(id)

            table.insert(companions, {
                id = id,
                name = name or "Unknown",
                nickname = nickname,
                unlocked = isUnlocked,
            })
            count = count + 1
        end
    end

    return {
        list = companions,
        count = count,
    }
end

-- Deprecated: Use GetAllCompanions instead
function api.GetCompanions()
    return api.GetAllCompanions()
end

function api.HasActiveCompanion()
    return CM.SafeCall(HasActiveCompanion) or false
end

function api.GetActiveCompanionId()
    -- Returns the ID of the currently active companion (if any)
    -- Uses companion-specific API only
    if not api.HasActiveCompanion() then
        return nil
    end

    -- Try to get active companion ID using companion-specific APIs
    -- Note: There may not be a direct GetActiveCompanionId() function
    -- This is a placeholder - actual implementation depends on ESO API availability
    -- For now, return nil and let collector handle via unit APIs
    return nil
end

-- GetActiveCompanion() removed - name/level require unit APIs (GetUnitName, GetUnitLevel)
-- These should be composed in the collector using Character API

function api.GetCompanionSkills()
    -- Returns companion ability slots (slots 3-7 are regular, slot 8 is ultimate)
    if not api.HasActiveCompanion() then
        return { ultimate = nil, ultimateId = nil, abilities = {} }
    end

    local skills = { ultimate = nil, ultimateId = nil, abilities = {} }

    -- Ultimate slot (slot 8)
    local ultimateSlotId = CM.SafeCall(GetSlotBoundId, 8, HOTBAR_CATEGORY_COMPANION)
    if ultimateSlotId and ultimateSlotId > 0 then
        skills.ultimate = CM.SafeCall(GetAbilityName, ultimateSlotId, "player") or "[Empty]"
        skills.ultimateId = ultimateSlotId
    else
        skills.ultimate = "[Empty]"
    end

    -- Regular ability slots (3-7)
    for slotIndex = 3, 7 do
        local slotId = CM.SafeCall(GetSlotBoundId, slotIndex, HOTBAR_CATEGORY_COMPANION)
        if slotId and slotId > 0 then
            local abilityName = CM.SafeCall(GetAbilityName, slotId, "player")
            table.insert(skills.abilities, {
                name = (abilityName and abilityName ~= "") and abilityName or "[Empty]",
                id = slotId,
            })
        else
            table.insert(skills.abilities, {
                name = "[Empty]",
                id = nil,
            })
        end
    end

    return skills
end

function api.GetCompanionEquipment()
    -- Returns companion equipment items
    if not api.HasActiveCompanion() then
        return {}
    end

    local equipment = {}
    local equipSlots = {
        { slot = EQUIP_SLOT_MAIN_HAND, name = "Main Hand" },
        { slot = EQUIP_SLOT_OFF_HAND, name = "Off Hand" },
        { slot = EQUIP_SLOT_HEAD, name = "Head" },
        { slot = EQUIP_SLOT_CHEST, name = "Chest" },
        { slot = EQUIP_SLOT_SHOULDERS, name = "Shoulders" },
        { slot = EQUIP_SLOT_HAND, name = "Hands" },
        { slot = EQUIP_SLOT_WAIST, name = "Waist" },
        { slot = EQUIP_SLOT_LEGS, name = "Legs" },
        { slot = EQUIP_SLOT_FEET, name = "Feet" },
    }

    for _, slotInfo in ipairs(equipSlots) do
        local itemName = CM.SafeCall(GetItemName, BAG_COMPANION_WORN, slotInfo.slot)
        if itemName and itemName ~= "" then
            local itemLink = CM.SafeCall(GetItemLink, BAG_COMPANION_WORN, slotInfo.slot, LINK_STYLE_DEFAULT)

            local itemData = {
                slot = slotInfo.name,
                name = itemName,
                quality = "Unknown",
                level = 0,
                hasSet = false,
                setName = nil,
                traitType = nil,
                traitName = nil,
                enchantName = nil,
                enchantCharge = nil,
                enchantMaxCharge = nil,
            }

            if itemLink and itemLink ~= "" then
                -- Quality
                local quality = CM.SafeCall(GetItemLinkDisplayQuality, itemLink)
                local qualityNumeric = quality or 0
                itemData.quality = CM.utils.GetQualityColor(qualityNumeric)
                itemData.qualityNumeric = qualityNumeric
                itemData.qualityEmoji = CM.utils.GetQualityEmoji(qualityNumeric)

                -- Level
                itemData.level = CM.SafeCall(GetItemLinkRequiredLevel, itemLink) or 0

                -- Set information
                local success, has, name, _, numEquipped, maxEquipped =
                    pcall(GetItemLinkSetInfo, itemLink, false)
                if success then
                    itemData.hasSet = has
                    itemData.setName = name
                end

                -- Trait information
                local success2, traitType, traitDesc = pcall(GetItemLinkTraitInfo, itemLink)
                if success2 and traitType then
                    itemData.traitType = traitType
                    itemData.traitName = traitDesc or CM.SafeCall(GetString, "SI_ITEMTRAITTYPE", traitType) or "None"
                end

                -- Enchantment information: hasCharges, enchantHeader, enchantDescription
                local success3, hasCharges, enchantHeader, enchantDescription =
                    pcall(GetItemLinkEnchantInfo, itemLink)
                if success3 then
                    if enchantHeader and enchantHeader ~= "" then
                        itemData.enchantName = enchantHeader
                    elseif enchantDescription and enchantDescription ~= "" then
                        itemData.enchantName = enchantDescription
                    end
                    if hasCharges then
                        itemData.enchantCharge = CM.SafeCall(GetItemLinkNumEnchantCharges, itemLink) or 0
                        itemData.enchantMaxCharge = CM.SafeCall(GetItemLinkMaxEnchantCharges, itemLink) or 0
                    end
                end
            end

            table.insert(equipment, itemData)
        end
    end

    return equipment
end

-- Composition functions moved to collector level

-- =====================================================
-- COMPANION OUTFIT & RAPPORT (API 101049+)
-- =====================================================

function api.GetCompanionOutfit()
    if not api.HasActiveCompanion() then
        return nil
    end

    -- Try to get the active companion's collectible ID
    local companionDefId = CM.SafeCall(GetActiveCompanionDefId)
    if not companionDefId then
        return nil
    end

    local outfitIndex = CM.SafeCall(GetEquippedOutfitIndex, GAMEPLAY_ACTOR_CATEGORY_COMPANION)
    local outfitName = nil

    if outfitIndex and outfitIndex > 0 then
        outfitName = CM.SafeCall(GetOutfitName, GAMEPLAY_ACTOR_CATEGORY_COMPANION, outfitIndex)
    end

    return {
        companionDefId = companionDefId,
        outfitId = outfitIndex,
        outfitName = outfitName or "Default",
    }
end

function api.GetCompanionRapport()
    if not api.HasActiveCompanion() then
        return nil
    end

    local rapportLevel = CM.SafeCall(GetActiveCompanionRapportLevel)
    local rapportDescription = nil

    if rapportLevel then
        rapportDescription = CM.SafeCall(GetActiveCompanionRapportLevelDescription, rapportLevel)
        if not rapportDescription or rapportDescription == "" then
            rapportDescription = CM.SafeCall(GetString, "SI_COMPANIONRAPPORTLEVEL", rapportLevel)
        end
    end

    return {
        level = rapportLevel or 0,
        description = rapportDescription or "Unknown",
    }
end

CM.DebugPrint("API", "Companion API module loaded")
