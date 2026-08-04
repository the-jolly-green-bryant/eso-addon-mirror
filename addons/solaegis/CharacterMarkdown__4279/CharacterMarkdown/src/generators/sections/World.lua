-- CharacterMarkdown - World Section Generators
-- Generates world progress-related markdown sections (Skyshards, Lorebooks, Zone Completion, Dungeons)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateProgressBar, CreateZoneLink, CreateCollapsible

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        CreateZoneLink = CM.links.CreateZoneLink
        CreateCollapsible = (CM.utils and CM.utils.markdown and CM.utils.markdown.CreateCollapsible) or nil
    end
end

-- =====================================================
-- SKYSHARDS
-- =====================================================

local function GenerateSkyshards(skyshardsData, asColumn)
    InitializeUtilities()

    local markdown = ""

    if not skyshardsData or skyshardsData.total == 0 then
        return ""
    end

    -- Use h4 (####) when in column mode, h3 (###) when standalone
    local headerLevel = asColumn and "####" or "###"
    markdown = markdown .. headerLevel .. " 🌟 Skyshards\n\n"
    markdown = markdown .. "| Zone | Collected | Progress |\n"
    markdown = markdown .. "|:-----|:----------|:--------|\n"

    -- Show zone-specific data
    for zoneName, zoneData in pairs(skyshardsData.zones) do
        if zoneData.total > 0 then
            local progressBar = GenerateProgressBar(zoneData.percentage, 10)
            markdown = markdown
                .. "| **"
                .. zoneName
                .. "** | "
                .. zoneData.collected
                .. "/"
                .. zoneData.total
                .. " | "
                .. progressBar
                .. " "
                .. zoneData.percentage
                .. "% |\n"
        end
    end

    -- Overall summary
    local overallProgress = math.floor((skyshardsData.collected / skyshardsData.total) * 100)
    local overallProgressBar = GenerateProgressBar(overallProgress, 10)
    markdown = markdown
        .. "| **Total** | "
        .. skyshardsData.collected
        .. "/"
        .. skyshardsData.total
        .. " | "
        .. overallProgressBar
        .. " "
        .. overallProgress
        .. "% |\n"

    return markdown
end

-- =====================================================
-- LOREBOOKS
-- =====================================================

local function GenerateLorebooks(lorebooksData)
    InitializeUtilities()

    local markdown = ""

    if not lorebooksData or not lorebooksData.categories or (lorebooksData.total or 0) == 0 then
        return ""
    end

    -- Build table content
    local tableContent = "| Category | Collected | Total | Progress |\n"
    tableContent = tableContent .. "|:---------|:----------|:------|:--------|\n"

    -- Show category breakdown
    for categoryName, categoryData in pairs(lorebooksData.categories) do
        if categoryData.total > 0 then
            local categoryPercent = math.floor((categoryData.collected / categoryData.total) * 100)
            local progressBar = GenerateProgressBar(categoryPercent, 20)
            tableContent = tableContent
                .. "| **"
                .. categoryName
                .. "** | "
                .. categoryData.collected
                .. " | "
                .. categoryData.total
                .. " | "
                .. progressBar
                .. " "
                .. categoryPercent
                .. "% |\n"
        end
    end

    -- Overall summary
    local overallProgress = math.floor((lorebooksData.collected / lorebooksData.total) * 100)
    local overallProgressBar = GenerateProgressBar(overallProgress, 20)
    tableContent = tableContent
        .. "| **Total** | "
        .. lorebooksData.collected
        .. " | "
        .. lorebooksData.total
        .. " | "
        .. overallProgressBar
        .. " "
        .. overallProgress
        .. "% |\n"

    -- Wrap in collapsible section (matching format of other collectible types)
    local summaryText = "📚 Lorebooks (" .. lorebooksData.collected .. " of " .. lorebooksData.total .. ")"
    markdown = markdown .. "<details>\n"
    markdown = markdown .. "<summary>" .. summaryText .. "</summary>\n\n"
    markdown = markdown .. tableContent .. "\n"
    markdown = markdown .. "</details>\n\n"

    return markdown
end

-- =====================================================
-- ZONE COMPLETION
-- =====================================================

local function GenerateZoneCompletion(zoneCompletionData)
    InitializeUtilities()

    local markdown = ""

    if not zoneCompletionData or zoneCompletionData.currentZone == "" then
        return ""
    end

    -- Create zone link if available (conditional based on settings)
    local zoneName = zoneCompletionData.currentZone
    local zoneLink = (CreateZoneLink and CreateZoneLink(zoneName)) or zoneName

    markdown = markdown .. "### 🗺️ Zone Completion\n\n"
    markdown = markdown .. "| Zone | Completion |\n"
    markdown = markdown .. "|:-----|:----------|\n"

    local progressBar = GenerateProgressBar(zoneCompletionData.completionPercentage, 20)
    markdown = markdown
        .. "| **"
        .. zoneLink
        .. "** | "
        .. progressBar
        .. " "
        .. zoneCompletionData.completionPercentage
        .. "% |\n\n"

    return markdown
end

-- =====================================================
-- DUNGEONS (DELVES & PUBLIC DUNGEONS)
-- =====================================================

local function GenerateDungeonProgress(dungeonData, asColumn)
    InitializeUtilities()

    local markdown = ""

    if not dungeonData then
        return ""
    end

    local hasDelves = dungeonData.delves and dungeonData.delves.total > 0
    local hasPublicDungeons = dungeonData.publicDungeons and dungeonData.publicDungeons.total > 0

    if not hasDelves and not hasPublicDungeons then
        return ""
    end

    -- Use h4 (####) when in column mode, h3 (###) when standalone
    local headerLevel = asColumn and "####" or "###"
    markdown = markdown .. headerLevel .. " 🏰 Dungeon Progress\n\n"

    if hasDelves then
        local delvePercent = math.floor((dungeonData.delves.completed / dungeonData.delves.total) * 100)
        markdown = markdown
            .. "**Delves:** "
            .. dungeonData.delves.completed
            .. "/"
            .. dungeonData.delves.total
            .. " ("
            .. delvePercent
            .. "%)\n\n"
    end

    if hasPublicDungeons then
        local dungeonPercent =
            math.floor((dungeonData.publicDungeons.completed / dungeonData.publicDungeons.total) * 100)
        markdown = markdown
            .. "**Public Dungeons:** "
            .. dungeonData.publicDungeons.completed
            .. "/"
            .. dungeonData.publicDungeons.total
            .. " ("
            .. dungeonPercent
            .. "%)\n"
    end

    return markdown
end

-- =====================================================
-- MAIN WORLD PROGRESS GENERATOR
-- =====================================================

local function GenerateWorldProgress(worldProgressData)
    InitializeUtilities()

    local markdown = ""

    if not worldProgressData then
        return ""
    end

    -- Only show the section if we have some data
    local hasData = false
    if worldProgressData.skyshards and worldProgressData.skyshards.total > 0 then
        hasData = true
    elseif worldProgressData.zoneCompletion and worldProgressData.zoneCompletion.currentZone ~= "" then
        hasData = true
    elseif
        worldProgressData.dungeons
        and (
            (worldProgressData.dungeons.delves and worldProgressData.dungeons.delves.total > 0)
            or (worldProgressData.dungeons.publicDungeons and worldProgressData.dungeons.publicDungeons.total > 0)
        )
    then
        hasData = true
    elseif worldProgressData.cadwell and worldProgressData.cadwell.levelName then
        hasData = true
    end

    if not hasData then
        return ""
    end

    markdown = markdown .. "## 🌍 World Progress\n\n"

    -- GitHub/VSCode: Use 2-column layout for skyshards + dungeons when available
    local CreateTwoColumnLayout = CM.utils.markdown and CM.utils.markdown.CreateTwoColumnLayout

    if CreateTwoColumnLayout then
        local column1 = GenerateSkyshards(worldProgressData.skyshards, true)
        local column2 = GenerateDungeonProgress(worldProgressData.dungeons, true)
        local layoutContent = CreateTwoColumnLayout(column1, column2)
        if layoutContent and layoutContent ~= "" then
            markdown = markdown .. layoutContent
        end
    else
        markdown = markdown .. GenerateSkyshards(worldProgressData.skyshards, false)
        markdown = markdown .. GenerateDungeonProgress(worldProgressData.dungeons, false)
    end

    markdown = markdown .. GenerateZoneCompletion(worldProgressData.zoneCompletion)

    if worldProgressData.cadwell and worldProgressData.cadwell.levelName then
        markdown = markdown .. "### Cadwell's Almanac\n\n"
        markdown = markdown
            .. "| Level | Zones |\n|:------|:------|\n| **"
            .. worldProgressData.cadwell.levelName
            .. "** | "
            .. tostring(worldProgressData.cadwell.zoneCount or 0)
            .. " |\n\n"
    end

    if worldProgressData.endlessDungeon then
        local ed = worldProgressData.endlessDungeon
        markdown = markdown .. "### Endless Dungeon\n\n"
        markdown = markdown
            .. "| Field | Value |\n|:------|:------|\n| **Score** | "
            .. tostring(ed.score or 0)
            .. " |\n| **In Instance** | "
            .. (ed.isInstance and "Yes" or "No")
            .. " |\n\n"
        if ed.verses and #ed.verses > 0 then
            markdown = markdown .. "**Active Verses:** "
            local names = {}
            for _, v in ipairs(ed.verses) do
                table.insert(names, v.name or tostring(v.id))
            end
            markdown = markdown .. table.concat(names, ", ") .. "\n\n"
        end
    end

    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateWorldProgress = GenerateWorldProgress
CM.generators.sections.GenerateSkyshards = GenerateSkyshards
CM.generators.sections.GenerateLorebooks = GenerateLorebooks
CM.generators.sections.GenerateZoneCompletion = GenerateZoneCompletion
CM.generators.sections.GenerateDungeonProgress = GenerateDungeonProgress
