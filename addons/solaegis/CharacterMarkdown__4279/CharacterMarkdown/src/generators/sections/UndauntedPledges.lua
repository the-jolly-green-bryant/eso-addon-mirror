-- CharacterMarkdown - Undaunted Pledges Section Generator
-- Generates Undaunted pledges, dungeon progress, and keys markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateProgressBar, GenerateAnchor

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
    end
end

-- =====================================================
-- UNDAUNTED PLEDGES
-- =====================================================

local function GenerateUndauntedPledges(pledgesData)
    InitializeUtilities()

    local markdown = ""

    if not pledgesData or not pledgesData.pledges then
        return "" -- No Undaunted data available
    end

    local pledges = pledgesData.pledges or {}
    local dungeonProgress = pledgesData.dungeonProgress or {}
    local keys = pledgesData.keys or {}

    local anchorId = GenerateAnchor and GenerateAnchor("🏰 Undaunted Pledges") or "undaunted-pledges"
    markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
    markdown = markdown .. "## 🏰 Undaunted Pledges\n\n" -- Changed from 🏛️ for better compatibility

    -- Show active pledges from quest journal
        local hasActivePledges = pledges.active and #pledges.active > 0
        if hasActivePledges then
            markdown = markdown .. "### 📋 Active Pledges\n\n"
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
        end

        -- Pledges summary (daily/weekly)
        local hasDaily = pledges.daily and ((#pledges.daily.normal or 0) + (#pledges.daily.veteran or 0)) > 0
        local hasWeekly = pledges.weekly and ((#pledges.weekly.normal or 0) + (#pledges.weekly.veteran or 0)) > 0

        if hasDaily or hasWeekly then
            markdown = markdown .. "| Type | Available | Keys |\n"
            markdown = markdown .. "|:-----|:----------|:-----|\n"

            if hasDaily then
                local dailyTotal = (#pledges.daily.normal or 0) + (#pledges.daily.veteran or 0)
                markdown = markdown .. "| **Daily** | " .. dailyTotal .. " | " .. (pledges.daily.keys or 0) .. " |\n"
            end

            if hasWeekly then
                local weeklyTotal = (#pledges.weekly.normal or 0) + (#pledges.weekly.veteran or 0)
                markdown = markdown .. "| **Weekly** | " .. weeklyTotal .. " | " .. (pledges.weekly.keys or 0) .. " |\n"
            end

            markdown = markdown .. "\n"
        end

        -- Only show "No pledges available" if there are no active pledges AND no daily/weekly pledges
        if not hasActivePledges and not hasDaily and not hasWeekly then
            markdown = markdown .. "*No pledges available*\n\n"
        end

        -- Progress section
        if pledges.progress and pledges.progress.totalAvailable > 0 then
            local percent = math.floor((pledges.progress.totalCompleted / pledges.progress.totalAvailable) * 100)
            local progressBar = GenerateProgressBar(percent, 20)
            markdown = markdown .. "### 📊 Progress\n\n"
            markdown = markdown
                .. "| Completed | "
                .. progressBar
                .. " "
                .. percent
                .. "% ("
                .. pledges.progress.totalCompleted
                .. "/"
                .. pledges.progress.totalAvailable
                .. ") |\n\n"
        end

        -- Dungeon progress section
        if dungeonProgress and (dungeonProgress.normal.total > 0 or dungeonProgress.veteran.total > 0) then
            markdown = markdown .. "### 🏰 Dungeon Progress\n\n"
            markdown = markdown .. "| Difficulty | Completed | Total | Progress |\n"
            markdown = markdown .. "|:-----------|:----------|:------|:--------|\n"

            if dungeonProgress.normal.total > 0 then
                local normalPercent =
                    math.floor((dungeonProgress.normal.completed / dungeonProgress.normal.total) * 100)
                local normalProgressBar = GenerateProgressBar(normalPercent, 20)
                markdown = markdown
                    .. "| **Normal** | "
                    .. dungeonProgress.normal.completed
                    .. " | "
                    .. dungeonProgress.normal.total
                    .. " | "
                    .. normalProgressBar
                    .. " "
                    .. normalPercent
                    .. "% |\n"
            end

            if dungeonProgress.veteran.total > 0 then
                local veteranPercent =
                    math.floor((dungeonProgress.veteran.completed / dungeonProgress.veteran.total) * 100)
                local veteranProgressBar = GenerateProgressBar(veteranPercent, 20)
                markdown = markdown
                    .. "| **Veteran** | "
                    .. dungeonProgress.veteran.completed
                    .. " | "
                    .. dungeonProgress.veteran.total
                    .. " | "
                    .. veteranProgressBar
                    .. " "
                    .. veteranPercent
                    .. "% |\n"
            end

            if dungeonProgress.hardmode and dungeonProgress.hardmode.total > 0 then
                local hardmodePercent =
                    math.floor((dungeonProgress.hardmode.completed / dungeonProgress.hardmode.total) * 100)
                local hardmodeProgressBar = GenerateProgressBar(hardmodePercent, 20)
                markdown = markdown
                    .. "| **Hardmode** | "
                    .. dungeonProgress.hardmode.completed
                    .. " | "
                    .. dungeonProgress.hardmode.total
                    .. " | "
                    .. hardmodeProgressBar
                    .. " "
                    .. hardmodePercent
                    .. "% |\n"
            end

            markdown = markdown .. "\n"
        end

        -- Keys section
        if keys and keys.total > 0 then
            markdown = markdown .. "### 🔑 Undaunted Keys\n\n"
            if keys.categories then
                for categoryName, categoryData in pairs(keys.categories) do
                    if categoryData.total > 0 then
                        markdown = markdown .. "#### " .. categoryName .. "\n\n"
                        if categoryData.keys and #categoryData.keys > 0 then
                            for _, key in ipairs(categoryData.keys) do
                                if key.count > 0 then
                                    markdown = markdown .. "- " .. key.name .. ": " .. key.count .. "\n"
                                end
                            end
                        end
                        markdown = markdown .. "\n"
                    end
                end
            end
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
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateUndauntedPledges = GenerateUndauntedPledges

return {
    GenerateUndauntedPledges = GenerateUndauntedPledges,
}
