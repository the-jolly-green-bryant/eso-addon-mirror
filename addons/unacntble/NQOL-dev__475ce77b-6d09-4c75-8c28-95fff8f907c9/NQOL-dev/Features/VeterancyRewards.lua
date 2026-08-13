NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local VeterancyRewards = {}

local FEATURE_NAME = NQOL.L("features.veterancy_rewards.feature_name")
NQOL.Lexicon.RegisterRefreshCallback(function()
    FEATURE_NAME = NQOL.L("features.veterancy_rewards.feature_name")
end)

local EVENT_NAMESPACE = "NQOL_VeterancyRewards"
local CLAIM_VERIFICATION_DELAY_MS = 2000

local defaults = {
    utility = {
        autoClaimVeterancyRewards = false,
    },
}

local savedVariables
local initialized = false
local eventsRegistered = false
local pendingClaim
local blockedFingerprint
local nextAttemptId = 0

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "utility")
    NQOL.Settings.Boolean(settings, defaults.utility, "autoClaimVeterancyRewards")

    return settings
end

local function IsEnabled()
    return GetSettings().autoClaimVeterancyRewards == true
end

local function IsApiAvailable()
    return type(IsVeterancySeasonActive) == "function"
        and type(GetActiveReferenceTrackIdsForRewardTrackType) == "function"
        and type(GetReferenceTrackIndex) == "function"
        and type(GetInfoForRewardTrack) == "function"
        and type(HasUnclaimedRewardTrackRewards) == "function"
        and type(ClaimAllRewardTrackRewards) == "function"
        and type(zo_callLater) == "function"
        and REWARD_TRACK_TYPE_AVA_VETERANCY ~= nil
        and EVENT_REWARD_TRACK_PROGRESS_GAINED ~= nil
        and EVENT_REWARD_TRACK_REWARDS_CLAIMED ~= nil
end

local function GetActiveTrackData()
    if not IsApiAvailable() or not IsVeterancySeasonActive() then
        return nil
    end

    local trackType = REWARD_TRACK_TYPE_AVA_VETERANCY
    local referenceTrackIds = { GetActiveReferenceTrackIdsForRewardTrackType(trackType) }
    for _, referenceTrackId in ipairs(referenceTrackIds) do
        if type(referenceTrackId) == "number" and referenceTrackId ~= 0 then
            local referenceTrackIndex = GetReferenceTrackIndex(trackType, referenceTrackId)
            if referenceTrackIndex then
                local _, currentTier = GetInfoForRewardTrack(trackType, referenceTrackIndex)
                return {
                    trackType = trackType,
                    referenceTrackId = referenceTrackId,
                    referenceTrackIndex = referenceTrackIndex,
                    currentTier = currentTier or 0,
                }
            end
        end
    end

    return nil
end

local function GetClaimFingerprint(trackData)
    return tostring(trackData.referenceTrackId) .. ":" .. tostring(trackData.currentTier)
end

local function HasUnclaimedRewards(trackData)
    return HasUnclaimedRewardTrackRewards(trackData.trackType, trackData.referenceTrackIndex)
end

local function ResetClaimState()
    pendingClaim = nil
    blockedFingerprint = nil
    nextAttemptId = nextAttemptId + 1
end

local function FinalizeClaimAttempt(attemptId)
    if not pendingClaim or pendingClaim.attemptId ~= attemptId then
        return
    end

    pendingClaim = nil

    local trackData = GetActiveTrackData()
    if trackData and HasUnclaimedRewards(trackData) then
        -- Store the state after ESO has processed the request. A partial claim can
        -- leave a different set of rewards than the one that started the request.
        blockedFingerprint = GetClaimFingerprint(trackData)
    else
        blockedFingerprint = nil
    end
end

local function CheckForVeterancyRewards()
    if not IsEnabled() or not IsApiAvailable() or pendingClaim then
        return
    end

    local trackData = GetActiveTrackData()
    if not trackData then
        return
    end

    if not HasUnclaimedRewards(trackData) then
        blockedFingerprint = nil
        return
    end

    local fingerprint = GetClaimFingerprint(trackData)
    if blockedFingerprint == fingerprint then
        return
    end

    nextAttemptId = nextAttemptId + 1
    local attemptId = nextAttemptId
    pendingClaim = {
        attemptId = attemptId,
        reported = false,
    }

    ClaimAllRewardTrackRewards(trackData.trackType, trackData.referenceTrackIndex)
    zo_callLater(function()
        FinalizeClaimAttempt(attemptId)
    end, CLAIM_VERIFICATION_DELAY_MS)
end

local function OnRewardsClaimed(_, rewardTrackType)
    if rewardTrackType ~= REWARD_TRACK_TYPE_AVA_VETERANCY or not pendingClaim then
        return
    end

    if not pendingClaim.reported and NQOL.Chat and NQOL.Chat.Message then
        pendingClaim.reported = true
        NQOL.Chat.Message(NQOL.L("features.veterancy_rewards.claimed"), FEATURE_NAME)
    end
end

local function OnProgressGained(_, rewardTrackType)
    if rewardTrackType == REWARD_TRACK_TYPE_AVA_VETERANCY then
        CheckForVeterancyRewards()
    end
end

local function OnRewardTrackStarted(_, rewardTrackType)
    if rewardTrackType == REWARD_TRACK_TYPE_AVA_VETERANCY then
        CheckForVeterancyRewards()
    end
end

local function RegisterEvents()
    if eventsRegistered or not EVENT_MANAGER or not IsApiAvailable() then
        return
    end

    eventsRegistered = true
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_REWARD_TRACK_PROGRESS_GAINED, OnProgressGained)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_REWARD_TRACK_REWARDS_CLAIMED, OnRewardsClaimed)

    if EVENT_REWARD_TRACK_STARTED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_REWARD_TRACK_STARTED, OnRewardTrackStarted)
    end
    if EVENT_REWARD_TRACK_UPDATE_RECEIVED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_REWARD_TRACK_UPDATE_RECEIVED, CheckForVeterancyRewards)
    end
    if EVENT_REWARD_TRACK_SETTINGS_UPDATE_RECEIVED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_REWARD_TRACK_SETTINGS_UPDATE_RECEIVED, CheckForVeterancyRewards)
    end
    if EVENT_HOLIDAYS_CHANGED then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_HOLIDAYS_CHANGED, CheckForVeterancyRewards)
    end
end

local function UnregisterEvents()
    if not eventsRegistered or not EVENT_MANAGER then
        return
    end

    eventsRegistered = false
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_REWARD_TRACK_PROGRESS_GAINED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_REWARD_TRACK_REWARDS_CLAIMED)

    if EVENT_REWARD_TRACK_STARTED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_REWARD_TRACK_STARTED)
    end
    if EVENT_REWARD_TRACK_UPDATE_RECEIVED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_REWARD_TRACK_UPDATE_RECEIVED)
    end
    if EVENT_REWARD_TRACK_SETTINGS_UPDATE_RECEIVED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_REWARD_TRACK_SETTINGS_UPDATE_RECEIVED)
    end
    if EVENT_HOLIDAYS_CHANGED then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_HOLIDAYS_CHANGED)
    end

    ResetClaimState()
end

function VeterancyRewards.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function VeterancyRewards.Initialize()
    if initialized then
        return
    end

    initialized = true
    if IsEnabled() then
        RegisterEvents()
        CheckForVeterancyRewards()
    end
end

function VeterancyRewards.GetEnabled()
    return IsEnabled()
end

function VeterancyRewards.SetEnabled(value)
    GetSettings().autoClaimVeterancyRewards = value == true
    ResetClaimState()

    if IsEnabled() then
        RegisterEvents()
        CheckForVeterancyRewards()
    else
        UnregisterEvents()
    end
end

function VeterancyRewards.GetEnabledLabel()
    return NQOL.L("features.veterancy_rewards.auto_claim_label")
end

function VeterancyRewards.GetEnabledTooltip()
    return NQOL.L("features.veterancy_rewards.auto_claim_tooltip")
end

NQOL.Features.VeterancyRewards = VeterancyRewards
