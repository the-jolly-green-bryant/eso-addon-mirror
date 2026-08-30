TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}
local Crafting = {}
TetsuDailyWritPrecrafter.Crafting = Crafting

function Crafting.IsBusy()
    return isCrafting == true
end

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

local function ChatInfo(msg)
    local vars = TetsuDailyWritPrecrafter.savedVars
    if vars and vars.quietInfo == true then
        return
    end
    Chat(msg)
end

local function LeaveCraftingStation()
    zo_callLater(function()
        pcall(function()
            if EndInteraction and INTERACTION_CRAFT then
                EndInteraction(INTERACTION_CRAFT)
            end
        end)
        pcall(function()
            if EndCraftingInteraction then
                EndCraftingInteraction()
            end
        end)
    end, 500)
end

local function StopStationGuard()
    pcall(function() EVENT_MANAGER:UnregisterForUpdate("TDWP_StationGuard") end)
end

function Crafting.AbortBecauseStationClosed()
    local wasRunning = isCrafting or waitingForCraft
    StopStationGuard()
    pcall(function() EVENT_MANAGER:UnregisterForUpdate("TDWP_CraftWatch") end)
    isCrafting = false
    waitingForCraft = false
    craftingQueue = {}
    currentQueueIndex = 0
    successCount = 0
    skipCount = 0
    Crafting._stationLock = false
    if TetsuDailyWritPrecrafter.UI and TetsuDailyWritPrecrafter.UI.HideProgress then
        TetsuDailyWritPrecrafter.UI.HideProgress()
    end
    pcall(function() EVENT_MANAGER:UnregisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_COMPLETED) end)
    pcall(function() EVENT_MANAGER:UnregisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_FAILED) end)
    if wasRunning then
        Chat(L().ERR_STATION_CLOSED or "Craft cancelled: left the station. Open it again and press R3 to restart.")
    end
end

local function StartStationGuard()
    StopStationGuard()
    EVENT_MANAGER:RegisterForUpdate("TDWP_StationGuard", 150, function()
        if not isCrafting and not waitingForCraft then
            StopStationGuard()
            return
        end
        local t = GetCraftingInteractionType and GetCraftingInteractionType() or 0
        if t == 0 then
            Crafting.AbortBecauseStationClosed()
        end
    end)
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
                    -- Match original Lazy Writ order: no isSelfCrafted flag first
                    local success, result = pcall(DoesItemLinkFulfillJournalQuestCondition, link, qIndex, MAIN_STEP, cIndex)
                    if success and result then ok = true end
                    if not ok then
                        success, result = pcall(DoesItemLinkFulfillJournalQuestCondition, link, qIndex, MAIN_STEP, cIndex, true)
                        if success and result then ok = true end
                    end
                    if not ok then
                        success, result = pcall(DoesItemLinkFulfillJournalQuestCondition, link, qIndex, MAIN_STEP, cIndex, false)
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

    local seenCond = {} -- conditionIndex already fully queued
    for patternIndex = 1, numPatterns do
        local styleId = 0
        if craftType ~= Data.CRAFT_JEWELRY and craftType ~= 7 then
            styleId = Data.GetAvailableStyleId(patternIndex) or 1
        end
        local qtyList
        if craftType == Data.CRAFT_JEWELRY or craftType == 7 then
            -- Lowest ounces first = CP150 platinum, not the CP160 row (10x mats)
            qtyList = { 6, 7, 8, 9, 10, 11, 12, 13, 15 }
        else
            local qty = Data.GetRequiredMaterialQuantity(patternIndex, materialIndex)
            if not qty or qty < 1 then qty = 7 end
            qtyList = { qty }
        end

        local matched = false
        for qi = 1, #qtyList do
            if matched then break end
            local qty = qtyList[qi]
            local link = Data.GetSmithingResultLink(patternIndex, materialIndex, qty, styleId)
            if link and link ~= "" then
                local ok, _, cIndex, remaining = LinkFulfillsAnyWrit(link)
                if ok and cIndex and not seenCond[cIndex] then
                    seenCond[cIndex] = true
                    matched = true
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

-- Jewelry writ text fallback (works even on Refine tab where GetNumSmithingPatterns==0)
local function ParseJewelryWritFromText()
    local maxQ = MAX_JOURNAL_QUESTS or 25
    for q = 1, maxQ do
        if IsValidQuestIndex and IsValidQuestIndex(q) and GetJournalQuestType(q) == QUEST_TYPE_CRAFTING then
            local n = GetJournalQuestNumConditions(q, MAIN_STEP) or 0
            for c = 1, n do
                local text, cur, maxv, isComplete, isVisible = GetJournalConditionInfo(q, c)
                if text and isVisible ~= false and not isComplete and (maxv or 1) > (cur or 0) then
                    local hay = string.lower(text)
                    if hay:find("добы", 1, true) or hay:find("acquire", 1, true) or hay:find("gather", 1, true) then
                        -- skip
                    else
                        local ring = hay:find("кольц", 1, true) or hay:find("ring", 1, true) or hay:find("ringe", 1, true)
                        local neck = hay:find("ожерел", 1, true) or hay:find("neck", 1, true) or hay:find("collier", 1, true)
                            or hay:find("kette", 1, true)
                        if ring or neck then
                            local remaining = (maxv or 1) - (cur or 0)
                            if remaining < 1 then remaining = 1 end
                            -- "три кольца" / "three rings" → remaining usually 3
                            return {
                                wantRing = ring and true or false,
                                wantNeck = neck and true or false,
                                remaining = remaining,
                                text = text,
                            }
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function JewelryJobsFromParse(parsed, materialIndex)
    local jobs = {}
    if not parsed then return jobs end
    local rank = Data.GetCraftingTier(7) or 5
    if rank < 1 then rank = 1 end
    if rank > 5 then rank = 5 end
    local pair = Data.JewelryQtyByRank and Data.JewelryQtyByRank[rank] or { 2, 3 }
    -- Prefer the FIRST row of the metal (CP150 platinum, not the CP160 row)
    local mat = materialIndex or Data.GetMaterialIndex(7, rank)
    if parsed.wantRing and not parsed.wantNeck then
        -- 3 rings typical
        local n = parsed.remaining
        if n < 1 then n = 3 end
        for i = 1, n do
            jobs[#jobs + 1] = {
                craftType = 7,
                patternIndex = 1,
                materialIndex = mat,
                materialQuantity = pair[1],
                styleId = 0,
            }
        end
    elseif parsed.wantNeck and not parsed.wantRing then
        local n = parsed.remaining
        if n < 1 then n = 2 end
        for i = 1, n do
            jobs[#jobs + 1] = {
                craftType = 7,
                patternIndex = 2,
                materialIndex = mat,
                materialQuantity = pair[2],
                styleId = 0,
            }
        end
    else
        -- mixed "ring and necklace": 1 each if remaining is 2, else one of each
        jobs[#jobs + 1] = {
            craftType = 7, patternIndex = 2, materialIndex = mat,
            materialQuantity = pair[2], styleId = 0,
        }
        jobs[#jobs + 1] = {
            craftType = 7, patternIndex = 1, materialIndex = mat,
            materialQuantity = pair[1], styleId = 0,
        }
    end
    return jobs
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

local function JewelryOunces(patternIndex, materialIndex)
    return Data.GetJewelryOunces(patternIndex, Data.GetCraftingTier(7))
end

local function JobsFromPatternList(craftType, patternList, materialIndex)
    local jobs = {}
    if not patternList then return jobs end
    for i = 1, #patternList do
        local patternIndex = patternList[i]
        local qty
        local styleId = 0
        if craftType == Data.CRAFT_JEWELRY or craftType == 7 then
            qty = JewelryOunces(patternIndex, materialIndex)
        else
            qty = Data.GetRequiredMaterialQuantity(patternIndex, materialIndex)
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

-- Requires known startPhase 1..3. Returns jobs, ok, errCode
-- errCode: "no_phase" if phase unknown — caller must ask player to take the writ once.
local function BuildPrecraftEquipmentJobs(craftType, startOff, endOff, startPhase)
    local jobs = {}
    if not startPhase or startPhase < 1 or startPhase > 3 then
        return jobs, false, "no_phase"
    end
    local tier = Data.GetCraftingTier(craftType)
    local stationPatterns = Data.Patterns[craftType]
    if not stationPatterns then return jobs, false, "no_patterns" end
    local materialIndex = Data.GetMaterialIndex(craftType, tier)
    startOff = tonumber(startOff) or 0
    endOff = tonumber(endOff) or startOff

    for offset = startOff, endOff do
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
                    phase = dayIdx,
                }
            end
        else
            local part = JobsFromPatternList(craftType, patterns, materialIndex)
            for i = 1, #part do
                part[i].dayOffset = offset
                part[i].phase = dayIdx
                jobs[#jobs + 1] = part[i]
            end
        end
    end
    return jobs, true, nil
end

-- Stand-alone: today .. today+slider. Compat (Lazy Writ does today): tomorrow .. slider days ahead.
local function PrecraftDayWindow()
    local cs = TetsuDailyWritPrecrafter.GetCharSettings and TetsuDailyWritPrecrafter.GetCharSettings()
    local slider = (cs and cs.preCraftDays) or 3
    if slider < 1 then slider = 1 end
    if slider > 10 then slider = 10 end
    local compat = TetsuDailyWritPrecrafter.IsLazyWritCompat and TetsuDailyWritPrecrafter.IsLazyWritCompat()
    if compat then
        return 1, slider
    end
    return 0, slider
end

local function EffectiveDaysFromSettings()
    local a, b = PrecraftDayWindow()
    return (b - a + 1), a, b
end

local function BuildPrecraftAlchemyJobs()
    local tier = Data.GetCraftingTier(4)
    local n = EffectiveDaysFromSettings()
    return Data.GetAlchemyJobsForTier(tier, n)
end

local function BuildPrecraftProvisioningJobs()
    local tier = Data.GetCraftingTier(5)
    local allianceId = GetUnitAlliance and GetUnitAlliance("player") or 0
    local recipeMap = Data.BuildRecipeMapByIngredients and Data.BuildRecipeMapByIngredients() or {}
    local n, startOff = EffectiveDaysFromSettings()
    return Data.GetProvisioningJobsForChar(tier, allianceId, recipeMap, n, startOff)
end

--------------------------------------------------------------------------
-- Public: build the list the station should craft right now
--------------------------------------------------------------------------

function Crafting.GetRequiredItemsForStation(craftType)
    EnsureData()
    local cs = TetsuDailyWritPrecrafter.GetCharSettings and TetsuDailyWritPrecrafter.GetCharSettings()
    local preCraft = cs and cs.preCraftEnabled == true
    local compat = TetsuDailyWritPrecrafter.IsLazyWritCompat and TetsuDailyWritPrecrafter.IsLazyWritCompat()
    -- Lazy Writ owns "today" when compat is on
    if compat then
        preCraft = cs and cs.preCraftEnabled == true
        if not preCraft then
            return {}, "none", 0
        end
    end
    -- Slider N means "today + N future days" (1 → 2 crafts, 3 → 4 crafts)
    local slider = (cs and cs.preCraftDays) or 3
    if slider < 1 then slider = 1 end
    if slider > 10 then slider = 10 end
    local startOff, endOff = PrecraftDayWindow()
    local days = endOff - startOff + 1

    local jobs = {}
    local mode = "none"
    local phase = nil

    -- Always try to resolve from active quest first (correct items + quantities)
    local questJobs = {}
    if craftType == 4 or craftType == Data.CRAFT_ALCHEMY then
        if not preCraft then
            local tier = Data.GetCraftingTier(4)
            if Data.GetAlchemyJobsForQuest then
                questJobs = Data.GetAlchemyJobsForQuest(tier)
            end
        end
    elseif craftType == 5 or craftType == Data.CRAFT_PROVISIONING then
        if not preCraft then
            local recipeMap = Data.BuildRecipeMapByIngredients and Data.BuildRecipeMapByIngredients() or {}
            if Data.ResolveProvisioningFromQuest then
                questJobs = Data.ResolveProvisioningFromQuest(recipeMap)
            end
        end
    elseif craftType == Data.CRAFT_ENCHANTING or craftType == 3 then
        local tier = Data.GetCraftingTier(craftType)
        questJobs = ResolveEnchantingFromQuest(tier)
        -- Glyphs have no patternIndex; derive phase from essence rune
        if questJobs and #questJobs > 0 then
            local ess = questJobs[1].essenceId
            if ess == 45832 then phase = 1      -- Makko / Magicka
            elseif ess == 45833 then phase = 2 -- Deni / Stamina
            elseif ess == 45831 then phase = 3 -- Oko / Health
            end
            if phase and cs then
                cs.writPhase = cs.writPhase or {}
                cs.writPhase[craftType] = phase
            end
        end
    else
        local tier = Data.GetCraftingTier(craftType)
        local materialIndex = Data.GetMaterialIndex(craftType, tier)
        questJobs = ResolveSmithingFromQuest(craftType, materialIndex)
        if (not questJobs or #questJobs == 0) and (craftType == Data.CRAFT_JEWELRY or craftType == 7) then
            local parsed = ParseJewelryWritFromText()
            questJobs = JewelryJobsFromParse(parsed, materialIndex)
            if parsed then
                if parsed.wantRing and not parsed.wantNeck then
                    phase = 1
                elseif parsed.wantRing and parsed.wantNeck then
                    phase = 2
                elseif parsed.wantNeck then
                    phase = 3
                end
            end
        end
        phase = phase or DetectPhaseFromResolved(craftType, questJobs)
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
            local ok, err
            jobs, ok, err = BuildPrecraftEquipmentJobs(craftType, startOff, endOff, savedPhase)
            if not ok and err == "no_phase" then
                -- Cannot guess per-character rotation. Force learn from active writ.
                Crafting._lastPhaseError = craftType
                jobs = {}
            else
                Crafting._lastPhaseError = nil
                if savedPhase then
                    Crafting._lastKnownPhase = savedPhase
                end
            end
        end
    else
        mode = "quest"
        jobs = questJobs
        if phase then
            Crafting._lastKnownPhase = phase
        end
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
    local function niceName(itemId, fallback)
        if itemId and itemId > 0 and Data.GetItemNameById then
            local n = Data.GetItemNameById(itemId)
            if n and n ~= "" then return n end
        end
        return fallback or ("#" .. tostring(itemId or "?"))
    end

    local function addNeed(itemId, fallbackName, amount)
        if not itemId or itemId <= 0 or not amount or amount <= 0 then return end
        if not need[itemId] then
            need[itemId] = { name = niceName(itemId, fallbackName), amount = 0 }
        end
        need[itemId].amount = need[itemId].amount + amount
    end

    for i = 1, #itemsList do
        local job = itemsList[i]
        if craftType == 4 or craftType == Data.CRAFT_ALCHEMY then
            if job.solventIds then
                -- Count only ONE solvent unit per job (first available id is used at craft time)
                local solventCounted = false
                for s = 1, #job.solventIds do
                    if not solventCounted then
                        addNeed(job.solventIds[s], "solvent", 1)
                        solventCounted = true
                    end
                end
            end
            addNeed(job.reagent1Id, "reagent", 1)
            addNeed(job.reagent2Id, "reagent", 1)
        elseif craftType == 5 or craftType == Data.CRAFT_PROVISIONING then
            if job.ingredientIds then
                for _, ingId in ipairs(job.ingredientIds) do
                    addNeed(ingId, "ingredient", 1)
                end
            end
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

local function EnsureSmithingCreationMode()
    pcall(function()
        if SMITHING_MODE_CREATION then
            if SMITHING and SMITHING.SetMode then
                SMITHING:SetMode(SMITHING_MODE_CREATION)
            end
            if SYSTEMS and SYSTEMS.GetObject then
                local obj = SYSTEMS:GetObject("smithing")
                if obj and obj.SetMode then
                    obj:SetMode(SMITHING_MODE_CREATION)
                end
            end
        end
    end)
end

local function ClearCraftWatch()
    pcall(function() EVENT_MANAGER:UnregisterForUpdate("TDWP_CraftWatch") end)
end

local function ArmCraftWatch(timeoutMs)
    ClearCraftWatch()
    if not timeoutMs then
        local cur = craftingQueue[currentQueueIndex]
        local n = (cur and (cur._craftedNow or cur.count)) or 1
        timeoutMs = 3500 + (tonumber(n) or 1) * 900
    end
    timeoutMs = tonumber(timeoutMs) or 4000
    if timeoutMs < 3500 then timeoutMs = 3500 end
    if timeoutMs > 25000 then timeoutMs = 25000 end
    EVENT_MANAGER:RegisterForUpdate("TDWP_CraftWatch", timeoutMs, function()
        ClearCraftWatch()
        if not waitingForCraft then return end
        waitingForCraft = false
        skipCount = skipCount + 1
        local item = craftingQueue[currentQueueIndex]
        if item then
            Chat(zo_strformat(
                L().ERR_CRAFT_FAILED or "Craft failed for item <<1>>/<<2>>",
                currentQueueIndex, #craftingQueue
            ))
        end
        zo_callLater(ProcessNextCraftItem, 200)
    end)
end

local function CanCraftSmithing(item)
    if not item.patternIndex then return false end
    local styleId = item.styleId or 0
    if item.craftType ~= Data.CRAFT_JEWELRY and item.craftType ~= 7 then
        if not styleId or styleId < 1 then return false end
    end
    return true
end


local function JobCollapseKey(job)
    local ct = job.craftType or 0
    if ct == 4 then
        return "4:" .. tostring(job.reagent1Id) .. ":" .. tostring(job.reagent2Id)
    end
    if ct == 5 then
        return "5:" .. tostring(job.recipeListIndex) .. ":" .. tostring(job.recipeIndex)
    end
    if ct == 3 then
        return "3:" .. tostring(job.potencyId) .. ":" .. tostring(job.essenceId) .. ":" .. tostring(job.aspectId)
    end
    return "S:" .. tostring(job.patternIndex) .. ":" .. tostring(job.materialIndex)
        .. ":" .. tostring(job.materialQuantity) .. ":" .. tostring(job.styleId)
end

local function CollapseIdenticalJobs(list)
    local order, map = {}, {}
    for i = 1, #list do
        local job = list[i]
        local key = JobCollapseKey(job)
        if map[key] then
            map[key].count = (map[key].count or 1) + (job.count or 1)
        else
            local copy = {}
            for k, v in pairs(job) do
                copy[k] = v
            end
            copy.count = job.count or 1
            map[key] = copy
            order[#order + 1] = copy
        end
    end
    return order
end

local function FinishQueue()
    ClearCraftWatch()
    StopStationGuard()
    isCrafting = false
    waitingForCraft = false
    craftingQueue = {}
    currentQueueIndex = 0
    if TetsuDailyWritPrecrafter.UI and TetsuDailyWritPrecrafter.UI.HideProgress then
        TetsuDailyWritPrecrafter.UI.HideProgress()
    end
    ChatInfo(zo_strformat(L().CRAFT_DONE, successCount, skipCount))
    successCount = 0
    skipCount = 0
    LeaveCraftingStation()
    EVENT_MANAGER:UnregisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_COMPLETED)
    EVENT_MANAGER:UnregisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_FAILED)
    -- Stay silent after a finished run on this station visit (prevents provisioning loop)
    Crafting._stationSessionDone = true
    zo_callLater(function()
        if GetCraftingInteractionType and GetCraftingInteractionType() ~= 0 then
            -- Only restore the R3 button for precraft; do not auto-start quest again
            local cs = TetsuDailyWritPrecrafter.GetCharSettings and TetsuDailyWritPrecrafter.GetCharSettings()
            if cs and cs.preCraftEnabled then
                Crafting.AddStationKeybind()
            end
        end
    end, 400)
end

local function ProcessNextCraftItem()
    if not isCrafting then return end
    if not GetCraftingInteractionType or GetCraftingInteractionType() == 0 then
        Crafting.AbortBecauseStationClosed()
        return
    end
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
        local want = item.count or 1
        local maxN = want
        if GetMaxIterationsPossibleForAlchemyItem then
            local n = GetMaxIterationsPossibleForAlchemyItem(sBag, sSlot, r1Bag, r1Slot, r2Bag, r2Slot)
            if tonumber(n) and n > 0 then maxN = n end
        end
        local n = want
        if n > maxN then n = maxN end
        if n < 1 then n = 1 end
        item._craftedNow = n
        if want > n then
            local rest = {}
            for k, v in pairs(item) do rest[k] = v end
            rest.count = want - n
            rest._craftedNow = nil
            table.insert(craftingQueue, currentQueueIndex + 1, rest)
        end
        waitingForCraft = true
        ArmCraftWatch()
        if CraftAlchemyItem then
            CraftAlchemyItem(sBag, sSlot, r1Bag, r1Slot, r2Bag, r2Slot, nil, nil, n)
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
        local want = item.count or 1
        local maxN = want
        if GetMaxIterationsPossibleForRecipe then
            local n = GetMaxIterationsPossibleForRecipe(item.recipeListIndex, item.recipeIndex)
            if tonumber(n) and n > 0 then maxN = n end
        end
        local n = want
        if n > maxN then n = maxN end
        if n < 1 then n = 1 end
        item._craftedNow = n
        if want > n then
            local rest = {}
            for k, v in pairs(item) do rest[k] = v end
            rest.count = want - n
            rest._craftedNow = nil
            table.insert(craftingQueue, currentQueueIndex + 1, rest)
        end
        waitingForCraft = true
        ArmCraftWatch()
        if CraftProvisionerItem then
            CraftProvisionerItem(item.recipeListIndex, item.recipeIndex, n)
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
        local want = item.count or 1
        local maxN = want
        if GetMaxIterationsPossibleForEnchantingItem then
            local n = GetMaxIterationsPossibleForEnchantingItem(pBag, pSlot, eBag, eSlot, aBag, aSlot)
            if tonumber(n) and n > 0 then maxN = n end
        end
        local n = want
        if n > maxN then n = maxN end
        if n < 1 then n = 1 end
        item._craftedNow = n
        if want > n then
            local rest = {}
            for k, v in pairs(item) do rest[k] = v end
            rest.count = want - n
            rest._craftedNow = nil
            table.insert(craftingQueue, currentQueueIndex + 1, rest)
        end
        waitingForCraft = true
        ArmCraftWatch()
        if CraftEnchantingItem then
            CraftEnchantingItem(pBag, pSlot, eBag, eSlot, aBag, aSlot, n)
        else
            waitingForCraft = false
            skipCount = skipCount + 1
            zo_callLater(ProcessNextCraftItem, 150)
        end
        return
    end

    -- Smithing / Clothing / Woodworking / Jewelry
    if not CanCraftSmithing(item) then
        Chat(zo_strformat(L().ERR_CANNOT_CRAFT, "equipment"))
        Chat(L().PRECHECK_ABORT)
        -- Hard stop: do not skip remaining jobs when materials/style missing
        isCrafting = false
        waitingForCraft = false
        craftingQueue = {}
        EVENT_MANAGER:UnregisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_COMPLETED)
        EVENT_MANAGER:UnregisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_FAILED)
        if TetsuDailyWritPrecrafter.UI and TetsuDailyWritPrecrafter.UI.HideProgress then
            TetsuDailyWritPrecrafter.UI.HideProgress()
        end
        Crafting.AddStationKeybind()
        return
    end
    -- Proven signature from Lazy Writ / original Tetsu: trait=1, mimic=false, count=1
    local trait = (Data and Data.TRAIT_NONE) or 1
    local qty = item.materialQuantity or 1
    local styleId = item.styleId or 0
    if item.craftType == Data.CRAFT_JEWELRY or item.craftType == 7 then
        styleId = 0
    end
    local want = item.count or 1
    local maxN = want
    if GetMaxIterationsPossibleForSmithingItem then
        local n = GetMaxIterationsPossibleForSmithingItem(
            item.patternIndex, item.materialIndex, qty, styleId, trait, false
        )
        if tonumber(n) and n > 0 then maxN = n end
    end
    local n = want
    if n > maxN then n = maxN end
    if n < 1 then n = 1 end
    item._craftedNow = n
    if want > n then
        local rest = {}
        for k, v in pairs(item) do rest[k] = v end
        rest.count = want - n
        rest._craftedNow = nil
        table.insert(craftingQueue, currentQueueIndex + 1, rest)
    end
    waitingForCraft = true
    ArmCraftWatch()
    if CraftSmithingItem then
        CraftSmithingItem(item.patternIndex, item.materialIndex, qty, styleId, trait, false, n)
    else
        waitingForCraft = false
        ClearCraftWatch()
        skipCount = skipCount + 1
        zo_callLater(ProcessNextCraftItem, 150)
    end
end

local function OnCraftCompleted()
    if not waitingForCraft then return end
    ClearCraftWatch()
    waitingForCraft = false
    local item = craftingQueue[currentQueueIndex]
    successCount = successCount + ((item and item._craftedNow) or (item and item.count) or 1)
    zo_callLater(ProcessNextCraftItem, 250)
end

local function OnCraftFailed()
    if not waitingForCraft then return end
    ClearCraftWatch()
    waitingForCraft = false
    skipCount = skipCount + 1
    Chat(zo_strformat(L().ERR_CRAFT_FAILED, currentQueueIndex, #craftingQueue))
    zo_callLater(ProcessNextCraftItem, 350)
end

function Crafting.ExecuteBulkCraft(itemsList, craftType)
    if TetsuDailyWritPrecrafter.HasWritConflict and select(1, TetsuDailyWritPrecrafter.HasWritConflict()) then
        Chat(L().CONFLICT_CHAT or "Disable Dolgubon's Lazy Writ Crafter — auto-craft paused.")
        return
    end
    if not GetCraftingInteractionType or GetCraftingInteractionType() == 0 then
        Chat(L().ERR_NOT_AT_STATION)
        return
    end
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
        LeaveCraftingStation()
        return
    end

    -- Material pre-check
    local missing = CheckMaterialsForJobs(itemsList, craftType)
    if #missing > 0 then
        Chat(L().PRECHECK_HEADER)
        Chat(zo_strformat(L().PRECHECK_JOBS, #itemsList))
        for i = 1, #missing do
            local m = missing[i]
            Chat(zo_strformat(L().PRECHECK_LINE, m.name, m.need, m.have, m.deficit))
        end
        Chat(L().PRECHECK_ABORT)
        LeaveCraftingStation()
        return
    end

    local originalCount = #itemsList
    itemsList = CollapseIdenticalJobs(itemsList)
    ChatInfo(zo_strformat(L().PRECHECK_OK, originalCount))

    Crafting._stationLock = true
    craftingQueue = itemsList
    currentQueueIndex = 0
    successCount = 0
    skipCount = 0
    isCrafting = true
    waitingForCraft = false
    StartStationGuard()

    Crafting.RemoveStationKeybind()

    if TetsuDailyWritPrecrafter.UI and TetsuDailyWritPrecrafter.UI.ShowProgress then
        TetsuDailyWritPrecrafter.UI.ShowProgress(#itemsList)
    end

    EVENT_MANAGER:RegisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_COMPLETED, OnCraftCompleted)
    EVENT_MANAGER:RegisterForEvent("TDWP_CraftEngine", EVENT_CRAFT_FAILED, OnCraftFailed)

    EnsureSmithingCreationMode()
    zo_callLater(ProcessNextCraftItem, 250)
end

--------------------------------------------------------------------------
-- Keybind strip (R3)
--------------------------------------------------------------------------

function Crafting.AddStationKeybind()
    EnsureData()
    if TetsuDailyWritPrecrafter.HasWritConflict and select(1, TetsuDailyWritPrecrafter.HasWritConflict()) then
        Crafting.RemoveStationKeybind()
        return
    end
    local craftType = GetCraftingInteractionType()
    if not craftType or craftType == 0 then
        Crafting.RemoveStationKeybind()
        return
    end

    local items, mode, days = Crafting.GetRequiredItemsForStation(craftType)
    Crafting._cachedStationType = craftType
    Crafting._cachedStationItems = items
    Crafting._cachedMode = mode
    Crafting._cachedDays = days

    -- Pre-craft needs a known per-character phase (learned from an active writ once)
    if mode == "precraft" and Crafting._lastPhaseError == craftType then
        Crafting.RemoveStationKeybind()
        if not Crafting._phaseWarnShown then
            Crafting._phaseWarnShown = true
            Chat(L().ERR_PHASE_UNKNOWN or "Take today's writ once so the addon can learn your rotation phase.")
            zo_callLater(function() Crafting._phaseWarnShown = false end, 5000)
        end
        return
    end

    -- Quest mode: auto-craft ONCE per station visit
    if mode == "quest" and items and #items > 0 and not isCrafting then
        if Crafting._stationSessionDone or Crafting._stationLock then
            Crafting.RemoveStationKeybind()
            return
        end
        Crafting.RemoveStationKeybind()
        if not Crafting._autoQuestStarted then
            Crafting._autoQuestStarted = true
            ChatInfo(L().USING_QUEST_DATA)
            zo_callLater(function()
                if GetCraftingInteractionType and GetCraftingInteractionType() == craftType and not isCrafting then
                    local again = select(1, Crafting.GetRequiredItemsForStation(craftType))
                    if again and #again > 0 then
                        Crafting.ExecuteBulkCraft(again, craftType)
                    end
                end
            end, 600)
        end
        return
    end

    if not items or #items == 0 then
        Crafting.RemoveStationKeybind()
        if mode == "quest" and not Crafting._emptyWarnShown then
            Crafting._emptyWarnShown = true
            Chat(L().ERR_NOTHING_TO_CRAFT)
            zo_callLater(function() Crafting._emptyWarnShown = false end, 8000)
        end
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
                ChatInfo(zo_strformat(L().USING_PREDICTED, curDays))
                if Crafting._lastKnownPhase then
                    local names = { "A", "B", "C" }
                    ChatInfo(zo_strformat(L().PHASE_LEARNED or "Rotation phase: <<1>>", names[Crafting._lastKnownPhase] or Crafting._lastKnownPhase))
                end
            else
                ChatInfo(L().USING_QUEST_DATA)
                if Crafting._lastKnownPhase then
                    local names = { "A", "B", "C" }
                    ChatInfo(zo_strformat(L().PHASE_LEARNED or "Rotation phase: <<1>>", names[Crafting._lastKnownPhase] or Crafting._lastKnownPhase))
                end
            end

            if curMode == "precraft" and TetsuDailyWritPrecrafter.UI and TetsuDailyWritPrecrafter.UI.ShowConfirmationDialog then
                TetsuDailyWritPrecrafter.UI.ShowConfirmationDialog(#curItems, function()
                    Crafting.ExecuteBulkCraft(curItems, cType)
                end, true)
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
