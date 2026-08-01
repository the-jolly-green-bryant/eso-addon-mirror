-- CharacterMarkdown - Formatting Utilities
-- Number formatting, progress bars, callouts (ESO Guideline Compliant)

local CM = CharacterMarkdown

-- =====================================================
-- CACHED GLOBALS (PERFORMANCE)
-- =====================================================

local string_format = string.format
local string_gsub = string.gsub
local string_rep = string.rep
local math_floor = math.floor
local tostring = tostring

-- =====================================================
-- NUMBER FORMATTING
-- =====================================================

-- Format number with comma separators
local function FormatNumber(number)
    if not number then
        return "0"
    end

    local formatted = tostring(math_floor(number))
    local k

    while true do
        formatted, k = string_gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then
            break
        end
    end

    return formatted
end

CM.utils.FormatNumber = FormatNumber

-- =====================================================
-- PROGRESS BARS
-- =====================================================

-- Generate progress bar (10 blocks)
local function CreateProgressBar(percentage, style)
    if not percentage then
        return ""
    end

    -- Clamp percentage to 0-100
    percentage = math_floor(percentage)
    if percentage < 0 then
        percentage = 0
    end
    if percentage > 100 then
        percentage = 100
    end

    local filled = math_floor(percentage / 10)
    local empty = 10 - filled

    -- STANDARDIZED: Always use █ (filled) and ░ (empty) for consistency (Issue #6 fix)
    local bar = string_rep("█", filled) .. string_rep("░", empty)
    return bar .. " " .. percentage .. "%"
end

CM.utils.CreateProgressBar = CreateProgressBar

-- =====================================================
-- CALLOUT BOXES
-- =====================================================

-- Create callout box for markdown
local function CreateCallout(type, content, format)
    if not content or content == "" then
        return ""
    end

    local types = {
        info = { emoji = "ℹ️", color = "#0969da", title = "Info" },
        warning = { emoji = "⚠️", color = "#d29922", title = "Warning" },
        success = { emoji = "✅", color = "#1a7f37", title = "Success" },
        error = { emoji = "❌", color = "#d1242f", title = "Error" },
    }

    local info = types[type] or types.info

    -- Always use GitHub-style HTML blockquote for markdown
    return string_format(
        '<blockquote style="border-left: 4px solid %s; background: %s10; padding: 10px;">\n%s <strong>%s</strong>\n\n%s\n</blockquote>',
        info.color,
        info.color,
        info.emoji,
        info.title,
        content
    )
end

CM.utils.CreateCallout = CreateCallout

-- =====================================================
-- TEXT TRUNCATION (UTF-8 SAFE)
-- =====================================================

-- Safely truncate text at UTF-8 boundaries
local function SafeTruncate(str, maxBytes)
    if not str or str == "" then
        return ""
    end
    if not maxBytes or maxBytes <= 0 then
        return ""
    end

    local len = string.len(str)
    if len <= maxBytes then
        return str
    end

    -- Walk back to find valid UTF-8 boundary
    while maxBytes > 0 do
        local byte = string.byte(str, maxBytes)
        if not byte then
            break
        end

        -- Check if valid UTF-8 start byte
        -- Start bytes: 0xxxxxxx (ASCII) or 11xxxxxx (multi-byte start)
        if byte < 128 or byte >= 192 then
            break
        end

        maxBytes = maxBytes - 1
    end

    return string.sub(str, 1, maxBytes)
end

CM.utils.SafeTruncate = SafeTruncate

-- =====================================================
-- PLURALIZATION
-- =====================================================

-- Simple pluralization helper
local function Pluralize(count, singular, plural)
    if not count then
        return singular
    end

    plural = plural or (singular .. "s")
    return count == 1 and singular or plural
end

CM.utils.Pluralize = Pluralize

-- =====================================================
-- ESO COLOR CODE STRIPPING
-- =====================================================

-- Strip ESO color codes from strings (e.g., |cffffff75|r becomes empty)
-- Pattern: |c[0-9a-fA-F]{6}|r or |c[0-9a-fA-F]{8}|r (with alpha)
local function StripColorCodes(text)
    if not text or type(text) ~= "string" then
        return text or ""
    end

    -- Try ZO_ClearColor first (ESO built-in function)
    if ZO_ClearColor and type(ZO_ClearColor) == "function" then
        local success, cleared = pcall(ZO_ClearColor, text)
        if success and cleared then
            return cleared
        end
    end

    -- Fallback: manual pattern stripping
    -- Pattern: |c[hex/digits]|r
    -- ESO color codes can be: |cRRGGBB|r, |cRRGGBBAA|r, or |cRRGGBB[digits]|r
    -- FIX: The original pattern %%|c was wrong - it matches %|c, not |c
    -- In Lua patterns, | is only special in alternation, so we can use | directly
    -- However, to be safe and explicit, we use %| to escape the | character
    -- In string literals: "|c" works, but "%|c" is more explicit
    local stripped = text
    -- Strategy: Extract numbers from inside color codes before stripping
    -- Pattern like |cffffff230|r should become 230 (number preserved)
    -- First, extract and preserve numbers that appear after hex in color codes
    -- Match |c + 6 hex + digits + |r and replace with just the digits
    stripped =
        string_gsub(stripped, "|c[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]([0-9]+)|r", "%1")
    -- Now strip remaining color codes (standard format: |cRRGGBB|r or |cRRGGBBAA|r)
    stripped = string_gsub(
        stripped,
        "|c[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]?[0-9a-fA-F]?|r",
        ""
    )
    -- Catch-all: match |c followed by any non-| characters until |r (fallback)
    stripped = string_gsub(stripped, "|c[^|]*|r", "")
    return stripped
end

CM.utils.StripColorCodes = StripColorCodes

CM.DebugPrint("UTILS", "Formatters module loaded")
