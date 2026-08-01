-- Beltalowda Ability Cache
-- Caches ability info (icon, name, cost) for any ability ID seen
-- Uses ESO API calls to dynamically fetch information

Beltalowda = Beltalowda or {}
Beltalowda.Data = Beltalowda.Data or {}
Beltalowda.Data.AbilityCache = Beltalowda.Data.AbilityCache or {}

local AC = Beltalowda.Data.AbilityCache

-- Cache storage: abilityId -> {icon, name, cost}
AC.cache = {}

--[[
    Get ability info (icon, name, cost) for an ability ID
    Caches on first call, returns cached data on subsequent calls
    @param abilityId number - The ability ID to look up
    @return table - {icon = string, name = string, cost = number} or nil if invalid
]]--
function AC.GetAbilityInfo(abilityId)
    if not abilityId or abilityId <= 0 then
        return nil
    end
    
    -- Check cache first
    if AC.cache[abilityId] then
        return AC.cache[abilityId]
    end
    
    -- Fetch from ESO API
    local icon = GetAbilityIcon(abilityId)
    local name = GetAbilityName(abilityId)
    local cost = GetAbilityCost(abilityId)
    
    -- Validate that we got real data
    -- GetAbilityName returns empty string for invalid IDs
    if not name or name == "" then
        return nil
    end
    
    -- Cache the result
    local info = {
        icon = icon or "/esoui/art/icons/ability_default.dds",
        name = name,
        cost = cost or 0,
    }
    
    AC.cache[abilityId] = info
    
    return info
end

--[[
    Get just the icon path for an ability ID
    @param abilityId number - The ability ID
    @return string - Icon texture path or default icon
]]--
function AC.GetAbilityIcon(abilityId)
    local info = AC.GetAbilityInfo(abilityId)
    return info and info.icon or "/esoui/art/icons/ability_default.dds"
end

--[[
    Get just the name for an ability ID
    @param abilityId number - The ability ID
    @return string - Ability name or "Unknown"
]]--
function AC.GetAbilityName(abilityId)
    local info = AC.GetAbilityInfo(abilityId)
    return info and info.name or "Unknown"
end

--[[
    Get just the cost for an ability ID
    @param abilityId number - The ability ID
    @return number - Ability cost or 0
]]--
function AC.GetAbilityCost(abilityId)
    local info = AC.GetAbilityInfo(abilityId)
    return info and info.cost or 0
end

--[[
    Clear the cache (useful for testing or if API data changes)
]]--
function AC.ClearCache()
    AC.cache = {}
end

--[[
    Get all cached ability IDs
    @return table - Array of ability IDs that have been cached
]]--
function AC.GetCachedAbilityIds()
    local ids = {}
    for id in pairs(AC.cache) do
        table.insert(ids, id)
    end
    table.sort(ids)
    return ids
end
