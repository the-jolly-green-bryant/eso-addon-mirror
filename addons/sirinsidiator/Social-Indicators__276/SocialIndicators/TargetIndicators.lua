local TARGET_UNIT_TAG = "reticleover"
local FRIEND_ICON_TEXTURE = "/esoui/art/campaign/campaignbrowser_friends.dds"
local IGNORED_ICON_TEXTURE = "SocialIndicators/images/target_ignored.dds"

local IsPositionLeft = SocialIndicators.IsPositionLeft
local GetPreferredGuildMemberIndexFromCharacterOrDisplayName = SocialIndicators.GetPreferredGuildMemberIndexFromCharacterOrDisplayName

local initialized = false
local settings = nil
local targetUnitFrame = nil
local targetFriendIcon = nil
local targetGuildRankIcon = nil
local targetGuildLabel = nil
local isChampionIconHidden = true
local isCaptionHidden = true
local isRankIconHidden = true

local function CreateTargetUnitFrameControl(name, type)
    local control = WINDOW_MANAGER:CreateControl("SocialIndicators" .. name, targetUnitFrame.frame, type)
    control:SetHidden(true)
    table.insert(targetUnitFrame.fadeComponents, control)
    return control
end

local function UpdateTargetFriendIconAnchor()
    local isLeft = IsPositionLeft(settings.friendIconPosition)
    targetFriendIcon:ClearAnchors()
    if(isLeft and isChampionIconHidden) then
        targetFriendIcon:SetAnchor(RIGHT, targetUnitFrame.levelLabel, LEFT, 0, 0)
    elseif(isLeft) then
        targetFriendIcon:SetAnchor(RIGHT, targetUnitFrame.championIcon, LEFT, 10, -1)
    elseif(isRankIconHidden) then
        targetFriendIcon:SetAnchor(LEFT, targetUnitFrame.nameLabel, RIGHT, 1, 0)
    else
        targetFriendIcon:SetAnchor(LEFT, targetUnitFrame.rankIcon, RIGHT, -8, 0)
    end
end

local function UpdateTargetGuildLabelAnchor()
    if(isCaptionHidden) then
        targetGuildLabel:SetAnchor(TOP, targetUnitFrame.nameLabel, BOTTOM, 0, 0)
    else
        targetGuildLabel:SetAnchor(TOP, targetUnitFrame.captionLabel, BOTTOM, 0, 0)
    end
end

local function UpdateTargetGuildRankIconAnchor()
    local isLeft = IsPositionLeft(settings.guildRankIconPosition)
    targetGuildRankIcon:ClearAnchors()
    if(isLeft) then
        targetGuildRankIcon:SetAnchor(RIGHT, targetGuildLabel, LEFT, 0, 0)
    else
        targetGuildRankIcon:SetAnchor(LEFT, targetGuildLabel, RIGHT, 0, 0)
    end
end

local function CreateTargetIndicatorControls()
    targetFriendIcon = CreateTargetUnitFrameControl("FriendIcon", CT_TEXTURE)
    targetFriendIcon:SetTexture(FRIEND_ICON_TEXTURE)
    targetFriendIcon:SetDimensions(32, 32)

    targetGuildLabel = CreateTargetUnitFrameControl("GuildLabel", CT_LABEL)
    targetGuildLabel:SetFont("ZoFontGameShadow")
    targetGuildLabel:SetHorizontalAlignment(CENTER)

    targetGuildRankIcon = CreateTargetUnitFrameControl("GuildRankIcon", CT_TEXTURE)
    targetGuildRankIcon:SetDimensions(32, 32)

    UpdateTargetFriendIconAnchor()
    UpdateTargetGuildLabelAnchor()
    UpdateTargetGuildRankIconAnchor()

    ZO_PreHook(targetUnitFrame.championIcon, 'SetHidden', function(data, hidden)
        if(isChampionIconHidden ~= hidden) then
            isChampionIconHidden = hidden
            UpdateTargetFriendIconAnchor()
        end
    end)

    ZO_PreHook(targetUnitFrame.captionLabel, 'SetHidden', function(data, hidden)
        if(isCaptionHidden ~= hidden) then
            isCaptionHidden = hidden
            UpdateTargetGuildLabelAnchor()
        end
    end)

    ZO_PreHook(targetUnitFrame.rankIcon, 'SetHidden', function(data, hidden)
        if(isRankIconHidden ~= hidden) then
            isRankIconHidden = hidden
            UpdateTargetFriendIconAnchor()
        end
    end)
end

local function ShouldTargetIgnoreIndicatorHide()
    return (not settings.ignoreIconActive or not IsUnitIgnored(TARGET_UNIT_TAG))
end

local function ShouldTargetFriendIndicatorHide()
    return (not settings.friendIconActive or not IsUnitFriend(TARGET_UNIT_TAG))
end

local function IsUnitGuildMate(unitTag)
    return GetPreferredGuildMemberIndexFromCharacterOrDisplayName(GetUnitName(unitTag)) ~= nil
end

local function ShouldTargetGuildIndicatorHide()
    return (not settings.guildIndicatorActive or not IsUnitGuildMate(TARGET_UNIT_TAG))
end

local function UpdateTargetUnitFrame()
    if(DoesUnitExist(TARGET_UNIT_TAG) and IsUnitPlayer(TARGET_UNIT_TAG)) then
        if(not ShouldTargetIgnoreIndicatorHide()) then
            targetFriendIcon:SetTexture(IGNORED_ICON_TEXTURE)
            targetFriendIcon:SetHidden(false)
        elseif(not ShouldTargetFriendIndicatorHide()) then
            targetFriendIcon:SetTexture(FRIEND_ICON_TEXTURE)
            targetFriendIcon:SetHidden(false)
        else
            targetFriendIcon:SetHidden(true)
        end

        local shouldHide = ShouldTargetGuildIndicatorHide()
        if(not shouldHide) then
            local guildId, memberIndex = GetPreferredGuildMemberIndexFromCharacterOrDisplayName(GetUnitName(TARGET_UNIT_TAG))
            local _, _, rankIndex = GetGuildMemberInfo(guildId, memberIndex)
            targetGuildRankIcon:SetTexture(GetFinalGuildRankTextureLarge(guildId, rankIndex))
            targetGuildLabel:SetText(GetGuildName(guildId))
        end
        targetGuildRankIcon:SetHidden(not settings.guildRankIconActive or shouldHide)
        targetGuildLabel:SetHidden(shouldHide)
    else
        targetFriendIcon:SetHidden(true)
        targetGuildRankIcon:SetHidden(true)
        targetGuildLabel:SetHidden(true)
    end

    CALLBACK_MANAGER:FireCallbacks("SocialIndicators_TargetUnitFrameUpdated")
end

local function InitTargetIndicators()
    if(initialized) then return end

    settings = SocialIndicators_Settings.targetIndicators
    targetUnitFrame = ZO_UnitFrames_GetUnitFrame(TARGET_UNIT_TAG)

    CreateTargetIndicatorControls()

    ZO_PreHook(targetUnitFrame.nameLabel, 'SetText', UpdateTargetUnitFrame)

    CALLBACK_MANAGER:RegisterCallback("SocialIndicators_TARGET_FRIEND_ICON_POSITION_Changed", UpdateTargetFriendIconAnchor)
    CALLBACK_MANAGER:RegisterCallback("SocialIndicators_TARGET_GUILD_RANK_ICON_POSITION_Changed", UpdateTargetGuildRankIconAnchor)

    initialized = true
end

SocialIndicators.ShouldTargetIgnoreIndicatorHide = ShouldTargetIgnoreIndicatorHide
SocialIndicators.ShouldTargetFriendIndicatorHide = ShouldTargetFriendIndicatorHide
SocialIndicators.ShouldTargetGuildIndicatorHide = ShouldTargetGuildIndicatorHide
SocialIndicators.InitTargetIndicators = InitTargetIndicators
