-- CharacterMarkdown - API Layer - Equipment
-- Abstraction for gear, item links, sets, and traits

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.equipment = {}

local api = CM.api.equipment

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetItemLink(bagId, slotIndex)
    return CM.SafeCall(GetItemLink, bagId, slotIndex, LINK_STYLE_DEFAULT) or ""
end

function api.GetItemInfo(bagId, slotIndex)
    -- Returns detailed info about item in slot
    local link = api.GetItemLink(bagId, slotIndex)
    if not link or link == "" then
        return nil
    end

    local success_info, icon, _, _, _, _, _, _, quality = CM.SafeCallMulti(GetItemInfo, bagId, slotIndex)
    local name = CM.SafeCall(GetItemName, bagId, slotIndex)

    -- Trait
    local traitType = CM.SafeCall(GetItemTrait, bagId, slotIndex)
    local traitName = "None"
    if traitType and traitType > 0 then
        traitName = CM.SafeCall(GetString, "SI_ITEMTRAITTYPE", traitType)
    end

    -- Set Info: hasSet, setName, numBonuses, numNormalEquipped, maxEquipped, setId, numPerfectedEquipped
    -- Pass equipped=true so numNormalEquipped reflects currently worn pieces (2H weapons count as 2)
    local success, hasSet, setName, _, numNormalEquipped, maxEquipped, setId =
        CM.SafeCallMulti(GetItemLinkSetInfo, link, true)

    -- Enchant: hasCharges, enchantHeader, enchantDescription
    local success_enchant, hasCharges, enchantHeader, enchantDescription =
        CM.SafeCallMulti(GetItemLinkEnchantInfo, link)

    return {
        name = name or "Unknown",
        link = link,
        icon = icon,
        quality = quality,
        trait = {
            id = traitType,
            name = traitName,
        },
        set = {
            hasSet = hasSet,
            name = setName,
            id = setId,
            count = numNormalEquipped,
            max = maxEquipped,
        },
        enchant = {
            hasEnchant = hasCharges,
            name = enchantHeader or enchantDescription,
        },
    }
end

function api.GetSetBonuses(itemLink)
    if not itemLink or itemLink == "" then
        return {}
    end

    local success, hasSet, setName, numBonuses, _, _, setId = CM.SafeCallMulti(GetItemLinkSetInfo, itemLink, false)

    if not success or not hasSet then
        return {}
    end

    local bonuses = {}
    for i = 1, numBonuses do
        local success_bonus, numRequired, description = CM.SafeCallMulti(GetItemLinkSetBonusInfo, itemLink, false, i)
        if success_bonus and description and description ~= "" then
            table.insert(bonuses, {
                numRequired = numRequired,
                description = description,
            })
        end
    end

    return bonuses
end

function api.GetEquippedItem(equipSlot)
    return api.GetItemInfo(BAG_WORN, equipSlot)
end

-- Composition functions moved to collector level
