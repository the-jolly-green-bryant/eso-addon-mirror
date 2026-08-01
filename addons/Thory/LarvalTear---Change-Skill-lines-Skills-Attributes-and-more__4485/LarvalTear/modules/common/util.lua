local Addon = LarvalTearMod
local LTM_SHARED_UTIL = Addon.Common.Util

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
