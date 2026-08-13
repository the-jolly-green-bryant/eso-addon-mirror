local ADDON_NAME = "NQOL"
local DEFAULT_ADDON_VERSION = 0
local SOURCE_DEV_MODE = false

local function GetAddonVersion()
    if not GetAddOnManager then
        return DEFAULT_ADDON_VERSION
    end

    local addonManager = GetAddOnManager()
    if not addonManager or not addonManager.GetNumAddOns or not addonManager.GetAddOnInfo or not addonManager.GetAddOnVersion then
        return DEFAULT_ADDON_VERSION
    end

    for addonIndex = 1, addonManager:GetNumAddOns() do
        local addonName = addonManager:GetAddOnInfo(addonIndex)
        if addonName == ADDON_NAME then
            return addonManager:GetAddOnVersion(addonIndex)
        end
    end

    return DEFAULT_ADDON_VERSION
end

NQOL = NQOL or {}
NQOL.name = ADDON_NAME
NQOL.version = GetAddonVersion()

function NQOL.IsDevMode()
    return SOURCE_DEV_MODE or NQOL.name == "NQOL-dev"
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    NQOL.version = GetAddonVersion()
    NQOL.Lexicon.Initialize()

    NQOL.FirstRun.InitializeSavedVariables()
    NQOL.WhatsNew.InitializeSavedVariables()
    NQOL.Features.Mounts.InitializeSavedVariables()
    NQOL.Features.Antiquities.InitializeSavedVariables()
    NQOL.Features.Gear.InitializeSavedVariables()
    NQOL.Features.Provisioning.InitializeSavedVariables()
    NQOL.Features.Map.InitializeSavedVariables()
    NQOL.Features.Minimap.InitializeSavedVariables()
    NQOL.Features.Fishing.InitializeSavedVariables()
    NQOL.Features.UI.InitializeSavedVariables()
    NQOL.Features.Camera.InitializeSavedVariables()
    NQOL.Features.UIPlayerInfo.InitializeSavedVariables()
    NQOL.Features.PlayerBars.InitializeSavedVariables()
    NQOL.Features.Chat.InitializeSavedVariables()
    NQOL.Features.ChatReminders.InitializeSavedVariables()
    NQOL.Features.Friends.InitializeSavedVariables()
    NQOL.Features.GroupFinderMonitor.InitializeSavedVariables()
    NQOL.Features.Grouping.InitializeSavedVariables()
    NQOL.Features.TomePoints.InitializeSavedVariables()
    NQOL.Features.VeterancyRewards.InitializeSavedVariables()
    NQOL.Features.TransmuteWatch.InitializeSavedVariables()
    NQOL.Features.SkipLogoutConfirmation.InitializeSavedVariables()
    NQOL.Features.Positioning.InitializeSavedVariables()
    NQOL.Features.LuaGc.InitializeSavedVariables()
    NQOL.Features.UltimateCountdown.InitializeSavedVariables()
    NQOL.Features.TrialTimer.InitializeSavedVariables()
    NQOL.Features.CombatInfiniteArchive.InitializeSavedVariables()
    NQOL.Features.CombatMiscellaneous.InitializeSavedVariables()
    NQOL.Features.BuffsDebuffs.InitializeSavedVariables()
    NQOL.Features.Ticker.InitializeSavedVariables()
    NQOL.Features.Progress.InitializeSavedVariables()
    NQOL.Features.ProgressGold.InitializeSavedVariables()
    NQOL.Features.ProgressDungeons.InitializeSavedVariables()
    NQOL.Features.ProgressTrials.InitializeSavedVariables()
    NQOL.Features.ProgressArenas.InitializeSavedVariables()
    NQOL.Features.ProgressInfiniteArchive.InitializeSavedVariables()
    if NQOL.IsDevMode() then
        NQOL.Features.Debug.InitializeSavedVariables()
    end
    NQOL.Settings.RemovePath({ "collections" })
    NQOL.Settings.RemovePath({ "mounts", "randomMount" })
    NQOL.Settings.RemovePath({ "ui", "customFrames", "playerFrame", "defaultFrame" })
    NQOL.Settings.RemovePath({ "ui", "customFrames", "companionFrame", "defaultFrame" })
    NQOL.Settings.RemovePath({ "ui", "customFrames", "groupFrame", "defaultFrame" })
    NQOL.Settings.RemovePath({ "utility", "cameraSensitivity" })
    NQOL.Features.SlashCommands.Initialize()
    NQOL.Features.Chat.Initialize()
    NQOL.Features.ChatMissingItemRequests.Initialize()
    NQOL.Features.ChatReminders.Initialize()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)

        NQOL.Features.Mounts.Initialize()
        NQOL.Features.Antiquities.Initialize()
        NQOL.Features.Gear.Initialize()
        NQOL.Features.Provisioning.Initialize()
        NQOL.Features.Map.Initialize()
        NQOL.Features.MapTravelTabs.Initialize()
        NQOL.Features.Minimap.Initialize()
        NQOL.Features.Fishing.Initialize()
        NQOL.Features.Freeport.Initialize()
        NQOL.Features.Camera.Initialize()
        NQOL.Features.UI.Initialize()
        NQOL.Features.UIPlayerInfo.Initialize()
        NQOL.Features.PlayerBars.Initialize()
        NQOL.Features.Grouping.Initialize()
        NQOL.Features.TomePoints.Initialize()
        NQOL.Features.VeterancyRewards.Initialize()
        NQOL.Features.TransmuteWatch.Initialize()
        NQOL.Features.SkipLogoutConfirmation.Initialize()
        NQOL.Features.LuaGc.Initialize()
        NQOL.Features.UltimateCountdown.Initialize()
        NQOL.Features.TrialTimer.Initialize()
        NQOL.Features.CombatInfiniteArchive.Initialize()
        NQOL.Features.CombatMiscellaneous.Initialize()
        NQOL.Features.BuffsDebuffs.Initialize()
        NQOL.Features.Ticker.Initialize()
        NQOL.Features.Friends.Initialize()
        NQOL.Features.GroupFinderMonitor.Initialize()
        NQOL.Features.Progress.Initialize()
        NQOL.Features.ProgressGold.Initialize()
        NQOL.Features.ProgressDungeons.Initialize()
        NQOL.Features.ProgressTrials.Initialize()
        NQOL.Features.ProgressArenas.Initialize()
        NQOL.Features.ProgressInfiniteArchive.Initialize()
        if NQOL.IsDevMode() then
            NQOL.Features.Debug.Initialize()
        end

        if NQOL.GamepadOptions then
            NQOL.GamepadOptions.Initialize()
        end

        local isFirstRun = NQOL.FirstRun.Initialize()
        NQOL.WhatsNew.Initialize(isFirstRun)
    end)

    NQOL.Chat.Message(NQOL.L("addon.loaded", tostring(NQOL.version)))
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
