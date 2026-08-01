-- CharacterMarkdown - Equipment Section Helpers
-- Shared utilities and helper functions for equipment generation

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.equipment = CM.generators.sections.equipment or {}

local helpers = CM.generators.sections.equipment
helpers.cache = helpers.cache or {}

-- Lazy initialization of cached references
function helpers.InitializeUtilities()
    local cache = helpers.cache
    if not cache.FormatNumber then
        -- Defensive: Check if functions exist before assigning
        cache.CreateAbilityLink = (CM.links and CM.links.CreateAbilityLink)
            or function(name, id)
                return name or ""
            end
        cache.CreateSetLink = (CM.links and CM.links.CreateSetLink)
            or function(name)
                return name or ""
            end
        cache.CreateSkillLineLink = (CM.links and CM.links.CreateSkillLineLink)
            or function(name)
                return name or ""
            end
        cache.FormatNumber = (CM.utils and CM.utils.FormatNumber)
            or function(num)
                return tostring(num or 0)
            end
        cache.GenerateProgressBar = (
            CM.generators
            and CM.generators.helpers
            and CM.generators.helpers.GenerateProgressBar
        ) or function(percent, width)
                return ""
            end
        cache.markdown = (CM.utils and CM.utils.markdown) or nil
    end
end

-- =====================================================
-- HELPER: Get Set Type Badge
-- =====================================================

function helpers.GetSetTypeBadge(setTypeName)
    if not setTypeName then
        return ""
    end

    local badges = {
        ["Trial"] = "🏰",
        ["Dungeon"] = "🏰",
        ["Overland"] = "🌍",
        ["Crafted"] = "⚒️",
        ["Monster"] = "👹",
        ["Arena"] = "⚔️",
        ["Battleground"] = "🎯",
        ["Cyrodiil"] = "🗡️",
        ["Imperial City"] = "🏰",
        ["Mythic"] = "✨",
        ["Class"] = "📚",
    }

    local badge = badges[setTypeName] or "📦"
    return badge .. " " .. setTypeName
end

CM.DebugPrint("GENERATOR", "Equipment helpers module loaded")
