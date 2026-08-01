GuildPlannerPro_Armory = {}

function GuildPlannerPro_Armory:ExportArmoryBuilds()
    local builds = {}
    local numBuilds = GetNumUnlockedArmoryBuilds()
    for i = 1, numBuilds do
        builds[i] = GuildPlannerPro_Armory:ParseArmoryBuild(i, false)
    end

    return builds
end

function GuildPlannerPro_Armory:ParseArmoryBuild(buildIndex, includeExtended)
    local build
    if buildIndex == 0 then
        build = {
            BuildIndex = buildIndex,
            TimeStamp = GetTimeStamp(),
            Name = "Default Gear",
            AttributePointsSpent = GuildPlannerPro_Character:GetAttributeSpentPoints(),
            ChampionPointsSpent = GuildPlannerPro_Character:GetChampionSpentPoints(),
            Hotbars = GuildPlannerPro_Skills:ExportCharacterHotbars(),
            Curse = GetPlayerCurseType(),
            Equipment = GuildPlannerPro_Character:CheckEquipment(),
            MundusStone = GuildPlannerPro_Character:ExportMundus(),
        }
    else
        build = {
            BuildIndex = buildIndex,
            TimeStamp = GetTimeStamp(),
            Name = GetArmoryBuildName(buildIndex),
            IconIndex = GetArmoryBuildIconIndex(buildIndex),
            AttributePointsSpent = GuildPlannerPro_Armory:GetArmoryBuildAttributeSpentPoints(buildIndex),
            ChampionPointsSpent = GuildPlannerPro_Armory:GetArmoryBuildChampionSpentPoints(buildIndex),
            Hotbars = GuildPlannerPro_Armory:ExportArmoryBuildHotbars(buildIndex),
            Curse = GetArmoryBuildCurseType(buildIndex),
            Equipment = GuildPlannerPro_Armory:GetEquipment(buildIndex),
            MundusStone = GetArmoryBuildPrimaryMundusStone(buildIndex),
        }
    end

    if includeExtended then
        build.Champion = GuildPlannerPro_Skills:ExportChampionPoints()
        build.SkillLines = GuildPlannerPro_Skills:ExportCharacterSkillLines()
        build.Stats = GuildPlannerPro_Character:ExportCharacterStats()
    end

    return build
end

function GuildPlannerPro_Armory:GetArmoryBuildAttributeSpentPoints(buildIndex)
    local attributeSpentPoints = {}
    for j = ATTRIBUTE_HEALTH, ATTRIBUTE_ITERATION_END do
        table.insert(attributeSpentPoints, {
            Attribute = j,
            PointsSpent = GetArmoryBuildAttributeSpentPoints(buildIndex, j),
        })
    end

    return attributeSpentPoints
end

function GuildPlannerPro_Armory:GetArmoryBuildChampionSpentPoints(buildIndex)
    local championSpentPoints = {}
    for k = CHAMPION_DISCIPLINE_TYPE_ITERATION_BEGIN, CHAMPION_DISCIPLINE_TYPE_ITERATION_END do
        table.insert(championSpentPoints, {
            ChampionDisciplineType = k,
            PointsSpent = GetArmoryBuildChampionSpentPointsByDiscipline(buildIndex, k),
        })
    end

    return championSpentPoints
end

function GuildPlannerPro_Armory:GetEquipment(buildIndex)
    local EQUIP_SLOTS =
    {
        EQUIP_SLOT_HEAD,
        EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_CHEST,
        EQUIP_SLOT_HAND,
        EQUIP_SLOT_WAIST,
        EQUIP_SLOT_LEGS,
        EQUIP_SLOT_FEET,
        EQUIP_SLOT_NECK,
        EQUIP_SLOT_RING1,
        EQUIP_SLOT_RING2,
        EQUIP_SLOT_MAIN_HAND,
        EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_POISON,
        EQUIP_SLOT_BACKUP_MAIN,
        EQUIP_SLOT_BACKUP_OFF,
        EQUIP_SLOT_BACKUP_POISON,
    }
    local equipment = {}
    for _, equipSlot in ipairs(EQUIP_SLOTS) do
        local slotState, bag, slotIndex = GetArmoryBuildEquipSlotInfo(buildIndex, equipSlot)
        if slotState == ARMORY_BUILD_EQUIP_SLOT_STATE_VALID then
            local itemLink = GetItemLink(bag, slotIndex, LINK_STYLE_BRACKETS)
            local _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
            local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)
            local _, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(itemLink)
            equipment[equipSlot] = {
                ItemId = GetItemLinkItemId(itemLink),
                ItemName = zo_strformat(GetString(SI_TOOLTIP_ITEM_NAME), GetItemName(bag, slotIndex)),
                ItemDisplayQuality = GetItemDisplayQuality(bag, slotIndex),
                ItemLevel = GetItemLevel(bag, slotIndex),
                ItemRequiredLevel = GetItemRequiredLevel(bag, slotIndex),
                ItemRequiredCp = GetItemLinkRequiredChampionPoints(itemLink),
                ItemTrait = traitType,
                ItemTraitDescription = traitDescription,
                ItemTraitCategory = GetItemTraitCategory(bag, slotIndex),
                ItemTraitInformation = GetItemTraitInformation(bag, slotIndex),
                ItemEnchantType = GetEnchantSearchCategoryType(GetItemLinkFinalEnchantId(itemLink)),
                ItemEnchantHeader = enchantHeader,
                ItemEnchantDescription = enchantDescription,
                ItemGlyphMinLevels = GetItemGlyphMinLevels(bag, slotIndex),
                ItemIcon = GetItemLinkIcon(itemLink),
                ItemLink = itemLink,
                SetId = setId,
                EquipSlot = equipSlot,
                EquipType = GetItemLinkEquipType(itemLink),
                ArmorType = GetItemLinkArmorType(itemLink),
                WeaponType = GetItemLinkWeaponType(itemLink),
                ArmorRating = GetItemLinkArmorRating(itemLink, false),
                WeaponPower = GetItemLinkWeaponPower(itemLink),
                TimeStamp = GetTimeStamp(),
            }
        end
    end

    return equipment
end

function GuildPlannerPro_Armory:ExportArmoryBuildHotbars(buildIndex)
    local hotbars = {}

    local hotBarsToExport = { HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP, HOTBAR_CATEGORY_CHAMPION }
    if GetArmoryBuildCurseType(buildIndex) == CURSE_TYPE_WEREWOLF then
        table.insert(hotBarsToExport, HOTBAR_CATEGORY_WEREWOLF)
    end

    local abilityIdToProgressionDataMap = SKILLS_DATA_MANAGER.abilityIdToProgressionDataMap
    for _, hotBarCategory in ipairs(hotBarsToExport) do
        hotbars[hotBarCategory] = {}
        local startActionSlotIndex, endActionSlotIndex
        if hotBarCategory ~= HOTBAR_CATEGORY_CHAMPION then
            startActionSlotIndex, endActionSlotIndex = GetAssignableAbilityBarStartAndEndSlots()
        else
            startActionSlotIndex, endActionSlotIndex = GetAssignableChampionBarStartAndEndSlots()
        end
        for slotIndex = startActionSlotIndex, endActionSlotIndex do
            local boundId = GetArmoryBuildSlotBoundId(buildIndex, slotIndex, hotBarCategory)
            if boundId ~= 0 then
                hotbars[hotBarCategory][slotIndex] = {
                    BoundId = boundId,
                    SlotIndex = slotIndex,
                }
                if hotBarCategory == HOTBAR_CATEGORY_CHAMPION then
                    hotbars[hotBarCategory][slotIndex]["Name"] = GetChampionSkillName(boundId)
                    hotbars[hotBarCategory][slotIndex]["Type"] = ACTION_TYPE_CHAMPION_SKILL
                else
                    local skill = abilityIdToProgressionDataMap[boundId]
                    if skill.skillData:IsCraftedAbility() then
                        local craftedAbilityId = skill:GetCraftedAbilityId()
                        local primaryScriptId, secondaryScriptId, tertiaryScriptId = GetCraftedAbilityActiveScriptIds(craftedAbilityId)
                        hotbars[hotBarCategory][slotIndex]["Name"] = skill:GetDetailedName()
                        hotbars[hotBarCategory][slotIndex]["Type"] = ACTION_TYPE_CRAFTED_ABILITY
                        hotbars[hotBarCategory][slotIndex]["Link"] = GetCraftedAbilityLink(craftedAbilityId, primaryScriptId, secondaryScriptId, tertiaryScriptId, LINK_STYLE_BRACKETS)
                        hotbars[hotBarCategory][slotIndex]["Facts"] = GuildPlannerPro_Skills:GetActiveSkillFacts(boundId)
                    else
                        hotbars[hotBarCategory][slotIndex]["Name"] = skill:GetDetailedName()
                        hotbars[hotBarCategory][slotIndex]["Type"] = ACTION_TYPE_ABILITY
                    end
                end
            end
        end
    end

    return hotbars
end
