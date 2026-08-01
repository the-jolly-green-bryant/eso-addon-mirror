RaidToolsTestingArea = {}

--
-- Override:Colors - Changes row colors
--

local friend_online_green = ZO_ColorDef:New('01C917')
local best_online_color_ever = ZO_ColorDef:New(1, 0, 0.60392156862, 1)

RTOriginal_ZO_SocialList_GetRowColors = ZO_SocialList_GetRowColors
function ZO_SocialList_GetRowColors(data, selected)
	local textColor = data.online and ZO_SECOND_CONTRAST_TEXT or ZO_DISABLED_TEXT
    local iconColor = data.online and ZO_DEFAULT_ENABLED_COLOR or ZO_DISABLED_TEXT
    if selected then
        textColor = ZO_SELECTED_TEXT
        iconColor = ZO_SELECTED_TEXT
    end
	if data.displayName == '@apfelstrudellq' then
		--if data.online then
		--	textColor = best_online_color_ever
		--end
	elseif data.displayName == '@Napoleoff' and (IsFriend('@Napoleoff') or UID == '@Napoleoff') then
		if data.online then
			--textColor = { ZO_ColorDef:New(.5, .5, 1, .3), ZO_ColorDef:New(.25, .25, .5, .5) }
			textColor = ZO_ColorDef:New('FFD700')
		end
	end
	return textColor, iconColor
end

--
-- Override:ChampionPoint - Displays effective champion points everywhere
--

RTOriginal_ZO_SocialList_SharedSocialSetup = ZO_SocialList_SharedSocialSetup
function ZO_SocialList_SharedSocialSetup(control, data, selected)
	RTOriginal_ZO_SocialList_SharedSocialSetup(control, data, selected)
	local level = GetControl(control, "Level")
	if level then
		if data.championPoints > 0 then level:SetText(data.championPoints)
		else level:SetText(data.level) end
	end
	local zone = GetControl(control, "Zone")
	local status = GetControl(control, "StatusIcon")
	if status then
		if data.displayName == '@apfelstrudellq' then
			if data.status == 3 then
				zone:SetText('|cE72727Working on RaidTools...|r')
			end
			--if (IsFriend('@apfelstrudellq') or UID == '@apfelstrudellq') then
			--	status:SetTexture(GetRTTexture('unicorn'))
			--end
			status:SetTexture(GetRTTexture('unicorn'))
		elseif data.displayName == '@sushiman573' and (IsFriend('@sushiman573') or UID == '@sushiman573') then
			status:SetTexture(GetRTTexture('sushi'))
		elseif data.displayName == '@Arishok33' and (IsFriend('@Arishok33') or UID == '@Arishok33') then
			status:SetTexture(GetRTTexture('whisky'))
		elseif data.displayName == '@Nemata6' and (IsFriend('@Nemata6') or UID == '@Nemata6') then
			status:SetTexture(GetRTTexture('lightsaber_green'))
		end
	end
end

RTOriginal_GetUnitVeteranRank = GetUnitVeteranRank
function GetUnitVeteranRank(unitTag)
	return GetUnitChampionPoints(unitTag)
end

RTOriginal_GetUnitEffectiveChampionPoints = GetUnitEffectiveChampionPoints
function GetUnitEffectiveChampionPoints(unitTag)
	return GetUnitChampionPoints(unitTag)
end

--[[
local function ChatFormatter(channel_id, sender, text)	
	local channels = ZO_ChatSystem_GetChannelInfo()
	local channel = channels[channel_id]

	if not channel or not channel.format then
		return
	end

	text = RaidTools.Iconify(text)

	local channelLink
	if channel.channelLinkable then
		local channelName = GetChannelName(channel.id)
		channelLink = ZO_LinkHandler_CreateChannelLink(channelName)
	end
	
	local playerLink
	if channel.playerLinkable and not sender:find("%[") then
		playerLink = ZO_LinkHandler_CreatePlayerLink(sender)
	else
		playerLink = sender
	end

	if channelLink then
		text = zo_strformat(channel.format, channelLink, playerLink, text)
	else
		text = zo_strformat(channel.format, playerLink, text)
	end

	return text, channel.saveTarget
end
ZO_ChatSystem_AddEventHandler(EVENT_CHAT_MESSAGE_CHANNEL, ChatFormatter)
]]--