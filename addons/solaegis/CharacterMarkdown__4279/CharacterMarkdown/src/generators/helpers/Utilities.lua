-- CharacterMarkdown - Generator Utilities
-- Helper functions for markdown generation

local CM = CharacterMarkdown

-- =====================================================
-- PROGRESS BAR GENERATION
-- =====================================================

-- Generate a text-based progress bar
-- Uses standardized blocks (█) for filled and (░) for empty (Issue #6 fix)
local function GenerateProgressBar(percent, width)
    width = width or 10
    local filled = math.floor((percent / 100) * width)
    local empty = width - filled
    return string.rep("█", filled) .. string.rep("░", empty)
end

-- =====================================================
-- STATUS INDICATORS
-- =====================================================

-- Create a compact skill status indicator
-- Using widely-supported emojis for maximum compatibility
local function GetSkillStatusEmoji(rank, progress)
    if rank >= 50 or progress >= 100 then
        return "✅"
    elseif rank >= 40 or progress >= 80 then
        return "🟠" -- Changed from 🔶 (orange diamond) to 🟠 (orange circle - more widely supported)
    elseif rank >= 20 or progress >= 40 then
        return "📈"
    else
        return "🔰" -- Keeping 🔰 (widely supported in modern systems)
    end
end

-- =====================================================
-- TEXT FORMATTING
-- =====================================================

-- Format plural correctly
local function Pluralize(count, singular, plural)
    plural = plural or (singular .. "s")
    return count == 1 and singular or plural
end

-- =====================================================
-- SECTION GENERATOR HELPERS
-- =====================================================

-- Generate section header with anchor
-- @param name: Section name (e.g., "Champion Points")
-- @param emoji: Optional emoji prefix (e.g., "⭐")
-- @param emoji: Optional emoji prefix (e.g., "⭐")
-- @return: Formatted header string
local function GenerateSectionHeader(name, emoji)
    -- GitHub format with anchor
    local markdown = CM.utils and CM.utils.markdown
    local anchorId = markdown and markdown.GenerateAnchor and markdown.GenerateAnchor(name)
        or name:lower():gsub("[^%w]+", "-")
    local header = ""
    if anchorId then
        header = string.format('<a id="%s"></a>\n\n', anchorId)
    end
    local title = name
    if emoji then
        title = emoji .. " " .. title
    end
    header = header .. "## " .. title .. "\n\n"
    return header
end

-- Handle empty data case with consistent messaging
-- @param message: Message to display when data is empty
-- @param sectionName: Optional section name for header
-- @param emoji: Optional emoji for header
-- @return: Formatted empty state message
local function HandleEmptyData(message, sectionName, emoji)
    local header = ""
    if sectionName then
        local markdown = CM.utils and CM.utils.markdown
        local anchorId = markdown and markdown.GenerateAnchor and markdown.GenerateAnchor(sectionName)
            or sectionName:lower():gsub("[^%w]+", "-")
        if anchorId then
            header = string.format('<a id="%s"></a>\n\n', anchorId)
        end
        local title = sectionName
        if emoji then
            title = emoji .. " " .. title
        end
        header = header .. "## " .. title .. "\n\n"
    end
    return header .. "*" .. message .. "*\n\n---\n\n"
end

-- Format section footer (separator)
-- @return: Footer separator string
local function FormatSectionFooter()
    -- Use CreateSeparator for consistent separator styling
    local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
    if CreateSeparator then
        return CreateSeparator("hr")
    else
        return "---\n\n"
    end
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.helpers = CM.generators.helpers or {}
CM.generators.helpers.GenerateProgressBar = GenerateProgressBar
CM.generators.helpers.GetSkillStatusEmoji = GetSkillStatusEmoji
CM.generators.helpers.Pluralize = Pluralize
CM.generators.helpers.GenerateSectionHeader = GenerateSectionHeader
CM.generators.helpers.HandleEmptyData = HandleEmptyData
CM.generators.helpers.FormatSectionFooter = FormatSectionFooter
