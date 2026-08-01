local FRIEND_ICON_TEXTURE = "SocialIndicators/images/adominion/friendicon.dds"
local IGNORED_ICON_TEXTURE = "SocialIndicators/images/adominion/ignored.dds"
local GUILD_ICON_TEXTURE = "SocialIndicators/images/adominion/guildicon.dds"

local IsSelf = SocialIndicators.IsSelf
local RegisterForEvent = SocialIndicators.RegisterForEvent
local GetPreferredGuildMemberIndexFromCharacterOrDisplayName = SocialIndicators.GetPreferredGuildMemberIndexFromCharacterOrDisplayName
local GetFinalGuildRankTextureCropped = SocialIndicators.GetFinalGuildRankTextureCropped

local initialized = false
local refreshGroupIconsPending = false
local settings = nil

local function CreateGroupUnitFrameIcon(unitTag, unitFrame, name)
	local icon = WINDOW_MANAGER:CreateControl("SocialIndicators" .. unitFrame.style .. unitTag .. name, unitFrame.frame, CT_TEXTURE)
	icon:SetDimensions(12, 12)
	icon:SetDrawLayer(2)
	icon:SetHidden(true)
	table.insert(unitFrame.fadeComponents, icon)
	return icon
end

local function CreateGroupFriendIcon(unitTag, unitFrame)
	local icon = CreateGroupUnitFrameIcon(unitTag, unitFrame, "FriendIcon")
	icon:SetTexture(IGNORED_ICON_TEXTURE)
	if(unitFrame.style == "ZO_RaidUnitFrame") then
		icon:SetAnchor(BOTTOMRIGHT, unitFrame.frame, BOTTOMRIGHT, -5, -3)
	else
		icon:SetAnchor(TOPLEFT, unitFrame.frame, TOPLEFT, 16, 22)
	end
	return icon
end

local function CreateGroupGuildIcon(unitTag, unitFrame)
	local icon = CreateGroupUnitFrameIcon(unitTag, unitFrame, "GuildIcon")
	icon:SetTexture(GUILD_ICON_TEXTURE)
	if(unitFrame.style == "ZO_RaidUnitFrame") then
		icon:SetAnchor(BOTTOMRIGHT, unitFrame.frame, BOTTOMRIGHT, -20, -3)
	else
		icon:SetAnchor(TOPLEFT, unitFrame.frame, TOPLEFT, 16, 38)
	end
	return icon
end

local function ShouldGroupIgnoreIndicatorHide(unitTag)
	return (not settings.ignoreIconActive or not IsUnitIgnored(unitTag))
end

local function ShouldGroupFriendIndicatorHide(unitTag)
	return (not settings.friendIconActive or not IsUnitFriend(unitTag))
end

local function IsUnitGuildMate(unitTag)
	return GetPreferredGuildMemberIndexFromCharacterOrDisplayName(GetUnitName(unitTag)) ~= nil
end

local function ShouldGroupGuildIndicatorHide(unitTag)
	return (not settings.guildIconActive or IsSelf(GetUnitName(unitTag)) or not IsUnitGuildMate(unitTag))
end

local function UpdateGroupFriendIcon(unitTag, unitFrame)
	if(not unitFrame.friendIcon) then
		unitFrame.friendIcon = CreateGroupFriendIcon(unitTag, unitFrame)
	end
	local icon = unitFrame.friendIcon

	if(not ShouldGroupIgnoreIndicatorHide(unitTag)) then
		icon:SetTexture(IGNORED_ICON_TEXTURE)
		icon:SetHidden(false)
	elseif(not ShouldGroupFriendIndicatorHide(unitTag)) then
		icon:SetTexture(FRIEND_ICON_TEXTURE)
		icon:SetHidden(false)
	else
		icon:SetHidden(true)
	end
end

local function UpdateGroupGuildIcon(unitTag, unitFrame)
	if(not unitFrame.guildIcon) then
		unitFrame.guildIcon = CreateGroupGuildIcon(unitTag, unitFrame)
	end
	local icon = unitFrame.guildIcon

	local shouldHide = ShouldGroupGuildIndicatorHide(unitTag)
	if(not shouldHide) then
		local guildId, memberIndex = GetPreferredGuildMemberIndexFromCharacterOrDisplayName(GetUnitName(unitTag))
		local _, _, rankIndex = GetGuildMemberInfo(guildId, memberIndex)
		icon:SetTexture(settings.showGuildRankIcon and GetFinalGuildRankTextureCropped(guildId, rankIndex) or GUILD_ICON_TEXTURE)
	end
	icon:SetHidden(shouldHide)
end

local function HideGroupIcons(unitFrame)
	if(unitFrame.guildIcon) then unitFrame.guildIcon:SetHidden(true) end
	if(unitFrame.friendIcon) then unitFrame.friendIcon:SetHidden(true) end
end

local function UpdateGroupSocialIndicators()
	local isLargeGroup = GetGroupSize() > SMALL_GROUP_SIZE_THRESHOLD
	local frameList = isLargeGroup and UNIT_FRAMES.raidFrames or UNIT_FRAMES.groupFrames

	for unitTag, unitFrame in pairs(frameList) do
		if(DoesUnitExist(unitTag) and IsUnitPlayer(unitTag)) then
			UpdateGroupGuildIcon(unitTag, unitFrame)
			UpdateGroupFriendIcon(unitTag, unitFrame)
		else
			HideGroupIcons(unitFrame)
		end
	end

	refreshGroupIconsPending = false
end

local function ClearCallLater(id)
	EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction"..id)
end

local function RequestUpdateGroupSocialIndicators()
	-- for some reason raid groups are always recreated when something changes
	-- in order to minimize the work, we wait for all events to fire and update afterwards
	if(refreshGroupIconsPending) then
		ClearCallLater(refreshGroupIconsPending)
		refreshGroupIconsPending = false
	end
	if(IsUnitGrouped("player")) then
		refreshGroupIconsPending = zo_callLater(UpdateGroupSocialIndicators, 200)
	end
end

local function InitGroupIndicators()
	if(initialized) then return end
	settings = SocialIndicators_Settings.groupIndicators

	UpdateGroupSocialIndicators()

	RegisterForEvent(EVENT_GROUP_MEMBER_JOINED, RequestUpdateGroupSocialIndicators)
	RegisterForEvent(EVENT_GROUP_MEMBER_LEFT, RequestUpdateGroupSocialIndicators)
	RegisterForEvent(EVENT_GROUP_TYPE_CHANGED, RequestUpdateGroupSocialIndicators)
	RegisterForEvent(EVENT_GROUP_UPDATE, RequestUpdateGroupSocialIndicators)
	RegisterForEvent(EVENT_FRIEND_ADDED, RequestUpdateGroupSocialIndicators)
	RegisterForEvent(EVENT_FRIEND_REMOVED, RequestUpdateGroupSocialIndicators)
	RegisterForEvent(EVENT_GUILD_MEMBER_ADDED, RequestUpdateGroupSocialIndicators)
	RegisterForEvent(EVENT_GUILD_MEMBER_REMOVED, RequestUpdateGroupSocialIndicators)
	RegisterForEvent(EVENT_GUILD_SELF_JOINED_GUILD, RequestUpdateGroupSocialIndicators)
	RegisterForEvent(EVENT_GUILD_SELF_LEFT_GUILD, RequestUpdateGroupSocialIndicators)

	CALLBACK_MANAGER:RegisterCallback("SocialIndicators_GROUP_IGNORE_ICON_ACTIVE_Changed", RequestUpdateGroupSocialIndicators)
	CALLBACK_MANAGER:RegisterCallback("SocialIndicators_GROUP_FRIEND_ICON_ACTIVE_Changed", RequestUpdateGroupSocialIndicators)
	CALLBACK_MANAGER:RegisterCallback("SocialIndicators_GROUP_GUILD_ICON_ACTIVE_Changed", RequestUpdateGroupSocialIndicators)
	CALLBACK_MANAGER:RegisterCallback("SocialIndicators_GROUP_SHOW_GUILD_RANK_ICON_Changed", RequestUpdateGroupSocialIndicators)

	initialized = true
end

SocialIndicators.InitGroupIndicators = InitGroupIndicators
SocialIndicators.RequestUpdateGroupSocialIndicators = RequestUpdateGroupSocialIndicators
SocialIndicators.ShouldGroupIgnoreIndicatorHide = ShouldGroupIgnoreIndicatorHide
SocialIndicators.ShouldGroupFriendIndicatorHide = ShouldGroupFriendIndicatorHide
SocialIndicators.ShouldGroupGuildIndicatorHide = ShouldGroupGuildIndicatorHide
