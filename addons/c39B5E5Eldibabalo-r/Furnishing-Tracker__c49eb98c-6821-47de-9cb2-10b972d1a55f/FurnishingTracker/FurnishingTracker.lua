FT = FT or {}
FT.name = "FurnishingTracker"
FT.version = "1.0.18"

ZO_CreateStringId("SI_BINDING_NAME_FT_TOGGLE", "Toggle Furnishing Tracker")
ZO_CreateStringId("SI_BINDING_NAME_FT_SCROLL_UP", "Scroll Up")
ZO_CreateStringId("SI_BINDING_NAME_FT_SCROLL_DOWN", "Scroll Down")
ZO_CreateStringId("SI_BINDING_NAME_FT_CLOSE", "Close Tracker")

FT.savedVars = nil
FT.entries = {}
FT.filteredList = {}
FT.searchText = ""
FT.lastCollectS = 0
FT.collectIntervalS = 45

local SAVED_VAR_VERSION = 1
local SV_DEFAULTS = {
    filterIndex = 1,
}

local RARITY_COMMON = 1
local RARITY_FINE = 2
local RARITY_SUPERIOR = 3
local RARITY_EPIC = 4
local RARITY_LEGENDARY = 5

FT.QUALITY_HEX = {
    [RARITY_COMMON] = "FFFFFF",
    [RARITY_FINE] = "2DC50E",
    [RARITY_SUPERIOR] = "3A92FF",
    [RARITY_EPIC] = "A02EF7",
    [RARITY_LEGENDARY] = "EECA2A",
}

FT.QUALITY_LABEL = {
    [RARITY_COMMON] = "Common",
    [RARITY_FINE] = "Fine",
    [RARITY_SUPERIOR] = "Superior",
    [RARITY_EPIC] = "Epic",
    [RARITY_LEGENDARY] = "Legendary",
}

local function Lower(text)
    if type(text) ~= "string" then
        return ""
    end
    return string.lower(text)
end

local function PrepareSearch(text)
    if not text or text == "" then
        return nil
    end
    return Lower(text)
end

local function GetQualityHex(quality)
    return FT.QUALITY_HEX[quality] or "FFFFFF"
end

local function GetQualityLabel(quality)
    return FT.QUALITY_LABEL[quality] or "Common"
end

local function ToRarityTier(rawQuality)
    if type(rawQuality) ~= "number" then
        return RARITY_COMMON
    end

    if type(ITEM_FUNCTIONAL_QUALITY_LEGENDARY) == "number" and rawQuality == ITEM_FUNCTIONAL_QUALITY_LEGENDARY then
        return RARITY_LEGENDARY
    elseif type(ITEM_FUNCTIONAL_QUALITY_ARTIFACT) == "number" and rawQuality == ITEM_FUNCTIONAL_QUALITY_ARTIFACT then
        return RARITY_EPIC
    elseif type(ITEM_FUNCTIONAL_QUALITY_ARCANE) == "number" and rawQuality == ITEM_FUNCTIONAL_QUALITY_ARCANE then
        return RARITY_SUPERIOR
    elseif type(ITEM_FUNCTIONAL_QUALITY_MAGIC) == "number" and rawQuality == ITEM_FUNCTIONAL_QUALITY_MAGIC then
        return RARITY_FINE
    elseif type(ITEM_FUNCTIONAL_QUALITY_NORMAL) == "number" and rawQuality == ITEM_FUNCTIONAL_QUALITY_NORMAL then
        return RARITY_COMMON
    elseif type(ITEM_FUNCTIONAL_QUALITY_TRASH) == "number" and rawQuality == ITEM_FUNCTIONAL_QUALITY_TRASH then
        return RARITY_COMMON
    end

    if type(ITEM_DISPLAY_QUALITY_LEGENDARY) == "number" and rawQuality == ITEM_DISPLAY_QUALITY_LEGENDARY then
        return RARITY_LEGENDARY
    elseif type(ITEM_DISPLAY_QUALITY_ARTIFACT) == "number" and rawQuality == ITEM_DISPLAY_QUALITY_ARTIFACT then
        return RARITY_EPIC
    elseif type(ITEM_DISPLAY_QUALITY_ARCANE) == "number" and rawQuality == ITEM_DISPLAY_QUALITY_ARCANE then
        return RARITY_SUPERIOR
    elseif type(ITEM_DISPLAY_QUALITY_MAGIC) == "number" and rawQuality == ITEM_DISPLAY_QUALITY_MAGIC then
        return RARITY_FINE
    end

    if rawQuality >= 5 then
        return RARITY_LEGENDARY
    elseif rawQuality == 4 then
        return RARITY_EPIC
    elseif rawQuality == 3 then
        return RARITY_SUPERIOR
    elseif rawQuality == 2 then
        return RARITY_FINE
    end

    return RARITY_COMMON
end

local function GetNowS()
    if type(GetTimeStamp) == "function" then
        return GetTimeStamp()
    end
    return 0
end

local function SafeGetRecipeInfo(listIndex, recipeIndex)
    if type(GetRecipeInfo) ~= "function" then
        return false, nil
    end
    local ok, a, b, c, d, e, f, g = pcall(GetRecipeInfo, listIndex, recipeIndex)
    if not ok and type(CRAFTING_TYPE_PROVISIONING) == "number" then
        ok, a, b, c, d, e, f, g = pcall(GetRecipeInfo, CRAFTING_TYPE_PROVISIONING, listIndex, recipeIndex)
    end
    if not ok then
        return false, nil
    end
    return true, { a, b, c, d, e, f, g }
end

local function SafeIsRecipeKnown(listIndex, recipeIndex)
    if type(IsRecipeKnown) == "function" then
        local ok, known = pcall(IsRecipeKnown, listIndex, recipeIndex)
        if ok and type(known) == "boolean" then
            return known
        end
    end
    local okInfo, values = SafeGetRecipeInfo(listIndex, recipeIndex)
    if okInfo and type(values[1]) == "boolean" then
        return values[1]
    end
    return false
end

local function SafeGetRecipeListName(listIndex)
    if type(GetRecipeListInfo) == "function" then
        local ok, name = pcall(GetRecipeListInfo, listIndex)
        if not ok and type(CRAFTING_TYPE_PROVISIONING) == "number" then
            ok, name = pcall(GetRecipeListInfo, CRAFTING_TYPE_PROVISIONING, listIndex)
        end
        if ok and type(name) == "string" then
            return name
        end
    end
    return "List " .. tostring(listIndex)
end

local function SafeGetNumRecipeLists()
    if type(GetNumRecipeLists) ~= "function" then
        return 0
    end
    local ok, count = pcall(GetNumRecipeLists)
    if (not ok or type(count) ~= "number" or count <= 0) and type(CRAFTING_TYPE_PROVISIONING) == "number" then
        ok, count = pcall(GetNumRecipeLists, CRAFTING_TYPE_PROVISIONING)
    end
    if ok and type(count) == "number" then
        return count
    end
    return 0
end

local function SafeGetNumRecipesInList(listIndex)
    if type(GetNumRecipesInRecipeList) ~= "function" then
        return 0
    end
    local ok, count = pcall(GetNumRecipesInRecipeList, listIndex)
    if (not ok or type(count) ~= "number") and type(CRAFTING_TYPE_PROVISIONING) == "number" then
        ok, count = pcall(GetNumRecipesInRecipeList, CRAFTING_TYPE_PROVISIONING, listIndex)
    end
    if ok and type(count) == "number" then
        return count
    end
    return 0
end

local SafeGetRecipeItemLink

local function BuildRecipeIndexMap()
    local maps = {
        byItemId = {},
        byName = {},
    }
    local listCount = SafeGetNumRecipeLists()
    for listIndex = 1, listCount do
        local recipeCount = SafeGetNumRecipesInList(listIndex)
        for recipeIndex = 1, recipeCount do
            local recipeLink = SafeGetRecipeItemLink(listIndex, recipeIndex)
            if recipeLink ~= "" and type(GetItemLinkItemId) == "function" then
                local ok, itemId = pcall(GetItemLinkItemId, recipeLink)
                if ok and type(itemId) == "number" and itemId > 0 and not maps.byItemId[itemId] then
                    maps.byItemId[itemId] = { listIndex = listIndex, recipeIndex = recipeIndex }
                end
            end
            local recipeName = SafeLinkName(recipeLink)
            local key = Lower(recipeName)
            if key ~= "" and not maps.byName[key] then
                maps.byName[key] = { listIndex = listIndex, recipeIndex = recipeIndex }
            end
        end
    end
    return maps
end

local function BuildBackpackPlanSlotMap()
    local byItemId = {}
    if type(GetBagSize) ~= "function" or type(GetItemLink) ~= "function" or type(GetItemLinkItemId) ~= "function" then
        return byItemId
    end
    local bagId = BAG_BACKPACK
    local bagSize = GetBagSize(bagId) or 0
    for slotIndex = 0, bagSize - 1 do
        local link = GetItemLink(bagId, slotIndex)
        if type(link) == "string" and link ~= "" then
            local ok, itemId = pcall(GetItemLinkItemId, link)
            if ok and type(itemId) == "number" and itemId > 0 and not byItemId[itemId] then
                byItemId[itemId] = { bagId = bagId, slotIndex = slotIndex }
            end
        end
    end
    return byItemId
end

local function SafeGetRecipeResultLink(listIndex, recipeIndex)
    if type(GetRecipeResultItemLink) == "function" then
        local ok, link = pcall(GetRecipeResultItemLink, listIndex, recipeIndex, LINK_STYLE_DEFAULT)
        if not ok and type(CRAFTING_TYPE_PROVISIONING) == "number" then
            ok, link = pcall(GetRecipeResultItemLink, CRAFTING_TYPE_PROVISIONING, listIndex, recipeIndex, LINK_STYLE_DEFAULT)
        end
        if ok and type(link) == "string" and link ~= "" then
            return link
        end
        ok, link = pcall(GetRecipeResultItemLink, listIndex, recipeIndex)
        if not ok and type(CRAFTING_TYPE_PROVISIONING) == "number" then
            ok, link = pcall(GetRecipeResultItemLink, CRAFTING_TYPE_PROVISIONING, listIndex, recipeIndex)
        end
        if ok and type(link) == "string" and link ~= "" then
            return link
        end
    end
    return ""
end

SafeGetRecipeItemLink = function(listIndex, recipeIndex)
    if type(GetRecipeItemLink) == "function" then
        local ok, link = pcall(GetRecipeItemLink, listIndex, recipeIndex, LINK_STYLE_DEFAULT)
        if not ok and type(CRAFTING_TYPE_PROVISIONING) == "number" then
            ok, link = pcall(GetRecipeItemLink, CRAFTING_TYPE_PROVISIONING, listIndex, recipeIndex, LINK_STYLE_DEFAULT)
        end
        if ok and type(link) == "string" and link ~= "" then
            return link
        end
        ok, link = pcall(GetRecipeItemLink, listIndex, recipeIndex)
        if not ok and type(CRAFTING_TYPE_PROVISIONING) == "number" then
            ok, link = pcall(GetRecipeItemLink, CRAFTING_TYPE_PROVISIONING, listIndex, recipeIndex)
        end
        if ok and type(link) == "string" and link ~= "" then
            return link
        end
    end
    return ""
end

local function SafeLinkName(itemLink)
    if itemLink == "" then
        return ""
    end
    if type(GetItemLinkName) == "function" then
        local ok, name = pcall(GetItemLinkName, itemLink)
        if ok and type(name) == "string" and name ~= "" then
            return zo_strformat("<<1>>", name)
        end
    end
    return ""
end

local function SafeLinkIcon(itemLink)
    if itemLink == "" then
        return ""
    end
    if type(GetItemLinkIcon) == "function" then
        local ok, icon = pcall(GetItemLinkIcon, itemLink)
        if ok and type(icon) == "string" and icon ~= "" then
            return icon
        end
    end
    return ""
end

local function SafeLinkQualityTier(itemLink)
    if itemLink == "" then
        return RARITY_COMMON
    end
    -- Match CharacterKnowledge browser behavior first.
    if type(GetItemLinkFunctionalQuality) == "function" then
        local ok, quality = pcall(GetItemLinkFunctionalQuality, itemLink)
        if ok and type(quality) == "number" then
            return ToRarityTier(quality)
        end
    end
    if type(GetItemLinkDisplayQuality) == "function" then
        local ok, quality = pcall(GetItemLinkDisplayQuality, itemLink)
        if ok and type(quality) == "number" then
            return ToRarityTier(quality)
        end
    end
    if type(GetItemLinkQuality) == "function" then
        local ok, quality = pcall(GetItemLinkQuality, itemLink)
        if ok and type(quality) == "number" then
            return ToRarityTier(quality)
        end
    end
    return RARITY_COMMON
end

local function ResolveEntryQualityTier(planLink, resultLink)
    -- First preference: resulting furniture item's display quality.
    -- This usually matches player expectation for rarity buckets.
    if type(resultLink) == "string" and resultLink ~= "" then
        if type(GetItemLinkDisplayQuality) == "function" then
            local ok, q = pcall(GetItemLinkDisplayQuality, resultLink)
            if ok and type(q) == "number" then
                return ToRarityTier(q)
            end
        end
        if type(GetItemLinkQuality) == "function" then
            local ok, q = pcall(GetItemLinkQuality, resultLink)
            if ok and type(q) == "number" then
                return ToRarityTier(q)
            end
        end
    end

    -- Fallback: plan/recipe link quality.
    return SafeLinkQualityTier(planLink ~= "" and planLink or resultLink)
end

local function SafeLinkItemType(itemLink)
    if itemLink == "" then
        return nil
    end
    if type(GetItemLinkItemType) == "function" then
        local ok, itemType = pcall(GetItemLinkItemType, itemLink)
        if ok then
            return itemType
        end
    end
    return nil
end

local function SafeGetResultLinkFromRecipeLink(recipeLink)
    if type(recipeLink) ~= "string" or recipeLink == "" then
        return ""
    end
    if type(GetItemLinkRecipeResultItemLink) ~= "function" then
        return ""
    end

    local ok, resultLink = pcall(GetItemLinkRecipeResultItemLink, recipeLink, LINK_STYLE_DEFAULT)
    if ok and type(resultLink) == "string" and resultLink ~= "" then
        return resultLink
    end

    ok, resultLink = pcall(GetItemLinkRecipeResultItemLink, recipeLink)
    if ok and type(resultLink) == "string" and resultLink ~= "" then
        return resultLink
    end

    return ""
end

local function GetSourceHint(planName)
    local n = Lower(planName)
    if n == "" then
        return "Unknown source"
    end

    if n:find("^praxis:") then
        return "Dwemer/clockwork style sources, containers, and dailies"
    elseif n:find("^blueprint:") then
        return "Containers, thieves troves, and zone loot"
    elseif n:find("^pattern:") then
        return "Containers, cloth-related loot pools, and dailies"
    elseif n:find("^diagram:") then
        return "Crafting containers and zone loot"
    elseif n:find("^design:") then
        return "Containers, pickpocket, and zone loot"
    elseif n:find("^formula:") then
        return "Alchemy/utility loot pools and containers"
    elseif n:find("^sketch:") then
        return "Containers and regional furnishing loot pools"
    end

    return "Containers, dailies, and regional furnishing loot pools"
end

local function IsFurnishingPlanName(planName)
    local n = Lower(planName)
    if n == "" then
        return false
    end
    return n:find("^blueprint:") ~= nil
        or n:find("^praxis:") ~= nil
        or n:find("^pattern:") ~= nil
        or n:find("^diagram:") ~= nil
        or n:find("^design:") ~= nil
        or n:find("^formula:") ~= nil
        or n:find("^sketch:") ~= nil
end

FT.FILTERS = {
    { label = "All Plans", fn = function(e) return true end },
    { label = "Unknown", fn = function(e) return not e.known end },
    { label = "Known", fn = function(e) return e.known end },
    { label = "Legendary", fn = function(e) return (e.qualityTier or RARITY_COMMON) == RARITY_LEGENDARY end },
    { label = "Epic", fn = function(e) return (e.qualityTier or RARITY_COMMON) == RARITY_EPIC end },
    { label = "Superior", fn = function(e) return (e.qualityTier or RARITY_COMMON) == RARITY_SUPERIOR end },
    { label = "Fine", fn = function(e) return (e.qualityTier or RARITY_COMMON) == RARITY_FINE end },
    { label = "Common", fn = function(e) return (e.qualityTier or RARITY_COMMON) == RARITY_COMMON end },
}
FT.filterIndex = 1

function FT:GetCurrentFilterLabel()
    local f = self.FILTERS[self.filterIndex] or self.FILTERS[1]
    return "Filter: " .. tostring(f.label or "All")
end

function FT:CycleFilter()
    self.filterIndex = (self.filterIndex % #self.FILTERS) + 1
    self.searchText = ""
    self:FilterAndSort()
end

function FT:NeedsCollect(force)
    if force then
        return true
    end
    if not self.entries or #self.entries == 0 then
        return true
    end
    return (GetNowS() - (self.lastCollectS or 0)) >= (self.collectIntervalS or 45)
end

function FT:CollectData()
    self.entries = {}
    local recipeIndexMap = BuildRecipeIndexMap()
    self.recipeIndexMap = recipeIndexMap
    self.planSlotMap = BuildBackpackPlanSlotMap()
    local uniqueResultIds = {}

    -- Preferred path: LibCharacterKnowledge provides furnishing plan data
    -- without requiring crafting-station context.
    local lck = _G["LibCharacterKnowledge"]
    local usedLck = false
    if lck
        and type(lck.GetItemIdsForCategory) == "function"
        and type(lck.GetItemKnowledgeForCharacter) == "function"
        and type(lck.GetItemLinkFromItemId) == "function"
        and type(lck.GetItemName) == "function"
        and type(lck.ITEM_CATEGORY_PLAN) == "number"
    then
        local okIds, ids = pcall(lck.GetItemIdsForCategory, lck.ITEM_CATEGORY_PLAN)
        if okIds and type(ids) == "table" and #ids > 0 then
            usedLck = true
            for _, itemId in ipairs(ids) do
                local link = lck.GetItemLinkFromItemId(itemId)
                if type(link) == "string" and link ~= "" then
                    local knowledge = lck.GetItemKnowledgeForCharacter(link)
                    local known = (knowledge == lck.KNOWLEDGE_KNOWN)
                    local planName = lck.GetItemName(link)
                    if planName == "" then
                        planName = SafeLinkName(link)
                    end

                    local resultLink = SafeGetResultLinkFromRecipeLink(link)
                    local listIndex = 0
                    local recipeIndex = 0
                    if type(GetItemLinkItemId) == "function" then
                        local okId, linkItemId = pcall(GetItemLinkItemId, link)
                        if okId and type(linkItemId) == "number" and recipeIndexMap.byItemId and recipeIndexMap.byItemId[linkItemId] then
                            listIndex = recipeIndexMap.byItemId[linkItemId].listIndex or 0
                            recipeIndex = recipeIndexMap.byItemId[linkItemId].recipeIndex or 0
                        end
                    end
                    if (listIndex <= 0 or recipeIndex <= 0) and recipeIndexMap.byName then
                        local nameKey = Lower(planName)
                        local mapped = recipeIndexMap.byName[nameKey]
                        if mapped then
                            listIndex = mapped.listIndex or 0
                            recipeIndex = mapped.recipeIndex or 0
                        end
                    end

                    local resultName = SafeLinkName(resultLink)
                    local qualityTier = ResolveEntryQualityTier(link, resultLink)
                    local icon = SafeLinkIcon(link)
                    local source = GetSourceHint(planName)
                    local previewBagId, previewSlotIndex = nil, nil
                    if type(GetItemLinkItemId) == "function" and self.planSlotMap then
                        local okPid, planItemId = pcall(GetItemLinkItemId, link)
                        if okPid and type(planItemId) == "number" and self.planSlotMap[planItemId] then
                            previewBagId = self.planSlotMap[planItemId].bagId
                            previewSlotIndex = self.planSlotMap[planItemId].slotIndex
                        end
                    end
                    local resultId = 0
                    if type(GetItemLinkItemId) == "function" then
                        local okRid, rid = pcall(GetItemLinkItemId, resultLink)
                        if okRid and type(rid) == "number" then
                            resultId = rid
                        end
                    end
                    if resultId <= 0 then
                        resultId = itemId
                    end

                    if not uniqueResultIds[resultId] then
                        uniqueResultIds[resultId] = true

                        table.insert(self.entries, {
                            listIndex = listIndex,
                            recipeIndex = recipeIndex,
                            listName = "Furnishing Plans",
                            name = planName ~= "" and planName or "Unknown Plan",
                            resultName = resultName ~= "" and resultName or "Unknown Result",
                            known = known,
                            qualityTier = qualityTier,
                            quality = qualityTier, -- kept for UI compatibility
                            qualityHex = GetQualityHex(qualityTier),
                            qualityLabel = GetQualityLabel(qualityTier),
                            icon = icon,
                            source = source,
                            planLink = link,
                            previewBagId = previewBagId,
                            previewSlotIndex = previewSlotIndex,
                        })
                    end
                end
            end
        end
    end

    if usedLck and #self.entries > 0 then
        self.lastCollectS = GetNowS()
        self:FilterAndSort()
        return
    end

    local listCount = SafeGetNumRecipeLists()
    for listIndex = 1, listCount do
        local listName = SafeGetRecipeListName(listIndex)
        local recipeCount = SafeGetNumRecipesInList(listIndex)
        for recipeIndex = 1, recipeCount do
            local known = SafeIsRecipeKnown(listIndex, recipeIndex)
            local okInfo, recipeInfo = SafeGetRecipeInfo(listIndex, recipeIndex)
            local infoName = (okInfo and recipeInfo and type(recipeInfo[2]) == "string") and recipeInfo[2] or ""
            local resultLink = SafeGetRecipeResultLink(listIndex, recipeIndex)
            local itemType = SafeLinkItemType(resultLink)
            local recipeLink = SafeGetRecipeItemLink(listIndex, recipeIndex)
            local planName = SafeLinkName(recipeLink)
            if planName == "" then
                planName = infoName
            end

            if itemType == ITEMTYPE_FURNISHING or IsFurnishingPlanName(planName) then
                local recipeLink = SafeGetRecipeItemLink(listIndex, recipeIndex)
                local resultName = SafeLinkName(resultLink)
                if planName == "" then
                    planName = infoName ~= "" and infoName or resultName
                end
                local icon = SafeLinkIcon(recipeLink ~= "" and recipeLink or resultLink)
                local source = GetSourceHint(planName)
                local previewBagId, previewSlotIndex = nil, nil
                if type(GetItemLinkItemId) == "function" and self.planSlotMap then
                    local keyLink = (recipeLink ~= "" and recipeLink) or resultLink
                    local okPid, planItemId = pcall(GetItemLinkItemId, keyLink)
                    if okPid and type(planItemId) == "number" and self.planSlotMap[planItemId] then
                        previewBagId = self.planSlotMap[planItemId].bagId
                        previewSlotIndex = self.planSlotMap[planItemId].slotIndex
                    end
                end
                local resultId = 0
                if type(GetItemLinkItemId) == "function" then
                    local okRid, rid = pcall(GetItemLinkItemId, resultLink)
                    if okRid and type(rid) == "number" then
                        resultId = rid
                    end
                end
                if resultId <= 0 then
                    resultId = (type(GetItemLinkItemId) == "function" and GetItemLinkItemId(recipeLink)) or (listIndex * 100000 + recipeIndex)
                end

                if not uniqueResultIds[resultId] then
                    uniqueResultIds[resultId] = true
                    local qualityTier = ResolveEntryQualityTier(recipeLink, resultLink)
                    table.insert(self.entries, {
                        listIndex = listIndex,
                        recipeIndex = recipeIndex,
                        listName = listName,
                        name = planName ~= "" and planName or "Unknown Plan",
                        resultName = resultName ~= "" and resultName or "Unknown Result",
                        known = known,
                        qualityTier = qualityTier,
                        quality = qualityTier, -- kept for UI compatibility
                        qualityHex = GetQualityHex(qualityTier),
                        qualityLabel = GetQualityLabel(qualityTier),
                        icon = icon,
                        source = source,
                        planLink = recipeLink,
                        previewBagId = previewBagId,
                        previewSlotIndex = previewSlotIndex,
                    })
                end
            end
        end
    end

    self.lastCollectS = GetNowS()
    self:FilterAndSort()
end

function FT:ResolvePreviewRecipeForEntry(entry)
    if not entry then
        return 0, 0
    end
    local listIndex = tonumber(entry.listIndex) or 0
    local recipeIndex = tonumber(entry.recipeIndex) or 0
    if listIndex > 0 and recipeIndex > 0 then
        return listIndex, recipeIndex
    end

    local map = self.recipeIndexMap
    if not map then
        map = BuildRecipeIndexMap()
        self.recipeIndexMap = map
    end
    if not map then
        return 0, 0
    end

    local planLink = entry.planLink or ""
    if planLink ~= "" and type(GetItemLinkItemId) == "function" and map.byItemId then
        local ok, planItemId = pcall(GetItemLinkItemId, planLink)
        if ok and type(planItemId) == "number" and map.byItemId[planItemId] then
            local mapped = map.byItemId[planItemId]
            return mapped.listIndex or 0, mapped.recipeIndex or 0
        end
    end

    if map.byName then
        local key = Lower(entry.name or "")
        local mapped = map.byName[key]
        if mapped then
            return mapped.listIndex or 0, mapped.recipeIndex or 0
        end
    end

    return 0, 0
end

function FT:FilterAndSort()
    self.filteredList = {}
    local filter = self.FILTERS[self.filterIndex] or self.FILTERS[1]
    local search = PrepareSearch(self.searchText)

    for _, entry in ipairs(self.entries) do
        local pass = true
        if filter and filter.fn then
            local ok, result = pcall(filter.fn, entry)
            pass = ok and result or false
        end
        if pass and search then
            local haystack = Lower(
                tostring(entry.name or "") .. " "
                .. tostring(entry.resultName or "") .. " "
                .. tostring(entry.source or "") .. " "
                .. tostring(entry.listName or "")
            )
            if not haystack:find(search, 1, true) then
                pass = false
            end
        end
        if pass then
            table.insert(self.filteredList, entry)
        end
    end

    table.sort(self.filteredList, function(a, b)
        if a.known ~= b.known then
            return (not a.known) and b.known
        end
        if (a.qualityTier or RARITY_COMMON) ~= (b.qualityTier or RARITY_COMMON) then
            return (a.qualityTier or RARITY_COMMON) > (b.qualityTier or RARITY_COMMON)
        end
        return Lower(a.name) < Lower(b.name)
    end)
end

function FT:EnsureDataFresh(force)
    if self:NeedsCollect(force) then
        self:CollectData()
    else
        self:FilterAndSort()
    end
end

function FT:GetStats()
    local total = #self.entries
    local showing = #self.filteredList
    local known = 0
    for _, e in ipairs(self.entries) do
        if e.known then
            known = known + 1
        end
    end
    return total, showing, known, total - known
end

function FT:ToggleWindow()
    if FT_UI then
        FT_UI:Toggle()
    end
end

function FT:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide("FurnishingTrackerSV", SAVED_VAR_VERSION, nil, SV_DEFAULTS)
    self.filterIndex = self.savedVars.filterIndex or 1
    if self.filterIndex < 1 or self.filterIndex > #self.FILTERS then
        self.filterIndex = 1
    end

    SLASH_COMMANDS["/ft"] = function()
        self:ToggleWindow()
    end
end

function FT:LateInitialize()
    if FT_UI then
        FT_UI:Initialize()
        FT_UI:LateInit()
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= FT.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(FT.name, EVENT_ADD_ON_LOADED)
    FT:Initialize()
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(FT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    zo_callLater(function()
        FT:LateInitialize()
    end, 2000)
end

EVENT_MANAGER:RegisterForEvent(FT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(FT.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
