-- CharacterMarkdown - Skill Morphs Generator
-- Generates skill morph sections for character progression

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.equipment = CM.generators.sections.equipment or {}

local helpers = CM.generators.sections.equipment
local morphs = {}

-- =====================================================
-- SKILL MORPHS
-- =====================================================

function morphs.GenerateSkillMorphs(skillMorphsData)
    helpers.InitializeUtilities()
    local cache = helpers.cache
    local markdown_utils = cache.markdown

    local output = ""

    if not skillMorphsData then
        return ""
    end

    local skillTypes = skillMorphsData.skillTypes or skillMorphsData
    if type(skillTypes) ~= "table" or #skillTypes == 0 then
        output = output .. "## 🌿 Skill Morphs\n\n"
        output = output .. "*No morphable abilities found.*\n\n"
        local CreateSeparator = markdown_utils and markdown_utils.CreateSeparator
        if CreateSeparator then
            output = output .. CreateSeparator("hr")
        else
            output = output .. "---\n\n"
        end
        return output
    end

    output = output .. "## 🌿 Skill Morphs\n\n"

    for _, skillType in ipairs(skillTypes) do
        local totalAbilities = 0
        for _, skillLine in ipairs(skillType.skillLines) do
            totalAbilities = totalAbilities + #(skillLine.abilities or {})
        end

        output = output
            .. "### "
            .. (skillType.emoji or "⚔️")
            .. " "
            .. skillType.name
            .. " ("
            .. totalAbilities
            .. " abilities with morph choices)\n\n"

        for _, skillLine in ipairs(skillType.skillLines) do
            output = output .. "#### " .. skillLine.name .. " (Rank " .. (skillLine.rank or 0) .. ")\n\n"

            for _, ability in ipairs(skillLine.abilities) do
                local baseText = cache.CreateAbilityLink(ability.name)
                local statusIcon = ""

                if ability.purchased then
                    if ability.currentMorph > 0 then
                        statusIcon = "✅ "
                    elseif ability.atMorphChoice then
                        statusIcon = "⚠️ "
                    else
                        statusIcon = "🔒 "
                    end
                else
                    statusIcon = "🔒 "
                end

                output = output .. statusIcon .. "**" .. baseText .. "**"

                if ability.currentRank and ability.currentRank > 0 then
                    output = output .. " (Rank " .. ability.currentRank .. ")"
                end

                output = output .. "\n\n"

                if #(ability.morphs or {}) > 0 then
                    local selectedMorph = nil
                    local unselectedMorphs = {}

                    for _, morph in ipairs(ability.morphs) do
                        if morph.selected then
                            selectedMorph = morph
                        else
                            table.insert(unselectedMorphs, morph)
                        end
                    end

                    if selectedMorph then
                        local morphName = tostring(selectedMorph.name or "Unknown")
                            :gsub("[\r\n\t]", "")
                            :gsub("^%s+", "")
                            :gsub("%s+$", "")
                            :gsub("%s+", " ")
                        local morphText = cache.CreateAbilityLink(morphName, selectedMorph.abilityId)
                        local morphSlot = tostring(selectedMorph.morphSlot or "?")
                        output = output .. "  ✅ **Morph " .. morphSlot .. "**: " .. morphText .. "\n"
                    end

                    if #unselectedMorphs > 0 then
                        output = output .. "\n"
                        output = output .. "  <details>\n"
                        output = output .. "  <summary>Other morph options</summary>\n\n"

                        for _, morph in ipairs(unselectedMorphs) do
                            local morphName = tostring(morph.name or "Unknown")
                                :gsub("[\r\n\t]", "")
                                :gsub("^%s+", "")
                                :gsub("%s+$", "")
                                :gsub("%s+", " ")
                            local morphText = cache.CreateAbilityLink(morphName, morph.abilityId)
                            local morphSlot = tostring(morph.morphSlot or "?")
                            output = output .. "  ⚪ **Morph " .. morphSlot .. "**: " .. morphText .. "\n"
                        end

                        output = output .. "\n  </details>\n"
                    end
                elseif ability.atMorphChoice then
                    output = output .. "  ⚠️ *Morph choice available - level up to unlock*\n"
                else
                    if ability.purchased then
                        output = output .. "  🔒 *Morph locked - continue leveling this skill*\n"
                    else
                        output = output .. "  🔒 *Purchase this ability to unlock morphs*\n"
                    end
                end

                output = output .. "\n"
            end
            output = output .. "\n"
        end
        output = output .. "\n"
    end

    return output
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections.GenerateSkillMorphs = morphs.GenerateSkillMorphs
CM.generators.sections.equipment.SkillMorphs = morphs

CM.DebugPrint("GENERATOR", "Skill morphs module loaded")
