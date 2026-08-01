Nvk3UT = Nvk3UT or {}

local AchievementState = {}
Nvk3UT.AchievementState = AchievementState

local savedRoot
local savedTracker

local LEGACY_CATEGORY_KEY = "achievements"
local LEGACY_CATEGORY_ALIASES = {
    ["achievements"] = true,
    ["ACHIEVEMENTS"] = true,
    ["Achievements"] = true,
    ["root"] = true,
}

local function isDebugEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils:IsDebugEnabled()
    end
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        return diagnostics:IsDebugEnabled()
    end
    local root = Nvk3UT
    if root and type(root.IsDebugEnabled) == "function" then
        return root:IsDebugEnabled()
    end
    return false
end

local function emitDebugMessage(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local Utils = Nvk3UT and Nvk3UT.Utils
    local ok, message = pcall(string.format, fmt, ...)
    if not ok then
        message = tostring(fmt)
    end

    if Utils and Utils.d then
        Utils.d("[Nvk3UT][AchievementState] %s", message)
    elseif d then
        d(string.format("[Nvk3UT][AchievementState] %s", message))
    end
end

local function ensureTrackerSaved()
    if type(savedTracker) ~= "table" then
        return nil
    end
    return savedTracker
end

local function ensureEntryTable(create)
    local tracker = ensureTrackerSaved()
    if not tracker then
        return nil
    end

    local entries = tracker.entryExpanded
    if type(entries) ~= "table" and create then
        entries = {}
        tracker.entryExpanded = entries
    end

    return entries
end

local function ensureGroupTable(create)
    local tracker = ensureTrackerSaved()
    if not tracker then
        return nil
    end

    local groups = tracker.groupExpanded
    if type(groups) ~= "table" and create then
        groups = {}
        tracker.groupExpanded = groups
    end

    return groups
end

local function ensureTimestampTable(create)
    local tracker = ensureTrackerSaved()
    if not tracker then
        return nil
    end

    local timestamps = tracker.timestamps
    if type(timestamps) ~= "table" and create then
        timestamps = {}
        tracker.timestamps = timestamps
    end

    return timestamps
end

local function normalizeString(value)
    if type(value) ~= "string" then
        return nil
    end

    local trimmed = value:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed == "" then
        return nil
    end

    return trimmed
end

local function normalizeAchievementId(id)
    if id == nil then
        return nil
    end

    if type(id) == "number" then
        if id > 0 then
            return math.floor(id)
        end
        return nil
    end

    local stringKey = normalizeString(tostring(id))
    if not stringKey then
        return nil
    end

    local numeric = tonumber(stringKey)
    if numeric and numeric > 0 then
        return math.floor(numeric)
    end

    return nil
end

local function normalizeGroupId(groupId)
    if groupId == nil then
        return LEGACY_CATEGORY_KEY, "category"
    end

    if type(groupId) == "number" then
        if groupId > 0 then
            return math.floor(groupId), "entry"
        end
        return LEGACY_CATEGORY_KEY, "category"
    end

    local asString = normalizeString(tostring(groupId))
    if not asString then
        return LEGACY_CATEGORY_KEY, "category"
    end

    local numeric = tonumber(asString)
    if numeric and numeric > 0 then
        return math.floor(numeric), "entry"
    end

    if LEGACY_CATEGORY_ALIASES[asString] or LEGACY_CATEGORY_ALIASES[asString:lower()] then
        return LEGACY_CATEGORY_KEY, "category"
    end

    return asString, "group"
end

local function readCategoryExpanded(createDefault)
    local tracker = ensureTrackerSaved()
    if not tracker then
        return true
    end

    local value = tracker.categoryExpanded
    if value == nil and createDefault then
        tracker.categoryExpanded = true
        value = true
    end

    if value == nil then
        return true
    end

    return value ~= false
end

local function writeCategoryExpanded(expanded)
    local tracker = ensureTrackerSaved()
    if not tracker then
        return false
    end

    local normalized = expanded and true or false
    local previous = tracker.categoryExpanded
    tracker.categoryExpanded = normalized
    return previous ~= normalized
end

local function readGroupExpanded(groupKey, createDefault)
    local groups = ensureGroupTable(createDefault)
    if not groups then
        return true
    end

    local value = groups[groupKey]
    if value == nil and createDefault then
        groups[groupKey] = true
        value = true
    end

    if value == nil then
        return true
    end

    return value ~= false
end

local function writeGroupExpanded(groupKey, expanded)
    local groups = ensureGroupTable(true)
    if not groups then
        return false
    end

    local normalized = expanded and true or false
    local previous = groups[groupKey]
    groups[groupKey] = normalized
    return previous ~= normalized
end

local function readEntryExpanded(entryId, createDefault)
    local entries = ensureEntryTable(createDefault)
    if not entries then
        return true
    end

    local value = entries[entryId]
    if value == nil and createDefault then
        entries[entryId] = true
        value = true
    end

    if value == nil then
        return true
    end

    return value ~= false
end

local function writeEntryExpanded(entryId, expanded)
    local entries = ensureEntryTable(true)
    if not entries then
        return false
    end

    local normalized = expanded and true or false
    local previous = entries[entryId]
    entries[entryId] = normalized
    return previous ~= normalized
end

local function resolveNow()
    local Utils = Nvk3UT and Nvk3UT.Utils
    if Utils and Utils.Now then
        local ok, stamp = pcall(Utils.Now)
        if ok and type(stamp) == "number" then
            return stamp
        end
    end

    if type(GetTimeStamp) == "function" then
        local ok, stamp = pcall(GetTimeStamp)
        if ok and type(stamp) == "number" then
            return stamp
        end
    end

    if type(GetFrameTimeSeconds) == "function" then
        local ok, seconds = pcall(GetFrameTimeSeconds)
        if ok and type(seconds) == "number" then
            return math.floor(seconds)
        end
    end

    return os.time and os.time() or 0
end

local function touchInternal(key, overrideTimestamp)
    if not key then
        return 0
    end

    local timestamps = ensureTimestampTable(true)
    if not timestamps then
        return 0
    end

    local stamp = overrideTimestamp or resolveNow()
    timestamps[key] = stamp
    return stamp
end

function AchievementState.Init(root)
    if type(root) ~= "table" then
        savedRoot = nil
        savedTracker = nil
        return nil
    end

    savedRoot = root
    local tracker = root.AchievementTracker
    if type(tracker) ~= "table" then
        tracker = {}
        root.AchievementTracker = tracker
    end

    tracker.entryExpanded = tracker.entryExpanded or {}
    tracker.timestamps = tracker.timestamps or {}
    savedTracker = tracker
    AchievementState._saved = savedTracker

    return savedTracker
end

function AchievementState.IsGroupExpanded(groupId)
    local key, keyType = normalizeGroupId(groupId)

    if keyType == "entry" then
        return readEntryExpanded(key, true)
    elseif keyType == "category" then
        return readCategoryExpanded(true)
    else
        return readGroupExpanded(key, false)
    end
end

function AchievementState.SetGroupExpanded(groupId, expanded, source)
    local key, keyType = normalizeGroupId(groupId)
    local before
    if keyType == "entry" then
        before = readEntryExpanded(key, true)
    elseif keyType == "category" then
        before = readCategoryExpanded(true)
    else
        before = readGroupExpanded(key, false)
    end

    local changed
    if keyType == "entry" then
        changed = writeEntryExpanded(key, expanded)
    elseif keyType == "category" then
        changed = writeCategoryExpanded(expanded)
    else
        changed = writeGroupExpanded(key, expanded)
    end

    local after
    if keyType == "entry" then
        after = readEntryExpanded(key, true)
    elseif keyType == "category" then
        after = readCategoryExpanded(true)
    else
        after = readGroupExpanded(key, false)
    end

    if changed and before ~= after then
        local logKey = keyType == "entry" and string.format("entry:%s", tostring(key)) or string.format("group:%s", tostring(key))
        emitDebugMessage("set %s expanded=%s source=%s", logKey, tostring(after), tostring(source or "auto"))
        touchInternal(logKey)
    end

    return changed
end

function AchievementState.ToggleGroupExpanded(groupId, source)
    local before = AchievementState.IsGroupExpanded(groupId)
    local changed = AchievementState.SetGroupExpanded(groupId, not before, source)
    return AchievementState.IsGroupExpanded(groupId), changed
end

local function resolveFavoritesScope()
    local root = savedRoot or (Nvk3UT and Nvk3UT.sv)
    local general = root and root.General
    local scope = "account"
    if general and type(general.favScope) == "string" and general.favScope ~= "" then
        scope = general.favScope
    end
    return scope
end

local function getFavoritesModule()
    return Nvk3UT and Nvk3UT.FavoritesData
end

function AchievementState.IsFavorited(achievementId)
    local normalized = normalizeAchievementId(achievementId)
    if not normalized then
        return false
    end

    local Fav = getFavoritesModule()
    if not (Fav and Fav.IsFavorited) then
        return false
    end

    local scope = resolveFavoritesScope()
    if Fav.IsFavorited(normalized, scope) then
        return true
    end

    if scope ~= "account" and Fav.IsFavorited(normalized, "account") then
        return true
    end

    if scope ~= "character" and Fav.IsFavorited(normalized, "character") then
        return true
    end

    return false
end

function AchievementState.SetFavorited(achievementId, shouldFavorite, source)
    local normalized = normalizeAchievementId(achievementId)
    if not normalized then
        return false
    end

    local Fav = getFavoritesModule()
    if not (Fav and Fav.SetFavorited) then
        return false
    end

    local desired = shouldFavorite and true or false
    local scope = resolveFavoritesScope()
    local changed = Fav.SetFavorited(normalized, desired, source, scope)
    if not changed then
        return false
    end

    emitDebugMessage(
        "favorite:%s id=%d scope=%s source=%s",
        desired and "add" or "remove",
        normalized,
        tostring(scope),
        tostring(source or "auto")
    )

    touchInternal(string.format("favorite:%d", normalized))
    return true
end

function AchievementState.TouchTimestamp(key, overrideTimestamp)
    return touchInternal(key, overrideTimestamp)
end

function AchievementState.GetTimestamp(key)
    if not key then
        return 0
    end

    local timestamps = ensureTimestampTable(false)
    if not timestamps then
        return 0
    end

    local value = timestamps[key]
    if type(value) ~= "number" then
        return 0
    end

    return value
end

return AchievementState
