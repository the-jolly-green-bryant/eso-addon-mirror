-- CharacterMarkdown v2.2.8 - Settings Initializer
-- Handles settings initialization with proper SavedVariables (ESO Guideline Compliant)
-- Author: solaegis
-- Enhanced with ZO_SavedVars, profiles, and import/export

CharacterMarkdown = CharacterMarkdown or {}
CharacterMarkdown.Settings = CharacterMarkdown.Settings or {}
CharacterMarkdown.Settings.Initializer = {}

local CM = CharacterMarkdown

-- =====================================================
-- INITIALIZATION
-- =====================================================

function CM.Settings.Initializer:Initialize()
    CM.DebugPrint("SETTINGS", "Initializing settings system...")

    -- Try ZO_SavedVars first (preferred method)
    local success = self:TryZOSavedVars()

    if not success then
        -- Fallback to direct assignment
        CM.DebugPrint("SETTINGS", "ZO_SavedVars initialization failed - using fallback method")
        self:InitializeFallback()
    end

    -- Initialize per-character data
    self:InitializeCharacterData()

    -- Initialize profile system
    self:InitializeProfiles()

    -- Sync formatter to core from SavedVariables
    -- Sync formatter to core from SavedVariables (REMOVED)
    -- REMOVED: Strict enforcement checks this logic from Commands instead

    CM.DebugPrint("SETTINGS", "Settings initialization complete")
    return true
end

-- =====================================================
-- ZO_SAVEDVARS INITIALIZATION (PREFERRED)
-- =====================================================

function CM.Settings.Initializer:TryZOSavedVars()
    -- Check if ZO_SavedVars is available
    if not ZO_SavedVars or type(ZO_SavedVars.NewAccountWide) ~= "function" then
        CM.Warn("ZO_SavedVars not available - addon loaded too early?")
        return false
    end

    -- Get defaults
    local defaults = CM.Settings.Defaults:GetAll()

    -- Initialize account-wide settings
    local success, result = pcall(function()
        CM.settings = ZO_SavedVars:NewAccountWide(
            "CharacterMarkdownSettings", -- SavedVariables name
            1, -- Version (increment when changing structure)
            nil, -- Namespace (nil = root)
            defaults -- Default values
        )
    end)

    if not success then
        CM.Error("Failed to initialize ZO_SavedVars: " .. tostring(result))
        return false
    end

    -- Verify initialization
    if not CM.settings or type(CM.settings) ~= "table" then
        CM.Error("ZO_SavedVars returned invalid settings table")
        return false
    end

    -- CRITICAL: Verify that CM.settings and CharacterMarkdownSettings are the same table
    -- ZO_SavedVars:NewAccountWide should return a reference to CharacterMarkdownSettings
    if CM.settings ~= CharacterMarkdownSettings then
        CM.DebugPrint("SETTINGS", "CM.settings and CharacterMarkdownSettings are different tables - forcing sync")
        -- This shouldn't happen, but if it does, ensure they point to the same table
        CM.settings = CharacterMarkdownSettings
    end

    -- CRITICAL: Ensure all defaults are applied to the actual SavedVariables table
    -- EXCEPTION: Never overwrite perCharacterData if it exists and has content
    for key, defaultValue in pairs(defaults) do
        if CM.settings[key] == nil then
            -- Special handling for perCharacterData: preserve existing data
            if key == "perCharacterData" and CharacterMarkdownSettings.perCharacterData then
                CM.DebugPrint("SETTINGS", "Preserving existing perCharacterData (not applying default)")
                -- Don't overwrite - keep the existing perCharacterData
            else
                CM.settings[key] = defaultValue
                CM.DebugPrint("SETTINGS", "Applied missing default: " .. key .. " = " .. tostring(defaultValue))
            end
        end
    end

    -- Ensure perCharacterData exists even if it was never created
    if not CM.settings.perCharacterData then
        CM.settings.perCharacterData = {}
        CM.DebugPrint("SETTINGS", "Initialized perCharacterData as empty table")
    end

    -- MIGRATION: Enable quest features for existing users (Version 2.1.8+)
    if CharacterMarkdownSettings.settingsVersion and CharacterMarkdownSettings.settingsVersion < 2 then
        CM.DebugPrint("SETTINGS", "Migrating to settings version 2 - enabling quest features")
        CharacterMarkdownSettings.includeQuests = true
        CharacterMarkdownSettings.showQuestsDetailed = true
        CharacterMarkdownSettings.showAllQuests = true
        CharacterMarkdownSettings.settingsVersion = 2
        CM.Info("Quest tracking has been enabled in your settings!")
    end

    -- MIGRATION: Split Character Stats into Basic and Advanced (Version 2.2.0+)
    if CharacterMarkdownSettings.settingsVersion and CharacterMarkdownSettings.settingsVersion < 3 then
        CM.DebugPrint("SETTINGS", "Migrating to settings version 3 - splitting character stats")

        -- If the old setting existed and was enabled, enable both new settings
        -- If it didn't exist or was disabled, use defaults (true)
        local oldSetting = CharacterMarkdownSettings.includeCharacterStats
        if oldSetting == nil then
            -- Setting never existed, use defaults
            CharacterMarkdownSettings.includeBasicCombatStats = true
            CharacterMarkdownSettings.includeAdvancedStats = true
            CM.DebugPrint("SETTINGS", "Old includeCharacterStats was nil, enabling both new stats by default")
        elseif oldSetting == true then
            -- Was enabled, keep enabled
            CharacterMarkdownSettings.includeBasicCombatStats = true
            CharacterMarkdownSettings.includeAdvancedStats = true
            CM.DebugPrint("SETTINGS", "Old includeCharacterStats was true, enabling both new stats")
        else
            -- Was explicitly disabled, respect that
            CharacterMarkdownSettings.includeBasicCombatStats = false
            CharacterMarkdownSettings.includeAdvancedStats = false
            CM.DebugPrint("SETTINGS", "Old includeCharacterStats was false, disabling both new stats")
        end

        CharacterMarkdownSettings.settingsVersion = 3
        CM.Info(
            "Character stats settings have been updated! You now have separate toggles for Basic and Advanced stats."
        )
    end

    -- MIGRATION: Enable Crafting & Style Knowledge (Version 2.2.6+)
    if CharacterMarkdownSettings.settingsVersion and CharacterMarkdownSettings.settingsVersion < 4 then
        CM.DebugPrint("SETTINGS", "Migrating to settings version 4 - enabling crafting and style features")

        -- Enable the features
        CharacterMarkdownSettings.includeCrafting = true
        CharacterMarkdownSettings.includeMotifs = true
        CharacterMarkdownSettings.showMotifsDetailed = true
        CharacterMarkdownSettings.includeStyles = true
        CharacterMarkdownSettings.showStylesDetailed = true
        CharacterMarkdownSettings.includeRecipes = true

        CharacterMarkdownSettings.settingsVersion = 4
        CM.Info(
            "New Crafting & Style Knowledge features have been enabled! You can now see your character's motifs and unlocked styles in your profiles."
        )
    end

    if CharacterMarkdownSettings.settingsVersion == nil then
        CharacterMarkdownSettings.settingsVersion = 4
    end

    -- zo_savedvars_available = true -- luacheck: ignore
    CM.DebugPrint("SETTINGS", "✓ ZO_SavedVars initialized successfully")
    return true
end

-- =====================================================
-- FALLBACK INITIALIZATION (DIRECT ASSIGNMENT)
-- =====================================================

function CM.Settings.Initializer:InitializeFallback()
    CM.DebugPrint("SETTINGS", "Using fallback initialization method")

    -- Access the global SavedVariables (created by ESO)
    if not CharacterMarkdownSettings then
        CM.Error("CRITICAL: CharacterMarkdownSettings not created by ESO!")
        CharacterMarkdownSettings = {}
    end

    -- Set reference
    CM.settings = CharacterMarkdownSettings

    -- Initialize settings with defaults
    local defaults = CM.Settings.Defaults:GetAll()

    -- Version tracking for fresh installs
    if CM.settings.settingsVersion == nil then
        CM.settings.settingsVersion = 4
        CM.settings._initialized = true
        CM.settings._lastModified = GetTimeStamp()
    end

    -- Apply defaults for any missing settings
    -- EXCEPTION: Never overwrite perCharacterData if it exists and has content
    for key, defaultValue in pairs(defaults) do
        if CM.settings[key] == nil then
            -- Special handling for perCharacterData: preserve existing data
            if key == "perCharacterData" and CharacterMarkdownSettings.perCharacterData then
                CM.DebugPrint("SETTINGS", "Preserving existing perCharacterData (not applying default)")
                -- Don't overwrite - keep the existing perCharacterData
            else
                CM.settings[key] = defaultValue
            end
        end
    end

    -- Ensure perCharacterData exists even if it was never created
    if not CM.settings.perCharacterData then
        CM.settings.perCharacterData = {}
        CM.DebugPrint("SETTINGS", "Initialized perCharacterData as empty table")
    end

    if CM.settings.settingsVersion and CM.settings.settingsVersion < 2 then
        CM.DebugPrint("SETTINGS", "Migrating to settings version 2 - enabling quest features")
        CM.settings.includeQuests = true
        CM.settings.showQuestsDetailed = true
        CM.settings.showAllQuests = true
        CM.settings.settingsVersion = 2
        CM.Info("Quest tracking has been enabled in your settings!")
    end

    if CM.settings.settingsVersion and CM.settings.settingsVersion < 3 then
        CM.DebugPrint("SETTINGS", "Migrating to settings version 3 - splitting character stats")

        -- If the old setting existed and was enabled, enable both new settings
        -- If it didn't exist or was disabled, use defaults (true)
        local oldSetting = CM.settings.includeCharacterStats
        if oldSetting == nil then
            -- Setting never existed, use defaults
            CM.settings.includeBasicCombatStats = true
            CM.settings.includeAdvancedStats = true
            CM.DebugPrint("SETTINGS", "Old includeCharacterStats was nil, enabling both new stats by default")
        elseif oldSetting == true then
            -- Was enabled, keep enabled
            CM.settings.includeBasicCombatStats = true
            CM.settings.includeAdvancedStats = true
            CM.DebugPrint("SETTINGS", "Old includeCharacterStats was true, enabling both new stats")
        else
            -- Was explicitly disabled, respect that
            CM.settings.includeBasicCombatStats = false
            CM.settings.includeAdvancedStats = false
            CM.DebugPrint("SETTINGS", "Old includeCharacterStats was false, disabling both new stats")
        end

        CM.settings.settingsVersion = 3
        CM.Info(
            "Character stats settings have been updated! You now have separate toggles for Basic and Advanced stats."
        )
    end

    if CM.settings.settingsVersion and CM.settings.settingsVersion < 4 then
        CM.DebugPrint("SETTINGS", "Migrating (fallback) to settings version 4")
        CM.settings.includeCrafting = true
        CM.settings.includeMotifs = true
        CM.settings.showMotifsDetailed = true
        CM.settings.includeStyles = true
        CM.settings.showStylesDetailed = true
        CM.settings.includeRecipes = true
        CM.settings.settingsVersion = 4
    end

    if CM.settings.settingsVersion == nil then
        CM.settings.settingsVersion = 4
    end

    CM.DebugPrint("SETTINGS", "✓ Fallback initialization complete")
end

-- =====================================================
-- PER-CHARACTER DATA
-- =====================================================

function CM.Settings.Initializer:InitializeCharacterData()
    -- Store per-character data INSIDE the account-wide CharacterMarkdownSettings
    -- This is more reliable than per-character SavedVariables

    local characterId = tostring(GetCurrentCharacterId())
    local accountName = GetDisplayName()

    -- Ensure the per-character storage exists in settings
    if not CM.settings.perCharacterData then
        CM.settings.perCharacterData = {}
        CM.DebugPrint("SETTINGS", "Created perCharacterData table (was nil)")
    end

    -- Check if character entry exists and log what we found
    local existingData = CM.settings.perCharacterData[characterId]
    if existingData then
        CM.DebugPrint(
            "SETTINGS",
            string.format(
                "Found existing data for character %s: customNotes=%d bytes, playStyle=%s",
                characterId,
                existingData.customNotes and #existingData.customNotes or 0,
                tostring(existingData.playStyle or "nil")
            )
        )
    else
        CM.DebugPrint("SETTINGS", "No existing data found for character " .. characterId .. ", creating new entry")
    end

    -- Ensure this character has an entry (only create if truly doesn't exist)
    if not CM.settings.perCharacterData[characterId] then
        CM.settings.perCharacterData[characterId] = {
            customNotes = "",
            customTitle = "",
            playStyle = "",
            _initialized = true,
            _lastModified = GetTimeStamp(),
            _characterName = GetUnitName("player"),
            _accountName = accountName,
        }
    end

    -- Point CM.charData to this character's data
    CM.charData = CM.settings.perCharacterData[characterId]

    -- Ensure all required fields exist (migration-safe for existing characters)
    CM.DebugPrint(
        "SETTINGS",
        string.format(
            "Before field checks - customNotes: %s (type: %s), customTitle: %s (type: %s), playStyle: %s (type: %s)",
            tostring(CM.charData.customNotes),
            type(CM.charData.customNotes),
            tostring(CM.charData.customTitle),
            type(CM.charData.customTitle),
            tostring(CM.charData.playStyle),
            type(CM.charData.playStyle)
        )
    )

    if not CM.charData.customNotes then
        CM.DebugPrint("SETTINGS", "customNotes was nil/false, initializing to empty string")
        CM.charData.customNotes = ""
    end
    if not CM.charData.customTitle then
        CM.DebugPrint("SETTINGS", "customTitle was nil/false, initializing to empty string")
        CM.charData.customTitle = ""
    end
    if not CM.charData.playStyle then
        CM.DebugPrint("SETTINGS", "playStyle was nil/false, initializing to empty string")
        CM.charData.playStyle = ""
    end

    -- Update metadata
    CM.charData._lastModified = GetTimeStamp()
    CM.charData._characterName = GetUnitName("player")
    CM.charData._accountName = accountName

    CM.DebugPrint(
        "SETTINGS",
        "✓ Character data initialized (notes: " .. string.len(CM.charData.customNotes) .. " bytes)"
    )
end

-- =====================================================
-- CUSTOM NOTES HELPERS
-- =====================================================

function CM.Settings.Initializer:SaveCustomNotes(notes)
    if not CM.charData then
        CM.Error("Character data not initialized")
        return false
    end

    -- Validate input
    if type(notes) ~= "string" then
        CM.Error("Custom notes must be a string")
        return false
    end

    -- Save notes
    CM.charData.customNotes = notes
    CM.charData._lastModified = GetTimeStamp()

    CM.DebugPrint("SETTINGS", "Custom notes saved (" .. string.len(notes) .. " bytes)")
    return true
end

function CM.Settings.Initializer:GetCustomNotes()
    if not CM.charData then
        CM.Error("Character data not initialized")
        return ""
    end

    return CM.charData.customNotes or ""
end

-- =====================================================
-- PROFILE SYSTEM INITIALIZATION
-- =====================================================

function CM.Settings.Initializer:InitializeProfiles()
    -- Initialize profiles storage
    if not CM.settings.profiles then
        CM.settings.profiles = {}
    end

    -- Track active profile
    if not CM.settings.activeProfile then
        CM.settings.activeProfile = "Custom" -- Default to custom (user's current settings)
    end

    CM.DebugPrint("SETTINGS", "✓ Profile system initialized")
end

-- =====================================================
-- SETTINGS VALIDATION
-- =====================================================

function CM.Settings.Initializer:ValidateSettings()
    local defaults = CM.Settings.Defaults:GetAll()
    local fixed = 0

    -- Ensure all required settings exist
    for key, defaultValue in pairs(defaults) do
        if CM.settings[key] == nil then
            CM.settings[key] = defaultValue
            CM.DebugPrint("SETTINGS", "Restored missing setting: " .. key)
            fixed = fixed + 1
        end
    end

    -- Validate formatter choice
    -- Validate formatter choice (REMOVED)
    -- REMOVED: Strict enforcement

    if fixed > 0 then
        CM.DebugPrint("SETTINGS", "Validated and fixed " .. fixed .. " settings")
    end

    return fixed == 0
end

-- =====================================================
-- PROFILE MANAGEMENT
-- =====================================================

function CM.Settings.Initializer:SaveProfile(profileName, includeNotes)
    if not profileName or profileName == "" then
        CM.Error("Profile name cannot be empty")
        return false
    end

    -- Create profile snapshot
    local profile = {
        name = profileName,
        created = GetTimeStamp(),
        version = CM.version,
    }

    -- Copy all settings (except meta fields and per-character data)
    local excludeKeys = {
        profiles = true,
        perCharacterData = true, -- Don't copy per-character data to profiles
        activeProfile = true,
        settingsVersion = true,
        _initialized = true,
        _lastModified = true,
        _panelOpened = true,
        _firstRun = true,
    }

    for key, value in pairs(CM.settings) do
        if not excludeKeys[key] then
            profile[key] = value
        end
    end

    -- Optionally include character notes
    if includeNotes and CM.charData.customNotes then
        profile.customNotes = CM.charData.customNotes
    end

    -- Save profile
    CM.settings.profiles[profileName] = profile
    CM.settings._lastModified = GetTimeStamp()

    CM.Info("Profile '" .. profileName .. "' saved")
    CM.DebugPrint("SETTINGS", "Profile saved with " .. self:CountProfileSettings(profile) .. " settings")

    return true
end

function CM.Settings.Initializer:LoadProfile(profileName)
    local profile = CM.settings.profiles[profileName]

    if not profile then
        if CM.Settings.Defaults.GetProfile then
            profile = CM.Settings.Defaults:GetProfile(profileName)
        end
        if not profile then
            CM.Error("Profile '" .. profileName .. "' not found")
            return false
        end
    end

    CM.DebugPrint("SETTINGS", "Loading profile: " .. profileName)

    -- Apply profile settings
    local applied = 0
    for key, value in pairs(profile) do
        if
            key ~= "name"
            and key ~= "created"
            and key ~= "version"
            and key ~= "description"
            and key ~= "customNotes"
        then
            CM.settings[key] = value
            applied = applied + 1
        end
    end

    -- Apply notes if present
    if profile.customNotes and CM.charData then
        CM.charData.customNotes = profile.customNotes
    end

    -- Update active profile
    CM.settings.activeProfile = profileName
    CM.settings._lastModified = GetTimeStamp()

    -- Sync format to core
    CM.currentFormatter = CM.settings.currentFormatter

    CM.Info("Profile '" .. profileName .. "' loaded (" .. applied .. " settings applied)")
    CM.DebugPrint("SETTINGS", "Profile loaded successfully")

    return true
end

function CM.Settings.Initializer:DeleteProfile(profileName)
    if not CM.settings.profiles[profileName] then
        CM.Error("Profile '" .. profileName .. "' not found")
        return false
    end

    CM.settings.profiles[profileName] = nil
    CM.settings._lastModified = GetTimeStamp()

    -- If this was the active profile, switch to Custom
    if CM.settings.activeProfile == profileName then
        CM.settings.activeProfile = "Custom"
    end

    CM.Info("Profile '" .. profileName .. "' deleted")
    return true
end

function CM.Settings.Initializer:GetProfileList()
    local profiles = {}

    -- Add user profiles
    for name, profile in pairs(CM.settings.profiles) do
        table.insert(profiles, {
            name = name,
            created = profile.created,
            version = profile.version,
            isPreset = false,
        })
    end

    -- Add preset profiles
    if CM.Settings.Defaults.PROFILES then
        for name, profile in pairs(CM.Settings.Defaults.PROFILES) do
            table.insert(profiles, {
                name = name,
                description = profile.description,
                isPreset = true,
            })
        end
    end

    return profiles
end

function CM.Settings.Initializer:CountProfileSettings(profile)
    local count = 0
    for _, _ in pairs(profile) do
        count = count + 1
    end
    return count
end

-- =====================================================
-- IMPORT/EXPORT
-- =====================================================

function CM.Settings.Initializer:ExportSettings()
    local export = {
        version = CM.version,
        timestamp = GetTimeStamp(),
        settings = {},
    }

    -- Copy all settings except meta fields and structural data
    local excludeKeys = {
        profiles = true, -- Don't export profiles
        perCharacterData = true, -- Don't export all characters' data (export current character separately)
        settingsVersion = true,
        _initialized = true,
        _lastModified = true,
        _panelOpened = true,
        _firstRun = true,
    }

    for key, value in pairs(CM.settings) do
        if not excludeKeys[key] then
            export.settings[key] = value
        end
    end

    -- Include character notes if present
    if CM.charData.customNotes and CM.charData.customNotes ~= "" then
        export.customNotes = CM.charData.customNotes
    end

    -- Include play style if present
    if CM.charData.playStyle and CM.charData.playStyle ~= "" then
        export.playStyle = CM.charData.playStyle
    end

    -- Serialize to string
    local serialized = self:SerializeTable(export)

    CM.Info("Settings exported to clipboard format")
    CM.DebugPrint("SETTINGS", "Export size: " .. string.len(serialized) .. " bytes")

    return serialized
end

function CM.Settings.Initializer:ImportSettings(importString)
    if not importString or importString == "" then
        CM.Error("Import string is empty")
        return false
    end

    -- Deserialize
    local success, import = pcall(function()
        return self:DeserializeTable(importString)
    end)

    if not success then
        CM.Error("Failed to parse import string: " .. tostring(import))
        return false
    end

    if not import or not import.settings then
        CM.Error("Invalid import format")
        return false
    end

    CM.DebugPrint("SETTINGS", "Importing settings from version: " .. tostring(import.version))

    -- Apply imported settings
    local applied = 0
    for key, value in pairs(import.settings) do
        if key ~= "perCharacterData" then
            CM.settings[key] = value
            applied = applied + 1
        end
    end

    -- Apply notes if present
    if import.customNotes and CM.charData then
        CM.charData.customNotes = import.customNotes
    end

    -- Apply play style if present
    if import.playStyle and CM.charData then
        CM.charData.playStyle = import.playStyle
    end

    -- Validate settings
    self:ValidateSettings()

    -- Mark as modified
    CM.settings._lastModified = GetTimeStamp()

    -- Sync format to core
    CM.currentFormatter = CM.settings.currentFormatter

    CM.Info("Settings imported successfully (" .. applied .. " settings)")
    return true
end

-- =====================================================
-- SERIALIZATION HELPERS
-- =====================================================

function CM.Settings.Initializer:SerializeTable(tbl, indent)
    indent = indent or 0
    local output = {}
    local prefix = string.rep("  ", indent)

    table.insert(output, "{\n")

    for k, v in pairs(tbl) do
        local key = type(k) == "string" and ('["%s"]'):format(k) or ("[%d]"):format(k)
        local value

        if type(v) == "table" then
            value = self:SerializeTable(v, indent + 1)
        elseif type(v) == "string" then
            value = ("%q"):format(v)
        elseif type(v) == "number" or type(v) == "boolean" then
            value = tostring(v)
        else
            value = "nil"
        end

        table.insert(output, prefix .. "  " .. key .. " = " .. value .. ",\n")
    end

    table.insert(output, prefix .. "}")

    return table.concat(output)
end

function CM.Settings.Initializer:DeserializeTable(str)
    -- Wrap in return statement for loadstring
    local funcStr = "return " .. str

    -- Load as function
    local func, err = loadstring(funcStr)
    if not func then
        error("Parse error: " .. tostring(err))
    end

    -- Execute and return table
    return func()
end

-- =====================================================
-- RESET TO DEFAULTS
-- =====================================================

function CM.Settings.Initializer:ResetToDefaults()
    CM.Info("Resetting all settings to defaults...")

    local defaults = CM.Settings.Defaults:GetAll()

    -- CRITICAL: Preserve only text fields (customNotes, customTitle, playStyle) for current character
    -- These are user-entered data that must NEVER be reset
    local characterId = tostring(GetCurrentCharacterId())
    local preservedTextFields = nil
    if CM.settings.perCharacterData and CM.settings.perCharacterData[characterId] then
        preservedTextFields = {
            customNotes = CM.settings.perCharacterData[characterId].customNotes,
            customTitle = CM.settings.perCharacterData[characterId].customTitle,
            playStyle = CM.settings.perCharacterData[characterId].playStyle,
        }
    end

    -- Apply defaults, but EXCLUDE perCharacterData (it's not a setting with a default)
    for key, value in pairs(defaults) do
        -- Skip perCharacterData - it's a data structure, not a setting with a default
        if key ~= "perCharacterData" then
            CM.settings[key] = value
        end
    end

    -- Restore only the text fields for current character (preserve customNotes, customTitle, playStyle)
    if preservedTextFields then
        -- Ensure perCharacterData structure exists
        if not CM.settings.perCharacterData then
            CM.settings.perCharacterData = {}
        end
        if not CM.settings.perCharacterData[characterId] then
            CM.settings.perCharacterData[characterId] = {}
        end
        -- Restore only the text fields
        CM.settings.perCharacterData[characterId].customNotes = preservedTextFields.customNotes
        CM.settings.perCharacterData[characterId].customTitle = preservedTextFields.customTitle
        CM.settings.perCharacterData[characterId].playStyle = preservedTextFields.playStyle
    end

    -- Reset version
    CM.settings.settingsVersion = 4
    CM.settings.activeProfile = "Custom"

    -- DO NOT clear character-specific data (customNotes, customTitle, playStyle)
    -- These are user-entered data and should never be reset automatically

    -- Sync format to core
    CM.currentFormatter = CM.settings.currentFormatter

    CM.settings._lastModified = GetTimeStamp()

    CM.Success("All settings reset to defaults (text fields preserved)")
end
