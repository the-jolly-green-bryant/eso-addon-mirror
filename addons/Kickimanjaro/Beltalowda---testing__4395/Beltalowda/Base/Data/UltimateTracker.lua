-- Beltalowda Ultimate Tracker
-- Tracks all ultimates seen in the group (from broadcasts and local player)
-- Maintains a dynamic list of known ultimates for dropdown menus

Beltalowda = Beltalowda or {}
Beltalowda.Data = Beltalowda.Data or {}
Beltalowda.Data.UltimateTracker = Beltalowda.Data.UltimateTracker or {}

local UT = Beltalowda.Data.UltimateTracker
local AC = Beltalowda.Data.AbilityCache

-- Set of all seen ultimate IDs (exact IDs, no morph grouping)
UT.seenUltimates = {}

--[[
    Register an ultimate as seen (from broadcast or local detection)
    @param abilityId number - The ultimate ability ID
]]--
function UT.RegisterUltimate(abilityId)
    if not abilityId or abilityId <= 0 then
        return
    end
    
    -- Exact ID matching - no morph grouping
    UT.seenUltimates[abilityId] = true
    
    -- Pre-cache the ability info so it's ready for dropdown
    AC.GetAbilityInfo(abilityId)
end

--[[
    Get all seen ultimate IDs, sorted by name
    @return table - Array of {id, name, icon, cost} sorted by name
]]--
function UT.GetSeenUltimates()
    local ultimates = {}
    
    for abilityId in pairs(UT.seenUltimates) do
        local info = AC.GetAbilityInfo(abilityId)
        if info then
            table.insert(ultimates, {
                id = abilityId,
                name = info.name,
                icon = info.icon,
                cost = info.cost,
            })
        end
    end
    
    -- Sort by name for better UX in dropdowns
    table.sort(ultimates, function(a, b)
        return a.name < b.name
    end)
    
    return ultimates
end

--[[
    Get count of unique ultimates seen
    @return number - Count of unique ultimate IDs
]]--
function UT.GetSeenUltimateCount()
    local count = 0
    for _ in pairs(UT.seenUltimates) do
        count = count + 1
    end
    return count
end

--[[
    Check if an ultimate has been seen
    @param abilityId number - The ultimate ability ID
    @return boolean - True if this ultimate has been seen
]]--
function UT.IsUltimateSeen(abilityId)
    return UT.seenUltimates[abilityId] == true
end

--[[
    Clear all seen ultimates (useful for testing)
]]--
function UT.ClearSeenUltimates()
    UT.seenUltimates = {}
end
