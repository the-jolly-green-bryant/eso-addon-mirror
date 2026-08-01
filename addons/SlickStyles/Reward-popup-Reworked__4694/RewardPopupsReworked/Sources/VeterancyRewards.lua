local RPR = RewardPopupsReworked

local source = {
    id = "veterancyRewards",
    displayName = "Veterancy Rewards",
    settingsKey = "veterancyRewards",
    replaceSetting = "replaceNotification",
    autoClaimSetting = "autoClaimRewards",
    safeByDefault = true,
    priority = 10,
    claimedMessage = "Veterancy rewards claimed.",
}

RPR.ApplySourceBase(source)

local VETERANCY_CALLBACKS = {
    "OnVeterancyRankUp",
    "OnVeterancyRankClaimed",
    "OnVeterancyRepeatableRankClaimed",
}

local function RefreshLater(reason)
    if RPR.RewardManager and RPR.RewardManager.RefreshLater then
        RPR.RewardManager:RefreshLater(reason or "veterancy update")
    end
end

function source:Initialize()
    self:RegisterVeterancyCallbacks()
end

function source:RegisterVeterancyCallbacks()
    local manager = ZO_VETERANCY_MANAGER

    if not self.managerCallbacksRegistered
        and manager
        and type(manager.RegisterCallback) == "function" then

        for _, callbackName in ipairs(VETERANCY_CALLBACKS) do
            manager:RegisterCallback(callbackName, function()
                RPR:Debug("Veterancy callback: " .. tostring(callbackName))
                RefreshLater("veterancy callback: " .. callbackName)
            end)
        end

        self.managerCallbacksRegistered = true
    end

    if not self.notificationCallbackRegistered
        and CALLBACK_MANAGER
        and type(CALLBACK_MANAGER.RegisterCallback) == "function" then

        CALLBACK_MANAGER:RegisterCallback("OnVeterancyNotificationsRefreshed", function()
            RPR:Debug("Veterancy notifications refreshed")
            RefreshLater("veterancy notifications refreshed")
        end)

        self.notificationCallbackRegistered = true
    end
end

function source:DetectPending()
    self:RegisterVeterancyCallbacks()

    local manager = ZO_VETERANCY_MANAGER
    if not manager or type(manager.HasUnclaimedRankRewards) ~= "function" then
        return nil
    end

    local ok, hasRewards = pcall(manager.HasUnclaimedRankRewards, manager)
    RPR:Debug("Veterancy pending check: " .. tostring(ok and hasRewards == true))
    if ok and hasRewards then
        return {
            source = self,
            count = 1,
            requiresManual = false,
        }
    end

    return nil
end

function source:ClaimSafe()
    local manager = ZO_VETERANCY_MANAGER
    if not manager or type(manager.TryClaimAllRewards) ~= "function" then
        return false
    end

    local ok, result = pcall(manager.TryClaimAllRewards, manager)
    RPR:Debug("Veterancy TryClaimAllRewards: " .. tostring(ok and result ~= false))
    return ok and result ~= false
end

function source:IsSafeToAutoClaim()
    return true
end

function source:ShouldUseWidget()
    return false
end

function source:OpenInterface()
    return false
end

RPR:RegisterSource(source)
