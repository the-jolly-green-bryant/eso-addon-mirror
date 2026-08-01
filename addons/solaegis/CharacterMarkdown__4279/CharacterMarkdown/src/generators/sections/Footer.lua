-- CharacterMarkdown - Footer Section Generator
-- Generates markdown footer section

local CM = CharacterMarkdown

local markdown
local string_format = string.format

local function InitializeUtilities()
    if not markdown then
        markdown = CM.utils.markdown
    end
end

-- =====================================================
-- ICON LEGEND
-- =====================================================

local function GenerateLegend()
    if false then
        return ""
    end

    InitializeUtilities()

    local CreateStyledTable = markdown and markdown.CreateStyledTable
        or (CM.utils.markdown and CM.utils.markdown.CreateStyledTable)

    -- Section Icons table
    local sectionIconsTable = ""
    if CreateStyledTable then
        local sectionHeaders = { "Icon", "Meaning" }
        local sectionRows = {
            { "📋", "Overview & Summary" },
            { "💰", "Currency, Resources & Inventory" },
            { "⚔️", "PvP & Combat" },
            { "🎨", "Collectibles" },
            { "🏆", "Achievements & Titles" },
            { "⚡", "Equipment Enhancement" },
            { "🌍", "World Progress" },
            { "🏰", "Guilds, Armory & Undaunted" },
            { "🗺️", "DLC & Chapter Access" },
            { "🎯", "Champion Points" },
            { "🎯", "Attributes & Analysis" },
            { "🍖", "Active Buffs" },
            { "📈", "Progression & Statistics" },
            { "🌿", "Skill Morphs" },
            { "📜", "Character Progress" },
            { "👥", "Companion" },
            { "⚒️", "Craft Discipline" },
            { "💪", "Fitness Discipline" },
            { "⚔️", "Warfare Discipline" },
        }
        local sectionOptions = {
            alignment = { "left", "left" },
            format = nil,
            coloredHeaders = true,
        }
        sectionIconsTable = CreateStyledTable(sectionHeaders, sectionRows, sectionOptions)
    else
        -- Fallback
        sectionIconsTable =
            "| Icon | Meaning |\n|:-----|:--------|\n| 📋 | Overview & Summary |\n| 💰 | Currency, Resources & Inventory |\n| ⚔️ | PvP & Combat |\n| 🎨 | Collectibles |\n| 🏆 | Achievements & Titles |\n| ⚡ | Equipment Enhancement |\n| 🌍 | World Progress |\n| 🏰 | Guilds, Armory & Undaunted |\n| 🗺️ | DLC & Chapter Access |\n| 🎯 | Champion Points |\n| 🎯 | Attributes & Analysis |\n| 🍖 | Active Buffs |\n| 📈 | Progression & Statistics |\n| 🌿 | Skill Morphs |\n| 📜 | Character Progress |\n| 👥 | Companion |\n| ⚒️ | Craft Discipline |\n| 💪 | Fitness Discipline |\n| ⚔️ | Warfare Discipline |\n"
    end

    -- Status Indicators table
    local statusTable = ""
    if CreateStyledTable then
        local statusHeaders = { "Icon", "Meaning" }
        local statusRows = {
            { "✅", "Complete, Maxed, Good Status" },
            { "⚠️", "Warning, Needs Attention" },
            { "🔴", "Critical, High Priority" },
            { "🟡", "Medium Priority, Gold Quality" },
            { "🟢", "Low Priority, Green Quality" },
            { "🟣", "Purple Quality" },
            { "🟠", "Orange Quality" },
            { "⚪", "White Quality, Not Started" },
            { "🔄", "In Progress, Active" },
        }
        local statusOptions = {
            alignment = { "left", "left" },
            format = nil,
            coloredHeaders = true,
        }
        statusTable = CreateStyledTable(statusHeaders, statusRows, statusOptions)
    else
        -- Fallback
        statusTable =
            "| Icon | Meaning |\n|:-----|:--------|\n| ✅ | Complete, Maxed, Good Status |\n| ⚠️ | Warning, Needs Attention |\n| 🔴 | Critical, High Priority |\n| 🟡 | Medium Priority, Gold Quality |\n| 🟢 | Low Priority, Green Quality |\n| 🟣 | Purple Quality |\n| 🟠 | Orange Quality |\n| ⚪ | White Quality, Not Started |\n| 🔄 | In Progress, Active |\n"
    end

    -- Champion Points table
    local cpTable = ""
    if CreateStyledTable then
        local cpHeaders = { "Icon", "Meaning" }
        local cpRows = {
            { "⭐", "Slotted Slottable Star (Active)" },
            { "☆", "Unslotted Slottable Star (Has Points, Not Active)" },
            { "🔒", "Passive Skill (No Slotting Required)" },
        }
        local cpOptions = {
            alignment = { "left", "left" },
            format = nil,
            coloredHeaders = true,
        }
        cpTable = CreateStyledTable(cpHeaders, cpRows, cpOptions)
    else
        -- Fallback
        cpTable =
            "| Icon | Meaning |\n|:-----|:--------|\n| ⭐ | Slotted Slottable Star (Active) |\n| ☆ | Unslotted Slottable Star (Has Points, Not Active) |\n| 🔒 | Passive Skill (No Slotting Required) |\n"
    end

    -- Attributes table
    local attrTable = ""
    if CreateStyledTable then
        local attrHeaders = { "Icon", "Meaning" }
        local attrRows = {
            { "🔵", "Magicka" },
            { "❤️", "Health" },
            { "⚡", "Stamina" },
        }
        local attrOptions = {
            alignment = { "left", "left" },
            format = nil,
            coloredHeaders = true,
        }
        attrTable = CreateStyledTable(attrHeaders, attrRows, attrOptions)
    else
        -- Fallback
        attrTable =
            "| Icon | Meaning |\n|:-----|:--------|\n| 🔵 | Magicka |\n| ❤️ | Health |\n| ⚡ | Stamina |\n"
    end

    -- Investment Levels table
    local investTable = ""
    if CreateStyledTable then
        local investHeaders = { "Icon", "Meaning" }
        local investRows = {
            { "🔥", "Very High (1500+ CP)" },
            { "⭐", "High (1200+ CP)" },
            { "💪", "Medium-High (800+ CP)" },
            { "📈", "Medium (400+ CP)" },
            { "🌱", "Low (<400 CP)" },
        }
        local investOptions = {
            alignment = { "left", "left" },
            format = nil,
            coloredHeaders = true,
        }
        investTable = CreateStyledTable(investHeaders, investRows, investOptions)
    else
        -- Fallback
        investTable =
            "| Icon | Meaning |\n|:-----|:--------|\n| 🔥 | Very High (1500+ CP) |\n| ⭐ | High (1200+ CP) |\n| 💪 | Medium-High (800+ CP) |\n| 📈 | Medium (400+ CP) |\n| 🌱 | Low (<400 CP) |\n"
    end

    return string_format(
        [[
---

## 📖 Icon Legend

<table style="width: 100%%; border-collapse: collapse;">
<tr>
<td style="vertical-align: top; padding: 0 15px; width: 50%%;">

### Section Icons
%s

</td>
<td style="vertical-align: top; padding: 0 15px; width: 50%%;">

### Status Indicators
%s

### Champion Points
%s

### Attributes
%s

### Investment Levels
%s

</td>
</tr>
</table>

---
]],
        sectionIconsTable,
        statusTable,
        cpTable,
        attrTable,
        investTable
    )
end

-- =====================================================
-- FOOTER
-- =====================================================

local function GenerateFooter(contentLength)
    InitializeUtilities()

    -- Enhanced visuals are now always enabled (baseline)

    if false then
        return ""
    end

    -- Use ESO API for timestamp (os.date() is disabled in ESO Lua)
    local timestamp = ""
    local timeSuccess, timeStamp = pcall(GetTimeStamp)
    if timeSuccess and timeStamp then
        local dateSuccess, dateString = pcall(GetDateStringFromTimestamp, timeStamp)
        if dateSuccess and dateString then
            timestamp = dateString
        else
            timestamp = "unknown time"
        end
    else
        timestamp = "unknown time"
    end

    local formatNumber = CM.utils and CM.utils.FormatNumber
    local safeFormatNumber = function(val)
        if formatNumber then
            return formatNumber(val)
        else
            return tostring(val)
        end
    end

    if false then
        -- Classic format (Discord block removed)
    end

    -- ENHANCED: Use separator and attractive footer (only if markdown utilities are available)
    if not markdown then
        -- Fallback to classic if markdown utilities not loaded
        return string.format(
            [[
*Generated by CharacterMarkdown (%s) on %s*  
*Total size: ~%s characters*
]],
            "MARKDOWN",
            timestamp,
            safeFormatNumber(contentLength or 0)
        )
    end

    -- Create attractive footer with badges and centered layout
    local formatBadge = markdown.CreateBadge("Format", "MARKDOWN", "blue", "flat")
    local sizeBadge = markdown.CreateBadge("Size", safeFormatNumber(contentLength or 0) .. " chars", "purple", "flat")

    local badgeRow = string_format("%s %s", formatBadge, sizeBadge)

    -- Get padding size from constants (same as chunks use: 85 spaces + 2 newlines)
    local CHUNKING = CM.constants and CM.constants.CHUNKING
    local paddingSize = (CHUNKING and CHUNKING.SPACE_PADDING_SIZE) or 85
    local spacePadding = string.rep(" ", paddingSize)

    local version = CM.version or "unknown"
    local footerContent = string_format(
        [[
<div align="center">

%s

**⚔️ CharacterMarkdown by @solaegis**

<sub>Generated on %s • Version: %s</sub>

</div>
%s

]],
        badgeRow,
        timestamp,
        version,
        spacePadding
    )

    return footerContent
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateFooter = GenerateFooter
CM.generators.sections.GenerateLegend = GenerateLegend

CM.DebugPrint("GENERATOR", "Footer section generator loaded (enhanced visuals)")
