local RPR = RewardPopupsReworked

RPR.RewardManager = {
    manualSources = {},
    refreshing = false,
}

local Manager = RPR.RewardManager

local EVENTS = {
    "EVENT_PLAYER_ACTIVATED",
    "EVENT_COLLECTIBLE_UPDATED",
    "EVENT_CURRENCY_UPDATE",
    "EVENT_INVENTORY_SINGLE_SLOT_UPDATE",
    "EVENT_QUEST_COMPLETE",
    "EVENT_TIMED_ACTIVITIES_UPDATED",
    "EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED",
    "EVENT_REWARD_TRACK_REWARD_CLAIMED",
    "EVENT_REWARD_TRACK_REWARDS_CLAIMED",
}

function Manager:Initialize()
    RPR:Debug("reward manager initializing")

    for _, source in ipairs(RPR.sourceOrder) do
        if source.Initialize then
            source:Initialize()
        end
        if RPR.PopupSuppressor and RPR.PopupSuppressor.Install then
            RPR.PopupSuppressor:Install(source)
        end
    end

    if RPR.Utils and RPR.Utils.RegisterForExistingEvents then
        RPR.Utils.RegisterForExistingEvents(RPR.name .. "Rewards", EVENTS, function()
            self:RefreshLater("event")
        end)
    end

    EVENT_MANAGER:RegisterForUpdate(RPR.name .. "RewardPoll", 3000, function()
        self:Refresh("poll")
    end)

    self:RefreshLater("startup", 500)
end

function Manager:RefreshLater(reason, delayMs)
    delayMs = delayMs or 150
    RPR:Debug("refresh queued: " .. tostring(reason or "unknown"))
    EVENT_MANAGER:UnregisterForUpdate(RPR.name .. "DeferredRewardRefresh")
    EVENT_MANAGER:RegisterForUpdate(RPR.name .. "DeferredRewardRefresh", delayMs, function()
        EVENT_MANAGER:UnregisterForUpdate(RPR.name .. "DeferredRewardRefresh")
        self:Refresh(reason)
    end)
end

function Manager:Refresh(reason)
    if self.refreshing then return end
    self.refreshing = true
    RPR:Debug("refresh started: " .. tostring(reason or "unknown"))

    local general = RPR.savedVars and RPR.savedVars.general
    if not general or general.enabled == false then
        self.manualSources = {}
        if RPR.ActionWidget and RPR.ActionWidget.SetPendingSources then
            RPR.ActionWidget:SetPendingSources({})
        end
        self.refreshing = false
        return
    end

    local manualSources = {}
    local signatureParts = {}
    local manualMessages = {}

    for _, source in ipairs(RPR.sourceOrder) do
        if RPR.PopupSuppressor and RPR.PopupSuppressor.Install then
            RPR.PopupSuppressor:Install(source)
        end

        if source:IsReplacementEnabled() and RPR.PopupSuppressor and RPR.PopupSuppressor.SuppressNow then
            RPR.PopupSuppressor:SuppressNow(source)
        end

        local pending = source:DetectPending()
        if pending then
            RPR:Debug("pending detected: " .. tostring(source.id))
            local claimed = false
            if source:IsAutoClaimEnabled() and source:IsSafeToAutoClaim(pending) then
                RPR:Debug("claim attempt: " .. tostring(source.id))
                local ok = source:ClaimSafe(pending)
                if ok then
                    RPR:Debug("claim succeeded: " .. tostring(source.id))
                    claimed = true
                    if source.claimedMessage then
                        RPR:Notify(source.claimedMessage)
                    end
                    self:RefreshLater(source.id .. " claimed", 1000)
                else
                    RPR:Debug("claim failed: " .. tostring(source.id))
                    RPR:NotifyOnce(source.id .. "ClaimUnavailable", source.displayName .. " rewards are pending, but no supported claim API was found.")
                end
            end

            if not claimed
                and not source:IsAutoClaimEnabled()
                and source:IsReplacementEnabled()
                and source.pendingMessage
            then
                RPR:NotifyOnce(source.id .. "Pending", source.pendingMessage, source.pendingMessageCooldownMs or 30000)
            end

            if not claimed and source:RequiresManualReview(pending) and source:ShouldUseWidget(pending) then
                table.insert(manualSources, source)
                table.insert(signatureParts, source.id .. ":" .. tostring(pending.count or 1))
                if source.manualMessage then
                    table.insert(manualMessages, source.manualMessage)
                end
            end
        end
    end

    local signature = table.concat(signatureParts, "|")
    if signature ~= RPR.session.manualSignature then
        RPR.session.widgetHidden = false
        RPR.session.manualSignature = signature
        for _, message in ipairs(manualMessages) do
            RPR:Notify(message)
        end
    end

    table.sort(manualSources, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)

    self.manualSources = manualSources
    RPR:Debug("manual source count: " .. tostring(#manualSources))
    if RPR.ActionWidget and RPR.ActionWidget.SetPendingSources then
        RPR.ActionWidget:SetPendingSources(manualSources)
    end
    self.refreshing = false
end

function Manager:GetPrimaryManualSource()
    return self.manualSources and self.manualSources[1] or nil
end

function Manager:OpenPrimaryManualSource()
    local source = self:GetPrimaryManualSource()
    if not source then
        RPR:Notify("No manual reward action is waiting.", true)
        return false
    end

    RPR:Debug("open primary source: " .. tostring(source.id))
    if source:OpenInterface() then
        return true
    end

    RPR:Notify("Unable to open " .. source.displayName .. " with the current API map.", true)
    return false
end

function Manager:OpenSourceById(sourceId)
    local source = RPR.sources and RPR.sources[sourceId]
    if not source then
        RPR:Notify("That reward page is not registered.", true)
        return false
    end

    RPR:Debug("open source: " .. tostring(sourceId))
    if source:OpenInterface() then
        return true
    end

    RPR:Notify("Unable to open " .. source.displayName .. " with the current API map.", true)
    return false
end

function Manager:ClaimVisibleSafeRewards()
    local claimedAny = false
    local enabledClaimSources = 0
    local attemptedAny = false

    for _, source in ipairs(RPR.sourceOrder) do
        if source:IsAutoClaimEnabled() then
            enabledClaimSources = enabledClaimSources + 1
        end

        local pending = source:IsAutoClaimEnabled() and source:DetectPending() or nil
        if source:IsAutoClaimEnabled() and source:CanAttemptManualClaim(pending) then
            attemptedAny = true
            RPR:Debug("manual claim command attempt: " .. tostring(source.id))
            local ok = source:ClaimSafe(pending)
            if ok then
                claimedAny = true
                if source.claimedMessage then
                    RPR:Notify(source.claimedMessage)
                end
            end
        end
    end

    if claimedAny then
        self:RefreshLater("manual claim", 1000)
    elseif enabledClaimSources == 0 then
        RPR:Notify("Automatic claiming is off. Enable claiming for a reward type in settings first.", true)
    elseif attemptedAny then
        RPR:Notify("No supported claim API was found for the enabled reward type.", true)
    else
        RPR:Notify("No safe rewards are currently claimable.", true)
    end
end
