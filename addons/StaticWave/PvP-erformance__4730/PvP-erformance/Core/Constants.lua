local PvPerformance = PvPerformance
local Dueling = PvPerformance.Modules.Dueling
local Private = PvPerformance.Private
setfenv(1, setmetatable({
    PvPerformance = PvPerformance,
    Dueling = Dueling,
    Private = Private,
}, {
    __index = function(_, key)
        local value = Private[key]
        if value ~= nil then
            return value
        end
        return _G[key]
    end,
}))
-- PvP-erformance
-- The game owns persistence: PvPerformanceSavedVars is written to SavedVariables
-- when the client exits or reloads the UI.

-- This must match the installed folder/manifest name so EVENT_ADD_ON_LOADED fires.
local ADDON_NAME = PvPerformance.ADDON_NAME
local DISPLAY_NAME = PvPerformance.DISPLAY_NAME
local SAVED_VARIABLES_VERSION = 1
local MAX_HISTORY = 1000
-- Seasons are release-controlled. Advancing this value in a future release
-- archives the prior active season and starts everyone on the same new one.
local CURRENT_SEASON_ID = "2026-S1"
local CURRENT_SEASON_NAME = "Season 1"
local PRESEASON_ID = "preseason"
local PRESEASON_NAME = "Preseason"
-- Development-only access. This command is intentionally absent from the UI,
-- help output, and README so public users cannot casually reset a rating.
local CREATOR_DISPLAY_NAMES = {
    ["@staminasorcerer"] = true,
    ["@staticwave"] = true,
}
local DEFAULT_WINDOW_WIDTH = 1020
local DEFAULT_WINDOW_HEIGHT = 860
-- The Commands tab adds a sixth tab while preserving room for the search box.
local MIN_WINDOW_WIDTH = 1120
local MIN_WINDOW_HEIGHT = 840
local TIER_CARD_SIZE = 120
local TIER_LABEL_SCALE = 1.8
local TIER_PROGRESS_WIDTH = 104
local TIER_PROGRESS_FILL_WIDTH = 100
local TIER_PROGRESS_HEIGHT = 16
local TIER_PROGRESS_FILL_HEIGHT = 12
local SUMMARY_RAIL_LEFT = 26
local SUMMARY_RAIL_TOP = 111
local SUMMARY_RAIL_GAP = 51
local SUMMARY_RAIL_STEP = TIER_CARD_SIZE + SUMMARY_RAIL_GAP
local SUMMARY_RAIL_SELECTOR_TO_SUMMARY_GAP = 12
local SUMMARY_RAIL_DIVIDER_X = 172
local SUMMARY_RAIL_DIVIDER_TOP = 72
local MAIN_CONTENT_LEFT = 192
local TAB_TOP = 78
local ROW_TOP = 111
local JOURNAL_ROW_HEIGHT = 76
local DETAIL_PERFORMANCE_HEIGHT = 198
local GRAPH_MAX_POINTS = 32
local GRAPH_ROLLING_WINDOW = 10

-- Rating is replayed from the saved duel journal. This keeps existing records
-- compatible and makes a clear journal a full rank reset.
local STARTING_RATING = 50 -- Hidden during the Provisional Phase.
local PLACEMENT_OPPONENTS_REQUIRED = 15
local PLACEMENT_DECISIVE_DUELS_REQUIRED = 20
local PLACEMENT_MAX_RESULTS_PER_OPPONENT = 2
local PLACEMENT_SEED_BASE = 50
local PLACEMENT_SEED_POINTS_PER_RESULT = 2
local PLACEMENT_SEED_MIN = 40
local PLACEMENT_SEED_MAX = 84 -- A- is the highest initial placement seed.
local CALIBRATION_DECISIVE_DUELS_REQUIRED = 20
local WIN_POINTS = 0.5
local LOSS_POINTS = 0.5
-- Version bumps safely replay existing records whenever rating rules or the
-- transparent per-duel modifier audit changes.
local RATING_RULES_VERSION = 14
local CLASS_RATING_RULES_VERSION = 13
-- A 1.0 K-factor produces the requested +0.5 / -0.5 mirror result while
-- preserving expected-matchup scoring for Class Tier.
local CLASS_RATING_K = 1.0
local WIN_STREAK_POINT_MULTIPLIERS = { 1, 0.75, 0.50, 0.25, 0 }
local EXHAUSTED_MATCHUP_WIN_COUNT = #WIN_STREAK_POINT_MULTIPLIERS
local EXHAUSTED_MATCHUP_RECOVERY_DECISIVE_DUELS = 10
local EXHAUSTED_MATCHUP_RECOVERY_UNIQUE_OPPONENTS = 5
local LOSS_STREAK_PENALTY_PER_WIN = 0.05
local MAX_LOSS_STREAK_PENALTY = 0.10
local DAMAGE_MODIFIER_MIN_DURATION_SECONDS = 20
local DAMAGE_MODIFIER_MIN_TOTAL = 150000
local DAMAGE_BURST_WINDOW_MS = 3000
local DAMAGE_MODIFIER_MAX_BURST_SHARE = 0.40
local DAMAGE_RATIO_MULTIPLIERS = {
    { minimum = 4.00, multiplier = 1.15 },
    { minimum = 3.00, multiplier = 1.10 },
    { minimum = 2.00, multiplier = 1.05 },
}
-- The ESO API exposes player stun state but not a verified Break Free result.
-- Therefore this is deliberately a conservative *suspected* lock detector,
-- not a claim that an input was received and ignored.
local CC_LOCK_MIN_STAMINA = 5000
local CC_LOCK_MIN_STUN_DURATION_MS = 1000
local CC_LOCK_IMMEDIATE_FINISH_WINDOW_MS = 500
local CC_LOCK_LIKELY_FINISH_WINDOW_MS = 2000
local CC_LOCK_RECOVERY_FINISH_WINDOW_MS = 5000
local CC_LOCK_POSSIBLE_LOSS_MULTIPLIER = 0.90
local CC_LOCK_LIKELY_LOSS_MULTIPLIER = 0.80
local CC_LOCK_STRONG_LOSS_MULTIPLIER = 0.75
-- GetLatency exposes a momentary client/server latency reading, not packet
-- loss or proof that a spike decided the duel. Keep this diagnostic-only.
local LATENCY_SAMPLE_INTERVAL_MS = 250
local LATENCY_MIN_BASELINE_SAMPLES = 4
local LATENCY_BASELINE_WINDOW_SAMPLES = 12
local LATENCY_MODERATE_MIN_DELTA_MS = 150
local LATENCY_MODERATE_MULTIPLIER = 1.5
local LATENCY_SEVERE_MIN_DELTA_MS = 300
local LATENCY_SEVERE_MULTIPLIER = 2.0
local LATENCY_MIN_SPIKE_DURATION_MS = 1000
local LATENCY_FINISH_WINDOW_MS = 2000
local LATENCY_UPDATE_NAME = ADDON_NAME .. "LatencySampling"

-- Aggregate tabs use a compact version of the reference addon's per-tab
-- sorting: Recent and detail histories remain chronological, while grouped
-- Opponent/Class rows can be ranked independently by a useful statistic.
local AGGREGATE_SORT_OPTIONS = {
    { key = "total", label = "Duels" },
    { key = "winRate", label = "Win Rate" },
    { key = "wins", label = "Wins" },
    { key = "losses", label = "Losses" },
    { key = "name", label = "Name" },
}

-- ESO class IDs are stable enum values. Keeping them here makes the matchup
-- table explicit and avoids depending on localized class names.
local CLASS_DRAGONKNIGHT = 1
local CLASS_SORCERER = 2
local CLASS_NIGHTBLADE = 3
local CLASS_WARDEN = 4
local CLASS_NECROMANCER = 5
local CLASS_TEMPLAR = 6
local CLASS_ARCANIST = 7

-- Werewolf is a form, not an ESO class ID. It therefore has a private,
-- persistent key for Class Tier history whenever the form is confirmed.
local CLASS_WEREWOLF = 99

-- Class Tier is intentionally separate for every class. This order is used
-- by the Class Tier selector in the journal; it includes Werewolf because a
-- confirmed form has its own rating history.
local CLASS_TIER_OPTIONS = {
    CLASS_DRAGONKNIGHT,
    CLASS_SORCERER,
    CLASS_NIGHTBLADE,
    CLASS_WARDEN,
    CLASS_NECROMANCER,
    CLASS_TEMPLAR,
    CLASS_ARCANIST,
    CLASS_WEREWOLF,
}

local TEST_CLASS_ALIASES = {
    dk = CLASS_DRAGONKNIGHT,
    dragonknight = CLASS_DRAGONKNIGHT,
    sorc = CLASS_SORCERER,
    sorcerer = CLASS_SORCERER,
    nb = CLASS_NIGHTBLADE,
    nightblade = CLASS_NIGHTBLADE,
    warden = CLASS_WARDEN,
    necro = CLASS_NECROMANCER,
    necromancer = CLASS_NECROMANCER,
    templar = CLASS_TEMPLAR,
    arc = CLASS_ARCANIST,
    arcanist = CLASS_ARCANIST,
    ww = CLASS_WEREWOLF,
    werewolf = CLASS_WEREWOLF,
}

-- Lower numbers are stronger in the current class ladder. Necromancer and
-- Templar intentionally share a rank, so their matchup is treated as even.
-- Werewolf is a confirmed combat form and intentionally ranks above DK.
local CLASS_POWER_RANK = {
    [CLASS_WEREWOLF] = -1,
    [CLASS_DRAGONKNIGHT] = 0,
    [CLASS_SORCERER] = 1,
    [CLASS_WARDEN] = 2,
    [CLASS_NECROMANCER] = 3,
    [CLASS_TEMPLAR] = 3,
    [CLASS_NIGHTBLADE] = 4,
    [CLASS_ARCANIST] = 5,
}

-- Signature effects that can only originate from the Werewolf skill line.
-- The transformation and form effects make pre-transformed opponents
-- detectable through their visible reticle buffs; the active skills catch
-- opponents after the duel begins. Extra IDs may be added without changing
-- rating history through /metrics ww add <abilityId>.
local WEREWOLF_SIGNATURE_ABILITY_IDS = {
    [32455] = true, -- Werewolf Transformation
    [42356] = true,
    [42357] = true,
    [42358] = true,
    [39033] = true, -- Werewolf Transform Setup
    [39076] = true, -- Werewolf Berserker
    [47083] = true, -- Werewolf Berserker morph effect
    [32632] = true, -- Pounce
    [42108] = true,
    [42109] = true,
    [42110] = true,
    [58310] = true, -- Hircine's Bounty
    [58314] = true,
    [58315] = true,
    [58316] = true,
    [58325] = true, -- Hircine's Fortitude
    [58329] = true,
    [58332] = true,
    [58334] = true,
    [89147] = true, -- Werewolf Berserker Bleed
    [58880] = true, -- Bloodclaws
    [137164] = true, -- Feral Carnage
    [137184] = true, -- Brutal Carnage
}

-- One intentional global namespace is required for the keybinding. Keep a
-- local alias for fast, unambiguous access everywhere else in this file.

-- Appears under Controls > Keybindings > Addons. No default key is imposed;
-- each player chooses a binding that does not conflict with their combat UI.
ZO_CreateStringId("SI_BINDING_NAME_DUELLEDGER_TOGGLE_UI", "Toggle PvP-erformance")

local DEFAULTS = {
    seasonSchemaVersion = 0,
    activeSeasonId = nil,
    seasons = {},
    werewolfAbilityIds = {},
    opponentNotes = {},
    settings = {
        uiScale = 1.00,
        effectIntensity = 1.00,
        damageRatingEnabled = true,
        duelTrackingEnabled = true,
    },
    window = {
        left = nil,
        top = nil,
        width = nil,
        height = nil,
    },
}

local function Print(message)
    CHAT_SYSTEM:AddMessage(string.format("|c70C0FF%s:|r %s", DISPLAY_NAME, message))
end

local UI_SCALE_OPTIONS = { 0.90, 1.00, 1.10 }
local EFFECT_INTENSITY_OPTIONS = {
    { value = 0.65, label = "LOW" },
    { value = 1.00, label = "NORMAL" },
    { value = 1.35, label = "HIGH" },
}

function Dueling:GetSettings()
    self.savedVars.settings = self.savedVars.settings or {}
    local settings = self.savedVars.settings
    settings.uiScale = tonumber(settings.uiScale) or 1.00
    settings.effectIntensity = tonumber(settings.effectIntensity) or 1.00
    if settings.damageRatingEnabled == nil then
        settings.damageRatingEnabled = true
    end
    if settings.duelTrackingEnabled == nil then
        settings.duelTrackingEnabled = true
    end
    return settings
end

function Dueling:GetOpponentNote(displayName)
    local notes = self.savedVars.opponentNotes or {}
    local entry = notes[zo_strlower(displayName or "")]
    if type(entry) == "table" then
        return entry.text
    end
    return type(entry) == "string" and entry or nil
end

function Dueling:GetSeasonById(seasonId)
    return self.savedVars
        and self.savedVars.seasons
        and self.savedVars.seasons[seasonId]
        or nil
end

function Dueling:GetActiveSeason()
    -- Season rollover is not part of the public release. Keep all live
    -- records in the root journal so a clear-command change cannot strand
    -- records outside the active journal.
    return self.savedVars
end

function Dueling:GetViewedSeason()
    return self:GetActiveSeason()
end

function Dueling:IsViewingActiveSeason()
    return true
end

function Dueling:GetSortedSeasons()
    local seasons = {}
    for _, season in pairs(self.savedVars.seasons or {}) do
        table.insert(seasons, season)
    end
    table.sort(seasons, function(left, right)
        if left.id == CURRENT_SEASON_ID then
            return true
        elseif right.id == CURRENT_SEASON_ID then
            return false
        end
        return (tonumber(left.startedAt) or 0) > (tonumber(right.startedAt) or 0)
    end)
    return seasons
end

local function SignedRatingChange(duel, change)
    change = tonumber(change) or 0
    if duel.drawn then
        return 0
    end
    return duel.won and change or -change
end

local function NameForClass(classId, gender)
    if classId == CLASS_WEREWOLF then
        return "Werewolf"
    end

    if not classId or classId == 0 then
        return "Unknown class"
    end

    return GetClassName(gender or GENDER_MALE, classId)
end

local function NameForRace(raceId, gender)
    if not raceId or raceId == 0 then
        return "Unknown race"
    end

    return GetRaceName(gender or GENDER_MALE, raceId)
end

local function FormatDuration(seconds)
    if not seconds then
        return "not available"
    end

    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%d:%02d", minutes, remainingSeconds)
end

local function FormatDamage(value)
    value = math.max(0, math.floor(tonumber(value) or 0))
    if value >= 1000000 then
        return string.format("%.2fm", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fk", value / 1000)
    end

    return tostring(value)
end

local function DamageDoneDifferenceText(damageDone, damageTaken)
    local done = math.max(0, tonumber(damageDone) or 0)
    local taken = math.max(0, tonumber(damageTaken) or 0)
    if done <= 0 then
        return "N/A", nil
    end

    -- The requested baseline is damage dealt, not total combat damage. Use
    -- an absolute difference for the exact display text, while returning the
    -- direction so the label can make a taken-heavy result visually obvious.
    local difference = taken - done
    local percent = math.abs(difference) / done * 100
    return string.format("%.1f%% damage done difference", percent), difference
end

local function ChampionPointCount()
    if type(GetPlayerChampionPointsEarned) == "function" then
        return tonumber(GetPlayerChampionPointsEarned()) or 0
    elseif type(GetNumChampionPoints) == "function" then
        return tonumber(GetNumChampionPoints()) or 0
    end

    return 0
end

-- The combat listener is registered only while a duel is tracked. These
-- result filters keep native event dispatch from invoking Lua for unrelated
-- heals, buffs, casts, and combat results.
local DAMAGE_COMBAT_RESULTS = {
    ACTION_RESULT_DAMAGE,
    ACTION_RESULT_CRITICAL_DAMAGE,
    ACTION_RESULT_DOT_TICK,
    ACTION_RESULT_DOT_TICK_CRITICAL,
    ACTION_RESULT_BLOCKED_DAMAGE,
    ACTION_RESULT_DAMAGE_SHIELDED,
    ACTION_RESULT_CRITICAL_DAMAGE_SHIELDED,
}

-- Healing is kept separate from damage and only while a duel is active. The
-- API does not expose universally reliable shield absorption/effective-heal
-- totals, so the final journal stores API-reported healing and leaves shield
-- absorption unavailable instead of guessing or double-counting it.
local HEAL_COMBAT_RESULTS = {
    ACTION_RESULT_HEAL,
    ACTION_RESULT_CRITICAL_HEAL,
    ACTION_RESULT_HOT_TICK,
    ACTION_RESULT_HOT_TICK_CRITICAL,
}
local COMBAT_SUMMARY_TOP_SOURCES = 15

local function FormatDuelTime(duel)
    -- ESO provides a formatter for a timestamp's date, but not its time of day.
    -- Store the localized time string alongside the timestamp when the duel ends.
    if not duel or not duel.timestamp then
        return duel and duel.timeString or "Unknown time"
    end
    return string.format("%s %s", GetDateStringFromTimestamp(duel.timestamp), duel.timeString or "")
end

local function CleanCharacterName(name)
    if not name or name == "" then
        return "Unknown character"
    end

    -- ESO may append a grammatical-gender suffix such as ^Mx to raw names.
    -- It is useful to the game's localization engine but not to the journal.
    return (name:gsub("%^%a+$", ""))
end

local function NormalizeUnitName(name)
    return zo_strlower(CleanCharacterName(name or ""))
end

local function NamesMatch(left, right)
    local normalizedLeft = NormalizeUnitName(left)
    local normalizedRight = NormalizeUnitName(right)
    return normalizedLeft ~= "" and normalizedRight ~= "" and normalizedLeft == normalizedRight
end

local function PlayerIsWerewolf()
    return IsPlayerInWerewolfForm and IsPlayerInWerewolfForm() or false
end

local function WinRateColor(winRate)
    if winRate <= 50 then
        return 1, 1, 1 -- white
    elseif winRate <= 60 then
        return 0.78, 0.64, 0.46 -- light brown
    elseif winRate <= 70 then
        return 0.55, 0.95, 0.55 -- light green
    elseif winRate <= 80 then
        return 0.48, 0.76, 1 -- light blue
    elseif winRate <= 90 then
        return 1, 0.70, 0.36 -- light orange
    end

    return 1, 0.84, 0.08 -- bright gold (91-100%)
end

local function WinRateHex(winRate)
    if winRate <= 50 then
        return "FFFFFF"
    elseif winRate <= 60 then
        return "C7A375"
    elseif winRate <= 70 then
        return "8CF28C"
    elseif winRate <= 80 then
        return "7ABFFF"
    elseif winRate <= 90 then
        return "FFB35C"
    end

    return "FFD615"
end

local RANK_THRESHOLDS = {
    { minimum = 99, name = "S+", color = { 1.00, 0.91, 0.16 } }, -- bright gold
    { minimum = 96, name = "S",  color = { 1.00, 0.76, 0.12 } }, -- normal gold
    { minimum = 93, name = "S-", color = { 1.00, 0.84, 0.42 } }, -- light gold
    { minimum = 89, name = "A+", color = { 1.00, 0.24, 0.24 } }, -- bright red
    { minimum = 85, name = "A",  color = { 0.92, 0.18, 0.18 } }, -- red
    { minimum = 81, name = "A-", color = { 0.76, 0.20, 0.20 } }, -- deep red
    { minimum = 76, name = "B+", color = { 0.83, 0.46, 1.00 } }, -- bright purple
    { minimum = 71, name = "B",  color = { 0.66, 0.30, 0.92 } }, -- purple
    { minimum = 66, name = "B-", color = { 0.50, 0.21, 0.72 } }, -- deep purple
    { minimum = 61, name = "C+", color = { 0.34, 1.00, 0.42 } }, -- bright green
    { minimum = 56, name = "C",  color = { 0.24, 0.88, 0.34 } }, -- green
    { minimum = 51, name = "C-", color = { 0.34, 0.70, 0.38 } }, -- deep green
    { minimum = 0,  name = "D",  color = { 0.50, 0.32, 0.18 } }, -- brown
}

local function RankForRating(rating)
    for _, rank in ipairs(RANK_THRESHOLDS) do
        if rating >= rank.minimum then
            return rank
        end
    end

    return RANK_THRESHOLDS[#RANK_THRESHOLDS]
end

local function RatingProgressForRank(rating, rank)
    for index, candidate in ipairs(RANK_THRESHOLDS) do
        if candidate == rank then
            local nextRank = RANK_THRESHOLDS[index - 1]
            if not nextRank then
                return 1, "MAX"
            end

            local span = nextRank.minimum - rank.minimum
            local progress = span > 0 and (rating - rank.minimum) / span or 1
            progress = math.max(0, math.min(1, progress))
            local ratingText = rating == math.floor(rating) and string.format("%d", rating)
                or string.format("%.1f", rating)
            return progress, string.format("%s / %d", ratingText, nextRank.minimum)
        end
    end

    return 0, ""
end

local function PointsToNextRank(rating, rank)
    for index, candidate in ipairs(RANK_THRESHOLDS) do
        if candidate == rank then
            local nextRank = RANK_THRESHOLDS[index - 1]
            if not nextRank then
                return nil, nil
            end

            return math.max(0, nextRank.minimum - rating), nextRank.name
        end
    end

    return nil, nil
end

local function OverallTierTooltipText(rankName)
    if rankName == "S" then
        return "You are officially among the top 0.01% of the dueling player base! You've earned this rank, so flex it hard!"
    elseif rankName == "S+" then
        return "Congratulations, you represent the pinnacle of dueling in ESO! Wear this badge with honor, and touch some grass for god's sake!"
    end

    return nil
end

local function ClassTierTooltipText(rankName, className)
    if rankName == "S" then
        return "You're among the top 0.01% of your class. What an achievement!"
    elseif rankName == "S+" then
        return string.format("Congratulations, you are the pinnacle of %s.", className or "your class")
    end

    return nil
end

local function DisplayNameScale(displayName)
    local length = string.len(displayName or "")
    if length > 28 then
        return 0.65
    elseif length > 23 then
        return 0.75
    elseif length > 18 then
        return 0.85
    end

    return 1
end

local function OpponentKey(duel)
    local opponent = duel.opponent or {}
    return zo_strlower(opponent.displayName or opponent.characterName or "Unknown opponent")
end

local function ConsecutiveWinMultiplier(previousWins)
    return WIN_STREAK_POINT_MULTIPLIERS[math.min(previousWins + 1, EXHAUSTED_MATCHUP_WIN_COUNT)]
end

local function LossStreakMultiplier(previousWinStreak)
    return 1 + math.min(MAX_LOSS_STREAK_PENALTY, previousWinStreak * LOSS_STREAK_PENALTY_PER_WIN)
end

local function HighTierWinMultiplier(rating)
    -- S-tier gains slow sharply, but stay recoverable after a legitimate loss.
    if rating >= 99 then
        return 0.35 -- S+
    elseif rating >= 96 then
        return 0.50 -- S
    elseif rating >= 93 then
        return 0.65 -- S-
    end
    return 1
end

local function HighTierLossMultiplier(rating)
    if rating >= 99 then
        return 0.85 -- S+
    elseif rating >= 96 then
        return 0.90 -- S
    elseif rating >= 93 then
        return 0.95 -- S-
    end
    return 1
end

local function DamageMultiplierForRatio(ratio)
    for _, band in ipairs(DAMAGE_RATIO_MULTIPLIERS) do
        if ratio >= band.minimum then
            return band.multiplier
        end
    end
    return 1
end

local function DamageRatingMultiplierForDuel(duel)
    -- The setting applies both to live results and to a replay of history, so
    -- toggling it immediately produces an internally consistent rating.
    if Dueling.savedVars
        and Dueling.savedVars.settings
        and Dueling.savedVars.settings.damageRatingEnabled == false then
        return 1
    end

    local storedMultiplier = tonumber(duel.damageRatingMultiplier)
    if storedMultiplier then
        return storedMultiplier
    end

    -- Historic records predate aggregate damage tracking and therefore retain
    -- their original rating. New records persist only this final multiplier,
    -- never live combat events or hit-by-hit data.
    return 1
end

local function CalculateDamageRatingMultiplier(won, drawn, damageDone, damageTaken, durationSeconds, peakOutgoingBurst)
    damageDone = tonumber(damageDone) or 0
    damageTaken = tonumber(damageTaken) or 0
    local totalDamage = damageDone + damageTaken
    if drawn
        or durationSeconds == nil
        or durationSeconds < DAMAGE_MODIFIER_MIN_DURATION_SECONDS
        or totalDamage < DAMAGE_MODIFIER_MIN_TOTAL
        or damageDone <= 0
        or damageTaken <= 0 then
        return 1
    end

    if won then
        -- Do not reward an intentionally passive duel followed by a single
        -- decisive burst. The three-second burst window is temporary state;
        -- only the final eligible multiplier is saved with the duel.
        local burstShare = (tonumber(peakOutgoingBurst) or 0) / damageDone
        if burstShare <= DAMAGE_MODIFIER_MAX_BURST_SHARE then
            return DamageMultiplierForRatio(damageTaken / damageDone)
        end
    else
        return DamageMultiplierForRatio(damageDone / damageTaken)
    end

    return 1
end

local function ClassExpectedWinChance(playerClassId, opponentClassId)
    -- Mirrors and equal-strength classes are evaluated as even matches.
    if not playerClassId or playerClassId == 0
        or not opponentClassId or opponentClassId == 0
        or playerClassId == opponentClassId then
        return 0.50
    end

    local playerPower = CLASS_POWER_RANK[playerClassId]
    local opponentPower = CLASS_POWER_RANK[opponentClassId]
    if playerPower == nil or opponentPower == nil then
        return 0.50
    end

    if playerPower == opponentPower then
        return 0.50
    end

    -- Solve all weaker-side matchups by mirroring the stronger side. This
    -- guarantees that every matchup is complementary and cannot inflate the
    -- rating pool through asymmetric expectations.
    if playerPower > opponentPower then
        return 1 - ClassExpectedWinChance(opponentClassId, playerClassId)
    end

    local powerGap = opponentPower - playerPower
    if playerClassId == CLASS_WEREWOLF then
        -- WW > DK. WW is 80% expected into Sorc (a 60% relative advantage
        -- over an even matchup), then rises as the opposing class weakens.
        local expectedByGap = {
            [1] = 0.65, -- WW vs DK
            [2] = 0.80, -- WW vs Sorcerer
            [3] = 0.84,
            [4] = 0.88,
            [5] = 0.91,
            [6] = 0.94,
        }
        return expectedByGap[powerGap] or 0.94
    end

    if playerClassId == CLASS_DRAGONKNIGHT then
        -- DK vs Sorc is 72.5% expected: 45% better than the 50% baseline.
        -- The DK advantage increases against each lower ladder position.
        local expectedByGap = {
            [1] = 0.725, -- DK vs Sorcerer
            [2] = 0.78,
            [3] = 0.825,
            [4] = 0.87,
            [5] = 0.915,
        }
        return expectedByGap[powerGap] or 0.915
    end

    -- The remaining classes retain the measured five-point expected-score
    -- step already used by the prior ladder.
    return math.min(0.70, 0.50 + powerGap * 0.05)
end

local function AdvanceExhaustedMatchupRecovery(ranking, opponentKey, duel)
    -- A draw or forfeit never restores a farmed matchup. Each exhausted
    -- opponent tracks its own recovery from decisive duels against *other*
    -- players, preventing a quick global draw loop from restoring all gains.
    if duel.drawn then
        return
    end

    local recovered = {}
    for exhaustedOpponentKey in pairs(ranking.diminishingOpponents or {}) do
        if exhaustedOpponentKey ~= opponentKey then
            local recovery = ranking.exhaustedMatchupRecovery[exhaustedOpponentKey]
            if not recovery then
                recovery = {
                    decisiveDuels = 0,
                    uniqueOpponents = {},
                    uniqueOpponentCount = 0,
                }
                ranking.exhaustedMatchupRecovery[exhaustedOpponentKey] = recovery
            end

            recovery.decisiveDuels = recovery.decisiveDuels + 1
            if not recovery.uniqueOpponents[opponentKey] then
                recovery.uniqueOpponents[opponentKey] = true
                recovery.uniqueOpponentCount = recovery.uniqueOpponentCount + 1
            end

            if recovery.decisiveDuels >= EXHAUSTED_MATCHUP_RECOVERY_DECISIVE_DUELS
                and recovery.uniqueOpponentCount >= EXHAUSTED_MATCHUP_RECOVERY_UNIQUE_OPPONENTS then
                table.insert(recovered, exhaustedOpponentKey)
            end
        end
    end

    for _, exhaustedOpponentKey in ipairs(recovered) do
        ranking.diminishingOpponents[exhaustedOpponentKey] = nil
        ranking.opponentFatigue[exhaustedOpponentKey] = 0
        ranking.exhaustedMatchupRecovery[exhaustedOpponentKey] = nil
    end
end

local function PlacementComplete(ranking)
    return (ranking.placementDecisiveCount or 0) >= PLACEMENT_DECISIVE_DUELS_REQUIRED
        and (ranking.qualifyingCount or 0) >= PLACEMENT_OPPONENTS_REQUIRED
end

local function CalibrationComplete(ranking)
    return PlacementComplete(ranking)
        and (ranking.calibrationDecisiveCount or 0) >= CALIBRATION_DECISIVE_DUELS_REQUIRED
end

local function PlacementSeed(ranking)
    local decisiveDifference = (ranking.placementWins or 0) - (ranking.placementLosses or 0)
    local seed = PLACEMENT_SEED_BASE + PLACEMENT_SEED_POINTS_PER_RESULT * decisiveDifference
    return math.max(PLACEMENT_SEED_MIN, math.min(PLACEMENT_SEED_MAX, seed))
end

local function ProvisionalProgressText(ratingState)
    return string.format(
        "%d/%d opponents, %d/%d decisive results",
        ratingState.qualifyingOpponents or 0,
        PLACEMENT_OPPONENTS_REQUIRED,
        ratingState.placementDecisiveCount or 0,
        PLACEMENT_DECISIVE_DUELS_REQUIRED
    )
end

local function ApplyRatingChange(ranking, duel, winPoints, lossPoints)
    local opponentKey = OpponentKey(duel)
    local previousDuels = ranking.opponentDuels[opponentKey] or 0
    local isPlacementMatch = not PlacementComplete(ranking)
    local placementResultsForOpponent = (ranking.placementOpponentResults or {})[opponentKey] or 0
    local countsForPlacement = isPlacementMatch and not duel.drawn
        and placementResultsForOpponent < PLACEMENT_MAX_RESULTS_PER_OPPONENT
    local isCalibrationMatch = not isPlacementMatch and not duel.drawn
        and (ranking.calibrationDecisiveCount or 0) < CALIBRATION_DECISIVE_DUELS_REQUIRED
    local previousFatigue = ranking.opponentFatigue[opponentKey] or 0
    local winMultiplier = ranking.diminishingOpponents[opponentKey] and 0
        or ConsecutiveWinMultiplier(previousFatigue)
    local highTierWinMultiplier = isPlacementMatch and 1
        or HighTierWinMultiplier(ranking.rating or STARTING_RATING)
    local highTierLossMultiplier = isPlacementMatch and 1
        or HighTierLossMultiplier(ranking.rating or STARTING_RATING)
    local lossMultiplier = isPlacementMatch and 1
        or LossStreakMultiplier(ranking.winStreak or 0)
    local damageMultiplier = isPlacementMatch and 1 or DamageRatingMultiplierForDuel(duel)
    -- Old entries only stored a boolean CC flag. Preserve their previous
    -- 25% reduction while new entries retain their confidence-specific value.
    local ccMultiplier = 1
    if not isPlacementMatch and duel.suspectedCcLock then
        ccMultiplier = tonumber(duel.ccLockLossMultiplier) or CC_LOCK_STRONG_LOSS_MULTIPLIER
    end
    local details = {
        basePoints = duel.won and winPoints or lossPoints,
        repeatMultiplier = winMultiplier,
        streakMultiplier = duel.won and 1 or lossMultiplier,
        damageMultiplier = damageMultiplier,
        ccMultiplier = duel.won and 1 or ccMultiplier,
        tierMultiplier = duel.won and highTierWinMultiplier or highTierLossMultiplier,
        placement = isPlacementMatch,
        countsForPlacement = countsForPlacement,
        calibration = isCalibrationMatch,
    }
    local change = 0

    if countsForPlacement then
        -- Stage 1 is a bounded local seed rather than an inflated version of
        -- the normal score. It needs 20 decisive results from 15 opponents,
        -- with at most two results from any one opponent contributing.
        local previousRating = ranking.rating or STARTING_RATING
        ranking.placementOpponentResults[opponentKey] = placementResultsForOpponent + 1
        ranking.placementDecisiveCount = (ranking.placementDecisiveCount or 0) + 1
        if not ranking.qualifyingOpponents[opponentKey] then
            ranking.qualifyingOpponents[opponentKey] = true
            ranking.qualifyingCount = (ranking.qualifyingCount or 0) + 1
        end
        if duel.won then
            ranking.placementWins = (ranking.placementWins or 0) + 1
        else
            ranking.placementLosses = (ranking.placementLosses or 0) + 1
        end
        ranking.rating = PlacementSeed(ranking)
        change = math.abs(ranking.rating - previousRating)
    elseif not duel.drawn and not isPlacementMatch then
        if duel.won then
            change = winPoints * winMultiplier * highTierWinMultiplier * damageMultiplier
        else
            change = lossPoints * lossMultiplier * highTierLossMultiplier * damageMultiplier
            change = change * ccMultiplier
        end
        if duel.won then
            ranking.rating = math.min(100, ranking.rating + change)
        else
            ranking.rating = math.max(0, ranking.rating - change)
        end
    end

    if duel.won then
        ranking.winStreak = (ranking.winStreak or 0) + 1
        if not ranking.diminishingOpponents[opponentKey] then
            local currentFatigue = previousFatigue + 1
            ranking.opponentFatigue[opponentKey] = currentFatigue
            if currentFatigue >= EXHAUSTED_MATCHUP_WIN_COUNT then
                ranking.diminishingOpponents[opponentKey] = true
                ranking.exhaustedMatchupRecovery[opponentKey] = {
                    decisiveDuels = 0,
                    uniqueOpponents = {},
                    uniqueOpponentCount = 0,
                }
            end
        end
    elseif not duel.drawn then
        -- A real loss decreases matchup fatigue by one instead of returning
        -- the next win to full value. Draws stay entirely neutral.
        if not ranking.diminishingOpponents[opponentKey] then
            ranking.opponentFatigue[opponentKey] = math.max(0, previousFatigue - 1)
        end
        ranking.winStreak = 0
    end

    AdvanceExhaustedMatchupRecovery(ranking, opponentKey, duel)

    local currentDuels = previousDuels + 1
    ranking.opponentDuels[opponentKey] = currentDuels
    if isPlacementMatch and PlacementComplete(ranking) then
        -- Provisional wins never carry a global loss penalty into calibration.
        ranking.winStreak = 0
    end
    if isCalibrationMatch then
        ranking.calibrationDecisiveCount = math.min(
            CALIBRATION_DECISIVE_DUELS_REQUIRED,
            (ranking.calibrationDecisiveCount or 0) + 1
        )
    end

    details.placementDecisiveCount = ranking.placementDecisiveCount or 0
    details.placementOpponentCount = ranking.qualifyingCount or 0
    details.finalChange = change
    return change, isPlacementMatch, winMultiplier, lossMultiplier, isCalibrationMatch, details
end

local function CopyRanking(ranking)
    local copy = {
        rating = ranking.rating,
        opponentDuels = {},
        opponentFatigue = {},
        diminishingOpponents = {},
        exhaustedMatchupRecovery = {},
        winStreak = ranking.winStreak or 0,
        qualifyingOpponents = {},
        qualifyingCount = ranking.qualifyingCount or 0,
        placementOpponentResults = {},
        placementDecisiveCount = ranking.placementDecisiveCount or 0,
        placementWins = ranking.placementWins or 0,
        placementLosses = ranking.placementLosses or 0,
        calibrationDecisiveCount = ranking.calibrationDecisiveCount or 0,
    }
    for opponentKey, count in pairs(ranking.opponentDuels) do
        copy.opponentDuels[opponentKey] = count
    end
    for opponentKey, fatigue in pairs(ranking.opponentFatigue or {}) do
        copy.opponentFatigue[opponentKey] = fatigue
    end
    for opponentKey, exhausted in pairs(ranking.diminishingOpponents or {}) do
        copy.diminishingOpponents[opponentKey] = exhausted
    end
    for exhaustedOpponentKey, recovery in pairs(ranking.exhaustedMatchupRecovery or {}) do
        copy.exhaustedMatchupRecovery[exhaustedOpponentKey] = {
            decisiveDuels = recovery.decisiveDuels or 0,
            uniqueOpponents = {},
            uniqueOpponentCount = recovery.uniqueOpponentCount or 0,
        }
        for opponentKey, counted in pairs(recovery.uniqueOpponents or {}) do
            copy.exhaustedMatchupRecovery[exhaustedOpponentKey].uniqueOpponents[opponentKey] = counted
        end
    end
    for opponentKey, qualified in pairs(ranking.qualifyingOpponents) do
        copy.qualifyingOpponents[opponentKey] = qualified
    end
    for opponentKey, count in pairs(ranking.placementOpponentResults or {}) do
        copy.placementOpponentResults[opponentKey] = count
    end
    return copy
end

local function TestClassIdFromText(classText)
    return TEST_CLASS_ALIASES[zo_strlower(classText or "")]
end

local function MatchesSearch(value, searchText)
    if not searchText or searchText == "" then
        return true
    end

    return string.find(zo_strlower(value or ""), zo_strlower(searchText), 1, true) ~= nil
end

local function AddToStats(stats, duel)
    stats.total = stats.total + 1
    if duel.drawn then
        stats.draws = stats.draws + 1
    elseif duel.won then
        stats.wins = stats.wins + 1
    else
        stats.losses = stats.losses + 1
    end
end

-- Draws are shown in every W-L-D record and still count as completed duels,
-- but they are deliberately neutral for win-rate math. This prevents a
-- forfeit (stored as a draw) from lowering a player's displayed win rate.
local function WinRateRatio(entry)
    local wins = tonumber(entry and entry.wins) or 0
    local losses = tonumber(entry and entry.losses) or 0
    local decisiveDuels = wins + losses
    return decisiveDuels > 0 and wins / decisiveDuels or 0
end

local function WinRatePercent(entry)
    return WinRateRatio(entry) * 100
end

local function ClassDisplayForDuel(participant)
    participant = participant or {}
    if participant.wasWerewolf then
        return string.format("Werewolf (%s)", participant.className or "Unknown class")
    end

    return participant.className or "Unknown class"
end

local function StatsText(entry)
    return string.format(
        "|c42FF63%d|r - |cFF4C4C%d|r - |cA8A8A8%d|r",
        entry.wins,
        entry.losses,
        entry.draws
    )
end

local function StatsWinRateText(entry)
    local winRate = WinRatePercent(entry)
    return string.format(
        "Win rate: |c%s%.1f%%|r",
        WinRateHex(winRate),
        winRate
    )
end

local function SmoothedWinRate(entry)
    -- A small neutral prior makes a 0-1 result less influential than a
    -- sustained losing matchup, while draws remain neutral.
    local wins = tonumber(entry.wins) or 0
    local losses = tonumber(entry.losses) or 0
    return (wins + 1) / (wins + losses + 2)
end

local function OpponentLeaderboardText(entry)
    local winRate = WinRatePercent(entry)
    return string.format(
        "|c42FF63%dW|r-|cFF4C4C%dL|r-|cA8A8A8%dD|r  |  |c%s%.1f%%|r",
        entry.wins,
        entry.losses,
        entry.draws,
        WinRateHex(winRate),
        winRate
    )
end

local function RecordOnlyText(entry)
    return string.format(
        "|c42FF63%dW|r-|cFF4C4C%dL|r-|cA8A8A8%dD|r",
        entry.wins,
        entry.losses,
        entry.draws
    )
end

local function WinRateOnlyText(entry)
    local winRate = WinRatePercent(entry)
    return string.format("|c%s%.1f%%|r", WinRateHex(winRate), winRate)
end

local function CompactStatsText(entry)
    local winRate = WinRatePercent(entry)
    return string.format("%dW-%dL-%dD  |  %.1f%%", entry.wins, entry.losses, entry.draws, winRate)
end

local function FormatRating(rating)
    rating = tonumber(rating) or 0
    if rating == math.floor(rating) then
        return string.format("%d", rating)
    end

    if math.abs(rating * 10 - math.floor(rating * 10 + 0.5)) < 0.0001 then
        return string.format("%.1f", rating)
    end

    return string.format("%.2f", rating)
end

local function FormatSignedRating(rating)
    rating = tonumber(rating) or 0
    local prefix = rating > 0 and "+" or ""
    return prefix .. FormatRating(rating)
end

local function FormatModifierPercent(multiplier)
    return math.abs(((tonumber(multiplier) or 1) - 1) * 100)
end

local function FormatRatingDebugLine(label, duel, details)
    if not details then
        return string.format("%s: no modifier log is available for this older duel.", label)
    end

    if duel.drawn then
        return string.format("%s: Base draw 0 | Final 0", label)
    end

    if details.placement then
        return string.format(
            "%s: placement seed %s (%s; %d/%d decisive, %d/%d opponents).",
            label,
            FormatSignedRating(duel.won and details.finalChange or -details.finalChange),
            details.countsForPlacement and "counted" or "not counted",
            details.placementDecisiveCount or 0,
            PLACEMENT_DECISIVE_DUELS_REQUIRED,
            details.placementOpponentCount or 0,
            PLACEMENT_OPPONENTS_REQUIRED
        )
    end

    local parts = {
        string.format(
            "Base %s %s",
            duel.won and "win" or "loss",
            FormatSignedRating(duel.won and details.basePoints or -details.basePoints)
        ),
    }
    if (details.repeatMultiplier or 1) ~= 1 then
        table.insert(parts, string.format("Repeat x%.2f", details.repeatMultiplier))
    end
    if (details.streakMultiplier or 1) ~= 1 then
        table.insert(parts, string.format("Streak x%.2f", details.streakMultiplier))
    end
    if (details.damageMultiplier or 1) ~= 1 then
        table.insert(parts, string.format("Damage x%.2f", details.damageMultiplier))
    end
    if (details.ccMultiplier or 1) ~= 1 then
        table.insert(parts, string.format("CC x%.2f", details.ccMultiplier))
    end
    if (details.tierMultiplier or 1) ~= 1 then
        table.insert(parts, string.format("S-tier x%.2f", details.tierMultiplier))
    end
    if details.expectedWinChance then
        table.insert(parts, string.format("Expected %.0f%%", details.expectedWinChance * 100))
    end
    table.insert(parts, string.format("Final %s", FormatSignedRating(duel.won and details.finalChange or -details.finalChange)))
    return string.format("%s: %s", label, table.concat(parts, " | "))
end

local function FormatProgressExplanation(duel, details)
    if not details or duel.drawn then
        return nil
    end

    if details.placement then
        return details.countsForPlacement and "placement result counted" or "placement result not counted"
    end

    local parts = {}
    if (details.repeatMultiplier or 1) < 1 then
        table.insert(parts, string.format("repeat opponent -%.0f%%", FormatModifierPercent(details.repeatMultiplier)))
    end
    if (details.damageMultiplier or 1) > 1 then
        table.insert(parts, string.format("pressure disadvantage +%.0f%%", FormatModifierPercent(details.damageMultiplier)))
    end
    if (details.streakMultiplier or 1) > 1 then
        table.insert(parts, string.format("win-streak loss +%.0f%%", FormatModifierPercent(details.streakMultiplier)))
    end
    if (details.ccMultiplier or 1) < 1 then
        table.insert(parts, string.format("%s CC lock -%.0f%%", zo_strlower(duel.ccLockConfidence or "suspected"), FormatModifierPercent(details.ccMultiplier)))
    end
    if (details.tierMultiplier or 1) < 1 then
        table.insert(parts, string.format("S-tier adjustment -%.0f%%", FormatModifierPercent(details.tierMultiplier)))
    end

    return #parts > 0 and table.concat(parts, "; ") or nil
end

local function CreateLabel(parent, font, red, green, blue, alpha)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font)
    label:SetColor(red, green, blue, alpha or 1)
    return label
end

-- Trend graphs are UI-only projections of saved duel summaries. They use a
-- fixed pool of 32 segments/dots, so opening a graph never allocates work in
-- the combat event path or grows with the number of rendered controls.
local function CreateTrendGraph(parent, height)
    local graph = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    graph:SetDimensions(400, height)
    graph:SetCenterColor(0.035, 0.045, 0.065, 0.98)
    graph:SetEdgeColor(0.17, 0.26, 0.36, 1)

    graph.title = CreateLabel(graph, "ZoFontGameBold", 0.44, 0.78, 1)
    graph.title:SetAnchor(TOPLEFT, graph, TOPLEFT, 12, 8)
    graph.title:SetDimensions(250, 18)

    graph.topValue = CreateLabel(graph, "ZoFontGameSmall", 0.62, 0.70, 0.79)
    graph.topValue:SetAnchor(TOPRIGHT, graph, TOPRIGHT, -10, 29)
    graph.topValue:SetDimensions(80, 16)
    graph.topValue:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    graph.topValue:SetScale(0.94)

    graph.bottomValue = CreateLabel(graph, "ZoFontGameSmall", 0.62, 0.70, 0.79)
    graph.bottomValue:SetAnchor(BOTTOMRIGHT, graph, BOTTOMRIGHT, -10, -8)
    graph.bottomValue:SetDimensions(80, 16)
    graph.bottomValue:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    graph.bottomValue:SetScale(0.94)

    graph.plot = WINDOW_MANAGER:CreateControl(nil, graph, CT_CONTROL)
    graph.plot:SetAnchor(TOPLEFT, graph, TOPLEFT, 12, 31)
    graph.plot:SetDimensions(360, math.max(48, height - 52))

    graph.zeroLine = WINDOW_MANAGER:CreateControl(nil, graph.plot, CT_BACKDROP)
    graph.zeroLine:SetDimensions(1, 1)
    graph.zeroLine:SetEdgeColor(0, 0, 0, 0)

    graph.empty = CreateLabel(graph.plot, "ZoFontGame", 0.62, 0.70, 0.79)
    graph.empty:SetAnchor(CENTER, graph.plot, CENTER, 0, 0)
    graph.empty:SetDimensions(280, 22)
    graph.empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    graph.empty:SetText("No recorded data yet")

    graph.segments = {}
    graph.dots = {}
    for index = 1, GRAPH_MAX_POINTS do
        local dot = WINDOW_MANAGER:CreateControl(nil, graph.plot, CT_BACKDROP)
        dot:SetDimensions(5, 5)
        dot:SetEdgeColor(0, 0, 0, 0)
        dot:SetHidden(true)
        graph.dots[index] = dot
        if index < GRAPH_MAX_POINTS then
            local segment = WINDOW_MANAGER:CreateControl(nil, graph.plot, CT_TEXTURE)
            segment:SetTexture("EsoUI/Art/Miscellaneous/white.dds")
            segment:SetDimensions(1, 2)
            segment:SetHidden(true)
            graph.segments[index] = segment
        end
    end

    return graph
end

local function DownsampleTrendValues(values)
    if #values <= GRAPH_MAX_POINTS then
        return values
    end

    local sampled = {}
    for index = 1, GRAPH_MAX_POINTS do
        local sourceIndex = math.floor(((index - 1) * (#values - 1) / (GRAPH_MAX_POINTS - 1)) + 0.5) + 1
        sampled[index] = values[sourceIndex]
    end
    return sampled
end

local function SetTrendGraphValues(graph, title, values, color, valueFormatter)
    graph.title:SetText(title)
    values = DownsampleTrendValues(values or {})
    local pointCount = #values
    local hasValues = pointCount >= 2
    graph.empty:SetHidden(hasValues)
    for index = 1, GRAPH_MAX_POINTS do
        graph.dots[index]:SetHidden(not hasValues or index > pointCount)
        if index < GRAPH_MAX_POINTS then
            graph.segments[index]:SetHidden(not hasValues or index >= pointCount)
        end
    end
    if not hasValues then
        graph.topValue:SetText("--")
        graph.bottomValue:SetText("--")
        graph.zeroLine:SetHidden(true)
        return
    end

    local minimum, maximum = values[1], values[1]
    for _, value in ipairs(values) do
        minimum = math.min(minimum, value)
        maximum = math.max(maximum, value)
    end
    local span = maximum - minimum
    if span < 0.01 then
        minimum = minimum - 0.5
        maximum = maximum + 0.5
        span = maximum - minimum
    else
        local padding = span * 0.08
        minimum = minimum - padding
        maximum = maximum + padding
        span = maximum - minimum
    end

    local plotWidth = graph.plot:GetWidth()
    local plotHeight = graph.plot:GetHeight()
    local points = {}
    for index, value in ipairs(values) do
        local x = pointCount == 1 and plotWidth / 2 or ((index - 1) / (pointCount - 1)) * (plotWidth - 6) + 3
        local y = plotHeight - 5 - ((value - minimum) / span) * (plotHeight - 10)
        points[index] = { x = x, y = y }
        local dot = graph.dots[index]
        dot:ClearAnchors()
        dot:SetAnchor(CENTER, graph.plot, TOPLEFT, x, y)
        dot:SetCenterColor(color[1], color[2], color[3], 1)
        dot:SetEdgeColor(color[1], color[2], color[3], 1)
    end
    for index = 1, pointCount - 1 do
        local first, second = points[index], points[index + 1]
        local deltaX, deltaY = second.x - first.x, second.y - first.y
        local segment = graph.segments[index]
        segment:ClearAnchors()
        segment:SetAnchor(CENTER, graph.plot, TOPLEFT, first.x + deltaX / 2, first.y + deltaY / 2)
        segment:SetDimensions(math.sqrt(deltaX * deltaX + deltaY * deltaY), 2)
        segment:SetColor(color[1], color[2], color[3], 0.92)
        -- Points are ordered left-to-right, so deltaX is always positive and
        -- Lua's portable one-argument atan is sufficient here.
        segment:SetTextureRotation(math.atan(deltaY / deltaX), 0.5, 0.5)
    end

    if minimum <= 0 and maximum >= 0 then
        local zeroY = plotHeight - 5 - ((0 - minimum) / span) * (plotHeight - 10)
        graph.zeroLine:ClearAnchors()
        graph.zeroLine:SetAnchor(TOPLEFT, graph.plot, TOPLEFT, 0, zeroY)
        graph.zeroLine:SetDimensions(plotWidth, 1)
        graph.zeroLine:SetCenterColor(0.30, 0.38, 0.48, 0.70)
        graph.zeroLine:SetHidden(false)
    else
        graph.zeroLine:SetHidden(true)
    end
    graph.topValue:SetText(valueFormatter(maximum))
    graph.bottomValue:SetText(valueFormatter(minimum))
end


local Private = PvPerformance.Private
Private.ADDON_NAME = ADDON_NAME
Private.DISPLAY_NAME = DISPLAY_NAME
Private.SAVED_VARIABLES_VERSION = SAVED_VARIABLES_VERSION
Private.MAX_HISTORY = MAX_HISTORY
Private.CURRENT_SEASON_ID = CURRENT_SEASON_ID
Private.CURRENT_SEASON_NAME = CURRENT_SEASON_NAME
Private.PRESEASON_ID = PRESEASON_ID
Private.PRESEASON_NAME = PRESEASON_NAME
Private.CREATOR_DISPLAY_NAMES = CREATOR_DISPLAY_NAMES
Private.DEFAULT_WINDOW_WIDTH = DEFAULT_WINDOW_WIDTH
Private.DEFAULT_WINDOW_HEIGHT = DEFAULT_WINDOW_HEIGHT
Private.MIN_WINDOW_WIDTH = MIN_WINDOW_WIDTH
Private.MIN_WINDOW_HEIGHT = MIN_WINDOW_HEIGHT
Private.TIER_CARD_SIZE = TIER_CARD_SIZE
Private.TIER_LABEL_SCALE = TIER_LABEL_SCALE
Private.TIER_PROGRESS_WIDTH = TIER_PROGRESS_WIDTH
Private.TIER_PROGRESS_FILL_WIDTH = TIER_PROGRESS_FILL_WIDTH
Private.TIER_PROGRESS_HEIGHT = TIER_PROGRESS_HEIGHT
Private.TIER_PROGRESS_FILL_HEIGHT = TIER_PROGRESS_FILL_HEIGHT
Private.SUMMARY_RAIL_LEFT = SUMMARY_RAIL_LEFT
Private.SUMMARY_RAIL_TOP = SUMMARY_RAIL_TOP
Private.SUMMARY_RAIL_GAP = SUMMARY_RAIL_GAP
Private.SUMMARY_RAIL_STEP = SUMMARY_RAIL_STEP
Private.SUMMARY_RAIL_SELECTOR_TO_SUMMARY_GAP = SUMMARY_RAIL_SELECTOR_TO_SUMMARY_GAP
Private.SUMMARY_RAIL_DIVIDER_X = SUMMARY_RAIL_DIVIDER_X
Private.SUMMARY_RAIL_DIVIDER_TOP = SUMMARY_RAIL_DIVIDER_TOP
Private.MAIN_CONTENT_LEFT = MAIN_CONTENT_LEFT
Private.TAB_TOP = TAB_TOP
Private.ROW_TOP = ROW_TOP
Private.JOURNAL_ROW_HEIGHT = JOURNAL_ROW_HEIGHT
Private.DETAIL_PERFORMANCE_HEIGHT = DETAIL_PERFORMANCE_HEIGHT
Private.GRAPH_MAX_POINTS = GRAPH_MAX_POINTS
Private.GRAPH_ROLLING_WINDOW = GRAPH_ROLLING_WINDOW
Private.STARTING_RATING = STARTING_RATING
Private.PLACEMENT_OPPONENTS_REQUIRED = PLACEMENT_OPPONENTS_REQUIRED
Private.PLACEMENT_DECISIVE_DUELS_REQUIRED = PLACEMENT_DECISIVE_DUELS_REQUIRED
Private.PLACEMENT_MAX_RESULTS_PER_OPPONENT = PLACEMENT_MAX_RESULTS_PER_OPPONENT
Private.PLACEMENT_SEED_BASE = PLACEMENT_SEED_BASE
Private.PLACEMENT_SEED_POINTS_PER_RESULT = PLACEMENT_SEED_POINTS_PER_RESULT
Private.PLACEMENT_SEED_MIN = PLACEMENT_SEED_MIN
Private.PLACEMENT_SEED_MAX = PLACEMENT_SEED_MAX
Private.CALIBRATION_DECISIVE_DUELS_REQUIRED = CALIBRATION_DECISIVE_DUELS_REQUIRED
Private.WIN_POINTS = WIN_POINTS
Private.LOSS_POINTS = LOSS_POINTS
Private.RATING_RULES_VERSION = RATING_RULES_VERSION
Private.CLASS_RATING_RULES_VERSION = CLASS_RATING_RULES_VERSION
Private.CLASS_RATING_K = CLASS_RATING_K
Private.WIN_STREAK_POINT_MULTIPLIERS = WIN_STREAK_POINT_MULTIPLIERS
Private.EXHAUSTED_MATCHUP_WIN_COUNT = EXHAUSTED_MATCHUP_WIN_COUNT
Private.EXHAUSTED_MATCHUP_RECOVERY_DECISIVE_DUELS = EXHAUSTED_MATCHUP_RECOVERY_DECISIVE_DUELS
Private.EXHAUSTED_MATCHUP_RECOVERY_UNIQUE_OPPONENTS = EXHAUSTED_MATCHUP_RECOVERY_UNIQUE_OPPONENTS
Private.LOSS_STREAK_PENALTY_PER_WIN = LOSS_STREAK_PENALTY_PER_WIN
Private.MAX_LOSS_STREAK_PENALTY = MAX_LOSS_STREAK_PENALTY
Private.DAMAGE_MODIFIER_MIN_DURATION_SECONDS = DAMAGE_MODIFIER_MIN_DURATION_SECONDS
Private.DAMAGE_MODIFIER_MIN_TOTAL = DAMAGE_MODIFIER_MIN_TOTAL
Private.DAMAGE_BURST_WINDOW_MS = DAMAGE_BURST_WINDOW_MS
Private.DAMAGE_MODIFIER_MAX_BURST_SHARE = DAMAGE_MODIFIER_MAX_BURST_SHARE
Private.DAMAGE_RATIO_MULTIPLIERS = DAMAGE_RATIO_MULTIPLIERS
Private.CC_LOCK_MIN_STAMINA = CC_LOCK_MIN_STAMINA
Private.CC_LOCK_MIN_STUN_DURATION_MS = CC_LOCK_MIN_STUN_DURATION_MS
Private.CC_LOCK_IMMEDIATE_FINISH_WINDOW_MS = CC_LOCK_IMMEDIATE_FINISH_WINDOW_MS
Private.CC_LOCK_LIKELY_FINISH_WINDOW_MS = CC_LOCK_LIKELY_FINISH_WINDOW_MS
Private.CC_LOCK_RECOVERY_FINISH_WINDOW_MS = CC_LOCK_RECOVERY_FINISH_WINDOW_MS
Private.CC_LOCK_POSSIBLE_LOSS_MULTIPLIER = CC_LOCK_POSSIBLE_LOSS_MULTIPLIER
Private.CC_LOCK_LIKELY_LOSS_MULTIPLIER = CC_LOCK_LIKELY_LOSS_MULTIPLIER
Private.CC_LOCK_STRONG_LOSS_MULTIPLIER = CC_LOCK_STRONG_LOSS_MULTIPLIER
Private.LATENCY_SAMPLE_INTERVAL_MS = LATENCY_SAMPLE_INTERVAL_MS
Private.LATENCY_MIN_BASELINE_SAMPLES = LATENCY_MIN_BASELINE_SAMPLES
Private.LATENCY_BASELINE_WINDOW_SAMPLES = LATENCY_BASELINE_WINDOW_SAMPLES
Private.LATENCY_MODERATE_MIN_DELTA_MS = LATENCY_MODERATE_MIN_DELTA_MS
Private.LATENCY_MODERATE_MULTIPLIER = LATENCY_MODERATE_MULTIPLIER
Private.LATENCY_SEVERE_MIN_DELTA_MS = LATENCY_SEVERE_MIN_DELTA_MS
Private.LATENCY_SEVERE_MULTIPLIER = LATENCY_SEVERE_MULTIPLIER
Private.LATENCY_MIN_SPIKE_DURATION_MS = LATENCY_MIN_SPIKE_DURATION_MS
Private.LATENCY_FINISH_WINDOW_MS = LATENCY_FINISH_WINDOW_MS
Private.LATENCY_UPDATE_NAME = LATENCY_UPDATE_NAME
Private.AGGREGATE_SORT_OPTIONS = AGGREGATE_SORT_OPTIONS
Private.CLASS_DRAGONKNIGHT = CLASS_DRAGONKNIGHT
Private.CLASS_SORCERER = CLASS_SORCERER
Private.CLASS_NIGHTBLADE = CLASS_NIGHTBLADE
Private.CLASS_WARDEN = CLASS_WARDEN
Private.CLASS_NECROMANCER = CLASS_NECROMANCER
Private.CLASS_TEMPLAR = CLASS_TEMPLAR
Private.CLASS_ARCANIST = CLASS_ARCANIST
Private.CLASS_WEREWOLF = CLASS_WEREWOLF
Private.CLASS_TIER_OPTIONS = CLASS_TIER_OPTIONS
Private.TEST_CLASS_ALIASES = TEST_CLASS_ALIASES
Private.CLASS_POWER_RANK = CLASS_POWER_RANK
Private.WEREWOLF_SIGNATURE_ABILITY_IDS = WEREWOLF_SIGNATURE_ABILITY_IDS
Private.DEFAULTS = DEFAULTS
Private.UI_SCALE_OPTIONS = UI_SCALE_OPTIONS
Private.EFFECT_INTENSITY_OPTIONS = EFFECT_INTENSITY_OPTIONS
Private.DAMAGE_COMBAT_RESULTS = DAMAGE_COMBAT_RESULTS
Private.HEAL_COMBAT_RESULTS = HEAL_COMBAT_RESULTS
Private.COMBAT_SUMMARY_TOP_SOURCES = COMBAT_SUMMARY_TOP_SOURCES
Private.RANK_THRESHOLDS = RANK_THRESHOLDS
Private.Print = Print
Private.SignedRatingChange = SignedRatingChange
Private.NameForClass = NameForClass
Private.NameForRace = NameForRace
Private.FormatDuration = FormatDuration
Private.FormatDamage = FormatDamage
Private.DamageDoneDifferenceText = DamageDoneDifferenceText
Private.ChampionPointCount = ChampionPointCount
Private.FormatDuelTime = FormatDuelTime
Private.CleanCharacterName = CleanCharacterName
Private.NormalizeUnitName = NormalizeUnitName
Private.NamesMatch = NamesMatch
Private.PlayerIsWerewolf = PlayerIsWerewolf
Private.WinRateColor = WinRateColor
Private.WinRateHex = WinRateHex
Private.RankForRating = RankForRating
Private.RatingProgressForRank = RatingProgressForRank
Private.PointsToNextRank = PointsToNextRank
Private.OverallTierTooltipText = OverallTierTooltipText
Private.ClassTierTooltipText = ClassTierTooltipText
Private.DisplayNameScale = DisplayNameScale
Private.OpponentKey = OpponentKey
Private.ConsecutiveWinMultiplier = ConsecutiveWinMultiplier
Private.LossStreakMultiplier = LossStreakMultiplier
Private.HighTierWinMultiplier = HighTierWinMultiplier
Private.HighTierLossMultiplier = HighTierLossMultiplier
Private.DamageMultiplierForRatio = DamageMultiplierForRatio
Private.DamageRatingMultiplierForDuel = DamageRatingMultiplierForDuel
Private.CalculateDamageRatingMultiplier = CalculateDamageRatingMultiplier
Private.ClassExpectedWinChance = ClassExpectedWinChance
Private.AdvanceExhaustedMatchupRecovery = AdvanceExhaustedMatchupRecovery
Private.PlacementComplete = PlacementComplete
Private.CalibrationComplete = CalibrationComplete
Private.PlacementSeed = PlacementSeed
Private.ProvisionalProgressText = ProvisionalProgressText
Private.ApplyRatingChange = ApplyRatingChange
Private.CopyRanking = CopyRanking
Private.TestClassIdFromText = TestClassIdFromText
Private.MatchesSearch = MatchesSearch
Private.AddToStats = AddToStats
Private.WinRateRatio = WinRateRatio
Private.WinRatePercent = WinRatePercent
Private.ClassDisplayForDuel = ClassDisplayForDuel
Private.StatsText = StatsText
Private.StatsWinRateText = StatsWinRateText
Private.SmoothedWinRate = SmoothedWinRate
Private.OpponentLeaderboardText = OpponentLeaderboardText
Private.RecordOnlyText = RecordOnlyText
Private.WinRateOnlyText = WinRateOnlyText
Private.CompactStatsText = CompactStatsText
Private.FormatRating = FormatRating
Private.FormatSignedRating = FormatSignedRating
Private.FormatModifierPercent = FormatModifierPercent
Private.FormatRatingDebugLine = FormatRatingDebugLine
Private.FormatProgressExplanation = FormatProgressExplanation
Private.CreateLabel = CreateLabel
Private.CreateTrendGraph = CreateTrendGraph
Private.DownsampleTrendValues = DownsampleTrendValues
Private.SetTrendGraphValues = SetTrendGraphValues
