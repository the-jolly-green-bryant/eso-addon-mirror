-- CharacterMarkdown - Combat Section Generators
-- Generates combat-related markdown sections (stats, attributes, buffs)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local CreateBuffLink, FormatNumber, GenerateAnchor

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        if CM.links then
            CreateBuffLink = CM.links.CreateBuffLink
        end
        if CM.utils then
            FormatNumber = CM.utils.FormatNumber
        end
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
    end
end

-- =====================================================
-- COMBAT STATS
-- =====================================================

local function GenerateCombatStats(statsData, inline)
    InitializeUtilities()

    if not statsData then
        return ""
    end

    -- inline parameter: if true, generate just the table without section header/divider (for overview section)
    inline = inline or false

    local markdown = ""

    if not inline then
        -- Use CreateSeparator for consistent separator styling
        local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
        if CreateSeparator then
            markdown = markdown .. CreateSeparator("hr")
        else
            markdown = markdown .. "---\n\n"
        end
        local anchorId = GenerateAnchor and GenerateAnchor("📈 Combat Statistics") or "combat-statistics"
        markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## 📈 Combat Statistics\n\n"
    else
        markdown = markdown .. '\n<a id="character-stats"></a>\n\n### Character Stats\n\n'

        -- For inline mode, use 3-column layout if markdown utilities are available
        local CreateStyledTable = CM.utils.markdown and CM.utils.markdown.CreateStyledTable
        local CreateResponsiveColumns = CM.utils.markdown and CM.utils.markdown.CreateResponsiveColumns

        if CreateStyledTable and CreateResponsiveColumns then
            -- COLUMN 1: Resources & Offensive
            local col1_headers = { "Category", "Stat", "Value" }
            local col1_rows = {
                { "💚 **Resources**", "Health", FormatNumber(statsData.health or 0) },
                { "", "Magicka", FormatNumber(statsData.magicka or 0) },
                { "", "Stamina", FormatNumber(statsData.stamina or 0) },
                { "⚔️ **Offensive**", "Weapon Power", FormatNumber(statsData.weaponPower or 0) },
                { "", "Spell Power", FormatNumber(statsData.spellPower or 0) },
            }

            local options1 = {
                alignment = { "left", "left", "right" },
                coloredHeaders = true,
            }
            local column1 = CreateStyledTable(col1_headers, col1_rows, options1)

            -- COLUMN 2: Critical & Penetration
            local col2_headers = { "Category", "Stat", "Value" }
            local col2_rows = {
                {
                    "🎯 **Critical**",
                    "Weapon Crit",
                    FormatNumber(statsData.weaponCritRating or 0) .. " (" .. (statsData.weaponCritChance or 0) .. "%)",
                },
                {
                    "",
                    "Spell Crit",
                    FormatNumber(statsData.spellCritRating or 0) .. " (" .. (statsData.spellCritChance or 0) .. "%)",
                },
                { "⚔️ **Penetration**", "Physical", FormatNumber(statsData.physicalPenetration or 0) },
                { "", "Spell", FormatNumber(statsData.spellPenetration or 0) },
            }

            local options2 = {
                alignment = { "left", "left", "right" },
                coloredHeaders = true,
            }
            local column2 = CreateStyledTable(col2_headers, col2_rows, options2)

            -- COLUMN 3: Defensive & Recovery
            local col3_headers = { "Category", "Stat", "Value" }
            local col3_rows = {
                {
                    "🛡️ **Defensive**",
                    "Physical Resist",
                    FormatNumber(statsData.physicalResist or 0) .. " (" .. (statsData.physicalMitigation or 0) .. "%)",
                },
                {
                    "",
                    "Spell Resist",
                    FormatNumber(statsData.spellResist or 0) .. " (" .. (statsData.spellMitigation or 0) .. "%)",
                },
                { "♻️ **Recovery**", "Health", FormatNumber(statsData.healthRecovery or 0) },
                { "", "Magicka", FormatNumber(statsData.magickaRecovery or 0) },
                { "", "Stamina", FormatNumber(statsData.staminaRecovery or 0) },
            }

            local options3 = {
                alignment = { "left", "left", "right" },
                coloredHeaders = true,
            }
            local column3 = CreateStyledTable(col3_headers, col3_rows, options3)

            -- Create responsive 3-column layout
            local LayoutCalculator = CM.utils.LayoutCalculator
            local minWidth, gap
            if LayoutCalculator then
                minWidth, gap =
                    LayoutCalculator.GetLayoutParamsWithFallback({ column1, column2, column3 }, "250px", "20px")
            else
                minWidth = "250px"
                gap = "20px"
            end
            local columnsLayout = CreateResponsiveColumns({ column1, column2, column3 }, minWidth, gap)
            markdown = markdown .. columnsLayout
        else
            -- Fallback to single table format
            local statRows = {
                "| Category | Stat | Value |",
                "|:---------|:-----|------:|",
                "| 💚 **Resources** | Health | " .. FormatNumber(statsData.health or 0) .. " |",
                "| | Magicka | " .. FormatNumber(statsData.magicka or 0) .. " |",
                "| | Stamina | " .. FormatNumber(statsData.stamina or 0) .. " |",
                "| ⚔️ **Offensive** | Weapon Power | " .. FormatNumber(statsData.weaponPower or 0) .. " |",
                "| | Spell Power | " .. FormatNumber(statsData.spellPower or 0) .. " |",
                "| 🎯 **Critical** | Weapon Crit | "
                    .. FormatNumber(statsData.weaponCritRating or 0)
                    .. " ("
                    .. (statsData.weaponCritChance or 0)
                    .. "%) |",
                "| | Spell Crit | "
                    .. FormatNumber(statsData.spellCritRating or 0)
                    .. " ("
                    .. (statsData.spellCritChance or 0)
                    .. "%) |",
                "| ⚔️ **Penetration** | Physical | " .. FormatNumber(statsData.physicalPenetration or 0) .. " |",
                "| | Spell | " .. FormatNumber(statsData.spellPenetration or 0) .. " |",
                "| 🛡️ **Defensive** | Physical Resist | "
                    .. FormatNumber(statsData.physicalResist or 0)
                    .. " ("
                    .. (statsData.physicalMitigation or 0)
                    .. "%) |",
                "| | Spell Resist | "
                    .. FormatNumber(statsData.spellResist or 0)
                    .. " ("
                    .. (statsData.spellMitigation or 0)
                    .. "%) |",
                "| ♻️ **Recovery** | Health | " .. FormatNumber(statsData.healthRecovery or 0) .. " |",
                "| | Magicka | " .. FormatNumber(statsData.magickaRecovery or 0) .. " |",
                "| | Stamina | " .. FormatNumber(statsData.staminaRecovery or 0) .. " |",
                "",
            }
            markdown = markdown .. table.concat(statRows, "\n") .. "\n"
        end
    end

    -- Generate table for non-inline mode
    if not inline then
        local statRows = {
            "| Category | Stat | Value |",
            "|:---------|:-----|------:|",
            "| 💚 **Resources** | Health | " .. FormatNumber(statsData.health or 0) .. " |",
            "| | Magicka | " .. FormatNumber(statsData.magicka or 0) .. " |",
            "| | Stamina | " .. FormatNumber(statsData.stamina or 0) .. " |",
            "| ⚔️ **Offensive** | Weapon Power | " .. FormatNumber(statsData.weaponPower or 0) .. " |",
            "| | Spell Power | " .. FormatNumber(statsData.spellPower or 0) .. " |",
            "| 🎯 **Critical** | Weapon Crit | "
                .. FormatNumber(statsData.weaponCritRating or 0)
                .. " ("
                .. (statsData.weaponCritChance or 0)
                .. "%) |",
            "| | Spell Crit | "
                .. FormatNumber(statsData.spellCritRating or 0)
                .. " ("
                .. (statsData.spellCritChance or 0)
                .. "%) |",
            "| ⚔️ **Penetration** | Physical | " .. FormatNumber(statsData.physicalPenetration or 0) .. " |",
            "| | Spell | " .. FormatNumber(statsData.spellPenetration or 0) .. " |",
            "| 🛡️ **Defensive** | Physical Resist | "
                .. FormatNumber(statsData.physicalResist or 0)
                .. " ("
                .. (statsData.physicalMitigation or 0)
                .. "%) |",
            "| | Spell Resist | "
                .. FormatNumber(statsData.spellResist or 0)
                .. " ("
                .. (statsData.spellMitigation or 0)
                .. "%) |",
            "| ♻️ **Recovery** | Health | " .. FormatNumber(statsData.healthRecovery or 0) .. " |",
            "| | Magicka | " .. FormatNumber(statsData.magickaRecovery or 0) .. " |",
            "| | Stamina | " .. FormatNumber(statsData.staminaRecovery or 0) .. " |",
            "",
        }
        markdown = markdown .. table.concat(statRows, "\n") .. "\n"
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
-- BUFFS
-- =====================================================

local function GenerateBuffs(buffsData)
    InitializeUtilities()

    local markdown = ""

    if not buffsData.food and not buffsData.potion and not (buffsData.other and #buffsData.other > 0) then
        return ""
    end

    markdown = markdown .. "### 🍖 Active Buffs\n\n"
    if buffsData.food then
        local foodLink = CreateBuffLink(buffsData.food)
        markdown = markdown .. "**Food:** " .. foodLink .. "  \n"
    end
    if buffsData.potion then
        local potionLink = CreateBuffLink(buffsData.potion)
        markdown = markdown .. "**Potion:** " .. potionLink .. "  \n"
    end
    if buffsData.other and #buffsData.other > 0 then
        for _, buffName in ipairs(buffsData.other) do
            local buffLink = CreateBuffLink(buffName)
            markdown = markdown .. "**Other:** " .. buffLink .. "  \n"
        end
    end
    markdown = markdown .. "\n"

    return markdown
end

-- =====================================================
-- ADVANCED STATS
-- =====================================================

local function GenerateAdvancedStats(statsData)
    InitializeUtilities()

    if not statsData or not statsData.advanced then
        return ""
    end

    local advanced = statsData.advanced
    local markdown = ""

    -- Helper for formatting numbers
    local function fmt(val)
        return FormatNumber(val or 0)
    end

    -- Helper for formatting percentages
    local function fmtPct(val)
        return (val or 0) .. "%"
    end

    -- Helper for damage/healing bonuses
    local function fmtBonus(bonus)
        if not bonus then
            return "0"
        end
        local flat = bonus.flat or 0
        local percent = bonus.percent or 0

        if flat == 0 and percent == 0 then
            return "0"
        end
        if flat == 0 then
            return percent .. "%"
        end
        if percent == 0 then
            return fmt(flat)
        end
        return string.format("%s (+%s%%)", fmt(flat), percent)
    end

    markdown = markdown .. '\n<a id="advanced-stats"></a>\n\n### Advanced Stats\n\n'

    -- Grid Layout Start
    markdown = markdown
        .. '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;">\n'

    -- Column 1: Core Abilities
    markdown = markdown .. "<div>\n\n"
    markdown = markdown .. "| **Ability** | **Cost/Value** |\n"
    markdown = markdown .. "|:---|---:|\n"
    if advanced.core then
        local core = advanced.core
        markdown = markdown .. "| ⚔️ **Light Attack** | " .. fmt(core.lightAttackDamage) .. " dmg |\n"
        markdown = markdown .. "| ⚔️ **Heavy Attack** | " .. fmt(core.heavyAttackDamage) .. " dmg |\n"

        local bashStr = ""
        if (core.bashCost or 0) > 0 then
            bashStr = fmt(core.bashCost) .. " cost, "
        end
        markdown = markdown .. "| ⚔️ **Bash** | " .. bashStr .. fmt(core.bashDamage) .. " dmg |\n"

        local blockStr = ""
        if (core.blockCost or 0) > 0 then
            blockStr = fmt(core.blockCost) .. " cost, "
        end
        markdown = markdown
            .. "| 🛡️ **Block** | "
            .. blockStr
            .. fmtPct(core.blockMitigation)
            .. " mit, "
            .. fmtPct(core.blockSpeed)
            .. " spd |\n"

        if (core.breakFreeCost or 0) > 0 then
            markdown = markdown .. "| 🔓 **Break Free** | " .. fmt(core.breakFreeCost) .. " cost |\n"
        end
        if (core.dodgeRollCost or 0) > 0 then
            markdown = markdown .. "| 🏃 **Dodge Roll** | " .. fmt(core.dodgeRollCost) .. " cost |\n"
        end

        local sneakStr = ""
        if (core.sneakCost or 0) > 0 then
            sneakStr = fmt(core.sneakCost) .. " cost, "
        end
        markdown = markdown .. "| 🐾 **Sneak** | " .. sneakStr .. fmtPct(core.sneakSpeed) .. " spd |\n"

        local sprintStr = ""
        if (core.sprintCost or 0) > 0 then
            sprintStr = fmt(core.sprintCost) .. " cost, "
        end
        markdown = markdown .. "| 🏃‍♂️ **Sprint** | " .. sprintStr .. fmtPct(core.sprintSpeed) .. " spd |\n"
    end
    markdown = markdown .. "\n</div>\n"

    -- Column 2: Resistances
    markdown = markdown .. "<div>\n\n"
    markdown = markdown .. "| **Resistance** | **Value** |\n"
    markdown = markdown .. "|:---|---:|\n"
    if advanced.resistances then
        local res = advanced.resistances
        -- Use the calculated percent if available (new structure), otherwise fallback
        local function getResVal(key)
            if type(res[key]) == "table" then
                return fmtPct(res[key].percent)
            else
                return fmt(res[key]) -- Fallback for old data structure
            end
        end

        markdown = markdown .. "| 🔥 **Flame** | " .. getResVal("flame") .. " |\n"
        markdown = markdown .. "| ⚡ **Shock** | " .. getResVal("shock") .. " |\n"
        markdown = markdown .. "| ❄️ **Frost** | " .. getResVal("frost") .. " |\n"
        markdown = markdown .. "| 🔮 **Magic** | " .. getResVal("magic") .. " |\n"
        markdown = markdown .. "| 🦠 **Disease** | " .. getResVal("disease") .. " |\n"
        markdown = markdown .. "| ☠️ **Poison** | " .. getResVal("poison") .. " |\n"
        markdown = markdown .. "| 🩸 **Bleed** | " .. getResVal("bleed") .. " |\n"
    end
    markdown = markdown .. "\n</div>\n"

    -- Column 3: Damage Bonuses
    markdown = markdown .. "<div>\n\n"
    markdown = markdown .. "| **Damage Type** | **Bonus** |\n"
    markdown = markdown .. "|:---|---:|\n"
    if advanced.damage then
        local dmg = advanced.damage
        markdown = markdown .. "| 💥 **Critical Damage** | " .. fmtPct(dmg.criticalDamage) .. " |\n"
        markdown = markdown .. "| ⚔️ **Physical** | " .. fmtBonus(dmg.physical) .. " |\n"
        markdown = markdown .. "| 🔥 **Flame** | " .. fmtBonus(dmg.flame) .. " |\n"
        markdown = markdown .. "| ⚡ **Shock** | " .. fmtBonus(dmg.shock) .. " |\n"
        markdown = markdown .. "| ❄️ **Frost** | " .. fmtBonus(dmg.frost) .. " |\n"
        markdown = markdown .. "| 🔮 **Magic** | " .. fmtBonus(dmg.magic) .. " |\n"
        markdown = markdown .. "| 🦠 **Disease** | " .. fmtBonus(dmg.disease) .. " |\n"
        markdown = markdown .. "| ☠️ **Poison** | " .. fmtBonus(dmg.poison) .. " |\n"
        markdown = markdown .. "| 🩸 **Bleed** | " .. fmtBonus(dmg.bleed) .. " |\n"
        markdown = markdown .. "| 🌌 **Oblivion** | " .. fmtBonus(dmg.oblivion) .. " |\n"
    end
    markdown = markdown .. "\n</div>\n"

    -- Column 4: Healing Bonuses
    markdown = markdown .. "<div>\n\n"
    markdown = markdown .. "| **Healing** | **Value** |\n"
    markdown = markdown .. "|:---|---:|\n"
    if advanced.healing then
        local heal = advanced.healing
        markdown = markdown .. "| 💚 **Healing Done** | " .. fmtBonus(heal.healingDone) .. " |\n"
        markdown = markdown .. "| 💖 **Healing Taken** | " .. fmtBonus(heal.healingTaken) .. " |\n"
        markdown = markdown .. "| ✨ **Critical Healing** | " .. fmtPct(heal.criticalHealing) .. " |\n"
    end
    markdown = markdown .. "\n</div>\n"

    -- Grid Layout End
    markdown = markdown .. "</div>\n\n"

    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateCombatStats = GenerateCombatStats
CM.generators.sections.GenerateBuffs = GenerateBuffs
CM.generators.sections.GenerateAdvancedStats = GenerateAdvancedStats

-- =====================================================
-- CHARACTER STATS WRAPPER
-- =====================================================

local function GenerateCharacterStats(statsData)
    if not statsData then
        CM.Warn("GenerateCharacterStats: statsData is nil")
        return ""
    end

    CM.DebugPrint("STATS_GEN", "GenerateCharacterStats called")

    local result = ""

    -- Generate Combat Stats (inline=true for table-only output)
    local combatStats = GenerateCombatStats(statsData, true)
    CM.DebugPrint("STATS_GEN", string.format("Combat stats generated: %d chars", #combatStats))
    result = result .. combatStats

    -- Generate Advanced Stats
    local advancedStats = GenerateAdvancedStats(statsData)
    CM.DebugPrint(
        "STATS_GEN",
        string.format(
            "Advanced stats generated: %d chars, has advanced: %s",
            #advancedStats,
            tostring(statsData.advanced ~= nil)
        )
    )
    result = result .. advancedStats

    CM.DebugPrint("STATS_GEN", string.format("Total GenerateCharacterStats output: %d chars", #result))
    return result
end

CM.generators.sections.GenerateCharacterStats = GenerateCharacterStats
