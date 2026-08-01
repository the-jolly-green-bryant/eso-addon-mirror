-----------------------------------------------------------
-- LibFilteredChatPanel
-- @author Kyzeragon
-----------------------------------------------------------

LibFilteredChatPanel = LibFilteredChatPanel or {}
local LFCP = LibFilteredChatPanel

LFCP.name = "LibFilteredChatPanel"
LFCP.version = "1.0.0"

-- Defaults
local defaultOptions = {
    expanded = true,
    window = {
        left = GuiRoot:GetWidth() - 530,
        top = GuiRoot:GetHeight() / 2 - 70 - 350,
        width = 530,
        height = 700,
    },
    fontSize = 13,
    toggles = {},
}

---------------------------------------------------------------------
-- Initialize 
local function Initialize()
    -- Settings and saved variables
    LFCP.savedOptions = ZO_SavedVars:NewAccountWide("LibFilteredChatPanelSavedVariables", 1, "Options", defaultOptions)

    LFCP.InitializeWindow()

    LFCP.CreateSettingsMenu()
end

---------------------------------------------------------------------
-- On Load
local function OnAddOnLoaded(_, addonName)
    if addonName == LFCP.name then
        EVENT_MANAGER:UnregisterForEvent(LFCP.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(LFCP.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

