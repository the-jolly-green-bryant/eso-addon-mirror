-- CharacterMarkdown - Debug Command Handlers
-- Debug utilities, stat scanning, and diagnostic tools

local CM = CharacterMarkdown
CM.commands = CM.commands or {}
CM.commands.debug = {}

-- =====================================================
-- SAVEDVARS DEBUG UTILITY
-- =====================================================

-- CharacterMarkdownData: Legacy global from older addon versions (not in manifest).
-- Current addon uses CharacterMarkdownSettings.perCharacterData[characterId] (CM.charData).
-- Debug checks for it for diagnostic/backward-compatibility visibility only.
local function DebugSavedVarsState()
    CM.Info("|c00FFFF[CM] ===== SAVEDVARIABLES DEBUG INFO =====|r")
    CM.Info("|c00FFFF[CM] CharacterMarkdownSettings exists: " .. tostring(_G.CharacterMarkdownSettings ~= nil) .. "|r")
    CM.Info("|c00FFFF[CM] CharacterMarkdownData exists (legacy): " .. tostring(_G.CharacterMarkdownData ~= nil) .. "|r")
    CM.Info("|c00FFFF[CM] CM.settings exists: " .. tostring(CM.settings ~= nil) .. "|r")
    CM.Info("|c00FFFF[CM] CM.charData exists: " .. tostring(CM.charData ~= nil) .. "|r")

    if CM.settings then
        CM.Info("|c00FF00[CM] CM.settings type: " .. type(CM.settings) .. "|r")
    end

    if CM.charData then
        CM.Info("|c00FF00[CM] CM.charData type: " .. type(CM.charData) .. "|r")
        CM.Info("|c00FFFF[CM] CM.charData contents:|r")
        for k, v in pairs(CM.charData) do
            CM.Info(string.format("|c00FFFF[CM]   %s = %s (%s)|r", tostring(k), tostring(v), type(v)))
        end
    else
        CM.Error("|cFF0000[CM] ERROR: CM.charData is NIL!|r")
    end

    if _G.CharacterMarkdownData then
        CM.Info("|c00FF00[CM] CharacterMarkdownData structure (legacy):|r")
        local keyCount = 0
        for k, v in pairs(_G.CharacterMarkdownData) do
            keyCount = keyCount + 1
            CM.Info(string.format("|c00FF00[CM]   [%s] = %s|r", tostring(k), type(v)))
        end
        CM.Info("|c00FF00[CM] Total keys: " .. keyCount .. "|r")
    else
        CM.Info("|c00FFFF[CM] CharacterMarkdownData: nil (expected - legacy, not in manifest)|r")
    end

    CM.Info("|c00FFFF[CM] Character ID: " .. tostring(GetCurrentCharacterId()) .. "|r")
    CM.Info("|c00FFFF[CM] Account: " .. tostring(GetDisplayName()) .. "|r")
    CM.Info("|c00FFFF[CM] =====================================|r")
end

-- =====================================================
-- DEBUG MODE HANDLERS
-- =====================================================

local function HandleDebug(args)
    CM.debug = not CM.debug
    if CM.debug then
        CM.Success("Debug mode ENABLED - debug output will show in chat")
        CM.Info("Run /markdown again to see debug output for quest collection")
    else
        CM.Success("Debug mode DISABLED")
    end
end

local function HandleDebugOn(args)
    CM.debug = true
    CM.Success("Debug mode ENABLED")
end

local function HandleDebugOff(args)
    CM.debug = false
    CM.Success("Debug mode DISABLED")
end

local function HandleVersion(args)
    CM.Info("Character Markdown Version: " .. (CM.version or "Unknown"))
end

-- =====================================================
-- STAT SCANNER (DEBUG UTILITY)
-- =====================================================

local function HandleScanStats(args)
    CM.Info("|cFFD700=== STAT Scanner ===|r")
    CM.Info("Scanning STAT_ IDs 1-200 for non-zero values...")
    CM.Info("This may take a moment...")
    CM.Info(" ")

    local foundStats = {}
    local totalFound = 0

    -- Scan range - try without bonus option first
    for i = 1, 200 do
        local value = GetPlayerStat(i)
        if value and value > 0 then
            totalFound = totalFound + 1
            table.insert(foundStats, { id = i, value = value })
        end
    end

    -- Display results
    if totalFound == 0 then
        CM.Warn("No non-zero stats found in range 1-200")
    else
        CM.Success(string.format("Found %d non-zero stats:", totalFound))
        CM.Info(" ")
        CM.Info("|cFFFFFFID  | Value|r")
        CM.Info("|cFFFFFF----|------|r")

        for _, stat in ipairs(foundStats) do
            CM.Info(string.format("|cFFFFFF%-4d| %s|r", stat.id, CM.utils.FormatNumber(stat.value)))
        end

        CM.Info(" ")
        CM.Info("|cFFD700Compare these IDs to your screenshot values:|r")
        CM.Info("  Bash Cost: 696")
        CM.Info("  Block Cost: 1757")
        CM.Info("  Break Free Cost: 4590")
        CM.Info("  Dodge Roll Cost: 3802")
        CM.Info("  Sneak Cost: 119")
        CM.Info("  Sprint Cost: 475")
        CM.Info(" ")
        CM.Info("Once you find matching IDs, let me know!")
    end
end

local function HandleTestConstants(args)
    CM.Info("|cFFD700=== Testing Core Ability Costs ===|r")
    CM.Info("Trying GetAbilityCost() with common ability IDs...")
    CM.Info(" ")

    -- Expanded list of ability IDs to test for Sneak/Sprint
    local abilitiesToTest = {
        { name = "Bash (21970)", id = 21970 },
        { name = "Break Free (16565)", id = 16565 },
        { name = "Dodge Roll (28549)", id = 28549 },
        { name = "Sprint (15000)", id = 15000 },
        { name = "Sprint (973)", id = 973 },
        { name = "Sprint (1000)", id = 1000 },
        { name = "Sneak (20299)", id = 20299 },
        { name = "Sneak (20000)", id = 20000 },
        { name = "Sneak (19999)", id = 19999 },
    }

    for _, ability in ipairs(abilitiesToTest) do
        local cost = GetAbilityCost(ability.id, COMBAT_MECHANIC_FLAGS_STAMINA)
        if cost and cost > 0 then
            CM.Info(string.format("|cFFFFFF%s: %d|r", ability.name, cost))
        else
            CM.Warn(string.format("%s: No cost found", ability.name))
        end
    end

    CM.Info(" ")
    CM.Info("|cFFD700=== Testing Damage/Crit Bonus Stats ===|r")

    -- Test various stat IDs that might be damage bonuses
    local bonusStatsToTest = {
        { name = "ID 48", id = 48 },
        { name = "ID 49", id = 49 },
        { name = "ID 50", id = 50 },
        { name = "ID 78 (Crit Damage?)", id = 78 },
        { name = "ID 79", id = 79 },
        { name = "ID 80", id = 80 },
    }

    for _, stat in ipairs(bonusStatsToTest) do
        local value = GetPlayerStat(stat.id)
        if value and value > 0 then
            -- Try to interpret as percentage
            local asPercent = value / 100
            CM.Info(string.format("|cFFFFFF%s: %d (%.1f%%)|r", stat.name, value, asPercent))
        else
            CM.Warn(string.format("%s: 0 or nil", stat.name))
        end
    end

    CM.Info(" ")
    CM.Info("|cFFD700=== Done ===|r")
end

local function HandleFindNames(args)
    CM.Info("|cFFD700=== Testing GetAdvancedStatValue (Corrected) ===|r")

    local advancedStats = {
        { name = "Sneak Cost", id = ADVANCED_STAT_DISPLAY_TYPE_SNEAK_COST },
        { name = "Sprint Cost", id = ADVANCED_STAT_DISPLAY_TYPE_SPRINT_COST },
        { name = "Crit Damage", id = ADVANCED_STAT_DISPLAY_TYPE_CRITICAL_DAMAGE },
        { name = "Physical Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_PHYSICAL_DAMAGE },
        { name = "Flame Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_FIRE_DAMAGE },
        { name = "Shock Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_SHOCK_DAMAGE },
        { name = "Magic Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_MAGIC_DAMAGE },
        { name = "Disease Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_DISEASE_DAMAGE },
        { name = "Poison Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_POISON_DAMAGE },
        { name = "Bleed Bonus", id = ADVANCED_STAT_DISPLAY_TYPE_BLEED_DAMAGE },
    }

    for _, stat in ipairs(advancedStats) do
        if stat.id then
            -- API returns: displayFormat, flatValue, percentValue
            local format, flat, pct = GetAdvancedStatValue(stat.id)
            flat = flat or 0
            pct = pct or 0
            CM.Info(string.format("%s: Flat=%d, Pct=%.1f%% (Format: %d)", stat.name, flat, pct, format or -1))
        else
            CM.Info(string.format("%s: Constant NIL", stat.name))
        end
    end
end

-- =====================================================
-- CACHE COMMANDS
-- =====================================================

local function HandleCacheClear(args)
    local cleared = {}
    local count = 0

    -- Clear all API module caches
    if CM.api and CM.api.skills and CM.api.skills.ClearCache then
        CM.api.skills.ClearCache()
        table.insert(cleared, "Skills")
        count = count + 1
    end

    if CM.api and CM.api.collectibles and CM.api.collectibles.ClearCache then
        CM.api.collectibles.ClearCache()
        table.insert(cleared, "Collectibles")
        count = count + 1
    end

    if CM.api and CM.api.titles and CM.api.titles.ClearCache then
        CM.api.titles.ClearCache()
        table.insert(cleared, "Titles")
        count = count + 1
    end

    if CM.api and CM.api.antiquities and CM.api.antiquities.ClearCache then
        CM.api.antiquities.ClearCache()
        table.insert(cleared, "Antiquities")
        count = count + 1
    end

    if count > 0 then
        CM.Success("Cleared " .. count .. " cache(s): " .. table.concat(cleared, ", "))
    else
        CM.Info("No caches available to clear")
    end
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.commands.debug.DebugSavedVarsState = DebugSavedVarsState
CM.commands.debug.HandleDebug = HandleDebug
CM.commands.debug.HandleDebugOn = HandleDebugOn
CM.commands.debug.HandleDebugOff = HandleDebugOff
CM.commands.debug.HandleVersion = HandleVersion
CM.commands.debug.HandleScanStats = HandleScanStats
CM.commands.debug.HandleTestConstants = HandleTestConstants
CM.commands.debug.HandleFindNames = HandleFindNames
CM.commands.debug.HandleCacheClear = HandleCacheClear

CM.DebugPrint("COMMANDS", "Debug commands module loaded")
