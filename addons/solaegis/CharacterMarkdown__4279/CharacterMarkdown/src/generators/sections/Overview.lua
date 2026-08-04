-- CharacterMarkdown - Overview Section Generators
-- Generates General subsection and Character Stats subsection for Overview

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}

local string_format = string.format
local table_concat = table.concat
local table_insert = table.insert

local markdown = (CM.utils and CM.utils.markdown) or nil

-- =====================================================
-- GENERAL SUBSECTION
-- =====================================================

local function GenerateGeneral(
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
    if not charData then
        return ""
    end

    -- Check if character attributes should be included
    local includeCharacterAttributes = true
    if settings then
        includeCharacterAttributes = settings.includeCharacterAttributes ~= false
    end

    local formatNumber = CM.utils and CM.utils.FormatNumber
    local safeFormat = function(val)
        if formatNumber then
            return formatNumber(val)
        else
            return tostring(val)
        end
    end

    local CreateStyledTable = markdown and markdown.CreateStyledTable
    local CreateResponsiveColumns = markdown and markdown.CreateResponsiveColumns

    -- Use multi-column styled tables if markdown utilities are available
    if CreateStyledTable and CreateResponsiveColumns then
        local result = "### General\n\n"

        -- Collect all rows first, then distribute into three balanced tables
        local allRows = {}

        -- Link creation functions
        local CreateRaceLink = CM.links and CM.links.CreateRaceLink
        local CreateClassLink = CM.links and CM.links.CreateClassLink
        local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink
        local CreateServerLink = CM.links and CM.links.CreateServerLink
        local CreateTitleLink = CM.links and CM.links.CreateTitleLink

        -- Basic Identity (always present)
        table_insert(allRows, { "**Level**", tostring(charData.level or 1) })

        local raceText = (CreateRaceLink and CreateRaceLink(charData.race)) or (charData.race or "Unknown")
        local classText = (CreateClassLink and CreateClassLink(charData.class)) or (charData.class or "Unknown")
        local allianceText = (CreateAllianceLink and CreateAllianceLink(charData.alliance))
            or (charData.alliance or "Unknown")

        table_insert(allRows, { "**Class**", classText })

        -- Subclassing (active foreign class skill lines)
        if charData.subclass then
            local subclassText = charData.subclass.summary or "None (native class lines)"
            if charData.subclass.accessLabel then
                subclassText = subclassText .. " [" .. charData.subclass.accessLabel .. "]"
            end
            table_insert(allRows, { "**Subclass**", subclassText })
        elseif charData.subclassingAccess then
            table_insert(allRows, { "**Subclass Access**", charData.subclassingAccess.label or "Unknown" })
        end

        table_insert(allRows, { "**Race**", raceText })
        table_insert(allRows, { "**Alliance**", allianceText })

        local serverText = (CreateServerLink and CreateServerLink(charData.server)) or (charData.server or "Unknown")
        table_insert(allRows, { "**Server**", serverText })
        table_insert(allRows, { "**Account**", charData.account or "Unknown" })

        -- Optional character attributes (controlled by setting)
        if includeCharacterAttributes then
            -- Gender (from attributes data if available, otherwise from charData if it exists)
            if attributesData and attributesData.gender and attributesData.gender ~= "Unknown" then
                table_insert(allRows, { "**Gender**", attributesData.gender })
            end
        end

        -- Champion Points
        if charData.cp and charData.cp > 0 then
            table_insert(allRows, { "**Champion Points**", tostring(charData.cp) })
        end

        -- Attributes
        local attrs = charData.attributes or {}
        table_insert(allRows, {
            "**Attributes**",
            string_format("🔵 %d / ❤️ %d / ⚡ %d", attrs.magicka or 0, attrs.health or 0, attrs.stamina or 0),
        })

        -- Available Champion Points (breakdown by discipline)
        if cpData and cpData.disciplines then
            local craftAvailable = 0
            local warfareAvailable = 0
            local fitnessAvailable = 0

            -- Get available points directly from pre-calculated discipline data
            for _, discipline in ipairs(cpData.disciplines) do
                local name = discipline.name or ""
                local id = discipline.id
                local available = discipline.available or 0

                -- Use ID for matching if available (more reliable than name)
                -- IDs: 1=Warfare, 2=Fitness, 3=Craft
                if id then
                    if id == 3 then -- Craft
                        craftAvailable = available
                    elseif id == 1 then -- Warfare
                        warfareAvailable = available
                    elseif id == 2 then -- Fitness
                        fitnessAvailable = available
                    end
                else
                    -- Fallback to name matching if ID is missing
                    local DisciplineType = CM.constants and CM.constants.DisciplineType
                    if DisciplineType then
                        if name == DisciplineType.CRAFT then
                            craftAvailable = available
                        elseif name == DisciplineType.WARFARE then
                            warfareAvailable = available
                        elseif name == DisciplineType.FITNESS then
                            fitnessAvailable = available
                        end
                    end
                end
            end

            CM.DebugPrint(
                "CP_OVERVIEW",
                string_format(
                    "Final: Craft=%d, Warfare=%d, Fitness=%d",
                    craftAvailable,
                    warfareAvailable,
                    fitnessAvailable
                )
            )

            if craftAvailable > 0 or warfareAvailable > 0 or fitnessAvailable > 0 then
                table_insert(allRows, {
                    "**Available Champion Points**",
                    string_format(
                        "⚒️ %d - ⚔️ %d - 💪 %d",
                        craftAvailable,
                        warfareAvailable,
                        fitnessAvailable
                    ),
                })
            end
        end

        -- Progression data (gated by includeProgression setting)
        if progressionData and settings and settings.includeProgression == true then
            local unspentSkillPoints = progressionData.unspentSkillPoints or progressionData.skillPoints or 0
            if unspentSkillPoints and unspentSkillPoints > 0 then
                table_insert(allRows, {
                    "**Skill Points**",
                    string_format("🎯 %d available - Ready to spend", unspentSkillPoints),
                })
            else
                table_insert(allRows, { "**Skill Points**", "None" })
            end

            if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
                table_insert(allRows, {
                    "**Attribute Points**",
                    string_format("⚠️ %d unspent", progressionData.unspentAttributePoints),
                })
            end

            if progressionData.isVampire then
                local stage = progressionData.vampireStage or 1
                table_insert(allRows, {
                    "**Vampire/Werewolf Status**",
                    string_format("🧛 Vampire Stage %d", stage),
                })
            elseif progressionData.isWerewolf then
                local stage = progressionData.werewolfStage or 1
                table_insert(allRows, {
                    "**Vampire/Werewolf Status**",
                    string_format("🐺 Werewolf Stage %d", stage),
                })
            end

            if progressionData.enlightenment then
                local current = progressionData.enlightenment.current or 0
                local max = progressionData.enlightenment.max or 0
                if max > 0 then
                    local percent = progressionData.enlightenment.percent or 0
                    table_insert(allRows, {
                        "**Enlightenment**",
                        string_format("%s / %s (%d%%)", safeFormat(current), safeFormat(max), percent),
                    })
                end
            end
        end

        -- Optional character attributes (controlled by setting)
        if includeCharacterAttributes then
            -- Title
            local title = nil
            if attributesData and attributesData.title and attributesData.title ~= "" then
                title = attributesData.title
            elseif charData.title and charData.title ~= "" then
                title = charData.title
            end
            if title then
                local titleText = (CreateTitleLink and CreateTitleLink(title)) or title
                table_insert(allRows, { "**Title**", titleText })
            end

            -- Age
            local age = nil
            if attributesData and attributesData.age then
                age = attributesData.age
            elseif charData.age then
                age = charData.age
            end
            if age then
                table_insert(allRows, { "**Age**", age })
            end
        end

        if charData.esoPlus then
            table_insert(allRows, { "**ESO Plus**", "✅ Active" })
        end

        -- Mundus Stone
        if mundusData and mundusData.active then
            local CreateMundusLink = CM.links and CM.links.CreateMundusLink
            local mundusText = (CreateMundusLink and CreateMundusLink(mundusData.name)) or mundusData.name
            table_insert(allRows, { "**🪨 Mundus Stone**", mundusText })
        end

        -- Active Buffs
        if buffsData and (buffsData.food or buffsData.potion or (buffsData.other and #buffsData.other > 0)) then
            local CreateBuffLink = CM.links and CM.links.CreateBuffLink
            local buffLines = {}

            if buffsData.food then
                local foodLink = (CreateBuffLink and CreateBuffLink(buffsData.food)) or buffsData.food
                table_insert(buffLines, "Food: " .. foodLink)
            end
            if buffsData.potion then
                local potionLink = (CreateBuffLink and CreateBuffLink(buffsData.potion)) or buffsData.potion
                table_insert(buffLines, "Potion: " .. potionLink)
            end
            if buffsData.other and #buffsData.other > 0 then
                local otherBuffs = {}
                for _, buff in ipairs(buffsData.other) do
                    local buffLink = (CreateBuffLink and CreateBuffLink(buff)) or buff
                    table_insert(otherBuffs, buffLink)
                end
                if #otherBuffs > 0 then
                    table_insert(buffLines, "Other: " .. table_concat(otherBuffs, ", "))
                end
            end

            if #buffLines > 0 then
                table_insert(allRows, { "**🍖 Active Buffs**", table_concat(buffLines, " • ") })
            end
        end

        -- Location
        if locationData then
            local zone = locationData.zone or "Unknown"
            local subzone = locationData.subzone
            local zoneIndex = locationData.zoneIndex or 0

            local CreateZoneLink = CM.links and CM.links.CreateZoneLink
            local zoneLink = (CreateZoneLink and CreateZoneLink(zone, format)) or zone

            local locStr = zoneLink
            if subzone and subzone ~= "" then
                locStr = string_format("%s (%s)", locStr, subzone)
            elseif zoneIndex and zoneIndex > 0 then
                locStr = string_format("%s (%d)", locStr, zoneIndex)
            end
            table_insert(allRows, { "**Location**", locStr })
        end

        -- Riding Skills (with emojis like attributes) - max is 60 for each
        -- Gated by includeRidingSkills setting (default: false)
        if ridingData and settings and settings.includeRidingSkills == true then
            -- Handle case where values might be booleans (true = maxed/60, false = 0)
            local speed = ridingData.speed
            if type(speed) == "boolean" then
                speed = speed and 60 or 0
            else
                speed = speed or 0
            end

            local stamina = ridingData.stamina
            if type(stamina) == "boolean" then
                stamina = stamina and 60 or 0
            else
                stamina = stamina or 0
            end

            local capacity = ridingData.capacity
            if type(capacity) == "boolean" then
                capacity = capacity and 60 or 0
            else
                capacity = capacity or 0
            end

            if speed > 0 or stamina > 0 or capacity > 0 then
                local allMaxed = (speed == 60 and stamina == 60 and capacity == 60)
                local value = allMaxed and "🐴 60 / 💪 60 / 🎒 60 ✅"
                    or string_format("🐴 %d/60 / 💪 %d/60 / 🎒 %d/60", speed, stamina, capacity)
                table_insert(allRows, {
                    "**🐴 Riding Skills**",
                    value,
                })
            end
        end

        -- Sort rows by value length (ascending) for better table sizing
        table.sort(allRows, function(a, b)
            local lenA = string.len(tostring(a[2] or ""))
            local lenB = string.len(tostring(b[2] or ""))
            return lenA < lenB
        end)

        -- Distribute rows into three balanced tables
        local totalRows = #allRows
        local rowsPerTable = math.ceil(totalRows / 3)

        local col1_rows = {}
        local col2_rows = {}
        local col3_rows = {}

        for i = 1, totalRows do
            local tableIndex = math.ceil(i / rowsPerTable)
            if tableIndex == 1 then
                table_insert(col1_rows, allRows[i])
            elseif tableIndex == 2 then
                table_insert(col2_rows, allRows[i])
            else
                table_insert(col3_rows, allRows[i])
            end
        end

        -- Create three tables
        local headers = { "Attribute", "Value" }
        local options = {
            alignment = { "left", "left" },
            format = nil,
            coloredHeaders = true,
        }

        local columns = {}
        if #col1_rows > 0 then
            table_insert(columns, CreateStyledTable(headers, col1_rows, options))
        end
        if #col2_rows > 0 then
            table_insert(columns, CreateStyledTable(headers, col2_rows, options))
        end
        if #col3_rows > 0 then
            table_insert(columns, CreateStyledTable(headers, col3_rows, options))
        end

        -- Create responsive multi-column layout
        local LayoutCalculator = CM.utils.LayoutCalculator
        local minWidth, gap
        if LayoutCalculator then
            minWidth, gap = LayoutCalculator.GetLayoutParamsWithFallback(columns, "250px", "20px")
        else
            minWidth = "250px"
            gap = "20px"
        end
        local columnsLayout = CreateResponsiveColumns(columns, minWidth, gap)
        result = result .. columnsLayout

        return result
    elseif not markdown then
        -- Fallback to simple table format when markdown utilities are not available
        local result = "### General\n\n"
        result = result .. "|| Attribute | Value |\n"
        result = result .. "||:----------|:------|\n"
        result = result .. string_format("|| **Level** | %d |\n", charData.level or 1)

        local CreateRaceLink = CM.links and CM.links.CreateRaceLink
        local CreateClassLink = CM.links and CM.links.CreateClassLink
        local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink

        local CreateRaceLink = CM.links and CM.links.CreateRaceLink
        local CreateClassLink = CM.links and CM.links.CreateClassLink
        local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink

        local raceText = (CreateRaceLink and CreateRaceLink(charData.race)) or (charData.race or "Unknown")
        local classText = (CreateClassLink and CreateClassLink(charData.class)) or (charData.class or "Unknown")
        local allianceText = (CreateAllianceLink and CreateAllianceLink(charData.alliance))
            or (charData.alliance or "Unknown")

        result = result .. string_format("|| **Class** | %s |\n", classText)
        if charData.subclass then
            local subclassText = charData.subclass.summary or "None (native class lines)"
            if charData.subclass.accessLabel then
                subclassText = subclassText .. " [" .. charData.subclass.accessLabel .. "]"
            end
            result = result .. string_format("|| **Subclass** | %s |\n", subclassText)
        end
        result = result .. string_format("|| **Race** | %s |\n", raceText)
        result = result .. string_format("|| **Alliance** | %s |\n", allianceText)

        local CreateServerLink = CM.links and CM.links.CreateServerLink
        local serverText = (CreateServerLink and CreateServerLink(charData.server)) or (charData.server or "Unknown")
        result = result .. string_format("|| **Server** | %s |\n", serverText)
        result = result .. string_format("|| **Account** | %s |\n", charData.account or "Unknown")

        if charData.cp and charData.cp > 0 then
            result = result .. string_format("|| **Champion Points** | %d |\n", charData.cp)
        end

        if charData.title and charData.title ~= "" then
            local CreateTitleLink = CM.links and CM.links.CreateTitleLink
            local titleText = (CreateTitleLink and CreateTitleLink(charData.title)) or charData.title
            result = result .. string_format("|| **Title** | %s |\n", titleText)
        end

        if charData.age then
            result = result .. string_format("|| **Age** | %s |\n", charData.age)
        end

        if charData.esoPlus then
            result = result .. "|| **ESO Plus** | ✅ Active |\n"
        end

        local attrs = charData.attributes or {}
        result = result
            .. string_format(
                "|| **Attributes** | 🔵 %d / ❤️ %d / ⚡ %d |\n",
                attrs.magicka or 0,
                attrs.health or 0,
                attrs.stamina or 0
            )

        -- Available Champion Points (breakdown by discipline)
        if cpData and cpData.disciplines then
            local DisciplineType = CM.constants and CM.constants.DisciplineType
            local craftAvailable = 0
            local warfareAvailable = 0
            local fitnessAvailable = 0

            -- Get available points directly from pre-calculated discipline data
            for _, discipline in ipairs(cpData.disciplines) do
                local name = discipline.name or ""
                local available = discipline.available or 0

                if DisciplineType then
                    if name == DisciplineType.CRAFT then
                        craftAvailable = available
                    elseif name == DisciplineType.WARFARE then
                        warfareAvailable = available
                    elseif name == DisciplineType.FITNESS then
                        fitnessAvailable = available
                    end
                end
            end

            if craftAvailable > 0 or warfareAvailable > 0 or fitnessAvailable > 0 then
                result = result
                    .. string_format(
                        "|| **Available Champion Points** | ⚒️ %d - ⚔️ %d - 💪 %d |\n",
                        craftAvailable,
                        warfareAvailable,
                        fitnessAvailable
                    )
            end
        end

        -- Progression data (gated by includeProgression setting)
        if progressionData and settings and settings.includeProgression == true then
            local unspentSkillPoints = progressionData.unspentSkillPoints or progressionData.skillPoints or 0
            if unspentSkillPoints and unspentSkillPoints > 0 then
                result = result
                    .. string_format("|| **Skill Points** | 🎯 %d available - Ready to spend |\n", unspentSkillPoints)
            else
                result = result .. "|| **Skill Points** | None |\n"
            end

            if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
                result = result
                    .. string_format(
                        "|| **Attribute Points** | ⚠️ %d unspent |\n",
                        progressionData.unspentAttributePoints
                    )
            end

            if progressionData.isVampire then
                local stage = progressionData.vampireStage or 1
                result = result .. string_format("|| **Vampire/Werewolf Status** | 🧛 Vampire Stage %d |\n", stage)
            elseif progressionData.isWerewolf then
                local stage = progressionData.werewolfStage or 1
                result = result .. string_format("|| **Vampire/Werewolf Status** | 🐺 Werewolf Stage %d |\n", stage)
            end

            if progressionData.enlightenment then
                local current = progressionData.enlightenment.current or 0
                local max = progressionData.enlightenment.max or 0
                if max > 0 then
                    local percent = progressionData.enlightenment.percent or 0
                    result = result
                        .. string_format(
                            "|| **Enlightenment** | %s / %s (%d%%) |\n",
                            safeFormat(current),
                            safeFormat(max),
                            percent
                        )
                end
            end
        end

        -- Add riding skills summary if available (max is 60 for each)
        -- Gated by includeRidingSkills setting (default: false)
        if ridingData and settings and settings.includeRidingSkills == true then
            -- Handle case where values might be booleans (true = maxed/60, false = 0)
            local speed = ridingData.speed
            if type(speed) == "boolean" then
                speed = speed and 60 or 0
            else
                speed = speed or 0
            end

            local stamina = ridingData.stamina
            if type(stamina) == "boolean" then
                stamina = stamina and 60 or 0
            else
                stamina = stamina or 0
            end

            local capacity = ridingData.capacity
            if type(capacity) == "boolean" then
                capacity = capacity and 60 or 0
            else
                capacity = capacity or 0
            end

            if speed > 0 or stamina > 0 or capacity > 0 then
                local allMaxed = (speed == 60 and stamina == 60 and capacity == 60)
                local skillsText = allMaxed and "🐴 60 / 💪 60 / 🎒 60 ✅"
                    or string_format("🐴 %d/60 / 💪 %d/60 / 🎒 %d/60", speed, stamina, capacity)
                result = result .. string_format("|| **🐴 Riding Skills** | %s |\n", skillsText)
            end
        end

        if mundusData and mundusData.active then
            local CreateMundusLink = CM.links and CM.links.CreateMundusLink
            local mundusText = (CreateMundusLink and CreateMundusLink(mundusData.name)) or mundusData.name
            result = result .. string_format("|| **🪨 Mundus Stone** | %s |\n", mundusText)
        end

        if buffsData and (buffsData.food or buffsData.potion or (buffsData.other and #buffsData.other > 0)) then
            local CreateBuffLink = CM.links and CM.links.CreateBuffLink
            local buffLines = {}

            if buffsData.food then
                local foodLink = (CreateBuffLink and CreateBuffLink(buffsData.food)) or buffsData.food
                table.insert(buffLines, "Food: " .. foodLink)
            end
            if buffsData.potion then
                local potionLink = (CreateBuffLink and CreateBuffLink(buffsData.potion)) or buffsData.potion
                table.insert(buffLines, "Potion: " .. potionLink)
            end
            if buffsData.other and #buffsData.other > 0 then
                local otherBuffs = {}
                for _, buff in ipairs(buffsData.other) do
                    local buffLink = (CreateBuffLink and CreateBuffLink(buff)) or buff
                    table.insert(otherBuffs, buffLink)
                end
                if #otherBuffs > 0 then
                    table.insert(buffLines, "Other: " .. table_concat(otherBuffs, ", "))
                end
            end

            if #buffLines > 0 then
                result = result .. string_format("|| **🍖 Active Buffs** | %s |\n", table_concat(buffLines, " • "))
            end
        end

        if locationData then
            local zone = locationData.zone or "Unknown"
            local subzone = locationData.subzone
            local zoneIndex = locationData.zoneIndex or 0

            local CreateZoneLink = CM.links and CM.links.CreateZoneLink
            local zoneLink = (CreateZoneLink and CreateZoneLink(zone)) or zone

            local locStr = zoneLink
            if subzone and subzone ~= "" then
                locStr = string_format("%s (%s)", locStr, subzone)
            elseif zoneIndex and zoneIndex > 0 then
                locStr = string_format("%s (%d)", locStr, zoneIndex)
            end
            result = result .. string_format("|| **Location** | %s |\n", locStr)
        end

        return result .. "\n"
    else
        local lines = {}

        local CreateRaceLink = CM.links and CM.links.CreateRaceLink
        local CreateClassLink = CM.links and CM.links.CreateClassLink
        local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink

        local raceText = (CreateRaceLink and CreateRaceLink(charData.race)) or (charData.race or "Unknown")
        local classText = (CreateClassLink and CreateClassLink(charData.class)) or (charData.class or "Unknown")
        local allianceText = (CreateAllianceLink and CreateAllianceLink(charData.alliance))
            or (charData.alliance or "Unknown")

        table.insert(lines, string_format("**Level:** %d", charData.level or 1))
        table.insert(lines, string_format("**Race:** %s", raceText))
        table.insert(lines, string_format("**Class:** %s", classText))
        if charData.subclass then
            local subclassText = charData.subclass.summary or "None (native class lines)"
            if charData.subclass.accessLabel then
                subclassText = subclassText .. " [" .. charData.subclass.accessLabel .. "]"
            end
            table.insert(lines, string_format("**Subclass:** %s", subclassText))
        end
        table.insert(lines, string_format("**Alliance:** %s", allianceText))

        local CreateServerLink = CM.links and CM.links.CreateServerLink
        local serverText = (CreateServerLink and CreateServerLink(charData.server)) or (charData.server or "Unknown")
        table.insert(lines, string_format("**Server:** %s", serverText))
        table.insert(lines, string_format("**Account:** %s", charData.account or "Unknown"))

        -- Optional character attributes (controlled by setting)
        if includeCharacterAttributes then
            -- Gender (from attributes data if available)
            if attributesData and attributesData.gender and attributesData.gender ~= "Unknown" then
                table.insert(lines, string_format("**Gender:** %s", attributesData.gender))
            end
        end

        if charData.cp and charData.cp > 0 then
            table.insert(lines, string_format("**Champion Points:** %d", charData.cp))
        end

        -- Optional character attributes (controlled by setting)
        if includeCharacterAttributes then
            -- Title
            local title = nil
            if attributesData and attributesData.title and attributesData.title ~= "" then
                title = attributesData.title
            elseif charData.title and charData.title ~= "" then
                title = charData.title
            end
            if title then
                local CreateTitleLink = CM.links and CM.links.CreateTitleLink
                local titleText = (CreateTitleLink and CreateTitleLink(title)) or title
                table.insert(lines, string_format("**Title:** %s", titleText))
            end

            -- Age
            local age = nil
            if attributesData and attributesData.age then
                age = attributesData.age
            elseif charData.age then
                age = charData.age
            end
            if age then
                table.insert(lines, string_format("**Age:** %s", age))
            end
        end

        if charData.esoPlus then
            table.insert(lines, "**ESO Plus:** ✅ Active")
        end

        local attrs = charData.attributes or {}
        table.insert(
            lines,
            string_format(
                "**Attributes:** 🔵 %d / ❤️ %d / ⚡ %d",
                attrs.magicka or 0,
                attrs.health or 0,
                attrs.stamina or 0
            )
        )

        -- Available Champion Points (breakdown by discipline)
        if cpData and cpData.disciplines then
            local DisciplineType = CM.constants and CM.constants.DisciplineType
            local craftAvailable = 0
            local warfareAvailable = 0
            local fitnessAvailable = 0

            for _, discipline in ipairs(cpData.disciplines) do
                local name = discipline.name or ""
                local available = discipline.available or 0

                if DisciplineType then
                    if name == DisciplineType.CRAFT then
                        craftAvailable = available
                    elseif name == DisciplineType.WARFARE then
                        warfareAvailable = available
                    elseif name == DisciplineType.FITNESS then
                        fitnessAvailable = available
                    end
                end
            end

            if craftAvailable > 0 or warfareAvailable > 0 or fitnessAvailable > 0 then
                table.insert(
                    lines,
                    string_format(
                        "**Available Champion Points:** ⚒️ %d - ⚔️ %d - 💪 %d",
                        craftAvailable,
                        warfareAvailable,
                        fitnessAvailable
                    )
                )
            end
        end

        -- Progression data (gated by includeProgression setting)
        if progressionData and settings and settings.includeProgression == true then
            local unspentSkillPoints = progressionData.unspentSkillPoints or progressionData.skillPoints or 0
            if unspentSkillPoints and unspentSkillPoints > 0 then
                table.insert(
                    lines,
                    string_format("**Skill Points:** 🎯 %d available - Ready to spend", unspentSkillPoints)
                )
            else
                table.insert(lines, "**Skill Points:** None")
            end

            if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
                table.insert(
                    lines,
                    string_format("**Attribute Points:** ⚠️ %d unspent", progressionData.unspentAttributePoints)
                )
            end

            if progressionData.isVampire then
                local stage = progressionData.vampireStage or 1
                table.insert(lines, string_format("**Vampire/Werewolf Status:** 🧛 Vampire Stage %d", stage))
            elseif progressionData.isWerewolf then
                local stage = progressionData.werewolfStage or 1
                table.insert(lines, string_format("**Vampire/Werewolf Status:** 🐺 Werewolf Stage %d", stage))
            end

            if progressionData.enlightenment then
                local current = progressionData.enlightenment.current or 0
                local max = progressionData.enlightenment.max or 0
                if max > 0 then
                    local percent = progressionData.enlightenment.percent or 0
                    table.insert(
                        lines,
                        string_format(
                            "**Enlightenment:** %s / %s (%d%%)",
                            safeFormat(current),
                            safeFormat(max),
                            percent
                        )
                    )
                end
            end
        end

        -- Add riding skills summary if available (max is 60 for each)
        -- Gated by includeRidingSkills setting (default: false)
        if ridingData and settings and settings.includeRidingSkills == true then
            -- Handle case where values might be booleans (true = maxed/60, false = 0)
            local speed = ridingData.speed
            if type(speed) == "boolean" then
                speed = speed and 60 or 0
            else
                speed = speed or 0
            end

            local stamina = ridingData.stamina
            if type(stamina) == "boolean" then
                stamina = stamina and 60 or 0
            else
                stamina = stamina or 0
            end

            local capacity = ridingData.capacity
            if type(capacity) == "boolean" then
                capacity = capacity and 60 or 0
            else
                capacity = capacity or 0
            end

            if speed > 0 or stamina > 0 or capacity > 0 then
                local allMaxed = (speed == 60 and stamina == 60 and capacity == 60)
                local skillsText = allMaxed and "🐴 60 / 💪 60 / 🎒 60 ✅"
                    or string_format("🐴 %d/60 / 💪 %d/60 / 🎒 %d/60", speed, stamina, capacity)
                table.insert(lines, string_format("**🐴 Riding Skills:** %s", skillsText))
            end
        end

        if mundusData and mundusData.active then
            local CreateMundusLink = CM.links and CM.links.CreateMundusLink
            local mundusText = (CreateMundusLink and CreateMundusLink(mundusData.name)) or mundusData.name
            table.insert(lines, string_format("**Mundus Stone:** %s", mundusText))
        end

        if buffsData and (buffsData.food or buffsData.potion or (buffsData.other and #buffsData.other > 0)) then
            local CreateBuffLink = CM.links and CM.links.CreateBuffLink
            local buffLines = {}

            if buffsData.food then
                local foodLink = (CreateBuffLink and CreateBuffLink(buffsData.food, format)) or buffsData.food
                table.insert(buffLines, "Food: " .. foodLink)
            end
            if buffsData.potion then
                local potionLink = (CreateBuffLink and CreateBuffLink(buffsData.potion, format)) or buffsData.potion
                table.insert(buffLines, "Potion: " .. potionLink)
            end
            if buffsData.other and #buffsData.other > 0 then
                local otherBuffs = {}
                for _, buff in ipairs(buffsData.other) do
                    local buffLink = (CreateBuffLink and CreateBuffLink(buff)) or buff
                    table.insert(otherBuffs, buffLink)
                end
                if #otherBuffs > 0 then
                    table.insert(buffLines, "Other: " .. table_concat(otherBuffs, ", "))
                end
            end

            if #buffLines > 0 then
                table.insert(lines, string_format("**Active Buffs:** %s", table_concat(buffLines, " • ")))
            end
        end

        if locationData then
            local zone = locationData.zone or "Unknown"
            local subzone = locationData.subzone
            local zoneIndex = locationData.zoneIndex or 0

            local CreateZoneLink = CM.links and CM.links.CreateZoneLink
            local zoneLink = (CreateZoneLink and CreateZoneLink(zone, format)) or zone

            local locStr = zoneLink
            if subzone and subzone ~= "" then
                locStr = string_format("%s (%s)", locStr, subzone)
            elseif zoneIndex and zoneIndex > 0 then
                locStr = string_format("%s (%d)", locStr, zoneIndex)
            end
            table.insert(lines, string_format("**Location:** %s", locStr))
        end

        local content = table_concat(lines, "  \n")
        return string_format("### General\n\n%s\n\n", content)
    end
end

CM.generators.sections.GenerateGeneral = GenerateGeneral

-- =====================================================
-- HELPER: Check if setting is enabled
-- =====================================================

local function IsSettingEnabled(settings, settingName, defaultValue)
    if not settings then
        return defaultValue ~= false
    end
    local value = settings[settingName]
    if value == nil then
        return defaultValue ~= false
    end
    return value == true
end

-- =====================================================
-- QUICK STATS GENERATOR (Aggregates General + Stats)
-- =====================================================

local function GenerateOverviewSection(
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
    titlesHousingData,
    mundusData,
    ridingData,
    settings
)
    local result = "## 📋 Overview\n\n"

    -- Extract characterAttributes from settings if passed via _collectedData
    local attributesData = nil
    if settings and settings._collectedData and settings._collectedData.characterAttributes then
        attributesData = settings._collectedData.characterAttributes
    end

    -- 1. General Section
    if IsSettingEnabled(settings, "includeGeneral", true) then
        result = result
            .. GenerateGeneral(
                charData,
                progressionData,
                locationData,
                buffsData,
                mundusData,
                format,
                ridingData,
                attributesData, -- Use extracted attributesData instead of charData.attributes
                cpData,
                settings
            )
    end

    -- 2. Currency Section
    if IsSettingEnabled(settings, "includeCurrency", true) and CM.generators.sections.GenerateCurrency then
        result = result .. CM.generators.sections.GenerateCurrency(currencyData, format)
    end

    -- Note: Character Stats (Basic and Advanced) have been moved to Combat Arsenal section
    -- They are no longer part of the Overview/QuickStats section

    return result
end

CM.generators.sections.GenerateOverviewSection = GenerateOverviewSection

CM.DebugPrint("GENERATOR", "Overview section generators loaded")
