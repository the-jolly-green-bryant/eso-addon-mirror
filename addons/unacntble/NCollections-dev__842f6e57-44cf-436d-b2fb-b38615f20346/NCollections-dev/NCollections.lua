local ADDON_NAME = "NCollections-dev"
local DEFAULT_ADDON_VERSION = 0
local SOURCE_DEV_MODE = true

local function GetAddonVersion()
    if not GetAddOnManager then
        return DEFAULT_ADDON_VERSION
    end

    local addonManager = GetAddOnManager()
    if not addonManager or not addonManager.GetNumAddOns or not addonManager.GetAddOnInfo
        or not addonManager.GetAddOnVersion then
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

NCollections = NCollections or {}
NCollections.name = ADDON_NAME
NCollections.version = GetAddonVersion()

function NCollections.IsDevMode()
    return SOURCE_DEV_MODE or NCollections.name == "NCollections-dev"
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    NCollections.version = GetAddonVersion()
    NCollections.Lexicon.Initialize()

    NCollections.ItemLocator.InitializeSavedVariables()
    NCollections.Features.CollectionsGear.InitializeSavedVariables()
    NCollections.Features.CollectionsGearCrafted.InitializeSavedVariables()
    NCollections.Features.CollectionsRecipes.InitializeSavedVariables()
    NCollections.Features.CollectionsHousing.InitializeSavedVariables()
    NCollections.Features.CollectionsMounts.InitializeSavedVariables()
    NCollections.Features.CollectionsSkins.InitializeSavedVariables()
    NCollections.Features.CollectionsPets.InitializeSavedVariables()
    NCollections.Features.CollectionsMementos.InitializeSavedVariables()
    NCollections.Features.CollectionsCompanions.InitializeSavedVariables()
    for _, feature in ipairs(NCollections.Features.ExtendedCollectionFeatures or {}) do
        feature.InitializeSavedVariables()
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)

        NCollections.ItemLocator.Initialize()
        NCollections.Features.CollectionsGear.Initialize()
        NCollections.Features.CollectionsGearCrafted.Initialize()
        NCollections.Features.CollectionsRecipes.Initialize()
        NCollections.Features.CollectionsHousing.Initialize()
        NCollections.Features.CollectionsMounts.Initialize()
        NCollections.Features.CollectionsSkins.Initialize()
        NCollections.Features.CollectionsPets.Initialize()
        NCollections.Features.CollectionsMementos.Initialize()
        NCollections.Features.CollectionsCompanions.Initialize()
        for _, feature in ipairs(NCollections.Features.ExtendedCollectionFeatures or {}) do
            feature.Initialize()
        end
        NCollections.GamepadOptions.Initialize()
    end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
