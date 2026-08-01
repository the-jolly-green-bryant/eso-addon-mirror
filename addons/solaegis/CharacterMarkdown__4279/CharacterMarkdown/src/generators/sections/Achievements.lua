-- CharacterMarkdown - Achievement Markdown Generator
-- Phase 5: Comprehensive achievement tracking and display

local CM = CharacterMarkdown

-- =====================================================
-- UTILITIES
-- =====================================================

local function InitializeUtilities()
    if not CM.utils then
        CM.utils = {}
    end

    -- FormatNumber is already exported by Formatters.lua to CM.utils.FormatNumber
    -- Just create fallback if somehow not loaded
    if not CM.utils.FormatNumber then
        CM.utils.FormatNumber = function(num)
            if not num then
                return "0"
            end
            local formatted = tostring(num)
            return formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        end
    end

    -- GenerateProgressBar is exported by helpers/Utilities.lua
    if not CM.utils.GenerateProgressBar and CM.generators and CM.generators.helpers then
        CM.utils.GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
    end

    -- Fallback progress bar if helpers not loaded
    if not CM.utils.GenerateProgressBar then
        CM.utils.GenerateProgressBar = function(percent, width)
            width = width or 10
            local filled = math.floor((percent / 100) * width)
            local empty = width - filled
            return string.rep("█", filled) .. string.rep("░", empty)
        end
    end

    -- Load GenerateAnchor from markdown utils
    if not CM.utils.GenerateAnchor and CM.utils.markdown and CM.utils.markdown.GenerateAnchor then
        CM.utils.GenerateAnchor = CM.utils.markdown.GenerateAnchor
    end
end

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function GetAchievementStatusIcon(achievement)
    local progress = achievement.progress or {}
    if achievement.completed then
        return "✅"
    elseif progress.totalRequired > 0 and progress.totalProgress > 0 then
        return "🔄"
    else
        return "⚪"
    end
end

local function GetProgressText(achievement)
    local progress = achievement.progress or {}
    if achievement.completed then
        return "Completed"
    elseif progress.totalRequired > 0 then
        return string.format(
            "%d/%d (%d%%)",
            progress.totalProgress,
            progress.totalRequired,
            progress.progressPercent
        )
    else
        return "Not Started"
    end
end

local function GetCategoryEmoji(categoryName)
    local emojis = {
        ["Combat"] = "⚔️",
        ["PvP"] = "🏰",
        ["Exploration"] = "🗺️",
        ["Skyshards"] = "⭐",
        ["Lorebooks"] = "📚",
        ["Crafting"] = "⚒️",
        ["Economy"] = "💰",
        ["Social"] = "👥",
        ["Dungeons"] = "🏰", -- Changed from 🏛️ for better compatibility
        ["Character"] = "📈",
        ["Vampire"] = "🧛",
        ["Werewolf"] = "🐺",
        ["Collectibles"] = "🎨",
        ["Housing"] = "🏠",
        ["Events"] = "🎉",
        ["Miscellaneous"] = "🔧",
    }
    return emojis[categoryName] or "🔧"
end

-- =====================================================
-- ACHIEVEMENT SUMMARY GENERATOR
-- =====================================================

local function GenerateAchievementSummary(achievementData, format)
    InitializeUtilities()

    local markdown = ""
    local anchorId = CM.utils.GenerateAnchor and CM.utils.GenerateAnchor("🏆 Achievement Progress")
        or "achievement-progress"
    markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
    markdown = markdown .. "## 🏆 Achievement Progress\n\n"

    local summary = achievementData.summary

    -- Pivot table: metrics as columns, values as rows
    local rows = {
        { "Total Achievements", CM.utils.FormatNumber(summary.totalAchievements) },
        { "Completion %", summary.completionPercent .. "%" },
        { "Points Earned", CM.utils.FormatNumber(summary.earnedPoints) },
        { "Total Points", CM.utils.FormatNumber(summary.totalPoints) },
    }

    -- Transpose: convert rows to columns (without Metric/Value column)
    local transposedHeaders = {}
    local transposedRows = {}

    -- Headers: metric names only (no "Metric" column)
    for _, row in ipairs(rows) do
        table.insert(transposedHeaders, row[1])
    end

    -- Row: values only (no "Value" column)
    local valueRow = {}
    for _, row in ipairs(rows) do
        table.insert(valueRow, row[2])
    end
    table.insert(transposedRows, valueRow)

    local CreateStyledTable = CM.utils.markdown.CreateStyledTable
    local options = {
        alignment = { "right", "right", "right", "right", "right" },
        format = format,
        coloredHeaders = true,
    }
    markdown = markdown .. CreateStyledTable(transposedHeaders, transposedRows, options)

    return markdown
end

-- =====================================================
-- ACHIEVEMENT CATEGORIES GENERATOR
-- =====================================================

local function GenerateAchievementCategories(achievementData, format)
    InitializeUtilities()

    local markdown = ""

    local categories = achievementData.categories
    if not categories then
        return markdown
    end

    -- Check if there are any categories with data
    local hasCategories = false
    for _, categoryData in pairs(categories) do
        if categoryData.total > 0 then
            hasCategories = true
            break
        end
    end

    -- Only generate section if there are categories with data
    if not hasCategories then
        return markdown
    end

    markdown = markdown .. "### 📊 Achievement Categories\n\n"

    -- Collect and sort categories alphabetically
    local sortedCategories = {}
    for _, categoryData in ipairs(categories) do
        if categoryData.total > 0 then
            table.insert(sortedCategories, categoryData)
        end
    end
    table.sort(sortedCategories, function(a, b)
        return string.lower(a.name or "") < string.lower(b.name or "")
    end)

    local CreateStyledTable = CM.utils.markdown.CreateStyledTable
    local CreateResponsiveColumns = CM.utils.markdown.CreateResponsiveColumns

    for _, categoryData in ipairs(sortedCategories) do
        local categoryName = categoryData.name or "Unknown"
        local emoji = GetCategoryEmoji(categoryName)

        -- Category Header (Collapsible)
        markdown = markdown .. "<details>\n"
        markdown = markdown
            .. "<summary><strong>"
            .. emoji
            .. " "
            .. categoryName
            .. " ("
            .. categoryData.earned
            .. "/"
            .. categoryData.total
            .. " pts)</strong></summary>\n\n"

        local subcategoryTables = {}

        -- Check for subcategories
        if categoryData.subcategories and #categoryData.subcategories > 0 then
            -- Sort subcategories alphabetically
            table.sort(categoryData.subcategories, function(a, b)
                return string.lower(a.name or "") < string.lower(b.name or "")
            end)

            for _, sub in ipairs(categoryData.subcategories) do
                local subName = sub.name or "Unknown"
                local subPercent = sub.percent or 0
                local subBar = CM.utils.GenerateProgressBar(subPercent, 10)

                local headers = { subName, "Value" }
                local rows = {
                    { "Points", (sub.earned or 0) .. "/" .. (sub.total or 0) },
                    { "Progress", subBar .. " " .. subPercent .. "%" },
                }

                local tableContent = ""
                if CreateStyledTable then
                    local options = {
                        alignment = { "left", "right" },
                        format = format,
                        coloredHeaders = true,
                    }
                    tableContent = CreateStyledTable(headers, rows, options)
                else
                    -- Fallback: Use table.concat for performance
                    local parts = { "| " .. subName .. " | Value |", "|:---|---:|" }
                    for _, row in ipairs(rows) do
                        parts[#parts + 1] = "| " .. row[1] .. " | " .. row[2] .. " |"
                    end
                    tableContent = table.concat(parts, "\n") .. "\n\n"
                end

                table.insert(subcategoryTables, tableContent)
            end
        else
            -- Fallback: Create a single table for the category itself if no subcategories
            local percent = categoryData.total > 0 and math.floor((categoryData.earned / categoryData.total) * 100) or 0
            local progressBar = CM.utils.GenerateProgressBar(percent, 10)

            local headers = { "Metric", "Value" }
            local rows = {
                { "Completed", tostring(categoryData.earned) },
                { "Total", tostring(categoryData.total) },
                { "Points", tostring(categoryData.points or 0) },
                { "Progress", progressBar .. " " .. percent .. "%" },
            }

            local tableContent = ""
            if CreateStyledTable then
                local options = {
                    alignment = { "left", "right" },
                    format = format,
                    coloredHeaders = true,
                }
                tableContent = CreateStyledTable(headers, rows, options)
            else
                -- Fallback: Use table.concat for performance
                local parts = { "| Metric | Value |", "|:---|---:|" }
                for _, row in ipairs(rows) do
                    parts[#parts + 1] = "| " .. row[1] .. " | " .. row[2] .. " |"
                end
                tableContent = table.concat(parts, "\n") .. "\n\n"
            end
            table.insert(subcategoryTables, tableContent)
        end

        -- Layout subcategory tables
        if CreateResponsiveColumns and #subcategoryTables > 0 then
            -- Calculate optimal layout
            local LayoutCalculator = CM.utils.LayoutCalculator
            local minWidth, gap
            if LayoutCalculator then
                minWidth, gap = LayoutCalculator.GetLayoutParamsWithFallback(subcategoryTables, "250px", "20px")
            else
                minWidth = "250px"
                gap = "20px"
            end
            markdown = markdown .. CreateResponsiveColumns(subcategoryTables, minWidth, gap)
        else
            -- Fallback to sequential display
            for _, tableContent in ipairs(subcategoryTables) do
                markdown = markdown .. tableContent
            end
        end

        markdown = markdown .. "\n</details>\n\n"
    end

    return markdown
end

-- =====================================================
-- IN-PROGRESS ACHIEVEMENTS GENERATOR
-- =====================================================

local function GenerateInProgressAchievements(achievementData, format)
    InitializeUtilities()

    local markdown = ""
    markdown = markdown .. "### 🔄 In-Progress Achievements\n\n"

    local inProgress = achievementData.inProgress

    if #inProgress == 0 then
        markdown = markdown .. "*No achievements currently in progress*\n\n"
        return markdown
    end

    -- Group achievements by category, then by subcategory
    local categories = {}
    for _, achievement in ipairs(inProgress) do
        local category = achievement.category or "Miscellaneous"
        if not categories[category] then
            categories[category] = {}
        end

        -- Group by subcategory within category
        local subcategory = achievement.subcategory or "General"
        if not categories[category][subcategory] then
            categories[category][subcategory] = {}
        end
        table.insert(categories[category][subcategory], achievement)
    end

    -- Sort achievements by name within each subcategory
    for _, subcategories in pairs(categories) do
        for _, achievements in pairs(subcategories) do
            table.sort(achievements, function(a, b)
                return (a.name or "") < (b.name or "")
            end)
        end
    end

    -- Create styled tables for each category/subcategory
    -- Don't sort categories alphabetically - preserve order for better layout density
    local categoryOrder = {}
    for category, _ in pairs(categories) do
        table.insert(categoryOrder, category)
    end

    local CreateStyledTable = CM.utils.markdown.CreateStyledTable
    if CreateStyledTable then
        -- Create one table per subcategory, grouped by category
        local allTables = {}

        -- Process categories in order (no alphabetical sorting for better density)
        for _, category in ipairs(categoryOrder) do
            local subcategories = categories[category]
            local categoryEmoji = GetCategoryEmoji(category)

            -- Get subcategories and sort them alphabetically
            local subcategoryOrder = {}
            for subcategory, _ in pairs(subcategories) do
                table.insert(subcategoryOrder, subcategory or "General")
            end
            table.sort(subcategoryOrder, function(a, b)
                return string.lower(a or "") < string.lower(b or "")
            end)

            -- Create one table per subcategory
            for _, subcategory in ipairs(subcategoryOrder) do
                local achievements = subcategories[subcategory]
                if achievements and #achievements > 0 then
                    -- Sort achievements by name within subcategory
                    table.sort(achievements, function(a, b)
                        return (a.name or "") < (b.name or "")
                    end)

                    local headers = { "Achievement", "Progress", "Points" }
                    local rows = {}

                    for _, achievement in ipairs(achievements) do
                        local statusIcon = GetAchievementStatusIcon(achievement)
                        local progressText = GetProgressText(achievement)

                        -- Safely convert achievement.name to string (handle boolean/nil)
                        local achievementName = ""
                        if achievement.name then
                            if type(achievement.name) == "string" then
                                achievementName = achievement.name
                            else
                                CM.DebugPrint(
                                    "ACHIEVEMENTS",
                                    string.format(
                                        "Invalid achievement name in in-progress: name=%s (type=%s), id=%s",
                                        tostring(achievement.name),
                                        type(achievement.name),
                                        tostring(achievement.id)
                                    )
                                )
                                achievementName = tostring(achievement.name)
                            end
                        else
                            CM.DebugPrint(
                                "ACHIEVEMENTS",
                                string.format(
                                    "Missing achievement name in in-progress: id=%s",
                                    tostring(achievement.id)
                                )
                            )
                        end

                        table.insert(rows, {
                            statusIcon .. " **" .. achievementName .. "**",
                            progressText,
                            tostring(achievement.points or 0),
                        })
                    end

                    local options = {
                        alignment = { "left", "left", "right" },
                        format = format,
                        coloredHeaders = true,
                    }

                    -- Ensure category and subcategory are valid strings
                    local safeCategory = category or "Miscellaneous"
                    local safeSubcategory = subcategory or "General"
                    local safeCategoryEmoji = categoryEmoji or "🔧"

                    -- Create table with category as header and subcategory in title
                    local tableMarkdown = "#### " .. safeCategoryEmoji .. " " .. safeCategory .. "\n\n"
                    tableMarkdown = tableMarkdown .. "##### " .. safeSubcategory .. "\n\n"
                    local styledTable = CreateStyledTable(headers, rows, options)
                    if styledTable and styledTable ~= "" then
                        tableMarkdown = tableMarkdown .. styledTable
                        table.insert(allTables, tableMarkdown)
                    else
                        -- Fallback: log error and skip this table
                        CM.DebugPrint(
                            "ERROR",
                            string.format("Failed to create styled table for %s > %s", safeCategory, safeSubcategory)
                        )
                    end
                end
            end
        end

        -- Use multi-column layout for better density (no need to sort categories)
        local CreateResponsiveColumns = CM.utils.markdown.CreateResponsiveColumns
        if CreateResponsiveColumns and #allTables > 1 then
            -- Filter out any nil or empty entries
            local validTables = {}
            for _, tableContent in ipairs(allTables) do
                if tableContent and tableContent ~= "" then
                    table.insert(validTables, tableContent)
                end
            end

            if #validTables > 1 then
                -- Calculate optimal layout based on table content
                local LayoutCalculator = CM.utils.LayoutCalculator
                local minWidth, gap
                if LayoutCalculator then
                    minWidth, gap = LayoutCalculator.GetLayoutParamsWithFallback(
                        validTables,
                        #validTables > 6 and "300px" or "250px",
                        "20px"
                    )
                else
                    minWidth = #validTables > 6 and "300px" or "250px"
                    gap = "20px"
                end
                markdown = markdown .. CreateResponsiveColumns(validTables, minWidth, gap)
            elseif #validTables == 1 then
                -- Single table: append directly
                markdown = markdown .. validTables[1]
            end
        else
            -- Single column or fallback
            for _, tableContent in ipairs(allTables) do
                markdown = markdown .. tableContent
            end
        end
    else
        -- Fallback to simple markdown table if CreateStyledTable not available
        -- Create one table per subcategory, grouped by category
        for _, category in ipairs(categoryOrder) do
            local subcategories = categories[category]
            local categoryEmoji = GetCategoryEmoji(category)

            -- Get subcategories and sort them alphabetically
            local subcategoryOrder = {}
            for subcategory, _ in pairs(subcategories) do
                table.insert(subcategoryOrder, subcategory or "General")
            end
            table.sort(subcategoryOrder, function(a, b)
                return string.lower(a or "") < string.lower(b or "")
            end)

            -- Create one table per subcategory
            for _, subcategory in ipairs(subcategoryOrder) do
                local achievements = subcategories[subcategory]
                if achievements and #achievements > 0 then
                    -- Sort achievements by name within subcategory
                    table.sort(achievements, function(a, b)
                        return (a.name or "") < (b.name or "")
                    end)

                    markdown = markdown .. "#### " .. categoryEmoji .. " " .. category .. "\n\n"
                    markdown = markdown .. "##### " .. subcategory .. "\n\n"
                    markdown = markdown .. "| Achievement | Progress | Points |\n"
                    markdown = markdown .. "|:-----------|:---------|------:|\n"

                    for _, achievement in ipairs(achievements) do
                        local statusIcon = GetAchievementStatusIcon(achievement)
                        local progressText = GetProgressText(achievement)

                        -- Safely convert achievement.name to string (handle boolean/nil)
                        local achievementName = ""
                        if achievement.name then
                            if type(achievement.name) == "string" then
                                achievementName = achievement.name
                            else
                                CM.DebugPrint(
                                    "ACHIEVEMENTS",
                                    string.format(
                                        "Invalid achievement name in in-progress fallback: name=%s (type=%s), id=%s",
                                        tostring(achievement.name),
                                        type(achievement.name),
                                        tostring(achievement.id)
                                    )
                                )
                                achievementName = tostring(achievement.name)
                            end
                        else
                            CM.DebugPrint(
                                "ACHIEVEMENTS",
                                string.format(
                                    "Missing achievement name in in-progress fallback: id=%s",
                                    tostring(achievement.id)
                                )
                            )
                        end

                        local row = "| "
                            .. statusIcon
                            .. " **"
                            .. achievementName
                            .. "** | "
                            .. progressText
                            .. " | "
                            .. tostring(achievement.points or 0)
                            .. " |"
                        row = row:gsub("%s+$", "") .. "\n"
                        markdown = markdown .. row
                    end
                    markdown = markdown .. "\n"
                end
            end
        end
    end

    return markdown
end

-- =====================================================
-- RECENT ACHIEVEMENTS GENERATOR
-- =====================================================

local function GenerateRecentAchievements(achievementData, format)
    InitializeUtilities()

    local markdown = ""

    markdown = markdown .. "### 🎉 Recent Achievements\n\n"

    local recent = achievementData.recent

    if #recent == 0 then
        markdown = markdown .. "*No recent achievements*\n\n"
        return markdown
    end

    local CreateStyledTable = CM.utils.markdown.CreateStyledTable
    if CreateStyledTable then
        local headers = { "Achievement", "Points", "Category" }
        local rows = {}

        for _, achievement in ipairs(recent) do
            -- Skip invalid achievement entries (debug log them but don't display)
            if not achievement.name or type(achievement.name) ~= "string" or achievement.name == "" then
                CM.DebugPrint(
                    "ACHIEVEMENTS",
                    string.format(
                        "Skipping invalid achievement entry: name=%s (type=%s), id=%s, points=%s",
                        tostring(achievement.name),
                        type(achievement.name),
                        tostring(achievement.id),
                        tostring(achievement.points)
                    )
                )
                -- Skip this achievement - don't add to rows
            else
                local achievementName = achievement.name

                -- Safely get category (handle nil/boolean)
                local category = ""
                if achievement.category then
                    if type(achievement.category) == "string" then
                        category = achievement.category
                    else
                        category = tostring(achievement.category)
                    end
                end

                local categoryEmoji = GetCategoryEmoji(category)
                table.insert(rows, {
                    "✅ **" .. achievementName .. "**",
                    tostring(achievement.points or 0),
                    categoryEmoji .. " " .. category,
                })
            end
        end

        local options = {
            alignment = { "left", "right", "left" },
            format = format,
            coloredHeaders = true,
        }
        markdown = markdown .. CreateStyledTable(headers, rows, options)
    else
        -- Fallback to markdown table
        markdown = markdown .. "| Achievement | Points | Category |\n"
        markdown = markdown .. "|:------------|-------:|:--------|\n"

        for _, achievement in ipairs(recent) do
            -- Skip invalid achievement entries (debug log them but don't display)
            if not achievement.name or type(achievement.name) ~= "string" or achievement.name == "" then
                CM.DebugPrint(
                    "ACHIEVEMENTS",
                    string.format(
                        "Skipping invalid achievement in recent fallback: name=%s (type=%s), id=%s",
                        tostring(achievement.name),
                        type(achievement.name),
                        tostring(achievement.id)
                    )
                )
                -- Skip this achievement - continue to next
            else
                -- Safely convert achievement.name and category to strings
                local achievementName = achievement.name

                local category = ""
                if achievement.category then
                    if type(achievement.category) == "string" then
                        category = achievement.category
                    else
                        category = tostring(achievement.category)
                    end
                end

                local categoryEmoji = GetCategoryEmoji(category)
                local row = "| ✅ **"
                    .. achievementName
                    .. "** | "
                    .. tostring(achievement.points or 0)
                    .. " | "
                    .. categoryEmoji
                    .. " "
                    .. category
                    .. " |"
                row = row:gsub("%s+$", "") .. "\n"
                markdown = markdown .. row
            end
        end
        markdown = markdown .. "\n"
    end

    return markdown
end

-- =====================================================
-- SPECIALIZED ACHIEVEMENT GENERATORS
-- =====================================================

local function GenerateSkyshardAchievements(skyshardData, format)
    InitializeUtilities()

    local markdown = ""

    markdown = markdown .. "### ⭐ Skyshard Collection\n\n"
    markdown = markdown .. "| Metric | Value |\n"
    markdown = markdown .. "|:-------|------:|\n"
    markdown = markdown .. "| **Collected** | " .. skyshardData.collected .. " |\n"
    markdown = markdown .. "| **Total** | " .. skyshardData.total .. " |\n"
    markdown = markdown .. "| **Skill Points Earned** | " .. skyshardData.skillPoints .. " |\n"
    local skyshardPct = (skyshardData.total and skyshardData.total > 0)
        and math.floor((skyshardData.collected / skyshardData.total) * 100)
        or 0
    markdown = markdown
        .. "| **Progress** | "
        .. CM.utils.GenerateProgressBar(skyshardPct, 12)
        .. " |\n"
    markdown = markdown .. "\n"

    return markdown
end

local function GenerateLorebookAchievements(lorebookData, format)
    InitializeUtilities()

    local markdown = ""

    markdown = markdown .. "### 📚 Lorebook Collection\n\n"
    markdown = markdown .. "| Metric | Value |\n"
    markdown = markdown .. "|:-------|------:|\n"
    markdown = markdown .. "| **Collected** | " .. lorebookData.collected .. " |\n"
    markdown = markdown .. "| **Total** | " .. lorebookData.total .. " |\n"
    markdown = markdown
        .. "| **Progress** | "
        .. CM.utils.GenerateProgressBar(math.floor((lorebookData.collected / lorebookData.total) * 100), 12)
        .. " |\n"
    markdown = markdown .. "\n"

    return markdown
end

-- =====================================================
-- MAIN ACHIEVEMENT GENERATOR
-- =====================================================

local function GenerateAchievements(achievementData, format)
    InitializeUtilities()

    -- Return empty if no achievement data
    if not achievementData or not achievementData.summary then
        return ""
    end

    local markdown = ""

    -- Generate achievement summary (always shown)
    markdown = markdown .. GenerateAchievementSummary(achievementData, format)

    -- Generate category breakdown (always shown when achievements enabled)
    markdown = markdown .. GenerateAchievementCategories(achievementData, format)

    -- Show in-progress achievements (if field exists and has items)
    if
        achievementData.inProgress
        and type(achievementData.inProgress) == "table"
        and #achievementData.inProgress > 0
    then
        markdown = markdown .. GenerateInProgressAchievements(achievementData, format)
    end

    -- Show recent achievements (if field exists and has items)
    if achievementData.recent and type(achievementData.recent) == "table" and #achievementData.recent > 0 then
        markdown = markdown .. GenerateRecentAchievements(achievementData, format)
    end

    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateAchievements = GenerateAchievements
CM.generators.sections.GenerateSkyshardAchievements = GenerateSkyshardAchievements
CM.generators.sections.GenerateLorebookAchievements = GenerateLorebookAchievements

return {
    GenerateAchievements = GenerateAchievements,
    GenerateSkyshardAchievements = GenerateSkyshardAchievements,
    GenerateLorebookAchievements = GenerateLorebookAchievements,
}
