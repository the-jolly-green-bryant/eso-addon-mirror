-- ============================================================================
-- Companion Wardrobe
-- Addon Entry Point
--
-- Responsibilities:
-- - Define addon metadata and version.
-- - Register addon lifecycle events.
-- - Initialize SavedVariables, settings, UI hooks, and slash commands.
-- - Coordinate startup once ESO reports the addon as loaded.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

MHCWL.name = "MadHoeksCompanionWardrobe"
MHCWL.version = "3.11.0"

function MHCWL.OnCompanionMenuOpened()
    MHCWL.Debug("Companion menu opened.")
    MHCWL.StartCompanionMenuWatcher()
    MHCWL.CreateCompanionMenuButton()
    if MHCWL.saved.settings.window.showWith then
        if not MHCWL.window then
            MHCWL.CreateWindow()
        end

        MHCWL.RebuildWindowContent()
        MHCWL.window:SetHidden(false)
    end
end

function MHCWL.ToggleWindowInMenu()
    if IsInteractingWithMyCompanion() then
        MHCWL.ToggleWindow()
    end
end

function MHCWL.SetUiUnlocked(unlocked)
    local isUnlocked = unlocked == true

    MHCWL.saved.settings.window.unlocked = isUnlocked
    MHCWL.saved.settings.companionButton.unlocked = isUnlocked

    if MHCWL.window
    and MHCWL.window.RefreshMoveState then
        MHCWL.window.RefreshMoveState()
    end

    if MHCWL.companionMenuButton
    and MHCWL.companionMenuButton.RefreshState then
        MHCWL.companionMenuButton.RefreshState()
    end
end

function MHCWL.Msg(text)
    d("|c88CCFF[MHCWL]|r " .. tostring(text))
end

function MHCWL.Help()
    MHCWL.Msg("/mhcwl help - Shows slash commands")
    MHCWL.Msg("/mhcwl unlockui - Unlock movable UI elements")
    MHCWL.Msg("/mhcwl lockui - Lock movable UI elements")

    if not MHCWL.IsDebugEnabled() then
        MHCWL.Msg("Enable debug mode in settings for developer commands.")
        return
    end

    MHCWL.Debug("Developer commands:")
    MHCWL.Debug("/mhcwl context")
    MHCWL.Debug("/mhcwl companion")
    MHCWL.Debug("/mhcwl gear")
    MHCWL.Debug("/mhcwl skills")
    MHCWL.Debug("/mhcwl saved")
    MHCWL.Debug("/mhcwl skilllines")
    MHCWL.Debug("/mhcwl debugall")
    MHCWL.Debug("/mhcwl save")
    MHCWL.Debug("/mhcwl load")
    MHCWL.Debug("/mhcwl verify")
    MHCWL.Debug("/mhcwl loadverify")
    MHCWL.Debug("/mhcwl loadgearall")
    MHCWL.Debug("/mhcwl loadskillsall")
    MHCWL.Debug("/mhcwl storegear")
    MHCWL.Debug("/mhcwl list")
    MHCWL.Debug("/mhcwl slot 1")
    MHCWL.Debug("/mhcwl rename 1 My Build")
    MHCWL.Debug("/mhcwl ui")
end

function MHCWL.SlashCommand(arg)
    arg = string.lower(arg or "")

    local command, value = string.match(arg, "^(%S+)%s*(.*)$")
    -- place user facing slash commands below:
    if arg == "unlockui" then
        MHCWL.SetUiUnlocked(true)
        return
    elseif arg == "lockui" then
        MHCWL.SetUiUnlocked(false)
        return
    end

    -- dev slash commands gate
    if arg == "help" then
        MHCWL.Help()
        return
    end

    if not MHCWL.IsDebugEnabled() then
        MHCWL.Msg("Enable debug mode in settings for developer commands.")
        return
    end

    -- developer / debug commands
    if command == "slot" then
        MHCWL.SetActiveSetup(value)
        return
    end

    if command == "rename" then
        local index, name = string.match(value or "", "^(%d+)%s+(.+)$")
        MHCWL.RenameSetup(index, name)
        return
    end

    if arg == "context" then
        MHCWL.DebugContext()
    elseif arg == "companion" then
        MHCWL.DebugCompanion()
    elseif arg == "gear" then
        MHCWL.DebugGear()
    elseif arg == "skills" then
        MHCWL.DebugSkills()
    elseif arg == "saved" then
        MHCWL.DebugSaved()
    elseif arg == "skilllines" then
        MHCWL.DebugCompanionSkillLines()
    elseif arg == "debugall" then
        MHCWL.DebugAll()
    elseif arg == "save" then
        MHCWL.SaveCurrent()
    elseif arg == "loadgearall" then
        MHCWL.LoadGearAll()
    elseif arg == "loadskillsall" then
        MHCWL.LoadSkillsAll()
    elseif arg == "load" then
        MHCWL.LoadSetup()
    elseif arg == "verify" then
        MHCWL.VerifySetup()
    elseif arg == "loadverify" then
        MHCWL.LoadAndVerify()
    elseif arg == "list" then
        MHCWL.ListSetups()
    elseif arg == "ui" then
        MHCWL.ToggleWindow()
    else
        MHCWL.Help()
    end
end

function MHCWL.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= MHCWL.name then return end

    EVENT_MANAGER:UnregisterForEvent(MHCWL.name, EVENT_ADD_ON_LOADED)

    MHCWL.InitializeSavedVars()
    MHCWL.InitializeSettingsMenu()

    SLASH_COMMANDS["/mhcwl"] = MHCWL.SlashCommand

    MHCWL.Debug("Loaded. Use /mhcwl")
    MHCWL.RegisterCompanionEvents()
end

EVENT_MANAGER:RegisterForEvent(MHCWL.name, EVENT_ADD_ON_LOADED, MHCWL.OnAddOnLoaded)