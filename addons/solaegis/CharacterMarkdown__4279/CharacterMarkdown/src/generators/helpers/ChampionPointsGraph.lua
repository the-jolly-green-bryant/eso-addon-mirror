--[[
    ESO Champion Points Graph Data Structures
    Lua 5.1 Compatible
    
    Each discipline contains:
    - nodes: table keyed by star name with node data and adjacency lists
    - getNode(name): returns node by name
    - getNeighbors(name): returns table of connected nodes (prerequisites + dependents)
    - walkPath(from, to): BFS pathfinding between nodes
    - getRoots(): returns nodes with no prerequisites
]]

local ChampionPointsGraph = {}

--------------------------------------------------------------------------------
-- GRAPH UTILITIES
--------------------------------------------------------------------------------

local function createGraph(nodes)
    local graph = {
        nodes = nodes,
        _byId = {},
    }

    -- Build ID index
    for name, node in pairs(nodes) do
        graph._byId[node.id] = node
    end

    -- Build adjacency lists (dependents)
    for name, node in pairs(nodes) do
        node.dependents = {}
    end

    for name, node in pairs(nodes) do
        for _, prereq in ipairs(node.prerequisites) do
            local prereqNode = nodes[prereq.star]
            if prereqNode then
                prereqNode.dependents[#prereqNode.dependents + 1] = {
                    star = name,
                    min_points = prereq.min_points,
                }
            end
        end
    end

    function graph:getNode(name)
        return self.nodes[name]
    end

    function graph:getNodeById(id)
        return self._byId[id]
    end

    function graph:getNeighbors(name)
        local node = self.nodes[name]
        if not node then
            return nil
        end

        local neighbors = {}
        -- Add prerequisites
        for _, prereq in ipairs(node.prerequisites) do
            neighbors[#neighbors + 1] = {
                star = prereq.star,
                direction = "prerequisite",
                min_points = prereq.min_points,
            }
        end
        -- Add dependents
        for _, dep in ipairs(node.dependents) do
            neighbors[#neighbors + 1] = {
                star = dep.star,
                direction = "dependent",
                min_points = dep.min_points,
            }
        end
        return neighbors
    end

    function graph:getRoots()
        local roots = {}
        for name, node in pairs(self.nodes) do
            if #node.prerequisites == 0 then
                roots[#roots + 1] = name
            end
        end
        return roots
    end

    function graph:walkPath(fromName, toName)
        -- BFS pathfinding (ignores point requirements)
        local visited = {}
        local queue = { { name = fromName, path = { fromName } } }
        visited[fromName] = true

        while #queue > 0 do
            local current = table.remove(queue, 1)

            if current.name == toName then
                return current.path
            end

            local neighbors = self:getNeighbors(current.name)
            if neighbors then
                for _, neighbor in ipairs(neighbors) do
                    if not visited[neighbor.star] then
                        visited[neighbor.star] = true
                        local newPath = {}
                        for i, p in ipairs(current.path) do
                            newPath[i] = p
                        end
                        newPath[#newPath + 1] = neighbor.star
                        queue[#queue + 1] = { name = neighbor.star, path = newPath }
                    end
                end
            end
        end

        return nil -- No path found
    end

    function graph:getPrerequisiteChain(name)
        -- Returns all prerequisites needed to unlock a node (topologically sorted)
        local node = self.nodes[name]
        if not node then
            return nil
        end

        local chain = {}
        local visited = {}

        local function visit(nodeName)
            if visited[nodeName] then
                return
            end
            visited[nodeName] = true

            local n = self.nodes[nodeName]
            if n then
                for _, prereq in ipairs(n.prerequisites) do
                    visit(prereq.star)
                end
                if nodeName ~= name then
                    chain[#chain + 1] = {
                        star = nodeName,
                        min_points = 0,
                    }
                    -- Find the min_points required by the dependent
                    for _, p in ipairs(n.dependents) do
                        if visited[p.star] then
                            for i, c in ipairs(chain) do
                                if c.star == nodeName then
                                    chain[i].min_points = math.max(chain[i].min_points, p.min_points)
                                end
                            end
                        end
                    end
                end
            end
        end

        for _, prereq in ipairs(node.prerequisites) do
            visit(prereq.star)
            -- Add direct prerequisites with their required points
            local found = false
            for _, c in ipairs(chain) do
                if c.star == prereq.star then
                    c.min_points = math.max(c.min_points, prereq.min_points)
                    found = true
                    break
                end
            end
            if not found then
                chain[#chain + 1] = { star = prereq.star, min_points = prereq.min_points }
            end
        end

        return chain
    end

    return graph
end

--------------------------------------------------------------------------------
-- CRAFT CONSTELLATION (Green/Thief) - 28 Stars
--------------------------------------------------------------------------------

ChampionPointsGraph.craft = createGraph({
    ["Friends in Low Places"] = {
        id = 76,
        name = "Friends in Low Places",
        slottable = false,
        stages = 1,
        points_per_stage = 25,
        max_points = 25,
        prerequisites = {},
    },
    ["Discipline Artisan"] = {
        id = 279,
        name = "Discipline Artisan",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {},
    },
    ["Fade Away"] = {
        id = 84,
        name = "Fade Away",
        slottable = true,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Cutpurse's Art", min_points = 25 },
            { star = "Meticulous Disassembly", min_points = 50 },
        },
    },
    ["Out of Sight"] = {
        id = 68,
        name = "Out of Sight",
        slottable = false,
        stages = 3,
        points_per_stage = 10,
        max_points = 30,
        prerequisites = {
            { star = "Friends in Low Places", min_points = 25 },
        },
    },
    ["Shadowstrike"] = {
        id = 80,
        name = "Shadowstrike",
        slottable = true,
        stages = 1,
        points_per_stage = 75,
        max_points = 75,
        prerequisites = {
            { star = "Fade Away", min_points = 50 },
        },
    },
    ["Cutpurse's Art"] = {
        id = 90,
        name = "Cutpurse's Art",
        slottable = false,
        stages = 1,
        points_per_stage = 25,
        max_points = 25,
        prerequisites = {
            { star = "Shadowstrike", min_points = 75 },
        },
    },
    ["Master Gatherer"] = {
        id = 78,
        name = "Master Gatherer",
        slottable = true,
        stages = 5,
        points_per_stage = 15,
        max_points = 75,
        prerequisites = {
            { star = "Treasure Hunter", min_points = 25 },
            { star = "Fade Away", min_points = 50 },
            { star = "Meticulous Disassembly", min_points = 50 },
        },
    },
    ["Treasure Hunter"] = {
        id = 79,
        name = "Treasure Hunter",
        slottable = false,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Meticulous Disassembly", min_points = 50 },
            { star = "Steadfast Enchantment", min_points = 10 },
        },
    },
    ["Angler's Instincts"] = {
        id = 89,
        name = "Angler's Instincts",
        slottable = true,
        stages = 1,
        points_per_stage = 25,
        max_points = 25,
        prerequisites = {
            { star = "Liquid Efficiency", min_points = 50 },
        },
    },
    ["Steadfast Enchantment"] = {
        id = 75,
        name = "Steadfast Enchantment",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Wanderer", min_points = 10 },
        },
    },
    ["Reel Technique"] = {
        id = 88,
        name = "Reel Technique",
        slottable = true,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Angler's Instincts", min_points = 25 },
        },
    },
    ["Rationer"] = {
        id = 85,
        name = "Rationer",
        slottable = false,
        stages = 3,
        points_per_stage = 10,
        max_points = 30,
        prerequisites = {
            { star = "Steadfast Enchantment", min_points = 10 },
        },
    },
    ["War Mount"] = {
        id = 82,
        name = "War Mount",
        slottable = true,
        stages = 1,
        points_per_stage = 75,
        max_points = 75,
        prerequisites = {
            { star = "Gifted Rider", min_points = 10 },
            { star = "Plentiful Harvest", min_points = 10 },
        },
    },
    ["Liquid Efficiency"] = {
        id = 86,
        name = "Liquid Efficiency",
        slottable = false,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Rationer", min_points = 10 },
        },
    },
    ["Gifted Rider"] = {
        id = 92,
        name = "Gifted Rider",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Master Gatherer", min_points = 15 },
        },
    },
    ["Homemaker"] = {
        id = 91,
        name = "Homemaker",
        slottable = false,
        stages = 1,
        points_per_stage = 25,
        max_points = 25,
        prerequisites = {
            { star = "Reel Technique", min_points = 50 },
        },
    },
    ["Steed's Blessing"] = {
        id = 66,
        name = "Steed's Blessing",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {},
    },
    ["Wanderer"] = {
        id = 70,
        name = "Wanderer",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Fortune's Favor", min_points = 10 },
        },
    },
    ["Sustaining Shadows"] = {
        id = 65,
        name = "Sustaining Shadows",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {},
    },
    ["Plentiful Harvest"] = {
        id = 81,
        name = "Plentiful Harvest",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Master Gatherer", min_points = 15 },
        },
    },
    ["Meticulous Disassembly"] = {
        id = 83,
        name = "Meticulous Disassembly",
        slottable = false,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Inspiration Boost", min_points = 15 },
        },
    },
    ["Inspiration Boost"] = {
        id = 72,
        name = "Inspiration Boost",
        slottable = false,
        stages = 3,
        points_per_stage = 15,
        max_points = 45,
        prerequisites = {
            { star = "Fortune's Favor", min_points = 10 },
        },
    },
    ["Fortune's Favor"] = {
        id = 71,
        name = "Fortune's Favor",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Gilded Fingers", min_points = 10 },
        },
    },
    ["Infamous"] = {
        id = 77,
        name = "Infamous",
        slottable = false,
        stages = 1,
        points_per_stage = 25,
        max_points = 25,
        prerequisites = {
            { star = "Fleet Phantom", min_points = 8 },
        },
    },
    ["Fleet Phantom"] = {
        id = 67,
        name = "Fleet Phantom",
        slottable = false,
        stages = 5,
        points_per_stage = 8,
        max_points = 40,
        prerequisites = {
            { star = "Friends in Low Places", min_points = 25 },
        },
    },
    ["Gilded Fingers"] = {
        id = 74,
        name = "Gilded Fingers",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {},
    },
    ["Breakfall"] = {
        id = 69,
        name = "Breakfall",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Wanderer", min_points = 10 },
        },
    },
    ["Soul Reservoir"] = {
        id = 87,
        name = "Soul Reservoir",
        slottable = false,
        stages = 1,
        points_per_stage = 30,
        max_points = 30,
        prerequisites = {
            { star = "Breakfall", min_points = 10 },
        },
    },
    ["Professional Upkeep"] = {
        id = 1,
        name = "Professional Upkeep",
        slottable = false,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {},
    },
})

--------------------------------------------------------------------------------
-- WARFARE CONSTELLATION (Blue/Mage) - 43 Stars
--------------------------------------------------------------------------------

ChampionPointsGraph.warfare = createGraph({
    ["Fighting Finesse"] = {
        id = 12,
        name = "Fighting Finesse",
        slottable = true,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Precision", min_points = 10 },
        },
    },
    ["From the Brink"] = {
        id = 262,
        name = "From the Brink",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Blessed", min_points = 10 },
        },
    },
    ["Enlivening Overflow"] = {
        id = 263,
        name = "Enlivening Overflow",
        slottable = true,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Blessed", min_points = 10 },
        },
    },
    ["Hope Infusion"] = {
        id = 261,
        name = "Hope Infusion",
        slottable = true,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Blessed", min_points = 10 },
        },
    },
    ["Salve of Renewal"] = {
        id = 260,
        name = "Salve of Renewal",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Blessed", min_points = 10 },
        },
    },
    ["Soothing Tide"] = {
        id = 24,
        name = "Soothing Tide",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Blessed", min_points = 10 },
        },
    },
    ["Rejuvenator"] = {
        id = 9,
        name = "Rejuvenator",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Soothing Tide", min_points = 10 },
        },
    },
    ["Foresight"] = {
        id = 163,
        name = "Foresight",
        slottable = true,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {},
    },
    ["Cleansing Revival"] = {
        id = 29,
        name = "Cleansing Revival",
        slottable = true,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Focused Mending", min_points = 10 },
        },
    },
    ["Focused Mending"] = {
        id = 26,
        name = "Focused Mending",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Blessed", min_points = 10 },
        },
    },
    ["Swift Renewal"] = {
        id = 28,
        name = "Swift Renewal",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Blessed", min_points = 10 },
        },
    },
    ["Exploiter"] = {
        id = 277,
        name = "Exploiter",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Piercing", min_points = 10 },
        },
    },
    ["Force of Nature"] = {
        id = 276,
        name = "Force of Nature",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Piercing", min_points = 10 },
        },
    },
    ["Master-at-Arms"] = {
        id = 264,
        name = "Master-at-Arms",
        slottable = true,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Piercing", min_points = 10 },
        },
    },
    ["Weapons Expert"] = {
        id = 259,
        name = "Weapons Expert",
        slottable = true,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Piercing", min_points = 10 },
        },
    },
    ["Deadly Aim"] = {
        id = 25,
        name = "Deadly Aim",
        slottable = true,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Piercing", min_points = 10 },
        },
    },
    ["Biting Aura"] = {
        id = 23,
        name = "Biting Aura",
        slottable = true,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Piercing", min_points = 10 },
        },
    },
    ["Thaumaturge"] = {
        id = 27,
        name = "Thaumaturge",
        slottable = true,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Piercing", min_points = 10 },
        },
    },
    ["Reaving Blows"] = {
        id = 30,
        name = "Reaving Blows",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Precision", min_points = 10 },
        },
    },
    ["Wrathful Strikes"] = {
        id = 8,
        name = "Wrathful Strikes",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Precision", min_points = 10 },
        },
    },
    ["Occult Overload"] = {
        id = 32,
        name = "Occult Overload",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Precision", min_points = 10 },
        },
    },
    ["Backstabber"] = {
        id = 31,
        name = "Backstabber",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Precision", min_points = 10 },
        },
    },
    ["Ironclad"] = {
        id = 265,
        name = "Ironclad",
        slottable = true,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Quick Recovery", min_points = 10 },
        },
    },
    ["Resilience"] = {
        id = 13,
        name = "Resilience",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Quick Recovery", min_points = 10 },
        },
    },
    ["Enduring Resolve"] = {
        id = 136,
        name = "Enduring Resolve",
        slottable = true,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Quick Recovery", min_points = 10 },
        },
    },
    ["Reinforced"] = {
        id = 160,
        name = "Reinforced",
        slottable = false,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Riposte", min_points = 1 },
            { star = "Bulwark", min_points = 1 },
        },
    },
    ["Riposte"] = {
        id = 162,
        name = "Riposte",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Duelist's Rebuff", min_points = 1 },
        },
    },
    ["Bulwark"] = {
        id = 159,
        name = "Bulwark",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Unyielding", min_points = 25 },
        },
    },
    ["Last Stand"] = {
        id = 161,
        name = "Last Stand",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Riposte", min_points = 1 },
            { star = "Reinforced", min_points = 1 },
            { star = "Cutting Defense", min_points = 1 },
        },
    },
    ["Cutting Defense"] = {
        id = 33,
        name = "Cutting Defense",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Riposte", min_points = 1 },
            { star = "Reinforced", min_points = 1 },
        },
    },
    ["Precision"] = {
        id = 11,
        name = "Precision",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {},
    },
    ["Blessed"] = {
        id = 108,
        name = "Blessed",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {
            { star = "Precision", min_points = 10 },
            { star = "Eldritch Insight", min_points = 10 },
        },
    },
    ["Piercing"] = {
        id = 10,
        name = "Piercing",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {
            { star = "Precision", min_points = 10 },
            { star = "Eldritch Insight", min_points = 10 },
            { star = "Tireless Discipline", min_points = 10 },
        },
    },
    ["Flawless Ritual"] = {
        id = 17,
        name = "Flawless Ritual",
        slottable = false,
        stages = 2,
        points_per_stage = 20,
        max_points = 40,
        prerequisites = {
            { star = "Piercing", min_points = 10 },
        },
    },
    ["War Mage"] = {
        id = 21,
        name = "War Mage",
        slottable = false,
        stages = 30,
        points_per_stage = 1,
        max_points = 30,
        prerequisites = {
            { star = "Flawless Ritual", min_points = 10 },
        },
    },
    ["Battle Mastery"] = {
        id = 18,
        name = "Battle Mastery",
        slottable = false,
        stages = 2,
        points_per_stage = 20,
        max_points = 40,
        prerequisites = {
            { star = "Piercing", min_points = 10 },
        },
    },
    ["Mighty"] = {
        id = 22,
        name = "Mighty",
        slottable = false,
        stages = 30,
        points_per_stage = 1,
        max_points = 30,
        prerequisites = {
            { star = "Battle Mastery", min_points = 20 },
        },
    },
    ["Tireless Discipline"] = {
        id = 6,
        name = "Tireless Discipline",
        slottable = false,
        stages = 2,
        points_per_stage = 20,
        max_points = 40,
        prerequisites = {},
    },
    ["Quick Recovery"] = {
        id = 20,
        name = "Quick Recovery",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {
            { star = "Eldritch Insight", min_points = 10 },
        },
    },
    ["Preparation"] = {
        id = 14,
        name = "Preparation",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {
            { star = "Quick Recovery", min_points = 10 },
        },
    },
    ["Elemental Aegis"] = {
        id = 15,
        name = "Elemental Aegis",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {
            { star = "Preparation", min_points = 10 },
        },
    },
    ["Hardy"] = {
        id = 16,
        name = "Hardy",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {
            { star = "Preparation", min_points = 10 },
        },
    },
    ["Eldritch Insight"] = {
        id = 99,
        name = "Eldritch Insight",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {},
    },
    ["Duelist's Rebuff"] = {
        id = 134,
        name = "Duelist's Rebuff",
        slottable = true,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Eldritch Insight", min_points = 10 },
        },
    },
    ["Unassailable"] = {
        id = 133,
        name = "Unassailable",
        slottable = true,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Quick Recovery", min_points = 10 },
        },
    },
    ["Endless Endurance"] = {
        id = 5,
        name = "Endless Endurance",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {},
    },
    ["Untamed Aggression"] = {
        id = 4,
        name = "Untamed Aggression",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {},
    },
    ["Arcane Supremacy"] = {
        id = 3,
        name = "Arcane Supremacy",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {},
    },
    -- Missing node referenced by Bulwark
    ["Unyielding"] = {
        id = 0, -- ID not in source data
        name = "Unyielding",
        slottable = false,
        stages = 1,
        points_per_stage = 25,
        max_points = 25,
        prerequisites = {},
    },
})

--------------------------------------------------------------------------------
-- FITNESS CONSTELLATION (Red/Warrior) - 44 Stars
--------------------------------------------------------------------------------

ChampionPointsGraph.fitness = createGraph({
    ["Thrill of the Hunt"] = {
        id = 272,
        name = "Thrill of the Hunt",
        slottable = true,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Hasty", min_points = 10 },
        },
    },
    ["Celerity"] = {
        id = 270,
        name = "Celerity",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Hasty", min_points = 10 },
        },
    },
    ["Refreshing Stride"] = {
        id = 271,
        name = "Refreshing Stride",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Hasty", min_points = 10 },
        },
    },
    ["Shield Master"] = {
        id = 63,
        name = "Shield Master",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Hero's Vigor", min_points = 10 },
        },
    },
    ["Bastion"] = {
        id = 46,
        name = "Bastion",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Shield Master", min_points = 10 },
        },
    },
    ["Survival Instincts"] = {
        id = 57,
        name = "Survival Instincts",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Mystic Tenacity", min_points = 10 },
        },
    },
    ["Spirit Mastery"] = {
        id = 56,
        name = "Spirit Mastery",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Tempered Soul", min_points = 25 },
        },
    },
    ["Arcane Alacrity"] = {
        id = 61,
        name = "Arcane Alacrity",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Bastion", min_points = 10 },
        },
    },
    ["Bloody Renewal"] = {
        id = 48,
        name = "Bloody Renewal",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Hero's Vigor", min_points = 10 },
        },
    },
    ["Strategic Reserve"] = {
        id = 49,
        name = "Strategic Reserve",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Hero's Vigor", min_points = 10 },
        },
    },
    ["Relentlessness"] = {
        id = 274,
        name = "Relentlessness",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Mystic Tenacity", min_points = 10 },
        },
    },
    ["Pain's Refuge"] = {
        id = 275,
        name = "Pain's Refuge",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Mystic Tenacity", min_points = 10 },
        },
    },
    ["Sustained by Suffering"] = {
        id = 273,
        name = "Sustained by Suffering",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Mystic Tenacity", min_points = 10 },
        },
    },
    ["Siphoning Spells"] = {
        id = 47,
        name = "Siphoning Spells",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Hero's Vigor", min_points = 10 },
        },
    },
    ["Rousing Speed"] = {
        id = 62,
        name = "Rousing Speed",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Sprinter", min_points = 10 },
        },
    },
    ["Soothing Shield"] = {
        id = 268,
        name = "Soothing Shield",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Nimble Protector", min_points = 3 },
        },
    },
    ["Bracing Anchor"] = {
        id = 267,
        name = "Bracing Anchor",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Nimble Protector", min_points = 3 },
        },
    },
    ["Ward Master"] = {
        id = 266,
        name = "Ward Master",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Nimble Protector", min_points = 3 },
        },
    },
    ["On Guard"] = {
        id = 60,
        name = "On Guard",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Tireless Guardian", min_points = 10 },
        },
    },
    ["Expert Evasion"] = {
        id = 51,
        name = "Expert Evasion",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Tumbling", min_points = 10 },
        },
    },
    ["Slippery"] = {
        id = 52,
        name = "Slippery",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Defiance", min_points = 10 },
        },
    },
    ["Unchained"] = {
        id = 64,
        name = "Unchained",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {
            { star = "Slippery", min_points = 10 },
        },
    },
    ["Juggernaut"] = {
        id = 59,
        name = "Juggernaut",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Defiance", min_points = 10 },
        },
    },
    ["Peace of Mind"] = {
        id = 54,
        name = "Peace of Mind",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Defiance", min_points = 10 },
        },
    },
    ["Hardened"] = {
        id = 55,
        name = "Hardened",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Defiance", min_points = 10 },
        },
    },
    ["Rejuvenation"] = {
        id = 35,
        name = "Rejuvenation",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {},
    },
    ["Fortified"] = {
        id = 34,
        name = "Fortified",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {},
    },
    ["Boundless Vitality"] = {
        id = 2,
        name = "Boundless Vitality",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {},
    },
    ["Sprinter"] = {
        id = 38,
        name = "Sprinter",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {},
    },
    ["Hasty"] = {
        id = 42,
        name = "Hasty",
        slottable = false,
        stages = 2,
        points_per_stage = 8,
        max_points = 16,
        prerequisites = {
            { star = "Sprinter", min_points = 10 },
            { star = "Hero's Vigor", min_points = 10 },
        },
    },
    ["Hero's Vigor"] = {
        id = 113,
        name = "Hero's Vigor",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {
            { star = "Mystic Tenacity", min_points = 10 },
        },
    },
    ["Tempered Soul"] = {
        id = 58,
        name = "Tempered Soul",
        slottable = false,
        stages = 2,
        points_per_stage = 25,
        max_points = 50,
        prerequisites = {
            { star = "Piercing Gaze", min_points = 10 },
            { star = "Survival Instincts", min_points = 10 },
        },
    },
    ["Piercing Gaze"] = {
        id = 45,
        name = "Piercing Gaze",
        slottable = false,
        stages = 3,
        points_per_stage = 10,
        max_points = 30,
        prerequisites = {
            { star = "Hero's Vigor", min_points = 10 },
        },
    },
    ["Mystic Tenacity"] = {
        id = 53,
        name = "Mystic Tenacity",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {
            { star = "Hero's Vigor", min_points = 10 },
            { star = "Tumbling", min_points = 10 },
        },
    },
    ["Tireless Guardian"] = {
        id = 39,
        name = "Tireless Guardian",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {
            { star = "Hasty", min_points = 10 },
        },
    },
    ["Savage Defense"] = {
        id = 40,
        name = "Savage Defense",
        slottable = false,
        stages = 2,
        points_per_stage = 15,
        max_points = 30,
        prerequisites = {
            { star = "Tireless Guardian", min_points = 10 },
        },
    },
    ["Bashing Brutality"] = {
        id = 50,
        name = "Bashing Brutality",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {
            { star = "Tireless Guardian", min_points = 10 },
        },
    },
    ["Nimble Protector"] = {
        id = 44,
        name = "Nimble Protector",
        slottable = false,
        stages = 2,
        points_per_stage = 3,
        max_points = 6,
        prerequisites = {
            { star = "Tireless Guardian", min_points = 10 },
        },
    },
    ["Fortification"] = {
        id = 43,
        name = "Fortification",
        slottable = false,
        stages = 2,
        points_per_stage = 15,
        max_points = 20,
        prerequisites = {
            { star = "Tireless Guardian", min_points = 10 },
        },
    },
    ["Tumbling"] = {
        id = 37,
        name = "Tumbling",
        slottable = false,
        stages = 2,
        points_per_stage = 15,
        max_points = 30,
        prerequisites = {},
    },
    ["Defiance"] = {
        id = 128,
        name = "Defiance",
        slottable = false,
        stages = 2,
        points_per_stage = 10,
        max_points = 20,
        prerequisites = {},
    },
})

--------------------------------------------------------------------------------
-- MERMAID DIAGRAM GENERATION
--------------------------------------------------------------------------------

-- Theme configurations for each constellation
local THEMES = {
    craft = {
        name = "Craft",
        emoji = "🌿",
        primaryColor = "#2d5016",
        primaryTextColor = "#fff",
        primaryBorderColor = "#4a7c23",
        lineColor = "#6b8e23",
        secondaryColor = "#3d6b1c",
        tertiaryColor = "#1a3009",
        background = "#0d1a00",
        mainBkg = "#2d5016",
        nodeBorder = "#4a7c23",
        clusterBkg = "#1a3009",
        titleColor = "#9acd32",
        edgeLabelBackground = "#1a3009",
        slottedFill = "#2d5016",
        slottedStroke = "#9acd32",
        unslottedFill = "#1a3009",
        unslottedStroke = "#4a7c23",
    },
    warfare = {
        name = "Warfare",
        emoji = "⚔️",
        primaryColor = "#6b1e1e",
        primaryTextColor = "#fff",
        primaryBorderColor = "#c0392b",
        lineColor = "#e74c3c",
        secondaryColor = "#922b21",
        tertiaryColor = "#400d0d",
        background = "#1a0808",
        mainBkg = "#6b1e1e",
        nodeBorder = "#c0392b",
        clusterBkg = "#400d0d",
        titleColor = "#f1948a",
        edgeLabelBackground = "#400d0d",
        slottedFill = "#6b1e1e",
        slottedStroke = "#e74c3c",
        unslottedFill = "#400d0d",
        unslottedStroke = "#c0392b",
    },
    fitness = {
        name = "Fitness",
        emoji = "💪",
        primaryColor = "#1e4d6b",
        primaryTextColor = "#fff",
        primaryBorderColor = "#3498db",
        lineColor = "#5dade2",
        secondaryColor = "#2874a6",
        tertiaryColor = "#0d2840",
        background = "#061520",
        mainBkg = "#1e4d6b",
        nodeBorder = "#3498db",
        clusterBkg = "#0d2840",
        titleColor = "#85c1e9",
        edgeLabelBackground = "#0d2840",
        slottedFill = "#1e4d6b",
        slottedStroke = "#5dade2",
        unslottedFill = "#0d2840",
        unslottedStroke = "#3498db",
    },
}

-- Category groupings for each constellation
local CATEGORIES = {
    craft = {
        { name = "STEALTH", emoji = "🗡️", title = "STEALTH & THIEVERY", stars = { 76, 68, 67, 77, 80, 90, 84 } },
        { name = "GATHER", emoji = "🌿", title = "GATHERING & CRAFTING", stars = { 279, 78, 79, 81, 83, 72 } },
        { name = "FISH", emoji = "🎣", title = "FISHING", stars = { 89, 88 } },
        { name = "CONSUME", emoji = "🧪", title = "CONSUMABLES", stars = { 85, 86, 91 } },
        { name = "MOUNT", emoji = "🐎", title = "MOUNT & MOVEMENT", stars = { 82, 92, 66, 70, 65 } },
        { name = "UTILITY", emoji = "⚡", title = "UTILITY", stars = { 75, 71, 74, 69, 87, 1 } },
    },
    warfare = {
        { name = "OFFENSE", emoji = "⚔️", title = "DIRECT DAMAGE", stars = { 11, 12, 30, 8, 32, 31 } },
        {
            name = "WEAPON",
            emoji = "🗡️",
            title = "WEAPON MASTERY",
            stars = { 10, 277, 276, 264, 259, 25, 23, 27 },
        },
        { name = "MAGIC_DMG", emoji = "✨", title = "MAGIC DAMAGE", stars = { 17, 21, 18, 22 } },
        {
            name = "HEALING",
            emoji = "💚",
            title = "HEALING",
            stars = { 108, 262, 263, 261, 260, 24, 9, 163, 29, 26, 28 },
        },
        {
            name = "DEFENSE",
            emoji = "🛡️",
            title = "DAMAGE MITIGATION",
            stars = { 99, 20, 265, 13, 136, 14, 15, 16 },
        },
        { name = "SUSTAIN", emoji = "⚡", title = "RESOURCE SUSTAIN", stars = { 6, 5, 4, 3 } },
        { name = "BLOCK", emoji = "🔰", title = "BLOCK & RIPOSTE", stars = { 134, 133, 162, 159, 160, 161, 33 } },
    },
    fitness = {
        { name = "RECOVERY", emoji = "💧", title = "RECOVERY", stars = { 35, 34, 2 } },
        { name = "SPEED", emoji = "⚡", title = "SPEED & MOBILITY", stars = { 38, 42, 272, 270, 271, 62 } },
        { name = "SHIELD", emoji = "🛡️", title = "SHIELD & BLOCK", stars = { 113, 63, 46, 50 } },
        { name = "MAGIC", emoji = "✨", title = "MAGIC SUSTAIN", stars = { 58, 56, 61, 47, 45 } },
        { name = "HEALTH", emoji = "❤️", title = "HEALTH & SURVIVAL", stars = { 48, 49, 53, 57, 274, 275, 273 } },
        { name = "DEFENSE", emoji = "🔰", title = "DEFENSIVE", stars = { 39, 40, 60, 44, 43, 268, 267, 266 } },
        { name = "EVASION", emoji = "💨", title = "EVASION & CC", stars = { 37, 51, 128, 52, 64, 59, 54, 55 } },
    },
}

-- Generate theme configuration block
local function generateThemeConfig(constellationName)
    local theme = THEMES[constellationName]
    if not theme then
        return ""
    end

    return string.format(
        [[%%{init: {
  'theme': 'base',
  'themeVariables': {
    'primaryColor': '%s',
    'primaryTextColor': '%s',
    'primaryBorderColor': '%s',
    'lineColor': '%s',
    'secondaryColor': '%s',
    'tertiaryColor': '%s',
    'background': '%s',
    'mainBkg': '%s',
    'nodeBorder': '%s',
    'clusterBkg': '%s',
    'titleColor': '%s',
    'edgeLabelBackground': '%s'
  },
  'flowchart': {
    'curve': 'basis',
    'nodeSpacing': 50,
    'rankSpacing': 60,
    'padding': 15
  }
}}%%]],
        theme.primaryColor,
        theme.primaryTextColor,
        theme.primaryBorderColor,
        theme.lineColor,
        theme.secondaryColor,
        theme.tertiaryColor,
        theme.background,
        theme.mainBkg,
        theme.nodeBorder,
        theme.clusterBkg,
        theme.titleColor,
        theme.edgeLabelBackground
    )
end

-- Generate node definition
local function generateNodeDefinition(star, pointsAllocated, isSlottable)
    local icon = (pointsAllocated and pointsAllocated > 0) and "✅" or (isSlottable and "🔲" or "✅")
    local label = string.format(
        "%s %s<br/><small>%dstg × %dpts = %d max</small>",
        icon,
        star.name,
        star.stages,
        star.points_per_stage,
        star.max_points
    )
    return string.format('    %d["%s"]', star.id, label)
end

-- Generate subgraph with stars
local function generateSubgraph(category, constellation, characterPoints)
    local lines = {}
    table.insert(lines, string.format('    subgraph %s["%s %s"]', category.name, category.emoji, category.title))
    table.insert(lines, "        direction TB")

    -- Generate nodes for this category
    for _, starId in ipairs(category.stars) do
        local star = constellation._byId[starId]
        if star then
            local points = characterPoints and characterPoints[star.name] or 0
            table.insert(lines, "    " .. generateNodeDefinition(star, points, star.slottable))
        end
    end

    table.insert(lines, "    end")
    return table.concat(lines, "\n")
end

-- Generate all connections
local function generateConnections(constellation)
    local lines = {}
    local processed = {}

    for name, node in pairs(constellation.nodes) do
        for _, prereq in ipairs(node.prerequisites) do
            local prereqNode = constellation.nodes[prereq.star]
            if prereqNode then
                local key = prereqNode.id .. "-" .. node.id
                if not processed[key] then
                    processed[key] = true
                    table.insert(lines, string.format('    %d -->|"%d"| %d', prereqNode.id, prereq.min_points, node.id))
                end
            end
        end
    end

    return table.concat(lines, "\n")
end

-- Generate styling classes
local function generateStyling(constellationName, constellation, characterPoints)
    local theme = THEMES[constellationName]
    local lines = {}

    -- Define classes
    table.insert(
        lines,
        string.format(
            [[    %% Class styling
    classDef slotted fill:%s,stroke:%s,stroke-width:3px,color:#fff
    classDef unslotted fill:%s,stroke:%s,stroke-width:2px,color:%s]],
            theme.slottedFill,
            theme.slottedStroke,
            theme.unslottedFill,
            theme.unslottedStroke,
            theme.titleColor
        )
    )

    -- Classify nodes
    local slottedIds = {}
    local unslottedIds = {}

    for name, node in pairs(constellation.nodes) do
        local points = characterPoints and characterPoints[name] or 0
        if node.slottable then
            if points > 0 then
                table.insert(unslottedIds, tostring(node.id))
            else
                table.insert(slottedIds, tostring(node.id))
            end
        else
            if points > 0 then
                table.insert(unslottedIds, tostring(node.id))
            else
                table.insert(unslottedIds, tostring(node.id))
            end
        end
    end

    if #slottedIds > 0 then
        table.insert(lines, "    class " .. table.concat(slottedIds, ",") .. " slotted")
    end
    if #unslottedIds > 0 then
        table.insert(lines, "    class " .. table.concat(unslottedIds, ",") .. " unslotted")
    end

    return table.concat(lines, "\n")
end

-- Main function to generate Mermaid diagram
function ChampionPointsGraph.generateMermaidDiagram(constellationName, characterPoints)
    --[[
        Generate a Mermaid flowchart diagram for a champion points constellation
        
        Args:
            constellationName: "craft", "warfare", or "fitness"
            characterPoints: optional table of {starName = pointsAllocated}
                           If nil, all stars shown as unallocated
        
        Returns:
            string: Complete Mermaid flowchart diagram
    ]]

    local constellation = ChampionPointsGraph[constellationName]
    if not constellation then
        return "-- Error: Invalid constellation name: " .. tostring(constellationName)
    end

    characterPoints = characterPoints or {}

    local diagram = {}

    -- Theme configuration
    table.insert(diagram, generateThemeConfig(constellationName))
    table.insert(diagram, "")

    -- Flowchart declaration
    table.insert(diagram, "flowchart LR")

    -- Generate subgraphs
    local categories = CATEGORIES[constellationName]
    if categories then
        for _, category in ipairs(categories) do
            table.insert(diagram, generateSubgraph(category, constellation, characterPoints))
            table.insert(diagram, "")
        end
    end

    -- Generate connections
    table.insert(diagram, "    %% Connections")
    table.insert(diagram, generateConnections(constellation))
    table.insert(diagram, "")

    -- Generate styling
    table.insert(diagram, generateStyling(constellationName, constellation, characterPoints))
    table.insert(diagram, "")

    return table.concat(diagram, "\n")
end

--------------------------------------------------------------------------------
-- MODULE EXPORT
--------------------------------------------------------------------------------

return ChampionPointsGraph
