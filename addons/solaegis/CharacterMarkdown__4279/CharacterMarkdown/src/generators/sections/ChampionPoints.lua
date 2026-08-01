-- CharacterMarkdown - Enhanced Champion Points Generator
-- Phase 4: Detailed allocation analysis and optimization suggestions

local CM = CharacterMarkdown
local string_format = string.format

-- =====================================================
-- CONSTANTS
-- =====================================================

-- Use centralized constants from CM.constants.CP
local CP_CONSTANTS = CM.constants.CP
    or {
        MIN_CP_FOR_SYSTEM = 10,
        MAX_CP_PER_DISCIPLINE = 660,
        PROGRESS_BAR_LENGTH = 12,
    }

-- =====================================================
-- UTILITIES
-- =====================================================

local function InitializeUtilities()
    if not CM.utils then
        CM.utils = {}
    end

    -- Lazy load utilities from correct modules
    -- FormatNumber is in CM.utils (from Formatters.lua) - should already be set, but check
    if not CM.utils.FormatNumber then
        -- Fallback: create a simple formatter if module not loaded
        CM.utils.FormatNumber = function(num)
            if not num then
                return "0"
            end
            return tostring(math.floor(num))
        end
    end

    -- CreateCPSkillLink is in CM.links (from Systems.lua)
    if not CM.utils.CreateCPSkillLink then
        if CM.links and CM.links.CreateCPSkillLink then
            CM.utils.CreateCPSkillLink = CM.links.CreateCPSkillLink
        else
            -- Fallback: return name as-is if links module not loaded
            CM.utils.CreateCPSkillLink = function(name)
                return name or ""
            end
        end
    end

    -- GenerateProgressBar is in CM.generators.helpers (from helpers/Utilities.lua)
    if not CM.utils.GenerateProgressBar then
        if CM.generators and CM.generators.helpers and CM.generators.helpers.GenerateProgressBar then
            CM.utils.GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        else
            -- Fallback: create a simple progress bar if module not loaded
            CM.utils.GenerateProgressBar = function(percent, width)
                width = width or 12
                local filled = math.floor((percent / 100) * width)
                local empty = width - filled
                return string.rep("█", filled) .. string.rep("░", empty)
            end
        end
    end

    -- GenerateAnchor is in CM.utils.markdown (from AdvancedMarkdown.lua)
    if not CM.utils.GenerateAnchor then
        if CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor then
            CM.utils.GenerateAnchor = CM.utils.markdown.GenerateAnchor
        end
    end
end

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function GetInvestmentLevelEmoji(level)
    local emojis = {
        ["very-high"] = "🔥",
        ["high"] = "⭐",
        ["medium-high"] = "💪",
        ["medium"] = "📈",
        ["low"] = "🌱",
    }
    return emojis[level] or "🌱"
end

local function GetInvestmentLevelDescription(level)
    local descriptions = {
        ["very-high"] = "Expert level (1500+ CP)",
        ["high"] = "Advanced level (1200+ CP)",
        ["medium-high"] = "Intermediate level (800+ CP)",
        ["medium"] = "Developing level (400+ CP)",
        ["low"] = "Beginner level (<400 CP)",
    }
    return descriptions[level] or "Beginner level"
end

-- Calculate available CP breakdown by discipline (⚒️ Craft - ⚔️ Warfare - 💪 Fitness)
-- Unassigned CP is a shared pool, but we show it per discipline to indicate
-- "available capacity" (max - assigned) for each discipline
local function GetAvailableCPBreakdown(cpData)
    if not cpData or not cpData.disciplines then
        return ""
    end

    local DisciplineType = CM.constants and CM.constants.DisciplineType
    if not DisciplineType then
        return ""
    end

    -- Get unassigned CP (shared pool)
    local totalUnassigned = cpData.available or 0
    if totalUnassigned == 0 and cpData.total and cpData.spent then
        totalUnassigned = math.max(0, cpData.total - cpData.spent)
    end

    -- Get assigned points per discipline
    local craftAssigned = 0
    local warfareAssigned = 0
    local fitnessAssigned = 0

    for _, discipline in ipairs(cpData.disciplines) do
        local name = discipline.name or ""
        local assigned = discipline.assigned or discipline.total or 0

        if name == DisciplineType.CRAFT then
            craftAssigned = assigned
        elseif name == DisciplineType.WARFARE then
            warfareAssigned = assigned
        elseif name == DisciplineType.FITNESS then
            fitnessAssigned = assigned
        end
    end

    -- Calculate "available capacity" per discipline
    -- Max per discipline = assigned + unassigned (shared pool)
    -- Available capacity = max - assigned = (assigned + unassigned) - assigned = unassigned
    -- Since unassigned is shared, all disciplines show the same available capacity
    -- This represents "how much more can be allocated to this discipline"
    local unassignedCraft = totalUnassigned
    local unassignedWarfare = totalUnassigned
    local unassignedFitness = totalUnassigned

    return string_format("⚒️ %d - ⚔️ %d - 💪 %d", unassignedCraft, unassignedWarfare, unassignedFitness)
end

local function GetSlottableStatus(skill, maxSlottable)
    if not skill.isSlottable then
        return "🔒 Passive"
    end

    local points = skill.points or 0
    if points >= 50 then
        return "⭐ Maxed Slottable"
    elseif points >= 30 then
        return "🔸 High Slottable"
    elseif points >= 15 then
        return "🔹 Medium Slottable"
    else
        return "🔸 Low Slottable"
    end
end

-- Get point text (singular/plural)
local function GetPointText(points)
    return points == 1 and "point" or "points"
end

-- Get slotted champion point skill IDs
local function GetSlottedChampionSkillIds()
    local slottedIds = {}

    -- Check if HOTBAR_CATEGORY_CHAMPION exists (ESO API)
    local success, category = pcall(function()
        return HOTBAR_CATEGORY_CHAMPION
    end)
    if not success or not category then
        -- Fallback: try alternative API methods
        CM.DebugPrint("CP", "HOTBAR_CATEGORY_CHAMPION not available, trying alternative methods")
        return slottedIds
    end

    -- Champion bar typically has slots 1-12 (3 per discipline, up to 4 per discipline at higher CP)
    -- Check slots 1-12 for champion abilities
    for slotIndex = 1, 12 do
        local slotSuccess, abilityId = pcall(GetSlotBoundId, slotIndex, category)
        if slotSuccess and abilityId and abilityId > 0 then
            table.insert(slottedIds, abilityId)
            CM.DebugPrint("CP", string_format("Found slotted CP skill ID %d in slot %d", abilityId, slotIndex))
        end
    end

    return slottedIds
end

-- Get discipline skills (unified from multiple sources)
local function GetDisciplineSkills(discipline)
    -- Prefer main skills array if populated
    if discipline.skills and #discipline.skills > 0 then
        return discipline.skills, "mixed"
    end

    -- Fallback to separated arrays
    local slottable = discipline.slottableSkills or {}
    local passive = discipline.passiveSkills or {}
    if #slottable > 0 or #passive > 0 then
        local combined = {}
        for _, s in ipairs(slottable) do
            table.insert(combined, { name = s.name, points = s.points, type = "slottable", isSlottable = true })
        end
        for _, s in ipairs(passive) do
            table.insert(combined, { name = s.name, points = s.points, type = "passive", isSlottable = false })
        end
        return combined, "separated"
    end

    return {}, "none"
end

-- Format discipline summary (reduces duplication)
local function FormatDisciplineSummary(discipline)
    local emoji = discipline.emoji or "⚔️"
    local name = discipline.name
    local total = CM.utils.FormatNumber(discipline.total)

    return string_format("### %s %s (%s CP)\n\n", emoji, name, total)
end

-- =====================================================
-- OPTIMIZATION SUGGESTIONS (Currently Unused)
-- =====================================================
-- This function is implemented but not currently used in any generator.
-- It was part of the detailed Champion Points analysis feature that has been disabled.
-- Kept for potential future use.

local function GenerateOptimizationSuggestions(cpData)
    local suggestions = {}

    -- Check for unspent points
    if cpData.available and cpData.available > 0 then
        table.insert(
            suggestions,
            "⚠️ You have " .. CM.utils.FormatNumber(cpData.available) .. " unspent Champion Points"
        )
    end

    -- Check slottable allocation
    if cpData.analysis then
        local totalSlottable = (cpData.analysis and cpData.analysis.slottableSkills) or 0
        local maxSlottable = (cpData.analysis and cpData.analysis.maxSlottablePerDiscipline) or 3
        local totalMaxSlottable = maxSlottable * 3 -- 3 disciplines

        if totalSlottable < totalMaxSlottable then
            table.insert(
                suggestions,
                "💡 Consider investing in more slottable skills ("
                    .. totalSlottable
                    .. "/"
                    .. totalMaxSlottable
                    .. " used)"
            )
        end

        -- Check for discipline balance
        if cpData.disciplines then
            local disciplineTotals = {}
            for _, discipline in ipairs(cpData.disciplines) do
                disciplineTotals[discipline.name] = discipline.total or 0
            end

            local craftTotal = disciplineTotals.Craft or 0
            local warfareTotal = disciplineTotals.Warfare or 0
            local fitnessTotal = disciplineTotals.Fitness or 0

            local maxDiscipline = math.max(craftTotal, warfareTotal, fitnessTotal)
            local minDiscipline = math.min(craftTotal, warfareTotal, fitnessTotal)

            if maxDiscipline > 0 and (maxDiscipline - minDiscipline) > 200 then
                table.insert(suggestions, "⚖️ Consider balancing CP allocation across disciplines")
            end
        end
    end

    return suggestions
end

-- =====================================================
-- SLOTTABLE-ONLY CHAMPION POINTS GENERATOR
-- =====================================================

local function GenerateSlottableChampionPoints(cpData)
    InitializeUtilities()

    local markdown = ""

    local anchorId = CM.utils.GenerateAnchor and CM.utils.GenerateAnchor("⭐ Slottable Champion Points")
        or "slottable-champion-points"
    markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
    markdown = markdown .. "## ⭐ Slottable Champion Points\n\n"

    local totalCP = cpData.total or 0

    if totalCP < CP_CONSTANTS.MIN_CP_FOR_SYSTEM then
        markdown = markdown .. "*Champion Point system unlocks at Level 50*\n\n"
        return markdown
    end

    local hasSlottableSkills = false

    if cpData.disciplines and #cpData.disciplines > 0 then
        for _, discipline in ipairs(cpData.disciplines) do
            local slottableSkills = discipline.slottableSkills or {}
            if #slottableSkills > 0 then
                hasSlottableSkills = true

                markdown = markdown .. FormatDisciplineSummary(discipline)

                for _, skill in ipairs(slottableSkills) do
                    local maxSlottable = (cpData.analysis and cpData.analysis.maxSlottablePerDiscipline) or 3
                    local status = GetSlottableStatus(skill, maxSlottable)
                    local skillText = CM.utils.CreateCPSkillLink(skill.name)
                    local pointText = GetPointText(skill.points)
                    markdown = markdown
                        .. string_format("- %s **%s**: %d %s\n", status, skillText, skill.points or 0, pointText)
                end
                markdown = markdown .. "\n"
            end
        end
    end

    if not hasSlottableSkills then
        markdown = markdown .. "*No slottable Champion Point skills found*\n\n"
    end

    return markdown
end

-- =====================================================
-- SINGLE DISCIPLINE GENERATOR (for multi-column layout)
-- =====================================================

local function GenerateSingleDiscipline(discipline, unassignedCP)
    local markdown = ""
    local disciplineSpent = discipline.spent or discipline.total or 0
    local maxPerDiscipline = discipline.cap or (disciplineSpent + (discipline.available or 0))

    -- Fallback if cap is missing
    if maxPerDiscipline == 0 and unassignedCP then
        maxPerDiscipline = disciplineSpent + unassignedCP
    end

    -- Ensure max is at least equal to spent (safety check)
    if maxPerDiscipline < disciplineSpent then
        maxPerDiscipline = disciplineSpent
    end

    if disciplineSpent > 0 then
        -- Safety check: avoid division by zero
        local disciplinePercent = maxPerDiscipline > 0
                and math.min(100, math.floor((disciplineSpent / maxPerDiscipline) * 100))
            or 0
        local progressBar = CM.utils.GenerateProgressBar(disciplinePercent, CP_CONSTANTS.PROGRESS_BAR_LENGTH)

        -- Progress row: progress bar + percentage | x/y points
        markdown = markdown .. "#### " .. (discipline.emoji or "⚔️") .. " " .. discipline.name .. "\n\n"
        markdown = markdown
            .. "**"
            .. CM.utils.FormatNumber(disciplineSpent)
            .. "/"
            .. maxPerDiscipline
            .. " points** "
            .. progressBar
            .. " "
            .. disciplinePercent
            .. "%\n\n"

        -- Show skills breakdown using unified function
        local skills, skillSource = GetDisciplineSkills(discipline)
        local hasSkills = #skills > 0

        if hasSkills then
            for _, skill in ipairs(skills) do
                local skillText = CM.utils.CreateCPSkillLink(skill.name)
                local pointText = GetPointText(skill.points)
                local skillType = skill.type or (skill.isSlottable and "slottable" or "passive")

                if skillSource == "separated" then
                    -- Show type indicator when using separated arrays
                    local typeEmoji = skillType == "slottable" and "⭐" or "🔒"
                    markdown = markdown
                        .. string_format("- %s **%s**: %d %s\n", typeEmoji, skillText, skill.points or 0, pointText)
                else
                    -- Standard format for mixed array
                    markdown = markdown .. string_format("- **%s**: %d %s\n", skillText, skill.points or 0, pointText)
                end
            end
        else
            -- If discipline has points but no skills listed, show a note
            markdown = markdown .. "*Points assigned but details not available*\n"
        end
    else
        -- Show discipline even with 0 points (for visibility)
        if maxPerDiscipline == 0 then
            maxPerDiscipline = unassignedCP
        end

        local progressBar = CM.utils.GenerateProgressBar(0, CP_CONSTANTS.PROGRESS_BAR_LENGTH)

        markdown = markdown .. "#### " .. (discipline.emoji or "⚔️") .. " " .. discipline.name .. "\n\n"
        markdown = markdown .. "**0/" .. maxPerDiscipline .. " points** " .. progressBar .. " 0%\n\n"
        markdown = markdown .. "*No points assigned*\n"
    end

    return markdown
end

-- Generate a discipline as a table (for multi-column table layout)
local function GenerateDisciplineTable(discipline, unassignedCP)
    local disciplineSpent = discipline.spent or discipline.total or 0
    local maxPerDiscipline = discipline.cap or (disciplineSpent + (discipline.available or 0))

    -- Fallback if cap is missing (shouldn't happen with new collector)
    if maxPerDiscipline == 0 and unassignedCP then
        maxPerDiscipline = disciplineSpent + unassignedCP
    end

    -- Ensure max is at least equal to spent (safety check)
    if maxPerDiscipline < disciplineSpent then
        maxPerDiscipline = disciplineSpent
    end

    local CreateStyledTable = CM.utils.markdown and CM.utils.markdown.CreateStyledTable
    if not CreateStyledTable then
        -- Fallback to old format if CreateStyledTable not available
        return GenerateSingleDiscipline(discipline, unassignedCP)
    end

    local headers = { (discipline.emoji or "⚔️") .. " " .. discipline.name, "Assigned Points" }
    local rows = {}

    if disciplineSpent > 0 then
        -- Safety check: avoid division by zero
        local disciplinePercent = maxPerDiscipline > 0
                and math.min(100, math.floor((disciplineSpent / maxPerDiscipline) * 100))
            or 0
        local progressBar = CM.utils.GenerateProgressBar(disciplinePercent, CP_CONSTANTS.PROGRESS_BAR_LENGTH)

        -- Progress row: progress bar + percentage | x/y points
        local progressBarText = progressBar .. " " .. disciplinePercent .. "%"
        local pointsText = CM.utils.FormatNumber(disciplineSpent) .. "/" .. maxPerDiscipline .. " points"
        table.insert(rows, { progressBarText, pointsText })

        -- Show skills breakdown using unified function
        local skills, skillSource = GetDisciplineSkills(discipline)
        local hasSkills = #skills > 0

        if hasSkills then
            for _, skill in ipairs(skills) do
                local skillText = CM.utils.CreateCPSkillLink(skill.name)
                local pointText = GetPointText(skill.points)
                local skillType = skill.type or (skill.isSlottable and "slottable" or "passive")

                local skillName = ""
                local pointsValue = string_format("%d %s", skill.points or 0, pointText)

                if skillSource == "separated" then
                    -- Show type indicator when using separated arrays
                    local typeEmoji = skillType == "slottable" and "⭐" or "🔒"
                    skillName = string_format("%s **%s**", typeEmoji, skillText)
                else
                    -- Standard format for mixed array
                    skillName = string_format("**%s**", skillText)
                end
                table.insert(rows, { skillName, pointsValue })
            end
        else
            -- If discipline has points but no skills listed, show a note
            table.insert(rows, { "*Points assigned but details not available*", "" })
        end
    else
        -- Show discipline even with 0 points (for visibility)
        if maxPerDiscipline == 0 then
            maxPerDiscipline = unassignedCP
        end

        local progressBar = CM.utils.GenerateProgressBar(0, CP_CONSTANTS.PROGRESS_BAR_LENGTH)
        local progressBarText = progressBar .. " 0%"
        local pointsText = "0/" .. maxPerDiscipline .. " points"
        table.insert(rows, { progressBarText, pointsText })
        table.insert(rows, { "*No points assigned*", "" })
    end

    local options = {
        alignment = { "left", "right" },
        coloredHeaders = true,
    }

    return CreateStyledTable(headers, rows, options)
end

-- =====================================================
-- MAIN CHAMPION POINTS GENERATOR (ENHANCED)
-- =====================================================

local function GenerateChampionPoints(cpData)
    InitializeUtilities()

    local markdown = ""

    -- Handle nil or empty cpData - always generate section header
    if not cpData then
        CM.DebugPrint("CP", "GenerateChampionPoints: cpData is nil")
        cpData = {}
    end

    local totalCP = cpData.total or 0
    CM.DebugPrint("CP", string_format("GenerateChampionPoints: totalCP=%d", totalCP))

    -- Always generate header when section is enabled
    markdown = markdown .. "## ⭐ Champion Points\n\n"

    -- If no CP data or CP system not unlocked, show message and return
    if totalCP < CP_CONSTANTS.MIN_CP_FOR_SYSTEM then
        markdown = markdown .. "*Champion Point system unlocks at Level 50*\n\n"
        -- Use CreateSeparator for consistent separator styling
        local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
        if CreateSeparator then
            markdown = markdown .. CreateSeparator("hr")
        else
            markdown = markdown .. "---\n\n"
        end
        return markdown
    end

    local spentCP = cpData.spent or 0
    -- Use API value for available CP if available, otherwise calculate
    local availableCP = cpData.available or (totalCP - spentCP)

    -- Use CreateStyledTable for consistent styling
    local CreateStyledTable = CM.utils.markdown and CM.utils.markdown.CreateStyledTable
    if CreateStyledTable then
        local headers = { "Total", "Spent", "Available" }
        local rows = {
            {
                CM.utils.FormatNumber(totalCP),
                CM.utils.FormatNumber(spentCP),
                CM.utils.FormatNumber(availableCP),
            },
        }
        local options = {
            alignment = { "center", "center", "center" },
            coloredHeaders = true,
        }
        markdown = markdown .. CreateStyledTable(headers, rows, options)
    else
        -- Fallback to simple markdown table if CreateStyledTable not available
        markdown = markdown .. "| **Total** | **Spent** | **Available** |\n"
        markdown = markdown .. "|:---------:|:---------:|:-------------:|\n"
        markdown = markdown
            .. "| "
            .. CM.utils.FormatNumber(totalCP)
            .. " | "
            .. CM.utils.FormatNumber(spentCP)
            .. " | "
            .. CM.utils.FormatNumber(availableCP)
            .. " |\n"
        markdown = markdown .. "\n"
    end

    -- Display enlightenment status if available (API 101049+)
    if cpData.enlightenment and cpData.enlightenment.isEnlightened then
        local enlightenment = cpData.enlightenment
        local poolText = CM.utils.FormatNumber(enlightenment.poolRemaining)
        local timeText = enlightenment.timeFormatted or "Unknown"
        markdown = markdown .. "\n> ✨ **Enlightened** - " .. poolText .. " XP bonus remaining"
        if enlightenment.timeUntilChange and enlightenment.timeUntilChange > 0 then
            markdown = markdown .. " (resets in " .. timeText .. ")"
        end
        markdown = markdown .. "\n\n"
    end

    -- Always show disciplines section if data exists
    if cpData.disciplines and #cpData.disciplines > 0 then
        local unassignedCP = availableCP or 0 -- Unassigned CP (shared pool)

        -- Use responsive column layout for disciplines (GitHub/VSCode only)
        local CreateResponsiveColumns = CM.utils.markdown and CM.utils.markdown.CreateResponsiveColumns

        if CreateResponsiveColumns and #cpData.disciplines > 0 then
            -- Generate each discipline as a table
            local columns = {}
            for _, discipline in ipairs(cpData.disciplines) do
                table.insert(columns, GenerateDisciplineTable(discipline, unassignedCP))
            end

            -- Calculate optimal layout based on discipline tables
            local LayoutCalculator = CM.utils.LayoutCalculator
            local minWidth, gap
            if LayoutCalculator then
                minWidth, gap = LayoutCalculator.GetLayoutParamsWithFallback(columns, "300px", "20px")
            else
                minWidth = "300px"
                gap = "20px"
            end

            -- Wrap in responsive column layout (tables side-by-side)
            markdown = markdown .. CreateResponsiveColumns(columns, minWidth, gap)
        else
            -- Fallback to vertical layout if multi-column not available or wrong number of disciplines
            for _, discipline in ipairs(cpData.disciplines) do
                local disciplineSpent = discipline.spent or discipline.total or 0
                local maxPerDiscipline = discipline.cap or (disciplineSpent + (discipline.available or 0))

                if maxPerDiscipline < disciplineSpent then
                    maxPerDiscipline = disciplineSpent
                end

                if disciplineSpent > 0 then
                    local disciplinePercent = maxPerDiscipline > 0
                            and math.min(100, math.floor((disciplineSpent / maxPerDiscipline) * 100))
                        or 0
                    local progressBar =
                        CM.utils.GenerateProgressBar(disciplinePercent, CP_CONSTANTS.PROGRESS_BAR_LENGTH)

                    markdown = markdown
                        .. "### "
                        .. (discipline.emoji or "⚔️")
                        .. " "
                        .. discipline.name
                        .. " ("
                        .. CM.utils.FormatNumber(disciplineSpent)
                        .. "/"
                        .. maxPerDiscipline
                        .. " points) "
                        .. progressBar
                        .. " "
                        .. disciplinePercent
                        .. "%\n\n"

                    local skills, skillSource = GetDisciplineSkills(discipline)
                    local hasSkills = #skills > 0

                    if hasSkills then
                        for _, skill in ipairs(skills) do
                            local skillText = CM.utils.CreateCPSkillLink(skill.name)
                            local pointText = GetPointText(skill.points)
                            local skillType = skill.type or (skill.isSlottable and "slottable" or "passive")

                            if skillSource == "separated" then
                                local typeEmoji = skillType == "slottable" and "⭐" or "🔒"
                                markdown = markdown
                                    .. string_format(
                                        "- %s **%s**: %d %s\n",
                                        typeEmoji,
                                        skillText,
                                        skill.points or 0,
                                        pointText
                                    )
                            else
                                markdown = markdown
                                    .. string_format("- **%s**: %d %s\n", skillText, skill.points or 0, pointText)
                            end
                        end
                        markdown = markdown .. "\n"
                    else
                        markdown = markdown .. "*Points assigned but details not available*\n\n"
                    end
                else
                    local maxPerDiscipline = discipline.cap or (discipline.available or 0)
                    if maxPerDiscipline == 0 then
                        maxPerDiscipline = unassignedCP
                    end

                    local progressBar = CM.utils.GenerateProgressBar(0, CP_CONSTANTS.PROGRESS_BAR_LENGTH)

                    markdown = markdown
                        .. "### "
                        .. (discipline.emoji or "⚔️")
                        .. " "
                        .. discipline.name
                        .. " (0/"
                        .. maxPerDiscipline
                        .. " points) "
                        .. progressBar
                        .. " 0%\n\n"
                    markdown = markdown .. "*No points assigned to this discipline*\n\n"
                end
            end
        end
    else
        -- No disciplines data available - still show section
        markdown = markdown .. "*Champion Point discipline data not available*\n\n"
    end

    -- Use CreateSeparator for consistent separator styling
    local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
    if CreateSeparator then
        markdown = markdown .. CreateSeparator("hr")
    else
        markdown = markdown .. "---\n\n"
    end

    -- Ensure we always return something (defensive check)
    if markdown == "" or not markdown:match("## ⭐ Champion Points") then
        -- Fallback: return at least header
        return "## ⭐ Champion Points\n\n*Champion Point data not available*\n\n---\n\n"
    end

    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateChampionPoints = GenerateChampionPoints
CM.generators.sections.GenerateSlottableChampionPoints = GenerateSlottableChampionPoints

return {
    GenerateChampionPoints = GenerateChampionPoints,
    GenerateSlottableChampionPoints = GenerateSlottableChampionPoints,
}
