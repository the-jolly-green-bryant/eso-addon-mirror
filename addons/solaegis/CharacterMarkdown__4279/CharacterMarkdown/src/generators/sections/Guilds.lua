-- CharacterMarkdown - Guilds Section Generator
-- Generates guild membership information markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateAnchor

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        if CM.utils then
            FormatNumber = CM.utils.FormatNumber
        end
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
    end
end

-- =====================================================
-- GUILDS
-- =====================================================

-- =====================================================
-- UNDAUNTED ACTIVE PLEDGES (Subsection)
-- =====================================================

local function GenerateUndauntedActivePledges(undauntedPledgesData)
    local markdown = ""
    local pledges = undauntedPledgesData.pledges or {}

    if not pledges.active or #pledges.active == 0 then
        return ""
    end

    markdown = markdown .. "### 📋 Undaunted Active Pledges\n\n"

    local CreateZoneLink = CM.links and CM.links.CreateZoneLink
    for _, pledge in ipairs(pledges.active) do
        -- Parse pledge name: "Pledge: Darkshade II - Deshaan" -> extract dungeon and zone
        local pledgeText = pledge.name or ""
        local locationText = pledge.location or ""

        -- Extract dungeon name (part after "Pledge: " and before " - ")
        local dungeonName = pledgeText
        if pledgeText:find("Pledge: ") and pledgeText:find(" - ") then
            -- Format: "Pledge: DUNGEON - ZONE"
            dungeonName = pledgeText:match("Pledge: (.+) %-")
                or pledgeText:gsub("^Pledge: ", ""):match("(.+) %-")
                or pledgeText:gsub("^Pledge: ", "")
        elseif pledgeText:find("Pledge: ") then
            -- Format: "Pledge: DUNGEON" (no location separator)
            dungeonName = pledgeText:gsub("^Pledge: ", "")
        end

        -- Clean up dungeon name
        dungeonName = dungeonName:gsub("^%s+", ""):gsub("%s+$", "")

        -- Create links for dungeon and location
        local dungeonLink = (CreateZoneLink and CreateZoneLink(dungeonName)) or dungeonName
        local locationLink = ""
        if locationText ~= "" then
            locationLink = (CreateZoneLink and CreateZoneLink(locationText)) or locationText
        elseif pledgeText:find(" - ") then
            -- Extract zone from pledge name if location field is empty
            local zoneName = pledgeText:match("%- (.+)$")
            if zoneName then
                zoneName = zoneName:gsub("^%s+", ""):gsub("%s+$", "")
                locationLink = (CreateZoneLink and CreateZoneLink(zoneName)) or zoneName
            end
        end

        markdown = markdown .. "- Pledge: " .. dungeonLink
        if locationLink ~= "" and locationLink ~= dungeonLink then
            markdown = markdown .. " - " .. locationLink
        end
        markdown = markdown .. "\n"
    end

    markdown = markdown .. "\n"

    return markdown
end

local function GenerateGuilds(guildsData, undauntedPledgesData)
    InitializeUtilities()

    local markdown = ""

    -- Handle both direct list (old format) and structured object (new format)
    local guildsList = guildsData
    if guildsData and guildsData.list then
        guildsList = guildsData.list
    end

    -- Sort guilds alphabetically by name
    if guildsList and #guildsList > 1 then
        table.sort(guildsList, function(a, b)
            local nameA = (a.name or ""):lower()
            local nameB = (b.name or ""):lower()
            return nameA < nameB
        end)
    end

    if not guildsList or #guildsList == 0 then
        -- Show placeholder when enabled but no data available
        local anchorId = GenerateAnchor and GenerateAnchor("🏰 Guild Membership") or "guild-membership"
        markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## 🏰 Guild Membership\n\n" -- Changed from 🏛️ for better compatibility
        markdown = markdown .. "*No guild data available*\n\n"

        -- Still show Undaunted Pledges subsection even if no guilds
        if
            undauntedPledgesData
            and undauntedPledgesData.pledges
            and undauntedPledgesData.pledges.active
            and #undauntedPledgesData.pledges.active > 0
        then
            markdown = markdown .. GenerateUndauntedActivePledges(undauntedPledgesData)
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

    local anchorId = GenerateAnchor and GenerateAnchor("🏰 Guild Membership") or "guild-membership"
    markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
    markdown = markdown .. "## 🏰 Guild Membership\n\n" -- Changed from 🏛️ for better compatibility

    if #guildsList > 0 then
        local CreateStyledTable = CM.utils.markdown.CreateStyledTable
        if CreateStyledTable then
            local headers = { "Guild Name", "Rank", "Members", "Alliance" }
            local rows = {}

            local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink
            for _, guild in ipairs(guildsList) do
                local allianceName = "Unknown"
                if guild.alliance then
                    if type(guild.alliance) == "table" then
                        allianceName = guild.alliance.name or "Unknown"
                    else
                        allianceName = guild.alliance
                    end
                end

                -- Only link actual alliances (not "Cross-Alliance")
                local allianceText = allianceName
                if allianceName ~= "Cross-Alliance" and allianceName ~= "Unknown" and allianceName ~= "" then
                    allianceText = (CreateAllianceLink and CreateAllianceLink(allianceName)) or allianceName
                end

                local rankName = guild.rankName or guild.rank or "Member"
                if CM.utils and CM.utils.StripColorCodes then
                    rankName = CM.utils.StripColorCodes(rankName)
                end

                table.insert(rows, {
                    "**" .. (guild.name or "Unknown") .. "**",
                    rankName,
                    guild.memberCount and FormatNumber(guild.memberCount) or "0",
                    allianceText,
                })
            end

            local options = {
                alignment = { "left", "left", "right", "left" },
                coloredHeaders = true,
            }
            markdown = markdown .. CreateStyledTable(headers, rows, options)
        else
            -- Fallback to markdown table
            markdown = markdown .. "| Guild Name | Rank | Members | Alliance |\n"
            markdown = markdown .. "|:-----------|:-----|:--------|:---------|\n"

            local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink
            for _, guild in ipairs(guildsList) do
                local allianceName = "Unknown"
                if guild.alliance then
                    if type(guild.alliance) == "table" then
                        allianceName = guild.alliance.name or "Unknown"
                    else
                        allianceName = guild.alliance
                    end
                end

                local allianceText = allianceName
                if allianceName ~= "Cross-Alliance" and allianceName ~= "Unknown" and allianceName ~= "" then
                    allianceText = (CreateAllianceLink and CreateAllianceLink(allianceName)) or allianceName
                end

                local rankName = guild.rankName or guild.rank or "Member"
                if CM.utils and CM.utils.StripColorCodes then
                    rankName = CM.utils.StripColorCodes(rankName)
                end

                markdown = markdown .. "| **" .. (guild.name or "Unknown") .. "** | "
                markdown = markdown .. rankName .. " | "
                markdown = markdown .. (guild.memberCount and FormatNumber(guild.memberCount) or "0") .. " | "
                markdown = markdown .. allianceText .. " |\n"
            end
            markdown = markdown .. "\n"
        end
    end

    -- Add Undaunted Active Pledges as subsection
    if
        undauntedPledgesData
        and undauntedPledgesData.pledges
        and undauntedPledgesData.pledges.active
        and #undauntedPledgesData.pledges.active > 0
    then
        markdown = markdown .. GenerateUndauntedActivePledges(undauntedPledgesData)
    end

    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateGuilds = GenerateGuilds

return {
    GenerateGuilds = GenerateGuilds,
}
