-- CharacterMarkdown - Skills Generator
-- Generates character progress summary and detailed skill sections

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.equipment = CM.generators.sections.equipment or {}

local helpers = CM.generators.sections.equipment
local skills = {}
local table_insert = table.insert

local constants = CM.constants or CM.Constants or {}
local SKILL_TYPE_NAMES = constants.SKILL_TYPE_NAMES or {}
local SKILL_TYPE_EMOJIS = constants.SKILL_TYPE_EMOJIS or {}
local DEFAULT_SKILL_EMOJI = constants.DEFAULT_SKILL_EMOJI or "📜"
local ALLIANCE_WAR_SKILL_TYPE = 6

local function CountMorphAbilities(skillMorphsData)
    if not skillMorphsData then
        return 0
    end
    if skillMorphsData.summary and skillMorphsData.summary.totalMorphs then
        return skillMorphsData.summary.totalMorphs
    end

    local skillTypes = skillMorphsData.skillTypes or skillMorphsData
    if type(skillTypes) ~= "table" or #skillTypes == 0 then
        return 0
    end

    local total = 0
    for _, skillType in ipairs(skillTypes) do
        for _, skillLine in ipairs(skillType.skillLines or {}) do
            total = total + #(skillLine.abilities or {})
        end
    end
    return total
end

local function GroupLinesByStatusAndCategory(lines, excludeType)
    local statusGroups = { maxed = {}, inProgress = {}, earlyProgress = {} }

    for _, line in ipairs(lines or {}) do
        if line.type ~= excludeType then
            local typeName = SKILL_TYPE_NAMES[line.type] or "Other"
            local emoji = SKILL_TYPE_EMOJIS[typeName] or DEFAULT_SKILL_EMOJI
            local bucket

            if line.status == "maxed" or line.maxed then
                bucket = statusGroups.maxed
            elseif line.status == "in_progress" then
                bucket = statusGroups.inProgress
            else
                bucket = statusGroups.earlyProgress
            end

            if not bucket[typeName] then
                bucket[typeName] = { emoji = emoji, name = typeName, skills = {} }
            end
            table_insert(bucket[typeName].skills, line)
        end
    end

    return statusGroups
end

local function GroupLegacyCategoriesByStatus(categories, excludeName)
    local statusGroups = { maxed = {}, inProgress = {}, earlyProgress = {} }

    for _, category in ipairs(categories or {}) do
        if category.name ~= excludeName and category.skills and #category.skills > 0 then
            local maxedSkills = {}
            local inProgressSkills = {}
            local earlyProgressSkills = {}

            for _, skill in ipairs(category.skills) do
                if skill.isRacial or skill.maxed or (skill.rank and skill.rank >= 50) then
                    table_insert(maxedSkills, skill)
                elseif skill.rank and skill.rank >= 20 then
                    table_insert(inProgressSkills, skill)
                else
                    table_insert(earlyProgressSkills, skill)
                end
            end

            if #maxedSkills > 0 then
                statusGroups.maxed[category.name] = {
                    emoji = category.emoji or "⚔️",
                    name = category.name,
                    skills = maxedSkills,
                }
            end
            if #inProgressSkills > 0 then
                statusGroups.inProgress[category.name] = {
                    emoji = category.emoji or "⚔️",
                    name = category.name,
                    skills = inProgressSkills,
                }
            end
            if #earlyProgressSkills > 0 then
                statusGroups.earlyProgress[category.name] = {
                    emoji = category.emoji or "⚔️",
                    name = category.name,
                    skills = earlyProgressSkills,
                }
            end
        end
    end

    return statusGroups
end

-- =====================================================
-- PROGRESS SUMMARY DASHBOARD
-- =====================================================

function skills.GenerateProgressSummary(skillProgressionData, skillMorphsData)
    helpers.InitializeUtilities()
    local cache = helpers.cache

    local totalAbilitiesWithMorphs = CountMorphAbilities(skillMorphsData)
    local maxedSkillLines = 0
    local inProgressSkillLines = 0
    local earlyProgressSkillLines = 0
    local overallCompletion = 0

    if skillProgressionData and skillProgressionData.summary then
        local summary = skillProgressionData.summary
        maxedSkillLines = summary.maxedCount or 0
        inProgressSkillLines = summary.inProgressCount or 0
        earlyProgressSkillLines = summary.earlyProgressCount or 0
        overallCompletion = summary.completionPercent or 0
    elseif skillProgressionData and skillProgressionData.lines then
        for _, line in ipairs(skillProgressionData.lines) do
            if line.status == "maxed" or line.maxed then
                maxedSkillLines = maxedSkillLines + 1
            elseif line.status == "in_progress" then
                inProgressSkillLines = inProgressSkillLines + 1
            else
                earlyProgressSkillLines = earlyProgressSkillLines + 1
            end
        end
        local totalSkillLines = maxedSkillLines + inProgressSkillLines + earlyProgressSkillLines
        overallCompletion = totalSkillLines > 0 and math.floor((maxedSkillLines / totalSkillLines) * 100) or 0
    elseif skillProgressionData and #skillProgressionData > 0 then
        for _, category in ipairs(skillProgressionData) do
            if category.skills and #category.skills > 0 then
                for _, skill in ipairs(category.skills) do
                    if skill.isRacial or skill.maxed or (skill.rank and skill.rank >= 50) then
                        maxedSkillLines = maxedSkillLines + 1
                    elseif skill.rank and skill.rank >= 20 then
                        inProgressSkillLines = inProgressSkillLines + 1
                    else
                        earlyProgressSkillLines = earlyProgressSkillLines + 1
                    end
                end
            end
        end
        local totalSkillLines = maxedSkillLines + inProgressSkillLines + earlyProgressSkillLines
        overallCompletion = totalSkillLines > 0 and math.floor((maxedSkillLines / totalSkillLines) * 100) or 0
    end

    local output = "### Progress Overview\n\n"

    local CreateStyledTable = cache.markdown and cache.markdown.CreateStyledTable
    if CreateStyledTable then
        local headers =
            { "Maxed Skill Lines", "In Progress", "Early Progress", "Abilities with Morphs", "Overall Completion" }
        local rows = {
            {
                tostring(maxedSkillLines),
                tostring(inProgressSkillLines),
                tostring(earlyProgressSkillLines),
                tostring(totalAbilitiesWithMorphs),
                string.format("%d%%", overallCompletion),
            },
        }
        local options = { alignment = { "right", "right", "right", "right", "right" }, coloredHeaders = true }
        output = output .. CreateStyledTable(headers, rows, options)
    else
        output = output
            .. "| Maxed Skill Lines | In Progress | Early Progress | Abilities with Morphs | Overall Completion |\n"
        output = output .. "|:---|:---|:---|:---|:---|\n"
        output = output
            .. string.format(
                "| %d | %d | %d | %d | %d%% |\n",
                maxedSkillLines,
                inProgressSkillLines,
                earlyProgressSkillLines,
                totalAbilitiesWithMorphs,
                overallCompletion
            )
        output = output .. "\n"
    end

    return output
end

-- =====================================================
-- SKILLS (reorganized by status)
-- =====================================================

function skills.GenerateSkills(skillData, skillMorphsData)
    helpers.InitializeUtilities()
    local cache = helpers.cache

    skillData = skillData or {}

    local output = ""

    -- Add Progress Summary
    local summaryTable = skills.GenerateProgressSummary(skillData, skillMorphsData)
    if summaryTable and summaryTable ~= "" then
        output = output .. summaryTable .. "\n\n"
    end

    local statusGroups
    if skillData.lines then
        statusGroups = GroupLinesByStatusAndCategory(skillData.lines, ALLIANCE_WAR_SKILL_TYPE)
    elseif #skillData > 0 then
        statusGroups = GroupLegacyCategoriesByStatus(skillData, "Alliance War")
    else
        statusGroups = { maxed = {}, inProgress = {}, earlyProgress = {} }
    end

    local function GeneratePassivesList(skills_list)
        local allPassives = {}
        for _, skill in ipairs(skills_list or {}) do
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

        if #allPassives == 0 then
            return ""
        end

        local passivesContent = ""
        for _, passive in ipairs(allPassives) do
            local passiveName = cache.CreateAbilityLink(passive.name, passive.abilityId)
            local passiveStatus = passive.purchased and "✅" or "🔒"
            local rankInfo = (passive.currentRank and passive.maxRank and passive.maxRank > 1)
                    and string.format(" (%d/%d)", passive.currentRank, passive.maxRank)
                or ""
            local skillLineLink = cache.CreateSkillLineLink(passive.skillLineName)
            passivesContent = passivesContent
                .. string.format("- %s %s%s *(from %s)*\n", passiveStatus, passiveName, rankInfo, skillLineLink)
        end
        return passivesContent
    end

    -- Generate Maxed Skills section
    if next(statusGroups.maxed) then
        output = output .. "### ✅ Maxed Skills\n\n"
        for _, categoryData in pairs(statusGroups.maxed) do
            local maxedNames = {}
            for _, skill in ipairs(categoryData.skills) do
                table.insert(maxedNames, "**" .. cache.CreateSkillLineLink(skill.name) .. "**")
            end

            local summaryText = string.format(
                "%s %s (%d skill line%s maxed)",
                categoryData.emoji,
                categoryData.name,
                #categoryData.skills,
                #categoryData.skills > 1 and "s" or ""
            )
            local categoryContent = table.concat(maxedNames, ", ") .. "\n\n"
            local passivesContent = GeneratePassivesList(categoryData.skills)
            if passivesContent ~= "" then
                categoryContent = categoryContent
                    .. "<details>\n<summary>✨ Passives</summary>\n\n"
                    .. passivesContent
                    .. "</details>\n\n"
            end
            output = output
                .. "<details>\n<summary>"
                .. summaryText
                .. "</summary>\n\n"
                .. categoryContent
                .. "</details>\n\n"
        end
    end

    -- Generate In-Progress Skills section
    if next(statusGroups.inProgress) then
        output = output .. "### 📈 In-Progress Skills\n\n"
        for _, categoryData in pairs(statusGroups.inProgress) do
            local lineParts = {}
            for _, skill in ipairs(categoryData.skills) do
                local progressBar = cache.GenerateProgressBar(skill.progress or 0, 10)
                table.insert(
                    lineParts,
                    string.format(
                        "- **%s**: Rank %d %s %d%%\n",
                        cache.CreateSkillLineLink(skill.name),
                        skill.rank or 0,
                        progressBar,
                        skill.progress or 0
                    )
                )
            end
            local categoryContent = table.concat(lineParts) .. "\n"
            local passivesContent = GeneratePassivesList(categoryData.skills)
            if passivesContent ~= "" then
                categoryContent = categoryContent
                    .. "<details>\n<summary>✨ Passives</summary>\n\n"
                    .. passivesContent
                    .. "</details>\n\n"
            end
            local summaryText = string.format(
                "%s %s (%d skill line%s in progress)",
                categoryData.emoji,
                categoryData.name,
                #categoryData.skills,
                #categoryData.skills > 1 and "s" or ""
            )
            output = output
                .. "<details>\n<summary>"
                .. summaryText
                .. "</summary>\n\n"
                .. categoryContent
                .. "</details>\n\n"
        end
    end

    -- Generate Early Progress Skills section
    if next(statusGroups.earlyProgress) then
        output = output .. "### ⚪ Early Progress Skills\n\n"
        for _, categoryData in pairs(statusGroups.earlyProgress) do
            local lineParts = {}
            for _, skill in ipairs(categoryData.skills) do
                local progressBar = cache.GenerateProgressBar(skill.progress or 0, 10)
                table.insert(
                    lineParts,
                    string.format(
                        "- **%s**: Rank %d %s %d%%\n",
                        cache.CreateSkillLineLink(skill.name),
                        skill.rank or 0,
                        progressBar,
                        skill.progress or 0
                    )
                )
            end
            local categoryContent = table.concat(lineParts) .. "\n"
            local passivesContent = GeneratePassivesList(categoryData.skills)
            if passivesContent ~= "" then
                categoryContent = categoryContent
                    .. "<details>\n<summary>✨ Passives</summary>\n\n"
                    .. passivesContent
                    .. "</details>\n\n"
            end
            local summaryText = string.format(
                "%s %s (%d skill line%s)",
                categoryData.emoji,
                categoryData.name,
                #categoryData.skills,
                #categoryData.skills > 1 and "s" or ""
            )
            output = output
                .. "<details>\n<summary>"
                .. summaryText
                .. "</summary>\n\n"
                .. categoryContent
                .. "</details>\n\n"
        end
    end

    return output
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections.GenerateSkills = skills.GenerateSkills
CM.generators.sections.GenerateProgressSummary = skills.GenerateProgressSummary
CM.generators.sections.equipment.Skills = skills

CM.DebugPrint("GENERATOR", "Skills module loaded")
