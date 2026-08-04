-- CharacterMarkdown v2.3.0 - Settings Panel
-- LibAddonMenu UI registration and panel controls (FIXED)
-- Author: solaegis
-- Following CraftStore pattern for proper persistence

CharacterMarkdown = CharacterMarkdown or {}
CharacterMarkdown.Settings = CharacterMarkdown.Settings or {}
CharacterMarkdown.Settings.Panel = {}

local CM = CharacterMarkdown

-- =====================================================
-- HELPER: INVALIDATE CACHE ON SETTING CHANGE
-- =====================================================

-- Helper function to create a setFunc that invalidates cache
local function CreateSetFunc(settingName)
    return function(value)
        CharacterMarkdownSettings[settingName] = value
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
    end
end

-- Helper function to ensure character data is initialized from perCharacterData
local function EnsureCharacterData()
    if CM.charData then
        return true
    end
    -- Initialize from account-wide settings perCharacterData
    local characterId = tostring(GetCurrentCharacterId())
    if
        CharacterMarkdownSettings
        and CharacterMarkdownSettings.perCharacterData
        and CharacterMarkdownSettings.perCharacterData[characterId]
    then
        CM.charData = CharacterMarkdownSettings.perCharacterData[characterId]
        return true
    end
    return false
end

-- Get or create per-character data for writing - writes directly to CharacterMarkdownSettings.perCharacterData
-- to guarantee persistence. Keeps CM.charData in sync.
local function GetOrCreateCharacterDataForWrite()
    if not CharacterMarkdownSettings then
        return nil
    end
    local characterId = tostring(GetCurrentCharacterId())
    if not CharacterMarkdownSettings.perCharacterData then
        CharacterMarkdownSettings.perCharacterData = {}
    end
    if not CharacterMarkdownSettings.perCharacterData[characterId] then
        CharacterMarkdownSettings.perCharacterData[characterId] = {
            customNotes = "",
            customTitle = "",
            playStyle = "",
            _initialized = true,
            _lastModified = GetTimeStamp(),
            _characterName = GetUnitName("player"),
            _accountName = GetDisplayName(),
        }
    end
    local charData = CharacterMarkdownSettings.perCharacterData[characterId]
    CM.charData = charData
    return charData
end

-- =====================================================
-- PLAY STYLES LIST
-- =====================================================

-- Display names shown to users in dropdown
local PLAY_STYLES = {
    "", -- Empty option (default)
    "Crafter",
    "Healer",
    "Hybrid Build",
    "Magicka DPS",
    "Mule",
    "Off-Tank",
    "Parse DPS",
    "PvP Bomblade",
    "PvP Brawler",
    "PvP Ganker",
    "PvP Support",
    "Resource Farmer",
    "Solo Self-Sufficient",
    "Stamina DPS",
    "Support DPS",
    "Tank",
}

-- Internal values saved to SavedVariables (must match exactly)
local PLAY_STYLE_VALUES = {
    "", -- Empty option (default)
    "crafter",
    "healer",
    "hybrid_build",
    "magicka_dps",
    "mule",
    "off_tank",
    "parse_dps",
    "pvp_bomblade",
    "pvp_brawler",
    "pvp_ganker",
    "pvp_support",
    "resource_farmer",
    "solo_self_sufficient",
    "stamina_dps",
    "support_dps",
    "tank",
}

-- =====================================================
-- PANEL REGISTRATION
-- =====================================================

function CM.Settings.Panel:Initialize()
    -- Wait for LibAddonMenu to be available
    if not LibAddonMenu2 then
        CM.Warn("Settings panel unavailable - LibAddonMenu-2.0 is required for the settings UI")
        CM.Info("To install:")
        CM.Info("  1. Download from: https://www.esoui.com/downloads/info7-LibAddonMenu.html")
        CM.Info("  2. Extract to: Documents/Elder Scrolls Online/live/AddOns/")
        CM.Info("  3. Reload UI with /reloadui")
        CM.Info("The /markdown command still works without settings UI")
        return false
    end

    -- Ensure settings are initialized
    if not CharacterMarkdownSettings then
        CM.Error("Settings not initialized! Cannot create panel.")
        return false
    end

    -- Ensure character data is initialized
    EnsureCharacterData()
    local LAM = LibAddonMenu2

    -- Create settings panel
    -- NOTE: We do NOT pass defaults to LAM - we handle reset entirely in defaultsFunc
    -- This prevents LibAddonMenu from directly resetting SavedVariables and clearing perCharacterData
    local panelData = {
        type = "panel",
        name = "Character Markdown",
        displayName = "Character Markdown",
        author = "solaegis",
        version = CM.version,
        slashCommand = "/markdown_settings",
        registerForRefresh = true,
        registerForDefaults = true,
        -- CRITICAL: Custom defaults handler to preserve text fields (customNotes, customTitle, playStyle)
        -- LibAddonMenu will call this function when user clicks "Defaults" button
        -- We handle ALL reset logic here to ensure text fields are preserved
        defaultsFunc = function()
            CM.DebugPrint("SETTINGS", "Defaults button clicked - preserving text fields")

            -- CRITICAL: Preserve text fields BEFORE any reset happens
            -- Get current character ID
            local characterId = tostring(GetCurrentCharacterId())
            local preservedTextFields = nil

            -- Preserve text fields from current character
            if
                CharacterMarkdownSettings
                and CharacterMarkdownSettings.perCharacterData
                and CharacterMarkdownSettings.perCharacterData[characterId]
            then
                preservedTextFields = {
                    customNotes = CharacterMarkdownSettings.perCharacterData[characterId].customNotes or "",
                    customTitle = CharacterMarkdownSettings.perCharacterData[characterId].customTitle or "",
                    playStyle = CharacterMarkdownSettings.perCharacterData[characterId].playStyle or "",
                }
                CM.DebugPrint(
                    "SETTINGS",
                    string.format(
                        "Preserved text fields for character %s: notes=%d chars, title='%s', playStyle='%s'",
                        characterId,
                        string.len(preservedTextFields.customNotes or ""),
                        preservedTextFields.customTitle or "",
                        preservedTextFields.playStyle or ""
                    )
                )
            else
                CM.DebugPrint("SETTINGS", "No text fields to preserve for character " .. characterId)
            end

            -- Apply defaults manually to ensure text fields are preserved correctly
            -- We don't call ResetToDefaults() here because we've already preserved the text fields
            -- and want to ensure they're restored after the reset
            local defaults = CM.Settings and CM.Settings.Defaults and CM.Settings.Defaults:GetAll() or {}

            -- Apply defaults, excluding perCharacterData
            for key, value in pairs(defaults) do
                if key ~= "perCharacterData" and key:sub(1, 1) ~= "_" then
                    CharacterMarkdownSettings[key] = value
                end
            end

            -- Restore only the text fields for current character
            if preservedTextFields then
                if not CharacterMarkdownSettings.perCharacterData then
                    CharacterMarkdownSettings.perCharacterData = {}
                end
                if not CharacterMarkdownSettings.perCharacterData[characterId] then
                    CharacterMarkdownSettings.perCharacterData[characterId] = {}
                end
                CharacterMarkdownSettings.perCharacterData[characterId].customNotes = preservedTextFields.customNotes
                CharacterMarkdownSettings.perCharacterData[characterId].customTitle = preservedTextFields.customTitle
                CharacterMarkdownSettings.perCharacterData[characterId].playStyle = preservedTextFields.playStyle
                CM.DebugPrint("SETTINGS", "Restored text fields after reset")
            end

            -- Update other reset-related fields
            CharacterMarkdownSettings.settingsVersion = 4
            CharacterMarkdownSettings.activeProfile = "Custom"
            CharacterMarkdownSettings._lastModified = GetTimeStamp()

            -- Sync formatter to core (REMOVED)
            -- if CharacterMarkdownSettings.currentFormatter then
            --     CM.currentFormatter = CharacterMarkdownSettings.currentFormatter
            -- end

            CM.InvalidateSettingsCache()
            CM.Info("Settings reset to defaults (text fields preserved)")

            -- CRITICAL: Force refresh the panel to update the UI with preserved values
            -- This ensures the text fields show the preserved values after reset
            zo_callLater(function()
                if CM.Settings.Panel.panelControl and CM.Settings.Panel.panelControl.RefreshPanel then
                    CM.Settings.Panel.panelControl:RefreshPanel()
                    CM.DebugPrint("SETTINGS", "Panel refreshed after defaults reset")
                end
            end, 100)
        end,
        website = "https://www.esoui.com/downloads/info4279-CharacterMarkdown.html",
        feedback = "https://www.esoui.com/downloads/info4279-CharacterMarkdown.html#comments",
        donation = "https://www.buymeacoffee.com/lewisvavasw",
    }

    self.panelId = "CharacterMarkdownPanel"
    self.panelControl = LAM:RegisterAddonPanel(self.panelId, panelData)

    -- Register options with proper getFunc/setFunc
    local optionsData = self:BuildOptionsData()
    LAM:RegisterOptionControls(self.panelId, optionsData)

    -- Manually resize Build Notes editbox after controls are created
    -- LAM2 doesn't properly support the height parameter for editboxes
    local function ResizeBuildNotesEditbox()
        local editBox = _G["CharacterMarkdown_BuildNotesEditBox"]
        if editBox then
            -- Find the actual text input control (editbox is the container)
            local textControl = editBox.editbox or editBox
            if textControl and textControl.SetHeight then
                textControl:SetHeight(500)
                CM.DebugPrint("SETTINGS", "Build Notes editbox height set to 500px")
            end
        end
    end

    -- Try to resize immediately after registration
    zo_callLater(ResizeBuildNotesEditbox, 500)

    -- Also register callback for when panel is shown/refreshed
    -- Fix for crash in LAM.util.RegisterForRefreshIfNeeded (replaced with standard callback)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
        if panel and panel.data and panel.data.name == "Character Markdown" then
            ResizeBuildNotesEditbox()
            -- Wire build notes counter label so setFunc can update it in real time as user types
            CM._buildNotesCounterLabel = _G["CharacterMarkdown_BuildNotesCounter"]
        end
    end)

    CM.DebugPrint("SETTINGS", "Settings panel registered with LAM")

    return true
end

-- =====================================================
-- OPTIONS DATA BUILDER
-- =====================================================

function CM.Settings.Panel:BuildOptionsData()
    local options = {}

    -- Add sections organized by user workflow (most-used first)
    self:AddActions(options) -- FIRST: Quick actions and controls

    -- self:AddFormatterSection(options) -- REMOVED: Formatter selection removed
    self:AddCustomNotes(options) -- Character Profile

    self:AddLayoutSection(options) -- Layout options (Header/Footer)

    -- Content sections: core build first, then common, then optional
    self:AddCombatSection(options) -- Combat (core)
    self:AddEquipmentSection(options) -- Equipment (core)
    self:AddSkillsSection(options) -- Skills (core)
    self:AddChampionSection(options) -- Champion Points (core)
    self:AddCharacterSection(options) -- Character identity
    self:AddInventorySection(options) -- Inventory, currency
    self:AddCompanionSection(options) -- Companion
    self:AddCollectiblesSection(options) -- Collectibles
    self:AddProgressionSection(options) -- Progression
    self:AddPvPSection(options) -- PvP
    self:AddAchievementsSection(options) -- Achievements
    self:AddAntiquitiesSection(options) -- Antiquities
    self:AddQuestsSection(options) -- Quests, Undaunted Pledges, World Progress
    self:AddArmoryBuildsSection(options) -- Armory Builds
    self:AddCraftingSection(options) -- Crafting
    self:AddSocialSection(options) -- Guilds, Mail

    self:AddLinkSettings(options)
    self:AddSupportSection(options) -- LAST: Support section

    return options
end

-- =====================================================
-- FORMATTER SETTINGS
-- =====================================================

-- =====================================================
-- FORMATTER SETTINGS (REMOVED)
-- =====================================================

-- function CM.Settings.Panel:AddFormatterSection(options)
--     -- Removed as part of strict format enforcement
-- end

-- =====================================================
-- LAYOUT SECTION
-- =====================================================

function CM.Settings.Panel:AddLayoutSection(options)
    table.insert(options, {
        type = "header",
        name = "Layout",
        width = "full",
    })

    table.insert(options, {
        type = "description",
        text = "Control which structural elements appear in your markdown output.",
        width = "full",
    })

    -- Header
    table.insert(options, {
        type = "checkbox",
        name = "Include Header",
        tooltip = "Show character name, level, CP, class, and alliance at the top of the markdown.",
        getFunc = function()
            return CharacterMarkdownSettings.includeHeader
        end,
        setFunc = CreateSetFunc("includeHeader"),
        width = "half",
        default = true,
    })

    -- Footer
    table.insert(options, {
        type = "checkbox",
        name = "Include Footer",
        tooltip = "Show format badge, size, and generation date at the bottom of the markdown.",
        getFunc = function()
            return CharacterMarkdownSettings.includeFooter
        end,
        setFunc = CreateSetFunc("includeFooter"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "divider",
        width = "full",
    })
end

-- =====================================================
-- COMBAT SECTION (Combat.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddCombatSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Combat statistics, role, active buffs, and attributes.",
        width = "full",
    })

    -- Basic Combat Stats (CollectCombatStatsData - basic stats)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Basic Combat Stats",
        tooltip = "Show basic combat statistics table in Combat Arsenal\\n(Health, Magicka, Stamina, Power, Critical Strike, Penetration, etc.)",
        getFunc = function()
            return CharacterMarkdownSettings.includeBasicCombatStats
        end,
        setFunc = CreateSetFunc("includeBasicCombatStats"),
        width = "half",
        default = true,
    })

    -- Advanced Stats (CollectCombatStatsData - advanced stats)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Advanced Stats",
        tooltip = "Show advanced combat statistics in Combat Arsenal\\n(Core Abilities, Elemental Resistances, Damage Bonuses, Healing Bonuses, etc.)",
        getFunc = function()
            return CharacterMarkdownSettings.includeAdvancedStats
        end,
        setFunc = CreateSetFunc("includeAdvancedStats"),
        width = "half",
        default = true,
    })

    -- Role (CollectRoleData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Role",
        tooltip = "Show selected role (Tank/Healer/DPS) in overview",
        getFunc = function()
            return CharacterMarkdownSettings.includeRole
        end,
        setFunc = CreateSetFunc("includeRole"),
        width = "half",
        default = true,
    })

    -- Active Buffs (CollectActiveBuffs)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Active Buffs",
        tooltip = "Show food, potions, and other active buffs",
        getFunc = function()
            return CharacterMarkdownSettings.includeBuffs
        end,
        setFunc = CreateSetFunc("includeBuffs"),
        width = "half",
        default = true,
    })

    -- Attribute Distribution (from Progression.lua, but shown here for logical grouping)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Attribute Distribution",
        tooltip = "Show magicka/health/stamina attribute points",
        getFunc = function()
            return CharacterMarkdownSettings.includeAttributes
        end,
        setFunc = CreateSetFunc("includeAttributes"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "submenu",
        name = "Combat",
        tooltip = "Combat statistics, role, active buffs, and attributes.",
        controls = controls,
    })
end

-- =====================================================
-- CHARACTER SECTION (Character.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddCharacterSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Character identity, location, and titles.",
        width = "full",
    })

    -- Current Location (CollectLocationData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Current Location",
        tooltip = "Show current zone/location in overview\n(Minimal size impact)",
        getFunc = function()
            return CharacterMarkdownSettings.includeLocation
        end,
        setFunc = CreateSetFunc("includeLocation"),
        width = "half",
        default = true,
    })

    -- Titles (CollectTitlesData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Titles",
        tooltip = "Show character titles.",
        getFunc = function()
            return CharacterMarkdownSettings.includeTitlesHousing
        end,
        setFunc = CreateSetFunc("includeTitlesHousing"),
        width = "half",
        default = false,
    })

    -- Character Attributes (CollectAttributesData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Attributes",
        tooltip = "Show character attributes (age, gender, race, title, etc.)",
        getFunc = function()
            return CharacterMarkdownSettings.includeCharacterAttributes
        end,
        setFunc = CreateSetFunc("includeCharacterAttributes"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "submenu",
        name = "Character",
        tooltip = "Character identity, location, and titles.",
        controls = controls,
    })
end

-- =====================================================
-- CHAMPION SECTION (Champion.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddChampionSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Champion Point allocation and discipline breakdown.",
        width = "full",
    })

    -- Champion Points (CollectChampionPointData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Champion Points",
        tooltip = "Show Champion Point allocation and discipline breakdown",
        getFunc = function()
            return CharacterMarkdownSettings.includeChampionPoints
        end,
        setFunc = CreateSetFunc("includeChampionPoints"),
        width = "half",
        default = true,
    })

    -- CP Visual Diagram
    table.insert(controls, {
        type = "checkbox",
        name = "    Include CP Visual Diagram",
        tooltip = "Mermaid diagram of Champion Points with prerequisites (GitHub/VSCode only). Requires Champion Points section.",
        getFunc = function()
            return CharacterMarkdownSettings.includeChampionDiagram
        end,
        setFunc = CreateSetFunc("includeChampionDiagram"),
        disabled = function()
            return not CharacterMarkdownSettings.includeChampionPoints
        end,
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Champion Points",
        tooltip = "Champion Point allocation and discipline breakdown.",
        controls = controls,
    })
end

-- =====================================================
-- SKILLS SECTION (Skills.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddSkillsSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Skill bars, skill progression, and skill morphs.",
        width = "full",
    })

    -- Skill Bars (CollectSkillBarData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Skill Bars",
        tooltip = "Show front and back bar abilities with ultimates",
        getFunc = function()
            return CharacterMarkdownSettings.includeSkillBars
        end,
        setFunc = CreateSetFunc("includeSkillBars"),
        width = "half",
        default = true,
    })

    -- Character Progress (CollectSkillProgressionData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Character Progress",
        tooltip = "Show Character Progress section with skill line ranks, progress, and passives",
        getFunc = function()
            return CharacterMarkdownSettings.includeSkills
        end,
        setFunc = CreateSetFunc("includeSkills"),
        width = "half",
        default = true,
    })

    -- Skill Morphs (CollectSkillMorphsData)
    table.insert(controls, {
        type = "checkbox",
        name = "    Show All Available Morphs",
        tooltip = "Show all morphable skills with morph choices (not just equipped). ~2-5KB for fully skilled characters.",
        getFunc = function()
            return CharacterMarkdownSettings.includeSkillMorphs
        end,
        setFunc = CreateSetFunc("includeSkillMorphs"),
        disabled = function()
            return not CharacterMarkdownSettings.includeSkills
        end,
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Skills",
        tooltip = "Skill bars, skill progression, and skill morphs.",
        controls = controls,
    })
end

-- =====================================================
-- EQUIPMENT SECTION (Equipment.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddEquipmentSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Equipped items and armor sets.",
        width = "full",
    })

    -- Equipment (CollectEquipmentData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Equipment",
        tooltip = "Show equipped items and armor sets",
        getFunc = function()
            return CharacterMarkdownSettings.includeEquipment
        end,
        setFunc = CreateSetFunc("includeEquipment"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "submenu",
        name = "Equipment",
        tooltip = "Equipped items and armor sets.",
        controls = controls,
    })
end

-- =====================================================
-- INVENTORY SECTION (Inventory.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddInventorySection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Inventory space, currency, and item lists.",
        width = "full",
    })

    -- Inventory Space (CollectInventoryData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Inventory Space",
        tooltip = "Show backpack and bank space usage\n(~150-200 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeInventory
        end,
        setFunc = CreateSetFunc("includeInventory"),
        width = "half",
        default = true,
    })

    -- Bag Contents
    table.insert(controls, {
        type = "checkbox",
        name = "    Show Bag Item List",
        tooltip = "Show detailed list of all items in your backpack.",
        warning = "Can generate very large output with many items",
        getFunc = function()
            return CharacterMarkdownSettings.showBagContents
        end,
        setFunc = CreateSetFunc("showBagContents"),
        width = "half",
        default = false,
        disabled = function()
            return not CharacterMarkdownSettings.includeInventory
        end,
    })

    -- Bank Contents
    table.insert(controls, {
        type = "checkbox",
        name = "    Show Bank Item List",
        tooltip = "Show detailed list of all items in your bank.",
        warning = "Can generate very large output with many items",
        getFunc = function()
            return CharacterMarkdownSettings.showBankContents
        end,
        setFunc = CreateSetFunc("showBankContents"),
        width = "half",
        default = false,
        disabled = function()
            return not CharacterMarkdownSettings.includeInventory
        end,
    })

    -- Crafting Bag Contents
    table.insert(controls, {
        type = "checkbox",
        name = "    Show Crafting Bag Item List",
        tooltip = "Show detailed list of all items in your crafting bag (ESO Plus only).",
        warning = "Can generate very large output with many items",
        getFunc = function()
            return CharacterMarkdownSettings.showCraftingBagContents
        end,
        setFunc = CreateSetFunc("showCraftingBagContents"),
        width = "half",
        default = false,
        disabled = function()
            return not CharacterMarkdownSettings.includeInventory
        end,
    })

    -- Currency & Resources (CollectCurrencyData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Currency & Resources",
        tooltip = "Show gold, Alliance Points, Tel Var, Transmutes, Writs, Event Tickets, etc.\n(~500-800 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeCurrency
        end,
        setFunc = CreateSetFunc("includeCurrency"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "submenu",
        name = "Inventory",
        tooltip = "Inventory space, currency, and item lists.",
        controls = controls,
    })
end

-- =====================================================
-- PROGRESSION SECTION (Progression.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddProgressionSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Character progression metrics and riding skills.",
        width = "full",
    })

    -- Progression Data (CollectProgressionData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Progression Data",
        tooltip = "Show skill points, attribute points, achievement points, available CP, vampire/werewolf status, and enlightenment\n(~200-400 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeProgression
        end,
        setFunc = CreateSetFunc("includeProgression"),
        width = "half",
        default = false,
    })

    -- Riding Skills (CollectRidingSkillsData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Riding Skills",
        tooltip = "Show riding speed, stamina, and capacity progress\n(~200-300 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeRidingSkills
        end,
        setFunc = CreateSetFunc("includeRidingSkills"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Progression",
        tooltip = "Character progression metrics and riding skills.",
        controls = controls,
    })
end

-- =====================================================
-- PVP SECTION (PvP.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddPvPSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "PvP statistics, progression, and Alliance War skills.",
        width = "full",
    })

    -- Basic PvP Information (CollectPvPData - basic)
    table.insert(controls, {
        type = "checkbox",
        name = "Include PvP Information",
        tooltip = "Show Alliance War rank and current campaign\n(~150-200 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includePvP
        end,
        setFunc = CreateSetFunc("includePvP"),
        width = "half",
        default = false,
    })

    -- PvP Statistics (CollectPvPData - stats)
    table.insert(controls, {
        type = "checkbox",
        name = "Include PvP Statistics",
        tooltip = "Show detailed PvP statistics and achievements.",
        getFunc = function()
            return CharacterMarkdownSettings.includePvPStats
        end,
        setFunc = CreateSetFunc("includePvPStats"),
        width = "half",
        default = false,
    })

    -- PvP Detail Options (dependent on includePvPStats)
    table.insert(controls, {
        type = "checkbox",
        name = "    Show PvP Progression",
        tooltip = "Include rank progress bars, percentages, and AP needed to next grade.",
        getFunc = function()
            return CharacterMarkdownSettings.showPvPProgression
        end,
        setFunc = CreateSetFunc("showPvPProgression"),
        width = "half",
        disabled = function()
            return not CharacterMarkdownSettings.includePvPStats
        end,
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Show Campaign Rewards",
        tooltip = "Display reward tier progress and loyalty streak.",
        getFunc = function()
            return CharacterMarkdownSettings.showCampaignRewards
        end,
        setFunc = CreateSetFunc("showCampaignRewards"),
        width = "half",
        disabled = function()
            return not CharacterMarkdownSettings.includePvPStats
        end,
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Show Leaderboards",
        tooltip = "Include campaign leaderboard ranking (requires API query).",
        getFunc = function()
            return CharacterMarkdownSettings.showLeaderboards
        end,
        setFunc = CreateSetFunc("showLeaderboards"),
        width = "half",
        disabled = function()
            return not CharacterMarkdownSettings.includePvPStats
        end,
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Show Battlegrounds",
        tooltip = "Include battleground leaderboard stats and medals.",
        getFunc = function()
            return CharacterMarkdownSettings.showBattlegrounds
        end,
        setFunc = CreateSetFunc("showBattlegrounds"),
        width = "half",
        disabled = function()
            return not CharacterMarkdownSettings.includePvPStats
        end,
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Detailed PvP Mode",
        tooltip = "Full comprehensive mode with campaign timing, underpop bonus, emperor info, and current match stats.",
        getFunc = function()
            return CharacterMarkdownSettings.showDetailedPvP
        end,
        setFunc = CreateSetFunc("showDetailedPvP"),
        width = "half",
        disabled = function()
            return not CharacterMarkdownSettings.includePvPStats
        end,
        default = false,
    })

    -- Alliance War Skills (independent setting)
    table.insert(controls, {
        type = "checkbox",
        name = "Show Alliance War Skills",
        tooltip = "Show Alliance War skill lines (Assault/Support/Emperor). Useful for PvE players who use these skills.",
        getFunc = function()
            return CharacterMarkdownSettings.showAllianceWarSkills
        end,
        setFunc = CreateSetFunc("showAllianceWarSkills"),
        width = "half",
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "Include Vengeance Loadout",
        tooltip = "Show Update 50 Vengeance role and perk summary when available.",
        getFunc = function()
            return CharacterMarkdownSettings.includeVengeance
        end,
        setFunc = CreateSetFunc("includeVengeance"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "PvP",
        tooltip = "PvP statistics, progression, and Alliance War skills.",
        controls = controls,
    })
end

-- =====================================================
-- COMPANION SECTION (Companion.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddCompanionSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Active companion information.",
        width = "full",
    })

    -- Companion Info (CollectCompanionData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Companion Info",
        tooltip = "Show active companion details (if summoned)",
        getFunc = function()
            return CharacterMarkdownSettings.includeCompanion
        end,
        setFunc = CreateSetFunc("includeCompanion"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "submenu",
        name = "Companion",
        tooltip = "Active companion information.",
        controls = controls,
    })
end

-- =====================================================
-- COLLECTIBLES SECTION (Collectibles.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddCollectiblesSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Mounts, pets, costumes, collectible items, DLC access, and housing.",
        width = "full",
    })

    -- Collectibles (CollectCollectiblesData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Collectibles",
        tooltip = "Show counts for mounts, pets, costumes, and collectible items\n(~200-300 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeCollectibles
        end,
        setFunc = CreateSetFunc("includeCollectibles"),
        width = "half",
        default = true,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Detailed Collectibles Lists",
        tooltip = "Show detailed lists of all owned collectibles (mounts, pets, costumes, emotes, mementos, skins, polymorphs, personalities) with progress bars and UESP links (~5000+ chars).",
        warning = "Can generate very large output depending on collection size",
        getFunc = function()
            return CharacterMarkdownSettings.showCollectiblesDetailed
        end,
        setFunc = CreateSetFunc("showCollectiblesDetailed"),
        disabled = function()
            return not CharacterMarkdownSettings.includeCollectibles
        end,
        width = "half",
        default = false,
    })

    -- DLC/Chapter Access (CollectDLCAccess)
    table.insert(controls, {
        type = "checkbox",
        name = "Include DLC/Chapter Access",
        tooltip = "Show which DLCs and Chapters are accessible\n(~400-600 chars - large section)",
        getFunc = function()
            return CharacterMarkdownSettings.includeDLCAccess
        end,
        setFunc = CreateSetFunc("includeDLCAccess"),
        width = "half",
        default = false,
    })

    -- Housing (CollectHousingData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Housing",
        tooltip = "Show owned houses and primary residence\n(~200-400 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeHousing
        end,
        setFunc = CreateSetFunc("includeHousing"),
        width = "half",
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "Include Appearance",
        tooltip = "Show active outfit, dyes, mount skin, and active costume/personality (~300-800 chars).",
        getFunc = function()
            return CharacterMarkdownSettings.includeAppearance
        end,
        setFunc = CreateSetFunc("includeAppearance"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Collectibles",
        tooltip = "Mounts, pets, costumes, collectible items, DLC access, and housing.",
        controls = controls,
    })
end

-- =====================================================
-- ACHIEVEMENTS SECTION (Achievements.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddAchievementsSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Achievement tracking and progress.",
        width = "full",
    })

    -- Achievement Tracking (CollectAchievementsData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Achievement Tracking",
        tooltip = "Show achievement progress by category, in-progress achievements, and recent completions (~1000-2000 chars).",
        getFunc = function()
            return CharacterMarkdownSettings.includeAchievements
        end,
        setFunc = CreateSetFunc("includeAchievements"),
        width = "half",
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Show All Achievements",
        tooltip = "Show all achievements. When disabled, only in-progress achievements appear.",
        getFunc = function()
            return CharacterMarkdownSettings.showAllAchievements ~= false
        end,
        setFunc = CreateSetFunc("showAllAchievements"),
        disabled = function()
            return not CharacterMarkdownSettings.includeAchievements
        end,
        width = "half",
        default = true,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Achievement Criteria Detail",
        tooltip = "Include criterion progress for incomplete achievements (larger output).",
        getFunc = function()
            return CharacterMarkdownSettings.includeAchievementDetail
        end,
        setFunc = CreateSetFunc("includeAchievementDetail"),
        disabled = function()
            return not CharacterMarkdownSettings.includeAchievements
        end,
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Achievements",
        tooltip = "Achievement tracking and progress.",
        controls = controls,
    })
end

-- =====================================================
-- ANTIQUITIES SECTION (Antiquities.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddAntiquitiesSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Antiquities progress, active leads, and discovered antiquities.",
        width = "full",
    })

    -- Antiquities (CollectAntiquitiesData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Antiquities",
        tooltip = "Show antiquities progress, active leads, and discovered antiquities.",
        getFunc = function()
            return CharacterMarkdownSettings.includeAntiquities
        end,
        setFunc = CreateSetFunc("includeAntiquities"),
        width = "half",
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Detailed Antiquity Sets",
        tooltip = "Show detailed breakdown of antiquity sets with progress tracking.",
        getFunc = function()
            return CharacterMarkdownSettings.showAntiquitiesDetailed
        end,
        setFunc = CreateSetFunc("showAntiquitiesDetailed"),
        disabled = function()
            return not CharacterMarkdownSettings.includeAntiquities
        end,
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Antiquities",
        tooltip = "Antiquities progress, active leads, and discovered antiquities.",
        controls = controls,
    })
end

-- =====================================================
-- QUESTS SECTION (Quests.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddQuestsSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Quest tracking and Undaunted pledges.",
        width = "full",
    })

    -- Quest Tracking (CollectQuestJournalData)
    table.insert(controls, {
        type = "checkbox",
        name = "[BETA] Include Quest Tracking",
        tooltip = "|cFFD700EXPERIMENTAL|r: Quest tracking is under active development.\n\nShow active quests, objectives, and quest categorization.",
        getFunc = function()
            return CharacterMarkdownSettings.includeQuests
        end,
        setFunc = CreateSetFunc("includeQuests"),
        width = "half",
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Detailed Quest Categories",
        tooltip = "Show quest breakdown by category (Main Story, Guild, DLC, etc.) with zone tracking.",
        getFunc = function()
            return CharacterMarkdownSettings.showQuestsDetailed
        end,
        setFunc = CreateSetFunc("showQuestsDetailed"),
        disabled = function()
            return not CharacterMarkdownSettings.includeQuests
        end,
        width = "half",
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Show All Quests",
        tooltip = "Show all quests. When disabled, only active quests appear.",
        getFunc = function()
            return CharacterMarkdownSettings.showAllQuests ~= false
        end,
        setFunc = CreateSetFunc("showAllQuests"),
        disabled = function()
            return not CharacterMarkdownSettings.includeQuests
        end,
        width = "half",
        default = false,
    })

    -- Undaunted Pledges (CollectUndauntedPledgesData)
    table.insert(controls, {
        type = "checkbox",
        name = "[BETA] Include Undaunted Pledges",
        tooltip = "|cFFD700EXPERIMENTAL|r: Undaunted tracking is under active development.\n\nShow active Undaunted pledges from quest journal.",
        getFunc = function()
            return CharacterMarkdownSettings.includeUndauntedPledges
        end,
        setFunc = CreateSetFunc("includeUndauntedPledges"),
        width = "half",
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "Include World Progress",
        tooltip = "Show skyshards, delves, public dungeons, current zone completion, and Cadwell progress (~800-3000 chars).",
        getFunc = function()
            return CharacterMarkdownSettings.includeWorldProgress
        end,
        setFunc = CreateSetFunc("includeWorldProgress"),
        width = "half",
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "Include Endless Dungeon",
        tooltip = "Show Endless Dungeon score and active verses when available.",
        getFunc = function()
            return CharacterMarkdownSettings.includeEndlessDungeon
        end,
        setFunc = CreateSetFunc("includeEndlessDungeon"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Quests [BETA]",
        tooltip = "Quest tracking, Undaunted pledges, and world progress.",
        controls = controls,
    })
end

-- =====================================================
-- ARMORY BUILDS SECTION (ArmoryBuilds.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddArmoryBuildsSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Saved armory builds and configurations.",
        width = "full",
    })

    -- Armory Builds (CollectArmoryBuildsData)
    table.insert(controls, {
        type = "checkbox",
        name = "[BETA] Include Armory Builds",
        tooltip = "|cFFD700EXPERIMENTAL|r: Armory export is under active development.\n\nShow saved armory builds and configurations.",
        getFunc = function()
            return CharacterMarkdownSettings.includeArmoryBuilds
        end,
        setFunc = CreateSetFunc("includeArmoryBuilds"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Armory Builds [BETA]",
        tooltip = "Saved armory builds and configurations.",
        controls = controls,
    })
end

-- =====================================================
-- CRAFTING SECTION (Crafting.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddCraftingSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Crafting knowledge, research, and styles.",
        width = "full",
    })

    -- Crafting Knowledge (CollectCraftingData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Crafting Knowledge",
        tooltip = "Show known motifs and active research slots\n(~150-200 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeCrafting
        end,
        setFunc = CreateSetFunc("includeCrafting"),
        width = "half",
        default = true,
    })

    -- Motifs
    table.insert(controls, {
        type = "checkbox",
        name = "    Include Motifs",
        tooltip = "Show known crafting motifs and completion progress.",
        getFunc = function()
            return CharacterMarkdownSettings.includeMotifs
        end,
        setFunc = CreateSetFunc("includeMotifs"),
        width = "half",
        default = true,
        disabled = function()
            return not CharacterMarkdownSettings.includeCrafting
        end,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Show Motifs Detailed",
        tooltip = "Show a detailed list of all motif chapters vs just a summary count.",
        getFunc = function()
            return CharacterMarkdownSettings.showMotifsDetailed
        end,
        setFunc = CreateSetFunc("showMotifsDetailed"),
        width = "half",
        default = false,
        disabled = function()
            return not CharacterMarkdownSettings.includeCrafting or not CharacterMarkdownSettings.includeMotifs
        end,
    })

    -- Outfit Styles
    table.insert(controls, {
        type = "checkbox",
        name = "    Include Outfit Styles",
        tooltip = "Show known outfit styles and completion progress.",
        getFunc = function()
            return CharacterMarkdownSettings.includeStyles
        end,
        setFunc = CreateSetFunc("includeStyles"),
        width = "half",
        default = true,
        disabled = function()
            return not CharacterMarkdownSettings.includeCrafting
        end,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Show Styles Detailed",
        tooltip = "Show a detailed list of all outfit styles vs just a summary count.",
        getFunc = function()
            return CharacterMarkdownSettings.showStylesDetailed
        end,
        setFunc = CreateSetFunc("showStylesDetailed"),
        width = "half",
        default = false,
        disabled = function()
            return not CharacterMarkdownSettings.includeCrafting or not CharacterMarkdownSettings.includeStyles
        end,
    })

    -- Recipes
    table.insert(controls, {
        type = "checkbox",
        name = "    Include Recipes",
        tooltip = "Show known provisioning and furnishing recipes.",
        getFunc = function()
            return CharacterMarkdownSettings.includeRecipes
        end,
        setFunc = CreateSetFunc("includeRecipes"),
        width = "half",
        default = true,
        disabled = function()
            return not CharacterMarkdownSettings.includeCrafting
        end,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "Include Item Set Collection",
        tooltip = "Show incomplete item set collection progress (up to 25 sets).",
        getFunc = function()
            return CharacterMarkdownSettings.includeItemSetCollection
        end,
        setFunc = CreateSetFunc("includeItemSetCollection"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Crafting",
        tooltip = "Crafting knowledge, research, and styles.",
        controls = controls,
    })
end

-- =====================================================
-- SOCIAL SECTION (Social.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddSocialSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Guild membership and mail information.",
        width = "full",
    })

    -- Guild Membership (CollectGuildsData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Guild Membership",
        tooltip = "Show guild membership information including guild names, member counts, and your rank\n(~200-400 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeGuilds
        end,
        setFunc = CreateSetFunc("includeGuilds"),
        width = "half",
        default = true,
    })

    -- Mail (CollectMailData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Mail",
        tooltip = "Show mail information including unread count and attachments\n(~100-200 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeMail
        end,
        setFunc = CreateSetFunc("includeMail"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Social",
        tooltip = "Guild membership and mail information.",
        controls = controls,
    })
end

-- =====================================================
-- LINK SETTINGS
-- =====================================================

function CM.Settings.Panel:AddLinkSettings(options)
    table.insert(options, {
        type = "divider",
        width = "full",
    })

    table.insert(options, {
        type = "header",
        name = "External Links (GitHub format only)",
        width = "full",
    })

    table.insert(options, {
        type = "description",
        text = "Enable clickable UESP wiki links for game elements by category.",
        width = "full",
    })

    table.insert(options, {
        type = "checkbox",
        name = "Enable UESP Links",
        tooltip = "Link abilities, armor sets, race, class, alliance, Mundus stones, CP skills, zones, PvP campaigns, and companions to UESP wiki.",
        getFunc = function()
            return CharacterMarkdownSettings.enableAbilityLinks
        end,
        setFunc = function(value)
            CharacterMarkdownSettings.enableAbilityLinks = value
            CharacterMarkdownSettings.enableSetLinks = value
            CharacterMarkdownSettings._lastModified = GetTimeStamp()
            CM.InvalidateSettingsCache()
        end,
        width = "full",
        default = true,
    })

    table.insert(options, {
        type = "checkbox",
        name = "    Motif UESP Links",
        tooltip = "Link crafting motif chapters to UESP wiki (Crafting section).",
        getFunc = function()
            return CharacterMarkdownSettings.enableMotifLinks
        end,
        setFunc = CreateSetFunc("enableMotifLinks"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "checkbox",
        name = "    Style UESP Links",
        tooltip = "Link outfit style entries to UESP wiki (Crafting section).",
        getFunc = function()
            return CharacterMarkdownSettings.enableStyleLinks
        end,
        setFunc = CreateSetFunc("enableStyleLinks"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "checkbox",
        name = "    Recipe UESP Links",
        tooltip = "Link individual recipes to UESP wiki (Crafting section).",
        getFunc = function()
            return CharacterMarkdownSettings.enableRecipeLinks
        end,
        setFunc = CreateSetFunc("enableRecipeLinks"),
        width = "half",
        default = true,
    })
end

-- =====================================================
-- CUSTOM NOTES
-- =====================================================

function CM.Settings.Panel:AddCustomNotes(options)
    table.insert(options, {
        type = "header",
        name = "Character Profile",
        width = "full",
    })

    -- Check for LibCustomIcons
    if LibCustomIcons and LibCustomIcons.GetStatic and GetDisplayName then
        local displayName = GetDisplayName()
        local iconPath = LibCustomIcons.GetStatic(displayName)

        if iconPath then
            table.insert(options, {
                type = "texture",
                image = iconPath,
                width = "full",
                height = 64,
                tooltip = "This icon is provided by LibCustomIcons addon",
            })

            table.insert(options, {
                type = "description",
                text = "|c6BCF7EYou have a custom icon!|r This icon will appear in your character header.",
                width = "full",
            })
        end
    end

    table.insert(options, {
        type = "checkbox",
        name = "Include Build Notes",
        tooltip = "Include custom build notes (after Overview). Enter notes below to appear in output.",
        getFunc = function()
            return CharacterMarkdownSettings.includeBuildNotes
        end,
        setFunc = CreateSetFunc("includeBuildNotes"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "editbox",
        name = "Custom Title",
        tooltip = "Override in-game title. Saved per-character. Leave empty to use current title.",
        getFunc = function()
            -- Ensure character data is initialized
            EnsureCharacterData()
            -- Ensure customTitle exists (initialize if nil)
            if CM.charData and CM.charData.customTitle == nil then
                CM.charData.customTitle = ""
            end
            return CM.charData and CM.charData.customTitle or ""
        end,
        setFunc = function(value)
            -- Write directly to CharacterMarkdownSettings.perCharacterData for guaranteed persistence
            local charData = GetOrCreateCharacterDataForWrite()
            if not charData then
                CM.Error("Failed to save custom title - character data not available")
                return
            end

            -- Normalize value (empty string if nil)
            local newValue = value or ""
            local currentValue = charData.customTitle or ""

            charData.customTitle = newValue
            charData._lastModified = GetTimeStamp()

            -- Log the save (only log if value actually changed)
            if newValue ~= currentValue then
                CM.DebugPrint("SETTINGS", "Custom title changed and saved")
            else
                CM.DebugPrint("SETTINGS", "Custom title refreshed")
            end
        end,
        width = "full",
        textType = TEXT_TYPE_ALL,
        maxChars = 100,
        -- NOTE: No default value - this is user-entered data that must never be reset
    })

    table.insert(options, {
        type = "dropdown",
        name = "Play Style",
        tooltip = "Primary play style. Saved per-character. Leave empty if not applicable.",
        choices = PLAY_STYLES,
        choicesValues = PLAY_STYLE_VALUES,
        getFunc = function()
            -- Ensure character data is initialized
            EnsureCharacterData()
            -- Ensure playStyle exists (initialize if nil)
            if CM.charData and CM.charData.playStyle == nil then
                CM.charData.playStyle = ""
            end
            return CM.charData and CM.charData.playStyle or ""
        end,
        setFunc = function(value)
            -- Write directly to CharacterMarkdownSettings.perCharacterData for guaranteed persistence
            local charData = GetOrCreateCharacterDataForWrite()
            if not charData then
                CM.Error("Failed to save play style - character data not available")
                return
            end

            -- Normalize value (empty string if nil)
            local newValue = value or ""
            local currentValue = charData.playStyle or ""

            charData.playStyle = newValue
            charData._lastModified = GetTimeStamp()

            -- Log the save (only log if value actually changed)
            if newValue ~= currentValue then
                CM.DebugPrint("SETTINGS", "Play style changed and saved: " .. tostring(newValue))
            else
                CM.DebugPrint("SETTINGS", "Play style refreshed")
            end
        end,
        width = "full",
        -- NOTE: No default value - this is user-entered data that must never be reset
    })

    table.insert(options, {
        type = "editbox",
        name = "Build Notes",
        tooltip = "Custom notes (rotation, parse data, build description). Saved per-character. Limit: 1,900 chars.",
        getFunc = function()
            -- Ensure character data is initialized
            EnsureCharacterData()
            -- Ensure customNotes exists (initialize if nil)
            if CM.charData and CM.charData.customNotes == nil then
                CM.charData.customNotes = ""
            end
            return CM.charData and CM.charData.customNotes or ""
        end,
        setFunc = function(value)
            -- Write directly to CharacterMarkdownSettings.perCharacterData for guaranteed persistence
            local charData = GetOrCreateCharacterDataForWrite()
            if not charData then
                CM.Error("Failed to save build notes - character data not available")
                return
            end

            -- Normalize value (empty string if nil)
            local newValue = value or ""
            local currentValue = charData.customNotes or ""

            charData.customNotes = newValue
            charData._lastModified = GetTimeStamp()

            -- Log the save (only log if value actually changed)
            if newValue ~= currentValue then
                CM.DebugPrint("SETTINGS", "Build notes changed and saved (" .. string.len(newValue) .. " bytes)")
            else
                CM.DebugPrint("SETTINGS", "Build notes refreshed (" .. string.len(newValue) .. " bytes)")
            end

            -- Update character counter if it exists (LAM description uses UpdateValue, not SetText)
            if CM._buildNotesCounterLabel and CM._buildNotesCounterLabel.UpdateValue then
                CM._buildNotesCounterLabel:UpdateValue()
            end
        end,
        width = "full",
        height = 500, -- Large editbox for better visibility - scrollbar appears when content exceeds this
        isMultiline = true,
        isExtraWide = true,
        maxChars = (CM.constants and CM.constants.LIMITS and CM.constants.LIMITS.MAX_CUSTOM_NOTES_SIZE) or 1900,
        -- NOTE: No default value - this is user-entered data that must never be reset
        reference = "CharacterMarkdown_BuildNotesEditBox",
    })

    -- Character counter label
    table.insert(options, {
        type = "description",
        text = function()
            local maxNotes = CM.constants and CM.constants.LIMITS and CM.constants.LIMITS.MAX_CUSTOM_NOTES_SIZE or 1900
            local charCount = 0
            if CM.charData and CM.charData.customNotes then
                charCount = string.len(CM.charData.customNotes)
            end
            local color = charCount > maxNotes and "|cFF6B6B"
                or (charCount > maxNotes - 200 and "|cFFD93D" or "|c6BCF7E")
            return color .. "Characters: " .. charCount .. " / " .. maxNotes .. "|r"
        end,
        reference = "CharacterMarkdown_BuildNotesCounter",
    })

    table.insert(options, {
        type = "divider",
        width = "full",
    })
end

-- =====================================================
-- ACTIONS
-- =====================================================

function CM.Settings.Panel:AddActions(options)
    local function RefreshSettingsPanel()
        if CM.Settings.Panel.panelControl and CM.Settings.Panel.panelControl.RefreshPanel then
            CM.Settings.Panel.panelControl:RefreshPanel()
        end
    end

    table.insert(options, {
        type = "header",
        name = "Actions",
        width = "full",
    })

    table.insert(options, {
        type = "description",
        text = "Configure which sections appear in your generated markdown. Character-specific options (title, play style, notes) are saved per character.",
        width = "full",
    })

    table.insert(options, {
        type = "button",
        name = "Generate Profile Now",
        tooltip = "Open the copy window with current settings",
        func = function()
            if CM.commands and CM.commands.GenerateOutput then
                CM.commands.GenerateOutput("markdown")
            elseif SLASH_COMMANDS and type(SLASH_COMMANDS["/markdown"]) == "function" then
                SLASH_COMMANDS["/markdown"]("")
            else
                CM.Error("Command not available - try /reloadui")
            end
        end,
        width = "half",
    })

    table.insert(options, {
        type = "button",
        name = "Reload UI",
        tooltip = "Reload the user interface (useful after making changes)",
        func = function()
            ReloadUI()
        end,
        width = "half",
    })

    -- Helper function to enable/disable all sections (organized by collector modules)
    local function ToggleAllSections(enable)
        local value = enable == true

        -- LAYOUT
        CharacterMarkdownSettings.includeHeader = value
        CharacterMarkdownSettings.includeFooter = value
        CharacterMarkdownSettings.includeTableOfContents = value
        CharacterMarkdownSettings.includeAttentionNeeded = value
        CharacterMarkdownSettings.includeQuickStats = value
        CharacterMarkdownSettings.includeGeneral = value

        -- CHARACTER (Character.lua collectors)
        CharacterMarkdownSettings.includeLocation = value
        CharacterMarkdownSettings.includeCharacterAttributes = value
        CharacterMarkdownSettings.includeTitlesHousing = value
        CharacterMarkdownSettings.includeDLCAccess = value

        -- COMBAT (Combat.lua collectors)
        CharacterMarkdownSettings.includeBasicCombatStats = value
        CharacterMarkdownSettings.includeAdvancedStats = value
        CharacterMarkdownSettings.includeRole = value
        CharacterMarkdownSettings.includeBuffs = value
        CharacterMarkdownSettings.includeAttributes = value

        -- CHAMPION (Champion.lua collectors)
        CharacterMarkdownSettings.includeChampionPoints = value
        CharacterMarkdownSettings.includeChampionDiagram = value

        -- SKILLS (Skills.lua collectors)
        CharacterMarkdownSettings.includeSkillBars = value
        CharacterMarkdownSettings.includeSkills = value
        CharacterMarkdownSettings.includeSkillMorphs = value

        -- EQUIPMENT (Equipment.lua collectors)
        CharacterMarkdownSettings.includeEquipment = value

        -- INVENTORY (Inventory.lua collectors)
        CharacterMarkdownSettings.includeInventory = value
        CharacterMarkdownSettings.showBagContents = value
        CharacterMarkdownSettings.showBankContents = value
        CharacterMarkdownSettings.showCraftingBagContents = value
        CharacterMarkdownSettings.includeCurrency = value

        -- PROGRESSION (Progression.lua collectors)
        CharacterMarkdownSettings.includeProgression = value
        CharacterMarkdownSettings.includeRidingSkills = value

        -- PVP (PvP.lua collectors)
        CharacterMarkdownSettings.includePvP = value
        CharacterMarkdownSettings.includePvPStats = value
        CharacterMarkdownSettings.showPvPProgression = value
        CharacterMarkdownSettings.showCampaignRewards = value
        CharacterMarkdownSettings.showLeaderboards = value
        CharacterMarkdownSettings.showBattlegrounds = value
        CharacterMarkdownSettings.showDetailedPvP = value
        CharacterMarkdownSettings.showAllianceWarSkills = value

        -- COMPANION (Companion.lua collectors)
        CharacterMarkdownSettings.includeCompanion = value

        -- COLLECTIBLES (Collectibles.lua collectors)
        CharacterMarkdownSettings.includeCollectibles = value
        CharacterMarkdownSettings.showCollectiblesDetailed = value
        CharacterMarkdownSettings.includeDLCAccess = value
        CharacterMarkdownSettings.includeHousing = value

        -- ACHIEVEMENTS (Achievements.lua collectors)
        CharacterMarkdownSettings.includeAchievements = value
        CharacterMarkdownSettings.showAllAchievements = value

        -- ANTIQUITIES (Antiquities.lua collectors)
        CharacterMarkdownSettings.includeAntiquities = value
        CharacterMarkdownSettings.showAntiquitiesDetailed = value

        -- QUESTS (Quests.lua collectors)
        CharacterMarkdownSettings.includeQuests = value
        CharacterMarkdownSettings.showQuestsDetailed = value
        CharacterMarkdownSettings.showAllQuests = value
        CharacterMarkdownSettings.includeUndauntedPledges = value

        -- ARMORY BUILDS (ArmoryBuilds.lua collectors)
        CharacterMarkdownSettings.includeArmoryBuilds = value

        -- CRAFTING (Crafting.lua collectors)
        CharacterMarkdownSettings.includeCrafting = value
        CharacterMarkdownSettings.includeMotifs = value
        CharacterMarkdownSettings.showMotifsDetailed = value
        CharacterMarkdownSettings.includeStyles = value
        CharacterMarkdownSettings.showStylesDetailed = value
        CharacterMarkdownSettings.includeRecipes = value
        CharacterMarkdownSettings.showRecipesDetailed = value

        -- SOCIAL (Social.lua collectors)
        CharacterMarkdownSettings.includeGuilds = value
        CharacterMarkdownSettings.includeMail = value

        -- LINKS
        CharacterMarkdownSettings.enableAbilityLinks = value
        CharacterMarkdownSettings.enableSetLinks = value
        CharacterMarkdownSettings.enableMotifLinks = value
        CharacterMarkdownSettings.enableStyleLinks = value
        CharacterMarkdownSettings.enableRecipeLinks = value

        -- NOTES/DISPLAY
        CharacterMarkdownSettings.includeBuildNotes = value

        -- OTHER ADDITIONS
        CharacterMarkdownSettings.includeEquipmentEnhancement = value
        CharacterMarkdownSettings.showEquipmentAnalysis = value
        CharacterMarkdownSettings.showEquipmentRecommendations = value
        CharacterMarkdownSettings.includeWorldProgress = value
        CharacterMarkdownSettings.includeAppearance = value
        CharacterMarkdownSettings.includeAchievementDetail = value
        CharacterMarkdownSettings.includeItemSetCollection = value
        CharacterMarkdownSettings.includeVengeance = value
        CharacterMarkdownSettings.includeEndlessDungeon = value

        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
        CM.Info(value and "All sections enabled!" or "All sections disabled!")
    end

    -- Enable All Sections button
    table.insert(options, {
        type = "button",
        name = "Enable All Sections",
        tooltip = "Turn on all content sections (Champion Points, Equipment, Currency, etc.). Full export can take several seconds and briefly pause the game.",
        func = function()
            ToggleAllSections(true)
            -- Force panel refresh
            RefreshSettingsPanel()
        end,
        width = "half",
    })

    -- Reset to Defaults button
    table.insert(options, {
        type = "button",
        name = "Reset to Defaults",
        tooltip = "Reset all settings to default values (preserves custom character notes).",
        func = function()
            CM.Settings.Initializer:ResetToDefaults()
            -- Force panel refresh
            RefreshSettingsPanel()
        end,
        width = "half",
        isDangerous = true,
    })

    table.insert(options, {
        type = "description",
        text = "Apply a curated preset configuration to match a specific playstyle or goal. This will modify your toggles, but will not erase your custom character notes.",
        width = "full",
    })

    -- Minimal preset: build sharing (Combat, Equipment, Skills, Champion, Currency)
    local function ApplyMinimalPreset()
        ToggleAllSections(false)
        CharacterMarkdownSettings.includeHeader = true
        CharacterMarkdownSettings.includeFooter = true
        CharacterMarkdownSettings.includeTableOfContents = true
        CharacterMarkdownSettings.includeBasicCombatStats = true
        CharacterMarkdownSettings.includeAdvancedStats = true
        CharacterMarkdownSettings.includeRole = true
        CharacterMarkdownSettings.includeBuffs = true
        CharacterMarkdownSettings.includeAttributes = true
        CharacterMarkdownSettings.includeChampionPoints = true
        CharacterMarkdownSettings.includeSkillBars = true
        CharacterMarkdownSettings.includeSkills = true
        CharacterMarkdownSettings.includeEquipment = true
        CharacterMarkdownSettings.includeCurrency = true
        CharacterMarkdownSettings.includeLocation = true
        CharacterMarkdownSettings.includeCharacterAttributes = true
        CharacterMarkdownSettings.includeBuildNotes = true
        CharacterMarkdownSettings.includeQuickStats = true
        CharacterMarkdownSettings.includeGeneral = true
        CharacterMarkdownSettings.enableAbilityLinks = false
        CharacterMarkdownSettings.enableSetLinks = false
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
        CM.Info("Minimal preset applied (build sharing)")
        RefreshSettingsPanel()
    end

    -- PvP Build preset: Minimal + PvP info and Alliance War Skills
    local function ApplyPvPBuildPreset()
        ApplyMinimalPreset()
        CharacterMarkdownSettings.enableAbilityLinks = true
        CharacterMarkdownSettings.enableSetLinks = true
        CharacterMarkdownSettings.includePvP = true
        CharacterMarkdownSettings.includePvPStats = true
        CharacterMarkdownSettings.showAllianceWarSkills = true
        CharacterMarkdownSettings.includeSkillMorphs = true
        CharacterMarkdownSettings.includeChampionDiagram = true
        CharacterMarkdownSettings.includeTitlesHousing = true
        CharacterMarkdownSettings.includeArmoryBuilds = true
        CharacterMarkdownSettings.includeGuilds = true
        CharacterMarkdownSettings.includeMail = true
        CharacterMarkdownSettings.includeVengeance = true
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
        CM.Info("PvP Build preset applied")
        RefreshSettingsPanel()
    end

    -- Achievement Hunter preset: Minimal + Achievements, Collectibles, Antiquities
    local function ApplyAchievementHunterPreset()
        ApplyMinimalPreset()
        CharacterMarkdownSettings.enableAbilityLinks = true
        CharacterMarkdownSettings.enableSetLinks = true
        CharacterMarkdownSettings.includeAchievements = true
        CharacterMarkdownSettings.showAllAchievements = true
        CharacterMarkdownSettings.includeAchievementDetail = true
        CharacterMarkdownSettings.includeCollectibles = true
        CharacterMarkdownSettings.includeAntiquities = true
        CharacterMarkdownSettings.showAntiquitiesDetailed = true
        CharacterMarkdownSettings.includeWorldProgress = true
        CharacterMarkdownSettings.includeCrafting = true
        CharacterMarkdownSettings.includeMotifs = true
        CharacterMarkdownSettings.showMotifsDetailed = true
        CharacterMarkdownSettings.includeStyles = true
        CharacterMarkdownSettings.showStylesDetailed = true
        CharacterMarkdownSettings.includeRecipes = true
        CharacterMarkdownSettings.showRecipesDetailed = true
        CharacterMarkdownSettings.enableMotifLinks = true
        CharacterMarkdownSettings.enableStyleLinks = true
        CharacterMarkdownSettings.enableRecipeLinks = true
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
        CM.Info("Achievement Hunter preset applied")
        RefreshSettingsPanel()
    end

    -- Crafter preset: Minimal + Crafting, Currency, Inventory
    local function ApplyCrafterPreset()
        ApplyMinimalPreset()
        CharacterMarkdownSettings.enableAbilityLinks = true
        CharacterMarkdownSettings.enableSetLinks = true
        CharacterMarkdownSettings.includeCrafting = true
        CharacterMarkdownSettings.includeMotifs = true
        CharacterMarkdownSettings.includeStyles = true
        CharacterMarkdownSettings.includeRecipes = true
        CharacterMarkdownSettings.showMotifsDetailed = true
        CharacterMarkdownSettings.showStylesDetailed = true
        CharacterMarkdownSettings.showRecipesDetailed = true
        CharacterMarkdownSettings.enableMotifLinks = true
        CharacterMarkdownSettings.enableStyleLinks = true
        CharacterMarkdownSettings.enableRecipeLinks = true
        CharacterMarkdownSettings.includeCurrency = true
        CharacterMarkdownSettings.includeInventory = true
        CharacterMarkdownSettings.showBagContents = true
        CharacterMarkdownSettings.showBankContents = true
        CharacterMarkdownSettings.showCraftingBagContents = true
        CharacterMarkdownSettings.includeCollectibles = true
        CharacterMarkdownSettings.showCollectiblesDetailed = true
        CharacterMarkdownSettings.includeDLCAccess = true
        CharacterMarkdownSettings.includeHousing = true
        CharacterMarkdownSettings.includeItemSetCollection = true
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
        CM.Info("Crafter preset applied")
        RefreshSettingsPanel()
    end

    -- Solo PvE preset: Minimal + Quests, Progression, Companion
    local function ApplySoloPvEPreset()
        ApplyMinimalPreset()
        CharacterMarkdownSettings.enableAbilityLinks = true
        CharacterMarkdownSettings.enableSetLinks = true
        CharacterMarkdownSettings.includeQuests = true
        CharacterMarkdownSettings.showQuestsDetailed = true
        CharacterMarkdownSettings.showAllQuests = true
        CharacterMarkdownSettings.includeUndauntedPledges = true
        CharacterMarkdownSettings.includeArmoryBuilds = true
        CharacterMarkdownSettings.includeProgression = true
        CharacterMarkdownSettings.includeRidingSkills = true
        CharacterMarkdownSettings.includeCompanion = true
        CharacterMarkdownSettings.includeSkillMorphs = true
        CharacterMarkdownSettings.includeChampionDiagram = true
        CharacterMarkdownSettings.includeTitlesHousing = true
        CharacterMarkdownSettings.includeCollectibles = true
        CharacterMarkdownSettings.showCollectiblesDetailed = true
        CharacterMarkdownSettings.includeDLCAccess = true
        CharacterMarkdownSettings.includeHousing = true
        CharacterMarkdownSettings.includeAppearance = true
        CharacterMarkdownSettings.includeWorldProgress = true
        CharacterMarkdownSettings.includeItemSetCollection = true
        CharacterMarkdownSettings.includePvP = true
        CharacterMarkdownSettings.includePvPStats = true
        CharacterMarkdownSettings.showPvPProgression = true
        CharacterMarkdownSettings.showCampaignRewards = true
        CharacterMarkdownSettings.showLeaderboards = true
        CharacterMarkdownSettings.showBattlegrounds = true
        CharacterMarkdownSettings.showDetailedPvP = true
        CharacterMarkdownSettings.showAllianceWarSkills = true
        CharacterMarkdownSettings.includeGuilds = true
        CharacterMarkdownSettings.includeMail = true
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
        CM.Info("Solo PvE preset applied")
        RefreshSettingsPanel()
    end

    table.insert(options, {
        type = "button",
        name = "Preset: Minimal (Build Export)",
        tooltip = "Build export for sharing: CP, attributes, skill bars, skills, equipment (traits/enchants), combat stats, currency. No UESP links. Disables optional sections (achievements, inventory lists, etc.).",
        func = ApplyMinimalPreset,
        width = "half",
    })

    table.insert(options, {
        type = "button",
        name = "Preset: Solo PvE",
        tooltip = "Minimal plus full Quests [BETA], Armory [BETA], Social, Progression, Riding, Companion, skill morphs, CP diagram, titles, Collectibles, and PvP.",
        func = ApplySoloPvEPreset,
        width = "half",
    })

    table.insert(options, {
        type = "button",
        name = "Preset: PvP Build",
        tooltip = "Minimal plus PvP info, stats, Alliance War skills, skill morphs, CP diagram, titles, Armory [BETA], and Social.",
        func = ApplyPvPBuildPreset,
        width = "half",
    })

    table.insert(options, {
        type = "button",
        name = "Preset: Achievement Hunter",
        tooltip = "Minimal plus full Achievements, Antiquities, Collectibles, and Crafting (all submenu options).",
        func = ApplyAchievementHunterPreset,
        width = "half",
    })

    table.insert(options, {
        type = "button",
        name = "Preset: Crafter",
        tooltip = "Minimal plus full Crafting, Currency, Inventory, bag/bank/crafting bag lists, and Collectibles.",
        func = ApplyCrafterPreset,
        width = "half",
    })

    table.insert(options, {
        type = "divider",
        width = "full",
    })
end

-- =====================================================
-- SUPPORT SECTION
-- =====================================================

function CM.Settings.Panel:AddSupportSection(options)
    table.insert(options, {
        type = "divider",
        width = "full",
    })

    table.insert(options, {
        type = "header",
        name = "Support",
        width = "full",
    })

    table.insert(options, {
        type = "description",
        text = "|cFFD700Enjoying CharacterMarkdown?|r\n\nIf you find this addon useful, consider supporting its development!",
        width = "full",
    })

    table.insert(options, {
        type = "button",
        name = "Buy Me a Coffee",
        tooltip = "Support the development of CharacterMarkdown\n\nOpens your browser to the Buy Me a Coffee page",
        func = function()
            -- Try to open URL using ESO's RequestOpenURL if available
            local success, result = pcall(function()
                if RequestOpenURL then
                    RequestOpenURL("https://www.buymeacoffee.com/lewisvavasw")
                    return true
                end
                return false
            end)

            if success and result then
                CM.Info("Opening Buy Me a Coffee page...")
            else
                -- Fallback: Show URL in chat
                CM.Info("Buy Me a Coffee: https://www.buymeacoffee.com/lewisvavasw")
                CM.Info("(Copy the URL above and paste it in your browser)")
            end
        end,
        width = "full",
    })
end

-- Debug print (deferred until CM.DebugPrint is available)
if CM.DebugPrint then
    CM.DebugPrint("SETTINGS", "Panel module loaded (CraftStore pattern)")
end
