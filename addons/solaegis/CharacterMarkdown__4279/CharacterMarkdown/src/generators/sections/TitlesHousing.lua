-- CharacterMarkdown - Titles & Housing Section Generators
-- Generates titles and housing-related markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateProgressBar, CreateTitleLink, CreateHouseLink, GenerateAnchor

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        CreateTitleLink = CM.links.CreateTitleLink
        CreateHouseLink = CM.links.CreateHouseLink
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
    end
end

-- =====================================================
-- TITLES
-- =====================================================

local function GenerateTitles(titlesData)
    InitializeUtilities()

    local markdown = ""

    -- Always show section if enabled, even if collector failed
    -- Check if we have a current title OR any titles data
    if not titlesData then
        titlesData = {}
    end

    -- Extract summary data
    local totalOwned = (titlesData.summary and titlesData.summary.totalOwned)
        or (titlesData.owned and #titlesData.owned)
        or 0
    local totalAvailable = (titlesData.summary and titlesData.summary.totalAvailable) or titlesData.total or 0

    -- Fallback: Try to get title from character data if collector failed
    if not titlesData.current or titlesData.current == "" then
        -- Check custom title in both CM.charData and CharacterMarkdownData
        local customTitle = ""
        if CM.charData and CM.charData.customTitle and CM.charData.customTitle ~= "" then
            customTitle = CM.charData.customTitle
        elseif
            CharacterMarkdownData
            and CharacterMarkdownData.customTitle
            and CharacterMarkdownData.customTitle ~= ""
        then
            customTitle = CharacterMarkdownData.customTitle
            -- Sync to CM.charData if it exists (for consistency)
            if CM.charData then
                CM.charData.customTitle = customTitle
            end
        end

        if customTitle ~= "" then
            titlesData.current = customTitle
        else
            -- Try API directly as last resort (using GetUnitTitle for simplicity)
            local GetUnitTitleFunc = rawget(_G, "GetUnitTitle")
            if GetUnitTitleFunc and type(GetUnitTitleFunc) == "function" then
                local success, apiTitle = pcall(GetUnitTitleFunc, "player")
                if success and apiTitle and apiTitle ~= "" then
                    titlesData.current = apiTitle
                end
            end
        end
    end

    -- Always show section if we have a current title, even if collector failed
    if titlesData.current and titlesData.current ~= "" then
        -- We have a title, show the section - continue below
    elseif totalAvailable == 0 and totalOwned == 0 then
        -- No titles data available at all
        markdown = markdown .. "### 👑 Titles\n\n"
        markdown = markdown .. "*No titles available*\n\n"
        return markdown
    end

    if true then
        markdown = markdown .. "### 👑 Titles\n\n"

        -- Current Title removed - now shown in Overview section

        -- Add progress bar if we have total count
        if totalAvailable > 0 then
            local progress = math.floor((totalOwned / totalAvailable) * 100)
            local progressBar = GenerateProgressBar(progress, 20)
            markdown = markdown .. "| Progress |\n"
            markdown = markdown .. "| --- |\n"
            markdown = markdown
                .. "| "
                .. progressBar
                .. " "
                .. progress
                .. "% ("
                .. totalOwned
                .. "/"
                .. totalAvailable
                .. ") |\n\n"
        end

        -- Show all owned titles as a list
        if titlesData.owned and #titlesData.owned > 0 then
            local ownedTitles = {}
            for _, title in ipairs(titlesData.owned) do
                table.insert(ownedTitles, title.name)
            end

            if #ownedTitles > 0 then
                markdown = markdown .. "**Owned Titles:**\n"
                for _, titleName in ipairs(ownedTitles) do
                    local titleLink = (CreateTitleLink and CreateTitleLink(titleName)) or titleName
                    markdown = markdown .. "• " .. titleLink .. "\n"
                end
                markdown = markdown .. "\n"
            else
                markdown = markdown .. "*No titles owned*\n\n"
            end
        elseif totalAvailable > 0 then
            -- Show count if we have total but no list
            markdown = markdown .. "**Owned:** " .. totalOwned .. "/" .. totalAvailable .. "\n\n"
        elseif titlesData.current and titlesData.current ~= "" then
            -- We have a current title but no total count - collector may have failed
            markdown = markdown
                .. "*Total count unavailable (collector may have failed, but you have the title: "
                .. titlesData.current
                .. ")*\n\n"
        end
    end

    return markdown
end

-- =====================================================
-- HOUSING
-- =====================================================

local function GenerateHousing(housingData)
    InitializeUtilities()

    local markdown = ""

    if not housingData then
        housingData = {}
    end

    -- Extract summary data
    local totalOwned = (housingData.summary and housingData.summary.totalOwned)
        or (housingData.owned and #housingData.owned)
        or 0
    local totalAvailable = (housingData.summary and housingData.summary.totalAvailable) or housingData.total or 0

    if totalOwned == 0 then
        -- Show placeholder when section enabled but no housing
        if true then
            markdown = markdown .. "### 🏠 Housing\n\n"
            markdown = markdown .. "*No houses owned*\n\n"
        end
        return markdown
    end

    if true then
        markdown = markdown .. "### 🏠 Housing\n\n"

        if housingData.primary and housingData.primary.name then
            local primaryName = housingData.primary.name
            local primaryLink = (CreateHouseLink and CreateHouseLink(primaryName)) or primaryName
            markdown = markdown .. "**Primary Residence:** " .. primaryLink .. "\n\n"
        end

        if totalAvailable > 0 then
            local progress = math.floor((totalOwned / totalAvailable) * 100)
            local progressBar = GenerateProgressBar(progress, 20)
            markdown = markdown .. "| Progress |\n"
            markdown = markdown .. "| --- |\n"
            markdown = markdown
                .. "| "
                .. progressBar
                .. " "
                .. progress
                .. "% ("
                .. totalOwned
                .. "/"
                .. totalAvailable
                .. ") |\n\n"
        else
            -- Just show count if total is unknown
            markdown = markdown .. "**Total Owned:** " .. totalOwned .. "\n\n"
        end

        -- Show owned houses
        local ownedHouses = {}
        if housingData.owned and #housingData.owned > 0 then
            for _, house in ipairs(housingData.owned) do
                table.insert(ownedHouses, house.name)
            end
        end

        if #ownedHouses > 0 then
            markdown = markdown .. "**Owned Houses:**\n"
            for _, houseName in ipairs(ownedHouses) do
                local houseLink = (CreateHouseLink and CreateHouseLink(houseName)) or houseName
                markdown = markdown .. "• " .. houseLink .. "\n"
            end
            markdown = markdown .. "\n"
        end
    end

    return markdown
end

-- =====================================================
-- HOUSING COLLECTIONS
-- =====================================================

local function GenerateHousingCollections(collectionsData)
    InitializeUtilities()

    local markdown = ""

    if
        not collectionsData
        or not collectionsData.furniture
        or not collectionsData.furniture.total
        or collectionsData.furniture.total == 0
    then
        -- Show placeholder when section enabled but no furniture
        if true then
            markdown = markdown .. "### 🪑 Housing Collections\n\n"
            markdown = markdown .. "*No furniture collections data available*\n\n"
        end
        return markdown
    end

    if true then
        markdown = markdown .. "### 🪑 Housing Collections\n\n"

        -- Furniture summary
        local furnitureProgress = math.floor((collectionsData.furniture.owned / collectionsData.furniture.total) * 100)
        local furnitureProgressBar = GenerateProgressBar(furnitureProgress, 20)
        markdown = markdown .. "#### Furniture\n\n"
        markdown = markdown .. "| Progress |\n"
        markdown = markdown .. "| --- |\n"
        markdown = markdown
            .. "| "
            .. furnitureProgressBar
            .. " "
            .. furnitureProgress
            .. "% ("
            .. collectionsData.furniture.owned
            .. "/"
            .. collectionsData.furniture.total
            .. ") |\n\n"

        -- Furniture categories
        markdown = markdown .. "| Category | Owned | Total | Progress |\n"
        markdown = markdown .. "|:---------|:------|:------|:--------|\n"

        for categoryName, categoryData in pairs(collectionsData.furniture.categories) do
            if categoryData.total > 0 then
                local categoryProgress = math.floor((categoryData.owned / categoryData.total) * 100)
                local categoryProgressBar = GenerateProgressBar(categoryProgress, 15)
                markdown = markdown
                    .. "| **"
                    .. categoryName
                    .. "** | "
                    .. categoryData.owned
                    .. " | "
                    .. categoryData.total
                    .. " | "
                    .. categoryProgressBar
                    .. " "
                    .. categoryProgress
                    .. "% |\n"
            end
        end
        markdown = markdown .. "\n"
    end

    return markdown
end

-- =====================================================
-- MAIN TITLES & HOUSING GENERATOR
-- =====================================================

local function GenerateTitlesHousing(titlesHousingData)
    InitializeUtilities()

    local markdown = ""

    if not titlesHousingData then
        -- Show placeholder when enabled but no data available
        if true then
            local anchorId = GenerateAnchor and GenerateAnchor("🏆 Titles & Housing") or "titles--housing"
            markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
            markdown = markdown .. "## 🏆 Titles & Housing\n\n"
            markdown = markdown .. "*No titles or housing data available*\n\n---\n\n"
        end
        return markdown
    end

    -- Always show the section when enabled (even if data is minimal/zero)
    if true then
        local anchorId = GenerateAnchor and GenerateAnchor("🏆 Titles & Housing") or "titles--housing"
        markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## 🏆 Titles & Housing\n\n"
    end

    -- Add each subsection (they handle their own empty states)
    -- Ensure we have data structures even if collector failed
    local titlesData = titlesHousingData and titlesHousingData.titles or {}
    local housingData = titlesHousingData and titlesHousingData.housing or {}
    local collectionsData = titlesHousingData and titlesHousingData.collections or {}

    markdown = markdown .. GenerateTitles(titlesData)
    markdown = markdown .. GenerateHousing(housingData)
    -- Housing Collections removed per user request
    -- markdown = markdown .. GenerateHousingCollections(collectionsData)

    -- Add divider for GitHub/VSCode format
    if true then
        -- Use CreateSeparator for consistent separator styling
        local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
        if CreateSeparator then
            markdown = markdown .. CreateSeparator("hr")
        else
            markdown = markdown .. "---\n\n"
        end
    end

    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateTitlesHousing = GenerateTitlesHousing
CM.generators.sections.GenerateTitles = GenerateTitles
CM.generators.sections.GenerateHousing = GenerateHousing
CM.generators.sections.GenerateHousingCollections = GenerateHousingCollections
