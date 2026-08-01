-- CharacterMarkdown - Economy Section Generators
-- Generates economy-related markdown sections (currency, inventory, riding)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, CreateCampaignLink, CreateCurrencyLink, markdown
local string_format = string.format
local string_rep = string.rep

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        CreateCampaignLink = CM.links.CreateCampaignLink
        CreateCurrencyLink = CM.links.CreateCurrencyLink
        markdown = CM.utils.markdown
    end
end

-- Append a styled table or plain markdown fallback when utils are unavailable
local function AppendStyledTable(result, headers, rows, options)
    local CreateStyledTable = (markdown and markdown.CreateStyledTable)
        or (CM.utils.markdown and CM.utils.markdown.CreateStyledTable)
    if CreateStyledTable then
        return result .. CreateStyledTable(headers, rows, options)
    end
    local lines = {}
    table.insert(lines, "| " .. table.concat(headers, " | ") .. " |")
    local alignRow = {}
    for i = 1, #headers do
        alignRow[i] = (options and options.alignment and options.alignment[i] == "left") and ":---" or "---:"
    end
    table.insert(lines, "| " .. table.concat(alignRow, " | ") .. " |")
    for _, row in ipairs(rows) do
        table.insert(lines, "| " .. table.concat(row, " | ") .. " |")
    end
    return result .. table.concat(lines, "\n") .. "\n"
end

-- =====================================================
-- CURRENCY
-- =====================================================

local function GenerateCurrency(currencyData)
    InitializeUtilities()

    if not currencyData then
        return ""
    end

    -- Helper to format currency values (with optional max)
    local function FormatValue(current, max)
        local currentStr = CM.utils.FormatNumber(current or 0)
        -- Always show max if it exists and is greater than 0
        if max and max > 0 then
            return currentStr .. "/" .. CM.utils.FormatNumber(max)
        end
        return currentStr
    end

    -- Define all currencies with their labels and values (matching user's format)
    local currencies = {
        { label = "💰 **Gold**", value = FormatValue(currencyData.gold) },
        { label = "⚔️ **Alliance Points**", value = FormatValue(currencyData.ap) },
        { label = "🔮 **Tel Var**", value = FormatValue(currencyData.telvar) },
        {
            label = "💎 **Transmute Crystals**",
            value = FormatValue(currencyData.transmute, currencyData.transmuteMax),
        },
        { label = "📜 **Writs**", value = FormatValue(currencyData.vouchers) },
        {
            label = "🎫 **Event Tickets**",
            value = FormatValue(currencyData.eventTickets, currencyData.eventTicketsMax),
        },
        { label = "👑 **Crowns**", value = FormatValue(currencyData.crowns) },
        { label = "💠 **Gems**", value = FormatValue(currencyData.gems) },
        { label = "🏅 **Seals**", value = FormatValue(currencyData.seals) },
        { label = "🗝️ **Keys**", value = FormatValue(currencyData.undauntedKeys) },
        { label = "👕 **Tokens**", value = FormatValue(currencyData.outfitTokens) },
        { label = "📚 **Fortunes**", value = FormatValue(currencyData.archivalFortunes) },
        { label = "🔹 **Fragments**", value = FormatValue(currencyData.imperialFragments) },
    }

    -- Markdown Table Format
    local result = '<a id="currency"></a>\n\n### Currency\n\n'

    local headers = { "Attribute", "Value" }
    local rows = {}

    for _, item in ipairs(currencies) do
        -- Labels already include bold formatting
        table.insert(rows, { item.label, item.value })
    end

    local options = {
        alignment = { "left", "left" },
        coloredHeaders = true,
    }
    result = AppendStyledTable(result, headers, rows, options)

    return result
end

CM.generators.sections.GenerateCurrency = GenerateCurrency

-- =====================================================
-- RIDING SKILLS
-- =====================================================

local function GenerateRidingSkills(ridingData)
    InitializeUtilities()

    if not ridingData then
        return ""
    end

    -- Enhanced visuals are now always enabled (baseline)
    local speed = ridingData.speed or 0
    local stamina = ridingData.stamina or 0
    local capacity = ridingData.capacity or 0
    local maxRiding = 60

    -- ENHANCED: Progress bars (with nil checks)
    local progressBars = {}
    if markdown and markdown.CreateProgressBar then
        -- Calculate progress bars manually with aligned labels
        local speedPercent = math.floor((speed / maxRiding) * 100)
        local staminaPercent = math.floor((stamina / maxRiding) * 100)
        local capacityPercent = math.floor((capacity / maxRiding) * 100)

        local speedFilled = math.floor((speedPercent / 100) * 20)
        local staminaFilled = math.floor((staminaPercent / 100) * 20)
        local capacityFilled = math.floor((capacityPercent / 100) * 20)

        -- Align colons: "Speed:" (5) + 3 spaces = 8, "Stamina:" (7) + 1 space = 8, "Capacity:" (8) = 8
        local speedBar = string_format(
            "%8s %s%s %d%% (%d/%d)",
            "Speed:",
            string_rep("█", speedFilled),
            string_rep("░", 20 - speedFilled),
            speedPercent,
            speed,
            maxRiding
        )
        local staminaBar = string_format(
            "%8s %s%s %d%% (%d/%d)",
            "Stamina:",
            string_rep("█", staminaFilled),
            string_rep("░", 20 - staminaFilled),
            staminaPercent,
            stamina,
            maxRiding
        )
        local capacityBar = string_format(
            "%8s %s%s %d%% (%d/%d)",
            "Capacity:",
            string_rep("█", capacityFilled),
            string_rep("░", 20 - capacityFilled),
            capacityPercent,
            capacity,
            maxRiding
        )

        table.insert(progressBars, speedBar)
        table.insert(progressBars, staminaBar)
        table.insert(progressBars, capacityBar)
    else
        -- Fallback: Use fixed-width format for alignment
        local speedPercent = math.floor((speed / maxRiding) * 100)
        local staminaPercent = math.floor((stamina / maxRiding) * 100)
        local capacityPercent = math.floor((capacity / maxRiding) * 100)

        local speedFilled = math.floor((speedPercent / 100) * 20)
        local staminaFilled = math.floor((staminaPercent / 100) * 20)
        local capacityFilled = math.floor((capacityPercent / 100) * 20)

        -- Align colons: "Speed:" (6) + 2 spaces = 8, "Stamina:" (7) + 1 space = 8, "Capacity:" (8) = 8
        -- Use left-alignment (%-8s) to pad labels on the right, aligning colons
        local speedBar = string_format(
            "%-8s %s%s %d%% (%d/%d)",
            "Speed:",
            string_rep("█", speedFilled),
            string_rep("░", 20 - speedFilled),
            speedPercent,
            speed,
            maxRiding
        )
        local staminaBar = string_format(
            "%-8s %s%s %d%% (%d/%d)",
            "Stamina:",
            string_rep("█", staminaFilled),
            string_rep("░", 20 - staminaFilled),
            staminaPercent,
            stamina,
            maxRiding
        )
        local capacityBar = string_format(
            "%-8s %s%s %d%% (%d/%d)",
            "Capacity:",
            string_rep("█", capacityFilled),
            string_rep("░", 20 - capacityFilled),
            capacityPercent,
            capacity,
            maxRiding
        )
        table.insert(progressBars, speedBar)
        table.insert(progressBars, staminaBar)
        table.insert(progressBars, capacityBar)
    end

    local content = table.concat(progressBars, "  \n")

    if markdown.CreateCollapsible then
        local collapsible = markdown.CreateCollapsible("Riding Skills", content, "🐴", false)
        return collapsible or (string.format("## 🐴 Riding Skills\n\n%s\n\n", content))
    else
        return string.format("## 🐴 Riding Skills\n\n%s\n\n", content)
    end
end

CM.generators.sections.GenerateRidingSkills = GenerateRidingSkills

-- =====================================================
-- INVENTORY
-- =====================================================

-- Helper: Get quality emoji/symbol
local function GetQualitySymbol(quality)
    local qualityMap = {
        [0] = "⚪", -- Trash/Normal
        [1] = "⚪", -- Normal/Fine
        [2] = "🟢", -- Superior (Green)
        [3] = "🔵", -- Artifact (Blue)
        [4] = "🟣", -- Epic (Purple)
        [5] = "🟡", -- Legendary (Gold)
    }
    return qualityMap[quality] or "⚪"
end

-- Helper: Generate item list for a specific container
local function GenerateItemList(items, containerName)
    if not items or #items == 0 then
        return ""
    end

    local result = ""

    -- Group items by category (itemTypeName)
    local categories = {}

    for _, item in ipairs(items) do
        local category = item.itemTypeName or "Other"
        if category == "" then
            category = "Other"
        end
        if not categories[category] then
            categories[category] = {}
        end
        table.insert(categories[category], item)
    end

    -- Sort categories alphabetically
    local sortedCategories = {}
    for category, categoryItems in pairs(categories) do
        table.insert(sortedCategories, { name = category, items = categoryItems })
    end
    table.sort(sortedCategories, function(a, b)
        return a.name:lower() < b.name:lower()
    end)

    result = result .. "<details>\n"
    result = result
        .. "<summary><strong>"
        .. containerName
        .. " Items</strong> ("
        .. #items
        .. " unique items)</summary>\n\n"

    -- Generate a table for each category
    local CreateStyledTable = CM.utils.markdown.CreateStyledTable
    local CreateResponsiveColumns = CM.utils.markdown.CreateResponsiveColumns
    local headers = { "Item", "Stack", "Quality" }
    local options = {
        alignment = { "left", "right", "left" },
        coloredHeaders = true,
    }

    -- For craft bag, use multi-column layout for better space efficiency
    -- Skip alphabetical sorting within categories for better performance
    local useMultiColumn = (containerName == "Crafting Bag") and CreateResponsiveColumns

    if useMultiColumn and #sortedCategories > 1 then
        -- Multi-column layout: collect all category tables first
        local categoryTables = {}

        for _, categoryData in ipairs(sortedCategories) do
            local categoryName = categoryData.name
            local categoryItems = categoryData.items

            -- Build table for this category (no sorting for efficiency)
            local rows = {}
            for _, item in ipairs(categoryItems) do
                local qualitySymbol = GetQualitySymbol(item.quality)
                local stackText = item.stack > 1 and tostring(item.stack) or "1"
                table.insert(rows, { qualitySymbol .. " " .. item.name, stackText, qualitySymbol })
            end

            -- Create table with category header embedded
            local categoryTable = "#### " .. categoryName .. " (" .. #categoryItems .. " items)\n\n"
            categoryTable = AppendStyledTable(categoryTable, headers, rows, options)
            table.insert(categoryTables, categoryTable)
        end

        -- Use LayoutCalculator for optimal sizing
        local LayoutCalculator = CM.utils.LayoutCalculator
        local minWidth, gap
        if LayoutCalculator then
            minWidth, gap = LayoutCalculator.GetLayoutParamsWithFallback(categoryTables, "250px", "20px")
        else
            minWidth, gap = "250px", "20px"
        end

        -- Wrap all category tables in responsive columns
        result = result .. CreateResponsiveColumns(categoryTables, minWidth, gap) .. "\n\n"
    else
        -- Single column layout (fallback or for non-craft-bag containers)
        for _, categoryData in ipairs(sortedCategories) do
            local categoryName = categoryData.name
            local categoryItems = categoryData.items

            -- Sort items within category by name (only for single column)
            table.sort(categoryItems, function(a, b)
                return a.name:lower() < b.name:lower()
            end)

            -- Ensure we have proper spacing before adding the category header
            if result ~= "" then
                local lastChars = string.sub(result, -2, -1)
                if lastChars ~= "\n\n" then
                    if lastChars:sub(-1, -1) ~= "\n" then
                        result = result .. "\n\n"
                    else
                        result = result .. "\n"
                    end
                end
            end

            -- Add category header
            result = result .. "#### " .. categoryName .. " (" .. #categoryItems .. " items)\n\n"

            -- Build table for this category
            local rows = {}
            for _, item in ipairs(categoryItems) do
                local qualitySymbol = GetQualitySymbol(item.quality)
                local stackText = item.stack > 1 and tostring(item.stack) or "1"
                table.insert(rows, { qualitySymbol .. " " .. item.name, stackText, qualitySymbol })
            end

            result = AppendStyledTable(result, headers, rows, options)

            -- Ensure table ends with proper newlines before next section
            local lastChars = string.sub(result, -2, -1)
            if lastChars ~= "\n\n" then
                if lastChars:sub(-1, -1) ~= "\n" then
                    result = result .. "\n\n"
                else
                    result = result .. "\n"
                end
            end
        end
    end

    result = result .. "</details>\n\n"

    return result
end

local function GenerateInventory(inventoryData)
    InitializeUtilities()

    -- Ensure we output something if enabled, even if data is missing
    if not inventoryData then
        return "## 🎒 Inventory\n\n*No inventory data available*\n\n"
    end

    local result = ""

    result = result .. "## 🎒 Inventory\n\n"

    -- Add attention warnings for nearly full storage
    local warnings = {}
    if inventoryData.backpackPercent and inventoryData.backpackPercent >= 90 then
        table.insert(
            warnings,
            string_format("🎒 **Backpack nearly full** (%d%%) - Clear out items", inventoryData.backpackPercent)
        )
    end
    if inventoryData.bankPercent and inventoryData.bankPercent >= 90 then
        table.insert(
            warnings,
            string_format("🏦 **Bank nearly full** (%d%%) - Clear out items", inventoryData.bankPercent)
        )
    end

    if #warnings > 0 then
        result = result .. table.concat(warnings, "  \n") .. "\n\n"
    end

    local headers = { "Storage", "Used", "Max", "Capacity" }

    -- Helper function to create capacity progress bar
    local function FormatCapacity(percent)
        if not percent then
            return "-"
        end
        local CreateProgressBar = CM.utils.CreateProgressBar
        if CreateProgressBar then
            return CreateProgressBar(percent, 10)
        else
            -- Fallback to percentage if progress bar not available
            return tostring(percent) .. "%"
        end
    end

    local rows = {
        {
            "Backpack",
            tostring(inventoryData.backpackUsed),
            tostring(inventoryData.backpackMax),
            FormatCapacity(inventoryData.backpackPercent),
        },
        {
            "Bank",
            tostring(inventoryData.bankUsed),
            tostring(inventoryData.bankMax),
            FormatCapacity(inventoryData.bankPercent),
        },
    }

    if inventoryData.hasCraftingBag then
        table.insert(rows, { "Crafting Bag", "∞", "∞", "ESO Plus" })
    end

    local options = {
        alignment = { "left", "right", "right", "left" },
        coloredHeaders = true,
    }
    result = AppendStyledTable(result, headers, rows, options)

    -- Add detailed bag contents if available
    if inventoryData.bagItems then
        result = result .. GenerateItemList(inventoryData.bagItems, "Backpack")
    end

    -- Add detailed bank contents if available
    if inventoryData.bankItems then
        result = result .. GenerateItemList(inventoryData.bankItems, "Bank")
    end

    -- Add detailed crafting bag contents if available
    if inventoryData.craftingBagItems then
        result = result .. GenerateItemList(inventoryData.craftingBagItems, "Crafting Bag")
    end

    return result
end

CM.generators.sections.GenerateInventory = GenerateInventory

-- =====================================================
-- PVP
-- =====================================================

local function GeneratePvP(pvpData)
    InitializeUtilities()

    if not pvpData then
        return ""
    end

    local result = ""

    result = result .. "## ⚔️ PvP Information\n\n"

    local headers = { "Category", "Value" }
    local rows = {
        { "Alliance War Rank", pvpData.rankName .. " (Rank " .. pvpData.rank .. ")" },
    }

    if pvpData.campaignName and pvpData.campaignName ~= "None" then
        local campaignText = CreateCampaignLink(pvpData.campaignName)
        table.insert(rows, { "Current Campaign", campaignText })
    end

    local options = {
        alignment = { "left", "left" },
        coloredHeaders = true,
    }
    result = AppendStyledTable(result, headers, rows, options)

    return result
end

CM.generators.sections.GeneratePvP = GeneratePvP

-- =====================================================
-- MERGED: CURRENCY, RESOURCES & INVENTORY
-- =====================================================

local function GenerateCurrencyResourcesInventory(currencyData, ridingData, inventoryData, cpData)
    InitializeUtilities()

    -- Check if any of the components have data
    local includeCurrency = currencyData ~= nil
    local includeInventory = inventoryData ~= nil

    if not includeCurrency and not includeInventory then
        return ""
    end

    local result = ""

    -- Non-Discord: Create merged section without headers (headers removed for Overview section)
    -- Add Currency title
    result = result .. '<a id="currency"></a>\n\n### Currency\n\n'

    -- Currency & Resources subsection
    if includeCurrency then
        -- Get currency content without header
        local currencyContent = GenerateCurrency(currencyData)
        -- Remove the header line (## 💰 Currency & Resources)
        currencyContent = currencyContent:gsub("^##%s+💰%s+Currency%s+&%s+Resources%s*\n%s*\n", "")
        result = result .. currencyContent
    end

    -- Inventory subsection
    if includeInventory then
        local inventoryContent = GenerateInventory(inventoryData)
        -- Remove the header line (## 🎒 Inventory)
        inventoryContent = inventoryContent:gsub("^##%s+🎒%s+Inventory%s*\n%s*\n", "")
        result = result .. inventoryContent
    end

    return result
end

CM.generators.sections.GenerateCurrencyResourcesInventory = GenerateCurrencyResourcesInventory

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint("GENERATOR", "Economy section generators loaded (enhanced visuals)")
