ResearchTracker = ResearchTracker or {}
local RT = ResearchTracker

RT.name = "ResearchTracker"
RT.version = "1.0.27"
RT.compatibleAddonNames = {
    ["ResearchTracker"] = true,
    ["Research Tracker"] = true,
}

RT.savedVars = nil
RT.accountVars = nil

RT.CRAFTS = {
    { key = "blacksmithing", label = "Blacksmithing", craftType = CRAFTING_TYPE_BLACKSMITHING },
    { key = "clothing", label = "Clothing", craftType = CRAFTING_TYPE_CLOTHIER },
    { key = "woodworking", label = "Woodworking", craftType = CRAFTING_TYPE_WOODWORKING },
    { key = "jewelry", label = "Jewelry", craftType = CRAFTING_TYPE_JEWELRYCRAFTING },
}

local SV_VERSION = 1
local SV_DEFAULTS = {
    lastCraftIndex = 1,
}
local ACCOUNT_DEFAULTS = {
    characters = {},
    preferredCrafterId = nil,
    preferredCrafterName = nil,
    craftQueue = {},
    dailyPlan = {},
    autoCraftEnabled = true,
    lastSessionCharacterId = nil,
}

local function Msg(text)
    d(string.format("[ResearchTracker] %s", tostring(text)))
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end
    local ok, a, b, c, d1, e, f, g, h, i, j, k = pcall(fn, ...)
    if not ok then
        return nil
    end
    return a, b, c, d1, e, f, g, h, i, j, k
end

local function NormalizeToken(text)
    local s = tostring(text or "")
    s = zo_strlower(s)
    s = s:gsub("%s+", "")
    return s
end

local LINE_TOKEN_MAP = {
    { key = "battleaxe", pats = { "battleaxe", "kriegsaxt" } },
    { key = "greatsword", pats = { "greatsword", "zweihander" } },
    { key = "lightningstaff", pats = { "lightningstaff", "blitzstab" } },
    { key = "infernostaff", pats = { "infernostaff", "flammenstab" } },
    { key = "restorationstaff", pats = { "restorationstaff", "heilungsstab" } },
    { key = "froststaff", pats = { "froststaff", "eisstab" } },
    { key = "necklace", pats = { "necklace", "halskette" } },
    { key = "shoulders", pats = { "shoulders", "schultern" } },
    { key = "gauntlets", pats = { "gauntlets", "handschuhe" } },
    { key = "greaves", pats = { "greaves", "beinschienen" } },
    { key = "cuirass", pats = { "cuirass", "harnisch" } },
    { key = "sabatons", pats = { "sabatons", "stiefel" } },
    { key = "bracers", pats = { "bracers", "armschienen" } },
    { key = "breeches", pats = { "breeches", "hosen" } },
    { key = "epaulets", pats = { "epaulets", "schulterklappen" } },
    { key = "jack", pats = { "jack", "wams" } },
    { key = "ring", pats = { "ring" } },
    { key = "shield", pats = { "shield", "schild" } },
    { key = "bow", pats = { "bow", "bogen" } },
    { key = "dagger", pats = { "dagger", "dolch" } },
    { key = "axe", pats = { "axe", "axt" } },
    { key = "mace", pats = { "mace", "kolben" } },
    { key = "sword", pats = { "sword", "schwert" } },
    { key = "maul", pats = { "maul", "streitkolben" } },
    { key = "helm", pats = { "helm" } },
    { key = "belt", pats = { "belt", "gurtel" } },
    { key = "robe", pats = { "robe" } },
    { key = "hat", pats = { "hat", "hut" } },
    { key = "gloves", pats = { "gloves", "handschuhe" } },
    { key = "boots", pats = { "boots", "stiefel" } },
}

local function BuildLineToken(text)
    local token = NormalizeToken(text)
    if token == "" then
        return nil
    end
    for _, row in ipairs(LINE_TOKEN_MAP) do
        for _, pat in ipairs(row.pats) do
            if token:find(pat, 1, true) then
                return row.key
            end
        end
    end
    return token
end

function RT:GetNowTimestamp()
    return (type(GetTimeStamp) == "function" and GetTimeStamp()) or 0
end

function RT:FormatSeconds(seconds)
    if type(seconds) ~= "number" or seconds <= 0 then
        return "Ready"
    end
    local total = math.floor(seconds + 0.5)
    local days = math.floor(total / 86400)
    total = total % 86400
    local hours = math.floor(total / 3600)
    total = total % 3600
    local mins = math.floor(total / 60)
    local secs = total % 60
    if days > 0 then
        return string.format("%dd %02dh %02dm", days, hours, mins)
    end
    if hours > 0 then
        return string.format("%02dh %02dm %02ds", hours, mins, secs)
    end
    return string.format("%02dm %02ds", mins, secs)
end

function RT:GetCraftDefinition(craftIndex)
    if type(craftIndex) ~= "number" then
        return nil
    end
    return self.CRAFTS[craftIndex]
end

function RT:GetCurrentCharacterIdString()
    local charId = SafeCall(GetCurrentCharacterId)
    if type(charId) == "number" then
        return tostring(charId)
    end
    local name = SafeCall(GetUnitName, "player")
    if type(name) == "string" and name ~= "" then
        return string.format("name:%s", name)
    end
    return "unknown"
end

function RT:GetCurrentCharacterName()
    local name = SafeCall(GetUnitName, "player")
    if type(name) == "string" and name ~= "" then
        return zo_strformat("<<1>>", name)
    end
    local display = SafeCall(GetDisplayName)
    if type(display) == "string" and display ~= "" then
        return display
    end
    return "Unknown Character"
end

function RT:GetTraitNameFromType(traitType, fallback)
    if type(traitType) == "number" and type(GetString) == "function" then
        local ok, resolved = pcall(function()
            return GetString("SI_ITEMTRAITTYPE", traitType)
        end)
        if ok and type(resolved) == "string" and resolved ~= "" then
            return resolved
        end
    end
    if type(fallback) == "string" and fallback ~= "" then
        return fallback
    end
    return "Trait"
end

function RT:IsNirnhonedTrait(traitType, traitName)
    if type(traitType) == "number" then
        if ITEM_TRAIT_TYPE_ARMOR_NIRNHONED and traitType == ITEM_TRAIT_TYPE_ARMOR_NIRNHONED then
            return true
        end
        if ITEM_TRAIT_TYPE_WEAPON_NIRNHONED and traitType == ITEM_TRAIT_TYPE_WEAPON_NIRNHONED then
            return true
        end
    end
    local token = NormalizeToken(traitName or "")
    if token ~= "" and (token:find("nirnhoned", 1, true) or token:find("nirnhon", 1, true)) then
        return true
    end
    return false
end

function RT:CaptureTrait(craftType, lineIndex, traitIndex, lineName, nowTs)
    local traitType, traitDescription, known = SafeCall(
        GetSmithingResearchLineTraitInfo,
        craftType,
        lineIndex,
        traitIndex
    )
    local duration, timeRemaining = SafeCall(
        GetSmithingResearchLineTraitTimes,
        craftType,
        lineIndex,
        traitIndex
    )

    local isKnown = (type(known) == "boolean" and known == true) or false
    local remaining = (type(timeRemaining) == "number" and timeRemaining > 0) and timeRemaining or 0
    local finishAt = nil
    if remaining > 0 then
        finishAt = nowTs + remaining
    end

    return {
        lineIndex = lineIndex,
        traitIndex = traitIndex,
        lineName = lineName,
        traitType = traitType,
        traitName = self:GetTraitNameFromType(traitType, traitDescription),
        known = isKnown,
        duration = (type(duration) == "number" and duration > 0) and duration or 0,
        finishAt = finishAt,
    }
end

function RT:CaptureCraftSnapshot(craftIndex, nowTs)
    local craft = self:GetCraftDefinition(craftIndex)
    if not craft then
        return nil
    end

    local lines = SafeCall(GetNumSmithingResearchLines, craft.craftType) or 0
    local maxSlots = SafeCall(GetMaxSimultaneousSmithingResearch, craft.craftType) or 0
    local items = {}

    for line = 1, lines do
        local lineName, _, traits = SafeCall(GetSmithingResearchLineInfo, craft.craftType, line)
        local normalizedLineName = tostring(lineName or string.format("Line %d", line))
        if traits and traits > 0 then
            for trait = 1, traits do
                items[#items + 1] = self:CaptureTrait(craft.craftType, line, trait, normalizedLineName, nowTs)
            end
        end
    end

    return {
        craftIndex = craftIndex,
        craftKey = craft.key,
        craftLabel = craft.label,
        maxSlots = maxSlots,
        items = items,
    }
end

function RT:RefreshCurrentCharacterSnapshot()
    if not self.accountVars or type(self.accountVars.characters) ~= "table" then
        return false
    end
    local charId = self:GetCurrentCharacterIdString()
    local nowTs = self:GetNowTimestamp()
    local previous = self.accountVars.characters[charId]

    local snapshot = {}
    snapshot.charId = charId
    snapshot.charName = self:GetCurrentCharacterName()
    snapshot.updatedAt = nowTs
    snapshot.crafts = {}
    local totalItems = 0

    for idx = 1, #self.CRAFTS do
        local craftData = self:CaptureCraftSnapshot(idx, nowTs)
        if craftData then
            snapshot.crafts[craftData.craftKey] = craftData
            totalItems = totalItems + #(craftData.items or {})
        end
    end

    -- During early login, API calls can transiently report no research lines.
    -- Keep older valid data instead of replacing it with an empty snapshot.
    if totalItems == 0 and type(previous) == "table" and type(previous.crafts) == "table" then
        local previousItems = 0
        for _, craftData in pairs(previous.crafts) do
            if type(craftData) == "table" then
                previousItems = previousItems + #((craftData.items) or {})
            end
        end
        if previousItems > 0 then
            previous.charName = snapshot.charName
            previous.updatedAt = nowTs
            self.accountVars.characters[charId] = previous
            return false
        end
    end

    self.accountVars.characters[charId] = snapshot
    return true
end

function RT:GetKnownCharacterIds()
    local ids = {}
    local map = (self.accountVars and self.accountVars.characters) or {}
    for charId, data in pairs(map) do
        if type(data) == "table" and data.crafts then
            ids[#ids + 1] = charId
        end
    end
    table.sort(ids, function(a, b)
        local da = map[a]
        local db = map[b]
        local na = (da and da.charName) or a
        local nb = (db and db.charName) or b
        return zo_strlower(tostring(na)) < zo_strlower(tostring(nb))
    end)
    return ids
end

function RT:GetCharacterDisplayName(charId)
    local data = self.accountVars and self.accountVars.characters and self.accountVars.characters[charId]
    if data and type(data.charName) == "string" and data.charName ~= "" then
        return data.charName
    end
    return tostring(charId or "Unknown")
end

function RT:NormalizeCharName(text)
    local s = tostring(text or "")
    s = zo_strformat("<<1>>", s)
    s = zo_strlower(s)
    s = s:gsub("%s+", "")
    return s
end

function RT:GetStoredCharIdByNameLike(charId)
    if not (self.accountVars and type(self.accountVars.characters) == "table") then
        return nil
    end
    local requestedName = self:NormalizeCharName(self:GetCharacterDisplayName(charId))
    if requestedName == "" then
        return nil
    end
    for id, data in pairs(self.accountVars.characters) do
        local name = type(data) == "table" and data.charName or id
        if self:NormalizeCharName(name) == requestedName then
            return id
        end
    end
    return nil
end

function RT:SetPreferredCrafterId(charId)
    if not self.accountVars or type(self.accountVars.characters) ~= "table" then
        return false
    end
    if not charId or not self.accountVars.characters[charId] then
        return false
    end
    self.accountVars.preferredCrafterId = charId
    local data = self.accountVars.characters[charId]
    self.accountVars.preferredCrafterName = (type(data) == "table" and data.charName) or nil
    return true
end

function RT:GetPreferredCrafterId()
    if not self.accountVars or type(self.accountVars.characters) ~= "table" then
        return nil
    end
    local preferredId = self.accountVars.preferredCrafterId
    if preferredId and self.accountVars.characters[preferredId] then
        return preferredId
    end

    -- Fallback: resolve by stored character name when ID format changed.
    local preferredName = self.accountVars.preferredCrafterName
    if type(preferredName) == "string" and preferredName ~= "" then
        local target = zo_strlower(zo_strformat("<<1>>", preferredName))
        for charId, data in pairs(self.accountVars.characters) do
            local name = type(data) == "table" and data.charName or nil
            if type(name) == "string" and name ~= "" then
                local normalized = zo_strlower(zo_strformat("<<1>>", name))
                if normalized == target then
                    self.accountVars.preferredCrafterId = charId
                    return charId
                end
            end
        end
    end
    return nil
end

function RT:EnsureCraftQueue()
    if not self.accountVars then
        return {}
    end
    if type(self.accountVars.craftQueue) ~= "table" then
        self.accountVars.craftQueue = {}
    end
    return self.accountVars.craftQueue
end

function RT:MakeQueueKey(targetCharId, craftKey, lineIndex, traitIndex)
    return string.format("%s|%s|%d|%d", tostring(targetCharId or "?"), tostring(craftKey or "?"), tonumber(lineIndex or 0), tonumber(traitIndex or 0))
end

function RT:IsQueued(targetCharId, craftKey, lineIndex, traitIndex)
    local queue = self:EnsureCraftQueue()
    local key = self:MakeQueueKey(targetCharId, craftKey, lineIndex, traitIndex)
    return queue[key] ~= nil
end

function RT:ToggleQueueItem(targetCharId, craftIndex, lineIndex, traitIndex)
    local resolvedTargetCharId = self:ResolveCharacterIdOrCurrent(targetCharId)
    if not resolvedTargetCharId then
        return false, false
    end
    local craftDef = self:GetCraftDefinition(craftIndex)
    if not craftDef then
        return false, false
    end
    local queue = self:EnsureCraftQueue()
    local key = self:MakeQueueKey(resolvedTargetCharId, craftDef.key, lineIndex, traitIndex)
    if queue[key] then
        queue[key] = nil
        return true, false
    end

    local detail = self:GetDetailForCraft(craftIndex, resolvedTargetCharId)
    if not detail then
        return false, false
    end

    local selected = nil
    for _, item in ipairs(detail.items or {}) do
        if item.lineIndex == lineIndex and item.traitIndex == traitIndex then
            selected = item
            break
        end
    end
    if not selected then
        return false, false
    end
    if self:IsNirnhonedTrait(selected.traitType, selected.name) then
        return false, false
    end

    queue[key] = {
        key = key,
        targetCharId = resolvedTargetCharId,
        targetCharName = detail.characterName,
        craftIndex = craftIndex,
        craftKey = craftDef.key,
        craftLabel = craftDef.label,
        lineIndex = lineIndex,
        traitIndex = traitIndex,
        traitType = selected.traitType,
        lineName = selected.lineName,
        traitName = selected.name,
        createdAt = self:GetNowTimestamp(),
    }
    return true, true
end

function RT:ResolveCharacterIdOrCurrent(charId)
    if charId and self.accountVars and self.accountVars.characters and self.accountVars.characters[charId] then
        return charId
    end
    local current = self:GetCurrentCharacterIdString()
    if self.accountVars and self.accountVars.characters and self.accountVars.characters[current] then
        return current
    end
    local ids = self:GetKnownCharacterIds()
    return ids[1]
end

function RT:BuildViewTrait(rawItem, nowTs)
    local finishAt = rawItem.finishAt
    local remaining = 0
    local state = "available"
    local known = rawItem.known == true

    if known then
        state = "completed"
    elseif type(finishAt) == "number" and finishAt > 0 then
        if finishAt > nowTs then
            state = "researching"
            remaining = finishAt - nowTs
        else
            -- Estimated complete since last snapshot.
            state = "completed"
            known = true
        end
    end

    return {
        lineIndex = rawItem.lineIndex,
        traitIndex = rawItem.traitIndex,
        lineName = rawItem.lineName,
        traitType = rawItem.traitType,
        name = rawItem.traitName or "Trait",
        state = state,
        remaining = remaining,
        known = known,
    }
end

function RT:GetDetailForCraft(craftIndex, charId)
    local craft = self:GetCraftDefinition(craftIndex)
    if not craft then
        return nil
    end
    local resolvedCharId = self:ResolveCharacterIdOrCurrent(charId)
    if not resolvedCharId then
        return nil
    end
    local charData = self.accountVars.characters[resolvedCharId]
    if not charData or not charData.crafts then
        return nil
    end
    local rawCraft = charData.crafts[craft.key]
    if not rawCraft then
        return nil
    end

    local nowTs = self:GetNowTimestamp()
    local items = {}
    local active = {}
    local completed = 0
    local researching = 0
    local available = 0

    for _, rawItem in ipairs(rawCraft.items or {}) do
        local item = self:BuildViewTrait(rawItem, nowTs)
        items[#items + 1] = item
        if item.state == "researching" then
            researching = researching + 1
            active[#active + 1] = item
        elseif item.state == "completed" then
            completed = completed + 1
        else
            available = available + 1
        end
    end

    table.sort(active, function(a, b)
        return (a.remaining or 0) < (b.remaining or 0)
    end)

    local total = #items
    local maxSlots = rawCraft.maxSlots or 0
    local freeSlots = zo_max((maxSlots or 0) - researching, 0)

    return {
        characterId = resolvedCharId,
        characterName = self:GetCharacterDisplayName(resolvedCharId),
        craftIndex = craftIndex,
        craftKey = craft.key,
        craftLabel = craft.label,
        total = total,
        completed = completed,
        researching = researching,
        available = available,
        maxSlots = maxSlots,
        freeSlots = freeSlots,
        activeResearch = active,
        items = items,
    }
end

function RT:GetTraitRuntimeState(craftIndex, lineIndex, traitIndex)
    local craftDef = self:GetCraftDefinition(craftIndex)
    if not craftDef then
        return "unknown"
    end
    if type(GetSmithingResearchLineTraitInfo) ~= "function" then
        return "unknown"
    end
    local _, _, known = SafeCall(GetSmithingResearchLineTraitInfo, craftDef.craftType, lineIndex, traitIndex)
    if known == true then
        return "completed"
    end
    local _, remaining = SafeCall(GetSmithingResearchLineTraitTimes, craftDef.craftType, lineIndex, traitIndex)
    if type(remaining) == "number" and remaining > 0 then
        return "researching"
    end
    return "available"
end

function RT:GetSummaryRows(charId)
    local rows = {}
    local resolvedCharId = self:ResolveCharacterIdOrCurrent(charId)
    if not resolvedCharId then
        return rows
    end
    for idx = 1, #self.CRAFTS do
        local snapshot = self:GetDetailForCraft(idx, resolvedCharId)
        if snapshot then
            local slotsText = ""
            if snapshot.maxSlots and snapshot.maxSlots > 0 and snapshot.freeSlots ~= nil then
                slotsText = string.format("  Slots %d/%d", snapshot.freeSlots, snapshot.maxSlots)
            end
            local nextText = "Ready"
            if snapshot.researching > 0 and snapshot.activeResearch[1] then
                nextText = self:FormatSeconds(snapshot.activeResearch[1].remaining)
            end
            rows[#rows + 1] = {
                craftIndex = idx,
                title = snapshot.craftLabel,
                detail = string.format(
                    "Done %d/%d  Active %d  Next %s%s",
                    snapshot.completed,
                    snapshot.total,
                    snapshot.researching,
                    nextText,
                    slotsText
                ),
                snapshot = snapshot,
            }
        end
    end
    return rows
end

function RT:BuildShoppingRows(targetCharId, craftIndex, crafterCharId)
    local target = self:GetDetailForCraft(craftIndex, targetCharId)
    local crafter = self:GetDetailForCraft(craftIndex, crafterCharId)
    if not target or not crafter then
        return {}
    end

    local crafterKnown = {}
    for _, item in ipairs(crafter.items or {}) do
        if item.state == "completed" then
            local key = string.format("%d:%d", item.lineIndex or 0, item.traitIndex or 0)
            crafterKnown[key] = true
        end
    end

    local rows = {}
    for _, item in ipairs(target.items or {}) do
        if item.state ~= "completed" and item.state ~= "researching" then
            if not self:IsNirnhonedTrait(item.traitType, item.name) then
                local key = string.format("%d:%d", item.lineIndex or 0, item.traitIndex or 0)
                local canCraftNow = crafterKnown[key] == true
                local queued = self:IsQueued(target.characterId, target.craftKey, item.lineIndex, item.traitIndex)
                rows[#rows + 1] = {
                    title = string.format("%s - %s", item.lineName or "Line", item.name or "Trait"),
                    detail = canCraftNow and "Target needs this - crafter CAN craft now" or "Target needs this - crafter MISSING trait",
                    state = canCraftNow and "craftable" or "missing",
                    canCraftNow = canCraftNow,
                    lineIndex = item.lineIndex,
                    traitIndex = item.traitIndex,
                    traitType = item.traitType,
                    queued = queued,
                }
            end
        end
    end

    table.sort(rows, function(a, b)
        if (a.canCraftNow and 1 or 2) ~= (b.canCraftNow and 1 or 2) then
            return (a.canCraftNow and 1 or 2) < (b.canCraftNow and 1 or 2)
        end
        return tostring(a.title or "") < tostring(b.title or "")
    end)
    return rows
end

function RT:BuildQueuedRows(targetCharId, craftIndex, crafterCharId)
    local detail = self:GetDetailForCraft(craftIndex, crafterCharId)
    local target = self:GetDetailForCraft(craftIndex, targetCharId)
    local craftDef = self:GetCraftDefinition(craftIndex)
    if not detail or not craftDef or not target then
        return {}
    end

    local crafterKnown = {}
    for _, item in ipairs(detail.items or {}) do
        if item.state == "completed" then
            local key = string.format("%d:%d", item.lineIndex or 0, item.traitIndex or 0)
            crafterKnown[key] = true
        end
    end

    local queue = self:EnsureCraftQueue()
    local rows = {}
    for _, entry in pairs(queue) do
        if entry.targetCharId == target.characterId and entry.craftIndex == craftIndex then
            local knownKey = string.format("%d:%d", entry.lineIndex or 0, entry.traitIndex or 0)
            local canCraftNow = crafterKnown[knownKey] == true
            rows[#rows + 1] = {
                title = string.format("%s - %s", entry.lineName or "Line", entry.traitName or "Trait"),
                detail = canCraftNow and "Queued - craftable now" or "Queued - crafter missing trait",
                state = canCraftNow and "craftable" or "missing",
                canCraftNow = canCraftNow,
                lineIndex = entry.lineIndex,
                traitIndex = entry.traitIndex,
                traitType = entry.traitType,
                queued = true,
            }
        end
    end

    table.sort(rows, function(a, b)
        if (a.canCraftNow and 1 or 2) ~= (b.canCraftNow and 1 or 2) then
            return (a.canCraftNow and 1 or 2) < (b.canCraftNow and 1 or 2)
        end
        return tostring(a.title or "") < tostring(b.title or "")
    end)
    return rows
end

function RT:RemoveQueueKey(queueKey)
    local queue = self:EnsureCraftQueue()
    if queue[queueKey] then
        queue[queueKey] = nil
        return true
    end
    return false
end

function RT:GetQueuedCountForCraft(craftIndex)
    local queue = self:EnsureCraftQueue()
    local total = 0
    for _, entry in pairs(queue) do
        if entry.craftIndex == craftIndex then
            total = total + 1
        end
    end
    return total
end

function RT:GetDailyQueueLimitForCraft(craftIndex)
    local craftDef = self:GetCraftDefinition(craftIndex)
    if not craftDef then
        return 0
    end
    if craftDef.craftType == CRAFTING_TYPE_JEWELRYCRAFTING then
        return 1
    end
    return 3
end

function RT:IsEquippableResearchItem(bagId, slotIndex)
    local stack = SafeCall(GetSlotStackSize, bagId, slotIndex) or 0
    if stack <= 0 then
        return false
    end
    if type(IsItemPlayerLocked) == "function" and IsItemPlayerLocked(bagId, slotIndex) then
        return false
    end
    local traitType = SafeCall(GetItemTrait, bagId, slotIndex)
    if type(traitType) ~= "number" or traitType <= 0 then
        return false
    end
    local name = SafeCall(GetItemName, bagId, slotIndex)
    if self:IsNirnhonedTrait(traitType, name) then
        return false
    end
    local equipType = SafeCall(GetItemEquipType, bagId, slotIndex)
    if type(equipType) ~= "number" or equipType == EQUIP_TYPE_INVALID then
        return false
    end
    return true
end

function RT:AutoDepositResearchItemsToBank()
    if type(IsBankOpen) ~= "function" or not IsBankOpen() then
        return false, "Open the bank first, then run /rt bank."
    end

    if self.bankDepositState and self.bankDepositState.running then
        return false, "Deposit already running. Please wait."
    end

    local slots = {}
    local backpackSize = SafeCall(GetBagSize, BAG_BACKPACK) or 0
    for slotIndex = 0, backpackSize - 1 do
        if self:IsEquippableResearchItem(BAG_BACKPACK, slotIndex) then
            slots[#slots + 1] = slotIndex
        end
    end
    if #slots <= 0 then
        return false, "No research items found in backpack."
    end

    self.bankDepositState = {
        running = true,
        slots = slots,
        index = 1,
        moved = 0,
        skipped = 0,
    }

    local function Finish()
        local state = self.bankDepositState
        if not state then
            return
        end
        self.bankDepositState = nil
        if state.moved <= 0 then
            Msg(string.format("No research items deposited. Skipped %d.", state.skipped or 0))
        else
            Msg(string.format("Deposited %d research items to bank. Skipped %d.", state.moved or 0, state.skipped or 0))
        end
    end

    local function Step()
        local state = self.bankDepositState
        if not state or not state.running then
            return
        end
        if type(IsBankOpen) ~= "function" or not IsBankOpen() then
            state.running = false
            Msg("Deposit stopped: bank was closed.")
            return Finish()
        end
        if state.index > #state.slots then
            state.running = false
            return Finish()
        end

        local slotIndex = state.slots[state.index]
        state.index = state.index + 1
        if not self:IsEquippableResearchItem(BAG_BACKPACK, slotIndex) then
            state.skipped = state.skipped + 1
            return zo_callLater(Step, 40)
        end

        local targetBag = BAG_BANK
        local emptySlot = FindFirstEmptySlotInBag and FindFirstEmptySlotInBag(targetBag)
        if (not emptySlot) and BAG_SUBSCRIBER_BANK then
            targetBag = BAG_SUBSCRIBER_BANK
            emptySlot = FindFirstEmptySlotInBag and FindFirstEmptySlotInBag(targetBag)
        end
        if not emptySlot then
            state.running = false
            Msg("Deposit stopped: bank is full.")
            return Finish()
        end

        local beforeStack = SafeCall(GetSlotStackSize, BAG_BACKPACK, slotIndex) or 0
        if beforeStack <= 0 then
            state.skipped = state.skipped + 1
            return zo_callLater(Step, 40)
        end

        local requested = false
        if CallSecureProtected then
            local ok, result = pcall(CallSecureProtected, "RequestMoveItem", BAG_BACKPACK, slotIndex, targetBag, emptySlot, beforeStack)
            requested = ok and (result ~= false)
        elseif RequestMoveItem then
            local ok, result = pcall(RequestMoveItem, BAG_BACKPACK, slotIndex, targetBag, emptySlot, beforeStack)
            requested = ok and (result ~= false)
        end
        if not requested then
            state.skipped = state.skipped + 1
            return zo_callLater(Step, 60)
        end

        zo_callLater(function()
            local afterStack = SafeCall(GetSlotStackSize, BAG_BACKPACK, slotIndex) or 0
            if afterStack < beforeStack then
                state.moved = state.moved + 1
            else
                state.skipped = state.skipped + 1
            end
            zo_callLater(Step, 40)
        end, 130)
    end

    zo_callLater(Step, 40)
    return true, string.format("Deposit started for %d items...", #slots)
end

function RT:GetResearchSearchBags(includeBank)
    local bags = { BAG_BACKPACK }
    if includeBank and type(IsBankOpen) == "function" and IsBankOpen() then
        bags[#bags + 1] = BAG_BANK
        if BAG_SUBSCRIBER_BANK then
            bags[#bags + 1] = BAG_SUBSCRIBER_BANK
        end
    end
    return bags
end

function RT:GetSlotQualityForSafety(bagId, slotIndex)
    local quality = SafeCall(GetItemQuality, bagId, slotIndex)
    if type(quality) == "number" then
        return quality
    end
    local link = SafeCall(GetItemLink, bagId, slotIndex)
    if type(link) == "string" and link ~= "" then
        local displayQ = SafeCall(GetItemLinkDisplayQuality, link)
        if type(displayQ) == "number" then
            return displayQ
        end
    end
    return -1
end

function RT:IsHighValueResearchItem(bagId, slotIndex)
    local q = self:GetSlotQualityForSafety(bagId, slotIndex)
    if q < 0 then
        return false
    end
    if ITEM_DISPLAY_QUALITY_EPIC and q >= ITEM_DISPLAY_QUALITY_EPIC then
        return true
    end
    if ITEM_QUALITY_EPIC and q >= ITEM_QUALITY_EPIC then
        return true
    end
    return false
end

function RT:IsCommonQualityItem(bagId, slotIndex)
    local q = self:GetSlotQualityForSafety(bagId, slotIndex)
    if q < 0 then
        return false
    end
    local common = ITEM_DISPLAY_QUALITY_NORMAL or ITEM_QUALITY_NORMAL or 1
    return q <= common
end

function RT:FindMatchingResearchSlotForTrait(craftIndex, lineIndex, traitType, includeBank, avoidHighValue)
    local craftDef = self:GetCraftDefinition(craftIndex)
    if not craftDef then
        return nil
    end
    local bags = self:GetResearchSearchBags(includeBank)
    local best = nil
    local bestQuality = 999
    local function ScanSlots(requireStrictResearchCheck)
        local candidate = nil
        local candidateQuality = 999
        for _, bagId in ipairs(bags) do
            local bagSize = SafeCall(GetBagSize, bagId) or 0
            for slotIndex = 0, bagSize - 1 do
                if self:CanSlotResearchTrait(bagId, slotIndex, craftDef.craftType, lineIndex, traitType, requireStrictResearchCheck) then
                    if avoidHighValue and bagId ~= BAG_BACKPACK and self:IsHighValueResearchItem(bagId, slotIndex) then
                        -- Never auto-withdraw expensive gear from bank.
                    else
                        local quality = self:GetSlotQualityForSafety(bagId, slotIndex)
                        if quality < 0 then
                            quality = 0
                        end
                        if (not candidate) or quality < candidateQuality then
                            local itemName = SafeCall(GetItemName, bagId, slotIndex)
                            candidateQuality = quality
                            candidate = {
                                bagId = bagId,
                                slotIndex = slotIndex,
                                itemName = (type(itemName) == "string" and itemName ~= "") and zo_strformat("<<1>>", itemName) or "Item",
                                quality = quality,
                            }
                        end
                    end
                end
            end
        end
        return candidate, candidateQuality
    end

    best, bestQuality = ScanSlots(true)
    if not best then
        -- Fallback pass for transient station UI/API states.
        best, bestQuality = ScanSlots(false)
    end
    return best
end

function RT:EnsureResearchModeReady()
    if not SMITHING_GAMEPAD then
        return
    end
    if SMITHING_GAMEPAD.SetMode and SMITHING_MODE_RESEARCH then
        pcall(function() SMITHING_GAMEPAD:SetMode(SMITHING_MODE_RESEARCH) end)
    end
    if SMITHING_GAMEPAD.researchPanel and SMITHING_GAMEPAD.researchPanel.PerformDeferredInitialization then
        pcall(function() SMITHING_GAMEPAD.researchPanel:PerformDeferredInitialization() end)
    end
end

function RT:CanSlotResearchTrait(bagId, slotIndex, craftType, lineIndex, traitType, requireStrictResearchCheck)
    local stack = SafeCall(GetSlotStackSize, bagId, slotIndex) or 0
    if stack <= 0 then
        return false
    end
    if type(IsItemPlayerLocked) == "function" and IsItemPlayerLocked(bagId, slotIndex) then
        return false
    end
    local itemTraitType = SafeCall(GetItemTrait, bagId, slotIndex)
    if type(itemTraitType) == "number" and self:IsNirnhonedTrait(itemTraitType, SafeCall(GetItemName, bagId, slotIndex)) then
        return false
    end
    if type(traitType) == "number" and type(itemTraitType) == "number" and itemTraitType ~= traitType then
        return false
    end
    if requireStrictResearchCheck ~= false and type(CanItemBeSmithingTraitResearched) == "function" then
        local ok, canResearch = pcall(CanItemBeSmithingTraitResearched, bagId, slotIndex, craftType, lineIndex)
        if ok and canResearch ~= nil then
            return canResearch == true
        end
    end
    return type(traitType) == "number" and type(itemTraitType) == "number" and itemTraitType == traitType
end
function RT:ResolveCurrentCharacterResearchCandidate(preferredCraftIndex, includeBank, blockedMap)
    if includeBank ~= true then
        self:EnsureResearchModeReady()
    end
    self:RefreshCurrentCharacterSnapshot()
    local currentCharId = self:GetCurrentCharacterIdString()
    local craftOrder = {}
    local seen = {}
    if type(preferredCraftIndex) == "number" and preferredCraftIndex >= 1 and preferredCraftIndex <= #self.CRAFTS then
        craftOrder[#craftOrder + 1] = preferredCraftIndex
        seen[preferredCraftIndex] = true
    end
    for idx = 1, #self.CRAFTS do
        if not seen[idx] then
            craftOrder[#craftOrder + 1] = idx
        end
    end

    for _, craftIndex in ipairs(craftOrder) do
        local detail = self:GetDetailForCraft(craftIndex, currentCharId)
        if detail then
            for _, row in ipairs(detail.items or {}) do
                if row.state == "available" and not self:IsNirnhonedTrait(row.traitType, row.name) then
                    local runtimeState = self:GetTraitRuntimeState(craftIndex, row.lineIndex, row.traitIndex)
                    if runtimeState == "completed" or runtimeState == "researching" then
                        -- Snapshot can lag briefly; always trust live state.
                    else
                    local candidateKey = string.format("%d:%d:%d", tonumber(craftIndex or 0), tonumber(row.lineIndex or 0), tonumber(row.traitIndex or 0))
                    if type(blockedMap) == "table" and blockedMap[candidateKey] == true then
                        -- Skip candidates that already failed in this run.
                    else
                    local slot = self:FindMatchingResearchSlotForTrait(craftIndex, row.lineIndex, row.traitType, includeBank == true, includeBank == true)
                    if slot then
                        local craftDef = self:GetCraftDefinition(craftIndex)
                        return {
                            craftIndex = craftIndex,
                            craftType = craftDef and craftDef.craftType,
                            craftLabel = craftDef and craftDef.label or "Craft",
                            lineIndex = row.lineIndex,
                            traitIndex = row.traitIndex,
                            traitType = row.traitType,
                            lineName = row.lineName or "Line",
                            traitName = row.name or "Trait",
                            itemSlot = slot,
                        }, nil
                    end
                    end
                    end
                end
            end
        end
    end

    if includeBank then
        return nil, "No matching research item found in backpack/bank for current character."
    end
    return nil, "No matching research item found in backpack for current character."
end

function RT:MoveResearchItemToBackpackIfNeeded(candidate, callback)
    if type(callback) ~= "function" then
        return
    end
    if not candidate or not candidate.itemSlot then
        callback(false, candidate, "Invalid research candidate.")
        return
    end
    local slot = candidate.itemSlot
    if slot.bagId == BAG_BACKPACK then
        callback(true, candidate, nil)
        return
    end
    local emptySlot = FindFirstEmptySlotInBag and FindFirstEmptySlotInBag(BAG_BACKPACK)
    if not emptySlot then
        callback(false, candidate, "Backpack is full. Free one slot first.")
        return
    end
    local moveOk = false
    if CallSecureProtected then
        local ok, result = pcall(CallSecureProtected, "RequestMoveItem", slot.bagId, slot.slotIndex, BAG_BACKPACK, emptySlot, 1)
        moveOk = ok and (result ~= false)
    elseif RequestMoveItem then
        local ok, result = pcall(RequestMoveItem, slot.bagId, slot.slotIndex, BAG_BACKPACK, emptySlot, 1)
        moveOk = ok and (result ~= false)
    end
    if not moveOk then
        callback(false, candidate, "Could not move the research item from bank to backpack.")
        return
    end
    zo_callLater(function()
        candidate.itemSlot.bagId = BAG_BACKPACK
        candidate.itemSlot.slotIndex = emptySlot
        callback(true, candidate, nil)
    end, 250)
end

function RT:TryStartSemiAutoResearch(candidate)
    if not candidate or not candidate.itemSlot then
        return false, "No research candidate."
    end
    if not SMITHING_GAMEPAD then
        return false, "Open a smithing station first, then run /rt alt."
    end
    if SMITHING_GAMEPAD.SetMode and SMITHING_MODE_RESEARCH then
        pcall(function() SMITHING_GAMEPAD:SetMode(SMITHING_MODE_RESEARCH) end)
    end
    if SMITHING_GAMEPAD.researchPanel and SMITHING_GAMEPAD.researchPanel.PerformDeferredInitialization then
        pcall(function() SMITHING_GAMEPAD.researchPanel:PerformDeferredInitialization() end)
    end

    local fn = _G["ResearchSmithingTrait"] or _G["StartSmithingResearch"] or _G["StartSmithingTraitResearch"]
    if type(fn) == "function" then
        local ok1, res1 = pcall(fn, candidate.craftType, candidate.lineIndex, candidate.traitIndex, candidate.itemSlot.bagId, candidate.itemSlot.slotIndex)
        if ok1 and res1 ~= false then
            return true, nil
        end
        local ok2, res2 = pcall(fn, candidate.craftType, candidate.lineIndex, candidate.traitIndex)
        if ok2 and res2 ~= false then
            return true, nil
        end
    end
    return false, "Ready to confirm: open Smithing > Research and confirm."
end

function RT:StartResearchForCurrentAltUntilSlotsFull(preferredCraftIndex)
    if not SMITHING_GAMEPAD then
        return false, "Open a smithing station first, then run /rt alt."
    end
    if type(preferredCraftIndex) ~= "number" then
        return false, "Open a Blacksmith/Clothing/Woodworking/Jewelry station first."
    end
    if self.altStartState and self.altStartState.running then
        return false, "Research start already running. Please wait."
    end

    local state = {
        running = true,
        started = 0,
        skipped = 0,
        attempts = 0,
        repeatedKeyCount = 0,
        lastKey = nil,
        blocked = {},
    }
    self.altStartState = state

    local function CandidateKey(candidate)
        return string.format(
            "%d:%d:%d",
            tonumber(candidate and candidate.craftIndex or 0) or 0,
            tonumber(candidate and candidate.lineIndex or 0) or 0,
            tonumber(candidate and candidate.traitIndex or 0) or 0
        )
    end

    local function Finish(message)
        local s = self.altStartState
        self.altStartState = nil
        if not s then
            return false, message or "Research start stopped."
        end
        local summary = string.format("Research start done: started %d, skipped %d.", s.started or 0, s.skipped or 0)
        if message and message ~= "" then
            summary = summary .. " " .. message
        end
        return true, summary
    end

    local function GetFreeSlotsForPreferredCraft()
        if type(preferredCraftIndex) ~= "number" then
            return nil
        end
        self:RefreshCurrentCharacterSnapshot()
        local detail = self:GetDetailForCraft(preferredCraftIndex, self:GetCurrentCharacterIdString())
        if not detail then
            return nil
        end
        return tonumber(detail.freeSlots or 0) or 0
    end

    local function Step()
        local s = self.altStartState
        if not s or not s.running then
            return
        end
        if (s.attempts or 0) >= 30 then
            local _, text = Finish("Safety stop: too many start attempts.")
            Msg(text)
            return
        end
        local freeSlots = GetFreeSlotsForPreferredCraft()
        if freeSlots ~= nil and freeSlots <= 0 then
            local _, text = Finish("No free research slots.")
            Msg(text)
            return
        end

        local candidate, _ = self:ResolveCurrentCharacterResearchCandidate(preferredCraftIndex, false, s.blocked)
        if not candidate then
            local _, text = Finish("No prepared research item in backpack.")
            Msg(text)
            return
        end
        local key = CandidateKey(candidate)
        if s.lastKey == key then
            s.repeatedKeyCount = (s.repeatedKeyCount or 0) + 1
        else
            s.lastKey = key
            s.repeatedKeyCount = 1
        end
        if (s.repeatedKeyCount or 0) >= 3 then
            s.blocked[key] = true
            s.skipped = (s.skipped or 0) + 1
            Msg(string.format("[Diag] blocked repeat candidate: %s - %s", candidate.lineName or "Line", candidate.traitName or "Trait"))
            return zo_callLater(Step, 120)
        end
        if s.blocked[key] then
            s.skipped = s.skipped + 1
            local _, text = Finish("No more valid candidates for current slots.")
            Msg(text)
            return
        end

        local liveState = self:GetTraitRuntimeState(candidate.craftIndex, candidate.lineIndex, candidate.traitIndex)
        if liveState == "completed" or liveState == "researching" then
            s.skipped = s.skipped + 1
            s.blocked[key] = true
            return zo_callLater(Step, 80)
        end

        local started, startErr = self:TryStartSemiAutoResearch(candidate)
        s.attempts = (s.attempts or 0) + 1
        if started then
            return zo_callLater(function()
                local s2 = self.altStartState
                if not s2 or not s2.running then
                    return
                end
                local verifyState = self:GetTraitRuntimeState(candidate.craftIndex, candidate.lineIndex, candidate.traitIndex)
                if verifyState == "researching" or verifyState == "completed" then
                    s2.started = (s2.started or 0) + 1
                    Msg(string.format("Research started: %s - %s", candidate.lineName or "Line", candidate.traitName or "Trait"))
                else
                    s2.skipped = (s2.skipped or 0) + 1
                    s2.blocked[key] = true
                    Msg(string.format("[Diag] start not confirmed, blocked: %s - %s", candidate.lineName or "Line", candidate.traitName or "Trait"))
                end
                zo_callLater(Step, 150)
            end, 400)
        end

        s.skipped = (s.skipped or 0) + 1
        s.blocked[key] = true
        if type(startErr) == "string" and startErr ~= "" then
            Msg(startErr)
        end
        return zo_callLater(Step, 100)
    end

    zo_callLater(Step, 50)
    return true, "Research start loop running..."
end

function RT:BuildCurrentCharacterBankFetchCandidates(preferredCraftIndex)
    self:RefreshCurrentCharacterSnapshot()
    local currentCharId = self:GetCurrentCharacterIdString()
    local resolvedCurrentCharId = self:GetStoredCharIdByNameLike(currentCharId) or currentCharId
    local diag = {
        currentCharId = resolvedCurrentCharId,
        bankIndexedItems = 0,
        queueEntries = 0,
        planEntries = 0,
        queueCandidates = 0,
        planCandidates = 0,
        fallbackCandidates = 0,
        selectedSource = "none",
        exactLineMatches = 0,
        fallbackLineMatches = 0,
        skippedLineMismatch = 0,
        queueSkippedKnown = 0,
        queueSkippedNirn = 0,
        queueSkippedNotRelevant = 0,
        queueSkippedNoBankMatch = 0,
        planSkippedKnown = 0,
        planSkippedNirn = 0,
        planSkippedNotRelevant = 0,
        planSkippedNoBankMatch = 0,
        selectedTraits = {},
    }
    local function AddDiagSample(list, text)
        if type(list) ~= "table" then
            return
        end
        if #list >= 5 then
            return
        end
        list[#list + 1] = tostring(text or "?")
    end
    local craftOrder = {}
    local seen = {}
    if type(preferredCraftIndex) == "number" and preferredCraftIndex >= 1 and preferredCraftIndex <= #self.CRAFTS then
        craftOrder[#craftOrder + 1] = preferredCraftIndex
        seen[preferredCraftIndex] = true
    end
    for idx = 1, #self.CRAFTS do
        if not seen[idx] then
            craftOrder[#craftOrder + 1] = idx
        end
    end

    local function BuildResearchSlotIndex()
        local byTraitBackpack = {}
        local byTraitBank = {}
        local bags = self:GetResearchSearchBags(true)
        for _, bagId in ipairs(bags) do
            local bagSize = (type(GetBagSize) == "function" and GetBagSize(bagId)) or 0
            for slotIndex = 0, bagSize - 1 do
                local stack = (type(GetSlotStackSize) == "function" and GetSlotStackSize(bagId, slotIndex)) or 0
                if stack > 0 then
                    local traitType = (type(GetItemTrait) == "function" and GetItemTrait(bagId, slotIndex)) or nil
                    if type(traitType) == "number" and traitType > 0 then
                        local itemNameRaw = (type(GetItemName) == "function" and GetItemName(bagId, slotIndex)) or ""
                        local itemName = (type(itemNameRaw) == "string" and itemNameRaw ~= "") and zo_strformat("<<1>>", itemNameRaw) or "Item"
                        if not self:IsNirnhonedTrait(traitType, itemName) then
                            local equipType = (type(GetItemEquipType) == "function" and GetItemEquipType(bagId, slotIndex)) or EQUIP_TYPE_INVALID
                            if type(equipType) == "number" and equipType ~= EQUIP_TYPE_INVALID then
                                local quality = self:GetSlotQualityForSafety(bagId, slotIndex)
                                if quality < 0 then
                                    quality = 0
                                end
                                local entry = {
                                    bagId = bagId,
                                    slotIndex = slotIndex,
                                    itemName = itemName,
                                    traitType = traitType,
                                    quality = quality,
                                    lineToken = BuildLineToken(itemName),
                                }
                                if bagId == BAG_BACKPACK then
                                    local list = byTraitBackpack[traitType] or {}
                                    list[#list + 1] = entry
                                    byTraitBackpack[traitType] = list
                                else
                                    -- Bank fetch hard-safety: only unlocked white/common items.
                                    if (not self:IsHighValueResearchItem(bagId, slotIndex))
                                        and self:IsCommonQualityItem(bagId, slotIndex)
                                        and (type(IsItemPlayerLocked) ~= "function" or not IsItemPlayerLocked(bagId, slotIndex)) then
                                        local list = byTraitBank[traitType] or {}
                                        list[#list + 1] = entry
                                        byTraitBank[traitType] = list
                                        diag.bankIndexedItems = (diag.bankIndexedItems or 0) + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        local function SortIndexLists(indexMap)
            for _, list in pairs(indexMap) do
                table.sort(list, function(a, b)
                    local qa = tonumber(a.quality or 0) or 0
                    local qb = tonumber(b.quality or 0) or 0
                    if qa ~= qb then
                        return qa < qb
                    end
                    return tonumber(a.slotIndex or 0) < tonumber(b.slotIndex or 0)
                end)
            end
        end
        SortIndexLists(byTraitBackpack)
        SortIndexLists(byTraitBank)
        return byTraitBackpack, byTraitBank
    end

    local function CanUseEntryForResearch(craftType, lineIndex, entry)
        if not entry then
            return false
        end
        -- Require exact line compatibility whenever API is available.
        if type(CanItemBeSmithingTraitResearched) == "function" then
            local ok, canResearch = pcall(CanItemBeSmithingTraitResearched, entry.bagId, entry.slotIndex, craftType, lineIndex)
            if ok and canResearch ~= nil then
                return canResearch == true
            end
        end
        -- If API is unavailable, keep permissive fallback to avoid total deadlock.
        return true
    end

    local function FindUsableEntry(entryList, craftType, lineIndex, desiredLineToken, usedMap, consume, requireResearchCheck)
        if type(entryList) ~= "table" then
            return nil
        end
        local function PickCandidate(strictCheck)
            local exactLineCandidate = nil
            local fallbackCandidate = nil
            local function IsJewelryLineSpecific(token)
                if type(token) ~= "string" then
                    return false
                end
                return token == "ring" or token == "necklace"
            end
            for _, entry in ipairs(entryList) do
                local key = string.format("%d:%d", tonumber(entry.bagId or -1), tonumber(entry.slotIndex or -1))
                local alreadyUsed = (type(usedMap) == "table" and usedMap[key] == true) or false
                if not alreadyUsed then
                    local lineMatches = true
                    local entryToken = tostring(entry.lineToken or "")
                    if desiredLineToken and desiredLineToken ~= "" and entryToken ~= desiredLineToken then
                        lineMatches = false
                        diag.skippedLineMismatch = (diag.skippedLineMismatch or 0) + 1
                    end
                    -- Hard protection for jewelry: never swap ring/necklace lines.
                    if craftType == CRAFTING_TYPE_JEWELRYCRAFTING
                        and IsJewelryLineSpecific(tostring(desiredLineToken or ""))
                        and IsJewelryLineSpecific(entryToken)
                        and entryToken ~= tostring(desiredLineToken or "") then
                        lineMatches = false
                        diag.skippedLineMismatch = (diag.skippedLineMismatch or 0) + 1
                    end

                    local canUse = true
                    if strictCheck and type(CanItemBeSmithingTraitResearched) == "function" then
                        canUse = CanUseEntryForResearch(craftType, lineIndex, entry)
                    end
                    if canUse then
                        if lineMatches and not exactLineCandidate then
                            exactLineCandidate = entry
                        elseif (not lineMatches) and (not fallbackCandidate) and (not desiredLineToken or desiredLineToken == "") then
                            -- Only allow fallback when there is no usable line token.
                            fallbackCandidate = entry
                        end
                    end
                end
            end
            if exactLineCandidate then
                return exactLineCandidate, true
            end
            if desiredLineToken and desiredLineToken ~= "" then
                -- When target line is known, never cross-line fallback.
                return nil, false
            end
            return fallbackCandidate, false
        end

        local chosen, isExact = PickCandidate(requireResearchCheck == true)
        if not chosen and requireResearchCheck == true then
            -- Bank-side compatibility fallback: some clients report false outside station context.
            chosen, isExact = PickCandidate(false)
        end
        if chosen then
            if consume and type(usedMap) == "table" then
                local chosenKey = string.format("%d:%d", tonumber(chosen.bagId or -1), tonumber(chosen.slotIndex or -1))
                usedMap[chosenKey] = true
            end
            if isExact then
                diag.exactLineMatches = (diag.exactLineMatches or 0) + 1
            else
                diag.fallbackLineMatches = (diag.fallbackLineMatches or 0) + 1
            end
            return chosen
        end
        return nil
    end

    local byTraitBackpack, byTraitBank = BuildResearchSlotIndex()
    local function IsTraitStillNeeded(craftIndex, lineIndex, traitIndex)
        local detail = self:GetDetailForCraft(craftIndex, resolvedCurrentCharId)
        if not detail then
            return false, nil
        end
        for _, row in ipairs(detail.items or {}) do
            if row.lineIndex == lineIndex and row.traitIndex == traitIndex then
                return row.state == "available", row
            end
        end
        return false, nil
    end

    local function IsTraitAlreadyKnownNow(craftIndex, lineIndex, traitIndex)
        local state = self:GetTraitRuntimeState(craftIndex, lineIndex, traitIndex)
        return state == "completed" or state == "researching"
    end

    local function ResolveTargetTraitType(craftIndex, lineIndex, traitIndex, fallbackTraitType)
        local craftDef = self:GetCraftDefinition(craftIndex)
        if craftDef and type(GetSmithingResearchLineTraitInfo) == "function" then
            local traitType = SafeCall(GetSmithingResearchLineTraitInfo, craftDef.craftType, lineIndex, traitIndex)
            if type(traitType) == "number" and traitType > 0 then
                return traitType
            end
        end
        local t = tonumber(fallbackTraitType)
        if type(t) == "number" and t > 0 then
            return t
        end
        return nil
    end

    local function BuildFromDailyPlan()
        local out = {}
        local usedSlots = {}
        local perCraftCount = {}
        local byChar = self.accountVars and self.accountVars.dailyPlan and self.accountVars.dailyPlan[resolvedCurrentCharId]
        if type(byChar) ~= "table" then
            return out
        end
        for _, craftIndex in ipairs(craftOrder) do
            local craftDef = self:GetCraftDefinition(craftIndex)
            if craftDef then
                local cap = self:GetDailyQueueLimitForCraft(craftIndex)
                perCraftCount[craftIndex] = perCraftCount[craftIndex] or 0
                local planned = byChar[craftIndex]
                if type(planned) == "table" then
                    diag.planEntries = (diag.planEntries or 0) + #planned
                    for _, entry in ipairs(planned) do
                        if perCraftCount[craftIndex] >= cap then
                            break
                        end
                        if self:IsNirnhonedTrait(entry.traitType, entry.traitName) then
                            diag.planSkippedNirn = (diag.planSkippedNirn or 0) + 1
                        else
                            local needed, liveRow = IsTraitStillNeeded(craftIndex, entry.lineIndex, entry.traitIndex)
                            local stillRelevant = needed or (liveRow and liveRow.state ~= "completed") or (liveRow == nil)
                            local resolvedTraitType = ResolveTargetTraitType(craftIndex, entry.lineIndex, entry.traitIndex, entry.traitType or (liveRow and liveRow.traitType))
                            if not stillRelevant then
                                diag.planSkippedNotRelevant = (diag.planSkippedNotRelevant or 0) + 1
                            elseif IsTraitAlreadyKnownNow(craftIndex, entry.lineIndex, entry.traitIndex) then
                                diag.planSkippedKnown = (diag.planSkippedKnown or 0) + 1
                            elseif type(resolvedTraitType) ~= "number" or resolvedTraitType <= 0 then
                                diag.planSkippedNoBankMatch = (diag.planSkippedNoBankMatch or 0) + 1
                            else
                                local bankList = byTraitBank[resolvedTraitType]
                                local desiredLineToken = BuildLineToken((liveRow and liveRow.lineName) or entry.lineName or "")
                                local slot = FindUsableEntry(bankList, craftDef.craftType, entry.lineIndex, desiredLineToken, usedSlots, true, true)
                                if slot and slot.bagId ~= BAG_BACKPACK then
                                    AddDiagSample(diag.selectedTraits, string.format("%s:%s", tostring(craftDef.label or "?"), tostring(entry.traitName or "Trait")))
                                    out[#out + 1] = {
                                        craftIndex = craftIndex,
                                        craftType = craftDef.craftType,
                                        craftLabel = craftDef.label,
                                        lineIndex = entry.lineIndex,
                                        traitIndex = entry.traitIndex,
                                        traitType = resolvedTraitType,
                                        lineName = (liveRow and liveRow.lineName) or entry.lineName or "Line",
                                        traitName = (liveRow and liveRow.name) or entry.traitName or "Trait",
                                        itemSlot = slot,
                                    }
                                    perCraftCount[craftIndex] = perCraftCount[craftIndex] + 1
                                else
                                    diag.planSkippedNoBankMatch = (diag.planSkippedNoBankMatch or 0) + 1
                                end
                            end
                        end
                    end
                end
            end
        end
        diag.planCandidates = #out
        return out
    end

    local function BuildFromQueue()
        local out = {}
        local usedSlots = {}
        local perCraftCount = {}
        local queue = self:EnsureCraftQueue()
        local entries = {}
        for queueKey, entry in pairs(queue) do
            if entry.targetCharId == resolvedCurrentCharId and type(entry.craftIndex) == "number" then
                diag.queueEntries = (diag.queueEntries or 0) + 1
                entry.key = queueKey
                entries[#entries + 1] = entry
            end
        end
        table.sort(entries, function(a, b)
            return tonumber(a.createdAt or 0) < tonumber(b.createdAt or 0)
        end)

        for _, entry in ipairs(entries) do
            local craftIndex = tonumber(entry.craftIndex or 0) or 0
            local craftDef = self:GetCraftDefinition(craftIndex)
            if craftDef then
                local cap = self:GetDailyQueueLimitForCraft(craftIndex)
                perCraftCount[craftIndex] = perCraftCount[craftIndex] or 0
                if perCraftCount[craftIndex] < cap then
                    if self:IsNirnhonedTrait(entry.traitType, entry.traitName) then
                        diag.queueSkippedNirn = (diag.queueSkippedNirn or 0) + 1
                    else
                        local needed, liveRow = IsTraitStillNeeded(craftIndex, entry.lineIndex, entry.traitIndex)
                        local stillRelevant = needed or (liveRow and liveRow.state ~= "completed") or (liveRow == nil)
                        local resolvedTraitType = ResolveTargetTraitType(craftIndex, entry.lineIndex, entry.traitIndex, entry.traitType or (liveRow and liveRow.traitType))
                        if not stillRelevant then
                            diag.queueSkippedNotRelevant = (diag.queueSkippedNotRelevant or 0) + 1
                        elseif IsTraitAlreadyKnownNow(craftIndex, entry.lineIndex, entry.traitIndex) then
                            diag.queueSkippedKnown = (diag.queueSkippedKnown or 0) + 1
                        elseif type(resolvedTraitType) ~= "number" or resolvedTraitType <= 0 then
                            diag.queueSkippedNoBankMatch = (diag.queueSkippedNoBankMatch or 0) + 1
                        else
                            local bankList = byTraitBank[resolvedTraitType]
                            local desiredLineToken = BuildLineToken((liveRow and liveRow.lineName) or entry.lineName or "")
                            local slot = FindUsableEntry(bankList, craftDef.craftType, entry.lineIndex, desiredLineToken, usedSlots, true, true)
                            if slot and slot.bagId ~= BAG_BACKPACK then
                                AddDiagSample(diag.selectedTraits, string.format("%s:%s", tostring(craftDef.label or "?"), tostring(entry.traitName or "Trait")))
                                out[#out + 1] = {
                                    craftIndex = craftIndex,
                                    craftType = craftDef.craftType,
                                    craftLabel = craftDef.label,
                                    lineIndex = entry.lineIndex,
                                    traitIndex = entry.traitIndex,
                                    traitType = resolvedTraitType,
                                    lineName = (liveRow and liveRow.lineName) or entry.lineName or "Line",
                                    traitName = (liveRow and liveRow.name) or entry.traitName or "Trait",
                                    itemSlot = slot,
                                }
                                perCraftCount[craftIndex] = perCraftCount[craftIndex] + 1
                            else
                                diag.queueSkippedNoBankMatch = (diag.queueSkippedNoBankMatch or 0) + 1
                            end
                        end
                    end
                end
            end
        end
        diag.queueCandidates = #out
        return out
    end

    local queuedCandidates = BuildFromQueue()
    if #queuedCandidates > 0 then
        diag.selectedSource = "queue"
        return queuedCandidates, diag
    end

    local plannedCandidates = BuildFromDailyPlan()
    if #plannedCandidates > 0 then
        diag.selectedSource = "dailyPlan"
        return plannedCandidates, diag
    end

    -- Fallback when queue is empty: derive missing rows directly with per-craft caps.
    local candidates = {}
    local used = {}
    local perCraftCount = {}
    for _, craftIndex in ipairs(craftOrder) do
        perCraftCount[craftIndex] = perCraftCount[craftIndex] or 0
        local detail = self:GetDetailForCraft(craftIndex, resolvedCurrentCharId)
        local craftDef = self:GetCraftDefinition(craftIndex)
        local cap = self:GetDailyQueueLimitForCraft(craftIndex)
        if detail and craftDef then
            for _, row in ipairs(detail.items or {}) do
                if perCraftCount[craftIndex] >= cap then
                    break
                end
                if row.state == "available" and not self:IsNirnhonedTrait(row.traitType, row.name) then
                    local key = string.format("%d:%d:%d", craftIndex, row.lineIndex or 0, row.traitIndex or 0)
                    if not used[key] then
                        local bankList = byTraitBank[row.traitType]
                        local desiredLineToken = BuildLineToken(row.lineName or "")
                        local slot = FindUsableEntry(bankList, craftDef.craftType, row.lineIndex, desiredLineToken, used, true, true)
                        if slot and slot.bagId ~= BAG_BACKPACK then
                            used[key] = true
                            candidates[#candidates + 1] = {
                                craftIndex = craftIndex,
                                craftType = craftDef.craftType,
                                craftLabel = craftDef.label,
                                lineIndex = row.lineIndex,
                                traitIndex = row.traitIndex,
                                traitType = row.traitType,
                                lineName = row.lineName or "Line",
                                traitName = row.name or "Trait",
                                itemSlot = slot,
                            }
                            perCraftCount[craftIndex] = perCraftCount[craftIndex] + 1
                        end
                    end
                end
            end
        end
    end
    diag.fallbackCandidates = #candidates
    diag.selectedSource = "fallback"
    return candidates, diag
end

function RT:FetchAllResearchItemsForCurrentAlt(preferredCraftIndex)
    if type(IsBankOpen) ~= "function" or not IsBankOpen() then
        Msg("Open the bank first, then run /rt alt.")
        return false
    end
    if self.fetchResearchState and self.fetchResearchState.running then
        Msg("Fetch already running. Please wait.")
        return false
    end

    local candidates, diag = self:BuildCurrentCharacterBankFetchCandidates(preferredCraftIndex)
    local maxPerRun = 10 -- 3 blacksmith + 3 clothing + 3 woodworking + 1 jewelry
    local beforeTrim = #candidates
    if #candidates > maxPerRun then
        local trimmed = {}
        for i = 1, maxPerRun do
            trimmed[i] = candidates[i]
        end
        candidates = trimmed
    end
    if type(diag) == "table" then
        Msg(string.format(
            "[Diag] alt=%s source=%s queueEntries=%d planEntries=%d bankItems=%d",
            tostring(diag.currentCharId or "?"),
            tostring(diag.selectedSource or "none"),
            tonumber(diag.queueEntries or 0) or 0,
            tonumber(diag.planEntries or 0) or 0,
            tonumber(diag.bankIndexedItems or 0) or 0
        ))
        Msg(string.format(
            "[Diag] queueCandidates=%d planCandidates=%d fallbackCandidates=%d beforeTrim=%d afterTrim=%d",
            tonumber(diag.queueCandidates or 0) or 0,
            tonumber(diag.planCandidates or 0) or 0,
            tonumber(diag.fallbackCandidates or 0) or 0,
            tonumber(beforeTrim or 0) or 0,
            tonumber(#candidates or 0) or 0
        ))
        Msg(string.format(
            "[Diag] matches exact=%d fallback=%d lineMismatch=%d",
            tonumber(diag.exactLineMatches or 0) or 0,
            tonumber(diag.fallbackLineMatches or 0) or 0,
            tonumber(diag.skippedLineMismatch or 0) or 0
        ))
        Msg(string.format(
            "[Diag] skip queue(k=%d,n=%d,r=%d,b=%d) plan(k=%d,n=%d,r=%d,b=%d)",
            tonumber(diag.queueSkippedKnown or 0) or 0,
            tonumber(diag.queueSkippedNirn or 0) or 0,
            tonumber(diag.queueSkippedNotRelevant or 0) or 0,
            tonumber(diag.queueSkippedNoBankMatch or 0) or 0,
            tonumber(diag.planSkippedKnown or 0) or 0,
            tonumber(diag.planSkippedNirn or 0) or 0,
            tonumber(diag.planSkippedNotRelevant or 0) or 0,
            tonumber(diag.planSkippedNoBankMatch or 0) or 0
        ))
        if type(diag.selectedTraits) == "table" and #diag.selectedTraits > 0 then
            Msg(string.format("[Diag] selected=%s", table.concat(diag.selectedTraits, ", ")))
        end
    end
    if #candidates <= 0 then
        Msg("No missing-trait items found in bank for this alt.")
        return false
    end

    self.fetchResearchState = {
        running = true,
        candidates = candidates,
        index = 1,
        moved = 0,
        skipped = 0,
        stoppedByFullBag = false,
    }

    local function Finish()
        local state = self.fetchResearchState
        if not state then
            return
        end
        self.fetchResearchState = nil
        if state.moved <= 0 then
            if state.stoppedByFullBag then
                Msg("No items fetched. Backpack is full.")
            else
                Msg(string.format("No items fetched. Skipped %d.", state.skipped or 0))
            end
        else
            local suffix = state.stoppedByFullBag and " (stopped: backpack full)" or ""
            Msg(string.format("Fetched %d item(s) for this alt. Skipped %d.%s", state.moved or 0, state.skipped or 0, suffix))
        end
    end

    local function Step()
        local state = self.fetchResearchState
        if not state or not state.running then
            return
        end
        if type(IsBankOpen) ~= "function" or not IsBankOpen() then
            state.running = false
            Msg("Fetch stopped: bank was closed.")
            return Finish()
        end
        if (state.moved or 0) >= maxPerRun then
            state.running = false
            return Finish()
        end
        if state.index > #state.candidates then
            state.running = false
            return Finish()
        end

        local candidate = state.candidates[state.index]
        state.index = state.index + 1
        local liveState = self:GetTraitRuntimeState(candidate.craftIndex, candidate.lineIndex, candidate.traitIndex)
        if liveState == "completed" or liveState == "researching" then
            state.skipped = state.skipped + 1
            Msg(string.format("[Diag] skip-live-state=%s trait=%s", tostring(liveState), tostring(candidate.traitName or "Trait")))
            return zo_callLater(Step, 40)
        end
        self:MoveResearchItemToBackpackIfNeeded(candidate, function(ok, updatedCandidate, moveErr)
            local _ = updatedCandidate
            if ok then
                state.moved = state.moved + 1
            else
                state.skipped = state.skipped + 1
                if type(moveErr) == "string" and moveErr:find("Backpack is full", 1, true) then
                    state.stoppedByFullBag = true
                    state.running = false
                    return Finish()
                end
            end
            zo_callLater(Step, 40)
        end)
    end

    Msg(string.format("Fetch started: %d bank item(s) to retrieve...", #candidates))
    zo_callLater(Step, 40)
    return true
end

function RT:PrintInventoryDiagnostics()
    local function ScanBag(bagId, label)
        local bagSize = SafeCall(GetBagSize, bagId) or 0
        local stat = {
            scanned = 0,
            equip = 0,
            nirn = 0,
            locked = 0,
            whiteUnlocked = 0,
            nonWhite = 0,
        }
        for slotIndex = 0, bagSize - 1 do
            local stack = SafeCall(GetSlotStackSize, bagId, slotIndex) or 0
            if stack > 0 then
                stat.scanned = stat.scanned + 1
                local equipType = SafeCall(GetItemEquipType, bagId, slotIndex)
                local isEquip = type(equipType) == "number" and equipType ~= EQUIP_TYPE_INVALID
                if isEquip then
                    stat.equip = stat.equip + 1
                end
                local traitType = SafeCall(GetItemTrait, bagId, slotIndex)
                local itemName = SafeCall(GetItemName, bagId, slotIndex)
                local isNirn = type(traitType) == "number" and self:IsNirnhonedTrait(traitType, itemName)
                if isNirn then
                    stat.nirn = stat.nirn + 1
                end
                local isLocked = type(IsItemPlayerLocked) == "function" and IsItemPlayerLocked(bagId, slotIndex)
                if isLocked then
                    stat.locked = stat.locked + 1
                end
                local isWhite = self:IsCommonQualityItem(bagId, slotIndex)
                if isWhite then
                    if (not isLocked) and (not isNirn) and isEquip then
                        stat.whiteUnlocked = stat.whiteUnlocked + 1
                    end
                else
                    stat.nonWhite = stat.nonWhite + 1
                end
            end
        end
        Msg(string.format(
            "[InvDiag] %s scanned=%d equip=%d whiteUnlocked=%d locked=%d nonWhite=%d nirn=%d",
            tostring(label),
            stat.scanned,
            stat.equip,
            stat.whiteUnlocked,
            stat.locked,
            stat.nonWhite,
            stat.nirn
        ))
        return stat
    end

    ScanBag(BAG_BACKPACK, "Backpack")
    if type(IsBankOpen) == "function" and IsBankOpen() then
        ScanBag(BAG_BANK, "Bank")
        if BAG_SUBSCRIBER_BANK then
            ScanBag(BAG_SUBSCRIBER_BANK, "ESO+ Bank")
        end
    else
        Msg("[InvDiag] Bank closed. Open bank to include bank diagnostics.")
    end
end

function RT:BuildLimitedDailyPrepQueue(crafterCharId)
    local stats = {
        added = 0,
        blocked = 0,
        perCraft = {},
    }
    for craftIndex = 1, #self.CRAFTS do
        stats.perCraft[craftIndex] = 0
    end

    -- Rebuild queue from scratch each prep to avoid huge carry-over.
    self.accountVars.craftQueue = {}
    self.accountVars.dailyPlan = {}

    local knownIds = self:GetKnownCharacterIds()
    for _, targetCharId in ipairs(knownIds) do
        if targetCharId ~= crafterCharId then
            for craftIndex = 1, #self.CRAFTS do
                local limit = self:GetDailyQueueLimitForCraft(craftIndex)
                local rows = self:BuildShoppingRows(targetCharId, craftIndex, crafterCharId)
                local targetDetail = self:GetDetailForCraft(craftIndex, targetCharId)
                local nameByKey = {}
                for _, item in ipairs((targetDetail and targetDetail.items) or {}) do
                    local key = string.format("%d:%d", tonumber(item.lineIndex or 0), tonumber(item.traitIndex or 0))
                    nameByKey[key] = {
                        lineName = item.lineName or "Line",
                        traitName = item.name or "Trait",
                    }
                end
                local addedForTargetCraft = 0
                local usedLines = {}
                local function TryQueueRow(row, requireNewLine)
                    if not row or not row.canCraftNow then
                        return false
                    end
                    local lineIndex = tonumber(row.lineIndex or 0) or 0
                    if requireNewLine and usedLines[lineIndex] then
                        return false
                    end
                    local changed, queuedNow = self:ToggleQueueItem(targetCharId, craftIndex, row.lineIndex, row.traitIndex)
                    if not (changed and queuedNow) then
                        return false
                    end
                    usedLines[lineIndex] = true
                    addedForTargetCraft = addedForTargetCraft + 1
                    stats.added = stats.added + 1
                    stats.perCraft[craftIndex] = (stats.perCraft[craftIndex] or 0) + 1
                    local byChar = self.accountVars.dailyPlan[targetCharId]
                    if type(byChar) ~= "table" then
                        byChar = {}
                        self.accountVars.dailyPlan[targetCharId] = byChar
                    end
                    local byCraft = byChar[craftIndex]
                    if type(byCraft) ~= "table" then
                        byCraft = {}
                        byChar[craftIndex] = byCraft
                    end
                    byCraft[#byCraft + 1] = {
                        lineIndex = row.lineIndex,
                        traitIndex = row.traitIndex,
                        traitType = row.traitType,
                        lineName = (nameByKey[string.format("%d:%d", tonumber(row.lineIndex or 0), tonumber(row.traitIndex or 0))] or {}).lineName or "Line",
                        traitName = (nameByKey[string.format("%d:%d", tonumber(row.lineIndex or 0), tonumber(row.traitIndex or 0))] or {}).traitName or "Trait",
                    }
                    return true
                end

                -- Pass 1: prioritize distinct equipment lines so alts can research in parallel slots.
                for _, row in ipairs(rows) do
                    if addedForTargetCraft >= limit then
                        break
                    end
                    if not row.canCraftNow then
                        stats.blocked = stats.blocked + 1
                    else
                        TryQueueRow(row, true)
                    end
                end

                -- Pass 2: if there were not enough distinct lines, allow same-line fallback.
                if addedForTargetCraft < limit then
                    for _, row in ipairs(rows) do
                        if addedForTargetCraft >= limit then
                            break
                        end
                        if row.canCraftNow then
                            TryQueueRow(row, false)
                        end
                    end
                end
            end
        end
    end
    return stats
end

function RT:IsAutoCraftEnabled()
    if not self.accountVars then
        return true
    end
    if self.accountVars.autoCraftEnabled == nil then
        self.accountVars.autoCraftEnabled = true
    end
    return self.accountVars.autoCraftEnabled == true
end

function RT:SetAutoCraftEnabled(enabled)
    if not self.accountVars then
        return
    end
    self.accountVars.autoCraftEnabled = enabled == true
end

function RT:GetCraftIndexForCraftingType(craftingType)
    for idx = 1, #self.CRAFTS do
        if self.CRAFTS[idx].craftType == craftingType then
            return idx
        end
    end
    return nil
end

function RT:GetAutoCraftLabel(craftingType)
    if craftingType == CRAFTING_TYPE_BLACKSMITHING then
        return "Blacksmith"
    elseif craftingType == CRAFTING_TYPE_CLOTHIER then
        return "Clothing"
    elseif craftingType == CRAFTING_TYPE_WOODWORKING then
        return "Woodworking"
    elseif craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
        return "Jewelry"
    end
    return "Unknown"
end

function RT:GetNextAutoCraftJob(crafterCharId, craftingType, skipMap)
    local craftIndex = self:GetCraftIndexForCraftingType(craftingType)
    if not craftIndex then
        return nil
    end
    local queue = self:EnsureCraftQueue()
    local rows = {}
    for key, entry in pairs(queue) do
        if entry.craftIndex == craftIndex and (not skipMap or skipMap[key] ~= true) then
            local crafterDetail = self:GetDetailForCraft(craftIndex, crafterCharId)
            if crafterDetail then
                local canCraftTrait = false
                for _, item in ipairs(crafterDetail.items or {}) do
                    if item.lineIndex == entry.lineIndex and item.traitIndex == entry.traitIndex and item.state == "completed" then
                        canCraftTrait = true
                        break
                    end
                end
                if canCraftTrait then
                    if type(entry.traitType) ~= "number" then
                        local targetDetail = self:GetDetailForCraft(craftIndex, entry.targetCharId)
                        for _, tItem in ipairs((targetDetail and targetDetail.items) or {}) do
                            if tItem.lineIndex == entry.lineIndex and tItem.traitIndex == entry.traitIndex then
                                entry.traitType = tItem.traitType
                                break
                            end
                        end
                    end
                    if not self:IsNirnhonedTrait(entry.traitType, entry.traitName) then
                        entry.key = key
                        rows[#rows + 1] = entry
                    end
                end
            end
        end
    end
    table.sort(rows, function(a, b)
        return tonumber(a.createdAt or 0) < tonumber(b.createdAt or 0)
    end)
    return rows[1]
end

function RT:TryConfigureGamepadCreationForJob(job)
    if not job then
        return false, "Invalid queued row."
    end
    if not SMITHING_GAMEPAD or not SMITHING_GAMEPAD.creationPanel then
        return false, "Smithing gamepad panel not ready."
    end

    local panel = SMITHING_GAMEPAD.creationPanel
    if SMITHING_GAMEPAD.SetMode and SMITHING_MODE_CREATION then
        SMITHING_GAMEPAD:SetMode(SMITHING_MODE_CREATION)
    end
    if panel.PerformDeferredInitialization then
        panel:PerformDeferredInitialization()
    end

    local function ResolvePatternIndexForJob()
        local wantedName = NormalizeToken(job.lineName)
        if wantedName == "" then
            return nil
        end

        local preferredBaseFilter = nil
        if type(job.traitType) == "number" and type(ZO_CraftingUtils_GetSmithingFilterFromTrait) == "function" then
            preferredBaseFilter = ZO_CraftingUtils_GetSmithingFilterFromTrait(job.traitType)
        end

        local fallbackMatch = nil
        local numPatterns = SafeCall(GetNumSmithingPatterns) or 0
        for patternIndex = 1, numPatterns do
            local patternName, baseName, _, numMaterials, _, _, resultingItemFilterType = SafeCall(GetSmithingPatternInfo, patternIndex)
            if (numMaterials or 0) > 0 then
                local p1 = NormalizeToken(patternName)
                local p2 = NormalizeToken(baseName)
                if wantedName == p1 or wantedName == p2 then
                    if preferredBaseFilter and resultingItemFilterType and type(ZO_CraftingUtils_GetSmithingFilterFromItemFilter) == "function" then
                        local baseFilter = ZO_CraftingUtils_GetSmithingFilterFromItemFilter(resultingItemFilterType)
                        if baseFilter == preferredBaseFilter then
                            return patternIndex
                        end
                    end
                    fallbackMatch = fallbackMatch or patternIndex
                end
            end
        end
        return fallbackMatch
    end

    local targetPatternIndex = ResolvePatternIndexForJob()
    if not targetPatternIndex then
        return false, string.format("Could not resolve smithing pattern for '%s'.", tostring(job.lineName or "?"))
    end

    local function BuildDirectCraftParams(targetPatternIndex, preferredStyleId)
        local _, _, _, numMaterials = SafeCall(GetSmithingPatternInfo, targetPatternIndex)
        numMaterials = tonumber(numMaterials or 0) or 0
        if numMaterials <= 0 then
            return nil, "Pattern has no craftable materials."
        end

        local materialIndex, materialQuantity = nil, nil
        for idx = 1, numMaterials do
            local _, _, requiredStack = SafeCall(GetSmithingPatternMaterialItemInfo, targetPatternIndex, idx)
            local need = tonumber(requiredStack or 0) or 0
            if need > 0 then
                local have = SafeCall(GetCurrentSmithingMaterialItemCount, targetPatternIndex, idx) or 0
                if have >= need then
                    materialIndex = idx
                    materialQuantity = need
                    break
                end
            end
        end
        if not materialIndex then
            return nil, "Missing smithing base materials for selected row."
        end

        local styleId = nil
        local ignoreStyles = (type(DoesSmithingTypeIgnoreStyleItems) == "function")
            and DoesSmithingTypeIgnoreStyleItems(GetCraftingInteractionType()) == true
        if not ignoreStyles then
            if preferredStyleId and preferredStyleId > 0 then
                local known = SafeCall(IsSmithingStyleKnown, preferredStyleId, targetPatternIndex)
                local canUse = SafeCall(CanSmithingStyleBeUsedOnPattern, preferredStyleId, targetPatternIndex, materialIndex, materialQuantity)
                local haveStyleStone = (SafeCall(GetCurrentSmithingStyleItemCount, preferredStyleId) or 0) > 0
                if known and canUse and haveStyleStone then
                    styleId = preferredStyleId
                end
            end
            if not styleId and type(GetNumValidItemStyles) == "function" then
                for styleIdx = 1, GetNumValidItemStyles() do
                    local candidate = GetValidItemStyleId(styleIdx)
                    if candidate and candidate > 0 then
                        local known = SafeCall(IsSmithingStyleKnown, candidate, targetPatternIndex)
                        local canUse = SafeCall(CanSmithingStyleBeUsedOnPattern, candidate, targetPatternIndex, materialIndex, materialQuantity)
                        local haveStyleStone = (SafeCall(GetCurrentSmithingStyleItemCount, candidate) or 0) > 0
                        if known and canUse and haveStyleStone then
                            styleId = candidate
                            break
                        end
                    end
                end
            end
            if not styleId then
                return nil, "Missing usable style material for selected row."
            end
        end

        local traitIndex = nil
        if type(job.traitType) == "number" and type(ZO_CraftingUtils_GetSmithingTraitItemInfo) == "function" then
            local knownForPattern = SafeCall(IsSmithingTraitKnownForPattern, targetPatternIndex, job.traitType)
            if not knownForPattern then
                return nil, "Crafter does not know required trait for this pattern."
            end
            local traitItems = ZO_CraftingUtils_GetSmithingTraitItemInfo()
            for _, traitInfo in ipairs(traitItems or {}) do
                if traitInfo.type == job.traitType then
                    traitIndex = traitInfo.index
                    break
                end
            end
            if not traitIndex then
                return nil, "Trait index not found in smithing trait table."
            end
            local haveTraitStone = (SafeCall(GetCurrentSmithingTraitItemCount, traitIndex) or 0) > 0
            if not haveTraitStone then
                return nil, "Missing trait stone for selected row."
            end
        else
            traitIndex = job.traitIndex
        end

        local useUniversalStyle = false
        local iterations = 1
        local maxIterations, craftResult = SafeCall(
            GetMaxIterationsPossibleForSmithingItem,
            targetPatternIndex,
            materialIndex,
            materialQuantity,
            styleId,
            traitIndex,
            useUniversalStyle
        )
        if not maxIterations or maxIterations < 1 then
            local reasonText = (type(GetString) == "function" and craftResult and GetString("SI_TRADESKILLRESULT", craftResult)) or "Unknown craft restriction."
            return nil, string.format("Not craftable now: %s", tostring(reasonText))
        end
        return { targetPatternIndex, materialIndex, materialQuantity, styleId, traitIndex, useUniversalStyle, iterations }, nil
    end

    local function ApplyTypeFilter(filterDescriptor)
        if filterDescriptor and panel.ChangeTypeFilter then
            panel:ChangeTypeFilter({ descriptor = filterDescriptor })
        end
        if panel.DirtyAllLists then
            panel:DirtyAllLists()
        end
    end

    -- Ignore optional "have mats/knowledge" UI filters during automation so valid patterns remain selectable.
    if panel.savedVars then
        panel.savedVars.haveMaterialChecked = false
        panel.savedVars.haveKnowledgeChecked = false
    end
    ApplyTypeFilter(nil)

    if not panel.patternList or not panel.traitList then
        return false, "Creation lists not ready."
    end

    local function SelectPatternInCurrentFilter()
        if not panel.patternList then
            return nil
        end
        if panel.patternList.SetSelectedDataIndex then
            panel.patternList:SetSelectedDataIndex(targetPatternIndex)
        end
        local selected = panel.patternList.GetSelectedData and panel.patternList:GetSelectedData() or nil
        if selected and selected.patternIndex == targetPatternIndex then
            return selected
        end
        if panel.patternList.FindIndexFromData and panel.patternList.SetSelectedIndex then
            local listIndex = panel.patternList:FindIndexFromData(targetPatternIndex, function(oldPatternIndex, newData)
                return type(newData) == "table" and newData.patternIndex == oldPatternIndex
            end)
            if listIndex then
                local ALLOW_EVEN_IF_DISABLED = true
                local SKIP_ANIMATION = true
                panel.patternList:SetSelectedIndex(listIndex, ALLOW_EVEN_IF_DISABLED, SKIP_ANIMATION)
                selected = panel.patternList.GetSelectedData and panel.patternList:GetSelectedData() or nil
                if selected and selected.patternIndex == targetPatternIndex then
                    return selected
                end
            end
        end
        return nil
    end

    local function TrySelectPatternAcrossFilters()
        local attempted = {}
        local function TryFilter(filterDescriptor)
            if not filterDescriptor or attempted[filterDescriptor] then
                return nil
            end
            attempted[filterDescriptor] = true
            ApplyTypeFilter(filterDescriptor)
            return SelectPatternInCurrentFilter()
        end

        local _, _, _, _, _, _, resultingItemFilterType = SafeCall(GetSmithingPatternInfo, targetPatternIndex)
        if resultingItemFilterType and type(ZO_CraftingUtils_GetSmithingFilterFromItemFilter) == "function" then
            local baseFilter = ZO_CraftingUtils_GetSmithingFilterFromItemFilter(resultingItemFilterType)
            local patternData = TryFilter(baseFilter)
            if patternData then
                return patternData
            end

            local setFilter = nil
            if baseFilter == SMITHING_FILTER_TYPE_WEAPONS then
                setFilter = SMITHING_FILTER_TYPE_SET_WEAPONS
            elseif baseFilter == SMITHING_FILTER_TYPE_ARMOR then
                setFilter = SMITHING_FILTER_TYPE_SET_ARMOR
            elseif baseFilter == SMITHING_FILTER_TYPE_JEWELRY then
                setFilter = SMITHING_FILTER_TYPE_SET_JEWELRY
            end
            patternData = TryFilter(setFilter)
            if patternData then
                return patternData
            end
        end

        -- Final fallback: brute-force known smithing creation filters that can be crafted here.
        local filters = {
            SMITHING_FILTER_TYPE_WEAPONS,
            SMITHING_FILTER_TYPE_ARMOR,
            SMITHING_FILTER_TYPE_JEWELRY,
            SMITHING_FILTER_TYPE_SET_WEAPONS,
            SMITHING_FILTER_TYPE_SET_ARMOR,
            SMITHING_FILTER_TYPE_SET_JEWELRY,
        }
        for _, filterDescriptor in ipairs(filters) do
            local canUse = true
            if type(ZO_CraftingUtils_CanSmithingFilterBeCraftedHere) == "function" then
                canUse = ZO_CraftingUtils_CanSmithingFilterBeCraftedHere(filterDescriptor) == true
            end
            if canUse then
                local patternData = TryFilter(filterDescriptor)
                if patternData then
                    return patternData
                end
            end
        end
        return nil
    end

    local patternData = TrySelectPatternAcrossFilters()
    if not patternData then
        local directParams, directErr = BuildDirectCraftParams(targetPatternIndex, nil)
        if directParams then
            return true, nil, directParams
        end
        return false, directErr or "Pattern not selectable in current station filter."
    end

    local styleId = nil
    if panel.styleList and type(GetNumValidItemStyles) == "function" then
        for styleIdx = 1, GetNumValidItemStyles() do
            local candidate = GetValidItemStyleId(styleIdx)
            if candidate and candidate > 0 then
                local okKnown = SafeCall(IsSmithingStyleKnown, candidate, targetPatternIndex)
                local canUse = SafeCall(CanSmithingStyleBeUsedOnPattern, candidate, targetPatternIndex, 1, 1)
                if okKnown and canUse and (SafeCall(GetCurrentSmithingStyleItemCount, candidate) or 0) > 0 then
                    styleId = candidate
                    break
                end
            end
        end
    end
    if styleId and panel.styleList and panel.styleList.SetSelectedDataIndex then
        panel.styleList:SetSelectedDataIndex(styleId)
    end

    if patternData and panel.RefreshMaterialList then
        panel:RefreshMaterialList(patternData)
    end
    if panel.materialList and panel.materialList.GetSelectedData and panel.materialList.SetSelectedDataIndex then
        local selectedMaterial = panel.materialList:GetSelectedData()
        if not selectedMaterial and patternData and patternData.materialData then
            for _, data in ipairs(patternData.materialData) do
                if (SafeCall(GetCurrentSmithingMaterialItemCount, targetPatternIndex, data.materialIndex) or 0) >= (data.min or 0) then
                    panel.materialList:SetSelectedDataIndex(data.materialIndex)
                    if panel.SetLastListSelection and panel.GetMaterialListMemoryKey then
                        panel:SetLastListSelection(panel:GetMaterialListMemoryKey(data.materialIndex), 1)
                    end
                    break
                end
            end
        end
    end

    if patternData and panel.RefreshTraitList then
        panel:RefreshTraitList(patternData)
    end

    local function TrySelectTrait()
        if not panel.traitList then
            return false
        end
        if type(job.traitType) == "number" and panel.traitList.FindIndexFromData and panel.traitList.SetSelectedIndex then
            local traitListIndex = panel.traitList:FindIndexFromData(job.traitType, function(oldTraitType, newData)
                return type(newData) == "table" and newData.traitType == oldTraitType
            end)
            if traitListIndex then
                local ALLOW_EVEN_IF_DISABLED = true
                local SKIP_ANIMATION = true
                panel.traitList:SetSelectedIndex(traitListIndex, ALLOW_EVEN_IF_DISABLED, SKIP_ANIMATION)
            end
        end
        if panel.traitList.SetSelectedDataIndex then
            local selectedData = panel.traitList.GetSelectedData and panel.traitList:GetSelectedData() or nil
            if not selectedData then
                panel.traitList:SetSelectedDataIndex(job.traitIndex)
            end
        end
        local selectedData = panel.traitList.GetSelectedData and panel.traitList:GetSelectedData() or nil
        if type(job.traitType) == "number" then
            return selectedData and selectedData.traitType == job.traitType
        end
        return selectedData ~= nil
    end

    local selectedTrait = TrySelectTrait()
    if (not selectedTrait) and type(job.traitType) == "number" and panel.ChangeTypeFilter and type(ZO_CraftingUtils_GetSmithingFilterFromTrait) == "function" then
        local targetFilter = ZO_CraftingUtils_GetSmithingFilterFromTrait(job.traitType)
        if targetFilter then
            panel:ChangeTypeFilter({ descriptor = targetFilter })
            if panel.DirtyAllLists then
                panel:DirtyAllLists()
            end
            patternData = TrySelectPatternAcrossFilters()
            if patternData and panel.RefreshTraitList then
                panel:RefreshTraitList(patternData)
            end
            selectedTrait = TrySelectTrait()
        end
    end

    if not selectedTrait then
        local directParams, directErr = BuildDirectCraftParams(targetPatternIndex, styleId)
        if directParams then
            return true, nil, directParams
        end
        return false, directErr or "Could not select trait in creation list."
    end
    if panel.ShouldCraftButtonBeEnabled then
        local canCraft = panel:ShouldCraftButtonBeEnabled()
        if not canCraft then
            local directParams, directErr = BuildDirectCraftParams(targetPatternIndex, styleId)
            if directParams then
                return true, nil, directParams
            end
            return false, directErr or "Missing mats/style/trait stone for selected row."
        end
    end
    return true, nil
end

function RT:ProcessAutoCraftQueue(craftingType)
    if not self:IsAutoCraftEnabled() then
        return
    end
    local currentCharId = self:GetCurrentCharacterIdString()
    if currentCharId ~= self:GetPreferredCrafterId() then
        return
    end
    if self.autoCraftState and self.autoCraftState.running then
        return
    end

    self.autoCraftState = {
        running = true,
        craftingType = craftingType,
        currentCharId = currentCharId,
        skip = {},
        pendingKey = nil,
        processed = 0,
        skipped = 0,
        skippedByReason = {},
        pendingWaitMs = 0,
    }

    local function AddSkipReason(state, reason)
        if not state then
            return
        end
        state.skipped = (state.skipped or 0) + 1
        local key = tostring(reason or "Not craftable with current station setup")
        state.skippedByReason[key] = (state.skippedByReason[key] or 0) + 1
    end

    local function BuildSummary(state)
        if not state then
            return "Auto-craft finished.", ""
        end
        local crafted = tonumber(state.processed or 0) or 0
        local skipped = tonumber(state.skipped or 0) or 0
        local craftLabel = self:GetAutoCraftLabel(state.craftingType)
        local summary = string.format("Auto-craft finished. Crafted %d Skipped %d (%s)", crafted, skipped, craftLabel)

        local reasonParts = {}
        for reason, count in pairs(state.skippedByReason or {}) do
            reasonParts[#reasonParts + 1] = string.format("%s x%d", reason, count)
        end
        table.sort(reasonParts)
        local details = ""
        if #reasonParts > 0 then
            details = string.format("Reasons: %s", table.concat(reasonParts, "; "))
        end
        return summary, details
    end

    local function Finish(reason)
        local state = self.autoCraftState
        local summaryText, detailsText = BuildSummary(state)
        if self.autoCraftState then
            self.autoCraftState.running = false
        end
        self.autoCraftState = nil
        self:PublishAutoCraftSummary(summaryText, reason and reason ~= "" and reason or detailsText)
    end

    local function Step()
        local state = self.autoCraftState
        if not state or not state.running then
            return
        end
        if state.pendingKey then
            return
        end

        local job = self:GetNextAutoCraftJob(state.currentCharId, state.craftingType, state.skip)
        if not job then
            return Finish(nil)
        end

        local ok, err, directParams = self:TryConfigureGamepadCreationForJob(job)
        if not ok then
            state.skip[job.key] = true
            AddSkipReason(state, err)
            zo_callLater(Step, 50)
            return
        end

        local panel = SMITHING_GAMEPAD and SMITHING_GAMEPAD.creationPanel
        if not panel then
            return Finish("Auto-craft stopped: smithing panel unavailable.")
        end

        local p1, p2, p3, p4, p5, p6, p7
        if type(directParams) == "table" then
            p1, p2, p3, p4, p5, p6, p7 = unpack(directParams)
        else
            p1, p2, p3, p4, p5, p6, p7 = panel:GetAllCraftingParameters(1)
        end
        if type(CraftSmithingItem) ~= "function" then
            return Finish("Auto-craft stopped: CraftSmithingItem unavailable.")
        end

        CraftSmithingItem(p1, p2, p3, p4, p5, p6, p7)
        state.pendingKey = job.key
        state.pendingWaitMs = 0

        local function WaitForCompletion()
            local s = self.autoCraftState
            if s and s.running and s.pendingKey == job.key then
                s.pendingWaitMs = (s.pendingWaitMs or 0) + 500

                local isCrafting = false
                if type(ZO_CraftingUtils_IsPerformingCraftProcess) == "function" then
                    isCrafting = ZO_CraftingUtils_IsPerformingCraftProcess() == true
                end

                if isCrafting and (s.pendingWaitMs or 0) < 25000 then
                    zo_callLater(WaitForCompletion, 500)
                    return
                end

                if (s.pendingWaitMs or 0) < 8000 then
                    zo_callLater(WaitForCompletion, 500)
                    return
                end

                s.pendingKey = nil
                s.skip[job.key] = true
                AddSkipReason(s, "Craft timed out (no completion event).")
                Step()
            end
        end
        zo_callLater(WaitForCompletion, 500)
    end

    self._autoCraftStep = Step
    zo_callLater(Step, 150)
end

function RT:HandleCraftCompleted()
    local state = self.autoCraftState
    if not state or not state.running or not state.pendingKey then
        return
    end
    self:RemoveQueueKey(state.pendingKey)
    state.pendingKey = nil
    state.processed = (state.processed or 0) + 1
    if self._autoCraftStep then
        zo_callLater(self._autoCraftStep, 120)
    end
end

function RT:SetLastCraftIndex(craftIndex)
    if not self.savedVars then
        return
    end
    if type(craftIndex) ~= "number" or craftIndex < 1 or craftIndex > #self.CRAFTS then
        return
    end
    self.savedVars.lastCraftIndex = craftIndex
end

function RT:GetLastCraftIndex()
    local idx = (self.savedVars and self.savedVars.lastCraftIndex) or 1
    if type(idx) ~= "number" or idx < 1 or idx > #self.CRAFTS then
        idx = 1
    end
    return idx
end

function RT:Initialize()
    self.savedVars = ZO_SavedVars:NewCharacterIdSettings(
        "ResearchTrackerSV",
        SV_VERSION,
        nil,
        SV_DEFAULTS
    )
    self.accountVars = ZO_SavedVars:NewAccountWide(
        "ResearchTrackerAccountSV",
        SV_VERSION,
        nil,
        ACCOUNT_DEFAULTS
    )
    if type(self.accountVars.characters) ~= "table" then
        self.accountVars.characters = {}
    end
    if type(self.accountVars.dailyPlan) ~= "table" then
        self.accountVars.dailyPlan = {}
    end

    -- Keep queue/plan across relogs so /rt prep on crafter can be consumed by alts.
    self:EnsureCraftQueue()

    self:RefreshCurrentCharacterSnapshot()
    self.accountVars.lastSessionCharacterId = self:GetCurrentCharacterIdString()
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_PlayerActivatedSnapshot", EVENT_PLAYER_ACTIVATED, function()
            EVENT_MANAGER:UnregisterForEvent(self.name .. "_PlayerActivatedSnapshot", EVENT_PLAYER_ACTIVATED)
            zo_callLater(function()
                self:RefreshCurrentCharacterSnapshot()
                if ResearchTrackerUI and ResearchTrackerUI.visible then
                    if ResearchTrackerUI.activeView == "detail" then
                        ResearchTrackerUI:OpenDetail(ResearchTrackerUI.currentCraftIndex)
                    else
                        ResearchTrackerUI:OpenMain()
                    end
                end
            end, 1200)
            zo_callLater(function()
                self:RefreshCurrentCharacterSnapshot()
            end, 3500)
            zo_callLater(function()
                self:RefreshCurrentCharacterSnapshot()
            end, 7000)
        end)
    end

    if EVENT_CRAFTING_STATION_INTERACT then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_AutoCraftInteract", EVENT_CRAFTING_STATION_INTERACT, function(_, craftingType)
            if not self:IsAutoCraftEnabled() then
                return
            end
            local craftIndex = self:GetCraftIndexForCraftingType(craftingType)
            if not craftIndex then
                return
            end
            if self:GetQueuedCountForCraft(craftIndex) <= 0 then
                return
            end
            if self:GetCurrentCharacterIdString() ~= self:GetPreferredCrafterId() then
                Msg("Queued crafts exist, but this character is not your master crafter.")
                return
            end
            zo_callLater(function()
                self:ProcessAutoCraftQueue(craftingType)
            end, 350)
        end)
    end
    if EVENT_CRAFT_COMPLETED then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_AutoCraftCompleted", EVENT_CRAFT_COMPLETED, function()
            self:HandleCraftCompleted()
        end)
    end

    SLASH_COMMANDS["/rt"] = function(args)
        local text = tostring(args or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local lower = zo_strlower(text)
        if lower == "crafter here" then
            local charId = self:GetCurrentCharacterIdString()
            if self:SetPreferredCrafterId(charId) then
                Msg(string.format("Master crafter set: %s", self:GetCharacterDisplayName(charId)))
                if ResearchTrackerUI and ResearchTrackerUI.visible then
                    if ResearchTrackerUI.activeView == "detail" then
                        ResearchTrackerUI:OpenDetail(ResearchTrackerUI.currentCraftIndex)
                    else
                        ResearchTrackerUI:OpenMain()
                    end
                end
            else
                Msg("Unable to set master crafter for this character yet.")
            end
            return
        elseif lower == "crafter status" then
            local crafterId = self:GetPreferredCrafterId()
            if crafterId then
                Msg(string.format("Master crafter: %s", self:GetCharacterDisplayName(crafterId)))
            else
                Msg("Master crafter not set.")
            end
            return
        elseif lower == "autocraft on" then
            self:SetAutoCraftEnabled(true)
            Msg("Auto-craft: ON")
            return
        elseif lower == "autocraft off" then
            self:SetAutoCraftEnabled(false)
            Msg("Auto-craft: OFF")
            return
        elseif lower == "autocraft status" then
            Msg(string.format("Auto-craft: %s", self:IsAutoCraftEnabled() and "ON" or "OFF"))
            return
        elseif lower == "prep" then
            local crafterId = self:GetPreferredCrafterId()
            if not crafterId then
                Msg("Master crafter not set.")
                return
            end
            if self:GetCurrentCharacterIdString() ~= crafterId then
                Msg("Run /rt prep on your master crafter.")
                return
            end
            local stats = self:BuildLimitedDailyPrepQueue(crafterId)
            local parts = {}
            for craftIndex = 1, #self.CRAFTS do
                local craftDef = self:GetCraftDefinition(craftIndex)
                if craftDef then
                    local cap = self:GetDailyQueueLimitForCraft(craftIndex)
                    local count = stats.perCraft[craftIndex] or 0
                    parts[#parts + 1] = string.format("%s %d/%d per alt", craftDef.label, count, cap)
                end
            end
            Msg(string.format("Prep complete. Added %d queued rows (limited 3/3/3/1 per alt).", stats.added or 0))
            Msg(table.concat(parts, " | "))
            return
        elseif lower == "make" then
            local crafterId = self:GetPreferredCrafterId()
            if not crafterId then
                Msg("Master crafter not set.")
                return
            end
            if self:GetCurrentCharacterIdString() ~= crafterId then
                Msg("Run /rt make on your master crafter.")
                return
            end
            local craftingType = SafeCall(GetCraftingInteractionType)
            local craftIndex = self:GetCraftIndexForCraftingType(craftingType)
            if not craftIndex then
                Msg("Open Blacksmithing/Clothing/Woodworking/Jewelry station, then run /rt make.")
                return
            end
            if self:GetQueuedCountForCraft(craftIndex) <= 0 then
                Msg("No queued rows for this station.")
                return
            end
            if not self:IsAutoCraftEnabled() then
                Msg("Auto-craft is OFF. Use /rt autocraft on first.")
                return
            end
            self:ProcessAutoCraftQueue(craftingType)
            Msg("Make started for this station.")
            return
        elseif lower == "research fetch" then
            local interactionType = SafeCall(GetCraftingInteractionType)
            local preferredCraftIndex = self:GetCraftIndexForCraftingType(interactionType)
            self:FetchAllResearchItemsForCurrentAlt(preferredCraftIndex)
            return
        elseif lower == "research start" then
            if not SMITHING_GAMEPAD then
                Msg("Open a smithing station first, then run /rt research start.")
                return
            end
            local interactionType = SafeCall(GetCraftingInteractionType)
            local preferredCraftIndex = self:GetCraftIndexForCraftingType(interactionType)
            local ok, message = self:StartResearchForCurrentAltUntilSlotsFull(preferredCraftIndex)
            Msg(message or (ok and "Research start running..." or "Research start failed."))
            return
        elseif lower == "alt" then
            local interactionType = SafeCall(GetCraftingInteractionType)
            local preferredCraftIndex = self:GetCraftIndexForCraftingType(interactionType)
            if type(IsBankOpen) == "function" and IsBankOpen() then
                self:FetchAllResearchItemsForCurrentAlt(preferredCraftIndex)
                return
            end
            if SMITHING_GAMEPAD then
                local ok, message = self:StartResearchForCurrentAltUntilSlotsFull(preferredCraftIndex)
                Msg(message or (ok and "Research start running..." or "Research start failed."))
                return
            end
            Msg("Use /rt alt at bank (fetch) or at station (start).")
            return
        elseif lower == "bank" or lower == "deposit" then
            local ok, message = self:AutoDepositResearchItemsToBank()
            Msg(message or (ok and "Deposit complete." or "Deposit failed."))
            return
        elseif lower == "invdiag" then
            self:PrintInventoryDiagnostics()
            return
        end
        if ResearchTrackerUI then
            ResearchTrackerUI:Toggle()
        end
    end
    SLASH_COMMANDS["/researchtracker"] = SLASH_COMMANDS["/rt"]
end

function RT:PublishAutoCraftSummary(summaryText, detailText)
    if summaryText and summaryText ~= "" then
        Msg(summaryText)
    end
    if detailText and detailText ~= "" then
        Msg(detailText)
    end
end

local function OnAddonLoaded(_, addonName)
    if not RT.compatibleAddonNames[tostring(addonName or "")] then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(RT.name, EVENT_ADD_ON_LOADED)
    RT:Initialize()
    if ResearchTrackerUI then
        ResearchTrackerUI:Initialize()
    else
        Msg("UI module not found.")
    end
end

EVENT_MANAGER:RegisterForEvent(RT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

function RT_Toggle()
    if ResearchTrackerUI then
        ResearchTrackerUI:Toggle()
    end
    return true
end

