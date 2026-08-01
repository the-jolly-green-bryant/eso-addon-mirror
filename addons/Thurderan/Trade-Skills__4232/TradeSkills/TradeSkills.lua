-- TradeSkills Addon: Combined tracker for Carpentry, Cooking, Brewing, Style Mastery, Trait Mastery, Fishing, Mining, Herbalism, and Skinning
-- Version 2.6 - Added Skinning skill (raw material scraps from creatures)

TradeSkills = {}
TradeSkills.name = "TradeSkills"
TradeSkills.SAVED_VARS_VERSION = 1
TradeSkills.activeTab = 1

-- Default saved variables (all per-character)
local defaultSettings = {
    windowPosition = {x = 350, y = 200},
    activeTab = 1,
    disabledPerks = {},  -- { ["SkillName_PerkLevel"] = true } for toggled-off perks
    -- Carpentry specific
    carpentry = {
        knownRecipes = {},
        lastNotifiedLevel = 0
    },
    -- Cooking specific
    cooking = {
        knownRecipes = {},
        lastNotifiedLevel = 0
    },
    -- Brewing specific
    brewing = {
        knownRecipes = {},
        lastNotifiedLevel = 0
    },
    -- Style Mastery specific
    stylemastery = {
        knownMotifPages = {},
        lastNotifiedLevel = 0,
        motifMapPosition = nil,
    },
    -- Trait Mastery specific
    traitmastery = {
        knownTraits = 0,
        lastNotifiedLevel = 0
    },
    -- Fishing specific
    fishing = {
        totalFishCaught = 0,
        lastNotifiedLevel = 0,
        checklistPosition = nil,
        fishBarPosition = nil,
    },
    -- Mining specific
    mining = {
        totalNodesGathered = 0,
        lastNotifiedLevel = 0
    },
    -- Herbalism specific
    herbalism = {
        totalNodesGathered = 0,
        lastNotifiedLevel = 0
    },
    -- Woodcutting specific
    woodcutting = {
        totalNodesGathered = 0,
        lastNotifiedLevel = 0
    },
    -- Skinning specific
    skinning = {
        totalScrapsLooted = 0,
        lastNotifiedLevel = 0,
        lootWindowPosition = nil,
        beastIndicatorPosition = nil,
        creatureLoot = {},  -- Learned loot drops: { ["creature name"] = { "item1", "item2", ... } }
    }
}

-- =======================
-- LEVEL UP ANNOUNCEMENT
-- =======================
-- Shows an uppercase "SKILL INCREASED TO LEVEL" message like native ESO skill ups
-- Uses CSA with extended display via a second queued message
function TradeSkills.AnnounceLevelUp(skillName, level, color)
    PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
    local upperName = string.upper(skillName)
    local message = string.format("|c%s%s|r INCREASED TO |cFFFFFF%d|r", color, upperName, level)
    
    -- Create message params with no sound (sound already played above)
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
    params:SetText(message)
    params:SetLifespanMS(3000)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

-- =======================
-- ACHIEVEMENT SCANNER
-- =======================
-- Dynamically finds all achievement IDs belonging to given subcategory names
-- Also includes achievements filed directly under the parent category (General)
-- This avoids hardcoding IDs and automatically picks up new achievements from updates
function TradeSkills.FindAchievementsBySubCategory(...)
    local targetNames = {}
    for i = 1, select("#", ...) do
        targetNames[string.lower(select(i, ...))] = true
    end
    
    local ids = {}
    local seenIds = {} -- prevent duplicates
    
    local numCategories = GetNumAchievementCategories()
    for ci = 1, numCategories do
        local catName, subCount, achCount = GetAchievementCategoryInfo(ci)
        
        -- Check subcategories for matches
        for si = 1, subCount do
            local subName, subAchCount = GetAchievementSubCategoryInfo(ci, si)
            if subName and targetNames[string.lower(subName)] then
                for ai = 1, subAchCount do
                    local id = GetAchievementId(ci, si, ai)
                    if id and id > 0 and not seenIds[id] then
                        seenIds[id] = true
                        table.insert(ids, id)
                        -- Also follow achievement chains
                        local nextId = GetNextAchievementInLine(id)
                        while nextId and nextId > 0 do
                            if not seenIds[nextId] then
                                seenIds[nextId] = true
                                table.insert(ids, nextId)
                            end
                            nextId = GetNextAchievementInLine(nextId)
                        end
                    end
                end
            end
        end
    end
    return ids
end

-- =======================
-- CARPENTRY MODULE
-- =======================
TradeSkills.Carpentry = {
    name = "Carpentry",
    color = {0.55, 0.27, 0.07, 1},
    icon = "TradeSkills/icons/carpentry.dds",
    RECIPES_PER_LEVEL = 37,
    MAX_LEVEL = 85,
    TOTAL_RECIPES = 3145,
    RANKS = {
        {level = 0, name = "Apprentice", color = {0.6, 0.6, 0.6, 1}},
        {level = 28, name = "Journeyman", color = {0.7, 0.5, 0.2, 1}},
        {level = 57, name = "Master Craftsman", color = {0.8, 0.6, 0.3, 1}},
        {level = 85, name = "Grandmaster", color = {1, 0.84, 0, 1}}
    },
    passiveAbilities = {
        {
            name = "Furniture Store",
            icon = "TradeSkills/icons/furniture_blueprint.dds",
            level = 10,
            description = "At crafting stations, shows furniture you can craft while keeping 200+ of each ingredient.",
        },
    },
    _debugPerks = false,
}

function TradeSkills.Carpentry:GetCount()
    local count = 0
    for _ in pairs(TradeSkills.savedVars.carpentry.knownRecipes) do
        count = count + 1
    end
    return count
end

function TradeSkills.Carpentry:GetLevel()
    local level = math.floor(self:GetCount() / self.RECIPES_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function TradeSkills.Carpentry:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.RECIPES_PER_LEVEL, self.RECIPES_PER_LEVEL
    end
    return count % self.RECIPES_PER_LEVEL, self.RECIPES_PER_LEVEL
end

function TradeSkills.Carpentry:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function TradeSkills.Carpentry:GetDescription()
    return string.format("Learn furniture recipes to increase skill.\nEvery 37 recipes increases your level by 1. Max level 85.\n\nFurniture Recipes Known: %d/%d", 
        self:GetCount(), self.TOTAL_RECIPES)
end

function TradeSkills.Carpentry:HasPerk(requiredLevel)
    if self._debugPerks then
        return not TradeSkills.IsPerkDisabled("Carpentry", requiredLevel)
    end
    if self:GetLevel() < requiredLevel then return false end
    return not TradeSkills.IsPerkDisabled("Carpentry", requiredLevel)
end

-- =======================
-- CARPENTRY PERK: FURNITURE STORE (Level 10)
-- =======================
-- At crafting stations (woodworking, clothing, blacksmithing, jewelry),
-- shows a scrollable window of furniture recipes you can craft while keeping 200+ of each ingredient.
-- Uses the same item counting logic as Master Chef's Margin.

function TradeSkills.Carpentry:CreateFurnitureStoreWindow()
    if self._storeWindow then return end
    
    local window = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_FurnitureStoreWindow")
    window:SetDimensions(420, 500)
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 20, 100)
    window:SetHidden(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    
    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.06, 0.04, 0.02, 0.92)
    bg:SetEdgeColor(0.55, 0.27, 0.07, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)
    
    local title = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    title:SetFont("ZoFontGameBold")
    title:SetAnchor(TOP, window, TOP, 0, 10)
    title:SetText("|cC8A060Furniture Store|r")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetDimensions(400, 24)
    
    local subtitle = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    subtitle:SetFont("ZoFontGameSmall")
    subtitle:SetAnchor(TOP, title, BOTTOM, 0, 2)
    subtitle:SetText("|c888888Furniture craftable while keeping 200+ of each ingredient|r")
    subtitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    subtitle:SetDimensions(400, 20)
    
    local scroll = WINDOW_MANAGER:CreateControlFromVirtual("TradeSkills_FurnitureStoreScroll", window, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 58)
    scroll:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -10, -10)
    
    local scrollChild = scroll:GetNamedChild("ScrollChild")
    
    local content = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_LABEL)
    content:SetFont("ZoFontGame")
    content:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 5, 0)
    content:SetWidth(375)
    content:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    content:SetVerticalAlignment(TEXT_ALIGN_TOP)
    content:SetMaxLineCount(200)
    
    self._storeWindow = window
    self._storeScroll = scroll
    self._storeScrollChild = scrollChild
    self._storeContent = content
end

-- Build a one-time inventory cache: maps lowercase item name -> total count across all bags
function TradeSkills.BuildInventoryCache()
    local cache = {}
    local bagsToSearch = { BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK }
    
    for _, bagId in ipairs(bagsToSearch) do
        local bagSize = GetBagSize(bagId)
        if bagSize and bagSize > 0 then
            for slot = 0, bagSize - 1 do
                local _, stackCount = GetItemInfo(bagId, slot)
                if stackCount and stackCount > 0 then
                    local slotLink = GetItemLink(bagId, slot)
                    if slotLink and slotLink ~= "" then
                        local slotName = string.lower(zo_strformat("<<1>>", GetItemLinkName(slotLink)))
                        if slotName ~= "" then
                            cache[slotName] = (cache[slotName] or 0) + stackCount
                        end
                    end
                end
            end
        end
    end
    
    -- Also check craft bag (BAG_VIRTUAL) using item IDs
    -- We store these by ID since virtual bag uses item ID as slot
    TradeSkills._virtualBagCache = {}
    -- Virtual bag items are accessed by itemId, not slot iteration
    -- We'll look them up on demand since the API is fast for direct access
    
    TradeSkills._inventoryCache = cache
    TradeSkills._inventoryCacheTime = GetGameTimeMilliseconds()
    return cache
end

function TradeSkills.Carpentry:CountItemInInventory(searchLink)
    if not searchLink or searchLink == "" then return 0 end
    
    local searchName = zo_strformat("<<1>>", GetItemLinkName(searchLink))
    if not searchName or searchName == "" then return 0 end
    searchName = string.lower(searchName)
    
    -- Use cached inventory if available and recent (within 5 seconds)
    if not TradeSkills._inventoryCache or 
       not TradeSkills._inventoryCacheTime or
       (GetGameTimeMilliseconds() - TradeSkills._inventoryCacheTime) > 5000 then
        TradeSkills.BuildInventoryCache()
    end
    
    local total = TradeSkills._inventoryCache[searchName] or 0
    
    -- Also check craft bag (direct lookup is fast)
    local itemId = GetItemLinkItemId(searchLink)
    if itemId and itemId > 0 then
        local _, stackCount = GetItemInfo(BAG_VIRTUAL, itemId)
        if stackCount and stackCount > 0 then
            total = total + stackCount
        end
    end
    
    return total
end

function TradeSkills.Carpentry:ScanCraftableFurniture(craftSkillType)
    if not self:HasPerk(10) then return end
    if not self._storeWindow then self:CreateFurnitureStoreWindow() end
    
    local MARGIN = 200
    local BATCH_SIZE = 15 -- recipes per frame (kept low due to inventory lookups per recipe)
    local craftableRecipes = {}
    
    -- Build inventory cache once upfront
    TradeSkills.BuildInventoryCache()
    
    local numRecipeLists = GetNumRecipeLists()
    local listIndex = 1
    local recipeIndex = 1
    local numRecipesInList = 0
    
    if numRecipeLists > 0 then
        _, numRecipesInList = GetRecipeListInfo(1)
    end
    
    -- Show loading state
    self._storeContent:SetText("|c888888Scanning furniture recipes...|r")
    self._storeWindow:SetHidden(false)
    
    local pollName = TradeSkills.name .. "_FURNSCAN"
    EVENT_MANAGER:UnregisterForUpdate(pollName)
    
    EVENT_MANAGER:RegisterForUpdate(pollName, 1, function()
        local processed = 0
        
        while processed < BATCH_SIZE and listIndex <= numRecipeLists do
            if recipeIndex <= numRecipesInList then
                local known, recipeName, numIngredients = GetRecipeInfo(listIndex, recipeIndex)
                
                if known and numIngredients and numIngredients > 0 then
                    local resultLink = GetRecipeResultItemLink(listIndex, recipeIndex, LINK_STYLE_DEFAULT)
                    if resultLink and resultLink ~= "" then
                        local resultType = GetItemLinkItemType(resultLink)
                        
                        if resultType == ITEMTYPE_FURNISHING then
                            local allAboveMargin = true
                            local maxCrafts = math.huge
                            
                            for i = 1, numIngredients do
                                local ingredientName, _, requiredQty = GetRecipeIngredientItemInfo(listIndex, recipeIndex, i)
                                local ingredientLink = GetRecipeIngredientItemLink(listIndex, recipeIndex, i, LINK_STYLE_DEFAULT)
                                local haveCount = self:CountItemInInventory(ingredientLink)
                                
                                local isStyleMat = false
                                if ingredientLink and ingredientLink ~= "" then
                                    local ingType = GetItemLinkItemType(ingredientLink)
                                    if ingType == ITEMTYPE_STYLE_MATERIAL or ingType == ITEMTYPE_RACIAL_STYLE_MOTIF then
                                        isStyleMat = true
                                    end
                                end
                                
                                if isStyleMat then
                                    if haveCount < (requiredQty or 1) then
                                        allAboveMargin = false
                                        break
                                    end
                                    local craftsFromThis = math.floor(haveCount / (requiredQty or 1))
                                    maxCrafts = math.min(maxCrafts, craftsFromThis)
                                else
                                    if haveCount < MARGIN then
                                        allAboveMargin = false
                                        break
                                    end
                                    local available = haveCount - MARGIN
                                    if requiredQty and requiredQty > 0 then
                                        local craftsFromThis = math.floor(available / requiredQty)
                                        maxCrafts = math.min(maxCrafts, craftsFromThis)
                                    end
                                end
                            end
                            
                            if allAboveMargin and maxCrafts > 0 then
                                local cleanName = zo_strformat("<<1>>", recipeName)
                                table.insert(craftableRecipes, {
                                    name = cleanName,
                                    count = maxCrafts,
                                    quality = GetItemLinkQuality(resultLink),
                                })
                            end
                        end
                    end
                end
                
                recipeIndex = recipeIndex + 1
                processed = processed + 1
            else
                listIndex = listIndex + 1
                recipeIndex = 1
                if listIndex <= numRecipeLists then
                    _, numRecipesInList = GetRecipeListInfo(listIndex)
                end
            end
        end
        
        -- Done scanning
        if listIndex > numRecipeLists then
            EVENT_MANAGER:UnregisterForUpdate(pollName)
            
            table.sort(craftableRecipes, function(a, b)
                if a.quality ~= b.quality then return a.quality > b.quality end
                return a.name < b.name
            end)
            
            if #craftableRecipes == 0 then
                self._storeContent:SetText("|c888888No furniture recipes found where you have\n200+ of every ingredient.|r")
            else
                local lines = {}
                for _, recipe in ipairs(craftableRecipes) do
                    local qualityColor = GetItemQualityColor(recipe.quality)
                    local colorHex = qualityColor and qualityColor:ToHex() or "FFFFFF"
                    table.insert(lines, string.format("|c%s%s|r |cFFFFFFx%d|r", colorHex, recipe.name, recipe.count))
                end
                self._storeContent:SetText(table.concat(lines, "\n"))
            end
            
            local textHeight = self._storeContent:GetTextHeight()
            self._storeScrollChild:SetHeight(textHeight + 10)
        end
    end)
end

function TradeSkills.Carpentry:HideFurnitureStoreWindow()
    if self._storeWindow then
        self._storeWindow:SetHidden(true)
    end
end

-- =======================
-- COOKING MODULE
-- =======================
TradeSkills.Cooking = {
    name = "Cooking",
    color = {1, 0.6, 0.2, 1},
    icon = "TradeSkills/icons/ts_cooking.dds",
    RECIPES_PER_LEVEL = 6,
    MAX_LEVEL = 48,
    TOTAL_RECIPES = 288,
    RANKS = {
        {level = 0, name = "Cook", color = {0.6, 0.6, 0.6, 1}},
        {level = 16, name = "Chef", color = {1, 0.7, 0.3, 1}},
        {level = 32, name = "Master Chef", color = {1, 0.8, 0.4, 1}},
        {level = 48, name = "Culinary Artist", color = {1, 0.84, 0, 1}}
    },
    passiveAbilities = {
        {
            name = "Quick Eat",
            icon = "TradeSkills/icons/quickeat.dds",
            level = 10,
            description = "Auto-selects food to your quickslot when your food buff expires.",
        },
        {
            name = "Master Chef's Margin",
            icon = "TradeSkills/icons/masterchefmargin.dds",
            level = 30,
            description = "At provisioning stations, shows recipes you can craft while keeping 200+ of each ingredient.",
        },
    },
    _debugPerks = false,
    _foodBuffActive = false,
}

function TradeSkills.Cooking:GetCount()
    local count = 0
    for _ in pairs(TradeSkills.savedVars.cooking.knownRecipes) do
        count = count + 1
    end
    return count
end

function TradeSkills.Cooking:GetLevel()
    local level = math.floor(self:GetCount() / self.RECIPES_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function TradeSkills.Cooking:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.RECIPES_PER_LEVEL, self.RECIPES_PER_LEVEL
    end
    return count % self.RECIPES_PER_LEVEL, self.RECIPES_PER_LEVEL
end

function TradeSkills.Cooking:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function TradeSkills.Cooking:GetDescription()
    return string.format("Learn food recipes to increase skill.\nEvery 6 recipes increases your level by 1. Max level 48.\n\nFood Recipes Known: %d/%d", 
        self:GetCount(), self.TOTAL_RECIPES)
end

function TradeSkills.Cooking:HasPerk(requiredLevel)
    if self._debugPerks then
        return not TradeSkills.IsPerkDisabled("Cooking", requiredLevel)
    end
    if self:GetLevel() < requiredLevel then return false end
    return not TradeSkills.IsPerkDisabled("Cooking", requiredLevel)
end

-- =======================
-- COOKING PERK: QUICK EAT (Level 10)
-- =======================
-- Auto-selects food from inventory to quickslot when food buff expires.
-- Mirrors Quick Drink but for ITEMTYPE_FOOD.

-- Detect if a buff is a food buff (not drink)
function TradeSkills.Cooking:IsFoodBuff(abilityId, effectName, abilityType, iconFilename)
    -- Try LibFoodDrinkBuff first
    if LibFoodDrinkBuff and LibFoodDrinkBuff.IsAbilityAFoodBuff then
        local result = LibFoodDrinkBuff:IsAbilityAFoodBuff(abilityId)
        if result ~= nil then return result end
    end
    -- Fallback: abilityType 5 = food in ESO
    if iconFilename and string.find(string.lower(iconFilename), "icon_potion_full") then
        if abilityType == 5 then
            return true  -- Food buff
        end
    end
    return false
end

-- Check if player currently has an active food buff
function TradeSkills.Cooking:HasFoodBuff()
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, _, endTime, _, _, iconFilename, buffType, effectType, abilityType, _, abilityId = GetUnitBuffInfo("player", i)
        if self:IsFoodBuff(abilityId, buffName, abilityType, iconFilename) then
            return true
        end
    end
    return false
end

-- Get the player's highest stat for food selection
function TradeSkills.Cooking:GetHighestPlayerStat()
    local _, maxHealth = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)
    local _, maxMagicka = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_MAGICKA)
    local _, maxStamina = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
    
    if maxStamina >= maxMagicka and maxStamina >= maxHealth then
        return "stamina", maxStamina
    elseif maxMagicka >= maxStamina and maxMagicka >= maxHealth then
        return "magicka", maxMagicka
    else
        return "health", maxHealth
    end
end

-- Determine which stat a food boosts
function TradeSkills.Cooking:GetFoodStatType(itemLink)
    local hasAbility, abilityDesc = GetItemLinkOnUseAbilityInfo(itemLink)
    local name = string.lower(zo_strformat("<<1>>", GetItemLinkName(itemLink)))
    local flavorText = string.lower(GetItemLinkFlavorText(itemLink) or "")
    local equipDesc = ""
    if abilityDesc then equipDesc = string.lower(abilityDesc) end
    
    local combined = name .. " " .. flavorText .. " " .. equipDesc
    
    if (string.find(combined, "health") and string.find(combined, "magicka") and string.find(combined, "stamina")) then
        return "tri"
    end
    
    local hasHealth = string.find(combined, "health") and true or false
    local hasMagicka = string.find(combined, "magicka") and true or false
    local hasStamina = string.find(combined, "stamina") and true or false
    
    if hasStamina and not hasMagicka and not hasHealth then return "stamina" end
    if hasMagicka and not hasStamina and not hasHealth then return "magicka" end
    if hasHealth and not hasMagicka and not hasStamina then return "health" end
    if hasStamina and hasMagicka then return "tri" end
    if hasStamina and hasHealth then return "tri" end
    if hasMagicka and hasHealth then return "tri" end
    
    return "unknown"
end

-- Find food in inventory and select it to quickslot, preferring highest stat
function TradeSkills.Cooking:SelectFoodToQuickslot()
    local highestStat = self:GetHighestPlayerStat()
    
    local foods = {}
    local bagSize = GetBagSize(BAG_BACKPACK)
    for slot = 0, bagSize - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slot)
        if itemLink and itemLink ~= "" then
            local itemType = GetItemLinkItemType(itemLink)
            if itemType == ITEMTYPE_FOOD then
                local quality = GetItemLinkQuality(itemLink)
                local statType = self:GetFoodStatType(itemLink)
                table.insert(foods, {
                    slot = slot,
                    quality = quality,
                    statType = statType,
                    link = itemLink,
                })
            end
        end
    end
    
    if #foods == 0 then return end
    
    local bestMatch = nil
    local bestTri = nil
    local bestAny = nil
    
    for _, food in ipairs(foods) do
        if food.statType == highestStat then
            if not bestMatch or food.quality > bestMatch.quality then
                bestMatch = food
            end
        elseif food.statType == "tri" then
            if not bestTri or food.quality > bestTri.quality then
                bestTri = food
            end
        end
        if not bestAny or food.quality > bestAny.quality then
            bestAny = food
        end
    end
    
    local chosen = bestMatch or bestTri or bestAny
    
    if chosen then
        local currentSlotIndex = GetCurrentQuickslot()
        CallSecureProtected("SelectSlotItem", BAG_BACKPACK, chosen.slot, currentSlotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    end
end

-- Called when any effect changes on the player (food buff tracking)
function TradeSkills.Cooking:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
    if not self:HasPerk(10) then return end
    if unitTag ~= "player" then return end
    
    if changeType == EFFECT_RESULT_FADED then
        if self:IsFoodBuff(abilityId, effectName, abilityType, iconFilename) then
            self._foodBuffActive = false
            -- Delay to avoid race with new buff application
            zo_callLater(function()
                if not self:HasFoodBuff() then
                    self:SelectFoodToQuickslot()
                end
            end, 1000)
        end
    elseif changeType == EFFECT_RESULT_GAINED then
        if self:IsFoodBuff(abilityId, effectName, abilityType, iconFilename) then
            self._foodBuffActive = true
        end
    end
end

-- Check on login if food buff is missing
function TradeSkills.Cooking:CheckFoodBuffOnLogin()
    if not self:HasPerk(10) then return end
    zo_callLater(function()
        if not self:HasFoodBuff() then
            self._foodBuffActive = false
            self:SelectFoodToQuickslot()
        else
            self._foodBuffActive = true
        end
    end, 5000)
end

-- Check if the current quickslot has food in it
function TradeSkills.Cooking:QuickslotHasFood()
    local slotIndex = GetCurrentQuickslot()
    if not slotIndex then return false end
    local itemLink = GetSlotItemLink(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    if not itemLink or itemLink == "" then return false end
    local itemType = GetItemLinkItemType(itemLink)
    return itemType == ITEMTYPE_FOOD
end

-- Start monitoring quickslot to ensure food is always slotted
function TradeSkills.Cooking:StartQuickslotMonitor()
    if not self:HasPerk(10) then return end
    EVENT_MANAGER:RegisterForUpdate(TradeSkills.name .. "_FOODSLOT", 3000, function()
        if not TradeSkills.Cooking:HasPerk(10) then return end
        -- Only fill if quickslot has neither food nor drink (don't override Quick Drink)
        local slotIndex = GetCurrentQuickslot()
        if slotIndex then
            local itemLink = GetSlotItemLink(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
            if itemLink and itemLink ~= "" then
                local itemType = GetItemLinkItemType(itemLink)
                if itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
                    return -- Already has food or drink, don't touch it
                end
            end
        end
        TradeSkills.Cooking:SelectFoodToQuickslot()
    end)
end

-- =======================
-- COOKING PERK: MASTER CHEF'S MARGIN (Level 30)
-- =======================
-- At provisioning stations, shows recipes you can craft while keeping 200+ of each ingredient.

function TradeSkills.Cooking:CreateMarginWindow()
    if self._marginWindow then return end
    
    local window = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_MarginWindow")
    window:SetDimensions(400, 500)
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 20, 100)
    window:SetHidden(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    
    -- Background
    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.08, 0.06, 0.04, 0.92)
    bg:SetEdgeColor(0.6, 0.5, 0.3, 0.8)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)
    
    -- Title
    local title = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    title:SetFont("ZoFontGameBold")
    title:SetAnchor(TOP, window, TOP, 0, 10)
    title:SetText("|cC8A060Master Chef's Margin|r")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetDimensions(380, 24)
    
    -- Subtitle
    local subtitle = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    subtitle:SetFont("ZoFontGameSmall")
    subtitle:SetAnchor(TOP, title, BOTTOM, 0, 2)
    subtitle:SetText("|c888888Recipes craftable while keeping 200+ of each ingredient|r")
    subtitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    subtitle:SetDimensions(380, 20)
    
    -- Scroll container
    local scroll = WINDOW_MANAGER:CreateControlFromVirtual("TradeSkills_MarginScroll", window, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 58)
    scroll:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -10, -10)
    
    local scrollChild = scroll:GetNamedChild("ScrollChild")
    
    -- Content label inside scroll child
    local content = WINDOW_MANAGER:CreateControl(nil, scrollChild, CT_LABEL)
    content:SetFont("ZoFontGame")
    content:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 5, 0)
    content:SetWidth(355)
    content:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    content:SetVerticalAlignment(TEXT_ALIGN_TOP)
    content:SetMaxLineCount(200)
    
    self._marginWindow = window
    self._marginScroll = scroll
    self._marginScrollChild = scrollChild
    self._marginContent = content
end

-- Scan all known food recipes and find which can be crafted while keeping 200+ ingredients
-- Count how many of a specific item (by link) the player has across all bags
function TradeSkills.Cooking:CountItemInInventory(searchLink)
    if not searchLink or searchLink == "" then return 0 end
    
    local searchName = zo_strformat("<<1>>", GetItemLinkName(searchLink))
    if not searchName or searchName == "" then return 0 end
    searchName = string.lower(searchName)
    
    -- Use cached inventory if available and recent (within 5 seconds)
    if not TradeSkills._inventoryCache or 
       not TradeSkills._inventoryCacheTime or
       (GetGameTimeMilliseconds() - TradeSkills._inventoryCacheTime) > 5000 then
        TradeSkills.BuildInventoryCache()
    end
    
    local total = TradeSkills._inventoryCache[searchName] or 0
    
    -- Also check craft bag (direct lookup is fast)
    local itemId = GetItemLinkItemId(searchLink)
    if itemId and itemId > 0 then
        local _, stackCount = GetItemInfo(BAG_VIRTUAL, itemId)
        if stackCount and stackCount > 0 then
            total = total + stackCount
        end
    end
    
    return total
end

-- Debug command to test ingredient counting for first known food recipe
function TradeSkills.Cooking:ScanCraftableRecipes()
    if not self:HasPerk(30) then
        return
    end
    if not self._marginWindow then self:CreateMarginWindow() end
    
    local MARGIN = 200
    local BATCH_SIZE = 15
    local craftableRecipes = {}
    
    -- Build inventory cache once upfront
    TradeSkills.BuildInventoryCache()
    
    local numRecipeLists = GetNumRecipeLists()
    local listIndex = 1
    local recipeIndex = 1
    local numRecipesInList = 0
    
    if numRecipeLists > 0 then
        _, numRecipesInList = GetRecipeListInfo(1)
    end
    
    -- Show loading state
    self._marginContent:SetText("|c888888Scanning food recipes...|r")
    self._marginWindow:SetHidden(false)
    
    local pollName = TradeSkills.name .. "_FOODSCAN"
    EVENT_MANAGER:UnregisterForUpdate(pollName)
    
    EVENT_MANAGER:RegisterForUpdate(pollName, 1, function()
        local processed = 0
        
        while processed < BATCH_SIZE and listIndex <= numRecipeLists do
            if recipeIndex <= numRecipesInList then
                local known, recipeName, numIngredients = GetRecipeInfo(listIndex, recipeIndex)
                
                if known and numIngredients and numIngredients > 0 then
                    local resultLink = GetRecipeResultItemLink(listIndex, recipeIndex, LINK_STYLE_DEFAULT)
                    if resultLink and resultLink ~= "" then
                        local itemType = GetItemLinkItemType(resultLink)
                        
                        if itemType == ITEMTYPE_FOOD then
                            local allAboveMargin = true
                            local maxCrafts = math.huge
                            
                            for i = 1, numIngredients do
                                local ingredientName, _, requiredQty = GetRecipeIngredientItemInfo(listIndex, recipeIndex, i)
                                local ingredientLink = GetRecipeIngredientItemLink(listIndex, recipeIndex, i, LINK_STYLE_DEFAULT)
                                local haveCount = self:CountItemInInventory(ingredientLink)
                                
                                if haveCount < MARGIN then
                                    allAboveMargin = false
                                    break
                                end
                                
                                local available = haveCount - MARGIN
                                if requiredQty > 0 then
                                    local craftsFromThis = math.floor(available / requiredQty)
                                    maxCrafts = math.min(maxCrafts, craftsFromThis)
                                end
                            end
                            
                            if allAboveMargin and maxCrafts > 0 then
                                local cleanName = zo_strformat("<<1>>", recipeName)
                                table.insert(craftableRecipes, {
                                    name = cleanName,
                                    count = maxCrafts,
                                    quality = GetItemLinkQuality(resultLink),
                                })
                            end
                        end
                    end
                end
                
                recipeIndex = recipeIndex + 1
                processed = processed + 1
            else
                listIndex = listIndex + 1
                recipeIndex = 1
                if listIndex <= numRecipeLists then
                    _, numRecipesInList = GetRecipeListInfo(listIndex)
                end
            end
        end
        
        -- Done scanning
        if listIndex > numRecipeLists then
            EVENT_MANAGER:UnregisterForUpdate(pollName)
            
            table.sort(craftableRecipes, function(a, b)
                if a.quality ~= b.quality then return a.quality > b.quality end
                return a.name < b.name
            end)
            
            if #craftableRecipes == 0 then
                self._marginContent:SetText("|c888888No food recipes found where you have\n200+ of every ingredient.|r")
            else
                local lines = {}
                for _, recipe in ipairs(craftableRecipes) do
                    local qualityColor = GetItemQualityColor(recipe.quality)
                    local colorHex = qualityColor and qualityColor:ToHex() or "FFFFFF"
                    table.insert(lines, string.format("|c%s%s|r |cFFFFFFx%d|r", colorHex, recipe.name, recipe.count))
                end
                self._marginContent:SetText(table.concat(lines, "\n"))
            end
            
            local textHeight = self._marginContent:GetTextHeight()
            self._marginScrollChild:SetHeight(textHeight + 10)
        end
    end)
end

function TradeSkills.Cooking:HideMarginWindow()
    if self._marginWindow then
        self._marginWindow:SetHidden(true)
    end
end

-- =======================
-- BREWING MODULE
-- =======================
TradeSkills.Brewing = {
    name = "Brewing",
    color = {0.7, 0.3, 0.9, 1},
    icon = "TradeSkills/icons/ts_brewing.dds",
    RECIPES_PER_LEVEL = 6,
    MAX_LEVEL = 47,
    TOTAL_RECIPES = 282,
    RANKS = {
        {level = 0, name = "Brewer", color = {0.6, 0.6, 0.6, 1}},
        {level = 16, name = "Brewmaster", color = {0.8, 0.4, 0.9, 1}},
        {level = 31, name = "Master Distiller", color = {0.9, 0.5, 1, 1}},
        {level = 47, name = "Alchemist", color = {1, 0.6, 1, 1}}
    },
    passiveAbilities = {
        {
            name = "Quick Drink",
            icon = "TradeSkills/icons/quickdrink.dds",
            level = 10,
            description = "Auto-selects a drink to your quickslot when your drink buff expires.",
        },
        {
            name = "Efficiency Calculator",
            icon = "TradeSkills/icons/effcalc.dds",
            level = 30,
            description = "Shows crafting cost vs market value at provisioning stations. Recipes highlighted in gold if profitable. Requires LibPrice and TamrielTradeCentre.",
        },
    },
    _debugPerks = false,
    _drinkBuffActive = false,
    _lastQuickslotIndex = nil,
}

function TradeSkills.Brewing:GetCount()
    local count = 0
    for _ in pairs(TradeSkills.savedVars.brewing.knownRecipes) do
        count = count + 1
    end
    return count
end

function TradeSkills.Brewing:GetLevel()
    local level = math.floor(self:GetCount() / self.RECIPES_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function TradeSkills.Brewing:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.RECIPES_PER_LEVEL, self.RECIPES_PER_LEVEL
    end
    return count % self.RECIPES_PER_LEVEL, self.RECIPES_PER_LEVEL
end

function TradeSkills.Brewing:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function TradeSkills.Brewing:GetDescription()
    return string.format("Learn drink recipes to increase skill.\nEvery 6 recipes increases your level by 1. Max level 47.\n\nDrink Recipes Known: %d/%d", 
        self:GetCount(), self.TOTAL_RECIPES)
end

function TradeSkills.Brewing:HasPerk(requiredLevel)
    if self._debugPerks then
        return not TradeSkills.IsPerkDisabled("Brewing", requiredLevel)
    end
    if self:GetLevel() < requiredLevel then return false end
    return not TradeSkills.IsPerkDisabled("Brewing", requiredLevel)
end

-- =======================
-- BREWING PERK: QUICK DRINK (Level 10)
-- =======================
-- Auto-selects a drink from inventory to quickslot when drink buff expires.
-- Uses EVENT_EFFECT_CHANGED to detect buff fading, then scans inventory for drinks.

-- Known drink buff ability IDs (food buffs that restore magicka, health regen, etc.)
-- We detect drink buffs by checking if the buff name contains drink-related patterns
-- or by checking the abilityType from the effect change event.

function TradeSkills.Brewing:IsDrinkBuff(abilityId, buffName, abilityType, iconFilename)
    -- Check if LibFoodDrinkBuff is available for accurate detection
    if LibFoodDrinkBuff then
        local isDrink = LibFoodDrinkBuff:IsAbilityADrinkBuff(abilityId)
        if isDrink ~= nil then return isDrink end
        local isFood = LibFoodDrinkBuff:IsAbilityAFoodBuff(abilityId)
        if isFood then return false end
    end
    -- Fallback: ESO food/drink buffs use the potion icon and have specific abilityType values
    -- abilityType 0 (ABILITY_NONE) = beverages, abilityType 5 (ABILITY_BONUS) = foods
    -- The food/drink icon is consistently "/esoui/art/icons/icon_potion_full.dds"
    if iconFilename and string.find(iconFilename, "icon_potion_full") then
        -- It's a food or drink buff
        if abilityType == 0 or abilityType == ABILITY_TYPE_NONE then
            return true  -- Beverage/drink
        end
        return false  -- Food
    end
    return false
end

-- Check if player currently has an active drink buff
function TradeSkills.Brewing:HasActiveDrinkBuff()
    -- Try LibFoodDrinkBuff first
    if LibFoodDrinkBuff then
        local isActive = LibFoodDrinkBuff:IsFoodBuffActive("player")
        if isActive then
            local buffType, isDrink = LibFoodDrinkBuff:GetFoodBuffInfos("player")
            if isDrink then return true end
        end
    end
    -- Fallback: scan buffs manually
    local numBuffs = GetNumBuffs("player")
    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)
        if buffName and timeEnding > 0 and self:IsDrinkBuff(abilityId, buffName, abilityType, iconFilename) then
            return true
        end
    end
    return false
end

-- Determine which stat a drink boosts by checking its item link tooltip/ability info
function TradeSkills.Brewing:GetDrinkStatType(itemLink)
    -- Check the drink's equip effect to determine what stat it boosts
    local hasAbility, abilityDesc = GetItemLinkOnUseAbilityInfo(itemLink)
    if not hasAbility then
        -- Fallback: try trait/effect info
        local traitInfo = GetItemLinkTraitInfo(itemLink)
    end
    
    -- Check the item's name and description for stat keywords
    local name = string.lower(zo_strformat("<<1>>", GetItemLinkName(itemLink)))
    local flavorText = string.lower(GetItemLinkFlavorText(itemLink) or "")
    
    -- Also check the drink's buff description if available
    local equipDesc = ""
    local numEquipEffects = GetItemLinkNumOnUseAbilities and GetItemLinkNumOnUseAbilities(itemLink) or 0
    -- Try getting the on-use ability description directly
    if abilityDesc then
        equipDesc = string.lower(abilityDesc)
    end
    
    -- Parse the actual item tooltip for stat references
    -- GetItemLinkOnUseAbilityInfo returns: hasAbility, abilityDescription
    local combined = name .. " " .. flavorText .. " " .. equipDesc
    
    -- Check for tri-stat drinks first (boost all 3)
    if (string.find(combined, "health") and string.find(combined, "magicka") and string.find(combined, "stamina")) then
        return "tri"
    end
    
    -- Score each stat
    local hasHealth = string.find(combined, "health") and true or false
    local hasMagicka = string.find(combined, "magicka") and true or false
    local hasStamina = string.find(combined, "stamina") and true or false
    
    if hasStamina and not hasMagicka and not hasHealth then return "stamina" end
    if hasMagicka and not hasStamina and not hasHealth then return "magicka" end
    if hasHealth and not hasMagicka and not hasStamina then return "health" end
    if hasStamina and hasMagicka then return "tri" end
    if hasStamina and hasHealth then return "tri" end
    if hasMagicka and hasHealth then return "tri" end
    
    return "unknown"
end

-- Get the player's highest base stat
function TradeSkills.Brewing:GetHighestPlayerStat()
    local health = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)
    local magicka = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_MAGICKA)
    local stamina = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
    
    -- Use max values (2nd return from GetUnitPower)
    local _, maxHealth = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)
    local _, maxMagicka = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_MAGICKA)
    local _, maxStamina = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
    
    if maxStamina >= maxMagicka and maxStamina >= maxHealth then
        return "stamina", maxStamina
    elseif maxMagicka >= maxStamina and maxMagicka >= maxHealth then
        return "magicka", maxMagicka
    else
        return "health", maxHealth
    end
end

-- Find a drink in inventory and select it to quickslot, preferring the player's highest stat
function TradeSkills.Brewing:SelectDrinkToQuickslot()
    local highestStat = self:GetHighestPlayerStat()
    
    -- Collect all drinks from inventory with their stat type and quality
    local drinks = {}
    local bagSize = GetBagSize(BAG_BACKPACK)
    for slot = 0, bagSize - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slot)
        if itemLink and itemLink ~= "" then
            local itemType = GetItemLinkItemType(itemLink)
            if itemType == ITEMTYPE_DRINK then
                local quality = GetItemLinkQuality(itemLink)
                local statType = self:GetDrinkStatType(itemLink)
                table.insert(drinks, {
                    slot = slot,
                    quality = quality,
                    statType = statType,
                    link = itemLink,
                })
            end
        end
    end
    
    if #drinks == 0 then
        if self._debugPerks then
            d("[TradeSkills] Quick Drink: No drinks found in inventory.")
        end
        return
    end
    
    -- Priority: 1) Exact stat match, 2) Tri-stat, 3) Any drink
    -- Within each priority, pick highest quality
    local bestMatch = nil
    local bestTri = nil
    local bestAny = nil
    
    for _, drink in ipairs(drinks) do
        if drink.statType == highestStat then
            if not bestMatch or drink.quality > bestMatch.quality then
                bestMatch = drink
            end
        elseif drink.statType == "tri" then
            if not bestTri or drink.quality > bestTri.quality then
                bestTri = drink
            end
        end
        if not bestAny or drink.quality > bestAny.quality then
            bestAny = drink
        end
    end
    
    local chosen = bestMatch or bestTri or bestAny
    
    if chosen then
        -- Add the drink to the current quickslot (player presses Q to use)
        local currentSlotIndex = GetCurrentQuickslot()
        CallSecureProtected("SelectSlotItem", BAG_BACKPACK, chosen.slot, currentSlotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    end
end

-- Called when any effect changes on the player
function TradeSkills.Brewing:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
    if not self:HasPerk(10) then return end
    if unitTag ~= "player" then return end
    
    -- changeType: EFFECT_RESULT_GAINED = 1, EFFECT_RESULT_FADED = 2
    if changeType == EFFECT_RESULT_FADED then
        -- A buff faded - check if it was a drink buff
        if self:IsDrinkBuff(abilityId, effectName, abilityType, iconFilename) then
            self._drinkBuffActive = false
            if self._debugPerks then
                d("[TradeSkills] Quick Drink: Drink buff expired (" .. tostring(effectName) .. ")")
            end
            -- Small delay to avoid issues during combat transitions
            zo_callLater(function()
                -- Double-check no new drink buff has been applied
                if not self:HasActiveDrinkBuff() then
                    self:SelectDrinkToQuickslot()
                end
            end, 1000)
        end
    elseif changeType == EFFECT_RESULT_GAINED then
        if self:IsDrinkBuff(abilityId, effectName, abilityType, iconFilename) then
            self._drinkBuffActive = true
        end
    end
end

-- Check on login if drink buff is missing
function TradeSkills.Brewing:CheckDrinkBuffOnLogin()
    if not self:HasPerk(10) then return end
    -- Delay to let buffs load
    zo_callLater(function()
        if not self:HasActiveDrinkBuff() then
            self._drinkBuffActive = false
            self:SelectDrinkToQuickslot()
        else
            self._drinkBuffActive = true
        end
    end, 5000)
end

-- Check if the current quickslot has a drink in it
function TradeSkills.Brewing:QuickslotHasDrink()
    local slotIndex = GetCurrentQuickslot()
    if not slotIndex then return false end
    local itemLink = GetSlotItemLink(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    if not itemLink or itemLink == "" then return false end
    local itemType = GetItemLinkItemType(itemLink)
    return itemType == ITEMTYPE_DRINK
end

-- Start monitoring quickslot to ensure a drink is always slotted
function TradeSkills.Brewing:StartQuickslotMonitor()
    if not self:HasPerk(10) then return end
    EVENT_MANAGER:RegisterForUpdate(TradeSkills.name .. "_DRINKSLOT", 3000, function()
        if not TradeSkills.Brewing:HasPerk(10) then return end
        -- Only fill if quickslot has neither a drink nor food (don't override Quick Eat)
        local slotIndex = GetCurrentQuickslot()
        if slotIndex then
            local itemLink = GetSlotItemLink(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
            if itemLink and itemLink ~= "" then
                local itemType = GetItemLinkItemType(itemLink)
                if itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_FOOD then
                    return -- Already has food or drink, don't touch it
                end
            end
        end
        TradeSkills.Brewing:SelectDrinkToQuickslot()
    end)
end

-- =======================
-- BREWING PERK: EFFICIENCY CALCULATOR (Level 30)
-- =======================
-- At provisioning stations, shows cost to craft vs market value.
-- Requires MasterMerchant or TamrielTradeCentre for price data.

function TradeSkills.Brewing:GetItemMarketPrice(itemLink)
    if not itemLink or itemLink == "" then return nil end
    
    -- Try LibPrice first (unified price API that aggregates multiple sources)
    if LibPrice and LibPrice.ItemLinkToPriceGold then
        local gold = LibPrice.ItemLinkToPriceGold(itemLink)
        if gold and gold > 0 then return gold end
    end
    
    -- Try TamrielTradeCentre directly
    if TamrielTradeCentrePrice and TamrielTradeCentrePrice.GetPriceInfo then
        local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
        if priceInfo then
            if priceInfo.SuggestedPrice and priceInfo.SuggestedPrice > 0 then
                return priceInfo.SuggestedPrice
            elseif priceInfo.Avg and priceInfo.Avg > 0 then
                return priceInfo.Avg
            end
        end
    end
    
    return nil
end

-- Calculate cost to craft a recipe (sum of ingredient market prices)
function TradeSkills.Brewing:GetRecipeCraftCost(recipeListIndex, recipeIndex)
    local totalCost = 0
    local missingPrice = false
    
    local _, _, numIngredients = GetRecipeInfo(recipeListIndex, recipeIndex)
    if not numIngredients or numIngredients == 0 then return 0, true end
    
    for i = 1, numIngredients do
        local ingredientLink = GetRecipeIngredientItemLink(recipeListIndex, recipeIndex, i, LINK_STYLE_DEFAULT)
        local _, _, requiredQty = GetRecipeIngredientItemInfo(recipeListIndex, recipeIndex, i)
        local price = self:GetItemMarketPrice(ingredientLink)
        if price then
            totalCost = totalCost + (price * (requiredQty or 1))
        else
            missingPrice = true
        end
    end
    
    return totalCost, missingPrice
end

-- Get market value of crafted result
function TradeSkills.Brewing:GetRecipeResultValue(recipeListIndex, recipeIndex)
    local resultLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex, LINK_STYLE_DEFAULT)
    if not resultLink or resultLink == "" then return nil end
    return self:GetItemMarketPrice(resultLink)
end

-- Create the Efficiency Calculator floating window
function TradeSkills.Brewing:CreateEfficiencyWindow()
    if self._effWindow then return end
    
    local window = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_EfficiencyWindow")
    window:SetDimensions(340, 140)
    window:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -20, 200)
    window:SetHidden(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    
    -- Background
    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.08, 0.06, 0.04, 0.92)
    bg:SetEdgeColor(0.6, 0.5, 0.3, 0.8)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)
    
    -- Title
    local title = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    title:SetFont("ZoFontGameBold")
    title:SetAnchor(TOP, window, TOP, 0, 8)
    title:SetText("|cC8A060Efficiency Calculator|r")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    
    -- Recipe name
    local recipeName = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    recipeName:SetFont("ZoFontGame")
    recipeName:SetAnchor(TOP, title, BOTTOM, 0, 6)
    recipeName:SetDimensions(320, 20)
    recipeName:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    recipeName:SetColor(1, 1, 1, 1)
    
    -- Craft cost line
    local craftCostLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    craftCostLabel:SetFont("ZoFontGame")
    craftCostLabel:SetAnchor(TOP, recipeName, BOTTOM, 0, 6)
    craftCostLabel:SetDimensions(320, 20)
    craftCostLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    
    -- Market value line
    local marketLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    marketLabel:SetFont("ZoFontGame")
    marketLabel:SetAnchor(TOP, craftCostLabel, BOTTOM, 0, 4)
    marketLabel:SetDimensions(320, 20)
    marketLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    
    -- Profit/Loss line
    local profitLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    profitLabel:SetFont("ZoFontGameBold")
    profitLabel:SetAnchor(TOP, marketLabel, BOTTOM, 0, 6)
    profitLabel:SetDimensions(320, 24)
    profitLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    
    self._effWindow = window
    self._effRecipeName = recipeName
    self._effCraftCost = craftCostLabel
    self._effMarketValue = marketLabel
    self._effProfit = profitLabel
end

-- Show efficiency info for a selected recipe at the provisioning station
function TradeSkills.Brewing:ShowEfficiencyInfo(recipeListIndex, recipeIndex)
    if not self:HasPerk(30) then return end
    if not self._effWindow then self:CreateEfficiencyWindow() end
    
    local known, recipeName, numIngredients = GetRecipeInfo(recipeListIndex, recipeIndex)
    if not recipeName or recipeName == "" then return end
    
    local cleanName = zo_strformat("<<1>>", recipeName)
    self._effRecipeName:SetText("|cFFFFFF" .. cleanName .. "|r")
    
    local craftCost, missingPrice = self:GetRecipeCraftCost(recipeListIndex, recipeIndex)
    local resultValue = self:GetRecipeResultValue(recipeListIndex, recipeIndex)
    
    -- Craft cost
    if craftCost > 0 then
        local costText = string.format("Craft Cost: %dg", craftCost)
        if missingPrice then costText = costText .. " (partial)" end
        self._effCraftCost:SetText(costText)
        self._effCraftCost:SetColor(0.9, 0.8, 0.6, 1)
    else
        self._effCraftCost:SetText("Craft Cost: No price data")
        self._effCraftCost:SetColor(0.5, 0.5, 0.5, 1)
    end
    
    -- Market value
    if resultValue and resultValue > 0 then
        self._effMarketValue:SetText(string.format("Market Value: %dg", resultValue))
        self._effMarketValue:SetColor(0.9, 0.8, 0.6, 1)
    else
        self._effMarketValue:SetText("Market Value: Unknown")
        self._effMarketValue:SetColor(0.5, 0.5, 0.5, 1)
    end
    
    -- Profit/Loss
    if resultValue and resultValue > 0 and craftCost > 0 then
        if resultValue > craftCost then
            local profit = resultValue - craftCost
            self._effProfit:SetText(string.format("|c00FF00PROFIT: +%dg|r", profit))
        else
            local loss = craftCost - resultValue
            self._effProfit:SetText(string.format("|cFF4444LOSS: -%dg|r", loss))
        end
    elseif not resultValue or not craftCost or craftCost == 0 then
        self._effProfit:SetText("|c888888Install LibPrice + TTC for prices|r")
    else
        self._effProfit:SetText("")
    end
    
    self._effWindow:SetHidden(false)
end

function TradeSkills.Brewing:HideEfficiencyInfo()
    if self._effWindow then
        self._effWindow:SetHidden(true)
    end
    if self._effPollName then
        EVENT_MANAGER:UnregisterForUpdate(self._effPollName)
        self._effPollName = nil
    end
end

-- Poll for selected recipe changes while at provisioning station
function TradeSkills.Brewing:StartEfficiencyPolling()
    if not self:HasPerk(30) then
        return
    end
    
    self._effLastRecipeKey = nil
    local pollName = TradeSkills.name .. "_EFFPOLL"
    
    -- Unregister any existing poll first
    EVENT_MANAGER:UnregisterForUpdate(pollName)
    self._effPollName = pollName
    
    
    EVENT_MANAGER:RegisterForUpdate(pollName, 500, function()
        if not self._atProvisioningStation then
            self:HideEfficiencyInfo()
            return
        end
        
        -- Try multiple approaches to find the selected recipe
        local recipeListIndex, recipeIndex
        
        -- Determine which provisioner object to use (keyboard or gamepad)
        local provObj = PROVISIONER
        if IsInGamepadPreferredMode and IsInGamepadPreferredMode() and GAMEPAD_PROVISIONER then
            provObj = GAMEPAD_PROVISIONER
        end
        
        -- Approach 1: Direct PROVISIONER members (various ESO versions use different names)
        if provObj then
            -- Check common member variable names
            recipeListIndex = provObj.selectedRecipeListIndex 
                or provObj.m_selectedRecipeListIndex
                or provObj.recipeListIndex
            recipeIndex = provObj.selectedRecipeIndex 
                or provObj.m_selectedRecipeIndex
                or provObj.recipeIndex
            
            -- Approach 2: Try the recipe tree's selected data
            if not (recipeListIndex and recipeIndex) then
                local tree = provObj.recipeTree or provObj.m_recipeTree
                if tree then
                    local node = tree.selectedNode or tree:GetSelectedNode()
                    if node then
                        local data = node.data or (node.GetData and node:GetData())
                        if data then
                            recipeListIndex = data.recipeListIndex
                            recipeIndex = data.recipeIndex
                        end
                    end
                end
            end
            
            -- Approach 3: Scan for any table with recipeListIndex
            if not (recipeListIndex and recipeIndex) then
                for k, v in pairs(provObj) do
                    if type(v) == "table" and v.recipeListIndex and v.recipeIndex then
                        recipeListIndex = v.recipeListIndex
                        recipeIndex = v.recipeIndex
                        break
                    end
                end
            end
        end
        
        if recipeListIndex and recipeIndex then
            local key = recipeListIndex .. "_" .. recipeIndex
            if key ~= self._effLastRecipeKey then
                self._effLastRecipeKey = key
                self:ShowEfficiencyInfo(recipeListIndex, recipeIndex)
            end
        end
    end)
end

-- =======================
-- STYLE MASTERY MODULE
-- =======================
TradeSkills.StyleMastery = {
    name = "Style Mastery",
    color = {0.6, 0.4, 0.8, 1},
    icon = "TradeSkills/icons/motif.dds",
    PAGES_PER_LEVEL = 25,
    MAX_LEVEL = 80,
    TOTAL_PAGES = 2000,
    RANKS = {
        {level = 0, name = "Apprentice Stylist", color = {0.6, 0.6, 0.6, 1}},
        {level = 25, name = "Journeyman Artisan", color = {0.7, 0.5, 0.8, 1}},
        {level = 50, name = "Master Craftsman", color = {0.8, 0.6, 0.9, 1}},
        {level = 80, name = "Style Grandmaster", color = {1, 0.8, 1, 1}}
    },
    passiveAbilities = {
        {
            name = "Visual Completionist",
            icon = "TradeSkills/icons/style_scholar.dds",
            level = 5,
            description = "When looting a motif page, shows a progress bar for that style.",
        },
        {
            name = "Motif Map",
            icon = "TradeSkills/icons/zone_motifs.dds",
            level = 10,
            description = "On the zone map, shows which motifs are known to drop in that zone.",
        },
    },
    _debugPerks = false,
}

function TradeSkills.StyleMastery:GetCount()
    -- Use cached count from scan (always accurate via IsSmithingStyleKnown)
    return self._knownPageCount or 0
end

function TradeSkills.StyleMastery:GetLevel()
    local level = math.floor(self:GetCount() / self.PAGES_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function TradeSkills.StyleMastery:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.PAGES_PER_LEVEL, self.PAGES_PER_LEVEL
    end
    return count % self.PAGES_PER_LEVEL, self.PAGES_PER_LEVEL
end

function TradeSkills.StyleMastery:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function TradeSkills.StyleMastery:GetDescription()
    return string.format("Learn motif pages to increase skill.\nEvery 25 pages increases your level by 1. Max level 80.\n\nMotif Pages Known: %d/%d",
        self:GetCount(), self.TOTAL_PAGES)
end

-- Scan all smithing styles to get accurate count of known motif pages
-- Called on login and after learning new pages
function TradeSkills.StyleMastery:ScanMotifPages()
    -- Async motif scan: 200 styles x 14 pieces = 2800 checks, spread across frames
    local BATCH_SIZE = 100
    local count = 0
    local styleIndex = 1
    local pieceIndex = 1
    
    local pollName = TradeSkills.name .. "_MOTIFSCAN"
    EVENT_MANAGER:UnregisterForUpdate(pollName)
    
    EVENT_MANAGER:RegisterForUpdate(pollName, 1, function()
        local processed = 0
        
        while processed < BATCH_SIZE and styleIndex <= 200 do
            if IsSmithingStyleKnown(styleIndex, pieceIndex) then
                count = count + 1
            end
            
            pieceIndex = pieceIndex + 1
            if pieceIndex > 14 then
                pieceIndex = 1
                styleIndex = styleIndex + 1
            end
            processed = processed + 1
        end
        
        if styleIndex > 200 then
            EVENT_MANAGER:UnregisterForUpdate(pollName)
            self._knownPageCount = count
            TradeSkills.CheckLevelUps()
            TradeSkills.UpdateWindow()
        end
    end)
end

function TradeSkills.StyleMastery:HasPerk(requiredLevel)
    if self._debugPerks then
        return not TradeSkills.IsPerkDisabled("Style Mastery", requiredLevel)
    end
    if self:GetLevel() < requiredLevel then return false end
    return not TradeSkills.IsPerkDisabled("Style Mastery", requiredLevel)
end

-- =======================
-- STYLE MASTERY PERK: VISUAL COMPLETIONIST (Level 5)
-- =======================
-- When looting a motif page, shows a popup with a progress bar for that style.

-- Zone-to-motif mapping for Motif Map perk
TradeSkills.ZONE_MOTIF_DATA = {
    -- === SEASONAL / LATEST CONTENT (Update 46-48) ===
    ["Solstice"] = {"Tide-Born", "Stirk Fellowship", "Voskrona Guardian"},
    ["Western Solstice"] = {"Tide-Born", "Stirk Fellowship"},
    ["Eastern Solstice"] = {"Tide-Born", "Stirk Fellowship", "Voskrona Guardian"},

    -- === GOLD ROAD (2024) ===
    ["West Weald"] = {"The Recollection", "Blind Path Cultist", "Shardborn", "West Weald Legion", "Lucent Sentinel"},

    -- === NECROM (2023) ===
    ["Telvanni Peninsula"] = {"Dead Keeper", "Clan Dreamcarver", "Kindred's Concord"},
    ["Apocrypha"] = {"Dead Keeper", "Clan Dreamcarver", "Scribes of Mora"},

    -- === HIGH ISLE / FIRESONG (2022) ===
    ["High Isle"] = {"Ascendant Order", "Systres Guardian", "Steadfast Society"},
    ["Galen"] = {"Systres Guardian", "Firesong", "House Mornard"},

    -- === DEADLANDS / BLACKWOOD (2021) ===
    ["The Deadlands"] = {"Deadlands Gladiator", "Fargrave Guardian", "Waking Flame"},
    ["Fargrave"] = {"Fargrave Guardian"},
    ["Blackwood"] = {"Ivory Brigade", "Black Fin Legion", "Sul-Xan"},

    -- === GREYMOOR / MARKARTH (2020) ===
    ["Western Skyrim"] = {"Greymoor", "Sea Giant"},
    ["The Reach"] = {"Arkthzand Armory", "Nighthollow", "Wayward Guardian"},
    ["Blackreach"] = {"Greymoor", "Blackreach Vanguard"},

    -- === ELSWEYR (2019) ===
    ["Northern Elsweyr"] = {"Anequina", "Pellitine", "Sunspire"},
    ["Southern Elsweyr"] = {"Dragonguard", "New Moon Priest", "Shield of Senchal"},

    -- === SUMMERSET / MURKMIRE (2018) ===
    ["Summerset"] = {"Sapiarch", "Psijic Order", "Welkynar"},
    ["Artaeum"] = {"Psijic Order"},
    ["Murkmire"] = {"Dead-Water", "Elder Argonian", "Honor Guard"},

    -- === MORROWIND / CLOCKWORK CITY (2017) ===
    ["Vvardenfell"] = {"Buoyant Armiger", "Morag Tong", "Telvanni", "Hlaalu", "Redoran"},
    ["Clockwork City"] = {"Apostle", "Ebonshadow", "Refabricated"},

    -- === ORSINIUM / DLC ZONES (2015-2016) ===
    ["Wrothgar"] = {"Malacath", "Trinimac", "Ancient Orc"},
    ["Hew's Bane"] = {"Thieves Guild", "Abah's Watch"},
    ["Gold Coast"] = {"Dark Brotherhood", "Minotaur", "Order of the Hour"},

    -- === CYRODIIL / IMPERIAL CITY ===
    ["Cyrodiil"] = {"Imperial", "Militant Ordinator", "Akaviri"},
    ["Imperial City"] = {"Imperial", "Xivkyn"},

    -- === CRAGLORN ===
    ["Craglorn"] = {"Celestial", "Yokudan", "Ra Gada"},

    -- === COLDHARBOUR ===
    ["Coldharbour"] = {"Xivkyn", "Soul Shriven", "Daedric"},

    -- === BASE GAME ZONES - ALDMERI DOMINION ===
    ["Auridon"] = {"High Elf", "Aldmeri Dominion"},
    ["Grahtwood"] = {"Wood Elf", "Aldmeri Dominion"},
    ["Greenshade"] = {"Wood Elf", "Aldmeri Dominion"},
    ["Malabal Tor"] = {"Wood Elf", "Silken Ring"},
    ["Reaper's March"] = {"Khajiit", "Aldmeri Dominion"},
    ["Khenarthi's Roost"] = {"Khajiit"},

    -- === BASE GAME ZONES - DAGGERFALL COVENANT ===
    ["Glenumbra"] = {"Breton", "Daggerfall Covenant"},
    ["Stormhaven"] = {"Breton", "Daggerfall Covenant"},
    ["Rivenspire"] = {"Breton", "Daggerfall Covenant"},
    ["Alik'r Desert"] = {"Redguard", "Daggerfall Covenant"},
    ["Bangkorai"] = {"Daggerfall Covenant", "Ra Gada"},
    ["Stros M'Kai"] = {"Redguard"},
    ["Betnikh"] = {"Orc"},

    -- === BASE GAME ZONES - EBONHEART PACT ===
    ["Stonefalls"] = {"Dark Elf", "Ebonheart Pact"},
    ["Deshaan"] = {"Dark Elf", "Ebonheart Pact"},
    ["Shadowfen"] = {"Argonian", "Ebonheart Pact"},
    ["Eastmarch"] = {"Nord", "Ebonheart Pact"},
    ["The Rift"] = {"Nord", "Ebonheart Pact"},
    ["Bal Foyen"] = {"Argonian", "Ebonheart Pact"},
    ["Bleakrock Isle"] = {"Nord"},

    -- === GROUP DUNGEONS (motif drops from final boss) ===
    -- Shadows of the Hist
    ["Ruins of Mazzatun"] = {"Mazzatun"},
    ["Cradle of Shadows"] = {"Silken Ring"},
    -- Horns of the Reach
    ["Bloodroot Forge"] = {"Bloodforge"},
    ["Falkreath Hold"] = {"Dreadhorn"},
    -- Dragon Bones
    ["Fang Lair"] = {"Fang Lair"},
    ["Scalecaller Peak"] = {"Scalecaller"},
    -- Wolfhunter
    ["March of Sacrifices"] = {"Huntsman"},
    ["Moon Hunter Keep"] = {"Silver Dawn"},
    -- Wrathstone
    ["Depths of Malatar"] = {"Meridian"},
    ["Frostvault"] = {"Coldsnap"},
    -- Scalebreaker
    ["Moongrave Fane"] = {"Moongrave Fane"},
    ["Lair of Maarselok"] = {"Stags of Z'en"},
    -- Harrowstorm
    ["Icereach"] = {"Icereach Coven"},
    ["Unhallowed Grave"] = {"Pyre Watch"},
    -- Stonethorn
    ["Stone Garden"] = {"Thorn Legion"},
    ["Castle Thorn"] = {"Hazardous Alchemy"},
    -- Flames of Ambition
    ["Black Drake Villa"] = {"True-Sworn"},
    ["The Cauldron"] = {"Waking Flame"},
    -- Waking Flame
    ["Red Petal Bastion"] = {"Crimson Oath"},
    ["The Dread Cellar"] = {"Silver Rose"},
    -- Ascending Tide
    ["Coral Aerie"] = {"Dreadsails"},
    ["Shipwright's Regret"] = {"Ascendant Order"},
    -- Lost Depths
    ["Earthen Root Enclave"] = {"Y'ffre's Will"},
    ["Graven Deep"] = {"Drowned Mariner"},
    -- Scribes of Fate
    ["Bal Sunnar"] = {"Scribes of Mora"},
    ["Scrivener's Hall"] = {"Blessed Inheritor"},
    -- Gold Road Dungeons
    ["Oathsworn Pit"] = {"The Recollection"},
    ["Bedlam Veil"] = {"Blind Path Cultist"},
    -- Fallen Banners Dungeons (2025)
    ["Voidcaller's Sanctum"] = {"Hircine Bloodhunter"},
    ["Dread Reef"] = {"Exile's Revenge"},
    -- Feast of Shadows Dungeons (2025)
    ["Soulwrack Spire"] = {"Militant Monk"},
    ["Oasis of Razors"] = {"Black Soul Gem"},

    -- === TRIALS ===
    ["Hel Ra Citadel"] = {"Celestial"},
    ["Aetherian Archive"] = {"Celestial"},
    ["Sanctum Ophidia"] = {"Celestial"},
    ["Maw of Lorkhaj"] = {"Dro-m'Athra"},
    ["Halls of Fabrication"] = {"Refabricated"},
    ["Cloudrest"] = {"Welkynar"},
    ["Sunspire"] = {"Sunspire"},
    ["Kyne's Aegis"] = {"Sea Giant"},
    ["Rockgrove"] = {"Sul-Xan"},
    ["Dreadsail Reef"] = {"Dreadsails"},
    ["Sanity's Edge"] = {"Kindred's Concord"},
    ["Lucent Citadel"] = {"Lucent Sentinel"},
    ["Ossein Cage"] = {"Coldharbour Dominator"},

    -- === ARENAS ===
    ["Maelstrom Arena"] = {"Outlaw"},
    ["Dragonstar Arena"] = {"Yokudan"},
    ["Vateshran Hollows"] = {"House Hexos"},
    ["Endless Archive"] = {"Clan Dreamcarver", "Dead Keeper"},
}

-- Style index to style name mapping
-- Maps the internal smithing style index to the proper style name.
-- Note: Style indices do NOT match motif numbers.
-- The first ~9 are racial styles, then they continue sequentially.
-- This table covers all 136 craftable styles as of Update 48.
-- If a style index isn't found here, we fall back to GetSmithingStyleItemInfo
-- and strip common suffixes like " Style Item" to get a cleaner name.
TradeSkills.STYLE_NAMES = {
    [1] = "Breton", [2] = "Redguard", [3] = "Orc", [4] = "Dark Elf",
    [5] = "Nord", [6] = "Argonian", [7] = "High Elf", [8] = "Wood Elf",
    [9] = "Khajiit", [10] = "Unique", [11] = "Thieves Guild",
    [12] = "Dark Brotherhood", [13] = "Primal", [14] = "Daedric",
    [15] = "Ancient Elf", [16] = "Imperial", [17] = "Barbaric",
    [18] = "Bandit", [19] = "Primitive", [20] = "Reach",
    [21] = "Glass", [22] = "Xivkyn", [23] = "Soul Shriven",
    [24] = "Dwemer", [25] = "Ancient Orc", [26] = "Trinimac",
    [27] = "Malacath", [28] = "Outlaw", [29] = "Aldmeri Dominion",
    [30] = "Daggerfall Covenant", [31] = "Ebonheart Pact",
    [32] = "Ra Gada", [33] = "Mercenary", [34] = "Yokudan",
    [35] = "Akaviri", [36] = "Silken Ring", [37] = "Mazzatun",
    [38] = "Ebony", [39] = "Draugr",
    [40] = "Skinchanger", [41] = "Minotaur", [42] = "Hollowjack",
    [43] = "Grim Harlequin", [44] = "Buoyant Armiger",
    [45] = "Stalhrim Frostcaster", [46] = "Ashlander",
    [47] = "Militant Ordinator", [48] = "Telvanni",
    [49] = "Hlaalu", [50] = "Redoran", [51] = "Tsaesci",
    [52] = "Celestial", [53] = "Worm Cult",
    [54] = "Refabricated", [55] = "Bloodforge", [56] = "Dreadhorn",
    [57] = "Apostle", [58] = "Ebonshadow", [59] = "Fang Lair",
    [60] = "Scalecaller", [61] = "Psijic Order", [62] = "Sapiarch",
    [63] = "Dremora", [64] = "Pyandonean", [65] = "Huntsman",
    [66] = "Silver Dawn", [67] = "Welkynar",
    [68] = "Honor Guard", [69] = "Dead-Water",
    [70] = "Elder Argonian", [71] = "Coldsnap", [72] = "Meridian",
    [73] = "Anequina", [74] = "Pellitine", [75] = "Sunspire",
    [76] = "Dragonguard", [77] = "Stags of Z'en",
    [78] = "Moongrave Fane", [79] = "New Moon Priest",
    [80] = "Shield of Senchal", [81] = "Icereach Coven",
    [82] = "Pyre Watch", [83] = "Blackreach Vanguard",
    [84] = "Greymoor", [85] = "Sea Giant",
    [86] = "Ancestral Nord", [87] = "Ancestral High Elf",
    [88] = "Ancestral Orc", [89] = "Thorn Legion",
    [90] = "Hazardous Alchemy", [91] = "Arkthzand Armory",
    [92] = "Nighthollow", [93] = "Wayward Guardian",
    [94] = "House Hexos", [95] = "True-Sworn",
    [96] = "Waking Flame", [97] = "Ancient Daedric",
    [98] = "Ivory Brigade", [99] = "Sul-Xan",
    [100] = "Black Fin Legion", [101] = "Crimson Oath",
    [102] = "Silver Rose", [103] = "Annihilarch's Chosen",
    [104] = "Fargrave Guardian", [105] = "Deadlands Gladiator",
    [106] = "Dreadsails", [107] = "Ascendant Order",
    [108] = "Syrabanic Marine", [109] = "Steadfast Society",
    [110] = "Systres Guardian", [111] = "Y'ffre's Will",
    [112] = "Drowned Mariner", [113] = "Firesong",
    [114] = "House Mornard", [115] = "Scribes of Mora",
    [116] = "Blessed Inheritor", [117] = "Clan Dreamcarver",
    [118] = "Dead Keeper", [119] = "Kindred's Concord",
    [120] = "The Recollection", [121] = "Blind Path Cultist",
    [122] = "Shardborn", [123] = "West Weald Legion",
    [124] = "Lucent Sentinel", [125] = "Hircine Bloodhunter",
    [126] = "Exile's Revenge", [127] = "Militant Monk",
    [128] = "Stirk Fellowship", [129] = "Coldharbour Dominator",
    [130] = "Tide-Born", [131] = "Black Soul Gem",
    [132] = "Voskrona Guardian",
    -- Crown Store / Special styles
    [133] = "Morag Tong",
    [134] = "Abah's Watch",
    [135] = "Trinimac",
    [136] = "Order of the Hour",
}

-- Get the number of known pages for a given style
function TradeSkills.StyleMastery:GetStyleProgress(styleIndex)
    local totalPages = 14  -- Most styles have 14 pages (armor + weapon types)
    local knownPages = 0
    
    if not styleIndex then return 0, totalPages end
    
    -- Check each armor/weapon piece type (14 total in ESO)
    for pieceIndex = 1, 14 do
        if IsSmithingStyleKnown(styleIndex, pieceIndex) then
            knownPages = knownPages + 1
        end
    end
    
    return knownPages, totalPages
end

-- Get style name from style index using our lookup table, with API fallback
function TradeSkills.StyleMastery:GetStyleName(styleIndex)
    if not styleIndex then return "Unknown" end
    if TradeSkills.STYLE_NAMES[styleIndex] then
        return TradeSkills.STYLE_NAMES[styleIndex]
    end
    -- Fallback: try the API and strip common suffixes
    local materialName = GetSmithingStyleItemInfo(styleIndex)
    if materialName and materialName ~= "" then
        return zo_strformat("<<1>>", materialName) .. " Style"
    end
    return "Style #" .. styleIndex
end

-- Create the Visual Completionist popup window
function TradeSkills.StyleMastery:CreateCompletionistPopup()
    if self._completionistPopup then return end
    
    local popup = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_CompletionistPopup")
    popup:SetDimensions(320, 80)
    popup:SetAnchor(TOP, GuiRoot, TOP, 0, 80)
    popup:SetHidden(true)
    popup:SetDrawLayer(DL_OVERLAY)
    popup:SetDrawTier(DT_HIGH)
    popup:SetMouseEnabled(false)
    
    local bg = WINDOW_MANAGER:CreateControl(nil, popup, CT_BACKDROP)
    bg:SetAnchorFill(popup)
    bg:SetCenterColor(0.06, 0.03, 0.08, 0.92)
    bg:SetEdgeColor(0.6, 0.4, 0.8, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)
    
    -- Style name label
    local nameLabel = WINDOW_MANAGER:CreateControl(nil, popup, CT_LABEL)
    nameLabel:SetFont("ZoFontGameBold")
    nameLabel:SetAnchor(TOPLEFT, popup, TOPLEFT, 12, 10)
    nameLabel:SetAnchor(TOPRIGHT, popup, TOPRIGHT, -12, 10)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetMaxLineCount(1)
    
    -- Progress bar background
    local barBg = WINDOW_MANAGER:CreateControl(nil, popup, CT_BACKDROP)
    barBg:SetAnchor(TOPLEFT, popup, TOPLEFT, 12, 40)
    barBg:SetAnchor(TOPRIGHT, popup, TOPRIGHT, -12, 40)
    barBg:SetHeight(18)
    barBg:SetCenterColor(0.1, 0.1, 0.1, 1)
    barBg:SetEdgeColor(0.3, 0.3, 0.3, 1)
    
    -- Progress bar fill
    local barFill = WINDOW_MANAGER:CreateControl(nil, popup, CT_BACKDROP)
    barFill:SetAnchor(TOPLEFT, barBg, TOPLEFT, 1, 1)
    barFill:SetDimensions(1, 16)
    barFill:SetCenterColor(0.6, 0.4, 0.8, 1)
    barFill:SetEdgeColor(0.6, 0.4, 0.8, 0)
    
    -- Progress text
    local progressLabel = WINDOW_MANAGER:CreateControl(nil, popup, CT_LABEL)
    progressLabel:SetFont("ZoFontGameSmall")
    progressLabel:SetAnchor(CENTER, barBg, CENTER, 0, 0)
    progressLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    progressLabel:SetColor(1, 1, 1, 1)
    
    self._completionistPopup = popup
    self._completionistName = nameLabel
    self._completionistBarBg = barBg
    self._completionistBarFill = barFill
    self._completionistProgress = progressLabel
end

function TradeSkills.StyleMastery:ShowCompletionistPopup(styleName, known, total)
    if not self._completionistPopup then self:CreateCompletionistPopup() end
    
    self._completionistName:SetText("|cC8A0E0" .. styleName .. "|r")
    self._completionistProgress:SetText(string.format("%d / %d Collected", known, total))
    
    -- Calculate bar width
    local barWidth = self._completionistBarBg:GetWidth() - 2
    local fillWidth = math.max(1, math.floor(barWidth * (known / total)))
    self._completionistBarFill:SetWidth(fillWidth)
    
    -- Color: green if complete, purple otherwise
    if known >= total then
        self._completionistBarFill:SetCenterColor(0.2, 0.9, 0.3, 1)
        self._completionistName:SetText("|c44FF44" .. styleName .. " - COMPLETE!|r")
    else
        self._completionistBarFill:SetCenterColor(0.6, 0.4, 0.8, 1)
    end
    
    self._completionistPopup:SetHidden(false)
    
    -- Auto-hide after 5 seconds
    zo_callLater(function()
        if self._completionistPopup then
            self._completionistPopup:SetHidden(true)
        end
    end, 5000)
end

-- =======================
-- STYLE MASTERY PERK: MOTIF MAP (Level 10)
-- =======================
-- When opening the zone map, shows which motifs drop in the current zone.

function TradeSkills.StyleMastery:CreateMotifMapWindow()
    if self._motifMapWindow then return end
    
    -- Create a standalone moveable window
    local window = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_MotifMapWindow")
    window:SetDimensions(320, 100)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    
    -- Restore saved position or use default
    local savedPos = TradeSkills.savedVars and TradeSkills.savedVars.stylemastery.motifMapPosition
    if savedPos then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedPos.x, savedPos.y)
    else
        window:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 20, -60)
    end
    
    -- Save position on move
    window:SetHandler("OnMoveStop", function()
        local left, top = window:GetLeft(), window:GetTop()
        if TradeSkills.savedVars then
            TradeSkills.savedVars.stylemastery.motifMapPosition = {x = left, y = top}
        end
    end)
    
    -- Background
    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.05, 0.03, 0.08, 0.92)
    bg:SetEdgeColor(0.6, 0.4, 0.8, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)
    
    -- Header
    local header = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    header:SetFont("ZoFontGameBold")
    header:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 8)
    header:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 8)
    header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    header:SetColor(0.78, 0.63, 0.88, 1)
    header:SetText("Motif Drops")
    self._motifMapHeader = header
    
    -- Zone name
    local zoneLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    zoneLabel:SetFont("ZoFontGame")
    zoneLabel:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 4)
    zoneLabel:SetAnchor(TOPRIGHT, header, BOTTOMRIGHT, 0, 4)
    zoneLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    zoneLabel:SetColor(0.9, 0.85, 0.7, 1)
    self._motifMapZone = zoneLabel
    
    -- Motif list
    local motifLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    motifLabel:SetFont("ZoFontGameSmall")
    motifLabel:SetAnchor(TOPLEFT, zoneLabel, BOTTOMLEFT, 0, 4)
    motifLabel:SetAnchor(TOPRIGHT, zoneLabel, BOTTOMRIGHT, 0, 4)
    motifLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    motifLabel:SetMaxLineCount(6)
    motifLabel:SetColor(1, 1, 1, 1)
    self._motifMapList = motifLabel
    
    self._motifMapWindow = window
end

function TradeSkills.StyleMastery:UpdateMotifMapDisplay()
    if not self:HasPerk(10) then return end
    if not self._motifMapWindow then self:CreateMotifMapWindow() end
    
    -- Only show when the world map scene is active
    local mapScene = SCENE_MANAGER:GetScene("worldMap")
    local gmapScene = SCENE_MANAGER:GetScene("gamepad_worldMap")
    local mapShowing = (mapScene and mapScene:IsShowing()) or (gmapScene and gmapScene:IsShowing())
    if not mapShowing then
        self._motifMapWindow:SetHidden(true)
        return
    end
    
    -- Get current zone name from the map
    local zoneName = zo_strformat("<<1>>", GetMapName())
    
    -- Look up motifs for this zone (exact match first)
    local motifs = TradeSkills.ZONE_MOTIF_DATA[zoneName]
    
    -- If no exact match, try substring matching (e.g. map says "Solstice" 
    -- but we have "Western Solstice" and "Eastern Solstice")
    if not motifs then
        local lowerZone = string.lower(zoneName)
        for dataZone, dataMotifs in pairs(TradeSkills.ZONE_MOTIF_DATA) do
            local lowerData = string.lower(dataZone)
            -- Check if zone name contains our data key or vice versa
            if string.find(lowerZone, lowerData, 1, true) or 
               string.find(lowerData, lowerZone, 1, true) then
                motifs = dataMotifs
                break
            end
        end
    end
    
    -- If still no match, try the player's actual zone name as fallback
    if not motifs then
        local playerZone = GetUnitZone("player")
        if playerZone then
            playerZone = zo_strformat("<<1>>", playerZone)
            motifs = TradeSkills.ZONE_MOTIF_DATA[playerZone]
            -- Try substring match on player zone too
            if not motifs then
                local lowerPZ = string.lower(playerZone)
                for dataZone, dataMotifs in pairs(TradeSkills.ZONE_MOTIF_DATA) do
                    local lowerData = string.lower(dataZone)
                    if string.find(lowerPZ, lowerData, 1, true) or 
                       string.find(lowerData, lowerPZ, 1, true) then
                        motifs = dataMotifs
                        break
                    end
                end
            end
        end
    end
    
    if motifs and #motifs > 0 then
        self._motifMapZone:SetText(zoneName)
        self._motifMapList:SetText("|cC8A0E0" .. table.concat(motifs, ", ") .. "|r")
        
        -- Resize window height to fit content
        local textHeight = self._motifMapList:GetTextHeight()
        local totalHeight = 8 + self._motifMapHeader:GetTextHeight() + 4 + self._motifMapZone:GetTextHeight() + 4 + textHeight + 10
        self._motifMapWindow:SetHeight(math.max(80, totalHeight))
        
        self._motifMapWindow:SetHidden(false)
    else
        self._motifMapWindow:SetHidden(true)
    end
end

function TradeSkills.StyleMastery:HideMotifMapWindow()
    if self._motifMapWindow then
        self._motifMapWindow:SetHidden(true)
    end
end

-- Show style progress from a motif/collectible name
-- Tries to extract the style name and find the matching style index
function TradeSkills.StyleMastery:ShowStyleProgressFromName(name)
    if not name or name == "" then return end
    
    local lowerName = string.lower(name)
    local bestMatch = nil
    local bestMatchLen = 0
    
    -- Search our style name lookup table
    for styleIndex, styleName in pairs(TradeSkills.STYLE_NAMES) do
        local lowerStyle = string.lower(styleName)
        if string.find(lowerName, lowerStyle, 1, true) then
            if #styleName > bestMatchLen then
                bestMatch = styleIndex
                bestMatchLen = #styleName
            end
        end
    end
    
    if bestMatch then
        local styleName = TradeSkills.STYLE_NAMES[bestMatch]
        local known, total = self:GetStyleProgress(bestMatch)
        self:ShowCompletionistPopup(styleName, known, total)
    else
        -- Fallback: just show the name without progress data
    end
end

-- Slash command for testing Visual Completionist: /tradeskills teststyle <styleIndex>
function TradeSkills.StyleMastery:TestCompletionistPopup(styleIndex)
    styleIndex = tonumber(styleIndex) or 1
    local styleName = self:GetStyleName(styleIndex)
    local known, total = self:GetStyleProgress(styleIndex)
    self:ShowCompletionistPopup(styleName, known, total)
end

-- =======================
-- TRAIT MASTERY MODULE
-- =======================
TradeSkills.TraitMastery = {
    name = "Trait Mastery",
    color = {0.2, 0.8, 0.5, 1},
    icon = "TradeSkills/icons/traits.dds",
    TRAITS_PER_LEVEL = 6,
    MAX_LEVEL = 54,
    TOTAL_TRAITS = 324,
    RANKS = {
        {level = 0, name = "Trait Novice", color = {0.6, 0.6, 0.6, 1}},
        {level = 10, name = "Trait Scholar", color = {0.3, 0.8, 0.6, 1}},
        {level = 25, name = "Trait Expert", color = {0.2, 0.9, 0.5, 1}},
        {level = 35, name = "Trait Master", color = {0.1, 1, 0.4, 1}},
        {level = 54, name = "Trait Grandmaster", color = {0, 1, 0.3, 1}}
    },
    passiveAbilities = {
        {
            name = "Material Salvage Forecast",
            icon = "TradeSkills/icons/z_salvage_forecast.dds",
            level = 10,
            description = "Adds a section to item tooltips estimating the materials you will receive when deconstructing that item.",
        },
    },
    IsPassiveActive = function(self, requiredLevel)
        if self._debugPerks then return true end
        return not TradeSkills.IsPerkDisabled("Trait Mastery", requiredLevel)
    end,
    IsAnyPassiveActive = function(self, requiredLevel)
        return not TradeSkills.IsPerkDisabled("Trait Mastery", requiredLevel)
    end,
}

function TradeSkills.TraitMastery:GetCount()
    return TradeSkills.savedVars.traitmastery.knownTraits
end

function TradeSkills.TraitMastery:GetLevel()
    local level = math.floor(self:GetCount() / self.TRAITS_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function TradeSkills.TraitMastery:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.TRAITS_PER_LEVEL, self.TRAITS_PER_LEVEL
    end
    return count % self.TRAITS_PER_LEVEL, self.TRAITS_PER_LEVEL
end

function TradeSkills.TraitMastery:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function TradeSkills.TraitMastery:GetDescription()
    return string.format("Research crafting traits to increase skill.\nEvery 6 traits increases your level by 1. Max level 54.\n\nTraits Researched: %d/%d", 
        self:GetCount(), self.TOTAL_TRAITS)
end

-- ===================================================
-- MATERIAL SALVAGE FORECAST (Trait Mastery Passive)
-- ===================================================
-- Material tier data: maps item level ranges to material names
-- NOTE: ESO API constants aren't available at file load time, so we use raw numbers:
-- CRAFTING_TYPE: BLACKSMITHING=1, CLOTHIER=2, WOODWORKING=6, JEWELRYCRAFTING=7
-- ITEM_FUNCTIONAL_QUALITY: NORMAL=1, FINE=2, SUPERIOR=3, EPIC=4, LEGENDARY=5
TradeSkills.DECON_MATERIALS = {
    [1] = { -- BLACKSMITHING
        tiers = {
            {maxLevel = 14, cpLevel = 0, material = "Iron Ingot", refined = "Iron Ore"},
            {maxLevel = 24, cpLevel = 0, material = "Steel Ingot", refined = "High Iron Ore"},
            {maxLevel = 34, cpLevel = 0, material = "Orichalcum Ingot", refined = "Orichalc Ore"},
            {maxLevel = 44, cpLevel = 0, material = "Dwarven Ingot", refined = "Dwemer Ore"},
            {maxLevel = 50, cpLevel = 0, material = "Ebony Ingot", refined = "Ebony Ore"},
            {maxLevel = 50, cpLevel = 10, material = "Calcinium Ingot", refined = "Calcinium Ore"},
            {maxLevel = 50, cpLevel = 30, material = "Galatite Ingot", refined = "Galatite Ore"},
            {maxLevel = 50, cpLevel = 50, material = "Quicksilver Ingot", refined = "Quicksilver Ore"},
            {maxLevel = 50, cpLevel = 70, material = "Voidstone Ingot", refined = "Voidstone Ore"},
            {maxLevel = 50, cpLevel = 150, material = "Rubedite Ingot", refined = "Rubedite Ore"},
        },
        traitMat = true,
        styleMat = true,
    },
    [2] = { -- CLOTHIER
        tiers = {
            {maxLevel = 14, cpLevel = 0, material = "Jute", refined = "Raw Jute"},
            {maxLevel = 24, cpLevel = 0, material = "Flax", refined = "Raw Flax"},
            {maxLevel = 34, cpLevel = 0, material = "Cotton", refined = "Raw Cotton"},
            {maxLevel = 44, cpLevel = 0, material = "Spidersilk", refined = "Raw Spidersilk"},
            {maxLevel = 50, cpLevel = 0, material = "Ebonthread", refined = "Raw Ebonthread"},
            {maxLevel = 50, cpLevel = 10, material = "Kresh Fiber", refined = "Raw Kresh Fiber"},
            {maxLevel = 50, cpLevel = 30, material = "Ironthread", refined = "Raw Ironthread"},
            {maxLevel = 50, cpLevel = 50, material = "Silverweave", refined = "Raw Silverweave"},
            {maxLevel = 50, cpLevel = 70, material = "Void Cloth", refined = "Raw Void Cloth"},
            {maxLevel = 50, cpLevel = 150, material = "Ancestor Silk", refined = "Raw Ancestor Silk"},
        },
        traitMat = true,
        styleMat = true,
    },
    [6] = { -- WOODWORKING
        tiers = {
            {maxLevel = 14, cpLevel = 0, material = "Sanded Maple", refined = "Rough Maple"},
            {maxLevel = 24, cpLevel = 0, material = "Sanded Oak", refined = "Rough Oak"},
            {maxLevel = 34, cpLevel = 0, material = "Sanded Beech", refined = "Rough Beech"},
            {maxLevel = 44, cpLevel = 0, material = "Sanded Hickory", refined = "Rough Hickory"},
            {maxLevel = 50, cpLevel = 0, material = "Sanded Yew", refined = "Rough Yew"},
            {maxLevel = 50, cpLevel = 10, material = "Sanded Birch", refined = "Rough Birch"},
            {maxLevel = 50, cpLevel = 30, material = "Sanded Ash", refined = "Rough Ash"},
            {maxLevel = 50, cpLevel = 50, material = "Sanded Mahogany", refined = "Rough Mahogany"},
            {maxLevel = 50, cpLevel = 70, material = "Sanded Nightwood", refined = "Rough Nightwood"},
            {maxLevel = 50, cpLevel = 150, material = "Sanded Ruby Ash", refined = "Rough Ruby Ash"},
        },
        traitMat = true,
        styleMat = true,
    },
    [7] = { -- JEWELRYCRAFTING
        tiers = {
            {maxLevel = 24, cpLevel = 0, material = "Pewter Ounce", refined = "Pewter Dust"},
            {maxLevel = 50, cpLevel = 0, material = "Copper Ounce", refined = "Copper Dust"},
            {maxLevel = 50, cpLevel = 50, material = "Silver Ounce", refined = "Silver Dust"},
            {maxLevel = 50, cpLevel = 150, material = "Electrum Ounce", refined = "Electrum Dust"},
            {maxLevel = 50, cpLevel = 160, material = "Platinum Ounce", refined = "Platinum Dust"},
        },
        traitMat = false,
        styleMat = false,
    },
}

-- Quality upgrade material names (keys: quality 2=Fine, 3=Superior, 4=Epic, 5=Legendary)
TradeSkills.UPGRADE_MATERIALS = {
    [1] = { -- BLACKSMITHING
        [2] = "Honing Stone",
        [3] = "Dwarven Oil",
        [4] = "Grain Solvent",
        [5] = "Tempering Alloy",
    },
    [2] = { -- CLOTHIER
        [2] = "Hemming",
        [3] = "Embroidery",
        [4] = "Elegant Lining",
        [5] = "Dreugh Wax",
    },
    [6] = { -- WOODWORKING
        [2] = "Pitch",
        [3] = "Turpen",
        [4] = "Mastic",
        [5] = "Rosin",
    },
    [7] = { -- JEWELRYCRAFTING
        [2] = "Terne Plating",
        [3] = "Iridium Plating",
        [4] = "Zircon Plating",
        [5] = "Chromium Plating",
    },
}

-- Determine the crafting type from an item link
-- Returns numeric crafting type: 1=BS, 2=CL, 6=WW, 7=JC
function TradeSkills.TraitMastery:GetCraftingTypeFromItemLink(itemLink)
    if not itemLink or itemLink == "" then return nil end
    local itemType = GetItemLinkItemType(itemLink)
    -- Armor
    if itemType == ITEMTYPE_ARMOR then
        local equipType = GetItemLinkEquipType(itemLink)
        local armorType = GetItemLinkArmorType(itemLink)
        if armorType == ARMORTYPE_HEAVY then
            return 1 -- BLACKSMITHING
        elseif armorType == ARMORTYPE_MEDIUM or armorType == ARMORTYPE_LIGHT then
            return 2 -- CLOTHIER
        end
        -- Shields are woodworking
        if equipType == EQUIP_TYPE_OFF_HAND then
            return 6 -- WOODWORKING
        end
        -- Jewelry
        if equipType == EQUIP_TYPE_NECK or equipType == EQUIP_TYPE_RING then
            return 7 -- JEWELRYCRAFTING
        end
    -- Weapons
    elseif itemType == ITEMTYPE_WEAPON then
        local weaponType = GetItemLinkWeaponType(itemLink)
        if weaponType == WEAPONTYPE_BOW 
            or weaponType == WEAPONTYPE_FIRE_STAFF
            or weaponType == WEAPONTYPE_FROST_STAFF
            or weaponType == WEAPONTYPE_LIGHTNING_STAFF
            or weaponType == WEAPONTYPE_HEALING_STAFF
            or weaponType == WEAPONTYPE_SHIELD then
            return 6 -- WOODWORKING
        else
            return 1 -- BLACKSMITHING
        end
    end
    return nil
end

-- Get material tier name based on item level/cp
function TradeSkills.TraitMastery:GetMaterialTier(craftingType, itemLevel, cpLevel)
    local data = TradeSkills.DECON_MATERIALS[craftingType]
    if not data then return nil end
    
    for _, tier in ipairs(data.tiers) do
        if itemLevel < 50 then
            if itemLevel <= tier.maxLevel and tier.cpLevel == 0 then
                return tier.material
            end
        else
            if cpLevel <= tier.cpLevel then
                return tier.material
            end
        end
    end
    -- Return highest tier as fallback
    return data.tiers[#data.tiers].material
end

-- Estimate deconstruction results for an item link
function TradeSkills.TraitMastery:EstimateDeconstruction(itemLink)
    if not itemLink or itemLink == "" then return nil end
    
    local craftingType = self:GetCraftingTypeFromItemLink(itemLink)
    if not craftingType then return nil end
    
    local quality = GetItemLinkQuality(itemLink)
    local itemLevel = GetItemLinkRequiredLevel(itemLink) or 1
    local cpLevel = GetItemLinkRequiredChampionPoints(itemLink) or 0
    
    local results = {}
    
    -- 1. Base material
    local baseMat = self:GetMaterialTier(craftingType, itemLevel, cpLevel)
    if baseMat then
        -- Base material quantity varies by quality
        -- Quality values: 1=Normal, 2=Fine, 3=Superior, 4=Epic, 5=Legendary
        local baseMin, baseMax
        if quality <= 1 then
            baseMin, baseMax = 1, 5
        elseif quality == 2 then
            baseMin, baseMax = 2, 7
        elseif quality == 3 then
            baseMin, baseMax = 3, 8
        elseif quality == 4 then
            baseMin, baseMax = 4, 10
        else
            baseMin, baseMax = 5, 12
        end
        table.insert(results, {name = baseMat, min = baseMin, max = baseMax, color = "FFFFFF"})
    end
    
    -- 2. Upgrade materials (chance based on quality)
    local upgradeData = TradeSkills.UPGRADE_MATERIALS[craftingType]
    if upgradeData then
        if quality >= 2 and upgradeData[2] then
            table.insert(results, {name = upgradeData[2], min = 0, max = 1, color = "2DC50E", chance = "frequent"})
        end
        if quality >= 3 and upgradeData[3] then
            table.insert(results, {name = upgradeData[3], min = 0, max = 1, color = "3A92FF", chance = "uncommon"})
        end
        if quality >= 4 and upgradeData[4] then
            table.insert(results, {name = upgradeData[4], min = 0, max = 1, color = "A02EF7", chance = "rare"})
        end
        if quality >= 5 and upgradeData[5] then
            table.insert(results, {name = upgradeData[5], min = 0, max = 1, color = "CCAA00", chance = "very rare"})
        end
    end
    
    -- 3. Trait material (if item has a trait, for BS/CL/WW only)
    local craftData = TradeSkills.DECON_MATERIALS[craftingType]
    if craftData and craftData.traitMat then
        local traitType = GetItemLinkTraitInfo(itemLink)
        if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
            -- Hardcoded trait type -> material name mapping
            -- Armor traits
            local TRAIT_MATERIALS = {
                [ITEM_TRAIT_TYPE_ARMOR_STURDY] = "Quartz",
                [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = "Diamond",
                [ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = "Sardonyx",
                [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = "Almandine",
                [ITEM_TRAIT_TYPE_ARMOR_TRAINING] = "Emerald",
                [ITEM_TRAIT_TYPE_ARMOR_INFUSED] = "Bloodstone",
                [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = "Garnet",
                [ITEM_TRAIT_TYPE_ARMOR_DIVINES] = "Sapphire",
                [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = "Fortified Nirncrux",
                -- Weapon traits
                [ITEM_TRAIT_TYPE_WEAPON_POWERED] = "Chysolite",
                [ITEM_TRAIT_TYPE_WEAPON_CHARGED] = "Amethyst",
                [ITEM_TRAIT_TYPE_WEAPON_PRECISE] = "Ruby",
                [ITEM_TRAIT_TYPE_WEAPON_INFUSED] = "Jade",
                [ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = "Turquoise",
                [ITEM_TRAIT_TYPE_WEAPON_TRAINING] = "Carnelian",
                [ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = "Fire Opal",
                [ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = "Citrine",
                [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = "Potent Nirncrux",
            }
            local traitMatName = TRAIT_MATERIALS[traitType]
            if traitMatName then
                table.insert(results, {name = traitMatName, min = 0, max = 1, color = "33CC80", chance = "uncommon"})
            end
        end
    end
    
    -- 4. Style material (for BS/CL/WW only)
    if craftData and craftData.styleMat then
        table.insert(results, {name = "Style Material", min = 0, max = 1, color = "AAAAAA", chance = "common"})
    end
    
    return results
end

-- Hook into item tooltips to add salvage forecast
function TradeSkills.TraitMastery:InitSalvageForecastTooltip()
    if self._tooltipHooked then return end
    self._tooltipHooked = true
    
    -- Hook ItemTooltip (keyboard mode)
    local origSetBagItem = ItemTooltip.SetBagItem
    ItemTooltip.SetBagItem = function(control, bagId, slotIndex, ...)
        origSetBagItem(control, bagId, slotIndex, ...)
        TradeSkills.TraitMastery:AddSalvageForecastToTooltip(control, GetItemLink(bagId, slotIndex))
    end
    
    -- Hook SetLootItem
    local origSetLootItem = ItemTooltip.SetLootItem
    if origSetLootItem then
        ItemTooltip.SetLootItem = function(control, lootId, ...)
            origSetLootItem(control, lootId, ...)
            local itemLink = GetLootItemLink(lootId)
            TradeSkills.TraitMastery:AddSalvageForecastToTooltip(control, itemLink)
        end
    end

    -- Hook SetTradeItem
    local origSetTradeItem = ItemTooltip.SetTradeItem
    if origSetTradeItem then
        ItemTooltip.SetTradeItem = function(control, who, tradeIndex, ...)
            origSetTradeItem(control, who, tradeIndex, ...)
            local itemLink = GetTradeItemLink(who, tradeIndex)
            TradeSkills.TraitMastery:AddSalvageForecastToTooltip(control, itemLink)
        end
    end

    -- Hook SetLink (covers chat links, guild store, etc.)
    local origSetLink = ItemTooltip.SetLink
    if origSetLink then
        ItemTooltip.SetLink = function(control, itemLink, ...)
            origSetLink(control, itemLink, ...)
            TradeSkills.TraitMastery:AddSalvageForecastToTooltip(control, itemLink)
        end
    end
    
    -- Hook PopupTooltip SetLink too
    if PopupTooltip then
        local origPopupSetLink = PopupTooltip.SetLink
        if origPopupSetLink then
            PopupTooltip.SetLink = function(control, itemLink, ...)
                origPopupSetLink(control, itemLink, ...)
                TradeSkills.TraitMastery:AddSalvageForecastToTooltip(control, itemLink)
            end
        end
    end
    
    -- Gamepad tooltip hooks
    -- In gamepad mode, tooltips use GAMEPAD_TOOLTIPS:LayoutItem/LayoutBagItem/LayoutItemLink
    if GAMEPAD_TOOLTIPS then
        SecurePostHook(GAMEPAD_TOOLTIPS, "LayoutBagItem", function(self, tooltipType, bagId, slotIndex, ...)
            local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(tooltipType)
            if tooltip then
                TradeSkills.TraitMastery:AddSalvageForecastToTooltip(tooltip, GetItemLink(bagId, slotIndex))
            end
        end)
        SecurePostHook(GAMEPAD_TOOLTIPS, "LayoutItemLink", function(self, tooltipType, itemLink, ...)
            local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(tooltipType)
            if tooltip then
                TradeSkills.TraitMastery:AddSalvageForecastToTooltip(tooltip, itemLink)
            end
        end)
    end
end

-- Add the salvage forecast section to a tooltip
function TradeSkills.TraitMastery:AddSalvageForecastToTooltip(tooltip, itemLink)
    if not tooltip or not itemLink or itemLink == "" then return end
    if not tooltip.AddLine then return end  -- Guard for incompatible tooltip objects
    
    -- Check if the passive is active
    if not self:IsPassiveActive(10) then return end
    
    -- Only show for deconstructable equipment
    local itemType = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_ARMOR and itemType ~= ITEMTYPE_WEAPON then return end
    
    -- Don't show for ornate/intricate tagged display, just regular items
    local results = self:EstimateDeconstruction(itemLink)
    if not results or #results == 0 then return end
    
    -- Add separator and header
    tooltip:AddLine(" ", "ZoFontGameSmall", 1, 1, 1, 1, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
    tooltip:AddLine("|c33CC80[Salvage Forecast]|r", "ZoFontGameSmall", 1, 1, 1, 1, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
    
    -- Add each estimated material
    for _, mat in ipairs(results) do
        local line
        if mat.chance then
            -- Has a chance qualifier
            if mat.min == 0 then
                line = string.format("|c%s%s|r |c888888(%s)|r", mat.color, mat.name, mat.chance)
            else
                line = string.format("|c%s%s|r x%d-%d |c888888(%s)|r", mat.color, mat.name, mat.min, mat.max, mat.chance)
            end
        else
            -- Guaranteed material with quantity range
            line = string.format("|c%s%s|r x%d-%d", mat.color, mat.name, mat.min, mat.max)
        end
        tooltip:AddLine(line, "ZoFontGameSmall", 1, 1, 1, 1, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
    end
end

-- =======================
-- FISHING MODULE
-- =======================
TradeSkills.Fishing = {
    name = "Fishing",
    color = {0.2, 0.6, 1, 1},
    icon = "TradeSkills/icons/fish.dds",
    FISH_PER_LEVEL = 20,
    MAX_LEVEL = 50,
    RANKS = {
        {level = 0, name = "Angler", color = {0.6, 0.6, 0.6, 1}},
        {level = 100, name = "Fisher", color = {0.4, 0.7, 1, 1}},
        {level = 200, name = "Master Fisher", color = {0.5, 0.8, 1, 1}},
        {level = 300, name = "Admiral of the Deep", color = {0.6, 0.9, 1, 1}},
        {level = 500, name = "Legendary Angler", color = {1, 1, 1, 1}}
    },
    passiveAbilities = {
        {
            name = "Bait Master",
            icon = "TradeSkills/icons/bait_master.dds",
            level = 10,
            description = "Auto-selects correct bait for the fishing hole water type.",
        },
        {
            name = "Keen Angler",
            icon = "TradeSkills/icons/keen_angler.dds",
            level = 30,
            description = "Shows zone fish checklist and fishing timer bar.",
        },
        {
            name = "Reel Alert",
            icon = "TradeSkills/icons/reel_alert.dds",
            level = 50,
            description = "Screen flash and sound alert when a fish bites.",
        },
    }
}

function TradeSkills.Fishing:GetCount()
    return TradeSkills.savedVars.fishing.totalFishCaught
end

function TradeSkills.Fishing:GetLevel()
    local level = math.floor(self:GetCount() / self.FISH_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function TradeSkills.Fishing:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.FISH_PER_LEVEL, self.FISH_PER_LEVEL
    end
    return count % self.FISH_PER_LEVEL, self.FISH_PER_LEVEL
end

function TradeSkills.Fishing:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function TradeSkills.Fishing:GetAchievementsCompleted()
    if not self._achievements then
        -- Start with achievements from the Fishing subcategory
        self._achievements = TradeSkills.FindAchievementsBySubCategory("Fishing")
        local seenIds = {}
        for _, id in ipairs(self._achievements) do
            seenIds[id] = true
        end
        
        -- Also scan ALL achievements for "angler" in the name (catches DLC anglers)
        -- Exclude "strangler" achievements
        for i = 1, 6000 do
            local name, _, _, _, _ = GetAchievementInfo(i)
            if name and name ~= "" and not seenIds[i] then
                local lowerName = string.lower(name)
                if (string.find(lowerName, "angler") or string.find(lowerName, "fish boon")) and not string.find(lowerName, "strangler") then
                    seenIds[i] = true
                    table.insert(self._achievements, i)
                end
            end
        end
    end
    local completed = 0
    for _, achievementId in ipairs(self._achievements) do
        local _, _, _, _, isCompleted = GetAchievementInfo(achievementId)
        if isCompleted then
            completed = completed + 1
        end
    end
    return completed, #self._achievements
end

function TradeSkills.Fishing:GetDescription()
    local fishCount = self:GetCount()
    local completed, total = self:GetAchievementsCompleted()
    local text = "Every 20 fish caught increases your level by 1. Max level 50.\n\n"
    text = text .. "Total Fish Caught: " .. fishCount .. "\n"
    text = text .. "Fishing Achievements Earned: " .. completed .. "/" .. total
    return text
end

-- =======================
-- FISHING PERK: AUTO-BAIT (Level 10)
-- =======================
-- Maps fishing hole names to water types, then selects the best bait
TradeSkills.Fishing.WATER_TYPE_MAP = {
    ["foul"]      = "foul",
    ["oily"]      = "foul",      -- Clockwork City, works like foul
    ["river"]     = "river",
    ["lake"]      = "lake",
    ["saltwater"] = "saltwater",
    ["ocean"]     = "saltwater",
    ["mystic"]    = "saltwater",  -- Artaeum, works like saltwater
}

-- Bait names for each water type, in priority order (special bait first, then common)
TradeSkills.Fishing.BAIT_PRIORITY = {
    foul      = {"Fish Roe", "Crawlers"},
    river     = {"Shad", "Insect Parts"},
    lake      = {"Minnow", "Guts"},
    saltwater = {"Chub", "Worms"},
}

function TradeSkills.Fishing:DetectWaterType(holeName)
    if not holeName then return nil end
    local lower = string.lower(holeName)
    for keyword, waterType in pairs(self.WATER_TYPE_MAP) do
        if string.find(lower, keyword) then
            return waterType
        end
    end
    return nil
end

function TradeSkills.Fishing:AutoSelectBait(waterType)
    if not waterType then return end
    local priorityBaits = self.BAIT_PRIORITY[waterType]
    if not priorityBaits then return end
    
    local numLures = GetNumFishingLures()
    
    -- Check if current lure is already correct for this water type
    local currentLure = GetFishingLure()
    if currentLure and currentLure > 0 then
        local currentName = GetFishingLureInfo(currentLure)
        if currentName and currentName ~= "" then
            local currentLower = string.lower(currentName)
            for _, desiredBait in ipairs(priorityBaits) do
                if string.find(currentLower, string.lower(desiredBait), 1, true) then
                    -- Already using correct bait
                    return true
                end
            end
        end
    end
    
    for _, desiredBait in ipairs(priorityBaits) do
        local desiredLower = string.lower(desiredBait)
        for i = 1, numLures do
            local name, _, stack = GetFishingLureInfo(i)
            if name and name ~= "" and stack and stack > 0 then
                local rawLower = string.lower(name)
                if string.find(rawLower, desiredLower, 1, true) then
                    SetFishingLure(i)
                    return true
                end
            end
        end
    end
    return false
end

-- Helper: check if a perk is available (respects debug mode)
function TradeSkills.Fishing:HasPerk(requiredLevel)
    if self._debugPerks then
        return not TradeSkills.IsPerkDisabled("Fishing", requiredLevel)
    end
    if self:GetLevel() < requiredLevel then return false end
    return not TradeSkills.IsPerkDisabled("Fishing", requiredLevel)
end

-- Called when the interaction HUD shows or hides (hooked via ZO_PreHookHandler on RETICLE.interact)
function TradeSkills.Fishing:OnInteractionChanged()
    local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
    
    if not action then return false end
    
    if additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
        -- We're looking at a fishing hole - save the name for later detection
        self._fishingHoleName = interactableName
        self._atFishingHole = true
        self._fishBitePending = false  -- Reset bite state for new hole
        
        -- Auto-bait perk (level 10+)
        if self:HasPerk(10) and interactableName then
            local waterType = self:DetectWaterType(interactableName)
            if waterType then
                self:AutoSelectBait(waterType)
            end
        end
        
        -- Zone fish checklist perk (level 30+)
        if self:HasPerk(30) then
            self:ShowChecklist()
        end
    else
        -- Check if the action is "Reel In" - this means line is in the water
        local reelInText = GetString(SI_GAMECAMERAACTIONTYPE17)
        if action == reelInText and self._fishingHoleName then
            -- Only start the bar if we haven't already detected a bite
            if self:HasPerk(30) and not self._fishBarActive and not self._fishBitePending then
                self:StartFishingWatch()
            end
        elseif self._fishingHoleName and interactableName == self._fishingHoleName then
            -- Still at the fishing hole but not reeling yet
        else
            -- Looking at something else entirely
            if self._atFishingHole then
                self._atFishingHole = false
                self._fishingHoleName = nil
                self._fishBitePending = false
                self:HideChecklist()
            end
            self:StopFishingWatch()
        end
    end
    return false
end

-- =======================
-- FISHING PERK: ZONE FISH CHECKLIST (Level 30)
-- =======================
-- Creates a small UI panel showing zone fishing achievement progress

function TradeSkills.Fishing:CreateChecklistWindow()
    if self._checklistWindow then return end
    
    local window = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_FishChecklist")
    window:SetDimensions(280, 400)
    window:SetHidden(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetDrawLevel(3)
    
    -- Restore saved position or use default
    local savedPos = TradeSkills.savedVars and TradeSkills.savedVars.fishing.checklistPosition
    if savedPos then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedPos.x, savedPos.y)
    else
        window:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -20, 200)
    end
    
    -- Save position on move
    window:SetHandler("OnMoveStop", function()
        local left, top = window:GetLeft(), window:GetTop()
        if TradeSkills.savedVars then
            TradeSkills.savedVars.fishing.checklistPosition = {x = left, y = top}
        end
    end)
    
    -- Background
    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.05, 0.05, 0.1, 0.9)
    bg:SetEdgeColor(0.2, 0.5, 1, 0.8)
    bg:SetEdgeTexture("", 1, 1, 1, 0)
    
    -- Title
    local title = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    title:SetAnchor(TOP, window, TOP, 0, 8)
    title:SetFont("ZoFontWinH4")
    title:SetColor(0.2, 0.6, 1, 1)
    title:SetText("Zone Fish Checklist")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self._checklistTitle = title
    
    -- Scrollable content area
    local content = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    content:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 35)
    content:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -12, -8)
    content:SetFont("ZoFontGame")
    content:SetColor(0.8, 0.8, 0.8, 1)
    content:SetText("")
    content:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self._checklistContent = content
    
    self._checklistWindow = window
end

function TradeSkills.Fishing:GetZoneFishingAchievement()
    -- Find the fishing achievement for the current zone
    -- Try multiple methods to get the zone name
    local zoneName = GetUnitZone("player")
    if zoneName then
        zoneName = zo_strformat("<<1>>", zoneName)
    end
    
    if not zoneName or zoneName == "" then
        local mapZoneIndex = GetCurrentMapZoneIndex()
        if mapZoneIndex then
            zoneName = zo_strformat("<<1>>", GetZoneNameByIndex(mapZoneIndex))
        end
    end
    
    if not zoneName or zoneName == "" then
        return nil
    end
    
    local lowerZone = string.lower(zoneName)
    
    -- Search all achievements for one matching the zone name + "angler" pattern
    for i = 1, 6000 do
        local name, desc, _, _, completed, _, _ = GetAchievementInfo(i)
        if name and name ~= "" then
            local lowerName = string.lower(name)
            if (string.find(lowerName, "angler", 1, true) or string.find(lowerName, "fish boon", 1, true)) 
               and not string.find(lowerName, "strangler", 1, true) then
                local lowerDesc = string.lower(desc or "")
                -- Check zone name in achievement name or description
                if string.find(lowerName, lowerZone, 1, true) or string.find(lowerDesc, lowerZone, 1, true) then
                    return i, name, completed
                end
            end
        end
    end
    return nil
end

function TradeSkills.Fishing:UpdateChecklist()
    if not self._checklistWindow then
        self:CreateChecklistWindow()
    end
    
    local achievementId, achievementName, achievementCompleted = self:GetZoneFishingAchievement()
    if not achievementId then
        self._checklistContent:SetText("|c888888No fishing achievement found for this zone.|r")
        self._checklistTitle:SetText("Zone Fish Checklist")
        return
    end
    
    self._checklistTitle:SetText(zo_strformat("<<1>>", achievementName))
    
    local text = ""
    local numCriteria = GetAchievementNumCriteria(achievementId)
    for i = 1, numCriteria do
        local criteriaDesc, numCompleted, numRequired = GetAchievementCriterion(achievementId, i)
        if criteriaDesc and criteriaDesc ~= "" then
            local fishName = zo_strformat("<<1>>", criteriaDesc)
            if numCompleted >= numRequired then
                text = text .. "|c00FF00✓|r " .. fishName .. "\n"
            else
                text = text .. "|cFF4444✗|r " .. fishName .. "\n"
            end
        end
    end
    
    if text == "" then
        text = "|c888888No fish criteria found.|r"
    end
    
    self._checklistContent:SetText(text)
end

function TradeSkills.Fishing:ShowChecklist(forceShow)
    if not forceShow and not self:HasPerk(30) then return end
    
    if not self._checklistWindow then
        self:CreateChecklistWindow()
    end
    self:UpdateChecklist()
    self._checklistWindow:SetHidden(false)
end

function TradeSkills.Fishing:HideChecklist()
    if self._checklistWindow then
        self._checklistWindow:SetHidden(true)
    end
end

-- Called when fishing interaction starts
function TradeSkills.Fishing:OnFishingStarted()
    self:ShowChecklist()
end

-- Called when fishing interaction ends
function TradeSkills.Fishing:OnFishingEnded()
    self:HideChecklist()
end

-- =======================
-- FISHING PERK: REEL ALERT (Level 50)
-- =======================
-- Detects fish bite by watching bait count drop by 1
-- Plays sound + screen flash when fish bites

function TradeSkills.Fishing:CreateReelAlertOverlay()
    if self._reelAlertOverlay then return end
    
    local overlay = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_ReelAlert")
    overlay:SetDimensions(GuiRoot:GetWidth(), GuiRoot:GetHeight())
    overlay:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    overlay:SetDrawLayer(DL_OVERLAY)
    overlay:SetDrawLevel(10)
    overlay:SetHidden(true)
    overlay:SetMouseEnabled(false)
    
    local bg = WINDOW_MANAGER:CreateControl(nil, overlay, CT_BACKDROP)
    bg:SetAnchorFill(overlay)
    bg:SetCenterColor(1, 0.2, 0.1, 0.35)
    bg:SetEdgeColor(1, 0.1, 0, 0.6)
    bg:SetEdgeTexture("", 16, 16, 16, 0)
    
    self._reelAlertOverlay = overlay
    
    -- Create fade animation
    local am = GetAnimationManager()
    local timeline = am:CreateTimeline()
    local fadeAnim = timeline:InsertAnimation(ANIMATION_ALPHA, overlay, 0)
    fadeAnim:SetAlphaValues(1, 0)
    fadeAnim:SetDuration(800)
    fadeAnim:SetEasingFunction(ZO_EaseOutQuadratic)
    timeline:SetHandler("OnStop", function()
        overlay:SetHidden(true)
        overlay:SetAlpha(1)
    end)
    self._reelAlertTimeline = timeline
end

function TradeSkills.Fishing:FlashReelAlert()
    if not self._reelAlertOverlay then
        self:CreateReelAlertOverlay()
    end
    
    -- Show flash
    self._reelAlertOverlay:SetHidden(false)
    self._reelAlertOverlay:SetAlpha(1)
    self._reelAlertTimeline:PlayFromStart()
    
    -- Play sound
    PlaySound(SOUNDS.DUEL_ACCEPTED)
end

-- =======================
-- FISHING PERK: FISH BAR (Part of Keen Angler, Level 30)
-- =======================
-- Countdown timer bar that shows while waiting for a fish to bite
local FISH_BAR_DEFAULT_INTERVAL = 30  -- ~30 seconds default fishing wait time

function TradeSkills.Fishing:CreateFishBar()
    if self._fishBar then return end
    
    local window = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_FishBar")
    window:SetDimensions(400, 25)
    window:SetHidden(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetDrawTier(DT_HIGH)
    
    -- Restore saved position or use default (bottom center)
    local savedPos = TradeSkills.savedVars and TradeSkills.savedVars.fishing.fishBarPosition
    if savedPos then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedPos.x, savedPos.y)
    else
        window:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, -20)
    end
    
    -- Save position on move
    window:SetHandler("OnMoveStop", function()
        local left, top = window:GetLeft(), window:GetTop()
        if TradeSkills.savedVars then
            TradeSkills.savedVars.fishing.fishBarPosition = {x = left, y = top}
        end
    end)
    
    -- Dark background
    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.08, 0.9)
    bg:SetEdgeColor(0.3, 0.3, 0.3, 0.8)
    
    -- Fill bar using CT_BACKDROP with dynamic width
    local fill = WINDOW_MANAGER:CreateControl("TradeSkills_FBFill", window, CT_BACKDROP)
    fill:SetAnchor(TOPLEFT, window, TOPLEFT, 2, 2)
    fill:SetDimensions(396, 21)
    fill:SetCenterColor(0.2, 0.6, 1, 0.9)
    fill:SetEdgeColor(0.2, 0.6, 1, 0)
    self._fishBarFill = fill
    
    -- "Fishing..." label
    local label = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    label:SetAnchor(CENTER, window, CENTER, 0, 0)
    label:SetFont("ZoFontWinH4")
    label:SetColor(1, 1, 1, 1)
    label:SetText("Fishing...")
    self._fishBarLabel = label
    
    self._fishBar = window
end

function TradeSkills.Fishing:ShowFishBar()
    if not self:HasPerk(30) then return end
    if not self._fishBar then
        self:CreateFishBar()
    end
    
    -- Calculate fishing interval with bonus
    local bonus = 1 - (GetNonCombatBonus(NON_COMBAT_BONUS_FISHING_TIME_REDUCTION_PERCENT) / 100)
    local interval = FISH_BAR_DEFAULT_INTERVAL * bonus
    
    -- Start countdown
    self._fishBarStartTime = GetGameTimeMilliseconds()
    self._fishBarDuration = interval * 1000  -- ms
    self._fishBarFill:SetDimensions(396, 21)
    self._fishBar:SetHidden(false)
    self._fishBarActive = true
    
    -- Unregister first to avoid duplicates
    EVENT_MANAGER:UnregisterForUpdate("TradeSkills_FishBarTick")
    
    -- Use EVENT_MANAGER timer to update fill width
    EVENT_MANAGER:RegisterForUpdate("TradeSkills_FishBarTick", 100, function()
        if not TradeSkills.Fishing._fishBarActive then
            EVENT_MANAGER:UnregisterForUpdate("TradeSkills_FishBarTick")
            return
        end
        local now = GetGameTimeMilliseconds()
        local elapsed = now - TradeSkills.Fishing._fishBarStartTime
        local remaining = TradeSkills.Fishing._fishBarDuration - elapsed
        if remaining < 0 then remaining = 0 end
        local pct = remaining / TradeSkills.Fishing._fishBarDuration
        TradeSkills.Fishing._fishBarFill:SetDimensions(math.max(1, pct * 396), 21)
        if remaining <= 0 then
            TradeSkills.Fishing:HideFishBar()
        end
    end)
end

function TradeSkills.Fishing:HideFishBar()
    self._fishBarActive = false
    self._fishBarStartTime = nil
    EVENT_MANAGER:UnregisterForUpdate("TradeSkills_FishBarTick")
    if self._fishBar then
        self._fishBar:SetHidden(true)
    end
end

function TradeSkills.Fishing:CountCurrentBait()
    local lureIndex = GetFishingLure()
    if lureIndex and lureIndex > 0 then
        local _, _, stack = GetFishingLureInfo(lureIndex)
        return stack or 0
    end
    return 0
end

function TradeSkills.Fishing:StartFishingWatch()
    -- Stop any existing watch first (like Votan's StopReelIn before starting)
    self:StopReelIn()
    
    local lureIndex = GetFishingLure()
    if not lureIndex then return end
    
    self._isFishing = true
    self._baitCountAtCast = self:CountCurrentBait()
    
    -- Show the fish bar countdown (Keen Angler perk)
    self:ShowFishBar()
    
    -- Register for inventory updates to detect bait consumption (fish bite)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_REEL", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
        function(event, bagId, slotIndex, isNew)
            if bagId ~= BAG_BACKPACK and bagId ~= BAG_VIRTUAL then return end
            
            local count = TradeSkills.Fishing:CountCurrentBait()
            
            if not isNew and TradeSkills.Fishing._baitCountAtCast 
               and (TradeSkills.Fishing._baitCountAtCast - count) == 1 then
                -- Bait dropped by exactly 1 = fish on the hook!
                TradeSkills.Fishing._fishBitePending = true
                TradeSkills.Fishing:HideFishBar()
                TradeSkills.Fishing:FlashReelAlert()
            end
            TradeSkills.Fishing._baitCountAtCast = count
        end)
    
    -- Register for loot events to stop watching
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_REEL", EVENT_LOOT_RECEIVED, function()
        TradeSkills.Fishing:StopReelIn()
        TradeSkills.Fishing:HideFishBar()
    end)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_REEL", EVENT_LOOT_CLOSED, function()
        TradeSkills.Fishing:StopFishingWatch()
    end)
end

-- Stop the inventory slot watcher (called on loot received)
function TradeSkills.Fishing:StopReelIn()
    pcall(EVENT_MANAGER.UnregisterForEvent, EVENT_MANAGER, TradeSkills.name .. "_REEL", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
end

-- Fully stop fishing watch (called on loot closed or walking away)
function TradeSkills.Fishing:StopFishingWatch()
    self._isFishing = false
    self._fishBitePending = false
    self._baitCountAtCast = nil
    self:StopReelIn()
    self:HideFishBar()
    pcall(EVENT_MANAGER.UnregisterForEvent, EVENT_MANAGER, TradeSkills.name .. "_REEL", EVENT_LOOT_RECEIVED)
    pcall(EVENT_MANAGER.UnregisterForEvent, EVENT_MANAGER, TradeSkills.name .. "_REEL", EVENT_LOOT_CLOSED)
end

-- =======================
-- MINING MODULE
-- =======================
TradeSkills.Mining = {
    name = "Mining",
    color = {0.7, 0.5, 0.3, 1},
    icon = "TradeSkills/icons/mining.dds",
    NODES_PER_LEVEL = 20,
    MAX_LEVEL = 50,
    RANKS = {
        {level = 0, name = "Prospector", color = {0.6, 0.6, 0.6, 1}},
        {level = 100, name = "Miner", color = {0.8, 0.6, 0.4, 1}},
        {level = 200, name = "Master Miner", color = {0.9, 0.7, 0.5, 1}},
        {level = 300, name = "Excavator Supreme", color = {1, 0.8, 0.6, 1}},
        {level = 500, name = "Legendary Prospector", color = {1, 0.84, 0, 1}}
    },
    passiveAbilities = {
        {
            name = "Miner's Eye",
            icon = "TradeSkills/icons/ts_miners_eye.dds",
            level = 10,
            description = "When approaching an ore node, shows the crafting level range for that material.",
        },
        {
            name = "Ore Tracker",
            icon = "TradeSkills/icons/ts_ore_tracker.dds",
            level = 30,
            description = "While mining, displays a small tracker showing your total inventory of that ore type.",
        },
        {
            name = "Heat Map",
            icon = "TradeSkills/icons/heat_map.dds",
            level = 50,
            description = "Marks ore-rich mining areas on your map.",
        },
    },
    _debugPerks = false,
}

function TradeSkills.Mining:GetCount()
    return TradeSkills.savedVars.mining.totalNodesGathered
end

function TradeSkills.Mining:GetLevel()
    local level = math.floor(self:GetCount() / self.NODES_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function TradeSkills.Mining:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.NODES_PER_LEVEL, self.NODES_PER_LEVEL
    end
    return count % self.NODES_PER_LEVEL, self.NODES_PER_LEVEL
end

function TradeSkills.Mining:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function TradeSkills.Mining:GetAchievementsCompleted()
    if not self._blacksmithingAchievements then
        self._blacksmithingAchievements = TradeSkills.FindAchievementsBySubCategory("Blacksmithing")
    end
    if not self._jewelryAchievements then
        self._jewelryAchievements = TradeSkills.FindAchievementsBySubCategory("Jewelry Crafting")
    end
    
    local bsCompleted = 0
    for _, achievementId in ipairs(self._blacksmithingAchievements) do
        local _, _, _, _, isCompleted = GetAchievementInfo(achievementId)
        if isCompleted then
            bsCompleted = bsCompleted + 1
        end
    end
    
    local jwCompleted = 0
    for _, achievementId in ipairs(self._jewelryAchievements) do
        local _, _, _, _, isCompleted = GetAchievementInfo(achievementId)
        if isCompleted then
            jwCompleted = jwCompleted + 1
        end
    end
    
    return bsCompleted, #self._blacksmithingAchievements, jwCompleted, #self._jewelryAchievements
end

function TradeSkills.Mining:GetDescription()
    local nodeCount = self:GetCount()
    local bsDone, bsTotal, jwDone, jwTotal = self:GetAchievementsCompleted()
    local text = "Mine ore nodes to increase skill.\n"
    text = text .. "Every 25 nodes mined increases your level by 1. Max level 50.\n\n"
    text = text .. "Ore Nodes Mined: " .. nodeCount .. "\n"
    text = text .. "Blacksmithing Achievements: " .. bsDone .. "/" .. bsTotal .. "\n"
    text = text .. "Jewelry Achievements: " .. jwDone .. "/" .. jwTotal
    return text
end

function TradeSkills.Mining:HasPerk(requiredLevel)
    if self._debugPerks then
        return not TradeSkills.IsPerkDisabled("Mining", requiredLevel)
    end
    if self:GetLevel() < requiredLevel then return false end
    return not TradeSkills.IsPerkDisabled("Mining", requiredLevel)
end

-- =======================
-- MINING PERK: HEAT MAP (Level 30)
-- =======================
-- Places pins on the world map for ore-rich mining areas
-- Uses LibMapPins, keyed by map ID so pins only show on the correct map

function TradeSkills.Mining:GetHeatMapLocations()
    if not self:HasPerk(30) then return nil end
    if not TradeSkills.accountVars then return nil end
    
    local currentMapId = GetCurrentMapId()
    if not currentMapId then return nil end
    
    local pins = TradeSkills.accountVars.heatMapPins and TradeSkills.accountVars.heatMapPins[currentMapId]
    if pins and #pins > 0 then
        return pins
    end
    return nil
end

function TradeSkills.Mining:AddHeatMapPin(label)
    if not self:HasPerk(30) then
        return
    end
    if not TradeSkills.accountVars then return end
    
    local mapId = GetCurrentMapId()
    local x, y = GetMapPlayerPosition("player")
    
    if not label or label == "" then
        local zoneName = zo_strformat("<<1>>", GetUnitZone("player"))
        label = zoneName .. " - Ore Farming"
    end
    
    if not TradeSkills.accountVars.heatMapPins then
        TradeSkills.accountVars.heatMapPins = {}
    end
    if not TradeSkills.accountVars.heatMapPins[mapId] then
        TradeSkills.accountVars.heatMapPins[mapId] = {}
    end
    
    table.insert(TradeSkills.accountVars.heatMapPins[mapId], {x, y, label})
    
    self:RefreshHeatMapPins()
end

function TradeSkills.Mining:RemoveNearestHeatMapPin()
    if not self:HasPerk(30) then
        return
    end
    if not TradeSkills.accountVars then return end
    local mapId = GetCurrentMapId()
    local pins = TradeSkills.accountVars.heatMapPins and TradeSkills.accountVars.heatMapPins[mapId]
    if not pins or #pins == 0 then
        return
    end
    
    local px, py = GetMapPlayerPosition("player")
    local closestIdx = 1
    local closestDist = math.huge
    
    for i, pin in ipairs(pins) do
        local dx = pin[1] - px
        local dy = pin[2] - py
        local dist = dx * dx + dy * dy
        if dist < closestDist then
            closestDist = dist
            closestIdx = i
        end
    end
    
    local removed = table.remove(pins, closestIdx)
    
    self:RefreshHeatMapPins()
end

function TradeSkills.Mining:ClearAllHeatMapPins()
    if not TradeSkills.accountVars then return end
    TradeSkills.accountVars.heatMapPins = {}
    self:RefreshHeatMapPins()
end

function TradeSkills.Mining:InitHeatMapPins()
    local LMP = LibMapPins
    if not LMP then
        return
    end
    
    local pinTypeString = "TradeSkills_HeatMapPin"
    
    local pinLayoutData = {
        level = 200,
        texture = "TradeSkills/icons/heat_map_pin.dds",
        size = 32,
        minSize = 20,
    }
    
    local pinTooltipCreator = {
        creator = function(pin)
            local pinTag = pin.m_PinTag
            if pinTag and pinTag.label then
                InformationTooltip:AddLine(pinTag.label)
                InformationTooltip:AddLine("Mining: Ore-rich area", "", ZO_ColorDef:New(0.7, 0.5, 0.3, 1):UnpackRGBA())
            end
        end,
        tooltip = InformationTooltip,
    }
    
    local function pinTypeAddCallback(pinManager)
        if not TradeSkills.Mining:HasPerk(50) then return end
        local locations = TradeSkills.Mining:GetHeatMapLocations()
        if not locations then return end
        
        for _, loc in ipairs(locations) do
            local pinInfo = { label = loc[3] }
            LMP:CreatePin(pinTypeString, pinInfo, loc[1], loc[2])
        end
    end
    
    LMP:AddPinType(pinTypeString, pinTypeAddCallback, nil, pinLayoutData, pinTooltipCreator)
    LMP:AddPinFilter(pinTypeString, "Mining: Heat Map Locations")
    
    self._heatMapPinType = pinTypeString
    self._heatMapPinsInitialized = true
end

function TradeSkills.Mining:RefreshHeatMapPins()
    if not self:HasPerk(50) then return end
    if not self._heatMapPinsInitialized then return end
    
    local LMP = LibMapPins
    if LMP and self._heatMapPinType then
        LMP:RefreshPins(self._heatMapPinType)
    end
end

-- =======================
-- MINING PERK: MINER'S EYE (Level 10)
-- =======================
-- Shows the crafting level range for ore nodes when you approach them

-- Ore material to crafting level range mapping
TradeSkills.Mining.ORE_LEVEL_DATA = {
    -- Blacksmithing ores (node interactable names)
    ["iron ore"]        = "1-14",
    ["high iron ore"]   = "16-24",
    ["orichalcum ore"]  = "26-34",
    ["dwarven ore"]     = "36-44",
    ["ebony ore"]       = "46-50",
    ["calcinium ore"]   = "CP 10-30",
    ["galatite ore"]    = "CP 40-60",
    ["quicksilver ore"] = "CP 70-80",
    ["voidstone ore"]   = "CP 90-140",
    ["rubedite ore"]    = "CP 150-160",
    -- Blacksmithing seams
    ["iron seam"]        = "1-14",
    ["high iron seam"]   = "16-24",
    ["orichalcum seam"]  = "26-34",
    ["dwarven seam"]     = "36-44",
    ["ebony seam"]       = "46-50",
    ["calcinium seam"]   = "CP 10-30",
    ["galatite seam"]    = "CP 40-60",
    ["quicksilver seam"] = "CP 70-80",
    ["voidstone seam"]   = "CP 90-140",
    ["rubedite seam"]    = "CP 150-160",
    -- Jewelry dusts (nodes)
    ["pewter dust"]     = "1-24",
    ["copper dust"]     = "26-50",
    ["silver dust"]     = "CP 10-70",
    ["electrum dust"]   = "CP 80-140",
    ["platinum dust"]   = "CP 150-160",
    -- Jewelry seams
    ["pewter seam"]     = "1-24",
    ["copper seam"]     = "26-50",
    ["silver seam"]     = "CP 10-70",
    ["electrum seam"]   = "CP 80-140",
    ["platinum seam"]   = "CP 150-160",
}

function TradeSkills.Mining:CreateMinersEyePopup()
    if self._minersEyePopup then return end
    local existing = WINDOW_MANAGER:GetControlByName("TradeSkills_MinersEye")
    if existing then
        self._minersEyePopup = existing
        self._minersEyeLabel = existing:GetChild(2)
        return
    end
    local popup = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_MinersEye")
    popup:SetDimensions(260, 50)
    popup:SetAnchor(TOP, GuiRoot, TOP, 0, 120)
    popup:SetHidden(true)
    popup:SetDrawLayer(DL_OVERLAY)
    popup:SetDrawTier(DT_HIGH)
    
    local bg = WINDOW_MANAGER:CreateControl(nil, popup, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.85)
    bg:SetEdgeColor(0.7, 0.5, 0.3, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)
    
    local label = WINDOW_MANAGER:CreateControl(nil, popup, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetAnchor(CENTER, popup, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(0.9, 0.8, 0.6, 1)
    
    self._minersEyePopup = popup
    self._minersEyeLabel = label
end

function TradeSkills.Mining:ShowMinersEye(oreName)
    if not self:HasPerk(10) then return end
    
    local lowerName = string.lower(oreName)
    local levelRange = nil
    
    -- Check against localized ore names via the whitelist, map to English for lookup
    local englishName = lowerName
    if TradeSkills.L and TradeSkills.L.ReagentToEnglish then
        -- Ores aren't in ReagentToEnglish, so we check the mining whitelist directly
    end
    
    -- Try direct match first (works for English clients)
    -- Use longest match to avoid "iron ore" matching "high iron ore"
    local bestMatchLen = 0
    for oreLower, range in pairs(self.ORE_LEVEL_DATA) do
        if string.find(lowerName, oreLower, 1, true) then
            if #oreLower > bestMatchLen then
                bestMatchLen = #oreLower
                levelRange = range
            end
            break
        end
    end
    
    if not levelRange then return end
    
    if not self._minersEyePopup then
        self:CreateMinersEyePopup()
    end
    
    local cleanName = zo_strformat("<<1>>", oreName)
    self._minersEyeLabel:SetText("|cDEB887" .. cleanName .. "|r  |cFFFFFF→  Level " .. levelRange .. "|r")
    self._minersEyePopup:SetHidden(false)
    
    -- Auto-hide after 4 seconds
    if self._minersEyeHideId then
        EVENT_MANAGER:UnregisterForUpdate(self._minersEyeHideId)
    end
    self._minersEyeHideId = TradeSkills.name .. "_MINERS_EYE_HIDE"
    EVENT_MANAGER:RegisterForUpdate(self._minersEyeHideId, 4000, function()
        EVENT_MANAGER:UnregisterForUpdate(self._minersEyeHideId)
        if self._minersEyePopup then
            self._minersEyePopup:SetHidden(true)
        end
    end)
end

function TradeSkills.Mining:HideMinersEye()
    if self._minersEyePopup then
        self._minersEyePopup:SetHidden(true)
    end
    if self._minersEyeHideId then
        EVENT_MANAGER:UnregisterForUpdate(self._minersEyeHideId)
    end
end

-- =======================
-- MINING PERK: ORE TRACKER (Level 30)
-- =======================
-- While mining, displays total count of that ore in inventory + bank

function TradeSkills.Mining:CreateOreTrackerWindow()
    if self._oreTrackerWindow then return end
    -- Also check if control already exists in window manager (survives errors/reloads)
    local existing = WINDOW_MANAGER:GetControlByName("TradeSkills_OreTracker")
    if existing then
        self._oreTrackerWindow = existing
        self._oreTrackerLabel = existing:GetChild(3)
        self._oreTrackerCountLabel = existing:GetChild(4)
        return
    end
    local window = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_OreTracker")
    window:SetDimensions(280, 70)
    window:SetAnchor(TOP, GuiRoot, TOP, 0, 180)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    window:SetMouseEnabled(false)
    
    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.85)
    bg:SetEdgeColor(0.5, 0.4, 0.25, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)
    
    -- Ore name (e.g. "Rubedite Ore")
    local nameLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    nameLabel:SetFont("ZoFontGameBold")
    nameLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 8)
    nameLabel:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 8)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetMaxLineCount(1)
    nameLabel:SetColor(0.87, 0.72, 0.53, 1)
    
    -- Count breakdown (e.g. "Bag: 12  Bank: 200  Craft: 450")
    local countLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    countLabel:SetFont("ZoFontGame")
    countLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 35)
    countLabel:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 35)
    countLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    countLabel:SetMaxLineCount(1)
    countLabel:SetColor(0.8, 0.8, 0.8, 1)
    
    self._oreTrackerWindow = window
    self._oreTrackerLabel = nameLabel
    self._oreTrackerCountLabel = countLabel
end

function TradeSkills.Mining:ShowOreTracker(itemName, itemLink)
    if not self:HasPerk(30) then return end
    
    if not self._oreTrackerWindow then
        self:CreateOreTrackerWindow()
    end
    
    local cleanName = zo_strformat("<<1>>", itemName)
    local lowerName = string.lower(cleanName)
    
    -- Count in backpack
    local backpackCount = 0
    local bagSize = GetBagSize(BAG_BACKPACK)
    for slot = 0, bagSize - 1 do
        local slotLink = GetItemLink(BAG_BACKPACK, slot)
        if slotLink and slotLink ~= "" then
            local slotName = string.lower(zo_strformat("<<1>>", GetItemLinkName(slotLink)))
            if slotName == lowerName then
                local _, count = GetItemInfo(BAG_BACKPACK, slot)
                backpackCount = backpackCount + count
            end
        end
    end
    
    -- Count in bank
    local bankCount = 0
    local bankBags = {BAG_BANK, BAG_SUBSCRIBER_BANK}
    for _, bagId in ipairs(bankBags) do
        local bSize = GetBagSize(bagId)
        if bSize and bSize > 0 then
            for slot = 0, bSize - 1 do
                local slotLink = GetItemLink(bagId, slot)
                if slotLink and slotLink ~= "" then
                    local slotName = string.lower(zo_strformat("<<1>>", GetItemLinkName(slotLink)))
                    if slotName == lowerName then
                        local _, count = GetItemInfo(bagId, slot)
                        bankCount = bankCount + count
                    end
                end
            end
        end
    end
    
    -- Count in craft bag
    local craftBagCount = 0
    if itemLink then
        local itemId = GetItemLinkItemId(itemLink)
        if itemId and itemId > 0 then
            local _, stackCount = GetItemInfo(BAG_VIRTUAL, itemId)
            if stackCount and stackCount > 0 then
                craftBagCount = stackCount
            end
        end
    end
    
    -- Set ore name on title line
    self._oreTrackerLabel:SetText("|cDEB887" .. cleanName .. "|r")
    
    -- Build count line like Greenhouse Tracker: "Bag: X  Bank: Y  Craft: Z"
    local parts = {}
    table.insert(parts, "|cDEB887Bag:|r " .. backpackCount)
    table.insert(parts, "|cB38C4DBank:|r " .. bankCount)
    if HasCraftBagAccess() then
        table.insert(parts, "|c8B7333Craft:|r " .. craftBagCount)
    end
    if self._oreTrackerCountLabel then
        self._oreTrackerCountLabel:SetText(table.concat(parts, "  "))
    end
    
    self._oreTrackerWindow:SetHidden(false)
    
    -- Auto-hide after 5 seconds
    if self._oreTrackerHideId then
        EVENT_MANAGER:UnregisterForUpdate(self._oreTrackerHideId)
    end
    self._oreTrackerHideId = TradeSkills.name .. "_ORE_TRACKER_HIDE"
    EVENT_MANAGER:RegisterForUpdate(self._oreTrackerHideId, 5000, function()
        EVENT_MANAGER:UnregisterForUpdate(self._oreTrackerHideId)
        if self._oreTrackerWindow then
            self._oreTrackerWindow:SetHidden(true)
        end
    end)
end

function TradeSkills.Mining:HideOreTracker()
    if self._oreTrackerWindow then
        self._oreTrackerWindow:SetHidden(true)
    end
    if self._oreTrackerHideId then
        EVENT_MANAGER:UnregisterForUpdate(self._oreTrackerHideId)
    end
end

-- =======================
-- HERBALISM MODULE
-- =======================
TradeSkills.Herbalism = {
    name = "Herbalism",
    color = {0.3, 0.8, 0.3, 1},
    icon = "TradeSkills/icons/herbalism.dds",
    NODES_PER_LEVEL = 20,
    MAX_LEVEL = 50,
    RANKS = {
        {level = 0, name = "Gatherer", color = {0.6, 0.6, 0.6, 1}},
        {level = 100, name = "Herbalist", color = {0.5, 0.9, 0.5, 1}},
        {level = 200, name = "Master Herbalist", color = {0.6, 1, 0.6, 1}},
        {level = 300, name = "Botanist Supreme", color = {0.7, 1, 0.7, 1}},
        {level = 500, name = "Legendary Botanist", color = {0, 1, 0, 1}}
    },
    passiveAbilities = {
        {
            name = "Flora ID",
            icon = "TradeSkills/icons/herb_eye.dds",
            level = 10,
            description = "Shows potion and poison uses for alchemy reagents, and displays crafting level ranges for clothier fiber nodes.",
        },
        {
            name = "Greenhouse Tracker",
            icon = "TradeSkills/icons/herb_ledger.dds",
            level = 25,
            description = "While harvesting, displays a small tracker window showing how many of that plant you have in your inventory and bank.",
        },
        {
            name = "Scent of the Wild",
            icon = "TradeSkills/icons/wild_scent.dds",
            level = 40,
            description = "Plays a distinct audio cue and screen flash when a Columbine node is detected nearby on your compass.",
        },
    },
    IsPassiveActive = function(self, requiredLevel)
        if self._debugPerks then return true end
        if self:GetLevel() < requiredLevel then return false end
        return not TradeSkills.IsPerkDisabled("Herbalism", requiredLevel)
    end,
    IsAnyPassiveActive = function(self, requiredLevel)
        if self:GetLevel() < requiredLevel then return false end
        return not TradeSkills.IsPerkDisabled("Herbalism", requiredLevel)
    end,
}

-- ===================================================
-- FLORA ID DATA (Herbalism Passive - Level 10)
-- ===================================================
-- Maps reagent names to the potions/poisons they are primary ingredients for
-- Based on ESO alchemy trait combinations
TradeSkills.FLORA_POTION_DATA = {
    ["blessed thistle"] = {
        potions = {"Weapon Power Potion", "Speed Potion"},
        poisons = {"Drain Speed Poison", "Reduce Weapon Power Poison"},
    },
    ["blue entoloma"] = {
        potions = {"Spell Power Potion", "Invisibility Potion"},
        poisons = {"Drain Spell Power Poison", "Reveal Poison"},
    },
    ["bugloss"] = {
        potions = {"Health Restore Potion", "Spell Critical Potion"},
        poisons = {"Health Drain Poison"},
    },
    ["columbine"] = {
        potions = {"Health Restore Potion", "Magicka Restore Potion", "Stamina Restore Potion"},
        poisons = {},
    },
    ["corn flower"] = {
        potions = {"Magicka Restore Potion", "Spell Power Potion", "Spell Critical Potion"},
        poisons = {"Magicka Drain Poison"},
    },
    ["dragonthorn"] = {
        potions = {"Weapon Power Potion", "Weapon Critical Potion", "Stamina Restore Potion"},
        poisons = {"Reduce Weapon Power Poison"},
    },
    ["emetic russula"] = {
        potions = {"Invisibility Potion", "Magicka Restore Potion"},
        poisons = {"Vulnerability Poison", "Reveal Poison"},
    },
    ["imp stool"] = {
        potions = {"Health Restore Potion", "Weapon Critical Potion"},
        poisons = {"Health Drain Poison"},
    },
    ["lady's smock"] = {
        potions = {"Spell Power Potion", "Spell Critical Potion", "Magicka Restore Potion"},
        poisons = {"Drain Spell Power Poison"},
    },
    ["luminous russula"] = {
        potions = {"Health Restore Potion", "Speed Potion"},
        poisons = {"Health Drain Poison"},
    },
    ["mountain flower"] = {
        potions = {"Health Restore Potion", "Weapon Power Potion", "Stamina Restore Potion"},
        poisons = {"Health Drain Poison"},
    },
    ["namira's rot"] = {
        potions = {"Invisibility Potion", "Speed Potion", "Spell Critical Potion"},
        poisons = {"Reveal Poison", "Drain Speed Poison"},
    },
    ["nirnroot"] = {
        potions = {"Magicka Restore Potion", "Stamina Restore Potion", "Invisibility Potion"},
        poisons = {"Magicka Drain Poison", "Stamina Drain Poison"},
    },
    ["stinkhorn"] = {
        potions = {"Weapon Critical Potion", "Stamina Restore Potion"},
        poisons = {"Stamina Drain Poison"},
    },
    ["violet coprinus"] = {
        potions = {"Speed Potion", "Stamina Restore Potion"},
        poisons = {"Drain Speed Poison", "Stamina Drain Poison"},
    },
    ["water hyacinth"] = {
        potions = {"Spell Critical Potion", "Weapon Critical Potion", "Health Restore Potion"},
        poisons = {"Health Drain Poison"},
    },
    ["wormwood"] = {
        potions = {"Weapon Power Potion", "Invisibility Potion", "Reduce Spell Power"},
        poisons = {"Reduce Weapon Power Poison"},
    },
    ["lorkhan's tears"] = {
        potions = {"All Restore Potions (universal solvent)"},
        poisons = {},
    },
    ["clam gall"] = {
        potions = {"Health Restore Potion"},
        poisons = {"Hindrance Poison", "Health Drain Poison"},
    },
    ["powdered mother of pearl"] = {
        potions = {"Health Restore Potion", "Magicka Restore Potion"},
        poisons = {"Health Drain Poison", "Magicka Drain Poison"},
    },
}

-- Clothier fiber material to crafting level range mapping
-- Used by Flora ID to show level ranges on clothier raw material tooltips
TradeSkills.FIBER_LEVEL_DATA = {
    ["raw jute"]          = "1-14",
    ["raw flax"]          = "16-24",
    ["raw cotton"]        = "26-34",
    ["raw spidersilk"]    = "36-44",
    ["raw ebonthread"]    = "46-50",
    ["raw kresh fiber"]   = "CP 10-30",
    ["raw kreshweed"]     = "CP 10-30",
    ["raw ironthread"]    = "CP 40-60",
    ["raw silverweave"]   = "CP 70-80",
    ["raw void cloth"]    = "CP 90-140",
    ["raw void bloom"]    = "CP 90-140",
    ["raw ancestor silk"] = "CP 150-160",
}

-- Hook reagent tooltips for Flora ID
function TradeSkills.Herbalism:InitFloraIDTooltip()
    if self._floraTooltipHooked then return end
    self._floraTooltipHooked = true
    
    -- Keyboard mode hooks
    local origSetBagItem = ItemTooltip.SetBagItem
    ItemTooltip.SetBagItem = function(control, bagId, slotIndex, ...)
        origSetBagItem(control, bagId, slotIndex, ...)
        TradeSkills.Herbalism:AddFloraIDToTooltip(control, GetItemLink(bagId, slotIndex))
    end
    
    local origSetLink = ItemTooltip.SetLink
    if origSetLink then
        ItemTooltip.SetLink = function(control, itemLink, ...)
            origSetLink(control, itemLink, ...)
            TradeSkills.Herbalism:AddFloraIDToTooltip(control, itemLink)
        end
    end
    
    if PopupTooltip then
        local origPopupSetLink = PopupTooltip.SetLink
        if origPopupSetLink then
            PopupTooltip.SetLink = function(control, itemLink, ...)
                origPopupSetLink(control, itemLink, ...)
                TradeSkills.Herbalism:AddFloraIDToTooltip(control, itemLink)
            end
        end
    end
    
    -- Gamepad mode hooks
    if GAMEPAD_TOOLTIPS then
        SecurePostHook(GAMEPAD_TOOLTIPS, "LayoutBagItem", function(self, tooltipType, bagId, slotIndex, ...)
            local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(tooltipType)
            if tooltip then
                TradeSkills.Herbalism:AddFloraIDToTooltip(tooltip, GetItemLink(bagId, slotIndex))
            end
        end)
        SecurePostHook(GAMEPAD_TOOLTIPS, "LayoutItemLink", function(self, tooltipType, itemLink, ...)
            local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(tooltipType)
            if tooltip then
                TradeSkills.Herbalism:AddFloraIDToTooltip(tooltip, itemLink)
            end
        end)
    end
end

function TradeSkills.Herbalism:AddFloraIDToTooltip(tooltip, itemLink)
    if not tooltip or not itemLink or itemLink == "" then return end
    if not tooltip.AddLine then return end  -- Guard for incompatible tooltip objects
    if not self:IsPassiveActive(10) then return end
    
    local itemType = GetItemLinkItemType(itemLink)
    local name = string.lower(zo_strformat("<<1>>", GetItemLinkName(itemLink)))
    
    -- Alchemy reagents: show potion/poison info
    if itemType == ITEMTYPE_REAGENT then
        local data = TradeSkills.FLORA_POTION_DATA[name]
        if not data then return end
        
        tooltip:AddLine(" ", "ZoFontGameSmall", 1, 1, 1, 1, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
        tooltip:AddLine("|c4DCC66[Flora ID]|r", "ZoFontGameSmall", 1, 1, 1, 1, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
        
        if data.potions and #data.potions > 0 then
            tooltip:AddLine("|c88CC88Potions:|r " .. table.concat(data.potions, ", "), "ZoFontGameSmall", 1, 1, 1, 1, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
        end
        if data.poisons and #data.poisons > 0 then
            tooltip:AddLine("|cCC6666Poisons:|r " .. table.concat(data.poisons, ", "), "ZoFontGameSmall", 1, 1, 1, 1, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
        end
        return
    end
    
    -- Clothier raw materials: show crafting level range
    local fiberLevelRange = TradeSkills.FIBER_LEVEL_DATA[name]
    if not fiberLevelRange then
        -- Try partial match for grammar-tagged names
        for fiberName, range in pairs(TradeSkills.FIBER_LEVEL_DATA) do
            if string.find(name, fiberName, 1, true) then
                fiberLevelRange = range
                break
            end
        end
    end
    
    if fiberLevelRange then
        local cleanName = zo_strformat("<<1>>", GetItemLinkName(itemLink))
        tooltip:AddLine(" ", "ZoFontGameSmall", 1, 1, 1, 1, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
        tooltip:AddLine("|c4DCC66[Flora ID]|r", "ZoFontGameSmall", 1, 1, 1, 1, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
        tooltip:AddLine("|c88CC88Crafting Level:|r " .. fiberLevelRange, "ZoFontGameSmall", 1, 1, 1, 1, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
    end
end

-- ===================================================
-- GREENHOUSE TRACKER (Herbalism Passive - Level 25)
-- ===================================================
function TradeSkills.Herbalism:CreateGreenhouseWindow()
    if self._greenhouseWindow then return end
    
    local window = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_GreenhouseTracker")
    window:SetDimensions(280, 70)
    window:SetAnchor(TOP, GuiRoot, TOP, 0, 180)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    window:SetMouseEnabled(false)
    
    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.04, 0.06, 0.03, 0.92)
    bg:SetEdgeColor(0.3, 0.6, 0.3, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)
    
    local nameLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    nameLabel:SetFont("ZoFontGameBold")
    nameLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 8)
    nameLabel:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 8)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetMaxLineCount(1)
    nameLabel:SetColor(0.3, 0.9, 0.3, 1)
    
    local countLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    countLabel:SetFont("ZoFontGame")
    countLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 35)
    countLabel:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 35)
    countLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    countLabel:SetMaxLineCount(1)
    countLabel:SetColor(0.8, 0.9, 0.8, 1)
    
    self._greenhouseWindow = window
    self._greenhouseName = nameLabel
    self._greenhouseCount = countLabel
end

function TradeSkills.Herbalism:ShowGreenhouseTracker(itemName)
    if not self:IsPassiveActive(25) then return end
    if not self._greenhouseWindow then self:CreateGreenhouseWindow() end
    
    local cleanName = zo_strformat("<<1>>", itemName)
    local lowerName = string.lower(cleanName)
    
    -- For fiber plant nodes, the interactable is "Flax" but item is "Raw Flax"
    -- Build a list of names to match against inventory
    local searchNames = { lowerName }
    if not string.find(lowerName, "^raw ") then
        table.insert(searchNames, "raw " .. lowerName)
    end
    
    local function matchesSearch(slotName)
        for _, sn in ipairs(searchNames) do
            if slotName == sn then return true end
        end
        return false
    end
    
    -- Count in backpack
    local backpackCount = 0
    local bagSize = GetBagSize(BAG_BACKPACK)
    for slot = 0, bagSize - 1 do
        local slotLink = GetItemLink(BAG_BACKPACK, slot)
        if slotLink and slotLink ~= "" then
            local slotName = string.lower(zo_strformat("<<1>>", GetItemLinkName(slotLink)))
            if matchesSearch(slotName) then
                local _, count = GetItemInfo(BAG_BACKPACK, slot)
                backpackCount = backpackCount + count
            end
        end
    end
    
    -- Count in bank
    local bankCount = 0
    local bankBags = {BAG_BANK, BAG_SUBSCRIBER_BANK}
    for _, bagId in ipairs(bankBags) do
        local bankSize = GetBagSize(bagId)
        for slot = 0, bankSize - 1 do
            local slotLink = GetItemLink(bagId, slot)
            if slotLink and slotLink ~= "" then
                local slotName = string.lower(zo_strformat("<<1>>", GetItemLinkName(slotLink)))
                if matchesSearch(slotName) then
                    local _, count = GetItemInfo(bagId, slot)
                    bankCount = bankCount + count
                end
            end
        end
    end
    
    -- Count in craft bag (use item ID lookup, not slot iteration)
    local craftBagCount = 0
    if HasCraftBagAccess() then
        -- Find the item ID from backpack or bank so we can look it up directly in BAG_VIRTUAL
        local craftItemId = nil
        local bagSize2 = GetBagSize(BAG_BACKPACK)
        for slot = 0, bagSize2 - 1 do
            local slotLink = GetItemLink(BAG_BACKPACK, slot)
            if slotLink and slotLink ~= "" then
                local slotName = string.lower(zo_strformat("<<1>>", GetItemLinkName(slotLink)))
                if matchesSearch(slotName) then
                    craftItemId = GetItemLinkItemId(slotLink)
                    break
                end
            end
        end
        -- If not found in backpack, try bank
        if not craftItemId then
            local bankBags2 = {BAG_BANK, BAG_SUBSCRIBER_BANK}
            for _, bagId2 in ipairs(bankBags2) do
                local bSize = GetBagSize(bagId2)
                if bSize and bSize > 0 then
                    for slot = 0, bSize - 1 do
                        local slotLink = GetItemLink(bagId2, slot)
                        if slotLink and slotLink ~= "" then
                            local slotName = string.lower(zo_strformat("<<1>>", GetItemLinkName(slotLink)))
                            if matchesSearch(slotName) then
                                craftItemId = GetItemLinkItemId(slotLink)
                                break
                            end
                        end
                    end
                end
                if craftItemId then break end
            end
        end
        -- Look up directly by item ID in craft bag
        if craftItemId and craftItemId > 0 then
            local _, stackCount = GetItemInfo(BAG_VIRTUAL, craftItemId)
            if stackCount and stackCount > 0 then
                craftBagCount = stackCount
            end
        end
    end
    
    self._greenhouseName:SetText(cleanName)
    
    local parts = {}
    table.insert(parts, "|cAADDAABag:|r " .. backpackCount)
    table.insert(parts, "|c88BB88Bank:|r " .. bankCount)
    if HasCraftBagAccess() then
        table.insert(parts, "|c66AA66Craft:|r " .. craftBagCount)
    end
    self._greenhouseCount:SetText(table.concat(parts, "  "))
    
    self._greenhouseWindow:SetHidden(false)
    
    -- Auto-hide after 6 seconds
    if self._greenhouseHideId then
        EVENT_MANAGER:UnregisterForUpdate(self._greenhouseHideId)
    end
    self._greenhouseHideId = "TradeSkills_GreenhouseHide"
    EVENT_MANAGER:RegisterForUpdate(self._greenhouseHideId, 6000, function()
        EVENT_MANAGER:UnregisterForUpdate(self._greenhouseHideId)
        if self._greenhouseWindow then
            self._greenhouseWindow:SetHidden(true)
        end
    end)
end

-- ===================================================
-- FLORA ID: FIBER NODE LEVEL RANGE (Herbalism Passive - Level 10)
-- ===================================================
-- Shows a Miner's Eye-style popup with crafting level range when looking at clothier fiber nodes

-- Fiber node interactable name to crafting level range mapping
TradeSkills.Herbalism.FIBER_NODE_LEVEL_DATA = {
    ["jute"]          = "1-14",
    ["flax"]          = "16-24",
    ["cotton"]        = "26-34",
    ["spidersilk"]    = "36-44",
    ["ebonthread"]    = "46-50",
    ["kreshweed"]     = "CP 10-30",
    ["kresh fiber"]   = "CP 10-30",
    ["ironthread"]    = "CP 40-60",
    ["silverweave"]   = "CP 70-80",
    ["void bloom"]    = "CP 90-140",
    ["void cloth"]    = "CP 90-140",
    ["ancestor silk"] = "CP 150-160",
}

function TradeSkills.Herbalism:CreateFiberLevelPopup()
    if self._fiberLevelPopup then return end
    local existing = WINDOW_MANAGER:GetControlByName("TradeSkills_FiberLevel")
    if existing then
        self._fiberLevelPopup = existing
        self._fiberLevelLabel = existing:GetChild(2)
        return
    end
    local popup = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_FiberLevel")
    popup:SetDimensions(280, 50)
    popup:SetAnchor(TOP, GuiRoot, TOP, 0, 120)
    popup:SetHidden(true)
    popup:SetDrawLayer(DL_OVERLAY)
    popup:SetDrawTier(DT_HIGH)

    local bg = WINDOW_MANAGER:CreateControl(nil, popup, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.85)
    bg:SetEdgeColor(0.3, 0.6, 0.3, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)

    local label = WINDOW_MANAGER:CreateControl(nil, popup, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetAnchor(CENTER, popup, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(0.9, 0.8, 0.6, 1)

    self._fiberLevelPopup = popup
    self._fiberLevelLabel = label
end

function TradeSkills.Herbalism:ShowFiberLevelRange(nodeName)
    if not self:IsPassiveActive(10) then return end

    local lowerName = string.lower(nodeName)
    local levelRange = nil
    local bestMatchLen = 0

    for fiberName, range in pairs(self.FIBER_NODE_LEVEL_DATA) do
        if string.find(lowerName, fiberName, 1, true) then
            if #fiberName > bestMatchLen then
                bestMatchLen = #fiberName
                levelRange = range
            end
        end
    end

    -- Not a fiber node (could be an alchemy reagent node) - hide popup
    if not levelRange then
        self:HideFiberLevelRange()
        return
    end

    if not self._fiberLevelPopup then
        self:CreateFiberLevelPopup()
    end

    local cleanName = zo_strformat("<<1>>", nodeName)
    self._fiberLevelLabel:SetText("|c4DCC66" .. cleanName .. "|r  |cFFFFFF\226\134\146  Level " .. levelRange .. "|r")
    self._fiberLevelPopup:SetHidden(false)

    -- Auto-hide after 4 seconds
    if self._fiberLevelHideId then
        EVENT_MANAGER:UnregisterForUpdate(self._fiberLevelHideId)
    end
    self._fiberLevelHideId = TradeSkills.name .. "_FIBER_LEVEL_HIDE"
    EVENT_MANAGER:RegisterForUpdate(self._fiberLevelHideId, 4000, function()
        EVENT_MANAGER:UnregisterForUpdate(self._fiberLevelHideId)
        if self._fiberLevelPopup then
            self._fiberLevelPopup:SetHidden(true)
        end
    end)
end

function TradeSkills.Herbalism:HideFiberLevelRange()
    if self._fiberLevelPopup then
        self._fiberLevelPopup:SetHidden(true)
    end
    if self._fiberLevelHideId then
        EVENT_MANAGER:UnregisterForUpdate(self._fiberLevelHideId)
    end
end

-- ===================================================
-- SCENT OF THE WILD (Herbalism Passive - Level 40)
-- ===================================================
-- Detects Columbine nodes within proximity using the compass pin system.
-- ESO's compass displays MAP_PIN_TYPE_HARVEST_NODE pins for nearby resource nodes.
-- We poll ZO_CompassContainer's centered pins to identify Columbine.

function TradeSkills.Herbalism:InitScentOfTheWild()
    if self._scentInitialized then return end
    self._scentInitialized = true
    
    -- Create screen flash overlay
    local flash = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_ColumbineFlash")
    flash:SetDimensions(GuiRoot:GetWidth(), GuiRoot:GetHeight())
    flash:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    flash:SetHidden(true)
    flash:SetDrawLayer(DL_OVERLAY)
    flash:SetDrawTier(DT_HIGH)
    flash:SetMouseEnabled(false)
    
    local flashBg = WINDOW_MANAGER:CreateControl(nil, flash, CT_BACKDROP)
    flashBg:SetAnchorFill(flash)
    flashBg:SetCenterColor(0.2, 0.8, 0.3, 0.25)
    flashBg:SetEdgeColor(0, 0, 0, 0)
    
    self._columbineFlash = flash
    self._columbineFlashBg = flashBg
    
    -- Create text alert
    local alert = WINDOW_MANAGER:CreateControl(nil, flash, CT_LABEL)
    alert:SetFont("ZoFontCallout")
    alert:SetAnchor(CENTER, flash, CENTER, 0, -150)
    alert:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    alert:SetColor(0.3, 1, 0.4, 1)
    alert:SetText("|c4DFF66~ Columbine Nearby ~|r")
    self._columbineAlert = alert
    
    -- Start compass scanning for Columbine
    EVENT_MANAGER:RegisterForUpdate("TradeSkills_ScentOfTheWild", 500, function()
        self:ScanCompassForColumbine()
    end)
end

function TradeSkills.Herbalism:ScanCompassForColumbine()
    if not self:IsPassiveActive(40) then return end
    
    local container = ZO_CompassContainer
    if not container or container:IsHidden() then return end
    
    -- Method 1: Check centered/overed pins (these have descriptions available)
    local numCentered = container:GetNumCenterOveredPins()
    for i = 1, numCentered do
        local pinType = container:GetCenterOveredPinType(i)
        if pinType == MAP_PIN_TYPE_HARVEST_NODE then
            local description = container:GetCenterOveredPinDescription(i)
            if description and type(description) == "string" then
                if string.find(string.lower(description), "columbine") then
                    self:TriggerColumbineAlert()
                    return
                end
            end
        end
    end
    
    -- Method 2: Iterate compass pin children for proximity detection
    -- Compass pin scale indicates distance: scale closer to 2.0 = very close, 
    -- lower scale = further away. (2 - scale) * 100 ≈ distance in meters.
    -- 25 feet ≈ 7.6 meters → scale > ~1.92
    -- We use a generous threshold of 1.5 (~50m / ~164ft) to give early warning.
    local numChildren = container:GetNumChildren()
    for c = 1, numChildren do
        local child = container:GetChild(c)
        if child and not child:IsHidden() then
            local scale = child:GetScale()
            -- Compass harvest pins use scale 0.0 (far at 200m) to 2.0 (on top of you)
            -- Only check pins with a meaningful scale (close enough to care about)
            if scale and scale > 1.5 then
                -- We can't directly get the description of a child control, 
                -- but if it's close enough AND we have a centered pin match, 
                -- Method 1 above will catch it. This block is a fallback.
            end
        end
    end
end

function TradeSkills.Herbalism:TriggerColumbineAlert()
    if not self._columbineFlash then return end
    
    -- Prevent spamming (cooldown 15 seconds)
    local now = GetGameTimeMilliseconds()
    if self._lastColumbineAlert and (now - self._lastColumbineAlert) < 15000 then return end
    self._lastColumbineAlert = now
    
    -- Play audio cue
    PlaySound(SOUNDS.COLLECTIBLE_UNLOCKED)
    
    -- Show screen flash
    self._columbineFlash:SetHidden(false)
    self._columbineFlash:SetAlpha(1)
    
    -- Also show center screen announcement
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
    if params then
        params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        params:SetText("", "|c4DFF66~ Columbine Nearby! ~|r")
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
    end
    
    -- Fade out flash over 2 seconds
    local startTime = now
    local fadeId = "TradeSkills_ColumbineFade"
    EVENT_MANAGER:UnregisterForUpdate(fadeId)
    EVENT_MANAGER:RegisterForUpdate(fadeId, 33, function()
        local elapsed = GetGameTimeMilliseconds() - startTime
        local alpha = 1 - (elapsed / 2000)
        if alpha <= 0 then
            EVENT_MANAGER:UnregisterForUpdate(fadeId)
            self._columbineFlash:SetHidden(true)
        else
            self._columbineFlash:SetAlpha(alpha)
        end
    end)
end

-- Check if a loot interaction is a Columbine node (reticle-based fallback)
function TradeSkills.Herbalism:CheckForColumbine(interactionName)
    if not interactionName then return end
    if string.find(string.lower(interactionName), "columbine") then
        self:TriggerColumbineAlert()
    end
end

function TradeSkills.Herbalism:GetCount()
    return TradeSkills.savedVars.herbalism.totalNodesGathered
end

function TradeSkills.Herbalism:GetLevel()
    local level = math.floor(self:GetCount() / self.NODES_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function TradeSkills.Herbalism:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.NODES_PER_LEVEL, self.NODES_PER_LEVEL
    end
    return count % self.NODES_PER_LEVEL, self.NODES_PER_LEVEL
end

function TradeSkills.Herbalism:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function TradeSkills.Herbalism:GetAchievementsCompleted()
    if not self._achievements then
        self._achievements = TradeSkills.FindAchievementsBySubCategory("Alchemy")
    end
    local completed = 0
    for _, achievementId in ipairs(self._achievements) do
        local _, _, _, _, isCompleted = GetAchievementInfo(achievementId)
        if isCompleted then
            completed = completed + 1
        end
    end
    return completed, #self._achievements
end

function TradeSkills.Herbalism:GetDescription()
    local nodeCount = self:GetCount()
    local completed, total = self:GetAchievementsCompleted()
    return string.format(
        "Gather plants to increase skill.\nEvery 25 nodes gathered increases your level by 1. Max level 50.\n\nPlant Nodes Gathered: %d\nAlchemy Achievements Earned: %d/%d",
        nodeCount, completed, total
    )
end

-- =======================
-- WOODCUTTING MODULE
-- =======================
TradeSkills.Woodcutting = {
    name = "Woodcutting",
    color = {0.4, 0.65, 0.2, 1},
    icon = "TradeSkills/icons/woodcutting.dds",
    NODES_PER_LEVEL = 20,
    MAX_LEVEL = 50,
    RANKS = {
        {level = 0, name = "Sapling", color = {0.6, 0.6, 0.6, 1}},
        {level = 100, name = "Woodsman", color = {0.5, 0.7, 0.3, 1}},
        {level = 200, name = "Forester", color = {0.5, 0.8, 0.3, 1}},
        {level = 300, name = "Master Lumberjack", color = {0.4, 0.9, 0.2, 1}},
        {level = 500, name = "Warden of the Grove", color = {0.3, 1, 0.1, 1}}
    },
    passiveAbilities = {
        {
            name = "Timber Sense",
            icon = "TradeSkills/icons/timber_sense.dds",
            level = 10,
            description = "When approaching a wood node, shows the crafting level range for that material.",
        },
        {
            name = "Log Ledger",
            icon = "TradeSkills/icons/log_ledger.dds",
            level = 30,
            description = "While harvesting wood, displays a small tracker showing your total inventory of that wood type.",
        },
        {
            name = "Grove Map",
            icon = "TradeSkills/icons/grove_map.dds",
            level = 50,
            description = "Marks wood-rich harvesting areas on your map.",
        },
    },
    _debugPerks = false,
}

function TradeSkills.Woodcutting:GetCount()
    return TradeSkills.savedVars.woodcutting.totalNodesGathered
end

function TradeSkills.Woodcutting:GetLevel()
    local level = math.floor(self:GetCount() / self.NODES_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function TradeSkills.Woodcutting:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.NODES_PER_LEVEL, self.NODES_PER_LEVEL
    end
    return count % self.NODES_PER_LEVEL, self.NODES_PER_LEVEL
end

function TradeSkills.Woodcutting:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function TradeSkills.Woodcutting:GetAchievementsCompleted()
    if not self._woodworkingAchievements then
        self._woodworkingAchievements = TradeSkills.FindAchievementsBySubCategory("Woodworking")
    end
    local completed = 0
    for _, achievementId in ipairs(self._woodworkingAchievements) do
        local _, _, _, _, isCompleted = GetAchievementInfo(achievementId)
        if isCompleted then
            completed = completed + 1
        end
    end
    return completed, #self._woodworkingAchievements
end

function TradeSkills.Woodcutting:GetDescription()
    local nodeCount = self:GetCount()
    local wwDone, wwTotal = self:GetAchievementsCompleted()
    local text = "Harvest wood nodes to increase skill.\n"
    text = text .. "Every 20 nodes harvested increases your level by 1. Max level 50.\n\n"
    text = text .. "Wood Nodes Harvested: " .. nodeCount .. "\n"
    text = text .. "Woodworking Achievements: " .. wwDone .. "/" .. wwTotal
    return text
end

function TradeSkills.Woodcutting:HasPerk(requiredLevel)
    if self._debugPerks then
        return not TradeSkills.IsPerkDisabled("Woodcutting", requiredLevel)
    end
    if self:GetLevel() < requiredLevel then return false end
    return not TradeSkills.IsPerkDisabled("Woodcutting", requiredLevel)
end

-- =======================
-- WOODCUTTING PERK: GROVE MAP (Level 50)
-- =======================
-- Places pins on the world map for wood-rich harvesting areas

function TradeSkills.Woodcutting:GetGroveMapLocations()
    if not self:HasPerk(50) then return nil end
    if not TradeSkills.accountVars then return nil end

    local currentMapId = GetCurrentMapId()
    if not currentMapId then return nil end

    local pins = TradeSkills.accountVars.groveMapPins and TradeSkills.accountVars.groveMapPins[currentMapId]
    if pins and #pins > 0 then
        return pins
    end
    return nil
end

function TradeSkills.Woodcutting:AddGroveMapPin(label)
    if not self:HasPerk(50) then return end
    if not TradeSkills.accountVars then return end

    local mapId = GetCurrentMapId()
    local x, y = GetMapPlayerPosition("player")

    if not label or label == "" then
        local zoneName = zo_strformat("<<1>>", GetUnitZone("player"))
        label = zoneName .. " - Wood Farming"
    end

    if not TradeSkills.accountVars.groveMapPins then
        TradeSkills.accountVars.groveMapPins = {}
    end
    if not TradeSkills.accountVars.groveMapPins[mapId] then
        TradeSkills.accountVars.groveMapPins[mapId] = {}
    end

    table.insert(TradeSkills.accountVars.groveMapPins[mapId], {x, y, label})
    self:RefreshGroveMapPins()
end

function TradeSkills.Woodcutting:RemoveNearestGroveMapPin()
    if not self:HasPerk(50) then return end
    if not TradeSkills.accountVars then return end
    local mapId = GetCurrentMapId()
    local pins = TradeSkills.accountVars.groveMapPins and TradeSkills.accountVars.groveMapPins[mapId]
    if not pins or #pins == 0 then return end

    local px, py = GetMapPlayerPosition("player")
    local closestIdx = 1
    local closestDist = math.huge

    for i, pin in ipairs(pins) do
        local dx = pin[1] - px
        local dy = pin[2] - py
        local dist = dx * dx + dy * dy
        if dist < closestDist then
            closestDist = dist
            closestIdx = i
        end
    end

    table.remove(pins, closestIdx)
    self:RefreshGroveMapPins()
end

function TradeSkills.Woodcutting:ClearAllGroveMapPins()
    if not TradeSkills.accountVars then return end
    TradeSkills.accountVars.groveMapPins = {}
    self:RefreshGroveMapPins()
end

function TradeSkills.Woodcutting:InitGroveMapPins()
    local LMP = LibMapPins
    if not LMP then return end

    local pinTypeString = "TradeSkills_GroveMapPin"

    local pinLayoutData = {
        level = 200,
        texture = "TradeSkills/icons/grove_map_pin.dds",
        size = 32,
        minSize = 20,
    }

    local pinTooltipCreator = {
        creator = function(pin)
            local pinTag = pin.m_PinTag
            if pinTag and pinTag.label then
                InformationTooltip:AddLine(pinTag.label)
                InformationTooltip:AddLine("Woodcutting: Wood-rich area", "", ZO_ColorDef:New(0.4, 0.65, 0.2, 1):UnpackRGBA())
            end
        end,
        tooltip = InformationTooltip,
    }

    local function pinTypeAddCallback(pinManager)
        if not TradeSkills.Woodcutting:HasPerk(50) then return end
        local locations = TradeSkills.Woodcutting:GetGroveMapLocations()
        if not locations then return end

        for _, loc in ipairs(locations) do
            local pinInfo = { label = loc[3] }
            LMP:CreatePin(pinTypeString, pinInfo, loc[1], loc[2])
        end
    end

    LMP:AddPinType(pinTypeString, pinTypeAddCallback, nil, pinLayoutData, pinTooltipCreator)
    LMP:AddPinFilter(pinTypeString, "Woodcutting: Grove Locations")

    self._groveMapPinType = pinTypeString
    self._groveMapPinsInitialized = true
end

function TradeSkills.Woodcutting:RefreshGroveMapPins()
    if not self:HasPerk(50) then return end
    if not self._groveMapPinsInitialized then return end

    local LMP = LibMapPins
    if LMP and self._groveMapPinType then
        LMP:RefreshPins(self._groveMapPinType)
    end
end

-- =======================
-- WOODCUTTING PERK: TIMBER SENSE (Level 10)
-- =======================
-- Shows the crafting level range for wood nodes when you approach them

TradeSkills.Woodcutting.WOOD_LEVEL_DATA = {
    -- Raw wood node interactable names
    ["maple"]       = "1-14",
    ["oak"]         = "16-24",
    ["beech"]       = "26-34",
    ["hickory"]     = "36-44",
    ["yew"]         = "46-50",
    ["birch"]       = "CP 10-30",
    ["ash"]         = "CP 40-60",
    ["mahogany"]    = "CP 70-80",
    ["nightwood"]   = "CP 90-140",
    ["ruby ash"]    = "CP 150-160",
}

function TradeSkills.Woodcutting:CreateTimberSensePopup()
    if self._timberSensePopup then return end
    local existing = WINDOW_MANAGER:GetControlByName("TradeSkills_TimberSense")
    if existing then
        self._timberSensePopup = existing
        self._timberSenseLabel = existing:GetChild(2)
        return
    end
    local popup = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_TimberSense")
    popup:SetDimensions(280, 50)
    popup:SetAnchor(TOP, GuiRoot, TOP, 0, 120)
    popup:SetHidden(true)
    popup:SetDrawLayer(DL_OVERLAY)
    popup:SetDrawTier(DT_HIGH)

    local bg = WINDOW_MANAGER:CreateControl(nil, popup, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.85)
    bg:SetEdgeColor(0.4, 0.65, 0.2, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)

    local label = WINDOW_MANAGER:CreateControl(nil, popup, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetAnchor(CENTER, popup, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(0.9, 0.8, 0.6, 1)

    self._timberSensePopup = popup
    self._timberSenseLabel = label
end

function TradeSkills.Woodcutting:ShowTimberSense(nodeName)
    if not self:HasPerk(10) then return end

    local lowerName = string.lower(nodeName)
    local levelRange = nil
    local bestMatchLen = 0

    for woodLower, range in pairs(self.WOOD_LEVEL_DATA) do
        if string.find(lowerName, woodLower, 1, true) then
            if #woodLower > bestMatchLen then
                bestMatchLen = #woodLower
                levelRange = range
            end
        end
    end

    if not levelRange then return end

    if not self._timberSensePopup then
        self:CreateTimberSensePopup()
    end

    local cleanName = zo_strformat("<<1>>", nodeName)
    self._timberSenseLabel:SetText("|c8FBF40" .. cleanName .. "|r  |cFFFFFF\226\134\146  Level " .. levelRange .. "|r")
    self._timberSensePopup:SetHidden(false)

    -- Auto-hide after 4 seconds
    if self._timberSenseHideId then
        EVENT_MANAGER:UnregisterForUpdate(self._timberSenseHideId)
    end
    self._timberSenseHideId = TradeSkills.name .. "_TIMBER_SENSE_HIDE"
    EVENT_MANAGER:RegisterForUpdate(self._timberSenseHideId, 4000, function()
        EVENT_MANAGER:UnregisterForUpdate(self._timberSenseHideId)
        if self._timberSensePopup then
            self._timberSensePopup:SetHidden(true)
        end
    end)
end

function TradeSkills.Woodcutting:HideTimberSense()
    if self._timberSensePopup then
        self._timberSensePopup:SetHidden(true)
    end
    if self._timberSenseHideId then
        EVENT_MANAGER:UnregisterForUpdate(self._timberSenseHideId)
    end
end

-- =======================
-- WOODCUTTING PERK: LOG LEDGER (Level 30)
-- =======================
-- While harvesting wood, displays total count of that wood in inventory + bank

function TradeSkills.Woodcutting:CreateLogLedgerWindow()
    if self._logLedgerWindow then return end
    local existing = WINDOW_MANAGER:GetControlByName("TradeSkills_LogLedger")
    if existing then
        self._logLedgerWindow = existing
        self._logLedgerLabel = existing:GetChild(3)
        self._logLedgerCountLabel = existing:GetChild(4)
        return
    end
    local window = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_LogLedger")
    window:SetDimensions(280, 70)
    window:SetAnchor(TOP, GuiRoot, TOP, 0, 180)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    window:SetMouseEnabled(false)

    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.85)
    bg:SetEdgeColor(0.4, 0.55, 0.2, 0.9)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)

    -- Wood name
    local nameLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    nameLabel:SetFont("ZoFontGameBold")
    nameLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 8)
    nameLabel:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 8)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetMaxLineCount(1)
    nameLabel:SetColor(0.56, 0.8, 0.26, 1)

    -- Count breakdown
    local countLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    countLabel:SetFont("ZoFontGame")
    countLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 35)
    countLabel:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 35)
    countLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    countLabel:SetMaxLineCount(1)
    countLabel:SetColor(0.8, 0.8, 0.8, 1)

    self._logLedgerWindow = window
    self._logLedgerLabel = nameLabel
    self._logLedgerCountLabel = countLabel
end

function TradeSkills.Woodcutting:ShowLogLedger(itemName, itemLink)
    if not self:HasPerk(30) then return end

    if not self._logLedgerWindow then
        self:CreateLogLedgerWindow()
    end

    local cleanName = zo_strformat("<<1>>", itemName)
    local lowerName = string.lower(cleanName)

    -- Count in backpack
    local backpackCount = 0
    local bagSize = GetBagSize(BAG_BACKPACK)
    for slot = 0, bagSize - 1 do
        local slotLink = GetItemLink(BAG_BACKPACK, slot)
        if slotLink and slotLink ~= "" then
            local slotName = string.lower(zo_strformat("<<1>>", GetItemLinkName(slotLink)))
            if slotName == lowerName then
                local _, count = GetItemInfo(BAG_BACKPACK, slot)
                backpackCount = backpackCount + count
            end
        end
    end

    -- Count in bank
    local bankCount = 0
    local bankBags = {BAG_BANK, BAG_SUBSCRIBER_BANK}
    for _, bagId in ipairs(bankBags) do
        local bSize = GetBagSize(bagId)
        if bSize and bSize > 0 then
            for slot = 0, bSize - 1 do
                local slotLink = GetItemLink(bagId, slot)
                if slotLink and slotLink ~= "" then
                    local slotName = string.lower(zo_strformat("<<1>>", GetItemLinkName(slotLink)))
                    if slotName == lowerName then
                        local _, count = GetItemInfo(bagId, slot)
                        bankCount = bankCount + count
                    end
                end
            end
        end
    end

    -- Count in craft bag
    local craftBagCount = 0
    if itemLink then
        local itemId = GetItemLinkItemId(itemLink)
        if itemId and itemId > 0 then
            local _, stackCount = GetItemInfo(BAG_VIRTUAL, itemId)
            if stackCount and stackCount > 0 then
                craftBagCount = stackCount
            end
        end
    end

    self._logLedgerLabel:SetText("|c8FBF40" .. cleanName .. "|r")

    local parts = {}
    table.insert(parts, "|c8FBF40Bag:|r " .. backpackCount)
    table.insert(parts, "|c6B9930Bank:|r " .. bankCount)
    if HasCraftBagAccess() then
        table.insert(parts, "|c4D7320Craft:|r " .. craftBagCount)
    end
    if self._logLedgerCountLabel then
        self._logLedgerCountLabel:SetText(table.concat(parts, "  "))
    end

    self._logLedgerWindow:SetHidden(false)

    -- Auto-hide after 5 seconds
    if self._logLedgerHideId then
        EVENT_MANAGER:UnregisterForUpdate(self._logLedgerHideId)
    end
    self._logLedgerHideId = TradeSkills.name .. "_LOG_LEDGER_HIDE"
    EVENT_MANAGER:RegisterForUpdate(self._logLedgerHideId, 5000, function()
        EVENT_MANAGER:UnregisterForUpdate(self._logLedgerHideId)
        if self._logLedgerWindow then
            self._logLedgerWindow:SetHidden(true)
        end
    end)
end

function TradeSkills.Woodcutting:HideLogLedger()
    if self._logLedgerWindow then
        self._logLedgerWindow:SetHidden(true)
    end
    if self._logLedgerHideId then
        EVENT_MANAGER:UnregisterForUpdate(self._logLedgerHideId)
    end
end

-- =======================
-- SKINNING MODULE
-- =======================
TradeSkills.Skinning = {
    name = "Skinning",
    color = {0.75, 0.55, 0.35, 1},
    icon = "TradeSkills/icons/skinning.dds",
    SCRAPS_PER_LEVEL = 20,
    MAX_LEVEL = 50,
    RANKS = {
        {level = 0, name = "Skinner", color = {0.6, 0.6, 0.6, 1}},
        {level = 100, name = "Tanner", color = {0.8, 0.6, 0.4, 1}},
        {level = 200, name = "Master Tanner", color = {0.85, 0.65, 0.45, 1}},
        {level = 300, name = "Hide Master", color = {0.9, 0.7, 0.5, 1}},
        {level = 500, name = "Legendary Skinner", color = {1, 0.84, 0, 1}}
    },
    passiveAbilities = {
        {
            name = "Beast Watch",
            icon = "TradeSkills/icons/beast_watch.dds",
            level = 10,
            description = "Highlights nearby enemies that drop tailoring scraps.",
        },
        {
            name = "Anatomy Specialist",
            icon = "TradeSkills/icons/anatomy_specialist.dds",
            level = 30,
            description = "Learns and shows loot drops when targeting scrap creatures.",
        },
        {
            name = "Herd Map",
            icon = "TradeSkills/icons/herd_map.dds",
            level = 50,
            description = "Marks scrap-rich hunting areas on your map.",
        },
    }
}

function TradeSkills.Skinning:GetCount()
    return TradeSkills.savedVars.skinning.totalScrapsLooted
end

function TradeSkills.Skinning:GetLevel()
    local level = math.floor(self:GetCount() / self.SCRAPS_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function TradeSkills.Skinning:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.SCRAPS_PER_LEVEL, self.SCRAPS_PER_LEVEL
    end
    return count % self.SCRAPS_PER_LEVEL, self.SCRAPS_PER_LEVEL
end

function TradeSkills.Skinning:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function TradeSkills.Skinning:GetAchievementsCompleted()
    if not self._trophyAchievements then
        self._trophyAchievements = TradeSkills.FindAchievementsBySubCategory("Trophies")
    end
    if not self._clothierAchievements then
        self._clothierAchievements = TradeSkills.FindAchievementsBySubCategory("Clothier")
    end
    
    local trophyCompleted = 0
    for _, achievementId in ipairs(self._trophyAchievements) do
        local _, _, _, _, isCompleted = GetAchievementInfo(achievementId)
        if isCompleted then
            trophyCompleted = trophyCompleted + 1
        end
    end
    
    local clothierCompleted = 0
    for _, achievementId in ipairs(self._clothierAchievements) do
        local _, _, _, _, isCompleted = GetAchievementInfo(achievementId)
        if isCompleted then
            clothierCompleted = clothierCompleted + 1
        end
    end
    
    return trophyCompleted, #self._trophyAchievements, clothierCompleted, #self._clothierAchievements
end

function TradeSkills.Skinning:GetDescription()
    local scrapCount = self:GetCount()
    local trophyDone, trophyTotal, clothierDone, clothierTotal = self:GetAchievementsCompleted()
    local text = "Loot raw material scraps from creatures to increase skill.\n"
    text = text .. "Every 20 scraps looted increases your level by 1. Max level 50.\n\n"
    text = text .. "Raw Scraps Looted: " .. scrapCount .. "\n"
    text = text .. "Trophy Achievements: " .. trophyDone .. "/" .. trophyTotal .. "\n"
    text = text .. "Clothier Achievements: " .. clothierDone .. "/" .. clothierTotal
    return text
end

function TradeSkills.Skinning:HasPerk(requiredLevel)
    if self._debugPerks then
        return not TradeSkills.IsPerkDisabled("Skinning", requiredLevel)
    end
    if self:GetLevel() < requiredLevel then return false end
    return not TradeSkills.IsPerkDisabled("Skinning", requiredLevel)
end

-- =======================
-- SKINNING PERK: BEAST WATCH (Level 10)
-- =======================
-- Highlights nearby enemies that drop crafting scraps (raw materials for Clothier)
-- Uses a periodic scan of nearby units and applies a visual glow/reticle highlight

-- Item types that indicate an enemy drops scraps
TradeSkills.Skinning.SCRAP_ITEM_TYPES = {
    [ITEMTYPE_RAW_MATERIAL] = true,
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = true,
    [ITEMTYPE_STYLE_MATERIAL] = true,
}

-- Word-boundary match: ensures "bat" matches "Bat" but not "Combat"
function TradeSkills.Skinning.MatchCreatureName(lowerName, creature)
    local startPos, endPos = string.find(lowerName, creature, 1, true)  -- plain find
    if not startPos then return false end
    -- Check character before match is not a letter
    if startPos > 1 then
        local before = string.sub(lowerName, startPos - 1, startPos - 1)
        if string.find(before, "%a") then return false end
    end
    -- Check character after match is not a letter
    if endPos < #lowerName then
        local after = string.sub(lowerName, endPos + 1, endPos + 1)
        if string.find(after, "%a") then return false end
    end
    return true
end

-- Known scrap-dropping creature types (broad categories)
TradeSkills.Skinning.SCRAP_CREATURE_NAMES = {
    -- Beasts
    ["wolf"] = true, ["bear"] = true, ["lion"] = true, ["tiger"] = true,
    ["senche"] = true, ["sabrecat"] = true, ["kagouti"] = true, ["guar"] = true,
    ["netch"] = true, ["mammoth"] = true, ["echatere"] = true, ["welwa"] = true,
    ["durzog"] = true, ["wamasu"] = true, ["alit"] = true, ["cliff strider"] = true,
    ["deer"] = true, ["elk"] = true, ["goat"] = true, ["sheep"] = true,
    ["pig"] = true, ["cow"] = true, ["horse"] = true, ["donkey"] = true,
    ["mudcrab"] = true, ["rat"] = true, ["snake"] = true, ["scorpion"] = true,
    ["spider"] = true, ["thunderbug"] = true, ["wasp"] = true, ["beetle"] = true,
    ["jackal"] = true, ["fox"] = true, ["crocodile"] = true, ["haj mota"] = true,
    ["bat"] = true, ["skeever"] = true, ["monkey"] = true, ["bantam guar"] = true,
    ["nixhound"] = true, ["nix-hound"] = true, ["shalk"] = true, ["kwama"] = true,
    ["fetcherfly"] = true, ["clannfear"] = true, ["hunger"] = true,
    ["dreugh"] = true,
}

function TradeSkills.Skinning:IsScrapCreature(unitTag)
    local name = string.lower(GetUnitName(unitTag) or "")
    for creature, _ in pairs(self.SCRAP_CREATURE_NAMES) do
        if self.MatchCreatureName(name, creature) then
            return true
        end
    end
    return false
end

function TradeSkills.Skinning:StartBeastWatch()
    if not self:HasPerk(10) then return end
    if self._beastWatchActive then return end
    self._beastWatchActive = true
    
    -- Register for reticle target to add a colored highlight on scrap creatures
    -- We modify the reticle nameplate color to indicate scrap-dropping creatures
    EVENT_MANAGER:RegisterForUpdate("TradeSkills_BeastWatch", 500, function()
        if not TradeSkills.Skinning:HasPerk(10) then
            TradeSkills.Skinning:StopBeastWatch()
            return
        end
        
        -- Check current reticle target
        local unitTag = "reticleover"
        if DoesUnitExist(unitTag) and not IsUnitDead(unitTag) and not IsUnitPlayer(unitTag) then
            local rawName = GetUnitName(unitTag)
            if rawName and rawName ~= "" then
                local unitName = zo_strformat("<<1>>", rawName)
                local lowerName = string.lower(unitName)
                local isScrapCreature = false
                
                for creature, _ in pairs(TradeSkills.Skinning.SCRAP_CREATURE_NAMES) do
                    if TradeSkills.Skinning.MatchCreatureName(lowerName, creature) then
                        isScrapCreature = true
                        break
                    end
                end
                
                if isScrapCreature then
                    -- Combined window: ShowBeastIndicator handles both Beast Watch + Anatomy Specialist
                    TradeSkills.Skinning:ShowBeastIndicator(unitName)
                    return
                end
            end
        end
        -- Not looking at a scrap creature - hide the combined window
        TradeSkills.Skinning:HideBeastIndicator()
    end)
end

function TradeSkills.Skinning:StopBeastWatch()
    self._beastWatchActive = false
    EVENT_MANAGER:UnregisterForUpdate("TradeSkills_BeastWatch")
    self:HideBeastIndicator()
end

function TradeSkills.Skinning:CreateBeastIndicator()
    if self._beastIndicator then return end
    
    -- Create combined window that serves as both Beast Watch indicator and Anatomy Specialist loot display
    local indicator = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_BeastIndicator")
    indicator:SetDimensions(280, 24)
    indicator:SetHidden(true)
    indicator:SetMouseEnabled(true)
    indicator:SetMovable(true)
    indicator:SetClampedToScreen(true)
    indicator:SetDrawTier(DT_HIGH)
    
    -- Restore saved position or use default
    local savedPos = TradeSkills.savedVars and TradeSkills.savedVars.skinning.beastIndicatorPosition
    if savedPos then
        indicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedPos.x, savedPos.y)
    else
        indicator:SetAnchor(TOP, GuiRoot, TOP, 0, 85)
    end
    
    -- Save position on move
    indicator:SetHandler("OnMoveStop", function()
        local left, top = indicator:GetLeft(), indicator:GetTop()
        if TradeSkills.savedVars then
            TradeSkills.savedVars.skinning.beastIndicatorPosition = {x = left, y = top}
        end
    end)
    
    local bg = WINDOW_MANAGER:CreateControl(nil, indicator, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.3, 0.2, 0.1, 0.7)
    bg:SetEdgeColor(0.75, 0.55, 0.35, 0.8)
    bg:SetEdgeTexture("", 1, 1, 1, 0)
    self._beastIndicatorBg = bg
    
    -- Top line: creature name + "Drops Scraps"
    local label = WINDOW_MANAGER:CreateControl(nil, indicator, CT_LABEL)
    label:SetAnchor(TOPLEFT, indicator, TOPLEFT, 8, 4)
    label:SetAnchor(TOPRIGHT, indicator, TOPRIGHT, -8, 4)
    label:SetFont("ZoFontGameBold")
    label:SetColor(0.9, 0.7, 0.4, 1)
    label:SetText("")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self._beastIndicatorLabel = label
    
    -- Loot section (shown when Anatomy Specialist is also active)
    local lootLabel = WINDOW_MANAGER:CreateControl(nil, indicator, CT_LABEL)
    lootLabel:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, 4)
    lootLabel:SetAnchor(TOPRIGHT, label, BOTTOMRIGHT, 0, 4)
    lootLabel:SetFont("ZoFontGame")
    lootLabel:SetColor(0.8, 0.8, 0.8, 1)
    lootLabel:SetText("")
    lootLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    lootLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self._beastLootLabel = lootLabel
    
    self._beastIndicator = indicator
end

function TradeSkills.Skinning:ShowBeastIndicator(unitName)
    if not self._beastIndicator then
        self:CreateBeastIndicator()
    end
    local text = "|t16:16:TradeSkills/icons/skinning.dds|t " .. unitName .. " - Drops Scraps"
    self._beastIndicatorLabel:SetText(text)
    
    -- If Anatomy Specialist (Lv 30) is also active, show loot data in the same window
    local showLoot = self:HasPerk(30)
    if showLoot then
        local creatureKey = self:GetCreatureKey(unitName)
        local lootItems = creatureKey and self:GetLearnedLoot(creatureKey) or nil
        
        if lootItems then
            local lootText = "|cC8A060Known Drops:|r "
            local items = {}
            for _, item in ipairs(lootItems) do
                table.insert(items, item)
            end
            lootText = lootText .. table.concat(items, ", ")
            self._beastLootLabel:SetText(lootText)
        else
            self._beastLootLabel:SetText("|c808080No loot data yet - kill and loot to learn|r")
        end
        self._beastLootLabel:SetHidden(false)
        
        -- Resize window to fit both the indicator and loot text
        local lootHeight = self._beastLootLabel:GetTextHeight()
        local totalHeight = 24 + lootHeight + 12
        local textWidth = math.max(self._beastIndicatorLabel:GetTextWidth(), self._beastLootLabel:GetTextWidth())
        self._beastIndicator:SetDimensions(math.max(280, textWidth + 24), totalHeight)
    else
        self._beastLootLabel:SetText("")
        self._beastLootLabel:SetHidden(true)
        -- Beast Watch only - compact single-line size
        local textWidth = self._beastIndicatorLabel:GetTextWidth()
        self._beastIndicator:SetDimensions(math.max(200, textWidth + 30), 24)
    end
    
    self._beastIndicator:SetHidden(false)
end

function TradeSkills.Skinning:HideBeastIndicator()
    if self._beastIndicator then
        self._beastIndicator:SetHidden(true)
    end
end

-- =======================
-- SKINNING PERK: ANATOMY SPECIALIST (Level 30)
-- =======================
-- Shows a small window with valuable loot drops when targeting a scrap-dropping creature

-- Loot tables are learned dynamically from actual gameplay
-- When you loot a scrap creature, the addon records what dropped
-- This data persists in saved variables across sessions

-- Get the creature type key from a full creature name (e.g. "Savage Wolf" -> "wolf")
function TradeSkills.Skinning:GetCreatureKey(unitName)
    local lowerName = string.lower(unitName)
    for creature, _ in pairs(self.SCRAP_CREATURE_NAMES) do
        if self.MatchCreatureName(lowerName, creature) then
            return creature
        end
    end
    return nil
end

-- Record loot from a creature into saved vars
function TradeSkills.Skinning:RecordCreatureLoot(creatureKey, itemName)
    if not TradeSkills.savedVars then return end
    local db = TradeSkills.savedVars.skinning.creatureLoot
    if not db[creatureKey] then
        db[creatureKey] = {}
    end
    -- Check if we already know this drop
    for _, existing in ipairs(db[creatureKey]) do
        if existing == itemName then return end
    end
    table.insert(db[creatureKey], itemName)
end

-- Get learned loot for a creature type
function TradeSkills.Skinning:GetLearnedLoot(creatureKey)
    if not TradeSkills.savedVars then return nil end
    local db = TradeSkills.savedVars.skinning.creatureLoot
    if db[creatureKey] and #db[creatureKey] > 0 then
        return db[creatureKey]
    end
    return nil
end

-- Hook into loot events to learn what creatures drop
-- Exclude items we don't want: gear (equippable), potions, poisons, and scraps
-- Filter loot items by name - no item link needed
function TradeSkills.Skinning:ShouldRecordLootName(name, quality)
    if not name or name == "" then return false end
    
    -- Strip ESO formatting codes (^n, ^p, ^m, ^f, etc.)
    local cleanName = string.gsub(name, "%^%a", "")
    local lowerName = string.lower(cleanName)
    
    -- Exclude grey (trash) quality: quality from GetLootItemInfo is 0-based (0=trash,1=normal,2=fine...)
    if quality == ITEM_QUALITY_TRASH or quality == 0 then return false end
    
    -- Exclude potions & poisons
    if string.find(lowerName, "potion") then return false end
    if string.find(lowerName, "poison") then return false end
    -- Exclude scraps (already shown by Beast Watch)
    if string.find(lowerName, "scraps") then return false end
    if string.find(lowerName, "scrap") then return false end
    -- Exclude glyphs
    if string.find(lowerName, "glyph") then return false end
    -- Exclude gold/currency
    if string.find(lowerName, "gold") then return false end
    -- Exclude gear by common patterns
    if string.find(lowerName, "sword") then return false end
    if string.find(lowerName, "axe") then return false end
    if string.find(lowerName, "mace") then return false end
    if string.find(lowerName, "maul") then return false end
    if string.find(lowerName, "dagger") then return false end
    if string.find(lowerName, "greatsword") then return false end
    if string.find(lowerName, "battle axe") then return false end
    if string.find(lowerName, "staff") then return false end
    if string.find(lowerName, "bow") then return false end
    if string.find(lowerName, "shield") then return false end
    if string.find(lowerName, "helm") then return false end
    if string.find(lowerName, "jack") then return false end
    if string.find(lowerName, "robe") then return false end
    if string.find(lowerName, "guard") then return false end
    if string.find(lowerName, "boots") then return false end
    if string.find(lowerName, "gauntlet") then return false end
    if string.find(lowerName, "sabatons") then return false end
    if string.find(lowerName, "greaves") then return false end
    if string.find(lowerName, "pauldron") then return false end
    if string.find(lowerName, "cuirass") then return false end
    if string.find(lowerName, "girdle") then return false end
    if string.find(lowerName, "sash") then return false end
    if string.find(lowerName, "epaulet") then return false end
    if string.find(lowerName, "breeches") then return false end
    if string.find(lowerName, "shoes") then return false end
    if string.find(lowerName, "gloves") then return false end
    if string.find(lowerName, "hat") then return false end
    if string.find(lowerName, "arm cops") then return false end
    if string.find(lowerName, "bracers") then return false end
    if string.find(lowerName, "ring") then return false end
    if string.find(lowerName, "necklace") then return false end
    if string.find(lowerName, "amulet") then return false end
    
    return true
end

-- Called when loot window opens/updates - read items BEFORE they're taken
function TradeSkills.Skinning:OnLootUpdated()
    if not self:HasPerk(30) then return end
    
    local targetName, targetType, actionName, isOwned = GetLootTargetInfo()
    if not targetName or targetName == "" then return end
    
    local cleanName = zo_strformat("<<1>>", targetName)
    local creatureKey = self:GetCreatureKey(cleanName)
    if not creatureKey then return end
    
    if self._debugPerks then
        d("[TradeSkills] Loot window for creature: " .. creatureKey)
    end
    
    -- Read loot items NOW while the loot window is still populated
    local numItems = GetNumLootItems()
    for i = 1, numItems do
        local lootId, name, icon, count, quality, value, isQuest, stolen = GetLootItemInfo(i)
        if name and name ~= "" and not isQuest and not stolen then
            -- Clean the name of ESO formatting codes
            local cleanItemName = zo_strformat("<<1>>", name)
            if self:ShouldRecordLootName(cleanItemName, quality) then
                self:RecordCreatureLoot(creatureKey, cleanItemName)
                if self._debugPerks then
                    d("[TradeSkills] Learned: " .. cleanItemName .. " from " .. creatureKey)
                end
            elseif self._debugPerks then
                d("[TradeSkills] Filtered: " .. tostring(cleanItemName) .. " q=" .. tostring(quality))
            end
        end
    end
end

function TradeSkills.Skinning:CreateLootWindow()
    if self._lootWindow then return end
    
    local window = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkills_SkinLoot")
    window:SetDimensions(250, 200)
    window:SetHidden(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetDrawTier(DT_HIGH)
    
    -- Restore saved position
    local savedPos = TradeSkills.savedVars and TradeSkills.savedVars.skinning.lootWindowPosition
    if savedPos then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedPos.x, savedPos.y)
    else
        window:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -20, 400)
    end
    
    -- Save position on move
    window:SetHandler("OnMoveStop", function()
        local left, top = window:GetLeft(), window:GetTop()
        if TradeSkills.savedVars then
            TradeSkills.savedVars.skinning.lootWindowPosition = {x = left, y = top}
        end
    end)
    
    -- Background
    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.9)
    bg:SetEdgeColor(0.6, 0.45, 0.3, 0.8)
    bg:SetEdgeTexture("", 1, 1, 1, 0)
    
    -- Title
    local title = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    title:SetAnchor(TOP, window, TOP, 0, 8)
    title:SetFont("ZoFontWinH4")
    title:SetColor(0.75, 0.55, 0.35, 1)
    title:SetText("Creature Loot")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self._lootTitle = title
    
    -- Content
    local content = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    content:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 35)
    content:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -12, -8)
    content:SetFont("ZoFontGame")
    content:SetColor(0.8, 0.8, 0.8, 1)
    content:SetText("")
    content:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self._lootContent = content
    
    self._lootWindow = window
end

function TradeSkills.Skinning:ShowLootWindow(unitName)
    if not self:HasPerk(30) then return end
    if not self._lootWindow then
        self:CreateLootWindow()
    end
    
    local creatureKey = self:GetCreatureKey(unitName)
    local lootItems = creatureKey and self:GetLearnedLoot(creatureKey) or nil
    
    self._lootTitle:SetText(unitName)
    
    local text = ""
    if lootItems then
        text = "|cC8A060Known Drops:|r\n"
        for _, item in ipairs(lootItems) do
            text = text .. "  • " .. item .. "\n"
        end
    else
        text = "|c808080No loot data yet.\nKill and loot this creature\nto learn its drops.|r"
    end
    
    self._lootContent:SetText(text)
    self._lootWindow:SetHidden(false)
end

function TradeSkills.Skinning:HideLootWindow()
    if self._lootWindow then
        self._lootWindow:SetHidden(true)
    end
end

-- =======================
-- SKINNING PERK: HERD MAP (Level 50)
-- =======================
-- Places pins on the world map for areas with high enemy density for scrap farming
-- Uses custom map pins via LibMapPins or manual pins

-- Known high-density scrap farming locations per zone
-- Player-placed herd pins stored in account-wide saved vars per zone

function TradeSkills.Skinning:GetHerdLocationsForZone()
    if not self:HasPerk(50) then return nil end
    if not TradeSkills.accountVars then return nil end
    
    -- Get the map currently being viewed (not necessarily the player's zone)
    local currentMapId = GetCurrentMapId()
    if not currentMapId then return nil end
    
    local pins = TradeSkills.accountVars.herdPins[currentMapId]
    if pins and #pins > 0 then
        return pins
    end
    return nil
end

-- Add a pin at the player's current map position
function TradeSkills.Skinning:AddHerdPin(label)
    if not self:HasPerk(50) then
        return
    end
    if not TradeSkills.accountVars then return end
    
    -- Store pin keyed by the current map ID so it only shows on this map
    local mapId = GetCurrentMapId()
    local x, y = GetMapPlayerPosition("player")
    
    if not label or label == "" then
        local zoneName = zo_strformat("<<1>>", GetUnitZone("player"))
        label = zoneName .. " - Scrap Farming"
    end
    
    if not TradeSkills.accountVars.herdPins[mapId] then
        TradeSkills.accountVars.herdPins[mapId] = {}
    end
    
    table.insert(TradeSkills.accountVars.herdPins[mapId], {x, y, label})
    
    self:RefreshHerdPins()
end

-- Remove the nearest herd pin to the player
function TradeSkills.Skinning:RemoveNearestHerdPin()
    if not self:HasPerk(50) then
        return
    end
    if not TradeSkills.accountVars then return end
    local mapId = GetCurrentMapId()
    local pins = TradeSkills.accountVars.herdPins[mapId]
    if not pins or #pins == 0 then
        return
    end
    
    local px, py = GetMapPlayerPosition("player")
    local closestIdx = 1
    local closestDist = math.huge
    
    for i, pin in ipairs(pins) do
        local dx = pin[1] - px
        local dy = pin[2] - py
        local dist = dx * dx + dy * dy
        if dist < closestDist then
            closestDist = dist
            closestIdx = i
        end
    end
    
    local removed = table.remove(pins, closestIdx)
    
    self:RefreshHerdPins()
end

-- Clear all herd pins
function TradeSkills.Skinning:ClearAllHerdPins()
    if not TradeSkills.accountVars then return end
    TradeSkills.accountVars.herdPins = {}
    self:RefreshHerdPins()
end

function TradeSkills.Skinning:InitHerdMapPins()
    local LMP = LibMapPins
    if not LMP then
        return
    end
    
    local pinTypeString = "TradeSkills_HerdMapPin"
    
    local pinLayoutData = {
        level = 200,
        texture = "TradeSkills/icons/herd_map_pin.dds",
        size = 32,
        minSize = 20,
    }
    
    local pinTooltipCreator = {
        creator = function(pin)
            local pinTag = pin.m_PinTag
            if pinTag and pinTag.label then
                InformationTooltip:AddLine(pinTag.label)
                InformationTooltip:AddLine("Skinning: High scrap density area", "", ZO_ColorDef:New(0.7, 0.55, 0.35, 1):UnpackRGBA())
            end
        end,
        tooltip = InformationTooltip,
    }
    
    local function pinTypeAddCallback(pinManager)
        if not TradeSkills.Skinning:HasPerk(50) then return end
        local locations = TradeSkills.Skinning:GetHerdLocationsForZone()
        if not locations then return end
        
        for _, loc in ipairs(locations) do
            local pinInfo = { label = loc[3] }
            LMP:CreatePin(pinTypeString, pinInfo, loc[1], loc[2])
        end
    end
    
    LMP:AddPinType(pinTypeString, pinTypeAddCallback, nil, pinLayoutData, pinTooltipCreator)
    LMP:AddPinFilter(pinTypeString, "Skinning: Herd Locations")
    
    self._herdPinType = pinTypeString
    self._herdPinsInitialized = true
end

function TradeSkills.Skinning:RefreshHerdPins()
    if not self:HasPerk(50) then return end
    if not self._herdPinsInitialized then return end
    
    local LMP = LibMapPins
    if LMP and self._herdPinType then
        LMP:RefreshPins(self._herdPinType)
    end
end

-- Track reticle target for Anatomy Specialist
function TradeSkills.Skinning:OnReticleTargetChanged()
    if not self:HasPerk(30) then return end
    
    -- If Beast Watch (Lv 10) is also active, the combined window handles loot display
    -- Only show the separate loot window if Beast Watch is NOT active
    if self:HasPerk(10) then return end
    
    local unitTag = "reticleover"
    if DoesUnitExist(unitTag) and not IsUnitDead(unitTag) then
        local rawName = GetUnitName(unitTag)
        if rawName and rawName ~= "" then
            local unitName = zo_strformat("<<1>>", rawName)
            local reaction = GetUnitReaction(unitTag)
            
            -- Only show for hostile/neutral non-player units
            if (reaction == UNIT_REACTION_HOSTILE or reaction == UNIT_REACTION_NEUTRAL or reaction == UNIT_REACTION_NPC_ALLY)
               and not IsUnitPlayer(unitTag) then
                -- Check if this is a known scrap creature
                if self:GetCreatureKey(unitName) then
                    self:ShowLootWindow(unitName)
                    return
                end
            end
        end
    end
    self:HideLootWindow()
end

-- =======================
-- TRAIT SCANNING FUNCTION (FIXED USING CRAFTSTORE METHOD)
-- =======================
function TradeSkills.ScanTraits()
    -- Async trait scan: spreads across frames
    local BATCH_SIZE = 30  -- trait checks per frame
    
    local craftingTypes = {
        CRAFTING_TYPE_BLACKSMITHING,
        CRAFTING_TYPE_CLOTHIER, 
        CRAFTING_TYPE_WOODWORKING,
        CRAFTING_TYPE_JEWELRYCRAFTING
    }
    
    local traitCount = 0
    local craftIdx = 1
    local lineIdx = 1
    local traitIdx = 1
    local numLines = GetNumSmithingResearchLines(craftingTypes[1]) or 0
    
    local pollName = TradeSkills.name .. "_TRAITSCAN"
    EVENT_MANAGER:UnregisterForUpdate(pollName)
    
    EVENT_MANAGER:RegisterForUpdate(pollName, 1, function()
        local processed = 0
        
        while processed < BATCH_SIZE and craftIdx <= #craftingTypes do
            local craftingType = craftingTypes[craftIdx]
            
            if lineIdx <= numLines then
                if traitIdx <= 9 then
                    local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingType, lineIdx, traitIdx)
                    if traitType and traitType ~= 0 and known == true then
                        traitCount = traitCount + 1
                    end
                    traitIdx = traitIdx + 1
                    processed = processed + 1
                else
                    traitIdx = 1
                    lineIdx = lineIdx + 1
                end
            else
                craftIdx = craftIdx + 1
                lineIdx = 1
                traitIdx = 1
                if craftIdx <= #craftingTypes then
                    numLines = GetNumSmithingResearchLines(craftingTypes[craftIdx]) or 0
                end
            end
        end
        
        if craftIdx > #craftingTypes then
            EVENT_MANAGER:UnregisterForUpdate(pollName)
            -- Only update when scan is complete - old value stays visible until now
            TradeSkills.savedVars.traitmastery.knownTraits = traitCount
            TradeSkills.CheckLevelUps()
            TradeSkills.UpdateWindow()
        end
    end)
end

-- =======================
-- ESO-STYLE UI CREATION
-- =======================
function TradeSkills.CreateWindow()
    -- Register skill modules
    TradeSkills.skills = {
        TradeSkills.Carpentry,
        TradeSkills.Cooking,
        TradeSkills.Brewing,
        TradeSkills.StyleMastery,
        TradeSkills.TraitMastery,
        TradeSkills.Fishing,
        TradeSkills.Mining,
        TradeSkills.Herbalism,
        TradeSkills.Woodcutting,
        TradeSkills.Skinning
    }
    
    -- Main window with ESO dimensions and style
    local window = WINDOW_MANAGER:CreateTopLevelWindow("TradeSkillsWindow")
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TradeSkills.savedVars.windowPosition.x, TradeSkills.savedVars.windowPosition.y)
    window:SetDimensions(800, 900)
    window:SetHidden(true)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)

    window:SetHandler("OnMoveStop", function()
        local left, top = window:GetLeft(), window:GetTop()
        TradeSkills.savedVars.windowPosition.x = left
        TradeSkills.savedVars.windowPosition.y = top
    end)

    -- Main background with ESO styling
    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.95)
    bg:SetEdgeColor(0.4, 0.35, 0.25, 1)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)

    -- Left panel for skill categories
    local leftPanel = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    leftPanel:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 10)
    leftPanel:SetDimensions(220, 880)
    leftPanel:SetCenterColor(0.08, 0.08, 0.08, 0.9)
    leftPanel:SetEdgeColor(0.3, 0.25, 0.18, 0.8)
    leftPanel:SetEdgeTexture("EsoUI/Art/Miscellaneous/scrollbox_edge.dds", 32, 4)

    -- Left panel header (ESO-style: icon + text + gold divider)
    local headerContainer = WINDOW_MANAGER:CreateControl(nil, leftPanel, CT_CONTROL)
    headerContainer:SetAnchor(TOPLEFT, leftPanel, TOPLEFT, 10, 12)
    headerContainer:SetDimensions(200, 35)
    
    -- Small crossed hammers icon
    local headerIcon = WINDOW_MANAGER:CreateControl(nil, headerContainer, CT_TEXTURE)
    headerIcon:SetDimensions(32, 32)
    headerIcon:SetAnchor(LEFT, headerContainer, LEFT, 0, 0)
    headerIcon:SetTexture("TradeSkills/icons/ts_header.dds")
    
    -- "TRADE SKILLS" text
    local headerText = WINDOW_MANAGER:CreateControl(nil, headerContainer, CT_LABEL)
    headerText:SetAnchor(LEFT, headerIcon, RIGHT, 8, 0)
    headerText:SetFont("ZoFontWinH4")
    headerText:SetText("TRADE SKILLS")
    headerText:SetColor(0.7, 0.65, 0.5, 1)
    
    -- Gold divider line underneath
    local headerDivider = WINDOW_MANAGER:CreateControl(nil, leftPanel, CT_TEXTURE)
    headerDivider:SetAnchor(TOPLEFT, headerContainer, BOTTOMLEFT, -5, 5)
    headerDivider:SetAnchor(TOPRIGHT, leftPanel, TOPRIGHT, -10, 52)
    headerDivider:SetHeight(2)
    headerDivider:SetColor(0.55, 0.48, 0.3, 0.8)

    -- Right panel for skill details
    local rightPanel = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    rightPanel:SetAnchor(TOPRIGHT, window, TOPRIGHT, -10, 10)
    rightPanel:SetDimensions(550, 880)
    rightPanel:SetCenterColor(0.06, 0.06, 0.06, 0.9)
    rightPanel:SetEdgeColor(0.25, 0.22, 0.16, 0.8)
    rightPanel:SetEdgeTexture("EsoUI/Art/Miscellaneous/scrollbox_edge.dds", 32, 4)

    -- Create skill category buttons
    TradeSkills.skillButtons = {}
    local buttonHeight = 55
    local buttonSpacing = 5
    
    for i, skill in ipairs(TradeSkills.skills) do
        local button = WINDOW_MANAGER:CreateControl(nil, leftPanel, CT_BUTTON)
        button:SetDimensions(200, buttonHeight)
        button:SetAnchor(TOPLEFT, leftPanel, TOPLEFT, 10, 60 + (i-1) * (buttonHeight + buttonSpacing))
        
        -- Button background
        local buttonBg = WINDOW_MANAGER:CreateControl(nil, button, CT_BACKDROP)
        buttonBg:SetAnchorFill()
        buttonBg:SetCenterColor(0.12, 0.12, 0.12, 0.8)
        buttonBg:SetEdgeColor(0.25, 0.22, 0.16, 0.6)
        button.bg = buttonBg
        
        -- Button icon
        local icon = WINDOW_MANAGER:CreateControl(nil, button, CT_TEXTURE)
        icon:SetDimensions(32, 32)
        icon:SetAnchor(LEFT, button, LEFT, 10, 0)
        icon:SetTexture(skill.icon)
        
        -- Button text
        local text = WINDOW_MANAGER:CreateControl(nil, button, CT_LABEL)
        text:SetAnchor(LEFT, icon, RIGHT, 10, -5)
        text:SetFont("ZoFontGame")
        text:SetText(skill.name)
        text:SetColor(0.85, 0.85, 0.85, 1)
        
        -- Level indicator
        local levelText = WINDOW_MANAGER:CreateControl(nil, button, CT_LABEL)
        levelText:SetAnchor(LEFT, icon, RIGHT, 10, 10)
        levelText:SetFont("ZoFontGameSmall")
        levelText:SetText("Level 0")
        levelText:SetColor(0.7, 0.7, 0.7, 1)
        
        button.text = text
        button.levelText = levelText
        
        button:SetHandler("OnClicked", function()
            TradeSkills.SelectTab(i)
        end)
        
        button:SetHandler("OnMouseEnter", function()
            if TradeSkills.activeTab ~= i then
                buttonBg:SetCenterColor(0.18, 0.18, 0.18, 0.9)
            end
        end)
        
        button:SetHandler("OnMouseExit", function()
            if TradeSkills.activeTab ~= i then
                buttonBg:SetCenterColor(0.12, 0.12, 0.12, 0.8)
            end
        end)
        
        TradeSkills.skillButtons[i] = button
    end

    -- Right panel content
    local skillNameLabel = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    skillNameLabel:SetAnchor(TOPLEFT, rightPanel, TOPLEFT, 20, 20)
    skillNameLabel:SetFont("ZoFontWinH1")
    skillNameLabel:SetText("Select a Skill")
    skillNameLabel:SetColor(0.9, 0.8, 0.6, 1)

    local skillLevelLabel = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    skillLevelLabel:SetAnchor(TOPRIGHT, rightPanel, TOPRIGHT, -20, 20)
    skillLevelLabel:SetFont("ZoFontWinH1")
    skillLevelLabel:SetText("")
    skillLevelLabel:SetColor(1, 0.84, 0, 1)

    local largeIcon = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_TEXTURE)
    largeIcon:SetDimensions(64, 64)
    largeIcon:SetAnchor(TOPLEFT, skillNameLabel, BOTTOMLEFT, 0, 15)

    local xpContainer = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_CONTROL)
    xpContainer:SetAnchor(TOPLEFT, largeIcon, BOTTOMLEFT, 0, 20)
    xpContainer:SetDimensions(500, 30)

    local xpBg = WINDOW_MANAGER:CreateControl(nil, xpContainer, CT_BACKDROP)
    xpBg:SetAnchorFill()
    xpBg:SetCenterColor(0.1, 0.1, 0.1, 0.8)
    xpBg:SetEdgeColor(0.3, 0.25, 0.18, 0.8)

    local xpBar = WINDOW_MANAGER:CreateControl(nil, xpBg, CT_STATUSBAR)
    xpBar:SetAnchor(TOPLEFT, xpBg, TOPLEFT, 2, 2)
    xpBar:SetAnchor(BOTTOMRIGHT, xpBg, BOTTOMRIGHT, -2, -2)
    xpBar:SetMinMax(0, 100)
    xpBar:SetValue(0)

    local xpText = WINDOW_MANAGER:CreateControl(nil, xpContainer, CT_LABEL)
    xpText:SetFont("ZoFontGameBold")
    xpText:SetColor(1, 1, 1, 1)
    xpText:SetAnchor(CENTER, xpContainer, CENTER, 0, 0)
    xpText:SetText("0 / 10")

    local totalLabel = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    totalLabel:SetAnchor(TOPLEFT, xpContainer, BOTTOMLEFT, 0, 25)
    totalLabel:SetFont("ZoFontGame")
    totalLabel:SetColor(0.8, 0.8, 0.8, 1)
    totalLabel:SetText("")

    local rankLabel = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    rankLabel:SetAnchor(TOPLEFT, totalLabel, BOTTOMLEFT, 0, 10)
    rankLabel:SetFont("ZoFontWinH4")
    rankLabel:SetText("")

    local divider = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_TEXTURE)
    divider:SetTexture("/esoui/art/miscellaneous/horizontaldivider.dds")
    divider:SetAnchor(TOPLEFT, rankLabel, BOTTOMLEFT, 0, 15)
    divider:SetDimensions(500, 2)

    local descHeader = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    descHeader:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, 10)
    descHeader:SetFont("ZoFontGame")
    descHeader:SetColor(0.8, 0.8, 0.5, 1)
    descHeader:SetText("How to Level")

    local descText = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    descText:SetAnchor(TOPLEFT, descHeader, BOTTOMLEFT, 0, 5)
    descText:SetFont("ZoFontGame")
    descText:SetColor(0.7, 0.7, 0.7, 1)
    descText:SetDimensions(500, 160)
    descText:SetText("")

    -- Passive Abilities section (like ESO's PASSIVE ABILITIES in skill menu)
    local passiveDivider = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_TEXTURE)
    passiveDivider:SetTexture("/esoui/art/miscellaneous/horizontaldivider.dds")
    passiveDivider:SetAnchor(TOPLEFT, descText, BOTTOMLEFT, 0, 10)
    passiveDivider:SetDimensions(500, 2)
    
    local passiveHeader = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    passiveHeader:SetAnchor(TOPLEFT, passiveDivider, BOTTOMLEFT, 0, 10)
    passiveHeader:SetFont("ZoFontWinH4")
    passiveHeader:SetText("PASSIVE ABILITIES")
    passiveHeader:SetColor(0.9, 0.8, 0.6, 1)
    
    -- Container for passive ability rows
    local passiveContainer = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_CONTROL)
    passiveContainer:SetAnchor(TOPLEFT, passiveHeader, BOTTOMLEFT, 0, 10)
    passiveContainer:SetDimensions(500, 250)

    -- Store references
    TradeSkills.window = window
    TradeSkills.skillNameLabel = skillNameLabel
    TradeSkills.skillLevelLabel = skillLevelLabel
    TradeSkills.largeIcon = largeIcon
    TradeSkills.xpBar = xpBar
    TradeSkills.xpText = xpText
    TradeSkills.totalLabel = totalLabel
    TradeSkills.rankLabel = rankLabel
    TradeSkills.descText = descText
    TradeSkills.passiveDivider = passiveDivider
    TradeSkills.passiveHeader = passiveHeader
    TradeSkills.passiveContainer = passiveContainer
    TradeSkills.passiveRows = {}

    -- Hook into skills scene (keyboard mode)
    local skillsScene = SCENE_MANAGER:GetScene("skills")
    if skillsScene then
        skillsScene:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING then
                TradeSkills.UpdateWindow()
                TradeSkills.window:SetHidden(false)
                -- Async scans: will update window again when complete
                TradeSkills.ScanRecipes()
                TradeSkills.ScanTraits()
            elseif newState == SCENE_HIDDEN then
                TradeSkills.window:SetHidden(true)
            end
        end)
    end
    
    -- Hook into skills scene (gamepad mode)
    local gamepadSkillScenes = { "gamepad_skills_root", "gamepad_skills", "gamepadSkills" }
    for _, sceneName in ipairs(gamepadSkillScenes) do
        local gpScene = SCENE_MANAGER:GetScene(sceneName)
        if gpScene then
            gpScene:RegisterCallback("StateChange", function(_, newState)
                if newState == SCENE_SHOWING then
                    TradeSkills.UpdateWindow()
                    TradeSkills.window:SetHidden(false)
                    TradeSkills.ScanRecipes()
                    TradeSkills.ScanTraits()
                elseif newState == SCENE_HIDDEN then
                    TradeSkills.window:SetHidden(true)
                end
            end)
            break
        end
    end
end

function TradeSkills.SelectTab(tabIndex)
    TradeSkills.activeTab = tabIndex
    TradeSkills.savedVars.activeTab = tabIndex
    
    -- Update button appearance
    for i, button in ipairs(TradeSkills.skillButtons) do
        if i == tabIndex then
            button.bg:SetCenterColor(0.2, 0.18, 0.12, 0.95)
            button.bg:SetEdgeColor(0.4, 0.35, 0.25, 0.9)
            button.text:SetColor(1, 0.9, 0.7, 1)
        else
            button.bg:SetCenterColor(0.12, 0.12, 0.12, 0.8)
            button.bg:SetEdgeColor(0.25, 0.22, 0.16, 0.6)
            button.text:SetColor(0.85, 0.85, 0.85, 1)
        end
    end
    
    TradeSkills.UpdateWindow()
end

function TradeSkills.UpdateWindow()
    if not TradeSkills.window then return end
    
    local skill = TradeSkills.skills[TradeSkills.activeTab]
    if not skill then return end
    
    -- Update button level displays
    for i, button in ipairs(TradeSkills.skillButtons) do
        local s = TradeSkills.skills[i]
        local level = s:GetLevel()
        button.levelText:SetText("Level " .. level)
        if level >= s.MAX_LEVEL then
            button.levelText:SetColor(1, 0.84, 0, 1)
        else
            button.levelText:SetColor(0.7, 0.7, 0.7, 1)
        end
    end
    
    -- Update main panel
    TradeSkills.skillNameLabel:SetText(skill.name)
    TradeSkills.skillNameLabel:SetColor(unpack(skill.color))
    
    -- Update large icon
    TradeSkills.largeIcon:SetTexture(skill.icon)
    
    -- Update level display
    local level = skill:GetLevel()
    if level >= skill.MAX_LEVEL then
        TradeSkills.skillLevelLabel:SetText(string.format("%d", level))
        TradeSkills.skillLevelLabel:SetColor(1, 0.84, 0, 1)
    else
        TradeSkills.skillLevelLabel:SetText(string.format("%d", level))
        TradeSkills.skillLevelLabel:SetColor(unpack(skill.color))
    end
    
    -- Update XP bar
    local current, max = skill:GetProgress()
    local percent = (current / max) * 100
    TradeSkills.xpBar:SetValue(percent)
    TradeSkills.xpBar:SetColor(unpack(skill.color))
    
    if level >= skill.MAX_LEVEL then
        TradeSkills.xpText:SetText("MAXED")
    else
        TradeSkills.xpText:SetText(string.format("%d / %d", current, max))
    end
    
    -- Update total counter
    local countText = ""
    if skill == TradeSkills.Carpentry then
        countText = "Furniture Recipes Known: " .. skill:GetCount()
    elseif skill == TradeSkills.Cooking then
        countText = "Food Recipes Known: " .. skill:GetCount()
    elseif skill == TradeSkills.Brewing then
        countText = "Drink Recipes Known: " .. skill:GetCount()
    elseif skill == TradeSkills.StyleMastery then
        countText = "Motif Pages Known: " .. skill:GetCount()
    elseif skill == TradeSkills.TraitMastery then
        countText = "Traits Researched: " .. skill:GetCount()
    elseif skill == TradeSkills.Fishing then
        countText = "Total Fish Caught: " .. skill:GetCount()
    elseif skill == TradeSkills.Skinning then
        countText = "Raw Scraps Looted: " .. skill:GetCount()
    elseif skill == TradeSkills.Mining then
        countText = "Ore Nodes Mined: " .. skill:GetCount()
    elseif skill == TradeSkills.Herbalism then
        countText = "Plant Nodes Gathered: " .. skill:GetCount()
    elseif skill == TradeSkills.Woodcutting then
        countText = "Wood Nodes Harvested: " .. skill:GetCount()
    end
    TradeSkills.totalLabel:SetText(countText)
    
    -- Update rank display
    if skill.GetRank then
        local rank = skill:GetRank()
        TradeSkills.rankLabel:SetText(string.format("Rank: %s", rank.name))
        TradeSkills.rankLabel:SetColor(unpack(rank.color))
    else
        TradeSkills.rankLabel:SetText("")
    end
    
    -- Update description
    TradeSkills.descText:SetText(skill:GetDescription())
    
    -- Update passive abilities section
    TradeSkills.UpdatePassiveAbilities(skill)
end

-- =======================
-- PERK TOGGLE SYSTEM
-- =======================
-- Allows players to enable/disable unlocked passive abilities by clicking their icon

function TradeSkills.GetPerkKey(skillName, perkLevel)
    return skillName .. "_" .. tostring(perkLevel)
end

function TradeSkills.IsPerkDisabled(skillName, perkLevel)
    if not TradeSkills.savedVars then return false end
    if not TradeSkills.savedVars.disabledPerks then return false end
    local key = TradeSkills.GetPerkKey(skillName, perkLevel)
    return TradeSkills.savedVars.disabledPerks[key] == true
end

function TradeSkills.TogglePerk(skillName, perkLevel)
    if not TradeSkills.savedVars then return end
    if not TradeSkills.savedVars.disabledPerks then
        TradeSkills.savedVars.disabledPerks = {}
    end
    local key = TradeSkills.GetPerkKey(skillName, perkLevel)
    if TradeSkills.savedVars.disabledPerks[key] then
        TradeSkills.savedVars.disabledPerks[key] = nil
    else
        TradeSkills.savedVars.disabledPerks[key] = true
    end
end

function TradeSkills.UpdatePassiveAbilities(skill)
    -- Hide all existing passive rows
    for _, row in ipairs(TradeSkills.passiveRows) do
        row:SetHidden(true)
    end
    
    -- Show/hide passive section based on whether skill has passives
    local hasPassives = skill.passiveAbilities and #skill.passiveAbilities > 0
    TradeSkills.passiveDivider:SetHidden(not hasPassives)
    TradeSkills.passiveHeader:SetHidden(not hasPassives)
    TradeSkills.passiveContainer:SetHidden(not hasPassives)
    
    if not hasPassives then return end
    
    local level = skill:GetLevel()
    if skill._debugPerks then level = 999 end
    
    for i, passive in ipairs(skill.passiveAbilities) do
        local row = TradeSkills.passiveRows[i]
        
        if not row then
            -- Create passive ability row (icon + name + description)
            row = WINDOW_MANAGER:CreateControl(nil, TradeSkills.passiveContainer, CT_CONTROL)
            row:SetDimensions(500, 56)
            row:SetMouseEnabled(true)
            
            -- Icon (like ESO passive ability icons)
            local icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
            icon:SetDimensions(48, 48)
            icon:SetAnchor(LEFT, row, LEFT, 5, 0)
            icon:SetMouseEnabled(true)
            row.icon = icon
            
            -- Ability name + rank on top line
            local nameLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
            nameLabel:SetAnchor(TOPLEFT, icon, TOPRIGHT, 12, 2)
            nameLabel:SetFont("ZoFontGame")
            row.nameLabel = nameLabel
            
            -- Rank text next to name (e.g. "(1 / 1)")
            local rankText = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
            rankText:SetAnchor(LEFT, nameLabel, RIGHT, 5, 0)
            rankText:SetFont("ZoFontGame")
            row.rankText = rankText
            
            -- Description on bottom line
            local descLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
            descLabel:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, 0, 2)
            descLabel:SetFont("ZoFontGameSmall")
            descLabel:SetDimensions(420, 40)
            row.descLabel = descLabel
            
            TradeSkills.passiveRows[i] = row
        end
        
        -- Position the row
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, TradeSkills.passiveContainer, TOPLEFT, 0, (i - 1) * 60)
        row:SetHidden(false)
        
        -- Set icon texture
        row.icon:SetTexture(passive.icon)
        
        -- Determine unlock state
        local unlocked = level >= passive.level
        local disabled = TradeSkills.IsPerkDisabled(skill.name, passive.level)
        
        if unlocked then
            -- Set up click handler on the whole row to toggle perk on/off
            row:SetHandler("OnMouseUp", function(control, button)
                if button == MOUSE_BUTTON_INDEX_LEFT then
                    TradeSkills.TogglePerk(skill.name, passive.level)
                    TradeSkills.UpdatePassiveAbilities(skill)
                    PlaySound(SOUNDS.DEFAULT_CLICK)
                end
            end)
            
            if not disabled then
                -- Unlocked and enabled: bright icon and text
                row.icon:SetDesaturation(0)
                row.icon:SetAlpha(1)
                row.nameLabel:SetText(passive.name)
                row.nameLabel:SetColor(0.9, 0.9, 0.9, 1)
                row.rankText:SetText("(1 / 1)")
                row.rankText:SetColor(0.9, 0.9, 0.9, 1)
                row.descLabel:SetText(passive.description)
                row.descLabel:SetColor(0.6, 0.6, 0.6, 1)
            else
                -- Unlocked but disabled: desaturated with "Disabled" label
                row.icon:SetDesaturation(1)
                row.icon:SetAlpha(0.6)
                row.nameLabel:SetText(passive.name)
                row.nameLabel:SetColor(0.6, 0.5, 0.5, 1)
                row.rankText:SetText("|cFF4444(Disabled)|r")
                row.rankText:SetColor(0.8, 0.3, 0.3, 1)
                row.descLabel:SetText(passive.description)
                row.descLabel:SetColor(0.4, 0.4, 0.4, 1)
            end
        else
            -- Locked: dimmed icon, no click handler
            row:SetHandler("OnMouseUp", nil)
            row.icon:SetDesaturation(1)
            row.icon:SetAlpha(0.4)
            row.nameLabel:SetText(passive.name)
            row.nameLabel:SetColor(0.4, 0.4, 0.4, 1)
            row.rankText:SetText(string.format("(Lv %d)", passive.level))
            row.rankText:SetColor(0.4, 0.4, 0.4, 1)
            row.descLabel:SetText(passive.description)
            row.descLabel:SetColor(0.3, 0.3, 0.3, 1)
        end
    end
end

-- =======================
-- RECIPE SCANNING
-- =======================
function TradeSkills.ScanRecipes()
    -- Async recipe scan: spreads work across multiple frames to prevent freezing
    -- Build into temp tables so existing counts stay visible until scan completes
    local BATCH_SIZE = 20  -- recipes per frame
    
    local tempCarpentry = {}
    local tempCooking = {}
    local tempBrewing = {}
    
    local numLists = GetNumRecipeLists()
    local listIndex = 1
    local recipeIndex = 1
    local numRecipesInList = 0
    local listName = ""
    
    -- Get first list info
    if numLists > 0 then
        listName, numRecipesInList = GetRecipeListInfo(1)
    end
    
    local pollName = TradeSkills.name .. "_RECIPESCAN"
    EVENT_MANAGER:UnregisterForUpdate(pollName)
    
    EVENT_MANAGER:RegisterForUpdate(pollName, 1, function()
        local processed = 0
        
        while processed < BATCH_SIZE and listIndex <= numLists do
            if recipeIndex <= numRecipesInList then
                local known, recipeName = GetRecipeInfo(listIndex, recipeIndex)
                
                if known then
                    local resultLink = GetRecipeResultItemLink(listIndex, recipeIndex)
                    if resultLink and resultLink ~= "" then
                        local itemType = GetItemLinkItemType(resultLink)
                        local key = string.format("%d_%d", listIndex, recipeIndex)
                        
                        if itemType == ITEMTYPE_FURNISHING then
                            tempCarpentry[key] = true
                        elseif itemType == ITEMTYPE_FOOD then
                            tempCooking[key] = true
                        elseif itemType == ITEMTYPE_DRINK then
                            tempBrewing[key] = true
                        end
                    end
                end
                
                recipeIndex = recipeIndex + 1
                processed = processed + 1
            else
                -- Move to next list
                listIndex = listIndex + 1
                recipeIndex = 1
                if listIndex <= numLists then
                    listName, numRecipesInList = GetRecipeListInfo(listIndex)
                end
            end
        end
        
        -- Done scanning
        if listIndex > numLists then
            EVENT_MANAGER:UnregisterForUpdate(pollName)
            
            -- Swap in new data (old counts were visible until now)
            TradeSkills.savedVars.carpentry.knownRecipes = tempCarpentry
            TradeSkills.savedVars.cooking.knownRecipes = tempCooking
            TradeSkills.savedVars.brewing.knownRecipes = tempBrewing
            
            -- Update counts from the scanned data
            local carpCount = 0
            for _ in pairs(tempCarpentry) do carpCount = carpCount + 1 end
            TradeSkills.savedVars.carpentry.knownCount = carpCount
            
            local cookCount = 0
            for _ in pairs(tempCooking) do cookCount = cookCount + 1 end
            TradeSkills.savedVars.cooking.knownCount = cookCount
            
            local brewCount = 0
            for _ in pairs(tempBrewing) do brewCount = brewCount + 1 end
            TradeSkills.savedVars.brewing.knownCount = brewCount
            
            TradeSkills.CheckLevelUps()
            TradeSkills.UpdateWindow()
        end
    end)
end

-- =======================
-- FISHING TRACKING
-- =======================

-- Helper function to check if we're currently looting from a container (not gathering)
local function IsLootingContainer()
    -- Check if loot window is open (indicates container/corpse looting)
    if LOOT_SCENE and LOOT_SCENE:IsShowing() then
        return true
    end
    
    -- Check interaction type - INTERACTION_HARVEST is for gathering nodes
    local interactionType = GetInteractionType()
    
    -- These interaction types indicate we're NOT gathering from a node:
    -- INTERACTION_NONE = 0 (no interaction, likely from mail/bank/container)
    -- INTERACTION_LOOT = 2 (looting a container or corpse)
    -- INTERACTION_BANK = 4 (using bank)
    -- INTERACTION_VENDOR = 5 (vendor)
    -- INTERACTION_MAIL = 13 (mailbox)
    -- INTERACTION_HARVEST = 14 (gathering from node - this is what we WANT)
    
    -- Only count materials if we're harvesting (interactionType == 14)
    -- or if there's no interaction (which can happen with quick node gathering)
    if interactionType == INTERACTION_LOOT then
        return true
    end
    
    return false
end

local function OnInventoryUpdate(eventCode, bagId, slotId, isNewItem)
    if not isNewItem then return end
    if bagId ~= BAG_BACKPACK and bagId ~= BAG_VIRTUAL then return end

    local itemLink = GetItemLink(bagId, slotId)
    if not itemLink then return end

    local itemName = GetItemLinkName(itemLink)
    if not itemName then return end

    -- Get item type to filter items properly
    local itemType = GetItemLinkItemType(itemLink)
    local specializedItemType = GetItemLinkItemUseType(itemLink)
    local itemQuality = GetItemLinkQuality(itemLink)
    local lowerName = string.lower(itemName)  -- Define this early so it's available everywhere
    
    -- === FISHING DETECTION ===
    -- Fish are Type 54 (discovered from debug output)
    local isFish = false
    
    if itemType == 54 then
        isFish = true
    end
    
    if isFish then
        -- Skip if we're looting from a container (not actually fishing)
        if IsLootingContainer() then
            if TradeSkills.debug then
                d(string.format("[Fishing Debug] '%s' ignored - looting from container, not fishing", itemName))
            end
            return
        end
        
        TradeSkills.savedVars.fishing.totalFishCaught = TradeSkills.savedVars.fishing.totalFishCaught + 1
        
        -- Check for level up
        local skill = TradeSkills.Fishing
        local currentLevel = skill:GetLevel()
        if currentLevel > TradeSkills.savedVars.fishing.lastNotifiedLevel then
            TradeSkills.AnnounceLevelUp("Fishing", currentLevel, "33A5F2")
            TradeSkills.savedVars.fishing.lastNotifiedLevel = currentLevel
        end
        
        TradeSkills.UpdateWindow()
        return
    end
    
    -- === MINING DETECTION ===
    -- WHITELIST ONLY - specific ores and dusts from nodes/seams
    local isMiningMaterial = false
    
    -- Whitelist of ore names
    local miningWhitelist = {
        -- Raw Ores (Type 10)
        ["iron ore"] = true,
        ["high iron ore"] = true,
        ["orichalcum ore"] = true,
        ["dwarven ore"] = true,
        ["ebony ore"] = true,
        ["calcinium ore"] = true,
        ["galatite ore"] = true,
        ["quicksilver ore"] = true,
        ["voidstone ore"] = true,
        ["rubedite ore"] = true,
        -- Jewelry Dusts from seams (Type 63)
        ["pewter dust"] = true,
        ["copper dust"] = true,
        ["silver dust"] = true,
        ["electrum dust"] = true,
        ["platinum dust"] = true
    }
    
    -- Check if this item is in the mining whitelist
    if miningWhitelist[lowerName] then
        isMiningMaterial = true
        if TradeSkills.debug then
            d(string.format("[Mining Debug] '%s' matched whitelist!", itemName))
        end
    elseif TradeSkills.debug then
        -- Show when an item doesn't match but might look like it should
        if itemType == 10 or itemType == 62 or itemType == 63 then
            d(string.format("[Mining Debug] '%s' (Type %d) NOT in whitelist", itemName, itemType))
        end
    end
    
    if isMiningMaterial then
        -- Skip if we're looting from a container (like writ reward boxes)
        if IsLootingContainer() then
            if TradeSkills.debug then
                d(string.format("[Mining Debug] '%s' ignored - looting from container, not gathering", itemName))
            end
            return
        end
        
        -- Ore Tracker (Level 30): show inventory count when mining
        TradeSkills.Mining:ShowOreTracker(itemName, GetItemLink(bagId, slotId))
        
        -- Use cooldown to count nodes, not individual items
        local timeSinceLastMining = TradeSkills.lastMiningTime and (GetGameTimeMilliseconds() - TradeSkills.lastMiningTime) or 9999
        if not TradeSkills.lastMiningTime or timeSinceLastMining > 1500 then
            TradeSkills.savedVars.mining.totalNodesGathered = TradeSkills.savedVars.mining.totalNodesGathered + 1
            TradeSkills.lastMiningTime = GetGameTimeMilliseconds()
            
            -- Check for level up
            local skill = TradeSkills.Mining
            local currentLevel = skill:GetLevel()
            if currentLevel > TradeSkills.savedVars.mining.lastNotifiedLevel then
                TradeSkills.AnnounceLevelUp("Mining", currentLevel, "B38C4D")
                TradeSkills.savedVars.mining.lastNotifiedLevel = currentLevel
            end
            
            TradeSkills.UpdateWindow()
        elseif TradeSkills.debug then
            d(string.format("[Mining Debug] '%s' blocked by cooldown (%dms since last mine, need 1500ms)", itemName, timeSinceLastMining))
        end
        return
    end
    
    -- === HERBALISM DETECTION ===
    -- WHITELIST ONLY - specific reagents and clothier materials from plant nodes
    local isHerbalismMaterial = false
    
    -- Whitelist of plant/reagent names
    local herbalismWhitelist = {
        -- Alchemy Reagents (Type 15)
        ["beetle scuttle"] = true,
        ["blessed thistle"] = true,
        ["blue entoloma"] = true,
        ["bugloss"] = true,
        ["butterfly wing"] = true,
        ["chaurus egg"] = true,
        ["clam gall"] = true,
        ["columbine"] = true,
        ["corn flower"] = true,
        ["crimson nirnroot"] = true,
        ["dragon rheum"] = true,
        ["dragon's bile"] = true,
        ["dragon's blood"] = true,
        ["dragonthorn"] = true,
        ["emetic russula"] = true,
        ["fleshfly larva"] = true,
        ["imp stool"] = true,
        ["lady's smock"] = true,
        ["luminous russula"] = true,
        ["mountain flower"] = true,
        ["namira's rot"] = true,
        ["nightshade"] = true,
        ["nirnroot"] = true,
        ["powdered mother of pearl"] = true,
        ["scrib jelly"] = true,
        ["stinkhorn"] = true,
        ["torchbug thorax"] = true,
        ["vile coagulant"] = true,
        ["violet coprinus"] = true,
        ["water hyacinth"] = true,
        ["white cap"] = true,
        ["wormwood"] = true,
        -- Clothier Raw Materials (Type 18)
        ["raw jute"] = true,
        ["raw flax"] = true,
        ["raw cotton"] = true,
        ["raw spidersilk"] = true,
        ["raw ebonthread"] = true,
        ["raw kreshweed"] = true,
        ["raw silverweed"] = true,
        ["raw void bloom"] = true,
        ["raw ancestor silk"] = true
    }
    
    -- Check if this item is in the herbalism whitelist
    if herbalismWhitelist[lowerName] then
        isHerbalismMaterial = true
        if TradeSkills.debug then
            d(string.format("[Herbalism Debug] '%s' matched whitelist!", itemName))
        end
    -- Special check: Type 39 items that contain "raw" and fabric names (ESO miscategorizes these)
    elseif itemType == 39 and string.find(lowerName, "raw") then
        if string.find(lowerName, "silk") or 
           string.find(lowerName, "jute") or
           string.find(lowerName, "flax") or
           string.find(lowerName, "cotton") or
           string.find(lowerName, "spidersilk") or
           string.find(lowerName, "ebonthread") or
           string.find(lowerName, "kreshweed") or
           string.find(lowerName, "silverweed") or
           string.find(lowerName, "void bloom") then
            isHerbalismMaterial = true
            if TradeSkills.debug then
                d(string.format("[Herbalism Debug] '%s' (Type 39) matched by name pattern!", itemName))
            end
        end
    elseif TradeSkills.debug then
        -- Show when an item doesn't match
        if itemType == 15 or itemType == 18 or itemType == 39 then
            d(string.format("[Herbalism Debug] '%s' (Type %d) NOT in whitelist", itemName, itemType))
        end
    end
    
    if isHerbalismMaterial then
        -- Skip if we're looting from a container (like writ reward boxes)
        if IsLootingContainer() then
            if TradeSkills.debug then
                d(string.format("[Herbalism Debug] '%s' ignored - looting from container, not gathering", itemName))
            end
            return
        end
        
        -- Use cooldown to count nodes, not individual items
        local timeSinceLastGather = TradeSkills.lastHerbalismTime and (GetGameTimeMilliseconds() - TradeSkills.lastHerbalismTime) or 9999
        if not TradeSkills.lastHerbalismTime or timeSinceLastGather > 1500 then
            TradeSkills.savedVars.herbalism.totalNodesGathered = TradeSkills.savedVars.herbalism.totalNodesGathered + 1
            TradeSkills.lastHerbalismTime = GetGameTimeMilliseconds()
            
            -- Check for level up
            local skill = TradeSkills.Herbalism
            local currentLevel = skill:GetLevel()
            if currentLevel > TradeSkills.savedVars.herbalism.lastNotifiedLevel then
                TradeSkills.AnnounceLevelUp("Herbalism", currentLevel, "4DCC66")
                TradeSkills.savedVars.herbalism.lastNotifiedLevel = currentLevel
            end
            
            TradeSkills.UpdateWindow()
        elseif TradeSkills.debug then
            d(string.format("[Herbalism Debug] '%s' blocked by cooldown (%dms since last gather, need 1500ms)", itemName, timeSinceLastGather))
        end
        return
    end
    
    -- === WOODCUTTING DETECTION ===
    -- WHITELIST ONLY - specific raw wood from nodes
    local isWoodcuttingMaterial = false
    
    local woodcuttingWhitelist = {
        ["rough maple"] = true,
        ["rough oak"] = true,
        ["rough beech"] = true,
        ["rough hickory"] = true,
        ["rough yew"] = true,
        ["rough birch"] = true,
        ["rough ash"] = true,
        ["rough mahogany"] = true,
        ["rough nightwood"] = true,
        ["rough ruby ash"] = true,
    }
    
    if woodcuttingWhitelist[lowerName] then
        isWoodcuttingMaterial = true
    -- Also catch by name pattern: "rough" + wood name (handles grammar tags and any item type)
    elseif string.find(lowerName, "rough", 1, true) then
        if string.find(lowerName, "maple", 1, true) or
           string.find(lowerName, "oak", 1, true) or
           string.find(lowerName, "beech", 1, true) or
           string.find(lowerName, "hickory", 1, true) or
           string.find(lowerName, "yew", 1, true) or
           string.find(lowerName, "birch", 1, true) or
           string.find(lowerName, "ash", 1, true) or
           string.find(lowerName, "mahogany", 1, true) or
           string.find(lowerName, "nightwood", 1, true) or
           string.find(lowerName, "ruby ash", 1, true) then
            isWoodcuttingMaterial = true
        end
    end
    
    if isWoodcuttingMaterial then
        -- Skip if looting from a container
        if IsLootingContainer() then return end
        
        -- Log Ledger (Level 30): show inventory count when harvesting wood
        TradeSkills.Woodcutting:ShowLogLedger(itemName, GetItemLink(bagId, slotId))
        
        -- Use cooldown to count nodes, not individual items
        local timeSinceLastWoodcut = TradeSkills.lastWoodcuttingTime and (GetGameTimeMilliseconds() - TradeSkills.lastWoodcuttingTime) or 9999
        if not TradeSkills.lastWoodcuttingTime or timeSinceLastWoodcut > 1500 then
            TradeSkills.savedVars.woodcutting.totalNodesGathered = TradeSkills.savedVars.woodcutting.totalNodesGathered + 1
            TradeSkills.lastWoodcuttingTime = GetGameTimeMilliseconds()
            
            local skill = TradeSkills.Woodcutting
            local currentLevel = skill:GetLevel()
            if currentLevel > TradeSkills.savedVars.woodcutting.lastNotifiedLevel then
                TradeSkills.AnnounceLevelUp("Woodcutting", currentLevel, "66A633")
                TradeSkills.savedVars.woodcutting.lastNotifiedLevel = currentLevel
            end
            
            TradeSkills.UpdateWindow()
        end
        return
    end
    
    -- === SKINNING DETECTION ===
    -- Raw material scraps looted from creatures
    -- ESO Type 39 items have grammar tags that break exact matching
    -- We use the same approach as Herbalism's Type 39 fix: check itemType + string.find
    local isSkinningMaterial = false
    
    if itemType == 39 then
        if string.find(lowerName, "rawhide") 
        or string.find(lowerName, "hide scraps")
        or string.find(lowerName, "leather scraps")
        or string.find(lowerName, "thick leather")
        or string.find(lowerName, "fell hide")
        or string.find(lowerName, "topgrain hide")
        or string.find(lowerName, "iron hide")
        or string.find(lowerName, "superb hide")
        or string.find(lowerName, "shadowhide")
        or string.find(lowerName, "rubedo hide") then
            isSkinningMaterial = true
            if TradeSkills.debug then
                d(string.format("[Skinning Debug] '%s' (Type 39) matched by name pattern!", itemName))
            end
        end
        
        if not isSkinningMaterial and TradeSkills.debug then
            if string.find(lowerName, "scraps") or string.find(lowerName, "hide") then
                d(string.format("[Skinning Debug] '%s' (Type %d) NOT in whitelist", itemName, itemType))
            end
        end
    end
    
    if isSkinningMaterial then
        -- Exclude scraps obtained from non-creature sources:
        -- crafting stations, banks, vendors, mail, guild stores, fences
        local interactionType = GetInteractionType()
        if interactionType == INTERACTION_BANK 
        or interactionType == INTERACTION_VENDOR
        or interactionType == INTERACTION_MAIL
        or interactionType == INTERACTION_GUILDBANK
        or interactionType == INTERACTION_TRADINGHOUSE
        or interactionType == INTERACTION_FENCE
        or interactionType == INTERACTION_CRAFT then
            if TradeSkills.debug then
                d(string.format("[Skinning Debug] '%s' ignored - obtained from interaction type %d (not creature loot)", itemName, interactionType))
            end
            return
        end
        
        TradeSkills.savedVars.skinning.totalScrapsLooted = TradeSkills.savedVars.skinning.totalScrapsLooted + 1
        
        -- Check for level up
        local skill = TradeSkills.Skinning
        local currentLevel = skill:GetLevel()
        if currentLevel > TradeSkills.savedVars.skinning.lastNotifiedLevel then
            TradeSkills.AnnounceLevelUp("Skinning", currentLevel, "BF8C59")
            TradeSkills.savedVars.skinning.lastNotifiedLevel = currentLevel
        end
        
        TradeSkills.UpdateWindow()
        return
    end
end

-- =======================
-- CHECK FOR LEVEL UPS
-- =======================
function TradeSkills.CheckLevelUps()
    -- Check Carpentry
    local carpentryLevel = TradeSkills.Carpentry:GetLevel()
    if carpentryLevel > TradeSkills.savedVars.carpentry.lastNotifiedLevel then
        TradeSkills.AnnounceLevelUp("Carpentry", carpentryLevel, "8C4511")
        TradeSkills.savedVars.carpentry.lastNotifiedLevel = carpentryLevel
    end
    
    -- Check Cooking
    local cookingLevel = TradeSkills.Cooking:GetLevel()
    if cookingLevel > TradeSkills.savedVars.cooking.lastNotifiedLevel then
        TradeSkills.AnnounceLevelUp("Cooking", cookingLevel, "FF9933")
        TradeSkills.savedVars.cooking.lastNotifiedLevel = cookingLevel
    end
    
    -- Check Brewing
    local brewingLevel = TradeSkills.Brewing:GetLevel()
    if brewingLevel > TradeSkills.savedVars.brewing.lastNotifiedLevel then
        TradeSkills.AnnounceLevelUp("Brewing", brewingLevel, "B34FE9")
        TradeSkills.savedVars.brewing.lastNotifiedLevel = brewingLevel
    end
    
    -- Check Style Mastery
    local styleMasteryLevel = TradeSkills.StyleMastery:GetLevel()
    if styleMasteryLevel > TradeSkills.savedVars.stylemastery.lastNotifiedLevel then
        TradeSkills.AnnounceLevelUp("Style Mastery", styleMasteryLevel, "9966CC")
        TradeSkills.savedVars.stylemastery.lastNotifiedLevel = styleMasteryLevel
    end
    
    -- Check Trait Mastery
    local traitMasteryLevel = TradeSkills.TraitMastery:GetLevel()
    if traitMasteryLevel > TradeSkills.savedVars.traitmastery.lastNotifiedLevel then
        TradeSkills.AnnounceLevelUp("Trait Mastery", traitMasteryLevel, "33CC80")
        TradeSkills.savedVars.traitmastery.lastNotifiedLevel = traitMasteryLevel
    end
    
    -- Check Mining
    local miningLevel = TradeSkills.Mining:GetLevel()
    if miningLevel > TradeSkills.savedVars.mining.lastNotifiedLevel then
        TradeSkills.AnnounceLevelUp("Mining", miningLevel, "B38C4D")
        TradeSkills.savedVars.mining.lastNotifiedLevel = miningLevel
    end
    
    -- Check Herbalism
    local herbalismLevel = TradeSkills.Herbalism:GetLevel()
    if herbalismLevel > TradeSkills.savedVars.herbalism.lastNotifiedLevel then
        TradeSkills.AnnounceLevelUp("Herbalism", herbalismLevel, "4DCC66")
        TradeSkills.savedVars.herbalism.lastNotifiedLevel = herbalismLevel
    end
    
    -- Check Woodcutting
    local woodcuttingLevel = TradeSkills.Woodcutting:GetLevel()
    if woodcuttingLevel > TradeSkills.savedVars.woodcutting.lastNotifiedLevel then
        TradeSkills.AnnounceLevelUp("Woodcutting", woodcuttingLevel, "66A633")
        TradeSkills.savedVars.woodcutting.lastNotifiedLevel = woodcuttingLevel
    end
    
    -- Check Skinning
    local skinningLevel = TradeSkills.Skinning:GetLevel()
    if skinningLevel > TradeSkills.savedVars.skinning.lastNotifiedLevel then
        TradeSkills.AnnounceLevelUp("Skinning", skinningLevel, "BF8C59")
        TradeSkills.savedVars.skinning.lastNotifiedLevel = skinningLevel
    end
end

-- =======================
-- INITIALIZATION
-- =======================
function TradeSkills.OnAddOnLoaded(event, addonName)
    if addonName ~= TradeSkills.name then return end
    
    -- Initialize saved variables (PER CHARACTER)
    TradeSkills.savedVars = ZO_SavedVars:NewCharacterIdSettings("TradeSkillsSavedVars", TradeSkills.SAVED_VARS_VERSION, nil, defaultSettings)
    
    -- Initialize account-wide saved variables (shared across all characters)
    TradeSkills.accountVars = ZO_SavedVars:NewAccountWide("TradeSkillsAccountVars", TradeSkills.SAVED_VARS_VERSION, nil, {
        herdPins = {},      -- { [mapId] = { {x, y, label}, ... } }
        heatMapPins = {},   -- { [mapId] = { {x, y, label}, ... } }
        groveMapPins = {},  -- { [mapId] = { {x, y, label}, ... } }
    })
    
    -- Create UI
    TradeSkills.CreateWindow()
    
    -- Scan recipes, traits, and motif pages
    TradeSkills.ScanRecipes()
    TradeSkills.ScanTraits()
    TradeSkills.StyleMastery:ScanMotifPages()
    
    -- Check for level ups on login
    TradeSkills.CheckLevelUps()
    
    -- Select saved tab
    TradeSkills.SelectTab(TradeSkills.savedVars.activeTab or 1)
    
    -- Register events
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_INVENTORY", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdate)
    EVENT_MANAGER:AddFilterForEvent(TradeSkills.name .. "_INVENTORY", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    
    -- Also listen for craft bag updates (ESO+ players' materials go directly to BAG_VIRTUAL)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_INVENTORY_CRAFT", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdate)
    EVENT_MANAGER:AddFilterForEvent(TradeSkills.name .. "_INVENTORY_CRAFT", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_VIRTUAL)
    
    -- Register for trait research completion
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_TRAIT", EVENT_SMITHING_TRAIT_LEARNED, function(_, craftingType, researchLineIndex, traitIndex)
        -- Rescan all traits when one is learned
        TradeSkills.ScanTraits()
        TradeSkills.CheckLevelUps()
        TradeSkills.UpdateWindow()
    end)
    
    -- Recipe learned event handler
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_RECIPE", EVENT_RECIPE_LEARNED, function(_, recipeListIndex, recipeIndex)
        local known, recipeName = GetRecipeInfo(recipeListIndex, recipeIndex)
        if known then
            -- Simple motif detection by name (fallback method)
            if recipeName and string.find(string.lower(recipeName), "motif") then
                TradeSkills.StyleMastery:ScanMotifPages()
                TradeSkills.CheckLevelUps()
                TradeSkills.UpdateWindow()
                return
            end
            
            -- Handle regular recipes
            local resultLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
            if resultLink and resultLink ~= "" then
                local itemType = GetItemLinkItemType(resultLink)
                local key = string.format("%d_%d", recipeListIndex, recipeIndex)
                
                local wasNew = false
                
                if itemType == ITEMTYPE_FURNISHING then
                    if not TradeSkills.savedVars.carpentry.knownRecipes[key] then
                        TradeSkills.savedVars.carpentry.knownRecipes[key] = true
                        wasNew = true
                    end
                elseif itemType == ITEMTYPE_FOOD then
                    if not TradeSkills.savedVars.cooking.knownRecipes[key] then
                        TradeSkills.savedVars.cooking.knownRecipes[key] = true
                        wasNew = true
                    end
                elseif itemType == ITEMTYPE_DRINK then
                    if not TradeSkills.savedVars.brewing.knownRecipes[key] then
                        TradeSkills.savedVars.brewing.knownRecipes[key] = true
                        wasNew = true
                    end
                end
                
                if wasNew then
                    TradeSkills.CheckLevelUps()
                    TradeSkills.UpdateWindow()
                end
            end
        end
    end)
    
    -- Register for collectible updates to catch motif learning in real-time
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_COLLECTIBLE", EVENT_COLLECTIBLE_UPDATED, function(_, collectibleId, justUnlocked)
        if justUnlocked then
            -- Check if it's a motif-related collectible
            local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
            if collectibleData then
                local categoryType = collectibleData:GetCategoryType()
                if categoryType == COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE then
                    local oldCount = TradeSkills.StyleMastery:GetCount()
                    TradeSkills.StyleMastery:ScanMotifPages()
                    if TradeSkills.StyleMastery:GetCount() > oldCount then
                        local collectibleName = collectibleData:GetName()
                        TradeSkills.CheckLevelUps()
                        TradeSkills.UpdateWindow()
                        
                        -- Visual Completionist: show progress popup
                        if TradeSkills.StyleMastery:HasPerk(5) then
                            TradeSkills.StyleMastery:ShowStyleProgressFromName(collectibleName)
                        end
                    end
                end
            end
        end
    end)
    
    -- Register for lore book updates to catch traditional motif learning
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_LOREBOOK", EVENT_LORE_BOOK_LEARNED, function(_, categoryIndex, collectionIndex, bookIndex)
        -- Check if it's a motif-related lore book
        local categoryName = GetLoreCategoryInfo(categoryIndex)
        if categoryName and (string.find(string.lower(categoryName), "motif") or 
                           string.find(string.lower(categoryName), "style") or
                           string.find(string.lower(categoryName), "craft")) then
            
            local oldCount = TradeSkills.StyleMastery:GetCount()
            TradeSkills.StyleMastery:ScanMotifPages()
            if TradeSkills.StyleMastery:GetCount() > oldCount then
                local bookName = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
                TradeSkills.CheckLevelUps()
                TradeSkills.UpdateWindow()
                
                -- Visual Completionist: show progress popup
                if TradeSkills.StyleMastery:HasPerk(5) then
                    TradeSkills.StyleMastery:ShowStyleProgressFromName(bookName or "Unknown")
                end
            end
        end
    end)
    
    -- Rescan recipes when interacting with provisioning station
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_STATION", EVENT_CRAFTING_STATION_INTERACT, function(_, craftSkill)
        if craftSkill == CRAFTING_TYPE_PROVISIONING then
            -- Build fresh inventory cache, then async scan
            zo_callLater(function()
                TradeSkills._inventoryCache = nil  -- force cache rebuild
                TradeSkills.ScanRecipes()
            end, 500)
        end
    end)
    
    -- Also rescan when closing a provisioning station
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_STATION_END", EVENT_END_CRAFTING_STATION_INTERACT, function(_, craftSkill)
        if craftSkill == CRAFTING_TYPE_PROVISIONING then
            zo_callLater(function()
                TradeSkills._inventoryCache = nil
                TradeSkills.ScanRecipes()
            end, 100)
        end
    end)
    
    -- Fishing Perks: Hook into RETICLE.interact (same approach as Votan's Fisherman)
    -- This fires reliably when interaction HUD appears/disappears
    ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", function()
        TradeSkills.Fishing:OnInteractionChanged()
        return false
    end)
    ZO_PreHookHandler(RETICLE.interact, "OnHide", function()
        TradeSkills.Fishing._atFishingHole = false
        TradeSkills.Fishing:HideChecklist()
        return false
    end)
    
    -- Detect fishing interruption (line break, attacked, etc.) like FishBar does
    ZO_PostHook(RETICLE, "TryHandlingInteraction", function(interactionPossible)
        if interactionPossible and TradeSkills.Fishing._isFishing then
            local action = GetGameCameraInteractableActionInfo()
            local reelInText = GetString(SI_GAMECAMERAACTIONTYPE17)
            if action ~= reelInText then
                -- Action changed away from "Reel In" while fishing = interrupted
                TradeSkills.Fishing:StopFishingWatch()
            end
        end
    end)
    
    -- Also detect when player loses the fishing interaction entirely
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_FISHSLOT", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, slotIndex, isNew)
        -- If we're fishing and get a new item that's NOT from fishing (no lure), stop
        if TradeSkills.Fishing._isFishing and not GetFishingLure() then
            TradeSkills.Fishing:StopFishingWatch()
        end
    end)
    EVENT_MANAGER:AddFilterForEvent(TradeSkills.name .. "_FISHSLOT", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
    
    -- Fishing Perk: Zone Fish Checklist
    -- Shown/hidden as part of the RETICLE.interact hook above
    
    -- Create the checklist window (hidden initially)
    TradeSkills.Fishing:CreateChecklistWindow()
    
    -- Create the reel alert overlay (hidden initially)
    TradeSkills.Fishing:CreateReelAlertOverlay()
    
    -- Stop fish bar when interaction ends (walk away, get attacked, etc.)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_FISHEND", EVENT_END_INTERACTION, function()
        TradeSkills.Fishing:StopFishingWatch()
    end)
    
    -- =======================
    -- SKINNING PERK HOOKS
    -- =======================
    
    -- Anatomy Specialist (Level 30): Show loot window when targeting creatures
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_RETICLE", EVENT_RETICLE_TARGET_CHANGED, function()
        TradeSkills.Skinning:OnReticleTargetChanged()
    end)
    
    -- Learn creature drops when looting (Anatomy Specialist)
    -- Learn creature drops when loot window opens (Anatomy Specialist)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_LOOTLEARN", EVENT_LOOT_UPDATED, function()
        TradeSkills.Skinning:OnLootUpdated()
    end)
    
    -- Beast Watch (Level 10): Highlight nearby scrap-dropping enemies
    TradeSkills.Skinning:StartBeastWatch()
    
    -- Herd Map (Level 50): Add map pins for scrap farming areas via LibMapPins
    TradeSkills.Skinning:InitHerdMapPins()
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
        TradeSkills.Skinning:RefreshHerdPins()
        TradeSkills.Mining:RefreshHeatMapPins()
        TradeSkills.Woodcutting:RefreshGroveMapPins()
    end)
    
    -- =======================
    -- CARPENTRY PERK EVENTS
    -- =======================
    
    -- Furniture Store (Level 10): Show craftable furniture at crafting stations
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_CARPSTATION", EVENT_CRAFTING_STATION_INTERACT, function(eventCode, craftSkillType, sameStation)
        -- Woodworking, Clothing, Blacksmithing, Jewelry
        if craftSkillType == CRAFTING_TYPE_WOODWORKING or craftSkillType == CRAFTING_TYPE_CLOTHIER
           or craftSkillType == CRAFTING_TYPE_BLACKSMITHING or craftSkillType == CRAFTING_TYPE_JEWELRYCRAFTING then
            if TradeSkills.Carpentry:HasPerk(10) then
                zo_callLater(function()
                    TradeSkills.Carpentry:ScanCraftableFurniture(craftSkillType)
                end, 500)
            end
        end
    end)
    
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_CARPSTATIONEND", EVENT_END_CRAFTING_STATION_INTERACT, function()
        TradeSkills.Carpentry:HideFurnitureStoreWindow()
    end)
    
    -- =======================
    -- STYLE MASTERY PERK EVENTS
    -- =======================
    
    -- Motif Map (Level 10): Show zone motif drops in a window only while in the map menu
    -- Hook into map zone changes
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
        if TradeSkills.StyleMastery:HasPerk(10) then
            TradeSkills.StyleMastery:UpdateMotifMapDisplay()
        end
    end)
    
    -- Use the world map scene to show/hide the motif window
    local worldMapScene = SCENE_MANAGER:GetScene("worldMap")
    if worldMapScene then
        worldMapScene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWN or newState == SCENE_SHOWING then
                if TradeSkills.StyleMastery:HasPerk(10) then
                    zo_callLater(function()
                        TradeSkills.StyleMastery:UpdateMotifMapDisplay()
                    end, 200)
                end
            elseif newState == SCENE_HIDDEN or newState == SCENE_HIDING then
                TradeSkills.StyleMastery:HideMotifMapWindow()
            end
        end)
    end
    
    -- Also handle the gamepad map scene if it exists
    local gmapScene = SCENE_MANAGER:GetScene("gamepad_worldMap")
    if gmapScene then
        gmapScene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWN or newState == SCENE_SHOWING then
                if TradeSkills.StyleMastery:HasPerk(10) then
                    zo_callLater(function()
                        TradeSkills.StyleMastery:UpdateMotifMapDisplay()
                    end, 200)
                end
            elseif newState == SCENE_HIDDEN or newState == SCENE_HIDING then
                TradeSkills.StyleMastery:HideMotifMapWindow()
            end
        end)
    end
    
    -- =======================
    -- MINING PERK EVENTS
    -- =======================
    
    -- Heat Map (Level 30): Add map pins for ore farming areas via LibMapPins
    TradeSkills.Mining:InitHeatMapPins()
    
    -- =======================
    -- WOODCUTTING PERK EVENTS
    -- =======================
    
    -- Grove Map (Level 50): Add map pins for wood farming areas via LibMapPins
    TradeSkills.Woodcutting:InitGroveMapPins()
    
    -- =======================
    -- TRAIT MASTERY PERK EVENTS
    -- =======================
    
    -- Material Salvage Forecast (Level 10): Hook item tooltips
    TradeSkills.TraitMastery:InitSalvageForecastTooltip()
    
    -- =======================
    -- HERBALISM PERK EVENTS
    -- =======================
    
    -- Flora ID (Level 10): Hook reagent tooltips
    TradeSkills.Herbalism:InitFloraIDTooltip()
    
    -- Scent of the Wild (Level 40): Initialize columbine detection
    TradeSkills.Herbalism:InitScentOfTheWild()
    
    -- Greenhouse Tracker + Scent of the Wild: Hook into interaction system
    -- Poll the reticle target to detect alchemy nodes
    EVENT_MANAGER:RegisterForUpdate("TradeSkills_HerbReticle", 500, function()
        local herbActive = TradeSkills.Herbalism:IsPassiveActive(10) or TradeSkills.Herbalism:IsPassiveActive(25) or TradeSkills.Herbalism:IsPassiveActive(40)
        local miningActive = TradeSkills.Mining:HasPerk(10)
        local woodcuttingActive = TradeSkills.Woodcutting:HasPerk(10)
        if not herbActive and not miningActive and not woodcuttingActive then return end
        
        -- Safely get reticle target info
        local ok, action, interactableName = pcall(GetGameCameraInteractableActionInfo)
        if not ok then
            TradeSkills.Herbalism._lastReticleName = nil
            return
        end
        
        -- Guard: both action and name must be strings
        if type(action) ~= "string" or type(interactableName) ~= "string" or interactableName == "" then
            TradeSkills.Herbalism._lastReticleName = nil
            return
        end
        
        local lowerName = string.lower(interactableName)
        
        -- Check if this is an alchemy plant node (exact reagent names only)
        local herbKeywords = {"blessed thistle", "blue entoloma", "bugloss", "columbine", "corn flower",
            "dragonthorn", "emetic russula", "imp stool", "lady's smock", "luminous russula",
            "mountain flower", "namira's rot", "nightshade", "nirnroot", "stinkhorn", "violet coprinus",
            "water hyacinth", "white cap", "wormwood",
            -- Clothier fiber plants (also tracked by Herbalism)
            "jute", "flax", "cotton", "spidersilk", "ebonthread",
            "kreshweed", "silverweed", "void bloom", "ancestor silk"}
        local isHerb = false
        for _, kw in ipairs(herbKeywords) do
            if string.find(lowerName, kw, 1, true) then
                isHerb = true
                break
            end
        end
        
        if isHerb then
            if TradeSkills.Herbalism._lastReticleName ~= lowerName then
                TradeSkills.Herbalism._lastReticleName = lowerName
                -- Greenhouse Tracker
                TradeSkills.Herbalism:ShowGreenhouseTracker(interactableName)
                -- Scent of the Wild
                TradeSkills.Herbalism:CheckForColumbine(interactableName)
                -- Flora ID (Level 10): Show fiber level range popup for clothier nodes
                if TradeSkills.Herbalism:IsPassiveActive(10) then
                    TradeSkills.Herbalism:ShowFiberLevelRange(interactableName)
                end
            end
        else
            TradeSkills.Herbalism._lastReticleName = nil
            TradeSkills.Herbalism:HideFiberLevelRange()
        end
        
        -- Miner's Eye (Level 10): check if this is an ore node and show level range
        if TradeSkills.Mining:HasPerk(10) then
            local isMiningNode = false
            -- Check against ore names in the mining whitelist
            if TradeSkills.L and TradeSkills.L.MiningWhitelist then
                if TradeSkills.L.MiningWhitelist[lowerName] then
                    isMiningNode = true
                end
            end
            -- Also try partial match for node interactable names (e.g. "Iron Ore" as node label)
            if not isMiningNode then
                for oreName, _ in pairs(TradeSkills.Mining.ORE_LEVEL_DATA) do
                    if string.find(lowerName, oreName, 1, true) then
                        isMiningNode = true
                        break
                    end
                end
            end
            
            if isMiningNode then
                if TradeSkills.Mining._lastReticleOre ~= lowerName then
                    TradeSkills.Mining._lastReticleOre = lowerName
                    TradeSkills.Mining:ShowMinersEye(interactableName)
                end
            else
                TradeSkills.Mining._lastReticleOre = nil
            end
        end
        
        -- Timber Sense (Level 10): check if this is a wood node and show level range
        if TradeSkills.Woodcutting:HasPerk(10) then
            local isWoodNode = false
            for woodName, _ in pairs(TradeSkills.Woodcutting.WOOD_LEVEL_DATA) do
                if string.find(lowerName, woodName, 1, true) then
                    isWoodNode = true
                    break
                end
            end
            
            if isWoodNode then
                if TradeSkills.Woodcutting._lastReticleWood ~= lowerName then
                    TradeSkills.Woodcutting._lastReticleWood = lowerName
                    TradeSkills.Woodcutting:ShowTimberSense(interactableName)
                end
            else
                TradeSkills.Woodcutting._lastReticleWood = nil
            end
        end
    end)
    
    -- =======================
    -- BREWING PERK EVENTS
    -- =======================
    
    -- Quick Drink (Level 10): Auto-select drink when buff expires
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_DRINKBUFF", EVENT_EFFECT_CHANGED, function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
        TradeSkills.Brewing:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
    end)
    EVENT_MANAGER:AddFilterForEvent(TradeSkills.name .. "_DRINKBUFF", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    
    -- Check drink buff on login
    TradeSkills.Brewing:CheckDrinkBuffOnLogin()
    TradeSkills.Brewing:StartQuickslotMonitor()
    
    -- Efficiency Calculator (Level 30): Hook provisioning station
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_PROVISION", EVENT_CRAFTING_STATION_INTERACT, function(eventCode, craftSkillType, sameStation)
        if craftSkillType == CRAFTING_TYPE_PROVISIONING then
            TradeSkills.Brewing._atProvisioningStation = true
            TradeSkills.Brewing:StartEfficiencyPolling()
            
            -- Also try to hook PROVISIONER's recipe selection directly (one-time)
            -- Keyboard mode: PROVISIONER
            if not TradeSkills.Brewing._provisionerHooked and PROVISIONER then
                -- Try hooking SelectNode on the recipe tree
                if PROVISIONER.recipeTree and PROVISIONER.recipeTree.SelectNode then
                    SecurePostHook(PROVISIONER.recipeTree, "SelectNode", function(tree, node)
                        if not TradeSkills.Brewing._atProvisioningStation then return end
                        if not TradeSkills.Brewing:HasPerk(30) then return end
                        local data = node and (node.data or (node.GetData and node:GetData()))
                        if data and data.recipeListIndex and data.recipeIndex then
                            TradeSkills.Brewing:ShowEfficiencyInfo(data.recipeListIndex, data.recipeIndex)
                        end
                    end)
                    TradeSkills.Brewing._provisionerHooked = true
                end
            end
            -- Gamepad mode: GAMEPAD_PROVISIONER
            if not TradeSkills.Brewing._gamepadProvisionerHooked and GAMEPAD_PROVISIONER then
                if GAMEPAD_PROVISIONER.recipeTree and GAMEPAD_PROVISIONER.recipeTree.SelectNode then
                    SecurePostHook(GAMEPAD_PROVISIONER.recipeTree, "SelectNode", function(tree, node)
                        if not TradeSkills.Brewing._atProvisioningStation then return end
                        if not TradeSkills.Brewing:HasPerk(30) then return end
                        local data = node and (node.data or (node.GetData and node:GetData()))
                        if data and data.recipeListIndex and data.recipeIndex then
                            TradeSkills.Brewing:ShowEfficiencyInfo(data.recipeListIndex, data.recipeIndex)
                        end
                    end)
                    TradeSkills.Brewing._gamepadProvisionerHooked = true
                end
            end
        end
    end)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_PROVISIONEND", EVENT_END_CRAFTING_STATION_INTERACT, function()
        TradeSkills.Brewing._atProvisioningStation = false
        TradeSkills.Brewing:HideEfficiencyInfo()
        TradeSkills.Cooking._atProvisioningStation = false
        TradeSkills.Cooking:HideMarginWindow()
    end)
    
    -- =======================
    -- COOKING PERK EVENTS
    -- =======================
    
    -- Quick Eat (Level 10): Auto-select food when buff expires
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_FOODBUFF", EVENT_EFFECT_CHANGED, function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
        TradeSkills.Cooking:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
    end)
    EVENT_MANAGER:AddFilterForEvent(TradeSkills.name .. "_FOODBUFF", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    
    -- Check food buff on login
    TradeSkills.Cooking:CheckFoodBuffOnLogin()
    TradeSkills.Cooking:StartQuickslotMonitor()
    
    -- Master Chef's Margin (Level 30): Show craftable recipes at provisioning station
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_COOKPROVISION", EVENT_CRAFTING_STATION_INTERACT, function(eventCode, craftSkillType, sameStation)
        if craftSkillType == CRAFTING_TYPE_PROVISIONING then
            TradeSkills.Cooking._atProvisioningStation = true
            -- Small delay to let the provisioner UI load
            zo_callLater(function()
                TradeSkills.Cooking:ScanCraftableRecipes()
            end, 500)
        end
    end)
    
    
    EVENT_MANAGER:UnregisterForEvent(TradeSkills.name, EVENT_ADD_ON_LOADED)
    
    -- =======================
    -- PAUSE INVENTORY TRACKING DURING BANK/VENDOR/MAIL
    -- =======================
    -- Prevents freezes when addons like PersonalAssistant auto-deposit hundreds of items.
    -- We completely unregister our inventory handlers while at a bank/vendor/etc,
    -- then re-register them when the interaction ends.
    
    local function PauseInventoryTracking()
        pcall(EVENT_MANAGER.UnregisterForEvent, EVENT_MANAGER, TradeSkills.name .. "_INVENTORY", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        pcall(EVENT_MANAGER.UnregisterForEvent, EVENT_MANAGER, TradeSkills.name .. "_INVENTORY_CRAFT", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    end
    
    local function ResumeInventoryTracking()
        -- Unregister first to avoid duplicates
        pcall(EVENT_MANAGER.UnregisterForEvent, EVENT_MANAGER, TradeSkills.name .. "_INVENTORY", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        pcall(EVENT_MANAGER.UnregisterForEvent, EVENT_MANAGER, TradeSkills.name .. "_INVENTORY_CRAFT", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        
        EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_INVENTORY", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdate)
        EVENT_MANAGER:AddFilterForEvent(TradeSkills.name .. "_INVENTORY", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
        EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_INVENTORY_CRAFT", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdate)
        EVENT_MANAGER:AddFilterForEvent(TradeSkills.name .. "_INVENTORY_CRAFT", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_VIRTUAL)
    end
    
    -- Pause when opening bank, guild bank, vendor, mail, fence, trading house
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_BANK_OPEN", EVENT_OPEN_BANK, PauseInventoryTracking)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_GBANK_OPEN", EVENT_OPEN_GUILD_BANK, PauseInventoryTracking)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_STORE_OPEN", EVENT_OPEN_STORE, PauseInventoryTracking)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_MAIL_OPEN", EVENT_MAIL_OPEN_MAILBOX, PauseInventoryTracking)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_FENCE_OPEN", EVENT_OPEN_FENCE, PauseInventoryTracking)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_TH_OPEN", EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, PauseInventoryTracking)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_HBANK_OPEN", EVENT_OPEN_HOUSE_BANK, PauseInventoryTracking)
    
    -- Resume when closing any of them (EVENT_END_INTERACTION covers all)
    EVENT_MANAGER:RegisterForEvent(TradeSkills.name .. "_INTERACT_END", EVENT_END_INTERACTION, ResumeInventoryTracking)
    
end

-- =======================
-- SLASH COMMANDS
-- =======================
SLASH_COMMANDS["/tradeskills"] = function(cmd)
    if cmd == "" then
        d("[TradeSkills] Available commands:")
        d("  /tradeskills show - Toggle window visibility")
        d("  /tradeskills reset <skill> - Reset a specific skill")
        d("  /tradeskills test fishing - Test increment fishing")
        d("  /tradeskills test mining - Test increment mining")
        d("  /tradeskills test herbalism - Test increment herbalism")
        d("  /tradeskills test skinning - Test increment skinning")
        d("  /tradeskills test stylemastery - Test increment style mastery")
        d("  /tradeskills test traitmastery - Test increment trait mastery")
        d("  /tradeskills addtraits <number> - Add trait count manually")
        d("  /tradeskills rescan - Rescan all recipes and traits")
        d("  /tradeskills debug perks - Toggle all passive abilities on/off")
        d("  /tradeskills herdpin add [label] - Add a Herd Map pin")
        d("  /tradeskills herdpin remove - Remove nearest Herd Map pin")
        d("  /tradeskills herdpin clear - Clear all Herd Map pins")
        d("  /tradeskills heatpin add [label] - Add a Heat Map pin")
        d("  /tradeskills heatpin remove - Remove nearest Heat Map pin")
        d("  /tradeskills heatpin clear - Clear all Heat Map pins")
    elseif cmd == "show" then
        if TradeSkills.window then
            local isHidden = TradeSkills.window:IsHidden()
            TradeSkills.window:SetHidden(not isHidden)
            d("[TradeSkills] Window " .. (isHidden and "shown" or "hidden"))
        end
    elseif string.find(cmd, "reset") then
        local skill = string.match(cmd, "reset%s+(%w+)")
        if skill == "carpentry" then
            TradeSkills.savedVars.carpentry.knownRecipes = {}
            TradeSkills.savedVars.carpentry.lastNotifiedLevel = 0
            d("[TradeSkills] Carpentry skill reset")
        elseif skill == "cooking" then
            TradeSkills.savedVars.cooking.knownRecipes = {}
            TradeSkills.savedVars.cooking.lastNotifiedLevel = 0
            d("[TradeSkills] Cooking skill reset")
        elseif skill == "brewing" then
            TradeSkills.savedVars.brewing.knownRecipes = {}
            TradeSkills.savedVars.brewing.lastNotifiedLevel = 0
            d("[TradeSkills] Brewing skill reset")
        elseif skill == "stylemastery" then
            TradeSkills.savedVars.stylemastery.knownMotifPages = {}
            TradeSkills.savedVars.stylemastery.lastNotifiedLevel = 0
            TradeSkills.StyleMastery:ScanMotifPages()
            d("[TradeSkills] Style Mastery skill reset")
        elseif skill == "traitmastery" then
            TradeSkills.savedVars.traitmastery.knownTraits = 0
            TradeSkills.savedVars.traitmastery.lastNotifiedLevel = 0
            d("[TradeSkills] Trait Mastery skill reset")
        elseif skill == "fishing" then
            TradeSkills.savedVars.fishing.totalFishCaught = 0
            TradeSkills.savedVars.fishing.lastNotifiedLevel = 0
            d("[TradeSkills] Fishing skill reset")
        elseif skill == "mining" then
            TradeSkills.savedVars.mining.totalNodesGathered = 0
            TradeSkills.savedVars.mining.lastNotifiedLevel = 0
            d("[TradeSkills] Mining skill reset")
        elseif skill == "herbalism" then
            TradeSkills.savedVars.herbalism.totalNodesGathered = 0
            TradeSkills.savedVars.herbalism.lastNotifiedLevel = 0
            d("[TradeSkills] Herbalism skill reset")
        elseif skill == "woodcutting" then
            TradeSkills.savedVars.woodcutting.totalNodesGathered = 0
            TradeSkills.savedVars.woodcutting.lastNotifiedLevel = 0
            d("[TradeSkills] Woodcutting skill reset")
        elseif skill == "skinning" then
            TradeSkills.savedVars.skinning.totalScrapsLooted = 0
            TradeSkills.savedVars.skinning.lastNotifiedLevel = 0
            d("[TradeSkills] Skinning skill reset")
        elseif skill == "creatureloot" then
            TradeSkills.savedVars.skinning.creatureLoot = {}
            d("[TradeSkills] Creature loot data cleared")
        elseif skill == "herdpins" then
            TradeSkills.accountVars.herdPins = {}
            TradeSkills.Skinning:RefreshHerdPins()
            d("[TradeSkills] All herd pins cleared")
        else
            d("[TradeSkills] Unknown skill. Use: carpentry, cooking, brewing, stylemastery, traitmastery, fishing, mining, herbalism, skinning, creatureloot, or herdpins")
        end
        TradeSkills.UpdateWindow()
    elseif cmd == "test fishing" then
        TradeSkills.savedVars.fishing.totalFishCaught = TradeSkills.savedVars.fishing.totalFishCaught + 1
        TradeSkills.CheckLevelUps()
        TradeSkills.UpdateWindow()
        d("[TradeSkills] Fish caught: " .. TradeSkills.savedVars.fishing.totalFishCaught)
    elseif cmd == "test mining" then
        TradeSkills.savedVars.mining.totalNodesGathered = TradeSkills.savedVars.mining.totalNodesGathered + 1
        TradeSkills.CheckLevelUps()
        TradeSkills.UpdateWindow()
        d("[TradeSkills] Nodes mined: " .. TradeSkills.savedVars.mining.totalNodesGathered)
    elseif cmd == "test herbalism" then
        TradeSkills.savedVars.herbalism.totalNodesGathered = TradeSkills.savedVars.herbalism.totalNodesGathered + 1
        TradeSkills.CheckLevelUps()
        TradeSkills.UpdateWindow()
        d("[TradeSkills] Plants gathered: " .. TradeSkills.savedVars.herbalism.totalNodesGathered)
    elseif cmd == "test woodcutting" then
        TradeSkills.savedVars.woodcutting.totalNodesGathered = TradeSkills.savedVars.woodcutting.totalNodesGathered + 1
        TradeSkills.CheckLevelUps()
        TradeSkills.UpdateWindow()
        d("[TradeSkills] Wood harvested: " .. TradeSkills.savedVars.woodcutting.totalNodesGathered)
    elseif cmd == "test skinning" then
        TradeSkills.savedVars.skinning.totalScrapsLooted = TradeSkills.savedVars.skinning.totalScrapsLooted + 1
        TradeSkills.CheckLevelUps()
        TradeSkills.UpdateWindow()
        d("[TradeSkills] Scraps looted: " .. TradeSkills.savedVars.skinning.totalScrapsLooted)
    elseif cmd:match("^addmotifs") then
        d("[TradeSkills] Style Mastery now counts directly from known styles. Use /tradeskills rescan to refresh the count.")
    elseif cmd:match("^addtraits%s+(%d+)") then
        local numToAdd = tonumber(cmd:match("^addtraits%s+(%d+)"))
        if numToAdd and numToAdd > 0 and numToAdd <= 1000 then
            TradeSkills.savedVars.traitmastery.knownTraits = TradeSkills.savedVars.traitmastery.knownTraits + numToAdd
            TradeSkills.CheckLevelUps()
            TradeSkills.UpdateWindow()
            d(string.format("[TradeSkills] Added %d traits manually. New total: %d", 
                           numToAdd, TradeSkills.savedVars.traitmastery.knownTraits))
        else
            d("[TradeSkills] Invalid number. Use: /tradeskills addtraits <1-1000>")
        end
    elseif cmd == "test stylemastery" then
        TradeSkills.StyleMastery:ScanMotifPages()
        TradeSkills.CheckLevelUps()
        TradeSkills.UpdateWindow()
        d("[TradeSkills] Motif pages rescanned. Total: " .. TradeSkills.StyleMastery:GetCount())
    elseif cmd == "test traitmastery" then
        TradeSkills.savedVars.traitmastery.knownTraits = TradeSkills.savedVars.traitmastery.knownTraits + 1
        TradeSkills.CheckLevelUps()
        TradeSkills.UpdateWindow()
        d("[TradeSkills] Test trait added. Total: " .. TradeSkills.savedVars.traitmastery.knownTraits)
    elseif cmd == "rescan" then
        TradeSkills.ScanRecipes()
        TradeSkills.ScanTraits()
        TradeSkills.StyleMastery:ScanMotifPages()
        -- Clear cached achievement lists so they get rescanned
        TradeSkills.Fishing._achievements = nil
        TradeSkills.Mining._blacksmithingAchievements = nil
        TradeSkills.Mining._jewelryAchievements = nil
        TradeSkills.Herbalism._achievements = nil
        TradeSkills.Woodcutting._woodworkingAchievements = nil
        TradeSkills.Skinning._trophyAchievements = nil
        TradeSkills.Skinning._clothierAchievements = nil
        TradeSkills.CheckLevelUps()
        TradeSkills.UpdateWindow()
        d("[TradeSkills] Recipes, traits, and achievements rescanned")
    elseif cmd == "debug achievements" then
        d("[TradeSkills] === Achievement Categories ===")
        local numCategories = GetNumAchievementCategories()
        for ci = 1, numCategories do
            local catName, subCount, achCount = GetAchievementCategoryInfo(ci)
            d(string.format("  Category %d: '%s' (subs: %d, achievements: %d)", ci, catName or "nil", subCount, achCount))
            for si = 1, subCount do
                local subName, subAchCount = GetAchievementSubCategoryInfo(ci, si)
                d(string.format("    Sub %d: '%s' (achievements: %d)", si, subName or "nil", subAchCount))
            end
        end
    elseif cmd == "debug achcount" then
        -- Show how many achievements each skill found
        -- Clear cached achievements first so we get fresh counts
        TradeSkills.Fishing._achievements = nil
        TradeSkills.Herbalism._achievements = nil
        TradeSkills.Mining._blacksmithingAchievements = nil
        TradeSkills.Mining._jewelryAchievements = nil
        TradeSkills.Skinning._trophyAchievements = nil
        TradeSkills.Skinning._clothierAchievements = nil
        local skills = {
            {name = "Fishing", cats = {"Fishing"}},
            {name = "Herbalism (Alchemy)", cats = {"Alchemy"}},
            {name = "Mining (Blacksmithing)", cats = {"Blacksmithing"}},
            {name = "Mining (Jewelry Crafting)", cats = {"Jewelry Crafting"}},
            {name = "Skinning (Trophies)", cats = {"Trophies"}},
            {name = "Skinning (Clothier)", cats = {"Clothier"}}
        }
        for _, s in ipairs(skills) do
            local ids = TradeSkills.FindAchievementsBySubCategory(unpack(s.cats))
            d(string.format("[%s] Found %d achievements searching for: %s", s.name, #ids, table.concat(s.cats, ", ")))
        end
    elseif cmd == "debug lures" then
        d("[TradeSkills] === Fishing Lure Dump ===")
        local numLures = GetNumFishingLures()
        d(string.format("Total lure slots: %d", numLures))
        for i = 1, numLures do
            local name, icon, stack, sellPrice, quality = GetFishingLureInfo(i)
            if name and name ~= "" then
                local formatted = zo_strformat("<<1>>", name)
                d(string.format("  [%d] raw='%s' formatted='%s' stack=%s quality=%s", i, name, formatted, tostring(stack), tostring(quality)))
            end
        end
        d(string.format("Current lure index: %d", GetFishingLure()))
    elseif cmd == "debug checklist" then
        d("[TradeSkills] === Fish Checklist Debug ===")
        local zoneName = GetUnitZone("player")
        d(string.format("Zone (GetUnitZone): '%s'", tostring(zoneName)))
        if zoneName then
            zoneName = zo_strformat("<<1>>", zoneName)
            d(string.format("Zone (formatted): '%s'", zoneName))
        end
        local achievementId, achievementName, completed = TradeSkills.Fishing:GetZoneFishingAchievement()
        if achievementId then
            d(string.format("Found achievement: [%d] '%s' (completed: %s)", achievementId, achievementName, tostring(completed)))
            local numCriteria = GetAchievementNumCriteria(achievementId)
            d(string.format("Criteria count: %d", numCriteria))
            for i = 1, numCriteria do
                local criteriaDesc, numCompleted, numRequired = GetAchievementCriterion(achievementId, i)
                d(string.format("  [%d] '%s' %d/%d", i, zo_strformat("<<1>>", criteriaDesc or ""), numCompleted, numRequired))
            end
        else
            d("No fishing achievement found for this zone!")
        end
        -- Also force-show the checklist
        TradeSkills.Fishing:ShowChecklist(true)
    elseif string.find(cmd, "^herdpin add") then
        local label = string.match(cmd, "^herdpin add%s*(.*)")
        TradeSkills.Skinning:AddHerdPin(label)
    elseif cmd == "herdpin remove" then
        TradeSkills.Skinning:RemoveNearestHerdPin()
    elseif cmd == "herdpin clear" then
        TradeSkills.Skinning:ClearAllHerdPins()
    elseif cmd == "herdpin list" then
        if not TradeSkills.accountVars then return end
        local zoneId = GetZoneId(GetUnitZoneIndex("player"))
        local pins = TradeSkills.accountVars.herdPins[zoneId]
        if not pins or #pins == 0 then
            d("[TradeSkills] No herd pins in this zone.")
        else
            d("[TradeSkills] Herd pins in this zone:")
            for i, pin in ipairs(pins) do
                d("  " .. i .. ". " .. pin[3] .. " (" .. string.format("%.2f", pin[1]) .. ", " .. string.format("%.2f", pin[2]) .. ")")
            end
        end
    elseif string.find(cmd, "^heatpin add") then
        local label = string.match(cmd, "^heatpin add%s*(.*)")
        TradeSkills.Mining:AddHeatMapPin(label)
    elseif cmd == "heatpin remove" then
        TradeSkills.Mining:RemoveNearestHeatMapPin()
    elseif cmd == "heatpin clear" then
        TradeSkills.Mining:ClearAllHeatMapPins()
    elseif string.find(cmd, "^grovepin add") then
        local label = string.match(cmd, "^grovepin add%s*(.*)")
        TradeSkills.Woodcutting:AddGroveMapPin(label)
    elseif cmd == "grovepin remove" then
        TradeSkills.Woodcutting:RemoveNearestGroveMapPin()
    elseif cmd == "grovepin clear" then
        TradeSkills.Woodcutting:ClearAllGroveMapPins()
    elseif cmd == "heatpin list" then
        if not TradeSkills.accountVars then return end
        local mapId = GetCurrentMapId()
        local pins = TradeSkills.accountVars.heatMapPins and TradeSkills.accountVars.heatMapPins[mapId]
        if not pins or #pins == 0 then
            d("[TradeSkills] No heat map pins on this map.")
        else
            d("[TradeSkills] Heat map pins on this map:")
            for i, pin in ipairs(pins) do
                d("  " .. i .. ". " .. pin[3] .. " (" .. string.format("%.2f", pin[1]) .. ", " .. string.format("%.2f", pin[2]) .. ")")
            end
        end
    elseif string.sub(cmd, 1, 9) == "teststyle" then
        local styleIndex = tonumber(string.sub(cmd, 11)) or 1
        TradeSkills.StyleMastery:TestCompletionistPopup(styleIndex)
    elseif cmd == "debug perks" then
        local enabling = not TradeSkills.Fishing._debugPerks
        -- Toggle debug perks for all skills that have passive abilities
        TradeSkills.Fishing._debugPerks = enabling
        TradeSkills.Skinning._debugPerks = enabling
        TradeSkills.Brewing._debugPerks = enabling
        TradeSkills.Cooking._debugPerks = enabling
        TradeSkills.Mining._debugPerks = enabling
        TradeSkills.Carpentry._debugPerks = enabling
        TradeSkills.Woodcutting._debugPerks = enabling
        TradeSkills.StyleMastery._debugPerks = enabling
        TradeSkills.TraitMastery._debugPerks = enabling
        TradeSkills.Herbalism._debugPerks = enabling
        
        if enabling then
            d("[TradeSkills] All perks debug mode ENABLED - all passive abilities unlocked!")
            d("  Carpentry:")
            d("    Furniture Store (Lv 10): Active")
            d("  Style Mastery:")
            d("    Visual Completionist (Lv 5): Active")
            d("    Motif Map (Lv 10): Active")
            d("  Trait Mastery:")
            d("    Material Salvage Forecast (Lv 10): Active")
            d("  Herbalism:")
            d("    Flora ID (Lv 10): Active")
            d("    Greenhouse Tracker (Lv 25): Active")
            d("    Scent of the Wild (Lv 40): Active")
            d("  Fishing:")
            d("    Bait Master (Lv 10): Active")
            d("    Keen Angler (Lv 30): Active")
            d("    Reel Alert (Lv 50): Active")
            d("  Skinning:")
            d("    Beast Watch (Lv 10): Active")
            d("    Anatomy Specialist (Lv 30): Active")
            d("    Herd Map (Lv 50): Active")
            d("  Brewing:")
            d("    Quick Drink (Lv 10): Active")
            d("    Efficiency Calculator (Lv 30): Active")
            d("  Cooking:")
            d("    Quick Eat (Lv 10): Active")
            d("    Master Chef's Margin (Lv 30): Active")
            d("  Mining:")
            d("    Miner's Eye (Lv 10): Active")
            d("    Ore Tracker (Lv 30): Active")
            d("    Heat Map (Lv 50): Active")
            d("  Woodcutting:")
            d("    Timber Sense (Lv 10): Active")
            d("    Log Ledger (Lv 30): Active")
            d("    Grove Map (Lv 50): Active")
            -- Start Beast Watch if not already running
            TradeSkills.Skinning:StartBeastWatch()
            if not TradeSkills.Skinning._herdPinsInitialized then
                TradeSkills.Skinning:InitHerdMapPins()
            end
            TradeSkills.Skinning:RefreshHerdPins()
            if not TradeSkills.Mining._heatMapPinsInitialized then
                TradeSkills.Mining:InitHeatMapPins()
            end
            TradeSkills.Mining:RefreshHeatMapPins()
            if not TradeSkills.Woodcutting._groveMapPinsInitialized then
                TradeSkills.Woodcutting:InitGroveMapPins()
            end
            TradeSkills.Woodcutting:RefreshGroveMapPins()
            -- Start Cooking quickslot monitor
            TradeSkills.Cooking:StartQuickslotMonitor()
            TradeSkills.Brewing:StartQuickslotMonitor()
        else
            d("[TradeSkills] All perks debug mode DISABLED - perks require normal levels")
            TradeSkills.Skinning:StopBeastWatch()
            TradeSkills.Skinning:HideLootWindow()
            TradeSkills.Skinning:HideBeastIndicator()
        end
    end
end

-- Register keybinding strings for the Controls menu
ZO_CreateStringId("SI_BINDING_NAME_TRADESKILLS_ADD_HERD_PIN", "Add Herd Map Pin")
ZO_CreateStringId("SI_BINDING_NAME_TRADESKILLS_ADD_HEAT_MAP_PIN", "Add Heat Map Pin")
ZO_CreateStringId("SI_BINDING_NAME_TRADESKILLS_ADD_GROVE_MAP_PIN", "Add Grove Map Pin")

-- Register addon
EVENT_MANAGER:RegisterForEvent(TradeSkills.name, EVENT_ADD_ON_LOADED, TradeSkills.OnAddOnLoaded)
