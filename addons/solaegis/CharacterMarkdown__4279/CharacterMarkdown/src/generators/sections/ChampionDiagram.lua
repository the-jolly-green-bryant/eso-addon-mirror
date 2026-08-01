-- CharacterMarkdown - Champion Points Mermaid Diagram Generator
-- Generates personalized CP diagrams showing invested stars with prerequisite relationships

local CM = CharacterMarkdown
local string_format = string.format
local table_insert = table.insert
local table_concat = table.concat

-- =====================================================
-- STAR MAPPING
-- =====================================================
-- Map skill names to their tree positions and types

local STAR_MAP = {
    -- CRAFT CONSTELLATION
    ["Friends in Low Places"] = { tree = "Craft", type = "slottable", prerequisites = {} },
    ["Discipline Artisan"] = { tree = "Craft", type = "passive", prerequisites = {} },
    ["Fade Away"] = {
        tree = "Craft",
        type = "slottable",
        prerequisites = { "Cutpurse's Art", "Meticulous Disassembly" },
    },
    ["Out of Sight"] = { tree = "Craft", type = "passive", prerequisites = { "Friends in Low Places" } },
    ["Shadowstrike"] = { tree = "Craft", type = "slottable", prerequisites = { "Infamous" } },
    ["Cutpurse's Art"] = { tree = "Craft", type = "passive", prerequisites = { "Shadowstrike" } },
    ["Master Gatherer"] = {
        tree = "Craft",
        type = "slottable",
        prerequisites = { "Treasure Hunter", "Fade Away", "Meticulous Disassembly" },
    },
    ["Treasure Hunter"] = {
        tree = "Craft",
        type = "passive",
        prerequisites = { "Meticulous Disassembly", "Steadfast Enchantment" },
    },
    ["Angler's Instincts"] = { tree = "Craft", type = "slottable", prerequisites = { "Liquid Efficiency" } },
    ["Steadfast Enchantment"] = { tree = "Craft", type = "passive", prerequisites = { "Wanderer" } },
    ["Reel Technique"] = { tree = "Craft", type = "slottable", prerequisites = { "Angler's Instincts" } },
    ["Rationer"] = { tree = "Craft", type = "passive", prerequisites = { "Steadfast Enchantment" } },
    ["War Mount"] = { tree = "Craft", type = "slottable", prerequisites = { "Gifted Rider", "Plentiful Harvest" } },
    ["Liquid Efficiency"] = { tree = "Craft", type = "passive", prerequisites = { "Rationer" } },
    ["Gifted Rider"] = { tree = "Craft", type = "slottable", prerequisites = { "Master Gatherer" } },
    ["Homemaker"] = { tree = "Craft", type = "passive", prerequisites = { "Reel Technique" } },
    ["Steed's Blessing"] = { tree = "Craft", type = "slottable", prerequisites = {} },
    ["Wanderer"] = { tree = "Craft", type = "passive", prerequisites = { "Fortune's Favor" } },
    ["Sustaining Shadows"] = { tree = "Craft", type = "slottable", prerequisites = {} },
    ["Plentiful Harvest"] = { tree = "Craft", type = "passive", prerequisites = { "Master Gatherer" } },
    ["Meticulous Disassembly"] = { tree = "Craft", type = "passive", prerequisites = { "Inspiration Boost" } },
    ["Inspiration Boost"] = { tree = "Craft", type = "passive", prerequisites = { "Fortune's Favor" } },
    ["Fortune's Favor"] = { tree = "Craft", type = "passive", prerequisites = { "Gilded Fingers" } },
    ["Infamous"] = { tree = "Craft", type = "passive", prerequisites = { "Fleet Phantom" } },
    ["Fleet Phantom"] = { tree = "Craft", type = "passive", prerequisites = { "Friends in Low Places" } },
    ["Gilded Fingers"] = { tree = "Craft", type = "passive", prerequisites = {} },
    ["Breakfall"] = { tree = "Craft", type = "passive", prerequisites = { "Wanderer" } },
    ["Soul Reservoir"] = { tree = "Craft", type = "passive", prerequisites = { "Breakfall" } },
    ["Professional Upkeep"] = { tree = "Craft", type = "passive", prerequisites = {} },

    -- WARFARE CONSTELLATION
    ["Fighting Finesse"] = { tree = "Warfare", type = "slottable", prerequisites = { "Precision" } },
    ["From the Brink"] = { tree = "Warfare", type = "slottable", prerequisites = { "Blessed" } },
    ["Enlivening Overflow"] = { tree = "Warfare", type = "slottable", prerequisites = { "Blessed" } },
    ["Hope Infusion"] = { tree = "Warfare", type = "slottable", prerequisites = { "Blessed" } },
    ["Salve of Renewal"] = { tree = "Warfare", type = "slottable", prerequisites = { "Blessed" } },
    ["Soothing Tide"] = { tree = "Warfare", type = "slottable", prerequisites = { "Blessed" } },
    ["Rejuvenator"] = { tree = "Warfare", type = "slottable", prerequisites = { "Soothing Tide" } },
    ["Foresight"] = { tree = "Warfare", type = "slottable", prerequisites = {} },
    ["Cleansing Revival"] = { tree = "Warfare", type = "slottable", prerequisites = { "Focused Mending" } },
    ["Focused Mending"] = { tree = "Warfare", type = "slottable", prerequisites = { "Blessed" } },
    ["Swift Renewal"] = { tree = "Warfare", type = "slottable", prerequisites = { "Blessed" } },
    ["Exploiter"] = { tree = "Warfare", type = "slottable", prerequisites = { "Piercing" } },
    ["Force of Nature"] = { tree = "Warfare", type = "slottable", prerequisites = { "Piercing" } },
    ["Master-at-Arms"] = { tree = "Warfare", type = "slottable", prerequisites = { "Piercing" } },
    ["Weapons Expert"] = { tree = "Warfare", type = "slottable", prerequisites = { "Piercing" } },
    ["Deadly Aim"] = { tree = "Warfare", type = "slottable", prerequisites = { "Piercing" } },
    ["Biting Aura"] = { tree = "Warfare", type = "slottable", prerequisites = { "Piercing" } },
    ["Thaumaturge"] = { tree = "Warfare", type = "slottable", prerequisites = { "Piercing" } },
    ["Reaving Blows"] = { tree = "Warfare", type = "slottable", prerequisites = { "Precision" } },
    ["Wrathful Strikes"] = { tree = "Warfare", type = "slottable", prerequisites = { "Precision" } },
    ["Occult Overload"] = { tree = "Warfare", type = "slottable", prerequisites = { "Precision" } },
    ["Backstabber"] = { tree = "Warfare", type = "slottable", prerequisites = { "Precision" } },
    ["Ironclad"] = { tree = "Warfare", type = "slottable", prerequisites = { "Quick Recovery" } },
    ["Resilience"] = { tree = "Warfare", type = "slottable", prerequisites = { "Quick Recovery" } },
    ["Enduring Resolve"] = { tree = "Warfare", type = "slottable", prerequisites = { "Quick Recovery" } },
    ["Reinforced"] = { tree = "Warfare", type = "slottable", prerequisites = { "Riposte", "Bulwark" } },
    ["Riposte"] = { tree = "Warfare", type = "slottable", prerequisites = { "Duelist's Rebuff" } },
    ["Bulwark"] = { tree = "Warfare", type = "slottable", prerequisites = { "Unassailable" } },
    ["Last Stand"] = {
        tree = "Warfare",
        type = "slottable",
        prerequisites = { "Riposte", "Reinforced", "Cutting Defense" },
    },
    ["Cutting Defense"] = { tree = "Warfare", type = "slottable", prerequisites = { "Riposte", "Reinforced" } },
    ["Precision"] = { tree = "Warfare", type = "passive", prerequisites = {} },
    ["Blessed"] = { tree = "Warfare", type = "passive", prerequisites = { "Precision", "Eldritch Insight" } },
    ["Piercing"] = {
        tree = "Warfare",
        type = "passive",
        prerequisites = { "Precision", "Eldritch Insight", "Tireless Discipline" },
    },
    ["Flawless Ritual"] = { tree = "Warfare", type = "passive", prerequisites = { "Piercing" } },
    ["War Mage"] = { tree = "Warfare", type = "passive", prerequisites = { "Flawless Ritual" } },
    ["Battle Mastery"] = { tree = "Warfare", type = "passive", prerequisites = { "Piercing" } },
    ["Mighty"] = { tree = "Warfare", type = "passive", prerequisites = { "Battle Mastery" } },
    ["Tireless Discipline"] = { tree = "Warfare", type = "passive", prerequisites = {} },
    ["Quick Recovery"] = { tree = "Warfare", type = "passive", prerequisites = { "Eldritch Insight" } },
    ["Preparation"] = { tree = "Warfare", type = "passive", prerequisites = { "Quick Recovery" } },
    ["Elemental Aegis"] = { tree = "Warfare", type = "passive", prerequisites = { "Preparation" } },
    ["Hardy"] = { tree = "Warfare", type = "passive", prerequisites = { "Preparation" } },
    ["Eldritch Insight"] = { tree = "Warfare", type = "passive", prerequisites = {} },
    ["Duelist's Rebuff"] = { tree = "Warfare", type = "slottable", prerequisites = { "Eldritch Insight" } },
    ["Unassailable"] = { tree = "Warfare", type = "slottable", prerequisites = { "Quick Recovery" } },
    ["Endless Endurance"] = { tree = "Warfare", type = "slottable", prerequisites = {} },
    ["Untamed Aggression"] = { tree = "Warfare", type = "slottable", prerequisites = {} },
    ["Arcane Supremacy"] = { tree = "Warfare", type = "slottable", prerequisites = {} },

    -- FITNESS CONSTELLATION
    ["Thrill of the Hunt"] = { tree = "Fitness", type = "slottable", prerequisites = { "Hasty" } },
    ["Celerity"] = { tree = "Fitness", type = "slottable", prerequisites = { "Hasty" } },
    ["Refreshing Stride"] = { tree = "Fitness", type = "slottable", prerequisites = { "Hasty" } },
    ["Shield Master"] = { tree = "Fitness", type = "slottable", prerequisites = { "Hero's Vigor" } },
    ["Bastion"] = { tree = "Fitness", type = "slottable", prerequisites = { "Shield Master" } },
    ["Survival Instincts"] = { tree = "Fitness", type = "slottable", prerequisites = { "Mystic Tenacity" } },
    ["Spirit Mastery"] = { tree = "Fitness", type = "slottable", prerequisites = { "Tempered Soul" } },
    ["Arcane Alacrity"] = { tree = "Fitness", type = "slottable", prerequisites = { "Bastion" } },
    ["Bloody Renewal"] = { tree = "Fitness", type = "slottable", prerequisites = { "Hero's Vigor" } },
    ["Strategic Reserve"] = { tree = "Fitness", type = "slottable", prerequisites = { "Hero's Vigor" } },
    ["Sustained by Suffering"] = { tree = "Fitness", type = "slottable", prerequisites = { "Mystic Tenacity" } },
    ["Pain's Refuge"] = { tree = "Fitness", type = "slottable", prerequisites = { "Mystic Tenacity" } },
    ["Relentlessness"] = { tree = "Fitness", type = "slottable", prerequisites = { "Mystic Tenacity" } },
    ["Siphoning Spells"] = { tree = "Fitness", type = "slottable", prerequisites = { "Hero's Vigor" } },
    ["Rousing Speed"] = { tree = "Fitness", type = "slottable", prerequisites = { "Sprinter" } },
    ["Soothing Shield"] = { tree = "Fitness", type = "slottable", prerequisites = { "Nimble Protector" } },
    ["Bracing Anchor"] = { tree = "Fitness", type = "slottable", prerequisites = { "Nimble Protector" } },
    ["Ward Master"] = { tree = "Fitness", type = "slottable", prerequisites = { "Nimble Protector" } },
    ["On Guard"] = { tree = "Fitness", type = "slottable", prerequisites = { "Tireless Guardian" } },
    ["Expert Evasion"] = { tree = "Fitness", type = "slottable", prerequisites = { "Tumbling" } },
    ["Slippery"] = { tree = "Fitness", type = "slottable", prerequisites = { "Defiance" } },
    ["Unchained"] = { tree = "Fitness", type = "slottable", prerequisites = { "Slippery" } },
    ["Juggernaut"] = { tree = "Fitness", type = "slottable", prerequisites = { "Defiance" } },
    ["Peace of Mind"] = { tree = "Fitness", type = "slottable", prerequisites = { "Defiance" } },
    ["Hardened"] = { tree = "Fitness", type = "slottable", prerequisites = { "Defiance" } },
    ["Rejuvenation"] = { tree = "Fitness", type = "slottable", prerequisites = {} },
    ["Fortified"] = { tree = "Fitness", type = "slottable", prerequisites = {} },
    ["Boundless Vitality"] = { tree = "Fitness", type = "slottable", prerequisites = {} },
    ["Sprinter"] = { tree = "Fitness", type = "passive", prerequisites = {} },
    ["Hasty"] = { tree = "Fitness", type = "passive", prerequisites = { "Sprinter", "Hero's Vigor" } },
    ["Hero's Vigor"] = { tree = "Fitness", type = "passive", prerequisites = { "Mystic Tenacity" } },
    ["Tempered Soul"] = {
        tree = "Fitness",
        type = "passive",
        prerequisites = { "Piercing Gaze", "Survival Instincts" },
    },
    ["Piercing Gaze"] = { tree = "Fitness", type = "passive", prerequisites = { "Hero's Vigor" } },
    ["Mystic Tenacity"] = { tree = "Fitness", type = "passive", prerequisites = { "Hero's Vigor", "Tumbling" } },
    ["Tireless Guardian"] = { tree = "Fitness", type = "passive", prerequisites = { "Hasty" } },
    ["Savage Defense"] = { tree = "Fitness", type = "passive", prerequisites = { "Tireless Guardian" } },
    ["Bashing Brutality"] = { tree = "Fitness", type = "passive", prerequisites = { "Tireless Guardian" } },
    ["Nimble Protector"] = { tree = "Fitness", type = "passive", prerequisites = { "Tireless Guardian" } },
    ["Fortification"] = { tree = "Fitness", type = "passive", prerequisites = { "Tireless Guardian" } },
    ["Tumbling"] = { tree = "Fitness", type = "passive", prerequisites = {} },
    ["Defiance"] = { tree = "Fitness", type = "passive", prerequisites = {} },
}

-- =====================================================
-- HELPER: Get color intensity based on points
-- =====================================================
local function GetColorIntensity(points)
    if points >= 50 then
        return "high" -- Maxed or near-max
    elseif points >= 30 then
        return "medium-high"
    elseif points >= 15 then
        return "medium"
    else
        return "low"
    end
end

-- =====================================================
-- HELPER: Get visual point indicator
-- =====================================================
local function GetPointIndicator(points, maxPoints)
    maxPoints = maxPoints or 50
    local percentage = (points / maxPoints) * 100

    if percentage >= 100 then
        return "⭐" -- Maxed
    elseif percentage >= 75 then
        return "●●●" -- High
    elseif percentage >= 50 then
        return "●●○" -- Medium-High
    elseif percentage >= 25 then
        return "●○○" -- Medium
    else
        return "○○○" -- Low
    end
end

-- =====================================================
-- HELPER: Determine max points for a star
-- =====================================================
local function GetMaxPoints(skillName)
    -- Common max values based on star names
    local maxMap = {
        ["Master Gatherer"] = 75,
        ["Boundless Vitality"] = 50,
        ["Rejuvenation"] = 50,
        ["War Mount"] = 120,
        ["Gifted Rider"] = 100,
        ["Wanderer"] = 100,
        ["Salvation"] = 75,
        ["Bloody Renewal"] = 75,
        ["Unassailable"] = 75,
        ["Deadly Precision"] = 75,
        ["Rationer"] = 75,
    }
    return maxMap[skillName] or 50 -- Default to 50
end

-- =====================================================
-- HELPER: Sanitize mermaid node labels
-- =====================================================
local function SanitizeMermaidLabel(text)
    if not text or text == "" then
        return ""
    end
    local sanitized = text
    sanitized = sanitized:gsub("\\", "\\\\")
    sanitized = sanitized:gsub('"', '\\"')
    sanitized = sanitized:gsub("%[", "\\[")
    sanitized = sanitized:gsub("%]", "\\]")
    return sanitized
end

-- =====================================================
-- HELPER: Generate node definition
-- =====================================================
local function GenerateNode(skill, starData)
    local nodeId = starData.node
    local skillName = SanitizeMermaidLabel(skill.name)
    local points = skill.points

    -- Node shape based on type
    local prefix, suffix
    if starData.type == "slottable" then
        prefix = "[["
        suffix = "]]"
    elseif starData.type == "base" then
        prefix = "("
        suffix = ")"
    else -- passive
        prefix = "("
        suffix = ")"
    end

    -- Build node label with points
    local label = string.format("%s%s<br/>%d pts%s", prefix, skillName, points, suffix)

    return string.format("    %s%s", nodeId, label)
end

-- =====================================================
-- HELPER: Get tree color with complementary pale palette
-- =====================================================
local function GetTreeColor(tree, intensity)
    -- Complementary color scheme with pale, harmonious backgrounds
    -- Craft: Soft sage/teal greens (complementary to coral)
    -- Warfare: Soft periwinkle/lavender blues (complementary to peach)
    -- Fitness: Soft coral/peach (complementary to teal)
    local colors = {
        Craft = {
            high = "#7fb3a8", -- Soft teal (maxed) - deeper but still pale
            ["medium-high"] = "#9fc5bb", -- Medium teal
            medium = "#b8d4cc", -- Light teal
            low = "#d4e8e1", -- Very pale sage green
        },
        Warfare = {
            high = "#8b9dc3", -- Soft periwinkle (maxed) - deeper but still pale
            ["medium-high"] = "#a5b3d1", -- Medium periwinkle
            medium = "#bfc9df", -- Light periwinkle
            low = "#d9dfed", -- Very pale lavender blue
        },
        Fitness = {
            high = "#d4a5a5", -- Soft coral (maxed) - deeper but still pale
            ["medium-high"] = "#e0b8b8", -- Medium coral
            medium = "#eccbcb", -- Light coral
            low = "#f8dede", -- Very pale peach
        },
    }

    return colors[tree] and colors[tree][intensity] or "#e8e8e8" -- Neutral pale gray fallback
end

-- =====================================================
-- HELPER: Get strong node color (for individual stars)
-- =====================================================
local function GetStrongNodeColor(tree)
    -- Stronger, more saturated colors for individual nodes
    local strongColors = {
        Craft = "#4a9d7f", -- Strong teal/green
        Warfare = "#5b7fb8", -- Strong periwinkle/blue
        Fitness = "#b87a7a", -- Strong coral/rose
    }

    return strongColors[tree] or "#888888" -- Neutral gray fallback
end

-- =====================================================
-- HELPER: Get subgraph background color
-- =====================================================
local function GetSubgraphBackgroundColor(tree)
    -- Transparent backgrounds for subgraph containers
    -- This allows the diagram to blend with any background (GitHub, VS Code, Discord, etc.)
    return "transparent"
end

-- =====================================================
-- HELPER: Get enhanced node shape based on points and star type
-- =====================================================
local function GetNodeShape(starData, points, maxPoints)
    maxPoints = maxPoints or 50 -- Default to 50 if not provided
    local isMaxed = points >= maxPoints

    -- Shape is determined by star type to ensure consistency
    -- Slottables: squares, Passives: circles, Base: hexagons
    if starData.type == "slottable" then
        if isMaxed then
            return "[[", "]]" -- Maxed slottable - double square brackets
        else
            return "[", "]" -- Partial slottable - single square brackets
        end
    elseif starData.type == "base" then
        return "{", "}" -- Base stars - hexagon (curly braces)
    else
        -- Passive stars - always use circles for consistency
        return "(", ")" -- Passive (maxed or partial) - circle (parentheses)
    end
end

-- =====================================================
-- MAIN: Generate Champion Points Diagram
-- =====================================================
local function GenerateChampionDiagram(cpData)
    CM.DebugPrint("CHAMPION_DIAGRAM", "GenerateChampionDiagram called")
    if not cpData or not cpData.disciplines or #cpData.disciplines == 0 then
        CM.DebugPrint("CHAMPION_DIAGRAM", "No CP data or disciplines, returning empty")
        return ""
    end

    CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Processing %d disciplines", #cpData.disciplines))
    local markdown = "### 🎯 Champion Points Visual\n\n"

    -- Organize skills by tree and type
    local treeSkills = {
        Craft = { slottable = {}, passive = {}, all = {} },
        Warfare = { slottable = {}, passive = {}, all = {} },
        Fitness = { slottable = {}, passive = {}, all = {} },
    }

    -- Track total points per constellation (564 max per constellation)
    local treePoints = {
        Craft = 0,
        Warfare = 0,
        Fitness = 0,
    }

    -- Map skills to trees and organize by type
    for _, discipline in ipairs(cpData.disciplines) do
        CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Processing discipline: %s", discipline.name or "Unknown"))
        -- Check allStars first (most complete), then fall back to slottableSkills + passiveSkills
        local skillsToProcess = {}
        if discipline.allStars and #discipline.allStars > 0 then
            CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Using allStars: %d skills", #discipline.allStars))
            skillsToProcess = discipline.allStars
        elseif discipline.slottableSkills or discipline.passiveSkills then
            -- Combine slottable and passive skills
            if discipline.slottableSkills then
                CM.DebugPrint(
                    "CHAMPION_DIAGRAM",
                    string.format("Adding %d slottable skills", #discipline.slottableSkills)
                )
                for _, skill in ipairs(discipline.slottableSkills) do
                    table.insert(skillsToProcess, skill)
                end
            end
            if discipline.passiveSkills then
                CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Adding %d passive skills", #discipline.passiveSkills))
                for _, skill in ipairs(discipline.passiveSkills) do
                    table.insert(skillsToProcess, skill)
                end
            end
        else
            CM.DebugPrint("CHAMPION_DIAGRAM", "No skills found in discipline")
        end

        for _, skill in ipairs(skillsToProcess) do
            -- Only include skills with points invested (for diagram clarity)
            local points = skill.points or 0
            if points > 0 then
                local starData = STAR_MAP[skill.name]
                if not starData then
                    -- Fallback for unmapped stars
                    CM.DebugPrint("CP", string_format("Star '%s' not in STAR_MAP, using default mapping", skill.name))
                    starData = {
                        tree = discipline.name, -- Use discipline name as fallback
                        type = "passive", -- Default to passive
                        node = string.format("%s_%s", discipline.name:sub(1, 1), skill.name:gsub("[^%w]", "")),
                        prerequisites = {},
                    }
                elseif not starData.node then
                    -- Generate node ID if missing in map (using copy to avoid mutating global map)
                    starData = {
                        tree = starData.tree,
                        type = starData.type,
                        prerequisites = starData.prerequisites,
                        node = string.format("%s_%s", starData.tree:sub(1, 1), skill.name:gsub("[^%w]", "")),
                    }
                end

                if starData then
                    local tree = starData.tree
                    if not treeSkills[tree] then
                        treeSkills[tree] = { slottable = {}, passive = {}, base = {} }
                    end

                    -- Categorize by type
                    local category = starData.type
                    if category == "slottable" or category == "passive" then
                        table.insert(treeSkills[tree][category], {
                            skill = skill,
                            starData = starData,
                        })
                        treePoints[tree] = treePoints[tree] + points
                    end
                end
            end
        end
    end

    -- Deduplicate skills by node ID within each category (in case aliases like "Wanderer" and "Gifted Rider" both appear)
    -- Keep the one with more points, or the first one if points are equal
    for treeName, categories in pairs(treeSkills) do
        for categoryName, skills in pairs(categories) do
            local nodeIdMap = {}
            local deduplicated = {}

            for _, entry in ipairs(skills) do
                local nodeId = entry.starData.node
                if not nodeIdMap[nodeId] then
                    -- First occurrence of this node ID
                    nodeIdMap[nodeId] = entry
                    table.insert(deduplicated, entry)
                else
                    -- Duplicate node ID - keep the one with more points
                    local existing = nodeIdMap[nodeId]
                    if entry.skill.points > existing.skill.points then
                        -- Replace with the one that has more points
                        for i, dedupEntry in ipairs(deduplicated) do
                            if dedupEntry.starData.node == nodeId then
                                deduplicated[i] = entry
                                nodeIdMap[nodeId] = entry
                                break
                            end
                        end
                        CM.DebugPrint(
                            "CHAMPION_DIAGRAM",
                            string.format(
                                "Deduplicated node %s: kept %s (%d pts) over %s (%d pts)",
                                nodeId,
                                entry.skill.name,
                                entry.skill.points,
                                existing.skill.name,
                                existing.skill.points
                            )
                        )
                    else
                        CM.DebugPrint(
                            "CHAMPION_DIAGRAM",
                            string.format(
                                "Deduplicated node %s: kept %s (%d pts) over %s (%d pts)",
                                nodeId,
                                existing.skill.name,
                                existing.skill.points,
                                entry.skill.name,
                                entry.skill.points
                            )
                        )
                    end
                end
            end

            -- Sort by points (highest first) for better visual hierarchy
            table.sort(deduplicated, function(a, b)
                return a.skill.points > b.skill.points
            end)

            treeSkills[treeName][categoryName] = deduplicated
        end
    end

    -- Count total skills for diagram
    local totalSkillsInDiagram = 0
    for treeName, categories in pairs(treeSkills) do
        for categoryName, skills in pairs(categories) do
            totalSkillsInDiagram = totalSkillsInDiagram + #skills
            CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Tree %s - %s: %d skills", treeName, categoryName, #skills))
        end
    end

    CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Total skills in diagram: %d", totalSkillsInDiagram))

    if totalSkillsInDiagram == 0 then
        CM.DebugPrint("CHAMPION_DIAGRAM", "No skills with points found, returning empty diagram")
        return markdown .. "*No invested Champion Points to visualize*\n\n"
    end

    -- Generate diagram with table.concat for performance
    local parts = {}

    -- Generate diagram with new cleaner format
    table_insert(parts, "```mermaid\n")
    table_insert(
        parts,
        '%%{init: {"theme":"base", "themeVariables": { "background":"transparent","fontSize":"14px","primaryColor":"#e8f4f0","primaryTextColor":"#000","primaryBorderColor":"#4a9d7f","lineColor":"#999","secondaryColor":"#f0f4f8","tertiaryColor":"#faf0f0"}, "flowchart": {"curve":"basis"}}}%%\n\n'
    )
    table_insert(parts, "flowchart LR\n")
    table_insert(parts, "  %% Champion Point Investment Visualization\n")
    table_insert(parts, "  %% Enhanced readability with clear visual hierarchy\n\n")

    -- Build discipline map for easy lookup
    local disciplineMap = {}
    for _, discipline in ipairs(cpData.disciplines) do
        if discipline.name then
            disciplineMap[discipline.name] = discipline
        end
    end

    -- Generate nodes for each tree
    local treeOrder = { "Craft", "Warfare", "Fitness" } -- Ensure consistent order
    local MAX_POINTS_PER_CONSTELLATION = 564
    local available = cpData.available or 0

    for _, treeName in ipairs(treeOrder) do
        local categories = treeSkills[treeName]
        local discipline = disciplineMap[treeName]

        -- Count skills in this tree
        local skillCount = 0
        for _, skills in pairs(categories) do
            skillCount = skillCount + #skills
        end

        if skillCount > 0 then
            local treeEmoji = {
                Craft = "⚒️",
                Warfare = "⚔️",
                Fitness = "💪",
            }

            local treeIcon = treeEmoji[treeName] or ""
            local pointsInvested = treePoints[treeName]

            table_insert(parts, "  %% ========================================\n")
            table_insert(
                parts,
                string_format(
                    "  %%%% %s %s CONSTELLATION (%d/%d pts)\n",
                    treeIcon,
                    treeName:upper(),
                    pointsInvested,
                    MAX_POINTS_PER_CONSTELLATION
                )
            )
            table_insert(parts, "  %% ========================================\n\n")

            -- Mermaid subgraph with simplified title
            table_insert(
                parts,
                string_format('  subgraph sub%s["%s %s CONSTELLATION"]\n', treeName:upper(), treeIcon, treeName:upper())
            )
            table_insert(parts, "    \n")

            -- Generate nodes for each tree
            for _, entry in ipairs(categories.slottable) do
                table.insert(treeSkills[treeName].all, entry)
            end
            for _, entry in ipairs(categories.passive) do
                table.insert(treeSkills[treeName].all, entry)
            end

            -- Sort all skills by points for consistent rendering order if needed,
            -- but for connections we just need the nodes to exist.

            -- Render all nodes
            for _, entry in ipairs(treeSkills[treeName].all) do
                local skill = entry.skill
                local starData = entry.starData
                local nodeId = starData.node
                local points = skill.points
                local maxPoints = (skill.maxPoints and skill.maxPoints > 0) and skill.maxPoints
                    or GetMaxPoints(skill.name)
                if maxPoints <= 0 then
                    maxPoints = 1
                end
                local indicator = GetPointIndicator(points, maxPoints)
                local percentage = math.floor((points / maxPoints) * 100)
                local isMaxed = points >= maxPoints
                local maxedText = isMaxed and " | MAXED" or string.format(" | %s %d%%", indicator, percentage)

                local label = string.format(
                    "%s%s<br/>%d/%d pts%s",
                    isMaxed and "⭐ " or "",
                    SanitizeMermaidLabel(skill.name),
                    points,
                    maxPoints,
                    maxedText
                )

                table_insert(parts, "    " .. nodeId .. '["' .. label .. '"]\n')

                -- Style the node
                local nodeColor = GetStrongNodeColor(treeName)
                local strokeWidth = "2px"
                local strokeColor = nodeColor

                if starData.type == "slottable" then
                    strokeWidth = isMaxed and "4px" or "3px"
                    strokeColor = isMaxed and "#ffd700" or nodeColor
                end

                table_insert(
                    parts,
                    "    style "
                        .. nodeId
                        .. " fill:"
                        .. nodeColor
                        .. ",stroke:"
                        .. strokeColor
                        .. ",stroke-width:"
                        .. strokeWidth
                        .. ",color:#fff\n"
                )
            end

            -- Render Connections
            table_insert(parts, "\n    %% Connections\n")
            for _, entry in ipairs(treeSkills[treeName].all) do
                local starData = entry.starData
                local nodeId = starData.node

                if starData.prerequisites then
                    for _, prereqName in ipairs(starData.prerequisites) do
                        -- Find the node ID for the prerequisite
                        -- We need to check if the prerequisite is actually in the diagram (has points)
                        -- If it doesn't have points, we might not have rendered it.
                        -- However, logic dictates if a child has points, the parent MUST have points (usually).
                        -- But we only render nodes that are in `treeSkills`.

                        local prereqNodeId = nil
                        -- Search in the current tree's skills
                        for _, pEntry in ipairs(treeSkills[treeName].all) do
                            if pEntry.skill.name == prereqName then
                                prereqNodeId = pEntry.starData.node
                                break
                            end
                        end

                        if prereqNodeId then
                            table_insert(parts, "    " .. prereqNodeId .. " --> " .. nodeId .. "\n")
                        end
                    end
                end
            end

            -- Add available points node
            local disciplineAvailable = discipline and discipline.available or 0
            table_insert(parts, "\n")
            table_insert(
                parts,
                "    " .. treeName:upper() .. '_AVAIL["💎 ' .. disciplineAvailable .. ' points available"]\n'
            )

            -- Style available node
            local availBgColor = {
                Craft = "#d4e8df",
                Warfare = "#d4e4f0",
                Fitness = "#f0d4d4",
            }
            local availBgColorValue = availBgColor[treeName]
            local availTextColor = {
                Craft = "#4a9d7f",
                Warfare = "#5b7fb8",
                Fitness = "#b87a7a",
            }

            table_insert(
                parts,
                "    style "
                    .. treeName:upper()
                    .. "_AVAIL fill:"
                    .. availBgColorValue
                    .. ",stroke:"
                    .. availTextColor[treeName]
                    .. ",stroke-width:2px,stroke-dasharray:5 5,color:"
                    .. availTextColor[treeName]
                    .. "\n\n"
            )

            table_insert(parts, "  end\n")

            -- Add subgraph background styling
            local subgraphBgColor = GetSubgraphBackgroundColor(treeName)
            table_insert(
                parts,
                string_format(
                    "  style sub%s fill:%s,stroke:%s,stroke-width:3px\n\n",
                    treeName:upper(),
                    subgraphBgColor,
                    GetStrongNodeColor(treeName)
                )
            )
        end
    end

    -- Add simplified legend matching the example format (same mermaid block as constellations)
    table_insert(parts, "  %% ========================================\n")
    table_insert(parts, "  %% LEGEND\n")
    table_insert(parts, "  %% ========================================\n\n")

    -- Parent legend subgraph
    table_insert(parts, '  subgraph subLEGEND["📖 LEGEND & VISUAL GUIDE"]\n')
    table_insert(parts, "    \n")

    -- Star Types subsection
    table_insert(parts, '    LEG_STARS["Star Types"]\n')
    table_insert(parts, '    LEG_S1["⭐ Gold Border = Maxed Slottable"]\n')
    table_insert(parts, '    LEG_S2["🔶 Orange Border = Independent Star"]\n')
    table_insert(parts, '    LEG_S3["Standard Border = In Progress"]\n')
    table_insert(parts, "    \n")

    -- Progress Indicators subsection
    table_insert(parts, '    LEG_FILL["Progress Indicators"]\n')
    table_insert(parts, '    LEG_F1["⭐ = 100% Maxed"]\n')
    table_insert(parts, '    LEG_F2["●●● = 75-99%"]\n')
    table_insert(parts, '    LEG_F3["●●○ = 50-74%"]\n')
    table_insert(parts, '    LEG_F4["●○○ = 25-49%"]\n')
    table_insert(parts, '    LEG_F5["○○○ = 1-24%"]\n')
    table_insert(parts, "    \n")

    -- Connections for visual organization
    table_insert(parts, "    LEG_STARS --> LEG_S1 & LEG_S2 & LEG_S3\n")
    table_insert(parts, "    LEG_FILL --> LEG_F1 & LEG_F2 & LEG_F3 & LEG_F4 & LEG_F5\n\n")

    -- Styling for legend elements
    table_insert(parts, "    style LEG_STARS fill:transparent,stroke:none,color:#ccc\n")
    table_insert(parts, "    style LEG_FILL fill:transparent,stroke:none,color:#ccc\n")
    table_insert(parts, "    style LEG_S1 fill:#fff,stroke:#ffd700,stroke-width:3px,color:#333\n")
    table_insert(parts, "    style LEG_S2 fill:#fff,stroke:#ff8c00,stroke-width:3px,color:#333\n")
    table_insert(parts, "    style LEG_S3 fill:#fff,stroke:#999,stroke-width:2px,color:#333\n")
    table_insert(parts, "    style LEG_F1 fill:#eee,stroke:#333,stroke-width:1px,color:#333\n")
    table_insert(parts, "    style LEG_F2 fill:#eee,stroke:#333,stroke-width:1px,color:#333\n")
    table_insert(parts, "    style LEG_F3 fill:#eee,stroke:#333,stroke-width:1px,color:#333\n")
    table_insert(parts, "    style LEG_F4 fill:#eee,stroke:#333,stroke-width:1px,color:#333\n")
    table_insert(parts, "    style LEG_F5 fill:#eee,stroke:#333,stroke-width:1px,color:#333\n")

    -- Close legend subgraph
    table_insert(parts, "  end\n")
    table_insert(parts, "  style subLEGEND fill:transparent,stroke:#999,stroke-width:3px\n")
    table_insert(parts, "```\n\n")

    -- Add separator at the end (as this becomes the end of the CP section)
    local CreateSeparator = CM.utils and CM.utils.markdown and CM.utils.markdown.CreateSeparator
    if CreateSeparator then
        table_insert(parts, CreateSeparator("hr"))
    else
        table_insert(parts, "---\n\n")
    end

    return markdown .. table_concat(parts)
end

CM.generators.sections.GenerateChampionDiagram = GenerateChampionDiagram
