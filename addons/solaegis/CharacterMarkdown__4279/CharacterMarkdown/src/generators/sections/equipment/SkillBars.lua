-- CharacterMarkdown - Skill Bar Generators
-- Generates skill bar tables for the equipment section

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.equipment = CM.generators.sections.equipment or {}

local helpers = CM.generators.sections.equipment
local skillbars = {}
local table_concat = table.concat
local table_insert = table.insert

local REGULAR_ABILITY_SLOTS = 5

local function FormatAbilityCell(ability, cache)
    if ability and type(ability) == "table" then
        local abilityName = ability.name or "[Empty Slot]"
        if ability.id and cache.CreateAbilityLink then
            local success, abText = pcall(cache.CreateAbilityLink, abilityName, ability.id)
            if success and abText then
                return abText
            end
        end
        return abilityName
    end
    return "[Empty Slot]"
end

local function FormatUltimateCell(bar, cache)
    if bar.ultimate and bar.ultimate ~= "" then
        if cache.CreateAbilityLink and bar.ultimateId then
            local success, ultText = pcall(cache.CreateAbilityLink, bar.ultimate, bar.ultimateId)
            if success and ultText then
                return ultText
            end
        end
        return bar.ultimate
    end
    return "[Empty]"
end

local function AppendSkillBarTable(outputParts, abilities, bar, cache)
    local markdown_utils = cache.markdown
    local CreateStyledTable = markdown_utils and markdown_utils.CreateStyledTable

    local headers = {}
    local rowData = {}

    for i = 1, REGULAR_ABILITY_SLOTS do
        table_insert(headers, tostring(i))
        table_insert(rowData, FormatAbilityCell(abilities[i], cache))
    end
    table_insert(headers, "⚡")
    table_insert(rowData, FormatUltimateCell(bar, cache))

    if not CreateStyledTable then
        local tableParts = {}
        local headerRow = "|"
        local separatorRow = "|"
        for _, header in ipairs(headers) do
            headerRow = headerRow .. " " .. header .. " |"
            separatorRow = separatorRow .. ":--:|"
        end
        table_insert(tableParts, headerRow .. "\n")
        table_insert(tableParts, separatorRow .. "\n")
        local abilitiesRow = "|"
        for _, cell in ipairs(rowData) do
            abilitiesRow = abilitiesRow .. " " .. cell .. " |"
        end
        table_insert(tableParts, abilitiesRow .. "\n\n")
        table_insert(outputParts, table_concat(tableParts))
        return
    end

    local alignment = {}
    for _ in ipairs(headers) do
        table_insert(alignment, "center")
    end
    local options = {
        alignment = alignment,
        coloredHeaders = true,
        width = "100%",
    }
    table_insert(outputParts, CreateStyledTable(headers, { rowData }, options))
end

local function BarHasSlottedContent(abilities, bar)
    if bar.ultimate and bar.ultimate ~= "" then
        return true
    end
    for i = 1, REGULAR_ABILITY_SLOTS do
        local ability = abilities[i]
        if ability and ability.id and ability.id > 0 then
            return true
        end
        if ability and ability.name and ability.name ~= "[Empty Slot]" and ability.name ~= "Empty" then
            return true
        end
    end
    return false
end

-- =====================================================
-- SKILL BARS ONLY (Front/Back Bar tables only)
-- =====================================================

function skillbars.GenerateSkillBarsOnly(skillBarData)
    -- Safe initialization
    helpers.InitializeUtilities()
    local cache = helpers.cache

    -- Validate input data - handle nil, non-table, or empty bars
    if not skillBarData or type(skillBarData) ~= "table" then
        CM.DebugPrint("EQUIPMENT", "GenerateSkillBarsOnly: No skill bar data provided")
        return ""
    end

    -- Check if bars exist and have content
    local bars = skillBarData.bars or skillBarData -- Support both {bars=[...]} and direct array
    if not bars or type(bars) ~= "table" or #bars == 0 then
        CM.DebugPrint("EQUIPMENT", "GenerateSkillBarsOnly: No bars in skill bar data")
        return ""
    end

    local outputParts = { "### Skill bars\n\n" }

    -- Determine weapon types from bar names for better labels
    local barLabels = {
        { emoji = "⚔️", suffix = "" },
        { emoji = "🔮", suffix = "" },
    }

    -- Try to detect weapon types from bar names
    for barIdx, bar in ipairs(bars) do
        local barName = bar.name or ""
        if barName:find("Backup") or barName:find("Back Bar") then
            barLabels[barIdx].suffix = " (Backup)"
        elseif barName:find("Main") or barName:find("Front") then
            barLabels[barIdx].suffix = " (Main Hand)"
        end
    end

    local hasBarContent = false

    for barIdx, bar in ipairs(bars) do
        if bar and type(bar) == "table" then
            local barName = bar.name or "Unknown Bar"
            table_insert(outputParts, "### " .. barName .. "\n\n")

            local abilities = (bar.abilities and type(bar.abilities) == "table") and bar.abilities or {}

            if BarHasSlottedContent(abilities, bar) then
                hasBarContent = true
                AppendSkillBarTable(outputParts, abilities, bar, cache)
            end
        end
    end

    if not hasBarContent then
        return ""
    end

    return table_concat(outputParts)
end

-- =====================================================
-- SKILL BARS (LEGACY - includes Equipment and Character Progress)
-- =====================================================

function skillbars.GenerateSkillBars(skillBarData, skillMorphsData, skillProgressionData, equipmentData)
    -- Safe initialization
    helpers.InitializeUtilities()
    local cache = helpers.cache

    -- Validate input data - handle nil, non-table, or empty bars
    if not skillBarData or type(skillBarData) ~= "table" then
        CM.DebugPrint("EQUIPMENT", "GenerateSkillBars: No skill bar data provided")
        local placeholder = "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n---\n\n"
        return placeholder
    end

    local bars = skillBarData.bars or skillBarData
    if not bars or type(bars) ~= "table" or #bars == 0 then
        CM.DebugPrint("EQUIPMENT", "GenerateSkillBars: No bars in skill bar data")
        local placeholder = "## ⚔️ Combat Arsenal\n\n*No skill bars configured*\n\n---\n\n"
        return placeholder
    end

    local output = ""
    local markdown_utils = cache.markdown
    local CreateCollapsible = markdown_utils and markdown_utils.CreateCollapsible

    CM.DebugPrint("EQUIPMENT", string.format("GenerateSkillBars: bars length=%s", tostring(#bars)))

    output = output .. "## ⚔️ Combat Arsenal\n\n"

    local barLabels = {
        { emoji = "⚔️", suffix = "" },
        { emoji = "🔮", suffix = "" },
    }

    -- Try to detect weapon types from bar names
    for barIdx, bar in ipairs(bars) do
        local barName = bar.name or ""
        if barName:find("Backup") or barName:find("Back Bar") then
            barLabels[barIdx].suffix = " (Backup)"
        elseif barName:find("Main") or barName:find("Front") then
            barLabels[barIdx].suffix = " (Main Hand)"
        end
    end

    for barIdx, bar in ipairs(bars) do
        if bar and type(bar) == "table" then
            local barName = bar.name or "Unknown Bar"
            output = output .. "### " .. barName .. "\n\n"

            local abilities = (bar.abilities and type(bar.abilities) == "table") and bar.abilities or {}

            if BarHasSlottedContent(abilities, bar) then
                local tableParts = { output }
                AppendSkillBarTable(tableParts, abilities, bar, cache)
                output = table_concat(tableParts)
            end
        end
    end

    if output == "## ⚔️ Combat Arsenal\n\n" then
        output = output .. "*No skill bars configured*\n\n"
    end

    -- Add Equipment & Active Sets
    if equipmentData then
        CM.Info("→ Including Equipment & Active Sets in Combat Arsenal")

        -- Use reference from CM.generators.sections
        local GenerateEquipment = CM.generators.sections.GenerateEquipment
        if GenerateEquipment then
            local success_equip, equipmentContent = pcall(GenerateEquipment, equipmentData, true)
            if success_equip and equipmentContent and equipmentContent ~= "" then
                output = output .. equipmentContent
            else
                CM.Error("GenerateSkillBars: Failed to generate Equipment content")
                output = output
                    .. '<a id="equipment--active-sets"></a>\n\n## ⚔️ Equipment & Active Sets\n\n*Error generating equipment data*\n\n'
            end
        end
    end

    local CreateSeparator = markdown_utils and markdown_utils.CreateSeparator
    if CreateSeparator then
        output = output .. CreateSeparator("hr")
    else
        output = output .. "---\n\n"
    end

    -- Add Skill Morphs as collapsible subsection
    if skillMorphsData and type(skillMorphsData) == "table" and (#skillMorphsData > 0 or next(skillMorphsData)) then
        local GenerateSkillMorphs = CM.generators.sections.GenerateSkillMorphs
        if GenerateSkillMorphs then
            local success, skillMorphsContent = pcall(GenerateSkillMorphs, skillMorphsData)
            if success and skillMorphsContent and type(skillMorphsContent) == "string" then
                skillMorphsContent = skillMorphsContent:gsub("^##%s+🌿%s+Skill%s+Morphs%s*\n%s*\n", "")
                skillMorphsContent = skillMorphsContent:gsub("%%-%%-%%-%s*\n%s*\n%s*$", "")

                if skillMorphsContent ~= "" then
                    if CreateCollapsible then
                        local success2, collapsibleContent =
                            pcall(CreateCollapsible, "Skill Morphs", skillMorphsContent, "🌿", false)
                        if success2 and collapsibleContent then
                            output = output .. collapsibleContent
                        else
                            output = output .. "### 🌿 Skill Morphs\n\n" .. skillMorphsContent .. "\n\n"
                        end
                    else
                        output = output .. "### 🌿 Skill Morphs\n\n" .. skillMorphsContent .. "\n\n"
                    end
                end
            end
        end
    end

    -- Add Character Progress categories as collapsible subsections
    if skillProgressionData and #skillProgressionData > 0 then
        output = output .. "## 📜 Character Progress\n\n"

        for _, category in ipairs(skillProgressionData) do
            if category.skills and #category.skills > 0 then
                local categoryContent = ""
                local categoryEmoji = category.emoji or "⚔️"

                local maxedSkills = {}
                local inProgressSkills = {}
                local lowLevelSkills = {}

                for _, skill in ipairs(category.skills) do
                    if skill.isRacial or skill.maxed or (skill.rank and skill.rank >= 50) then
                        table.insert(maxedSkills, skill)
                    elseif skill.rank and skill.rank >= 20 then
                        table.insert(inProgressSkills, skill)
                    else
                        table.insert(lowLevelSkills, skill)
                    end
                end

                if #maxedSkills > 0 then
                    local maxedNames = {}
                    for _, skill in ipairs(maxedSkills) do
                        local skillNameLinked = cache.CreateSkillLineLink(skill.name)
                        table.insert(maxedNames, "**" .. skillNameLinked .. "**")
                    end
                    categoryContent = categoryContent .. "#### ✅ Maxed\n"
                    categoryContent = categoryContent .. table.concat(maxedNames, ", ") .. "\n\n"
                end

                if #inProgressSkills > 0 then
                    categoryContent = categoryContent .. "#### 📈 In Progress\n"
                    for _, skill in ipairs(inProgressSkills) do
                        local skillNameLinked = cache.CreateSkillLineLink(skill.name)
                        local progressPercent = skill.progress or 0
                        local progressBar = cache.GenerateProgressBar(progressPercent, 10)
                        categoryContent = categoryContent
                            .. "- **"
                            .. skillNameLinked
                            .. "**: Rank "
                            .. (skill.rank or 0)
                            .. " "
                            .. progressBar
                            .. " "
                            .. progressPercent
                            .. "%\n"
                    end
                    categoryContent = categoryContent .. "\n"
                end

                if #lowLevelSkills > 0 then
                    categoryContent = categoryContent .. "#### ⚪ Early Progress\n"
                    for _, skill in ipairs(lowLevelSkills) do
                        local skillNameLinked = cache.CreateSkillLineLink(skill.name)
                        local progressPercent = skill.progress or 0
                        local progressBar = cache.GenerateProgressBar(progressPercent, 10)
                        categoryContent = categoryContent
                            .. "- **"
                            .. skillNameLinked
                            .. "**: Rank "
                            .. (skill.rank or 0)
                            .. " "
                            .. progressBar
                            .. " "
                            .. progressPercent
                            .. "%\n"
                    end
                    categoryContent = categoryContent .. "\n"
                end

                -- Passives
                local allPassives = {}
                for _, skill in ipairs(category.skills or {}) do
                    if skill.passives and #skill.passives > 0 then
                        for _, passive in ipairs(skill.passives) do
                            table.insert(allPassives, {
                                name = passive.name,
                                abilityId = passive.abilityId,
                                purchased = passive.purchased,
                                currentRank = passive.currentRank,
                                maxRank = passive.maxRank,
                                skillLineName = skill.name,
                            })
                        end
                    end
                end

                if #allPassives > 0 then
                    categoryContent = categoryContent .. "#### ✨ Passives\n"
                    for _, passive in ipairs(allPassives) do
                        local passiveName = cache.CreateAbilityLink(passive.name, passive.abilityId)
                        local passiveStatus = passive.purchased and "✅" or "🔒"
                        local rankInfo = ""
                        if passive.currentRank and passive.maxRank and passive.maxRank > 1 then
                            rankInfo = string.format(" (%d/%d)", passive.currentRank or 0, passive.maxRank)
                        end
                        local skillLineLink = cache.CreateSkillLineLink(passive.skillLineName)
                        categoryContent = categoryContent
                            .. string.format(
                                "- %s %s%s *(from %s)*\n",
                                passiveStatus,
                                passiveName,
                                rankInfo,
                                skillLineLink
                            )
                    end
                    categoryContent = categoryContent .. "\n"
                end

                if categoryContent ~= "" then
                    if CreateCollapsible then
                        local success3, collapsibleContent2 =
                            pcall(CreateCollapsible, category.name, categoryContent, categoryEmoji, false)
                        if success3 and collapsibleContent2 then
                            output = output .. collapsibleContent2
                        else
                            output = output
                                .. "### "
                                .. categoryEmoji
                                .. " "
                                .. category.name
                                .. "\n\n"
                                .. categoryContent
                                .. "\n\n"
                        end
                    else
                        output = output
                            .. "### "
                            .. categoryEmoji
                            .. " "
                            .. category.name
                            .. "\n\n"
                            .. categoryContent
                            .. "\n\n"
                    end
                end
            end
        end
    end

    return output
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections.GenerateSkillBars = skillbars.GenerateSkillBars
CM.generators.sections.GenerateSkillBarsOnly = skillbars.GenerateSkillBarsOnly
CM.generators.sections.equipment.SkillBars = skillbars

CM.DebugPrint("GENERATOR", "Skill bars module loaded")
