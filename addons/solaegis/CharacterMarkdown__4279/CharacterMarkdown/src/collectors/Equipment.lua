-- CharacterMarkdown - Equipment Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

local function CollectEquipmentData()
    local equipment = { sets = {}, items = {} }

    -- Check if LibSets integration is available
    local LibSetsIntegration = CM.utils and CM.utils.LibSetsIntegration
    local libSetsAvailable = LibSetsIntegration
        and LibSetsIntegration.IsLibSetsAvailable
        and LibSetsIntegration.IsLibSetsAvailable()

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

    -- Collect set information and equipment items in a single slot scan
    local sets = {}
    local setItemLinks = {}
    for _, slotIndex in ipairs(equipSlots) do
        local itemInfo = CM.api.equipment.GetEquippedItem(slotIndex)
        if itemInfo and itemInfo.name and itemInfo.name ~= "" then
            if itemInfo.set and itemInfo.set.hasSet and itemInfo.set.name then
                -- Use game-reported equipped count (numNormalEquipped). A two-handed
                -- weapon occupies one slot but counts as two set pieces; slot-based
                -- +1 under-counts those bonuses.
                local equippedCount = itemInfo.set.count
                if type(equippedCount) ~= "number" or equippedCount < 1 then
                    equippedCount = 1
                end
                sets[itemInfo.set.name] = math.max(sets[itemInfo.set.name] or 0, equippedCount)
                if not setItemLinks[itemInfo.set.name] then
                    setItemLinks[itemInfo.set.name] = itemInfo.link
                end
            end

            -- Strip superscript markers from item names (^n, ^N, ^F, ^p, etc.)
            local itemName = itemInfo.name:gsub("%^%w+$", "")
            local itemLink = itemInfo.link
            local hasSet = itemInfo.set and itemInfo.set.hasSet or false
            local setName = itemInfo.set and itemInfo.set.name or nil
            local quality = itemInfo.quality or 0
            if type(quality) ~= "number" then
                quality = 0
            end
            local traitName = itemInfo.trait and itemInfo.trait.name or "None"

            local enchantName = itemInfo.enchant and itemInfo.enchant.name or nil
            local enchantIcon, enchantCharge, enchantMaxCharge = nil, 0, 0
            local success1, name, icon, charge, maxCharge = pcall(GetItemLinkEnchantInfo, itemLink)
            if success1 then
                if charge ~= nil and type(charge) == "number" then
                    enchantCharge = charge
                end
                if maxCharge ~= nil and type(maxCharge) == "number" and maxCharge > 0 then
                    enchantMaxCharge = maxCharge
                end
                if icon then
                    enchantIcon = icon
                end
                if not enchantName and name and name ~= "" and type(name) == "string" then
                    enchantName = name
                end
            end

            local itemStyle = 0
            local success2, style = pcall(GetItemLinkItemStyle, itemLink)
            if success2 and style then
                itemStyle = style
            end

            local requiredLevel, requiredCP = 0, 0
            local success3, level = pcall(GetItemLinkRequiredLevel, itemLink)
            if success3 and level then
                requiredLevel = level
            end
            local success4, cp = pcall(GetItemLinkRequiredChampionPoints, itemLink)
            if success4 and cp then
                requiredCP = cp
            end

            local bindType = BIND_TYPE_NONE
            local success5, bind = pcall(GetItemLinkBindType, itemLink)
            if success5 and bind then
                bindType = bind
            end

            local itemValue = 0
            local success6, value = pcall(GetItemLinkValue, itemLink, false)
            if success6 and value then
                itemValue = value
            end

            local isCrafted = false
            local success7, crafted = pcall(IsItemLinkCrafted, itemLink)
            if success7 then
                isCrafted = crafted
            end

            local armorType = ARMOR_TYPE_NONE
            local weaponType = WEAPON_TYPE_NONE
            local craftedQuality = ITEM_QUALITY_NONE
            local isStolen = false

            local success8, armor = pcall(GetItemLinkArmorType, itemLink)
            if success8 and armor then
                armorType = armor
            end
            local success9, weapon = pcall(GetItemLinkWeaponType, itemLink)
            if success9 and weapon then
                weaponType = weapon
            end
            local success10, craftedQual = pcall(GetItemLinkCraftedQuality, itemLink)
            if success10 and craftedQual then
                craftedQuality = craftedQual
            end
            local success11, stolen = pcall(GetItemLinkStolen, itemLink)
            if success11 then
                isStolen = stolen
            end

            local flavorText = ""
            local originalItemLink = ""
            local success12, flavor = pcall(GetItemLinkFlavorText, itemLink)
            if success12 and flavor and flavor ~= "" then
                flavorText = flavor
            end
            local success13, originalItem = pcall(GetItemLinkClothierOriginalItem, itemLink)
            if success13 and originalItem and originalItem ~= "" then
                originalItemLink = originalItem
            end

            table.insert(equipment.items, {
                slotIndex = slotIndex,
                slotName = CM.utils.GetEquipSlotName(slotIndex),
                emoji = CM.utils.GetSlotEmoji(slotIndex),
                name = itemName,
                setName = (hasSet and setName) and setName or "-",
                quality = CM.utils.GetQualityColor(quality),
                qualityNumeric = quality or 0,
                qualityEmoji = CM.utils.GetQualityEmoji(quality),
                trait = traitName,
                isEmpty = false,
                enchantment = enchantName or false,
                enchantIcon = enchantIcon,
                enchantCharge = enchantCharge,
                enchantMaxCharge = enchantMaxCharge,
                style = itemStyle,
                requiredLevel = requiredLevel,
                requiredCP = requiredCP,
                bindType = bindType,
                value = itemValue,
                isCrafted = isCrafted,
                armorType = armorType,
                weaponType = weaponType,
                craftedQuality = craftedQuality,
                isStolen = isStolen,
                flavorText = flavorText,
                originalItemLink = originalItemLink,
            })
        end
    end

    -- Format sets array with LibSets enhancement if available
    for setName, count in pairs(sets) do
        local setData = { name = setName, count = count }

        -- Enhance with LibSets data if available
        if libSetsAvailable and LibSetsIntegration.GetSetInfo then
            local setInfo = LibSetsIntegration.GetSetInfo(setName)
            if setInfo then
                setData.setType = setInfo.setType
                setData.setTypeName = setInfo.setTypeName
                setData.dropLocations = setInfo.dropLocations
                setData.dropMechanics = setInfo.dropMechanics
                setData.dropMechanicNames = setInfo.dropMechanicNames
                setData.dlcId = setInfo.dlcId
                setData.chapterId = setInfo.chapterId
                setData.zoneIds = setInfo.zoneIds
            end
        end

        -- Get detailed set bonuses
        if setItemLinks[setName] then
            local bonuses = CM.api.equipment.GetSetBonuses(setItemLinks[setName])
            if bonuses then
                -- Add active status to each bonus
                for _, bonus in ipairs(bonuses) do
                    bonus.isActive = (count >= bonus.numRequired)
                end
                setData.bonuses = bonuses
            end
        end

        table.insert(equipment.sets, setData)
    end

    -- ===== COMPUTED FIELDS =====

    -- Set Bonus Analysis
    local setCounts = {}
    for _, setData in ipairs(equipment.sets) do
        local setName = setData.name
        if setName then
            setCounts[setName] = setData.count or 0
        end
    end

    local activeSetBonuses = {}
    for setName, count in pairs(setCounts) do
        if count >= 2 then
            table.insert(activeSetBonuses, {
                name = setName,
                pieces = count,
                has2Piece = count >= 2,
                has3Piece = count >= 3,
                has4Piece = count >= 4,
                has5Piece = count >= 5,
            })
        end
    end

    equipment.setBonuses = activeSetBonuses

    -- Trait Distribution
    local traitCounts = {}
    for _, item in ipairs(equipment.items) do
        local traitName = item.trait or "None"
        traitCounts[traitName] = (traitCounts[traitName] or 0) + 1
    end
    equipment.traitDistribution = traitCounts

    -- Gear Score (rough calculation based on quality and level)
    local gearScore = 0
    local itemCount = 0
    for _, item in ipairs(equipment.items) do
        -- Use qualityNumeric (number) instead of quality (string/color)
        -- Ensure we have numeric values for calculations
        local qualityNum = 0
        if item.qualityNumeric ~= nil then
            if type(item.qualityNumeric) == "number" then
                qualityNum = item.qualityNumeric
            elseif type(item.qualityNumeric) == "string" then
                qualityNum = tonumber(item.qualityNumeric) or 0
            end
        end

        local levelValue = 0
        if item.requiredLevel ~= nil then
            if type(item.requiredLevel) == "number" then
                levelValue = item.requiredLevel
            elseif type(item.requiredLevel) == "string" then
                levelValue = tonumber(item.requiredLevel) or 0
            end
        end

        -- Calculate gear score if we have valid values
        if qualityNum >= 0 and levelValue >= 0 then
            -- Quality: 0-4 (white to gold), Level: 1-50
            local qualityMultiplier = qualityNum + 1 -- 1-5
            gearScore = gearScore + (qualityMultiplier * levelValue)
            itemCount = itemCount + 1
        end
    end
    equipment.gearScore = itemCount > 0 and math.floor(gearScore / itemCount) or 0

    return equipment
end

CM.collectors.CollectEquipmentData = CollectEquipmentData

CM.DebugPrint("COLLECTOR", "Equipment collector module loaded")
