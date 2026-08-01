-- CharacterMarkdown - Character Section Generators
-- Generates character identity, overview, and header sections

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}

local string_format = string.format
local table_concat = table.concat
local table_insert = table.insert

-- Import advanced markdown utilities (with nil check)
local markdown = (CM.utils and CM.utils.markdown) or nil

-- GenerateQuickSummary removed - quick format no longer supported

-- =====================================================
-- ENHANCED HEADER with Badges
-- =====================================================

local function GenerateHeader(charData, format)
    if not charData then
        return "# Unknown Character\n\n"
    end

    local name = charData.name or "Unknown"
    local title = charData.title or ""
    local race = charData.race or "Unknown"
    local class = charData.class or "Unknown"
    local alliance = charData.alliance or "Unknown"
    local level = charData.level or 1
    -- Fix: Use correct field name (cp, not championPoints)
    local cp = charData.cp or 0
    local isESOPlus = charData.esoPlus or false

    -- Use character name as H1, append title if set (format: "Name" or "Name (Title)")
    local displayTitle = name
    if title ~= "" then
        displayTitle = string_format("%s (%s)", name, title)
    end

    -- Enhanced visuals are now always enabled (baseline)
    if not markdown then
        -- Classic format
        -- Classic format
        local parts = {}
        table_insert(parts, string_format("# %s\n\n", displayTitle))
        table_insert(parts, string_format("**%s %s**  \n", race, class))
        table_insert(parts, string_format("**Level %d • CP %d • %s**\n\n", level, cp, alliance))
        if isESOPlus then
            table_insert(parts, "✨ *ESO Plus Active*\n\n")
        end
        -- Add leading newline for proper markdown formatting
        return "\n" .. table_concat(parts)
    end

    -- ENHANCED FORMAT with badges (with nil checks)
    if not markdown.CreateBadgeRow or not markdown.CreateCenteredBlock then
        -- Fallback to classic if functions don't exist
        local header = string_format("# %s\n\n", displayTitle)
        header = header .. string_format("**%s %s**  \n", race, class)
        header = header .. string_format("**Level %d • CP %d • %s**\n\n", level, cp, alliance)
        -- Add leading newline for proper markdown formatting
        return "\n" .. header
    end

    local badges = {
        { label = "Level", value = level, color = "blue" },
        { label = "CP", value = cp, color = "purple" },
        { label = "Class", value = class:gsub(" ", "_"), color = "green" },
    }

    if isESOPlus then
        local esoPlusValue = "Active"
        local settings = CM.GetSettings()
        if settings.esoPlusExpirationDate and settings.esoPlusExpirationDate ~= "" then
            esoPlusValue = string_format("Active (exp %s)", settings.esoPlusExpirationDate)
        end
        table.insert(badges, { label = "ESO+", value = esoPlusValue, color = "gold" })
    end

    local badgeRow = markdown.CreateBadgeRow(badges) or ""

    local header = markdown.CreateCenteredBlock(string_format(
        [[
# %s

%s

**%s %s • %s Alliance**
]],
        displayTitle,
        badgeRow,
        race,
        class,
        alliance
    )) or string_format("# %s\n\n**%s %s • %s Alliance**\n\n", displayTitle, race, class, alliance)

    -- Use CreateSeparator for consistent separator styling
    local CreateSeparator = markdown and markdown.CreateSeparator
    if CreateSeparator then
        header = header .. CreateSeparator("hr")
    else
        header = header .. "---\n\n"
    end

    -- Check for Custom Icon via LibCustomIcons
    if LibCustomIcons and LibCustomIcons.GetStatic and GetDisplayName then
        local displayName = GetDisplayName()
        local iconPath = LibCustomIcons.GetStatic(displayName)
        if iconPath then
            -- Convert to URL (assuming standard GitHub hosting for the library)
            -- Remove "LibCustomIcons/" prefix if present to avoid double path
            local relativePath = iconPath:gsub("^LibCustomIcons/", "")
            local iconUrl = "https://raw.githubusercontent.com/m00nyONE/LibCustomIcons/main/" .. relativePath
            local iconMarkdown = string_format("\n![Custom Icon](%s)\n\n", iconUrl)
            header = header .. iconMarkdown
        end
    end

    -- Add leading newline for proper markdown formatting
    return "\n" .. header
end

CM.generators.sections.GenerateHeader = GenerateHeader

-- =====================================================
-- QUICK STATS (At-a-glance info box)
-- =====================================================

local function GenerateQuickStats(
    charData,
    statsData,
    format,
    equipmentData,
    progressionData,
    currencyData,
    cpData,
    inventoryData,
    locationData,
    buffsData,
    pvpData,
    titlesData,
    mundusData,
    ridingData,
    settings
)
    if not charData then
        return ""
    end

    local formatNumber = CM.utils and CM.utils.FormatNumber
    local safeFormat = function(val)
        if formatNumber then
            return formatNumber(val)
        else
            return tostring(val)
        end
    end

    settings = settings or {}
    local IsSettingEnabled = function(settingName, defaultValue)
        if settings[settingName] == nil then
            return defaultValue ~= false
        end
        return settings[settingName] ~= false
    end

    local generalSection = ""
    if IsSettingEnabled("includeGeneral", true) then
        local GenerateGeneral = CM.generators.sections.GenerateGeneral
        if GenerateGeneral then
            -- Get attributes data from collectedData (passed via settings context)
            local attributesData = nil
            if settings and settings._collectedData and settings._collectedData.characterAttributes then
                attributesData = settings._collectedData.characterAttributes
            end
            generalSection = GenerateGeneral(
                charData,
                progressionData,
                locationData,
                buffsData,
                mundusData,
                format,
                ridingData,
                attributesData,
                cpData,
                settings
            )
        end
    end

    local currencySection = ""
    if IsSettingEnabled("includeCurrency", true) and currencyData then
        local markdown = CM.utils and CM.utils.markdown
        local CreateStyledTable = markdown and markdown.CreateStyledTable

        -- Define all currency types with their emojis and labels
        local currencyItems = {
            { key = "gold", label = "Gold", emoji = "💰" },
            { key = "ap", label = "Alliance Points", emoji = "⚔️" },
            { key = "telvar", label = "Tel Var", emoji = "🔮" },
            { key = "transmute", label = "Transmute Crystals", emoji = "💎" },
            { key = "vouchers", label = "Writs", emoji = "📜" },
            { key = "eventTickets", label = "Event Tickets", emoji = "🎫" },
            { key = "crowns", label = "Crowns", emoji = "👑" },
            { key = "gems", label = "Gems", emoji = "💠" },
            { key = "seals", label = "Seals", emoji = "🏅" },
            { key = "undauntedKeys", label = "Keys", emoji = "🗝️" },
            { key = "outfitTokens", label = "Tokens", emoji = "👕" },
            { key = "archivalFortunes", label = "Fortunes", emoji = "📚" },
            { key = "imperialFragments", label = "Fragments", emoji = "🔹" },
        }

        if CreateStyledTable then
            -- Use styled table
            local currencyRows = {}

            for _, item in ipairs(currencyItems) do
                local value = currencyData[item.key]
                -- Always include all currencies to match Economy section
                table_insert(currencyRows, { item.emoji .. " **" .. item.label .. "**", safeFormat(value or 0) })
            end

            -- Currency section is always created since Gold is always included
            local headers = { "Attribute", "Value" }
            local options = {
                alignment = { "left", "left" },
                format = format,
                coloredHeaders = true,
            }
            local currencyTable = CreateStyledTable(headers, currencyRows, options)
            currencySection = "### Currency\n\n" .. currencyTable
        else
            -- Fallback to simple table format
            local currencyRowsParts = {}

            for _, item in ipairs(currencyItems) do
                local value = currencyData[item.key]
                -- Always include all currencies
                table.insert(
                    currencyRowsParts,
                    string_format("| %s **%s** | %s |\n", item.emoji, item.label, safeFormat(value or 0))
                )
            end
            local currencyRows = table.concat(currencyRowsParts)

            -- Currency section is always created since Gold is always included
            currencySection =
                string_format("### Currency\n\n| Attribute | Value |\n|:----------|:------|\n%s\n", currencyRows)
        end
    end

    local result = "## 📋 Overview\n\n"

    -- Check if General section uses styled tables (has grid layout)
    local generalHasGrid = generalSection ~= "" and string.find(generalSection, '<div style="display: grid;')
    -- Currency uses styled tables if it doesn't start with the fallback pipe table
    -- and doesn't have a grid wrapper (meaning it's a styled table ready to be added to grid)
    local currencyHasStyledTable = currencySection ~= ""
        and not string.find(currencySection, "^### Currency\n\n| Attribute")
        and not string.find(currencySection, "<div style=")

    if generalHasGrid and currencyHasStyledTable then
        -- Both use styled tables - combine into single grid
        -- Extract General's grid content (everything INSIDE the grid div, not the grid div itself)
        local gridStartPos = string.find(generalSection, '<div style="display: grid;')
        if gridStartPos then
            -- Find the opening <div> tag end (after the style attribute)
            local gridDivEnd = string.find(generalSection, ">", gridStartPos)
            if gridDivEnd then
                -- Find the matching closing </div> for the grid wrapper by tracking div depth
                local divDepth = 1
                local gridClosePos = nil
                local searchStart = gridDivEnd + 1

                for i = searchStart, string.len(generalSection) do
                    -- Check for opening div tag
                    if string.sub(generalSection, i, i + 3) == "<div" then
                        -- Verify it's a complete div tag (check for space, >, or newline after "div")
                        local afterDiv = string.sub(generalSection, i + 4, i + 4)
                        if afterDiv == " " or afterDiv == ">" or afterDiv == "\n" then
                            divDepth = divDepth + 1
                        end
                    -- Check for closing div tag
                    elseif string.sub(generalSection, i, i + 5) == "</div>" then
                        divDepth = divDepth - 1
                        if divDepth == 0 then
                            gridClosePos = i -- Position of </div>
                            break
                        end
                    end
                end

                if gridClosePos then
                    -- Extract only the content INSIDE the grid (between > and </div>)
                    local generalGridContent = string.sub(generalSection, gridDivEnd + 1, gridClosePos - 1)
                    -- Trim any leading/trailing whitespace
                    generalGridContent = string.gsub(generalGridContent, "^%s+", "")
                    generalGridContent = string.gsub(generalGridContent, "%s+$", "")

                    -- Extract Currency content (remove header)
                    local currencyContent = string.gsub(currencySection, "^### Currency\n\n", "")

                    -- Combine into single grid
                    result = result .. '<a id="general"></a>\n\n'
                    result = result .. "### General\n\n"
                    result = result
                        .. '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">\n'
                    result = result .. generalGridContent
                    result = result .. "<div>\n\n"
                    result = result .. '<a id="currency"></a>\n\n'
                    result = result .. "### Currency\n\n"
                    result = result .. currencyContent
                    result = result .. "</div>\n"
                    result = result .. "</div>\n\n"
                else
                    -- Fallback: couldn't find grid closing tag
                    if generalSection ~= "" then
                        result = result .. '<a id="general"></a>\n\n' .. generalSection
                    end
                    if currencySection ~= "" then
                        result = result .. '<a id="currency"></a>\n\n' .. currencySection
                    end
                end
            else
                -- Fallback: couldn't find grid div end
                if generalSection ~= "" then
                    result = result .. '<a id="general"></a>\n\n' .. generalSection
                end
                if currencySection ~= "" then
                    result = result .. '<a id="currency"></a>\n\n' .. currencySection
                end
            end
        else
            -- Fallback: append normally
            if generalSection ~= "" then
                result = result .. '<a id="general"></a>\n\n' .. generalSection
            end
            if currencySection ~= "" then
                result = result .. '<a id="currency"></a>\n\n' .. currencySection
            end
        end
    else
        -- Append sections normally
        if generalSection ~= "" then
            result = result .. '<a id="general"></a>\n\n' .. generalSection
        end
        if currencySection ~= "" then
            result = result .. '<a id="currency"></a>\n\n' .. currencySection
        end
    end

    return result
end

CM.generators.sections.GenerateQuickStats = GenerateQuickStats

-- =====================================================
-- ATTENTION NEEDED (Warnings/Important Info)
-- =====================================================

-- FIX #5: Enhanced attention needed with more warnings
local function GenerateAttentionNeeded(progressionData, inventoryData, ridingData, companionData, currencyData, format)
    -- Enhanced visuals are now always enabled (baseline)
    local warnings = {}

    -- Check for unspent points
    if progressionData then
        if progressionData.unspentSkillPoints and progressionData.unspentSkillPoints > 0 then
            table.insert(
                warnings,
                string_format("🎯 **%d skill points available** - Ready to spend", progressionData.unspentSkillPoints)
            )
        end
        if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
            table.insert(
                warnings,
                string_format("⚠️ **%d unspent attribute points**", progressionData.unspentAttributePoints)
            )
        end
    end

    -- Check inventory capacity warnings (>90%)
    if inventoryData then
        if inventoryData.backpackPercent and inventoryData.backpackPercent >= 90 then
            table.insert(warnings, string_format("🎒 **Backpack nearly full** (%d%%)", inventoryData.backpackPercent))
        end
        if inventoryData.bankPercent and inventoryData.bankPercent >= 90 then
            table.insert(warnings, string_format("🏦 **Bank nearly full** (%d%%)", inventoryData.bankPercent))
        end
    end

    -- Check riding skill training available
    if ridingData then
        local speed = ridingData.speed or 0
        local stamina = ridingData.stamina or 0
        local capacity = ridingData.capacity or 0
        if speed < 60 or stamina < 60 or capacity < 60 then
            local incomplete = {}
            if speed < 60 then
                table.insert(incomplete, "Speed")
            end
            if stamina < 60 then
                table.insert(incomplete, "Stamina")
            end
            if capacity < 60 then
                table.insert(incomplete, "Capacity")
            end
            table.insert(
                warnings,
                string_format("🐴 **Riding training available**: %s", table_concat(incomplete, ", "))
            )
        end
    end

    -- Check companion rapport low (keep this for rapport-specific warnings)
    -- Rapport levels: 1=Disdainful, 2=Wary, 3=Cordial, 4=Friendly, 5=Close
    if companionData and companionData.active and companionData.rapport then
        if companionData.rapport.level and companionData.rapport.level < 5 then
            table.insert(
                warnings,
                string_format(
                    "💔 **Companion rapport low**: %s (%s)",
                    companionData.active.name or "Unknown",
                    companionData.rapport.description or tostring(companionData.rapport.level)
                )
            )
        end
    end

    -- Check event tickets at maximum (12 is the cap in ESO)
    if currencyData then
        local eventTickets = currencyData.eventTickets or 0
        if eventTickets >= 12 then
            table.insert(
                warnings,
                string_format(
                    "🎫 **Event tickets at maximum** (%d/12) - Use tickets to avoid wasting future rewards",
                    eventTickets
                )
            )
        end
    end

    if #warnings == 0 then
        return ""
    end

    -- Add section header
    local result = "## ⚠️ Attention Needed\n\n"

    -- Use generic function for warnings (blockquote for GitHub, styled table for VSCode/Discord)
    local CreateAttentionNeeded = CM.utils.markdown and CM.utils.markdown.CreateAttentionNeeded
    if CreateAttentionNeeded then
        result = result .. CreateAttentionNeeded(warnings, format, "Attention Needed")
    else
        -- Fallback to old format if function not available
        local content = table_concat(warnings, "  \n")
        if markdown and markdown.CreateCallout then
            result = result .. markdown.CreateCallout("warning", content, format)
        else
            result = result .. content .. "\n\n"
        end
    end

    return result
end

CM.generators.sections.GenerateAttentionNeeded = GenerateAttentionNeeded

-- =====================================================
-- CUSTOM NOTES SECTION
-- =====================================================

-- Helper function to auto-link sets and abilities in build notes
local function AutoLinkSetsAndAbilities(notes, format, equipmentData, skillBarData)
    if not notes or notes == "" then
        return notes
    end
    -- Always enable links (markdown format supports it)

    local CreateSetLink = CM.links and CM.links.CreateSetLink
    local CreateAbilityLink = CM.links and CM.links.CreateAbilityLink

    if not CreateSetLink and not CreateAbilityLink then
        return notes
    end

    local processedNotes = notes

    -- Extract set names from equipment data
    local setNames = {}
    if equipmentData and equipmentData.sets then
        for _, set in ipairs(equipmentData.sets) do
            if set.name and set.name ~= "" and set.name ~= "-" then
                -- Escape special regex characters in set name for pattern matching
                local escapedName = set.name:gsub("([%(%)%.%+%*%?%[%]%^%$%%])", "%%%1")
                if not setNames[set.name] then
                    setNames[set.name] = true
                    -- Only link if not already linked (avoid double-linking)
                    local pattern = "%f[%w]" .. escapedName .. "%f[%W]"
                    local alreadyLinked = processedNotes:find("%[" .. escapedName .. "%]%(")
                    if not alreadyLinked then
                        local linkedName = CreateSetLink(set.name, format)
                        if linkedName and linkedName ~= set.name then
                            -- Replace set name with linked version (word boundary aware)
                            processedNotes = processedNotes:gsub(pattern, linkedName)
                        end
                    end
                end
            end
        end
    end

    -- Extract ability names from skill bar data
    local abilityNames = {}
    if skillBarData and skillBarData.bars then
        for _, bar in ipairs(skillBarData.bars) do
            if bar.abilities then
                for _, ability in ipairs(bar.abilities) do
                    if
                        ability.name
                        and ability.name ~= ""
                        and ability.name ~= "[Empty]"
                        and ability.name ~= "[Empty Slot]"
                    then
                        -- Clean ability name (remove rank suffixes like " IV")
                        local cleanName =
                            ability.name:gsub("%s+IV$", ""):gsub("%s+III$", ""):gsub("%s+II$", ""):gsub("%s+I$", "")
                        if cleanName ~= "" and not abilityNames[cleanName] then
                            abilityNames[cleanName] = true
                            -- Escape special regex characters
                            local escapedName = cleanName:gsub("([%(%)%.%+%*%?%[%]%^%$%%])", "%%%1")
                            -- Only link if not already linked
                            local pattern = "%f[%w]" .. escapedName .. "%f[%W]"
                            local alreadyLinked = processedNotes:find("%[" .. escapedName .. "%]%(")
                            if not alreadyLinked then
                                local linkedName = CreateAbilityLink(cleanName, ability.abilityId, format)
                                if linkedName and linkedName ~= cleanName then
                                    -- Replace ability name with linked version (word boundary aware)
                                    processedNotes = processedNotes:gsub(pattern, linkedName)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return processedNotes
end

local function GenerateCustomNotes(customNotes, format, equipmentData, skillBarData)
    if not customNotes or customNotes == "" then
        return ""
    end

    -- Auto-link sets and abilities in notes
    local processedNotes = AutoLinkSetsAndAbilities(customNotes, format, equipmentData, skillBarData)

    -- Output as plain markdown to preserve full markdown formatting capabilities
    return string_format("## 📝 Build Notes\n\n%s\n\n", processedNotes)
end

CM.generators.sections.GenerateCustomNotes = GenerateCustomNotes

-- =====================================================
-- DYNAMIC TABLE OF CONTENTS (from Registry)
-- =====================================================

-- Generate Table of Contents dynamically from section registry
-- sectionOutputs: optional map of section.name -> generated markdown (two-pass TOC)
local function GenerateDynamicTableOfContents(registry, format, sectionOutputs)
    -- Always generate TOC for markdown format

    local tocLines = {}

    local function sectionHasBody(sectionName)
        if not sectionOutputs or not sectionName then
            return true
        end
        local content = sectionOutputs[sectionName]
        return content and content ~= "" and content:gsub("%s+", "") ~= ""
    end

    -- Use central anchor generator from utilities if available, otherwise fallback
    local GenerateAnchor = (CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor)
        or function(text)
            if not text then
                return ""
            end
            local anchor = ""
            for i = 1, #text do
                local byte = text:byte(i)
                if
                    (byte >= 48 and byte <= 57)
                    or (byte >= 65 and byte <= 90)
                    or (byte >= 97 and byte <= 122)
                    or byte == 32
                    or byte == 45
                then
                    anchor = anchor .. text:sub(i, i)
                end
            end
            anchor = anchor:lower():gsub("%s+", "-"):gsub("^%-+", ""):gsub("%-+$", ""):gsub("%-%-+", "-")
            return anchor
        end

    -- Loop through registry and build TOC for sections with tocEntry metadata
    for _, section in ipairs(registry) do
        -- Check if section has TOC entry and condition is met
        if section.tocEntry then
            local shouldInclude = false

            -- Evaluate condition (can be boolean or function)
            if type(section.condition) == "function" then
                shouldInclude = section.condition()
            else
                shouldInclude = section.condition
            end

            if shouldInclude and sectionHasBody(section.name) then
                local tocEntry = section.tocEntry
                local anchor = GenerateAnchor(tocEntry.title)
                local content = sectionOutputs and sectionOutputs[section.name] or nil

                -- Main section entry
                table_insert(tocLines, string_format("- [%s](#%s)", tocEntry.title, anchor))

                -- Add subsections if present
                if tocEntry.subsections then
                    for _, subsection in ipairs(tocEntry.subsections) do
                        local subAnchor = GenerateAnchor(subsection)
                        local includeSubsection = true
                        if content then
                            includeSubsection = content:find('id="' .. subAnchor .. '"', 1, true)
                                or content:find("### " .. subsection, 1, true)
                                or content:find("## " .. subsection, 1, true)
                        end
                        if includeSubsection then
                            table_insert(tocLines, string_format("  - [%s](#%s)", subsection, subAnchor))
                        end
                    end
                end
            end
        end
    end

    -- Build final TOC markdown
    if #tocLines == 0 then
        return ""
    end

    local tocContent = table_concat(tocLines, "\n")
    return string_format("## 📑 Table of Contents\n\n%s\n\n", tocContent)
end

CM.generators.sections.GenerateDynamicTableOfContents = GenerateDynamicTableOfContents

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint("GENERATOR", "Character section generators loaded (enhanced visuals)")
