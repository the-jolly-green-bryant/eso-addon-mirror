local Addon = LarvalTearMod
local Domains = Addon.Common.Domains
local Log = Addon.Common.Log
local Util = Addon.Common.Util
local M = Addon.Modules.BuildCodec

local PASSIVE_SNAPSHOT_EMPTY = "-"
local SKILL_SLOT_HOTBAR_CATEGORIES = Util.HOTBAR_CATEGORIES
local BuildCodecResult
local DecodeSkillState
local RESERVED_CHARACTER_BUCKET_KEYS = {
    pageOrder = true,
    pages = true,
    uiState = true,
}

function M:IsReservedCharacterBucketKey(key)
    return RESERVED_CHARACTER_BUCKET_KEYS[key] == true
end

local function CountEntries(entries)
    local count = 0
    if type(entries) ~= "table" then
        return count
    end

    for _ in pairs(entries or {}) do
        count = count + 1
    end
    return count
end

local function AppendResultError(result, message)
    if type(result) ~= "table" then
        return
    end

    result.errors = result.errors or {}
    result.errors[#result.errors + 1] = message
end

local function SetResultStatus(result, status)
    if type(result) ~= "table" then
        return
    end

    if status == "failure" then
        result.status = "failure"
    elseif status == "partial" and result.status ~= "failure" then
        result.status = "partial"
    elseif result.status == nil then
        result.status = "success"
    end
end

function BuildCodecResult()
    return {
        status = "success",
        errors = {},
    }
end

local function IsPositiveInteger(value)
    return type(value) == "number" and value > 0 and math.floor(value) == value
end

local function IsNonNegativeInteger(value)
    return type(value) == "number" and value >= 0 and math.floor(value) == value
end

local function NormalizeCanonicalPassivePolicy(policy)
    if policy == "none"
        or policy == "class_all_purchase"
        or policy == "class_only"
        or policy == "all" then
        return policy
    end
    return "class_all_purchase"
end

local function DecodePassivePolicy(policy)
    if policy == "auto_fill" then
        policy = "class_all_purchase"
    elseif policy == "manual" then
        policy = "none"
    end
    return NormalizeCanonicalPassivePolicy(policy)
end

function M:NormalizePassivePolicy(policy)
    return NormalizeCanonicalPassivePolicy(policy)
end

local function NormalizeHotbarCategory(value)
    local hotbarCategory = tonumber(value)
    if hotbarCategory == nil or math.floor(hotbarCategory) ~= hotbarCategory then
        return nil
    end
    hotbarCategory = math.floor(hotbarCategory)
    if hotbarCategory == 0 or hotbarCategory == 1 then
        return hotbarCategory
    end
    return nil
end

local function NormalizeSlotIndex(value)
    local slotIndex = tonumber(value)
    if slotIndex == nil or math.floor(slotIndex) ~= slotIndex then
        return nil
    end
    slotIndex = math.floor(slotIndex)
    if slotIndex >= 3 and slotIndex <= 8 then
        return slotIndex
    end
    return nil
end

local function BuildSkillSlotKey(hotbarCategory, slotIndex)
    return tostring(hotbarCategory) .. ":" .. tostring(slotIndex)
end

local function CloneScriptIds(scriptIds)
    if type(scriptIds) ~= "table" then
        return nil
    end

    local cloned = {}
    local hasValue = false
    for index = 1, 3 do
        local scriptId = tonumber(scriptIds[index])
        if scriptId ~= nil and scriptId > 0 and math.floor(scriptId) == scriptId then
            cloned[index] = math.floor(scriptId)
            hasValue = true
        elseif scriptId ~= nil and scriptId == 0 then
            cloned[index] = 0
        else
            return nil
        end
    end

    return hasValue and cloned or nil
end

local function EncodeChampionAllocated(allocated)
    if type(allocated) ~= "table" then
        return ""
    end

    local starIds = {}
    for starId, points in pairs(allocated) do
        local numericStarId = tonumber(starId)
        local numericPoints = tonumber(points)
        if numericStarId ~= nil and numericPoints ~= nil then
            numericStarId = math.floor(numericStarId)
            numericPoints = math.floor(numericPoints)
            if numericStarId > 0 and numericPoints > 0 then
                starIds[#starIds + 1] = numericStarId
            end
        end
    end

    table.sort(starIds)

    local entries = {}
    for _, starId in ipairs(starIds) do
        entries[#entries + 1] = tostring(starId) .. ":" .. tostring(math.floor(tonumber(allocated[starId] or allocated[tostring(starId)]) or 0))
    end

    return table.concat(entries, ",")
end

local function EncodeChampionSlotted(slotted)
    local entries = {}
    for index = 1, 4 do
        local starId = type(slotted) == "table" and tonumber(slotted[index]) or nil
        starId = starId ~= nil and starId > 0 and math.floor(starId) or 0
        entries[index] = tostring(starId)
    end
    return table.concat(entries, ",")
end

local function EncodeChampionGroup(group)
    group = type(group) == "table" and group or {}
    return {
        allocated = EncodeChampionAllocated(group.allocated),
        slotted = EncodeChampionSlotted(group.slotted),
    }
end

local function EncodeChampionPoints(championPoints)
    if type(championPoints) ~= "table" then
        return nil
    end

    local encoded = {}
    for _, groupId in ipairs(Domains.ChampionGroupIds) do
        encoded[groupId] = EncodeChampionGroup(championPoints[groupId])
    end
    return encoded
end

local function DecodeChampionAllocated(encoded, groupId, result)
    if encoded == nil or encoded == "" then
        return {}
    end

    if type(encoded) == "table" then
        local allocated = {}
        for starId, points in pairs(encoded) do
            local numericStarId = tonumber(starId)
            local numericPoints = tonumber(points)
            if not IsPositiveInteger(numericStarId) or not IsPositiveInteger(numericPoints) then
                AppendResultError(result, "cp_allocated_table_malformed:" .. tostring(groupId))
                return nil
            end
            allocated[math.floor(numericStarId)] = math.floor(numericPoints)
        end
        return allocated
    end

    if type(encoded) ~= "string" then
        AppendResultError(result, "cp_allocated_not_string:" .. tostring(groupId))
        return nil
    end

    local allocated = {}
    for entry in string.gmatch(encoded, "([^,]+)") do
        local starText, pointsText = string.match(entry, "^(%d+):(%d+)$")
        local starId = tonumber(starText)
        local points = tonumber(pointsText)
        if not IsPositiveInteger(starId) or not IsPositiveInteger(points) then
            AppendResultError(result, "cp_allocated_malformed:" .. tostring(groupId) .. ":" .. tostring(entry))
            return nil
        end
        if allocated[starId] ~= nil then
            AppendResultError(result, "cp_allocated_duplicate:" .. tostring(groupId) .. ":" .. tostring(starId))
            return nil
        end
        allocated[starId] = points
    end

    return allocated
end

local function DecodeChampionSlotted(encoded, groupId, result)
    if encoded == nil or encoded == "" then
        return {}
    end

    if type(encoded) == "table" then
        local slotted = {}
        for key, starId in pairs(encoded) do
            local numericKey = tonumber(key)
            local numericStarId = tonumber(starId)
            if numericKey == nil
                or numericKey < 1
                or numericKey > 4
                or math.floor(numericKey) ~= numericKey
                or numericStarId == nil
                or numericStarId < 0
                or math.floor(numericStarId) ~= numericStarId then
                AppendResultError(result, "cp_slotted_table_malformed:" .. tostring(groupId))
                return nil
            end
            slotted[math.floor(numericKey)] = math.floor(numericStarId)
        end
        return slotted
    end

    if type(encoded) ~= "string" then
        AppendResultError(result, "cp_slotted_not_string:" .. tostring(groupId))
        return nil
    end

    local first, second, third, fourth = string.match(encoded, "^(%d+),(%d+),(%d+),(%d+)$")
    if first == nil then
        AppendResultError(result, "cp_slotted_malformed:" .. tostring(groupId) .. ":" .. tostring(encoded))
        return nil
    end

    local slotted = {}
    local entries = { first, second, third, fourth }
    for index = 1, 4 do
        local starId = tonumber(entries[index])
        if starId == nil or starId < 0 or math.floor(starId) ~= starId then
            AppendResultError(result, "cp_slotted_malformed:" .. tostring(groupId) .. ":" .. tostring(entries[index]))
            return nil
        end
        slotted[index] = starId
    end

    return slotted
end

local function DecodeChampionGroup(group, groupId, result)
    if group == nil then
        group = {}
    elseif type(group) ~= "table" then
        AppendResultError(result, "cp_group_missing:" .. tostring(groupId))
        return nil
    end

    local allocated = DecodeChampionAllocated(group.allocated, groupId, result)
    local slotted = DecodeChampionSlotted(group.slotted, groupId, result)
    if allocated == nil or slotted == nil then
        return nil
    end

    return {
        allocated = allocated,
        slotted = slotted,
    }
end

local function DecodeChampionPoints(championPoints, result)
    if type(championPoints) ~= "table" then
        return nil
    end

    local decoded = {}
    local successCount = 0
    local failureCount = 0

    for _, groupId in ipairs(Domains.ChampionGroupIds) do
        local group = DecodeChampionGroup(championPoints[groupId], groupId, result)
        if group ~= nil then
            decoded[groupId] = group
            successCount = successCount + 1
        else
            failureCount = failureCount + 1
        end
    end

    if failureCount > 0 and successCount > 0 then
        SetResultStatus(result, "partial")
    elseif failureCount > 0 then
        SetResultStatus(result, "failure")
    end

    return decoded
end

local function NormalizeLegacyChampionSlotted(slotted)
    local normalized = {}
    for index = 1, 4 do
        local starId = type(slotted) == "table" and tonumber(slotted[index]) or nil
        normalized[index] = starId ~= nil and starId > 0 and math.floor(starId) or 0
    end
    return normalized
end

local function NormalizeLegacyChampionAllocated(allocated)
    local normalized = {}
    if type(allocated) ~= "table" then
        return normalized
    end

    for starId, points in pairs(allocated) do
        local numericStarId = tonumber(starId)
        local numericPoints = tonumber(points)
        if numericStarId ~= nil and numericPoints ~= nil then
            numericStarId = math.floor(numericStarId)
            numericPoints = math.floor(numericPoints)
            if numericStarId > 0 and numericPoints > 0 then
                normalized[numericStarId] = numericPoints
            end
        end
    end
    return normalized
end

local function NormalizeLegacyChampionPoints(championPoints)
    if type(championPoints) ~= "table" then
        return nil
    end

    local normalized = {}
    for _, groupId in ipairs(Domains.ChampionGroupIds) do
        local group = type(championPoints[groupId]) == "table" and championPoints[groupId] or {}
        normalized[groupId] = {
            allocated = NormalizeLegacyChampionAllocated(group.allocated),
            slotted = NormalizeLegacyChampionSlotted(group.slotted),
        }
    end
    return normalized
end

local function ChampionPointTablesEqual(left, right)
    left = NormalizeLegacyChampionPoints(left)
    right = NormalizeLegacyChampionPoints(right)
    if left == nil and right == nil then
        return true
    end
    if left == nil or right == nil then
        return false
    end

    for _, groupId in ipairs(Domains.ChampionGroupIds) do
        local leftGroup = left[groupId] or {}
        local rightGroup = right[groupId] or {}
        for index = 1, 4 do
            if (leftGroup.slotted or {})[index] ~= (rightGroup.slotted or {})[index] then
                return false
            end
        end
        for starId, points in pairs(leftGroup.allocated or {}) do
            if (rightGroup.allocated or {})[starId] ~= points then
                return false
            end
        end
        for starId, points in pairs(rightGroup.allocated or {}) do
            if (leftGroup.allocated or {})[starId] ~= points then
                return false
            end
        end
    end
    return true
end

local function IsCraftedSkillSlot(entry)
    if type(entry) ~= "table" then
        return false
    end

    local craftedAbilityId = tonumber(entry.craftedAbilityId)
    if craftedAbilityId == nil or craftedAbilityId <= 0 or math.floor(craftedAbilityId) ~= craftedAbilityId then
        return false
    end

    local actionType = tonumber(entry.slotActionType)
    return actionType == 3
end

local function NormalizeLegacySkillSlot(entry, sourceLabel, result)
    if type(entry) ~= "table" then
        AppendResultError(result, "skill_slot_not_table:" .. tostring(sourceLabel))
        return nil
    end

    local hotbarCategory = NormalizeHotbarCategory(entry.hotbarCategory)
    local slotIndex = NormalizeSlotIndex(entry.slot or entry.slotIndex)
    local abilityId = tonumber(entry.abilityId)
    if hotbarCategory == nil or slotIndex == nil then
        AppendResultError(result, "skill_slot_target_malformed:" .. tostring(sourceLabel))
        return nil
    end
    if abilityId == nil or abilityId <= 0 or math.floor(abilityId) ~= abilityId then
        AppendResultError(result, "skill_slot_ability_malformed:" .. tostring(sourceLabel))
        return nil
    end

    local normalized = {
        hotbarCategory = hotbarCategory,
        slot = slotIndex,
        abilityId = math.floor(abilityId),
    }

    local slotActionType = tonumber(entry.slotActionType)
    if slotActionType ~= nil then
        if slotActionType <= 0 or math.floor(slotActionType) ~= slotActionType then
            AppendResultError(result, "skill_slot_action_type_malformed:" .. tostring(sourceLabel))
            return nil
        end
        normalized.slotActionType = math.floor(slotActionType)
    end

    if IsCraftedSkillSlot(entry) then
        local craftedAbilityId = tonumber(entry.craftedAbilityId)
        local scriptIds = CloneScriptIds(entry.scriptIds)
        if scriptIds == nil then
            AppendResultError(result, "skill_slot_scribing_scripts_malformed:" .. tostring(sourceLabel))
            return nil
        end
        normalized.slotActionType = 3
        normalized.craftedAbilityId = math.floor(craftedAbilityId)
        normalized.scriptIds = scriptIds
    elseif entry.craftedAbilityId ~= nil or entry.scriptIds ~= nil then
        AppendResultError(result, "skill_slot_scribing_malformed:" .. tostring(sourceLabel))
        return nil
    end

    return normalized
end

local function AddDecodedSkillSlot(slots, seen, slotEntry, sourceLabel, result)
    if type(slotEntry) ~= "table" then
        return false
    end

    local key = BuildSkillSlotKey(slotEntry.hotbarCategory, slotEntry.slot)
    if seen[key] then
        AppendResultError(result, "skill_slot_duplicate:" .. tostring(sourceLabel) .. ":" .. key)
        return false
    end

    seen[key] = true
    slots[#slots + 1] = slotEntry
    return true
end

local function AppendDuplicateSkillSlotError(result, hotbarCategory, slotIndex)
    SetResultStatus(result, "failure")
    AppendResultError(
        result,
        "duplicate_skill_slot:hotbarCategory=" .. tostring(hotbarCategory) .. ":slotIndex=" .. tostring(slotIndex)
    )
end

local function ValidateNoDuplicateSkillSlots(slots, result)
    local seen = {}

    for _, entry in ipairs(type(slots) == "table" and slots or {}) do
        local hotbarCategory = NormalizeHotbarCategory(type(entry) == "table" and entry.hotbarCategory or nil)
        local slotIndex = NormalizeSlotIndex(type(entry) == "table" and (entry.slot or entry.slotIndex) or nil)
        local abilityId = tonumber(type(entry) == "table" and entry.abilityId or nil)
        if hotbarCategory ~= nil
            and slotIndex ~= nil
            and abilityId ~= nil
            and abilityId > 0
            and math.floor(abilityId) == abilityId then
            local key = BuildSkillSlotKey(hotbarCategory, slotIndex)
            if seen[key] then
                AppendDuplicateSkillSlotError(result, hotbarCategory, slotIndex)
                return false
            end
            seen[key] = true
        end
    end

    return true
end

local function EncodeSkillBarSlots(slots, hotbarCategory)
    local bySlot = {}
    local slotIndices = {}

    for _, entry in ipairs(type(slots) == "table" and slots or {}) do
        local normalizedHotbarCategory = NormalizeHotbarCategory(type(entry) == "table" and entry.hotbarCategory or nil)
        local slotIndex = NormalizeSlotIndex(type(entry) == "table" and (entry.slot or entry.slotIndex) or nil)
        local abilityId = tonumber(type(entry) == "table" and entry.abilityId or nil)
        if normalizedHotbarCategory == hotbarCategory
            and slotIndex ~= nil
            and abilityId ~= nil
            and abilityId > 0
            and math.floor(abilityId) == abilityId
            and not IsCraftedSkillSlot(entry) then
            bySlot[slotIndex] = math.floor(abilityId)
            slotIndices[#slotIndices + 1] = slotIndex
        end
    end

    table.sort(slotIndices)

    local entries = {}
    for _, slotIndex in ipairs(slotIndices) do
        entries[#entries + 1] = tostring(slotIndex) .. ":" .. tostring(bySlot[slotIndex])
    end
    return table.concat(entries, ",")
end

local function EncodeScribingSkillSlots(slots)
    local scribingEntries = {}

    for _, entry in ipairs(type(slots) == "table" and slots or {}) do
        if IsCraftedSkillSlot(entry) then
            local hotbarCategory = NormalizeHotbarCategory(entry.hotbarCategory)
            local slotIndex = NormalizeSlotIndex(entry.slot or entry.slotIndex)
            local abilityId = tonumber(entry.abilityId)
            local craftedAbilityId = tonumber(entry.craftedAbilityId)
            local scriptIds = CloneScriptIds(entry.scriptIds)
            if hotbarCategory ~= nil
                and slotIndex ~= nil
                and abilityId ~= nil
                and abilityId > 0
                and math.floor(abilityId) == abilityId
                and craftedAbilityId ~= nil
                and craftedAbilityId > 0
                and math.floor(craftedAbilityId) == craftedAbilityId
                and scriptIds ~= nil then
                scribingEntries[#scribingEntries + 1] = {
                    hotbarCategory,
                    slotIndex,
                    math.floor(abilityId),
                    math.floor(craftedAbilityId),
                    scriptIds[1] or 0,
                    scriptIds[2] or 0,
                    scriptIds[3] or 0,
                }
            end
        end
    end

    table.sort(scribingEntries, function(left, right)
        if left[1] == right[1] then
            return left[2] < right[2]
        end
        return left[1] < right[1]
    end)

    return #scribingEntries > 0 and scribingEntries or nil
end

local function EncodeSkillState(skillState, result)
    if type(skillState) ~= "table" then
        return skillState
    end

    if skillState.bar0 ~= nil or skillState.bar1 ~= nil or skillState.scribing ~= nil then
        local decodeResult = BuildCodecResult()
        skillState = DecodeSkillState(skillState, decodeResult)
        if type(decodeResult) == "table" and decodeResult.status ~= "success" then
            SetResultStatus(result, "failure")
            for _, message in ipairs(decodeResult.errors or {}) do
                AppendResultError(result, message)
            end
            return nil
        end
    end

    local encoded = Util:DeepCopy(skillState)
    local slots = type(skillState.slots) == "table" and skillState.slots or {}
    if not ValidateNoDuplicateSkillSlots(slots, result) then
        return nil
    end

    encoded.slots = nil
    local bar0 = EncodeSkillBarSlots(slots, 0)
    local bar1 = EncodeSkillBarSlots(slots, 1)
    encoded.bar0 = bar0 ~= "" and bar0 or nil
    encoded.bar1 = bar1 ~= "" and bar1 or nil
    encoded.scribing = EncodeScribingSkillSlots(slots)
    return encoded
end

local function DecodeCompactSkillBar(encoded, hotbarCategory, slots, seen, result)
    if encoded == nil or encoded == "" then
        return true
    end

    if type(encoded) ~= "string" then
        AppendResultError(result, "skill_bar_not_string:" .. tostring(hotbarCategory))
        return false
    end

    for entry in string.gmatch(encoded, "([^,]+)") do
        local slotText, abilityText = string.match(entry, "^(%d+):(%d+)$")
        local slotIndex = NormalizeSlotIndex(slotText)
        local abilityId = tonumber(abilityText)
        if slotIndex == nil or not IsPositiveInteger(abilityId) then
            AppendResultError(result, "skill_bar_malformed:" .. tostring(hotbarCategory) .. ":" .. tostring(entry))
            return false
        end
        if not AddDecodedSkillSlot(slots, seen, {
            hotbarCategory = hotbarCategory,
            slot = slotIndex,
            abilityId = math.floor(abilityId),
        }, "bar" .. tostring(hotbarCategory), result) then
            return false
        end
    end

    return true
end

local function DecodeCompactScribingEntry(entry, index, result)
    if type(entry) ~= "table" then
        AppendResultError(result, "skill_scribing_not_table:" .. tostring(index))
        return nil
    end

    local hotbarCategory = NormalizeHotbarCategory(entry[1])
    local slotIndex = NormalizeSlotIndex(entry[2])
    local abilityId = tonumber(entry[3])
    local craftedAbilityId = tonumber(entry[4])
    local scriptIds = {
        tonumber(entry[5]),
        tonumber(entry[6]),
        tonumber(entry[7]),
    }

    if hotbarCategory == nil
        or slotIndex == nil
        or not IsPositiveInteger(abilityId)
        or not IsPositiveInteger(craftedAbilityId)
        or not IsNonNegativeInteger(scriptIds[1])
        or not IsNonNegativeInteger(scriptIds[2])
        or not IsNonNegativeInteger(scriptIds[3])
        or ((scriptIds[1] or 0) == 0 and (scriptIds[2] or 0) == 0 and (scriptIds[3] or 0) == 0) then
        AppendResultError(result, "skill_scribing_malformed:" .. tostring(index))
        return nil
    end

    return {
        hotbarCategory = hotbarCategory,
        slot = slotIndex,
        abilityId = math.floor(abilityId),
        slotActionType = 3,
        craftedAbilityId = math.floor(craftedAbilityId),
        scriptIds = {
            math.floor(scriptIds[1]),
            math.floor(scriptIds[2]),
            math.floor(scriptIds[3]),
        },
    }
end

local function DecodeCompactScribingSlots(encoded, slots, seen, result)
    if encoded == nil then
        return true
    end

    if type(encoded) ~= "table" then
        AppendResultError(result, "skill_scribing_not_table")
        return false
    end

    for index, entry in ipairs(encoded) do
        local slotEntry = DecodeCompactScribingEntry(entry, index, result)
        if slotEntry == nil then
            return false
        end
        if not AddDecodedSkillSlot(slots, seen, slotEntry, "scribing", result) then
            return false
        end
    end

    return true
end

local function DecodeLegacySkillSlots(encoded, slots, seen, result)
    if encoded == nil then
        return true
    end

    if type(encoded) ~= "table" then
        AppendResultError(result, "skill_slots_not_table")
        return false
    end

    for index, entry in ipairs(encoded) do
        local normalized = NormalizeLegacySkillSlot(entry, "slots:" .. tostring(index), result)
        if normalized == nil then
            return false
        end
        if not AddDecodedSkillSlot(slots, seen, normalized, "slots", result) then
            return false
        end
    end

    return true
end

local function SortSkillSlots(slots)
    table.sort(slots, function(left, right)
        if left.hotbarCategory == right.hotbarCategory then
            return left.slot < right.slot
        end
        return left.hotbarCategory < right.hotbarCategory
    end)
end

function DecodeSkillState(skillState, result)
    if type(skillState) ~= "table" then
        return skillState
    end

    local decoded = Util:DeepCopy(skillState)
    local slots = {}
    local seen = {}

    local ok = DecodeLegacySkillSlots(skillState.slots, slots, seen, result)
    for _, hotbarCategory in ipairs(SKILL_SLOT_HOTBAR_CATEGORIES) do
        ok = DecodeCompactSkillBar(skillState["bar" .. tostring(hotbarCategory)], hotbarCategory, slots, seen, result) and ok
    end
    ok = DecodeCompactScribingSlots(skillState.scribing, slots, seen, result) and ok

    if not ok then
        SetResultStatus(result, "failure")
        return decoded
    end

    SortSkillSlots(slots)
    decoded.slots = slots
    decoded.bar0 = nil
    decoded.bar1 = nil
    decoded.scribing = nil
    return decoded
end

local function NormalizeSkillSlotsForCompare(skillState)
    local result = BuildCodecResult()
    local decoded = DecodeSkillState(skillState, result)
    if type(result) == "table" and result.status ~= "success" then
        return nil
    end

    local normalized = {}
    for _, entry in ipairs(type(decoded) == "table" and type(decoded.slots) == "table" and decoded.slots or {}) do
        local normalizedEntry = NormalizeLegacySkillSlot(entry, "compare", result)
        if normalizedEntry == nil then
            return nil
        end
        normalized[#normalized + 1] = normalizedEntry
    end
    SortSkillSlots(normalized)
    return normalized
end

local function SkillSlotTablesEqual(left, right)
    left = NormalizeSkillSlotsForCompare(left)
    right = NormalizeSkillSlotsForCompare(right)
    if left == nil and right == nil then
        return true
    end
    if left == nil or right == nil or #left ~= #right then
        return false
    end

    for index = 1, #left do
        local leftEntry = left[index]
        local rightEntry = right[index]
        if leftEntry.hotbarCategory ~= rightEntry.hotbarCategory
            or leftEntry.slot ~= rightEntry.slot
            or leftEntry.abilityId ~= rightEntry.abilityId
            or (leftEntry.slotActionType or 1) ~= (rightEntry.slotActionType or 1)
            or (leftEntry.craftedAbilityId or 0) ~= (rightEntry.craftedAbilityId or 0) then
            return false
        end

        for scriptIndex = 1, 3 do
            local leftScriptId = type(leftEntry.scriptIds) == "table" and (leftEntry.scriptIds[scriptIndex] or 0) or 0
            local rightScriptId = type(rightEntry.scriptIds) == "table" and (rightEntry.scriptIds[scriptIndex] or 0) or 0
            if leftScriptId ~= rightScriptId then
                return false
            end
        end
    end

    return true
end

local function EncodePassiveSnapshot(snapshot)
    if snapshot == nil then
        return nil
    end

    if type(snapshot) == "string" then
        return snapshot
    end

    if type(snapshot) ~= "table" then
        return nil
    end

    local lines = type(snapshot.lines) == "table" and snapshot.lines or {}
    local lineIds = {}
    for rawSkillLineId, lineEntries in pairs(lines) do
        local skillLineId = tonumber(rawSkillLineId)
        if IsPositiveInteger(skillLineId) and type(lineEntries) == "table" then
            lineIds[#lineIds + 1] = math.floor(skillLineId)
        end
    end
    table.sort(lineIds)

    local lineParts = {}
    for _, skillLineId in ipairs(lineIds) do
        local lineEntries = lines[skillLineId] or lines[tostring(skillLineId)]
        local skillIndexes = {}
        for rawSkillIndex, rank in pairs(type(lineEntries) == "table" and lineEntries or {}) do
            local skillIndex = tonumber(rawSkillIndex)
            local savedRank = tonumber(rank)
            if IsPositiveInteger(skillIndex) and IsNonNegativeInteger(savedRank) then
                skillIndexes[#skillIndexes + 1] = math.floor(skillIndex)
            end
        end
        table.sort(skillIndexes)

        local passiveParts = {}
        for _, skillIndex in ipairs(skillIndexes) do
            local savedRank = tonumber(lineEntries[skillIndex] or lineEntries[tostring(skillIndex)])
            passiveParts[#passiveParts + 1] = tostring(skillIndex) .. ":" .. tostring(math.floor(savedRank))
        end
        if #passiveParts > 0 then
            lineParts[#lineParts + 1] = tostring(skillLineId) .. "|" .. table.concat(passiveParts, ",")
        end
    end

    return #lineParts > 0 and table.concat(lineParts, ";") or PASSIVE_SNAPSHOT_EMPTY
end

local function DecodePassiveSnapshot(encoded, result)
    if encoded == nil then
        return nil
    end

    if type(encoded) == "table" then
        local snapshot = {
            version = 1,
            lines = {},
        }
        local lines = type(encoded.lines) == "table" and encoded.lines or nil
        if lines == nil then
            AppendResultError(result, "passive_snapshot_table_malformed")
            SetResultStatus(result, "partial")
            return nil
        end
        for rawSkillLineId, lineEntries in pairs(lines) do
            local skillLineId = tonumber(rawSkillLineId)
            if IsPositiveInteger(skillLineId) and type(lineEntries) == "table" then
                local normalizedLine = {}
                local hasEntry = false
                for rawSkillIndex, rank in pairs(lineEntries) do
                    local skillIndex = tonumber(rawSkillIndex)
                    local savedRank = tonumber(rank)
                    if IsPositiveInteger(skillIndex) and IsNonNegativeInteger(savedRank) then
                        normalizedLine[math.floor(skillIndex)] = math.floor(savedRank)
                        hasEntry = true
                    else
                        AppendResultError(result, "passive_snapshot_entry_malformed:" .. tostring(rawSkillLineId))
                        SetResultStatus(result, "partial")
                    end
                end
                if hasEntry then
                    snapshot.lines[math.floor(skillLineId)] = normalizedLine
                end
            else
                AppendResultError(result, "passive_snapshot_line_malformed:" .. tostring(rawSkillLineId))
                SetResultStatus(result, "partial")
            end
        end
        return snapshot
    end

    if type(encoded) ~= "string" then
        AppendResultError(result, "passive_snapshot_not_string")
        SetResultStatus(result, "partial")
        return nil
    end

    if encoded == PASSIVE_SNAPSHOT_EMPTY then
        return {
            version = 1,
            lines = {},
        }
    end

    if encoded == "" then
        AppendResultError(result, "passive_snapshot_empty_string_malformed")
        SetResultStatus(result, "partial")
        return nil
    end

    local snapshot = {
        version = 1,
        lines = {},
    }
    local seenLines = {}
    for lineText in string.gmatch(encoded, "([^;]+)") do
        local skillLineText, entriesText = string.match(lineText, "^(%d+)|(.+)$")
        local skillLineId = tonumber(skillLineText)
        if not IsPositiveInteger(skillLineId) or seenLines[skillLineId] == true then
            AppendResultError(result, "passive_snapshot_line_malformed:" .. tostring(lineText))
            SetResultStatus(result, "partial")
            return nil
        end
        seenLines[skillLineId] = true

        local lineEntries = {}
        local seenIndexes = {}
        for entryText in string.gmatch(entriesText, "([^,]+)") do
            local skillIndexText, rankText = string.match(entryText, "^(%d+):(%d+)$")
            local skillIndex = tonumber(skillIndexText)
            local savedRank = tonumber(rankText)
            if not IsPositiveInteger(skillIndex)
                or not IsNonNegativeInteger(savedRank)
                or seenIndexes[skillIndex] == true then
                AppendResultError(result, "passive_snapshot_entry_malformed:" .. tostring(lineText))
                SetResultStatus(result, "partial")
                return nil
            end
            seenIndexes[skillIndex] = true
            lineEntries[math.floor(skillIndex)] = math.floor(savedRank)
        end

        local hasEntry = false
        for _ in pairs(lineEntries) do
            hasEntry = true
            break
        end
        if not hasEntry then
            AppendResultError(result, "passive_snapshot_line_empty:" .. tostring(skillLineId))
            SetResultStatus(result, "partial")
            return nil
        end
        snapshot.lines[math.floor(skillLineId)] = lineEntries
    end

    return snapshot
end

local function PassiveSnapshotTablesEqual(left, right)
    local result = BuildCodecResult()
    left = DecodePassiveSnapshot(EncodePassiveSnapshot(left), result)
    if type(result) == "table" and result.status == "failure" then
        return false
    end
    result = BuildCodecResult()
    right = DecodePassiveSnapshot(EncodePassiveSnapshot(right), result)
    if type(result) == "table" and result.status == "failure" then
        return false
    end
    if left == nil and right == nil then
        return true
    end
    if left == nil or right == nil then
        return false
    end
    for skillLineId, lineEntries in pairs(left.lines or {}) do
        for skillIndex, rank in pairs(lineEntries or {}) do
            if type(right.lines) ~= "table"
                or type(right.lines[skillLineId]) ~= "table"
                or right.lines[skillLineId][skillIndex] ~= rank then
                return false
            end
        end
    end
    for skillLineId, lineEntries in pairs(right.lines or {}) do
        for skillIndex, rank in pairs(lineEntries or {}) do
            if type(left.lines) ~= "table"
                or type(left.lines[skillLineId]) ~= "table"
                or left.lines[skillLineId][skillIndex] ~= rank then
                return false
            end
        end
    end
    return true
end

local function CountBuildsInBucket(bucket)
    local count = 0
    if type(bucket) ~= "table" then
        return count
    end

    if type(bucket.pages) == "table" then
        for _, page in pairs(bucket.pages) do
            if type(page) == "table" and type(page.builds) == "table" then
                count = count + CountEntries(page.builds)
            end
        end
    else
        for key, value in pairs(bucket) do
            if not RESERVED_CHARACTER_BUCKET_KEYS[key] and type(value) == "table" then
                count = count + 1
            end
        end
    end
    return count
end

local function TransformBuildForSchema9(codec, build, buildId)
    local runtimeBuild, runtimeDecodeResult = codec:DecodeBuildForRuntime(build)
    if type(runtimeDecodeResult) == "table" and runtimeDecodeResult.status ~= "success" then
        return nil, "decode_source_failed:" .. tostring(buildId) .. ":" .. tostring(runtimeDecodeResult.status)
    end

    local encoded, encodeResult = codec:EncodeBuildForPersist(runtimeBuild)
    if type(encodeResult) == "table" and encodeResult.status ~= "success" then
        return nil, "encode_source_failed:" .. tostring(buildId) .. ":" .. tostring(encodeResult.status)
    end
    local decoded, decodeResult = codec:DecodeBuildForRuntime(encoded)
    if type(decodeResult) == "table" and decodeResult.status ~= "success" then
        return nil, "decode_verify_failed:" .. tostring(buildId) .. ":" .. tostring(decodeResult.status)
    end
    if not ChampionPointTablesEqual(runtimeBuild and runtimeBuild.championPoints, decoded and decoded.championPoints) then
        return nil, "cp_roundtrip_mismatch:" .. tostring(buildId)
    end
    if not SkillSlotTablesEqual(runtimeBuild and runtimeBuild.skills, decoded and decoded.skills) then
        return nil, "skill_slots_roundtrip_mismatch:" .. tostring(buildId)
    end
    return encoded
end

local function TransformBuildForSchema10(codec, build, buildId)
    local runtimeBuild, runtimeDecodeResult = codec:DecodeBuildForRuntime(build)
    if type(runtimeDecodeResult) == "table" and runtimeDecodeResult.status == "failure" then
        return nil, "decode_source_failed:" .. tostring(buildId) .. ":" .. tostring(runtimeDecodeResult.status)
    end

    if type(runtimeBuild) == "table" then
        runtimeBuild.passivePolicy = M:NormalizePassivePolicy(runtimeBuild.passivePolicy)
    end

    local encoded, encodeResult = codec:EncodeBuildForPersist(runtimeBuild)
    if type(encodeResult) == "table" and encodeResult.status ~= "success" then
        return nil, "encode_source_failed:" .. tostring(buildId) .. ":" .. tostring(encodeResult.status)
    end
    local decoded, decodeResult = codec:DecodeBuildForRuntime(encoded)
    if type(decodeResult) == "table" and decodeResult.status == "failure" then
        return nil, "decode_verify_failed:" .. tostring(buildId) .. ":" .. tostring(decodeResult.status)
    end
    if not PassiveSnapshotTablesEqual(runtimeBuild and runtimeBuild.passiveSnapshot, decoded and decoded.passiveSnapshot) then
        return nil, "passive_snapshot_roundtrip_mismatch:" .. tostring(buildId)
    end
    return encoded
end

local function TransformBuildMapForSchema9(codec, builds)
    local transformed = {}
    for buildId, build in pairs(builds or {}) do
        if type(buildId) == "string" and type(build) == "table" then
            local encodedBuild, err = TransformBuildForSchema9(codec, build, buildId)
            if encodedBuild == nil then
                return nil, err
            end
            transformed[buildId] = encodedBuild
        end
    end
    return transformed
end

local function TransformBucketForSchema9(codec, bucket)
    local transformed = Util:DeepCopy(bucket)
    if type(transformed) ~= "table" then
        return transformed
    end

    if type(transformed.pages) == "table" then
        for pageId, page in pairs(transformed.pages) do
            if type(page) == "table" and type(page.builds) == "table" then
                local builds, err = TransformBuildMapForSchema9(codec, page.builds)
                if builds == nil then
                    return nil, tostring(pageId) .. ":" .. tostring(err)
                end
                page.builds = builds
            end
        end
    else
        for key, value in pairs(transformed) do
            if not RESERVED_CHARACTER_BUCKET_KEYS[key] and type(value) == "table" then
                local encodedBuild, err = TransformBuildForSchema9(codec, value, key)
                if encodedBuild == nil then
                    return nil, err
                end
                transformed[key] = encodedBuild
            end
        end
    end

    return transformed
end

function M:GetCurrentSchemaVersion()
    return tonumber(Addon.SAVED_VARS_SCHEMA_VERSION) or 0
end

function M:EncodeBuildForPersist(runtimeBuild)
    local result = BuildCodecResult()
    local persistentBuild = Util:DeepCopy(runtimeBuild)
    if type(persistentBuild) == "table" then
        persistentBuild.passivePolicy = M:NormalizePassivePolicy(runtimeBuild and runtimeBuild.passivePolicy)
        persistentBuild.passiveSnapshot = EncodePassiveSnapshot(runtimeBuild and runtimeBuild.passiveSnapshot)
        persistentBuild.championPoints = EncodeChampionPoints(runtimeBuild and runtimeBuild.championPoints)
        persistentBuild.skills = EncodeSkillState(runtimeBuild and runtimeBuild.skills, result)
        if type(result) == "table" and result.status ~= "success" then
            return nil, result
        end
    end
    return persistentBuild, result
end

function M:DecodeBuildForRuntime(persistentBuild)
    local result = BuildCodecResult()
    local runtimeBuild = Util:DeepCopy(persistentBuild)
    if type(runtimeBuild) == "table" then
        runtimeBuild.passivePolicy = DecodePassivePolicy(persistentBuild and persistentBuild.passivePolicy)
        runtimeBuild.passiveSnapshot = DecodePassiveSnapshot(persistentBuild and persistentBuild.passiveSnapshot, result)
        runtimeBuild.championPoints = DecodeChampionPoints(persistentBuild and persistentBuild.championPoints, result)
        runtimeBuild.skills = DecodeSkillState(persistentBuild and persistentBuild.skills, result)
    else
        SetResultStatus(result, "failure")
        AppendResultError(result, "build_not_table")
    end
    if result.status == nil then
        SetResultStatus(result, "success")
    end
    return runtimeBuild, result
end

function M:MigrateToSchema9(savedVars)
    if type(savedVars) ~= "table" then
        return false, "saved_vars_invalid"
    end

    local oldBuildsByCharacter = savedVars.buildsByCharacter
    if type(oldBuildsByCharacter) ~= "table" then
        savedVars.buildsByCharacter = {}
        return true, {
            buildCount = 0,
            beforeBytes = 0,
            afterBytes = 0,
        }
    end

    local migratedBuildsByCharacter = {}
    local buildCount = 0
    for characterKey, bucket in pairs(oldBuildsByCharacter) do
        local migratedBucket, err = TransformBucketForSchema9(self, bucket)
        if migratedBucket == nil then
            return false, "character=" .. tostring(characterKey) .. ":" .. tostring(err)
        end
        migratedBuildsByCharacter[characterKey] = migratedBucket
        buildCount = buildCount + CountBuildsInBucket(bucket)
    end

    savedVars.buildsByCharacter = migratedBuildsByCharacter
    if type(Log.LogDebugSummary) == "function" then
        Log.LogDebugSummary("SavedVariables schema 9 migration complete", "buildCount=" .. tostring(buildCount))
    end
    return true, {
        buildCount = buildCount,
    }
end

function M:MigrateToSchema10(savedVars)
    if type(savedVars) ~= "table" then
        return false, "saved_vars_invalid"
    end

    local oldBuildsByCharacter = savedVars.buildsByCharacter
    if type(oldBuildsByCharacter) ~= "table" then
        savedVars.buildsByCharacter = {}
        return true, {
            buildCount = 0,
        }
    end

    local migratedBuildsByCharacter = {}
    local buildCount = 0
    for characterKey, bucket in pairs(oldBuildsByCharacter) do
        local transformed = Util:DeepCopy(bucket)
        if type(transformed) == "table" then
            if type(transformed.pages) == "table" then
                for pageId, page in pairs(transformed.pages) do
                    if type(page) == "table" and type(page.builds) == "table" then
                        local builds = {}
                        for buildId, build in pairs(page.builds) do
                            if type(buildId) == "string" and type(build) == "table" then
                                local encodedBuild, err = TransformBuildForSchema10(self, build, buildId)
                                if encodedBuild == nil then
                                    return false, "character=" .. tostring(characterKey) .. ":" .. tostring(pageId) .. ":" .. tostring(err)
                                end
                                builds[buildId] = encodedBuild
                                buildCount = buildCount + 1
                            end
                        end
                        page.builds = builds
                    end
                end
            else
                for key, value in pairs(transformed) do
                    if not RESERVED_CHARACTER_BUCKET_KEYS[key] and type(value) == "table" then
                        local encodedBuild, err = TransformBuildForSchema10(self, value, key)
                        if encodedBuild == nil then
                            return false, "character=" .. tostring(characterKey) .. ":" .. tostring(err)
                        end
                        transformed[key] = encodedBuild
                        buildCount = buildCount + 1
                    end
                end
            end
        end
        migratedBuildsByCharacter[characterKey] = transformed
    end

    savedVars.buildsByCharacter = migratedBuildsByCharacter
    if type(Log.LogDebugSummary) == "function" then
        Log.LogDebugSummary("SavedVariables schema 10 migration complete", "buildCount=" .. tostring(buildCount))
    end
    return true, {
        buildCount = buildCount,
    }
end
