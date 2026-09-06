local BA = BMGAdventures
BA.ProgressionEngine = BA.ProgressionEngine or {}

function BA.ProgressionEngine:Initialize() end

function BA.ProgressionEngine:GetAdventurerLevel(xp)
    local level, needed = 1, 0
    while level < 100 do
        needed = needed + (500 + level * 90)
        if xp < needed then break end
        level = level + 1
    end
    return level
end

function BA.ProgressionEngine:GetDisciplineLevel(xp)
    local level, needed = 1, 0
    while level < 50 do
        needed = needed + (200 + level * 75)
        if xp < needed then break end
        level = level + 1
    end
    return level
end

function BA.ProgressionEngine:RecalculateLevels()
    BA.account.adventurerLevel = self:GetAdventurerLevel(BA.account.adventurerXP or 0)
    for id, state in pairs(BA.account.disciplines) do
        state.level = self:GetDisciplineLevel(state.xp or 0)
    end
end
