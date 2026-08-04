-- CharacterMarkdown - Markdown Generation Engine
-- Generates markdown in standard format (GitHub-compatible)

local CM = CharacterMarkdown

-- Import section generators (these modules register themselves to CM.generators.sections)

-- Get references to imported section generators for convenience
local function GetGenerators()
    return {
        -- Character sections
        GenerateHeader = CM.generators.sections.GenerateHeader,
        GenerateGeneral = CM.generators.sections.GenerateGeneral,
        GenerateQuickStats = CM.generators.sections.GenerateQuickStats,
        GenerateOverviewSection = CM.generators.sections.GenerateOverviewSection,
        GenerateCharacterStats = CM.generators.sections.GenerateCharacterStats,
        GenerateCustomNotes = CM.generators.sections.GenerateCustomNotes,
        GenerateDynamicTableOfContents = CM.generators.sections.GenerateDynamicTableOfContents,

        -- Economy sections
        GenerateCurrency = CM.generators.sections.GenerateCurrency,
        GenerateRidingSkills = CM.generators.sections.GenerateRidingSkills,
        GenerateInventory = CM.generators.sections.GenerateInventory,
        GeneratePvP = CM.generators.sections.GeneratePvP,

        -- Equipment sections
        GenerateSkillBars = CM.generators.sections.GenerateSkillBars,
        GenerateSkillBarsOnly = CM.generators.sections.GenerateSkillBarsOnly,
        GenerateSkillMorphs = CM.generators.sections.GenerateSkillMorphs,
        GenerateEquipment = CM.generators.sections.GenerateEquipment,
        GenerateSkills = CM.generators.sections.GenerateSkills,
        GenerateProgressSummary = CM.generators.sections.GenerateProgressSummary,
        GenerateCharacterProgress = CM.generators.sections.GenerateCharacterProgress,

        -- Combat sections
        GenerateCombatStats = CM.generators.sections.GenerateCombatStats,
        GenerateAdvancedStats = CM.generators.sections.GenerateAdvancedStats,
        GenerateBuffs = CM.generators.sections.GenerateBuffs,

        -- Content sections
        GenerateDLCAccess = CM.generators.sections.GenerateDLCAccess,
        GenerateMundus = CM.generators.sections.GenerateMundus,
        GenerateChampionPoints = CM.generators.sections.GenerateChampionPoints,
        GenerateChampionDiagram = CM.generators.sections.GenerateChampionDiagram,
        GenerateCollectibles = CM.generators.sections.GenerateCollectibles,
        GenerateCrafting = CM.generators.sections.GenerateCrafting,
        GenerateStyles = CM.generators.sections.GenerateStyles,
        GenerateAchievements = CM.generators.sections.GenerateAchievements,
        GenerateAntiquities = CM.generators.sections.GenerateAntiquities,
        GenerateQuests = CM.generators.sections.GenerateQuests,
        -- GenerateEquipmentEnhancement = CM.generators.sections.GenerateEquipmentEnhancement,  -- DISABLED: moved to DISABLED/

        -- World sections
        GenerateWorldProgress = CM.generators.sections.GenerateWorldProgress,

        -- Tier 3-5 sections
        GenerateTitlesHousing = CM.generators.sections.GenerateTitlesHousing,
        GenerateTitles = CM.generators.sections.GenerateTitles,
        GeneratePvPStats = CM.generators.sections.GeneratePvPStats,
        GenerateArmoryBuilds = CM.generators.sections.GenerateArmoryBuilds,
        GenerateUndauntedPledges = CM.generators.sections.GenerateUndauntedPledges,
        GenerateGuilds = CM.generators.sections.GenerateGuilds,
        GenerateMail = CM.generators.sections.GenerateMail,

        -- Companion sections
        GenerateCompanion = CM.generators.sections.GenerateCompanion,

        -- Footer
        GenerateFooter = CM.generators.sections.GenerateFooter,
    }
end

-- =====================================================
-- ERROR AGGREGATION SYSTEM
-- =====================================================

local collectionErrors = {}

local function SafeCollect(collectorName, collectorFunc)
    -- Check if function exists before trying to call it
    if not collectorFunc or type(collectorFunc) ~= "function" then
        -- Silently return empty data if collector not available
        return {} -- Return empty data if function doesn't exist
    end

    local success, result = pcall(collectorFunc)

    if not success then
        table.insert(collectionErrors, {
            collector = collectorName,
            error = tostring(result),
        })
        CM.Error(string.format("[FAIL] Collect %s failed: %s", collectorName, tostring(result)))
        return {} -- Return empty data on failure
    end

    return result
end

local function ReportCollectionErrors()
    if #collectionErrors == 0 then
        return
    end

    -- Errors are logged to saved variables but not spammed to chat
    -- Users can check the error log if needed
    CM.DebugPrint("ERRORS", string.format("Encountered %d error(s) during data collection", #collectionErrors))
    for i, err in ipairs(collectionErrors) do
        CM.DebugPrint("ERRORS", string.format("  %d. %s: %s", i, err.collector, err.error))
    end
end

local function ResetCollectionErrors()
    collectionErrors = {}
end

-- =====================================================
-- SETTINGS HELPER
-- =====================================================

-- Helper function to check if a setting is enabled
-- Settings are guaranteed to be true or false (never nil) via CM.GetSettings()
-- Returns true only if setting is explicitly true, false otherwise
local function IsSettingEnabled(settings, settingName, defaultValue)
    if not settings then
        CM.DebugPrint(
            "SETTINGS",
            string.format(
                "IsSettingEnabled: settings table is nil for '%s', using default: %s",
                settingName,
                tostring(defaultValue)
            )
        )
        return defaultValue
    end
    local value = settings[settingName]
    -- Settings should never be nil (CM.GetSettings() ensures this), but handle it defensively
    if value == nil then
        CM.DebugPrint(
            "SETTINGS",
            string.format(
                "IsSettingEnabled: '%s' is nil (should never happen!), using default: %s",
                settingName,
                tostring(defaultValue)
            )
        )
        return defaultValue
    end
    -- Explicitly check for true - false means disabled
    return value == true
end

-- =====================================================
-- SECTION REGISTRY PATTERN
-- =====================================================

-- Use canonical GenerateAnchor from AdvancedMarkdown.lua
-- Generates standard markdown anchor from section title text
-- GitHub anchors: lowercase, spaces to hyphens, remove emojis and special chars
-- Must match the logic in GenerateDynamicTableOfContents
local GenerateAnchor = CM.utils.markdown and CM.utils.markdown.GenerateAnchor
    or function(text)
        -- Fallback implementation if utils not loaded yet
        if not text then
            return ""
        end
        local anchor = ""
        for i = 1, #text do
            local byte = text:byte(i)
            if
                (byte >= 48 and byte <= 57)
                or (byte >= 65 and byte <= 90)
                or (byte >= 97 and byte <= 122)
                or byte == 32
                or byte == 45
            then
                anchor = anchor .. text:sub(i, i)
            end
        end
        anchor = anchor:lower():gsub("%s+", "-")
        anchor = anchor:gsub("^%-+", ""):gsub("%-+$", ""):gsub("%-%-+", "-")
        return anchor
    end

-- Helper function to create a section definition
-- This simplifies section creation and ensures consistent structure
local function CreateSection(name, tocEntry, condition, generator, options)
    options = options or {}
    return {
        name = name,
        tocEntry = tocEntry,
        condition = condition,
        generator = generator,
        dynamicTOC = options.dynamicTOC or false,
    }
end

-- Section configuration: defines all sections with their conditions
-- Settings parameter must be the flattened settings table
--
-- STRUCTURE:
--   Each section has:
--     - name: Unique identifier
--     - tocEntry: Table of Contents entry (nil if not in TOC)
--     - condition: Boolean or function returning boolean
--     - generator: Function that returns markdown string
--     - dynamicTOC: Optional flag for special TOC handling
local function GetSectionRegistry(settings, gen, data)
    -- Debug: Log settings at registry creation time (lazy evaluation)
    CM.DebugPrint("REGISTRY", function()
        return string.format(
            "Building section registry - includeChampionPoints: %s, includeChampionDiagram: %s",
            tostring(settings.includeChampionPoints),
            tostring(settings.includeChampionDiagram)
        )
    end)

    local registry = {
        -- Header (controlled by includeHeader setting, not in TOC)
        {
            name = "Header",
            tocEntry = nil, -- Not in TOC
            condition = IsSettingEnabled(settings, "includeHeader", true),
            generator = function()
                return gen.GenerateHeader(data.character, data.cp)
            end,
        },

        -- Table of Contents (non-Discord/Quick only, not in TOC itself)
        {
            name = "TableOfContents",
            tocEntry = nil, -- Not in TOC
            condition = function()
                return IsSettingEnabled(settings, "includeTableOfContents", true)
            end,
            generator = function()
                -- TOC will be generated dynamically from this registry
                -- Note: registry reference will be injected after registry is built
                return "" -- Will be replaced during generation
            end,
            dynamicTOC = true, -- Flag to indicate this needs special handling
        },

        -- ========================================
        -- SECTIONS ORGANIZED TO MATCH SETTINGS PANEL ORDER
        -- ========================================
        -- Sections are ordered to match the settings panel organization
        -- This ensures the TOC reflects the same structure as the settings UI

        -- ========================================
        -- OVERVIEW & CUSTOM NOTES (Special sections)
        -- ========================================

        -- 1. 📋 Overview (Quick Stats Summary) - Uses multiple collectors
        {
            name = "QuickStats",
            tocEntry = {
                title = "📋 Overview",
                subsections = { "General", "Currency" },
            },
            condition = function()
                -- Check if any subsection is enabled
                return IsSettingEnabled(settings, "includeGeneral", true)
                    or IsSettingEnabled(settings, "includeCurrency", true)
            end,
            generator = function()
                -- Pass attributes data through settings for GenerateGeneral
                local settingsWithData = {}
                for k, v in pairs(settings) do
                    settingsWithData[k] = v
                end
                settingsWithData._collectedData = {
                    characterAttributes = data.characterAttributes,
                }
                return gen.GenerateQuickStats(
                    data.character,
                    data.stats,
                    nil, -- format
                    data.equipment,
                    data.progression,
                    data.currency,
                    data.cp,
                    data.inventory,
                    data.location,
                    data.buffs,
                    data.pvp,
                    data.titlesHousing,
                    data.mundus,
                    data.riding,
                    settingsWithData
                )
            end,
        },

        -- 1a. Custom Notes (appears immediately after Overview, requires both setting enabled AND content present)
        {
            name = "CustomNotes",
            tocEntry = {
                title = "📝 Build Notes",
            },
            condition = IsSettingEnabled(settings, "includeBuildNotes", true)
                and data.customNotes
                and data.customNotes ~= "",
            generator = function()
                return gen.GenerateCustomNotes(data.customNotes, nil, data.equipment, data.skillBar)
            end,
        },

        -- ========================================
        -- COMBAT ARSENAL (Composite section grouping multiple collectors)
        -- ========================================

        -- 2. ⚔️ Combat Arsenal (Character Stats + Optional Skill Bars)
        -- Uses: Combat.lua - CollectCombatStatsData, Skills.lua - CollectSkillBarData
        {
            name = "CombatArsenal",
            tocEntry = {
                title = "⚔️ Combat Arsenal",
                subsections = {
                    "Character Stats",
                    "Advanced Stats",
                    "Skill bars",
                },
            },
            condition = function()
                local basicEnabled = IsSettingEnabled(settings, "includeBasicCombatStats", true)
                local advancedEnabled = IsSettingEnabled(settings, "includeAdvancedStats", true)
                local barsEnabled = IsSettingEnabled(settings, "includeSkillBars", true)

                return basicEnabled or advancedEnabled or barsEnabled
            end,
            generator = function()
                -- Ensure stats data exists
                if not data.stats then
                    if CM.collectors and CM.collectors.CollectCombatStatsData then
                        data.stats = CM.collectors.CollectCombatStatsData()
                    end
                end

                -- Start with section header
                local output = "## ⚔️ Combat Arsenal\n\n"

                -- Generate Basic Combat Stats
                if IsSettingEnabled(settings, "includeBasicCombatStats", true) then
                    CM.DebugPrint("STATS_GEN", "Generating Basic Combat Stats...")
                    if data.stats then
                        local success, result = pcall(gen.GenerateCombatStats, data.stats, true) -- inline=true
                        if success then
                            local statsOutput = result or ""
                            if statsOutput ~= "" then
                                CM.DebugPrint(
                                    "STATS_GEN",
                                    string.format("✓ Generated %d characters of basic stats", #statsOutput)
                                )
                                output = output .. statsOutput
                            end
                        else
                            CM.Error(string.format("Basic Combat Stats failed: %s", tostring(result)))
                        end
                    end
                end

                -- Generate Advanced Stats
                if IsSettingEnabled(settings, "includeAdvancedStats", true) then
                    CM.DebugPrint("STATS_GEN", "Generating Advanced Stats...")
                    if data.stats then
                        local success, result = pcall(gen.GenerateAdvancedStats, data.stats)
                        if success then
                            local advStatsOutput = result or ""
                            if advStatsOutput ~= "" then
                                CM.DebugPrint(
                                    "STATS_GEN",
                                    string.format("✓ Generated %d characters of advanced stats", #advStatsOutput)
                                )
                                output = output .. advStatsOutput
                            end
                        else
                            CM.Error(string.format("Advanced Stats failed: %s", tostring(result)))
                        end
                    end
                end

                -- Generate Skill Bars (optional)
                if IsSettingEnabled(settings, "includeSkillBars", true) then
                    local skillBarData = data.skillBar or {}
                    local success, result = pcall(gen.GenerateSkillBarsOnly, skillBarData)

                    if success then
                        output = output .. (result or "")
                    else
                        CM.Error(string.format("Skill bars failed: %s", tostring(result)))
                    end
                end

                -- If we generated nothing, return empty to skip section
                return output
            end,
        },

        -- ========================================
        -- EQUIPMENT (Equipment.lua collector)
        -- ========================================
        -- Uses: Equipment.lua - CollectEquipmentData
        -- Setting: includeEquipment

        -- 2a. Equipment & Active Sets (separate section)
        {
            name = "Equipment",
            tocEntry = {
                title = "⚔️ Equipment & Active Sets",
            },
            condition = IsSettingEnabled(settings, "includeEquipment", true),
            generator = function()
                local equipmentData = data.equipment or {}
                local success, result = pcall(gen.GenerateEquipment, equipmentData, false)
                if success then
                    return result or ""
                else
                    -- Silently fail - error already logged
                    return ""
                end
            end,
        },

        -- ========================================
        -- CHAMPION POINTS (Champion.lua collector)
        -- ========================================
        -- Uses: Champion.lua - CollectChampionPointData
        -- Settings: includeChampionPoints, includeChampionDiagram

        -- 2b. ⭐ Champion Points (part of Combat Arsenal)
        {
            name = "ChampionPoints",
            tocEntry = {
                title = "⭐ Champion Points",
            },
            condition = function()
                -- Re-evaluate condition at generation time to ensure we have latest settings
                local currentSettings = CM.GetSettings() or settings
                return IsSettingEnabled(currentSettings, "includeChampionPoints", true)
            end,
            generator = function()
                local currentSettings = CM.GetSettings() or settings
                local markdown = ""

                local cpSuccess, cpResult = pcall(gen.GenerateChampionPoints, data.cp)
                if not cpSuccess then
                    CM.Error(string.format("Champion Points failed: %s", tostring(cpResult)))
                    cpResult = "## ⭐ Champion Points\n\n*Error generating champion point data*\n\n"
                else
                    cpResult = cpResult or ""
                end

                local diagramEnabled = IsSettingEnabled(currentSettings, "includeChampionDiagram", false)
                if diagramEnabled then
                    if cpResult ~= "" and cpResult:match("%-%-%-\n\n$") then
                        cpResult = cpResult:gsub("%-%-%-\n\n$", "")
                    elseif cpResult ~= "" and cpResult:match("<hr%s*/>\n\n$") then
                        cpResult = cpResult:gsub("<hr%s*/>\n\n$", "")
                    end

                    markdown = markdown .. cpResult
                    local diagramSuccess, diagramResult = pcall(gen.GenerateChampionDiagram, data.cp)
                    if diagramSuccess then
                        markdown = markdown .. (diagramResult or "")
                    else
                        CM.Error(string.format("Champion diagram failed: %s", tostring(diagramResult)))
                    end
                else
                    markdown = markdown .. cpResult
                end

                return markdown
            end,
        },

        -- ========================================
        -- SKILLS (Skills.lua collectors)
        -- ========================================
        -- Uses: Skills.lua - CollectSkillBarData, CollectSkillProgressionData, CollectSkillMorphsData
        -- Settings: includeSkillBars, includeSkills, includeSkillMorphs

        -- 2c. Character Progress (Summary + Skill Morphs + Status-Organized Progression)
        {
            name = "CharacterProgress",
            tocEntry = {
                title = "📜 Character Progress",
            },
            condition = IsSettingEnabled(settings, "includeSkills", true),
            generator = function()
                local skillProgressionData = data.skill or {}
                -- Only pass morph data if includeSkillMorphs is enabled (default: false)
                local skillMorphsData = IsSettingEnabled(settings, "includeSkillMorphs", false)
                        and (data.skillMorphs or {})
                    or nil

                -- Use the new consolidated generator
                return gen.GenerateCharacterProgress(skillProgressionData, skillMorphsData)
            end,
        },

        -- ========================================
        -- PVP (PvP.lua collector) - Settings Panel Order: 8
        -- ========================================
        -- Uses: PvP.lua - CollectPvPData
        -- Settings: includePvP, includePvPStats, showPvPProgression, showCampaignRewards, showLeaderboards, showBattlegrounds, showDetailedPvP, showAllianceWarSkills

        -- ⚔️ PvP Profile (includes Alliance War skills conditionally)
        {
            name = "PvPStats",
            tocEntry = {
                title = "⚔️ PvP",
                subsections = IsSettingEnabled(settings, "showAllianceWarSkills", false) and { "Alliance War Skills" }
                    or nil,
            },
            condition = IsSettingEnabled(settings, "includePvPStats", false)
                or IsSettingEnabled(settings, "includePvP", false)
                or IsSettingEnabled(settings, "showAllianceWarSkills", false)
                or IsSettingEnabled(settings, "includeVengeance", false),
            generator = function()
                -- Pass skill progression data so PvP section can include Alliance War skills
                local skillProgressionData = data.skill or {}
                -- Use unified pvp structure: data.pvp.basic and data.pvp.stats
                local pvpBasic = data.pvp and data.pvp.basic or nil
                local pvpStats = data.pvp and data.pvp.stats or nil
                local markdown = gen.GeneratePvPStats(pvpBasic, pvpStats, skillProgressionData, settings) or ""
                if data.pvp and data.pvp.vengeance and data.pvp.vengeance.available then
                    local v = data.pvp.vengeance
                    markdown = markdown .. "### Vengeance Loadout\n\n"
                    if v.equippedRole then
                        markdown = markdown
                            .. "| Field | Value |\n|:------|:------|\n| **Equipped Role** | "
                            .. (v.equippedRole.name or "Unknown")
                            .. " |\n| **Perks Listed** | "
                            .. tostring(v.equippedRole.perkCount or 0)
                            .. " |\n\n"
                        if v.equippedRole.perks and #v.equippedRole.perks > 0 then
                            markdown = markdown .. "| Perk |\n|:-----|\n"
                            local limit = math.min(12, #v.equippedRole.perks)
                            for i = 1, limit do
                                markdown = markdown .. "| " .. v.equippedRole.perks[i].name .. " |\n"
                            end
                            markdown = markdown .. "\n"
                        end
                    else
                        markdown = markdown .. "*Vengeance roles available: " .. tostring(#(v.roles or {})) .. "*\n\n"
                    end
                end
                return markdown
            end,
        },

        -- ========================================
        -- COMPANION (Companion.lua collector) - Settings Panel Order: 9
        -- ========================================
        -- Uses: Companion.lua - CollectCompanionData
        -- Setting: includeCompanion

        -- 👥 Companions (standalone section, moved from Combat Arsenal)
        {
            name = "Companion",
            tocEntry = {
                title = "👥 Companions",
            },
            condition = IsSettingEnabled(settings, "includeCompanion", true),
            generator = function()
                return gen.GenerateCompanion(data.companion)
            end,
        },

        -- 👑 Titles (standalone when Collectibles is off)
        {
            name = "Titles",
            tocEntry = {
                title = "👑 Titles",
            },
            condition = function()
                if not IsSettingEnabled(settings, "includeTitlesHousing", false) then
                    return false
                end
                if IsSettingEnabled(settings, "includeCollectibles", false) then
                    return false
                end
                return data.titlesHousing ~= nil
            end,
            generator = function()
                local titlesData = data.titlesHousing and data.titlesHousing.titles or {}
                return gen.GenerateTitles(titlesData)
            end,
        },

        -- ========================================
        -- COLLECTIBLES (Collectibles.lua collector) - Settings Panel Order: 10
        -- ========================================
        -- Uses: Collectibles.lua - CollectCollectiblesData, CollectDLCAccess, CollectHousingData
        -- Settings: includeCollectibles, showCollectiblesDetailed, includeDLCAccess, includeTitlesHousing

        -- 🎨 Collectibles (includes Accessible Content, Titles & Housing as collapsible subsections)
        {
            name = "Collectibles",
            tocEntry = {
                title = "🎨 Collectibles",
            },
            condition = function()
                if not IsSettingEnabled(settings, "includeCollectibles", true) then
                    return false
                end
                -- Check if there is any collectible data to show
                local hasData = false
                if data.collectibles then
                    -- Check for simple counts
                    if
                        (data.collectibles.mounts and data.collectibles.mounts > 0)
                        or (data.collectibles.pets and data.collectibles.pets > 0)
                        or (data.collectibles.costumes and data.collectibles.costumes > 0)
                        or (data.collectibles.houses and data.collectibles.houses > 0)
                    then
                        hasData = true
                    end
                    -- Check for detailed categories
                    if not hasData and data.collectibles.categories then
                        for _, cat in pairs(data.collectibles.categories) do
                            if cat and cat.total and cat.total > 0 then
                                hasData = true
                                break
                            end
                        end
                    end
                end
                -- Check for DLC data if enabled
                if not hasData and IsSettingEnabled(settings, "includeDLCAccess", false) and data.dlc then
                    if
                        (data.dlc.accessible and #data.dlc.accessible > 0)
                        or (data.dlc.locked and #data.dlc.locked > 0)
                        or data.dlc.hasESOPlus
                    then
                        hasData = true
                    end
                end
                -- Check for Titles/Housing if those toggles are enabled
                if not hasData and data.titlesHousing then
                    local titles = data.titlesHousing.titles
                    local housing = data.titlesHousing.housing
                    if IsSettingEnabled(settings, "includeTitlesHousing", false) then
                        if (titles and (titles.total or 0) > 0)
                            or (titles and titles.current and titles.current ~= "")
                            or (titles and titles.owned and #titles.owned > 0)
                        then
                            hasData = true
                        end
                    end
                    if not hasData and IsSettingEnabled(settings, "includeHousing", false) then
                        if housing and (housing.total or 0) > 0 then
                            hasData = true
                        end
                    end
                end
                return hasData
            end,
            generator = function()
                local lorebooksData = (data.worldProgress and data.worldProgress.lorebooks) or nil
                return gen.GenerateCollectibles(
                    data.collectibles,
                    nil,
                    data.dlc,
                    lorebooksData,
                    data.titlesHousing,
                    data.riding
                )
            end,
        },

        -- ========================================
        -- INVENTORY (Inventory.lua collector) - Settings Panel Order: 6
        -- ========================================
        -- Uses: Inventory.lua - CollectInventoryData, CollectCurrencyData
        -- Settings: includeInventory, showBagContents, showBankContents, showCraftingBagContents, includeCurrency

        -- 🎒 Inventory
        {
            name = "Inventory",
            tocEntry = {
                title = "🎒 Inventory",
            },
            condition = IsSettingEnabled(settings, "includeInventory", true),
            generator = function()
                return gen.GenerateInventory(data.inventory)
            end,
        },

        -- ========================================
        -- ACHIEVEMENTS (Achievements.lua collector) - Settings Panel Order: 11
        -- ========================================
        -- Uses: Achievements.lua - CollectAchievementsData
        -- Settings: includeAchievements, showAllAchievements

        -- 🏆 Achievements (standalone section)
        {
            name = "Achievements",
            tocEntry = {
                title = "🏆 Achievements",
            },
            condition = IsSettingEnabled(settings, "includeAchievements", false),
            generator = function()
                local markdown = ""

                if not data.achievements then
                    return markdown
                end

                -- Check if we should show all achievements or filter to in-progress only
                local showAllAchievements = settings.showAllAchievements ~= false -- Default to true (show all)

                if showAllAchievements then
                    -- Show all achievements (full data with categories)
                    markdown = markdown .. gen.GenerateAchievements(data.achievements)
                else
                    -- Filter to show only in-progress achievements
                    local inProgressData = {
                        summary = data.achievements.summary,
                        inProgress = data.achievements.inProgress or {},
                        categories = data.achievements.categories, -- Include categories for consistency
                    }
                    markdown = markdown .. gen.GenerateAchievements(inProgressData)
                end

                return markdown
            end,
        },

        -- ========================================
        -- WORLD PROGRESS (World.lua collector)
        -- ========================================
        {
            name = "WorldProgress",
            tocEntry = {
                title = "🌍 World Progress",
            },
            condition = IsSettingEnabled(settings, "includeWorldProgress", false)
                and data.worldProgress ~= nil,
            generator = function()
                return gen.GenerateWorldProgress(data.worldProgress) or ""
            end,
        },

        -- ========================================
        -- APPEARANCE (Appearance.lua collector)
        -- ========================================
        {
            name = "Appearance",
            tocEntry = {
                title = "🎨 Appearance",
            },
            condition = IsSettingEnabled(settings, "includeAppearance", false)
                and data.appearance ~= nil,
            generator = function()
                local GenerateAppearance = CM.generators.sections.GenerateAppearance
                if GenerateAppearance then
                    return GenerateAppearance(data.appearance) or ""
                end
                return ""
            end,
        },

        -- ========================================
        -- ANTIQUITIES (Antiquities.lua collector) - Settings Panel Order: 12
        -- ========================================
        -- Uses: Antiquities.lua - CollectAntiquitiesData
        -- Settings: includeAntiquities, showAntiquitiesDetailed

        -- 🏺 Antiquities (standalone section)
        {
            name = "Antiquities",
            tocEntry = {
                title = "🏺 Antiquities",
            },
            condition = IsSettingEnabled(settings, "includeAntiquities", false)
                and data.antiquities
                and data.antiquities.summary
                and data.antiquities.summary.totalAntiquities > 0,
            generator = function()
                local markdown = ""

                if not data.antiquities then
                    return markdown
                end

                -- Generate antiquities section
                markdown = markdown .. gen.GenerateAntiquities(data.antiquities)

                return markdown
            end,
        },

        -- ========================================
        -- QUESTS (Quests.lua collector) - Settings Panel Order: 13
        -- ========================================
        -- Uses: Quests.lua - CollectQuestJournalData, CollectUndauntedPledgesData
        -- Settings: includeQuests (disabled), includeUndauntedPledges

        -- 📜 Quests (standalone section)
        {
            name = "Quests",
            tocEntry = {
                title = "📝 Quest Progress",
            },
            condition = IsSettingEnabled(settings, "includeQuests", false),
            generator = function()
                local markdown = ""

                if not data.quests or not data.quests.summary then
                    return markdown
                end

                local showAllQuests = settings.showAllQuests ~= false

                if showAllQuests then
                    markdown = markdown .. gen.GenerateQuests(data.quests, format)
                else
                    local activeData = {
                        summary = data.quests.summary,
                        active = data.quests.active or {},
                    }
                    markdown = markdown .. gen.GenerateQuests(activeData, format)
                end

                return markdown
            end,
        },

        -- 🏰 Armory Builds
        {
            name = "ArmoryBuilds",
            tocEntry = {
                title = "🏰 Armory Builds",
            },
            condition = IsSettingEnabled(settings, "includeArmoryBuilds", false),
            generator = function()
                return gen.GenerateArmoryBuilds(data.armoryBuilds or {})
            end,
        },

        -- ========================================
        -- CRAFTING (Crafting.lua collector) - Settings Panel Order: 15
        -- ========================================
        -- Uses: Crafting.lua - CollectCraftingData
        -- Setting: includeCrafting
        {
            name = "Crafting",
            tocEntry = {
                title = "⚒️ Crafting Knowledge",
            },
            condition = IsSettingEnabled(settings, "includeCrafting", true)
                or IsSettingEnabled(settings, "includeMotifs", true)
                or IsSettingEnabled(settings, "includeRecipes", true),
            generator = function()
                return gen.GenerateCrafting(data.crafting)
            end,
        },

        -- ========================================
        -- OUTFIT STYLES (Styles.lua collector)
        -- ========================================
        -- Uses: Styles.lua - CollectStylesData
        -- Setting: includeStyles
        {
            name = "Styles",
            tocEntry = {
                title = "🧥 Outfit Styles",
            },
            condition = IsSettingEnabled(settings, "includeStyles", true),
            generator = function()
                return gen.GenerateStyles(data.styles)
            end,
        },

        -- ========================================
        -- SOCIAL (Social.lua collector) - Settings Panel Order: 16
        -- ========================================
        -- Uses: Social.lua - CollectGuildsData, CollectMailData
        -- Settings: includeGuilds, includeMail

        -- 📬 Mail
        {
            name = "Mail",
            tocEntry = {
                title = "📬 Mail",
            },
            condition = IsSettingEnabled(settings, "includeMail", false),
            generator = function()
                return gen.GenerateMail(data.mail)
            end,
        },

        -- 🏰 Guild Membership (includes Undaunted Active Pledges as subsection)
        {
            name = "Guilds",
            tocEntry = {
                title = "🏰 Guild Membership",
            },
            condition = IsSettingEnabled(settings, "includeGuilds", true),
            generator = function()
                local undauntedPledgesData = nil
                if IsSettingEnabled(settings, "includeUndauntedPledges", true) then
                    undauntedPledgesData = data.undauntedPledges
                end
                return gen.GenerateGuilds(data.guilds, undauntedPledgesData)
            end,
        },

        -- ========================================
        -- COMBAT (Combat.lua collectors)
        -- ========================================
        -- Uses: Combat.lua - CollectCombatStatsData, CollectRoleData, CollectActiveBuffs, CollectMundusData
        -- Settings: includeCombatStats, includeRole, includeBuffs
        -- NOTE: These are shown in Overview table, not as standalone sections

        -- Buffs are shown in Overview when includeBuffs is enabled (no standalone section)
        {
            name = "Buffs",
            tocEntry = nil,
            condition = false,
            generator = function()
                return ""
            end,
        },

        -- Mundus (included in DLC section, not standalone)
        {
            name = "Mundus",
            tocEntry = nil, -- Not shown in TOC (included in DLC section)
            condition = false, -- Always false - Mundus is handled in DLC section
            generator = function() end,
        },
    }

    return registry
end

-- =====================================================
-- MAIN GENERATION FUNCTION
-- =====================================================

local function GenerateMarkdown()
    -- Default to markdown (GitHub style)

    -- Reset error tracking
    ResetCollectionErrors()

    -- Verify collectors are loaded
    if not CM.collectors then
        CM.Error("CM.collectors namespace doesn't exist!")
        CM.Error("The addon did not load correctly. Try /reloadui")
        return "ERROR: Addon not loaded. Type /reloadui and try again."
    end

    -- Check if a critical collector exists (test case)
    if not CM.collectors.CollectCharacterData then
        CM.Error("Collectors not loaded!")
        CM.Error("Available in CM.collectors:")
        for k, v in pairs(CM.collectors) do
            CM.Error("  - " .. k)
        end
        return "ERROR: Collectors not loaded. Type /reloadui and try again."
    end

    -- Get settings before collection so disabled sections skip heavy collectors
    -- CM.GetSettings() merges with defaults to ensure every setting is true or false, never nil
    local settings = CM.GetSettings() or {}

    local function Need(...)
        for i = 1, select("#", ...) do
            local settingName = select(i, ...)
            if IsSettingEnabled(settings, settingName, false) then
                return true
            end
        end
        return false
    end

    -- Optional collectors: only run when at least one consuming section is enabled
    local function MaybeCollect(enabled, name, fn)
        if enabled and fn then
            return SafeCollect(name, fn)
        end
        return nil
    end

    -- Collect data with error handling; skip collectors for disabled sections
    CM.DebugPrint("GENERATOR", "Starting data collection...")

    local needOverview = Need("includeGeneral", "includeCurrency", "includeQuickStats")
    local needCombat = Need("includeBasicCombatStats", "includeAdvancedStats", "includeSkillBars")
    local needSkills = Need("includeSkills", "includeSkillMorphs")
    local needCp = Need("includeChampionPoints", "includeChampionDiagram") or needOverview
    local needPvp = Need("includePvP", "includePvPStats", "showAllianceWarSkills", "includeVengeance")
    local needTitlesHousing = Need("includeTitlesHousing", "includeHousing")
    local needCollectibles = Need("includeCollectibles") or needTitlesHousing
    local needCrafting = Need("includeCrafting", "includeMotifs", "includeRecipes", "includeItemSetCollection")
    local needGuilds = Need("includeGuilds", "includeUndauntedPledges")

    local collectedData = {
        -- Always collect: identity + cheap fields used by header/footer
        character = SafeCollect("CollectCharacterData", CM.collectors.CollectCharacterData),
        characterAttributes = MaybeCollect(
            Need("includeCharacterAttributes") or needOverview,
            "CollectAttributesData",
            CM.collectors.CollectAttributesData
        ),
        dlc = MaybeCollect(
            Need("includeDLCAccess") or needCollectibles,
            "CollectDLCAccess",
            CM.collectors.CollectDLCAccess
        ),
        mundus = MaybeCollect(needOverview or Need("includeBuffs"), "CollectMundusData", CM.collectors.CollectMundusData),
        buffs = MaybeCollect(Need("includeBuffs") or needOverview, "CollectActiveBuffs", CM.collectors.CollectActiveBuffs),
        cp = MaybeCollect(needCp, "CollectChampionPointData", CM.collectors.CollectChampionPointData),
        skillBar = MaybeCollect(Need("includeSkillBars"), "CollectSkillBarData", CM.collectors.CollectSkillBarData),
        skillMorphs = MaybeCollect(
            Need("includeSkillMorphs"),
            "CollectSkillMorphsData",
            CM.collectors.CollectSkillMorphsData
        ),
        stats = MaybeCollect(needCombat, "CollectCombatStatsData", CM.collectors.CollectCombatStatsData),
        equipment = MaybeCollect(
            Need("includeEquipment", "includeBuildNotes"),
            "CollectEquipmentData",
            CM.collectors.CollectEquipmentData
        ),
        skill = MaybeCollect(needSkills, "CollectSkillProgressionData", CM.collectors.CollectSkillProgressionData),
        companion = MaybeCollect(Need("includeCompanion"), "CollectCompanionData", CM.collectors.CollectCompanionData),
        currency = MaybeCollect(
            Need("includeCurrency") or needOverview,
            "CollectCurrencyData",
            CM.collectors.CollectCurrencyData
        ),
        progression = MaybeCollect(
            Need("includeProgression") or needOverview,
            "CollectProgressionData",
            CM.collectors.CollectProgressionData
        ),
        riding = MaybeCollect(
            Need("includeRidingSkills") or needCollectibles,
            "CollectRidingSkillsData",
            CM.collectors.CollectRidingSkillsData
        ),
        inventory = MaybeCollect(Need("includeInventory"), "CollectInventoryData", CM.collectors.CollectInventoryData),
        pvp = MaybeCollect(needPvp or needOverview, "CollectPvPData", CM.collectors.CollectPvPData),
        role = MaybeCollect(Need("includeRole"), "CollectRoleData", CM.collectors.CollectRoleData),
        location = MaybeCollect(
            Need("includeLocation") or needOverview,
            "CollectLocationData",
            CM.collectors.CollectLocationData
        ),
        collectibles = MaybeCollect(
            needCollectibles,
            "CollectCollectiblesData",
            CM.collectors.CollectCollectiblesData
        ),
        crafting = MaybeCollect(needCrafting, "CollectCraftingData", CM.collectors.CollectCraftingData),
        styles = MaybeCollect(Need("includeStyles"), "CollectStylesData", CM.collectors.CollectStylesData),
        achievements = MaybeCollect(
            Need("includeAchievements"),
            "CollectAchievementsData",
            CM.collectors.CollectAchievementsData
        ),
        antiquities = MaybeCollect(
            Need("includeAntiquities"),
            "CollectAntiquitiesData",
            CM.collectors.CollectAntiquitiesData
        ),
        quests = MaybeCollect(Need("includeQuests"), "CollectQuestJournalData", CM.collectors.CollectQuestJournalData),
        titles = MaybeCollect(needTitlesHousing, "CollectTitlesData", CM.collectors.CollectTitlesData),
        housing = MaybeCollect(needTitlesHousing, "CollectHousingData", CM.collectors.CollectHousingData),
        armoryBuilds = MaybeCollect(
            Need("includeArmoryBuilds"),
            "CollectArmoryBuildsData",
            CM.collectors.CollectArmoryBuildsData
        ),
        undauntedPledges = MaybeCollect(
            needGuilds,
            "CollectUndauntedPledgesData",
            CM.collectors.CollectUndauntedPledgesData
        ),
        guilds = MaybeCollect(Need("includeGuilds"), "CollectGuildsData", CM.collectors.CollectGuildsData),
        mail = MaybeCollect(Need("includeMail"), "CollectMailData", CM.collectors.CollectMailData),
        worldProgress = MaybeCollect(
            Need("includeWorldProgress", "includeEndlessDungeon") or Need("includeCollectibles"),
            "CollectWorldProgressData",
            CM.collectors.CollectWorldProgressData
        ),
        appearance = MaybeCollect(
            Need("includeAppearance"),
            "CollectAppearanceData",
            CM.collectors.CollectAppearanceData
        ),
        customNotes = (CM.charData and CM.charData.customNotes)
            or (CharacterMarkdownData and CharacterMarkdownData.customNotes)
            or "",
    }

    -- Add composite data structures
    collectedData.titlesHousing = {
        titles = collectedData.titles,
        housing = collectedData.housing,
        collections = collectedData.collectibles, -- Pass collectibles for furniture collections if needed
    }

    -- Report any collection errors
    ReportCollectionErrors()

    -- Get section generators
    local gen = GetGenerators()

    -- Generate markdown
    CM.DebugPrint("GENERATOR", function()
        return "Generating markdown..."
    end)

    -- Get section registry (pass flattened settings)
    local sections = GetSectionRegistry(settings, gen, collectedData)

    -- Generate all sections based on registry (two-pass: bodies first, then TOC from actual output)
    local function sectionHasContent(result)
        return result and result ~= "" and result:gsub("%s+", "") ~= ""
    end

    local function applySectionFormatting(section, result)
        if not sectionHasContent(result) then
            return nil
        end

        if section.tocEntry and section.tocEntry.title then
            local anchor = GenerateAnchor(section.tocEntry.title)
            if anchor and anchor ~= "" then
                if not result:match("^%s*<a id=") then
                    result = string.format('<a id="%s"></a>\n\n%s', anchor, result)
                    CM.DebugPrint(
                        "MARKDOWN",
                        string.format("Auto-added anchor: #%s for section %s", anchor, section.name)
                    )
                end
            end
        end

        local hasSeparator = result:match("%-%-%-%s*$")
            or result:match("<hr>%s*$")
            or result:match("<hr%s*/>%s*$")

        if not hasSeparator then
            local CreateSeparator = CM.utils and CM.utils.markdown and CM.utils.markdown.CreateSeparator
            if CreateSeparator then
                result = result .. CreateSeparator("hr")
            else
                result = result .. "\n---\n\n"
            end
            CM.DebugPrint("GENERATOR", string.format("Auto-added separator for section %s", section.name))
        end

        return result
    end

    local sectionOutputs = {}

    -- Pass 1: generate section bodies (TOC deferred until outputs are known)
    for _, section in ipairs(sections) do
        local conditionMet = false
        if type(section.condition) == "function" then
            conditionMet = section.condition()
        else
            conditionMet = section.condition
        end

        if conditionMet and not section.dynamicTOC and section.generator and type(section.generator) == "function" then
            CM.DebugPrint("GENERATOR", string.format("Generating: %s", section.name))
            local success, result = pcall(section.generator)
            if success then
                local resultLength = result and #result or 0
                CM.DebugPrint("GENERATOR", string.format("%s: %d chars", section.name, resultLength))

                if section.name == "Equipment" then
                    if not result or result == "" or (result:gsub("%s+", "") == "") then
                        CM.Error(
                            string.format(
                                "CRITICAL: Section '%s' returned empty content, this should never happen!",
                                section.name
                            )
                        )
                        result = "## ⚔️ Equipment & Active Sets\n\n*No equipment data available*\n\n---\n\n"
                    end
                end

                sectionOutputs[section.name] = result or ""
            else
                CM.Error(string.format("[FAIL] Section %s failed: %s", section.name, tostring(result)))
                if section.name == "Equipment" then
                    CM.Error(string.format("CRITICAL: Section '%s' failed, adding placeholder", section.name))
                    sectionOutputs[section.name] =
                        "## ⚔️ Equipment & Active Sets\n\n*Error generating equipment data*\n\n---\n\n"
                else
                    sectionOutputs[section.name] = ""
                end
            end
        end
    end

    -- Build TOC from sections that produced content
    local tocContent = ""
    if gen.GenerateDynamicTableOfContents then
        local success, resultTOC = pcall(gen.GenerateDynamicTableOfContents, sections, nil, sectionOutputs)
        if success then
            tocContent = resultTOC or ""
            CM.DebugPrint(
                "GENERATOR",
                string.format("  ✓ TableOfContents: %d chars (dynamic)", tocContent and #tocContent or 0)
            )
        else
            CM.Error(string.format("Dynamic TOC generation failed: %s", tostring(resultTOC)))
        end
    else
        CM.Error("GenerateDynamicTableOfContents function not found!")
    end

    -- Pass 2: assemble markdown in registry order
    local markdownChunks = {}
    for _, section in ipairs(sections) do
        local conditionMet = false
        if type(section.condition) == "function" then
            conditionMet = section.condition()
        else
            conditionMet = section.condition
        end

        if conditionMet then
            local result
            if section.dynamicTOC then
                result = tocContent
            else
                result = sectionOutputs[section.name]
            end

            local formatted = applySectionFormatting(section, result)
            if formatted then
                table.insert(markdownChunks, formatted)
            elseif not section.dynamicTOC then
                CM.DebugPrint(
                    "GENERATOR",
                    string.format("%s returned EMPTY despite condition=true", section.name)
                )
            end
        end
    end
    -- Markdown generated

    local finalMarkdown = table.concat(markdownChunks)

    -- CRITICAL CHECK: If finalMarkdown is empty at this point, log it
    if finalMarkdown == "" or #finalMarkdown == 0 then
        CM.Error("[ERR] Markdown is EMPTY after section generation!")
        CM.Error("All sections returned empty content or were skipped.")
        CM.Error("Check settings and data collectors; use /markdown debug on for details.")
    end

    -- Footer (controlled by includeFooter setting)
    if IsSettingEnabled(settings, "includeFooter", true) then
        local footerSuccess, footerResult = pcall(gen.GenerateFooter, string.len(finalMarkdown))
        if footerSuccess then
            finalMarkdown = finalMarkdown .. footerResult
            CM.DebugPrint("GENERATOR", string.format("Footer added (%d chars)", #footerResult))
        else
            CM.DebugPrint("GENERATOR", string.format("Failed to generate footer: %s", tostring(footerResult)))
        end
    end

    -- Final markdown complete

    CM.DebugPrint("GENERATOR", function()
        return string.format("Markdown generation complete: %d bytes", string.len(finalMarkdown))
    end)

    -- Store the complete markdown in a variable
    local completeMarkdown = finalMarkdown
    local markdownLength = string.len(completeMarkdown)

    -- Update character data timestamp (markdown/format no longer stored - exceeds ESO 2k char limit and unused)
    if CM.charData then
        CM.charData._lastModified = GetTimeStamp()
    end

    -- Get EditBox limit from constants
    local CHUNKING = CM.constants and CM.constants.CHUNKING
    local DEFAULTS = CM.constants and CM.constants.DEFAULTS
    local EDITBOX_LIMIT = (CHUNKING and CHUNKING.EDITBOX_LIMIT)
        or (DEFAULTS and DEFAULTS.EDITBOX_LIMIT_FALLBACK)
        or 10000

    -- Once complete, chunk if necessary
    if markdownLength > EDITBOX_LIMIT then
        CM.DebugPrint("GENERATOR", function()
            return string.format("Markdown exceeds EditBox limit (%d > %d), chunking...", markdownLength, EDITBOX_LIMIT)
        end)

        -- Use the consolidated chunking utility (handles tables, lists, padding, etc.)
        local Chunking = CM.utils and CM.utils.Chunking
        local SplitMarkdownIntoChunks = Chunking and Chunking.SplitMarkdownIntoChunks

        if SplitMarkdownIntoChunks then
            local chunks = SplitMarkdownIntoChunks(completeMarkdown)
            CM.DebugPrint("GENERATOR", function()
                return string.format("Split into %d chunks using Chunking utility", #chunks)
            end)

            -- Clear references to help GC before returning
            collectedData = nil
            settings = nil
            gen = nil
            sections = nil
            completeMarkdown = nil

            -- Hint to Lua GC that now is a good time to collect
            -- (Large markdown generation can create significant temporary string garbage)
            collectgarbage("step", 1000)

            return chunks
        else
            CM.Error("Chunking utility not available - markdown may be truncated!")

            -- Clear references even on error path
            collectedData = nil
            settings = nil
            gen = nil
            sections = nil

            return completeMarkdown
        end
    end

    -- Markdown fits in one chunk - return as string
    -- Clear references to help GC
    collectedData = nil
    settings = nil
    gen = nil
    sections = nil

    -- Hint to Lua GC that now is a good time to collect
    -- (Large markdown generation can create significant temporary string garbage)
    collectgarbage("step", 1000)

    return completeMarkdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.GenerateMarkdown = GenerateMarkdown
