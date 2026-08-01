-- CharacterMarkdown - Equipment Section Orchestrator
-- Central registry for equipment-related generators

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}

-- =====================================================
-- CONSOLIDATED PROGRESS GENERATOR
-- =====================================================

-- This function replaces the old logic from CharacterProgress.lua
-- It combines skill progression, summaries, and morphs into a single section
function CM.generators.sections.GenerateCharacterProgress(skillProgressionData, skillMorphsData)
    local output = "## 📜 Character Progress\n\n"

    -- Use the modular generators
    local GenerateSkills = CM.generators.sections.GenerateSkills
    local GenerateSkillMorphs = CM.generators.sections.GenerateSkillMorphs

    if GenerateSkills then
        local success, result = pcall(GenerateSkills, skillProgressionData, skillMorphsData)
        if success and result then
            output = output .. result
        end
    end

    if skillMorphsData and GenerateSkillMorphs then
        local success, result = pcall(GenerateSkillMorphs, skillMorphsData)
        if success and result and result ~= "" then
            -- Strip the redudant "## 🌿 Skill Morphs" header if present
            local morphsContent = result:gsub("^##%s+🌿%s+Skill%s+Morphs%s*\n%s*\n", "")
            -- Wrap in a collapsible if it's long
            output = output
                .. "\n<details>\n<summary>🌿 Detailed Skill Morphs</summary>\n\n"
                .. morphsContent
                .. "\n</details>\n\n"
        end
    end

    return output
end

-- =====================================================
-- DEBUG IDENTIFICATION
-- =====================================================

CM.DebugPrint("GENERATOR", "Equipment orchestrator module loaded")
