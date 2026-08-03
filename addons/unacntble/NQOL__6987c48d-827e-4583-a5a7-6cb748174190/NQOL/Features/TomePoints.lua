NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local TomePoints = {}

local FEATURE_NAME = NQOL.L("features.tome_points.feature_name")
local GOLDEN_PURSUITS_FEATURE_NAME = NQOL.L("features.tome_points.golden_pursuits_feature_name")
NQOL.Lexicon.RegisterRefreshCallback(function()
    FEATURE_NAME = NQOL.L("features.tome_points.feature_name")
    GOLDEN_PURSUITS_FEATURE_NAME = NQOL.L("features.tome_points.golden_pursuits_feature_name")
end)
local EVENT_NAMESPACE = "NQOL_TomePoints"
local GOLDEN_PURSUITS_EVENT_NAMESPACE = "NQOL_GoldenPursuits"
local CLAIM_RETRY_MS = 1500

local defaults = {
    utility = {
        autoClaimTomePoints = false,
        autoClaimGoldenPursuits = false,
    },
}

local savedVariables
local initialized = false
local pendingClaims = {}
local lastReportedClaimCounts = {}
local tomePointsEventsRegistered = false
local pendingGoldenPursuitClaims = {}
local goldenPursuitsEventsRegistered = false
local ReportGoldenPursuitClaim

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "utility")
    NQOL.Settings.Boolean(settings, defaults.utility, "autoClaimTomePoints")
    NQOL.Settings.Boolean(settings, defaults.utility, "autoClaimGoldenPursuits")

    return settings
end

local function IsApiAvailable()
    return type(IsTimedActivitySystemAvailable) == "function"
        and type(GetNumTimedActivities) == "function"
        and type(GetTimedActivityCurrencyRewardInfo) == "function"
        and type(GetTimedActivityProgress) == "function"
        and type(GetTimedActivityMaxProgress) == "function"
        and type(GetTimedActivityNumTimesClaimed) == "function"
        and type(GetTimedActivityTotalNumTimesClaimable) == "function"
        and type(ClaimTimedActivityReward) == "function"
        and EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED ~= nil
        and CURT_TOME_POINTS ~= nil
end

local function IsGoldenPursuitsApiAvailable()
    return type(IsPromotionalEventSystemLocked) == "function"
        and type(GetNumActivePromotionalEventCampaigns) == "function"
        and type(GetActivePromotionalEventCampaignKey) == "function"
        and type(ShouldPromotionalEventCampaignBeVisible) == "function"
        and type(GetNumPromotionalEventCampaignActivities) == "function"
        and type(GetPromotionalEventCampaignActivityInfo) == "function"
        and type(GetPromotionalEventCampaignActivityProgress) == "function"
        and type(TryClaimPromotionalEventActivityReward) == "function"
        and type(GetNumPromotionalEventCampaignMilestoneRewards) == "function"
        and type(GetPromotionalEventCampaignMilestoneInfo) == "function"
        and type(GetPromotionalEventCampaignMilestoneRewardFlags) == "function"
        and type(TryClaimPromotionalEventMilestoneReward) == "function"
        and type(GetPromotionalEventCampaignInfo) == "function"
        and type(GetPromotionalEventCampaignDisplayName) == "function"
        and type(GetPromotionalEventCampaignProgress) == "function"
        and type(TryClaimPromotionalEventCapstoneReward) == "function"
        and type(GetRewardType) == "function"
        and type(GetNumRewardListEntries) == "function"
        and type(GetRewardListEntryInfo) == "function"
        and type(ZO_FlagHelpers) == "table"
        and type(ZO_FlagHelpers.MaskHasFlag) == "function"
        and EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED ~= nil
        and EVENT_PROMOTIONAL_EVENTS_CAMPAIGNS_UPDATED ~= nil
        and EVENT_PROMOTIONAL_EVENTS_REWARDS_CLAIMED ~= nil
        and PROMOTIONAL_EVENTS_REWARD_FLAG_CLAIMED ~= nil
        and REWARD_ENTRY_TYPE_CHOICE ~= nil
        and REWARD_ENTRY_TYPE_REWARD_LIST ~= nil
end

local function IsTimedActivitySystemReady()
    return IsApiAvailable() and IsTimedActivitySystemAvailable()
end

local function IsAutoClaimEnabled()
    return GetSettings().autoClaimTomePoints == true
end

local function IsGoldenPursuitsAutoClaimEnabled()
    return GetSettings().autoClaimGoldenPursuits == true
end

local function GetTimeMilliseconds()
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end

    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end

    return 0
end

local function ClearTimedActivityAnnouncement()
    if CENTER_SCREEN_ANNOUNCE
        and CENTER_SCREEN_ANNOUNCE.ClearActiveLinesByType
        and CENTER_SCREEN_ANNOUNCE_TYPE_TIMED_ACTIVITY_COMPLETED
    then
        CENTER_SCREEN_ANNOUNCE:ClearActiveLinesByType(CENTER_SCREEN_ANNOUNCE_TYPE_TIMED_ACTIVITY_COMPLETED)
    end
end

local function GetClaimKey(index)
    if GetTimedActivityEncodedId then
        local encodedId = GetTimedActivityEncodedId(index)
        if encodedId ~= nil then
            local encodedIdString = Id64ToString and Id64ToString(encodedId) or tostring(encodedId)
            return "encoded:" .. encodedIdString
        end
    end

    if GetTimedActivityId then
        local activityId = GetTimedActivityId(index)
        if activityId ~= nil then
            return "activity:" .. tostring(activityId)
        end
    end

    return "index:" .. tostring(index)
end

local function IsTomePointActivity(index)
    local currencyType = GetTimedActivityCurrencyRewardInfo(index)
    return currencyType == CURT_TOME_POINTS
end

local function IsClaimable(index)
    local maxProgress = GetTimedActivityMaxProgress(index)
    if not maxProgress or maxProgress <= 0 then
        return false
    end

    local progress = GetTimedActivityProgress(index)
    if not progress or progress < maxProgress then
        return false
    end

    local totalClaimable = GetTimedActivityTotalNumTimesClaimable(index)
    if not totalClaimable or totalClaimable <= 0 then
        return false
    end

    local claimed = GetTimedActivityNumTimesClaimed(index)
    return claimed and claimed < totalClaimable
end

local function ReportClaim(index, claimed, totalClaimable)
    if not NQOL.Chat or not NQOL.Chat.Message then
        return
    end

    local activityName = GetTimedActivityName and GetTimedActivityName(index) or NQOL.L("common.unknown_value")
    if zo_strformat then
        local claimText = zo_strformat(SI_TIMED_ACTIVITY_CLAIMED_PROGRESS, claimed, totalClaimable)
        NQOL.Chat.Message(NQOL.L("common.detail_pair", claimText, tostring(activityName)), FEATURE_NAME)
    else
        NQOL.Chat.Message(NQOL.L("features.tome_points.claimed_activity", tostring(claimed) .. "/" .. tostring(totalClaimable), tostring(activityName)), FEATURE_NAME)
    end
end

local function UpdatePendingClaim(index, key)
    local pendingClaim = pendingClaims[key]
    if not pendingClaim then
        return false, false
    end

    local claimed = GetTimedActivityNumTimesClaimed(index)
    if claimed and claimed > pendingClaim.claimed then
        pendingClaims[key] = nil
        if lastReportedClaimCounts[key] ~= claimed then
            lastReportedClaimCounts[key] = claimed
            ReportClaim(index, claimed, GetTimedActivityTotalNumTimesClaimable(index))
        end
        ClearTimedActivityAnnouncement()
        return false, true
    end

    return true, false
end

local function TryClaimActivity(index)
    if not IsTomePointActivity(index) then
        return
    end

    local key = GetClaimKey(index)
    local hasPendingClaim, claimConfirmed = UpdatePendingClaim(index, key)
    if claimConfirmed then
        return
    end

    if not IsClaimable(index) then
        pendingClaims[key] = nil
        return
    end

    local now = GetTimeMilliseconds()
    if hasPendingClaim then
        local startedAt = pendingClaims[key].startedAt or 0
        if now - startedAt < CLAIM_RETRY_MS then
            ClearTimedActivityAnnouncement()
            return
        end
    end

    pendingClaims[key] = {
        claimed = GetTimedActivityNumTimesClaimed(index) or 0,
        startedAt = now,
    }

    ClaimTimedActivityReward(index)
    ClearTimedActivityAnnouncement()
end

local function CheckForTomePoints()
    if not IsAutoClaimEnabled() or not IsTimedActivitySystemReady() then
        return
    end

    for index = 1, GetNumTimedActivities() do
        TryClaimActivity(index)
    end
end

local function RegisterTomePointsEvents()
    if tomePointsEventsRegistered or not EVENT_MANAGER or not IsApiAvailable() then
        return
    end

    tomePointsEventsRegistered = true
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, CheckForTomePoints)

    if EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED, CheckForTomePoints)
    end
end

local function UnregisterTomePointsEvents()
    if not tomePointsEventsRegistered or not EVENT_MANAGER then
        return
    end

    tomePointsEventsRegistered = false
    pendingClaims = {}
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED)

    if EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED)
    end
end

local function GetCampaignKeyString(campaignKey)
    if Id64ToString then
        return Id64ToString(campaignKey)
    end

    return tostring(campaignKey)
end

local function FormatGoldenPursuitRewardName(rewardId, rewardQuantity)
    if type(REWARDS_MANAGER) == "table" and type(REWARDS_MANAGER.GetInfoForReward) == "function" then
        local rewardData = REWARDS_MANAGER:GetInfoForReward(rewardId, rewardQuantity)
        if rewardData then
            if rewardQuantity and rewardQuantity > 1 and type(rewardData.GetFormattedNameWithStack) == "function" then
                return rewardData:GetFormattedNameWithStack()
            elseif type(rewardData.GetFormattedName) == "function" then
                return rewardData:GetFormattedName()
            end
        end
    end

    return NQOL.L("features.tome_points.reward")
end

local function FormatCampaignName(campaignKey)
    local campaignId = GetPromotionalEventCampaignInfo(campaignKey)
    if campaignId and campaignId ~= 0 then
        local campaignName = GetPromotionalEventCampaignDisplayName(campaignId)
        if campaignName and campaignName ~= "" then
            return campaignName
        end
    end

    if GetString and SI_PROMOTIONAL_EVENT_TRACKER_HEADER then
        return GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER)
    end
    return NQOL.L("features.tome_points.golden_pursuit")
end

local function IsGoldenPursuitRewardClaimed(rewardFlags)
    return ZO_FlagHelpers.MaskHasFlag(rewardFlags or 0, PROMOTIONAL_EVENTS_REWARD_FLAG_CLAIMED)
end

local function RewardOffersChoice(rewardId, visitedRewardIds)
    if not rewardId or rewardId == 0 then
        return false
    end

    if visitedRewardIds and visitedRewardIds[rewardId] then
        return false
    end

    visitedRewardIds = visitedRewardIds or {}
    visitedRewardIds[rewardId] = true

    local rewardType = GetRewardType(rewardId)
    if rewardType == REWARD_ENTRY_TYPE_CHOICE then
        return true
    end

    if rewardType == REWARD_ENTRY_TYPE_REWARD_LIST then
        for rewardIndex = 1, GetNumRewardListEntries(rewardId) do
            local nestedRewardId = GetRewardListEntryInfo(rewardId, rewardIndex)
            if RewardOffersChoice(nestedRewardId, visitedRewardIds) then
                return true
            end
        end
    end

    return false
end

local function GetGoldenPursuitClaimKey(campaignKey, rewardType, rewardIndex)
    return GetCampaignKeyString(campaignKey) .. ":" .. rewardType .. ":" .. tostring(rewardIndex or 0)
end

local function IsGoldenPursuitClaimPending(claimKey)
    local pendingClaim = pendingGoldenPursuitClaims[claimKey]
    if not pendingClaim then
        return false
    end

    return GetTimeMilliseconds() - (pendingClaim.startedAt or 0) < CLAIM_RETRY_MS
end

local function TryClaimGoldenPursuitReward(campaignKey, claimKey, rewardKind, rewardIndex, message, claimFunction)
    if IsGoldenPursuitClaimPending(claimKey) then
        return
    end

    pendingGoldenPursuitClaims[claimKey] = {
        campaignKey = GetCampaignKeyString(campaignKey),
        message = message,
        rewardKind = rewardKind,
        rewardIndex = rewardIndex,
        startedAt = GetTimeMilliseconds(),
    }

    claimFunction()
end

local function TryClaimGoldenPursuitActivity(campaignKey, activityIndex)
    local _, activityName, _, completionThreshold, rewardId, rewardQuantity = GetPromotionalEventCampaignActivityInfo(campaignKey, activityIndex)
    if not rewardId or rewardId == 0 or not completionThreshold or completionThreshold <= 0 or RewardOffersChoice(rewardId) then
        return
    end

    local progress, rewardFlags = GetPromotionalEventCampaignActivityProgress(campaignKey, activityIndex)
    if not progress or progress < completionThreshold or IsGoldenPursuitRewardClaimed(rewardFlags) then
        return
    end

    local claimKey = GetGoldenPursuitClaimKey(campaignKey, "activity", activityIndex)
    local message = NQOL.L("features.tome_points.claimed_activity", FormatGoldenPursuitRewardName(rewardId, rewardQuantity), tostring(activityName or NQOL.L("features.tome_points.activity_reward")))
    TryClaimGoldenPursuitReward(campaignKey, claimKey, "activity", activityIndex, message, function()
        TryClaimPromotionalEventActivityReward(campaignKey, activityIndex, nil)
    end)
end

local function TryClaimGoldenPursuitMilestone(campaignKey, milestoneIndex, activitiesCompleted)
    local completionThreshold, rewardId, rewardQuantity = GetPromotionalEventCampaignMilestoneInfo(campaignKey, milestoneIndex)
    if not rewardId or rewardId == 0 or not completionThreshold or completionThreshold <= 0 or RewardOffersChoice(rewardId) then
        return
    end

    local rewardFlags = GetPromotionalEventCampaignMilestoneRewardFlags(campaignKey, milestoneIndex)
    if not activitiesCompleted or activitiesCompleted < completionThreshold or IsGoldenPursuitRewardClaimed(rewardFlags) then
        return
    end

    local claimKey = GetGoldenPursuitClaimKey(campaignKey, "milestone", milestoneIndex)
    local message = NQOL.L("features.tome_points.claimed_milestone", FormatGoldenPursuitRewardName(rewardId, rewardQuantity), FormatCampaignName(campaignKey), tostring(completionThreshold))
    TryClaimGoldenPursuitReward(campaignKey, claimKey, "milestone", milestoneIndex, message, function()
        TryClaimPromotionalEventMilestoneReward(campaignKey, milestoneIndex, nil)
    end)
end

local function TryClaimGoldenPursuitCapstone(campaignKey)
    local _, _, _, completionThreshold, rewardId, rewardQuantity = GetPromotionalEventCampaignInfo(campaignKey)
    if not rewardId or rewardId == 0 or not completionThreshold or completionThreshold <= 0 or RewardOffersChoice(rewardId) then
        return
    end

    local activitiesCompleted, rewardFlags = GetPromotionalEventCampaignProgress(campaignKey)
    if not activitiesCompleted or activitiesCompleted < completionThreshold or IsGoldenPursuitRewardClaimed(rewardFlags) then
        return
    end

    local claimKey = GetGoldenPursuitClaimKey(campaignKey, "capstone", 0)
    local message = NQOL.L("features.tome_points.claimed_capstone", FormatGoldenPursuitRewardName(rewardId, rewardQuantity), FormatCampaignName(campaignKey))
    TryClaimGoldenPursuitReward(campaignKey, claimKey, "capstone", 0, message, function()
        TryClaimPromotionalEventCapstoneReward(campaignKey, nil)
    end)
end

local function TryClaimGoldenPursuitCampaign(campaignKey)
    if not ShouldPromotionalEventCampaignBeVisible(campaignKey) then
        return
    end

    for activityIndex = 1, GetNumPromotionalEventCampaignActivities(campaignKey) do
        TryClaimGoldenPursuitActivity(campaignKey, activityIndex)
    end

    local activitiesCompleted = GetPromotionalEventCampaignProgress(campaignKey)
    for milestoneIndex = 1, GetNumPromotionalEventCampaignMilestoneRewards(campaignKey) do
        TryClaimGoldenPursuitMilestone(campaignKey, milestoneIndex, activitiesCompleted)
    end

    TryClaimGoldenPursuitCapstone(campaignKey)
end

local function CheckForGoldenPursuits()
    if not IsGoldenPursuitsAutoClaimEnabled() or not IsGoldenPursuitsApiAvailable() or IsPromotionalEventSystemLocked() then
        return
    end

    for campaignIndex = 1, GetNumActivePromotionalEventCampaigns() do
        TryClaimGoldenPursuitCampaign(GetActivePromotionalEventCampaignKey(campaignIndex))
    end
end

local function RegisterGoldenPursuitsEvents()
    if goldenPursuitsEventsRegistered or not EVENT_MANAGER or not IsGoldenPursuitsApiAvailable() then
        return
    end

    goldenPursuitsEventsRegistered = true
    EVENT_MANAGER:RegisterForEvent(GOLDEN_PURSUITS_EVENT_NAMESPACE, EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED, CheckForGoldenPursuits)
    EVENT_MANAGER:RegisterForEvent(GOLDEN_PURSUITS_EVENT_NAMESPACE, EVENT_PROMOTIONAL_EVENTS_CAMPAIGNS_UPDATED, CheckForGoldenPursuits)
    EVENT_MANAGER:RegisterForEvent(GOLDEN_PURSUITS_EVENT_NAMESPACE, EVENT_PROMOTIONAL_EVENTS_REWARDS_CLAIMED, function(_, campaignKey)
        ReportGoldenPursuitClaim(campaignKey)
        CheckForGoldenPursuits()
    end)
end

local function UnregisterGoldenPursuitsEvents()
    if not goldenPursuitsEventsRegistered or not EVENT_MANAGER then
        return
    end

    goldenPursuitsEventsRegistered = false
    pendingGoldenPursuitClaims = {}
    EVENT_MANAGER:UnregisterForEvent(GOLDEN_PURSUITS_EVENT_NAMESPACE, EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(GOLDEN_PURSUITS_EVENT_NAMESPACE, EVENT_PROMOTIONAL_EVENTS_CAMPAIGNS_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(GOLDEN_PURSUITS_EVENT_NAMESPACE, EVENT_PROMOTIONAL_EVENTS_REWARDS_CLAIMED)
end

local function IsPendingGoldenPursuitClaimConfirmed(campaignKey, pendingClaim)
    if pendingClaim.rewardKind == "activity" then
        local _, rewardFlags = GetPromotionalEventCampaignActivityProgress(campaignKey, pendingClaim.rewardIndex)
        return IsGoldenPursuitRewardClaimed(rewardFlags)
    elseif pendingClaim.rewardKind == "milestone" then
        return IsGoldenPursuitRewardClaimed(GetPromotionalEventCampaignMilestoneRewardFlags(campaignKey, pendingClaim.rewardIndex))
    elseif pendingClaim.rewardKind == "capstone" then
        local _, rewardFlags = GetPromotionalEventCampaignProgress(campaignKey)
        return IsGoldenPursuitRewardClaimed(rewardFlags)
    end

    return false
end

ReportGoldenPursuitClaim = function(campaignKey)
    local campaignKeyString = GetCampaignKeyString(campaignKey)

    for claimKey, pendingClaim in pairs(pendingGoldenPursuitClaims) do
        if pendingClaim.campaignKey == campaignKeyString and IsPendingGoldenPursuitClaimConfirmed(campaignKey, pendingClaim) then
            pendingGoldenPursuitClaims[claimKey] = nil
            if NQOL.Chat and NQOL.Chat.Message then
                NQOL.Chat.Message(pendingClaim.message or NQOL.L("features.tome_points.reward_claimed"), GOLDEN_PURSUITS_FEATURE_NAME)
            end
        end
    end
end

function TomePoints.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function TomePoints.Initialize()
    if initialized then
        return
    end

    initialized = true

    if not EVENT_MANAGER then
        return
    end

    if IsAutoClaimEnabled() then
        RegisterTomePointsEvents()
    end

    if IsGoldenPursuitsAutoClaimEnabled() then
        RegisterGoldenPursuitsEvents()
    end

    CheckForTomePoints()
    CheckForGoldenPursuits()
end

function TomePoints.GetAutoClaimTomePoints()
    return GetSettings().autoClaimTomePoints
end

function TomePoints.SetAutoClaimTomePoints(value)
    GetSettings().autoClaimTomePoints = value == true

    if GetSettings().autoClaimTomePoints then
        RegisterTomePointsEvents()
        CheckForTomePoints()
    else
        UnregisterTomePointsEvents()
    end
end

function TomePoints.GetAutoClaimGoldenPursuits()
    return GetSettings().autoClaimGoldenPursuits
end

function TomePoints.SetAutoClaimGoldenPursuits(value)
    GetSettings().autoClaimGoldenPursuits = value == true

    if GetSettings().autoClaimGoldenPursuits then
        RegisterGoldenPursuitsEvents()
        CheckForGoldenPursuits()
    else
        UnregisterGoldenPursuitsEvents()
    end
end

function TomePoints.GetAutoClaimTomePointsLabel()
    return NQOL.L("features.tome_points.auto_claim_tome_points_label")
end

function TomePoints.GetAutoClaimTomePointsTooltip()
    return NQOL.L("features.tome_points.auto_claim_tome_points_tooltip")
end

function TomePoints.GetAutoClaimGoldenPursuitsLabel()
    return NQOL.L("features.tome_points.auto_claim_golden_pursuits_label")
end

function TomePoints.GetAutoClaimGoldenPursuitsTooltip()
    return NQOL.L("features.tome_points.auto_claim_golden_pursuits_tooltip")
end

NQOL.Features.TomePoints = TomePoints
