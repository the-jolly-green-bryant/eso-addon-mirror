local BA = BMGAdventures
BA.Journal = BA.Journal or {}

function BA.Journal:Initialize()
    self.lastSummary = ""
end

function BA.Journal:GetSummary()
    local p = BA.account
    local lines = {
        "|cFFD700BMG ADVENTURES|r",
        string.format("Adventurer %d  |  XP %d", p.adventurerLevel or 1, p.adventurerXP or 0),
        string.format("Adventure Score %d  |  Completed %d/%d", p.scores.adventure or 0, BA.Profile:GetCompletedChallengeCount(), #BA.Challenges),
        "",
    }
    for _, id in ipairs(BA.Constants.DISCIPLINES) do
        local s = p.disciplines[id]
        lines[#lines+1] = string.format("%s: Level %d  XP %d  Score %d", BA.Disciplines[id].name, s.level or 1, s.xp or 0, p.scores[id] or 0)
    end
    lines[#lines+1] = ""
    lines[#lines+1] = string.format("Collections: %d/%d  |  Unlocks: %d", BA.CollectionEngine and BA.CollectionEngine:GetCompletedCount() or 0, (function() local n=0; for _ in pairs(BA.Collections or {}) do n=n+1 end; return n end)(), BA.Profile:GetUnlockCount())
    lines[#lines+1] = string.format("Profile Revision: %d", p.profileRevision or 0)
    if BA.LegacyImport and p.legacyImport and p.legacyImport.completed then
        lines[#lines+1] = BA.LegacyImport:GetSummary()
    end
    return table.concat(lines, "\n")
end

function BA.Journal:GetChallengeSummary(category, limit, offset)
    limit = limit or 25
    offset = math.max(0, tonumber(offset) or 0)
    local rows = {}
    local skipped = 0
    for _, def in ipairs(BA.Challenges) do
        if (not category or def.category == category) and not def.secret then
            if skipped < offset then
                skipped = skipped + 1
            else
                local state = BA.account.challenges[def.id] or {v=0,c=false}
                rows[#rows+1] = string.format("%s %s [%d/%d]", state.c and "|c66FF66✓|r" or "|cAAAAAA•|r", def.name, state.v or 0, def.goal)
                if #rows >= limit then break end
            end
        end
    end
    return table.concat(rows, "\n")
end

function BA.Journal:GetVisibleChallengeCount(category)
    local count = 0
    for _, def in ipairs(BA.Challenges) do
        if (not category or def.category == category) and not def.secret then
            count = count + 1
        end
    end
    return count
end
