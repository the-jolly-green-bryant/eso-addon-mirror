local RPR = RewardPopupsReworked

local source = {
    id = "tamrielTomes",
    displayName = "Tamriel Tomes",
    settingsKey = "tamrielTomes",
    replaceSetting = "replacePopup",
    autoClaimSetting = "autoClaimRewards",
    safeByDefault = true,
    priority = 50,
    claimedMessage = "Tamriel Tome rewards claimed.",
    widgetFrame = "/RewardPopupsReworked/textures/silver_frame.dds",
    widgetIcon = "/RewardPopupsReworked/textures/tome.dds",
    widgetGlow = "/RewardPopupsReworked/textures/glow.dds",
    widgetGlowColor = { 0.10, 0.45, 0.95, 1.00 }, -- Blue   
}

RPR.ApplySourceBase(source)

local function ShouldSuppressHUDPrompt()
    return RPR.savedVars
        and RPR.savedVars.general.enabled == true
        and source:IsReplacementEnabled()
end

function source:Initialize()
    self:InstallTimedActivityHUDPromptOverride()
    self:RegisterTimedActivityEvents()
end

function source:InstallTimedActivityHUDPromptOverride()
    if self.hudPromptOverridesInstalled then return end

    local manager = TIMED_ACTIVITIES_MANAGER
    if not manager then return end

    local originalGetFirst =
        manager.GetFirstClaimableTimedActivityForHUDPrompt

    local originalHasClaimable =
        manager.HasClaimableTimedActivitiesForHUDPrompt

    if type(originalGetFirst) ~= "function"
        or type(originalHasClaimable) ~= "function" then
        return
    end

    self.originalGetFirstClaimableTimedActivityForHUDPrompt = originalGetFirst
    self.originalHasClaimableTimedActivitiesForHUDPrompt = originalHasClaimable

    manager.GetFirstClaimableTimedActivityForHUDPrompt =
        function(managerInstance, timedActivityType)

            if ShouldSuppressHUDPrompt() then
                if RPR.RewardManager and RPR.RewardManager.RefreshLater then
                    RPR.RewardManager:RefreshLater(
                        "timed activity HUD prompt suppressed"
                    )
                end

                -- Returning nil tells the HUD there is no reward
                -- that should produce a claim prompt.
                return nil
            end

            return source.originalGetFirstClaimableTimedActivityForHUDPrompt(
                managerInstance,
                timedActivityType
            )
        end

    manager.HasClaimableTimedActivitiesForHUDPrompt =
        function(managerInstance, timedActivityType)

            if ShouldSuppressHUDPrompt() then
                return false
            end

            return source.originalHasClaimableTimedActivitiesForHUDPrompt(
                managerInstance,
                timedActivityType
            )
        end

    self.hudPromptOverridesInstalled = true
end

function source:RegisterTimedActivityEvents()
    if self.eventsRegistered then return end
    self.eventsRegistered = true

    local function RefreshLater()
        RPR:Debug("timed activity event")
        if RPR.RewardManager and RPR.RewardManager.RefreshLater then
            RPR.RewardManager:RefreshLater("timed activity event")
        end
    end

    local events = {
        TimedActivitiesUpdated = EVENT_TIMED_ACTIVITIES_UPDATED,
        TimedActivityProgressUpdated = EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED,
        TimedActivityRewardClaimed = EVENT_REWARD_TRACK_REWARD_CLAIMED,
        TimedActivityRewardsClaimed = EVENT_REWARD_TRACK_REWARDS_CLAIMED,
    }

    for eventName, eventId in pairs(events) do
        if eventId then
            EVENT_MANAGER:RegisterForEvent(RPR.name .. eventName, eventId, RefreshLater)
        end
    end
end

function source:DetectPending()
    self:InstallTimedActivityHUDPromptOverride()

    local manager = TIMED_ACTIVITIES_MANAGER

    if manager and type(manager.HasClaimableTimedActivities) == "function" then
        local ok, hasClaimable = pcall(manager.HasClaimableTimedActivities, manager)
        if ok and hasClaimable then
            RPR:Debug("Tamriel Tomes claimable")
            return {
                source = self,
                count = 1,
                requiresManual = not self:IsAutoClaimEnabled(),
            }
        end
    end

    if manager and type(manager.GetFirstClaimableTimedActivity) == "function" then
        local ok, activityData = pcall(manager.GetFirstClaimableTimedActivity, manager)
        if ok and activityData then
            RPR:Debug("Tamriel Tome activity data claimable")
            return {
                source = self,
                count = 1,
                requiresManual = not self:IsAutoClaimEnabled(),
                activityData = activityData,
            }
        end
    end

    return RPR.SourceBase.DetectPending(self)
end

function source:ClaimSafe(pending)
    self:InstallTimedActivityHUDPromptOverride()

    local manager = TIMED_ACTIVITIES_MANAGER

    if manager
        and type(manager.HasClaimableTimedActivities) == "function"
        and type(manager.ClaimAllRewards) == "function" then

        local hasOk, hasClaimable = pcall(manager.HasClaimableTimedActivities, manager)
        if hasOk and hasClaimable then
            RPR:Debug("Tamriel Tome ClaimAllRewards")
            local claimOk, result = pcall(manager.ClaimAllRewards, manager)
            if claimOk and result ~= false then
                return true
            end
        end
    end

    if not pending then
        return false
    end

    if RPR.Utils.CallFirst(self.api and self.api.claimSafe) then
        return true
    end

    local activityData = pending.activityData

    if not activityData and manager and type(manager.GetFirstClaimableTimedActivity) == "function" then
        local ok, result = pcall(manager.GetFirstClaimableTimedActivity, manager)
        if ok then
            activityData = result
        end
    end

    if activityData and type(activityData.Claim) == "function" then
        RPR:Debug("Tamriel Tome activityData:Claim")
        local ok, result = pcall(activityData.Claim, activityData)
        if ok and result ~= false then
            return true
        end
    end

    return false
end

function source:OpenInterface()
    self:InstallTimedActivityHUDPromptOverride()

    local manager = TIMED_ACTIVITIES_MANAGER

    if manager and type(manager.ShowTimedActivitiesScene) == "function" then
        local activityData

        if type(manager.GetFirstClaimableTimedActivity) == "function" then
            local ok, result = pcall(manager.GetFirstClaimableTimedActivity, manager)
            if ok then
                activityData = result
            end
        end

        local ok = pcall(manager.ShowTimedActivitiesScene, manager, activityData)
        if ok then
            return true
        end
    end

    if SYSTEMS and type(SYSTEMS.ShowScene) == "function" then
        local ok = pcall(SYSTEMS.ShowScene, SYSTEMS, "timedActivities")
        if ok then
            return true
        end
    end

    return RPR.SourceBase.OpenInterface(self)
end

function source:ShouldUseWidget(pending)
    return pending
        and self:IsReplacementEnabled()
        and not self:IsAutoClaimEnabled()
end

RPR:RegisterSource(source)
