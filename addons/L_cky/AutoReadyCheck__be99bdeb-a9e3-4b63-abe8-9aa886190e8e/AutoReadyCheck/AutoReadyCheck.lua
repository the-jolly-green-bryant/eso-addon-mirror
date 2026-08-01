AutoReadyCheck = AutoReadyCheck or {}

-- Addon information
AutoReadyCheck.name = "AutoReadyCheck"
AutoReadyCheck.tag = "ARC"
AutoReadyCheck.author = "@L_cky"
AutoReadyCheck.description = "Automatically accept different queues across Tamriel. Supports AvA Campaigns and all current activity types (Battlegrouns, Dungeons, Trials, Tales of Tribute, etc)."

-- Saved Variables/Configuration
AutoReadyCheck.Vars = {}
AutoReadyCheck.Vars.ref = "AutoReadyCheck_SavedVariables"
AutoReadyCheck.Vars.configVersion = 4
AutoReadyCheck.Vars.configDefaults = {
    ["configVersion"] = AutoReadyCheck.Vars.configVersion,
    ["groupEnabled"] = true,
    ["messagesEnabled"] = false,
    ["avaEnabled"] = true,
    ["bgEnabled"] = true,
    ["dungeonEnabled"] = true,
    ["vetDungeonEnabled"] = true,
    ["trialEnabled"] = true,
    ["tributeCasualEnabled"] = true,
    ["tributeCompEnabled"] = true,
    ["homeShowEnabled"] = true,
    ["explorationEnabled"] = true,
    ["arenaEnabled"] = true,
    ["endlessDungeonEnabled"] = true,
    0
}


--- Addon Setup
local function OnAddOnLoaded(event, addonName)
    if addonName ~= AutoReadyCheck.name then return end

    EVENT_MANAGER:UnregisterForEvent(AutoReadyCheck.name, EVENT_ADD_ON_LOADED)

    -- Account Wide Settings
    AutoReadyCheck.settings = ZO_SavedVars:NewAccountWide(
        AutoReadyCheck.Vars.ref,
        AutoReadyCheck.Vars.configVersion,
        AutoReadyCheck.name,
        AutoReadyCheck.Vars.configDefaults,
        GetWorldName()
    )

    AutoReadyCheck:BuildMenu()
end

-- Re initialize modules on reloads and zone changes
local function OnPlayerActivated()
    AutoReadyCheck:InitGroupElection()
    AutoReadyCheck:InitLFGReadyCheck()
    AutoReadyCheck:InitAvACampaign()
end

-- Register Addon Load
EVENT_MANAGER:RegisterForEvent(AutoReadyCheck.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- Register player activation
EVENT_MANAGER:RegisterForEvent(AutoReadyCheck.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

-- Slash Commands
SLASH_COMMANDS['/autoreadycheck'] = AutoReadyCheck.OpenPanel
SLASH_COMMANDS['/arc'] = AutoReadyCheck.OpenPanel