HideUI = HideUI or {}
HideUI.name = "HideUI"

-- This stuff should be put in either OnInitialized or OnPlayerActivated, but I'm leaving it as is
ZO_ChatWindowMinBar:SetAlpha(0) -- Chat Bar
ZO_UnitFramesGroups:SetHidden(true) -- Group frame
ZO_FocusedQuestTrackerPanel:SetHidden(true) -- Quest Tracker
ZO_ActionBar1KeybindBG:SetAlpha(0) -- Action Bar keybind
ZO_ActionBar1WeaponSwap:SetAlpha(0) -- Weapon swap


---------------------------------------------------------------------
-- The first time after a log in or reload when the player is activated
local function OnPlayerActivated()
    -- Only run this once ever
    EVENT_MANAGER:UnregisterForEvent(HideUI.name, EVENT_PLAYER_ACTIVATED)

    -- Put things that need to be run after player is loaded here
    HideUI.InitializeReticle()
end

---------------------------------------------------------------------
-- On init
local function OnInitialized()
    -- Listen for the player activation, i.e. when the character is loaded in
    EVENT_MANAGER:RegisterForEvent(HideUI.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

---------------------------------------------------------------------
-- On Load
local function OnAddOnLoaded(_, addonName)
    if (addonName == HideUI.name) then
        -- Only run this once ever
        EVENT_MANAGER:UnregisterForEvent(HideUI.name, EVENT_ADD_ON_LOADED)

        OnInitialized()
    end
end

EVENT_MANAGER:RegisterForEvent(HideUI.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
