-- CharacterMarkdown - PvP Stats Section Generator
-- Generates PvP statistics and campaign data markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateProgressBar, FormatTime

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        FormatTime = CM.utils.FormatTime
    end
end

-- Helper: Generate rank progression text
local function GenerateRankProgression(progression, format)
    if not progression or (progression.pointsToNext or 0) <= 0 then
        return ""
    end

    local progressText = string.format(
        "%s / %s AP",
        FormatNumber(progression.currentPoints - progression.subRankStart),
        FormatNumber(progression.nextSubRank - progression.subRankStart)
    )

    local percentText = string.format("%.1f%%", progression.progressPercent)

    if GenerateProgressBar then
        local progressBar = GenerateProgressBar(progression.progressPercent, 10)
        return string.format("%s to next grade %s %s", progressText, progressBar, percentText)
    else
        return string.format("%s to next grade (%s)", progressText, percentText)
    end
end

-- Helper: Generate campaign ruleset description
local function GenerateCampaignRuleset(campaign)
    local parts = {}

    if campaign.ruleset and campaign.ruleset.name and campaign.ruleset.name ~= "" then
        table.insert(parts, campaign.ruleset.name)
    end

    if campaign.ruleset and campaign.ruleset.allowsCP ~= nil then
        if campaign.ruleset.allowsCP then
            table.insert(parts, "CP Enabled")
        else
            table.insert(parts, "No CP")
        end
    end

    if #parts > 0 then
        return table.concat(parts, ", ")
    end

    return ""
end

-- =====================================================
-- HELPER: GENERATE ALLIANCE WAR COLUMN
-- =====================================================

local function GenerateAllianceWarColumn(pvp, settings)
    if not pvp then
        return ""
    end

    local markdown = ""
    local showProgression = settings.showPvPProgression or false

    markdown = markdown .. "#### Alliance War Status\n\n"

    -- Build table rows
    local headers = { "Category", "Value" }
    local rows = {}

    -- Rank
    if pvp.rankName and pvp.rankName ~= "" then
        local rankText = pvp.rankName
        if (pvp.rank or 0) > 0 then
            rankText = string.format("%s (Rank %d)", rankText, pvp.rank)
        end
        table.insert(rows, { "Rank", rankText })
    end

    -- Alliance Points
    if (pvp.rankPoints or 0) > 0 then
        table.insert(rows, { "Alliance Points", FormatNumber(pvp.rankPoints) })
    end

    -- Progression
    if showProgression and pvp.progression and (pvp.progression.pointsToNext or 0) > 0 then
        local progressText = GenerateRankProgression(pvp.progression)
        if progressText ~= "" then
            table.insert(rows, { "Progress to Next", progressText })
            table.insert(rows, { "AP Needed", FormatNumber(pvp.progression.pointsToNext) })
        end
    end

    -- Alliance
    if pvp.allianceName and pvp.allianceName ~= "" then
        table.insert(rows, { "Alliance", pvp.allianceName })
    end

    local CreateStyledTable = CM.utils.markdown.CreateStyledTable
    local options = {
        alignment = { "left", "left" },
        coloredHeaders = true,
    }
    markdown = markdown .. CreateStyledTable(headers, rows, options)

    return markdown
end

-- =====================================================
-- HELPER: GENERATE CAMPAIGN COLUMN
-- =====================================================

local function GenerateCampaignColumn(pvp, settings)
    if not pvp then
        return ""
    end

    local markdown = ""
    local CreateCampaignLink = CM.links and CM.links.CreateCampaignLink
    local showCampaignRewards = settings.showCampaignRewards or false
    local detailedPvP = settings.showDetailedPvP or false

    if not pvp.campaign or not pvp.campaign.name or pvp.campaign.name == "" then
        return markdown
    end

    markdown = markdown .. "#### Campaign\n\n"

    -- Build table rows
    local headers = { "Category", "Value" }
    local rows = {}

    -- Campaign name
    local campaignLink = pvp.campaign.name
    if CreateCampaignLink then
        campaignLink = CreateCampaignLink(pvp.campaign.name) or pvp.campaign.name
    end
    if pvp.campaign.isActive then
        campaignLink = campaignLink .. " 🟢"
    end
    table.insert(rows, { "Campaign", campaignLink })

    -- Ruleset
    local ruleset = GenerateCampaignRuleset(pvp.campaign)
    if ruleset ~= "" then
        table.insert(rows, { "Ruleset", ruleset })
    end

    -- Campaign Rewards
    if showCampaignRewards and pvp.rewards and (pvp.rewards.earnedTier or 0) > 0 then
        table.insert(rows, { "Reward Tier", string.format("%d / 5", pvp.rewards.earnedTier) })

        if (pvp.rewards.loyaltyStreak or 0) > 0 then
            table.insert(rows, { "Loyalty", string.format("%d campaigns", pvp.rewards.loyaltyStreak) })
        end
    end

    local CreateStyledTable = CM.utils.markdown.CreateStyledTable
    local options = {
        alignment = { "left", "left" },
        coloredHeaders = true,
    }
    markdown = markdown .. CreateStyledTable(headers, rows, options)

    return markdown
end

-- =====================================================
-- HELPER: GENERATE LEADERBOARDS & BATTLEGROUNDS COLUMN
-- =====================================================

local function GenerateLeaderboardsColumn(leaderboards, battlegrounds, settings)
    local markdown = ""
    local showLeaderboards = settings.showLeaderboards or false
    local showBattlegrounds = settings.showBattlegrounds or false

    -- Leaderboard Position
    if showLeaderboards and leaderboards.playerPosition and leaderboards.playerPosition.found then
        markdown = markdown .. "#### Leaderboard\n\n"

        local headers = { "Category", "Value" }
        local rows = {
            { "Rank", string.format("#%d", leaderboards.playerPosition.rank) },
        }

        if (leaderboards.playerPosition.ap or 0) > 0 then
            table.insert(rows, { "AP", FormatNumber(leaderboards.playerPosition.ap) })
        end

        if leaderboards.playerPosition.rank == 1 then
            table.insert(rows, { "Status", "👑 Candidate" })
        elseif leaderboards.playerPosition.rank <= 10 then
            table.insert(rows, { "Status", "Top 10" })
        end

        local CreateStyledTable = CM.utils.markdown.CreateStyledTable
        local options = {
            alignment = { "left", "left" },
            coloredHeaders = true,
        }
        markdown = markdown .. CreateStyledTable(headers, rows, options)
    end

    -- Battlegrounds
    if showBattlegrounds and battlegrounds.leaderboards then
        local bg = battlegrounds.leaderboards
        if (bg.deathmatch.rank or 0) > 0 or (bg.flagGames.rank or 0) > 0 or (bg.landGrab.rank or 0) > 0 then
            markdown = markdown .. "#### Battlegrounds\n\n"

            local headers = { "Mode", "Rank" }
            local rows = {}

            if (bg.deathmatch.rank or 0) > 0 then
                table.insert(rows, { "Deathmatch", string.format("#%d", bg.deathmatch.rank) })
            end

            if (bg.flagGames.rank or 0) > 0 then
                table.insert(rows, { "Flag Games", string.format("#%d", bg.flagGames.rank) })
            end

            if (bg.landGrab.rank or 0) > 0 then
                table.insert(rows, { "Land Grab", string.format("#%d", bg.landGrab.rank) })
            end

            local CreateStyledTable = CM.utils.markdown.CreateStyledTable
            local options = {
                alignment = { "left", "right" },
                coloredHeaders = true,
            }
            markdown = markdown .. CreateStyledTable(headers, rows, options)
        end
    end

    return markdown
end

-- =====================================================
-- HELPER: GENERATE ALLIANCE WAR SKILLS
-- =====================================================

local function GenerateAllianceWarSkills(skillProgressionData)
    if not skillProgressionData then
        return ""
    end

    local CreateSkillLineLink = CM.links and CM.links.CreateSkillLineLink
    local CreateAbilityLink = CM.links and CM.links.CreateAbilityLink
    local CreateCollapsible = CM.utils and CM.utils.markdown and CM.utils.markdown.CreateCollapsible

    local allianceWarSkills = {}

    if skillProgressionData.lines then
        for _, line in ipairs(skillProgressionData.lines) do
            if line.type == 6 then
                table.insert(allianceWarSkills, line)
            end
        end
    elseif #skillProgressionData > 0 then
        for _, category in ipairs(skillProgressionData) do
            if category.name == "Alliance War" and category.skills then
                allianceWarSkills = category.skills
                break
            end
        end
    end

    if #allianceWarSkills == 0 then
        return ""
    end

    local markdown = ""
    local categoryEmoji = "🏰"

    -- Group skills by status
    local maxedSkills = {}
    local inProgressSkills = {}
    local lowLevelSkills = {}

    for _, skill in ipairs(allianceWarSkills) do
        if skill.status == "maxed" or skill.maxed or (skill.rank and skill.rank >= 50) then
            table.insert(maxedSkills, skill)
        elseif skill.status == "in_progress" or (skill.rank and skill.rank >= 20) then
            table.insert(inProgressSkills, skill)
        else
            table.insert(lowLevelSkills, skill)
        end
    end

    -- Show maxed skills first (compact)
    if #maxedSkills > 0 then
        local maxedNames = {}
        for _, skill in ipairs(maxedSkills) do
            local skillNameLinked = (CreateSkillLineLink and CreateSkillLineLink(skill.name)) or skill.name
            table.insert(maxedNames, "**" .. skillNameLinked .. "**")
        end
        markdown = markdown .. "#### ✅ Maxed\n"
        markdown = markdown .. table.concat(maxedNames, ", ") .. "\n\n"
    end

    -- Show in-progress skills with progress bars
    if #inProgressSkills > 0 then
        markdown = markdown .. "#### 📈 In Progress\n"
        for _, skill in ipairs(inProgressSkills) do
            local skillNameLinked = (CreateSkillLineLink and CreateSkillLineLink(skill.name)) or skill.name
            local progressPercent = skill.progress or 0
            local progressBar = GenerateProgressBar(progressPercent, 10)
            markdown = markdown
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
        markdown = markdown .. "\n"
    end

    -- Show low-level skills
    if #lowLevelSkills > 0 then
        markdown = markdown .. "#### ⚪ Early Progress\n"
        for _, skill in ipairs(lowLevelSkills) do
            local skillNameLinked = (CreateSkillLineLink and CreateSkillLineLink(skill.name)) or skill.name
            local progressPercent = skill.progress or 0
            local progressBar = GenerateProgressBar(progressPercent, 10)
            markdown = markdown
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
        markdown = markdown .. "\n"
    end

    -- Show passives for all skills in this category
    local allPassives = {}
    for _, skill in ipairs(allianceWarSkills) do
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
        markdown = markdown .. "#### ✨ Passives\n"
        for _, passive in ipairs(allPassives) do
            local passiveName = (CreateAbilityLink and CreateAbilityLink(passive.name, passive.abilityId))
                or passive.name
            local passiveStatus = passive.purchased and "✅" or "🔒"
            local rankInfo = ""
            if passive.currentRank and passive.maxRank and passive.maxRank > 1 then
                rankInfo = string.format(" (%d/%d)", passive.currentRank or 0, passive.maxRank)
            end
            local skillLineLink = (CreateSkillLineLink and CreateSkillLineLink(passive.skillLineName))
                or passive.skillLineName
            -- Build entire line as single string to prevent merging
            local line = string.format("- %s %s%s *(from %s)*", passiveStatus, passiveName, rankInfo, skillLineLink)
            -- Remove trailing whitespace and add explicit newline
            line = line:gsub("%s+$", "") .. "\n"
            markdown = markdown .. line
        end
        markdown = markdown .. "\n"
    end

    -- Wrap in collapsible
    if CreateCollapsible and markdown ~= "" then
        return CreateCollapsible("Alliance War", markdown, categoryEmoji, false) or ""
    end

    return markdown
end

-- =====================================================
-- MAIN GENERATOR
-- =====================================================

local function GeneratePvPStats(pvpData, pvpStatsData, skillProgressionData, settings)
    InitializeUtilities()

    -- Use provided settings or get current settings
    if not settings then
        settings = CM.GetSettings()
    end

    -- includePvP = basic Alliance War profile; includePvPStats = detailed stats block
    local showPvPStats = settings.includePvPStats or settings.includePvP or false
    local showAllianceWarSkills = settings.showAllianceWarSkills or false

    -- Return empty if nothing to show
    if not showPvPStats and not showAllianceWarSkills then
        return ""
    end

    -- Require at least one data source for PvP stats
    if showPvPStats and (not pvpStatsData or not pvpStatsData.pvp) and not pvpData then
        showPvPStats = false
    end

    -- Fallback: Use basic pvp data (arg 1) if pvpStatsData (arg 2) is missing or incomplete
    local pvp = nil
    if showPvPStats then
        if pvpStatsData and pvpStatsData.pvp then
            pvp = pvpStatsData.pvp
        elseif pvpData then
            pvp = pvpData
        end
    end
    local leaderboards = showPvPStats and pvpStatsData and pvpStatsData.leaderboards or {}
    local battlegrounds = showPvPStats and pvpStatsData and pvpStatsData.battlegrounds or {}

    local markdown = ""

    -- =====================================================
    -- PvP Content
    -- =====================================================
    -- Generate content first to check if we have anything to show
    local pvpContent = ""
    local skillsContent = ""

    -- PvP Stats section (if enabled)
    if showPvPStats then
        local pvpSection = ""
        pvpSection = pvpSection .. "### PvP Profile\n\n"

        -- Use 2-3 column layout for PvP areas
        local CreateTwoColumnLayout = CM.utils.markdown and CM.utils.markdown.CreateTwoColumnLayout
        local CreateThreeColumnLayout = CM.utils.markdown and CM.utils.markdown.CreateThreeColumnLayout

        -- Generate columns
        local column1 = GenerateAllianceWarColumn(pvp, settings)
        local column2 = GenerateCampaignColumn(pvp, settings)
        local column3 = GenerateLeaderboardsColumn(leaderboards, battlegrounds, settings)

        -- Only add if we have at least one column with content
        if column1 ~= "" or column2 ~= "" or column3 ~= "" then
            -- Use 3-column if we have content in the third column, otherwise 2-column
            if CreateThreeColumnLayout and column3 ~= "" then
                pvpSection = pvpSection .. CreateThreeColumnLayout(column1, column2, column3)
            elseif CreateTwoColumnLayout then
                pvpSection = pvpSection .. CreateTwoColumnLayout(column1, column2)
            else
                -- Fallback to vertical layout
                pvpSection = pvpSection .. column1 .. "\n"
                pvpSection = pvpSection .. column2 .. "\n"
                if column3 ~= "" then
                    pvpSection = pvpSection .. column3 .. "\n"
                end
            end
            pvpContent = pvpSection
        end
    end

    -- Alliance War Skills section (if enabled)
    if showAllianceWarSkills and skillProgressionData then
        local allianceWarSkills = GenerateAllianceWarSkills(skillProgressionData)
        if allianceWarSkills ~= "" then
            skillsContent = allianceWarSkills .. "\n"
        end
    end

    -- Only output the main header if we have content
    if pvpContent ~= "" or skillsContent ~= "" then
        markdown = markdown .. "## ⚔️ PvP\n\n"

        if pvpContent ~= "" then
            markdown = markdown .. pvpContent
        end

        if skillsContent ~= "" then
            markdown = markdown .. skillsContent
        end

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
CM.generators.sections.GeneratePvPStats = GeneratePvPStats
-- Also export as GeneratePvP to maintain compatibility
CM.generators.sections.GeneratePvP = GeneratePvPStats

return {
    GeneratePvPStats = GeneratePvPStats,
    GeneratePvP = GeneratePvPStats, -- Alias for compatibility
}
