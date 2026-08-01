-- Battleboard_Matches.lua  (match repository and saved match lifecycle)
-- Part of Battleboard. Loaded before Capture and Init.

local BL = Battleboard
local _x = BL.__constants

local ALL_CHARACTERS_KEY = _x.ALL_CHARACTERS_KEY
local Num = _x.Num
local MakeSignature = _x.MakeSignature

local function RoundTimestampToNearestFiveMinutes(timestamp)
    timestamp = Num(timestamp)
    if timestamp <= 0 then return 0 end
    return math.floor((timestamp / 300) + 0.5) * 300
end

local function BuildMatchFingerprint(match)
    local bg = match and match.battleground or {}
    local roundedTime = RoundTimestampToNearestFiveMinutes(match and match.capturedAt)
    local bgId = Num((match and match.battlegroundId) or bg.id)
    local numTeams = Num(bg.numTeams or (match and match.battlegroundNumTeams))
    local teamSize = Num(bg.teamSize or (match and match.battlegroundTeamSize))

    local teams = {}
    for _, team in ipairs(match and match.teamSummaries or {}) do
        if type(team) == "table" then
            teams[#teams + 1] = {
                alliance = Num(team.alliance),
                score = Num(team.score),
                kills = Num(team.kills),
                deaths = Num(team.deaths),
            }
        end
    end
    table.sort(teams, function(a, b) return a.alliance < b.alliance end)

    local scoreParts = {}
    local kdParts = {}
    for _, team in ipairs(teams) do
        scoreParts[#scoreParts + 1] = string.format("%d:%d", team.alliance, team.score)
        kdParts[#kdParts + 1] = string.format("%d:%d:%d", team.alliance, team.kills, team.deaths)
    end

    return table.concat({
        "v1",
        tostring(roundedTime),
        tostring(bgId),
        tostring(numTeams),
        tostring(teamSize),
        table.concat(scoreParts, ","),
        table.concat(kdParts, ","),
    }, "|")
end

local function HashMatchFingerprint(fingerprint)
    local h1 = 0
    local h2 = 0
    fingerprint = tostring(fingerprint or "")
    for i = 1, #fingerprint do
        local byte = string.byte(fingerprint, i) or 0
        h1 = (h1 * 131 + byte) % 10000
        h2 = (h2 * 257 + byte * (i + 17)) % 10000
    end
    return string.format("%04d-%04d", h1, h2)
end

local function BuildMatchId(match)
    return HashMatchFingerprint(BuildMatchFingerprint(match))
end

function BL.RebuildMatchIndex()
    -- Bug #2 fix: O(n) GetMatch was called in every hot path (SelectMatch,
    -- RefreshDetails, SortDetails). Build a lookup table keyed by match.id so all of
    -- those callers resolve in O(1) instead of scanning up to 1000 entries.
    BL.matchById = {}
    for _, match in ipairs(BL.matches or {}) do
        if match and match.id then
            if match.isFavorite == true then
                match.isLocked = true
                match.isFavorite = nil
            end
            BL.matchById[match.id] = match
        end
    end
end

function BL.GetMatch(matchId)
    if BL.matchById then
        return BL.matchById[matchId]
    end
    -- Fallback if index not yet built (e.g. called before Initialize completes).
    for _, match in ipairs(BL.matches) do
        if match.id == matchId then return match end
    end
    return nil
end

function BL.SaveCurrentScoreboard(reason, options)
    -- Save is intentionally storage-only.
    -- It captures the currently visible battleground scoreboard, writes the match
    -- into SavedVariables, assigns its deterministic match key, and prints
    -- to chat. It must not open Battleboard or navigate to Match History.
    if not BL.vars then
        d("|cFFD700Battleboard|r could not save: SavedVariables are not ready.")
        return nil, "noVars"
    end

    if type(BL.vars.matches) ~= "table" then BL.vars.matches = {} end
    BL.matches = BL.vars.matches

    options = options or {}

    local match = BL.CaptureCurrentScoreboard()
    if not match or not match.players or #match.players == 0 then
        if not options.silentNoData then
            d("|cFFD700Battleboard|r could not save: no active battleground scoreboard entries found.")
        end
        return nil, "noData"
    end

    -- Prevent repeated clicks/slash commands from saving the same visible scoreboard
    -- multiple times during the same post-match scoreboard session.
    local sig = MakeSignature(match)
    if sig == BL.lastCapturedSignature then
        return nil, "duplicate"
    end
    BL.lastCapturedSignature = sig

    match.id = BuildMatchId(match)
    if BL.GetMatch(match.id) then
        return nil, "duplicate"
    end

    -- Runtime render/cache data must never be persisted into SavedVariables.
    match._battleboardDetailCache = nil

    table.insert(BL.matches, match)
    BL.RebuildMatchIndex() -- Bug #2 fix: keep O(1) lookup index current after insert

    -- Keep internal state coherent for the next time Battleboard is opened, but do not
    -- build/show/refresh the Match History UI as part of saving.
    BL.selectedMatchId = match.id
    BL.selectedPlayerRowKey = nil
    BL.currentSort = nil
    BL.historyNeedsRebuild = true
    BL.detailCache = BL.detailCache or {}

    if not BL.selectedCharacterKey or BL.selectedCharacterKey == "" then
        BL.selectedCharacterKey = ALL_CHARACTERS_KEY
    end

    d("|cFFD700Battleboard|r saved match.")
    BL.ClearQueueCache()

    -- Bug #4 fix: enforce the max-matches cap immediately after each save, not only
    -- at the next login (OnPlayerActivated). Without this, a player who saves many
    -- matches in one session exceeds the cap until they rezone or relog.
    BL.PruneSavedMatchesToLimit()

    return match, "saved"
end

function BL.GetLastSavedMatch()
    if #(BL.matches or {}) == 0 then return nil end

    local latest = nil
    for _, match in ipairs(BL.matches or {}) do
        local capturedAt = Num(match and match.capturedAt)
        local latestCapturedAt = Num(latest and latest.capturedAt)
        if match and (not latest or capturedAt > latestCapturedAt) then
            latest = match
        end
    end
    return latest
end

function BL.DeleteAllEntries()
    local keptMatches = {}
    for _, match in ipairs(BL.matches or {}) do
        if match and match.isLocked == true then
            keptMatches[#keptMatches + 1] = match
        end
    end

    BL.matches = keptMatches
    if BL.vars then
        BL.vars.matches = BL.matches
        BL.vars.deserterEvents = {}
        if #keptMatches > 0 and BL.RefreshAccountCharacters then
            BL.RefreshAccountCharacters()
        else
            BL.vars.characters = {}
        end
    end

    BL.RebuildMatchIndex()

    local selectedMatch = BL.selectedMatchId and BL.GetMatch(BL.selectedMatchId) or nil
    if not selectedMatch then
        local latest = BL.GetLastSavedMatch()
        BL.selectedMatchId = latest and latest.id or nil
    end
    BL.selectedPlayerRowKey = nil
    BL.selectedCharacterKey = ALL_CHARACTERS_KEY
    BL.lastCapturedSignature = nil
    BL.currentSort = nil
    BL.historyNeedsRebuild = true
    BL.detailCache = {}
    BL.rowDataCache = {}
    BL.deserterTimerCacheSeconds = 0
    if BL.PrimeDeserterCooldownTracking then
        BL.PrimeDeserterCooldownTracking()
    end

    BL.RefreshHistory(true)
    BL.RefreshDetails(BL.selectedMatchId and BL.GetMatch(BL.selectedMatchId) or nil)
    BL.RefreshDataPage()
    if BL.RefreshObservatoryPage then
        BL.RefreshObservatoryPage()
    end
    BL.RefreshFooterMatchesSaved()

    d("|cFFD700Battleboard|r cleared all match data")
end

function BL.ConfirmDeleteAllEntries()
    ZO_Dialogs_ShowDialog("BATTLEBOARD_CONFIRM_DELETE_ALL")
end

function BL.GetMaxMatchesSaved()
    local value = Num(BL.vars and BL.vars.maxMatchesSaved)
    if value < 1000 then value = 1000 end
    if value > 10000 then value = 10000 end
    value = math.floor((value + 500) / 1000) * 1000
    if value < 1000 then value = 1000 end
    if value > 10000 then value = 10000 end
    return value
end

function BL.PruneSavedMatchesToLimit()
    if not BL.vars then return end
    if type(BL.vars.matches) ~= "table" then BL.vars.matches = type(BL.matches) == "table" and BL.matches or {} end
    BL.matches = BL.vars.matches

    local maxSaved = BL.GetMaxMatchesSaved()
    if #(BL.matches or {}) <= maxSaved then return end

    -- Sort oldest-first so we remove from the front. Locked matches are
    -- always kept; they are sorted to the back so they are the last to be touched.
    table.sort(BL.matches, function(a, b)
        local af = a and a.isLocked and 1 or 0
        local bf = b and b.isLocked and 1 or 0
        if af ~= bf then return af < bf end  -- locked matches sort to back (kept)
        local at = Num(a and a.capturedAt)
        local bt = Num(b and b.capturedAt)
        if at == bt then
            return tostring(a and a.id or "") < tostring(b and b.id or "")
        end
        return at < bt
    end)

    local removedSelected = false
    while #BL.matches > maxSaved do
        -- Never remove a locked match.
        if BL.matches[1] and BL.matches[1].isLocked then break end
        local removed = table.remove(BL.matches, 1)
        if removed and removed.id == BL.selectedMatchId then
            removedSelected = true
        end
    end

    BL.vars.matches = BL.matches
    BL.historyNeedsRebuild = true
    BL.RebuildMatchIndex() -- Bug #2 fix: rebuild O(1) index after pruning old matches
    if removedSelected then
        BL.selectedMatchId = nil
        BL.selectedPlayerRowKey = nil
    end

    d("|cFFD700Battleboard|r pruned excess matches.")
end
