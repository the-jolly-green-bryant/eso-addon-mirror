-- CharacterMarkdown - Advanced Markdown Utilities
-- Implements GitHub callouts, badges, collapsible sections, styled tables, and visual enhancements
-- Based on: https://github.com/DavidWells/advanced-markdown

local CM = CharacterMarkdown
CM.utils = CM.utils or {}
CM.utils.markdown = CM.utils.markdown or {}

-- Localize frequently used functions for performance
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match
local string_rep = string.rep
local table_concat = table.concat
local math_max = math.max

-- =====================================================
-- GITHUB CALLOUTS (Native Markdown Alerts)
-- =====================================================
-- GitHub/GitLab/Azure DevOps native callout syntax:
-- > [!NOTE], > [!TIP], > [!IMPORTANT], > [!WARNING], > [!CAUTION]

local CALLOUT_TYPES = {
    note = {
        tag = "NOTE",
        emoji = "ℹ️",
        desc = "Information that users should take into account",
    },
    tip = {
        tag = "TIP",
        emoji = "💡",
        desc = "Optional information to help user success",
    },
    important = {
        tag = "IMPORTANT",
        emoji = "❗",
        desc = "Crucial information necessary for users to succeed",
    },
    warning = {
        tag = "WARNING",
        emoji = "⚠️",
        desc = "Critical content demanding immediate attention",
    },
    caution = {
        tag = "CAUTION",
        emoji = "🔥",
        desc = "Negative potential consequences of an action",
    },
    success = {
        tag = "TIP", -- Map to TIP for GitHub compatibility
        emoji = "✅",
        desc = "Successful completion or positive outcome",
    },
    danger = {
        tag = "CAUTION", -- Map to CAUTION for GitHub compatibility
        emoji = "❌",
        desc = "Critical danger or failure state",
    },
}

--[[
    Create a GitHub-native callout box
    @param type string - "note", "tip", "important", "warning", "caution", "success", "danger"
    @param content string - The content to display in the callout
    @return string - Formatted callout
]]
local function CreateCallout(type, content)
    if not content or content == "" then
        return ""
    end

    local callout = CALLOUT_TYPES[type] or CALLOUT_TYPES.note

    -- Escape newlines in content for proper rendering
    -- Prefix all lines (including first) with "> "
    local escaped_content = string_gsub(content, "\n", "\n> ")
    -- Ensure first line also has "> " prefix
    if not string_match(escaped_content, "^> ") then
        escaped_content = "> " .. escaped_content
    end

    -- Always use GitHub-native callout syntax
    return string_format("> [!%s]\n%s\n\n", callout.tag, escaped_content)
end

CM.utils.markdown.CreateCallout = CreateCallout

-- =====================================================
-- BADGES (shields.io style)
-- =====================================================

--[[
    Create a badge using shields.io
    @param label string - Badge label
    @param value string or number - Badge value
    @param color string - Badge color (blue, green, red, yellow, orange, purple, etc.)
    @param style string - Badge style ("flat", "flat-square", "plastic", "for-the-badge")
    @return string - Markdown badge
]]
local function CreateBadge(label, value, color, style)
    color = color or "blue"
    style = style or "flat"

    -- Sanitize label and value: remove control characters and ensure they're strings
    local safe_label = tostring(label or "")
    local safe_value = tostring(value or "")

    -- Remove control characters that could break URLs
    safe_label = safe_label:gsub("[\r\n\t<>]", "")
    safe_value = safe_value:gsub("[\r\n\t<>]", "")

    -- URL-encode label and value (spaces to %20)
    local encoded_label = string_gsub(safe_label, " ", "%%20")
    local encoded_value = string_gsub(safe_value, " ", "%%20")

    -- Ensure URL is complete and valid
    local url =
        string_format("https://img.shields.io/badge/%s-%s-%s?style=%s", encoded_label, encoded_value, color, style)

    -- Validate URL is complete before returning
    if url:find("^https://img.shields.io/badge/") and url:find("?style=") then
        return string_format("![%s](<%s>)", safe_label, url)
    else
        -- Fallback: return plain text if URL generation fails
        return string_format("**%s:** %s", safe_label, safe_value)
    end
end

CM.utils.markdown.CreateBadge = CreateBadge

--[[
    Create a series of badges on one line
    @param badges table - Array of badge definitions {label, value, color, style}
    @param separator string - Separator between badges (default: " ")
    @return string - Space-separated badges
]]
local function CreateBadgeRow(badges, separator)
    separator = separator or " "
    local badge_strings = {}

    for _, badge in ipairs(badges) do
        table.insert(
            badge_strings,
            CreateBadge(
                badge.label or badge[1],
                badge.value or badge[2],
                badge.color or badge[3],
                badge.style or badge[4]
            )
        )
    end

    return table_concat(badge_strings, separator)
end

CM.utils.markdown.CreateBadgeRow = CreateBadgeRow

-- =====================================================
-- COLLAPSIBLE SECTIONS
-- =====================================================

--[[
    Create a collapsible HTML details section
    @param title string - Summary/title of the section
    @param content string - Content to show when expanded
    @param emoji string - Optional emoji prefix
    @param defaultOpen boolean - Whether section is open by default
    @return string - HTML details/summary block
]]
local function CreateCollapsible(title, content, emoji, defaultOpen)
    if not content or content == "" then
        return ""
    end

    local open_attr = defaultOpen and " open" or ""
    local emoji_prefix = emoji and (emoji .. " ") or ""

    return string_format(
        [[
<details%s>
<summary><strong>%s%s</strong></summary>

%s

</details>

]],
        open_attr,
        emoji_prefix,
        title,
        content
    )
end

CM.utils.markdown.CreateCollapsible = CreateCollapsible

-- =====================================================
-- ALIGNED CONTENT
-- =====================================================

--[[
    Create centered content block
    @param content string - Content to center
    @return string - HTML-centered content
]]
local function CreateCenteredBlock(content)
    if not content or content == "" then
        return ""
    end

    return string_format(
        [[
<div align="center">

%s

</div>

]],
        content
    )
end

CM.utils.markdown.CreateCenteredBlock = CreateCenteredBlock

-- =====================================================
-- CSS GRID MULTI-COLUMN LAYOUTS
-- =====================================================

--[[
    Create a 2-column layout using CSS Grid
    Works with GitHub markdown
    @param column1 string - Content for first column
    @param column2 string - Content for second column
    @param gap string - Gap between columns (default: "20px")
    @return string - HTML div with CSS Grid
]]
local function CreateTwoColumnLayout(column1, column2, gap)
    -- Check if both columns are nil or empty strings
    local col1Empty = not column1 or column1 == ""
    local col2Empty = not column2 or column2 == ""

    -- If both columns are empty, return empty string
    if col1Empty and col2Empty then
        return ""
    end

    -- If only one column is empty, return the non-empty one without layout
    if col1Empty then
        return column2
    end
    if col2Empty then
        return column1
    end

    gap = gap or "20px"

    return string_format(
        [[
<div style="display: grid; grid-template-columns: 1fr 1fr; gap: %s;">
<div>

%s

</div><div>

%s

</div>
</div>

]],
        gap,
        column1,
        column2
    )
end

CM.utils.markdown.CreateTwoColumnLayout = CreateTwoColumnLayout

--[[
    Create a 3-column layout using CSS Grid
    Works with GitHub markdown
    @param column1 string - Content for first column
    @param column2 string - Content for second column
    @param column3 string - Content for third column
    @param gap string - Gap between columns (default: "20px")
    @return string - HTML div with CSS Grid
]]
local function CreateThreeColumnLayout(column1, column2, column3, gap)
    -- Check if all columns are nil or empty strings
    local col1Empty = not column1 or column1 == ""
    local col2Empty = not column2 or column2 == ""
    local col3Empty = not column3 or column3 == ""

    -- If all columns are empty, return empty string
    if col1Empty and col2Empty and col3Empty then
        return ""
    end

    -- If only one or two columns have content, still use the layout but mark empty columns
    column1 = column1 or ""
    column2 = column2 or ""
    column3 = column3 or ""
    gap = gap or "20px"

    return string_format(
        [[
<div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: %s;">
<div>

%s

</div><div>

%s

</div><div>

%s

</div>
</div>

]],
        gap,
        column1,
        column2,
        column3
    )
end

CM.utils.markdown.CreateThreeColumnLayout = CreateThreeColumnLayout

--[[
    Create an N-column responsive layout using CSS Grid with auto-fit
    Works with GitHub markdown
    @param columns table - Array of content strings for each column
    @param minColumnWidth string - Minimum column width (default: "300px")
    @param gap string - Gap between columns (default: "20px")
    @return string - HTML div with CSS Grid
]]
local function CreateResponsiveColumns(columns, minColumnWidth, gap)
    if not columns or #columns == 0 then
        return ""
    end

    -- Check if all columns are empty
    local hasContent = false
    for _, content in ipairs(columns) do
        if content and content ~= "" then
            hasContent = true
            break
        end
    end

    -- If all columns are empty, return empty string
    if not hasContent then
        return ""
    end

    -- If only one column has content, return it directly
    if #columns == 1 then
        return columns[1] or ""
    end

    minColumnWidth = minColumnWidth or "300px"
    gap = gap or "20px"

    local gridStyle = string_format(
        "display: grid; grid-template-columns: repeat(auto-fit, minmax(%s, 1fr)); gap: %s;",
        minColumnWidth,
        gap
    )

    local parts = {}
    table.insert(parts, string_format('<div style="%s">\n', gridStyle))

    for _, content in ipairs(columns) do
        -- Ensure content is a valid string
        local safeContent = content or ""
        if type(safeContent) ~= "string" then
            safeContent = tostring(safeContent)
        end

        table.insert(parts, "<div>\n\n")
        table.insert(parts, safeContent)
        table.insert(parts, "\n\n</div>")
    end

    table.insert(parts, "\n</div>\n\n")

    local result = table_concat(parts, "")

    -- Validate that result contains proper HTML structure
    if result and result ~= "" then
        return result
    else
        -- Fallback: return empty string if result is invalid
        return ""
    end
end

CM.utils.markdown.CreateResponsiveColumns = CreateResponsiveColumns

-- =====================================================
-- FANCY BOXES & CARDS
-- =====================================================

-- =====================================================
-- VISUAL STAT BARS
-- =====================================================

--[[
    Create a progress bar with percentage
    @param current number - Current value
    @param max number - Maximum value
    @param width number - Character width of bar (default: 20)
    @param width number - Character width of bar (default: 20)
    @param label string - Optional label
    @return string - Text-based progress bar
]]
local function CreateProgressBar(current, max, width, label)
    if not current or not max or max == 0 then
        return ""
    end

    width = width or 20
    -- Style ignored, always standard string rep

    local percentage = math.floor((current / max) * 100)
    local filled = math.floor((percentage / 100) * width)
    local empty = width - filled

    -- STANDARDIZED: Always use █ (filled) and ░ (empty) for consistency across all sections
    local bar = string_rep("█", filled) .. string_rep("░", empty)

    if label then
        return string_format("%s: %s %d%% (%d/%d)", label, bar, percentage, current, max)
    else
        return string_format("%s %d%%", bar, percentage)
    end
end

CM.utils.markdown.CreateProgressBar = CreateProgressBar

-- =====================================================
-- VISUAL INDICATORS
-- =====================================================

--[[
    Get a visual indicator emoji based on completion/status
    @param value number - Current value
    @param max number - Maximum value
    @param thresholds table - Optional custom thresholds {complete, high, medium, low}
    @return string - Emoji indicator
]]
local function GetProgressIndicator(value, max, thresholds)
    if not value or not max or max == 0 then
        return "⚪"
    end

    thresholds = thresholds or { complete = 100, high = 75, medium = 50, low = 25 }
    local percentage = (value / max) * 100

    -- Using widely-supported emoji circles (🟢🟡🟠🔴 may not render on all systems)
    -- Fallback to simpler symbols for maximum compatibility
    if percentage >= thresholds.complete then
        return "🟢" -- Complete/Full (green circle - widely supported)
    elseif percentage >= thresholds.high then
        return "🟡" -- High/Almost full (yellow circle - widely supported)
    elseif percentage >= thresholds.medium then
        return "🟠" -- Medium/Half (orange circle - widely supported)
    elseif percentage >= thresholds.low then
        return "🔴" -- Low/Quarter (red circle - widely supported)
    else
        return "⚪" -- Empty/None (white circle - widely supported, changed from ⚫)
    end
end

CM.utils.markdown.GetProgressIndicator = GetProgressIndicator

--[[
    Get quality/tier indicator emoji
    @param quality string|number - Quality tier name ("legendary", "epic", etc.) or ESO quality constant
    @return string - Emoji indicator
]]
local function GetQualityIndicator(quality)
    -- Handle both string names and ESO constants
    local qualityString = quality
    if type(quality) == "number" then
        -- Convert constant to string using GetQualityColor
        if CM.utils and CM.utils.GetQualityColor then
            qualityString = CM.utils.GetQualityColor(quality)
        else
            return "⚪" -- Fallback if utility not available
        end
    end

    if not qualityString or qualityString == "" then
        return "⚪"
    end

    -- Using widely-supported quality indicators (avoiding newer colored squares)
    local indicators = {
        legendary = "⭐", -- Gold/Star (changed from 🟨 - more widely supported)
        epic = "💜", -- Purple heart (changed from 🟪 - more widely supported)
        artifact = "💜", -- Alias for epic
        superior = "💙", -- Blue heart (changed from 🟦 - more widely supported)
        arcane = "💙", -- Alias for superior
        fine = "💚", -- Green heart (changed from 🟩 - more widely supported)
        magic = "💚", -- Alias for fine
        normal = "⚪", -- White circle (changed from ⬜ - more widely supported)
        trash = "⚫", -- Black circle (changed from ⬛ - more widely supported)
        mythic = "💜✨", -- Purple heart with sparkle (more widely supported)
    }

    return indicators[qualityString:lower()] or "⚪"
end

CM.utils.markdown.GetQualityIndicator = GetQualityIndicator

-- =====================================================
-- FORMATTED LISTS
-- =====================================================

--[[
    Create a compact grid list (for currencies, small stats)
    @param items table - Array of {emoji, label, value}
    @param columns number - Number of columns (default: 4)
    @return string - HTML table or markdown list
]]

local function CreateCompactGrid(items, columns, align)
    if not items or #items == 0 then
        return ""
    end

    columns = columns or 4
    align = align or "center" -- Default to center for backwards compatibility

    -- Use native markdown table instead of HTML table
    -- Format: Simple table with emoji, value, and label in each cell (single line)
    local rows = {}
    local numRows = math.ceil(#items / columns)

    -- Create separator row with proper alignment
    local separatorRow = "|"
    for _ = 1, columns do
        if align == "left" then
            separatorRow = separatorRow .. ":---|"
        elseif align == "right" then
            separatorRow = separatorRow .. "---:|"
        else
            separatorRow = separatorRow .. ":---:|" -- Center (default)
        end
    end

    -- Build data rows
    for row = 1, numRows do
        local rowCells = {}
        for col = 1, columns do
            local idx = (row - 1) * columns + col
            if idx <= #items then
                local item = items[idx]
                -- Format as single line: emoji **value** label (pure markdown, no HTML)
                local cellContent = string_format("%s **%s** %s", item.emoji or "", item.value, item.label or "")
                -- Escape pipe characters in cell content
                cellContent = string_gsub(cellContent, "|", "\\|")
                table.insert(rowCells, cellContent)
            else
                table.insert(rowCells, "") -- Empty cell for incomplete rows
            end
        end

        -- Create markdown table row
        if row == 1 then
            -- First row: create empty header row
            local headerRow = "|"
            for _ = 1, columns do
                headerRow = headerRow .. " |"
            end
            table.insert(rows, headerRow)
            table.insert(rows, separatorRow)
        end

        -- Data row - pure markdown table format
        local dataRow = "| " .. table_concat(rowCells, " | ") .. " |"
        table.insert(rows, dataRow)
    end

    table.insert(rows, "\n")

    return table_concat(rows, "\n")
end

CM.utils.markdown.CreateCompactGrid = CreateCompactGrid

-- =====================================================
-- ENHANCED TABLES
-- =====================================================

--[[
    Create a styled table with optional colored headers for VSCode
    @param headers table - Array of header strings
    @param rows table - Array of row arrays
    @param options table|string - Options table or alignment array (for backward compatibility)
        - alignment: table of alignments per column ("left", "center", "right")
        - coloredHeaders: boolean
    @return string - Markdown or HTML table
]]
local function CreateStyledTable(headers, rows, options)
    if not headers or #headers == 0 then
        return ""
    end

    -- Handle backward compatibility: if options is array, treat as alignment
    local alignment
    if type(options) == "table" and options[1] ~= nil then
        -- Old-style: array of alignments
        alignment = options
    elseif type(options) == "table" then
        -- New-style: options table
        alignment = options.alignment or {}
    else
        -- No options provided
        alignment = {}
    end

    -- Bold all headers - Always use markdown bold
    local boldHeaders = {}

    for i, header in ipairs(headers) do
        -- Check if already bolded (markdown or HTML)
        local alreadyMarkdownBold = string.match(header, "^%*%*.*%*%*$")
        local alreadyHtmlBold = string.match(header, "^<strong>.*</strong>$")

        -- Use markdown bolding
        if alreadyMarkdownBold then
            boldHeaders[i] = header
        elseif alreadyHtmlBold then
            -- Convert HTML bold to markdown bold
            boldHeaders[i] = header:gsub("<strong>(.-)</strong>", "**%1**")
        else
            boldHeaders[i] = "**" .. header .. "**"
        end
    end

    -- Standard Markdown table (for all other cases)
    local lines = {}

    -- Header row
    table.insert(lines, "| " .. table_concat(boldHeaders, " | ") .. " |")

    -- Separator row with alignment
    local separators = {}
    for i = 1, #headers do
        local align = alignment[i] or "left"
        if align == "center" then
            table.insert(separators, ":---:")
        elseif align == "right" then
            table.insert(separators, "---:")
        else
            table.insert(separators, "---")
        end
    end
    table.insert(lines, "| " .. table_concat(separators, " | ") .. " |")

    -- Normalize rows: accept a single flat row (array of cell strings) by mistake
    local normalizedRows = rows
    if type(rows) == "table" and #rows > 0 and type(rows[1]) ~= "table" then
        normalizedRows = { rows }
    end

    -- Data rows
    for rowIndex = 1, #normalizedRows do
        local row = normalizedRows[rowIndex]
        if type(row) ~= "table" then
            row = { tostring(row or "") }
        end

        local escapedRow = {}
        local columnCount = math_max(#headers, #row)
        for colIndex = 1, columnCount do
            local cell = row[colIndex] or ""
            escapedRow[colIndex] = string_gsub(tostring(cell), "|", "\\|")
        end
        table.insert(lines, "| " .. table_concat(escapedRow, " | ") .. " |")
    end

    return table_concat(lines, "\n") .. "\n\n"
end

CM.utils.markdown.CreateStyledTable = CreateStyledTable

-- =====================================================
-- VISUAL SEPARATORS
-- =====================================================

--[[
    Create a visual section separator
    @param style string - "hr" (horizontal rule), "emoji", "box", "fade"
    @param emoji string - Optional emoji for emoji style
    @return string - Separator line
]]
local function CreateSeparator(style, emoji)
    style = style or "hr"

    if style == "hr" then
        return "---\n\n"
    elseif style == "emoji" then
        emoji = emoji or "⚔️"
        return string_format("\n%s %s %s\n\n", string_rep("━", 15), emoji, string_rep("━", 15))
    elseif style == "box" then
        return "\n" .. string_rep("═", 60) .. "\n\n"
    elseif style == "fade" then
        return "\n・・・\n\n"
    else
        return "\n\n"
    end
end

CM.utils.markdown.CreateSeparator = CreateSeparator

-- =====================================================
-- TEXT FORMATTING & ANCHORS
-- =====================================================

--[[
    Generate a GitHub-compatible anchor from header text
    Removes emojis and special characters, converts to lowercase kebab-case
    @param text string - Header text
    @return string - Anchor ID
]]
local function GenerateAnchor(text)
    if not text then
        return ""
    end

    -- Keep only ASCII letters, numbers, spaces, and basic punctuation
    -- This removes emojis and other Unicode characters
    local anchor = ""
    for i = 1, #text do
        local byte = text:byte(i)
        if
            (byte >= 48 and byte <= 57) -- 0-9
            or (byte >= 65 and byte <= 90) -- A-Z
            or (byte >= 97 and byte <= 122) -- a-z
            or byte == 32
            or byte == 45
        then -- space or hyphen
            anchor = anchor .. text:sub(i, i)
        end
    end

    -- Convert to lowercase and replace spaces with hyphens
    anchor = anchor:lower():gsub("%s+", "-")

    -- Remove leading/trailing hyphens and collapse multiple hyphens
    anchor = anchor:gsub("^%-+", ""):gsub("%-+$", ""):gsub("%-%-+", "-")

    return anchor
end

CM.utils.markdown.GenerateAnchor = GenerateAnchor

--[[
    Create a header with emoji, optional subtitle, and HTML anchor for universal markdown support
    @param title string - Main title
    @param emoji string - Optional emoji prefix
    @param subtitle string - Optional subtitle
    @param level number - Header level (1-6, default: 2)
    @param skipAnchor boolean - Skip anchor generation (default: false)
    @return string - Formatted header with HTML anchor
]]
local function CreateHeader(title, emoji, subtitle, level, skipAnchor)
    level = level or 2
    local prefix = string_rep("#", level)
    local emoji_prefix = emoji and (emoji .. " ") or ""

    -- Generate anchor ID from title (without emoji)
    local anchorId = ""
    if not skipAnchor then
        -- Create anchor from emoji + title for consistency with TOC
        local fullTitle = (emoji and (emoji .. " ") or "") .. title
        anchorId = GenerateAnchor(fullTitle)
    end

    -- Build header with HTML anchor for universal markdown support
    local header = ""
    if not skipAnchor and anchorId ~= "" then
        header = string_format('<a id="%s"></a>\n\n', anchorId)
    end
    header = header .. string_format("%s %s%s\n\n", prefix, emoji_prefix, title)

    if subtitle and subtitle ~= "" then
        header = header .. string_format("*%s*\n\n", subtitle)
    end

    return header
end

CM.utils.markdown.CreateHeader = CreateHeader

--[[
    Create attention needed/warning section with format-specific styling
    @param warnings table - Array of warning message strings
    @param format string - Format type ("github", "vscode", "discord", "quick")
    @param headerTitle string - Optional header title (default: "Attention Needed")
    @return string - Formatted warnings section (GitHub callout for github format, table for others)
]]
local function CreateAttentionNeeded(warnings, format, headerTitle)
    if not warnings or #warnings == 0 then
        return ""
    end

    local hTitle = headerTitle or "Attention Needed"
    -- format = format or "github"

    -- Always use GitHub-native callout syntax for warnings
    -- Use bullet points for proper list rendering inside the callout
    local result = string_format("> [!WARNING]\n> **%s**\n", hTitle)
    for _, warning in ipairs(warnings) do
        result = result .. "> - " .. warning .. "\n"
    end
    result = result .. "\n"
    return result
end

CM.utils.markdown.CreateAttentionNeeded = CreateAttentionNeeded

--[[
    Format text with multiple styles
    @param text string - Text to format
    @param styles table - Array of style names: "bold", "italic", "code", "strikethrough"
    @param format string - Target format ("github", "vscode", "discord") - defaults to "github"
    @return string - Formatted text
]]
local function FormatText(text, styles, format)
    if not text or text == "" then
        return ""
    end
    if not styles or #styles == 0 then
        return text
    end

    -- format = format or "github"
    local result = text

    for _, style in ipairs(styles) do
        if style == "bold" then
            result = "**" .. result .. "**"
        elseif style == "italic" then
            result = "*" .. result .. "*"
        elseif style == "code" then
            result = "`" .. result .. "`"
        elseif style == "strikethrough" then
            result = "~~" .. result .. "~~"
        elseif style == "underline" then
            result = "<ins>" .. result .. "</ins>"
        elseif style == "highlight" then
            result = "<mark>" .. result .. "</mark>"
        end
    end

    return result
end

CM.utils.markdown.FormatText = FormatText

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint(
    "UTILS",
    "AdvancedMarkdown module loaded with " .. "callouts, badges, collapsible sections, progress bars, and styled tables"
)

-- Functions are already exported to CM.utils.markdown above
-- No need to return (this is not a module requiring return)
