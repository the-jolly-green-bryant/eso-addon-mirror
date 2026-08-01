--------------------------------------------------
-- ShibUI Player Progress Bar Template
--------------------------------------------------
local SUI = SUI
local sv

SUI.PlayerProgressBar = SUI.PlayerProgressBar or {}
local PPB = SUI.PlayerProgressBar

local Log = function(...) SUI.Debug:Log("PlayerProgressBar", ...) end

--------------------------------------------------
-- XML Template Application
-- local PLAYER_PROGRESS_BAR = "ZO_PlayerProgressBar"
--------------------------------------------------
local function RepositionProgressBar()
    ZO_PlayerProgress:ClearAnchors()
    ZO_PlayerProgress:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 15, 60)
end

SecurePostHook(PLAYER_PROGRESS_BAR, "RefreshTemplate", function(self)
    ApplyTemplateToControl(self.barControl, "SUI_PlayerProgressBarTemplate")
    RepositionProgressBar()
end)

--------------------------------------------------
-- Runtime functions
--------------------------------------------------
-- Hook the fragment's RefreshBaseType to prevent clearing when always visible
local originalRefreshBaseType = ZO_PlayerProgressBarCurrentFragment.RefreshBaseType

function ZO_PlayerProgressBarCurrentFragment:RefreshBaseType()
    if(self:IsShowing() or sv.showPlayerProgressBar) then
        if(CanUnitGainChampionPoints("player")) then
            PLAYER_PROGRESS_BAR:SetBaseType(PPB_CP)
        else
            PLAYER_PROGRESS_BAR:SetBaseType(PPB_XP)
        end
    else
        PLAYER_PROGRESS_BAR:ClearBaseType()
    end
end

-- Initialize on player activated
local function OnPlayerActivated()
    RepositionProgressBar()
    if sv.showPlayerProgressBar and PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT then
        PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT:RefreshBaseType()
    end
end

EVENT_MANAGER:RegisterForEvent("AlwaysVisibleProgressBarInit", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

function PPB:Toggle()
    sv.showPlayerProgressBar = not sv.showPlayerProgressBar
    
    if sv.showPlayerProgressBar then
        -- Trigger a refresh to set the base type
        if PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT then
            PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT:RefreshBaseType()
        end
    else
        -- Clear base type when turning off
        PLAYER_PROGRESS_BAR:ClearBaseType()
    end

    Log("Progress bar always visible: " .. (sv.showPlayerProgressBar and "ON" or "OFF"), 0)
end

--------------------------------------------------
-- Initialization
--------------------------------------------------
function PPB:Initialize()
    sv = SUI.SavedVars.saved
    Log("Initialized")
    ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_PROGRESS_BAR_KEYBIND", "Toggle Progress Bar")    
    RepositionProgressBar()
end