-- CharacterMarkdown - Settings Defaults
-- Defines default values for all settings

local CM = CharacterMarkdown

CM.Settings = CM.Settings or {}
CM.Settings.Defaults = {}

-- =====================================================
-- DEFAULT SETTINGS
-- =====================================================

function CM.Settings.Defaults:GetAll()
    return {

        -- ====================================
        -- SYSTEM SETTINGS
        -- ====================================
        detectedOS = "unknown", -- Auto-detected OS: "windows", "mac", or "unknown"

        -- ====================================
        -- FORMATTER SETTINGS
        -- ====================================
        -- currentFormatter = "markdown", -- REMOVED: Strict enforcement

        -- ====================================
        -- LAYOUT SETTINGS
        -- ====================================
        includeHeader = true, -- Include character header section
        includeFooter = true, -- Include footer section

        -- ====================================
        -- CORE CONTENT SECTIONS
        -- ====================================
        includeChampionPoints = true,
        includeChampionDiagram = false, -- Mermaid diagram (GitHub/VSCode only - Mermaid doesn't render in Discord)
        includeSkillBars = true,
        includeSkills = true,
        includeSkillMorphs = false, -- Show all morphable skills with choices
        includeEquipment = true,
        includeCompanion = true,
        includeBuffs = true,
        includeAttributes = true,
        includeCharacterAttributes = true, -- Character attributes (age, gender, race, title, etc.)
        includeDLCAccess = false, -- DLC/Chapter access (opt-in, not essential for build sharing)
        includeRole = true,
        includeLocation = true,
        includeBuildNotes = true, -- Include custom build notes
        includeQuickStats = true, -- Quick stats at top (GitHub/VSCode only)
        includeGeneral = true, -- Include General subsection in Overview
        includeBasicCombatStats = true, -- Include Basic Combat Stats in Combat Arsenal (Health, Magicka, Stamina, Power, Crit, etc.)
        includeAdvancedStats = true, -- Include Advanced Stats in Combat Arsenal (Core Abilities, Resistances, Damage Bonuses, etc.)
        includeAttentionNeeded = true, -- Attention needed section (GitHub/VSCode only)
        includeTableOfContents = true, -- Table of contents (GitHub/VSCode only)

        -- ====================================
        -- EXTENDED CONTENT SECTIONS
        -- ====================================
        includeCurrency = true,
        includeProgression = false,
        includeRidingSkills = false,
        includeInventory = true,
        showBagContents = false, -- Show detailed list of items in backpack
        showBankContents = false, -- Show detailed list of items in bank
        showCraftingBagContents = false, -- Show detailed list of items in crafting bag (ESO Plus only)
        includePvP = false,
        includeCollectibles = true,
        showCollectiblesDetailed = false, -- Show full lists vs counts
        includeCrafting = true,
        includeMotifs = true,
        showMotifsDetailed = false,
        includeStyles = true,
        showStylesDetailed = false,
        includeRecipes = true,
        showRecipesDetailed = false, -- Show individual recipe lists per category vs counts only
        includeAchievements = false, -- Achievement tracking with category breakdown (opt-in for detail level)
        showAllAchievements = true, -- Show all achievements vs in-progress only
        includeAntiquities = false, -- Antiquities tracking (opt-in, not all players use this content)
        showAntiquitiesDetailed = false, -- Detailed antiquity sets breakdown
        -- includeQuests = true,  -- Quest tracking (Phase 6) - DISABLED
        -- includeQuestsDetailed = true,  -- Detailed quest categories - DISABLED
        -- showAllQuests = true,  -- Show all quests vs active only - DISABLED
        includeQuests = false, -- Quest tracking disabled temporarily
        showQuestsDetailed = false,
        showAllQuests = false,
        includeEquipmentEnhancement = false, -- Equipment analysis (Phase 7)
        showEquipmentAnalysis = false, -- Detailed equipment analysis
        showEquipmentRecommendations = false, -- Optimization recommendations
        includeWorldProgress = false, -- World progress tracking
        includeTitlesHousing = false, -- Titles and housing
        includeHousing = false, -- Housing information (owned houses, primary residence)
        includePvPStats = false, -- PvP statistics
        includeArmoryBuilds = false, -- Armory builds
        includeUndauntedPledges = false, -- Undaunted pledges
        includeGuilds = true, -- Guild membership (social context, minimal size ~200-400 chars)
        includeMail = false, -- Mail information (unread count, attachments)

        -- ====================================
        -- PVP DISPLAY SETTINGS
        -- ====================================
        showPvPProgression = false, -- Include rank progress bars and percentages
        showCampaignRewards = false, -- Display reward tier and loyalty streak
        showLeaderboards = false, -- Include leaderboard ranking (requires API query)
        showBattlegrounds = false, -- Include BG leaderboard stats
        showDetailedPvP = false, -- Full comprehensive mode with all PvP details
        showAllianceWarSkills = false, -- Show Alliance War skill lines (Assault/Support/Emperor) - useful for PvE builds

        -- ====================================
        -- LINK SETTINGS
        -- ====================================
        enableAbilityLinks = true, -- Add UESP wiki links to abilities (no size impact, major UX improvement)
        enableSetLinks = true, -- Add UESP wiki links to armor sets (no size impact, major UX improvement)
        enableMotifLinks = true, -- Add UESP wiki links to crafting motif chapters (no size impact, major UX improvement)
        enableStyleLinks = true, -- Add UESP wiki links to outfit style entries (no size impact, major UX improvement)
        enableRecipeLinks = true, -- Add UESP wiki links to individual recipes (no size impact, major UX improvement)

        -- ====================================
        -- PER-CHARACTER DATA STORAGE
        -- ====================================
        -- NOTE: perCharacterData is NOT a default setting - it's a data structure that accumulates
        -- perCharacterData is initialized in Initializer.lua and should NEVER be reset to defaults
        -- Each character in perCharacterData[characterId] has:
        --   - customNotes: custom build notes
        --   - customTitle: custom character title
        --   - playStyle: play style tag (magicka_dps, stamina_tank, etc.)
        -- Note: markdown/markdown_format fields removed (exceeded ESO 2k char limit, never used)
    }
end

CM.DebugPrint("SETTINGS", "Defaults module loaded")
