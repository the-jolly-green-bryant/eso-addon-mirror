local Addon = LarvalTearMod
local LTM_SHARED_UTIL = Addon.Common.Util
local CRYPT_CANON_SPECIAL_ULTIMATE_ID = 195031

function LTM_SHARED_UTIL:NormalizeNumber(value)
    local numberValue = tonumber(value)
    if numberValue == nil then
        return nil
    end

    return math.floor(numberValue)
end

function LTM_SHARED_UTIL:BuildSlotKey(hotbarCategory, slotIndex)
    return tostring(hotbarCategory) .. ":" .. tostring(slotIndex)
end

function LTM_SHARED_UTIL:NormalizeScriptIds(scriptIds)
    if type(scriptIds) ~= "table" then
        return nil
    end

    local normalized = {}
    local hasValue = false
    for index = 1, 3 do
        local scriptId = self:NormalizeNumber(scriptIds[index])
        if scriptId ~= nil and scriptId > 0 then
            normalized[index] = scriptId
            hasValue = true
        else
            normalized[index] = 0
        end
    end

    if hasValue then
        return normalized
    end

    return nil
end

function LTM_SHARED_UTIL:AppendNormalizedSlotTarget(targets, seenKeys, hotbarCategory, slotIndex, abilityId, extra)
    hotbarCategory = self:NormalizeNumber(hotbarCategory)
    slotIndex = self:NormalizeNumber(slotIndex)
    abilityId = self:NormalizeNumber(abilityId)
    if hotbarCategory == nil or slotIndex == nil or abilityId == nil then
        return
    end

    local key = self:BuildSlotKey(hotbarCategory, slotIndex)
    if seenKeys[key] then
        return
    end

    seenKeys[key] = true
    local target = {
        hotbarCategory = hotbarCategory,
        slotIndex = slotIndex,
        abilityId = abilityId,
    }
    if type(extra) == "table" then
        local slotActionType = self:NormalizeNumber(extra.slotActionType)
        if slotActionType ~= nil then
            target.slotActionType = slotActionType
        end

        local craftedAbilityId = self:NormalizeNumber(extra.craftedAbilityId)
        if craftedAbilityId ~= nil and craftedAbilityId > 0 then
            target.craftedAbilityId = craftedAbilityId
        end

        local scriptIds = self:NormalizeScriptIds(extra.scriptIds)
        if scriptIds ~= nil then
            target.scriptIds = scriptIds
        end
    end

    targets[#targets + 1] = target
end

local function ResolveCraftedAbilityIdFromAbilityId(abilityId)
    abilityId = LTM_SHARED_UTIL:NormalizeNumber(abilityId)
    if abilityId == nil or abilityId <= 0 or type(GetAbilityCraftedAbilityId) ~= "function" then
        return nil
    end

    local ok, craftedAbilityId = pcall(GetAbilityCraftedAbilityId, abilityId)
    if not ok then
        return nil
    end

    craftedAbilityId = LTM_SHARED_UTIL:NormalizeNumber(craftedAbilityId)
    if craftedAbilityId ~= nil and craftedAbilityId > 0 then
        return craftedAbilityId
    end

    return nil
end

function LTM_SHARED_UTIL:ResolveCraftedAbilityTarget(target, skillData)
    local targetAbilityId = self:NormalizeNumber(type(target) == "table" and (target.targetAbilityId or target.abilityId) or nil)
    local slotActionType = self:NormalizeNumber(type(target) == "table" and target.slotActionType or nil)
    local savedCraftedAbilityId = self:NormalizeNumber(type(target) == "table" and target.craftedAbilityId or nil)
    local craftedAbilityActionType = ACTION_TYPE_CRAFTED_ABILITY or 3

    if slotActionType == craftedAbilityActionType then
        local fallbackCraftedAbilityId = nil
        if savedCraftedAbilityId == nil or savedCraftedAbilityId <= 0 then
            fallbackCraftedAbilityId = ResolveCraftedAbilityIdFromAbilityId(targetAbilityId)
        end
        return {
            isCrafted = true,
            craftedAbilityId = savedCraftedAbilityId ~= nil and savedCraftedAbilityId > 0
                and savedCraftedAbilityId
                or fallbackCraftedAbilityId,
            source = "saved_slot_action_type",
            fallbackCraftedAbilityId = fallbackCraftedAbilityId,
        }
    end

    if savedCraftedAbilityId ~= nil and savedCraftedAbilityId > 0 then
        return {
            isCrafted = true,
            craftedAbilityId = savedCraftedAbilityId,
            source = "saved_crafted_ability_id",
            fallbackCraftedAbilityId = nil,
        }
    end

    local fallbackCraftedAbilityId = ResolveCraftedAbilityIdFromAbilityId(targetAbilityId)
    if fallbackCraftedAbilityId ~= nil and fallbackCraftedAbilityId > 0 then
        return {
            isCrafted = true,
            craftedAbilityId = fallbackCraftedAbilityId,
            source = "ability_api_fallback",
            fallbackCraftedAbilityId = fallbackCraftedAbilityId,
        }
    end

    if type(skillData) == "table"
        and type(skillData.IsCraftedAbility) == "function"
        and skillData:IsCraftedAbility() == true then
        return {
            isCrafted = true,
            craftedAbilityId = nil,
            source = "skill_data",
            fallbackCraftedAbilityId = fallbackCraftedAbilityId,
        }
    end

    return {
        isCrafted = false,
        craftedAbilityId = nil,
        source = "none",
        fallbackCraftedAbilityId = fallbackCraftedAbilityId,
    }
end

local function ResolveSkillLineIdFromSkillData(skillData, skillLineData)
    if type(skillData) == "table" and type(skillData.GetSkillLineId) == "function" then
        local skillLineId = skillData:GetSkillLineId()
        if type(skillLineId) == "number" and skillLineId > 0 then
            return skillLineId, "skillData.GetSkillLineId"
        end
    end

    if type(skillLineData) == "table" and type(skillLineData.GetId) == "function" then
        local skillLineId = skillLineData:GetId()
        if type(skillLineId) == "number" and skillLineId > 0 then
            return skillLineId, "skillLineData.GetId"
        end
    end

    if type(skillLineData) == "table" and type(skillLineData.GetSkillLineId) == "function" then
        local skillLineId = skillLineData:GetSkillLineId()
        if type(skillLineId) == "number" and skillLineId > 0 then
            return skillLineId, "skillLineData.GetSkillLineId"
        end
    end

    return nil, "unresolved"
end

function LTM_SHARED_UTIL:ResolveActiveSkillTargetState(target)
    local resolved = {
        hotbarCategory = self:NormalizeNumber(type(target) == "table" and target.hotbarCategory or nil),
        slotIndex = self:NormalizeNumber(type(target) == "table" and (target.slotIndex or target.slot) or nil),
        targetAbilityId = self:NormalizeNumber(type(target) == "table" and (target.targetAbilityId or target.abilityId) or nil),
        slotActionType = self:NormalizeNumber(type(target) == "table" and target.slotActionType or nil),
        craftedAbilityId = self:NormalizeNumber(type(target) == "table" and target.craftedAbilityId or nil),
        scriptIds = type(target) == "table" and target.scriptIds or nil,
        progressionId = nil,
        targetMorphSlot = nil,
        currentMorphSlot = nil,
        pendingMorphSlot = nil,
        effectiveMorphSlotForPlanning = nil,
        currentEffectiveAbilityId = nil,
        skillLineId = nil,
        isActiveSkill = false,
        isPassiveSkill = false,
        isCraftedAbility = false,
        isAutoGrant = false,
        isClassSkillLine = false,
        isClassMastery = false,
        skillLineActive = false,
        isPlayerClassSkillLine = false,
        skillPointCostMultiplier = nil,
        committedPurchased = false,
        pendingPurchaseObserved = false,
        effectivePurchasedForPlanning = false,
        pendingMorphObserved = false,
        requiresPurchase = false,
        requiresMorph = false,
        ready = false,
        unresolved = false,
        nonSlottable = false,
        sameMorphSlotForPlanning = false,
        effectiveSkillLineActiveForPlanning = false,
        reason = nil,
        progressionData = nil,
        skillData = nil,
        skillLineData = nil,
        skillLineIdSource = nil,
        allocator = nil,
    }

    if resolved.targetAbilityId == nil then
        resolved.unresolved = true
        resolved.reason = "invalid_target_ability_id"
        return resolved
    end

    if resolved.targetAbilityId <= 0 then
        resolved.ready = true
        resolved.reason = "empty_target_slot"
        return resolved
    end

    if resolved.targetAbilityId == CRYPT_CANON_SPECIAL_ULTIMATE_ID then
        resolved.unresolved = true
        resolved.reason = "cryptcanon_special_ultimate_requires_overwrite"
        return resolved
    end

    local craftedInfo = self:ResolveCraftedAbilityTarget(resolved)
    resolved.fallbackCraftedAbilityId = craftedInfo.fallbackCraftedAbilityId
    resolved.craftedResolveSource = craftedInfo.source
    if craftedInfo.isCrafted == true then
        resolved.craftedAbilityId = craftedInfo.craftedAbilityId or resolved.craftedAbilityId
        resolved.nonSlottable = true
        resolved.isCraftedAbility = true
        resolved.reason = "crafted_ability_not_supported"
        return resolved
    end

    if type(SKILLS_DATA_MANAGER) ~= "table"
        or type(SKILLS_DATA_MANAGER.GetProgressionDataByAbilityId) ~= "function" then
        resolved.unresolved = true
        resolved.reason = "skills_data_manager_unavailable"
        return resolved
    end

    local progressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(resolved.targetAbilityId)
    if type(progressionData) ~= "table" then
        resolved.unresolved = true
        resolved.reason = "unknown_target_ability"
        return resolved
    end
    resolved.progressionData = progressionData

    local skillData = type(progressionData.GetSkillData) == "function" and progressionData:GetSkillData() or nil
    if type(skillData) ~= "table" then
        resolved.unresolved = true
        resolved.reason = "skill_data_unavailable"
        return resolved
    end
    resolved.skillData = skillData

    resolved.progressionId = type(skillData.GetProgressionId) == "function" and skillData:GetProgressionId() or nil
    resolved.targetMorphSlot = type(progressionData.GetMorphSlot) == "function" and progressionData:GetMorphSlot() or nil
    resolved.isActiveSkill = type(skillData.IsActive) == "function" and skillData:IsActive() or false
    resolved.isPassiveSkill = type(skillData.IsPassive) == "function" and skillData:IsPassive() or false
    resolved.isCraftedAbility = type(skillData.IsCraftedAbility) == "function" and skillData:IsCraftedAbility() or false
    resolved.isAutoGrant = type(skillData.IsAutoGrant) == "function" and skillData:IsAutoGrant() == true or false
    if resolved.isCraftedAbility == true then
        resolved.craftedResolveSource = "skill_data"
    end

    if not resolved.isActiveSkill then
        resolved.nonSlottable = true
        resolved.reason = "target_is_not_active_skill"
        return resolved
    end

    if resolved.isPassiveSkill then
        resolved.nonSlottable = true
        resolved.reason = "passive_not_supported"
        return resolved
    end

    if resolved.isCraftedAbility then
        resolved.nonSlottable = true
        resolved.reason = "crafted_ability_not_supported"
        return resolved
    end

    local skillLineData = type(skillData.GetSkillLineData) == "function" and skillData:GetSkillLineData() or nil
    if type(skillLineData) ~= "table" then
        resolved.unresolved = true
        resolved.reason = "skill_line_data_unavailable"
        return resolved
    end
    resolved.skillLineData = skillLineData
    resolved.skillLineId, resolved.skillLineIdSource = ResolveSkillLineIdFromSkillData(skillData, skillLineData)

    resolved.isClassSkillLine = type(skillLineData.IsClassSkillLine) == "function"
        and skillLineData:IsClassSkillLine() == true
        or false
    resolved.isClassMastery = type(skillLineData.IsClassMastery) == "function"
        and skillLineData:IsClassMastery() == true
        or false
    resolved.skillLineActive = type(skillLineData.IsActive) == "function" and skillLineData:IsActive() or false
    resolved.effectiveSkillLineActiveForPlanning = resolved.skillLineActive
    resolved.isPlayerClassSkillLine = type(skillLineData.IsPlayerClassSkillLine) == "function"
        and skillLineData:IsPlayerClassSkillLine()
        or false
    if type(skillData.GetSkillPointCostMultiplier) == "function" then
        local ok, multiplier = pcall(skillData.GetSkillPointCostMultiplier, skillData)
        multiplier = ok and tonumber(multiplier) or nil
        if multiplier ~= nil and multiplier > 0 and math.floor(multiplier) == multiplier then
            resolved.skillPointCostMultiplier = multiplier
        end
    end
    resolved.committedPurchased = type(skillData.IsPurchased) == "function" and skillData:IsPurchased() or false

    local allocator = type(skillData.GetPointAllocator) == "function" and skillData:GetPointAllocator() or nil
    resolved.allocator = allocator
    if type(allocator) == "table" and type(allocator.IsPurchasedChangePending) == "function" then
        resolved.pendingPurchaseObserved = allocator:IsPurchasedChangePending() == true
    end
    resolved.effectivePurchasedForPlanning = resolved.committedPurchased or resolved.pendingPurchaseObserved

    if not resolved.effectivePurchasedForPlanning then
        resolved.requiresPurchase = true
        resolved.reason = "skill_not_purchased"
        return resolved
    end

    if not resolved.effectiveSkillLineActiveForPlanning then
        resolved.unresolved = true
        resolved.reason = "skill_line_not_active"
        return resolved
    end

    local hasSlotContext = resolved.hotbarCategory ~= nil
    if hasSlotContext then
        local currentProgressionData = type(skillData.GetPointAllocatorProgressionData) == "function"
            and skillData:GetPointAllocatorProgressionData()
            or nil
        if type(currentProgressionData) ~= "table" then
            resolved.unresolved = true
            resolved.reason = "current_progression_unavailable"
            return resolved
        end
        resolved.currentEffectiveAbilityId = type(currentProgressionData.GetEffectiveAbilityId) == "function"
            and currentProgressionData:GetEffectiveAbilityId(resolved.hotbarCategory)
            or nil
    end
    resolved.currentMorphSlot = type(skillData.GetCurrentMorphSlot) == "function" and skillData:GetCurrentMorphSlot() or nil

    if type(allocator) == "table" and type(allocator.GetMorphSlot) == "function" then
        resolved.pendingMorphSlot = allocator:GetMorphSlot()
    end

    resolved.pendingMorphObserved = resolved.targetMorphSlot ~= nil
        and resolved.pendingMorphSlot ~= nil
        and resolved.pendingMorphSlot == resolved.targetMorphSlot

    if resolved.pendingMorphObserved then
        resolved.effectiveMorphSlotForPlanning = resolved.pendingMorphSlot
    else
        resolved.effectiveMorphSlotForPlanning = resolved.currentMorphSlot
    end

    resolved.sameMorphSlotForPlanning = resolved.targetMorphSlot ~= nil
        and resolved.effectiveMorphSlotForPlanning ~= nil
        and resolved.effectiveMorphSlotForPlanning == resolved.targetMorphSlot

    if not hasSlotContext and resolved.sameMorphSlotForPlanning then
        resolved.ready = true
        resolved.reason = resolved.pendingMorphObserved and "pending_morph_ready" or "already_ready"
        return resolved
    end

    if resolved.currentEffectiveAbilityId == resolved.targetAbilityId
        or resolved.pendingMorphObserved then
        resolved.ready = true
        if resolved.pendingMorphObserved then
            resolved.reason = "pending_morph_ready"
        else
            resolved.reason = "already_ready"
        end
        return resolved
    end

    resolved.requiresMorph = true
    if resolved.targetMorphSlot ~= nil
        and resolved.effectiveMorphSlotForPlanning ~= nil
        and resolved.effectiveMorphSlotForPlanning ~= resolved.targetMorphSlot then
        resolved.reason = "target_morph_differs_from_current"
    else
        resolved.reason = "target_effective_ability_not_current"
    end

    return resolved
end

function LTM_SHARED_UTIL:NormalizeLineIdList(lineIds)
    local normalized = {}
    local seen = {}

    if type(lineIds) ~= "table" then
        return normalized
    end

    for _, rawValue in ipairs(lineIds) do
        local lineId = self:NormalizeNumber(rawValue)
        if lineId ~= nil and not seen[lineId] then
            seen[lineId] = true
            normalized[#normalized + 1] = lineId
        end
    end

    table.sort(normalized)
    return normalized
end

function LTM_SHARED_UTIL:BuildLineIdSet(lineIds)
    local set = {}
    for _, lineId in ipairs(lineIds or {}) do
        set[lineId] = true
    end
    return set
end

function LTM_SHARED_UTIL:BuildLineIdSignature(lineIds)
    local normalized = self:NormalizeLineIdList(lineIds)
    return table.concat(normalized, ",")
end

-- Shared default domain. Consumers must treat this table as immutable.
LTM_SHARED_UTIL.HOTBAR_CATEGORIES = { 0, 1 }

local function ExtractSlotValue(value)
    if type(value) ~= "table" then
        return value, nil
    end

    return value.abilityId or value.targetAbilityId, value
end

function LTM_SHARED_UTIL:NormalizeSlotTargets(config, hotbarCategories)
    local targets = {}
    local seenKeys = {}
    config = config or {}
    hotbarCategories = hotbarCategories or self.HOTBAR_CATEGORIES

    if type(config.slots) == "table" then
        for _, entry in ipairs(config.slots) do
            if type(entry) == "table" then
                self:AppendNormalizedSlotTarget(targets, seenKeys, entry.hotbarCategory,
                    entry.slotIndex or entry.slot, entry.abilityId, entry)
            end
        end
    end

    local hotbars = config.hotbars
    if type(hotbars) == "table" then
        for hotbarCategory, slotTable in pairs(hotbars) do
            if type(slotTable) == "table" then
                for slotIndex, abilityId in pairs(slotTable) do
                    local slotAbilityId, slotExtra = ExtractSlotValue(abilityId)
                    local normalizedHotbarCategory = hotbarCategory
                    if hotbarCategory == "front" then
                        normalizedHotbarCategory = 0
                    elseif hotbarCategory == "back" then
                        normalizedHotbarCategory = 1
                    end
                    self:AppendNormalizedSlotTarget(targets, seenKeys, normalizedHotbarCategory,
                        slotExtra and (slotExtra.slotIndex or slotExtra.slot) or slotIndex,
                        slotAbilityId, slotExtra)
                end
            end
        end
    end

    for _, hotbarCategory in ipairs(hotbarCategories) do
        local slotTable = config[hotbarCategory]
        if type(slotTable) == "table" then
            for slotIndex, abilityId in pairs(slotTable) do
                local slotAbilityId, slotExtra = ExtractSlotValue(abilityId)
                self:AppendNormalizedSlotTarget(targets, seenKeys,
                    slotExtra and slotExtra.hotbarCategory or hotbarCategory,
                    slotExtra and (slotExtra.slotIndex or slotExtra.slot) or slotIndex,
                    slotAbilityId, slotExtra)
            end
        end
    end

    if type(config.skills) == "table" then
        for _, entry in ipairs(config.skills) do
            if type(entry) == "table" then
                self:AppendNormalizedSlotTarget(targets, seenKeys, entry.hotbarCategory or 0,
                    entry.slotIndex or entry.slot, entry.abilityId, entry)
            end
        end
    end

    table.sort(targets, function(left, right)
        if left.hotbarCategory == right.hotbarCategory then
            return left.slotIndex < right.slotIndex
        end
        return left.hotbarCategory < right.hotbarCategory
    end)

    return targets
end

function LTM_SHARED_UTIL:GetEventManager()
    if type(_G) == "table" and _G.EVENT_MANAGER ~= nil then
        local candidate = _G.EVENT_MANAGER
        if type(candidate.RegisterForEvent) == "function"
            and type(candidate.UnregisterForEvent) == "function" then
            return candidate, "_G.EVENT_MANAGER"
        end
    end

    if EVENT_MANAGER ~= nil then
        local candidate = EVENT_MANAGER
        if type(candidate.RegisterForEvent) == "function"
            and type(candidate.UnregisterForEvent) == "function" then
            return candidate, "EVENT_MANAGER"
        end
    end

    return nil, "missing"
end

function LTM_SHARED_UTIL:DeepCopy(value, seen)
    if type(value) ~= "table" then
        return value
    end

    seen = seen or {}
    if seen[value] ~= nil then
        return seen[value]
    end

    local copy = {}
    seen[value] = copy

    for key, entryValue in pairs(value) do
        copy[self:DeepCopy(key, seen)] = self:DeepCopy(entryValue, seen)
    end

    local meta = getmetatable(value)
    if meta ~= nil then
        setmetatable(copy, meta)
    end

    return copy
end

function LTM_SHARED_UTIL:SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end

    local ok, resultA, resultB, resultC, resultD = pcall(fn, ...)
    if ok ~= true then
        return nil
    end

    return resultA, resultB, resultC, resultD
end

function LTM_SHARED_UTIL:SafeCallMethod(obj, methodName, ...)
    if type(obj) ~= "table" or type(methodName) ~= "string" then
        return nil
    end

    local method = obj[methodName]
    if type(method) ~= "function" then
        return nil
    end

    return self:SafeCall(method, obj, ...)
end

function LTM_SHARED_UTIL:GetFrameTimeMillisecondsSafe()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end

    return 0
end

function LTM_SHARED_UTIL:GetTimestamp()
    return type(GetTimeStamp) == "function" and GetTimeStamp() or 0
end

function LTM_SHARED_UTIL:NormalizeDisplayName(name)
    if type(name) ~= "string" then
        return nil
    end

    if type(zo_strtrim) == "function" then
        name = zo_strtrim(name)
    else
        name = name:gsub("^%s+", ""):gsub("%s+$", "")
    end

    return name ~= "" and name or nil
end
