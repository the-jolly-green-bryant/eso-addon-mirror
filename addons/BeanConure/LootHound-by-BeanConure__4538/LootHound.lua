LootHound = {}
local addon = LootHound

-- Addon metadata
addon.name    = "LootHound"
addon.version = "1.0.0"

-- Default saved variable schema (Account-wide settings)
-- If a player has never used the addon, it starts with these values.
local DEFAULTS = {
    watchList   = {},
    alertChat   = true,
    alertSound  = true,
    alertFlash  = true,
    flashColour = "FF4400",
    flashAlpha  = 0.55,
    flashDuration = 1.2,
}

-- ─── Event Handler: Addon Loaded ────────────────────────────
-- Fires when the game is loading UI components.
local function OnAddonLoaded(event, addonName)
    -- Only run this code when LootHound itself is loading
    if addonName ~= addon.name then return end

    -- Initialize Account-wide saved variables using our DEFAULTS table
    addon.savedVars = ZO_SavedVars:NewAccountWide(
        "LootHound_SavedVars", 2, nil, DEFAULTS
    )

    -- Initialize all sub-modules
    addon.WatchList:Init()
    addon.ItemTracker:Init()
    addon.AlertSystem:Init()
    addon.GUI:Init()

    -- Print a welcome message to the player's chat box
    CHAT_SYSTEM:AddMessage("|c44FF88[LootHound]|r v" .. addon.version .. " loaded. /lh to open.")
end

-- Register the load event with ESO's Event Manager
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

-- ─── Slash Commands ─────────────────────────────────────────
-- Allows the player to open the UI by typing in the chat box
SLASH_COMMANDS["/lh"]        = function() addon.GUI:Toggle() end
SLASH_COMMANDS["/loothound"] = function() addon.GUI:Toggle() end

-- Registers the localized string for the Controls / Keybindings menu
ZO_CreateStringId("SI_BINDING_NAME_LOOTHOUND_TOGGLE_GUI", "Open/Close LootHound")