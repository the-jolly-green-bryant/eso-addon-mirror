-- CharacterMarkdown - Crafting Section Generators
-- Generates crafting-related markdown sections (motifs, recipes, research)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateAnchor, GenerateProgressBar, CreateMotifLink, CreateRecipeLink
local string_format = string.format

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        CreateMotifLink = CM.links and CM.links.CreateMotifLink
        CreateRecipeLink = CM.links and CM.links.CreateRecipeLink
    end
end

-- =====================================================
-- HELPER: GENERATE MOTIFS SECTION
-- =====================================================

local function GenerateMotifsSection(craftingData)
    local markdown = ""
    local settings = CM.GetSettings()

    if not craftingData.motifs or #craftingData.motifs == 0 then
        return markdown
    end

    local knownMotifs = {}
    local partialMotifs = {}
    local completedCount = 0
    local totalMotifs = #craftingData.motifs

    for _, motif in ipairs(craftingData.motifs) do
        if motif.isCompleted then
            table.insert(knownMotifs, motif)
            completedCount = completedCount + 1
        elseif motif.numKnown > 0 then
            table.insert(partialMotifs, motif)
        end
    end

    -- Outer collapsible: overall motif progress summary
    markdown = markdown .. "<details>\n"
    markdown = markdown
        .. string_format(
            "<summary>🎨 Crafting Motifs (%d of %d Completed)</summary>\n\n",
            completedCount,
            totalMotifs
        )

    -- Overall progress bar
    InitializeUtilities()
    local progress = math.floor((completedCount / totalMotifs) * 100)
    local progressBar = GenerateProgressBar(progress, 20)
    markdown = markdown .. "| Progress |\n"
    markdown = markdown .. "| --- |\n"
    markdown = markdown .. string_format("| %s %d%% (%d/%d) |\n\n", progressBar, progress, completedCount, totalMotifs)

    if settings.showMotifsDetailed then
        -- Collectibles-style: one collapsible per motif style with progress bar + chapter list
        markdown = markdown .. "### 📚 Style Collection\n\n"

        -- Sort: completed first, then in-progress, then not-started; alphabetical within each group
        local sortedMotifs = {}
        for _, motif in ipairs(craftingData.motifs) do
            table.insert(sortedMotifs, motif)
        end
        table.sort(sortedMotifs, function(a, b)
            local rankA = a.isCompleted and 0 or (a.numKnown > 0 and 1 or 2)
            local rankB = b.isCompleted and 0 or (b.numKnown > 0 and 1 or 2)
            if rankA ~= rankB then
                return rankA < rankB
            end
            return (a.name or ""):lower() < (b.name or ""):lower()
        end)

        for _, motif in ipairs(sortedMotifs) do
            local numKnown = motif.numKnown or 0
            local total = motif.total or 14
            local statusEmoji = motif.isCompleted and "✅" or (numKnown > 0 and "🚧" or "❌")

            -- Per-style collapsible (matching Collectibles layout)
            markdown = markdown .. "<details>\n"
            markdown = markdown
                .. string_format("<summary>%s %s (%d of %d)</summary>\n\n", statusEmoji, motif.name, numKnown, total)

            -- Per-style progress bar
            local styleProgress = total > 0 and math.floor((numKnown / total) * 100) or 0
            local styleBar = GenerateProgressBar(styleProgress, 20)
            markdown = markdown .. "| Progress |\n"
            markdown = markdown .. "| --- |\n"
            markdown = markdown .. string_format("| %s %d%% (%d/%d) |\n\n", styleBar, styleProgress, numKnown, total)

            -- Chapter list (sorted alphabetically)
            if motif.chapters and #motif.chapters > 0 then
                local sortedChapters = {}
                for _, chapter in ipairs(motif.chapters) do
                    table.insert(sortedChapters, chapter)
                end
                table.sort(sortedChapters, function(a, b)
                    return (a.name or ""):lower() < (b.name or ""):lower()
                end)

                for _, chapter in ipairs(sortedChapters) do
                    local icon = chapter.known and "- ✅" or "- ❌"
                    local displayName = (CreateMotifLink and CreateMotifLink(chapter.name)) or chapter.name
                    markdown = markdown .. icon .. " " .. displayName .. "\n"
                end
            elseif motif.isCompleted then
                markdown = markdown .. "*All chapters known*\n"
            else
                markdown = markdown .. "*No chapter detail available*\n"
            end

            markdown = markdown .. "</details>\n\n"
        end
    else
        -- Concise view: just list completed and partial ones
        markdown = markdown .. "**Completed:**\n"
        for _, motif in ipairs(knownMotifs) do
            markdown = markdown .. "- ✅ " .. motif.name .. "\n"
        end
        if #partialMotifs > 0 then
            markdown = markdown .. "\n**In Progress:**\n"
            for _, motif in ipairs(partialMotifs) do
                markdown = markdown .. string_format("- 🚧 %s (%d/%d)\n", motif.name, motif.numKnown, motif.total)
            end
        end
    end

    markdown = markdown .. "\n</details>\n\n"
    return markdown
end

-- =====================================================
-- HELPER: GENERATE RECIPES SECTION
-- =====================================================

local function GenerateRecipesSection(craftingData)
    local markdown = ""
    local settings = CM.GetSettings()

    if not craftingData.recipes then
        return markdown
    end

    InitializeUtilities()

    local totalKnown = (craftingData.recipes.all and #craftingData.recipes.all) or 0

    -- Outer collapsible: overall recipe summary
    markdown = markdown .. "<details>\n"
    markdown = markdown .. string_format("<summary>📜 Recipe Knowledge (%d Known)</summary>\n\n", totalKnown)

    if totalKnown == 0 then
        markdown = markdown .. "*No recipes learned yet*\n"
        markdown = markdown .. "\n</details>\n\n"
        return markdown
    end

    -- Overall count display (no bounded total for recipes, so just a note)
    markdown = markdown .. string_format("**Total Known Recipes:** %d\n\n", totalKnown)

    -- Per-category section
    if craftingData.recipes.byList then
        markdown = markdown .. "### 🍽️ Recipes by Category\n\n"

        -- Collect category names and sort alphabetically
        local categoryNames = {}
        for listName, _ in pairs(craftingData.recipes.byList) do
            table.insert(categoryNames, listName)
        end
        table.sort(categoryNames, function(a, b)
            return a:lower() < b:lower()
        end)

        for _, listName in ipairs(categoryNames) do
            local listRecipes = craftingData.recipes.byList[listName]
            if listRecipes and #listRecipes > 0 then
                local count = #listRecipes

                -- Per-category collapsible (matching Collectibles / Motifs layout)
                markdown = markdown .. "<details>\n"
                markdown = markdown .. string_format("<summary>🍽️ %s (%d recipes)</summary>\n\n", listName, count)

                if settings.showRecipesDetailed then
                    -- Sort recipes alphabetically within the category
                    local sortedRecipes = {}
                    for _, recipe in ipairs(listRecipes) do
                        table.insert(sortedRecipes, recipe)
                    end
                    table.sort(sortedRecipes, function(a, b)
                        return (a.name or ""):lower() < (b.name or ""):lower()
                    end)

                    for _, recipe in ipairs(sortedRecipes) do
                        local displayName = (CreateRecipeLink and CreateRecipeLink(recipe.name)) or recipe.name
                        markdown = markdown .. "- " .. displayName .. "\n"
                    end
                    markdown = markdown .. "\n"
                else
                    markdown = markdown .. string_format("*%d recipes known in this category*\n\n", count)
                end

                markdown = markdown .. "</details>\n\n"
            end
        end
    end

    markdown = markdown .. "</details>\n\n"
    return markdown
end

-- =====================================================
-- HELPER: GENERATE RESEARCH SECTION
-- =====================================================

local function GenerateResearchSection(craftingData)
    local markdown = ""

    if not craftingData.research then
        return markdown
    end

    markdown = markdown .. "<details>\n"
    markdown = markdown .. "<summary>🔬 Research Progress</summary>\n\n"

    local craftTypes = {
        { name = "Blacksmithing", key = "blacksmithing", emoji = "⚒️" },
        { name = "Clothing", key = "clothing", emoji = "🧵" },
        { name = "Woodworking", key = "woodworking", emoji = "🪵" },
        { name = "Jewelry", key = "jewelry", emoji = "💎" },
    }

    markdown = markdown .. "| Profession | Progress |\n"
    markdown = markdown .. "| --- | --- |\n"

    InitializeUtilities()
    for _, craftType in ipairs(craftTypes) do
        local progress = craftingData.summary.researchProgress[craftType.key] or 0
        local progressBar = GenerateProgressBar(progress, 15)
        markdown = markdown
            .. string_format("| %s %s | %s %d%% |\n", craftType.emoji, craftType.name, progressBar, progress)
    end
    markdown = markdown .. "\n"

    for _, craftType in ipairs(craftTypes) do
        local researchLines = craftingData.research[craftType.key]
        if researchLines and #researchLines > 0 then
            markdown = markdown .. "#### " .. craftType.emoji .. " " .. craftType.name .. "\n"

            for _, line in ipairs(researchLines) do
                local known = 0
                if line.traits then
                    for _, t in ipairs(line.traits) do
                        if t.known then
                            known = known + 1
                        end
                    end
                end
                markdown = markdown .. "- " .. line.name .. ": " .. known .. "/9 traits\n"
            end
            markdown = markdown .. "\n"
        end
    end

    markdown = markdown .. "</details>\n\n"
    return markdown
end

-- =====================================================
-- CRAFTING KNOWLEDGE
-- =====================================================

local function GenerateCrafting(craftingData)
    InitializeUtilities()

    local markdown = ""

    if not craftingData then
        return ""
    end

    local anchorId = GenerateAnchor and GenerateAnchor("🔨 Crafting Knowledge") or "crafting-knowledge"
    markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
    markdown = markdown .. "## 🔨 Crafting Knowledge\n\n"

    -- Stack sections vertically (matching Collectibles layout)
    markdown = markdown .. GenerateMotifsSection(craftingData)
    markdown = markdown .. GenerateRecipesSection(craftingData)
    markdown = markdown .. GenerateResearchSection(craftingData)

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
CM.generators.sections.GenerateCrafting = GenerateCrafting
