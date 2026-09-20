local A = ESOBuildTracker

A.slotDefinitions = {
    { key = "head", label = "Head", constant = "EQUIP_SLOT_HEAD" },
    { key = "chest", label = "Chest", constant = "EQUIP_SLOT_CHEST" },
    { key = "shoulders", label = "Shoulders", constant = "EQUIP_SLOT_SHOULDERS" },
    { key = "hands", label = "Hands", constant = "EQUIP_SLOT_HAND" },
    { key = "waist", label = "Waist", constant = "EQUIP_SLOT_WAIST" },
    { key = "legs", label = "Legs", constant = "EQUIP_SLOT_LEGS" },
    { key = "feet", label = "Feet", constant = "EQUIP_SLOT_FEET" },
    { key = "neck", label = "Necklace", constant = "EQUIP_SLOT_NECK" },
    { key = "ring1", label = "Ring 1", constant = "EQUIP_SLOT_RING1" },
    { key = "ring2", label = "Ring 2", constant = "EQUIP_SLOT_RING2" },
    { key = "frontMain", label = "Front bar - main hand", constant = "EQUIP_SLOT_MAIN_HAND" },
    { key = "frontOff", label = "Front bar - off hand", constant = "EQUIP_SLOT_OFF_HAND" },
    { key = "backMain", label = "Back bar - main hand", constant = "EQUIP_SLOT_BACKUP_MAIN" },
    { key = "backOff", label = "Back bar - off hand", constant = "EQUIP_SLOT_BACKUP_OFF" },
    { key = "frontPoison", label = "Front bar - poison", constant = "EQUIP_SLOT_POISON" },
    { key = "backPoison", label = "Back bar - poison", constant = "EQUIP_SLOT_BACKUP_POISON" },
    { key = "costume", label = "Equipped disguise / costume item", constant = "EQUIP_SLOT_COSTUME" },
}

local additionalSlots = {
    { key = "class1", label = "Additional equipped slot 1", constant = "EQUIP_SLOT_CLASS1" },
    { key = "class2", label = "Additional equipped slot 2", constant = "EQUIP_SLOT_CLASS2" },
    { key = "class3", label = "Additional equipped slot 3", constant = "EQUIP_SLOT_CLASS3" },
    { key = "ranged", label = "Additional ranged slot", constant = "EQUIP_SLOT_RANGED" },
    { key = "wrist", label = "Additional wrist slot", constant = "EQUIP_SLOT_WRIST" },
}

function A.ReadItem(def, warnings, existingLink)
    local slot = _G[def.constant]
    local item = { key = def.key, slotLabel = def.label, slotId = slot, status = "unavailable" }
    if slot == nil then
        warnings[def.constant] = def.constant .. ": equipment slot is not available."
        return item
    end
    local link = existingLink or A.Call(warnings, "GetItemLink", BAG_WORN, slot, LINK_STYLE_DEFAULT)
    if link == nil then return item end
    if link == "" then item.status = "empty"; return item end

    item.status = "equipped"
    item.link = link
    item.name = A.CleanName(A.Call(warnings, "GetItemLinkName", link))
    item.itemId = A.Call(warnings, "GetItemLinkItemId", link)
    local uniqueId = A.Call(warnings, "GetItemUniqueId", BAG_WORN, slot)
    if uniqueId ~= nil then item.uniqueId = A.Call(warnings, "Id64ToString", uniqueId) end
    local icon, stack = A.Call(warnings, "GetItemInfo", BAG_WORN, slot)
    item.icon, item.stack = icon, stack
    item.quality = A.Call(warnings, "GetItemLinkFunctionalQuality", link)
    item.qualityName = A.EnumName("SI_ITEMQUALITY", item.quality)
    item.requiredLevel = A.Call(warnings, "GetItemLinkRequiredLevel", link)
    item.requiredCP = A.Call(warnings, "GetItemLinkRequiredChampionPoints", link)
    item.equipType = A.Call(warnings, "GetItemLinkEquipType", link)
    item.armorType = A.Call(warnings, "GetItemLinkArmorType", link)
    item.weaponType = A.Call(warnings, "GetItemLinkWeaponType", link)
    item.trait, item.traitDescription = A.Call(warnings, "GetItemLinkTraitInfo", link)
    item.traitName = A.EnumName("SI_ITEMTRAITTYPE", item.trait)
    item.hasEnchantCharges, item.enchantName, item.enchantDescription = A.Call(warnings, "GetItemLinkEnchantInfo", link)
    item.enchantId = A.Call(warnings, "GetItemLinkFinalEnchantId", link)
    item.armorRating = A.Call(warnings, "GetItemLinkArmorRating", link, false)
    item.weaponPower = A.Call(warnings, "GetItemLinkWeaponPower", link)
    item.conditionPercent = A.Call(warnings, "GetItemCondition", BAG_WORN, slot)
    if item.armorType and item.armorType ~= ARMORTYPE_NONE then
        item.armorTypeName = A.EnumName("SI_ARMORTYPE", item.armorType)
    end
    if item.weaponType and item.weaponType ~= WEAPONTYPE_NONE then
        item.weaponTypeName = A.EnumName("SI_WEAPONTYPE", item.weaponType)
    end

    local hasSet, name, bonusCount, normalCount, maxCount, setId, perfectedCount = A.Call(warnings, "GetItemLinkSetInfo", link, true)
    if hasSet then
        item.set = {
            id = setId, name = A.CleanName(name), bonuses = {},
            normalEquippedAtCapture = normalCount,
            perfectedEquippedAtCapture = perfectedCount,
            maxEquipped = maxCount,
        }
        for i = 1, bonusCount or 0 do
            local required, text, perfected = A.Call(warnings, "GetItemLinkSetBonusInfo", link, true, i)
            item.set.bonuses[#item.set.bonuses + 1] = {
                required = required, description = text, perfectedOnly = perfected,
            }
        end
    elseif hasSet == false then
        item.noSet = true
    end
    -- Distinguish a missing enchant from a read failure. hasEnchantCharges is
    -- NOT a "has enchantment" flag: armor glyphs normally have no charges.
    item.enchantReadComplete = item.enchantName ~= nil and item.enchantDescription ~= nil
    return item
end

function A.ReadBar(label, category, warnings)
    local bar = { label = label, category = category, slots = {} }
    if category == nil then warnings[label] = label .. ": hotbar category unavailable." end
    for index = 1, 6 do
        -- ESO's weapon abilities occupy action slots 3..7; ultimate is 8.
        local actionSlot = index + 2
        local skill = { position = index, actionSlot = actionSlot, ultimate = index == 6, status = "unavailable" }
        bar.slots[index] = skill
        if category ~= nil then
            local actionType = A.Call(warnings, "GetSlotType", actionSlot, category)
            local boundId = A.Call(warnings, "GetSlotBoundId", actionSlot, category)
            skill.actionType, skill.boundId = actionType, boundId
            if actionType == ACTION_TYPE_NOTHING or (actionType ~= nil and boundId == 0) then
                skill.status = "empty"
            elseif actionType ~= nil and boundId ~= nil then
                skill.status = "slotted"
                skill.name = A.CleanName(A.Call(warnings, "GetSlotName", actionSlot, category))
                skill.icon = A.Call(warnings, "GetSlotTexture", actionSlot, category)
                if actionType == ACTION_TYPE_ABILITY then
                    skill.abilityId = boundId
                    local hasProgression, progressionIndex = A.Call(warnings, "GetAbilityProgressionXPInfoFromAbilityId", boundId)
                    if hasProgression and progressionIndex then
                        local _, morph, rank = A.Call(warnings, "GetAbilityProgressionInfo", progressionIndex)
                        skill.morph, skill.rank = morph, rank
                    end
                elseif actionType == ACTION_TYPE_CRAFTED_ABILITY then
                    skill.craftedAbilityId = boundId
                    skill.abilityId = A.Call(warnings, "GetCraftedAbilityRepresentativeAbilityId", boundId, "player")
                    local focus, signature, affix = A.Call(warnings, "GetCraftedAbilityActiveScriptIds", boundId)
                    skill.scripts = {}
                    for i, scriptId in pairs({ focus, signature, affix }) do
                        if scriptId and scriptId ~= 0 then
                            skill.scripts[i] = {
                                id = scriptId,
                                name = A.CleanName(A.Call(warnings, "GetCraftedAbilityScriptDisplayName", scriptId)),
                            }
                        end
                    end
                else
                    -- Preserve special/Vengeance slots without interpreting
                    -- their action IDs as ordinary skill ability IDs.
                    skill.specialAction = true
                end
                if skill.abilityId and skill.abilityId > 0 then
                    skill.description = A.Call(warnings, "GetAbilityDescription", skill.abilityId, nil, "player")
                end
            end
        end
    end
    return bar
end

local statDefinitions = {
    { "Max Health", "STAT_HEALTH_MAX" },
    { "Max Magicka", "STAT_MAGICKA_MAX" },
    { "Max Stamina", "STAT_STAMINA_MAX" },
    { "Weapon Damage", "STAT_POWER" },
    { "Spell Damage", "STAT_SPELL_POWER" },
    { "Physical Resistance", "STAT_PHYSICAL_RESIST" },
    { "Spell Resistance", "STAT_SPELL_RESIST" },
    { "Physical Penetration", "STAT_PHYSICAL_PENETRATION" },
    { "Spell Penetration", "STAT_SPELL_PENETRATION" },
    { "Health Recovery (combat)", "STAT_HEALTH_REGEN_COMBAT" },
    { "Magicka Recovery (combat)", "STAT_MAGICKA_REGEN_COMBAT" },
    { "Stamina Recovery (combat)", "STAT_STAMINA_REGEN_COMBAT" },
}

function A.Capture(reason)
    local warnings = {}
    local snapshot = {
        schemaVersion = A.schemaVersion, addonVersion = A.version,
        reason = reason, capturedAt = A.Call(warnings, "GetTimeStamp"),
        apiVersion = A.Call(warnings, "GetAPIVersion"),
        characterId = A.Call(warnings, "GetCurrentCharacterId"),
        characterName = A.CleanName(A.Call(warnings, "GetUnitName", "player")),
        world = A.Call(warnings, "GetWorldName"),
        level = A.Call(warnings, "GetUnitLevel", "player"),
        championPoints = A.Call(warnings, "GetUnitChampionPoints", "player"),
        className = A.CleanName(A.Call(warnings, "GetUnitClass", "player")),
        raceName = A.CleanName(A.Call(warnings, "GetUnitRace", "player")),
        inCombat = A.Call(warnings, "IsUnitInCombat", "player"),
        activeHotbarCategory = A.Call(warnings, "GetActiveHotbarCategory"),
        equipment = {}, stats = {}, coreDataComplete = true,
    }
    snapshot.activeWeaponPair, snapshot.weaponSwapLocked = A.Call(warnings, "GetActiveWeaponPairInfo")
    snapshot.capturedTimeText = A.Call(warnings, "GetTimeString")
    if snapshot.capturedAt then snapshot.capturedDateText = A.Call(warnings, "GetDateStringFromTimestamp", snapshot.capturedAt) end
    if snapshot.apiVersion ~= A.referenceAPIVersion then
        warnings.version = "Runtime API differs from reference " .. A.referenceAPIVersion .. ". Validate all readings before relying on this build."
    end
    for _, def in ipairs(A.slotDefinitions) do
        local item = A.ReadItem(def, warnings)
        snapshot.equipment[#snapshot.equipment + 1] = item
        if item.status == "unavailable" then snapshot.coreDataComplete = false end
    end
    -- Old/reserved equipment slots are included only if actually occupied.
    for _, def in ipairs(additionalSlots) do
        local slot = _G[def.constant]
        if slot ~= nil then
            local link = A.Call(nil, "GetItemLink", BAG_WORN, slot, LINK_STYLE_DEFAULT)
            if link and link ~= "" then snapshot.equipment[#snapshot.equipment + 1] = A.ReadItem(def, warnings, link) end
        end
    end
    snapshot.bars = {
        A.ReadBar("Front bar", HOTBAR_CATEGORY_PRIMARY, warnings),
        A.ReadBar("Back bar", HOTBAR_CATEGORY_BACKUP, warnings),
    }
    for _, bar in ipairs(snapshot.bars) do
        for _, skill in ipairs(bar.slots) do
            if skill.status == "unavailable" then snapshot.coreDataComplete = false end
        end
    end
    for _, def in ipairs(statDefinitions) do
        local statId = _G[def[2]]
        local value
        if statId ~= nil then value = A.Call(warnings, "GetPlayerStat", statId, STAT_BONUS_OPTION_APPLY_BONUS) end
        snapshot.stats[#snapshot.stats + 1] = { label = def[1], constant = def[2], value = value }
    end
    snapshot.warnings = A.WarningList(warnings)
    return snapshot
end
