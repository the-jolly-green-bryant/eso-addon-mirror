local addon = {
	name = "RankNotifier",
	title = "Guild Rank Notifier",
	author = "Valve",
	version = "1.2.0",
	sv = nil,
	defaults = {
		notificationType = 1,
		guilds = {}
	}
}

local guildNotifications = {}
local activeNotifications

--Libraries
local LAM2, LN

---------- Events ----------
local function SelfRankChanged(eventCode, guildId, newRank, rankChangeAction)
	local guildName = GetGuildName(guildId)
	if addon.sv.guilds[guildName].enabled then
		addon.sv.guilds[guildName].newRank = newRank
		addon:AddRankNotification(guildId, newRank, rankChangeAction)
	end
end

-- Function to remove custom notification
local function RemoveNotification(provider, data)
	local t = provider.notifications
	local j = data.notificationId
	-- Loop through table starting at index
	for i=j, #t do
		-- Replace current element with next element
		t[i] = t[i+1]
		-- Update index in data
		if i<#t then
			t[i].notificationId = i
		end
	end
	provider:UpdateNotifications()
end

local function SelfJoinedGuild(eventCode, guildId, guildName)
	local data = {
		enabled = true,
		rank = nil,
		allianceId = GetGuildAlliance(guildId),
		active = true,
	}
	addon.sv.guilds[guildName] = data
	if guildNotifications[guildName] ~= nil then
		RemoveNotification(activeNotifications, guildNotifications[guildName])
	end
	addon:ReIndexGuildControls()
end

-- Callback functions
local function DeleteCallback(data)
	if addon.sv.guilds[data.guildName].active == false then
		addon.sv.guilds[data.guildName] = nil
	else
		addon.sv.guilds[data.guildName].rank = addon.sv.guilds[data.guildName].newRank
		addon.sv.guilds[data.guildName].newRank = nil
	end
	guildNotifications[data.guildName] = nil
	RemoveNotification(activeNotifications, data)
end

function addon:ReIndexGuildControls()
    if not RankNotifierControl_Guild_1 then
        return --controls haven't been created yet so we dont have to do anything
    end
    
    for i=1, MAX_GUILDS do
        local control = WINDOW_MANAGER:GetControlByName("RankNotifierControl_Guild_", i)
        if control then --just in case
            control.label:SetText(LAM2.util.GetStringFromValue(control.data.name))
			control.data.tooltipText = LAM2.util.GetStringFromValue(control.data.tooltip)
            LAM2.util.RegisterForRefreshIfNeeded(control)
        end
    end

    local panel = WINDOW_MANAGER:GetControlByName(addon.name)
    if (panel and not panel:IsHidden()) then 
        LAM2.util.RequestRefreshIfNeeded(RankNotifierControl_Guild_1) --cant pass the panel, need to pass an actual control
    end
end

function addon:AddRankNotification(guildId, rankIndex, rankChangeAction)
	local guildName = GetGuildName(guildId)
	local alliance = GetGuildAlliance(guildId)
	local allianceIcon = zo_iconFormat(GetAllianceBannerIcon(alliance), 24, 24)
	local rankIcon = zo_iconFormat(GetGuildRankLargeIcon(GetGuildRankIconIndex(guildId, rankIndex)), 24, 24)

	-- Remove any undismissed notification for the current guild
	if guildNotifications[guildName] ~= nil then
		RemoveNotification(activeNotifications, guildNotifications[guildName])
	end

	local rankChangeStringId
	if (rankChangeAction == GUILD_RANK_CHANGE_ACTION_PROMOTE) then
		rankChangeStringId = SI_RN_RANK_PROMOTED_MSG
	elseif (rankChangeAction == GUILD_RANK_CHANGE_ACTION_DEMOTE) then
		rankChangeStringId = SI_RN_RANK_DEMOTED_MSG
	else
		rankChangeStringId = SI_RN_RANK_CHANGED_MSG
	end

	local notificationData = {
		dataType                = NOTIFICATIONS_ALERT_DATA,
		secsSinceRequest        = ZO_NormalizeSecondsSince(0),
		--note                    = GetString(),
		message                 = zo_strformat(rankChangeStringId, allianceIcon, guildName, rankIcon, GetFinalGuildRankName(guildId, rankIndex)),
		heading                 = GetString(SI_RN_RANK_CHANGED_HEADING),
		texture                 = "esoui/art/notifications/notificationicon_guild.dds",
		--shortDisplayText        = DisplayName,
		controlsOwnSounds       = false,
		keyboardDeclineCallback = DeleteCallback,
		gamepadDeclineCallback  = DeleteCallback,
		-- Custom keys
		notificationId          = #activeNotifications.notifications + 1,
		guildName				= GetGuildName(guildId),
	}
	
	guildNotifications[guildName] = { notificationId = notificationData.notificationId }
	-- Add custom notification
	table.insert(activeNotifications.notifications, notificationData)
	activeNotifications:UpdateNotifications()
end

local function AddRemovedNotification(guildName)
	if not addon.sv.guilds[guildName] then return end
	local allianceIcon = zo_iconFormat(GetAllianceBannerIcon(addon.sv.guilds[guildName].allianceId), 24, 24)
	--local rankIcon = zo_iconFormat(GetGuildRankLargeIcon(GetGuildRankIconIndex(guildId, rankIndex)), 24, 24)
	-- Custom notification info
	
	if guildNotifications[guildName] ~= nil then
		RemoveNotification(activeNotifications, guildNotifications[guildName])
	end
	
	local notificationData = {
		dataType                = NOTIFICATIONS_ALERT_DATA,
		secsSinceRequest        = ZO_NormalizeSecondsSince(0),
		--note                    = GetString(),
		message                 = zo_strformat(SI_RN_GUILD_REMOVED_MSG, allianceIcon, guildName),
		heading                 = GetString(SI_RN_GUILD_REMOVED_HEADING),
		texture                 = "esoui/art/notifications/notificationicon_guild.dds",
		--shortDisplayText        = DisplayName,
		controlsOwnSounds       = false,
		keyboardDeclineCallback = DeleteCallback,
		gamepadDeclineCallback  = DeleteCallback,
		-- Custom keys
		notificationId          = #activeNotifications.notifications + 1,
		guildName				= guildName,
	}

	guildNotifications[guildName] = { notificationId = notificationData.notificationId }
	-- Add custom notification
	table.insert(activeNotifications.notifications, notificationData)
	activeNotifications:UpdateNotifications()
end

local function SelfLeftGuild(eventCode, guildId, guildName)
	if addon.sv.guilds[guildName].enabled then
		AddRemovedNotification(guildName)
	end
	addon:ReIndexGuildControls()
end

function addon:CheckGuildChanges()
	for guildName, guild in pairs(self.sv.guilds) do
		-- if true then return end
		local guildExists = false
		for i=1,GetNumGuilds() do
			local guildId = GetGuildId(i)
			local activeGuildName = GetGuildName(guildId)
			if activeGuildName == guildName then
				guildExists = true
				guild.active = true
				break
			end
		end
		if not guildExists then
			guild.active = false
			AddRemovedNotification(guildName)
		end
	end
end

function addon:CheckRankChanges()
	for i=1, GetNumGuilds() do
		local guildId = GetGuildId(i)
		local guildName = GetGuildName(guildId)
		if self.sv.guilds[guildName].enabled then
			local _, _, rankIndex = GetGuildMemberInfo(guildId, GetPlayerGuildMemberIndex(guildId))	
			if self.sv.guilds[guildName].rank ~= nil then
				if self.sv.guilds[guildName].rank ~= rankIndex then
					local rankChangeAction = self.sv.guilds[guildName].rank > rankIndex and GUILD_RANK_CHANGE_ACTION_PROMOTE or GUILD_RANK_CHANGE_ACTION_DEMOTE
					self.sv.guilds[guildName].newRank = rankIndex
					self:AddRankNotification(guildId, rankIndex, rankChangeAction)
				end
			else
				self.sv.guilds[guildName].rank = rankIndex
			end
		end
	end
end

function addon:SetupDefaults()
	for i=1, GetNumGuilds() do
		local guildId = GetGuildId(i)
		local guildName = GetGuildName(guildId)
		if self.sv.guilds[guildName] == nil then
			data = {
				enabled = true,
				rank = nil,
				allianceId = GetGuildAlliance(guildId),
				active = true,
			}
			self.sv.guilds[guildName] = data
		end
	end
end

local function OnAddonLoaded(event, name)
	if name ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	addon:Initialise()
	addon:SetupDefaults()
	addon:CheckGuildChanges()
	addon:CheckRankChanges()
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GUILD_PLAYER_RANK_CHANGED, SelfRankChanged)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GUILD_SELF_LEFT_GUILD, SelfLeftGuild)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GUILD_SELF_JOINED_GUILD, SelfJoinedGuild) 
end

function addon:Initialise()
	LAM2 = LibAddonMenu2
	LN = LibNotification
	if not LN or not LAM2 then return end
	activeNotifications = LN:CreateProvider()

	self.sv = ZO_SavedVars:NewAccountWide(self.name .. "_dat", 3, nil, self.defaults, GetWorldName())
	self.activeCharacterId = GetCurrentCharacterId()

	local panelData = {
		type = "panel",
		name = addon.title,
		displayName = addon.title,
		author = addon.author,
		version = addon.version,
		-- slashCommand = "",
		registerForRefresh = true,
		registerForDefaults = true,
		website = "http://www.esoui.com/downloads/info1660-GuildRankNotifier-GuildRankChangeNotifications.html",
	}
	LAM2:RegisterAddonPanel(addon.name, panelData)

	local optionsTable = {}
	optionsTable[#optionsTable+1] =
	{
		type = "header",
		name = GetString(SI_RN_GUILD_ENABLED_HEADER),
	}
	optionsTable[#optionsTable+1] =
	{
		type = "description",
		text = GetString(SI_RN_GUILD_ENABLED_DESC),
	}

	---------- START GUILDS ENABLED CHECK ----------
	for i=1, MAX_GUILDS do
		local guildId = GetGuildId(i)
		local guildName = GetGuildName(guildId)
		optionsTable[#optionsTable+1] = {
			type = "checkbox",
			name = function() return guildName end,
			tooltip = function()
				if guildId > 0 then
					return zo_strformat(GetString(SI_RN_GUILD_ENABLED_TOOLTIP), guildName)
				end
			end,
			getFunc = function()
				if guildId > 0 then
					return self.sv.guilds[guildName].enabled
				else return false end
			end,
			setFunc = function(value)
				if guildId > 0 then
					self.sv.guilds[guildName].enabled = value
					if (not value) then
						if guildNotifications[guildName] ~= nil then
							RemoveNotification(activeNotifications, guildNotifications[guildName])
						end
					else
						addon:CheckRankChanges()
						addon:CheckGuildChanges()
					end
				end
			end,
			default = true,
			disabled = function() return guildId == 0 end,
			reference = "RankNotifierControl_Guild_" .. i
		}
	end
	----------  END GUILDS ENABLED CHECK  ----------

	LAM2:RegisterOptionControls(addon.name, optionsTable)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

GUILD_RANK_NOTIFIER = addon