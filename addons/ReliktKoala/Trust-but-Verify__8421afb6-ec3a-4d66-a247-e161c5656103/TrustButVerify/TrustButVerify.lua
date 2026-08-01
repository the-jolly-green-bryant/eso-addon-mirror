TrustButVerify = TrustButVerify or {}
local TBV = TrustButVerify

TBV.name = "TrustButVerify"
TBV.savedVarName = "TrustButVerifySavedVariables"
TBV.savedVarVersion = 1

TBV.defaults = {
    totalMountUps = 0,
    trackedMountUps = 0,
    skippedWhenRandomOff = 0,
    skippedWhenFavoriteRandom = 0,
    skippedWhenRandomUndetermined = 0,
    skippedUnknownMount = 0,
    randomSettingSamples = {
        enabled = 0,
        disabled = 0,
        unknown = 0,
    },
    countsByMountId = {},
    mountNamesById = {},
    currentStreak = {
        mountId = 0,
        length = 0,
    },
    maxStreak = {
        mountId = 0,
        length = 0,
    },
}

local function Print(message)
    d(string.format("[%s] %s", TBV.name, message))
end

local function Trim(text)
    local value = text or ""
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    return value
end

local function ToBoolean(value)
    if value == nil then
        return nil
    end

    if type(value) == "boolean" then
        return value
    end

    local asNumber = tonumber(value)
    if asNumber ~= nil then
        return asNumber ~= 0
    end

    local asString = tostring(value):lower()
    if asString == "true" or asString == "on" then
        return true
    end
    if asString == "false" or asString == "off" then
        return false
    end

    return nil
end

local function FormatPercent(part, whole)
    if whole <= 0 then
        return "0.00%"
    end
    return string.format("%.2f%%", (part / whole) * 100)
end

local function FormatPValue(pValue)
    if pValue == nil then
        return "n/a"
    end
    if pValue < 0.0001 then
        return "<0.0001"
    end
    return string.format("%.4f", pValue)
end

local function GetFairnessAssessment(stats)
    if stats.unlockedMountCount < 2 then
        return {
            verdict = "Not enough variety yet (need at least 2 unlocked mounts).",
            guidance = "Unlock at least two mounts before checking fairness.",
        }
    end

    if stats.totalTracked < 30 then
        return {
            verdict = "Too little data for a meaningful fairness verdict.",
            guidance = string.format(
                "Collect more mount-ups (current: %d, suggested minimum: 30).",
                stats.totalTracked
            ),
        }
    end

    if stats.expectedPerMount < 5 then
        local suggestedSamples = math.ceil(stats.unlockedMountCount * 5)
        return {
            verdict = "Still inconclusive: sample size is too small for a reliable check.",
            guidance = string.format(
                "Try to reach around %d tracked samples (current: %d).",
                suggestedSamples,
                stats.totalTracked
            ),
        }
    end

    if stats.pValue == nil then
        return {
            verdict = "No fairness verdict available yet.",
            guidance = "Collect more samples and try again.",
        }
    end

    if stats.pValue < 0.01 then
        return {
            verdict = "Strong imbalance signal: outcomes look unlikely to be uniformly random.",
            guidance = "Keep collecting data; if this stays, random mount behavior may be biased.",
        }
    end

    if stats.pValue < 0.05 then
        return {
            verdict = "Possible imbalance signal: outcomes look somewhat uneven.",
            guidance = "Collect more samples to confirm whether this trend persists.",
        }
    end

    return {
        verdict = "No imbalance signal right now: outcomes look reasonably fair so far.",
        guidance = "Keep collecting samples for a stronger long-term confidence level.",
    }
end

local function NormalCdf(x)
    local absoluteX = math.abs(x)
    local t = 1 / (1 + 0.2316419 * absoluteX)
    local polynomial = t
        * (
            0.319381530
            + t
            * (
                -0.356563782
                + t
                * (
                    1.781477937
                    + t * (-1.821255978 + t * 1.330274429)
                )
            )
        )
    local density = 0.3989422804014327 * math.exp(-0.5 * absoluteX * absoluteX)
    local cdf = 1 - density * polynomial

    if x < 0 then
        return 1 - cdf
    end
    return cdf
end

local function ApproximateChiSquareUpperTail(chiSquareValue, degreesOfFreedom)
    if degreesOfFreedom <= 0 then
        return nil
    end

    -- Wilson-Hilferty transform to approximate chi-square upper-tail probability.
    local transformed = (chiSquareValue / degreesOfFreedom) ^ (1 / 3)
    local mean = 1 - (2 / (9 * degreesOfFreedom))
    local stdDev = math.sqrt(2 / (9 * degreesOfFreedom))
    local zScore = (transformed - mean) / stdDev
    local pValue = 1 - NormalCdf(zScore)

    if pValue < 0 then
        return 0
    end
    if pValue > 1 then
        return 1
    end
    return pValue
end

local RANDOM_MOUNT_MODE_ALL = "all"
local RANDOM_MOUNT_MODE_FAVORITE = "favorite"
local RANDOM_MOUNT_MODE_OFF = "off"
local RANDOM_MOUNT_MODE_UNKNOWN = "unknown"

local function GetRandomMountMode()
    if type(GetRandomMountType) == "function"
        and type(COLLECTIBLE_CATEGORY_TYPE_MOUNT) == "number" then
        local ok, randomMountType = pcall(
            GetRandomMountType,
            COLLECTIBLE_CATEGORY_TYPE_MOUNT
        )
        if ok and tonumber(randomMountType) ~= nil then
            local mode = tonumber(randomMountType)
            if mode == 2 then
                return RANDOM_MOUNT_MODE_ALL
            end
            if mode == 1 then
                return RANDOM_MOUNT_MODE_FAVORITE
            end
            if mode == 0 then
                return RANDOM_MOUNT_MODE_OFF
            end
            return RANDOM_MOUNT_MODE_UNKNOWN
        end
    end

    if type(SETTING_TYPE_COLLECTIBLES) ~= "number" then
        return nil
    end
    if COLLECTIBLES_SETTING_RANDOMIZE_MOUNT == nil then
        return nil
    end

    if type(GetSetting_Bool) == "function" then
        local ok, value = pcall(
            GetSetting_Bool,
            SETTING_TYPE_COLLECTIBLES,
            COLLECTIBLES_SETTING_RANDOMIZE_MOUNT
        )
        if ok then
            if value then
                return RANDOM_MOUNT_MODE_ALL
            end
            return RANDOM_MOUNT_MODE_OFF
        end
    end

    if type(GetSetting) == "function" then
        local ok, value = pcall(
            GetSetting,
            SETTING_TYPE_COLLECTIBLES,
            COLLECTIBLES_SETTING_RANDOMIZE_MOUNT
        )
        if ok then
            local boolValue = ToBoolean(value)
            if boolValue == true then
                return RANDOM_MOUNT_MODE_ALL
            end
            if boolValue == false then
                return RANDOM_MOUNT_MODE_OFF
            end
        end
    end

    return RANDOM_MOUNT_MODE_UNKNOWN
end

local function GetActiveMountId()
    local mountId = 0

    if type(GetActiveMount) == "function" then
        local fromActiveMount = GetActiveMount()
        if tonumber(fromActiveMount) ~= nil then
            mountId = tonumber(fromActiveMount)
        end
    end

    if mountId == 0 and type(GetActiveCollectibleByType) == "function" then
        local fromCollectibleType = GetActiveCollectibleByType(
            COLLECTIBLE_CATEGORY_TYPE_MOUNT
        )
        if tonumber(fromCollectibleType) ~= nil then
            mountId = tonumber(fromCollectibleType)
        end
    end

    return mountId
end

local function GetMountName(mountId)
    if mountId == nil or mountId <= 0 then
        return "Unknown mount"
    end

    if type(GetCollectibleName) == "function" then
        local name = GetCollectibleName(mountId)
        if name ~= nil and name ~= "" then
            if type(ZO_CachedStrFormat) == "function"
                and SI_COLLECTIBLE_NAME_FORMATTER ~= nil then
                return ZO_CachedStrFormat(SI_COLLECTIBLE_NAME_FORMATTER, name)
            end
            return name
        end
    end

    return tostring(mountId)
end

local function GetUnlockedMountIds()
    local unlockedMountIds = {}

    if type(GetTotalCollectiblesByCategoryType) ~= "function"
        or type(GetCollectibleIdFromType) ~= "function"
        or type(GetCollectibleInfo) ~= "function" then
        return unlockedMountIds
    end

    local totalMounts = GetTotalCollectiblesByCategoryType(
        COLLECTIBLE_CATEGORY_TYPE_MOUNT
    ) or 0
    for index = 1, totalMounts do
        local mountId = GetCollectibleIdFromType(
            COLLECTIBLE_CATEGORY_TYPE_MOUNT,
            index
        )
        if mountId ~= nil and mountId ~= 0 then
            local _, _, _, _, unlocked = GetCollectibleInfo(mountId)
            if unlocked then
                unlockedMountIds[#unlockedMountIds + 1] = mountId
            end
        end
    end

    return unlockedMountIds
end

local function EnsureSavedVariableSchema()
    TBV.sv = TBV.sv or {}

    if type(TBV.sv.randomSettingSamples) ~= "table" then
        TBV.sv.randomSettingSamples = { enabled = 0, disabled = 0, unknown = 0 }
    end
    if type(TBV.sv.countsByMountId) ~= "table" then
        TBV.sv.countsByMountId = {}
    end
    if type(TBV.sv.mountNamesById) ~= "table" then
        TBV.sv.mountNamesById = {}
    end
    if type(TBV.sv.currentStreak) ~= "table" then
        TBV.sv.currentStreak = { mountId = 0, length = 0 }
    end
    if type(TBV.sv.maxStreak) ~= "table" then
        TBV.sv.maxStreak = { mountId = 0, length = 0 }
    end

    TBV.sv.totalMountUps = tonumber(TBV.sv.totalMountUps) or 0
    TBV.sv.trackedMountUps = tonumber(TBV.sv.trackedMountUps) or 0
    TBV.sv.skippedWhenRandomOff = tonumber(TBV.sv.skippedWhenRandomOff) or 0
    TBV.sv.skippedWhenFavoriteRandom =
        tonumber(TBV.sv.skippedWhenFavoriteRandom) or 0
    TBV.sv.skippedWhenRandomUndetermined =
        tonumber(TBV.sv.skippedWhenRandomUndetermined) or 0
    TBV.sv.skippedUnknownMount = tonumber(TBV.sv.skippedUnknownMount) or 0

    TBV.sv.randomSettingSamples.enabled =
        tonumber(TBV.sv.randomSettingSamples.enabled) or 0
    TBV.sv.randomSettingSamples.disabled =
        tonumber(TBV.sv.randomSettingSamples.disabled) or 0
    TBV.sv.randomSettingSamples.unknown =
        tonumber(TBV.sv.randomSettingSamples.unknown) or 0

    TBV.sv.currentStreak.mountId = tonumber(TBV.sv.currentStreak.mountId) or 0
    TBV.sv.currentStreak.length = tonumber(TBV.sv.currentStreak.length) or 0
    TBV.sv.maxStreak.mountId = tonumber(TBV.sv.maxStreak.mountId) or 0
    TBV.sv.maxStreak.length = tonumber(TBV.sv.maxStreak.length) or 0

    local normalizedCounts = {}
    for rawMountId, rawCount in pairs(TBV.sv.countsByMountId) do
        local mountId = tonumber(rawMountId)
        local count = tonumber(rawCount) or 0
        if mountId ~= nil then
            normalizedCounts[mountId] = (normalizedCounts[mountId] or 0) + count
        end
    end
    TBV.sv.countsByMountId = normalizedCounts

    local normalizedNames = {}
    for rawMountId, rawName in pairs(TBV.sv.mountNamesById) do
        local mountId = tonumber(rawMountId)
        if mountId ~= nil and rawName ~= nil and rawName ~= "" then
            normalizedNames[mountId] = tostring(rawName)
        end
    end
    TBV.sv.mountNamesById = normalizedNames
end

function TBV:RecordMountSelection()
    self.sv.totalMountUps = self.sv.totalMountUps + 1

    local randomMountMode = GetRandomMountMode()
    if randomMountMode == RANDOM_MOUNT_MODE_ALL then
        self.sv.randomSettingSamples.enabled =
            self.sv.randomSettingSamples.enabled + 1
    elseif randomMountMode == RANDOM_MOUNT_MODE_OFF then
        self.sv.randomSettingSamples.disabled =
            self.sv.randomSettingSamples.disabled + 1
        self.sv.skippedWhenRandomOff = self.sv.skippedWhenRandomOff + 1
        return
    elseif randomMountMode == RANDOM_MOUNT_MODE_FAVORITE then
        self.sv.randomSettingSamples.disabled =
            self.sv.randomSettingSamples.disabled + 1
        self.sv.skippedWhenFavoriteRandom =
            self.sv.skippedWhenFavoriteRandom + 1
        return
    else
        self.sv.randomSettingSamples.unknown =
            self.sv.randomSettingSamples.unknown + 1
        self.sv.skippedWhenRandomUndetermined =
            self.sv.skippedWhenRandomUndetermined + 1
        return
    end

    local mountId = GetActiveMountId()
    if mountId == 0 then
        self.sv.skippedUnknownMount = self.sv.skippedUnknownMount + 1
        return
    end

    self.sv.trackedMountUps = self.sv.trackedMountUps + 1
    self.sv.countsByMountId[mountId] =
        (tonumber(self.sv.countsByMountId[mountId]) or 0) + 1
    self.sv.mountNamesById[mountId] = GetMountName(mountId)

    local streak = self.sv.currentStreak
    if streak.mountId == mountId then
        streak.length = streak.length + 1
    else
        streak.mountId = mountId
        streak.length = 1
    end

    local maxStreak = self.sv.maxStreak
    if streak.length > maxStreak.length then
        maxStreak.mountId = mountId
        maxStreak.length = streak.length
    end
end

function TBV:BuildStatistics()
    local rows = {}
    local countsByMountId = self.sv.countsByMountId
    local mountNamesById = self.sv.mountNamesById
    local unlockedMountIds = GetUnlockedMountIds()
    local unlockedIdLookup = {}

    local totalTracked = 0
    local unlockedSampleCount = 0
    local observedDistinct = 0

    for _, mountId in ipairs(unlockedMountIds) do
        local count = tonumber(countsByMountId[mountId]) or 0
        local name = mountNamesById[mountId] or GetMountName(mountId)
        unlockedIdLookup[mountId] = true
        totalTracked = totalTracked + count
        unlockedSampleCount = unlockedSampleCount + count
        if count > 0 then
            observedDistinct = observedDistinct + 1
        end
        rows[#rows + 1] = {
            mountId = mountId,
            count = count,
            name = tostring(name),
            unavailable = false,
        }
    end

    for rawMountId, rawCount in pairs(countsByMountId) do
        local mountId = tonumber(rawMountId)
        local count = tonumber(rawCount) or 0
        if mountId ~= nil and unlockedIdLookup[mountId] ~= true then
            local name = mountNamesById[mountId] or tostring(mountId)
            totalTracked = totalTracked + count
            if count > 0 then
                observedDistinct = observedDistinct + 1
            end
            rows[#rows + 1] = {
                mountId = mountId,
                count = count,
                name = tostring(name),
                unavailable = true,
            }
        end
    end

    table.sort(rows, function(left, right)
        if left.count == right.count then
            return left.name < right.name
        end
        return left.count > right.count
    end)

    local unlockedMountCount = #unlockedMountIds
    local expectedPerMount = 0
    local chiSquareValue = nil
    local degreesOfFreedom = nil
    local pValue = nil

    if unlockedMountCount > 0 then
        expectedPerMount = unlockedSampleCount / unlockedMountCount
    end
    if unlockedMountCount > 1 and unlockedSampleCount > 0 then
        chiSquareValue = 0
        for _, mountId in ipairs(unlockedMountIds) do
            local observed = tonumber(countsByMountId[mountId]) or 0
            local difference = observed - expectedPerMount
            chiSquareValue = chiSquareValue + (
                (difference * difference) / expectedPerMount
            )
        end
        degreesOfFreedom = unlockedMountCount - 1
        pValue = ApproximateChiSquareUpperTail(chiSquareValue, degreesOfFreedom)
    end

    return {
        rows = rows,
        totalTracked = totalTracked,
        unlockedSampleCount = unlockedSampleCount,
        observedDistinct = observedDistinct,
        unlockedMountCount = unlockedMountCount,
        expectedPerMount = expectedPerMount,
        chiSquareValue = chiSquareValue,
        degreesOfFreedom = degreesOfFreedom,
        pValue = pValue,
    }
end

function TBV:PrintSummary()
    local stats = self:BuildStatistics()
    local totalMountUps = self.sv.totalMountUps
    local randomSamples = self.sv.randomSettingSamples

    Print(
        string.format(
            "Mount-ups seen: %d | tracked samples: %d",
            totalMountUps,
            stats.totalTracked
        )
    )
    Print(
        string.format(
            "Random mode checks: eligible-all=%d disabled-or-favorite=%d unknown=%d",
            randomSamples.enabled,
            randomSamples.disabled,
            randomSamples.unknown
        )
    )
    if self.sv.skippedWhenRandomOff > 0
        or self.sv.skippedWhenFavoriteRandom > 0
        or self.sv.skippedWhenRandomUndetermined > 0
        or self.sv.skippedUnknownMount > 0 then
        Print(
            string.format(
                "Skipped samples: random-off=%d random-favorite=%d random-undetermined=%d unknown-mount=%d",
                self.sv.skippedWhenRandomOff,
                self.sv.skippedWhenFavoriteRandom,
                self.sv.skippedWhenRandomUndetermined,
                self.sv.skippedUnknownMount
            )
        )
    end

    Print(
        string.format(
            "Unlocked mounts now: %d | observed mounts: %d",
            stats.unlockedMountCount,
            stats.observedDistinct
        )
    )

    if self.sv.maxStreak.length > 1 then
        local streakName = self.sv.mountNamesById[self.sv.maxStreak.mountId]
            or GetMountName(self.sv.maxStreak.mountId)
        Print(
            string.format(
                "Longest streak: %d (%s)",
                self.sv.maxStreak.length,
                streakName
            )
        )
    end

    local assessment = GetFairnessAssessment(stats)
    Print("Fairness verdict: " .. assessment.verdict)
    Print(assessment.guidance)
    Print("Use /mountstats technical for raw test values.")

    if stats.totalTracked == 0 then
        Print("No mount data yet. Mount up with Random Mount (all mounts) enabled to collect samples.")
        return
    end

    local maxRows = math.min(3, #stats.rows)
    if maxRows == 0 then
        Print("No mount data available to display.")
        return
    end

    Print("Top mount counts:")
    for index = 1, maxRows do
        local row = stats.rows[index]
        local suffix = ""
        if row.unavailable then
            suffix = " (not currently unlocked)"
        end
        Print(
            string.format(
                "%d. %s: %d (%s)%s",
                index,
                row.name,
                row.count,
                FormatPercent(row.count, stats.totalTracked),
                suffix
            )
        )
    end
    if #stats.rows > maxRows then
        Print(string.format("... %d more mounts omitted.", #stats.rows - maxRows))
    end
end

function TBV:PrintTechnicalSummary()
    local stats = self:BuildStatistics()

    if stats.chiSquareValue == nil then
        Print("Technical fairness values are unavailable yet.")
        Print("Need at least 2 unlocked mounts and tracked samples.")
        return
    end

    Print(
        string.format(
            "Technical fairness values: chi-square=%.3f, df=%d, approx p=%s, expected per mount=%.2f",
            stats.chiSquareValue,
            stats.degreesOfFreedom,
            FormatPValue(stats.pValue),
            stats.expectedPerMount
        )
    )
end

function TBV:ResetStatistics()
    self.sv.totalMountUps = 0
    self.sv.trackedMountUps = 0
    self.sv.skippedWhenRandomOff = 0
    self.sv.skippedWhenFavoriteRandom = 0
    self.sv.skippedWhenRandomUndetermined = 0
    self.sv.skippedUnknownMount = 0
    self.sv.randomSettingSamples.enabled = 0
    self.sv.randomSettingSamples.disabled = 0
    self.sv.randomSettingSamples.unknown = 0
    self.sv.countsByMountId = {}
    self.sv.mountNamesById = {}
    self.sv.currentStreak.mountId = 0
    self.sv.currentStreak.length = 0
    self.sv.maxStreak.mountId = 0
    self.sv.maxStreak.length = 0
    Print("All tracked mount statistics were reset.")
end

function TBV:PrintHelp()
    Print("Commands:")
    Print("/mountstats - show summary + fairness check")
    Print("/mountstats technical - show chi-square/df/p technical values")
    Print("/mountstats reset - clear all tracked statistics")
    Print("/mountstats help - show command help")
end

local function HandleSlashCommand(commandText)
    local normalized = Trim(commandText):lower()
    if normalized == "" or normalized == "show" or normalized == "summary" then
        TBV:PrintSummary()
        return
    end

    if normalized == "reset" then
        TBV:ResetStatistics()
        return
    end

    if normalized == "help" then
        TBV:PrintHelp()
        return
    end

    if normalized == "technical" or normalized == "tech"
        or normalized == "details" then
        TBV:PrintTechnicalSummary()
        return
    end

    Print(string.format("Unknown argument '%s'. Use /mountstats help.", normalized))
end

local function OnMountedStateChanged(_, isMounted)
    if not isMounted then
        return
    end

    TBV:RecordMountSelection()
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= TBV.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(TBV.name, EVENT_ADD_ON_LOADED)

    TBV.sv = ZO_SavedVars:NewAccountWide(
        TBV.savedVarName,
        TBV.savedVarVersion,
        nil,
        TBV.defaults
    )
    EnsureSavedVariableSchema()

    SLASH_COMMANDS["/mountstats"] = HandleSlashCommand
    SLASH_COMMANDS["/trustbutverify"] = HandleSlashCommand
    SLASH_COMMANDS["/tbv"] = HandleSlashCommand

    EVENT_MANAGER:RegisterForEvent(
        TBV.name,
        EVENT_MOUNTED_STATE_CHANGED,
        OnMountedStateChanged
    )

    Print("Loaded. Use /mountstats (or /tbv) for mount statistics.")
end

EVENT_MANAGER:RegisterForEvent(TBV.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
