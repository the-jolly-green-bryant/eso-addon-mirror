-- CharacterMarkdown - Crafting Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

local function CollectCraftingData()
    -- Use API layer granular functions (composition at collector level)
    local timers = CM.api.crafting.GetActiveTimers()

    local crafting = {}

    -- Transform API data to expected format (backward compatibility)
    crafting.timers = timers or {}

    -- Motifs
    local settings = CM.GetSettings()
    if settings.includeMotifs then
        crafting.motifs = CM.api.crafting.GetMotifKnowledge()
    else
        crafting.motifs = {}
    end

    -- Recipes
    if settings.includeRecipes then
        crafting.recipes = CM.api.crafting.GetRecipeKnowledge()
    else
        crafting.recipes = { all = {}, count = 0 }
    end

    -- Research info (optional, can be large)
    crafting.research = {
        blacksmithing = CM.api.crafting.GetResearchInfo(CRAFTING_TYPE_BLACKSMITHING),
        clothing = CM.api.crafting.GetResearchInfo(CRAFTING_TYPE_CLOTHIER),
        woodworking = CM.api.crafting.GetResearchInfo(CRAFTING_TYPE_WOODWORKING),
        jewelry = CM.api.crafting.GetResearchInfo(CRAFTING_TYPE_JEWELRYCRAFTING),
    }

    -- Styles (basic crafting styles)
    crafting.styles = CM.api.crafting.GetKnownStyles()

    -- Add computed summary
    local activeTimers = crafting.timers and #crafting.timers or 0
    local totalMotifs = crafting.motifs and #crafting.motifs or 0
    local totalRecipes = crafting.recipes and crafting.recipes.count or 0

    -- Calculate research progress
    local researchProgress = {
        blacksmithing = 0,
        clothing = 0,
        woodworking = 0,
        jewelry = 0,
    }

    for craftType, researchInfo in pairs(crafting.research) do
        local totalTraits = 0
        local knownTraits = 0
        if researchInfo then
            for _, line in ipairs(researchInfo) do
                if line.traits then
                    for _, trait in ipairs(line.traits) do
                        totalTraits = totalTraits + 1
                        if trait.known then
                            knownTraits = knownTraits + 1
                        end
                    end
                end
            end
        end
        if totalTraits > 0 then
            researchProgress[craftType] = math.floor((knownTraits / totalTraits) * 100)
        end
    end

    crafting.summary = {
        activeTimers = activeTimers,
        totalMotifs = totalMotifs,
        totalRecipes = totalRecipes,
        researchProgress = researchProgress,
    }

    return crafting
end

CM.collectors.CollectCraftingData = CollectCraftingData

CM.DebugPrint("COLLECTOR", "Crafting collector module loaded")
