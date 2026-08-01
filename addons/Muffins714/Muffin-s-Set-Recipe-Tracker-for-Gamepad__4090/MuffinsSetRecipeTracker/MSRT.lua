-- Create the global namespace for the addon
MuffinsSetRecipeTracker = MuffinsSetRecipeTracker or {}

-- Create a local shortcut for global
local MSRT = MuffinsSetRecipeTracker

-- AddOn information
MSRT.name = "MuffinsSetRecipeTracker"
MSRT.prefix = "MSRT"
MSRT.version = "1.6.1"
MSRT.author = "Muffins714"
MSRT.website = "https://www.esoui.com/downloads/info4090-MuffinsSetampRecipeTracker.html"

-- Holds our SavedVariable data
MSRT.GlobalSavedVars = MSRT.GlobalSavedVars or {}
MSRT.SavedVars = MSRT.SavedVars or {}

-- Default values for SavedVariable
local defaults = {
    -- global vs char switch
    useGlobalSettings      = true,

    -- Motif tooltip settings
    useSelectedMotif       = false,
    selectedCharName       = "",
    -- Nickname settings
    useNicknames           = false,
    charNicknames          = {},

    -- Sets
    HideCompletedSetPieces = false,
    HideCompletedSetPage   = false,
    showSetBookPieces      = false,
    showSetBookFragments   = false,
}

-- Called when any addon is loaded
function MSRT.OnAddOnLoaded(event, addonName)
    if addonName ~= MSRT.name then return end
    EVENT_MANAGER:UnregisterForEvent(MSRT.name, EVENT_ADD_ON_LOADED)

    --Load both account wide and character SavedVars
    MSRT.GlobalSavedVars = ZO_SavedVars:NewAccountWide("MSRTGlobalSavedVars", 1, nil, defaults, GetWorldName()) --account wide
    MSRT.SavedVars = ZO_SavedVars:NewCharacterIdSettings("MSRTSavedVars", 1, nil, defaults, GetWorldName())

    -- Remove
    MSRT.GlobalSavedVars.worldname = nil
    MSRT.SavedVars.worldname = nil

    -- Default to account wide settings
    if MSRT.GlobalSavedVars.useGlobalSettings == nil then
        MSRT.GlobalSavedVars.useGlobalSettings = true
    end

    if MSRT.GlobalSavedVars.useGlobalSettings then
        MSRT.SavedVars = MSRT.GlobalSavedVars
    else
        MSRT.SavedVars = MSRT.SavedVars
    end

    -- Make our options menu
    MSRT.CreateSettingsMenu(defaults)
    zo_callLater(function()
        MSRT_Initialize()
        MSRT_Initialize2()
    end, 100)
end

-- Register event for when any addon (including ours) is loaded
EVENT_MANAGER:RegisterForEvent(MSRT.name, EVENT_ADD_ON_LOADED, MSRT.OnAddOnLoaded)
