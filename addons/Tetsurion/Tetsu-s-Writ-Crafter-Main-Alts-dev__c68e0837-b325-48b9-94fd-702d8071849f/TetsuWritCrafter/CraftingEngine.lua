TetsuWritCrafter = TetsuWritCrafter or {}
local Crafting = {}
TetsuWritCrafter.Crafting = Crafting

local stationKeybindDescriptor = nil
local craftingQueue = {}
local isCrafting = false
local currentQueueIndex = 0

local function GetSkillTierKey(craftType)
    if craftType == CRAFTING_TYPE_BLACKSMITHING then return "blacksmithingTier", 1
    elseif craftType == CRAFTING_TYPE_CLOTHING then return "clothingTier", 2
    elseif craftType == CRAFTING_TYPE_WOODWORKING then return "woodworkingTier", 6
    elseif craftType == CRAFTING_TYPE_ENCHANTING then return "enchantingTier", 3
    elseif craftType == CRAFTING_TYPE_JEWELRYCRAFTING then return "jewelryTier", 7
    end
    return nil, nil
end

local function CanCurrentCharacterCraft(craftType)
    local _, skillIndex = GetSkillTierKey(craftType)
    if not skillIndex then return false end
    local currentLevel, maxLevel = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, skillIndex, 1)
    if not currentLevel or not maxLevel then return false end
    return currentLevel == maxLevel
end

function Crafting.GetRequiredItemsForStation(craftType)
    local vars = TetsuWritCrafter.savedVars
    if not vars or not vars.characters or not TetsuWritCrafter.Data or not TetsuWritCrafter.Data.Patterns then 
        return {} 
    end

    local currentName = zo_strformat("<<1>>", GetUnitName("player"))
    local todayKey = TetsuWritCrafter.Data.GetTodayPatternIndex()
    
    vars.dailyCrafted = vars.dailyCrafted or {}
    if vars.dailyCrafted[todayKey] and vars.dailyCrafted[todayKey][craftType] then
        return {}
    end

    local stationPatterns = TetsuWritCrafter.Data.Patterns[craftType]
    if not stationPatterns then return {} end

    local currentDayPattern = stationPatterns[todayKey] or {}
    local tierKey, skillIdx = GetSkillTierKey(craftType)
    local myTier = skillIdx and (GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, skillIdx, 1) or 1) or 1
    local requiredList = {}

    -- 1. Предметы для текущего мастера
    for _, patternId in ipairs(currentDayPattern) do
        table.insert(requiredList, { craftType = craftType, patternId = patternId, tier = myTier, isForAlt = false })
    end

    -- 2. Предметы для активных твинков
    for charName, charData in pairs(vars.characters) do
        if type(charData) == "table" and charName ~= currentName and charData.enabled and charData.isScanned then
            local altTier = (tierKey and charData[tierKey]) or 1
            for _, patternId in ipairs(currentDayPattern) do
                table.insert(requiredList, { craftType = craftType, patternId = patternId, tier = altTier, isForAlt = true, targetChar = charName })
            end
        end
    end

    return requiredList
end

local function ProcessNextCraftItem()
    currentQueueIndex = currentQueueIndex + 1
    if currentQueueIndex > #craftingQueue then
        isCrafting = false
        EVENT_MANAGER:UnregisterForEvent("TWC_CraftEngine", EVENT_CRAFT_COMPLETED)
        EVENT_MANAGER:UnregisterForEvent("TWC_CraftEngine", EVENT_CRAFT_FAILED)
        EVENT_MANAGER:UnregisterForUpdate("TWC_CraftTimeout")
        TetsuWritCrafter.UI.HideProgress()

        local vars = TetsuWritCrafter.savedVars
        local todayKey = TetsuWritCrafter.Data.GetTodayPatternIndex()
        local cType = GetCraftingInteractionType()
        vars.dailyCrafted = vars.dailyCrafted or {}
        vars.dailyCrafted[todayKey] = vars.dailyCrafted[todayKey] or {}
        vars.dailyCrafted[todayKey][cType] = true

        Crafting.RemoveStationKeybind()
        return
    end

    local item = craftingQueue[currentQueueIndex]
    TetsuWritCrafter.UI.UpdateProgress(TetsuWritCrafter.L.PROGRESS_CRAFTING, currentQueueIndex, #craftingQueue)

    EVENT_MANAGER:RegisterForUpdate("TWC_CraftTimeout", 2500, function()
        EVENT_MANAGER:UnregisterForUpdate("TWC_CraftTimeout")
        ProcessNextCraftItem()
    end)

    if item.craftType == CRAFTING_TYPE_ENCHANTING then
        local potencyId = TetsuWritCrafter.Data.EnchantingPotency[item.tier] or 68342
        local essenceId = item.patternId
        local aspectId  = 45850 -- Ta

        local pBag, pSlot = TetsuWritCrafter.Data.FindItemInBags(potencyId)
        local eBag, eSlot = TetsuWritCrafter.Data.FindItemInBags(essenceId)
        local aBag, aSlot = TetsuWritCrafter.Data.FindItemInBags(aspectId)

        if pBag and eBag and aBag then
            CraftEnchantingItem(pBag, pSlot, eBag, eSlot, aBag, aSlot)
        else
            ProcessNextCraftItem()
        end
    else
        local styleIndex = (item.craftType == CRAFTING_TYPE_JEWELRYCRAFTING) and 0 or TetsuWritCrafter.Data.GetAvailableStyleIndex()
        local _, _, numMats = GetSmithingPatternMaterialItemInfo(item.patternId, item.tier)
        CraftSmithingItem(item.patternId, item.tier, numMats or 1, styleIndex, 0, false, 0, 0, 0)
    end
end

local function OnCraftFinished()
    EVENT_MANAGER:UnregisterForUpdate("TWC_CraftTimeout")
    zo_callLater(ProcessNextCraftItem, 60)
end

function Crafting.ExecuteBulkCraft(itemsList, craftType)
    local L = TetsuWritCrafter.L
    local freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)
    if freeSlots < #itemsList then
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, zo_strformat(L.ERR_BAG_FULL, #itemsList, freeSlots))
        return
    end

    craftingQueue = itemsList
    currentQueueIndex = 0
    isCrafting = true

    EVENT_MANAGER:RegisterForEvent("TWC_CraftEngine", EVENT_CRAFT_COMPLETED, OnCraftFinished)
    EVENT_MANAGER:RegisterForEvent("TWC_CraftEngine", EVENT_CRAFT_FAILED, OnCraftFinished)

    ProcessNextCraftItem()
end

function Crafting.AddStationKeybind()
    local craftType = GetCraftingInteractionType()
    if not craftType or craftType == CRAFTING_TYPE_INVALID or not CanCurrentCharacterCraft(craftType) then
        Crafting.RemoveStationKeybind()
        return
    end

    local items = Crafting.GetRequiredItemsForStation(craftType)
    if #items == 0 then
        Crafting.RemoveStationKeybind()
        return
    end

    if stationKeybindDescriptor then
        KEYBIND_STRIP:UpdateKeybindButton(stationKeybindDescriptor)
        return
    end

    local L = TetsuWritCrafter.L
    stationKeybindDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        name = function()
            local curItems = Crafting.GetRequiredItemsForStation(GetCraftingInteractionType())
            return zo_strformat(L.KEYBIND_CRAFT_ALL, #curItems)
        end,
        keybind = "UI_SHORTCUT_RIGHT_STICK",
        visible = function()
            local cType = GetCraftingInteractionType()
            return cType and cType ~= CRAFTING_TYPE_INVALID and CanCurrentCharacterCraft(cType) and #Crafting.GetRequiredItemsForStation(cType) > 0
        end,
        callback = function()
            local cType = GetCraftingInteractionType()
            local curItems = Crafting.GetRequiredItemsForStation(cType)
            if #curItems > 0 then
                TetsuWritCrafter.UI.ShowConfirmationDialog(#curItems, function()
                    Crafting.ExecuteBulkCraft(curItems, cType)
                end)
            end
        end,
    }
    KEYBIND_STRIP:AddKeybindButton(stationKeybindDescriptor)
end

function Crafting.RemoveStationKeybind()
    if stationKeybindDescriptor then
        KEYBIND_STRIP:RemoveKeybindButton(stationKeybindDescriptor)
        stationKeybindDescriptor = nil
    end
end