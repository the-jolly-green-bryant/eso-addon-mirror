-- VeterancyAutoClaim.lua
-- Author:  @NPViral
-- Version: 1.0.2
-- Automatically claims available Veterancy rank rewards.

local ADDON_NAME = "VeterancyAutoClaim"
local ADDON_VERSION = "1.0.2"
local SAVED_VARS_NAME = "VeterancyAutoClaimSavedVars"
local TRACK_TYPE = REWARD_TRACK_TYPE_AVA_VETERANCY
local COMPONENT = REWARD_TRACK_COMPONENT_PRIMARY
local DEFAULT_REWARD_INDEX = 1
local CHECK_DELAY_MS = 150
local REQUEST_TIMEOUT_MS = 3000
local TAG = "|c88CCFF[Veterancy]|r "

local EM = EVENT_MANAGER
local LAM = LibAddonMenu2

local defaults = {
    autoClaim = true,
    chatOutput = true,
}

local sv
local claimEventsRegistered = false
local checkQueued = false
local claimPending = false
local claimRequestedAt = 0
local pendingRewardText = nil

local function GetVeterancyTrackInfo()
    if not IsVeterancySeasonActive() then return nil end

    -- ZOS currently exposes one active Veterancy reference track.
    local referenceTrackId = GetActiveReferenceTrackIdsForRewardTrackType(TRACK_TYPE)
    if not referenceTrackId or referenceTrackId == 0 then return nil end

    local trackIndex = GetReferenceTrackIndex(TRACK_TYPE, referenceTrackId)
    if not trackIndex or trackIndex <= 0 then return nil end

    local rewardTrackId = GetRewardTrackIdFromReferenceTrackId(TRACK_TYPE, referenceTrackId)
    if not rewardTrackId or rewardTrackId == 0 then return nil end

    return trackIndex, rewardTrackId
end

local function AddRewardText(output, rewardData, repeatCount)
    if not rewardData then return end

    if rewardData.ShouldUseFallback and rewardData:ShouldUseFallback() then
        rewardData = rewardData:GetFallbackRewardData() or rewardData
    end

    if rewardData:GetRewardType() == REWARD_ENTRY_TYPE_REWARD_LIST then
        local rewardListId = GetRewardListIdFromReward(rewardData:GetRewardId())
        local rewardList = REWARDS_MANAGER:GetAllRewardInfoForRewardList(rewardListId)
        for _, childRewardData in ipairs(rewardList) do
            AddRewardText(output, childRewardData, repeatCount)
        end
        return
    end

    local text
    local itemLink = rewardData:GetItemLink()
    local quantity = rewardData:GetQuantity() or 1

    if itemLink and itemLink ~= "" then
        text = itemLink
        if quantity > 1 then
            text = text .. " x" .. tostring(quantity)
        end
    else
        text = rewardData:GetFormattedNameWithStack()
        if not text or text == "" then
            text = rewardData:GetFormattedName()
        end
        if not text or text == "" then
            text = rewardData:GetRawName()
        end
    end

    if text and text ~= "" then
        if repeatCount and repeatCount > 1 then
            text = text .. " x" .. tostring(repeatCount)
        end
        table.insert(output, text)
    end
end

local function AddVeterancyTierRewards(output, rewardTrackId, tierIndex, repeatCount)
    local numRewards = GetNumRewardsAtRewardTrackTier(rewardTrackId, tierIndex, COMPONENT)
    for rewardIndex = 1, numRewards do
        local rewardId = GetVeterancyRewardDefIdAtRewardTrackTierIndex(rewardTrackId, tierIndex, rewardIndex)
        local quantity = GetVeterancyRewardQuantityAtRewardTrackTierIndex(rewardTrackId, tierIndex, rewardIndex)
        if rewardId and rewardId ~= 0 then
            local rewardData = REWARDS_MANAGER:GetInfoForReward(rewardId, quantity)
            AddRewardText(output, rewardData, repeatCount)
        end
    end
end

local function BuildClaimRewardText(trackIndex, rewardTrackId)
    local output = {}
    local _, currentRank = GetInfoForRewardTrack(TRACK_TYPE, trackIndex)
    local numBaseRanks = GetNumBaseTiersForRewardTrack(rewardTrackId)

    if currentRank and currentRank > 0 then
        local maxRank = zo_min(currentRank, numBaseRanks)
        for rankIndex = 1, maxRank do
            local numRewards = GetNumRewardsAtRewardTrackTier(rewardTrackId, rankIndex, COMPONENT)
            if numRewards > 0 then
                local isClaimed = GetRewardTrackRewardClaimedState(
                    TRACK_TYPE,
                    trackIndex,
                    rankIndex,
                    COMPONENT,
                    DEFAULT_REWARD_INDEX
                )
                if not isClaimed then
                    AddVeterancyTierRewards(output, rewardTrackId, rankIndex)
                end
            end
        end
    end

    if HasInfinitelyRepeatableTierForRewardTrack(rewardTrackId) then
        local repeatableRankIndex = GetInfinitelyRepeatableTierForRewardTrack(rewardTrackId)
        local _, numTimesStillClaimable = GetRewardTrackInfinitelyRepeatableRewardClaimedState(
            TRACK_TYPE,
            trackIndex,
            repeatableRankIndex,
            COMPONENT
        )
        if numTimesStillClaimable and numTimesStillClaimable > 0 then
            AddVeterancyTierRewards(output, rewardTrackId, repeatableRankIndex, numTimesStillClaimable)
        end
    end

    if #output == 0 then return nil end
    return table.concat(output, ", ")
end

local function TryClaimAvailableRewards()
    checkQueued = false

    if not sv or not sv.autoClaim then return end
    if not IsPlayerActivated() then return end
    -- Keep pending rewards unclaimed anywhere in Imperial City, including the Sewers.
    if IsInImperialCity() then return end

    if claimPending then
        local elapsed = GetGameTimeMilliseconds() - claimRequestedAt
        if elapsed < REQUEST_TIMEOUT_MS then return end
        claimPending = false
        claimRequestedAt = 0
        pendingRewardText = nil
    end

    local trackIndex, rewardTrackId = GetVeterancyTrackInfo()
    if not trackIndex then return end
    if not HasUnclaimedRewardTrackRewards(TRACK_TYPE, trackIndex) then return end

    pendingRewardText = BuildClaimRewardText(trackIndex, rewardTrackId)
    claimPending = true
    claimRequestedAt = GetGameTimeMilliseconds()
    ClaimAllRewardTrackRewards(TRACK_TYPE, trackIndex)
end

local function QueueClaimCheck()
    if not sv or not sv.autoClaim then return end
    if checkQueued then return end
    checkQueued = true
    zo_callLater(TryClaimAvailableRewards, CHECK_DELAY_MS)
end

local function OnProgressGained(_, trackType)
    if trackType ~= TRACK_TYPE then return end
    QueueClaimCheck()
end

local function OnTrackStarted(_, trackType)
    if trackType ~= TRACK_TYPE then return end
    QueueClaimCheck()
end

local function OnRewardsClaimed(_, trackType)
    if trackType ~= TRACK_TYPE then return end

    local wasOurRequest = claimPending
    local rewardText = pendingRewardText
    claimPending = false
    claimRequestedAt = 0
    pendingRewardText = nil

    if wasOurRequest and sv and sv.chatOutput then
        CHAT_SYSTEM:AddMessage(TAG .. "Claimed: " .. (rewardText or "Veterancy reward(s)"))
    end
end

local function RegisterClaimEvents()
    if claimEventsRegistered then return end
    claimEventsRegistered = true

    EM:RegisterForEvent(ADDON_NAME .. "_Progress", EVENT_REWARD_TRACK_PROGRESS_GAINED, OnProgressGained)
    EM:RegisterForEvent(ADDON_NAME .. "_TrackStarted", EVENT_REWARD_TRACK_STARTED, OnTrackStarted)
    EM:RegisterForEvent(ADDON_NAME .. "_TrackUpdate", EVENT_REWARD_TRACK_UPDATE_RECEIVED, QueueClaimCheck)
    EM:RegisterForEvent(ADDON_NAME .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, QueueClaimCheck)
    EM:RegisterForEvent(ADDON_NAME .. "_ClaimedSingle", EVENT_REWARD_TRACK_REWARD_CLAIMED, OnRewardsClaimed)
    EM:RegisterForEvent(ADDON_NAME .. "_ClaimedAll", EVENT_REWARD_TRACK_REWARDS_CLAIMED, OnRewardsClaimed)
end

local function UnregisterClaimEvents()
    if not claimEventsRegistered then return end
    claimEventsRegistered = false

    EM:UnregisterForEvent(ADDON_NAME .. "_Progress", EVENT_REWARD_TRACK_PROGRESS_GAINED)
    EM:UnregisterForEvent(ADDON_NAME .. "_TrackStarted", EVENT_REWARD_TRACK_STARTED)
    EM:UnregisterForEvent(ADDON_NAME .. "_TrackUpdate", EVENT_REWARD_TRACK_UPDATE_RECEIVED)
    EM:UnregisterForEvent(ADDON_NAME .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    EM:UnregisterForEvent(ADDON_NAME .. "_ClaimedSingle", EVENT_REWARD_TRACK_REWARD_CLAIMED)
    EM:UnregisterForEvent(ADDON_NAME .. "_ClaimedAll", EVENT_REWARD_TRACK_REWARDS_CLAIMED)

    checkQueued = false
    claimPending = false
    claimRequestedAt = 0
    pendingRewardText = nil
end

local function SetAutoClaimEnabled(enabled)
    sv.autoClaim = enabled
    if enabled then
        RegisterClaimEvents()
        QueueClaimCheck()
    else
        UnregisterClaimEvents()
    end
end

local function OpenDonationMail()
    local ok = pcall(function()
        if MAIN_MENU_KEYBOARD and type(MAIN_MENU_KEYBOARD.ShowScene) == "function" then
            MAIN_MENU_KEYBOARD:ShowScene("mailSend")
        end

        if ZO_MailSendToField and type(ZO_MailSendToField.SetText) == "function" then
            ZO_MailSendToField:SetText("@NPViral")
        end

        if ZO_MailSendSubjectField and type(ZO_MailSendSubjectField.SetText) == "function" then
            ZO_MailSendSubjectField:SetText("Skooma Fund")
        end

        if ZO_MailSendBodyField and type(ZO_MailSendBodyField.SetText) == "function" then
            ZO_MailSendBodyField:SetText("Thanks for Veterancy Auto Claim!")
        end
    end)

    if not ok then
        CHAT_SYSTEM:AddMessage("Could not open mail automatically. Send gold manually to @NPViral.")
    end
end

local function CreateSettingsPanel()
    LAM:RegisterAddonPanel(ADDON_NAME .. "Options", {
        type = "panel",
        name = "Veterancy Auto Claim",
        displayName = "Veterancy Auto Claim",
        author = "@NPViral",
        version = ADDON_VERSION,
        slashCommand = "/vac",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    LAM:RegisterOptionControls(ADDON_NAME .. "Options", {
        {
            type = "description",
            text = "Automatically claims available Veterancy rank rewards.",
            width = "full",
        },
        {
            type = "header",
            name = "Settings",
        },
        {
            type = "checkbox",
            name = "Auto Claim Rewards",
            tooltip = "Automatically claim available Veterancy rank rewards as soon as ESO reports them as claimable, except while you are in Imperial City.",
            getFunc = function() return sv.autoClaim end,
            setFunc = SetAutoClaimEnabled,
            default = defaults.autoClaim,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Chat Output",
            tooltip = "Show a short '[Veterancy] Claimed:' message with the reward after ESO confirms an automatic claim.",
            getFunc = function() return sv.chatOutput end,
            setFunc = function(value) sv.chatOutput = value end,
            default = defaults.chatOutput,
            disabled = function() return not sv.autoClaim end,
            width = "full",
        },
        {
            type = "header",
            name = "Info",
        },
        {
            type = "description",
            text = "Settings are account-wide. Use /vac to open this panel.",
            width = "full",
        },
        {
            type = "button",
            name = "Feeling generous?",
            tooltip = "Donations keep the skooma flowing.",
            func = OpenDonationMail,
            width = "full",
        },
    })
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide(SAVED_VARS_NAME, 1, GetWorldName(), defaults)
    CreateSettingsPanel()

    if sv.autoClaim then
        RegisterClaimEvents()
    end

end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
