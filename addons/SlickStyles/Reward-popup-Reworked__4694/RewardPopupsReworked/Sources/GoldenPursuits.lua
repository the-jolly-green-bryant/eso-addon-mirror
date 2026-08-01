local RPR = RewardPopupsReworked

local source = {
    id = "goldenPursuits",
    displayName = "Golden Pursuits",
    settingsKey = "goldenPursuits",
    replaceSetting = "replacePopup",
    autoClaimSetting = "autoClaimSafeRewards",
    priority = 100,
    claimedMessage = "Golden Pursuits rewards claimed.",
    manualMessage = "Golden Pursuits rewards require manual review.",
    widgetFrame = "/RewardPopupsReworked/textures/gold_frame.dds",
    widgetIcon = "/RewardPopupsReworked/textures/golden.dds",
    widgetGlow = "/RewardPopupsReworked/textures/glow.dds",
    widgetGlowColor = { 1.00, 0.65, 0.15, 1.00 }, -- Gold
}

RPR.ApplySourceBase(source)

local PROMOTIONAL_EVENT_CALLBACKS = {
    "CampaignsUpdated",
    "CampaignSeenStateChanged",
    "RewardsClaimed",
    "ActivityProgressUpdated",
    "CapstoneDialogClosed",
}

local function ShouldSuppressClaimablePrompt()
    return RPR.savedVars
        and RPR.savedVars.general.enabled == true
        and source:IsReplacementEnabled()
end

function source:Initialize()
    self:InstallClaimableOverride()
    self:RegisterPromotionalEventCallbacks()
end

function source:InstallClaimableOverride()
    if self.claimableOverrideInstalled then return end

    local managerClass = ZO_PromotionalEvent_Manager
    if not managerClass or type(managerClass.IsAnyRewardClaimable) ~= "function" then
        return
    end

    self.originalIsAnyRewardClaimable = managerClass.IsAnyRewardClaimable

    managerClass.IsAnyRewardClaimable = function(manager, ...)
        if ShouldSuppressClaimablePrompt() then
            RPR:Debug("Golden Pursuits claimable prompt suppressed")
            if RPR.RewardManager and RPR.RewardManager.RefreshLater then
                RPR.RewardManager:RefreshLater("golden claimable suppressed")
            end

            return false
        end

        return source.originalIsAnyRewardClaimable(manager, ...)
    end

    self.claimableOverrideInstalled = true
end

function source:RegisterPromotionalEventCallbacks()
    if self.callbacksRegistered then return end

    local manager = PROMOTIONAL_EVENT_MANAGER
    if not manager or type(manager.RegisterCallback) ~= "function" then
        return
    end

    for _, callbackName in ipairs(PROMOTIONAL_EVENT_CALLBACKS) do
        manager:RegisterCallback(callbackName, function()
            RPR:Debug("Golden callback: " .. tostring(callbackName))
            if RPR.RewardManager and RPR.RewardManager.RefreshLater then
                RPR.RewardManager:RefreshLater("golden callback: " .. callbackName)
            end
        end)
    end

    self.callbacksRegistered = true
end

function source:IsAnyRewardClaimable()
    self:InstallClaimableOverride()

    local manager = PROMOTIONAL_EVENT_MANAGER
    local original = self.originalIsAnyRewardClaimable

    if not manager or type(original) ~= "function" then
        return false
    end

    local ok, claimable = pcall(original, manager)
    RPR:Debug("Golden claimable check: " .. tostring(ok and claimable == true))
    return ok and claimable == true
end

function source:DetectPending()
    self:InstallClaimableOverride()
    self:RegisterPromotionalEventCallbacks()

    if not self:IsAnyRewardClaimable() then
        return nil
    end

    return {
        source = self,
        count = 1,
        requiresManual = true,
        safeToClaim = false,
    }
end

function source:IsSafeToAutoClaim(pending)
    return pending and pending.safeToClaim == true
end

function source:ClaimSafe()
    return false
end

function source:CanAttemptManualClaim(pending)
    return self:IsSafeToAutoClaim(pending)
end

function source:ShouldUseWidget(pending)
    return pending
        and pending.requiresManual == true
        and self:GetSettings().enableActionWidget ~= false
end

function source:OpenInterface()
    if PROMOTIONAL_EVENT_MANAGER and PROMOTIONAL_EVENT_MANAGER.ShowPromotionalEventScene then
        local SCROLL_TO_FIRST_CLAIMABLE_REWARD = true
        PROMOTIONAL_EVENT_MANAGER:ShowPromotionalEventScene(SCROLL_TO_FIRST_CLAIMABLE_REWARD)
        return true
    end

    return false
end

RPR:RegisterSource(source)
