-- CharacterMarkdown v2.2.8 - Core Namespace
-- Author: solaegis
--
-- Memory Management: This module implements efficient memory practices.
-- See docs/MEMORY_MANAGEMENT.md for detailed information on:
--   - Settings cache lifecycle and invalidation
--   - Event handler cleanup patterns
--   - Garbage collection strategies
--   - String building optimizations

CharacterMarkdown = CharacterMarkdown or {}
local CM = CharacterMarkdown

-- Debug: Confirm Core.lua is loading (safe method)
if _G.d then
    _G.d("|cFFFFFF[CharacterMarkdown] ========================================|r")
    _G.d("|cFFFFFF[CharacterMarkdown] Core.lua LOADING...|r")
    _G.d("|cFFFFFF[CharacterMarkdown] ========================================|r")
end

-- Addon metadata
CM.name = "CharacterMarkdown"
-- Initialize version - will be updated after addon loads when GetAddOnMetadata is available
CM.version = "2.2.8" -- Fallback version (replaced during build)
CM.author = "solaegis"
CM.apiVersion = 101050

-- Update version and metadata from manifest after addon loads
-- This function will be called from Events.lua after EVENT_ADD_ON_LOADED
function CM.UpdateVersion()
    if not GetAddOnMetadata then
        CM.DebugPrint("CORE", "GetAddOnMetadata not available yet")
        return false
    end

    -- Get version from manifest
    local version = GetAddOnMetadata(CM.name, "Version")
    if version and version ~= "" then
        if version == "2.2.8" then
            -- Placeholder detected - try to get version from Git or use fallback
            -- In development, this means the manifest hasn't been processed
            -- We'll keep the fallback version but log a warning
            CM.DebugPrint("CORE", "Version placeholder 2.2.8 detected - using fallback version")
            CM.DebugPrint(
                "CORE",
                string.format("Using fallback version: %s (placeholder not replaced - run 'task build')", CM.version)
            )
        else
            -- Valid version found - update it
            CM.version = version
            CM.DebugPrint("CORE", string.format("Version updated from manifest: %s", version))
        end
    else
        CM.DebugPrint("CORE", string.format("Version from manifest invalid or empty: %s", tostring(version)))
    end

    -- Also update author from manifest if available
    local author = GetAddOnMetadata(CM.name, "Author")
    if author and author ~= "" then
        CM.author = author
    end

    -- Also update API version from manifest if available
    local apiVersion = GetAddOnMetadata(CM.name, "APIVersion")
    if apiVersion and apiVersion ~= "" then
        local apiVersionNum = tonumber(apiVersion)
        if apiVersionNum then
            CM.apiVersion = apiVersionNum
            CM.DebugPrint("CORE", string.format("API version updated from manifest: %d", apiVersionNum))
        end
    end

    -- Also try to get API version from game API as verification/fallback
    if GetAPIVersion then
        local gameApiVersion = CM.SafeCall(GetAPIVersion)
        if gameApiVersion and gameApiVersion > 0 then
            if gameApiVersion ~= CM.apiVersion then
                CM.DebugPrint(
                    "CORE",
                    string.format("API version mismatch: manifest=%d, game=%d", CM.apiVersion, gameApiVersion)
                )
                -- Optionally update to match game API (uncomment if desired)
                -- CM.apiVersion = gameApiVersion
            else
                CM.DebugPrint("CORE", string.format("API version verified: %d", gameApiVersion))
            end
        end
    end

    return true
end

-- Sub-namespaces
CM.utils = CM.utils or {}
CM.links = CM.links or {}
CM.collectors = CM.collectors or {}
CM.generators = CM.generators or {}
CM.commands = CM.commands or {}
CM.events = CM.events or {}
CM.Settings = CM.Settings or {}
CM.constants = CM.constants or {}

-- Constants
-- Champion Points Discipline Types
CM.constants.DisciplineType = {
    WARFARE = "Warfare",
    FITNESS = "Fitness",
    CRAFT = "Craft",
}

-- State management
-- CM.currentFormatter = "markdown" -- REMOVED: Strict enforcement
CM.isInitialized = false

-- Debug system with LibDebugLogger integration
local logger = LibDebugLogger and LibDebugLogger.Create(CM.name) or nil
CM.debug = false

-- Check if debug logging is enabled (lazy check)
local function IsDebugEnabled()
    return logger ~= nil or CM.debug == true
end

-- Optimized debug print with lazy evaluation
-- Usage: CM.DebugPrint("CATEGORY", function() return "expensive string format" end)
-- Or: CM.DebugPrint("CATEGORY", "simple message")
function CM.DebugPrint(category, ...)
    -- Early return if debug not enabled (avoids string formatting)
    if not IsDebugEnabled() then
        return
    end

    local args = { ... }
    local parts = {}

    -- Lazy evaluation: if first arg is a function, call it to get the message
    if #args == 1 and type(args[1]) == "function" then
        local success, result = pcall(args[1])
        if success then
            parts[1] = tostring(result)
        else
            parts[1] = "Error in debug function: " .. tostring(result)
        end
    else
        -- Normal case: format all arguments
        for i, v in ipairs(args) do
            parts[i] = tostring(v)
        end
    end

    local message = table.concat(parts, " ")

    if logger then
        logger:Debug(string.format("[%s] %s", category or "CORE", message))
    elseif CM.debug then
        d(string.format("[CharacterMarkdown:%s]", category or "CORE"), message)
    end
end

-- Verbose logging (only when explicitly enabled)
function CM.Verbose(category, ...)
    if not IsDebugEnabled() then
        return
    end

    local args = { ... }
    local parts = {}

    -- Lazy evaluation support
    if #args == 1 and type(args[1]) == "function" then
        local success, result = pcall(args[1])
        if success then
            parts[1] = tostring(result)
        else
            parts[1] = "Error in verbose function: " .. tostring(result)
        end
    else
        for i, v in ipairs(args) do
            parts[i] = tostring(v)
        end
    end

    local message = table.concat(parts, " ")

    if logger then
        logger:Verbose(string.format("[%s] %s", category or "CORE", message))
    elseif CM.debug then
        CM.DebugPrint(category, message)
    end
end

local function NormalizeLogMessage(message)
    local text = message
    if text == nil then
        return "(no message)"
    end
    text = tostring(text)
    if text == "" or text:match("^%s*$") then
        return "(no message)"
    end
    return text
end

local function ShouldLogToLibDebugLogger()
    if not logger then
        return false
    end
    if logger.IsEnabled then
        return logger:IsEnabled()
    end
    return true
end

function CM.Info(message)
    local text = NormalizeLogMessage(message)
    if ShouldLogToLibDebugLogger() then
        logger:Info(text)
    end
    d("|cFFFFFF[CharacterMarkdown]|r " .. text)
end

function CM.Warn(message)
    local text = NormalizeLogMessage(message)
    if ShouldLogToLibDebugLogger() then
        logger:Warn(text)
    end
    d("|cFFFF00[CharacterMarkdown] WARNING:|r " .. tostring(text))
end

function CM.Error(message)
    local text = NormalizeLogMessage(message)
    if ShouldLogToLibDebugLogger() then
        logger:Error(text)
    end
    d("|cFF0000[CharacterMarkdown] ERROR:|r " .. tostring(text))
end

function CM.Success(message)
    local text = NormalizeLogMessage(message)
    if ShouldLogToLibDebugLogger() then
        logger:Info(text)
    end
    d("|c00FF00[CharacterMarkdown]|r " .. text)
end

-- Cache frequently used globals for performance
CM.cached = {
    EVENT_MANAGER = EVENT_MANAGER,
    string_format = string.format,
    string_gsub = string.gsub,
    string_sub = string.sub,
    string_len = string.len,
    string_lower = string.lower,
    string_upper = string.upper,
    table_insert = table.insert,
    table_concat = table.concat,
    math_floor = math.floor,
    math_ceil = math.ceil,
    math_min = math.min,
    math_max = math.max,
    zo_callLater = zo_callLater,
    zo_strformat = zo_strformat,
}

-- Safe call wrapper for functions returning a single value
-- Use this for ESO API calls that return a single value
-- Returns nil on error, the result on success
--
-- Example:
--   local health = CM.SafeCall(GetPlayerStat, STAT_HEALTH_MAX) or 0
function CM.SafeCall(func, ...)
    local success, result = CM.SafeCallMulti(func, ...)
    if success then
        return result
    end
    return nil
end

-- Safe call wrapper for functions returning multiple values
-- Use this for ESO API calls that return multiple values (e.g., GetJournalQuestInfo)
-- Returns success (boolean), followed by the function's return values
--
-- Example:
--   local success, questName, level, stepText = CM.SafeCallMulti(GetJournalQuestInfo, questIndex)
--   if not success then
--       CM.Error("Failed to get quest info: " .. tostring(questName))
--       return
--   end
function CM.SafeCallMulti(func, ...)
    -- Check if function exists before calling
    if not func or type(func) ~= "function" then
        local errorMsg = string.format("SafeCallMulti: function is nil or not a function (type=%s)", type(func))
        CM.DebugPrint("SAFECALL", function()
            return errorMsg
        end)
        return false, errorMsg
    end

    -- Forward "..." directly to pcall (no intermediate args table) so input args
    -- containing nils are not truncated. Capture the exact return count with
    -- select("#") so returns with nil "holes" (e.g. GetSkillAbilityUpgradeInfo,
    -- GetMailItemInfo) are not silently dropped by unpack's undefined length.
    local function capture(ok, ...)
        return ok, select("#", ...), { ... }
    end

    local pcallOk, count, results = capture(pcall(func, ...))
    if not pcallOk then
        local errorMsg = results[1]
        CM.DebugPrint("SAFECALL", function()
            return string.format("Error in SafeCallMulti: %s", tostring(errorMsg))
        end)
        return false, errorMsg
    end

    return true, unpack(results, 1, count)
end

-- Validate required modules loaded
function CM.ValidateModules()
    local required = { "utils", "links", "collectors", "generators", "commands", "events" }
    local allLoaded = true

    for _, module in ipairs(required) do
        if not CM[module] then
            CM.Error(string.format("Required module '%s' not loaded!", module))
            allLoaded = false
        end
    end

    return allLoaded
end

-- Settings cache for merged settings (performance optimization)
local settingsCache = nil
local settingsCacheTimestamp = 0
local SETTINGS_CACHE_VERSION = 1 -- Increment when cache structure changes

-- Invalidate settings cache (call when settings change)
function CM.InvalidateSettingsCache()
    settingsCache = nil
    settingsCacheTimestamp = 0
end

-- Unified settings access helper
-- Always returns a valid settings table, merging SavedVariables with defaults
-- This ensures settings are NEVER nil - they're always true or false, never nil
-- CACHED: Merged settings are cached to avoid repeated merging on every call
--
-- USAGE PATTERN:
--   - For READING settings: Always use CM.GetSettings() (this is the single source of truth)
--   - For WRITING settings: Write directly to CharacterMarkdownSettings[key] = value,
--     then update _lastModified timestamp and call CM.InvalidateSettingsCache()
--
-- Example (reading):
--   local settings = CM.GetSettings()
--   if settings.includeChampionPoints then ...
--
-- Example (writing):
--   CharacterMarkdownSettings.includeChampionPoints = true
--   CharacterMarkdownSettings._lastModified = GetTimeStamp()
--   CM.InvalidateSettingsCache()
function CM.GetSettings()
    local settings = CharacterMarkdownSettings
    if not settings then
        -- Return defaults if settings not available
        if CM.Settings and CM.Settings.Defaults then
            return CM.Settings.Defaults:GetAll()
        else
            -- Last resort: return empty table
            return {}
        end
    end

    -- Check cache validity using timestamp
    -- Cache is invalid if settings have been modified (via _lastModified timestamp)
    local currentTimestamp = settings._lastModified or 0
    if settingsCache and settingsCacheTimestamp == currentTimestamp then
        return settingsCache
    end

    -- CRITICAL: Merge with defaults to ensure no nil values
    -- This guarantees that every setting is either true or false, never nil
    if CM.Settings and CM.Settings.Defaults then
        local defaults = CM.Settings.Defaults:GetAll()
        local merged = {}

        -- First, copy all defaults
        for key, defaultValue in pairs(defaults) do
            merged[key] = defaultValue
        end

        -- Then, overlay saved values (which may be true, false, or other types)
        -- IMPORTANT: We must overlay ALL saved values, including false, to respect user settings
        for key, savedValue in pairs(settings) do
            -- Only merge keys that exist in defaults (ignore internal keys like _metadata, filters, etc.)
            if defaults[key] ~= nil then
                -- Overlay saved value (even if it's false - this respects user's disabled settings)
                merged[key] = savedValue
            end
        end

        -- Cache the merged result
        settingsCache = merged
        settingsCacheTimestamp = currentTimestamp

        return merged
    end

    -- Fallback: return raw settings (shouldn't happen if defaults are available)
    return settings
end

-- Unified link creation
function CM.CreateLink(text, linkType, format)
    if not text or text == "" or text == "[Empty]" or text == "[Empty Slot]" or text == "Unknown" then
        return text or ""
    end

    local settings = CM.GetSettings()
    local linksEnabled = true

    if linkType == "ability" and settings.enableAbilityLinks == false then
        linksEnabled = false
    elseif linkType == "set" and settings.enableSetLinks == false then
        linksEnabled = false
    end

    if not linksEnabled then
        return text
    end

    local urlText = text

    -- Clean ability names (remove rank suffixes)
    if linkType == "ability" then
        urlText = urlText:gsub("%s+IV$", ""):gsub("%s+III$", ""):gsub("%s+II$", ""):gsub("%s+I$", "")
    end

    -- Clean mundus stone names
    if linkType == "mundus" then
        urlText = urlText:gsub("^The ", ""):gsub("^Boon: The ", ""):gsub("^Boon: ", "")
    end

    urlText = urlText:gsub(" ", "_"):gsub("[%(%)%[%]%{%}]", "")

    local url = "https://en.uesp.net/wiki/Online:" .. urlText
    return "[" .. text .. "](" .. url .. ")"
end

if logger then
    logger:Info("LibDebugLogger initialized for CharacterMarkdown")
    logger:SetEnabled(false)
end

CM.DebugPrint("INIT", "Core namespace initialized")
