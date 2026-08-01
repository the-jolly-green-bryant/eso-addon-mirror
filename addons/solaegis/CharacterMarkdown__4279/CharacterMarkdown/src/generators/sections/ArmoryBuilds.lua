-- CharacterMarkdown - Armory Builds Section Generator
-- Generates armory builds markdown sections

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
-- HELPER FUNCTIONS
-- =====================================================

-- Format attributes for display
local function FormatAttributes(attributes)
    if not attributes or (not attributes.health and not attributes.magicka and not attributes.stamina) then
        return "Not configured"
    end

    local parts = {}
    if (attributes.health or 0) > 0 then
        table.insert(parts, attributes.health .. " Health")
    end
    if (attributes.magicka or 0) > 0 then
        table.insert(parts, attributes.magicka .. " Magicka")
    end
    if (attributes.stamina or 0) > 0 then
        table.insert(parts, attributes.stamina .. " Stamina")
    end

    return table.concat(parts, ", ")
end

-- Format champion points for display
local function FormatChampionPoints(champion)
    if not champion or not champion.total or champion.total == 0 then
        return "Not configured"
    end

    local parts = {}
    if (champion.craft or 0) > 0 then
        table.insert(parts, champion.craft .. " Craft")
    end
    if (champion.warfare or 0) > 0 then
        table.insert(parts, champion.warfare .. " Warfare")
    end
    if (champion.fitness or 0) > 0 then
        table.insert(parts, champion.fitness .. " Fitness")
    end

    return champion.total .. " total (" .. table.concat(parts, ", ") .. ")"
end

-- Format mundus stones for display
local function FormatMundusStones(mundus)
    if not mundus or (not mundus.primary and not mundus.secondary) then
        return "None"
    end

    local parts = {}
    if mundus.primary then
        table.insert(parts, mundus.primary)
    end
    if mundus.secondary then
        table.insert(parts, mundus.secondary .. " (Secondary)")
    end

    return table.concat(parts, ", ")
end

-- =====================================================

-- =====================================================
-- STANDARD FORMAT
-- =====================================================

local function GenerateArmoryBuildsStandard(armory)
    local markdown = ""

    local anchorId = GenerateAnchor and GenerateAnchor("🏰 Armory Builds") or "armory-builds"
    markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
    markdown = markdown .. "## 🏰 Armory Builds\n\n"

    markdown = markdown .. "**Unlocked Slots:** " .. (armory.unlocked or 0) .. "\n\n"

    if not armory.builds or #armory.builds == 0 then
        markdown = markdown .. "*No builds configured*\n\n---\n\n"
        return markdown
    end

    -- Display each build with details
    for i, build in ipairs(armory.builds) do
        if i > 1 then
            markdown = markdown .. "\n"
        end

        markdown = markdown .. "### " .. build.name .. "\n\n"

        -- Build info table
        markdown = markdown .. "| Property | Value |\n"
        markdown = markdown .. "|:---------|:------|\n"

        -- Skill Points
        if (build.skillPoints or 0) > 0 then
            markdown = markdown .. "| **Skill Points** | " .. FormatNumber(build.skillPoints) .. " |\n"
        end

        -- Attributes
        markdown = markdown .. "| **Attributes** | " .. FormatAttributes(build.attributes) .. " |\n"

        -- Champion Points
        markdown = markdown .. "| **Champion Points** | " .. FormatChampionPoints(build.champion) .. " |\n"

        -- Mundus Stones
        markdown = markdown .. "| **Mundus Stones** | " .. FormatMundusStones(build.mundus) .. " |\n"

        -- Curse
        if build.curse then
            markdown = markdown .. "| **Curse** | " .. build.curse .. " |\n"
        end

        -- Outfit
        if (build.outfitIndex or 0) > 0 then
            markdown = markdown .. "| **Outfit Index** | " .. build.outfitIndex .. " |\n"
        end

        markdown = markdown .. "\n"

        -- Equipment
        if build.equipment and #build.equipment > 0 then
            markdown = markdown .. "#### Equipment (" .. #build.equipment .. " items)\n\n"
            markdown = markdown .. "| Slot | Item |\n"
            markdown = markdown .. "|:-----|:-----|\n"

            for _, item in ipairs(build.equipment) do
                local slotName = "Slot " .. item.slot
                -- Map slot IDs to names
                if item.slot == 0 then
                    slotName = "Head"
                elseif item.slot == 1 then
                    slotName = "Neck"
                elseif item.slot == 2 then
                    slotName = "Chest"
                elseif item.slot == 3 then
                    slotName = "Shoulders"
                elseif item.slot == 4 then
                    slotName = "Main Hand"
                elseif item.slot == 5 then
                    slotName = "Off Hand"
                elseif item.slot == 6 then
                    slotName = "Waist"
                elseif item.slot == 7 then
                    slotName = "Legs"
                elseif item.slot == 8 then
                    slotName = "Feet"
                elseif item.slot == 11 then
                    slotName = "Ring 1"
                elseif item.slot == 12 then
                    slotName = "Ring 2"
                elseif item.slot == 13 then
                    slotName = "Hands"
                elseif item.slot == 20 then
                    slotName = "Backup Main"
                elseif item.slot == 21 then
                    slotName = "Backup Off"
                end

                markdown = markdown .. "| " .. slotName .. " | " .. item.name .. " |\n"
            end

            markdown = markdown .. "\n"
        end

        -- Hotbars
        if build.hotbars and #build.hotbars > 0 then
            for _, hotbar in ipairs(build.hotbars) do
                local barName = hotbar.category == 1 and "Primary Bar" or "Backup Bar"
                markdown = markdown .. "#### " .. barName .. " (" .. #hotbar.abilities .. " abilities)\n\n"

                if #hotbar.abilities > 0 then
                    for _, ability in ipairs(hotbar.abilities) do
                        markdown = markdown .. "- " .. ability.name .. "\n"
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
-- MAIN GENERATOR
-- =====================================================

local function GenerateArmoryBuilds(armoryData)
    InitializeUtilities()

    if not armoryData or not armoryData.armory then
        -- Show placeholder when enabled but no data available
        if true then
            local anchorId = GenerateAnchor and GenerateAnchor("🏰 Armory Builds") or "armory-builds"
            return string.format(
                '<a id="%s"></a>\n\n## 🏰 Armory Builds\n\n*No armory data available*\n\n---\n\n',
                anchorId
            )
        end
        return ""
    end

    local armory = armoryData.armory

    if false then
        -- Discord logic removed
        return ""
    else
        return GenerateArmoryBuildsStandard(armory)
    end
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateArmoryBuilds = GenerateArmoryBuilds

return {
    GenerateArmoryBuilds = GenerateArmoryBuilds,
}
