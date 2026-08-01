-- Aldren's Grandmaster Workshop
-- Version 2.0.1
--
-- Grandmaster Journal chapters:
-- 1. Preserve the checklist cover and Journey page.
-- 2. Add one calm Journal chapter for each completed crafting profession.
-- 3. Reuse only verified systems that already exist in the workshop.
-- 4. Move forward and backward through chapters with the gamepad stick keybinds.

local AAW = AAW or {}
AAW.name = "AldrensGrandmasterWorkshop"
AAW.displayName = "Aldren's Grandmaster Workshop"
AAW.version = "2.0.1"
AAW.savedVersion = 1

-- Grand Master Crafter uses Recipe Compendium: learn 100 food or drink recipes.
-- Provisioning furnishing designs are useful knowledge, but they do not advance this achievement.
local AAW_RECIPE_COMPENDIUM_ACHIEVEMENT_ID = 1028
local AAW_RECIPE_COMPENDIUM_REQUIRED = 100
AAW.state = {
    hasLaboratoryUse = false,
    labConfidence = "not_checked",
    recipeIngredientCount = 2,
    loginLabChecked = false,
    latestRecipe = nil,
    latestFarmRecipe = nil,
    latestFoundItems = nil,
    latestRuneLesson = nil,
    latestEnchantingMissing = nil,
    provisioningKnownRecipes = 0,
    provisioningTotalRecipes = AAW_RECIPE_COMPENDIUM_REQUIRED,
    provisioningAchievementReady = false,
    provisioningKnownEntries = 0,
    provisioningKnownDesigns = 0,
    provisioningUnresolvedKnownEntries = 0,
    provisioningFoodDrinkRecipes = 0,
    provisioningUnknownFoodDrinkRecipes = 0,
    provisioningWorkshopPage = 1,
    recipeKnowledgeDirty = true,
    recipeKnowledgeRefreshQueued = false,
    isAtAlchemyStation = false,
    isAtEnchantingStation = false,
    isAtProvisioningStation = false,
    isAtJewelryStation = false,
    isAtBlacksmithingStation = false,
    isAtClothingStation = false,
    isAtWoodworkingStation = false,
    isBankOpen = false,
    bankRefreshQueued = false,
    jewelryKnownTraits = 0,
    jewelryTotalTraits = 0,
    jewelryActiveResearch = 0,
    backpackResearchScrolls = { jewelry = 0, blacksmithing = 0, clothing = 0, woodworking = 0 },
    isAtSupportedCraftingStation = false,
    currentStation = "none",
    craftRefreshQueued = false,
    refreshCount = 0,
    hasSeenAldrenIntro = false,
}

-- True Style Master is read from LibCharacterKnowledge's Lore Book records.
-- This cache is refreshed only when the library initializes or reports that
-- knowledge changed, keeping the Journal light on console.
local AAW_TRUE_STYLE_REQUIRED = 50
AAW.trueStyleKnowledge = {
    ready = false,
    known = 0,
    required = AAW_TRUE_STYLE_REQUIRED,
    styleCount = 0,
    closestReady = false,
    closestMotifs = {},
    refreshQueued = false,
    callbacksRegistered = false,
    lastError = "not_checked",
    closestError = "not_checked",
}

AAW.ui = {
    created = false,
    window = nil,
    title = nil,
    mode = nil,
    lab = nil,
    items = nil,
    instruction = nil,
    grandmaster = nil,
    instructionRight = nil,
}

AAW.provisioningUi = {
    keybindStripDescriptor = nil,
    keybindsVisible = false,
}

local AAW_ALDREN_BLUE = "|cB3E6FF"
local AAW_COLOR_END = "|r"

local function AAW_ColorizeVerifiedRecipeName(name, verifiedQuality)
    local safeName = tostring(name or "Unknown recipe")
    local quality = tonumber(verifiedQuality)

    if quality and type(GetItemQualityColor) == "function" then
        local okColor, color = pcall(GetItemQualityColor, quality)
        if okColor and color and type(color.Colorize) == "function" then
            local okText, coloredText = pcall(function()
                return color:Colorize(safeName)
            end)
            if okText and type(coloredText) == "string" and coloredText ~= "" then
                return coloredText
            end
        end
    end

    return safeName
end

-- Ingredient names used by learned food and drink recipes are stable until a
-- new recipe is learned. Cache this small catalogue instead of walking ESO's
-- sparse recipe-index slots.
AAW.provisioningIngredientKnowledge = {
    dirty = true,
    ready = false,
    catalog = {},
    usedIngredients = {},
}

-- Recipe Knowledge Library foundation. This is Aldren's private notebook, not a
-- player-facing database. The live ESO scan can verify known food and drink
-- recipes; a separate static archive will eventually provide verified unknowns.
AAW.recipeKnowledgeLibrary = {
    entries = {},
    unknown = {},
    easiest = {},
    watchedDesigns = {},
    total = 0,
    known = 0,
    liveFoodDrinkKnown = 0,
    knownProvisioningEntries = 0,
    knownDesigns = 0,
    unresolvedKnownEntries = 0,
    foodDrinkKnowledgeCount = 0,
    designKnowledgeCount = 0,
    achievementKnown = 0,
    achievementRequired = AAW_RECIPE_COMPENDIUM_REQUIRED,
    achievementReady = false,
    achievementComplete = false,
    unknownCount = 0,
    unknownDesignCount = 0,
    recipeIndexSlots = 0,
    completeArchiveReady = false,
    designArchiveReady = false,
    lastScanSucceeded = false,
    staticLookupsReady = false,
    foodDrinkLookup = {},
    designLookup = {},
    preparedArchiveRecords = {},
}

-- Shared Research Brain foundation. Each research profession has its own
-- compartment, so data can be reused without ever mixing professions.
local function AAW_NewResearchProfessionState()
    return {
        known = 0,
        total = 0,
        active = 0,
        projects = {},
        categories = {},
        longestRemaining = 0,
        slotLimit = nil,
        carriedScrolls = { total = 0, oneDay = 0, sevenDay = 0 },
        rememberedBankScrolls = { total = 0, oneDay = 0, sevenDay = 0 },
    }
end

AAW.researchBrain = {
    professions = {
        jewelry = AAW_NewResearchProfessionState(),
        blacksmithing = AAW_NewResearchProfessionState(),
        clothing = AAW_NewResearchProfessionState(),
        woodworking = AAW_NewResearchProfessionState(),
    },
}

local function AAW_ResetResearchProfession(profession)
    local fresh = AAW_NewResearchProfessionState()
    AAW.researchBrain.professions[profession] = fresh
    return fresh
end

local function AAW_GetResearchProfession(profession)
    if not AAW.researchBrain.professions[profession] then
        AAW.researchBrain.professions[profession] = AAW_NewResearchProfessionState()
    end
    return AAW.researchBrain.professions[profession]
end

local function AAW_Message(text)
    d(string.format("|c88CCFF%s v%s|r: %s", AAW.displayName, AAW.version, tostring(text)))
end

local function AAW_Value(value)
    if value == nil then return "nil" end
    return tostring(value)
end

local function AAW_CleanName(name)
    if not name then
        return ""
    end

    if zo_strformat then
        return zo_strformat("<<1>>", name)
    end

    return tostring(name)
end

local function AAW_GetPlayerName()
    local name = "friend"

    if type(GetUnitName) == "function" then
        local okName, unitName = pcall(GetUnitName, "player")
        if okName and unitName and unitName ~= "" then
            name = AAW_CleanName(unitName)
        end
    end

    if name == "" then
        name = "friend"
    end

    return name
end

local function AAW_Lower(text)
    text = text or ""

    if zo_strlower then
        return zo_strlower(text)
    end

    return string.lower(text)
end

local function AAW_Contains(text, needle)
    text = AAW_Lower(text or "")
    needle = AAW_Lower(needle or "")
    return string.find(text, needle, 1, true) ~= nil
end

local function AAW_BoolToYesNo(value)
    if value then return "YES" end
    return "NO"
end


-- Static knowledge archives now load from AldrensGrandmasterWorkshop_Data.lua.

local function AAW_GetRecipeModeText()
    return tostring(AAW.state.recipeIngredientCount or 2) .. " reagents + solvent"
end

local function AAW_SaveLaboratoryUse(hasLaboratoryUse, confidence)
    AAW.state.hasLaboratoryUse = hasLaboratoryUse == true
    AAW.state.labConfidence = confidence or "unknown"
    AAW.state.recipeIngredientCount = AAW.state.hasLaboratoryUse and 3 or 2

    if AAW.saved then
        AAW.saved.hasLaboratoryUse = AAW.state.hasLaboratoryUse
        AAW.saved.labConfidence = AAW.state.labConfidence
        AAW.saved.recipeIngredientCount = AAW.state.recipeIngredientCount
        AAW.saved.lastCheckedVersion = AAW.version
    end
end

local function AAW_LoadSavedLaboratoryUse()
    if not AAW.saved then
        return
    end

    if AAW.saved.recipeIngredientCount == 3 or AAW.saved.recipeIngredientCount == 2 then
        AAW.state.hasLaboratoryUse = AAW.saved.hasLaboratoryUse == true
        AAW.state.labConfidence = AAW.saved.labConfidence or "saved"
        AAW.state.recipeIngredientCount = AAW.saved.recipeIngredientCount
    end
end

local function AAW_IsAlchemyItemType(itemType)
    return itemType == ITEMTYPE_REAGENT
        or itemType == ITEMTYPE_POTION_BASE
        or itemType == ITEMTYPE_POISON_BASE
end

local function AAW_AddItem(foundItems, itemName, stackCount, itemType, bagName, bagId, slotIndex, itemId, itemLink)
    itemName = AAW_CleanName(itemName)

    if itemName == "" then
        return
    end

    local key = AAW_Lower(itemName)

    if not foundItems[key] then
        foundItems[key] = {
            name = itemName,
            count = 0,
            itemType = itemType,
            locations = {},
            bagId = bagId,
            slotIndex = slotIndex,
            itemId = itemId,
            itemLink = itemLink,
        }
    end

    foundItems[key].count = foundItems[key].count + (stackCount or 0)
    foundItems[key].locations[bagName] = true

    if itemLink and itemLink ~= "" then
        foundItems[key].itemLink = itemLink
    end

    -- Keep one usable bag/slot sample so we can ask the game which trait slots are already known.
    if foundItems[key].bagId == nil and bagId ~= nil then
        foundItems[key].bagId = bagId
        foundItems[key].slotIndex = slotIndex
    end
    if foundItems[key].itemId == nil and itemId ~= nil then
        foundItems[key].itemId = itemId
    end
end

local function AAW_ReadSlotData(foundItems, bagId, bagName)
    if not bagId then
        return
    end

    if SHARED_INVENTORY and SHARED_INVENTORY.GenerateFullSlotData then
        local okShared, slotDataList = pcall(function()
            return SHARED_INVENTORY:GenerateFullSlotData(nil, bagId)
        end)

        if okShared and slotDataList then
            for _, slotData in pairs(slotDataList) do
                local itemType = slotData.itemType

                if AAW_IsAlchemyItemType(itemType) then
                    local itemName = slotData.name
                    local stackCount = slotData.stackCount or 0

                    if (not itemName or itemName == "") and slotData.itemLink and slotData.itemLink ~= "" and GetItemLinkName then
                        itemName = GetItemLinkName(slotData.itemLink)
                    end

                    local sourceBagId = slotData.bagId or slotData.bag or bagId
                    local sourceSlotIndex = slotData.slotIndex or slotData.slot or slotData.index
                    local itemId = slotData.itemId
                    if itemId == nil and type(GetItemId) == "function" and sourceBagId ~= nil and sourceSlotIndex ~= nil then
                        local okItemId, readItemId = pcall(GetItemId, sourceBagId, sourceSlotIndex)
                        if okItemId then
                            itemId = readItemId
                        end
                    end

                    AAW_AddItem(foundItems, itemName, stackCount, itemType, bagName, sourceBagId, sourceSlotIndex, itemId)
                end
            end

            return
        end
    end

    if type(GetBagSize) ~= "function" or type(GetItemType) ~= "function" then
        return
    end

    local bagSize = GetBagSize(bagId) or 0

    for slotIndex = 0, bagSize do
        local itemType = GetItemType(bagId, slotIndex)

        if AAW_IsAlchemyItemType(itemType) then
            local itemName = ""
            local stackCount = 0

            if type(GetItemName) == "function" then
                itemName = GetItemName(bagId, slotIndex)
            end

            if type(GetSlotStackSize) == "function" then
                stackCount = GetSlotStackSize(bagId, slotIndex)
            end

            local itemId = nil
            if type(GetItemId) == "function" then
                local okItemId, readItemId = pcall(GetItemId, bagId, slotIndex)
                if okItemId then
                    itemId = readItemId
                end
            end

            AAW_AddItem(foundItems, itemName, stackCount, itemType, bagName, bagId, slotIndex, itemId)
        end
    end
end

function AAW.ScanAlchemyItems(showMessages)
    local foundItems = {}

    AAW_ReadSlotData(foundItems, BAG_BACKPACK, "Backpack")

    if BAG_VIRTUAL then
        AAW_ReadSlotData(foundItems, BAG_VIRTUAL, "Craft Bag")
    end

    local reagentCount = 0
    local solventCount = 0
    local totalStacks = 0

    for _, item in pairs(foundItems) do
        totalStacks = totalStacks + 1

        if item.itemType == ITEMTYPE_REAGENT then
            reagentCount = reagentCount + 1
        elseif item.itemType == ITEMTYPE_POTION_BASE or item.itemType == ITEMTYPE_POISON_BASE then
            solventCount = solventCount + 1
        end
    end

    if showMessages then
        AAW_Message("ITEM TEST 1: Alchemy scan complete.")
        AAW_Message("ITEM TEST 2: Unique alchemy items found: " .. tostring(totalStacks))
        AAW_Message("ITEM TEST 3: Reagent types found: " .. tostring(reagentCount))
        AAW_Message("ITEM TEST 4: Solvent types found: " .. tostring(solventCount))
    end

    return foundItems, totalStacks, reagentCount, solventCount
end

local function AAW_IsEnchantingItemType(itemType)
    return (ITEMTYPE_ENCHANTING_RUNE_ASPECT ~= nil and itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT)
        or (ITEMTYPE_ENCHANTING_RUNE_ESSENCE ~= nil and itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE)
        or (ITEMTYPE_ENCHANTING_RUNE_POTENCY ~= nil and itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY)
end

local function AAW_GetRuneCategory(itemType)
    if ITEMTYPE_ENCHANTING_RUNE_POTENCY ~= nil and itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY then
        return "potency"
    elseif ITEMTYPE_ENCHANTING_RUNE_ESSENCE ~= nil and itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE then
        return "essence"
    elseif ITEMTYPE_ENCHANTING_RUNE_ASPECT ~= nil and itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT then
        return "aspect"
    end

    return "unknown"
end

local function AAW_ReadEnchantingSlotData(foundItems, bagId, bagName)
    if not bagId then
        return
    end

    if SHARED_INVENTORY and SHARED_INVENTORY.GenerateFullSlotData then
        local okShared, slotDataList = pcall(function()
            return SHARED_INVENTORY:GenerateFullSlotData(nil, bagId)
        end)

        if okShared and slotDataList then
            for _, slotData in pairs(slotDataList) do
                local itemType = slotData.itemType

                if AAW_IsEnchantingItemType(itemType) then
                    local itemName = slotData.name
                    local stackCount = slotData.stackCount or 0

                    if (not itemName or itemName == "") and slotData.itemLink and slotData.itemLink ~= "" and GetItemLinkName then
                        itemName = GetItemLinkName(slotData.itemLink)
                    end

                    AAW_AddItem(foundItems, itemName, stackCount, itemType, bagName, slotData.bagId or slotData.bag or bagId, slotData.slotIndex or slotData.slot or slotData.index, slotData.itemId, slotData.itemLink)
                end
            end

            return
        end
    end

    if type(GetBagSize) ~= "function" or type(GetItemType) ~= "function" then
        return
    end

    local bagSize = GetBagSize(bagId) or 0

    for slotIndex = 0, bagSize do
        local itemType = GetItemType(bagId, slotIndex)

        if AAW_IsEnchantingItemType(itemType) then
            local itemName = ""
            local stackCount = 0

            if type(GetItemName) == "function" then
                itemName = GetItemName(bagId, slotIndex)
            end

            if type(GetSlotStackSize) == "function" then
                stackCount = GetSlotStackSize(bagId, slotIndex)
            end

            AAW_AddItem(foundItems, itemName, stackCount, itemType, bagName, bagId, slotIndex, nil)
        end
    end
end

function AAW.ScanEnchantingItems(showMessages)
    local foundItems = {}

    AAW_ReadEnchantingSlotData(foundItems, BAG_BACKPACK, "Backpack")

    if BAG_VIRTUAL then
        AAW_ReadEnchantingSlotData(foundItems, BAG_VIRTUAL, "Craft Bag")
    end

    local potencyCount = 0
    local essenceCount = 0
    local aspectCount = 0
    local totalStacks = 0

    for _, item in pairs(foundItems) do
        totalStacks = totalStacks + 1
        local category = AAW_GetRuneCategory(item.itemType)

        if category == "potency" then
            potencyCount = potencyCount + 1
        elseif category == "essence" then
            essenceCount = essenceCount + 1
        elseif category == "aspect" then
            aspectCount = aspectCount + 1
        end
    end

    if showMessages then
        AAW_Message("ENCHANTING TEST 1: rune scan complete.")
        AAW_Message("ENCHANTING TEST 2: unique rune items found: " .. tostring(totalStacks))
        AAW_Message("ENCHANTING TEST 3: potency runes found: " .. tostring(potencyCount))
        AAW_Message("ENCHANTING TEST 4: essence runes found: " .. tostring(essenceCount))
        AAW_Message("ENCHANTING TEST 5: aspect runes found: " .. tostring(aspectCount))
    end

    return foundItems, totalStacks, potencyCount, essenceCount, aspectCount
end


local function AAW_ReadLabAbility(skillType, skillLineIndex)
    if type(GetSkillAbilityInfo) ~= "function" then
        return false, "unknown"
    end

    local abilityCount = 15
    if type(GetNumSkillAbilities) == "function" then
        local okCount, count = pcall(GetNumSkillAbilities, skillType, skillLineIndex)
        if okCount and tonumber(count) and tonumber(count) > 0 then
            abilityCount = tonumber(count)
        end
    end

    for abilityIndex = 1, abilityCount do
        local okAbility, abilityName, texture, earnedRank, passive, ultimate, purchased = pcall(GetSkillAbilityInfo, skillType, skillLineIndex, abilityIndex)

        if okAbility then
            abilityName = AAW_CleanName(abilityName)

            if abilityName ~= "" and AAW_Contains(abilityName, "Laboratory") then
                local currentUpgradeLevel = 0

                if type(GetSkillAbilityUpgradeInfo) == "function" then
                    local okUpgrade, currentUpgrade = pcall(GetSkillAbilityUpgradeInfo, skillType, skillLineIndex, abilityIndex)

                    if okUpgrade then
                        currentUpgradeLevel = tonumber(currentUpgrade) or 0
                    end
                end

                if purchased == true or currentUpgradeLevel > 0 then
                    return true, "known"
                end

                return false, "known"
            end
        end
    end

    return nil, "not_found_on_line"
end

local function AAW_SearchTradeSkillAbilitiesForLaboratoryUse()
    local skillType = SKILL_TYPE_TRADESKILL or 8

    if type(GetNumSkillLines) ~= "function" then
        return false, "unknown"
    end

    if type(GetSkillAbilityInfo) ~= "function" then
        return false, "unknown"
    end

    local okLines, numLines = pcall(GetNumSkillLines, skillType)
    if not okLines or not tonumber(numLines) or tonumber(numLines) <= 0 then
        return false, "unknown"
    end

    numLines = tonumber(numLines)

    for skillLineIndex = 1, numLines do
        local abilityCount = 15

        if type(GetNumSkillAbilities) == "function" then
            local okCount, count = pcall(GetNumSkillAbilities, skillType, skillLineIndex)
            if okCount and tonumber(count) and tonumber(count) > 0 then
                abilityCount = tonumber(count)
            end
        end

        for abilityIndex = 1, abilityCount do
            local okAbility, abilityName = pcall(GetSkillAbilityInfo, skillType, skillLineIndex, abilityIndex)

            if okAbility then
                abilityName = AAW_CleanName(abilityName)

                if abilityName ~= "" and AAW_Contains(abilityName, "Laboratory") then
                    return AAW_ReadLabAbility(skillType, skillLineIndex)
                end
            end
        end
    end

    return false, "unknown"
end

local function AAW_CheckLaboratoryUseUnsafe()
    return AAW_SearchTradeSkillAbilitiesForLaboratoryUse()
end

function AAW.RefreshLaboratoryUse(showMessages, reason)
    local ok, hasLaboratoryUse, confidence = pcall(AAW_CheckLaboratoryUseUnsafe)

    if not ok then
        hasLaboratoryUse = false
        confidence = "unknown"
    end

    AAW_SaveLaboratoryUse(hasLaboratoryUse, confidence)
    AAW.state.loginLabChecked = true

    if showMessages then
        AAW_Message("LAB CHECK: reason=" .. tostring(reason or "manual") .. ".")
        AAW_Message("LAB RESULT: Laboratory Use " .. AAW_BoolToYesNo(AAW.state.hasLaboratoryUse) .. ". Recipe mode is " .. AAW_GetRecipeModeText() .. ".")
    end

    return AAW.state.hasLaboratoryUse, AAW.state.labConfidence
end

local function AAW_IsAlchemyCraftingType(craftingType)
    local alchemyType = CRAFTING_TYPE_ALCHEMY or 4
    return craftingType == alchemyType
end

local function AAW_IsEnchantingCraftingType(craftingType)
    local enchantingType = CRAFTING_TYPE_ENCHANTING or 3
    return craftingType == enchantingType
end

local function AAW_IsProvisioningCraftingType(craftingType)
    local provisioningType = CRAFTING_TYPE_PROVISIONING or 5
    return craftingType == provisioningType
end

local function AAW_IsJewelryCraftingType(craftingType)
    local jewelryType = CRAFTING_TYPE_JEWELRYCRAFTING or 7
    return craftingType == jewelryType
end

local function AAW_IsBlacksmithingCraftingType(craftingType)
    return craftingType == (CRAFTING_TYPE_BLACKSMITHING or 1)
end

local function AAW_IsClothingCraftingType(craftingType)
    return craftingType == (CRAFTING_TYPE_CLOTHIER or 2)
end

local function AAW_IsWoodworkingCraftingType(craftingType)
    return craftingType == (CRAFTING_TYPE_WOODWORKING or 6)
end

local function AAW_IsSupportedCraftingType(craftingType)
    return AAW_IsAlchemyCraftingType(craftingType)
        or AAW_IsEnchantingCraftingType(craftingType)
        or AAW_IsProvisioningCraftingType(craftingType)
        or AAW_IsJewelryCraftingType(craftingType)
        or AAW_IsBlacksmithingCraftingType(craftingType)
        or AAW_IsClothingCraftingType(craftingType)
        or AAW_IsWoodworkingCraftingType(craftingType)
end


local function AAW_GetKnownTraitFlags(item)
    local flags = {}

    if type(IsAlchemyItemTraitKnown) ~= "function" or item == nil or item.bagId == nil or item.slotIndex == nil then
        return flags, "unavailable"
    end

    for traitIndex = 1, 4 do
        local okKnown, known = pcall(IsAlchemyItemTraitKnown, item.bagId, item.slotIndex, traitIndex)
        flags[traitIndex] = okKnown and known == true
    end

    return flags, "known"
end

local function AAW_TitleCaseReagentName(key)
    key = tostring(key or "")
    local result = string.gsub(key, "(%a)([%w']*)", function(first, rest)
        return string.upper(first) .. tostring(rest or "")
    end)
    return result
end

local function AAW_EnsureKnownTraitsTable()
    if not AAW.saved then
        return nil
    end

    if type(AAW.saved.knownTraitsByReagent) ~= "table" then
        AAW.saved.knownTraitsByReagent = {}
    end

    return AAW.saved.knownTraitsByReagent
end

local function AAW_SaveKnownTraitFlags(reagentKey, flags)
    if not reagentKey or not flags then
        return
    end

    local knownTraitsByReagent = AAW_EnsureKnownTraitsTable()
    if not knownTraitsByReagent then
        return
    end

    knownTraitsByReagent[reagentKey] = knownTraitsByReagent[reagentKey] or {}

    for traitIndex = 1, 4 do
        knownTraitsByReagent[reagentKey][traitIndex] = flags[traitIndex] == true
    end
end

local function AAW_GetSavedKnownTraitFlags(reagentKey)
    local flags = {}

    if AAW.saved and type(AAW.saved.knownTraitsByReagent) == "table" and type(AAW.saved.knownTraitsByReagent[reagentKey]) == "table" then
        for traitIndex = 1, 4 do
            flags[traitIndex] = AAW.saved.knownTraitsByReagent[reagentKey][traitIndex] == true
        end
    end

    return flags
end

local function AAW_GetReagentNamesLine(reagents, includeCounts)
    local names = {}

    for _, reagent in ipairs(reagents or {}) do
        local name = tostring(reagent.name or "?")
        if includeCounts then
            name = name .. " x" .. tostring(reagent.count or 0)
        end
        table.insert(names, name)
    end

    if #names == 0 then
        return "none"
    end

    return table.concat(names, ", ")
end

local function AAW_BuildRecipeReagentList(foundItems)
    local reagents = {}

    for key, item in pairs(foundItems or {}) do
        if item.itemType == ITEMTYPE_REAGENT and AAW.reagentTraits[key] and (item.count or 0) > 0 then
            local knownTraits, knownStatus = AAW_GetKnownTraitFlags(item)

            -- Remember known trait slots for this character.
            -- This helps Farm Next make better guesses when that reagent is missing later.
            if knownStatus == "known" then
                AAW_SaveKnownTraitFlags(key, knownTraits)
            else
                local savedFlags = AAW_GetSavedKnownTraitFlags(key)
                for traitIndex = 1, 4 do
                    if savedFlags[traitIndex] == true then
                        knownTraits[traitIndex] = true
                    end
                end
            end

            table.insert(reagents, {
                key = key,
                name = item.name,
                count = item.count or 0,
                traits = AAW.reagentTraits[key],
                knownTraits = knownTraits,
                knownStatus = knownStatus,
            })
        end
    end

    table.sort(reagents, function(a, b)
        return tostring(a.name) < tostring(b.name)
    end)

    return reagents
end

local function AAW_BuildFarmRecipeReagentList(foundItems)
    local reagents = {}

    for key, traits in pairs(AAW.reagentTraits or {}) do
        local ownedItem = foundItems and foundItems[key]
        local count = 0
        local name = AAW_TitleCaseReagentName(key)
        local knownTraits = AAW_GetSavedKnownTraitFlags(key)
        local knownStatus = "saved_or_unknown"

        if ownedItem and ownedItem.itemType == ITEMTYPE_REAGENT then
            count = ownedItem.count or 0
            name = ownedItem.name or name

            local flags, status = AAW_GetKnownTraitFlags(ownedItem)
            if status == "known" then
                knownTraits = flags
                knownStatus = status
                AAW_SaveKnownTraitFlags(key, flags)
            end
        end

        table.insert(reagents, {
            key = key,
            name = name,
            count = count,
            traits = traits,
            knownTraits = knownTraits,
            knownStatus = knownStatus,
        })
    end

    table.sort(reagents, function(a, b)
        return tostring(a.name) < tostring(b.name)
    end)

    return reagents
end

local function AAW_PickBestSolvent(foundItems)
    local best = nil

    for _, item in pairs(foundItems or {}) do
        if (item.itemType == ITEMTYPE_POTION_BASE or item.itemType == ITEMTYPE_POISON_BASE) and (item.count or 0) > 0 then
            if best == nil or (item.count or 0) > (best.count or 0) then
                best = item
            end
        end
    end

    return best
end

local function AAW_JoinNames(values, maxValues)
    local parts = {}
    maxValues = maxValues or 3

    for i, value in ipairs(values or {}) do
        if i > maxValues then
            break
        end
        table.insert(parts, tostring(value))
    end

    if #parts == 0 then
        return "none"
    end

    return table.concat(parts, ", ")
end


local function AAW_EvaluateRecipe(combo)
    local traitCounts = {}

    for _, reagent in ipairs(combo) do
        for _, traitName in ipairs(reagent.traits or {}) do
            traitCounts[traitName] = (traitCounts[traitName] or 0) + 1
        end
    end

    local effects = {}
    local learns = {}
    local score = 0

    for traitName, count in pairs(traitCounts) do
        local cancelName = AAW.traitCancels[traitName]
        local cancelCount = cancelName and traitCounts[cancelName] or 0

        if count >= 2 and (cancelCount or 0) == 0 then
            table.insert(effects, traitName)

            for _, reagent in ipairs(combo) do
                for traitIndex, reagentTraitName in ipairs(reagent.traits or {}) do
                    if reagentTraitName == traitName then
                        local isKnown = reagent.knownTraits and reagent.knownTraits[traitIndex] == true
                        if not isKnown then
                            score = score + 1
                            table.insert(learns, reagent.name .. ": " .. traitName)
                        end
                    end
                end
            end
        end
    end

    table.sort(effects)
    table.sort(learns)

    local minCount = 999999
    local totalCount = 0
    for _, reagent in ipairs(combo) do
        minCount = math.min(minCount, reagent.count or 0)
        totalCount = totalCount + (reagent.count or 0)
    end

    return {
        reagents = combo,
        effects = effects,
        learns = learns,
        score = score,
        effectCount = #effects,
        minCount = minCount,
        totalCount = totalCount,
    }
end

local function AAW_IsBetterRecipe(candidate, currentBest)
    if candidate == nil then
        return false
    end
    if currentBest == nil then
        return true
    end
    if candidate.score ~= currentBest.score then
        return candidate.score > currentBest.score
    end
    if candidate.effectCount ~= currentBest.effectCount then
        return candidate.effectCount > currentBest.effectCount
    end
    if candidate.minCount ~= currentBest.minCount then
        return candidate.minCount > currentBest.minCount
    end
    return candidate.totalCount > currentBest.totalCount
end


local function AAW_AttachMissingIngredients(candidate)
    local missing = {}
    local missingCount = 0
    local ownedCount = 0

    for _, reagent in ipairs(candidate.reagents or {}) do
        if (reagent.count or 0) <= 0 then
            table.insert(missing, reagent.name)
            missingCount = missingCount + 1
        else
            ownedCount = ownedCount + 1
        end
    end

    candidate.missing = missing
    candidate.missingCount = missingCount
    candidate.ownedCount = ownedCount
    return candidate
end

local function AAW_IsBetterFarmRecipe(candidate, currentBest)
    if candidate == nil then
        return false
    end
    if currentBest == nil then
        return true
    end
    if candidate.score ~= currentBest.score then
        return candidate.score > currentBest.score
    end
    if candidate.effectCount ~= currentBest.effectCount then
        return candidate.effectCount > currentBest.effectCount
    end
    if candidate.missingCount ~= currentBest.missingCount then
        return candidate.missingCount < currentBest.missingCount
    end
    if candidate.ownedCount ~= currentBest.ownedCount then
        return candidate.ownedCount > currentBest.ownedCount
    end
    return candidate.totalCount > currentBest.totalCount
end

function AAW.FindBestLearningRecipe(foundItems)
    local reagents = AAW_BuildRecipeReagentList(foundItems)
    local solvent = AAW_PickBestSolvent(foundItems)
    local targetCount = AAW.state.recipeIngredientCount or 2
    local best = nil

    if #reagents < 2 then
        return {
            status = "not_enough_reagents",
            reagentCount = #reagents,
            solvent = solvent,
        }
    end

    if solvent == nil then
        return {
            status = "no_solvent",
            reagentCount = #reagents,
            solvent = nil,
        }
    end

    if targetCount >= 3 and #reagents >= 3 then
        for i = 1, #reagents - 2 do
            for j = i + 1, #reagents - 1 do
                for k = j + 1, #reagents do
                    local candidate = AAW_EvaluateRecipe({ reagents[i], reagents[j], reagents[k] })
                    if candidate.score > 0 and candidate.effectCount > 0 and AAW_IsBetterRecipe(candidate, best) then
                        best = candidate
                    end
                end
            end
        end
    else
        for i = 1, #reagents - 1 do
            for j = i + 1, #reagents do
                local candidate = AAW_EvaluateRecipe({ reagents[i], reagents[j] })
                if candidate.score > 0 and candidate.effectCount > 0 and AAW_IsBetterRecipe(candidate, best) then
                    best = candidate
                end
            end
        end
    end

    if best == nil then
        return {
            status = "no_unknown_combo",
            reagentCount = #reagents,
            solvent = solvent,
        }
    end

    best.status = "ok"
    best.solvent = solvent
    best.reagentCount = #reagents
    return best
end


function AAW.FindBestFarmTargetRecipe(foundItems)
    local reagents = AAW_BuildFarmRecipeReagentList(foundItems)
    local solvent = AAW_PickBestSolvent(foundItems)
    local targetCount = AAW.state.recipeIngredientCount or 2
    local best = nil

    if targetCount >= 3 and #reagents >= 3 then
        for i = 1, #reagents - 2 do
            for j = i + 1, #reagents - 1 do
                for k = j + 1, #reagents do
                    local candidate = AAW_EvaluateRecipe({ reagents[i], reagents[j], reagents[k] })
                    AAW_AttachMissingIngredients(candidate)
                    if candidate.score > 0 and candidate.effectCount > 0 and (candidate.missingCount or 0) > 0 and AAW_IsBetterFarmRecipe(candidate, best) then
                        best = candidate
                    end
                end
            end
        end
    else
        for i = 1, #reagents - 1 do
            for j = i + 1, #reagents do
                local candidate = AAW_EvaluateRecipe({ reagents[i], reagents[j] })
                AAW_AttachMissingIngredients(candidate)
                if candidate.score > 0 and candidate.effectCount > 0 and (candidate.missingCount or 0) > 0 and AAW_IsBetterFarmRecipe(candidate, best) then
                    best = candidate
                end
            end
        end
    end

    if best == nil then
        return {
            status = "no_farm_target",
            solvent = solvent,
        }
    end

    best.status = "ok"
    best.solvent = solvent
    return best
end


local function AAW_CountUnknownSavedTraits(reagentKey)
    local flags = AAW_GetSavedKnownTraitFlags(reagentKey)
    local unknown = 0

    for traitIndex = 1, 4 do
        if flags[traitIndex] ~= true then
            unknown = unknown + 1
        end
    end

    return unknown
end


local function AAW_AreAllKnownTraitLessonsComplete()
    -- Aldren can only be certain when this character's saved notes show
    -- all four trait slots learned for every reagent in the archive.
    -- If even one reagent is unknown or missing from the notes, we keep offering gathering help.
    local knownTraitsByReagent = AAW.saved and AAW.saved.knownTraitsByReagent
    if type(knownTraitsByReagent) ~= "table" then
        return false
    end

    for reagentKey, traits in pairs(AAW.reagentTraits or {}) do
        local flags = knownTraitsByReagent[reagentKey]
        if type(flags) ~= "table" then
            return false
        end

        for traitIndex = 1, 4 do
            if flags[traitIndex] ~= true then
                return false
            end
        end
    end

    return true
end


local function AAW_GetAlchemyLessonProgress()
    local known = 0
    local total = 0
    local knownTraitsByReagent = AAW.saved and AAW.saved.knownTraitsByReagent

    for reagentKey, traits in pairs(AAW.reagentTraits or {}) do
        for traitIndex = 1, 4 do
            total = total + 1

            local flags = type(knownTraitsByReagent) == "table" and knownTraitsByReagent[reagentKey] or nil
            if type(flags) == "table" and flags[traitIndex] == true then
                known = known + 1
            end
        end
    end

    return known, total
end

local function AAW_FormatAlchemyGrandmasterNote()
    local known, total = AAW_GetAlchemyLessonProgress()

    if total > 0 and known >= total then
        return "Grandmaster note:\nAlchemy complete."
    end

    return "Grandmaster note:\nAlchemy lessons: " .. tostring(known) .. "/" .. tostring(total) .. " traits learned."
end


local function AAW_GetSavedRuneTranslations()
    if AAW.saved then
        AAW.saved.knownRunesByName = AAW.saved.knownRunesByName or {}
        return AAW.saved.knownRunesByName
    end

    return {}
end

local function AAW_IsRuneKnownFromSaved(runeKey)
    local knownRunes = AAW_GetSavedRuneTranslations()
    return knownRunes[AAW_Lower(runeKey or "")] == true
end

local function AAW_ReadBooleanFromResults(...)
    local count = select("#", ...)
    for i = 1, count do
        local value = select(i, ...)
        if type(value) == "boolean" then
            return value
        end
    end

    return nil
end

local function AAW_TryAskGameIfRuneKnown(item)
    if not item then
        return nil
    end

    -- Different ESO API surfaces expose rune translation knowledge in different ways.
    -- Console has already shown us that some PC-style helpers are missing, so this
    -- function tries several safe shapes and uses the first clear boolean answer.
    local itemLink = item.itemLink
    local bagId = item.bagId
    local slotIndex = item.slotIndex

    local linkFunctions = {
        "IsItemLinkEnchantingRuneKnown",
        "IsItemLinkRuneKnown",
        "IsItemLinkRuneTranslationKnown",
        "IsItemLinkEnchantingRuneTranslationKnown",
        "GetItemLinkEnchantingRuneKnown",
        "GetItemLinkRuneKnown",
        "GetItemLinkRuneTranslationKnown",
        "GetItemLinkEnchantingRuneTranslationKnown",
        "GetItemLinkRuneInfo",
        "GetItemLinkEnchantingRuneInfo",
    }

    if itemLink and itemLink ~= "" then
        for _, functionName in ipairs(linkFunctions) do
            local fn = _G and _G[functionName]
            if type(fn) == "function" then
                local ok, a, b, c, d, e, f = pcall(fn, itemLink)
                if ok then
                    local result = AAW_ReadBooleanFromResults(a, b, c, d, e, f)
                    if result ~= nil then
                        return result
                    end
                end
            end
        end
    end

    local slotFunctions = {
        "IsEnchantingRuneKnown",
        "IsRuneKnown",
        "IsEnchantingRuneTranslationKnown",
        "IsRuneTranslationKnown",
        "GetEnchantingRuneKnown",
        "GetRuneKnown",
        "GetEnchantingRuneTranslationKnown",
        "GetRuneTranslationKnown",
        "GetEnchantingRuneInfo",
        "GetRuneInfo",
    }

    if bagId ~= nil and slotIndex ~= nil then
        for _, functionName in ipairs(slotFunctions) do
            local fn = _G and _G[functionName]
            if type(fn) == "function" then
                local ok, a, b, c, d, e, f = pcall(fn, bagId, slotIndex)
                if ok then
                    local result = AAW_ReadBooleanFromResults(a, b, c, d, e, f)
                    if result ~= nil then
                        return result
                    end
                end
            end
        end
    end

    return nil
end

local function AAW_IsRuneKnown(item)
    if not item then
        return false
    end

    local runeKey = AAW_Lower(item.name or "")

    -- A translated rune can never become untranslated. Once Aldren has directly
    -- observed a completed lesson, his saved note is authoritative. Some console
    -- API shapes return an unrelated false boolean while describing a rune; that
    -- uncertain answer must not erase or temporarily hide permanent knowledge.
    if AAW_IsRuneKnownFromSaved(runeKey) then
        return true
    end

    local knownFromGame = AAW_TryAskGameIfRuneKnown(item)
    if knownFromGame == true then
        local knownRunes = AAW_GetSavedRuneTranslations()
        knownRunes[runeKey] = true
        return true
    end

    return false
end

local AAW_GetRuneMeta

local function AAW_CollectRunesForKnownProbe(foundItems, category)
    local list = {}

    for key, item in pairs(foundItems or {}) do
        local meta = AAW_GetRuneMeta(item)
        if meta and meta.category == category and tonumber(item.count or 0) > 0 and item.bagId ~= nil and item.slotIndex ~= nil then
            table.insert(list, {
                key = key,
                name = item.name,
                bagId = item.bagId,
                slotIndex = item.slotIndex,
                rare = meta.rare == true,
                rank = meta.rank or 50,
            })
        end
    end

    table.sort(list, function(a, b)
        if a.rare ~= b.rare then
            return a.rare == false
        end
        if a.rank ~= b.rank then
            return a.rank < b.rank
        end
        return tostring(a.name) < tostring(b.name)
    end)

    return list
end

local function AAW_TryMarkKnownRuneTriple(potency, essence, aspect)
    if type(AreAllEnchantingRunesKnown) ~= "function" then
        return 0, "missing_function"
    end

    if not potency or not essence or not aspect then
        return 0, "missing_rune"
    end

    local ok, allKnown = pcall(AreAllEnchantingRunesKnown,
        potency.bagId, potency.slotIndex,
        essence.bagId, essence.slotIndex,
        aspect.bagId, aspect.slotIndex)

    if not ok then
        return 0, "call_failed"
    end

    if allKnown == true then
        local marked = 0
        local knownRunes = AAW_GetSavedRuneTranslations()
        for _, rune in ipairs({ potency, essence, aspect }) do
            local runeKey = AAW_Lower(rune.key or rune.name or "")
            if runeKey ~= "" and knownRunes[runeKey] ~= true then
                knownRunes[runeKey] = true
                marked = marked + 1
            end
        end
        return marked, "known_combo"
    end

    return 0, "not_all_known"
end

local function AAW_TryInferKnownRuneTranslationsFromCombos(foundItems)
    -- ESO's shared enchanting UI uses AreAllEnchantingRunesKnown for a full
    -- potency/essence/aspect set. Console may not expose a clean single-rune
    -- function, so we use any all-known combination we can see to mark those
    -- three runes as translated in Aldren's per-character notes.
    if type(AreAllEnchantingRunesKnown) ~= "function" then
        return 0, 0, "missing_function"
    end

    local potencyRunes = AAW_CollectRunesForKnownProbe(foundItems, "potency")
    local essenceRunes = AAW_CollectRunesForKnownProbe(foundItems, "essence")
    local aspectRunes = AAW_CollectRunesForKnownProbe(foundItems, "aspect")

    if #potencyRunes == 0 or #essenceRunes == 0 or #aspectRunes == 0 then
        return 0, 0, "missing_category"
    end

    local markedTotal = 0
    local tested = 0
    local maxTests = 5000

    for _, potency in ipairs(potencyRunes) do
        for _, essence in ipairs(essenceRunes) do
            for _, aspect in ipairs(aspectRunes) do
                local marked = AAW_TryMarkKnownRuneTriple(potency, essence, aspect)
                markedTotal = markedTotal + (tonumber(marked) or 0)
                tested = tested + 1
                if tested >= maxTests then
                    return markedTotal, tested, "capped"
                end
            end
        end
    end

    return markedTotal, tested, "done"
end

local function AAW_RefreshKnownRuneTranslationsFromFoundItems(foundItems)
    -- Quietly ask the game about every rune we can currently see.
    -- This keeps the Grandmaster note based on the character's real rune knowledge
    -- whenever the rune is in the backpack or crafting bag.
    for _, item in pairs(foundItems or {}) do
        AAW_IsRuneKnown(item)
    end

    AAW_TryInferKnownRuneTranslationsFromCombos(foundItems)
end

local function AAW_MarkRuneKnown(runeKey)
    runeKey = AAW_Lower(runeKey or "")
    if runeKey == "" then
        return
    end

    local knownRunes = AAW_GetSavedRuneTranslations()
    knownRunes[runeKey] = true
end

local function AAW_MarkLatestRuneLessonKnown()
    local lesson = AAW.state.latestRuneLesson
    if not lesson or lesson.status ~= "ok" then
        return
    end

    for _, item in ipairs({ lesson.potency, lesson.essence, lesson.aspect }) do
        if item and item.key then
            AAW_MarkRuneKnown(item.key)
        end
    end
end

AAW_GetRuneMeta = function(item)
    if not item then
        return nil
    end

    local key = AAW_Lower(item.name or "")
    local meta = AAW.runeTranslations and AAW.runeTranslations[key]

    if meta then
        return meta
    end

    local category = AAW_GetRuneCategory(item.itemType)
    if category ~= "unknown" then
        return { category = category, meaning = "unknown", rank = 50 }
    end

    return nil
end

local function AAW_BuildRuneListByCategory(foundItems, category)
    local list = {}

    for key, item in pairs(foundItems or {}) do
        local meta = AAW_GetRuneMeta(item)
        if meta and meta.category == category and tonumber(item.count or 0) > 0 then
            table.insert(list, {
                key = key,
                name = item.name,
                count = item.count or 0,
                itemType = item.itemType,
                itemLink = item.itemLink,
                category = category,
                meaning = meta.meaning or "unknown",
                rank = meta.rank or 50,
                rare = meta.rare == true,
                known = AAW_IsRuneKnown(item),
            })
        end
    end

    table.sort(list, function(a, b)
        if a.known ~= b.known then
            return a.known == false
        end
        if a.rare ~= b.rare then
            return a.rare == false
        end
        if a.rank ~= b.rank then
            return a.rank < b.rank
        end
        return tostring(a.name) < tostring(b.name)
    end)

    return list
end

local function AAW_PickRuneForLesson(list)
    if not list or #list == 0 then
        return nil
    end

    -- First choice: an unknown rune that is not marked rare.
    for _, item in ipairs(list) do
        if not item.known and not item.rare then
            return item
        end
    end

    -- Second choice: any unknown rune.
    for _, item in ipairs(list) do
        if not item.known then
            return item
        end
    end

    -- Filler: a known, common rune.
    for _, item in ipairs(list) do
        if not item.rare then
            return item
        end
    end

    return list[1]
end

function AAW.FindBestEnchantingRuneLesson(foundItems)
    local potencyRunes = AAW_BuildRuneListByCategory(foundItems, "potency")
    local essenceRunes = AAW_BuildRuneListByCategory(foundItems, "essence")
    local aspectRunes = AAW_BuildRuneListByCategory(foundItems, "aspect")

    local missing = {}
    if #potencyRunes == 0 then table.insert(missing, "potency rune") end
    if #essenceRunes == 0 then table.insert(missing, "essence rune") end
    if #aspectRunes == 0 then table.insert(missing, "aspect rune") end

    if #missing > 0 then
        return {
            status = "missing_runes",
            missing = missing,
            learnCount = 0,
        }
    end

    local potency = AAW_PickRuneForLesson(potencyRunes)
    local essence = AAW_PickRuneForLesson(essenceRunes)
    local aspect = AAW_PickRuneForLesson(aspectRunes)
    local learnCount = 0

    for _, item in ipairs({ potency, essence, aspect }) do
        if item and not item.known then
            learnCount = learnCount + 1
        end
    end

    if learnCount <= 0 then
        return {
            status = "complete_or_saved",
            potency = potency,
            essence = essence,
            aspect = aspect,
            learnCount = 0,
        }
    end

    return {
        status = "ok",
        potency = potency,
        essence = essence,
        aspect = aspect,
        learnCount = learnCount,
    }
end

local function AAW_GetEnchantingProgressBreakdown()
    local progress = {
        allKnown = 0,
        allTotal = 0,
        potencyTotal = 0,
        essenceTotal = 0,
        aspectTotal = 0,
        positiveKnown = 0,
        positiveTotal = 0,
        negativeKnown = 0,
        negativeTotal = 0,
    }
    local knownRunes = AAW_GetSavedRuneTranslations()

    for runeKey, meta in pairs(AAW.runeTranslations or {}) do
        if meta and meta.category then
            local isKnown = knownRunes[runeKey] == true
            progress.allTotal = progress.allTotal + 1
            if isKnown then
                progress.allKnown = progress.allKnown + 1
            end

            if meta.category == "potency" then
                progress.potencyTotal = progress.potencyTotal + 1
            elseif meta.category == "essence" then
                progress.essenceTotal = progress.essenceTotal + 1
            elseif meta.category == "aspect" then
                progress.aspectTotal = progress.aspectTotal + 1
            end

            -- Grand Master Crafter's Potency requirement uses ranks 1-14 on
            -- both the additive and subtractive sides. Ranks 15-16 remain part
            -- of Aldren's broader 56-rune Enchanting mastery.
            if meta.category == "potency" and tonumber(meta.rank or 0) <= 14 then
                if meta.polarity == "add" then
                    progress.positiveTotal = progress.positiveTotal + 1
                    if isKnown then
                        progress.positiveKnown = progress.positiveKnown + 1
                    end
                elseif meta.polarity == "sub" then
                    progress.negativeTotal = progress.negativeTotal + 1
                    if isKnown then
                        progress.negativeKnown = progress.negativeKnown + 1
                    end
                end
            end
        end
    end

    return progress
end

local function AAW_GetEnchantingProgress()
    local progress = AAW_GetEnchantingProgressBreakdown()
    return progress.allKnown, progress.allTotal
end

local function AAW_GetGrandmasterPotencyProgress()
    local progress = AAW_GetEnchantingProgressBreakdown()
    local completed = 0

    if progress.positiveTotal > 0 and progress.positiveKnown >= progress.positiveTotal then
        completed = completed + 1
    end
    if progress.negativeTotal > 0 and progress.negativeKnown >= progress.negativeTotal then
        completed = completed + 1
    end

    return completed, 2, progress
end

local function AAW_GetMissingRuneCategoryLabel(meta)
    if not meta then
        return "Rune"
    end

    if meta.category == "potency" then
        if meta.polarity == "add" then
            return "Positive Potency"
        elseif meta.polarity == "sub" then
            return "Negative Potency"
        end
        return "Potency"
    elseif meta.category == "essence" then
        return "Essence"
    elseif meta.category == "aspect" then
        return "Aspect"
    end

    return "Rune"
end

local function AAW_BuildMissingEnchantingRuneList(foundItems, limit)
    local missing = {}
    local knownRunes = AAW_GetSavedRuneTranslations()
    local maximum = math.max(1, tonumber(limit) or 5)

    for runeKey, meta in pairs(AAW.runeTranslations or {}) do
        local ownedItem = foundItems and foundItems[runeKey]
        local ownedCount = ownedItem and tonumber(ownedItem.count or 0) or 0

        if meta and meta.category and knownRunes[runeKey] ~= true and ownedCount <= 0 then
            local rank = tonumber(meta.rank or 50) or 50
            local priority = 4

            if meta.category == "potency" and rank <= 14 then
                priority = 1
            elseif meta.category == "potency" then
                priority = 2
            elseif meta.category == "essence" then
                priority = 3
            end

            table.insert(missing, {
                key = runeKey,
                name = AAW_TitleCaseReagentName(runeKey),
                categoryLabel = AAW_GetMissingRuneCategoryLabel(meta),
                priority = priority,
                rank = rank,
                polarityOrder = meta.polarity == "add" and 1 or (meta.polarity == "sub" and 2 or 3),
                rare = meta.rare == true,
            })
        end
    end

    table.sort(missing, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        if a.rank ~= b.rank then
            return a.rank < b.rank
        end
        if a.polarityOrder ~= b.polarityOrder then
            return a.polarityOrder < b.polarityOrder
        end
        if a.rare ~= b.rare then
            return a.rare == false
        end
        return tostring(a.name) < tostring(b.name)
    end)

    local result = {}
    for index = 1, math.min(maximum, #missing) do
        table.insert(result, missing[index])
    end

    return result
end

local function AAW_FormatMissingEnchantingRunes(foundItems)
    local missing = AAW_BuildMissingEnchantingRuneList(foundItems, 5)
    local lines = { "Runes to look for:" }

    if #missing == 0 then
        table.insert(lines, "None from Aldren's unfinished list.")
        return table.concat(lines, "\n")
    end

    for _, rune in ipairs(missing) do
        table.insert(lines, "- " .. tostring(rune.name) .. " (" .. tostring(rune.categoryLabel) .. ")")
    end

    return table.concat(lines, "\n")
end

local function AAW_FormatRuneLine(label, item)
    if not item then
        return label .. ": none"
    end

    return label .. ": " .. tostring(item.name or "unknown")
end

local function AAW_FormatRuneLesson(lesson)
    if not lesson then
        return "Next lesson:\nLet us count your runes first."
    end

    if lesson.status == "missing_runes" then
        return "Next lesson:\nWe need more runes before the next lesson."
            .. "\nA runestone walk may help."
    end

    if lesson.status == "complete_or_saved" then
        local known, total = AAW_GetEnchantingProgress()
        if total > 0 and known >= total then
            return "Congratulations, you have mastered enchanting."
        end

        return "Next lesson:\nWe need more runes before the next lesson."
            .. "\nA runestone walk may help."
    end

    return "Next lesson:\nMake this glyph to translate runes."
        .. "\n" .. AAW_FormatRuneLine("Potency", lesson.potency)
        .. "\n" .. AAW_FormatRuneLine("Essence", lesson.essence)
        .. "\n" .. AAW_FormatRuneLine("Aspect", lesson.aspect)
        .. "\nMay translate: " .. tostring(lesson.learnCount or 0) .. " rune(s)"
end

local function AAW_FormatEnchantingGrandmasterNote()
    local completed, required = AAW_GetGrandmasterPotencyProgress()
    return "Grandmaster note:\nYou have completed " .. tostring(completed) .. "/" .. tostring(required) .. " Potency achievements."
end



-- Shared research foundation. Each profession keeps its own scroll count so
-- Aldren never suggests a scroll that cannot help at the current station.
local AAW_RESEARCH_PROFESSIONS = { "jewelry", "blacksmithing", "clothing", "woodworking" }

local function AAW_NewResearchScrollCounts()
    return { jewelry = 0, blacksmithing = 0, clothing = 0, woodworking = 0 }
end

local function AAW_GetResearchScrollProfession(itemName)
    local lower = AAW_Lower(AAW_CleanName(itemName or ""))
    if lower == "" or not string.find(lower, "research", 1, true) then return nil end
    if not (string.find(lower, "scroll", 1, true) or string.find(lower, "instant", 1, true)) then return nil end

    -- Be deliberately strict. Shared/all-profession scrolls and ambiguous item
    -- names must never be filed under Jewelry merely because their description
    -- mentions Jewelry Crafting. Aldren only remembers an explicitly named,
    -- profession-specific research scroll.
    local isJewelry = string.find(lower, "jewelry crafting research", 1, true)
        or string.find(lower, "jewelry research scroll", 1, true)
    local isBlacksmithing = string.find(lower, "blacksmithing research", 1, true)
        or string.find(lower, "blacksmith research scroll", 1, true)
    local isClothing = string.find(lower, "clothing research", 1, true)
        or string.find(lower, "clothier research", 1, true)
    local isWoodworking = string.find(lower, "woodworking research", 1, true)
        or string.find(lower, "woodworker research scroll", 1, true)

    local matches = 0
    local profession = nil
    if isJewelry then matches = matches + 1; profession = "jewelry" end
    if isBlacksmithing then matches = matches + 1; profession = "blacksmithing" end
    if isClothing then matches = matches + 1; profession = "clothing" end
    if isWoodworking then matches = matches + 1; profession = "woodworking" end
    if matches == 1 then return profession end
    return nil
end

local function AAW_GetResearchScrollDays(itemName)
    local lower = AAW_Lower(AAW_CleanName(itemName or ""))
    if string.find(lower, "7 day", 1, true) or string.find(lower, "seven day", 1, true) then return 7 end
    return 1
end

local function AAW_ScanResearchScrollBag(bagId)
    local counts = AAW_NewResearchScrollCounts()
    local details = {
        jewelry = { total = 0, oneDay = 0, sevenDay = 0 },
        blacksmithing = { total = 0, oneDay = 0, sevenDay = 0 },
        clothing = { total = 0, oneDay = 0, sevenDay = 0 },
        woodworking = { total = 0, oneDay = 0, sevenDay = 0 },
    }
    if type(GetBagSize) ~= "function" or type(GetItemName) ~= "function" then return counts, details end
    local okSize, size = pcall(GetBagSize, bagId)
    if not okSize or type(size) ~= "number" then return counts, details end

    for slotIndex = 0, size - 1 do
        local okName, name = pcall(GetItemName, bagId, slotIndex)
        local profession = okName and AAW_GetResearchScrollProfession(name) or nil
        if profession then
            local stack = 1
            if type(GetSlotStackSize) == "function" then
                local okStack, value = pcall(GetSlotStackSize, bagId, slotIndex)
                if okStack and type(value) == "number" then stack = value end
            end
            counts[profession] = (counts[profession] or 0) + stack
            details[profession].total = details[profession].total + stack
            if AAW_GetResearchScrollDays(name) == 7 then
                details[profession].sevenDay = details[profession].sevenDay + stack
            else
                details[profession].oneDay = details[profession].oneDay + stack
            end
        end
    end
    return counts, details
end

local function AAW_AddResearchScrollCounts(target, source)
    for _, profession in ipairs(AAW_RESEARCH_PROFESSIONS) do
        target[profession] = (target[profession] or 0) + (source[profession] or 0)
    end
end

local function AAW_RememberBankResearchScrolls()
    if not AAW.saved then return end

    local counts = AAW_NewResearchScrollCounts()
    local details = {
        jewelry = { total = 0, oneDay = 0, sevenDay = 0 },
        blacksmithing = { total = 0, oneDay = 0, sevenDay = 0 },
        clothing = { total = 0, oneDay = 0, sevenDay = 0 },
        woodworking = { total = 0, oneDay = 0, sevenDay = 0 },
    }

    local function addBag(bagId)
        local bagCounts, bagDetails = AAW_ScanResearchScrollBag(bagId)
        AAW_AddResearchScrollCounts(counts, bagCounts)
        for _, profession in ipairs(AAW_RESEARCH_PROFESSIONS) do
            local source = bagDetails[profession] or {}
            local target = details[profession]
            target.total = target.total + (source.total or 0)
            target.oneDay = target.oneDay + (source.oneDay or 0)
            target.sevenDay = target.sevenDay + (source.sevenDay or 0)
        end
    end

    if BAG_BANK then addBag(BAG_BANK) end
    if BAG_SUBSCRIBER_BANK and BAG_SUBSCRIBER_BANK ~= BAG_BANK then addBag(BAG_SUBSCRIBER_BANK) end

    AAW.saved.bankResearchScrollsByProfession = counts
    AAW.saved.bankResearchScrollDetailsByProfession = details
    AAW.saved.bankResearchScrollsSeenAt = (type(GetTimeStamp) == "function" and GetTimeStamp()) or 0

    -- Copy the memory into the shared Brain. Each profession remains isolated.
    for _, profession in ipairs(AAW_RESEARCH_PROFESSIONS) do
        AAW_GetResearchProfession(profession).rememberedBankScrolls = details[profession]
    end
end

local function AAW_FormatResearchTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if days > 0 then return tostring(days) .. " day(s), " .. tostring(hours) .. " hour(s)" end
    if hours > 0 then return tostring(hours) .. " hour(s), " .. tostring(minutes) .. " minute(s)" end
    return tostring(math.max(1, minutes)) .. " minute(s)"
end

local function AAW_GetScrollCooldownForProfession(profession)
    if not BAG_BACKPACK or type(GetBagSize) ~= "function" then return 0, false end
    local okSize, size = pcall(GetBagSize, BAG_BACKPACK)
    if not okSize or type(size) ~= "number" then return 0, false end
    local longest = 0
    local found = false
    for slotIndex = 0, size - 1 do
        local okName, name = pcall(GetItemName, BAG_BACKPACK, slotIndex)
        if okName and AAW_GetResearchScrollProfession(name) == profession then
            found = true
            if type(GetItemCooldownInfo) == "function" then
                local values = { pcall(GetItemCooldownInfo, BAG_BACKPACK, slotIndex) }
                if values[1] then
                    for i = 2, #values do
                        local value = tonumber(values[i])
                        if value and value >= 0 and value > longest then longest = value end
                    end
                end
            end
        end
    end
    return longest, found
end

local function AAW_CalculateResearchScrollPlan(remainingSeconds, currentCooldown, scrollDetails)
    local remaining = math.max(0, tonumber(remainingSeconds) or 0)
    local cooldown = math.max(0, tonumber(currentCooldown) or 0)
    local details = scrollDetails or {}
    local oneDayAvailable = math.max(0, math.floor(tonumber(details.oneDay) or 0))
    local sevenDayAvailable = math.max(0, math.floor(tonumber(details.sevenDay) or 0))
    local usedOneDay = 0
    local usedSevenDay = 0

    -- If a cooldown is already running, research continues naturally while
    -- Aldren waits for the next scroll to become usable.
    if cooldown > 0 then
        remaining = math.max(0, remaining - cooldown)
        if remaining <= 0 then
            return {
                scrollsUsed = 0,
                oneDayUsed = 0,
                sevenDayUsed = 0,
                remainingAfterFinalCooldown = 0,
                finishesDuringCurrentCooldown = true,
                enoughCarried = true,
            }
        end
    end

    -- A scroll is useful only while more than one day of research remains.
    -- Seven-day scrolls are applied first because they provide the larger
    -- reduction. Every use begins the shared 20-hour cooldown.
    while remaining > 86400 and (sevenDayAvailable > 0 or oneDayAvailable > 0) do
        if sevenDayAvailable > 0 then
            remaining = math.max(0, remaining - 604800)
            sevenDayAvailable = sevenDayAvailable - 1
            usedSevenDay = usedSevenDay + 1
        else
            remaining = math.max(0, remaining - 86400)
            oneDayAvailable = oneDayAvailable - 1
            usedOneDay = usedOneDay + 1
        end

        if remaining <= 0 then break end

        -- Research keeps counting down during the 20-hour scroll cooldown.
        remaining = math.max(0, remaining - 72000)
        if remaining <= 0 then break end
    end

    return {
        scrollsUsed = usedOneDay + usedSevenDay,
        oneDayUsed = usedOneDay,
        sevenDayUsed = usedSevenDay,
        remainingAfterFinalCooldown = remaining,
        finishesDuringCurrentCooldown = false,
        enoughCarried = remaining <= 86400,
    }
end

local function AAW_GetTraitName(traitType)
    if type(traitType) ~= "number" or traitType <= 0 then return nil end

    -- Step Six: one shared, console-safe trait archive for every research bench.
    -- ESO gives Aldren the numeric item trait type.  The console API's localized
    -- string lookup is not consistent for every profession, so use the stable
    -- research trait IDs directly and reserve GetString only for future traits.
    local researchTraitNames = {
        -- Weapon traits (Blacksmithing and Woodworking)
        [ITEM_TRAIT_TYPE_WEAPON_POWERED or 1] = "Powered",
        [ITEM_TRAIT_TYPE_WEAPON_CHARGED or 2] = "Charged",
        [ITEM_TRAIT_TYPE_WEAPON_PRECISE or 3] = "Precise",
        [ITEM_TRAIT_TYPE_WEAPON_INFUSED or 4] = "Infused",
        [ITEM_TRAIT_TYPE_WEAPON_DEFENDING or 5] = "Defending",
        [ITEM_TRAIT_TYPE_WEAPON_TRAINING or 6] = "Training",
        [ITEM_TRAIT_TYPE_WEAPON_SHARPENED or 7] = "Sharpened",
        [ITEM_TRAIT_TYPE_WEAPON_DECISIVE or 8] = "Decisive",
        [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED or 9] = "Nirnhoned",

        -- Armor traits (Blacksmithing, Clothing, and Woodworking shields)
        [ITEM_TRAIT_TYPE_ARMOR_STURDY or 11] = "Sturdy",
        [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE or 12] = "Impenetrable",
        [ITEM_TRAIT_TYPE_ARMOR_REINFORCED or 13] = "Reinforced",
        [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED or 14] = "Well-fitted",
        [ITEM_TRAIT_TYPE_ARMOR_TRAINING or 15] = "Training",
        [ITEM_TRAIT_TYPE_ARMOR_INFUSED or 16] = "Infused",
        [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS or ITEM_TRAIT_TYPE_ARMOR_INVIGORATING or 17] = "Invigorating",
        [ITEM_TRAIT_TYPE_ARMOR_DIVINES or 18] = "Divines",
        [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED or 19] = "Nirnhoned",

        -- Jewelry traits
        [ITEM_TRAIT_TYPE_JEWELRY_ARCANE or 22] = "Arcane",
        [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY or 23] = "Healthy",
        [ITEM_TRAIT_TYPE_JEWELRY_ROBUST or 24] = "Robust",
        [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE or 25] = "Triune",
        [ITEM_TRAIT_TYPE_JEWELRY_INFUSED or 26] = "Infused",
        [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE or 27] = "Protective",
        [ITEM_TRAIT_TYPE_JEWELRY_SWIFT or 28] = "Swift",
        [ITEM_TRAIT_TYPE_JEWELRY_HARMONY or 29] = "Harmony",
        [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY or 30] = "Bloodthirsty",
    }

    local archivedName = researchTraitNames[traitType]
    if archivedName then return archivedName end

    -- A gentle future-proof fallback if ESO adds another research trait later.
    if type(GetString) == "function" then
        local stringIds = { SI_ITEMTRAITTYPE, "SI_ITEMTRAITTYPE" }
        for _, stringId in ipairs(stringIds) do
            if stringId then
                local ok, value = pcall(GetString, stringId, traitType)
                if ok and type(value) == "string" and value ~= "" then
                    return zo_strformat and zo_strformat("<<1>>", value) or value
                end
            end
        end
    end

    return nil
end

local function AAW_GetResearchSlotLimit(craftingType)
    local candidates = { "GetMaxSimultaneousSmithingResearch", "GetMaxSimultaneousSmithingResearches" }
    for _, functionName in ipairs(candidates) do
        local fn = _G and _G[functionName]
        if type(fn) == "function" then
            local ok, value = pcall(fn, craftingType)
            if ok and type(value) == "number" and value > 0 then return value end
        end
    end
    return nil
end

local function AAW_ScanJewelryResearch()
    local result = AAW_ResetResearchProfession("jewelry")
    local craftingType = CRAFTING_TYPE_JEWELRYCRAFTING or 7
    if type(GetNumSmithingResearchLines) ~= "function" or type(GetSmithingResearchLineInfo) ~= "function" then
        return result
    end
    local okLines, numLines = pcall(GetNumSmithingResearchLines, craftingType)
    if not okLines or type(numLines) ~= "number" then return result end

    for lineIndex = 1, numLines do
        local lineValues = { pcall(GetSmithingResearchLineInfo, craftingType, lineIndex) }
        local lineName = "Jewelry item"
        local numTraits = 9
        if lineValues[1] then
            -- ESO returns the research-line name first and the trait count third.
            -- Read those exact fields so an icon path or another numeric value is never mistaken for them.
            if type(lineValues[2]) == "string" and lineValues[2] ~= "" then
                lineName = lineValues[2]
            end
            local reportedTraits = tonumber(lineValues[4])
            if reportedTraits and reportedTraits >= 1 and reportedTraits <= 20 then
                numTraits = reportedTraits
            end
        end

        local lineKnown = 0
        local lineActive = 0
        local lineAvailableTraits = {}
        for traitIndex = 1, numTraits do
            result.total = result.total + 1
            if type(GetSmithingResearchLineTraitInfo) == "function" then
                local values = { pcall(GetSmithingResearchLineTraitInfo, craftingType, lineIndex, traitIndex) }
                if values[1] then
                    -- ESO returns the numeric trait type, its effect description, and whether it is known.
                    -- Use the numeric type to obtain the actual trait NAME.
                    local traitType = tonumber(values[2])
                    local traitName = AAW_GetTraitName(traitType)
                    local known = values[4] == true
                    local traitActive = false
                    if known then
                        result.known = result.known + 1
                        lineKnown = lineKnown + 1
                    end

                    if type(GetSmithingResearchLineTraitTimes) == "function" then
                        local times = { pcall(GetSmithingResearchLineTraitTimes, craftingType, lineIndex, traitIndex) }
                        if times[1] then
                            local remaining = 0
                            for i = 2, #times do
                                local n = tonumber(times[i])
                                if n and n > 0 then remaining = n end
                            end
                            if remaining > 0 then
                                traitActive = true
                                result.active = result.active + 1
                                lineActive = lineActive + 1
                                if remaining > result.longestRemaining then result.longestRemaining = remaining end
                                table.insert(result.projects, {
                                    item = lineName,
                                    trait = traitName or "Unknown trait",
                                    remaining = remaining,
                                })
                            end
                        end
                    end

                    if not known and not traitActive and traitName then
                        table.insert(lineAvailableTraits, traitName)
                    end
                end
            end
        end

        table.insert(result.categories, {
            item = lineName,
            known = lineKnown,
            total = numTraits,
            active = lineActive,
            remaining = math.max(0, numTraits - lineKnown),
            availableTraits = lineAvailableTraits,
        })
    end

    table.sort(result.projects, function(a, b) return (a.remaining or 0) < (b.remaining or 0) end)
    result.slotLimit = AAW_GetResearchSlotLimit(craftingType)
    AAW.state.jewelryKnownTraits = result.known
    AAW.state.jewelryTotalTraits = result.total
    AAW.state.jewelryActiveResearch = result.active
    AAW.state.jewelryResearchRemaining = result.longestRemaining
    local backpackCounts, backpackDetails = AAW_ScanResearchScrollBag(BAG_BACKPACK)
    AAW.state.backpackResearchScrolls = backpackCounts
    AAW.state.backpackResearchScrollDetails = backpackDetails
    result.carriedScrolls = backpackDetails.jewelry or { total = 0, oneDay = 0, sevenDay = 0 }
    return result
end


local function AAW_AddResearchSlotGuidance(lines, research)
    if not research or not research.slotLimit then return end

    local used = math.max(0, tonumber(research.active) or 0)
    local limit = math.max(0, tonumber(research.slotLimit) or 0)
    local available = math.max(0, limit - used)

    table.insert(lines, "Research slots: " .. tostring(used) .. "/" .. tostring(limit) .. " in use.")

    if limit <= 0 then return end

    if used <= 0 then
        table.insert(lines, "Your research bench is ready whenever you are.")
    elseif available <= 0 then
        table.insert(lines, "All research slots are currently in use.")
        table.insert(lines, "We can begin another project when one becomes available.")
    elseif available == 1 then
        table.insert(lines, "You may begin one more research project.")
    else
        table.insert(lines, "You may begin " .. tostring(available) .. " more research projects.")
    end
end

local function AAW_AddAdaptiveResearchGuidance(lines, research)
    if not research or not research.slotLimit or not research.categories then return end

    local available = math.max(0, (tonumber(research.slotLimit) or 0) - (tonumber(research.active) or 0))
    if available <= 0 then return end

    local best = nil
    for _, category in ipairs(research.categories) do
        local remaining = math.max(0, tonumber(category.remaining) or 0)
        local active = math.max(0, tonumber(category.active) or 0)
        -- ESO permits only one active research project for an item category.
        -- Do not suggest a category that is already being studied.
        if remaining > 0 and active == 0 then
            if not best
                or remaining > (best.remaining or 0)
                or (remaining == (best.remaining or 0) and tostring(category.item) < tostring(best.item)) then
                best = category
            end
        end
    end

    if not best then return end

    local suggestedTrait = nil
    if type(best.availableTraits) == "table" and #best.availableTraits > 0 then
        table.sort(best.availableTraits, function(a, b) return tostring(a) < tostring(b) end)
        suggestedTrait = best.availableTraits[1]
    end

    table.insert(lines, "")
    if best.remaining == 1 then
        table.insert(lines, "Only one " .. tostring(best.item) .. " trait remains to be learned.")
        if suggestedTrait then
            table.insert(lines, tostring(suggestedTrait) .. " would complete our studies of " .. tostring(best.item) .. ".")
        else
            table.insert(lines, tostring(best.item) .. " would be a gentle place to continue our studies.")
        end
    else
        table.insert(lines, "We still have the most to learn about " .. tostring(best.item) .. ".")
        table.insert(lines, tostring(best.remaining) .. " traits remain to be learned there.")
        if suggestedTrait then
            table.insert(lines, "The " .. tostring(suggestedTrait) .. " trait would be a good place to begin.")
        end
    end
end

local function AAW_FormatJewelryPanel(showIntro)
    AAW_ScanJewelryResearch()
    local research = AAW_GetResearchProfession("jewelry")
    local lines = {}
    table.insert(lines, (showIntro and "Welcome, " or "Welcome back, ") .. AAW_GetPlayerName() .. ".")
    table.insert(lines, "")
    table.insert(lines, "Jewelry traits researched: " .. tostring(research.known) .. "/" .. tostring(research.total) .. ".")
    table.insert(lines, "Traits remaining: " .. tostring(math.max(0, research.total - research.known)) .. ".")

    if research.total > 0 and research.known >= research.total then
        -- Completed research uses a deliberately quiet panel. Scrolls, slots,
        -- timers, greetings, and planning are no longer useful here.
        return "Congratulations on completing all Jewelry Crafting research."
    end

    AAW_AddResearchSlotGuidance(lines, research)
    AAW_AddAdaptiveResearchGuidance(lines, research)

    if research.active > 0 then
        table.insert(lines, "")
        table.insert(lines, "Research in progress:")
        for index, project in ipairs(research.projects) do
            if index > 3 then break end
            table.insert(lines, tostring(project.item) .. " — " .. tostring(project.trait))
            table.insert(lines, "Time remaining: " .. AAW_FormatResearchTime(project.remaining) .. ".")
        end

        local carried = (research.carriedScrolls and research.carriedScrolls.total) or 0
        local bankDetails = (AAW.saved and AAW.saved.bankResearchScrollDetailsByProfession) or {}
        local remembered = bankDetails.jewelry or { total = 0, oneDay = 0, sevenDay = 0 }
        research.rememberedBankScrolls = remembered

        table.insert(lines, "")
        if carried > 0 then
            table.insert(lines, "Jewelry Research Scrolls carried: " .. tostring(carried) .. ".")

            local cooldown = 0
            cooldown = select(1, AAW_GetScrollCooldownForProfession("jewelry")) or 0
            local plan = AAW_CalculateResearchScrollPlan(research.longestRemaining, cooldown, research.carriedScrolls)

            if plan.finishesDuringCurrentCooldown then
                table.insert(lines, "This research should finish before another scroll can be used.")
            elseif plan.scrollsUsed > 0 then
                local scrollWord = plan.scrollsUsed == 1 and "scroll" or "scrolls"
                table.insert(lines, "For the longest project, I estimate " .. tostring(plan.scrollsUsed) .. " " .. scrollWord .. " will be useful.")
                if plan.remainingAfterFinalCooldown > 0 then
                    table.insert(lines, "After the final cooldown, about " .. AAW_FormatResearchTime(plan.remainingAfterFinalCooldown) .. " will remain.")
                else
                    table.insert(lines, "The research should finish by the end of the final cooldown.")
                end
            else
                table.insert(lines, "This research has less than one day remaining, so a scroll is not needed.")
            end
        elseif (remembered.total or 0) > 0 then
            table.insert(lines, "I remember seeing Jewelry Research Scrolls in your bank that may help shorten this research.")
        else
            table.insert(lines, "If you carry your Jewelry Research Scrolls with you, they may shorten this research, and I can estimate how many will be useful.")
        end
    else
        table.insert(lines, "")
        table.insert(lines, "No Jewelry research is in progress.")
    end

    return table.concat(lines, "\n")
end

local AAW_RESEARCH_STATION_INFO = {
    blacksmithing = { craftingType = CRAFTING_TYPE_BLACKSMITHING or 1, display = "Blacksmithing", itemFallback = "Blacksmithing item" },
    clothing = { craftingType = CRAFTING_TYPE_CLOTHIER or 2, display = "Clothing", itemFallback = "Clothing item" },
    woodworking = { craftingType = CRAFTING_TYPE_WOODWORKING or 6, display = "Woodworking", itemFallback = "Woodworking item" },
}

local function AAW_ScanResearchProfession(profession)
    local info = AAW_RESEARCH_STATION_INFO[profession]
    local result = AAW_ResetResearchProfession(profession)
    if not info
        or type(GetNumSmithingResearchLines) ~= "function"
        or type(GetSmithingResearchLineInfo) ~= "function"
        or type(GetSmithingResearchLineTraitInfo) ~= "function"
        or type(GetSmithingResearchLineTraitTimes) ~= "function" then
        return result
    end

    local okLines, numLines = pcall(GetNumSmithingResearchLines, info.craftingType)
    if not okLines or type(numLines) ~= "number" then return result end

    for lineIndex = 1, numLines do
        local lineValues = { pcall(GetSmithingResearchLineInfo, info.craftingType, lineIndex) }
        local lineName = info.itemFallback
        local numTraits = 9
        if lineValues[1] then
            if type(lineValues[2]) == "string" and lineValues[2] ~= "" then lineName = lineValues[2] end
            local reportedTraits = tonumber(lineValues[4])
            if reportedTraits and reportedTraits >= 1 and reportedTraits <= 20 then numTraits = reportedTraits end
        end

        local lineKnown = 0
        local lineActive = 0
        local lineAvailableTraits = {}
        for traitIndex = 1, numTraits do
            result.total = result.total + 1
            local values = { pcall(GetSmithingResearchLineTraitInfo, info.craftingType, lineIndex, traitIndex) }
            if values[1] then
                local traitType = tonumber(values[2])
                local traitName = AAW_GetTraitName(traitType)
                local known = values[4] == true
                local traitActive = false
                if known then
                    result.known = result.known + 1
                    lineKnown = lineKnown + 1
                end
                local times = { pcall(GetSmithingResearchLineTraitTimes, info.craftingType, lineIndex, traitIndex) }
                if times[1] then
                    local remaining = 0
                    for i = 2, #times do
                        local n = tonumber(times[i])
                        if n and n > 0 then remaining = n end
                    end
                    if remaining > 0 then
                        traitActive = true
                        result.active = result.active + 1
                        lineActive = lineActive + 1
                        if remaining > result.longestRemaining then result.longestRemaining = remaining end
                        table.insert(result.projects, { item = lineName, trait = traitName or "Unknown trait", remaining = remaining })
                    end
                end
                if not known and not traitActive and traitName then
                    table.insert(lineAvailableTraits, traitName)
                end
            end
        end

        table.insert(result.categories, {
            item = lineName,
            known = lineKnown,
            total = numTraits,
            active = lineActive,
            remaining = math.max(0, numTraits - lineKnown),
            availableTraits = lineAvailableTraits,
        })
    end

    table.sort(result.projects, function(a, b) return (a.remaining or 0) < (b.remaining or 0) end)
    result.slotLimit = AAW_GetResearchSlotLimit(info.craftingType)
    local backpackCounts, backpackDetails = AAW_ScanResearchScrollBag(BAG_BACKPACK)
    AAW.state.backpackResearchScrolls = backpackCounts
    AAW.state.backpackResearchScrollDetails = backpackDetails
    result.carriedScrolls = backpackDetails[profession] or { total = 0, oneDay = 0, sevenDay = 0 }
    return result
end

local function AAW_AddCompactResearchSuggestion(lines, research)
    if not research or not research.slotLimit or not research.categories then return end

    local available = math.max(0, (tonumber(research.slotLimit) or 0) - (tonumber(research.active) or 0))
    if available <= 0 then return end

    local best = nil
    for _, category in ipairs(research.categories) do
        local remaining = math.max(0, tonumber(category.remaining) or 0)
        local active = math.max(0, tonumber(category.active) or 0)
        if remaining > 0 and active == 0 then
            if not best
                or remaining > (best.remaining or 0)
                or (remaining == (best.remaining or 0) and tostring(category.item) < tostring(best.item)) then
                best = category
            end
        end
    end

    if not best then return end

    local suggestedTrait = nil
    if type(best.availableTraits) == "table" and #best.availableTraits > 0 then
        table.sort(best.availableTraits, function(a, b) return tostring(a) < tostring(b) end)
        suggestedTrait = best.availableTraits[1]
    end

    table.insert(lines, "")
    if suggestedTrait then
        table.insert(lines, "Next lesson: " .. tostring(best.item) .. " — " .. tostring(suggestedTrait) .. ".")
    else
        table.insert(lines, "Next lesson: continue our studies of " .. tostring(best.item) .. ".")
    end
end

local function AAW_FormatResearchProfessionPanel(profession, showIntro)
    local info = AAW_RESEARCH_STATION_INFO[profession]
    AAW_ScanResearchProfession(profession)
    local research = AAW_GetResearchProfession(profession)
    local lines = {}
    table.insert(lines, (showIntro and "Welcome, " or "Welcome back, ") .. AAW_GetPlayerName() .. ".")

    if research.total > 0 and research.known >= research.total then
        -- Every completed research profession uses the same quiet finished state.
        -- The profession's total remains visible in the Grandmaster note below.
        return "Congratulations on completing all " .. info.display .. " research."
    end

    local used = math.max(0, tonumber(research.active) or 0)
    local limit = math.max(0, tonumber(research.slotLimit) or 0)
    table.insert(lines, "")
    if limit > 0 then
        table.insert(lines, "Research slots: " .. tostring(used) .. "/" .. tostring(limit) .. " in use.")
    else
        table.insert(lines, "Active research: " .. tostring(used) .. ".")
    end

    if research.active > 0 then
        table.insert(lines, "")
        table.insert(lines, "Research in progress:")
        for index, project in ipairs(research.projects) do
            table.insert(lines, tostring(index) .. ". " .. tostring(project.item)
                .. " — " .. tostring(project.trait)
                .. " — " .. AAW_FormatResearchTime(project.remaining))
        end
    else
        table.insert(lines, "")
        table.insert(lines, "No " .. info.display .. " research is in progress.")
    end

    AAW_AddCompactResearchSuggestion(lines, research)

    if research.active > 0 then
        local carried = (research.carriedScrolls and research.carriedScrolls.total) or 0
        local bankDetails = (AAW.saved and AAW.saved.bankResearchScrollDetailsByProfession) or {}
        local remembered = bankDetails[profession] or { total = 0 }
        if carried > 0 then
            local cooldown = select(1, AAW_GetScrollCooldownForProfession(profession)) or 0
            local plan = AAW_CalculateResearchScrollPlan(research.longestRemaining, cooldown, research.carriedScrolls)
            table.insert(lines, "")
            if plan.finishesDuringCurrentCooldown then
                table.insert(lines, "The longest project should finish before another scroll can be used.")
            elseif plan.scrollsUsed > 0 then
                local scrollWord = plan.scrollsUsed == 1 and "scroll" or "scrolls"
                table.insert(lines, tostring(plan.scrollsUsed) .. " carried research " .. scrollWord .. " may help the longest project.")
            end
        elseif (remembered.total or 0) > 0 then
            table.insert(lines, "")
            table.insert(lines, "I remember seeing " .. info.display .. " Research Scrolls in your bank.")
        end
    end

    return table.concat(lines, "\n")
end

local function AAW_FormatGrandmasterNote()
    if AAW_RESEARCH_STATION_INFO[AAW.state.currentStation] then
        local profession = AAW.state.currentStation
        local info = AAW_RESEARCH_STATION_INFO[profession]
        local research = AAW_GetResearchProfession(profession)
        if research.total > 0 and research.known >= research.total then
            return "Grandmaster note:\nCompleted " .. tostring(research.known) .. "/" .. tostring(research.total) .. " traits."
        end
        return "Grandmaster note:\n" .. info.display .. " research: " .. tostring(research.known) .. "/" .. tostring(research.total) .. " traits known."
    end

    if AAW.state.currentStation == "jewelry" then
        local known, total = AAW.state.jewelryKnownTraits or 0, AAW.state.jewelryTotalTraits or 0
        if total > 0 and known >= total then
            return "Grandmaster note:\nCompleted " .. tostring(known) .. "/" .. tostring(total) .. " traits."
        end
        return "Grandmaster note:\nJewelry research: " .. tostring(known) .. "/" .. tostring(total) .. " traits known."
    end

    if AAW.state.currentStation == "enchanting" then
        return AAW_FormatEnchantingGrandmasterNote()
    end

    if AAW.state.currentStation == "provisioning" then
        return "Grandmaster note:\nI have kept our Recipe Compendium lesson in the Journal."
    end

    return AAW_FormatAlchemyGrandmasterNote()
end

local function AAW_GetGatherSuggestionLine(foundItems)
    local suggestions = {}

    for key, traits in pairs(AAW.reagentTraits or {}) do
        local ownedItem = foundItems and foundItems[key]
        local count = ownedItem and tonumber(ownedItem.count or 0) or 0
        local unknownCount = AAW_CountUnknownSavedTraits(key)

        -- We only suggest reagents that are missing or nearly gone.
        -- If all four traits are already saved as known, this reagent is less useful for trait lessons.
        if count <= 0 and unknownCount > 0 then
            table.insert(suggestions, {
                name = ownedItem and ownedItem.name or AAW_TitleCaseReagentName(key),
                count = count,
                unknownCount = unknownCount,
            })
        end
    end

    table.sort(suggestions, function(a, b)
        if a.unknownCount ~= b.unknownCount then
            return a.unknownCount > b.unknownCount
        end
        return tostring(a.name) < tostring(b.name)
    end)

    local names = {}
    for index, suggestion in ipairs(suggestions) do
        if index > 3 then
            break
        end
        table.insert(names, suggestion.name)
    end

    if #names == 0 then
        return nil
    end

    return table.concat(names, ", ")
end

local function AAW_FormatFarmTargetForPanel(farmRecipe)
    if farmRecipe == nil then
        local fallback = AAW_GetGatherSuggestionLine(AAW.state.latestFoundItems)
        if fallback then
            return "Need to gather: " .. fallback
                .. "\nThis may open a new lesson."
        end

        return "Need to gather: checking what would help next."
    end

    if farmRecipe.status ~= "ok" then
        local fallback = AAW_GetGatherSuggestionLine(AAW.state.latestFoundItems)
        if fallback then
            return "Need to gather: " .. fallback
                .. "\nThis may open a new lesson."
        end

        return "Need to gather: We do not have the reagents needed to move forward in your training."
            .. "\nYou may already know these lessons."
    end

    local missingText = AAW_JoinNames(farmRecipe.missing or {}, 3)
    local nextRecipeName = AAW_JoinNames(farmRecipe.effects, 3)
    if nextRecipeName == "none" then
        nextRecipeName = "the next lesson"
    end

    return "Need to gather: " .. missingText
        .. "\nNext potion: " .. nextRecipeName
        .. "\nUses: " .. AAW_GetReagentNamesLine(farmRecipe.reagents, false)
        .. "\nCould learn: " .. tostring(farmRecipe.score or 0) .. " trait(s)"
end

local function AAW_ShouldShowIntro()
    if AAW.saved then
        return AAW.saved.hasSeenAldrenIntro ~= true
    end

    return AAW.state.hasSeenAldrenIntro ~= true
end

local function AAW_MarkIntroSeen()
    AAW.state.hasSeenAldrenIntro = true

    if AAW.saved then
        AAW.saved.hasSeenAldrenIntro = true
    end
end


local function AAW_FormatEnchantingPanel(showIntro)
    local lines = {}
    local playerName = AAW_GetPlayerName()
    local totalStacks = AAW.state.latestEnchantingTotalStacks or 0
    local potencyCount = AAW.state.latestPotencyRuneCount or 0
    local essenceCount = AAW.state.latestEssenceRuneCount or 0
    local aspectCount = AAW.state.latestAspectRuneCount or 0
    local lesson = AAW.state.latestRuneLesson

    if showIntro then
        table.insert(lines, "Welcome, " .. playerName .. ".")
        table.insert(lines, "I'm Aldren the Archivist.")
        table.insert(lines, "I will help you learn the runes.")
        table.insert(lines, "")
    else
        table.insert(lines, "Welcome back, " .. playerName .. ".")
        table.insert(lines, "Here is your next rune lesson.")
        table.insert(lines, "")
    end

    table.insert(lines, AAW_FormatRuneLesson(lesson))

    local progress = AAW_GetEnchantingProgressBreakdown()
    table.insert(lines, "")
    table.insert(lines, "Rune pouch — distinct rune types held:")
    table.insert(lines, "Potency: " .. tostring(potencyCount) .. "/" .. tostring(progress.potencyTotal))
    table.insert(lines, "Essence: " .. tostring(essenceCount) .. "/" .. tostring(progress.essenceTotal))
    table.insert(lines, "Aspect: " .. tostring(aspectCount) .. "/" .. tostring(progress.aspectTotal))

    table.insert(lines, "")
    table.insert(lines, "Positive Potency: " .. tostring(progress.positiveKnown) .. "/" .. tostring(progress.positiveTotal))
    table.insert(lines, "Negative Potency: " .. tostring(progress.negativeKnown) .. "/" .. tostring(progress.negativeTotal))
    table.insert(lines, "All rune translations: " .. tostring(progress.allKnown) .. "/" .. tostring(progress.allTotal))
    table.insert(lines, "")
    table.insert(lines, AAW_FormatMissingEnchantingRunes(AAW.state.latestEnchantingItems or {}))

    return table.concat(lines, "\n")
end

local function AAW_GetProvisioningRecipeName(listIndex, recipeIndex, recipeName)
    if type(recipeName) == "string" and recipeName ~= "" then
        return recipeName
    end

    if type(GetRecipeResultItemLink) == "function" then
        local okLink, itemLink = pcall(GetRecipeResultItemLink, listIndex, recipeIndex)
        if okLink and type(itemLink) == "string" and itemLink ~= "" then
            if type(GetItemLinkName) == "function" then
                local okName, itemName = pcall(GetItemLinkName, itemLink)
                if okName and type(itemName) == "string" and itemName ~= "" then
                    return itemName
                end
            end
            return itemLink
        end
    end

    return nil
end

local function AAW_GetProvisioningRecipeCount(listIndex)
    -- Current ESO builds report the number of recipes through GetRecipeListInfo.
    if type(GetRecipeListInfo) == "function" then
        local okInfo, _, numRecipes = pcall(GetRecipeListInfo, listIndex)
        if okInfo and type(numRecipes) == "number" then
            return numRecipes
        end
    end

    -- Keep this older fallback in case a platform build still exposes it.
    if type(GetNumRecipesInRecipeList) == "function" then
        local okCount, numRecipes = pcall(GetNumRecipesInRecipeList, listIndex)
        if okCount and type(numRecipes) == "number" then
            return numRecipes
        end
    end

    return 0
end

local function AAW_GetRecipeCompendiumProgress()
    local knowledge = _G["AldrensGrandmasterWorkshop_ProvisioningKnowledge"]
    local achievementId = tonumber(knowledge and knowledge.recipeCompendiumAchievementId)
        or AAW_RECIPE_COMPENDIUM_ACHIEVEMENT_ID
    local fallbackRequired = tonumber(knowledge and knowledge.recipeCompendiumRequired)
        or AAW_RECIPE_COMPENDIUM_REQUIRED

    if type(GetAchievementCriterion) == "function" then
        local okCriterion, _, numCompleted, numRequired =
            pcall(GetAchievementCriterion, achievementId, 1)
        if okCriterion and type(numCompleted) == "number"
            and type(numRequired) == "number" and numRequired > 0 then
            local completed = math.max(0, math.min(numCompleted, numRequired))
            return completed, numRequired, true
        end
    end

    return 0, fallbackRequired, false
end

local function AAW_ScanProvisioningRecipes()
    -- Grand Master progress must come from ESO's Recipe Compendium criterion.
    -- Furnishing designs and catalogue size never alter this number.
    local known, total, ready = AAW_GetRecipeCompendiumProgress()
    AAW.state.provisioningKnownRecipes = known
    AAW.state.provisioningTotalRecipes = total
    AAW.state.provisioningAchievementReady = ready
    return known, total, {}
end

-- Aldren's Recipe Knowledge Library.
--
-- Important console finding from the 1.3.5 PS5 test:
-- GetRecipeListInfo can report a large sparse recipe-index range, but ESO's own
-- Provisioner Manager does not treat every number in that range as a readable
-- recipe. It walks the known recipes with GetNextKnownRecipeForCraftingStation.
--
-- For now Aldren records only the food and drink recipes ESO can verify as
-- known. Unknown recipes need a separate, verified static archive. He will not
-- guess names, levels, or qualities from empty/inaccessible recipe slots.
local function AAW_GetRecipeResultItemLinkSafe(listIndex, recipeIndex)
    if type(GetRecipeResultItemLink) ~= "function" then
        return nil
    end

    local okLink, itemLink
    if LINK_STYLE_DEFAULT ~= nil then
        okLink, itemLink = pcall(GetRecipeResultItemLink, listIndex, recipeIndex, LINK_STYLE_DEFAULT)
    else
        okLink, itemLink = pcall(GetRecipeResultItemLink, listIndex, recipeIndex)
    end

    if okLink and type(itemLink) == "string" and itemLink ~= "" then
        return itemLink
    end

    return nil
end

local function AAW_IsFoodOrDrinkItemType(itemType)
    return (ITEMTYPE_FOOD ~= nil and itemType == ITEMTYPE_FOOD)
        or (ITEMTYPE_DRINK ~= nil and itemType == ITEMTYPE_DRINK)
end

local function AAW_GetRecipeResultItemType(itemLink)
    if not itemLink or type(GetItemLinkItemType) ~= "function" then
        return nil
    end

    local okType, itemType = pcall(GetItemLinkItemType, itemLink)
    if okType then
        return itemType
    end

    return nil
end

local function AAW_GetRecipeResultDisplayQuality(itemLink, listIndex, recipeIndex)
    if itemLink and type(GetItemLinkDisplayQuality) == "function" then
        local okQuality, displayQuality = pcall(GetItemLinkDisplayQuality, itemLink)
        if okQuality and type(displayQuality) == "number" then
            return displayQuality
        end
    end

    if type(GetRecipeResultItemInfo) == "function" then
        local okInfo, _, _, _, _, displayQuality = pcall(GetRecipeResultItemInfo, listIndex, recipeIndex)
        if okInfo and type(displayQuality) == "number" then
            return displayQuality
        end
    end

    return nil
end

local function AAW_GetRecipeResultName(itemLink, listIndex, recipeIndex, recipeName)
    if type(GetRecipeResultItemInfo) == "function" then
        local okInfo, resultName = pcall(GetRecipeResultItemInfo, listIndex, recipeIndex)
        if okInfo and type(resultName) == "string" and resultName ~= "" then
            return AAW_CleanName(resultName)
        end
    end

    local fallbackName = AAW_GetProvisioningRecipeName(listIndex, recipeIndex, recipeName)
    if fallbackName and fallbackName ~= "" then
        return AAW_CleanName(fallbackName)
    end

    if itemLink and type(GetItemLinkName) == "function" then
        local okName, itemName = pcall(GetItemLinkName, itemLink)
        if okName and type(itemName) == "string" and itemName ~= "" then
            return AAW_CleanName(itemName)
        end
    end

    return nil
end

local function AAW_GetRecipeLevelRequirement(itemLink)
    local requiredLevel = 0
    local requiredChampionPoints = 0

    if itemLink and type(GetItemLinkRequiredLevel) == "function" then
        local okLevel, level = pcall(GetItemLinkRequiredLevel, itemLink)
        if okLevel and type(level) == "number" then
            requiredLevel = level
        end
    end

    if itemLink and type(GetItemLinkRequiredChampionPoints) == "function" then
        local okChampion, championPoints = pcall(GetItemLinkRequiredChampionPoints, itemLink)
        if okChampion and type(championPoints) == "number" then
            requiredChampionPoints = championPoints
        end
    end

    local sortTier = 0
    local sortValue = 0
    if requiredChampionPoints > 0 then
        sortTier = 2
        sortValue = requiredChampionPoints
    elseif requiredLevel > 0 then
        sortTier = 1
        sortValue = requiredLevel
    end

    return requiredLevel, requiredChampionPoints, sortTier, sortValue
end

local function AAW_NormalizeProvisioningKnowledgeName(name)
    local cleaned = AAW_CleanName(name)
    local normalized = AAW_Lower(cleaned)
    normalized = string.gsub(normalized, "^design:%s*", "")
    normalized = string.gsub(normalized, "^recipe:%s*", "")
    return normalized
end

local function AAW_BuildProvisioningKnowledgeLookup(names)
    local lookup = {}
    if type(names) ~= "table" then
        return lookup
    end

    for _, name in ipairs(names) do
        local normalized = AAW_NormalizeProvisioningKnowledgeName(name)
        if normalized ~= "" then
            lookup[normalized] = true
        end
    end
    return lookup
end

-- These catalogues never change during a play session. Build their normalized
-- lookups once, then reuse them. Rebuilding nearly one thousand lowercase keys
-- on every zone change was unnecessary work on console.
local function AAW_EnsureRecipeKnowledgeStaticData()
    local library = AAW.recipeKnowledgeLibrary
    if library.staticLookupsReady then
        return library.foodDrinkLookup, library.designLookup, library.preparedArchiveRecords
    end

    local knowledge = _G["AldrensGrandmasterWorkshop_ProvisioningKnowledge"]
    local foodDrinkNames = knowledge and knowledge.foodDrinkRecipeNames or {}
    local designNames = knowledge and knowledge.provisioningDesignNames or {}

    library.foodDrinkLookup = AAW_BuildProvisioningKnowledgeLookup(foodDrinkNames)
    library.designLookup = AAW_BuildProvisioningKnowledgeLookup(designNames)
    library.foodDrinkKnowledgeCount = type(foodDrinkNames) == "table" and #foodDrinkNames or 0
    library.designKnowledgeCount = type(designNames) == "table" and #designNames or 0
    library.preparedArchiveRecords = {}

    local archive = _G["AldrensGrandmasterWorkshop_RecipeArchive"]
    local archiveRecords = archive and archive.records
    if type(archiveRecords) == "table"
        and #archiveRecords > 0
        and tostring(archive.levelStatus or "") == "verified"
        and tostring(archive.qualityStatus or "") == "verified" then
        for _, record in ipairs(archiveRecords) do
            local recipeName = tostring(record[4] or "")
            table.insert(library.preparedArchiveRecords, {
                resultItemId = tonumber(record[1]) or 0,
                recipeItemId = tonumber(record[2]) or 0,
                category = tostring(record[3] or ""),
                name = recipeName,
                recipeType = tostring(record[5] or ""),
                sourceQualityCandidate = tonumber(record[6]),
                verifiedQuality = tonumber(record[7]),
                catalogStatus = tostring(record[8] or ""),
                requiredLevel = tonumber(record[9]) or 0,
                requiredChampionPoints = tonumber(record[10]) or 0,
                normalizedName = AAW_NormalizeProvisioningKnowledgeName(recipeName),
                sortName = AAW_Lower(recipeName),
                known = false,
            })
        end
    end

    library.staticLookupsReady = true
    return library.foodDrinkLookup, library.designLookup, library.preparedArchiveRecords
end

local function AAW_ClearRecipeKnowledgeLibrary()
    local library = AAW.recipeKnowledgeLibrary
    library.entries = {}
    library.unknown = {}
    library.easiest = {}
    library.watchedDesigns = {}
    library.total = 0
    library.known = 0
    library.liveFoodDrinkKnown = 0
    library.knownProvisioningEntries = 0
    library.knownDesigns = 0
    library.unresolvedKnownEntries = 0
    library.foodDrinkKnowledgeCount = 0
    library.designKnowledgeCount = 0
    library.achievementKnown = 0
    library.achievementRequired = AAW_RECIPE_COMPENDIUM_REQUIRED
    library.achievementReady = false
    library.achievementComplete = false
    library.unknownCount = 0
    library.unknownDesignCount = 0
    library.recipeIndexSlots = 0
    library.completeArchiveReady = false
    library.designArchiveReady = false
    library.lastScanSucceeded = false

    AAW.state.provisioningFoodDrinkRecipes = 0
    AAW.state.provisioningUnknownFoodDrinkRecipes = 0
    AAW.state.provisioningKnownEntries = 0
    AAW.state.provisioningKnownDesigns = 0
    AAW.state.provisioningUnresolvedKnownEntries = 0
    return library
end

function AAW.RefreshRecipeKnowledgeLibrary(forceRefresh)
    local library = AAW.recipeKnowledgeLibrary

    -- Reuse the last successful snapshot until ESO tells Aldren that a recipe
    -- was learned. The achievement criterion is cheap, so keep that one value live.
    if forceRefresh ~= true and library.lastScanSucceeded and not AAW.state.recipeKnowledgeDirty then
        local achievementKnown, achievementRequired, achievementReady = AAW_GetRecipeCompendiumProgress()
        library.achievementKnown = achievementKnown
        library.achievementRequired = achievementRequired
        library.achievementReady = achievementReady
        library.achievementComplete = achievementReady
            and achievementRequired > 0
            and achievementKnown >= achievementRequired
        AAW.state.provisioningKnownRecipes = achievementKnown
        AAW.state.provisioningTotalRecipes = achievementRequired
        AAW.state.provisioningAchievementReady = achievementReady
        return true, library
    end

    library = AAW_ClearRecipeKnowledgeLibrary()
    local knownResultItemIds = {}
    local knownRecipeNames = {}
    local knownDesignNames = {}
    local foodDrinkLookup, designLookup, preparedArchiveRecords = AAW_EnsureRecipeKnowledgeStaticData()

    -- AAW_ClearRecipeKnowledgeLibrary resets dynamic display fields only. Restore
    -- the two static catalogue totals from the cached source tables.
    local knowledge = _G["AldrensGrandmasterWorkshop_ProvisioningKnowledge"]
    local foodDrinkNames = knowledge and knowledge.foodDrinkRecipeNames or {}
    local designNames = knowledge and knowledge.provisioningDesignNames or {}
    library.foodDrinkKnowledgeCount = type(foodDrinkNames) == "table" and #foodDrinkNames or 0
    library.designKnowledgeCount = type(designNames) == "table" and #designNames or 0

    local achievementKnown, achievementRequired, achievementReady = AAW_GetRecipeCompendiumProgress()
    library.achievementKnown = achievementKnown
    library.achievementRequired = achievementRequired
    library.achievementReady = achievementReady
    library.achievementComplete = achievementReady
        and achievementRequired > 0
        and achievementKnown >= achievementRequired

    AAW.state.provisioningKnownRecipes = achievementKnown
    AAW.state.provisioningTotalRecipes = achievementRequired
    AAW.state.provisioningAchievementReady = achievementReady

    if type(GetNumRecipeLists) ~= "function"
        or type(GetRecipeListInfo) ~= "function"
        or type(GetRecipeInfo) ~= "function"
        or type(GetNextKnownRecipeForCraftingStation) ~= "function"
        or CRAFTING_TYPE_PROVISIONING == nil then
        return false, library
    end

    local okLists, numLists = pcall(GetNumRecipeLists)
    if not okLists or type(numLists) ~= "number" then
        return false, library
    end

    for listIndex = 1, numLists do
        local okListInfo, _, numRecipeSlots = pcall(GetRecipeListInfo, listIndex)
        if okListInfo and type(numRecipeSlots) == "number" and numRecipeSlots > 0 then
            library.recipeIndexSlots = library.recipeIndexSlots + numRecipeSlots
        end

        local lastRecipeIndex = nil
        while true do
            local okNext, recipeIndex = pcall(
                GetNextKnownRecipeForCraftingStation,
                listIndex,
                CRAFTING_TYPE_PROVISIONING,
                lastRecipeIndex
            )
            if not okNext or recipeIndex == nil then
                break
            end

            -- Defensive guard against a platform API returning the same index twice.
            if recipeIndex == lastRecipeIndex then
                break
            end
            lastRecipeIndex = recipeIndex

            local okInfo, recipeKnown, recipeName, numIngredients, provisionerLevelReq,
                qualityReq, specialIngredientType, requiredCraftingStationType, resultItemId =
                pcall(GetRecipeInfo, listIndex, recipeIndex)

            if okInfo and recipeKnown == true then
                library.knownProvisioningEntries = library.knownProvisioningEntries + 1

                local itemLink = AAW_GetRecipeResultItemLinkSafe(listIndex, recipeIndex)
                local itemType = AAW_GetRecipeResultItemType(itemLink)
                local name = AAW_GetRecipeResultName(itemLink, listIndex, recipeIndex, recipeName)
                local normalizedResultName = AAW_NormalizeProvisioningKnowledgeName(name)
                local normalizedRecipeName = AAW_NormalizeProvisioningKnowledgeName(recipeName)
                local recipeNameLower = AAW_Lower(AAW_CleanName(recipeName))
                local recipeSaysDesign = string.sub(recipeNameLower, 1, 7) == "design:"

                if AAW_IsFoodOrDrinkItemType(itemType)
                    or foodDrinkLookup[normalizedResultName] == true
                    or foodDrinkLookup[normalizedRecipeName] == true then
                    if name and name ~= "" then
                        local verifiedResultItemId = tonumber(resultItemId) or 0
                        if itemLink and type(GetItemLinkItemId) == "function" then
                            local okItemId, linkItemId = pcall(GetItemLinkItemId, itemLink)
                            if okItemId and type(linkItemId) == "number" and linkItemId > 0 then
                                verifiedResultItemId = linkItemId
                            end
                        end

                        -- The visible pages need counts and matching keys, not a
                        -- second detailed copy of every known recipe. Avoiding those
                        -- extra item-link calls keeps the first console refresh light.
                        library.liveFoodDrinkKnown = library.liveFoodDrinkKnown + 1
                        if verifiedResultItemId > 0 then
                            knownResultItemIds[verifiedResultItemId] = true
                        end
                        if normalizedResultName ~= "" then
                            knownRecipeNames[normalizedResultName] = true
                        end
                        if normalizedRecipeName ~= "" then
                            knownRecipeNames[normalizedRecipeName] = true
                        end
                    else
                        library.unresolvedKnownEntries = library.unresolvedKnownEntries + 1
                    end
                elseif recipeSaysDesign
                    or designLookup[normalizedResultName] == true
                    or designLookup[normalizedRecipeName] == true then
                    library.knownDesigns = library.knownDesigns + 1
                    if normalizedResultName ~= "" then
                        knownDesignNames[normalizedResultName] = true
                    end
                    if normalizedRecipeName ~= "" then
                        knownDesignNames[normalizedRecipeName] = true
                    end
                else
                    library.unresolvedKnownEntries = library.unresolvedKnownEntries + 1
                end
            end
        end
    end

    -- library.entries is retained for diagnostics, but no visible feature needs
    -- it alphabetized. Removing this full-list sort fixes the exact PS5 travel
    -- stack that exhausted the add-on CPU budget.

    -- The watch archive is a fixed, prepared table. It is compared only with
    -- ESO's safe known-recipe iterator. Its size is not an achievement target.
    if type(preparedArchiveRecords) == "table" and #preparedArchiveRecords > 0 then
        library.completeArchiveReady = true
        library.total = #preparedArchiveRecords
        library.known = 0

        for _, record in ipairs(preparedArchiveRecords) do
            local resultItemId = tonumber(record.resultItemId) or 0
            local normalizedName = tostring(record.normalizedName or "")
            local isKnown = (resultItemId > 0 and knownResultItemIds[resultItemId] == true)
                or (normalizedName ~= "" and knownRecipeNames[normalizedName] == true)

            if isKnown then
                library.known = library.known + 1
            else
                table.insert(library.unknown, record)
            end
        end

        table.sort(library.unknown, function(left, right)
            local leftLevel = tonumber(left.requiredLevel) or 0
            local rightLevel = tonumber(right.requiredLevel) or 0
            if leftLevel ~= rightLevel then
                return leftLevel < rightLevel
            end

            local leftChampionPoints = tonumber(left.requiredChampionPoints) or 0
            local rightChampionPoints = tonumber(right.requiredChampionPoints) or 0
            if leftChampionPoints ~= rightChampionPoints then
                return leftChampionPoints < rightChampionPoints
            end

            local leftQuality = tonumber(left.verifiedQuality) or 99
            local rightQuality = tonumber(right.verifiedQuality) or 99
            if leftQuality ~= rightQuality then
                return leftQuality < rightQuality
            end

            return tostring(left.sortName or left.name or "") < tostring(right.sortName or right.name or "")
        end)

        for index = 1, math.min(5, #library.unknown) do
            table.insert(library.easiest, library.unknown[index])
        end

        library.unknownCount = #library.unknown
    end

    -- Furnishing plans do not have character-level requirements to rank by.
    -- The verified catalogue is already alphabetical, so keep the first five
    -- unknown names without sorting or scanning any item-ID range.
    if type(designNames) == "table" and #designNames > 0 then
        library.designArchiveReady = true
        for _, designName in ipairs(designNames) do
            local normalizedDesignName = AAW_NormalizeProvisioningKnowledgeName(designName)
            if normalizedDesignName ~= "" and knownDesignNames[normalizedDesignName] ~= true then
                library.unknownDesignCount = library.unknownDesignCount + 1
                if #library.watchedDesigns < 5 then
                    table.insert(library.watchedDesigns, {
                        name = tostring(designName),
                        normalizedName = normalizedDesignName,
                    })
                end
            end
        end
    end

    library.lastScanSucceeded = true
    AAW.state.recipeKnowledgeDirty = false
    AAW.state.provisioningFoodDrinkRecipes = library.liveFoodDrinkKnown
    AAW.state.provisioningUnknownFoodDrinkRecipes = library.unknownCount
    AAW.state.provisioningKnownEntries = library.knownProvisioningEntries
    AAW.state.provisioningKnownDesigns = library.knownDesigns
    AAW.state.provisioningUnresolvedKnownEntries = library.unresolvedKnownEntries
    return true, library
end

function AAW.RunRecipeKnowledgeTest()
    local ok, library = AAW.RefreshRecipeKnowledgeLibrary(true)
    if not ok then
        AAW_Message("PROVISIONING KNOWLEDGE: ESO's known-recipe notes were not ready to read.")
        return
    end

    if library.achievementReady then
        AAW_Message("PROVISIONING KNOWLEDGE: Recipe Compendium "
            .. tostring(library.achievementKnown) .. "/" .. tostring(library.achievementRequired) .. ".")
    else
        AAW_Message("PROVISIONING KNOWLEDGE: Recipe Compendium progress was not ready.")
    end

    AAW_Message("PROVISIONING KNOWLEDGE: " .. tostring(library.knownProvisioningEntries)
        .. " learned Provisioning entries read safely: "
        .. tostring(library.liveFoodDrinkKnown) .. " food/drink, "
        .. tostring(library.knownDesigns) .. " furnishing designs, "
        .. tostring(library.unresolvedKnownEntries) .. " unresolved.")

    AAW_Message("PROVISIONING KNOWLEDGE: Aldren carries "
        .. tostring(library.foodDrinkKnowledgeCount) .. " food/drink names and "
        .. tostring(library.designKnowledgeCount) .. " Provisioning design names in separate notes.")

    if (library.recipeIndexSlots or 0) > 0 then
        AAW_Message("PROVISIONING KNOWLEDGE: ESO's sparse internal recipe-index slots are ignored.")
    end

    if library.completeArchiveReady then
        AAW_Message("PROVISIONING KNOWLEDGE: The verified watch notes loaded safely. "
            .. tostring(library.unknownCount) .. " recipes are still ahead of us.")
    else
        AAW_Message("PROVISIONING KNOWLEDGE: The verified watch notes were not ready. No unknown recipe was guessed.")
    end
end

local function AAW_IsProvisioningIngredientType(itemType)
    return (ITEMTYPE_INGREDIENT ~= nil and itemType == ITEMTYPE_INGREDIENT)
        or (ITEMTYPE_FLAVORING ~= nil and itemType == ITEMTYPE_FLAVORING)
        or (ITEMTYPE_SPICE ~= nil and itemType == ITEMTYPE_SPICE)
end

local function AAW_ReadProvisioningSlotData(foundItems, bagId, bagName)
    if not bagId then
        return
    end

    if SHARED_INVENTORY and SHARED_INVENTORY.GenerateFullSlotData then
        local okShared, slotDataList = pcall(function()
            return SHARED_INVENTORY:GenerateFullSlotData(nil, bagId)
        end)

        if okShared and slotDataList then
            for _, slotData in pairs(slotDataList) do
                if AAW_IsProvisioningIngredientType(slotData.itemType) then
                    local itemName = slotData.name
                    if (not itemName or itemName == "") and slotData.itemLink and slotData.itemLink ~= "" and GetItemLinkName then
                        itemName = GetItemLinkName(slotData.itemLink)
                    end
                    AAW_AddItem(foundItems, itemName, slotData.stackCount or 0, slotData.itemType, bagName)
                end
            end
            return
        end
    end

    if type(GetBagSize) ~= "function" or type(GetItemType) ~= "function" then
        return
    end

    local bagSize = GetBagSize(bagId) or 0
    for slotIndex = 0, bagSize do
        local itemType = GetItemType(bagId, slotIndex)
        if AAW_IsProvisioningIngredientType(itemType) then
            local itemName = type(GetItemName) == "function" and GetItemName(bagId, slotIndex) or ""
            local stackCount = type(GetSlotStackSize) == "function" and GetSlotStackSize(bagId, slotIndex) or 0
            AAW_AddItem(foundItems, itemName, stackCount, itemType, bagName)
        end
    end
end

local function AAW_NormalizeProvisioningName(name)
    if type(name) ~= "string" then
        return nil
    end
    local trimmed = name:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed == "" then
        return nil
    end
    return string.lower(trimmed)
end

local function AAW_GetProvisioningIngredientName(listIndex, recipeIndex, ingredientIndex)
    if type(GetRecipeIngredientItemInfo) == "function" then
        local okInfo, ingredientName = pcall(GetRecipeIngredientItemInfo, listIndex, recipeIndex, ingredientIndex)
        if okInfo and type(ingredientName) == "string" and ingredientName ~= "" then
            return ingredientName
        end
    end

    if type(GetRecipeIngredientItemLink) == "function" then
        local okLink, itemLink = pcall(GetRecipeIngredientItemLink, listIndex, recipeIndex, ingredientIndex)
        if okLink and type(itemLink) == "string" and itemLink ~= "" then
            if type(GetItemLinkName) == "function" then
                local okName, itemName = pcall(GetItemLinkName, itemLink)
                if okName and type(itemName) == "string" and itemName ~= "" then
                    return itemName
                end
            end
        end
    end

    return nil
end

local function AAW_RefreshProvisioningIngredientKnowledge()
    local knowledge = AAW.provisioningIngredientKnowledge
    if knowledge.ready and not knowledge.dirty then
        return knowledge.catalog, knowledge.usedIngredients
    end

    knowledge.catalog = {}
    knowledge.usedIngredients = {}
    knowledge.ready = false

    if type(GetNumRecipeLists) ~= "function"
        or type(GetRecipeInfo) ~= "function"
        or type(GetNextKnownRecipeForCraftingStation) ~= "function"
        or CRAFTING_TYPE_PROVISIONING == nil then
        return knowledge.catalog, knowledge.usedIngredients
    end

    local okLists, numLists = pcall(GetNumRecipeLists)
    if not okLists or type(numLists) ~= "number" then
        return knowledge.catalog, knowledge.usedIngredients
    end

    -- Walk only ESO's known-recipe iterator. Never scan the sparse internal
    -- recipe-index range and never guess unknown recipe slots.
    for listIndex = 1, numLists do
        local lastRecipeIndex = nil
        while true do
            local okNext, recipeIndex = pcall(
                GetNextKnownRecipeForCraftingStation,
                listIndex,
                CRAFTING_TYPE_PROVISIONING,
                lastRecipeIndex
            )
            if not okNext or recipeIndex == nil or recipeIndex == lastRecipeIndex then
                break
            end
            lastRecipeIndex = recipeIndex

            local okInfo, recipeKnown, recipeName, numIngredients =
                pcall(GetRecipeInfo, listIndex, recipeIndex)
            if okInfo and recipeKnown == true and type(numIngredients) == "number" then
                local includeRecipe = true
                local resultLink = AAW_GetRecipeResultItemLinkSafe(listIndex, recipeIndex)
                local itemType = AAW_GetRecipeResultItemType(resultLink)
                if itemType ~= nil then
                    includeRecipe = AAW_IsFoodOrDrinkItemType(itemType)
                elseif type(recipeName) == "string" then
                    local lowerRecipeName = AAW_Lower(AAW_CleanName(recipeName))
                    includeRecipe = string.sub(lowerRecipeName, 1, 7) ~= "design:"
                end

                if includeRecipe then
                    for ingredientIndex = 1, numIngredients do
                        local ingredientName = AAW_GetProvisioningIngredientName(
                            listIndex, recipeIndex, ingredientIndex
                        )
                        local key = AAW_NormalizeProvisioningName(ingredientName)
                        if key then
                            knowledge.catalog[key] = knowledge.catalog[key] or ingredientName
                            knowledge.usedIngredients[key] = true
                        end
                    end
                end
            end
        end
    end

    knowledge.ready = true
    knowledge.dirty = false
    return knowledge.catalog, knowledge.usedIngredients
end

local function AAW_ScanProvisioningIngredientCatalog()
    local catalog = AAW_RefreshProvisioningIngredientKnowledge()
    return catalog
end

local function AAW_ScanProvisioningKnownRecipeNeeds()
    local _, usedIngredients = AAW_RefreshProvisioningIngredientKnowledge()
    return usedIngredients, 0
end

local function AAW_ScanProvisioningIngredients()
    local foundItems = {}
    AAW_ReadProvisioningSlotData(foundItems, BAG_BACKPACK, "Backpack")
    if BAG_BANK then
        AAW_ReadProvisioningSlotData(foundItems, BAG_BANK, "Bank")
    end
    if BAG_SUBSCRIBER_BANK and BAG_SUBSCRIBER_BANK ~= BAG_BANK then
        AAW_ReadProvisioningSlotData(foundItems, BAG_SUBSCRIBER_BANK, "Bank")
    end
    if BAG_VIRTUAL then
        AAW_ReadProvisioningSlotData(foundItems, BAG_VIRTUAL, "Craft Bag")
    end

    local items = {}
    local ownedByName = {}
    for _, item in pairs(foundItems) do
        local count = tonumber(item.count or 0) or 0
        table.insert(items, { name = item.name, count = count })
        local key = AAW_NormalizeProvisioningName(item.name)
        if key and count > 0 then
            ownedByName[key] = true
        end
    end

    table.sort(items, function(a, b)
        if a.count ~= b.count then
            return a.count < b.count
        end
        return string.lower(tostring(a.name)) < string.lower(tostring(b.name))
    end)

    local catalog = AAW_ScanProvisioningIngredientCatalog()
    local totalIngredients = 0
    local ownedIngredients = 0
    local missingIngredients = {}

    for key, displayName in pairs(catalog) do
        totalIngredients = totalIngredients + 1
        if ownedByName[key] then
            ownedIngredients = ownedIngredients + 1
        else
            table.insert(missingIngredients, displayName)
        end
    end

    table.sort(missingIngredients, function(a, b)
        return string.lower(tostring(a)) < string.lower(tostring(b))
    end)

    -- If the recipe catalog cannot be read, keep the working owned count visible.
    if totalIngredients <= 0 then
        totalIngredients = #items
        ownedIngredients = #items
    end

    AAW.state.provisioningIngredientTypes = ownedIngredients
    AAW.state.provisioningTotalIngredientTypes = totalIngredients
    AAW.state.provisioningLowestIngredients = items
    AAW.state.provisioningMissingIngredients = missingIngredients
    return ownedIngredients, totalIngredients, items, missingIngredients
end

local function AAW_FormatProvisioningPanel(showIntro)
    local lines = {}
    local playerName = AAW_GetPlayerName()
    local known, total = AAW_ScanProvisioningRecipes()
    local knowledgeOk, recipeKnowledge = AAW.RefreshRecipeKnowledgeLibrary()
    local ownedIngredients, totalIngredients, lowestIngredients = AAW_ScanProvisioningIngredients()
    local usedByKnownRecipes, recipesCanPrepare = AAW_ScanProvisioningKnownRecipeNeeds()

    if showIntro then
        table.insert(lines, "Welcome, " .. playerName .. ".")
        table.insert(lines, "I'm Aldren the Archivist.")
        table.insert(lines, "Let us look through your kitchen together.")
    else
        table.insert(lines, "Welcome back, " .. playerName .. ".")
        table.insert(lines, "Let us look through your pantry.")
    end

    table.insert(lines, "")
    if knowledgeOk then
        table.insert(lines, "Food & Drink: "
            .. tostring(recipeKnowledge.liveFoodDrinkKnown) .. "/"
            .. tostring(recipeKnowledge.foodDrinkKnowledgeCount) .. " learned.")
        table.insert(lines, "Furnishing Designs: "
            .. tostring(recipeKnowledge.knownDesigns) .. "/"
            .. tostring(recipeKnowledge.designKnowledgeCount) .. " learned.")
        if (recipeKnowledge.unresolvedKnownEntries or 0) > 0 then
            table.insert(lines, tostring(recipeKnowledge.unresolvedKnownEntries)
                .. " learned Provisioning entries still need careful classification.")
        end
    else
        table.insert(lines, "Aldren is still checking the Provisioning knowledge notes.")
    end

    table.insert(lines, "")
    table.insert(lines, "Pantry: " .. tostring(ownedIngredients) .. "/" .. tostring(totalIngredients) .. " different ingredients.")

    local usefulLowIngredients = {}
    for _, item in ipairs(lowestIngredients or {}) do
        local key = AAW_NormalizeProvisioningName(item.name)
        if key and usedByKnownRecipes[key] and (tonumber(item.count or 0) or 0) > 0 then
            table.insert(usefulLowIngredients, item)
        end
    end

    if #usefulLowIngredients > 0 then
        table.insert(lines, "")
        table.insert(lines, "The pantry is running low. A gathering trip may help.")
        table.insert(lines, "These ingredients are running low")
        table.insert(lines, "and are used in recipes you know:")
        local shown = math.min(#usefulLowIngredients, 5)
        for index = 1, shown do
            local item = usefulLowIngredients[index]
            table.insert(lines, "- " .. tostring(item.name) .. " (" .. tostring(item.count) .. ")")
        end
    else
        table.insert(lines, "")
        table.insert(lines, "Your known recipes are well supplied for now.")
    end


    return table.concat(lines, "\n")
end

local function AAW_FormatProvisioningSecondPageColumns()
    local _, totalIngredients, _, missingIngredients = AAW_ScanProvisioningIngredients()
    local knowledgeOk, library = AAW.RefreshRecipeKnowledgeLibrary()
    local left = {}
    local right = {}
    local missingCount = #(missingIngredients or {})

    table.insert(left, AAW_ALDREN_BLUE .. "Food & drink recipes I'm watching" .. AAW_COLOR_END)
    if not knowledgeOk then
        table.insert(left, "ESO's known-recipe notes were not ready to read.")
        table.insert(left, "I have stopped rather than guess.")
    elseif not library.completeArchiveReady then
        table.insert(left, "The verified recipe notes did not load safely.")
        table.insert(left, "I have stopped rather than guess.")
    elseif library.unknownCount <= 0 then
        table.insert(left, "Every recipe in my verified notes has been learned.")
    else
        for index, entry in ipairs(library.easiest or {}) do
            local coloredName = AAW_ColorizeVerifiedRecipeName(entry.name, entry.verifiedQuality)
            table.insert(left, tostring(index) .. ". " .. coloredName)
        end
    end

    table.insert(right, AAW_ALDREN_BLUE .. "Furnishing plans I'm watching" .. AAW_COLOR_END)
    if not knowledgeOk then
        table.insert(right, "ESO's known-recipe notes were not ready to read.")
        table.insert(right, "I have stopped rather than guess.")
    elseif not library.designArchiveReady then
        table.insert(right, "The verified furnishing notes did not load safely.")
        table.insert(right, "I have stopped rather than guess.")
    elseif library.unknownDesignCount <= 0 then
        table.insert(right, "Every furnishing plan in my verified notes has been learned.")
    else
        for index, entry in ipairs(library.watchedDesigns or {}) do
            table.insert(right, tostring(index) .. ". " .. tostring(entry.name or "Unknown furnishing plan"))
        end
    end

    table.insert(left, "")
    table.insert(right, "")

    if missingCount <= 0 then
        table.insert(left, AAW_ALDREN_BLUE .. "Missing ingredients" .. AAW_COLOR_END)
        table.insert(left, "Our pantry holds every ingredient used by the food and drink recipes we know.")
    else
        table.insert(left, AAW_ALDREN_BLUE .. "Missing ingredients" .. AAW_COLOR_END)
        table.insert(right, AAW_ALDREN_BLUE .. "Missing ingredients — continued" .. AAW_COLOR_END)

        local split = math.ceil(missingCount / 2)
        for index, ingredientName in ipairs(missingIngredients) do
            local line = tostring(index) .. ". " .. tostring(ingredientName)
            if index <= split then
                table.insert(left, line)
            else
                table.insert(right, line)
            end
        end
    end

    local noteLines = {}
    if knowledgeOk and library.achievementReady then
        table.insert(noteLines, "Recipe Compendium: "
            .. tostring(library.achievementKnown) .. "/" .. tostring(library.achievementRequired) .. ".")
    end
    table.insert(noteLines, "I have placed our recipe watch notes beside the pantry notes.")
    table.insert(noteLines, tostring(missingCount) .. " missing from "
        .. tostring(totalIngredients) .. " ingredients used by our learned recipes.")

    return table.concat(left, "\n"), table.concat(right, "\n"), table.concat(noteLines, "\n")
end

local function AAW_GetProvisioningWorkshopPageLabel()
    if (tonumber(AAW.state.provisioningWorkshopPage) or 1) == 2 then
        return "Pantry Guidance"
    end
    return "Recipes & Missing Ingredients"
end

local function AAW_EnsureProvisioningKeybinds()
    if AAW.provisioningUi.keybindStripDescriptor then return end

    AAW.provisioningUi.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = AAW_GetProvisioningWorkshopPageLabel,
            keybind = "UI_SHORTCUT_RIGHT_STICK",
            callback = function()
                local currentPage = tonumber(AAW.state.provisioningWorkshopPage) or 1
                AAW.state.provisioningWorkshopPage = currentPage == 1 and 2 or 1
                AAW.RefreshWorkshopPanel("provisioning page changed", false)
            end,
        },
    }
end

local function AAW_RemoveProvisioningKeybinds()
    if AAW.provisioningUi.keybindsVisible and KEYBIND_STRIP and AAW.provisioningUi.keybindStripDescriptor then
        pcall(function()
            KEYBIND_STRIP:RemoveKeybindButtonGroup(AAW.provisioningUi.keybindStripDescriptor)
        end)
    end
    AAW.provisioningUi.keybindsVisible = false
end

local function AAW_AddProvisioningKeybinds()
    if not KEYBIND_STRIP then return end
    AAW_EnsureProvisioningKeybinds()
    if not AAW.provisioningUi.keybindStripDescriptor then return end

    if AAW.provisioningUi.keybindsVisible then
        if KEYBIND_STRIP.UpdateKeybindButtonGroup then
            pcall(function()
                KEYBIND_STRIP:UpdateKeybindButtonGroup(AAW.provisioningUi.keybindStripDescriptor)
            end)
        end
        return
    end

    local ok = pcall(function()
        KEYBIND_STRIP:AddKeybindButtonGroup(AAW.provisioningUi.keybindStripDescriptor)
    end)
    AAW.provisioningUi.keybindsVisible = ok == true
end

local function AAW_FormatRecipeForPanel(recipe, farmRecipe, showIntro)
    local lines = {}

    local playerName = AAW_GetPlayerName()
    local traitLessonsComplete = AAW_AreAllKnownTraitLessonsComplete()

    if showIntro then
        table.insert(lines, "Welcome, " .. playerName .. ".")
        table.insert(lines, "I'm Aldren the Archivist.")
        table.insert(lines, "We will master alchemy together.")
        table.insert(lines, "Here is your first lesson.")
        table.insert(lines, "")
    else
        table.insert(lines, "Welcome back, " .. playerName .. ".")
        table.insert(lines, "Here is the next lesson.")
        table.insert(lines, "")
    end

    if recipe == nil then
        table.insert(lines, "I am checking your reagents...")
    elseif recipe.status == "not_enough_reagents" then
        table.insert(lines, "We need at least 2 reagents to begin.")
    elseif recipe.status == "no_solvent" then
        table.insert(lines, "We need a water or oil solvent to begin.")
    elseif recipe.status == "no_unknown_combo" then
        if traitLessonsComplete then
            table.insert(lines, "Congratulations, you have mastered alchemy.")
        else
            table.insert(lines, "We do not have the reagents needed to move forward in your training.")
            table.insert(lines, "Let us gather a few more reagents.")
        end
    elseif recipe.status == "ok" then
        table.insert(lines, "Make now:")
        if recipe.solvent then
            table.insert(lines, "Solvent: " .. recipe.solvent.name)
        else
            table.insert(lines, "Solvent: any water or oil")
        end
        table.insert(lines, "Reagents:")
        for index, reagent in ipairs(recipe.reagents or {}) do
            table.insert(lines, tostring(index) .. ") " .. tostring(reagent.name or "Unknown"))
        end
        table.insert(lines, "Learns: " .. tostring(recipe.score or 0) .. " trait(s)")
        table.insert(lines, "Lesson: " .. AAW_JoinNames(recipe.effects, 2))
    else
        table.insert(lines, "I found this note: " .. tostring(recipe.status))
    end

    table.insert(lines, "")
    if not traitLessonsComplete then
        table.insert(lines, AAW_FormatFarmTargetForPanel(farmRecipe))
    end

    return table.concat(lines, "\n")
end

local function AAW_SetLabel(label, text)
    if label and label.SetText then
        label:SetText(tostring(text or ""))
    end
end

function AAW.EnsureWorkshopWindow()
    if AAW.ui.created and AAW.ui.window then
        return true
    end

    if not WINDOW_MANAGER or type(WINDOW_MANAGER.CreateTopLevelWindow) ~= "function" then
        AAW_Message("UI TEST: WINDOW_MANAGER is missing. Cannot create workshop window.")
        return false
    end

    local ok = pcall(function()
        local wm = WINDOW_MANAGER
        local window = wm:CreateTopLevelWindow("AldrensAlchemyWorkshopWindow")

        -- v0.9.10 tall, narrow console panel.
        -- It hugs the right edge so the crafting lists and bottom controls stay visible.
        window:SetDimensions(430, 960)
        window:SetAnchor(RIGHT, GuiRoot, RIGHT, -20, -90)
        window:SetHidden(true)

        if window.SetClampedToScreen then
            window:SetClampedToScreen(true)
        end
        if window.SetDrawTier then
            window:SetDrawTier(DT_HIGH)
        end

        local backdrop = wm:CreateControl("AldrensAlchemyWorkshopWindowBackdrop", window, CT_BACKDROP)
        backdrop:SetAnchorFill(window)
        if backdrop.SetCenterColor then
            backdrop:SetCenterColor(0, 0, 0, 0.88)
        end
        if backdrop.SetEdgeColor then
            backdrop:SetEdgeColor(0.70, 0.90, 1, 1)
        end
        if backdrop.SetEdgeTexture then
            backdrop:SetEdgeTexture("EsoUI/Art/Miscellaneous/centerscreen_left.dds", 8, 1, 1)
        end

        local title = wm:CreateControl("AldrensAlchemyWorkshopWindowTitle", window, CT_LABEL)
        title:SetAnchor(TOPLEFT, window, TOPLEFT, 22, 18)
        title:SetDimensions(386, 86)
        title:SetFont("$(BOLD_FONT)|30|soft-shadow-thick")
        if title.SetColor then
            title:SetColor(0.70, 0.90, 1, 1)
        end
        if title.SetHorizontalAlignment and TEXT_ALIGN_CENTER then
            title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
        title:SetText("Aldren's Alchemy Workshop")

        -- These labels remain for compatibility with earlier builds, but they are hidden.
        -- The player-facing panel now only shows the title and Aldren's recipe guidance.
        local mode = wm:CreateControl("AldrensAlchemyWorkshopWindowMode", window, CT_LABEL)
        mode:SetHidden(true)

        local lab = wm:CreateControl("AldrensAlchemyWorkshopWindowLab", window, CT_LABEL)
        lab:SetHidden(true)

        local items = wm:CreateControl("AldrensAlchemyWorkshopWindowItems", window, CT_LABEL)
        items:SetHidden(true)

        local instruction = wm:CreateControl("AldrensAlchemyWorkshopWindowInstruction", window, CT_LABEL)
        instruction:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 18)
        instruction:SetDimensions(386, 660)
        instruction:SetFont("$(BOLD_FONT)|25|soft-shadow-thick")
        if instruction.SetColor then
            -- Soft lavender: gentler than white, not yellow, and keeps the blue title distinct.
            instruction:SetColor(0.86, 0.82, 1.00, 1)
        end
        if instruction.SetHorizontalAlignment and TEXT_ALIGN_LEFT then
            instruction:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        end

        local instructionRight = wm:CreateControl("AldrensAlchemyWorkshopWindowInstructionRight", window, CT_LABEL)
        instructionRight:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 548, 18)
        instructionRight:SetDimensions(520, 700)
        instructionRight:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
        if instructionRight.SetColor then
            instructionRight:SetColor(0.86, 0.82, 1.00, 1)
        end
        if instructionRight.SetHorizontalAlignment and TEXT_ALIGN_LEFT then
            instructionRight:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        end
        instructionRight:SetHidden(true)

        local grandmaster = wm:CreateControl("AldrensAlchemyWorkshopWindowGrandmaster", window, CT_LABEL)
        grandmaster:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 22, -18)
        grandmaster:SetDimensions(386, 110)
        grandmaster:SetFont("$(BOLD_FONT)|24|soft-shadow-thick")
        if grandmaster.SetColor then
            grandmaster:SetColor(0.70, 0.90, 1, 1)
        end
        if grandmaster.SetHorizontalAlignment and TEXT_ALIGN_LEFT then
            grandmaster:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        end

        AAW.ui.window = window
        AAW.ui.title = title
        AAW.ui.mode = mode
        AAW.ui.lab = lab
        AAW.ui.items = items
        AAW.ui.instruction = instruction
        AAW.ui.instructionRight = instructionRight
        AAW.ui.grandmaster = grandmaster
        AAW.ui.created = true
    end)

    if not ok then
        AAW_Message("UI TEST: workshop window failed to build safely.")
        return false
    end

    return true
end

local function AAW_ApplyStationLayout()
    local window = AAW.ui.window
    local title = AAW.ui.title
    local instruction = AAW.ui.instruction
    local instructionRight = AAW.ui.instructionRight
    local grandmaster = AAW.ui.grandmaster

    if not window then return end

    if window.ClearAnchors then window:ClearAnchors() end
    if title and title.ClearAnchors then title:ClearAnchors() end
    if instruction and instruction.ClearAnchors then instruction:ClearAnchors() end
    if instructionRight and instructionRight.ClearAnchors then instructionRight:ClearAnchors() end
    if grandmaster and grandmaster.ClearAnchors then grandmaster:ClearAnchors() end

    if instructionRight then instructionRight:SetHidden(true) end
    if grandmaster then grandmaster:SetHidden(false) end
    if instruction and instruction.SetFont then instruction:SetFont("$(BOLD_FONT)|25|soft-shadow-thick") end

    if AAW.state.currentStation == "alchemy" then
        window:SetDimensions(370, 690)
        window:SetAnchor(RIGHT, GuiRoot, RIGHT, -20, -145)
        title:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 16)
        title:SetDimensions(330, 64)
        instruction:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)
        instruction:SetDimensions(330, 425)
        grandmaster:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 20, -16)
        grandmaster:SetDimensions(330, 82)
    elseif AAW.state.currentStation == "jewelry" or AAW_RESEARCH_STATION_INFO[AAW.state.currentStation] then
        local completedResearch = false
        if AAW.state.currentStation == "jewelry" then
            AAW_ScanJewelryResearch()
            local research = AAW_GetResearchProfession("jewelry")
            completedResearch = research.total > 0 and research.known >= research.total
        elseif AAW_RESEARCH_STATION_INFO[AAW.state.currentStation] then
            AAW_ScanResearchProfession(AAW.state.currentStation)
            local research = AAW_GetResearchProfession(AAW.state.currentStation)
            completedResearch = research.total > 0 and research.known >= research.total
        end

        if completedResearch then
            window:SetDimensions(430, 360)
            window:SetAnchor(RIGHT, GuiRoot, RIGHT, -20, -80)
            title:SetAnchor(TOPLEFT, window, TOPLEFT, 22, 18)
            title:SetDimensions(386, 70)
            instruction:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)
            instruction:SetDimensions(386, 78)
            grandmaster:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 22, -18)
            grandmaster:SetDimensions(386, 90)
        else
            window:SetDimensions(430, 820)
            window:SetAnchor(RIGHT, GuiRoot, RIGHT, -20, -80)
            title:SetAnchor(TOPLEFT, window, TOPLEFT, 22, 18)
            title:SetDimensions(386, 80)
            instruction:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 14)
            instruction:SetDimensions(386, 520)
            grandmaster:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 22, -18)
            grandmaster:SetDimensions(386, 100)
        end
    elseif AAW.state.currentStation == "enchanting" then
        -- The expanded rune lesson needs a slightly smaller body font to remain
        -- inside the existing console-safe panel without covering ESO controls.
        window:SetDimensions(430, 960)
        window:SetAnchor(RIGHT, GuiRoot, RIGHT, -20, -90)
        title:SetAnchor(TOPLEFT, window, TOPLEFT, 22, 18)
        title:SetDimensions(386, 86)
        instruction:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 18)
        instruction:SetDimensions(386, 720)
        instruction:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
        grandmaster:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 22, -18)
        grandmaster:SetDimensions(386, 110)
    elseif AAW.state.currentStation == "provisioning" then
        local provisioningPage = tonumber(AAW.state.provisioningWorkshopPage) or 1
        if provisioningPage == 2 then
            -- The missing-pantry page deliberately takes most of the screen.
            -- It stays above ESO's lower gamepad controls and uses two large columns.
            window:SetDimensions(1120, 920)
            window:SetAnchor(TOP, GuiRoot, TOP, 0, 20)
            title:SetAnchor(TOPLEFT, window, TOPLEFT, 22, 18)
            title:SetDimensions(1076, 70)
            instruction:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 14)
            instruction:SetDimensions(520, 700)
            instruction:SetFont("$(BOLD_FONT)|20|soft-shadow-thick")
            if instructionRight then
                instructionRight:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 556, 14)
                instructionRight:SetDimensions(520, 700)
                instructionRight:SetFont("$(BOLD_FONT)|20|soft-shadow-thick")
                instructionRight:SetHidden(false)
            end
            grandmaster:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 22, -18)
            grandmaster:SetDimensions(1076, 78)
        else
            window:SetDimensions(430, 900)
            window:SetAnchor(RIGHT, GuiRoot, RIGHT, -20, -70)
            title:SetAnchor(TOPLEFT, window, TOPLEFT, 22, 18)
            title:SetDimensions(386, 80)
            instruction:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 14)
            instruction:SetDimensions(386, 610)
            grandmaster:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 22, -18)
            grandmaster:SetDimensions(386, 100)
        end
    else
        window:SetDimensions(430, 960)
        window:SetAnchor(RIGHT, GuiRoot, RIGHT, -20, -90)
        title:SetAnchor(TOPLEFT, window, TOPLEFT, 22, 18)
        title:SetDimensions(386, 86)
        instruction:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 18)
        instruction:SetDimensions(386, 720)
        grandmaster:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 22, -18)
        grandmaster:SetDimensions(386, 110)
    end
end

function AAW.UpdateWorkshopWindow(totalStacks, reagentCount, solventCount, recipe)
    if not AAW.EnsureWorkshopWindow() then
        return false
    end

    AAW_ApplyStationLayout()

    if AAW.state.currentStation == "jewelry" then
        AAW_SetLabel(AAW.ui.title, "Aldren's Jewelry Bench")
    elseif AAW.state.currentStation == "blacksmithing" then
        AAW_SetLabel(AAW.ui.title, "Aldren's Blacksmithing Forge")
    elseif AAW.state.currentStation == "clothing" then
        AAW_SetLabel(AAW.ui.title, "Aldren's Clothing Table")
    elseif AAW.state.currentStation == "woodworking" then
        AAW_SetLabel(AAW.ui.title, "Aldren's Woodworking Bench")
    elseif AAW.state.currentStation == "enchanting" then
        AAW_SetLabel(AAW.ui.title, "Aldren's Enchanting Desk")
    elseif AAW.state.currentStation == "provisioning" then
        if (tonumber(AAW.state.provisioningWorkshopPage) or 1) == 2 then
            AAW_SetLabel(AAW.ui.title, "Recipes & Ingredients We Still Need")
        else
            AAW_SetLabel(AAW.ui.title, "Aldren's Provisioning Kitchen")
        end
    else
        AAW_SetLabel(AAW.ui.title, "Aldren's Alchemy Workshop")
    end
    AAW_SetLabel(AAW.ui.mode, "")
    AAW_SetLabel(AAW.ui.lab, "")
    AAW_SetLabel(AAW.ui.items, "")
    AAW_SetLabel(AAW.ui.instructionRight, "")

    local showIntro = AAW_ShouldShowIntro()
    if AAW.state.currentStation == "jewelry" then
        AAW_SetLabel(AAW.ui.instruction, AAW_FormatJewelryPanel(showIntro))
    elseif AAW_RESEARCH_STATION_INFO[AAW.state.currentStation] then
        AAW_SetLabel(AAW.ui.instruction, AAW_FormatResearchProfessionPanel(AAW.state.currentStation, showIntro))
    elseif AAW.state.currentStation == "enchanting" then
        AAW_SetLabel(AAW.ui.instruction, AAW_FormatEnchantingPanel(showIntro))
    elseif AAW.state.currentStation == "provisioning" then
        if (tonumber(AAW.state.provisioningWorkshopPage) or 1) == 2 then
            local leftText, rightText, noteText = AAW_FormatProvisioningSecondPageColumns()
            AAW_SetLabel(AAW.ui.instruction, leftText)
            AAW_SetLabel(AAW.ui.instructionRight, rightText)
            AAW_SetLabel(AAW.ui.grandmaster, noteText)
        else
            AAW_SetLabel(AAW.ui.instruction, AAW_FormatProvisioningPanel(showIntro))
        end
    else
        AAW_SetLabel(AAW.ui.instruction, AAW_FormatRecipeForPanel(recipe or AAW.state.latestRecipe, AAW.state.latestFarmRecipe, showIntro))
    end
    if not (AAW.state.currentStation == "provisioning"
        and (tonumber(AAW.state.provisioningWorkshopPage) or 1) == 2) then
        AAW_SetLabel(AAW.ui.grandmaster, AAW_FormatGrandmasterNote())
    end

    if AAW.state.currentStation == "provisioning" then
        AAW_AddProvisioningKeybinds()
    else
        AAW_RemoveProvisioningKeybinds()
    end

    if showIntro then
        AAW_MarkIntroSeen()
    end

    return true
end

function AAW.ShowWorkshopWindow(totalStacks, reagentCount, solventCount, recipe)
    if AAW.UpdateWorkshopWindow(totalStacks, reagentCount, solventCount, recipe) and AAW.ui.window then
        AAW.ui.window:SetHidden(false)
        return true
    end

    return false
end

function AAW.HideWorkshopWindow()
    AAW_RemoveProvisioningKeybinds()
    if AAW.ui.window then
        AAW.ui.window:SetHidden(true)
    end
end

function AAW.RunWorkshopScan(reason, showMessages)
    if AAW.state.currentStation == "provisioning" then
        if showMessages then
            AAW_Message("WORKSHOP: provisioning station detected.")
        end
        return {}, 0, 0, 0, nil
    end

    if AAW.state.currentStation == "enchanting" then
        local foundItems, totalStacks, potencyCount, essenceCount, aspectCount = AAW.ScanEnchantingItems(showMessages)
        AAW.state.latestEnchantingItems = foundItems
        AAW.state.latestEnchantingTotalStacks = totalStacks
        AAW.state.latestPotencyRuneCount = potencyCount
        AAW.state.latestEssenceRuneCount = essenceCount
        AAW.state.latestAspectRuneCount = aspectCount
        AAW_RefreshKnownRuneTranslationsFromFoundItems(foundItems)
        AAW.state.latestRuneLesson = AAW.FindBestEnchantingRuneLesson(foundItems)

        if showMessages then
            AAW_Message("WORKSHOP: enchanting station scan complete.")
        end

        return foundItems, totalStacks, potencyCount, essenceCount, nil
    end

    -- Keep this check in. It is tiny, and it keeps the recipe mode correct
    -- if the player spends a skill point in Laboratory Use during the session.
    AAW.RefreshLaboratoryUse(showMessages, reason or "workshop")

    local foundItems, totalStacks, reagentCount, solventCount = AAW.ScanAlchemyItems(showMessages)
    local recipe = AAW.FindBestLearningRecipe(foundItems)
    local farmRecipe = AAW.FindBestFarmTargetRecipe(foundItems)
    AAW.state.latestFoundItems = foundItems
    AAW.state.latestRecipe = recipe
    AAW.state.latestFarmRecipe = farmRecipe

    if showMessages then
        AAW_Message("WORKSHOP: recipe mode is " .. AAW_GetRecipeModeText() .. ".")
        if recipe and recipe.status == "ok" then
            AAW_Message("RECIPE TEST: suggested " .. tostring(#recipe.reagents) .. " reagents, learns " .. tostring(recipe.score or 0) .. " trait(s).")
        elseif recipe then
            AAW_Message("RECIPE TEST: " .. tostring(recipe.status) .. ".")
        end
        if farmRecipe and farmRecipe.status == "ok" then
            AAW_Message("FARM TEST: target has " .. tostring(farmRecipe.missingCount or 0) .. " missing reagent(s), would learn " .. tostring(farmRecipe.score or 0) .. " trait(s).")
        elseif farmRecipe then
            AAW_Message("FARM TEST: " .. tostring(farmRecipe.status) .. ".")
        end
    end

    return foundItems, totalStacks, reagentCount, solventCount, recipe
end

function AAW.RefreshWorkshopPanel(reason, showMessages)
    local foundItems, totalStacks, reagentCount, solventCount, recipe = AAW.RunWorkshopScan(reason or "refresh", showMessages == true)
    AAW.state.refreshCount = (AAW.state.refreshCount or 0) + 1
    AAW.ShowWorkshopWindow(totalStacks, reagentCount, solventCount, recipe)
    return recipe
end

function AAW.QueueWorkshopRefresh(reason)
    if AAW.state.craftRefreshQueued then
        return
    end

    AAW.state.craftRefreshQueued = true

    local function DoRefresh()
        AAW.state.craftRefreshQueued = false

        if not AAW.state.isAtSupportedCraftingStation then
            return
        end

        AAW.RefreshWorkshopPanel(reason or "queued refresh", false)
    end

    if type(zo_callLater) == "function" then
        zo_callLater(DoRefresh, 800)
    else
        DoRefresh()
    end
end

function AAW.RunManualCheck()
    AAW_Message("VERSION TEST: /aaw is running v" .. AAW.version .. ".")
    AAW.RefreshLaboratoryUse(true, "manual /aaw")
    AAW.state.currentStation = "alchemy"
    AAW.state.isAtAlchemyStation = true
    AAW.state.isAtSupportedCraftingStation = true
    AAW.RefreshWorkshopPanel("manual /aaw", true)
    AAW_Message("UI TEST: manual /aaw showed the workshop window.")
end

function AAW.RunRuneSyncTest()
    AAW.state.currentStation = "enchanting"
    AAW.state.isAtEnchantingStation = true
    AAW.state.isAtSupportedCraftingStation = true

    local foundItems, totalStacks, potencyCount, essenceCount, aspectCount = AAW.ScanEnchantingItems(false)
    local beforeKnown, beforeTotal = AAW_GetEnchantingProgress()

    for _, item in pairs(foundItems or {}) do
        AAW_IsRuneKnown(item)
    end

    local afterDirectKnown, afterDirectTotal = AAW_GetEnchantingProgress()
    local marked, tested, status = AAW_TryInferKnownRuneTranslationsFromCombos(foundItems)
    local afterComboKnown, afterComboTotal = AAW_GetEnchantingProgress()

    AAW_Message("RUNE SYNC TEST v" .. AAW.version .. ": checked " .. tostring(totalStacks or 0) .. " rune stack(s).")
    AAW_Message("RUNE SYNC TEST: pouch has " .. tostring(potencyCount or 0) .. " potency, " .. tostring(essenceCount or 0) .. " essence, " .. tostring(aspectCount or 0) .. " aspect.")
    AAW_Message("RUNE SYNC TEST: AreAllEnchantingRunesKnown=" .. tostring(type(AreAllEnchantingRunesKnown) == "function") .. ".")
    AAW_Message("RUNE SYNC TEST: direct sync " .. tostring(beforeKnown) .. "/" .. tostring(beforeTotal) .. " -> " .. tostring(afterDirectKnown) .. "/" .. tostring(afterDirectTotal) .. ".")
    AAW_Message("RUNE SYNC TEST: combo sync marked " .. tostring(marked or 0) .. " rune(s), tested " .. tostring(tested or 0) .. ", status " .. tostring(status or "unknown") .. ".")
    AAW_Message("RUNE SYNC TEST: final progress " .. tostring(afterComboKnown) .. "/" .. tostring(afterComboTotal) .. ".")
    AAW.RefreshWorkshopPanel("manual rune sync", false)
end

local function AAW_OnCraftingStationInteract(eventCode, craftingType, sameStation)
    if AAW_IsAlchemyCraftingType(craftingType) then
        AAW.state.currentStation = "alchemy"
        AAW.state.isAtAlchemyStation = true
        AAW.state.isAtEnchantingStation = false
        AAW.state.isAtProvisioningStation = false
        AAW.state.isAtSupportedCraftingStation = true
        AAW.RefreshWorkshopPanel("alchemy station", false)
    elseif AAW_IsEnchantingCraftingType(craftingType) then
        AAW.state.currentStation = "enchanting"
        AAW.state.isAtAlchemyStation = false
        AAW.state.isAtEnchantingStation = true
        AAW.state.isAtProvisioningStation = false
        AAW.state.isAtSupportedCraftingStation = true
        AAW.RefreshWorkshopPanel("enchanting station", false)
    elseif AAW_IsJewelryCraftingType(craftingType) then
        AAW.state.currentStation = "jewelry"
        AAW.state.isAtAlchemyStation = false
        AAW.state.isAtEnchantingStation = false
        AAW.state.isAtProvisioningStation = false
        AAW.state.isAtJewelryStation = true
        AAW.state.isAtSupportedCraftingStation = true
        AAW.RefreshWorkshopPanel("jewelry station", false)
    elseif AAW_IsBlacksmithingCraftingType(craftingType) then
        AAW.state.currentStation = "blacksmithing"
        AAW.state.isAtSupportedCraftingStation = true
        AAW.state.isAtBlacksmithingStation = true
        AAW.RefreshWorkshopPanel("blacksmithing station", false)
    elseif AAW_IsClothingCraftingType(craftingType) then
        AAW.state.currentStation = "clothing"
        AAW.state.isAtSupportedCraftingStation = true
        AAW.state.isAtClothingStation = true
        AAW.RefreshWorkshopPanel("clothing station", false)
    elseif AAW_IsWoodworkingCraftingType(craftingType) then
        AAW.state.currentStation = "woodworking"
        AAW.state.isAtSupportedCraftingStation = true
        AAW.state.isAtWoodworkingStation = true
        AAW.RefreshWorkshopPanel("woodworking station", false)
    elseif AAW_IsProvisioningCraftingType(craftingType) then
        AAW.state.currentStation = "provisioning"
        AAW.state.provisioningWorkshopPage = 1
        AAW.state.isAtAlchemyStation = false
        AAW.state.isAtEnchantingStation = false
        AAW.state.isAtProvisioningStation = true
        AAW.state.isAtSupportedCraftingStation = true
        AAW.RefreshWorkshopPanel("provisioning station", false)
    end
end

local function AAW_OnEndCraftingStationInteract(eventCode, craftingType)
    if AAW_IsSupportedCraftingType(craftingType) or AAW.state.isAtSupportedCraftingStation then
        AAW.state.isAtAlchemyStation = false
        AAW.state.isAtEnchantingStation = false
        AAW.state.isAtProvisioningStation = false
        AAW.state.isAtJewelryStation = false
        AAW.state.isAtBlacksmithingStation = false
        AAW.state.isAtClothingStation = false
        AAW.state.isAtWoodworkingStation = false
        AAW.state.isAtSupportedCraftingStation = false
        AAW.state.currentStation = "none"
        AAW.state.provisioningWorkshopPage = 1
        AAW.state.craftRefreshQueued = false
        AAW.HideWorkshopWindow()
    end
end

local function AAW_OnCraftCompleted(eventCode, craftingType)
    if AAW.state.isAtEnchantingStation then
        AAW_MarkLatestRuneLessonKnown()
    end

    if AAW.state.isAtSupportedCraftingStation then
        AAW.QueueWorkshopRefresh("craft completed")
    end
end

local function AAW_OnInventorySingleSlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- A bank visit can change after Aldren first looks. Refresh his memory when
    -- items move, so using or withdrawing the last scroll clears the old note.
    if AAW.state.isBankOpen and not AAW.state.bankRefreshQueued then
        AAW.state.bankRefreshQueued = true
        local function refreshBankMemory()
            AAW.state.bankRefreshQueued = false
            if AAW.state.isBankOpen then
                AAW_RememberBankResearchScrolls()
            end
        end
        if type(zo_callLater) == "function" then
            zo_callLater(refreshBankMemory, 300)
        else
            refreshBankMemory()
        end
    end

    if AAW.state.isAtEnchantingStation then
        -- On console, enchanting may refresh through inventory changes instead of
        -- EVENT_CRAFT_COMPLETED. If the suggested glyph was just made, mark those
        -- three runes as translated before Aldren chooses the next lesson.
        AAW_MarkLatestRuneLessonKnown()
    end

    if AAW.state.isAtSupportedCraftingStation then
        AAW.QueueWorkshopRefresh("inventory update")
    end
end

local function AAW_OnResearchChanged(eventCode, ...)
    -- Step Seven: keep the visible Research Brain current while the player
    -- remains at a research bench. ESO can report a research start, finish,
    -- cancellation, or timer change without a normal crafting completion.
    -- A short queued refresh lets the game finish updating its research data
    -- before Aldren reads it again.
    local station = AAW.state.currentStation
    if station == "jewelry"
        or station == "blacksmithing"
        or station == "clothing"
        or station == "woodworking" then
        AAW.QueueWorkshopRefresh("research changed")
    end
end

local function AAW_OnSkillChanged(eventCode, ...)
    -- Skill points can change while the character is still logged in.
    -- When that happens, refresh Laboratory Use and update the visible panel.
    AAW.RefreshLaboratoryUse(false, "skill changed")

    if AAW.state.isAtSupportedCraftingStation then
        AAW.RefreshWorkshopPanel("skill changed", false)
    else
    end
end

local AAW_InstallJournalMenuEntry

local function AAW_OnPlayerActivated()
    AAW_LoadSavedLaboratoryUse()
    if AAW_InstallJournalMenuEntry then
        AAW_InstallJournalMenuEntry()
    end

    if not AAW.state.loginLabChecked then
        -- Quiet login check. The player does not need to see this in the final version.
        AAW.RefreshLaboratoryUse(false, "login")
    end

    -- Do not rebuild the complete Provisioning knowledge snapshot here. ESO fires
    -- PLAYER_ACTIVATED after every zone change, and the old full scan could exhaust
    -- the PS5 add-on CPU budget. Aldren refreshes this snapshot only when the player
    -- opens the Provisioning panel or Journal recipe page, or after learning a recipe.
end

local function AAW_OnOpenBank()
    AAW.state.isBankOpen = true
    if type(zo_callLater) == "function" then
        zo_callLater(AAW_RememberBankResearchScrolls, 500)
    else
        AAW_RememberBankResearchScrolls()
    end
end

local function AAW_OnCloseBank()
    -- Take one last look before the bank bags become unavailable. An empty scan
    -- deliberately clears earlier memories instead of leaving a stale count.
    AAW_RememberBankResearchScrolls()
    AAW.state.isBankOpen = false
    AAW.state.bankRefreshQueued = false
end

local function AAW_RegisterCraftingEvents()
    if EVENT_CRAFTING_STATION_INTERACT then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "CraftingStationInteract", EVENT_CRAFTING_STATION_INTERACT, AAW_OnCraftingStationInteract)
    else
    end

    if EVENT_END_CRAFTING_STATION_INTERACT then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "EndCraftingStationInteract", EVENT_END_CRAFTING_STATION_INTERACT, AAW_OnEndCraftingStationInteract)
    end

    if EVENT_CRAFT_COMPLETED then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "CraftCompleted", EVENT_CRAFT_COMPLETED, AAW_OnCraftCompleted)
    else
    end

    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "InventorySlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, AAW_OnInventorySingleSlotUpdate)
    end

    if EVENT_SKILL_POINTS_CHANGED then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "SkillPointsChanged", EVENT_SKILL_POINTS_CHANGED, AAW_OnSkillChanged)
    end

    if EVENT_OPEN_BANK then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "OpenBank", EVENT_OPEN_BANK, AAW_OnOpenBank)
    end

    if EVENT_CLOSE_BANK then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "CloseBank", EVENT_CLOSE_BANK, AAW_OnCloseBank)
    end

    if EVENT_SKILL_ABILITY_PROGRESSIONS_UPDATED then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "SkillProgressionsUpdated", EVENT_SKILL_ABILITY_PROGRESSIONS_UPDATED, AAW_OnSkillChanged)
    end


    -- Research events differ slightly across ESO API versions, so each one is
    -- registered only when the client exposes it. They all use the same gentle
    -- queued refresh and do not alter any research data themselves.
    if EVENT_SMITHING_TRAIT_RESEARCH_STARTED then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "ResearchStarted", EVENT_SMITHING_TRAIT_RESEARCH_STARTED, AAW_OnResearchChanged)
    end
    if EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "ResearchCompleted", EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, AAW_OnResearchChanged)
    end
    if EVENT_SMITHING_TRAIT_RESEARCH_CANCELED then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "ResearchCanceled", EVENT_SMITHING_TRAIT_RESEARCH_CANCELED, AAW_OnResearchChanged)
    end
    if EVENT_SMITHING_TRAIT_RESEARCH_TIMES_UPDATED then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "ResearchTimesUpdated", EVENT_SMITHING_TRAIT_RESEARCH_TIMES_UPDATED, AAW_OnResearchChanged)
    end
end


-- Aldren's Grandmaster Journal.
-- The native Scene opens on a Grand Master Crafter checklist cover.
-- Aldren's existing profession Journey remains Page 1.
local AAW_JOURNAL_SCENE_NAME = "aldrenGrandmasterJournal"

AAW.journal = {
    created = false,
    sceneName = AAW_JOURNAL_SCENE_NAME,
    scene = nil,
    fragment = nil,
    control = nil,
    title = nil,
    subtitle = nil,
    pageTitle = nil,
    pageBackdrop = nil,
    body = nil,
    checklistRows = {},
    recipeLeft = nil,
    recipeRight = nil,
    footer = nil,
    keybindStripDescriptor = nil,
    keybindsVisible = false,
    currentGreeting = nil,
    currentPage = 0,
    menuEntryInstalled = false,
    menuInstallAttempts = 0,
}

-- Compatibility name for any older internal references. The Journal is now a Scene,
-- not a floating progress window.
AAW.progressUi = AAW.journal


local function AAW_JournalProfessionEntry(entry)
    local label = entry.label
    local known = tonumber(entry.known) or 0
    local total = tonumber(entry.total) or 0
    local verb = entry.verb or "completed"
    local noun = entry.noun or "lessons"
    local heading = AAW_ALDREN_BLUE .. label .. AAW_COLOR_END

    if total <= 0 then
        return heading .. "\nI am still checking these notes carefully."
    end

    if known >= total then
        if label == "Woodworking" then
            return heading .. " — Mastered together — all " .. tostring(total) .. " " .. noun .. " " .. verb .. "."
        end
        return heading .. "\nMastered together — all " .. tostring(total) .. " " .. noun .. " " .. verb .. "."
    end

    return heading .. "\nWe have " .. verb .. " " .. tostring(known) .. " of " .. tostring(total) .. " " .. noun .. "."
end

local function AAW_IsJournalProfessionComplete(entry)
    local known = tonumber(entry.known) or 0
    local total = tonumber(entry.total) or 0
    return total > 0 and known >= total
end

local AAW_JOURNAL_GREETINGS = {
    "Welcome back, %s.\nI have been keeping careful notes on everything we have learned together.",
    "Ah, there you are, %s.\nI have been organizing our discoveries while you were away.",
    "Welcome, %s.\nEvery lesson brings us a little closer to mastery.",
    "It is good to see you again, %s.\nLet us remember how much we have already learned.",
}

local function AAW_NextJournalGreeting()
    AAW.journalGreetingIndex = (tonumber(AAW.journalGreetingIndex) or 0) + 1
    if AAW.journalGreetingIndex > #AAW_JOURNAL_GREETINGS then
        AAW.journalGreetingIndex = 1
    end
    local template = AAW_JOURNAL_GREETINGS[AAW.journalGreetingIndex]
    return string.format(template, AAW_GetPlayerName())
end

local function AAW_BuildJourneyText(chooseNewGreeting)
    local lines = {}
    local alchemyKnown, alchemyTotal = AAW_GetAlchemyLessonProgress()
    local enchantingKnown, enchantingTotal = AAW_GetEnchantingProgress()
    local provisioningKnown, provisioningTotal = AAW_ScanProvisioningRecipes()

    AAW_ScanJewelryResearch()
    AAW_ScanResearchProfession("blacksmithing")
    AAW_ScanResearchProfession("clothing")
    AAW_ScanResearchProfession("woodworking")

    local jewelry = AAW_GetResearchProfession("jewelry")
    local blacksmithing = AAW_GetResearchProfession("blacksmithing")
    local clothing = AAW_GetResearchProfession("clothing")
    local woodworking = AAW_GetResearchProfession("woodworking")

    local professions = {
        { label = "Alchemy", known = alchemyKnown, total = alchemyTotal, verb = "learned", noun = "reagent traits" },
        { label = "Blacksmithing", known = blacksmithing.known, total = blacksmithing.total, verb = "researched", noun = "traits" },
        { label = "Clothing", known = clothing.known, total = clothing.total, verb = "researched", noun = "traits" },
        { label = "Enchanting", known = enchantingKnown, total = enchantingTotal, verb = "translated", noun = "runes" },
        { label = "Jewelry Crafting", known = jewelry.known, total = jewelry.total, verb = "researched", noun = "traits" },
        { label = "Provisioning", known = provisioningKnown, total = provisioningTotal, verb = "learned", noun = "recipes" },
        { label = "Woodworking", known = woodworking.known, total = woodworking.total, verb = "researched", noun = "traits" },
    }

    local active = {}
    local completed = {}
    for _, entry in ipairs(professions) do
        if AAW_IsJournalProfessionComplete(entry) then
            table.insert(completed, entry)
        else
            table.insert(active, entry)
        end
    end

    local function SortByProfessionName(left, right)
        return left.label < right.label
    end
    table.sort(active, SortByProfessionName)
    table.sort(completed, SortByProfessionName)

    if chooseNewGreeting or not AAW.journal.currentGreeting then
        AAW.journal.currentGreeting = AAW_NextJournalGreeting()
    end

    table.insert(lines, AAW.journal.currentGreeting)

    if #active > 0 then
        table.insert(lines, "")
        table.insert(lines, AAW_ALDREN_BLUE .. "Still learning" .. AAW_COLOR_END)
        for _, entry in ipairs(active) do
            table.insert(lines, AAW_JournalProfessionEntry(entry))
        end
    end

    if #completed > 0 then
        table.insert(lines, "")
        table.insert(lines, AAW_ALDREN_BLUE .. "Completed lessons" .. AAW_COLOR_END)
        for _, entry in ipairs(completed) do
            table.insert(lines, AAW_JournalProfessionEntry(entry))
        end
    end

    return table.concat(lines, "\n")
end


local function AAW_BuildAlchemyJournalText()
    local lines = {
        "Alchemy rewards patience. We shall learn one safe mixture at a time.",
        "",
    }

    if type(AAW.RefreshLaboratoryUse) == "function" then
        pcall(AAW.RefreshLaboratoryUse, false, "journal")
    end

    local foundItems = {}
    if type(AAW.ScanAlchemyItems) == "function" then
        foundItems = select(1, AAW.ScanAlchemyItems(false)) or {}
    end

    local recipe = AAW.FindBestLearningRecipe(foundItems)
    local farmRecipe = AAW.FindBestFarmTargetRecipe(foundItems)
    AAW.state.latestFoundItems = foundItems
    AAW.state.latestRecipe = recipe
    AAW.state.latestFarmRecipe = farmRecipe

    local known, total = AAW_GetAlchemyLessonProgress()
    table.insert(lines, AAW_ALDREN_BLUE .. "Reagent lessons" .. AAW_COLOR_END)
    table.insert(lines, tostring(known) .. "/" .. tostring(total) .. " reagent traits learned.")

    if total > 0 and known >= total then
        table.insert(lines, "")
        table.insert(lines, "Congratulations. Every reagent trait in my notes has been learned.")
        table.insert(lines, "There is no new lesson to force. We may simply enjoy the craft.")
        return table.concat(lines, "\n")
    end

    table.insert(lines, "")
    table.insert(lines, AAW_ALDREN_BLUE .. "Next lesson" .. AAW_COLOR_END)

    if not recipe then
        table.insert(lines, "I am still checking the reagents we can safely use.")
    elseif recipe.status == "ok" then
        local reagentNames = {}
        for _, reagent in ipairs(recipe.reagents or {}) do
            table.insert(reagentNames, tostring(reagent.name or "Unknown reagent"))
        end
        table.insert(lines, "Make a potion with " .. tostring(recipe.solvent and recipe.solvent.name or "any suitable solvent") .. ".")
        table.insert(lines, "Reagents: " .. table.concat(reagentNames, ", ") .. ".")
        table.insert(lines, "May reveal " .. tostring(recipe.score or 0) .. " trait(s): " .. AAW_JoinNames(recipe.effects, 2) .. ".")
    elseif recipe.status == "not_enough_reagents" then
        table.insert(lines, "We need at least two suitable reagents before the next lesson.")
    elseif recipe.status == "no_solvent" then
        table.insert(lines, "We have the reagents, but we still need a water or oil solvent.")
    elseif recipe.status == "no_unknown_combo" then
        table.insert(lines, "The reagents we hold do not reveal a new trait yet.")
    else
        table.insert(lines, "I have stopped this lesson until the reagent notes are clear.")
    end

    local gatherLine = nil
    if farmRecipe and farmRecipe.status == "ok" and #(farmRecipe.missing or {}) > 0 then
        gatherLine = AAW_JoinNames(farmRecipe.missing, 3)
    else
        gatherLine = AAW_GetGatherSuggestionLine(foundItems)
    end

    if gatherLine then
        table.insert(lines, "")
        table.insert(lines, AAW_ALDREN_BLUE .. "Gather next" .. AAW_COLOR_END)
        table.insert(lines, tostring(gatherLine) .. ".")
        table.insert(lines, "These reagents may open the next useful lesson.")
    end

    return table.concat(lines, "\n")
end

local function AAW_BuildEnchantingJournalText()
    local foundItems, _, potencyCount, essenceCount, aspectCount = AAW.ScanEnchantingItems(false)
    foundItems = foundItems or {}
    AAW_RefreshKnownRuneTranslationsFromFoundItems(foundItems)

    local lesson = AAW.FindBestEnchantingRuneLesson(foundItems)
    AAW.state.latestEnchantingItems = foundItems
    AAW.state.latestPotencyRuneCount = potencyCount or 0
    AAW.state.latestEssenceRuneCount = essenceCount or 0
    AAW.state.latestAspectRuneCount = aspectCount or 0
    AAW.state.latestRuneLesson = lesson

    local progress = AAW_GetEnchantingProgressBreakdown()
    local completedPotency, requiredPotency = AAW_GetGrandmasterPotencyProgress()
    local lines = {
        "Every glyph is a sentence. We shall translate it one rune at a time.",
        "",
        AAW_ALDREN_BLUE .. "Translation record" .. AAW_COLOR_END,
        "Positive Potency: " .. tostring(progress.positiveKnown) .. "/" .. tostring(progress.positiveTotal) .. ".",
        "Negative Potency: " .. tostring(progress.negativeKnown) .. "/" .. tostring(progress.negativeTotal) .. ".",
        "Potency achievement groups: " .. tostring(completedPotency) .. "/" .. tostring(requiredPotency) .. ".",
        "All rune translations: " .. tostring(progress.allKnown) .. "/" .. tostring(progress.allTotal) .. ".",
        "",
        AAW_ALDREN_BLUE .. "Rune pouch — distinct types held" .. AAW_COLOR_END,
        "Potency: " .. tostring(potencyCount or 0) .. "/" .. tostring(progress.potencyTotal) .. ".",
        "Essence: " .. tostring(essenceCount or 0) .. "/" .. tostring(progress.essenceTotal) .. ".",
        "Aspect: " .. tostring(aspectCount or 0) .. "/" .. tostring(progress.aspectTotal) .. ".",
        "",
        AAW_FormatRuneLesson(lesson),
        "",
        AAW_FormatMissingEnchantingRunes(foundItems),
    }

    return table.concat(lines, "\n")
end

local function AAW_BuildProvisioningJournalText()
    AAW_ScanProvisioningRecipes()
    local knowledgeOk, library = AAW.RefreshRecipeKnowledgeLibrary()
    local ownedIngredients, totalIngredients, _, missingIngredients = AAW_ScanProvisioningIngredients()
    local missingCount = #(missingIngredients or {})
    local lines = {
        "A well-kept kitchen remembers both what we know and what we still need.",
        "",
        AAW_ALDREN_BLUE .. "Recipe archive" .. AAW_COLOR_END,
    }

    if not knowledgeOk then
        table.insert(lines, "ESO's recipe notes are not ready to read safely.")
        table.insert(lines, "I have stopped rather than guess.")
        return table.concat(lines, "\n")
    end

    table.insert(lines, "Food & drink recipes learned: "
        .. tostring(library.liveFoodDrinkKnown or 0) .. "/"
        .. tostring(library.foodDrinkKnowledgeCount or 0) .. ".")
    table.insert(lines, "Furnishing designs learned: "
        .. tostring(library.knownDesigns or 0) .. "/"
        .. tostring(library.designKnowledgeCount or 0) .. ".")

    if library.achievementReady then
        table.insert(lines, "Recipe Compendium: "
            .. tostring(library.achievementKnown or 0) .. "/"
            .. tostring(library.achievementRequired or AAW_RECIPE_COMPENDIUM_REQUIRED) .. ".")
    else
        table.insert(lines, "Recipe Compendium: ESO is still opening that achievement note.")
    end

    if library.completeArchiveReady then
        table.insert(lines, tostring(library.unknownCount or 0)
            .. " verified food & drink recipes remain unlearned.")
    else
        table.insert(lines, "The verified food & drink archive did not load safely.")
    end

    table.insert(lines, "")
    table.insert(lines, AAW_ALDREN_BLUE .. "Pantry record" .. AAW_COLOR_END)
    table.insert(lines, tostring(ownedIngredients or 0) .. "/" .. tostring(totalIngredients or 0)
        .. " ingredient types used by learned recipes are currently held.")

    if missingCount > 0 then
        table.insert(lines, tostring(missingCount)
            .. " ingredient types used by learned recipes are missing.")
    else
        table.insert(lines, "Every ingredient used by our learned recipes is currently present.")
    end

    table.insert(lines, "")
    table.insert(lines, "The five recipe choices, five furnishing plans, and exact pantry list")
    table.insert(lines, "remain on Provisioning page two, where they are most useful.")

    return table.concat(lines, "\n")
end

local function AAW_GetJournalResearchSuggestion(research)
    local best = nil
    for _, category in ipairs((research and research.categories) or {}) do
        local remaining = math.max(0, tonumber(category.remaining) or 0)
        local active = math.max(0, tonumber(category.active) or 0)
        if remaining > 0 and active == 0 then
            if not best
                or remaining > (best.remaining or 0)
                or (remaining == (best.remaining or 0) and tostring(category.item) < tostring(best.item)) then
                best = category
            end
        end
    end

    if not best then
        return nil, nil
    end

    local suggestedTrait = nil
    for _, traitName in ipairs(best.availableTraits or {}) do
        if not suggestedTrait or tostring(traitName) < tostring(suggestedTrait) then
            suggestedTrait = traitName
        end
    end

    return best, suggestedTrait
end

local AAW_RESEARCH_JOURNAL_GREETINGS = {
    jewelry = "A fine setting begins with patience. Let us give each small detail its proper care.",
    blacksmithing = "Good steel remembers every careful strike. We shall shape the next lesson with purpose.",
    clothing = "Every strong seam begins with a measured hand. Let us continue without haste.",
    woodworking = "The grain will guide us when we listen closely. One thoughtful cut is enough for today.",
}

local function AAW_BuildResearchJournalText(profession)
    local displayName = profession == "jewelry" and "Jewelry Crafting"
        or ((AAW_RESEARCH_STATION_INFO[profession] and AAW_RESEARCH_STATION_INFO[profession].display) or profession)

    if profession == "jewelry" then
        AAW_ScanJewelryResearch()
    else
        AAW_ScanResearchProfession(profession)
    end

    local research = AAW_GetResearchProfession(profession)
    local remaining = math.max(0, (tonumber(research.total) or 0) - (tonumber(research.known) or 0))
    local lines = {
        AAW_RESEARCH_JOURNAL_GREETINGS[profession]
            or "Research is slow work, but no careful lesson is ever wasted.",
        "",
        AAW_ALDREN_BLUE .. displayName .. " record" .. AAW_COLOR_END,
        "Traits researched: " .. tostring(research.known or 0) .. "/" .. tostring(research.total or 0) .. ".",
        "Traits remaining: " .. tostring(remaining) .. ".",
    }

    if (tonumber(research.total) or 0) > 0 and remaining <= 0 then
        table.insert(lines, "")
        table.insert(lines, "Congratulations. Every " .. displayName .. " research lesson is complete.")
        table.insert(lines, "This chapter may rest quietly among our finished notes.")
        return table.concat(lines, "\n")
    end

    local used = math.max(0, tonumber(research.active) or 0)
    local limit = math.max(0, tonumber(research.slotLimit) or 0)
    table.insert(lines, "")
    table.insert(lines, AAW_ALDREN_BLUE .. "Research bench" .. AAW_COLOR_END)
    if limit > 0 then
        table.insert(lines, "Research slots: " .. tostring(used) .. "/" .. tostring(limit) .. " in use.")
    else
        table.insert(lines, "Active research projects: " .. tostring(used) .. ".")
    end

    if used > 0 then
        table.insert(lines, "")
        table.insert(lines, "In progress:")
        for index, project in ipairs(research.projects or {}) do
            if index > 3 then
                break
            end
            table.insert(lines, tostring(index) .. ". " .. tostring(project.item)
                .. " — " .. tostring(project.trait)
                .. " — " .. AAW_FormatResearchTime(project.remaining) .. ".")
        end
        if #(research.projects or {}) > 3 then
            table.insert(lines, "And " .. tostring(#research.projects - 3) .. " more active project(s).")
        end
    else
        table.insert(lines, "No project is active at this bench.")
    end

    local available = math.max(0, limit - used)
    local best, suggestedTrait = AAW_GetJournalResearchSuggestion(research)
    if available > 0 and best then
        table.insert(lines, "")
        table.insert(lines, AAW_ALDREN_BLUE .. "Next lesson" .. AAW_COLOR_END)
        if suggestedTrait then
            table.insert(lines, tostring(best.item) .. " — " .. tostring(suggestedTrait) .. ".")
        else
            table.insert(lines, "Continue our studies of " .. tostring(best.item) .. ".")
        end
        table.insert(lines, tostring(best.remaining or 0) .. " trait(s) remain in that item category.")
    end

    local carried = (research.carriedScrolls and research.carriedScrolls.total) or 0
    local bankDetails = (AAW.saved and AAW.saved.bankResearchScrollDetailsByProfession) or {}
    local remembered = bankDetails[profession] or { total = 0 }
    if used > 0 and carried > 0 then
        local cooldown = select(1, AAW_GetScrollCooldownForProfession(profession)) or 0
        local plan = AAW_CalculateResearchScrollPlan(research.longestRemaining, cooldown, research.carriedScrolls)
        table.insert(lines, "")
        table.insert(lines, AAW_ALDREN_BLUE .. "Scroll note" .. AAW_COLOR_END)
        if plan.finishesDuringCurrentCooldown then
            table.insert(lines, "The longest project should finish before another scroll can help.")
        elseif plan.scrollsUsed > 0 then
            table.insert(lines, tostring(plan.scrollsUsed) .. " carried research scroll(s) may help the longest project.")
        else
            table.insert(lines, tostring(carried) .. " research scroll(s) are carried for a later moment.")
        end
    elseif (remembered.total or 0) > 0 then
        table.insert(lines, "")
        table.insert(lines, "I remember " .. tostring(remembered.total) .. " " .. displayName .. " research scroll(s) in the bank.")
    end

    return table.concat(lines, "\n")
end

local AAW_BuildTrueStyleJournalText

local AAW_JOURNAL_PAGES = {
    {
        short = "Journey",
        title = "Page 1 — Journey",
        fontSize = 24,
        build = function(chooseNewGreeting) return AAW_BuildJourneyText(chooseNewGreeting == true) end,
    },
    {
        short = "Alchemy",
        title = "Page 2 — Alchemy",
        fontSize = 22,
        build = AAW_BuildAlchemyJournalText,
    },
    {
        short = "Enchanting",
        title = "Page 3 — Enchanting",
        fontSize = 21,
        build = AAW_BuildEnchantingJournalText,
    },
    {
        short = "Provisioning",
        title = "Page 4 — Provisioning",
        fontSize = 22,
        build = AAW_BuildProvisioningJournalText,
    },
    {
        short = "Jewelry Crafting",
        title = "Page 5 — Jewelry Crafting",
        fontSize = 22,
        build = function() return AAW_BuildResearchJournalText("jewelry") end,
    },
    {
        short = "Blacksmithing",
        title = "Page 6 — Blacksmithing",
        fontSize = 22,
        build = function() return AAW_BuildResearchJournalText("blacksmithing") end,
    },
    {
        short = "Clothing",
        title = "Page 7 — Clothing",
        fontSize = 22,
        build = function() return AAW_BuildResearchJournalText("clothing") end,
    },
    {
        short = "Woodworking",
        title = "Page 8 — Woodworking",
        fontSize = 22,
        build = function() return AAW_BuildResearchJournalText("woodworking") end,
    },
    {
        short = "True Style Master",
        title = "Page 9 — True Style Master",
        fontSize = 20,
        build = function() return AAW_BuildTrueStyleJournalText() end,
    },
}

local AAW_GRANDMASTER_REQUIREMENTS = {
    { key = "professions", name = "Professions Master", total = 7, unit = "professions at rank 50" },
    { key = "unsurpassed", name = "Unsurpassed Crafter", id = 1801, total = 100, unit = "Master Writs completed" },
    { key = "trueStyle", name = "True Style Master", total = 50, unit = "complete motifs known" },
    { key = "traitMaster", name = "Trait Master", id = 1041, total = 16, unit = "weapon and armor trait lessons" },
    { key = "nirnhoned", name = "Learn the Nirnhoned Trait", id = 1125, total = 1, unit = "Nirnhoned lesson" },
    { key = "jewelryTraits", name = "Jewelry Trait Master", total = 9, unit = "jewelry traits learned" },
    { key = "recipeCompendium", name = "Recipe Compendium", id = 1028, total = 100, unit = "food and drink recipes learned" },
    { key = "potency", name = "Potency", id = 987, total = nil, unit = "Potency rune lessons" },
    { key = "botanist", name = "Botanist", id = 1045, total = nil, unit = "Alchemy reagent lessons" },
}

local AAW_GRANDMASTER_IDS_RESOLVED = false

local function AAW_NormalizeAchievementName(name)
    return string.lower(AAW_CleanName(name or ""))
end

local function AAW_ReadAchievementName(achievementId)
    if not achievementId or type(GetAchievementInfo) ~= "function" then
        return nil
    end

    local okInfo, name = pcall(GetAchievementInfo, achievementId)
    if okInfo and type(name) == "string" and name ~= "" then
        return name
    end
    return nil
end

local function AAW_RecordGrandmasterAchievementId(achievementId)
    if not achievementId or type(GetAchievementInfo) ~= "function" then
        return false
    end

    local okInfo, name = pcall(GetAchievementInfo, achievementId)
    if not okInfo then
        return false
    end

    local normalizedName = AAW_NormalizeAchievementName(name)

    for _, requirement in ipairs(AAW_GRANDMASTER_REQUIREMENTS) do
        if requirement.key ~= "trueStyle" and not requirement.id
            and normalizedName == AAW_NormalizeAchievementName(requirement.name) then
            requirement.id = achievementId
            return true
        end
    end

    return false
end

local function AAW_ScanAchievementGroup(categoryIndex, subCategoryIndex, achievementCount)
    if type(GetAchievementId) ~= "function" then
        return
    end

    for achievementIndex = 1, tonumber(achievementCount) or 0 do
        local okId, achievementId = pcall(GetAchievementId, categoryIndex, subCategoryIndex, achievementIndex)
        if okId and tonumber(achievementId) and tonumber(achievementId) > 0 then
            AAW_RecordGrandmasterAchievementId(tonumber(achievementId))
        end
    end
end

local function AAW_ResolveGrandmasterAchievementIds()
    if AAW_GRANDMASTER_IDS_RESOLVED then
        return
    end

    -- Most IDs are fixed above. The remaining requirements are matched by their
    -- exact achievement names inside ESO's small achievement catalogue. This is
    -- safer on console than relying on one category label, and it never scans item IDs.
    if type(GetNumAchievementCategories) ~= "function"
        or type(GetAchievementCategoryInfo) ~= "function" then
        return
    end

    local okCategories, categoryCount = pcall(GetNumAchievementCategories)
    if not okCategories or not tonumber(categoryCount) then
        return
    end

    for categoryIndex = 1, tonumber(categoryCount) do
        local okCategory, _, numSubCategories, numAchievements =
            pcall(GetAchievementCategoryInfo, categoryIndex)
        if okCategory then
            AAW_ScanAchievementGroup(categoryIndex, nil, numAchievements)

            if type(GetAchievementSubCategoryInfo) == "function" then
                for subCategoryIndex = 1, tonumber(numSubCategories) or 0 do
                    local okSub, _, subAchievementCount =
                        pcall(GetAchievementSubCategoryInfo, categoryIndex, subCategoryIndex)
                    if okSub then
                        AAW_ScanAchievementGroup(categoryIndex, subCategoryIndex, subAchievementCount)
                    end
                end
            end
        end
    end

    local unresolvedAchievementRequirement = false
    for _, requirement in ipairs(AAW_GRANDMASTER_REQUIREMENTS) do
        if requirement.key ~= "trueStyle" and not requirement.id then
            unresolvedAchievementRequirement = true
            break
        end
    end

    -- True Style Master no longer depends on the achievement catalogue. Retry only
    -- when another achievement-backed checklist row still lacks its verified ID.
    AAW_GRANDMASTER_IDS_RESOLVED = not unresolvedAchievementRequirement
end

local function AAW_GetAchievementCompletion(achievementId)
    if not achievementId or type(GetAchievementInfo) ~= "function" then
        return false, false
    end

    local okInfo, _, _, _, _, completed = pcall(GetAchievementInfo, achievementId)
    if okInfo then
        return completed == true, true
    end
    return false, false
end

local function AAW_GetAchievementProgress(achievementId, fallbackTotal)
    local completed, infoReady = AAW_GetAchievementCompletion(achievementId)
    local current = 0
    local required = 0
    local progressReady = false

    if achievementId and type(GetAchievementCriterion) == "function" then
        local criterionCount = 1
        if type(GetAchievementNumCriteria) == "function" then
            local okCount, count = pcall(GetAchievementNumCriteria, achievementId)
            if okCount and tonumber(count) and tonumber(count) > 0 then
                criterionCount = tonumber(count)
            end
        end

        for criterionIndex = 1, criterionCount do
            local okCriterion, _, numCompleted, numRequired =
                pcall(GetAchievementCriterion, achievementId, criterionIndex)
            if okCriterion and type(numCompleted) == "number"
                and type(numRequired) == "number" and numRequired > 0 then
                current = current + math.max(0, math.min(numCompleted, numRequired))
                required = required + numRequired
                progressReady = true
            end
        end
    end

    if not progressReady and tonumber(fallbackTotal) and tonumber(fallbackTotal) > 0 then
        required = tonumber(fallbackTotal)
        if completed then
            current = required
        end
        progressReady = infoReady
    end

    if completed and required > 0 then
        current = required
    end

    return current, required, progressReady, completed
end

local function AAW_SetTrueStyleKnowledgeUnavailable(reason)
    local knowledge = AAW.trueStyleKnowledge
    knowledge.ready = false
    knowledge.known = 0
    knowledge.styleCount = 0
    knowledge.closestReady = false
    knowledge.closestMotifs = {}
    knowledge.lastError = tostring(reason or "unavailable")
    knowledge.closestError = tostring(reason or "unavailable")
end

local function AAW_GetMotifStyleDisplayName(styleId, items)
    if type(GetItemStyleName) == "function" then
        local okName, styleName = pcall(GetItemStyleName, styleId)
        if okName and type(styleName) == "string" and styleName ~= "" then
            if type(zo_strformat) == "function" then
                local okFormatted, formatted = pcall(zo_strformat, "<<t:1>>", styleName)
                if okFormatted and type(formatted) == "string" and formatted ~= "" then
                    return formatted
                end
            end
            return AAW_CleanName(styleName)
        end
    end

    local motifNumber = items and tonumber(items.number)
    if motifNumber and motifNumber > 0 then
        return "Crafting Motif " .. tostring(motifNumber)
    end

    return nil
end

local function AAW_GetMotifChapterNameMap(LCK)
    if type(LCK.GetMotifChapterNames) ~= "function" then
        return nil, "chapter_names_missing"
    end

    local okNames, chapterNames = pcall(LCK.GetMotifChapterNames)
    if not okNames or type(chapterNames) ~= "table" or #chapterNames <= 0 then
        return nil, "chapter_names_not_ready"
    end

    local namesById = {}
    for _, chapter in ipairs(chapterNames) do
        local chapterId = type(chapter) == "table" and chapter.id or nil
        local chapterName = type(chapter) == "table" and chapter.name or nil
        if type(chapterId) == "number" and type(chapterName) == "string" and chapterName ~= "" then
            namesById[chapterId] = AAW_CleanName(chapterName)
        end
    end

    if next(namesById) == nil then
        return nil, "chapter_names_empty"
    end

    return namesById, nil
end

local function AAW_RefreshTrueStyleKnowledge()
    local knowledge = AAW.trueStyleKnowledge
    local LCK = _G["LibCharacterKnowledge"]

    if type(LCK) ~= "table"
        or type(LCK.GetMotifStyles) ~= "function"
        or type(LCK.GetMotifItemsFromStyle) ~= "function"
        or type(LCK.GetMotifKnowledgeForCharacter) ~= "function"
        or LCK.KNOWLEDGE_KNOWN == nil
        or LCK.KNOWLEDGE_UNKNOWN == nil then
        AAW_SetTrueStyleKnowledgeUnavailable("library_not_ready")
        return false
    end

    local okStyles, styles = pcall(LCK.GetMotifStyles)
    if not okStyles or type(styles) ~= "table" or #styles <= 0 then
        AAW_SetTrueStyleKnowledgeUnavailable("motif_styles_not_ready")
        return false
    end

    local chapterNamesById, closestError = AAW_GetMotifChapterNameMap(LCK)
    local closestDataUsable = chapterNamesById ~= nil
    local incompleteMotifs = {}
    local completeMotifs = 0
    local styleCount = 0

    for _, styleId in ipairs(styles) do
        if type(styleId) ~= "number" then
            AAW_SetTrueStyleKnowledgeUnavailable("invalid_style_record")
            return false
        end

        local okItems, items = pcall(LCK.GetMotifItemsFromStyle, styleId)
        if not okItems or type(items) ~= "table" or type(items.chapters) ~= "table" then
            AAW_SetTrueStyleKnowledgeUnavailable("motif_items_not_ready")
            return false
        end

        styleCount = styleCount + 1
        local hasChapters = false
        local complete = true
        local knownChapters = 0
        local totalChapters = 0
        local missingChapterNames = {}

        for chapterId in pairs(items.chapters) do
            hasChapters = true
            totalChapters = totalChapters + 1
            local okKnowledge, chapterKnowledge =
                pcall(LCK.GetMotifKnowledgeForCharacter, styleId, chapterId)

            if not okKnowledge
                or (chapterKnowledge ~= LCK.KNOWLEDGE_KNOWN
                    and chapterKnowledge ~= LCK.KNOWLEDGE_UNKNOWN) then
                AAW_SetTrueStyleKnowledgeUnavailable("chapter_knowledge_not_ready")
                return false
            end

            if chapterKnowledge == LCK.KNOWLEDGE_KNOWN then
                knownChapters = knownChapters + 1
            else
                complete = false
                if closestDataUsable then
                    local chapterName = chapterNamesById[chapterId]
                    if type(chapterName) ~= "string" or chapterName == "" then
                        closestDataUsable = false
                        closestError = "chapter_name_unavailable"
                    else
                        table.insert(missingChapterNames, chapterName)
                    end
                end
            end
        end

        -- Motifs without individual chapters are learned as one complete book.
        if not hasChapters then
            local okKnowledge, bookKnowledge =
                pcall(LCK.GetMotifKnowledgeForCharacter, styleId)

            if not okKnowledge
                or (bookKnowledge ~= LCK.KNOWLEDGE_KNOWN
                    and bookKnowledge ~= LCK.KNOWLEDGE_UNKNOWN) then
                AAW_SetTrueStyleKnowledgeUnavailable("book_knowledge_not_ready")
                return false
            end

            complete = bookKnowledge == LCK.KNOWLEDGE_KNOWN
            totalChapters = 1
            knownChapters = complete and 1 or 0
            if not complete then
                table.insert(missingChapterNames, "Complete motif book")
            end
        end

        if complete then
            completeMotifs = completeMotifs + 1
        elseif hasChapters and closestDataUsable then
            -- The closest-motif lesson is for page-by-page motif sets. Motifs
            -- learned only through one complete book still count toward the
            -- verified True Style Master total, but they do not take a place
            -- in this chapter-progress list.
            local styleName = AAW_GetMotifStyleDisplayName(styleId, items)
            if type(styleName) ~= "string" or styleName == "" then
                closestDataUsable = false
                closestError = "style_name_unavailable"
            else
                table.sort(missingChapterNames, function(left, right)
                    return AAW_Lower(left) < AAW_Lower(right)
                end)
                table.insert(incompleteMotifs, {
                    styleId = styleId,
                    name = styleName,
                    known = knownChapters,
                    total = totalChapters,
                    missingCount = math.max(0, totalChapters - knownChapters),
                    missing = missingChapterNames,
                })
            end
        end
    end

    if styleCount <= 0 then
        AAW_SetTrueStyleKnowledgeUnavailable("empty_motif_archive")
        return false
    end

    if closestDataUsable then
        table.sort(incompleteMotifs, function(left, right)
            if left.known ~= right.known then
                return left.known > right.known
            end
            return AAW_Lower(left.name) < AAW_Lower(right.name)
        end)
    end

    local closestMotifs = {}
    if closestDataUsable then
        for index = 1, math.min(5, #incompleteMotifs) do
            closestMotifs[index] = incompleteMotifs[index]
        end
    end

    knowledge.ready = true
    knowledge.known = completeMotifs
    knowledge.required = AAW_TRUE_STYLE_REQUIRED
    knowledge.styleCount = styleCount
    knowledge.closestReady = closestDataUsable
    knowledge.closestMotifs = closestMotifs
    knowledge.lastError = nil
    knowledge.closestError = closestDataUsable and nil or tostring(closestError or "closest_motifs_not_ready")
    return true
end

local function AAW_RefreshVisibleTrueStyleKnowledge()
    AAW.trueStyleKnowledge.refreshQueued = false
    AAW_RefreshTrueStyleKnowledge()

    if AAW.journal.scene and AAW.journal.scene:IsShowing()
        and type(AAW.RefreshGrandmasterJournal) == "function" then
        AAW.RefreshGrandmasterJournal(false)
    end
end

local function AAW_QueueTrueStyleKnowledgeRefresh()
    if AAW.trueStyleKnowledge.refreshQueued then
        return
    end

    AAW.trueStyleKnowledge.refreshQueued = true
    if type(zo_callLater) == "function" then
        zo_callLater(AAW_RefreshVisibleTrueStyleKnowledge, 100)
    else
        AAW_RefreshVisibleTrueStyleKnowledge()
    end
end

local function AAW_RegisterTrueStyleKnowledgeCallbacks()
    local LCK = _G["LibCharacterKnowledge"]
    if type(LCK) ~= "table" or type(LCK.RegisterForCallback) ~= "function" then
        AAW_SetTrueStyleKnowledgeUnavailable("library_missing")
        return false
    end

    if not AAW.trueStyleKnowledge.callbacksRegistered then
        if LCK.EVENT_INITIALIZED == nil or LCK.EVENT_UPDATE_REFRESH == nil then
            AAW_SetTrueStyleKnowledgeUnavailable("library_callbacks_missing")
            return false
        end

        local initializedRegistered = pcall(
            LCK.RegisterForCallback,
            AAW.name .. "TrueStyleInitialized",
            LCK.EVENT_INITIALIZED,
            AAW_QueueTrueStyleKnowledgeRefresh
        )
        local refreshRegistered = pcall(
            LCK.RegisterForCallback,
            AAW.name .. "TrueStyleUpdated",
            LCK.EVENT_UPDATE_REFRESH,
            AAW_QueueTrueStyleKnowledgeRefresh
        )

        if not initializedRegistered or not refreshRegistered then
            AAW_SetTrueStyleKnowledgeUnavailable("library_callback_registration_failed")
            return false
        end

        AAW.trueStyleKnowledge.callbacksRegistered = true
    end

    -- This also covers the rare case where LCK finished before our callback was registered.
    AAW_RefreshTrueStyleKnowledge()
    return true
end

AAW_BuildTrueStyleJournalText = function()
    if not AAW.trueStyleKnowledge.ready then
        AAW_RefreshTrueStyleKnowledge()
    end

    local knowledge = AAW.trueStyleKnowledge
    local lines = {
        "A true master learns the whole story of a style, one page at a time.",
        "",
        AAW_ALDREN_BLUE .. "True Style Master" .. AAW_COLOR_END,
    }

    if not knowledge.ready then
        table.insert(lines, "Aldren's motif archive is still opening.")
        table.insert(lines, "I will show verified guidance when the Lore Book records are ready.")
        return table.concat(lines, "\n")
    end

    local current = tonumber(knowledge.known) or 0
    local required = tonumber(knowledge.required) or AAW_TRUE_STYLE_REQUIRED
    local completed = current >= required

    table.insert(lines, "Complete motifs known: " .. tostring(current) .. "/" .. tostring(required) .. ".")
    table.insert(lines, "")

    if completed then
        table.insert(lines, AAW_ALDREN_BLUE .. "Achievement complete" .. AAW_COLOR_END)
        table.insert(lines, "True Style Master is complete, but we may continue learning new styles.")
        table.insert(lines, "")
    end

    table.insert(lines, AAW_ALDREN_BLUE .. "Five closest unfinished motifs" .. AAW_COLOR_END)
    table.insert(lines, "")

    if not knowledge.closestReady then
        table.insert(lines, "The verified total is ready, but the chapter guide is still opening.")
        table.insert(lines, "I will not name missing pages until their records are available.")
        return table.concat(lines, "\n")
    end

    local closestMotifs = knowledge.closestMotifs or {}
    if #closestMotifs <= 0 then
        table.insert(lines, "No unfinished motif records remain in the archive.")
        return table.concat(lines, "\n")
    end

    for index, motif in ipairs(closestMotifs) do
        table.insert(lines, tostring(index) .. ". " .. tostring(motif.name)
            .. " — " .. tostring(motif.known) .. "/" .. tostring(motif.total) .. " pages known")
        table.insert(lines, "   Seek: " .. table.concat(motif.missing or {}, ", "))
        if index < #closestMotifs then
            table.insert(lines, "")
        end
    end

    table.insert(lines, "")
    table.insert(lines, "When a motif is completed, it leaves this list and the next closest lesson takes its place.")

    return table.concat(lines, "\n")
end

local function AAW_BuildGrandmasterCoverText()
    return "A grand achievement is only a collection of smaller lessons.\nWe shall take them one at a time."
end

local function AAW_RefreshGrandmasterChecklist()
    AAW_ResolveGrandmasterAchievementIds()

    for index, requirement in ipairs(AAW_GRANDMASTER_REQUIREMENTS) do
        local row = AAW.journal.checklistRows and AAW.journal.checklistRows[index]
        if row then
            local current, required, ready, completed
            if requirement.key == "trueStyle" then
                if not AAW.trueStyleKnowledge.ready then
                    AAW_RefreshTrueStyleKnowledge()
                end
                current = tonumber(AAW.trueStyleKnowledge.known) or 0
                required = tonumber(AAW.trueStyleKnowledge.required) or AAW_TRUE_STYLE_REQUIRED
                ready = AAW.trueStyleKnowledge.ready == true
                completed = ready and current >= required
            else
                current, required, ready, completed =
                    AAW_GetAchievementProgress(requirement.id, requirement.total)
            end

            local progress
            if ready and required > 0 then
                progress = tostring(current) .. " / " .. tostring(required) .. " " .. requirement.unit
            elseif completed then
                progress = "Complete"
            elseif requirement.key == "trueStyle" then
                progress = "Aldren's motif archive is still opening."
            else
                progress = "ESO is still opening this achievement note."
            end

            row.text:SetText(AAW_ALDREN_BLUE .. requirement.name .. AAW_COLOR_END .. " — " .. progress)
            row.box:SetHidden(false)
            if row.checkShort then row.checkShort:SetHidden(not completed) end
            if row.checkLong then row.checkLong:SetHidden(not completed) end
            row.text:SetHidden(false)
        end
    end
end

local function AAW_SetGrandmasterChecklistHidden(hidden)
    for _, row in ipairs(AAW.journal.checklistRows or {}) do
        row.box:SetHidden(hidden)
        if row.checkShort then row.checkShort:SetHidden(true) end
        if row.checkLong then row.checkLong:SetHidden(true) end
        row.text:SetHidden(hidden)
    end
end

local function AAW_GetJournalPageLabel()
    local currentPage = tonumber(AAW.journal.currentPage) or 0
    if currentPage <= 0 then
        return "Next: " .. tostring(AAW_JOURNAL_PAGES[1].short)
    end
    if currentPage >= #AAW_JOURNAL_PAGES then
        return "Return to Cover"
    end
    return "Next: " .. tostring(AAW_JOURNAL_PAGES[currentPage + 1].short)
end

local function AAW_GetJournalPreviousPageLabel()
    local currentPage = tonumber(AAW.journal.currentPage) or 0
    if currentPage <= 0 then
        return "Previous: " .. tostring(AAW_JOURNAL_PAGES[#AAW_JOURNAL_PAGES].short)
    end
    if currentPage == 1 then
        return "Return to Cover"
    end
    return "Previous: " .. tostring(AAW_JOURNAL_PAGES[currentPage - 1].short)
end

local function AAW_ShowJournalPage(page, chooseNewGreeting)
    local requestedPage = tonumber(page) or 0
    if requestedPage < 0 or requestedPage > #AAW_JOURNAL_PAGES then
        requestedPage = 0
    end
    AAW.journal.currentPage = requestedPage

    AAW_SetGrandmasterChecklistHidden(true)
    if AAW.journal.recipeLeft then AAW.journal.recipeLeft:SetHidden(true) end
    if AAW.journal.recipeRight then AAW.journal.recipeRight:SetHidden(true) end

    if requestedPage == 0 then
        AAW.journal.subtitle:SetText("Aldren's personal notebook of the lessons we have shared.")
        AAW.journal.pageTitle:SetText("The Road to Grand Master Crafter")
        AAW.journal.body:SetDimensions(1016, 72)
        AAW.journal.body:SetFont("$(BOLD_FONT)|23|soft-shadow-thick")
        AAW.journal.body:SetText(AAW_BuildGrandmasterCoverText())
        AAW_RefreshGrandmasterChecklist()
        return
    end

    local pageInfo = AAW_JOURNAL_PAGES[requestedPage]
    AAW.journal.subtitle:SetText("Chapter " .. tostring(requestedPage) .. " of "
        .. tostring(#AAW_JOURNAL_PAGES) .. " — one lesson at a time.")
    AAW.journal.pageTitle:SetText(pageInfo.title)
    AAW.journal.body:SetDimensions(1016, 580)
    AAW.journal.body:SetFont("$(BOLD_FONT)|" .. tostring(pageInfo.fontSize or 22) .. "|soft-shadow-thick")

    local okText, pageText = pcall(pageInfo.build, chooseNewGreeting == true)
    if okText and type(pageText) == "string" and pageText ~= "" then
        AAW.journal.body:SetText(pageText)
    else
        AAW.journal.body:SetText("I could not open this chapter safely.\nI have stopped rather than guess.")
    end
end

local function AAW_GetJournalBackLabel()
    if type(GetString) == "function" and SI_GAMEPAD_BACK_OPTION then
        local ok, label = pcall(GetString, SI_GAMEPAD_BACK_OPTION)
        if ok and label and label ~= "" then
            return label
        end
    end
    return "Back"
end

local function AAW_UpdateJournalKeybinds()
    if AAW.journal.keybindsVisible and KEYBIND_STRIP and AAW.journal.keybindStripDescriptor
        and KEYBIND_STRIP.UpdateKeybindButtonGroup then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(AAW.journal.keybindStripDescriptor)
    end
end

local function AAW_RemoveJournalKeybinds()
    if AAW.journal.keybindsVisible and KEYBIND_STRIP and AAW.journal.keybindStripDescriptor then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(AAW.journal.keybindStripDescriptor)
    end
    AAW.journal.keybindsVisible = false
end

local function AAW_AddJournalKeybinds()
    if AAW.journal.keybindsVisible or not KEYBIND_STRIP or not AAW.journal.keybindStripDescriptor then
        return
    end

    KEYBIND_STRIP:AddKeybindButtonGroup(AAW.journal.keybindStripDescriptor)
    AAW.journal.keybindsVisible = true
end

function AAW.CloseGrandmasterJournal()
    if AAW.journal.scene and AAW.journal.scene:IsShowing() and SCENE_MANAGER then
        SCENE_MANAGER:Hide(AAW.journal.sceneName)
    end
end

local function AAW_EnsureGrandmasterJournalScene()
    if AAW.journal.created and AAW.journal.scene and AAW.journal.control then
        return true
    end

    if not WINDOW_MANAGER or not GuiRoot or not SCENE_MANAGER or not ZO_Scene or not ZO_FadeSceneFragment then
        return false
    end

    local ok = pcall(function()
        local wm = WINDOW_MANAGER
        local control = wm:CreateTopLevelWindow("AldrensGrandmasterJournalSceneControl")
        control:SetDimensions(1100, 920)
        -- Keep the Journal above ESO's lower gamepad controls on a television.
        control:SetAnchor(TOP, GuiRoot, TOP, 0, 20)
        control:SetHidden(true)
        if control.SetClampedToScreen then control:SetClampedToScreen(true) end
        if control.SetDrawTier then control:SetDrawTier(DT_HIGH) end

        local backdrop = wm:CreateControl("AldrensGrandmasterJournalSceneBackdrop", control, CT_BACKDROP)
        backdrop:SetAnchorFill(control)
        if backdrop.SetCenterColor then backdrop:SetCenterColor(0, 0, 0, 0.96) end
        if backdrop.SetEdgeColor then backdrop:SetEdgeColor(0.70, 0.90, 1, 1) end
        if backdrop.SetEdgeTexture then backdrop:SetEdgeTexture("EsoUI/Art/Miscellaneous/centerscreen_left.dds", 8, 1, 1) end

        local title = wm:CreateControl("AldrensGrandmasterJournalSceneTitle", control, CT_LABEL)
        title:SetAnchor(TOPLEFT, control, TOPLEFT, 42, 24)
        title:SetDimensions(1016, 54)
        title:SetFont("$(BOLD_FONT)|34|soft-shadow-thick")
        title:SetColor(0.70, 0.90, 1, 1)
        title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        title:SetText("Aldren's Grandmaster Journal")

        local subtitle = wm:CreateControl("AldrensGrandmasterJournalSceneSubtitle", control, CT_LABEL)
        subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 6)
        subtitle:SetDimensions(1016, 38)
        subtitle:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
        subtitle:SetColor(0.86, 0.82, 1.00, 1)
        subtitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        subtitle:SetText("Aldren's personal notebook of the lessons we have shared.")

        local pageTitle = wm:CreateControl("AldrensGrandmasterJournalJourneyTitle", control, CT_LABEL)
        pageTitle:SetAnchor(TOPLEFT, subtitle, BOTTOMLEFT, 0, 18)
        pageTitle:SetDimensions(1016, 44)
        pageTitle:SetFont("$(BOLD_FONT)|30|soft-shadow-thick")
        pageTitle:SetColor(0.70, 0.90, 1, 1)
        pageTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        pageTitle:SetText("Journey")

        local pageBackdrop = wm:CreateControl("AldrensGrandmasterJournalJourneyBackdrop", control, CT_BACKDROP)
        pageBackdrop:SetAnchor(TOPLEFT, pageTitle, BOTTOMLEFT, -18, 6)
        pageBackdrop:SetDimensions(1052, 612)
        if pageBackdrop.SetCenterColor then pageBackdrop:SetCenterColor(0.04, 0.03, 0.08, 0.98) end
        if pageBackdrop.SetEdgeColor then pageBackdrop:SetEdgeColor(0.48, 0.42, 0.68, 0.95) end
        if pageBackdrop.SetEdgeTexture then pageBackdrop:SetEdgeTexture("EsoUI/Art/Miscellaneous/centerscreen_left.dds", 8, 1, 1) end

        local body = wm:CreateControl("AldrensGrandmasterJournalJourneyBody", control, CT_LABEL)
        body:SetAnchor(TOPLEFT, pageBackdrop, TOPLEFT, 18, 16)
        body:SetDimensions(1016, 580)
        body:SetFont("$(BOLD_FONT)|24|soft-shadow-thick")
        body:SetColor(0.96, 0.93, 1.00, 1)
        body:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

        local checklistRows = {}
        local function AAW_CreateChecklistTexture(name, parent, red, green, blue, alpha)
            local texture = wm:CreateControl(name, parent, CT_TEXTURE)
            texture:SetTexture("EsoUI/Art/Miscellaneous/white.dds")
            texture:SetColor(red, green, blue, alpha)
            return texture
        end

        for index = 1, #AAW_GRANDMASTER_REQUIREMENTS do
            -- Nine compact rows remain above ESO's lower gamepad controls.
            local rowY = 82 + ((index - 1) * 48)

            local box = wm:CreateControl("AldrensGrandmasterJournalChecklistBox" .. tostring(index), pageBackdrop, CT_CONTROL)
            box:SetAnchor(TOPLEFT, pageBackdrop, TOPLEFT, 22, rowY)
            box:SetDimensions(58, 34)

            local fill = AAW_CreateChecklistTexture("AldrensGrandmasterJournalChecklistFill" .. tostring(index), box, 0.04, 0.03, 0.08, 1)
            fill:SetAnchorFill(box)

            local borderTop = AAW_CreateChecklistTexture("AldrensGrandmasterJournalChecklistTop" .. tostring(index), box, 0.70, 0.90, 1, 1)
            borderTop:SetAnchor(TOPLEFT, box, TOPLEFT, 0, 0)
            borderTop:SetDimensions(58, 3)

            local borderBottom = AAW_CreateChecklistTexture("AldrensGrandmasterJournalChecklistBottom" .. tostring(index), box, 0.70, 0.90, 1, 1)
            borderBottom:SetAnchor(BOTTOMLEFT, box, BOTTOMLEFT, 0, 0)
            borderBottom:SetDimensions(58, 3)

            local borderLeft = AAW_CreateChecklistTexture("AldrensGrandmasterJournalChecklistLeft" .. tostring(index), box, 0.70, 0.90, 1, 1)
            borderLeft:SetAnchor(TOPLEFT, box, TOPLEFT, 0, 0)
            borderLeft:SetDimensions(3, 34)

            local borderRight = AAW_CreateChecklistTexture("AldrensGrandmasterJournalChecklistRight" .. tostring(index), box, 0.70, 0.90, 1, 1)
            borderRight:SetAnchor(TOPRIGHT, box, TOPRIGHT, 0, 0)
            borderRight:SetDimensions(3, 34)

            -- Use two textured strokes rather than a font glyph. Some console
            -- fonts do not contain the Unicode check mark used in v1.3.20.
            local checkShort = AAW_CreateChecklistTexture("AldrensGrandmasterJournalChecklistCheckShort" .. tostring(index), box, 0.70, 0.90, 1, 1)
            checkShort:SetAnchor(CENTER, box, CENTER, -8, 4)
            checkShort:SetDimensions(18, 5)
            if checkShort.SetTextureRotation then checkShort:SetTextureRotation(math.rad(45)) end
            checkShort:SetHidden(true)

            local checkLong = AAW_CreateChecklistTexture("AldrensGrandmasterJournalChecklistCheckLong" .. tostring(index), box, 0.70, 0.90, 1, 1)
            checkLong:SetAnchor(CENTER, box, CENTER, 7, -2)
            checkLong:SetDimensions(30, 5)
            if checkLong.SetTextureRotation then checkLong:SetTextureRotation(math.rad(-45)) end
            checkLong:SetHidden(true)

            local rowText = wm:CreateControl("AldrensGrandmasterJournalChecklistText" .. tostring(index), pageBackdrop, CT_LABEL)
            rowText:SetAnchor(LEFT, box, RIGHT, 16, 0)
            rowText:SetDimensions(920, 40)
            rowText:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
            rowText:SetColor(0.96, 0.93, 1.00, 1)
            rowText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            rowText:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            checklistRows[index] = { box = box, checkShort = checkShort, checkLong = checkLong, text = rowText }
        end

        local recipeLeft = wm:CreateControl("AldrensGrandmasterJournalRecipeLeft", control, CT_LABEL)
        recipeLeft:SetAnchor(TOPLEFT, pageBackdrop, TOPLEFT, 18, 330)
        recipeLeft:SetDimensions(490, 230)
        recipeLeft:SetFont("$(BOLD_FONT)|24|soft-shadow-thick")
        recipeLeft:SetColor(0.96, 0.93, 1.00, 1)
        recipeLeft:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        recipeLeft:SetHidden(true)

        local recipeRight = wm:CreateControl("AldrensGrandmasterJournalRecipeRight", control, CT_LABEL)
        recipeRight:SetAnchor(TOPLEFT, pageBackdrop, TOPLEFT, 526, 330)
        recipeRight:SetDimensions(490, 230)
        recipeRight:SetFont("$(BOLD_FONT)|24|soft-shadow-thick")
        recipeRight:SetColor(0.96, 0.93, 1.00, 1)
        recipeRight:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        recipeRight:SetHidden(true)

        local footer = wm:CreateControl("AldrensGrandmasterJournalSceneFooter", control, CT_LABEL)
        footer:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 42, -24)
        footer:SetDimensions(1016, 84)
        footer:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
        footer:SetColor(0.70, 0.90, 1, 1)
        footer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        footer:SetText("Until our next lesson,\n\n— Aldren")

        local scene = ZO_Scene:New(AAW.journal.sceneName, SCENE_MANAGER)
        if scene.SetInputPreferredMode and INPUT_PREFERRED_MODE_ALWAYS_GAMEPAD then
            scene:SetInputPreferredMode(INPUT_PREFERRED_MODE_ALWAYS_GAMEPAD)
        end
        if FRAGMENT_GROUP and FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW then
            scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
        end
        if UNIFORM_BLUR_FRAGMENT then
            scene:AddFragment(UNIFORM_BLUR_FRAGMENT)
        end

        local fragment = ZO_FadeSceneFragment:New(control)
        scene:AddFragment(fragment)

        AAW.journal.keybindStripDescriptor = {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            {
                name = AAW_GetJournalBackLabel,
                keybind = "UI_SHORTCUT_NEGATIVE",
                callback = AAW.CloseGrandmasterJournal,
            },
            {
                name = AAW_GetJournalPreviousPageLabel,
                keybind = "UI_SHORTCUT_LEFT_STICK",
                callback = function()
                    local previousPage = (tonumber(AAW.journal.currentPage) or 0) - 1
                    if previousPage < 0 then
                        previousPage = #AAW_JOURNAL_PAGES
                    end
                    AAW_ShowJournalPage(previousPage, false)
                    AAW_UpdateJournalKeybinds()
                end,
            },
            {
                name = AAW_GetJournalPageLabel,
                keybind = "UI_SHORTCUT_RIGHT_STICK",
                callback = function()
                    local nextPage = (tonumber(AAW.journal.currentPage) or 0) + 1
                    if nextPage > #AAW_JOURNAL_PAGES then
                        nextPage = 0
                    end
                    AAW_ShowJournalPage(nextPage, false)
                    AAW_UpdateJournalKeybinds()
                end,
            },
        }

        scene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING then
                AAW.HideWorkshopWindow()
                AAW.journal.currentPage = 0
                AAW.RefreshGrandmasterJournal(true)
                AAW_AddJournalKeybinds()
            elseif newState == SCENE_HIDING then
                AAW_RemoveJournalKeybinds()
            elseif newState == SCENE_HIDDEN then
                AAW.journal.currentGreeting = nil
                if AAW.state.isAtSupportedCraftingStation then
                    AAW.QueueWorkshopRefresh("journal closed")
                end
            end
        end)

        AAW.journal.scene = scene
        AAW.journal.fragment = fragment
        AAW.journal.control = control
        AAW.journal.title = title
        AAW.journal.subtitle = subtitle
        AAW.journal.pageTitle = pageTitle
        AAW.journal.pageBackdrop = pageBackdrop
        AAW.journal.body = body
        AAW.journal.checklistRows = checklistRows
        AAW.journal.recipeLeft = recipeLeft
        AAW.journal.recipeRight = recipeRight
        AAW.journal.footer = footer
        AAW.journal.created = true
    end)

    return ok and AAW.journal.created and AAW.journal.scene ~= nil
end

function AAW.RefreshGrandmasterJournal(chooseNewGreeting)
    if not AAW_EnsureGrandmasterJournalScene() then
        return false
    end

    AAW_ShowJournalPage(AAW.journal.currentPage, chooseNewGreeting == true)
    AAW_UpdateJournalKeybinds()
    return true
end

function AAW.OpenGrandmasterJournal()
    if not AAW_EnsureGrandmasterJournalScene() then
        AAW_Message("Aldren's Grandmaster Journal could not open safely.")
        return false
    end

    AAW.HideWorkshopWindow()
    SCENE_MANAGER:Push(AAW.journal.sceneName)
    return true
end

function AAW.ToggleGrandmasterJournal()
    if AAW.journal.scene and AAW.journal.scene:IsShowing() then
        AAW.CloseGrandmasterJournal()
    else
        AAW.OpenGrandmasterJournal()
    end
end

-- Compatibility wrappers preserve the existing keybind and slash command names.
function AAW.RefreshGrandmasterProgressPage()
    return AAW.RefreshGrandmasterJournal(false)
end

function AAW.ToggleGrandmasterProgressPage()
    AAW.ToggleGrandmasterJournal()
end

local function AAW_OnRecipeLearnedForProgress()
    AAW.state.recipeKnowledgeDirty = true
    AAW.provisioningIngredientKnowledge.dirty = true
    if AAW.state.recipeKnowledgeRefreshQueued then return end
    AAW.state.recipeKnowledgeRefreshQueued = true

    local function refreshVisibleRecipeNotes()
        AAW.state.recipeKnowledgeRefreshQueued = false

        -- Leave the snapshot dirty when no relevant page is visible. The next
        -- deliberate opening will refresh it once. This avoids background work.
        if AAW.state.isAtProvisioningStation then
            AAW.RefreshWorkshopPanel("recipe learned", false)
        end

        if AAW.journal.scene and AAW.journal.scene:IsShowing() then
            AAW.RefreshGrandmasterJournal(false)
        end
    end

    if type(zo_callLater) == "function" then
        zo_callLater(refreshVisibleRecipeNotes, 300)
    else
        refreshVisibleRecipeNotes()
    end
end

_G["AldrensGrandmasterWorkshop_ToggleProgress"] = function()
    AAW.ToggleGrandmasterJournal()
end

-- Console players do not have the PC keybinding list. Add Aldren to ESO's
-- existing Player Menu > Journal submenu so the Scene can be opened normally
-- with a controller. The slash command remains only as a backup test tool.
local AAW_JOURNAL_MENU_ENTRY_ID = "aldrenGrandmasterJournalEntry"

local function AAW_TryInstallJournalMenuEntry()
    if AAW.journal.menuEntryInstalled then
        return true
    end

    if not ZO_MENU_ENTRIES or not ZO_MENU_MAIN_ENTRIES or not ZO_GamepadEntryData then
        return false
    end

    local journalIndex = ZO_MENU_MAIN_ENTRIES.JOURNAL
    local journalMenuEntry = journalIndex and ZO_MENU_ENTRIES[journalIndex]
    if not journalMenuEntry or not journalMenuEntry.subMenu then
        return false
    end

    for _, existingEntry in ipairs(journalMenuEntry.subMenu) do
        if existingEntry.id == AAW_JOURNAL_MENU_ENTRY_ID
            or (existingEntry.data and existingEntry.data.isAldrenGrandmasterJournal) then
            AAW.journal.menuEntryInstalled = true
            return true
        end
    end

    if not AAW_EnsureGrandmasterJournalScene() then
        return false
    end

    local entryData = {
        scene = AAW.journal.sceneName,
        name = "Aldren's Grandmaster Journal",
        icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_journal.dds",
        isAldrenGrandmasterJournal = true,
    }

    local entry = ZO_GamepadEntryData:New(entryData.name, entryData.icon)
    if entry.SetIconTintOnSelection then entry:SetIconTintOnSelection(true) end
    if entry.SetIconDisabledTintOnSelection then entry:SetIconDisabledTintOnSelection(true) end
    entry.data = entryData
    entry.id = AAW_JOURNAL_MENU_ENTRY_ID
    table.insert(journalMenuEntry.subMenu, entry)

    AAW.journal.menuEntryInstalled = true
    if MAIN_MENU_GAMEPAD and MAIN_MENU_GAMEPAD.RefreshLists then
        MAIN_MENU_GAMEPAD:RefreshLists()
    end
    return true
end

AAW_InstallJournalMenuEntry = function()
    if AAW_TryInstallJournalMenuEntry() then
        return
    end

    AAW.journal.menuInstallAttempts = (AAW.journal.menuInstallAttempts or 0) + 1
    if AAW.journal.menuInstallAttempts < 8 and type(zo_callLater) == "function" then
        zo_callLater(AAW_InstallJournalMenuEntry, 1000)
    end
end

if type(ZO_CreateStringId) == "function" then
    ZO_CreateStringId("SI_BINDING_NAME_ALDREN_TOGGLE_GRANDMASTER_PROGRESS", "Open Aldren's Grandmaster Journal")
end

local function AAW_InitSavedVariables()
    local defaults = {
        hasLaboratoryUse = false,
        labConfidence = "not_checked",
        recipeIngredientCount = 2,
        lastCheckedVersion = "none",
        knownTraitsByReagent = {},
        knownRunesByName = {},
        hasSeenAldrenIntro = false,
        bankResearchScrollsByProfession = { jewelry = 0, blacksmithing = 0, clothing = 0, woodworking = 0 },
        bankResearchScrollDetailsByProfession = {
            jewelry = { total = 0, oneDay = 0, sevenDay = 0 },
            blacksmithing = { total = 0, oneDay = 0, sevenDay = 0 },
            clothing = { total = 0, oneDay = 0, sevenDay = 0 },
            woodworking = { total = 0, oneDay = 0, sevenDay = 0 },
        },
        bankResearchScrollsSeenAt = 0,
        researchScrollMemoryVersion = 3,
    }

    if ZO_SavedVars and ZO_SavedVars.NewCharacterIdSettings then
        AAW.saved = ZO_SavedVars:NewCharacterIdSettings("AldrensAlchemyWorkshopSavedVariables", AAW.savedVersion, nil, defaults)
    elseif ZO_SavedVars and ZO_SavedVars.NewCharacterNameSettings then
        AAW.saved = ZO_SavedVars:NewCharacterNameSettings("AldrensAlchemyWorkshopSavedVariables", AAW.savedVersion, nil, defaults)
    else
        AAW.saved = defaults
    end

    -- Version 3 uses strict profession-specific names. Clear older memory once
    -- so an item previously misidentified as Jewelry cannot linger.
    if (AAW.saved.researchScrollMemoryVersion or 0) < 3 then
        AAW.saved.bankResearchScrollsByProfession = AAW_NewResearchScrollCounts()
        AAW.saved.bankResearchScrollDetailsByProfession = {
            jewelry = { total = 0, oneDay = 0, sevenDay = 0 },
            blacksmithing = { total = 0, oneDay = 0, sevenDay = 0 },
            clothing = { total = 0, oneDay = 0, sevenDay = 0 },
            woodworking = { total = 0, oneDay = 0, sevenDay = 0 },
        }
        AAW.saved.researchScrollMemoryVersion = 3
    end

    AAW_LoadSavedLaboratoryUse()
end

local function AAW_OnAddonLoaded(eventCode, addonName)
    if addonName ~= AAW.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(AAW.name, EVENT_ADD_ON_LOADED)

    AAW_InitSavedVariables()
    AAW_RegisterTrueStyleKnowledgeCallbacks()
    AAW_InstallJournalMenuEntry()

    EVENT_MANAGER:RegisterForEvent(AAW.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, AAW_OnPlayerActivated)
    AAW_RegisterCraftingEvents()

    SLASH_COMMANDS["/aaw"] = AAW.RunManualCheck
    SLASH_COMMANDS["/agw"] = AAW.RunManualCheck
    SLASH_COMMANDS["/aldrenalchemy"] = AAW.RunManualCheck
    SLASH_COMMANDS["/agwrunes"] = AAW.RunRuneSyncTest
    SLASH_COMMANDS["/agwprogress"] = AAW.ToggleGrandmasterJournal
    SLASH_COMMANDS["/agwjournal"] = AAW.ToggleGrandmasterJournal
    SLASH_COMMANDS["/agwrecipes"] = AAW.RunRecipeKnowledgeTest

    if EVENT_RECIPE_LEARNED then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "ProgressRecipeLearned", EVENT_RECIPE_LEARNED, AAW_OnRecipeLearnedForProgress)
    end
    if EVENT_MULTIPLE_RECIPES_LEARNED then
        EVENT_MANAGER:RegisterForEvent(AAW.name .. "ProgressMultipleRecipesLearned", EVENT_MULTIPLE_RECIPES_LEARNED, AAW_OnRecipeLearnedForProgress)
    end

end

EVENT_MANAGER:RegisterForEvent(AAW.name, EVENT_ADD_ON_LOADED, AAW_OnAddonLoaded)
