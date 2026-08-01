StarNames = StarNames or {}
StarNames.name = "StarNames"
StarNames.version = "1.2.1"
StarNames.author = "|cDAFF21DonjaZero|r"

StarNames.experimental = false -- Experimental features flag for development branches

local defaultOptions = {
    firstTime = true, -- Not currently used

-- User options accessible in the settings menu
    debug = false,
    showLabels = true, -- Are star labels with the name visible or not?
    showOnMainScreen = true, -- Are star labels also shown on the main CP screen? Or just the individual trees?
    passiveLabelColor = {1, 1, 0.5},
    passiveLabelSize = 22,
    slottableLabelColor = {1, 1, 1},
    slottableLabelSize = 18,
    clusterLabelColor = {1, 0.7, 1},
    clusterLabelSize = 13,
}

----------------------------------------------------------------
-- Additional variables
local initialOpened = false
local debugFilter

----------------------------------------------------------------
-- Collect messages for displaying later when addon is not fully loaded
StarNames.dbgMessages = {}
function StarNames.dbg(msg)
    if (not msg) then return end
    if (not StarNames.savedOptions.debug) then return end
    if (debugFilter) then
        debugFilter:AddMessage(tostring(msg))
    elseif (CHAT_SYSTEM.primaryContainer) then
        d("|cDAFF21[StarNamesDebug]|r " .. tostring(msg))
    else
        StarNames.dbgMessages[#StarNames.dbgMessages + 1] = msg
    end
end

StarNames.messages = {}
function StarNames.msg(msg)
    if (not msg) then return end
    if (CHAT_SYSTEM.primaryContainer) then
        CHAT_SYSTEM:AddMessage("|cDAFF21[StarNames] " .. tostring(msg) .. "|r")
    else
        StarNames.messages[#StarNames.messages + 1] = msg
    end
end

----------------------------------------------------------------
-- Post Load (player loaded)
local function OnPlayerActivated(_, initial)
    -- Display all the delayed chat
    for i = 1, #StarNames.dbgMessages do
        d("|cDAFF21[StarNamesDebugDelayed]|r " .. tostring(StarNames.dbgMessages[i]))
    end
    StarNames.dbgMessages = {}

    for i = 1, #StarNames.messages do
        CHAT_SYSTEM:AddMessage("|cDAFF21[StarNames] " .. tostring(StarNames.messages[i]) .. "|r")
    end
    StarNames.messages = {}

    EVENT_MANAGER:UnregisterForEvent(StarNames.name .. "Activated", EVENT_PLAYER_ACTIVATED)
end

----------------------------------------------------------------
-- Register events
local function RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(StarNames.name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

----------------------------------------------------------------
-- Initialize
local function Initialize()
    -- Only using account-wide settings
    StarNames.savedOptions = ZO_SavedVars:NewAccountWide("StarNamesSavedVariables", 1, "Options", defaultOptions)

    -- Debug chat panel
    if (LibFilteredChatPanel) then
        debugFilter = LibFilteredChatPanel:CreateFilter(StarNames.name, "/esoui/art/champion/champion_icon.dds", {0.5, 0.8, 1}, false)
    end

    StarNames.dbg("Initializing...")

    StarNames.savedOptions.settingsVersion = 2 -- Not currently used, but useful to have for migrating to new settings formats

    StarNames:CreateSettingsMenu()

    ZO_CreateStringId("SI_BINDING_NAME_SN_TOGGLE_LABELS", "Toggle CP Star Labels")

    -- Register events
    RegisterEvents()

    CHAMPION_PERKS_CONSTELLATIONS_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        if (newState ~= SCENE_SHOWN) then
            return
        end
        
        -- Run this on the first time only
        if (not initialOpened) then
            initialOpened = true
            StarNames.InitLabels()
            if (StarNames.savedOptions.showLabels and StarNames.savedOptions.showOnMainScreen) then
                StarNames.RefreshLabels(true)
            end
            -- Further decisions on whether labels are shown are made in OnCanvasAnimationStopped
        end
    end)

    -- Slash command(s)
    SLASH_COMMANDS["/starnames"] = function(arg)
        if (arg == "on" or arg == "yes" or arg == "true" or arg == "1") then
            StarNames.savedOptions.showLabels = true
            StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
            StarNames.msg("Champion Point star name labels are now ON")
        elseif (arg == "off" or arg == "no" or arg == "false" or arg == "0") then
            StarNames.savedOptions.showLabels = false
            StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
            StarNames.msg("Champion Point star name labels are now OFF")
        elseif (arg == "toggle") then
            StarNames.ToggleLabels()
            if (StarNames.savedOptions.showLabels) then
                StarNames.msg("Champion Point star name labels toggled ON")
            else
                StarNames.msg("Champion Point star name labels toggled OFF")
            end
        else
            StarNames.msg("Usage: /starnames <on || off || toggle>")
        end
    end

end

----------------------------------------------------------------
-- On load
local function OnAddOnLoaded(_, addonName)
    -- TODO: Check for "DynamicCP" and try to avoid conflicts with it
    if (addonName == StarNames.name) then
        EVENT_MANAGER:UnregisterForEvent(StarNames.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(StarNames.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
