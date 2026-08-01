--------------------------------------------------------------------
-- Local variables
--------------------------------------------------------------------

local NAME = "GuildOrder"
local VERSION = "0.1"

local EM = EVENT_MANAGER
local CM -- callback manager

local SV = nil -- saved variables
local SV_DEFAULTS = {
	guilds = {}, -- custom guild order (guild id => order)
}

local enabledConflicts = {} -- table keys from conflicts.lua that should be checked

local sortedGuilds	= {} -- new guild index	=> guild id
local guildIndexMap = {} -- original index	=> new index
local channelMap	= {} -- channel id		=> original chat channel id

-- Channel data
local ChannelInfo = ZO_ChatSystem_GetChannelInfo()
local g_switchLookup = ZO_ChatSystem_GetChannelSwitchLookupTable() -- use the same names as ZOS just for convenience
local errorMessages = {}
for k, v in pairs(ChannelInfo) do
	errorMessages[k] = v['requirementErrorMessage']
end

--------------------------------------------------------------------
-- API

-- With GuildOrder enabled it's wrong to assume that CHAT_CHANNEL_GUILD_1 shows messages of the guild with index 1.
-- 
--------------------------------------------------------------------

-- Use xGetGuildId(index) if you need to call the original function.
xGetGuildId = GetGuildId

GuildOrder = {}

-- Saved variables are loaded on EVENT_ADD_ON_LOADED,
-- so it's safe to use API functions if your addon is loaded and initialized after GuildOrder.
function GuildOrder.IsInitialized()
	return SV ~= nil
end

function GuildOrder.GetName()
	return NAME
end

function GuildOrder.GetVersion()
	return VERSION
end

-- Returns original (old) index for current (new) guild index,
-- e.g. if player moved "guild 5" all the way up, then this function will return 5 for index 1
function GuildOrder.GetOldGuildIndex(newIndex)
	return guildIndexMap[newIndex]
end

-- The opposite of previous function.
function GuildOrder.GetNewGuildIndex(oldIndex)
	-- I don't think it's worth to have a separate table to avoid this loop, at least for now...
	for k, v in pairs(guildIndexMap) do
		if v == oldIndex then
			return k
		end
	end
end

-- Returns guild chat channel id by current guild index.
function GuildOrder.GetGuildChannel(index)
	return channelMap[CHAT_CHANNEL_GUILD_1 + index - 1]
end

-- Returns officer chat channel id by current guild index.
function GuildOrder.GetOfficerChannel(index)
	return channelMap[CHAT_CHANNEL_OFFICER_1 + index - 1]
end

-- Returns current guild index by chat channel id.
function GuildOrder.GetGuildIndexByChannel(channel)
	if channel >= CHAT_CHANNEL_GUILD_1 and channel <= CHAT_CHANNEL_GUILD_5 then
		return GuildOrder.GetNewGuildIndex(channel - CHAT_CHANNEL_GUILD_1 + 1)-- + CHAT_CHANNEL_GUILD_1 - 1
	elseif channel >= CHAT_CHANNEL_OFFICER_1 and channel <= CHAT_CHANNEL_OFFICER_5 then
		return GuildOrder.GetNewGuildIndex(channel - CHAT_CHANNEL_OFFICER_1 + 1)-- + CHAT_CHANNEL_OFFICER_1 - 1
	end
end

-- Returns guild id by chat channel id.
function GuildOrder.GetGuildIdByChannel(channel)
	return sortedGuilds[GuildOrder.GetGuildIndexByChannel(channel)]
end

-- Returns guild channel id by guild id.
function GuildOrder.GetGuildChannelByGuildId(id)
	return SV.guilds[id] and GuildOrder.GetGuildChannel(SV.guilds[id]) or CHAT_CHANNEL_GUILD_1
end

-- Returns officer channel id by guild id.
function GuildOrder.GetOfficerChannelByGuildId(id)
	return SV.guilds[id] and GuildOrder.GetOfficerChannel(SV.guilds[id]) or CHAT_CHANNEL_OFFICER_1
end

-- Set new guild order based on table t (probably shouldn't be used outside of GuildOrder menu).
-- Allowed table formats:
-- 1) guild id => order
-- 2) order (1-5) => guild id
-- 3) LibAddonMenuOrderListBox's listEntries (index => table)
function GuildOrder.SetOrder(t)
	for k, v in pairs(t) do
		if type(v) == 'table' then
			SV.guilds[v.uniqueKey] = k
		elseif k > 0 and k < MAX_GUILDS + 1 then
			SV.guilds[v] = k
			A.requiresReload = true
		else
			SV.guilds[k] = v
			A.requiresReload = true
		end
	end
	GuildOrder.ValidateGuilds()
end

-- Reset guild order to default
function GuildOrder.ResetOrder(reload)
	for k in pairs(SV.guilds) do
		SV.guilds[k] = nil
	end
	GuildOrder.ValidateGuilds()

	if reload then
		ReloadUI()
	end
end

-- Addon events
-- Use GuildOrder.RegisterCallback(event, callback) to register a callback
GUILD_ORDER_CHANGED	= "OrderChanged" -- player changed guild order (it can be the same as the previous one, though)

function GuildOrder.RegisterCallback(eventName, callback)
    CM:RegisterCallback(eventName, callback)
end

function GuildOrder.UnregisterCallback(eventName, callback)
    CM:UnregisterCallback(eventName, callback)
end

-- Conflicts (see conflicts.lua)
function GuildOrder.AddConflict(addonName, callback)
	GuildOrder.conflicts[addonName] = callback
	enabledConflicts[addonName] = true
end

function GuildOrder.DisableConflict(addonName)
	enabledConflicts[addonName] = nil
end

function GuildOrder.IsConflictEnabled(addonName)
	return enabledConflicts[addonName] == true
end

--------------------------------------------------------------------
-- Internal Magic (10% logic, 90% testing to find whatever works)
--------------------------------------------------------------------

local A  = GuildOrder

-- Overriding this function covers the majority of default places where guild list is shown.
-- For addons it can be an issue however, but we can dynamically choose between new and original return value depending on traceback.
GetGuildId = function(index)
	if sortedGuilds[index] then -- make sure data is loaded
		-- check for conflicts
		local tb = debug.traceback()
		local foundConflicts = false
		for name, enabled in pairs(enabledConflicts) do
			local f = A.conflicts[name]
			if enabled and f then
				foundConflicts = foundConflicts or f(tb)
			end
		end
		-- if there are no conflicts, then return guild id based on user guild order
		if not foundConflicts then
			return sortedGuilds[index]
		end
	end
	return xGetGuildId(index)
end

-- Update possibly outdated data
function A.ValidateGuilds()
	if not SV.guilds then SV.guilds = {} end

	local guilds = {} -- guilds player is currently in
	local defaultOrder = {}
	for i = 1, GetNumGuilds() do
		local id = xGetGuildId(i)
		table.insert(guilds, id)
		defaultOrder[id] = i
	end

	-- Sort guilds based on saved vars first, otherwise use the default order
	table.sort(guilds, function(a, b)
		if SV.guilds[a] or SV.guilds[b] then		
			if SV.guilds[a] and SV.guilds[b] then
				-- if both guilds are in saved vars, then compare their order
				return SV.guilds[a] < SV.guilds[b]
			else
				-- if "b" is not in SV, then "a" goes first
				return SV.guilds[b] == nil
			end
		else
			return defaultOrder[a] < defaultOrder[b]
		end
	end)

	sortedGuilds = guilds

	-- Update original index => new index
	for i = 1, GetNumGuilds() do
		guildIndexMap[i] = defaultOrder[guilds[i]]
	end

	-- Update saved vars
	for id in pairs(SV.guilds) do
		SV.guilds[id] = nil -- clear old data first
	end
	for i, id in ipairs(sortedGuilds) do
		SV.guilds[id] = i
	end

	CM:FireCallbacks(GUILD_ORDER_CHANGED)
end

-- Update switches in ZO_ChatSystem_GetChannelSwitchLookupTable()
local function UpdateSwitchLookupTable(channel1)
	for k, v in pairs(guildIndexMap) do -- {1=>2, 2=>3, 3=>1}
		local oldChannel = v + channel1 - 1 -- 13
		local newChannel = k + channel1 - 1 -- 12

		local mainSwitch = false
		for switchArg in ChannelInfo[newChannel]['switches']:gmatch("%S+") do -- /g1 /group1
			g_switchLookup[switchArg] = ChannelInfo[oldChannel]
			g_switchLookup[switchArg]['requirementErrorMessage'] = errorMessages[newChannel] -- error message callback is tricky, because it uses the original guild index but with the new GetGuildId
			-- g_switchLookup consists of two type of values: "switch"=>{channel data} and [channel id]=>"switch"
			if not mainSwitch then
				mainSwitch = switchArg
				g_switchLookup[oldChannel] = mainSwitch
			end
		end

		channelMap[newChannel] = oldChannel
	end
end

-- Settings -> Social tab needs special attention.
-- It uses its own constants instead of CHAT_CHANNEL_*, so we need to map them.
local social = {
	[CHAT_CHANNEL_GUILD_1]		= OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_GUILD1,
	[CHAT_CHANNEL_GUILD_2]		= OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_GUILD2,
	[CHAT_CHANNEL_GUILD_3]		= OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_GUILD3,
	[CHAT_CHANNEL_GUILD_4]		= OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_GUILD4,
	[CHAT_CHANNEL_GUILD_5]		= OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_GUILD5,
	[CHAT_CHANNEL_OFFICER_1]	= OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_OFFICER1,
	[CHAT_CHANNEL_OFFICER_2]	= OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_OFFICER2,
	[CHAT_CHANNEL_OFFICER_3]	= OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_OFFICER3,
	[CHAT_CHANNEL_OFFICER_4]	= OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_OFFICER4,
	[CHAT_CHANNEL_OFFICER_5]	= OPTIONS_CUSTOM_SETTING_SOCIAL_CHAT_COLOR_OFFICER5,
}
-- channel name (Guild 1, Officer 1, etc) => category (needed to update checkboxes in Chat Tab Options window)
local channelNameCategory = {}

local function OnGuildOrderChanged()
	-- Rebuild guild selector
	GUILD_SELECTOR:InitializeGuilds()

	UpdateSwitchLookupTable(CHAT_CHANNEL_GUILD_1)
	UpdateSwitchLookupTable(CHAT_CHANNEL_OFFICER_1)

	for k, v in pairs(social) do
		local newCategory = GetChannelCategoryFromChannel(channelMap[k])
		ZO_SharedOptions_SettingsData[SETTING_PANEL_SOCIAL][SETTING_TYPE_CUSTOM][v]['chatChannelCategory'] = newCategory
		channelNameCategory[GetString("SI_CHATCHANNELCATEGORIES", GetChannelCategoryFromChannel(k))] = newCategory
	end
end

--------------------------------------------------------------------
---- Load & Initialize
--------------------------------------------------------------------

local function Initialize()
	CM = ZO_CallbackObject:New()

	-- Retrieve saved variables
	SV = ZO_SavedVars:NewAccountWide('GuildOrderSV', 1, GetWorldName(), SV_DEFAULTS)

	-- Events
	A.RegisterCallback(GUILD_ORDER_CHANGED, OnGuildOrderChanged)
	EM:RegisterForEvent(NAME, EVENT_GUILD_DATA_LOADED, function() -- account login, join/leave guild
		A.ValidateGuilds()
		-- if panel has been already created, then it's much easier just to reloadui than to add/remove list items and make sure everything is correct
		if A.lamPanel and A.lamPanel.isCreated then
			A.requiresReload = true
			if LibAddonMenu2.currentAddonPanel == A.lamPanel and LibAddonMenu2.currentPanelOpened then
				LibAddonMenu2.util.RequestRefreshIfNeeded(A.lamPanel)
			end
		end
	end)

	-- Make sure guild data is valid (saved vars can become outdated if player's guilds change when the addon is not loaded)
	A.ValidateGuilds()

	-- Build LibAddonMenu2
	A.BuildMenu(SV, SV_DEFAULTS)

	-- Update channels for checkboxes in chat options
	ZO_PostHook(CHAT_OPTIONS, 'UpdateGuildNames', function()
		for k, button in pairs(CHAT_OPTIONS.filterButtons) do
			local name = button.label:GetText()
			if channelNameCategory[name] then
				button.channels[1] = channelNameCategory[name]
			end
		end
	end)
end

local function OnAddOnLoaded(event, addonName)
	if A.conflicts[addonName] then
		-- To disable a conflict, another addon should load after GuildOrder (by adding "## OptionalDependsOn: GuildOrder" to addonName.txt) and call A.DisableConflict(addonName)
		enabledConflicts[addonName] = true
	elseif addonName == NAME then
		--EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED) -- need to check all addons for potential conflicts
		Initialize()
	end
end

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
