TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}
local Crafting = {}
TetsuDailyWritPrecrafter.Crafting = Crafting

local Data
local stationKeybindDescriptor = nil
local craftingQueue = {}
local isCrafting = false
local currentQueueIndex = 0
local successCount = 0
local skipCount = 0
local waitingForCraft = false

local function L()
    return TetsuDailyWritPrecrafter.L
end

local function Chat(msg)
    if TetsuDailyWritPrecrafter.UI and TetsuDailyWritPrecrafter.UI.Chat then
        TetsuDailyWritPrecrafter.UI.Chat(msg)
    else
        d("|cFFD700[Tetsu's Daily Writ Precrafter]|r " .. tostring(msg))
    end
end

local function EnsureData()
    Data = TetsuDailyWritPrecrafter.Data
    return Data
end

--------------------------------------------------------------------------
-- Journal / quest helpers — match items to ACTIVE writ conditions
-- Critical: writ rotation is PER-CHARACTER, not global calendar day.
-- Always prefer DoesItemLinkFulfillJournalQuestCondition over predicted sets.
--------------------------------------------------------------------------

local MAIN_STEP = QUEST_MAIN_STEP_INDEX or 1

local function GetJournalConditionInfo(questIndex, conditionIndex)
    local text, current, maxVal, isFail, isComplete, isCreditShared, isVisible =
        GetJournalQuestConditionInfo(questIndex, MAIN_STEP, conditionIndex)
    return text, current or 0, maxVal or 0, isComplete, isVisible
end

local function LinkFulfillsAnyWrit(link)
    if not link or link == "" or not DoesItemLinkFulfillJournalQuestCondition then
        return false, nil, nil, 0
    end
    local maxQuests = MAX_JOURNAL_QUESTS or 25
    for qIndex = 1, maxQuests do
        if IsValidQuestIndex and IsValidQuestIndex(qIndex) and GetJournalQuestType(qIndex) == QUEST_TYPE_CRAFTING then
            local numConditions = GetJournalQuestNumConditions(qIndex, MAIN_STEP) or 0
            for cIndex = 1, numConditions do
                local _, current, maxVal, isComplete, isVisible = GetJournalConditionInfo(qIndex, cIndex)
                if isVisible ~= false and not isComplete and (current or 0) < (maxVal or 1) then
                    local ok = false
                    -- Try with isSelfCrafted = true first (normal), then false
                    local success, result = pcall(DoesItemLinkFulfillJournalQuestCondition, link, qIndex, MAIN_STEP, cIndex, true)
                    if success and result then ok = true end
                    if not ok then
                        success, result = pcall(DoesItemLinkFulfillJournalQuestCondition, link, qIndex, MAIN_STEP, cIndex)
                        if success and result then ok = true end
                    end
                    if ok then
                        local remaining = (maxVal or 1) - (current or 0)
                        if remaining < 1 then remaining = 1 end
                        return true, qIndex, cIndex, remaining
                    end
                end
            end
        end
    end
    return false, nil, nil, 0
end

-- Walk every smithing pattern at current material rank; keep those that fulfill the writ.
local function ResolveSmithingFromQuest(craftType, materialIndex)
    local resolved = {}
    local numPatterns = GetNumSmithingPatterns and GetNumSmithingPatterns() or 0
    if numPatterns == 0 then return resolved end

    local seen = {}
    for patternIndex = 1, numPatterns do
        local styleId = 0
        if craftType ~= Data.CRAFT_JEWELRY and craftType ~= 7 then
            styleId = Data.GetAvailableStyleId(patternIndex) or 1
        end
        local qty = Data.GetRequiredMaterialQuantity(patternIndex, materialIndex)
        if not qty or qty < 1 then qty = (craftType == Data.CRAFT_JEWELRY or craftType == 7) and 10 or 7 end

        local link = Data.GetSmithingResultLink(patternIndex, materialIndex, qty, styleId)
        if link and link ~= "" then
            local ok, _, cIndex, remaining = LinkFulfillsAnyWrit(link)
            if ok then
                local key = tostring(patternIndex) .. ":" .. tostring(cIndex)
                if not seen[key] then
                    seen[key] = true
                    for n = 1, remaining do
                        resolved[#resolved + 1] = {
                            craftType = craftType,
                            patternIndex = patternIndex,
                            materialIndex = materialIndex,
                            materialQuantity = qty,
                            styleId = styleId,
                        }
                    end
                end
            end
        end
    end
    return resolved
end

local function ResolveEnchantingFromQuest(potencyTier)
    local resolved = {}
    local potencyIds = {}
    local function addPot(id)
        if not id then return end
        for i = 1, #potencyIds do
            if potencyIds[i] == id then return end
        end
        potencyIds[#potencyIds + 1] = id
    end
    addPot(Data.EnchantingPotencyAlt and Data.EnchantingPotencyAlt[10])
    addPot(Data.EnchantingPotency[10])
    addPot(Data.EnchantingPotency[potencyTier])
    if Data.EnchantingPotencyAlt then addPot(Data.EnchantingPotencyAlt[potencyTier]) end

    local aBag, aSlot = Data.FindItemInBags(Data.ASPECT_TA)
    if not aBag then return resolved end

    for p = 1, #potencyIds do
        local potencyId = potencyIds[p]
        local pBag, pSlot = Data.FindItemInBags(potencyId)
        if pBag then
            for e = 1, #(Data.EnchantingEssences or {}) do
                local essenceId = Data.EnchantingEssences[e]
                local eBag, eSlot = Data.FindItemInBags(essenceId)
                if eBag and GetEnchantingResultingItemLink then
                    local link = GetEnchantingResultingItemLink(pBag, pSlot, eBag, eSlot, aBag, aSlot, LINK_STYLE_DEFAULT)
                    local ok, _, _, remaining = LinkFulfillsAnyWrit(link)
                    if ok then
                        for n = 1, remaining do
                            resolved[#resolved + 1] = {
                                craftType = Data.CRAFT_ENCHANTING,
                                potencyId = potencyId,
                                essenceId = essenceId,
                                aspectId = Data.ASPECT_TA,
                            }
                        end
                        return resolved
                    end
                end
            end
        end
    end
    return resolved
end

-- Detect which pattern-set (1/2/3) matches the active quest, by comparing resolved patternIndices.
local function DetectPhaseFromResolved(craftType, resolved)
    if not resolved or #resolved == 0 then return nil end
    local counts = {}
    for i = 1, #resolved do
        local pi = resolved[i].patternIndex
        if pi then counts[pi] = (counts[pi] or 0) + 1 end
    end
    local sets = Data.Patterns[craftType]
    if not sets then return nil end

    local bestIdx, bestScore = nil, -1
    for setIdx = 1, 3 do
        local set = sets[setIdx]
        if set then
            local need = {}
            for j = 1, #set do
                need[set[j]] = (need[set[j]] or 0) + 1
            end
            local score = 0
            local mismatch = false
            for pi, n in pairs(need) do
                local have = counts[pi] or 0
                if have > 0 then score = score + math.min(have, n) end
                -- don't require exact match (quest may be partially done)
            end
            -- prefer sets that cover all resolved patterns
            local covered = true
            for pi, _ in pairs(counts) do
                if not need[pi] then covered = false break end
            end
            if covered then score = score + 10 end
            if score > bestScore then
                bestScore = score
                bestIdx = setIdx
            end
        end
    end
    return bestIdx
end

local function JobsFromPatternList(craftType, patternList, materialIndex)
    local jobs = {}
    if not patternList then return jobs end
    for i = 1, #patternList do
        local patternIndex = patternList[i]
        local qty = Data.GetRequiredMaterialQuantity(patternIndex, materialIndex)
        local styleId = 0
        if craftType ~= Data.CRAFT_JEWELRY and craftType ~= 7 then
            styleId = Data.GetAvailableStyleId(patternIndex) or 1
        end
        jobs[#jobs + 1] = {
            craftType = craftType,
            patternIndex = patternIndex,
            materialIndex = materialIndex,
            materialQuantity = qty,
            styleId = styleId or 0,
        }
    end
    return jobs
end

--------------------------------------------------------------------------
-- Pre-craft job builders
--------------------------------------------------------------------------

local function BuildPrecraftEquipmentJobs(craftType, days, startPhase)
    local jobs = {}
    local tier = Data.GetCraftingTier(craftType)
    local stationPatterns = Data.Patterns[craftType]
    if not stationPatterns then return jobs end
    local materialIndex = Data.GetMaterialIndex(craftType, tier)

    -- startPhase 1..3; if unknown, craft ALL three sets once (safe coverage)
    if not startPhase or startPhase < 1 or startPhase > 3 then
        for setIdx = 1, 3 do
            local patterns = stationPatterns[setIdx] or {}
            if craftType == Data.CRAFT_ENCHANTING or craftType == 3 then
                local potencyId = Data.EnchantingPotency[tier] or 45855
                for i = 1, #patterns do
                    jobs[#jobs + 1] = {
                        craftType = craftType,
                        potencyId = potencyId,
                        essenceId = patterns[i],
                        aspectId = Data.ASPECT_TA,
                    }
                end
            else
                local part = JobsFromPatternList(craftType, patterns, materialIndex)
                for i = 1, #part do jobs[#jobs + 1] = part[i] end
            end
        end
        return jobs
    end

    for offset = 0, days - 1 do
        local dayIdx = ((startPhase - 1 + offset) % 3) + 1
        local patterns = stationPatterns[dayIdx] or {}
        if craftType == Data.CRAFT_ENCHANTING or craftType == 3 then
            local potencyId = Data.EnchantingPotency[tier] or 45855
            for i = 1, #patterns do
                jobs[#jobs + 1] = {
                    craftType = craftType,
                    potencyId = potencyId,
                    essenceId = patterns[i],
                    aspectId = Data.ASPECT_TA,
                    dayOffset = offset,
                }
            end
        else
            local part = JobsFromPatternList(craftType, patterns, materialIndex)
            for i = 1, #part do
                part[i].dayOffset = offset
                jobs[#jobs + 1] = part[i]
            end
        end
    end
    return jobs
end

local function BuildPrecraftAlchemyJobs()
    local tier = Data.GetCraftingTier(4)
    return Data.GetAlchemyJobsForTier(tier, 5)
end

local function BuildPrecraftProvisioningJobs()
    local tier = Data.GetCraftingTier(5)
    local allianceId = GetUnitAlliance and GetUnitAlliance("player") or 0
    local recipeMap = Data.BuildRecipeMapByIngredients and Data.BuildRecipeMapByIngredients() or {}
    return Data.GetProvisioningJobsForChar(tier, allianceId, recipeMap, 5)
end

--------------------------------------------------------------------------
-- Public: build the list the station should craft right now
--------------------------------------------------------------------------

function Crafting.GetRequiredItemsForStation(craftType)
    EnsureData()
    local cs = TetsuDailyWritPrecrafter.GetCharSettings and TetsuDailyWritPrecrafter.GetCharSettings()
    local preCraft = cs and cs.preCraftEnabled == true
    local days = (cs and cs.preCraftDays) or 3
    if days < 1 then days = 1 end
    if days > 10 then days = 10 end

    local jobs = {}
    local mode = "none"
    local phase = nil

    -- Always try to resolve from active quest first (correct items + quantities)
    local questJobs = {}
    if craftType == 4 or craftType == Data.CRAFT_ALCHEMY then
        -- Alchemy: quest rarely exposes item links cleanly; use restore set for current tier
        if not preCraft then
            local tier = Data.GetCraftingTier(4)
            questJobs = Data.GetAlchemyJobsForTier(tier, 1)
        end
    elseif craftType == 5 or craftType == Data.CRAFT_PROVISIONING then
        if not preCraft then
            local tier = Data.GetCraftingTier(5)
            local allianceId = GetUnitAlliance and GetUnitAlliance("player") or 0
            local recipeMap = Data.BuildRecipeMapByIngredients and Data.BuildRecipeMapByIngredients() or {}
            local all = Data.GetProvisioningJobsForChar(tier, allianceId, recipeMap, 1)
            for i = 1, #all do
                if all[i].recipeKnown then questJobs[#questJobs + 1] = all[i] end
            end
        end
    elseif craftType == Data.CRAFT_ENCHANTING or craftType == 3 then
        local tier = Data.GetCraftingTier(craftType)
        questJobs = ResolveEnchantingFromQuest(tier)
    else
        local tier = Data.GetCraftingTier(craftType)
        local materialIndex = Data.GetMaterialIndex(craftType, tier)
        questJobs = ResolveSmithingFromQuest(craftType, materialIndex)
        phase = DetectPhaseFromResolved(craftType, questJobs)
        -- Remember phase for this character so pre-craft can cycle correctly
        if phase and cs then
            cs.writPhase = cs.writPhase or {}
            cs.writPhase[craftType] = phase
        end
    end

    if preCraft then
        mode = "precraft"
        if craftType == 4 or craftType == Data.CRAFT_ALCHEMY then
            jobs = BuildPrecraftAlchemyJobs()
        elseif craftType == 5 or craftType == Data.CRAFT_PROVISIONING then
            jobs = BuildPrecraftProvisioningJobs()
        else
            local savedPhase = phase
            if not savedPhase and cs and cs.writPhase then
                savedPhase = cs.writPhase[craftType]
            end
            jobs = BuildPrecraftEquipmentJobs(craftType, days, savedPhase)
        end
    else
        mode = "quest"
        jobs = questJobs
    end

    return jobs or {}, mode, (preCraft and days or 1)
end


--------------------------------------------------------------------------
-- Filter already owned (simple version)
--------------------------------------------------------------------------

local function FilterAlreadyOwned(jobs, craftType)
    if not jobs or #jobs == 0 then return jobs end
    -- For pre-craft we still craft even if some exist (player may want more days).
    -- Only skip exact duplicates when in quest mode would be ideal; keep simple for now.
    return jobs
end

--------------------------------------------------------------------------
-- Material pre-check
--------------------------------------------------------------------------

local function CountItem(itemId)
    if not itemId or itemId <= 0 then return 0 end
    return Data.CountItemById(itemId, false) or 0
end

local function CheckMaterialsForJobs(itemsList, craftType)
    local need = {} -- itemId -> { name, amount }
    local function addNeed(itemId, name, amount)
        if not itemId or itemId <= 0 or not amount or amount <= 0 then return end
        if not need[itemId] then
            need[itemId] = { name = name or ("#" .. tostring(itemId)), amount = 0 }
        end
        need[itemId].amount = need[itemId].amount + amount
    end

    for i = 1, #itemsList do
        local job = itemsList[i]
        if craftType == 4 or craftType == Data.CRAFT_ALCHEMY then
            if job.solventIds then
                for s = 1, #job.solventIds do
                    addNeed(job.solventIds[s], "solvent", 1)
                end
            end
            addNeed(job.reagent1Id, "reagent1", 1)
            addNeed(job.reagent2Id, "reagent2", 1)
        elseif craftType == 5 or craftType == Data.CRAFT_PROVISIONING then
            -- Ingredients checked via recipe knowledge; skip detailed mat check if known
        elseif craftType == Data.CRAFT_ENCHANTING or craftType == 3 then
            addNeed(job.potencyId, "potency", 1)
            addNeed(job.essenceId, "essence", 1)
            addNeed(job.aspectId or Data.ASPECT_TA, "Ta", 1)
        else
            local matId = Data.GetMaterialItemId(job.patternIndex, job.materialIndex)
            if matId then
                addNeed(matId, "material", job.materialQuantity or 7)
            end
            if job.styleId and job.styleId > 0 then
                local styleMatId = Data.GetStyleMaterialItemId(job.styleId)
                if styleMatId then
                    addNeed(styleMatId, "style", 1)
                end
            end
        end
    end

    local missing = {}
    for itemId, info in pairs(need) do
        local have = CountItem(itemId)
        if have < info.amount then
            missing[#missing + 1] = {
                name = info.name,
                need = info.amount,
                have = have,
                deficit = info.amount - have,
            }
        end
    end
    return missing
end

local function CountSlotsNeeded(itemsList, craftType)
    if craftType == 4 or craftType == Data.CRAFT_ALCHEMY or craftType == 5 or craftType == Data.CRAFT_PROVISIONING then
        -- Stackable – roughly 1 slot per unique product type
        return math.max(3, math.ceil(#itemsList / 5))
    end
    return #itemsList -- equipment / glyphs do not stack
end

--------------------------------------------------------------------------
-- Craft execution
--------------------------------------------------------------------------

local function CanCraftSmithing(item)
    if not item.patternIndex then return false end
    local styleId = item.styleId or 0
    if item.craftType ~= Data.CRAFT_JEWELRY and item.craftType ~= 7 then
        if not styleId or styleId < 1 then return false end
    end
    return true
end

local function FinishQueue()
    isCrafting = false
    waitingForCraft = false
    craftingQueue = {}
    currentQueueIndex = 0
    if TetsuDailyWritPrecrafter.UI and TetsuDailyWritPrecrafter.UI.HideProgress then
        TetsuDailyWritPrecrafter.UI.HideProgress()
    end
    Chat(zo_strformat(L().CRAFT_DONE, successCount, skipCount))
    successCount = 0
    skipCount = 0
    EVENT_MANAGER:UnregisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_COMPLETED)
    EVENT_MANAGER:UnregisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_FAILED)
    -- Re-show keybind after a short delay
    zo_callLater(function()
        if GetCraftingInteractionType and GetCraftingInteractionType() ~= 0 then
            Crafting.AddStationKeybind()
        end
    end, 400)
end

local function ProcessNextCraftItem()
    if not isCrafting then return end
    currentQueueIndex = currentQueueIndex + 1
    if currentQueueIndex > #craftingQueue then
        FinishQueue()
        return
    end

    local item = craftingQueue[currentQueueIndex]
    if TetsuDailyWritPrecrafter.UI and TetsuDailyWritPrecrafter.UI.UpdateProgress then
        TetsuDailyWritPrecrafter.UI.UpdateProgress(currentQueueIndex, #craftingQueue)
    end

    local craftType = item.craftType or GetCraftingInteractionType()

    -- Alchemy
    if craftType == 4 or craftType == Data.CRAFT_ALCHEMY then
        local sBag, sSlot
        if item.solventIds then
            for i = 1, #item.solventIds do
                sBag, sSlot = Data.FindItemInBags(item.solventIds[i])
                if sBag then break end
            end
        end
        local r1Bag, r1Slot = Data.FindItemInBags(item.reagent1Id)
        local r2Bag, r2Slot = Data.FindItemInBags(item.reagent2Id)
        if not sBag or not r1Bag or not r2Bag then
            skipCount = skipCount + 1
            Chat(zo_strformat(L().ERR_CANNOT_CRAFT, item.recipeName or "Alchemy"))
            zo_callLater(ProcessNextCraftItem, 150)
            return
        end
        waitingForCraft = true
        if CraftAlchemyItem then
            CraftAlchemyItem(sBag, sSlot, r1Bag, r1Slot, r2Bag, r2Slot, nil, nil, 1)
        else
            waitingForCraft = false
            skipCount = skipCount + 1
            zo_callLater(ProcessNextCraftItem, 150)
        end
        return
    end

    -- Provisioning
    if craftType == 5 or craftType == Data.CRAFT_PROVISIONING then
        if not item.recipeKnown or not item.recipeListIndex or not item.recipeIndex then
            skipCount = skipCount + 1
            Chat(zo_strformat(L().ERR_PROV_SKIP_UNKNOWN, item.name or "?"))
            zo_callLater(ProcessNextCraftItem, 150)
            return
        end
        waitingForCraft = true
        if CraftProvisionerItem then
            CraftProvisionerItem(item.recipeListIndex, item.recipeIndex, 1)
        else
            waitingForCraft = false
            skipCount = skipCount + 1
            zo_callLater(ProcessNextCraftItem, 150)
        end
        return
    end

    -- Enchanting
    if craftType == Data.CRAFT_ENCHANTING or craftType == 3 then
        local pBag, pSlot = Data.FindItemInBags(item.potencyId)
        local eBag, eSlot = Data.FindItemInBags(item.essenceId)
        local aBag, aSlot = Data.FindItemInBags(item.aspectId or Data.ASPECT_TA)
        if not pBag or not eBag or not aBag then
            skipCount = skipCount + 1
            Chat(L().ERR_MISSING_RUNES)
            zo_callLater(ProcessNextCraftItem, 150)
            return
        end
        waitingForCraft = true
        if CraftEnchantingItem then
            CraftEnchantingItem(pBag, pSlot, eBag, eSlot, aBag, aSlot)
        else
            waitingForCraft = false
            skipCount = skipCount + 1
            zo_callLater(ProcessNextCraftItem, 150)
        end
        return
    end

    -- Smithing / Clothing / Woodworking / Jewelry
    if not CanCraftSmithing(item) then
        skipCount = skipCount + 1
        Chat(zo_strformat(L().ERR_CANNOT_CRAFT, "equipment"))
        zo_callLater(ProcessNextCraftItem, 150)
        return
    end
    local trait = 1 -- no trait
    waitingForCraft = true
    if CraftSmithingItem then
        CraftSmithingItem(
            item.patternIndex,
            item.materialIndex,
            item.materialQuantity,
            item.styleId or 0,
            trait,
            false -- useItemSet?
        )
    else
        waitingForCraft = false
        skipCount = skipCount + 1
        zo_callLater(ProcessNextCraftItem, 150)
    end
end

local function OnCraftCompleted()
    if not waitingForCraft then return end
    waitingForCraft = false
    successCount = successCount + 1
    zo_callLater(ProcessNextCraftItem, 350)
end

local function OnCraftFailed()
    if not waitingForCraft then return end
    waitingForCraft = false
    skipCount = skipCount + 1
    Chat(zo_strformat(L().ERR_CRAFT_FAILED, currentQueueIndex, #craftingQueue))
    zo_callLater(ProcessNextCraftItem, 350)
end

function Crafting.ExecuteBulkCraft(itemsList, craftType)
    if isCrafting then return end
    if not itemsList or #itemsList == 0 then
        Chat(L().ERR_NOTHING_TO_CRAFT)
        return
    end

    EnsureData()

    -- Bag space check
    local slotsNeeded = CountSlotsNeeded(itemsList, craftType)
    local freeSlots = GetBagSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK)
    if freeSlots < slotsNeeded then
        Chat(zo_strformat(L().ERR_BAG_FULL, slotsNeeded))
        return
    end

    -- Material pre-check
    local missing = CheckMaterialsForJobs(itemsList, craftType)
    if #missing > 0 then
        Chat(L().PRECHECK_HEADER)
        Chat(zo_strformat(L().PRECHECK_JOBS, #itemsList))
        for i = 1, math.min(8, #missing) do
            local m = missing[i]
            Chat(zo_strformat(L().PRECHECK_LINE, m.name, m.need, m.have, m.deficit))
        end
        Chat(L().PRECHECK_ABORT)
        return
    end

    Chat(zo_strformat(L().PRECHECK_OK, #itemsList))

    craftingQueue = itemsList
    currentQueueIndex = 0
    successCount = 0
    skipCount = 0
    isCrafting = true
    waitingForCraft = false

    Crafting.RemoveStationKeybind()

    if TetsuDailyWritPrecrafter.UI and TetsuDailyWritPrecrafter.UI.ShowProgress then
        TetsuDailyWritPrecrafter.UI.ShowProgress(#itemsList)
    end

    EVENT_MANAGER:RegisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_COMPLETED, OnCraftCompleted)
    EVENT_MANAGER:RegisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_FAILED, OnCraftFailed)

    ProcessNextCraftItem()
end

--------------------------------------------------------------------------
-- Keybind strip (R3)
--------------------------------------------------------------------------

function Crafting.AddStationKeybind()
    EnsureData()
    local craftType = GetCraftingInteractionType()
    if not craftType or craftType == 0 then
        Crafting.RemoveStationKeybind()
        return
    end

    -- No longer require maxed skill – each character crafts at their own rank
    local items, mode, days = Crafting.GetRequiredItemsForStation(craftType)
    Crafting._cachedStationType = craftType
    Crafting._cachedStationItems = items
    Crafting._cachedMode = mode
    Crafting._cachedDays = days

    if #items == 0 then
        -- Still show a disabled-looking keybind? Prefer hide.
        Crafting.RemoveStationKeybind()
        return
    end

    if stationKeybindDescriptor then
        KEYBIND_STRIP:UpdateKeybindButton(stationKeybindDescriptor)
        return
    end

    local cachedCount = #items
    local cachedMode = mode
    local cachedDays = days

    stationKeybindDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        name = function()
            if cachedMode == "precraft" then
                return zo_strformat(L().KEYBIND_PRECRAFT, cachedDays, cachedCount)
            end
            return zo_strformat(L().KEYBIND_QUEST_CRAFT, cachedCount)
        end,
        keybind = "UI_SHORTCUT_RIGHT_STICK",
        order = 500,
        visible = function()
            if isCrafting then return false end
            local cType = GetCraftingInteractionType()
            return cType and cType ~= 0
        end,
        callback = function()
            local cType = GetCraftingInteractionType()
            if not cType or cType == 0 then
                if TetsuDailyWritPrecrafter.UI and TetsuDailyWritPrecrafter.UI.AlertError then
                    TetsuDailyWritPrecrafter.UI.AlertError(L().ERR_NOT_AT_STATION)
                end
                return
            end
            local curItems, curMode, curDays = Crafting.GetRequiredItemsForStation(cType)
            cachedCount = #curItems
            cachedMode = curMode
            cachedDays = curDays
            if #curItems == 0 then
                if curMode == "quest" then
                    Chat(L().ERR_NO_ACTIVE_WRIT)
                else
                    Chat(L().ERR_NOTHING_TO_CRAFT)
                end
                return
            end
            if curMode == "precraft" then
                Chat(zo_strformat(L().USING_PREDICTED, curDays))
            else
                Chat(L().USING_QUEST_DATA)
            end
            local patternNames = { "A", "B", "C" }
            local today = Data.GetTodayPatternIndex()
            Chat(zo_strformat(L().PATTERN_TODAY, patternNames[today] or today))

            if TetsuDailyWritPrecrafter.UI and TetsuDailyWritPrecrafter.UI.ShowConfirmationDialog then
                TetsuDailyWritPrecrafter.UI.ShowConfirmationDialog(#curItems, function()
                    Crafting.ExecuteBulkCraft(curItems, cType)
                end, curMode == "precraft")
            else
                Crafting.ExecuteBulkCraft(curItems, cType)
            end
        end,
    }
    pcall(function()
        KEYBIND_STRIP:AddKeybindButton(stationKeybindDescriptor)
    end)
end

function Crafting.RemoveStationKeybind()
    pcall(function() EVENT_MANAGER:UnregisterForUpdate("TDWP_KeybindRefresh") end)
    local D = EnsureData and EnsureData() or TetsuDailyWritPrecrafter.Data
    if D and D.ClearRecipeCache then
        pcall(D.ClearRecipeCache)
    end
    Crafting._cachedStationItems = nil
    Crafting._cachedStationType = nil
    Crafting._cachedMode = nil
    if stationKeybindDescriptor then
        pcall(function()
            if KEYBIND_STRIP and KEYBIND_STRIP.RemoveKeybindButton then
                KEYBIND_STRIP:RemoveKeybindButton(stationKeybindDescriptor)
            end
        end)
        stationKeybindDescriptor = nil
    end
end
