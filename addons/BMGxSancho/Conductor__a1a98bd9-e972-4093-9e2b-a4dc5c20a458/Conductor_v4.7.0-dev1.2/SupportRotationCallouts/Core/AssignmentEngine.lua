local C = Conductor
C.AssignmentEngine = C.AssignmentEngine or {}
local Engine = C.AssignmentEngine

function Engine:CanPlayerProvide(player, responsibility)
    if not player or not responsibility then return false end
    local key = responsibility.effectKey or responsibility.key
    if not key or key == "" then return false end
    if player.capabilities and player.capabilities[key] then return true end
    if player.responsibilities and player.responsibilities[key] then return true end
    return false
end

function Engine:FindProviders(responsibility, players)
    local matches = {}
    for _, player in ipairs(players or {}) do
        if self:CanPlayerProvide(player, responsibility) then matches[#matches + 1] = player end
    end
    return matches
end

function Engine:Validate(setup, players)
    local result = { ready = true, fulfilled = {}, missing = {}, recommended = {} }
    if not setup then return result end
    local buckets = { setup.ultimates, setup.buffs, setup.debuffs, setup.gear, setup.classMasteries, setup.championPoints }
    for _, bucket in ipairs(buckets) do
        for _, responsibility in ipairs(bucket or {}) do
            local assigned = C.Database and C.Database:GetPlayer(responsibility.assignedAccount)
            local providers = self:FindProviders(responsibility, players or {})
            local fulfilled = assigned and self:CanPlayerProvide(assigned, responsibility) or #providers > 0
            if fulfilled then
                result.fulfilled[#result.fulfilled + 1] = responsibility
            elseif responsibility.requirement == "RECOMMENDED" then
                result.recommended[#result.recommended + 1] = responsibility
            else
                result.ready = false
                result.missing[#result.missing + 1] = responsibility
            end
        end
    end
    return result
end

function Engine:Initialize()
    self.initialized = true
end
