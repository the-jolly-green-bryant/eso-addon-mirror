-- CharacterMarkdown - DLC, Mundus, and Collectibles Section Generators
-- Generates DLC Access, Mundus Stone, and Collectibles sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateMundusLink, CreateCollectibleLink
local FormatNumber, GenerateProgressBar, GenerateAnchor
local string_format = string.format

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        CreateMundusLink = CM.links.CreateMundusLink
        CreateCollectibleLink = CM.links.CreateCollectibleLink
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        GenerateAnchor = (CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor) or nil
    end
end

-- =====================================================
-- DLC ACCESS
-- =====================================================

local function GenerateDLCAccess(dlcData)
    local markdown = ""

    -- Handle nil or empty dlcData
    if not dlcData then
        dlcData = {}
    end

    -- Ensure accessible array exists
    if not dlcData.accessible then
        dlcData.accessible = {}
    end
    if not dlcData.locked then
        dlcData.locked = {}
    end

    -- If ESO Plus active, show section with ESO Plus status AND list all accessible DLCs
    if dlcData.hasESOPlus then
        InitializeUtilities()
        local anchorId = GenerateAnchor and GenerateAnchor("🗺️ DLC & Chapter Access") or "dlc--chapter-access"
        markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## 🗺️ DLC & Chapter Access\n\n"

        -- Show all accessible DLCs (purchased or via ESO Plus)
        if #dlcData.accessible > 0 then
            for _, dlcName in ipairs(dlcData.accessible) do
                markdown = markdown .. "- ✅ " .. dlcName .. "\n"
            end
            markdown = markdown .. "\n"
        end

        markdown = markdown .. "**ESO Plus Active** - All DLCs and Chapters are accessible.\n\n"
        -- Use CreateSeparator for consistent separator styling
        local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
        if CreateSeparator then
            markdown = markdown .. CreateSeparator("hr")
        else
            markdown = markdown .. "---\n\n"
        end
        return markdown
    end

    -- Only show DLC section if user does NOT have ESO Plus
    InitializeUtilities()
    local anchorId = GenerateAnchor and GenerateAnchor("🗺️ DLC & Chapter Access") or "dlc--chapter-access"
    markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
    markdown = markdown .. "## 🗺️ DLC & Chapter Access\n\n"

    -- Show accessible DLCs
    if #dlcData.accessible > 0 then
        markdown = markdown .. "### ✅ Accessible DLCs\n\n"
        for _, dlcName in ipairs(dlcData.accessible) do
            markdown = markdown .. "- ✅ " .. dlcName .. "\n"
        end
        markdown = markdown .. "\n"
    end

    -- Show locked DLCs
    if #dlcData.locked > 0 then
        markdown = markdown .. "### 🔒 Locked DLCs\n\n"
        for _, dlcName in ipairs(dlcData.locked) do
            markdown = markdown .. "- 🔒 " .. dlcName .. "\n"
        end
        markdown = markdown .. "\n"
    end

    -- If no accessible or locked content, show a message
    if #dlcData.accessible == 0 and #dlcData.locked == 0 then
        markdown = markdown .. "*No DLC access information available*\n\n"
    end

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
-- MUNDUS STONE
-- =====================================================

local function GenerateMundus(mundusData)
    InitializeUtilities()

    if not mundusData then
        return ""
    end

    local markdown = ""

    InitializeUtilities()
    local anchorId = GenerateAnchor and GenerateAnchor("🪨 Mundus Stone") or "mundus-stone"
    markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
    markdown = markdown .. "## 🪨 Mundus Stone\n\n"
    if mundusData.active then
        local mundusText = CreateMundusLink(mundusData.name)
        markdown = markdown .. "✅ **Active:** " .. mundusText .. "\n\n"
    else
        markdown = markdown .. "⚠️ **No Active Mundus Stone**\n\n"
    end

    markdown = markdown .. "---\n\n"

    return markdown
end

-- =====================================================
-- COLLECTIBLES
-- =====================================================

-- Helper function to generate DLC content in collectibles format
local function GenerateDLCAsCollectible(dlcData)
    if not dlcData then
        return ""
    end

    local content = ""

    if dlcData.hasESOPlus then
        if dlcData.accessible and #dlcData.accessible > 0 then
            for _, dlcName in ipairs(dlcData.accessible) do
                content = content .. "- ✅ " .. dlcName .. "\n"
            end
        end

        local esoPlusText = "ESO Plus Active"
        local settings = CharacterMarkdownSettings or {}
        if settings.esoPlusExpirationDate and settings.esoPlusExpirationDate ~= "" then
            esoPlusText = string_format("ESO Plus Active (exp %s)", settings.esoPlusExpirationDate)
        end
        content = content .. "\n**" .. esoPlusText .. "** - All DLCs and Chapters are accessible.\n\n"
    else
        -- Show accessible and locked content
        if dlcData.accessible and #dlcData.accessible > 0 then
            for _, dlcName in ipairs(dlcData.accessible) do
                content = content .. "- ✅ " .. dlcName .. "\n"
            end
            content = content .. "\n"
        end

        if dlcData.locked and #dlcData.locked > 0 then
            content = content .. "### 🔒 Locked Content\n\n"
            for _, dlcName in ipairs(dlcData.locked) do
                content = content .. "- 🔒 " .. dlcName .. "\n"
            end
        end

        if (not dlcData.accessible or #dlcData.accessible == 0) and (not dlcData.locked or #dlcData.locked == 0) then
            content = content .. "*No DLC access information available*\n"
        end
    end

    if content == "" then
        return ""
    end

    -- Count total DLCs
    local totalDLCs = 0
    local accessibleCount = (dlcData.accessible and #dlcData.accessible) or 0
    local lockedCount = (dlcData.locked and #dlcData.locked) or 0
    totalDLCs = accessibleCount + lockedCount

    -- Create collapsible details block
    local summaryText = "🗺️ DLC & Chapter Access"
    if totalDLCs > 0 then
        summaryText = summaryText .. " (" .. accessibleCount .. " accessible"
        if lockedCount > 0 then
            summaryText = summaryText .. ", " .. lockedCount .. " locked"
        end
        summaryText = summaryText .. ")"
    end

    return "<details>\n<summary>" .. summaryText .. "</summary>\n\n" .. content .. "\n</details>\n\n"
end

local function GenerateCollectibles(collectiblesData, _, dlcData, lorebooksData, titlesHousingData, ridingData)
    local markdown = ""

    -- Check if we have detailed data enabled
    local hasDetailedData = collectiblesData.hasDetailedData
    local settings = CharacterMarkdownSettings or {}
    local includeDetailed = settings.showCollectiblesDetailed or false

    -- Only show section if there's content to display
    -- Check if we should show anything
    local hasContent = false

    -- Check if detailed mode has content
    if includeDetailed and hasDetailedData and collectiblesData.categories then
        hasContent = true
    end

    -- Check if fallback mode has content (any counts > 0)
    if not hasContent then
        local collections = collectiblesData.collections or {}
        if
            (collections.mounts and collections.mounts.count and collections.mounts.count > 0)
            or (collections.pets and collections.pets.count and collections.pets.count > 0)
            or (collections.costumes and collections.costumes.count and collections.costumes.count > 0)
            or (collections.skins and collections.skins.count and collections.skins.count > 0)
            or (collections.polymorphs and collections.polymorphs.count and collections.polymorphs.count > 0)
        then
            hasContent = true
        end
    end

    -- Check if titles/housing would add content (respect section toggles)
    if not hasContent and titlesHousingData then
        local titlesData = titlesHousingData.titles or {}
        local housingData = titlesHousingData.housing or {}

        if settings.includeTitlesHousing then
            local hasTitles = (titlesData.total and titlesData.total > 0)
                or (titlesData.summary and titlesData.summary.totalAvailable and titlesData.summary.totalAvailable > 0)
                or (titlesData.owned and #titlesData.owned > 0)
                or (titlesData.current and titlesData.current ~= "")

            if hasTitles then
                hasContent = true
            end
        end

        if not hasContent and settings.includeHousing then
            local hasHousing = (housingData.total and housingData.total > 0)
                or (housingData.summary and housingData.summary.totalOwned and housingData.summary.totalOwned > 0)
                or (housingData.owned and #housingData.owned > 0)
                or (housingData.primary and housingData.primary.name)

            if hasHousing then
                hasContent = true
            end
        end
    end

    -- Check if DLC would add content
    if not hasContent and dlcData and settings.includeDLCAccess then
        if
            (dlcData.accessible and #dlcData.accessible > 0)
            or (dlcData.locked and #dlcData.locked > 0)
            or dlcData.hasESOPlus
        then
            hasContent = true
        end
    end

    -- Check if DLC would add content
    if not hasContent and dlcData and settings.includeDLCAccess then
        if
            (dlcData.accessible and #dlcData.accessible > 0)
            or (dlcData.locked and #dlcData.locked > 0)
            or dlcData.hasESOPlus
        then
            hasContent = true
        end
    end

    -- Only create section if we have content to show
    if not hasContent then
        return ""
    end

    -- GitHub/VSCode: Show collapsible detailed lists
    InitializeUtilities()
    markdown = markdown .. "## 🎨 Collectibles\n\n"

    -- List to hold all sections for sorting
    local sections = {}

    -- 1. DLC Access
    local includeDLCAccess = settings.includeDLCAccess
    if includeDLCAccess == nil then
        includeDLCAccess = false -- Default to false per Defaults.lua
    end

    if dlcData and includeDLCAccess then
        local dlcContent = GenerateDLCAsCollectible(dlcData)
        if dlcContent ~= "" then
            table.insert(sections, {
                sortKey = "DLC & Chapter Access",
                content = dlcContent,
            })
        end
    end

    -- 2. Standard Categories
    local categories = {
        { key = "assistants", name = "Assistants", emoji = "💁" },
        { key = "bodyMarkings", name = "Body Markings", emoji = "🖌️" },
        { key = "costumes", name = "Costumes", emoji = "👗" },
        { key = "emotes", name = "Emotes", emoji = "🗣️" },
        { key = "facialAccessories", name = "Facial Accessories", emoji = "👓" },
        { key = "hair", name = "Hair Styles", emoji = "💇" },
        { key = "hats", name = "Hats", emoji = "🎩" },
        { key = "headMarkings", name = "Head Markings", emoji = "🖍️" },
        { key = "mementos", name = "Mementos", emoji = "🔮" },
        { key = "mounts", name = "Mounts", emoji = "🐴" },
        { key = "personalities", name = "Personalities", emoji = "🎭" },
        { key = "pets", name = "Pets", emoji = "🐾" },
        { key = "piercings", name = "Piercings", emoji = "💍" },
        { key = "polymorphs", name = "Polymorphs", emoji = "✨" },
        { key = "skins", name = "Skins", emoji = "🎭" },
    }

    local collections = collectiblesData.collections or {}

    for _, cat in ipairs(categories) do
        local collection = collections[cat.key]
        if collection and collection.total and collection.total > 0 then
            local owned = collection.count or 0
            local total = collection.total or 0

            local sectionContent = ""

            -- Collapsible section header
            sectionContent = sectionContent .. "<details>\n"
            sectionContent = sectionContent
                .. "<summary>"
                .. cat.emoji
                .. " "
                .. cat.name
                .. " ("
                .. owned
                .. " of "
                .. total
                .. ")</summary>\n\n"

            -- Add progress bar
            InitializeUtilities()
            local progress = math.floor((owned / total) * 100)
            local progressBar = GenerateProgressBar(progress, 20)
            sectionContent = sectionContent .. "| Progress |\n"
            sectionContent = sectionContent .. "| --- |\n"
            sectionContent = sectionContent
                .. "| "
                .. progressBar
                .. " "
                .. progress
                .. "% ("
                .. owned
                .. "/"
                .. total
                .. ") |\n\n"

            -- List owned collectibles (alphabetically sorted)
            if owned > 0 and collection.list then
                -- Sort in-place to ensure consistent ordering
                table.sort(collection.list, function(a, b)
                    local nameA = (a.name or ""):lower()
                    local nameB = (b.name or ""):lower()
                    return nameA < nameB
                end)

                for _, collectible in ipairs(collection.list) do
                    InitializeUtilities()
                    -- Use fullName for links (UESP uses full names), display name for text
                    local linkName = collectible.fullName or collectible.name
                    local displayName = collectible.name
                    local collectibleLink = (CreateCollectibleLink and CreateCollectibleLink(linkName)) or displayName
                    sectionContent = sectionContent .. "- " .. collectibleLink
                    -- Add rarity if available
                    if collectible.quality then
                        sectionContent = sectionContent .. " [" .. collectible.quality .. "]"
                    end
                    sectionContent = sectionContent .. "\n"
                end
            else
                sectionContent = sectionContent .. "*No " .. cat.name:lower() .. " owned*\n"
            end

            sectionContent = sectionContent .. "</details>\n\n"

            table.insert(sections, {
                sortKey = cat.name,
                content = sectionContent,
            })
        end
    end

    -- 3. Lorebooks
    if lorebooksData then
        local GenerateLorebooks = CM.generators.sections.GenerateLorebooks
        if GenerateLorebooks then
            local lorebooksContent = GenerateLorebooks(lorebooksData)
            -- Content is already in collapsible format
            if lorebooksContent ~= "" then
                table.insert(sections, {
                    sortKey = "Lorebooks",
                    content = lorebooksContent,
                })
            end
        end
    end

    -- 4. Titles & Housing (gated by includeTitlesHousing / includeHousing)
    if titlesHousingData then
        local GenerateTitles = CM.generators.sections.GenerateTitles
        local GenerateHousing = CM.generators.sections.GenerateHousing
        if GenerateTitles and GenerateHousing then
            local titlesData = titlesHousingData.titles or {}
            local housingData = titlesHousingData.housing or {}

            -- Generate Titles section (collapsible)
            -- Check for total (legacy), summary.totalAvailable (new), or owned list (new)
            local hasTitles = (titlesData.total and titlesData.total > 0)
                or (titlesData.summary and titlesData.summary.totalAvailable and titlesData.summary.totalAvailable > 0)
                or (titlesData.list and #titlesData.list > 0)
                or (titlesData.owned and #titlesData.owned > 0)

            if settings.includeTitlesHousing and titlesData and hasTitles then
                local titlesContent = GenerateTitles(titlesData)
                -- Remove header if present (will be in summary)
                titlesContent = titlesContent:gsub("^###%s+👑%s+Titles%s*\n%s*\n", "")

                if titlesContent ~= "" then
                    -- Count owned titles
                    local owned = 0
                    if titlesData.summary and titlesData.summary.totalOwned then
                        owned = titlesData.summary.totalOwned
                    elseif titlesData.owned and type(titlesData.owned) == "table" then
                        owned = #titlesData.owned
                    else
                        owned = 0
                    end
                    local total = (titlesData.summary and titlesData.summary.totalAvailable) or 0

                    local sectionContent = ""
                    sectionContent = sectionContent .. "<details>\n"
                    sectionContent = sectionContent
                        .. "<summary>👑 Titles ("
                        .. owned
                        .. " of "
                        .. total
                        .. ")</summary>\n\n"
                    sectionContent = sectionContent .. titlesContent
                    sectionContent = sectionContent .. "</details>\n\n"

                    table.insert(sections, {
                        sortKey = "Titles",
                        content = sectionContent,
                    })
                end
            end

            -- Generate Housing section (collapsible)
            -- Check for total (legacy), summary.totalOwned (new), or owned list (new)
            local hasHousing = (housingData.total and housingData.total > 0)
                or (housingData.summary and housingData.summary.totalAvailable and housingData.summary.totalAvailable > 0)
                or (housingData.owned and #housingData.owned > 0)

            if settings.includeHousing and housingData and hasHousing then
                local housingContent = GenerateHousing(housingData)
                -- Remove header if present (will be in summary)
                housingContent = housingContent:gsub("^###%s+🏠%s+Housing%s*\n%s*\n", "")

                if housingContent ~= "" then
                    local owned = 0
                    if housingData.summary and housingData.summary.totalOwned then
                        owned = housingData.summary.totalOwned
                    elseif housingData.owned and type(housingData.owned) == "table" then
                        owned = #housingData.owned
                    end
                    local total = (housingData.summary and housingData.summary.totalAvailable) or 0

                    local sectionContent = ""
                    sectionContent = sectionContent .. "<details>\n"
                    sectionContent = sectionContent
                        .. "<summary>🏠 Housing ("
                        .. owned
                        .. " of "
                        .. total
                        .. ")</summary>\n\n"
                    sectionContent = sectionContent .. housingContent
                    sectionContent = sectionContent .. "</details>\n\n"

                    table.insert(sections, {
                        sortKey = "Housing",
                        content = sectionContent,
                    })
                end
            end
        end
    end

    -- Sort all sections alphabetically by sortKey
    table.sort(sections, function(a, b)
        return a.sortKey:lower() < b.sortKey:lower()
    end)

    -- Concatenate sorted sections
    for _, section in ipairs(sections) do
        markdown = markdown .. section.content
    end

    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateDLCAccess = GenerateDLCAccess
CM.generators.sections.GenerateMundus = GenerateMundus
CM.generators.sections.GenerateCollectibles = GenerateCollectibles
