-- BuildTracker_Settings.lua
--
-- LibAddonMenu-2.0 options panel - re-added as a real DependsOn here (it was
-- removed earlier in this project's life as declared-but-unused) now that
-- the loot-alert feature genuinely needs a configuration UI for its three
-- independent toggles, per user request.
--
-- Initialize() must be called from BuildTracker's own EVENT_ADD_ON_LOADED
-- handler (BuildTracker.lua), NOT run directly at this file's top level.
-- First attempt did exactly that and hit LAM's own safety warning in-game:
-- "[LAM2] The panel with id 'BuildTracker_LAMPanel' was registered before
-- addon loading has completed." Root cause: ESO's addon bootstrap has two
-- separate passes - first every enabled addon's Lua files execute their
-- top-level code in dependency order (so LibAddonMenu2 exists as a global
-- by the time this file's code RUNS), and only afterward does it go back
-- and fire EVENT_ADD_ON_LOADED for each addon in order. LAM's own
-- "safeToInitialize" flag is only set true once ITS EVENT_ADD_ON_LOADED
-- has actually fired in that second pass - calling RegisterAddonPanel
-- during the first (file-execution) pass runs before that flag flips, even
-- though the global itself is already available. Every other LAM-using
-- addon checked (LootDrop, PotionMaker, etc.) registers its panel from
-- inside its own addon-loaded flow for exactly this reason - matched here.

BuildTracker = BuildTracker or {}
BuildTracker.Settings = {}

function BuildTracker.Settings.Initialize()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local Data = BuildTracker.Data

    local panelData = {
        type = "panel",
        name = BuildTracker.displayName,
        displayName = BuildTracker.displayName,
        author = "Arandul",
        version = BuildTracker.version,
        registerForRefresh = true,
    }
    BuildTracker.settingsPanel = LAM:RegisterAddonPanel("BuildTracker_LAMPanel", panelData)

    local optionsTable = {
        {
            type = "header",
            name = "Loot Alerts",
        },
        {
            type = "checkbox",
            name = "Enable loot alerts",
            tooltip = "Show a chat message when you or a groupmate loots an item matching a piece a registered build still needs.",
            getFunc = Data.GetNotifyOnLoot,
            setFunc = Data.SetNotifyOnLoot,
            default = true,
        },
        {
            type = "checkbox",
            name = "Alert on my own loot",
            getFunc = Data.GetNotifyOnLootSelf,
            setFunc = Data.SetNotifyOnLootSelf,
            default = true,
            disabled = function() return not Data.GetNotifyOnLoot() end,
        },
        {
            type = "checkbox",
            name = "Alert on groupmate loot",
            tooltip = "Useful for Need/Greed or Round Robin loot rules - lets you know a groupmate got something you need, since most items stay tradeable for a couple hours after looting.",
            getFunc = Data.GetNotifyOnLootGroup,
            setFunc = Data.SetNotifyOnLootGroup,
            default = true,
            disabled = function() return not Data.GetNotifyOnLoot() end,
        },
        {
            type = "colorpicker",
            name = "My loot alert color",
            tooltip = "Chat text color for alerts triggered by your own loot.",
            getFunc = Data.GetSelfLootColor,
            setFunc = Data.SetSelfLootColor,
            default = { r = 1, g = 0.84, b = 0 },
            disabled = function() return not Data.GetNotifyOnLoot() or not Data.GetNotifyOnLootSelf() end,
        },
        {
            type = "colorpicker",
            name = "Groupmate loot alert color",
            tooltip = "Chat text color for alerts triggered by a groupmate's loot.",
            getFunc = Data.GetGroupLootColor,
            setFunc = Data.SetGroupLootColor,
            default = { r = 0.3, g = 0.7, b = 1 },
            disabled = function() return not Data.GetNotifyOnLoot() or not Data.GetNotifyOnLootGroup() end,
        },
        {
            type = "header",
            name = "Advanced",
        },
        {
            type = "checkbox",
            name = "Show debug commands in /bt help",
            tooltip = "The /bt debug* commands (debuglibsets, debugitem, debugfindpiece, debugcollection, debugsetitems, debugsource) are troubleshooting/diagnostic tools - they still work either way, this just controls whether /bt's help text advertises them.",
            getFunc = Data.GetShowDebugCommands,
            setFunc = Data.SetShowDebugCommands,
            default = false,
        },
    }
    LAM:RegisterOptionControls("BuildTracker_LAMPanel", optionsTable)
end
