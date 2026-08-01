-- CharacterMarkdown - Outfit Styles Section Generator
-- Generates markdown for outfit styles and collections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateAnchor, CreateStyleLink
local string_format = string.format

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
        CreateStyleLink = CM.links and CM.links.CreateStyleLink
    end
end

local function GenerateStyles(stylesData)
    InitializeUtilities()
    local settings = CM.GetSettings()

    if not stylesData or (stylesData.count or 0) == 0 then
        return ""
    end

    local markdown = ""
    local anchorId = GenerateAnchor and GenerateAnchor("🧥 Outfit Styles") or "outfit-styles"
    markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
    markdown = markdown .. "## 🧥 Outfit Styles\n\n"

    local totalUnlocked = stylesData.count or 0
    markdown = markdown .. "<details>\n"
    markdown = markdown .. string_format("<summary>🧥 Acquired Styles (%d Unlocked)</summary>\n\n", totalUnlocked)

    markdown = markdown .. "**Total Unlocked:** " .. totalUnlocked .. "\n\n"

    if settings.showStylesDetailed and stylesData.categories and stylesData.categories.all then
        markdown = markdown .. "### 📚 Style Collection\n\n"
        for _, style in ipairs(stylesData.categories.all) do
            local displayName = (CreateStyleLink and CreateStyleLink(style.name)) or style.name
            markdown = markdown .. "- " .. displayName .. "\n"
        end
    else
        markdown = markdown
            .. "*Detailed list disabled. Enable 'Detailed Styles' in settings to see all acquired styles.*\n"
    end

    markdown = markdown .. "\n</details>\n\n"

    -- Use CreateSeparator for consistent separator styling
    local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
    if CreateSeparator then
        markdown = markdown .. CreateSeparator("hr")
    else
        markdown = markdown .. "---\n\n"
    end

    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateStyles = GenerateStyles
