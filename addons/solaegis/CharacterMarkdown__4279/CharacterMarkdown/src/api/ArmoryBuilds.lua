-- CharacterMarkdown - API Layer - Armory Builds
-- Abstraction for armory system builds and loadouts

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.armoryBuilds = {}

local api = CM.api.armoryBuilds

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetNumUnlocked()
    return CM.SafeCall(GetNumUnlockedArmoryBuilds) or 0
end

function api.GetBuildName(buildIndex)
    return CM.SafeCall(GetArmoryBuildName, buildIndex) or ""
end

function api.GetBuildIconIndex(buildIndex)
    return CM.SafeCall(GetArmoryBuildIconIndex, buildIndex) or 0
end

function api.GetBuildAttributePoints(buildIndex)
    local health = CM.SafeCall(GetArmoryBuildAttributeSpentPoints, buildIndex, ATTRIBUTE_HEALTH) or 0
    local magicka = CM.SafeCall(GetArmoryBuildAttributeSpentPoints, buildIndex, ATTRIBUTE_MAGICKA) or 0
    local stamina = CM.SafeCall(GetArmoryBuildAttributeSpentPoints, buildIndex, ATTRIBUTE_STAMINA) or 0

    if health > 0 or magicka > 0 or stamina > 0 then
        return {
            health = health,
            magicka = magicka,
            stamina = stamina,
        }
    end

    return {}
end

function api.GetBuildChampionPoints(buildIndex)
    local craft, warfare, fitness = 0, 0, 0
    for disciplineIndex = 1, 3 do
        local disciplineId = CM.SafeCall(GetChampionDisciplineId, disciplineIndex)
        if disciplineId then
            local spent = CM.SafeCall(GetArmoryBuildChampionSpentPointsByDiscipline, buildIndex, disciplineId) or 0
            if disciplineIndex == 1 then
                craft = spent
            elseif disciplineIndex == 2 then
                warfare = spent
            elseif disciplineIndex == 3 then
                fitness = spent
            end
        end
    end

    if craft > 0 or warfare > 0 or fitness > 0 then
        return {
            craft = craft,
            warfare = warfare,
            fitness = fitness,
            total = craft + warfare + fitness,
        }
    end

    return {}
end

local function GetMundusStoneName(stoneId)
    if not stoneId or stoneId <= 0 then
        return nil
    end
    local name = CM.SafeCall(GetString, "SI_MUNDUSSTONE", stoneId)
    if name and name ~= "" then
        return name
    end
    return "Mundus Stone " .. tostring(stoneId)
end

function api.GetBuildEquipment(buildIndex)
    local equipment = {}
    local equipSlots = {
        EQUIP_SLOT_HEAD,
        EQUIP_SLOT_NECK,
        EQUIP_SLOT_CHEST,
        EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_MAIN_HAND,
        EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_WAIST,
        EQUIP_SLOT_LEGS,
        EQUIP_SLOT_FEET,
        EQUIP_SLOT_RING1,
        EQUIP_SLOT_RING2,
        EQUIP_SLOT_HAND,
        EQUIP_SLOT_BACKUP_MAIN,
        EQUIP_SLOT_BACKUP_OFF,
    }

    for _, slot in ipairs(equipSlots) do
        local success, equipSlotState, bagId, slotIndex = CM.SafeCallMulti(
            GetArmoryBuildEquipSlotInfo,
            buildIndex,
            slot
        )
        if success and equipSlotState and bagId and slotIndex then
            local itemLink = CM.SafeCall(GetItemLink, bagId, slotIndex, LINK_STYLE_DEFAULT)
            if itemLink and itemLink ~= "" then
                local itemName = CM.SafeCall(GetItemLinkName, itemLink)
                if itemName and itemName ~= "" then
                    table.insert(equipment, {
                        slot = slot,
                        name = itemName,
                        link = itemLink,
                    })
                end
            end
        end
    end

    return equipment
end

function api.GetBuildHotbars(buildIndex)
    local hotbars = {}

    -- Primary bar
    local primaryBar = {
        category = HOTBAR_CATEGORY_PRIMARY,
        abilities = {},
    }
    for slotIndex = 3, 8 do
        local abilityId = CM.SafeCall(GetArmoryBuildSlotBoundId, buildIndex, slotIndex, HOTBAR_CATEGORY_PRIMARY)
        if abilityId and abilityId > 0 then
            local abilityName = CM.SafeCall(GetAbilityName, abilityId, "player")
            if abilityName and abilityName ~= "" then
                table.insert(primaryBar.abilities, {
                    slot = slotIndex,
                    id = abilityId,
                    name = abilityName,
                })
            end
        end
    end
    if #primaryBar.abilities > 0 then
        table.insert(hotbars, primaryBar)
    end

    -- Backup bar
    local backupBar = {
        category = HOTBAR_CATEGORY_BACKUP,
        abilities = {},
    }
    for slotIndex = 3, 8 do
        local abilityId = CM.SafeCall(GetArmoryBuildSlotBoundId, buildIndex, slotIndex, HOTBAR_CATEGORY_BACKUP)
        if abilityId and abilityId > 0 then
            local abilityName = CM.SafeCall(GetAbilityName, abilityId, "player")
            if abilityName and abilityName ~= "" then
                table.insert(backupBar.abilities, {
                    slot = slotIndex,
                    id = abilityId,
                    name = abilityName,
                })
            end
        end
    end
    if #backupBar.abilities > 0 then
        table.insert(hotbars, backupBar)
    end

    return hotbars
end

function api.GetBuildMundusStones(buildIndex)
    local mundus = {}

    local primary = CM.SafeCall(GetArmoryBuildPrimaryMundusStone, buildIndex)
    if primary and primary > 0 then
        local primaryName = GetMundusStoneName(primary)
        if primaryName and primaryName ~= "" then
            mundus.primary = primaryName
        end
    end

    local secondary = CM.SafeCall(GetArmoryBuildSecondaryMundusStone, buildIndex)
    if secondary and secondary > 0 then
        local secondaryName = GetMundusStoneName(secondary)
        if secondaryName and secondaryName ~= "" then
            mundus.secondary = secondaryName
        end
    end

    return mundus
end

function api.GetBuildCurse(buildIndex)
    local curseType = CM.SafeCall(GetArmoryBuildCurseType, buildIndex)
    if curseType and curseType > 0 then
        if curseType == 1 then
            return "Vampire"
        elseif curseType == 2 then
            return "Werewolf"
        end
    end
    return nil
end

function api.GetBuildInfo(buildIndex)
    local name = api.GetBuildName(buildIndex)
    if not name or name == "" then
        return nil
    end

    return {
        index = buildIndex,
        name = name,
        iconIndex = api.GetBuildIconIndex(buildIndex),
        attributes = api.GetBuildAttributePoints(buildIndex),
        champion = api.GetBuildChampionPoints(buildIndex),
        equipment = api.GetBuildEquipment(buildIndex),
        hotbars = api.GetBuildHotbars(buildIndex),
        mundus = api.GetBuildMundusStones(buildIndex),
        curse = api.GetBuildCurse(buildIndex),
        skillPoints = CM.SafeCall(GetArmoryBuildSkillsTotalSpentPoints, buildIndex) or 0,
        outfitIndex = CM.SafeCall(GetArmoryBuildEquippedOutfitIndex, buildIndex) or 0,
    }
end

-- Composition functions moved to collector level

CM.DebugPrint("API", "ArmoryBuilds API module loaded")
